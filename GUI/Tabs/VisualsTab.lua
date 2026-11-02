-- Visuals Tab.
---@module GUI.Tabs.VisualsTab
local VisualsTab = {}

local Library = ModuleLoader.load("GUI/Library")
local State = ModuleLoader.load("Core/State")
local ESP = ModuleLoader.load("Features/Visuals/ESP")
local Tracers = ModuleLoader.load("Features/Visuals/Tracers")

VisualsTab.tab = nil

---Initialize Visuals Tab
---@param window table
function VisualsTab.initialize(window)
    VisualsTab.tab = Library.createTab(window, "Visuals")

    -- ESP Section
    local espSection = Library.createSection(VisualsTab.tab, "Player ESP")

    Library.createToggle(espSection, "Enabled", State.espEnabled, function(value)
        State.espEnabled = value
        if value then ESP.enable() else ESP.disable() end
    end)

    Library.createToggle(espSection, "Team Check", State.teamCheck, function(value)
        State.teamCheck = value
    end)

    Library.createToggle(espSection, "Distance Check", State.distanceCheck, function(value)
        State.distanceCheck = value
    end)

    Library.createSlider(espSection, "Max Distance", 100, 5000, State.maxDistance or 1000, function(value)
        State.maxDistance = value
    end)

    Library.createToggle(espSection, "Show Boxes", true, function(value) end)
    Library.createToggle(espSection, "Show Names", true, function(value) end)
    Library.createToggle(espSection, "Show Health", true, function(value) end)
    Library.createToggle(espSection, "Show Distance", true, function(value) end)
    Library.createToggle(espSection, "Show Health Bar", true, function(value) end)

    -- Tracers Section
    local tracersSection = Library.createSection(VisualsTab.tab, "Tracers")

    Library.createToggle(tracersSection, "Enabled", State.tracersEnabled, function(value)
        State.tracersEnabled = value
        if value then Tracers.enable() else Tracers.disable() end
    end)

    Library.createDropdown(tracersSection, "Origin", {"Bottom", "Mouse", "Center"}, "Bottom", function(value)
        State.tracerOrigin = value
        Tracers.setOrigin(value)
    end)

    Library.createToggle(tracersSection, "Team Check", State.teamCheck, function(value)
        State.teamCheck = value
    end)

    Library.createToggle(tracersSection, "Distance Check", State.distanceCheck, function(value)
        State.distanceCheck = value
    end)

    Library.createSlider(tracersSection, "Max Distance", 100, 5000, State.maxDistance or 1000, function(value)
        State.maxDistance = value
    end)

    -- FOV Circle Section
    local fovSection = Library.createSection(VisualsTab.tab, "FOV Circle")

    Library.createToggle(fovSection, "Show FOV Circle", false, function(value)
        if State.espEnabled and State.silentAimEnabled then
            -- FOV circle visibility handled by SilentAim
        end
    end)

    Library.createSlider(fovSection, "FOV Radius", 0, 500, State.fovRadius, function(value)
        State.fovRadius = value
    end)

    Library.createDropdown(fovSection, "FOV Color", {"White", "Red", "Green", "Blue", "Yellow", "Cyan", "Magenta"}, "White", function(value)
        -- Color handled in SilentAim
    end)

    -- Crosshair Section
    local crosshairSection = Library.createSection(VisualsTab.tab, "Crosshair")

    Library.createToggle(crosshairSection, "Custom Crosshair", false, function(value) end)
    Library.createSlider(crosshairSection, "Crosshair Size", 1, 50, 10, function(value) end)
    Library.createSlider(crosshairSection, "Crosshair Gap", 0, 20, 5, function(value) end)
    Library.createSlider(crosshairSection, "Crosshair Thickness", 1, 10, 2, function(value) end)

    return VisualsTab.tab
end

return VisualsTab