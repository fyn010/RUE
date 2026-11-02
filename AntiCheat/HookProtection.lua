-- Hook Protection.
---@module AntiCheat.HookProtection
local HookProtection = {}

local Constants = require("Core/Constants")
local Utilities = require("Core/Utilities")
local Logger = require("Utility/Logger")

HookProtection.hooks = {}
HookProtection.originals = {}

---Create a protected hook for metamethods
---@param object table | Instance
---@param metamethod string
---@param hook function
---@return function
function HookProtection.hookMetamethod(object, metamethod, hook)
    local protectedHook = Utilities.protectFunction(hook, true)
    local original = hookmetamethod(object, metamethod, protectedHook)

    table.insert(HookProtection.hooks, {
        object = object,
        metamethod = metamethod,
        hook = protectedHook,
        original = original
    })

    HookProtection.originals[object .. "." .. metamethod] = original
    Logger.debug("Hooked %s.%s", object.ClassName or "table", metamethod)

    return original
end

---Create a protected hook for functions
---@param func function
---@param hook function
---@return function
function HookProtection.hookFunction(func, hook)
    local protectedHook = Utilities.protectFunction(hook, true)
    local original = hookfunction(func, protectedHook)

    table.insert(HookProtection.hooks, {
        func = func,
        hook = protectedHook,
        original = original
    })

    HookProtection.originals[tostring(func)] = original
    Logger.debug("Hooked function: %s", tostring(func))

    return original
end

---Hook upvalue of a function
---@param func function
---@param upvalueIndex number
---@param newValue any
---@return any
function HookProtection.hookUpvalue(func, upvalueIndex, newValue)
    local oldValue = debug.getupvalue(func, upvalueIndex)
    debug.setupvalue(func, upvalueIndex, newValue)
    Logger.debug("Hooked upvalue %d of %s", upvalueIndex, tostring(func))
    return oldValue
end

---Restore a hooked metamethod
---@param object table | Instance
---@param metamethod string
function HookProtection.restoreMetamethod(object, metamethod)
    local key = object .. "." .. metamethod
    local original = HookProtection.originals[key]
    if original then
        hookmetamethod(object, metamethod, original)
        HookProtection.originals[key] = nil
        Logger.debug("Restored %s.%s", object.ClassName or "table", metamethod)
    end
end

---Restore a hooked function
---@param func function
function HookProtection.restoreFunction(func)
    local key = tostring(func)
    local original = HookProtection.originals[key]
    if original then
        restorefunction(func)
        HookProtection.originals[key] = nil
        Logger.debug("Restored function: %s", key)
    end
end

---Restore all hooks
function HookProtection.restoreAll()
    for _, hookData in ipairs(HookProtection.hooks) do
        if hookData.object and hookData.metamethod then
            hookmetamethod(hookData.object, hookData.metamethod, hookData.original)
        elseif hookData.func then
            restorefunction(hookData.func)
        end
    end
    HookProtection.hooks = {}
    HookProtection.originals = {}
    Logger.info("All hooks restored")
end

---Check if a function is hooked
---@param func function
---@return boolean
function HookProtection.isHooked(func)
    return isfunctionhooked and isfunctionhooked(func) or false
end

---Get original function
---@param func function
---@return function?
function HookProtection.getOriginal(func)
    return HookProtection.originals[tostring(func)]
end

---Wrap hook with Solara protection
---@param hook function
---@return function
function HookProtection.wrapHook(hook)
    return Utilities.protectFunction(hook, true)
end

return HookProtection