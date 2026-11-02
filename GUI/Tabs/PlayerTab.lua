-- Player Tab.
---@module GUI.Tabs.PlayerTab
local PlayerTab = {}

local Library = require("GUI/Library")
local State = require("Core/State")
local Teleport = require("Features/Player/Teleport")
local AutoFarm = require("Features/Player/AutoFarm")

PlayerTab.tab = nil

---Initialize Player Tab
---@param window table
function PlayerTab.initialize(window)
    PlayerTab.tab = Library.createTab(window, "Player")

    -- Teleport Section
    local teleportSection = Library.createSection(PlayerTab.tab, "Teleport")

    Library.createToggle(teleportSection, "Safe Teleport (Tween)", false, function(value)
        State.safeTeleport = value
        Teleport.setSafeTeleport(value)
    end)

    Library.createButton(teleportSection, "Teleport to Random Player", function()
        local players = game:GetService("Players"):GetPlayers()
        local localPlayer = game:GetService("Players").LocalPlayer
        local validPlayers = {}

        for _, player in ipairs(players) do
            if player ~= localPlayer and player.Character then
                table.insert(validPlayers, player)
            end
        end

        if #validPlayers > 0 then
            Teleport.toPlayer(validPlayers[math.random(1, #validPlayers)])
        end
    end)

    Library.createButton(teleportSection, "Save Current Position", function()
        Teleport.saveWaypoint("Waypoint_" .. os.time())
    end)

    Library.createButton(teleportSection, "Load Last Waypoint", function()
        local waypoints = Teleport.getWaypoints()
        local lastKey = nil
        for k, _ in pairs(waypoints) do
            lastKey = k
        end
        if lastKey then
            Teleport.loadWaypoint(lastKey)
        end
    end)

    -- Auto Farm Section
    local farmSection = Library.createSection(PlayerTab.tab, "Auto Farm")

    Library.createToggle(farmSection, "Enabled", State.autoFarmEnabled, function(value)
        State.autoFarmEnabled = value
        if value then AutoFarm.enable() else AutoFarm.disable() end
    end)

    Library.createToggle(farmSection, "Farm Cash", false, function(value)
        State.farmCash = value
        AutoFarm.setFarmCash(value)
    end)

    Library.createToggle(farmSection, "Farm XP", false, function(value)
        State.farmXP = value
        AutoFarm.setFarmXP(value)
    end)

    Library.createToggle(farmSection, "Farm Kills", false, function(value)
        State.farmKills = value
        AutoFarm.setFarmKills(value)
    end)

    Library.createToggle(farmSection, "Farm Items", false, function(value)
        State.farmItems = value
        AutoFarm.setFarmItems(value)
    end)

    Library.createToggle(farmSection, "Team Check", State.teamCheck, function(value)
        State.teamCheck = value
        AutoFarm.setTeamCheck(value)
    end)

    Library.createButton(farmSection, "Give Weapon (AK47)", function()
        AutoFarm.giveWeapon("AK47")
    end)

    -- God Mode Section
    local godModeSection = Library.createSection(PlayerTab.tab, "God Mode")

    Library.createToggle(godModeSection, "Infinite Health", false, function(value) end)
    Library.createToggle(godModeSection, "Infinite Ammo", false, function(value) end)
    Library.createToggle(godModeSection, "No Fall Damage", false, function(value) end)
    Library.createToggle(godModeSection, "Anti Ragdoll", false, function(value) end)

    return PlayerTab.tab
end

return PlayerTab