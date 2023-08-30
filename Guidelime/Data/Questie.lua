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
	return QuestieDB:GetQuest(id) ~= nil
end

function QUESTIE.getQuestName(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.name
end

function QUESTIE.getQuestSort(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB:GetQuest(id)
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
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.preQuestSingle or quest.preQuestGroup
end

function QUESTIE.getQuestOneOfPrequests(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB:GetQuest(id)
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
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.questLevel
end

function QUESTIE.getQuestMinimumLevel(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.requiredLevel
end

function QUESTIE.getQuestNext(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.nextQuestInChain
end

function QUESTIE.getQuestRaces(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	local bitmask = quest.requiredRaces
	if bitmask == nil or bitmask == 0 then return end
	local races = {}
	for i, race in ipairs({"Human", "Orc", "Dwarf", "NightElf", "Undead", "Troll", "Gnome", "Tauren", "", "BloodElf", "Draenei"}) do
		if race ~= "" and D.hasbit(bitmask, D.bit(i)) then 
			table.insert(races, race) 
		end
	end
	return races
end

function QUESTIE.getQuestClasses(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	local bitmask = quest.requiredClasses
	if bitmask == nil or bitmask == 0 then return end
	local classes = {}
	for i, class in pairs({"Warrior", "Paladin", "Hunter", "Rogue", "Priest", "DeathKnight", "Shaman", "Mage", "Warlock", "", "Druid"}) do
		if class ~= "" and D.hasbit(bitmask, D.bit(i)) then 
			table.insert(classes, class) 
		end
	end
	return classes
end

function QUESTIE.getQuestFaction(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	local bitmask = quest.requiredRaces
	if bitmask == nil then return end
	if bitmask == 77 or bitmask == 1101 then return "Alliance" end
	if bitmask == 178 or bitmask == 690 then return "Horde" end
end

function QUESTIE.getQuestObjective(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.objectivesText[1]
end

function QUESTIE.getQuestReputation(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
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

function QUESTIE.getQuestPositions(id, typ, index, filterZone)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	if index == 0 then index = nil end
	if type(index) == "number" then index = {index} end
	local ids = {npc = {}, object = {}, item = {}}
	local objectives = {npc = {}, object = {}, item = {}}
	local positions = {}
	local filterZoneId = filterZone and DM.mapIDs[filterZone] and ZoneDB:GetAreaIdByUiMapId(DM.mapIDs[filterZone])
	local specialObjectivesIndex
	if GP.getSuperCode(typ) == "QUEST" then
		local quest = QuestieDB:GetQuest(id)
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
								for _, pos in ipairs(posList) do
									table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, objectives = {oi}})
								end
							end
						elseif list[i].Coordinates[filterZoneId] ~= nil then
							for _, pos in ipairs(list[i].Coordinates[filterZoneId]) do
								table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, objectives = {oi}})
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
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, npcId = npcId, objectives = objectives.npc[npcId]})
					end
				end
			elseif npc.spawns[filterZoneId] ~= nil then
				for _, pos in ipairs(npc.spawns[filterZoneId]) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, npcId = npcId, objectives = objectives.npc[npcId]})
				end
			end
		end
		if npc ~= nil and npc.waypoints ~= nil then
			if filterZone == nil then
				for zone, pathList in pairs(npc.waypoints) do
					for _, posList in ipairs(pathList) do
						for _, pos in ipairs(posList) do
							table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, npcId = npcId, objectives = objectives.npc[npcId]})
						end
					end
				end
			elseif npc.waypoints[filterZoneId] ~= nil then
				for _, posList in ipairs(npc.waypoints[filterZoneId]) do
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, npcId = npcId, objectives = objectives.npc[npcId]})
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
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, objectId = objectId, objectives = objectives.object[objectId]})
					end
				end
			elseif object.spawns[filterZoneId] ~= nil then
				for _, pos in ipairs(object.spawns[filterZoneId]) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = filterZone, objectId = objectId, objectives = objectives.object[objectId]})
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
			pos.mapID = DM.mapIDs[pos.zone]
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
				for _, pos in ipairs(posList) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, npcId = npcId})
				end
			end
		end
		if npc ~= nil and npc.waypoints ~= nil then
			for zone, pathList in pairs(npc.waypoints) do
				for _, posList in ipairs(pathList) do
					for _, pos in ipairs(posList) do
						table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, npcId = npcId})
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
				for _, pos in ipairs(posList) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, objectId = objectId})
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
			pos.mapID = DM.mapIDs[pos.zone]
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
			for _, pos in ipairs(posList) do
				table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, npcId = id})
			end
		end
	end
	if npc ~= nil and npc.waypoints ~= nil then
		for zone, pathList in pairs(npc.waypoints) do
			for _, posList in ipairs(pathList) do
				for _, pos in ipairs(posList) do
					table.insert(positions, {x = pos[1], y = pos[2], zone = DM.zoneNames[ZoneDB:GetUiMapIdByAreaId(zone)] or zone, npcId = id})
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
			pos.mapID = DM.mapIDs[pos.zone]
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
		local quest = QuestieDB:GetQuest(id)
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
	local quest = QuestieDB:GetQuest(id)
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
	local quest = QuestieDB:GetQuest(id)
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
	local quest = QuestieDB:GetQuest(id)
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
			local quest = QuestieDB:GetQuest(qid)
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
	[1] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[3] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[4] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[5] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[6] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[7] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[10] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[11] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[12] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[14] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[15] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[16] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[17] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[18] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[19] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[20] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[21] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[22] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[23] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[24] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[25] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[26] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[27] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[28] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[29] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[30] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[31] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[32] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[33] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[34] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[35] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[36] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[37] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[38] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[39] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[40] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[41] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[42] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[43] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[44] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[45] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[46] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[47] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[48] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[49] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[50] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[51] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[52] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[53] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[54] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[55] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[56] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[57] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[58] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[59] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[60] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[61] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[62] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[63] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[64] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[65] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[66] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[67] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[68] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[69] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[70] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[71] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[72] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[73] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[74] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[76] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[77] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[78] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[79] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[80] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[81] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[82] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[83] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[84] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[85] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[86] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[87] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[88] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[89] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[90] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[91] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[92] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[93] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[94] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[95] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[96] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[97] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[98] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[99] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[100] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[101] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[102] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[103] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[104] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[105] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[106] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[107] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[108] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[109] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[110] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[111] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[112] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[113] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[114] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[115] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[116] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[118] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[119] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[120] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[121] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[122] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[123] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[124] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[125] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[126] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[127] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[128] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[129] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[130] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[131] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[132] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[133] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[134] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[148] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[149] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[150] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[151] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[152] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[153] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[154] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[168] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[188] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[189] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[190] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[208] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[209] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[210] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[230] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[231] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[232] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[233] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[250] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[270] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[290] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[310] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[311] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[312] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[330] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[350] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[370] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[371] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[390] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[410] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[411] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[412] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[413] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[414] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[415] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[416] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[430] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[450] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[470] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[471] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[472] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[473] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[474] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[475] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[494] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[495] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[514] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[534] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[554] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[574] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[575] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[594] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[614] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[634] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[635] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[636] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[637] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[654] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[655] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[674] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[694] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[695] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[714] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[734] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[735] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[736] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[754] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[774] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[775] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[776] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[777] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[778] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[794] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[795] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[814] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[834] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[854] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[855] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[874] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[875] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[876] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[877] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[894] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[914] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[934] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[954] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[974] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[994] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[995] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[996] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1014] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1015] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1034] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[1054] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1055] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1074] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1075] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1076] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1077] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1078] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1080] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1081] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1094] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1095] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1096] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1097] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1114] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1134] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1154] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1174] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1194] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1214] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1215] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1216] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1217] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1234] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1235] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1236] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1254] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1274] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[1275] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[1294] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1314] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1315] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1334] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1335] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1354] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1355] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1374] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1375] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1394] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1395] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1414] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[1415] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[1434] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1454] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1474] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1475] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1494] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1495] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1496] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1514] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1515] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1534] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1554] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[1555] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1574] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1575] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1576] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1577] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1594] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1595] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1596] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1597] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1598] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1599] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1600] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[1601] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1602] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1603] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1604] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1605] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1606] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1607] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1608] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1610] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1611] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1612] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1613] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1614] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1615] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1616] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1617] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1618] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1619] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1620] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1621] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[1622] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[1623] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1624] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1625] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1626] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1627] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1628] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1629] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1630] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1634] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1635] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1636] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1637] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1638] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1639] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1640] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1641] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1642] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1643] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1644] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1645] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1646] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1647] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1648] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1649] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1650] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1651] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1652] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1653] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1654] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1655] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1656] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1657] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1658] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1659] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1660] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1661] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1662] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1663] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1664] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1665] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1666] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1667] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1668] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1669] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1670] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1671] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1672] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1673] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1674] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1675] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1676] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1677] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1678] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1679] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1680] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1681] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1682] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1683] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1684] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1685] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[1686] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1687] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1688] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1689] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1690] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1691] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1692] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1693] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1694] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1695] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1696] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1697] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1698] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1699] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1700] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1701] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1702] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1703] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1704] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1705] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1706] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1707] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1708] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1709] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1710] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1711] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1712] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1713] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1714] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1715] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1716] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1717] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1718] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1719] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1720] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1721] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1722] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1723] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1724] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1725] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1726] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1727] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1728] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1729] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1730] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1731] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1732] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1733] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1734] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1735] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1736] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1737] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1738] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1739] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1740] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1741] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1742] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1743] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1744] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1745] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1746] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1747] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1748] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1749] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1750] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1751] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1752] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1753] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1754] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1755] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[1756] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[1757] = {Horde = 'Neutral', Alliance = 'Friendly'},
	[1758] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[1759] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[1760] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[1761] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1762] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1763] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1764] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1765] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1766] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1767] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1768] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1769] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1770] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1771] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1772] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1773] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1774] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1775] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1776] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1777] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1778] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1779] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1780] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1781] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1782] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1783] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1784] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1785] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1786] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1787] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1788] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1789] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1790] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1791] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1792] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1793] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1794] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1795] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1796] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1797] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1798] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1799] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1800] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1801] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1802] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1803] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[1804] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[1805] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1806] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1807] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1808] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1809] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1810] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1811] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1812] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1813] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1814] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1815] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1816] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1818] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1819] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1820] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1821] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1822] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1823] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1824] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1825] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1826] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1827] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1828] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1829] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1830] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1831] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1832] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1833] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1834] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1835] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1836] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1837] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1838] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1839] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1840] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1841] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1842] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1843] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1844] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1845] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1846] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1847] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1848] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1849] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1850] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1851] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1852] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1853] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1854] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1855] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1856] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1857] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1858] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1859] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1860] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1862] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1863] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1864] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1865] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1866] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1867] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1868] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1869] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1870] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1871] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1872] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1873] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1874] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1875] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1876] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1877] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1878] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1879] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1880] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1881] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1882] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1883] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1884] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1885] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1886] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1887] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1888] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1889] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1890] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1891] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1892] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1893] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1894] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1895] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1896] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1897] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1898] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1899] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1900] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1901] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1902] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1904] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1905] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1906] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1907] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1908] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1909] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1910] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1911] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1912] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1913] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1914] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1915] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1916] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1917] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1918] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1919] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1920] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[1921] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1922] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1923] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1924] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1925] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1926] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[1927] = {Horde = 'Hostile', Alliance = 'Neutral'},
	[1928] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[1929] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[1930] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1931] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1932] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1933] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[1934] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1935] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1936] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1937] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1938] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1939] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1940] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1941] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1942] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1943] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1944] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1945] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1947] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1948] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1949] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1950] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1951] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1952] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1953] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1954] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1955] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1956] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1957] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1958] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1959] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1960] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1961] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1962] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1963] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1964] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1965] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1966] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1967] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1968] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1969] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1970] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1971] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1972] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1973] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1974] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1975] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1976] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1977] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1978] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[1979] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[1980] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[1981] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[1982] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1983] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1984] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1985] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1986] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[1987] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[1988] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1989] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1990] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1991] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1992] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1993] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1994] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1995] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[1997] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[1998] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[1999] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2000] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2001] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2003] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2004] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2005] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2006] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2007] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2008] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2009] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2010] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2011] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2012] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2013] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2014] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2016] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2017] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2018] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2019] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2020] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2021] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2022] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2023] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2024] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[2025] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2026] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2027] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2028] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2029] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2030] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2031] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[2032] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2033] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2034] = {Horde = 'Neutral', Alliance = 'Hostile'},
	[2035] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2036] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2037] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2038] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2039] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2040] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2041] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2042] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2043] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2044] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2045] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2046] = {Horde = 'Friendly', Alliance = 'Neutral'},
	[2047] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2048] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2049] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2050] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2051] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2052] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2053] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2054] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2055] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2056] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2057] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2058] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2059] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2060] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2061] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2062] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2063] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2064] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2065] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2066] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2067] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2068] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2069] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2070] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2071] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2072] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2073] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2074] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2075] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2076] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2077] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2078] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2079] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2080] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2081] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2082] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2083] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2084] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2085] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2086] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2087] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2088] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2089] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2090] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2091] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2092] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2093] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2094] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2095] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2096] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2097] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2098] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2099] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2100] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2101] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2102] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2103] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2104] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2105] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2106] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2107] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2108] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2109] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2110] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2111] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2112] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2113] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2114] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2115] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2116] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2117] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2118] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2119] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2120] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2121] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2122] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2123] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2124] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2125] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2126] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2127] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2128] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2129] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2130] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2131] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2132] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2133] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2134] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2135] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2136] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2137] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2138] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2139] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2140] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2141] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2142] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2143] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2144] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2145] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2148] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2150] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2155] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2156] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2176] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2178] = {Horde = 'Hostile', Alliance = 'Friendly'},
	[2189] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2190] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2191] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2209] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2210] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2212] = {Horde = 'Hostile', Alliance = 'Hostile'},
	[2214] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2216] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2217] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2218] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2219] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2226] = {Horde = 'Friendly', Alliance = 'Friendly'},
	[2230] = {Horde = 'Neutral', Alliance = 'Neutral'},
	[2235] = {Horde = 'Friendly', Alliance = 'Hostile'},
	[2236] = {Horde = 'Hostile', Alliance = 'Friendly'}
}

function QUESTIE.isFriendlyNpc(id)
	if id == nil or not QUESTIE.isDataSourceReady() then return end
	local npc = QuestieDB:GetNPC(id)
	return npc and npc.factionID and friendlyFaction[npc.factionID] and friendlyFaction[npc.factionID][D.faction] or 'Neutral'
end
