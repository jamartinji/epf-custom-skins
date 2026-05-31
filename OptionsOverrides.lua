-- [ OPTIONS: OVERRIDES TAB ] Auto-mode texture overrides UI.

EPF_CustomSkins_OptionsOverrides = EPF_CustomSkins_OptionsOverrides or {}

local OO = EPF_CustomSkins_OptionsOverrides
local O = EPF_CustomSkins_Overrides
local ANY_VALUE = ""

local PAD = 16
local SECTION_PADDING = 10
local ROW_SPACING = 8
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

local function setSectionBackdrop(frame)
    if not frame.SetBackdrop and BackdropTemplateMixin then
        Mixin(frame, BackdropTemplateMixin)
    end
    if frame.SetBackdrop then
        frame:SetBackdrop(CONTAINER_BACKDROP)
        frame:SetBackdropColor(0.2, 0.2, 0.2, 0.5)
        if frame.SetBackdropBorderColor then
            frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        end
    end
end

local function getBaseAddon()
    return ElitePlayerFrame_Enhanced
end

local function requestBaseUpdate(force)
    local addon = getBaseAddon()
    if addon and type(addon.Update) == "function" then
        pcall(function() addon:Update(force) end)
    end
end

local function valuesEqual(a, b)
    if a == b then return true end
    local na, nb = tonumber(a), tonumber(b)
    if na and nb then return na == nb end
    return false
end

local function findItemText(items, value)
    for _, item in ipairs(items) do
        if valuesEqual(item.value, value) then
            return item.text
        end
    end
    return L("OverrideAny", "Any")
end

local function forceDropdownLabel(dropdown, text)
    if UIDropDownMenu_SetText then
        UIDropDownMenu_SetText(dropdown, text)
    end
    local name = dropdown:GetName()
    if name then
        local label = _G[name .. "Text"]
        if label then
            label:SetText(text or "")
        end
    end
    if UIDropDownMenu_Refresh then
        UIDropDownMenu_Refresh(dropdown)
    end
end

local function setupDropdown(dropdown, width)
    if UIDropDownMenu_SetWidth then
        UIDropDownMenu_SetWidth(dropdown, width or 170)
    end
end

local function initDropdown(dropdown, items, selected, onSelect)
    if not UIDropDownMenu_Initialize then return end
    local selected_text = findItemText(items, selected)
    UIDropDownMenu_Initialize(dropdown, function()
        for _, item in ipairs(items) do
            local captured = item
            local info = UIDropDownMenu_CreateInfo()
            info.text = captured.text
            info.value = captured.value
            info.checked = valuesEqual(captured.value, selected)
            info.func = function()
                onSelect(captured.value)
                UIDropDownMenu_SetSelectedValue(dropdown, captured.value)
                forceDropdownLabel(dropdown, captured.text)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedValue(dropdown, selected)
    forceDropdownLabel(dropdown, selected_text)
end

local function getClassIdFromFile(class_file)
    if not class_file or class_file == ANY_VALUE then
        return nil
    end
    if GetNumClasses and GetClassInfo then
        for i = 1, GetNumClasses() do
            local class_name, file, class_id = GetClassInfo(i)
            if file == class_file then
                return class_id or i
            end
        end
    end
    if C_CreatureInfo and C_CreatureInfo.GetClassInfo then
        local class_id = 1
        while true do
            local info = C_CreatureInfo.GetClassInfo(class_id)
            if not info then break end
            if info.classFile == class_file then
                return class_id
            end
            class_id = class_id + 1
        end
    end
    return nil
end

local function buildClassItems()
    local items = { { text = L("OverrideAny", "Any"), value = ANY_VALUE } }
    if GetNumClasses and GetClassInfo then
        for i = 1, GetNumClasses() do
            local class_name, class_file = GetClassInfo(i)
            if class_file and class_name then
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
    local class_id = getClassIdFromFile(class_file)
    if not class_id or not C_SpecializationInfo or not C_SpecializationInfo.GetNumSpecializationsForClassID then
        return items
    end
    local num_specs = C_SpecializationInfo.GetNumSpecializationsForClassID(class_id)
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
        Vulpera = true, Dracthyr = true, Earthen = true, Haranir = true,
    }
    if C_CreatureInfo and C_CreatureInfo.GetRaceInfo then
        for race_id = 1, 150 do
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
    for id, entry in ipairs(catalog) do
        local plain = (entry.label or tostring(id)):gsub("|c%x%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        items[#items + 1] = { text = plain, value = id }
    end
    table.sort(items, function(a, b) return a.text < b.text end)
    return items
end

local FACTION_ICONS = {
    Alliance = "Interface\\Icons\\Inv_BannerPVP_02",
    Horde = "Interface\\Icons\\Inv_BannerPVP_01",
}

local ICON_SIZE = 16
local ROW_HEIGHT = 22
local ICON_STEP = 18

local function isAnyValue(value)
    return not value or value == ANY_VALUE
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

local function setRowAtlasIcon(texture, atlas)
    if not texture then return end
    if atlas and texture.SetAtlas then
        local ok = pcall(function() texture:SetAtlas(atlas) end)
        if ok and texture.GetAtlas and texture:GetAtlas() then
            texture:Show()
            return
        end
    end
    texture:Hide()
end

local function getOverrideClassIcon(class_file)
    if not class_file or class_file == ANY_VALUE then return nil end
    return ("Interface\\Icons\\ClassIcon_%s"):format(class_file)
end

local function getOverrideSpecIcon(spec_id)
    if not spec_id or spec_id == ANY_VALUE then return nil end
    spec_id = tonumber(spec_id) or spec_id
    local _, _, _, icon = GetSpecializationInfoByID(spec_id)
    return icon
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

local function getOverrideRaceAtlas(race_file, sex)
    if isAnyValue(race_file) then
        return nil
    end
    return ("raceicon128-%s-%s"):format(string.lower(race_file), getRaceSexSuffix(sex))
end

local function getOverrideFactionIcon(faction)
    if isAnyValue(faction) then return nil end
    return FACTION_ICONS[faction]
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
        local class_id = getClassIdFromFile(override.class)
        local class_name = override.class
        if class_id and C_CreatureInfo and C_CreatureInfo.GetClassInfo then
            local info = C_CreatureInfo.GetClassInfo(class_id)
            if info and info.className then class_name = info.className end
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
    local texture = O.GetCatalogLabel(override.catalogId):gsub("|c%x%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
    lines[#lines + 1] = " "
    lines[#lines + 1] = L("OverrideTooltipTexture", "Texture")
    lines[#lines + 1] = texture
    return lines
end

local function populateOverrideRow(btn, override, index, is_selected)
    local icon_x = 20

    local function placeRowIcon(texture, icon, use_atlas)
        texture:ClearAllPoints()
        if not icon then
            texture:Hide()
            return
        end
        texture:SetPoint("LEFT", btn, "LEFT", icon_x, 0)
        icon_x = icon_x + ICON_STEP
        if use_atlas then
            setRowAtlasIcon(texture, icon)
        else
            setRowIcon(texture, icon)
        end
    end

    if isAnyValue(override.class) then
        btn.ClassIcon:Hide()
    else
        placeRowIcon(btn.ClassIcon, getOverrideClassIcon(override.class), false)
    end
    if isAnyValue(override.spec) then
        btn.SpecIcon:Hide()
    else
        placeRowIcon(btn.SpecIcon, getOverrideSpecIcon(override.spec), false)
    end
    if isAnyValue(override.race) then
        btn.RaceIcon:Hide()
    else
        placeRowIcon(btn.RaceIcon, getOverrideRaceAtlas(override.race, override.sex), true)
    end
    if isAnyValue(override.faction) then
        btn.FactionIcon:Hide()
    else
        placeRowIcon(btn.FactionIcon, getOverrideFactionIcon(override.faction), false)
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
        if not override or not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        for _, line in ipairs(buildOverrideTooltip(override)) do
            if line == " " then
                GameTooltip:AddLine(" ")
            else
                GameTooltip:AddLine(line, 1, 1, 1, true)
            end
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)

    return btn
end

function OO.Build(root_panel, tab_y_offset)
    local panel = CreateFrame("Frame", "EPFCustomSkinsOverridesPanel", root_panel)
    panel:SetPoint("TOPLEFT", root_panel, "TOPLEFT", 0, tab_y_offset or -48)
    panel:SetPoint("BOTTOMRIGHT", root_panel, "BOTTOMRIGHT", 0, 0)
    panel:Hide()

    local intro = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    intro:SetPoint("TOPLEFT", PAD, -PAD)
    intro:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PAD, -PAD)
    intro:SetJustifyH("LEFT")
    intro:SetText(L("OverrideIntro", "Assign a texture for a class/spec/race/faction/sex combination. Overrides take priority in Automatic mode."))

    local listGroup = CreateFrame("Frame", nil, panel, BackdropTemplate)
    listGroup:SetPoint("TOPLEFT", intro, "BOTTOMLEFT", 0, -12)
    listGroup:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", PAD, PAD)
    setSectionBackdrop(listGroup)

    local editorGroup = CreateFrame("Frame", nil, panel, BackdropTemplate)
    editorGroup:SetPoint("TOPLEFT", listGroup, "TOPRIGHT", 16, 0)
    editorGroup:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -PAD, PAD)
    setSectionBackdrop(editorGroup)

    local listTitle = listGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    listTitle:SetPoint("TOPLEFT", SECTION_PADDING, -SECTION_PADDING)
    listTitle:SetText(L("OverrideListTitle", "Saved overrides"))

    local editorTitle = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    editorTitle:SetPoint("TOPLEFT", SECTION_PADDING, -SECTION_PADDING)
    editorTitle:SetText(L("OverrideEditorTitle", "Edit override"))

    local selected_index = nil
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
    setupDropdown(classDropdown, 170)

    local specLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    specLabel:SetPoint("TOPLEFT", classDropdown, "BOTTOMLEFT", 16, -8)
    specLabel:SetText(L("OverrideSpec", "Specialization"))

    local specDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideSpecDropdown", editorGroup, "UIDropDownMenuTemplate")
    specDropdown:SetPoint("TOPLEFT", specLabel, "BOTTOMLEFT", -16, -4)
    setupDropdown(specDropdown, 170)

    local raceLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    raceLabel:SetPoint("TOPLEFT", specDropdown, "BOTTOMLEFT", 16, -8)
    raceLabel:SetText(L("OverrideRace", "Race"))

    local raceDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideRaceDropdown", editorGroup, "UIDropDownMenuTemplate")
    raceDropdown:SetPoint("TOPLEFT", raceLabel, "BOTTOMLEFT", -16, -4)
    setupDropdown(raceDropdown, 170)

    local factionLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    factionLabel:SetPoint("TOPLEFT", raceDropdown, "BOTTOMLEFT", 16, -8)
    factionLabel:SetText(L("OverrideFaction", "Faction"))

    local factionDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideFactionDropdown", editorGroup, "UIDropDownMenuTemplate")
    factionDropdown:SetPoint("TOPLEFT", factionLabel, "BOTTOMLEFT", -16, -4)
    setupDropdown(factionDropdown, 170)

    local sexLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sexLabel:SetPoint("TOPLEFT", factionDropdown, "BOTTOMLEFT", 16, -8)
    sexLabel:SetText(L("OverrideSex", "Sex"))

    local sexDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideSexDropdown", editorGroup, "UIDropDownMenuTemplate")
    sexDropdown:SetPoint("TOPLEFT", sexLabel, "BOTTOMLEFT", -16, -4)
    setupDropdown(sexDropdown, 170)

    local textureLabel = editorGroup:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    textureLabel:SetPoint("TOPLEFT", sexDropdown, "BOTTOMLEFT", 16, -8)
    textureLabel:SetText(L("OverrideTexture", "Texture"))

    local textureDropdown = CreateFrame("Frame", "EPFCustomSkinsOverrideTextureDropdown", editorGroup, "UIDropDownMenuTemplate")
    textureDropdown:SetPoint("TOPLEFT", textureLabel, "BOTTOMLEFT", -16, -4)
    setupDropdown(textureDropdown, 170)

    local btnAdd = CreateFrame("Button", nil, editorGroup, "UIPanelButtonTemplate")
    btnAdd:SetSize(120, 22)
    btnAdd:SetPoint("TOPLEFT", textureDropdown, "BOTTOMLEFT", 16, -20)
    btnAdd:SetText(L("OverrideAdd", "Add"))

    local btnSave = CreateFrame("Button", nil, editorGroup, "UIPanelButtonTemplate")
    btnSave:SetSize(120, 22)
    btnSave:SetPoint("TOPLEFT", btnAdd, "BOTTOMLEFT", 0, -6)
    btnSave:SetText(L("OverrideSave", "Save"))

    local btnDelete = CreateFrame("Button", nil, editorGroup, "UIPanelButtonTemplate")
    btnDelete:SetSize(120, 22)
    btnDelete:SetPoint("TOPLEFT", btnSave, "BOTTOMLEFT", 0, -6)
    btnDelete:SetText(L("OverrideDelete", "Delete"))

    local btnClear = CreateFrame("Button", nil, editorGroup, "UIPanelButtonTemplate")
    btnClear:SetSize(120, 22)
    btnClear:SetPoint("TOPLEFT", btnDelete, "BOTTOMLEFT", 0, -6)
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

    local function refreshFormDropdowns()
        initDropdown(classDropdown, buildClassItems(), form.class, function(value)
            form.class = value
            if value == ANY_VALUE then form.spec = ANY_VALUE end
            refreshFormDropdowns()
        end)
        initDropdown(specDropdown, buildSpecItems(form.class), form.spec, function(value)
            form.spec = value
            forceDropdownLabel(specDropdown, findItemText(buildSpecItems(form.class), value))
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
        initDropdown(textureDropdown, buildTextureItems(), form.catalogId, function(value)
            form.catalogId = O.NormalizeCatalogId(value)
        end)
    end

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
            form.class = override.class or ANY_VALUE
            form.spec = override.spec or ANY_VALUE
            form.race = override.race or ANY_VALUE
            form.faction = override.faction or ANY_VALUE
            form.sex = override.sex or ANY_VALUE
            form.catalogId = O.NormalizeCatalogId(override.catalogId)
        end
        refreshFormDropdowns()
    end

    local function refreshList()
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
            end)
            y = y + (ROW_HEIGHT + 2)
        end
        listContent:SetSize(listScroll:GetWidth() > 0 and listScroll:GetWidth() or 200, math.max(y, 1))
        highlightListSelection()
    end

    local function buildOverrideFromForm()
        if not form.catalogId then return nil end
        return {
            enabled = true,
            class = form.class,
            spec = form.spec,
            race = form.race,
            faction = form.faction,
            sex = form.sex,
            catalogId = O.NormalizeCatalogId(form.catalogId),
        }
    end

    btnAdd:SetScript("OnClick", function()
        local override = buildOverrideFromForm()
        if not override then return end
        if O.AddOverride(override) then
            selected_index = #O.GetOverrides()
            refreshList()
            requestBaseUpdate(true)
        end
    end)

    btnSave:SetScript("OnClick", function()
        if not selected_index then return end
        local override = buildOverrideFromForm()
        if not override then return end
        if O.UpdateOverride(selected_index, override) then
            refreshList()
            requestBaseUpdate(true)
        end
    end)

    btnDelete:SetScript("OnClick", function()
        if not selected_index then return end
        if O.RemoveOverride(selected_index) then
            selected_index = nil
            loadFormFromOverride(nil)
            refreshList()
            requestBaseUpdate(true)
        end
    end)

    btnClear:SetScript("OnClick", function()
        selected_index = nil
        loadFormFromOverride(nil)
        refreshList()
    end)

    function panel:Refresh()
        local addon = getBaseAddon()
        if addon and EPF_CustomSkins_Definitions then
            O.BuildCatalog(addon, EPF_CustomSkins_Definitions)
        end
        intro:SetText(L("OverrideIntro", "Assign a texture for a class/spec/race/faction/sex combination. Overrides take priority in Automatic mode."))
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
        loadFormFromOverride(selected_index and O.GetOverrides()[selected_index] or nil)
        refreshList()
    end

    panel:SetScript("OnShow", function()
        local panelW = root_panel:GetWidth()
        if panelW and panelW > 0 then
            listGroup:SetWidth(panelW * 0.52)
            editorGroup:SetWidth(panelW * 0.40)
        end
        panel:Refresh()
    end)

    loadFormFromOverride(nil)
    refreshList()

    return panel
end
