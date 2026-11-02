-- Environment Spoofing.
---@module AntiCheat.EnvironmentSpoof
local EnvironmentSpoof = {}

local Constants = require("Core/Constants")
local Utilities = require("Core/Utilities")
local Logger = require("Utility/Logger")

EnvironmentSpoof.originalGetfenv = nil
EnvironmentSpoof.fakeEnv = nil

---Initialize environment spoofing
function EnvironmentSpoof.initialize()
    Logger.info("Initializing Environment Spoofing...")
    EnvironmentSpoof.createFakeEnv()
    EnvironmentSpoof.hookGetfenv()
    EnvironmentSpoof.hookGetrenv()
    Logger.info("Environment Spoofing initialized")
end

---Create fake environment for spoofing
function EnvironmentSpoof.createFakeEnv()
    local RobloxEnv = getrenv()
    EnvironmentSpoof.fakeEnv = {}
    setmetatable(EnvironmentSpoof.fakeEnv, {
        __index = function(t, k)
            -- Block access to executor globals
            if k == "getgenv" or k == "getsenv" or k == "getreg" or k == "getgc" or
               k == "hookfunction" or k == "hookmetamethod" or k == "debug" or
               k == "solara" or k == "LPH_NO_VIRTUALIZE" then
                return nil
            end
            return RobloxEnv[k]
        end
    })
end

---Hook getfenv to return fake env for game scripts
function EnvironmentSpoof.hookGetfenv()
    local RobloxEnv = getrenv()
    EnvironmentSpoof.originalGetfenv = RobloxEnv.getfenv

    RobloxEnv.getfenv = Utilities.protectFunction(function(...)
        local args = {...}
        local level = args[1] or 1

        -- Check call stack for suspicious scripts
        for i = 1, 15 do
            if debug.isvalidlevel(i) then
                local info = debug.getinfo(i, "S")
                if info and info.source then
                    local source = info.source
                    -- Return fake env for AntiTunnel and similar modules
                    if source:find(Constants.ANTI_TUNNEL_NAME) or
                       source:find("AntiCheat") or
                       source:find("Detection") then
                        return EnvironmentSpoof.fakeEnv
                    end
                end
            else
                break
            end
        end

        return EnvironmentSpoof.originalGetfenv(...)
    end)
end

---Hook getrenv to return fake env
function EnvironmentSpoof.hookGetrenv()
    local RobloxEnv = getrenv()
    local originalGetrenv = RobloxEnv.getrenv

    RobloxEnv.getrenv = Utilities.protectFunction(function(...)
        -- Check caller
        if debug.isvalidlevel(2) then
            local info = debug.getinfo(2, "S")
            if info and info.source then
                local source = info.source
                if source:find(Constants.ANTI_TUNNEL_NAME) or
                   source:find("AntiCheat") or
                   source:find("Detection") then
                    return EnvironmentSpoof.fakeEnv
                end
            end
        end
        return originalGetrenv(...)
    end)
end

---Spoof thread identity for require calls
---@param func function
---@param ... any
---@return ...
function EnvironmentSpoof.spoofRequire(func, ...)
    if setthreadidentity then
        setthreadidentity(2)
    end
    local results = {func(...)}
    if setthreadidentity then
        setthreadidentity(8)
    end
    return unpack(results)
end

---Clone service reference for safety
---@param service Instance
---@return Instance
function EnvironmentSpoof.cloneService(service)
    return cloneref(service)
end

---Check if running in executor context
---@return boolean
function EnvironmentSpoof.isExecutorContext()
    return checkcaller()
end

---Get safe environment for game scripts
---@return table
function EnvironmentSpoof.getSafeEnv()
    return EnvironmentSpoof.fakeEnv or getrenv()
end

---Restore original environment
function EnvironmentSpoof.restore()
    local RobloxEnv = getrenv()
    if EnvironmentSpoof.originalGetfenv then
        RobloxEnv.getfenv = EnvironmentSpoof.originalGetfenv
    end
    EnvironmentSpoof.fakeEnv = nil
    Logger.info("Environment restored")
end

return EnvironmentSpoof