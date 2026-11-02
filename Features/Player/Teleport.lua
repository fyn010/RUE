-- Teleport.
---@module Features.Player.Teleport
local Teleport = {}

local Constants = require("Core/Constants")
local State = require("Core/State")
local Services = require("Core/Services")
local Utilities = require("Core/Utilities")
local Logger = require("Utility/Logger")

Teleport.enabled = false
Teleport.savedPositions = {}
Teleport.waypoints = {}

---Initialize Teleport
function Teleport.initialize()
    Logger.info("Initializing Teleport...")
    Teleport.enabled = State.teleportEnabled
end

---Teleport to a player
---@param targetPlayer Player
function Teleport.toPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end

    local localPlayer = Services.playersService.LocalPlayer
    local localChar = localPlayer.Character
    if not localChar then return end

    local hrp = localChar:FindFirstChild("HumanoidRootPart")
    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHrp then return end

    if State.safeTeleport then
        Teleport.safeTeleport(hrp, targetHrp.CFrame + Vector3.new(0, 3, 0))
    else
        hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
    end

    Logger.info("Teleported to %s", targetPlayer.Name)
end

---Teleport to coordinates
---@param position Vector3
function Teleport.toPosition(position)
    local localPlayer = Services.playersService.LocalPlayer
    local localChar = localPlayer.Character
    if not localChar then return end

    local hrp = localChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if State.safeTeleport then
        Teleport.safeTeleport(hrp, CFrame.new(position))
    else
        hrp.CFrame = CFrame.new(position)
    end

    Logger.info("Teleported to position: %s", tostring(position))
end

---Safe teleport with tween
---@param hrp BasePart
---@param targetCFrame CFrame
function Teleport.safeTeleport(hrp, targetCFrame)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = Services.tweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
end

---Teleport to vehicle
---@param vehicle Model
function Teleport.toVehicle(vehicle)
    if not vehicle then return end

    local localPlayer = Services.playersService.LocalPlayer
    local localChar = localPlayer.Character
    if not localChar then return end

    local hrp = localChar:FindFirstChild("HumanoidRootPart")
    local seat = vehicle:FindFirstChild("VehicleSeat") or vehicle:FindFirstChild("Seat")

    if seat and hrp then
        seat:Sit(hrp.Parent:FindFirstChild("Humanoid"))
    end
end

---Save current position as waypoint
---@param name string
function Teleport.saveWaypoint(name)
    local localPlayer = Services.playersService.LocalPlayer
    local localChar = localPlayer.Character
    if not localChar then return end

    local hrp = localChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    Teleport.waypoints[name] = hrp.CFrame
    Logger.info("Saved waypoint: %s", name)
end

---Load waypoint
---@param name string
function Teleport.loadWaypoint(name)
    local cframe = Teleport.waypoints[name]
    if cframe then
        Teleport.toPosition(cframe.Position)
    end
end

---Delete waypoint
---@param name string
function Teleport.deleteWaypoint(name)
    Teleport.waypoints[name] = nil
    Logger.info("Deleted waypoint: %s", name)
end

---Get all waypoints
---@return table
function Teleport.getWaypoints()
    return Teleport.waypoints
end

---Teleport behind player
---@param targetPlayer Player
---@param distance number?
function Teleport.behindPlayer(targetPlayer, distance)
    distance = distance or 5

    if not targetPlayer or not targetPlayer.Character then return end

    local localPlayer = Services.playersService.LocalPlayer
    local localChar = localPlayer.Character
    if not localChar then return end

    local hrp = localChar:FindFirstChild("HumanoidRootPart")
    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHrp then return end

    local behindCFrame = targetHrp.CFrame * CFrame.new(0, 0, distance)

    if State.safeTeleport then
        Teleport.safeTeleport(hrp, behindCFrame)
    else
        hrp.CFrame = behindCFrame
    end
end

---Toggle safe teleport
---@param enabled boolean
function Teleport.setSafeTeleport(enabled)
    State.safeTeleport = enabled
end

---Cleanup
function Teleport.cleanup()
    Teleport.enabled = false
    State.teleportEnabled = false
end

return Teleport