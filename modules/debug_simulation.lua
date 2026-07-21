EZOGroupFrames_DebugSimulation = EZOGroupFrames_DebugSimulation or {}

local MOD = EZOGroupFrames_DebugSimulation
MOD.previewMode = MOD.previewMode or 0

local function RoleTank()
    return LFG_ROLE_TANK or 2
end

local function RoleHealer()
    return LFG_ROLE_HEAL or 4
end

local function RoleDamage()
    return LFG_ROLE_DPS or 1
end

local function BuildMember(index, role, name, currentHealth, maxHealth, levelText, classText, isLeader)
    local percent = 0
    if maxHealth > 0 then
        percent = zo_floor((currentHealth / maxHealth) * 100)
    end

    return {
        unitTag = "debug" .. tostring(index),
        name = name,
        role = role,
        levelText = levelText,
        classText = classText,
        currentHealth = currentHealth,
        maxHealth = maxHealth,
        healthPercent = percent,
        isLeader = isLeader == true,
        simulated = true,
    }
end

function MOD.GetPreviewMode()
    return tonumber(MOD.previewMode) or 0
end

function MOD.SetPreviewMode(mode)
    mode = tonumber(mode) or 0
    if mode ~= 4 and mode ~= 12 then
        mode = 0
    end

    if MOD.previewMode == mode then
        return MOD.previewMode
    end

    MOD.previewMode = mode
    MOD.active = (mode > 0)

    if EZOGroupFrames_Debug and EZOGroupFrames_Debug.Log then
        if mode == 4 then
            EZOGroupFrames_Debug.Log("Sample preview mode enabled: 4 members (1 Tank, 1 Healer, 2 DD).", "Simulation")
        elseif mode == 12 then
            EZOGroupFrames_Debug.Log("Sample preview mode enabled: 12 members (2 Tanks, 2 Healers, 8 DD).", "Simulation")
        else
            EZOGroupFrames_Debug.Log("Sample preview mode disabled.", "Simulation")
        end
    end

    if EZOGroupFrames_GroupState and EZOGroupFrames_GroupState.Refresh then
        EZOGroupFrames_GroupState.Refresh()
    end
    if EZOGroupFrames_Frames and EZOGroupFrames_Frames.Refresh then
        EZOGroupFrames_Frames.Refresh()
    end

    return MOD.previewMode
end

function MOD.IsActive()
    return MOD.GetPreviewMode() > 0 or MOD.active == true
end

function MOD.SetActive(active)
    if active == true then
        MOD.SetPreviewMode(12)
    else
        MOD.SetPreviewMode(0)
    end
    return MOD.IsActive()
end

function MOD.Toggle()
    local current = MOD.GetPreviewMode()
    if current == 0 then
        return MOD.SetPreviewMode(12)
    elseif current == 12 then
        return MOD.SetPreviewMode(4)
    else
        return MOD.SetPreviewMode(0)
    end
end

function MOD.GetSampleMembers(count)
    count = tonumber(count) or 12
    if count == 4 then
        return {
            BuildMember(1, RoleTank(), "EZO Tank", 48000, 52000, "CP2200", "DK", true),
            BuildMember(2, RoleHealer(), "EZO Healer", 28600, 32000, "CP1800", "Templar"),
            BuildMember(3, RoleDamage(), "EZO DD One", 21400, 28000, "CP1600", "Arcanista"),
            BuildMember(4, RoleDamage(), "EZO DD Two", 25200, 30000, "CP1900", "NB"),
        }
    end

    -- Default 12 members preview
    return {
        BuildMember(1, RoleTank(), "EZO Tank Main", 54000, 54000, "CP2400", "DK", true),
        BuildMember(2, RoleTank(), "EZO Tank Off", 49000, 50000, "CP2100", "Necro"),
        BuildMember(3, RoleHealer(), "EZO Healer Main", 29000, 32000, "CP1950", "Templar"),
        BuildMember(4, RoleHealer(), "EZO Healer Off", 31000, 31000, "CP1750", "Warden"),
        BuildMember(5, RoleDamage(), "EZO DD Alpha", 22400, 28000, "CP1600", "Arcanista"),
        BuildMember(6, RoleDamage(), "EZO DD Beta", 25200, 30000, "CP1900", "NB"),
        BuildMember(7, RoleDamage(), "EZO DD Gamma", 24000, 29000, "CP2050", "Sorc"),
        BuildMember(8, RoleDamage(), "EZO DD Delta", 27500, 31000, "CP1820", "DK"),
        BuildMember(9, RoleDamage(), "EZO DD Epsilon", 21800, 28000, "CP1700", "Arcanista"),
        BuildMember(10, RoleDamage(), "EZO DD Zeta", 26000, 29500, "CP2200", "Templar"),
        BuildMember(11, RoleDamage(), "EZO DD Eta", 23500, 28500, "CP1650", "Warden"),
        BuildMember(12, RoleDamage(), "EZO DD Theta", 24800, 30000, "CP1980", "Sorc"),
    }
end

function MOD.GetMembers()
    if not MOD.IsActive() then
        return nil
    end

    return MOD.GetSampleMembers(MOD.GetPreviewMode())
end
