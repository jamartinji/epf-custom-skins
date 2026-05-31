-- [ SKIN BUILDER ] Shared helpers for menu labels and layered textures.

EPF_CustomSkins_SkinBuilder = EPF_CustomSkins_SkinBuilder or {}

local SB = EPF_CustomSkins_SkinBuilder

function SB.BuildMenuName(addon, data)
    if data.displayName then
        return data.displayName
    end

    local class_name = "?"
    if data.class then
        class_name = tostring(data.class)
    elseif data.race then
        class_name = data.race
    elseif data.faction then
        class_name = data.faction
    end

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
    if data.race and type(addon.GetRace) == "function" then
        local race_info = addon:GetRace(data.race)
        if type(race_info) == "table" and race_info.name then
            class_name = race_info.name
        end
    end
    if data.faction and not data.class and not data.race and type(addon.GetFaction) == "function" then
        local faction_info = addon:GetFaction(data.faction)
        if type(faction_info) == "table" and faction_info.name then
            class_name = faction_info.name
        end
    end

    local menu_name = class_name
    if data.spec then
        local _, spec_name = GetSpecializationInfoByID(data.spec)
        menu_name = menu_name .. " (" .. (spec_name or ("Spec " .. data.spec)) .. ")"
    end
    if data.race and data.class then
        local race_label = data.race
        if type(addon.GetRace) == "function" then
            local race_info = addon:GetRace(data.race)
            if type(race_info) == "table" and race_info.name then
                race_label = race_info.name
            end
        end
        menu_name = menu_name .. " - " .. race_label
    end
    if data.faction and (data.class or data.race) then
        local faction_label = data.faction
        if type(addon.GetFaction) == "function" then
            local faction_info = addon:GetFaction(data.faction)
            if type(faction_info) == "table" and faction_info.name then
                faction_label = faction_info.name
            end
        end
        menu_name = menu_name .. " - " .. faction_label
    end

    if data.menuColor then
        local color_code = data.menuColor
        if not color_code:find("^|c") then
            color_code = "|cff" .. color_code
        end
        menu_name = color_code .. menu_name .. "|r"
    elseif data.faction and type(addon.GetFaction) == "function" then
        local faction_info = addon:GetFaction(data.faction)
        if type(faction_info) == "table" and faction_info.color and faction_info.color.GetRGB then
            local r, g, b = faction_info.color:GetRGB()
            menu_name = format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, menu_name)
        end
    end

    return menu_name
end

function SB.BuildTextures(addon, folder_path, default_frame_layout, data)
    local full_path_2x = folder_path .. data.name .. "-2x." .. data.ext
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

function SB.ApplyLayeredTexture(base_addon, mode_id, layered, rest_offset)
    if not base_addon or not mode_id or not layered then return false end
    local textures = base_addon.TEXTURES
    if not textures or not textures[mode_id] then return false end

    local target = textures[mode_id]
    if not layered.Frame and not layered.Portrait then
        layered = { ["Frame"] = layered }
    end
    for key, layer in pairs(layered) do
        if type(layer) == "table" then
            target[key] = target[key] or {}
            local atlas = type(layer.atlas) == "string" and { ["name"] = layer.atlas } or layer.atlas
            if atlas and atlas.name and (not atlas.width or not atlas.height) then
                if C_Texture and C_Texture.GetAtlasInfo then
                    local ai = C_Texture.GetAtlasInfo(atlas.name)
                    if ai then
                        atlas.width = atlas.width or ai.width
                        atlas.height = atlas.height or ai.height
                    end
                end
            end
            target[key].atlas = atlas
            target[key].offsets = layer.offsets or base_addon.CreatePointOffset(0, 0)
        end
    end
    if rest_offset then
        target.restIconOffsets = rest_offset
    end
    return true
end
