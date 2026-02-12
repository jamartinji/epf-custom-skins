-- [ LOCALE LOADER ] Picks the correct locale table based on GetLocale().
-- Load this after all Locales/xxXX.lua files so EPF_CustomSkins_Locales is populated.

EPF_CustomSkins_Locales = EPF_CustomSkins_Locales or {}
local loc = (GetLocale and GetLocale()) or "enUS"
-- Algunos clientes devuelven "es" en vez de "esES"; usar esES si existe
if loc == "es" and EPF_CustomSkins_Locales.esES then loc = "esES" end
local fallback = EPF_CustomSkins_Locales.enUS or {}
-- Asegurar que el fallback tenga estas claves (usadas en Options)
fallback.OutputLevel = fallback.OutputLevel or "Message output level"
fallback.SectionTextures = fallback.SectionTextures or "Available textures"
EPF_CustomSkins_L = setmetatable(EPF_CustomSkins_Locales[loc] or {}, {
    __index = function(_, k) return fallback[k] or k end
})
