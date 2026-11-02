-- Maid.
---@module Utility.Maid
local Maid = {}
Maid.__index = Maid

---Create a new Maid instance
---@return Maid
function Maid.new()
    local self = setmetatable({}, Maid)
    self._tasks = {}
    return self
end

---Add a task to the maid
---@param task any
---@return any
function Maid:GiveTask(task)
    if not task then return task end
    table.insert(self._tasks, task)
    return task
end

---Remove a specific task
---@param task any
function Maid:RemoveTask(task)
    for i, t in ipairs(self._tasks) do
        if t == task then
            table.remove(self._tasks, i)
            break
        end
    end
end

---Clean up all tasks
function Maid:DoCleaning()
    for i = #self._tasks, 1, -1 do
        local task = self._tasks[i]
        if typeof(task) == "function" then
            task()
        elseif typeof(task) == "table" and task.Destroy then
            task:Destroy()
        elseif typeof(task) == "table" and task.Disconnect then
            task:Disconnect()
        elseif typeof(task) == "Instance" then
            task:Destroy()
        elseif typeof(task) == "RBXScriptConnection" then
            task:Disconnect()
        end
    end
    self._tasks = {}
end

---Destroy the maid
function Maid:Destroy()
    self:DoCleaning()
    setmetatable(self, nil)
end

return Maid