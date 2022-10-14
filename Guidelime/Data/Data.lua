local addonName, addon = ...
local L = addon.L

addon.factions = {"Alliance", "Horde"}
addon.races = {Human = "Alliance", NightElf = "Alliance", Dwarf = "Alliance", Gnome = "Alliance", Orc = "Horde", Troll = "Horde", Tauren = "Horde", Undead = "Horde", Draenei = "Alliance", BloodElf = "Horde"}
addon.raceIDs = {Human = 1, NightElf = 4, Dwarf = 3, Gnome = 7, Orc = 2, Troll = 8, Tauren = 6, Undead = 5, BloodElf = 10, Draenei = 11}
addon.classes = {"Warrior", "Rogue", "Mage", "Warlock", "Hunter", "Priest", "Druid", "Paladin", "Shaman", "DeathKnight"}
addon.classesWithFaction = {}
addon.classesPerRace = {
	Human = {"Warrior", "Paladin", "Rogue", "Priest", "Mage", "Warlock", "DeathKnight"},
	NightElf = {"Warrior", "Hunter", "Rogue", "Priest", "Druid", "DeathKnight"},
	Dwarf = {"Warrior", "Paladin", "Hunter", "Rogue", "Priest", "DeathKnight"},
	Gnome = {"Warrior", "Rogue", "Mage", "Warlock", "DeathKnight"},
	Orc = {"Warrior", "Hunter", "Rogue", "Shaman", "Warlock", "DeathKnight"},
	Troll = {"Warrior", "Hunter", "Rogue", "Priest", "Shaman", "Mage", "DeathKnight"},
	Tauren = {"Warrior", "Hunter", "Shaman", "Druid", "DeathKnight"},
	Undead = {"Warrior", "Rogue", "Priest", "Mage", "Warlock", "DeathKnight"},
	Draenei = {"Hunter", "Mage", "Paladin", "Priest", "Shaman", "Warrior", "DeathKnight"},
	BloodElf = {"Hunter", "Mage", "Paladin", "Priest", "Rogue", "Warlock", "DeathKnight"}
}
addon.reputations = {
	bootybay = 21,
	ironforge = 47,
	gnomeregan = 54,
	thoriumbrotherhood = 59,
	undercity = 68,
	darnassus = 69,
	syndicate = 70,
	stormwind = 72,
	orgrimmar = 76,
	thunderbluff = 81,
	bloodsailbuccaneers = 87,
	gelkisclancentaur = 92,
	magramclancentaur = 93,
	zandalartribe = 270,
	ravenholdt = 349,
	gadgetzan = 369,
	ratchet = 470,
	wildhammerclan = 471,
	leagueofarathor = 509,
	defilers = 510,
	argentdawn = 529,
	darkspeartrolls = 530,
	timbermawhold = 576,
	everlook = 577,
	wintersabertrainers = 589,
	cenarioncircle = 609,
	frostwolfclan = 729,
	stormpikeguard = 730,
	hydraxianwaterlords = 749,
	shendralar = 809,
	warsongoutriders = 889,
	silverwingsentinels = 890,
	darkmoonfaire = 909,
	broodofnozdormu = 910,
	silvermooncity = 911,
	tranquillien = 922,
	exodar = 930,
	aldor = 932,
	consortium = 933,
	scryers = 934,
	shatar = 935,
	maghar = 941,
	cenarionexpedition = 942,
	honorhold = 946,
	thrallmar = 947,
	violeteye = 967,
	sporeggar = 970,
	kurenai = 978,
	keepersoftime = 989,
	scaleofthesands = 990,
	lowercity = 1011,
	ashtonguedeathsworn = 1012,
	netherwing = 1015,
	shatariskyguard = 1031,
	ogrila = 1038,
	shatteredsunoffensive = 1077,
	valianceexpedition = 1050,
	silvercovenant = 1094,
	explorersleague = 1068,
	frostborn = 1126,
	warsongoffensive = 1085,
	sunreavers = 1124,
	handofvengeance = 1067,
	taunka = 1064,
	oracles = 1105,
	frenzyhearttribe = 1104,
}

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

function addon.getReputation(rep)
	return addon.reputations[string.gsub(string.gsub(string.lower(rep), "[' ]", ""), "^the", "")]
end
function addon.isReputation(rep)
	return addon.getReputation(rep) ~= nil
end
function addon.getLocalizedReputation(id)
	local name = GetFactionInfoByID(id)
	return name
end
function addon.isRequiredReputation(id, repMin, repMax)
	local _, _, standing, _, _, value = GetFactionInfoByID(id)
	if repMin ~= nil and value < repMin then return false end
	if repMax ~= nil and value >= repMax then return false end
	return true
end

function addon.contains(array, value)
	if not array then return end
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

function addon.applies(guide)
	if guide == nil then return false end
	if guide.races ~= nil then
		if not addon.contains(guide.races, addon.race) then return false end
	end
	if guide.classes ~= nil then
		if not addon.contains(guide.classes, addon.class) then return false end
	end
	if guide.faction ~= nil and guide.faction ~= addon.faction then return false end
	return true
end

function addon.isAlive()
	return not UnitIsDeadOrGhost("player")
	--return HBD:GetPlayerZone() == nil or C_DeathInfo.GetCorpseMapPosition(HBD:GetPlayerZone()) == nil
end


