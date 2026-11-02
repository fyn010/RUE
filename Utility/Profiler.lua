-- Profiler.
---@module Utility.Profiler
local Profiler = {}

Profiler.enabled = false
Profiler.results = {}

---Run a function with profiling
---@param scope string
---@param func function
---@param ... any
---@return ...
function Profiler.run(scope, func, ...)
    if not Profiler.enabled then
        return func(...)
    end

    local startTime = os.clock()
    local startMem = collectgarbage("count")

    local results = {func(...)}

    local endTime = os.clock()
    local endMem = collectgarbage("count")

    local duration = (endTime - startTime) * 1000
    local memUsed = endMem - startMem

    Profiler.results[scope] = Profiler.results[scope] or {
        count = 0,
        totalTime = 0,
        maxTime = 0,
        totalMem = 0
    }

    local stats = Profiler.results[scope]
    stats.count = stats.count + 1
    stats.totalTime = stats.totalTime + duration
    stats.maxTime = math.max(stats.maxTime, duration)
    stats.totalMem = stats.totalMem + memUsed

    return unpack(results)
end

---Get profiler results
---@return table
function Profiler.getResults()
    return Profiler.results
end

---Print profiler results
function Profiler.printResults()
    print("=== Profiler Results ===")
    for scope, stats in pairs(Profiler.results) do
        local avgTime = stats.totalTime / stats.count
        print(string.format("%s: %d calls, avg %.2fms, max %.2fms, total mem %.2fKB",
            scope, stats.count, avgTime, stats.maxTime, stats.totalMem))
    end
end

---Reset profiler
function Profiler.reset()
    Profiler.results = {}
end

---Enable/disable profiler
---@param enabled boolean
function Profiler.setEnabled(enabled)
    Profiler.enabled = enabled
end

return Profiler