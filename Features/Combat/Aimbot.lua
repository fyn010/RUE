-- Aimbot.
---@module Features.Combat.Aimbot
local Aimbot = {}

local Constants = ModuleLoader.load("Core/Constants")
local State = ModuleLoader.load("Core/State")
local Services = ModuleLoader.load("Core/Services")
local Utilities = ModuleLoader.load("Core/Utilities")
local Logger = ModuleLoader.load("Utility/Logger")

Aimbot.enabled = false
Aimbot.runConnection = nil
Aimbot.currentTarget = nil

---Initialize Aimbot
function Aimbot.initialize()
    Logger.info("Initializing Aimbot...")
    Aimbot.enabled = State.aimbotEnabled
end

---Enable Aimbot
function Aimbot.enable()
    if Aimbot.enabled then return end

    Aimbot.enabled = true
    State.aimbotEnabled = true

    Aimbot.runConnection = Services.runService.RenderStepped:Connect(function()
        if not Aimbot.enabled then return end
        Aimbot.update()
    end)

    Logger.info("Aimbot enabled")
end

---Disable Aimbot
function Aimbot.disable()
    if not Aimbot.enabled then return end

    Aimbot.enabled = false
    State.aimbotEnabled = false

    if Aimbot.runConnection then
        Aimbot.runConnection:Disconnect()
        Aimbot.runConnection = nil
    end

    Aimbot.currentTarget = nil
    State.currentTarget = nil

    Logger.info("Aimbot disabled")
end

---Update aimbot
function Aimbot.update()
    local targetPlayer, targetDist, targetScreenPos = Utilities.getClosestPlayer(
        State.fovRadius,
        State.teamCheck,
        State.visibleCheck
    )

    if not targetPlayer or not targetPlayer.Character then
        Aimbot.currentTarget = nil
        State.currentTarget = nil
        return
    end

    local targetPart = targetPlayer.Character:FindFirstChild(State.silentAimTargetPart)
    if not targetPart then
        targetPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    end

    if not targetPart then
        Aimbot.currentTarget = nil
        State.currentTarget = nil
        return
    end

    Aimbot.currentTarget = targetPlayer
    State.currentTarget = targetPlayer

    local camera = Services.camera
    local currentCFrame = camera.CFrame
    local targetPosition = targetPart.Position
    local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)

    -- Apply smoothing
    local smoothness = State.aimbotSmoothness or 0.1
    local newCFrame = currentCFrame:Lerp(targetCFrame, smoothness)

    camera.CFrame = newCFrame
end

---Set target part
---@param partName string
function Aimbot.setTargetPart(partName)
    State.silentAimTargetPart = partName
end

---Set FOV radius
---@param radius number
function Aimbot.setFovRadius(radius)
    State.fovRadius = math.clamp(radius, 0, Constants.MAX_FOV_RADIUS)
end

---Set smoothness
---@param smoothness number
function Aimbot.setSmoothness(smoothness)
    State.aimbotSmoothness = math.clamp(smoothness, 0, 1)
end

---Toggle team check
---@param enabled boolean
function Aimbot.setTeamCheck(enabled)
    State.teamCheck = enabled
end

---Toggle visible check
---@param enabled boolean
function Aimbot.setVisibleCheck(enabled)
    State.visibleCheck = enabled
end

---Get current target
---@return Player?
function Aimbot.getCurrentTarget()
    return Aimbot.currentTarget
end

---Cleanup
function Aimbot.cleanup()
    Aimbot.disable()
end

return Aimbot