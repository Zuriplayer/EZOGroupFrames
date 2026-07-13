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
    if MOD.loggerUnavailable == true then
        return nil
    end

    local lib = _G.LibDebugLogger
    if type(lib) ~= "function" and type(lib) ~= "table" then
        MOD.loggerUnavailable = true
        return nil
    end

    local ok, logger = pcall(function()
        local created = nil
        local debugLevel = type(lib) == "table" and lib.LOG_LEVEL_DEBUG or nil

        if type(lib) == "function" then
            created = lib(LOGGER_TAG)
        elseif type(lib) == "table" then
            local directOk, directLogger = pcall(lib, LOGGER_TAG)
            if directOk then
                created = directLogger
            elseif type(lib.Create) == "function" then
                created = lib:Create(LOGGER_TAG)
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
        MOD.loggerUnavailable = false
    else
        MOD.loggerUnavailable = true
    end

    return MOD.logger
end

function MOD.Init()
    if IsEnabled() then
        MOD.EnsureLogger()
    end
end

function MOD.ShowViewer()
    local viewer = _G.DebugLogViewer
    if viewer then
        if type(viewer.ShowWindow) == "function" then
            viewer.ShowWindow()
            return true
        end
        if type(viewer.ToggleWindow) == "function" then
            viewer.ToggleWindow()
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
