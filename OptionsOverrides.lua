-- [ OPTIONS: OVERRIDES TAB ] Auto-mode texture overrides UI.

EPF_CustomSkins_OptionsOverrides = EPF_CustomSkins_OptionsOverrides or {}

local OO = EPF_CustomSkins_OptionsOverrides
local O = EPF_CustomSkins_Overrides
local SB = EPF_CustomSkins_SkinBuilder
local ANY_VALUE = ""

local SECTION_PADDING = 8
local ROW_SPACING = 8
local LIST_PANEL_WIDTH = 196
local OVERRIDE_DROPDOWN_WIDTH = 170
local COPY_CHIP_SIZE = 22
local TEXTURE_PICKER_WIDTH = 280
local TEXTURE_PICKER_HEIGHT = 220
local TEXTURE_PICKER_ROW_HEIGHT = 20
local BackdropTemplate = "BackdropTemplate"

local CONTAINER_BACKDROP = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}

local function L(key, fallback)
    local loc = EPF_CustomSkins_L or {}
    return loc[key] or fallback
end

local function setSectionBackdrop(frame, bg_alpha)
    if not frame.SetBackdrop and BackdropTemplateMixin then
        Mixin(frame, BackdropTemplateMixin)
    end
    if frame.SetBackdrop then
        frame:SetBackdrop(CONTAINER_BACKDROP)
        frame:SetBackdropColor(0.08, 0.08, 0.08, bg_alpha or 0.5)
        if frame.SetBackdropBorderColor then
            frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        end
    end
end

local function setTexturePickerBackdrop(frame)
    setSectionBackdrop(frame, 1)
end

local function getBaseAddon()
    return ElitePlayerFrame_Enhanced
end

local function requestBaseUpdate(force_reset)
    if O and type(O.RequestDisplayRefresh) == "function" then
        O.RequestDisplayRefresh(force_reset)
        return
    end
    local addon = getBaseAddon()
    if addon and type(addon.Update) == "function" then
        pcall(function() addon:Update(true) end)
    end
end

local function valuesEqual(a, b)
    if a == b then return true end
    local na, nb = tonumber(a), tonumber(b)
    if na and nb then return na == nb end
    return false
end

local function isAnyValue(value)
    return not value or value == ANY_VALUE
end

local function findItemText(items, value)
    for _, item in ipairs(items) do
        if valuesEqual(item.value, value) then
            return item.text
        end
    end
    return L("OverrideAny", "Any")
end

local function stripColorCodes(text)
    if SB and SB.StripColorCodes then
        return SB.StripColorCodes(text)
    end
    if not text then return "" end
    text = text:gsub("|cff%x%x%x%x%x%x", "")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    return text:gsub("|r", "")
end

--[[
 * Set dropdown caption without UIDropDownMenu_Refresh (Refresh with a closed menu forces "Personalizado").
--]]
local function showCatalogTooltip(owner, header_lines)
    if not GameTooltip then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    if header_lines then
        for _, line in ipairs(header_lines) do
            if line == " " then
                GameTooltip:AddLine(" ")
            else
                GameTooltip:AddLine(line, 1, 1, 1, true)
            end
        end
    end
    GameTooltip:Show()
end

local function hideCatalogTooltip()
    if GameTooltip then
        GameTooltip:Hide()
    end
end

local function getProfilePopupEditBox(dialog)
    if dialog and dialog.GetEditBox then
        return dialog:GetEditBox()
    end
    return nil
end

local function getProfilePopupButton1(dialog)
    if dialog and dialog.GetButton1 then
        return dialog:GetButton1()
    end
    return dialog and dialog.button1
end

--[[
 * Retail GameDialog requires dialogInfo.text; StaticPopup_Show passes the caption as text_arg1.
 * OnAccept return value (legacy StaticPopup path): true = keep open, false/nil = close.
--]]
local function registerProfilePopups()
    if not StaticPopupDialogs then
        return
    end

    StaticPopupDialogs["EPF_CS_NEW_OVERRIDE_PROFILE"] = {
        text = "%s",
        button1 = _G.ACCEPT,
        button2 = _G.CANCEL,
        hasEditBox = 1,
        maxLetters = 32,
        editBoxWidth = 220,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
        OnShow = function(dialog)
            local accept_btn = getProfilePopupButton1(dialog)
            if accept_btn then
                accept_btn:Disable()
            end
            local edit_box = getProfilePopupEditBox(dialog)
            if edit_box then
                edit_box:SetText("")
                edit_box:SetFocus()
            end
        end,
        OnHide = function(dialog)
            local edit_box = getProfilePopupEditBox(dialog)
            if edit_box then
                edit_box:SetText("")
            end
        end,
        EditBoxOnTextChanged = StaticPopup_StandardNonEmptyTextHandler or function(edit_box)
            local dialog = edit_box:GetParent()
            local accept_btn = dialog and getProfilePopupButton1(dialog)
            if accept_btn then
                local text = edit_box:GetText() or ""
                accept_btn:SetEnabled(text:match("%S") ~= nil)
            end
        end,
        OnAccept = function(dialog, data)
            local payload = data or dialog.data
            local edit_box = getProfilePopupEditBox(dialog)
            local raw_text = edit_box and edit_box.GetText and edit_box:GetText() or ""
            local name = O.NormalizeProfileName(raw_text)
            if not name then
                if UIErrorsFrame then
                    UIErrorsFrame:AddMessage(L("OverrideProfileInvalidName", "Invalid profile name."), 1, 0.1, 0.1, 1)
                end
                return true
            end
            local ok, reason, profile_key = O.CreateProfile(name, true)
            profile_key = profile_key or name
            if not ok then
                if reason == "reserved" and UIErrorsFrame then
                    UIErrorsFrame:AddMessage(
                        L("OverrideProfileReservedName", "That name is reserved. Choose another profile name."),
                        1, 0.1, 0.1, 1
                    )
                    return true
                end
                if reason == "exists" then
                    local existing_key = profile_key or O.FindProfileKey(name)
                    if existing_key then
                        O.SetActiveProfile(existing_key)
                        if payload and payload.onChanged then
                            pcall(payload.onChanged, existing_key)
                        end
                        return nil
                    end
                    if UIErrorsFrame then
                        UIErrorsFrame:AddMessage(L("OverrideProfileExists", "That profile name already exists."), 1, 0.1, 0.1, 1)
                    end
                    return true
                end
                if reason == "max" and UIErrorsFrame then
                    UIErrorsFrame:AddMessage(L("OverrideProfileMax", "Maximum number of profiles reached."), 1, 0.1, 0.1, 1)
                end
                return true
            end
            O.SetActiveProfile(profile_key)
            if payload and payload.onChanged then
                pcall(payload.onChanged, profile_key)
            end
            return nil
        end,
        EditBoxOnEnterPressed = StaticPopup_StandardEditBoxOnEnterPressed or function(edit_box)
            local dialog = edit_box:GetParent()
            local accept_btn = dialog and getProfilePopupButton1(dialog)
            if accept_btn and accept_btn:IsEnabled() then
                StaticPopup_OnClick(dialog, 1)
            end
        end,
        EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed or function(edit_box)
            edit_box:ClearFocus()
            local dialog = edit_box:GetParent()
            if dialog then
                dialog:Hide()
            end
        end,
    }

    StaticPopupDialogs["EPF_CS_DELETE_OVERRIDE_PROFILE"] = {
        text = "%s",
        button1 = _G.ACCEPT,
        button2 = _G.CANCEL,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = 1,
        preferredIndex = 3,
        OnAccept = function(dialog, data)
            local profile_name = (data and data.profileName) or (dialog.data and dialog.data.profileName)
            if not profile_name then
                return nil
            end
            local ok, reason = O.DeleteProfile(profile_name)
            if not ok then
                if reason == "default" and UIErrorsFrame then
                    UIErrorsFrame:AddMessage(L("OverrideProfileCantDeleteDefault", "The Default profile cannot be deleted."), 1, 0.1, 0.1, 1)
                elseif reason == "missing" and UIErrorsFrame then
                    UIErrorsFrame:AddMessage(L("OverrideProfileDeleteFailed", "Could not delete that profile."), 1, 0.1, 0.1, 1)
                end
                return true
            end
            local callback_data = data or dialog.data
            if callback_data and type(callback_data.onChanged) == "function" then
                pcall(callback_data.onChanged)
            end
            return nil
        end,
    }
end

local function setDropdownDisplayText(dropdown, text)
    if UIDropDownMenu_SetText then
        UIDropDownMenu_SetText(dropdown, text or "")
    end
    local name = dropdown:GetName()
    if name then
        local label = _G[name .. "Text"]
        if label then
            label:SetText(text or "")
        end
    end
end

local function setupDropdown(dropdown, width)
    if UIDropDownMenu_SetWidth then
        UIDropDownMenu_SetWidth(dropdown, width or OVERRIDE_DROPDOWN_WIDTH)
    end
end

local function bindCopyButtonTooltip(btn)
    btn:SetScript("OnEnter", function(self)
        if GameTooltip and self.tooltipText then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function()
        if GameTooltip then
            GameTooltip:Hide()
        end
    end)
end

--[[
 * Compact button anchored to the right of a criteria dropdown (copy one field from target).
--]]
local function createCriteriaCopyChip(parent, dropdown)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetSize(COPY_CHIP_SIZE, COPY_CHIP_SIZE)
    btn:SetPoint("LEFT", dropdown, "RIGHT", 2, 0)
    btn:SetText(L("OverrideCopyFieldButton", ">"))
    bindCopyButtonTooltip(btn)
    return btn
end

local function initDropdown(dropdown, items, selected, onSelect)
    if not UIDropDownMenu_Initialize then return end
    dropdown.epfSelectedValue = selected
    local selected_text = findItemText(items, selected)
    UIDropDownMenu_Initialize(dropdown, function()
        local current = dropdown.epfSelectedValue
        for _, item in ipairs(items) do
            local captured = item
            local info = UIDropDownMenu_CreateInfo()
            info.text = captured.text
            info.value = captured.value
            info.checked = valuesEqual(captured.value, current)
            info.func = function()
                dropdown.epfSelectedValue = captured.value
                onSelect(captured.value)
                setDropdownDisplayText(dropdown, captured.text)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    setDropdownDisplayText(dropdown, selected_text)
end

--[[
 * Returns className, classFile, classID from GetClassInfo(classIndex).
 * Retail API order: (className, classFile, classID).
--]]
local function getClassInfoByIndex(class_index)
    if not GetClassInfo then return nil end
    local class_name, class_file, class_id = GetClassInfo(class_index)
    if class_name and class_file and class_id then
        return class_name, class_file, class_id
    end
    return nil
end

local function getClassIdFromFile(class_file)
    if not class_file or class_file == ANY_VALUE then
        return nil
    end
    local numeric = tonumber(class_file)
    if numeric and C_CreatureInfo and C_CreatureInfo.GetClassInfo then
        local info = C_CreatureInfo.GetClassInfo(numeric)
        if info and info.classFile then
            return numeric
        end
    end
    if GetNumClasses and GetClassInfo then
        for i = 1, GetNumClasses() do
            local _, file, id = getClassInfoByIndex(i)
            if file == class_file then
                return id
            end
        end
    end
    if C_CreatureInfo and C_CreatureInfo.GetClassInfo then
        for class_id = 1, 50 do
            local info = C_CreatureInfo.GetClassInfo(class_id)
            if info and info.classFile == class_file then
                return class_id
            end
        end
    end
    return nil
end

local function normalizeClassFile(class_value)
    if not class_value or class_value == ANY_VALUE then
        return ANY_VALUE
    end
    if class_value == "CUSTOM" then
        return ANY_VALUE
    end
    local numeric = tonumber(class_value)
    if numeric and C_CreatureInfo and C_CreatureInfo.GetClassInfo then
        local info = C_CreatureInfo.GetClassInfo(numeric)
        if info and info.classFile then
            return info.classFile
        end
    end
    if type(class_value) == "string" then
        return class_value:upper()
    end
    return class_value
end

local function getClassDisplayName(class_value)
    if isAnyValue(class_value) then
        return L("OverrideAny", "Any")
    end
    local class_file = normalizeClassFile(class_value)
    local class_id = getClassIdFromFile(class_file)
    if class_id and C_CreatureInfo and C_CreatureInfo.GetClassInfo then
        local ok, info = pcall(C_CreatureInfo.GetClassInfo, class_id)
        if ok and info and info.className then
            return info.className
        end
    end
    return findItemText(buildClassItems(), class_file)
end

local function getSpecDisplayName(spec_value, class_file)
    if isAnyValue(spec_value) then
        return L("OverrideAny", "Any")
    end
    local spec_id = tonumber(spec_value) or spec_value
    local _, spec_name = GetSpecializationInfoByID(spec_id)
    if spec_name then
        return spec_name
    end
    return findItemText(buildSpecItems(class_file), spec_value)
end

local function buildClassItems()
    local items = { { text = L("OverrideAny", "Any"), value = ANY_VALUE } }
    if GetNumClasses and GetClassInfo then
        for i = 1, GetNumClasses() do
            local class_name, class_file, _ = getClassInfoByIndex(i)
            if class_file and class_name and class_file ~= "ADVENTURER" then
                items[#items + 1] = { text = class_name, value = class_file }
            end
        end
    end
    table.sort(items, function(a, b)
        if a.value == ANY_VALUE then return true end
        if b.value == ANY_VALUE then return false end
        return a.text < b.text
    end)
    return items
end

local function buildSpecItems(class_file)
    local items = { { text = L("OverrideAny", "Any"), value = ANY_VALUE } }
    class_file = normalizeClassFile(class_file)
    if isAnyValue(class_file) then
        return items
    end
    local class_id = getClassIdFromFile(class_file)
    class_id = tonumber(class_id)
    if not class_id or class_id < 1 or not C_SpecializationInfo or not C_SpecializationInfo.GetNumSpecializationsForClassID then
        return items
    end
    local ok, num_specs = pcall(C_SpecializationInfo.GetNumSpecializationsForClassID, class_id)
    if not ok or not num_specs or num_specs < 1 then
        return items
    end
    for spec_index = 1, num_specs do
        local spec_id = GetSpecializationInfoForClassID(class_id, spec_index)
        if spec_id then
            local _, spec_name = GetSpecializationInfoByID(spec_id)
            items[#items + 1] = {
                text = spec_name or tostring(spec_id),
                value = spec_id,
            }
        end
    end
    return items
end

local function buildRaceItems()
    local items = { { text = L("OverrideAny", "Any"), value = ANY_VALUE } }
    local seen = {}

    local function addRace(file_string, race_name)
        if file_string and file_string ~= "" and not seen[file_string] then
            seen[file_string] = true
            items[#items + 1] = { text = race_name or file_string, value = file_string }
        end
    end

    if C_CharacterCreation and C_CharacterCreation.GetAvailableRaces then
        local ok, races = pcall(C_CharacterCreation.GetAvailableRaces)
        if ok and type(races) == "table" then
            for _, race_data in ipairs(races) do
                local file_string = race_data.fileName or race_data.clientFileString
                local race_name = race_data.name
                if race_data.raceID and C_CreatureInfo and C_CreatureInfo.GetRaceInfo then
                    local info = C_CreatureInfo.GetRaceInfo(race_data.raceID)
                    if info then
                        file_string = file_string or info.clientFileString
                        race_name = race_name or info.raceName
                    end
                end
                addRace(file_string, race_name)
            end
        end
    end

    -- Include playable races from API even if not returned by character creation (e.g. locked allied races).
    local PLAYABLE_RACE_FILES = {
        Human = true, Dwarf = true, NightElf = true, Gnome = true, Draenei = true, Worgen = true,
        VoidElf = true, LightforgedDraenei = true, DarkIronDwarf = true, KulTiran = true, Mechagnome = true,
        Orc = true, Scourge = true, Tauren = true, Troll = true, BloodElf = true, Goblin = true,
        Pandaren = true, Nightborne = true, HighmountainTauren = true, MagharOrc = true, ZandalariTroll = true,
        Vulpera = true, Dracthyr = true, EarthenDwarf = true, Harronir = true,
    }
    if C_CreatureInfo and C_CreatureInfo.GetRaceInfo then
        for race_id = 1, 250 do
            local info = C_CreatureInfo.GetRaceInfo(race_id)
            if info and PLAYABLE_RACE_FILES[info.clientFileString] and not seen[info.clientFileString] then
                addRace(info.clientFileString, info.raceName)
            end
        end
    end

    table.sort(items, function(a, b)
        if a.value == ANY_VALUE then return true end
        if b.value == ANY_VALUE then return false end
        return a.text < b.text
    end)
    return items
end

local function buildFactionItems()
    return {
        { text = L("OverrideAny", "Any"), value = ANY_VALUE },
        { text = L("OverrideAlliance", "Alliance"), value = "Alliance" },
        { text = L("OverrideHorde", "Horde"), value = "Horde" },
    }
end

local function buildTextureItems()
    local items = {}
    local catalog = O.catalog or {}
    for _, entry in ipairs(catalog) do
        local stable_id = entry.id
        if stable_id then
            local plain = entry.plainLabel or stripColorCodes(entry.label or tostring(stable_id))
            items[#items + 1] = { text = plain, value = stable_id }
        end
    end
    table.sort(items, function(a, b) return a.text < b.text end)
    return items
end

local FACTION_ATLAS = {
    Alliance = "pvpqueue-sidebar-honorbar-badge-alliance",
    Horde = "pvpqueue-sidebar-honorbar-badge-horde",
}

-- Legacy texture fallbacks if PvP badge atlases are unavailable.
local FACTION_ICON_TEXTURES = {
    Alliance = "Interface\\Icons\\Inv_BannerPVP_02",
    Horde = "Interface\\Icons\\Inv_BannerPVP_01",
}

local ICON_SIZE = 32
local ROW_HEIGHT = 38
local ICON_STEP = 34

local function atlasExists(atlas)
    if not atlas or atlas == "" then return false end
    if C_Texture and C_Texture.GetAtlasInfo then
        local ok, info = pcall(C_Texture.GetAtlasInfo, atlas)
        return ok and info ~= nil
    end
    return true
end

local function setRowIcon(texture, icon)
    if not texture then return end
    if icon then
        if type(icon) == "number" then
            texture:SetTexture(icon)
        else
            texture:SetTexture(icon)
        end
        texture:Show()
    else
        texture:Hide()
    end
end

local function setRowAtlasIcon(texture, atlas_or_list)
    if not texture or not texture.SetAtlas then return end
    if not atlas_or_list then
        texture:Hide()
        return
    end
    local candidates = atlas_or_list
    if type(atlas_or_list) == "string" then
        candidates = { atlas_or_list }
    end
    for _, atlas in ipairs(candidates) do
        if atlasExists(atlas) then
            local ok = pcall(function() texture:SetAtlas(atlas) end)
            if ok and texture.GetAtlas and texture:GetAtlas() then
                texture:Show()
                return
            end
        end
    end
    texture:Hide()
end

--[[
 * Retail class portraits use classicon-{class} atlases (128px, same family as character create).
--]]
local function getOverrideClassAtlasCandidates(class_file)
    class_file = normalizeClassFile(class_file)
    if isAnyValue(class_file) then return nil end
    local slug = string.lower(class_file)
    local candidates = {}
    local atlas = ("classicon-%s"):format(slug)
    if atlasExists(atlas) then
        candidates[#candidates + 1] = atlas
    end
    return #candidates > 0 and candidates or nil
end

local function getOverrideClassIconTextureFallback(class_file)
    class_file = normalizeClassFile(class_file)
    if isAnyValue(class_file) then return nil end
    return ("Interface\\Icons\\ClassIcon_%s"):format(class_file)
end

--[[
 * Spec column uses the specialization spell/icon from GetSpecializationInfoByID (Blizzard spec icon).
--]]
local function getOverrideSpecIcon(spec_id)
    if not spec_id or spec_id == ANY_VALUE then return nil end
    spec_id = tonumber(spec_id) or spec_id
    local _, _, _, icon = GetSpecializationInfoByID(spec_id)
    return icon
end

local function getOverrideFactionAtlasCandidates(faction)
    if isAnyValue(faction) then return nil end
    local candidates = {}
    local atlas = FACTION_ATLAS[faction]
    if atlas and atlasExists(atlas) then
        candidates[#candidates + 1] = atlas
    end
    return #candidates > 0 and candidates or nil
end

local function getOverrideFactionIconTextureFallback(faction)
    if isAnyValue(faction) then return nil end
    return FACTION_ICON_TEXTURES[faction]
end

local function getRaceSexSuffix(sex)
    if sex == "FEMALE" then
        return "female"
    end
    if sex == "MALE" then
        return "male"
    end
    return "male"
end

-- Atlas slug overrides (clientFileString is not always the atlas token).
local RACE_ATLAS_SLUG = {
    Scourge = "undead",
    LightforgedDraenei = "lightforged",
    VoidElf = "voidelf",
    Nightborne = "nightborne",
    HighmountainTauren = "highmountain",
    MagharOrc = "magharorc",
    ZandalariTroll = "zandalari",
    DarkIronDwarf = "darkiron",
    KulTiran = "kultiran",
    Mechagnome = "mechagnome",
    EarthenDwarf = "earthen",
    Dracthyr = "dracthyr",
    Haranir = "haranir",
    Harronir = "haranir",
}

local function getRaceAtlasSlug(race_file)
    return RACE_ATLAS_SLUG[race_file] or string.lower(race_file)
end

local function appendAtlasCandidate(list, atlas)
    if not atlas then return end
    for _, existing in ipairs(list) do
        if existing == atlas then return end
    end
    list[#list + 1] = atlas
end

local function prependAtlasCandidate(list, atlas)
    if not atlas then return end
    for _, existing in ipairs(list) do
        if existing == atlas then return end
    end
    table.insert(list, 1, atlas)
end

local function getEpfRaceInfo(frame, race_file)
    if not frame or type(frame.GetRace) ~= "function" or not race_file then
        return nil
    end
    local ok, race_info = pcall(function() return frame:GetRace(race_file) end)
    if ok and type(race_info) == "table" and type(race_info.icon) == "table" then
        return race_info
    end
    local enum_key = type(race_file) == "string" and race_file:upper():gsub(" ", "") or race_file
    ok, race_info = pcall(function() return frame:GetRace(enum_key) end)
    if ok and type(race_info) == "table" and type(race_info.icon) == "table" then
        return race_info
    end
    if C_CreatureInfo and C_CreatureInfo.GetRaceInfo then
        for race_id = 1, 200 do
            local info = C_CreatureInfo.GetRaceInfo(race_id)
            if info and info.clientFileString == race_file then
                ok, race_info = pcall(function() return frame:GetRace(race_id) end)
                if ok and type(race_info) == "table" and type(race_info.icon) == "table" then
                    return race_info
                end
                break
            end
        end
    end
    return nil
end

--[[
 * Extra atlas slug tokens beyond the primary slug (retail uses raceicon128-* as the sharp source).
--]]
local function getRaceAtlasSlugVariants(race_file)
    if O and O.NormalizeRaceClientFile then
        race_file = O.NormalizeRaceClientFile(race_file)
    end
    local primary = getRaceAtlasSlug(race_file)
    local variants = { primary }
    local seen = { [primary] = true }

    local function add(slug)
        if slug and not seen[slug] then
            seen[slug] = true
            variants[#variants + 1] = slug
        end
    end

    add(string.lower(race_file))
    if race_file == "Scourge" then
        add("undead")
    elseif race_file == "ZandalariTroll" then
        add("zandalari")
        add("zandalaritroll")
    end
    return variants
end

--[[
 * Prefer raceicon128-* (scales cleanly to UI size), then GetRaceAtlas / EPF / 64px raceicon-* fallbacks.
--]]
local function getOverrideRaceAtlasCandidates(race_file, sex)
    if isAnyValue(race_file) then
        return nil
    end
    if O and O.NormalizeRaceClientFile then
        race_file = O.NormalizeRaceClientFile(race_file)
    end

    local candidates = {}
    local frame = EPF_CustomSkins_BaseAddon or getBaseAddon()
    local suffix = getRaceSexSuffix(sex)
    local icon_index = (sex == "FEMALE") and 3 or 2
    local slug_variants = getRaceAtlasSlugVariants(race_file)

    for _, slug in ipairs(slug_variants) do
        local atlas128 = ("raceicon128-%s-%s"):format(slug, suffix)
        if atlasExists(atlas128) then
            prependAtlasCandidate(candidates, atlas128)
        end
    end

    if type(GetRaceAtlas) == "function" then
        for _, token in ipairs(slug_variants) do
            local ok, atlas = pcall(GetRaceAtlas, token, suffix, true)
            if ok and atlas and atlasExists(atlas) then
                appendAtlasCandidate(candidates, atlas)
            end
        end
    end

    local race_info = getEpfRaceInfo(frame, race_file)
    if race_info and type(race_info.icon) == "table" then
        local icons = race_info.icon
        for _, icon_atlas in ipairs({ icons[icon_index], icons[1], icons[3] }) do
            if atlasExists(icon_atlas) then
                appendAtlasCandidate(candidates, icon_atlas)
            end
        end
    end

    for _, slug in ipairs(slug_variants) do
        local atlas64 = ("raceicon-%s-%s"):format(slug, suffix)
        if atlasExists(atlas64) then
            appendAtlasCandidate(candidates, atlas64)
        end
    end

    return #candidates > 0 and candidates or nil
end

local function buildSexItems()
    return {
        { text = L("OverrideAny", "Any"), value = ANY_VALUE },
        { text = _G.MALE or L("OverrideMale", "Male"), value = "MALE" },
        { text = _G.FEMALE or L("OverrideFemale", "Female"), value = "FEMALE" },
    }
end

local function buildOverrideTooltip(override)
    local lines = {}
    lines[#lines + 1] = L("OverrideTooltipCriteria", "Match criteria")
    if override.class and override.class ~= ANY_VALUE then
        local class_file = normalizeClassFile(override.class)
        local class_name = class_file
        local class_id = getClassIdFromFile(class_file)
        if class_id and C_CreatureInfo and C_CreatureInfo.GetClassInfo then
            local ok, info = pcall(C_CreatureInfo.GetClassInfo, class_id)
            if ok and info and info.className then
                class_name = info.className
            end
        end
        lines[#lines + 1] = (L("OverrideClass", "Class") .. ": " .. class_name)
    end
    if override.spec and override.spec ~= ANY_VALUE then
        local spec_id = tonumber(override.spec) or override.spec
        local _, spec_name = GetSpecializationInfoByID(spec_id)
        lines[#lines + 1] = (L("OverrideSpec", "Specialization") .. ": " .. (spec_name or tostring(spec_id)))
    end
    if override.race and override.race ~= ANY_VALUE then
        local race_label = override.race
        if C_CreatureInfo and C_CreatureInfo.GetRaceInfo then
            for race_id = 1, 150 do
                local info = C_CreatureInfo.GetRaceInfo(race_id)
                if info and info.clientFileString == override.race then
                    race_label = info.raceName
                    break
                end
            end
        end
        lines[#lines + 1] = (L("OverrideRace", "Race") .. ": " .. race_label)
    end
    if override.faction and override.faction ~= ANY_VALUE then
        lines[#lines + 1] = (L("OverrideFaction", "Faction") .. ": " .. override.faction)
    end
    if override.sex and override.sex ~= ANY_VALUE then
        local sex_label = override.sex
        if override.sex == "MALE" and _G.MALE then
            sex_label = MALE
        elseif override.sex == "FEMALE" and _G.FEMALE then
            sex_label = FEMALE
        end
        lines[#lines + 1] = (L("OverrideSex", "Sex") .. ": " .. sex_label)
    end
    if #lines == 1 then
        lines[#lines + 1] = L("OverrideAny", "Any")
    end
    local texture = O.GetCatalogPlainLabel and O.GetCatalogPlainLabel(override.catalogId) or stripColorCodes(O.GetCatalogLabel(override.catalogId))
    lines[#lines + 1] = " "
    lines[#lines + 1] = L("OverrideTooltipTexture", "Texture")
    lines[#lines + 1] = texture
    return lines
end

local function populateOverrideRow(btn, override, index, is_selected)
    local icon_x = 20

    local function placeRowIcon(texture, icon, use_atlas, texture_fallback)
        texture:ClearAllPoints()
        if not icon and not texture_fallback then
            texture:Hide()
            return
        end
        texture:SetPoint("LEFT", btn, "LEFT", icon_x, 0)
        icon_x = icon_x + ICON_STEP
        if use_atlas and icon then
            setRowAtlasIcon(texture, icon)
            if texture:IsShown() then
                return
            end
        end
        if texture_fallback then
            setRowIcon(texture, texture_fallback)
        elseif icon and not use_atlas then
            setRowIcon(texture, icon)
        else
            texture:Hide()
        end
    end

    if isAnyValue(override.class) then
        btn.ClassIcon:Hide()
    else
        placeRowIcon(
            btn.ClassIcon,
            getOverrideClassAtlasCandidates(override.class),
            true,
            getOverrideClassIconTextureFallback(override.class)
        )
    end
    if isAnyValue(override.spec) then
        btn.SpecIcon:Hide()
    else
        placeRowIcon(btn.SpecIcon, getOverrideSpecIcon(override.spec), false)
    end
    if isAnyValue(override.race) then
        btn.RaceIcon:Hide()
    else
        placeRowIcon(btn.RaceIcon, getOverrideRaceAtlasCandidates(override.race, override.sex), true)
    end
    if isAnyValue(override.faction) then
        btn.FactionIcon:Hide()
    else
        placeRowIcon(
            btn.FactionIcon,
            getOverrideFactionAtlasCandidates(override.faction),
            true,
            getOverrideFactionIconTextureFallback(override.faction)
        )
    end
    if btn.IndexText then
        btn.IndexText:SetText(tostring(index))
    end
    if btn.Selected then
        btn.Selected:SetShown(is_selected)
    end
end

local function createOverrideListButton(parent)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(ROW_HEIGHT)
    btn:SetPoint("LEFT", parent, "LEFT", 2, 0)
    btn:SetPoint("RIGHT", parent, "RIGHT", -2, 0)

    btn.Selected = btn:CreateTexture(nil, "BACKGROUND")
    btn.Selected:SetAllPoints()
    btn.Selected:SetColorTexture(0.18, 0.42, 0.72, 0.45)
    btn.Selected:Hide()

    btn.IndexText = btn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    btn.IndexText:SetPoint("LEFT", 4, 0)
    btn.IndexText:SetWidth(14)
    btn.IndexText:SetJustifyH("RIGHT")

    local icon_left = 20
    btn.ClassIcon = btn:CreateTexture(nil, "ARTWORK")
    btn.ClassIcon:SetSize(ICON_SIZE, ICON_SIZE)
    btn.ClassIcon:SetPoint("LEFT", icon_left, 0)

    btn.SpecIcon = btn:CreateTexture(nil, "ARTWORK")
    btn.SpecIcon:SetSize(ICON_SIZE, ICON_SIZE)
    btn.SpecIcon:SetPoint("LEFT", btn.ClassIcon, "RIGHT", ICON_STEP - ICON_SIZE, 0)

    btn.RaceIcon = btn:CreateTexture(nil, "ARTWORK")
    btn.RaceIcon:SetSize(ICON_SIZE, ICON_SIZE)
    btn.RaceIcon:SetPoint("LEFT", btn.SpecIcon, "RIGHT", ICON_STEP - ICON_SIZE, 0)

    btn.FactionIcon = btn:CreateTexture(nil, "ARTWORK")
    btn.FactionIcon:SetSize(ICON_SIZE, ICON_SIZE)
    btn.FactionIcon:SetPoint("LEFT", btn.RaceIcon, "RIGHT", ICON_STEP - ICON_SIZE, 0)

    local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 1, 1, 0.1)

    btn:SetScript("OnEnter", function(self)
        local overrides = O.GetOverrides()
        local override = overrides[self.index]
        if not override then return end
        showCatalogTooltip(self, buildOverrideTooltip(override))
    end)
    btn:SetScript("OnLeave", function()
        hideCatalogTooltip()
    end)

    return btn
end

function OO.Build(content_panel)
    registerProfilePopups()

    local panel = CreateFrame("Frame", "EPFCustomSkinsOverridesPanel", content_panel)
    panel:SetAllPoints(content_panel)

    local profileBar = CreateFrame("Frame", nil, panel)
    profileBar:SetPoint("TOPLEFT", panel, "TOPLEFT", SECTION_PADDING, -SECTION_PADDING)
    profileBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -SECTION_PADDING, -SECTION_PADDING)
    profileBar:SetHeight(28)

    local profileLabel = profileBar:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    profileLabel:SetPoint("LEFT", profileBar, "LEFT", 0, 0)
    profileLabel:SetText(L("OverrideProfile", "Profile"))

    local profileDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideProfileDropdown", profileBar, "UIDropDownMenuTemplate")
    profileDropdown:SetPoint("LEFT", profileLabel, "RIGHT", -12, -2)
    setupDropdown(profileDropdown, 140)

    local btnProfileNew = CreateFrame("Button", nil, profileBar, "UIPanelButtonTemplate")
    btnProfileNew:SetSize(44, 22)
    btnProfileNew:SetPoint("LEFT", profileDropdown, "RIGHT", -4, 0)
    btnProfileNew:SetText(L("OverrideProfileNew", "New"))

    local btnProfileDelete = CreateFrame("Button", nil, profileBar, "UIPanelButtonTemplate")
    btnProfileDelete:SetSize(52, 22)
    btnProfileDelete:SetPoint("LEFT", btnProfileNew, "RIGHT", 4, 0)
    btnProfileDelete:SetText(L("OverrideProfileDelete", "Delete"))

    local intro = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    intro:SetPoint("TOPLEFT", profileBar, "BOTTOMLEFT", 0, -8)
    intro:SetPoint("TOPRIGHT", profileBar, "BOTTOMRIGHT", 0, -8)
    intro:SetJustifyH("LEFT")
    intro:SetText(L("OverrideIntro", "Assign a texture for a class/spec/race/faction/sex combination. Overrides take priority in Automatic mode."))

    local listGroup = CreateFrame("Frame", nil, panel)
    listGroup:SetPoint("TOPLEFT", intro, "BOTTOMLEFT", 0, -10)
    listGroup:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", SECTION_PADDING, SECTION_PADDING)
    listGroup:SetWidth(LIST_PANEL_WIDTH)
    setSectionBackdrop(listGroup)

    local editorGroup = CreateFrame("Frame", nil, panel)
    editorGroup:SetPoint("TOPLEFT", listGroup, "TOPRIGHT", 12, 0)
    editorGroup:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -SECTION_PADDING, SECTION_PADDING)
    setSectionBackdrop(editorGroup)

    local listTitle = listGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    listTitle:SetPoint("TOPLEFT", SECTION_PADDING, -SECTION_PADDING)
    listTitle:SetText(L("OverrideListTitle", "Saved overrides"))

    local editorTitle = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    editorTitle:SetPoint("TOPLEFT", SECTION_PADDING, -SECTION_PADDING)
    editorTitle:SetJustifyH("LEFT")
    editorTitle:SetText(L("OverrideEditorTitle", "Edit override"))

    local btnCopyTarget = CreateFrame("Button", nil, editorGroup, "UIPanelButtonTemplate")
    btnCopyTarget:SetHeight(22)
    btnCopyTarget:SetPoint("TOPRIGHT", editorGroup, "TOPRIGHT", -SECTION_PADDING, -SECTION_PADDING)
    btnCopyTarget:SetText(L("OverrideCopyTarget", "Copy from target"))
    btnCopyTarget.tooltipText = L("OverrideCopyTargetTooltip", "Fill criteria from your current target (class, spec, race, faction, sex).")
    bindCopyButtonTooltip(btnCopyTarget)

    local function fitHeaderCopyTargetButtonWidth()
        local font_string = btnCopyTarget:GetFontString()
        if font_string then
            local text_width = font_string:GetStringWidth() or 0
            btnCopyTarget:SetWidth(math.min(math.max(text_width + 28, 96), 185))
        else
            btnCopyTarget:SetWidth(130)
        end
    end
    fitHeaderCopyTargetButtonWidth()

    editorTitle:SetPoint("RIGHT", btnCopyTarget, "LEFT", -8, 0)

    local selected_index = nil
    local field_copy_buttons = {}
    local form = {
        class = ANY_VALUE,
        spec = ANY_VALUE,
        race = ANY_VALUE,
        faction = ANY_VALUE,
        sex = ANY_VALUE,
        catalogId = nil,
    }

    local classLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    classLabel:SetPoint("TOPLEFT", editorTitle, "BOTTOMLEFT", 0, -10)
    classLabel:SetText(L("OverrideClass", "Class"))

    local classDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideClassDropdown", editorGroup, "UIDropDownMenuTemplate")
    classDropdown:SetPoint("TOPLEFT", classLabel, "BOTTOMLEFT", -16, -4)
    setupDropdown(classDropdown, OVERRIDE_DROPDOWN_WIDTH)
    local btnCopyClass = createCriteriaCopyChip(editorGroup, classDropdown)

    local specLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    specLabel:SetPoint("TOPLEFT", classDropdown, "BOTTOMLEFT", 16, -8)
    specLabel:SetText(L("OverrideSpec", "Specialization"))

    local specDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideSpecDropdown", editorGroup, "UIDropDownMenuTemplate")
    specDropdown:SetPoint("TOPLEFT", specLabel, "BOTTOMLEFT", -16, -4)
    setupDropdown(specDropdown, OVERRIDE_DROPDOWN_WIDTH)
    local btnCopySpec = createCriteriaCopyChip(editorGroup, specDropdown)

    local raceLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    raceLabel:SetPoint("TOPLEFT", specDropdown, "BOTTOMLEFT", 16, -8)
    raceLabel:SetText(L("OverrideRace", "Race"))

    local raceDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideRaceDropdown", editorGroup, "UIDropDownMenuTemplate")
    raceDropdown:SetPoint("TOPLEFT", raceLabel, "BOTTOMLEFT", -16, -4)
    setupDropdown(raceDropdown, OVERRIDE_DROPDOWN_WIDTH)
    local btnCopyRace = createCriteriaCopyChip(editorGroup, raceDropdown)

    local factionLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    factionLabel:SetPoint("TOPLEFT", raceDropdown, "BOTTOMLEFT", 16, -8)
    factionLabel:SetText(L("OverrideFaction", "Faction"))

    local factionDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideFactionDropdown", editorGroup, "UIDropDownMenuTemplate")
    factionDropdown:SetPoint("TOPLEFT", factionLabel, "BOTTOMLEFT", -16, -4)
    setupDropdown(factionDropdown, OVERRIDE_DROPDOWN_WIDTH)
    local btnCopyFaction = createCriteriaCopyChip(editorGroup, factionDropdown)

    local sexLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sexLabel:SetPoint("TOPLEFT", factionDropdown, "BOTTOMLEFT", 16, -8)
    sexLabel:SetText(L("OverrideSex", "Sex"))

    local sexDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideSexDropdown", editorGroup, "UIDropDownMenuTemplate")
    sexDropdown:SetPoint("TOPLEFT", sexLabel, "BOTTOMLEFT", -16, -4)
    setupDropdown(sexDropdown, OVERRIDE_DROPDOWN_WIDTH)
    local btnCopySex = createCriteriaCopyChip(editorGroup, sexDropdown)

    field_copy_buttons[1] = btnCopyClass
    field_copy_buttons[2] = btnCopySpec
    field_copy_buttons[3] = btnCopyRace
    field_copy_buttons[4] = btnCopyFaction
    field_copy_buttons[5] = btnCopySex

    local textureLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    textureLabel:SetPoint("TOPLEFT", sexDropdown, "BOTTOMLEFT", 16, -10)
    textureLabel:SetText(L("OverrideTexture", "Texture"))

    local textureSelectBtn = CreateFrame("Button", nil, editorGroup, "UIPanelButtonTemplate")
    textureSelectBtn:SetSize(220, 22)
    textureSelectBtn:SetPoint("TOPLEFT", textureLabel, "BOTTOMLEFT", 0, -4)
    textureSelectBtn.epfCatalogId = nil

    local texturePicker = CreateFrame("Frame", nil, editorGroup, BackdropTemplate)
    texturePicker:SetSize(TEXTURE_PICKER_WIDTH, TEXTURE_PICKER_HEIGHT)
    texturePicker:SetPoint("TOPLEFT", textureSelectBtn, "BOTTOMLEFT", 0, -4)
    texturePicker:SetFrameStrata("FULLSCREEN_DIALOG")
    texturePicker:SetFrameLevel(250)
    texturePicker:Hide()
    setTexturePickerBackdrop(texturePicker)

    local textureFilter = CreateFrame("EditBox", nil, texturePicker, "InputBoxTemplate")
    textureFilter:SetSize(TEXTURE_PICKER_WIDTH - 24, 20)
    textureFilter:SetPoint("TOPLEFT", texturePicker, "TOPLEFT", 12, -10)
    textureFilter:SetAutoFocus(false)
    textureFilter:SetMaxLetters(48)
    textureFilter:SetText("")

    local textureFilterLabel = texturePicker:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    textureFilterLabel:SetPoint("BOTTOMLEFT", textureFilter, "TOPLEFT", 0, 2)
    textureFilterLabel:SetText(L("OverrideTextureFilter", "Filter textures"))

    local texturePickerScroll = CreateFrame("ScrollFrame", nil, texturePicker, "UIPanelScrollFrameTemplate")
    texturePickerScroll:SetPoint("TOPLEFT", textureFilter, "BOTTOMLEFT", -6, -8)
    texturePickerScroll:SetPoint("BOTTOMRIGHT", texturePicker, "BOTTOMRIGHT", -28, 10)

    local texturePickerContent = CreateFrame("Frame", nil, texturePickerScroll)
    texturePickerContent:SetSize(1, 1)
    texturePickerScroll:SetScrollChild(texturePickerContent)

    local texturePickerRows = {}

    local BTN_W = 88
    local BTN_H = 22
    local BTN_GAP = 6

    local btnAdd = CreateFrame("Button", nil, editorGroup, "UIPanelButtonTemplate")
    btnAdd:SetSize(BTN_W, BTN_H)
    btnAdd:SetPoint("TOPLEFT", textureSelectBtn, "BOTTOMLEFT", 0, -16)
    btnAdd:SetText(L("OverrideAdd", "Add"))
    btnAdd.tooltipText = L("OverrideNeedCriterion", "Select at least one match criterion (class, spec, race, faction, or sex).")

    local btnSave = CreateFrame("Button", nil, editorGroup, "UIPanelButtonTemplate")
    btnSave:SetSize(BTN_W, BTN_H)
    btnSave:SetPoint("LEFT", btnAdd, "RIGHT", BTN_GAP, 0)
    btnSave:SetText(L("OverrideSave", "Save"))
    btnSave.tooltipText = btnAdd.tooltipText

    local btnDelete = CreateFrame("Button", nil, editorGroup, "UIPanelButtonTemplate")
    btnDelete:SetSize(BTN_W, BTN_H)
    btnDelete:SetPoint("LEFT", btnSave, "RIGHT", BTN_GAP, 0)
    btnDelete:SetText(L("OverrideDelete", "Delete"))

    local btnClear = CreateFrame("Button", nil, editorGroup, "UIPanelButtonTemplate")
    btnClear:SetSize(BTN_W, BTN_H)
    btnClear:SetPoint("LEFT", btnDelete, "RIGHT", BTN_GAP, 0)
    btnClear:SetText(L("OverrideClear", "Clear"))

    local listScroll = CreateFrame("ScrollFrame", nil, listGroup, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", listTitle, "BOTTOMLEFT", 0, -6)
    listScroll:SetPoint("BOTTOMRIGHT", listGroup, "BOTTOMRIGHT", -28, SECTION_PADDING)

    local listContent = CreateFrame("Frame", nil, listScroll)
    listContent:SetSize(1, 1)
    listScroll:SetScrollChild(listContent)

    local listButtons = {}

    local function highlightListSelection()
        for _, btn in ipairs(listButtons) do
            if btn and btn.Selected then
                btn.Selected:SetShown(btn.index == selected_index)
            end
        end
    end

    local function syncFormFromDropdowns()
        if classDropdown.epfSelectedValue ~= nil then
            form.class = normalizeClassFile(classDropdown.epfSelectedValue)
        end
        if specDropdown.epfSelectedValue ~= nil then
            form.spec = specDropdown.epfSelectedValue
        end
        if raceDropdown.epfSelectedValue ~= nil then
            form.race = raceDropdown.epfSelectedValue
        end
        if factionDropdown.epfSelectedValue ~= nil then
            form.faction = factionDropdown.epfSelectedValue
        end
        if sexDropdown.epfSelectedValue ~= nil then
            form.sex = sexDropdown.epfSelectedValue
        end
        if textureSelectBtn.epfCatalogId ~= nil then
            form.catalogId = O.NormalizeCatalogId(textureSelectBtn.epfCatalogId)
        end
    end

    local function getPlainCatalogLabel(catalog_id)
        if O.GetCatalogPlainLabel then
            return O.GetCatalogPlainLabel(catalog_id)
        end
        return stripColorCodes(O.GetCatalogLabel(catalog_id))
    end

    local function updateTextureButtonLabel()
        if form.catalogId then
            textureSelectBtn.epfCatalogId = O.NormalizeCatalogId(form.catalogId)
            textureSelectBtn:SetText(getPlainCatalogLabel(form.catalogId))
        else
            textureSelectBtn.epfCatalogId = nil
            textureSelectBtn:SetText(L("OverrideTexturePick", "Select texture..."))
        end
    end

    local function formHasMatchCriteria()
        return O.HasMatchCriteria(form)
    end

    local function getTargetCriteriaForForm()
        if not UnitExists or not UnitExists("target") then
            return nil
        end

        local criteria = {
            class = ANY_VALUE,
            spec = ANY_VALUE,
            race = ANY_VALUE,
            faction = ANY_VALUE,
            sex = ANY_VALUE,
        }

        local _, class_file = UnitClass("target")
        if class_file then
            criteria.class = normalizeClassFile(class_file)
        end

        if UnitIsPlayer and UnitIsPlayer("target") then
            if UnitIsUnit and UnitIsUnit("target", "player") and PlayerUtil and PlayerUtil.GetCurrentSpecID then
                criteria.spec = PlayerUtil.GetCurrentSpecID()
            elseif GetInspectSpecialization then
                local spec_id = GetInspectSpecialization("target")
                if spec_id and spec_id > 0 then
                    criteria.spec = spec_id
                end
            end
        end

        local _, _, race_id = UnitRace("target")
        if race_id and C_CreatureInfo and C_CreatureInfo.GetRaceInfo then
            local ok, race_info = pcall(C_CreatureInfo.GetRaceInfo, race_id)
            if ok and race_info and race_info.clientFileString then
                criteria.race = O.NormalizeRaceClientFile(race_info.clientFileString) or race_info.clientFileString
            end
        end

        local faction = UnitFactionGroup and UnitFactionGroup("target")
        if faction then
            criteria.faction = faction
        end

        local sex = UnitSex and UnitSex("target")
        if sex == 2 then
            criteria.sex = "MALE"
        elseif sex == 3 then
            criteria.sex = "FEMALE"
        end

        return criteria
    end

    local function updateEditorActionsState()
        local can_commit = formHasMatchCriteria() and form.catalogId ~= nil
        local has_target = UnitExists and UnitExists("target")
        btnAdd:SetEnabled(can_commit)
        btnSave:SetEnabled(can_commit and selected_index ~= nil)
        btnDelete:SetEnabled(selected_index ~= nil and true or false)
        btnCopyTarget:SetEnabled(has_target and true or false)
        for _, copy_btn in ipairs(field_copy_buttons) do
            if copy_btn then
                copy_btn:SetEnabled(has_target and true or false)
            end
        end
    end

    local function refreshOverridePlayerFrame()
        if O and type(O.ScheduleOverrideDisplayRefresh) == "function" then
            O.ScheduleOverrideDisplayRefresh()
        elseif O and type(O.ApplyOverrideDisplayRefresh) == "function" then
            O.ApplyOverrideDisplayRefresh()
        elseif O and type(O.RefreshAllOverrideTextures) == "function" then
            O.RefreshAllOverrideTextures()
        else
            requestBaseUpdate(true)
        end
    end

    local function onTexturePickerRowClicked(catalog_id)
        form.catalogId = O.NormalizeCatalogId(catalog_id)
        texturePicker:Hide()
        updateTextureButtonLabel()
        updateEditorActionsState()
    end

    local function refreshTexturePickerList()
        local filter_text = (textureFilter:GetText() or ""):lower()
        local items = buildTextureItems()
        local y = 0
        local row_index = 0
        for _, item in ipairs(items) do
            local plain = item.text or ""
            if filter_text == "" or plain:lower():find(filter_text, 1, true) then
                row_index = row_index + 1
                local row = texturePickerRows[row_index]
                if not row then
                    row = CreateFrame("Button", nil, texturePickerContent)
                    row:SetHeight(TEXTURE_PICKER_ROW_HEIGHT)
                    row:SetPoint("LEFT", texturePickerContent, "LEFT", 2, 0)
                    row:SetPoint("RIGHT", texturePickerContent, "RIGHT", -2, 0)
                    row.Text = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
                    row.Text:SetPoint("LEFT", 4, 0)
                    row.Text:SetPoint("RIGHT", -4, 0)
                    row.Text:SetJustifyH("LEFT")
                    local highlight = row:CreateTexture(nil, "HIGHLIGHT")
                    highlight:SetAllPoints()
                    highlight:SetColorTexture(1, 1, 1, 0.08)
                    texturePickerRows[row_index] = row
                end
                row.catalogId = item.value
                row.Text:SetText(plain)
                row:SetPoint("TOP", texturePickerContent, "TOP", 0, -y)
                row:SetScript("OnClick", function(self)
                    onTexturePickerRowClicked(self.catalogId)
                end)
                row:SetScript("OnEnter", function(self)
                    showCatalogTooltip(self, { plain })
                end)
                row:SetScript("OnLeave", function()
                    hideCatalogTooltip()
                end)
                row:Show()
                y = y + TEXTURE_PICKER_ROW_HEIGHT
            end
        end
        for i = row_index + 1, #texturePickerRows do
            if texturePickerRows[i] then
                texturePickerRows[i]:Hide()
            end
        end
        local width = texturePickerScroll:GetWidth() > 0 and texturePickerScroll:GetWidth() or (TEXTURE_PICKER_WIDTH - 40)
        texturePickerContent:SetSize(width, math.max(y, 1))
    end

    local function toggleTexturePicker()
        if texturePicker:IsShown() then
            texturePicker:Hide()
            return
        end
        refreshTexturePickerList()
        texturePicker:Show()
    end

    textureSelectBtn:SetScript("OnClick", toggleTexturePicker)
    textureFilter:SetScript("OnTextChanged", function()
        refreshTexturePickerList()
    end)
    textureFilter:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        texturePicker:Hide()
    end)

    local function buildOverrideFromForm()
        syncFormFromDropdowns()
        if not form.catalogId then return nil end
        return {
            enabled = true,
            class = normalizeClassFile(form.class),
            spec = form.spec,
            race = form.race,
            faction = form.faction,
            sex = form.sex,
            catalogId = O.NormalizeCatalogId(form.catalogId),
        }
    end

    local function refreshFormDropdowns()
        local class_items = buildClassItems()
        local spec_items = buildSpecItems(form.class)
        initDropdown(classDropdown, class_items, form.class, function(value)
            form.class = normalizeClassFile(value)
            form.spec = ANY_VALUE
            refreshFormDropdowns()
        end)
        initDropdown(specDropdown, spec_items, form.spec, function(value)
            form.spec = value
        end)
        initDropdown(raceDropdown, buildRaceItems(), form.race, function(value)
            form.race = value
        end)
        initDropdown(factionDropdown, buildFactionItems(), form.faction, function(value)
            form.faction = value
        end)
        initDropdown(sexDropdown, buildSexItems(), form.sex, function(value)
            form.sex = value
        end)
        setDropdownDisplayText(classDropdown, getClassDisplayName(form.class))
        setDropdownDisplayText(specDropdown, getSpecDisplayName(form.spec, form.class))
        updateTextureButtonLabel()
        updateEditorActionsState()
    end

    local function applyTargetFieldToForm(field)
        local criteria = getTargetCriteriaForForm()
        if not criteria or not field or criteria[field] == nil then
            return false
        end
        form[field] = criteria[field]
        refreshFormDropdowns()
        return true
    end

    local function applyTargetCriteriaToForm()
        local criteria = getTargetCriteriaForForm()
        if not criteria then
            return false
        end
        form.class = criteria.class
        form.spec = criteria.spec
        form.race = criteria.race
        form.faction = criteria.faction
        form.sex = criteria.sex
        refreshFormDropdowns()
        return true
    end

    local function bindFieldCopyButton(btn, label_key, field)
        btn.tooltipText = string.format(
            L("OverrideCopyFieldTooltip", "Copy %s from current target"),
            L(label_key, label_key)
        )
        btn:SetScript("OnClick", function()
            if applyTargetFieldToForm(field) then
                updateEditorActionsState()
            end
        end)
    end

    bindFieldCopyButton(btnCopyClass, "OverrideClass", "class")
    bindFieldCopyButton(btnCopySpec, "OverrideSpec", "spec")
    bindFieldCopyButton(btnCopyRace, "OverrideRace", "race")
    bindFieldCopyButton(btnCopyFaction, "OverrideFaction", "faction")
    bindFieldCopyButton(btnCopySex, "OverrideSex", "sex")

    local function loadFormFromOverride(override)
        if not override then
            form.class = ANY_VALUE
            form.spec = ANY_VALUE
            form.race = ANY_VALUE
            form.faction = ANY_VALUE
            form.sex = ANY_VALUE
            local texture_items = buildTextureItems()
            form.catalogId = texture_items[1] and texture_items[1].value or nil
            selected_index = nil
        else
            form.class = normalizeClassFile(override.class or ANY_VALUE)
            form.spec = override.spec or ANY_VALUE
            form.race = override.race or ANY_VALUE
            form.faction = override.faction or ANY_VALUE
            form.sex = override.sex or ANY_VALUE
            form.catalogId = O.NormalizeCatalogId(override.catalogId)
        end
        refreshFormDropdowns()
        updateEditorActionsState()
    end

    -- Forward declarations (onProfileChanged calls these before their definitions).
    local refreshProfileDropdown
    local refreshList
    local onProfileChanged

    refreshProfileDropdown = function()
        local profiles = O.GetProfileList()
        local active = O.GetActiveProfileName()
        profileDropdown.epfItems = {}
        for _, name in ipairs(profiles) do
            profileDropdown.epfItems[#profileDropdown.epfItems + 1] = {
                text = name,
                value = name,
            }
        end
        profileDropdown.epfSelectedValue = active
        setDropdownDisplayText(profileDropdown, active or O.DEFAULT_PROFILE_NAME)
        UIDropDownMenu_Initialize(profileDropdown, function(_, level)
            for _, item in ipairs(profileDropdown.epfItems or {}) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = item.text
                info.func = function()
                    if item.value ~= O.GetActiveProfileName() then
                        O.SetActiveProfile(item.value)
                        onProfileChanged()
                    else
                        setDropdownDisplayText(profileDropdown, item.text)
                    end
                end
                info.checked = (item.value == active)
                UIDropDownMenu_AddButton(info, level)
            end
        end)
        local can_delete = active and active ~= O.DEFAULT_PROFILE_NAME
        btnProfileDelete:SetEnabled(can_delete and true or false)
    end

    refreshList = function()
        for _, btn in ipairs(listButtons) do btn:Hide() end
        local overrides = O.GetOverrides()
        local y = 0
        for index, override in ipairs(overrides) do
            local btn = listButtons[index]
            if not btn then
                btn = createOverrideListButton(listContent)
                listButtons[index] = btn
            end
            btn.index = index
            btn:SetPoint("TOP", listContent, "TOP", 0, -y)
            btn:Show()
            populateOverrideRow(btn, override, index, index == selected_index)
            btn:SetScript("OnClick", function(self)
                selected_index = self.index
                loadFormFromOverride(O.GetOverrides()[self.index])
                highlightListSelection()
                updateEditorActionsState()
            end)
            y = y + (ROW_HEIGHT + 2)
        end
        listContent:SetSize(listScroll:GetWidth() > 0 and listScroll:GetWidth() or 200, math.max(y, 1))
        highlightListSelection()
    end

    onProfileChanged = function()
        selected_index = nil
        loadFormFromOverride(nil)
        refreshProfileDropdown()
        refreshList()
        refreshOverridePlayerFrame()
        updateEditorActionsState()
    end

    profileDropdown:SetScript("OnShow", function()
        refreshProfileDropdown()
    end)

    btnProfileNew:SetScript("OnClick", function()
        StaticPopup_Show(
            "EPF_CS_NEW_OVERRIDE_PROFILE",
            L("OverrideProfileNewTitle", "New override profile"),
            nil,
            { onChanged = onProfileChanged }
        )
    end)

    btnProfileDelete:SetScript("OnClick", function()
        local active = O.GetActiveProfileName()
        if not active or active == O.DEFAULT_PROFILE_NAME then
            if UIErrorsFrame then
                UIErrorsFrame:AddMessage(L("OverrideProfileCantDeleteDefault", "The Default profile cannot be deleted."), 1, 0.1, 0.1, 1)
            end
            return
        end
        StaticPopup_Show(
            "EPF_CS_DELETE_OVERRIDE_PROFILE",
            string.format(
                L("OverrideProfileDeleteConfirm", "Delete profile \"%s\"? All overrides in it will be lost."),
                active
            ),
            nil,
            {
                profileName = active,
                onChanged = onProfileChanged,
            }
        )
    end)

    btnAdd:SetScript("OnClick", function()
        if not formHasMatchCriteria() then return end
        local override = buildOverrideFromForm()
        if not override then return end
        if O.AddOverride(override) then
            selected_index = #O.GetOverrides()
            refreshList()
            refreshOverridePlayerFrame()
            updateEditorActionsState()
        end
    end)

    btnSave:SetScript("OnClick", function()
        if not selected_index or not formHasMatchCriteria() then return end
        local override = buildOverrideFromForm()
        if not override then return end
        if O.UpdateOverride(selected_index, override) then
            refreshList()
            refreshOverridePlayerFrame()
        end
    end)

    btnDelete:SetScript("OnClick", function()
        if not selected_index then return end
        if O.RemoveOverride(selected_index) then
            selected_index = nil
            loadFormFromOverride(nil)
            refreshList()
            refreshOverridePlayerFrame()
            updateEditorActionsState()
        end
    end)

    btnClear:SetScript("OnClick", function()
        selected_index = nil
        loadFormFromOverride(nil)
        refreshList()
        refreshOverridePlayerFrame()
        updateEditorActionsState()
    end)

    btnCopyTarget:SetScript("OnClick", function()
        if applyTargetCriteriaToForm() then
            updateEditorActionsState()
        end
    end)

    function panel:Refresh()
        local ok, err = pcall(function()
        local addon = getBaseAddon()
        if addon and EPF_CustomSkins_Definitions then
            O.BuildCatalog(addon, EPF_CustomSkins_Definitions)
        end
        intro:SetText(L("OverrideIntro", "Assign a texture for a class/spec/race/faction/sex combination. Overrides take priority in Automatic mode. Profiles are account-wide; each character remembers its active profile."))
        profileLabel:SetText(L("OverrideProfile", "Profile"))
        btnProfileNew:SetText(L("OverrideProfileNew", "New"))
        btnProfileDelete:SetText(L("OverrideProfileDelete", "Delete"))
        refreshProfileDropdown()
        listTitle:SetText(L("OverrideListTitle", "Saved overrides"))
        editorTitle:SetText(L("OverrideEditorTitle", "Edit override"))
        classLabel:SetText(L("OverrideClass", "Class"))
        specLabel:SetText(L("OverrideSpec", "Specialization"))
        raceLabel:SetText(L("OverrideRace", "Race"))
        factionLabel:SetText(L("OverrideFaction", "Faction"))
        sexLabel:SetText(L("OverrideSex", "Sex"))
        textureLabel:SetText(L("OverrideTexture", "Texture"))
        btnAdd:SetText(L("OverrideAdd", "Add"))
        btnSave:SetText(L("OverrideSave", "Save"))
        btnDelete:SetText(L("OverrideDelete", "Delete"))
        btnClear:SetText(L("OverrideClear", "Clear"))
        btnCopyTarget:SetText(L("OverrideCopyTarget", "Copy from target"))
        btnCopyTarget.tooltipText = L("OverrideCopyTargetTooltip", "Fill criteria from your current target (class, spec, race, faction, sex).")
        fitHeaderCopyTargetButtonWidth()
        btnCopyClass:SetText(L("OverrideCopyFieldButton", ">"))
        btnCopySpec:SetText(L("OverrideCopyFieldButton", ">"))
        btnCopyRace:SetText(L("OverrideCopyFieldButton", ">"))
        btnCopyFaction:SetText(L("OverrideCopyFieldButton", ">"))
        btnCopySex:SetText(L("OverrideCopyFieldButton", ">"))
        bindFieldCopyButton(btnCopyClass, "OverrideClass", "class")
        bindFieldCopyButton(btnCopySpec, "OverrideSpec", "spec")
        bindFieldCopyButton(btnCopyRace, "OverrideRace", "race")
        bindFieldCopyButton(btnCopyFaction, "OverrideFaction", "faction")
        bindFieldCopyButton(btnCopySex, "OverrideSex", "sex")
        loadFormFromOverride(selected_index and O.GetOverrides()[selected_index] or nil)
        refreshList()
        updateEditorActionsState()
        end)
        if not ok and geterrorhandler then
            geterrorhandler()("EPF Custom Skins Overrides Refresh: " .. tostring(err))
        end
    end

    local target_watcher = CreateFrame("Frame", nil, panel)
    target_watcher:RegisterEvent("PLAYER_TARGET_CHANGED")
    target_watcher:SetScript("OnEvent", function()
        if panel:IsShown() then
            updateEditorActionsState()
        end
    end)

    panel:SetScript("OnShow", function()
        updateEditorActionsState()
        pcall(function() panel:Refresh() end)
    end)

    panel:SetScript("OnHide", function()
        texturePicker:Hide()
        hideCatalogTooltip()
    end)

    pcall(function()
        refreshProfileDropdown()
        loadFormFromOverride(nil)
        refreshList()
        updateEditorActionsState()
    end)

    return panel
end
