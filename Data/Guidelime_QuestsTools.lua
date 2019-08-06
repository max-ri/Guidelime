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

-- returns a list of synonyms for quest source / each objective / turn in; e.g. {{"Dealt with The Hogger Situation", "Huge Gnoll Claw", "Hogger"}} for id = 176, typ = "COMPLETE"
function addon.getQuestObjectives(id, typ)
	if id == nil then return end
	if typ == nil then typ = "COMPLETE" end
	if GuidelimeData.dataSourceQuestie and Questie ~= nil then return addon.getQuestObjectivesQuestie(id, typ) end
	if addon.questsDB[id] == nil then return end
	local locale = GetLocale()
	local ids = {}
	if typ == "ACCEPT" then 
		if addon.questsDB[id].source ~= nil then
			for i, e in ipairs(addon.questsDB[id].source) do
				ids[i] = {[e.type] = {e.id}}
			end
		end
	elseif typ == "TURNIN" then
		if addon.questsDB[id].deliver ~= nil then
			for i, e in ipairs(addon.questsDB[id].deliver) do
				ids[i] = {[e.type] = {e.id}}
			end
		end
	elseif typ == "COMPLETE" then
		local c = 1
		if addon.questsDB[id].kill ~= nil then
			for i, id in ipairs(addon.questsDB[id].kill) do
				ids[c] = {npc = {id}}
				c = c + 1
			end
		end
		if addon.questsDB[id].interact ~= nil then
			for i, id in ipairs(addon.questsDB[id].interact) do
				ids[c] = {object = {id}}
				c = c + 1
			end
		end
		if addon.questsDB[id].gather ~= nil then
			for i, id in ipairs(addon.questsDB[id].gather) do
				ids[c] = {item = {id}}
				c = c + 1
			end
		end
	end
	local names = {}
	for i, objectiveIds in ipairs(ids) do
		names[i] = {}
		if objectiveIds.item ~= nil then
			for _, itemId in ipairs(objectiveIds.item) do
				local item = addon.itemsDB[itemId]
				if item ~= nil then
					if item["name_" .. locale] ~= nil then
						table.insert(names[i], item["name_" .. locale])
					end
					if not addon.contains(names[i], item.name) then table.insert(names[i], item.name) end
					if item.drop ~= nil then
						for _, npcId in ipairs(item.drop) do
							if objectiveIds.npc == nil then objectiveIds.npc = {} end
							table.insert(objectiveIds.npc, npcId)
						end
					end
					if item.object ~= nil then
						for _, objectId in ipairs(item.object) do
							if objectiveIds.object == nil then objectiveIds.object = {} end
							table.insert(objectiveIds.object, objectId)
						end
					end
				end
			end
		end
		if objectiveIds.npc ~= nil then
			for _, npcId in ipairs(objectiveIds.npc) do
				local creature = addon.creaturesDB[npcId]
				if creature ~= nil then
					if creature["name_" .. locale] ~= nil then
						if not addon.contains(names[i], creature["name_" .. locale]) then table.insert(names[i], creature["name_" .. locale]) end
					end
					if not addon.contains(names[i], creature.name) then table.insert(names[i], creature.name) end
				end
			end
		end
		if objectiveIds.object ~= nil then
			for _, objectId in ipairs(objectiveIds.object) do
				local object = addon.objectsDB[objectId]
				if object ~= nil then
					if object["name_" .. locale] ~= nil then
						if not addon.contains(names[i], object["name_" .. locale]) then table.insert(names[i], object["name_" .. locale]) end
					end
					if not addon.contains(names[i], object.name) then table.insert(names[i], object.name) end
				end
			end
		end
	end	
	return names
end

function addon.getQuestPositions(id, typ, objective)
	if GuidelimeData.dataSourceQuestie and Questie ~= nil then return addon.getQuestPositionsQuestie(id, typ, objective) end
	if id == nil or addon.questsDB[id] == nil then return end
	local ids = {npc = {}, object = {}, item = {}}
	if typ == "ACCEPT" then 
		if addon.questsDB[id].source ~= nil then
			for i, e in ipairs(addon.questsDB[id].source) do
				if objective == nil or objective == i then
					table.insert(ids[e.type], e.id)
				end
			end
		end
	elseif typ == "TURNIN" then
		if addon.questsDB[id].deliver ~= nil then
			for i, e in ipairs(addon.questsDB[id].deliver) do
				if objective == nil or objective == i then
					table.insert(ids[e.type], e.id)
				end
			end
		end
	elseif typ == "COMPLETE" then
		local c = 1
		if addon.questsDB[id].kill ~= nil then
			for i, id in ipairs(addon.questsDB[id].kill) do
				if objective == nil or objective == c then
					table.insert(ids.npc, id)
				end
				c = c + 1
			end
		end
		if addon.questsDB[id].interact ~= nil then
			for i, id in ipairs(addon.questsDB[id].interact) do
				if objective == nil or objective == c then
					table.insert(ids.object, id)
				end
				c = c + 1
			end
		end
		if addon.questsDB[id].gather ~= nil then
			for i, id in ipairs(addon.questsDB[id].gather) do
				if objective == nil or objective == c then
					table.insert(ids.item, id)
				end
				c = c + 1
			end
		end
	end
	for _, itemId in ipairs(ids.item) do
		if addon.itemsDB[itemId] ~= nil then
			if addon.itemsDB[itemId].drop ~= nil then
				for _, npcId in ipairs(addon.itemsDB[itemId].drop) do
					table.insert(ids.npc, npcId)
				end
			end
			if addon.itemsDB[itemId].object ~= nil then
				for _, objectId in ipairs(addon.itemsDB[itemId].object) do
					table.insert(ids.object, objectId)
				end
			end
		end
	end
	local positions = {}
	if addon.questsDB[id] ~= nil and addon.questsDB[id].zone ~= nil then filterZone = addon.questsDB[id].zone end
	for _, npcId in ipairs(ids.npc) do
		local element = addon.creaturesDB[npcId]
		if element ~= nil and element.positions ~= nil then
			for i, pos in ipairs(element.positions) do
				-- TODO: x/y are still switched in db
				local x, y, zone
				if filterZone == nil then
					x, y, zone = addon.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid)
				else
					zone = filterZone
					x, y = HBD:GetZoneCoordinatesFromWorld(x, y, addon.mapIDs[filterZone], true)
					if x ~= nil and (x > 1 or x < 0 or y > 1 or y < 0) then x = nil end
				end
				if x ~= nil then
					table.insert(positions, {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = addon.mapIDs[zone], 
						wx = pos.y, wy = pos.x, instance = pos.mapid})
				elseif filterZone == nil then
					error("error transforming (" .. pos.x .. "," .. pos.y .. " " .. pos.mapid .. ") into zone coordinates for quest #" .. id)
				end
			end
		end
	end	
	for _, objectId in ipairs(ids.object) do
		local element = addon.objectsDB[objectId]
		if element ~= nil and element.positions ~= nil then
			for i, pos in ipairs(element.positions) do
				-- TODO: x/y are still switched in db
				local x, y, zone = addon.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid)
				if x ~= nil then
					table.insert(positions, {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = addon.mapIDs[zone], 
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
