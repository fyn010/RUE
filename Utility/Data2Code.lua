-- Data2Code.
---@module Utility.Data2Code
local Data2Code = {}

Data2Code.loaded = false
Data2Code.Class = nil
Data2Code.Methods = nil

---Load Data2Code from GitHub
function Data2Code.load()
    if Data2Code.loaded then return Data2Code.Class, Data2Code.Methods end

    local Constants = require("Core/Constants")
    local success, result = pcall(function()
        return loadstring(game:HttpGet(Constants.DATA2CODE_URL))()
    end)

    if success and result then
        Data2Code.Class, Data2Code.Methods = result[1], result[2]
        Data2Code.loaded = true
    else
        warn("Failed to load Data2Code: " .. tostring(result))
    end

    return Data2Code.Class, Data2Code.Methods
end

---Serialize any value to Lua code
---@param value any
---@param pretty boolean?
---@return string
function Data2Code.Convert(value, pretty)
    Data2Code.load()
    if Data2Code.Class then
        return Data2Code.Class.Convert(value, pretty or false)
    end
    return tostring(value)
end

---Print serialized value
---@param ... any
function Data2Code.print(...)
    Data2Code.load()
    if Data2Code.Class then
        Data2Code.Class.print(...)
    else
        print(...)
    end
end

---Warn serialized value
---@param ... any
function Data2Code.warn(...)
    Data2Code.load()
    if Data2Code.Class then
        Data2Code.Class.warn(...)
    else
        warn(...)
    end
end

---Set clipboard with serialized value
---@param value any
---@param pretty boolean?
function Data2Code.setclipboard(value, pretty)
    Data2Code.load()
    if Data2Code.Class then
        Data2Code.Class.setclipboard(value, pretty or false)
    end
end

---Convert known type
---@param dataType string
---@param value any
---@param pretty boolean?
---@return string
function Data2Code.ConvertKnown(dataType, value, pretty)
    Data2Code.load()
    if Data2Code.Class then
        return Data2Code.Class.ConvertKnown(dataType, value, pretty or false)
    end
    return tostring(value)
end

return Data2Code