-- [ OVERRIDES ] Account-wide override profiles; active profile per character.

EPF_CustomSkins_Overrides = EPF_CustomSkins_Overrides or {}

local O = EPF_CustomSkins_Overrides
local SB = EPF_CustomSkins_SkinBuilder

O.MAX_OVERRIDES = 16
O.MAX_PROFILES = 32
O.MAX_PROFILE_NAME_LEN = 32
O.DEFAULT_PROFILE_NAME = "Default"
O.STORAGE_VERSION = 2
O.override_mode_ids = O.override_mode_ids or {}
O._mode_pool = O._mode_pool or {}
O.mode_to_override = O.mode_to_override or {}
O.catalog = O.catalog or {}
O.catalog_by_id = O.catalog_by_id or {}
O._addon = nil
O._epf_core = nil
O._reorder_hook = nil

local ANY_VALUE = ""

-- Saved overrides may use shorthand; values must match Blizzard clientFileString.
local RACE_FILE_ALIASES = {
    Earthen = "EarthenDwarf",
    Haranir = "Harronir", -- Retail typo: raceName Haranir, clientFile Harronir (id 86+).
}

local RACE_SCAN_MAX_ID = 250

--[[
 * EPF stores TEXTURES on the addon core table (select(2,...)), not on the XML frame global.
--]]
function O.GetEpfCore()
    if O._epf_core and O._epf_core.TEXTURES then
        return O._epf_core
    end
    local frame = O._addon or EPF_CustomSkins_BaseAddon
    if frame and type(frame.GetCore) == "function" then
        local ok, core = pcall(function() return frame:GetCore() end)
        if ok and type(core) == "table" and core.TEXTURES then
            O._epf_core = core
            return core
        end
    end
    return nil
end

local function resolve_class_id(addon, class_value)
    if not class_value or class_value == ANY_VALUE then return nil end
    local class_id = tonumber(class_value)
    if class_id then return class_id end
    if addon and type(addon.GetClass) == "function" then
        local ok, info = pcall(function() return addon:GetClass(class_value) end)
        if ok and type(info) == "table" and info.id then
            return info.id
        end
    end
    local class_file = type(class_value) == "string" and class_value:upper() or class_value
    if C_CreatureInfo and C_CreatureInfo.GetClassInfo and GetNumClasses then
        for i = 1, GetNumClasses() do
            local ok, info = pcall(C_CreatureInfo.GetClassInfo, i)
            if ok and info and info.classFile == class_file then
                return i
            end
        end
    end
    return nil
end

local function resolve_race_id(addon, race_value)
    if not race_value or race_value == ANY_VALUE then return nil end
    race_value = O.NormalizeRaceClientFile(race_value)
    local race_id = tonumber(race_value)
    if race_id then return race_id end
    if addon and type(addon.GetRace) == "function" then
        local ok, info = pcall(function() return addon:GetRace(race_value) end)
        if ok and type(info) == "table" and info.id then
            return info.id
        end
    end
    if C_CreatureInfo and C_CreatureInfo.GetRaceInfo then
        local key = O.NormalizeRaceKey(race_value)
        for id = 1, RACE_SCAN_MAX_ID do
            local info = C_CreatureInfo.GetRaceInfo(id)
            if info and O.NormalizeRaceKey(info.clientFileString) == key then
                return id
            end
        end
    end
    return nil
end

function O.GetRaceClientFileString(race_id)
    if not race_id or not C_CreatureInfo or not C_CreatureInfo.GetRaceInfo then
        return nil
    end
    local ok, info = pcall(C_CreatureInfo.GetRaceInfo, race_id)
    if ok and type(info) == "table" then
        return info.clientFileString
    end
    return nil
end

--[[
 * Some races share clientFileString across faction-specific IDs (e.g. Haranir 86/91).
 * Compare by file string, not only the first ID from resolve_race_id.
--]]
function O.RaceCriteriaMatches(override_race, char_race_id)
    if not override_race or override_race == ANY_VALUE then
        return true
    end
    if not char_race_id then
        return false
    end
    local numeric = tonumber(override_race)
    if numeric then
        return char_race_id == numeric
    end
    return O.RaceClientFilesEquivalent(override_race, O.GetRaceClientFileString(char_race_id))
end

local function resolve_sex_id(addon, sex_value)
    if not sex_value or sex_value == ANY_VALUE then return nil end
    local sex_id = tonumber(sex_value)
    if sex_id then return sex_id end
    if addon and type(addon.GetSex) == "function" then
        local ok, info = pcall(function() return addon:GetSex(sex_value) end)
        if ok and type(info) == "table" and info.id then
            return info.id
        end
    end
    local core = O.GetEpfCore()
    if core and core.SEXES_ENUM and core.SEXES_ENUM[sex_value] then
        return core.SEXES_ENUM[sex_value]
    end
    return nil
end

local function get_locale()
    return EPF_CustomSkins_L or {}
end

function O.GetCharacterKey()
    local name = UnitName and UnitName("player")
    local realm = GetRealmName and GetRealmName()
    if name and realm then
        return realm .. "-" .. name
    end
    return "default"
end

local function copy_override(override)
    if type(override) ~= "table" then return nil end
    local copy = {}
    for key, value in pairs(override) do
        if key ~= "modeId" then
            copy[key] = value
        end
    end
    return copy
end

function O.CopyOverride(override)
    return copy_override(override)
end

function O.IsValidProfileSlot(slot)
    return type(slot) == "table" and type(slot.overrides) == "table"
end

function O.NormalizeProfileName(name)
    if type(name) ~= "string" then return nil end
    if SB and SB.StripColorCodes then
        name = SB.StripColorCodes(name)
    end
    if strtrim then
        name = strtrim(name)
    else
        name = name:match("^%s*(.-)%s*$")
    end
    if not name or name == "" then return nil end
    if name:find("|", 1, true) or name:find("\n", 1, true) or name:find("\r", 1, true) then
        return nil
    end
    if #name > O.MAX_PROFILE_NAME_LEN then
        name = name:sub(1, O.MAX_PROFILE_NAME_LEN)
    end
    return name
end

function O.IsReservedProfileName(name)
    return name and name:lower() == O.DEFAULT_PROFILE_NAME:lower()
end

--[[
 * Remove legacy/corrupt keys (e.g. profiles.overrides as a rule list) and keep only valid profile slots.
--]]
function O.RepairProfilesStorage()
    EPF_CustomSkins_Options = EPF_CustomSkins_Options or {}
    local profiles = EPF_CustomSkins_Options.profiles
    if type(profiles) ~= "table" then
        EPF_CustomSkins_Options.profiles = {}
        profiles = EPF_CustomSkins_Options.profiles
    end

    local root_overrides = profiles.overrides
    local root_is_override_list = type(root_overrides) == "table"
        and (root_overrides[1] ~= nil or root_overrides.class ~= nil or root_overrides.catalogId ~= nil)

    if root_is_override_list and not O.IsValidProfileSlot(profiles) then
        if not O.IsValidProfileSlot(profiles[O.DEFAULT_PROFILE_NAME]) then
            profiles[O.DEFAULT_PROFILE_NAME] = { overrides = {} }
        end
        local dest = profiles[O.DEFAULT_PROFILE_NAME].overrides
        if #dest == 0 then
            for index, override in ipairs(root_overrides) do
                dest[index] = copy_override(override)
            end
        end
        profiles.overrides = nil
    end

    local to_remove = {}
    for key, slot in pairs(profiles) do
        if key == "overrides" and not O.IsValidProfileSlot(slot) then
            to_remove[#to_remove + 1] = key
        elseif not O.IsValidProfileSlot(slot) then
            if type(key) == "number" and type(slot) == "table" and (slot.class or slot.catalogId) then
                if not O.IsValidProfileSlot(profiles[O.DEFAULT_PROFILE_NAME]) then
                    profiles[O.DEFAULT_PROFILE_NAME] = { overrides = {} }
                end
                local dest = profiles[O.DEFAULT_PROFILE_NAME].overrides
                dest[#dest + 1] = copy_override(slot)
            end
            to_remove[#to_remove + 1] = key
        end
    end
    for _, key in ipairs(to_remove) do
        profiles[key] = nil
    end

    if not O.IsValidProfileSlot(profiles[O.DEFAULT_PROFILE_NAME]) then
        profiles[O.DEFAULT_PROFILE_NAME] = { overrides = {} }
    end
end

function O.FindProfileKey(name)
    if not name or type(name) ~= "string" then return nil end
    local profiles = O.GetProfilesTable()
    local name_lower = name:lower()
    for key, slot in pairs(profiles) do
        if type(key) == "string" and key:lower() == name_lower and O.IsValidProfileSlot(slot) then
            return key
        end
    end
    return nil
end

function O.ProfileExists(name)
    return O.FindProfileKey(name) ~= nil
end

function O.RemoveInvalidProfileKeysForName(name)
    if not name then return end
    local profiles = O.GetProfilesTable()
    local name_lower = name:lower()
    for key, slot in pairs(profiles) do
        if type(key) == "string" and key:lower() == name_lower and not O.IsValidProfileSlot(slot) then
            profiles[key] = nil
        end
    end
end

function O.MigrateStorageToProfiles()
    EPF_CustomSkins_Options = EPF_CustomSkins_Options or {}
    if (EPF_CustomSkins_Options.version or 0) >= O.STORAGE_VERSION
        and type(EPF_CustomSkins_Options.profiles) == "table" then
        return
    end

    local default_overrides = {}
    local seen = {}

    local function append_override(override)
        if type(override) ~= "table" then return end
        local copy = copy_override(override)
        if not copy or not O.HasMatchCriteria(copy) then return end
        O.NormalizeOverride(copy)
        local signature = table.concat({
            tostring(copy.class or ""),
            tostring(copy.spec or ""),
            tostring(copy.race or ""),
            tostring(copy.faction or ""),
            tostring(copy.sex or ""),
            tostring(copy.catalogId or ""),
        }, "\31")
        if seen[signature] then return end
        seen[signature] = true
        default_overrides[#default_overrides + 1] = copy
    end

    EPF_CustomSkins_Options.characters = EPF_CustomSkins_Options.characters or {}
    for _, char_data in pairs(EPF_CustomSkins_Options.characters) do
        if type(char_data) == "table" and type(char_data.overrides) == "table" then
            for _, override in ipairs(char_data.overrides) do
                append_override(override)
            end
            char_data.overrides = nil
        end
        if not char_data.activeProfile then
            char_data.activeProfile = O.DEFAULT_PROFILE_NAME
        end
    end

    EPF_CustomSkins_Options.profiles = EPF_CustomSkins_Options.profiles or {}
    local default_profile = EPF_CustomSkins_Options.profiles[O.DEFAULT_PROFILE_NAME]
    if not default_profile then
        EPF_CustomSkins_Options.profiles[O.DEFAULT_PROFILE_NAME] = { overrides = default_overrides }
    elseif type(default_profile.overrides) ~= "table" or #default_profile.overrides == 0 then
        default_profile.overrides = default_overrides
    end

    EPF_CustomSkins_Options.version = O.STORAGE_VERSION
end

function O.EnsureSavedVariables()
    EPF_CustomSkins_Options = EPF_CustomSkins_Options or {}
    O.MigrateStorageToProfiles()
    EPF_CustomSkins_Options.profiles = EPF_CustomSkins_Options.profiles or {}
    O.RepairProfilesStorage()
    EPF_CustomSkins_Options.characters = EPF_CustomSkins_Options.characters or {}
    return EPF_CustomSkins_Options
end

function O.EnsureCharacterRecord()
    O.EnsureSavedVariables()
    local key = O.GetCharacterKey()
    EPF_CustomSkins_Options.characters[key] = EPF_CustomSkins_Options.characters[key] or {}
    local record = EPF_CustomSkins_Options.characters[key]
    if not record.activeProfile or not O.ProfileExists(record.activeProfile) then
        record.activeProfile = O.DEFAULT_PROFILE_NAME
    end
    return record
end

function O.GetProfilesTable()
    O.EnsureSavedVariables()
    return EPF_CustomSkins_Options.profiles
end

function O.GetActiveProfileName()
    return O.EnsureCharacterRecord().activeProfile
end

function O.GetProfileList()
    local names = {}
    for name, slot in pairs(O.GetProfilesTable()) do
        if type(name) == "string" and O.IsValidProfileSlot(slot) then
            names[#names + 1] = name
        end
    end
    table.sort(names, function(a, b)
        if a == O.DEFAULT_PROFILE_NAME then return true end
        if b == O.DEFAULT_PROFILE_NAME then return false end
        return a:lower() < b:lower()
    end)
    return names
end

function O.CountProfiles()
    local count = 0
    for _, slot in pairs(O.GetProfilesTable()) do
        if O.IsValidProfileSlot(slot) then
            count = count + 1
        end
    end
    return count
end

function O.GetProfileOverrides(profile_name)
    local profiles = O.GetProfilesTable()
    local key = O.FindProfileKey(profile_name or "") or profile_name
    local profile = key and profiles[key]
    if not profile then return nil end
    profile.overrides = profile.overrides or {}
    return profile.overrides
end

function O.GetOverrides()
    return O.GetProfileOverrides(O.GetActiveProfileName()) or {}
end

function O.CreateProfile(name, copy_current)
    name = O.NormalizeProfileName(name)
    if not name then return false, "invalid" end
    if O.IsReservedProfileName(name) then return false, "reserved" end

    O.RepairProfilesStorage()
    O.RemoveInvalidProfileKeysForName(name)

    local existing_key = O.FindProfileKey(name)
    if existing_key then
        return false, "exists", existing_key
    end

    if O.CountProfiles() >= O.MAX_PROFILES then return false, "max" end

    local overrides = {}
    if copy_current then
        for _, override in ipairs(O.GetOverrides()) do
            overrides[#overrides + 1] = copy_override(override)
        end
    end
    O.GetProfilesTable()[name] = { overrides = overrides }
    return true, nil, name
end

function O.DeleteProfile(name)
    name = O.FindProfileKey(name or "") or name
    if not name or O.IsReservedProfileName(name) then return false, "default" end
    local profiles = O.GetProfilesTable()
    if not O.IsValidProfileSlot(profiles[name]) then return false, "missing" end

    local active_key = O.FindProfileKey(O.GetActiveProfileName() or "")
    local was_active = (active_key == name)

    for _, record in pairs(EPF_CustomSkins_Options.characters or {}) do
        local record_key = O.FindProfileKey(record.activeProfile or "")
        if record_key == name then
            record.activeProfile = O.DEFAULT_PROFILE_NAME
        end
    end

    profiles[name] = nil

    if was_active then
        O.EnsureCharacterRecord().activeProfile = O.DEFAULT_PROFILE_NAME
        O.ReloadActiveProfileOverrides()
    end
    return true
end

function O.SetActiveProfile(name)
    name = O.FindProfileKey(name or "") or name
    if not name or not O.ProfileExists(name) then return false end
    O.EnsureCharacterRecord().activeProfile = name
    O.ReloadActiveProfileOverrides()
    return true
end

function O.DisablePooledOverrideMode(mode_id)
    local core = O.GetEpfCore()
    if not core or not core.TEXTURES or not core.TEXTURES[mode_id] then return end
    core.TEXTURES[mode_id].autoCondition = function()
        return false
    end
    O.override_mode_ids[mode_id] = nil
    O.mode_to_override[mode_id] = nil
end

function O.ReloadActiveProfileOverrides()
    local addon = O._addon or EPF_CustomSkins_BaseAddon
    if not addon then return end

    O.PrepareOverridesForSession()
    local overrides = O.GetOverrides()
    O.override_mode_ids = {}
    O.mode_to_override = {}

    for index, override in ipairs(overrides) do
        local mode_id = O._mode_pool[index]
        local core = O.GetEpfCore()
        if mode_id and core and core.TEXTURES and core.TEXTURES[mode_id] then
            override.modeId = mode_id
            O.override_mode_ids[mode_id] = true
            O.mode_to_override[mode_id] = override
            O.SetOverrideAutoCondition(mode_id)
            O.RefreshOverrideTexture(mode_id, override)
            O.UpdateOverrideModeLabels(mode_id, override)
        else
            mode_id = O.RegisterSingleOverrideMode(addon, override)
            O._mode_pool[index] = mode_id
        end
    end

    for index = #overrides + 1, #O._mode_pool do
        local mode_id = O._mode_pool[index]
        if mode_id then
            O.DisablePooledOverrideMode(mode_id)
        end
    end

    if O._reorder_hook then
        O._reorder_hook()
    end
    O.ScheduleOverrideDisplayRefresh()
end

function O.NormalizeCatalogId(value)
    if value == nil or value == "" then return nil end
    return tonumber(value) or value
end

--[[
 * Stable catalog key from texture definition fields (survives new textures inserted in the list).
 * Includes displayName when present to disambiguate entries that share the same file name.
--]]
function O.BuildCatalogKey(entry)
    if type(entry) ~= "table" or not entry.name then
        return nil
    end
    local segments = {}
    if entry.class then
        segments[#segments + 1] = entry.class
    end
    if entry.spec then
        segments[#segments + 1] = tostring(entry.spec)
    end
    if entry.race then
        segments[#segments + 1] = entry.race
    end
    if entry.faction then
        segments[#segments + 1] = entry.faction
    end
    if entry.displayName and entry.displayName ~= "" then
        local safe_label = tostring(entry.displayName):gsub("[/\\]", "_")
        segments[#segments + 1] = safe_label
    end
    local ext = entry.ext or "png"
    segments[#segments + 1] = entry.name .. "." .. ext
    return table.concat(segments, "/")
end

function O.GetCatalogItem(catalog_id)
    catalog_id = O.NormalizeCatalogId(catalog_id)
    if not catalog_id then
        return nil
    end
    if type(catalog_id) == "number" then
        return O.catalog[catalog_id]
    end
    return O.catalog_by_id[catalog_id]
end

--[[
 * Legacy overrides stored catalogId as a list index; convert once to a stable key after BuildCatalog.
--]]
function O.MigrateOverrideCatalogId(override)
    if not override or override.catalogId == nil then
        return
    end
    local catalog_id = O.NormalizeCatalogId(override.catalogId)
    override.catalogId = catalog_id
    if type(catalog_id) == "string" and O.catalog_by_id[catalog_id] then
        return
    end
    if type(catalog_id) == "number" then
        local item = O.catalog[catalog_id]
        if item and item.id then
            override.catalogId = item.id
        end
    end
end

function O.MigrateAllProfileCatalogIds()
    if not O.catalog or not next(O.catalog) then
        return
    end
    for _, slot in pairs(O.GetProfilesTable()) do
        if O.IsValidProfileSlot(slot) and type(slot.overrides) == "table" then
            for _, override in ipairs(slot.overrides) do
                O.MigrateOverrideCatalogId(override)
            end
        end
    end
end

function O.NormalizeRaceKey(race)
    if not race or race == ANY_VALUE then return nil end
    return race:upper():gsub(" ", "")
end

function O.NormalizeRaceClientFile(race_value)
    if not race_value or race_value == ANY_VALUE then
        return race_value
    end
    return RACE_FILE_ALIASES[race_value] or race_value
end

function O.RaceClientFilesEquivalent(stored_race, client_file)
    if not stored_race or stored_race == ANY_VALUE then
        return true
    end
    if not client_file then
        return false
    end
    local a = O.NormalizeRaceKey(O.NormalizeRaceClientFile(stored_race))
    local b = O.NormalizeRaceKey(O.NormalizeRaceClientFile(client_file))
    return a == b
end

local function get_epf_character(addon)
    local frame = addon or O._addon or EPF_CustomSkins_BaseAddon
    if frame and type(frame.GetCharacterInfo) == "function" then
        local ok, char = pcall(function() return frame:GetCharacterInfo() end)
        if ok and type(char) == "table" then
            return char
        end
    end
    local core = O.GetEpfCore()
    if core and core.info and core.info.character then
        return core.info.character
    end
    return nil
end

--[[
 * Match override criteria against a unit table (class, specialization, race, faction, sex).
 * Used by Elite Target Frame so overrides follow the target unit, not the player.
--]]
function O.MatchesUnitInfo(addon, override, unit_info)
    if not override or override.enabled == false then return false end
    if not override.catalogId or type(unit_info) ~= "table" then return false end

    local frame = addon or O._addon or EPF_CustomSkins_BaseAddon

    if override.class and override.class ~= ANY_VALUE then
        local class_id = resolve_class_id(frame, override.class)
        if not class_id or unit_info.class ~= class_id then
            return false
        end
    end

    if override.spec and override.spec ~= ANY_VALUE then
        local spec_id = tonumber(override.spec) or override.spec
        if unit_info.specialization ~= spec_id then
            return false
        end
    end

    if override.race and override.race ~= ANY_VALUE then
        if not O.RaceCriteriaMatches(override.race, unit_info.race) then
            return false
        end
    end

    if override.faction and override.faction ~= ANY_VALUE then
        if unit_info.faction ~= override.faction then
            return false
        end
    end

    if override.sex and override.sex ~= ANY_VALUE then
        local sex_id = resolve_sex_id(frame, override.sex)
        if not sex_id or unit_info.sex ~= sex_id then
            return false
        end
    end

    return true
end

function O.GetOverrideForModeId(mode_id)
    if not mode_id then return nil end
    return O.mode_to_override and O.mode_to_override[mode_id] or nil
end

--[[
 * Override criteria must match the player even when EPF class/spec/race/sex selection toggles are off.
 * CharacterIsClass() returns false when classSelection is disabled in EPF settings.
--]]
function O.MatchesCharacter(addon, override)
    local frame = addon or O._addon or EPF_CustomSkins_BaseAddon
    local char = get_epf_character(frame)
    if not char then return false end
    return O.MatchesUnitInfo(frame, override, char)
end

function O.BuildCatalog(addon, definitions)
    O.catalog = {}
    O.catalog_by_id = {}
    if not definitions then return O.catalog end

    local merged = {}
    local spec_list = definitions.textureConfigSpec or definitions.textureConfig or {}
    for _, entry in ipairs(spec_list) do
        merged[#merged + 1] = entry
    end
    for _, entry in ipairs(definitions.textureConfigFallback or {}) do
        merged[#merged + 1] = entry
    end

    local folder_path = definitions.folderPath
    local default_layout = definitions.defaultFrameLayout
    for index, entry in ipairs(merged) do
        local stable_id = O.BuildCatalogKey(entry)
        if not stable_id then
            stable_id = "entry/" .. tostring(index)
        elseif O.catalog_by_id[stable_id] then
            stable_id = stable_id .. "#" .. tostring(index)
        end
        local label = addon and SB.BuildMenuName(addon, entry) or (entry.displayName or entry.name or tostring(index))
        local left, right, top, bottom = SB.GetEntryPreviewTexCoords(entry, default_layout)
        local item = {
            id = stable_id,
            legacyIndex = index,
            entry = entry,
            label = label,
            plainLabel = SB.StripColorCodes(label),
            previewPath = SB.GetEntryPreviewPath(folder_path, entry),
            previewCoords = { left, right, top, bottom },
        }
        O.catalog[index] = item
        O.catalog_by_id[stable_id] = item
    end
    O.MigrateAllProfileCatalogIds()
    return O.catalog
end

function O.GetCatalogEntry(catalog_id)
    local item = O.GetCatalogItem(catalog_id)
    return item and item.entry or nil
end

function O.GetCatalogLabel(catalog_id)
    local item = O.GetCatalogItem(catalog_id)
    return item and item.label or ("#" .. tostring(catalog_id))
end

function O.GetCatalogPlainLabel(catalog_id)
    local item = O.GetCatalogItem(catalog_id)
    if item and item.plainLabel then
        return item.plainLabel
    end
    return SB.StripColorCodes(O.GetCatalogLabel(catalog_id))
end

function O.GetCatalogPreviewPath(catalog_id)
    local item = O.GetCatalogItem(catalog_id)
    return item and item.previewPath or nil
end

function O.GetCatalogPreviewTexCoords(catalog_id)
    local item = O.GetCatalogItem(catalog_id)
    if item and item.previewCoords then
        return item.previewCoords[1], item.previewCoords[2], item.previewCoords[3], item.previewCoords[4]
    end
    return 0, 1, 0, 1
end

function O.ApplyOverrideDisplayRefresh()
    local addon = O._addon or EPF_CustomSkins_BaseAddon or ElitePlayerFrame_Enhanced
    if not addon then return end
    if type(addon.SetCharacterInfo) == "function" then
        pcall(function() addon:SetCharacterInfo() end)
    end
    if O._reorder_hook then
        O._reorder_hook()
    end
    for mode_id, override in pairs(O.mode_to_override) do
        O.SetOverrideAutoCondition(mode_id)
        O.RefreshOverrideTexture(mode_id, override)
    end
    O.RequestDisplayRefresh(true)
end

function O.ScheduleOverrideDisplayRefresh()
    if C_Timer and C_Timer.After then
        C_Timer.After(0, function()
            O.ApplyOverrideDisplayRefresh()
        end)
    else
        O.ApplyOverrideDisplayRefresh()
    end
end

function O.IsOverrideModeId(mode_id)
    return mode_id and O.override_mode_ids[mode_id] == true
end

function O.GetOverrideModeIdList()
    local ids = {}
    for _, override in ipairs(O.GetOverrides()) do
        if override.modeId then
            ids[#ids + 1] = override.modeId
        end
    end
    return ids
end

--[[
 * Keep autoCondition tied to mode_to_override[mode_id] so edits replace the override table without stale closures.
--]]
function O.SetOverrideAutoCondition(mode_id)
    if not mode_id then return end
    local core = O.GetEpfCore()
    if not core or not core.TEXTURES or not core.TEXTURES[mode_id] then return end
    local frame = O._addon or EPF_CustomSkins_BaseAddon
    core.TEXTURES[mode_id].autoCondition = function(epf_frame)
        local active = O.mode_to_override[mode_id]
        return active and O.MatchesCharacter(epf_frame or frame, active)
    end
end

function O.RefreshOverrideTexture(mode_id, override)
    local addon = O._addon or EPF_CustomSkins_BaseAddon or ElitePlayerFrame_Enhanced
    if not mode_id or not addon or not override then return false end

    local definitions = EPF_CustomSkins_Definitions
    if not definitions or not definitions.folderPath or not definitions.defaultFrameLayout then
        return false
    end

    local entry = O.GetCatalogEntry(override.catalogId)
    if not entry then return false end

    local layered, rest_offset = SB.BuildTextures(addon, definitions.folderPath, definitions.defaultFrameLayout, entry)
    local core = O.GetEpfCore()
    if not core then return false end
    return SB.ReplaceLayeredTexture(core, mode_id, layered, rest_offset)
end

function O.ResolveOverrideModeId(override, index)
    if override and override.modeId then
        return override.modeId
    end
    if index and O.GetOverrides()[index] and O.GetOverrides()[index].modeId then
        return O.GetOverrides()[index].modeId
    end
    for mode_id, mapped in pairs(O.mode_to_override) do
        if mapped == override then
            return mode_id
        end
    end
    return nil
end

function O.RequestDisplayRefresh(force_reset)
    local addon = O._addon or EPF_CustomSkins_BaseAddon or ElitePlayerFrame_Enhanced
    if not addon then return end
    if type(addon.UpdateTexture) == "function" then
        pcall(function() addon:UpdateTexture(force_reset) end)
    end
    if type(addon.UpdateRestIcon) == "function" then
        pcall(function() addon:UpdateRestIcon(force_reset) end)
    end
    if type(addon.Update) == "function" then
        pcall(function() addon:Update(true) end)
    end
end

function O.RefreshAllOverrideTextures()
    local addon = O._addon or EPF_CustomSkins_BaseAddon or ElitePlayerFrame_Enhanced
    if not addon then return end
    for mode_id, override in pairs(O.mode_to_override) do
        O.SetOverrideAutoCondition(mode_id)
        O.RefreshOverrideTexture(mode_id, override)
    end
    O.RequestDisplayRefresh(true)
end

function O.UpdateOverrideModeLabels(mode_id, override)
    if not mode_id or not override then return end
    local core = O.GetEpfCore()
    if not core then return end
    local menu_name = O.BuildOverrideMenuName(override)
    if core.TEXTURES and core.TEXTURES[mode_id] then
        core.TEXTURES[mode_id].name = menu_name
    end
    if core.FRAME_MODES and core.FRAME_MODES[mode_id] then
        core.FRAME_MODES[mode_id].name = menu_name
    end
end

function O.RegisterSingleOverrideMode(addon, override)
    if not addon or not override then return nil end

    local hidden_color = CreateColor(0.6, 0.6, 0.6)

    local ok, result = pcall(function()
        return addon:AddCustomFrameMode(function(a)
            local menu_name = O.BuildOverrideMenuName(override)
            local entry = O.GetCatalogEntry(override.catalogId)
            if not entry then
                local first = O.catalog[1]
                entry = first and first.entry or { name = "warlock", ext = "png" }
            end
            local layered, rest_offset = SB.BuildTextures(a, EPF_CustomSkins_Definitions.folderPath, EPF_CustomSkins_Definitions.defaultFrameLayout, entry)
            return {
                menu_name,
                hidden_color,
                layered,
                rest_offset,
                function(epf_frame)
                    local mid = override.modeId
                    if mid and O.mode_to_override[mid] then
                        return O.MatchesCharacter(epf_frame or a, O.mode_to_override[mid])
                    end
                    return O.MatchesCharacter(epf_frame or a, override)
                end,
            }
        end)
    end)

    if ok and type(result) == "number" then
        override.modeId = result
        O.override_mode_ids[result] = true
        O.mode_to_override[result] = override
        O.SetOverrideAutoCondition(result)
        O.RefreshOverrideTexture(result, override)
        return result
    end
    return nil
end

function O.BuildOverrideMenuName(override)
    local L = get_locale()
    local parts = {}
    if override.class and override.class ~= ANY_VALUE then
        parts[#parts + 1] = tostring(override.class)
    end
    if override.spec and override.spec ~= ANY_VALUE then
        local spec_id = tonumber(override.spec) or override.spec
        local _, spec_name = GetSpecializationInfoByID(spec_id)
        parts[#parts + 1] = spec_name or tostring(spec_id)
    end
    if override.race and override.race ~= ANY_VALUE then
        parts[#parts + 1] = tostring(override.race)
    end
    if override.faction and override.faction ~= ANY_VALUE then
        parts[#parts + 1] = tostring(override.faction)
    end
    if override.sex and override.sex ~= ANY_VALUE then
        local sex_label = override.sex
        if override.sex == "MALE" and _G.MALE then
            sex_label = MALE
        elseif override.sex == "FEMALE" and _G.FEMALE then
            sex_label = FEMALE
        end
        parts[#parts + 1] = tostring(sex_label)
    end
    local criteria = (#parts > 0) and table.concat(parts, " / ") or (L.OverrideAnyCriteria or "Any")
    local texture = O.GetCatalogLabel(override.catalogId)
    local plain_texture = SB.StripColorCodes(texture)
    return (L.OverrideMenuPrefix or "Override") .. ": " .. criteria .. " -> " .. plain_texture
end

function O.HasMatchCriteria(override)
    if not override then return false end
    return (override.class and override.class ~= ANY_VALUE)
        or (override.spec and override.spec ~= ANY_VALUE)
        or (override.race and override.race ~= ANY_VALUE)
        or (override.faction and override.faction ~= ANY_VALUE)
        or (override.sex and override.sex ~= ANY_VALUE)
end

function O.NormalizeOverride(override)
    override.enabled = (override.enabled ~= false)
    override.class = override.class or ANY_VALUE
    override.spec = override.spec or ANY_VALUE
    override.race = override.race or ANY_VALUE
    override.faction = override.faction or ANY_VALUE
    override.sex = override.sex or ANY_VALUE
    if override.race and override.race ~= ANY_VALUE then
        override.race = O.NormalizeRaceClientFile(override.race)
    end
    override.catalogId = O.NormalizeCatalogId(override.catalogId)
    O.MigrateOverrideCatalogId(override)
    if override.spec ~= ANY_VALUE then
        override.spec = tonumber(override.spec) or override.spec
    end
    -- modeId is runtime-only; EPF assigns new ids every session.
    override.modeId = nil
    return override
end

function O.PrepareOverridesForSession()
    O.override_mode_ids = {}
    O.mode_to_override = {}
    for _, override in ipairs(O.GetOverrides()) do
        O.NormalizeOverride(override)
    end
end

function O.AddOverride(override)
    local overrides = O.GetOverrides()
    if #overrides >= O.MAX_OVERRIDES then return false end
    if not O.HasMatchCriteria(override) then return false end

    override.modeId = nil
    O.NormalizeOverride(override)
    overrides[#overrides + 1] = override

    local addon = O._addon or EPF_CustomSkins_BaseAddon
    if addon then
        O.RegisterSingleOverrideMode(addon, override)
        if O._reorder_hook then
            O._reorder_hook()
        end
    end

    O.ScheduleOverrideDisplayRefresh()
    return true
end

function O.UpdateOverride(index, override)
    local overrides = O.GetOverrides()
    local previous = overrides[index]
    if not previous then return false end
    if not O.HasMatchCriteria(override) then return false end

    local addon = O._addon or EPF_CustomSkins_BaseAddon or ElitePlayerFrame_Enhanced
    local existing_mode_id = O.ResolveOverrideModeId(previous, index)

    override.modeId = existing_mode_id
    O.NormalizeOverride(override)
    override.modeId = existing_mode_id
    overrides[index] = override

    if existing_mode_id then
        O.override_mode_ids[existing_mode_id] = true
        O.mode_to_override[existing_mode_id] = override
        O.SetOverrideAutoCondition(existing_mode_id)
        O.RefreshOverrideTexture(existing_mode_id, override)
        O.UpdateOverrideModeLabels(existing_mode_id, override)
    elseif addon then
        existing_mode_id = O.RegisterSingleOverrideMode(addon, override)
        override.modeId = existing_mode_id
        overrides[index] = override
    end

    O.ScheduleOverrideDisplayRefresh()
    return true
end

function O.RemoveOverride(index)
    local overrides = O.GetOverrides()
    local override = overrides[index]
    if not override then return false end

    if override.modeId then
        O.mode_to_override[override.modeId] = nil
    end
    table.remove(overrides, index)

    O.ScheduleOverrideDisplayRefresh()
    return true
end

function O.RegisterOverrideModes(addon, reorder_callback)
    O._addon = addon
    O._epf_core = nil
    O.GetEpfCore()
    O._reorder_hook = reorder_callback
    O.BuildCatalog(addon, EPF_CustomSkins_Definitions)
    O._mode_pool = {}
    O.ReloadActiveProfileOverrides()
    return O.override_mode_ids
end

local init_frame = CreateFrame("Frame")
init_frame:RegisterEvent("ADDON_LOADED")
init_frame:SetScript("OnEvent", function(_, event, addon_name)
    if event == "ADDON_LOADED" and addon_name == "ElitePlayerFrame_Enhanced_CustomSkins" then
        init_frame:UnregisterEvent("ADDON_LOADED")
        O.EnsureSavedVariables()
    end
end)
