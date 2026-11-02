-- Hitbox Expander.
---@module Features.Combat.HitboxExpander
local HitboxExpander = {}

local Constants = require("Core/Constants")
local State = require("Core/State")
local Services = require("Core/Services")
local Utilities = require("Core/Utilities")
local HookProtection = require("AntiCheat/HookProtection")
local Logger = require("Utility/Logger")

HitboxExpander.enabled = false
HitboxExpander.originalSizeOf = nil
HitboxExpander.expandedParts = {}

---Initialize Hitbox Expander
function HitboxExpander.initialize()
    Logger.info("Initializing Hitbox Expander...")
    HitboxExpander.enabled = State.hitboxExpanderEnabled
end

---Enable Hitbox Expander
function HitboxExpander.enable()
    if HitboxExpander.enabled then return end

    HitboxExpander.enabled = true
    State.hitboxExpanderEnabled = true

    -- Hook HitboxModel.SizeOf
    HitboxExpander.hookHitboxModel()

    -- Expand existing hitboxes
    HitboxExpander.expandExistingHitboxes()

    Logger.info("Hitbox Expander enabled")
end

---Disable Hitbox Expander
function HitboxExpander.disable()
    if not HitboxExpander.enabled then return end

    HitboxExpander.enabled = false
    State.hitboxExpanderEnabled = false

    -- Restore original SizeOf
    if HitboxExpander.originalSizeOf then
        local HitboxModel = Utilities.getWeaponClientModule(Constants.HITBOX_MODEL_NAME)
        if HitboxModel then
            HitboxModel.SizeOf = HitboxExpander.originalSizeOf
        end
        HitboxExpander.originalSizeOf = nil
    end

    -- Restore expanded parts
    HitboxExpander.restoreExpandedParts()

    Logger.info("Hitbox Expander disabled")
end

---Hook HitboxModel.SizeOf function
function HitboxExpander.hookHitboxModel()
    local HitboxModel = Utilities.getWeaponClientModule(Constants.HITBOX_MODEL_NAME)
    if not HitboxModel then
        Logger.warn("HitboxModel not found")
        return
    end

    if HitboxModel.SizeOf and typeof(HitboxModel.SizeOf) == "function" then
        HitboxExpander.originalSizeOf = HitboxModel.SizeOf
        HitboxModel.SizeOf = HookProtection.wrapHook(function(hitboxName)
            local originalSize = HitboxExpander.originalSizeOf(hitboxName)
            if typeof(originalSize) == "Vector3" then
                return originalSize * State.hitboxMultiplier
            end
            return originalSize
        end)
        Logger.debug("Hooked HitboxModel.SizeOf")
    end
end

---Expand existing hitbox parts
function HitboxExpander.expandExistingHitboxes()
    local ClientHitboxes = Utilities.getWeaponClientModule(Constants.CLIENT_HITBOXES_NAME)
    if not ClientHitboxes then
        Logger.warn("ClientHitboxes not found")
        return
    end

    local folders = ClientHitboxes.folders
    if not folders then return end

    for character, folder in pairs(folders) do
        if folder and folder:IsA("Folder") then
            for _, part in ipairs(folder:GetChildren()) do
                if part:IsA("BasePart") then
                    HitboxExpander.expandPart(part)
                end
            end
        end
    end
end

---Expand a single hitbox part
---@param part BasePart
function HitboxExpander.expandPart(part)
    if HitboxExpander.expandedParts[part] then return end

    HitboxExpander.expandedParts[part] = {
        originalSize = part.Size,
        originalTransparency = part.Transparency
    }

    part.Size = part.Size * State.hitboxMultiplier

    -- Visual indicator
    if State.espEnabled then
        part.Transparency = 0.7
        part.Color = Color3.fromRGB(255, 0, 0)
        part.Material = Enum.Material.ForceField
    end
end

---Restore expanded parts to original
function HitboxExpander.restoreExpandedParts()
    for part, data in pairs(HitboxExpander.expandedParts) do
        if part and part.Parent then
            part.Size = data.originalSize
            part.Transparency = data.originalTransparency
        end
    end
    HitboxExpander.expandedParts = {}
end

---Set hitbox multiplier
---@param multiplier number
function HitboxExpander.setMultiplier(multiplier)
    State.hitboxMultiplier = math.clamp(multiplier, 1, Constants.MAX_HITBOX_MULTIPLIER)

    -- Re-expand with new multiplier
    if HitboxExpander.enabled then
        HitboxExpander.restoreExpandedParts()
        HitboxExpander.expandExistingHitboxes()
    end
end

---Set hitbox transparency for visualization
---@param transparency number
function HitboxExpander.setVisualization(enabled, transparency)
    for part, data in pairs(HitboxExpander.expandedParts) do
        if part and part.Parent then
            part.Transparency = enabled and (transparency or 0.7) or data.originalTransparency
            part.Color = enabled and Color3.fromRGB(255, 0, 0) or part.Color
            part.Material = enabled and Enum.Material.ForceField or Enum.Material.Plastic
        end
    end
end

---Get current multiplier
---@return number
function HitboxExpander.getMultiplier()
    return State.hitboxMultiplier
end

---Cleanup
function HitboxExpander.cleanup()
    HitboxExpander.disable()
end

return HitboxExpander