local addonName, addon = ...

addon.DM = addon.DM or {}; local DM = addon.DM

--[[if GetLocale() == "enUS" then
	-- read ui map id list from HDB
	DM.mapIDs = {}
	for i, id in ipairs(HBD:GetAllMapIDs()) do
		DM.mapIDs[HBD:GetLocalizedMap(id)] = id
	end
else]]

DM.mapIDs = {
	["The Hinterlands"] = 1425,
	["Moonglade"] = 1450,
	["Thousand Needles"] = 1441,
	["Winterspring"] = 1452,
	["Arathi Highlands"] = 1417,
	["Westfall"] = 1436,
	["Badlands"] = 1418,
	["Searing Gorge"] = 1427,
	["Loch Modan"] = 1432,
	--["Eastern Kingdoms"] = 1415,
	["Undercity"] = 1458,
	["Desolace"] = 1443,
	["Warsong Gulch"] = 1460,
	["Tirisfal Glades"] = 1420,
	["Stormwind City"] = 1453,
	["Azshara"] = 1447,
	["The Barrens"] = 1413,
	["Swamp of Sorrows"] = 1435,
	--["Azeroth"] = 947,
	["Alterac Mountains"] = 1416,
	["Darkshore"] = 1439,
	["Blasted Lands"] = 1419,
	["Stranglethorn Vale"] = 1434,
	["Eastern Plaguelands"] = 1423,
	["Duskwood"] = 1431,
	["Durotar"] = 1411,
	["Orgrimmar"] = 1454,
	["Ashenvale"] = 1440,
	["Teldrassil"] = 1438,
	["Redridge Mountains"] = 1433,
	["Un'Goro Crater"] = 1449,
	["Mulgore"] = 1412,
	["Ironforge"] = 1455,
	["Felwood"] = 1448,
	["Tanaris"] = 1446,
	["Stonetalon Mountains"] = 1442,
	["Burning Steppes"] = 1428,
	["Deadwind Pass"] = 1430,
	["Dun Morogh"] = 1426,
	["Western Plaguelands"] = 1422,
	["Wetlands"] = 1437,
	--["Kalimdor"] = 1414,
	["Arathi Basin"] = 1461,
	["Silverpine Forest"] = 1421,
	["Darnassus"] = 1457,
	["Feralas"] = 1444,
	["Elwynn Forest"] = 1429,
	["Alterac Valley"] = 1459,
	["Thunder Bluff"] = 1456,
	["Dustwallow Marsh"] = 1445,
	["Hillsbrad Foothills"] = 1424,
	["Silithus"] = 1451,
	
	-- The Burning Crusade
	["Eversong Woods"] = 1941,
	["Ghostlands"] = 1942,
	["Azuremyst Isle"] = 1943,
	["Hellfire Peninsula"] = 1944,
	["Zangarmarsh"] = 1946,
	["The Exodar"] = 1947,
	["Shadowmoon Valley"] = 1948,
	["Blades Edge Mountains"] = 1949,
	["Bloodmyst Isle"] = 1950,
	["Nagrand"] = 1951,
	["Terokkar Forest"] = 1952,
	["Netherstorm"] = 1953,
	["Silvermoon City"] = 1954,
	["Shattrath City"] = 1955,
	["Isle of Quel Danas"] = 1957,
	
	-- The Wrath of the Lich King
    ["Borean Tundra"]=114,
    ["Dragonblight"]=115,
    ["Grizzly Hills"]=116,
    ["Howling Fjord"]=117,
    ["Icecrown"]=118,
    ["Sholazar Basin"]=119,
    ["The Storm Peaks"]=120,
    ["Zul'Drak"]=121,
    ["Wintergrasp"]=123,
    ["Dalaran"]=125,
    ["The Underbelly"]=126,	
	["The Scarlet Enclave"]=124,	
	["Crystalsong Forest"]=127,
	["Hrothgar's Landing"]=170,
	
	-- Cataclysm
	["The Lost Isles"]=174,
	["Gilneas"]=179,
	["Kezan"]=194,
	["Mount Hyjal"]=198,
	["Southern Barrens"]=199,
	["Kelp'thar Forest"]=201,
	["Gilneas City"]=202,
	["Vashj'ir"]=203,
	["Abyssal Depths"]=204,
	["Shimmering Expanse"]=205,
	["Deepholm"]=207,
	["The Cape of Stranglethorn"]=210,
	["Ruins of Gilneas"]=217,
	--["Stranglethorn Vale"]=224,
	["Northern Stranglethorn"]=50,
	["Twilight Highlands"]=241,
	["Tol Barad"]=244,
	["Tol Barad Peninsula"]=245,
	["Uldum"]=249,
	["The Maelstrom"]=276,
	
}

DM.zoneNames = {}
for zone, id in pairs(DM.mapIDs) do
	DM.zoneNames[id] = zone
end

function DM.getZoneName(name)
	name = name:lower():gsub("[%s']", "")
	if name:sub(1, 3) == "the" then name = name:sub(4) end
	for zone, _ in pairs(DM.mapIDs) do
		local z = zone:lower():gsub("[%s']", "")
		if z:sub(1, 3) == "the" then z = z:sub(4) end
		if z == name then return zone end
	end
end
