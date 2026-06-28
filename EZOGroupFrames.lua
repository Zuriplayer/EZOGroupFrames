EZOGroupFrames = EZOGroupFrames or {}

local ADDON = EZOGroupFrames

local DEFAULTS = {
    general = {
        language = "auto",
        debug = false,
    },
    frames = {
        enabled = true,
        locked = true,
        scale = 1.0,
        x = 260,
        y = 260,
        showOnlyInGroup = true,
        hideNativeWhenActive = true,
        showLevel = false,
        showClass = false,
        tankColor = { r = 0.88, g = 0.28, b = 0.22, a = 1.0 },
        healerColor = { r = 0.20, g = 0.78, b = 0.34, a = 1.0 },
        damageColor = { r = 0.32, g = 0.52, b = 1.0, a = 1.0 },
        unknownColor = { r = 0.72, g = 0.72, b = 0.78, a = 1.0 },
    },
}

local function DeepCopyDefaults(src)
    local out = {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            out[k] = DeepCopyDefaults(v)
        else
            out[k] = v
        end
    end
    return out
end

function ADDON.GetDefaultLanguage()
    local lang = "en"
    if type(GetCVar) == "function" then
        lang = GetCVar("Language.2") or lang
    end
    return (lang == "es") and "es" or "en"
end

function ADDON.GetEffectiveLanguage(lang)
    if lang == "en" or lang == "es" then
        return lang
    end
    return ADDON.GetDefaultLanguage()
end

function ADDON.EnsureDefaults()
    ADDON.sv = ADDON.sv or {}
    for sectionName, defaults in pairs(DEFAULTS) do
        if type(ADDON.sv[sectionName]) ~= "table" then
            ADDON.sv[sectionName] = DeepCopyDefaults(defaults)
        else
            for k, v in pairs(defaults) do
                if ADDON.sv[sectionName][k] == nil then
                    ADDON.sv[sectionName][k] = type(v) == "table" and DeepCopyDefaults(v) or v
                end
            end
        end
    end
end

function ADDON.Print(message)
    if type(d) == "function" then
        d("|cB040FFEZO|rGroupFrames: " .. tostring(message or ""))
    end
end

function ADDON.Refresh()
    if EZOGroupFrames_GroupState and EZOGroupFrames_GroupState.Refresh then
        EZOGroupFrames_GroupState.Refresh()
    end
    if EZOGroupFrames_Frames and EZOGroupFrames_Frames.Refresh then
        EZOGroupFrames_Frames.Refresh()
    end
end

function ADDON.Initialize()
    ADDON.sv = ZO_SavedVars:NewAccountWide("EZOGroupFramesSV", 1, GetWorldName(), DEFAULTS)
    ADDON.EnsureDefaults()

    if EZOGroupFrames_Lang and EZOGroupFrames_Lang.Apply then
        EZOGroupFrames_Lang.Apply(ADDON.sv.general.language)
    end
    if EZOGroupFrames_Menu and EZOGroupFrames_Menu.Init then
        EZOGroupFrames_Menu.Init()
    end
    if EZOGroupFrames_Debug and EZOGroupFrames_Debug.Init then
        EZOGroupFrames_Debug.Init()
    end
    if EZOGroupFrames_GroupState and EZOGroupFrames_GroupState.Init then
        EZOGroupFrames_GroupState.Init()
    end
    if EZOGroupFrames_NativeFrames and EZOGroupFrames_NativeFrames.Init then
        EZOGroupFrames_NativeFrames.Init()
    end
    if EZOGroupFrames_Frames and EZOGroupFrames_Frames.Init then
        EZOGroupFrames_Frames.Init()
    end
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= "EZOGroupFrames" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("EZOGroupFrames_Loaded", EVENT_ADD_ON_LOADED)
    ADDON.Initialize()
end

EVENT_MANAGER:RegisterForEvent("EZOGroupFrames_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
