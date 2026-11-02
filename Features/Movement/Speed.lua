-- Speed.
---@module Features.Movement.Speed
local Speed = {}

local Constants = ModuleLoader.load("Core/Constants")
local State = ModuleLoader.load("Core/State")
local Services = ModuleLoader.load("Core/Services")
local Utilities = ModuleLoader.load("Core/Utilities")
local HookProtection = ModuleLoader.load("AntiCheat/HookProtection")
local Logger = ModuleLoader.load("Utility/Logger")

Speed.enabled = false
Speed.originalWalkSpeed = nil
Speed.speedConnection = nil
Speed.humanoidConnection = nil

---Initialize Speed
function Speed.initialize()
    Logger.info("Initializing Speed...")
    Speed.enabled = State.speedEnabled
end

---Enable Speed
function Speed.enable()
    if Speed.enabled then return end

    local character = Services.playersService.LocalPlayer.Character
    if not character then return end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end

    Speed.enabled = true
    State.speedEnabled = true

    Speed.originalWalkSpeed = humanoid.WalkSpeed

    -- Hook WalkSpeed __index/__newindex
    Speed.hookHumanoid(humanoid)

    -- Handle character respawn
    Speed.humanoidConnection = Services.playersService.LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        if Speed.enabled then
            local newHumanoid = newChar:FindFirstChild("Humanoid")
            if newHumanoid then
                Speed.hookHumanoid(newHumanoid)
            end
        end
    end)

    Logger.info("Speed enabled")
end

---Disable Speed
function Speed.disable()
    if not Speed.enabled then return end

    Speed.enabled = false
    State.speedEnabled = false

    local character = Services.playersService.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and Speed.originalWalkSpeed then
            humanoid.WalkSpeed = Speed.originalWalkSpeed
        end
    end

    if Speed.humanoidConnection then
        Speed.humanoidConnection:Disconnect()
        Speed.humanoidConnection = nil
    end

    Speed.originalWalkSpeed = nil

    Logger.info("Speed disabled")
end

---Hook Humanoid WalkSpeed
---@param humanoid Humanoid
function Speed.hookHumanoid(humanoid)
    local meta = getrawmetatable(humanoid)
    if not meta then return end

    local oldIndex = meta.__index
    local oldNewindex = meta.__newindex

    meta.__index = HookProtection.wrapHook(function(self, key)
        if key == "WalkSpeed" and Speed.enabled then
            return State.walkSpeed or Constants.DEFAULT_WALK_SPEED
        end
        return oldIndex(self, key)
    end)

    meta.__newindex = HookProtection.wrapHook(function(self, key, value)
        if key == "WalkSpeed" and Speed.enabled then
            value = State.walkSpeed or Constants.DEFAULT_WALK_SPEED
        end
        return oldNewindex(self, key, value)
    end)

    -- Apply immediately
    humanoid.WalkSpeed = State.walkSpeed or Constants.DEFAULT_WALK_SPEED
end

---Set walk speed
---@param speed number
function Speed.setSpeed(speed)
    State.walkSpeed = math.clamp(speed, 1, 200)

    if Speed.enabled then
        local character = Services.playersService.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = State.walkSpeed
            end
        end
    end
end

---Get walk speed
---@return number
function Speed.getSpeed()
    return State.walkSpeed or Constants.DEFAULT_WALK_SPEED
end

---Toggle speed
function Speed.toggle()
    if Speed.enabled then
        Speed.disable()
    else
        Speed.enable()
    end
end

---Cleanup
function Speed.cleanup()
    Speed.disable()
end

return Speed