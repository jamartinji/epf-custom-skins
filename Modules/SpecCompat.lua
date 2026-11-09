-- [ SPEC COMPAT ] Forever talent-tree → retail texture-def spec matching.
-- TipTac (LibFroznFunctions.GetTalentsForever) clusters C_Traits nodes by posX into 3 trees.

EPF_CustomSkins_SpecCompat = EPF_CustomSkins_SpecCompat or {}
local SC = EPF_CustomSkins_SpecCompat

-- Retail ChrSpecialization ID → classic/Forever tree index (1-based).
SC.RETAIL_SPEC_TREE_INDEX = {
    [71] = 1, [72] = 2, [73] = 3,
    [65] = 1, [66] = 2, [70] = 3,
    [253] = 1, [254] = 2, [255] = 3,
    [259] = 1, [260] = 2, [261] = 3,
    [256] = 1, [257] = 2, [258] = 3,
    [250] = 1, [251] = 2, [252] = 3,
    [262] = 1, [263] = 2, [264] = 3,
    [62] = 1, [63] = 2, [64] = 3,
    [265] = 1, [266] = 2, [267] = 3,
    [268] = 1, [270] = 2, [269] = 3,
    [102] = 1, [103] = 2, [104] = 3, [105] = 4,
    [577] = 1, [581] = 2, [1480] = 3,
    [1467] = 1, [1468] = 2, [1473] = 3,
}

-- Classic tree names (English) for debug / TipTac parity. Druid Forever has 3 trees.
SC.FOREVER_TREE_NAMES = {
    WARRIOR = { "Arms", "Fury", "Protection" },
    PALADIN = { "Holy", "Protection", "Retribution" },
    HUNTER = { "Beast Mastery", "Marksmanship", "Survival" },
    ROGUE = { "Assassination", "Combat", "Subtlety" },
    PRIEST = { "Discipline", "Holy", "Shadow" },
    SHAMAN = { "Elemental", "Enhancement", "Restoration" },
    MAGE = { "Arcane", "Fire", "Frost" },
    WARLOCK = { "Affliction", "Demonology", "Destruction" },
    DRUID = { "Balance", "Feral Combat", "Restoration" },
    DEATHKNIGHT = { "Blood", "Frost", "Unholy" },
}

function SC.IsForever(addon)
    if addon and addon.GameType and type(addon.GameType.IsGame) == "function" then
        local ok, result = pcall(function() return addon.GameType:IsGame("forever") end)
        if ok and result then
            return true
        end
    end
    local toc = select(4, GetBuildInfo())
    return type(toc) == "number" and toc >= 16000 and toc < 20000
end

--[[
 * Split Forever's single trait tree into per-spec point totals (TipTac algorithm).
 * Returns pointsSpent array (1..n) or nil.
--]]
function SC.GetForeverPointsSpent(unit)
    if not C_Traits or not C_Traits.GetConfigInfo then
        return nil
    end
    unit = unit or "player"
    local is_self = UnitIsUnit and UnitIsUnit(unit, "player")

    local config_id
    if is_self then
        if C_ClassTalents and C_ClassTalents.GetActiveConfigID then
            config_id = C_ClassTalents.GetActiveConfigID()
        end
    else
        if not C_Traits.HasValidInspectData or not C_Traits.HasValidInspectData() then
            return nil
        end
        if Constants and Constants.TraitConsts then
            config_id = Constants.TraitConsts.INSPECT_TRAIT_CONFIG_ID
        end
    end
    if not config_id then
        return nil
    end

    local ok_info, config_info = pcall(C_Traits.GetConfigInfo, config_id)
    if not ok_info or type(config_info) ~= "table" or type(config_info.treeIDs) ~= "table" then
        return nil
    end

    local points_spent = {}
    local total_spent = 0
    for _, tree_id in ipairs(config_info.treeIDs) do
        local tree_spent = 0
        local ok_cur, currency_info = pcall(C_Traits.GetTreeCurrencyInfo, config_id, tree_id, false)
        if ok_cur and type(currency_info) == "table" then
            for _, item in ipairs(currency_info) do
                if type(item.spent) == "number" then
                    tree_spent = tree_spent + item.spent
                end
            end
        end
        points_spent[#points_spent + 1] = tree_spent
        total_spent = total_spent + tree_spent
    end

    -- Forever packs all specs into one trait tree → split by node posX clusters (TipTac).
    if total_spent > 0 and #points_spent < 2 then
        local tree_id = config_info.treeIDs[1]
        local split
        if tree_id and C_Traits.GetTreeNodes and C_Traits.GetNodeInfo then
            local nodes = {}
            local x_count, x_list = {}, {}
            local min_x, max_x
            local ok_nodes, node_ids = pcall(C_Traits.GetTreeNodes, tree_id)
            if ok_nodes and type(node_ids) == "table" then
                for _, node_id in ipairs(node_ids) do
                    local ok_n, node_info = pcall(C_Traits.GetNodeInfo, config_id, node_id)
                    if ok_n and type(node_info) == "table" and type(node_info.posX) == "number" then
                        local x = node_info.posX
                        local rank = (type(node_info.currentRank) == "number") and node_info.currentRank or 0
                        nodes[#nodes + 1] = { x = x, rank = rank }
                        if not x_count[x] then
                            x_count[x] = 0
                            x_list[#x_list + 1] = x
                        end
                        x_count[x] = x_count[x] + 1
                        min_x = (not min_x) and x or math.min(min_x, x)
                        max_x = (not max_x) and x or math.max(max_x, x)
                    end
                end
            end

            if #nodes > 0 and max_x and min_x and max_x > min_x then
                local per_column = { 0, 0, 0 }
                table.sort(x_list)
                local clusters = {}
                if #x_list >= 2 then
                    local gaps = {}
                    for i = 2, #x_list do
                        gaps[#gaps + 1] = x_list[i] - x_list[i - 1]
                    end
                    table.sort(gaps)
                    local threshold = gaps[math.ceil(#gaps / 2)] * 2.5
                    local current = { minX = x_list[1], maxX = x_list[1], count = x_count[x_list[1]] }
                    clusters[#clusters + 1] = current
                    for i = 2, #x_list do
                        if x_list[i] - x_list[i - 1] > threshold then
                            current = { minX = x_list[i], maxX = x_list[i], count = 0 }
                            clusters[#clusters + 1] = current
                        end
                        current.maxX = x_list[i]
                        current.count = current.count + x_count[x_list[i]]
                    end
                end

                if #clusters >= 3 then
                    local by_count = {}
                    for _, cluster in ipairs(clusters) do
                        by_count[#by_count + 1] = cluster
                    end
                    table.sort(by_count, function(a, b)
                        if a.count ~= b.count then
                            return a.count > b.count
                        end
                        return a.minX < b.minX
                    end)
                    local trees = { by_count[1], by_count[2], by_count[3] }
                    table.sort(trees, function(a, b) return a.minX < b.minX end)
                    for _, node in ipairs(nodes) do
                        for column, tree in ipairs(trees) do
                            if node.x >= tree.minX and node.x <= tree.maxX then
                                per_column[column] = per_column[column] + node.rank
                                break
                            end
                        end
                    end
                else
                    local width = (max_x - min_x) / 3
                    for _, node in ipairs(nodes) do
                        local column = math.min(3, math.floor((node.x - min_x) / width) + 1)
                        per_column[column] = per_column[column] + node.rank
                    end
                end

                if per_column[1] + per_column[2] + per_column[3] > 0 then
                    split = per_column
                end
            end
        end

        if not split and tree_id then
            local ok_cur, currencies = pcall(C_Traits.GetTreeCurrencyInfo, config_id, tree_id, false)
            if ok_cur and type(currencies) == "table" and #currencies == 3 then
                local per_currency, sum = {}, 0
                for _, currency_item in ipairs(currencies) do
                    local spent = (type(currency_item.spent) == "number") and currency_item.spent or 0
                    per_currency[#per_currency + 1] = spent
                    sum = sum + spent
                end
                if sum == total_spent then
                    split = per_currency
                end
            end
        end

        if split then
            points_spent = split
        end
    end

    return points_spent
end

--[[
 * Dominant talent-tree index (1-based) from C_Traits points.
 * Untalented (0 points): returns nil so class-base skins win — do NOT use
 * C_SpecializationInfo.GetSpecialization() on Forever (it often returns 1 with 0 points).
--]]
function SC.GetDominantTreeIndex(unit)
    unit = unit or "player"
    local points = SC.GetForeverPointsSpent(unit)
    if type(points) == "table" then
        local best_index, best_points, total = nil, -1, 0
        for i, spent in ipairs(points) do
            local n = tonumber(spent) or 0
            total = total + n
            if n > best_points then
                best_points = n
                best_index = i
            end
        end
        if total > 0 and best_index then
            return best_index, points, best_points
        end
        -- Explicitly untalented: no spec skin.
        return nil, points, 0
    end

    -- No trait data available. Forever must not invent tree 1 via GetSpecialization.
    if SC.IsForever(nil) then
        return nil, nil, 0
    end

    if UnitIsUnit and UnitIsUnit(unit, "player") then
        if C_SpecializationInfo and type(C_SpecializationInfo.GetSpecialization) == "function" then
            local ok, idx = pcall(C_SpecializationInfo.GetSpecialization)
            if ok and type(idx) == "number" and idx > 0 then
                return idx, points, 0
            end
        end
        if type(GetSpecialization) == "function" then
            local ok, idx = pcall(GetSpecialization)
            if ok and type(idx) == "number" and idx > 0 then
                return idx, points, 0
            end
        end
    end

    return nil, points, 0
end

--[[
 * Resolve Forever trait groupID for a retail spec via C_Traits groups (no EPF helper required).
--]]
function SC.RetailSpecToForeverId(addon, retail_spec_id, class_id)
    if type(retail_spec_id) ~= "number" then
        return nil
    end
    local tree_index = SC.RETAIL_SPEC_TREE_INDEX[retail_spec_id]
    if not tree_index or not class_id then
        return nil
    end

    local getter = addon and addon.GetSpecializationInfoForClassID
    if type(getter) == "function" then
        local ok, forever_id = pcall(getter, class_id, tree_index)
        if ok and forever_id then
            return forever_id
        end
    end

    -- Direct Forever path (same as EPF Mainline forever branch).
    if C_ClassTalents and C_ClassTalents.GetTraitTreeForSpec and C_Traits and C_Traits.GetGroupDisplayInfoByTreeID then
        local ok_spec, base_spec = pcall(function()
            if GetSpecializationInfoForClassID then
                return GetSpecializationInfoForClassID(class_id, 1)
            end
            if C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfoForClassID then
                return C_SpecializationInfo.GetSpecializationInfoForClassID(class_id, 1)
            end
        end)
        if ok_spec and base_spec then
            local ok_tree, tree_id = pcall(C_ClassTalents.GetTraitTreeForSpec, base_spec)
            if ok_tree and tree_id then
                local ok_groups, groups = pcall(C_Traits.GetGroupDisplayInfoByTreeID, tree_id)
                if ok_groups and type(groups) == "table" and groups[tree_index] then
                    return groups[tree_index].groupID
                end
            end
        end
    end

    return nil
end

--[[
 * Class file for a retail spec id (only Forever tree-1 collisions need this for debug).
--]]
SC.RETAIL_SPEC_CLASS = {
    [71] = "WARRIOR", [72] = "WARRIOR", [73] = "WARRIOR",
    [65] = "PALADIN", [66] = "PALADIN", [70] = "PALADIN",
    [253] = "HUNTER", [254] = "HUNTER", [255] = "HUNTER",
    [259] = "ROGUE", [260] = "ROGUE", [261] = "ROGUE",
    [256] = "PRIEST", [257] = "PRIEST", [258] = "PRIEST",
    [250] = "DEATHKNIGHT", [251] = "DEATHKNIGHT", [252] = "DEATHKNIGHT",
    [262] = "SHAMAN", [263] = "SHAMAN", [264] = "SHAMAN",
    [62] = "MAGE", [63] = "MAGE", [64] = "MAGE",
    [265] = "WARLOCK", [266] = "WARLOCK", [267] = "WARLOCK",
    [268] = "MONK", [270] = "MONK", [269] = "MONK",
    [102] = "DRUID", [103] = "DRUID", [104] = "DRUID", [105] = "DRUID",
    [577] = "DEMONHUNTER", [581] = "DEMONHUNTER", [1480] = "DEMONHUNTER",
    [1467] = "EVOKER", [1468] = "EVOKER", [1473] = "EVOKER",
}

--[[
 * Class match independent of EPF classSelection toggle (that toggle returns false when off).
--]]
function SC.PlayerMatchesClass(want_class)
    if want_class == nil or want_class == "CUSTOM" then
        return true
    end
    local _, class_file, class_id = UnitClass("player")
    if type(want_class) == "string" and want_class == class_file then
        return true
    end
    if type(want_class) == "number" and want_class == class_id then
        return true
    end
    return false
end

function SC.PlayerMatchesFaction(want_faction)
    if want_faction == nil then
        return true
    end
    local faction = UnitFactionGroup("player")
    if type(want_faction) == "string" and want_faction == faction then
        return true
    end
    return false
end

function SC.PlayerMatchesRace(want_race)
    if want_race == nil then
        return true
    end
    local _, race_file, race_id = UnitRace("player")
    if type(want_race) == "string" and (want_race == race_file or want_race == tostring(race_id)) then
        return true
    end
    if type(want_race) == "number" and want_race == race_id then
        return true
    end
    return false
end

--[[
 * Match texture-definition retail spec against the player's Forever talent tree.
--]]
function SC.CharacterMatchesSpec(addon, want_spec)
    if not addon or want_spec == nil then
        return false
    end

    -- Ignore EPF specializationSelection gate / nil character.specialization on Forever.
    if SC.IsForever(addon) then
        local want_index = SC.RETAIL_SPEC_TREE_INDEX[want_spec]
        if not want_index then
            return false
        end
        local dominant = SC.GetDominantTreeIndex("player")
        return dominant == want_index
    end

    if type(addon.CharacterIsSpecialization) == "function" then
        local ok, matched = pcall(function() return addon:CharacterIsSpecialization(want_spec) end)
        if ok and matched then
            return true
        end
    end

    return false
end

--[[
 * Full autoCondition for a texture definition entry.
 * Forever: Unit* + C_Traits tree points (EPF specialization is often nil).
 * Retail: prefer EPF CharacterIs* so classSelection / specializationSelection still apply.
--]]
function SC.MatchesSkinDefinition(addon, data)
    if not data or data.class == "CUSTOM" or data.auto == false then
        return false
    end

    local forever = SC.IsForever(addon)

    if data.class then
        if forever then
            if not SC.PlayerMatchesClass(data.class) then
                return false
            end
        elseif type(addon.CharacterIsClass) == "function" then
            local ok, matched = pcall(function() return addon:CharacterIsClass(data.class) end)
            if not (ok and matched) then
                return false
            end
        elseif not SC.PlayerMatchesClass(data.class) then
            return false
        end
    end

    if data.spec and not SC.CharacterMatchesSpec(addon, data.spec) then
        return false
    end

    if data.faction then
        if forever then
            if not SC.PlayerMatchesFaction(data.faction) then
                return false
            end
        elseif type(addon.CharacterIsFaction) == "function" then
            local ok, matched = pcall(function() return addon:CharacterIsFaction(data.faction) end)
            if not (ok and matched) then
                return false
            end
        elseif not SC.PlayerMatchesFaction(data.faction) then
            return false
        end
    end

    if data.race then
        if forever then
            if not SC.PlayerMatchesRace(data.race) then
                return false
            end
        elseif type(addon.CharacterIsRace) == "function" then
            local ok, matched = pcall(function() return addon:CharacterIsRace(data.race) end)
            if not (ok and matched) then
                return false
            end
        elseif not SC.PlayerMatchesRace(data.race) then
            return false
        end
    end

    return true
end
