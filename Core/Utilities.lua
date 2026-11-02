-- Utilities.
---@module Core.Utilities
local Utilities = {}

local Constants = require("Core/Constants")

-- Solara protection wrapper
---Wraps a function with Solara's protection to hide it from detection
---@param func function
---@param hideFromStack boolean?
---@return function
function Utilities.protectFunction(func, hideFromStack)
    if Constants.SOLARA_PROTECT_HOOKS and solara and solara.protect_function then
        return solara.protect_function(func, hideFromStack or false)
    end
    return func
end

---Wraps a GUI object with Solara's protection
---@param guiObject Instance
---@return Instance
function Utilities.protectGui(guiObject)
    if Constants.SOLARA_PROTECT_GUI and solara and solara.protect_gui then
        return solara.protect_gui(guiObject)
    end
    return guiObject
end

---Safe require with thread identity protection
---@param moduleScript ModuleScript
---@return any
function Utilities.safeRequire(moduleScript)
    local success, result = pcall(function()
        if setthreadidentity then
            setthreadidentity(2)
        end
        return require(moduleScript)
    end)
    if setthreadidentity then
        setthreadidentity(8)
    end
    if not success then
        warn("Failed to require module: " .. tostring(result))
        return nil
    end
    return result
end

---Get closest player to cursor within FOV
---@param fovRadius number
---@param teamCheck boolean
---@param visibleCheck boolean
---@return Player?, number?, Vector3?
function Utilities.getClosestPlayer(fovRadius, teamCheck, visibleCheck)
    local Services = require("Core/Services")
    local State = require("Core/State")

    local localPlayer = Services.playersService.LocalPlayer
    if not localPlayer then return nil, nil, nil end

    local camera = Services.camera
    local mousePos = Services.userInputService:GetMouseLocation()
    local closestPlayer = nil
    local closestDist = math.huge
    local closestScreenPos = nil

    for _, player in ipairs(Services.playersService:GetPlayers()) do
        if player == localPlayer then continue end
        if teamCheck and player.Team == localPlayer.Team then continue end

        local character = player.Character
        if not character then continue end

        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        local targetPart = character:FindFirstChild(State.silentAimTargetPart or "Head")
        if not targetPart then
            targetPart = character:FindFirstChild("HumanoidRootPart")
        end
        if not targetPart then continue end

        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end

        if visibleCheck then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {localPlayer.Character, character}
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            local result = workspace:Raycast(camera.CFrame.Position, (targetPart.Position - camera.CFrame.Position).Unit * 1000, raycastParams)
            if result and result.Instance and not result.Instance:IsDescendantOf(character) then
                continue
            end
        end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist <= fovRadius and dist < closestDist then
            closestDist = dist
            closestPlayer = player
            closestScreenPos = Vector2.new(screenPos.X, screenPos.Y)
        end
    end

    return closestPlayer, closestDist, closestScreenPos
end

---Create a Drawing object with Solara protection
---@param drawingType string
---@param properties table
---@return DrawingObject
function Utilities.createDrawing(drawingType, properties)
    local drawing = Drawing.new(drawingType)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    return Utilities.protectGui(drawing)
end

---Safe hook using hookmetamethod with Solara protection
---@param object table | Instance
---@param metamethod string
---@param hook function
---@return function
function Utilities.safeHookMetamethod(object, metamethod, hook)
    local protectedHook = Utilities.protectFunction(hook, true)
    return hookmetamethod(object, metamethod, protectedHook)
end

---Safe hook using hookfunction with Solara protection
---@param func function
---@param hook function
---@return function
function Utilities.safeHookFunction(func, hook)
    local protectedHook = Utilities.protectFunction(hook, true)
    return hookfunction(func, protectedHook)
end

---Get module from WeaponClient upvalues
---@param moduleName string
---@return any
function Utilities.getWeaponClientModule(moduleName)
    local WeaponClient = game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("WeaponClient")
    if not WeaponClient then return nil end

    local gc = getgc(true)
    for _, obj in ipairs(gc) do
        if typeof(obj) == "function" then
            local info = debug.getinfo(obj, "S")
            if info and info.source and info.source:find("WeaponClient") then
                local upvalues = debug.getupvalues(obj)
                for _, upval in ipairs(upvalues) do
                    if typeof(upval) == "table" and upval[moduleName] then
                        return upval[moduleName]
                    elseif typeof(upval) == "table" then
                        for k, v in pairs(upval) do
                            if k == moduleName then
                                return v
                            end
                        end
                    end
                end
            end
        elseif typeof(obj) == "table" then
            if obj[moduleName] then
                return obj[moduleName]
            end
        end
    end
    return nil
end

---Wrap in pcall with error logging
---@param func function
---@param ... any
---@return boolean, any
function Utilities.safeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("SafeCall error: " .. tostring(result))
        warn(debug.traceback())
    end
    return success, result
end

---Deep copy a table
---@param original table
---@return table
function Utilities.deepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if typeof(v) == "table" then
            copy[k] = Utilities.deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

---Format number with commas
---@param num number
---@return string
function Utilities.formatNumber(num)
    local formatted = tostring(math.floor(num))
    local k = 1
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    return formatted
end

---Get distance between two positions
---@param pos1 Vector3
---@param pos2 Vector3
---@return number
function Utilities.getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

---Check if a player is alive
---@param player Player
---@return boolean
function Utilities.isPlayerAlive(player)
    local character = player.Character
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

return Utilities