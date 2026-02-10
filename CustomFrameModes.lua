local folderPath = "Interface\\AddOns\\ElitePlayerFrame_Enhacned_CustomSkins\\assets\\"

-- [ CONFIGURATION ]
-- We use an ordered list (array) to prioritize.
-- IMPORTANT: Put more specific textures FIRST (e.g. race+spec+faction > spec > class).
--
-- Optional fields per entry:
--   class   = required, e.g. "WARLOCK", "DRUID"
--   spec    = optional, specialization ID (e.g. 265 = Affliction)
--   race    = optional, race file string from API (see examples below)
--   faction = optional, "Alliance" or "Horde" (respects /epf faction when set)
--   name        = texture file name (without path/extension)
--   ext         = file extension, e.g. "png"
--   displayName = optional; menu label (e.g. for manual-only textures)
--
-- Race examples (use exact string): "Human", "Dwarf", "NightElf", "Gnome", "Draenei", "Worgen",
--   "Orc", "Scourge", "Tauren", "Troll", "BloodElf", "Goblin", "Pandaren",
--   "VoidElf", "LightforgedDraenei", "DarkIronDwarf", "KulTiran", "Mechagnome",
--   "Nightborne", "HighmountainTauren", "MagharOrc", "ZandalariTroll", "Vulpera",
--   "Dracthyr", "Earthen"

local textureConfig = {

    -- ==================================================================================
    -- [ RACE / FACTION SPECIFIC TEXTURES ] Optional "race" or "faction".
    -- ==================================================================================
    -- Examples: { class = "WARLOCK", race = "Human", name = "warlock_human", ext = "png" };
    --           { class = "WARLOCK", spec = 265, race = "Scourge", name = "warlock_affliction_undead", ext = "png" };
    --           { class = "DEATHKNIGHT", faction = "Horde", name = "dk_horde", ext = "png" },

    -- ==================================================================================
    -- [ SPECIALIZATION SPECIFIC TEXTURES ]
    -- Uncomment and edit the lines below to use specific textures for each spec.
    -- ==================================================================================

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
    -- { class = "ROGUE", spec = 259, name = "rogue_assassination", ext = "png" }, -- Assassination
    -- { class = "ROGUE", spec = 260, name = "rogue_outlaw", ext = "png" },        -- Outlaw
    -- { class = "ROGUE", spec = 261, name = "rogue_subtlety", ext = "png" },      -- Subtlety

    -- [ SHAMAN ]
    -- { class = "SHAMAN", spec = 262, name = "shaman_elemental", ext = "png" },   -- Elemental
    -- { class = "SHAMAN", spec = 263, name = "shaman_enhancement", ext = "png" }, -- Enhancement
    -- { class = "SHAMAN", spec = 264, name = "shaman_resto", ext = "png" },       -- Restoration

    -- [ WARLOCK ]
    { class = "WARLOCK", spec = 265, name = "warlock_affliction", ext = "png" },-- Affliction
    { class = "WARLOCK", spec = 266, name = "warlock_demonology", ext = "png" },-- Demonology
    { class = "WARLOCK", spec = 267, name = "warlock_destro", ext = "png" },    -- Destruction

    -- [ WARRIOR ]
    -- { class = "WARRIOR", spec = 71, name = "warrior_arms", ext = "png" },       -- Arms
    -- { class = "WARRIOR", spec = 72, name = "warrior_fury", ext = "png" },       -- Fury
    -- { class = "WARRIOR", spec = 73, name = "warrior_prot", ext = "png" },       -- Protection


    -- ==================================================================================
    -- [ GENERIC CLASS TEXTURES ]
    -- These will be used if no specialization above matches.
    -- Uncomment to enable generic class textures.
    -- ==================================================================================

    -- { class = "DEATHKNIGHT", name = "deathknight", ext = "png" },
    -- { class = "DEMONHUNTER", name = "demonhunter", ext = "png" },
    -- { class = "DRUID",       name = "druid",       ext = "png" },
    -- { class = "EVOKER",      name = "evoker",      ext = "png" },
    -- { class = "HUNTER",      name = "hunter",      ext = "png" },
    -- { class = "MAGE",        name = "mage",        ext = "png" },
    -- { class = "MONK",        name = "monk",        ext = "png" },
    -- { class = "PALADIN",     name = "paladin",     ext = "png" },
    -- { class = "PRIEST",      name = "priest",      ext = "png" },
    -- { class = "ROGUE",       name = "rogue",       ext = "png" },
    -- { class = "SHAMAN",      name = "shaman",      ext = "png" },
    -- { class = "WARLOCK",     name = "warlock",     ext = "png" },
    -- { class = "WARRIOR",     name = "warrior",     ext = "png" },

    -- [ ACTIVE TEXTURES (TESTING) ]
    { class = "WARLOCK", name = "warlock", ext = "png" },

    -- [ MANUAL-ONLY ] No class/race/spec; never auto-selected. Choose via /epf frame N.
    { class = "CUSTOM", name = "blackdragon", ext = "png", displayName = "Black Dragon" },
}

-- [ ADDON LOGIC ]

local baseAddon = nil

-- Spec change: base addon doesn't listen for this; we trigger Update(true) after a short delay
-- (so GetSpecialization() has the new value).
local eventFrame = CreateFrame("Frame")
local delayFrame = CreateFrame("Frame")
local pendingUpdate = false
local DELAY = 0.25

local function runUpdate()
    if baseAddon and baseAddon.Update then
        pcall(function() baseAddon:Update(true) end)
    end
end

local function onDelayTick(self, elapsed)
    self.wait = (self.wait or 0) + elapsed
    if self.wait < DELAY then return end
    self:SetScript("OnUpdate", nil)
    self.wait = nil
    pendingUpdate = false
    runUpdate()
    -- Second pass in case GetSpecialization() wasn't updated yet
    self.wait = 0
    self:SetScript("OnUpdate", function(s, e)
        s.wait = s.wait + e
        if s.wait < DELAY then return end
        s:SetScript("OnUpdate", nil)
        s.wait = nil
        runUpdate()
    end)
end

eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function(_, event)
    if event ~= "PLAYER_SPECIALIZATION_CHANGED" or pendingUpdate then return end
    pendingUpdate = true
    delayFrame.wait = 0
    delayFrame:SetScript("OnUpdate", onDelayTick)
end)

-- Function to add skins
local function AddCustomSkins()
    if EPF_CustomSkins_Loaded then return end
    EPF_CustomSkins_Loaded = true

    for _, data in ipairs(textureConfig) do
        ElitePlayerFrame_Enhanced:AddCustomFrameMode(function(a)
            if not baseAddon then baseAddon = a end
            -- Get class data
            local className = a.safeIndex(a.CLASSES, data.class, "name", 2) or data.class
            local classColor = a.safeIndex(a.CLASSES, data.class, "color") or CreateColor(1,1,1)

            -- Build paths
            local fullPath = folderPath .. data.name .. "." .. data.ext
            local fullPath2x = folderPath .. data.name .. "-2x." .. data.ext

            -- Menu name (displayName, or built from class/spec/race/faction)
            local menuName
            if data.displayName then
                menuName = data.displayName
            else
                menuName = className
                if data.spec then
                    local _, specName = GetSpecializationInfoByID(data.spec)
                    menuName = menuName .. " (" .. (specName or "Spec " .. data.spec) .. ")"
                end
                if data.race then menuName = menuName .. " - " .. data.race end
                if data.faction then menuName = menuName .. " - " .. data.faction end
                if not data.spec and not data.race and not data.faction then
                    menuName = menuName .. " (Custom)"
                end
            end

            return {
                menuName,
                classColor,
                a.SetLayeredTextures(
                    a.SetTexture({
                        ["file"] = fullPath,
                        ["file-2x"] = fullPath2x,
                        ["width"] = 280,
                        ["height"] = 140,
                        ["leftTexCoord"] = 0/512,
                        ["rightTexCoord"] = 512/512,
                        ["topTexCoord"] = 0/512,
                        ["bottomTexCoord"] = 256/512
                    },
                    a.SetPointOffset(50,0)),
                    a.SetTexture({
                        ["file"] = fullPath,
                        ["file-2x"] = fullPath2x,
                        ["width"] = 280,
                        ["height"] = 140,
                        ["leftTexCoord"] = 0/512,
                        ["rightTexCoord"] = 512/512,
                        ["topTexCoord"] = 256/512,
                        ["bottomTexCoord"] = 512/512
                    }
                    ,a.SetPointOffset(180,0))
                ),
                a.SetPointOffset(0,0),

                -- AUTOMATIC SELECTION: which texture is chosen is determined by textureConfig ORDER
                -- (first matching entry wins). Here we only decide if THIS entry matches.
                -- Order of checks: class (required), then faction, race, spec (if set).
                function(addon)
                    if not addon.settings.classSelection then return false end
                    if addon.info.character.class ~= data.class then return false end
                    if data.faction then
                        if not addon.settings.factionSelection then return false end
                        if addon.info.character.faction ~= data.faction then return false end
                    end
                    if data.race then
                        local _, playerRaceEn = UnitRace("player")
                        if playerRaceEn ~= data.race then return false end
                    end
                    if data.spec then
                        local currentSpecIndex = GetSpecialization()
                        if currentSpecIndex then
                            local currentSpecID = GetSpecializationInfo(currentSpecIndex)
                            return currentSpecID == data.spec
                        end
                        return false
                    end

                    -- If no spec defined, it's generic for the class (and race if was required)
                    return true
                end
            }
        end)
    end

    print("|cff00ff00EPF Custom Skins:|r Textures loaded (with specialization support).")
end

if ElitePlayerFrame_Enhanced and ElitePlayerFrame_Enhanced:Initialised() then
    AddCustomSkins()
else
    hooksecurefunc(ElitePlayerFrame_Enhanced, "Initialised", AddCustomSkins)
end