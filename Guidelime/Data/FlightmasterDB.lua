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
	FM.flightmasterDB[2] = {zone = "Elwynn", place = "Stormwind", faction = "Alliance", id = 2, wx = 489.65600585938, wy = -8841.0595703125, instance = 0}
	FM.flightmasterDB[4] = {zone = "Westfall", place = "Sentinel Hill", faction = "Alliance", id = 4, wx = 1034.3900146484, wy = -10551.900390625, instance = 0}
	FM.flightmasterDB[5] = {zone = "Redridge", place = "Lakeshire", faction = "Alliance", id = 5, wx = -2231.3999023438, wy = -9429.099609375, instance = 0}
	FM.flightmasterDB[6] = {zone = "Dun Morogh", place = "Ironforge", faction = "Alliance", id = 6, wx = -1155.4399414062, wy = -4821.7797851562, instance = 0}
	FM.flightmasterDB[7] = {zone = "Wetlands", place = "Menethil Harbor", faction = "Alliance", id = 7, wx = -777.69598388672, wy = -3787.8100585938, instance = 0}
	FM.flightmasterDB[8] = {zone = "Loch Modan", place = "Thelsamar", faction = "Alliance", id = 8, wx = -2930.0100097656, wy = -5421.91015625, instance = 0}
	FM.flightmasterDB[10] = {zone = "Silverpine Forest", place = "The Sepulcher", faction = "Horde", id = 10, wx = 1536.5899658203, wy = 478.85998535156, instance = 0}
	FM.flightmasterDB[11] = {zone = "Tirisfal", place = "Undercity", faction = "Horde", id = 11, wx = 267.9700012207, wy = 1568.6199951172, instance = 0}
	FM.flightmasterDB[12] = {zone = "Duskwood", place = "Darkshire", faction = "Alliance", id = 12, wx = -1261.6500244141, wy = -10515.5, instance = 0}
	FM.flightmasterDB[13] = {zone = "Hillsbrad", place = "Tarren Mill", faction = "Horde", id = 13, wx = -874.20300292969, wy = -17.70660018921, instance = 0}
	FM.flightmasterDB[14] = {zone = "Hillsbrad", place = "Southshore", id = 14, wx = -515.47998046875, wy = -711.47998046875, instance = 0}
	FM.flightmasterDB[16] = {zone = "Arathi", place = "Refuge Pointe", faction = "Alliance", id = 16, wx = -2515.1101074219, wy = -1240.5300292969, instance = 0}
	FM.flightmasterDB[17] = {zone = "Arathi", place = "Hammerfall", faction = "Horde", id = 17, wx = -3496.8898925781, wy = -916.28997802734, instance = 0}
	FM.flightmasterDB[18] = {zone = "Stranglethorn", place = "Booty Bay", faction = "Horde", id = 18, wx = 509.61999511719, wy = -14444.290039062, instance = 0}
	FM.flightmasterDB[19] = {zone = "Stranglethorn", place = "Booty Bay", faction = "Alliance", id = 19, wx = 464.14999389648, wy = -14473.0, instance = 0}
	FM.flightmasterDB[20] = {zone = "Stranglethorn", place = "Grom'gol", faction = "Horde", id = 20, wx = 146.28999328613, wy = -12414.200195312, instance = 0}
	FM.flightmasterDB[21] = {zone = "Badlands", place = "New Kargath", faction = "Horde", id = 21, wx = -2433.3701171875, wy = -6676.8701171875, instance = 0}
	FM.flightmasterDB[22] = {zone = "Mulgore", place = "Thunder Bluff", faction = "Horde", id = 22, wx = 29.70999908447, wy = -1197.2099609375, instance = 1}
	FM.flightmasterDB[23] = {zone = "Durotar", place = "Orgrimmar", faction = "Horde", id = 23, wx = -4363.2700195312, wy = 1798.2700195312, instance = 1}
	FM.flightmasterDB[25] = {zone = "Northern Barrens", place = "The Crossroads", faction = "Horde", id = 25, wx = -2596.080078125, wy = -441.79998779297, instance = 1}
	FM.flightmasterDB[26] = {zone = "Darkshore", place = "Lor'danel", faction = "Alliance", id = 26, wx = -326.55999755859, wy = 7459.8999023438, instance = 1}
	FM.flightmasterDB[27] = {zone = "Teldrassil", place = "Rut'theran Village", faction = "Alliance", id = 27, wx = 980.96398925781, wy = 8383.75, instance = 1}
	FM.flightmasterDB[28] = {zone = "Ashenvale", place = "Astranaar", faction = "Alliance", id = 28, wx = -289.23999023438, wy = 2827.3400878906, instance = 1}
	FM.flightmasterDB[29] = {zone = "Stonetalon Mountains", place = "Sun Rock Retreat", faction = "Horde", id = 29, wx = 1040.3199462891, wy = 966.57000732422, instance = 1}
	FM.flightmasterDB[30] = {zone = "Thousand Needles", place = "Westreach Summit", faction = "Horde", id = 30, wx = -927.06402587891, wy = -4310.6098632812, instance = 1}
	FM.flightmasterDB[31] = {zone = "Feralas", place = "Shadebough", faction = "Alliance", id = 31, wx = 73.94270324707, wy = -4996.8798828125, instance = 1}
	FM.flightmasterDB[32] = {zone = "Dustwallow Marsh", place = "Theramore", id = 32, wx = -4516.580078125, wy = -3825.3701171875, instance = 1}
	FM.flightmasterDB[33] = {zone = "Stonetalon Mountains", place = "Thal'darah Overlook", faction = "Alliance", id = 33, wx = 1537.8699951172, wy = 2147.25, instance = 1}
	FM.flightmasterDB[37] = {zone = "Desolace", place = "Nijel's Point", faction = "Alliance", id = 37, wx = 1325.8199462891, wy = 139.24000549316, instance = 1}
	FM.flightmasterDB[38] = {zone = "Desolace", place = "Shadowprey Village", faction = "Horde", id = 38, wx = 3263.8898925781, wy = -1767.6400146484, instance = 1}
	FM.flightmasterDB[39] = {zone = "Tanaris", place = "Gadgetzan", faction = "Alliance", id = 39, wx = -3768.2399902344, wy = -7185.9702148438, instance = 1}
	FM.flightmasterDB[40] = {zone = "Tanaris", place = "Gadgetzan", faction = "Horde", id = 40, wx = -3813.6899414062, wy = -7094.0297851562, instance = 1}
	FM.flightmasterDB[41] = {zone = "Feralas", place = "Feathermoon", faction = "Alliance", id = 41, wx = 2188.6398925781, wy = -4467.0400390625, instance = 1}
	FM.flightmasterDB[42] = {zone = "Feralas", place = "Camp Mojache", faction = "Horde", id = 42, wx = 199.30999755859, wy = -4419.8598632812, instance = 1}
	FM.flightmasterDB[43] = {zone = "The Hinterlands", place = "Aerie Peak", faction = "Alliance", id = 43, wx = -2002.7600097656, wy = 283.73999023438, instance = 0}
	FM.flightmasterDB[44] = {zone = "Azshara", place = "Bilgewater Harbor", faction = "Horde", id = 44, wx = -6294.66015625, wy = 3547.1999511719, instance = 1}
	FM.flightmasterDB[45] = {zone = "Blasted Lands", place = "Nethergarde Keep", faction = "Alliance", id = 45, wx = -3435.7399902344, wy = -11112.299804688, instance = 0}
	FM.flightmasterDB[49] = {zone = "Moonglade", faction = "Alliance", id = 49, wx = -2487.2099609375, wy = 7458.4501953125, instance = 1}
	FM.flightmasterDB[52] = {zone = "Winterspring", place = "Everlook", faction = "Alliance", id = 52, wx = -4742.3901367188, wy = 6796.7998046875, instance = 1}
	FM.flightmasterDB[53] = {zone = "Winterspring", place = "Everlook", faction = "Horde", id = 53, wx = -4611.1201171875, wy = 6813.0600585938, instance = 1}
	FM.flightmasterDB[55] = {zone = "Dustwallow Marsh", place = "Brackenwall Village", faction = "Horde", id = 55, wx = -2842.1799316406, wy = -3147.3898925781, instance = 1}
	FM.flightmasterDB[56] = {zone = "Swamp of Sorrows", place = "Stonard", faction = "Horde", id = 56, wx = -3279.25, wy = -10457.0, instance = 0}
	FM.flightmasterDB[58] = {zone = "Ashenvale", place = "Zoram'gar Outpost", faction = "Horde", id = 58, wx = 1052.3000488281, wy = 3351.8200683594, instance = 1}
	FM.flightmasterDB[61] = {zone = "Ashenvale", place = "Splintertree Post", faction = "Horde", id = 61, wx = -2524.5500488281, wy = 2302.3898925781, instance = 1}
	FM.flightmasterDB[65] = {zone = "Felwood", place = "Talonbranch Glade", faction = "Alliance", id = 65, wx = -1874.2800292969, wy = 6214.3198242188, instance = 1}
	FM.flightmasterDB[66] = {zone = "Western Plaguelands", place = "Chillwind Camp", faction = "Alliance", id = 66, wx = -1430.1099853516, wy = 931.32000732422, instance = 0}
	FM.flightmasterDB[67] = {zone = "Eastern Plaguelands", place = "Light's Hope Chapel", faction = "Alliance", id = 67, wx = -5340.7998046875, wy = 2271.0900878906, instance = 0}
	FM.flightmasterDB[68] = {zone = "Eastern Plaguelands", place = "Light's Hope Chapel", faction = "Horde", id = 68, wx = -5343.1098632812, wy = 2270.1999511719, instance = 0}
	FM.flightmasterDB[69] = {zone = "Moonglade", faction = "Horde", id = 69, wx = -2123.3798828125, wy = 7470.3901367188, instance = 1}
	FM.flightmasterDB[70] = {zone = "Burning Steppes", place = "Flame Crest", faction = "Horde", id = 70, wx = -2187.5400390625, wy = -7504.0297851562, instance = 0}
	FM.flightmasterDB[71] = {zone = "Burning Steppes", place = "Morgan's Vigil", faction = "Alliance", id = 71, wx = -2738.3500976562, wy = -8364.6103515625, instance = 0}
	FM.flightmasterDB[72] = {zone = "Silithus", place = "Cenarion Hold", faction = "Horde", id = 72, wx = 836.73999023438, wy = -6811.3901367188, instance = 1}
	FM.flightmasterDB[73] = {zone = "Silithus", place = "Cenarion Hold", faction = "Alliance", id = 73, wx = 772.03002929688, wy = -6761.830078125, instance = 1}
	FM.flightmasterDB[74] = {zone = "Searing Gorge", place = "Thorium Point", faction = "Alliance", id = 74, wx = -1168.2700195312, wy = -6552.58984375, instance = 0}
	FM.flightmasterDB[75] = {zone = "Searing Gorge", place = "Thorium Point", faction = "Horde", id = 75, wx = -1100.0500488281, wy = -6554.9301757812, instance = 0}
	FM.flightmasterDB[76] = {zone = "The Hinterlands", place = "Revantusk Village", faction = "Horde", id = 76, wx = -4720.5, wy = -635.26000976563, instance = 0}
	FM.flightmasterDB[77] = {zone = "Southern Barrens", place = "Vendetta Point", faction = "Horde", id = 77, wx = -1724.3399658203, wy = -2152.3500976562, instance = 1}
	FM.flightmasterDB[79] = {zone = "Un'Goro Crater", place = "Marshal's Stand", id = 79, wx = -1541.1300048828, wy = -7548.0498046875, instance = 1}
	FM.flightmasterDB[80] = {zone = "Northern Barrens", place = "Ratchet", id = 80, wx = -3773.0100097656, wy = -894.59002685547, instance = 1}
	FM.flightmasterDB[82] = {zone = "Silvermoon City", faction = "Horde", id = 82, wx = -7165.8901367188, wy = 9375.240234375, instance = 530}
	FM.flightmasterDB[83] = {zone = "Ghostlands", place = "Tranquillien", faction = "Horde", id = 83, wx = -6784.2900390625, wy = 7594.4702148438, instance = 530}
	FM.flightmasterDB[84] = {zone = "Eastern Plaguelands", place = "Plaguewood Tower", id = 84, wx = -3033.6101074219, wy = 2965.5500488281, instance = 0}
	FM.flightmasterDB[85] = {zone = "Eastern Plaguelands", place = "Northpass Tower", id = 85, wx = -4354.7797851562, wy = 3134.2600097656, instance = 0}
	FM.flightmasterDB[86] = {zone = "Eastern Plaguelands", place = "Eastwall Tower", id = 86, wx = -4769.5600585938, wy = 2524.4399414062, instance = 0}
	FM.flightmasterDB[87] = {zone = "Eastern Plaguelands", place = "Crown Guard Tower", id = 87, wx = -3693.3200683594, wy = 1876.4000244141, instance = 0}
	FM.flightmasterDB[93] = {zone = "Bloodmyst Isle", place = "Blood Watch", faction = "Alliance", id = 93, wx = -11954.599609375, wy = -1933.2700195312, instance = 530}
	FM.flightmasterDB[94] = {zone = "The Exodar", faction = "Alliance", id = 94, wx = -11641.099609375, wy = -3867.5600585938, instance = 530}
	FM.flightmasterDB[99] = {zone = "Hellfire Peninsula", place = "Thrallmar", faction = "Horde", id = 99, wx = 2633.5700683594, wy = 228.5, instance = 530}
	FM.flightmasterDB[100] = {zone = "Hellfire Peninsula", place = "Honor Hold", faction = "Alliance", id = 100, wx = 2717.2700195312, wy = -673.41998291016, instance = 530}
	FM.flightmasterDB[101] = {zone = "Hellfire Peninsula", place = "Temple of Telhamat", faction = "Alliance", id = 101, wx = 4241.5600585938, wy = 199.16000366211, instance = 530}
	FM.flightmasterDB[102] = {zone = "Hellfire Peninsula", place = "Falcon Watch", faction = "Horde", id = 102, wx = 4101.009765625, wy = -587.40997314453, instance = 530}
	FM.flightmasterDB[117] = {zone = "Zangarmarsh", place = "Telredor", faction = "Alliance", id = 117, wx = 6063.75, wy = 213.75, instance = 530}
	FM.flightmasterDB[118] = {zone = "Zangarmarsh", place = "Zabra'jin", faction = "Horde", id = 118, wx = 7816.0, wy = 219.44999694824, instance = 530}
	FM.flightmasterDB[119] = {zone = "Nagrand", place = "Telaar", faction = "Alliance", id = 119, wx = 7305.2998046875, wy = -2729.0, instance = 530}
	FM.flightmasterDB[120] = {zone = "Nagrand", place = "Garadar", faction = "Horde", id = 120, wx = 7133.3901367188, wy = -1261.0899658203, instance = 530}
	FM.flightmasterDB[121] = {zone = "Terokkar Forest", place = "Allerian Stronghold", faction = "Alliance", id = 121, wx = 3872.7800292969, wy = -2987.2399902344, instance = 530}
	FM.flightmasterDB[122] = {zone = "Netherstorm", place = "Area 52", id = 122, wx = 3596.1101074219, wy = 3082.3100585938, instance = 530}
	FM.flightmasterDB[123] = {zone = "Shadowmoon Valley", place = "Shadowmoon Village", faction = "Horde", id = 123, wx = 2557.0900878906, wy = -3018.6201171875, instance = 530}
	FM.flightmasterDB[124] = {zone = "Shadowmoon Valley", place = "Wildhammer Stronghold", faction = "Alliance", id = 124, wx = 2156.4699707031, wy = -3982.0700683594, instance = 530}
	FM.flightmasterDB[125] = {zone = "Blade's Edge Mountains", place = "Sylvanaar", faction = "Alliance", id = 125, wx = 6794.4599609375, wy = 2183.6499023438, instance = 530}
	FM.flightmasterDB[126] = {zone = "Blade's Edge Mountains", place = "Thunderlord Stronghold", faction = "Horde", id = 126, wx = 6020.9301757812, wy = 2446.3701171875, instance = 530}
	FM.flightmasterDB[127] = {zone = "Terokkar Forest", place = "Stonebreaker Hold", faction = "Horde", id = 127, wx = 4423.830078125, wy = -2567.330078125, instance = 530}
	FM.flightmasterDB[128] = {zone = "Terokkar Forest", place = "Shattrath", id = 128, wx = 5301.8999023438, wy = -1837.2299804688, instance = 530}
	FM.flightmasterDB[129] = {zone = "The Dark Portal", place = "Hellfire Peninsula", faction = "Alliance", id = 129, wx = 1020.4899902344, wy = -327.35000610352, instance = 530}
	FM.flightmasterDB[130] = {zone = "The Dark Portal", place = "Hellfire Peninsula", faction = "Horde", id = 130, wx = 1026.7199707031, wy = -178.08999633789, instance = 530}
	FM.flightmasterDB[139] = {zone = "Netherstorm", place = "The Stormspire", id = 139, wx = 2959.6899414062, wy = 4157.580078125, instance = 530}
	FM.flightmasterDB[140] = {zone = "Shadowmoon Valley", place = "Altar of Sha'tar", id = 140, wx = 749.41998291016, wy = -3065.6000976562, instance = 530}
	FM.flightmasterDB[141] = {zone = "Hellfire Peninsula", place = "Spinebreaker Ridge", faction = "Horde", id = 141, wx = 2358.6201171875, wy = -1316.8399658203, instance = 530}
	FM.flightmasterDB[149] = {zone = "Hellfire Peninsula", place = "Shatter Point", id = 149, wx = 1486.9100341797, wy = 276.20001220703, instance = 530}
	FM.flightmasterDB[150] = {zone = "Netherstorm", place = "Cosmowrench", id = 150, wx = 1848.2399902344, wy = 2974.9499511719, instance = 530}
	FM.flightmasterDB[151] = {zone = "Zangarmarsh", place = "Swamprat Post", faction = "Horde", id = 151, wx = 5214.919921875, wy = 91.66999816895, instance = 530}
	FM.flightmasterDB[156] = {zone = "Blade's Edge Mountains", place = "Toshley's Station", faction = "Alliance", id = 156, wx = 5531.8701171875, wy = 1857.3499755859, instance = 530}
	FM.flightmasterDB[159] = {zone = "Shadowmoon Valley", place = "Sanctum of the Stars", id = 159, wx = 1123.6099853516, wy = -4073.169921875, instance = 530}
	FM.flightmasterDB[160] = {zone = "Blade's Edge Mountains", place = "Evergrove", id = 160, wx = 5501.1298828125, wy = 2976.0100097656, instance = 530}
	FM.flightmasterDB[163] = {zone = "Blade's Edge Mountains", place = "Mok'Nathal Village", faction = "Horde", id = 163, wx = 4705.2700195312, wy = 2028.7900390625, instance = 530}
	FM.flightmasterDB[164] = {zone = "Zangarmarsh", place = "Orebor Harborage", faction = "Alliance", id = 164, wx = 7399.16015625, wy = 966.66998291016, instance = 530}
	FM.flightmasterDB[166] = {zone = "Felwood", place = "Emerald Sanctuary", id = 166, wx = -1324.5100097656, wy = 3972.8400878906, instance = 1}
	FM.flightmasterDB[167] = {zone = "Ashenvale", place = "Forest Song", faction = "Alliance", id = 167, wx = -3202.4099121094, wy = 3000.25, instance = 1}
	FM.flightmasterDB[179] = {zone = "Dustwallow Marsh", place = "Mudsprocket", id = 179, wx = -3226.0500488281, wy = -4566.2299804688, instance = 1}
	FM.flightmasterDB[183] = {zone = "Howling Fjord", place = "Valgarde Port", faction = "Alliance", id = 183, wx = -5010.9702148438, wy = 567.40997314453, instance = 571}
	FM.flightmasterDB[184] = {zone = "Howling Fjord", place = "Fort Wildervar", faction = "Alliance", id = 184, wx = -5029.8198242188, wy = 2468.7700195312, instance = 571}
	FM.flightmasterDB[185] = {zone = "Howling Fjord", place = "Westguard Keep", faction = "Alliance", id = 185, wx = -3287.8999023438, wy = 1342.8399658203, instance = 571}
	FM.flightmasterDB[190] = {zone = "Howling Fjord", place = "New Agamand", faction = "Horde", id = 190, wx = -4544.2998046875, wy = 401.11999511719, instance = 571}
	FM.flightmasterDB[191] = {zone = "Howling Fjord", place = "Vengeance Landing", faction = "Horde", id = 191, wx = -6175.8901367188, wy = 1918.5999755859, instance = 571}
	FM.flightmasterDB[192] = {zone = "Howling Fjord", place = "Camp Winterhoof", faction = "Horde", id = 192, wx = -4392.7099609375, wy = 2652.8898925781, instance = 571}
	FM.flightmasterDB[195] = {zone = "Stranglethorn Vale", place = "Rebel Camp", faction = "Alliance", id = 195, wx = -216.83000183106, wy = -11344.0, instance = 0}
	FM.flightmasterDB[205] = {zone = "Ghostlands", place = "Zul'Aman", id = 205, wx = -7747.580078125, wy = 6789.7900390625, instance = 530}
	FM.flightmasterDB[226] = {zone = "Coldarra", place = "Transitus Shield", id = 226, wx = 6661.6401367188, wy = 3575.4399414062, instance = 571}
	FM.flightmasterDB[244] = {zone = "Dragonblight", place = "Wintergarde Keep", faction = "Alliance", id = 244, wx = -694.85998535156, wy = 3712.4299316406, instance = 571}
	FM.flightmasterDB[245] = {zone = "Borean Tundra", place = "Valiance Keep", faction = "Alliance", id = 245, wx = 5173.6899414062, wy = 2269.5400390625, instance = 571}
	FM.flightmasterDB[246] = {zone = "Borean Tundra", place = "Fizzcrank Airstrip", faction = "Alliance", id = 246, wx = 5313.0698242188, wy = 4127.2299804688, instance = 571}
	FM.flightmasterDB[247] = {zone = "Dragonblight", place = "Stars' Rest", faction = "Alliance", id = 247, wx = 1992.0300292969, wy = 3504.1298828125, instance = 571}
	FM.flightmasterDB[248] = {zone = "Howling Fjord", place = "Apothecary Camp", faction = "Horde", id = 248, wx = -2970.6201171875, wy = 2108.1101074219, instance = 571}
	FM.flightmasterDB[249] = {zone = "Grizzly Hills", place = "Camp Oneqwah", faction = "Horde", id = 249, wx = -4520.080078125, wy = 3876.3400878906, instance = 571}
	FM.flightmasterDB[250] = {zone = "Grizzly Hills", place = "Conquest Hold", faction = "Horde", id = 250, wx = -2263.0900878906, wy = 3258.8999023438, instance = 571}
	FM.flightmasterDB[251] = {zone = "Dragonblight", place = "Fordragon Hold", faction = "Alliance", id = 251, wx = 1406.5999755859, wy = 4612.2099609375, instance = 571}
	FM.flightmasterDB[252] = {zone = "Dragonblight", place = "Wyrmrest Temple", id = 252, wx = 247.58000183106, wy = 3653.2099609375, instance = 571}
	FM.flightmasterDB[253] = {zone = "Grizzly Hills", place = "Amberpine Lodge", faction = "Alliance", id = 253, wx = -2754.1000976562, wy = 3446.3500976562, instance = 571}
	FM.flightmasterDB[254] = {zone = "Dragonblight", place = "Venomspite", faction = "Horde", id = 254, wx = -666.15997314453, wy = 3242.9599609375, instance = 571}
	FM.flightmasterDB[255] = {zone = "Grizzly Hills", place = "Westfall Brigade", faction = "Alliance", id = 255, wx = -4254.6899414062, wy = 4584.9799804688, instance = 571}
	FM.flightmasterDB[256] = {zone = "Dragonblight", place = "Agmar's Hammer", faction = "Horde", id = 256, wx = 1525.6300048828, wy = 3865.8701171875, instance = 571}
	FM.flightmasterDB[257] = {zone = "Borean Tundra", place = "Warsong Hold", faction = "Horde", id = 257, wx = 6242.8500976562, wy = 2920.2900390625, instance = 571}
	FM.flightmasterDB[258] = {zone = "Borean Tundra", place = "Taunka'le Village", faction = "Horde", id = 258, wx = 4089.5200195312, wy = 3449.5100097656, instance = 571}
	FM.flightmasterDB[259] = {zone = "Borean Tundra", place = "Bor'gorok Outpost", faction = "Horde", id = 259, wx = 5712.1298828125, wy = 4474.7900390625, instance = 571}
	FM.flightmasterDB[260] = {zone = "Dragonblight", place = "Kor'kron Vanguard", faction = "Horde", id = 260, wx = 1165.9399414062, wy = 4946.669921875, instance = 571}
	FM.flightmasterDB[289] = {zone = "Borean Tundra", place = "Amber Ledge", id = 289, wx = 5973.2998046875, wy = 3587.8400878906, instance = 571}
	FM.flightmasterDB[294] = {zone = "Dragonblight", place = "Moa'ki", id = 294, wx = 908.96002197266, wy = 2792.4499511719, instance = 571}
	FM.flightmasterDB[295] = {zone = "Howling Fjord", place = "Kamagua", id = 295, wx = -2887.7099609375, wy = 785.27001953125, instance = 571}
	FM.flightmasterDB[296] = {zone = "Borean Tundra", place = "Unu'pe", id = 296, wx = 4046.0900878906, wy = 2919.1899414062, instance = 571}
	FM.flightmasterDB[303] = {zone = "Wintergrasp", place = "Valiance Landing Camp", faction = "Alliance", id = 303, wx = 2185.6499023438, wy = 5100.8100585938, instance = 571}
	FM.flightmasterDB[304] = {zone = "Zul'Drak", place = "The Argent Stand", id = 304, wx = -2672.25, wy = 5521.6298828125, instance = 571}
	FM.flightmasterDB[305] = {zone = "Zul'Drak", place = "Ebon Watch", id = 305, wx = -1302.2199707031, wy = 5218.8999023438, instance = 571}
	FM.flightmasterDB[306] = {zone = "Zul'Drak", place = "Light's Breach", id = 306, wx = -2206.4599609375, wy = 5190.1098632812, instance = 571}
	FM.flightmasterDB[307] = {zone = "Zul'Drak", place = "Zim'Torga", id = 307, wx = -3594.9399414062, wy = 5777.3999023438, instance = 571}
	FM.flightmasterDB[308] = {zone = "Sholazar Basin", place = "River's Heart", id = 308, wx = 4748.1000976562, wy = 5506.2299804688, instance = 571}
	FM.flightmasterDB[309] = {zone = "Sholazar Basin", place = "Nesingwary Base Camp", id = 309, wx = 5824.3701171875, wy = 5596.1000976562, instance = 571}
	FM.flightmasterDB[310] = {zone = "Dalaran", id = 310, wx = 449.13000488281, wy = 5813.8901367188, instance = 571}
	FM.flightmasterDB[315] = {zone = "Acherus: The Ebon Hold", id = 315, wx = -5666.91015625, wy = 2352.3701171875, instance = 0}
	FM.flightmasterDB[320] = {zone = "The Storm Peaks", place = "K3", id = 320, wx = -1052.9100341797, wy = 6186.75, instance = 571}
	FM.flightmasterDB[321] = {zone = "The Storm Peaks", place = "Frosthold", faction = "Alliance", id = 321, wx = -258.70001220703, wy = 6667.0400390625, instance = 571}
	FM.flightmasterDB[322] = {zone = "The Storm Peaks", place = "Dun Niffelem", id = 322, wx = -2607.6000976562, wy = 7308.0400390625, instance = 571}
	FM.flightmasterDB[323] = {zone = "The Storm Peaks", place = "Grom'arsh Crash-Site", faction = "Horde", id = 323, wx = -735.02001953125, wy = 7857.2998046875, instance = 571}
	FM.flightmasterDB[324] = {zone = "The Storm Peaks", place = "Camp Tunka'lo", faction = "Horde", id = 324, wx = -2810.0900878906, wy = 7793.8500976562, instance = 571}
	FM.flightmasterDB[325] = {zone = "Icecrown", place = "Death's Rise", id = 325, wx = 4224.16015625, wy = 7427.3198242188, instance = 571}
	FM.flightmasterDB[326] = {zone = "The Storm Peaks", place = "Ulduar", id = 326, wx = -1324.3299560547, wy = 8864.740234375, instance = 571}
	FM.flightmasterDB[327] = {zone = "The Storm Peaks", place = "Bouldercrag's Refuge", id = 327, wx = -335.95001220703, wy = 8472.4599609375, instance = 571}
	FM.flightmasterDB[331] = {zone = "Zul'Drak", place = "Gundrak", id = 331, wx = -4118.2299804688, wy = 6897.6499023438, instance = 571}
	FM.flightmasterDB[332] = {zone = "Wintergrasp", place = "Warsong Camp", faction = "Horde", id = 332, wx = 3685.5500488281, wy = 5024.990234375, instance = 571}
	FM.flightmasterDB[333] = {zone = "Icecrown", place = "The Shadow Vault", id = 333, wx = 2702.6599121094, wy = 8408.08984375, instance = 571}
	FM.flightmasterDB[334] = {zone = "Icecrown", place = "The Argent Vanguard", id = 334, wx = -61.31000137329, wy = 6164.490234375, instance = 571}
	FM.flightmasterDB[335] = {zone = "Icecrown", place = "Crusaders' Pinnacle", id = 335, wx = 467.85998535156, wy = 6402.0600585938, instance = 571}
	FM.flightmasterDB[336] = {zone = "Crystalsong Forest", place = "Windrunner's Overlook", faction = "Alliance", id = 336, wx = -519.96002197266, wy = 5035.6499023438, instance = 571}
	FM.flightmasterDB[337] = {zone = "Crystalsong Forest", place = "Sunreaver's Command", faction = "Horde", id = 337, wx = -693.22998046875, wy = 5590.490234375, instance = 571}
	FM.flightmasterDB[338] = {zone = "Ashenvale", place = "Blackfathom Camp", faction = "Alliance", id = 338, wx = 654.15997314453, wy = 3880.5100097656, instance = 1}
	FM.flightmasterDB[339] = {zone = "Darkshore", place = "Grove of the Ancients", faction = "Alliance", id = 339, wx = 147.64999389648, wy = 4970.5, instance = 1}
	FM.flightmasterDB[340] = {zone = "Icecrown", place = "Argent Tournament Grounds", id = 340, wx = 891.20001220703, wy = 8475.7900390625, instance = 571}
	FM.flightmasterDB[350] = {zone = "Ashenvale", place = "Hellscream's Watch", faction = "Horde", id = 350, wx = -498.95001220703, wy = 3049.080078125, instance = 1}
	FM.flightmasterDB[351] = {zone = "Ashenvale", place = "Stardust Spire", faction = "Alliance", id = 351, wx = -321.98999023438, wy = 1905.1099853516, instance = 1}
	FM.flightmasterDB[354] = {zone = "Ashenvale", place = "The Mor'Shan Ramparts", faction = "Horde", id = 354, wx = -2209.1499023438, wy = 1206.0500488281, instance = 1}
	FM.flightmasterDB[356] = {zone = "Ashenvale", place = "Silverwind Refuge", faction = "Horde", id = 356, wx = -1144.0500488281, wy = 2159.6201171875, instance = 1}
	FM.flightmasterDB[360] = {zone = "Stonetalon Mountains", place = "Cliffwalker Post", faction = "Horde", id = 360, wx = 1241.8900146484, wy = 2188.0, instance = 1}
	FM.flightmasterDB[361] = {zone = "Stonetalon Mountains", place = "Windshear Hold", faction = "Alliance", id = 361, wx = 432.86999511719, wy = 1268.5100097656, instance = 1}
	FM.flightmasterDB[362] = {zone = "Stonetalon Mountains", place = "Krom'gar Fortress", faction = "Horde", id = 362, wx = -21.25, wy = 932.11999511719, instance = 1}
	FM.flightmasterDB[363] = {zone = "Stonetalon Mountains", place = "Malaka'jin", faction = "Horde", id = 363, wx = -260.41000366211, wy = -111.94000244141, instance = 1}
	FM.flightmasterDB[364] = {zone = "Stonetalon Mountains", place = "Northwatch Expedition Base Camp", faction = "Alliance", id = 364, wx = -281.35000610352, wy = 237.88000488281, instance = 1}
	FM.flightmasterDB[365] = {zone = "Stonetalon Mountains", place = "Farwatcher's Glen", faction = "Alliance", id = 365, wx = 2013.1300048828, wy = 973.94000244141, instance = 1}
	FM.flightmasterDB[366] = {zone = "Desolace", place = "Furien's Post", faction = "Horde", id = 366, wx = 2242.6201171875, wy = -439.14999389648, instance = 1}
	FM.flightmasterDB[367] = {zone = "Desolace", place = "Thargad's Camp", faction = "Alliance", id = 367, wx = 2577.5700683594, wy = -1694.5300292969, instance = 1}
	FM.flightmasterDB[368] = {zone = "Desolace", place = "Karnum's Glade", id = 368, wx = 1637.9899902344, wy = -1038.4300537109, instance = 1}
	FM.flightmasterDB[369] = {zone = "Desolace", place = "Thunk's Abode", id = 369, wx = 1056.6800537109, wy = -534.03997802734, instance = 1}
	FM.flightmasterDB[370] = {zone = "Desolace", place = "Ethel Rethor", id = 370, wx = 2478.8999023438, wy = -356.4700012207, instance = 1}
	FM.flightmasterDB[383] = {zone = "Eastern Plaguelands", place = "Thondroril River", id = 383, wx = -2694.4799804688, wy = 1935.9699707031, instance = 0}
	FM.flightmasterDB[384] = {zone = "Tirisfal", place = "The Bulwark", faction = "Horde", id = 384, wx = -740.98101806641, wy = 1726.6199951172, instance = 0}
	FM.flightmasterDB[386] = {zone = "Un'Goro Crater", place = "Mossy Pile", id = 386, wx = -1095.2399902344, wy = -6958.4399414062, instance = 1}
	FM.flightmasterDB[387] = {zone = "Southern Barrens", place = "Honor's Stand", faction = "Alliance", id = 387, wx = -1532.4399414062, wy = -335.20001220703, instance = 1}
	FM.flightmasterDB[388] = {zone = "Southern Barrens", place = "Northwatch Hold", faction = "Alliance", id = 388, wx = -3561.7900390625, wy = -2124.2099609375, instance = 1}
	FM.flightmasterDB[389] = {zone = "Southern Barrens", place = "Fort Triumph", faction = "Alliance", id = 389, wx = -2286.2700195312, wy = -3150.25, instance = 1}
	FM.flightmasterDB[390] = {zone = "Southern Barrens", place = "Hunter's Hill", faction = "Horde", id = 390, wx = -1590.8699951172, wy = -798.71997070313, instance = 1}
	FM.flightmasterDB[391] = {zone = "Southern Barrens", place = "Desolation Hold", faction = "Horde", id = 391, wx = -1697.9899902344, wy = -3288.8500976562, instance = 1}
	FM.flightmasterDB[402] = {zone = "Mulgore", place = "Bloodhoof Village", faction = "Horde", id = 402, wx = -379.06900024414, wy = -2299.5400390625, instance = 1}
	FM.flightmasterDB[456] = {zone = "Teldrassil", place = "Dolanaar", faction = "Alliance", id = 456, wx = 977.69799804688, wy = 9873.099609375, instance = 1}
	FM.flightmasterDB[457] = {zone = "Teldrassil", place = "Darnassus", faction = "Alliance", id = 457, wx = 2622.0900878906, wy = 9968.7998046875, instance = 1}
	FM.flightmasterDB[458] = {zone = "Northern Barrens", place = "Nozzlepot's Outpost", faction = "Horde", id = 458, wx = -3381.7399902344, wy = 1152.5999755859, instance = 1}
	FM.flightmasterDB[460] = {zone = "Tirisfal Glades", place = "Brill", faction = "Horde", id = 460, wx = 372.06399536133, wy = 2272.6799316406, instance = 0}
	FM.flightmasterDB[513] = {zone = "Thousand Needles", place = "Fizzle & Pozzik's Speedbarge", id = 513, wx = -3913.4399414062, wy = -6075.3701171875, instance = 1}
	FM.flightmasterDB[521] = {zone = "Vashj'ir", place = "Smuggler's Scar", id = 521, wx = 3481.1201171875, wy = -4588.0498046875, instance = 0}
	FM.flightmasterDB[522] = {zone = "Vashj'ir", place = "Silver Tide Hollow", id = 522, wx = 4285.080078125, wy = -6105.6098632812, instance = 0}
	FM.flightmasterDB[523] = {zone = "Vashj'ir", place = "Tranquil Wash", faction = "Alliance", id = 523, wx = 4308.2797851562, wy = -6616.3999023438, instance = 0}
	FM.flightmasterDB[524] = {zone = "Vashj'ir", place = "Darkbreak Cove", faction = "Alliance", id = 524, wx = 5943.8198242188, wy = -6902.25, instance = 0}
	FM.flightmasterDB[525] = {zone = "Vashj'ir", place = "Legion's Rest", faction = "Horde", id = 525, wx = 4199.8500976562, wy = -6805.6298828125, instance = 0}
	FM.flightmasterDB[526] = {zone = "Vashj'ir", place = "Tenebrous Cavern", faction = "Horde", id = 526, wx = 6075.25, wy = -6507.990234375, instance = 0}
	FM.flightmasterDB[531] = {zone = "Tanaris", place = "Dawnrise Expedition", faction = "Horde", id = 531, wx = -2467.1298828125, wy = -9487.8896484375, instance = 1}
	FM.flightmasterDB[532] = {zone = "Tanaris", place = "Gunstan's Dig", faction = "Alliance", id = 532, wx = -2953.9899902344, wy = -9493.7099609375, instance = 1}
	FM.flightmasterDB[536] = {zone = "Durotar", place = "Sen'jin Village", faction = "Horde", id = 536, wx = -4890.2797851562, wy = -780.26702880859, instance = 1}
	FM.flightmasterDB[537] = {zone = "Durotar", place = "Razor Hill", faction = "Horde", id = 537, wx = -4766.759765625, wy = 269.9169921875, instance = 1}
	FM.flightmasterDB[539] = {zone = "Tanaris", place = "Bootlegger Outpost", id = 539, wx = -4088.1000976562, wy = -8683.08984375, instance = 1}
	FM.flightmasterDB[540] = {zone = "Stonetalon Mountains", place = "The Sludgewerks", faction = "Horde", id = 540, wx = 727.2080078125, wy = 1825.9399414062, instance = 1}
	FM.flightmasterDB[541] = {zone = "Stonetalon Mountains", place = "Mirkfallon Post", faction = "Alliance", id = 541, wx = 1034.8599853516, wy = 1379.4200439453, instance = 1}
	FM.flightmasterDB[551] = {zone = "Wetlands", place = "Whelgar's Retreat", faction = "Alliance", id = 551, wx = -1989.4899902344, wy = -3222.9299316406, instance = 0}
	FM.flightmasterDB[552] = {zone = "Wetlands", place = "Greenwarden's Grove", faction = "Alliance", id = 552, wx = -2718.6899414062, wy = -3306.6499023438, instance = 0}
	FM.flightmasterDB[553] = {zone = "Wetlands", place = "Dun Modr", faction = "Alliance", id = 553, wx = -2464.2800292969, wy = -2656.5400390625, instance = 0}
	FM.flightmasterDB[554] = {zone = "Wetlands", place = "Slabchisel's Survey", faction = "Alliance", id = 554, wx = -2741.2099609375, wy = -4113.6000976562, instance = 0}
	FM.flightmasterDB[555] = {zone = "Loch Modan", place = "Farstrider Lodge", faction = "Alliance", id = 555, wx = -4253.4399414062, wy = -5668.3100585938, instance = 0}
	FM.flightmasterDB[557] = {zone = "Hyjal", place = "Shrine of Aviana", id = 557, wx = -2676.1899414062, wy = 4987.8701171875, instance = 1}
	FM.flightmasterDB[558] = {zone = "Hyjal", place = "Grove of Aessina", id = 558, wx = -1760.5799560547, wy = 5163.509765625, instance = 1}
	FM.flightmasterDB[559] = {zone = "Hyjal", place = "Nordrassil", id = 559, wx = -3569.8400878906, wy = 5584.0600585938, instance = 1}
	FM.flightmasterDB[565] = {zone = "Feralas", place = "Dreamer's Rest", faction = "Alliance", id = 565, wx = 1951.6700439453, wy = -3136.6201171875, instance = 1}
	FM.flightmasterDB[567] = {zone = "Feralas", place = "Tower of Estulan", faction = "Alliance", id = 567, wx = 1478.1600341797, wy = -4863.6401367188, instance = 1}
	FM.flightmasterDB[568] = {zone = "Feralas", place = "Camp Ataya", faction = "Horde", id = 568, wx = 2560.1000976562, wy = -3081.6999511719, instance = 1}
	FM.flightmasterDB[569] = {zone = "Feralas", place = "Stonemaul Hold", faction = "Horde", id = 569, wx = 1898.1899414062, wy = -4606.5200195312, instance = 1}
	FM.flightmasterDB[582] = {zone = "Elwynn", place = "Goldshire", faction = "Alliance", id = 582, wx = 85.14929962158, wy = -9433.990234375, instance = 0}
	FM.flightmasterDB[583] = {zone = "Westfall", place = "Moonbrook", faction = "Alliance", id = 583, wx = 1542.8800048828, wy = -10876.900390625, instance = 0}
	FM.flightmasterDB[584] = {zone = "Westfall", place = "Furlbrow's Pumpkin Farm", faction = "Alliance", id = 584, wx = 1273.9300537109, wy = -9838.509765625, instance = 0}
	FM.flightmasterDB[589] = {zone = "Elwynn", place = "Eastvale Logging Camp", faction = "Alliance", id = 589, wx = -1306.7399902344, wy = -9475.7099609375, instance = 0}
	FM.flightmasterDB[590] = {zone = "Stranglethorn", place = "Fort Livingston", faction = "Alliance", id = 590, wx = -413.70999145508, wy = -12828.799804688, instance = 0}
	FM.flightmasterDB[591] = {zone = "Stranglethorn", place = "Explorers' League Digsite", faction = "Alliance", id = 591, wx = -85.54859924316, wy = -13600.900390625, instance = 0}
	FM.flightmasterDB[592] = {zone = "Stranglethorn", place = "Hardwrench Hideaway", faction = "Horde", id = 592, wx = 722.02801513672, wy = -13288.299804688, instance = 0}
	FM.flightmasterDB[593] = {zone = "Stranglethorn", place = "Bambala", faction = "Horde", id = 593, wx = -814.09899902344, wy = -12092.200195312, instance = 0}
	FM.flightmasterDB[594] = {zone = "Felwood", place = "Whisperwind Grove", id = 594, wx = -844.99798583984, wy = 6078.509765625, instance = 1}
	FM.flightmasterDB[595] = {zone = "Felwood", place = "Wildheart Point", id = 595, wx = -883.80603027344, wy = 4734.16015625, instance = 1}
	FM.flightmasterDB[596] = {zone = "Redridge", place = "Shalewind Canyon", faction = "Alliance", id = 596, wx = -3479.3701171875, wy = -9641.669921875, instance = 0}
	FM.flightmasterDB[597] = {zone = "Felwood", place = "Irontree Clearing", faction = "Horde", id = 597, wx = -1620.4100341797, wy = 6892.6899414062, instance = 1}
	FM.flightmasterDB[598] = {zone = "Swamp of Sorrows", place = "Marshtide Watch", faction = "Alliance", id = 598, wx = -3836.5400390625, wy = -10176.599609375, instance = 0}
	FM.flightmasterDB[599] = {zone = "Swamp of Sorrows", place = "Bogpaddle", id = 599, wx = -3890.7199707031, wy = -9737.080078125, instance = 0}
	FM.flightmasterDB[600] = {zone = "Swamp of Sorrows", place = "The Harborage", faction = "Alliance", id = 600, wx = -2852.4799804688, wy = -10118.599609375, instance = 0}
	FM.flightmasterDB[601] = {zone = "Arathi", place = "Galen's Fall", faction = "Horde", id = 601, wx = -1585.7399902344, wy = -952.37701416016, instance = 0}
	FM.flightmasterDB[602] = {zone = "Blasted Lands", place = "Surwich", faction = "Alliance", id = 602, wx = -2919.0400390625, wy = -12761.900390625, instance = 0}
	FM.flightmasterDB[603] = {zone = "Blasted Lands", place = "Sunveil Excursion", faction = "Horde", id = 603, wx = -3058.2299804688, wy = -12357.599609375, instance = 0}
	FM.flightmasterDB[604] = {zone = "Blasted Lands", place = "Dreadmaul Hold", faction = "Horde", id = 604, wx = -2790.9799804688, wy = -10933.299804688, instance = 0}
	FM.flightmasterDB[605] = {zone = "Vashj'ir", place = "Voldrin's Hold", faction = "Alliance", id = 605, wx = 3925.8500976562, wy = -7209.7099609375, instance = 0}
	FM.flightmasterDB[606] = {zone = "Vashj'ir", place = "Sandy Beach", faction = "Alliance", id = 606, wx = 3914.419921875, wy = -5310.8500976562, instance = 0}
	FM.flightmasterDB[608] = {zone = "Vashj'ir", place = "Sandy Beach", faction = "Horde", id = 608, wx = 3720.0700683594, wy = -5671.0200195312, instance = 0}
	FM.flightmasterDB[610] = {zone = "Vashj'ir", place = "Stygian Bounty", faction = "Horde", id = 610, wx = 4244.7099609375, wy = -6878.5200195312, instance = 0}
	FM.flightmasterDB[613] = {zone = "Azshara", place = "Southern Rocketway", faction = "Horde", id = 613, wx = -6214.3999023438, wy = 2647.7900390625, instance = 1}
	FM.flightmasterDB[614] = {zone = "Azshara", place = "Northern Rocketway", faction = "Horde", id = 614, wx = -7041.7998046875, wy = 4611.3798828125, instance = 1}
	FM.flightmasterDB[615] = {zone = "Redridge", place = "Camp Everstill", faction = "Alliance", id = 615, wx = -2836.9899902344, wy = -9446.6396484375, instance = 0}
	FM.flightmasterDB[616] = {zone = "Hyjal", place = "Gates of Sothann", id = 616, wx = -3966.75, wy = 4059.3999023438, instance = 1}
	FM.flightmasterDB[617] = {zone = "The Hinterlands", place = "Hiri'watha Research Station", faction = "Horde", id = 617, wx = -2821.7800292969, wy = -25.77599906921, instance = 0}
	FM.flightmasterDB[618] = {zone = "The Hinterlands", place = "Stormfeather Outpost", faction = "Alliance", id = 618, wx = -4105.3598632812, wy = 312.32598876953, instance = 0}
	FM.flightmasterDB[619] = {zone = "Dun Morogh", place = "Kharanos", faction = "Alliance", id = 619, wx = -494.85101318359, wy = -5660.7998046875, instance = 0}
	FM.flightmasterDB[620] = {zone = "Dun Morogh", place = "Gol'Bolar Quarry", faction = "Alliance", id = 620, wx = -1578.6400146484, wy = -5714.1401367188, instance = 0}
	FM.flightmasterDB[622] = {zone = "Duskwood", place = "Raven Hill", faction = "Alliance", id = 622, wx = 267.04299926758, wy = -10737.599609375, instance = 0}
	FM.flightmasterDB[624] = {zone = "Azuremyst Isle", place = "Azure Watch", faction = "Alliance", id = 624, wx = -12520.5, wy = -4130.080078125, instance = 530}
	FM.flightmasterDB[625] = {zone = "Eversong Woods", place = "Fairbreeze Village", faction = "Horde", id = 625, wx = -6654.1201171875, wy = 8745.7802734375, instance = 530}
	FM.flightmasterDB[630] = {zone = "Eastern Plaguelands", place = "Light's Shield Tower", id = 630, wx = -4411.5200195312, wy = 2262.1000976562, instance = 0}
	FM.flightmasterDB[631] = {zone = "Eversong Woods", place = "Falconwing Square", faction = "Horde", id = 631, wx = -6767.08984375, wy = 9501.9296875, instance = 530}
	FM.flightmasterDB[632] = {zone = "Badlands", place = "Bloodwatcher Point", faction = "Horde", id = 632, wx = -3513.9899902344, wy = -6898.25, instance = 0}
	FM.flightmasterDB[633] = {zone = "Badlands", place = "Dustwind Dig", faction = "Alliance", id = 633, wx = -3401.1799316406, wy = -6594.08984375, instance = 0}
	FM.flightmasterDB[634] = {zone = "Badlands", place = "Dragon's Mouth", faction = "Alliance", id = 634, wx = -2570.7900390625, wy = -7034.5297851562, instance = 0}
	FM.flightmasterDB[635] = {zone = "Badlands", place = "Fuselight", id = 635, wx = -3875.1298828125, wy = -6574.9399414062, instance = 0}
	FM.flightmasterDB[645] = {zone = "Silverpine Forest", place = "Forsaken High Command", faction = "Horde", id = 645, wx = 1018.2299804688, wy = 1421.0200195312, instance = 0}
	FM.flightmasterDB[646] = {zone = "Gilneas", place = "Forsaken Forward Command", faction = "Horde", id = 646, wx = 1638.5999755859, wy = -910.22100830078, instance = 0}
	FM.flightmasterDB[649] = {zone = "Western Plaguelands", place = "Andorhal", faction = "Horde", id = 649, wx = -1586.9499511719, wy = 1511.8000488281, instance = 0}
	FM.flightmasterDB[650] = {zone = "Western Plaguelands", place = "Andorhal", faction = "Alliance", id = 650, wx = -1281.9399414062, wy = 1374.2299804688, instance = 0}
	FM.flightmasterDB[651] = {zone = "Western Plaguelands", place = "The Menders' Stead", id = 651, wx = -1755.8199462891, wy = 1864.3199462891, instance = 0}
	FM.flightmasterDB[652] = {zone = "Uldum", place = "Ramkahen", id = 652, wx = -1042.9699707031, wy = -9415.01953125, instance = 1}
	FM.flightmasterDB[653] = {zone = "Uldum", place = "Oasis of Vir'sar", id = 653, wx = 791.25897216797, wy = -8375.4697265625, instance = 1}
	FM.flightmasterDB[654] = {zone = "Silverpine Forest", place = "The Forsaken Front", faction = "Horde", id = 654, wx = 1312.3199462891, wy = -114.14199829102, instance = 0}
	FM.flightmasterDB[656] = {zone = "Twilight Highlands", place = "Crushblow", faction = "Horde", id = 656, wx = -4848.9301757812, wy = -4831.759765625, instance = 0}
	FM.flightmasterDB[657] = {zone = "Twilight Highlands", place = "The Gullet", faction = "Horde", id = 657, wx = -4379.4799804688, wy = -3494.6298828125, instance = 0}
	FM.flightmasterDB[658] = {zone = "Twilight Highlands", place = "Vermillion Redoubt", id = 658, wx = -3940.9699707031, wy = -3032.7600097656, instance = 0}
	FM.flightmasterDB[659] = {zone = "Twilight Highlands", place = "Bloodgulch", faction = "Horde", id = 659, wx = -5288.1899414062, wy = -3637.5600585938, instance = 0}
	FM.flightmasterDB[660] = {zone = "Twilight Highlands", place = "The Krazzworks", faction = "Horde", id = 660, wx = -6409.2797851562, wy = -2780.1799316406, instance = 0}
	FM.flightmasterDB[661] = {zone = "Twilight Highlands", place = "Dragonmaw Port", faction = "Horde", id = 661, wx = -6329.25, wy = -4012.4499511719, instance = 0}
	FM.flightmasterDB[662] = {zone = "Twilight Highlands", place = "Highbank", faction = "Alliance", id = 662, wx = -6740.6098632812, wy = -4863.1000976562, instance = 0}
	FM.flightmasterDB[663] = {zone = "Twilight Highlands", place = "Victor's Point", faction = "Alliance", id = 663, wx = -4748.9301757812, wy = -4170.5498046875, instance = 0}
	FM.flightmasterDB[664] = {zone = "Twilight Highlands", place = "Firebeard's Patrol", faction = "Alliance", id = 664, wx = -5620.1499023438, wy = -4183.8999023438, instance = 0}
	FM.flightmasterDB[665] = {zone = "Twilight Highlands", place = "Thundermar", faction = "Alliance", id = 665, wx = -4994.2797851562, wy = -3146.919921875, instance = 0}
	FM.flightmasterDB[666] = {zone = "Twilight Highlands", place = "Kirthaven", faction = "Alliance", id = 666, wx = -5427.5297851562, wy = -2689.4299316406, instance = 0}
	FM.flightmasterDB[667] = {zone = "Hillsbrad", place = "Ruins of Southshore", faction = "Horde", id = 667, wx = -536.49298095703, wy = -661.83697509766, instance = 0}
	FM.flightmasterDB[668] = {zone = "Hillsbrad", place = "Southpoint Gate", faction = "Horde", id = 668, wx = 435.46499633789, wy = -605.18402099609, instance = 0}
	FM.flightmasterDB[669] = {zone = "Hillsbrad", place = "Eastpoint Tower", faction = "Horde", id = 669, wx = -1051.1999511719, wy = -566.88897705078, instance = 0}
	FM.flightmasterDB[670] = {zone = "Alterac Mountains", place = "Strahnbrad", faction = "Horde", id = 670, wx = -979.57800292969, wy = 622.85101318359, instance = 0}
	FM.flightmasterDB[672] = {zone = "Western Plaguelands", place = "Hearthglen", id = 672, wx = -1500.5100097656, wy = 2839.7800292969, instance = 0}
	FM.flightmasterDB[673] = {zone = "Searing Gorge", place = "Iron Summit", id = 673, wx = -1236.6300048828, wy = -7123.0600585938, instance = 0}
	FM.flightmasterDB[674] = {zone = "Uldum", place = "Schnottz's Landing", id = 674, wx = 1059.6199951172, wy = -10711.900390625, instance = 1}
	FM.flightmasterDB[675] = {zone = "Burning Steppes", place = "Flamestar Post", id = 675, wx = -1025.7900390625, wy = -8092.259765625, instance = 0}
	FM.flightmasterDB[676] = {zone = "Burning Steppes", place = "Chiselgrip", id = 676, wx = -1919.5300292969, wy = -7865.9301757812, instance = 0}
	FM.flightmasterDB[681] = {zone = "Silverpine Forest", place = "Forsaken Rear Guard", faction = "Horde", id = 681, wx = 1518.9000244141, wy = 1056.0600585938, instance = 0}
	FM.flightmasterDB[683] = {zone = "Azshara", place = "Valormok", faction = "Horde", id = 683, wx = -4161.3598632812, wy = 2988.1298828125, instance = 1}
	FM.flightmasterDB[781] = {zone = "Hyjal", place = "Sanctuary of Malorne", id = 781, wx = -2107.5300292969, wy = 4397.7900390625, instance = 1}
end

-- Mists of Pandaria
if select(4, GetBuildInfo()) >= 50000 then
	FM.flightmasterDB[894] = {zone = "Jade Forest", place = "Grookin Hill", faction = "Horde", id = 894, wx = -487.70300292969, wy = 1418.5699462891, instance = 870}
	FM.flightmasterDB[895] = {zone = "Jade Forest", place = "Dawn's Blossom", id = 895, wx = -1832.1300048828, wy = 1503.7099609375, instance = 870}
	FM.flightmasterDB[966] = {zone = "Jade Forest", place = "Paw'Don Village", faction = "Alliance", id = 966, wx = -1762.7700195312, wy = -307.20001220703, instance = 870}
	FM.flightmasterDB[967] = {zone = "Jade Forest", place = "The Arboretum", id = 967, wx = -2530.2700195312, wy = 1600.6600341797, instance = 870}
	FM.flightmasterDB[968] = {zone = "Jade Forest", place = "Jade Temple Grounds", id = 968, wx = -2358.9599609375, wy = 773.24700927734, instance = 870}
	FM.flightmasterDB[969] = {zone = "Jade Forest", place = "Sri-La Village", id = 969, wx = -2418.3200683594, wy = 2550.7600097656, instance = 870}
	FM.flightmasterDB[970] = {zone = "Jade Forest", place = "Emperor's Omen", id = 970, wx = -2099.4299316406, wy = 2400.75, instance = 870}
	FM.flightmasterDB[971] = {zone = "Jade Forest", place = "Tian Monastery", id = 971, wx = -1590.8900146484, wy = 2505.8999023438, instance = 870}
	FM.flightmasterDB[972] = {zone = "Jade Forest", place = "Pearlfin Village", faction = "Alliance", id = 972, wx = -2594.6101074219, wy = -186.09700012207, instance = 870}
	FM.flightmasterDB[973] = {zone = "Jade Forest", place = "Honeydew Village", faction = "Horde", id = 973, wx = -509.18399047852, wy = 2927.1599121094, instance = 870}
	FM.flightmasterDB[984] = {zone = "Valley of the Four Winds", place = "Pang's Stead", id = 984, wx = -637.81402587891, wy = 543.91497802734, instance = 870}
	FM.flightmasterDB[985] = {zone = "Valley of the Four Winds", place = "Halfhill", id = 985, wx = 464.55899047852, wy = -221.32600402832, instance = 870}
	FM.flightmasterDB[986] = {zone = "Krasarang Wilds", place = "Zhu's Watch", id = 986, wx = -647.96502685547, wy = -375.68399047852, instance = 870}
	FM.flightmasterDB[987] = {zone = "Krasarang Wilds", place = "Thunder Cleft", faction = "Horde", id = 987, wx = 171.40299987793, wy = -878.27600097656, instance = 870}
	FM.flightmasterDB[988] = {zone = "Krasarang Wilds", place = "The Incursion", faction = "Alliance", id = 988, wx = -227.74699401856, wy = -1125.3100585938, instance = 870}
	FM.flightmasterDB[989] = {zone = "Valley of the Four Winds", place = "Stoneplow", id = 989, wx = 1886.6999511719, wy = -436.54000854492, instance = 870}
	FM.flightmasterDB[990] = {zone = "Krasarang Wilds", place = "Dawnchaser Retreat", faction = "Horde", id = 990, wx = 1590.3399658203, wy = -1685.6800537109, instance = 870}
	FM.flightmasterDB[991] = {zone = "Krasarang Wilds", place = "Sentinel Basecamp", faction = "Alliance", id = 991, wx = 1770.3800048828, wy = -1156.6099853516, instance = 870}
	FM.flightmasterDB[992] = {zone = "Krasarang Wilds", place = "Cradle of Chi-Ji", id = 992, wx = 1483.6300048828, wy = -2082.3000488281, instance = 870}
	FM.flightmasterDB[993] = {zone = "Krasarang Wilds", place = "Marista", id = 993, wx = 491.5830078125, wy = -2504.0900878906, instance = 870}
	FM.flightmasterDB[1017] = {zone = "Kun-Lai Summit", place = "Binan Village", id = 1017, wx = 303.9580078125, wy = 1690.1099853516, instance = 870}
	FM.flightmasterDB[1018] = {zone = "Kun-Lai Summit", place = "Temple of the White Tiger", id = 1018, wx = 690.67700195313, wy = 3504.0400390625, instance = 870}
	FM.flightmasterDB[1019] = {zone = "Kun-Lai Summit", place = "Eastwind Rest", faction = "Horde", id = 1019, wx = 931.56896972656, wy = 2250.5900878906, instance = 870}
	FM.flightmasterDB[1020] = {zone = "Kun-Lai Summit", place = "Westwind Rest", faction = "Alliance", id = 1020, wx = 1463.8299560547, wy = 2103.3500976562, instance = 870}
	FM.flightmasterDB[1021] = {zone = "Kun-Lai Summit", place = "Zouchin Village", id = 1021, wx = 932.11798095703, wy = 4362.9599609375, instance = 870}
	FM.flightmasterDB[1022] = {zone = "Kun-Lai Summit", place = "One Keg", id = 1022, wx = 1224.2800292969, wy = 3124.5200195312, instance = 870}
	FM.flightmasterDB[1023] = {zone = "Kun-Lai Summit", place = "Kota Basecamp", id = 1023, wx = 2163.3100585938, wy = 2716.4299316406, instance = 870}
	FM.flightmasterDB[1024] = {zone = "Kun-Lai Summit", place = "Shado-Pan Fallback", id = 1024, wx = 2088.580078125, wy = 1880.5899658203, instance = 870}
	FM.flightmasterDB[1025] = {zone = "Kun-Lai Summit", place = "Winter's Blossom", id = 1025, wx = 2677.7600097656, wy = 3151.8500976562, instance = 870}
	FM.flightmasterDB[1029] = {zone = "The Veiled Stair", place = "Tavern in the Mists", id = 1029, wx = -203.66999816895, wy = 784.89898681641, instance = 870}
	FM.flightmasterDB[1052] = {zone = "Valley of the Four Winds", place = "Grassy Cline", id = 1052, wx = -100.46700286865, wy = 460.54000854492, instance = 870}
	FM.flightmasterDB[1053] = {zone = "Townlong Steppes", place = "Longying Outpost", id = 1053, wx = 2994.3898925781, wy = 2363.2299804688, instance = 870}
	FM.flightmasterDB[1054] = {zone = "Townlong Steppes", place = "Gao-Ran Battlefront", id = 1054, wx = 2804.4899902344, wy = 1440.7199707031, instance = 870}
	FM.flightmasterDB[1055] = {zone = "Townlong Steppes", place = "Rensai's Watchpost", id = 1055, wx = 3963.6999511719, wy = 1531.7299804688, instance = 870}
	FM.flightmasterDB[1056] = {zone = "Townlong Steppes", place = "Shado-Pan Garrison", id = 1056, wx = 4204.2299804688, wy = 1803.3199462891, instance = 870}
	FM.flightmasterDB[1057] = {zone = "Vale of Eternal Blossoms", place = "Shrine of Seven Stars", faction = "Alliance", id = 1057, wx = 334.35101318359, wy = 896.45300292969, instance = 870}
	FM.flightmasterDB[1058] = {zone = "Vale of Eternal Blossoms", place = "Shrine of Two Moons", faction = "Horde", id = 1058, wx = 894.1669921875, wy = 1580.1600341797, instance = 870}
	FM.flightmasterDB[1070] = {zone = "Dread Wastes", place = "Klaxxi'vess", id = 1070, wx = 3152.25, wy = 172.66299438477, instance = 870}
	FM.flightmasterDB[1071] = {zone = "Dread Wastes", place = "Soggy's Gamble", id = 1071, wx = 3136.1899414062, wy = -1086.2099609375, instance = 870}
	FM.flightmasterDB[1072] = {zone = "Dread Wastes", place = "The Sunset Brewgarden", id = 1072, wx = 3451.8601074219, wy = 982.67700195313, instance = 870}
	FM.flightmasterDB[1073] = {zone = "Vale of Eternal Blossoms", place = "Serpent's Spine", id = 1073, wx = 2125.0300292969, wy = 611.36499023438, instance = 870}
	FM.flightmasterDB[1080] = {zone = "Jade Forest", place = "Serpent's Overlook", id = 1080, wx = -1558.5600585938, wy = 465.85598754883, instance = 870}
	FM.flightmasterDB[1090] = {zone = "Dread Wastes", place = "The Briny Muck", id = 1090, wx = 3859.7900390625, wy = -570.40502929688, instance = 870}
	FM.flightmasterDB[1115] = {zone = "Dread Wastes", place = "The Lion's Redoubt", faction = "Alliance", id = 1115, wx = 2198.0300292969, wy = 234.40600585938, instance = 870}
	FM.flightmasterDB[1117] = {zone = "Kun-Lai Summit", place = "Serpent's Spine", faction = "Horde", id = 1117, wx = 2584.9299316406, wy = 2123.1499023438, instance = 870}
	FM.flightmasterDB[1190] = {zone = "Krasarang Wilds", place = "Lion's Landing", faction = "Alliance", id = 1190, wx = -1193.6999511719, wy = -1193.5600585938, instance = 870}
	FM.flightmasterDB[1195] = {zone = "Krasarang Wilds", place = "Domination Point", faction = "Horde", id = 1195, wx = 2492.0200195312, wy = -1752.1899414062, instance = 870}
	FM.flightmasterDB[1221] = {zone = "Isle Of Giants", place = "Beeble's Wreck", faction = "Alliance", id = 1221, wx = 1255.5500488281, wy = 5753.759765625, instance = 870}
	FM.flightmasterDB[1222] = {zone = "Isle Of Giants", place = "Bozzle's Wreck", faction = "Horde", id = 1222, wx = 1080.5699462891, wy = 5799.6401367188, instance = 870}
	FM.flightmasterDB[1293] = {zone = "Timeless Isle", place = "Tushui Landing", faction = "Alliance", id = 1293, wx = -4639.1201171875, wy = -901.36999511719, instance = 870}
	FM.flightmasterDB[1294] = {zone = "Timeless Isle", place = "Huojin Landing", faction = "Horde", id = 1294, wx = -4608.5600585938, wy = -404.95001220703, instance = 870}
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
	