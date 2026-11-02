-- AntiCheat Bypass.
---@module AntiCheat.Bypass
local Bypass = {}

local Constants = ModuleLoader.load("Core/Constants")
local Utilities = ModuleLoader.load("Core/Utilities")
local Logger = ModuleLoader.load("Utility/Logger")

Bypass.initialized = false
Bypass.antiTunnelModule = nil
Bypass.originalFunctions = {}

---Initialize anti-cheat bypass
function Bypass.initialize()
    if Bypass.initialized then return end

    Logger.info("Initializing AntiCheat Bypass...")

    -- Find and analyze AntiTunnel module
    Bypass.antiTunnelModule = Bypass.findAntiTunnelModule()
    if Bypass.antiTunnelModule then
        Logger.info("Found AntiTunnel module")
        Bypass.hookAntiTunnel()
    else
        Logger.warn("AntiTunnel module not found")
    end

    -- Hook common detection methods
    Bypass.hookDetectionMethods()

    Bypass.initialized = true
    Logger.info("AntiCheat Bypass initialized")
end

---Find AntiTunnel module in ReplicatedStorage
---@return ModuleScript?
function Bypass.findAntiTunnelModule()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    return ReplicatedStorage:FindFirstChild(Constants.ANTI_TUNNEL_NAME)
end

---Hook AntiTunnel detection functions
function Bypass.hookAntiTunnel()
    if not Bypass.antiTunnelModule then return end

    local success, module = pcall(require, Bypass.antiTunnelModule)
    if not success then
        Logger.warn("Failed to require AntiTunnel: " .. tostring(module))
        return
    end

    -- Hook all functions in the module to return safe values
    for key, value in pairs(module) do
        if typeof(value) == "function" then
            Bypass.originalFunctions[key] = value
            local hook = Utilities.protectFunction(function(...)
                -- Return safe defaults for detection functions
                if key:find("Check") or key:find("Detect") or key:find("Validate") then
                    return true, "OK"
                end
                return Bypass.originalFunctions[key](...)
            end)
            module[key] = hook
        end
    end
end

---Hook common detection methods
function Bypass.hookDetectionMethods()
    -- Hook WalkSpeed/__index spoofing
    local humanoidMeta = getrawmetatable(game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid"))
    if humanoidMeta then
        local oldIndex = humanoidMeta.__index
        humanoidMeta.__index = Utilities.protectFunction(function(self, key)
            if key == "WalkSpeed" or key == "JumpPower" or key == "JumpHeight" then
                return oldIndex(self, key)
            end
            return oldIndex(self, key)
        end)
    end

    -- Hook RemoteEvent FireServer to prevent logging
    local oldNamecall
    oldNamecall = Utilities.safeHookMetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        -- Prevent detection remotes from being logged
        if method == "FireServer" and self.Name and self.Name:lower():find("detect") then
            return
        end

        return oldNamecall(self, ...)
    end)
end

---Spoof getfenv for game scripts
function Bypass.spoofGetfenv()
    local RobloxEnv = getrenv()
    local FakeEnv = {}
    setmetatable(FakeEnv, {__index = RobloxEnv})

    local oldGetfenv = RobloxEnv.getfenv
    RobloxEnv.getfenv = Utilities.protectFunction(function(...)
        local args = {...}
        local level = args[1] or 1

        -- Check call stack for AntiTunnel
        for i = 1, 10 do
            if debug.isvalidlevel(i) then
                local info = debug.getinfo(i, "S")
                if info and info.source and info.source:find(Constants.ANTI_TUNNEL_NAME) then
                    return FakeEnv
                end
            else
                break
            end
        end

        return oldGetfenv(...)
    end)
end

---Protect hooks from detection
---@param hookFunc function
---@return function
function Bypass.protectHook(hookFunc)
    return Utilities.protectFunction(hookFunc, true)
end

---Check if we're in a protected context
---@return boolean
function Bypass.isProtectedContext()
    return checkcaller()
end

return Bypass