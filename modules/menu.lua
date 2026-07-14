EZOGroupFrames_Menu = EZOGroupFrames_Menu or {}

local MENU = EZOGroupFrames_Menu
local ADDON_NAME = "EZOGroupFrames"
local PANEL_ID = "EZOGroupFrames_Panel"

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
        name = ADDON_NAME,
        displayName = "E|cB040FFZ|rOGroupFrames",
        author = EZOGroupFrames.AUTHOR,
        version = EZOGroupFrames.ADDON_VERSION,
        ezoStage = "beta",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options = BuildOptions()
    if EZOCore and type(EZOCore.RegisterSettingsPanel) == "function" then
        local registered = EZOCore:RegisterSettingsPanel(ADDON_NAME, PANEL_ID, panelData, options)
        if registered then
            EZOGroupFrames.ezoSettingsRegistered = true
            return
        end
    end

    local panel = LAM:RegisterAddonPanel(PANEL_ID, panelData)
    EZOGroupFrames._lamPanel = panel
    _G.EZOGroupFrames_Panel = panel

    LAM:RegisterOptionControls(PANEL_ID, options)
end
