EZOGroupFrames_EZOCorePerformance = EZOGroupFrames_EZOCorePerformance or {}

local MOD = EZOGroupFrames_EZOCorePerformance
local UPDATE_NAMESPACE = "EZOGroupFrames_EZOCorePerformance_Update"
local SOURCE_ADDON_ID = "ezogroupframes"
local PUBLISH_INTERVAL_MS = 15000
local TTL_SECONDS = 45

local callbackRegistered = false

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

local function GetLatencyMs()
    if type(GetLatency) ~= "function" then
        return nil
    end
    return RoundToStep(GetLatency(), 5)
end

local function GetFps()
    local fn = type(GetFramerate) == "function" and GetFramerate
        or type(GetFrameRate) == "function" and GetFrameRate
        or nil
    if type(fn) ~= "function" then
        return nil
    end
    return RoundToStep(fn(), 1)
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

local function RefreshFrames()
    if EZOGroupFrames_Frames and type(EZOGroupFrames_Frames.Refresh) == "function" then
        EZOGroupFrames_Frames.Refresh()
    end
end

local function OnPerformanceStateUpdated()
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
    if settings.showPing == true and tonumber(state.pingMs) then
        parts[#parts + 1] = string.format("%dms", tonumber(state.pingMs))
    end
    if settings.showFps == true and tonumber(state.fps) then
        parts[#parts + 1] = string.format("%dfps", tonumber(state.fps))
    end
    if settings.showPrivacy == true then
        parts[#parts + 1] = GetPrivacyText(state.privacyState)
    end
    return table.concat(parts, " ")
end

function MOD.PublishNow()
    local settings = GetSettings()
    if settings.sharePerformance ~= true or not IsGrouped() then
        return false, "disabled"
    end

    local service = GetGroupPresenceService()
    if not service or type(service.PublishPerformanceState) ~= "function" then
        return false, "serviceMissing"
    end

    local state = {
        sourceAddonId = SOURCE_ADDON_ID,
        pingMs = GetLatencyMs(),
        fps = GetFps(),
        privacyState = "public",
        ttlSeconds = TTL_SECONDS,
    }
    if state.pingMs == nil or state.fps == nil then
        return false, "metricsUnavailable"
    end

    local ok, published, reason = pcall(service.PublishPerformanceState, service, state)
    if ok then
        return published == true, reason
    end
    return false, tostring(published or "publishFailed")
end

local function OnPublishUpdate()
    RefreshFrames()
    MOD.PublishNow()
end

function MOD.RefreshPublisher()
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_NAMESPACE)
    end

    local settings = GetSettings()
    if (settings.showPlayerStatus == true or settings.sharePerformance == true)
        and EVENT_MANAGER
        and type(EVENT_MANAGER.RegisterForUpdate) == "function" then
        EVENT_MANAGER:RegisterForUpdate(UPDATE_NAMESPACE, PUBLISH_INTERVAL_MS, OnPublishUpdate)
        if settings.sharePerformance == true then
            MOD.PublishNow()
        end
    end
end

function MOD.Init()
    RegisterCallback()
    MOD.RefreshPublisher()
end
