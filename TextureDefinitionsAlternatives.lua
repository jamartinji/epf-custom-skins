-- [ ALTERNATIVE / MANUAL TEXTURES ] Spec alternatives, legacy skins, and CUSTOM entries.
-- Part of textureConfigFallback; load after RaceFaction; Extra atlas appends after this file.

EPF_CustomSkins_Definitions = EPF_CustomSkins_Definitions or {}
local D = EPF_CustomSkins_Definitions
D.textureConfigFallback = D.textureConfigFallback or {}

local entries = {
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
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 170, 0 },
                },
            },
        },
    },
    { class = "DRUID", name = "druid_balance", ext = "png", displayName = "Night Owl",
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
    { class = "DRUID", name = "druid_feral", ext = "png", displayName = "Fangs of Ashamane",
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
    { class = "DRUID", name = "druid_feral_savage", ext = "png", displayName = "Savage Feral Beast",
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
    { class = "DRUID", name = "druid_feral_savage", ext = "png", displayName = "Incarnation of Nightmare",
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
    { class = "DRUID", name = "druid_guardian", ext = "png", displayName = "Stonepaw",
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
    { class = "DRUID", name = "druid_restoration", ext = "png", displayName = "Warden's Crown",
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
    { class = "DRUID", name = "druid_guardian&restoration", ext = "png", displayName = "Alpha Claws",
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
    { class = "DRUID", name = "druid_guardian&restoration", ext = "png", displayName = "Gnarled Roots",
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
    { class = "DRUID", name = "druid", ext = "png", displayName = "Druid old",
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
    { class = "HUNTER", name = "hunter_mm_eagle", ext = "png", displayName = "Eagle Hunter",
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
    { class = "HUNTER", name = "hunter_survival", ext = "png", displayName = "Talonclawer",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 178, 0 },
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
    { class = "PRIEST", name = "priest", ext = "png", displayName = "Legacy priest",
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
    { class = "PRIEST", name = "priest_extras", ext = "png", displayName = "Tomekeeper's Spire",
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
    { class = "PRIEST", name = "priest_extras", ext = "png", displayName = "Sacred disciple",
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
    { class = "PRIEST", name = "priest_shadow", ext = "png", displayName = "Dark devotion",
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
    { class = "PRIEST", name = "priest_black_empire", ext = "png", displayName = "Xal'atath Blade",
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
    { class = "PRIEST", name = "priest_black_empire", ext = "png", displayName = "Black Empire",
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
    { class = "ROGUE", name = "rogue_assassination", ext = "png", displayName = "Kingslayer",
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
    { class = "ROGUE", name = "rogue_outlaw", ext = "png", displayName = "Dreadblades",
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
    { class = "CUSTOM", name = "corsairs", ext = "png", displayName = "Pirate",
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
    { class = "CUSTOM", name = "corsairs", ext = "png", displayName = "Corsair",
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
    { class = "CUSTOM", name = "void", ext = "png", displayName = "Void Shadow",
        singleLayer = true,
        layout = {
            layers = {
                {
                    topTexCoord = 256/512, bottomTexCoord = 512/512,
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
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 170, 0 },
                },
            },
        },
    },
    -- [ MANUAL-ONLY ] No class/race/spec; never auto-selected.
    { class = "CUSTOM", name = "blackdragon", ext = "png", displayName = "Black Dragon" },
}

for _, entry in ipairs(entries) do
    D.textureConfigFallback[#D.textureConfigFallback + 1] = entry
end
