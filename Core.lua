-- [ ADDON LOGIC ] Spec-change handling and registration with ElitePlayerFrame_Enhanced.
-- Texture data is in TextureDefinitions.lua (EPF_CustomSkins_Definitions).

-- Own options (SavedVariables: EPF_CustomSkins_Options in TOC)
EPF_CustomSkins_Options = EPF_CustomSkins_Options or {}
if EPF_CustomSkins_Options.hideInInstance == nil then
    EPF_CustomSkins_Options.hideInInstance = false
end

local baseAddon = nil
local DELAY = 0.25
local pendingUpdate = false

local eventFrame = CreateFrame("Frame")
local delayFrame = CreateFrame("Frame")

local function runUpdate()
    if baseAddon and baseAddon.Update then
        pcall(function() baseAddon:Update(true) end)
    end
end

local function onDelayTick(self, elapsed)
    self.wait = (self.wait or 0) + elapsed
    if self.wait < DELAY then return end
    self:SetScript("OnUpdate", nil)
    self.wait = nil
    pendingUpdate = false
    runUpdate()
    -- Second pass: GetSpecialization() can lag one frame; use timer when available
    if C_Timer and C_Timer.After then
        C_Timer.After(DELAY, runUpdate)
    else
        self.wait = 0
        self:SetScript("OnUpdate", function(s, e)
            s.wait = (s.wait or 0) + e
            if s.wait < DELAY then return end
            s:SetScript("OnUpdate", nil)
            s.wait = nil
            runUpdate()
        end)
    end
end

eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "ZONE_CHANGED_NEW_AREA" then
        if baseAddon and baseAddon.Update and EPF_CustomSkins_Options.hideInInstance then
            pcall(function() baseAddon:Update(true) end)
        end
        return
    end
    if event ~= "PLAYER_SPECIALIZATION_CHANGED" or pendingUpdate then return end
    pendingUpdate = true
    delayFrame.wait = 0
    delayFrame:SetScript("OnUpdate", onDelayTick)
end)

local function AddCustomSkins()
    if EPF_CustomSkins_Loaded then return end
    EPF_CustomSkins_Loaded = true

    local D = EPF_CustomSkins_Definitions
    if not D or not D.textureConfig then
        return
    end

    local folderPath = D.folderPath
    if not folderPath then
        print("|cff00ff00EPF Custom Skins|r |cffff0000folderPath not set in TextureDefinitions.|r")
        return
    end
    local defaultFrameLayout = D.defaultFrameLayout

    for _, data in ipairs(D.textureConfig) do
        ElitePlayerFrame_Enhanced:AddCustomFrameMode(function(a)
            if not baseAddon then
                baseAddon = a
                EPF_CustomSkins_BaseAddon = a
            end

            local className = data.class and (a.safeIndex(a.CLASSES, data.class, "name", 2) or data.class) or (data.race or "?")
            local classColor = (data.class and a.safeIndex(a.CLASSES, data.class, "color")) or CreateColor(1, 1, 1)

            --local fullPath = folderPath .. data.name .. "." .. data.ext
            local fullPath2x = folderPath .. data.name .. "-2x." .. data.ext
            -- For now, using 2x path as the same for fullPath, since there are no low res textures.
            local fullPath = fullPath2x

            local menuName
            if data.displayName then
                menuName = data.displayName
            else
                menuName = className
                if data.spec then
                    local _, specName = GetSpecializationInfoByID(data.spec)
                    menuName = menuName .. " (" .. (specName or ("Spec " .. data.spec)) .. ")"
                end
                if data.race then menuName = menuName .. " - " .. data.race end
                if data.faction then menuName = menuName .. " - " .. data.faction end
            end

            if data.menuColor then
                local colorCode = data.menuColor
                if not colorCode:find("^|c") then
                    colorCode = "|cff" .. colorCode
                end
                menuName = colorCode .. menuName .. "|r"
            end

            local layout = data.layout or defaultFrameLayout
            local restIconOffset = layout.restIconOffset or defaultFrameLayout.restIconOffset
            local defaultLayers = defaultFrameLayout.layers
            local customLayers = layout.layers or {}
            local singleLayer = data.singleLayer

            local textureLayers = {}
            local layerCount = singleLayer and 1 or #defaultLayers
            local startIndex = 1
            for j = 1, layerCount do
                local i = singleLayer and 1 or j
                local def = defaultLayers[i]
                local custom = customLayers[i] or {}
                local layer = {}
                for k, v in pairs(def) do layer[k] = v end
                for k, v in pairs(custom) do layer[k] = v end
                local tex = {
                    ["file"] = fullPath,
                    ["file-2x"] = fullPath2x,
                    ["width"] = layer.width,
                    ["height"] = layer.height,
                    ["leftTexCoord"] = layer.leftTexCoord,
                    ["rightTexCoord"] = layer.rightTexCoord,
                    ["topTexCoord"] = layer.topTexCoord,
                    ["bottomTexCoord"] = layer.bottomTexCoord,
                }
                local ox, oy = layer.pointOffset[1], layer.pointOffset[2]
                textureLayers[j] = a.SetTexture(tex, a.SetPointOffset(ox, oy))
            end

            local layered
            if singleLayer then
                layered = a.SetLayeredTextures(nil, textureLayers[1])
            else
                layered = a.SetLayeredTextures(unpack(textureLayers))
            end

            return {
                menuName,
                classColor,
                layered,
                a.SetPointOffset(restIconOffset[1], restIconOffset[2]),
                function(addon)
                    if data.class then
                        if not addon.settings.classSelection then return false end
                        if addon.info.character.class ~= data.class then return false end
                    end
                    if data.faction then
                        if not addon.settings.factionSelection then return false end
                        if addon.info.character.faction ~= data.faction then return false end
                    end
                    if data.race then
                        local _, playerRaceEn = UnitRace("player")
                        if playerRaceEn ~= data.race then return false end
                    end
                    if data.spec then
                        local currentSpecIndex = GetSpecialization()
                        if currentSpecIndex then
                            local currentSpecID = GetSpecializationInfo(currentSpecIndex)
                            return currentSpecID == data.spec
                        end
                        return false
                    end
                    return true
                end
            }
        end)
    end

    -- [ Hide in instance ] Hook base addon GetTexture so in instances we use default frame when option is on.
    if baseAddon and baseAddon.GetTexture and baseAddon.TEXTURES then
        local origGetTexture = baseAddon.GetTexture
        function baseAddon.GetTexture()
            if EPF_CustomSkins_Options.hideInInstance and IsInInstance() then
                return baseAddon.TEXTURES[1]
            end
            return origGetTexture()
        end
    end

    print("|cff00ff00EPF Custom Skins:|r Textures loaded (with specialization support).")
end

if ElitePlayerFrame_Enhanced and ElitePlayerFrame_Enhanced:Initialised() then
    AddCustomSkins()
else
    hooksecurefunc(ElitePlayerFrame_Enhanced, "Initialised", AddCustomSkins)
end
