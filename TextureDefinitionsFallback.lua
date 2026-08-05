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
    { class = "HUNTER", name = "hunter_base&bm", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0 / 512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "HUNTER", name = "hunter_mm_eagle", ext = "png", displayName = "Eagle Hunter",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 256/512, bottomTexCoord = 512/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "HUNTER", name = "hunter_mm_white", ext = "png", displayName = "Azure Thas'dorah",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
        { class = "HUNTER", name = "hunter_mm_white", ext = "png", displayName = "Azure Eagle",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 256/512, bottomTexCoord = 512/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "HUNTER", name = "hunter_mm_banshee", ext = "png", displayName = "Nelf Thas'dorah",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
        { class = "HUNTER", name = "hunter_mm_banshee", ext = "png", displayName = "Banshee Redemption",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 256/512, bottomTexCoord = 512/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "MAGE", name = "mage", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 256 / 512, bottomTexCoord = 512/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "MONK", name = "monk_base&brew", ext = "png", displayName="Celestials",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 10 },
                },
            },
        },
    },
    { class = "MONK", name = "monk", ext = "png", displayName="Zen Legacy",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 10 },
                },
            },
        },
    },
    { class = "MONK", name = "monk", ext = "png", displayName="Niuzao Spirit",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 256/512, bottomTexCoord = 512/512,
                    pointOffset = { 160, 0 },
                },
            },
        },
    },
    { class = "PALADIN", name = "paladin_base&holy", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 170, 0 },
                },
            },
        },
    },
    { class = "PALADIN", name = "paladin_protection", ext = "png", displayName="Judgement Charger",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 192, -8 },
                },
            },
            restIconOffset = { 210, 0 },
        },
    },
    { class = "PALADIN", name = "paladin_retribution", ext = "png", displayName="Ashbringer Judgement",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 256/512, bottomTexCoord = 512/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "PRIEST", name = "priest", ext = "png" },
    { class = "ROGUE", name = "rogue", ext = "png" },
    { class = "SHAMAN", name = "shaman_base&resto", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },
    { class = "WARLOCK", name = "warlock", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 38, -4 } },
                { pointOffset = { 168, -4 } },
            },
        },
    },
    { class = "WARRIOR", name = "warrior_base&protection", ext = "png",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },

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
    { class = "DEATHKNIGHT", spec = 251, name = "dk_frost-by-benjiro_blue", ext = "png", displayName = "Frost by Benjiro Blue",
        singleLayer = true,
        layout = {
            layers = {
                {
                    width = 280,
                    height = 163,
                    leftTexCoord = 0/512,
                    rightTexCoord = 512/512,
                    topTexCoord = 216/512,
                    bottomTexCoord = 512/512,
                    pointOffset = { 190, -12 },
                },
            },
        },
    },
    { class = "DEMONHUNTER", spec = 1480, name = "dh_devourer", ext = "png", displayName = "Devourer Horns",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512,
                    bottomTexCoord = 256/512,
                    pointOffset = { 170, 0 },
                },
            },
        },
    },
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
    { class = "CUSTOM", name = "void", ext = "png", displayName = "Void Matter",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512,
                    bottomTexCoord = 256/512,
                    pointOffset = { 170, 0 },
                },
            },
        },
    },
    -- [ MANUAL-ONLY ] No class/race/spec; never auto-selected.
    { class = "CUSTOM", name = "blackdragon", ext = "png", displayName = "Black Dragon" },
}
