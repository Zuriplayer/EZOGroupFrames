EZOGroupFrames_Menu = EZOGroupFrames_Menu or {}

local MENU = EZOGroupFrames_Menu

local function BuildOptions()
    if EZOGroupFrames_LAM and EZOGroupFrames_LAM.GetSortedOptions then
        return EZOGroupFrames_LAM.GetSortedOptions()
    end
    return {}
end

function MENU.Init()
    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local panelData = {
        type = "panel",
        name = "EZOGroupFrames",
        displayName = "E|cB040FFZ|rOGroupFrames",
        author = EZOGroupFrames.AUTHOR,
        version = EZOGroupFrames.ADDON_VERSION,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local panel = LAM:RegisterAddonPanel("EZOGroupFrames_Panel", panelData)
    EZOGroupFrames._lamPanel = panel
    _G.EZOGroupFrames_Panel = panel

    LAM:RegisterOptionControls("EZOGroupFrames_Panel", BuildOptions())
end
