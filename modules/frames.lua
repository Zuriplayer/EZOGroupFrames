EZOGroupFrames_Frames = EZOGroupFrames_Frames or {}

local FRAMES = EZOGroupFrames_Frames

local BAR_TEXTURE = "EsoUI/Art/UnitAttributeVisualizer/attributeBar_dynamic_fill.dds"
local BAR_CAP_TEXTURE = "EsoUI/Art/Miscellaneous/progressbar_genericfill_leadingedge_blunt.dds"
local ROWS_PER_BLOCK = 4
local MAX_ROWS = 12
local ROW_WIDTH = 260
local ROW_HEIGHT = 42
local BLOCK_GAP = 18
local ROW_GAP = 6
local TEXT_INSET = 12
local CONTAINER_NAME = "EZOGroupFrames_Container"
local ROW_NAME_PREFIX = "EZOGroupFrames_Row"
local LEADER_ICON_TEXTURE = "EsoUI/Art/Icons/MapKey/mapkey_groupleader.dds"
local CONSUMED_BAR_COLOR = { 0.20, 0.20, 0.22, 0.88 }
local FILL_SHEEN_COLOR = { 1.0, 1.0, 1.0, 0.12 }
local INNER_SHADE_COLOR = { 0, 0, 0, 0.16 }

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
    if EZOGroupFrames_DebugSimulation and EZOGroupFrames_DebugSimulation.IsActive and EZOGroupFrames_DebugSimulation.IsActive() then
        return true
    end
    if EZOGroupFrames.sv.frames.showOnlyInGroup ~= false and #members == 0 then
        return false
    end
    return true
end

function FRAMES.IsShowing()
    return FRAMES.container and FRAMES.container:IsHidden() == false
end

function FRAMES.IsFunctionallyShowing()
    return FRAMES.functionalVisible == true
end

function FRAMES.IsLayoutEditMode()
    return FRAMES.layoutEditMode == true
end

function FRAMES.SetLayoutEditMode(enabled)
    if not IsEnabled() then
        FRAMES.layoutEditMode = false
        FRAMES.Refresh()
        return false
    end
    if FRAMES.layoutEditMode == (enabled == true) then
        return FRAMES.layoutEditMode
    end
    FRAMES.layoutEditMode = enabled == true
    FRAMES.Refresh()
    return FRAMES.layoutEditMode
end

local function GetRoleColor(role)
    local settings = EZOGroupFrames.sv.frames
    local color = settings.unknownColor
    if role == LFG_ROLE_TANK then
        color = settings.tankColor
    elseif role == LFG_ROLE_HEAL then
        color = settings.healerColor
    elseif role == LFG_ROLE_DPS then
        color = settings.damageColor
    end
    if type(color) ~= "table" then
        return 0.72, 0.72, 0.78, 1
    end
    return color.r or 1, color.g or 1, color.b or 1, color.a or 1
end

local function GetRoleIcon(role)
    if role == LFG_ROLE_TANK then
        return "EsoUI/Art/LFG/Gamepad/lfg_roleicon_tank.dds"
    end
    if role == LFG_ROLE_HEAL then
        return "EsoUI/Art/LFG/Gamepad/lfg_roleicon_healer.dds"
    end
    if role == LFG_ROLE_DPS then
        return "EsoUI/Art/LFG/Gamepad/lfg_roleicon_dps.dds"
    end
    return nil
end

local function FormatNumber(value)
    value = tonumber(value) or 0
    if value >= 1000 then
        return string.format("%.1fk", value / 1000)
    end
    return tostring(zo_floor(value))
end

local function CreateStatusBar(name, parent)
    local bar = WINDOW_MANAGER:CreateControl(name, parent, CT_STATUSBAR)
    bar:SetMouseEnabled(false)
    bar:SetTexture(BAR_TEXTURE)
    bar:SetOrientation(ORIENTATION_HORIZONTAL)
    bar:SetMinMax(0, 1)
    bar:SetValue(1)
    if type(bar.SetTextureCoords) == "function" then
        bar:SetTextureCoords(0, 1, 0, 0.53125)
    end
    if type(bar.SetBarAlignment) == "function" and BAR_ALIGNMENT_NORMAL then
        bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
    end
    return bar
end

local function CreateLabel(parent, font)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(font or "ZoFontGameSmall")
    label:SetColor(0.98, 0.98, 0.98, 0.96)
    label:SetMouseEnabled(false)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function CreateCap(parent, mirrored)
    local texture = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
    texture:SetMouseEnabled(false)
    texture:SetTexture(BAR_CAP_TEXTURE)
    if mirrored and type(texture.SetTextureCoords) == "function" then
        texture:SetTextureCoords(1, 0, 0, 1)
    end
    return texture
end

local function CreateFlatTexture(parent, color)
    local texture = WINDOW_MANAGER:CreateControl(nil, parent, CT_TEXTURE)
    texture:SetMouseEnabled(false)
    texture:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
    texture:SetColor(unpack(color))
    return texture
end

local function SetOverlayDrawOrder(control, level)
    if not control then
        return
    end
    if type(control.SetDrawTier) == "function" and DT_HIGH then
        control:SetDrawTier(DT_HIGH)
    end
    if type(control.SetDrawLayer) == "function" and DL_OVERLAY then
        control:SetDrawLayer(DL_OVERLAY)
    end
    if type(control.SetDrawLevel) == "function" then
        control:SetDrawLevel(level or 5)
    end
end

local function GetNamedControl(name)
    if _G and _G[name] then
        return _G[name]
    end
    if WINDOW_MANAGER and type(WINDOW_MANAGER.GetControlByName) == "function" then
        return WINDOW_MANAGER:GetControlByName(name)
    end
    return nil
end

local function CreateRow(parent, index, anonymousName)
    local controlName = anonymousName and nil or ROW_NAME_PREFIX .. tostring(index)
    local row = WINDOW_MANAGER:CreateControl(controlName, parent, CT_CONTROL)
    local rowName = row:GetName()
    if rowName == "" then
        rowName = nil
    end
    local function ChildName(suffix)
        return rowName and rowName .. suffix or nil
    end

    row:SetDimensions(ROW_WIDTH, ROW_HEIGHT)

    row.name = CreateLabel(row, "ZoFontGameSmall")
    row.name:SetAnchor(TOPLEFT, row, TOPLEFT, 8, 0)
    row.name:SetDimensions(172, 17)
    row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    row.roleIcon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.roleIcon:SetAnchor(TOPRIGHT, row, TOPRIGHT, -8, 0)
    row.roleIcon:SetDimensions(18, 18)
    row.roleIcon:SetMouseEnabled(false)
    row.roleIcon:SetHidden(true)

    row.barRoot = WINDOW_MANAGER:CreateControl(nil, row, CT_CONTROL)
    row.barRoot:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 0, 0)
    row.barRoot:SetDimensions(ROW_WIDTH, 24)

    row.consumed = CreateStatusBar(ChildName("_Consumed"), row.barRoot)
    row.fill = CreateStatusBar(ChildName("_Fill"), row.barRoot)
    row.sheen = CreateStatusBar(ChildName("_Sheen"), row.barRoot)
    row.shade = CreateFlatTexture(row.barRoot, INNER_SHADE_COLOR)
    row.consumedLeftCap = CreateCap(row.barRoot, true)
    row.consumedRightCap = CreateCap(row.barRoot, false)
    row.fillLeftCap = CreateCap(row.barRoot, true)
    row.fillRightCap = CreateCap(row.barRoot, false)

    row.leaderIconBack = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.leaderIconBack:SetAnchor(LEFT, row.barRoot, LEFT, 4, 0)
    row.leaderIconBack:SetDimensions(24, 20)
    row.leaderIconBack:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
    row.leaderIconBack:SetColor(0, 0, 0, 0.62)
    row.leaderIconBack:SetMouseEnabled(false)
    row.leaderIconBack:SetHidden(true)
    SetOverlayDrawOrder(row.leaderIconBack, 8)

    row.leaderIcon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.leaderIcon:SetAnchor(CENTER, row.leaderIconBack, CENTER, 0, 0)
    row.leaderIcon:SetDimensions(20, 20)
    row.leaderIcon:SetTexture(LEADER_ICON_TEXTURE)
    row.leaderIcon:SetColor(1, 0.92, 0.22, 1)
    row.leaderIcon:SetMouseEnabled(false)
    row.leaderIcon:SetHidden(true)
    SetOverlayDrawOrder(row.leaderIcon, 9)

    row.value = CreateLabel(row.barRoot, "ZoFontGameSmall")
    row.value:SetAnchor(LEFT, row.barRoot, LEFT, TEXT_INSET, 0)
    row.value:SetDimensions(150, 24)
    row.value:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    row.percent = CreateLabel(row.barRoot, "ZoFontGameSmall")
    row.percent:SetAnchor(RIGHT, row.barRoot, RIGHT, -TEXT_INSET, 0)
    row.percent:SetDimensions(66, 24)
    row.percent:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    row.ezoStatus = CreateLabel(row.barRoot, "ZoFontGameSmall")
    row.ezoStatus:SetAnchor(RIGHT, row.percent, LEFT, -4, 0)
    row.ezoStatus:SetDimensions(96, 24)
    row.ezoStatus:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    row.ezoStatus:SetColor(0.82, 0.62, 1, 0.95)
    row.ezoStatus:SetHidden(true)

    return row
end

local function HasCompleteRow(row)
    return row
        and row.name
        and row.roleIcon
        and row.barRoot
        and row.consumed
        and row.fill
        and row.sheen
        and row.shade
        and row.leaderIconBack
        and row.leaderIcon
        and row.value
        and row.percent
        and row.ezoStatus
end

local function AttachOrCreateRow(parent, index)
    local row = GetNamedControl(ROW_NAME_PREFIX .. tostring(index))
    if HasCompleteRow(row) then
        return row
    end
    if row and type(row.SetHidden) == "function" then
        row:SetHidden(true)
    end
    return CreateRow(parent, index, row ~= nil)
end

local function ApplyBarStyle(row)
    local height = 24
    local capSize = height
    local innerWidth = ROW_WIDTH - capSize

    row.consumed:SetAnchor(LEFT, row.barRoot, LEFT, zo_floor(capSize / 2), 0)
    row.consumed:SetDimensions(innerWidth, height)

    row.fill:SetAnchor(LEFT, row.barRoot, LEFT, zo_floor(capSize / 2), 0)
    row.fill:SetDimensions(innerWidth, height)

    row.sheen:SetAnchor(LEFT, row.barRoot, LEFT, zo_floor(capSize / 2), 0)
    row.sheen:SetDimensions(innerWidth, 10)
    row.sheen:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")

    row.shade:SetAnchor(BOTTOMLEFT, row.barRoot, BOTTOMLEFT, zo_floor(capSize / 2), 0)
    row.shade:SetDimensions(innerWidth, 11)

    row.consumedLeftCap:SetAnchor(TOPLEFT, row.barRoot, TOPLEFT, 0, 0)
    row.consumedLeftCap:SetDimensions(capSize, height)
    row.consumedRightCap:SetAnchor(TOPRIGHT, row.barRoot, TOPRIGHT, 0, 0)
    row.consumedRightCap:SetDimensions(capSize, height)
    row.fillLeftCap:SetAnchor(TOPLEFT, row.barRoot, TOPLEFT, 0, 0)
    row.fillLeftCap:SetDimensions(capSize, height)
    row.fillRightCap:SetDimensions(capSize, height)

    row.innerWidth = innerWidth
end

local function UpdateBar(row, member)
    if not HasCompleteRow(row) or not member then
        return
    end

    local current = tonumber(member.currentHealth) or 0
    local maximum = tonumber(member.maxHealth) or 0
    local percent = tonumber(member.healthPercent) or 0
    local ratio = maximum > 0 and zo_clamp(current / maximum, 0, 1) or 0
    local r, g, b = GetRoleColor(member.role)

    row.consumed:SetColor(unpack(CONSUMED_BAR_COLOR))
    row.consumed:SetMinMax(0, math.max(1, maximum))
    row.consumed:SetValue(math.max(1, maximum))
    row.consumedLeftCap:SetColor(unpack(CONSUMED_BAR_COLOR))
    row.consumedRightCap:SetColor(unpack(CONSUMED_BAR_COLOR))

    row.fill:SetColor(r, g, b, 1)
    row.fill:SetMinMax(0, math.max(1, maximum))
    row.fill:SetValue(current)
    row.fillLeftCap:SetColor(r, g, b, 1)
    row.fillRightCap:SetColor(r, g, b, 1)

    row.sheen:SetColor(unpack(FILL_SHEEN_COLOR))
    row.sheen:SetMinMax(0, math.max(1, maximum))
    row.sheen:SetValue(current)
    row.shade:SetColor(unpack(INNER_SHADE_COLOR))

    local hasValue = current > 0 and maximum > 0
    row.fillLeftCap:SetHidden(not hasValue)
    row.fillRightCap:SetHidden(not hasValue)
    if hasValue then
        local capX = zo_floor((row.innerWidth or 1) * ratio)
        row.fillRightCap:ClearAnchors()
        row.fillRightCap:SetAnchor(TOPLEFT, row.barRoot, TOPLEFT, capX, 0)
    end

    row.value:SetText(string.format("%s / %s", FormatNumber(current), FormatNumber(maximum)))
    row.percent:SetText(string.format("%d%%", percent))

    local isLeader = member.isLeader == true
    row.leaderIconBack:SetHidden(not isLeader)
    row.leaderIcon:SetHidden(not isLeader)

    local ezoStatusText = ""
    if EZOGroupFrames_EZOCorePerformance
        and type(EZOGroupFrames_EZOCorePerformance.BuildDisplayText) == "function" then
        ezoStatusText = EZOGroupFrames_EZOCorePerformance.BuildDisplayText(member.unitTag)
    end
    local hasEzoStatus = ezoStatusText ~= ""
    row.ezoStatus:SetHidden(not hasEzoStatus)
    row.ezoStatus:SetText(ezoStatusText)
    row.value:ClearAnchors()
    row.value:SetAnchor(LEFT, row.barRoot, LEFT, isLeader and 34 or TEXT_INSET, 0)
    row.value:SetDimensions(hasEzoStatus and (isLeader and 60 or 82) or (isLeader and 128 or 150), 24)
    row.percent:SetDimensions(hasEzoStatus and 52 or 66, 24)
end

local function BuildDisplayName(member)
    local parts = { member.name or member.unitTag or "" }
    local settings = EZOGroupFrames.sv.frames
    if settings.showLevel == true and member.levelText and member.levelText ~= "" then
        parts[#parts + 1] = member.levelText
    end
    if settings.showClass == true and member.classText and member.classText ~= "" then
        parts[#parts + 1] = member.classText
    end
    return table.concat(parts, " - ")
end

local function PositionRow(row, index)
    local blockIndex = zo_floor((index - 1) / ROWS_PER_BLOCK)
    local rowIndex = (index - 1) % ROWS_PER_BLOCK
    local x = blockIndex * (ROW_WIDTH + BLOCK_GAP)
    local y = 18 + (rowIndex * (ROW_HEIGHT + ROW_GAP))
    row:ClearAnchors()
    row:SetAnchor(TOPLEFT, FRAMES.container, TOPLEFT, x, y)
end

local function EnsureControls()
    if FRAMES.container and FRAMES.rows then
        return
    end

    local container = GetNamedControl(CONTAINER_NAME)
    if not container then
        container = WINDOW_MANAGER:CreateTopLevelWindow(CONTAINER_NAME)
    end
    if not container then
        return
    end
    container:SetDimensions((ROW_WIDTH * 3) + (BLOCK_GAP * 2), 212)
    local settings = EZOGroupFrames.sv and EZOGroupFrames.sv.frames or {}
    container:ClearAnchors()
    container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, settings.x or 260, settings.y or 260)
    container:SetMovable(false)
    container:SetMouseEnabled(true)
    container:SetClampedToScreen(true)
    container:SetHidden(true)
    container:SetHandler("OnMouseDown", function(control, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or FRAMES.moveEnabled ~= true then
            return
        end
        FRAMES.dragActive = true
        control:SetMovable(true)
        control:StartMoving()
    end)
    container:SetHandler("OnMouseUp", function(control, button)
        if button ~= MOUSE_BUTTON_INDEX_LEFT or FRAMES.dragActive ~= true then
            return
        end
        control:StopMovingOrResizing()
        FRAMES.dragActive = false
        control:SetMovable(false)
    end)
    container:SetHandler("OnMoveStop", function(control)
        FRAMES.dragActive = false
        control:SetMovable(false)
        if EZOGroupFrames and EZOGroupFrames.sv and EZOGroupFrames.sv.frames then
            EZOGroupFrames.sv.frames.x = zo_floor(control:GetLeft())
            EZOGroupFrames.sv.frames.y = zo_floor(control:GetTop())
        end
    end)

    container.title = container.title or WINDOW_MANAGER:CreateControl(nil, container, CT_LABEL)
    container.title:ClearAnchors()
    container.title:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
    container.title:SetFont("ZoFontGameSmall")
    container.title:SetColor(0.8, 0.6, 1, 1)
    container.title:SetText(GetString(EZO_GF_STATUS_GROUP))

    FRAMES.container = container
    FRAMES.rows = {}
    for i = 1, MAX_ROWS do
        FRAMES.rows[i] = AttachOrCreateRow(container, i)
        ApplyBarStyle(FRAMES.rows[i])
    end

    if not FRAMES.hudRegistered and EZOGroupFrames_HudVisibility and EZOGroupFrames_HudVisibility.Register then
        EZOGroupFrames_HudVisibility.Register(container, FRAMES.Refresh)
        FRAMES.hudRegistered = true
    end
end

function FRAMES.Refresh()
    if FRAMES.isRefreshing then
        return
    end
    FRAMES.isRefreshing = true

    EnsureControls()
    if not FRAMES.container or not FRAMES.rows then
        FRAMES.isRefreshing = false
        return
    end

    local members = {}
    if EZOGroupFrames_GroupState and EZOGroupFrames_GroupState.GetMembers then
        members = EZOGroupFrames_GroupState.GetMembers()
    end

    local enabled = IsEnabled()
    local settings = EZOGroupFrames.sv and EZOGroupFrames.sv.frames or {}
    local isHudScene = not EZOGroupFrames_HudVisibility
        or not EZOGroupFrames_HudVisibility.IsHudScene
        or EZOGroupFrames_HudVisibility.IsHudScene()

    local isPreviewActive = enabled and isHudScene and EZOGroupFrames_DebugSimulation and EZOGroupFrames_DebugSimulation.IsActive and EZOGroupFrames_DebugSimulation.IsActive()
    local isEditModeActive = enabled and isHudScene and FRAMES.layoutEditMode == true

    if #members == 0 and (isEditModeActive or isPreviewActive) and EZOGroupFrames_DebugSimulation and EZOGroupFrames_DebugSimulation.GetSampleMembers then
        local mode = EZOGroupFrames_DebugSimulation.GetPreviewMode and EZOGroupFrames_DebugSimulation.GetPreviewMode() or 0
        local count = (mode == 4) and 4 or 12
        members = EZOGroupFrames_DebugSimulation.GetSampleMembers(count)
    end

    local functionalShow = ShouldShow(members)
    FRAMES.functionalVisible = functionalShow

    local show = enabled and isHudScene and (functionalShow or isEditModeActive)
    local moveMode = show and (isEditModeActive or settings.locked == false)
    FRAMES.moveEnabled = moveMode

    if FRAMES.dragActive and not moveMode then
        FRAMES.container:StopMovingOrResizing()
        FRAMES.dragActive = false
    end

    FRAMES.container:SetHidden(not show)
    if EZOGroupFrames_NativeFrames and EZOGroupFrames_NativeFrames.ApplyVisibility then
        EZOGroupFrames_NativeFrames.ApplyVisibility(functionalShow)
    end
    if not show then
        FRAMES.isRefreshing = false
        return
    end

    if FRAMES.container.title then
        local mode = EZOGroupFrames_DebugSimulation and EZOGroupFrames_DebugSimulation.GetPreviewMode and EZOGroupFrames_DebugSimulation.GetPreviewMode() or 0
        if mode == 12 or #members == 12 then
            FRAMES.container.title:SetText(GetString(EZO_GF_STATUS_GROUP_PREVIEW_12))
        elseif mode == 4 or #members == 4 then
            FRAMES.container.title:SetText(GetString(EZO_GF_STATUS_GROUP_PREVIEW_4))
        else
            FRAMES.container.title:SetText(GetString(EZO_GF_STATUS_GROUP))
        end
    end

    FRAMES.container:SetScale(tonumber(settings.scale) or 1)
    FRAMES.container:SetMovable(false)
    FRAMES.container:SetMouseEnabled(moveMode)

    for i = 1, MAX_ROWS do
        local row = FRAMES.rows[i]
        local member = members[i]
        row:SetHidden(member == nil)
        PositionRow(row, i)
        if member then
            local r, g, b = GetRoleColor(member.role)
            local roleIcon = GetRoleIcon(member.role)
            row.name:SetText(BuildDisplayName(member))
            if roleIcon then
                row.roleIcon:SetTexture(roleIcon)
                row.roleIcon:SetColor(r, g, b, 1)
                row.roleIcon:SetHidden(false)
            else
                row.roleIcon:SetHidden(true)
            end
            UpdateBar(row, member)
        end
    end

    FRAMES.isRefreshing = false
end

function FRAMES.Init()
    FRAMES.layoutEditMode = false
    EnsureControls()
    FRAMES.Refresh()
end
