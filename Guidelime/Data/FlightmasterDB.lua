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
	FM.flightmasterDB[1] = {zone = "Northshire Abbey", id = 1, wx = -888898046875.0, wy = -0.54000002146, instance = 0}
	FM.flightmasterDB[2] = {zone = "Elwynn", place = "Stormwind", faction = "Alliance", id = 2, wx = -88410595703125.0, wy = 48965600585938.0, instance = 0}
	FM.flightmasterDB[4] = {zone = "Westfall", place = "Sentinel Hill", faction = "Alliance", id = 4, wx = -10551900390625.0, wy = 10343900146484.0, instance = 0}
	FM.flightmasterDB[5] = {zone = "Redridge", place = "Lakeshire", faction = "Alliance", id = 5, wx = -9429099609375.0, wy = -22313999023438.0, instance = 0}
	FM.flightmasterDB[6] = {zone = "Dun Morogh", place = "Ironforge", faction = "Alliance", id = 6, wx = -48217797851562.0, wy = -11554399414062.0, instance = 0}
	FM.flightmasterDB[7] = {zone = "Wetlands", place = "Menethil Harbor", faction = "Alliance", id = 7, wx = -37878100585938.0, wy = -77769598388672.0, instance = 0}
	FM.flightmasterDB[8] = {zone = "Loch Modan", place = "Thelsamar", faction = "Alliance", id = 8, wx = -542191015625.0, wy = -29300100097656.0, instance = 0}
	FM.flightmasterDB[9] = {zone = "Stranglethorn", place = "Booty Bay", id = 9, wx = -14271799804688.0, wy = 29986999511719.0, instance = 0}
	FM.flightmasterDB[10] = {zone = "Silverpine Forest", place = "The Sepulcher", faction = "Horde", id = 10, wx = 47885998535156.0, wy = 15365899658203.0, instance = 0}
	FM.flightmasterDB[11] = {zone = "Tirisfal", place = "Undercity", faction = "Horde", id = 11, wx = 15686199951172.0, wy = 2679700012207.0, instance = 0}
	FM.flightmasterDB[12] = {zone = "Duskwood", place = "Darkshire", faction = "Alliance", id = 12, wx = -10515.5, wy = -12616500244141.0, instance = 0}
	FM.flightmasterDB[13] = {zone = "Hillsbrad", place = "Tarren Mill", faction = "Horde", id = 13, wx = -1770660018921.0, wy = -87420300292969.0, instance = 0}
	FM.flightmasterDB[14] = {zone = "Hillsbrad", place = "Southshore", id = 14, wx = -71147998046875.0, wy = -51547998046875.0, instance = 0}
	FM.flightmasterDB[15] = {zone = "Eastern Plaguelands", id = 15, wx = 22533999023438.0, wy = -53448999023438.0, instance = 0}
	FM.flightmasterDB[16] = {zone = "Arathi", place = "Refuge Pointe", faction = "Alliance", id = 16, wx = -12405300292969.0, wy = -25151101074219.0, instance = 0}
	FM.flightmasterDB[17] = {zone = "Arathi", place = "Hammerfall", faction = "Horde", id = 17, wx = -91628997802734.0, wy = -34968898925781.0, instance = 0}
	FM.flightmasterDB[18] = {zone = "Stranglethorn", place = "Booty Bay", faction = "Horde", id = 18, wx = -14444290039062.0, wy = 50961999511719.0, instance = 0}
	FM.flightmasterDB[19] = {zone = "Stranglethorn", place = "Booty Bay", faction = "Alliance", id = 19, wx = -14473.0, wy = 46414999389648.0, instance = 0}
	FM.flightmasterDB[20] = {zone = "Stranglethorn", place = "Grom'gol", faction = "Horde", id = 20, wx = -12414200195312.0, wy = 14628999328613.0, instance = 0}
	FM.flightmasterDB[21] = {zone = "Badlands", place = "New Kargath", faction = "Horde", id = 21, wx = -66768701171875.0, wy = -24333701171875.0, instance = 0}
	FM.flightmasterDB[22] = {zone = "Mulgore", place = "Thunder Bluff", faction = "Horde", id = 22, wx = -11972099609375.0, wy = 2970999908447.0, instance = 1}
	FM.flightmasterDB[23] = {zone = "Durotar", place = "Orgrimmar", faction = "Horde", id = 23, wx = 17982700195312.0, wy = -43632700195312.0, instance = 1}
	FM.flightmasterDB[25] = {zone = "Northern Barrens", place = "The Crossroads", faction = "Horde", id = 25, wx = -44179998779297.0, wy = -2596080078125.0, instance = 1}
	FM.flightmasterDB[26] = {zone = "Darkshore", place = "Lor'danel", faction = "Alliance", id = 26, wx = 74598999023438.0, wy = -32655999755859.0, instance = 1}
	FM.flightmasterDB[27] = {zone = "Teldrassil", place = "Rut'theran Village", faction = "Alliance", id = 27, wx = 8383.75, wy = 98096398925781.0, instance = 1}
	FM.flightmasterDB[28] = {zone = "Ashenvale", place = "Astranaar", faction = "Alliance", id = 28, wx = 28273400878906.0, wy = -28923999023438.0, instance = 1}
	FM.flightmasterDB[29] = {zone = "Stonetalon Mountains", place = "Sun Rock Retreat", faction = "Horde", id = 29, wx = 96657000732422.0, wy = 10403199462891.0, instance = 1}
	FM.flightmasterDB[30] = {zone = "Thousand Needles", place = "Westreach Summit", faction = "Horde", id = 30, wx = -43106098632812.0, wy = -92706402587891.0, instance = 1}
	FM.flightmasterDB[31] = {zone = "Feralas", place = "Shadebough", faction = "Alliance", id = 31, wx = -49968798828125.0, wy = 7394270324707.0, instance = 1}
	FM.flightmasterDB[32] = {zone = "Dustwallow Marsh", place = "Theramore", id = 32, wx = -38253701171875.0, wy = -4516580078125.0, instance = 1}
	FM.flightmasterDB[33] = {zone = "Stonetalon Mountains", place = "Thal'darah Overlook", faction = "Alliance", id = 33, wx = 2147.25, wy = 15378699951172.0, instance = 1}
	FM.flightmasterDB[37] = {zone = "Desolace", place = "Nijel's Point", faction = "Alliance", id = 37, wx = 13924000549316.0, wy = 13258199462891.0, instance = 1}
	FM.flightmasterDB[38] = {zone = "Desolace", place = "Shadowprey Village", faction = "Horde", id = 38, wx = -17676400146484.0, wy = 32638898925781.0, instance = 1}
	FM.flightmasterDB[39] = {zone = "Tanaris", place = "Gadgetzan", faction = "Alliance", id = 39, wx = -71859702148438.0, wy = -37682399902344.0, instance = 1}
	FM.flightmasterDB[40] = {zone = "Tanaris", place = "Gadgetzan", faction = "Horde", id = 40, wx = -70940297851562.0, wy = -38136899414062.0, instance = 1}
	FM.flightmasterDB[41] = {zone = "Feralas", place = "Feathermoon", faction = "Alliance", id = 41, wx = -44670400390625.0, wy = 21886398925781.0, instance = 1}
	FM.flightmasterDB[42] = {zone = "Feralas", place = "Camp Mojache", faction = "Horde", id = 42, wx = -44198598632812.0, wy = 19930999755859.0, instance = 1}
	FM.flightmasterDB[43] = {zone = "The Hinterlands", place = "Aerie Peak", faction = "Alliance", id = 43, wx = 28373999023438.0, wy = -20027600097656.0, instance = 0}
	FM.flightmasterDB[44] = {zone = "Azshara", place = "Bilgewater Harbor", faction = "Horde", id = 44, wx = 35471999511719.0, wy = -629466015625.0, instance = 1}
	FM.flightmasterDB[45] = {zone = "Blasted Lands", place = "Nethergarde Keep", faction = "Alliance", id = 45, wx = -11112299804688.0, wy = -34357399902344.0, instance = 0}
	FM.flightmasterDB[46] = {zone = "Southshore", place = "Transport", id = 46, wx = -98642999267578.0, wy = -54785998535156.0, instance = 0}
	FM.flightmasterDB[47] = {zone = "Grom'gol", place = "Transport", id = 47, wx = -1241876953125.0, wy = 23542999267578.0, instance = 0}
	FM.flightmasterDB[49] = {zone = "Moonglade", faction = "Alliance", id = 49, wx = 74584501953125.0, wy = -24872099609375.0, instance = 1}
	FM.flightmasterDB[50] = {zone = "Menethil Harbor", place = "Transport", id = 50, wx = 0.0, wy = 0.0, instance = 0}
	FM.flightmasterDB[51] = {zone = "Auberdine", place = "Transport", id = 51, wx = 0.0, wy = 0.0, instance = 0}
	FM.flightmasterDB[52] = {zone = "Winterspring", place = "Everlook", faction = "Alliance", id = 52, wx = 67967998046875.0, wy = -47423901367188.0, instance = 1}
	FM.flightmasterDB[53] = {zone = "Winterspring", place = "Everlook", faction = "Horde", id = 53, wx = 68130600585938.0, wy = -46111201171875.0, instance = 1}
	FM.flightmasterDB[54] = {zone = "Feathermoon", place = "Transport", id = 54, wx = -42038701171875.0, wy = 3284.0, instance = 1}
	FM.flightmasterDB[55] = {zone = "Dustwallow Marsh", place = "Brackenwall Village", faction = "Horde", id = 55, wx = -31473898925781.0, wy = -28421799316406.0, instance = 1}
	FM.flightmasterDB[56] = {zone = "Swamp of Sorrows", place = "Stonard", faction = "Horde", id = 56, wx = -10457.0, wy = -3279.25, instance = 0}
	FM.flightmasterDB[57] = {zone = "Teldrassil", place = "Fishing Village", id = 57, wx = 8701509765625.0, wy = 99136999511719.0, instance = 1}
	FM.flightmasterDB[58] = {zone = "Ashenvale", place = "Zoram'gar Outpost", faction = "Horde", id = 58, wx = 33518200683594.0, wy = 10523000488281.0, instance = 1}
	FM.flightmasterDB[59] = {zone = "Alterac Valley", place = "Dun Baldar", id = 59, wx = 57421002197266.0, wy = -4665000152588.0, instance = 30}
	FM.flightmasterDB[60] = {zone = "Alterac Valley", place = "Frostwolf Keep", id = 60, wx = -13354399414062.0, wy = -31969000244141.0, instance = 30}
	FM.flightmasterDB[61] = {zone = "Ashenvale", place = "Splintertree Post", faction = "Horde", id = 61, wx = 23023898925781.0, wy = -25245500488281.0, instance = 1}
	FM.flightmasterDB[62] = {zone = "Moonglade", place = "Nighthaven", faction = "Alliance", id = 62, wx = 77936098632812.0, wy = -24034699707031.0, instance = 1}
	FM.flightmasterDB[63] = {zone = "Moonglade", place = "Nighthaven", faction = "Horde", id = 63, wx = 77877202148438.0, wy = -24041000976562.0, instance = 1}
	FM.flightmasterDB[65] = {zone = "Felwood", place = "Talonbranch Glade", faction = "Alliance", id = 65, wx = 62143198242188.0, wy = -18742800292969.0, instance = 1}
	FM.flightmasterDB[66] = {zone = "Western Plaguelands", place = "Chillwind Camp", faction = "Alliance", id = 66, wx = 93132000732422.0, wy = -14301099853516.0, instance = 0}
	FM.flightmasterDB[67] = {zone = "Eastern Plaguelands", place = "Light's Hope Chapel", faction = "Alliance", id = 67, wx = 22710900878906.0, wy = -53407998046875.0, instance = 0}
	FM.flightmasterDB[68] = {zone = "Eastern Plaguelands", place = "Light's Hope Chapel", faction = "Horde", id = 68, wx = 22701999511719.0, wy = -53431098632812.0, instance = 0}
	FM.flightmasterDB[69] = {zone = "Moonglade", faction = "Horde", id = 69, wx = 74703901367188.0, wy = -21233798828125.0, instance = 1}
	FM.flightmasterDB[70] = {zone = "Burning Steppes", place = "Flame Crest", faction = "Horde", id = 70, wx = -75040297851562.0, wy = -21875400390625.0, instance = 0}
	FM.flightmasterDB[71] = {zone = "Burning Steppes", place = "Morgan's Vigil", faction = "Alliance", id = 71, wx = -83646103515625.0, wy = -27383500976562.0, instance = 0}
	FM.flightmasterDB[72] = {zone = "Silithus", place = "Cenarion Hold", faction = "Horde", id = 72, wx = -68113901367188.0, wy = 83673999023438.0, instance = 1}
	FM.flightmasterDB[73] = {zone = "Silithus", place = "Cenarion Hold", faction = "Alliance", id = 73, wx = -6761830078125.0, wy = 77203002929688.0, instance = 1}
	FM.flightmasterDB[74] = {zone = "Searing Gorge", place = "Thorium Point", faction = "Alliance", id = 74, wx = -655258984375.0, wy = -11682700195312.0, instance = 0}
	FM.flightmasterDB[75] = {zone = "Searing Gorge", place = "Thorium Point", faction = "Horde", id = 75, wx = -65549301757812.0, wy = -11000500488281.0, instance = 0}
	FM.flightmasterDB[76] = {zone = "The Hinterlands", place = "Revantusk Village", faction = "Horde", id = 76, wx = -63526000976563.0, wy = -4720.5, instance = 0}
	FM.flightmasterDB[77] = {zone = "Southern Barrens", place = "Vendetta Point", faction = "Horde", id = 77, wx = -21523500976562.0, wy = -17243399658203.0, instance = 1}
	FM.flightmasterDB[78] = {zone = "Naxxramas", id = 78, wx = 31333100585938.0, wy = -33999299316406.0, instance = 0}
	FM.flightmasterDB[79] = {zone = "Un'Goro Crater", place = "Marshal's Stand", id = 79, wx = -75480498046875.0, wy = -15411300048828.0, instance = 1}
	FM.flightmasterDB[80] = {zone = "Northern Barrens", place = "Ratchet", id = 80, wx = -89459002685547.0, wy = -37730100097656.0, instance = 1}
	FM.flightmasterDB[82] = {zone = "Silvermoon City", faction = "Horde", id = 82, wx = 9375240234375.0, wy = -71658901367188.0, instance = 530}
	FM.flightmasterDB[83] = {zone = "Ghostlands", place = "Tranquillien", faction = "Horde", id = 83, wx = 75944702148438.0, wy = -67842900390625.0, instance = 530}
	FM.flightmasterDB[84] = {zone = "Eastern Plaguelands", place = "Plaguewood Tower", id = 84, wx = 29655500488281.0, wy = -30336101074219.0, instance = 0}
	FM.flightmasterDB[85] = {zone = "Eastern Plaguelands", place = "Northpass Tower", id = 85, wx = 31342600097656.0, wy = -43547797851562.0, instance = 0}
	FM.flightmasterDB[86] = {zone = "Eastern Plaguelands", place = "Eastwall Tower", id = 86, wx = 25244399414062.0, wy = -47695600585938.0, instance = 0}
	FM.flightmasterDB[87] = {zone = "Eastern Plaguelands", place = "Crown Guard Tower", id = 87, wx = 18764000244141.0, wy = -36933200683594.0, instance = 0}
	FM.flightmasterDB[88] = {zone = "Exodar", place = "Transport", id = 88, wx = -4284009765625.0, wy = -11194740234375.0, instance = 530}
	FM.flightmasterDB[89] = {zone = "Theramore", place = "Transport", id = 89, wx = 0.0, wy = 0.0, instance = 0}
	FM.flightmasterDB[90] = {zone = "Undercity", place = "Transport", id = 90, wx = 0.0, wy = 0.0, instance = 1}
	FM.flightmasterDB[93] = {zone = "Bloodmyst Isle", place = "Blood Watch", faction = "Alliance", id = 93, wx = -19332700195312.0, wy = -11954599609375.0, instance = 530}
	FM.flightmasterDB[94] = {zone = "The Exodar", faction = "Alliance", id = 94, wx = -38675600585938.0, wy = -11641099609375.0, instance = 530}
	FM.flightmasterDB[99] = {zone = "Hellfire Peninsula", place = "Thrallmar", faction = "Horde", id = 99, wx = 228.5, wy = 26335700683594.0, instance = 530}
	FM.flightmasterDB[100] = {zone = "Hellfire Peninsula", place = "Honor Hold", faction = "Alliance", id = 100, wx = -67341998291016.0, wy = 27172700195312.0, instance = 530}
	FM.flightmasterDB[101] = {zone = "Hellfire Peninsula", place = "Temple of Telhamat", faction = "Alliance", id = 101, wx = 19916000366211.0, wy = 42415600585938.0, instance = 530}
	FM.flightmasterDB[102] = {zone = "Hellfire Peninsula", place = "Falcon Watch", faction = "Horde", id = 102, wx = -58740997314453.0, wy = 4101009765625.0, instance = 530}
	FM.flightmasterDB[117] = {zone = "Zangarmarsh", place = "Telredor", faction = "Alliance", id = 117, wx = 213.75, wy = 6063.75, instance = 530}
	FM.flightmasterDB[118] = {zone = "Zangarmarsh", place = "Zabra'jin", faction = "Horde", id = 118, wx = 21944999694824.0, wy = 7816.0, instance = 530}
	FM.flightmasterDB[119] = {zone = "Nagrand", place = "Telaar", faction = "Alliance", id = 119, wx = -2729.0, wy = 73052998046875.0, instance = 530}
	FM.flightmasterDB[120] = {zone = "Nagrand", place = "Garadar", faction = "Horde", id = 120, wx = -12610899658203.0, wy = 71333901367188.0, instance = 530}
	FM.flightmasterDB[121] = {zone = "Terokkar Forest", place = "Allerian Stronghold", faction = "Alliance", id = 121, wx = -29872399902344.0, wy = 38727800292969.0, instance = 530}
	FM.flightmasterDB[122] = {zone = "Netherstorm", place = "Area 52", id = 122, wx = 30823100585938.0, wy = 35961101074219.0, instance = 530}
	FM.flightmasterDB[123] = {zone = "Shadowmoon Valley", place = "Shadowmoon Village", faction = "Horde", id = 123, wx = -30186201171875.0, wy = 25570900878906.0, instance = 530}
	FM.flightmasterDB[124] = {zone = "Shadowmoon Valley", place = "Wildhammer Stronghold", faction = "Alliance", id = 124, wx = -39820700683594.0, wy = 21564699707031.0, instance = 530}
	FM.flightmasterDB[125] = {zone = "Blade's Edge Mountains", place = "Sylvanaar", faction = "Alliance", id = 125, wx = 21836499023438.0, wy = 67944599609375.0, instance = 530}
	FM.flightmasterDB[126] = {zone = "Blade's Edge Mountains", place = "Thunderlord Stronghold", faction = "Horde", id = 126, wx = 24463701171875.0, wy = 60209301757812.0, instance = 530}
	FM.flightmasterDB[127] = {zone = "Terokkar Forest", place = "Stonebreaker Hold", faction = "Horde", id = 127, wx = -2567330078125.0, wy = 4423830078125.0, instance = 530}
	FM.flightmasterDB[128] = {zone = "Terokkar Forest", place = "Shattrath", id = 128, wx = -18372299804688.0, wy = 53018999023438.0, instance = 530}
	FM.flightmasterDB[129] = {zone = "The Dark Portal", place = "Hellfire Peninsula", faction = "Alliance", id = 129, wx = -32735000610352.0, wy = 10204899902344.0, instance = 530}
	FM.flightmasterDB[130] = {zone = "The Dark Portal", place = "Hellfire Peninsula", faction = "Horde", id = 130, wx = -17808999633789.0, wy = 10267199707031.0, instance = 530}
	FM.flightmasterDB[139] = {zone = "Netherstorm", place = "The Stormspire", id = 139, wx = 4157580078125.0, wy = 29596899414062.0, instance = 530}
	FM.flightmasterDB[140] = {zone = "Shadowmoon Valley", place = "Altar of Sha'tar", id = 140, wx = -30656000976562.0, wy = 74941998291016.0, instance = 530}
	FM.flightmasterDB[141] = {zone = "Hellfire Peninsula", place = "Spinebreaker Ridge", faction = "Horde", id = 141, wx = -13168399658203.0, wy = 23586201171875.0, instance = 530}
	FM.flightmasterDB[142] = {zone = "Hellfire Peninsula - Reaver's Fall", id = 142, wx = -2915999984741.0, wy = 21257199707031.0, instance = 530}
	FM.flightmasterDB[147] = {zone = "Hellfire Peninsula - Force Camp Beach Head", id = 147, wx = 50917001342773.0, wy = 19886899414062.0, instance = 530}
	FM.flightmasterDB[148] = {zone = "Hellfire Peninsula (Beach Assault)", place = "Shatter Point", id = 148, wx = 29845999145508.0, wy = 15011800537109.0, instance = 530}
	FM.flightmasterDB[149] = {zone = "Hellfire Peninsula", place = "Shatter Point", id = 149, wx = 27620001220703.0, wy = 14869100341797.0, instance = 530}
	FM.flightmasterDB[150] = {zone = "Netherstorm", place = "Cosmowrench", id = 150, wx = 29749499511719.0, wy = 18482399902344.0, instance = 530}
	FM.flightmasterDB[151] = {zone = "Zangarmarsh", place = "Swamprat Post", faction = "Horde", id = 151, wx = 9166999816895.0, wy = 5214919921875.0, instance = 530}
	FM.flightmasterDB[156] = {zone = "Blade's Edge Mountains", place = "Toshley's Station", faction = "Alliance", id = 156, wx = 18573499755859.0, wy = 55318701171875.0, instance = 530}
	FM.flightmasterDB[159] = {zone = "Shadowmoon Valley", place = "Sanctum of the Stars", id = 159, wx = -4073169921875.0, wy = 11236099853516.0, instance = 530}
	FM.flightmasterDB[160] = {zone = "Blade's Edge Mountains", place = "Evergrove", id = 160, wx = 29760100097656.0, wy = 55011298828125.0, instance = 530}
	FM.flightmasterDB[163] = {zone = "Blade's Edge Mountains", place = "Mok'Nathal Village", faction = "Horde", id = 163, wx = 20287900390625.0, wy = 47052700195312.0, instance = 530}
	FM.flightmasterDB[164] = {zone = "Zangarmarsh", place = "Orebor Harborage", faction = "Alliance", id = 164, wx = 96666998291016.0, wy = 739916015625.0, instance = 530}
	FM.flightmasterDB[166] = {zone = "Felwood", place = "Emerald Sanctuary", id = 166, wx = 39728400878906.0, wy = -13245100097656.0, instance = 1}
	FM.flightmasterDB[167] = {zone = "Ashenvale", place = "Forest Song", faction = "Alliance", id = 167, wx = 3000.25, wy = -32024099121094.0, instance = 1}
	FM.flightmasterDB[171] = {zone = "Skettis", id = 171, wx = -33646799316406.0, wy = 36501799316406.0, instance = 530}
	FM.flightmasterDB[172] = {zone = "Ogri'La", id = 172, wx = 25311000976562.0, wy = 732208984375.0, instance = 530}
	FM.flightmasterDB[179] = {zone = "Dustwallow Marsh", place = "Mudsprocket", id = 179, wx = -45662299804688.0, wy = -32260500488281.0, instance = 1}
	FM.flightmasterDB[183] = {zone = "Howling Fjord", place = "Valgarde Port", faction = "Alliance", id = 183, wx = 56740997314453.0, wy = -50109702148438.0, instance = 571}
	FM.flightmasterDB[184] = {zone = "Howling Fjord", place = "Fort Wildervar", faction = "Alliance", id = 184, wx = 24687700195312.0, wy = -50298198242188.0, instance = 571}
	FM.flightmasterDB[185] = {zone = "Howling Fjord", place = "Westguard Keep", faction = "Alliance", id = 185, wx = 13428399658203.0, wy = -32878999023438.0, instance = 571}
	FM.flightmasterDB[190] = {zone = "Howling Fjord", place = "New Agamand", faction = "Horde", id = 190, wx = 40111999511719.0, wy = -45442998046875.0, instance = 571}
	FM.flightmasterDB[191] = {zone = "Howling Fjord", place = "Vengeance Landing", faction = "Horde", id = 191, wx = 19185999755859.0, wy = -61758901367188.0, instance = 571}
	FM.flightmasterDB[192] = {zone = "Howling Fjord", place = "Camp Winterhoof", faction = "Horde", id = 192, wx = 26528898925781.0, wy = -43927099609375.0, instance = 571}
	FM.flightmasterDB[195] = {zone = "Stranglethorn Vale", place = "Rebel Camp", faction = "Alliance", id = 195, wx = -11344.0, wy = -21683000183106.0, instance = 0}
	FM.flightmasterDB[205] = {zone = "Ghostlands", place = "Zul'Aman", id = 205, wx = 67897900390625.0, wy = -7747580078125.0, instance = 530}
	FM.flightmasterDB[222] = {zone = "Borean", place = "Beryl Point", id = 222, wx = 32137399902344.0, wy = 60847202148438.0, instance = 571}
	FM.flightmasterDB[224] = {zone = "Naglevar", place = "Borean Tundra", id = 224, wx = 0.0, wy = 0.0, instance = 0}
	FM.flightmasterDB[226] = {zone = "Coldarra", place = "Transitus Shield", id = 226, wx = 35754399414062.0, wy = 66616401367188.0, instance = 571}
	FM.flightmasterDB[234] = {zone = "Coldarra", place = "Coldarra Ledge", id = 234, wx = 41306201171875.0, wy = 73723100585938.0, instance = 571}
	FM.flightmasterDB[244] = {zone = "Dragonblight", place = "Wintergarde Keep", faction = "Alliance", id = 244, wx = 37124299316406.0, wy = -69485998535156.0, instance = 571}
	FM.flightmasterDB[245] = {zone = "Borean Tundra", place = "Valiance Keep", faction = "Alliance", id = 245, wx = 22695400390625.0, wy = 51736899414062.0, instance = 571}
	FM.flightmasterDB[246] = {zone = "Borean Tundra", place = "Fizzcrank Airstrip", faction = "Alliance", id = 246, wx = 41272299804688.0, wy = 53130698242188.0, instance = 571}
	FM.flightmasterDB[247] = {zone = "Dragonblight", place = "Stars' Rest", faction = "Alliance", id = 247, wx = 35041298828125.0, wy = 19920300292969.0, instance = 571}
	FM.flightmasterDB[248] = {zone = "Howling Fjord", place = "Apothecary Camp", faction = "Horde", id = 248, wx = 21081101074219.0, wy = -29706201171875.0, instance = 571}
	FM.flightmasterDB[249] = {zone = "Grizzly Hills", place = "Camp Oneqwah", faction = "Horde", id = 249, wx = 38763400878906.0, wy = -4520080078125.0, instance = 571}
	FM.flightmasterDB[250] = {zone = "Grizzly Hills", place = "Conquest Hold", faction = "Horde", id = 250, wx = 32588999023438.0, wy = -22630900878906.0, instance = 571}
	FM.flightmasterDB[251] = {zone = "Dragonblight", place = "Fordragon Hold", faction = "Alliance", id = 251, wx = 46122099609375.0, wy = 14065999755859.0, instance = 571}
	FM.flightmasterDB[252] = {zone = "Dragonblight", place = "Wyrmrest Temple", id = 252, wx = 36532099609375.0, wy = 24758000183106.0, instance = 571}
	FM.flightmasterDB[253] = {zone = "Grizzly Hills", place = "Amberpine Lodge", faction = "Alliance", id = 253, wx = 34463500976562.0, wy = -27541000976562.0, instance = 571}
	FM.flightmasterDB[254] = {zone = "Dragonblight", place = "Venomspite", faction = "Horde", id = 254, wx = 32429599609375.0, wy = -66615997314453.0, instance = 571}
	FM.flightmasterDB[255] = {zone = "Grizzly Hills", place = "Westfall Brigade", faction = "Alliance", id = 255, wx = 45849799804688.0, wy = -42546899414062.0, instance = 571}
	FM.flightmasterDB[256] = {zone = "Dragonblight", place = "Agmar's Hammer", faction = "Horde", id = 256, wx = 38658701171875.0, wy = 15256300048828.0, instance = 571}
	FM.flightmasterDB[257] = {zone = "Borean Tundra", place = "Warsong Hold", faction = "Horde", id = 257, wx = 29202900390625.0, wy = 62428500976562.0, instance = 571}
	FM.flightmasterDB[258] = {zone = "Borean Tundra", place = "Taunka'le Village", faction = "Horde", id = 258, wx = 34495100097656.0, wy = 40895200195312.0, instance = 571}
	FM.flightmasterDB[259] = {zone = "Borean Tundra", place = "Bor'gorok Outpost", faction = "Horde", id = 259, wx = 44747900390625.0, wy = 57121298828125.0, instance = 571}
	FM.flightmasterDB[260] = {zone = "Dragonblight", place = "Kor'kron Vanguard", faction = "Horde", id = 260, wx = 4946669921875.0, wy = 11659399414062.0, instance = 571}
	FM.flightmasterDB[289] = {zone = "Borean Tundra", place = "Amber Ledge", id = 289, wx = 35878400878906.0, wy = 59732998046875.0, instance = 571}
	FM.flightmasterDB[290] = {zone = "Zul'Drak", place = "Argent Stand", id = 290, wx = 54502998046875.0, wy = -26062700195312.0, instance = 571}
	FM.flightmasterDB[294] = {zone = "Dragonblight", place = "Moa'ki", id = 294, wx = 27924499511719.0, wy = 90896002197266.0, instance = 571}
	FM.flightmasterDB[295] = {zone = "Howling Fjord", place = "Kamagua", id = 295, wx = 78527001953125.0, wy = -28877099609375.0, instance = 571}
	FM.flightmasterDB[296] = {zone = "Borean Tundra", place = "Unu'pe", id = 296, wx = 29191899414062.0, wy = 40460900878906.0, instance = 571}
	FM.flightmasterDB[303] = {zone = "Wintergrasp", place = "Valiance Landing Camp", faction = "Alliance", id = 303, wx = 51008100585938.0, wy = 21856499023438.0, instance = 571}
	FM.flightmasterDB[304] = {zone = "Zul'Drak", place = "The Argent Stand", id = 304, wx = 55216298828125.0, wy = -2672.25, instance = 571}
	FM.flightmasterDB[305] = {zone = "Zul'Drak", place = "Ebon Watch", id = 305, wx = 52188999023438.0, wy = -13022199707031.0, instance = 571}
	FM.flightmasterDB[306] = {zone = "Zul'Drak", place = "Light's Breach", id = 306, wx = 51901098632812.0, wy = -22064599609375.0, instance = 571}
	FM.flightmasterDB[307] = {zone = "Zul'Drak", place = "Zim'Torga", id = 307, wx = 57773999023438.0, wy = -35949399414062.0, instance = 571}
	FM.flightmasterDB[308] = {zone = "Sholazar Basin", place = "River's Heart", id = 308, wx = 55062299804688.0, wy = 47481000976562.0, instance = 571}
	FM.flightmasterDB[309] = {zone = "Sholazar Basin", place = "Nesingwary Base Camp", id = 309, wx = 55961000976562.0, wy = 58243701171875.0, instance = 571}
	FM.flightmasterDB[310] = {zone = "Dalaran", id = 310, wx = 58138901367188.0, wy = 44913000488281.0, instance = 571}
	FM.flightmasterDB[315] = {zone = "Acherus: The Ebon Hold", id = 315, wx = 23523701171875.0, wy = -566691015625.0, instance = 0}
	FM.flightmasterDB[320] = {zone = "The Storm Peaks", place = "K3", id = 320, wx = 6186.75, wy = -10529100341797.0, instance = 571}
	FM.flightmasterDB[321] = {zone = "The Storm Peaks", place = "Frosthold", faction = "Alliance", id = 321, wx = 66670400390625.0, wy = -25870001220703.0, instance = 571}
	FM.flightmasterDB[322] = {zone = "The Storm Peaks", place = "Dun Niffelem", id = 322, wx = 73080400390625.0, wy = -26076000976562.0, instance = 571}
	FM.flightmasterDB[323] = {zone = "The Storm Peaks", place = "Grom'arsh Crash-Site", faction = "Horde", id = 323, wx = 78572998046875.0, wy = -73502001953125.0, instance = 571}
	FM.flightmasterDB[324] = {zone = "The Storm Peaks", place = "Camp Tunka'lo", faction = "Horde", id = 324, wx = 77938500976562.0, wy = -28100900878906.0, instance = 571}
	FM.flightmasterDB[325] = {zone = "Icecrown", place = "Death's Rise", id = 325, wx = 74273198242188.0, wy = 422416015625.0, instance = 571}
	FM.flightmasterDB[326] = {zone = "The Storm Peaks", place = "Ulduar", id = 326, wx = 8864740234375.0, wy = -13243299560547.0, instance = 571}
	FM.flightmasterDB[327] = {zone = "The Storm Peaks", place = "Bouldercrag's Refuge", id = 327, wx = 84724599609375.0, wy = -33595001220703.0, instance = 571}
	FM.flightmasterDB[331] = {zone = "Zul'Drak", place = "Gundrak", id = 331, wx = 68976499023438.0, wy = -41182299804688.0, instance = 571}
	FM.flightmasterDB[332] = {zone = "Wintergrasp", place = "Warsong Camp", faction = "Horde", id = 332, wx = 5024990234375.0, wy = 36855500488281.0, instance = 571}
	FM.flightmasterDB[333] = {zone = "Icecrown", place = "The Shadow Vault", id = 333, wx = 840808984375.0, wy = 27026599121094.0, instance = 571}
	FM.flightmasterDB[334] = {zone = "Icecrown", place = "The Argent Vanguard", id = 334, wx = 6164490234375.0, wy = -6131000137329.0, instance = 571}
	FM.flightmasterDB[335] = {zone = "Icecrown", place = "Crusaders' Pinnacle", id = 335, wx = 64020600585938.0, wy = 46785998535156.0, instance = 571}
	FM.flightmasterDB[336] = {zone = "Crystalsong Forest", place = "Windrunner's Overlook", faction = "Alliance", id = 336, wx = 50356499023438.0, wy = -51996002197266.0, instance = 571}
	FM.flightmasterDB[337] = {zone = "Crystalsong Forest", place = "Sunreaver's Command", faction = "Horde", id = 337, wx = 5590490234375.0, wy = -69322998046875.0, instance = 571}
	FM.flightmasterDB[338] = {zone = "Ashenvale", place = "Blackfathom Camp", faction = "Alliance", id = 338, wx = 38805100097656.0, wy = 65415997314453.0, instance = 1}
	FM.flightmasterDB[339] = {zone = "Darkshore", place = "Grove of the Ancients", faction = "Alliance", id = 339, wx = 4970.5, wy = 14764999389648.0, instance = 1}
	FM.flightmasterDB[340] = {zone = "Icecrown", place = "Argent Tournament Grounds", id = 340, wx = 84757900390625.0, wy = 89120001220703.0, instance = 571}
	FM.flightmasterDB[343] = {zone = "Ashenvale", place = "Splintertree", id = 343, wx = 23092299804688.0, wy = -25232099609375.0, instance = 1}
	FM.flightmasterDB[349] = {zone = "Zoram'gar", place = "Andruk", id = 349, wx = 33502099609375.0, wy = 10541199951172.0, instance = 1}
	FM.flightmasterDB[350] = {zone = "Ashenvale", place = "Hellscream's Watch", faction = "Horde", id = 350, wx = 3049080078125.0, wy = -49895001220703.0, instance = 1}
	FM.flightmasterDB[351] = {zone = "Ashenvale", place = "Stardust Spire", faction = "Alliance", id = 351, wx = 19051099853516.0, wy = -32198999023438.0, instance = 1}
	FM.flightmasterDB[354] = {zone = "Ashenvale", place = "The Mor'Shan Ramparts", faction = "Horde", id = 354, wx = 12060500488281.0, wy = -22091499023438.0, instance = 1}
	FM.flightmasterDB[356] = {zone = "Ashenvale", place = "Silverwind Refuge", faction = "Horde", id = 356, wx = 21596201171875.0, wy = -11440500488281.0, instance = 1}
	FM.flightmasterDB[360] = {zone = "Stonetalon Mountains", place = "Cliffwalker Post", faction = "Horde", id = 360, wx = 2188.0, wy = 12418900146484.0, instance = 1}
	FM.flightmasterDB[361] = {zone = "Stonetalon Mountains", place = "Windshear Hold", faction = "Alliance", id = 361, wx = 12685100097656.0, wy = 43286999511719.0, instance = 1}
	FM.flightmasterDB[362] = {zone = "Stonetalon Mountains", place = "Krom'gar Fortress", faction = "Horde", id = 362, wx = 93211999511719.0, wy = -21.25, instance = 1}
	FM.flightmasterDB[363] = {zone = "Stonetalon Mountains", place = "Malaka'jin", faction = "Horde", id = 363, wx = -11194000244141.0, wy = -26041000366211.0, instance = 1}
	FM.flightmasterDB[364] = {zone = "Stonetalon Mountains", place = "Northwatch Expedition Base Camp", faction = "Alliance", id = 364, wx = 23788000488281.0, wy = -28135000610352.0, instance = 1}
	FM.flightmasterDB[365] = {zone = "Stonetalon Mountains", place = "Farwatcher's Glen", faction = "Alliance", id = 365, wx = 97394000244141.0, wy = 20131300048828.0, instance = 1}
	FM.flightmasterDB[366] = {zone = "Desolace", place = "Furien's Post", faction = "Horde", id = 366, wx = -43914999389648.0, wy = 22426201171875.0, instance = 1}
	FM.flightmasterDB[367] = {zone = "Desolace", place = "Thargad's Camp", faction = "Alliance", id = 367, wx = -16945300292969.0, wy = 25775700683594.0, instance = 1}
	FM.flightmasterDB[368] = {zone = "Desolace", place = "Karnum's Glade", id = 368, wx = -10384300537109.0, wy = 16379899902344.0, instance = 1}
	FM.flightmasterDB[369] = {zone = "Desolace", place = "Thunk's Abode", id = 369, wx = -53403997802734.0, wy = 10566800537109.0, instance = 1}
	FM.flightmasterDB[370] = {zone = "Desolace", place = "Ethel Rethor", id = 370, wx = -3564700012207.0, wy = 24788999023438.0, instance = 1}
	FM.flightmasterDB[383] = {zone = "Eastern Plaguelands", place = "Thondroril River", id = 383, wx = 19359699707031.0, wy = -26944799804688.0, instance = 0}
	FM.flightmasterDB[384] = {zone = "Tirisfal", place = "The Bulwark", faction = "Horde", id = 384, wx = 17266199951172.0, wy = -74098101806641.0, instance = 0}
	FM.flightmasterDB[386] = {zone = "Un'Goro Crater", place = "Mossy Pile", id = 386, wx = -69584399414062.0, wy = -10952399902344.0, instance = 1}
	FM.flightmasterDB[387] = {zone = "Southern Barrens", place = "Honor's Stand", faction = "Alliance", id = 387, wx = -33520001220703.0, wy = -15324399414062.0, instance = 1}
	FM.flightmasterDB[388] = {zone = "Southern Barrens", place = "Northwatch Hold", faction = "Alliance", id = 388, wx = -21242099609375.0, wy = -35617900390625.0, instance = 1}
	FM.flightmasterDB[389] = {zone = "Southern Barrens", place = "Fort Triumph", faction = "Alliance", id = 389, wx = -3150.25, wy = -22862700195312.0, instance = 1}
	FM.flightmasterDB[390] = {zone = "Southern Barrens", place = "Hunter's Hill", faction = "Horde", id = 390, wx = -79871997070313.0, wy = -15908699951172.0, instance = 1}
	FM.flightmasterDB[391] = {zone = "Southern Barrens", place = "Desolation Hold", faction = "Horde", id = 391, wx = -32888500976562.0, wy = -16979899902344.0, instance = 1}
	FM.flightmasterDB[402] = {zone = "Mulgore", place = "Bloodhoof Village", faction = "Horde", id = 402, wx = -22995400390625.0, wy = -37906900024414.0, instance = 1}
	FM.flightmasterDB[456] = {zone = "Teldrassil", place = "Dolanaar", faction = "Alliance", id = 456, wx = 9873099609375.0, wy = 97769799804688.0, instance = 1}
	FM.flightmasterDB[457] = {zone = "Teldrassil", place = "Darnassus", faction = "Alliance", id = 457, wx = 99687998046875.0, wy = 26220900878906.0, instance = 1}
	FM.flightmasterDB[458] = {zone = "Northern Barrens", place = "Nozzlepot's Outpost", faction = "Horde", id = 458, wx = 11525999755859.0, wy = -33817399902344.0, instance = 1}
	FM.flightmasterDB[460] = {zone = "Tirisfal Glades", place = "Brill", faction = "Horde", id = 460, wx = 22726799316406.0, wy = 37206399536133.0, instance = 0}
	FM.flightmasterDB[513] = {zone = "Thousand Needles", place = "Fizzle & Pozzik's Speedbarge", id = 513, wx = -60753701171875.0, wy = -39134399414062.0, instance = 1}
	FM.flightmasterDB[521] = {zone = "Vashj'ir", place = "Smuggler's Scar", id = 521, wx = -45880498046875.0, wy = 34811201171875.0, instance = 0}
	FM.flightmasterDB[522] = {zone = "Vashj'ir", place = "Silver Tide Hollow", id = 522, wx = -61056098632812.0, wy = 4285080078125.0, instance = 0}
	FM.flightmasterDB[523] = {zone = "Vashj'ir", place = "Tranquil Wash", faction = "Alliance", id = 523, wx = -66163999023438.0, wy = 43082797851562.0, instance = 0}
	FM.flightmasterDB[524] = {zone = "Vashj'ir", place = "Darkbreak Cove", faction = "Alliance", id = 524, wx = -6902.25, wy = 59438198242188.0, instance = 0}
	FM.flightmasterDB[525] = {zone = "Vashj'ir", place = "Legion's Rest", faction = "Horde", id = 525, wx = -68056298828125.0, wy = 41998500976562.0, instance = 0}
	FM.flightmasterDB[526] = {zone = "Vashj'ir", place = "Tenebrous Cavern", faction = "Horde", id = 526, wx = -6507990234375.0, wy = 6075.25, instance = 0}
	FM.flightmasterDB[531] = {zone = "Tanaris", place = "Dawnrise Expedition", faction = "Horde", id = 531, wx = -94878896484375.0, wy = -24671298828125.0, instance = 1}
	FM.flightmasterDB[532] = {zone = "Tanaris", place = "Gunstan's Dig", faction = "Alliance", id = 532, wx = -94937099609375.0, wy = -29539899902344.0, instance = 1}
	FM.flightmasterDB[536] = {zone = "Durotar", place = "Sen'jin Village", faction = "Horde", id = 536, wx = -78026702880859.0, wy = -48902797851562.0, instance = 1}
	FM.flightmasterDB[537] = {zone = "Durotar", place = "Razor Hill", faction = "Horde", id = 537, wx = 2699169921875.0, wy = -4766759765625.0, instance = 1}
	FM.flightmasterDB[539] = {zone = "Tanaris", place = "Bootlegger Outpost", id = 539, wx = -868308984375.0, wy = -40881000976562.0, instance = 1}
	FM.flightmasterDB[540] = {zone = "Stonetalon Mountains", place = "The Sludgewerks", faction = "Horde", id = 540, wx = 18259399414062.0, wy = 7272080078125.0, instance = 1}
	FM.flightmasterDB[541] = {zone = "Stonetalon Mountains", place = "Mirkfallon Post", faction = "Alliance", id = 541, wx = 13794200439453.0, wy = 10348599853516.0, instance = 1}
	FM.flightmasterDB[551] = {zone = "Wetlands", place = "Whelgar's Retreat", faction = "Alliance", id = 551, wx = -32229299316406.0, wy = -19894899902344.0, instance = 0}
	FM.flightmasterDB[552] = {zone = "Wetlands", place = "Greenwarden's Grove", faction = "Alliance", id = 552, wx = -33066499023438.0, wy = -27186899414062.0, instance = 0}
	FM.flightmasterDB[553] = {zone = "Wetlands", place = "Dun Modr", faction = "Alliance", id = 553, wx = -26565400390625.0, wy = -24642800292969.0, instance = 0}
	FM.flightmasterDB[554] = {zone = "Wetlands", place = "Slabchisel's Survey", faction = "Alliance", id = 554, wx = -41136000976562.0, wy = -27412099609375.0, instance = 0}
	FM.flightmasterDB[555] = {zone = "Loch Modan", place = "Farstrider Lodge", faction = "Alliance", id = 555, wx = -56683100585938.0, wy = -42534399414062.0, instance = 0}
	FM.flightmasterDB[557] = {zone = "Hyjal", place = "Shrine of Aviana", id = 557, wx = 49878701171875.0, wy = -26761899414062.0, instance = 1}
	FM.flightmasterDB[558] = {zone = "Hyjal", place = "Grove of Aessina", id = 558, wx = 5163509765625.0, wy = -17605799560547.0, instance = 1}
	FM.flightmasterDB[559] = {zone = "Hyjal", place = "Nordrassil", id = 559, wx = 55840600585938.0, wy = -35698400878906.0, instance = 1}
	FM.flightmasterDB[565] = {zone = "Feralas", place = "Dreamer's Rest", faction = "Alliance", id = 565, wx = -31366201171875.0, wy = 19516700439453.0, instance = 1}
	FM.flightmasterDB[567] = {zone = "Feralas", place = "Tower of Estulan", faction = "Alliance", id = 567, wx = -48636401367188.0, wy = 14781600341797.0, instance = 1}
	FM.flightmasterDB[568] = {zone = "Feralas", place = "Camp Ataya", faction = "Horde", id = 568, wx = -30816999511719.0, wy = 25601000976562.0, instance = 1}
	FM.flightmasterDB[569] = {zone = "Feralas", place = "Stonemaul Hold", faction = "Horde", id = 569, wx = -46065200195312.0, wy = 18981899414062.0, instance = 1}
	FM.flightmasterDB[582] = {zone = "Elwynn", place = "Goldshire", faction = "Alliance", id = 582, wx = -9433990234375.0, wy = 8514929962158.0, instance = 0}
	FM.flightmasterDB[583] = {zone = "Westfall", place = "Moonbrook", faction = "Alliance", id = 583, wx = -10876900390625.0, wy = 15428800048828.0, instance = 0}
	FM.flightmasterDB[584] = {zone = "Westfall", place = "Furlbrow's Pumpkin Farm", faction = "Alliance", id = 584, wx = -9838509765625.0, wy = 12739300537109.0, instance = 0}
	FM.flightmasterDB[589] = {zone = "Elwynn", place = "Eastvale Logging Camp", faction = "Alliance", id = 589, wx = -94757099609375.0, wy = -13067399902344.0, instance = 0}
	FM.flightmasterDB[590] = {zone = "Stranglethorn", place = "Fort Livingston", faction = "Alliance", id = 590, wx = -12828799804688.0, wy = -41370999145508.0, instance = 0}
	FM.flightmasterDB[591] = {zone = "Stranglethorn", place = "Explorers' League Digsite", faction = "Alliance", id = 591, wx = -13600900390625.0, wy = -8554859924316.0, instance = 0}
	FM.flightmasterDB[592] = {zone = "Stranglethorn", place = "Hardwrench Hideaway", faction = "Horde", id = 592, wx = -13288299804688.0, wy = 72202801513672.0, instance = 0}
	FM.flightmasterDB[593] = {zone = "Stranglethorn", place = "Bambala", faction = "Horde", id = 593, wx = -12092200195312.0, wy = -81409899902344.0, instance = 0}
	FM.flightmasterDB[594] = {zone = "Felwood", place = "Whisperwind Grove", id = 594, wx = 6078509765625.0, wy = -84499798583984.0, instance = 1}
	FM.flightmasterDB[595] = {zone = "Felwood", place = "Wildheart Point", id = 595, wx = 473416015625.0, wy = -88380603027344.0, instance = 1}
	FM.flightmasterDB[596] = {zone = "Redridge", place = "Shalewind Canyon", faction = "Alliance", id = 596, wx = -9641669921875.0, wy = -34793701171875.0, instance = 0}
	FM.flightmasterDB[597] = {zone = "Felwood", place = "Irontree Clearing", faction = "Horde", id = 597, wx = 68926899414062.0, wy = -16204100341797.0, instance = 1}
	FM.flightmasterDB[598] = {zone = "Swamp of Sorrows", place = "Marshtide Watch", faction = "Alliance", id = 598, wx = -10176599609375.0, wy = -38365400390625.0, instance = 0}
	FM.flightmasterDB[599] = {zone = "Swamp of Sorrows", place = "Bogpaddle", id = 599, wx = -9737080078125.0, wy = -38907199707031.0, instance = 0}
	FM.flightmasterDB[600] = {zone = "Swamp of Sorrows", place = "The Harborage", faction = "Alliance", id = 600, wx = -10118599609375.0, wy = -28524799804688.0, instance = 0}
	FM.flightmasterDB[601] = {zone = "Arathi", place = "Galen's Fall", faction = "Horde", id = 601, wx = -95237701416016.0, wy = -15857399902344.0, instance = 0}
	FM.flightmasterDB[602] = {zone = "Blasted Lands", place = "Surwich", faction = "Alliance", id = 602, wx = -12761900390625.0, wy = -29190400390625.0, instance = 0}
	FM.flightmasterDB[603] = {zone = "Blasted Lands", place = "Sunveil Excursion", faction = "Horde", id = 603, wx = -12357599609375.0, wy = -30582299804688.0, instance = 0}
	FM.flightmasterDB[604] = {zone = "Blasted Lands", place = "Dreadmaul Hold", faction = "Horde", id = 604, wx = -10933299804688.0, wy = -27909799804688.0, instance = 0}
	FM.flightmasterDB[605] = {zone = "Vashj'ir", place = "Voldrin's Hold", faction = "Alliance", id = 605, wx = -72097099609375.0, wy = 39258500976562.0, instance = 0}
	FM.flightmasterDB[606] = {zone = "Vashj'ir", place = "Sandy Beach", faction = "Alliance", id = 606, wx = -53108500976562.0, wy = 3914419921875.0, instance = 0}
	FM.flightmasterDB[607] = {zone = "Vashj'ir", place = "Sandy Beach", faction = "Alliance", id = 607, wx = -52673500976562.0, wy = 39002700195312.0, instance = 0}
	FM.flightmasterDB[608] = {zone = "Vashj'ir", place = "Sandy Beach", faction = "Horde", id = 608, wx = -56710200195312.0, wy = 37200700683594.0, instance = 0}
	FM.flightmasterDB[609] = {zone = "Vashj'ir", place = "Sandy Beach", faction = "Horde", id = 609, wx = -56691899414062.0, wy = 37118100585938.0, instance = 0}
	FM.flightmasterDB[610] = {zone = "Vashj'ir", place = "Stygian Bounty", faction = "Horde", id = 610, wx = -68785200195312.0, wy = 42447099609375.0, instance = 0}
	FM.flightmasterDB[611] = {zone = "Vashj'ir", place = "Voldrin's Hold", faction = "Alliance", id = 611, wx = -71989702148438.0, wy = 39123601074219.0, instance = 0}
	FM.flightmasterDB[612] = {zone = "Vashj'ir", place = "Stygian Bounty", faction = "Horde", id = 612, wx = -6880169921875.0, wy = 42780600585938.0, instance = 0}
	FM.flightmasterDB[613] = {zone = "Azshara", place = "Southern Rocketway", faction = "Horde", id = 613, wx = 26477900390625.0, wy = -62143999023438.0, instance = 1}
	FM.flightmasterDB[614] = {zone = "Azshara", place = "Northern Rocketway", faction = "Horde", id = 614, wx = 46113798828125.0, wy = -70417998046875.0, instance = 1}
	FM.flightmasterDB[615] = {zone = "Redridge", place = "Camp Everstill", faction = "Alliance", id = 615, wx = -94466396484375.0, wy = -28369899902344.0, instance = 0}
	FM.flightmasterDB[616] = {zone = "Hyjal", place = "Gates of Sothann", id = 616, wx = 40593999023438.0, wy = -3966.75, instance = 1}
	FM.flightmasterDB[617] = {zone = "The Hinterlands", place = "Hiri'watha Research Station", faction = "Horde", id = 617, wx = -2577599906921.0, wy = -28217800292969.0, instance = 0}
	FM.flightmasterDB[618] = {zone = "The Hinterlands", place = "Stormfeather Outpost", faction = "Alliance", id = 618, wx = 31232598876953.0, wy = -41053598632812.0, instance = 0}
	FM.flightmasterDB[619] = {zone = "Dun Morogh", place = "Kharanos", faction = "Alliance", id = 619, wx = -56607998046875.0, wy = -49485101318359.0, instance = 0}
	FM.flightmasterDB[620] = {zone = "Dun Morogh", place = "Gol'Bolar Quarry", faction = "Alliance", id = 620, wx = -57141401367188.0, wy = -15786400146484.0, instance = 0}
	FM.flightmasterDB[622] = {zone = "Duskwood", place = "Raven Hill", faction = "Alliance", id = 622, wx = -10737599609375.0, wy = 26704299926758.0, instance = 0}
	FM.flightmasterDB[624] = {zone = "Azuremyst Isle", place = "Azure Watch", faction = "Alliance", id = 624, wx = -4130080078125.0, wy = -12520.5, instance = 530}
	FM.flightmasterDB[625] = {zone = "Eversong Woods", place = "Fairbreeze Village", faction = "Horde", id = 625, wx = 87457802734375.0, wy = -66541201171875.0, instance = 530}
	FM.flightmasterDB[630] = {zone = "Eastern Plaguelands", place = "Light's Shield Tower", id = 630, wx = 22621000976562.0, wy = -44115200195312.0, instance = 0}
	FM.flightmasterDB[631] = {zone = "Eversong Woods", place = "Falconwing Square", faction = "Horde", id = 631, wx = 95019296875.0, wy = -676708984375.0, instance = 530}
	FM.flightmasterDB[632] = {zone = "Badlands", place = "Bloodwatcher Point", faction = "Horde", id = 632, wx = -6898.25, wy = -35139899902344.0, instance = 0}
	FM.flightmasterDB[633] = {zone = "Badlands", place = "Dustwind Dig", faction = "Alliance", id = 633, wx = -659408984375.0, wy = -34011799316406.0, instance = 0}
	FM.flightmasterDB[634] = {zone = "Badlands", place = "Dragon's Mouth", faction = "Alliance", id = 634, wx = -70345297851562.0, wy = -25707900390625.0, instance = 0}
	FM.flightmasterDB[635] = {zone = "Badlands", place = "Fuselight", id = 635, wx = -65749399414062.0, wy = -38751298828125.0, instance = 0}
	FM.flightmasterDB[645] = {zone = "Silverpine Forest", place = "Forsaken High Command", faction = "Horde", id = 645, wx = 14210200195312.0, wy = 10182299804688.0, instance = 0}
	FM.flightmasterDB[646] = {zone = "Gilneas", place = "Forsaken Forward Command", faction = "Horde", id = 646, wx = -91022100830078.0, wy = 16385999755859.0, instance = 0}
	FM.flightmasterDB[649] = {zone = "Western Plaguelands", place = "Andorhal", faction = "Horde", id = 649, wx = 15118000488281.0, wy = -15869499511719.0, instance = 0}
	FM.flightmasterDB[650] = {zone = "Western Plaguelands", place = "Andorhal", faction = "Alliance", id = 650, wx = 13742299804688.0, wy = -12819399414062.0, instance = 0}
	FM.flightmasterDB[651] = {zone = "Western Plaguelands", place = "The Menders' Stead", id = 651, wx = 18643199462891.0, wy = -17558199462891.0, instance = 0}
	FM.flightmasterDB[652] = {zone = "Uldum", place = "Ramkahen", id = 652, wx = -941501953125.0, wy = -10429699707031.0, instance = 1}
	FM.flightmasterDB[653] = {zone = "Uldum", place = "Oasis of Vir'sar", id = 653, wx = -83754697265625.0, wy = 79125897216797.0, instance = 1}
	FM.flightmasterDB[654] = {zone = "Silverpine Forest", place = "The Forsaken Front", faction = "Horde", id = 654, wx = -11414199829102.0, wy = 13123199462891.0, instance = 0}
	FM.flightmasterDB[656] = {zone = "Twilight Highlands", place = "Crushblow", faction = "Horde", id = 656, wx = -4831759765625.0, wy = -48489301757812.0, instance = 0}
	FM.flightmasterDB[657] = {zone = "Twilight Highlands", place = "The Gullet", faction = "Horde", id = 657, wx = -34946298828125.0, wy = -43794799804688.0, instance = 0}
	FM.flightmasterDB[658] = {zone = "Twilight Highlands", place = "Vermillion Redoubt", id = 658, wx = -30327600097656.0, wy = -39409699707031.0, instance = 0}
	FM.flightmasterDB[659] = {zone = "Twilight Highlands", place = "Bloodgulch", faction = "Horde", id = 659, wx = -36375600585938.0, wy = -52881899414062.0, instance = 0}
	FM.flightmasterDB[660] = {zone = "Twilight Highlands", place = "The Krazzworks", faction = "Horde", id = 660, wx = -27801799316406.0, wy = -64092797851562.0, instance = 0}
	FM.flightmasterDB[661] = {zone = "Twilight Highlands", place = "Dragonmaw Port", faction = "Horde", id = 661, wx = -40124499511719.0, wy = -6329.25, instance = 0}
	FM.flightmasterDB[662] = {zone = "Twilight Highlands", place = "Highbank", faction = "Alliance", id = 662, wx = -48631000976562.0, wy = -67406098632812.0, instance = 0}
	FM.flightmasterDB[663] = {zone = "Twilight Highlands", place = "Victor's Point", faction = "Alliance", id = 663, wx = -41705498046875.0, wy = -47489301757812.0, instance = 0}
	FM.flightmasterDB[664] = {zone = "Twilight Highlands", place = "Firebeard's Patrol", faction = "Alliance", id = 664, wx = -41838999023438.0, wy = -56201499023438.0, instance = 0}
	FM.flightmasterDB[665] = {zone = "Twilight Highlands", place = "Thundermar", faction = "Alliance", id = 665, wx = -3146919921875.0, wy = -49942797851562.0, instance = 0}
	FM.flightmasterDB[666] = {zone = "Twilight Highlands", place = "Kirthaven", faction = "Alliance", id = 666, wx = -26894299316406.0, wy = -54275297851562.0, instance = 0}
	FM.flightmasterDB[667] = {zone = "Hillsbrad", place = "Ruins of Southshore", faction = "Horde", id = 667, wx = -66183697509766.0, wy = -53649298095703.0, instance = 0}
	FM.flightmasterDB[668] = {zone = "Hillsbrad", place = "Southpoint Gate", faction = "Horde", id = 668, wx = -60518402099609.0, wy = 43546499633789.0, instance = 0}
	FM.flightmasterDB[669] = {zone = "Hillsbrad", place = "Eastpoint Tower", faction = "Horde", id = 669, wx = -56688897705078.0, wy = -10511999511719.0, instance = 0}
	FM.flightmasterDB[670] = {zone = "Alterac Mountains", place = "Strahnbrad", faction = "Horde", id = 670, wx = 62285101318359.0, wy = -97957800292969.0, instance = 0}
	FM.flightmasterDB[672] = {zone = "Western Plaguelands", place = "Hearthglen", id = 672, wx = 28397800292969.0, wy = -15005100097656.0, instance = 0}
	FM.flightmasterDB[673] = {zone = "Searing Gorge", place = "Iron Summit", id = 673, wx = -71230600585938.0, wy = -12366300048828.0, instance = 0}
	FM.flightmasterDB[674] = {zone = "Uldum", place = "Schnottz's Landing", id = 674, wx = -10711900390625.0, wy = 10596199951172.0, instance = 1}
	FM.flightmasterDB[675] = {zone = "Burning Steppes", place = "Flamestar Post", id = 675, wx = -8092259765625.0, wy = -10257900390625.0, instance = 0}
	FM.flightmasterDB[676] = {zone = "Burning Steppes", place = "Chiselgrip", id = 676, wx = -78659301757812.0, wy = -19195300292969.0, instance = 0}
	FM.flightmasterDB[681] = {zone = "Silverpine Forest", place = "Forsaken Rear Guard", faction = "Horde", id = 681, wx = 10560600585938.0, wy = 15189000244141.0, instance = 0}
	FM.flightmasterDB[683] = {zone = "Azshara", place = "Valormok", faction = "Horde", id = 683, wx = 29881298828125.0, wy = -41613598632812.0, instance = 1}
	FM.flightmasterDB[781] = {zone = "Hyjal", place = "Sanctuary of Malorne", id = 781, wx = 43977900390625.0, wy = -21075300292969.0, instance = 1}
end

-- Mists of Pandaria
if select(4, GetBuildInfo()) >= 50000 then
	FM.flightmasterDB[894] = {zone = "Jade Forest", place = "Grookin Hill", faction = "Horde", id = 894, wx = 14185699462891.0, wy = -48770300292969.0, instance = 870}
	FM.flightmasterDB[895] = {zone = "Jade Forest", place = "Dawn's Blossom", id = 895, wx = 15037099609375.0, wy = -18321300048828.0, instance = 870}
	FM.flightmasterDB[966] = {zone = "Jade Forest", place = "Paw'Don Village", faction = "Alliance", id = 966, wx = -30720001220703.0, wy = -17627700195312.0, instance = 870}
	FM.flightmasterDB[967] = {zone = "Jade Forest", place = "The Arboretum", id = 967, wx = 16006600341797.0, wy = -25302700195312.0, instance = 870}
	FM.flightmasterDB[968] = {zone = "Jade Forest", place = "Jade Temple Grounds", id = 968, wx = 77324700927734.0, wy = -23589599609375.0, instance = 870}
	FM.flightmasterDB[969] = {zone = "Jade Forest", place = "Sri-La Village", id = 969, wx = 25507600097656.0, wy = -24183200683594.0, instance = 870}
	FM.flightmasterDB[970] = {zone = "Jade Forest", place = "Emperor's Omen", id = 970, wx = 2400.75, wy = -20994299316406.0, instance = 870}
	FM.flightmasterDB[971] = {zone = "Jade Forest", place = "Tian Monastery", id = 971, wx = 25058999023438.0, wy = -15908900146484.0, instance = 870}
	FM.flightmasterDB[972] = {zone = "Jade Forest", place = "Pearlfin Village", faction = "Alliance", id = 972, wx = -18609700012207.0, wy = -25946101074219.0, instance = 870}
	FM.flightmasterDB[973] = {zone = "Jade Forest", place = "Honeydew Village", faction = "Horde", id = 973, wx = 29271599121094.0, wy = -50918399047852.0, instance = 870}
	FM.flightmasterDB[984] = {zone = "Valley of the Four Winds", place = "Pang's Stead", id = 984, wx = 54391497802734.0, wy = -63781402587891.0, instance = 870}
	FM.flightmasterDB[985] = {zone = "Valley of the Four Winds", place = "Halfhill", id = 985, wx = -22132600402832.0, wy = 46455899047852.0, instance = 870}
	FM.flightmasterDB[986] = {zone = "Krasarang Wilds", place = "Zhu's Watch", id = 986, wx = -37568399047852.0, wy = -64796502685547.0, instance = 870}
	FM.flightmasterDB[987] = {zone = "Krasarang Wilds", place = "Thunder Cleft", faction = "Horde", id = 987, wx = -87827600097656.0, wy = 17140299987793.0, instance = 870}
	FM.flightmasterDB[988] = {zone = "Krasarang Wilds", place = "The Incursion", faction = "Alliance", id = 988, wx = -11253100585938.0, wy = -22774699401856.0, instance = 870}
	FM.flightmasterDB[989] = {zone = "Valley of the Four Winds", place = "Stoneplow", id = 989, wx = -43654000854492.0, wy = 18866999511719.0, instance = 870}
	FM.flightmasterDB[990] = {zone = "Krasarang Wilds", place = "Dawnchaser Retreat", faction = "Horde", id = 990, wx = -16856800537109.0, wy = 15903399658203.0, instance = 870}
	FM.flightmasterDB[991] = {zone = "Krasarang Wilds", place = "Sentinel Basecamp", faction = "Alliance", id = 991, wx = -11566099853516.0, wy = 17703800048828.0, instance = 870}
	FM.flightmasterDB[992] = {zone = "Krasarang Wilds", place = "Cradle of Chi-Ji", id = 992, wx = -20823000488281.0, wy = 14836300048828.0, instance = 870}
	FM.flightmasterDB[993] = {zone = "Krasarang Wilds", place = "Marista", id = 993, wx = -25040900878906.0, wy = 4915830078125.0, instance = 870}
	FM.flightmasterDB[1017] = {zone = "Kun-Lai Summit", place = "Binan Village", id = 1017, wx = 16901099853516.0, wy = 3039580078125.0, instance = 870}
	FM.flightmasterDB[1018] = {zone = "Kun-Lai Summit", place = "Temple of the White Tiger", id = 1018, wx = 35040400390625.0, wy = 69067700195313.0, instance = 870}
	FM.flightmasterDB[1019] = {zone = "Kun-Lai Summit", place = "Eastwind Rest", faction = "Horde", id = 1019, wx = 22505900878906.0, wy = 93156896972656.0, instance = 870}
	FM.flightmasterDB[1020] = {zone = "Kun-Lai Summit", place = "Westwind Rest", faction = "Alliance", id = 1020, wx = 21033500976562.0, wy = 14638299560547.0, instance = 870}
	FM.flightmasterDB[1021] = {zone = "Kun-Lai Summit", place = "Zouchin Village", id = 1021, wx = 43629599609375.0, wy = 93211798095703.0, instance = 870}
	FM.flightmasterDB[1022] = {zone = "Kun-Lai Summit", place = "One Keg", id = 1022, wx = 31245200195312.0, wy = 12242800292969.0, instance = 870}
	FM.flightmasterDB[1023] = {zone = "Kun-Lai Summit", place = "Kota Basecamp", id = 1023, wx = 27164299316406.0, wy = 21633100585938.0, instance = 870}
	FM.flightmasterDB[1024] = {zone = "Kun-Lai Summit", place = "Shado-Pan Fallback", id = 1024, wx = 18805899658203.0, wy = 2088580078125.0, instance = 870}
	FM.flightmasterDB[1025] = {zone = "Kun-Lai Summit", place = "Winter's Blossom", id = 1025, wx = 31518500976562.0, wy = 26777600097656.0, instance = 870}
	FM.flightmasterDB[1029] = {zone = "The Veiled Stair", place = "Tavern in the Mists", id = 1029, wx = 78489898681641.0, wy = -20366999816895.0, instance = 870}
	FM.flightmasterDB[1052] = {zone = "Valley of the Four Winds", place = "Grassy Cline", id = 1052, wx = 46054000854492.0, wy = -10046700286865.0, instance = 870}
	FM.flightmasterDB[1053] = {zone = "Townlong Steppes", place = "Longying Outpost", id = 1053, wx = 23632299804688.0, wy = 29943898925781.0, instance = 870}
	FM.flightmasterDB[1054] = {zone = "Townlong Steppes", place = "Gao-Ran Battlefront", id = 1054, wx = 14407199707031.0, wy = 28044899902344.0, instance = 870}
	FM.flightmasterDB[1055] = {zone = "Townlong Steppes", place = "Rensai's Watchpost", id = 1055, wx = 15317299804688.0, wy = 39636999511719.0, instance = 870}
	FM.flightmasterDB[1056] = {zone = "Townlong Steppes", place = "Shado-Pan Garrison", id = 1056, wx = 18033199462891.0, wy = 42042299804688.0, instance = 870}
	FM.flightmasterDB[1057] = {zone = "Vale of Eternal Blossoms", place = "Shrine of Seven Stars", faction = "Alliance", id = 1057, wx = 89645300292969.0, wy = 33435101318359.0, instance = 870}
	FM.flightmasterDB[1058] = {zone = "Vale of Eternal Blossoms", place = "Shrine of Two Moons", faction = "Horde", id = 1058, wx = 15801600341797.0, wy = 8941669921875.0, instance = 870}
	FM.flightmasterDB[1070] = {zone = "Dread Wastes", place = "Klaxxi'vess", id = 1070, wx = 17266299438477.0, wy = 3152.25, instance = 870}
	FM.flightmasterDB[1071] = {zone = "Dread Wastes", place = "Soggy's Gamble", id = 1071, wx = -10862099609375.0, wy = 31361899414062.0, instance = 870}
	FM.flightmasterDB[1072] = {zone = "Dread Wastes", place = "The Sunset Brewgarden", id = 1072, wx = 98267700195313.0, wy = 34518601074219.0, instance = 870}
	FM.flightmasterDB[1073] = {zone = "Vale of Eternal Blossoms", place = "Serpent's Spine", id = 1073, wx = 61136499023438.0, wy = 21250300292969.0, instance = 870}
	FM.flightmasterDB[1080] = {zone = "Jade Forest", place = "Serpent's Overlook", id = 1080, wx = 46585598754883.0, wy = -15585600585938.0, instance = 870}
	FM.flightmasterDB[1090] = {zone = "Dread Wastes", place = "The Briny Muck", id = 1090, wx = -57040502929688.0, wy = 38597900390625.0, instance = 870}
	FM.flightmasterDB[1115] = {zone = "Dread Wastes", place = "The Lion's Redoubt", faction = "Alliance", id = 1115, wx = 23440600585938.0, wy = 21980300292969.0, instance = 870}
	FM.flightmasterDB[1117] = {zone = "Kun-Lai Summit", place = "Serpent's Spine", faction = "Horde", id = 1117, wx = 21231499023438.0, wy = 25849299316406.0, instance = 870}
	FM.flightmasterDB[1190] = {zone = "Krasarang Wilds", place = "Lion's Landing", faction = "Alliance", id = 1190, wx = -11935600585938.0, wy = -11936999511719.0, instance = 870}
	FM.flightmasterDB[1195] = {zone = "Krasarang Wilds", place = "Domination Point", faction = "Horde", id = 1195, wx = -17521899414062.0, wy = 24920200195312.0, instance = 870}
	FM.flightmasterDB[1221] = {zone = "Isle Of Giants", place = "Beeble's Wreck", faction = "Alliance", id = 1221, wx = 5753759765625.0, wy = 12555500488281.0, instance = 870}
	FM.flightmasterDB[1222] = {zone = "Isle Of Giants", place = "Bozzle's Wreck", faction = "Horde", id = 1222, wx = 57996401367188.0, wy = 10805699462891.0, instance = 870}
	FM.flightmasterDB[1293] = {zone = "Timeless Isle", place = "Tushui Landing", faction = "Alliance", id = 1293, wx = -90136999511719.0, wy = -46391201171875.0, instance = 870}
	FM.flightmasterDB[1294] = {zone = "Timeless Isle", place = "Huojin Landing", faction = "Horde", id = 1294, wx = -40495001220703.0, wy = -46085600585938.0, instance = 870}
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
	