-- Gun Mods.
---@module Features.Combat.GunMods
local GunMods = {}

local Constants = ModuleLoader.load("Core/Constants")
local State = ModuleLoader.load("Core/State")
local Services = ModuleLoader.load("Core/Services")
local Utilities = ModuleLoader.load("Core/Utilities")
local HookProtection = ModuleLoader.load("AntiCheat/HookProtection")
local Logger = ModuleLoader.load("Utility/Logger")

GunMods.enabled = false
GunMods.originalSpread = nil
GunMods.originalRecoil = nil
GunMods.originalWeaponData = {}

---Initialize Gun Mods
function GunMods.initialize()
    Logger.info("Initializing Gun Mods...")
    GunMods.enabled = State.gunModsEnabled
end

---Enable Gun Mods
function GunMods.enable()
    if GunMods.enabled then return end

    GunMods.enabled = true
    State.gunModsEnabled = true

    GunMods.hookWeaponData()
    GunMods.hookSpreadAndRecoil()

    Logger.info("Gun Mods enabled")
end

---Disable Gun Mods
function GunMods.disable()
    if not GunMods.enabled then return end

    GunMods.enabled = false
    State.gunModsEnabled = false

    GunMods.restoreWeaponData()
    GunMods.restoreSpreadAndRecoil()

    Logger.info("Gun Mods disabled")
end

---Hook WeaponData for rapid fire, infinite ammo, etc.
function GunMods.hookWeaponData()
    local WeaponData = Utilities.getWeaponClientModule(Constants.WEAPON_DATA_NAME)
    if not WeaponData then
        Logger.warn("WeaponData not found")
        return
    end

    -- Backup original data
    for weaponName, weaponData in pairs(WeaponData) do
        if typeof(weaponData) == "table" then
            GunMods.originalWeaponData[weaponName] = Utilities.deepCopy(weaponData)

            -- Apply modifications
            if State.noRecoil then
                weaponData.Recoil = 0
                weaponData.RecoilX = 0
                weaponData.RecoilY = 0
            end

            if State.noSpread then
                weaponData.Spread = 0
                weaponData.Bloom = 0
            end

            if State.rapidFire then
                weaponData.RPM = weaponData.RPM * 3
                weaponData.FireRate = weaponData.FireRate / 3
            end

            if State.infiniteAmmo then
                weaponData.MaxAmmo = 9999
                weaponData.MagSize = 9999
            end

            if State.instantReload then
                weaponData.ReloadTime = 0.01
            end

            if State.autoReload then
                weaponData.AutoReload = true
            end
        end
    end
end

---Restore original WeaponData
function GunMods.restoreWeaponData()
    local WeaponData = Utilities.getWeaponClientModule(Constants.WEAPON_DATA_NAME)
    if not WeaponData then return end

    for weaponName, originalData in pairs(GunMods.originalWeaponData) do
        if WeaponData[weaponName] then
            for key, value in pairs(originalData) do
                WeaponData[weaponName][key] = value
            end
        end
    end
    GunMods.originalWeaponData = {}
end

---Hook spread and recoil functions in WeaponClient
function GunMods.hookSpreadAndRecoil()
    local WeaponClient = game:GetService("StarterPlayer").StarterPlayerScripts:FindFirstChild("WeaponClient")
    if not WeaponClient then return end

    local gc = getgc(true)
    for _, obj in ipairs(gc) do
        if typeof(obj) == "function" then
            local info = debug.getinfo(obj, "S")
            if info and info.source and info.source:find("WeaponClient") then
                local name = debug.getinfo(obj, "n").name or ""

                -- Hook currentSpread function
                if name:find("currentSpread") or name:find("getSpread") then
                    GunMods.originalSpread = obj
                    hookfunction(obj, HookProtection.wrapHook(function(...)
                        if State.noSpread then
                            return 0
                        end
                        return GunMods.originalSpread(...)
                    end))
                end

                -- Hook recoil function
                if name:find("Recoil") or name:find("recoil") then
                    GunMods.originalRecoil = obj
                    hookfunction(obj, HookProtection.wrapHook(function(...)
                        if State.noRecoil then
                            return Vector3.new(0, 0, 0)
                        end
                        return GunMods.originalRecoil(...)
                    end))
                end
            end
        end
    end
end

---Restore spread and recoil hooks
function GunMods.restoreSpreadAndRecoil()
    if GunMods.originalSpread then
        restorefunction(GunMods.originalSpread)
        GunMods.originalSpread = nil
    end
    if GunMods.originalRecoil then
        restorefunction(GunMods.originalRecoil)
        GunMods.originalRecoil = nil
    end
end

---Set no recoil
---@param enabled boolean
function GunMods.setNoRecoil(enabled)
    State.noRecoil = enabled
    if GunMods.enabled then
        GunMods.restoreWeaponData()
        GunMods.hookWeaponData()
    end
end

---Set no spread
---@param enabled boolean
function GunMods.setNoSpread(enabled)
    State.noSpread = enabled
    if GunMods.enabled then
        GunMods.restoreWeaponData()
        GunMods.hookWeaponData()
    end
end

---Set rapid fire
---@param enabled boolean
function GunMods.setRapidFire(enabled)
    State.rapidFire = enabled
    if GunMods.enabled then
        GunMods.restoreWeaponData()
        GunMods.hookWeaponData()
    end
end

---Set infinite ammo
---@param enabled boolean
function GunMods.setInfiniteAmmo(enabled)
    State.infiniteAmmo = enabled
    if GunMods.enabled then
        GunMods.restoreWeaponData()
        GunMods.hookWeaponData()
    end
end

---Set instant reload
---@param enabled boolean
function GunMods.setInstantReload(enabled)
    State.instantReload = enabled
    if GunMods.enabled then
        GunMods.restoreWeaponData()
        GunMods.hookWeaponData()
    end
end

---Set auto reload
---@param enabled boolean
function GunMods.setAutoReload(enabled)
    State.autoReload = enabled
    if GunMods.enabled then
        GunMods.restoreWeaponData()
        GunMods.hookWeaponData()
    end
end

---Cleanup
function GunMods.cleanup()
    GunMods.disable()
end

return GunMods