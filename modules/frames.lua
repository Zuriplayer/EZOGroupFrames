EZOGroupFrames_Frames = EZOGroupFrames_Frames or {}

local FRAMES = EZOGroupFrames_Frames
local ROW_HEIGHT = 24
local MAX_ROWS = 12

local function IsEnabled()
    return EZOGroupFrames
        and EZOGroupFrames.sv
        and EZOGroupFrames.sv.frames
        and EZOGroupFrames.sv.frames.enabled == true
end

local function ShouldShow(members)
    if not IsEnabled() then
        return false
    end
    if EZOGroupFrames_HudVisibility and not EZOGroupFrames_HudVisibility.IsHudScene() then
        return false
    end
    if EZOGroupFrames.sv.frames.showOnlyInGroup ~= false and #members == 0 then
        return false
    end
    return true
end

local function CreateRow(parent, index)
    local row = WINDOW_MANAGER:CreateControl("EZOGroupFrames_Row" .. tostring(index), parent, CT_CONTROL)
    row:SetDimensions(220, ROW_HEIGHT)
    row:SetAnchor(TOPLEFT, parent, TOPLEFT, 8, 8 + ((index - 1) * (ROW_HEIGHT + 3)))

    row.bg = WINDOW_MANAGER:CreateControl(nil, row, CT_BACKDROP)
    row.bg:SetAnchorFill(row)
    row.bg:SetCenterColor(0, 0, 0, 0.45)
    row.bg:SetEdgeColor(0.45, 0.25, 0.8, 0.85)
    row.bg:SetEdgeTexture(nil, 1, 1, 1)

    row.name = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.name:SetAnchor(LEFT, row, LEFT, 8, 0)
    row.name:SetFont("ZoFontGameSmall")
    row.name:SetColor(1, 1, 1, 1)

    row.health = WINDOW_MANAGER:CreateControl(nil, row, CT_LABEL)
    row.health:SetAnchor(RIGHT, row, RIGHT, -8, 0)
    row.health:SetFont("ZoFontGameSmall")
    row.health:SetColor(0.65, 1, 0.65, 1)

    return row
end

local function EnsureControls()
    if FRAMES.container then
        return
    end

    local container = WINDOW_MANAGER:CreateTopLevelWindow("EZOGroupFrames_Container")
    container:SetDimensions(236, 336)
    container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 260, 260)
    container:SetMovable(true)
    container:SetMouseEnabled(true)
    container:SetClampedToScreen(true)
    container:SetHidden(true)

    container.title = WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
    container.title:SetAnchor(TOPLEFT, container, TOPLEFT, 8, -18)
    container.title:SetFont("ZoFontGameSmall")
    container.title:SetColor(0.8, 0.6, 1, 1)
    container.title:SetText(GetString(EZO_GF_STATUS_GROUP))

    FRAMES.container = container
    FRAMES.rows = {}
    for i = 1, MAX_ROWS do
        FRAMES.rows[i] = CreateRow(container, i)
    end

    if EZOGroupFrames_HudVisibility and EZOGroupFrames_HudVisibility.Register then
        EZOGroupFrames_HudVisibility.Register(container, FRAMES.Refresh)
    end
end

function FRAMES.Refresh()
    EnsureControls()

    local members = {}
    if EZOGroupFrames_GroupState and EZOGroupFrames_GroupState.GetMembers then
        members = EZOGroupFrames_GroupState.GetMembers()
    end

    local show = ShouldShow(members)
    FRAMES.container:SetHidden(not show)
    if not show then
        return
    end

    local settings = EZOGroupFrames.sv.frames
    FRAMES.container:SetScale(tonumber(settings.scale) or 1)
    FRAMES.container:SetMovable(settings.locked == false)
    FRAMES.container:SetMouseEnabled(settings.locked == false)

    for i = 1, MAX_ROWS do
        local row = FRAMES.rows[i]
        local member = members[i]
        row:SetHidden(member == nil)
        if member then
            row.name:SetText(member.name or member.unitTag or "")
            row.health:SetText(member.healthPercent and (tostring(member.healthPercent) .. "%") or "")
        end
    end
end

function FRAMES.Init()
    EnsureControls()
    FRAMES.Refresh()
end
