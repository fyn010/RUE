-- Infinite Stamina.
---@module Features.Movement.InfiniteStamina
local InfiniteStamina = {}

local Constants = ModuleLoader.load("Core/Constants")
local State = ModuleLoader.load("Core/State")
local Services = ModuleLoader.load("Core/Services")
local Utilities = ModuleLoader.load("Core/Utilities")
local HookProtection = ModuleLoader.load("AntiCheat/HookProtection")
local Logger = ModuleLoader.load("Utility/Logger")

InfiniteStamina.enabled = false
InfiniteStamina.staminaConnection = nil
InfiniteStamina.clientState = nil
InfiniteStamina.originalSpend = nil

---Initialize Infinite Stamina
function InfiniteStamina.initialize()
    Logger.info("Initializing Infinite Stamina...")
    InfiniteStamina.enabled = State.infiniteStaminaEnabled
    InfiniteStamina.clientState = Utilities.getWeaponClientModule(Constants.CLIENT_STATE_NAME)
end

---Enable Infinite Stamina
function InfiniteStamina.enable()
    if InfiniteStamina.enabled then return end

    InfiniteStamina.enabled = true
    State.infiniteStaminaEnabled = true

    -- Hook ClientState Stamina
    InfiniteStamina.hookClientState()

    -- Loop to keep stamina maxed
    InfiniteStamina.staminaConnection = Services.runService.RenderStepped:Connect(function()
        if not InfiniteStamina.enabled then return end
        InfiniteStamina.setMaxStamina()
    end)

    Logger.info("Infinite Stamina enabled")
end

---Disable Infinite Stamina
function InfiniteStamina.disable()
    if not InfiniteStamina.enabled then return end

    InfiniteStamina.enabled = false
    State.infiniteStaminaEnabled = false

    -- Restore spend function
    if InfiniteStamina.originalSpend and InfiniteStamina.clientState then
        InfiniteStamina.clientState.spend = InfiniteStamina.originalSpend
        InfiniteStamina.originalSpend = nil
    end

    if InfiniteStamina.staminaConnection then
        InfiniteStamina.staminaConnection:Disconnect()
        InfiniteStamina.staminaConnection = nil
    end

    Logger.info("Infinite Stamina disabled")
end

---Hook ClientState stamina functions
function InfiniteStamina.hookClientState()
    if not InfiniteStamina.clientState then
        InfiniteStamina.clientState = Utilities.getWeaponClientModule(Constants.CLIENT_STATE_NAME)
    end

    if not InfiniteStamina.clientState then
        Logger.warn("ClientState not found")
        return
    end

    -- Hook spend function
    if InfiniteStamina.clientState.spend and typeof(InfiniteStamina.clientState.spend) == "function" then
        InfiniteStamina.originalSpend = InfiniteStamina.clientState.spend
        InfiniteStamina.clientState.spend = HookProtection.wrapHook(function(self, amount)
            if InfiniteStamina.enabled then
                return -- Don't spend stamina
            end
            return InfiniteStamina.originalSpend(self, amount)
        end)
    end

    -- Set initial max stamina
    InfiniteStamina.setMaxStamina()
end

---Set stamina to max
function InfiniteStamina.setMaxStamina()
    if not InfiniteStamina.clientState then
        InfiniteStamina.clientState = Utilities.getWeaponClientModule(Constants.CLIENT_STATE_NAME)
    end

    if InfiniteStamina.clientState then
        InfiniteStamina.clientState.Stamina = Constants.MAX_STAMINA
    end
end

---Get current stamina
---@return number
function InfiniteStamina.getStamina()
    if InfiniteStamina.clientState then
        return InfiniteStamina.clientState.Stamina or 0
    end
    return 0
end

---Toggle infinite stamina
function InfiniteStamina.toggle()
    if InfiniteStamina.enabled then
        InfiniteStamina.disable()
    else
        InfiniteStamina.enable()
    end
end

---Cleanup
function InfiniteStamina.cleanup()
    InfiniteStamina.disable()
end

return InfiniteStamina