-- [ RACE & FACTION FALLBACK TEXTURES ] Used when no class texture matched.
-- Part of textureConfigFallback; load after TextureDefinitionsClassOnly.lua.

EPF_CustomSkins_Definitions = EPF_CustomSkins_Definitions or {}
local D = EPF_CustomSkins_Definitions
D.textureConfigFallback = D.textureConfigFallback or {}

local entries = {
    -- [ GENERIC RACE TEXTURES ]
    { id = "dracthyr", race = "Dracthyr", name = "dracthyr", layout = "dual" },
    { id = "undead", race = "Scourge", name = "undead",
        layout = { preset = "dual", layers = { { pointOffset = { 42, 16 } }, { pointOffset = { 172, 16 } } } },
    },
    { id = "pandaren", race = "Pandaren", name = "pandaren", layout = "dual" },

    -- [ FACTION (no class) ] Last auto fallback among race/faction (before alternatives).
    { id = "alliance", faction = "Alliance", name = "alliance",
        layout = { preset = "dual", layers = { { pointOffset = { 42, -2 } }, { pointOffset = { 171, -3 } } } },
    },
    { id = "horde", faction = "Horde", name = "horde",
        layout = { preset = "dual", layers = { { pointOffset = { 65, -10 } }, { pointOffset = { 195, -10 } } } },
    },
}

for _, entry in ipairs(entries) do
    D.textureConfigFallback[#D.textureConfigFallback + 1] = entry
end