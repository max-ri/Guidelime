local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")

local QuestieDB = QuestieLoader and QuestieLoader:ImportModule("QuestieDB");
local ZoneDB = QuestieLoader and QuestieLoader:ImportModule("ZoneDB")

local correctionsObjectiveOrder = {
	-- https://tbc.wowhead.com/quest=10503/the-bladespire-threat
	-- objectives switched; first kill credit then creature
	[10503] = {2, 1},
	-- https://tbc.wowhead.com/quest=10861/veil-lithic-preemptive-strike
	-- objectives switched; first object then creature
	[10861] = {2, 1},
}

function addon.bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function addon.hasbit(x, p)
  return x % (p + p) >= p       
end

function addon.isDataSourceInstalledQUESTIE()
	return QuestieLoader ~= nil
end

local function checkQuestie()
	if addon.waitingForQuestie or not addon.isDataSourceInstalledQUESTIE() then return false end
	if QuestieDB == nil or QuestieDB.QueryQuest == nil or type(QuestieDB.QueryQuest) ~= "function" then
		if addon.debugging then print("LIME: Questie is not yet initialized") end
		addon.waitingForQuestie = true
		C_Timer.After(4, function()
			addon.waitingForQuestie = false
			addon.loadCurrentGuide(false)
			addon.updateFromQuestLog()
			addon.updateSteps()
		end)
		return false	
	end
	return true
end

function addon.isQuestIdQuestie(id)
	if id == nil or not checkQuestie() then return false end
	return QuestieDB:GetQuest(id) ~= nil
end

function addon.getQuestNameQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.name
end

function addon.getQuestSortQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	if quest.zoneOrSort > 0 then
    	local parentZoneID = ZoneDB:GetParentZoneId(quest.zoneOrSort)
		return addon.zoneNames[ZoneDB:GetUiMapIdByAreaId(parentZoneID or quest.zoneOrSort)]
	elseif quest.zoneOrSort < 0 then
		for key, n in pairs(QuestieDB.sortKeys) do
			if quest.zoneOrSort == n then
				return string.lower(key):gsub("^%l", string.upper)
			end
		end
	end
end

function addon.getQuestPrequestsQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.preQuestSingle or quest.preQuestGroup
end

function addon.getQuestOneOfPrequestsQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.preQuestSingle ~= nil
end

function addon.getQuestTypeQuestie(id)
	if id == nil or not checkQuestie() then return end
	if QuestieDB:IsDungeonQuest(id) then return "Dungeon" end
	if QuestieDB:IsRaidQuest(id) then return "Raid" end
	if QuestieDB:GetQuestTagInfo(id) == 1 then return "Group" end
	local _, _, _, _, _, isElite = GetQuestTagInfo(id)
	if isElite then return "Elite" end
end

function addon.getQuestLevelQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.questLevel
end

function addon.getQuestMinimumLevelQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.requiredLevel
end

function addon.getQuestNextQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.nextQuestInChain
end

function addon.getQuestRacesQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	local bitmask = quest.requiredRaces
	if bitmask == nil or bitmask == 0 then return end
	local races = {}
	for i, race in ipairs({"Human", "Orc", "Dwarf", "NightElf", "Undead", "Troll", "Gnome", "Tauren", "", "BloodElf", "Draenei"}) do
		if race ~= "" and addon.hasbit(bitmask, addon.bit(i)) then 
			table.insert(races, race) 
		end
	end
	return races
end

function addon.getQuestClassesQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	local bitmask = quest.requiredClasses
	if bitmask == nil or bitmask == 0 then return end
	local classes = {}
	for i, class in pairs({"Warrior", "Paladin", "Hunter", "Rogue", "Priest", "", "Shaman", "Mage", "Warlock", "", "Druid"}) do
		if class ~= "" and addon.hasbit(bitmask, addon.bit(i)) then 
			table.insert(classes, class) 
		end
	end
	return classes
end

function addon.getQuestFactionQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	local bitmask = quest.requiredRaces
	if bitmask == nil then return end
	if bitmask == 77 or bitmask == 1101 then return "Alliance" end
	if bitmask == 178 or bitmask == 690 then return "Horde" end
end

function addon.getQuestObjectiveQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.objectivesText[1]
end

function addon.getQuestReputationQuestie(id)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	local reputation, repMin, repMax
	if quest.requiredMinRep ~= nil then
		reputation = quest.requiredMinRep[1]
		repMin = quest.requiredMinRep[2]
	end
	if quest.requiredMaxRep ~= nil and (reputation == nil or reputation == quest.requiredMaxRep[1]) then
		reputation = quest.requiredMaxRep[1]
		repMax = quest.requiredMaxRep[2]
	end
	return reputation, repMin, repMax
end
	

function addon.getQuestPositionsQuestie(id, typ, index, filterZone)
	if id == nil or not checkQuestie() then return end
	local ids = {npc = {}, object = {}, item = {}}
	local objectives = {npc = {}, object = {}, item = {}}
	local positions = {}
	local filterZoneId
	if filterZone ~= nil then filterZoneId = ZoneDB:GetAreaIdByUiMapId(addon.mapIDs[filterZone]) end
	if addon.getSuperCode(typ) == "QUEST" then
		local quest = QuestieDB:GetQuest(id)
		if quest == nil then return end
		local list
		if typ == "ACCEPT" then 
			list = {quest.Starts}
		elseif typ == "COMPLETE" then
			list = quest.ObjectiveData
		elseif typ == "TURNIN" then
			list = {quest.Finisher}
		end
		if list ~= nil then
			--if addon.debugging then print("LIME: getQuestPositionsQuestie " .. typ .. " " .. id .. " " .. #list) end
			for i = 1, #list do
				local oi = (typ == "COMPLETE" and correctionsObjectiveOrder[id]) and correctionsObjectiveOrder[id][i] or i
				if index == nil or index == 0 or index == oi then
					if list[i].NPC ~= nil then
						for _, id2 in ipairs(list[i].NPC) do
							table.insert(ids.npc, id2)
							if objectives.npc[id2] == nil then objectives.npc[id2] = {} end
							table.insert(objectives.npc[id2], oi)
						end
					elseif list[i].GameObject ~= nil then
						for _, id2 in ipairs(list[i].GameObject) do
							table.insert(ids.object, id2)
							if objectives.object[id2] == nil then objectives.object[id2] = {} end
							table.insert(objectives.object[id2], oi)
						end
					elseif list[i].Type == "monster" or list[i].Type == "item" or list[i].Type == "object" then
						local type = list[i].Type == "monster" and "npc" or list[i].Type
						table.insert(ids[type], list[i].Id)
						if objectives[type][list[i].Id] == nil then objectives[type][list[i].Id] = {} end
						table.insert(objectives[type][list[i].Id], oi)
					elseif list[i].Type == "killcredit" then
						for _, id2 in ipairs(list[i].IdList) do
							table.insert(ids.npc, id2)
							if objectives.npc[id2] == nil then objectives.npc[id2] = {} end
							table.insert(objectives.npc[id2], oi)
						end
					elseif list[i].Type == "event" and list[i].Coordinates ~= nil then
						if filterZone == nil then
							for zone, posList in pairs(list[i].Coordinates) do
								for _, pos in ipairs(posList) do
									table.insert(positions, {x = pos[1], y = pos[2], zone = addon.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, objectives = oi})
								end
							end
						elseif list[i].Coordinates[filterZoneId] ~= nil then
							for _, pos in ipairs(list[i].Coordinates[filterZoneId]) do
								table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, objectives = oi})
							end
						end
					end
				end
			end
		end
	elseif typ == "COLLECT_ITEM" then
		ids.item = {id}
		objectives.item[id] = {}
	else
		return
	end
	for _, itemId in ipairs(ids.item) do
		local item = QuestieDB:GetItem(itemId)
		--if item == nil then error("item " .. ids.item[j] .. " not found for quest " .. questid .. typ) end
		--if addon.debugging then print("LIME: item", ids.item[j] .. " " .. item[6]) end
		if item ~= nil then
			if item.npcDrops ~= nil then
				for i = 1, #item.npcDrops do
					if not addon.contains(ids.npc, item.npcDrops[i]) then table.insert(ids.npc, item.npcDrops[i]) end
					if objectives.npc[item.npcDrops[i]] == nil then objectives.npc[item.npcDrops[i]] = {} end
					for _, c in ipairs(objectives.item[itemId]) do table.insert(objectives.npc[item.npcDrops[i]], c) end
				end
			end
			if item.objectDrops ~= nil then
				for i = 1, #item.objectDrops do
					if not addon.contains(ids.object, item.objectDrops[i]) then table.insert(ids.object, item.objectDrops[i]) end
					if objectives.object[item.objectDrops[i]] == nil then objectives.object[item.objectDrops[i]] = {} end
					for _, c in ipairs(objectives.item[itemId]) do table.insert(objectives.object[item.objectDrops[i]], c) end
				end
			end
		end
	end
	for _, npcId in ipairs(ids.npc) do
		local npc = QuestieDB:GetNPC(npcId)
		--if npc == nil then error("npc " .. npcId .. " not found for quest " .. questid .. typ) end
		--if addon.debugging then print("LIME: npc", npc[1]) end
		if npc ~= nil and npc.spawns ~= nil then
			if filterZone == nil then
				for zone, posList in pairs(npc.spawns) do
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = addon.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, npcId = npcId, objectives = objectives.npc[npcId]})
					end
				end
			elseif npc.spawns[filterZoneId] ~= nil then
				for _, pos in ipairs(npc.spawns[filterZoneId]) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, npcId = npcId, objectives = objectives.npc[npcId]})
				end
			end
		end
	end
	for _, objectId in ipairs(ids.object) do
		local object = QuestieDB:GetObject(objectId)
		if object == nil then error("object " .. objectId .. " not found for quest " .. id .. typ) end
		--if addon.debugging then print("LIME: object", object[1]) end
		if object.spawns ~= nil then
			if filterZone == nil then
				for zone, posList in pairs(object.spawns) do
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = addon.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, objectId = objectId, objectives = objectives.object[objectId]})
					end
				end
			elseif object.spawns[filterZoneId] ~= nil then
				for _, pos in ipairs(object.spawns[filterZoneId]) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, objectId = objectId, objectives = objectives.object[objectId]})
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

-- returns a type (npc/item/object) and a list of names for quest source / each objective / turn in; e.g. {{type="item", names={"Huge Gnoll Claw", "Hogger"}, ids={item={1931},npc={448}} for id = 176, typ = "COMPLETE"
function addon.getQuestObjectivesQuestie(id, typ)
	if id == nil or not checkQuestie() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	if typ == "ACCEPT" then 
		list = {quest.Starts}
	elseif typ == "COMPLETE" then
		list = quest.ObjectiveData
	elseif typ == "TURNIN" then
		list = {quest.Finisher}
	else
		return
	end
	--if addon.debugging then print("LIME: getQuestObjectivesQuestie " .. typ .. " " .. id .. " " .. addon.show(list)) end
	
	local objectives = {}
	for j = 1, #list do
		if list[j].NPC ~= nil then
			for _, npcId in ipairs(list[j].NPC) do
				local objList = {}
				local npc = QuestieDB:GetNPC(npcId)
				if npc ~= nil and not addon.contains(objList, npc.name) then table.insert(objList, npc.name) end
				table.insert(objectives, {type = "npc", names = objList, ids = {npc = {npcId}}})
			end
		elseif list[j].Type == "monster" then
			local objList = {}
			if list[j].Name ~= nil then table.insert(objList, list[j].Name) end
			local npc = QuestieDB:GetNPC(list[j].Id)
			if npc ~= nil and not addon.contains(objList, npc.name) then table.insert(objList, npc.name) end
			table.insert(objectives, {type = "monster", names = objList, ids = {npc = {list[j].Id}}})
		elseif list[j].Type == "object" then
			local objList = {}
			if list[j].Name ~= nil then table.insert(objList, list[j].Name) end
			local obj = QuestieDB:GetObject(list[j].Id)
			if obj ~= nil and not addon.contains(objList, obj.name) then table.insert(objList, obj.name) end
			table.insert(objectives, {type = "object", names = objList, ids = {object = {list[j].Id}}})
		elseif list[j].Type == "item" then
			local objective = {type = "item", ids = {item = {list[j].Id}}, names = {}}
			if list[j].Name ~= nil then table.insert(objective.names, list[j].Name) end
			local item = QuestieDB:GetItem(list[j].Id)
			if item ~= nil then
				if not addon.contains(objective.names, item.name) then table.insert(objective.names, item.name) end
				if item.npcDrops ~= nil then
					objective.ids.npc = {}
					for i = 1, #item.npcDrops do
						table.insert(objective.ids.npc, item.npcDrops[i])
						local npc = QuestieDB:GetNPC(item.npcDrops[i])
						if npc ~= nil then
							if not addon.contains(objective.names, npc.name) then table.insert(objective.names, npc.name) end
						end
					end
				end
				if item.objectDrops ~= nil then
					objective.ids.object = {}
					for i = 1, #item.objectDrops do
						table.insert(objective.ids.object, item.objectDrops[i])
						local obj = QuestieDB:GetObject(item.objectDrops[i])
						if not addon.contains(objective.names, obj.name) then table.insert(objective.names, obj.name) end
					end
				end
			end
			table.insert(objectives, objective)
		elseif list[j].Type == "killcredit" then
			local objList = {}
			if list[j].Text ~= nil then table.insert(objList, list[j].Text) end
			local npc = QuestieDB:GetNPC(list[j].RootId)
			if npc ~= nil then table.insert(objList, npc.name) end
			table.insert(objectives, {type = "monster", names = objList, ids = {npc = list[j].IdList}})
		end
	end
	if typ == "COMPLETE" and correctionsObjectiveOrder[id] then
		local objectives2 = {}
		for i, j in ipairs(correctionsObjectiveOrder[id]) do
			objectives2[i] = objectives[j]
		end
		return objectives2
	end
	return objectives
end

function addon.getNPCPositionQuestie(id)
	if id == nil or not checkQuestie() then return end
	local npc = QuestieDB:GetNPC(id)
	if npc ~= nil and npc.spawns ~= nil then
		for zone, posList in pairs(npc.spawns) do
			for _, pos in ipairs(posList) do
				local p = {x = pos[1], y = pos[2], mapID = ZoneDB:GetUiMapIdByAreaId(zone), zone = addon.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone}
				p.wx, p.wy, p.instance = HBD:GetWorldCoordinatesFromZone(p.x / 100, p.y / 100, p.mapID)
				if p.wx == nil then
					if addon.debugging then print("LIME: error transforming (", p.x, ",", p.y, p.zone, p.mapID, ") into world coordinates for npc #", id) end
				else
					return p
				end
			end
		end
	end
end

function addon.getNPCNameQuestie(id)
	if id == nil or not checkQuestie() then return end
	local npc = QuestieDB:GetNPC(id)
	if npc ~= nil then return npc.name end
end

function addon.getObjectNameQuestie(id)
	if id == nil or not checkQuestie() then return end
	local object = QuestieDB:GetObject(id)
	if object ~= nil then return object.name end
end
