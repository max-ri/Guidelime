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
	elseif addon["questsDB_" .. locale] ~= nil and addon["questsDB_" .. locale][id] ~= nil and addon["questsDB_" .. locale][id].name ~= nil then
		return addon["questsDB_" .. locale][id].name
	elseif locale == "zhTW" and addon.questsDB_zhCN ~= nil and addon.questsDB_zhCN[id] ~= nil and addon.questsDB_zhCN[id].name ~= nil then
		return addon.questsDB_zhCN[id].name
	else
		return addon.questsDB[id].name
	end
end

function addon.getQuestObjective(id)
	local locale = GetLocale()
	if id == nil or addon.questsDB[id] == nil then
		return
	elseif addon["questsDB_" .. locale] ~= nil and addon["questsDB_" .. locale][id] ~= nil and addon["questsDB_" .. locale][id].objective ~= nil then
		return addon["questsDB_" .. locale][id].objective
	elseif locale == "zhTW" and addon.questsDB_zhCN ~= nil and addon.questsDB_zhCN[id] ~= nil and addon.questsDB_zhCN[id].objective ~= nil then
		return addon.questsDB_zhCN[id].objective
	else
		return addon.questsDB[id].objective
	end
end

function addon.getQuestRaces(id)
	if GuidelimeData.dataSourceQuestie and QuestieDB ~= nil then return addon.getQuestRacesQuestie(id) end
	if id == nil or addon.questsDB[id] == nil then return end
	return addon.questsDB[id].races
end

function addon.getQuestClasses(id)
	if GuidelimeData.dataSourceQuestie and QuestieDB ~= nil then return addon.getQuestClassesQuestie(id) end
	if id == nil or addon.questsDB[id] == nil then return end
	return addon.questsDB[id].classes
end

function addon.getQuestFaction(id)
	if GuidelimeData.dataSourceQuestie and QuestieDB ~= nil then return addon.getQuestFactionQuestie(id) end
	if id == nil or addon.questsDB[id] == nil then return end
	return addon.questsDB[id].faction
end

-- returns a type (npc/item/object) and a list of names for quest source / each objective / turn in; e.g. {{type="item", names={"Dealt with The Hogger Situation", "Huge Gnoll Claw", "Hogger"}} for id = 176, typ = "COMPLETE"
function addon.getQuestObjectives(id, typ)
	if id == nil then return end
	if typ == nil then typ = "COMPLETE" end
	if addon.questObjectives == nil then addon.questObjectives = {} end
	if addon.questObjectives[id] == nil then addon.questObjectives[id] = {} end
	if addon.questObjectives[id][typ] ~= nil then return addon.questObjectives[id][typ] end
	if GuidelimeData.dataSourceQuestie and QuestieDB ~= nil then 
		addon.questObjectives[id][typ] = addon.getQuestObjectivesQuestie(id, typ) 
		return addon.questObjectives[id][typ]
	end
	if addon.questsDB[id] == nil then return end
	local locale = GetLocale()
	local ids = {}
	local objectives = {}
	if typ == "ACCEPT" then 
		if addon.questsDB[id].source ~= nil then
			for i, e in ipairs(addon.questsDB[id].source) do
				objectives[i] = {type = e.type, ids = {[e.type] = {e.id}}}
			end
		end
	elseif typ == "TURNIN" then
		if addon.questsDB[id].deliver ~= nil then
			for i, e in ipairs(addon.questsDB[id].deliver) do
				objectives[i] = {type = e.type, ids = {[e.type] = {e.id}}}
			end
		end
	elseif typ == "COMPLETE" then
		local c = 1
		if addon.questsDB[id].kill ~= nil then
			for i, id in ipairs(addon.questsDB[id].kill) do
				objectives[c] = {type = "monster", ids = {npc = {id}}}
				c = c + 1
			end
		end
		if addon.questsDB[id].interact ~= nil then
			for i, id in ipairs(addon.questsDB[id].interact) do
				objectives[c] = {type = "object", ids = {object = {id}}}
				ids[c] = {object = {id}}
				c = c + 1
			end
		end
		if addon.questsDB[id].gather ~= nil then
			for i, id in ipairs(addon.questsDB[id].gather) do
				objectives[c] = {type = "item", ids = {item = {id}}}
				c = c + 1
			end
		end
	end
	for i, objective in ipairs(objectives) do
		objective.names = {}
		if objective.ids.item ~= nil then
			for _, itemId in ipairs(objective.ids.item) do
				if addon["itemsDB_" .. locale] ~= nil and addon["itemsDB_" .. locale][itemId] ~= nil then
					table.insert(objective.names, addon["itemsDB_" .. locale][itemId])
				end
				local item = addon.itemsDB[itemId]
				if item ~= nil then
					if not addon.contains(objective.names, item.name) then table.insert(objective.names, item.name) end
					if item.drop ~= nil then
						for _, npcId in ipairs(item.drop) do
							if objective.ids.npc == nil then objective.ids.npc = {} end
							table.insert(objective.ids.npc, npcId)
						end
					end
					if item.object ~= nil then
						for _, objectId in ipairs(item.object) do
							if objective.ids.object == nil then objective.ids.object = {} end
							table.insert(objective.ids.object, objectId)
						end
					end
				end
			end
		end
		if objective.ids.npc ~= nil then
			for _, npcId in ipairs(objective.ids.npc) do
				if addon["creaturesDB_" .. locale] ~= nil and addon["creaturesDB_" .. locale][npcId] ~= nil then
					if not addon.contains(objective.names, addon["creaturesDB_" .. locale][npcId]) then table.insert(objective.names, addon["creaturesDB_" .. locale][npcId]) end
				end
				local creature = addon.creaturesDB[npcId]
				if creature ~= nil then
					if not addon.contains(objective.names, creature.name) then table.insert(objective.names, creature.name) end
				end
			end
		end
		if objective.ids.object ~= nil then
			for _, objectId in ipairs(objective.ids.object) do
				if addon["objectsDB_" .. locale] ~= nil and addon["objectsDB_" .. locale][objectId] ~= nil then
					if not addon.contains(objective.names, addon["objectsDB_" .. locale][objectId]) then table.insert(objective.names, addon["objectsDB_" .. locale][objectId]) end
				end
				local object = addon.objectsDB[objectId]
				if object ~= nil then
					if not addon.contains(objective.names, object.name) then table.insert(objective.names, object.name) end
				end
			end
		end
	end	
	addon.questObjectives[id][typ] = objectives
	return objectives
end

function addon.getQuestPositions(id, typ, objective, filterZone)
	if id == nil then return end
	if objective == 0 then objective = nil end
	if GuidelimeData.dataSourceQuestie and QuestieDB ~= nil then return addon.getQuestPositionsQuestie(id, typ, objective, filterZone) end
	if addon.questsDB[id] == nil then return end
	--local time
	--if addon.debugging then time = debugprofilestop() end
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
	for _, npcId in ipairs(ids.npc) do
		local element = addon.creaturesDB[npcId]
		if element ~= nil and element.positions ~= nil then
			for i, pos in ipairs(element.positions) do
				-- filter all instances
				if pos.mapid == 0 or pos.mapid == 1 then
					-- TODO: x/y are still switched in db
					local x, y, zone = addon.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid, filterZone)
					if x ~= nil then
						table.insert(positions, {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = addon.mapIDs[zone], 
							wx = pos.y, wy = pos.x, instance = pos.mapid})
					elseif addon.debugging and filterZone == nil then
						print("LIME: error transforming (", pos.x, pos.y, pos.mapid, ") into zone coordinates for quest #" .. id .. " npc #" .. npcId)
					end
				end
			end
		end
	end	
	for _, objectId in ipairs(ids.object) do
		local element = addon.objectsDB[objectId]
		if element ~= nil and element.positions ~= nil then
			for i, pos in ipairs(element.positions) do
				-- filter all instances
				if pos.mapid == 0 or pos.mapid == 1 then
					-- TODO: x/y are still switched in db
					local x, y, zone = addon.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid, filterZone)
					if x ~= nil then
						table.insert(positions, {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = addon.mapIDs[zone], 
							wx = pos.y, wy = pos.x, instance = pos.mapid})
					elseif addon.debugging and filterZone == nil then 
						print("error transforming (" .. pos.x .. "," .. pos.y .. "," .. pos.mapid .. ") into zone coordinates for quest #" .. id .. " object #" .. objectId)
					end
				end
			end
		end
	end	
	--if addon.debugging then print("LIME: getQuestPositions " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
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
				bestDist = dist
			end
		end
	else
		clusters[instance] = {}
	end
	if bestCluster == nil then
		bestCluster = {x = 0, y = 0, count = 0, radius = 0, instance = instance}
		bestDist = 0
		table.insert(clusters[instance], bestCluster)
	end
	return bestCluster, bestDist
end

local function addToCluster(x, y, cluster, dist)
	cluster.x = (cluster.x * cluster.count + x) / (cluster.count + 1)
	cluster.y = (cluster.y * cluster.count + y) / (cluster.count + 1)
	-- this is an approximation only
	if dist ~= nil and cluster.radius < dist then cluster.radius = dist end	
	cluster.count = cluster.count + 1
	--if addon.debugging then print("LIME: adding to cluster ", cluster.count, cluster.x, cluster.y) end
end

-- approximation in order to find a position equally far away from previous clusters
local function selectFurthestPosition(positions, clusters)
	local maxPos, maxDist
	for _, pos in ipairs(positions) do
		if not pos.selected then
			if clusters[pos.instance] == nil then return pos end
			local dist = 0
			for _, cluster in ipairs(clusters[pos.instance]) do
				if cluster.x == pos.wx and cluster.y == pos.wy then
					dist = nil
				elseif dist ~= nil then
					dist = dist + 1 / ((cluster.x - pos.wx) * (cluster.x - pos.wx) + (cluster.y - pos.wy) * (cluster.y - pos.wy)) 
				end
			end
			if maxDist == nil or (dist ~= nil and dist < maxDist) then
				maxPos, maxDist = pos, dist
			end
		end
	end
	--if addon.debugging then print("LIME: furthest point is #", maxPos.x, maxPos.y, maxPos.mapid, maxDist) end
	return maxPos
end

function addon.getQuestPosition(id, typ, index)
	if index == nil then index = 0 end
	if addon.questPosition == nil then addon.questPosition = {} end
	if addon.questPosition[id] == nil then addon.questPosition[id] = {} end
	if addon.questPosition[id][typ] == nil then addon.questPosition[id][typ] = {} end
	if addon.questPosition[id][typ][index] ~= nil then 
		if addon.questPosition[id][typ][index] == false then return end
		return addon.questPosition[id][typ][index] 
	end

	addon.questPosition[id][typ][index] = false
	local clusters = {}
	local maxCluster	
	local filterZone
	if addon.questsDB[id] ~= nil and addon.questsDB[id].zone ~= nil then filterZone = addon.questsDB[id].zone end
	local positions = addon.getQuestPositions(id, typ, index, filterZone)
	if positions == nil then return end
	if #positions == 0 and filterZone ~= nil then
		positions = addon.getQuestPositions(id, typ, index)
	end
	if #positions > 400 then return end
	--local time
	--if addon.debugging then time = debugprofilestop() end
	for i = 1, #positions do 
		local pos = selectFurthestPosition(positions, clusters)
		--if addon.debugging then print("LIME: found position", pos.wx, pos.wy, pos.instance) end
		pos.selected = true
		local cluster, dist = findCluster(clusters, pos.wx, pos.wy, pos.instance)
		addToCluster(pos.wx, pos.wy, cluster, dist)
		if maxCluster == nil or cluster.count > maxCluster.count then maxCluster = cluster end
	end
	--if addon.debugging then print("LIME: findCluster " .. #positions .. " positions " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	if maxCluster ~= nil then
		if addon.debugging and maxCluster.count > 1 then print("LIME: biggest cluster of", maxCluster.count, "at", maxCluster.x, maxCluster.y, maxCluster.instance) end
		local x, y, zone = addon.GetZoneCoordinatesFromWorld(maxCluster.x, maxCluster.y, maxCluster.instance)
		if x ~= nil then
			--if addon.debugging then print("LIME: getQuestPosition " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
			addon.questPosition[id][typ][index] = {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, 
				wx = maxCluster.x, wy = maxCluster.y, instance = maxCluster.instance,
				zone = zone, mapID = addon.mapIDs[zone], radius = math.floor(math.sqrt(maxCluster.radius)), estimate = #positions > 1}
			return addon.questPosition[id][typ][index]
		elseif addon.debugging then
			print("error transforming (" .. maxCluster.x .. "," .. maxCluster.y .. "," .. maxCluster.instance .. ") into zone coordinates for quest #" .. id)
		end
	end
end

function addon.getQuestPositionsLimited(id, typ, index, maxNumber, onlyWorld)
	local clusters = {}
	local filterZone
	if addon.questsDB[id] ~= nil and addon.questsDB[id].zone ~= nil then filterZone = addon.questsDB[id].zone end
	local positions = addon.getQuestPositions(id, typ, index, filterZone)
	if positions == nil then return end
	if #positions == 0 and filterZone ~= nil then
		positions = addon.getQuestPositions(id, typ, index)
	end
	if maxNumber > 0 and #positions > maxNumber then
		local positions2 = {}
		local y, x, z, instance = UnitPosition("player")
		-- fill part with the nearest positions
		local closestCount = math.ceil(maxNumber / 5)
		local minDist = {}
		for _, pos in ipairs(positions) do
			if pos.instance == instance then
				local dist = (pos.wx - x) * (pos.wx - x) + (pos.wy - y) * (pos.wy - y)
				for i = 1, closestCount do
					if minDist[i] == nil or minDist[i] > dist then
						table.insert(minDist, i, dist)
						table.insert(positions2, i, pos)
						break
					end
				end
			end
		end
		for i = closestCount + 1, #positions2 do
			positions2[i] = nil
		end
		-- fill up with positions spread out
		for i = #positions2 + 1, maxNumber do 
			local pos = selectFurthestPosition(positions, clusters)
			pos.selected = true
			if clusters[pos.instance] == nil then clusters[pos.instance] = {} end
			table.insert(clusters[pos.instance], {x = pos.wx, y = pos.wy, count = 1, instance = pos.instance})
			table.insert(positions2, pos)
		end
		positions = positions2
	end
	if onlyWorld then return positions end
	local result = {}
	for _, pos in ipairs(positions) do
		local x, y, zone = addon.GetZoneCoordinatesFromWorld(pos.wx, pos.wy, pos.instance)
		if x ~= nil then
			pos.x = math.floor(x * 10000) / 100
			pos.y = math.floor(y * 10000) / 100
			pos.zone = zone
			pos.mapID = addon.mapIDs[zone]
			table.insert(result, pos)
		elseif addon.debugging then
			print("error transforming (" .. maxCluster.x .. "," .. maxCluster.y .. "," .. maxCluster.instance .. ") into zone coordinates for quest #" .. id)
		end
	end
	return result
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
			local pos = startPos
			repeat
				local s2, e2 = lower:find(word, pos)
				if s2 ~= nil and s2 < endPos and (s == nil or (first and s > s2) or (not first and s < s2) or (s == s2 and #word > #w)) then
					s = s2
					e = e2
					w = word
					result = r
				end
				if s2 ~= nil then pos = e2 end
			until s2 == nil
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

function addon.GetZoneCoordinatesFromWorld(worldX, worldY, instance, zone)
	if zone ~= nil then
		local x, y = HBD:GetZoneCoordinatesFromWorld(worldX, worldY, addon.mapIDs[zone], true)
		if x ~= nil and x > 0 and x < 1 and y ~= nil and y > 0 and y < 1 then
			local _, _, checkInstance = HBD:GetWorldCoordinatesFromZone(x, y, addon.mapIDs[zone])
			if checkInstance == instance then
				-- hack for some bfa zone names
				do
					local e = zone:find("[@!]")
					if e ~= nil then zone = zone:sub(1, e - 1) end
				end
				return x, y, zone
			end
		end
	else
		for zone, _ in pairs(addon.mapIDs) do
			local x, y, z = addon.GetZoneCoordinatesFromWorld(worldX, worldY, instance, zone)
			if x ~= nil then return x, y, z end
		end
	end
end
