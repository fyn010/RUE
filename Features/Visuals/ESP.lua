-- ESP.
---@module Features.Visuals.ESP
local ESP = {}

local Constants = require("Core/Constants")
local State = require("Core/State")
local Services = require("Core/Services")
local Utilities = require("Core/Utilities")
local Logger = require("Utility/Logger")

ESP.enabled = false
ESP.espObjects = {}
ESP.renderConnection = nil
ESP.playerAddedConnection = nil
ESP.playerRemovingConnection = nil

---Initialize ESP
function ESP.initialize()
    Logger.info("Initializing ESP...")
    ESP.enabled = State.espEnabled
end

---Enable ESP
function ESP.enable()
    if ESP.enabled then return end

    ESP.enabled = true
    State.espEnabled = true

    -- Create ESP for existing players
    for _, player in ipairs(Services.playersService:GetPlayers()) do
        if player ~= Services.playersService.LocalPlayer then
            ESP.createESP(player)
        end
    end

    -- Handle new players
    ESP.playerAddedConnection = Services.playersService.PlayerAdded:Connect(function(player)
        if ESP.enabled then
            ESP.createESP(player)
        end
    end)

    -- Handle player leaving
    ESP.playerRemovingConnection = Services.playersService.PlayerRemoving:Connect(function(player)
        ESP.removeESP(player)
    end)

    -- Render loop
    ESP.renderConnection = Services.runService.RenderStepped:Connect(function()
        ESP.update()
    end)

    Logger.info("ESP enabled")
end

---Disable ESP
function ESP.disable()
    if not ESP.enabled then return end

    ESP.enabled = false
    State.espEnabled = false

    -- Remove all ESP objects
    for player, _ in pairs(ESP.espObjects) do
        ESP.removeESP(player)
    end

    if ESP.renderConnection then
        ESP.renderConnection:Disconnect()
        ESP.renderConnection = nil
    end

    if ESP.playerAddedConnection then
        ESP.playerAddedConnection:Disconnect()
        ESP.playerAddedConnection = nil
    end

    if ESP.playerRemovingConnection then
        ESP.playerRemovingConnection:Disconnect()
        ESP.playerRemovingConnection = nil
    end

    Logger.info("ESP disabled")
end

---Create ESP for a player
---@param player Player
function ESP.createESP(player)
    if player == Services.playersService.LocalPlayer then return end
    if ESP.espObjects[player] then return end

    local objects = {}

    -- Box
    objects.box = Utilities.createDrawing("Square", {
        Visible = false,
        Color = Color3.fromRGB(255, 255, 255),
        Thickness = 2,
        Transparency = 1,
        Filled = false,
        ZIndex = 50
    })

    -- Box Outline
    objects.boxOutline = Utilities.createDrawing("Square", {
        Visible = false,
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 4,
        Transparency = 0.5,
        Filled = false,
        ZIndex = 49
    })

    -- Name Text
    objects.name = Utilities.createDrawing("Text", {
        Visible = false,
        Color = Color3.fromRGB(255, 255, 255),
        Size = 16,
        Center = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Font = Drawing.Fonts.Plex,
        ZIndex = 51
    })

    -- Health Text
    objects.health = Utilities.createDrawing("Text", {
        Visible = false,
        Color = Color3.fromRGB(0, 255, 0),
        Size = 14,
        Center = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Font = Drawing.Fonts.Plex,
        ZIndex = 51
    })

    -- Distance Text
    objects.distance = Utilities.createDrawing("Text", {
        Visible = false,
        Color = Color3.fromRGB(200, 200, 200),
        Size = 14,
        Center = true,
        Outline = true,
        OutlineColor = Color3.fromRGB(0, 0, 0),
        Font = Drawing.Fonts.Plex,
        ZIndex = 51
    })

    -- Health Bar Background
    objects.healthBarBg = Utilities.createDrawing("Square", {
        Visible = false,
        Color = Color3.fromRGB(0, 0, 0),
        Thickness = 1,
        Transparency = 0.5,
        Filled = true,
        ZIndex = 48
    })

    -- Health Bar
    objects.healthBar = Utilities.createDrawing("Square", {
        Visible = false,
        Color = Color3.fromRGB(0, 255, 0),
        Thickness = 1,
        Transparency = 1,
        Filled = true,
        ZIndex = 49
    })

    ESP.espObjects[player] = objects
end

---Remove ESP for a player
---@param player Player
function ESP.removeESP(player)
    local objects = ESP.espObjects[player]
    if not objects then return end

    for _, drawing in pairs(objects) do
        if drawing and drawing.__OBJECT_EXISTS then
            drawing:Destroy()
        end
    end

    ESP.espObjects[player] = nil
end

---Update all ESP
function ESP.update()
    if not ESP.enabled then return end

    local localPlayer = Services.playersService.LocalPlayer
    local camera = Services.camera

    for player, objects in pairs(ESP.espObjects) do
        if not player or not player.Parent then
            ESP.removeESP(player)
            continue
        end

        if player == localPlayer then
            ESP.setVisible(objects, false)
            continue
        end

        local character = player.Character
        if not character then
            ESP.setVisible(objects, false)
            continue
        end

        local humanoid = character:FindFirstChild("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")

        if not humanoid or not hrp or humanoid.Health <= 0 then
            ESP.setVisible(objects, false)
            continue
        end

        -- Team check
        if State.teamCheck and player.Team == localPlayer.Team then
            ESP.setVisible(objects, false)
            continue
        end

        -- Distance check
        local localChar = localPlayer.Character
        if localChar and localChar:FindFirstChild("HumanoidRootPart") and State.distanceCheck then
            local dist = (hrp.Position - localChar.HumanoidRootPart.Position).Magnitude
            if dist > (State.maxDistance or 1000) then
                ESP.setVisible(objects, false)
                continue
            end
        end

        -- Get screen positions
        local head = character:FindFirstChild("Head")
        local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
        local headScreenPos, headOnScreen = head and camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0)) or nil, false

        if not onScreen then
            ESP.setVisible(objects, false)
            continue
        end

        -- Calculate box size
        local distance = (camera.CFrame.Position - hrp.Position).Magnitude
        local scale = 1 / (distance * 0.02)
        local boxHeight = math.clamp(60 * scale, 20, 200)
        local boxWidth = boxHeight * 0.6

        local boxPosition = Vector2.new(screenPos.X - boxWidth / 2, screenPos.Y - boxHeight / 2)

        -- Team color
        local teamColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)

        -- Update box
        objects.box.Position = boxPosition
        objects.box.Size = Vector2.new(boxWidth, boxHeight)
        objects.box.Color = teamColor
        objects.box.Visible = true

        objects.boxOutline.Position = boxPosition
        objects.boxOutline.Size = Vector2.new(boxWidth, boxHeight)
        objects.boxOutline.Visible = true

        -- Update name
        objects.name.Position = Vector2.new(screenPos.X, boxPosition.Y - 20)
        objects.name.Text = player.Name
        objects.name.Color = teamColor
        objects.name.Visible = true

        -- Update health
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        objects.health.Position = Vector2.new(screenPos.X, boxPosition.Y + boxHeight + 5)
        objects.health.Text = string.format("HP: %d", math.floor(humanoid.Health))
        objects.health.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        objects.health.Visible = true

        -- Update distance
        if localChar and localChar:FindFirstChild("HumanoidRootPart") then
            local dist = math.floor((hrp.Position - localChar.HumanoidRootPart.Position).Magnitude)
            objects.distance.Position = Vector2.new(screenPos.X, boxPosition.Y + boxHeight + 20)
            objects.distance.Text = string.format("%dm", dist)
            objects.distance.Visible = true
        else
            objects.distance.Visible = false
        end

        -- Update health bar
        local barWidth = 3
        local barHeight = boxHeight
        local barX = boxPosition.X - barWidth - 2
        local barY = boxPosition.Y

        objects.healthBarBg.Position = Vector2.new(barX, barY)
        objects.healthBarBg.Size = Vector2.new(barWidth, barHeight)
        objects.healthBarBg.Visible = true

        local healthBarHeight = barHeight * healthPercent
        objects.healthBar.Position = Vector2.new(barX, barY + barHeight - healthBarHeight)
        objects.healthBar.Size = Vector2.new(barWidth, healthBarHeight)
        objects.healthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        objects.healthBar.Visible = true
    end
end

---Set visibility of all ESP objects for a player
---@param objects table
---@param visible boolean
function ESP.setVisible(objects, visible)
    for _, drawing in pairs(objects) do
        if drawing then
            drawing.Visible = visible
        end
    end
end

---Toggle ESP
function ESP.toggle()
    if ESP.enabled then
        ESP.disable()
    else
        ESP.enable()
    end
end

---Cleanup
function ESP.cleanup()
    ESP.disable()
end

return ESP