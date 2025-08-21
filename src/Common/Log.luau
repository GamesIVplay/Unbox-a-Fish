local Log = {}

local function createLogFunction(LevelName, LogFn, PrintInDev)
    return function(...)
        if PrintInDev and not _G.IN_DEV then
            return
        end

        local ModulePath = debug.info(2, "s")
        local ModuleName = ModulePath:match("[^.]+$")

        LogFn(`[{ModuleName}] {LevelName}:`, ...)
    end
end

Log.Debug = createLogFunction("DEBUG", print, false)
Log.Info = createLogFunction("INFO", print, true)
Log.Warn = createLogFunction("WARN", warn, true)

return Log
