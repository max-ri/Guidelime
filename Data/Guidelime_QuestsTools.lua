local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")

function addon.getQuestNameById(id)
	if id == nil then return nil end
	if addon.quests ~= nil and addon.quests[id] ~= nil and addon.quests[id].name ~= nil then
		return addon.quests[id].name
	end
	local locale = GetLocale()
	if addon.questsDB[id] == nil then
		return nil
	elseif addon.questsDB[id]["name_" .. locale] ~= nil then
		return addon.questsDB[id]["name_"..locale]
	else
		return addon.questsDB[id].name
	end
end

function addon.getQuestObjective(id)
	local locale = GetLocale()
	if id == nil or addon.questsDB[id] == nil then
		return
	elseif addon.questsDB[id]["objective_" .. locale] ~= nil then
		return addon.questsDB[id]["objective_"..locale]
	else
		return addon.questsDB[id].objective
	end
end

function addon.getQuestTargetNames(id, typ)
	if GuidelimeData.dataSourceQuestie and Questie ~= nil then return addon.getQuestTargetNamesQuestie(id, typ) end
	if id == nil or addon.questsDB[id] == nil then return end
	local quest
	if typ == "ACCEPT" then 
		quest = addon.questsDB[id].source
	elseif typ == "TURNIN" then
		quest = addon.questsDB[id].deliver
	else
		return
	end
	if quest == nil or type(quest) == "string" then return end
	local names = {}
	for _, element in ipairs(quest) do
		table.insert(names, element.name)
	end
	return names
end	

function addon.getQuestObjectives(id)
	if GuidelimeData.dataSourceQuestie and Questie ~= nil then return addon.getQuestObjectivesQuestie(id, typ) end
	-- list of target names for each quest objective is not available in the database
	return {}
end

function addon.getQuestPositions(id, typ, objective)
	if GuidelimeData.dataSourceQuestie and Questie ~= nil then return addon.getQuestPositionsQuestie(id, typ, objective) end
	if id == nil or addon.questsDB[id] == nil then return end
	local quest
	if typ == "ACCEPT" then 
		quest = addon.questsDB[id].source
	elseif typ == "TURNIN" then
		quest = addon.questsDB[id].deliver
	else
		return
	end
	if quest == nil or type(quest) == "string" then return end
	local positions = {}
	for i in ipairs(quest) do
		local element = quest[i]
		if element.positions ~= nil and (objective == nil or objective == i) then
			for i, pos in ipairs(element.positions) do
				-- TODO: x/y are still switched in db
				local x, y, zone = addon.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid)
				if x ~= nil then
					table.insert(positions, {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, 	mapID = addon.mapIDs[zone], 
						wx = pos.y, wy = pos.x, instance = pos.mapid})
				else
					error("error transforming (" .. pos.x .. "," .. pos.y .. " " .. pos.mapid .. ") into zone coordinates for quest #" .. id)
				end
			end
		end
	end	
	return positions
end

local CLUSTER_DIST = 170

local function findCluster(clusters, x, y, instance)
	local bestCluster, bestDist
	if clusters[instance] ~= nil then
		for i, cluster in ipairs(clusters[instance]) do
			local dist = (x - cluster.x) * (x - cluster.x) + (y - cluster.y) * (y - cluster.y)
			if dist < CLUSTER_DIST * CLUSTER_DIST and (bestDist == nil or bestDist > dist) then
				bestCluster = cluster
			end
		end
	else
		clusters[instance] = {}
	end
	if bestCluster == nil then
		bestCluster = {x = 0, y = 0, count = 0, instance = instance}
		table.insert(clusters[instance], bestCluster)
	end
	return bestCluster
end

local function addToCluster(cluster, x, y)
	cluster.x = (cluster.x * cluster.count + x) / (cluster.count + 1)
	cluster.y = (cluster.y * cluster.count + y) / (cluster.count + 1)
	cluster.count = cluster.count + 1
	--if addon.debugging then print("LIME: adding to cluster ", cluster.count, cluster.x, cluster.y) end
	return cluster
end

local function selectFurthestPosition(positions, clusters)
	local maxPos, maxDist
	for _, pos in ipairs(positions) do
		if not pos.selected then
			if clusters[pos.instance] == nil then return pos end
			local dist = 0
			for _, cluster in ipairs(clusters[pos.instance]) do
				dist = dist + (cluster.x - pos.wx) * (cluster.x - pos.wx) + (cluster.y - pos.wy) * (cluster.y - pos.wy) 
			end
			if maxDist == nil or dist > maxDist then
				maxPos, maxDist = pos, dist
			end
		end
	end
	--if addon.debugging then print("LIME: furthest point is #", maxPos.x, maxPos.y, maxPos.mapid, maxDist) end
	return maxPos
end

function addon.getQuestPosition(id, typ, index)
	local clusters = {}
	local maxCluster	
	local positions = addon.getQuestPositions(id, typ, index)
	if positions == nil then return end
	for i = 1, #positions do 
		local pos = selectFurthestPosition(positions, clusters)
		--if addon.debugging then print("LIME: found position", pos.wx, pos.wy, pos.instance) end
		pos.selected = true
		local cluster = addToCluster(findCluster(clusters, pos.wx, pos.wy, pos.instance), pos.wx, pos.wy)
		if maxCluster == nil or cluster.count > maxCluster.count then maxCluster = cluster end
	end
	if maxCluster ~= nil then
		if addon.debugging and maxCluster.count > 1 then print("LIME: biggest cluster of", maxCluster.count, "at", maxCluster.x, maxCluster.y, maxCluster.instance) end
		local x, y, zone = addon.GetZoneCoordinatesFromWorld(maxCluster.x, maxCluster.y, maxCluster.instance)
		if x ~= nil then
			return {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = addon.mapIDs[zone]}
		else
			error("error transforming (" .. maxCluster.x .. "," .. maxCluster.y .. " " .. maxCluster.instance .. ") into zone coordinates for quest #" .. id)
		end
	end
end

function addon.findInLists(line, wordLists, first, startPos, endPos)
	local s, e, w, result
	local lower = " " .. line:lower() .. " "
	startPos = (startPos or 1)
	endPos = (endPos or #lower)
	if first == nil then first = true end
	for wordList, r in pairs(wordLists) do
		for word in wordList:gmatch("[^;]+") do
			word = word:gsub(" ", "[%%s%%p]")
			local s2, e2 = lower:find(word, startPos)
			if s2 ~= nil and s2 < endPos and (s == nil or (first and s > s2) or (not first and s < s2) or (s == s2 and #word > #w)) then
				s = s2
				e = e2
				w = word
				result = r
			end
		end
	end
	if s ~= nil then 
		if type(result) == "function" then
			return result(s - 1, e - 1, lower:match(w, startPos))
		else
			return result, s - 1, e - 1, lower:match(w, startPos)
		end
	end
end

function addon.getPossibleQuestIdsByName(name, part, faction, race, class)
	if addon.questsDBReverse == nil then
		addon.questsDBReverse = {}
		for id, quest in pairs(addon.questsDB) do
			local n = addon.getQuestNameById(id):lower():gsub("[%(%)\"%s%p]","")
			if addon.questsDBReverse[n] == nil then addon.questsDBReverse[n] = {} end
			table.insert(addon.questsDBReverse[n], id)
			-- if localized quest name is different from english name also include english name
			if addon.getQuestNameById(id) ~= addon.questsDB[id].name then
				n = addon.questsDB[id].name:lower():gsub("[%(%)\"%s%p]",""):gsub("  ", " ")
				if addon.questsDBReverse[n] == nil then addon.questsDBReverse[n] = {} end
				table.insert(addon.questsDBReverse[n], id)
			end
		end
	end
	local filteredName = name:lower():gsub("[%(%)\"%s%p]","")
	local ids = addon.questsDBReverse[filteredName]
	if ids == nil or #ids == 0 and part == nil then
		print(filteredName)
		local wordListMap = {}
		wordListMap[L.WORD_LIST_PART_N] = function(s, e, n) filteredName = filteredName:sub(1, s - 1); part = tonumber(n) end
		if GetLocale() ~= "enUS" then wordListMap[addon.defaultL.WORD_LIST_PART_N] = function(s, e, n) filteredName = filteredName:sub(1, s - 1); part = tonumber(n) end end
		local i = 1
		while L["WORD_LIST_PART_" .. i] ~= nil do
			local ii = i
			wordListMap[L["WORD_LIST_PART_" .. i]] = function(s, e) filteredName = filteredName:sub(1, s - 1); part = ii end
			if GetLocale() ~= "enUS" then wordListMap[addon.defaultL["WORD_LIST_PART_" .. i]] = function(s, e) filteredName = filteredName:sub(1, s - 1); part = ii end end
			i = i + 1
		end
		addon.findInLists(filteredName, wordListMap, false)
		if part == nil then
			addon.findInLists(filteredName, {["(%d+) "] = function(s, e, n) filteredName = filteredName:sub(1, s - 1); part = tonumber(n) end}, false)
		end
		print(filteredName, part)
		ids = addon.questsDBReverse[filteredName]
	end	

	if ids == nil then ids = {} end
	if #ids > 0 and part ~= nil then
		if part > 1 and #ids == 1 then 
			-- looking for part > 1 and only getting 1 quest? not good return nil
			return {}
		elseif #ids > 1 then
			local filteredIds = {}
			for i, id in ipairs(ids) do
				if addon.questsDB[id].series == part then
					table.insert(filteredIds, id)		
				end
			end
			if #filteredIds > 0 then ids = filteredIds end
		end
	end
	if faction ~= nil or race ~= nil or class ~= nil then
		local filteredIds = {}
		for i, id in ipairs(ids) do
			local match = faction == nil or addon.questsDB[id].faction == nil or faction == addon.questsDB[id].faction
			if match and race ~= nil and addon.questsDB[id].races ~= nil then
				match = false
				for i, r in ipairs(race) do
					if addon.contains(addon.questsDB[id].races, r) then match = true; break end
				end
			end	
			if match and class ~= nil and addon.questsDB[id].classes ~= nil then
				match = false
				for i, c in ipairs(class) do
					if addon.contains(addon.questsDB[id].classes, c) then match = true; break end
				end
			end	
			if match then table.insert(filteredIds, id) end
		end
		ids = filteredIds
	end
	return ids
end

function addon.GetZoneCoordinatesFromWorld(worldX, worldY, instance)
	for name, id in pairs(addon.mapIDs) do
		local x, y = HBD:GetZoneCoordinatesFromWorld(worldX, worldY, id, false)
		if x ~= nil and x > 0 and x < 1 and y ~= nil and y > 0 and y < 1 then
			local checkX, checkY, checkInstance = HBD:GetWorldCoordinatesFromZone(x, y, id)
			if checkInstance == instance then
				-- hack for some bfa zone names
				do
					local e = name:find("[@!]")
					if e ~= nil then name = name:sub(1, e - 1) end
				end
				return x, y, name
			end
		end
	end
end
