-- [ OVERRIDES ] Per-character Auto mode texture overrides.

EPF_CustomSkins_Overrides = EPF_CustomSkins_Overrides or {}

local O = EPF_CustomSkins_Overrides
local SB = EPF_CustomSkins_SkinBuilder

O.MAX_OVERRIDES = 16
O.override_mode_ids = O.override_mode_ids or {}
O.mode_to_override = O.mode_to_override or {}
O.catalog = O.catalog or {}
O._addon = nil
O._reorder_hook = nil

local ANY_VALUE = ""

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

function O.MatchesCharacter(addon, override)
    if not override or override.enabled == false then return false end
    if not override.catalogId then return false end

    if override.class and override.class ~= ANY_VALUE then
        if not addon:CharacterIsClass(override.class) then return false end
    end
    if override.spec and override.spec ~= ANY_VALUE then
        local spec_id = tonumber(override.spec) or override.spec
        if not addon:CharacterIsSpecialization(spec_id) then return false end
    end
    if override.race and override.race ~= ANY_VALUE then
        local race_key = O.NormalizeRaceKey(override.race)
        if race_key and not addon:CharacterIsRace(race_key) and not addon:CharacterIsRace(override.race) then
            return false
        end
    end
    if override.faction and override.faction ~= ANY_VALUE then
        if not addon:CharacterIsFaction(override.faction) then return false end
    end
    if override.sex and override.sex ~= ANY_VALUE then
        if not addon:CharacterIsSex(override.sex) then return false end
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

    for index, entry in ipairs(merged) do
        O.catalog[index] = {
            id = index,
            entry = entry,
            label = addon and SB.BuildMenuName(addon, entry) or (entry.displayName or entry.name or tostring(index)),
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
    return SB.ApplyLayeredTexture(ElitePlayerFrame_Enhanced, mode_id, layered, rest_offset)
end

function O.RefreshAllOverrideTextures()
    local addon = O._addon or EPF_CustomSkins_BaseAddon or ElitePlayerFrame_Enhanced
    if not addon then return end
    for mode_id, override in pairs(O.mode_to_override) do
        O.RefreshOverrideTexture(mode_id, override)
    end
    if type(addon.Update) == "function" then
        pcall(function() addon:Update(true) end)
    end
end

function O.RegisterSingleOverrideMode(addon, override)
    if not addon or not override then return nil end

    local hidden_color = CreateColor(0.6, 0.6, 0.6)
    local mode_id

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
                function()
                    local active = mode_id and O.mode_to_override[mode_id]
                    return active and O.MatchesCharacter(addon, active)
                end,
            }
        end)
    end)

    if ok and type(result) == "number" then
        mode_id = result
        override.modeId = mode_id
        O.override_mode_ids[mode_id] = true
        O.mode_to_override[mode_id] = override
        O.RefreshOverrideTexture(mode_id, override)
        return mode_id
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
    local plain_texture = texture:gsub("|c%x%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    return (L.OverrideMenuPrefix or "Override") .. ": " .. criteria .. " -> " .. plain_texture
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

    override.modeId = nil
    O.NormalizeOverride(override)
    overrides[#overrides + 1] = override

    local addon = O._addon or EPF_CustomSkins_BaseAddon
    if addon then
        O.RegisterSingleOverrideMode(addon, override)
    end

    if O._reorder_hook then O._reorder_hook() end
    O.RefreshAllOverrideTextures()
    return true
end

function O.UpdateOverride(index, override)
    local overrides = O.GetOverrides()
    if not overrides[index] then return false end

    local existing_mode_id = overrides[index].modeId
    override.modeId = existing_mode_id
    O.NormalizeOverride(override)
    override.modeId = existing_mode_id
    overrides[index] = override

    if existing_mode_id then
        O.mode_to_override[existing_mode_id] = override
        O.RefreshOverrideTexture(existing_mode_id, override)
    end

    if O._reorder_hook then O._reorder_hook() end
    O.RefreshAllOverrideTextures()
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

    if O._reorder_hook then O._reorder_hook() end
    O.RefreshAllOverrideTextures()
    return true
end

function O.RegisterOverrideModes(addon, reorder_callback)
    O._addon = addon
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
