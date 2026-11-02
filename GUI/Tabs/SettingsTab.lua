-- Settings Tab.
---@module GUI.Tabs.SettingsTab
local SettingsTab = {}

local Library = require("GUI/Library")
local State = require("Core/State")
local Constants = require("Core/Constants")
local Window = require("GUI/Window")

SettingsTab.tab = nil

---Initialize Settings Tab
---@param window table
function SettingsTab.initialize(window)
    SettingsTab.tab = Library.createTab(window, "Settings")

    -- UI Settings Section
    local uiSection = Library.createSection(SettingsTab.tab, "UI Settings")

    Library.createKeybind(uiSection, "Toggle GUI Key", Constants.GUI_TOGGLE_KEY, function(key)
        Constants.GUI_TOGGLE_KEY = key
    end)

    Library.createDropdown(uiSection, "Theme", {"Dark", "Light", "Blue", "Red", "Green", "Purple"}, Constants.GUI_THEME, function(value)
        Constants.GUI_THEME = value
        -- Theme change would require reloading UI
    end)

    Library.createToggle(uiSection, "Show Watermark", true, function(value) end)
    Library.createToggle(uiSection, "Show Keybinds", true, function(value) end)
    Library.createToggle(uiSection, "Minimize to Tray", false, function(value) end)

    -- Configuration Section
    local configSection = Library.createSection(SettingsTab.tab, "Configuration")

    Library.createButton(configSection, "Save Config", function()
        SettingsTab.saveConfig()
    end)

    Library.createButton(configSection, "Load Config", function()
        SettingsTab.loadConfig()
    end)

    Library.createButton(configSection, "Reset Config", function()
        SettingsTab.resetConfig()
    end)

    Library.createButton(configSection, "Export Config to Clipboard", function()
        SettingsTab.exportConfig()
    end)

    -- Anti-Cheat Section
    local acSection = Library.createSection(SettingsTab.tab, "Anti-Cheat")

    Library.createToggle(acSection, "Enable Bypass", true, function(value) end)
    Library.createToggle(acSection, "Hook Protection", true, function(value) end)
    Library.createToggle(acSection, "Environment Spoofing", true, function(value) end)
    Library.createToggle(acSection, "Safe Teleport", false, function(value)
        State.safeTeleport = value
    end)

    -- Performance Section
    local perfSection = Library.createSection(SettingsTab.tab, "Performance")

    Library.createToggle(perfSection, "Enable Profiler", false, function(value)
        local Profiler = require("Utility/Profiler")
        Profiler.setEnabled(value)
    end)

    Library.createButton(perfSection, "Print Profiler Results", function()
        local Profiler = require("Utility/Profiler")
        Profiler.printResults()
    end)

    Library.createButton(perfSection, "Reset Profiler", function()
        local Profiler = require("Utility/Profiler")
        Profiler.reset()
    end)

    -- Debug Section
    local debugSection = Library.createSection(SettingsTab.tab, "Debug")

    Library.createButton(debugSection, "Print State to Console", function()
        print("=== RUE State ===")
        for k, v in pairs(State) do
            if typeof(v) ~= "function" and typeof(v) ~= "table" then
                print(k .. ": " .. tostring(v))
            end
        end
    end)

    Library.createButton(debugSection, "Reinitialize All Features", function()
        SettingsTab.reinitialize()
    end)

    Library.createButton(debugSection, "Destroy GUI", function()
        Window.destroy()
    end)

    return SettingsTab.tab
end

---Save configuration to file
function SettingsTab.saveConfig()
    local config = {}
    for k, v in pairs(State) do
        if typeof(v) ~= "function" and typeof(v) ~= "table" and typeof(v) ~= "userdata" then
            config[k] = v
        end
    end

    local HttpService = game:GetService("HttpService")
    local json = HttpService:JSONEncode(config)

    pcall(function()
        writefile("RUE_Config.json", json)
    end)
end

---Load configuration from file
function SettingsTab.loadConfig()
    pcall(function()
        local HttpService = game:GetService("HttpService")
        if isfile("RUE_Config.json") then
            local json = readfile("RUE_Config.json")
            local config = HttpService:JSONDecode(json)
            for k, v in pairs(config) do
                State[k] = v
            end
        end
    end)
end

---Reset configuration
function SettingsTab.resetConfig()
    pcall(function()
        delfile("RUE_Config.json")
    end)
    -- Reset state to defaults
    State.silentAimEnabled = false
    State.aimbotEnabled = false
    State.hitboxExpanderEnabled = false
    State.gunModsEnabled = false
    State.espEnabled = false
    State.tracersEnabled = false
    State.flyEnabled = false
    State.speedEnabled = false
    State.noclipEnabled = false
    State.infiniteStaminaEnabled = false
    State.teleportEnabled = false
    State.autoFarmEnabled = false
end

---Export config to clipboard
function SettingsTab.exportConfig()
    local config = {}
    for k, v in pairs(State) do
        if typeof(v) ~= "function" and typeof(v) ~= "table" and typeof(v) ~= "userdata" then
            config[k] = v
        end
    end

    local HttpService = game:GetService("HttpService")
    local json = HttpService:JSONEncode(config)

    pcall(function()
        setclipboard(json)
    end)
end

---Reinitialize all features
function SettingsTab.reinitialize()
    -- This would reinitialize all features
    -- Implementation depends on feature structure
end

return SettingsTab