local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")

function addon.isDataSourceInstalledCLASSIC_CODEX()
	return CodexDB ~= nil
end

function addon.getQuestIDsClassicCodex()
	local ids = {}
	for id, q in pairs(CodexDB.quests.data) do
		table.insert(ids, id)
	end
	return ids
end

function addon.isQuestIdClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return false end
	return CodexDB.quests.data[id] ~= nil
end

function addon.getQuestNameClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.loc[id]
	if quest == nil then return end
	return quest.T
end

-- not supported
function addon.getQuestSortClassicCodex(id) return nil end

function addon.getQuestPrequestsClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.data[id]
	if quest == nil then return end
	if quest.pre ~= nil then return type(quest.pre) == "number" and {quest.pre} or quest.pre end 
	if quest.preg ~= nil then return type(quest.preg) == "number" and {quest.preg} or quest.preg end
end

function addon.getQuestOneOfPrequestsClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.data[id]
	if quest == nil then return end
	return quest.pre ~= nil
end

-- not supported
function addon.getQuestTypeClassicCodex(id) return nil end

function addon.getQuestLevelClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.data[id]
	if quest == nil then return end
	return quest.lvl
end

function addon.getQuestMinimumLevelClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.data[id]
	if quest == nil then return end
	return quest.min
end

function addon.getQuestNextClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.data[id]
	if quest == nil then return end
	return quest.next
end

function addon.getQuestRacesClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.data[id]
	if quest == nil then return end
	local bitmask = quest.race
	if bitmask == nil or bitmask == 0 then return end
	local races = {}
	for i, race in ipairs({"Human", "Orc", "Dwarf", "NightElf", "Undead", "Tauren", "Gnome", "Troll", "", "BloodElf", "Draenei"}) do
		if race ~= "" and addon.hasbit(bitmask, addon.bit(i)) then 
			table.insert(races, race) 
		end
	end
	return races
end

function addon.getQuestClassesClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.data[id]
	if quest == nil then return end
	local bitmask = quest.class
	if bitmask == nil or bitmask == 0 then return end
	local classes = {}
	for i, class in pairs({"Warrior", "Paladin", "Hunter", "Rogue", "Priest", "Shaman", "Mage", "Warlock", "Druid"}) do
		if class ~= "" and addon.hasbit(bitmask, addon.bit(i)) then 
			table.insert(classes, class) 
		end
	end
	return classes
end

function addon.getQuestFactionClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.data[id]
	if quest == nil then return end
	local bitmask = quest.race
	if bitmask == nil then return end
	if bitmask == 77 or bitmask == 1101 then return "Alliance" end
	if bitmask == 178 or bitmask == 690 then return "Horde" end
end

function addon.getQuestObjectiveClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.loc[id]
	if quest == nil then return end
	return quest.O
end

function addon.getQuestReputationClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.data[id]
	if quest == nil then return end
	if quest.repu ~= nil then
		return quest.repu.id, quest.repu.min
	end
end
	

function addon.getQuestPositionsClassicCodex(id, typ, index, filterZone)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local ids = {npc = {}, object = {}, item = {}}
	local objectives = {npc = {}, object = {}, item = {}}
	if addon.getSuperCode(typ) == "QUEST" then
		for i, o in ipairs(addon.getQuestObjectives(id, typ) or {}) do
			if index == nil or index == 0 or index == i then
				local type = o.type == "monster" and "npc" or o.type
				for _, oid in ipairs(o.ids[type]) do
					table.insert(ids[type], oid)
					if objectives[type][oid] == nil then objectives[type][oid] = {} end
					table.insert(objectives[type][oid], i)
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
		local item = CodexDB.items.data[itemId]
		--if item == nil then error("item " .. itemId .. " not found for quest " .. questid .. typ) end
		--if addon.debugging then print("LIME: item", itemId .. " " .. item[6]) end
		if item ~= nil then
			if item.U ~= nil then
				for npcId, chance in pairs(item.U) do
					if not addon.contains(ids.npc, npcId) then table.insert(ids.npc, npcId) end
					if objectives.npc[npcId] == nil then objectives.npc[npcId] = {} end
					for _, c in ipairs(objectives.item[itemId]) do table.insert(objectives.npc[npcId], c) end
				end
			end
			if item.O ~= nil then
				for objectId, chance in pairs(item.O) do
					if not addon.contains(ids.object, objectId) then table.insert(ids.object, objectId) end
					if objectives.object[objectId] == nil then objectives.object[objectId] = {} end
					for _, c in ipairs(objectives.item[itemId]) do table.insert(objectives.object[objectId], c) end
				end
			end
		end
	end
	local positions = {}
	local filterZoneId
	if filterZone ~= nil then filterZoneId = addon.mapIDs[filterZone] end
	for _, npcId in ipairs(ids.npc) do
		local npc = CodexDB.units.data[npcId]
		--if npc == nil then error("npc " .. npcId .. " not found for quest " .. questid .. typ) end
		--if addon.debugging then print("LIME: npc", npc[1]) end
		if npc ~= nil and npc.coords ~= nil then
			for _, pos in ipairs(npc.coords) do
				if filterZone == nil or filterZone == CodexMap.zones[pos[3]] then
					table.insert(positions, {x = pos[1], y = pos[2], zone = addon.zoneNames[CodexMap.zones[pos[3]]] or CodexMap.zones[pos[3]], npcId = npcId, objectives = objectives.npc[npcId]})
				end
			end
		end
	end
	for _, objectId in ipairs(ids.object) do
		local object = CodexDB.objects.data[objectId]
		--if object == nil then error("object " .. objectId .. " not found for quest " .. id .. typ) end
		--if addon.debugging then print("LIME: object", object[1]) end
		if object ~= nil and object.coords ~= nil then
			for _, pos in ipairs(object.coords) do
				if filterZone == nil or filterZone == CodexMap.zones[pos[3]] then
					table.insert(positions, {x = pos[1], y = pos[2], zone = addon.zoneNames[CodexMap.zones[pos[3]]] or CodexMap.zones[pos[3]], objectId = objectId, objectives = objectives.object[objectId]})
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
function addon.getQuestObjectivesClassicCodex(id, typ)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local quest = CodexDB.quests.data[id]
	if quest == nil then return end
	if typ == "ACCEPT" then 
		list = quest.start
	elseif typ == "COMPLETE" then
		list = quest.obj
	elseif typ == "TURNIN" then
		list = quest["end"]
	else
		return
	end
	if list == nil then return end
	--if addon.debugging then print("LIME: getQuestObjectivesClassicCodex " .. typ .. " " .. id .. " " .. addon.show(list)) end
	local objectives = {}
	if list.U ~= nil then
		for _, npcId in ipairs(list.U) do
			local npcName = CodexDB.units.loc[npcId]
			table.insert(objectives, {type = typ == "COMPLETE" and "monster" or "npc", names = {npcName or npcId}, ids = {npc = {npcId}}})
		end
	end
	if list.O ~= nil then
		for _, objId in ipairs(list.O) do
			local objName = CodexDB.objects.loc[objId]
			table.insert(objectives, {type = "object", names = {objName or objId}, ids = {object = {objId}}})
		end
	end
	local idsReceived = {}
	if list.IR ~= nil then
		for _, itemId in ipairs(list.IR) do
			idsReceived[itemId] = true
		end
	end
	if list.I ~= nil then
		for _, itemId in ipairs(list.I) do
			if not idsReceived[itemId] then
				local itemName = CodexDB.items.loc[itemId]
				local objective = {type = "item", names = {itemName or itemId}, ids = {item = {itemId}}}
				local item = CodexDB.items.data[itemId]
				if item ~= nil then
					if item.U ~= nil then
						objective.ids.npc = {}
						for unitId, chance in pairs(item.U) do
							table.insert(objective.ids.npc, unitId)
							local npcName = CodexDB.units.loc[unitId]
							if npcName and not addon.contains(objective.names, npcName) then table.insert(objective.names, npcName) end
						end
					end
					if item.O ~= nil then
						objective.ids.object = {}
						for objectId, chance in pairs(item.O) do
							table.insert(objective.ids.object, objectId)
							local objName = CodexDB.objects.loc[objectId]
							if objName and not addon.contains(objective.names, objName) then table.insert(objective.names, objName) end
						end
					end
				end
				table.insert(objectives, objective)
			end
		end
	end
	-- apply corrections for objective order
	if typ == "COMPLETE" and addon.classicCodexCorrectionsObjectiveOrder[id] then
		local objectives2 = {}
		for i, j in ipairs(addon.classicCodexCorrectionsObjectiveOrder[id]) do
			objectives2[i] = objectives[j]
		end
		objectives = objectives2
	end
	-- apply corrections for missing objectives
	-- e.g. kill credit objectives as in https://tbc.wowhead.com/quest=10482/fel-orc-scavengers
	-- or https://tbc.wowhead.com/quest=9935/wanted-giselda-the-crone (kill credit + kill)
	if typ == "COMPLETE" and addon.classicCodexCorrectionsObjectives[id] then
		for i, o in pairs(addon.classicCodexCorrectionsObjectives[id]) do
			objectives[i] = o
		end
	end
	return objectives
end

function addon.getNPCPositionClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	local npc = CodexDB.units.data[id]
	if npc ~= nil and npc.coords ~= nil then
		for _, pos in ipairs(npc.coords) do
			local p = {x = pos[1], y = pos[2], mapID = CodexMap.zones[pos[3]], zone = addon.zoneNames[CodexMap.zones[pos[3]]] or CodexMap.zones[pos[3]]}
			p.wx, p.wy, p.instance = HBD:GetWorldCoordinatesFromZone(p.x / 100, p.y / 100, p.mapID)
			if p.wx == nil then
				if addon.debugging then print("LIME: error transforming (", p.x, ",", p.y, p.zone, p.mapID, ") into world coordinates for npc #", id) end
			else
				return p
			end
		end
	end
end

function addon.getNPCNameClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	return CodexDB.units.loc[id]
end

function addon.getObjectNameClassicCodex(id)
	if id == nil or not addon.isDataSourceInstalledCLASSIC_CODEX() then return end
	return CodexDB.objects.loc[id]
end

