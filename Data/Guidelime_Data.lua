local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")

addon.factions = {"Alliance", "Horde"}
addon.races = {Human = "Alliance", NightElf = "Alliance", Dwarf = "Alliance", Gnome = "Alliance", Orc = "Horde", Troll = "Horde", Tauren = "Horde", Undead = "Horde"}
addon.raceIDs = {Human = 1, NightElf = 4, Dwarf = 3, Gnome = 7, Orc = 2, Troll = 8, Tauren = 6, Undead = 5}
addon.classes = {"Warrior", "Rogue", "Mage", "Warlock", "Hunter", "Priest", "Druid", "Paladin", "Shaman"}
addon.classesWithFaction = {Paladin = "Alliance", Shaman = "Horde"}

addon.racesPerFaction = {}
for race, faction in pairs(addon.races) do
	if addon.racesPerFaction[faction] == nil then addon.racesPerFaction[faction] = {} end
	table.insert(addon.racesPerFaction[faction], race)
end

addon.classesPerFaction = {}
for i, class in ipairs(addon.classes) do
	for i, faction in ipairs(addon.factions) do
		if addon.classesWithFaction[class] or faction == faction then
			if addon.classesPerFaction[faction] == nil then addon.classesPerFaction[faction] = {} end
			table.insert(addon.classesPerFaction[faction], class)
		end
	end
end

function addon.getClass(class)
	class = class:upper():gsub(" ","")
	for i, c in ipairs(addon.classes) do
		if c:upper() == class then return c end
	end
end
function addon.isClass(class)
	return addon.getClass(class) ~= nil
end
function addon.getRace(race)
	race = race:upper():gsub(" ","")
	if race == "SCOURCE" then return "Undead" end
	for r, f in pairs(addon.races) do
		if r:upper() == race then return r end
	end
end
function addon.isRace(race)
	return addon.getRace(race) ~= nil
end
function addon.getFaction(faction)
	faction = faction:upper()
	for i, f in ipairs(addon.factions) do
		if f:upper() == faction then return f end
	end
end
function addon.isFaction(faction)
	return addon.getFaction(faction) ~= nil
end
function addon.getLocalizedRace(race)
	return C_CreatureInfo.GetRaceInfo(addon.raceIDs[race]).raceName
end
function addon.getLocalizedClass(class)
	return LOCALIZED_CLASS_NAMES_MALE[class:upper()]
end

function addon.getQuestNameById(id)
	if id == nil then return nil end
	if addon.quests ~= nil and addon.quests[id] ~= nil and addon.quests[id].name ~= nil then
		return addon.quests[id].name
	end
	local locale = GetLocale()
	if addon.questsDB[id] == nil then
		return nil
	elseif addon.questsDB[id]["name_" .. locale] ~= nil then
		return addon.questsDB[id]["name_"..locale]
	else
		return addon.questsDB[id].name
	end
end

function addon.getQuestObjective(id)
	local locale = GetLocale()
	if id == nil or addon.questsDB[id] == nil then
		return
	elseif addon.questsDB[id]["objective_" .. locale] ~= nil then
		return addon.questsDB[id]["objective_"..locale]
	else
		return addon.questsDB[id].objective
	end
end

function addon.getQuestPositions(id, typ, index, objective)
	if id == nil or addon.questsDB[id] == nil then return end
	local quest
	if typ == "ACCEPT" then 
		quest = addon.questsDB[id].source
	elseif typ == "TURNIN" then
		quest = addon.questsDB[id].deliver
	else
		return
	end
	if quest == nil or #quest < index then return end
	local element = quest[index]
	if element.positions == nil then return end
	local positions = {}
	for i, pos in ipairs(element.positions) do
		local x, y, zone = addon.GetZoneCoordinatesFromWorld(pos.x, pos.y, pos.mapid)
		if x ~= nil then
			table.insert(positions, {x = math.floor(x * 10000) / 100, y = math.floor(y * 10000) / 100, zone = zone})
		else
			error("error transforming (" .. pos.x .. "," .. pos.y .. " " .. pos.mapid .. ") into zone coordinates for quest #" .. id)
		end
	end
	return positions
end

function addon.getQuestTargetNames(id, typ, objective)
	if id == nil or addon.questsDB[id] == nil then return end
	local quest
	if typ == "ACCEPT" then 
		quest = addon.questsDB[id].source
	elseif typ == "TURNIN" then
		quest = addon.questsDB[id].deliver
	else
		return
	end
	if quest == nil then return end
	local names = {}
	for _, element in ipairs(quest) do
		table.insert(names, element.name)
	end
	return names
end	

function addon.getPossibleQuestIdsByName(name, faction, race, class)
	if addon.questsDBReverse == nil then
		addon.questsDBReverse = {}
		for id, quest in pairs(addon.questsDB) do
			local n = addon.getQuestNameById(id):upper()
			if addon.questsDBReverse[n] == nil then addon.questsDBReverse[n] = {} end
			table.insert(addon.questsDBReverse[n], id)
			if quest.series ~= nil then
				local n2 = n .. " " .. L.PART:upper() .. " " .. quest.series
				if addon.questsDBReverse[n2] == nil then addon.questsDBReverse[n2] = {} end
				table.insert(addon.questsDBReverse[n2], id)
			end
			if n:upper() ~= addon.questsDB[id].name:upper() then
				n = addon.questsDB[id].name:upper()
				if addon.questsDBReverse[n] == nil then addon.questsDBReverse[n] = {} end
				table.insert(addon.questsDBReverse[n], id)
				if quest.series ~= nil then
					local n2 = n .. " PART " .. quest.series
					if addon.questsDBReverse[n2] == nil then addon.questsDBReverse[n2] = {} end
					table.insert(addon.questsDBReverse[n2], id)
				end
			end
		end
	end
	local filteredName = name:gsub("%(",""):gsub("%)",""):gsub("pt%.","part"):upper()
	local ids = addon.questsDBReverse[filteredName]
	if ids == nil and filteredName:sub(#filteredName - 5, #filteredName - 1) == "PART " then 
		ids = addon.getPossibleQuestIdsByName(filteredName:sub(1, #filteredName - 7))
		-- looking for part 2 without specifying so and only getting 1 quest? not good return nil
		if tonumber(filteredName:sub(#filteredName - 1, #filteredName)) > 1 and ids ~= nil and #ids == 1 then ids = nil end
	end
	if ids ~= nil and (faction ~= nil or race ~= nil or class ~= nil) then
		local filteredIds = {}
		for i, id in ipairs(ids) do
			local match = faction == nil or addon.questsDB[id].faction == nil or faction == addon.questsDB[id].faction
			if match and race ~= nil and addon.questsDB[id].races ~= nil then
				match = false
				for i, r in ipairs(race) do
					if addon.contains(addon.questsDB[id].races, r) then match = true; break end
				end
			end	
			if match and class ~= nil and addon.questsDB[id].classes ~= nil then
				match = false
				for i, c in ipairs(class) do
					if addon.contains(addon.questsDB[id].classes, c) then match = true; break end
				end
			end	
			if match then table.insert(filteredIds, id) end
		end
		return filteredIds
	end
	return ids
end

function addon.GetZoneCoordinatesFromWorld(worldX, worldY, instance)
	for name, id in pairs(addon.mapIDs) do
		local x, y = HBD:GetZoneCoordinatesFromWorld(worldY, worldX, id, false)
		if x ~= nil and x > 0 and x < 1 and y ~= nil and y > 0 and y < 1 then
			local checkX, checkY, checkInstance = HBD:GetWorldCoordinatesFromZone(x, y, id)
			if checkInstance == instance then
				-- hack for some bfa zone names
				do
					local e = name:find("[@!]")
					if e ~= nil then name = name:sub(1, e - 1) end
				end
				return x, y, name
			end
		end
	end
end

function addon.contains(array, value)
	for i, v in ipairs(array) do
		if type(value) == "function" then
			if value(v) then return true end
		else
			if v == value then return true end
		end
	end
	return false
end

function addon.containsIgnoreCase(array, value)
	return addon.contains(array, function(v) return v:upper() == value:upper() end)
end

function addon.containsKey(table, value)
	for k, v in pairs(table) do
		if type(value) == "function" then
			if value(k) then return true end
		else
			if k == value then return true end
		end
	end
	return false
end
