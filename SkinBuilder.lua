-- [ SKIN BUILDER ] Shared helpers for menu labels and layered textures.

EPF_CustomSkins_SkinBuilder = EPF_CustomSkins_SkinBuilder or {}

local SB = EPF_CustomSkins_SkinBuilder

local function deep_copy_layer(src)
    local layer = {}
    for k, v in pairs(src) do
        if k == "pointOffset" and type(v) == "table" then
            layer.pointOffset = { v[1], v[2] }
        else
            layer[k] = v
        end
    end
    return layer
end

local function merge_layer(base, override)
    local layer = deep_copy_layer(base or {})
    if type(override) ~= "table" then
        return layer
    end
    for k, v in pairs(override) do
        if k == "pointOffset" and type(v) == "table" then
            layer.pointOffset = { v[1], v[2] }
        else
            layer[k] = v
        end
    end
    return layer
end

--[[
 * Resolve layoutPreset / layout string|table into concrete singleLayer + layout table.
 * Presets live on EPF_CustomSkins_Definitions.layoutPresets (top, bot, dual).
 * Default preset is single-layer top half of a 512 atlas (most skins).
--]]
function SB.ResolveEntryLayout(definitions, entry)
    definitions = definitions or EPF_CustomSkins_Definitions or {}
    entry = entry or {}
    local presets = definitions.layoutPresets or {}
    local default_name = definitions.defaultLayoutPreset or "top"

    local preset_name = nil
    local layout_override = nil

    local layout_field = entry.layout
    if type(layout_field) == "string" then
        preset_name = layout_field
    elseif type(layout_field) == "table" then
        if type(layout_field.preset) == "string" then
            preset_name = layout_field.preset
            layout_override = layout_field
        else
            layout_override = layout_field
        end
    end

    if entry.dualLayer == true then
        preset_name = "dual"
    end

    if not preset_name then
        if entry.singleLayer == false then
            preset_name = "dual"
        elseif layout_override then
            -- Custom layout table without preset: keep legacy dual default only when clearly dual.
            local layer_count = layout_override.layers and #layout_override.layers or 0
            if entry.singleLayer == true or layer_count <= 1 then
                preset_name = default_name
            else
                preset_name = "dual"
            end
        else
            preset_name = default_name
        end
    end

    if preset_name == "bottom" then
        preset_name = "bot"
    end

    local preset = presets[preset_name]
    if not preset then
        preset = presets[default_name] or presets.top
        preset_name = default_name
    end

    local single_layer = preset and preset.singleLayer
    if entry.singleLayer ~= nil then
        single_layer = entry.singleLayer and true or false
    elseif entry.dualLayer == true then
        single_layer = false
    end

    local base_layout = (preset and preset.layout) or definitions.defaultFrameLayout or { layers = {} }
    local merged = {
        layers = {},
        restIconOffset = base_layout.restIconOffset,
    }

    local base_layers = base_layout.layers or {}
    local override_layers = (layout_override and layout_override.layers) or {}
    local layer_count = single_layer and 1 or math.max(#base_layers, #override_layers, 2)
    if single_layer then
        layer_count = 1
    end

    for i = 1, layer_count do
        local base_i = base_layers[i] or base_layers[1] or {}
        merged.layers[i] = merge_layer(base_i, override_layers[i])
    end

    if layout_override and layout_override.restIconOffset then
        merged.restIconOffset = layout_override.restIconOffset
    end
    if entry.restIconOffset then
        merged.restIconOffset = entry.restIconOffset
    end

    -- Shorthand: entry.pointOffset applies to the portrait/single layer.
    if entry.pointOffset and type(entry.pointOffset) == "table" and merged.layers[1] then
        local idx = single_layer and 1 or math.min(2, #merged.layers)
        merged.layers[idx].pointOffset = { entry.pointOffset[1], entry.pointOffset[2] }
    end

    return single_layer, merged, preset_name
end

--[[
 * Remove WoW |cffRRGGBB and |cAARRGGBB color sequences. Do not use [%x]+ (hex letters eat "Alianza"/"Horda").
--]]
function SB.GetEntryPreviewPath(folder_path, entry)
    if not folder_path or not entry or not entry.name then return nil end
    local ext = entry.ext or "png"
    return folder_path .. entry.name .. "-2x." .. ext
end

function SB.GetEntryPreviewTexCoords(entry, default_frame_layout)
    local definitions = EPF_CustomSkins_Definitions
    local _, layout = SB.ResolveEntryLayout(definitions, entry)
    local layer = layout and layout.layers and layout.layers[1]
    if not layer then
        local fallback = default_frame_layout and default_frame_layout.layers and default_frame_layout.layers[1]
        if fallback then
            return fallback.leftTexCoord or 0, fallback.rightTexCoord or 1, fallback.topTexCoord or 0, fallback.bottomTexCoord or 1
        end
        return 0, 1, 0, 1
    end
    return layer.leftTexCoord or 0, layer.rightTexCoord or 1, layer.topTexCoord or 0, layer.bottomTexCoord or 1
end

function SB.StripColorCodes(text)
    if not text or text == "" then return "" end
    text = text:gsub("|cff%x%x%x%x%x%x", "")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    return text:gsub("|r", "")
end

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
    local ext = data.ext or "png"
    local full_path_2x = folder_path .. data.name .. "-2x." .. ext
    local full_path = full_path_2x

    local definitions = EPF_CustomSkins_Definitions
    local single_layer, layout = SB.ResolveEntryLayout(definitions, data)
    if not layout or not layout.layers or not layout.layers[1] then
        layout = default_frame_layout
        single_layer = data.singleLayer and true or false
    end

    local layers = layout.layers
    local layer_count = single_layer and 1 or #layers
    if layer_count < 1 then
        layer_count = 1
    end

    local texture_layers = {}
    for j = 1, layer_count do
        local layer = layers[j] or layers[1]
        local offset = layer.pointOffset or { 0, 0 }
        local tex = addon.CreateTexture({
            ["file"] = full_path,
            ["file-2x"] = full_path_2x,
            ["width"] = layer.width,
            ["height"] = layer.height,
            ["leftTexCoord"] = layer.leftTexCoord,
            ["rightTexCoord"] = layer.rightTexCoord,
            ["topTexCoord"] = layer.topTexCoord,
            ["bottomTexCoord"] = layer.bottomTexCoord,
        }, addon.CreatePointOffset(offset[1], offset[2]))
        texture_layers[j] = tex
    end

    local layered
    if single_layer then
        layered = addon.CreateLayeredTextures(nil, texture_layers[1])
    else
        layered = addon.CreateLayeredTextures(texture_layers[1], texture_layers[2])
    end

    local rest_icon_offset = layout.restIconOffset or (default_frame_layout and default_frame_layout.restIconOffset) or { 0, 0 }
    return layered, addon.CreatePointOffset(rest_icon_offset[1], rest_icon_offset[2])
end

function SB.ReplaceLayeredTexture(base_addon, mode_id, layered, rest_offset)
    if not base_addon or not mode_id then return false end
    local textures = base_addon.TEXTURES
    if not textures or not textures[mode_id] then return false end
    local target = textures[mode_id]
    target.Frame = nil
    target.Portrait = nil
    return SB.ApplyLayeredTexture(base_addon, mode_id, layered, rest_offset)
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
