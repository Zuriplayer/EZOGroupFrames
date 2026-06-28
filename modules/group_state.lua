EZOGroupFrames_GroupState = EZOGroupFrames_GroupState or {}

local STATE = EZOGroupFrames_GroupState
STATE.members = STATE.members or {}

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

local function GetHealthPercent(unitTag)
    if type(GetUnitPower) ~= "function" or POWERTYPE_HEALTH == nil then
        return nil
    end
    local current, max = GetUnitPower(unitTag, POWERTYPE_HEALTH)
    current = tonumber(current) or 0
    max = tonumber(max) or 0
    if max <= 0 then
        return nil
    end
    return zo_floor((current / max) * 100)
end

function STATE.Refresh()
    local members = {}
    local size = type(GetGroupSize) == "function" and tonumber(GetGroupSize()) or 0
    if size and size > 0 then
        for i = 1, size do
            local unitTag = "group" .. tostring(i)
            members[#members + 1] = {
                unitTag = unitTag,
                name = GetMemberName(unitTag),
                healthPercent = GetHealthPercent(unitTag),
            }
        end
    end
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
        EVENT_UNIT_DEATH_STATE_CHANGED,
        EVENT_POWER_UPDATE,
    }

    for i, eventCode in ipairs(events) do
        if eventCode ~= nil then
            EVENT_MANAGER:RegisterForEvent("EZOGroupFrames_GroupState_" .. tostring(i), eventCode, RefreshAll)
        end
    end
end
