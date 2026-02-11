-- [ ADDON LOGIC ] Spec-change handling and registration with ElitePlayerFrame_Enhanced.
-- Texture data is in TextureDefinitions.lua (EPF_CustomSkins_Definitions).

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
    -- Second pass in case GetSpecialization() was not updated yet
    self.wait = 0
    self:SetScript("OnUpdate", function(s, e)
        s.wait = s.wait + e
        if s.wait < DELAY then return end
        s:SetScript("OnUpdate", nil)
        s.wait = nil
        runUpdate()
    end)
end

eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function(_, event)
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

    local folderPath = D.folderPath or "Interface\\AddOns\\ElitePlayerFrame_Enhanced_CustomSkins\\assets\\"
    local defaultFrameLayout = D.defaultFrameLayout

    for _, data in ipairs(D.textureConfig) do
        ElitePlayerFrame_Enhanced:AddCustomFrameMode(function(a)
            if not baseAddon then baseAddon = a end

            local className = a.safeIndex(a.CLASSES, data.class, "name", 2) or data.class
            local classColor = a.safeIndex(a.CLASSES, data.class, "color") or CreateColor(1, 1, 1)

            local fullPath = folderPath .. data.name .. "." .. data.ext
            local fullPath2x = folderPath .. data.name .. "-2x." .. data.ext

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
                if not data.spec and not data.race and not data.faction then
                    menuName = menuName .. " (Custom)"
                end
            end

            local layout = data.layout or defaultFrameLayout
            local restIconOffset = layout.restIconOffset or defaultFrameLayout.restIconOffset

            local textureLayers = {}
            for i, layer in ipairs(layout.layers or defaultFrameLayout.layers) do
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
                textureLayers[i] = a.SetTexture(tex, a.SetPointOffset(ox, oy))
            end

            return {
                menuName,
                classColor,
                a.SetLayeredTextures(unpack(textureLayers)),
                a.SetPointOffset(restIconOffset[1], restIconOffset[2]),
                function(addon)
                    if not addon.settings.classSelection then return false end
                    if addon.info.character.class ~= data.class then return false end
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

    print("|cff00ff00EPF Custom Skins:|r Textures loaded (with specialization support).")
end

if ElitePlayerFrame_Enhanced and ElitePlayerFrame_Enhanced:Initialised() then
    AddCustomSkins()
else
    hooksecurefunc(ElitePlayerFrame_Enhanced, "Initialised", AddCustomSkins)
end
