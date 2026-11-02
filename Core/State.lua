-- State.
---@module Core.State
local State = {}

-- Shared state tables
State.maid = {}
State.signals = {}
State.cache = {}
State.enabledFeatures = {}
State.config = {}
State.connections = {}

-- Feature states
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

-- Configuration values
State.fovRadius = 120
State.hitboxMultiplier = 2
State.flySpeed = 50
State.walkSpeed = 16
State.silentAimTargetPart = "Head"
State.aimbotSmoothness = 0.1
State.teamCheck = true
State.visibleCheck = true
State.distanceCheck = true
State.maxDistance = 1000

-- Runtime references
State.localPlayer = nil
State.camera = nil
State.currentTarget = nil
State.fovCircle = nil
State.espObjects = {}
State.tracerObjects = {}

return State