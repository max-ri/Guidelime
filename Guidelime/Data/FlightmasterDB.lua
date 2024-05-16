local addonName, addon = ...

local HBD = LibStub("HereBeDragons-2.0")

addon.DM = addon.DM or {}; local DM = addon.DM -- Data/MapDB
addon.PT = addon.PT or {}; local PT = addon.PT -- Data/PositionTools

addon.FM = addon.FM or {}; local FM = addon.FM -- Data/FlightmasterDB

FM.flightmasterDB = {
	[2] = {npcId = 352, zone = "Stormwind City", name = "Dungar Longdrink", place = "Stormwind", faction = "Alliance", id = 2},
	[4] = {npcId = 523, zone = "Westfall", name = "Thor", place = "Sentinel Hill", faction = "Alliance", id = 4},
	[5] = {npcId = 931, zone = "Redridge Mountains", name = "Ariena Stormfeather", place = "Lakeshire", faction = "Alliance", id = 5},
	[20] = {npcId = 1387, zone = "Stranglethorn Vale", name = "Thysta", place = "Grom'gol Base Camp", faction = "Horde", id = 20},
	[7] = {npcId = 1571, zone = "Wetlands", name = "Shellei Brondir", place = "Menethil Harbor", faction = "Alliance", id = 7},
	[8] = {npcId = 1572, zone = "Loch Modan", name = "Thorgrum Borrelson", place = "Thelsamar", faction = "Alliance", id = 8},
	[6] = {npcId = 1573, zone = "Ironforge", name = "Gryth Thurden", faction = "Alliance", id = 6},
	[10] = {npcId = 2226, zone = "Silverpine Forest", name = "Karos Razok", place = "The Sepulcher", faction = "Horde", id = 10},
	[71] = {npcId = 2299, zone = "Burning Steppes", name = "Borgus Stoutarm", place = "Morgan's Vigil", faction = "Alliance", id = 71},
	[13] = {npcId = 2389, zone = "Hillsbrad Foothills", name = "Zarise", place = "Tarren Mill", faction = "Horde", id = 13},
	[12] = {npcId = 2409, zone = "Duskwood", name = "Felicia Maline", place = "Darkshire", faction = "Alliance", id = 12},
	[14] = {npcId = 2432, zone = "Hillsbrad Foothills", name = "Darla Harris", place = "Southshore", faction = "Alliance", id = 14},
	[16] = {npcId = 2835, zone = "Arathi Highlands", name = "Cedrik Prose", place = "Refuge Pointe", faction = "Alliance", id = 16},
	[17] = {npcId = 2851, zone = "Arathi Highlands", name = "Urda", place = "Hammerfall", faction = "Horde", id = 17},
	[18] = {npcId = 2858, zone = "Stranglethorn Vale", name = "Gringer", place = "Booty Bay", faction = "Horde", id = 18},
	[19] = {npcId = 2859, zone = "Stranglethorn Vale", name = "Gyll", place = "Booty Bay", faction = "Alliance", id = 19},
	[21] = {npcId = 2861, zone = "Badlands", name = "Gorrik", place = "Kargath", faction = "Horde", id = 21},
	[74] = {npcId = 2941, zone = "Searing Gorge", name = "Lanie Reed", place = "Thorium Point", faction = "Alliance", id = 74},	
	[22] = {npcId = 2995, zone = "Mulgore", name = "Tal", place = "Thunder Bluff", faction = "Horde", id = 22},
	[75] = {npcId = 3305, zone = "Searing Gorge", name = "Grisha", place = "Thorium Point", faction = "Horde", id = 75},	
	[23] = {npcId = 3310, zone = "Orgrimmar", name = "Doras", faction = "Horde", id = 23},	            
	[25] = {npcId = 3615, zone = "The Barrens", name = "Devrak", place = "Crossroads", faction = "Horde", id = 25},	      
	[27] = {npcId = 3838, zone = "Teldrassil", name = "Vesprystus", place = "Rut'theran Village", faction = "Alliance", id = 27},           
	[26] = {npcId = 3841, zone = "Darkshore", name = "Caylais Moonfeather", place = "Auberdine", faction = "Alliance", id = 26},            
	[28] = {npcId = 4267, zone = "Ashenvale", name = "Daelyshia ", place = "Astranaar", faction = "Alliance", id = 28},            
	[29] = {npcId = 4312, zone = "Stonetalon Mountains", name = "Tharm", place = "Sun Rock Retreat", faction = "Horde", id = 29},  
	[76] = {npcId = 4314, zone = "The Hinterlands", name = "Gorkas", place = "Revantusk Village", faction = "Horde", id = 76},       
	[30] = {npcId = 4317, zone = "Thousand Needles", name = "Nyse", place = "Freewind Post", faction = "Horde", id = 30},      
	[31] = {npcId = 4319, zone = "Feralas", name = "Thyssiana", place = "Thalanaar", faction = "Alliance", id = 31},               
	[32] = {npcId = 4321, zone = "Dustwallow Marsh", name = "Baldruc", place = "Theramore", faction = "Alliance", id = 32},      
	[33] = {npcId = 4407, zone = "Stonetalon Mountains", name = "Teloren", place = "Stonetalon Peak", faction = "Alliance", id = 33},  
	[11] = {npcId = 4551, zone = "Undercity", name = "Michael Garrett", faction = "Horde", id = 11},                  
	[56] = {npcId = 6026, zone = "Swamp of Sorrows", name = "Breyk", place = "Stonard", faction = "Horde", id = 56},
	[37] = {npcId = 6706, zone = "Desolace", name = "Baritanas Skyriver", place = "Nijel's Point", faction = "Alliance", id = 37},
	[38] = {npcId = 6726, zone = "Desolace", name = "Thalon", place = "Shadowprey Village", faction = "Horde", id = 38},  
	[39] = {npcId = 7823, zone = "Tanaris", name = "Bera Stonehammer", place = "Gadgetzan", faction = "Alliance", id = 39},
	[40] = {npcId = 7824, zone = "Tanaris", name = "Bulkrek Ragefist", place = "Gadgetzan", faction = "Horde", id = 40},  
	[43] = {npcId = 8018, zone = "The Hinterlands", name = "Guthrum Thunderfist", place = "Aerie Peak", faction = "Alliance", id = 43},
	[41] = {npcId = 8019, zone = "Feralas", name = "Fyldren Moonfeather", place = "Feathermoon", faction = "Alliance", id = 41},
	[42] = {npcId = 8020, zone = "Feralas", name = "Shyn", place = "Camp Mojache", faction = "Horde", id = 42},  
	[45] = {npcId = 8609, zone = "Blasted Lands", name = "Alexandra Constantine", place = "Nethergarde Keep", faction = "Alliance", id = 45},
	[44] = {npcId = 8610, zone = "Azshara", name = "Kroum", place = "Valormok", faction = "Horde", id = 44},  
	[77] = {npcId = 10378, zone = "The Barrens", name = "Omusa Thunderhorn", place = "Camp Taurajo", faction = "Horde", id = 77},  
	[49] = {npcId = 10897, zone = "Moonglade", name = "Sindrayl", faction = "Alliance", id = 49},
	[52] = {npcId = 11138, zone = "Winterspring", name = "Maethrya", place = "Everlook", faction = "Alliance", id = 52},
	[53] = {npcId = 11139, zone = "Winterspring", name = "Yugrek", place = "Everlook", faction = "Horde", id = 53},  
	[55] = {npcId = 11899, zone = "Dustwallow Marsh", name = "Shardi", place = "Brackenwall Village", faction = "Horde", id = 55},  
	[48] = {npcId = 11900, zone = "Felwood", name = "Brakkar", place = "Bloodvenom Post", faction = "Horde", id = 48},  
	[58] = {npcId = 11901, zone = "Ashenvale", name = "Andruk", place = "Zoram'gar Outpost", faction = "Horde", id = 58},  
	[64] = {npcId = 12577, zone = "Azshara", name = "Jarrodenus", place = "Talrendis Point", faction = "Alliance", id = 64},
	[65] = {npcId = 12578, zone = "Felwood", name = "Mishellena", place = "Talonbranch Glade", faction = "Alliance", id = 65},
	[66] = {npcId = 12596, zone = "Western Plaguelands", name = "Bibilfaz Featherwhistle", place = "Chillwind Camp", faction = "Alliance", id = 66},
	[61] = {npcId = 12616, zone = "Ashenvale", name = "Vhulgra", place = "Splintertree Post", faction = "Horde", id = 61},  
	[67] = {npcId = 12617, zone = "Eastern Plaguelands", name = "Khaelyn Steelwing", place = "Light's Hope Chapel", faction = "Alliance", id = 67},
	[68] = {npcId = 12636, zone = "Eastern Plaguelands", name = "Georgia", place = "Light's Hope Chapel", faction = "Horde", id = 68},
	[69] = {npcId = 12740, zone = "Moonglade", name = "Faustron", faction = "Horde", id = 69},  
	[70] = {npcId = 13177, zone = "Burning Steppes", name = "Vahgruk", place = "Flame Crest", faction = "Horde", id = 70},  
	[72] = {npcId = 15177, zone = "Silithus", name = "Cloud Skydancer", place = "Cenarion Hold", faction = "Alliance", id = 72},
	[73] = {npcId = 15178, zone = "Silithus", name = "Runk Windtamer", place = "Cenarion Hold", faction = "Horde", id = 73},  
	[79] = {npcId = 10583, zone = "Un'Goro Crater", name = "Gryfe", place = "Marshal's Refuge", id = 79},
	[80] = {npcId = 16227, zone = "The Barrens", name = "Bragok", place = "Ratchet", id = 80},
}

-- Burning Crusade
if select(4, GetBuildInfo()) >= 20000 then
	FM.flightmasterDB[82] = {npcId = 16192, zone = "Silvermoon City", name = "Skymistress Gloaming", faction = "Horde", id = 82}
	FM.flightmasterDB[83] = {npcId = 16189, zone = "Ghostlands", name = "Skymaster Sunwing", place = "Tranquillien", faction = "Horde", id = 83}
	FM.flightmasterDB[93] = {npcId = 17554, zone = "Bloodmyst Isle", name = "Laando", place = "Blood Watch", faction = "Alliance", id = 93}
	FM.flightmasterDB[94] = {npcId = 17555, zone = "The Exodar", name = "Stephanos", faction = "Alliance", id = 94}
	FM.flightmasterDB[99] = {npcId = 16587, zone = "Hellfire Peninsula", name = "Barley", place = "Thrallmar", faction = "Horde", id = 99}
	FM.flightmasterDB[100] = {npcId = 16822, zone = "Hellfire Peninsula", name = "Flightmaster Krill Bitterhue", place = "Honor Hold", faction = "Alliance", id = 100}
	FM.flightmasterDB[101] = {npcId = 18785, zone = "Hellfire Peninsula", name = "Kuma", place = "Temple of Telhamat", faction = "Alliance", id = 101}
	FM.flightmasterDB[102] = {npcId = 18942, zone = "Hellfire Peninsula", name = "Innalia", place = "Falcon Watch", faction = "Horde", id = 102}
	FM.flightmasterDB[117] = {npcId = 18788, zone = "Zangarmarsh", name = "Munci", place = "Telredor", faction = "Alliance", id = 117}
	FM.flightmasterDB[118] = {npcId = 18791, zone = "Zangarmarsh", name = "Du'ga", place = "Zabra'jin", faction = "Horde", id = 118}
	FM.flightmasterDB[119] = {npcId = 18789, zone = "Nagrand", name = "Furgu", place = "Telaar", faction = "Alliance", id = 119}
	FM.flightmasterDB[120] = {npcId = 18808, zone = "Nagrand", name = "Gursha", place = "Garadar", faction = "Horde", id = 120}
	FM.flightmasterDB[121] = {npcId = 18809, zone = "Terokkar Forest", name = "Furnan Skysoar", place = "Allerian Stronghold", faction = "Alliance", id = 121}
	FM.flightmasterDB[122] = {npcId = 18938, zone = "Netherstorm", name = "Krexcil", place = "Area 52", id = 122}
	FM.flightmasterDB[123] = {npcId = 19317, zone = "Shadowmoon Valley", name = "Drek'Gol", place = "Shadowmoon Village", faction = "Horde", id = 123}
	FM.flightmasterDB[124] = {npcId = 18939, zone = "Shadowmoon Valley", name = "Brubeck Stormfoot", place = "Wildhammer Stronghold", faction = "Alliance", id = 124}
	FM.flightmasterDB[125] = {npcId = 18937, zone = "Blades Edge Mountains", name = "Amerun Leafshade", place = "Sylvanaar", faction = "Alliance", id = 125}
	FM.flightmasterDB[126] = {npcId = 18953, zone = "Blades Edge Mountains", name = "Unoke Tenderhoof", place = "Thunderlord Stronghold", faction = "Horde", id = 126}
	FM.flightmasterDB[127] = {npcId = 18807, zone = "Terokkar Forest", name = "Kerna", place = "Stonebreaker Hold", faction = "Horde", id = 127}
	FM.flightmasterDB[128] = {npcId = 18940, zone = "Terokkar Forest", name = "Nutral", place = "Shattrath", id = 128}
	FM.flightmasterDB[129] = {npcId = 18931, zone = "Hellfire Peninsula", name = "Amish Wildhammer", place = "The Dark Portal", faction = "Alliance", id = 129}
	FM.flightmasterDB[130] = {npcId = 18930, zone = "Hellfire Peninsula", name = "Vlagga Freyfeather", place = "The Dark Portal", faction = "Horde", id = 130}
	FM.flightmasterDB[139] = {npcId = 19583, zone = "Netherstorm", name = "Grennik", place = "The Stormspire", id = 139}
	FM.flightmasterDB[140] = {npcId = 19581, zone = "Shadowmoon Valley", name = "Maddix", place = "Altar of Sha'tar", id = 140}
	FM.flightmasterDB[141] = {npcId = 19558, zone = "Hellfire Peninsula", name = "Amilya Airheart", place = "Spinebreaker Ridge", faction = "Horde", id = 141}
	FM.flightmasterDB[149] = {npcId = 20234, zone = "Hellfire Peninsula", name = "Runetog Wildhammer", place = "Shatter Point", faction = "Alliance", id = 149}
	FM.flightmasterDB[150] = {npcId = 20515, zone = "Netherstorm", name = "Harpax", place = "Cosmowrench", id = 150}
	FM.flightmasterDB[151] = {npcId = 20762, zone = "Zangarmarsh", name = "Gur'zil", place = "Swamprat Post", faction = "Horde", id = 151}
	FM.flightmasterDB[156] = {npcId = 21107, zone = "Blades Edge Mountains", name = "Rip Pedalslam", place = "Toshley's Station", faction = "Alliance", id = 156}
	FM.flightmasterDB[159] = {npcId = 21766, zone = "Shadowmoon Valley", name = "Alieshor", place = "Sanctum of the Stars", id = 159}
	FM.flightmasterDB[160] = {npcId = 22216, zone = "Blades Edge Mountains", name = "Fhyn Leafshadow", place = "Evergrove", id = 160}
	FM.flightmasterDB[163] = {npcId = 22455, zone = "Blades Edge Mountains", name = "Sky-Master Maxxor", place = "Mok'Nathal Village", faction = "Horde", id = 163}
	FM.flightmasterDB[164] = {npcId = 22485, zone = "Zangarmarsh", name = "Halu", place = "Orebor Harborage", faction = "Alliance", id = 164}
	FM.flightmasterDB[205] = {npcId = 24851, zone = "Ghostlands", name = "Kiz Coilspanner", place = "Zul'Aman", id = 205}
	FM.flightmasterDB[213] = {npcId = 26560, zone = "Isle of Quel Danas", name = "Ohura", place = "Shattered Sun Staging Area", id = 213}
	FM.flightmasterDB[166] = {npcId = 22931, zone = "Felwood", name = "Gorrim", place = "Emerald Sanctuary", id = 166}
	FM.flightmasterDB[167] = {npcId = 22935, zone = "Ashenvale", name = "Suralais Farwind", place = "Forest Song", faction = "Alliance", id = 167}
	FM.flightmasterDB[179] = {npcId = 23612, zone = "Dustwallow Marsh", name = "Dyslix Silvergrub", place = "Mudsprocket", id = 179}
	FM.flightmasterDB[195] = {npcId = 24366, zone = "Stranglethorn Vale", name = "Nizzle", place = "Rebel Camp", faction = "Alliance", id = 195}
	FM.flightmasterDB[205] = {npcId = 24851, zone = "Ghostlands", name = "Kiz Coilspanner", place = "Zul'Aman", id = 205}
	FM.flightmasterDB[213] = {npcId = 26560, zone = "Shattered Sun Staging Area", name = "Ohura", id = 213}
end

-- Wrath of the Lich King
if select(4, GetBuildInfo()) >= 30000 then
	FM.flightmasterDB[245] = {npcId = 26879, zone = "Borean Tundra", name = "Tomas Riverwell", place = "Valiance Keep", faction = "Alliance", id = 245}
	FM.flightmasterDB[246] = {npcId = 26602, zone = "Borean Tundra", name = "Kara Thricestar", place = "Fizzcrank Airstrip", faction = "Alliance", id = 246}
	FM.flightmasterDB[257] = {npcId = 25288, zone = "Borean Tundra", name = "Turida Coldwind", place = "Warsong Hold", faction = "Horde", id = 257}
	FM.flightmasterDB[258] = {npcId = 26847, zone = "Borean Tundra", name = "Omu Spiritbreeze", place = "Taunka'le Village", faction = "Horde", id = 258}
	FM.flightmasterDB[259] = {npcId = 26848, zone = "Borean Tundra", name = "Kimbiza", place = "Bor'gorok Outpost", faction = "Horde", id = 259}
	FM.flightmasterDB[289] = {npcId = 24795, zone = "Borean Tundra", name = "Surristrasz", place = "Amber Ledge", id = 289}
	FM.flightmasterDB[296] = {npcId = 28195, zone = "Borean Tundra", name = "Bilko Driftspark", place = "Unu'pe", id = 296}
	FM.flightmasterDB[226] = {npcId = 27046, zone = "Coldarra", name = "Warmage Adami", place = "Transitus Shield", id = 226}
	FM.flightmasterDB[336] = {npcId = 30271, zone = "Crystalsong Forest", name = "Galendror Whitewing", place = "Windrunner's Overlook", faction = "Alliance", id = 336}
	FM.flightmasterDB[337] = {npcId = 30269, zone = "Crystalsong Forest", name = "Skymaster Baeric ", place = "Sunreaver's Command", faction = "Horde", id = 337}
	FM.flightmasterDB[310] = {npcId = 28674, zone = "Dalaran", name = "Aludane Whitecloud", id = 310}
	FM.flightmasterDB[244] = {npcId = 26878, zone = "Dragonblight", name = "Rodney Wells", place = "Wintergarde Keep", faction = "Alliance", id = 244}
	FM.flightmasterDB[247] = {npcId = 26881, zone = "Dragonblight", name = "Palena Silvercloud ", place = "Stars' Rest", faction = "Alliance", id = 247}
	FM.flightmasterDB[251] = {npcId = 26877, zone = "Dragonblight", name = "Derek Rammel", place = "Fordragon Hold", faction = "Alliance", id = 251}
	FM.flightmasterDB[252] = {npcId = 26851, zone = "Dragonblight", name = "Nethestrasz", place = "Wyrmrest Temple", id = 252}
	FM.flightmasterDB[254] = {npcId = 26845, zone = "Dragonblight", name = "Junter Weiss", place = "Venomspite", faction = "Horde", id = 254}
	FM.flightmasterDB[256] = {npcId = 26566, zone = "Dragonblight", name = "Narzun Skybreaker", place = "Agmar's Hammer", faction = "Horde", id = 256}
	FM.flightmasterDB[260] = {npcId = 26850, zone = "Dragonblight", name = "Numo Spiritbreeze", place = "Kor'koron Vanguard", faction = "Horde", id = 260}
	FM.flightmasterDB[294] = {npcId = 28196, zone = "Dragonblight", name = "Cid Flounderfix", place = "Moa'ki", id = 294}
	FM.flightmasterDB[249] = {npcId = 26853, zone = "Grizzly Hills", name = "Makki Wintergale", place = "Camp Oneqwah", faction = "Horde", id = 249}
	FM.flightmasterDB[250] = {npcId = 26852, zone = "Grizzly Hills", name = "Kragh", place = "Conquest Hold", faction = "Horde", id = 250}
	FM.flightmasterDB[253] = {npcId = 26880, zone = "Grizzly Hills", name = "Vana Grey", place = "Amberpine Lodge", faction = "Alliance", id = 253}
	FM.flightmasterDB[255] = {npcId = 26876, zone = "Grizzly Hills", name = "Samuel Clearbook", place = "Westfall Brigade", faction = "Alliance", id = 255}
	FM.flightmasterDB[183] = {npcId = 23736, zone = "Howling Fjord", name = "Pricilla Winterwind", place = "Valgarde Port", faction = "Alliance", id = 183}
	FM.flightmasterDB[184] = {npcId = 24061, zone = "Howling Fjord", name = "James Ormsby", place = "Fort Wildervar", faction = "Alliance", id = 184}
	FM.flightmasterDB[185] = {npcId = 23859, zone = "Howling Fjord", name = "Greer Orehammer", place = "Westguard Keep", faction = "Alliance", id = 185}
	FM.flightmasterDB[190] = {npcId = 24155, zone = "Howling Fjord", name = "Tobias Sarkhoff", place = "New Agamand", faction = "Horde", id = 190}
	FM.flightmasterDB[191] = {npcId = 27344, zone = "Howling Fjord", name = "Bat Handler Adeline", place = "Vengeance Landing", faction = "Horde", id = 191}
	FM.flightmasterDB[192] = {npcId = 24032, zone = "Howling Fjord", name = "Celea Frozenmane", place = "Camp Winterhoof", faction = "Horde", id = 192}
	FM.flightmasterDB[248] = {npcId = 26844, zone = "Howling Fjord", name = "Lilleth Radescu", place = "Apothecary Camp", faction = "Horde", id = 248}
	FM.flightmasterDB[295] = {npcId = 28197, zone = "Howling Fjord", name = "Kip Trawlskip", place = "Kamagua", id = 295}
	FM.flightmasterDB[325] = {npcId = 31078, zone = "Icecrown", name = "Dreadwind", place = "Death's Rise", id = 325}
	FM.flightmasterDB[333] = {npcId = 30314, zone = "Icecrown", name = "Morlia Doomwing", place = "The Shadow Vault", faction = "Horde", id = 333}
	FM.flightmasterDB[334] = {npcId = 33849, zone = "Icecrown", name = "Helidan Lightwing", place = "The Argent Vanguard", id = 334}
	FM.flightmasterDB[335] = {npcId = 31069, zone = "Icecrown", name = "Penumbrius", place = "Crusaders' Pinnacle", id = 335}
	FM.flightmasterDB[308] = {npcId = 28574, zone = "Sholazar Basin", name = "Marvin Wobblesprocket", place = "River's Heart", id = 308}
	FM.flightmasterDB[309] = {npcId = 28037, zone = "Sholazar Basin", name = "The Spirit of Gnomeregan", place = "Nesingwary Base Camp", id = 309}
	FM.flightmasterDB[320] = {npcId = 29721, zone = "The Storm Peaks", name = "Skizzle Slickslide", place = "K3", id = 320}
	FM.flightmasterDB[321] = {npcId = 29750, zone = "The Storm Peaks", name = "Faldorf Bitterchill", place = "Frosthold", faction = "Alliance", id = 321}
	FM.flightmasterDB[322] = {npcId = 32571, zone = "The Storm Peaks", name = "Halvdan ", place = "Dun Nifflelem", id = 322}
	FM.flightmasterDB[323] = {npcId = 29757, zone = "The Storm Peaks", name = "Kabarg Windtamer", place = "Grom'arsh Crash-Site", faction = "Horde", id = 323}
	FM.flightmasterDB[324] = {npcId = 29762, zone = "The Storm Peaks", name = "Hyeyoung Parka", place = "Camp Tunka'lo", faction = "Horde", id = 324}
	FM.flightmasterDB[326] = {npcId = 29951, zone = "The Storm Peaks", name = "Shavalius the Fancy", place = "Ulduar", id = 326}
	FM.flightmasterDB[327] = {npcId = 29950, zone = "The Storm Peaks", name = "Breck Rockbrow", place = "Bouldercrag's Refuge", id = 327}
	FM.flightmasterDB[303] = {npcId = 30869, zone = "Wintergrasp", name = "Arzo Safeflight", place = "Valiance Landing Camp", faction = "Alliance", id = 303}
	FM.flightmasterDB[332] = {npcId = 30870, zone = "Wintergrasp", name = "Herzo Safeflight", place = "Warsong Camp", faction = "Horde", id = 332}
	FM.flightmasterDB[290] = {npcId = 28623, zone = "Zul'Drak", name = "Gurric", place = "Argent Stand", faction = "Horde", id = 290}
	FM.flightmasterDB[305] = {npcId = 28615, zone = "Zul'Drak", name = "Baneflight", place = "Ebon Watch", id = 305}
	FM.flightmasterDB[306] = {npcId = 28618, zone = "Zul'Drak", name = "Danica Saint", place = "Light's Breach", id = 306}
	FM.flightmasterDB[307] = {npcId = 28624, zone = "Zul'Drak", name = "Maaka", place = "Zim'Torga", id = 307}
	FM.flightmasterDB[331] = {npcId = 30569, zone = "Zul'Drak", name = "Rafae", place = "Gundrak", id = 331}
	FM.flightmasterDB[383] = {npcId = 37888, zone = "Western Plaguelands", name = "Frax Bucketdrop", place = "Thondoril River", id = 383}
	FM.flightmasterDB[384] = {npcId = 37915, zone = "Tirisfal", name = "Timothy Cunningham", place = "The Bulwark", faction = "Horde", id = 384}
end

-- Cataclysm
if select(4, GetBuildInfo()) >= 40000 then
	FM.flightmasterDB[338] = {zone = "Ashenvale", place = "Blackfathom Camp", faction = "Alliance", wx = 654.15997314453, wy = 3880.5100097656, instance = 1, id = 338}
	FM.flightmasterDB[339] = {zone = "Darkshore", place = "Grove of the Ancients", faction = "Alliance", wx = 147.64999389648, wy = 4970.5, instance = 1, id = 339}
	FM.flightmasterDB[340] = {zone = "Icecrown", place = "Argent Tournament Grounds", wx = 891.20001220703, wy = 8475.7900390625, instance = 571, id = 340}
	FM.flightmasterDB[350] = {zone = "Ashenvale", place = "Hellscream's Watch", faction = "Horde", wx = -498.95001220703, wy = 3049.080078125, instance = 1, id = 350}
	FM.flightmasterDB[351] = {zone = "Ashenvale", place = "Stardust Spire", faction = "Alliance", wx = -321.98999023438, wy = 1905.1099853516, instance = 1, id = 351}
	FM.flightmasterDB[354] = {zone = "Ashenvale", place = "The Mor'Shan Ramparts", faction = "Horde", wx = -2209.1499023438, wy = 1206.0500488281, instance = 1, id = 354}
	FM.flightmasterDB[356] = {zone = "Ashenvale", place = "Silverwind Refuge", faction = "Horde", wx = -1144.0500488281, wy = 2159.6201171875, instance = 1, id = 356}
	FM.flightmasterDB[360] = {zone = "Stonetalon Mountains", place = "Cliffwalker Post", faction = "Horde", wx = 1241.8900146484, wy = 2188.0, instance = 1, id = 360}
	FM.flightmasterDB[361] = {zone = "Stonetalon Mountains", place = "Windshear Hold", faction = "Alliance", wx = 432.86999511719, wy = 1268.5100097656, instance = 1, id = 361}
	FM.flightmasterDB[362] = {zone = "Stonetalon Mountains", place = "Krom'gar Fortress", faction = "Horde", wx = -21.25, wy = 932.11999511719, instance = 1, id = 362}
	FM.flightmasterDB[363] = {zone = "Stonetalon Mountains", place = "Malaka'jin", faction = "Horde", wx = -260.41000366211, wy = -111.94000244141, instance = 1, id = 363}
	FM.flightmasterDB[364] = {zone = "Stonetalon Mountains", place = "Northwatch Expedition Base Camp", faction = "Alliance", wx = -281.35000610352, wy = 237.88000488281, instance = 1, id = 364}
	FM.flightmasterDB[365] = {zone = "Stonetalon Mountains", place = "Farwatcher's Glen", faction = "Alliance", wx = 2013.1300048828, wy = 973.94000244141, instance = 1, id = 365}
	FM.flightmasterDB[366] = {zone = "Desolace", place = "Furien's Post", faction = "Horde", wx = 2242.6201171875, wy = -439.14999389648, instance = 1, id = 366}
	FM.flightmasterDB[367] = {zone = "Desolace", place = "Thargad's Camp", faction = "Alliance", wx = 2577.5700683594, wy = -1694.5300292969, instance = 1, id = 367}
	FM.flightmasterDB[368] = {zone = "Desolace", place = "Karnum's Glade", wx = 1637.9899902344, wy = -1038.4300537109, instance = 1, id = 368}
	FM.flightmasterDB[369] = {zone = "Desolace", place = "Thunk's Abode", wx = 1056.6800537109, wy = -534.03997802734, instance = 1, id = 369}
	FM.flightmasterDB[370] = {zone = "Desolace", place = "Ethel Rethor", wx = 2478.8999023438, wy = -356.4700012207, instance = 1, id = 370}
	FM.flightmasterDB[383] = {zone = "Eastern Plaguelands", place = "Thondroril River", wx = -2694.4799804688, wy = 1935.9699707031, instance = 0, id = 383}
	FM.flightmasterDB[384] = {zone = "Tirisfal", place = "The Bulwark", faction = "Horde", wx = -740.98101806641, wy = 1726.6199951172, instance = 0, id = 384}
	FM.flightmasterDB[386] = {zone = "Un'Goro Crater", place = "Mossy Pile", wx = -1095.2399902344, wy = -6958.4399414062, instance = 1, id = 386}
	FM.flightmasterDB[387] = {zone = "Southern Barrens", place = "Honor's Stand", faction = "Alliance", wx = -1532.4399414062, wy = -335.20001220703, instance = 1, id = 387}
	FM.flightmasterDB[388] = {zone = "Southern Barrens", place = "Northwatch Hold", faction = "Alliance", wx = -3561.7900390625, wy = -2124.2099609375, instance = 1, id = 388}
	FM.flightmasterDB[389] = {zone = "Southern Barrens", place = "Fort Triumph", faction = "Alliance", wx = -2286.2700195312, wy = -3150.25, instance = 1, id = 389}
	FM.flightmasterDB[390] = {zone = "Southern Barrens", place = "Hunter's Hill", faction = "Horde", wx = -1590.8699951172, wy = -798.71997070313, instance = 1, id = 390}
	FM.flightmasterDB[391] = {zone = "Southern Barrens", place = "Desolation Hold", faction = "Horde", wx = -1697.9899902344, wy = -3288.8500976562, instance = 1, id = 391}
	FM.flightmasterDB[402] = {zone = "Mulgore", place = "Bloodhoof Village", faction = "Horde", wx = -379.06900024414, wy = -2299.5400390625, instance = 1, id = 402}
	FM.flightmasterDB[456] = {zone = "Teldrassil", place = "Dolanaar", faction = "Alliance", wx = 977.69799804688, wy = 9873.099609375, instance = 1, id = 456}
	FM.flightmasterDB[457] = {zone = "Teldrassil", place = "Darnassus", faction = "Alliance", wx = 2622.0900878906, wy = 9968.7998046875, instance = 1, id = 457}
	FM.flightmasterDB[458] = {zone = "Northern Barrens", place = "Nozzlepot's Outpost", faction = "Horde", wx = -3381.7399902344, wy = 1152.5999755859, instance = 1, id = 458}
	FM.flightmasterDB[460] = {zone = "Tirisfal Glades", place = "Brill", faction = "Horde", wx = 372.06399536133, wy = 2272.6799316406, instance = 0, id = 460}
	FM.flightmasterDB[513] = {zone = "Thousand Needles", place = "Fizzle & Pozzik's Speedbarge", wx = -3913.4399414062, wy = -6075.3701171875, instance = 1, id = 513}
	FM.flightmasterDB[521] = {zone = "Vashj'ir", place = "Smuggler's Scar", wx = 3481.1201171875, wy = -4588.0498046875, instance = 0, id = 521}
	FM.flightmasterDB[522] = {zone = "Vashj'ir", place = "Silver Tide Hollow", wx = 4285.080078125, wy = -6105.6098632812, instance = 0, id = 522}
	FM.flightmasterDB[523] = {zone = "Vashj'ir", place = "Tranquil Wash", faction = "Alliance", wx = 4308.2797851562, wy = -6616.3999023438, instance = 0, id = 523}
	FM.flightmasterDB[524] = {zone = "Vashj'ir", place = "Darkbreak Cove", faction = "Alliance", wx = 5943.8198242188, wy = -6902.25, instance = 0, id = 524}
	FM.flightmasterDB[525] = {zone = "Vashj'ir", place = "Legion's Rest", faction = "Horde", wx = 4199.8500976562, wy = -6805.6298828125, instance = 0, id = 525}
	FM.flightmasterDB[526] = {zone = "Vashj'ir", place = "Tenebrous Cavern", faction = "Horde", wx = 6075.25, wy = -6507.990234375, instance = 0, id = 526}
	FM.flightmasterDB[531] = {zone = "Tanaris", place = "Dawnrise Expedition", faction = "Horde", wx = -2467.1298828125, wy = -9487.8896484375, instance = 1, id = 531}
	FM.flightmasterDB[532] = {zone = "Tanaris", place = "Gunstan's Dig", faction = "Alliance", wx = -2953.9899902344, wy = -9493.7099609375, instance = 1, id = 532}
	FM.flightmasterDB[536] = {zone = "Durotar", place = "Sen'jin Village", faction = "Horde", wx = -4890.2797851562, wy = -780.26702880859, instance = 1, id = 536}
	FM.flightmasterDB[537] = {zone = "Durotar", place = "Razor Hill", faction = "Horde", wx = -4766.759765625, wy = 269.9169921875, instance = 1, id = 537}
	FM.flightmasterDB[539] = {zone = "Tanaris", place = "Bootlegger Outpost", wx = -4088.1000976562, wy = -8683.08984375, instance = 1, id = 539}
	FM.flightmasterDB[540] = {zone = "Stonetalon Mountains", place = "The Sludgewerks", faction = "Horde", wx = 727.2080078125, wy = 1825.9399414062, instance = 1, id = 540}
	FM.flightmasterDB[541] = {zone = "Stonetalon Mountains", place = "Mirkfallon Post", faction = "Alliance", wx = 1034.8599853516, wy = 1379.4200439453, instance = 1, id = 541}
	FM.flightmasterDB[551] = {zone = "Wetlands", place = "Whelgar's Retreat", faction = "Alliance", wx = -1989.4899902344, wy = -3222.9299316406, instance = 0, id = 551}
	FM.flightmasterDB[552] = {zone = "Wetlands", place = "Greenwarden's Grove", faction = "Alliance", wx = -2718.6899414062, wy = -3306.6499023438, instance = 0, id = 552}
	FM.flightmasterDB[553] = {zone = "Wetlands", place = "Dun Modr", faction = "Alliance", wx = -2464.2800292969, wy = -2656.5400390625, instance = 0, id = 553}
	FM.flightmasterDB[554] = {zone = "Wetlands", place = "Slabchisel's Survey", faction = "Alliance", wx = -2741.2099609375, wy = -4113.6000976562, instance = 0, id = 554}
	FM.flightmasterDB[555] = {zone = "Loch Modan", place = "Farstrider Lodge", faction = "Alliance", wx = -4253.4399414062, wy = -5668.3100585938, instance = 0, id = 555}
	FM.flightmasterDB[557] = {zone = "Hyjal", place = "Shrine of Aviana", wx = -2676.1899414062, wy = 4987.8701171875, instance = 1, id = 557}
	FM.flightmasterDB[558] = {zone = "Hyjal", place = "Grove of Aessina", wx = -1760.5799560547, wy = 5163.509765625, instance = 1, id = 558}
	FM.flightmasterDB[559] = {zone = "Hyjal", place = "Nordrassil", wx = -3569.8400878906, wy = 5584.0600585938, instance = 1, id = 559}
	FM.flightmasterDB[565] = {zone = "Feralas", place = "Dreamer's Rest", faction = "Alliance", wx = 1951.6700439453, wy = -3136.6201171875, instance = 1, id = 565}
	FM.flightmasterDB[567] = {zone = "Feralas", place = "Tower of Estulan", faction = "Alliance", wx = 1478.1600341797, wy = -4863.6401367188, instance = 1, id = 567}
	FM.flightmasterDB[568] = {zone = "Feralas", place = "Camp Ataya", faction = "Horde", wx = 2560.1000976562, wy = -3081.6999511719, instance = 1, id = 568}
	FM.flightmasterDB[569] = {zone = "Feralas", place = "Stonemaul Hold", faction = "Horde", wx = 1898.1899414062, wy = -4606.5200195312, instance = 1, id = 569}
	FM.flightmasterDB[582] = {zone = "Elwynn", place = "Goldshire", faction = "Alliance", wx = 85.14929962158, wy = -9433.990234375, instance = 0, id = 582}
	FM.flightmasterDB[583] = {zone = "Westfall", place = "Moonbrook", faction = "Alliance", wx = 1542.8800048828, wy = -10876.900390625, instance = 0, id = 583}
	FM.flightmasterDB[584] = {zone = "Westfall", place = "Furlbrow's Pumpkin Farm", faction = "Alliance", wx = 1273.9300537109, wy = -9838.509765625, instance = 0, id = 584}
	FM.flightmasterDB[589] = {zone = "Elwynn", place = "Eastvale Logging Camp", faction = "Alliance", wx = -1306.7399902344, wy = -9475.7099609375, instance = 0, id = 589}
	FM.flightmasterDB[590] = {zone = "Stranglethorn", place = "Fort Livingston", faction = "Alliance", wx = -413.70999145508, wy = -12828.799804688, instance = 0, id = 590}
	FM.flightmasterDB[591] = {zone = "Stranglethorn", place = "Explorers' League Digsite", faction = "Alliance", wx = -85.54859924316, wy = -13600.900390625, instance = 0, id = 591}
	FM.flightmasterDB[592] = {zone = "Stranglethorn", place = "Hardwrench Hideaway", faction = "Horde", wx = 722.02801513672, wy = -13288.299804688, instance = 0, id = 592}
	FM.flightmasterDB[593] = {zone = "Stranglethorn", place = "Bambala", faction = "Horde", wx = -814.09899902344, wy = -12092.200195312, instance = 0, id = 593}
	FM.flightmasterDB[594] = {zone = "Felwood", place = "Whisperwind Grove", wx = -844.99798583984, wy = 6078.509765625, instance = 1, id = 594}
	FM.flightmasterDB[595] = {zone = "Felwood", place = "Wildheart Point", wx = -883.80603027344, wy = 4734.16015625, instance = 1, id = 595}
	FM.flightmasterDB[596] = {zone = "Redridge", place = "Shalewind Canyon", faction = "Alliance", wx = -3479.3701171875, wy = -9641.669921875, instance = 0, id = 596}
	FM.flightmasterDB[597] = {zone = "Felwood", place = "Irontree Clearing", faction = "Horde", wx = -1620.4100341797, wy = 6892.6899414062, instance = 1, id = 597}
	FM.flightmasterDB[598] = {zone = "Swamp of Sorrows", place = "Marshtide Watch", faction = "Alliance", wx = -3836.5400390625, wy = -10176.599609375, instance = 0, id = 598}
	FM.flightmasterDB[599] = {zone = "Swamp of Sorrows", place = "Bogpaddle", wx = -3890.7199707031, wy = -9737.080078125, instance = 0, id = 599}
	FM.flightmasterDB[600] = {zone = "Swamp of Sorrows", place = "The Harborage", faction = "Alliance", wx = -2852.4799804688, wy = -10118.599609375, instance = 0, id = 600}
	FM.flightmasterDB[601] = {zone = "Arathi", place = "Galen's Fall", faction = "Horde", wx = -1585.7399902344, wy = -952.37701416016, instance = 0, id = 601}
	FM.flightmasterDB[602] = {zone = "Blasted Lands", place = "Surwich", faction = "Alliance", wx = -2919.0400390625, wy = -12761.900390625, instance = 0, id = 602}
	FM.flightmasterDB[603] = {zone = "Blasted Lands", place = "Sunveil Excursion", faction = "Horde", wx = -3058.2299804688, wy = -12357.599609375, instance = 0, id = 603}
	FM.flightmasterDB[604] = {zone = "Blasted Lands", place = "Dreadmaul Hold", faction = "Horde", wx = -2790.9799804688, wy = -10933.299804688, instance = 0, id = 604}
	FM.flightmasterDB[605] = {zone = "Vashj'ir", place = "Voldrin's Hold", faction = "Alliance", wx = 3925.8500976562, wy = -7209.7099609375, instance = 0, id = 605}
	FM.flightmasterDB[606] = {zone = "Vashj'ir", place = "Sandy Beach", faction = "Alliance", wx = 3914.419921875, wy = -5310.8500976562, instance = 0, id = 606}
	FM.flightmasterDB[607] = {zone = "Vashj'ir", place = "Sandy Beach", faction = "Alliance", wx = 3900.2700195312, wy = -5267.3500976562, instance = 0, id = 607}
	FM.flightmasterDB[608] = {zone = "Vashj'ir", place = "Sandy Beach", faction = "Horde", wx = 3720.0700683594, wy = -5671.0200195312, instance = 0, id = 608}
	FM.flightmasterDB[609] = {zone = "Vashj'ir", place = "Sandy Beach", faction = "Horde", wx = 3711.8100585938, wy = -5669.1899414062, instance = 0, id = 609}
	FM.flightmasterDB[610] = {zone = "Vashj'ir", place = "Stygian Bounty", faction = "Horde", wx = 4244.7099609375, wy = -6878.5200195312, instance = 0, id = 610}
	FM.flightmasterDB[611] = {zone = "Vashj'ir", place = "Voldrin's Hold", faction = "Alliance", wx = 3912.3601074219, wy = -7198.9702148438, instance = 0, id = 611}
	FM.flightmasterDB[612] = {zone = "Vashj'ir", place = "Stygian Bounty", faction = "Horde", wx = 4278.0600585938, wy = -6880.169921875, instance = 0, id = 612}
	FM.flightmasterDB[613] = {zone = "Azshara", place = "Southern Rocketway", faction = "Horde", wx = -6214.3999023438, wy = 2647.7900390625, instance = 1, id = 613}
	FM.flightmasterDB[614] = {zone = "Azshara", place = "Northern Rocketway", faction = "Horde", wx = -7041.7998046875, wy = 4611.3798828125, instance = 1, id = 614}
	FM.flightmasterDB[615] = {zone = "Redridge", place = "Camp Everstill", faction = "Alliance", wx = -2836.9899902344, wy = -9446.6396484375, instance = 0, id = 615}
	FM.flightmasterDB[616] = {zone = "Hyjal", place = "Gates of Sothann", wx = -3966.75, wy = 4059.3999023438, instance = 1, id = 616}
	FM.flightmasterDB[617] = {zone = "The Hinterlands", place = "Hiri'watha Research Station", faction = "Horde", wx = -2821.7800292969, wy = -25.77599906921, instance = 0, id = 617}
	FM.flightmasterDB[618] = {zone = "The Hinterlands", place = "Stormfeather Outpost", faction = "Alliance", wx = -4105.3598632812, wy = 312.32598876953, instance = 0, id = 618}
	FM.flightmasterDB[619] = {zone = "Dun Morogh", place = "Kharanos", faction = "Alliance", wx = -494.85101318359, wy = -5660.7998046875, instance = 0, id = 619}
	FM.flightmasterDB[620] = {zone = "Dun Morogh", place = "Gol'Bolar Quarry", faction = "Alliance", wx = -1578.6400146484, wy = -5714.1401367188, instance = 0, id = 620}
	FM.flightmasterDB[622] = {zone = "Duskwood", place = "Raven Hill", faction = "Alliance", wx = 267.04299926758, wy = -10737.599609375, instance = 0, id = 622}
	FM.flightmasterDB[624] = {zone = "Azuremyst Isle", place = "Azure Watch", faction = "Alliance", wx = -12520.5, wy = -4130.080078125, instance = 530, id = 624}
	FM.flightmasterDB[625] = {zone = "Eversong Woods", place = "Fairbreeze Village", faction = "Horde", wx = -6654.1201171875, wy = 8745.7802734375, instance = 530, id = 625}
	FM.flightmasterDB[630] = {zone = "Eastern Plaguelands", place = "Light's Shield Tower", wx = -4411.5200195312, wy = 2262.1000976562, instance = 0, id = 630}
	FM.flightmasterDB[631] = {zone = "Eversong Woods", place = "Falconwing Square", faction = "Horde", wx = -6767.08984375, wy = 9501.9296875, instance = 530, id = 631}
	FM.flightmasterDB[632] = {zone = "Badlands", place = "Bloodwatcher Point", faction = "Horde", wx = -3513.9899902344, wy = -6898.25, instance = 0, id = 632}
	FM.flightmasterDB[633] = {zone = "Badlands", place = "Dustwind Dig", faction = "Alliance", wx = -3401.1799316406, wy = -6594.08984375, instance = 0, id = 633}
	FM.flightmasterDB[634] = {zone = "Badlands", place = "Dragon's Mouth", faction = "Alliance", wx = -2570.7900390625, wy = -7034.5297851562, instance = 0, id = 634}
	FM.flightmasterDB[635] = {zone = "Badlands", place = "Fuselight", wx = -3875.1298828125, wy = -6574.9399414062, instance = 0, id = 635}
	FM.flightmasterDB[645] = {zone = "Silverpine Forest", place = "Forsaken High Command", faction = "Horde", wx = 1018.2299804688, wy = 1421.0200195312, instance = 0, id = 645}
	FM.flightmasterDB[646] = {zone = "Gilneas", place = "Forsaken Forward Command", faction = "Horde", wx = 1638.5999755859, wy = -910.22100830078, instance = 0, id = 646}
	FM.flightmasterDB[649] = {zone = "Western Plaguelands", place = "Andorhal", faction = "Horde", wx = -1586.9499511719, wy = 1511.8000488281, instance = 0, id = 649}
	FM.flightmasterDB[650] = {zone = "Western Plaguelands", place = "Andorhal", faction = "Alliance", wx = -1281.9399414062, wy = 1374.2299804688, instance = 0, id = 650}
	FM.flightmasterDB[651] = {zone = "Western Plaguelands", place = "The Menders' Stead", wx = -1755.8199462891, wy = 1864.3199462891, instance = 0, id = 651}
	FM.flightmasterDB[652] = {zone = "Uldum", place = "Ramkahen", wx = -1042.9699707031, wy = -9415.01953125, instance = 1, id = 652}
	FM.flightmasterDB[653] = {zone = "Uldum", place = "Oasis of Vir'sar", wx = 791.25897216797, wy = -8375.4697265625, instance = 1, id = 653}
	FM.flightmasterDB[654] = {zone = "Silverpine Forest", place = "The Forsaken Front", faction = "Horde", wx = 1312.3199462891, wy = -114.14199829102, instance = 0, id = 654}
	FM.flightmasterDB[656] = {zone = "Twilight Highlands", place = "Crushblow", faction = "Horde", wx = -4848.9301757812, wy = -4831.759765625, instance = 0, id = 656}
	FM.flightmasterDB[657] = {zone = "Twilight Highlands", place = "The Gullet", faction = "Horde", wx = -4379.4799804688, wy = -3494.6298828125, instance = 0, id = 657}
	FM.flightmasterDB[658] = {zone = "Twilight Highlands", place = "Vermillion Redoubt", wx = -3940.9699707031, wy = -3032.7600097656, instance = 0, id = 658}
	FM.flightmasterDB[659] = {zone = "Twilight Highlands", place = "Bloodgulch", faction = "Horde", wx = -5288.1899414062, wy = -3637.5600585938, instance = 0, id = 659}
	FM.flightmasterDB[660] = {zone = "Twilight Highlands", place = "The Krazzworks", faction = "Horde", wx = -6409.2797851562, wy = -2780.1799316406, instance = 0, id = 660}
	FM.flightmasterDB[661] = {zone = "Twilight Highlands", place = "Dragonmaw Port", faction = "Horde", wx = -6329.25, wy = -4012.4499511719, instance = 0, id = 661}
	FM.flightmasterDB[662] = {zone = "Twilight Highlands", place = "Highbank", faction = "Alliance", wx = -6740.6098632812, wy = -4863.1000976562, instance = 0, id = 662}
	FM.flightmasterDB[663] = {zone = "Twilight Highlands", place = "Victor's Point", faction = "Alliance", wx = -4748.9301757812, wy = -4170.5498046875, instance = 0, id = 663}
	FM.flightmasterDB[664] = {zone = "Twilight Highlands", place = "Firebeard's Patrol", faction = "Alliance", wx = -5620.1499023438, wy = -4183.8999023438, instance = 0, id = 664}
	FM.flightmasterDB[665] = {zone = "Twilight Highlands", place = "Thundermar", faction = "Alliance", wx = -4994.2797851562, wy = -3146.919921875, instance = 0, id = 665}
	FM.flightmasterDB[666] = {zone = "Twilight Highlands", place = "Kirthaven", faction = "Alliance", wx = -5427.5297851562, wy = -2689.4299316406, instance = 0, id = 666}
	FM.flightmasterDB[667] = {zone = "Hillsbrad", place = "Ruins of Southshore", faction = "Horde", wx = -536.49298095703, wy = -661.83697509766, instance = 0, id = 667}
	FM.flightmasterDB[668] = {zone = "Hillsbrad", place = "Southpoint Gate", faction = "Horde", wx = 435.46499633789, wy = -605.18402099609, instance = 0, id = 668}
	FM.flightmasterDB[669] = {zone = "Hillsbrad", place = "Eastpoint Tower", faction = "Horde", wx = -1051.1999511719, wy = -566.88897705078, instance = 0, id = 669}
	FM.flightmasterDB[670] = {zone = "Alterac Mountains", place = "Strahnbrad", faction = "Horde", wx = -979.57800292969, wy = 622.85101318359, instance = 0, id = 670}
	FM.flightmasterDB[672] = {zone = "Western Plaguelands", place = "Hearthglen", wx = -1500.5100097656, wy = 2839.7800292969, instance = 0, id = 672}
	FM.flightmasterDB[673] = {zone = "Searing Gorge", place = "Iron Summit", wx = -1236.6300048828, wy = -7123.0600585938, instance = 0, id = 673}
	FM.flightmasterDB[674] = {zone = "Uldum", place = "Schnottz's Landing", wx = 1059.6199951172, wy = -10711.900390625, instance = 1, id = 674}
	FM.flightmasterDB[675] = {zone = "Burning Steppes", place = "Flamestar Post", wx = -1025.7900390625, wy = -8092.259765625, instance = 0, id = 675}
	FM.flightmasterDB[676] = {zone = "Burning Steppes", place = "Chiselgrip", wx = -1919.5300292969, wy = -7865.9301757812, instance = 0, id = 676}
	FM.flightmasterDB[681] = {zone = "Silverpine Forest", place = "Forsaken Rear Guard", faction = "Horde", wx = 1518.9000244141, wy = 1056.0600585938, instance = 0, id = 681}
	FM.flightmasterDB[683] = {zone = "Azshara", place = "Valormok", faction = "Horde", wx = -4161.3598632812, wy = 2988.1298828125, instance = 1, id = 683}
	FM.flightmasterDB[781] = {zone = "Hyjal", place = "Sanctuary of Malorne", wx = -2107.5300292969, wy = 4397.7900390625, instance = 1, id = 781}
end

function FM.getNearestFlightPoint(x, y, instance, faction)
	local minDist, minPos, minId
	for id, master in pairs(FM.flightmasterDB) do
		local pos = FM.getFlightPoint(id)
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
	local master = FM.flightmasterDB[id]
	if master == nil then return end
	if master.npcId ~= nil then return PT.getNPCPosition(master.npcId) end
	local x, y, zone = PT.GetZoneCoordinatesFromWorld(master.wx, master.wy, master.instance)
	return {wx = master.wx, wy = master.wy, instance = master.instance, x = x, y = y, zone = zone, mapID = DM.mapIDs[zone]}
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
			if flightmasters[master.id] ~= nil then return flightmasters[master.id]:gsub(" ",""):gsub(" ",""):gsub("'",""):lower() end
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
	if FM.flightmasterDB_Locales[GetLocale()][master.id] == name then return true end
	return false
end
	