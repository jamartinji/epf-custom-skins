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

-- Ordered list (array); first matching entry wins. Put more specific before generic.
-- This file contains specialization-specific rules only.
D.textureConfigSpec = {

    -- [ DEATH KNIGHT ]
    -- { class = "DEATHKNIGHT", spec = 250, name = "dk_blood", ext = "png" },      -- Blood
    -- { class = "DEATHKNIGHT", spec = 251, name = "dk_frost", ext = "png" },      -- Frost
    -- { class = "DEATHKNIGHT", spec = 252, name = "dk_unholy", ext = "png" },     -- Unholy

    -- [ DEMON HUNTER ]
    -- { class = "DEMONHUNTER", spec = 577, name = "dh_havoc", ext = "png" },      -- Havoc
    -- { class = "DEMONHUNTER", spec = 581, name = "dh_vengeance", ext = "png" },  -- Vengeance
    { class = "DEMONHUNTER", spec = 1480, name = "void", ext = "png",
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
    },  -- Devourer (default: top variant)

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
    { class = "MAGE", spec = 62, name = "mage", ext = "png",
        layout = {
            layers = {
                {
                    width = 1, height = 1, pointOffset = { 0, 0 },  -- Hide first layer
                    leftTexCoord = 0, rightTexCoord = 0, topTexCoord = 0, bottomTexCoord = 0,
                },
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },           -- Arcane
    { class = "MAGE", spec = 63, name = "firefrost", ext = "png",
        layout = {
            layers = {
                {
                    width = 1, height = 1, pointOffset = { 0, 0 },  -- Hide first layer
                    leftTexCoord = 0, rightTexCoord = 0, topTexCoord = 0, bottomTexCoord = 0,
                },
                {
                    topTexCoord = 0/512, bottomTexCoord = 256/512,
                    pointOffset = { 172, 0 },
                },
            },
        },
    },             -- Fire
    { class = "MAGE", spec = 64, name = "firefrost", ext = "png",
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
    },            -- Frost

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
    { class = "PRIEST", spec = 258, name = "priest_shadow", ext = "png" },      -- Shadow

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
}
