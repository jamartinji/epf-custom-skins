-- [ OPTIONS ] Configuration panel for EPF Custom Skins.
-- Access: Esc → System → AddOns → EPF Custom Skins

EPF_CustomSkins_Options = EPF_CustomSkins_Options or {}

local ADDON_NAME = "EPF Custom Skins"
local ADDON_LOADED_NAME = "ElitePlayerFrame_Enhanced_CustomSkins"
local OPTIONS_SUBTITLE = "options"

local L = EPF_CustomSkins_L or {}

-- SectionTextures label: read from locale table directly to avoid key lookup issues
local function getSectionTexturesLabel()
    local loc = (GetLocale and GetLocale()) or "enUS"
    if loc == "es" and EPF_CustomSkins_Locales and EPF_CustomSkins_Locales.esES then loc = "esES" end
    local locales = EPF_CustomSkins_Locales
    if not locales then return "Available textures" end
    local t = locales[loc]
    if t and t.SectionTextures then return t.SectionTextures end
    t = locales.enUS
    if t and t.SectionTextures then return t.SectionTextures end
    return "Available textures"
end

local panel = CreateFrame("Frame", "EPFCustomSkinsOptionsPanel", UIParent)
panel.name = ADDON_NAME
panel:Hide()

local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(ADDON_NAME .. " " .. "|cff808080(" .. (L.OptionsSubtitle or OPTIONS_SUBTITLE) .. ")|r")

local function getBaseAddon()
    -- Prefer reference set by CustomSkins; fallback to base addon so options work even if load order differs
    return EPF_CustomSkins_BaseAddon or (ElitePlayerFrame_Enhanced and ElitePlayerFrame_Enhanced.Initialised and ElitePlayerFrame_Enhanced:Initialised() and ElitePlayerFrame_Enhanced or nil)
end

local PAD = 16
local GROUP_SPACING = 20
local SECTION_PADDING = 10

local function setSectionBackdrop(frame)
    if not frame.SetBackdrop and BackdropTemplateMixin then
        Mixin(frame, BackdropTemplateMixin)
    end
    if frame.SetBackdrop then
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 16,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        frame:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
        if frame.SetBackdropBorderColor then
            frame:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        end
    end
end

-- BackdropTemplate required on Retail (9.0+); setSectionBackdrop applies Mixin if missing
local BackdropTemplate = "BackdropTemplate"

local group1 = CreateFrame("Frame", nil, panel, BackdropTemplate)
group1:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
group1:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -PAD, 0)
group1:SetHeight(44 + 50 + SECTION_PADDING * 2 + 18)
setSectionBackdrop(group1)

local sectionMain = group1:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
sectionMain:SetPoint("TOPLEFT", SECTION_PADDING, -SECTION_PADDING)
sectionMain:SetText(L.SectionMainAddon or "Elite Player Frame (Enhanced) options")

local CHECK_SPACING = 180
local checkDisplay = CreateFrame("CheckButton", nil, group1, "InterfaceOptionsCheckButtonTemplate")
checkDisplay:SetPoint("TOPLEFT", sectionMain, "BOTTOMLEFT", 0, -6)
local checkDisplayLabel = checkDisplay:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
checkDisplayLabel:SetPoint("LEFT", checkDisplay, "RIGHT", 4, 0)
checkDisplayLabel:SetText(L.Display or "Display")
checkDisplay.tooltipText = L.DisplayDesc or "Show or hide the player frame modifications."

local checkClass = CreateFrame("CheckButton", nil, group1, "InterfaceOptionsCheckButtonTemplate")
checkClass:SetPoint("LEFT", checkDisplay, "RIGHT", CHECK_SPACING, 0)
local checkClassLabel = checkClass:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
checkClassLabel:SetPoint("LEFT", checkClass, "RIGHT", 4, 0)
checkClassLabel:SetText(L.ClassSelection or "Class selection")
checkClass.tooltipText = L.ClassSelectionDesc or "In Auto mode, choose frame by class/spec."

local checkFaction = CreateFrame("CheckButton", nil, group1, "InterfaceOptionsCheckButtonTemplate")
checkFaction:SetPoint("LEFT", checkClass, "RIGHT", CHECK_SPACING, 0)
local checkFactionLabel = checkFaction:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
checkFactionLabel:SetPoint("LEFT", checkFaction, "RIGHT", 4, 0)
checkFactionLabel:SetText(L.FactionSelection or "Faction selection")
checkFaction.tooltipText = L.FactionSelectionDesc or "In Auto mode, choose frame by faction."

local outputLabel = group1:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
outputLabel:SetPoint("TOPLEFT", checkDisplay, "BOTTOMLEFT", 0, -14)
outputLabel:SetText(L.OutputLevel or "Message output level")
outputLabel:SetJustifyH("LEFT")

local outputDesc = group1:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
outputDesc:SetPoint("TOPLEFT", outputLabel, "BOTTOMLEFT", 0, -2)
outputDesc:SetText(L.OutputLevelDesc or "Message verbosity (0 = critical, higher = more debug).")
outputDesc:SetTextColor(0.7, 0.7, 0.7)
outputDesc:SetJustifyH("LEFT")

local outputDropdown = CreateFrame("Frame", "EPFCustomSkinsOutputDropdown", group1, "UIDropDownMenuTemplate")
outputDropdown:SetPoint("TOPLEFT", outputDesc, "BOTTOMLEFT", 0, -4)
if outputDropdown.SetWidth then outputDropdown:SetWidth(200) end
outputDropdown.initialize = function()
    local addon = getBaseAddon()
    if not addon or not addon.OUTPUT_LEVELS then return end
    local list = addon.OUTPUT_LEVELS
    local maxIdx = 0
    for k in pairs(list) do
        if type(k) == "number" and k > maxIdx then maxIdx = k end
    end
    for i = 0, maxIdx do
        local info = list[i]
        local nameStr = (info and info.name) and tostring(info.name) or tostring(i)
        local option = UIDropDownMenu_CreateInfo()
        option.text = nameStr
        option.value = i
        option.func = function(self)
            if addon and addon.settings then
                addon.settings.outputLevel = self.value
                UIDropDownMenu_SetSelectedValue(outputDropdown, self.value)
            end
        end
        UIDropDownMenu_AddButton(option)
    end
end

local btnReset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
btnReset:SetSize(100, 22)
btnReset:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -24, -16)
btnReset:SetText(L.Reset or "Reset")
btnReset.tooltipText = L.ResetDesc or "Reset Elite Player Frame (Enhanced) settings to defaults."
btnReset:SetScript("OnClick", function()
    local addon = getBaseAddon()
    if not addon or not addon.settings or not addon.SV_SETTINGS_DEFAULTS then return end
    local def = addon.SV_SETTINGS_DEFAULTS
    addon.settings.display = def.display
    addon.settings.frameMode = def.frameMode
    addon.settings.classSelection = def.classSelection
    addon.settings.factionSelection = def.factionSelection
    addon.settings.outputLevel = def.outputLevel
    if addon.Update then addon:Update(true) end
    -- Set checkboxes from defaults; toggle opposite first to force template redraw
    local function setCheck(btn, value)
        btn:SetChecked(value and 0 or 1)
        btn:SetChecked(value and 1 or 0)
    end
    setCheck(checkDisplay, def.display)
    setCheck(checkClass, def.classSelection)
    setCheck(checkFaction, def.factionSelection)
    if addon.OUTPUT_LEVELS and UIDropDownMenu_Initialize and UIDropDownMenu_SetSelectedValue then
        UIDropDownMenu_Initialize(outputDropdown, outputDropdown.initialize)
        UIDropDownMenu_SetSelectedValue(outputDropdown, def.outputLevel)
    end
end)

local function updateCheckButtonVisual(btn, checked)
    btn:SetChecked(checked and 1 or 0)
    if InterfaceOptionsPanel_CheckButton_Update then
        InterfaceOptionsPanel_CheckButton_Update(btn)
    end
end

local function refreshMainAddonChecks()
    local addon = getBaseAddon()
    if addon and addon.settings then
        updateCheckButtonVisual(checkDisplay, addon.settings.display)
        updateCheckButtonVisual(checkClass, addon.settings.classSelection)
        updateCheckButtonVisual(checkFaction, addon.settings.factionSelection)
        if addon.OUTPUT_LEVELS and UIDropDownMenu_Initialize and UIDropDownMenu_SetSelectedValue then
            UIDropDownMenu_Initialize(outputDropdown, outputDropdown.initialize)
            UIDropDownMenu_SetSelectedValue(outputDropdown, addon.settings.outputLevel)
        end
    end
end

checkDisplay:SetScript("OnClick", function(self)
    local addon = getBaseAddon()
    if addon and addon.settings then
        addon.settings.display = self:GetChecked()
        if addon.Update then addon:Update(true) end
    end
end)
checkClass:SetScript("OnClick", function(self)
    local addon = getBaseAddon()
    if addon and addon.settings then
        addon.settings.classSelection = self:GetChecked()
        if addon.Update then addon:Update(true) end
    end
end)
checkFaction:SetScript("OnClick", function(self)
    local addon = getBaseAddon()
    if addon and addon.settings then
        addon.settings.factionSelection = self:GetChecked()
        if addon.Update then addon:Update(true) end
    end
end)

local group3 = CreateFrame("Frame", nil, panel, BackdropTemplate)
group3:SetPoint("TOPLEFT", group1, "BOTTOMLEFT", 0, -GROUP_SPACING)
group3:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -PAD, 24)
setSectionBackdrop(group3)

local listLabel = group3:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
listLabel:SetPoint("TOPLEFT", SECTION_PADDING, -SECTION_PADDING)
listLabel:SetText(getSectionTexturesLabel())

-- Placeholder for the list update function
local updateFrameModeList = function() end

-- Check if ScrollBox API is available (Retail 10.0+); use LinearView for a single-column list
local hasScrollBoxAPI = (CreateScrollBoxListLinearView or CreateScrollBoxListGridView) and ScrollUtil and ScrollUtil.InitScrollBoxListWithScrollBar and CreateDataProvider
if hasScrollBoxAPI then
    local scrollBox = CreateFrame("Frame", nil, group3, "WowScrollBoxList")
    scrollBox:SetPoint("TOPLEFT", listLabel, "BOTTOMLEFT", 0, -6)
    scrollBox:SetPoint("BOTTOMRIGHT", group3, "BOTTOMRIGHT", -24, 6)

    local scrollBar = CreateFrame("EventFrame", nil, group3, "MinimalScrollBar")
    scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 6, 0)
    scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 6, 0)

    local function applyFrameMode(index)
        local addon = getBaseAddon()
        if not addon or not addon.settings then return end
        addon.settings.frameMode = index
        if addon.Update then addon:Update(true) end
        if C_Timer and C_Timer.After then
            C_Timer.After(0, function()
                if addon and addon.Update then pcall(function() addon:Update(true) end) end
            end)
        end
        -- Update selection visuals
        if scrollBox.GetDataProvider then
            scrollBox:ForEachFrame(function(button, elementData)
                local isSelected = (addon.settings.frameMode == elementData.index)
                if isSelected then
                    button:LockHighlight()
                else
                    button:UnlockHighlight()
                end
            end)
        end
    end

    local function getModeDisplayName(modes, i, L)
        local mode = modes[i]
        local displayName
        if i == 0 then
            displayName = L.DefaultNoTexture or "Default (no texture)"
        elseif mode and mode.name then
            displayName = tostring(mode.name)
        else
            displayName = (i == 1 and (L.Automatic or "Automatic")) or (L.Custom or "Custom")
        end
        if mode and mode.color and mode.color.GetRGB then
            local r, g, b = mode.color:GetRGB()
            return format("|cff%02x%02x%02x[%d] %s|r", r * 255, g * 255, b * 255, i, displayName)
        end
        return format("[%d] %s", i, displayName)
    end

    local function InitButton(button, elementData)
        -- Create text region if it doesn't exist
        if not button.Text then
            button.Text = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
            button.Text:SetPoint("LEFT", 10, 0)
            button.Text:SetPoint("RIGHT", -10, 0)
            button.Text:SetJustifyH("LEFT")

            -- Set up a highlight texture for mouseover
            local highlight = button:CreateTexture(nil, "HIGHLIGHT")
            highlight:SetAllPoints()
            highlight:SetColorTexture(1, 1, 1, 0.15)
            button:SetHighlightTexture(highlight)
        end

        local index = elementData.index
        local L = EPF_CustomSkins_L or {}
        local displayName = getModeDisplayName(elementData.allModes, index, L)
        button.Text:SetText(displayName)

        button:SetScript("OnClick", function()
            applyFrameMode(index)
        end)

        local addon = getBaseAddon()
        local isSelected = (addon and addon.settings and addon.settings.frameMode == index)

        if isSelected then
            button:LockHighlight()
        else
            button:UnlockHighlight()
        end
    end

    -- Define the update function
    updateFrameModeList = function()
        local addon = getBaseAddon()
        if not addon or not addon.FRAME_MODES then return end

        local dataProvider = CreateDataProvider()
        local modes = addon.FRAME_MODES
        local maxIndex = 0
        for k in pairs(modes) do
            if type(k) == "number" and k > maxIndex then maxIndex = k end
        end

        for i = 0, maxIndex do
            dataProvider:Insert({index = i, allModes = modes})
        end

        scrollBox:SetDataProvider(dataProvider)
    end

    -- Use LinearView for a single-column list (GridView(2) expects a different layout and can show nothing)
    local view = CreateScrollBoxListLinearView and CreateScrollBoxListLinearView() or CreateScrollBoxListGridView(1)
    view:SetElementExtent(24)
    view:SetElementInitializer("Button", InitButton)
    view:SetPadding(5, 5, 5, 5, 5)

    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view)
else
    -- Fallback for older clients or if API is missing
    local errorLabel = group3:CreateFontString(nil, "ARTWORK", "GameFontRed")
    errorLabel:SetPoint("CENTER", 0, 0)
    errorLabel:SetText("ScrollBox API not available on this client version.")
end

panel:SetScript("OnShow", function()
    local L = EPF_CustomSkins_L or {}
    panel.name = ADDON_NAME
    title:SetText(ADDON_NAME .. " " .. "|cff808080(" .. (L.OptionsSubtitle or OPTIONS_SUBTITLE) .. ")|r")
    sectionMain:SetText(L.SectionMainAddon or "Elite Player Frame (Enhanced) options")
    checkDisplayLabel:SetText(L.Display or "Display")
    checkClassLabel:SetText(L.ClassSelection or "Class selection")
    checkFactionLabel:SetText(L.FactionSelection or "Faction selection")
    outputLabel:SetText(L.OutputLevel or "Message output level")
    outputDesc:SetText(L.OutputLevelDesc or "Message verbosity (0 = critical, higher = more debug).")
    btnReset:SetText(L.Reset or "Reset")
    btnReset.tooltipText = L.ResetDesc or "Reset Elite Player Frame (Enhanced) settings to defaults."
    listLabel:SetText(getSectionTexturesLabel())
    refreshMainAddonChecks()

    -- Call the list update function (will be the real one if API exists, or no-op)
    updateFrameModeList()
end)

local function registerOptions()
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
    if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, ADDON_NAME)
        Settings.RegisterAddOnCategory(category)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == ADDON_LOADED_NAME then
        eventFrame:UnregisterEvent("ADDON_LOADED")
        registerOptions()
    end
end)
