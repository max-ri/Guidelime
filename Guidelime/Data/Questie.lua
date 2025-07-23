local addonName, addon = ...
local L = addon.L

local HBD = LibStub("HereBeDragons-2.0")

local QuestieDB = QuestieLoader and QuestieLoader:ImportModule("QuestieDB")
local ZoneDB = QuestieLoader and QuestieLoader:ImportModule("ZoneDB")

addon.D = addon.D or {}; local D = addon.D                         -- Data/Data
addon.DM = addon.DM or {}; local DM = addon.DM                     -- Data/MapDB
addon.QT = addon.QT or {}; local QT = addon.QT                     -- Data/QuestTools
addon.CG = addon.CG or {}; local CG = addon.CG                     -- CurrentGuide
addon.EV = addon.EV or {}; local EV = addon.EV                     -- Events
addon.GP = addon.GP or {}; local GP = addon.GP                     -- GuideParser
addon.MW = addon.MW or {}; local MW = addon.MW                     -- MainWindow

addon.QUESTIE = addon.QUESTIE or {}; local QUESTIE = addon.QUESTIE -- Data/Questie

function QUESTIE.isDataSourceInstalled()
	return QuestieLoader ~= nil
end

function QUESTIE.isDataSourceReady()
	if QUESTIE.waitingForQuestie or not QUESTIE.isDataSourceInstalled() then return false end
	if QuestieDB == nil or QuestieDB.QueryQuest == nil or type(QuestieDB.QueryQuest) ~= "function" then
		if addon.debugging then print("LIME: Questie is not yet initialized") end
		QUESTIE.waitingForQuestie = true
		C_Timer.After(4, function()
			if addon.debugging then print("LIME: reload after waiting for Questie") end
			QUESTIE.waitingForQuestie = false
			CG.loadCurrentGuide(false)
			EV.updateFromQuestLog()
			MW.updateMainFrame()
		end)
		return false	
	end
	return true
end

function QUESTIE.isQuestId(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return false end
	return QuestieDB.GetQuest(id) ~= nil
end

function QUESTIE.getQuestName(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	return quest.name
end

function QUESTIE.getQuestSort(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	if quest.zoneOrSort > 0 then
    	local parentZoneID = ZoneDB:GetParentZoneId(quest.zoneOrSort)
		return DM.zoneNames[ZoneDB:GetUiMapIdByAreaId(parentZoneID or quest.zoneOrSort)]
	elseif quest.zoneOrSort < 0 then
		for key, n in pairs(QuestieDB.sortKeys) do
			if quest.zoneOrSort == n then
				return string.lower(key):gsub("^%l", string.upper)
			end
		end
	end
end

function QUESTIE.getQuestPrequests(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	return quest.preQuestSingle or quest.preQuestGroup
end

function QUESTIE.getQuestOneOfPrequests(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	return quest.preQuestSingle ~= nil
end

function QUESTIE.getQuestType(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	if QuestieDB.IsDungeonQuest(id) then return "Dungeon" end
	if QuestieDB.IsRaidQuest(id) then return "Raid" end
	if QuestieDB.GetQuestTagInfo(id) == 1 then return "Group" end
	local _, _, _, _, _, isElite = GetQuestTagInfo(id)
	if isElite then return "Elite" end
end

function QUESTIE.getQuestLevel(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	return quest.questLevel
end

function QUESTIE.getQuestMinimumLevel(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	return quest.requiredLevel
end

function QUESTIE.getQuestNext(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	return quest.nextQuestInChain
end

function QUESTIE.getQuestRaces(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	local bitmask = quest.requiredRaces
	if bitmask == nil or bitmask == 0 then return end
	local races = {}
	for i, race in ipairs({
		"Human", "Orc", "Dwarf", "NightElf", 
		"Undead", "Tauren", "Gnome", "Troll", 
		"Goblin", "BloodElf", "Draenei", "", 
		"", "", "", "", 
		"", "", "", "", 
		"", "Worgen", "Pandaren" --[[neutral]], "",
		"Pandaren" --[[Alliance]], "Pandaren" --[[Horde]]}) do
		if race ~= "" and D.hasbit(bitmask, D.bit(i)) then 
			table.insert(races, race) 
		end
	end
	return races
end

function QUESTIE.getQuestClasses(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	local bitmask = quest.requiredClasses
	if bitmask == nil or bitmask == 0 then return end
	local classes = {}
	for i, class in pairs({"Warrior", "Paladin", "Hunter", "Rogue", "Priest", "DeathKnight", "Shaman", "Mage", "Warlock", "Monk", "Druid"}) do
		if class ~= "" and D.hasbit(bitmask, D.bit(i)) then 
			table.insert(classes, class) 
		end
	end
	return classes
end

function QUESTIE.getQuestFaction(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	local bitmask = quest.requiredRaces
	if bitmask == nil then return end
	if bitmask == 77 or bitmask == 1101 or bitmask == 2098253 or bitmask == 18875469 then return "Alliance" end
	if bitmask == 178 or bitmask == 690 or bitmask == 946 or bitmask == 33555378 then return "Horde" end
end

function QUESTIE.getQuestObjective(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	return quest.objectivesText[1]
end

function QUESTIE.getQuestReputation(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
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

function QUESTIE.getQuestPositions(id, typ, index, filterZone)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	if index == 0 then index = nil end
	if type(index) == "number" then index = {index} end
	local ids = {npc = {}, object = {}, item = {}}
	local objectives = {npc = {}, object = {}, item = {}}
	local positions = {}
	local filterZoneId = filterZone and DM.mapIDs[filterZone]
	local filterZoneUiId = filterZoneId and ZoneDB:GetAreaIdByUiMapId(filterZoneId)
	local specialObjectivesIndex
	if GP.getSuperCode(typ) == "QUEST" then
		local quest = QuestieDB.GetQuest(id)
		if quest == nil then return end
		local list
		if typ == "ACCEPT" then 
			list = {quest.Starts}
			if QUESTIE.correctionsQuestAccept[id] then list = QUESTIE.correctionsQuestAccept[id] end
		elseif typ == "COMPLETE" then
			list = {}
			if quest.ObjectiveData then
				for i = 1, #quest.ObjectiveData do
					list[#list + 1] = quest.ObjectiveData[i]
				end
			end
			if quest.SpecialObjectives then
				specialObjectivesIndex = #list
				for _, v in pairs(quest.SpecialObjectives) do
					list[#list + 1] = v
				end
			end
		elseif typ == "TURNIN" then
			list = {quest.Finisher}
		end
		if list ~= nil then
			--if addon.debugging then print("LIME: getQuestPositionsQuestie " .. typ .. " " .. id .. " " .. #list) end
			for i = 1, #list do
				local oi = (typ == "COMPLETE" and QUESTIE.correctionsObjectiveOrder[id] and QUESTIE.correctionsObjectiveOrder[id][i]) and QUESTIE.correctionsObjectiveOrder[id][i] or i
				if index == nil or D.contains(index, oi) then
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
								local mapID = ZoneDB:GetUiMapIdByAreaId(zone)
								for _, pos in ipairs(posList) do
									table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[mapID] or zone, mapID = mapID, objectives = {oi}})
								end
							end
						elseif list[i].Coordinates[filterZoneUiId] ~= nil then
							for _, pos in ipairs(list[i].Coordinates[filterZoneUiId]) do
								table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, mapID = filterZoneId, objectives = {oi}})
							end
						end
					end
				end
			end
		end
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
					if not D.contains(ids.npc, item.npcDrops[i]) then table.insert(ids.npc, item.npcDrops[i]) end
					if objectives.npc[item.npcDrops[i]] == nil then objectives.npc[item.npcDrops[i]] = {} end
					for _, c in ipairs(objectives.item[itemId]) do table.insert(objectives.npc[item.npcDrops[i]], c) end
				end
			end
			if item.objectDrops ~= nil then
				for i = 1, #item.objectDrops do
					if not D.contains(ids.object, item.objectDrops[i]) then table.insert(ids.object, item.objectDrops[i]) end
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
					local mapID = ZoneDB:GetUiMapIdByAreaId(zone)
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[mapID] or zone, mapID = mapID, npcId = npcId, objectives = objectives.npc[npcId]})
					end
				end
			elseif npc.spawns[filterZoneUiId] ~= nil then
				for _, pos in ipairs(npc.spawns[filterZoneUiId]) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, mapID = filterZoneId, npcId = npcId, objectives = objectives.npc[npcId]})
				end
			end
		end
		if npc ~= nil and npc.waypoints ~= nil then
			if filterZone == nil then
				for zone, pathList in pairs(npc.waypoints) do
					local mapID = ZoneDB:GetUiMapIdByAreaId(zone)
					for _, posList in ipairs(pathList) do
						for _, pos in ipairs(posList) do
							table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[mapID] or zone, mapID = mapID, npcId = npcId, objectives = objectives.npc[npcId]})
						end
					end
				end
			elseif npc.waypoints[filterZoneUiId] ~= nil then
				for _, posList in ipairs(npc.waypoints[filterZoneUiId]) do
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, mapID = filterZoneId, npcId = npcId, objectives = objectives.npc[npcId]})
					end
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
					local mapID = ZoneDB:GetUiMapIdByAreaId(zone)
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[mapID] or zone, mapID = mapID, objectId = objectId, objectives = objectives.object[objectId]})
					end
				end
			elseif object.spawns[filterZoneUiId] ~= nil then
				for _, pos in ipairs(object.spawns[filterZoneUiId]) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, mapID = filterZoneId, objectId = objectId, objectives = objectives.object[objectId]})
				end
			end
		end
	end
	-- remove positions from special objectives only when there are coordinates from actual objectives
	if specialObjectivesIndex and not D.contains(positions, function(p) return D.contains(p.objectives, function(o) return o <= specialObjectivesIndex end) end) then
		specialObjectivesIndex = nil
	end
	local i = 1
	while i <= #positions do
		local pos = positions[i]
		if pos.wx == -1 and pos.wy == -1 then
			-- locations inside instances are marked with -1,-1
			table.remove(positions, i)
		elseif specialObjectivesIndex and not D.contains(pos.objectives, function(o) return o <= specialObjectivesIndex end) then
			-- remove positions from special objectives
			table.remove(positions, i)
		else
			pos.wx, pos.wy, pos.instance = HBD:GetWorldCoordinatesFromZone(pos.x / 100, pos.y / 100, pos.mapID)
			--if addon.debugging then print("LIME: found position", pos.wx, pos.wy, pos.instance) end
			if pos.wx == nil then
				if addon.debugging then print("LIME: error transforming (", pos.x, ",", pos.y, pos.zone, DM.mapIDs[pos.zone], ") into world coordinates for quest #", id) end
				table.remove(positions, i)
			else
				i = i + 1
			end
		end
	end
	--if addon.debugging then print("LIME: found ", #positions, "positions") end
	return positions
end

function QUESTIE.getItemPositions(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local ids = {npc = {}, object = {}}
	local positions = {}
	local item = QuestieDB:GetItem(id)
	if item ~= nil then
		if item.npcDrops ~= nil then
			for i = 1, #item.npcDrops do
				if not D.contains(ids.npc, item.npcDrops[i]) then table.insert(ids.npc, item.npcDrops[i]) end
			end
		end
		if item.objectDrops ~= nil then
			for i = 1, #item.objectDrops do
				if not D.contains(ids.object, item.objectDrops[i]) then table.insert(ids.object, item.objectDrops[i]) end
			end
		end
	end
	for _, npcId in ipairs(ids.npc) do
		local npc = QuestieDB:GetNPC(npcId)
		--if npc == nil then error("npc " .. npcId .. " not found for quest " .. questid .. typ) end
		--if addon.debugging then print("LIME: npc", npc[1]) end
		if npc ~= nil and npc.spawns ~= nil then
			for zone, posList in pairs(npc.spawns) do
				local mapID = ZoneDB:GetUiMapIdByAreaId(zone)
				for _, pos in ipairs(posList) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[mapID] or zone, mapID = mapID, npcId = npcId})
				end
			end
		end
		if npc ~= nil and npc.waypoints ~= nil then
			for zone, pathList in pairs(npc.waypoints) do
				local mapID = ZoneDB:GetUiMapIdByAreaId(zone)
				for _, posList in ipairs(pathList) do
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[mapID] or zone, mapID = mapID, npcId = npcId})
					end
				end
			end
		end
	end
	for _, objectId in ipairs(ids.object) do
		local object = QuestieDB:GetObject(objectId)
		if object == nil then error("object " .. objectId .. " not found for quest " .. id .. typ) end
		--if addon.debugging then print("LIME: object", object[1]) end
		if object.spawns ~= nil then
			for zone, posList in pairs(object.spawns) do
				local mapID = ZoneDB:GetUiMapIdByAreaId(zone)
				for _, pos in ipairs(posList) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[mapID] or zone, mapID = mapID, objectId = objectId})
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
			pos.wx, pos.wy, pos.instance = HBD:GetWorldCoordinatesFromZone(pos.x / 100, pos.y / 100, pos.mapID)
			--if addon.debugging then print("LIME: found position", pos.wx, pos.wy, pos.instance) end
			if pos.wx == nil then
				if addon.debugging then print("LIME: error transforming (", pos.x, ",", pos.y, pos.zone, DM.mapIDs[pos.zone], ") into world coordinates for item #", id) end
				table.remove(positions, i)
			else
				i = i + 1
			end
		end
	end
	--if addon.debugging then print("LIME: found ", #positions, "positions") end
	return positions
end

function QUESTIE.getNPCPositions(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local positions = {}
	local npc = QuestieDB:GetNPC(id)
	if npc ~= nil and npc.spawns ~= nil then
		for zone, posList in pairs(npc.spawns) do
			local mapID = ZoneDB:GetUiMapIdByAreaId(zone)
			for _, pos in ipairs(posList) do
				table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[mapID] or zone, mapID = mapID, npcId = id})
			end
		end
	end
	if npc ~= nil and npc.waypoints ~= nil then
		for zone, pathList in pairs(npc.waypoints) do
			local mapID = ZoneDB:GetUiMapIdByAreaId(zone)
			for _, posList in ipairs(pathList) do
				for _, pos in ipairs(posList) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[mapID] or zone, mapID = mapID, npcId = id})
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
			pos.wx, pos.wy, pos.instance = HBD:GetWorldCoordinatesFromZone(pos.x / 100, pos.y / 100, pos.mapID)
			--if addon.debugging then print("LIME: found position", pos.wx, pos.wy, pos.instance) end
			if pos.wx == nil then
				if addon.debugging then print("LIME: error transforming (", pos.x, ",", pos.y, pos.zone, DM.mapIDs[pos.zone], ") into world coordinates for npc #", id) end
				table.remove(positions, i)
			else
				i = i + 1
			end
		end
	end
	--if addon.debugging then print("LIME: found ", #positions, "positions") end
	return positions
end

function QUESTIE.getQuestNPCs(id, typ, index)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local ids = {npc = {}, item = {}}
	local objectives = {npc = {}, item = {}}
	if GP.getSuperCode(typ) == "QUEST" then
		local quest = QuestieDB.GetQuest(id)
		if quest == nil then return end
		local list
		if typ == "ACCEPT" then 
			list = {quest.Starts}
			if QUESTIE.correctionsQuestAccept[id] then list = QUESTIE.correctionsQuestAccept[id] end
		elseif typ == "COMPLETE" then
			list = {}
			if quest.ObjectiveData then
				for i = 1, #quest.ObjectiveData do
					list[#list + 1] = quest.ObjectiveData[i]
				end
			end
			if quest.SpecialObjectives then
				for _, v in pairs(quest.SpecialObjectives) do
					list[#list + 1] = v
				end
			end
		elseif typ == "TURNIN" then
			list = {quest.Finisher}
		end
		if list ~= nil then
			--if addon.debugging then print("LIME: getQuestPositionsQuestie " .. typ .. " " .. id .. " " .. #list) end
			for i = 1, #list do
				local oi = (typ == "COMPLETE" and QUESTIE.correctionsObjectiveOrder[id]) and QUESTIE.correctionsObjectiveOrder[id][i] or i
				if index == nil or index == 0 or index == oi then
					if list[i].NPC ~= nil then
						for _, id2 in ipairs(list[i].NPC) do
							table.insert(ids.npc, id2)
							if objectives.npc[id2] == nil then objectives.npc[id2] = {} end
							table.insert(objectives.npc[id2], oi)
						end
					elseif list[i].Type == "monster" or list[i].Type == "item" then
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
		if item ~= nil then
			if item.npcDrops ~= nil then
				for i = 1, #item.npcDrops do
					if not D.contains(ids.npc, item.npcDrops[i]) then table.insert(ids.npc, item.npcDrops[i]) end
					if objectives.npc[item.npcDrops[i]] == nil then objectives.npc[item.npcDrops[i]] = {} end
					for _, c in ipairs(objectives.item[itemId]) do table.insert(objectives.npc[item.npcDrops[i]], c) end
				end
			end
		end
	end
	local npcs = {}
	for _, id in ipairs(ids.npc) do
		table.insert(npcs, {id = id; objectives = objectives.npc[id]})
	end
	return npcs
end

-- returns a type (npc/item/object) and a list of names for quest source / each objective / turn in; e.g. {{type="item", names={"Huge Gnoll Claw", "Hogger"}, ids={item={1931},npc={448}} for id = 176, typ = "COMPLETE"
function QUESTIE.getQuestObjectives(id, typ)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if quest == nil then return end
	if typ == "ACCEPT" then 
		list = {quest.Starts}
		if QUESTIE.correctionsQuestAccept[id] then list = QUESTIE.correctionsQuestAccept[id] end
	elseif typ == "COMPLETE" then
		list = quest.ObjectiveData
	elseif typ == "TURNIN" then
		list = {quest.Finisher}
	else
		return
	end
	--if addon.debugging then print("LIME: getQuestObjectivesQuestie " .. typ .. " " .. id .. " " .. #list) end
	
	local objectives = {}
	for j = 1, #list do
		if list[j].NPC ~= nil then
			for _, npcId in ipairs(list[j].NPC) do
				local objList = {}
				local npc = QuestieDB:GetNPC(npcId)
				if npc ~= nil and not D.contains(objList, npc.name) then table.insert(objList, npc.name) end
				table.insert(objectives, {type = "npc", names = objList, ids = {npc = {npcId}}})
			end
		elseif list[j].Type == "monster" then
			local objList = {}
			if list[j].Name ~= nil then table.insert(objList, list[j].Name) end
			local npc = QuestieDB:GetNPC(list[j].Id)
			if npc ~= nil and not D.contains(objList, npc.name) then table.insert(objList, npc.name) end
			table.insert(objectives, {type = "monster", names = objList, ids = {npc = {list[j].Id}}})
		elseif list[j].Type == "object" then
			local objList = {}
			if list[j].Name ~= nil then table.insert(objList, list[j].Name) end
			local obj = QuestieDB:GetObject(list[j].Id)
			if obj ~= nil and not D.contains(objList, obj.name) then table.insert(objList, obj.name) end
			table.insert(objectives, {type = "object", names = objList, ids = {object = {list[j].Id}}})
		elseif list[j].Type == "item" then
			local objective = {type = "item", ids = {item = {list[j].Id}}, names = {}}
			if list[j].Name ~= nil then table.insert(objective.names, list[j].Name) end
			local item = QuestieDB:GetItem(list[j].Id)
			if item ~= nil then
				if not D.contains(objective.names, item.name) then table.insert(objective.names, item.name) end
				if item.npcDrops ~= nil then
					objective.ids.npc = {}
					for i = 1, #item.npcDrops do
						table.insert(objective.ids.npc, item.npcDrops[i])
						local npc = QuestieDB:GetNPC(item.npcDrops[i])
						if npc ~= nil then
							if not D.contains(objective.names, npc.name) then table.insert(objective.names, npc.name) end
						end
					end
				end
				if item.objectDrops ~= nil then
					objective.ids.object = {}
					for i = 1, #item.objectDrops do
						table.insert(objective.ids.object, item.objectDrops[i])
						local obj = QuestieDB:GetObject(item.objectDrops[i])
						if not D.contains(objective.names, obj.name) then table.insert(objective.names, obj.name) end
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
	if typ == "COMPLETE" and QUESTIE.correctionsObjectiveOrder[id] then
		local objectives2 = {}
		for i, j in ipairs(QUESTIE.correctionsObjectiveOrder[id]) do
			objectives2[i] = objectives[j]
		end
		return objectives2
	end
	return objectives
end

function QUESTIE.getNPCName(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local npc = QuestieDB:GetNPC(id)
	if npc ~= nil then return npc.name end
end

function QUESTIE.getObjectName(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local object = QuestieDB:GetObject(id)
	if object ~= nil then return object.name end
end

function QUESTIE.getItemName(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local item = QuestieDB:GetItem(id)
	if item ~= nil then return item.name end
end

function QUESTIE.getItemProvidedByQuest(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	return quest and quest.sourceItemId > 0 and quest.sourceItemId
end

function QUESTIE.isItemLootable(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local item = QuestieDB:GetItem(id)
	-- lootable according to https://github.com/cmangos/issues/wiki/Item_template#flags
	return item and (D.hasbit(item.flags, 4))
end

function QUESTIE.getQuestItems(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB.GetQuest(id)
	if not quest then return end
	local items
	if quest.sourceItemId > 0 then
		items = {quest.sourceItemId}
	end
	if quest.ObjectiveData then
		for _, o in ipairs(quest.ObjectiveData) do
			if o.Type == "item" and not D.contains(items, o.Id) then
				if not items then items = {o.Id} else table.insert(items, o.Id) end
			end
		end
	end
	if quest.SpecialObjectives then
		for _, o in pairs(quest.SpecialObjectives) do
			if o.Type == "item" and not D.contains(items, o.Id) then
				if not items then items = {o.Id} else table.insert(items, o.Id) end
			end
		end
	end
	return items
end

-- /run Guidelime.addon.QUESTIE.listQuestWithItems()
function QUESTIE.listQuestWithItems()
	local t = ""
    for qid, _ in pairs(QuestieDB.QuestPointers) do
		local items = QUESTIE.getUsableQuestItems(qid)
		if items then
			local quest = QuestieDB.GetQuest(qid)
			t = t .. qid .. ";" .. quest.name
			for _, id in ipairs(items) do
				local item = QuestieDB:GetItem(id)
				t = t .. ";" .. id .. ";" .. item.name
			end
			t = t .. "\n"
		end
	end
	--print(t)
	F.showUrlPopup(t)
end

-- Source: https://github.com/cmangos/issues/wiki/FactionTemplate.dbc
local friendlyFaction = 
{
	[1] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[3] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[4] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[5] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[6] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[7] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[10] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[11] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[12] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[14] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[15] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[16] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[17] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[18] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[19] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[20] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[21] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[22] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[23] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[24] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[25] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[26] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[27] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[28] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[29] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[30] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[31] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[32] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[33] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[34] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[35] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[36] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[37] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[38] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[39] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[40] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[41] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[42] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[43] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[44] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[45] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[46] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[47] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[48] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[49] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[50] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[51] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[52] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[53] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[54] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[55] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[56] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[57] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[58] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[59] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[60] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[61] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[62] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[63] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[64] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[65] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[66] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[67] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[68] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[69] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[70] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[71] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[72] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[73] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[74] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[76] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[77] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[78] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[79] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[80] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[81] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[82] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[83] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[84] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[85] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[86] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[87] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[88] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[89] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[90] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[91] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[92] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[93] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[94] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[95] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[96] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[97] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[98] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[99] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[100] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[101] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[102] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[103] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[104] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[105] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[106] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[107] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[108] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[109] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[110] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[111] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[112] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[113] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[114] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[115] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[116] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[118] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[119] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[120] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[121] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[122] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[123] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[124] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[125] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[126] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[127] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[128] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[129] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[130] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[131] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[132] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[133] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[134] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[149] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[150] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[151] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[152] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[153] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[154] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[168] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[188] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[189] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[190] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[208] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[209] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[210] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[230] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[231] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[232] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[233] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[250] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[270] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[290] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[310] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[311] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[312] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[330] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[350] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[370] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[371] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[390] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[410] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[411] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[412] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[413] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[414] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[415] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[416] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[430] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[450] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[470] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[471] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[472] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[473] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[474] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[475] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[494] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[495] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[514] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[534] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[554] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[574] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[575] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[594] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[614] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[634] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[635] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[636] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[637] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[654] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[655] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[674] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[694] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[695] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[714] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[734] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[735] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[736] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[754] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[774] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[775] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[776] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[777] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[778] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[794] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[795] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[814] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[834] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[854] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[855] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[874] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[875] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[876] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[877] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[894] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[914] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[934] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[954] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[974] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[994] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[995] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[996] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1014] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1015] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1034] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1054] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1055] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1074] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1075] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1076] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1077] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1078] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1080] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1081] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1094] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1096] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1097] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1114] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1134] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1174] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1194] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1214] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1215] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1216] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1217] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1234] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1235] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1236] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1254] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1274] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1275] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1294] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1314] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1315] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1334] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1335] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1354] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1355] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1374] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1375] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1394] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1395] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1414] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1415] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1434] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1454] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1474] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1475] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1494] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1495] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1496] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1514] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1515] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1534] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1554] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1555] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1574] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1575] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1576] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1577] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1594] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1595] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1598] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1599] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1600] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1601] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1602] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1603] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1604] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1605] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1606] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1608] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1610] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1611] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1612] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1613] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1615] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1616] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1617] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1618] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1619] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1620] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1621] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1622] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1623] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1624] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1625] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1626] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1627] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1628] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1629] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1630] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1634] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1635] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1636] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1637] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1638] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1639] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1640] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1641] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1642] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1643] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1644] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1645] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1648] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1649] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1650] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1651] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1652] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1653] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1654] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1655] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1659] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1660] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1661] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1662] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1663] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1664] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1665] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1666] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1667] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1668] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1669] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1670] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1671] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1672] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1673] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1674] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1675] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1676] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1677] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1678] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1679] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1680] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1681] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1682] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1683] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1684] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1685] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1686] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1687] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1688] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1689] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1690] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1691] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1692] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1693] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1694] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1696] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1697] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1698] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1699] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1700] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1701] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1702] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1704] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1705] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1706] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1707] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1708] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1709] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1710] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1711] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1712] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1713] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1714] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1715] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1716] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1717] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1718] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1719] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1720] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1721] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1722] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1723] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1724] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1725] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1726] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1727] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1728] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1729] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1730] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1731] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1732] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1733] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1734] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1735] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1736] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1737] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1738] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1739] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1740] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1741] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1742] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1743] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1744] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1745] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1746] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1747] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1748] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1749] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1750] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1751] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1752] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1753] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1754] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1755] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1756] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1757] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1758] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1759] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1760] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1761] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1762] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1763] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1764] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1765] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1766] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1767] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1768] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1769] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1770] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1771] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1772] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1773] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1774] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1775] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1776] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1777] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1778] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1779] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1780] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1781] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1782] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1783] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1784] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1787] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1788] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1789] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1790] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1791] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1792] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1793] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1794] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1795] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1796] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1797] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1798] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1799] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1800] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1801] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1802] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1803] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1804] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1805] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1806] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1807] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1808] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1809] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1810] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1811] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1812] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1813] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1814] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1815] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1816] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1818] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1819] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1820] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1821] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1822] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1823] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1824] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1825] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1826] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1827] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1828] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1829] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1830] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1831] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1832] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1833] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1834] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1835] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1836] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1837] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1838] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1839] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1840] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1841] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1842] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1843] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1844] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1845] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1846] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1847] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1848] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1849] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1850] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1851] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1852] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1853] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1854] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1855] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1856] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1857] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1858] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1859] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1860] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1862] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1863] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1864] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1865] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1866] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1867] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1868] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1869] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1870] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1871] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1872] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1873] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1874] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1875] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1876] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1877] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1878] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1879] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1880] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1881] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1882] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1883] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1884] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1885] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1886] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1887] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1888] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1889] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1890] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1891] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1892] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1893] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1894] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1895] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1896] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1897] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1898] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1899] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1900] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1901] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1902] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1905] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1906] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1907] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1908] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1909] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1910] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1911] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1912] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1913] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1914] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1915] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1916] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1917] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1918] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1919] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1920] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1921] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1922] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1923] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1924] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1925] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1926] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1927] = {Horde = 'Hostile', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1928] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1929] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1930] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1931] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1932] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1933] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1934] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1935] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1936] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1942] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1945] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1948] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Hostile'},
	[1949] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1950] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1951] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1952] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1953] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1954] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1955] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1956] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1958] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1959] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1960] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1961] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1962] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1963] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1964] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1965] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1966] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1967] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1968] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1969] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1970] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1971] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1972] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1973] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1974] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1975] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1976] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1977] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1978] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1979] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1980] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1981] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1982] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1983] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1984] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1985] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1986] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1987] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1988] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1989] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1990] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1991] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1992] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1993] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1994] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1995] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1997] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1998] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1999] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2000] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2001] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2003] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2004] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2006] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2007] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2008] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2009] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2010] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2011] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2012] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2013] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2014] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2016] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2017] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2018] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2019] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2020] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2021] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2022] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2023] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2024] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2025] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2026] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2027] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2028] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2029] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2031] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2032] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2033] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2034] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2035] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2036] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2037] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2038] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2039] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2040] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2041] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2042] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2043] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2044] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2045] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2046] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2047] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2048] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2049] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2050] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2051] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2052] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2053] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2054] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2055] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2056] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2057] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2058] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2059] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2060] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2061] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2062] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2063] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2064] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2065] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2066] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2067] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2068] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2069] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2070] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2071] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2072] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2073] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2074] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2075] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2076] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2077] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2078] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2080] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2081] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2082] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2083] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2084] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2085] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2086] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2087] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2088] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2089] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2090] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2091] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2092] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2093] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2095] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2096] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2098] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2099] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2100] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2101] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2102] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2103] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2104] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2105] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2106] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2107] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2108] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2109] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2110] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2111] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2112] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2113] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2114] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2115] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2116] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2117] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2118] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2119] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2120] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2121] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2122] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2123] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2124] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2125] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2126] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2127] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2128] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2129] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2130] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2131] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2132] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2133] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2134] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2135] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2136] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2137] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2138] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2139] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2140] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2141] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2142] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2143] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2144] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2145] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2146] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2147] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2148] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2149] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2150] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2151] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2152] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2153] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2154] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2155] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2156] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2157] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2158] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2159] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2161] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2162] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2163] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2164] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2165] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2166] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2167] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2168] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2169] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2170] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2171] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2172] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2173] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2174] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2175] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2176] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2178] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2179] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2180] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2181] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2182] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2183] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2184] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2185] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2186] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2187] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2189] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2190] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2191] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2200] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2201] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2202] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2203] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2204] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2205] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2206] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2207] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2208] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2209] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2210] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2211] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2212] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2213] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2214] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2215] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2216] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2217] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2218] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2219] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2220] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2221] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2222] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2223] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2224] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2225] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2226] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2227] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2228] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2229] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2230] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2231] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2232] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2233] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2234] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2235] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2236] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2237] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2238] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2239] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2240] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2241] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2242] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2243] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2244] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2245] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2246] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2247] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2248] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2249] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2250] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2251] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2252] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2253] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2254] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2255] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2256] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2257] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2258] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2259] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2260] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2261] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2262] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2263] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2264] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2265] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2266] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2267] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2268] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2269] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2270] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2271] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2272] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2273] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2274] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2275] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2276] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2277] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2278] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2279] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2280] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2281] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2282] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2283] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2284] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2285] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2286] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2287] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2288] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2289] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2290] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2291] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2292] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2293] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2294] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2295] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2296] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2297] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2298] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2299] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2300] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2301] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2302] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2303] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2304] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2305] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2306] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2307] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2308] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2309] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2310] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2311] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2312] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2313] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2314] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2316] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2317] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2318] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2319] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2320] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2321] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2322] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2323] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2324] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2325] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2326] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2327] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2328] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2330] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2331] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2332] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2333] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2334] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2335] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2336] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2337] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2338] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2339] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2340] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2341] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2342] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2343] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2344] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2345] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2346] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2347] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2348] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2349] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2350] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2351] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2352] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2353] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2354] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2355] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2356] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2357] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2358] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2359] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2360] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2361] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2362] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2363] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2364] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2365] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2366] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2367] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2369] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2371] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2372] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2373] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2374] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2375] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2376] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2377] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2378] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2379] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2381] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2382] = {Horde = 'Neutral', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2383] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2384] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2385] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2386] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2387] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2388] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2389] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2390] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2391] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2392] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2393] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2394] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2395] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2399] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2400] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2468] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2476] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2477] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2478] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2479] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2480] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2481] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2482] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2483] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2484] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2485] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2486] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2487] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2488] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2489] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2490] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2491] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2492] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2493] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2497] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2498] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2501] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2502] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2503] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2504] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2505] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2533] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2548] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2550] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2551] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2552] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2553] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2554] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2556] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2557] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2558] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2559] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2560] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2561] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2562] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2563] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2564] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2565] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2566] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2568] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2569] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2570] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2573] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2574] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2575] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2576] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2577] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2578] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2579] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2580] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2581] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2585] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2587] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2588] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2590] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2591] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2592] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2593] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2594] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2595] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2596] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2597] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2598] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2600] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2602] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2603] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2604] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2605] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2606] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2607] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2608] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2609] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2611] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2612] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2614] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2618] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2622] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2623] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2624] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2625] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2626] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2628] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2629] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2630] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2633] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2634] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2635] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2637] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2638] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2639] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2640] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2641] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2642] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2643] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2648] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2649] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2650] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2659] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2660] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2661] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2662] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2663] = {Horde = 'Friendly', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2664] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2665] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2666] = {Horde = 'Neutral', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2667] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2668] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2669] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2673] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2675] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2676] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2677] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2684] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2685] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2686] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2687] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[2688] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[3149] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[3150] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[3151] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[3152] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[3501] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2401] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[148] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1614] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1786] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1095] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1703] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2097] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1154] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1597] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1596] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1657] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1656] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1658] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1695] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1607] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2402] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[1647] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1646] = {Horde = 'Hostile', Alliance = 'Friendly', Neutral = 'Neutral'},
	[1785] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1904] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[1937] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1938] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1939] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1940] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1941] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1943] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1944] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[1947] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[1957] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'},
	[2621] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2005] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2030] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2079] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2094] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2370] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2636] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2160] = {Horde = 'Friendly', Alliance = 'Hostile', Neutral = 'Neutral'},
	[2188] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2315] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2329] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[2599] = {Horde = 'Hostile', Alliance = 'Hostile', Neutral = 'Hostile'},
	[2646] = {Horde = 'Friendly', Alliance = 'Friendly', Neutral = 'Friendly'},
	[3564] = {Horde = 'Neutral', Alliance = 'Neutral', Neutral = 'Neutral'}
}

function QUESTIE.isFriendlyNpc(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local npc = QuestieDB:GetNPC(id)
	return (npc and npc.friendlyToFaction and string.match(npc.friendlyToFaction, string.sub(D.faction, 1, 1)) and 'Friendly') or
		(npc and npc.factionID and friendlyFaction[npc.factionID] and friendlyFaction[npc.factionID][D.faction]) or
		'Neutral'
end
