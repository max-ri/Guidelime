local addonName, addon = ...

addon.flightmasterDB = {
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
	
	-- Burning Crusade
	[16192] = {zone = "Silvermoon City", name = "Skymistress Gloaming", faction = "Horde", localesIndex = 82},
	[16189] = {zone = "Ghostlands", name = "Skymaster Sunwing", place = "Tranquillien", faction = "Horde", localesIndex = 83},
	[17554] = {zone = "Bloodmyst Isle", name = "Laando", place = "Blood Watch", faction = "Alliance", localesIndex = 93},
	[17555] = {zone = "The Exodar", name = "Stephanos", faction = "Alliance", localesIndex = 94},
	[16587] = {zone = "Hellfire Peninsula", name = "Barley", place = "Thrallmar", faction = "Horde", localesIndex = 99},
	[16822] = {zone = "Hellfire Peninsula", name = "Flightmaster Krill Bitterhue", place = "Honor Hold", faction = "Alliance", localesIndex = 100},
	[18785] = {zone = "Hellfire Peninsula", name = "Kuma", place = "Temple of Telhamat", faction = "Alliance", localesIndex = 101},
	[18942] = {zone = "Hellfire Peninsula", name = "Innalia", place = "Falcon Watch", faction = "Horde", localesIndex = 102},
	[18788] = {zone = "Zangarmarsh", name = "Munci", place = "Telredor", faction = "Alliance", localesIndex = 117},
	[18791] = {zone = "Zangarmarsh", name = "Du'ga", place = "Zabra'jin", faction = "Horde", localesIndex = 118},
	[18789] = {zone = "Nagrand", name = "Furgu", place = "Telaar", faction = "Alliance", localesIndex = 119},
	[18808] = {zone = "Nagrand", name = "Gursha", place = "Garadar", faction = "Horde", localesIndex = 120},
	[18809] = {zone = "Terokkar Forest", name = "Furnan Skysoar", place = "Allerian Stronghold", faction = "Alliance", localesIndex = 121},
	[18938] = {zone = "Netherstorm", name = "Krexcil", place = "Area 52", localesIndex = 122},
	[19317] = {zone = "Shadowmoon Valley", name = "Drek'Gol", place = "Shadowmoon Village", faction = "Horde", localesIndex = 123},
	[18939] = {zone = "Shadowmoon Valley", name = "Brubeck Stormfoot", place = "Wildhammer Stronghold", faction = "Alliance", localesIndex = 124},
	[18937] = {zone = "Blades Edge Mountains", name = "Amerun Leafshade", place = "Sylvanaar", faction = "Alliance", localesIndex = 125},
	[18953] = {zone = "Blades Edge Mountains", name = "Unoke Tenderhoof", place = "Thunderlord Stronghold", faction = "Horde", localesIndex = 126},
	[18807] = {zone = "Terokkar Forest", name = "Kerna", place = "Stonebreaker Hold", faction = "Horde", localesIndex = 127},
	[18940] = {zone = "Terokkar Forest", name = "Nutral", place = "Shattrath", localesIndex = 128},
	[18931] = {zone = "Hellfire Peninsula", name = "Amish Wildhammer", place = "The Dark Portal", faction = "Alliance", localesIndex = 129},
	[18930] = {zone = "Hellfire Peninsula", name = "Vlagga Freyfeather", place = "The Dark Portal", faction = "Horde", localesIndex = 130},
	[19583] = {zone = "Netherstorm", name = "Grennik", place = "The Stormspire", localesIndex = 139},
	[19581] = {zone = "Shadowmoon Valley", name = "Maddix", place = "Altar of Sha'tar", localesIndex = 140},
	[19558] = {zone = "Hellfire Peninsula", name = "Amilya Airheart", place = "Spinebreaker Ridge", faction = "Horde", localesIndex = 141},
	[20234] = {zone = "Hellfire Peninsula", name = "Runetog Wildhammer", place = "Shatter Point", faction = "Alliance", localesIndex = 149},
	[20515] = {zone = "Netherstorm", name = "Harpax", place = "Cosmowrench", localesIndex = 150},
	[20762] = {zone = "Zangarmarsh", name = "Gur'zil", place = "Swamprat Post", faction = "Horde", localesIndex = 151},
	[21107] = {zone = "Blades Edge Mountains", name = "Rip Pedalslam", place = "Toshley's Station", faction = "Alliance", localesIndex = 156},
	[21766] = {zone = "Shadowmoon Valley", name = "Alieshor", place = "Sanctum of the Stars", localesIndex = 159},
	[22216] = {zone = "Blades Edge Mountains", name = "Fhyn Leafshadow", place = "Evergrove", localesIndex = 160},
	[22455] = {zone = "Blades Edge Mountains", name = "Sky-Master Maxxor", place = "Mok'Nathal Village", faction = "Horde", localesIndex = 163},
	[22485] = {zone = "Zangarmarsh", name = "Halu", place = "Orebor Harborage", faction = "Alliance", localesIndex = 164},
	[24851] = {zone = "Ghostlands", name = "Kiz Coilspanner", place = "Zul'Aman", localesIndex = 205},
	[26560] = {zone = "Isle of Quel Danas", name = "Ohura", place = "Shattered Sun Staging Area", localesIndex = 213},
}

function addon.getNearestFlightPoint(x, y, instance, faction)
	local minDist, minPos, minId
	for id, master in pairs(addon.flightmasterDB) do
		local pos = addon.getNPCPosition(id)
		if pos.instance == instance and ((master.faction or faction) == faction) then
			local dist = (x - pos.wx) * (x - pos.wx) + (y - pos.wy) * (y - pos.wy)
			if minDist == nil or dist < minDist then
				minDist = dist
				minPos = pos
				minId = id
			end
		end
	end
	if minPos == nil then return end
	return minPos.wx, minPos.wy, minPos.instance
end

function addon.getFlightPoint(id)
	if id == nil then return end
	local pos = addon.getNPCPosition(id)
	if pos == nil then return end
	return pos.wx, pos.wy, pos.instance
end

local function getFlightmasterByPlaceHelper(place, faction, func)
	local result
	for id, master in pairs(addon.flightmasterDB) do
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
	for id, master in pairs(addon.flightmasterDB) do
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
	for id, master in pairs(addon.flightmasterDB) do
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
	
function addon.getFlightmasterByPlace(place, faction)
	place = place:gsub(" ",""):lower()
	local result = getFlightmasterByPlaceHelper(place, faction, function(master) return master.zone:gsub(" ",""):lower() end)
	if result ~= nil then return result end
	result = getFlightmasterByPlaceHelper(place, faction, function(master) if master.place ~= nil then return master.place:gsub(" ",""):lower() end end)
	if result ~= nil then return result end
	result = getFlightmasterByPlaceHelper(place, faction, function(master) 
		local place = master.place and master.place:gsub(" ",""):lower()
		if place ~= nil and place:sub(1,3) == "the" then place = place:sub(4) end
		return place
	end)
	if result ~= nil then return result end
	for locale, flightmasters in pairs(addon.flightmasterDB_Locales) do
		result = getFlightmasterByPlaceHelper(place, faction, function(master) 
			return flightmasters[master.localesIndex]:gsub(" ",""):gsub(" ",""):lower() 
		end)
		if result ~= nil then return result end
	end
	result = getFlightmasterByPlaceHelper(place, faction, function(master) return addon.mapIDs[master.zone] and HBD:GetLocalizedMap(addon.mapIDs[master.zone]):gsub(" ",""):lower() end)
	return result
end

function addon.isFlightmasterMatch(master, name)
	if (master.place or master.zone) == name:sub(1, #(master.place or master.zone)) then return true end
	-- additional check for weird case where it is "place, zone" e.g. "Hellfire Peninsula, The Dark Portal"
	if master.place ~= nil and master.zone .. ", " .. master.place == name:sub(1, #(master.zone .. ", " .. master.place)) then return true end
	if addon.flightmasterDB_Locales[GetLocale()][master.localesIndex] == name then return true end
	return false
end
	