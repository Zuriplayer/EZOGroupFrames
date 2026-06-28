EZOGroupFrames_Debug = EZOGroupFrames_Debug or {}

local function IsEnabled()
    return EZOGroupFrames
        and EZOGroupFrames.sv
        and EZOGroupFrames.sv.general
        and EZOGroupFrames.sv.general.debug == true
end

function EZOGroupFrames_Debug.Log(message)
    if not IsEnabled() then
        return
    end
    if type(d) == "function" then
        d("|cB040FFEZO|rGroupFrames debug: " .. tostring(message or ""))
    end
end
