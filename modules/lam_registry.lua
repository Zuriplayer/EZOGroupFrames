EZOGroupFrames_LAM = EZOGroupFrames_LAM or {}

local REG = EZOGroupFrames_LAM
REG._sections = REG._sections or {}

local INFO_HEADER_TEXTURE = "EsoUI/Art/Miscellaneous/help_icon.dds"

function REG.CreateInfoHeader(name, tooltip)
    return {
        type = "header",
        name = zo_strformat(
            "<<1>> |cB040FF|t26:26:<<2>>:inheritcolor|t|r",
            tostring(name or ""),
            INFO_HEADER_TEXTURE
        ),
        tooltip = tooltip,
    }
end

function REG.RegisterSection(name, order, provider)
    REG._sections[name] = { order = order or 100, provider = provider }
end

function REG.GetSortedOptions()
    local sections = {}
    for name, section in pairs(REG._sections) do
        sections[#sections + 1] = { name = name, order = section.order, provider = section.provider }
    end
    table.sort(sections, function(a, b) return a.order < b.order end)

    local options = {}
    for _, section in ipairs(sections) do
        local ok, provided = pcall(section.provider)
        if ok and type(provided) == "table" then
            for _, option in ipairs(provided) do
                options[#options + 1] = option
            end
        end
    end
    return options
end

local function RefreshFrames()
    if EZOGroupFrames_Frames and EZOGroupFrames_Frames.Refresh then
        EZOGroupFrames_Frames.Refresh()
    end
end

local function RefreshEzoStatus()
    RefreshFrames()
    if EZOGroupFrames_EZOCorePerformance
        and type(EZOGroupFrames_EZOCorePerformance.RefreshPublisher) == "function" then
        EZOGroupFrames_EZOCorePerformance.RefreshPublisher()
    end
end

local function GetColor(settings, key, fallback)
    local color = settings[key]
    if type(color) ~= "table" then
        color = fallback
    end
    return color.r or fallback.r, color.g or fallback.g, color.b or fallback.b, color.a or fallback.a or 1
end

local function SetColor(settings, key, r, g, b, a)
    settings[key] = { r = r, g = g, b = b, a = a or 1 }
    RefreshFrames()
end

local function RegisterBaseSections()
    if REG._baseSectionsRegistered then
        return
    end
    REG._baseSectionsRegistered = true

    REG.RegisterSection("general", 1, function()
        local addon = EZOGroupFrames
        return {
            REG.CreateInfoHeader(GetString(EZO_GF_MENU_GENERAL), GetString(EZO_GF_MENU_GENERAL_TOOLTIP)),
            {
                type = "dropdown",
                name = GetString(EZO_GF_OPTION_LANGUAGE),
                tooltip = GetString(EZO_GF_OPTION_LANGUAGE_TOOLTIP),
                choices = {
                    GetString(EZO_GF_OPTION_LANGUAGE_AUTO),
                    "English",
                    "Español",
                },
                choicesValues = { "auto", "en", "es" },
                getFunc = function()
                    local value = addon.sv.general.language
                        or (addon.GetDefaultLanguage and addon.GetDefaultLanguage())
                        or "auto"
                    if value == "inherit" then value = "auto" end
                    return value
                end,
                setFunc = function(value)
                    addon.sv.general.language = tostring(
                        value or (addon.GetDefaultLanguage and addon.GetDefaultLanguage()) or "auto"
                    )
                    if addon.sv.general.language == "inherit" then
                        addon.sv.general.language = "auto"
                    end
                    if addon.ApplyLanguagePreference then
                        addon.ApplyLanguagePreference(addon.sv.general.language)
                    elseif EZOGroupFrames_Lang and EZOGroupFrames_Lang.Apply then
                        EZOGroupFrames_Lang.Apply(addon.sv.general.language)
                    end
                end,
                disabled = function()
                    return addon.IsLanguageManagedByEZOCore and addon.IsLanguageManagedByEZOCore()
                end,
                default = (addon.GetDefaultLanguage and addon.GetDefaultLanguage()) or "auto",
                width = "half",
            },
        }
    end)

    REG.RegisterSection("frames", 10, function()
        local addon = EZOGroupFrames
        return {
            REG.CreateInfoHeader(GetString(EZO_GF_MENU_FRAMES), GetString(EZO_GF_MENU_FRAMES_TOOLTIP)),
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_FRAMES_ENABLE),
                tooltip = GetString(EZO_GF_OPTION_FRAMES_ENABLE_TOOLTIP),
                getFunc = function() return addon.sv.frames.enabled == true end,
                setFunc = function(value) addon.sv.frames.enabled = value == true; RefreshFrames() end,
                default = false,
            },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_FRAMES_LOCK),
                tooltip = GetString(EZO_GF_OPTION_FRAMES_LOCK_TOOLTIP),
                getFunc = function() return addon.sv.frames.locked ~= false end,
                setFunc = function(value) addon.sv.frames.locked = value ~= false; RefreshFrames() end,
                default = true,
            },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_FRAMES_GROUP_ONLY),
                tooltip = GetString(EZO_GF_OPTION_FRAMES_GROUP_ONLY_TOOLTIP),
                getFunc = function() return addon.sv.frames.showOnlyInGroup ~= false end,
                setFunc = function(value) addon.sv.frames.showOnlyInGroup = value ~= false; RefreshFrames() end,
                default = true,
            },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_HIDE_NATIVE),
                tooltip = GetString(EZO_GF_OPTION_HIDE_NATIVE_TOOLTIP),
                getFunc = function() return addon.sv.frames.hideNativeWhenActive ~= false end,
                setFunc = function(value)
                    addon.sv.frames.hideNativeWhenActive = value ~= false
                    if EZOGroupFrames_NativeFrames and EZOGroupFrames_NativeFrames.Refresh then
                        EZOGroupFrames_NativeFrames.Refresh()
                    end
                    RefreshFrames()
                end,
                default = true,
            },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_SHOW_LEVEL),
                tooltip = GetString(EZO_GF_OPTION_SHOW_LEVEL_TOOLTIP),
                getFunc = function() return addon.sv.frames.showLevel == true end,
                setFunc = function(value) addon.sv.frames.showLevel = value == true; RefreshFrames() end,
                default = false,
            },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_SHOW_CLASS),
                tooltip = GetString(EZO_GF_OPTION_SHOW_CLASS_TOOLTIP),
                getFunc = function() return addon.sv.frames.showClass == true end,
                setFunc = function(value) addon.sv.frames.showClass = value == true; RefreshFrames() end,
                default = false,
            },
            {
                type = "slider",
                name = GetString(EZO_GF_OPTION_FRAMES_SCALE),
                tooltip = GetString(EZO_GF_OPTION_FRAMES_SCALE_TOOLTIP),
                min = 0.7,
                max = 1.6,
                step = 0.05,
                decimals = 2,
                getFunc = function() return tonumber(addon.sv.frames.scale) or 1 end,
                setFunc = function(value) addon.sv.frames.scale = tonumber(value) or 1; RefreshFrames() end,
                default = 1.0,
            },
            {
                type = "colorpicker",
                name = GetString(EZO_GF_OPTION_COLOR_TANK),
                tooltip = GetString(EZO_GF_OPTION_COLOR_TANK_TOOLTIP),
                getFunc = function()
                    return GetColor(addon.sv.frames, "tankColor", { r = 0.88, g = 0.28, b = 0.22, a = 1 })
                end,
                setFunc = function(r, g, b, a) SetColor(addon.sv.frames, "tankColor", r, g, b, a) end,
                default = { r = 0.88, g = 0.28, b = 0.22, a = 1 },
            },
            {
                type = "colorpicker",
                name = GetString(EZO_GF_OPTION_COLOR_HEALER),
                tooltip = GetString(EZO_GF_OPTION_COLOR_HEALER_TOOLTIP),
                getFunc = function()
                    return GetColor(addon.sv.frames, "healerColor", { r = 0.20, g = 0.78, b = 0.34, a = 1 })
                end,
                setFunc = function(r, g, b, a) SetColor(addon.sv.frames, "healerColor", r, g, b, a) end,
                default = { r = 0.20, g = 0.78, b = 0.34, a = 1 },
            },
            {
                type = "colorpicker",
                name = GetString(EZO_GF_OPTION_COLOR_DAMAGE),
                tooltip = GetString(EZO_GF_OPTION_COLOR_DAMAGE_TOOLTIP),
                getFunc = function()
                    return GetColor(addon.sv.frames, "damageColor", { r = 0.32, g = 0.52, b = 1.0, a = 1 })
                end,
                setFunc = function(r, g, b, a) SetColor(addon.sv.frames, "damageColor", r, g, b, a) end,
                default = { r = 0.32, g = 0.52, b = 1.0, a = 1 },
            },
            {
                type = "colorpicker",
                name = GetString(EZO_GF_OPTION_COLOR_UNKNOWN),
                tooltip = GetString(EZO_GF_OPTION_COLOR_UNKNOWN_TOOLTIP),
                getFunc = function()
                    return GetColor(addon.sv.frames, "unknownColor", { r = 0.72, g = 0.72, b = 0.78, a = 1 })
                end,
                setFunc = function(r, g, b, a) SetColor(addon.sv.frames, "unknownColor", r, g, b, a) end,
                default = { r = 0.72, g = 0.72, b = 0.78, a = 1 },
            },
        }
    end)

    REG.RegisterSection("ezoStatus", 15, function()
        local addon = EZOGroupFrames
        return {
            REG.CreateInfoHeader(GetString(EZO_GF_MENU_EZO_STATUS), GetString(EZO_GF_MENU_EZO_STATUS_TOOLTIP)),
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_SHOW_EZO_STATUS),
                tooltip = GetString(EZO_GF_OPTION_SHOW_EZO_STATUS_TOOLTIP),
                getFunc = function() return addon.sv.ezoStatus.showPlayerStatus == true end,
                setFunc = function(value)
                    addon.sv.ezoStatus.showPlayerStatus = value == true
                    RefreshEzoStatus()
                end,
                default = false,
            },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_SHOW_PING),
                tooltip = GetString(EZO_GF_OPTION_SHOW_PING_TOOLTIP),
                getFunc = function() return addon.sv.ezoStatus.showPing == true end,
                setFunc = function(value) addon.sv.ezoStatus.showPing = value == true; RefreshEzoStatus() end,
                disabled = function() return addon.sv.ezoStatus.showPlayerStatus ~= true end,
                default = false,
            },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_SHOW_FPS),
                tooltip = GetString(EZO_GF_OPTION_SHOW_FPS_TOOLTIP),
                getFunc = function() return addon.sv.ezoStatus.showFps == true end,
                setFunc = function(value) addon.sv.ezoStatus.showFps = value == true; RefreshEzoStatus() end,
                disabled = function() return addon.sv.ezoStatus.showPlayerStatus ~= true end,
                default = false,
            },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_SHOW_PRIVACY),
                tooltip = GetString(EZO_GF_OPTION_SHOW_PRIVACY_TOOLTIP),
                getFunc = function() return addon.sv.ezoStatus.showPrivacy == true end,
                setFunc = function(value) addon.sv.ezoStatus.showPrivacy = value == true; RefreshEzoStatus() end,
                disabled = function() return addon.sv.ezoStatus.showPlayerStatus ~= true end,
                default = false,
            },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_SHARE_PERFORMANCE),
                tooltip = GetString(EZO_GF_OPTION_SHARE_PERFORMANCE_TOOLTIP),
                getFunc = function() return addon.sv.ezoStatus.sharePerformance == true end,
                setFunc = function(value)
                    addon.sv.ezoStatus.sharePerformance = value == true
                    RefreshEzoStatus()
                end,
                default = false,
            },
        }
    end)

    REG.RegisterSection("debug", 20, function()
        local addon = EZOGroupFrames
        return {
            REG.CreateInfoHeader(GetString(EZO_GF_OPTION_DEBUG), GetString(EZO_GF_OPTION_DEBUG_TOOLTIP)),
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_DEBUG_MODE),
                tooltip = GetString(EZO_GF_OPTION_DEBUG_MODE_TOOLTIP),
                getFunc = function() return addon.sv.general.debug == true end,
                setFunc = function(value)
                    addon.sv.general.debug = value == true
                    if addon.sv.general.debug ~= true
                        and EZOGroupFrames_DebugSimulation
                        and EZOGroupFrames_DebugSimulation.IsActive
                        and EZOGroupFrames_DebugSimulation.IsActive()
                    then
                        EZOGroupFrames_DebugSimulation.SetActive(false)
                    end
                end,
                default = false,
            },
            {
                type = "button",
                name = GetString(EZO_GF_OPTION_DEBUG_SIMULATED_GROUP),
                tooltip = GetString(EZO_GF_OPTION_DEBUG_SIMULATED_GROUP_TOOLTIP),
                func = function()
                    if EZOGroupFrames_DebugSimulation and EZOGroupFrames_DebugSimulation.Toggle then
                        EZOGroupFrames_DebugSimulation.Toggle()
                    end
                    if EZOGroupFrames_Debug and EZOGroupFrames_Debug.ShowViewer then
                        EZOGroupFrames_Debug.ShowViewer()
                    end
                end,
                disabled = function() return addon.sv.general.debug ~= true end,
                width = "full",
            },
        }
    end)
end

RegisterBaseSections()
