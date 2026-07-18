EZOGroupFrames_EZOCorePerformance = EZOGroupFrames_EZOCorePerformance or {}

local MOD = EZOGroupFrames_EZOCorePerformance
local UPDATE_NAMESPACE = "EZOGroupFrames_EZOCorePerformance_Update"
local GROUP_EVENT_NAMESPACE = "EZOGroupFrames_EZOCorePerformance_Group"
local SOURCE_ADDON_ID = "ezogroupframes"
local PUBLISH_INTERVAL_MS = 15000
local INITIAL_PUBLISH_DELAY_MS = 1500
local TTL_SECONDS = 45
local WITHDRAW_TTL_SECONDS = 15
local MAX_PING_MS = 4095
local MAX_FPS = 255
local COLOR_WARNING = "FFD84D"
local COLOR_CRITICAL = "FF4A4A"

local callbackRegistered = false
local groupEventRegistered = false
local publishGeneration = 0
local wasSharing = nil
local transportWasActive = nil
local lastPublishResultKey = nil
local receivedStateKeyByUnitTag = {}

local function GetSettings()
    return EZOGroupFrames
        and EZOGroupFrames.sv
        and EZOGroupFrames.sv.ezoStatus
        or {}
end

local function IsGrouped()
    return type(IsUnitGrouped) == "function" and IsUnitGrouped("player") == true
end

local function GetGroupPresenceService()
    if not (EZOCore and type(EZOCore.GetService) == "function") then
        return nil
    end

    local ok, service = pcall(EZOCore.GetService, EZOCore, "family.groupPresence", 1)
    if ok and type(service) == "table" then
        return service
    end
    return nil
end

local function RoundToStep(value, step)
    value = tonumber(value)
    step = tonumber(step) or 1
    if not value then
        return nil
    end
    return zo_floor((value / step) + 0.5) * step
end

local function ClampRounded(value, step, minimum, maximum)
    local rounded = RoundToStep(value, step)
    if rounded == nil then
        return nil
    end
    return math.max(minimum, math.min(maximum, rounded))
end

local function GetLatencyMs()
    if type(GetLatency) ~= "function" then
        return nil
    end
    return ClampRounded(GetLatency(), 5, 0, MAX_PING_MS)
end

local function GetFps()
    local fn = type(GetFramerate) == "function" and GetFramerate
        or type(GetFrameRate) == "function" and GetFrameRate
        or nil
    if type(fn) ~= "function" then
        return nil
    end
    return ClampRounded(fn(), 1, 0, MAX_FPS)
end

local function IsPublicPrivacy(state)
    return state == "public" or tonumber(state) == 1
end

local function GetPrivacyText(state)
    local value = state
    if tonumber(value) == 1 then
        value = "public"
    elseif tonumber(value) == 2 then
        value = "private"
    elseif tonumber(value) == 3 then
        value = "hidden"
    end

    if value == "public" then
        return GetString(EZO_GF_PRIVACY_PUBLIC_SHORT)
    elseif value == "private" then
        return GetString(EZO_GF_PRIVACY_PRIVATE_SHORT)
    elseif value == "hidden" then
        return GetString(EZO_GF_PRIVACY_HIDDEN_SHORT)
    end
    return GetString(EZO_GF_PRIVACY_UNKNOWN_SHORT)
end

local function Colorize(text, color)
    if not color then
        return text
    end
    return string.format("|c%s%s|r", color, text)
end

local function GetPingColor(pingMs)
    pingMs = tonumber(pingMs)
    if not pingMs then
        return nil
    end
    if pingMs >= 250 then
        return COLOR_CRITICAL
    end
    if pingMs >= 150 then
        return COLOR_WARNING
    end
    return nil
end

local function GetFpsColor(fps)
    fps = tonumber(fps)
    if not fps then
        return nil
    end
    if fps <= 30 then
        return COLOR_CRITICAL
    end
    if fps <= 45 then
        return COLOR_WARNING
    end
    return nil
end

local function RefreshFrames()
    if EZOGroupFrames_Frames and type(EZOGroupFrames_Frames.Refresh) == "function" then
        EZOGroupFrames_Frames.Refresh()
    end
end

local function LogPublishResult(published, reason, action)
    local result = published == true and "sent" or tostring(reason or "failed")
    local key = tostring(action or "publish") .. ":" .. result
    if key == lastPublishResultKey then
        return
    end
    lastPublishResultKey = key

    if EZOGroupFrames_Debug and type(EZOGroupFrames_Debug.Log) == "function" then
        EZOGroupFrames_Debug.Log(
            string.format("Performance state %s: %s", tostring(action or "publish"), result),
            "Performance")
    end
end

local function OnPerformanceStateUpdated(unitTag, state)
    if type(unitTag) == "string" and type(state) == "table" then
        local stateKey = tostring(state.privacyState)
        if receivedStateKeyByUnitTag[unitTag] ~= stateKey then
            receivedStateKeyByUnitTag[unitTag] = stateKey
            if EZOGroupFrames_Debug and type(EZOGroupFrames_Debug.Log) == "function" then
                EZOGroupFrames_Debug.Log(
                    string.format("Received performance state for %s (%s)", unitTag, stateKey),
                    "Performance")
            end
        end
    end
    RefreshFrames()
end

local function RegisterCallback()
    if callbackRegistered
        or not (EZOCore and type(EZOCore.RegisterCallback) == "function") then
        return false
    end

    local ok, result = pcall(function()
        return EZOCore:RegisterCallback("EZO_CORE_GROUP_PERFORMANCE_STATE_UPDATED", OnPerformanceStateUpdated)
    end)
    callbackRegistered = ok and result == true
    return callbackRegistered
end

function MOD.GetPeerState(unitTag)
    if type(unitTag) ~= "string" or unitTag == "" then
        return nil
    end

    local service = GetGroupPresenceService()
    if not service or type(service.GetPeerPerformanceState) ~= "function" then
        return nil
    end

    local ok, state = pcall(service.GetPeerPerformanceState, service, unitTag)
    if ok and type(state) == "table" then
        return state
    end
    return nil
end

function MOD.BuildDisplayText(unitTag)
    local settings = GetSettings()
    if settings.showPlayerStatus ~= true then
        return ""
    end

    local state = MOD.GetPeerState(unitTag)
    if type(state) ~= "table" then
        return ""
    end

    local parts = {}
    local publicMetrics = IsPublicPrivacy(state.privacyState)
    local pingMs = tonumber(state.pingMs)
    if publicMetrics and settings.showPing == true and pingMs then
        parts[#parts + 1] = Colorize(string.format("%dms", pingMs), GetPingColor(pingMs))
    end
    local fps = tonumber(state.fps)
    if publicMetrics and settings.showFps == true and fps then
        parts[#parts + 1] = Colorize(string.format("%dfps", fps), GetFpsColor(fps))
    end
    if settings.showPrivacy == true then
        parts[#parts + 1] = GetPrivacyText(state.privacyState)
    end
    return table.concat(parts, "/")
end

local function PublishState(state, action)
    local service = GetGroupPresenceService()
    if not service or type(service.PublishPerformanceState) ~= "function" then
        LogPublishResult(false, "serviceMissing", action)
        return false, "serviceMissing"
    end

    local ok, published, reason = pcall(service.PublishPerformanceState, service, state)
    if not ok then
        reason = tostring(published or "publishFailed")
        published = false
    end
    LogPublishResult(published == true, reason, action)
    return published == true, reason
end

function MOD.PublishNow()
    local settings = GetSettings()
    if settings.sharePerformance ~= true then
        return false, "disabled"
    end
    if not IsGrouped() then
        LogPublishResult(false, "notGrouped", "publish")
        return false, "notGrouped"
    end

    local state = {
        sourceAddonId = SOURCE_ADDON_ID,
        pingMs = GetLatencyMs(),
        fps = GetFps(),
        privacyState = "public",
        ttlSeconds = TTL_SECONDS,
    }
    if state.pingMs == nil or state.fps == nil then
        LogPublishResult(false, "metricsUnavailable", "publish")
        return false, "metricsUnavailable"
    end

    return PublishState(state, "publish")
end

function MOD.WithdrawNow()
    if not IsGrouped() then
        return false, "notGrouped"
    end
    return PublishState({
        sourceAddonId = SOURCE_ADDON_ID,
        privacyState = "hidden",
        ttlSeconds = WITHDRAW_TTL_SECONDS,
    }, "withdraw")
end

function MOD.IsTransportActive()
    local service = GetGroupPresenceService()
    if not service then
        return false
    end
    if type(service.GetStatus) ~= "function" then
        return true
    end

    local ok, transportStatus = pcall(service.GetStatus, service)
    return ok and type(transportStatus) == "table" and transportStatus.active == true
end

local function CancelScheduledPublish()
    publishGeneration = publishGeneration + 1
end

local function AnnouncePresenceBeforePublish()
    local service = GetGroupPresenceService()
    if not service or type(service.AnnounceLocalPresence) ~= "function" then
        return false
    end

    local ok, announced = pcall(service.AnnounceLocalPresence, service)
    return ok and announced == true
end

local function SchedulePublish()
    CancelScheduledPublish()
    local generation = publishGeneration
    AnnouncePresenceBeforePublish()
    if type(zo_callLater) ~= "function" then
        MOD.PublishNow()
        return
    end

    zo_callLater(function()
        if generation == publishGeneration and GetSettings().sharePerformance == true and IsGrouped() then
            MOD.PublishNow()
        end
    end, INITIAL_PUBLISH_DELAY_MS)
end

local function OnPublishUpdate()
    RefreshFrames()
    local transportActive = MOD.IsTransportActive()
    if not transportActive then
        if GetSettings().sharePerformance == true then
            LogPublishResult(false, "transportInactive", "publish")
        end
    elseif GetSettings().sharePerformance == true then
        if transportWasActive == false then
            SchedulePublish()
        else
            MOD.PublishNow()
        end
    end
    transportWasActive = transportActive
end

local function RegisterGroupEvent()
    if groupEventRegistered
        or not EVENT_MANAGER
        or type(EVENT_MANAGER.RegisterForEvent) ~= "function"
        or EVENT_GROUP_UPDATE == nil then
        return false
    end

    EVENT_MANAGER:RegisterForEvent(GROUP_EVENT_NAMESPACE, EVENT_GROUP_UPDATE, function()
        receivedStateKeyByUnitTag = {}
        local settings = GetSettings()
        if settings.showPlayerStatus == true or settings.sharePerformance == true then
            MOD.RefreshPublisher()
        end
    end)
    groupEventRegistered = true
    return true
end

function MOD.RefreshPublisher()
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAMESPACE)
    end

    CancelScheduledPublish()
    local settings = GetSettings()
    local sharing = settings.sharePerformance == true
    local transportActive = MOD.IsTransportActive()
    transportWasActive = transportActive
    if wasSharing == true and not sharing then
        MOD.WithdrawNow()
    end
    wasSharing = sharing

    if (settings.showPlayerStatus == true or sharing)
        and EVENT_MANAGER
        and type(EVENT_MANAGER.RegisterForUpdate) == "function" then
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAMESPACE, PUBLISH_INTERVAL_MS, OnPublishUpdate)
        if sharing and transportActive then
            SchedulePublish()
        elseif sharing then
            LogPublishResult(false, "transportInactive", "publish")
        end
    end
end

function MOD.Init()
    RegisterCallback()
    RegisterGroupEvent()
    MOD.RefreshPublisher()
end
