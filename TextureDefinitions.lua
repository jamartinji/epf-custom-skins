-- [ TEXTURE DEFINITIONS ] Data only; no addon logic. Edit this file to add/change skins.
-- See Core.lua for spec-change handling and registration with ElitePlayerFrame_Enhanced.

EPF_CustomSkins_Definitions = EPF_CustomSkins_Definitions or {}

local D = EPF_CustomSkins_Definitions

D.folderPath = "Interface\\AddOns\\ElitePlayerFrame_Enhanced_CustomSkins\\assets\\"

-- Optional fields per textureConfig entry:
--   class   = optional; e.g. "WARLOCK", "DRUID". Omit for race-only entries (use displayName).
--   spec    = optional, specialization ID (e.g. 265 = Affliction)
--   race    = optional, race file string from API (see examples below)
--   faction = optional, "Alliance" or "Horde" (respects /epf faction when set)
--   name        = texture file name (without path/extension)
--   ext         = file extension, e.g. "png"
--   displayName = optional; menu label (e.g. for manual-only textures)
--   singleLayer = optional; if true, only one layer is used (Portrait/top). Define just layout.layers[1] with the correct offset.
--   layout      = optional; table with layers and/or restIconOffset. If set, each layer is merged with
--                 defaultFrameLayout: only declare fields you want to override (e.g. pointOffset).
--   menuColor   = optional; hex color code for the menu name (e.g. "00ff00" or "|cff00ff00").
--
-- Race examples (exact string): "Human", "Dwarf", "NightElf", "Gnome", "Draenei", "Worgen",
--   "Orc", "Scourge", "Tauren", "Troll", "BloodElf", "Goblin", "Pandaren",
--   "VoidElf", "LightforgedDraenei", "DarkIronDwarf", "KulTiran", "Mechagnome",
--   "Nightborne", "HighmountainTauren", "MagharOrc", "ZandalariTroll", "Vulpera",
--   "Dracthyr", "Earthen"

-- [ FRAME LAYOUT ] Sizes, texture coordinates and positions per layer.
-- Each textureConfig entry may use the default layout or define its own "layout".
-- layout = { layers = { { width, height, leftTexCoord, rightTexCoord, topTexCoord, bottomTexCoord, pointOffset = {x,y} }, ... }, restIconOffset = {x,y} }
D.defaultFrameLayout = {
    layers = {
        {
            width = 280,
            height = 140,
            leftTexCoord = 0/512,
            rightTexCoord = 512/512,
            topTexCoord = 0/512,
            bottomTexCoord = 256/512,
            pointOffset = { 42, 0 },
        },
        {
            width = 280,
            height = 140,
            leftTexCoord = 0/512,
            rightTexCoord = 512/512,
            topTexCoord = 256/512,
            bottomTexCoord = 512/512,
            pointOffset = { 172, 0 },
        },
    },
    restIconOffset = { 0, 0 },
}

-- Ordered list (array); first matching entry wins. Put more specific (e.g. race+spec+faction) before generic.
D.textureConfig = {

    -- [ RACE / FACTION SPECIFIC TEXTURES ] Optional "race" or "faction".
    -- Examples: { class = "WARLOCK", race = "Human", name = "warlock_human", ext = "png" };
    --           { class = "WARLOCK", spec = 265, race = "Scourge", name = "warlock_affliction_undead", ext = "png" };
    --           { class = "DEATHKNIGHT", faction = "Horde", name = "dk_horde", ext = "png" },

    -- [ SPECIALIZATION SPECIFIC TEXTURES ] Uncomment and edit to use per-spec textures.

    -- [ DEATH KNIGHT ]
    -- { class = "DEATHKNIGHT", spec = 250, name = "dk_blood", ext = "png" },      -- Blood
    -- { class = "DEATHKNIGHT", spec = 251, name = "dk_frost", ext = "png" },      -- Frost
    -- { class = "DEATHKNIGHT", spec = 252, name = "dk_unholy", ext = "png" },     -- Unholy

    -- [ DEMON HUNTER ]
    -- { class = "DEMONHUNTER", spec = 577, name = "dh_havoc", ext = "png" },      -- Havoc
    -- { class = "DEMONHUNTER", spec = 581, name = "dh_vengeance", ext = "png" },  -- Vengeance
    -- { class = "DEMONHUNTER", spec = ????, name = "dh_devourer", ext = "png" },  -- Devourer

    -- [ DRUID ]
    -- { class = "DRUID", spec = 102, name = "druid_balance", ext = "png" },       -- Balance
    -- { class = "DRUID", spec = 103, name = "druid_feral", ext = "png" },         -- Feral
    { class = "DRUID", spec = 104, name = "druid_guardian", ext = "png" },      -- Guardian
    { class = "DRUID", spec = 105, name = "druid_resto", ext = "png" },         -- Restoration

    -- [ EVOKER ]
    -- { class = "EVOKER", spec = 1467, name = "evoker_devastation", ext = "png" },-- Devastation
    -- { class = "EVOKER", spec = 1468, name = "evoker_preservation", ext = "png" },-- Preservation
    -- { class = "EVOKER", spec = 1473, name = "evoker_augmentation", ext = "png" },-- Augmentation

    -- [ HUNTER ]
    -- { class = "HUNTER", spec = 253, name = "hunter_bm", ext = "png" },          -- Beast Mastery
    -- { class = "HUNTER", spec = 254, name = "hunter_mm", ext = "png" },          -- Marksmanship
    -- { class = "HUNTER", spec = 255, name = "hunter_survival", ext = "png" },    -- Survival

    -- [ MAGE ]
    -- { class = "MAGE", spec = 62, name = "mage_arcane", ext = "png" },           -- Arcane
    -- { class = "MAGE", spec = 63, name = "mage_fire", ext = "png" },             -- Fire
    -- { class = "MAGE", spec = 64, name = "mage_frost", ext = "png" },            -- Frost

    -- [ MONK ]
    -- { class = "MONK", spec = 268, name = "monk_brewmaster", ext = "png" },      -- Brewmaster
    -- { class = "MONK", spec = 270, name = "monk_mistweaver", ext = "png" },      -- Mistweaver
    -- { class = "MONK", spec = 269, name = "monk_windwalker", ext = "png" },      -- Windwalker

    -- [ PALADIN ]
    -- { class = "PALADIN", spec = 65, name = "paladin_holy", ext = "png" },       -- Holy
    -- { class = "PALADIN", spec = 66, name = "paladin_prot", ext = "png" },       -- Protection
    -- { class = "PALADIN", spec = 70, name = "paladin_ret", ext = "png" },        -- Retribution

    -- [ PRIEST ]
    -- { class = "PRIEST", spec = 256, name = "priest_disc", ext = "png" },        -- Discipline
    -- { class = "PRIEST", spec = 257, name = "priest_holy", ext = "png" },        -- Holy
    -- { class = "PRIEST", spec = 258, name = "priest_shadow", ext = "png" },      -- Shadow

    -- [ ROGUE ]
    { class = "ROGUE", spec = 259, name = "rogue_assassination", ext = "png" }, -- Assassination
    -- { class = "ROGUE", spec = 260, name = "rogue_outlaw", ext = "png" },        -- Outlaw
    -- { class = "ROGUE", spec = 261, name = "rogue_subtlety", ext = "png" },      -- Subtlety

    -- [ SHAMAN ]
    -- { class = "SHAMAN", spec = 262, name = "shaman_elemental", ext = "png" },   -- Elemental
    -- { class = "SHAMAN", spec = 263, name = "shaman_enhancement", ext = "png" }, -- Enhancement
    -- { class = "SHAMAN", spec = 264, name = "shaman_resto", ext = "png" },       -- Restoration

    -- [ WARLOCK ]
    -- Affliction: overrides only pointOffset from default layout.
    { class = "WARLOCK", spec = 265, name = "warlock_affliction", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 42, -10 } },
                { pointOffset = { 172, -10 } },
            },
        },
    },
    { class = "WARLOCK", spec = 266, name = "warlock_demonology", ext = "png" },-- Demonology
    { class = "WARLOCK", spec = 267, name = "warlock_destro", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 42, 6 } },
                { pointOffset = { 172, 6 } },
            },
        },
    },    -- Destruction

    -- [ WARRIOR ]
    -- { class = "WARRIOR", spec = 71, name = "warrior_arms", ext = "png" },       -- Arms
    -- { class = "WARRIOR", spec = 72, name = "warrior_fury", ext = "png" },       -- Fury
    -- { class = "WARRIOR", spec = 73, name = "warrior_prot", ext = "png" },       -- Protection

    -- [ GENERIC CLASS TEXTURES ] Used when no specialization above matches.
    -- { class = "DEATHKNIGHT", name = "deathknight", ext = "png" },
    -- { class = "DEMONHUNTER", name = "demonhunter", ext = "png" },
    { class = "DRUID", name = "druid", ext = "png" },
    { class = "EVOKER", name = "evoker", ext = "png" },
    { class = "HUNTER", name = "hunter", ext = "png" },
    -- { class = "MAGE",        name = "mage",        ext = "png" },
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
    -- { class = "PRIEST",      name = "priest",      ext = "png" },
    { class = "ROGUE", name = "rogue", ext = "png" },
    { class = "SHAMAN", name = "shaman", ext = "png" },
    -- { class = "WARLOCK",     name = "warlock",     ext = "png" },
    -- { class = "WARRIOR",     name = "warrior",     ext = "png" },

    -- [ GENERIC RACE TEXTURES ] Used when no specialization above matches.
    -- Race-only (no class): any Undead character. Use displayName; class is omitted.
    { race = "Dracthyr", name = "dracthyr", ext = "png", displayName = "Dracthyr" },
    { race = "Scourge", name = "undead", ext = "png", displayName = "Undead",
        layout = {
            layers = {
                { pointOffset = { 42, 16 } },
                { pointOffset = { 172, 16 } },
            },
        },
    },
    { race = "Pandaren", name = "pandaren", ext = "png", displayName = "Pandaren" },

    -- [ FACTION (no class) ] After class/race; used when no class texture matched.
    { faction = "Alliance", name = "alliance", ext = "png", displayName = "Alliance", menuColor = "36579e",
        layout = {
            layers = {
                { pointOffset = { 42, -2} },
                { pointOffset = { 171, -3 } },
            },
        },
    },
    { faction = "Horde", name = "horde", ext = "png", displayName = "Horde", menuColor = "b01b1b",
        layout = {
            layers = {
                { pointOffset = { 65, -10 } },
                { pointOffset = { 195, -10 } },
            },
        },
    },

    -- [ ALTERNATIVE TEXTURES ]
    { class = "WARLOCK", name = "warlock", ext = "png",
        layout = {
            layers = {
                { pointOffset = { 38, -4 } },
                { pointOffset = { 168, -4 } },
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

    -- [ MANUAL-ONLY ] No class/race/spec; never auto-selected. Choose via /epf frame N.
    { class = "CUSTOM", name = "blackdragon", ext = "png", displayName = "Black Dragon" },
}
