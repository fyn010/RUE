-- Logger.
---@module Utility.Logger
local Logger = {}

Logger.LogLevel = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

Logger.currentLevel = Logger.LogLevel.INFO
Logger.prefix = "[RUE]"

---Set log level
---@param level number
function Logger.setLevel(level)
    Logger.currentLevel = level
end

---Log debug message
---@param message string
---@param ... any
function Logger.debug(message, ...)
    if Logger.currentLevel <= Logger.LogLevel.DEBUG then
        print(Logger.prefix .. " [DEBUG] " .. message:format(...))
    end
end

---Log info message
---@param message string
---@param ... any
function Logger.info(message, ...)
    if Logger.currentLevel <= Logger.LogLevel.INFO then
        print(Logger.prefix .. " [INFO] " .. message:format(...))
    end
end

---Log warning message
---@param message string
---@param ... any
function Logger.warn(message, ...)
    if Logger.currentLevel <= Logger.LogLevel.WARN then
        warn(Logger.prefix .. " [WARN] " .. message:format(...))
    end
end

---Log error message
---@param message string
---@param ... any
function Logger.error(message, ...)
    if Logger.currentLevel <= Logger.LogLevel.ERROR then
        warn(Logger.prefix .. " [ERROR] " .. message:format(...))
    end
end

---Log with custom prefix
---@param prefix string
---@param message string
---@param ... any
function Logger.log(prefix, message, ...)
    print("[" .. prefix .. "] " .. message:format(...))
end

return Logger