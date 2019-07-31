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
	if quest == nil then return end
	local names = {}
	for _, element in ipairs(quest) do
		table.insert(names, element.name)
	end
	return names
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
	if quest == nil then return end
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

function addon.getPossibleQuestIdsByName(name, faction, race, class)
	if addon.questsDBReverse == nil then
		addon.questsDBReverse = {}
		for id, quest in pairs(addon.questsDB) do
			local n = addon.getQuestNameById(id):upper()
			if addon.questsDBReverse[n] == nil then addon.questsDBReverse[n] = {} end
			table.insert(addon.questsDBReverse[n], id)
			if quest.series ~= nil then
				local n2 = n .. " " .. L.PART:upper() .. " " .. quest.series
				if addon.questsDBReverse[n2] == nil then addon.questsDBReverse[n2] = {} end
				table.insert(addon.questsDBReverse[n2], id)
			end
			if n:upper() ~= addon.questsDB[id].name:upper() then
				n = addon.questsDB[id].name:upper()
				if addon.questsDBReverse[n] == nil then addon.questsDBReverse[n] = {} end
				table.insert(addon.questsDBReverse[n], id)
				if quest.series ~= nil then
					local n2 = n .. " PART " .. quest.series
					if addon.questsDBReverse[n2] == nil then addon.questsDBReverse[n2] = {} end
					table.insert(addon.questsDBReverse[n2], id)
				end
			end
		end
	end
	local filteredName = name:gsub("%(",""):gsub("%)",""):gsub("pt%.","part"):upper()
	local ids = addon.questsDBReverse[filteredName]
	if ids == nil and filteredName:sub(#filteredName - 5, #filteredName - 1) == "PART " then 
		ids = addon.getPossibleQuestIdsByName(filteredName:sub(1, #filteredName - 7))
		-- looking for part 2 without specifying so and only getting 1 quest? not good return nil
		if tonumber(filteredName:sub(#filteredName - 1, #filteredName)) > 1 and ids ~= nil and #ids == 1 then ids = nil end
	end
	if ids ~= nil and (faction ~= nil or race ~= nil or class ~= nil) then
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
		return filteredIds
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
