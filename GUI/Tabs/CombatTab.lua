-- Combat Tab.
---@module GUI.Tabs.CombatTab
local CombatTab = {}

local Library = ModuleLoader.load("GUI/Library")
local State = ModuleLoader.load("Core/State")
local SilentAim = ModuleLoader.load("Features/Combat/SilentAim")
local Aimbot = ModuleLoader.load("Features/Combat/Aimbot")
local HitboxExpander = ModuleLoader.load("Features/Combat/HitboxExpander")
local GunMods = ModuleLoader.load("Features/Combat/GunMods")

CombatTab.tab = nil

---Initialize Combat Tab
---@param window table
function CombatTab.initialize(window)
    CombatTab.tab = Library.createTab(window, "Combat")

    -- Silent Aim Section
    local silentAimSection = Library.createSection(CombatTab.tab, "Silent Aim")

    Library.createToggle(silentAimSection, "Enabled", State.silentAimEnabled, function(value)
        State.silentAimEnabled = value
        if value then SilentAim.enable() else SilentAim.disable() end
    end)

    Library.createSlider(silentAimSection, "FOV Radius", 0, 500, State.fovRadius, function(value)
        State.fovRadius = value
        SilentAim.setFovRadius(value)
    end)

    Library.createDropdown(silentAimSection, "Target Part", {"Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}, State.silentAimTargetPart, function(value)
        State.silentAimTargetPart = value
        SilentAim.setTargetPart(value)
    end)

    Library.createToggle(silentAimSection, "Team Check", State.teamCheck, function(value)
        State.teamCheck = value
        SilentAim.setTeamCheck(value)
    end)

    Library.createToggle(silentAimSection, "Visible Check", State.visibleCheck, function(value)
        State.visibleCheck = value
        SilentAim.setVisibleCheck(value)
    end)

    Library.createToggle(silentAimSection, "Show FOV Circle", false, function(value)
        if SilentAim.fovCircle then
            SilentAim.fovCircle.Visible = value and State.silentAimEnabled
        end
    end)

    -- Aimbot Section
    local aimbotSection = Library.createSection(CombatTab.tab, "Aimbot")

    Library.createToggle(aimbotSection, "Enabled", State.aimbotEnabled, function(value)
        State.aimbotEnabled = value
        if value then Aimbot.enable() else Aimbot.disable() end
    end)

    Library.createSlider(aimbotSection, "FOV Radius", 0, 500, State.fovRadius, function(value)
        State.fovRadius = value
        Aimbot.setFovRadius(value)
    end)

    Library.createSlider(aimbotSection, "Smoothness", 0, 1, State.aimbotSmoothness or 0.1, function(value)
        State.aimbotSmoothness = value
        Aimbot.setSmoothness(value)
    end)

    Library.createDropdown(aimbotSection, "Target Part", {"Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}, State.silentAimTargetPart, function(value)
        State.silentAimTargetPart = value
        Aimbot.setTargetPart(value)
    end)

    Library.createToggle(aimbotSection, "Team Check", State.teamCheck, function(value)
        State.teamCheck = value
        Aimbot.setTeamCheck(value)
    end)

    Library.createToggle(aimbotSection, "Visible Check", State.visibleCheck, function(value)
        State.visibleCheck = value
        Aimbot.setVisibleCheck(value)
    end)

    -- Hitbox Expander Section
    local hitboxSection = Library.createSection(CombatTab.tab, "Hitbox Expander")

    Library.createToggle(hitboxSection, "Enabled", State.hitboxExpanderEnabled, function(value)
        State.hitboxExpanderEnabled = value
        if value then HitboxExpander.enable() else HitboxExpander.disable() end
    end)

    Library.createSlider(hitboxSection, "Multiplier", 1, 10, State.hitboxMultiplier or 2, function(value)
        State.hitboxMultiplier = value
        HitboxExpander.setMultiplier(value)
    end)

    Library.createToggle(hitboxSection, "Visualize Hitboxes", false, function(value)
        HitboxExpander.setVisualization(value, 0.7)
    end)

    -- Gun Mods Section
    local gunModsSection = Library.createSection(CombatTab.tab, "Gun Mods")

    Library.createToggle(gunModsSection, "Enabled", State.gunModsEnabled, function(value)
        State.gunModsEnabled = value
        if value then GunMods.enable() else GunMods.disable() end
    end)

    Library.createToggle(gunModsSection, "No Recoil", false, function(value)
        State.noRecoil = value
        GunMods.setNoRecoil(value)
    end)

    Library.createToggle(gunModsSection, "No Spread", false, function(value)
        State.noSpread = value
        GunMods.setNoSpread(value)
    end)

    Library.createToggle(gunModsSection, "Rapid Fire", false, function(value)
        State.rapidFire = value
        GunMods.setRapidFire(value)
    end)

    Library.createToggle(gunModsSection, "Infinite Ammo", false, function(value)
        State.infiniteAmmo = value
        GunMods.setInfiniteAmmo(value)
    end)

    Library.createToggle(gunModsSection, "Instant Reload", false, function(value)
        State.instantReload = value
        GunMods.setInstantReload(value)
    end)

    Library.createToggle(gunModsSection, "Auto Reload", false, function(value)
        State.autoReload = value
        GunMods.setAutoReload(value)
    end)

    return CombatTab.tab
end

return CombatTab