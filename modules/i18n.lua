EZOGroupFrames_Lang = EZOGroupFrames_Lang or {}

local function ApplyString(id, value, version)
    local stringId = _G[id]
    if stringId == nil and type(ZO_CreateStringId) == "function" then
        ZO_CreateStringId(id, value)
        stringId = _G[id]
    end
    if stringId ~= nil and type(SafeAddString) == "function" then
        SafeAddString(stringId, value, version)
    end
end

function EZOGroupFrames_Lang.Apply(lang)
    local effectiveLang = lang
    if EZOGroupFrames and EZOGroupFrames.GetEffectiveLanguage then
        effectiveLang = EZOGroupFrames.GetEffectiveLanguage(lang)
    end
    local source = (effectiveLang == "es" and EZO_GROUP_FRAMES_STRINGS_ES) or EZO_GROUP_FRAMES_STRINGS_EN
    if not source then
        return
    end
    EZOGroupFrames_Lang._version = (tonumber(EZOGroupFrames_Lang._version) or 0) + 1
    for id, value in pairs(source) do
        ApplyString(id, value, EZOGroupFrames_Lang._version)
    end
    EZOGroupFrames_Lang.current = (effectiveLang == "es") and "es" or "en"
end
