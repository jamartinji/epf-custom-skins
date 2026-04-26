-- [ FALLBACK TEXTURE DEFINITIONS ] Class defaults, race/faction and manual alternatives.
-- Loaded after TextureDefinitions.lua and merged in Core.lua.

EPF_CustomSkins_Definitions = EPF_CustomSkins_Definitions or {}
local D = EPF_CustomSkins_Definitions

D.textureConfigFallback = {
    -- [ GENERIC CLASS TEXTURES ] Used when no specialization-specific entry matches.
    -- { class = "DEATHKNIGHT", name = "deathknight", ext = "png" },
    -- { class = "DEMONHUNTER", name = "demonhunter", ext = "png" },
    { class = "DRUID", name = "druid", ext = "png" },
    { class = "EVOKER", name = "evoker", ext = "png" },
    { class = "HUNTER", name = "hunter", ext = "png" },
    { class = "MAGE", name = "mage", ext = "png",
        layout = {
            layers = {
                {
                    width = 1, height = 1, pointOffset = { 0, 0 },  -- Hide first layer
                    leftTexCoord = 0, rightTexCoord = 0, topTexCoord = 0, bottomTexCoord = 0,
                },
                {
                    topTexCoord = 256/512, bottomTexCoord = 512/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "MONK", name = "monk", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 42, 10 } },
                { pointOffset = { 172, 10 } },
            },
        },
    },
    { class = "PALADIN", name = "paladin", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 62, -8 } },
                { pointOffset = { 192, -8 } },
            },
            restIconOffset = { 210, 0 },
        },
    },
    { class = "PRIEST", name = "priest", ext = "png" },
    { class = "ROGUE", name = "rogue", ext = "png" },
    { class = "SHAMAN", name = "shaman", ext = "png" },
    { class = "WARLOCK", name = "warlock", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 38, -4 } },
                { pointOffset = { 168, -4 } },
            },
        },
    },
    { class = "WARRIOR", name = "warrior", ext = "png" },

    -- [ GENERIC RACE TEXTURES ] Used when no class texture matched.
    { race = "Dracthyr", name = "dracthyr", ext = "png" },
    { race = "Scourge", name = "undead", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 42, 16 } },
                { pointOffset = { 172, 16 } },
            },
        },
    },
    { race = "Pandaren", name = "pandaren", ext = "png" },

    -- [ FACTION (no class) ] Last auto fallback.
    { faction = "Alliance", name = "alliance", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 42, -2} },
                { pointOffset = { 171, -3 } },
            },
        },
    },
    { faction = "Horde", name = "horde", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 65, -10 } },
                { pointOffset = { 195, -10 } },
            },
        },
    },

    -- [ ALTERNATIVE TEXTURES ]
    { class = "PRIEST", name = "priest_black_empire", ext = "png", displayName = "Black Empire" },
    { class = "WARLOCK", name = "warlock_red", ext = "png", displayName = "Warlock (Old Red)" },
    { class = "WARLOCK", name = "fel_corruption", ext = "png", displayName = "Fel corruption" },
    { class = "WARLOCK", name = "destro_succubus", ext = "png", displayName = "Inferno Succubus",
        layout = {
            layers = {
                { pointOffset = { 42, 6 } },
                { pointOffset = { 172, 6 } },
            },
        },
    },
    { class = "CUSTOM", name = "void", ext = "png", displayName = "Void Shadow",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 256/512,
                    bottomTexCoord = 512/512,
                    pointOffset = { 170, 0 },
                },
            },
        },
    },

    -- [ MANUAL-ONLY ] No class/race/spec; never auto-selected.
    { class = "CUSTOM", name = "blackdragon", ext = "png", displayName = "Black Dragon" },
}
