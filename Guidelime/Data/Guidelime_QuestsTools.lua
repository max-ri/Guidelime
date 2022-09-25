local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")

local LIMIT_CENTER_POSITION = 400
local LIMIT_POSITIONS = 1000

function addon.GetQuestsCompleted()
	if GetQuestsCompleted ~= nil then return GetQuestsCompleted() end
	local t = {}
	local completedQuests = C_QuestLog.GetAllCompletedQuestIDs()
	if completedQuests then
		for i, id in ipairs(completedQuests) do
			t[id] = true
		end
	end
	return t
end

function addon.GetNumGossipActiveQuests()
	if GetNumGossipActiveQuests ~= nil then return GetNumGossipActiveQuests() end
	return C_GossipInfo.GetNumActiveQuests()
end

function addon.GetGossipActiveQuests()
	if GetGossipActiveQuests ~= nil then return GetGossipActiveQuests() end
	return C_GossipInfo.GetActiveQuests()
end

function addon.SelectGossipActiveQuest(i)
	if SelectGossipActiveQuest ~= nil then return SelectGossipActiveQuest(i) end 
	return C_GossipInfo.SelectActiveQuest(i)
end

function addon.GetNumGossipAvailableQuests()
	if GetNumGossipAvailableQuests ~= nil then return GetNumGossipAvailableQuests() end 
	return C_GossipInfo.GetNumAvailableQuests()
end

function addon.GetGossipAvailableQuests()
	if GetGossipAvailableQuests ~= nil then return GetGossipAvailableQuests() end 
	return C_GossipInfo.GetAvailableQuests()
end

function addon.SelectGossipAvailableQuest(i)
	if SelectGossipAvailableQuest ~= nil then return SelectGossipAvailableQuest(i) end 
	return C_GossipInfo.SelectAvailableQuest(i)
end

function addon.SelectGossipOption(i)
	if SelectGossipOption ~= nil then return SelectGossipOption(i) end 
	return C_GossipInfo.SelectOption(i)
end
	
function addon.resetCachedQuestData()
	addon.questPosition = nil
	addon.questObjectives = nil
end


function addon.isQuestId(id)
	if id == nil then return false end
	if addon.dataSource == "QUESTIE" then return addon.isQuestIdQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.isQuestIdClassicCodex(id) end
	return addon.questsDB[id] ~= nil
end

function addon.getQuestReplacement(id)
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].replacement end
end

function addon.getQuestSort(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestSortQuestie(id) end
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].sort end
end

-- this function intentionally only uses internal database instead of selected data source
-- this is used in parsing guides and guides should not parse with errors or not depending on data source used
function addon.getQuestZone(id)
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].zone end
end

function addon.getQuestPrequests(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestPrequestsQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestPrequestsClassicCodex(id) end
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].prequests end
end

function addon.getQuestOneOfPrequests(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestOneOfPrequestsQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestOneOfPrequestsClassicCodex(id) end
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].oneOfPrequests end
end

function addon.getQuestType(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestTypeQuestie(id) end
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].type end
end

function addon.getQuestLevel(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestLevelQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestLevelClassicCodex(id) end
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].level end
end

function addon.getQuestMinimumLevel(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestMinimumLevelQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestMinimumLevelClassicCodex(id) end
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].req	end
end

function addon.getQuestSeries(id)
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].series end
end

function addon.getQuestNext(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestNextQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestNextClassicCodex(id) end
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].next end
end

function addon.getQuestPrev(id)
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].prev end
end

function addon.getQuestRaces(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestRacesQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestRacesClassicCodex(id) end
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].races end
end

function addon.getQuestClasses(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestClassesQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestClassesClassicCodex(id) end
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].classes end
end

function addon.getQuestFaction(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestFactionQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestFactionClassicCodex(id) end
	if addon.questsDB[id] ~= nil then return addon.questsDB[id].faction end
end

function addon.getNPCPosition(id)
	if addon.dataSource == "QUESTIE" then return addon.getNPCPositionQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getNPCPositionClassicCodex(id) end
	local element = addon.creaturesDB[npcId]
	if element ~= nil and element.positions ~= nil then
		for i, pos in ipairs(element.positions) do
			-- filter all instances
			if pos.mapid == 0 or pos.mapid == 1 then
				-- x/y are switched in db
				local x, y, zone = addon.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid, filterZone)
				if x ~= nil then
					return {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = addon.mapIDs[zone], 
						wx = pos.y, wy = pos.x, instance = pos.mapid,
						objectives = objectives.npc[npcId],
						npcId = npcId
					}
				elseif addon.debugging and filterZone == nil then
					print("LIME: error transforming (", pos.x, pos.y, pos.mapid, ") into zone coordinates for npc #" .. npcId)
				end
			end
		end
	end
end

function addon.getQuestIDs()
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestIDsClassicCodex(id) end
	local ids = {}
	for id, q in pairs(addon.questsDB) do
		table.insert(ids, id)
	end
	return ids
end

function addon.getQuestApplies(id)
	return addon.applies({races = addon.getQuestRaces(id), classes = addon.getQuestClasses(id), faction = addon.getQuestFaction(id)})
end

function addon.getQuestNameById(id)
	if id == nil then return nil end
	if addon.quests ~= nil and addon.quests[id] ~= nil and addon.quests[id].name ~= nil then
		return addon.quests[id].name
	end
	if C_QuestLog.GetQuestInfo(id) ~= nil then return C_QuestLog.GetQuestInfo(id) end
	if addon.dataSource == "QUESTIE" then return addon.getQuestNameQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestNameClassicCodex(id) end
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
	if addon.dataSource == "QUESTIE" then return addon.getQuestObjectiveQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestObjectiveClassicCodex(id) end
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

function addon.getQuestReputation(id)
	if addon.dataSource == "QUESTIE" then return addon.getQuestReputationQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestReputationClassicCodex(id) end
end

-- returns a type (npc/item/object) and a list of names for quest source / each objective / turn in; e.g. {{type="item", names={"Huge Gnoll Claw", "Hogger"}, ids={item={1931},npc={448}} for id = 176, typ = "COMPLETE"
function addon.getQuestObjectives(id, typ)
	if id == nil then return end
	if typ == nil then typ = "COMPLETE" end
	if addon.questObjectives == nil then addon.questObjectives = {} end
	if addon.questObjectives[id] == nil then addon.questObjectives[id] = {} end
	if addon.questObjectives[id][typ] == nil and addon.dataSource == "QUESTIE" then addon.questObjectives[id][typ] = addon.getQuestObjectivesQuestie(id, typ) end
	if addon.questObjectives[id][typ] == nil and addon.dataSource == "CLASSIC_CODEX" then addon.questObjectives[id][typ] = addon.getQuestObjectivesClassicCodex(id, typ) end
	if addon.questObjectives[id][typ] == nil and addon.questsDB[id] ~= nil then
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
	end
	return addon.questObjectives[id][typ]
end

function addon.getQuestPositions(id, typ, objective, filterZone)
	if id == nil then return end
	if objective == 0 then objective = nil end
	if addon.dataSource == "QUESTIE" then return addon.getQuestPositionsQuestie(id, typ, objective, filterZone) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getQuestPositionsClassicCodex(id, typ, objective, filterZone) end
	if addon.getSuperCode(typ) == "QUEST" and addon.questsDB[id] == nil then return end
	--local time
	--if addon.debugging then time = debugprofilestop() end
	local ids = {npc = {}, object = {}, item = {}}
	local objectives = {npc = {}, object = {}, item = {}}
	if typ == "ACCEPT" then 
		if addon.questsDB[id].source ~= nil then
			for i, e in ipairs(addon.questsDB[id].source) do
				if objective == nil or objective == i then
					table.insert(ids[e.type], e.id)
					if objectives[e.type][e.id] == nil then objectives[e.type][e.id] = {} end
					table.insert(objectives[e.type][e.id], i)
				end
			end
		end
	elseif typ == "TURNIN" then
		if addon.questsDB[id].deliver ~= nil then
			for i, e in ipairs(addon.questsDB[id].deliver) do
				if objective == nil or objective == i then
					table.insert(ids[e.type], e.id)
					if objectives[e.type][e.id] == nil then objectives[e.type][e.id] = {} end
					table.insert(objectives[e.type][e.id], i)
				end
			end
		end
	elseif typ == "COMPLETE" then
		local c = 1
		if addon.questsDB[id].kill ~= nil then
			for i, id in ipairs(addon.questsDB[id].kill) do
				if objective == nil or objective == c then
					table.insert(ids.npc, id)
					if objectives.npc[id] == nil then objectives.npc[id] = {} end
					table.insert(objectives.npc[id], c)
				end
				c = c + 1
			end
		end
		if addon.questsDB[id].interact ~= nil then
			for i, id in ipairs(addon.questsDB[id].interact) do
				if objective == nil or objective == c then
					table.insert(ids.object, id)
					if objectives.object[id] == nil then objectives.object[id] = {} end
					table.insert(objectives.object[id], c)
				end
				c = c + 1
			end
		end
		if addon.questsDB[id].gather ~= nil then
			for i, id in ipairs(addon.questsDB[id].gather) do
				if objective == nil or objective == c then
					table.insert(ids.item, id)
					if objectives.item[id] == nil then objectives.item[id] = {} end
					table.insert(objectives.item[id], c)
				end
				c = c + 1
			end
		end
	elseif typ == "COLLECT_ITEM" then
		table.insert(ids.item, id)
	end
	for _, itemId in ipairs(ids.item) do
		if addon.itemsDB[itemId] ~= nil then
			if addon.itemsDB[itemId].drop ~= nil then
				for _, npcId in ipairs(addon.itemsDB[itemId].drop) do
					table.insert(ids.npc, npcId)
					if objectives.item[itemId] ~= nil then
						if objectives.npc[npcId] == nil then objectives.npc[npcId] = {} end
						for _, c in ipairs(objectives.item[itemId]) do
							table.insert(objectives.npc[npcId], c)
						end
					end
				end
			end
			if addon.itemsDB[itemId].object ~= nil then
				for _, objectId in ipairs(addon.itemsDB[itemId].object) do
					table.insert(ids.object, objectId)
					if objectives.object[objectId] == nil then objectives.object[objectId] = {} end
					if objectives.item[itemId] ~= nil then
						for _, c in ipairs(objectives.item[itemId]) do
							table.insert(objectives.object[objectId], c)
						end
					end
				end
			end
		end
	end
	local positions = {}
	local count = 0
	for _, npcId in ipairs(ids.npc) do
		local element = addon.creaturesDB[npcId]
		if element ~= nil and element.positions ~= nil then
			for i, pos in ipairs(element.positions) do
				-- filter all instances
				if pos.mapid == 0 or pos.mapid == 1 then
					-- TODO: x/y are still switched in db
					local x, y, zone = addon.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid, filterZone)
					if x ~= nil then
						if count >= LIMIT_POSITIONS then return end
						count = count + 1
						positions[count] = {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = addon.mapIDs[zone], 
							wx = pos.y, wy = pos.x, instance = pos.mapid,
							objectives = objectives.npc[npcId],
							npcId = npcId
						}
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
						if count >= LIMIT_POSITIONS then return end
						count = count + 1
						positions[count] = {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = addon.mapIDs[zone], 
							wx = pos.y, wy = pos.x, instance = pos.mapid,
							objectives = objectives.object[objectId],
							objectId = objectId}
					elseif addon.debugging and filterZone == nil then 
						print("LIME: error transforming (" .. pos.x .. "," .. pos.y .. "," .. pos.mapid .. ") into zone coordinates for quest #" .. id .. " object #" .. objectId)
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

	--caching of empty results disabled 
	--addon.questPosition[id][typ][index] = false
	local clusters = {}
	local maxCluster	
	local filterZone = addon.getQuestSort(id)
	if filterZone ~= nil and addon.mapIDs[filterZone] == nil then filterZone = nil end
	local positions = addon.getQuestPositions(id, typ, index, filterZone)
	if positions ~= nil and #positions == 0 and filterZone ~= nil then
		positions = addon.getQuestPositions(id, typ, index)
	end
	if positions == nil or #positions > LIMIT_CENTER_POSITION then return end
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
			print("LIME: error transforming (" .. maxCluster.x .. "," .. maxCluster.y .. "," .. maxCluster.instance .. ") into zone coordinates for quest #" .. id)
		end
	end
end

function addon.getQuestPositionsLimited(id, typ, index, maxNumber, onlyWorld)
	local clusters = {}
	local filterZone = addon.getSuperCode(typ) == "QUEST" and addon.getQuestZone(id)
	local positions = addon.getQuestPositions(id, typ, index, filterZone)
	if positions == nil then return end
	if #positions == 0 and filterZone ~= nil then
		positions = addon.getQuestPositions(id, typ, index)
		if positions == nil then return end
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
		if addon.debugging then print("LIME: limited " .. #positions .. " positions to " .. #positions2 .. " positions. x = " .. x .. " y = " .. y) end
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
			print("LIME: error transforming (" .. maxCluster.x .. "," .. maxCluster.y .. "," .. maxCluster.instance .. ") into zone coordinates for quest #" .. id)
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
		for _, id in ipairs(addon.getQuestIDs()) do
			if addon.getQuestReplacement(id) == nil then
				local n = addon.getQuestNameById(id):lower():gsub("[%(%)\"%s%p]","")
				if addon.questsDBReverse[n] == nil then addon.questsDBReverse[n] = {} end
				table.insert(addon.questsDBReverse[n], id)
				-- if localized quest name is different from english name also include english name
				--[[
				if addon.getQuestNameById(id) ~= addon.questsDB[id].name then
					n = addon.questsDB[id].name:lower():gsub("[%(%)\"%s%p]",""):gsub("  ", " ")
					if addon.questsDBReverse[n] == nil then addon.questsDBReverse[n] = {} end
					table.insert(addon.questsDBReverse[n], id)
				end]]
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
				if addon.getQuestSeries(id) == part then
					table.insert(filteredIds, id)		
				end
			end
			if #filteredIds > 0 then ids = filteredIds end
		end
	end
	if faction ~= nil or race ~= nil or class ~= nil then
		local filteredIds = {}
		for i, id in ipairs(ids) do
			local match = faction == nil or addon.getQuestFaction(id) == nil or faction == addon.getQuestFaction(id)
			if match and race ~= nil and addon.getQuestRaces(id) ~= nil then
				match = false
				for i, r in ipairs(race) do
					if addon.contains(addon.getQuestRaces(id), r) then match = true; break end
				end
			end	
			if match and class ~= nil and addon.getQuestClasses(id) ~= nil then
				match = false
				for i, c in ipairs(class) do
					if addon.contains(addon.getQuestClasses(id), c) then match = true; break end
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

function addon.getMissingPrequests(id, isCompleteFunc)
	local missingPrequests = {}
	if addon.getQuestPrequests(id) ~= nil then
		for _, pid in ipairs(addon.getQuestPrequests(id)) do
			if addon.getQuestApplies(pid) then
				if not isCompleteFunc(pid) then
					table.insert(missingPrequests, pid)
				elseif addon.getQuestOneOfPrequests(id) then
					return {}
				end
			end
		end
	end
	return missingPrequests
end

function addon.getNPCPosition(id)
	if id == nil then return end
	if addon.dataSource == "QUESTIE" then return addon.getNPCPositionQuestie(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return addon.getNPCPositionClassicCodex(id) end
	if addon.creaturesDB[id] == nil or addon.creaturesDB[id].positions == nil then return end
	local p = addon.creaturesDB[id].positions[1]
	local x, y, z = addon.GetZoneCoordinatesFromWorld(p.y, p.x, p.mapid)
	return {instance = p.mapid, wx = p.y, wy = p.x, mapID = addon.mapIDs[z], x = x, y = y}
end


function addon.getNPCName(id)
	if id == nil then return end
	if addon.npcNames == nil then addon.npcNames = {} end
	if addon.npcNames[id] ~= nil then return addon.npcNames[id] end
	if addon.dataSource == "QUESTIE" then addon.npcNames[id] = addon.getNPCNameQuestie(id); return addon.npcNames[id] end
	if addon["creaturesDB_" .. GetLocale()] ~= nil and addon["creaturesDB_" .. GetLocale()][id] ~= nil then
		addon.npcNames[id] = addon["creaturesDB_" .. GetLocale()][npcId]
	elseif addon.creaturesDB[id] ~= nil then
		addon.npcNames[id] = addon.creaturesDB[id].name
	end
	return addon.npcNames[id]
end

function addon.getObjectName(id)
	if id == nil then return end
	if addon.objectNames == nil then addon.objectNames = {} end
	if addon.objectNames[id] ~= nil then return addon.objectNames[id] end
	if addon.dataSource == "QUESTIE" then addon.objectNames[id] = addon.getObjectNameQuestie(id); return addon.objectNames[id] end
	if addon["objectsDB_" .. GetLocale()] ~= nil and addon["objectsDB_" .. GetLocale()][id] ~= nil then
		addon.objectNames[id] = addon["objectsDB_" .. GetLocale()][id]
	elseif addon.objectsDB[id] ~= nil then
		addon.objectNames[id] = addon.objectsDB[id].name
	end
	return addon.objectNames[id]
end

function addon.getItemStartingQuest(id)
	local objectives = addon.getQuestObjectives(id, "ACCEPT")
	if objectives then
		for _, o in ipairs(objectives) do
			if o.type == "item" then
				return o.ids.item[1]
			end
		end
	end
end	

function addon.getItemProvidedByQuest(id)
	if id == nil then return end
	if addon.dataSource == "QUESTIE" then return addon.getItemProvidedByQuestQuestie(id) end
end

function addon.isItemUsable(id)
	if id == nil then return end
	local _,_,enable = GetItemCooldown(id)
	if enable == 1 then return true end
	if addon.dataSource == "QUESTIE" then return addon.isItemUsableQuestie(id) end
	return false
end

function addon.getUsableQuestItems(id)
	if id == nil then return end
	if addon.dataSource == "QUESTIE" then return addon.getUsableQuestItemsQuestie(id) end
end

addon.questItemIsFor = {
	[6145] = false,
	[34688] = false,
	[34908] = false,
	[34968] = false,
	[36726] = false,
	[35746] = false,
	[36760] = false,
	[40652] = false,
	[40641] = false,
	[41615] = false,
	[42422] = false,
	[42839] = false,
	[42918] = false,
	[18597] = "TURNIN",
	[28455] = "TURNIN",
	[34971] = "TURNIN",
	[35797] = "TURNIN",
	[40971] = "TURNIN",
}
setmetatable(addon.questItemIsFor, {__index = function() return "COMPLETE" end})
