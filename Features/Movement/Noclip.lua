-- Noclip.
---@module Features.Movement.Noclip
local Noclip = {}

local Constants = ModuleLoader.load("Core/Constants")
local State = ModuleLoader.load("Core/State")
local Services = ModuleLoader.load("Core/Services")
local Logger = ModuleLoader.load("Utility/Logger")

Noclip.enabled = false
Noclip.noclipConnection = nil
Noclip.originalCollisions = {}

---Initialize Noclip
function Noclip.initialize()
    Logger.info("Initializing Noclip...")
    Noclip.enabled = State.noclipEnabled
end

---Enable Noclip
function Noclip.enable()
    if Noclip.enabled then return end

    local character = Services.playersService.LocalPlayer.Character
    if not character then return end

    Noclip.enabled = true
    State.noclipEnabled = true

    -- Disable collisions on all parts
    Noclip.disableCollisions(character)

    -- Handle new parts added
    Noclip.noclipConnection = Services.runService.Stepped:Connect(function()
        if not Noclip.enabled then return end
        local char = Services.playersService.LocalPlayer.Character
        if char then
            Noclip.disableCollisions(char)
        end
    end)

    -- Handle character respawn
    Services.playersService.LocalPlayer.CharacterAdded:Connect(function(newChar)
        if Noclip.enabled then
            task.wait(1)
            Noclip.disableCollisions(newChar)
        end
    end)

    Logger.info("Noclip enabled")
end

---Disable Noclip
function Noclip.disable()
    if not Noclip.enabled then return end

    Noclip.enabled = false
    State.noclipEnabled = false

    -- Restore collisions
    Noclip.restoreCollisions()

    if Noclip.noclipConnection then
        Noclip.noclipConnection:Disconnect()
        Noclip.noclipConnection = nil
    end

    Logger.info("Noclip disabled")
end

---Disable collisions on character parts
---@param character Model
function Noclip.disableCollisions(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            if not Noclip.originalCollisions[part] then
                Noclip.originalCollisions[part] = true
            end
            part.CanCollide = false
        end
    end
end

---Restore original collisions
function Noclip.restoreCollisions()
    for part, _ in pairs(Noclip.originalCollisions) do
        if part and part.Parent then
            part.CanCollide = true
        end
    end
    Noclip.originalCollisions = {}
end

---Toggle noclip
function Noclip.toggle()
    if Noclip.enabled then
        Noclip.disable()
    else
        Noclip.enable()
    end
end

---Cleanup
function Noclip.cleanup()
    Noclip.disable()
end

return Noclip