-- Module Loader.
---@module Core.ModuleLoader
local ModuleLoader = {}

ModuleLoader.cache = {}
ModuleLoader.basePath = "RUE/"

---Load a module from filesystem
---@param path string
---@return any
function ModuleLoader.load(path)
    if ModuleLoader.cache[path] then
        return ModuleLoader.cache[path]
    end

    local fullPath = ModuleLoader.basePath .. path .. ".lua"
    local success, content = pcall(function()
        return readfile(fullPath)
    end)

    if not success or not content then
        error("Failed to read module: " .. fullPath .. " - " .. tostring(content))
    end

    local chunk, err = loadstring(content, "@" .. fullPath)
    if not chunk then
        error("Failed to compile module: " .. fullPath .. " - " .. tostring(err))
    end

    -- Set up environment with requireModule
    local env = setmetatable({
        requireModule = ModuleLoader.load,
        require = ModuleLoader.load,
        shared = shared,
        game = game,
        workspace = workspace,
    }, { __index = getfenv() })

    setfenv(chunk, env)

    local result = chunk()
    ModuleLoader.cache[path] = result
    return result
end

---Clear cache
function ModuleLoader.clearCache()
    ModuleLoader.cache = {}
end

---Set base path
---@param path string
function ModuleLoader.setBasePath(path)
    ModuleLoader.basePath = path
end

-- Make globally available
getfenv().requireModule = ModuleLoader.load
getfenv().require = ModuleLoader.load

return ModuleLoader