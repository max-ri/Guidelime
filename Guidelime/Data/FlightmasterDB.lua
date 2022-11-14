local addonName, addon = ...

local HBD = LibStub("HereBeDragons-2.0")

addon.DM = addon.DM or {}; local DM = addon.DM -- Data/MapDB
addon.PT = addon.PT or {}; local PT = addon.PT -- Data/PositionTools

addon.FM = addon.FM or {}; local FM = addon.FM -- Data/FlightmasterDB

FM.flightmasterDB = {
	[352] = {zone = "Stormwind City", name = "Dungar Longdrink", place = "Stormwind", faction = "Alliance", localesIndex = 2},
	[523] = {zone = "Westfall", name = "Thor", place = "Sentinel Hill", faction = "Alliance", localesIndex = 4},
	[931] = {zone = "Redridge Mountains", name = "Ariena Stormfeather", place = "Lakeshire", faction = "Alliance", localesIndex = 5},
	[1387] = {zone = "Stranglethorn Vale", name = "Thysta", place = "Grom'gol Base Camp", faction = "Horde", localesIndex = 20},
	[1571] = {zone = "Wetlands", name = "Shellei Brondir", place = "Menethil Harbor", faction = "Alliance", localesIndex = 7},
	[1572] = {zone = "Loch Modan", name = "Thorgrum Borrelson", place = "Thelsamar", faction = "Alliance", localesIndex = 8},
	[1573] = {zone = "Ironforge", name = "Gryth Thurden", faction = "Alliance", localesIndex = 6},
	[2226] = {zone = "Silverpine Forest", name = "Karos Razok", place = "The Sepulcher", faction = "Horde", localesIndex = 10},
	[2299] = {zone = "Burning Steppes", name = "Borgus Stoutarm", place = "Morgan's Vigil", faction = "Alliance", localesIndex = 71},
	[2389] = {zone = "Hillsbrad Foothills", name = "Zarise", place = "Tarren Mill", faction = "Horde", localesIndex = 13},
	[2409] = {zone = "Duskwood", name = "Felicia Maline", place = "Darkshire", faction = "Alliance", localesIndex = 12},
	[2432] = {zone = "Hillsbrad Foothills", name = "Darla Harris", place = "Southshore", faction = "Alliance", localesIndex = 14},
	[2835] = {zone = "Arathi Highlands", name = "Cedrik Prose", place = "Refuge Pointe", faction = "Alliance", localesIndex = 16},
	[2851] = {zone = "Arathi Highlands", name = "Urda", place = "Hammerfall", faction = "Horde", localesIndex = 17},
	[2858] = {zone = "Stranglethorn Vale", name = "Gringer", place = "Booty Bay", faction = "Horde", localesIndex = 18},
	[2859] = {zone = "Stranglethorn Vale", name = "Gyll", place = "Booty Bay", faction = "Alliance", localesIndex = 19},
	[2861] = {zone = "Badlands", name = "Gorrik", place = "Kargath", faction = "Horde", localesIndex = 21},
	[2941] = {zone = "Searing Gorge", name = "Lanie Reed", place = "Thorium Point", faction = "Alliance", localesIndex = 74},	
	[2995] = {zone = "Mulgore", name = "Tal", place = "Thunder Bluff", faction = "Horde", localesIndex = 22},
	[3305] = {zone = "Searing Gorge", name = "Grisha", place = "Thorium Point", faction = "Horde", localesIndex = 75},	
	[3310] = {zone = "Orgrimmar", name = "Doras", faction = "Horde", localesIndex = 23},	            
	[3615] = {zone = "The Barrens", name = "Devrak", place = "Crossroads", faction = "Horde", localesIndex = 25},	      
	[3838] = {zone = "Teldrassil", name = "Vesprystus", place = "Rut'theran Village", faction = "Alliance", localesIndex = 27},           
	[3841] = {zone = "Darkshore", name = "Caylais Moonfeather", place = "Auberdine", faction = "Alliance", localesIndex = 26},            
	[4267] = {zone = "Ashenvale", name = "Daelyshia ", place = "Astranaar", faction = "Alliance", localesIndex = 28},            
	[4312] = {zone = "Stonetalon Mountains", name = "Tharm", place = "Sun Rock Retreat", faction = "Horde", localesIndex = 29},  
	[4314] = {zone = "The Hinterlands", name = "Gorkas", place = "Revantusk Village", faction = "Horde", localesIndex = 76},       
	[4317] = {zone = "Thousand Needles", name = "Nyse", place = "Freewind Post", faction = "Horde", localesIndex = 30},      
	[4319] = {zone = "Feralas", name = "Thyssiana", place = "Thalanaar", faction = "Alliance", localesIndex = 31},               
	[4321] = {zone = "Dustwallow Marsh", name = "Baldruc", place = "Theramore", faction = "Alliance", localesIndex = 32},      
	[4407] = {zone = "Stonetalon Mountains", name = "Teloren", place = "Stonetalon Peak", faction = "Alliance", localesIndex = 33},  
	[4551] = {zone = "Undercity", name = "Michael Garrett", faction = "Horde", localesIndex = 11},                  
	[6026] = {zone = "Swamp of Sorrows", name = "Breyk", place = "Stonard", faction = "Horde", localesIndex = 56},
	[6706] = {zone = "Desolace", name = "Baritanas Skyriver", place = "Nijel's Point", faction = "Alliance", localesIndex = 37},
	[6726] = {zone = "Desolace", name = "Thalon", place = "Shadowprey Village", faction = "Horde", localesIndex = 38},  
	[7823] = {zone = "Tanaris", name = "Bera Stonehammer", place = "Gadgetzan", faction = "Alliance", localesIndex = 39},
	[7824] = {zone = "Tanaris", name = "Bulkrek Ragefist", place = "Gadgetzan", faction = "Horde", localesIndex = 40},  
	[8018] = {zone = "The Hinterlands", name = "Guthrum Thunderfist", place = "Aerie Peak", faction = "Alliance", localesIndex = 43},
	[8019] = {zone = "Feralas", name = "Fyldren Moonfeather", place = "Feathermoon", faction = "Alliance", localesIndex = 41},
	[8020] = {zone = "Feralas", name = "Shyn", place = "Camp Mojache", faction = "Horde", localesIndex = 42},  
	[8609] = {zone = "Blasted Lands", name = "Alexandra Constantine", place = "Nethergarde Keep", faction = "Alliance", localesIndex = 45},
	[8610] = {zone = "Azshara", name = "Kroum", place = "Valormok", faction = "Horde", localesIndex = 44},  
	[10378] = {zone = "The Barrens", name = "Omusa Thunderhorn", place = "Camp Taurajo", faction = "Horde", localesIndex = 77},  
	[10897] = {zone = "Moonglade", name = "Sindrayl", faction = "Alliance", localesIndex = 49},
	[11138] = {zone = "Winterspring", name = "Maethrya", place = "Everlook", faction = "Alliance", localesIndex = 52},
	[11139] = {zone = "Winterspring", name = "Yugrek", place = "Everlook", faction = "Horde", localesIndex = 53},  
	[11899] = {zone = "Dustwallow Marsh", name = "Shardi", place = "Brackenwall Village", faction = "Horde", localesIndex = 55},  
	[11900] = {zone = "Felwood", name = "Brakkar", place = "Bloodvenom Post", faction = "Horde", localesIndex = 48},  
	[11901] = {zone = "Ashenvale", name = "Andruk", place = "Zoram'gar Outpost", faction = "Horde", localesIndex = 58},  
	[12577] = {zone = "Azshara", name = "Jarrodenus", place = "Talrendis Point", faction = "Alliance", localesIndex = 64},
	[12578] = {zone = "Felwood", name = "Mishellena", place = "Talonbranch Glade", faction = "Alliance", localesIndex = 65},
	[12596] = {zone = "Western Plaguelands", name = "Bibilfaz Featherwhistle", place = "Chillwind Camp", faction = "Alliance", localesIndex = 66},
	[12616] = {zone = "Ashenvale", name = "Vhulgra", place = "Splintertree Post", faction = "Horde", localesIndex = 61},  
	[12617] = {zone = "Eastern Plaguelands", name = "Khaelyn Steelwing", place = "Light's Hope Chapel", faction = "Alliance", localesIndex = 67},
	[12636] = {zone = "Eastern Plaguelands", name = "Georgia", place = "Light's Hope Chapel", faction = "Horde", localesIndex = 68},
	[12740] = {zone = "Moonglade", name = "Faustron", faction = "Horde", localesIndex = 69},  
	[13177] = {zone = "Burning Steppes", name = "Vahgruk", place = "Flame Crest", faction = "Horde", localesIndex = 70},  
	[15177] = {zone = "Silithus", name = "Cloud Skydancer", place = "Cenarion Hold", faction = "Alliance", localesIndex = 72},
	[15178] = {zone = "Silithus", name = "Runk Windtamer", place = "Cenarion Hold", faction = "Horde", localesIndex = 73},  
	[10583] = {zone = "Un'Goro Crater", name = "Gryfe", place = "Marshal's Refuge", localesIndex = 79},
	[16227] = {zone = "The Barrens", name = "Bragok", place = "Ratchet", localesIndex = 80},
}

-- Burning Crusade
if select(4, GetBuildInfo()) >= 20000 then
	FM.flightmasterDB[16192] = {zone = "Silvermoon City", name = "Skymistress Gloaming", faction = "Horde", localesIndex = 82}
	FM.flightmasterDB[16189] = {zone = "Ghostlands", name = "Skymaster Sunwing", place = "Tranquillien", faction = "Horde", localesIndex = 83}
	FM.flightmasterDB[17554] = {zone = "Bloodmyst Isle", name = "Laando", place = "Blood Watch", faction = "Alliance", localesIndex = 93}
	FM.flightmasterDB[17555] = {zone = "The Exodar", name = "Stephanos", faction = "Alliance", localesIndex = 94}
	FM.flightmasterDB[16587] = {zone = "Hellfire Peninsula", name = "Barley", place = "Thrallmar", faction = "Horde", localesIndex = 99}
	FM.flightmasterDB[16822] = {zone = "Hellfire Peninsula", name = "Flightmaster Krill Bitterhue", place = "Honor Hold", faction = "Alliance", localesIndex = 100}
	FM.flightmasterDB[18785] = {zone = "Hellfire Peninsula", name = "Kuma", place = "Temple of Telhamat", faction = "Alliance", localesIndex = 101}
	FM.flightmasterDB[18942] = {zone = "Hellfire Peninsula", name = "Innalia", place = "Falcon Watch", faction = "Horde", localesIndex = 102}
	FM.flightmasterDB[18788] = {zone = "Zangarmarsh", name = "Munci", place = "Telredor", faction = "Alliance", localesIndex = 117}
	FM.flightmasterDB[18791] = {zone = "Zangarmarsh", name = "Du'ga", place = "Zabra'jin", faction = "Horde", localesIndex = 118}
	FM.flightmasterDB[18789] = {zone = "Nagrand", name = "Furgu", place = "Telaar", faction = "Alliance", localesIndex = 119}
	FM.flightmasterDB[18808] = {zone = "Nagrand", name = "Gursha", place = "Garadar", faction = "Horde", localesIndex = 120}
	FM.flightmasterDB[18809] = {zone = "Terokkar Forest", name = "Furnan Skysoar", place = "Allerian Stronghold", faction = "Alliance", localesIndex = 121}
	FM.flightmasterDB[18938] = {zone = "Netherstorm", name = "Krexcil", place = "Area 52", localesIndex = 122}
	FM.flightmasterDB[19317] = {zone = "Shadowmoon Valley", name = "Drek'Gol", place = "Shadowmoon Village", faction = "Horde", localesIndex = 123}
	FM.flightmasterDB[18939] = {zone = "Shadowmoon Valley", name = "Brubeck Stormfoot", place = "Wildhammer Stronghold", faction = "Alliance", localesIndex = 124}
	FM.flightmasterDB[18937] = {zone = "Blades Edge Mountains", name = "Amerun Leafshade", place = "Sylvanaar", faction = "Alliance", localesIndex = 125}
	FM.flightmasterDB[18953] = {zone = "Blades Edge Mountains", name = "Unoke Tenderhoof", place = "Thunderlord Stronghold", faction = "Horde", localesIndex = 126}
	FM.flightmasterDB[18807] = {zone = "Terokkar Forest", name = "Kerna", place = "Stonebreaker Hold", faction = "Horde", localesIndex = 127}
	FM.flightmasterDB[18940] = {zone = "Terokkar Forest", name = "Nutral", place = "Shattrath", localesIndex = 128}
	FM.flightmasterDB[18931] = {zone = "Hellfire Peninsula", name = "Amish Wildhammer", place = "The Dark Portal", faction = "Alliance", localesIndex = 129}
	FM.flightmasterDB[18930] = {zone = "Hellfire Peninsula", name = "Vlagga Freyfeather", place = "The Dark Portal", faction = "Horde", localesIndex = 130}
	FM.flightmasterDB[19583] = {zone = "Netherstorm", name = "Grennik", place = "The Stormspire", localesIndex = 139}
	FM.flightmasterDB[19581] = {zone = "Shadowmoon Valley", name = "Maddix", place = "Altar of Sha'tar", localesIndex = 140}
	FM.flightmasterDB[19558] = {zone = "Hellfire Peninsula", name = "Amilya Airheart", place = "Spinebreaker Ridge", faction = "Horde", localesIndex = 141}
	FM.flightmasterDB[20234] = {zone = "Hellfire Peninsula", name = "Runetog Wildhammer", place = "Shatter Point", faction = "Alliance", localesIndex = 149}
	FM.flightmasterDB[20515] = {zone = "Netherstorm", name = "Harpax", place = "Cosmowrench", localesIndex = 150}
	FM.flightmasterDB[20762] = {zone = "Zangarmarsh", name = "Gur'zil", place = "Swamprat Post", faction = "Horde", localesIndex = 151}
	FM.flightmasterDB[21107] = {zone = "Blades Edge Mountains", name = "Rip Pedalslam", place = "Toshley's Station", faction = "Alliance", localesIndex = 156}
	FM.flightmasterDB[21766] = {zone = "Shadowmoon Valley", name = "Alieshor", place = "Sanctum of the Stars", localesIndex = 159}
	FM.flightmasterDB[22216] = {zone = "Blades Edge Mountains", name = "Fhyn Leafshadow", place = "Evergrove", localesIndex = 160}
	FM.flightmasterDB[22455] = {zone = "Blades Edge Mountains", name = "Sky-Master Maxxor", place = "Mok'Nathal Village", faction = "Horde", localesIndex = 163}
	FM.flightmasterDB[22485] = {zone = "Zangarmarsh", name = "Halu", place = "Orebor Harborage", faction = "Alliance", localesIndex = 164}
	FM.flightmasterDB[24851] = {zone = "Ghostlands", name = "Kiz Coilspanner", place = "Zul'Aman", localesIndex = 205}
	FM.flightmasterDB[26560] = {zone = "Isle of Quel Danas", name = "Ohura", place = "Shattered Sun Staging Area", localesIndex = 213}
	FM.flightmasterDB[22931] = {zone = "Felwood", name = "Gorrim", place = "Emerald Sanctuary", localesIndex = 166}
	FM.flightmasterDB[22935] = {zone = "Ashenvale", name = "Suralais Farwind", place = "Forest Song", faction = "Alliance", localesIndex = 167}
	FM.flightmasterDB[23612] = {zone = "Dustwallow Marsh", name = "Dyslix Silvergrub", place = "Mudsprocket", localesIndex = 179}
	FM.flightmasterDB[24366] = {zone = "Stranglethorn Vale", name = "Nizzle", place = "Rebel Camp", faction = "Alliance", localesIndex = 195}
	FM.flightmasterDB[24851] = {zone = "Ghostlands", name = "Kiz Coilspanner", place = "Zul'Aman", localesIndex = 205}
	FM.flightmasterDB[26560] = {zone = "Shattered Sun Staging Area", name = "Ohura", localesIndex = 213}
end

-- Wrath of the Lich King
if select(4, GetBuildInfo()) >= 30000 then
	FM.flightmasterDB[26879] = {zone = "Borean Tundra", name = "Tomas Riverwell", place = "Valiance Keep", faction = "Alliance", localesIndex = 245}
	FM.flightmasterDB[26602] = {zone = "Borean Tundra", name = "Kara Thricestar", place = "Fizzcrank Airstrip", faction = "Alliance", localesIndex = 246}
	FM.flightmasterDB[25288] = {zone = "Borean Tundra", name = "Turida Coldwind", place = "Warsong Hold", faction = "Horde", localesIndex = 257}
	FM.flightmasterDB[26847] = {zone = "Borean Tundra", name = "Omu Spiritbreeze", place = "Taunka'le Village", faction = "Horde", localesIndex = 258}
	FM.flightmasterDB[26848] = {zone = "Borean Tundra", name = "Kimbiza", place = "Bor'gorok Outpost", faction = "Horde", localesIndex = 259}
	FM.flightmasterDB[24795] = {zone = "Borean Tundra", name = "Surristrasz", place = "Amber Ledge", localesIndex = 289}
	FM.flightmasterDB[28195] = {zone = "Borean Tundra", name = "Bilko Driftspark", place = "Unu'pe", localesIndex = 296}
	FM.flightmasterDB[27046] = {zone = "Coldarra", name = "Warmage Adami", place = "Transitus Shield", localesIndex = 226}
	FM.flightmasterDB[30271] = {zone = "Crystalsong Forest", name = "Galendror Whitewing", place = "Windrunner's Overlook", faction = "Alliance", localesIndex = 336}
	FM.flightmasterDB[30269] = {zone = "Crystalsong Forest", name = "Skymaster Baeric ", place = "Sunreaver's Command", faction = "Horde", localesIndex = 337}
	FM.flightmasterDB[96813] = {zone = "Dalaran", name = "Aludane Whitecloud", localesIndex = 310}
	FM.flightmasterDB[26878] = {zone = "Dragonblight", name = "Rodney Wells", place = "Wintergarde Keep", faction = "Alliance", localesIndex = 244}
	FM.flightmasterDB[26881] = {zone = "Dragonblight", name = "Palena Silvercloud ", place = "Stars' Rest", faction = "Alliance", localesIndex = 247}
	FM.flightmasterDB[26877] = {zone = "Dragonblight", name = "Derek Rammel", place = "Fordragon Hold", faction = "Alliance", localesIndex = 251}
	FM.flightmasterDB[26851] = {zone = "Dragonblight", name = "Nethestrasz", place = "Wyrmrest Temple", localesIndex = 252}
	FM.flightmasterDB[26845] = {zone = "Dragonblight", name = "Junter Weiss", place = "Venomspite", faction = "Horde", localesIndex = 254}
	FM.flightmasterDB[26566] = {zone = "Dragonblight", name = "Narzun Skybreaker", place = "Agmar's Hammer", faction = "Horde", localesIndex = 256}
	FM.flightmasterDB[26850] = {zone = "Dragonblight", name = "Numo Spiritbreeze", place = "Kor'koron Vanguard", faction = "Horde", localesIndex = 260}
	FM.flightmasterDB[28196] = {zone = "Dragonblight", name = "Cid Flounderfix", place = "Moa'ki", localesIndex = 294}
	FM.flightmasterDB[26853] = {zone = "Grizzly Hills", name = "Makki Wintergale", place = "Camp Oneqwah", faction = "Horde", localesIndex = 249}
	FM.flightmasterDB[26852] = {zone = "Grizzly Hills", name = "Kragh", place = "Conquest Hold", faction = "Horde", localesIndex = 250}
	FM.flightmasterDB[26880] = {zone = "Grizzly Hills", name = "Vana Grey", place = "Amberpine Lodge", faction = "Alliance", localesIndex = 253}
	FM.flightmasterDB[26876] = {zone = "Grizzly Hills", name = "Samuel Clearbook", place = "Westfall Brigade", faction = "Alliance", localesIndex = 255}
	FM.flightmasterDB[23736] = {zone = "Howling Fjord", name = "Pricilla Winterwind", place = "Valgarde Port", faction = "Alliance", localesIndex = 183}
	FM.flightmasterDB[24061] = {zone = "Howling Fjord", name = "James Ormsby", place = "Fort Wildervar", faction = "Alliance", localesIndex = 184}
	FM.flightmasterDB[23859] = {zone = "Howling Fjord", name = "Greer Orehammer", place = "Westguard Keep", faction = "Alliance", localesIndex = 185}
	FM.flightmasterDB[24155] = {zone = "Howling Fjord", name = "Tobias Sarkhoff", place = "New Agamand", faction = "Horde", localesIndex = 190}
	FM.flightmasterDB[27344] = {zone = "Howling Fjord", name = "Bat Handler Adeline", place = "Vengeance Landing", faction = "Horde", localesIndex = 191}
	FM.flightmasterDB[24032] = {zone = "Howling Fjord", name = "Celea Frozenmane", place = "Camp Winterhoof", faction = "Horde", localesIndex = 192}
	FM.flightmasterDB[26844] = {zone = "Howling Fjord", name = "Lilleth Radescu", place = "Apothecary Camp", faction = "Horde", localesIndex = 248}
	FM.flightmasterDB[28197] = {zone = "Howling Fjord", name = "Kip Trawlskip", place = "Kamagua", localesIndex = 295}
	FM.flightmasterDB[31078] = {zone = "Icecrown", name = "Dreadwind", place = "Death's Rise", localesIndex = 325}
	FM.flightmasterDB[30314] = {zone = "Icecrown", name = "Morlia Doomwing", place = "The Shadow Vault", faction = "Horde", localesIndex = 333}
	FM.flightmasterDB[33849] = {zone = "Icecrown", name = "Helidan Lightwing", place = "The Argent Vanguard", localesIndex = 334}
	FM.flightmasterDB[31069] = {zone = "Icecrown", name = "Penumbrius", place = "Crusaders' Pinnacle", localesIndex = 335}
	FM.flightmasterDB[28574] = {zone = "Sholazar Basin", name = "Marvin Wobblesprocket", place = "River's Heart", localesIndex = 308}
	FM.flightmasterDB[28037] = {zone = "Sholazar Basin", name = "The Spirit of Gnomeregan", place = "Nesingwary Base Camp", localesIndex = 309}
	FM.flightmasterDB[29721] = {zone = "The Storm Peaks", name = "Skizzle Slickslide", place = "K3", localesIndex = 320}
	FM.flightmasterDB[29750] = {zone = "The Storm Peaks", name = "Faldorf Bitterchill", place = "Frosthold", faction = "Alliance", localesIndex = 321}
	FM.flightmasterDB[32571] = {zone = "The Storm Peaks", name = "Halvdan ", place = "Dun Nifflelem", localesIndex = 322}
	FM.flightmasterDB[29757] = {zone = "The Storm Peaks", name = "Kabarg Windtamer", place = "Grom'arsh Crash-Site", faction = "Horde", localesIndex = 323}
	FM.flightmasterDB[29762] = {zone = "The Storm Peaks", name = "Hyeyoung Parka", place = "Camp Tunka'lo", faction = "Horde", localesIndex = 324}
	FM.flightmasterDB[29951] = {zone = "The Storm Peaks", name = "Shavalius the Fancy", place = "Ulduar", localesIndex = 326}
	FM.flightmasterDB[29950] = {zone = "The Storm Peaks", name = "Breck Rockbrow", place = "Bouldercrag's Refuge", localesIndex = 327}
	FM.flightmasterDB[30869] = {zone = "Wintergrasp", name = "Arzo Safeflight", place = "Valiance Landing Camp", faction = "Alliance", localesIndex = 303}
	FM.flightmasterDB[30870] = {zone = "Wintergrasp", name = "Herzo Safeflight", place = "Warsong Camp", faction = "Horde", localesIndex = 332}
	FM.flightmasterDB[28623] = {zone = "Zul'Drak", name = "Gurric", place = "Argent Stand", faction = "Horde", localesIndex = 290}
	FM.flightmasterDB[28615] = {zone = "Zul'Drak", name = "Baneflight", place = "Ebon Watch", localesIndex = 305}
	FM.flightmasterDB[28618] = {zone = "Zul'Drak", name = "Danica Saint", place = "Light's Breach", localesIndex = 306}
	FM.flightmasterDB[28624] = {zone = "Zul'Drak", name = "Maaka", place = "Zim'Torga", localesIndex = 307}
	FM.flightmasterDB[30569] = {zone = "Zul'Drak", name = "Rafae", place = "Gundrak", localesIndex = 331}
	FM.flightmasterDB[37888] = {zone = "Western Plaguelands", name = "Frax Bucketdrop", place = "Thondoril River", localesIndex = 383}
	FM.flightmasterDB[37915] = {zone = "Tirisfal", name = "Timothy Cunningham", place = "The Bulwark", faction = "Horde", localesIndex = 384}
end

function FM.getNearestFlightPoint(x, y, instance, faction)
	local minDist, minPos, minId
	for id, master in pairs(FM.flightmasterDB) do
		local pos = PT.getNPCPosition(id)
		if pos and pos.instance == instance and ((master.faction or faction) == faction) then
			local dist = (x - pos.wx) * (x - pos.wx) + (y - pos.wy) * (y - pos.wy)
			if minDist == nil or dist < minDist then
				minDist = dist
				minPos = pos
				minId = id
			end
		end
	end
	return minPos
end

function FM.getFlightPoint(id)
	if id == nil then return end
	return PT.getNPCPosition(id)
end

local function getFlightmasterByPlaceHelper(place, faction, func)
	local result
	for id, master in pairs(FM.flightmasterDB) do
		if faction == nil or ((master.faction or faction) == faction) then
			local value = func(master)
			if value ~= nil and value == place then
				if result == nil then 
					result = id 
				else 
					result = nil 
					break
				end
			end
		end
	end
	if result ~= nil then return result end
	for id, master in pairs(FM.flightmasterDB) do
		if faction == nil or ((master.faction or faction) == faction) then
			local value = func(master)
			if value ~= nil and value:sub(1, #place) == place then
				if result == nil then 
					result = id 
				else 
					result = nil 
					break
				end
			end
		end
	end
	if result ~= nil then return result end
	for id, master in pairs(FM.flightmasterDB) do
		if faction == nil or ((master.faction or faction) == faction) then
			local value = func(master)
			if value ~= nil and value == place:sub(1, #value) then
				if result == nil then 
					result = id 
				else 
					result = nil 
					break
				end
			end
		end
	end
	return result
end
	
function FM.getFlightmasterByPlace(place, faction)
	place = place:gsub(" ",""):gsub("'",""):lower()
	local result = getFlightmasterByPlaceHelper(place, faction, function(master) return master.zone:gsub(" ",""):gsub("'",""):lower() end)
	if result ~= nil then return result end
	result = getFlightmasterByPlaceHelper(place, faction, function(master) if master.place ~= nil then return master.place:gsub(" ",""):gsub("'",""):lower() end end)
	if result ~= nil then return result end
	result = getFlightmasterByPlaceHelper(place, faction, function(master) 
		local place = master.place and master.place:gsub(" ",""):gsub("'",""):lower()
		if place ~= nil and place:sub(1,3) == "the" then place = place:sub(4) end
		return place
	end)
	if result ~= nil then return result end
	for locale, flightmasters in pairs(FM.flightmasterDB_Locales) do
		result = getFlightmasterByPlaceHelper(place, faction, function(master) 
			return flightmasters[master.localesIndex]:gsub(" ",""):gsub(" ",""):gsub("'",""):lower() 
		end)
		if result ~= nil then return result end
	end
	result = getFlightmasterByPlaceHelper(place, faction, function(master) return DM.mapIDs[master.zone] and HBD:GetLocalizedMap(DM.mapIDs[master.zone]) and HBD:GetLocalizedMap(DM.mapIDs[master.zone]):gsub(" ",""):lower() end)
	return result
end

function FM.isFlightmasterMatch(master, name)
	if (master.place or master.zone) == name:sub(1, #(master.place or master.zone)) then return true end
	-- additional check for weird case where it is "place, zone" e.g. "Hellfire Peninsula, The Dark Portal"
	if master.place ~= nil and master.zone .. ", " .. master.place == name:sub(1, #(master.zone .. ", " .. master.place)) then return true end
	if FM.flightmasterDB_Locales[GetLocale()][master.localesIndex] == name then return true end
	return false
end
	