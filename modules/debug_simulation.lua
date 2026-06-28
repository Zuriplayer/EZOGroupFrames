EZOGroupFrames_DebugSimulation = EZOGroupFrames_DebugSimulation or {}

local MOD = EZOGroupFrames_DebugSimulation

local function RoleTank()
    return LFG_ROLE_TANK or 2
end

local function RoleHealer()
    return LFG_ROLE_HEAL or 4
end

local function RoleDamage()
    return LFG_ROLE_DPS or 1
end

local function IsDebugEnabled()
    return EZOGroupFrames
        and EZOGroupFrames.sv
        and EZOGroupFrames.sv.general
        and EZOGroupFrames.sv.general.debug == true
end

local function BuildMember(index, role, name, currentHealth, maxHealth, levelText, classText)
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
        simulated = true,
    }
end

function MOD.IsActive()
    return MOD.active == true
end

function MOD.SetActive(active)
    if active == true and not IsDebugEnabled() then
        MOD.active = false
        return false
    end

    MOD.active = active == true

    if EZOGroupFrames_Debug and EZOGroupFrames_Debug.Log then
        EZOGroupFrames_Debug.Log(MOD.active and "Debug simulation enabled: 1 tank, 1 healer, 2 DD." or "Debug simulation disabled.", "Simulation")
    end

    if EZOGroupFrames_GroupState and EZOGroupFrames_GroupState.Refresh then
        EZOGroupFrames_GroupState.Refresh()
    end
    if EZOGroupFrames_Frames and EZOGroupFrames_Frames.Refresh then
        EZOGroupFrames_Frames.Refresh()
    end

    return true
end

function MOD.Toggle()
    return MOD.SetActive(not MOD.IsActive())
end

function MOD.GetMembers()
    if not MOD.IsActive() or not IsDebugEnabled() then
        return nil
    end

    return {
        BuildMember(1, RoleTank(), "EZO Tank", 48000, 52000, "CP2200", "DK"),
        BuildMember(2, RoleHealer(), "EZO Healer", 28600, 32000, "CP1800", "Templar"),
        BuildMember(3, RoleDamage(), "EZO DD One", 21400, 28000, "CP1600", "Arcanista"),
        BuildMember(4, RoleDamage(), "EZO DD Two", 25200, 30000, "CP1900", "NB"),
    }
end
