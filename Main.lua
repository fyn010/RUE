-- Main Entry Point.
---@module Main
-- Check for shared table
if not shared then
    return warn("No shared, no script.")
end

-- Initialize Luraph globals if they do not exist
loadstring("getfenv().LPH_NO_VIRTUALIZE = function(...) return ... end")()

getfenv().PP_SCRAMBLE_NUM = function(...) return ... end
getfenv().PP_SCRAMBLE_STR = function(...) return ... end
getfenv().PP_SCRAMBLE_RE_NUM = function(...) return ... end

-- Load ModuleLoader first
local moduleLoaderContent = readfile("RUE/Core/ModuleLoader.lua")
local moduleLoaderChunk = loadstring(moduleLoaderContent, "@RUE/Core/ModuleLoader.lua")
local ModuleLoader = moduleLoaderChunk()

-- Module table
local RUE = {
    version = "1.0.0",
    gameName = "Recarga Urbana",
    executor = "Solara",
    initialized = false,
    queued = false,
    silent = false
}

RUE.__index = RUE

-- Requires (using ModuleLoader)
---@module Core.Services
local Services = ModuleLoader.load("Core/Services")

---@module Core.Constants
local Constants = ModuleLoader.load("Core/Constants")

---@module Core.State
local State = ModuleLoader.load("Core/State")

---@module Core.Utilities
local Utilities = ModuleLoader.load("Core/Utilities")

---@module Utility.Maid
local Maid = ModuleLoader.load("Utility/Maid")

---@module Utility.Signal
local Signal = ModuleLoader.load("Utility/Signal")

---@module Utility.Logger
local Logger = ModuleLoader.load("Utility/Logger")

---@module Utility.Profiler
local Profiler = ModuleLoader.load("Utility/Profiler")

---@module Utility.Data2Code
local Data2Code = ModuleLoader.load("Utility/Data2Code")

---@module AntiCheat.Bypass
local Bypass = ModuleLoader.load("AntiCheat/Bypass")

---@module AntiCheat.HookProtection
local HookProtection = ModuleLoader.load("AntiCheat/HookProtection")

---@module AntiCheat.EnvironmentSpoof
local EnvironmentSpoof = ModuleLoader.load("AntiCheat/EnvironmentSpoof")

---@module Features.Combat.SilentAim
local SilentAim = ModuleLoader.load("Features/Combat/SilentAim")

---@module Features.Combat.Aimbot
local Aimbot = ModuleLoader.load("Features/Combat/Aimbot")

---@module Features.Combat.HitboxExpander
local HitboxExpander = ModuleLoader.load("Features/Combat/HitboxExpander")

---@module Features.Combat.GunMods
local GunMods = ModuleLoader.load("Features/Combat/GunMods")

---@module Features.Movement.Fly
local Fly = ModuleLoader.load("Features/Movement/Fly")

---@module Features.Movement.Speed
local Speed = ModuleLoader.load("Features/Movement/Speed")

---@module Features.Movement.Noclip
local Noclip = ModuleLoader.load("Features/Movement/Noclip")

---@module Features.Movement.InfiniteStamina
local InfiniteStamina = ModuleLoader.load("Features/Movement/InfiniteStamina")

---@module Features.Visuals.ESP
local ESP = ModuleLoader.load("Features/Visuals/ESP")

---@module Features.Visuals.Tracers
local Tracers = ModuleLoader.load("Features/Visuals/Tracers")

---@module Features.Player.Teleport
local Teleport = ModuleLoader.load("Features/Player/Teleport")

---@module Features.Player.AutoFarm
local AutoFarm = ModuleLoader.load("Features/Player/AutoFarm")

---@module Features.Exploits.Remotes
local Remotes = ModuleLoader.load("Features/Exploits/Remotes")

---@module GUI.Library
local Library = ModuleLoader.load("GUI/Library")

---@module GUI.Window
local Window = ModuleLoader.load("GUI/Window")

---@module GUI.Tabs.CombatTab
local CombatTab = ModuleLoader.load("GUI/Tabs/CombatTab")

---@module GUI.Tabs.MovementTab
local MovementTab = ModuleLoader.load("GUI/Tabs/MovementTab")

---@module GUI.Tabs.VisualsTab
local VisualsTab = ModuleLoader.load("GUI/Tabs/VisualsTab")

---@module GUI.Tabs.PlayerTab
local PlayerTab = ModuleLoader.load("GUI/Tabs/PlayerTab")

---@module GUI.Tabs.ExploitsTab
local ExploitsTab = ModuleLoader.load("GUI/Tabs/ExploitsTab")

---@module GUI.Tabs.SettingsTab
local SettingsTab = ModuleLoader.load("GUI/Tabs/SettingsTab")

-- Module-level state
local rueMaid = Maid.new()
local rueSignal = Signal.new()

-- Timestamp
local startTime = os.clock()

-- State references
State.localPlayer = Services.playersService.LocalPlayer
State.camera = Services.camera

-- Error handler
---This is called when initialization errors.
---@param error string
local function onInitializeError(error)
    warn("Failed to initialize RUE.")
    warn(error)
    warn(debug.traceback())
    RUE.detach()
end

---Initialize all features
local function initializeFeatures()
    Logger.info("Initializing features...")

    -- Initialize core features
    Bypass.initialize()
    HookProtection.initialize()
    EnvironmentSpoof.initialize()

    -- Initialize combat features
    SilentAim.initialize()
    Aimbot.initialize()
    HitboxExpander.initialize()
    GunMods.initialize()

    -- Initialize movement features
    Fly.initialize()
    Speed.initialize()
    Noclip.initialize()
    InfiniteStamina.initialize()

    -- Initialize visual features
    ESP.initialize()
    Tracers.initialize()

    -- Initialize player features
    Teleport.initialize()
    AutoFarm.initialize()

    -- Initialize exploits
    Remotes.initialize()

    Logger.info("All features initialized")
end

---Initialize GUI
local function initializeGUI()
    Logger.info("Initializing GUI...")

    local mainWindow = Window.create()

    -- Create tabs
    CombatTab.initialize(mainWindow)
    MovementTab.initialize(mainWindow)
    VisualsTab.initialize(mainWindow)
    PlayerTab.initialize(mainWindow)
    ExploitsTab.initialize(mainWindow)
    SettingsTab.initialize(mainWindow)

    -- Load saved config
    SettingsTab.loadConfig()

    -- Setup GUI toggle keybind
    Services.userInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Constants.GUI_TOGGLE_KEY then
            Window.toggle()
        end
    end)

    Logger.info("GUI initialized")
end

---Main initialization function
local function initializeScript()
    Logger.info("Starting RUE initialization...")
    Logger.info("Executor: " .. RUE.executor)
    Logger.info("Game: " .. RUE.gameName)
    Logger.info("Place ID: " .. tostring(Constants.PLACE_ID))

    -- Verify we're in the correct game
    if game.PlaceId ~= Constants.PLACE_ID then
        warn("Warning: Place ID mismatch. Expected " .. Constants.PLACE_ID .. ", got " .. game.PlaceId)
    end

    -- Wait for game to load
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    -- Initialize features
    initializeFeatures()

    -- Initialize GUI
    initializeGUI()

    -- Mark as initialized
    RUE.initialized = true
    shared.RUE = RUE

    local initTime = (os.clock() - startTime) * 1000
    Logger.info("RUE initialized in %.2fms", initTime)

    -- Print startup message
    print("========================================")
    print("  RUE - Recarga Urbana Exploit")
    print("  Version: " .. RUE.version)
    print("  Executor: " .. RUE.executor)
    print("  Initialized in " .. string.format("%.2fms", initTime))
    print("  Press " .. Constants.GUI_TOGGLE_KEY.Name .. " to toggle GUI")
    print("========================================")
end

---Detach and cleanup
function RUE.detach()
    Logger.info("Detaching RUE...")

    -- Cleanup features
    SilentAim.cleanup()
    Aimbot.cleanup()
    HitboxExpander.cleanup()
    GunMods.cleanup()
    Fly.cleanup()
    Speed.cleanup()
    Noclip.cleanup()
    InfiniteStamina.cleanup()
    ESP.cleanup()
    Tracers.cleanup()
    Teleport.cleanup()
    AutoFarm.cleanup()
    Remotes.cleanup()

    -- Restore hooks
    HookProtection.restoreAll()
    EnvironmentSpoof.restore()

    -- Destroy GUI
    Window.destroy()

    -- Clean up maid
    rueMaid:DoCleaning()

    -- Disconnect signals
    rueSignal:DisconnectAll()

    -- Clear shared
    shared.RUE = nil

    RUE.initialized = false
    Logger.info("RUE detached")
end

---Get version
---@return string
function RUE.getVersion()
    return RUE.version
end

---Check if initialized
---@return boolean
function RUE.isInitialized()
    return RUE.initialized
end

---Toggle silent mode
---@param silent boolean
function RUE.setSilent(silent)
    RUE.silent = silent
    Logger.setLevel(silent and Logger.LogLevel.ERROR or Logger.LogLevel.INFO)
end

-- Handle previous instance
if shared.RUE then
    shared.RUE.detach()
    RUE.queued = shared.RUE.queued
end

shared.RUE = RUE

-- Safely profile and initialize
Profiler.run("Main_InitializeScript", function(...)
    return xpcall(initializeScript, onInitializeError, ...)
end)

return RUE