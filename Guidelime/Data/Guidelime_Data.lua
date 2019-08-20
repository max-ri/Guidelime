local addonName, addon = ...
local L = addon.L

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
	if race == "SCOURGE" then return "Undead" end
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
	if C_CreatureInfo == nil then return race end
	return C_CreatureInfo.GetRaceInfo(addon.raceIDs[race]).raceName
end
function addon.getLocalizedClass(class)
	return LOCALIZED_CLASS_NAMES_MALE[class:upper()]
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
