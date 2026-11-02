-- Constants.
---@module Core.Constants
local Constants = {}

-- Game Specific Constants
Constants.PLACE_ID = 84448037861644
Constants.GAME_NAME = "Recarga Urbana"

-- WeaponClient Paths
Constants.WEAPON_CLIENT_PATH = "StarterPlayer.StarterPlayerScripts.WeaponClient"
Constants.HITBOX_CLIENT_PATH = "StarterPlayer.StarterPlayerScripts.HitboxClient"
Constants.MOVEMENT_CLIENT_PATH = "StarterPlayer.StarterPlayerScripts.MovementClient"

-- ModuleScript Names
Constants.CLIENT_STATE_NAME = "ClientState"
Constants.WEAPON_DATA_NAME = "WeaponData"
Constants.HITBOX_MODEL_NAME = "HitboxModel"
Constants.CLIENT_HITBOXES_NAME = "ClientHitboxes"
Constants.NET_LAG_NAME = "NetLag"
Constants.CONTROLS_NAME = "Controls"
Constants.ANTI_TUNNEL_NAME = "AntiTunnel"

-- Remote Paths
Constants.REMOTES_FOLDER = "Remotes"
Constants.EVENTS_FOLDER = "Events"
Constants.FIRE_REMOTE = "Fire"
Constants.RELOAD_REMOTE = "Reload"
Constants.DEAL_DAMAGE_REMOTE = "DealDamage"
Constants.GIVE_WEAPON_REMOTE = "GiveWeapon"
Constants.AWARD_CASH_REMOTE = "AwardCash"
Constants.AWARD_XP_REMOTE = "AwardXP"
Constants.BREAK_ARMOR_REMOTE = "BreakArmor"
Constants.FORCE_RESPAWN_REMOTE = "ForceRespawn"
Constants.SET_HEALTH_REMOTE = "SetHealth"
Constants.REFILL_AMMO_REMOTE = "RefillAmmo"
Constants.RESET_COOLDOWNS_REMOTE = "ResetCooldowns"
Constants.UPDATE_STATS_REMOTE = "UpdateStats"

-- Hitbox Names
Constants.HITBOX_NAMES = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}

-- Default FOV
Constants.DEFAULT_FOV_RADIUS = 120
Constants.MAX_FOV_RADIUS = 500

-- Hitbox Expander Defaults
Constants.DEFAULT_HITBOX_MULTIPLIER = 2
Constants.MAX_HITBOX_MULTIPLIER = 10

-- Movement Defaults
Constants.DEFAULT_FLY_SPEED = 50
Constants.DEFAULT_WALK_SPEED = 16
Constants.DEFAULT_SPRINT_SPEED = 24
Constants.MAX_STAMINA = 150

-- GUI
Constants.GUI_TOGGLE_KEY = Enum.KeyCode.RightShift
Constants.GUI_THEME = "Dark"

-- Auto Farm
Constants.AUTO_FARM_INTERVAL = 1

-- Data2Code URL
Constants.DATA2CODE_URL = "https://raw.githubusercontent.com/Awakenchan/GcViewerV2/refs/heads/main/Utility/Data2Code%40Amity.lua"

-- Solara Protection
Constants.SOLARA_PROTECT_HOOKS = true
Constants.SOLARA_PROTECT_GUI = true

return Constants