EZOGroupFrames = EZOGroupFrames or {}

local ADDON = EZOGroupFrames
local LANGUAGE_INHERIT = "inherit"
local LANGUAGE_AUTO = "auto"
local languageCallbackRegistered = false
local ezocoreRegistered = false
local layoutSurfaceRegistered = false
local debugControllerRegistered = false

local DEFAULTS = {
    general = {
        language = LANGUAGE_AUTO,
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
    ezoStatus = {
        showPlayerStatus = false,
        showPing = false,
        showFps = false,
        showPrivacy = false,
        sharePerformance = false,
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
    return LANGUAGE_AUTO
end

function ADDON.GetClientLanguage()
    local lang = "en"
    if type(GetCVar) == "function" then
        lang = GetCVar("Language.2") or lang
    end
    return (lang == "es") and "es" or "en"
end

function ADDON.GetEffectiveLanguage(lang)
    if ADDON.IsLanguageManagedByEZOCore and ADDON.IsLanguageManagedByEZOCore() then
        local ok, inherited = pcall(function()
            return EZOCore:GetLanguage()
        end)
        if ok and (inherited == "es" or inherited == "en") then
            return inherited
        end
    end
    if lang == LANGUAGE_INHERIT then
        lang = LANGUAGE_AUTO
    end
    if lang == "en" or lang == "es" then
        return lang
    end
    return ADDON.GetClientLanguage()
end

function ADDON.IsLanguageManagedByEZOCore()
    if not (EZOCore and type(EZOCore.IsLanguageGloballyManaged) == "function") then
        return false
    end
    local ok, managed = pcall(function()
        return EZOCore:IsLanguageGloballyManaged()
    end)
    return ok and managed == true
end

function ADDON.ApplyLanguagePreference(lang)
    if EZOGroupFrames_Lang and EZOGroupFrames_Lang.Apply then
        EZOGroupFrames_Lang.Apply(lang or ADDON.GetDefaultLanguage())
    end
end

function ADDON.RegisterEZOCoreLanguageCallback()
    if languageCallbackRegistered
        or not (EZOCore and type(EZOCore.RegisterCallback) == "function") then
        return false
    end

    local eventName = EZOCore.EVENT_LANGUAGE_CHANGED or "EZO_CORE_LANGUAGE_CHANGED"
    local ok, result = pcall(function()
        return EZOCore:RegisterCallback(eventName, function()
            if ADDON.sv and ADDON.sv.general then
                ADDON.ApplyLanguagePreference(ADDON.sv.general.language or ADDON.GetDefaultLanguage())
                ADDON.Refresh()
            end
        end)
    end)
    languageCallbackRegistered = ok and result == true
    return languageCallbackRegistered
end

function ADDON.RegisterWithEZOCore()
    if ezocoreRegistered
        or not (EZOCore and type(EZOCore.RegisterAddon) == "function") then
        return false
    end

    local ok, result = pcall(function()
        return EZOCore:RegisterAddon({
            id = "ezogroupframes",
            name = ADDON.ADDON_NAME or "EZOGroupFrames",
            version = ADDON.ADDON_VERSION or "0.0.0",
            addOnVersion = 115,
            apiVersion = 1,
            capabilities = {
                "family.language.consumer",
                "family.debug.controller",
                "family.layout.consumer",
                "family.settings.consumer",
                "group.activityState.consumer",
                "group.performanceState.consumer",
                "group.performanceState.provider",
                "group.frames.visualHints",
            },
        })
    end)

    ezocoreRegistered = ok and result == true
    return ezocoreRegistered
end

function ADDON.SetDebugModeEnabled(enabled)
    if not (ADDON.sv and ADDON.sv.general) then
        return false
    end

    ADDON.sv.general.debug = enabled == true
    if not ADDON.sv.general.debug
        and EZOGroupFrames_DebugSimulation
        and EZOGroupFrames_DebugSimulation.IsActive
        and EZOGroupFrames_DebugSimulation.IsActive()
    then
        EZOGroupFrames_DebugSimulation.SetActive(false)
    end
    return ADDON.sv.general.debug == (enabled == true)
end

function ADDON.RegisterDebugWithEZOCore()
    if debugControllerRegistered
        or not (EZOCore and type(EZOCore.GetService) == "function") then
        return false
    end

    local service = EZOCore:GetService("family.debug", 1)
    if not service or type(service.RegisterController) ~= "function" then
        return false
    end

    local ok, result = pcall(function()
        return service:RegisterController({
            id = "ezogroupframes.debug",
            addonId = "ezogroupframes",
            addonName = "EZOGroupFrames",
            name = function() return GetString(EZO_GF_OPTION_DEBUG_MODE) end,
            isEnabled = function()
                return ADDON.sv and ADDON.sv.general and ADDON.sv.general.debug == true
            end,
            setEnabled = function(enabled)
                return ADDON.SetDebugModeEnabled(enabled == true)
            end,
        })
    end)

    debugControllerRegistered = ok and result == true
    return debugControllerRegistered
end

function ADDON.RegisterLayoutWithEZOCore()
    if layoutSurfaceRegistered
        or not (EZOCore and type(EZOCore.GetService) == "function") then
        return false
    end

    local service = EZOCore:GetService("family.layout", 1)
    if not service or type(service.RegisterSurface) ~= "function" then
        return false
    end

    local ok, result = pcall(function()
        return service:RegisterSurface({
            id = "ezogroupframes.frames",
            addonId = "ezogroupframes",
            addonName = "EZOGroupFrames",
            name = function() return GetString(EZO_GF_MENU_FRAMES) end,
            tooltip = function() return GetString(EZO_GF_MENU_FRAMES_TOOLTIP) end,
            setEditMode = function(enabled)
                EZOGroupFrames_Frames.SetLayoutEditMode(enabled)
                return EZOGroupFrames_Frames.IsLayoutEditMode() == (enabled == true)
            end,
            isEditMode = function()
                return EZOGroupFrames_Frames.IsLayoutEditMode()
            end,
        })
    end)

    layoutSurfaceRegistered = ok and result == true
    return layoutSurfaceRegistered
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

    ADDON.ApplyLanguagePreference(ADDON.sv.general.language)
    ADDON.RegisterEZOCoreLanguageCallback()
    ADDON.RegisterWithEZOCore()
    ADDON.RegisterDebugWithEZOCore()
    if EZOGroupFrames_Menu and EZOGroupFrames_Menu.Init then
        EZOGroupFrames_Menu.Init()
    end
    if EZOGroupFrames_Debug and EZOGroupFrames_Debug.Init then
        EZOGroupFrames_Debug.Init()
    end
    if EZOGroupFrames_GroupState and EZOGroupFrames_GroupState.Init then
        EZOGroupFrames_GroupState.Init()
    end
    if EZOGroupFrames_EZOCorePerformance and EZOGroupFrames_EZOCorePerformance.Init then
        EZOGroupFrames_EZOCorePerformance.Init()
    end
    if EZOGroupFrames_NativeFrames and EZOGroupFrames_NativeFrames.Init then
        EZOGroupFrames_NativeFrames.Init()
    end
    if EZOGroupFrames_Frames and EZOGroupFrames_Frames.Init then
        EZOGroupFrames_Frames.Init()
    end
    ADDON.RegisterLayoutWithEZOCore()
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= "EZOGroupFrames" then
        return
    end
    EVENT_MANAGER:UnregisterForEvent("EZOGroupFrames_Loaded", EVENT_ADD_ON_LOADED)
    ADDON.Initialize()
end

EVENT_MANAGER:RegisterForEvent("EZOGroupFrames_Loaded", EVENT_ADD_ON_LOADED, OnAddOnLoaded)
