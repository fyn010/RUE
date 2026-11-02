-- Movement Tab.
---@module GUI.Tabs.MovementTab
local MovementTab = {}

local Library = require("GUI/Library")
local State = require("Core/State")
local Fly = require("Features/Movement/Fly")
local Speed = require("Features/Movement/Speed")
local Noclip = require("Features/Movement/Noclip")
local InfiniteStamina = require("Features/Movement/InfiniteStamina")

MovementTab.tab = nil

---Initialize Movement Tab
---@param window table
function MovementTab.initialize(window)
    MovementTab.tab = Library.createTab(window, "Movement")

    -- Fly Section
    local flySection = Library.createSection(MovementTab.tab, "Fly")

    Library.createToggle(flySection, "Enabled", State.flyEnabled, function(value)
        State.flyEnabled = value
        if value then Fly.enable() else Fly.disable() end
    end)

    Library.createSlider(flySection, "Fly Speed", 1, 500, State.flySpeed or 50, function(value)
        State.flySpeed = value
        Fly.setSpeed(value)
    end)

    Library.createKeybind(flySection, "Toggle Key", Enum.KeyCode.F, function(key)
        Fly.toggle()
    end)

    -- Speed Section
    local speedSection = Library.createSection(MovementTab.tab, "Speed")

    Library.createToggle(speedSection, "Enabled", State.speedEnabled, function(value)
        State.speedEnabled = value
        if value then Speed.enable() else Speed.disable() end
    end)

    Library.createSlider(speedSection, "Walk Speed", 1, 200, State.walkSpeed or 16, function(value)
        State.walkSpeed = value
        Speed.setSpeed(value)
    end)

    Library.createKeybind(speedSection, "Toggle Key", Enum.KeyCode.V, function(key)
        Speed.toggle()
    end)

    -- Noclip Section
    local noclipSection = Library.createSection(MovementTab.tab, "Noclip")

    Library.createToggle(noclipSection, "Enabled", State.noclipEnabled, function(value)
        State.noclipEnabled = value
        if value then Noclip.enable() else Noclip.disable() end
    end)

    Library.createKeybind(noclipSection, "Toggle Key", Enum.KeyCode.N, function(key)
        Noclip.toggle()
    end)

    -- Infinite Stamina Section
    local staminaSection = Library.createSection(MovementTab.tab, "Infinite Stamina")

    Library.createToggle(staminaSection, "Enabled", State.infiniteStaminaEnabled, function(value)
        State.infiniteStaminaEnabled = value
        if value then InfiniteStamina.enable() else InfiniteStamina.disable() end
    end)

    Library.createKeybind(staminaSection, "Toggle Key", Enum.KeyCode.G, function(key)
        InfiniteStamina.toggle()
    end)

    return MovementTab.tab
end

return MovementTab