EZOGroupFrames_LAM = EZOGroupFrames_LAM or {}

local REG = EZOGroupFrames_LAM
REG._sections = REG._sections or {}

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

local function RegisterBaseSections()
    if REG._baseSectionsRegistered then
        return
    end
    REG._baseSectionsRegistered = true

    REG.RegisterSection("general", 1, function()
        local addon = EZOGroupFrames
        return {
            { type = "header", name = GetString(EZO_GF_MENU_GENERAL) },
            {
                type = "dropdown",
                name = GetString(EZO_GF_OPTION_LANGUAGE),
                tooltip = GetString(EZO_GF_OPTION_LANGUAGE_TOOLTIP),
                choices = { GetString(EZO_GF_OPTION_LANGUAGE_AUTO), "English", "Espanol" },
                choicesValues = { "auto", "en", "es" },
                getFunc = function() return addon.sv.general.language or "auto" end,
                setFunc = function(value)
                    addon.sv.general.language = tostring(value or "auto")
                    if EZOGroupFrames_Lang and EZOGroupFrames_Lang.Apply then
                        EZOGroupFrames_Lang.Apply(addon.sv.general.language)
                    end
                end,
                default = "auto",
                width = "half",
            },
        }
    end)

    REG.RegisterSection("frames", 10, function()
        local addon = EZOGroupFrames
        return {
            { type = "header", name = GetString(EZO_GF_MENU_FRAMES) },
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
                getFunc = function() return addon.sv.frames.locked ~= false end,
                setFunc = function(value) addon.sv.frames.locked = value ~= false; RefreshFrames() end,
                default = true,
            },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_FRAMES_GROUP_ONLY),
                getFunc = function() return addon.sv.frames.showOnlyInGroup ~= false end,
                setFunc = function(value) addon.sv.frames.showOnlyInGroup = value ~= false; RefreshFrames() end,
                default = true,
            },
            {
                type = "slider",
                name = GetString(EZO_GF_OPTION_FRAMES_SCALE),
                min = 0.7,
                max = 1.6,
                step = 0.05,
                decimals = 2,
                getFunc = function() return tonumber(addon.sv.frames.scale) or 1 end,
                setFunc = function(value) addon.sv.frames.scale = tonumber(value) or 1; RefreshFrames() end,
                default = 1.0,
            },
            { type = "header", name = GetString(EZO_GF_OPTION_DEBUG) },
            {
                type = "checkbox",
                name = GetString(EZO_GF_OPTION_DEBUG_MODE),
                tooltip = GetString(EZO_GF_OPTION_DEBUG_MODE_TOOLTIP),
                getFunc = function() return addon.sv.general.debug == true end,
                setFunc = function(value) addon.sv.general.debug = value == true end,
                default = false,
            },
        }
    end)
end

RegisterBaseSections()
