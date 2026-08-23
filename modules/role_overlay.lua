EZOGroupFrames_RoleOverlay = EZOGroupFrames_RoleOverlay or {}

local OVERLAY = EZOGroupFrames_RoleOverlay

local PROVIDER_ID = "ezogroupframes.roleOverlay"
local UPDATE_EVENT = "EZOGroupFrames_RoleOverlayUpdate"
local SUPPORT_ADDON_NAME = "EZOCustomSupportIcons"
local ROLE_OFFSET_M = 1.35
local ROLE_FADE_DISTANCE_M = 25
local ROW_HEIGHT = 34
local NAME_ROW_WIDTH = 220
local ICON_SIZE = 28
local BACKGROUND_COLOR = { 0, 0, 0, 0.68 }
local ROLE_ICON_TEXTURES = {
    tank = "EsoUI/Art/LFG/Gamepad/lfg_roleicon_tank.dds",
    healer = "EsoUI/Art/LFG/Gamepad/lfg_roleicon_healer.dds",
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

local function IsGrouped()
    return type(GetGroupSize) == "function" and (tonumber(GetGroupSize()) or 0) >= 2
end

local function IsPvEWorld()
    local checked = false

    if type(IsPlayerInAvAWorld) == "function" then
        checked = true
        local ok, isAvA = pcall(IsPlayerInAvAWorld)
        if ok and isAvA == true then
            return false
        end
    end

    if type(IsActiveWorldBattleground) == "function" then
        checked = true
        local ok, isBattleground = pcall(IsActiveWorldBattleground)
        if ok and isBattleground == true then
            return false
        end
    end

    return checked
end

local function CanShowUnit(unitTag)
    if type(DoesUnitExist) ~= "function"
        or type(IsUnitPlayer) ~= "function"
        or type(IsUnitOnline) ~= "function"
        or type(IsGroupMemberInSameWorldAsPlayer) ~= "function"
        or type(IsGroupMemberInRemoteRegion) ~= "function"
        or type(IsGroupMemberInSameInstanceAsPlayer) ~= "function"
    then
        return false
    end

    local sameInstance = IsGroupMemberInSameInstanceAsPlayer(unitTag)
    local inBattleground = type(IsActiveWorldBattleground) == "function"
        and IsActiveWorldBattleground() == true

    return DoesUnitExist(unitTag)
        and IsUnitPlayer(unitTag)
        and IsUnitOnline(unitTag)
        and IsGroupMemberInSameWorldAsPlayer(unitTag)
        and not IsGroupMemberInRemoteRegion(unitTag)
        and (sameInstance or inBattleground)
end

local function GetRoleKey(role)
    if LFG_ROLE_TANK ~= nil and role == LFG_ROLE_TANK then
        return "tank"
    end
    if LFG_ROLE_HEAL ~= nil and role == LFG_ROLE_HEAL then
        return "healer"
    end
    return nil
end

local function GetRoleColor(role)
    local settings = EZOGroupFrames.sv and EZOGroupFrames.sv.frames or {}
    local color = settings.unknownColor
    if LFG_ROLE_TANK ~= nil and role == LFG_ROLE_TANK then
        color = settings.tankColor
    elseif LFG_ROLE_HEAL ~= nil and role == LFG_ROLE_HEAL then
        color = settings.healerColor
    end

    if type(color) ~= "table" then
        return 0.8, 0.8, 0.8, 1
    end
    return color.r or 1, color.g or 1, color.b or 1, color.a or 1
end

local function GetRoleMode(roleKey)
    local settings = EZOGroupFrames.sv and EZOGroupFrames.sv.roleOverlay or {}
    local mode = roleKey == "tank" and settings.tankMode or settings.healerMode
    if mode == "icon" or mode == "name" or mode == "icon_name" then
        return mode
    end
    return "icon"
end

local function IsRoleEnabled(roleKey)
    local settings = EZOGroupFrames.sv and EZOGroupFrames.sv.roleOverlay or {}
    if settings.enabled ~= true then
        return false
    end
    return roleKey == "tank" and settings.showTanks == true
        or roleKey == "healer" and settings.showHealers == true
end

local function GetUnitName(unitTag, fallback)
    if type(GetUnitDisplayName) == "function" then
        local displayName = GetUnitDisplayName(unitTag)
        if displayName and displayName ~= "" then
            return displayName
        end
    end
    return fallback or unitTag
end

local function CreateLabel(parent)
    local label = WINDOW_MANAGER:CreateControl(nil, parent, CT_LABEL)
    label:SetFont("ZoFontGameMedium")
    label:SetMouseEnabled(false)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function CreateRow(parent)
    local row = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
    row:SetDimensions(NAME_ROW_WIDTH, ROW_HEIGHT)
    row:SetMouseEnabled(false)
    if type(row.SetDrawLayer) == "function" and DL_OVERLAY then
        row:SetDrawLayer(DL_OVERLAY)
    end
    if type(row.SetDrawLevel) == "function" then
        row:SetDrawLevel(2)
    end

    row.background = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.background:SetAnchorFill(row)
    row.background:SetTexture("EsoUI/Art/Miscellaneous/progressbar_genericfill.dds")
    row.background:SetColor(unpack(BACKGROUND_COLOR))
    row.background:SetMouseEnabled(false)

    row.icon = WINDOW_MANAGER:CreateControl(nil, row, CT_TEXTURE)
    row.icon:SetDimensions(ICON_SIZE, ICON_SIZE)
    row.icon:SetMouseEnabled(false)

    row.name = CreateLabel(row)
    row.name:SetColor(1, 1, 1, 1)
    row.name:SetMouseEnabled(false)

    row:SetHidden(true)
    return row
end

local function ApplyMode(row, mode)
    row:ClearAnchors()
    row:SetAnchor(BOTTOM, OVERLAY.window, CENTER, 0, 0)

    if mode == "icon" then
        row:SetDimensions(ICON_SIZE + 6, ROW_HEIGHT)
        row.icon:ClearAnchors()
        row.icon:SetAnchor(CENTER, row, CENTER, 0, 0)
        row.icon:SetHidden(false)
        row.name:SetHidden(true)
    elseif mode == "name" then
        row:SetDimensions(NAME_ROW_WIDTH, ROW_HEIGHT)
        row.icon:SetHidden(true)
        row.name:ClearAnchors()
        row.name:SetAnchorFill(row)
        row.name:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        row.name:SetHidden(false)
    else
        row:SetDimensions(NAME_ROW_WIDTH, ROW_HEIGHT)
        row.icon:ClearAnchors()
        row.icon:SetAnchor(LEFT, row, LEFT, 4, 0)
        row.icon:SetHidden(false)
        row.name:ClearAnchors()
        row.name:SetAnchor(LEFT, row.icon, RIGHT, 6, 0)
        row.name:SetDimensions(NAME_ROW_WIDTH - ICON_SIZE - 14, ROW_HEIGHT)
        row.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        row.name:SetHidden(false)
    end
end

local function HideAll()
    for _, row in pairs(OVERLAY.rows) do
        row:SetHidden(true)
    end
end

local function EnsureRows(parent)
    if not parent then
        return false
    end
    if OVERLAY.parent == parent and OVERLAY.rows then
        return true
    end

    if OVERLAY.parent and OVERLAY.parent ~= parent then
        HideAll()
    end

    OVERLAY.parent = parent
    OVERLAY.window = parent
    OVERLAY.rows = {}
    return true
end

local function GetOrCreateRow(unitTag)
    local row = OVERLAY.rows[unitTag]
    if row then
        return row
    end
    row = CreateRow(OVERLAY.parent)
    OVERLAY.rows[unitTag] = row
    return row
end

local function ProjectRow(unitTag, row, camera)
    if type(GetUnitRawWorldPosition) ~= "function"
        or type(GetWorldDimensionsOfViewFrustumAtDepth) ~= "function"
    then
        return
    end

    local _, worldX, worldY, worldZ = GetUnitRawWorldPosition(unitTag)
    worldY = worldY + ROLE_OFFSET_M * 100

    local screenX = worldX * camera.i11 + worldY * camera.i21 + worldZ * camera.i31 + camera.i41
    local screenY = worldX * camera.i12 + worldY * camera.i22 + worldZ * camera.i32 + camera.i42
    local screenZ = worldX * camera.i13 + worldY * camera.i23 + worldZ * camera.i33 + camera.i43
    if screenZ <= 0 then
        return
    end

    local viewW, viewH = GetWorldDimensionsOfViewFrustumAtDepth(screenZ)
    if not viewW or not viewH or viewW == 0 or viewH == 0 then
        return
    end

    local uiX = screenX * camera.uiW / viewW
    local uiY = -screenY * camera.uiH / viewH
    row:ClearAnchors()
    row:SetAnchor(BOTTOM, OVERLAY.window, CENTER, uiX, uiY)

    local dx = worldX - camera.x
    local dy = worldY - camera.y
    local dz = worldZ - camera.z
    local distance = 1 + zo_sqrt(dx * dx + dy * dy + dz * dz)
    row:SetScale(1000 / distance)

    local alpha = zo_clampedPercentBetween(1, ROLE_FADE_DISTANCE_M * 100, distance)
    if type(IsUnitDead) == "function" and IsUnitDead(unitTag) then
        alpha = alpha * 0.62
    end
    row:SetAlpha(alpha)
    row:SetHidden(false)
end

local function UpdateRows(camera, parent)
    if not camera or not parent or not IsHudScene() or not IsPvEWorld() or not IsGrouped() then
        HideAll()
        return
    end

    local settings = EZOGroupFrames.sv and EZOGroupFrames.sv.roleOverlay
    if not settings or settings.enabled ~= true then
        HideAll()
        return
    end

    local members = EZOGroupFrames_GroupState and EZOGroupFrames_GroupState.GetMembers
        and EZOGroupFrames_GroupState.GetMembers() or {}
    HideAll()

    for _, member in ipairs(members) do
        local roleKey = GetRoleKey(member.role)
        if roleKey and IsRoleEnabled(roleKey) and CanShowUnit(member.unitTag) then
            local row = GetOrCreateRow(member.unitTag)
            local mode = GetRoleMode(roleKey)
            local r, g, b = GetRoleColor(member.role)
            ApplyMode(row, mode)
            row.background:SetColor(0, 0, 0, 0.68)
            row.icon:SetTexture(ROLE_ICON_TEXTURES[roleKey])
            row.icon:SetColor(r, g, b, 1)
            row.name:SetText(GetUnitName(member.unitTag, member.name))
            row.name:SetColor(r, g, b, 1)
            ProjectRow(member.unitTag, row, camera)
        end
    end
end

local function GetCamera()
    if not OVERLAY.renderControl then
        return nil
    end

    Set3DRenderSpaceToCurrentCamera(OVERLAY.renderControl:GetName())
    local cameraX, cameraY, cameraZ = GuiRender3DPositionToWorldPosition(OVERLAY.renderControl:Get3DRenderSpaceOrigin())
    local forwardX, forwardY, forwardZ = OVERLAY.renderControl:Get3DRenderSpaceForward()
    local rightX, rightY, rightZ = OVERLAY.renderControl:Get3DRenderSpaceRight()
    local upX, upY, upZ = OVERLAY.renderControl:Get3DRenderSpaceUp()
    local uiW, uiH = GuiRoot:GetDimensions()

    return {
        x = cameraX,
        y = cameraY,
        z = cameraZ,
        uiW = uiW,
        uiH = uiH,
        i11 = -(upY * forwardZ - upZ * forwardY),
        i12 = -(rightZ * forwardY - rightY * forwardZ),
        i13 = -(rightY * upZ - rightZ * upY),
        i21 = -(upZ * forwardX - upX * forwardZ),
        i22 = -(rightX * forwardZ - rightZ * forwardX),
        i23 = -(rightZ * upX - rightX * upZ),
        i31 = -(upX * forwardY - upY * forwardX),
        i32 = -(rightY * forwardX - rightX * forwardY),
        i33 = -(rightX * upY - rightY * upX),
        i41 = -(upZ * forwardY * cameraX + upY * forwardX * cameraZ + upX * forwardZ * cameraY - upX * forwardY * cameraZ - upY * forwardZ * cameraX - upZ * forwardX * cameraY),
        i42 = -(rightX * forwardY * cameraZ + rightY * forwardZ * cameraX + rightZ * forwardX * cameraY - rightZ * forwardY * cameraX - rightY * forwardX * cameraZ - rightX * forwardZ * cameraY),
        i43 = -(rightZ * upY * cameraX + rightY * upX * cameraZ + rightX * upZ * cameraY - rightX * upY * cameraZ - rightY * upZ * cameraX - rightZ * upX * cameraY),
    }
end

function OVERLAY.OnUpdate(camera, sharedWindow)
    local parent = OVERLAY.usingShared and sharedWindow or OVERLAY.ownWindow
    if not EnsureRows(parent) then
        return
    end
    UpdateRows(camera, parent)
end

local function RegisterSharedProvider()
    if OVERLAY.usingShared then
        return true
    end
    if not (EZOCustomSupportIcons and type(EZOCustomSupportIcons.RegisterWorldOverlayProvider) == "function") then
        return false
    end

    local ok, registered = pcall(function()
        return EZOCustomSupportIcons.RegisterWorldOverlayProvider(PROVIDER_ID, OVERLAY)
    end)
    if not ok or registered ~= true then
        return false
    end

    OVERLAY.usingShared = true
    if OVERLAY.updateRegistered then
        EVENT_MANAGER:UnregisterForUpdate(UPDATE_EVENT)
        OVERLAY.updateRegistered = false
    end
    if OVERLAY.ownWindow then
        OVERLAY.ownWindow:SetHidden(true)
    end
    return true
end

local function InitializeOwnRenderer()
    if OVERLAY.ownWindow then
        return
    end

    OVERLAY.renderControl = WINDOW_MANAGER:CreateControl("EZOGroupFramesRoleOverlayRenderControl", GuiRoot, CT_CONTROL)
    OVERLAY.renderControl:SetAnchorFill(GuiRoot)
    OVERLAY.renderControl:Create3DRenderSpace()
    OVERLAY.renderControl:SetHidden(true)

    OVERLAY.ownWindow = WINDOW_MANAGER:CreateTopLevelWindow("EZOGroupFramesRoleOverlayWindow")
    OVERLAY.ownWindow:SetAnchorFill(GuiRoot)
    OVERLAY.ownWindow:SetMouseEnabled(false)
    OVERLAY.ownWindow:SetDrawLayer(DL_OVERLAY)
    OVERLAY.ownWindow:SetHidden(false)
end

local function RegisterOwnRenderer()
    InitializeOwnRenderer()
    if OVERLAY.updateRegistered then
        return
    end
    EVENT_MANAGER:RegisterForUpdate(UPDATE_EVENT, 10, function()
        OVERLAY.OnUpdate(GetCamera(), nil)
    end)
    OVERLAY.updateRegistered = true
end

function OVERLAY.Refresh()
    if OVERLAY.rows and (not EZOGroupFrames.sv or not EZOGroupFrames.sv.roleOverlay or EZOGroupFrames.sv.roleOverlay.enabled ~= true) then
        HideAll()
    end
end

function OVERLAY.Init()
    if not RegisterSharedProvider() then
        RegisterOwnRenderer()
    end

    EVENT_MANAGER:RegisterForEvent("EZOGroupFrames_RoleOverlayAddonLoaded", EVENT_ADD_ON_LOADED, function(_, addonName)
        if addonName == SUPPORT_ADDON_NAME then
            RegisterSharedProvider()
        end
    end)
end
