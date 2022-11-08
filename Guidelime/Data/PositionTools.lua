local addonName, addon = ...
local L = addon.L

local HBD = LibStub("HereBeDragons-2.0")

addon.DM = addon.DM or {}; local DM = addon.DM                                             -- Data/MapDB
addon.QT = addon.QT or {}; local QT = addon.QT                                             -- Data/QuestTools
addon.CG = addon.CG or {}; local CG = addon.CG                                             -- CurrentGuide
addon.GP = addon.GP or {}; local GP = addon.GP                                             -- GuideParser

addon.PT = addon.PT or {}; local PT = addon.PT                                             -- Data/PositionTools

local LIMIT_CENTER_POSITION = 400
local LIMIT_POSITIONS = 1000

local CLUSTER_DIST = 170

local function findCluster(clusters, wx, wy, instance)
	local bestCluster, bestDist
	if clusters[instance] ~= nil then
		for i, cluster in ipairs(clusters[instance]) do
			local dist = (wx - cluster.wx) * (wx - cluster.wx) + (wy - cluster.wy) * (wy - cluster.wy)
			if dist < CLUSTER_DIST * CLUSTER_DIST and (bestDist == nil or bestDist > dist) then
				bestCluster = cluster
				bestDist = dist
			end
		end
	else
		clusters[instance] = {}
	end
	if bestCluster == nil then
		bestCluster = {wx = 0, wy = 0, count = 0, radius = 0, instance = instance}
		bestDist = 0
		table.insert(clusters[instance], bestCluster)
	end
	return bestCluster, bestDist
end

local function addToCluster(wx, wy, cluster, dist)
	cluster.wx = (cluster.wx * cluster.count + wx) / (cluster.count + 1)
	cluster.wy = (cluster.wy * cluster.count + wy) / (cluster.count + 1)
	-- this is an approximation only
	if dist ~= nil and cluster.radius < dist then cluster.radius = dist end	
	cluster.count = cluster.count + 1
	--if addon.debugging then print("LIME: adding to cluster ", cluster.count, cluster.wx, cluster.wy) end
end

-- approximation in order to find a position equally far away from previous clusters
local function selectFurthestPosition(positions, clusters)
	local maxPos, maxDist
	for _, pos in ipairs(positions) do
		if pos.wx and not pos.selected then
			if clusters[pos.instance] == nil then return pos end
			local dist = 0
			for _, cluster in ipairs(clusters[pos.instance]) do
				if cluster.wx == pos.wx and cluster.wy == pos.wy then
					dist = nil
				elseif dist ~= nil then
					dist = dist + 1 / ((cluster.wx - pos.wx) * (cluster.wx - pos.wx) + (cluster.wy - pos.wy) * (cluster.wy - pos.wy)) 
				end
			end
			if maxDist == nil or (dist ~= nil and dist < maxDist) then
				maxPos, maxDist = pos, dist
			end
		end
	end
	--if addon.debugging then print("LIME: furthest point is #", maxPos.wx, maxPos.wy, maxPos.mapid, maxDist) end
	return maxPos
end

local function convertClusterCoordinates(clusters)
	for instance, list in pairs(clusters) do
		for i = 1, #list do
			local cluster = list[i]
			cluster.x, cluster.y, cluster.zone = PT.GetZoneCoordinatesFromWorld(cluster.wx, cluster.wy, cluster.instance)
			if not cluster.x then
				if addon.debugging then print("LIME: error transforming (" .. cluster.wx .. "," .. cluster.wy .. "," .. cluster.instance .. ") into zone coordinates") end
				table.remove(list, i)
			end
		end
	end
end

local function selectBestCluster(clusters, currentPos)
	local maxCluster
	local count = 0
	for instance, list in pairs(clusters) do
		count = count + #list
		for _, cluster in ipairs(list) do
			if currentPos and currentPos.instance == cluster.instance then
				-- if current position is given weight cluster according to their distance: 
				-- weight of cluster in 1000yd is its count; weight of cluster in 500yd is twice its count
				cluster.distance = math.sqrt((currentPos.wx - cluster.wx) * (currentPos.wx - cluster.wx) + (currentPos.wy - cluster.wy) * (currentPos.wy - cluster.wy))
				if cluster.distance < 1 then cluster.distance = 1 end
				cluster.weight = cluster.count * 1000 / cluster.distance 
				if maxCluster == nil or maxCluster.instance ~= currentPos.instance or cluster.weight > maxCluster.weight then maxCluster = cluster end
			else
				if maxCluster == nil or (not currentPos and cluster.count > maxCluster.count) then maxCluster = cluster end
			end
		end
	end
	if addon.debugging and count > 1 then print("LIME: biggest cluster out of", count, "count", maxCluster.count, "at", maxCluster.wx, maxCluster.wy, maxCluster.instance) end
	if addon.debugging and count > 1 and currentPos then print("LIME: distance", maxCluster.distance, "from", currentPos.wx, currentPos.wy, "weight", maxCluster.weight) end
	return maxCluster
end

local function calculateClusters(positions)
	local clusters = {}
	--local time
	--if addon.debugging then time = debugprofilestop() end
	for i = 1, #positions do 
		local pos = selectFurthestPosition(positions, clusters)
		--if addon.debugging then print("LIME: found position", pos.wx, pos.wy, pos.instance) end
		pos.selected = true
		local cluster, dist = findCluster(clusters, pos.wx, pos.wy, pos.instance)
		addToCluster(pos.wx, pos.wy, cluster, dist)
	end
	convertClusterCoordinates(clusters)
	return clusters
end

function PT.getQuestPosition(id, typ, index, currentPos)
	if index == nil then index = 0 end
	if type(index) == "number" then index = {index} end
	if PT.questPosition == nil then PT.questPosition = {} end
	if PT.questPosition[id] == nil then PT.questPosition[id] = {} end
	if PT.questPosition[id][typ] == nil then PT.questPosition[id][typ] = {} end
	local pos = PT.questPosition[id][typ][table.concat(index,",")]
	if pos and not pos.estimate then return pos end
	local clusters = pos and pos.clusters
	local estimate = true
	if not clusters then 
		local filterZone = QT.getQuestSort(id)
		if filterZone ~= nil and DM.mapIDs[filterZone] == nil then filterZone = nil end
		local positions = QT.getQuestPositions(id, typ, index, filterZone)
		if positions ~= nil and #positions == 0 and filterZone ~= nil then
			positions = QT.getQuestPositions(id, typ, index)
		end
		if positions == nil or #positions > LIMIT_CENTER_POSITION then return end
		clusters = calculateClusters(positions)
		estimate = #positions > 1
	end
	local maxCluster = selectBestCluster(clusters, currentPos)
	--if addon.debugging then print("LIME: findCluster " .. #positions .. " positions " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	if maxCluster ~= nil then
		--if addon.debugging then print("LIME: getQuestPosition " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
		pos = {x = math.floor(maxCluster.x * 10000) / 100, y = math.floor(maxCluster.y * 10000) / 100, 
			wx = maxCluster.wx, wy = maxCluster.wy, instance = maxCluster.instance,
			zone = maxCluster.zone, mapID = DM.mapIDs[maxCluster.zone],
			radius = math.floor(math.sqrt(maxCluster.radius)) + CG.DEFAULT_GOTO_RADIUS, estimate = estimate,
			clusters = clusters}
		PT.questPosition[id][typ][table.concat(index,",")] = pos 
		return pos
	end
end

function PT.getQuestPositionsLimited(id, typ, index, maxNumber, onlyWorld)
	local clusters = {}
	local filterZone = GP.getSuperCode(typ) == "QUEST" and QT.getQuestZone(id)
	local positions = QT.getQuestPositions(id, typ, index, filterZone)
	if positions == nil then return end
	if #positions == 0 and filterZone ~= nil then
		positions = QT.getQuestPositions(id, typ, index)
		if positions == nil then return end
	end
	return PT.getPositionsLimited(positions, maxNumber, onlyWorld)
end	

function PT.getPositionsLimited(positions, maxNumber, onlyWorld)
	local clusters = {}
	if maxNumber > 0 and #positions > maxNumber then
		local positions2 = {}
		local wy, wx, _, instance = UnitPosition("player")
		-- fill part with the nearest positions
		local closestCount = math.ceil(maxNumber / 5)
		local minDist = {}
		for _, pos in ipairs(positions) do
			if pos.instance == instance then
				local dist = (pos.wx - wx) * (pos.wx - wx) + (pos.wy - wy) * (pos.wy - wy)
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
			table.insert(clusters[pos.instance], {wx = pos.wx, wy = pos.wy, count = 1, instance = pos.instance})
			table.insert(positions2, pos)
		end
		if addon.debugging then print("LIME: limited " .. #positions .. " positions to " .. #positions2 .. " positions. x = " .. wx .. " y = " .. wy) end
		positions = positions2
	end
	if onlyWorld then return positions end
	local result = {}
	for _, pos in ipairs(positions) do
		local x, y, zone = PT.GetZoneCoordinatesFromWorld(pos.wx, pos.wy, pos.instance)
		if x ~= nil then
			pos.x = math.floor(x * 10000) / 100
			pos.y = math.floor(y * 10000) / 100
			pos.zone = zone
			pos.mapID = DM.mapIDs[zone]
			table.insert(result, pos)
		elseif addon.debugging then
			print("LIME: error transforming (" .. maxCluster.wx .. "," .. maxCluster.wy .. "," .. maxCluster.instance .. ") into zone coordinates")
		end
	end
	return result
end

function PT.GetZoneCoordinatesFromWorld(worldX, worldY, instance, zone)
	if zone ~= nil then
		local x, y = HBD:GetZoneCoordinatesFromWorld(worldX, worldY, DM.mapIDs[zone], true)
		if x ~= nil and x > 0 and x < 1 and y ~= nil and y > 0 and y < 1 then
			local _, _, checkInstance = HBD:GetWorldCoordinatesFromZone(x, y, DM.mapIDs[zone])
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
		for zone, _ in pairs(DM.mapIDs) do
			local x, y, z = PT.GetZoneCoordinatesFromWorld(worldX, worldY, instance, zone)
			if x ~= nil then return x, y, z end
		end
	end
end

--[[function PT.getNPCPosition(id)
	if id == nil then return end
	if addon.dataSource == "QUESTIE" then return QUESTIE.getNPCPosition(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getNPCPosition(id) end
	if DB.creaturesDB[id] == nil or DB.creaturesDB[id].positions == nil then return end
	local p = DB.creaturesDB[id].positions[1]
	local x, y, z = QT.GetZoneCoordinatesFromWorld(p.y, p.x, p.mapid)
	return {instance = p.mapid, wx = p.y, wy = p.x, mapID = DM.mapIDs[z], x = x, y = y}
end]]

function PT.getNPCPosition(id, currentPos)
	if PT.npcPosition == nil then PT.npcPosition = {} end
	local pos = PT.npcPosition[id]
	if pos and not pos.estimate then return pos end
	local clusters = pos and pos.clusters
	local estimate = true
	if not clusters then 
		local positions = QT.getNPCPositions(id)
		if positions == nil or #positions > LIMIT_CENTER_POSITION then return end
		clusters = calculateClusters(positions)
		estimate = #positions > 1
	end
	local maxCluster = selectBestCluster(clusters, currentPos)
	if maxCluster ~= nil then
		pos = {x = math.floor(maxCluster.x * 10000) / 100, y = math.floor(maxCluster.y * 10000) / 100, 
			wx = maxCluster.wx, wy = maxCluster.wy, instance = maxCluster.instance,
			zone = maxCluster.zone, mapID = DM.mapIDs[maxCluster.zone],
			radius = math.floor(math.sqrt(maxCluster.radius)) + CG.DEFAULT_GOTO_RADIUS, estimate = estimate,
			clusters = clusters}
		PT.npcPosition[id] = pos 
		return pos
	end
end

function PT.getNPCPositionsLimited(id, maxNumber, onlyWorld)
	local positions = QT.getNPCPositions(id)
	if positions == nil then return end
	return PT.getPositionsLimited(positions, maxNumber, onlyWorld)
end	

function PT.getItemPosition(id, currentPos)
	if PT.itemPosition == nil then PT.itemPosition = {} end
	local pos = PT.itemPosition[id]
	if pos and not pos.estimate then return pos end
	local clusters = pos and pos.clusters
	local estimate = true
	if not clusters then 
		local positions = QT.getItemPositions(id)
		if positions == nil or #positions > LIMIT_CENTER_POSITION then return end
		clusters = calculateClusters(positions)
		estimate = #positions > 1
	end
	local maxCluster = selectBestCluster(clusters, currentPos)
	if maxCluster ~= nil then
		pos = {x = math.floor(maxCluster.x * 10000) / 100, y = math.floor(maxCluster.y * 10000) / 100, 
			wx = maxCluster.wx, wy = maxCluster.wy, instance = maxCluster.instance,
			zone = maxCluster.zone, mapID = DM.mapIDs[maxCluster.zone],
			radius = math.floor(math.sqrt(maxCluster.radius)) + CG.DEFAULT_GOTO_RADIUS, estimate = estimate,
			clusters = clusters}
		PT.itemPosition[id] = pos 
		return pos
	end
end

function PT.getItemPositionsLimited(id, maxNumber, onlyWorld)
	local positions = QT.getItemPositions(id)
	if positions == nil then return end
	return PT.getPositionsLimited(positions, maxNumber, onlyWorld)
end	





