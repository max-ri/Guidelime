local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")

local function reverseZoneData()
	addon.zoneDataClassicReverse = {}
	for id, zone in pairs(zoneDataClassic) do
		addon.zoneDataClassicReverse[zone] = id
	end
end

local function bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
local function hasbit(x, p)
  return x % (p + p) >= p       
end

function addon.getQuestRacesQuestie(id)
	if id == nil or QuestieDB == nil or QuestieDB.questData == nil or QuestieDB.questData[id] == nil then return end
	local bitmask = QuestieDB.questData[id][6]
	if bitmask == nil then return end
	local races = {}
	for i, race in ipairs({"Human", "Orc", "Dwarf", "NightElf", "Undead", "Troll", "Gnome", "Tauren"}) do
		if hasbit(bitmask, bit(i)) then 
			table.insert(races, race) 
		end
	end
	return races
end

function addon.getQuestClassesQuestie(id)
	if id == nil or QuestieDB == nil or QuestieDB.questData == nil or QuestieDB.questData[id] == nil then return end
	local bitmask = QuestieDB.questData[id][7]
	if bitmask == nil then return end
	local races = {}
	for i, race in pairs({"Warrior", "Paladin", "Hunter", "Rogue", "Priest", nil, "Shaman", "Mage", "Warlock", nil, "Druid"}) do
		if hasbit(bitmask, bit(i)) then 
			table.insert(races, race) 
		end
	end
	return races
end

function addon.getQuestFactionQuestie(id)
	if id == nil or QuestieDB == nil or QuestieDB.questData == nil or QuestieDB.questData[id] == nil then return end
	local bitmask = QuestieDB.questData[id][6]
	if bitmask == nil then return end
	if bitmask == 77 then return "Alliance" end
	if bitmask == 178 then return "Horde" end
end

function addon.getQuestPositionsQuestie(id, typ, index, filterZone)
	if id == nil or QuestieDB == nil or QuestieDB.questData == nil or QuestieDB.questData[id] == nil then return end
	local quest = QuestieDB.questData[id]
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
		local item = QuestieDB.itemData[items[j]]
		--if item == nil then error("item " .. items[j] .. " not found for quest " .. questid .. typ) end
		--if addon.debugging then print("LIME: item", items[j] .. " " .. item[6]) end
		if item ~= nil then
			for i = 1, #item[1] do
				if not addon.contains(npcs, item[1][i][1]) then table.insert(npcs, item[1][i][1]) end
			end
			for i = 1, #item[2] do
				if not addon.contains(objects, item[2][i][1]) then table.insert(objects, item[2][i][1]) end
			end
		end
	end
	local positions = {}
	local filterZone
	if addon.zoneDataClassicReverse == nil then reverseZoneData() end
	if filterZone ~= nil then filterZone = addon.zoneDataClassicReverse[filterZone] end
	for j = 1, #npcs do
		local npc = QuestieDB.npcData[npcs[j]]
		--if npc == nil then error("npc " .. npcs[j] .. " not found for quest " .. questid .. typ) end
		--if addon.debugging then print("LIME: npc", npc[1]) end
		if npc ~= nil and npc[7] ~= nil then
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
		local object = QuestieDB.objectData[objects[j]]
		if object == nil then error("object " .. objects[j] .. " not found for quest " .. id .. typ) end
		--if addon.debugging then print("LIME: object", object[1]) end
		if object[4] ~= nil then
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

-- returns a type (npc/item/object) and a list of names for quest source / each objective / turn in; e.g. {{type="item", names={"Dealt with The Hogger Situation", "Huge Gnoll Claw", "Hogger"}} for id = 176, typ = "COMPLETE"
function addon.getQuestObjectivesQuestie(id, typ)
	if id == nil or QuestieDB == nil or QuestieDB.questData == nil or QuestieDB.questData[id] == nil then return end
	local quest = QuestieDB.questData[id]
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
	local objectives = {}
	if list[1] ~= nil then
		for j = 1, #list[1] do
			local objList = {}
			local npc
			if type(list[1][j]) == "number" then 
				npc = QuestieDB.npcData[list[1][j]]
			else 
				npc = QuestieDB.npcData[list[1][j][1]]
				table.insert(objList, list[1][j][2])
			end
			if npc ~= nil and not addon.contains(objList, npc[1]) then table.insert(objList, npc[1]) end
			if typ == "COMPLETE" then
				table.insert(objectives, {type = "monster", names = objList})
			else
				table.insert(objectives, {type = "npc", names = objList})
			end
		end
	end
	if list[2] ~= nil then
		for j = 1, #list[2] do
			local objList = {}
			local obj
			if type(list[2][j]) == "number" then 
				obj = QuestieDB.npcData[list[2][j]]
			else 
				obj = QuestieDB.npcData[list[2][j][1]]
				table.insert(objList, list[2][j][2])
			end
			if obj ~= nil and not addon.contains(objList, obj[1]) then table.insert(objList, obj[1]) end
			table.insert(objectives, {type = "object", names = objList})
		end
	end
	if list[3] ~= nil then
		for j = 1, #list[3] do
			local objList = {}
			local item
			if type(list[3][j]) == "number" then 
				item = QuestieDB.itemData[list[3][j]]
			else
				item = QuestieDB.itemData[list[3][j][1]]
				table.insert(objList, list[3][j][2])
			end
			if item ~= nil then
				if not addon.contains(objList, item[6]) then table.insert(objList, item[6]) end
				for i = 1, #item[1] do
					local npc = QuestieDB.npcData[item[1][i][1] ]
					if npc ~= nil then
						if not addon.contains(objList, npc[1]) then table.insert(objList, npc[1]) end
					end
				end
				for i = 1, #item[2] do
					local obj = QuestieDB.objectData[item[2][i][1] ]
					if not addon.contains(objList, obj[1]) then table.insert(objList, obj[1]) end
				end
			end
			table.insert(objectives, {type = "item", names = objList})
		end
	end
	return objectives
end

