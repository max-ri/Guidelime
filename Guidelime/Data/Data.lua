local addonName, addon = ...
local L = addon.L

local HBD = LibStub("HereBeDragons-2.0")

addon.SK = addon.SK or {}; local SK = addon.SK -- Data/SkillDB
addon.SP = addon.SP or {}; local SP = addon.SP -- Data/SpellDB

addon.D = addon.D or {}; local D = addon.D     -- Data/Data

D.factions = {"Alliance", "Horde"}
D.races = {Human = "Alliance", NightElf = "Alliance", Dwarf = "Alliance", Gnome = "Alliance", Orc = "Horde", Troll = "Horde", Tauren = "Horde", Undead = "Horde", Draenei = "Alliance", BloodElf = "Horde"}
D.raceIDs = {Human = 1, NightElf = 4, Dwarf = 3, Gnome = 7, Orc = 2, Troll = 8, Tauren = 6, Undead = 5, BloodElf = 10, Draenei = 11}
D.classes = {"Warrior", "Rogue", "Mage", "Warlock", "Hunter", "Priest", "Druid", "Paladin", "Shaman", "DeathKnight"}
D.classesWithFaction = {}
D.classesPerRace = {
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
function D.getClass(class)
	class = class:upper():gsub(" ","")
	for i, c in ipairs(D.classes) do
		if c:upper() == class then return c end
	end
end
function D.getRace(race)
	race = race:upper():gsub(" ","")
	if race == "SCOURGE" then return "Undead" end
	for r, f in pairs(D.races) do
		if r:upper() == race then return r end
	end
end
function D.getSex(sex)
	if type(sex) == "number" then
		return sex == 2 and "Male" or "Female"
	else
		return sex:upper() == "MALE" and "Male" or "Female"
	end
end

D.class = D.getClass(select(2, UnitClass("player")))
D.race = D.getRace(select(2, UnitRace("player")))
D.sex = D.getSex(UnitSex("player"))
D.faction = UnitFactionGroup("player")
D.level = UnitLevel("player")
D.xp = UnitXP("player")
D.xpMax = UnitXPMax("player")
D.wx, D.wy, D.instance = HBD:GetPlayerWorldPosition()
D.face = GetPlayerFacing()

D.reputations = {
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

D.racesPerFaction = {}
for race, faction in pairs(D.races) do
	if D.racesPerFaction[faction] == nil then D.racesPerFaction[faction] = {} end
	table.insert(D.racesPerFaction[faction], race)
end

D.classesPerFaction = {}
for i, class in ipairs(D.classes) do
	for i, faction in ipairs(D.factions) do
		if D.classesWithFaction[class] or faction == faction then
			if D.classesPerFaction[faction] == nil then D.classesPerFaction[faction] = {} end
			table.insert(D.classesPerFaction[faction], class)
		end
	end
end

function D.isClass(class)
	return D.getClass(class) ~= nil
end
function D.isRace(race)
	return D.getRace(race) ~= nil
end
function D.getFaction(faction)
	faction = faction:upper()
	for i, f in ipairs(D.factions) do
		if f:upper() == faction then return f end
	end
end
function D.isFaction(faction)
	return D.getFaction(faction) ~= nil
end
function D.getLocalizedRace(race)
	if C_CreatureInfo == nil then return race end
	return C_CreatureInfo.GetRaceInfo(D.raceIDs[race]).raceName
end
function D.getLocalizedClass(class)
	return LOCALIZED_CLASS_NAMES_MALE[class:upper()]
end

function D.getReputation(rep)
	return D.reputations[string.gsub(string.gsub(string.lower(rep), "[' ]", ""), "^the", "")]
end
function D.isReputation(rep)
	return D.getReputation(rep) ~= nil
end
function D.getLocalizedReputation(id)
	local name = GetFactionInfoByID(id)
	return name
end
function D.isRequiredReputation(id, repMin, repMax)
	local _, _, standing, _, _, value = GetFactionInfoByID(id)
	if repMin ~= nil and value < repMin then return false end
	if repMax ~= nil and value >= repMax then return false end
	return true
end

function D.contains(array, value)
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

function D.find(array, func)
	if not array then return end
	for i, v in ipairs(array) do
		if func(v) then return v end
	end
end

function D.containsIgnoreCase(array, value)
	return D.contains(array, function(v) return v:upper() == value:upper() end)
end

function D.containsKey(table, value)
	for k, v in pairs(table) do
		if type(value) == "function" then
			if value(k) then return true end
		else
			if k == value then return true end
		end
	end
	return false
end

function D.applies(guide)
	if guide == nil then return false end
	if guide.races ~= nil then
		if not D.contains(guide.races, D.race) then return false end
	end
	if guide.classes ~= nil then
		if not D.contains(guide.classes, D.class) then return false end
	end
	if guide.faction ~= nil and guide.faction ~= D.faction then return false end
	return true
end

function D.hasRequirements(guide)
	if guide == nil then return true end
	if guide.reputation and not D.isRequiredReputation(guide.reputation, guide.repMin, guide.repMax) then return false end
	if guide.skillReq and not SK.isRequiredSkill(guide.skillReq, guide.skillMin, guide.skillMax) then return false end
	if guide.spellReq and not SP.isRequiredSpell(guide.spellReq, guide.spellMin, guide.spellMax) then return false end
	if guide.itemReq and not D.hasItem(guide.itemReq, guide.itemMin, guide.itemMax) then return false end
	return true
end

function D.isAlive()
	return not UnitIsDeadOrGhost("player")
	--return HBD:GetPlayerZone() == nil or C_DeathInfo.GetCorpseMapPosition(HBD:GetPlayerZone()) == nil
end

function D.bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function D.hasbit(x, p)
  return x % (p + p) >= p       
end

function D.hasItem(itemReq, itemMin, itemMax)
	-- note that itemMin is not "minimum number of items", but "greater than" (not "greater or equal"), analog itemMax
	-- as pattern match for element.t == "APPLIES" in GuideParser.lua does not allow for <= or >=

	local itemcnt = GetItemCount(tonumber(itemReq))

	if itemMin ~= nil then return (itemcnt > itemMin) end
	if itemMax ~= nil then return (itemcnt < itemMax) end

	return nil
end

D.RACE_ICON_TCOORDS = {
	["Human"] = {
		["Male"] = {0, 0.125, 0, 0.25},
		["Female"]	= {0, 0.125, 0.5, 0.75},  
	},
	["Dwarf"] = {
		["Male"] = {0.125, 0.25, 0, 0.25},
		["Female"]	= {0.125, 0.25, 0.5, 0.75},
	},
	["Gnome"] = {
		["Male"] = {0.25, 0.375, 0, 0.25},
		["Female"]	= {0.25, 0.375, 0.5, 0.75},
	},
	["NightElf"] = {
		["Male"] = {0.375, 0.5, 0, 0.25},
		["Female"]	= {0.375, 0.5, 0.5, 0.75},
	},
	["Tauren"] = {
		["Male"] = {0, 0.125, 0.25, 0.5},
		["Female"]	= {0, 0.125, 0.75, 1.0},   
	},
	["Undead"] = {
		["Male"] = {0.125, 0.25, 0.25, 0.5},
		["Female"]	= {0.125, 0.25, 0.75, 1.0}, 
	},
	["Troll"] = {
		["Male"] = {0.25, 0.375, 0.25, 0.5},
		["Female"]	= {0.25, 0.375, 0.75, 1.0}, 
	},
	["Orc"] = {
		["Male"] = {0.375, 0.5, 0.25, 0.5},
		["Female"] = {0.375, 0.5, 0.75, 1.0}, 
	},
	["BloodElf"] = {
		["Male"] = {0.5, 0.625, 0.25, 0.5},
		["Female"] = {0.5, 0.625, 0.75, 1.0}, 
	},
	["Draenei"] = {
		["Male"] = {0.5, 0.625, 0, 0.25},
		["Female"] = {0.5, 0.625, 0.5, 0.75}, 
	},
};

function D.getRaceIconText(race, sex, size)
	local coords = D.RACE_ICON_TCOORDS[D.getRace(race)][D.getSex(sex)]
	return "|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-RACES:" .. (size or 12) .. ":" .. (size or 12) .. ":0:0:64:128:" .. 
		coords[1] * 128 .. ":" .. coords[2] * 128 .. ":" .. coords[3] * 128 .. ":" .. coords[4] * 128 .. ":::|t"
end

function D.getClassIconText(class, size)
	-- cf https://wowpedia.fandom.com/wiki/Class_icon; alternative icon suggestions there as well
	local coords = CLASS_ICON_TCOORDS[D.getClass(class):upper()]
	return "|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:" .. (size or 12) .. ":" .. (size or 12) .. ":0:0:128:128:" .. 
		coords[1] * 128 .. ":" .. coords[2] * 128 .. ":" .. coords[3] * 128 .. ":" .. coords[4] * 128 .. ":::|t"
end
