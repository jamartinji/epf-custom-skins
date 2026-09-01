-- [ TEXTURE DEFINITIONS ] Data only; no addon logic. Edit this file to add/change skins.
-- See Core.lua for spec-change handling and registration with ElitePlayerFrame_Enhanced.

EPF_CustomSkins_Definitions = EPF_CustomSkins_Definitions or {}

local D = EPF_CustomSkins_Definitions

D.folderPath = "Interface\\AddOns\\ElitePlayerFrame_Enhanced_CustomSkins\\assets\\"

-- Optional fields per textureConfig entry:
--   id       = short stable slug (3–12 chars). Used for SavedVariables / overrides; survives renames.
--              If omitted, a fallback slug is generated from name (+ displayName / spec).
--   class / spec / race / faction / name / displayName / menuColor — as before.
--   ext      = optional file extension; defaults to "png" if omitted.
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
    { id = "dkbloo250", class = "DEATHKNIGHT", spec = 250, name = "dk_blood", layout = "top" }, -- Blood
    { id = "dkunho251", class = "DEATHKNIGHT", spec = 251, name = "dk_frost", layout = "bot", pointOffset = { 188, 0 }, restIconOffset = { 30, 5 } }, -- Frost
    { id = "dkunho252", class = "DEATHKNIGHT", spec = 252, name = "dk_unholy", layout = "top", pointOffset = { 178, 0 } }, -- Unholy

    -- [ DEMON HUNTER ]
    { id = "dhhavoc577", class = "DEMONHUNTER", spec = 577, name = "dh_havoc", layout = "top" }, -- Havoc
    { id = "dhvenge581", class = "DEMONHUNTER", spec = 581, name = "dh_vengeance", layout = "top" }, -- Vengeance
    { id = "dhdevo1480", class = "DEMONHUNTER", spec = 1480, name = "dh_devourer", layout = "top", pointOffset = { 170, 0 } }, -- Devourer

    -- [ DRUID ]
    { id = "druidb102", class = "DRUID", spec = 102, name = "druid_balance", layout = "bot" }, -- Balance
    { id = "druidf103", class = "DRUID", spec = 103, name = "druid_feral", layout = "top" }, -- Feral
    { id = "druidg104", class = "DRUID", spec = 104, name = "druid_guardian", layout = "top" }, -- Guardian
    { id = "druidr105", class = "DRUID", spec = 105, name = "druid_restoration", layout = "bot" }, -- Restoration

    -- [ EVOKER ]
    { id = "evoker1467", class = "EVOKER", spec = 1467, name = "evoker_ruby", layout = "top" }, -- Devastation
    { id = "evoker1468", class = "EVOKER", spec = 1468, name = "evoker_emerald", layout = "top" }, -- Preservation
    { id = "evoker1473", class = "EVOKER", spec = 1473, name = "evoker_obsidian", layout = "top" }, -- Augmentation

    -- [ HUNTER ]
    { id = "hunter253", class = "HUNTER", spec = 253, name = "hunter_base&bm", layout = "bot", pointOffset = { 198, 0 }, }, -- Beast Mastery
    { id = "hunter254", class = "HUNTER", spec = 254, name = "hunter_mm_eagle", layout = "bot" }, -- Marksmanship
    { id = "hunter255", class = "HUNTER", spec = 255, name = "hunter_survival", layout = "bot" }, -- Survival

    -- [ MAGE ]
    { id = "mage62", class = "MAGE", spec = 62, name = "mage", layout = "top" }, -- Arcane
    { id = "firefr63", class = "MAGE", spec = 63, name = "firefrost", layout = "top" }, -- Fire
    { id = "firefr64", class = "MAGE", spec = 64, name = "firefrost", layout = "bot" }, -- Frost

    -- [ MONK ]
    { id = "monkba268", class = "MONK", spec = 268, name = "monk_base&brew", layout = "bot", pointOffset = { 161, 0 }, }, -- Brewmaster
    { id = "monkmi270", class = "MONK", spec = 270, name = "monk_mist&wind", layout = "top" }, -- Mistweaver
    { id = "monkmi269", class = "MONK", spec = 269, name = "monk_mist&wind", layout = "bot" }, -- Windwalker

    -- [ PALADIN ]
    { id = "paladi65", class = "PALADIN", spec = 65, name = "paladin_base&holy", layout = "bot" }, -- Holy
    { id = "paladi66", class = "PALADIN", spec = 66, name = "paladin_protection", layout = "bot", pointOffset = { 192, -8 }, restIconOffset = { 190, 0 } }, -- Protection
    { id = "paladi70", class = "PALADIN", spec = 70, name = "paladin_retribution", layout = "top" }, -- Retribution

    -- [ PRIEST ]
    { id = "priest256", class = "PRIEST", spec = 256, name = "priest_discipline&holy", layout = "top", pointOffset = { 182, 0 } }, -- Discipline
    { id = "priest257", class = "PRIEST", spec = 257, name = "priest_discipline&holy", layout = "bot" }, -- Holy
    { id = "priest258", class = "PRIEST",  spec = 258, name = "priest_shadow",                layout = "top" }, -- Shadow

    -- [ ROGUE ]
    { id = "roguea259", class = "ROGUE", spec = 259, name = "rogue_assassination", layout = "top" }, -- Assassination
    { id = "rogueo260", class = "ROGUE", spec = 260, name = "rogue_outlaw", layout = "top" }, -- Outlaw
    { id = "rogueb261", class = "ROGUE", spec = 261, name = "rogue_base&subtley", layout = "bot" }, -- Subtlety

    -- [ SHAMAN ]
    { id = "shaman262", class = "SHAMAN", spec = 262, name = "shaman_elemental&enhancement", layout = "top" }, -- Elemental
    { id = "shaman263", class = "SHAMAN", spec = 263, name = "shaman_elemental&enhancement", layout = "bot" }, -- Enhancement
    { id = "shaman264", class = "SHAMAN", spec = 264, name = "shaman_base&resto", layout = "bot" }, -- Restoration

    -- [ WARLOCK ]
    -- Affliction: overrides only pointOffset from default layout.
    { id = "warloc265", class = "WARLOCK", spec = 265, name = "warlock_affliction",
        layout = { preset = "dual", layers = { { pointOffset = { 42, -10 } }, { pointOffset = { 172, -10 } } } },
    }, -- Affliction
    { id = "warloc266", class = "WARLOCK", spec = 266, name = "warlock_demonology", layout = "dual" }, -- Demonology
    { id = "warloc267", class = "WARLOCK", spec = 267, name = "warlock_destruction",
        layout = { preset = "dual", layers = { { pointOffset = { 42, 6 } }, { pointOffset = { 172, 6 } } } },
    }, -- Destruction

    -- [ WARRIOR ]
    { id = "warrio71", class = "WARRIOR", spec = 71, name = "warrior_arms&fury", layout = "bot", pointOffset = { 172, 6 }, }, -- Arms
    { id = "warrio72", class = "WARRIOR", spec = 72, name = "warrior_arms&fury", layout = "top" }, -- Fury
    { id = "warrio73", class = "WARRIOR", spec = 73, name = "warrior_base&protection", layout = "bot", pointOffset = { 172, -18 }, }, -- Protection
}