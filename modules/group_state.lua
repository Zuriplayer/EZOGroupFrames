EZOGroupFrames_GroupState = EZOGroupFrames_GroupState or {}

local STATE = EZOGroupFrames_GroupState
STATE.members = STATE.members or {}

local ROLE_SORT = {}

local function GetMemberName(unitTag)
    if type(GetUnitDisplayName) == "function" then
        local displayName = GetUnitDisplayName(unitTag)
        if displayName and displayName ~= "" then
            return displayName
        end
    end
    if type(GetUnitName) == "function" then
        local name = GetUnitName(unitTag)
        if name and name ~= "" then
            return name
        end
    end
    return unitTag
end

local function GetHealth(unitTag)
    if type(GetUnitPower) ~= "function" or POWERTYPE_HEALTH == nil then
        return 0, 0, 0
    end
    local current, max, effectiveMax = GetUnitPower(unitTag, POWERTYPE_HEALTH)
    current = tonumber(current) or 0
    max = tonumber(effectiveMax) or tonumber(max) or 0
    local percent = 0
    if max > 0 then
        percent = zo_floor((current / max) * 100)
    end
    return current, max, percent
end

local function GetRole(unitTag)
    if type(GetGroupMemberSelectedRole) == "function" then
        return GetGroupMemberSelectedRole(unitTag)
    end
    if unitTag == "player" and type(GetSelectedLFGRole) == "function" then
        return GetSelectedLFGRole()
    end
    return LFG_ROLE_INVALID
end

local function GetRoleSort(role)
    ROLE_SORT[LFG_ROLE_TANK or -1] = 1
    ROLE_SORT[LFG_ROLE_DPS or -2] = 2
    ROLE_SORT[LFG_ROLE_HEAL or -3] = 3
    ROLE_SORT[LFG_ROLE_INVALID or -4] = 4
    return ROLE_SORT[role] or 4
end

local function GetLevelText(unitTag)
    if type(GetUnitChampionPoints) == "function" then
        local championPoints = tonumber(GetUnitChampionPoints(unitTag)) or 0
        if championPoints > 0 then
            return "CP" .. tostring(championPoints)
        end
    end
    if type(GetUnitLevel) == "function" then
        local level = tonumber(GetUnitLevel(unitTag)) or 0
        if level > 0 then
            return "L" .. tostring(level)
        end
    end
    return ""
end

local function GetClassText(unitTag)
    if type(GetUnitClass) ~= "function" then
        return ""
    end
    local className = GetUnitClass(unitTag)
    if not className or className == "" then
        return ""
    end
    local normalized = zo_strlower(className)
    if normalized:find("dragon") or normalized:find("dk") then
        return "DK"
    end
    if normalized:find("arcan") then
        return "Arcanista"
    end
    if normalized:find("templ") then
        return "Templar"
    end
    if normalized:find("sorc") or normalized:find("hech") then
        return "Sorc"
    end
    if normalized:find("night") or normalized:find("blade") or normalized:find("noche") then
        return "NB"
    end
    if normalized:find("warden") or normalized:find("guardi") then
        return "Warden"
    end
    if normalized:find("necro") then
        return "Necro"
    end
    return className
end

function STATE.Refresh()
    local members = {}
    local size = type(GetGroupSize) == "function" and tonumber(GetGroupSize()) or 0
    if size and size > 0 then
        for i = 1, size do
            local unitTag = "group" .. tostring(i)
            local currentHealth, maxHealth, healthPercent = GetHealth(unitTag)
            local role = GetRole(unitTag)
            members[#members + 1] = {
                unitTag = unitTag,
                name = GetMemberName(unitTag),
                role = role,
                roleSort = GetRoleSort(role),
                levelText = GetLevelText(unitTag),
                classText = GetClassText(unitTag),
                currentHealth = currentHealth,
                maxHealth = maxHealth,
                healthPercent = healthPercent,
            }
        end
    end
    table.sort(members, function(a, b)
        if a.roleSort ~= b.roleSort then
            return a.roleSort < b.roleSort
        end
        return tostring(a.name or "") < tostring(b.name or "")
    end)
    STATE.members = members
end

function STATE.GetMembers()
    return STATE.members or {}
end

local function RefreshAll()
    STATE.Refresh()
    if EZOGroupFrames_Frames and EZOGroupFrames_Frames.Refresh then
        EZOGroupFrames_Frames.Refresh()
    end
end

function STATE.Init()
    STATE.Refresh()

    local events = {
        EVENT_GROUP_MEMBER_JOINED,
        EVENT_GROUP_MEMBER_LEFT,
        EVENT_GROUP_UPDATE,
        EVENT_GROUP_MEMBER_ROLE_CHANGED,
        EVENT_UNIT_DEATH_STATE_CHANGED,
        EVENT_POWER_UPDATE,
    }

    for i, eventCode in ipairs(events) do
        if eventCode ~= nil then
            EVENT_MANAGER:RegisterForEvent("EZOGroupFrames_GroupState_" .. tostring(i), eventCode, RefreshAll)
        end
    end
end
