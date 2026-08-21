-- [ TEXTURE DEFINITIONS ] Data only; no addon logic. Edit this file to add/change skins.
-- See Core.lua for spec-change handling and registration with ElitePlayerFrame_Enhanced.

EPF_CustomSkins_Definitions = EPF_CustomSkins_Definitions or {}

local D = EPF_CustomSkins_Definitions

D.folderPath = "Interface\\AddOns\\ElitePlayerFrame_Enhanced_CustomSkins\\assets\\"

-- Optional fields per textureConfig entry:
--   id       = short stable slug (3–12 chars). Used for SavedVariables / overrides; survives renames.
--              If omitted, a fallback slug is generated from name (+ displayName / spec).
--   class / spec / race / faction / name / ext / displayName / menuColor — as before.
--   layout = "top" | "bot" | "dual" | { preset = "bot", layers = {...}, restIconOffset = {...} }
--     "top"  = single layer, upper half of a 512 atlas (y 0-256). DEFAULT.
--     "bot"  = single layer, lower half of a 512 atlas (y 256-512).
--     "dual" = two layers (frame + portrait) using both halves — legacy multi-layer skins.
--   pointOffset = { x, y } — shorthand override for the portrait/single layer.
--   restIconOffset = { x, y } — optional rest-icon override.
--   dualLayer = true — alias for layout = "dual".
--   singleLayer / full custom layout tables still work for unusual crops (merged onto the preset).
--
-- Race examples (exact string): "Human", "Dwarf", "NightElf", "Gnome", "Draenei", "Worgen",
--   "Orc", "Scourge", "Tauren", "Troll", "BloodElf", "Goblin", "Pandaren",
--   "VoidElf", "LightforgedDraenei", "DarkIronDwarf", "KulTiran", "Mechagnome",
--   "Nightborne", "HighmountainTauren", "MagharOrc", "ZandalariTroll", "Vulpera",
--   "Dracthyr", "Earthen"

-- Shared layer sizes for 512-tall atlas halves.
local LAYER_TOP = {
    width = 280,
    height = 140,
    leftTexCoord = 0/512,
    rightTexCoord = 512/512,
    topTexCoord = 0/512,
    bottomTexCoord = 256/512,
    pointOffset = { 172, 0 },
}
local LAYER_BOT = {
    width = 280,
    height = 140,
    leftTexCoord = 0/512,
    rightTexCoord = 512/512,
    topTexCoord = 256/512,
    bottomTexCoord = 512/512,
    pointOffset = { 172, 0 },
}
-- Dual-layer frame crop uses the top half with the classic frame offset.
local LAYER_DUAL_FRAME = {
    width = 280,
    height = 140,
    leftTexCoord = 0/512,
    rightTexCoord = 512/512,
    topTexCoord = 0/512,
    bottomTexCoord = 256/512,
    pointOffset = { 42, 0 },
}

D.layoutPresets = {
    top = {
        singleLayer = true,
        layout = {
            layers = { LAYER_TOP },
            restIconOffset = { 0, 0 },
        },
    },
    bot = {
        singleLayer = true,
        layout = {
            layers = { LAYER_BOT },
            restIconOffset = { 0, 0 },
        },
    },
    dual = {
        singleLayer = false,
        layout = {
            layers = { LAYER_DUAL_FRAME, LAYER_BOT },
            restIconOffset = { 0, 0 },
        },
    },
}

-- Default for new entries: single-layer top half.
D.defaultLayoutPreset = "top"
-- Kept for callers that still pass defaultFrameLayout into SkinBuilder (dual geometry).
D.defaultFrameLayout = D.layoutPresets.dual.layout


-- Ordered list (array); first matching entry wins. Put more specific before generic.
-- This file contains specialization-specific rules only.
D.textureConfigSpec = {

    -- [ DEATH KNIGHT ]
    { id = "dkbloo250", class = "DEATHKNIGHT", spec = 250, name = "dk_blood-by-benjiro_blue", ext = "png",
        layout = {
            layers = {
                {
                    width = 280,
                    height = 163,
                    leftTexCoord = 0/512,
                    rightTexCoord = 512/512,
                    topTexCoord = 216/512,
                    bottomTexCoord = 512/512,
                    pointOffset = { 190, -2 },
                },
            },
        },
    },      -- Blood
    { id = "dkunho251", class = "DEATHKNIGHT", spec = 251, name = "dk_frost", ext = "png",
        layout = "bot",
        pointOffset = { 188, 0 },
    },      -- Frost
    { id = "dkunho252", class = "DEATHKNIGHT", spec = 252, name = "dk_unholy", ext = "png",
        layout = "top",
        pointOffset = { 182, 0 },
    },     -- Unholy

    -- [ DEMON HUNTER ]
    -- { class = "DEMONHUNTER", spec = 577, name = "dh_havoc", ext = "png" },      -- Havoc
    -- { class = "DEMONHUNTER", spec = 581, name = "dh_vengeance", ext = "png" },  -- Vengeance
    { id = "dhdevo1480", class = "DEMONHUNTER", spec = 1480, name = "dh_devourer", ext = "png",
        layout = "bot",
        pointOffset = { 170, 0 },
    },  -- Devourer

    -- [ DRUID ]
    { id = "druidb102", class = "DRUID", spec = 102, name = "druid_balance", ext = "png",
        layout = "bot",
    },       -- Balance
    { id = "druidf103", class = "DRUID", spec = 103, name = "druid_feral", ext = "png",
        layout = "top",
    },         -- Feral
    { id = "druidg104", class = "DRUID", spec = 104, name = "druid_guardian", ext = "png",
        layout = "top",
    },      -- Guardian
    { id = "druidr105", class = "DRUID", spec = 105, name = "druid_restoration", ext = "png",
        layout = "bot",
    },         -- Restoration

    -- [ EVOKER ]
    -- { class = "EVOKER", spec = 1467, name = "evoker_devastation", ext = "png" },-- Devastation
    -- { class = "EVOKER", spec = 1468, name = "evoker_preservation", ext = "png" },-- Preservation
    -- { class = "EVOKER", spec = 1473, name = "evoker_augmentation", ext = "png" },-- Augmentation

    -- [ HUNTER ]
    { id = "hunter253", class = "HUNTER", spec = 253, name = "hunter_base&bm", ext = "png",
        layout = "bot",
        pointOffset = { 198, 0 },
    },          -- Beast Mastery
    { id = "hunter254", class = "HUNTER", spec = 254, name = "hunter_mm_eagle", ext = "png",
        layout = "bot",
    },          -- Marksmanship
    { id = "hunter255", class = "HUNTER", spec = 255, name = "hunter_survival", ext = "png",
        layout = "bot",
    },    -- Survival

    -- [ MAGE ]
    { id = "mage62", class = "MAGE", spec = 62, name = "mage", ext = "png",
        layout = "top",
    },           -- Arcane
    { id = "firefr63", class = "MAGE", spec = 63, name = "firefrost", ext = "png",
        layout = "top",
    },             -- Fire
    { id = "firefr64", class = "MAGE", spec = 64, name = "firefrost", ext = "png",
        layout = "bot",
    },            -- Frost

    -- [ MONK ]
    { id = "monkba268", class = "MONK", spec = 268, name = "monk_base&brew", ext = "png",
        layout = "bot",
        pointOffset = { 161, 0 },
    },      -- Brewmaster
    { id = "monkmi270", class = "MONK", spec = 270, name = "monk_mist&wind", ext = "png",
        layout = "top",
    },      -- Mistweaver
    { id = "monkmi269", class = "MONK", spec = 269, name = "monk_mist&wind", ext = "png",
        layout = "bot",
    },      -- Windwalker

    -- [ PALADIN ]
    { id = "paladi65", class = "PALADIN", spec = 65, name = "paladin_base&holy", ext = "png",
        layout = "bot",
    },        -- Holy
    { id = "paladi66", class = "PALADIN", spec = 66, name = "paladin_protection", ext = "png",
        layout = "bot",
        pointOffset = { 192, -8 },
        restIconOffset = { 190, 0 },
    },       -- Protection
    { id = "paladi70", class = "PALADIN", spec = 70, name = "paladin_retribution", ext = "png",
        layout = "top",
    },        -- Retribution

    -- [ PRIEST ]
    { id = "priest256", class = "PRIEST", spec = 256, name = "priest_discipline&holy", ext = "png",
        layout = "top",
        pointOffset = { 182, 0 },
    },        -- Discipline
    { id = "priest257", class = "PRIEST", spec = 257, name = "priest_discipline&holy", ext = "png",
        layout = "bot",
    },        -- Holy
    { id = "priest258", class = "PRIEST", spec = 258, name = "priest_shadow", ext = "png",
        layout = "top",
    },      -- Shadow
    -- [ ROGUE ]
    { id = "roguea259", class = "ROGUE", spec = 259, name = "rogue_assassination", ext = "png",
        layout = "top",
    }, -- Assassination
    { id = "rogueo260", class = "ROGUE", spec = 260, name = "rogue_outlaw", ext = "png",
        layout = "top",
    },        -- Outlaw
    { id = "rogueb261", class = "ROGUE", spec = 261, name = "rogue_base&subtley", ext = "png",
        layout = "bot",
    },      -- Subtlety

    -- [ SHAMAN ]
    { id = "shaman262", class = "SHAMAN", spec = 262, name = "shaman_elemental&enhancement", ext = "png",
        layout = "top",
    },   -- Elemental
    { id = "shaman263", class = "SHAMAN", spec = 263, name = "shaman_elemental&enhancement", ext = "png",
        layout = "bot",
    }, -- Enhancement
    { id = "shaman264", class = "SHAMAN", spec = 264, name = "shaman_base&resto", ext = "png",
        layout = "bot",
    },       -- Restoration

    -- [ WARLOCK ]
    -- Affliction: overrides only pointOffset from default layout.
    { id = "warloc265", class = "WARLOCK", spec = 265, name = "warlock_affliction", ext = "png",
        layout = { preset = "dual", layers = { { pointOffset = { 42, -10 } }, { pointOffset = { 172, -10 } } } },
    },
    { id = "warloc266", class = "WARLOCK", spec = 266, name = "warlock_demonology", ext = "png", layout = "dual" },-- Demonology
    { id = "warloc267", class = "WARLOCK", spec = 267, name = "warlock_destruction", ext = "png",
        layout = { preset = "dual", layers = { { pointOffset = { 42, 6 } }, { pointOffset = { 172, 6 } } } },
    },    -- Destruction

    -- [ WARRIOR ]
    { id = "warrio71", class = "WARRIOR", spec = 71, name = "warrior_arms&fury", ext = "png",
        layout = "bot",
        pointOffset = { 172, 6 },
    },       -- Arms
    { id = "warrio72", class = "WARRIOR", spec = 72, name = "warrior_arms&fury", ext = "png",
        layout = "top",
    },       -- Fury
    { id = "warrio73", class = "WARRIOR", spec = 73, name = "warrior_base&protection", ext = "png",
        layout = "bot",
        pointOffset = { 172, -18 },
    },       -- Protection
}