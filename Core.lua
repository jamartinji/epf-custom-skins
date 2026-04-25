-- [ ADDON LOGIC ] Spec-change handling and registration with ElitePlayerFrame_Enhanced.
-- Texture data is in TextureDefinitions.lua (EPF_CustomSkins_Definitions).

local baseAddon = nil
local DELAY = 0.25
local pendingUpdate = false
local registerRetries = 0
local MAX_REGISTER_RETRIES = 60
local initialisationHookRegistered = false
local REQUIRED_EPF_VERSION = "1.10.1"

local eventFrame = CreateFrame("Frame")
local delayFrame = CreateFrame("Frame")
local INFO_LOGS = false

local function Log(message)
    if INFO_LOGS and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00EPF Custom Skins:|r " .. tostring(message))
    end
end

local function LogError(context, err)
    local details = tostring(err or "unknown error")
    Log("|cffff3333" .. tostring(context) .. ": " .. details .. "|r")
    if geterrorhandler then
        geterrorhandler()("EPF Custom Skins - " .. tostring(context) .. ": " .. details)
    end
end

local function ParseVersion(versionString)
    if type(versionString) ~= "string" then return nil end
    local major, minor, patch = versionString:match("(%d+)%.(%d+)%.(%d+)")
    if not major then
        major, minor = versionString:match("(%d+)%.(%d+)")
        patch = "0"
    end
    if not major then return nil end
    return tonumber(major) or 0, tonumber(minor) or 0, tonumber(patch) or 0
end

local function IsVersionAtLeast(currentVersion, minimumVersion)
    local c1, c2, c3 = ParseVersion(currentVersion)
    local m1, m2, m3 = ParseVersion(minimumVersion)
    if not (c1 and m1) then return false end
    if c1 ~= m1 then return c1 > m1 end
    if c2 ~= m2 then return c2 > m2 end
    return c3 >= m3
end

local function runUpdate()
    if baseAddon and baseAddon.Update then
        local ok, err = pcall(function() baseAddon:Update(true) end)
        if not ok then
            LogError("runUpdate", err)
        end
    elseif type(PlayerFrame_Update) == "function" then
        pcall(PlayerFrame_Update, true)
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
        if baseAddon and baseAddon.Update then
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

    local D = EPF_CustomSkins_Definitions
    if not D or not D.textureConfig then
        Log("Texture definitions not available yet.")
        return
    end

    local folderPath = D.folderPath
    if not folderPath then
        LogError("Setup", "folderPath not set in TextureDefinitions")
        return
    end
    local defaultFrameLayout = D.defaultFrameLayout
    Log("Registering custom frame modes...")
    local registeredCount = 0
    local failedCount = 0

    for idx, data in ipairs(D.textureConfig) do
        local ok, result = pcall(function()
            return ElitePlayerFrame_Enhanced:AddCustomFrameMode(function(a)
            if not baseAddon then
                baseAddon = a
                EPF_CustomSkins_BaseAddon = a
                Log("Captured base addon reference.")
            end

            local safeIndex = a.SafeIndex or a.safeIndex
            local createTexture = a.CreateTexture or a.SetTexture
            local createPointOffset = a.CreatePointOffset or a.SetPointOffset
            local createLayeredTextures = a.CreateLayeredTextures or a.SetLayeredTextures
            if type(safeIndex) ~= "function"
                or type(createTexture) ~= "function"
                or type(createPointOffset) ~= "function"
                or type(createLayeredTextures) ~= "function"
            then
                return
            end

            local classId
            local className
            local classColor
            if data.class and type(a.GetClass) == "function" then
                local ok, classData = pcall(function() return a:GetClass(data.class) end)
                if ok and type(classData) == "table" then
                    classId = classData.id
                    if type(classData.name) == "table" then
                        className = classData.name[2] or classData.name[1]
                    else
                        className = classData.name
                    end
                    classColor = classData.color
                end
            end
            if not classId and data.class then
                classId = (a.CLASSES_ENUM and a.CLASSES_ENUM[data.class]) or data.class
            end
            if not className then
                className = data.class and tostring(data.class) or (data.race or "?")
            end
            if not classColor then
                classColor = CreateColor(1, 1, 1)
            end

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
                textureLayers[j] = createTexture(tex, createPointOffset(ox, oy))
            end

            local layered
            if a.CreateLayeredTextures then
                if singleLayer then
                    layered = createLayeredTextures(nil, textureLayers[1])
                else
                    layered = createLayeredTextures(textureLayers[1], textureLayers[2])
                end
            elseif singleLayer then
                layered = createLayeredTextures(nil, textureLayers[1])
            elseif #textureLayers == 2 then
                layered = createLayeredTextures(textureLayers[1], textureLayers[2])
            else
                layered = createLayeredTextures(unpack(textureLayers))
            end

            return {
                menuName,
                classColor,
                layered,
                createPointOffset(restIconOffset[1], restIconOffset[2]),
                function(addon)
                    addon = addon or baseAddon
                    local settings = (addon and addon.settings) or _G["ElitePlayerFrame_Enhanced_Settings"] or {}
                    local classSelectionEnabled = settings.classSelection ~= false
                    local factionSelectionEnabled = settings.factionSelection ~= false
                    local specSelectionEnabled = settings.specializationSelection ~= false

                    if data.class then
                        -- Manual-only entries should never be auto-selected.
                        if data.class == "CUSTOM" then return false end
                        if not classSelectionEnabled then return false end
                        local _, playerClassToken = UnitClass("player")
                        if type(data.class) == "string" then
                            if playerClassToken ~= data.class then return false end
                        elseif classId then
                            local _, _, playerClassId = UnitClass("player")
                            if playerClassId ~= classId then return false end
                        end
                    end
                    if data.faction then
                        if not factionSelectionEnabled then return false end
                        if UnitFactionGroup("player") ~= data.faction then return false end
                    end
                    if data.race then
                        local _, playerRaceEn = UnitRace("player")
                        if playerRaceEn ~= data.race then return false end
                    end
                    if data.spec then
                        if not specSelectionEnabled then return true end
                        local currentSpecID
                        if PlayerUtil and type(PlayerUtil.GetCurrentSpecID) == "function" then
                            currentSpecID = PlayerUtil.GetCurrentSpecID()
                        elseif GetSpecialization and GetSpecializationInfo then
                            local currentSpecIndex = GetSpecialization()
                            if currentSpecIndex then
                                currentSpecID = GetSpecializationInfo(currentSpecIndex)
                            end
                        end
                        if currentSpecID ~= data.spec then return false end
                    end
                    return true
                end
            }
            end)
        end)

        if not ok then
            LogError("AddCustomFrameMode", result)
            failedCount = failedCount + 1
        elseif result then
            registeredCount = registeredCount + 1
        else
            failedCount = failedCount + 1
        end
    end

    if registeredCount > 0 then
        EPF_CustomSkins_Loaded = true
        Log("Textures loaded (with specialization support). Registered modes: " .. tostring(registeredCount) .. ", failed/skipped: " .. tostring(failedCount))
        -- EPF may have already resolved Auto mode before custom entries existed.
        -- Force a refresh pass now and once more shortly after to catch load-order timing.
        runUpdate()
        if C_Timer and C_Timer.After then
            C_Timer.After(0.2, runUpdate)
        end
    else
        Log("No custom frame modes registered yet. Failed/skipped: " .. tostring(failedCount))
    end
end

local function TryAddCustomSkins()
    if EPF_CustomSkins_Loaded then
        return
    end

    local addon = ElitePlayerFrame_Enhanced
    if not addon then
        registerRetries = registerRetries + 1
        if registerRetries <= MAX_REGISTER_RETRIES and C_Timer and C_Timer.After then
            Log("Base addon API not ready. Retry " .. tostring(registerRetries) .. "/" .. tostring(MAX_REGISTER_RETRIES))
            C_Timer.After(0.5, TryAddCustomSkins)
        else
            LogError("Startup", "ElitePlayerFrame_Enhanced global not available for custom registration")
        end
        return
    end

    if type(addon.WhenInitialised) == "function" and not initialisationHookRegistered then
        initialisationHookRegistered = true
        addon:WhenInitialised(function()
            TryAddCustomSkins()
        end)
    end

    local epfVersion = C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata("ElitePlayerFrame_Enhanced", "Version")
    if not IsVersionAtLeast(epfVersion, REQUIRED_EPF_VERSION) then
        LogError("Startup", ("ElitePlayerFrame_Enhanced v%s or newer is required (found: %s)"):format(REQUIRED_EPF_VERSION, tostring(epfVersion or "unknown")))
        return
    end

    if type(addon.AddCustomFrameMode) ~= "function" then
        registerRetries = registerRetries + 1
        if registerRetries <= MAX_REGISTER_RETRIES and C_Timer and C_Timer.After then
            Log("Base addon registration API not ready. Retry " .. tostring(registerRetries) .. "/" .. tostring(MAX_REGISTER_RETRIES))
            C_Timer.After(0.5, TryAddCustomSkins)
        else
            LogError("Startup", "ElitePlayerFrame_Enhanced AddCustomFrameMode API unavailable after retries")
        end
        return
    end

    AddCustomSkins()
    if not EPF_CustomSkins_Loaded then
        registerRetries = registerRetries + 1
        if registerRetries <= MAX_REGISTER_RETRIES and C_Timer and C_Timer.After then
            Log("Custom modes still pending. Retry " .. tostring(registerRetries) .. "/" .. tostring(MAX_REGISTER_RETRIES))
            C_Timer.After(0.5, TryAddCustomSkins)
        else
            LogError("Startup", "Could not register custom modes after retries")
        end
    end
end

TryAddCustomSkins()
