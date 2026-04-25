-- [ ADDON LOGIC ] Custom frame registration for ElitePlayerFrame_Enhanced.
-- Texture data is in TextureDefinitions.lua (EPF_CustomSkins_Definitions).

local INFO_LOGS = false

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

local function BuildMenuName(addon, data)
    if data.displayName then
        return data.displayName
    end

    local class_name = data.class and tostring(data.class) or (data.race or "?")
    if data.class and type(addon.GetClass) == "function" then
        local class_info = addon:GetClass(data.class)
        if type(class_info) == "table" then
            if type(class_info.name) == "table" then
                class_name = class_info.name[2] or class_info.name[1] or class_name
            elseif class_info.name then
                class_name = class_info.name
            end
        end
    end

    local menu_name = class_name
    if data.spec then
        local _, spec_name = GetSpecializationInfoByID(data.spec)
        menu_name = menu_name .. " (" .. (spec_name or ("Spec " .. data.spec)) .. ")"
    end
    if data.race then menu_name = menu_name .. " - " .. data.race end
    if data.faction then menu_name = menu_name .. " - " .. data.faction end

    if data.menuColor then
        local color_code = data.menuColor
        if not color_code:find("^|c") then
            color_code = "|cff" .. color_code
        end
        menu_name = color_code .. menu_name .. "|r"
    end

    return menu_name
end

local function BuildTextures(addon, folder_path, default_frame_layout, data)
    local full_path_2x = folder_path .. data.name .. "-2x." .. data.ext
    -- This addon ships only 2x assets; use the same path for base and 2x.
    local full_path = full_path_2x

    local layout = data.layout or default_frame_layout
    local default_layers = default_frame_layout.layers
    local custom_layers = layout.layers or {}
    local single_layer = data.singleLayer
    local layer_count = single_layer and 1 or #default_layers

    local texture_layers = {}
    for j = 1, layer_count do
        local i = single_layer and 1 or j
        local layer = {}
        for k, v in pairs(default_layers[i]) do layer[k] = v end
        for k, v in pairs(custom_layers[i] or {}) do layer[k] = v end

        local tex = addon.CreateTexture({
            ["file"] = full_path,
            ["file-2x"] = full_path_2x,
            ["width"] = layer.width,
            ["height"] = layer.height,
            ["leftTexCoord"] = layer.leftTexCoord,
            ["rightTexCoord"] = layer.rightTexCoord,
            ["topTexCoord"] = layer.topTexCoord,
            ["bottomTexCoord"] = layer.bottomTexCoord,
        }, addon.CreatePointOffset(layer.pointOffset[1], layer.pointOffset[2]))
        texture_layers[j] = tex
    end

    local layered
    if single_layer then
        layered = addon.CreateLayeredTextures(nil, texture_layers[1])
    else
        layered = addon.CreateLayeredTextures(texture_layers[1], texture_layers[2])
    end

    local rest_icon_offset = layout.restIconOffset or default_frame_layout.restIconOffset
    return layered, addon.CreatePointOffset(rest_icon_offset[1], rest_icon_offset[2])
end

local function RegisterCustomSkins(addon)
    if EPF_CustomSkins_Loaded then return end

    local D = EPF_CustomSkins_Definitions
    if not D or not D.textureConfig then
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
    local priority_mode_ids = {}

    for _, data in ipairs(D.textureConfig) do
        local ok, mode_id = pcall(function()
            return addon:AddCustomFrameMode(function(a)
                local menu_name = BuildMenuName(a, data)
                local class_color = CreateColor(1, 1, 1)
                if data.class and type(a.GetClass) == "function" then
                    local class_info = a:GetClass(data.class)
                    if type(class_info) == "table" and class_info.color then
                        class_color = class_info.color
                    end
                end

                local layered, rest_offset = BuildTextures(a, D.folderPath, D.defaultFrameLayout, data)
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
            if data.class and data.class ~= "CUSTOM" then
                priority_mode_ids[#priority_mode_ids + 1] = mode_id
            end
        else
            failed_count = failed_count + 1
            if not ok then
                LogError("AddCustomFrameMode", mode_id)
            end
        end
    end

    if #priority_mode_ids > 0 then
        local order = addon:GetCustomFrameModesOrder()
        if type(order) == "table" and #order > 0 then
            local is_priority = {}
            for _, mode_id in ipairs(priority_mode_ids) do
                is_priority[mode_id] = true
            end

            local new_order = {}
            for _, mode_id in ipairs(order) do
                if is_priority[mode_id] then
                    new_order[#new_order + 1] = mode_id
                end
            end
            for _, mode_id in ipairs(order) do
                if not is_priority[mode_id] then
                    new_order[#new_order + 1] = mode_id
                end
            end
            addon:ReorderCustomFrameModes(new_order)
        end
    end

    EPF_CustomSkins_Loaded = registered_count > 0
    Log("Textures loaded. Registered modes: " .. tostring(registered_count) .. ", failed/skipped: " .. tostring(failed_count))
end

if ElitePlayerFrame_Enhanced and type(ElitePlayerFrame_Enhanced.WhenInitialised) == "function" then
    ElitePlayerFrame_Enhanced:WhenInitialised(function(addon)
        local ok, err = pcall(function()
            RegisterCustomSkins(addon)
            addon:RegisterCallback("SETTINGS_RESET", function()
                EPF_CustomSkins_Loaded = false
                RegisterCustomSkins(addon)
            end, "EPF_CustomSkins_SettingsReset_ReRegister")
        end)
        if not ok then
            LogError("RegisterCustomSkins", err)
        end
    end)
else
    LogError("Startup", "ElitePlayerFrame_Enhanced API unavailable")
end
