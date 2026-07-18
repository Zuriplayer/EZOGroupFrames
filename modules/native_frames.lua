EZOGroupFrames_NativeFrames = EZOGroupFrames_NativeFrames or {}

local MOD = EZOGroupFrames_NativeFrames

local HIDDEN_REASON = "EZOGroupFrames"
local STYLE_REFRESH_DELAY_MS = 250
local STYLE_REFRESH_FALLBACK_DELAY_MS = 1000
local NATIVE_GROUP_CONTROLS = {
    "ZO_UnitFramesGroups",
}

local function IsHudScene()
    if EZOGroupFrames_HudVisibility and EZOGroupFrames_HudVisibility.IsHudScene then
        return EZOGroupFrames_HudVisibility.IsHudScene()
    end
    if not SCENE_MANAGER then
        return true
    end
    return SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
end

local function ShouldHideNative(customFramesVisible)
    return customFramesVisible == true
        and EZOGroupFrames
        and EZOGroupFrames.sv
        and EZOGroupFrames.sv.frames
        and EZOGroupFrames.sv.frames.hideNativeWhenActive ~= false
end

local function SetNativeHiddenFallback(hidden)
    for _, controlName in ipairs(NATIVE_GROUP_CONTROLS) do
        local control = _G[controlName]
        if control and type(control.SetHidden) == "function" then
            control:SetHidden(hidden == true)
            MOD.touched = true
        end
    end
end

local function SetNativeHidden(hidden, force)
    hidden = hidden == true
    if force ~= true and MOD.nativeHidden == hidden then
        return
    end

    if UNIT_FRAMES and type(UNIT_FRAMES.SetGroupAndRaidFramesHiddenForReason) == "function" then
        UNIT_FRAMES:SetGroupAndRaidFramesHiddenForReason(HIDDEN_REASON, hidden)
        MOD.nativeHidden = hidden
        MOD.touched = true
        return
    end

    SetNativeHiddenFallback(hidden)
    MOD.nativeHidden = hidden
end

local function ScheduleResumeAfterStyleRefresh(generation)
    local resumed = false
    local function Resume()
        if resumed or MOD.styleRefreshGeneration ~= generation then
            return
        end

        resumed = true
        MOD.suspendNativeHiding = false
        MOD.Refresh()
    end

    if type(zo_callLater) == "function" then
        zo_callLater(Resume, STYLE_REFRESH_DELAY_MS)
        zo_callLater(Resume, STYLE_REFRESH_FALLBACK_DELAY_MS)
    else
        Resume()
    end
end

local function RestoreNativeForStyleRefresh()
    MOD.styleRefreshGeneration = (MOD.styleRefreshGeneration or 0) + 1
    MOD.suspendNativeHiding = true

    -- The ESO style refresh reads native group-frame anchors immediately. Clear
    -- our hidden reason even if the local cache has drifted from UNIT_FRAMES.
    SetNativeHidden(false, true)
    MOD.hiddenByAddon = false

    ScheduleResumeAfterStyleRefresh(MOD.styleRefreshGeneration)
end

local function MayManageNativeFrames()
    return MOD.nativeHidden == true
        or MOD.hiddenByAddon == true
        or MOD.touched == true
        or (EZOGroupFrames
            and EZOGroupFrames.sv
            and EZOGroupFrames.sv.frames
            and EZOGroupFrames.sv.frames.hideNativeWhenActive ~= false)
end

local function InstallPlatformStylePreHook()
    if MOD.platformStylePreHookInstalled then
        return
    end
    if type(ZO_PreHook) ~= "function" then
        return
    end
    if type(ZO_PlatformStyle) ~= "table" or type(ZO_PlatformStyle.Apply) ~= "function" then
        return
    end

    ZO_PreHook(ZO_PlatformStyle, "Apply", function()
        if MayManageNativeFrames() then
            RestoreNativeForStyleRefresh()
        end
        return false
    end)

    MOD.platformStylePreHookInstalled = true
end

function MOD.ApplyVisibility(customFramesVisible)
    if MOD.suspendNativeHiding then
        if MOD.nativeHidden then
            SetNativeHidden(false)
        end
        MOD.hiddenByAddon = false
        return
    end

    if ShouldHideNative(customFramesVisible) then
        SetNativeHidden(true)
        MOD.hiddenByAddon = true
        return
    end

    if MOD.hiddenByAddon and IsHudScene() then
        SetNativeHidden(false)
        MOD.hiddenByAddon = false
    end
end

function MOD.Refresh()
    local customFramesVisible = EZOGroupFrames_Frames
        and EZOGroupFrames_Frames.IsFunctionallyShowing
        and EZOGroupFrames_Frames.IsFunctionallyShowing()

    MOD.ApplyVisibility(customFramesVisible == true)
end

function MOD.Init()
    InstallPlatformStylePreHook()

    if EVENT_MANAGER and EVENT_GAMEPAD_PREFERRED_MODE_CHANGED then
        EVENT_MANAGER:UnregisterForEvent("EZOGroupFrames_NativeFrames", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED)
        EVENT_MANAGER:RegisterForEvent("EZOGroupFrames_NativeFrames", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function()
            RestoreNativeForStyleRefresh()
        end)
    end

    if SCENE_MANAGER then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
            MOD.Refresh()
        end)
    end

    MOD.Refresh()
end
