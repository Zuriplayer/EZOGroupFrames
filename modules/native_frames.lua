EZOGroupFrames_NativeFrames = EZOGroupFrames_NativeFrames or {}

local MOD = EZOGroupFrames_NativeFrames

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

local function SetNativeHidden(hidden)
    hidden = hidden == true
    if MOD.nativeHidden == hidden then
        return
    end

    for _, controlName in ipairs(NATIVE_GROUP_CONTROLS) do
        local control = _G[controlName]
        if control and type(control.SetHidden) == "function" then
            control:SetHidden(hidden)
            MOD.touched = true
        end
    end

    MOD.nativeHidden = hidden
end

function MOD.ApplyVisibility(customFramesVisible)
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
    if SCENE_MANAGER then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
            MOD.Refresh()
        end)
    end

    MOD.Refresh()
end
