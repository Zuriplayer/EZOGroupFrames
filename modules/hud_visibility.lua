EZOGroupFrames_HudVisibility = EZOGroupFrames_HudVisibility or {}

function EZOGroupFrames_HudVisibility.IsHudScene()
    if not SCENE_MANAGER then
        return true
    end
    return SCENE_MANAGER:IsShowing("hud") or SCENE_MANAGER:IsShowing("hudui")
end

function EZOGroupFrames_HudVisibility.Register(control, refreshCallback)
    if control and ZO_SimpleSceneFragment and HUD_SCENE and HUD_UI_SCENE then
        local fragment = ZO_SimpleSceneFragment:New(control)
        HUD_SCENE:AddFragment(fragment)
        HUD_UI_SCENE:AddFragment(fragment)
        EZOGroupFrames_HudVisibility.fragment = fragment
    end

    if SCENE_MANAGER and type(refreshCallback) == "function" then
        SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
            refreshCallback()
        end)
    end
end
