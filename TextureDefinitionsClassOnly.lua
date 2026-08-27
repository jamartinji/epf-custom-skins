-- [ CLASS-ONLY FALLBACK TEXTURES ] Generic class defaults when no spec entry matches.
-- Part of textureConfigFallback; load order: ClassOnly -> RaceFaction -> Alternatives -> Extra.

EPF_CustomSkins_Definitions = EPF_CustomSkins_Definitions or {}
local D = EPF_CustomSkins_Definitions
D.textureConfigFallback = D.textureConfigFallback or {}

local entries = {
    -- { class = "DEATHKNIGHT", name = "deathknight" },
    -- { class = "DEMONHUNTER", name = "demonhunter" },
    { id = "druid", class = "DRUID", name = "druid", layout = "top" },
    { id = "evoker", class = "EVOKER", name = "evoker", layout = "dual" },
    { id = "hunter", class = "HUNTER", name = "hunter_base&bm", layout = "top" },
    { id = "mage", class = "MAGE", name = "mage", layout = "bot" },
    { id = "monk", class = "MONK", name = "monk_base&brew",
        layout = "top",
        pointOffset = { 172, 10 },
    },
    { id = "priest", class = "PRIEST", name = "priest", layout = "top" },
    { id = "rogue", class = "ROGUE", name = "rogue_base&subtley", layout = "top" },
    { id = "shaman", class = "SHAMAN", name = "shaman_base&resto", layout = "top" },
    { id = "warlock", class = "WARLOCK", name = "warlock",
        layout = { preset = "dual", layers = { { pointOffset = { 38, -4 } }, { pointOffset = { 168, -4 } } } },
    },
    { id = "warrior", class = "WARRIOR", name = "warrior_base&protection", layout = "top" },
}

for _, entry in ipairs(entries) do
    D.textureConfigFallback[#D.textureConfigFallback + 1] = entry
end