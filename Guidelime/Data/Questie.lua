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

local function check()
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
	if id == nil or not check() then return false end
	return QuestieDB:GetQuest(id) ~= nil
end

function QUESTIE.getQuestName(id)
	if id == nil or not check() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.name
end

function QUESTIE.getQuestSort(id)
	if id == nil or not check() then return end
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
	if id == nil or not check() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.preQuestSingle or quest.preQuestGroup
end

function QUESTIE.getQuestOneOfPrequests(id)
	if id == nil or not check() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.preQuestSingle ~= nil
end

function QUESTIE.getQuestType(id)
	if id == nil or not check() then return end
	if QuestieDB.IsDungeonQuest(id) then return "Dungeon" end
	if QuestieDB.IsRaidQuest(id) then return "Raid" end
	if QuestieDB.GetQuestTagInfo(id) == 1 then return "Group" end
	local _, _, _, _, _, isElite = GetQuestTagInfo(id)
	if isElite then return "Elite" end
end

function QUESTIE.getQuestLevel(id)
	if id == nil or not check() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.questLevel
end

function QUESTIE.getQuestMinimumLevel(id)
	if id == nil or not check() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.requiredLevel
end

function QUESTIE.getQuestNext(id)
	if id == nil or not check() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.nextQuestInChain
end

function QUESTIE.getQuestRaces(id)
	if id == nil or not check() then return end
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
	if id == nil or not check() then return end
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
	if id == nil or not check() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	local bitmask = quest.requiredRaces
	if bitmask == nil then return end
	if bitmask == 77 or bitmask == 1101 then return "Alliance" end
	if bitmask == 178 or bitmask == 690 then return "Horde" end
end

function QUESTIE.getQuestObjective(id)
	if id == nil or not check() then return end
	local quest = QuestieDB:GetQuest(id)
	if quest == nil then return end
	return quest.objectivesText[1]
end

function QUESTIE.getQuestReputation(id)
	if id == nil or not check() then return end
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
	if id == nil or not check() then return end
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
	if id == nil or not check() then return end
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
	if id == nil or not check() then return end
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
	if id == nil or not check() then return end
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
	if id == nil or not check() then return end
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
	if id == nil or not check() then return end
	local npc = QuestieDB:GetNPC(id)
	if npc ~= nil then return npc.name end
end

function QUESTIE.getObjectName(id)
	if id == nil or not check() then return end
	local object = QuestieDB:GetObject(id)
	if object ~= nil then return object.name end
end

function QUESTIE.getItemName(id)
	if id == nil or not check() then return end
	local item = QuestieDB:GetItem(id)
	if item ~= nil then return item.name end
end

function QUESTIE.getItemProvidedByQuest(id)
	if id == nil or not check() then return end
	local quest = QuestieDB:GetQuest(id)
	return quest and quest.sourceItemId > 0 and quest.sourceItemId
end

function QUESTIE.isItemLootable(id)
	if id == nil or not check() then return end
	local item = QuestieDB:GetItem(id)
	-- lootable according to https://github.com/cmangos/issues/wiki/Item_template#flags
	return item and (D.hasbit(item.flags, 4))
end

function QUESTIE.getQuestItems(id)
	if id == nil or not check() then return end
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


