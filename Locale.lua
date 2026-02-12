-- [ LOCALE LOADER ] Picks the correct locale table based on GetLocale().
-- Load this after all Locales/xxXX.lua files so EPF_CustomSkins_Locales is populated.

EPF_CustomSkins_Locales = EPF_CustomSkins_Locales or {}
local loc = GetLocale and GetLocale() or "enUS"
local fallback = EPF_CustomSkins_Locales.enUS or {}
EPF_CustomSkins_L = setmetatable(EPF_CustomSkins_Locales[loc] or {}, {
    __index = function(_, k) return fallback[k] or k end
})
