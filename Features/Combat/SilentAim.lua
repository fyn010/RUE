-- Silent Aim.
---@module Features.Combat.SilentAim
local SilentAim = {}

local Constants = require("Core/Constants")
local State = require("Core/State")
local Services = require("Core/Services")
local Utilities = require("Core/Utilities")
local HookProtection = require("AntiCheat/HookProtection")
local Logger = require("Utility/Logger")

SilentAim.enabled = false
SilentAim.hookConnection = nil
SilentAim.originalNamecall = nil
SilentAim.fovCircle = nil

---Initialize Silent Aim
function SilentAim.initialize()
    Logger.info("Initializing Silent Aim...")
    SilentAim.createFovCircle()
    SilentAim.enabled = State.silentAimEnabled
end

---Create FOV circle drawing
function SilentAim.createFovCircle()
    SilentAim.fovCircle = Utilities.createDrawing("Circle", {
        Visible = false,
        Radius = State.fovRadius,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2,
        Transparency = 0.5,
        Filled = false,
        ZIndex = 100
    })
end

---Update FOV circle position
function SilentAim.updateFovCircle()
    if not SilentAim.fovCircle then return end
    local mousePos = Services.userInputService:GetMouseLocation()
    SilentAim.fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    SilentAim.fovCircle.Radius = State.fovRadius
    SilentAim.fovCircle.Visible = SilentAim.enabled and State.espEnabled
end

---Enable Silent Aim
function SilentAim.enable()
    if SilentAim.enabled then return end

    SilentAim.enabled = true
    State.silentAimEnabled = true

    -- Hook __namecall on Remotes.Fire
    local fireRemote = Services.replicatedStorage:FindFirstChild(Constants.REMOTES_FOLDER)
        and Services.replicatedStorage[Constants.REMOTES_FOLDER]:FindFirstChild(Constants.FIRE_REMOTE)

    if fireRemote then
        SilentAim.hookFireRemote(fireRemote)
    else
        -- Fallback: hook globally and filter
        SilentAim.hookGlobalNamecall()
    end

    Logger.info("Silent Aim enabled")
end

---Disable Silent Aim
function SilentAim.disable()
    if not SilentAim.enabled then return end

    SilentAim.enabled = false
    State.silentAimEnabled = false

    if SilentAim.hookConnection then
        SilentAim.hookConnection:Disconnect()
        SilentAim.hookConnection = nil
    end

    if SilentAim.originalNamecall then
        HookProtection.restoreMetamethod(game, "__namecall")
        SilentAim.originalNamecall = nil
    end

    if SilentAim.fovCircle then
        SilentAim.fovCircle.Visible = false
    end

    Logger.info("Silent Aim disabled")
end

---Hook the Fire RemoteEvent
---@param fireRemote RemoteEvent
function SilentAim.hookFireRemote(fireRemote)
    local oldFireServer
    oldFireServer = HookProtection.hookMetamethod(fireRemote, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "FireServer" and SilentAim.enabled and not checkcaller() then
            -- Args: origin, direction, shotId, hitChar, hitBone, hitPos, vehiclePart, glassParts, collateralHits, isRocket, shotCounter, cameraOrigin, cameraDirection, hitPosition
            local targetPlayer, targetDist, targetScreenPos = Utilities.getClosestPlayer(
                State.fovRadius,
                State.teamCheck,
                State.visibleCheck
            )

            if targetPlayer and targetPlayer.Character then
                local targetPart = targetPlayer.Character:FindFirstChild(State.silentAimTargetPart)
                if not targetPart then
                    targetPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                end

                if targetPart then
                    local camera = Services.camera
                    local origin = args[1] or camera.CFrame.Position
                    local direction = (targetPart.Position - origin).Unit

                    -- Modify direction (arg 2)
                    args[2] = direction

                    -- Update hit position (arg 14)
                    args[14] = targetPart.Position

                    -- Update hit character (arg 4)
                    args[4] = targetPlayer.Character

                    -- Update hit bone (arg 5)
                    args[5] = State.silentAimTargetPart

                    return oldFireServer(self, unpack(args))
                end
            end
        end

        return oldFireServer(self, ...)
    end)

    SilentAim.originalNamecall = oldFireServer
end

---Global namecall hook fallback
function SilentAim.hookGlobalNamecall()
    local oldNamecall
    oldNamecall = HookProtection.hookMetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if method == "FireServer" and SilentAim.enabled and not checkcaller() then
            if self.Name == Constants.FIRE_REMOTE or self.Name == "Fire" then
                local targetPlayer, targetDist, targetScreenPos = Utilities.getClosestPlayer(
                    State.fovRadius,
                    State.teamCheck,
                    State.visibleCheck
                )

                if targetPlayer and targetPlayer.Character then
                    local targetPart = targetPlayer.Character:FindFirstChild(State.silentAimTargetPart)
                    if not targetPart then
                        targetPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    end

                    if targetPart then
                        local camera = Services.camera
                        local origin = args[1] or camera.CFrame.Position
                        local direction = (targetPart.Position - origin).Unit

                        args[2] = direction
                        args[14] = targetPart.Position
                        args[4] = targetPlayer.Character
                        args[5] = State.silentAimTargetPart

                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end

        return oldNamecall(self, ...)
    end)

    SilentAim.originalNamecall = oldNamecall
end

---Set target part
---@param partName string
function SilentAim.setTargetPart(partName)
    State.silentAimTargetPart = partName
end

---Set FOV radius
---@param radius number
function SilentAim.setFovRadius(radius)
    State.fovRadius = math.clamp(radius, 0, Constants.MAX_FOV_RADIUS)
    if SilentAim.fovCircle then
        SilentAim.fovCircle.Radius = State.fovRadius
    end
end

---Toggle team check
---@param enabled boolean
function SilentAim.setTeamCheck(enabled)
    State.teamCheck = enabled
end

---Toggle visible check
---@param enabled boolean
function SilentAim.setVisibleCheck(enabled)
    State.visibleCheck = enabled
end

---Get current target
---@return Player?
function SilentAim.getCurrentTarget()
    local targetPlayer = Utilities.getClosestPlayer(State.fovRadius, State.teamCheck, State.visibleCheck)
    State.currentTarget = targetPlayer
    return targetPlayer
end

---Cleanup
function SilentAim.cleanup()
    SilentAim.disable()
    if SilentAim.fovCircle then
        SilentAim.fovCircle:Destroy()
        SilentAim.fovCircle = nil
    end
end

return SilentAim