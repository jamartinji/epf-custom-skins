-- [ CLASS-ONLY FALLBACK TEXTURES ] Generic class defaults when no spec entry matches.
-- Part of textureConfigFallback; load order: ClassOnly -> RaceFaction -> Alternatives -> Extra.

EPF_CustomSkins_Definitions = EPF_CustomSkins_Definitions or {}
local D = EPF_CustomSkins_Definitions
D.textureConfigFallback = D.textureConfigFallback or {}

local entries = {
    -- { class = "DEATHKNIGHT", name = "deathknight", ext = "png" },
    -- { class = "DEMONHUNTER", name = "demonhunter", ext = "png" },
    { class = "DRUID", name = "druid", ext = "png",
        layout = "top",
    },
    { class = "EVOKER", name = "evoker", ext = "png", layout = "dual" },
    { class = "HUNTER", name = "hunter_base&bm", ext = "png",
        layout = "top",
    },
    { class = "MAGE", name = "mage", ext = "png",
        layout = "bot",
    },
    { class = "MONK", name = "monk_base&brew", ext = "png",
        layout = "top",
        pointOffset = { 172, 10 },
    },
    { class = "PRIEST", name = "priest", ext = "png",
        layout = "top",
    },
    { class = "ROGUE", name = "rogue_base&subtley", ext = "png",
        layout = "top",
    },
    { class = "SHAMAN", name = "shaman_base&resto", ext = "png",
        layout = "top",
    },
    { class = "WARLOCK", name = "warlock", ext = "png",
        layout = { preset = "dual", layers = { { pointOffset = { 38, -4 } }, { pointOffset = { 168, -4 } } } },
    },
    { class = "WARRIOR", name = "warrior_base&protection", ext = "png",
        layout = "top",
    },
}

for _, entry in ipairs(entries) do
    D.textureConfigFallback[#D.textureConfigFallback + 1] = entry
end
