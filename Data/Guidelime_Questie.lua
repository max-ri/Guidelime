local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")

-- TODO: items in CHANGEME_Questie4_ItemDB ?

function addon.getQuestTargetNamesQuestie(id, typ, objective)
	if id == nil or Questie == nil then return end
	local quest = qData[id]
	if quest == nil then return nil end
	local list
	if typ == "ACCEPT" then 
		list = quest[2]
	elseif typ == "COMPLETE" then
		list = quest[10]
	elseif typ == "TURNIN" then
		list = quest[3]
	else
		return
	end
	local names = {}
	if list[1] ~= nil then for i, npc in ipairs(list[1]) do 
		if typ == "COMPLETE" then
			--if addon.debugging then print("LIME: npc", npc[1]) end
			table.insert(names, npc[2] or npcData[npc[1]][1]) 
		else
			--if addon.debugging then print("LIME: npc", npc) end
			table.insert(names, npcData[npc][1]) 
		end
	end end
	if list[2] ~= nil then for i, object in ipairs(list[2]) do 
		if typ == "COMPLETE" then
			--if addon.debugging then print("LIME: object", object[1]) end
			table.insert(names, object[2] or objData[object[1]][1])
		else
			--if addon.debugging then print("LIME: object", object) end
			table.insert(names, objData[object][1])
		end
	end end
	if list[3] ~= nil then for i, item in ipairs(list[3]) do 
		if typ == "COMPLETE" then
			--if addon.debugging then print("LIME: item", item[1]) end
			if (item[2] or CHANGEME_Questie4_ItemDB[item[1]]) ~= nil then
				table.insert(names, item[2] or CHANGEME_Questie4_ItemDB[item[1]][1]) 
			end
		else
			--if addon.debugging then print("LIME: item", item) end
			if CHANGEME_Questie4_ItemDB[item] ~= nil then
				table.insert(names, CHANGEME_Questie4_ItemDB[item][1]) 
			end
		end
	end end
	return names
end

local function reverseZoneData()
	addon.zoneDataClassicReverse = {}
	for id, zone in pairs(zoneDataClassic) do
		addon.zoneDataClassicReverse[zone] = id
	end
end

function addon.getQuestPositionsQuestie(id, typ, index)
	if id == nil or Questie == nil then return end
	local quest = qData[id]
	if quest == nil then return nil end
	local list
	if typ == "ACCEPT" then 
		list = quest[2]
	elseif typ == "COMPLETE" then
		list = quest[10]
	elseif typ == "TURNIN" then
		list = quest[3]
	else
		return
	end
	local npcs = {}
	local objects = {}
	local items = {}
	if index == nil then
		if list[1] ~= nil then for i, npc in ipairs(list[1]) do if typ == "COMPLETE" then npcs[i] = npc[1] else npcs[i] = npc end end end
		if list[2] ~= nil then for i, object in ipairs(list[2]) do if typ == "COMPLETE" then objects[i] = object[1] else objects[i] = object end end end
		if list[3] ~= nil then for i, item in ipairs(list[3]) do if typ == "COMPLETE" then items[i] = item[1] else items[i] = item end end end
	else
		local c = 0
		if list[1] ~= nil and #list[1] > 0 and #list[1] >= index then 
			if typ == "COMPLETE" then npcs = {list[1][index][1]} else npcs = {list[1][index]} end
		else
			if list[1] ~= nil then c = #list[1] end
			if list[2] ~= nil and #list[2] > 0 and #list[2] >= index - c then 
				if typ == "COMPLETE" then objects = {list[2][index - c][1]} else objects = {list[2][index - c]} end
			else
				if list[2] ~= nil then c = c + #list[2] end
				if list[3] ~= nil and #list[3] > 0 and #list[3] >= index - c then 
					if typ == "COMPLETE" then items = {list[3][index - c][1]} else items = {list[3][index - c]} end
				end
			end
		end
	end
	for j = 1, #items do
		local item = CHANGEME_Questie4_ItemDB[items[j]]
		--if item == nil then error("item " .. items[j] .. " not found for quest " .. questid .. typ) end
		--if addon.debugging then print("LIME: item", items[j] .. " " .. item[6]) end
		if item ~= nil then
			for i = 1, #item[3] do
				if not addon.contains(npcs, item[3][i]) then table.insert(npcs, item[3][i]) end
			end
			for i = 1, #item[4] do
				if not addon.contains(objects, item[4][i]) then table.insert(objects, item[4][i]) end
			end
		end
	end
	local positions = {}
	local filterZone
	if addon.zoneDataClassicReverse == nil then reverseZoneData() end
	if addon.questsDB[id] ~= nil then filterZone = addon.zoneDataClassicReverse[addon.questsDB[id].sort] end
	for j = 1, #npcs do
		local npc = npcData[npcs[j]]
		--if npc == nil then error("npc " .. npcs[j] .. " not found for quest " .. questid .. typ) end
		--if addon.debugging then print("LIME: npc", npc[1]) end
		if npc ~= nil then
			if filterZone == nil then
				for zone, posList in pairs(npc[7]) do
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = zoneDataClassic[zone] or zone})
					end
				end
			elseif npc[7][filterZone] ~= nil then
				for _, pos in ipairs(npc[7][filterZone]) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = zoneDataClassic[filterZone]})
				end
			end
		end
	end
	for j = 1, #objects do
		local object = objData[objects[j]]
		if object == nil then error("object " .. objects[j] .. " not found for quest " .. questid .. typ) end
		--if addon.debugging then print("LIME: object", object[1]) end
		if filterZone == nil then
			for zone, posList in pairs(object[4]) do
				for _, pos in ipairs(posList) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = zoneDataClassic[zone] or zone})
				end
			end
		elseif object[4][filterZone] ~= nil then
			for _, pos in ipairs(object[4][filterZone]) do
				table.insert(positions, {x = pos[1], y = pos[2], zone = zoneDataClassic[filterZone]})
			end
		end
	end
	local i = 1
	while i <= #positions do
		local pos = positions[i]
		if pos.wx == -1 and pos.wy == -1 then
			-- locations inside instances are marked with -1,-1
			table.remove(positions, i)
		else
			pos.mapID = addon.mapIDs[pos.zone]
			pos.wx, pos.wy, pos.instance = HBD:GetWorldCoordinatesFromZone(pos.x / 100, pos.y / 100, pos.mapID)
			--if addon.debugging then print("LIME: found position", pos.wx, pos.wy, pos.instance) end
			if pos.wx == nil then
				if addon.debugging then print("LIME: error transforming (", pos.x, ",", pos.y, pos.zone, addon.mapIDs[pos.zone], ") into world coordinates for quest #", id) end
				table.remove(positions, i)
			else
				i = i + 1
			end
		end
	end
	--if addon.debugging then print("LIME: found ", #positions, "positions") end
	return positions
end

function addon.getQuestObjectivesQuestie(id)
	if Questie == nil then return end
	local objectives = {}
	if qData[id][10][1] ~= nil then
		for j = 1, #qData[id][10][1] do
			local npc = npcData[qData[id][10][1][j][1]]
			if npc ~= nil then
				table.insert(objectives, {npc[1]})
			end
		end
	end
	if qData[id][10][2] ~= nil then
		for j = 1, #qData[id][10][2] do
			if objectives[id] == nil then objectives[id] = {} end
			local obj = objData[qData[id][10][2][j][1]]
			if obj ~= nil then
				table.insert(objectives, {obj[1]})
			end
		end
	end
	if qData[id][10][3] ~= nil then
		for j = 1, #qData[id][10][3] do
			local item = CHANGEME_Questie4_ItemDB[qData[id][10][3][j][1] ]
			if item ~= nil then
				local objList = {}
				for i = 1, #item[3] do
					local npc = npcData[item[3][i] ]
					if npc ~= nil then
						table.insert(objList, npc[1])
					end
				end
				for i = 1, #item[4] do
					local obj = objData[item[4][i] ]
					table.insert(objList, obj[1])
				end
				table.insert(objList, item[1])
				table.insert(objectives, objList)
			end
		end
	end
	return objectives
end

