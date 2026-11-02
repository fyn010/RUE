-- Auto Farm.
---@module Features.Player.AutoFarm
local AutoFarm = {}

local Constants = require("Core/Constants")
local State = require("Core/State")
local Services = require("Core/Services")
local Utilities = require("Core/Utilities")
local Logger = require("Utility/Logger")

AutoFarm.enabled = false
AutoFarm.farmConnection = nil
AutoFarm.cashRemote = nil
AutoFarm.xpRemote = nil
AutoFarm.damageRemote = nil
AutoFarm.giveWeaponRemote = nil

---Initialize Auto Farm
function AutoFarm.initialize()
    Logger.info("Initializing Auto Farm...")
    AutoFarm.enabled = State.autoFarmEnabled
    AutoFarm.cacheRemotes()
end

---Cache remote references
function AutoFarm.cacheRemotes()
    local events = Services.replicatedStorage:FindFirstChild(Constants.EVENTS_FOLDER)
    if events then
        AutoFarm.cashRemote = events:FindFirstChild(Constants.AWARD_CASH_REMOTE)
        AutoFarm.xpRemote = events:FindFirstChild(Constants.AWARD_XP_REMOTE)
        AutoFarm.damageRemote = events:FindFirstChild(Constants.DEAL_DAMAGE_REMOTE)
    end

    local remotes = Services.replicatedStorage:FindFirstChild(Constants.REMOTES_FOLDER)
    if remotes then
        AutoFarm.giveWeaponRemote = remotes:FindFirstChild(Constants.GIVE_WEAPON_REMOTE)
    end
end

---Enable Auto Farm
function AutoFarm.enable()
    if AutoFarm.enabled then return end

    AutoFarm.enabled = true
    State.autoFarmEnabled = true

    AutoFarm.cacheRemotes()

    AutoFarm.farmConnection = Services.runService.Heartbeat:Connect(function()
        if not AutoFarm.enabled then return end
        AutoFarm.runFarm()
    end)

    Logger.info("Auto Farm enabled")
end

---Disable Auto Farm
function AutoFarm.disable()
    if not AutoFarm.enabled then return end

    AutoFarm.enabled = false
    State.autoFarmEnabled = false

    if AutoFarm.farmConnection then
        AutoFarm.farmConnection:Disconnect()
        AutoFarm.farmConnection = nil
    end

    Logger.info("Auto Farm disabled")
end

---Run farm loop
function AutoFarm.runFarm()
    task.wait(Constants.AUTO_FARM_INTERVAL)

    if not AutoFarm.enabled then return end

    -- Cash Farm
    if State.farmCash and AutoFarm.cashRemote then
        AutoFarm.farmCash()
    end

    -- XP Farm
    if State.farmXP and AutoFarm.xpRemote then
        AutoFarm.farmXP()
    end

    -- Kill Farm
    if State.farmKills then
        AutoFarm.farmKills()
    end

    -- Item Farm
    if State.farmItems then
        AutoFarm.farmItems()
    end
end

---Farm cash
function AutoFarm.farmCash()
    if AutoFarm.cashRemote then
        -- Fire AwardCash remote
        pcall(function()
            AutoFarm.cashRemote:FireServer(100) -- Amount
        end)
    end
end

---Farm XP
function AutoFarm.farmXP()
    if AutoFarm.xpRemote then
        pcall(function()
            AutoFarm.xpRemote:FireServer(100) -- Amount
        end)
    end
end

---Farm kills (attack nearest enemy)
function AutoFarm.farmKills()
    local localPlayer = Services.playersService.LocalPlayer
    local localChar = localPlayer.Character
    if not localChar then return end

    local hrp = localChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Find nearest enemy
    local nearestEnemy = nil
    local nearestDist = math.huge

    for _, player in ipairs(Services.playersService:GetPlayers()) do
        if player == localPlayer then continue end
        if State.teamCheck and player.Team == localPlayer.Team then continue end

        local char = player.Character
        if not char then continue end

        local enemyHrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        if not enemyHrp or not humanoid or humanoid.Health <= 0 then continue end

        local dist = (enemyHrp.Position - hrp.Position).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearestEnemy = player
        end
    end

    if nearestEnemy and AutoFarm.damageRemote then
        -- Fire damage remote
        pcall(function()
            AutoFarm.damageRemote:FireServer(nearestEnemy.Character, 100, "Head")
        end)
    end
end

---Farm items (collect drops)
function AutoFarm.farmItems()
    local localPlayer = Services.playersService.LocalPlayer
    local localChar = localPlayer.Character
    if not localChar then return end

    local hrp = localChar:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Find nearby items/drops
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("drop") or obj.Name:lower():find("cash") or obj.Name:lower():find("item") then
            local dist = (obj.Position - hrp.Position).Magnitude
            if dist < 50 then
                -- Teleport to item or fire proximity prompt
                local prompt = obj:FindFirstChild("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end

---Give weapon
---@param weaponName string
function AutoFarm.giveWeapon(weaponName)
    if AutoFarm.giveWeaponRemote then
        pcall(function()
            AutoFarm.giveWeaponRemote:FireServer(weaponName)
        end)
    end
end

---Set farm cash
---@param enabled boolean
function AutoFarm.setFarmCash(enabled)
    State.farmCash = enabled
end

---Set farm XP
---@param enabled boolean
function AutoFarm.setFarmXP(enabled)
    State.farmXP = enabled
end

---Set farm kills
---@param enabled boolean
function AutoFarm.setFarmKills(enabled)
    State.farmKills = enabled
end

---Set farm items
---@param enabled boolean
function AutoFarm.setFarmItems(enabled)
    State.farmItems = enabled
end

---Set team check
---@param enabled boolean
function AutoFarm.setTeamCheck(enabled)
    State.teamCheck = enabled
end

---Cleanup
function AutoFarm.cleanup()
    AutoFarm.disable()
end

return AutoFarm