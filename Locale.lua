-- [ LOCALE LOADER ] Picks the correct locale table based on GetLocale().
-- Load this after all Locales/xxXX.lua files so EPF_CustomSkins_Locales is populated.

EPF_CustomSkins_Locales = EPF_CustomSkins_Locales or {}
local loc = (GetLocale and GetLocale()) or "enUS"
-- Some clients return "es" instead of "esES"; use esES when available
if loc == "es" and EPF_CustomSkins_Locales.esES then loc = "esES" end
local fallback = EPF_CustomSkins_Locales.enUS or {}
local defaultStrings = {
    OutputLevel = "Message output level",
    SectionTextures = "Available textures",
    SearchFilter = "Filter...",
}
EPF_CustomSkins_L = setmetatable(EPF_CustomSkins_Locales[loc] or {}, {
    __index = function(_, k) return fallback[k] or defaultStrings[k] or k end
})
