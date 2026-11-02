-- Tracers.
---@module Features.Visuals.Tracers
local Tracers = {}

local Constants = ModuleLoader.load("Core/Constants")
local State = ModuleLoader.load("Core/State")
local Services = ModuleLoader.load("Core/Services")
local Utilities = ModuleLoader.load("Core/Utilities")
local Logger = ModuleLoader.load("Utility/Logger")

Tracers.enabled = false
Tracers.tracerObjects = {}
Tracers.renderConnection = nil
Tracers.playerAddedConnection = nil
Tracers.playerRemovingConnection = nil

---Initialize Tracers
function Tracers.initialize()
    Logger.info("Initializing Tracers...")
    Tracers.enabled = State.tracersEnabled
end

---Enable Tracers
function Tracers.enable()
    if Tracers.enabled then return end

    Tracers.enabled = true
    State.tracersEnabled = true

    -- Create tracers for existing players
    for _, player in ipairs(Services.playersService:GetPlayers()) do
        if player ~= Services.playersService.LocalPlayer then
            Tracers.createTracer(player)
        end
    end

    -- Handle new players
    Tracers.playerAddedConnection = Services.playersService.PlayerAdded:Connect(function(player)
        if Tracers.enabled then
            Tracers.createTracer(player)
        end
    end)

    -- Handle player leaving
    Tracers.playerRemovingConnection = Services.playersService.PlayerRemoving:Connect(function(player)
        Tracers.removeTracer(player)
    end)

    -- Render loop
    Tracers.renderConnection = Services.runService.RenderStepped:Connect(function()
        Tracers.update()
    end)

    Logger.info("Tracers enabled")
end

---Disable Tracers
function Tracers.disable()
    if not Tracers.enabled then return end

    Tracers.enabled = false
    State.tracersEnabled = false

    -- Remove all tracers
    for player, _ in pairs(Tracers.tracerObjects) do
        Tracers.removeTracer(player)
    end

    if Tracers.renderConnection then
        Tracers.renderConnection:Disconnect()
        Tracers.renderConnection = nil
    end

    if Tracers.playerAddedConnection then
        Tracers.playerAddedConnection:Disconnect()
        Tracers.playerAddedConnection = nil
    end

    if Tracers.playerRemovingConnection then
        Tracers.playerRemovingConnection:Disconnect()
        Tracers.playerRemovingConnection = nil
    end

    Logger.info("Tracers disabled")
end

---Create tracer for a player
---@param player Player
function Tracers.createTracer(player)
    if player == Services.playersService.LocalPlayer then return end
    if Tracers.tracerObjects[player] then return end

    local tracer = Utilities.createDrawing("Line", {
        Visible = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2,
        Transparency = 1,
        ZIndex = 40
    })

    Tracers.tracerObjects[player] = tracer
end

---Remove tracer for a player
---@param player Player
function Tracers.removeTracer(player)
    local tracer = Tracers.tracerObjects[player]
    if tracer and tracer.__OBJECT_EXISTS then
        tracer:Destroy()
    end
    Tracers.tracerObjects[player] = nil
end

---Update all tracers
function Tracers.update()
    if not Tracers.enabled then return end

    local localPlayer = Services.playersService.LocalPlayer
    local camera = Services.camera
    local mousePos = Services.userInputService:GetMouseLocation()
    local viewportSize = camera.ViewportSize

    -- Tracer origin (bottom center, mouse, or custom)
    local origin = Vector2.new(viewportSize.X / 2, viewportSize.Y)
    if State.tracerOrigin == "Mouse" then
        origin = mousePos
    elseif State.tracerOrigin == "Center" then
        origin = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
    end

    for player, tracer in pairs(Tracers.tracerObjects) do
        if not player or not player.Parent then
            Tracers.removeTracer(player)
            continue
        end

        if player == localPlayer then
            tracer.Visible = false
            continue
        end

        local character = player.Character
        if not character then
            tracer.Visible = false
            continue
        end

        local humanoid = character:FindFirstChild("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")

        if not humanoid or not hrp or humanoid.Health <= 0 then
            tracer.Visible = false
            continue
        end

        -- Team check
        if State.teamCheck and player.Team == localPlayer.Team then
            tracer.Visible = false
            continue
        end

        -- Distance check
        local localChar = localPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") and State.distanceCheck then
            local dist = (hrp.Position - localChar.HumanoidRootPart.Position).Magnitude
            if dist > (State.maxDistance or 1000) then
                tracer.Visible = false
                continue
            end
        end

        -- Get screen position
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

        if not onScreen then
            tracer.Visible = false
            continue
        end

        -- Team color
        local teamColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)

        tracer.From = origin
        tracer.To = Vector2.new(screenPos.X, screenPos.Y)
        tracer.Color = teamColor
        tracer.Visible = true
    end
end

---Set tracer origin
---@param origin string "Bottom" | "Mouse" | "Center"
function Tracers.setOrigin(origin)
    State.tracerOrigin = origin
end

---Toggle tracers
function Tracers.toggle()
    if Tracers.enabled then
        Tracers.disable()
    else
        Tracers.enable()
    end
end

---Cleanup
function Tracers.cleanup()
    Tracers.disable()
end

return Tracers