-- [ ADDON LOGIC ] Custom frame registration for ElitePlayerFrame_Enhanced.
-- Texture data is in TextureDefinitions.lua (EPF_CustomSkins_Definitions).

local INFO_LOGS = false
local SB = EPF_CustomSkins_SkinBuilder
local O = EPF_CustomSkins_Overrides

local function Log(message)
    if INFO_LOGS and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00EPF Custom Skins:|r " .. tostring(message))
    end
end

local function LogError(context, err)
    local details = tostring(err or "unknown error")
    if geterrorhandler then
        geterrorhandler()("EPF Custom Skins - " .. tostring(context) .. ": " .. details)
    else
        Log(context .. ": " .. details)
    end
end

local function RegisterCustomSkins(addon)
    if EPF_CustomSkins_Loaded then return end

    local D = EPF_CustomSkins_Definitions
    if not D or (not D.textureConfigSpec and not D.textureConfig and not D.textureConfigFallback) then
        Log("Texture definitions not available yet.")
        return
    end
    if not D.folderPath or not D.defaultFrameLayout then
        LogError("Setup", "folderPath/defaultFrameLayout missing in TextureDefinitions")
        return
    end

    EPF_CustomSkins_BaseAddon = addon

    local registered_count = 0
    local failed_count = 0
    local own_spec_mode_ids = {}
    local own_class_default_mode_ids = {}
    local own_classless_mode_ids = {}
    local own_all_mode_ids = {}

    local merged_config = {}
    local spec_list = D.textureConfigSpec or D.textureConfig or {}
    for _, entry in ipairs(spec_list) do
        merged_config[#merged_config + 1] = entry
    end
    for _, entry in ipairs(D.textureConfigFallback or {}) do
        merged_config[#merged_config + 1] = entry
    end

    for _, data in ipairs(merged_config) do
        local ok, mode_id = pcall(function()
            return addon:AddCustomFrameMode(function(a)
                local menu_name = SB.BuildMenuName(a, data)
                local class_color = CreateColor(1, 1, 1)
                if data.class and type(a.GetClass) == "function" then
                    local class_info = a:GetClass(data.class)
                    if type(class_info) == "table" and class_info.color then
                        class_color = class_info.color
                    end
                end

                local layered, rest_offset = SB.BuildTextures(a, D.folderPath, D.defaultFrameLayout, data)
                return {
                    menu_name,
                    class_color,
                    layered,
                    rest_offset,
                    function()
                        return data.class ~= "CUSTOM"
                            and (not data.class or addon:CharacterIsClass(data.class))
                            and (not data.spec or addon:CharacterIsSpecialization(data.spec))
                            and (not data.faction or addon:CharacterIsFaction(data.faction))
                            and (not data.race or addon:CharacterIsRace(data.race))
                    end
                }
            end)
        end)

        if ok and type(mode_id) == "number" then
            registered_count = registered_count + 1
            own_all_mode_ids[#own_all_mode_ids + 1] = mode_id
            if data.spec and data.class and data.class ~= "CUSTOM" then
                own_spec_mode_ids[#own_spec_mode_ids + 1] = mode_id
            elseif data.class and data.class ~= "CUSTOM" then
                own_class_default_mode_ids[#own_class_default_mode_ids + 1] = mode_id
            else
                own_classless_mode_ids[#own_classless_mode_ids + 1] = mode_id
            end
        else
            failed_count = failed_count + 1
            if not ok then
                LogError("AddCustomFrameMode", mode_id)
            end
        end
    end

    local function ReorderCustomModes()
        local order = addon:GetCustomFrameModesOrder()
        if type(order) ~= "table" or #order == 0 then return end

        local is_own = {}
        local is_override = {}
        local is_spec = {}
        local is_class_default = {}
        local is_classless = {}

        for _, mode_id in ipairs(own_all_mode_ids) do is_own[mode_id] = true end
        if O and type(O.GetOverrideModeIdList) == "function" then
            for _, mode_id in ipairs(O.GetOverrideModeIdList()) do
                is_own[mode_id] = true
                is_override[mode_id] = true
            end
        end
        for _, mode_id in ipairs(own_spec_mode_ids) do is_spec[mode_id] = true end
        for _, mode_id in ipairs(own_class_default_mode_ids) do is_class_default[mode_id] = true end
        for _, mode_id in ipairs(own_classless_mode_ids) do is_classless[mode_id] = true end

        local base_mode_ids = {}
        for _, mode_id in ipairs(order) do
            if not is_own[mode_id] then
                base_mode_ids[#base_mode_ids + 1] = mode_id
            end
        end

        local new_order = {}
        for _, mode_id in ipairs(order) do
            if is_override[mode_id] then
                new_order[#new_order + 1] = mode_id
            end
        end
        for _, mode_id in ipairs(order) do
            if is_spec[mode_id] then
                new_order[#new_order + 1] = mode_id
            end
        end
        for _, mode_id in ipairs(base_mode_ids) do
            new_order[#new_order + 1] = mode_id
        end
        for _, mode_id in ipairs(order) do
            if is_class_default[mode_id] then
                new_order[#new_order + 1] = mode_id
            end
        end
        for _, mode_id in ipairs(order) do
            if is_classless[mode_id] then
                new_order[#new_order + 1] = mode_id
            end
        end
        addon:ReorderCustomFrameModes(new_order)
    end

    if O and type(O.RegisterOverrideModes) == "function" then
        O.RegisterOverrideModes(addon, ReorderCustomModes)
    end

    if #own_all_mode_ids > 0 then
        ReorderCustomModes()
        if C_Timer and C_Timer.After then
            C_Timer.After(0, ReorderCustomModes)
            C_Timer.After(0.2, ReorderCustomModes)
        end
    end

    EPF_CustomSkins_Loaded = registered_count > 0
    Log("Textures loaded. Registered modes: " .. tostring(registered_count) .. ", failed/skipped: " .. tostring(failed_count))
end

if ElitePlayerFrame_Enhanced and type(ElitePlayerFrame_Enhanced.WhenInitialised) == "function" then
    ElitePlayerFrame_Enhanced:WhenInitialised(function(addon)
        local ok, err = pcall(function()
            RegisterCustomSkins(addon)
        end)
        if not ok then
            LogError("RegisterCustomSkins", err)
        end
    end)
else
    LogError("Startup", "ElitePlayerFrame_Enhanced API unavailable")
end
