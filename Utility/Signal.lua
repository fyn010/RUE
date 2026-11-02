-- Signal.
---@module Utility.Signal
local Signal = {}
Signal.__index = Signal

---Create a new Signal
---@return Signal
function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    self._waitingThreads = {}
    return self
end

---Connect a function to the signal
---@param callback function
---@return table
function Signal:Connect(callback)
    local connection = {
        _callback = callback,
        _connected = true,
        _signal = self
    }
    table.insert(self._connections, connection)
    return connection
end

---Connect a function that fires once
---@param callback function
---@return table
function Signal:Once(callback)
    local connection
    connection = self:Connect(function(...)
        connection:Disconnect()
        callback(...)
    end)
    return connection
end

---Wait for the signal to fire
---@return ...
function Signal:Wait()
    local thread = coroutine.running()
    table.insert(self._waitingThreads, thread)
    return coroutine.yield()
end

---Fire the signal
---@param ... any
function Signal:Fire(...)
    for i = #self._connections, 1, -1 do
        local connection = self._connections[i]
        if connection._connected then
            task.spawn(connection._callback, ...)
        else
            table.remove(self._connections, i)
        end
    end
    for _, thread in ipairs(self._waitingThreads) do
        task.spawn(thread, ...)
    end
    self._waitingThreads = {}
end

---Disconnect all connections
function Signal:DisconnectAll()
    for _, connection in ipairs(self._connections) do
        connection._connected = false
    end
    self._connections = {}
    self._waitingThreads = {}
end

---Connection methods
local Connection = {}
Connection.__index = Connection

function Connection:Disconnect()
    self._connected = false
    if self._signal then
        for i, conn in ipairs(self._signal._connections) do
            if conn == self then
                table.remove(self._signal._connections, i)
                break
            end
        end
    end
end

return Signal