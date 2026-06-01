-- [ OVERRIDES ] Per-character Auto mode texture overrides.

EPF_CustomSkins_Overrides = EPF_CustomSkins_Overrides or {}

local O = EPF_CustomSkins_Overrides
local SB = EPF_CustomSkins_SkinBuilder

O.MAX_OVERRIDES = 16
O.override_mode_ids = O.override_mode_ids or {}
O.mode_to_override = O.mode_to_override or {}
O.catalog = O.catalog or {}
O._addon = nil
O._epf_core = nil
O._reorder_hook = nil

local ANY_VALUE = ""

-- Saved overrides may use shorthand; API clientFileString is canonical.
local RACE_FILE_ALIASES = {
    Earthen = "EarthenDwarf",
}

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
    race_value = RACE_FILE_ALIASES[race_value] or race_value
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
        for id = 1, 150 do
            local info = C_CreatureInfo.GetRaceInfo(id)
            if info and O.NormalizeRaceKey(info.clientFileString) == key then
                return id
            end
        end
    end
    return nil
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

function O.EnsureSavedVariables()
    EPF_CustomSkins_Options = EPF_CustomSkins_Options or {}
    if not EPF_CustomSkins_Options.version then
        EPF_CustomSkins_Options.version = 1
    end
    EPF_CustomSkins_Options.characters = EPF_CustomSkins_Options.characters or {}
    local key = O.GetCharacterKey()
    EPF_CustomSkins_Options.characters[key] = EPF_CustomSkins_Options.characters[key] or {}
    EPF_CustomSkins_Options.characters[key].overrides = EPF_CustomSkins_Options.characters[key].overrides or {}
    return EPF_CustomSkins_Options.characters[key].overrides
end

function O.GetOverrides()
    return O.EnsureSavedVariables()
end

function O.NormalizeCatalogId(value)
    if value == nil or value == "" then return nil end
    return tonumber(value) or value
end

function O.NormalizeRaceKey(race)
    if not race or race == ANY_VALUE then return nil end
    return race:upper():gsub(" ", "")
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
 * Override criteria must match the player even when EPF class/spec/race/sex selection toggles are off.
 * CharacterIsClass() returns false when classSelection is disabled in EPF settings.
--]]
function O.MatchesCharacter(addon, override)
    if not override or override.enabled == false then return false end
    if not override.catalogId then return false end

    local frame = addon or O._addon or EPF_CustomSkins_BaseAddon
    local char = get_epf_character(frame)
    if not char then return false end

    if override.class and override.class ~= ANY_VALUE then
        local class_id = resolve_class_id(frame, override.class)
        if not class_id or char.class ~= class_id then
            return false
        end
    end

    if override.spec and override.spec ~= ANY_VALUE then
        local spec_id = tonumber(override.spec) or override.spec
        if char.specialization ~= spec_id then
            return false
        end
    end

    if override.race and override.race ~= ANY_VALUE then
        local race_id = resolve_race_id(frame, override.race)
        if not race_id or char.race ~= race_id then
            return false
        end
    end

    if override.faction and override.faction ~= ANY_VALUE then
        if char.faction ~= override.faction then
            return false
        end
    end

    if override.sex and override.sex ~= ANY_VALUE then
        local sex_id = resolve_sex_id(frame, override.sex)
        if not sex_id or char.sex ~= sex_id then
            return false
        end
    end

    return true
end

function O.BuildCatalog(addon, definitions)
    O.catalog = {}
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
        local label = addon and SB.BuildMenuName(addon, entry) or (entry.displayName or entry.name or tostring(index))
        local left, right, top, bottom = SB.GetEntryPreviewTexCoords(entry, default_layout)
        O.catalog[index] = {
            id = index,
            entry = entry,
            label = label,
            plainLabel = SB.StripColorCodes(label),
            previewPath = SB.GetEntryPreviewPath(folder_path, entry),
            previewCoords = { left, right, top, bottom },
        }
    end
    return O.catalog
end

function O.GetCatalogEntry(catalog_id)
    catalog_id = O.NormalizeCatalogId(catalog_id)
    local item = catalog_id and O.catalog[catalog_id]
    return item and item.entry or nil
end

function O.GetCatalogLabel(catalog_id)
    catalog_id = O.NormalizeCatalogId(catalog_id)
    local item = catalog_id and O.catalog[catalog_id]
    return item and item.label or ("#" .. tostring(catalog_id))
end

function O.GetCatalogPlainLabel(catalog_id)
    catalog_id = O.NormalizeCatalogId(catalog_id)
    local item = catalog_id and O.catalog[catalog_id]
    if item and item.plainLabel then
        return item.plainLabel
    end
    return SB.StripColorCodes(O.GetCatalogLabel(catalog_id))
end

function O.GetCatalogPreviewPath(catalog_id)
    catalog_id = O.NormalizeCatalogId(catalog_id)
    local item = catalog_id and O.catalog[catalog_id]
    return item and item.previewPath or nil
end

function O.GetCatalogPreviewTexCoords(catalog_id)
    catalog_id = O.NormalizeCatalogId(catalog_id)
    local item = catalog_id and O.catalog[catalog_id]
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
                entry = O.GetCatalogEntry(1) or { name = "warlock", ext = "png" }
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
    override.catalogId = O.NormalizeCatalogId(override.catalogId)
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
    O.PrepareOverridesForSession()

    for _, override in ipairs(O.GetOverrides()) do
        O.RegisterSingleOverrideMode(addon, override)
    end

    if O._reorder_hook then O._reorder_hook() end
    O.RefreshAllOverrideTextures()
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
