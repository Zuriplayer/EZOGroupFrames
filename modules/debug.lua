EZOGroupFrames_Debug = EZOGroupFrames_Debug or {}

local MOD = EZOGroupFrames_Debug
local LOGGER_TAG = "EZOGroupFrames"

local function IsEnabled()
    return EZOGroupFrames
        and EZOGroupFrames.sv
        and EZOGroupFrames.sv.general
        and EZOGroupFrames.sv.general.debug == true
end

function MOD.EnsureLogger()
    if MOD.logger then
        return MOD.logger
    end

    local ok, logger = pcall(function()
        if not LibDebugLogger then
            return nil
        end

        local created = nil
        local debugLevel = type(LibDebugLogger) == "table" and LibDebugLogger.LOG_LEVEL_DEBUG or nil

        if type(LibDebugLogger) == "function" then
            created = LibDebugLogger(LOGGER_TAG)
        elseif type(LibDebugLogger) == "table" then
            local directOk, directLogger = pcall(LibDebugLogger, LOGGER_TAG)
            if directOk then
                created = directLogger
            elseif type(LibDebugLogger.Create) == "function" then
                created = LibDebugLogger:Create(LOGGER_TAG)
            end
        end

        if created and type(created.SetMinLevelOverride) == "function" and debugLevel ~= nil then
            created:SetMinLevelOverride(debugLevel)
        end
        if created and type(created.SetLogTracesOverride) == "function" then
            created:SetLogTracesOverride(false)
        end
        if created and type(created.SetEnabled) == "function" then
            created:SetEnabled(true)
        end

        return created
    end)

    if ok and logger then
        MOD.logger = logger
    end

    return MOD.logger
end

function MOD.Init()
    MOD.EnsureLogger()
end

function MOD.ShowViewer()
    if DebugLogViewer then
        if type(DebugLogViewer.ShowWindow) == "function" then
            DebugLogViewer.ShowWindow()
            return true
        end
        if type(DebugLogViewer.ToggleWindow) == "function" then
            DebugLogViewer.ToggleWindow()
            return true
        end
    end
    return false
end

function MOD.Log(message, subTag)
    if not IsEnabled() then
        return false
    end

    local logger = MOD.EnsureLogger()
    if not logger then
        return false
    end

    local ok = pcall(function()
        if type(logger.SetSubTag) == "function" then
            logger:SetSubTag(subTag or "Debug")
        end

        if type(logger.Debug) == "function" then
            logger:Debug(tostring(message or ""))
        elseif type(logger.Info) == "function" then
            logger:Info(tostring(message or ""))
        end
    end)

    if type(logger.SetSubTag) == "function" then
        pcall(function()
            logger:SetSubTag(nil)
        end)
    end

    return ok
end
