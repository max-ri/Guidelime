local addonName, addon = ...
local L = addon.L

addon.D = addon.D or {}; local D = addon.D                                                 -- Data/Data
addon.DM = addon.DM or {}; local DM = addon.DM                                             -- Data/MapDB
addon.QUESTIE = addon.QUESTIE or {}; local QUESTIE = addon.QUESTIE                         -- Data/Questie
addon.CLASSIC_CODEX = addon.CLASSIC_CODEX or {}; local CLASSIC_CODEX = addon.CLASSIC_CODEX -- Data/ClassicCodex
addon.DB = addon.DB or {}; local DB = addon.DB                                             -- Data/Internal
addon.PT = addon.PT or {}; local PT = addon.PT                                             -- Data/PositionTools
addon.CG = addon.CG or {}; local CG = addon.CG                                             -- CurrentGuide
addon.GP = addon.GP or {}; local GP = addon.GP                                             -- GuideParser

addon.QT = addon.QT or {}; local QT = addon.QT                                             -- Data/QuestTools

local LIMIT_CENTER_POSITION = 400
local LIMIT_POSITIONS = 1000

function QT.GetQuestsCompleted()
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

function QT.GetItemCooldown(id)
	if GetItemCooldown ~= nil then return GetItemCooldown(id) end
	return C_Container.GetItemCooldown(id)
end

function QT.resetCachedQuestData()
	QT.questPosition = nil
	QT.questObjectives = nil
	QT.questsDBReverse = nil
	QT.npcNames = nil
	QT.itemNames = nil
	QT.objectNames = nil
	QT.useItemTooltips = {}
end

function QT.isQuestId(id)
	if id == nil then return false end
	if addon.dataSource == "QUESTIE" then return QUESTIE.isQuestId(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.isQuestId(id) end
	return DB.questsDB[id] ~= nil
end

function QT.getQuestReplacement(id)
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].replacement end
end

function QT.getQuestSort(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestSort(id) end
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].sort end
end

-- this function intentionally only uses internal database instead of selected data source
-- this is used in parsing guides and guides should not parse with errors or not depending on data source used
function QT.getQuestZone(id)
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].zone end
end

function QT.getQuestPrequests(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestPrequests(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestPrequests(id) end
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].prequests end
end

function QT.getQuestOneOfPrequests(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestOneOfPrequests(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestOneOfPrequests(id) end
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].oneOfPrequests end
end

function QT.getQuestType(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestType(id) end
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].type end
end

function QT.getQuestLevel(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestLevel(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestLevel(id) end
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].level end
end

function QT.getQuestMinimumLevel(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestMinimumLevel(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestMinimumLevel(id) end
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].req	end
end

function QT.getQuestSeries(id)
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].series end
end

function QT.getQuestNext(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestNext(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestNext(id) end
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].next end
end

function QT.getQuestPrev(id)
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].prev end
end

function QT.getQuestRaces(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestRaces(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestRaces(id) end
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].races end
end

function QT.getQuestClasses(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestClasses(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestClasses(id) end
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].classes end
end

function QT.getQuestFaction(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestFaction(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestFaction(id) end
	if DB.questsDB[id] ~= nil then return DB.questsDB[id].faction end
end

function QT.getQuestIDs()
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestIDs(id) end
	local ids = {}
	for id, q in pairs(DB.questsDB) do
		table.insert(ids, id)
	end
	return ids
end

function QT.getQuestApplies(id)
	return D.applies({races = QT.getQuestRaces(id), classes = QT.getQuestClasses(id), faction = QT.getQuestFaction(id)})
end

function QT.getQuestNameById(id)
	if id == nil then return nil end
	if CG.quests ~= nil and CG.quests[id] ~= nil and CG.quests[id].name ~= nil then
		return CG.quests[id].name
	end
	if C_QuestLog.GetQuestInfo(id) ~= nil then return C_QuestLog.GetQuestInfo(id) end
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestName(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestName(id) end
	local locale = GetLocale()
	if DB.questsDB[id] == nil then
		return nil
	elseif DB["questsDB_" .. locale] ~= nil and DB["questsDB_" .. locale][id] ~= nil and DB["questsDB_" .. locale][id].name ~= nil then
		return DB["questsDB_" .. locale][id].name
	elseif locale == "zhTW" and DB.questsDB_zhCN ~= nil and DB.questsDB_zhCN[id] ~= nil and DB.questsDB_zhCN[id].name ~= nil then
		return DB.questsDB_zhCN[id].name
	else
		return DB.questsDB[id].name
	end
end

function QT.getQuestObjective(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestObjective(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestObjective(id) end
	local locale = GetLocale()
	if id == nil or DB.questsDB[id] == nil then
		return
	elseif DB["questsDB_" .. locale] ~= nil and DB["questsDB_" .. locale][id] ~= nil and DB["questsDB_" .. locale][id].objective ~= nil then
		return DB["questsDB_" .. locale][id].objective
	elseif locale == "zhTW" and DB.questsDB_zhCN ~= nil and DB.questsDB_zhCN[id] ~= nil and DB.questsDB_zhCN[id].objective ~= nil then
		return DB.questsDB_zhCN[id].objective
	else
		return DB.questsDB[id].objective
	end
end

function QT.getQuestReputation(id)
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestReputation(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestReputation(id) end
end

-- returns a type (npc/item/object) and a list of names for quest source / each objective / turn in; e.g. {{type="item", names={"Huge Gnoll Claw", "Hogger"}, ids={item={1931},npc={448}} for id = 176, typ = "COMPLETE"
function QT.getQuestObjectives(id, typ)
	if id == nil then return end
	if typ == nil then typ = "COMPLETE" end
	if QT.questObjectives == nil then QT.questObjectives = {} end
	if QT.questObjectives[id] == nil then QT.questObjectives[id] = {} end
	if QT.questObjectives[id][typ] == nil and addon.dataSource == "QUESTIE" then QT.questObjectives[id][typ] = QUESTIE.getQuestObjectives(id, typ) end
	if QT.questObjectives[id][typ] == nil and addon.dataSource == "CLASSIC_CODEX" then QT.questObjectives[id][typ] = CLASSIC_CODEX.getQuestObjectives(id, typ) end
	if QT.questObjectives[id][typ] == nil and DB.questsDB[id] ~= nil then
		local locale = GetLocale()
		local ids = {}
		local objectives = {}
		if typ == "ACCEPT" then 
			if DB.questsDB[id].source ~= nil then
				for i, e in ipairs(DB.questsDB[id].source) do
					objectives[i] = {type = e.type, ids = {[e.type] = {e.id}}}
				end
			end
		elseif typ == "TURNIN" then
			if DB.questsDB[id].deliver ~= nil then
				for i, e in ipairs(DB.questsDB[id].deliver) do
					objectives[i] = {type = e.type, ids = {[e.type] = {e.id}}}
				end
			end
		elseif typ == "COMPLETE" then
			local c = 1
			if DB.questsDB[id].kill ~= nil then
				for i, id in ipairs(DB.questsDB[id].kill) do
					objectives[c] = {type = "monster", ids = {npc = {id}}}
					c = c + 1
				end
			end
			if DB.questsDB[id].interact ~= nil then
				for i, id in ipairs(DB.questsDB[id].interact) do
					objectives[c] = {type = "object", ids = {object = {id}}}
					ids[c] = {object = {id}}
					c = c + 1
				end
			end
			if DB.questsDB[id].gather ~= nil then
				for i, id in ipairs(DB.questsDB[id].gather) do
					objectives[c] = {type = "item", ids = {item = {id}}}
					c = c + 1
				end
			end
		end
		for i, objective in ipairs(objectives) do
			objective.names = {}
			if objective.ids.item ~= nil then
				for _, itemId in ipairs(objective.ids.item) do
					if DB["itemsDB_" .. locale] ~= nil and DB["itemsDB_" .. locale][itemId] ~= nil then
						table.insert(objective.names, DB["itemsDB_" .. locale][itemId])
					end
					local item = DB.itemsDB[itemId]
					if item ~= nil then
						if not D.contains(objective.names, item.name) then table.insert(objective.names, item.name) end
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
					if DB["creaturesDB_" .. locale] ~= nil and DB["creaturesDB_" .. locale][npcId] ~= nil then
						if not D.contains(objective.names, DB["creaturesDB_" .. locale][npcId]) then table.insert(objective.names, DB["creaturesDB_" .. locale][npcId]) end
					end
					local creature = DB.creaturesDB[npcId]
					if creature ~= nil then
						if not D.contains(objective.names, creature.name) then table.insert(objective.names, creature.name) end
					end
				end
			end
			if objective.ids.object ~= nil then
				for _, objectId in ipairs(objective.ids.object) do
					if DB["objectsDB_" .. locale] ~= nil and DB["objectsDB_" .. locale][objectId] ~= nil then
						if not D.contains(objective.names, DB["objectsDB_" .. locale][objectId]) then table.insert(objective.names, DB["objectsDB_" .. locale][objectId]) end
					end
					local object = DB.objectsDB[objectId]
					if object ~= nil then
						if not D.contains(objective.names, object.name) then table.insert(objective.names, object.name) end
					end
				end
			end
		end	
		QT.questObjectives[id][typ] = objectives
	end
	return QT.questObjectives[id][typ]
end

function QT.getQuestPositions(id, typ, objective, filterZone)
	if id == nil then return end
	if type(objective) == "number" then objective = {objective} end
	if D.contains(objective, 0) then objective = nil end
	if addon.dataSource == "QUESTIE" then return QUESTIE.getQuestPositions(id, typ, objective, filterZone) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getQuestPositions(id, typ, objective, filterZone) end
	if GP.getSuperCode(typ) == "QUEST" and DB.questsDB[id] == nil then return end
	--local time
	--if addon.debugging then time = debugprofilestop() end
	local ids = {npc = {}, object = {}, item = {}}
	local objectives = {npc = {}, object = {}, item = {}}
	if typ == "ACCEPT" then 
		if DB.questsDB[id].source ~= nil then
			for i, e in ipairs(DB.questsDB[id].source) do
				if objective == nil or D.contains(objective, i) then
					table.insert(ids[e.type], e.id)
					if objectives[e.type][e.id] == nil then objectives[e.type][e.id] = {} end
					table.insert(objectives[e.type][e.id], i)
				end
			end
		end
	elseif typ == "TURNIN" then
		if DB.questsDB[id].deliver ~= nil then
			for i, e in ipairs(DB.questsDB[id].deliver) do
				if objective == nil or D.contains(objective, i) then
					table.insert(ids[e.type], e.id)
					if objectives[e.type][e.id] == nil then objectives[e.type][e.id] = {} end
					table.insert(objectives[e.type][e.id], i)
				end
			end
		end
	elseif typ == "COMPLETE" then
		local c = 1
		if DB.questsDB[id].kill ~= nil then
			for i, id in ipairs(DB.questsDB[id].kill) do
				if objective == nil or D.contains(objective, c) then
					table.insert(ids.npc, id)
					if objectives.npc[id] == nil then objectives.npc[id] = {} end
					table.insert(objectives.npc[id], c)
				end
				c = c + 1
			end
		end
		if DB.questsDB[id].interact ~= nil then
			for i, id in ipairs(DB.questsDB[id].interact) do
				if objective == nil or D.contains(objective, c) then
					table.insert(ids.object, id)
					if objectives.object[id] == nil then objectives.object[id] = {} end
					table.insert(objectives.object[id], c)
				end
				c = c + 1
			end
		end
		if DB.questsDB[id].gather ~= nil then
			for i, id in ipairs(DB.questsDB[id].gather) do
				if objective == nil or D.contains(objective, c) then
					table.insert(ids.item, id)
					if objectives.item[id] == nil then objectives.item[id] = {} end
					table.insert(objectives.item[id], c)
				end
				c = c + 1
			end
		end
	end
	for _, itemId in ipairs(ids.item) do
		if DB.itemsDB[itemId] ~= nil then
			if DB.itemsDB[itemId].drop ~= nil then
				for _, npcId in ipairs(DB.itemsDB[itemId].drop) do
					table.insert(ids.npc, npcId)
					if objectives.item[itemId] ~= nil then
						if objectives.npc[npcId] == nil then objectives.npc[npcId] = {} end
						for _, c in ipairs(objectives.item[itemId]) do
							table.insert(objectives.npc[npcId], c)
						end
					end
				end
			end
			if DB.itemsDB[itemId].object ~= nil then
				for _, objectId in ipairs(DB.itemsDB[itemId].object) do
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
		local element = DB.creaturesDB[npcId]
		if element ~= nil and element.positions ~= nil then
			for i, pos in ipairs(element.positions) do
				-- filter all instances
				if pos.mapid == 0 or pos.mapid == 1 then
					-- TODO: x/y are still switched in db
					local x, y, zone = PT.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid, filterZone)
					if x ~= nil then
						if count >= LIMIT_POSITIONS then return end
						count = count + 1
						positions[count] = {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = DM.mapIDs[zone], 
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
		local element = DB.objectsDB[objectId]
		if element ~= nil and element.positions ~= nil then
			for i, pos in ipairs(element.positions) do
				-- filter all instances
				if pos.mapid == 0 or pos.mapid == 1 then
					-- TODO: x/y are still switched in db
					local x, y, zone = PT.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid, filterZone)
					if x ~= nil then
						if count >= LIMIT_POSITIONS then return end
						count = count + 1
						positions[count] = {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = DM.mapIDs[zone], 
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

function QT.getNPCPositions(id)
	if id == nil then return end
	if addon.dataSource == "QUESTIE" then return QUESTIE.getNPCPositions(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getNPCPositions(id) end
	local positions = {}
	local count = 0
	local element = DB.creaturesDB[id]
	if element ~= nil and element.positions ~= nil then
		for i, pos in ipairs(element.positions) do
			-- filter all instances
			if pos.mapid == 0 or pos.mapid == 1 then
				-- TODO: x/y are still switched in db
				local x, y, zone = PT.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid, filterZone)
				if x ~= nil then
					if count >= LIMIT_POSITIONS then return end
					count = count + 1
					positions[count] = {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = DM.mapIDs[zone], 
						wx = pos.y, wy = pos.x, instance = pos.mapid,
						npcId = id
					}
				elseif addon.debugging and filterZone == nil then
					print("LIME: error transforming (", pos.x, pos.y, pos.mapid, ") into zone coordinates for npc #" .. id)
				end
			end
		end
	end
	return positions
end

function QT.getItemPositions(id)
	if id == nil then return end
	if addon.dataSource == "QUESTIE" then return QUESTIE.getItemPositions(id) end
	if addon.dataSource == "CLASSIC_CODEX" then return CLASSIC_CODEX.getItemPositions(id) end
	local ids = {npc = {}, object = {}}
	if DB.itemsDB[id] ~= nil then
		if DB.itemsDB[id].drop ~= nil then
			for _, npcId in ipairs(DB.itemsDB[id].drop) do
				table.insert(ids.npc, npcId)
			end
		end
		if DB.itemsDB[id].object ~= nil then
			for _, objectId in ipairs(DB.itemsDB[id].object) do
				table.insert(ids.object, objectId)
			end
		end
	end
	local positions = {}
	local count = 0
	for _, npcId in ipairs(ids.npc) do
		local element = DB.creaturesDB[npcId]
		if element ~= nil and element.positions ~= nil then
			for i, pos in ipairs(element.positions) do
				-- filter all instances
				if pos.mapid == 0 or pos.mapid == 1 then
					-- TODO: x/y are still switched in db
					local x, y, zone = PT.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid, filterZone)
					if x ~= nil then
						if count >= LIMIT_POSITIONS then return end
						count = count + 1
						positions[count] = {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = DM.mapIDs[zone], 
							wx = pos.y, wy = pos.x, instance = pos.mapid,
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
		local element = DB.objectsDB[objectId]
		if element ~= nil and element.positions ~= nil then
			for i, pos in ipairs(element.positions) do
				-- filter all instances
				if pos.mapid == 0 or pos.mapid == 1 then
					-- TODO: x/y are still switched in db
					local x, y, zone = PT.GetZoneCoordinatesFromWorld(pos.y, pos.x, pos.mapid, filterZone)
					if x ~= nil then
						if count >= LIMIT_POSITIONS then return end
						count = count + 1
						positions[count] = {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone, mapID = DM.mapIDs[zone], 
							wx = pos.y, wy = pos.x, instance = pos.mapid,
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

function QT.findInLists(line, wordLists, first, startPos, endPos)
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

function QT.getPossibleQuestIdsByName(name, part, faction, race, class)
	if QT.questsDBReverse == nil then
		QT.questsDBReverse = {}
		for _, id in ipairs(QT.getQuestIDs()) do
			if QT.getQuestReplacement(id) == nil then
				local n = QT.getQuestNameById(id):lower():gsub("[%(%)\"%s%p]","")
				if QT.questsDBReverse[n] == nil then QT.questsDBReverse[n] = {} end
				table.insert(QT.questsDBReverse[n], id)
				-- if localized quest name is different from english name also include english name
				--[[
				if QT.getQuestNameById(id) ~= DB.questsDB[id].name then
					n = DB.questsDB[id].name:lower():gsub("[%(%)\"%s%p]",""):gsub("  ", " ")
					if QT.questsDBReverse[n] == nil then QT.questsDBReverse[n] = {} end
					table.insert(QT.questsDBReverse[n], id)
				end]]
			end
		end
	end
	local filteredName = name:lower():gsub("[%(%)\"%s%p]","")
	local ids = QT.questsDBReverse[filteredName]
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
		QT.findInLists(filteredName, wordListMap, false)
		if part == nil then
			QT.findInLists(filteredName, {["(%d+) "] = function(s, e, n) filteredName = filteredName:sub(1, s - 1); part = tonumber(n) end}, false)
		end
		ids = QT.questsDBReverse[filteredName]
	end	

	if ids == nil then ids = {} end
	if #ids > 0 and part ~= nil then
		if part > 1 and #ids == 1 then 
			-- looking for part > 1 and only getting 1 quest? not good return nil
			return {}
		elseif #ids > 1 then
			local filteredIds = {}
			for i, id in ipairs(ids) do
				if QT.getQuestSeries(id) == part then
					table.insert(filteredIds, id)		
				end
			end
			if #filteredIds > 0 then ids = filteredIds end
		end
	end
	if faction ~= nil or race ~= nil or class ~= nil then
		local filteredIds = {}
		for i, id in ipairs(ids) do
			local match = faction == nil or QT.getQuestFaction(id) == nil or faction == QT.getQuestFaction(id)
			if match and race ~= nil and QT.getQuestRaces(id) ~= nil then
				match = false
				for i, r in ipairs(race) do
					if D.contains(QT.getQuestRaces(id), r) then match = true; break end
				end
			end	
			if match and class ~= nil and QT.getQuestClasses(id) ~= nil then
				match = false
				for i, c in ipairs(class) do
					if D.contains(QT.getQuestClasses(id), c) then match = true; break end
				end
			end	
			if match then table.insert(filteredIds, id) end
		end
		ids = filteredIds
	end
	return ids
end

function QT.getMissingPrequests(id, isCompleteFunc)
	local missingPrequests = {}
	if QT.getQuestPrequests(id) ~= nil then
		for _, pid in ipairs(QT.getQuestPrequests(id)) do
			if QT.getQuestApplies(pid) then
				if not isCompleteFunc(pid) then
					table.insert(missingPrequests, pid)
				elseif QT.getQuestOneOfPrequests(id) then
					return {}
				end
			end
		end
	end
	return missingPrequests
end

function QT.getNPCName(id)
	if id == nil then return end
	if QT.npcNames == nil then QT.npcNames = {} end
	if QT.npcNames[id] ~= nil then return QT.npcNames[id] end
	if addon.dataSource == "QUESTIE" then QT.npcNames[id] = QUESTIE.getNPCName(id); return QT.npcNames[id] end
	if addon.dataSource == "CLASSIC_CODEX" then QT.npcNames[id] = CLASSIC_CODEX.getNPCName(id); return QT.npcNames[id] end
	if DB["creaturesDB_" .. GetLocale()] ~= nil and DB["creaturesDB_" .. GetLocale()][id] ~= nil then
		QT.npcNames[id] = DB["creaturesDB_" .. GetLocale()][npcId]
	elseif DB.creaturesDB[id] ~= nil then
		QT.npcNames[id] = DB.creaturesDB[id].name
	end
	return QT.npcNames[id]
end

function QT.getObjectName(id)
	if id == nil then return end
	if QT.objectNames == nil then QT.objectNames = {} end
	if QT.objectNames[id] ~= nil then return QT.objectNames[id] end
	if addon.dataSource == "QUESTIE" then QT.objectNames[id] = QUESTIE.getObjectName(id); return QT.objectNames[id] end
	if addon.dataSource == "CLASSIC_CODEX" then QT.objectNames[id] = CLASSIC_CODEX.getObjectName(id); return QT.objectNames[id] end
	if DB["objectsDB_" .. GetLocale()] ~= nil and DB["objectsDB_" .. GetLocale()][id] ~= nil then
		QT.objectNames[id] = DB["objectsDB_" .. GetLocale()][id]
	elseif DB.objectsDB[id] ~= nil then
		QT.objectNames[id] = DB.objectsDB[id].name
	end
	return QT.objectNames[id]
end

function QT.getItemName(id)
	if id == nil then return end
	if QT.itemNames == nil then QT.itemNames = {} end
	if QT.itemNames[id] ~= nil then return QT.itemNames[id] end
	if addon.dataSource == "QUESTIE" then QT.itemNames[id] = QUESTIE.getItemName(id); return QT.itemNames[id] end
	if addon.dataSource == "CLASSIC_CODEX" then QT.itemNames[id] = CLASSIC_CODEX.getItemName(id); return QT.itemNames[id] end
	if DB["itemsDB_" .. GetLocale()] ~= nil and DB["itemsDB_" .. GetLocale()][id] ~= nil then
		QT.itemNames[id] = DB["itemsDB_" .. GetLocale()][id]
	elseif DB.itemsDB[id] ~= nil then
		QT.itemNames[id] = DB.itemsDB[id].name
	end
	return QT.itemNames[id]
end

function QT.getItemStartingQuest(id)
	local objectives = QT.getQuestObjectives(id, "ACCEPT")
	if objectives then
		for _, o in ipairs(objectives) do
			if o.type == "item" then
				return o.ids.item[1]
			end
		end
	end
end	

function QT.isItemUsable(id)
	if id == nil then return end
	if addon.dataSource == "QUESTIE" then 
		if QUESTIE.isItemLootable(id) then 
			if addon.debugging then print("LIME: found usable item", id, "(via Questie)") end
			return true 
		end
	end
	return QT.getUseItemTooltip(id) ~= nil
end

QT.useItemTooltips = {}
-- search for "Use:" in tooltip
-- see https://wowwiki-archive.fandom.com/wiki/UIOBJECT_GameTooltip for tooltip scanning
function QT.getUseItemTooltip(id)
	if id == nil then return end
	if QT.useItemTooltips[id] then return QT.useItemTooltips[id] end
	if not GuidelimeScanningTooltip then
		CreateFrame( "GameTooltip", "GuidelimeScanningTooltip", nil, "GameTooltipTemplate" );
		GuidelimeScanningTooltip:SetOwner( WorldFrame, "ANCHOR_NONE" );
		GuidelimeScanningTooltip:AddFontStrings(
    	GuidelimeScanningTooltip:CreateFontString( "GameTooltipTextLeft1", nil, "GameTooltipText" ),
    	GuidelimeScanningTooltip:CreateFontString( "GameTooltipTextRight1", nil, "GameTooltipText" ) 
		);
	end
	GuidelimeScanningTooltip:ClearLines() 
	GuidelimeScanningTooltip:SetHyperlink("item:" .. id .. ":0:0:0:0:0:0:0")
	if addon.debugging then print("LIME: scanning tooltip for", id) end
    for i = 1, select("#", GuidelimeScanningTooltip:GetRegions()) do
        local region = select(i, GuidelimeScanningTooltip:GetRegions())
        if region and region:GetObjectType() == "FontString" and region:GetText() and 
			region:GetText():find(USE_COLON) then
			if addon.debugging then print("LIME: found usable item", id, "(via tooltip)") end
			QT.useItemTooltips[id] = region:GetText()
			break
        end
    end
	return QT.useItemTooltips[id]
end

function QT.filterUsableItems(items)
	local filtered = {}
	for _, item in ipairs(items or {}) do
		if QT.isItemUsable(item) then
			table.insert(filtered, item)
		end
	end
	return filtered
end

function QT.getUsableQuestItems(id)
	if id == nil then return end
	if addon.dataSource == "QUESTIE" then return QT.filterUsableItems(QUESTIE.getQuestItems(id)) end
	if addon.dataSource == "CLASSIC_CODEX" then return QT.filterUsableItems(CLASSIC_CODEX.getQuestItems(id)) end
end

QT.questItemIsFor = {
	[6145] = false,
	--[34688] = false, -- Beryl Prison Key for Prison Break(11587); while it is not necessary to use this item it is nice to have the button to see whether it dropped already
	--[34908] = false, -- dropped key as well
	[34968] = false,
	[36726] = false,
	[35746] = false,
	[36760] = false,
	--[40652] = false, -- dropped key as well
	--[40641] = false, -- dropped key as well
	[41615] = false,
	--[42422] = false, -- dropped key as well
	[42839] = false,
	[42918] = false,
	[18597] = "TURNIN",
	[28455] = "TURNIN",
	[34971] = "TURNIN",
	[35797] = "TURNIN",
	[40971] = "TURNIN",
}
setmetatable(QT.questItemIsFor, {__index = function() return "COMPLETE" end})

-- list of non-targetable NPCs; e.g. "invisible bunnies"
QT.npcIsInvisible = {
	-- Wowhead search for "invis"
	[26444] = true, [26175] = true, [26105] = true, [23095] = true, [15214] = true, [14495] = true, [17984] = true, [18849] = true, [23059] = true, [28492] = true, [24771] = true, 
	[23815] = true, [36736] = true, [17915] = true, [19547] = true, [20153] = true, [23240] = true, [29029] = true, [24705] = true, [21237] = true, [25172] = true, [27452] = true, 
	[19550] = true, [26804] = true, [26129] = true, [18818] = true, [32662] = true, [18275] = true, [33087] = true, [23727] = true, [21940] = true, [18968] = true, [18555] = true, 
	[20736] = true, [23057] = true, [35228] = true, [19198] = true, [23746] = true, [27306] = true, [17428] = true, [24289] = true, [31576] = true, [18582] = true, [20979] = true, 
	[23058] = true, [36495] = true, [19230] = true, [21396] = true, [23807] = true, [27324] = true, [19868] = true, [22139] = true, [24449] = true, [18721] = true, [20982] = true, 
	[23813] = true, [19870] = true, [22422] = true, [24450] = true, [31653] = true, [18793] = true, [20991] = true, [23084] = true, [26130] = true, [36737] = true, [19548] = true, 
	[21417] = true, [23814] = true, [28130] = true, [19924] = true, [31817] = true, [18814] = true, [21210] = true, [36848] = true, [19549] = true, [21418] = true, [17974] = true, 
	[22868] = true, [24648] = true, [31913] = true, [21211] = true, [23155] = true, [21422] = true, [23868] = true, [28947] = true, [22974] = true, [21234] = true, [38310] = true,
	[19656] = true, [21512] = true, [23869] = true, [17992] = true, [20212] = true, [22986] = true, [32768] = true, [18967] = true, [21236] = true, [39842] = true, [15221] = true, 
	[19723] = true, [21807] = true, [23893] = true, [29052] = true, [20213] = true, [23033] = true, [32780] = true, [23409] = true, [15222] = true, [19724] = true, [21819] = true, 
	[23901] = true, [30298] = true, [18392] = true, [20469] = true, [23043] = true, [25171] = true, [19008] = true, [21297] = true, [23500] = true, [27047] = true, [15454] = true, 
	[19842] = true, [21939] = true, [24025] = true, [18553] = true, [20562] = true, [23046] = true, [34548] = true, [21310] = true, [27180] = true, [24034] = true, [19867] = true, 
	[26373] = true, [23260] = true, [17286] = true, [21957] = true, [12999] = true, [37071] = true, [24704] = true, [19009] = true, [21355] = true, [31577] = true, [21403] = true, 
	[17950] = true, [17972] = true, [22519] = true, [24526] = true, [31245] = true, [19866] = true, [31517] = true, [26265] = true, [173338] = true, [174404] = true, [186207] = true, 
	[25594] = true, [20061] = true,
	-- Wowhead search for "bunny" except Baby Bunny and some battle pets
	[30315] = true, [29845] = true, [29847] = true, [28293] = true, [29846] = true, [28296] = true, [27426] = true, [30318] = true, [30327] = true, [30317] = true, [32195] = true, 
	[29627] = true, [27394] = true, [28622] = true, [28928] = true, [28294] = true, [28295] = true, [30126] = true, [31312] = true, [30316] = true, [31767] = true, [30125] = true, 
	[26889] = true, [28876] = true, [31105] = true, [32196] = true, [27427] = true, [26887] = true, [30412] = true, [31272] = true, [29803] = true, [30880] = true, [30750] = true, 
	[32197] = true, [30421] = true, [27698] = true, [28631] = true, [30038] = true, [28777] = true, [32199] = true, [28738] = true, [32314] = true, [30210] = true, [28762] = true, 
	[30169] = true, [27444] = true, [29595] = true, [30644] = true, [29391] = true, [28786] = true, [26831] = true, [28757] = true, [30415] = true, [32229] = true, [27445] = true, 
	[27429] = true, [27995] = true, [32821] = true, [29597] = true, [27428] = true, [31866] = true, [30246] = true, [31364] = true, [28739] = true, [28591] = true, [28663] = true, 
	[31743] = true, [31049] = true, [32168] = true, [26227] = true, [29060] = true, [24098] = true, [30514] = true, [28753] = true, [27419] = true, [28352] = true, [31065] = true, 
	[26773] = true, [32167] = true, [27853] = true, [29398] = true, [28248] = true, [28929] = true, [32242] = true, [30576] = true, [33006] = true, [33005] = true, [32266] = true, 
	[29406] = true, [26082] = true, [27280] = true, [28289] = true, [27135] = true, [30996] = true, [31068] = true, [30366] = true, [28755] = true, [27396] = true, [31888] = true, 
	[28330] = true, [32244] = true, [34157] = true, [29999] = true, [28523] = true, [25505] = true, [32245] = true, [31845] = true, [29550] = true, [28300] = true, [24094] = true, 
	[28316] = true, [28459] = true, [27929] = true, [28740] = true, [31064] = true, [27466] = true, [24102] = true, [27253] = true, [27296] = true, [27111] = true, [28137] = true, 
	[31066] = true, [24290] = true, [29099] = true, [28456] = true, [28455] = true, [28299] = true, [32224] = true, [23924] = true, [24202] = true, [28770] = true, [24193] = true, 
	[28713] = true, [32264] = true, [28778] = true, [22177] = true, [27331] = true, [25581] = true, [28460] = true, [25654] = true, [35009] = true, [24100] = true, [27921] = true, 
	[24087] = true, [27889] = true, [17984] = true, [28190] = true, [24095] = true, [37222] = true, [28013] = true, [30220] = true, [28773] = true, [38121] = true, [24264] = true, 
	[31006] = true, [28307] = true, [38289] = true, [37558] = true, [24093] = true, [23922] = true, [27112] = true, [28240] = true, [30339] = true, [27663] = true, [26498] = true, 
	[24194] = true, [32265] = true, [27200] = true, [24337] = true, [26700] = true, [25154] = true, [28224] = true, [30122] = true, [27723] = true, [24170] = true, [25815] = true, 
	[27450] = true, [26867] = true, [22371] = true, [39361] = true, [33340] = true, [27569] = true, [27326] = true, [28520] = true, [37894] = true, [40428] = true, [22925] = true, 
	[21926] = true, [28960] = true, [32256] = true, [32520] = true, [22021] = true, [17947] = true, [24230] = true, [33725] = true, [32531] = true, [31630] = true, [31643] = true, 
	[29558] = true, [32217] = true, [33054] = true, [25746] = true, [24092] = true, [29577] = true, [30959] = true, [32221] = true, [29100] = true, [33140] = true, [38340] = true, 
	[24928] = true, [31794] = true, [35608] = true, [24263] = true, [27453] = true, [23921] = true, [29258] = true, [38341] = true, [37702] = true, [30079] = true, [29094] = true, 
	[24171] = true, [24265] = true, [26804] = true, [32784] = true, [32318] = true, [39356] = true, [27837] = true, [25114] = true, [24101] = true, [22444] = true, [27353] = true, 
	[32202] = true, [28617] = true, [22502] = true, [33779] = true, [30156] = true, [27201] = true, [23837] = true, [28462] = true, [28485] = true, [28724] = true, [27910] = true, 
	[22111] = true, [20736] = true, [22508] = true, [23894] = true, [25964] = true, [28648] = true, [30588] = true, [31777] = true, [32319] = true, [21800] = true, [23074] = true, 
	[24936] = true, [26188] = true, [27757] = true, [30215] = true, [37202] = true, [23395] = true, [24203] = true, [37871] = true, [39744] = true, [21351] = true, [22918] = true, 
	[25965] = true, [32347] = true, [21814] = true, [23081] = true, [26190] = true, [27306] = true, [28441] = true, [28761] = true, [29685] = true, [22422] = true, [23424] = true, 
	[24204] = true, [25535] = true, [27420] = true, [39841] = true, [21352] = true, [22923] = true, [25966] = true, [29397] = true, [35016] = true, [38503] = true, [21921] = true, 
	[28454] = true, [29771] = true, [31047] = true, [32892] = true, [22428] = true, [23425] = true, [24205] = true, [25536] = true, [26732] = true, [28128] = true, [28932] = true, 
	[29877] = true, [21391] = true, [24465] = true, [25971] = true, [27572] = true, [30131] = true, [31817] = true, [32445] = true, [38527] = true, [23118] = true, [26230] = true, 
	[29772] = true, [30302] = true, [39420] = true, [23444] = true, [24220] = true, [33500] = true, [37952] = true, [40506] = true, [21456] = true, [22926] = true, [24466] = true, 
	[25972] = true, [27589] = true, [30132] = true, [36155] = true, [38528] = true, [23119] = true, [25156] = true, [26258] = true, [27890] = true, [39683] = true, [22467] = true, 
	[23445] = true, [26774] = true, [40617] = true, [21498] = true, [23037] = true, [24630] = true, [25973] = true, [27622] = true, [29524] = true, [30133] = true, [36530] = true, 
	[38587] = true, [22109] = true, [23255] = true, [24110] = true, [25157] = true, [27369] = true, [28457] = true, [32214] = true, [37746] = true, [39691] = true, [22495] = true, 
	[23512] = true, [25670] = true, [26775] = true, [29081] = true, [30442] = true, [33742] = true, [38001] = true, [23040] = true, [24021] = true, [24766] = true, [25985] = true, 
	[28301] = true, [30153] = true, [31880] = true, [36966] = true, [23301] = true, [26346] = true, [32215] = true, [33045] = true, [39692] = true, [18560] = true, [25745] = true, 
	[26789] = true, [30091] = true, [30476] = true, [21758] = true, [23056] = true, [24903] = true, [30889] = true, [37000] = true, [38870] = true, [23307] = true, [25192] = true, 
	[26355] = true, [28780] = true, [29812] = true, [37801] = true, [39695] = true, [18563] = true, [22503] = true, [30101] = true, [32298] = true, [38288] = true, [21759] = true, 
	[23071] = true, [24904] = true, [26120] = true, [27674] = true, [28751] = true, [31915] = true, [37039] = true, [39023] = true, [22240] = true, [26391] = true, [27402] = true, 
	[29815] = true, [31092] = true, [37814] = true, [39707] = true, [34319] = true, [39362] = true, [39743] = true, [38342] = true, [31246] = true, [30559] = true, [30589] = true, 
	[39703] = true, [39355] = true, [37990] = true, [37168] = true, [37201] = true, [33341] = true, [33339] = true, [37788] = true, [22296] = true, [26177] = true, [37878] = true, 
	[19654] = true, [19655] = true, [28273] = true, [23322] = true, [23327] = true, [32532] = true, [24908] = true, [28741] = true, [23810] = true, [28632] = true, [28633] = true, 
	[38588] = true, [23104] = true, [34806] = true, [30712] = true, [28461] = true, [23072] = true, [23073] = true, [29805] = true, [25213] = true, [24412] = true, [27988] = true, 
	[33068] = true, [27931] = true, [29215] = true, [26559] = true, [28015] = true, [29876] = true, [26298] = true, [28333] = true, [24288] = true, [29773] = true, [30384] = true, 
	[30361] = true, [37704] = true, [26937] = true, [23923] = true, [23758] = true, [23686] = true, [32608] = true, [31745] = true, [173338] = true, [174404] = true, [186207] = true, 
	[31801] = true, [28458] = true, [27660] = true, [21641] = true, [22246] = true, [37832] = true, [37827] = true, [27413] = true, [25042] = true, [30990] = true, [26834] = true, 
	[27449] = true, [32782] = true, [21760] = true, [21781] = true, [26591] = true, [31005] = true, [39135] = true, [25303] = true, [28463] = true, [27418] = true, [31117] = true, 
	[23378] = true, [25952] = true, [32431] = true, [32984] = true, [24269] = true, [22505] = true, [33141] = true, [30214] = true, [30103] = true, [30130] = true, [30599] = true, 
	[22504] = true, [23974] = true, [26121] = true, [31415] = true, [28816] = true,	
	-- Wowhead search for "proxy"
	[36189] = true, [28270] = true, [29943] = true, [30402] = true, [27341] = true, [27109] = true, [27875] = true, [27825] = true, [30670] = true, [25495] = true, [24124] = true, 
	[29882] = true, [28764] = true, [34899] = true, [31100] = true, [25382] = true, [23450] = true, [34810] = true, [28763] = true, [35055] = true, [35297] = true, [38751] = true, 
	[34879] = true, [35089] = true, [28849] = true, [38587] = true, [34741] = true, [34739] = true, [16398] = true, [38588] = true, [34740] = true, [29150] = true, [33192] = true, 
	[34738] = true, [28984] = true, [28986] = true, [34737] = true,
	-- Wohead search for "credit -bunny"
	[27372] = true, [29816] = true, [27472] = true, [27879] = true, [30296] = true, [26612] = true, [27263] = true, [28644] = true, [27322] = true, [30467] = true, [32648] = true, 
	[29055] = true, [30297] = true, [29008] = true, [27265] = true, [27321] = true, [24165] = true, [24166] = true, [27802] = true, [27471] = true, [26895] = true, [27473] = true, 
	[27264] = true, [27474] = true, [24167] = true, [29009] = true, [27786] = true, [24281] = true, [26882] = true, [28019] = true, [30221] = true, [29245] = true, [29056] = true, 
	[29303] = true, [26249] = true, [27561] = true, [28767] = true, [18841] = true, [24182] = true, [18842] = true, [21039] = true, [26248] = true, [31766] = true, [24274] = true, 
	[18000] = true, [34336] = true, [18840] = true, [23957] = true, [22401] = true, [24276] = true, [28820] = true, [27625] = true, [22051] = true, [25698] = true, [18354] = true, 
	[31481] = true, [18161] = true, [25669] = true, [24641] = true, [21094] = true, [34327] = true, [20815] = true, [32797] = true, [18002] = true, [34338] = true, [17998] = true, 
	[25672] = true, [24185] = true, [22316] = true, [29886] = true, [24184] = true, [20813] = true, [39975] = true, [28595] = true, [24121] = true, [36715] = true, [31329] = true, 
	[18162] = true, [18142] = true, [18144] = true, [30515] = true, [22798] = true, [22799] = true, [27121] = true, [40103] = true, [24888] = true, [26465] = true, [38547] = true, 
	[29058] = true, [25671] = true, [40101] = true, [40102] = true, [38211] = true, [20816] = true, [21892] = true, [39091] = true, [39092] = true, [39454] = true, [23454] = true, 
	[23443] = true, [40387] = true, [29069] = true, [40218] = true, [21321] = true, [23972] = true, [22383] = true, [22434] = true, [17915] = true, [17985] = true, [28482] = true, 
	[21096] = true, [28271] = true, [29057] = true, [26114] = true, [28758] = true, [17413] = true, [24758] = true, [18393] = true, [21173] = true, [33490] = true, [22367] = true, 
	[18551] = true, [17665] = true, [19620] = true, [21924] = true, [33708] = true, [38595] = true, [39123] = true, [25091] = true, [21121] = true, [19032] = true, [22350] = true, 
	[39821] = true, [19619] = true, [24991] = true, [21092] = true, [21095] = true, [39872] = true, [25092] = true, [19652] = true, [19717] = true, [23209] = true, [22351] = true, 
	[25067] = true, [25066] = true, [25065] = true, [26256] = true, [26161] = true, [21959] = true, [24887] = true, [18590] = true, [18589] = true, [25086] = true, [38546] = true, 
	[29800] = true, [20469] = true, [20982] = true, [15894] = true, [15893] = true, [17863] = true, [23438] = true, [26193] = true, [20333] = true, [15005] = true, [15004] = true, 
	[14732] = true, [13756] = true, [15003] = true, [39977] = true, [21910] = true, [24889] = true, [18388] = true, [26464] = true, [25090] = true, [20337] = true, [19028] = true, 
	[19029] = true, [16166] = true, [21929] = true, [27366] = true, [26927] = true, [18395] = true, [19618] = true, [17861] = true, [39976] = true, [22348] = true, [20338] = true, 
	[24890] = true, [18143] = true, [27796] = true, [20814] = true, [22403] = true, [22402] = true, [21182] = true, [33489] = true, [33491] = true, [33493] = true, [22800] = true, 
	[22801] = true, [22435] = true, [22116] = true, [22117] = true, [22118] = true, [22850] = true, [21893] = true, [24275] = true, [18843] = true, [20336] = true, [23727] = true, 
	[29902] = true, [17999] = true, [15001] = true, [15002] = true, [13796] = true, [26466] = true, [37601] = true, [40301] = true, [18110] = true, [24183] = true, [29025] = true, 
	[33492] = true, [22368] = true, [22356] = true, [17950] = true, [13778] = true,	
	
	[27345] = true -- Helpless Wintergarde Villager (Peasants)
}

function QT.filterInvisibleNpcs(npcs)
	local filtered = {}
	for _, npc in ipairs(npcs or {}) do
		if not QT.npcIsInvisible[npc.id] then
			table.insert(filtered, npc)
		end
	end
	return filtered
end

function QT.getQuestNPCs(id, typ, index)
	if addon.dataSource == "QUESTIE" then return QT.filterInvisibleNpcs(QUESTIE.getQuestNPCs(id, typ, index)) end
	if addon.dataSource == "CLASSIC_CODEX" then return QT.filterInvisibleNpcs(CLASSIC_CODEX.getQuestNPCs(id, typ, index)) end
	local npcs = {}
	local objectives = QT.getQuestObjectives(id, typ)
	if not objectives then return end
	for i, o in ipairs(objectives) do
		if o.ids and o.ids.npc then
			for _, id in ipairs(o.ids.npc) do
				if not QT.npcIsInvisible[id] then
					table.insert(npcs, {id = id, objectives = {i}})
				end
			end
		end
	end
	return npcs
end
