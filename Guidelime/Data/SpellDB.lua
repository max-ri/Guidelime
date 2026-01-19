local addonName, addon = ...

addon.D = addon.D or {}; local D = addon.D         -- Data/Data
addon.SK = addon.SK or {}; local SK = addon.SK     -- Data/SkillDB
addon.F = addon.F or {}; local F = addon.F         -- Frames

addon.SP = addon.SP or {}; local SP = addon.SP

function SP.getSpell(name)
	local s = name:upper():gsub("[ :%-%(%)'\"]","")
	return SP.spells[s] and s
end

function SP.isSpell(name)
	return SP.getSpell(name) ~= nil
end

function SP.getSpellId(name)
	local s = SP.spells[name]
	for _, id in ipairs(s.id) do
		if GetSpellInfo(id) then return id end
	end
end

local function mapSpellsById()
	SP.spellsById = {}
	for key, s in pairs(SP.spells) do
		for _, id in ipairs(s.id) do
			if addon.debugging and SP.spellsById[id] ~= nil then
				F.createPopupFrame("Error in Guidelime spell data: duplicate id " .. id .. " for " .. SP.spellsById[id] .. " and " .. key):Show()
			end
			SP.spellsById[id] = key
		end
	end
end

function SP.getSpellById(id)
	if not SP.spellsById then mapSpellsById() end
	return SP.spellsById[id] or (GetSpellInfo(id) and (GetSpellInfo(id)):upper():gsub("[ :%-%(%)'\"]",""))
end

function SP.getLocalizedName(name)
	if (type(name) == "number") then 
		local id = name
		local localized = (GetSpellInfo(id))
		if not localized and (not SP.loadSpellRequest or not SP.loadSpellRequest[id]) then 
			if addon.debugging then print("LIME: requesting spell data", id) end
			SP.reloadOnSpellData = true 
			C_Spell.RequestLoadSpellData(id)
			if not SP.loadSpellRequest then SP.loadSpellRequest = {} end
			SP.loadSpellRequest[id] = true
		end
		if localized then return localized, id end
		name = SP.getSpellById(id)
		if not name then return end
	end
	local s = SP.spells[name] 
	if s then
		for _, id in ipairs(s.id) do
			local localized = (GetSpellInfo(id))
			if localized then return localized, id end
		end
		return s.name, s.id[1]
	end
end

local function isTradeSkillKnown(localizedName)
	if GuidelimeDataChar.tradeSkills and GuidelimeDataChar.tradeSkills[localizedName] then return true end
	if SP.getTradeSkillIndex(localizedName) then
		if not GuidelimeDataChar.tradeSkills then GuidelimeDataChar.tradeSkills = {} end
		GuidelimeDataChar.tradeSkills[localizedName] = true 
		return true
	end
	return false
end

function SP.getSpellRank(name)
	local localizedName, id = SP.getLocalizedName(name)
	if GuidelimeDataChar.learnedSpells ~= nil and GuidelimeDataChar.learnedSpells[localizedName] ~= nil then return GuidelimeDataChar.learnedSpells[localizedName] end
	local skill, max = SK.getMaxSkillLearnedBySpell(id)
	if skill ~= nil then return SK.getSkillRank(skill) ~= nil and select(2, SK.getSkillRank(skill)) >= max and 1 or 0 end
	if not id or not IsSpellKnown(id) then return (isTradeSkillKnown(localizedName) and 1) or 0 end
	return SP.getSpellRankById(id)
end

function SP.getSpellRankById(id)
	local rank = GetSpellSubtext(id)
	if not rank and (not SP.loadSpellRequest or not SP.loadSpellRequest[id]) then 
		if addon.debugging then print("LIME: requesting spell data", id) end
		SP.reloadOnSpellData = true 
		C_Spell.RequestLoadSpellData(id)
		if not SP.loadSpellRequest then SP.loadSpellRequest = {} end
		SP.loadSpellRequest[id] = true
	end
	if rank ~= nil and rank:sub(1, RANK:len()) == RANK then return tonumber(rank:sub(RANK:len() + 2)) end
	return 1 
end

function SP.getTradeSkillIndex(localizedName)
	for i = 1, GetNumTradeSkills() do
		local skillName = GetTradeSkillInfo(i)
		if skillName == localizedName then return i end
	end
end

function SP.isRequiredSpell(name, spellMin, spellMax)
	local value = SP.getSpellRank(name)
	if spellMin ~= nil and value < spellMin then return false end
	if spellMax ~= nil and value >= spellMax then return false end
	return true
end

SP.spells = {
		["TITANSTEELGUARDIAN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55371, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Titansteel Guardian",
		},
		["MINORMANAPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Minor Mana Potion",
			["icon"] = 136243,
			["id"] = {
				2331, -- [1]
				2339, -- [2]
			},
		},
		["GLYPHOFEARTHLIVINGWEAPON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55439, -- [1]
				55541, -- [2]
				57236, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Earthliving Weapon",
		},
		["HELLFIRETOME"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59495, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Hellfire Tome",
		},
		["GLYPHOFVOIDWALKER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Voidwalker",
			["icon"] = 136243,
			["id"] = {
				56247, -- [1]
				56302, -- [2]
				57277, -- [3]
			},
		},
		["TYPHOON"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Typhoon",
			["icon"] = 236170,
			["id"] = {
				50516, -- [1]
				51817, -- [2]
				53223, -- [3]
				53225, -- [4]
				53226, -- [5]
				53227, -- [6]
				55087, -- [7]
				61384, -- [8]
				61387, -- [9]
				61388, -- [10]
				61390, -- [11]
				61391, -- [12]
				69823, -- [13]
				69824, -- [14]
			},
		},
		["ENDLESSHEALINGPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				58871, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Endless Healing Potion",
		},
		["DESTRUCTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				28508, -- [1]
			},
			["icon"] = 134729,
			["name"] = "Destruction",
		},
		["ARTISANFIRSTAID"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan First Aid",
			["icon"] = 135966,
			["id"] = {
				10847, -- [1]
				19902, -- [2]
			},
		},
		["MOONSHROUDGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56025, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Moonshroud Gloves",
		},
		["MITHRILCASING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Mithril Casing",
			["icon"] = 136243,
			["id"] = {
				12599, -- [1]
				12637, -- [2]
			},
		},
		["ENCHANTGLOVESEXCEPTIONALSPELLPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Gloves - Exceptional Spellpower",
			["icon"] = 136244,
			["id"] = {
				44592, -- [1]
			},
		},
		["GLYPHOFCONSECRATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Consecration",
			["icon"] = 136243,
			["id"] = {
				54928, -- [1]
				55114, -- [2]
				57023, -- [3]
			},
		},
		["MOONGLOWINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Moonglow Ink",
			["icon"] = 132918,
			["id"] = {
				52843, -- [1]
			},
		},
		["GLYPHOFFRENZIEDREGENERATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				54810, -- [1]
				54854, -- [2]
				56943, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Frenzied Regeneration",
		},
		["INKOFTHESEA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				57715, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Ink of the Sea",
		},
		["SAVAGESARONITELEGPLATES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55310, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Savage Saronite Legplates",
		},
		["STORMHERALD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				36263, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Stormherald",
		},
		["FROSTWEAVEBAG"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56007, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostweave Bag",
		},
		["HEROICPRESENCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				6562, -- [1]
				28878, -- [2]
			},
			["icon"] = 133123,
			["name"] = "Heroic Presence",
		},
		["THICKSUNCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53855, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Thick Sun Crystal",
		},
		["BINDINGHEAL"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				32546, -- [1]
				48119, -- [2]
				48120, -- [3]
			},
			["name"] = "Binding Heal",
			["icon"] = 135883,
			["castTime"] = 1500,
		},
		["SILVERPLATEDSHOTGUN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Silver-plated Shotgun",
			["icon"] = 136243,
			["id"] = {
				3949, -- [1]
				4009, -- [2]
			},
		},
		["COARSEBLASTINGPOWDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Coarse Blasting Powder",
			["icon"] = 136243,
			["id"] = {
				3929, -- [1]
				3992, -- [2]
			},
		},
		["WINDFURYTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8512, -- [1]
				8513, -- [2]
				8516, -- [3]
				10608, -- [4]
				10610, -- [5]
				10613, -- [6]
				10614, -- [7]
				10615, -- [8]
				10616, -- [9]
				27621, -- [10]
				8515, -- [11]
				65990, -- [12]
			},
			["icon"] = 136114,
			["name"] = "Windfury Totem",
		},
		["RUNEDTRUESILVERROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 30000,
			["id"] = {
				13702, -- [1]
				13703, -- [2]
			},
			["icon"] = 135148,
			["name"] = "Runed Truesilver Rod",
		},
		["EARTHENVEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Earthen Vest",
			["icon"] = 132149,
			["id"] = {
				8764, -- [1]
				8765, -- [2]
			},
		},
		["SILKYICESHARDBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56019, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Silky Iceshard Boots",
		},
		["RUNESTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56815, -- [1]
				56816, -- [2]
				62036, -- [3]
				66217, -- [4]
			},
			["icon"] = 237518,
			["name"] = "Rune Strike",
		},
		["HEAVYMITHRILGAUNTLET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Heavy Mithril Gauntlet",
			["icon"] = 132961,
			["id"] = {
				9928, -- [1]
				9929, -- [2]
			},
		},
		["JADEDAGGERPENDANT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				56195, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Jade Dagger Pendant",
		},
		["STARSHARDS"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				10797, -- [1]
				19296, -- [2]
				19299, -- [3]
				19302, -- [4]
				19303, -- [5]
				19304, -- [6]
				19305, -- [7]
				19350, -- [8]
				19351, -- [9]
				19352, -- [10]
				19353, -- [11]
				19354, -- [12]
				19355, -- [13]
				19356, -- [14]
				22822, -- [15]
				22823, -- [16]
				27636, -- [17]
			},
			["castTime"] = 0,
			["icon"] = 135753,
			["name"] = "Starshards",
		},
		["GREATERMAGICWAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 10000,
			["id"] = {
				14807, -- [1]
				14808, -- [2]
			},
			["icon"] = 135144,
			["name"] = "Greater Magic Wand",
		},
		["PYROBLAST"] = {
			["maxRange"] = 35,
			["minRange"] = 0,
			["castTime"] = 4704,
			["id"] = {
				11366, -- [1]
				1830, -- [2]
				12505, -- [3]
				12522, -- [4]
				12523, -- [5]
				12524, -- [6]
				12525, -- [7]
				12526, -- [8]
				13011, -- [9]
				13012, -- [10]
				13014, -- [11]
				13015, -- [12]
				13016, -- [13]
				13017, -- [14]
				17273, -- [15]
				17274, -- [16]
				18809, -- [17]
				20228, -- [18]
				24995, -- [19]
				27132, -- [20]
				29459, -- [21]
				29978, -- [22]
				31263, -- [23]
				33938, -- [24]
				33975, -- [25]
				36277, -- [26]
				36819, -- [27]
				38535, -- [28]
				41578, -- [29]
				42890, -- [30]
				42891, -- [31]
				64698, -- [32]
				70516, -- [33]
			},
			["icon"] = 135808,
			["name"] = "Pyroblast",
		},
		["HELLFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1949, -- [1]
				711, -- [2]
				1401, -- [3]
				3732, -- [4]
				5709, -- [5]
				11683, -- [6]
				11684, -- [7]
				11685, -- [8]
				11686, -- [9]
				27213, -- [10]
				30859, -- [11]
				34659, -- [12]
				34660, -- [13]
				37428, -- [14]
				39131, -- [15]
				39132, -- [16]
				40717, -- [17]
				40718, -- [18]
				42270, -- [19]
				43438, -- [20]
				43465, -- [21]
				47823, -- [22]
				69586, -- [23]
				65816, -- [24]
			},
			["name"] = "Hellfire",
			["icon"] = 135818,
			["castTime"] = 0,
		},
		["DAMPENMAGIC"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				604, -- [1]
				1266, -- [2]
				5305, -- [3]
				8450, -- [4]
				8451, -- [5]
				8452, -- [6]
				8453, -- [7]
				10173, -- [8]
				10174, -- [9]
				10175, -- [10]
				10176, -- [11]
				33944, -- [12]
				41478, -- [13]
				43015, -- [14]
			},
			["icon"] = 136006,
			["name"] = "Dampen Magic",
		},
		["FROSTWARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				6143, -- [1]
				3723, -- [2]
				6144, -- [3]
				8461, -- [4]
				8462, -- [5]
				8463, -- [6]
				8464, -- [7]
				10177, -- [8]
				10178, -- [9]
				15044, -- [10]
				28609, -- [11]
				25641, -- [12]
				27396, -- [13]
				32796, -- [14]
				32797, -- [15]
				43012, -- [16]
			},
			["icon"] = 135850,
			["name"] = "Frost Ward",
		},
		["SARONITEBULWARK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55014, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Saronite Bulwark",
		},
		["EXPERTCOOK"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 18816,
			["name"] = "Expert Cook",
			["icon"] = 133971,
			["id"] = {
				19886, -- [1]
				2552, -- [2]
				54257, -- [3]
			},
		},
		["LIFEBLOOM"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Lifebloom",
			["icon"] = 134206,
			["id"] = {
				33763, -- [1]
				33778, -- [2]
				43421, -- [3]
				43422, -- [4]
				48450, -- [5]
				48451, -- [6]
				52551, -- [7]
				52552, -- [8]
				53608, -- [9]
				53692, -- [10]
				57762, -- [11]
				57763, -- [12]
				59990, -- [13]
				61489, -- [14]
				64372, -- [15]
				66093, -- [16]
				66094, -- [17]
			},
		},
		["RUNEDCOPPERPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Runed Copper Pants",
			["icon"] = 134583,
			["id"] = {
				3324, -- [1]
				3343, -- [2]
			},
		},
		["DARKARCTICLEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				51569, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Dark Arctic Leggings",
		},
		["VIRULENTSPAULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60651, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Virulent Spaulders",
		},
		["LAVABURST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				21158, -- [1]
				51505, -- [2]
				53788, -- [3]
				55659, -- [4]
				55704, -- [5]
				56491, -- [6]
				58972, -- [7]
				59182, -- [8]
				59519, -- [9]
				60043, -- [10]
				61924, -- [11]
				64870, -- [12]
				64991, -- [13]
				71824, -- [14]
				66813, -- [15]
			},
			["icon"] = 135830,
			["name"] = "Lava Burst",
		},
		["SPARKLINGAZUREMOONSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28953, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Sparkling Azure Moonstone",
		},
		["FLAMESTRIKE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1882,
			["id"] = {
				2120, -- [1]
				846, -- [2]
				872, -- [3]
				2121, -- [4]
				2124, -- [5]
				2125, -- [6]
				8422, -- [7]
				8423, -- [8]
				8425, -- [9]
				8426, -- [10]
				10215, -- [11]
				10216, -- [12]
				10217, -- [13]
				10218, -- [14]
				11829, -- [15]
				12468, -- [16]
				16102, -- [17]
				16419, -- [18]
				18399, -- [19]
				18816, -- [20]
				18818, -- [21]
				20296, -- [22]
				20794, -- [23]
				20813, -- [24]
				20827, -- [25]
				22275, -- [26]
				24612, -- [27]
				30091, -- [28]
				27086, -- [29]
				27385, -- [30]
				33452, -- [31]
				36730, -- [32]
				36731, -- [33]
				36735, -- [34]
				41379, -- [35]
				41481, -- [36]
				42925, -- [37]
				42926, -- [38]
				44190, -- [39]
				44191, -- [40]
				44192, -- [41]
				46162, -- [42]
				46163, -- [43]
				56858, -- [44]
				61402, -- [45]
				61568, -- [46]
				62998, -- [47]
				63002, -- [48]
				63775, -- [49]
				72169, -- [50]
			},
			["icon"] = 135826,
			["name"] = "Flamestrike",
		},
		["TWILIGHTTOME"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				64053, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Twilight Tome",
		},
		["ARCTICSHOULDERPADS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50946, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Arctic Shoulderpads",
		},
		["QUICKDRAWQUIVER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Quickdraw Quiver",
			["icon"] = 136247,
			["id"] = {
				14930, -- [1]
				14931, -- [2]
			},
		},
		["GREATRESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53430, -- [1]
				53427, -- [2]
				53429, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 136085,
			["name"] = "Great Resistance",
		},
		["ENCHANTBOOTSGREATERVITALITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Boots - Greater Vitality",
			["icon"] = 136244,
			["id"] = {
				44584, -- [1]
			},
		},
		["PRISTINEHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53887, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Pristine Huge Citrine",
		},
		["CHALLENGINGSHOUT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Challenging Shout",
			["icon"] = 132091,
			["id"] = {
				1161, -- [1]
				798, -- [2]
			},
		},
		["SPELLPOWERELIXIR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				33721, -- [1]
				53842, -- [2]
			},
			["icon"] = 236885,
			["name"] = "Spellpower Elixir",
		},
		["GLOBALTHERMALSAPPERCHARGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56488, -- [1]
				56514, -- [2]
				61765, -- [3]
			},
			["icon"] = 135826,
			["name"] = "Global Thermal Sapper Charge",
		},
		["ARCANERESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				20592, -- [1]
				24493, -- [2]
				24495, -- [3]
				24497, -- [4]
				24500, -- [5]
				24501, -- [6]
				24508, -- [7]
				24509, -- [8]
				24510, -- [9]
				24519, -- [10]
				24520, -- [11]
				24521, -- [12]
				24522, -- [13]
				27540, -- [14]
				28770, -- [15]
				27350, -- [16]
			},
			["icon"] = 136116,
			["name"] = "Arcane Resistance",
		},
		["LEAP"] = {
			["maxRange"] = 30,
			["minRange"] = 5,
			["id"] = {
				47482, -- [1]
				28683, -- [2]
				49291, -- [3]
				55518, -- [4]
				57882, -- [5]
				60591, -- [6]
				61134, -- [7]
				61934, -- [8]
				70150, -- [9]
				67749, -- [10]
				67382, -- [11]
			},
			["castTime"] = 0,
			["icon"] = 237569,
			["name"] = "Leap",
		},
		["PRISTINEMONARCHTOPAZ"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				53989, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Pristine Monarch Topaz",
		},
		["HANDOFFREEDOM"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Hand of Freedom",
			["icon"] = 135968,
			["id"] = {
				--1044, -- [1]
				66115, -- [2]
			},
		},
		["ANGUISH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				47993, -- [1]
				33698, -- [2]
				33699, -- [3]
				33700, -- [4]
				33704, -- [5]
				33705, -- [6]
				33706, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 136160,
			["name"] = "Anguish",
		},
		["HOLYLIGHT"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 2352,
			["name"] = "Holy Light",
			["icon"] = 135920,
			["id"] = {
				635, -- [1]
				639, -- [2]
				647, -- [3]
				656, -- [4]
				664, -- [5]
				1026, -- [6]
				1027, -- [7]
				1042, -- [8]
				1043, -- [9]
				1872, -- [10]
				1873, -- [11]
				1874, -- [12]
				1913, -- [13]
				1914, -- [14]
				3472, -- [15]
				3473, -- [16]
				3474, -- [17]
				10328, -- [18]
				10329, -- [19]
				10330, -- [20]
				10331, -- [21]
				13952, -- [22]
				15493, -- [23]
				19968, -- [24]
				19980, -- [25]
				19981, -- [26]
				19982, -- [27]
				25263, -- [28]
				25292, -- [29]
				25400, -- [30]
				25963, -- [31]
				27135, -- [32]
				27136, -- [33]
				29383, -- [34]
				29427, -- [35]
				29562, -- [36]
				31713, -- [37]
				32769, -- [38]
				37979, -- [39]
				43451, -- [40]
				44479, -- [41]
				46029, -- [42]
				48781, -- [43]
				48782, -- [44]
				52444, -- [45]
				56539, -- [46]
				58053, -- [47]
				66112, -- [48]
			},
		},
		["HANDOFSALVATION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Hand of Salvation",
			["icon"] = 135967,
			["id"] = {
				--1038, -- [1]
				53055, -- [2]
			},
		},
		["OVERCHARGEDCAPACITOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56464, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Overcharged Capacitor",
		},
		["GOBLINROCKETHELMET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				12758, -- [1]
				12780, -- [2]
				13821, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Goblin Rocket Helmet",
		},
		["NIMBLELEATHERGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Nimble Leather Gloves",
			["icon"] = 136247,
			["id"] = {
				9074, -- [1]
				9075, -- [2]
			},
		},
		["DUSKWEAVELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55901, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Duskweave Leggings",
		},
		["SUMMONWARHORSE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Summon Warhorse",
			["icon"] = 136103,
			["id"] = {
				13820, -- [1]
				13819, -- [2]
				34768, -- [3]
				34769, -- [4]
				50829, -- [5]
			},
		},
		["RUBYHARE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56121, -- [1]
				56199, -- [2]
			},
			["icon"] = 237182,
			["name"] = "Ruby Hare",
		},
		["MASTERSCALL"] = {
			["maxRange"] = 25,
			["minRange"] = 0,
			["id"] = {
				53271, -- [1]
				54216, -- [2]
				56651, -- [3]
				62305, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 236189,
			["name"] = "Master's Call",
		},
		["SUPERSAPPERCHARGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				30486, -- [1]
				30560, -- [2]
			},
			["icon"] = 135826,
			["name"] = "Super Sapper Charge",
		},
		["AMULETOFTRUESIGHT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Amulet of Truesight",
			["icon"] = 134072,
			["id"] = {
				63743, -- [1]
			},
		},
		["ASPECTOFTHEMONKEY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				13163, -- [1]
				13164, -- [2]
			},
			["icon"] = 132159,
			["name"] = "Aspect of the Monkey",
		},
		["SIPHONLIFE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				18265, -- [1]
				18879, -- [2]
				18880, -- [3]
				18881, -- [4]
				18927, -- [5]
				18928, -- [6]
				18929, -- [7]
				35195, -- [8]
				41597, -- [9]
				63106, -- [10]
				63108, -- [11]
			},
			["castTime"] = 0,
			["icon"] = 136188,
			["name"] = "Siphon Life",
		},
		["ICEBLOCK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				27619, -- [1]
				11958, -- [2]
				36911, -- [3]
				41590, -- [4]
				45438, -- [5]
				45776, -- [6]
				46604, -- [7]
				46882, -- [8]
				56124, -- [9]
				56644, -- [10]
				62766, -- [11]
				65802, -- [12]
				69924, -- [13]
			},
			["icon"] = 135841,
			["name"] = "Ice Block",
		},
		["GLYPHOFTOTEMOFWRATH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Totem of Wrath",
			["icon"] = 136243,
			["id"] = {
				63280, -- [1]
				63926, -- [2]
				64262, -- [3]
			},
		},
		["NERUBIANGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50959, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Nerubian Gloves",
		},
		["ELIXIROFMIGHTYSTRENGTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				54218, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Elixir of Mighty Strength",
		},
		["GLYPHOFSWEEPINGSTRIKES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				57168, -- [1]
				58383, -- [2]
				58384, -- [3]
				58394, -- [4]
			},
			["icon"] = 132918,
			["name"] = "Glyph of Sweeping Strikes",
		},
		["CHAMPIONSHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53874, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Champion's Huge Citrine",
		},
		["HEAVYSHARPENINGSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Heavy Sharpening Stone",
			["icon"] = 135250,
			["id"] = {
				2674, -- [1]
				2752, -- [2]
			},
		},
		["GLYPHOFFLASHOFLIGHT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				54936, -- [1]
				54957, -- [2]
				55120, -- [3]
				57026, -- [4]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Flash of Light",
		},
		["SHOOT"] = {
			["maxRange"] = 30,
			["minRange"] = 5,
			["castTime"] = 1500,
			["id"] = {
				3018, -- [1]
				5019, -- [2]
				6660, -- [3]
				8995, -- [4]
				8996, -- [5]
				8997, -- [6]
				9008, -- [7]
				15547, -- [8]
				15620, -- [9]
				16100, -- [10]
				16496, -- [11]
				16572, -- [12]
				16767, -- [13]
				16768, -- [14]
				16772, -- [15]
				16775, -- [16]
				16776, -- [17]
				16777, -- [18]
				16778, -- [19]
				16779, -- [20]
				16780, -- [21]
				17353, -- [22]
				18561, -- [23]
				20463, -- [24]
				22121, -- [25]
				22411, -- [26]
				22907, -- [27]
				23073, -- [28]
				23337, -- [29]
				29575, -- [30]
				30221, -- [31]
				32103, -- [32]
				32168, -- [33]
				32190, -- [34]
				34583, -- [35]
				35946, -- [36]
				36625, -- [37]
				36951, -- [38]
				36980, -- [39]
				37770, -- [40]
				38094, -- [41]
				38295, -- [42]
				38372, -- [43]
				38723, -- [44]
				38858, -- [45]
				38940, -- [46]
				39079, -- [47]
				40124, -- [48]
				40873, -- [49]
				41093, -- [50]
				41169, -- [51]
				41188, -- [52]
				41440, -- [53]
				42131, -- [54]
				42476, -- [55]
				42579, -- [56]
				42580, -- [57]
				42611, -- [58]
				42661, -- [59]
				42664, -- [60]
				43234, -- [61]
				44961, -- [62]
				45172, -- [63]
				45219, -- [64]
				45223, -- [65]
				45229, -- [66]
				45233, -- [67]
				45425, -- [68]
				45578, -- [69]
				47001, -- [70]
				48115, -- [71]
				48117, -- [72]
				48424, -- [73]
				48425, -- [74]
				48426, -- [75]
				48815, -- [76]
				48854, -- [77]
				49712, -- [78]
				49987, -- [79]
				50092, -- [80]
				50512, -- [81]
				51502, -- [82]
				52566, -- [83]
				52818, -- [84]
				53327, -- [85]
				53332, -- [86]
				57589, -- [87]
				59001, -- [88]
				59146, -- [89]
				59241, -- [90]
				59710, -- [91]
				59993, -- [92]
				60926, -- [93]
				61512, -- [94]
				61515, -- [95]
				72208, -- [96]
				70162, -- [97]
				66079, -- [98]
				69710, -- [99]
				71253, -- [100]
				69276, -- [101]
				71927, -- [102]
				65868, -- [103]
				69974, -- [104]
				72545, -- [105]
				74414, -- [106]
				74762, -- [107]
				74182, -- [108]
				74179, -- [109]
				74178, -- [110]
				74174, -- [111]
			},
			["icon"] = 132222,
			["name"] = "Shoot",
		},
		["FROSTFEVER"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55095, -- [1]
				53388, -- [2]
				59921, -- [3]
				67719, -- [4]
				67767, -- [5]
				69917, -- [6]
			},
			["icon"] = 237522,
			["name"] = "Frost Fever",
		},
		["RAVAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53559, -- [1]
				3242, -- [2]
				3446, -- [3]
				6785, -- [4]
				6786, -- [5]
				6787, -- [6]
				6790, -- [7]
				8391, -- [8]
				9866, -- [9]
				9867, -- [10]
				9868, -- [11]
				9869, -- [12]
				24213, -- [13]
				24333, -- [14]
				27005, -- [15]
				29906, -- [16]
				33781, -- [17]
				48578, -- [18]
				48579, -- [19]
				50518, -- [20]
				53558, -- [21]
				53560, -- [22]
				53561, -- [23]
				53562, -- [24]
			},
			["castTime"] = 0,
			["icon"] = 132139,
			["name"] = "Ravage",
		},
		["BIGBLACKMACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Big Black Mace",
			["icon"] = 133490,
			["id"] = {
				10001, -- [1]
				10002, -- [2]
			},
		},
		["RAINOFFIRE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				4629, -- [1]
				3354, -- [2]
				3751, -- [3]
				5740, -- [4]
				5741, -- [5]
				6219, -- [6]
				6220, -- [7]
				11677, -- [8]
				11678, -- [9]
				11679, -- [10]
				11680, -- [11]
				11990, -- [12]
				16005, -- [13]
				19474, -- [14]
				19475, -- [15]
				19717, -- [16]
				20754, -- [17]
				24669, -- [18]
				28794, -- [19]
				27212, -- [20]
				31340, -- [21]
				31598, -- [22]
				33508, -- [23]
				33617, -- [24]
				33627, -- [25]
				33972, -- [26]
				34169, -- [27]
				34185, -- [28]
				34360, -- [29]
				34435, -- [30]
				36808, -- [31]
				37279, -- [32]
				37465, -- [33]
				38635, -- [34]
				38741, -- [35]
				39024, -- [36]
				39273, -- [37]
				39363, -- [38]
				39376, -- [39]
				42023, -- [40]
				42218, -- [41]
				42223, -- [42]
				42224, -- [43]
				42225, -- [44]
				42226, -- [45]
				42227, -- [46]
				43440, -- [47]
				47817, -- [48]
				47818, -- [49]
				47819, -- [50]
				47820, -- [51]
				49518, -- [52]
				54099, -- [53]
				54210, -- [54]
				57757, -- [55]
				58936, -- [56]
				59971, -- [57]
				69670, -- [58]
			},
			["name"] = "Rain of Fire",
			["icon"] = 136186,
			["castTime"] = 3000,
		},
		["PICKPOCKET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				921, -- [1]
				5167, -- [2]
			},
			["icon"] = 133644,
			["name"] = "Pick Pocket",
		},
		["DESPERATEPRAYER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				19236, -- [1]
				13908, -- [2]
				19238, -- [3]
				19240, -- [4]
				19241, -- [5]
				19242, -- [6]
				19243, -- [7]
				19338, -- [8]
				19339, -- [9]
				19340, -- [10]
				19341, -- [11]
				19342, -- [12]
				19343, -- [13]
				19344, -- [14]
				25437, -- [15]
				48172, -- [16]
				48173, -- [17]
			},
			["name"] = "Desperate Prayer",
			["icon"] = 135954,
			["castTime"] = 0,
		},
		["RIGHTEOUSDEFENSE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Righteous Defense",
			["icon"] = 135068,
			["id"] = {
				31789, -- [1]
				31790, -- [2]
			},
		},
		["TITANSTEELSPELLBLADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				63182, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Titansteel Spellblade",
		},
		["WEAPONVELLUMII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Weapon Vellum II",
			["icon"] = 132918,
			["id"] = {
				59488, -- [1]
			},
		},
		["WILDSCALEBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60669, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Wildscale Breastplate",
		},
		["COPPERSHORTSWORD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Copper Shortsword",
			["icon"] = 135327,
			["id"] = {
				2739, -- [1]
				2756, -- [2]
			},
		},
		["BRILLIANTGOLDENDRAENITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28938, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Brilliant Golden Draenite",
		},
		["COARSEDYNAMITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Coarse Dynamite",
			["icon"] = 136243,
			["id"] = {
				3931, -- [1]
				3994, -- [2]
				4061, -- [3]
				8333, -- [4]
				9002, -- [5]
				9003, -- [6]
				9004, -- [7]
				9009, -- [8]
			},
		},
		["ARCANETAROT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Arcane Tarot",
			["icon"] = 132918,
			["id"] = {
				59487, -- [1]
			},
		},
		["SMALLSILKPACK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Small Silk Pack",
			["icon"] = 136249,
			["id"] = {
				3813, -- [1]
				3814, -- [2]
			},
		},
		["OILOFIMMOLATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Oil of Immolation",
			["icon"] = 136243,
			["id"] = {
				11451, -- [1]
				11486, -- [2]
			},
		},
		["GLINTINGSTEELDAGGER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Glinting Steel Dagger",
			["icon"] = 135641,
			["id"] = {
				15972, -- [1]
				15974, -- [2]
			},
		},
		["CRAFTEDHEAVYSHOT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Crafted Heavy Shot",
			["icon"] = 136243,
			["id"] = {
				3930, -- [1]
				3993, -- [2]
			},
		},
		["APPRENTICEBLACKSMITH"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Blacksmith",
			["icon"] = 136241,
			["id"] = {
				2020, -- [1]
			},
		},
		["GLYPHOFLAVALASH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Lava Lash",
			["icon"] = 136243,
			["id"] = {
				55444, -- [1]
				55560, -- [2]
				57249, -- [3]
			},
		},
		["ENCHANTBRACERMINORSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7457, -- [1]
				7459, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Minor Stamina",
		},
		["HEROISM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				23682, -- [1]
				23689, -- [2]
				32182, -- [3]
				32927, -- [4]
				32955, -- [5]
				37471, -- [6]
				39200, -- [7]
				65983, -- [8]
			},
			["icon"] = 135953,
			["name"] = "Heroism",
		},
		["GLYPHOFIMP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Imp",
			["icon"] = 136243,
			["id"] = {
				56248, -- [1]
				56292, -- [2]
				57269, -- [3]
			},
		},
		["ELIXIROFMIGHTYAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53840, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Elixir of Mighty Agility",
		},
		["LESSERINVISIBILITYPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Lesser Invisibility Potion",
			["icon"] = 136243,
			["id"] = {
				3448, -- [1]
				3459, -- [2]
			},
		},
		["BALANCEDTWILIGHTOPAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				53969, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Balanced Twilight Opal",
		},
		["STRANGULATE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				47476, -- [1]
				48680, -- [2]
				49913, -- [3]
				49914, -- [4]
				49915, -- [5]
				49916, -- [6]
				51131, -- [7]
				55314, -- [8]
				55334, -- [9]
				66018, -- [10]
			},
			["icon"] = 136214,
			["name"] = "Strangulate",
		},
		["DARKNERUBIANCHESTPIECE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60629, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Dark Nerubian Chestpiece",
		},
		["LINENBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Linen Boots",
			["icon"] = 132149,
			["id"] = {
				2386, -- [1]
				2967, -- [2]
			},
		},
		["SHADOWBURN"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["id"] = {
				17877, -- [1]
				18867, -- [2]
				18868, -- [3]
				18869, -- [4]
				18870, -- [5]
				18871, -- [6]
				18872, -- [7]
				18875, -- [8]
				18876, -- [9]
				18877, -- [10]
				18878, -- [11]
				27263, -- [12]
				29341, -- [13]
				30546, -- [14]
				47826, -- [15]
				47827, -- [16]
			},
			["name"] = "Shadowburn",
			["icon"] = 136191,
			["castTime"] = 0,
		},
		["TURTLESCALEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Turtle Scale Bracers",
			["icon"] = 136247,
			["id"] = {
				10518, -- [1]
				10519, -- [2]
			},
		},
		["GLYPHOFBLOODSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				59332, -- [1]
				59333, -- [2]
				59339, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Blood Strike",
		},
		["SOLIDBRONZERING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Solid Bronze Ring",
			["icon"] = 136243,
			["id"] = {
				25490, -- [1]
			},
		},
		["BOLTOFMAGEWEAVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Bolt of Mageweave",
			["icon"] = 136249,
			["id"] = {
				3865, -- [1]
				3875, -- [2]
			},
		},
		["SKINNING"] = {
			["maxRange"] = 5,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				8613, -- [1]
				8617, -- [2]
				8618, -- [3]
				10768, -- [4]
				13697, -- [5]
				32678, -- [6]
				50305, -- [7]
				52158, -- [8]
			},
			["icon"] = 134366,
			["name"] = "Skinning",
		},
		["EMERALDCHOKER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				64725, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Emerald Choker",
		},
		["SALTSHAKER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Salt Shaker",
			["icon"] = 134459,
			["id"] = {
				19566, -- [1]
				19567, -- [2]
				19568, -- [3]
			},
		},
		["FROSTLEATHERCLOAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Frost Leather Cloak",
			["icon"] = 136247,
			["id"] = {
				9198, -- [1]
				9212, -- [2]
			},
		},
		["KICK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1766, -- [1]
				1767, -- [2]
				1768, -- [3]
				1769, -- [4]
				1771, -- [5]
				1772, -- [6]
				1773, -- [7]
				1774, -- [8]
				1775, -- [9]
				3467, -- [10]
				11978, -- [11]
				15610, -- [12]
				15614, -- [13]
				27613, -- [14]
				27814, -- [15]
				1770, -- [16]
				3466, -- [17]
				29560, -- [18]
				29586, -- [19]
				30460, -- [20]
				31402, -- [21]
				32105, -- [22]
				33424, -- [23]
				34802, -- [24]
				36033, -- [25]
				38625, -- [26]
				38768, -- [27]
				41395, -- [28]
				43518, -- [29]
				45356, -- [30]
			},
			["castTime"] = 0,
			["icon"] = 132219,
			["name"] = "Kick",
		},
		["FELIRONHATCHET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29557, -- [1]
			},
			["icon"] = 132402,
			["name"] = "Fel Iron Hatchet",
		},
		["TRUESILVERCOMMANDERSRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Truesilver Commander's Ring",
			["icon"] = 134072,
			["id"] = {
				34959, -- [1]
			},
		},
		["MYSTERIOUSTAROT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Mysterious Tarot",
			["icon"] = 132918,
			["id"] = {
				48247, -- [1]
			},
		},
		["ARCTICLEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50945, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Arctic Leggings",
		},
		["CALLOFTHEELEMENTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				66842, -- [1]
			},
			["icon"] = 310730,
			["name"] = "Call of the Elements",
		},
		["THICKBRONZEDARTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Thick Bronze Darts",
			["icon"] = 136241,
			["id"] = {
				34979, -- [1]
			},
		},
		["GREENIRONHAUBERK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Green Iron Hauberk",
			["icon"] = 132624,
			["id"] = {
				3508, -- [1]
				3525, -- [2]
			},
		},
		["ENCHANTBRACERSMAJORSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Bracers - Major Spirit",
			["icon"] = 136244,
			["id"] = {
				44593, -- [1]
			},
		},
		["GNOMISHDEATHRAY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				12759, -- [1]
				12779, -- [2]
				13278, -- [3]
				13279, -- [4]
				13280, -- [5]
				13493, -- [6]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Death Ray",
		},
		["BARBARICIRONCOLLAR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Barbaric Iron Collar",
			["icon"] = 136243,
			["id"] = {
				25498, -- [1]
			},
		},
		["FORMALWHITESHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Formal White Shirt",
			["icon"] = 132149,
			["id"] = {
				3871, -- [1]
				3893, -- [2]
			},
		},
		["STARKHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53889, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Stark Huge Citrine",
		},
		["SHIMMERINGINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Shimmering Ink",
			["icon"] = 132918,
			["id"] = {
				57711, -- [1]
			},
		},
		["INVISIBILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				--66, -- [1]
				885, -- [2]
				886, -- [3]
				11392, -- [4]
				23452, -- [5]
				28500, -- [6]
				32612, -- [7]
				32754, -- [8]
				52060, -- [9]
				55848, -- [10]
				60190, -- [11]
				60191, -- [12]
				67765, -- [13]
			},
			["icon"] = 132220,
			["name"] = "Invisibility",
		},
		["DRAKEFISTHAMMER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34545, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Drakefist Hammer",
		},
		["HAMMERPICK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56459, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Hammer Pick",
		},
		["FROSTWEAVEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Frostweave Gloves",
			["icon"] = 132149,
			["id"] = {
				18411, -- [1]
			},
		},
		["MANAPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Mana Potion",
			["icon"] = 136243,
			["id"] = {
				3452, -- [1]
				3461, -- [2]
				32453, -- [3]
				58864, -- [4]
			},
		},
		["STONESCALEOIL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Stonescale Oil",
			["icon"] = 136243,
			["id"] = {
				17551, -- [1]
				17581, -- [2]
			},
		},
		["GHOSTWEAVEBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Ghostweave Belt",
			["icon"] = 132149,
			["id"] = {
				18410, -- [1]
			},
		},
		["SHADOWMIGHTRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				58146, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Shadowmight Ring",
		},
		["GLYPHOFPOWERWORDSHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Power Word: Shield",
			["icon"] = 136243,
			["id"] = {
				55672, -- [1]
				56160, -- [2]
				56175, -- [3]
				57194, -- [4]
			},
		},
		["BRILLIANTAUTUMNSGLOW"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				53956, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Brilliant Autumn's Glow",
		},
		["PRISMATICBLACKDIAMOND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				62941, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Prismatic Black Diamond",
		},
		["SHADOWRESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				20579, -- [1]
				4084, -- [2]
				24488, -- [3]
				24490, -- [4]
				24505, -- [5]
				24506, -- [6]
				24507, -- [7]
				24514, -- [8]
				24515, -- [9]
				24516, -- [10]
				24518, -- [11]
				24526, -- [12]
				24527, -- [13]
				24528, -- [14]
				27535, -- [15]
				28769, -- [16]
				27056, -- [17]
				27353, -- [18]
				59221, -- [19]
				59535, -- [20]
				59536, -- [21]
				59538, -- [22]
				59539, -- [23]
				59540, -- [24]
				59541, -- [25]
			},
			["icon"] = 136152,
			["name"] = "Shadow Resistance",
		},
		["CONEOFCOLD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				120, -- [1]
				1241, -- [2]
				8492, -- [3]
				8493, -- [4]
				10159, -- [5]
				10160, -- [6]
				10161, -- [7]
				10162, -- [8]
				10163, -- [9]
				10164, -- [10]
				12557, -- [11]
				12611, -- [12]
				15244, -- [13]
				20828, -- [14]
				22746, -- [15]
				30095, -- [16]
				27087, -- [17]
				27386, -- [18]
				29717, -- [19]
				34325, -- [20]
				37265, -- [21]
				38384, -- [22]
				38644, -- [23]
				42930, -- [24]
				42931, -- [25]
				43066, -- [26]
				46984, -- [27]
				58463, -- [28]
				59258, -- [29]
				64645, -- [30]
				64655, -- [31]
				65023, -- [32]
			},
			["icon"] = 135852,
			["name"] = "Cone of Cold",
		},
		["EXPERTLEATHERWORKER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Expert Leatherworker",
			["icon"] = 133611,
			["id"] = {
				3812, -- [1]
			},
		},
		["FELSTEELWHISPERKNIVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				34983, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Felsteel Whisper Knives",
		},
		["FLIGHTFORM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Flight Form",
			["icon"] = 132128,
			["id"] = {
				33943, -- [1]
				33950, -- [2]
			},
		},
		["GLYPHOFICEBLOCK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Ice Block",
			["icon"] = 136243,
			["id"] = {
				56372, -- [1]
				56592, -- [2]
				56979, -- [3]
			},
		},
		["COBRAREFLEXES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				61682, -- [1]
				25076, -- [2]
				25077, -- [3]
				61683, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 136040,
			["name"] = "Cobra Reflexes",
		},
		["STRENGTHOFEARTHTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8075, -- [1]
				8077, -- [2]
				8160, -- [3]
				8161, -- [4]
				8164, -- [5]
				8165, -- [6]
				10442, -- [7]
				10443, -- [8]
				25361, -- [9]
				25403, -- [10]
				25965, -- [11]
				25528, -- [12]
				31633, -- [13]
				57622, -- [14]
				58643, -- [15]
				65991, -- [16]
			},
			["icon"] = 136023,
			["name"] = "Strength of Earth Totem",
		},
		["ENCHANTCHESTMAJORMANA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				20028, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Major Mana",
		},
		["FROSTSAVAGEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59586, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostsavage Gloves",
		},
		["NETHERWEAVEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				26764, -- [1]
			},
			["icon"] = 132149,
			["name"] = "Netherweave Bracers",
		},
		["ENCHANTBOOTSLESSERACCURACY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				63746, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Boots - Lesser Accuracy",
		},
		["RUNICHEALINGPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53836, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Runic Healing Potion",
		},
		["GLYPHOFPLAGUESTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				57221, -- [1]
				58657, -- [2]
				58720, -- [3]
			},
			["icon"] = 132918,
			["name"] = "Glyph of Plague Strike",
		},
		["FREEZINGTRAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1499, -- [1]
				1552, -- [2]
				14310, -- [3]
				14311, -- [4]
				14368, -- [5]
				14370, -- [6]
				27753, -- [7]
				31933, -- [8]
				32419, -- [9]
				37368, -- [10]
				41085, -- [11]
				43414, -- [12]
				43415, -- [13]
				43447, -- [14]
				43448, -- [15]
				44136, -- [16]
				55040, -- [17]
			},
			["icon"] = 135834,
			["name"] = "Freezing Trap",
		},
		["MACESPECIALIZATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				5530, -- [1]
				4366, -- [2]
				4367, -- [3]
				4368, -- [4]
				4369, -- [5]
				4370, -- [6]
				4371, -- [7]
				4372, -- [8]
				4373, -- [9]
				4374, -- [10]
				4375, -- [11]
				4376, -- [12]
				4377, -- [13]
				4378, -- [14]
				4379, -- [15]
				4380, -- [16]
				4381, -- [17]
				5548, -- [18]
				5549, -- [19]
				5550, -- [20]
				5551, -- [21]
				5552, -- [22]
				5553, -- [23]
				5554, -- [24]
				5558, -- [25]
				5559, -- [26]
				5560, -- [27]
				5561, -- [28]
				5562, -- [29]
				5563, -- [30]
				5564, -- [31]
				12284, -- [32]
				12701, -- [33]
				12702, -- [34]
				12703, -- [35]
				12704, -- [36]
				13709, -- [37]
				13800, -- [38]
				13801, -- [39]
				13802, -- [40]
				13803, -- [41]
				20864, -- [42]
				59224, -- [43]
			},
			["icon"] = 133476,
			["name"] = "Mace Specialization",
		},
		["ELIXIROFWATERBREATHING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Water Breathing",
			["icon"] = 136243,
			["id"] = {
				7179, -- [1]
				7180, -- [2]
			},
		},
		["GREENWORKMANSSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				56000, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Green Workman's Shirt",
		},
		["STALWARTHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53890, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Stalwart Huge Citrine",
		},
		["DRAGONSBREATH"] = {
			["maxRange"] = 50,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				29964, -- [1]
				29965, -- [2]
				31661, -- [3]
				33041, -- [4]
				33042, -- [5]
				33043, -- [6]
				35250, -- [7]
				37289, -- [8]
				42949, -- [9]
				42950, -- [10]
			},
			["icon"] = 134153,
			["name"] = "Dragon's Breath",
		},
		["PETBARDING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53175, -- [1]
				53176, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 133190,
			["name"] = "Pet Barding",
		},
		["SCROLLOFSTAMINAVIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50620, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Stamina VIII",
		},
		["DIVINEPROTECTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Divine Protection",
			["icon"] = 135954,
			["id"] = {
				498, -- [1]
				735, -- [2]
				3697, -- [3]
				5572, -- [4]
				5573, -- [5]
				5574, -- [6]
				13007, -- [7]
				27778, -- [8]
				27779, -- [9]
			},
		},
		["DENSESHARPENINGSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Dense Sharpening Stone",
			["icon"] = 135252,
			["id"] = {
				16641, -- [1]
				16669, -- [2]
			},
		},
		["VISAGELIQUIFICATIONGOGGLES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				56484, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Visage Liquification Goggles",
		},
		["PURGE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				370, -- [1]
				558, -- [2]
				1333, -- [3]
				8012, -- [4]
				8013, -- [5]
				25756, -- [6]
				27626, -- [7]
				33625, -- [8]
				66057, -- [9]
			},
			["icon"] = 136075,
			["name"] = "Purge",
		},
		["NETHERWEAVEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				26772, -- [1]
			},
			["icon"] = 132149,
			["name"] = "Netherweave Boots",
		},
		["SAPPHIREOWL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56186, -- [1]
				56187, -- [2]
				56202, -- [3]
			},
			["icon"] = 237178,
			["name"] = "Sapphire Owl",
		},
		["EMERALDBOAR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56188, -- [1]
				56203, -- [2]
			},
			["icon"] = 237186,
			["name"] = "Emerald Boar",
		},
		["THORIUMWIDGET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Thorium Widget",
			["icon"] = 136243,
			["id"] = {
				19791, -- [1]
			},
		},
		["POTIONOFNIGHTMARES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53900, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Potion of Nightmares",
		},
		["BULLHEADED"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53490, -- [1]
				63896, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132335,
			["name"] = "Bullheaded",
		},
		["SCROLLOFINTELLECTII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Intellect II",
			["icon"] = 132918,
			["id"] = {
				50598, -- [1]
			},
		},
		["SPARKLINGCHALCEDONY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53940, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Sparkling Chalcedony",
		},
		["RUGGEDARMORKIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Rugged Armor Kit",
			["icon"] = 136243,
			["id"] = {
				19058, -- [1]
				19148, -- [2]
			},
		},
		["FIRERESISTANCETOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8184, -- [1]
				8186, -- [2]
				10537, -- [3]
				10538, -- [4]
				10540, -- [5]
				10541, -- [6]
				25563, -- [7]
				58737, -- [8]
				58739, -- [9]
			},
			["icon"] = 135832,
			["name"] = "Fire Resistance Totem",
		},
		["GLYPHOFRIGHTEOUSDEFENSE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Righteous Defense",
			["icon"] = 136243,
			["id"] = {
				54929, -- [1]
				55115, -- [2]
				57032, -- [3]
			},
		},
		["FLAMETHROWER"] = {
			["maxRange"] = 15,
			["minRange"] = 0,
			["id"] = {
				25027, -- [1]
				25029, -- [2]
				39686, -- [3]
				39693, -- [4]
				45466, -- [5]
				45467, -- [6]
				52609, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 134535,
			["name"] = "Flamethrower",
		},
		["NATURESGRASP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Nature's Grasp",
			["icon"] = 136063,
			["id"] = {
				16689, -- [1]
				5230, -- [2]
				16810, -- [3]
				16811, -- [4]
				16812, -- [5]
				16813, -- [6]
				17329, -- [7]
				17373, -- [8]
				17374, -- [9]
				17375, -- [10]
				17376, -- [11]
				27009, -- [12]
				53312, -- [13]
				66071, -- [14]
			},
		},
		["ELIXIROFBRUTEFORCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Elixir of Brute Force",
			["icon"] = 134839,
			["id"] = {
				17537, -- [1]
				17557, -- [2]
			},
		},
		["SHIFTINGSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53860, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Shifting Shadow Crystal",
		},
		["LASHOFPAIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				47992, -- [1]
				7814, -- [2]
				7815, -- [3]
				7816, -- [4]
				7876, -- [5]
				7877, -- [6]
				7878, -- [7]
				11778, -- [8]
				11779, -- [9]
				11780, -- [10]
				11781, -- [11]
				11782, -- [12]
				11783, -- [13]
				15968, -- [14]
				15969, -- [15]
				20398, -- [16]
				20399, -- [17]
				20400, -- [18]
				20401, -- [19]
				20402, -- [20]
				21987, -- [21]
				27274, -- [22]
				27493, -- [23]
				32202, -- [24]
				36864, -- [25]
				38852, -- [26]
				41353, -- [27]
				44640, -- [28]
				47991, -- [29]
			},
			["castTime"] = 0,
			["icon"] = 136136,
			["name"] = "Lash of Pain",
		},
		["FISTWEAPONS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Fist Weapons",
			["icon"] = 132938,
			["id"] = {
				15590, -- [1]
				15992, -- [2]
			},
		},
		["SHIELDWALL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Shield Wall",
			["icon"] = 132362,
			["id"] = {
				871, -- [1]
				1055, -- [2]
				15062, -- [3]
				29061, -- [4]
				29390, -- [5]
				31731, -- [6]
				41104, -- [7]
				41196, -- [8]
			},
		},
		["SCROLLOFSPIRITII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Spirit II",
			["icon"] = 132918,
			["id"] = {
				50605, -- [1]
			},
		},
		["BRILLIANTSARONITEPAULDRONS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59440, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Brilliant Saronite Pauldrons",
		},
		["SEALOFVENGEANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Seal of Vengeance",
			["icon"] = 135969,
			["id"] = {
				31801, -- [1]
				42463, -- [2]
			},
		},
		["MINDAMPLIFICATIONDISH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 470,
			["id"] = {
				67799, -- [1]
				67839, -- [2]
			},
			["icon"] = 135995,
			["name"] = "Mind Amplification Dish",
		},
		["SPIDERSILKBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Spidersilk Boots",
			["icon"] = 132149,
			["id"] = {
				3855, -- [1]
				3886, -- [2]
			},
		},
		["DAZZLINGFORESTEMERALD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				54007, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Dazzling Forest Emerald",
		},
		["CORRODEDSARONITEWOUNDBRINGER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55184, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Corroded Saronite Woundbringer",
		},
		["TITANSTEELBONECRUSHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55370, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Titansteel Bonecrusher",
		},
		["GLYPHOFMULTISHOT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Multi-Shot",
			["icon"] = 136243,
			["id"] = {
				56836, -- [1]
				56882, -- [2]
				57007, -- [3]
			},
		},
		["CRUDESCOPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["name"] = "Crude Scope",
			["icon"] = 136243,
			["id"] = {
				3974, -- [1]
				3977, -- [2]
				3988, -- [3]
			},
		},
		["DARKMOONCARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Darkmoon Card",
			["icon"] = 132918,
			["id"] = {
				59502, -- [1]
			},
		},
		["FIREGOGGLES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Fire Goggles",
			["icon"] = 136243,
			["id"] = {
				12594, -- [1]
				12634, -- [2]
			},
		},
		["SHADOWGUARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				18137, -- [1]
				19308, -- [2]
				19309, -- [3]
				19310, -- [4]
				19311, -- [5]
				19312, -- [6]
				19331, -- [7]
				19332, -- [8]
				19333, -- [9]
				19334, -- [10]
				19335, -- [11]
				19336, -- [12]
				28165, -- [13]
				28166, -- [14]
				28376, -- [15]
				28377, -- [16]
				28378, -- [17]
				28379, -- [18]
				28380, -- [19]
				28381, -- [20]
				28382, -- [21]
				32861, -- [22]
				38379, -- [23]
			},
			["castTime"] = 0,
			["icon"] = 136051,
			["name"] = "Shadowguard",
		},
		["GLYPHOFRENDING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Rending",
			["icon"] = 132918,
			["id"] = {
				57163, -- [1]
				58385, -- [2]
				58399, -- [3]
			},
		},
		["BLACKJELLY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				64358, -- [1]
			},
			["icon"] = 252178,
			["name"] = "Black Jelly",
		},
		["BRILLIANTSUNCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53852, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Brilliant Sun Crystal",
		},
		["JOURNEYMANRIDING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				33391, -- [1]
				33392, -- [2]
			},
			["icon"] = 136103,
			["name"] = "Journeyman Riding",
		},
		["GREATERDARKMOONCARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				59503, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Greater Darkmoon Card",
		},
		["RIGHTEOUSFURY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Righteous Fury",
			["icon"] = 135962,
			["id"] = {
				25780, -- [1]
				20450, -- [2]
				25781, -- [3]
			},
		},
		["INVIGORATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53397, -- [1]
				53252, -- [2]
				53253, -- [3]
				53398, -- [4]
				53412, -- [5]
				71881, -- [6]
				71882, -- [7]
				71883, -- [8]
				71884, -- [9]
				71885, -- [10]
				71886, -- [11]
				71887, -- [12]
				71888, -- [13]
			},
			["castTime"] = 0,
			["icon"] = 236184,
			["name"] = "Invigoration",
		},
		["GOBLINBOMBDISPENSER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				12755, -- [1]
				12777, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Goblin Bomb Dispenser",
		},
		["DIPLOMACY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Diplomacy",
			["icon"] = 134328,
			["id"] = {
				20599, -- [1]
			},
		},
		["SPARKLINGSKYSAPPHIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				53953, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Sparkling Sky Sapphire",
		},
		["ICEBORNEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50942, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Iceborne Boots",
		},
		["ORNATESARONITESKULLSHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56556, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Ornate Saronite Skullshield",
		},
		["WATERBREATHING"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				131, -- [1]
				488, -- [2]
				5386, -- [3]
				7178, -- [4]
				11789, -- [5]
				16881, -- [6]
				40621, -- [7]
				44235, -- [8]
				45328, -- [9]
				48719, -- [10]
				51244, -- [11]
				52909, -- [12]
			},
			["icon"] = 136148,
			["name"] = "Water Breathing",
		},
		["PORTALIRONFORGE"] = {
			["maxRange"] = 10,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				11416, -- [1]
				11421, -- [2]
			},
			["icon"] = 135743,
			["name"] = "Portal: Ironforge",
		},
		["PRAYEROFSHADOWPROTECTION"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				27683, -- [1]
				27684, -- [2]
				39236, -- [3]
				39374, -- [4]
				48170, -- [5]
			},
			["name"] = "Prayer of Shadow Protection",
			["icon"] = 135945,
			["castTime"] = 0,
		},
		["THICKBRONZENECKLACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Thick Bronze Necklace",
			["icon"] = 136243,
			["id"] = {
				26927, -- [1]
			},
		},
		["ENCHANTGLOVESMINORHASTE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13948, -- [1]
				13950, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Gloves - Minor Haste",
		},
		["NERUBIANLEGARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3763,
			["id"] = {
				50902, -- [1]
				50966, -- [2]
			},
			["icon"] = 136247,
			["name"] = "Nerubian Leg Armor",
		},
		["TIGERSEYEBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Tigerseye Band",
			["icon"] = 136243,
			["id"] = {
				32179, -- [1]
			},
		},
		["SCROLLOFAGILITYV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Agility V",
			["icon"] = 132918,
			["id"] = {
				58480, -- [1]
			},
		},
		["HUGETHORIUMBATTLEAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Huge Thorium Battleaxe",
			["icon"] = 135581,
			["id"] = {
				16971, -- [1]
			},
		},
		["WORMHOLEGENERATORNORTHREND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				67920, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Wormhole Generator: Northrend",
		},
		["MAIL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8737, -- [1]
				8738, -- [2]
			},
			["icon"] = 132627,
			["name"] = "Mail",
		},
		["ARTISANFISHING"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Fishing",
			["icon"] = 136245,
			["id"] = {
				18249, -- [1]
				19890, -- [2]
			},
		},
		["GLYPHOFEXECUTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Execution",
			["icon"] = 132918,
			["id"] = {
				57156, -- [1]
				58367, -- [2]
				58405, -- [3]
			},
		},
		["CALLOFTHEANCESTORS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				66843, -- [1]
			},
			["icon"] = 310731,
			["name"] = "Call of the Ancestors",
		},
		["ELEMENTALBLASTINGPOWDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				30303, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Elemental Blasting Powder",
		},
		["BEASTMASTERY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53270, -- [1]
			},
			["icon"] = 236175,
			["name"] = "Beast Mastery",
		},
		["HIGHPOWEREDFLASHLIGHT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "High-powered Flashlight",
			["icon"] = 136243,
			["id"] = {
				63750, -- [1]
			},
		},
		["HANDMOUNTEDPYROROCKET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				54998, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Hand-Mounted Pyro Rocket",
		},
		["DISTRACTINGSHOT"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = -999500,
			["id"] = {
				20736, -- [1]
				14274, -- [2]
				14346, -- [3]
				15629, -- [4]
				15630, -- [5]
				15631, -- [6]
				15632, -- [7]
				15637, -- [8]
				15638, -- [9]
				15639, -- [10]
				15640, -- [11]
				20738, -- [12]
				56559, -- [13]
			},
			["icon"] = 135736,
			["name"] = "Distracting Shot",
		},
		["FIREBREATH"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["id"] = {
				55483, -- [1]
				34889, -- [2]
				35323, -- [3]
				37985, -- [4]
				38309, -- [5]
				55482, -- [6]
				55484, -- [7]
				55485, -- [8]
				59197, -- [9]
			},
			["castTime"] = 0,
			["icon"] = 135789,
			["name"] = "Fire Breath",
		},
		["ELIXIROFDETECTUNDEAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Detect Undead",
			["icon"] = 136243,
			["id"] = {
				11460, -- [1]
				11495, -- [2]
			},
		},
		["RESOLUTEHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53893, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Resolute Huge Citrine",
		},
		["SUPERIORMANAPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Superior Mana Potion",
			["icon"] = 136243,
			["id"] = {
				17553, -- [1]
			},
		},
		["SCROLLOFAGILITYIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Agility III",
			["icon"] = 132918,
			["id"] = {
				58476, -- [1]
			},
		},
		["BIGBRONZEBOMB"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Big Bronze Bomb",
			["icon"] = 136243,
			["id"] = {
				3950, -- [1]
				4010, -- [2]
				4067, -- [3]
			},
		},
		["DRYPORKRIBS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Dry Pork Ribs",
			["icon"] = 134004,
			["id"] = {
				2546, -- [1]
				2563, -- [2]
			},
		},
		["GOUGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1776, -- [1]
				1777, -- [2]
				1780, -- [3]
				1781, -- [4]
				8629, -- [5]
				8630, -- [6]
				11285, -- [7]
				11286, -- [8]
				11287, -- [9]
				11288, -- [10]
				12540, -- [11]
				13579, -- [12]
				24698, -- [13]
				28456, -- [14]
				29425, -- [15]
				34940, -- [16]
				36862, -- [17]
				38764, -- [18]
				38863, -- [19]
			},
			["icon"] = 132155,
			["name"] = "Gouge",
		},
		["THUNDERCLAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Thunder Clap",
			["icon"] = 136105,
			["id"] = {
				6343, -- [1]
				926, -- [2]
				1343, -- [3]
				1344, -- [4]
				3726, -- [5]
				8078, -- [6]
				8147, -- [7]
				8198, -- [8]
				8204, -- [9]
				8205, -- [10]
				8206, -- [11]
				8207, -- [12]
				8732, -- [13]
				11580, -- [14]
				11581, -- [15]
				11582, -- [16]
				11583, -- [17]
				13532, -- [18]
				15548, -- [19]
				15588, -- [20]
				23931, -- [21]
				26554, -- [22]
				25264, -- [23]
				30633, -- [24]
				33967, -- [25]
				36214, -- [26]
				36706, -- [27]
				38537, -- [28]
				43583, -- [29]
				44033, -- [30]
				47501, -- [31]
				47502, -- [32]
				53113, -- [33]
				55635, -- [34]
				57832, -- [35]
				58975, -- [36]
				59217, -- [37]
				60019, -- [38]
				61359, -- [39]
				63757, -- [40]
				69965, -- [41]
			},
		},
		["BLACKCHITINGUARDBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				51568, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Black Chitinguard Boots",
		},
		["TOUGHNESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				12299, -- [1]
				819, -- [2]
				1163, -- [3]
				1164, -- [4]
				1165, -- [5]
				1166, -- [6]
				4527, -- [7]
				4528, -- [8]
				4529, -- [9]
				4530, -- [10]
				4531, -- [11]
				4532, -- [12]
				4533, -- [13]
				4534, -- [14]
				4535, -- [15]
				4536, -- [16]
				4537, -- [17]
				12761, -- [18]
				12762, -- [19]
				12763, -- [20]
				12764, -- [21]
				16252, -- [22]
				16306, -- [23]
				16307, -- [24]
				16308, -- [25]
				16309, -- [26]
				20143, -- [27]
				20144, -- [28]
				20145, -- [29]
				20146, -- [30]
				20147, -- [31]
				49042, -- [32]
				49786, -- [33]
				49787, -- [34]
				49788, -- [35]
				49789, -- [36]
				53040, -- [37]
				53120, -- [38]
				53121, -- [39]
				53122, -- [40]
				53123, -- [41]
				53124, -- [42]
			},
			["icon"] = 135892,
			["name"] = "Toughness",
		},
		["PROSPECTING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				31252, -- [1]
			},
			["icon"] = 134081,
			["name"] = "Prospecting",
		},
		["SHADOWJADEFOCUSINGLENS"] = {
			["maxRange"] = 60,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56191, -- [1]
				56208, -- [2]
			},
			["icon"] = 134072,
			["name"] = "Shadow Jade Focusing Lens",
		},
		["ARCTICGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50947, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Arctic Gloves",
		},
		["THEBLACKPEARL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				41415, -- [1]
			},
			["icon"] = 134071,
			["name"] = "The Black Pearl",
		},
		["EVISCERATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2098, -- [1]
				6712, -- [2]
				6760, -- [3]
				6761, -- [4]
				6762, -- [5]
				6763, -- [6]
				6764, -- [7]
				6765, -- [8]
				8623, -- [9]
				8624, -- [10]
				8625, -- [11]
				8626, -- [12]
				11299, -- [13]
				11300, -- [14]
				11301, -- [15]
				11302, -- [16]
				15691, -- [17]
				15692, -- [18]
				27611, -- [19]
				31016, -- [20]
				31017, -- [21]
				26865, -- [22]
				41177, -- [23]
				46189, -- [24]
				48667, -- [25]
				48668, -- [26]
				57641, -- [27]
				60008, -- [28]
				65957, -- [29]
				67709, -- [30]
				71933, -- [31]
			},
			["icon"] = 132292,
			["name"] = "Eviscerate",
		},
		["GLYPHOFSERPENTSTING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Serpent Sting",
			["icon"] = 136243,
			["id"] = {
				56832, -- [1]
				56884, -- [2]
				57009, -- [3]
			},
		},
		["SMELTIRON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Smelt Iron",
			["icon"] = 136243,
			["id"] = {
				3307, -- [1]
				3316, -- [2]
			},
		},
		["PERSONALELECTROMAGNETICPULSEGENERATOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				54736, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Personal Electromagnetic Pulse Generator",
		},
		["GNOMISHPOULTRYIZER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				30569, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Poultryizer",
		},
		["EMBOSSEDLEATHERGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Embossed Leather Gloves",
			["icon"] = 136247,
			["id"] = {
				3756, -- [1]
				3784, -- [2]
			},
		},
		["RUNEDCOPPERGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Runed Copper Gauntlets",
			["icon"] = 132938,
			["id"] = {
				3323, -- [1]
				3342, -- [2]
			},
		},
		["BLACKMAGEWEAVEROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Black Mageweave Robe",
			["icon"] = 132149,
			["id"] = {
				12050, -- [1]
				12102, -- [2]
			},
		},
		["ARTISANENGINEER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Engineer",
			["icon"] = 136243,
			["id"] = {
				12657, -- [1]
			},
		},
		["GNAW"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				47481, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 237524,
			["name"] = "Gnaw",
		},
		["EYEOFKILROGG"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["id"] = {
				126, -- [1]
				928, -- [2]
				6228, -- [3]
			},
			["name"] = "Eye of Kilrogg",
			["icon"] = 136155,
			["castTime"] = 5000,
		},
		["CATSEYEELIXIR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Catseye Elixir",
			["icon"] = 136243,
			["id"] = {
				12609, -- [1]
				12610, -- [2]
			},
		},
		["DIVINEINTERVENTION"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Divine Intervention",
			["icon"] = 136106,
			["id"] = {
				19752, -- [1]
				19753, -- [2]
				19754, -- [3]
			},
		},
		["SPELLSTEAL"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				30449, -- [1]
			},
			["icon"] = 135729,
			["name"] = "Spellsteal",
		},
		["TWISTINGNETHERCHAINSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34530, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Twisting Nether Chain Shirt",
		},
		["ICEBORNEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50941, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Iceborne Gloves",
		},
		["FROSTSTORMBREATH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				55490, -- [1]
				54644, -- [2]
				54689, -- [3]
				55488, -- [4]
				55489, -- [5]
				55491, -- [6]
				55492, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 136048,
			["name"] = "Froststorm Breath",
		},
		["MASTERLEATHERWORKER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				32550, -- [1]
			},
			["icon"] = 133611,
			["name"] = "Master Leatherworker",
		},
		["MOONSHROUD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56001, -- [1]
			},
			["icon"] = 132149,
			["name"] = "Moonshroud",
		},
		["IRONGRENADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Iron Grenade",
			["icon"] = 136243,
			["id"] = {
				3962, -- [1]
				4018, -- [2]
				4068, -- [3]
			},
		},
		["GOBLINSAPPERCHARGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12760, -- [1]
				12771, -- [2]
				13241, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Goblin Sapper Charge",
		},
		["BLOODTHIRSTY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53187, -- [1]
				53186, -- [2]
				54131, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 132139,
			["name"] = "Bloodthirsty",
		},
		["SONICBLAST"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["id"] = {
				53567, -- [1]
				29300, -- [2]
				50519, -- [3]
				53564, -- [4]
				53565, -- [5]
				53566, -- [6]
				53568, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 132182,
			["name"] = "Sonic Blast",
		},
		["TOTEMICRECALL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				36936, -- [1]
				39104, -- [2]
			},
			["icon"] = 310733,
			["name"] = "Totemic Recall",
		},
		["ENCHANTSHIELDLESSERSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13631, -- [1]
				13634, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Shield - Lesser Stamina",
		},
		["FURIOUSSARONITEBEATSTICK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55182, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Furious Saronite Beatstick",
		},
		["FROSTTRAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				13809, -- [1]
				13811, -- [2]
				63487, -- [3]
				67035, -- [4]
				72215, -- [5]
				72216, -- [6]
				65880, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 135840,
			["name"] = "Frost Trap",
		},
		["GLYPHOFBACKSTAB"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Backstab",
			["icon"] = 136243,
			["id"] = {
				56800, -- [1]
				57114, -- [2]
				57141, -- [3]
			},
		},
		["MAMMOTHCUTTERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56474, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Mammoth Cutters",
		},
		["THORIUMSHELLS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Thorium Shells",
			["icon"] = 136243,
			["id"] = {
				19800, -- [1]
			},
		},
		["ARTISANSKINNER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Skinner",
			["icon"] = 134366,
			["id"] = {
				10769, -- [1]
			},
		},
		["DEFTHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53880, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Deft Huge Citrine",
		},
		["GLYPHOFSHADOWBOLT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Shadow Bolt",
			["icon"] = 136243,
			["id"] = {
				56240, -- [1]
				56294, -- [2]
				57271, -- [3]
			},
		},
		["MANUALOFCLOUDS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Manual of Clouds",
			["icon"] = 132918,
			["id"] = {
				59494, -- [1]
			},
		},
		["AVENGINGWRATH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Avenging Wrath",
			["icon"] = 135875,
			["id"] = {
				31884, -- [1]
				43430, -- [2]
				50837, -- [3]
				66011, -- [4]
			},
		},
		["HANDSTITCHEDLEATHERBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Handstitched Leather Belt",
			["icon"] = 136247,
			["id"] = {
				3753, -- [1]
				3782, -- [2]
			},
		},
		["DAWNSTARINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Dawnstar Ink",
			["icon"] = 132918,
			["id"] = {
				57706, -- [1]
			},
		},
		["HEROICSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Heroic Strike",
			["icon"] = 132282,
			["id"] = {
				78, -- [1]
				284, -- [2]
				285, -- [3]
				1605, -- [4]
				1606, -- [5]
				1607, -- [6]
				1608, -- [7]
				1610, -- [8]
				1611, -- [9]
				6158, -- [10]
				11564, -- [11]
				11565, -- [12]
				11566, -- [13]
				11567, -- [14]
				11570, -- [15]
				11571, -- [16]
				25286, -- [17]
				25354, -- [18]
				25710, -- [19]
				25712, -- [20]
				25958, -- [21]
				29426, -- [22]
				29567, -- [23]
				29707, -- [24]
				30324, -- [25]
				31827, -- [26]
				41975, -- [27]
				45026, -- [28]
				47449, -- [29]
				47450, -- [30]
				52221, -- [31]
				53395, -- [32]
				57846, -- [33]
				59035, -- [34]
				59607, -- [35]
				62444, -- [36]
				69566, -- [37]
			},
		},
		["HOWLOFTERROR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				5484, -- [1]
				5486, -- [2]
				17928, -- [3]
				18169, -- [4]
				39048, -- [5]
				50577, -- [6]
			},
			["name"] = "Howl of Terror",
			["icon"] = 136147,
			["castTime"] = 1500,
		},
		["BACKSTAB"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53, -- [1]
				2589, -- [2]
				2590, -- [3]
				2591, -- [4]
				2592, -- [5]
				2593, -- [6]
				2594, -- [7]
				2595, -- [8]
				7159, -- [9]
				8721, -- [10]
				8723, -- [11]
				11279, -- [12]
				11280, -- [13]
				11281, -- [14]
				11282, -- [15]
				11283, -- [16]
				11284, -- [17]
				15582, -- [18]
				15657, -- [19]
				22416, -- [20]
				25300, -- [21]
				25411, -- [22]
				25973, -- [23]
				26863, -- [24]
				30992, -- [25]
				34614, -- [26]
				37685, -- [27]
				48656, -- [28]
				48657, -- [29]
				52540, -- [30]
				58471, -- [31]
				63754, -- [32]
				72427, -- [33]
				71410, -- [34]
			},
			["icon"] = 132090,
			["name"] = "Backstab",
		},
		["EMERALDLIONRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Emerald Lion Ring",
			["icon"] = 134072,
			["id"] = {
				34961, -- [1]
			},
		},
		["COARSEGRINDINGSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Coarse Grinding Stone",
			["icon"] = 135244,
			["id"] = {
				3326, -- [1]
				3344, -- [2]
			},
		},
		["BLOODPLAGUE"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55078, -- [1]
				55264, -- [2]
				55322, -- [3]
				55973, -- [4]
				57601, -- [5]
				58840, -- [6]
				58844, -- [7]
				59879, -- [8]
				59984, -- [9]
				60950, -- [10]
				61111, -- [11]
				61601, -- [12]
				67722, -- [13]
				71923, -- [14]
				69911, -- [15]
			},
			["icon"] = 237514,
			["name"] = "Blood Plague",
		},
		["ENCHANTBRACERGREATERINTELLECT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				20008, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Greater Intellect",
		},
		["GHOSTWOLF"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1882,
			["id"] = {
				2645, -- [1]
				519, -- [2]
				3691, -- [3]
				5387, -- [4]
				5389, -- [5]
				45528, -- [6]
				47133, -- [7]
				67116, -- [8]
			},
			["icon"] = 136095,
			["name"] = "Ghost Wolf",
		},
		["GRANDMASTERBLACKSMITH"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				51298, -- [1]
				65282, -- [2]
			},
			["icon"] = 136241,
			["name"] = "Grand Master Blacksmith",
		},
		["CREATESOULSTONEMAJOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				20757, -- [1]
				20769, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 136210,
			["name"] = "Create Soulstone (Major)",
		},
		["GRANDMASTERHERBALIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				50301, -- [1]
				65288, -- [2]
			},
			["icon"] = 136246,
			["name"] = "Grand Master Herbalist",
		},
		["GREENLEATHERBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Green Leather Belt",
			["icon"] = 136247,
			["id"] = {
				3774, -- [1]
				3795, -- [2]
			},
		},
		["GLYPHOFCRUSADERSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Crusader Strike",
			["icon"] = 136243,
			["id"] = {
				54927, -- [1]
				55113, -- [2]
				57024, -- [3]
			},
		},
		["RUNEOFCINDERGLACIER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				53341, -- [1]
			},
			["icon"] = 136130,
			["name"] = "Rune of Cinderglacier",
		},
		["RESURGENTHEALINGPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53838, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Resurgent Healing Potion",
		},
		["THICKARMORKIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Thick Armor Kit",
			["icon"] = 136247,
			["id"] = {
				10487, -- [1]
				10655, -- [2]
			},
		},
		["RIPTIDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				22419, -- [1]
				61295, -- [2]
				61299, -- [3]
				61300, -- [4]
				61301, -- [5]
				66053, -- [6]
				75367, -- [7]
			},
			["icon"] = 132343,
			["name"] = "Riptide",
		},
		["MASTERHERBALIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				28696, -- [1]
			},
			["icon"] = 136246,
			["name"] = "Master Herbalist",
		},
		["HEALINGPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Healing Potion",
			["icon"] = 136243,
			["id"] = {
				439, -- [1]
				440, -- [2]
				441, -- [3]
				2024, -- [4]
				3447, -- [5]
				3458, -- [6]
				4042, -- [7]
				17534, -- [8]
				28495, -- [9]
				40535, -- [10]
				41619, -- [11]
				41620, -- [12]
				43185, -- [13]
				53144, -- [14]
				53670, -- [15]
				54572, -- [16]
				58862, -- [17]
			},
		},
		["MAMMOTHMEAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45549, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Mammoth Meal",
		},
		["ENCHANTBRACERINTELLECT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13822, -- [1]
				13829, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Intellect",
		},
		["GNOMISHARMYKNIFE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56462, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Army Knife",
		},
		["HANDFULOFCOPPERBOLTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Handful of Copper Bolts",
			["icon"] = 136243,
			["id"] = {
				3922, -- [1]
				3984, -- [2]
			},
		},
		["UNSTABLETRIGGER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Unstable Trigger",
			["icon"] = 136243,
			["id"] = {
				12591, -- [1]
				12633, -- [2]
			},
		},
		["ENCHANTSHIELDGREATERSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13905, -- [1]
				13906, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Shield - Greater Spirit",
		},
		["RAZORSTRIKEBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60649, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Razorstrike Breastplate",
		},
		["DARKLEATHERPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Dark Leather Pants",
			["icon"] = 136247,
			["id"] = {
				7135, -- [1]
				7146, -- [2]
			},
		},
		["CALLSTABLEDPET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				62757, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 132599,
			["name"] = "Call Stabled Pet",
		},
		["DEMONICCIRCLESUMMON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				48018, -- [1]
			},
			["name"] = "Demonic Circle: Summon",
			["icon"] = 237559,
			["castTime"] = 500,
		},
		["JUDGEMENTOFLIGHT"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Judgement of Light",
			["icon"] = 135959,
			["id"] = {
				20185, -- [1]
				20267, -- [2]
				20341, -- [3]
				20342, -- [4]
				20343, -- [5]
				20344, -- [6]
				20345, -- [7]
				20346, -- [8]
				25752, -- [9]
				25753, -- [10]
				28775, -- [11]
				--20271, -- [12]
				57774, -- [13]
			},
		},
		["SEALOFJUSTICE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Seal of Justice",
			["icon"] = 135971,
			["id"] = {
				20164, -- [1]
				20462, -- [2]
			},
		},
		["CLOAKOFCRIMSONSNOW"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				64730, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Cloak of Crimson Snow",
		},
		["ELIXIROFDETECTDEMON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Detect Demon",
			["icon"] = 136243,
			["id"] = {
				11478, -- [1]
				11501, -- [2]
			},
		},
		["FROSTSAVAGEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59585, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostsavage Boots",
		},
		["DISEASECLEANSINGTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				8170, -- [1]
				8173, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 136019,
			["name"] = "Disease Cleansing Totem",
		},
		["FIREBOLT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				47964, -- [1]
				701, -- [2]
				1370, -- [3]
				3110, -- [4]
				7799, -- [5]
				7800, -- [6]
				7801, -- [7]
				7802, -- [8]
				7832, -- [9]
				7833, -- [10]
				7834, -- [11]
				7835, -- [12]
				7886, -- [13]
				9057, -- [14]
				9233, -- [15]
				11762, -- [16]
				11763, -- [17]
				11764, -- [18]
				11765, -- [19]
				13441, -- [20]
				13442, -- [21]
				14103, -- [22]
				15592, -- [23]
				15598, -- [24]
				15599, -- [25]
				18083, -- [26]
				18086, -- [27]
				18112, -- [28]
				18186, -- [29]
				18187, -- [30]
				18833, -- [31]
				20270, -- [32]
				20312, -- [33]
				20313, -- [34]
				20314, -- [35]
				20315, -- [36]
				20316, -- [37]
				20801, -- [38]
				23267, -- [39]
				27267, -- [40]
				27487, -- [41]
				30050, -- [42]
				30180, -- [43]
				36227, -- [44]
				36905, -- [45]
				36906, -- [46]
				38239, -- [47]
				39022, -- [48]
				39023, -- [49]
				43584, -- [50]
				44164, -- [51]
				44577, -- [52]
				46044, -- [53]
				47965, -- [54]
				54235, -- [55]
				59468, -- [56]
				62669, -- [57]
			},
			["castTime"] = 2373,
			["icon"] = 135809,
			["name"] = "Firebolt",
		},
		["SPELLPOWERGOGGLESXTREME"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Spellpower Goggles Xtreme",
			["icon"] = 136243,
			["id"] = {
				12615, -- [1]
			},
		},
		["PENANCE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				47540, -- [1]
				47666, -- [2]
				47750, -- [3]
				47757, -- [4]
				47758, -- [5]
				52983, -- [6]
				52984, -- [7]
				52985, -- [8]
				52986, -- [9]
				52987, -- [10]
				52988, -- [11]
				52998, -- [12]
				52999, -- [13]
				53000, -- [14]
				53001, -- [15]
				53002, -- [16]
				53003, -- [17]
				53005, -- [18]
				53006, -- [19]
				53007, -- [20]
				54518, -- [21]
				54520, -- [22]
				71139, -- [23]
				66097, -- [24]
				66098, -- [25]
				69905, -- [26]
				69906, -- [27]
			},
			["name"] = "Penance",
			["icon"] = 237545,
			["castTime"] = 0,
		},
		["CORNERED"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53497, -- [1]
				52234, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132214,
			["name"] = "Cornered",
		},
		["GNOMISHSHRINKRAY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12899, -- [1]
				12911, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Shrink Ray",
		},
		["SMELTETERNIUM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				29359, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Smelt Eternium",
		},
		["FROSTWOVENBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55906, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostwoven Boots",
		},
		["ARMORVELLUMIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				59500, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Armor Vellum III",
		},
		["MASTERFISHING"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 18816,
			["id"] = {
				33100, -- [1]
				54084, -- [2]
			},
			["icon"] = 136245,
			["name"] = "Master Fishing",
		},
		["LONGSILKENCLOAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Long Silken Cloak",
			["icon"] = 132149,
			["id"] = {
				3861, -- [1]
				3889, -- [2]
			},
		},
		["GLYPHOFARCANEMISSILES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Arcane Missiles",
			["icon"] = 136243,
			["id"] = {
				56363, -- [1]
				56542, -- [2]
				56971, -- [3]
			},
		},
		["STORMBOUNDTOME"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Stormbound Tome",
			["icon"] = 132918,
			["id"] = {
				59493, -- [1]
			},
		},
		["NATURALARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				61689, -- [1]
				24545, -- [2]
				24547, -- [3]
				24548, -- [4]
				24549, -- [5]
				24550, -- [6]
				24551, -- [7]
				24552, -- [8]
				24553, -- [9]
				24554, -- [10]
				24555, -- [11]
				24556, -- [12]
				24557, -- [13]
				24558, -- [14]
				24559, -- [15]
				24560, -- [16]
				24561, -- [17]
				24562, -- [18]
				24563, -- [19]
				24565, -- [20]
				24566, -- [21]
				24567, -- [22]
				24568, -- [23]
				24569, -- [24]
				24570, -- [25]
				24629, -- [26]
				24630, -- [27]
				24631, -- [28]
				24632, -- [29]
				24633, -- [30]
				24634, -- [31]
				27362, -- [32]
				61690, -- [33]
			},
			["castTime"] = 0,
			["icon"] = 136094,
			["name"] = "Natural Armor",
		},
		["CARRIONFEEDER"] = {
			["maxRange"] = 5,
			["minRange"] = 0,
			["id"] = {
				54044, -- [1]
				54045, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132278,
			["name"] = "Carrion Feeder",
		},
		["MASTERMINER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				29355, -- [1]
			},
			["icon"] = 136248,
			["name"] = "Master Miner",
		},
		["ENCHANTEDPEARL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				56530, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Enchanted Pearl",
		},
		["GREATERBLESSINGOFWISDOM"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Greater Blessing of Wisdom",
			["icon"] = 135912,
			["id"] = {
				25894, -- [1]
				25918, -- [2]
				25919, -- [3]
				25920, -- [4]
				27143, -- [5]
				48937, -- [6]
				48938, -- [7]
			},
		},
		["GLYPHOFFROSTTRAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56847, -- [1]
				56878, -- [2]
				57003, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Frost Trap",
		},
		["FELIRONROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				32655, -- [1]
			},
			["icon"] = 134926,
			["name"] = "Fel Iron Rod",
		},
		["EMBOSSEDLEATHERBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Embossed Leather Boots",
			["icon"] = 136247,
			["id"] = {
				2161, -- [1]
				2177, -- [2]
			},
		},
		["DEFENSE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Defense",
			["icon"] = 132279,
			["id"] = {
				204, -- [1]
				62157, -- [2]
			},
		},
		["GNOMISHHARMPREVENTIONBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				12903, -- [1]
				12914, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Harm Prevention Belt",
		},
		["BOLTOFIMBUEDFROSTWEAVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55900, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Bolt of Imbued Frostweave",
		},
		["TRANQUILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Tranquility",
			["icon"] = 136107,
			["id"] = {
				740, -- [1]
				792, -- [2]
				1439, -- [3]
				8918, -- [4]
				8920, -- [5]
				9862, -- [6]
				9863, -- [7]
				9864, -- [8]
				9865, -- [9]
				21791, -- [10]
				25817, -- [11]
				26983, -- [12]
				34550, -- [13]
				38659, -- [14]
				44203, -- [15]
				44205, -- [16]
				44206, -- [17]
				44207, -- [18]
				44208, -- [19]
				48444, -- [20]
				48445, -- [21]
				48446, -- [22]
				48447, -- [23]
				51972, -- [24]
				57054, -- [25]
				63241, -- [26]
				63554, -- [27]
				66086, -- [28]
			},
		},
		["DAZZLINGDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53926, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Dazzling Dark Jade",
		},
		["BOLTOFFROSTWEAVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				55899, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Bolt of Frostweave",
		},
		["MOONCLEAVER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34544, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Mooncleaver",
		},
		["CUREDTHICKHIDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Cured Thick Hide",
			["icon"] = 136247,
			["id"] = {
				10482, -- [1]
				10485, -- [2]
			},
		},
		["IMMOLATIONTRAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				13795, -- [1]
				13799, -- [2]
				14302, -- [3]
				14303, -- [4]
				14304, -- [5]
				14305, -- [6]
				14364, -- [7]
				14365, -- [8]
				14366, -- [9]
				14367, -- [10]
				22910, -- [11]
				13797, -- [12]
				14298, -- [13]
				14299, -- [14]
				14300, -- [15]
				14301, -- [16]
				27023, -- [17]
				27024, -- [18]
				47784, -- [19]
				49053, -- [20]
				49054, -- [21]
				49055, -- [22]
				49056, -- [23]
				52606, -- [24]
			},
			["icon"] = 135813,
			["name"] = "Immolation Trap",
		},
		["SPRINT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				2983, -- [1]
				2984, -- [2]
				8696, -- [3]
				8697, -- [4]
				11305, -- [5]
				11318, -- [6]
				26542, -- [7]
				26543, -- [8]
				32720, -- [9]
				48594, -- [10]
				56354, -- [11]
				61922, -- [12]
			},
			["castTime"] = 0,
			["icon"] = 132307,
			["name"] = "Sprint",
		},
		["SMELTTHORIUM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Smelt Thorium",
			["icon"] = 136243,
			["id"] = {
				16153, -- [1]
				16154, -- [2]
			},
		},
		["JOURNEYMANSKINNER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Skinner",
			["icon"] = 134366,
			["id"] = {
				8619, -- [1]
			},
		},
		["LACERATE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Lacerate",
			["icon"] = 136231,
			["id"] = {
				5422, -- [1]
				33745, -- [2]
				48567, -- [3]
				48568, -- [4]
				52504, -- [5]
				61896, -- [6]
			},
		},
		["NERUBIANBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50961, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Nerubian Belt",
		},
		["GRILLEDBONESCALE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45561, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Grilled Bonescale",
		},
		["SCROLLOFSTAMINAIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Stamina III",
			["icon"] = 132918,
			["id"] = {
				50614, -- [1]
			},
		},
		["HORNOFWINTER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				57330, -- [1]
				57623, -- [2]
			},
			["icon"] = 134228,
			["name"] = "Horn of Winter",
		},
		["MEDIUMLEATHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Medium Leather",
			["icon"] = 136243,
			["id"] = {
				20648, -- [1]
				20651, -- [2]
			},
		},
		["SERPENTSTING"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = -999500,
			["id"] = {
				1978, -- [1]
				2003, -- [2]
				13549, -- [3]
				13550, -- [4]
				13551, -- [5]
				13552, -- [6]
				13553, -- [7]
				13554, -- [8]
				13555, -- [9]
				13556, -- [10]
				13557, -- [11]
				13558, -- [12]
				13559, -- [13]
				13560, -- [14]
				13561, -- [15]
				13562, -- [16]
				25295, -- [17]
				25405, -- [18]
				25968, -- [19]
				27016, -- [20]
				31975, -- [21]
				35511, -- [22]
				36984, -- [23]
				38859, -- [24]
				38914, -- [25]
				39182, -- [26]
				49000, -- [27]
				49001, -- [28]
			},
			["icon"] = 132204,
			["name"] = "Serpent Sting",
		},
		["FROSTSCALELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50951, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Frostscale Leggings",
		},
		["ENCHANTCHESTLESSERSTATS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13700, -- [1]
				13701, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Lesser Stats",
		},
		["MINORINSCRIPTIONRESEARCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Minor Inscription Research",
			["icon"] = 237171,
			["id"] = {
				61288, -- [1]
			},
		},
		["MOBILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53555, -- [1]
				53483, -- [2]
				53485, -- [3]
				53554, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 132158,
			["name"] = "Mobility",
		},
		["LINENBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Linen Belt",
			["icon"] = 132149,
			["id"] = {
				8776, -- [1]
				8777, -- [2]
			},
		},
		["LIGHTNINGSHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				324, -- [1]
				325, -- [2]
				532, -- [3]
				557, -- [4]
				905, -- [5]
				906, -- [6]
				945, -- [7]
				946, -- [8]
				1303, -- [9]
				1304, -- [10]
				1305, -- [11]
				1363, -- [12]
				8134, -- [13]
				8135, -- [14]
				8788, -- [15]
				10431, -- [16]
				10432, -- [17]
				10433, -- [18]
				10434, -- [19]
				12550, -- [20]
				13585, -- [21]
				15507, -- [22]
				19514, -- [23]
				20545, -- [24]
				23551, -- [25]
				23552, -- [26]
				25020, -- [27]
				26363, -- [28]
				26364, -- [29]
				26365, -- [30]
				26366, -- [31]
				26367, -- [32]
				26369, -- [33]
				26370, -- [34]
				26545, -- [35]
				27635, -- [36]
				28820, -- [37]
				28821, -- [38]
				25469, -- [39]
				25472, -- [40]
				26371, -- [41]
				26372, -- [42]
				31765, -- [43]
				39067, -- [44]
				41151, -- [45]
				49278, -- [46]
				49279, -- [47]
				49280, -- [48]
				49281, -- [49]
				50831, -- [50]
				51620, -- [51]
				51776, -- [52]
				52651, -- [53]
				56221, -- [54]
				59025, -- [55]
				59845, -- [56]
				61570, -- [57]
				69698, -- [58]
				75381, -- [59]
			},
			["icon"] = 136051,
			["name"] = "Lightning Shield",
		},
		["CHAINSOFICE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				113, -- [1]
				485, -- [2]
				512, -- [3]
				520, -- [4]
				1175, -- [5]
				1208, -- [6]
				22744, -- [7]
				22745, -- [8]
				29991, -- [9]
				39268, -- [10]
				45524, -- [11]
				47805, -- [12]
				53534, -- [13]
				58464, -- [14]
				61077, -- [15]
				66020, -- [16]
				72171, -- [17]
			},
			["icon"] = 135834,
			["name"] = "Chains of Ice",
		},
		["GLYPHOFEVISCERATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Eviscerate",
			["icon"] = 136243,
			["id"] = {
				56802, -- [1]
				57120, -- [2]
				57147, -- [3]
			},
		},
		["KHORIUMPOWERCORE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				30308, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Khorium Power Core",
		},
		["AZURESILKPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Azure Silk Pants",
			["icon"] = 132149,
			["id"] = {
				8758, -- [1]
				8759, -- [2]
			},
		},
		["STONESKINTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8071, -- [1]
				8073, -- [2]
				8154, -- [3]
				8155, -- [4]
				8158, -- [5]
				8159, -- [6]
				10406, -- [7]
				10407, -- [8]
				10408, -- [9]
				10409, -- [10]
				10410, -- [11]
				10411, -- [12]
				25508, -- [13]
				25509, -- [14]
				38115, -- [15]
				58751, -- [16]
				58753, -- [17]
			},
			["icon"] = 136098,
			["name"] = "Stoneskin Totem",
		},
		["FIERCEHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53876, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Fierce Huge Citrine",
		},
		["SPIDERSBITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53205, -- [1]
				53203, -- [2]
				53204, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 132196,
			["name"] = "Spider's Bite",
		},
		["GLYPHOFMONSOON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Monsoon",
			["icon"] = 136243,
			["id"] = {
				63056, -- [1]
				63739, -- [2]
				64258, -- [3]
			},
		},
		["TITANIUMSHIELDSPIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				56353, -- [1]
				56355, -- [2]
				56357, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Titanium Shield Spike",
		},
		["DREADSTEED"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				23161, -- [1]
			},
			["name"] = "Dreadsteed",
			["icon"] = 132238,
			["castTime"] = 1500,
		},
		["ORNATESARONITEPAULDRONS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56550, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Ornate Saronite Pauldrons",
		},
		["SENSEDEMONS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				5500, -- [1]
				1017, -- [2]
				5501, -- [3]
				47524, -- [4]
			},
			["name"] = "Sense Demons",
			["icon"] = 136172,
			["castTime"] = 0,
		},
		["DARKLEATHERBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Dark Leather Belt",
			["icon"] = 136247,
			["id"] = {
				3766, -- [1]
				3792, -- [2]
			},
		},
		["CLOAKOFFROZENSPIRITS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56015, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Cloak of Frozen Spirits",
		},
		["COPPERCHAINBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Copper Chain Belt",
			["icon"] = 132491,
			["id"] = {
				2661, -- [1]
				2744, -- [2]
			},
		},
		["GOLDENSKELETONKEY"] = {
			["maxRange"] = 5,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Golden Skeleton Key",
			["icon"] = 136243,
			["id"] = {
				19649, -- [1]
				19667, -- [2]
				19671, -- [3]
			},
		},
		["FROSTSTEELTUBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56471, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Froststeel Tube",
		},
		["RADIANTDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53931, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Radiant Dark Jade",
		},
		["DISPELMAGIC"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				527, -- [1]
				615, -- [2]
				988, -- [3]
				989, -- [4]
				1283, -- [5]
				1284, -- [6]
				15090, -- [7]
				16908, -- [8]
				17201, -- [9]
				19476, -- [10]
				19477, -- [11]
				21076, -- [12]
				23859, -- [13]
				27609, -- [14]
				43577, -- [15]
				63499, -- [16]
				65546, -- [17]
			},
			["name"] = "Dispel Magic",
			["icon"] = 135894,
			["castTime"] = 0,
		},
		["SIMPLEBLACKDRESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Simple Black Dress",
			["icon"] = 132149,
			["id"] = {
				12077, -- [1]
				12122, -- [2]
			},
		},
		["HUDDLE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				47484, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 136187,
			["name"] = "Huddle",
		},
		["GLYPHOFSCOURGEIMPRISONMENT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55690, -- [1]
				56179, -- [2]
				57198, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Scourge Imprisonment",
		},
		["ENCHANTBOOTSSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13836, -- [1]
				13837, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Boots - Stamina",
		},
		["ENCHANTBOOTSAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13935, -- [1]
				13936, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Boots - Agility",
		},
		["RETALIATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Retaliation",
			["icon"] = 132336,
			["id"] = {
				20230, -- [1]
				20240, -- [2]
				20724, -- [3]
				22857, -- [4]
				22858, -- [5]
				40546, -- [6]
				52423, -- [7]
				52424, -- [8]
				65932, -- [9]
				65934, -- [10]
			},
		},
		["SEALOFCOMMAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				20375, -- [1]
				20424, -- [2]
				20915, -- [3]
				20918, -- [4]
				20919, -- [5]
				20920, -- [6]
				20944, -- [7]
				20945, -- [8]
				20946, -- [9]
				20947, -- [10]
				29385, -- [11]
				33127, -- [12]
				41469, -- [13]
				42058, -- [14]
				57769, -- [15]
				57770, -- [16]
				66004, -- [17]
				69403, -- [18]
			},
			["castTime"] = 0,
			["icon"] = 132347,
			["name"] = "Seal of Command",
		},
		["ROASTEDWORG"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45552, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Roasted Worg",
		},
		["ENCHANTBRACERLESSERINTELLECT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13622, -- [1]
				13623, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Lesser Intellect",
		},
		["ETHEREALOIL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				62408, -- [1]
				62409, -- [2]
			},
			["icon"] = 132798,
			["name"] = "Ethereal Oil",
		},
		["RUNEDCOPPERBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Runed Copper Belt",
			["icon"] = 132492,
			["id"] = {
				2666, -- [1]
				2747, -- [2]
			},
		},
		["BLOODOFTHERHINO"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53481, -- [1]
				53482, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 136168,
			["name"] = "Blood of the Rhino",
		},
		["WOOLENCAPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Woolen Cape",
			["icon"] = 136249,
			["id"] = {
				2402, -- [1]
				2423, -- [2]
			},
		},
		["FRENZIEDREGENERATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Frenzied Regeneration",
			["icon"] = 132091,
			["id"] = {
				22842, -- [1]
				22845, -- [2]
				22894, -- [3]
				22895, -- [4]
				22896, -- [5]
				22897, -- [6]
				22898, -- [7]
			},
		},
		["ARTISANRIDING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				34091, -- [1]
				34093, -- [2]
			},
			["icon"] = 136103,
			["name"] = "Artisan Riding",
		},
		["WICKEDHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53886, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Wicked Huge Citrine",
		},
		["MINDFREEZE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				47528, -- [1]
				53550, -- [2]
			},
			["icon"] = 237527,
			["name"] = "Mind Freeze",
		},
		["DREAMWEAVEVEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Dreamweave Vest",
			["icon"] = 132149,
			["id"] = {
				12070, -- [1]
				12113, -- [2]
			},
		},
		["SARONITERAZORHEADS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56475, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Saronite Razorheads",
		},
		["CRUSADERAURA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Crusader Aura",
			["icon"] = 135890,
			["id"] = {
				32223, -- [1]
			},
		},
		["ROYALINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Royal Ink",
			["icon"] = 132918,
			["id"] = {
				57708, -- [1]
			},
		},
		["ARCANITESKELETONKEY"] = {
			["maxRange"] = 5,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Arcanite Skeleton Key",
			["icon"] = 136243,
			["id"] = {
				19657, -- [1]
				19669, -- [2]
				19673, -- [3]
				20709, -- [4]
			},
		},
		["ENCHANTEDTEAR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				56531, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Enchanted Tear",
		},
		["ARMORVELLUMII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Armor Vellum II",
			["icon"] = 132918,
			["id"] = {
				59499, -- [1]
			},
		},
		["FLASKOFTHEFROSTWYRM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53755, -- [1]
				53901, -- [2]
			},
			["icon"] = 236878,
			["name"] = "Flask of the Frost Wyrm",
		},
		["FELIRONBLOODRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				31048, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Fel Iron Blood Ring",
		},
		["CLOAKOFTORMENTEDSKIES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55199, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Cloak of Tormented Skies",
		},
		["REINCARNATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				20608, -- [1]
				20613, -- [2]
				21169, -- [3]
				27740, -- [4]
			},
			["icon"] = 136080,
			["name"] = "Reincarnation",
		},
		["SCORCH"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1811, -- [1]
				2948, -- [2]
				8444, -- [3]
				8445, -- [4]
				8446, -- [5]
				8447, -- [6]
				8448, -- [7]
				8449, -- [8]
				10205, -- [9]
				10206, -- [10]
				10207, -- [11]
				10208, -- [12]
				10209, -- [13]
				10210, -- [14]
				13878, -- [15]
				15241, -- [16]
				17195, -- [17]
				27073, -- [18]
				27074, -- [19]
				27375, -- [20]
				27376, -- [21]
				35377, -- [22]
				36807, -- [23]
				38391, -- [24]
				38636, -- [25]
				42858, -- [26]
				42859, -- [27]
				47723, -- [28]
				50183, -- [29]
				56938, -- [30]
				62546, -- [31]
				62548, -- [32]
				62549, -- [33]
				62551, -- [34]
				62553, -- [35]
				63473, -- [36]
				63474, -- [37]
				63475, -- [38]
				63476, -- [39]
				75412, -- [40]
			},
			["icon"] = 135827,
			["name"] = "Scorch",
		},
		["RIGIDSUNCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53854, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Rigid Sun Crystal",
		},
		["SCROLLOFINTELLECTVII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50603, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Intellect VII",
		},
		["ENCHANTCHESTSUPERIORHEALTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13858, -- [1]
				13861, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Superior Health",
		},
		["THEHUMANSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "The Human Spirit",
			["icon"] = 132874,
			["id"] = {
				20598, -- [1]
			},
		},
		["LESSERMANAPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Lesser Mana Potion",
			["icon"] = 136243,
			["id"] = {
				3173, -- [1]
				3181, -- [2]
			},
		},
		["BOLTOFSILKCLOTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Bolt of Silk Cloth",
			["icon"] = 136243,
			["id"] = {
				3839, -- [1]
			},
		},
		["GLYPHOFSINISTERSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Sinister Strike",
			["icon"] = 136130,
			["id"] = {
				56821, -- [1]
				57131, -- [2]
				57302, -- [3]
			},
		},
		["BRILLIANTTITANSTEELTREADS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55377, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Brilliant Titansteel Treads",
		},
		["UNENDINGBREATH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				5697, -- [1]
				5698, -- [2]
			},
			["name"] = "Unending Breath",
			["icon"] = 136148,
			["castTime"] = 0,
		},
		["MARKOFTHEWILD"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Mark of the Wild",
			["icon"] = 136078,
			["id"] = {
				1126, -- [1]
				5231, -- [2]
				5232, -- [3]
				5233, -- [4]
				5234, -- [5]
				5235, -- [6]
				5285, -- [7]
				5286, -- [8]
				5287, -- [9]
				5310, -- [10]
				6756, -- [11]
				6782, -- [12]
				8907, -- [13]
				8908, -- [14]
				9884, -- [15]
				9885, -- [16]
				9886, -- [17]
				9887, -- [18]
				16878, -- [19]
				24752, -- [20]
				26990, -- [21]
				39233, -- [22]
				48469, -- [23]
			},
		},
		["BOREANARMORKIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				50906, -- [1]
				50962, -- [2]
			},
			["icon"] = 136247,
			["name"] = "Borean Armor Kit",
		},
		["CYCLONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Cyclone",
			["icon"] = 136018,
			["id"] = {
				29538, -- [1]
				5197, -- [2]
				5199, -- [3]
				32334, -- [4]
				33786, -- [5]
				38516, -- [6]
				38517, -- [7]
				39594, -- [8]
				40578, -- [9]
				43120, -- [10]
				43121, -- [11]
				43528, -- [12]
				60236, -- [13]
				61662, -- [14]
				62632, -- [15]
				62633, -- [16]
				69699, -- [17]
				65859, -- [18]
			},
		},
		["NATURERESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Nature Resistance",
			["icon"] = 135865,
			["id"] = {
				4081, -- [1]
				848, -- [2]
				1331, -- [3]
				10596, -- [4]
				10598, -- [5]
				10599, -- [6]
				20551, -- [7]
				20583, -- [8]
				24492, -- [9]
				24494, -- [10]
				24502, -- [11]
				24503, -- [12]
				24504, -- [13]
				24511, -- [14]
				24512, -- [15]
				24513, -- [16]
				24517, -- [17]
				24523, -- [18]
				24524, -- [19]
				24525, -- [20]
				27538, -- [21]
				28768, -- [22]
				25573, -- [23]
				27055, -- [24]
				27354, -- [25]
				58748, -- [26]
				58750, -- [27]
			},
		},
		["ANTIMAGICSHELL"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				31662, -- [1]
				48707, -- [2]
				49088, -- [3]
				53766, -- [4]
			},
			["icon"] = 136120,
			["name"] = "Anti-Magic Shell",
		},
		["VEILEDHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53883, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Veiled Huge Citrine",
		},
		["LIFETAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1454, -- [1]
				1455, -- [2]
				1456, -- [3]
				1476, -- [4]
				1477, -- [5]
				1478, -- [6]
				3095, -- [7]
				3096, -- [8]
				3097, -- [9]
				4090, -- [10]
				11687, -- [11]
				11688, -- [12]
				11689, -- [13]
				11690, -- [14]
				11691, -- [15]
				11692, -- [16]
				28830, -- [17]
				31818, -- [18]
				27222, -- [19]
				32553, -- [20]
				57946, -- [21]
				63321, -- [22]
			},
			["icon"] = 136126,
			["name"] = "Life Tap",
		},
		["AVENGERSSHIELD"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Avenger's Shield",
			["icon"] = 135874,
			["id"] = {
				31935, -- [1]
				32674, -- [2]
				32699, -- [3]
				32700, -- [4]
				32774, -- [5]
				37554, -- [6]
				38631, -- [7]
				48826, -- [8]
				48827, -- [9]
				52807, -- [10]
				57799, -- [11]
				59999, -- [12]
				69927, -- [13]
			},
		},
		["LIFEBLOOD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55428, -- [1]
				55480, -- [2]
				55500, -- [3]
				55501, -- [4]
				55502, -- [5]
				55503, -- [6]
			},
			["icon"] = 237556,
			["name"] = "Lifeblood",
		},
		["CONJUREMANARUBY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				10054, -- [1]
				10056, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 134128,
			["name"] = "Conjure Mana Ruby",
		},
		["VOLATILEBLASTINGTRIGGER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				53281, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Volatile Blasting Trigger",
		},
		["ENCHANTGLOVESMAJORSTRENGTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				33995, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Gloves - Major Strength",
		},
		["GYROBALANCEDKHORIUMDESTROYER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				41307, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Gyro-balanced Khorium Destroyer",
		},
		["GLYPHOFTURNEVIL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				54931, -- [1]
				55117, -- [2]
				57036, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Turn Evil",
		},
		["GARROTE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				703, -- [1]
				6737, -- [2]
				8631, -- [3]
				8632, -- [4]
				8633, -- [5]
				8634, -- [6]
				8635, -- [7]
				8636, -- [8]
				8818, -- [9]
				11289, -- [10]
				11290, -- [11]
				11291, -- [12]
				11292, -- [13]
				26839, -- [14]
				26884, -- [15]
				37066, -- [16]
				48675, -- [17]
				48676, -- [18]
			},
			["castTime"] = 0,
			["icon"] = 132297,
			["name"] = "Garrote",
		},
		["ARTISANALCHEMIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Alchemist",
			["icon"] = 136240,
			["id"] = {
				11612, -- [1]
			},
		},
		["ONSLAUGHTRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Onslaught Ring",
			["icon"] = 136243,
			["id"] = {
				26907, -- [1]
			},
		},
		["WINDWALLTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				15107, -- [1]
				15111, -- [2]
				15112, -- [3]
				15113, -- [4]
				15115, -- [5]
				15116, -- [6]
			},
			["castTime"] = 0,
			["icon"] = 136022,
			["name"] = "Windwall Totem",
		},
		["HEAVYLEATHERAMMOPOUCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Heavy Leather Ammo Pouch",
			["icon"] = 136247,
			["id"] = {
				9194, -- [1]
				9210, -- [2]
			},
		},
		["SAVAGESARONITEPAULDRONS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55306, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Savage Saronite Pauldrons",
		},
		["SMELTTRUESILVER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Smelt Truesilver",
			["icon"] = 136243,
			["id"] = {
				10098, -- [1]
				10100, -- [2]
			},
		},
		["GUARDDOG"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53178, -- [1]
				53179, -- [2]
				54445, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 132270,
			["name"] = "Guard Dog",
		},
		["COOKING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2550, -- [1]
				3102, -- [2]
				3413, -- [3]
				18260, -- [4]
				33359, -- [5]
				43744, -- [6]
				51296, -- [7]
			},
			["icon"] = 133971,
			["name"] = "Cooking",
		},
		["ARTISANCOOK"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Cook",
			["icon"] = 133971,
			["id"] = {
				18261, -- [1]
				19887, -- [2]
			},
		},
		["FROSTSCALESHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50952, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Frostscale Shoulders",
		},
		["ENCHANTBRACERSSTRIKING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Bracers - Striking",
			["icon"] = 136244,
			["id"] = {
				60616, -- [1]
			},
		},
		["GIFTOFTHENAARU"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				28880, -- [1]
				59542, -- [2]
				59543, -- [3]
				59544, -- [4]
				59545, -- [5]
				59547, -- [6]
				59548, -- [7]
			},
			["icon"] = 135923,
			["name"] = "Gift of the Naaru",
		},
		["GLOOMBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Gloom Band",
			["icon"] = 136243,
			["id"] = {
				25287, -- [1]
			},
		},
		["HEAVYEARTHFORGEDBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36129, -- [1]
			},
			["icon"] = 132741,
			["name"] = "Heavy Earthforged Breastplate",
		},
		["TURTLESCALELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Turtle Scale Leggings",
			["icon"] = 136247,
			["id"] = {
				10556, -- [1]
				10557, -- [2]
			},
		},
		["GLACIALSLIPPERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				60994, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Glacial Slippers",
		},
		["BLACKPLANAREDGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34542, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Black Planar Edge",
		},
		["ENCHANTBRACERSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13642, -- [1]
				13643, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Spirit",
		},
		["ROUGHBLASTINGPOWDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				3918, -- [1]
				3980, -- [2]
			},
			["icon"] = 133848,
			["name"] = "Rough Blasting Powder",
		},
		["APPRENTICECOOK"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Cook",
			["icon"] = 133971,
			["id"] = {
				2551, -- [1]
			},
		},
		["HEX"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				11641, -- [1]
				16097, -- [2]
				16707, -- [3]
				16708, -- [4]
				16709, -- [5]
				17172, -- [6]
				18503, -- [7]
				22566, -- [8]
				24053, -- [9]
				29044, -- [10]
				36700, -- [11]
				40400, -- [12]
				46295, -- [13]
				51514, -- [14]
				53439, -- [15]
				66054, -- [16]
			},
			["icon"] = 136071,
			["name"] = "Hex",
		},
		["PLATEMAIL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Plate Mail",
			["icon"] = 132736,
			["id"] = {
				750, -- [1]
				7109, -- [2]
				16320, -- [3]
			},
		},
		["SHININGSILVERBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Shining Silver Breastplate",
			["icon"] = 132750,
			["id"] = {
				2675, -- [1]
				2753, -- [2]
			},
		},
		["WOOLENBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Woolen Boots",
			["icon"] = 136249,
			["id"] = {
				2401, -- [1]
				2422, -- [2]
			},
		},
		["SARONITESPELLBLADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59442, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Saronite Spellblade",
		},
		["ADVANCEDTARGETDUMMY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Advanced Target Dummy",
			["icon"] = 136243,
			["id"] = {
				3965, -- [1]
				4022, -- [2]
				4049, -- [3]
				4072, -- [4]
			},
		},
		["GREENLEATHERBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Green Leather Bracers",
			["icon"] = 136247,
			["id"] = {
				3776, -- [1]
				3797, -- [2]
			},
		},
		["LIVINGEMERALDPENDANT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Living Emerald Pendant",
			["icon"] = 136243,
			["id"] = {
				26911, -- [1]
			},
		},
		["GLYPHOFSOULSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Soulstone",
			["icon"] = 136243,
			["id"] = {
				56231, -- [1]
				56297, -- [2]
				57274, -- [3]
			},
		},
		["BOREANLEATHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				59926, -- [1]
				64661, -- [2]
			},
			["icon"] = 136247,
			["name"] = "Borean Leather",
		},
		["FARSIGHT"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 1882,
			["id"] = {
				6196, -- [1]
				570, -- [2]
				1345, -- [3]
			},
			["icon"] = 136034,
			["name"] = "Far Sight",
		},
		["NETHERWEAVEBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				27032, -- [1]
			},
			["icon"] = 133691,
			["name"] = "Netherweave Bandage",
		},
		["WILLTOSURVIVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Will to Survive",
			["icon"] = 136129,
			["id"] = {
				59752, -- [1]
			},
		},
		["SCROLLOFRECALLIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				60337, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Recall III",
		},
		["FLASKOFPUREMOJO"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				54212, -- [1]
				54213, -- [2]
			},
			["icon"] = 236877,
			["name"] = "Flask of Pure Mojo",
		},
		["HEAVYSTONESTATUE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Heavy Stone Statue",
			["icon"] = 134230,
			["id"] = {
				32803, -- [1]
				32807, -- [2]
			},
		},
		["GOLDENROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Golden Rod",
			["icon"] = 135147,
			["id"] = {
				14379, -- [1]
				14381, -- [2]
			},
		},
		["APPRENTICESCRIBE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Scribe",
			["icon"] = 237171,
			["id"] = {
				45375, -- [1]
			},
		},
		["SILKHEADBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Silk Headband",
			["icon"] = 132149,
			["id"] = {
				8762, -- [1]
				8763, -- [2]
			},
		},
		["FELSHARPENINGSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				29654, -- [1]
			},
			["icon"] = 135253,
			["name"] = "Fel Sharpening Stone",
		},
		["LAVAFORGEDWARHAMMER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36136, -- [1]
			},
			["icon"] = 133054,
			["name"] = "Lavaforged Warhammer",
		},
		["ENCHANTBRACERSEXPERTISE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Bracers - Expertise",
			["icon"] = 136244,
			["id"] = {
				44598, -- [1]
			},
		},
		["THUNDERSTOMP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				63900, -- [1]
				26090, -- [2]
				26094, -- [3]
				26187, -- [4]
				26188, -- [5]
				26189, -- [6]
				26190, -- [7]
				27366, -- [8]
				34388, -- [9]
				61580, -- [10]
			},
			["castTime"] = 0,
			["icon"] = 132154,
			["name"] = "Thunderstomp",
		},
		["SUREFIRESHURIKEN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55202, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Sure-fire Shuriken",
		},
		["TARGETDUMMY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Target Dummy",
			["icon"] = 136243,
			["id"] = {
				3932, -- [1]
				3995, -- [2]
				4071, -- [3]
			},
		},
		["SIMPLEOPALRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Simple Opal Ring",
			["icon"] = 136243,
			["id"] = {
				26902, -- [1]
			},
		},
		["COBALTFRAGBOMB"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56460, -- [1]
				67769, -- [2]
				67890, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Cobalt Frag Bomb",
		},
		["RECKLESSNESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Recklessness",
			["icon"] = 132109,
			["id"] = {
				1719, -- [1]
				1722, -- [2]
				13847, -- [3]
			},
		},
		["TURNEVIL"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["castTime"] = 1411,
			["name"] = "Turn Evil",
			["icon"] = 135983,
			["id"] = {
				--10326, -- [1]
			},
		},
		["GLYPHOFPAINSUPPRESSION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Pain Suppression",
			["icon"] = 136243,
			["id"] = {
				63248, -- [1]
				63877, -- [2]
				64259, -- [3]
			},
		},
		["GLYPHOFMANAGEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Mana Gem",
			["icon"] = 136243,
			["id"] = {
				56367, -- [1]
				56598, -- [2]
				56985, -- [3]
			},
		},
		["FEARWARD"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				6346, -- [1]
				19337, -- [2]
			},
			["name"] = "Fear Ward",
			["icon"] = 135902,
			["castTime"] = 0,
		},
		["RITUALOFSOULS"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				29893, -- [1]
				34143, -- [2]
				58887, -- [3]
				60429, -- [4]
			},
			["name"] = "Ritual of Souls",
			["icon"] = 136194,
			["castTime"] = 0,
		},
		["ENCHANTBRACERLESSERSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13501, -- [1]
				13502, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Lesser Stamina",
		},
		["GREENIRONHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Green Iron Helm",
			["icon"] = 133071,
			["id"] = {
				3502, -- [1]
				3522, -- [2]
			},
		},
		["GLYPHOFSEALOFCOMMAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				54925, -- [1]
				55109, -- [2]
				57033, -- [3]
				68082, -- [4]
				67337, -- [5]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Seal of Command",
		},
		["LESSERRUNEOFWARDING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				32274, -- [1]
				32284, -- [2]
				42134, -- [3]
				42135, -- [4]
			},
			["icon"] = 134424,
			["name"] = "Lesser Rune of Warding",
		},
		["GLYPHOFCORRUPTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Corruption",
			["icon"] = 136243,
			["id"] = {
				56218, -- [1]
				56271, -- [2]
				57259, -- [3]
			},
		},
		["LINENBAG"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Linen Bag",
			["icon"] = 136243,
			["id"] = {
				3755, -- [1]
				3783, -- [2]
			},
		},
		["RITUALOFREFRESHMENT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				43987, -- [1]
				58659, -- [2]
			},
			["icon"] = 135739,
			["name"] = "Ritual of Refreshment",
		},
		["ARCANEBRILLIANCE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				23028, -- [1]
				23030, -- [2]
				27127, -- [3]
				27394, -- [4]
				43002, -- [5]
				43003, -- [6]
				43004, -- [7]
			},
			["icon"] = 135869,
			["name"] = "Arcane Brilliance",
		},
		["SIMPLEPEARLRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Simple Pearl Ring",
			["icon"] = 136243,
			["id"] = {
				25284, -- [1]
			},
		},
		["SMOKEDSALMON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45564, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Smoked Salmon",
		},
		["MASTERSINSCRIPTIONOFTHEPINNACLE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 4000,
			["id"] = {
				61119, -- [1]
			},
			["icon"] = 237171,
			["name"] = "Master's Inscription of the Pinnacle",
		},
		["BLUELINENSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Blue Linen Shirt",
			["icon"] = 132149,
			["id"] = {
				2394, -- [1]
				2416, -- [2]
			},
		},
		["GLYPHOFEXPOSEARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Expose Armor",
			["icon"] = 136243,
			["id"] = {
				56803, -- [1]
				57121, -- [2]
				57148, -- [3]
			},
		},
		["RHINODOGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45553, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Rhino Dogs",
		},
		["NIGHTSCAPETUNIC"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Nightscape Tunic",
			["icon"] = 136247,
			["id"] = {
				10499, -- [1]
				10500, -- [2]
			},
		},
		["INTERVENE"] = {
			["maxRange"] = 25,
			["minRange"] = 8,
			["id"] = {
				53476, -- [1]
				3411, -- [2]
				34784, -- [3]
				41198, -- [4]
				59667, -- [5]
			},
			["castTime"] = 0,
			["icon"] = 132199,
			["name"] = "Intervene",
		},
		["DARKPACT"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				18220, -- [1]
				18937, -- [2]
				18938, -- [3]
				18939, -- [4]
				18940, -- [5]
				27265, -- [6]
				59092, -- [7]
			},
			["name"] = "Dark Pact",
			["icon"] = 136141,
			["castTime"] = 0,
		},
		["FROSTSCALEHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				60600, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Frostscale Helm",
		},
		["SEALOFTHECRUSADER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				20162, -- [1]
				20305, -- [2]
				20306, -- [3]
				20307, -- [4]
				20308, -- [5]
				20444, -- [6]
				20445, -- [7]
				20446, -- [8]
				20447, -- [9]
				20448, -- [10]
				21082, -- [11]
				21083, -- [12]
			},
			["castTime"] = 0,
			["icon"] = 135924,
			["name"] = "Seal of the Crusader",
		},
		["STARFALL"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Starfall",
			["icon"] = 135753,
			["id"] = {
				20687, -- [1]
				26540, -- [2]
				35749, -- [3]
				37124, -- [4]
				48505, -- [5]
				50286, -- [6]
				50288, -- [7]
				50294, -- [8]
				53188, -- [9]
				53189, -- [10]
				53190, -- [11]
				53191, -- [12]
				53194, -- [13]
				53195, -- [14]
				53196, -- [15]
				53197, -- [16]
				53198, -- [17]
				53199, -- [18]
				53200, -- [19]
				53201, -- [20]
				61986, -- [21]
				64378, -- [22]
				64593, -- [23]
				64594, -- [24]
			},
		},
		["PRAYEROFFORTITUDE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				21562, -- [1]
				21564, -- [2]
				21568, -- [3]
				21569, -- [4]
				25392, -- [5]
				39231, -- [6]
				43939, -- [7]
				48162, -- [8]
			},
			["name"] = "Prayer of Fortitude",
			["icon"] = 135941,
			["castTime"] = 0,
		},
		["CLEANSINGTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				--8170, -- [1]
			},
			["icon"] = 136019,
			["name"] = "Cleansing Totem",
		},
		["ENCHANTBOOTSGREATERAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				20023, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Boots - Greater Agility",
		},
		["RUNEOFTHENERUBIANCARAPACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				70164, -- [1]
			},
			["icon"] = 135371,
			["name"] = "Rune of the Nerubian Carapace",
		},
		["ARTISANENCHANTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				13921, -- [1]
			},
			["icon"] = 136244,
			["name"] = "Artisan Enchanter",
		},
		["KILLCOMMAND"] = {
			["maxRange"] = 45,
			["minRange"] = 0,
			["id"] = {
				34026, -- [1]
				34027, -- [2]
				58914, -- [3]
				60110, -- [4]
				60113, -- [5]
			},
			["castTime"] = 0,
			["icon"] = 132176,
			["name"] = "Kill Command",
		},
		["BRONZEBATTLEAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Bronze Battle Axe",
			["icon"] = 132415,
			["id"] = {
				9987, -- [1]
				9990, -- [2]
			},
		},
		["ELIXIROFMIGHTYFORTITUDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53751, -- [1]
				53898, -- [2]
			},
			["icon"] = 134792,
			["name"] = "Elixir of Mighty Fortitude",
		},
		["RIP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Rip",
			["icon"] = 132152,
			["id"] = {
				1079, -- [1]
				1445, -- [2]
				9492, -- [3]
				9493, -- [4]
				9494, -- [5]
				9495, -- [6]
				9752, -- [7]
				9753, -- [8]
				9894, -- [9]
				9895, -- [10]
				9896, -- [11]
				9897, -- [12]
				27008, -- [13]
				33912, -- [14]
				36590, -- [15]
				49799, -- [16]
				49800, -- [17]
				57661, -- [18]
				59989, -- [19]
				71926, -- [20]
			},
		},
		["ICEBORNEBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50943, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Iceborne Belt",
		},
		["MAGEARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				6117, -- [1]
				6121, -- [2]
				22782, -- [3]
				22783, -- [4]
				22784, -- [5]
				22785, -- [6]
				27125, -- [7]
				27392, -- [8]
				43023, -- [9]
				43024, -- [10]
			},
			["icon"] = 135991,
			["name"] = "Mage Armor",
		},
		["PORTALSTORMWIND"] = {
			["maxRange"] = 10,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				10059, -- [1]
				1851, -- [2]
			},
			["icon"] = 135748,
			["name"] = "Portal: Stormwind",
		},
		["HEAVYRUNECLOTHBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Heavy Runecloth Bandage",
			["icon"] = 133682,
			["id"] = {
				18630, -- [1]
				18632, -- [2]
			},
		},
		["SCORPIDSTING"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = -999500,
			["id"] = {
				3043, -- [1]
				3047, -- [2]
				14275, -- [3]
				14276, -- [4]
				14277, -- [5]
				14347, -- [6]
				14348, -- [7]
				14349, -- [8]
				18545, -- [9]
				52604, -- [10]
			},
			["icon"] = 132169,
			["name"] = "Scorpid Sting",
		},
		["HEAVYMITHRILAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Heavy Mithril Axe",
			["icon"] = 132405,
			["id"] = {
				9993, -- [1]
				9994, -- [2]
			},
		},
		["DODGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				81, -- [1]
				25071, -- [2]
				62951, -- [3]
			},
			["icon"] = 136047,
			["name"] = "Dodge",
		},
		["GNOMISHNETOMATICPROJECTOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12902, -- [1]
				12913, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Net-o-Matic Projector",
		},
		["HEAVYMITHRILSHOULDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Heavy Mithril Shoulder",
			["icon"] = 135053,
			["id"] = {
				9926, -- [1]
				9927, -- [2]
			},
		},
		["FROSTMOONPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56021, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostmoon Pants",
		},
		["BARBARICLINENVEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Barbaric Linen Vest",
			["icon"] = 132149,
			["id"] = {
				2395, -- [1]
				2417, -- [2]
			},
		},
		["MANAINJECTORKIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56477, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Mana Injector Kit",
		},
		["ROUGHBRONZESHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Rough Bronze Shoulders",
			["icon"] = 135036,
			["id"] = {
				3328, -- [1]
				3345, -- [2]
			},
		},
		["JOURNEYMANLEATHERWORKER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Leatherworker",
			["icon"] = 133611,
			["id"] = {
				2154, -- [1]
			},
		},
		["GNOMISHROCKETBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				12905, -- [1]
				12916, -- [2]
				13141, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Rocket Boots",
		},
		["EARTHLIVINGWEAPON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				51730, -- [1]
				51988, -- [2]
				51991, -- [3]
				51992, -- [4]
				51993, -- [5]
				51994, -- [6]
			},
			["icon"] = 237575,
			["name"] = "Earthliving Weapon",
		},
		["GLYPHOFINSECTSWARM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Insect Swarm",
			["icon"] = 136243,
			["id"] = {
				54830, -- [1]
				54872, -- [2]
				56948, -- [3]
			},
		},
		["HEALINGTOUCH"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 1411,
			["name"] = "Healing Touch",
			["icon"] = 136041,
			["id"] = {
				5185, -- [1]
				3735, -- [2]
				5186, -- [3]
				5187, -- [4]
				5188, -- [5]
				5189, -- [6]
				5190, -- [7]
				5191, -- [8]
				5192, -- [9]
				5193, -- [10]
				5194, -- [11]
				5294, -- [12]
				5295, -- [13]
				5296, -- [14]
				5297, -- [15]
				6659, -- [16]
				6778, -- [17]
				6779, -- [18]
				8903, -- [19]
				8904, -- [20]
				9758, -- [21]
				9759, -- [22]
				9888, -- [23]
				9889, -- [24]
				9890, -- [25]
				9891, -- [26]
				11431, -- [27]
				20790, -- [28]
				23381, -- [29]
				25297, -- [30]
				25407, -- [31]
				25970, -- [32]
				27527, -- [33]
				28719, -- [34]
				28742, -- [35]
				28848, -- [36]
				26978, -- [37]
				26979, -- [38]
				29339, -- [39]
				38658, -- [40]
				48377, -- [41]
				48378, -- [42]
				69899, -- [43]
			},
		},
		["SOLIDBLASTINGPOWDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Solid Blasting Powder",
			["icon"] = 136243,
			["id"] = {
				12585, -- [1]
				12629, -- [2]
			},
		},
		["FELIRONBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29550, -- [1]
			},
			["icon"] = 132742,
			["name"] = "Fel Iron Breastplate",
		},
		["GLOVESOFMEDITATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Gloves of Meditation",
			["icon"] = 132149,
			["id"] = {
				3852, -- [1]
				3884, -- [2]
			},
		},
		["GLYPHOFHAMMEROFJUSTICE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Hammer of Justice",
			["icon"] = 136243,
			["id"] = {
				54923, -- [1]
				55110, -- [2]
				57027, -- [3]
			},
		},
		["FIRENOVATOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1535, -- [1]
				8086, -- [2]
				8498, -- [3]
				8499, -- [4]
				8500, -- [5]
				8501, -- [6]
				11314, -- [7]
				11315, -- [8]
				11316, -- [9]
				11317, -- [10]
				27623, -- [11]
				32062, -- [12]
				43436, -- [13]
				44257, -- [14]
			},
			["castTime"] = 0,
			["icon"] = 135824,
			["name"] = "Fire Nova Totem",
		},
		["NIGHTSCAPEPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Nightscape Pants",
			["icon"] = 136247,
			["id"] = {
				10548, -- [1]
				10549, -- [2]
			},
		},
		["ENCHANTCLOAKGREATERAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				34004, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Greater Agility",
		},
		["GLYPHOFUNBREAKABLEARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				57226, -- [1]
				58635, -- [2]
				58725, -- [3]
			},
			["icon"] = 132918,
			["name"] = "Glyph of Unbreakable Armor",
		},
		["AMBUSH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				8676, -- [1]
				8678, -- [2]
				8724, -- [3]
				8725, -- [4]
				8727, -- [5]
				8728, -- [6]
				11267, -- [7]
				11268, -- [8]
				11269, -- [9]
				11270, -- [10]
				11271, -- [11]
				11272, -- [12]
				24337, -- [13]
				27441, -- [14]
				39668, -- [15]
				39669, -- [16]
				41390, -- [17]
				48689, -- [18]
				48690, -- [19]
				48691, -- [20]
				56239, -- [21]
			},
			["castTime"] = 0,
			["icon"] = 132282,
			["name"] = "Ambush",
		},
		["JOURNEYMANJEWELCRAFTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Jewelcrafter",
			["icon"] = 134073,
			["id"] = {
				25246, -- [1]
			},
		},
		["MECHANICALREPAIRKIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Mechanical Repair Kit",
			["icon"] = 136243,
			["id"] = {
				15255, -- [1]
				15256, -- [2]
			},
		},
		["BRILLIANTSARONITELEGPLATES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55055, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Brilliant Saronite Legplates",
		},
		["TEMPEREDSARONITEHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54555, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Tempered Saronite Helm",
		},
		["TRAVELFORM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Travel Form",
			["icon"] = 132144,
			["id"] = {
				783, -- [1]
				1441, -- [2]
				32447, -- [3]
			},
		},
		["REND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Rend",
			["icon"] = 132155,
			["id"] = {
				772, -- [1]
				1423, -- [2]
				6546, -- [3]
				6547, -- [4]
				6548, -- [5]
				6549, -- [6]
				6550, -- [7]
				6551, -- [8]
				11572, -- [9]
				11573, -- [10]
				11574, -- [11]
				11575, -- [12]
				11576, -- [13]
				11577, -- [14]
				11977, -- [15]
				12054, -- [16]
				13318, -- [17]
				13443, -- [18]
				13445, -- [19]
				13738, -- [20]
				14087, -- [21]
				14118, -- [22]
				16393, -- [23]
				16403, -- [24]
				16406, -- [25]
				16509, -- [26]
				17153, -- [27]
				17504, -- [28]
				18075, -- [29]
				18078, -- [30]
				18106, -- [31]
				18200, -- [32]
				18202, -- [33]
				21949, -- [34]
				25208, -- [35]
				29574, -- [36]
				29578, -- [37]
				36965, -- [38]
				36991, -- [39]
				37662, -- [40]
				43246, -- [41]
				43931, -- [42]
				46845, -- [43]
				47465, -- [44]
				48880, -- [45]
				53317, -- [46]
				54703, -- [47]
				54708, -- [48]
				59239, -- [49]
				59343, -- [50]
				59691, -- [51]
			},
		},
		["EBONWEAVEROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56026, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Ebonweave Robe",
		},
		["RUNECLOTHHEADBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runecloth Headband",
			["icon"] = 132149,
			["id"] = {
				18444, -- [1]
			},
		},
		["ICYPRISM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				62242, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Icy Prism",
		},
		["HILLMANSLEATHERGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Hillman's Leather Gloves",
			["icon"] = 136247,
			["id"] = {
				3764, -- [1]
				3790, -- [2]
			},
		},
		["PRAYEROFHEALING"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				596, -- [1]
				618, -- [2]
				996, -- [3]
				997, -- [4]
				1287, -- [5]
				1288, -- [6]
				2049, -- [7]
				10960, -- [8]
				10961, -- [9]
				10962, -- [10]
				13857, -- [11]
				15585, -- [12]
				25316, -- [13]
				25353, -- [14]
				25985, -- [15]
				25308, -- [16]
				30604, -- [17]
				33152, -- [18]
				35943, -- [19]
				48072, -- [20]
				59698, -- [21]
			},
			["name"] = "Prayer of Healing",
			["icon"] = 135943,
			["castTime"] = 3000,
		},
		["ROYALGUIDEOFESCAPEROUTES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Royal Guide of Escape Routes",
			["icon"] = 132918,
			["id"] = {
				59486, -- [1]
			},
		},
		["AQUAMARINESIGNET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Aquamarine Signet",
			["icon"] = 136243,
			["id"] = {
				26874, -- [1]
			},
		},
		["FLAMETONGUETOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8227, -- [1]
				8231, -- [2]
				8249, -- [3]
				8252, -- [4]
				10526, -- [5]
				10528, -- [6]
				16387, -- [7]
				16394, -- [8]
				25557, -- [9]
				52109, -- [10]
				52110, -- [11]
				52111, -- [12]
				52112, -- [13]
				52113, -- [14]
				58649, -- [15]
				58651, -- [16]
				58652, -- [17]
				58654, -- [18]
				58655, -- [19]
				58656, -- [20]
			},
			["icon"] = 136040,
			["name"] = "Flametongue Totem",
		},
		["SOOTHEANIMAL"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Soothe Animal",
			["icon"] = 132163,
			["id"] = {
				2908, -- [1]
				2910, -- [2]
				8955, -- [3]
				8956, -- [4]
				9901, -- [5]
				9902, -- [6]
				26995, -- [7]
			},
		},
		["JORMUNGARLEGREINFORCEMENTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3763,
			["id"] = {
				50903, -- [1]
				60583, -- [2]
			},
			["icon"] = 136247,
			["name"] = "Jormungar Leg Reinforcements",
		},
		["BRIGHTCLOTHCLOAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Brightcloth Cloak",
			["icon"] = 132149,
			["id"] = {
				18420, -- [1]
			},
		},
		["LIONHEARTBLADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34538, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Lionheart Blade",
		},
		["BRIGHTCLOTHROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Brightcloth Robe",
			["icon"] = 132149,
			["id"] = {
				18414, -- [1]
			},
		},
		["ESCAPEARTIST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				20589, -- [1]
			},
			["icon"] = 132309,
			["name"] = "Escape Artist",
		},
		["ENCHANT2HWEAPONMINORIMPACT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7745, -- [1]
				7746, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant 2H Weapon - Minor Impact",
		},
		["GLYPHOFAIMEDSHOT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Aimed Shot",
			["icon"] = 136243,
			["id"] = {
				56824, -- [1]
				56869, -- [2]
				56994, -- [3]
			},
		},
		["FLYINGTIGERGOGGLES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Flying Tiger Goggles",
			["icon"] = 136243,
			["id"] = {
				3934, -- [1]
				3997, -- [2]
			},
		},
		["TEMPEREDSARONITESHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54556, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Tempered Saronite Shoulders",
		},
		["SWIFTSKYFLAREDIAMOND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55394, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Swift Skyflare Diamond",
		},
		["FEINT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1966, -- [1]
				6734, -- [2]
				6768, -- [3]
				6769, -- [4]
				8637, -- [5]
				8638, -- [6]
				11303, -- [7]
				11304, -- [8]
				25302, -- [9]
				25413, -- [10]
				25976, -- [11]
				27448, -- [12]
				48658, -- [13]
				48659, -- [14]
			},
			["castTime"] = 0,
			["icon"] = 132294,
			["name"] = "Feint",
		},
		["ENCHANTWEAPONEXCEPTIONALSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Weapon - Exceptional Spirit",
			["icon"] = 136244,
			["id"] = {
				44510, -- [1]
			},
		},
		["VOLLEY"] = {
			["maxRange"] = 35,
			["minRange"] = 0,
			["castTime"] = -999500,
			["id"] = {
				1510, -- [1]
				1540, -- [2]
				1564, -- [3]
				1598, -- [4]
				14294, -- [5]
				14295, -- [6]
				14361, -- [7]
				14362, -- [8]
				22908, -- [9]
				27022, -- [10]
				30933, -- [11]
				34100, -- [12]
				35950, -- [13]
				41089, -- [14]
				41091, -- [15]
				42234, -- [16]
				42243, -- [17]
				42244, -- [18]
				42245, -- [19]
				56843, -- [20]
				58431, -- [21]
				58432, -- [22]
				58433, -- [23]
				58434, -- [24]
				71252, -- [25]
			},
			["icon"] = 132222,
			["name"] = "Volley",
		},
		["DUSKWEAVECOWL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55919, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Duskweave Cowl",
		},
		["HAMSTRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Hamstring",
			["icon"] = 132316,
			["id"] = {
				1715, -- [1]
				1716, -- [2]
				7372, -- [3]
				7373, -- [4]
				7374, -- [5]
				7375, -- [6]
				9080, -- [7]
				26141, -- [8]
				26211, -- [9]
				27584, -- [10]
				25212, -- [11]
				29667, -- [12]
				30989, -- [13]
				31553, -- [14]
				38262, -- [15]
				38995, -- [16]
				48639, -- [17]
				62845, -- [18]
			},
		},
		["GREATERMANAPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Greater Mana Potion",
			["icon"] = 136243,
			["id"] = {
				11448, -- [1]
				11488, -- [2]
			},
		},
		["RESTORATION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				11359, -- [1]
				23396, -- [2]
				23493, -- [3]
				24379, -- [4]
				40097, -- [5]
			},
			["icon"] = 135894,
			["name"] = "Restoration",
		},
		["NEXUSTRANSFORMATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				42613, -- [1]
			},
			["icon"] = 132882,
			["name"] = "Nexus Transformation",
		},
		["ENCHANTBOOTSLESSERSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13644, -- [1]
				13645, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Boots - Lesser Stamina",
		},
		["ENCHANTCHESTMINORABSORPTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7426, -- [1]
				13373, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Minor Absorption",
		},
		["ENERGIZEDDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53930, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Energized Dark Jade",
		},
		["AUTOSHOT"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = -999500,
			["id"] = {
				75, -- [1]
				1583, -- [2]
			},
			["icon"] = 135485,
			["name"] = "Auto Shot",
		},
		["RUNECLOTHBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runecloth Boots",
			["icon"] = 132149,
			["id"] = {
				18423, -- [1]
			},
		},
		["PSYCHICSCREAM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				8122, -- [1]
				8123, -- [2]
				8124, -- [3]
				8125, -- [4]
				10888, -- [5]
				10889, -- [6]
				10890, -- [7]
				10891, -- [8]
				13704, -- [9]
				15398, -- [10]
				22884, -- [11]
				26042, -- [12]
				27610, -- [13]
				34322, -- [14]
				43432, -- [15]
				65543, -- [16]
			},
			["name"] = "Psychic Scream",
			["icon"] = 136184,
			["castTime"] = 0,
		},
		["FELIRONCASING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				30304, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Fel Iron Casing",
		},
		["HEAVYLINENBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Heavy Linen Bandage",
			["icon"] = 133688,
			["id"] = {
				3276, -- [1]
				3281, -- [2]
			},
		},
		["LESSERFLASKOFTOUGHNESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53752, -- [1]
				53899, -- [2]
			},
			["icon"] = 236876,
			["name"] = "Lesser Flask of Toughness",
		},
		["ICYVEINS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				--12472, -- [1]
				54792, -- [2]
			},
			["icon"] = 135838,
			["name"] = "Icy Veins",
		},
		["QUICKNESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Quickness",
			["icon"] = 136057,
			["id"] = {
				4281, -- [1]
				4777, -- [2]
				6015, -- [3]
				20582, -- [4]
			},
		},
		["WHIRLINGSTEELAXES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Whirling Steel Axes",
			["icon"] = 136241,
			["id"] = {
				34981, -- [1]
			},
		},
		["SHININGDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53923, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Shining Dark Jade",
		},
		["GLYPHOFDEATHSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				59336, -- [1]
				59337, -- [2]
				59340, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Death Strike",
		},
		["ENDLESSMANAPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				58868, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Endless Mana Potion",
		},
		["FROSTSAVAGECOWL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59589, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostsavage Cowl",
		},
		["MAGNIFICENTFLYINGCARPET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 20000,
			["id"] = {
				60971, -- [1]
				61309, -- [2]
			},
			["icon"] = 136249,
			["name"] = "Magnificent Flying Carpet",
		},
		["SONICBOOSTER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				56466, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Sonic Booster",
		},
		["APPRENTICERIDING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				33388, -- [1]
				33389, -- [2]
			},
			["icon"] = 136103,
			["name"] = "Apprentice Riding",
		},
		["CERTIFICATEOFOWNERSHIP"] = {
			["maxRange"] = 15,
			["minRange"] = 0,
			["castTime"] = 9408,
			["name"] = "Certificate of Ownership",
			["icon"] = 237446,
			["id"] = {
				59385, -- [1]
				59387, -- [2]
			},
		},
		["ELIXIROFMINORACCURACY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Elixir of Minor Accuracy",
			["icon"] = 134786,
			["id"] = {
				63729, -- [1]
				63732, -- [2]
			},
		},
		["REMOVECURSE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				--475, -- [1]
				486, -- [2]
				2782, -- [3]
				2786, -- [4]
				2788, -- [5]
				3364, -- [6]
				3750, -- [7]
				15729, -- [8]
				30281, -- [9]
			},
			["icon"] = 136082,
			["name"] = "Remove Curse",
		},
		["EXPERTSKINNER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Expert Skinner",
			["icon"] = 134366,
			["id"] = {
				8620, -- [1]
			},
		},
		["GLYPHOFSPRINT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Sprint",
			["icon"] = 136243,
			["id"] = {
				56811, -- [1]
				57133, -- [2]
				57304, -- [3]
			},
		},
		["SAUTEEDGOBY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45562, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Sauteed Goby",
		},
		["HEAVYNETHERWEAVEBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				27033, -- [1]
			},
			["icon"] = 133692,
			["name"] = "Heavy Netherweave Bandage",
		},
		["FLARE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1543, -- [1]
				1603, -- [2]
				10113, -- [3]
				28822, -- [4]
				41094, -- [5]
				41095, -- [6]
				55798, -- [7]
			},
			["icon"] = 135815,
			["name"] = "Flare",
		},
		["CREATESPELLSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				2362, -- [1]
				918, -- [2]
				6485, -- [3]
				--17727, -- [4]
				--17728, -- [5]
				28172, -- [6]
				47886, -- [7]
				47888, -- [8]
			},
			["name"] = "Create Spellstone",
			["icon"] = 134131,
			["castTime"] = 5000,
		},
		["ABOLISHDISEASE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				552, -- [1]
				1269, -- [2]
			},
			["name"] = "Abolish Disease",
			["icon"] = 136066,
			["castTime"] = 0,
		},
		["ENCHANTRINGSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Ring - Stamina",
			["icon"] = 136244,
			["id"] = {
				59636, -- [1]
			},
		},
		["GREATERBLESSINGOFMIGHT"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Greater Blessing of Might",
			["icon"] = 135908,
			["id"] = {
				25782, -- [1]
				25915, -- [2]
				25916, -- [3]
				25917, -- [4]
				27141, -- [5]
				29381, -- [6]
				33564, -- [7]
				43940, -- [8]
				48933, -- [9]
				48934, -- [10]
			},
		},
		["HAMMEROFJUSTICE"] = {
			["maxRange"] = 10,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Hammer of Justice",
			["icon"] = 135963,
			["id"] = {
				853, -- [1]
				5584, -- [2]
				5588, -- [3]
				5589, -- [4]
				5590, -- [5]
				5591, -- [6]
				10308, -- [7]
				10309, -- [8]
				13005, -- [9]
				32416, -- [10]
				37369, -- [11]
				39077, -- [12]
				41468, -- [13]
				66007, -- [14]
				66613, -- [15]
				66863, -- [16]
				66940, -- [17]
				66941, -- [18]
			},
		},
		["SMELTSARONITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				49258, -- [1]
			},
			["icon"] = 135811,
			["name"] = "Smelt Saronite",
		},
		["INDESTRUCTIBLEALCHEMISTSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				60403, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Indestructible Alchemist Stone",
		},
		["BALANCEDSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53866, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Balanced Shadow Crystal",
		},
		["SHATTERINGTHROW"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Shattering Throw",
			["icon"] = 311430,
			["id"] = {
				64380, -- [1]
				64382, -- [2]
				65940, -- [3]
				65941, -- [4]
			},
		},
		["SUBTLETY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				17118, -- [1]
				17119, -- [2]
				17120, -- [3]
				17121, -- [4]
				17122, -- [5]
				23545, -- [6]
			},
			["icon"] = 132150,
			["name"] = "Subtlety",
		},
		["DIAMONDFOCUSRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Diamond Focus Ring",
			["icon"] = 136243,
			["id"] = {
				36526, -- [1]
			},
		},
		["DAUNTINGHANDGUARDS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55301, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Daunting Handguards",
		},
		["AVOIDANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				32233, -- [1]
				23198, -- [2]
				23647, -- [3]
				32234, -- [4]
				32600, -- [5]
				62137, -- [6]
				63623, -- [7]
				65220, -- [8]
			},
			["castTime"] = 0,
			["icon"] = 132332,
			["name"] = "Avoidance",
		},
		["RITUALOFSUMMONING"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				698, -- [1]
				7663, -- [2]
				7720, -- [3]
				32899, -- [4]
				32928, -- [5]
				32929, -- [6]
				32948, -- [7]
				40335, -- [8]
				46546, -- [9]
				61993, -- [10]
				61994, -- [11]
			},
			["name"] = "Ritual of Summoning",
			["icon"] = 136223,
			["castTime"] = 0,
		},
		["ROYALSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53864, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Royal Shadow Crystal",
		},
		["ICESTRIKERSCLOAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				60637, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Ice Striker's Cloak",
		},
		["SCROLLOFAGILITYIV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Agility IV",
			["icon"] = 132918,
			["id"] = {
				58478, -- [1]
			},
		},
		["HARDENEDADAMANTITETUBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				30307, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Hardened Adamantite Tube",
		},
		["THICKWARAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Thick War Axe",
			["icon"] = 135419,
			["id"] = {
				3294, -- [1]
				3300, -- [2]
			},
		},
		["BLACKMAGEWEAVELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Black Mageweave Leggings",
			["icon"] = 132149,
			["id"] = {
				12049, -- [1]
				12101, -- [2]
			},
		},
		["DELICATEBLOODSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53832, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Delicate Bloodstone",
		},
		["DARKLEATHERCLOAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Dark Leather Cloak",
			["icon"] = 136247,
			["id"] = {
				2168, -- [1]
				2179, -- [2]
			},
		},
		["COPPERCHAINPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Copper Chain Pants",
			["icon"] = 134583,
			["id"] = {
				2662, -- [1]
				2743, -- [2]
			},
		},
		["MYSTICTOME"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Mystic Tome",
			["icon"] = 132918,
			["id"] = {
				58565, -- [1]
			},
		},
		["FAERIEFIREFERAL"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Faerie Fire (Feral)",
			["icon"] = 136033,
			["id"] = {
				16857, -- [1]
				3739, -- [2]
				17390, -- [3]
				17391, -- [4]
				17392, -- [5]
				17396, -- [6]
				17397, -- [7]
				60089, -- [8]
			},
		},
		["SARONITEPROTECTOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55013, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Saronite Protector",
		},
		["GLYPHOFAMBUSH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56813, -- [1]
				57113, -- [2]
				57140, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Ambush",
		},
		["THORIUMLEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Thorium Leggings",
			["icon"] = 134584,
			["id"] = {
				16662, -- [1]
			},
		},
		["SMOOTHGOLDENDRAENITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				34069, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Smooth Golden Draenite",
		},
		["FROSTWEAVEBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				45545, -- [1]
			},
			["icon"] = 133675,
			["name"] = "Frostweave Bandage",
		},
		["PATTERNEDBRONZEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Patterned Bronze Bracers",
			["icon"] = 132606,
			["id"] = {
				2672, -- [1]
				2751, -- [2]
			},
		},
		["CREATEHEALTHSTONEMINOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				6201, -- [1]
				6203, -- [2]
				23517, -- [3]
				23518, -- [4]
				23519, -- [5]
			},
			["castTime"] = 3000,
			["icon"] = 135230,
			["name"] = "Create Healthstone (Minor)",
		},
		["SHIELDBLOCK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Shield Block",
			["icon"] = 132110,
			["id"] = {
				2565, -- [1]
				2570, -- [2]
				12169, -- [3]
				32587, -- [4]
				37414, -- [5]
				38031, -- [6]
				69580, -- [7]
			},
		},
		["FLASHHEAL"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				2061, -- [1]
				2066, -- [2]
				9472, -- [3]
				9473, -- [4]
				9474, -- [5]
				9475, -- [6]
				9476, -- [7]
				9477, -- [8]
				10915, -- [9]
				10916, -- [10]
				10917, -- [11]
				10918, -- [12]
				10919, -- [13]
				10920, -- [14]
				17137, -- [15]
				17138, -- [16]
				17843, -- [17]
				27608, -- [18]
				25233, -- [19]
				25235, -- [20]
				38588, -- [21]
				42420, -- [22]
				43431, -- [23]
				43516, -- [24]
				43575, -- [25]
				48070, -- [26]
				48071, -- [27]
				56331, -- [28]
				56919, -- [29]
				71595, -- [30]
				66104, -- [31]
				71782, -- [32]
			},
			["name"] = "Flash Heal",
			["icon"] = 135907,
			["castTime"] = 1500,
		},
		["SCROLLOFINTELLECTV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Intellect V",
			["icon"] = 132918,
			["id"] = {
				50601, -- [1]
			},
		},
		["MAGEWEAVEBAG"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Mageweave Bag",
			["icon"] = 132149,
			["id"] = {
				12065, -- [1]
				12110, -- [2]
			},
		},
		["THEBIGONE"] = {
			["maxRange"] = 15,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				12562, -- [1]
				12754, -- [2]
				12778, -- [3]
			},
			["icon"] = 135826,
			["name"] = "The Big One",
		},
		["GUARDIANSSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53871, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Guardian's Shadow Crystal",
		},
		["ARTISANMINER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Miner",
			["icon"] = 136248,
			["id"] = {
				10249, -- [1]
			},
		},
		["POISONSPIT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				35387, -- [1]
				32093, -- [2]
				32330, -- [3]
				35388, -- [4]
				35389, -- [5]
				35390, -- [6]
				35391, -- [7]
				35392, -- [8]
				37839, -- [9]
				38030, -- [10]
				39204, -- [11]
				39419, -- [12]
				40078, -- [13]
				49708, -- [14]
				55555, -- [15]
				55556, -- [16]
				55557, -- [17]
				70189, -- [18]
			},
			["castTime"] = 0,
			["icon"] = 136016,
			["name"] = "Poison Spit",
		},
		["BLAZEFURY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				36258, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Blazefury",
		},
		["GNOMISHPOWERGOGGLES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				30574, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Power Goggles",
		},
		["GLYPHOFWRATH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Wrath",
			["icon"] = 136243,
			["id"] = {
				54756, -- [1]
				54875, -- [2]
				56963, -- [3]
			},
		},
		["ENCHANTSHIELDRESILIENCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				44383, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Shield - Resilience",
		},
		["ELUSIVENESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Elusiveness",
			["icon"] = 135994,
			["id"] = {
				13981, -- [1]
				14066, -- [2]
				21009, -- [3]
			},
		},
		["MIDNIGHTINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Midnight Ink",
			["icon"] = 132918,
			["id"] = {
				53462, -- [1]
			},
		},
		["WOOLBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Wool Bandage",
			["icon"] = 133684,
			["id"] = {
				3277, -- [1]
				3282, -- [2]
			},
		},
		["RUNEDBLOODSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53834, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Runed Bloodstone",
		},
		["GLYPHOFRIP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Rip",
			["icon"] = 136243,
			["id"] = {
				54818, -- [1]
				54860, -- [2]
				56956, -- [3]
			},
		},
		["FOREMANSREINFORCEDHELMET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				30519, -- [1]
				30566, -- [2]
			},
			["icon"] = 135933,
			["name"] = "Foreman's Reinforced Helmet",
		},
		["WRATH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["name"] = "Wrath",
			["icon"] = 136006,
			["id"] = {
				5176, -- [1]
				3737, -- [2]
				5177, -- [3]
				5178, -- [4]
				5179, -- [5]
				5180, -- [6]
				5181, -- [7]
				5182, -- [8]
				5183, -- [9]
				5184, -- [10]
				5289, -- [11]
				5290, -- [12]
				5291, -- [13]
				5292, -- [14]
				6780, -- [15]
				6781, -- [16]
				6806, -- [17]
				8905, -- [18]
				8906, -- [19]
				9739, -- [20]
				9911, -- [21]
				9912, -- [22]
				17144, -- [23]
				18104, -- [24]
				20698, -- [25]
				21667, -- [26]
				21807, -- [27]
				26984, -- [28]
				26985, -- [29]
				31784, -- [30]
				43619, -- [31]
				48459, -- [32]
				48461, -- [33]
				52501, -- [34]
				57648, -- [35]
				59986, -- [36]
				62793, -- [37]
				63259, -- [38]
				63569, -- [39]
				65862, -- [40]
				69968, -- [41]
				75327, -- [42]
			},
		},
		["AZURESILKVEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Azure Silk Vest",
			["icon"] = 132149,
			["id"] = {
				3859, -- [1]
				3888, -- [2]
			},
		},
		["CURSEOFWEAKNESS"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				702, -- [1]
				729, -- [2]
				1031, -- [3]
				1108, -- [4]
				1109, -- [5]
				1393, -- [6]
				1394, -- [7]
				6205, -- [8]
				6206, -- [9]
				7646, -- [10]
				7647, -- [11]
				8552, -- [12]
				11707, -- [13]
				11708, -- [14]
				11709, -- [15]
				11710, -- [16]
				11980, -- [17]
				12493, -- [18]
				12741, -- [19]
				17227, -- [20]
				18267, -- [21]
				21007, -- [22]
				27224, -- [23]
				30909, -- [24]
				50511, -- [25]
			},
			["icon"] = 136138,
			["name"] = "Curse of Weakness",
		},
		["FROSTSAVAGELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59588, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostsavage Leggings",
		},
		["COYOTESTEAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Coyote Steak",
			["icon"] = 134021,
			["id"] = {
				2541, -- [1]
				2561, -- [2]
			},
		},
		["DIVINESPIRIT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				14752, -- [1]
				6386, -- [2]
				14818, -- [3]
				14819, -- [4]
				14820, -- [5]
				16875, -- [6]
				27841, -- [7]
				27843, -- [8]
				25312, -- [9]
				39234, -- [10]
				48073, -- [11]
			},
			["name"] = "Divine Spirit",
			["icon"] = 135898,
			["castTime"] = 0,
		},
		["SMELTFELIRON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				29356, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Smelt Fel Iron",
		},
		["AIMEDSHOT"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = -999500,
			["id"] = {
				19434, -- [1]
				20900, -- [2]
				20901, -- [3]
				20902, -- [4]
				20903, -- [5]
				20904, -- [6]
				20931, -- [7]
				20932, -- [8]
				20933, -- [9]
				20934, -- [10]
				20935, -- [11]
				27632, -- [12]
				27065, -- [13]
				30614, -- [14]
				31623, -- [15]
				38370, -- [16]
				38861, -- [17]
				44271, -- [18]
				46460, -- [19]
				48871, -- [20]
				49049, -- [21]
				49050, -- [22]
				52718, -- [23]
				54615, -- [24]
				59243, -- [25]
				60954, -- [26]
				65883, -- [27]
			},
			["icon"] = 135130,
			["name"] = "Aimed Shot",
		},
		["GLYPHOFSCOURGESTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				57224, -- [1]
				58642, -- [2]
				58723, -- [3]
				69961, -- [4]
			},
			["icon"] = 132918,
			["name"] = "Glyph of Scourge Strike",
		},
		["FIREOIL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Fire Oil",
			["icon"] = 136243,
			["id"] = {
				7837, -- [1]
				7839, -- [2]
			},
		},
		["ABOLISHPOISON"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Abolish Poison",
			["icon"] = 136068,
			["id"] = {
				2893, -- [1]
				2897, -- [2]
				14253, -- [3]
			},
		},
		["GLYPHOFFADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Fade",
			["icon"] = 136243,
			["id"] = {
				55684, -- [1]
				56164, -- [2]
				57184, -- [3]
			},
		},
		["SWOOP"] = {
			["maxRange"] = 25,
			["minRange"] = 8,
			["id"] = {
				52825, -- [1]
				5708, -- [2]
				18144, -- [3]
				23919, -- [4]
				37012, -- [5]
				51919, -- [6]
				55079, -- [7]
				55936, -- [8]
			},
			["castTime"] = 0,
			["icon"] = 132188,
			["name"] = "Swoop",
		},
		["FROSTWOVENGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55904, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostwoven Gloves",
		},
		["BIGIRONBOMB"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Big Iron Bomb",
			["icon"] = 136243,
			["id"] = {
				3967, -- [1]
				4023, -- [2]
				4069, -- [3]
			},
		},
		["RUNICMANAPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53837, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Runic Mana Potion",
		},
		["NIGHTSCAPEHEADBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Nightscape Headband",
			["icon"] = 136247,
			["id"] = {
				10507, -- [1]
				10508, -- [2]
			},
		},
		["GLYPHOFRENEW"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Renew",
			["icon"] = 136243,
			["id"] = {
				55674, -- [1]
				56178, -- [2]
				57197, -- [3]
			},
		},
		["CURSEOFTHEELEMENTS"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				1490, -- [1]
				7666, -- [2]
				11721, -- [3]
				11722, -- [4]
				11723, -- [5]
				11724, -- [6]
				27228, -- [7]
				36831, -- [8]
				44332, -- [9]
				47865, -- [10]
			},
			["name"] = "Curse of the Elements",
			["icon"] = 136130,
			["castTime"] = 0,
		},
		["BRONZEBANDOFFORCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Bronze Band of Force",
			["icon"] = 134072,
			["id"] = {
				37818, -- [1]
			},
		},
		["FELCLOTHHOOD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Felcloth Hood",
			["icon"] = 132149,
			["id"] = {
				18442, -- [1]
			},
		},
		["CREATESPELLSTONEGREATER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				17727, -- [1]
				17732, -- [2]
			},
			["castTime"] = 5000,
			["icon"] = 134131,
			["name"] = "Create Spellstone (Greater)",
		},
		["SCROLLOFSTRENGTHIV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Strength IV",
			["icon"] = 132918,
			["id"] = {
				58487, -- [1]
			},
		},
		["MASTEROFANATOMY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53125, -- [1]
				53662, -- [2]
				53663, -- [3]
				53664, -- [4]
				53665, -- [5]
				53666, -- [6]
			},
			["icon"] = 134338,
			["name"] = "Master of Anatomy",
		},
		["TELEPORTSHATTRATH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				33690, -- [1]
				35715, -- [2]
				46149, -- [3]
			},
			["icon"] = 135760,
			["name"] = "Teleport: Shattrath",
		},
		["TRICKSOFTHETRADE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				57933, -- [1]
				57934, -- [2]
				59628, -- [3]
				70804, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 236283,
			["name"] = "Tricks of the Trade",
		},
		["RIGHTEOUSGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55300, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Righteous Gauntlets",
		},
		["BLINDINGPOWDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				6510, -- [1]
				6511, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 133588,
			["name"] = "Blinding Powder",
		},
		["ROUGHCOPPERBOMB"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Rough Copper Bomb",
			["icon"] = 136243,
			["id"] = {
				3923, -- [1]
				3985, -- [2]
				4064, -- [3]
			},
		},
		["PACKOFENDLESSPOCKETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60643, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Pack of Endless Pockets",
		},
		["CRIMSONSILKPANTALOONS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Crimson Silk Pantaloons",
			["icon"] = 132149,
			["id"] = {
				8799, -- [1]
				8801, -- [2]
			},
		},
		["LUSTROUSCHALCEDONY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53941, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Lustrous Chalcedony",
		},
		["SHELLSHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				26064, -- [1]
				26065, -- [2]
				40087, -- [3]
				46327, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 132199,
			["name"] = "Shell Shield",
		},
		["TWOHANDEDAXES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Two-Handed Axes",
			["icon"] = 132395,
			["id"] = {
				197, -- [1]
				15985, -- [2]
			},
		},
		["DARKLEATHERBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Dark Leather Boots",
			["icon"] = 136247,
			["id"] = {
				2167, -- [1]
				2181, -- [2]
			},
		},
		["BOLTOFNETHERWEAVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				26745, -- [1]
			},
			["icon"] = 132149,
			["name"] = "Bolt of Netherweave",
		},
		["HEALINGINJECTORKIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56476, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Healing Injector Kit",
		},
		["BLACKMAGEWEAVESHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Black Mageweave Shoulders",
			["icon"] = 132149,
			["id"] = {
				12074, -- [1]
				12117, -- [2]
			},
		},
		["FROSTBRANDWEAPON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8033, -- [1]
				8035, -- [2]
				8038, -- [3]
				8039, -- [4]
				10456, -- [5]
				10457, -- [6]
				16355, -- [7]
				16356, -- [8]
				16357, -- [9]
				16358, -- [10]
				25500, -- [11]
				58794, -- [12]
				58795, -- [13]
				58796, -- [14]
			},
			["icon"] = 135847,
			["name"] = "Frostbrand Weapon",
		},
		["TRANSMUTESKYFLAREDIAMOND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				57425, -- [1]
			},
			["icon"] = 134085,
			["name"] = "Transmute: Skyflare Diamond",
		},
		["PORTALDARNASSUS"] = {
			["maxRange"] = 10,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				11419, -- [1]
				11422, -- [2]
			},
			["icon"] = 135741,
			["name"] = "Portal: Darnassus",
		},
		["WRATHELIXIR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53746, -- [1]
				53841, -- [2]
			},
			["icon"] = 134737,
			["name"] = "Wrath Elixir",
		},
		["BLOODSTONEBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				56193, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Bloodstone Band",
		},
		["BITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				17261, -- [1]
				17253, -- [2]
				17254, -- [3]
				17255, -- [4]
				17256, -- [5]
				17257, -- [6]
				17258, -- [7]
				17259, -- [8]
				17260, -- [9]
				17262, -- [10]
				17263, -- [11]
				17264, -- [12]
				17265, -- [13]
				17266, -- [14]
				17267, -- [15]
				17268, -- [16]
				27050, -- [17]
				27348, -- [18]
				37454, -- [19]
				52473, -- [20]
				52474, -- [21]
			},
			["castTime"] = 0,
			["icon"] = 132127,
			["name"] = "Bite",
		},
		["NETHERSHOCK"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["id"] = {
				50479, -- [1]
				35334, -- [2]
				44957, -- [3]
				53584, -- [4]
				53586, -- [5]
				53587, -- [6]
				53588, -- [7]
				53589, -- [8]
				62347, -- [9]
			},
			["castTime"] = 0,
			["icon"] = 136214,
			["name"] = "Nether Shock",
		},
		["RUNEDSILVERROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 30000,
			["id"] = {
				7795, -- [1]
				7797, -- [2]
			},
			["icon"] = 135138,
			["name"] = "Runed Silver Rod",
		},
		["FELIRONBOMB"] = {
			["maxRange"] = 15,
			["minRange"] = 0,
			["castTime"] = 941,
			["id"] = {
				30216, -- [1]
				30310, -- [2]
				46024, -- [3]
				46184, -- [4]
				71592, -- [5]
				71787, -- [6]
			},
			["icon"] = 135826,
			["name"] = "Fel Iron Bomb",
		},
		["GRANDMASTERENCHANTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Grand Master Enchanter",
			["icon"] = 136244,
			["id"] = {
				51312, -- [1]
				65285, -- [2]
			},
		},
		["GOLDENDRAGONRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Golden Dragon Ring",
			["icon"] = 136243,
			["id"] = {
				25613, -- [1]
			},
		},
		["FLETCHERSGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Fletcher's Gloves",
			["icon"] = 136247,
			["id"] = {
				9145, -- [1]
				9150, -- [2]
			},
		},
		["PERCEPTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Perception",
			["icon"] = 136090,
			["id"] = {
				20600, -- [1]
				58985, -- [2]
			},
		},
		["LEGPLATESOFCONQUEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55187, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Legplates of Conquest",
		},
		["TRACKUNDEAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				19884, -- [1]
				20161, -- [2]
			},
			["icon"] = 136142,
			["name"] = "Track Undead",
		},
		["NIGHINVULNERABILITYBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				30570, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Nigh-Invulnerability Belt",
		},
		["TAUNT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53477, -- [1]
				355, -- [2]
				3196, -- [3]
				8133, -- [4]
				26281, -- [5]
				28140, -- [6]
				29060, -- [7]
				37017, -- [8]
				37486, -- [9]
				37548, -- [10]
				49613, -- [11]
				51774, -- [12]
				51775, -- [13]
				52154, -- [14]
				53798, -- [15]
				53799, -- [16]
				54794, -- [17]
				70428, -- [18]
			},
			["castTime"] = 0,
			["icon"] = 136080,
			["name"] = "Taunt",
		},
		["WHIRRINGBRONZEGIZMO"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Whirring Bronze Gizmo",
			["icon"] = 136243,
			["id"] = {
				3942, -- [1]
				4005, -- [2]
			},
		},
		["FROSTSAVAGEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59583, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostsavage Bracers",
		},
		["GLYPHOFHEALINGTOUCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Healing Touch",
			["icon"] = 136243,
			["id"] = {
				54825, -- [1]
				54869, -- [2]
				56945, -- [3]
			},
		},
		["GREATERARCANEELIXIR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Greater Arcane Elixir",
			["icon"] = 134827,
			["id"] = {
				16889, -- [1]
				17539, -- [2]
				17573, -- [3]
			},
		},
		["GUNSPECIALIZATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				20595, -- [1]
				5626, -- [2]
				5630, -- [3]
				5631, -- [4]
				5632, -- [5]
				5633, -- [6]
				5634, -- [7]
				5635, -- [8]
				5636, -- [9]
				5637, -- [10]
				5638, -- [11]
				5639, -- [12]
				5640, -- [13]
				5641, -- [14]
				5642, -- [15]
				5643, -- [16]
				5650, -- [17]
				5651, -- [18]
				5652, -- [19]
				5653, -- [20]
				5654, -- [21]
				5655, -- [22]
				5656, -- [23]
				5657, -- [24]
				5658, -- [25]
				5659, -- [26]
				5660, -- [27]
				5661, -- [28]
				5662, -- [29]
				5663, -- [30]
				5664, -- [31]
			},
			["icon"] = 134537,
			["name"] = "Gun Specialization",
		},
		["PRAYEROFMENDING"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				33076, -- [1]
				33110, -- [2]
				41635, -- [3]
				41637, -- [4]
				44583, -- [5]
				44586, -- [6]
				46045, -- [7]
				48110, -- [8]
				48111, -- [9]
				48112, -- [10]
				48113, -- [11]
			},
			["name"] = "Prayer of Mending",
			["icon"] = 135944,
			["castTime"] = 0,
		},
		["ORNATESARONITELEGPLATES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56554, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Ornate Saronite Legplates",
		},
		["HAUNT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				48181, -- [1]
				48184, -- [2]
				48210, -- [3]
				50091, -- [4]
				59161, -- [5]
				59163, -- [6]
				59164, -- [7]
			},
			["name"] = "Haunt",
			["icon"] = 236298,
			["castTime"] = 1500,
		},
		["GLYPHOFOVERPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Overpower",
			["icon"] = 132918,
			["id"] = {
				57161, -- [1]
				58386, -- [2]
				58400, -- [3]
			},
		},
		["ORNATESARONITEHAUBERK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56555, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Ornate Saronite Hauberk",
		},
		["ENCHANTBRACERSGREATERSPELLPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Bracers - Greater Spellpower",
			["icon"] = 136244,
			["id"] = {
				44635, -- [1]
			},
		},
		["HUNTERSMARK"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1130, -- [1]
				5298, -- [2]
				14323, -- [3]
				14324, -- [4]
				14325, -- [5]
				14431, -- [6]
				14432, -- [7]
				14434, -- [8]
				31615, -- [9]
				53338, -- [10]
				56303, -- [11]
			},
			["icon"] = 132212,
			["name"] = "Hunter's Mark",
		},
		["FROSTNOVA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				122, -- [1]
				497, -- [2]
				865, -- [3]
				866, -- [4]
				1194, -- [5]
				1225, -- [6]
				6131, -- [7]
				6132, -- [8]
				6644, -- [9]
				9915, -- [10]
				10230, -- [11]
				10231, -- [12]
				11831, -- [13]
				12674, -- [14]
				12748, -- [15]
				14907, -- [16]
				15063, -- [17]
				15531, -- [18]
				15532, -- [19]
				22645, -- [20]
				29849, -- [21]
				30094, -- [22]
				27088, -- [23]
				27387, -- [24]
				31250, -- [25]
				32192, -- [26]
				32365, -- [27]
				34326, -- [28]
				36989, -- [29]
				38033, -- [30]
				39035, -- [31]
				39063, -- [32]
				42917, -- [33]
				43426, -- [34]
				44177, -- [35]
				45905, -- [36]
				46555, -- [37]
				57629, -- [38]
				57668, -- [39]
				58458, -- [40]
				59253, -- [41]
				59995, -- [42]
				61376, -- [43]
				61462, -- [44]
				62597, -- [45]
				62605, -- [46]
				63912, -- [47]
				69571, -- [48]
				69060, -- [49]
				68198, -- [50]
				71320, -- [51]
				71929, -- [52]
				65792, -- [53]
			},
			["icon"] = 135848,
			["name"] = "Frost Nova",
		},
		["HEAVYBOREANLEATHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				50936, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Heavy Borean Leather",
		},
		["ELUNESGRACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				2651, -- [1]
				19289, -- [2]
				19291, -- [3]
				19292, -- [4]
				19293, -- [5]
				19357, -- [6]
				19358, -- [7]
				19359, -- [8]
				19360, -- [9]
				19361, -- [10]
			},
			["castTime"] = 0,
			["icon"] = 135900,
			["name"] = "Elune's Grace",
		},
		["WICKEDLEATHERHEADBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Wicked Leather Headband",
			["icon"] = 136243,
			["id"] = {
				19071, -- [1]
			},
		},
		["HEROICTHROW"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Heroic Throw",
			["icon"] = 132453,
			["id"] = {
				57755, -- [1]
			},
		},
		["POUNCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Pounce",
			["icon"] = 132142,
			["id"] = {
				9005, -- [1]
				9006, -- [2]
				9823, -- [3]
				9825, -- [4]
				9827, -- [5]
				9828, -- [6]
				27006, -- [7]
				39449, -- [8]
				43356, -- [9]
				49803, -- [10]
				54272, -- [11]
				55077, -- [12]
				61184, -- [13]
				64399, -- [14]
			},
		},
		["GREATERBLESSINGOFSANCTUARY"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Greater Blessing of Sanctuary",
			["icon"] = 135911,
			["id"] = {
				25899, -- [1]
				25951, -- [2]
			},
		},
		["DENSESTONESTATUE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Dense Stone Statue",
			["icon"] = 134230,
			["id"] = {
				32805, -- [1]
				32809, -- [2]
			},
		},
		["GLYPHOFBONESHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Bone Shield",
			["icon"] = 132918,
			["id"] = {
				57210, -- [1]
				58673, -- [2]
				58708, -- [3]
			},
		},
		["DENSEDYNAMITE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 941,
			["name"] = "Dense Dynamite",
			["icon"] = 135826,
			["id"] = {
				23063, -- [1]
				23070, -- [2]
				23095, -- [3]
			},
		},
		["MASTERBLACKSMITH"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				29845, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Master Blacksmith",
		},
		["ROUGHBRONZECUIRASS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Rough Bronze Cuirass",
			["icon"] = 132630,
			["id"] = {
				2670, -- [1]
				2750, -- [2]
			},
		},
		["HEAVYCOPPERBROADSWORD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Heavy Copper Broadsword",
			["icon"] = 135312,
			["id"] = {
				3292, -- [1]
				3298, -- [2]
			},
		},
		["CREATEFIRESTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				--6366, -- [1]
				607, -- [2]
				17951, -- [3]
				--17952, -- [4]
				--17953, -- [5]
				27250, -- [6]
				60219, -- [7]
				60220, -- [8]
			},
			["name"] = "Create Firestone",
			["icon"] = 132386,
			["castTime"] = 3000,
		},
		["TITANSTEELSHANKER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56234, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Titansteel Shanker",
		},
		["BREASTPLATEOFKINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34533, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Breastplate of Kings",
		},
		["HOLYWRATH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Holy Wrath",
			["icon"] = 135902,
			["id"] = {
				2812, -- [1]
				685, -- [2]
				10318, -- [3]
				10320, -- [4]
				23979, -- [5]
				28883, -- [6]
				27139, -- [7]
				32445, -- [8]
				48816, -- [9]
				48817, -- [10]
				52836, -- [11]
				53638, -- [12]
				57466, -- [13]
				69934, -- [14]
			},
		},
		["GLYPHOFDETERRENCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Deterrence",
			["icon"] = 136243,
			["id"] = {
				56850, -- [1]
				56875, -- [2]
				57000, -- [3]
			},
		},
		["NETHERCHAINSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34529, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Nether Chain Shirt",
		},
		["BAKEDMANTARAY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45569, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Baked Manta Ray",
		},
		["EARTHELEMENTALTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2062, -- [1]
				33663, -- [2]
				44130, -- [3]
			},
			["icon"] = 136024,
			["name"] = "Earth Elemental Totem",
		},
		["MAGEWEAVEBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Mageweave Bandage",
			["icon"] = 133689,
			["id"] = {
				10840, -- [1]
				10842, -- [2]
			},
		},
		["ELIXIROFGREATERINTELLECT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Greater Intellect",
			["icon"] = 136243,
			["id"] = {
				11465, -- [1]
				11497, -- [2]
			},
		},
		["DREAMWEAVEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Dreamweave Gloves",
			["icon"] = 132149,
			["id"] = {
				12067, -- [1]
				12111, -- [2]
			},
		},
		["GLYPHOFMENDING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Mending",
			["icon"] = 136243,
			["id"] = {
				56833, -- [1]
				56872, -- [2]
				56997, -- [3]
			},
		},
		["BRONZEAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Bronze Axe",
			["icon"] = 132408,
			["id"] = {
				2741, -- [1]
				2758, -- [2]
			},
		},
		["ENCHANTCHESTSUPERIORMANA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13917, -- [1]
				13919, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Superior Mana",
		},
		["BROWNLINENPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Brown Linen Pants",
			["icon"] = 136243,
			["id"] = {
				3914, -- [1]
				3916, -- [2]
			},
		},
		["BOLTOFRUNECLOTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Bolt of Runecloth",
			["icon"] = 132149,
			["id"] = {
				18401, -- [1]
				18470, -- [2]
			},
		},
		["ICESCALELEGARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50967, -- [1]
				60582, -- [2]
			},
			["icon"] = 136247,
			["name"] = "Icescale Leg Armor",
		},
		["STONECLAWTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				5730, -- [1]
				5731, -- [2]
				6390, -- [3]
				6391, -- [4]
				6392, -- [5]
				6400, -- [6]
				6401, -- [7]
				6402, -- [8]
				10427, -- [9]
				10428, -- [10]
				10429, -- [11]
				10430, -- [12]
				25525, -- [13]
				55277, -- [14]
				55278, -- [15]
				55328, -- [16]
				55329, -- [17]
				55330, -- [18]
				55332, -- [19]
				55333, -- [20]
				55335, -- [21]
				58580, -- [22]
				58581, -- [23]
				58582, -- [24]
				58589, -- [25]
				58590, -- [26]
				58591, -- [27]
			},
			["icon"] = 136097,
			["name"] = "Stoneclaw Totem",
		},
		["COBALTCHESTPIECE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				52570, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cobalt Chestpiece",
		},
		["SHIV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				5938, -- [1]
				5940, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 135428,
			["name"] = "Shiv",
		},
		["DENSEWEIGHTSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Dense Weightstone",
			["icon"] = 135259,
			["id"] = {
				16640, -- [1]
				16670, -- [2]
			},
		},
		["BLOODTHIRST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				23880, -- [1]
				23881, -- [2]
				23885, -- [3]
				23886, -- [4]
				23887, -- [5]
				23888, -- [6]
				23889, -- [7]
				23890, -- [8]
				23891, -- [9]
				23892, -- [10]
				23893, -- [11]
				23894, -- [12]
				23898, -- [13]
				23899, -- [14]
				23900, -- [15]
				25251, -- [16]
				30335, -- [17]
				30474, -- [18]
				30475, -- [19]
				30476, -- [20]
				31996, -- [21]
				31997, -- [22]
				31998, -- [23]
				33964, -- [24]
				35123, -- [25]
				35125, -- [26]
				35947, -- [27]
				35948, -- [28]
				35949, -- [29]
				39070, -- [30]
				39071, -- [31]
				39072, -- [32]
				40423, -- [33]
				55968, -- [34]
				55969, -- [35]
				55970, -- [36]
				57790, -- [37]
				57791, -- [38]
				57792, -- [39]
				60017, -- [40]
				71938, -- [41]
			},
			["castTime"] = 0,
			["icon"] = 136012,
			["name"] = "Bloodthirst",
		},
		["SILVEREDBRONZEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Silvered Bronze Boots",
			["icon"] = 132535,
			["id"] = {
				3331, -- [1]
				3346, -- [2]
			},
		},
		["APPRENTICELEATHERWORKER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Leatherworker",
			["icon"] = 133611,
			["id"] = {
				2155, -- [1]
			},
		},
		["GLYPHOFFEAR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Fear",
			["icon"] = 136243,
			["id"] = {
				56244, -- [1]
				56284, -- [2]
				57262, -- [3]
			},
		},
		["LIONHEARTED"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53411, -- [1]
				53409, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132486,
			["name"] = "Lionhearted",
		},
		["FINELEATHERTUNIC"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Fine Leather Tunic",
			["icon"] = 136247,
			["id"] = {
				3761, -- [1]
				3788, -- [2]
			},
		},
		["SCROLLOFSTAMINAII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Stamina II",
			["icon"] = 132918,
			["id"] = {
				50612, -- [1]
			},
		},
		["ARCANEELIXIR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Arcane Elixir",
			["icon"] = 134810,
			["id"] = {
				11390, -- [1]
				11461, -- [2]
				11496, -- [3]
			},
		},
		["TWILIGHTSERPENT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56184, -- [1]
				56201, -- [2]
			},
			["icon"] = 237242,
			["name"] = "Twilight Serpent",
		},
		["SMELTTITANSTEEL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				55208, -- [1]
			},
			["icon"] = 135811,
			["name"] = "Smelt Titansteel",
		},
		["SCROLLOFRECALLII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Recall II",
			["icon"] = 132918,
			["id"] = {
				60336, -- [1]
			},
		},
		["HANDOFSACRIFICE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Hand of Sacrifice",
			["icon"] = 135966,
			["id"] = {
				--6940, -- [1]
			},
		},
		["DARKICEBORNECHESTGUARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60613, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Dark Iceborne Chestguard",
		},
		["CREATESOULSTONEGREATER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				20756, -- [1]
				20768, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 136210,
			["name"] = "Create Soulstone (Greater)",
		},
		["CONCENTRATIONAURA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Concentration Aura",
			["icon"] = 135933,
			["id"] = {
				19746, -- [1]
				19747, -- [2]
			},
		},
		["BRONZEGREATSWORD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Bronze Greatsword",
			["icon"] = 135321,
			["id"] = {
				9986, -- [1]
				9989, -- [2]
			},
		},
		["SACRIFICE"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["id"] = {
				19438, -- [1]
				1050, -- [2]
				7812, -- [3]
				7885, -- [4]
				19439, -- [5]
				19440, -- [6]
				19441, -- [7]
				19442, -- [8]
				19443, -- [9]
				19444, -- [10]
				19445, -- [11]
				19446, -- [12]
				19447, -- [13]
				20381, -- [14]
				20382, -- [15]
				20383, -- [16]
				20384, -- [17]
				20385, -- [18]
				20386, -- [19]
				22651, -- [20]
				27273, -- [21]
				27492, -- [22]
				30115, -- [23]
				33587, -- [24]
				34661, -- [25]
				47985, -- [26]
				47986, -- [27]
				48001, -- [28]
				48002, -- [29]
			},
			["castTime"] = 0,
			["icon"] = 136190,
			["name"] = "Sacrifice",
		},
		["THORIUMSETTING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Thorium Setting",
			["icon"] = 136243,
			["id"] = {
				26880, -- [1]
			},
		},
		["TELEPORTSTORMWIND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				3561, -- [1]
				665, -- [2]
			},
			["icon"] = 135763,
			["name"] = "Teleport: Stormwind",
		},
		["THORIUMBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Thorium Boots",
			["icon"] = 132589,
			["id"] = {
				16652, -- [1]
			},
		},
		["RAISEALLY"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				46619, -- [1]
				61999, -- [2]
			},
			["icon"] = 136143,
			["name"] = "Raise Ally",
		},
		["MYSTICFROSTWOVENWRISTWRAPS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55913, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Mystic Frostwoven Wristwraps",
		},
		["FANOFKNIVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				51723, -- [1]
				52874, -- [2]
				61739, -- [3]
				61740, -- [4]
				61741, -- [5]
				61742, -- [6]
				61743, -- [7]
				61744, -- [8]
				61745, -- [9]
				61746, -- [10]
				63753, -- [11]
				65955, -- [12]
				67706, -- [13]
				69921, -- [14]
			},
			["castTime"] = 0,
			["icon"] = 236273,
			["name"] = "Fan of Knives",
		},
		["DEATHSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				45463, -- [1]
				45469, -- [2]
				45470, -- [3]
				49923, -- [4]
				49924, -- [5]
				49998, -- [6]
				49999, -- [7]
				53639, -- [8]
				60644, -- [9]
				66951, -- [10]
				66952, -- [11]
				66953, -- [12]
				71489, -- [13]
				66188, -- [14]
				66950, -- [15]
			},
			["icon"] = 237517,
			["name"] = "Death Strike",
		},
		["NIGHTSHOCKHOOD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60655, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Nightshock Hood",
		},
		["WARP"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				35346, -- [1]
				32920, -- [2]
				35348, -- [3]
				35779, -- [4]
				36908, -- [5]
				40432, -- [6]
				40949, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 135731,
			["name"] = "Warp",
		},
		["EARTHENLEGARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3763,
			["id"] = {
				62447, -- [1]
				62448, -- [2]
			},
			["icon"] = 136247,
			["name"] = "Earthen Leg Armor",
		},
		["BRILLIANTSARONITEHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59441, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Brilliant Saronite Helm",
		},
		["TITANSTEELDESTROYER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55369, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Titansteel Destroyer",
		},
		["CONSUMESHADOWS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				47988, -- [1]
				17767, -- [2]
				17776, -- [3]
				17850, -- [4]
				17851, -- [5]
				17852, -- [6]
				17853, -- [7]
				17854, -- [8]
				17855, -- [9]
				17856, -- [10]
				17857, -- [11]
				17859, -- [12]
				17860, -- [13]
				20387, -- [14]
				20388, -- [15]
				20389, -- [16]
				20390, -- [17]
				20391, -- [18]
				20392, -- [19]
				27272, -- [20]
				27491, -- [21]
				36472, -- [22]
				47987, -- [23]
				48003, -- [24]
				48004, -- [25]
				49739, -- [26]
				54501, -- [27]
			},
			["castTime"] = 0,
			["icon"] = 136121,
			["name"] = "Consume Shadows",
		},
		["GLYPHOFBARBARICINSULTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Barbaric Insults",
			["icon"] = 132918,
			["id"] = {
				57151, -- [1]
				58365, -- [2]
				58401, -- [3]
			},
		},
		["TRUESILVERSKELETONKEY"] = {
			["maxRange"] = 5,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Truesilver Skeleton Key",
			["icon"] = 136243,
			["id"] = {
				19651, -- [1]
				19668, -- [2]
				19672, -- [3]
			},
		},
		["GLYPHOFSTORMSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55446, -- [1]
				55559, -- [2]
				57248, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Stormstrike",
		},
		["STYLISHREDSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Stylish Red Shirt",
			["icon"] = 132149,
			["id"] = {
				3866, -- [1]
				3890, -- [2]
			},
		},
		["APPRENTICESKINNER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Skinner",
			["icon"] = 134366,
			["id"] = {
				8615, -- [1]
			},
		},
		["ENCHANTCHESTGREATERDEFENSE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Chest - Greater Defense",
			["icon"] = 135913,
			["id"] = {
				47766, -- [1]
			},
		},
		["RUNECLOTHPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runecloth Pants",
			["icon"] = 132149,
			["id"] = {
				18438, -- [1]
			},
		},
		["ENCHANTSHIELDSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13659, -- [1]
				13660, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Shield - Spirit",
		},
		["SEEDOFCORRUPTION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				27243, -- [1]
				27285, -- [2]
				32863, -- [3]
				32865, -- [4]
				36123, -- [5]
				37826, -- [6]
				38252, -- [7]
				39367, -- [8]
				43991, -- [9]
				44141, -- [10]
				47831, -- [11]
				47832, -- [12]
				47833, -- [13]
				47834, -- [14]
				47835, -- [15]
				47836, -- [16]
				70388, -- [17]
			},
			["name"] = "Seed of Corruption",
			["icon"] = 136193,
			["castTime"] = 2000,
		},
		["RUNICLEATHERPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runic Leather Pants",
			["icon"] = 136243,
			["id"] = {
				19091, -- [1]
			},
		},
		["RUNEDCOPPERBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Runed Copper Bracers",
			["icon"] = 132602,
			["id"] = {
				2664, -- [1]
				2745, -- [2]
			},
		},
		["FELINEGRACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Feline Grace",
			["icon"] = 132914,
			["id"] = {
				20719, -- [1]
				20722, -- [2]
			},
		},
		["ENCHANTEDLEATHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				17181, -- [1]
				17182, -- [2]
			},
			["icon"] = 134418,
			["name"] = "Enchanted Leather",
		},
		["ADAMANTITEGRENADE"] = {
			["maxRange"] = 45,
			["minRange"] = 0,
			["castTime"] = 941,
			["id"] = {
				30217, -- [1]
				30311, -- [2]
			},
			["icon"] = 135826,
			["name"] = "Adamantite Grenade",
		},
		["MANATIDETOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				16190, -- [1]
				17354, -- [2]
				17359, -- [3]
				17362, -- [4]
				17363, -- [5]
				39609, -- [6]
				39610, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 135861,
			["name"] = "Mana Tide Totem",
		},
		["TEMPEREDTITANSTEELTREADS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55376, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Tempered Titansteel Treads",
		},
		["NETHERWEAVEBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				26765, -- [1]
			},
			["icon"] = 132149,
			["name"] = "Netherweave Belt",
		},
		["GRANDMASTERFISHING"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				51293, -- [1]
				64484, -- [2]
				65293, -- [3]
			},
			["icon"] = 136245,
			["name"] = "Grand Master Fishing",
		},
		["DEMONARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				706, -- [1]
				733, -- [2]
				1086, -- [3]
				1087, -- [4]
				1384, -- [5]
				1404, -- [6]
				11733, -- [7]
				11734, -- [8]
				11735, -- [9]
				11736, -- [10]
				11737, -- [11]
				11738, -- [12]
				12956, -- [13]
				13787, -- [14]
				27260, -- [15]
				34881, -- [16]
				47793, -- [17]
				47889, -- [18]
			},
			["name"] = "Demon Armor",
			["icon"] = 136185,
			["castTime"] = 0,
		},
		["LIGHTLEATHERPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Light Leather Pants",
			["icon"] = 136247,
			["id"] = {
				9068, -- [1]
				9069, -- [2]
			},
		},
		["TRACKDEMONS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				19878, -- [1]
				20155, -- [2]
			},
			["icon"] = 136217,
			["name"] = "Track Demons",
		},
		["EARTHBINDTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2484, -- [1]
				2076, -- [2]
				15786, -- [3]
				38304, -- [4]
			},
			["icon"] = 136102,
			["name"] = "Earthbind Totem",
		},
		["GLYPHOFHEALTHSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Healthstone",
			["icon"] = 136243,
			["id"] = {
				56224, -- [1]
				56289, -- [2]
				57266, -- [3]
			},
		},
		["GREENLINENSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Green Linen Shirt",
			["icon"] = 132149,
			["id"] = {
				2396, -- [1]
				2418, -- [2]
			},
		},
		["FLAMESHOCK"] = {
			["maxRange"] = 25,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8050, -- [1]
				8051, -- [2]
				8052, -- [3]
				8053, -- [4]
				8054, -- [5]
				8055, -- [6]
				10447, -- [7]
				10448, -- [8]
				10449, -- [9]
				10450, -- [10]
				13729, -- [11]
				15039, -- [12]
				15096, -- [13]
				15616, -- [14]
				16804, -- [15]
				22423, -- [16]
				23038, -- [17]
				29228, -- [18]
				29229, -- [19]
				25457, -- [20]
				32967, -- [21]
				34354, -- [22]
				39529, -- [23]
				39590, -- [24]
				41115, -- [25]
				43303, -- [26]
				49232, -- [27]
				49233, -- [28]
				51588, -- [29]
				55613, -- [30]
				58940, -- [31]
				58971, -- [32]
				59684, -- [33]
			},
			["icon"] = 135813,
			["name"] = "Flame Shock",
		},
		["STRANGETAROT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Strange Tarot",
			["icon"] = 132918,
			["id"] = {
				59480, -- [1]
			},
		},
		["DESTRUCTIONHOLOGOGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				41320, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Destruction Holo-gogs",
		},
		["OBLITERATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				49020, -- [1]
				51423, -- [2]
				51424, -- [3]
				51425, -- [4]
				56061, -- [5]
				66972, -- [6]
				66973, -- [7]
				66974, -- [8]
				67725, -- [9]
				66198, -- [10]
				72360, -- [11]
			},
			["icon"] = 135771,
			["name"] = "Obliterate",
		},
		["ENCHANTGLOVESGATHERER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Gloves - Gatherer",
			["icon"] = 136244,
			["id"] = {
				44506, -- [1]
			},
		},
		["AQUADYNAMICFISHATTRACTOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Aquadynamic Fish Attractor",
			["icon"] = 134335,
			["id"] = {
				8089, -- [1]
				9271, -- [2]
				9272, -- [3]
			},
		},
		["GLYPHOFDISENGAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Disengage",
			["icon"] = 136243,
			["id"] = {
				56844, -- [1]
				57001, -- [2]
			},
		},
		["ORNATETIGERSEYENECKLACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Ornate Tigerseye Necklace",
			["icon"] = 136243,
			["id"] = {
				26928, -- [1]
			},
		},
		["ARCTICBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50949, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Arctic Belt",
		},
		["ACCURATEHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53892, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Accurate Huge Citrine",
		},
		["DEATHANDDECAY"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1882,
			["id"] = {
				37788, -- [1]
				39658, -- [2]
				43265, -- [3]
				49936, -- [4]
				49937, -- [5]
				49938, -- [6]
				52212, -- [7]
				53721, -- [8]
				54143, -- [9]
				56359, -- [10]
				60160, -- [11]
				60953, -- [12]
				61112, -- [13]
				61603, -- [14]
				71001, -- [15]
			},
			["icon"] = 136144,
			["name"] = "Death and Decay",
		},
		["ORNATESPYGLASS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Ornate Spyglass",
			["icon"] = 136243,
			["id"] = {
				6458, -- [1]
				6459, -- [2]
			},
		},
		["HEAVYMAGEWEAVEBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Heavy Mageweave Bandage",
			["icon"] = 133690,
			["id"] = {
				10841, -- [1]
				10843, -- [2]
			},
		},
		["GLYPHOFSTRANGULATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				57225, -- [1]
				58618, -- [2]
				58724, -- [3]
			},
			["icon"] = 132918,
			["name"] = "Glyph of Strangulate",
		},
		["DIVINEPLEA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Divine Plea",
			["icon"] = 237537,
			["id"] = {
				54428, -- [1]
			},
		},
		["FROSTRESISTANCETOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8181, -- [1]
				8183, -- [2]
				10478, -- [3]
				10479, -- [4]
				10480, -- [5]
				10481, -- [6]
				25560, -- [7]
				58741, -- [8]
				58745, -- [9]
			},
			["icon"] = 135866,
			["name"] = "Frost Resistance Totem",
		},
		["UNSTABLEAFFLICTION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				30108, -- [1]
				30404, -- [2]
				30405, -- [3]
				31117, -- [4]
				34438, -- [5]
				34439, -- [6]
				35183, -- [7]
				43522, -- [8]
				43523, -- [9]
				47841, -- [10]
				47843, -- [11]
				65812, -- [12]
				65813, -- [13]
			},
			["name"] = "Unstable Affliction",
			["icon"] = 136228,
			["castTime"] = 1500,
		},
		["RENEW"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				139, -- [1]
				860, -- [2]
				870, -- [3]
				890, -- [4]
				3070, -- [5]
				3071, -- [6]
				3072, -- [7]
				6073, -- [8]
				6074, -- [9]
				6075, -- [10]
				6076, -- [11]
				6077, -- [12]
				6078, -- [13]
				6079, -- [14]
				6080, -- [15]
				6081, -- [16]
				6082, -- [17]
				6083, -- [18]
				8362, -- [19]
				10927, -- [20]
				10928, -- [21]
				10929, -- [22]
				10930, -- [23]
				10931, -- [24]
				10932, -- [25]
				11640, -- [26]
				22168, -- [27]
				23895, -- [28]
				25058, -- [29]
				25315, -- [30]
				25352, -- [31]
				25984, -- [32]
				27606, -- [33]
				28807, -- [34]
				25221, -- [35]
				25222, -- [36]
				31325, -- [37]
				34423, -- [38]
				36679, -- [39]
				36969, -- [40]
				37260, -- [41]
				37978, -- [42]
				38210, -- [43]
				41456, -- [44]
				44174, -- [45]
				45859, -- [46]
				46192, -- [47]
				46563, -- [48]
				47079, -- [49]
				48067, -- [50]
				48068, -- [51]
				49263, -- [52]
				56332, -- [53]
				57777, -- [54]
				60004, -- [55]
				61967, -- [56]
				62333, -- [57]
				62441, -- [58]
				66537, -- [59]
				66177, -- [60]
				71932, -- [61]
			},
			["name"] = "Renew",
			["icon"] = 135953,
			["castTime"] = 0,
		},
		["FINDHERBS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2383, -- [1]
				8387, -- [2]
				8390, -- [3]
			},
			["icon"] = 133939,
			["name"] = "Find Herbs",
		},
		["GNOMISHMINDCONTROLCAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12907, -- [1]
				12918, -- [2]
				13180, -- [3]
				13181, -- [4]
				26740, -- [5]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Mind Control Cap",
		},
		["BASICCAMPFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				818, -- [1]
				1290, -- [2]
			},
			["icon"] = 135805,
			["name"] = "Basic Campfire",
		},
		["BATTLESTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Battle Stance",
			["icon"] = 132349,
			["id"] = {
				2457, -- [1]
				2467, -- [2]
				7165, -- [3]
				41099, -- [4]
				53792, -- [5]
			},
		},
		["GLACIALWAISTBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				60990, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Glacial Waistband",
		},
		["CROSSBOWS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				5011, -- [1]
				15995, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 135530,
			["name"] = "Crossbows",
		},
		["GLYPHOFICELANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56377, -- [1]
				56593, -- [2]
				56980, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Ice Lance",
		},
		["DREAMLESSSLEEPPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Dreamless Sleep Potion",
			["icon"] = 136243,
			["id"] = {
				15833, -- [1]
				15834, -- [2]
			},
		},
		["SCROLLOFSTAMINAVI"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Stamina VI",
			["icon"] = 132918,
			["id"] = {
				50618, -- [1]
			},
		},
		["TRUESILVERTRANSFORMER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Truesilver Transformer",
			["icon"] = 136243,
			["id"] = {
				23071, -- [1]
			},
		},
		["ENCHANTSTAFFSPELLPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Staff - Spellpower",
			["icon"] = 135913,
			["id"] = {
				62959, -- [1]
			},
		},
		["WRATHOFAIRTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2895, -- [1]
				3738, -- [2]
				68933, -- [3]
			},
			["icon"] = 136092,
			["name"] = "Wrath of Air Totem",
		},
		["NITROBOOSTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				54861, -- [1]
				55004, -- [2]
				55016, -- [3]
			},
			["icon"] = 135788,
			["name"] = "Nitro Boosts",
		},
		["MITHRILBLUNDERBUSS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Mithril Blunderbuss",
			["icon"] = 136243,
			["id"] = {
				12595, -- [1]
				12635, -- [2]
			},
		},
		["INTRICATEDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53925, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Intricate Dark Jade",
		},
		["FELIRONMUSKET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				30312, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Fel Iron Musket",
		},
		["JOURNEYMANCOOK"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Cook",
			["icon"] = 133971,
			["id"] = {
				3412, -- [1]
			},
		},
		["BLESSINGOFMIGHT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Blessing of Might",
			["icon"] = 135906,
			["id"] = {
				19740, -- [1]
				19741, -- [2]
				19834, -- [3]
				19835, -- [4]
				19836, -- [5]
				19837, -- [6]
				19838, -- [7]
				19839, -- [8]
				19840, -- [9]
				19841, -- [10]
				19842, -- [11]
				19843, -- [12]
				25291, -- [13]
				25399, -- [14]
				25962, -- [15]
				27140, -- [16]
				48931, -- [17]
				48932, -- [18]
				56520, -- [19]
			},
		},
		["SCROLLOFSPIRITVI"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Spirit VI",
			["icon"] = 132918,
			["id"] = {
				50609, -- [1]
			},
		},
		["REBIRTH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1882,
			["name"] = "Rebirth",
			["icon"] = 136080,
			["id"] = {
				20484, -- [1]
				20485, -- [2]
				20739, -- [3]
				20742, -- [4]
				20744, -- [5]
				20745, -- [6]
				20747, -- [7]
				20748, -- [8]
				20749, -- [9]
				20750, -- [10]
				26994, -- [11]
				34342, -- [12]
				35369, -- [13]
				41587, -- [14]
				44196, -- [15]
				44200, -- [16]
				48477, -- [17]
			},
		},
		["FLYINGCARPET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 20000,
			["id"] = {
				60969, -- [1]
				61451, -- [2]
			},
			["icon"] = 136249,
			["name"] = "Flying Carpet",
		},
		["FLASKOFSTONEBLOOD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53758, -- [1]
				53902, -- [2]
			},
			["icon"] = 236879,
			["name"] = "Flask of Stoneblood",
		},
		["GLYPHOFSCORCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Scorch",
			["icon"] = 136243,
			["id"] = {
				56371, -- [1]
				56595, -- [2]
				56982, -- [3]
			},
		},
		["EXPERTJEWELCRAFTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Expert Jewelcrafter",
			["icon"] = 134073,
			["id"] = {
				28896, -- [1]
			},
		},
		["SAPPHIRESIGNET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Sapphire Signet",
			["icon"] = 136243,
			["id"] = {
				26903, -- [1]
			},
		},
		["GLYPHOFDEATHGRIP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Death Grip",
			["icon"] = 132918,
			["id"] = {
				57213, -- [1]
				58626, -- [2]
				58628, -- [3]
				58713, -- [4]
				62259, -- [5]
				62261, -- [6]
			},
		},
		["COBALTGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55835, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cobalt Gauntlets",
		},
		["RUNICLEATHERGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runic Leather Gauntlets",
			["icon"] = 136243,
			["id"] = {
				19055, -- [1]
			},
		},
		["MOONFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["name"] = "Moonfire",
			["icon"] = 136243,
			["id"] = {
				563, -- [1]
				521, -- [2]
				539, -- [3]
				573, -- [4]
				880, -- [5]
				962, -- [6]
				5307, -- [7]
				8921, -- [8]
				8922, -- [9]
				8924, -- [10]
				8925, -- [11]
				8926, -- [12]
				8927, -- [13]
				8928, -- [14]
				8929, -- [15]
				8930, -- [16]
				8931, -- [17]
				8932, -- [18]
				8933, -- [19]
				8934, -- [20]
				8935, -- [21]
				9833, -- [22]
				9834, -- [23]
				9835, -- [24]
				9836, -- [25]
				9837, -- [26]
				9838, -- [27]
				15798, -- [28]
				20690, -- [29]
				21669, -- [30]
				22206, -- [31]
				23380, -- [32]
				24957, -- [33]
				27737, -- [34]
				26987, -- [35]
				26988, -- [36]
				31270, -- [37]
				31401, -- [38]
				32373, -- [39]
				32415, -- [40]
				37328, -- [41]
				43545, -- [42]
				45821, -- [43]
				45900, -- [44]
				47072, -- [45]
				48462, -- [46]
				48463, -- [47]
				52502, -- [48]
				57647, -- [49]
				59987, -- [50]
				65856, -- [51]
				75329, -- [52]
			},
		},
		["FROSTSAVAGEBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59582, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostsavage Belt",
		},
		["FROSTWEAVEPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Frostweave Pants",
			["icon"] = 132149,
			["id"] = {
				18424, -- [1]
			},
		},
		["RUNECLOTHSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runecloth Shoulders",
			["icon"] = 132149,
			["id"] = {
				18449, -- [1]
			},
		},
		["WHITELINENSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "White Linen Shirt",
			["icon"] = 132149,
			["id"] = {
				2393, -- [1]
				2415, -- [2]
			},
		},
		["ARTISANSCRIBE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Scribe",
			["icon"] = 237171,
			["id"] = {
				45378, -- [1]
			},
		},
		["ICYTOUCH"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				45477, -- [1]
				49723, -- [2]
				49896, -- [3]
				49903, -- [4]
				49904, -- [5]
				49909, -- [6]
				50349, -- [7]
				52372, -- [8]
				52378, -- [9]
				53549, -- [10]
				55313, -- [11]
				55331, -- [12]
				59011, -- [13]
				59131, -- [14]
				60952, -- [15]
				70589, -- [16]
				70591, -- [17]
				66021, -- [18]
				67718, -- [19]
				69916, -- [20]
			},
			["icon"] = 237526,
			["name"] = "Icy Touch",
		},
		["WORMDELIGHT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45551, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Worm Delight",
		},
		["FIGURINEJADEOWL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Figurine - Jade Owl",
			["icon"] = 136243,
			["id"] = {
				26872, -- [1]
			},
		},
		["CORPSEEXPLOSION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				17616, -- [1]
				43999, -- [2]
				49158, -- [3]
				50444, -- [4]
				51325, -- [5]
				51326, -- [6]
				51327, -- [7]
				51328, -- [8]
				53717, -- [9]
				61614, -- [10]
			},
			["icon"] = 136133,
			["name"] = "Corpse Explosion",
		},
		["ENCHANTCLOAKMAJORAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Cloak - Major Agility",
			["icon"] = 136244,
			["id"] = {
				60663, -- [1]
			},
		},
		["ENCHANTWEAPONGREATERSTRIKING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13943, -- [1]
				13944, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Weapon - Greater Striking",
		},
		["GRANDMASTERSKINNER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				50307, -- [1]
				65290, -- [2]
			},
			["icon"] = 134366,
			["name"] = "Grand Master Skinner",
		},
		["ENCHANTGLOVESBLASTING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				33993, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Gloves - Blasting",
		},
		["HELMOFCOMMAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55302, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Helm of Command",
		},
		["RUPTURE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1943, -- [1]
				6736, -- [2]
				8639, -- [3]
				8640, -- [4]
				8641, -- [5]
				8642, -- [6]
				11273, -- [7]
				11274, -- [8]
				11275, -- [9]
				11276, -- [10]
				11277, -- [11]
				11278, -- [12]
				14874, -- [13]
				14903, -- [14]
				15583, -- [15]
				26867, -- [16]
				48671, -- [17]
				48672, -- [18]
			},
			["castTime"] = 0,
			["icon"] = 132302,
			["name"] = "Rupture",
		},
		["EARTHSHADOWRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				58143, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Earthshadow Ring",
		},
		["WHIRLWIND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Whirlwind",
			["icon"] = 132369,
			["id"] = {
				1680, -- [1]
				1685, -- [2]
				8989, -- [3]
				9633, -- [4]
				13736, -- [5]
				15576, -- [6]
				15577, -- [7]
				15578, -- [8]
				15589, -- [9]
				17207, -- [10]
				24236, -- [11]
				26038, -- [12]
				26083, -- [13]
				26084, -- [14]
				26686, -- [15]
				28334, -- [16]
				28335, -- [17]
				29851, -- [18]
				29852, -- [19]
				29573, -- [20]
				31737, -- [21]
				31738, -- [22]
				31909, -- [23]
				31910, -- [24]
				33238, -- [25]
				33239, -- [26]
				33500, -- [27]
				36132, -- [28]
				36142, -- [29]
				36175, -- [30]
				36981, -- [31]
				36982, -- [32]
				37582, -- [33]
				37583, -- [34]
				37640, -- [35]
				37641, -- [36]
				37704, -- [37]
				38618, -- [38]
				38619, -- [39]
				39232, -- [40]
				40236, -- [41]
				40653, -- [42]
				40654, -- [43]
				41056, -- [44]
				41057, -- [45]
				41058, -- [46]
				41059, -- [47]
				41061, -- [48]
				41097, -- [49]
				41098, -- [50]
				41194, -- [51]
				41195, -- [52]
				41399, -- [53]
				41400, -- [54]
				43442, -- [55]
				44949, -- [56]
				45895, -- [57]
				45896, -- [58]
				46270, -- [59]
				46271, -- [60]
				48280, -- [61]
				48281, -- [62]
				49807, -- [63]
				50228, -- [64]
				50229, -- [65]
				50622, -- [66]
				52027, -- [67]
				52028, -- [68]
				52977, -- [69]
				54797, -- [70]
				55266, -- [71]
				55267, -- [72]
				55463, -- [73]
				55977, -- [74]
				56408, -- [75]
				59322, -- [76]
				59323, -- [77]
				59549, -- [78]
				59550, -- [79]
				61076, -- [80]
				61078, -- [81]
				61136, -- [82]
				61137, -- [83]
				61139, -- [84]
				63805, -- [85]
				63806, -- [86]
				63807, -- [87]
				63808, -- [88]
				65510, -- [89]
				67037, -- [90]
				67716, -- [91]
			},
		},
		["ROCKBITERWEAPON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8017, -- [1]
				8018, -- [2]
				8019, -- [3]
				8020, -- [4]
				8021, -- [5]
				8022, -- [6]
				10399, -- [7]
				10401, -- [8]
				10402, -- [9]
				16314, -- [10]
				16315, -- [11]
				16316, -- [12]
				16317, -- [13]
				16318, -- [14]
				33640, -- [15]
				36494, -- [16]
				36495, -- [17]
				36496, -- [18]
				36744, -- [19]
				36750, -- [20]
				36751, -- [21]
				36752, -- [22]
				36753, -- [23]
				36754, -- [24]
				36755, -- [25]
				36756, -- [26]
				36757, -- [27]
				36758, -- [28]
				36759, -- [29]
				36760, -- [30]
				36761, -- [31]
			},
			["icon"] = 136086,
			["name"] = "Rockbiter Weapon",
		},
		["RUNEDTITANIUMROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 30000,
			["name"] = "Runed Titanium Rod",
			["icon"] = 134923,
			["id"] = {
				60619, -- [1]
			},
		},
		["SCROLLOFSTAMINAV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Stamina V",
			["icon"] = 132918,
			["id"] = {
				50617, -- [1]
			},
		},
		["CONJUREMANAJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				3552, -- [1]
				3553, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 134105,
			["name"] = "Conjure Mana Jade",
		},
		["MONGOOSEBITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1495, -- [1]
				1549, -- [2]
				14269, -- [3]
				14270, -- [4]
				14271, -- [5]
				14341, -- [6]
				14342, -- [7]
				14343, -- [8]
				36916, -- [9]
				53339, -- [10]
			},
			["icon"] = 132215,
			["name"] = "Mongoose Bite",
		},
		["SMOOTHSUNCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53853, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Smooth Sun Crystal",
		},
		["GREENSILKENSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Green Silken Shoulders",
			["icon"] = 132149,
			["id"] = {
				8774, -- [1]
				8775, -- [2]
			},
		},
		["ENCHANTCHESTSUPERHEALTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Chest - Super Health",
			["icon"] = 136244,
			["id"] = {
				47900, -- [1]
			},
		},
		["SPELLLOCK"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				19244, -- [1]
				19647, -- [2]
				19648, -- [3]
				19650, -- [4]
				20433, -- [5]
				20434, -- [6]
				24259, -- [7]
				30849, -- [8]
				67519, -- [9]
			},
			["castTime"] = 0,
			["icon"] = 136174,
			["name"] = "Spell Lock",
		},
		["PERSISTENTEARTHSIEGEDIAMOND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55402, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Persistent Earthsiege Diamond",
		},
		["FIRESUNDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				35751, -- [1]
			},
			["icon"] = 132839,
			["name"] = "Fire Sunder",
		},
		["FORCEFULDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53920, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Forceful Dark Jade",
		},
		["BLIZZARD"] = {
			["maxRange"] = 36,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				10, -- [1]
				1196, -- [2]
				3067, -- [3]
				3068, -- [4]
				6141, -- [5]
				6142, -- [6]
				8364, -- [7]
				8427, -- [8]
				8428, -- [9]
				10185, -- [10]
				10186, -- [11]
				10187, -- [12]
				10188, -- [13]
				10189, -- [14]
				10190, -- [15]
				15783, -- [16]
				19099, -- [17]
				20680, -- [18]
				21096, -- [19]
				21367, -- [20]
				25019, -- [21]
				26607, -- [22]
				27618, -- [23]
				30093, -- [24]
				27085, -- [25]
				27384, -- [26]
				29458, -- [27]
				29951, -- [28]
				31266, -- [29]
				31581, -- [30]
				33418, -- [31]
				33624, -- [32]
				33634, -- [33]
				34167, -- [34]
				34183, -- [35]
				34356, -- [36]
				37263, -- [37]
				37671, -- [38]
				38646, -- [39]
				39416, -- [40]
				41382, -- [41]
				41482, -- [42]
				42198, -- [43]
				42208, -- [44]
				42209, -- [45]
				42210, -- [46]
				42211, -- [47]
				42212, -- [48]
				42213, -- [49]
				42937, -- [50]
				42938, -- [51]
				42939, -- [52]
				42940, -- [53]
				44178, -- [54]
				46195, -- [55]
				47727, -- [56]
				49034, -- [57]
				50715, -- [58]
				56936, -- [59]
				58693, -- [60]
				59278, -- [61]
				59369, -- [62]
				59854, -- [63]
				61085, -- [64]
				62576, -- [65]
				62577, -- [66]
				62602, -- [67]
				62603, -- [68]
				62706, -- [69]
				64642, -- [70]
				64653, -- [71]
				70362, -- [72]
				70421, -- [73]
			},
			["icon"] = 135857,
			["name"] = "Blizzard",
		},
		["ARCLIGHTSPANNER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Arclight Spanner",
			["icon"] = 136243,
			["id"] = {
				7430, -- [1]
				7431, -- [2]
			},
		},
		["GNOMISHGOGGLES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				12897, -- [1]
				12910, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Goggles",
		},
		["CRABCAKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Crab Cake",
			["icon"] = 133950,
			["id"] = {
				2544, -- [1]
				2562, -- [2]
			},
		},
		["ENCHANTCHESTGREATERHEALTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13640, -- [1]
				13641, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Greater Health",
		},
		["BOLDBLOODSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53831, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Bold Bloodstone",
		},
		["COLDSNAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				--11958, -- [1]
				12472, -- [2]
			},
			["icon"] = 135865,
			["name"] = "Cold Snap",
		},
		["BRILLIANTTITANSTEELHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55374, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Brilliant Titansteel Helm",
		},
		["BLESSINGOFLIGHT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				19977, -- [1]
				19978, -- [2]
				19979, -- [3]
				19995, -- [4]
				19996, -- [5]
				19997, -- [6]
				26650, -- [7]
				32770, -- [8]
				71870, -- [9]
				71872, -- [10]
			},
			["castTime"] = 0,
			["icon"] = 135943,
			["name"] = "Blessing of Light",
		},
		["ENCHANTBRACERSTATS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				27905, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Stats",
		},
		["EXPERTFISHING"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 18816,
			["name"] = "Expert Fishing",
			["icon"] = 136245,
			["id"] = {
				19889, -- [1]
				7736, -- [2]
				54083, -- [3]
			},
		},
		["INKOFTHESKY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Ink of the Sky",
			["icon"] = 132918,
			["id"] = {
				57712, -- [1]
			},
		},
		["ANTIVENOM"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Anti-Venom",
			["icon"] = 136068,
			["id"] = {
				7932, -- [1]
				7934, -- [2]
				7936, -- [3]
			},
		},
		["GLYPHOFLESSERHEALINGWAVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Lesser Healing Wave",
			["icon"] = 136243,
			["id"] = {
				55438, -- [1]
				55552, -- [2]
				57244, -- [3]
			},
		},
		["SAVAGEREND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53580, -- [1]
				50498, -- [2]
				50871, -- [3]
				53578, -- [4]
				53579, -- [5]
				53581, -- [6]
				53582, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 132155,
			["name"] = "Savage Rend",
		},
		["MASTERSINSCRIPTIONOFTHECRAG"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 4000,
			["id"] = {
				61118, -- [1]
			},
			["icon"] = 237171,
			["name"] = "Master's Inscription of the Crag",
		},
		["WICKEDLEATHERPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Wicked Leather Pants",
			["icon"] = 136243,
			["id"] = {
				19083, -- [1]
			},
		},
		["DREAMWEAVECIRCLET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Dreamweave Circlet",
			["icon"] = 132149,
			["id"] = {
				12092, -- [1]
				12132, -- [2]
			},
		},
		["GLYPHOFHOLYNOVA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55683, -- [1]
				56167, -- [2]
				57187, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Holy Nova",
		},
		["APPRENTICEHERBALIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Herbalist",
			["icon"] = 136246,
			["id"] = {
				2372, -- [1]
			},
		},
		["DEMONICCIRCLETELEPORT"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				48020, -- [1]
			},
			["name"] = "Demonic Circle: Teleport",
			["icon"] = 237560,
			["castTime"] = 0,
		},
		["SCROLLOFRECALL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 9408,
			["name"] = "Scroll of Recall",
			["icon"] = 134940,
			["id"] = {
				48129, -- [1]
				48248, -- [2]
				60320, -- [3]
				60321, -- [4]
				60322, -- [5]
				60323, -- [6]
				60324, -- [7]
				60325, -- [8]
				60326, -- [9]
				60327, -- [10]
				60328, -- [11]
				60329, -- [12]
				60330, -- [13]
				60331, -- [14]
				60332, -- [15]
				60333, -- [16]
				60334, -- [17]
				60335, -- [18]
			},
		},
		["APPRENTICEFIRSTAID"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice First Aid",
			["icon"] = 135966,
			["id"] = {
				3279, -- [1]
			},
		},
		["COBALTTENDERIZER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55201, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cobalt Tenderizer",
		},
		["MAIM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Maim",
			["icon"] = 132134,
			["id"] = {
				22570, -- [1]
				49802, -- [2]
			},
		},
		["THEPLANAREDGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34541, -- [1]
			},
			["icon"] = 136241,
			["name"] = "The Planar Edge",
		},
		["DARKCOMMAND"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56222, -- [1]
			},
			["icon"] = 136088,
			["name"] = "Dark Command",
		},
		["EMBOSSEDLEATHERPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Embossed Leather Pants",
			["icon"] = 136247,
			["id"] = {
				3759, -- [1]
				3786, -- [2]
			},
		},
		["REDMAGEWEAVEBAG"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Red Mageweave Bag",
			["icon"] = 132149,
			["id"] = {
				12079, -- [1]
				12123, -- [2]
			},
		},
		["NERUBIANCHESTGUARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50956, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Nerubian Chestguard",
		},
		["RUNESCROLLOFFORTITUDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				69385, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Runescroll of Fortitude",
		},
		["MYSTICFROSTWOVENROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55911, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Mystic Frostwoven Robe",
		},
		["ETCHEDHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53873, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Etched Huge Citrine",
		},
		["SMELTCOBALT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				49252, -- [1]
			},
			["icon"] = 135811,
			["name"] = "Smelt Cobalt",
		},
		["GLYPHOFSEARINGPAIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Searing Pain",
			["icon"] = 136243,
			["id"] = {
				56226, -- [1]
				56293, -- [2]
				57270, -- [3]
			},
		},
		["DIAMONDCUTREFRACTORSCOPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				61468, -- [1]
				61471, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Diamond-cut Refractor Scope",
		},
		["FERALCOMBAT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Feral Combat",
			["icon"] = 135958,
			["id"] = {
				61977, -- [1]
			},
		},
		["SCROLLOFSTAMINAIV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Stamina IV",
			["icon"] = 132918,
			["id"] = {
				50616, -- [1]
			},
		},
		["CRIMSONSILKGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Crimson Silk Gloves",
			["icon"] = 132149,
			["id"] = {
				8804, -- [1]
				8805, -- [2]
			},
		},
		["HEAVYSILVERRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Heavy Silver Ring",
			["icon"] = 136243,
			["id"] = {
				25305, -- [1]
			},
		},
		["THEBIGGERONE"] = {
			["maxRange"] = 15,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				30461, -- [1]
				30558, -- [2]
			},
			["icon"] = 135826,
			["name"] = "The Bigger One",
		},
		["TRUESILVERCHAMPION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				10015, -- [1]
				10016, -- [2]
			},
			["icon"] = 135317,
			["name"] = "Truesilver Champion",
		},
		["SPIRITSTRIKE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				61196, -- [1]
				40325, -- [2]
				48423, -- [3]
				59304, -- [4]
				61193, -- [5]
				61194, -- [6]
				61195, -- [7]
				61197, -- [8]
				61198, -- [9]
			},
			["castTime"] = 0,
			["icon"] = 136096,
			["name"] = "Spirit Strike",
		},
		["LAYONHANDS"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Lay on Hands",
			["icon"] = 135928,
			["id"] = {
				633, -- [1]
				1878, -- [2]
				2800, -- [3]
				2804, -- [4]
				9257, -- [5]
				10310, -- [6]
				10311, -- [7]
				17233, -- [8]
				20233, -- [9]
				20236, -- [10]
				27154, -- [11]
				48788, -- [12]
				53778, -- [13]
			},
		},
		["SMOKEDROCKFIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45560, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Smoked Rockfin",
		},
		["CHESTPLATEOFCONQUEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55186, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Chestplate of Conquest",
		},
		["MANGLECAT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Mangle (Cat)",
			["icon"] = 132135,
			["id"] = {
				33876, -- [1]
				33982, -- [2]
				33983, -- [3]
				48565, -- [4]
				48566, -- [5]
			},
		},
		["GOBLINMORTAR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12716, -- [1]
				12768, -- [2]
				13237, -- [3]
				13238, -- [4]
			},
			["icon"] = 134535,
			["name"] = "Goblin Mortar",
		},
		["EXPERTENCHANTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				7416, -- [1]
			},
			["icon"] = 136244,
			["name"] = "Expert Enchanter",
		},
		["EARTHSHOCK"] = {
			["maxRange"] = 25,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8042, -- [1]
				8043, -- [2]
				8044, -- [3]
				8045, -- [4]
				8046, -- [5]
				8047, -- [6]
				8048, -- [7]
				8049, -- [8]
				10412, -- [9]
				10413, -- [10]
				10414, -- [11]
				10415, -- [12]
				10416, -- [13]
				10417, -- [14]
				13281, -- [15]
				13728, -- [16]
				15501, -- [17]
				22885, -- [18]
				23114, -- [19]
				24685, -- [20]
				25025, -- [21]
				26194, -- [22]
				25454, -- [23]
				43305, -- [24]
				47071, -- [25]
				49230, -- [26]
				49231, -- [27]
				54511, -- [28]
				56506, -- [29]
				57783, -- [30]
				60011, -- [31]
				61668, -- [32]
				65973, -- [33]
			},
			["icon"] = 136026,
			["name"] = "Earth Shock",
		},
		["LIONHEARTCHAMPION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34540, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Lionheart Champion",
		},
		["MINORREJUVENATIONPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Minor Rejuvenation Potion",
			["icon"] = 136243,
			["id"] = {
				2332, -- [1]
				2340, -- [2]
			},
		},
		["ENCHANTCHESTMAJORSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				33990, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Major Spirit",
		},
		["SWIPECAT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Swipe (Cat)",
			["icon"] = 134296,
			["id"] = {
				62078, -- [1]
			},
		},
		["BLESSINGOFFREEDOM"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				1044, -- [1]
				1909, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 135968,
			["name"] = "Blessing of Freedom",
		},
		["FLAMETONGUEWEAPON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8024, -- [1]
				8025, -- [2]
				8027, -- [3]
				8030, -- [4]
				8031, -- [5]
				8032, -- [6]
				10446, -- [7]
				16339, -- [8]
				16341, -- [9]
				16342, -- [10]
				16347, -- [11]
				16348, -- [12]
				25489, -- [13]
				58785, -- [14]
				58789, -- [15]
				58790, -- [16]
				65979, -- [17]
			},
			["icon"] = 135814,
			["name"] = "Flametongue Weapon",
		},
		["JOURNEYMANBLACKSMITH"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Blacksmith",
			["icon"] = 136241,
			["id"] = {
				2021, -- [1]
			},
		},
		["THICKLEATHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Thick Leather",
			["icon"] = 136243,
			["id"] = {
				20650, -- [1]
				20653, -- [2]
			},
		},
		["DEATHGRIP"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				49560, -- [1]
				49575, -- [2]
				49576, -- [3]
				51399, -- [4]
				53276, -- [5]
				55719, -- [6]
				57602, -- [7]
				57603, -- [8]
				57604, -- [9]
				61094, -- [10]
				64429, -- [11]
				64430, -- [12]
				64431, -- [13]
				70564, -- [14]
				66017, -- [15]
			},
			["icon"] = 237532,
			["name"] = "Death Grip",
		},
		["FEROCIOUSBITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Ferocious Bite",
			["icon"] = 132127,
			["id"] = {
				22568, -- [1]
				22569, -- [2]
				22827, -- [3]
				22828, -- [4]
				22829, -- [5]
				22830, -- [6]
				22831, -- [7]
				22832, -- [8]
				27557, -- [9]
				31018, -- [10]
				24248, -- [11]
				48576, -- [12]
				48577, -- [13]
			},
		},
		["MASTERJEWELCRAFTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				28901, -- [1]
			},
			["icon"] = 134073,
			["name"] = "Master Jewelcrafter",
		},
		["SAPPHIREPENDANTOFWINTERNIGHT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Sapphire Pendant of Winter Night",
			["icon"] = 136243,
			["id"] = {
				26908, -- [1]
			},
		},
		["INSCRIBEDHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53872, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Inscribed Huge Citrine",
		},
		["GLOWINGSHADOWDRAENITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28925, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Glowing Shadow Draenite",
		},
		["FIRSTAID"] = {
			["maxRange"] = 15,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				746, -- [1]
				1159, -- [2]
				3267, -- [3]
				3268, -- [4]
				3273, -- [5]
				3274, -- [6]
				7162, -- [7]
				7924, -- [8]
				7926, -- [9]
				7927, -- [10]
				10838, -- [11]
				10839, -- [12]
				10846, -- [13]
				18608, -- [14]
				18610, -- [15]
				23567, -- [16]
				23568, -- [17]
				23569, -- [18]
				23696, -- [19]
				24412, -- [20]
				24413, -- [21]
				24414, -- [22]
				30020, -- [23]
				27028, -- [24]
				27030, -- [25]
				27031, -- [26]
				45542, -- [27]
				45543, -- [28]
				45544, -- [29]
				51803, -- [30]
				51809, -- [31]
				51811, -- [32]
				51827, -- [33]
			},
			["icon"] = 135915,
			["name"] = "First Aid",
		},
		["ENCHANTEDTHORIUM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				17180, -- [1]
				17184, -- [2]
				70524, -- [3]
			},
			["icon"] = 133229,
			["name"] = "Enchanted Thorium",
		},
		["FROSTGRENADES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				39973, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Frost Grenades",
		},
		["STEELPLATEHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Steel Plate Helm",
			["icon"] = 133071,
			["id"] = {
				9935, -- [1]
				9936, -- [2]
			},
		},
		["GLYPHOFRAKE"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				54820, -- [1]
				54821, -- [2]
				54863, -- [3]
				56952, -- [4]
			},
			["icon"] = 236164,
			["name"] = "Glyph of Rake",
		},
		["POLEARMS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				200, -- [1]
				15991, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 135129,
			["name"] = "Polearms",
		},
		["RUNEOFSPELLBREAKING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				54447, -- [1]
				54449, -- [2]
			},
			["icon"] = 136120,
			["name"] = "Rune of Spellbreaking",
		},
		["MOLLE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				54710, -- [1]
				56472, -- [2]
			},
			["icon"] = 133871,
			["name"] = "MOLL-E",
		},
		["SAVAGESARONITEHAUBERK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55311, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Savage Saronite Hauberk",
		},
		["CUREDHEAVYHIDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Cured Heavy Hide",
			["icon"] = 136247,
			["id"] = {
				3818, -- [1]
				3820, -- [2]
			},
		},
		["ELIXIROFTHESAGES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Elixir of the Sages",
			["icon"] = 134809,
			["id"] = {
				17535, -- [1]
				17555, -- [2]
			},
		},
		["RUNICLEATHERSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runic Leather Shoulders",
			["icon"] = 136243,
			["id"] = {
				19103, -- [1]
			},
		},
		["GLYPHOFMAGEARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56383, -- [1]
				56597, -- [2]
				56984, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Mage Armor",
		},
		["GLYPHOFLIGHTNINGSHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Lightning Shield",
			["icon"] = 136243,
			["id"] = {
				55448, -- [1]
				55553, -- [2]
				57246, -- [3]
			},
		},
		["ELIXIROFMIGHTYTHOUGHTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				60367, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Elixir of Mighty Thoughts",
		},
		["HEAVYCOPPERMAUL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Heavy Copper Maul",
			["icon"] = 133055,
			["id"] = {
				7408, -- [1]
				7409, -- [2]
			},
		},
		["GYROMATICMICROADJUSTOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Gyromatic Micro-Adjustor",
			["icon"] = 136243,
			["id"] = {
				12590, -- [1]
				12631, -- [2]
			},
		},
		["UNHOLYPRESENCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				48265, -- [1]
				49772, -- [2]
				55222, -- [3]
			},
			["icon"] = 135775,
			["name"] = "Unholy Presence",
		},
		["GLYPHOFFLASHHEAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Flash Heal",
			["icon"] = 136243,
			["id"] = {
				55679, -- [1]
				56166, -- [2]
				57186, -- [3]
			},
		},
		["HEARTSEEKERSCOPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				55135, -- [1]
				56478, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Heartseeker Scope",
		},
		["CREATEFIRESTONEMAJOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				17953, -- [1]
				18171, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 132386,
			["name"] = "Create Firestone (Major)",
		},
		["BLIGHT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				9796, -- [1]
				10011, -- [2]
				10012, -- [3]
				59285, -- [4]
				61130, -- [5]
				69603, -- [6]
				69604, -- [7]
			},
			["icon"] = 136066,
			["name"] = "Blight",
		},
		["SCROLLOFSTRENGTHVI"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Strength VI",
			["icon"] = 132918,
			["id"] = {
				58489, -- [1]
			},
		},
		["CONJUREREFRESHMENT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				42955, -- [1]
				42956, -- [2]
				43988, -- [3]
				58660, -- [4]
			},
			["icon"] = 236212,
			["name"] = "Conjure Refreshment",
		},
		["ENCHANTBRACERSGREATERSTATS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Bracers - Greater Stats",
			["icon"] = 136244,
			["id"] = {
				44616, -- [1]
			},
		},
		["GOBLINMININGHELMET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12717, -- [1]
				12769, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Goblin Mining Helmet",
		},
		["MECHANIZEDSNOWGOGGLES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56465, -- [1]
				61481, -- [2]
				61482, -- [3]
				61483, -- [4]
			},
			["icon"] = 136243,
			["name"] = "Mechanized Snow Goggles",
		},
		["COARSESHARPENINGSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Coarse Sharpening Stone",
			["icon"] = 135249,
			["id"] = {
				2665, -- [1]
				2746, -- [2]
			},
		},
		["MANGLEBEAR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Mangle (Bear)",
			["icon"] = 132135,
			["id"] = {
				33878, -- [1]
				33986, -- [2]
				33987, -- [3]
				48563, -- [4]
				48564, -- [5]
			},
		},
		["ENDURINGDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53918, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Enduring Dark Jade",
		},
		["ICEBANEGIRDLE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				61009, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Icebane Girdle",
		},
		["GLYPHOFINCINERATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56242, -- [1]
				56268, -- [2]
				57257, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Incinerate",
		},
		["RUNEOFLICHBANE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				53331, -- [1]
			},
			["icon"] = 135914,
			["name"] = "Rune of Lichbane",
		},
		["CORRODEDSARONITEEDGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55183, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Corroded Saronite Edge",
		},
		["LESSERHEALINGWAVE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				8004, -- [1]
				8007, -- [2]
				8008, -- [3]
				8009, -- [4]
				8010, -- [5]
				8011, -- [6]
				10466, -- [7]
				10467, -- [8]
				10468, -- [9]
				10469, -- [10]
				10470, -- [11]
				10471, -- [12]
				27624, -- [13]
				28849, -- [14]
				28850, -- [15]
				25420, -- [16]
				44256, -- [17]
				46181, -- [18]
				49275, -- [19]
				49276, -- [20]
				49309, -- [21]
				66055, -- [22]
				75366, -- [23]
			},
			["icon"] = 136043,
			["name"] = "Lesser Healing Wave",
		},
		["STONEFORGEDCLAYMORE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36133, -- [1]
			},
			["icon"] = 135347,
			["name"] = "Stoneforged Claymore",
		},
		["LESSERHEAL"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				2050, -- [1]
				613, -- [2]
				622, -- [3]
				2051, -- [4]
				2052, -- [5]
				2053, -- [6]
				2056, -- [7]
				2057, -- [8]
				29170, -- [9]
			},
			["icon"] = 135929,
			["name"] = "Lesser Heal",
		},
		["HEAVYWOOLENPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Heavy Woolen Pants",
			["icon"] = 132149,
			["id"] = {
				3850, -- [1]
				3882, -- [2]
			},
		},
		["BLACKDUSKWEAVEROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55941, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Black Duskweave Robe",
		},
		["DUSKWEAVEWRISTWRAPS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55920, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Duskweave Wristwraps",
		},
		["NETHERWEAVEBAG"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				26746, -- [1]
			},
			["icon"] = 132149,
			["name"] = "Netherweave Bag",
		},
		["ORNATETHORIUMHANDAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Ornate Thorium Handaxe",
			["icon"] = 132403,
			["id"] = {
				16969, -- [1]
			},
		},
		["GLYPHOFTHEGHOUL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				57222, -- [1]
				58686, -- [2]
				58721, -- [3]
			},
			["icon"] = 132918,
			["name"] = "Glyph of the Ghoul",
		},
		["SOLIDSHARPENINGSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Solid Sharpening Stone",
			["icon"] = 135251,
			["id"] = {
				9918, -- [1]
				9924, -- [2]
			},
		},
		["GREATERHEAL"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				2060, -- [1]
				2065, -- [2]
				2067, -- [3]
				2068, -- [4]
				2069, -- [5]
				3085, -- [6]
				10963, -- [7]
				10964, -- [8]
				10965, -- [9]
				22009, -- [10]
				25314, -- [11]
				25350, -- [12]
				25983, -- [13]
				28809, -- [14]
				25210, -- [15]
				25213, -- [16]
				29564, -- [17]
				34119, -- [18]
				35096, -- [19]
				38580, -- [20]
				41378, -- [21]
				48062, -- [22]
				48063, -- [23]
				49348, -- [24]
				57775, -- [25]
				60003, -- [26]
				61965, -- [27]
				62334, -- [28]
				62442, -- [29]
				63760, -- [30]
				71931, -- [31]
				69963, -- [32]
			},
			["name"] = "Greater Heal",
			["icon"] = 135913,
			["castTime"] = 3000,
		},
		["BARBARICHARNESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Barbaric Harness",
			["icon"] = 136247,
			["id"] = {
				6661, -- [1]
				6662, -- [2]
			},
		},
		["RAKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				59882, -- [1]
				1822, -- [2]
				1823, -- [3]
				1824, -- [4]
				1827, -- [5]
				1828, -- [6]
				1829, -- [7]
				9904, -- [8]
				9905, -- [9]
				24331, -- [10]
				24332, -- [11]
				27556, -- [12]
				27638, -- [13]
				27003, -- [14]
				36332, -- [15]
				48573, -- [16]
				48574, -- [17]
				53499, -- [18]
				54668, -- [19]
				59881, -- [20]
				59883, -- [21]
				59884, -- [22]
				59885, -- [23]
				59886, -- [24]
			},
			["castTime"] = 0,
			["icon"] = 132122,
			["name"] = "Rake",
		},
		["MASTERALCHEMIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				28597, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Master Alchemist",
		},
		["HEAVYJADERING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Heavy Jade Ring",
			["icon"] = 136243,
			["id"] = {
				36524, -- [1]
			},
		},
		["SCROLLOFSTAMINAVII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50619, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Stamina VII",
		},
		["DISMANTLE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				51722, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 236272,
			["name"] = "Dismantle",
		},
		["STEELBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Steel Breastplate",
			["icon"] = 132740,
			["id"] = {
				9916, -- [1]
				9917, -- [2]
			},
		},
		["DETECTGREATERINVISIBILITY"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				11743, -- [1]
				11788, -- [2]
				16882, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 136152,
			["name"] = "Detect Greater Invisibility",
		},
		["NETHERWEAVEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				26770, -- [1]
			},
			["icon"] = 132149,
			["name"] = "Netherweave Gloves",
		},
		["MYSTICFROSTWOVENSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55910, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Mystic Frostwoven Shoulders",
		},
		["SCROLLOFAGILITYII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Agility II",
			["icon"] = 132918,
			["id"] = {
				58473, -- [1]
			},
		},
		["ENCHANTWEAPONSTRIKING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13693, -- [1]
				13694, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Weapon - Striking",
		},
		["REGROWTH"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 1882,
			["name"] = "Regrowth",
			["icon"] = 136085,
			["id"] = {
				8936, -- [1]
				3734, -- [2]
				8937, -- [3]
				8938, -- [4]
				8939, -- [5]
				8940, -- [6]
				8941, -- [7]
				8942, -- [8]
				8943, -- [9]
				8944, -- [10]
				8945, -- [11]
				9750, -- [12]
				9751, -- [13]
				9856, -- [14]
				9857, -- [15]
				9858, -- [16]
				9859, -- [17]
				9860, -- [18]
				9861, -- [19]
				16561, -- [20]
				20665, -- [21]
				22373, -- [22]
				22695, -- [23]
				27637, -- [24]
				28744, -- [25]
				26980, -- [26]
				34361, -- [27]
				39000, -- [28]
				39125, -- [29]
				48442, -- [30]
				48443, -- [31]
				66067, -- [32]
				69882, -- [33]
			},
		},
		["ONEHANDEDSWORDS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				201, -- [1]
				1847, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132223,
			["name"] = "One-Handed Swords",
		},
		["BLESSINGOFWISDOM"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Blessing of Wisdom",
			["icon"] = 135970,
			["id"] = {
				19742, -- [1]
				19743, -- [2]
				19850, -- [3]
				19852, -- [4]
				19853, -- [5]
				19854, -- [6]
				19855, -- [7]
				19856, -- [8]
				19857, -- [9]
				19858, -- [10]
				25290, -- [11]
				25398, -- [12]
				25961, -- [13]
				27142, -- [14]
				48935, -- [15]
				48936, -- [16]
				56521, -- [17]
			},
		},
		["WINDFORGEDRAPIER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36131, -- [1]
			},
			["icon"] = 135340,
			["name"] = "Windforged Rapier",
		},
		["LIONSINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Lion's Ink",
			["icon"] = 132918,
			["id"] = {
				57704, -- [1]
			},
		},
		["SUBTLEBLOODSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53843, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Subtle Bloodstone",
		},
		["WIZARDWEAVELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Wizardweave Leggings",
			["icon"] = 132149,
			["id"] = {
				18421, -- [1]
			},
		},
		["TRANSMUTEEARTHSIEGEDIAMOND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				57427, -- [1]
			},
			["icon"] = 134085,
			["name"] = "Transmute: Earthsiege Diamond",
		},
		["RABID"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53401, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 236149,
			["name"] = "Rabid",
		},
		["FROSTSAVAGESHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59584, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostsavage Shoulders",
		},
		["STEALTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1784, -- [1]
				1785, -- [2]
				1786, -- [3]
				1787, -- [4]
				1789, -- [5]
				1790, -- [6]
				1791, -- [7]
				1792, -- [8]
				8822, -- [9]
				30831, -- [10]
				30991, -- [11]
				31526, -- [12]
				31621, -- [13]
				32199, -- [14]
				32615, -- [15]
				34189, -- [16]
				42347, -- [17]
				42866, -- [18]
				42943, -- [19]
				52188, -- [20]
				58506, -- [21]
			},
			["icon"] = 132320,
			["name"] = "Stealth",
		},
		["GLYPHOFFROSTSHOCK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Frost Shock",
			["icon"] = 136243,
			["id"] = {
				55443, -- [1]
				55547, -- [2]
				57241, -- [3]
			},
		},
		["FELIRONSHELLS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				30346, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Fel Iron Shells",
		},
		["ARCTICHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				51572, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Arctic Helm",
		},
		["BRILLIANTSARONITEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55057, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Brilliant Saronite Boots",
		},
		["ENVENOM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				32645, -- [1]
				32684, -- [2]
				39967, -- [3]
				41487, -- [4]
				41509, -- [5]
				41510, -- [6]
				57992, -- [7]
				57993, -- [8]
			},
			["castTime"] = 0,
			["icon"] = 132287,
			["name"] = "Envenom",
		},
		["BADATTITUDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				52395, -- [1]
				50433, -- [2]
				52396, -- [3]
				52397, -- [4]
				52398, -- [5]
				52399, -- [6]
			},
			["castTime"] = 0,
			["icon"] = 132187,
			["name"] = "Bad Attitude",
		},
		["THORIUMBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Thorium Belt",
			["icon"] = 132519,
			["id"] = {
				16643, -- [1]
			},
		},
		["RIGIDGOLDENDRAENITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28948, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Rigid Golden Draenite",
		},
		["GOBLINROCKETFUELRECIPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12715, -- [1]
				12767, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Goblin Rocket Fuel Recipe",
		},
		["SEALOFLIGHT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Seal of Light",
			["icon"] = 135917,
			["id"] = {
				20165, -- [1]
				20167, -- [2]
				20333, -- [3]
				20334, -- [4]
				20340, -- [5]
				20347, -- [6]
				20348, -- [7]
				20349, -- [8]
				20455, -- [9]
				20456, -- [10]
				20457, -- [11]
				20458, -- [12]
			},
		},
		["ASPECTOFTHEDRAGONHAWK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				61846, -- [1]
				61847, -- [2]
				61848, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 132188,
			["name"] = "Aspect of the Dragonhawk",
		},
		["GLYPHOFSMITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Smite",
			["icon"] = 136243,
			["id"] = {
				55692, -- [1]
				56182, -- [2]
				57201, -- [3]
			},
		},
		["FACESOFDOOM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59498, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Faces of Doom",
		},
		["ICYBLASTINGPRIMERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				39971, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Icy Blasting Primers",
		},
		["TOUGHENEDLEATHERARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Toughened Leather Armor",
			["icon"] = 136247,
			["id"] = {
				2166, -- [1]
				2180, -- [2]
			},
		},
		["COMPACTHARVESTREAPERKIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Compact Harvest Reaper Kit",
			["icon"] = 136243,
			["id"] = {
				3963, -- [1]
				4019, -- [2]
			},
		},
		["SILVERSKELETONKEY"] = {
			["maxRange"] = 5,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Silver Skeleton Key",
			["icon"] = 136243,
			["id"] = {
				19646, -- [1]
				19666, -- [2]
				19670, -- [3]
			},
		},
		["FIREEATERSGUIDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Fire Eater's Guide",
			["icon"] = 132918,
			["id"] = {
				59489, -- [1]
			},
		},
		["LIGHTEMBERFORGEDHAMMER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36128, -- [1]
			},
			["icon"] = 133058,
			["name"] = "Light Emberforged Hammer",
		},
		["ARMORPLATEDCOMBATSHOTGUN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				56479, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Armor Plated Combat Shotgun",
		},
		["EXPANSIVEMIND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				20591, -- [1]
			},
			["icon"] = 132864,
			["name"] = "Expansive Mind",
		},
		["MINDNUMBINGPOISON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				5760, -- [1]
				5761, -- [2]
				5763, -- [3]
				5768, -- [4]
				8695, -- [5]
				11401, -- [6]
				25810, -- [7]
				34615, -- [8]
				41190, -- [9]
			},
			["castTime"] = 0,
			["icon"] = 136066,
			["name"] = "Mind-numbing Poison",
		},
		["BRONZEFRAMEWORK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Bronze Framework",
			["icon"] = 136243,
			["id"] = {
				3953, -- [1]
				4012, -- [2]
			},
		},
		["PYGMYOIL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53805, -- [1]
				53806, -- [2]
				53808, -- [3]
				53812, -- [4]
			},
			["icon"] = 134718,
			["name"] = "Pygmy Oil",
		},
		["GLYPHOFRAPIDFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56828, -- [1]
				56883, -- [2]
				57008, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Rapid Fire",
		},
		["AZUREMOONSTONERING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				31050, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Azure Moonstone Ring",
		},
		["BLACKMOUTHOIL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Blackmouth Oil",
			["icon"] = 136243,
			["id"] = {
				7836, -- [1]
				7838, -- [2]
			},
		},
		["POISONCLEANSINGTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				8166, -- [1]
				8169, -- [2]
				38306, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 136070,
			["name"] = "Poison Cleansing Totem",
		},
		["BLACKMAGEWEAVEHEADBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Black Mageweave Headband",
			["icon"] = 132149,
			["id"] = {
				12072, -- [1]
				12115, -- [2]
			},
		},
		["ELIXIROFFIREPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Firepower",
			["icon"] = 136243,
			["id"] = {
				7845, -- [1]
				7846, -- [2]
			},
		},
		["CREATEFIRESTONEGREATER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				17952, -- [1]
				18170, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 132386,
			["name"] = "Create Firestone (Greater)",
		},
		["WATERSHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				23575, -- [1]
				24398, -- [2]
				33736, -- [3]
				33737, -- [4]
				34827, -- [5]
				34828, -- [6]
				36816, -- [7]
				37432, -- [8]
				52127, -- [9]
				52128, -- [10]
				52129, -- [11]
				52130, -- [12]
				52131, -- [13]
				52132, -- [14]
				52133, -- [15]
				52134, -- [16]
				52135, -- [17]
				52136, -- [18]
				52137, -- [19]
				52138, -- [20]
				57960, -- [21]
				57961, -- [22]
			},
			["icon"] = 132315,
			["name"] = "Water Shield",
		},
		["FELSTEELSTABILIZER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				30309, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Felsteel Stabilizer",
		},
		["ARCANEBLAST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				10833, -- [1]
				16067, -- [2]
				18091, -- [3]
				20883, -- [4]
				22893, -- [5]
				22920, -- [6]
				22940, -- [7]
				24857, -- [8]
				30451, -- [9]
				30661, -- [10]
				31457, -- [11]
				32935, -- [12]
				34793, -- [13]
				35314, -- [14]
				35927, -- [15]
				36032, -- [16]
				37126, -- [17]
				38342, -- [18]
				38344, -- [19]
				38538, -- [20]
				38881, -- [21]
				40837, -- [22]
				40881, -- [23]
				42894, -- [24]
				42896, -- [25]
				42897, -- [26]
				49198, -- [27]
				50545, -- [28]
				51797, -- [29]
				51830, -- [30]
				56969, -- [31]
				58462, -- [32]
				59257, -- [33]
				59909, -- [34]
				65791, -- [35]
			},
			["icon"] = 136146,
			["name"] = "Arcane Blast",
		},
		["EARTHSHATTER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				35750, -- [1]
			},
			["icon"] = 132838,
			["name"] = "Earth Shatter",
		},
		["ELIXIROFWISDOM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Wisdom",
			["icon"] = 136243,
			["id"] = {
				3171, -- [1]
				3179, -- [2]
			},
		},
		["EBONWEAVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56002, -- [1]
			},
			["icon"] = 132149,
			["name"] = "Ebonweave",
		},
		["ROSECOLOREDGOGGLES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Rose Colored Goggles",
			["icon"] = 136243,
			["id"] = {
				12618, -- [1]
				12640, -- [2]
			},
		},
		["MEDIUMARMORKIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Medium Armor Kit",
			["icon"] = 136247,
			["id"] = {
				2165, -- [1]
				2884, -- [2]
			},
		},
		["RUNEFORGING"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53424, -- [1]
				53428, -- [2]
				53431, -- [3]
				53441, -- [4]
			},
			["icon"] = 237523,
			["name"] = "Runeforging",
		},
		["COPPERBATTLEAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Copper Battle Axe",
			["icon"] = 135420,
			["id"] = {
				3293, -- [1]
				3299, -- [2]
			},
		},
		["SPIKEDCOBALTHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54917, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Spiked Cobalt Helm",
		},
		["LIVINGBOMB"] = {
			["maxRange"] = 45,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				20475, -- [1]
				44457, -- [2]
				44461, -- [3]
				55359, -- [4]
				55360, -- [5]
				55361, -- [6]
				55362, -- [7]
			},
			["icon"] = 132863,
			["name"] = "Living Bomb",
		},
		["SEAFOAMGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60665, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Seafoam Gauntlets",
		},
		["FROSTHIDELEGARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50965, -- [1]
				60581, -- [2]
			},
			["icon"] = 136247,
			["name"] = "Frosthide Leg Armor",
		},
		["BRILLIANTSARONITEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59438, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Brilliant Saronite Bracers",
		},
		["ENCHANTGLOVESCRUSHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Gloves - Crusher",
			["icon"] = 136244,
			["id"] = {
				60668, -- [1]
			},
		},
		["FLEXWEAVEUNDERLAY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				55002, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Flexweave Underlay",
		},
		["SUMMONIMP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				688, -- [1]
				1366, -- [2]
				11939, -- [3]
				23503, -- [4]
				30066, -- [5]
				33973, -- [6]
				34238, -- [7]
				34251, -- [8]
				44163, -- [9]
				46214, -- [10]
				46544, -- [11]
			},
			["icon"] = 136218,
			["name"] = "Summon Imp",
		},
		["SAVAGECOBALTSLICER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55177, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Savage Cobalt Slicer",
		},
		["HOLYSHOCK"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Holy Shock",
			["icon"] = 135972,
			["id"] = {
				20473, -- [1]
				20929, -- [2]
				20930, -- [3]
				20958, -- [4]
				20960, -- [5]
				25902, -- [6]
				25903, -- [7]
				25911, -- [8]
				25912, -- [9]
				25913, -- [10]
				25914, -- [11]
				27174, -- [12]
				27175, -- [13]
				27176, -- [14]
				32771, -- [15]
				33072, -- [16]
				33073, -- [17]
				33074, -- [18]
				35160, -- [19]
				36340, -- [20]
				38921, -- [21]
				48820, -- [22]
				48821, -- [23]
				48822, -- [24]
				48823, -- [25]
				48824, -- [26]
				48825, -- [27]
				66114, -- [28]
			},
		},
		["THUNDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34547, -- [1]
				52166, -- [2]
				53630, -- [3]
				59507, -- [4]
				75033, -- [5]
			},
			["icon"] = 136241,
			["name"] = "Thunder",
		},
		["ARTISANTAILOR"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Tailor",
			["icon"] = 136249,
			["id"] = {
				12181, -- [1]
			},
		},
		["CHAINHEAL"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 2352,
			["id"] = {
				1064, -- [1]
				1444, -- [2]
				10622, -- [3]
				10623, -- [4]
				10624, -- [5]
				10625, -- [6]
				14900, -- [7]
				15799, -- [8]
				16367, -- [9]
				25422, -- [10]
				25423, -- [11]
				33642, -- [12]
				41114, -- [13]
				42027, -- [14]
				42477, -- [15]
				43527, -- [16]
				48894, -- [17]
				54481, -- [18]
				55458, -- [19]
				55459, -- [20]
				59473, -- [21]
				75370, -- [22]
				70425, -- [23]
				69923, -- [24]
			},
			["icon"] = 136042,
			["name"] = "Chain Heal",
		},
		["JOURNEYMANTAILOR"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Tailor",
			["icon"] = 136249,
			["id"] = {
				3912, -- [1]
			},
		},
		["ORNATESARONITEWAISTGUARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56551, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Ornate Saronite Waistguard",
		},
		["MISDIRECTION"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				34477, -- [1]
				35079, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132180,
			["name"] = "Misdirection",
		},
		["FIREBALL"] = {
			["maxRange"] = 35,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				133, -- [1]
				143, -- [2]
				145, -- [3]
				483, -- [4]
				502, -- [5]
				854, -- [6]
				1173, -- [7]
				1198, -- [8]
				3140, -- [9]
				3142, -- [10]
				3688, -- [11]
				8400, -- [12]
				8401, -- [13]
				8402, -- [14]
				8403, -- [15]
				8404, -- [16]
				8405, -- [17]
				9053, -- [18]
				9487, -- [19]
				9488, -- [20]
				10148, -- [21]
				10149, -- [22]
				10150, -- [23]
				10151, -- [24]
				10152, -- [25]
				10153, -- [26]
				10154, -- [27]
				10155, -- [28]
				10578, -- [29]
				11839, -- [30]
				11921, -- [31]
				11985, -- [32]
				12466, -- [33]
				13140, -- [34]
				13375, -- [35]
				13438, -- [36]
				14034, -- [37]
				15228, -- [38]
				15242, -- [39]
				15536, -- [40]
				15662, -- [41]
				15665, -- [42]
				16101, -- [43]
				16412, -- [44]
				16413, -- [45]
				16415, -- [46]
				16788, -- [47]
				17290, -- [48]
				18082, -- [49]
				18105, -- [50]
				18108, -- [51]
				18199, -- [52]
				18392, -- [53]
				18796, -- [54]
				19391, -- [55]
				19816, -- [56]
				20420, -- [57]
				20678, -- [58]
				20692, -- [59]
				20714, -- [60]
				20793, -- [61]
				20797, -- [62]
				20808, -- [63]
				20811, -- [64]
				20815, -- [65]
				20823, -- [66]
				21072, -- [67]
				21159, -- [68]
				21162, -- [69]
				21402, -- [70]
				21549, -- [71]
				22088, -- [72]
				23024, -- [73]
				23411, -- [74]
				24374, -- [75]
				24611, -- [76]
				25306, -- [77]
				25415, -- [78]
				25978, -- [79]
				27070, -- [80]
				29456, -- [81]
				29925, -- [82]
				29953, -- [83]
				30218, -- [84]
				30534, -- [85]
				30691, -- [86]
				30943, -- [87]
				30967, -- [88]
				31262, -- [89]
				31620, -- [90]
				32363, -- [91]
				32369, -- [92]
				32414, -- [93]
				32491, -- [94]
				33417, -- [95]
				33793, -- [96]
				33794, -- [97]
				34083, -- [98]
				34348, -- [99]
				34653, -- [100]
				36711, -- [101]
				36805, -- [102]
				36920, -- [103]
				36971, -- [104]
				37111, -- [105]
				37329, -- [106]
				37463, -- [107]
				38641, -- [108]
				38692, -- [109]
				38824, -- [110]
				39267, -- [111]
				40554, -- [112]
				40598, -- [113]
				40877, -- [114]
				41383, -- [115]
				41484, -- [116]
				42802, -- [117]
				42832, -- [118]
				42833, -- [119]
				42834, -- [120]
				42853, -- [121]
				44189, -- [122]
				44202, -- [123]
				44237, -- [124]
				45580, -- [125]
				45595, -- [126]
				45748, -- [127]
				46164, -- [128]
				46988, -- [129]
				47074, -- [130]
				49512, -- [131]
				52282, -- [132]
				54094, -- [133]
				54095, -- [134]
				54096, -- [135]
				57628, -- [136]
				59994, -- [137]
				61567, -- [138]
				61909, -- [139]
				62796, -- [140]
				63789, -- [141]
				63815, -- [142]
				69570, -- [143]
				69583, -- [144]
				72163, -- [145]
				66042, -- [146]
				69668, -- [147]
				70754, -- [148]
				71928, -- [149]
				70409, -- [150]
				71500, -- [151]
				71501, -- [152]
				71504, -- [153]
			},
			["icon"] = 135812,
			["name"] = "Fireball",
		},
		["ENCHANTWEAPONGREATERPOTENCY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Weapon - Greater Potency",
			["icon"] = 135913,
			["id"] = {
				60621, -- [1]
			},
		},
		["FELIRONCHAINCOIF"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29551, -- [1]
			},
			["icon"] = 133137,
			["name"] = "Fel Iron Chain Coif",
		},
		["HAMMEROFWRATH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Hammer of Wrath",
			["icon"] = 132326,
			["id"] = {
				24239, -- [1]
				24274, -- [2]
				24275, -- [3]
				24276, -- [4]
				24277, -- [5]
				24278, -- [6]
				27180, -- [7]
				32772, -- [8]
				37251, -- [9]
				37255, -- [10]
				37259, -- [11]
				48805, -- [12]
				48806, -- [13]
				51384, -- [14]
			},
		},
		["GLYPHOFVAMPIRICBLOOD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				57227, -- [1]
				58675, -- [2]
				58676, -- [3]
				58726, -- [4]
			},
			["icon"] = 132918,
			["name"] = "Glyph of Vampiric Blood",
		},
		["MINDFLAY"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				15407, -- [1]
				7378, -- [2]
				16568, -- [3]
				17165, -- [4]
				17311, -- [5]
				17312, -- [6]
				17313, -- [7]
				17314, -- [8]
				17316, -- [9]
				17317, -- [10]
				17318, -- [11]
				18807, -- [12]
				18808, -- [13]
				22919, -- [14]
				23953, -- [15]
				26044, -- [16]
				26143, -- [17]
				28310, -- [18]
				29407, -- [19]
				25387, -- [20]
				29570, -- [21]
				32417, -- [22]
				35507, -- [23]
				37276, -- [24]
				37330, -- [25]
				37621, -- [26]
				38243, -- [27]
				40842, -- [28]
				42396, -- [29]
				43512, -- [30]
				46562, -- [31]
				48155, -- [32]
				48156, -- [33]
				52586, -- [34]
				54339, -- [35]
				54805, -- [36]
				57779, -- [37]
				57941, -- [38]
				58381, -- [39]
				59367, -- [40]
				59974, -- [41]
				60006, -- [42]
				60472, -- [43]
				65488, -- [44]
			},
			["name"] = "Mind Flay",
			["icon"] = 136208,
			["castTime"] = 0,
		},
		["PUMMEL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				--26090, -- [1]
				6552, -- [2]
				6553, -- [3]
				6554, -- [4]
				6556, -- [5]
				12555, -- [6]
				13491, -- [7]
				15615, -- [8]
				19639, -- [9]
				19640, -- [10]
				6555, -- [11]
				36470, -- [12]
				38313, -- [13]
				47081, -- [14]
				53394, -- [15]
				58953, -- [16]
				59344, -- [17]
				67235, -- [18]
			},
			["castTime"] = 0,
			["icon"] = 132189,
			["name"] = "Pummel",
		},
		["DEEPFROZENCORD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56020, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Deep Frozen Cord",
		},
		["EMPOWERRUNEWEAPON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				47568, -- [1]
			},
			["icon"] = 135372,
			["name"] = "Empower Rune Weapon",
		},
		["APPRENTICEFISHING"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Fishing",
			["icon"] = 136245,
			["id"] = {
				7733, -- [1]
			},
		},
		["WEAPONVELLUM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Weapon Vellum",
			["icon"] = 132918,
			["id"] = {
				52840, -- [1]
			},
		},
		["GIFTOFTHEWILD"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Gift of the Wild",
			["icon"] = 136038,
			["id"] = {
				21849, -- [1]
				21850, -- [2]
				21851, -- [3]
				21852, -- [4]
				26991, -- [5]
				48470, -- [6]
				72588, -- [7]
				69381, -- [8]
			},
		},
		["HIEXPLOSIVEBOMB"] = {
			["maxRange"] = 15,
			["minRange"] = 0,
			["castTime"] = 941,
			["name"] = "Hi-Explosive Bomb",
			["icon"] = 135826,
			["id"] = {
				12543, -- [1]
				12619, -- [2]
				12641, -- [3]
			},
		},
		["SNOWFALLINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				57716, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Snowfall Ink",
		},
		["ENGRAVEDTRUESILVERRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Engraved Truesilver Ring",
			["icon"] = 136243,
			["id"] = {
				25620, -- [1]
			},
		},
		["MALACHITEPENDANT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Malachite Pendant",
			["icon"] = 136243,
			["id"] = {
				32178, -- [1]
			},
		},
		["BRONZETORC"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Bronze Torc",
			["icon"] = 136243,
			["id"] = {
				38175, -- [1]
			},
		},
		["COWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1742, -- [1]
				1747, -- [2]
				1748, -- [3]
				1749, -- [4]
				1750, -- [5]
				1751, -- [6]
				1753, -- [7]
				1754, -- [8]
				1755, -- [9]
				1756, -- [10]
				8998, -- [11]
				8999, -- [12]
				9000, -- [13]
				9001, -- [14]
				9892, -- [15]
				9893, -- [16]
				16697, -- [17]
				16698, -- [18]
				27004, -- [19]
				27048, -- [20]
				27346, -- [21]
				31709, -- [22]
				48575, -- [23]
			},
			["castTime"] = 0,
			["icon"] = 132118,
			["name"] = "Cower",
		},
		["CRIMSONSILKBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Crimson Silk Belt",
			["icon"] = 132149,
			["id"] = {
				8772, -- [1]
				8773, -- [2]
			},
		},
		["CLOAKOFTHEMOON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56014, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Cloak of the Moon",
		},
		["HANDFULOFFELIRONBOLTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				30305, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Handful of Fel Iron Bolts",
		},
		["ROBEOFPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Robe of Power",
			["icon"] = 132149,
			["id"] = {
				8770, -- [1]
				8771, -- [2]
			},
		},
		["SHIELDOFRIGHTEOUSNESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Shield of Righteousness",
			["icon"] = 236265,
			["id"] = {
				53600, -- [1]
				61411, -- [2]
			},
		},
		["JOURNEYMANMINER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Miner",
			["icon"] = 136248,
			["id"] = {
				2582, -- [1]
			},
		},
		["CLEAVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				47994, -- [1]
				797, -- [2]
				845, -- [3]
				3433, -- [4]
				3434, -- [5]
				3435, -- [6]
				5532, -- [7]
				7369, -- [8]
				11427, -- [9]
				11608, -- [10]
				11609, -- [11]
				15284, -- [12]
				15496, -- [13]
				15579, -- [14]
				15584, -- [15]
				15613, -- [16]
				15622, -- [17]
				15623, -- [18]
				15663, -- [19]
				15754, -- [20]
				16044, -- [21]
				17685, -- [22]
				19632, -- [23]
				19642, -- [24]
				19983, -- [25]
				20569, -- [26]
				20571, -- [27]
				20605, -- [28]
				20666, -- [29]
				20677, -- [30]
				20684, -- [31]
				20691, -- [32]
				22540, -- [33]
				26350, -- [34]
				27794, -- [35]
				25231, -- [36]
				29561, -- [37]
				29665, -- [38]
				30014, -- [39]
				30131, -- [40]
				30213, -- [41]
				30214, -- [42]
				30219, -- [43]
				30222, -- [44]
				30223, -- [45]
				30224, -- [46]
				30619, -- [47]
				31043, -- [48]
				31345, -- [49]
				31779, -- [50]
				37476, -- [51]
				38260, -- [52]
				38474, -- [53]
				39047, -- [54]
				39174, -- [55]
				40504, -- [56]
				40505, -- [57]
				42724, -- [58]
				42746, -- [59]
				43273, -- [60]
				46468, -- [61]
				46559, -- [62]
				47519, -- [63]
				47520, -- [64]
				49806, -- [65]
				51917, -- [66]
				52835, -- [67]
				53631, -- [68]
				53633, -- [69]
				56909, -- [70]
				58131, -- [71]
				59992, -- [72]
				70191, -- [73]
				70361, -- [74]
				68868, -- [75]
				74524, -- [76]
			},
			["castTime"] = 0,
			["icon"] = 132338,
			["name"] = "Cleave",
		},
		["GLYPHOFLIGHTNINGBOLT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Lightning Bolt",
			["icon"] = 136243,
			["id"] = {
				55453, -- [1]
				55554, -- [2]
				57245, -- [3]
			},
		},
		["MASTERENCHANTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				28030, -- [1]
			},
			["icon"] = 136244,
			["name"] = "Master Enchanter",
		},
		["TEMPEREDSARONITELEGPLATES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54554, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Tempered Saronite Legplates",
		},
		["GLYPHOFFREEZINGTRAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Freezing Trap",
			["icon"] = 136243,
			["id"] = {
				56845, -- [1]
				56877, -- [2]
				57002, -- [3]
				61394, -- [4]
			},
		},
		["SHOVELTUSKSTEAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45550, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Shoveltusk Steak",
		},
		["LARGECOPPERBOMB"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Large Copper Bomb",
			["icon"] = 136243,
			["id"] = {
				3937, -- [1]
				3999, -- [2]
				4065, -- [3]
			},
		},
		["PESTILENCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				50842, -- [1]
				51426, -- [2]
				51427, -- [3]
				51428, -- [4]
				51429, -- [5]
			},
			["icon"] = 136182,
			["name"] = "Pestilence",
		},
		["LOCKPICKING"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				1809, -- [1]
				1810, -- [2]
				6460, -- [3]
				6481, -- [4]
				6482, -- [5]
			},
			["castTime"] = 0,
			["icon"] = 136058,
			["name"] = "Lockpicking",
		},
		["SOCKETBRACER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				55628, -- [1]
			},
			["icon"] = 133273,
			["name"] = "Socket Bracer",
		},
		["SUPERIORHEALINGPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Superior Healing Potion",
			["icon"] = 136243,
			["id"] = {
				11457, -- [1]
				11491, -- [2]
			},
		},
		["RIGHTEOUSGREAVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55304, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Righteous Greaves",
		},
		["DUSKWEAVEROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55921, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Duskweave Robe",
		},
		["WICKEDEDGEOFTHEPLANES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				36260, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Wicked Edge of the Planes",
		},
		["ENCHANTRINGGREATERSPELLPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Ring - Greater Spellpower",
			["icon"] = 136244,
			["id"] = {
				44636, -- [1]
			},
		},
		["TOMEOFKINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Tome of Kings",
			["icon"] = 132918,
			["id"] = {
				59484, -- [1]
			},
		},
		["GLYPHOFTHEHAWK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56856, -- [1]
				56881, -- [2]
				57006, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of the Hawk",
		},
		["IMPROVEDCOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53181, -- [1]
				53180, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132118,
			["name"] = "Improved Cower",
		},
		["FROSTWOVENROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55903, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostwoven Robe",
		},
		["GLYPHOFFEINT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56804, -- [1]
				57122, -- [2]
				57149, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Feint",
		},
		["HILLMANSCLOAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Hillman's Cloak",
			["icon"] = 136247,
			["id"] = {
				3760, -- [1]
				3787, -- [2]
			},
		},
		["DEADLYPOISON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				2818, -- [1]
				2823, -- [2]
				2835, -- [3]
				2843, -- [4]
				2844, -- [5]
				3583, -- [6]
				10022, -- [7]
				11360, -- [8]
				11361, -- [9]
				13582, -- [10]
				21787, -- [11]
				21788, -- [12]
				25412, -- [13]
				25974, -- [14]
				32970, -- [15]
				32971, -- [16]
				34616, -- [17]
				34655, -- [18]
				34657, -- [19]
				36872, -- [20]
				38519, -- [21]
				38520, -- [22]
				41191, -- [23]
				41192, -- [24]
				41485, -- [25]
				43580, -- [26]
				43581, -- [27]
				56145, -- [28]
				56149, -- [29]
				59479, -- [30]
				59482, -- [31]
				63755, -- [32]
				63756, -- [33]
				67710, -- [34]
				67711, -- [35]
				72329, -- [36]
			},
			["castTime"] = 0,
			["icon"] = 132290,
			["name"] = "Deadly Poison",
		},
		["INSCRIBEDFLAMESPESSARITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28910, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Inscribed Flame Spessarite",
		},
		["PUREHORNSPAULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60671, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Purehorn Spaulders",
		},
		["RUNECLOTHBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Runecloth Bandage",
			["icon"] = 133681,
			["id"] = {
				18629, -- [1]
				18631, -- [2]
			},
		},
		["COBALTLEGPLATES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				52567, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cobalt Legplates",
		},
		["FRACTUREDBLOODSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53845, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Fractured Bloodstone",
		},
		["THICKADAMANTITENECKLACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				31051, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Thick Adamantite Necklace",
		},
		["CURETOXINS"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				--526, -- [1]
			},
			["icon"] = 136067,
			["name"] = "Cure Toxins",
		},
		["ELIXIROFMINORFORTITUDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Minor Fortitude",
			["icon"] = 136243,
			["id"] = {
				2334, -- [1]
				11536, -- [2]
			},
		},
		["YELLOWLUMBERJACKSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55995, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Yellow Lumberjack Shirt",
		},
		["CORRUPTION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				172, -- [1]
				979, -- [2]
				1025, -- [3]
				1107, -- [4]
				6221, -- [5]
				6222, -- [6]
				6223, -- [7]
				6224, -- [8]
				6225, -- [9]
				7648, -- [10]
				7649, -- [11]
				11671, -- [12]
				11672, -- [13]
				11673, -- [14]
				11674, -- [15]
				13530, -- [16]
				16402, -- [17]
				16985, -- [18]
				17510, -- [19]
				18088, -- [20]
				18376, -- [21]
				18656, -- [22]
				21068, -- [23]
				23439, -- [24]
				23642, -- [25]
				25311, -- [26]
				25419, -- [27]
				25982, -- [28]
				28829, -- [29]
				27216, -- [30]
				30938, -- [31]
				31405, -- [32]
				32063, -- [33]
				32197, -- [34]
				37113, -- [35]
				37961, -- [36]
				39212, -- [37]
				39621, -- [38]
				41988, -- [39]
				47782, -- [40]
				47812, -- [41]
				47813, -- [42]
				56898, -- [43]
				57645, -- [44]
				58811, -- [45]
				60016, -- [46]
				61563, -- [47]
				70602, -- [48]
				70904, -- [49]
				71937, -- [50]
				65810, -- [51]
			},
			["icon"] = 136118,
			["name"] = "Corruption",
		},
		["GLYPHOFEXORCISM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Exorcism",
			["icon"] = 136243,
			["id"] = {
				54934, -- [1]
				55118, -- [2]
				57025, -- [3]
			},
		},
		["WEAPONVELLUMIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				59501, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Weapon Vellum III",
		},
		["COBALTSKELETONKEY"] = {
			["maxRange"] = 5,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				59404, -- [1]
				59405, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Cobalt Skeleton Key",
		},
		["TITANIUMSKELETONKEY"] = {
			["maxRange"] = 5,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				59403, -- [1]
				59406, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Titanium Skeleton Key",
		},
		["AZURESILKBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Azure Silk Belt",
			["icon"] = 132149,
			["id"] = {
				8766, -- [1]
				8767, -- [2]
			},
		},
		["HIIMPACTMITHRILSLUGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Hi-Impact Mithril Slugs",
			["icon"] = 136243,
			["id"] = {
				12596, -- [1]
				12636, -- [2]
			},
		},
		["MOLTENARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				30482, -- [1]
				34913, -- [2]
				35915, -- [3]
				35916, -- [4]
				43043, -- [5]
				43044, -- [6]
				43045, -- [7]
				43046, -- [8]
			},
			["icon"] = 132221,
			["name"] = "Molten Armor",
		},
		["GLYPHOFFEARWARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Fear Ward",
			["icon"] = 136243,
			["id"] = {
				55678, -- [1]
				56165, -- [2]
				57185, -- [3]
			},
		},
		["PURIFIEDSHADOWPEARL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				41429, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Purified Shadow Pearl",
		},
		["EXPERTBLACKSMITH"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Expert Blacksmith",
			["icon"] = 136241,
			["id"] = {
				3539, -- [1]
			},
		},
		["SWIMSPEEDPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Swim Speed Potion",
			["icon"] = 136243,
			["id"] = {
				7841, -- [1]
				7842, -- [2]
			},
		},
		["TRUESILVERGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				9954, -- [1]
				9955, -- [2]
			},
			["icon"] = 132963,
			["name"] = "Truesilver Gauntlets",
		},
		["BIGBRONZEKNIFE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Big Bronze Knife",
			["icon"] = 135640,
			["id"] = {
				3491, -- [1]
				3516, -- [2]
			},
		},
		["DEMORALIZINGROAR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Demoralizing Roar",
			["icon"] = 132121,
			["id"] = {
				99, -- [1]
				1735, -- [2]
				1736, -- [3]
				1737, -- [4]
				9490, -- [5]
				9491, -- [6]
				9747, -- [7]
				9748, -- [8]
				9898, -- [9]
				9899, -- [10]
				10968, -- [11]
				15727, -- [12]
				15971, -- [13]
				20753, -- [14]
				27551, -- [15]
				26998, -- [16]
				48559, -- [17]
				48560, -- [18]
			},
		},
		["JOURNEYMANENCHANTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				7415, -- [1]
			},
			["icon"] = 136244,
			["name"] = "Journeyman Enchanter",
		},
		["TOMEOFTHEDAWN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Tome of the Dawn",
			["icon"] = 132918,
			["id"] = {
				59475, -- [1]
			},
		},
		["HEARTOFTHEPHOENIX"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				55709, -- [1]
				54114, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 134373,
			["name"] = "Heart of the Phoenix",
		},
		["TEMPEREDSARONITEBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54553, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Tempered Saronite Breastplate",
		},
		["DARKNERUBIANLEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60627, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Dark Nerubian Leggings",
		},
		["ENCHANTSHIELDGREATERINTELLECT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Shield - Greater Intellect",
			["icon"] = 136244,
			["id"] = {
				60653, -- [1]
			},
		},
		["GRANDMASTERALCHEMIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				51303, -- [1]
				65281, -- [2]
			},
			["icon"] = 136240,
			["name"] = "Grand Master Alchemist",
		},
		["COPPERAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Copper Axe",
			["icon"] = 132417,
			["id"] = {
				2738, -- [1]
				2755, -- [2]
			},
		},
		["EAGLEBANEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60652, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Eaglebane Bracers",
		},
		["SHADOWWORDPAIN"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				589, -- [1]
				594, -- [2]
				610, -- [3]
				616, -- [4]
				970, -- [5]
				971, -- [6]
				992, -- [7]
				993, -- [8]
				1258, -- [9]
				1259, -- [10]
				1260, -- [11]
				1261, -- [12]
				2767, -- [13]
				2799, -- [14]
				3752, -- [15]
				10892, -- [16]
				10893, -- [17]
				10894, -- [18]
				10895, -- [19]
				10896, -- [20]
				10897, -- [21]
				11639, -- [22]
				14032, -- [23]
				15654, -- [24]
				17146, -- [25]
				19776, -- [26]
				23268, -- [27]
				23952, -- [28]
				24212, -- [29]
				27605, -- [30]
				25367, -- [31]
				25368, -- [32]
				30854, -- [33]
				30898, -- [34]
				34441, -- [35]
				34941, -- [36]
				34942, -- [37]
				37275, -- [38]
				41355, -- [39]
				46560, -- [40]
				48124, -- [41]
				48125, -- [42]
				57778, -- [43]
				59864, -- [44]
				60005, -- [45]
				60446, -- [46]
				65541, -- [47]
				72318, -- [48]
			},
			["icon"] = 136207,
			["name"] = "Shadow Word: Pain",
		},
		["SPIKEDCOBALTBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54946, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Spiked Cobalt Belt",
		},
		["FELARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				28176, -- [1]
				28189, -- [2]
				44520, -- [3]
				44977, -- [4]
				47892, -- [5]
				47893, -- [6]
			},
			["name"] = "Fel Armor",
			["icon"] = 136156,
			["castTime"] = 0,
		},
		["ENCHANT2HWEAPONIMPACT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13695, -- [1]
				13696, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant 2H Weapon - Impact",
		},
		["SEALOFRIGHTEOUSNESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Seal of Righteousness",
			["icon"] = 132325,
			["id"] = {
				20154, -- [1]
				864, -- [2]
				3093, -- [3]
				3094, -- [4]
				20287, -- [5]
				20288, -- [6]
				20289, -- [7]
				20290, -- [8]
				20291, -- [9]
				20292, -- [10]
				20293, -- [11]
				20437, -- [12]
				20438, -- [13]
				20439, -- [14]
				20440, -- [15]
				20441, -- [16]
				20442, -- [17]
				20443, -- [18]
				21084, -- [19]
				21085, -- [20]
				25713, -- [21]
				25735, -- [22]
				25736, -- [23]
				25737, -- [24]
				25738, -- [25]
				25739, -- [26]
				25740, -- [27]
				25741, -- [28]
				25742, -- [29]
			},
		},
		["BLACKDUSKWEAVEWRISTWRAPS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55943, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Black Duskweave Wristwraps",
		},
		["JORMSCALEFOOTPADS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60666, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Jormscale Footpads",
		},
		["DUSKWEAVESHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55923, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Duskweave Shoulders",
		},
		["RUNEDFELIRONROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 30000,
			["id"] = {
				32664, -- [1]
			},
			["icon"] = 134924,
			["name"] = "Runed Fel Iron Rod",
		},
		["FROSTFIREBOLT"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				44614, -- [1]
				47610, -- [2]
				51779, -- [3]
				70616, -- [4]
				69869, -- [5]
				69984, -- [6]
			},
			["icon"] = 236217,
			["name"] = "Frostfire Bolt",
		},
		["DUSKYLEATHERARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Dusky Leather Armor",
			["icon"] = 136247,
			["id"] = {
				9196, -- [1]
				9211, -- [2]
			},
		},
		["SARONITEMINDCRUSHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55185, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Saronite Mindcrusher",
		},
		["SWIPEBEAR"] = {
			["maxRange"] = 8,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Swipe (Bear)",
			["icon"] = 134296,
			["id"] = {
				--769, -- [1]
				--779, -- [2]
				--780, -- [3]
				--9754, -- [4]
				--9908, -- [5]
				26997, -- [6]
				48561, -- [7]
				48562, -- [8]
			},
		},
		["MASTERENGINEERSGOGGLES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["name"] = "Master Engineer's Goggles",
			["icon"] = 136243,
			["id"] = {
				19825, -- [1]
			},
		},
		["CUREDRUGGEDHIDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Cured Rugged Hide",
			["icon"] = 136243,
			["id"] = {
				19047, -- [1]
				19147, -- [2]
			},
		},
		["MAJORHEALINGPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Major Healing Potion",
			["icon"] = 136243,
			["id"] = {
				17556, -- [1]
			},
		},
		["SOFTSOLEDLINENBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Soft-soled Linen Boots",
			["icon"] = 132149,
			["id"] = {
				3845, -- [1]
				3880, -- [2]
			},
		},
		["GLYPHOFHUNTERSMARK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Hunter's Mark",
			["icon"] = 136243,
			["id"] = {
				56829, -- [1]
				56879, -- [2]
				57004, -- [3]
			},
		},
		["MASTERSCRIBE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				45379, -- [1]
			},
			["icon"] = 237171,
			["name"] = "Master Scribe",
		},
		["JOURNEYMANSCRIBE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Scribe",
			["icon"] = 237171,
			["id"] = {
				45376, -- [1]
			},
		},
		["HEAVYMITHRILBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Heavy Mithril Breastplate",
			["icon"] = 132745,
			["id"] = {
				9959, -- [1]
				9960, -- [2]
			},
		},
		["ENTANGLINGROOTS"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["name"] = "Entangling Roots",
			["icon"] = 136100,
			["id"] = {
				339, -- [1]
				790, -- [2]
				1062, -- [3]
				1063, -- [4]
				1435, -- [5]
				1436, -- [6]
				2919, -- [7]
				2920, -- [8]
				5195, -- [9]
				5196, -- [10]
				5309, -- [11]
				9852, -- [12]
				9853, -- [13]
				9854, -- [14]
				9855, -- [15]
				11922, -- [16]
				12747, -- [17]
				19970, -- [18]
				19971, -- [19]
				19972, -- [20]
				19973, -- [21]
				19974, -- [22]
				19975, -- [23]
				20654, -- [24]
				20699, -- [25]
				21331, -- [26]
				22127, -- [27]
				22415, -- [28]
				22800, -- [29]
				24648, -- [30]
				26071, -- [31]
				28858, -- [32]
				26989, -- [33]
				27010, -- [34]
				31287, -- [35]
				32173, -- [36]
				33844, -- [37]
				37823, -- [38]
				40363, -- [39]
				53308, -- [40]
				53313, -- [41]
				57095, -- [42]
				66070, -- [43]
				65857, -- [44]
			},
		},
		["GREATERBLESSINGOFKINGS"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Greater Blessing of Kings",
			["icon"] = 135993,
			["id"] = {
				25898, -- [1]
				25946, -- [2]
				43223, -- [3]
			},
		},
		["PATHOFFROST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				3714, -- [1]
				60068, -- [2]
				61081, -- [3]
			},
			["icon"] = 237528,
			["name"] = "Path of Frost",
		},
		["HANDSTITCHEDLINENBRITCHES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Handstitched Linen Britches",
			["icon"] = 132149,
			["id"] = {
				3842, -- [1]
				3878, -- [2]
			},
		},
		["GLYPHOFFIRENOVA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Fire Nova",
			["icon"] = 136243,
			["id"] = {
				55450, -- [1]
				55544, -- [2]
				57238, -- [3]
			},
		},
		["STORMFORGEDAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36134, -- [1]
			},
			["icon"] = 132432,
			["name"] = "Stormforged Axe",
		},
		["PARRY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				3124, -- [1]
				3126, -- [2]
				3127, -- [3]
				3128, -- [4]
				16268, -- [5]
				18848, -- [6]
				18849, -- [7]
				23547, -- [8]
				23548, -- [9]
				60617, -- [10]
			},
			["icon"] = 132269,
			["name"] = "Parry",
		},
		["GLYPHOFRUNETAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				59327, -- [1]
				59328, -- [2]
				59338, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Rune Tap",
		},
		["RUNEDMANABAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				64727, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Runed Mana Band",
		},
		["ARTISANHERBALIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Herbalist",
			["icon"] = 136246,
			["id"] = {
				11994, -- [1]
			},
		},
		["PRECISEBLOODSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				54017, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Precise Bloodstone",
		},
		["COBALTHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				52571, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cobalt Helm",
		},
		["LIGHTLEATHERQUIVER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Light Leather Quiver",
			["icon"] = 136247,
			["id"] = {
				9060, -- [1]
				9061, -- [2]
			},
		},
		["GLYPHOFBLINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Blink",
			["icon"] = 136243,
			["id"] = {
				56365, -- [1]
				56546, -- [2]
				56973, -- [3]
			},
		},
		["RUNEOFSPELLSHATTERING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				53342, -- [1]
				53362, -- [2]
			},
			["icon"] = 136120,
			["name"] = "Rune of Spellshattering",
		},
		["SMALLBRONZEBOMB"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Small Bronze Bomb",
			["icon"] = 136243,
			["id"] = {
				3941, -- [1]
				4003, -- [2]
				4066, -- [3]
			},
		},
		["ICEARMOR"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1214, -- [1]
				506, -- [2]
				844, -- [3]
				1228, -- [4]
				7302, -- [5]
				7320, -- [6]
				10219, -- [7]
				10220, -- [8]
				10221, -- [9]
				10222, -- [10]
				27124, -- [11]
				27391, -- [12]
				36881, -- [13]
				43008, -- [14]
			},
			["icon"] = 135835,
			["name"] = "Ice Armor",
		},
		["DRAGONMAW"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34546, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Dragonmaw",
		},
		["NOURISH"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 1411,
			["name"] = "Nourish",
			["icon"] = 236162,
			["id"] = {
				50464, -- [1]
				52554, -- [2]
				57765, -- [3]
				59991, -- [4]
				63242, -- [5]
				63556, -- [6]
				66066, -- [7]
			},
		},
		["RUNICLEATHERARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runic Leather Armor",
			["icon"] = 136243,
			["id"] = {
				19102, -- [1]
			},
		},
		["CREATEHEALTHSTONEMAJOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				11730, -- [1]
				11731, -- [2]
				20018, -- [3]
				23819, -- [4]
				23820, -- [5]
				23821, -- [6]
			},
			["castTime"] = 3000,
			["icon"] = 135230,
			["name"] = "Create Healthstone (Major)",
		},
		["SPELLPOWERGOGGLESXTREMEPLUS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Spellpower Goggles Xtreme Plus",
			["icon"] = 136243,
			["id"] = {
				19794, -- [1]
			},
		},
		["SMELTSILVER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Smelt Silver",
			["icon"] = 136243,
			["id"] = {
				2658, -- [1]
				3317, -- [2]
			},
		},
		["GNOMISHBATTLEGOGGLES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				30575, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Battle Goggles",
		},
		["REJUVENATION"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Rejuvenation",
			["icon"] = 136081,
			["id"] = {
				774, -- [1]
				788, -- [2]
				1058, -- [3]
				1059, -- [4]
				1428, -- [5]
				1429, -- [6]
				1430, -- [7]
				1431, -- [8]
				2090, -- [9]
				2091, -- [10]
				2092, -- [11]
				2093, -- [12]
				3062, -- [13]
				3063, -- [14]
				3627, -- [15]
				3628, -- [16]
				8070, -- [17]
				8910, -- [18]
				8911, -- [19]
				9839, -- [20]
				9840, -- [21]
				9841, -- [22]
				9842, -- [23]
				9843, -- [24]
				9844, -- [25]
				12160, -- [26]
				15981, -- [27]
				20664, -- [28]
				20701, -- [29]
				25299, -- [30]
				25409, -- [31]
				25972, -- [32]
				27532, -- [33]
				28716, -- [34]
				28722, -- [35]
				28723, -- [36]
				28724, -- [37]
				26981, -- [38]
				26982, -- [39]
				31782, -- [40]
				32131, -- [41]
				38657, -- [42]
				42544, -- [43]
				48440, -- [44]
				48441, -- [45]
				53607, -- [46]
				64801, -- [47]
				66065, -- [48]
				70691, -- [49]
				69898, -- [50]
			},
		},
		["BRIGHTBLOODGARNET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				34590, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Bright Blood Garnet",
		},
		["SCROLLOFSPIRITV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Spirit V",
			["icon"] = 132918,
			["id"] = {
				50608, -- [1]
			},
		},
		["DIREBEARFORM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Dire Bear Form",
			["icon"] = 132276,
			["id"] = {
				9634, -- [1]
				11594, -- [2]
			},
		},
		["ENCHANTWEAPONEXCEPTIONALSPELLPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Weapon - Exceptional Spellpower",
			["icon"] = 136244,
			["id"] = {
				44629, -- [1]
			},
		},
		["HEALTHFUNNEL"] = {
			["maxRange"] = 45,
			["minRange"] = 0,
			["id"] = {
				755, -- [1]
				730, -- [2]
				3698, -- [3]
				3699, -- [4]
				3700, -- [5]
				3701, -- [6]
				3702, -- [7]
				3703, -- [8]
				3704, -- [9]
				3705, -- [10]
				3706, -- [11]
				3707, -- [12]
				11693, -- [13]
				11694, -- [14]
				11695, -- [15]
				11696, -- [16]
				11697, -- [17]
				11698, -- [18]
				16569, -- [19]
				27259, -- [20]
				40671, -- [21]
				40884, -- [22]
				46467, -- [23]
				47856, -- [24]
				60829, -- [25]
			},
			["name"] = "Health Funnel",
			["icon"] = 136168,
			["castTime"] = 0,
		},
		["BARKSKIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Barkskin",
			["icon"] = 136063,
			["id"] = {
				20655, -- [1]
				22812, -- [2]
				22826, -- [3]
				63408, -- [4]
				63409, -- [5]
				65860, -- [6]
			},
		},
		["COBALTBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				52569, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cobalt Boots",
		},
		["DASH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				61684, -- [1]
				1151, -- [2]
				1850, -- [3]
				9821, -- [4]
				9822, -- [5]
				23099, -- [6]
				23100, -- [7]
				23109, -- [8]
				23110, -- [9]
				23111, -- [10]
				23112, -- [11]
				33357, -- [12]
				36589, -- [13]
				43317, -- [14]
				44029, -- [15]
				44531, -- [16]
			},
			["castTime"] = 0,
			["icon"] = 132120,
			["name"] = "Dash",
		},
		["CUREDLIGHTHIDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Cured Light Hide",
			["icon"] = 136247,
			["id"] = {
				3816, -- [1]
				3821, -- [2]
			},
		},
		["FROSTSHOCK"] = {
			["maxRange"] = 25,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8056, -- [1]
				8057, -- [2]
				8058, -- [3]
				8059, -- [4]
				10472, -- [5]
				10473, -- [6]
				10474, -- [7]
				10475, -- [8]
				12548, -- [9]
				15089, -- [10]
				15499, -- [11]
				19133, -- [12]
				21030, -- [13]
				21401, -- [14]
				22582, -- [15]
				23115, -- [16]
				25464, -- [17]
				29666, -- [18]
				34353, -- [19]
				37332, -- [20]
				37865, -- [21]
				38234, -- [22]
				39062, -- [23]
				41116, -- [24]
				43524, -- [25]
				46180, -- [26]
				49235, -- [27]
				49236, -- [28]
			},
			["icon"] = 135849,
			["name"] = "Frost Shock",
		},
		["GREATEARTHFORGEDHAMMER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36137, -- [1]
			},
			["icon"] = 133046,
			["name"] = "Great Earthforged Hammer",
		},
		["HUNTERSINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Hunter's Ink",
			["icon"] = 132918,
			["id"] = {
				57703, -- [1]
			},
		},
		["RETICULATEDARMORWEBBING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				63770, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Reticulated Armor Webbing",
		},
		["PEARLCLASPEDCLOAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Pearl-clasped Cloak",
			["icon"] = 132149,
			["id"] = {
				6521, -- [1]
				6522, -- [2]
			},
		},
		["SEALOFWISDOM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Seal of Wisdom",
			["icon"] = 135960,
			["id"] = {
				20166, -- [1]
				1105, -- [2]
				3713, -- [3]
				7327, -- [4]
				20168, -- [5]
				20350, -- [6]
				20351, -- [7]
				20356, -- [8]
				20357, -- [9]
				20459, -- [10]
				20460, -- [11]
				20461, -- [12]
			},
		},
		["SHADOWBOLT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1599,
			["id"] = {
				686, -- [1]
				695, -- [2]
				705, -- [3]
				721, -- [4]
				732, -- [5]
				1088, -- [6]
				1089, -- [7]
				1106, -- [8]
				1381, -- [9]
				1382, -- [10]
				1406, -- [11]
				1407, -- [12]
				2965, -- [13]
				7617, -- [14]
				7619, -- [15]
				7641, -- [16]
				7642, -- [17]
				9613, -- [18]
				11659, -- [19]
				11660, -- [20]
				11661, -- [21]
				11662, -- [22]
				11663, -- [23]
				11664, -- [24]
				12471, -- [25]
				12739, -- [26]
				13440, -- [27]
				13480, -- [28]
				14106, -- [29]
				14122, -- [30]
				15232, -- [31]
				15472, -- [32]
				15537, -- [33]
				16408, -- [34]
				16409, -- [35]
				16410, -- [36]
				16783, -- [37]
				16784, -- [38]
				17393, -- [39]
				17434, -- [40]
				17435, -- [41]
				17483, -- [42]
				17509, -- [43]
				18111, -- [44]
				18138, -- [45]
				18164, -- [46]
				18205, -- [47]
				18211, -- [48]
				18214, -- [49]
				18217, -- [50]
				19728, -- [51]
				19729, -- [52]
				20298, -- [53]
				20791, -- [54]
				20807, -- [55]
				20816, -- [56]
				20825, -- [57]
				21077, -- [58]
				21141, -- [59]
				22336, -- [60]
				22677, -- [61]
				24668, -- [62]
				25307, -- [63]
				25417, -- [64]
				25980, -- [65]
				26006, -- [66]
				29317, -- [67]
				29626, -- [68]
				29640, -- [69]
				27209, -- [70]
				29487, -- [71]
				29927, -- [72]
				30055, -- [73]
				30505, -- [74]
				30686, -- [75]
				31618, -- [76]
				31627, -- [77]
				32666, -- [78]
				32860, -- [79]
				33335, -- [80]
				34344, -- [81]
				36714, -- [82]
				36868, -- [83]
				36972, -- [84]
				36986, -- [85]
				36987, -- [86]
				38378, -- [87]
				38386, -- [88]
				38628, -- [89]
				38825, -- [90]
				38892, -- [91]
				39025, -- [92]
				39026, -- [93]
				39297, -- [94]
				39309, -- [95]
				40185, -- [96]
				41069, -- [97]
				41280, -- [98]
				41957, -- [99]
				43330, -- [100]
				43649, -- [101]
				43667, -- [102]
				45055, -- [103]
				45679, -- [104]
				45680, -- [105]
				47076, -- [106]
				47248, -- [107]
				47808, -- [108]
				47809, -- [109]
				49084, -- [110]
				50455, -- [111]
				51363, -- [112]
				51432, -- [113]
				51608, -- [114]
				52257, -- [115]
				52534, -- [116]
				53086, -- [117]
				53333, -- [118]
				54113, -- [119]
				55984, -- [120]
				56405, -- [121]
				57374, -- [122]
				57464, -- [123]
				57644, -- [124]
				57725, -- [125]
				58827, -- [126]
				59016, -- [127]
				59246, -- [128]
				59254, -- [129]
				59351, -- [130]
				59357, -- [131]
				59389, -- [132]
				59575, -- [133]
				60015, -- [134]
				61558, -- [135]
				61562, -- [136]
				70043, -- [137]
				69028, -- [138]
				70080, -- [139]
				69577, -- [140]
				69068, -- [141]
				71254, -- [142]
				69211, -- [143]
				69212, -- [144]
				71296, -- [145]
				72901, -- [146]
				70386, -- [147]
				71936, -- [148]
				72960, -- [149]
				69387, -- [150]
				65821, -- [151]
				69972, -- [152]
				75384, -- [153]
				75330, -- [154]
			},
			["icon"] = 136197,
			["name"] = "Shadow Bolt",
		},
		["MERCURIALALCHEMISTSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				60396, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Mercurial Alchemist Stone",
		},
		["SLOWFALL"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				130, -- [1]
				6493, -- [2]
				12438, -- [3]
				50085, -- [4]
				50237, -- [5]
			},
			["icon"] = 135992,
			["name"] = "Slow Fall",
		},
		["BLACKMAGEWEAVEVEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Black Mageweave Vest",
			["icon"] = 132149,
			["id"] = {
				12048, -- [1]
				12100, -- [2]
			},
		},
		["GNOMISHXRAYSPECS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				56473, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Gnomish X-Ray Specs",
		},
		["CHAINLIGHTNING"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1882,
			["id"] = {
				421, -- [1]
				920, -- [2]
				930, -- [3]
				1339, -- [4]
				1340, -- [5]
				2860, -- [6]
				2862, -- [7]
				2863, -- [8]
				10605, -- [9]
				12058, -- [10]
				15117, -- [11]
				15305, -- [12]
				15659, -- [13]
				16006, -- [14]
				16033, -- [15]
				16921, -- [16]
				20831, -- [17]
				21179, -- [18]
				22355, -- [19]
				23106, -- [20]
				23206, -- [21]
				24680, -- [22]
				25021, -- [23]
				27567, -- [24]
				28167, -- [25]
				28293, -- [26]
				25439, -- [27]
				25442, -- [28]
				28900, -- [29]
				31330, -- [30]
				31717, -- [31]
				32337, -- [32]
				33643, -- [33]
				37448, -- [34]
				39066, -- [35]
				39945, -- [36]
				40536, -- [37]
				41183, -- [38]
				42441, -- [39]
				42804, -- [40]
				43435, -- [41]
				44318, -- [42]
				45297, -- [43]
				45298, -- [44]
				45299, -- [45]
				45300, -- [46]
				45301, -- [47]
				45302, -- [48]
				45868, -- [49]
				46380, -- [50]
				48140, -- [51]
				48699, -- [52]
				49268, -- [53]
				49269, -- [54]
				49270, -- [55]
				49271, -- [56]
				50830, -- [57]
				52383, -- [58]
				54334, -- [59]
				54531, -- [60]
				59082, -- [61]
				59220, -- [62]
				59223, -- [63]
				59273, -- [64]
				59517, -- [65]
				59716, -- [66]
				59844, -- [67]
				61528, -- [68]
				61879, -- [69]
				62131, -- [70]
				63479, -- [71]
				64213, -- [72]
				64215, -- [73]
				64390, -- [74]
				64758, -- [75]
				64759, -- [76]
				67529, -- [77]
				69696, -- [78]
				75362, -- [79]
			},
			["icon"] = 136015,
			["name"] = "Chain Lightning",
		},
		["BULWARKOFTHEANCIENTKINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				36257, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Bulwark of the Ancient Kings",
		},
		["BASH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Bash",
			["icon"] = 132114,
			["id"] = {
				5211, -- [1]
				5212, -- [2]
				6798, -- [3]
				6799, -- [4]
				8983, -- [5]
				8984, -- [6]
				25515, -- [7]
				43612, -- [8]
				57094, -- [9]
				58861, -- [10]
			},
		},
		["SCROLLOFAGILITYVI"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Agility VI",
			["icon"] = 132918,
			["id"] = {
				58481, -- [1]
			},
		},
		["WINDSHEAR"] = {
			["maxRange"] = 25,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				57994, -- [1]
				52870, -- [2]
			},
			["icon"] = 136018,
			["name"] = "Wind Shear",
		},
		["CLEANSE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Cleanse",
			["icon"] = 135953,
			["id"] = {
				4987, -- [1]
				4990, -- [2]
				4993, -- [3]
				28787, -- [4]
				28788, -- [5]
				29380, -- [6]
				32400, -- [7]
				39078, -- [8]
				57767, -- [9]
				66116, -- [10]
			},
		},
		["KILLSHOT"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["id"] = {
				34104, -- [1]
				53351, -- [2]
				61005, -- [3]
				61006, -- [4]
			},
			["castTime"] = -999500,
			["icon"] = 132312,
			["name"] = "Kill Shot",
		},
		["FROSTSTRIKE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				43568, -- [1]
				49143, -- [2]
				51416, -- [3]
				51417, -- [4]
				51418, -- [5]
				51419, -- [6]
				55268, -- [7]
				60951, -- [8]
				66958, -- [9]
				66959, -- [10]
				66960, -- [11]
				66961, -- [12]
				66962, -- [13]
				66047, -- [14]
				66196, -- [15]
			},
			["icon"] = 135846,
			["name"] = "Frost Strike",
		},
		["GLYPHOFJUDGEMENT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Judgement",
			["icon"] = 136243,
			["id"] = {
				54922, -- [1]
				55003, -- [2]
				57030, -- [3]
			},
		},
		["PURIFIEDJAGGALPEARL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				41420, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Purified Jaggal Pearl",
		},
		["GRANDMASTERLEATHERWORKER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				51301, -- [1]
				65284, -- [2]
			},
			["icon"] = 133611,
			["name"] = "Grand Master Leatherworker",
		},
		["HOLYFIRE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				14914, -- [1]
				15261, -- [2]
				15262, -- [3]
				15263, -- [4]
				15264, -- [5]
				15265, -- [6]
				15266, -- [7]
				15267, -- [8]
				15452, -- [9]
				15454, -- [10]
				15455, -- [11]
				15457, -- [12]
				15459, -- [13]
				15460, -- [14]
				17140, -- [15]
				17141, -- [16]
				17142, -- [17]
				18165, -- [18]
				18167, -- [19]
				18806, -- [20]
				23860, -- [21]
				27796, -- [22]
				25384, -- [23]
				29522, -- [24]
				29563, -- [25]
				36947, -- [26]
				38585, -- [27]
				39323, -- [28]
				48134, -- [29]
				48135, -- [30]
				66538, -- [31]
			},
			["name"] = "Holy Fire",
			["icon"] = 135972,
			["castTime"] = 2000,
		},
		["VANISH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1856, -- [1]
				1857, -- [2]
				1858, -- [3]
				1859, -- [4]
				11327, -- [5]
				11329, -- [6]
				24223, -- [7]
				24228, -- [8]
				24229, -- [9]
				24230, -- [10]
				24231, -- [11]
				24232, -- [12]
				24233, -- [13]
				24699, -- [14]
				24700, -- [15]
				27617, -- [16]
				26888, -- [17]
				26889, -- [18]
				29448, -- [19]
				31619, -- [20]
				35205, -- [21]
				39667, -- [22]
				41476, -- [23]
				41479, -- [24]
				44290, -- [25]
				55964, -- [26]
				71400, -- [27]
			},
			["castTime"] = 0,
			["icon"] = 132331,
			["name"] = "Vanish",
		},
		["CREATEHEALTHSTONELESSER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				6202, -- [1]
				6204, -- [2]
				23520, -- [3]
				23521, -- [4]
				23522, -- [5]
			},
			["castTime"] = 3000,
			["icon"] = 135230,
			["name"] = "Create Healthstone (Lesser)",
		},
		["ROUGHBOOMSTICK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Rough Boomstick",
			["icon"] = 136243,
			["id"] = {
				3925, -- [1]
				3987, -- [2]
			},
		},
		["FROSTSCALECHESTGUARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50950, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Frostscale Chestguard",
		},
		["FURLININGATTACKPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				57683, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Fur Lining - Attack Power",
		},
		["STANDARDSCOPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["name"] = "Standard Scope",
			["icon"] = 136243,
			["id"] = {
				3975, -- [1]
				3978, -- [2]
				4001, -- [3]
			},
		},
		["SCROLLOFSPIRITVII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50610, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Spirit VII",
		},
		["TITANIUMROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55732, -- [1]
			},
			["icon"] = 237444,
			["name"] = "Titanium Rod",
		},
		["BANISH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				710, -- [1]
				7664, -- [2]
				8994, -- [3]
				18647, -- [4]
				18648, -- [5]
				24466, -- [6]
				27565, -- [7]
				30231, -- [8]
				35182, -- [9]
				37527, -- [10]
				37546, -- [11]
				37833, -- [12]
				38009, -- [13]
				38376, -- [14]
				38791, -- [15]
				39622, -- [16]
				39674, -- [17]
				40370, -- [18]
				44765, -- [19]
				44836, -- [20]
				71298, -- [21]
			},
			["name"] = "Banish",
			["icon"] = 136135,
			["castTime"] = 1500,
		},
		["ARMORVELLUM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Armor Vellum",
			["icon"] = 132918,
			["id"] = {
				52739, -- [1]
			},
		},
		["FELIRONPLATEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29548, -- [1]
			},
			["icon"] = 132554,
			["name"] = "Fel Iron Plate Boots",
		},
		["DAUNTINGLEGPLATES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55303, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Daunting Legplates",
		},
		["SHININGSPELLTHREAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3763,
			["id"] = {
				55630, -- [1]
				56008, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Shining Spellthread",
		},
		["BRIGHTCLOTHGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Brightcloth Gloves",
			["icon"] = 132149,
			["id"] = {
				18415, -- [1]
			},
		},
		["CONJUREMANAAGATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				759, -- [1]
				1210, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 134104,
			["name"] = "Conjure Mana Agate",
		},
		["BLOODBOIL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				48721, -- [1]
				650, -- [2]
				655, -- [3]
				661, -- [4]
				6210, -- [5]
				6211, -- [6]
				6212, -- [7]
				42005, -- [8]
				49939, -- [9]
				49940, -- [10]
				49941, -- [11]
				55974, -- [12]
				65658, -- [13]
			},
			["icon"] = 237513,
			["name"] = "Blood Boil",
		},
		["PUISSANTSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53870, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Puissant Shadow Crystal",
		},
		["GLYPHOFARCANEBLAST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				56991, -- [1]
				62210, -- [2]
				62353, -- [3]
			},
			["icon"] = 132918,
			["name"] = "Glyph of Arcane Blast",
		},
		["HEAVYBRONZEMACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Heavy Bronze Mace",
			["icon"] = 133483,
			["id"] = {
				3296, -- [1]
				3301, -- [2]
			},
		},
		["STRONGTROLLSBLOODELIXIR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Strong Troll's Blood Elixir",
			["icon"] = 136243,
			["id"] = {
				3176, -- [1]
				3222, -- [2]
			},
		},
		["POLYMORPH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				118, -- [1]
				1168, -- [2]
				1192, -- [3]
				1219, -- [4]
				12824, -- [5]
				12825, -- [6]
				12826, -- [7]
				12827, -- [8]
				12828, -- [9]
				12829, -- [10]
				13323, -- [11]
				14621, -- [12]
				15534, -- [13]
				27760, -- [14]
				28271, -- [15]
				28272, -- [16]
				29124, -- [17]
				29848, -- [18]
				28285, -- [19]
				30838, -- [20]
				34639, -- [21]
				36840, -- [22]
				38245, -- [23]
				38896, -- [24]
				41334, -- [25]
				43309, -- [26]
				46280, -- [27]
				58537, -- [28]
				61025, -- [29]
				61305, -- [30]
				61721, -- [31]
				61780, -- [32]
				66043, -- [33]
				71319, -- [34]
				65801, -- [35]
			},
			["icon"] = 136071,
			["name"] = "Polymorph",
		},
		["TELEPORTIRONFORGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				3562, -- [1]
				3581, -- [2]
				27597, -- [3]
			},
			["icon"] = 135757,
			["name"] = "Teleport: Ironforge",
		},
		["ENCHANTEDTHORIUMBLADES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Enchanted Thorium Blades",
			["icon"] = 136241,
			["id"] = {
				34982, -- [1]
			},
		},
		["PIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53545, -- [1]
				50245, -- [2]
				53544, -- [3]
				53546, -- [4]
				53547, -- [5]
				53548, -- [6]
			},
			["castTime"] = 0,
			["icon"] = 133275,
			["name"] = "Pin",
		},
		["ENCHANTCHESTMINORSTATS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13626, -- [1]
				13627, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Minor Stats",
		},
		["FELCLOTHBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Felcloth Boots",
			["icon"] = 132149,
			["id"] = {
				18437, -- [1]
			},
		},
		["NORTHRENDINSCRIPTIONRESEARCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				61177, -- [1]
			},
			["icon"] = 237171,
			["name"] = "Northrend Inscription Research",
		},
		["GLYPHOFSHRED"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Shred",
			["icon"] = 136243,
			["id"] = {
				54815, -- [1]
				54859, -- [2]
				56957, -- [3]
			},
		},
		["SILVEREDBRONZEGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Silvered Bronze Gauntlets",
			["icon"] = 132939,
			["id"] = {
				3333, -- [1]
				3347, -- [2]
			},
		},
		["RUBYPENDANTOFFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Ruby Pendant of Fire",
			["icon"] = 136243,
			["id"] = {
				26883, -- [1]
			},
		},
		["JOURNEYMANHERBALIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Herbalist",
			["icon"] = 136246,
			["id"] = {
				2373, -- [1]
			},
		},
		["STAMPEDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				57390, -- [1]
				45876, -- [2]
				45901, -- [3]
				46384, -- [4]
				46385, -- [5]
				55218, -- [6]
				55219, -- [7]
				55220, -- [8]
				55221, -- [9]
				57386, -- [10]
				57389, -- [11]
				57391, -- [12]
				57392, -- [13]
				57393, -- [14]
				59823, -- [15]
			},
			["castTime"] = 0,
			["icon"] = 237572,
			["name"] = "Stampede",
		},
		["GREATERBLESSINGOFLIGHT"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				25890, -- [1]
				25948, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 135909,
			["name"] = "Greater Blessing of Light",
		},
		["MERCURIALADAMANTITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				38068, -- [1]
			},
			["icon"] = 135732,
			["name"] = "Mercurial Adamantite",
		},
		["THESHATTERER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				10003, -- [1]
				10004, -- [2]
			},
			["icon"] = 133055,
			["name"] = "The Shatterer",
		},
		["TIRELESSSKYFLAREDIAMOND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55386, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Tireless Skyflare Diamond",
		},
		["LESSERHEALINGPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Lesser Healing Potion",
			["icon"] = 136243,
			["id"] = {
				2337, -- [1]
				2341, -- [2]
			},
		},
		["TEMPEREDTITANSTEELHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55373, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Tempered Titansteel Helm",
		},
		["AQUAMARINEPENDANTOFTHEWARRIOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Aquamarine Pendant of the Warrior",
			["icon"] = 133303,
			["id"] = {
				26562, -- [1]
				26876, -- [2]
			},
		},
		["FELIRONCHAINTUNIC"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29556, -- [1]
			},
			["icon"] = 132636,
			["name"] = "Fel Iron Chain Tunic",
		},
		["TEARDROPBLOODGARNET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28903, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Teardrop Blood Garnet",
		},
		["DEATHKNIGHTPETSCALING01"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				54566, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 136024,
			["name"] = "Death Knight Pet Scaling 01",
		},
		["HEAVYWOOLBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Heavy Wool Bandage",
			["icon"] = 133687,
			["id"] = {
				3278, -- [1]
				3283, -- [2]
			},
		},
		["JOURNEYMANFISHING"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Fishing",
			["icon"] = 136245,
			["id"] = {
				7734, -- [1]
				64485, -- [2]
			},
		},
		["SEARINGPAIN"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				5676, -- [1]
				2945, -- [2]
				17919, -- [3]
				17920, -- [4]
				17921, -- [5]
				17922, -- [6]
				17923, -- [7]
				18154, -- [8]
				18155, -- [9]
				18156, -- [10]
				18157, -- [11]
				18158, -- [12]
				27210, -- [13]
				29492, -- [14]
				30358, -- [15]
				30459, -- [16]
				47814, -- [17]
				47815, -- [18]
				65819, -- [19]
			},
			["name"] = "Searing Pain",
			["icon"] = 135827,
			["castTime"] = 1500,
		},
		["FROSTWEAVETUNIC"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Frostweave Tunic",
			["icon"] = 132149,
			["id"] = {
				18403, -- [1]
			},
		},
		["PURIFY"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Purify",
			["icon"] = 135949,
			["id"] = {
				1152, -- [1]
				1937, -- [2]
				3725, -- [3]
			},
		},
		["BOLDBLOODGARNET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28905, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Bold Blood Garnet",
		},
		["RUNEDGOLDENROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 30000,
			["id"] = {
				13628, -- [1]
				13629, -- [2]
			},
			["icon"] = 135147,
			["name"] = "Runed Golden Rod",
		},
		["RUNICLEATHERBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runic Leather Belt",
			["icon"] = 136243,
			["id"] = {
				19072, -- [1]
			},
		},
		["MORTALSTRIKE"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Mortal Strike",
			["icon"] = 132355,
			["id"] = {
				9347, -- [1]
				12294, -- [2]
				13737, -- [3]
				15708, -- [4]
				16856, -- [5]
				17547, -- [6]
				19643, -- [7]
				21551, -- [8]
				21552, -- [9]
				21553, -- [10]
				21555, -- [11]
				21557, -- [12]
				21558, -- [13]
				24573, -- [14]
				27580, -- [15]
				25248, -- [16]
				29572, -- [17]
				30330, -- [18]
				31911, -- [19]
				32736, -- [20]
				35054, -- [21]
				37335, -- [22]
				39171, -- [23]
				40220, -- [24]
				43441, -- [25]
				43529, -- [26]
				44268, -- [27]
				47485, -- [28]
				47486, -- [29]
				57789, -- [30]
				67542, -- [31]
				71552, -- [32]
				65926, -- [33]
			},
		},
		["FELIRONPLATEBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29547, -- [1]
			},
			["icon"] = 132510,
			["name"] = "Fel Iron Plate Belt",
		},
		["GOBLINCONSTRUCTIONHELMET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12718, -- [1]
				12770, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Goblin Construction Helmet",
		},
		["RUNECLOTHBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runecloth Belt",
			["icon"] = 132149,
			["id"] = {
				18402, -- [1]
				18471, -- [2]
			},
		},
		["SAFEFALL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1860, -- [1]
				1862, -- [2]
				18443, -- [3]
				24350, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 132914,
			["name"] = "Safe Fall",
		},
		["GLYPHOFFLAMESHOCK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Flame Shock",
			["icon"] = 136243,
			["id"] = {
				55447, -- [1]
				55545, -- [2]
				57239, -- [3]
			},
		},
		["EXPLOSIVESHEEP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Explosive Sheep",
			["icon"] = 136243,
			["id"] = {
				3955, -- [1]
				4013, -- [2]
				4050, -- [3]
				4074, -- [4]
				8209, -- [5]
			},
		},
		["EXORCISM"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["name"] = "Exorcism",
			["icon"] = 135903,
			["id"] = {
				879, -- [1]
				559, -- [2]
				931, -- [3]
				3690, -- [4]
				5613, -- [5]
				5614, -- [6]
				5615, -- [7]
				5616, -- [8]
				5617, -- [9]
				10312, -- [10]
				10313, -- [11]
				10314, -- [12]
				10315, -- [13]
				10316, -- [14]
				10317, -- [15]
				17147, -- [16]
				17149, -- [17]
				27138, -- [18]
				33632, -- [19]
				48800, -- [20]
				48801, -- [21]
				52445, -- [22]
				58822, -- [23]
			},
		},
		["STANCEMASTERY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Stance Mastery",
			["icon"] = 136031,
			["id"] = {
				12678, -- [1]
			},
		},
		["GREATFEAST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				45554, -- [1]
				57301, -- [2]
				57337, -- [3]
			},
			["icon"] = 133971,
			["name"] = "Great Feast",
		},
		["INLAIDMITHRILCYLINDERPLANS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12895, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Inlaid Mithril Cylinder Plans",
		},
		["SPIKEDCOBALTBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54918, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Spiked Cobalt Boots",
		},
		["FURIOUSHOWL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				64491, -- [1]
				3149, -- [2]
				24597, -- [3]
				24599, -- [4]
				24603, -- [5]
				24604, -- [6]
				24605, -- [7]
				24607, -- [8]
				24608, -- [9]
				24609, -- [10]
				30636, -- [11]
				35942, -- [12]
				50728, -- [13]
				59274, -- [14]
				64492, -- [15]
				64493, -- [16]
				64494, -- [17]
				64495, -- [18]
			},
			["castTime"] = 0,
			["icon"] = 132203,
			["name"] = "Furious Howl",
		},
		["RUNICFOCUS"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = 0,
			["id"] = {
				53069, -- [1]
				59153, -- [2]
				61455, -- [3]
				61579, -- [4]
				61596, -- [5]
			},
			["icon"] = 136057,
			["name"] = "Runic Focus",
		},
		["TRACKDRAGONKIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				19879, -- [1]
				20156, -- [2]
			},
			["icon"] = 134153,
			["name"] = "Track Dragonkin",
		},
		["SARONITESHIV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55181, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Saronite Shiv",
		},
		["POACHEDNETTLEFISH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45565, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Poached Nettlefish",
		},
		["BROWNLINENVEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Brown Linen Vest",
			["icon"] = 136243,
			["id"] = {
				2385, -- [1]
				2996, -- [2]
			},
		},
		["CHEAPSHOT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1833, -- [1]
				1838, -- [2]
				6409, -- [3]
				14902, -- [4]
				30986, -- [5]
				31819, -- [6]
				31843, -- [7]
				34243, -- [8]
			},
			["castTime"] = 0,
			["icon"] = 132092,
			["name"] = "Cheap Shot",
		},
		["GLYPHOFENTANGLINGROOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Entangling Roots",
			["icon"] = 132918,
			["id"] = {
				48121, -- [1]
				54760, -- [2]
				54877, -- [3]
			},
		},
		["RUNEOFSWORDBREAKING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				54446, -- [1]
			},
			["icon"] = 132269,
			["name"] = "Rune of Swordbreaking",
		},
		["NERUBIANLEGGUARDS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50957, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Nerubian Legguards",
		},
		["RAISEDEAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 941,
			["id"] = {
				17473, -- [1]
				17475, -- [2]
				17476, -- [3]
				17477, -- [4]
				17478, -- [5]
				17479, -- [6]
				17480, -- [7]
				28353, -- [8]
				31617, -- [9]
				31624, -- [10]
				31625, -- [11]
				34011, -- [12]
				34012, -- [13]
				34019, -- [14]
				41071, -- [15]
				43559, -- [16]
				46584, -- [17]
				46585, -- [18]
				47505, -- [19]
				47527, -- [20]
				47532, -- [21]
				47596, -- [22]
				47597, -- [23]
				47598, -- [24]
				47599, -- [25]
				47616, -- [26]
				47617, -- [27]
				47618, -- [28]
				47619, -- [29]
				48289, -- [30]
				48597, -- [31]
				48605, -- [32]
				51516, -- [33]
				51517, -- [34]
				52150, -- [35]
				58814, -- [36]
				58815, -- [37]
				69562, -- [38]
				71769, -- [39]
				72376, -- [40]
				69350, -- [41]
				69431, -- [42]
			},
			["icon"] = 136187,
			["name"] = "Raise Dead",
		},
		["SOULSHATTER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				29858, -- [1]
				10771, -- [2]
				32835, -- [3]
			},
			["name"] = "Soulshatter",
			["icon"] = 135728,
			["castTime"] = 0,
		},
		["LIGHTSKYFORGEDAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36126, -- [1]
			},
			["icon"] = 132454,
			["name"] = "Light Skyforged Axe",
		},
		["ICELANCE"] = {
			["maxRange"] = 36,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				30455, -- [1]
				31766, -- [2]
				42913, -- [3]
				42914, -- [4]
				43427, -- [5]
				43571, -- [6]
				44176, -- [7]
				45906, -- [8]
				46194, -- [9]
				49906, -- [10]
				54261, -- [11]
			},
			["icon"] = 135844,
			["name"] = "Ice Lance",
		},
		["RUNEOFTHEFALLENCRUSADER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				53344, -- [1]
			},
			["icon"] = 135957,
			["name"] = "Rune of the Fallen Crusader",
		},
		["ENCHANTCLOAKSPELLPIERCING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Cloak - Spell Piercing",
			["icon"] = 136244,
			["id"] = {
				44582, -- [1]
			},
		},
		["DEMONSKIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				687, -- [1]
				696, -- [2]
				722, -- [3]
				1383, -- [4]
				20798, -- [5]
			},
			["icon"] = 136185,
			["name"] = "Demon Skin",
		},
		["SERENITYDUST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				50318, -- [1]
				52012, -- [2]
				52013, -- [3]
				52014, -- [4]
				52015, -- [5]
				52016, -- [6]
			},
			["castTime"] = 0,
			["icon"] = 135900,
			["name"] = "Serenity Dust",
		},
		["GREENLENS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Green Lens",
			["icon"] = 136243,
			["id"] = {
				12622, -- [1]
				12644, -- [2]
			},
		},
		["HOLYSHIELD"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Holy Shield",
			["icon"] = 135940,
			["id"] = {
				9800, -- [1]
				20925, -- [2]
				20927, -- [3]
				20928, -- [4]
				20955, -- [5]
				20956, -- [6]
				20957, -- [7]
				27179, -- [8]
				31904, -- [9]
				32777, -- [10]
				48951, -- [11]
				48952, -- [12]
			},
		},
		["DARKFROSTSCALELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60601, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Dark Frostscale Leggings",
		},
		["LIGHTLEATHERBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Light Leather Bracers",
			["icon"] = 136247,
			["id"] = {
				9065, -- [1]
				9066, -- [2]
			},
		},
		["ENCHANTCLOAKRESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13794, -- [1]
				13798, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Resistance",
		},
		["MANASPRINGTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				5675, -- [1]
				5678, -- [2]
				10495, -- [3]
				10496, -- [4]
				10497, -- [5]
				10512, -- [6]
				10514, -- [7]
				10515, -- [8]
				24854, -- [9]
				25570, -- [10]
				52031, -- [11]
				52032, -- [12]
				52033, -- [13]
				52034, -- [14]
				52035, -- [15]
				52036, -- [16]
				58771, -- [17]
				58773, -- [18]
				58774, -- [19]
				58778, -- [20]
				58779, -- [21]
				58780, -- [22]
			},
			["icon"] = 136053,
			["name"] = "Mana Spring Totem",
		},
		["RINGOFSILVERMIGHT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Ring of Silver Might",
			["icon"] = 136243,
			["id"] = {
				25317, -- [1]
			},
		},
		["MITHRILGYROSHOT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Mithril Gyro-Shot",
			["icon"] = 136243,
			["id"] = {
				12621, -- [1]
				12643, -- [2]
			},
		},
		["SMELTHARDENEDADAMANTITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				29686, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Smelt Hardened Adamantite",
		},
		["SCARLETSIGNET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				64728, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Scarlet Signet",
		},
		["SIMPLEKILT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Simple Kilt",
			["icon"] = 132149,
			["id"] = {
				12046, -- [1]
				12120, -- [2]
			},
		},
		["RETRIBUTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Retribution",
			["icon"] = 135741,
			["id"] = {
				49898, -- [1]
				52629, -- [2]
			},
		},
		["SPIKEDTITANSTEELTREADS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55375, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Spiked Titansteel Treads",
		},
		["ORANGEMAGEWEAVESHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Orange Mageweave Shirt",
			["icon"] = 132149,
			["id"] = {
				12061, -- [1]
				12106, -- [2]
			},
		},
		["ADAMANTITEFRAME"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				30306, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Adamantite Frame",
		},
		["CRYSTALCITRINENECKLACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				58141, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Crystal Citrine Necklace",
		},
		["GLYPHOFMUTILATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Mutilate",
			["icon"] = 136243,
			["id"] = {
				63268, -- [1]
				63899, -- [2]
				64260, -- [3]
			},
		},
		["SHADOWPROTECTION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				976, -- [1]
				977, -- [2]
				1279, -- [3]
				1280, -- [4]
				7235, -- [5]
				7241, -- [6]
				7242, -- [7]
				7243, -- [8]
				7244, -- [9]
				10957, -- [10]
				10958, -- [11]
				10959, -- [12]
				16874, -- [13]
				16891, -- [14]
				17548, -- [15]
				25433, -- [16]
				28537, -- [17]
				48169, -- [18]
				53915, -- [19]
			},
			["name"] = "Shadow Protection",
			["icon"] = 136121,
			["castTime"] = 0,
		},
		["TEMPEREDSARONITEBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54551, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Tempered Saronite Belt",
		},
		["DEMORALIZINGSHOUT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Demoralizing Shout",
			["icon"] = 132366,
			["id"] = {
				1160, -- [1]
				1065, -- [2]
				6190, -- [3]
				6191, -- [4]
				11554, -- [5]
				11555, -- [6]
				11556, -- [7]
				11557, -- [8]
				11558, -- [9]
				11559, -- [10]
				13730, -- [11]
				16244, -- [12]
				19778, -- [13]
				23511, -- [14]
				27579, -- [15]
				25202, -- [16]
				25203, -- [17]
				29584, -- [18]
				47437, -- [19]
				59613, -- [20]
				61044, -- [21]
				62102, -- [22]
				69565, -- [23]
			},
		},
		["ORNATESARONITEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56549, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Ornate Saronite Bracers",
		},
		["WHITEWOOLENDRESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "White Woolen Dress",
			["icon"] = 132149,
			["id"] = {
				8467, -- [1]
				8468, -- [2]
			},
		},
		["ELIXIROFGREATERAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Greater Agility",
			["icon"] = 136243,
			["id"] = {
				11467, -- [1]
				11498, -- [2]
			},
		},
		["HEAVYSILKBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Heavy Silk Bandage",
			["icon"] = 133672,
			["id"] = {
				7929, -- [1]
				7931, -- [2]
			},
		},
		["FIERYINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Fiery Ink",
			["icon"] = 132918,
			["id"] = {
				57710, -- [1]
			},
		},
		["BRILLIANTSARONITEBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59436, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Brilliant Saronite Belt",
		},
		["SAVAGESARONITEWALKERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55308, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Savage Saronite Walkers",
		},
		["TENUOUSSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53861, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Tenuous Shadow Crystal",
		},
		["FROSTWEAVENET"] = {
			["maxRange"] = 25,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55536, -- [1]
				55898, -- [2]
			},
			["icon"] = 134325,
			["name"] = "Frostweave Net",
		},
		["RUNECLOTHGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runecloth Gloves",
			["icon"] = 132149,
			["id"] = {
				18417, -- [1]
			},
		},
		["JUDGEMENTOFJUSTICE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Judgement of Justice",
			["icon"] = 236258,
			["id"] = {
				20184, -- [1]
				25944, -- [2]
				25945, -- [3]
				53407, -- [4]
			},
		},
		["FELWEIGHTSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				34607, -- [1]
			},
			["icon"] = 135260,
			["name"] = "Fel Weightstone",
		},
		["BRILLIANTPEARLBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				41414, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Brilliant Pearl Band",
		},
		["SPELLWEAVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56003, -- [1]
			},
			["icon"] = 132149,
			["name"] = "Spellweave",
		},
		["SKYSAPPHIREAMULET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				64726, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Sky Sapphire Amulet",
		},
		["TRACKHUMANOID"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				5226, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 132328,
			["name"] = "Track Humanoid",
		},
		["GLYPHOFARCANEPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56381, -- [1]
				56544, -- [2]
				56972, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Arcane Power",
		},
		["CINDERCLOTHROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Cindercloth Robe",
			["icon"] = 132149,
			["id"] = {
				12069, -- [1]
				12112, -- [2]
			},
		},
		["PRACTICELOCK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Practice Lock",
			["icon"] = 136243,
			["id"] = {
				8334, -- [1]
				8336, -- [2]
			},
		},
		["SIMPLEDRESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Simple Dress",
			["icon"] = 132149,
			["id"] = {
				8465, -- [1]
				8466, -- [2]
			},
		},
		["DARKMOONCARDOFTHENORTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				59504, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Darkmoon Card of the North",
		},
		["ARCANEEXPLOSION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1449, -- [1]
				1467, -- [2]
				8437, -- [3]
				8438, -- [4]
				8439, -- [5]
				8440, -- [6]
				8441, -- [7]
				8442, -- [8]
				9433, -- [9]
				10201, -- [10]
				10202, -- [11]
				10203, -- [12]
				10204, -- [13]
				11975, -- [14]
				13745, -- [15]
				15253, -- [16]
				15453, -- [17]
				19712, -- [18]
				21073, -- [19]
				22271, -- [20]
				22460, -- [21]
				22938, -- [22]
				23413, -- [23]
				25679, -- [24]
				26192, -- [25]
				26643, -- [26]
				27989, -- [27]
				28450, -- [28]
				30096, -- [29]
				27080, -- [30]
				27082, -- [31]
				27380, -- [32]
				27381, -- [33]
				29106, -- [34]
				29973, -- [35]
				30266, -- [36]
				32614, -- [37]
				33237, -- [38]
				33623, -- [39]
				33860, -- [40]
				33959, -- [41]
				34170, -- [42]
				34349, -- [43]
				34517, -- [44]
				34791, -- [45]
				34933, -- [46]
				35014, -- [47]
				35124, -- [48]
				36607, -- [49]
				38150, -- [50]
				38197, -- [51]
				38725, -- [52]
				38809, -- [53]
				39348, -- [54]
				40425, -- [55]
				41524, -- [56]
				42920, -- [57]
				42921, -- [58]
				44538, -- [59]
				46457, -- [60]
				46553, -- [61]
				46608, -- [62]
				51725, -- [63]
				51820, -- [64]
				54211, -- [65]
				54890, -- [66]
				54891, -- [67]
				55467, -- [68]
				56063, -- [69]
				56067, -- [70]
				56407, -- [71]
				56825, -- [72]
				58455, -- [73]
				59245, -- [74]
				59477, -- [75]
				65800, -- [76]
			},
			["icon"] = 136116,
			["name"] = "Arcane Explosion",
		},
		["CREATEFIRESTONELESSER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				1197, -- [1]
				6366, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132386,
			["name"] = "Create Firestone (Lesser)",
		},
		["RUNECLOTHROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runecloth Robe",
			["icon"] = 132149,
			["id"] = {
				18406, -- [1]
			},
		},
		["BLOODPRESENCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				48266, -- [1]
				50475, -- [2]
				50689, -- [3]
				54476, -- [4]
				55212, -- [5]
			},
			["icon"] = 135770,
			["name"] = "Blood Presence",
		},
		["CREATESOULSTONEMINOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				693, -- [1]
				1377, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 136210,
			["name"] = "Create Soulstone (Minor)",
		},
		["BRILLIANTNECKLACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Brilliant Necklace",
			["icon"] = 136243,
			["id"] = {
				36523, -- [1]
			},
		},
		["JEWELCRAFTING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				25229, -- [1]
				25230, -- [2]
				28894, -- [3]
				28895, -- [4]
				28897, -- [5]
				51311, -- [6]
			},
			["icon"] = 134071,
			["name"] = "Jewelcrafting",
		},
		["CREATESPELLSTONEMAJOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				17728, -- [1]
				17733, -- [2]
			},
			["castTime"] = 5000,
			["icon"] = 134131,
			["name"] = "Create Spellstone (Major)",
		},
		["GLYPHOFCLEANSING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Cleansing",
			["icon"] = 136243,
			["id"] = {
				54935, -- [1]
				55119, -- [2]
				57020, -- [3]
			},
		},
		["ARCTICBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50948, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Arctic Boots",
		},
		["SPIKEDCOBALTSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54941, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Spiked Cobalt Shoulders",
		},
		["AQUATICFORM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Aquatic Form",
			["icon"] = 132112,
			["id"] = {
				1066, -- [1]
				1446, -- [2]
			},
		},
		["HEAVYLINENGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Heavy Linen Gloves",
			["icon"] = 132149,
			["id"] = {
				3840, -- [1]
				3876, -- [2]
			},
		},
		["DEADLYSARONITEDIRK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55206, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Deadly Saronite Dirk",
		},
		["GHOSTWEAVEVEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Ghostweave Vest",
			["icon"] = 132149,
			["id"] = {
				18416, -- [1]
			},
		},
		["HEARTSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55050, -- [1]
				55258, -- [2]
				55259, -- [3]
				55260, -- [4]
				55261, -- [5]
				55262, -- [6]
				55978, -- [7]
				59790, -- [8]
				59792, -- [9]
			},
			["icon"] = 135675,
			["name"] = "Heart Strike",
		},
		["DRAGONSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				36262, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Dragonstrike",
		},
		["ELIXIROFGREATERDEFENSE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Greater Defense",
			["icon"] = 136243,
			["id"] = {
				11450, -- [1]
				11484, -- [2]
			},
		},
		["WEAKTROLLSBLOODELIXIR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Weak Troll's Blood Elixir",
			["icon"] = 136243,
			["id"] = {
				3170, -- [1]
				3219, -- [2]
			},
		},
		["DEADLYTHROW"] = {
			["maxRange"] = 30,
			["minRange"] = 5,
			["id"] = {
				26679, -- [1]
				37074, -- [2]
				48673, -- [3]
				48674, -- [4]
				52885, -- [5]
				59180, -- [6]
				64499, -- [7]
			},
			["castTime"] = -999500,
			["icon"] = 135430,
			["name"] = "Deadly Throw",
		},
		["GUNS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Guns",
			["icon"] = 135610,
			["id"] = {
				266, -- [1]
				15996, -- [2]
			},
		},
		["BOARSSPEED"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				19596, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 132184,
			["name"] = "Boar's Speed",
		},
		["CHARGE"] = {
			["maxRange"] = 25,
			["minRange"] = 8,
			["id"] = {
				61685, -- [1]
				100, -- [2]
				1738, -- [3]
				6178, -- [4]
				6180, -- [5]
				7370, -- [6]
				7371, -- [7]
				11578, -- [8]
				11579, -- [9]
				20508, -- [10]
				22120, -- [11]
				22911, -- [12]
				24023, -- [13]
				24193, -- [14]
				24315, -- [15]
				24408, -- [16]
				25821, -- [17]
				26177, -- [18]
				26178, -- [19]
				26179, -- [20]
				26184, -- [21]
				26185, -- [22]
				26186, -- [23]
				26201, -- [24]
				26202, -- [25]
				27685, -- [26]
				28343, -- [27]
				25999, -- [28]
				29320, -- [29]
				29847, -- [30]
				31426, -- [31]
				31733, -- [32]
				32323, -- [33]
				33709, -- [34]
				34846, -- [35]
				35412, -- [36]
				35570, -- [37]
				35754, -- [38]
				36058, -- [39]
				36140, -- [40]
				36509, -- [41]
				37511, -- [42]
				38461, -- [43]
				39574, -- [44]
				40602, -- [45]
				41581, -- [46]
				42003, -- [47]
				43519, -- [48]
				43651, -- [49]
				43807, -- [50]
				44357, -- [51]
				44884, -- [52]
				49758, -- [53]
				50582, -- [54]
				51492, -- [55]
				51756, -- [56]
				51842, -- [57]
				52538, -- [58]
				52577, -- [59]
				52856, -- [60]
				53148, -- [61]
				54460, -- [62]
				55317, -- [63]
				55530, -- [64]
				57627, -- [65]
				58619, -- [66]
				58991, -- [67]
				59040, -- [68]
				59611, -- [69]
				60067, -- [70]
				62563, -- [71]
				62613, -- [72]
				62614, -- [73]
				62874, -- [74]
				62960, -- [75]
				62961, -- [76]
				62977, -- [77]
				63003, -- [78]
				63010, -- [79]
				63661, -- [80]
				63665, -- [81]
				64591, -- [82]
				64719, -- [83]
				65927, -- [84]
				68498, -- [85]
				68501, -- [86]
				66481, -- [87]
				74399, -- [88]
				68282, -- [89]
				68284, -- [90]
				68301, -- [91]
				68307, -- [92]
				68321, -- [93]
				71553, -- [94]
			},
			["castTime"] = 0,
			["icon"] = 132183,
			["name"] = "Charge",
		},
		["GHOSTWEAVEPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Ghostweave Pants",
			["icon"] = 132149,
			["id"] = {
				18441, -- [1]
			},
		},
		["DISTRACT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				1725, -- [1]
				1728, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132289,
			["name"] = "Distract",
		},
		["INSECTSWARM"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Insect Swarm",
			["icon"] = 136045,
			["id"] = {
				5570, -- [1]
				24974, -- [2]
				24975, -- [3]
				24976, -- [4]
				24977, -- [5]
				24978, -- [6]
				24979, -- [7]
				24980, -- [8]
				24981, -- [9]
				27013, -- [10]
				48468, -- [11]
				65855, -- [12]
			},
		},
		["SENSEUNDEAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Sense Undead",
			["icon"] = 135974,
			["id"] = {
				5502, -- [1]
				922, -- [2]
				5503, -- [3]
			},
		},
		["SPICEDWOLFMEAT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Spiced Wolf Meat",
			["icon"] = 134021,
			["id"] = {
				2539, -- [1]
				2559, -- [2]
			},
		},
		["MASTERTAILOR"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				26791, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Master Tailor",
		},
		["ASTRALRECALL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				556, -- [1]
				577, -- [2]
				1352, -- [3]
			},
			["icon"] = 136010,
			["name"] = "Astral Recall",
		},
		["ONEHANDEDAXES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "One-Handed Axes",
			["icon"] = 132392,
			["id"] = {
				196, -- [1]
				15984, -- [2]
			},
		},
		["SCROLLOFSPIRITIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Spirit III",
			["icon"] = 132918,
			["id"] = {
				50606, -- [1]
			},
		},
		["FEEDBACK"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				6347, -- [1]
				13896, -- [2]
				19267, -- [3]
				19268, -- [4]
				19269, -- [5]
				19270, -- [6]
				19271, -- [7]
				19273, -- [8]
				19274, -- [9]
				19275, -- [10]
				19345, -- [11]
				19346, -- [12]
				19347, -- [13]
				19348, -- [14]
				19349, -- [15]
				32897, -- [16]
			},
			["name"] = "Feedback",
			["icon"] = 136189,
			["castTime"] = 0,
		},
		["GLYPHOFHEROICSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Heroic Strike",
			["icon"] = 132918,
			["id"] = {
				57158, -- [1]
				58357, -- [2]
				58362, -- [3]
				58403, -- [4]
			},
		},
		["INTERCEPT"] = {
			["maxRange"] = 25,
			["minRange"] = 8,
			["id"] = {
				30195, -- [1]
				20252, -- [2]
				20611, -- [3]
				20616, -- [4]
				20617, -- [5]
				20621, -- [6]
				20622, -- [7]
				27577, -- [8]
				27826, -- [9]
				20253, -- [10]
				20614, -- [11]
				20615, -- [12]
				25272, -- [13]
				25273, -- [14]
				25274, -- [15]
				25275, -- [16]
				30151, -- [17]
				30153, -- [18]
				30154, -- [19]
				30194, -- [20]
				30197, -- [21]
				30198, -- [22]
				30199, -- [23]
				30200, -- [24]
				47995, -- [25]
				47996, -- [26]
				50823, -- [27]
				58743, -- [28]
				58747, -- [29]
				58769, -- [30]
				61490, -- [31]
				61491, -- [32]
				67540, -- [33]
				67573, -- [34]
			},
			["castTime"] = 0,
			["icon"] = 135860,
			["name"] = "Intercept",
		},
		["BLESSINGOFSALVATION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				1038, -- [1]
				1912, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 135967,
			["name"] = "Blessing of Salvation",
		},
		["BLESSINGOFPROTECTION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				1022, -- [1]
				1911, -- [2]
				5599, -- [3]
				5600, -- [4]
				10278, -- [5]
				10279, -- [6]
				41450, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 135964,
			["name"] = "Blessing of Protection",
		},
		["BLOODSUNNECKLACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				56196, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Blood Sun Necklace",
		},
		["GREATERBLESSINGOFSALVATION"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				25895, -- [1]
				25939, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 135910,
			["name"] = "Greater Blessing of Salvation",
		},
		["COUNTERSPELL"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2139, -- [1]
				1053, -- [2]
				3576, -- [3]
				15122, -- [4]
				19715, -- [5]
				20537, -- [6]
				20788, -- [7]
				29443, -- [8]
				29961, -- [9]
				31596, -- [10]
				31999, -- [11]
				37470, -- [12]
				51610, -- [13]
				65790, -- [14]
			},
			["icon"] = 135856,
			["name"] = "Counterspell",
		},
		["JUDGEMENT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				3684, -- [1]
				10321, -- [2]
				20271, -- [3]
				23590, -- [4]
				23591, -- [5]
				35170, -- [6]
				41467, -- [7]
				43838, -- [8]
				54158, -- [9]
			},
			["castTime"] = 3000,
			["icon"] = 136235,
			["name"] = "Judgement",
		},
		["ROAROFRECOVERY"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				53517, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 236161,
			["name"] = "Roar of Recovery",
		},
		["TIGERSFURY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Tiger's Fury",
			["icon"] = 132242,
			["id"] = {
				5217, -- [1]
				5218, -- [2]
				6793, -- [3]
				6794, -- [4]
				9845, -- [5]
				9846, -- [6]
				9847, -- [7]
				9848, -- [8]
				50212, -- [9]
				50213, -- [10]
			},
		},
		["EARTHSHIELD"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				379, -- [1]
				974, -- [2]
				32593, -- [3]
				32594, -- [4]
				32734, -- [5]
				38590, -- [6]
				49283, -- [7]
				49284, -- [8]
				54479, -- [9]
				54480, -- [10]
				55599, -- [11]
				55600, -- [12]
				56451, -- [13]
				57802, -- [14]
				57803, -- [15]
				58981, -- [16]
				58982, -- [17]
				59471, -- [18]
				59472, -- [19]
				60013, -- [20]
				60014, -- [21]
				69568, -- [22]
				69569, -- [23]
				67530, -- [24]
				67537, -- [25]
				66063, -- [26]
				66064, -- [27]
				69925, -- [28]
				69926, -- [29]
			},
			["icon"] = 136089,
			["name"] = "Earth Shield",
		},
		["THROW"] = {
			["maxRange"] = 30,
			["minRange"] = 5,
			["castTime"] = 500,
			["id"] = {
				2764, -- [1]
				10277, -- [2]
				15607, -- [3]
				15795, -- [4]
				16000, -- [5]
				19785, -- [6]
				22887, -- [7]
				29582, -- [8]
				38556, -- [9]
				38557, -- [10]
				38558, -- [11]
				38559, -- [12]
				38560, -- [13]
				38561, -- [14]
				38562, -- [15]
				38563, -- [16]
				38564, -- [17]
				38565, -- [18]
				38566, -- [19]
				38567, -- [20]
				38568, -- [21]
				38569, -- [22]
				38570, -- [23]
				38904, -- [24]
				39060, -- [25]
				40317, -- [26]
				40413, -- [27]
				40843, -- [28]
				43409, -- [29]
				43665, -- [30]
				44012, -- [31]
				45815, -- [32]
				48975, -- [33]
				49090, -- [34]
				49091, -- [35]
				51454, -- [36]
				51925, -- [37]
				52356, -- [38]
				52904, -- [39]
				53824, -- [40]
				54983, -- [41]
				55348, -- [42]
				55425, -- [43]
				58966, -- [44]
				59179, -- [45]
				59209, -- [46]
				59249, -- [47]
				59603, -- [48]
				59696, -- [49]
				61168, -- [50]
				68812, -- [51]
			},
			["icon"] = 132324,
			["name"] = "Throw",
		},
		["NERUBIANBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50960, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Nerubian Boots",
		},
		["GRANDMASTERJEWELCRAFTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				51310, -- [1]
				65286, -- [2]
			},
			["icon"] = 134072,
			["name"] = "Grand Master Jewelcrafter",
		},
		["FROSTWOVENLEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				56030, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostwoven Leggings",
		},
		["SILVERROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Silver Rod",
			["icon"] = 135138,
			["id"] = {
				7818, -- [1]
				7820, -- [2]
			},
		},
		["LESSERMAGICWAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 10000,
			["id"] = {
				14293, -- [1]
				14805, -- [2]
			},
			["icon"] = 135139,
			["name"] = "Lesser Magic Wand",
		},
		["NERUBIANHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				60624, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Nerubian Helm",
		},
		["MAUL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Maul",
			["icon"] = 132136,
			["id"] = {
				6807, -- [1]
				6808, -- [2]
				6809, -- [3]
				6810, -- [4]
				6811, -- [5]
				6812, -- [6]
				7092, -- [7]
				8972, -- [8]
				8973, -- [9]
				9745, -- [10]
				9746, -- [11]
				9880, -- [12]
				9881, -- [13]
				9882, -- [14]
				9883, -- [15]
				12161, -- [16]
				15793, -- [17]
				17156, -- [18]
				20751, -- [19]
				27553, -- [20]
				26996, -- [21]
				34298, -- [22]
				48479, -- [23]
				48480, -- [24]
				51875, -- [25]
				52506, -- [26]
				54459, -- [27]
			},
		},
		["FIRESHIELD"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				27269, -- [1]
				134, -- [2]
				1167, -- [3]
				2947, -- [4]
				2949, -- [5]
				8316, -- [6]
				8317, -- [7]
				8318, -- [8]
				8319, -- [9]
				11350, -- [10]
				11351, -- [11]
				11770, -- [12]
				11771, -- [13]
				11772, -- [14]
				11773, -- [15]
				11966, -- [16]
				11968, -- [17]
				13376, -- [18]
				13377, -- [19]
				18268, -- [20]
				18968, -- [21]
				19626, -- [22]
				19627, -- [23]
				20322, -- [24]
				20323, -- [25]
				20324, -- [26]
				20326, -- [27]
				20327, -- [28]
				27486, -- [29]
				27489, -- [30]
				30513, -- [31]
				30514, -- [32]
				32749, -- [33]
				32751, -- [34]
				35265, -- [35]
				35266, -- [36]
				36907, -- [37]
				37282, -- [38]
				37283, -- [39]
				37318, -- [40]
				37434, -- [41]
				38732, -- [42]
				38733, -- [43]
				38855, -- [44]
				38893, -- [45]
				38901, -- [46]
				38902, -- [47]
				38933, -- [48]
				38934, -- [49]
				47983, -- [50]
				47998, -- [51]
				61144, -- [52]
				63778, -- [53]
				63779, -- [54]
				71514, -- [55]
				71515, -- [56]
			},
			["castTime"] = 0,
			["icon"] = 135806,
			["name"] = "Fire Shield",
		},
		["MASTERSSPELLTHREAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 4000,
			["id"] = {
				56034, -- [1]
			},
			["icon"] = 136011,
			["name"] = "Master's Spellthread",
		},
		["SHADOWMELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Shadowmeld",
			["icon"] = 132089,
			["id"] = {
				58984, -- [1]
				743, -- [2]
				20580, -- [3]
				62196, -- [4]
				62199, -- [5]
			},
		},
		["DUSKWEAVEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55922, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Duskweave Gloves",
		},
		["EXPERTENGINEER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Expert Engineer",
			["icon"] = 136243,
			["id"] = {
				4041, -- [1]
			},
		},
		["PURIFICATIONPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Purification Potion",
			["icon"] = 136243,
			["id"] = {
				17572, -- [1]
			},
		},
		["SUNDEREDDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53927, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Sundered Dark Jade",
		},
		["FINDTREASURE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2481, -- [1]
			},
			["icon"] = 135725,
			["name"] = "Find Treasure",
		},
		["REMOVELESSERCURSE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				475, -- [1]
				1176, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 136082,
			["name"] = "Remove Lesser Curse",
		},
		["DEMORALIZINGSCREECH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				55487, -- [1]
				24423, -- [2]
				24424, -- [3]
				24577, -- [4]
				24578, -- [5]
				24579, -- [6]
				24580, -- [7]
				24581, -- [8]
				24582, -- [9]
				27051, -- [10]
				27349, -- [11]
			},
			["castTime"] = 0,
			["icon"] = 132200,
			["name"] = "Demoralizing Screech",
		},
		["MASSDISPEL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				4526, -- [1]
				32375, -- [2]
				32592, -- [3]
				38082, -- [4]
				39897, -- [5]
				72734, -- [6]
			},
			["name"] = "Mass Dispel",
			["icon"] = 136222,
			["castTime"] = 1000,
		},
		["CINDERCLOTHBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Cindercloth Boots",
			["icon"] = 132149,
			["id"] = {
				12088, -- [1]
				12129, -- [2]
			},
		},
		["TIMELESSDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53894, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Timeless Dark Jade",
		},
		["PROTECTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Protection",
			["icon"] = 132360,
			["id"] = {
				42206, -- [1]
				53763, -- [2]
			},
		},
		["FELINTELLIGENCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				57565, -- [1]
				54424, -- [2]
				57564, -- [3]
				57566, -- [4]
				57567, -- [5]
			},
			["castTime"] = 0,
			["icon"] = 136125,
			["name"] = "Fel Intelligence",
		},
		["SPIKEDCOLLAR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53184, -- [1]
				53182, -- [2]
				53183, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 133309,
			["name"] = "Spiked Collar",
		},
		["FROSTSCALEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				60599, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Frostscale Bracers",
		},
		["WILDHUNT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				62762, -- [1]
				62758, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 237377,
			["name"] = "Wild Hunt",
		},
		["GLYPHOFDIVINITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Divinity",
			["icon"] = 136243,
			["id"] = {
				54939, -- [1]
				54986, -- [2]
				55123, -- [3]
				57031, -- [4]
			},
		},
		["MINDSEAR"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["id"] = {
				32000, -- [1]
				36447, -- [2]
				48045, -- [3]
				49821, -- [4]
				53022, -- [5]
				53023, -- [6]
				60440, -- [7]
				60441, -- [8]
			},
			["name"] = "Mind Sear",
			["icon"] = 136208,
			["castTime"] = 0,
		},
		["FELCLOTHSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Felcloth Shoulders",
			["icon"] = 132149,
			["id"] = {
				18453, -- [1]
			},
		},
		["REDLINENSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Red Linen Shirt",
			["icon"] = 132149,
			["id"] = {
				2392, -- [1]
				2414, -- [2]
			},
		},
		["GLYPHOFREVENGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Revenge",
			["icon"] = 132918,
			["id"] = {
				57165, -- [1]
				58363, -- [2]
				58364, -- [3]
				58398, -- [4]
			},
		},
		["LIGHTNINGBOLT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				403, -- [1]
				529, -- [2]
				531, -- [3]
				548, -- [4]
				566, -- [5]
				915, -- [6]
				943, -- [7]
				944, -- [8]
				1324, -- [9]
				1325, -- [10]
				1357, -- [11]
				1358, -- [12]
				3089, -- [13]
				6041, -- [14]
				6043, -- [15]
				8246, -- [16]
				9532, -- [17]
				10391, -- [18]
				10392, -- [19]
				10393, -- [20]
				10394, -- [21]
				12167, -- [22]
				13482, -- [23]
				13527, -- [24]
				14109, -- [25]
				14119, -- [26]
				15207, -- [27]
				15208, -- [28]
				15209, -- [29]
				15210, -- [30]
				15234, -- [31]
				15801, -- [32]
				16782, -- [33]
				18081, -- [34]
				18089, -- [35]
				19874, -- [36]
				20295, -- [37]
				20802, -- [38]
				20805, -- [39]
				20824, -- [40]
				22414, -- [41]
				23592, -- [42]
				26098, -- [43]
				25448, -- [44]
				25449, -- [45]
				31764, -- [46]
				34345, -- [47]
				35010, -- [48]
				36152, -- [49]
				37273, -- [50]
				37661, -- [51]
				37664, -- [52]
				38465, -- [53]
				39065, -- [54]
				41184, -- [55]
				42024, -- [56]
				43526, -- [57]
				43903, -- [58]
				45075, -- [59]
				45284, -- [60]
				45286, -- [61]
				45287, -- [62]
				45288, -- [63]
				45289, -- [64]
				45290, -- [65]
				45291, -- [66]
				45292, -- [67]
				45293, -- [68]
				45294, -- [69]
				45295, -- [70]
				45296, -- [71]
				48698, -- [72]
				48895, -- [73]
				49237, -- [74]
				49238, -- [75]
				49239, -- [76]
				49240, -- [77]
				49418, -- [78]
				49454, -- [79]
				51587, -- [80]
				51618, -- [81]
				53044, -- [82]
				53314, -- [83]
				54843, -- [84]
				55044, -- [85]
				56326, -- [86]
				56891, -- [87]
				57780, -- [88]
				57781, -- [89]
				59006, -- [90]
				59024, -- [91]
				59081, -- [92]
				59169, -- [93]
				59199, -- [94]
				59683, -- [95]
				59863, -- [96]
				60009, -- [97]
				60032, -- [98]
				61374, -- [99]
				61893, -- [100]
				63809, -- [101]
				64098, -- [102]
				64696, -- [103]
				69567, -- [104]
				65987, -- [105]
				71934, -- [106]
				69970, -- [107]
			},
			["icon"] = 136048,
			["name"] = "Lightning Bolt",
		},
		["BRONZESETTING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Bronze Setting",
			["icon"] = 136243,
			["id"] = {
				25278, -- [1]
			},
		},
		["NERUBIANLEGREINFORCEMENTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3763,
			["id"] = {
				50904, -- [1]
				60584, -- [2]
			},
			["icon"] = 136247,
			["name"] = "Nerubian Leg Reinforcements",
		},
		["WARLOCKPETSCALING05"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				61013, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 136243,
			["name"] = "Warlock Pet Scaling 05",
		},
		["HEAVYDYNAMITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Heavy Dynamite",
			["icon"] = 136243,
			["id"] = {
				3946, -- [1]
				4007, -- [2]
				4062, -- [3]
				32191, -- [4]
				37666, -- [5]
			},
		},
		["SOOTHINGKISS"] = {
			["maxRange"] = 10,
			["minRange"] = 0,
			["id"] = {
				27275, -- [1]
				6360, -- [2]
				6362, -- [3]
				7813, -- [4]
				7879, -- [5]
				11784, -- [6]
				11785, -- [7]
				11786, -- [8]
				11787, -- [9]
				20403, -- [10]
				20404, -- [11]
				20405, -- [12]
				20406, -- [13]
				27494, -- [14]
			},
			["castTime"] = 0,
			["icon"] = 136209,
			["name"] = "Soothing Kiss",
		},
		["GLYPHOFMOONFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Moonfire",
			["icon"] = 237171,
			["id"] = {
				52085, -- [1]
				54829, -- [2]
				54876, -- [3]
				56951, -- [4]
			},
		},
		["GLYPHOFHEALTHFUNNEL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Health Funnel",
			["icon"] = 136243,
			["id"] = {
				56238, -- [1]
				56288, -- [2]
				57265, -- [3]
			},
		},
		["HYPERSPEEDACCELERATORS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				54999, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Hyperspeed Accelerators",
		},
		["TOUCHOFWEAKNESS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				2652, -- [1]
				2943, -- [2]
				19249, -- [3]
				19251, -- [4]
				19252, -- [5]
				19253, -- [6]
				19254, -- [7]
				19261, -- [8]
				19262, -- [9]
				19264, -- [10]
				19265, -- [11]
				19266, -- [12]
				19318, -- [13]
				19320, -- [14]
				19321, -- [15]
				19322, -- [16]
				19323, -- [17]
				19324, -- [18]
				28598, -- [19]
			},
			["castTime"] = 0,
			["icon"] = 136143,
			["name"] = "Touch of Weakness",
		},
		["JAGGEDDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53916, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Jagged Dark Jade",
		},
		["HEAVYBOREANARMORKIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				50909, -- [1]
				50963, -- [2]
			},
			["icon"] = 136247,
			["name"] = "Heavy Borean Armor Kit",
		},
		["GROUNDINGTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8177, -- [1]
				8180, -- [2]
				34079, -- [3]
				65989, -- [4]
			},
			["icon"] = 136039,
			["name"] = "Grounding Totem",
		},
		["GOBLINROCKETBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8892, -- [1]
				8895, -- [2]
				12776, -- [3]
			},
			["icon"] = 135805,
			["name"] = "Goblin Rocket Boots",
		},
		["FURLININGSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				57690, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Fur Lining - Stamina",
		},
		["PEARLHANDLEDDAGGER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Pearl-handled Dagger",
			["icon"] = 135641,
			["id"] = {
				6517, -- [1]
				6520, -- [2]
			},
		},
		["ELEGANTSILVERRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Elegant Silver Ring",
			["icon"] = 136243,
			["id"] = {
				25280, -- [1]
			},
		},
		["FROSTSCALEBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50955, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Frostscale Belt",
		},
		["JOURNEYMANALCHEMIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Alchemist",
			["icon"] = 136240,
			["id"] = {
				2280, -- [1]
			},
		},
		["SMELTTITANIUM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				55211, -- [1]
			},
			["icon"] = 135811,
			["name"] = "Smelt Titanium",
		},
		["TENDONRIP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53573, -- [1]
				3604, -- [2]
				44622, -- [3]
				50271, -- [4]
				53571, -- [5]
				53572, -- [6]
				53574, -- [7]
				53575, -- [8]
			},
			["castTime"] = 0,
			["icon"] = 132109,
			["name"] = "Tendon Rip",
		},
		["MONARCHCRAB"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59759, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Monarch Crab",
		},
		["HEALINGSTREAMTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				5394, -- [1]
				5396, -- [2]
				6375, -- [3]
				6377, -- [4]
				6383, -- [5]
				6384, -- [6]
				10462, -- [7]
				10463, -- [8]
				10464, -- [9]
				10465, -- [10]
				25567, -- [11]
				35199, -- [12]
				52041, -- [13]
				52042, -- [14]
				52046, -- [15]
				52047, -- [16]
				52048, -- [17]
				52049, -- [18]
				52050, -- [19]
				58755, -- [20]
				58756, -- [21]
				58757, -- [22]
				58759, -- [23]
				58760, -- [24]
				58761, -- [25]
				65993, -- [26]
				65995, -- [27]
				75368, -- [28]
				68883, -- [29]
				70517, -- [30]
			},
			["icon"] = 135127,
			["name"] = "Healing Stream Totem",
		},
		["IRONBOUNDTOME"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59497, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Iron-bound Tome",
		},
		["GRANDMASTERMINER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				50309, -- [1]
				65289, -- [2]
			},
			["icon"] = 136248,
			["name"] = "Grand Master Miner",
		},
		["FLASHOFLIGHT"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 1411,
			["name"] = "Flash of Light",
			["icon"] = 135907,
			["id"] = {
				19750, -- [1]
				19751, -- [2]
				19939, -- [3]
				19940, -- [4]
				19941, -- [5]
				19942, -- [6]
				19943, -- [7]
				19944, -- [8]
				19945, -- [9]
				19946, -- [10]
				19947, -- [11]
				19948, -- [12]
				19993, -- [13]
				25514, -- [14]
				27137, -- [15]
				33641, -- [16]
				37249, -- [17]
				37254, -- [18]
				37257, -- [19]
				48784, -- [20]
				48785, -- [21]
				57766, -- [22]
				59997, -- [23]
				66113, -- [24]
				71930, -- [25]
				66922, -- [26]
			},
		},
		["BLESSINGOFKINGS"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Blessing of Kings",
			["icon"] = 135995,
			["id"] = {
				20217, -- [1]
				56525, -- [2]
				58054, -- [3]
			},
		},
		["EARTHFORGEDLEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36122, -- [1]
			},
			["icon"] = 134693,
			["name"] = "Earthforged Leggings",
		},
		["FIRERESISTANCEAURA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Fire Resistance Aura",
			["icon"] = 135824,
			["id"] = {
				19891, -- [1]
				19894, -- [2]
				19899, -- [3]
				19900, -- [4]
				19908, -- [5]
				19909, -- [6]
				27153, -- [7]
				48947, -- [8]
			},
		},
		["REDSWASHBUCKLERSSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Red Swashbuckler's Shirt",
			["icon"] = 132149,
			["id"] = {
				8489, -- [1]
				8491, -- [2]
			},
		},
		["LAMBENTDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53928, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Lambent Dark Jade",
		},
		["DEVOURINGPLAGUE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				2944, -- [1]
				2946, -- [2]
				19276, -- [3]
				19277, -- [4]
				19278, -- [5]
				19279, -- [6]
				19280, -- [7]
				19313, -- [8]
				19314, -- [9]
				19315, -- [10]
				19316, -- [11]
				19317, -- [12]
				25467, -- [13]
				48299, -- [14]
				48300, -- [15]
			},
			["name"] = "Devouring Plague",
			["icon"] = 252997,
			["castTime"] = 0,
		},
		["DIVINESHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Divine Shield",
			["icon"] = 135896,
			["id"] = {
				642, -- [1]
				659, -- [2]
				1020, -- [3]
				1021, -- [4]
				1897, -- [5]
				1898, -- [6]
				13874, -- [7]
				29382, -- [8]
				33581, -- [9]
				40733, -- [10]
				41367, -- [11]
				54322, -- [12]
				63148, -- [13]
				66010, -- [14]
				67251, -- [15]
				71550, -- [16]
			},
		},
		["SILVERBACK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				62764, -- [1]
				62765, -- [2]
				62800, -- [3]
				62801, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 132189,
			["name"] = "Silverback",
		},
		["HEAVYADAMANTITERING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				31052, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Heavy Adamantite Ring",
		},
		["DRAINMANA"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				5138, -- [1]
				496, -- [2]
				862, -- [3]
				5139, -- [4]
				6226, -- [5]
				6227, -- [6]
				11703, -- [7]
				11704, -- [8]
				11705, -- [9]
				11706, -- [10]
				17008, -- [11]
				17243, -- [12]
				17682, -- [13]
				18394, -- [14]
				25671, -- [15]
				25676, -- [16]
				25754, -- [17]
				25755, -- [18]
				26457, -- [19]
				26559, -- [20]
				26639, -- [21]
				29058, -- [22]
				29881, -- [23]
				35332, -- [24]
				36088, -- [25]
				36095, -- [26]
				44956, -- [27]
				46153, -- [28]
				46453, -- [29]
				58770, -- [30]
				58772, -- [31]
				69067, -- [32]
			},
			["name"] = "Drain Mana",
			["icon"] = 136208,
			["castTime"] = 0,
		},
		["ARCANITEROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Arcanite Rod",
			["icon"] = 135156,
			["id"] = {
				20201, -- [1]
				20202, -- [2]
			},
		},
		["TWOHANDEDSWORDS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				202, -- [1]
				15983, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132223,
			["name"] = "Two-Handed Swords",
		},
		["LUMINOUSHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53881, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Luminous Huge Citrine",
		},
		["SCROLLOFINTELLECTVIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50604, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Intellect VIII",
		},
		["SHIELDBASH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Shield Bash",
			["icon"] = 132357,
			["id"] = {
				72, -- [1]
				1671, -- [2]
				1672, -- [3]
				1675, -- [4]
				1676, -- [5]
				1677, -- [6]
				11972, -- [7]
				29704, -- [8]
				33871, -- [9]
				35178, -- [10]
				36988, -- [11]
				38233, -- [12]
				41180, -- [13]
				41197, -- [14]
				72194, -- [15]
				70964, -- [16]
			},
		},
		["CONJUREWATER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				5504, -- [1]
				3696, -- [2]
				5505, -- [3]
				5506, -- [4]
				5507, -- [5]
				5565, -- [6]
				5566, -- [7]
				6127, -- [8]
				6128, -- [9]
				6635, -- [10]
				6638, -- [11]
				6639, -- [12]
				10138, -- [13]
				10139, -- [14]
				10140, -- [15]
				10141, -- [16]
				10142, -- [17]
				10143, -- [18]
				27090, -- [19]
				29975, -- [20]
				36879, -- [21]
				37420, -- [22]
				37421, -- [23]
				42978, -- [24]
			},
			["icon"] = 132793,
			["name"] = "Conjure Water",
		},
		["ENCHANTCHESTLESSERABSORPTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13538, -- [1]
				13539, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Lesser Absorption",
		},
		["GNOMISHFLAMETURRET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				30568, -- [1]
				43050, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Flame Turret",
		},
		["SOLIDGRINDINGSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Solid Grinding Stone",
			["icon"] = 135246,
			["id"] = {
				9920, -- [1]
				9922, -- [2]
			},
		},
		["HONEDCOBALTCLEAVER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55174, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Honed Cobalt Cleaver",
		},
		["STONEGUARDBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				58145, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Stoneguard Band",
		},
		["NETHERWEAVEPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				26771, -- [1]
			},
			["icon"] = 132149,
			["name"] = "Netherweave Pants",
		},
		["MINDBLAST"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				8092, -- [1]
				8093, -- [2]
				8102, -- [3]
				8103, -- [4]
				8104, -- [5]
				8105, -- [6]
				8106, -- [7]
				8107, -- [8]
				8108, -- [9]
				8109, -- [10]
				8110, -- [11]
				8111, -- [12]
				10945, -- [13]
				10946, -- [14]
				10947, -- [15]
				10948, -- [16]
				10949, -- [17]
				10950, -- [18]
				13860, -- [19]
				15587, -- [20]
				17194, -- [21]
				17287, -- [22]
				20830, -- [23]
				26048, -- [24]
				25372, -- [25]
				25375, -- [26]
				31516, -- [27]
				37531, -- [28]
				38259, -- [29]
				41374, -- [30]
				48126, -- [31]
				48127, -- [32]
				52722, -- [33]
				58850, -- [34]
				60447, -- [35]
				60453, -- [36]
				60500, -- [37]
				65492, -- [38]
			},
			["name"] = "Mind Blast",
			["icon"] = 136224,
			["castTime"] = 1500,
		},
		["FROSTRESISTANCEAURA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Frost Resistance Aura",
			["icon"] = 135865,
			["id"] = {
				19888, -- [1]
				19893, -- [2]
				19897, -- [3]
				19898, -- [4]
				19906, -- [5]
				19907, -- [6]
				27152, -- [7]
				48945, -- [8]
			},
		},
		["STAVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				227, -- [1]
				15989, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 135145,
			["name"] = "Staves",
		},
		["APPRENTICEMINER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Miner",
			["icon"] = 136248,
			["id"] = {
				2581, -- [1]
			},
		},
		["FREEZINGARROW"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				60192, -- [1]
				60202, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 135837,
			["name"] = "Freezing Arrow",
		},
		["DEEPFREEZE"] = {
			["maxRange"] = 36,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				44572, -- [1]
				58534, -- [2]
				60511, -- [3]
				61224, -- [4]
				71757, -- [5]
				70380, -- [6]
				70381, -- [7]
			},
			["icon"] = 236214,
			["name"] = "Deep Freeze",
		},
		["DETECTMAGIC"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				2855, -- [1]
				2858, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 135899,
			["name"] = "Detect Magic",
		},
		["SPIDERSILKDRAPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Spidersilk Drape",
			["icon"] = 132149,
			["id"] = {
				63742, -- [1]
			},
		},
		["BRILLIANTGLASS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				47280, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Brilliant Glass",
		},
		["SUMMONFELSTEED"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				1710, -- [1]
				5784, -- [2]
			},
			["name"] = "Summon Felsteed",
			["icon"] = 136103,
			["castTime"] = 0,
		},
		["EXPLOSIVESHOT"] = {
			["maxRange"] = 30,
			["minRange"] = 5,
			["id"] = {
				15495, -- [1]
				6997, -- [2]
				53301, -- [3]
				53352, -- [4]
				56298, -- [5]
				60051, -- [6]
				60052, -- [7]
				60053, -- [8]
				65866, -- [9]
				69975, -- [10]
			},
			["castTime"] = 1500,
			["icon"] = 135808,
			["name"] = "Explosive Shot",
		},
		["MASTERSINSCRIPTIONOFTHESTORM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 4000,
			["id"] = {
				61120, -- [1]
			},
			["icon"] = 237171,
			["name"] = "Master's Inscription of the Storm",
		},
		["GLOWINGTHORIUMBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Glowing Thorium Band",
			["icon"] = 134072,
			["id"] = {
				34960, -- [1]
			},
		},
		["GLOWINGSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53862, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Glowing Shadow Crystal",
		},
		["FLASKOFTHENORTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				67016, -- [1]
				67017, -- [2]
				67018, -- [3]
				67019, -- [4]
				67025, -- [5]
			},
			["icon"] = 236879,
			["name"] = "Flask of the North",
		},
		["GRILLEDSCULPIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45563, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Grilled Sculpin",
		},
		["EVOCATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				12051, -- [1]
				28403, -- [2]
				28763, -- [3]
				30254, -- [4]
				30935, -- [5]
				30972, -- [6]
				45052, -- [7]
				51602, -- [8]
				52869, -- [9]
			},
			["icon"] = 136075,
			["name"] = "Evocation",
		},
		["STING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				56628, -- [1]
				56626, -- [2]
				56627, -- [3]
				56629, -- [4]
				56630, -- [5]
				56631, -- [6]
			},
			["castTime"] = 0,
			["icon"] = 136093,
			["name"] = "Sting",
		},
		["CUREDMEDIUMHIDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Cured Medium Hide",
			["icon"] = 136247,
			["id"] = {
				3817, -- [1]
				3819, -- [2]
			},
		},
		["REDRINGOFDESTRUCTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Red Ring of Destruction",
			["icon"] = 136243,
			["id"] = {
				36525, -- [1]
			},
		},
		["BANDOFNATURALFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				26916, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Band of Natural Fire",
		},
		["TOTEMOFWRATH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				30706, -- [1]
				30708, -- [2]
				57658, -- [3]
				57660, -- [4]
				57662, -- [5]
				57663, -- [6]
				57720, -- [7]
				57721, -- [8]
				57722, -- [9]
				63283, -- [10]
			},
			["icon"] = 135829,
			["name"] = "Totem of Wrath",
		},
		["KIDNEYSHOT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				408, -- [1]
				6735, -- [2]
				8643, -- [3]
				8644, -- [4]
				27615, -- [5]
				30621, -- [6]
				30832, -- [7]
				32864, -- [8]
				41389, -- [9]
				49616, -- [10]
				72335, -- [11]
			},
			["castTime"] = 0,
			["icon"] = 132298,
			["name"] = "Kidney Shot",
		},
		["BRONZETUBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Bronze Tube",
			["icon"] = 136243,
			["id"] = {
				3938, -- [1]
				4000, -- [2]
			},
		},
		["FIREELEMENTALTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2894, -- [1]
				32982, -- [2]
			},
			["icon"] = 135790,
			["name"] = "Fire Elemental Totem",
		},
		["MUTILATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1329, -- [1]
				5374, -- [2]
				27576, -- [3]
				32319, -- [4]
				32320, -- [5]
				32321, -- [6]
				34411, -- [7]
				34412, -- [8]
				34413, -- [9]
				34414, -- [10]
				34415, -- [11]
				34416, -- [12]
				34417, -- [13]
				34418, -- [14]
				34419, -- [15]
				41103, -- [16]
				48661, -- [17]
				48662, -- [18]
				48663, -- [19]
				48664, -- [20]
				48665, -- [21]
				48666, -- [22]
				60850, -- [23]
			},
			["castTime"] = 0,
			["icon"] = 132304,
			["name"] = "Mutilate",
		},
		["NATURERESISTANCETOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				10595, -- [1]
				10597, -- [2]
				10600, -- [3]
				10601, -- [4]
				10602, -- [5]
				10603, -- [6]
				25574, -- [7]
				58746, -- [8]
				58749, -- [9]
			},
			["icon"] = 136061,
			["name"] = "Nature Resistance Totem",
		},
		["DUSKYBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Dusky Belt",
			["icon"] = 136247,
			["id"] = {
				9206, -- [1]
				9214, -- [2]
			},
		},
		["HYMNOFHOPE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				64901, -- [1]
				64904, -- [2]
			},
			["name"] = "Hymn of Hope",
			["icon"] = 135982,
			["castTime"] = 0,
		},
		["TELEPORTDALARAN"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 941,
			["id"] = {
				--3578, -- [1]
				53140, -- [2]
				54406, -- [3]
			},
			["icon"] = 135760,
			["name"] = "Teleport: Dalaran",
		},
		["ENCHANTSHIELDDEFENSE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Shield - Defense",
			["icon"] = 136244,
			["id"] = {
				44489, -- [1]
			},
		},
		["GLYPHOFSHADOWWORDPAIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55681, -- [1]
				56172, -- [2]
				57192, -- [3]
				71132, -- [4]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Shadow Word: Pain",
		},
		["SMALLLEATHERAMMOPOUCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Small Leather Ammo Pouch",
			["icon"] = 136247,
			["id"] = {
				9062, -- [1]
				9063, -- [2]
			},
		},
		["FURY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Fury",
			["icon"] = 135882,
			["id"] = {
				40601, -- [1]
				40845, -- [2]
				67671, -- [3]
			},
		},
		["THROWN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				2567, -- [1]
				15997, -- [2]
			},
			["name"] = "Thrown",
			["icon"] = 135426,
			["castTime"] = 0,
		},
		["GLYPHOFEARTHSHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Earth Shield",
			["icon"] = 136243,
			["id"] = {
				63279, -- [1]
				63925, -- [2]
				64261, -- [3]
			},
		},
		["SHADOWCRYSTALFOCUSINGLENS"] = {
			["maxRange"] = 60,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56190, -- [1]
				56206, -- [2]
			},
			["icon"] = 134071,
			["name"] = "Shadow Crystal Focusing Lens",
		},
		["CREATESOULSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				--693, -- [1]
				719, -- [2]
				20022, -- [3]
				20755, -- [4]
				20767, -- [5]
				--20752, -- [6]
				--20756, -- [7]
				--20757, -- [8]
				27238, -- [9]
				47884, -- [10]
			},
			["name"] = "Create Soulstone",
			["icon"] = 136210,
			["castTime"] = 3000,
		},
		["CURSEOFDOOM"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				603, -- [1]
				18753, -- [2]
				30910, -- [3]
				43439, -- [4]
				47867, -- [5]
				64157, -- [6]
				70144, -- [7]
				69969, -- [8]
			},
			["name"] = "Curse of Doom",
			["icon"] = 136122,
			["castTime"] = 0,
		},
		["LIGHTBLESSEDMITTENS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56022, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Light Blessed Mittens",
		},
		["MULTISHOT"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = 500,
			["id"] = {
				2643, -- [1]
				5338, -- [2]
				6999, -- [3]
				14288, -- [4]
				14289, -- [5]
				14290, -- [6]
				14359, -- [7]
				14360, -- [8]
				14443, -- [9]
				18651, -- [10]
				20735, -- [11]
				21390, -- [12]
				25294, -- [13]
				25404, -- [14]
				25967, -- [15]
				28751, -- [16]
				27021, -- [17]
				29576, -- [18]
				30990, -- [19]
				31942, -- [20]
				34879, -- [21]
				34974, -- [22]
				36979, -- [23]
				38310, -- [24]
				38383, -- [25]
				41187, -- [26]
				41448, -- [27]
				43205, -- [28]
				44285, -- [29]
				48098, -- [30]
				48872, -- [31]
				49047, -- [32]
				49048, -- [33]
				52270, -- [34]
				52813, -- [35]
				59244, -- [36]
				59515, -- [37]
				59713, -- [38]
				66081, -- [39]
				70513, -- [40]
			},
			["icon"] = 132330,
			["name"] = "Multi-Shot",
		},
		["DOUBLESTITCHEDWOOLENSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Double-stitched Woolen Shoulders",
			["icon"] = 132149,
			["id"] = {
				3848, -- [1]
				3881, -- [2]
			},
		},
		["LIGHTWELL"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				724, -- [1]
				27870, -- [2]
				27871, -- [3]
				27875, -- [4]
				27876, -- [5]
				28275, -- [6]
				48086, -- [7]
				48087, -- [8]
			},
			["name"] = "Lightwell",
			["icon"] = 135980,
			["castTime"] = 500,
		},
		["MENDPET"] = {
			["maxRange"] = 45,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				136, -- [1]
				796, -- [2]
				1117, -- [3]
				3111, -- [4]
				3661, -- [5]
				3662, -- [6]
				3663, -- [7]
				3664, -- [8]
				13542, -- [9]
				13543, -- [10]
				13544, -- [11]
				13545, -- [12]
				13546, -- [13]
				13547, -- [14]
				27046, -- [15]
				33976, -- [16]
				48989, -- [17]
				48990, -- [18]
			},
			["icon"] = 132179,
			["name"] = "Mend Pet",
		},
		["ICEBORNESHOULDERPADS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50940, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Iceborne Shoulderpads",
		},
		["FROSTWOVENBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55908, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostwoven Belt",
		},
		["SMELTSTEEL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Smelt Steel",
			["icon"] = 136243,
			["id"] = {
				3569, -- [1]
				3596, -- [2]
			},
		},
		["GREENLINENBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Green Linen Bracers",
			["icon"] = 132149,
			["id"] = {
				3841, -- [1]
				3877, -- [2]
			},
		},
		["MINDCONTROL"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["id"] = {
				605, -- [1]
				627, -- [2]
				1293, -- [3]
				10911, -- [4]
				10912, -- [5]
				10913, -- [6]
				10914, -- [7]
				11446, -- [8]
				15690, -- [9]
				36797, -- [10]
				36798, -- [11]
				43550, -- [12]
				43871, -- [13]
				43875, -- [14]
				45112, -- [15]
				67229, -- [16]
			},
			["name"] = "Mind Control",
			["icon"] = 136206,
			["castTime"] = 3000,
		},
		["FELIRONGREATSWORD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29565, -- [1]
			},
			["icon"] = 135327,
			["name"] = "Fel Iron Greatsword",
		},
		["TRACKHUMANOIDS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Track Humanoids",
			["icon"] = 132328,
			["id"] = {
				5225, -- [1]
				19883, -- [2]
				20160, -- [3]
			},
		},
		["POWERFULEARTHSIEGEDIAMOND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55399, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Powerful Earthsiege Diamond",
		},
		["SMELTTIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Smelt Tin",
			["icon"] = 136243,
			["id"] = {
				3304, -- [1]
				3313, -- [2]
			},
		},
		["SCROLLOFSTRENGTHIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Strength III",
			["icon"] = 132918,
			["id"] = {
				58486, -- [1]
			},
		},
		["DENSEGRINDINGSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Dense Grinding Stone",
			["icon"] = 135247,
			["id"] = {
				16639, -- [1]
				16668, -- [2]
			},
		},
		["TRANQUILAIRTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				25908, -- [1]
				25910, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 136013,
			["name"] = "Tranquil Air Totem",
		},
		["ELIXIROFGREATERWATERBREATHING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Greater Water Breathing",
			["icon"] = 136243,
			["id"] = {
				22808, -- [1]
				22809, -- [2]
			},
		},
		["SLAM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Slam",
			["icon"] = 132340,
			["id"] = {
				1464, -- [1]
				1482, -- [2]
				8820, -- [3]
				8821, -- [4]
				11430, -- [5]
				11604, -- [6]
				11605, -- [7]
				11606, -- [8]
				11607, -- [9]
				25241, -- [10]
				25242, -- [11]
				34620, -- [12]
				47474, -- [13]
				47475, -- [14]
				50782, -- [15]
				50783, -- [16]
				52026, -- [17]
				67028, -- [18]
			},
		},
		["EMBOSSEDLEATHERVEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Embossed Leather Vest",
			["icon"] = 136247,
			["id"] = {
				2160, -- [1]
				2883, -- [2]
			},
		},
		["RESURRECTION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				2006, -- [1]
				2010, -- [2]
				2013, -- [3]
				2016, -- [4]
				3215, -- [5]
				3216, -- [6]
				7330, -- [7]
				10880, -- [8]
				10881, -- [9]
				10882, -- [10]
				10883, -- [11]
				20770, -- [12]
				20771, -- [13]
				24173, -- [14]
				25435, -- [15]
				35599, -- [16]
				35746, -- [17]
				36450, -- [18]
				48171, -- [19]
				58854, -- [20]
			},
			["name"] = "Resurrection",
			["icon"] = 135955,
			["castTime"] = 10000,
		},
		["GRANDMASTERCOOK"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				51295, -- [1]
				65291, -- [2]
			},
			["icon"] = 133971,
			["name"] = "Grand Master Cook",
		},
		["DETECTINVISIBILITY"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				--132, -- [1]
				2970, -- [2]
				2972, -- [3]
				3692, -- [4]
				11649, -- [5]
			},
			["name"] = "Detect Invisibility",
			["icon"] = 136153,
			["castTime"] = 0,
		},
		["HEAL"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				2054, -- [1]
				964, -- [2]
				983, -- [3]
				1153, -- [4]
				2055, -- [5]
				2058, -- [6]
				2059, -- [7]
				3810, -- [8]
				6063, -- [9]
				6064, -- [10]
				6071, -- [11]
				6072, -- [12]
				8812, -- [13]
				10577, -- [14]
				11642, -- [15]
				12039, -- [16]
				14053, -- [17]
				15586, -- [18]
				22167, -- [19]
				22883, -- [20]
				24947, -- [21]
				29580, -- [22]
				30155, -- [23]
				30643, -- [24]
				31730, -- [25]
				31739, -- [26]
				31749, -- [27]
				32130, -- [28]
				33144, -- [29]
				34945, -- [30]
				35162, -- [31]
				36144, -- [32]
				36678, -- [33]
				36983, -- [34]
				37569, -- [35]
				38209, -- [36]
				39013, -- [37]
				39378, -- [38]
				39868, -- [39]
				40972, -- [40]
				41372, -- [41]
				41386, -- [42]
				47668, -- [43]
				59195, -- [44]
				61326, -- [45]
				62352, -- [46]
			},
			["name"] = "Heal",
			["icon"] = 135915,
			["castTime"] = 3000,
		},
		["MOONSHROUDROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56024, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Moonshroud Robe",
		},
		["MIRRORIMAGE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				36847, -- [1]
				36848, -- [2]
				40943, -- [3]
				40944, -- [4]
				55342, -- [5]
				58831, -- [6]
				58832, -- [7]
				58833, -- [8]
				58834, -- [9]
				60352, -- [10]
				65047, -- [11]
				69936, -- [12]
				69939, -- [13]
				69940, -- [14]
				69941, -- [15]
				69960, -- [16]
			},
			["icon"] = 135757,
			["name"] = "Mirror Image",
		},
		["SMALLPRISMATICSHARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				42615, -- [1]
			},
			["icon"] = 132882,
			["name"] = "Small Prismatic Shard",
		},
		["HOLYNOVA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				15237, -- [1]
				3046, -- [2]
				15430, -- [3]
				15431, -- [4]
				15434, -- [5]
				20694, -- [6]
				23455, -- [7]
				23458, -- [8]
				23459, -- [9]
				23858, -- [10]
				27799, -- [11]
				27800, -- [12]
				27801, -- [13]
				27803, -- [14]
				27804, -- [15]
				27805, -- [16]
				27821, -- [17]
				27822, -- [18]
				27823, -- [19]
				25329, -- [20]
				25331, -- [21]
				29514, -- [22]
				34944, -- [23]
				35740, -- [24]
				36985, -- [25]
				37669, -- [26]
				38589, -- [27]
				40096, -- [28]
				41380, -- [29]
				46564, -- [30]
				48075, -- [31]
				48076, -- [32]
				48077, -- [33]
				48078, -- [34]
				57771, -- [35]
				59701, -- [36]
				66546, -- [37]
			},
			["name"] = "Holy Nova",
			["icon"] = 135922,
			["castTime"] = 0,
		},
		["RUNEOFTHESTONESKINGARGOYLE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				62158, -- [1]
			},
			["icon"] = 237480,
			["name"] = "Rune of the Stoneskin Gargoyle",
		},
		["DISARM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Disarm",
			["icon"] = 132343,
			["id"] = {
				676, -- [1]
				1646, -- [2]
				6713, -- [3]
				8379, -- [4]
				11879, -- [5]
				13534, -- [6]
				15752, -- [7]
				22691, -- [8]
				27581, -- [9]
				1843, -- [10]
				30013, -- [11]
				31955, -- [12]
				36139, -- [13]
				41062, -- [14]
				48883, -- [15]
				65935, -- [16]
			},
		},
		["FRAGBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				54793, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Frag Belt",
		},
		["GREATERHEALINGPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Greater Healing Potion",
			["icon"] = 136243,
			["id"] = {
				7181, -- [1]
				7182, -- [2]
			},
		},
		["SCALEDICEWALKERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60630, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Scaled Icewalkers",
		},
		["HEALINGWAVE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				331, -- [1]
				332, -- [2]
				538, -- [3]
				547, -- [4]
				565, -- [5]
				913, -- [6]
				914, -- [7]
				939, -- [8]
				959, -- [9]
				1326, -- [10]
				1327, -- [11]
				1354, -- [12]
				1355, -- [13]
				1356, -- [14]
				8005, -- [15]
				8006, -- [16]
				10395, -- [17]
				10396, -- [18]
				10397, -- [19]
				10398, -- [20]
				11986, -- [21]
				12491, -- [22]
				12492, -- [23]
				15982, -- [24]
				25357, -- [25]
				25402, -- [26]
				25964, -- [27]
				26097, -- [28]
				25391, -- [29]
				25396, -- [30]
				38330, -- [31]
				43548, -- [32]
				48700, -- [33]
				49272, -- [34]
				49273, -- [35]
				51586, -- [36]
				52868, -- [37]
				55597, -- [38]
				57785, -- [39]
				58980, -- [40]
				59083, -- [41]
				60012, -- [42]
				61569, -- [43]
				67528, -- [44]
				75382, -- [45]
				69958, -- [46]
			},
			["icon"] = 136052,
			["name"] = "Healing Wave",
		},
		["BEASTLORE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1462, -- [1]
				6792, -- [2]
			},
			["icon"] = 132270,
			["name"] = "Beast Lore",
		},
		["MASTERSKINNER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				32679, -- [1]
			},
			["icon"] = 134366,
			["name"] = "Master Skinner",
		},
		["COPPERMODULATOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Copper Modulator",
			["icon"] = 136243,
			["id"] = {
				3926, -- [1]
				3991, -- [2]
			},
		},
		["AUTOATTACK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				6603, -- [1]
			},
			["icon"] = 135703,
			["name"] = "Auto Attack",
		},
		["LESSERWIZARDSROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Lesser Wizard's Robe",
			["icon"] = 132149,
			["id"] = {
				6690, -- [1]
				6691, -- [2]
			},
		},
		["CONJUREMANAGEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				--759, -- [1]
				3724, -- [2]
				--1210, -- [3]
				--3552, -- [4]
				--3553, -- [5]
				--10053, -- [6]
				--10054, -- [7]
				--10055, -- [8]
				--10056, -- [9]
				27101, -- [10]
				27390, -- [11]
				42985, -- [12]
				42986, -- [13]
			},
			["icon"] = 134104,
			["name"] = "Conjure Mana Gem",
		},
		["MASTERENGINEER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				30351, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Master Engineer",
		},
		["TRACKHIDDEN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				19885, -- [1]
				20159, -- [2]
			},
			["icon"] = 132320,
			["name"] = "Track Hidden",
		},
		["ENCHANTBOOTSGREATERFORTITUDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Boots - Greater Fortitude",
			["icon"] = 136244,
			["id"] = {
				44528, -- [1]
			},
		},
		["SPELLREFLECTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Spell Reflection",
			["icon"] = 136222,
			["id"] = {
				9941, -- [1]
				9943, -- [2]
				10074, -- [3]
				11818, -- [4]
				21118, -- [5]
				23920, -- [6]
				31533, -- [7]
				31534, -- [8]
				31554, -- [9]
				33961, -- [10]
				34783, -- [11]
				35399, -- [12]
				36096, -- [13]
				37885, -- [14]
				38331, -- [15]
				38592, -- [16]
				38599, -- [17]
				43443, -- [18]
				47981, -- [19]
				57643, -- [20]
				59725, -- [21]
			},
		},
		["ROUGHBRONZEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Rough Bronze Boots",
			["icon"] = 132535,
			["id"] = {
				7817, -- [1]
				7819, -- [2]
			},
		},
		["PICKLEDFANGTOOTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				45566, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Pickled Fangtooth",
		},
		["GRANDMASTERENGINEER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				51305, -- [1]
				61464, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Grand Master Engineer",
		},
		["OVERPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Overpower",
			["icon"] = 132223,
			["id"] = {
				7384, -- [1]
				7385, -- [2]
				7887, -- [3]
				7889, -- [4]
				11584, -- [5]
				11585, -- [6]
				11586, -- [7]
				11587, -- [8]
				14895, -- [9]
				17198, -- [10]
				24407, -- [11]
				32154, -- [12]
				37321, -- [13]
				37529, -- [14]
				43456, -- [15]
				58516, -- [16]
				65924, -- [17]
			},
		},
		["FORCEFULDEFLECTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				49410, -- [1]
			},
			["icon"] = 132269,
			["name"] = "Forceful Deflection",
		},
		["ENCHANTGLOVESGREATERAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				20012, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Gloves - Greater Agility",
		},
		["NETHERWEAVENET"] = {
			["maxRange"] = 25,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				31367, -- [1]
				31460, -- [2]
			},
			["icon"] = 134325,
			["name"] = "Netherweave Net",
		},
		["MANABURN"] = {
			["maxRange"] = 10,
			["minRange"] = 0,
			["id"] = {
				2691, -- [1]
				4091, -- [2]
				8129, -- [3]
				8130, -- [4]
				8131, -- [5]
				8132, -- [6]
				10874, -- [7]
				10875, -- [8]
				10876, -- [9]
				10877, -- [10]
				10878, -- [11]
				10879, -- [12]
				11981, -- [13]
				12745, -- [14]
				13321, -- [15]
				14033, -- [16]
				15785, -- [17]
				15800, -- [18]
				15980, -- [19]
				17615, -- [20]
				17630, -- [21]
				20817, -- [22]
				22189, -- [23]
				22936, -- [24]
				22947, -- [25]
				25779, -- [26]
				26046, -- [27]
				26049, -- [28]
				27992, -- [29]
				28301, -- [30]
				29310, -- [31]
				29405, -- [32]
				31729, -- [33]
				33385, -- [34]
				34930, -- [35]
				34931, -- [36]
				36484, -- [37]
				37159, -- [38]
				37176, -- [39]
				38883, -- [40]
				38884, -- [41]
				39020, -- [42]
				39136, -- [43]
				39262, -- [44]
				39675, -- [45]
				48054, -- [46]
				54338, -- [47]
				55010, -- [48]
				57047, -- [49]
				66100, -- [50]
			},
			["name"] = "Mana Burn",
			["icon"] = 136170,
			["castTime"] = 0,
		},
		["FEEDINGFRENZY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53512, -- [1]
				53511, -- [2]
				60096, -- [3]
				60097, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 133934,
			["name"] = "Feeding Frenzy",
		},
		["IMMOLATE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1882,
			["id"] = {
				348, -- [1]
				707, -- [2]
				734, -- [3]
				1094, -- [4]
				1095, -- [5]
				1374, -- [6]
				1375, -- [7]
				1376, -- [8]
				2941, -- [9]
				2942, -- [10]
				3686, -- [11]
				8981, -- [12]
				9034, -- [13]
				9275, -- [14]
				9276, -- [15]
				11665, -- [16]
				11666, -- [17]
				11667, -- [18]
				11668, -- [19]
				11669, -- [20]
				11670, -- [21]
				11962, -- [22]
				11984, -- [23]
				12742, -- [24]
				15505, -- [25]
				15506, -- [26]
				15570, -- [27]
				15661, -- [28]
				15732, -- [29]
				15733, -- [30]
				17883, -- [31]
				18542, -- [32]
				20294, -- [33]
				20787, -- [34]
				20800, -- [35]
				20826, -- [36]
				25309, -- [37]
				25418, -- [38]
				25981, -- [39]
				27215, -- [40]
				29928, -- [41]
				36637, -- [42]
				36638, -- [43]
				37668, -- [44]
				38805, -- [45]
				38806, -- [46]
				41958, -- [47]
				44267, -- [48]
				44518, -- [49]
				46042, -- [50]
				46191, -- [51]
				47810, -- [52]
				47811, -- [53]
				75383, -- [54]
			},
			["icon"] = 135817,
			["name"] = "Immolate",
		},
		["ICEBORNELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50939, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Iceborne Leggings",
		},
		["ENCHANTGLOVESSTRENGTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13887, -- [1]
				13888, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Gloves - Strength",
		},
		["GLYPHOFGARROTE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Garrote",
			["icon"] = 136243,
			["id"] = {
				56812, -- [1]
				57123, -- [2]
				57150, -- [3]
			},
		},
		["TRUESILVERROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Truesilver Rod",
			["icon"] = 135148,
			["id"] = {
				14380, -- [1]
				14382, -- [2]
			},
		},
		["SMELTING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2656, -- [1]
				61422, -- [2]
			},
			["icon"] = 135811,
			["name"] = "Smelting",
		},
		["GRANDMASTERFIRSTAID"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				50299, -- [1]
				65292, -- [2]
			},
			["icon"] = 135966,
			["name"] = "Grand Master First Aid",
		},
		["GLYPHOFFLAMETONGUEWEAPON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Flametongue Weapon",
			["icon"] = 136243,
			["id"] = {
				55451, -- [1]
				55546, -- [2]
				57240, -- [3]
			},
		},
		["FIREWARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				543, -- [1]
				874, -- [2]
				1035, -- [3]
				8457, -- [4]
				8458, -- [5]
				8459, -- [6]
				8460, -- [7]
				10223, -- [8]
				10224, -- [9]
				10225, -- [10]
				10226, -- [11]
				15041, -- [12]
				27128, -- [13]
				27395, -- [14]
				37844, -- [15]
				43010, -- [16]
			},
			["icon"] = 135806,
			["name"] = "Fire Ward",
		},
		["SCROLLOFINTELLECTIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Intellect III",
			["icon"] = 132918,
			["id"] = {
				50599, -- [1]
			},
		},
		["ENCHANTCHESTGREATERMANARESTORATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Chest - Greater Mana Restoration",
			["icon"] = 136244,
			["id"] = {
				44509, -- [1]
			},
		},
		["ENCHANTCHESTEXCEPTIONALHEALTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				27957, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Exceptional Health",
		},
		["SILVERCONTACT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Silver Contact",
			["icon"] = 136243,
			["id"] = {
				3973, -- [1]
				3990, -- [2]
			},
		},
		["INLAIDMALACHITERING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Inlaid Malachite Ring",
			["icon"] = 136243,
			["id"] = {
				25283, -- [1]
			},
		},
		["GLYPHOFPOLYMORPH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56375, -- [1]
				56600, -- [2]
				56987, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Polymorph",
		},
		["DARKGLOWEMBROIDERY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55768, -- [1]
				55769, -- [2]
			},
			["icon"] = 136037,
			["name"] = "Darkglow Embroidery",
		},
		["STORMFORGEDHAUBERK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36130, -- [1]
			},
			["icon"] = 132639,
			["name"] = "Stormforged Hauberk",
		},
		["DARKICEBORNELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60611, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Dark Iceborne Leggings",
		},
		["HEAVYCOPPERRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Heavy Copper Ring",
			["icon"] = 136243,
			["id"] = {
				26926, -- [1]
			},
		},
		["BULWARKOFKINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34534, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Bulwark of Kings",
		},
		["SCAREBEAST"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				1513, -- [1]
				1567, -- [2]
				14326, -- [3]
				14327, -- [4]
				14445, -- [5]
				14446, -- [6]
			},
			["icon"] = 132118,
			["name"] = "Scare Beast",
		},
		["ASPECTOFTHEWILD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				20043, -- [1]
				20044, -- [2]
				20190, -- [3]
				20191, -- [4]
				27045, -- [5]
				49071, -- [6]
			},
			["icon"] = 136074,
			["name"] = "Aspect of the Wild",
		},
		["SHADOWRESISTANCEAURA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Shadow Resistance Aura",
			["icon"] = 136192,
			["id"] = {
				19876, -- [1]
				19892, -- [2]
				19895, -- [3]
				19896, -- [4]
				19904, -- [5]
				19905, -- [6]
				27151, -- [7]
				48943, -- [8]
			},
		},
		["TEMPEREDSARONITEGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55015, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Tempered Saronite Gauntlets",
		},
		["TORMENT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				11775, -- [1]
				3716, -- [2]
				7809, -- [3]
				7810, -- [4]
				7811, -- [5]
				7881, -- [6]
				7882, -- [7]
				7883, -- [8]
				7884, -- [9]
				11774, -- [10]
				11776, -- [11]
				11777, -- [12]
				20317, -- [13]
				20377, -- [14]
				20378, -- [15]
				20379, -- [16]
				20380, -- [17]
				27270, -- [18]
				27490, -- [19]
				47984, -- [20]
				48000, -- [21]
				54526, -- [22]
			},
			["castTime"] = 0,
			["icon"] = 136160,
			["name"] = "Torment",
		},
		["GLYPHOFDISPELMAGIC"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Dispel Magic",
			["icon"] = 136243,
			["id"] = {
				55677, -- [1]
				56131, -- [2]
				56163, -- [3]
				57183, -- [4]
			},
		},
		["GLINTINGHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53878, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Glinting Huge Citrine",
		},
		["GYROCHRONATOM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Gyrochronatom",
			["icon"] = 136243,
			["id"] = {
				3961, -- [1]
				4017, -- [2]
			},
		},
		["GLYPHOFSTARFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Starfire",
			["icon"] = 136243,
			["id"] = {
				54845, -- [1]
				54846, -- [2]
				54871, -- [3]
				56959, -- [4]
			},
		},
		["ELIXIROFFORTITUDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Elixir of Fortitude",
			["icon"] = 136243,
			["id"] = {
				3450, -- [1]
				3178, -- [2]
				3593, -- [3]
			},
		},
		["DARKFLAMEINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				57714, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Darkflame Ink",
		},
		["ENCHANTGLOVESEXPERTISE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Gloves - Expertise",
			["icon"] = 136244,
			["id"] = {
				44484, -- [1]
			},
		},
		["HEAVYLEATHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Heavy Leather",
			["icon"] = 136243,
			["id"] = {
				20649, -- [1]
				20652, -- [2]
			},
		},
		["SAVAGESARONITEWAISTGUARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55307, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Savage Saronite Waistguard",
		},
		["SPIKEDTITANSTEELHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55372, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Spiked Titansteel Helm",
		},
		["ROUGHBRONZELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Rough Bronze Leggings",
			["icon"] = 134583,
			["id"] = {
				2668, -- [1]
				2749, -- [2]
			},
		},
		["CONSECRATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Consecration",
			["icon"] = 135926,
			["id"] = {
				20116, -- [1]
				20922, -- [2]
				20923, -- [3]
				20924, -- [4]
				20952, -- [5]
				20953, -- [6]
				20954, -- [7]
				26573, -- [8]
				26574, -- [9]
				27173, -- [10]
				32773, -- [11]
				33559, -- [12]
				36946, -- [13]
				37553, -- [14]
				38385, -- [15]
				41541, -- [16]
				43429, -- [17]
				48818, -- [18]
				48819, -- [19]
				57798, -- [20]
				59998, -- [21]
				69930, -- [22]
			},
		},
		["HANDSTITCHEDLEATHERPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Handstitched Leather Pants",
			["icon"] = 136247,
			["id"] = {
				2153, -- [1]
				2338, -- [2]
			},
		},
		["ENCHANTGLOVESPRECISION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Gloves - Precision",
			["icon"] = 135913,
			["id"] = {
				44488, -- [1]
			},
		},
		["ANCESTRALSPIRIT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				2008, -- [1]
				2014, -- [2]
				20609, -- [3]
				20610, -- [4]
				20776, -- [5]
				20777, -- [6]
				20778, -- [7]
				20779, -- [8]
				20780, -- [9]
				20781, -- [10]
				25590, -- [11]
				45608, -- [12]
				49277, -- [13]
			},
			["icon"] = 136077,
			["name"] = "Ancestral Spirit",
		},
		["APPRENTICETAILOR"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Tailor",
			["icon"] = 136249,
			["id"] = {
				3911, -- [1]
			},
		},
		["ENCHANTCHESTMIGHTYHEALTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Chest - Mighty Health",
			["icon"] = 136244,
			["id"] = {
				44492, -- [1]
			},
		},
		["DUSKWEAVEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55924, -- [1]
				56048, -- [2]
			},
			["icon"] = 136249,
			["name"] = "Duskweave Boots",
		},
		["SPELLWEAVEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56029, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Spellweave Gloves",
		},
		["SMACK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				52476, -- [1]
				49966, -- [2]
				49967, -- [3]
				49968, -- [4]
				49969, -- [5]
				49970, -- [6]
				49971, -- [7]
				49972, -- [8]
				49973, -- [9]
				49974, -- [10]
				52475, -- [11]
			},
			["castTime"] = 0,
			["icon"] = 132114,
			["name"] = "Smack",
		},
		["ENCHANTCHESTLESSERHEALTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7748, -- [1]
				7749, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Lesser Health",
		},
		["HANDOFRECKONING"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Hand of Reckoning",
			["icon"] = 135984,
			["id"] = {
				62124, -- [1]
				67485, -- [2]
			},
		},
		["THORNS"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Thorns",
			["icon"] = 136104,
			["id"] = {
				467, -- [1]
				782, -- [2]
				786, -- [3]
				795, -- [4]
				1075, -- [5]
				1076, -- [6]
				1420, -- [7]
				1421, -- [8]
				1422, -- [9]
				8914, -- [10]
				8915, -- [11]
				9756, -- [12]
				9757, -- [13]
				9910, -- [14]
				10343, -- [15]
				15438, -- [16]
				16877, -- [17]
				21335, -- [18]
				21337, -- [19]
				22128, -- [20]
				22351, -- [21]
				22696, -- [22]
				25640, -- [23]
				25777, -- [24]
				26992, -- [25]
				31271, -- [26]
				33907, -- [27]
				34343, -- [28]
				34663, -- [29]
				35361, -- [30]
				43420, -- [31]
				53307, -- [32]
				66068, -- [33]
			},
		},
		["SPIKEDCOBALTGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54945, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Spiked Cobalt Gauntlets",
		},
		["AMPLIFYMAGIC"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1008, -- [1]
				1267, -- [2]
				8455, -- [3]
				8456, -- [4]
				10169, -- [5]
				10170, -- [6]
				10171, -- [7]
				10172, -- [8]
				27130, -- [9]
				27397, -- [10]
				33946, -- [11]
				33947, -- [12]
				43017, -- [13]
				51054, -- [14]
				59371, -- [15]
				70408, -- [16]
			},
			["icon"] = 135907,
			["name"] = "Amplify Magic",
		},
		["EXECUTE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Execute",
			["icon"] = 135358,
			["id"] = {
				5308, -- [1]
				5283, -- [2]
				6176, -- [3]
				6177, -- [4]
				7160, -- [5]
				20647, -- [6]
				20658, -- [7]
				20660, -- [8]
				20661, -- [9]
				20662, -- [10]
				20703, -- [11]
				20704, -- [12]
				26651, -- [13]
				25234, -- [14]
				25236, -- [15]
				38959, -- [16]
				47470, -- [17]
				47471, -- [18]
				56426, -- [19]
				61140, -- [20]
			},
		},
		["JORMUNGARLEGARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3763,
			["id"] = {
				50901, -- [1]
				50964, -- [2]
			},
			["icon"] = 136247,
			["name"] = "Jormungar Leg Armor",
		},
		["SCROLLOFSPIRITIV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Spirit IV",
			["icon"] = 132918,
			["id"] = {
				50607, -- [1]
			},
		},
		["DREAMSIGNET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56197, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Dream Signet",
		},
		["DEVASTATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Devastate",
			["icon"] = 135291,
			["id"] = {
				20243, -- [1]
				30016, -- [2]
				30017, -- [3]
				30022, -- [4]
				36891, -- [5]
				36894, -- [6]
				38849, -- [7]
				38967, -- [8]
				44452, -- [9]
				47497, -- [10]
				47498, -- [11]
				57795, -- [12]
				60018, -- [13]
				62317, -- [14]
				69902, -- [15]
			},
		},
		["TOUGHENEDLEATHERGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Toughened Leather Gloves",
			["icon"] = 136247,
			["id"] = {
				3770, -- [1]
				3794, -- [2]
			},
		},
		["GLINTINGFLAMESPESSARITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28914, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Glinting Flame Spessarite",
		},
		["FROSTARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				168, -- [1]
				484, -- [2]
				1174, -- [3]
				1200, -- [4]
				6116, -- [5]
				6643, -- [6]
				7300, -- [7]
				7301, -- [8]
				12544, -- [9]
				12556, -- [10]
				15784, -- [11]
				18100, -- [12]
				31256, -- [13]
			},
			["icon"] = 135843,
			["name"] = "Frost Armor",
		},
		["ENRAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Enrage",
			["icon"] = 132126,
			["id"] = {
				5229, -- [1]
				1640, -- [2]
				3019, -- [3]
				5228, -- [4]
				8269, -- [5]
				8599, -- [6]
				12317, -- [7]
				12686, -- [8]
				12795, -- [9]
				12880, -- [10]
				13045, -- [11]
				13046, -- [12]
				13047, -- [13]
				13048, -- [14]
				14201, -- [15]
				14202, -- [16]
				14203, -- [17]
				14204, -- [18]
				15061, -- [19]
				15097, -- [20]
				15716, -- [21]
				18501, -- [22]
				19516, -- [23]
				19953, -- [24]
				23537, -- [25]
				24318, -- [26]
				25503, -- [27]
				26527, -- [28]
				27897, -- [29]
				28131, -- [30]
				28468, -- [31]
				28747, -- [32]
				28798, -- [33]
				19451, -- [34]
				19812, -- [35]
				22428, -- [36]
				23128, -- [37]
				23342, -- [38]
				26041, -- [39]
				26051, -- [40]
				28371, -- [41]
				30485, -- [42]
				31540, -- [43]
				31915, -- [44]
				32714, -- [45]
				33958, -- [46]
				34670, -- [47]
				37605, -- [48]
				37648, -- [49]
				37975, -- [50]
				38046, -- [51]
				38166, -- [52]
				38664, -- [53]
				39031, -- [54]
				41254, -- [55]
				41447, -- [56]
				42705, -- [57]
				42745, -- [58]
				43139, -- [59]
				44427, -- [60]
				45111, -- [61]
				47399, -- [62]
				48138, -- [63]
				48142, -- [64]
				48193, -- [65]
				50420, -- [66]
				51513, -- [67]
				52470, -- [68]
				54287, -- [69]
				54427, -- [70]
				55285, -- [71]
				56646, -- [72]
				57514, -- [73]
				57516, -- [74]
				57518, -- [75]
				57519, -- [76]
				57520, -- [77]
				57521, -- [78]
				57522, -- [79]
				59697, -- [80]
				59707, -- [81]
				59828, -- [82]
				60075, -- [83]
				61369, -- [84]
				63227, -- [85]
				72143, -- [86]
				70371, -- [87]
				68335, -- [88]
				78722, -- [89]
			},
		},
		["POWERWORDSHIELD"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				17, -- [1]
				592, -- [2]
				600, -- [3]
				1277, -- [4]
				1278, -- [5]
				1298, -- [6]
				2851, -- [7]
				3747, -- [8]
				6065, -- [9]
				6066, -- [10]
				6067, -- [11]
				6068, -- [12]
				10898, -- [13]
				10899, -- [14]
				10900, -- [15]
				10901, -- [16]
				10902, -- [17]
				10903, -- [18]
				10904, -- [19]
				10905, -- [20]
				11647, -- [21]
				11835, -- [22]
				11974, -- [23]
				17139, -- [24]
				20697, -- [25]
				22187, -- [26]
				27607, -- [27]
				25217, -- [28]
				25218, -- [29]
				29408, -- [30]
				32595, -- [31]
				35944, -- [32]
				36052, -- [33]
				41373, -- [34]
				44175, -- [35]
				44291, -- [36]
				46193, -- [37]
				48065, -- [38]
				48066, -- [39]
				66099, -- [40]
				71780, -- [41]
				71548, -- [42]
			},
			["icon"] = 135940,
			["name"] = "Power Word: Shield",
		},
		["ENCHANTGLOVESGREATERASSAULT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Gloves - Greater Assault",
			["icon"] = 136244,
			["id"] = {
				44513, -- [1]
			},
		},
		["APPRENTICEENCHANTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				7414, -- [1]
			},
			["icon"] = 136244,
			["name"] = "Apprentice Enchanter",
		},
		["ENCHANTRINGASSAULT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Ring - Assault",
			["icon"] = 136244,
			["id"] = {
				44645, -- [1]
			},
		},
		["FROSTWOVENCOWL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55907, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostwoven Cowl",
		},
		["BLADEDPICKAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56461, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Bladed Pickaxe",
		},
		["FLASHINGBLOODSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53844, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Flashing Bloodstone",
		},
		["EMBRACEOFTHETWISTINGNETHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				36256, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Embrace of the Twisting Nether",
		},
		["DEATHGATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				50977, -- [1]
				52751, -- [2]
				53822, -- [3]
				57890, -- [4]
				57892, -- [5]
				57910, -- [6]
				57911, -- [7]
				57916, -- [8]
				57917, -- [9]
			},
			["icon"] = 135766,
			["name"] = "Death Gate",
		},
		["DEVOTIONAURA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Devotion Aura",
			["icon"] = 135893,
			["id"] = {
				465, -- [1]
				643, -- [2]
				1032, -- [3]
				1875, -- [4]
				1876, -- [5]
				1877, -- [6]
				8258, -- [7]
				10290, -- [8]
				10291, -- [9]
				10292, -- [10]
				10293, -- [11]
				10294, -- [12]
				10295, -- [13]
				10296, -- [14]
				10297, -- [15]
				17232, -- [16]
				27149, -- [17]
				41452, -- [18]
				48941, -- [19]
				48942, -- [20]
				52442, -- [21]
				57740, -- [22]
				58944, -- [23]
			},
		},
		["GLYPHOFICYVEINS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Icy Veins",
			["icon"] = 136243,
			["id"] = {
				56374, -- [1]
				56594, -- [2]
				56981, -- [3]
			},
		},
		["RINGOFTWILIGHTSHADOWS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Ring of Twilight Shadows",
			["icon"] = 136243,
			["id"] = {
				25318, -- [1]
			},
		},
		["GLYPHOFSPIRITUALATTUNEMENT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Spiritual Attunement",
			["icon"] = 136243,
			["id"] = {
				54924, -- [1]
				55111, -- [2]
				57022, -- [3]
			},
		},
		["SOVEREIGNSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53859, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Sovereign Shadow Crystal",
		},
		["ENCHANTBRACERSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13648, -- [1]
				13649, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Stamina",
		},
		["ONEHANDEDMACES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "One-Handed Maces",
			["icon"] = 133476,
			["id"] = {
				198, -- [1]
				15986, -- [2]
			},
		},
		["MITHRILSCALEPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Mithril Scale Pants",
			["icon"] = 134583,
			["id"] = {
				9931, -- [1]
				9932, -- [2]
			},
		},
		["LEVITATE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				1706, -- [1]
				3745, -- [2]
				6492, -- [3]
				27986, -- [4]
				31704, -- [5]
				50195, -- [6]
				52970, -- [7]
				59200, -- [8]
			},
			["name"] = "Levitate",
			["icon"] = 135928,
			["castTime"] = 0,
		},
		["ENCHANTCLOAKGREATERDEFENSE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13746, -- [1]
				13749, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Greater Defense",
		},
		["THORIUMARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Thorium Armor",
			["icon"] = 132743,
			["id"] = {
				16642, -- [1]
			},
		},
		["ENCHANTCLOAKMINORPROTECTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7771, -- [1]
				7461, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Minor Protection",
		},
		["TRUESILVERBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				9974, -- [1]
				9978, -- [2]
			},
			["icon"] = 132739,
			["name"] = "Truesilver Breastplate",
		},
		["DETECTTRAPS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				2836, -- [1]
				1846, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132319,
			["name"] = "Detect Traps",
		},
		["BOWS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				264, -- [1]
				15994, -- [2]
			},
			["name"] = "Bows",
			["icon"] = 135493,
			["castTime"] = 0,
		},
		["NIGHTSHOCKGIRDLE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60658, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Nightshock Girdle",
		},
		["ENCHANTCLOAKFIRERESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13657, -- [1]
				13658, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Fire Resistance",
		},
		["TRACKBEASTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1494, -- [1]
				1547, -- [2]
			},
			["icon"] = 132328,
			["name"] = "Track Beasts",
		},
		["ENCHANTSHIELDVITALITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				20016, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Shield - Vitality",
		},
		["ENCHANTBOOTSASSAULT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Boots - Assault",
			["icon"] = 136244,
			["id"] = {
				60606, -- [1]
			},
		},
		["THORIUMHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Thorium Helm",
			["icon"] = 133125,
			["id"] = {
				16653, -- [1]
			},
		},
		["GOLDENRINGOFPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Golden Ring of Power",
			["icon"] = 134072,
			["id"] = {
				34955, -- [1]
			},
		},
		["MOCKINGBLOW"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Mocking Blow",
			["icon"] = 132350,
			["id"] = {
				694, -- [1]
				7382, -- [2]
				7400, -- [3]
				7401, -- [4]
				7402, -- [5]
				7403, -- [6]
				20559, -- [7]
				20560, -- [8]
				20561, -- [9]
				20562, -- [10]
				21008, -- [11]
				25266, -- [12]
				47504, -- [13]
			},
		},
		["FROSTSCALEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50953, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Frostscale Gloves",
		},
		["TEMPEREDSARONITEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55017, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Tempered Saronite Bracers",
		},
		["THORIUMGRENADE"] = {
			["maxRange"] = 45,
			["minRange"] = 0,
			["castTime"] = 941,
			["name"] = "Thorium Grenade",
			["icon"] = 135826,
			["id"] = {
				19769, -- [1]
				19790, -- [2]
			},
		},
		["REINFORCEDLINENCAPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Reinforced Linen Cape",
			["icon"] = 132149,
			["id"] = {
				2397, -- [1]
				2419, -- [2]
			},
		},
		["SCROLLOFSTRENGTHV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Strength V",
			["icon"] = 132918,
			["id"] = {
				58488, -- [1]
			},
		},
		["CALLOFTHESPIRITS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				66844, -- [1]
			},
			["icon"] = 310732,
			["name"] = "Call of the Spirits",
		},
		["EXPERTRIDING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				34090, -- [1]
				34092, -- [2]
			},
			["icon"] = 136103,
			["name"] = "Expert Riding",
		},
		["BERSERKERRAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Berserker Rage",
			["icon"] = 136009,
			["id"] = {
				18499, -- [1]
				18556, -- [2]
			},
		},
		["GLYPHOFIMMOLATIONTRAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Immolation Trap",
			["icon"] = 136243,
			["id"] = {
				56846, -- [1]
				56880, -- [2]
				57005, -- [3]
			},
		},
		["FROSTBOLT"] = {
			["maxRange"] = 36,
			["minRange"] = 0,
			["castTime"] = 753,
			["id"] = {
				116, -- [1]
				205, -- [2]
				478, -- [3]
				494, -- [4]
				837, -- [5]
				838, -- [6]
				1142, -- [7]
				1191, -- [8]
				1211, -- [9]
				7322, -- [10]
				7323, -- [11]
				7324, -- [12]
				8406, -- [13]
				8407, -- [14]
				8408, -- [15]
				8409, -- [16]
				8410, -- [17]
				8411, -- [18]
				9672, -- [19]
				10179, -- [20]
				10180, -- [21]
				10181, -- [22]
				10182, -- [23]
				10183, -- [24]
				10184, -- [25]
				11538, -- [26]
				12675, -- [27]
				12737, -- [28]
				13322, -- [29]
				13439, -- [30]
				15043, -- [31]
				15497, -- [32]
				15530, -- [33]
				16249, -- [34]
				16799, -- [35]
				17503, -- [36]
				20297, -- [37]
				20792, -- [38]
				20806, -- [39]
				20819, -- [40]
				20822, -- [41]
				21369, -- [42]
				23102, -- [43]
				23412, -- [44]
				24942, -- [45]
				25304, -- [46]
				25414, -- [47]
				25940, -- [48]
				25977, -- [49]
				28478, -- [50]
				28479, -- [51]
				27071, -- [52]
				27072, -- [53]
				29457, -- [54]
				29926, -- [55]
				29954, -- [56]
				30942, -- [57]
				31296, -- [58]
				31622, -- [59]
				32364, -- [60]
				32370, -- [61]
				32984, -- [62]
				34347, -- [63]
				35316, -- [64]
				36279, -- [65]
				36710, -- [66]
				36990, -- [67]
				37930, -- [68]
				38238, -- [69]
				38534, -- [70]
				38645, -- [71]
				38697, -- [72]
				38826, -- [73]
				39064, -- [74]
				40429, -- [75]
				40430, -- [76]
				41384, -- [77]
				41486, -- [78]
				42719, -- [79]
				42803, -- [80]
				42841, -- [81]
				42842, -- [82]
				43083, -- [83]
				43428, -- [84]
				44606, -- [85]
				44843, -- [86]
				46035, -- [87]
				46987, -- [88]
				49037, -- [89]
				50378, -- [90]
				50721, -- [91]
				54791, -- [92]
				55802, -- [93]
				55807, -- [94]
				56775, -- [95]
				56837, -- [96]
				57665, -- [97]
				57825, -- [98]
				58457, -- [99]
				58535, -- [100]
				59017, -- [101]
				59251, -- [102]
				59280, -- [103]
				59638, -- [104]
				59855, -- [105]
				61087, -- [106]
				61461, -- [107]
				61590, -- [108]
				61730, -- [109]
				61747, -- [110]
				62583, -- [111]
				62601, -- [112]
				63913, -- [113]
				69573, -- [114]
				72166, -- [115]
				71318, -- [116]
				69274, -- [117]
				70327, -- [118]
				71420, -- [119]
				65807, -- [120]
			},
			["icon"] = 135846,
			["name"] = "Frostbolt",
		},
		["WINDFURYWEAPON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8232, -- [1]
				8233, -- [2]
				8234, -- [3]
				8235, -- [4]
				8236, -- [5]
				8237, -- [6]
				10484, -- [7]
				10486, -- [8]
				10488, -- [9]
				16361, -- [10]
				16362, -- [11]
				16363, -- [12]
				25505, -- [13]
				32911, -- [14]
				35886, -- [15]
				58801, -- [16]
				58803, -- [17]
				58804, -- [18]
			},
			["icon"] = 136018,
			["name"] = "Windfury Weapon",
		},
		["CATFORM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Cat Form",
			["icon"] = 132115,
			["id"] = {
				768, -- [1]
				499, -- [2]
				5759, -- [3]
				27545, -- [4]
				32356, -- [5]
				57655, -- [6]
			},
		},
		["EXPERTTAILOR"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Expert Tailor",
			["icon"] = 136249,
			["id"] = {
				3913, -- [1]
			},
		},
		["CLAW"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				16831, -- [1]
				1082, -- [2]
				1448, -- [3]
				2975, -- [4]
				2976, -- [5]
				2977, -- [6]
				2980, -- [7]
				2981, -- [8]
				2982, -- [9]
				3009, -- [10]
				3010, -- [11]
				3029, -- [12]
				3030, -- [13]
				3666, -- [14]
				3667, -- [15]
				5201, -- [16]
				5203, -- [17]
				5204, -- [18]
				9849, -- [19]
				9850, -- [20]
				9851, -- [21]
				16827, -- [22]
				16828, -- [23]
				16829, -- [24]
				16830, -- [25]
				16832, -- [26]
				24187, -- [27]
				27000, -- [28]
				27049, -- [29]
				27347, -- [30]
				31289, -- [31]
				47468, -- [32]
				48569, -- [33]
				48570, -- [34]
				51772, -- [35]
				52471, -- [36]
				52472, -- [37]
				62225, -- [38]
				75159, -- [39]
				67774, -- [40]
				67793, -- [41]
			},
			["castTime"] = 0,
			["icon"] = 132140,
			["name"] = "Claw",
		},
		["EBONWEAVEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56027, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Ebonweave Gloves",
		},
		["SPRINGYARACHNOWEAVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				63765, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Springy Arachnoweave",
		},
		["LESSERFLASKOFRESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				62213, -- [1]
				62380, -- [2]
			},
			["icon"] = 136240,
			["name"] = "Lesser Flask of Resistance",
		},
		["SOLIDCHALCEDONY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53934, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Solid Chalcedony",
		},
		["GLYPHOFCLAW"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Claw",
			["icon"] = 136243,
			["id"] = {
				67598, -- [1]
				67599, -- [2]
				67600, -- [3]
			},
		},
		["RAPIDFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				3045, -- [1]
				3049, -- [2]
				28755, -- [3]
				36828, -- [4]
				69277, -- [5]
			},
			["icon"] = 132208,
			["name"] = "Rapid Fire",
		},
		["BLOODSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				45902, -- [1]
				49926, -- [2]
				49927, -- [3]
				49928, -- [4]
				49929, -- [5]
				49930, -- [6]
				52374, -- [7]
				52377, -- [8]
				59130, -- [9]
				60945, -- [10]
				61696, -- [11]
				66975, -- [12]
				66976, -- [13]
				66977, -- [14]
				66978, -- [15]
				66979, -- [16]
				66215, -- [17]
			},
			["icon"] = 135772,
			["name"] = "Blood Strike",
		},
		["HEXOFWEAKNESS"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				9035, -- [1]
				19281, -- [2]
				19282, -- [3]
				19283, -- [4]
				19284, -- [5]
				19285, -- [6]
				19325, -- [7]
				19326, -- [8]
				19327, -- [9]
				19328, -- [10]
				19329, -- [11]
				19330, -- [12]
				25816, -- [13]
				52645, -- [14]
			},
			["castTime"] = 0,
			["icon"] = 136157,
			["name"] = "Hex of Weakness",
		},
		["BLINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1953, -- [1]
				517, -- [2]
				894, -- [3]
				5499, -- [4]
				14514, -- [5]
				21655, -- [6]
				28391, -- [7]
				28401, -- [8]
				29208, -- [9]
				29209, -- [10]
				29210, -- [11]
				29211, -- [12]
				6139, -- [13]
				29883, -- [14]
				29884, -- [15]
				29966, -- [16]
				29967, -- [17]
				29968, -- [18]
				31439, -- [19]
				31465, -- [20]
				32937, -- [21]
				33546, -- [22]
				33548, -- [23]
				33549, -- [24]
				33550, -- [25]
				34165, -- [26]
				34605, -- [27]
				34844, -- [28]
				36097, -- [29]
				36109, -- [30]
				36718, -- [31]
				36994, -- [32]
				38194, -- [33]
				38203, -- [34]
				38642, -- [35]
				38643, -- [36]
				38932, -- [37]
				38981, -- [38]
				45862, -- [39]
				46571, -- [40]
				46573, -- [41]
				50648, -- [42]
				57869, -- [43]
				62578, -- [44]
				64662, -- [45]
				65793, -- [46]
				69904, -- [47]
			},
			["icon"] = 135736,
			["name"] = "Blink",
		},
		["DENSEBLASTINGPOWDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Dense Blasting Powder",
			["icon"] = 136243,
			["id"] = {
				19788, -- [1]
				19844, -- [2]
			},
		},
		["BRILLIANTSARONITEBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55058, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Brilliant Saronite Breastplate",
		},
		["STARFIRE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 3293,
			["name"] = "Starfire",
			["icon"] = 135753,
			["id"] = {
				2912, -- [1]
				2914, -- [2]
				8949, -- [3]
				8950, -- [4]
				8951, -- [5]
				8952, -- [6]
				8953, -- [7]
				8954, -- [8]
				9875, -- [9]
				9876, -- [10]
				9877, -- [11]
				9878, -- [12]
				21668, -- [13]
				25298, -- [14]
				25408, -- [15]
				25971, -- [16]
				26986, -- [17]
				35243, -- [18]
				38935, -- [19]
				40344, -- [20]
				48464, -- [21]
				48465, -- [22]
				65854, -- [23]
				75332, -- [24]
			},
		},
		["SUNROCKRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				56194, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Sun Rock Ring",
		},
		["SMELTGOLD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Smelt Gold",
			["icon"] = 136243,
			["id"] = {
				3308, -- [1]
				3315, -- [2]
			},
		},
		["TEMPEREDSARONITEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54552, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Tempered Saronite Boots",
		},
		["HILLMANSSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Hillman's Shoulders",
			["icon"] = 136247,
			["id"] = {
				3768, -- [1]
				3793, -- [2]
			},
		},
		["ENCHANTBRACERSEXCEPTIONALINTELLECT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Bracers - Exceptional Intellect",
			["icon"] = 136244,
			["id"] = {
				44555, -- [1]
			},
		},
		["FOREMANSENCHANTEDHELMET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				30515, -- [1]
				30565, -- [2]
			},
			["icon"] = 135933,
			["name"] = "Foreman's Enchanted Helmet",
		},
		["ENCHANTSHIELDMINORSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13378, -- [1]
				13392, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Shield - Minor Stamina",
		},
		["FELIRONPLATEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29545, -- [1]
			},
			["icon"] = 132937,
			["name"] = "Fel Iron Plate Gloves",
		},
		["BARBARICSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Barbaric Shoulders",
			["icon"] = 136247,
			["id"] = {
				7151, -- [1]
				7152, -- [2]
			},
		},
		["SUFFERING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				17752, -- [1]
				17735, -- [2]
				17736, -- [3]
				17750, -- [4]
				17751, -- [5]
				17753, -- [6]
				17754, -- [7]
				17755, -- [8]
				20393, -- [9]
				20394, -- [10]
				20395, -- [11]
				20396, -- [12]
				27271, -- [13]
				27500, -- [14]
				33701, -- [15]
				33703, -- [16]
				47989, -- [17]
				47990, -- [18]
				48005, -- [19]
				48006, -- [20]
				50330, -- [21]
			},
			["castTime"] = 0,
			["icon"] = 136123,
			["name"] = "Suffering",
		},
		["BATTLESHOUT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Battle Shout",
			["icon"] = 132333,
			["id"] = {
				6673, -- [1]
				5242, -- [2]
				5243, -- [3]
				6192, -- [4]
				6193, -- [5]
				6543, -- [6]
				6674, -- [7]
				9128, -- [8]
				11549, -- [9]
				11550, -- [10]
				11551, -- [11]
				11552, -- [12]
				11553, -- [13]
				24438, -- [14]
				25101, -- [15]
				25289, -- [16]
				25356, -- [17]
				25959, -- [18]
				26043, -- [19]
				26099, -- [20]
				27578, -- [21]
				2048, -- [22]
				30635, -- [23]
				30833, -- [24]
				30931, -- [25]
				31403, -- [26]
				32064, -- [27]
				38232, -- [28]
				42247, -- [29]
				46763, -- [30]
				47436, -- [31]
				49724, -- [32]
				59614, -- [33]
				64062, -- [34]
				70750, -- [35]
			},
		},
		["GLYPHOFFROSTNOVA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Frost Nova",
			["icon"] = 136243,
			["id"] = {
				56376, -- [1]
				56589, -- [2]
				56976, -- [3]
			},
		},
		["ENCHANTBOOTSGREATERSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Boots - Greater Spirit",
			["icon"] = 136244,
			["id"] = {
				44508, -- [1]
			},
		},
		["RUGGEDLEATHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Rugged Leather",
			["icon"] = 136243,
			["id"] = {
				22331, -- [1]
				22332, -- [2]
			},
		},
		["BLOODMOON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				36261, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Bloodmoon",
		},
		["SHRED"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Shred",
			["icon"] = 132152,
			["id"] = {
				3252, -- [1]
				5221, -- [2]
				5222, -- [3]
				6800, -- [4]
				6801, -- [5]
				8992, -- [6]
				8993, -- [7]
				9829, -- [8]
				9830, -- [9]
				9831, -- [10]
				9832, -- [11]
				27555, -- [12]
				27001, -- [13]
				27002, -- [14]
				48571, -- [15]
				48572, -- [16]
				49121, -- [17]
				49165, -- [18]
				61548, -- [19]
				61549, -- [20]
			},
		},
		["FROST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				18977, -- [1]
				43569, -- [2]
			},
			["icon"] = 135849,
			["name"] = "Frost",
		},
		["AURORASLIPPERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56023, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Aurora Slippers",
		},
		["ENCHANTBOOTSLESSERAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13637, -- [1]
				13638, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Boots - Lesser Agility",
		},
		["GLYPHOFWINDFURYWEAPON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55445, -- [1]
				55562, -- [2]
				57252, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Windfury Weapon",
		},
		["INTIMIDATINGSHOUT"] = {
			["maxRange"] = 8,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Intimidating Shout",
			["icon"] = 132154,
			["id"] = {
				5246, -- [1]
				5247, -- [2]
				19134, -- [3]
				20511, -- [4]
				29544, -- [5]
				65930, -- [6]
				65931, -- [7]
			},
		},
		["FORGEDCOBALTCLAYMORE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55203, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Forged Cobalt Claymore",
		},
		["GRANDMASTERTAILOR"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				51308, -- [1]
				65283, -- [2]
			},
			["icon"] = 136249,
			["name"] = "Grand Master Tailor",
		},
		["PRAYEROFSPIRIT"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				27681, -- [1]
				27682, -- [2]
				27845, -- [3]
				32999, -- [4]
				48074, -- [5]
			},
			["name"] = "Prayer of Spirit",
			["icon"] = 135946,
			["castTime"] = 0,
		},
		["FROSTSCALEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50954, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Frostscale Boots",
		},
		["GLYPHOFARCANEEXPLOSION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Arcane Explosion",
			["icon"] = 136243,
			["id"] = {
				56360, -- [1]
				56540, -- [2]
				56968, -- [3]
			},
		},
		["INFUSEDSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53867, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Infused Shadow Crystal",
		},
		["PURIFIEDSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53863, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Purified Shadow Crystal",
		},
		["ARCANEBARRAGE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				44425, -- [1]
				44780, -- [2]
				44781, -- [3]
				50273, -- [4]
				50804, -- [5]
				56397, -- [6]
				58456, -- [7]
				59248, -- [8]
				59381, -- [9]
				63934, -- [10]
				64599, -- [11]
				64607, -- [12]
				65799, -- [13]
			},
			["icon"] = 236205,
			["name"] = "Arcane Barrage",
		},
		["JUDGEMENTOFWISDOM"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Judgement of Wisdom",
			["icon"] = 236255,
			["id"] = {
				20186, -- [1]
				20268, -- [2]
				20352, -- [3]
				20353, -- [4]
				20354, -- [5]
				20355, -- [6]
				25757, -- [7]
				25758, -- [8]
				53408, -- [9]
			},
		},
		["GROWL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				14917, -- [1]
				1853, -- [2]
				2649, -- [3]
				6795, -- [4]
				6796, -- [5]
				14916, -- [6]
				14918, -- [7]
				14919, -- [8]
				14920, -- [9]
				14921, -- [10]
				14922, -- [11]
				14923, -- [12]
				14924, -- [13]
				14925, -- [14]
				14926, -- [15]
				14927, -- [16]
				15147, -- [17]
				15148, -- [18]
				15149, -- [19]
				15150, -- [20]
				15151, -- [21]
				27047, -- [22]
				27344, -- [23]
				31334, -- [24]
				39270, -- [25]
				58855, -- [26]
				61676, -- [27]
			},
			["castTime"] = 0,
			["icon"] = 132270,
			["name"] = "Growl",
		},
		["FURLININGSPELLPOWER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				57691, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Fur Lining - Spell Power",
		},
		["TRACKGIANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				19882, -- [1]
				20158, -- [2]
				31886, -- [3]
			},
			["icon"] = 132275,
			["name"] = "Track Giants",
		},
		["TURTLESCALEBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Turtle Scale Breastplate",
			["icon"] = 136247,
			["id"] = {
				10511, -- [1]
				10513, -- [2]
			},
		},
		["ENRAGEDREGENERATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Enraged Regeneration",
			["icon"] = 132345,
			["id"] = {
				55694, -- [1]
			},
		},
		["SOLIDDYNAMITE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 941,
			["name"] = "Solid Dynamite",
			["icon"] = 135826,
			["id"] = {
				12419, -- [1]
				12586, -- [2]
				12630, -- [3]
			},
		},
		["EXPLOSIVEDECOY"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				54359, -- [1]
				56463, -- [2]
			},
			["icon"] = 136172,
			["name"] = "Explosive Decoy",
		},
		["FINELEATHERCLOAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Fine Leather Cloak",
			["icon"] = 136247,
			["id"] = {
				2159, -- [1]
				2886, -- [2]
			},
		},
		["ORNATESARONITEWALKERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56552, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Ornate Saronite Walkers",
		},
		["SCROLLOFSTRENGTHVIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				58491, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Strength VIII",
		},
		["ENCHANTWEAPONMINORSTRIKING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7788, -- [1]
				7789, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Weapon - Minor Striking",
		},
		["GLYPHOFSUNDERARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Sunder Armor",
			["icon"] = 132918,
			["id"] = {
				57167, -- [1]
				58387, -- [2]
				58395, -- [3]
			},
		},
		["FROSTGUARDDRAPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				64729, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostguard Drape",
		},
		["MISTYDARKJADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53922, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Misty Dark Jade",
		},
		["SCROLLOFSTRENGTHII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Strength II",
			["icon"] = 132918,
			["id"] = {
				58485, -- [1]
			},
		},
		["TITANSTEELSHIELDWALL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56400, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Titansteel Shield Wall",
		},
		["NERUBIANSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50958, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Nerubian Shoulders",
		},
		["DRAINSOUL"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				1120, -- [1]
				7662, -- [2]
				8288, -- [3]
				8289, -- [4]
				8290, -- [5]
				8291, -- [6]
				11675, -- [7]
				11676, -- [8]
				18371, -- [9]
				27217, -- [10]
				32862, -- [11]
				35839, -- [12]
				47855, -- [13]
				60452, -- [14]
			},
			["name"] = "Drain Soul",
			["icon"] = 136163,
			["castTime"] = 0,
		},
		["SPIDERSAUSAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Spider Sausage",
			["icon"] = 134022,
			["id"] = {
				21175, -- [1]
				21176, -- [2]
			},
		},
		["GLYPHOFHEALINGSTREAMTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Healing Stream Totem",
			["icon"] = 136243,
			["id"] = {
				55456, -- [1]
				57242, -- [2]
			},
		},
		["GLYPHOFFROSTSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Frost Strike",
			["icon"] = 132918,
			["id"] = {
				57216, -- [1]
				58644, -- [2]
				58647, -- [3]
				58715, -- [4]
			},
		},
		["ENGINEERINGSPECIALIZATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				20593, -- [1]
			},
			["icon"] = 134063,
			["name"] = "Engineering Specialization",
		},
		["WATERWALKING"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				546, -- [1]
				562, -- [2]
				1338, -- [3]
				11319, -- [4]
			},
			["icon"] = 135863,
			["name"] = "Water Walking",
		},
		["PROWL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				24452, -- [1]
				5215, -- [2]
				5216, -- [3]
				6783, -- [4]
				6784, -- [5]
				8152, -- [6]
				9913, -- [7]
				9914, -- [8]
				24450, -- [9]
				24451, -- [10]
				24453, -- [11]
				24454, -- [12]
				24455, -- [13]
				42932, -- [14]
			},
			["castTime"] = 0,
			["icon"] = 132142,
			["name"] = "Prowl",
		},
		["SUBJUGATEDEMON"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				1098, -- [1]
				7665, -- [2]
				11725, -- [3]
				11726, -- [4]
				11727, -- [5]
				11728, -- [6]
				20882, -- [7]
				61191, -- [8]
			},
			["name"] = "Subjugate Demon",
			["icon"] = 136154,
			["castTime"] = 3000,
		},
		["FAERIEFIRE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Faerie Fire",
			["icon"] = 136033,
			["id"] = {
				770, -- [1]
				778, -- [2]
				784, -- [3]
				793, -- [4]
				1070, -- [5]
				1414, -- [6]
				1415, -- [7]
				1416, -- [8]
				2889, -- [9]
				6950, -- [10]
				9749, -- [11]
				9907, -- [12]
				13424, -- [13]
				13752, -- [14]
				16498, -- [15]
				20656, -- [16]
				21670, -- [17]
				25602, -- [18]
				32129, -- [19]
				65863, -- [20]
			},
		},
		["PLAGUESTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				45462, -- [1]
				49917, -- [2]
				49918, -- [3]
				49919, -- [4]
				49920, -- [5]
				49921, -- [6]
				50688, -- [7]
				52373, -- [8]
				52379, -- [9]
				53694, -- [10]
				54469, -- [11]
				55255, -- [12]
				55321, -- [13]
				56361, -- [14]
				57599, -- [15]
				58839, -- [16]
				58843, -- [17]
				59133, -- [18]
				59985, -- [19]
				60186, -- [20]
				61109, -- [21]
				61600, -- [22]
				66988, -- [23]
				66989, -- [24]
				66990, -- [25]
				66991, -- [26]
				66992, -- [27]
				67724, -- [28]
				66216, -- [29]
				71924, -- [30]
				69912, -- [31]
			},
			["icon"] = 237519,
			["name"] = "Plague Strike",
		},
		["BUGSQUASHERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60620, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Bugsquashers",
		},
		["BOILEDCLAMS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Boiled Clams",
			["icon"] = 134433,
			["id"] = {
				6499, -- [1]
				6502, -- [2]
			},
		},
		["SPORECLOUD"] = {
			["maxRange"] = 6,
			["minRange"] = 0,
			["id"] = {
				53597, -- [1]
				21547, -- [2]
				22948, -- [3]
				24871, -- [4]
				31689, -- [5]
				32079, -- [6]
				32642, -- [7]
				32643, -- [8]
				34168, -- [9]
				35004, -- [10]
				35005, -- [11]
				35394, -- [12]
				38652, -- [13]
				38653, -- [14]
				42526, -- [15]
				50274, -- [16]
				53593, -- [17]
				53594, -- [18]
				53596, -- [19]
				53598, -- [20]
			},
			["castTime"] = 0,
			["icon"] = 132371,
			["name"] = "Spore Cloud",
		},
		["HANDOFPROTECTION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Hand of Protection",
			["icon"] = 135964,
			["id"] = {
				--1022, -- [1]
				--5599, -- [2]
				--10278, -- [3]
				66009, -- [4]
			},
		},
		["HIBERNATE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["name"] = "Hibernate",
			["icon"] = 136090,
			["id"] = {
				2637, -- [1]
				5299, -- [2]
				18657, -- [3]
				18658, -- [4]
				18659, -- [5]
				18660, -- [6]
			},
		},
		["SKYFORGEDGREATAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36135, -- [1]
			},
			["icon"] = 132436,
			["name"] = "Skyforged Great Axe",
		},
		["HEAVYWEIGHTSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Heavy Weightstone",
			["icon"] = 135257,
			["id"] = {
				3117, -- [1]
				3119, -- [2]
			},
		},
		["GLYPHOFSUCCUBUS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				56250, -- [1]
				56299, -- [2]
				57275, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Succubus",
		},
		["ELIXIROFSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53747, -- [1]
				53847, -- [2]
			},
			["icon"] = 134713,
			["name"] = "Elixir of Spirit",
		},
		["MOONSOULCROWN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Moonsoul Crown",
			["icon"] = 136243,
			["id"] = {
				25321, -- [1]
			},
		},
		["SOLIDWEIGHTSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Solid Weightstone",
			["icon"] = 135258,
			["id"] = {
				9921, -- [1]
				9925, -- [2]
			},
		},
		["GNOMISHBATTLECHICKEN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12906, -- [1]
				12917, -- [2]
				23133, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Gnomish Battle Chicken",
		},
		["NOTCHEDCOBALTWARAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55204, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Notched Cobalt War Axe",
		},
		["GLYPHOFEVOCATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Evocation",
			["icon"] = 136243,
			["id"] = {
				56380, -- [1]
				56547, -- [2]
				56974, -- [3]
			},
		},
		["POTENTHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53882, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Potent Huge Citrine",
		},
		["SCROLLOFINTELLECTIV"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Intellect IV",
			["icon"] = 132918,
			["id"] = {
				50600, -- [1]
			},
		},
		["COPPERCHAINBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Copper Chain Boots",
			["icon"] = 132535,
			["id"] = {
				3319, -- [1]
				3340, -- [2]
			},
		},
		["BRONZEMACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Bronze Mace",
			["icon"] = 133483,
			["id"] = {
				2740, -- [1]
				2757, -- [2]
			},
		},
		["SLICEANDDICE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				5171, -- [1]
				5175, -- [2]
				6434, -- [3]
				6774, -- [4]
				6775, -- [5]
				30470, -- [6]
				43547, -- [7]
				60847, -- [8]
			},
			["castTime"] = 0,
			["icon"] = 132306,
			["name"] = "Slice and Dice",
		},
		["CRYSTALCHALCEDONYAMULET"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				58142, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Crystal Chalcedony Amulet",
		},
		["CHALLENGINGROAR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Challenging Roar",
			["icon"] = 132117,
			["id"] = {
				5209, -- [1]
				5210, -- [2]
			},
		},
		["JOURNEYMANFIRSTAID"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman First Aid",
			["icon"] = 135966,
			["id"] = {
				3280, -- [1]
			},
		},
		["GRANDMASTERSCRIBE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				45380, -- [1]
				65287, -- [2]
			},
			["icon"] = 237171,
			["name"] = "Grand Master Scribe",
		},
		["SAVAGEDEFENSE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Savage Defense",
			["icon"] = 132278,
			["id"] = {
				62600, -- [1]
				62606, -- [2]
			},
		},
		["RADIANTDEEPPERIDOT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28916, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Radiant Deep Peridot",
		},
		["CLOAKOFHARSHWINDS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60631, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Cloak of Harsh Winds",
		},
		["TURTLESCALEHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Turtle Scale Helm",
			["icon"] = 136247,
			["id"] = {
				10552, -- [1]
				10553, -- [2]
			},
		},
		["SMITE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 1411,
			["id"] = {
				585, -- [1]
				591, -- [2]
				598, -- [3]
				984, -- [4]
				1004, -- [5]
				1275, -- [6]
				1276, -- [7]
				1300, -- [8]
				1301, -- [9]
				6060, -- [10]
				6062, -- [11]
				10933, -- [12]
				10934, -- [13]
				10935, -- [14]
				10936, -- [15]
				25363, -- [16]
				25364, -- [17]
				35155, -- [18]
				48122, -- [19]
				48123, -- [20]
				61923, -- [21]
				71778, -- [22]
				71841, -- [23]
				71842, -- [24]
				69967, -- [25]
				71546, -- [26]
			},
			["icon"] = 135924,
			["name"] = "Smite",
		},
		["ICYMANAPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53839, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Icy Mana Potion",
		},
		["JADEFIREINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Jadefire Ink",
			["icon"] = 132918,
			["id"] = {
				57707, -- [1]
			},
		},
		["WHITESWASHBUCKLERSSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "White Swashbuckler's Shirt",
			["icon"] = 132149,
			["id"] = {
				8483, -- [1]
				8490, -- [2]
			},
		},
		["GREATERMYSTICWAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 10000,
			["id"] = {
				14810, -- [1]
				14812, -- [2]
			},
			["icon"] = 135469,
			["name"] = "Greater Mystic Wand",
		},
		["SANCTIFIEDSPELLTHREAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 4000,
			["id"] = {
				56039, -- [1]
			},
			["icon"] = 136011,
			["name"] = "Sanctified Spellthread",
		},
		["GLYPHOFPSYCHICSCREAM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Psychic Scream",
			["icon"] = 136243,
			["id"] = {
				55676, -- [1]
				56177, -- [2]
				57196, -- [3]
			},
		},
		["DALARANCLAMCHOWDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				58065, -- [1]
			},
			["icon"] = 133971,
			["name"] = "Dalaran Clam Chowder",
		},
		["GLYPHOFINNERFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Inner Fire",
			["icon"] = 136243,
			["id"] = {
				55686, -- [1]
				56168, -- [2]
				57188, -- [3]
			},
		},
		["CITRINERINGOFRAPIDHEALING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Citrine Ring of Rapid Healing",
			["icon"] = 136243,
			["id"] = {
				25621, -- [1]
			},
		},
		["DEATHCOIL"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				6789, -- [1]
				1572, -- [2]
				17925, -- [3]
				17926, -- [4]
				18161, -- [5]
				18162, -- [6]
				28412, -- [7]
				27223, -- [8]
				30500, -- [9]
				30741, -- [10]
				32709, -- [11]
				33130, -- [12]
				34437, -- [13]
				35954, -- [14]
				38065, -- [15]
				39661, -- [16]
				41070, -- [17]
				44142, -- [18]
				46283, -- [19]
				47541, -- [20]
				47632, -- [21]
				47633, -- [22]
				47859, -- [23]
				47860, -- [24]
				49892, -- [25]
				49893, -- [26]
				49894, -- [27]
				49895, -- [28]
				50668, -- [29]
				52375, -- [30]
				52376, -- [31]
				53769, -- [32]
				55209, -- [33]
				55210, -- [34]
				55320, -- [35]
				56362, -- [36]
				59134, -- [37]
				60949, -- [38]
				62900, -- [39]
				62901, -- [40]
				62902, -- [41]
				62903, -- [42]
				62904, -- [43]
				66019, -- [44]
				65820, -- [45]
				71490, -- [46]
			},
			["icon"] = 136145,
			["name"] = "Death Coil",
		},
		["SHADOWFURY"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				30283, -- [1]
				30413, -- [2]
				30414, -- [3]
				35373, -- [4]
				39082, -- [5]
				45270, -- [6]
				47846, -- [7]
				47847, -- [8]
				56733, -- [9]
				61463, -- [10]
			},
			["name"] = "Shadowfury",
			["icon"] = 136201,
			["castTime"] = 0,
		},
		["SAVAGEROAR"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Savage Roar",
			["icon"] = 236167,
			["id"] = {
				52610, -- [1]
				62071, -- [2]
			},
		},
		["MARKSBOOMSTICK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				54353, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Mark \"S\" Boomstick",
		},
		["STEADYSHOT"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["id"] = {
				34120, -- [1]
				49051, -- [2]
				49052, -- [3]
				56641, -- [4]
				65867, -- [5]
			},
			["castTime"] = 2000,
			["icon"] = 132213,
			["name"] = "Steady Shot",
		},
		["CRIMSONSILKVEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Crimson Silk Vest",
			["icon"] = 132149,
			["id"] = {
				8791, -- [1]
				8807, -- [2]
			},
		},
		["SCROLLOFSPIRITVIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50611, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Spirit VIII",
		},
		["ASPECTOFTHEHAWK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				13165, -- [1]
				6385, -- [2]
				14318, -- [3]
				14319, -- [4]
				14320, -- [5]
				14321, -- [6]
				14322, -- [7]
				14374, -- [8]
				14375, -- [9]
				14376, -- [10]
				14377, -- [11]
				14378, -- [12]
				25296, -- [13]
				25406, -- [14]
				25969, -- [15]
				27044, -- [16]
			},
			["icon"] = 136076,
			["name"] = "Aspect of the Hawk",
		},
		["TITANIUMWEAPONCHAIN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				55836, -- [1]
				55839, -- [2]
			},
			["icon"] = 132507,
			["name"] = "Titanium Weapon Chain",
		},
		["IRONSTRUT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Iron Strut",
			["icon"] = 136243,
			["id"] = {
				3958, -- [1]
				4016, -- [2]
			},
		},
		["FELIRONPLATEPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29549, -- [1]
			},
			["icon"] = 134694,
			["name"] = "Fel Iron Plate Pants",
		},
		["GLIMMERINGHUGECITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53891, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Glimmering Huge Citrine",
		},
		["GLYPHOFICEARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Ice Armor",
			["icon"] = 136243,
			["id"] = {
				56384, -- [1]
				56591, -- [2]
				56978, -- [3]
			},
		},
		["LESSERINVISIBILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				7870, -- [1]
				66, -- [2]
				515, -- [3]
				3680, -- [4]
				7880, -- [5]
				12845, -- [6]
				20408, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 135994,
			["name"] = "Lesser Invisibility",
		},
		["GREENTINTEDGOGGLES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Green Tinted Goggles",
			["icon"] = 136243,
			["id"] = {
				3956, -- [1]
				4014, -- [2]
			},
		},
		["ENCHANTCLOAKSPEED"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Cloak - Speed",
			["icon"] = 136244,
			["id"] = {
				60609, -- [1]
			},
		},
		["BRONZEWARHAMMER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Bronze Warhammer",
			["icon"] = 133055,
			["id"] = {
				9985, -- [1]
				9988, -- [2]
			},
		},
		["BOOKOFSURVIVAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Book of Survival",
			["icon"] = 132918,
			["id"] = {
				59478, -- [1]
			},
		},
		["VICTORYRUSH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Victory Rush",
			["icon"] = 132342,
			["id"] = {
				34428, -- [1]
			},
		},
		["COBALTBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55834, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cobalt Bracers",
		},
		["SCROLLOFSTRENGTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Scroll of Strength",
			["icon"] = 132918,
			["id"] = {
				58484, -- [1]
			},
		},
		["SILKBANDAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Silk Bandage",
			["icon"] = 133671,
			["id"] = {
				7928, -- [1]
				7930, -- [2]
			},
		},
		["GUARDIANPANTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Guardian Pants",
			["icon"] = 136247,
			["id"] = {
				7147, -- [1]
				7148, -- [2]
			},
		},
		["GOLDENSCALEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Golden Scale Bracers",
			["icon"] = 132609,
			["id"] = {
				7223, -- [1]
				7225, -- [2]
			},
		},
		["POWERWORDFORTITUDE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1243, -- [1]
				1244, -- [2]
				1245, -- [3]
				1255, -- [4]
				1256, -- [5]
				1257, -- [6]
				2791, -- [7]
				2793, -- [8]
				10937, -- [9]
				10938, -- [10]
				10939, -- [11]
				10940, -- [12]
				13864, -- [13]
				23947, -- [14]
				23948, -- [15]
				25389, -- [16]
				36004, -- [17]
				48161, -- [18]
				58921, -- [19]
			},
			["icon"] = 135987,
			["name"] = "Power Word: Fortitude",
		},
		["FEROCIOUSINSPIRATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				75593, -- [1]
				34455, -- [2]
				34459, -- [3]
				34460, -- [4]
				75447, -- [5]
				75446, -- [6]
			},
			["castTime"] = 0,
			["icon"] = 132173,
			["name"] = "Ferocious Inspiration",
		},
		["GLYPHOFHAMSTRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Hamstring",
			["icon"] = 132918,
			["id"] = {
				57157, -- [1]
				58372, -- [2]
				58373, -- [3]
				58404, -- [4]
			},
		},
		["EXPERTMINER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Expert Miner",
			["icon"] = 136248,
			["id"] = {
				3568, -- [1]
			},
		},
		["WINGCLIP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2974, -- [1]
				2979, -- [2]
				14267, -- [3]
				14268, -- [4]
				14339, -- [5]
				14340, -- [6]
				27633, -- [7]
				32908, -- [8]
				40652, -- [9]
				44286, -- [10]
				59604, -- [11]
				66207, -- [12]
			},
			["icon"] = 132309,
			["name"] = "Wing Clip",
		},
		["MIGHTYALCHEMISTSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				60405, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Mighty Alchemist Stone",
		},
		["ARTISANBLACKSMITH"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Blacksmith",
			["icon"] = 136241,
			["id"] = {
				9786, -- [1]
			},
		},
		["DRUMSOFFORGOTTENKINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				69386, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Drums of Forgotten Kings",
		},
		["GLYPHOFMINDFLAY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Mind Flay",
			["icon"] = 136243,
			["id"] = {
				55687, -- [1]
				56181, -- [2]
				57200, -- [3]
			},
		},
		["GREENIRONLEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Green Iron Leggings",
			["icon"] = 134585,
			["id"] = {
				3506, -- [1]
				3524, -- [2]
			},
		},
		["EMPOWEREDIMP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				54278, -- [1]
				47220, -- [2]
				47221, -- [3]
				47223, -- [4]
				47283, -- [5]
			},
			["castTime"] = 0,
			["icon"] = 236294,
			["name"] = "Empowered Imp",
		},
		["SPIKEDCOBALTLEGPLATES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54947, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Spiked Cobalt Legplates",
		},
		["NECKLACEOFTHEDEEP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				40514, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Necklace of the Deep",
		},
		["MAGMATOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8187, -- [1]
				8189, -- [2]
				8190, -- [3]
				10579, -- [4]
				10580, -- [5]
				10581, -- [6]
				10585, -- [7]
				10586, -- [8]
				10587, -- [9]
				10588, -- [10]
				10589, -- [11]
				10590, -- [12]
				25550, -- [13]
				25552, -- [14]
				58731, -- [15]
				58732, -- [16]
				58734, -- [17]
				58735, -- [18]
			},
			["icon"] = 135826,
			["name"] = "Magma Totem",
		},
		["LIGHTWEAVEEMBROIDERY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55640, -- [1]
				55642, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Lightweave Embroidery",
		},
		["WYVERNSTING"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = -999500,
			["id"] = {
				19386, -- [1]
				20940, -- [2]
				20941, -- [3]
				24131, -- [4]
				24132, -- [5]
				24133, -- [6]
				24134, -- [7]
				24135, -- [8]
				24335, -- [9]
				24336, -- [10]
				26180, -- [11]
				26233, -- [12]
				26748, -- [13]
				27068, -- [14]
				27069, -- [15]
				41186, -- [16]
				49009, -- [17]
				49010, -- [18]
				49011, -- [19]
				49012, -- [20]
				65877, -- [21]
				65878, -- [22]
			},
			["icon"] = 135125,
			["name"] = "Wyvern Sting",
		},
		["MIGHTYRAGEPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Mighty Rage Potion",
			["icon"] = 136243,
			["id"] = {
				17527, -- [1]
				17552, -- [2]
			},
		},
		["ETERNALBELTBUCKLE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3763,
			["id"] = {
				55655, -- [1]
				55656, -- [2]
			},
			["icon"] = 132525,
			["name"] = "Eternal Belt Buckle",
		},
		["FISHING"] = {
			["maxRange"] = 20,
			["minRange"] = 10,
			["castTime"] = 0,
			["id"] = {
				7620, -- [1]
				7731, -- [2]
				7732, -- [3]
				13615, -- [4]
				18248, -- [5]
				24303, -- [6]
				33095, -- [7]
				45698, -- [8]
				51294, -- [9]
				62734, -- [10]
				63275, -- [11]
				71691, -- [12]
			},
			["icon"] = 136245,
			["name"] = "Fishing",
		},
		["INNERFIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				588, -- [1]
				602, -- [2]
				609, -- [3]
				624, -- [4]
				1006, -- [5]
				1007, -- [6]
				1252, -- [7]
				1253, -- [8]
				1254, -- [9]
				7128, -- [10]
				7129, -- [11]
				7130, -- [12]
				10951, -- [13]
				10952, -- [14]
				11025, -- [15]
				11026, -- [16]
				25431, -- [17]
				48040, -- [18]
				48168, -- [19]
			},
			["name"] = "Inner Fire",
			["icon"] = 135926,
			["castTime"] = 0,
		},
		["SOCKETGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				55641, -- [1]
			},
			["icon"] = 132984,
			["name"] = "Socket Gloves",
		},
		["BROWNLINENROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Brown Linen Robe",
			["icon"] = 136243,
			["id"] = {
				7623, -- [1]
				7626, -- [2]
			},
		},
		["STONEFORM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				7020, -- [1]
				20594, -- [2]
				20612, -- [3]
				65116, -- [4]
				69575, -- [5]
				70733, -- [6]
			},
			["icon"] = 132275,
			["name"] = "Stoneform",
		},
		["BLIND"] = {
			["maxRange"] = 10,
			["minRange"] = 0,
			["id"] = {
				2094, -- [1]
				6505, -- [2]
				21060, -- [3]
				34654, -- [4]
				34694, -- [5]
				42972, -- [6]
				43433, -- [7]
				65960, -- [8]
			},
			["castTime"] = 0,
			["icon"] = 136175,
			["name"] = "Blind",
		},
		["EXPERTSCRIBE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Expert Scribe",
			["icon"] = 237171,
			["id"] = {
				45377, -- [1]
			},
		},
		["SINISTERSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1752, -- [1]
				1757, -- [2]
				1758, -- [3]
				1759, -- [4]
				1760, -- [5]
				1761, -- [6]
				1762, -- [7]
				1763, -- [8]
				1764, -- [9]
				1765, -- [10]
				8621, -- [11]
				8622, -- [12]
				11293, -- [13]
				11294, -- [14]
				11295, -- [15]
				11296, -- [16]
				14873, -- [17]
				15581, -- [18]
				15667, -- [19]
				19472, -- [20]
				26861, -- [21]
				26862, -- [22]
				46558, -- [23]
				48637, -- [24]
				48638, -- [25]
				57640, -- [26]
				59409, -- [27]
				60195, -- [28]
				69920, -- [29]
			},
			["icon"] = 136189,
			["name"] = "Sinister Strike",
		},
		["GUARDIANGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Guardian Gloves",
			["icon"] = 136247,
			["id"] = {
				7156, -- [1]
				7157, -- [2]
			},
		},
		["ENCHANT2HWEAPONGREATERIMPACT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13937, -- [1]
				13938, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant 2H Weapon - Greater Impact",
		},
		["COBALTBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				52568, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cobalt Belt",
		},
		["RETRIBUTIONAURA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Retribution Aura",
			["icon"] = 135873,
			["id"] = {
				7294, -- [1]
				7296, -- [2]
				8990, -- [3]
				10298, -- [4]
				10299, -- [5]
				10300, -- [6]
				10301, -- [7]
				10302, -- [8]
				10303, -- [9]
				10304, -- [10]
				10305, -- [11]
				13008, -- [12]
				27150, -- [13]
				54043, -- [14]
			},
		},
		["MINDVISION"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				2096, -- [1]
				1150, -- [2]
				2097, -- [3]
				10909, -- [4]
				10910, -- [5]
				45468, -- [6]
			},
			["name"] = "Mind Vision",
			["icon"] = 135934,
			["castTime"] = 0,
		},
		["JADERINGOFSLAYING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				58144, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Jade Ring of Slaying",
		},
		["SOULFIRE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				6353, -- [1]
				1571, -- [2]
				17924, -- [3]
				18160, -- [4]
				27211, -- [5]
				30545, -- [6]
				47824, -- [7]
				47825, -- [8]
			},
			["name"] = "Soul Fire",
			["icon"] = 135808,
			["castTime"] = 6000,
		},
		["COARSEWEIGHTSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Coarse Weightstone",
			["icon"] = 135256,
			["id"] = {
				3116, -- [1]
				3118, -- [2]
			},
		},
		["WINDFORGEDLEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36124, -- [1]
			},
			["icon"] = 134662,
			["name"] = "Windforged Leggings",
		},
		["SMELTADAMANTITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				29358, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Smelt Adamantite",
		},
		["DUALWIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				674, -- [1]
				1424, -- [2]
				30798, -- [3]
				29651, -- [4]
				42459, -- [5]
			},
			["icon"] = 132147,
			["name"] = "Dual Wield",
		},
		["FIREBLAST"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2136, -- [1]
				2137, -- [2]
				2138, -- [3]
				2141, -- [4]
				2142, -- [5]
				2143, -- [6]
				3073, -- [7]
				3074, -- [8]
				3075, -- [9]
				8412, -- [10]
				8413, -- [11]
				8414, -- [12]
				8415, -- [13]
				10197, -- [14]
				10198, -- [15]
				10199, -- [16]
				10200, -- [17]
				13339, -- [18]
				13340, -- [19]
				13341, -- [20]
				13342, -- [21]
				13374, -- [22]
				14145, -- [23]
				15573, -- [24]
				15574, -- [25]
				16144, -- [26]
				20623, -- [27]
				20679, -- [28]
				20795, -- [29]
				20832, -- [30]
				25028, -- [31]
				29633, -- [32]
				29644, -- [33]
				27078, -- [34]
				27079, -- [35]
				27378, -- [36]
				27379, -- [37]
				30512, -- [38]
				30516, -- [39]
				36339, -- [40]
				37110, -- [41]
				38526, -- [42]
				42872, -- [43]
				42873, -- [44]
				43245, -- [45]
				45232, -- [46]
				47721, -- [47]
				56939, -- [48]
				57984, -- [49]
				59637, -- [50]
				60871, -- [51]
				64773, -- [52]
			},
			["icon"] = 135807,
			["name"] = "Fire Blast",
		},
		["MANASHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1463, -- [1]
				1481, -- [2]
				8494, -- [3]
				8495, -- [4]
				8496, -- [5]
				8497, -- [6]
				10191, -- [7]
				10192, -- [8]
				10193, -- [9]
				10194, -- [10]
				10195, -- [11]
				10196, -- [12]
				17740, -- [13]
				17741, -- [14]
				27131, -- [15]
				27398, -- [16]
				29880, -- [17]
				30973, -- [18]
				31635, -- [19]
				35064, -- [20]
				38151, -- [21]
				43019, -- [22]
				43020, -- [23]
				46151, -- [24]
				56778, -- [25]
				58348, -- [26]
			},
			["icon"] = 136153,
			["name"] = "Mana Shield",
		},
		["SENTRYTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				6495, -- [1]
				6496, -- [2]
			},
			["icon"] = 136082,
			["name"] = "Sentry Totem",
		},
		["BOOKOFSTARS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Book of Stars",
			["icon"] = 132918,
			["id"] = {
				59490, -- [1]
			},
		},
		["TWOHANDEDMACES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Two-Handed Maces",
			["icon"] = 133479,
			["id"] = {
				199, -- [1]
				15987, -- [2]
			},
		},
		["INDESTRUCTIBLEPOTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53905, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Indestructible Potion",
		},
		["CROWNOFTHESEAWITCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				41418, -- [1]
				41419, -- [2]
			},
			["icon"] = 134071,
			["name"] = "Crown of the Sea Witch",
		},
		["THORIUMTUBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Thorium Tube",
			["icon"] = 136243,
			["id"] = {
				19795, -- [1]
			},
		},
		["SUNSCOPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				55076, -- [1]
				56470, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Sun Scope",
		},
		["FINELEATHERBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Fine Leather Belt",
			["icon"] = 136247,
			["id"] = {
				3763, -- [1]
				3789, -- [2]
			},
		},
		["ICEBORNEWRISTGUARDS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				60607, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Iceborne Wristguards",
		},
		["FROSTRESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				4077, -- [1]
				4080, -- [2]
				8182, -- [3]
				10476, -- [4]
				10477, -- [5]
				13923, -- [6]
				20596, -- [7]
				24446, -- [8]
				24447, -- [9]
				24448, -- [10]
				24449, -- [11]
				24473, -- [12]
				24475, -- [13]
				24476, -- [14]
				24477, -- [15]
				24478, -- [16]
				24481, -- [17]
				24484, -- [18]
				24485, -- [19]
				27534, -- [20]
				28766, -- [21]
				25559, -- [22]
				27054, -- [23]
				27352, -- [24]
				58742, -- [25]
				58744, -- [26]
			},
			["icon"] = 135843,
			["name"] = "Frost Resistance",
		},
		["TRANQUILIZINGSHOT"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["id"] = {
				19801, -- [1]
				19877, -- [2]
				55625, -- [3]
			},
			["castTime"] = -999500,
			["icon"] = 136020,
			["name"] = "Tranquilizing Shot",
		},
		["ASPECTOFTHECHEETAH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				5118, -- [1]
				5131, -- [2]
			},
			["icon"] = 132242,
			["name"] = "Aspect of the Cheetah",
		},
		["DEATHPACT"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				17471, -- [1]
				17472, -- [2]
				17698, -- [3]
				48743, -- [4]
				51956, -- [5]
			},
			["icon"] = 136146,
			["name"] = "Death Pact",
		},
		["THICKLEATHERAMMOPOUCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Thick Leather Ammo Pouch",
			["icon"] = 136247,
			["id"] = {
				14932, -- [1]
				14933, -- [2]
			},
		},
		["SOLIDAZUREMOONSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28950, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Solid Azure Moonstone",
		},
		["GLYPHOFEVASION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Evasion",
			["icon"] = 136243,
			["id"] = {
				56799, -- [1]
				57119, -- [2]
				57146, -- [3]
			},
		},
		["FIRE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				44146, -- [1]
			},
			["icon"] = 134424,
			["name"] = "Fire",
		},
		["DARKFROSTSCALEBREASTPLATE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60604, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Dark Frostscale Breastplate",
		},
		["MASTERCOOK"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 18816,
			["id"] = {
				33361, -- [1]
				54256, -- [2]
			},
			["icon"] = 133971,
			["name"] = "Master Cook",
		},
		["SWORDSPECIALIZATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Sword Specialization",
			["icon"] = 132223,
			["id"] = {
				4352, -- [1]
				4350, -- [2]
				4351, -- [3]
				4353, -- [4]
				4354, -- [5]
				4355, -- [6]
				4356, -- [7]
				4357, -- [8]
				4358, -- [9]
				4359, -- [10]
				4360, -- [11]
				4361, -- [12]
				4362, -- [13]
				4363, -- [14]
				4364, -- [15]
				4365, -- [16]
				5448, -- [17]
				5449, -- [18]
				5450, -- [19]
				5451, -- [20]
				5452, -- [21]
				5453, -- [22]
				5489, -- [23]
				5490, -- [24]
				5491, -- [25]
				5492, -- [26]
				5493, -- [27]
				5494, -- [28]
				12281, -- [29]
				12812, -- [30]
				12813, -- [31]
				12814, -- [32]
				12815, -- [33]
				13960, -- [34]
				13961, -- [35]
				13962, -- [36]
				13963, -- [37]
				13964, -- [38]
				16459, -- [39]
				20597, -- [40]
			},
		},
		["REGALSHADOWCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53868, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Regal Shadow Crystal",
		},
		["APPRENTICEENGINEER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Engineer",
			["icon"] = 136243,
			["id"] = {
				4039, -- [1]
			},
		},
		["SCROLLOFINTELLECTVI"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Scroll of Intellect VI",
			["icon"] = 132918,
			["id"] = {
				50602, -- [1]
			},
		},
		["ENCHANTCLOAKGREATERRESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				20014, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Greater Resistance",
		},
		["LEGGINGSOFVISCERALSTRIKES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60660, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Leggings of Visceral Strikes",
		},
		["TRACKELEMENTALS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				19880, -- [1]
				20157, -- [2]
			},
			["icon"] = 135861,
			["name"] = "Track Elementals",
		},
		["WICKEDLEATHERBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Wicked Leather Bracers",
			["icon"] = 136243,
			["id"] = {
				19052, -- [1]
			},
		},
		["ENCHANTCHESTGREATERMANA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13663, -- [1]
				13666, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Greater Mana",
		},
		["ENCHANTBRACERSTRENGTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13661, -- [1]
				13662, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Strength",
		},
		["WHITELINENROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "White Linen Robe",
			["icon"] = 136243,
			["id"] = {
				7624, -- [1]
				7627, -- [2]
			},
		},
		["DUSKYBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Dusky Bracers",
			["icon"] = 136247,
			["id"] = {
				9201, -- [1]
				9213, -- [2]
			},
		},
		["CONCUSSIVESHOT"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = -999500,
			["id"] = {
				5116, -- [1]
				5117, -- [2]
				17174, -- [3]
				22914, -- [4]
				27634, -- [5]
			},
			["icon"] = 135860,
			["name"] = "Concussive Shot",
		},
		["ROUGHGRINDINGSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Rough Grinding Stone",
			["icon"] = 135243,
			["id"] = {
				3320, -- [1]
				3341, -- [2]
			},
		},
		["DEMONICPACT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53646, -- [1]
				47236, -- [2]
				47237, -- [3]
				47238, -- [4]
				47239, -- [5]
				47240, -- [6]
				48090, -- [7]
				54909, -- [8]
			},
			["castTime"] = 0,
			["icon"] = 237562,
			["name"] = "Demonic Pact",
		},
		["COPPERCLAYMORE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Copper Claymore",
			["icon"] = 135322,
			["id"] = {
				9983, -- [1]
				9984, -- [2]
			},
		},
		["SCROLLOFAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Scroll of Agility",
			["icon"] = 132918,
			["id"] = {
				58472, -- [1]
			},
		},
		["COBALTSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				52572, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cobalt Shoulders",
		},
		["HEAVYMITHRILBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Heavy Mithril Boots",
			["icon"] = 132582,
			["id"] = {
				9968, -- [1]
				9969, -- [2]
			},
		},
		["CHARGER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Charger",
			["icon"] = 132226,
			["id"] = {
				23214, -- [1]
			},
		},
		["GLYPHOFCLEAVING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Cleaving",
			["icon"] = 132918,
			["id"] = {
				57154, -- [1]
				58366, -- [2]
				58407, -- [3]
			},
		},
		["BLESSINGOFSANCTUARY"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				20911, -- [1]
				20912, -- [2]
				20913, -- [3]
				20914, -- [4]
				20948, -- [5]
				20949, -- [6]
				20950, -- [7]
				20951, -- [8]
				57319, -- [9]
				57320, -- [10]
				57321, -- [11]
				67480, -- [12]
			},
			["castTime"] = 0,
			["icon"] = 136051,
			["name"] = "Blessing of Sanctuary",
		},
		["HANDFULOFCOBALTBOLTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56349, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Handful of Cobalt Bolts",
		},
		["GNOMISHLIGHTNINGGENERATOR"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55039, -- [1]
				55069, -- [2]
				56469, -- [3]
			},
			["icon"] = 136050,
			["name"] = "Gnomish Lightning Generator",
		},
		["INNERVATE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Innervate",
			["icon"] = 136048,
			["id"] = {
				29166, -- [1]
				29167, -- [2]
			},
		},
		["COBALTTRIANGLESHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54550, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cobalt Triangle Shield",
		},
		["WEB"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				4167, -- [1]
				745, -- [2]
				4782, -- [3]
				4783, -- [4]
				4785, -- [5]
				6026, -- [6]
				6027, -- [7]
				6028, -- [8]
				12023, -- [9]
				28991, -- [10]
				71327, -- [11]
			},
			["castTime"] = 0,
			["icon"] = 136113,
			["name"] = "Web",
		},
		["GLYPHOFSAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Sap",
			["icon"] = 136243,
			["id"] = {
				56798, -- [1]
				57129, -- [2]
				57299, -- [3]
			},
		},
		["REVENGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Revenge",
			["icon"] = 132353,
			["id"] = {
				6572, -- [1]
				6573, -- [2]
				6574, -- [3]
				6575, -- [4]
				7379, -- [5]
				7380, -- [6]
				11600, -- [7]
				11601, -- [8]
				11602, -- [9]
				11603, -- [10]
				12170, -- [11]
				19130, -- [12]
				25288, -- [13]
				25355, -- [14]
				25960, -- [15]
				28844, -- [16]
				25269, -- [17]
				30357, -- [18]
				37517, -- [19]
				40392, -- [20]
				57823, -- [21]
			},
		},
		["REDEMPTION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 9408,
			["name"] = "Redemption",
			["icon"] = 135955,
			["id"] = {
				7328, -- [1]
				574, -- [2]
				7329, -- [3]
				10322, -- [4]
				10323, -- [5]
				10324, -- [6]
				10325, -- [7]
				20772, -- [8]
				20773, -- [9]
				20774, -- [10]
				20775, -- [11]
				39794, -- [12]
				48949, -- [13]
				48950, -- [14]
			},
		},
		["JOURNEYMANENGINEER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Journeyman Engineer",
			["icon"] = 136243,
			["id"] = {
				4040, -- [1]
			},
		},
		["RAPTORSTRIKE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2973, -- [1]
				2978, -- [2]
				14260, -- [3]
				14261, -- [4]
				14262, -- [5]
				14263, -- [6]
				14264, -- [7]
				14265, -- [8]
				14266, -- [9]
				14332, -- [10]
				14333, -- [11]
				14334, -- [12]
				14335, -- [13]
				14336, -- [14]
				14337, -- [15]
				14338, -- [16]
				27014, -- [17]
				31566, -- [18]
				32915, -- [19]
				48995, -- [20]
				48996, -- [21]
				63087, -- [22]
			},
			["icon"] = 132223,
			["name"] = "Raptor Strike",
		},
		["THORIUMRIFLE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["name"] = "Thorium Rifle",
			["icon"] = 136243,
			["id"] = {
				19792, -- [1]
			},
		},
		["GOLDENDRAENITERING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				31049, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Golden Draenite Ring",
		},
		["SARONITEAMBUSHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55179, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Saronite Ambusher",
		},
		["TELEPORTTHERAMORE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				49359, -- [1]
			},
			["icon"] = 135764,
			["name"] = "Teleport: Theramore",
		},
		["COPPERTUBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Copper Tube",
			["icon"] = 136243,
			["id"] = {
				3924, -- [1]
				3986, -- [2]
			},
		},
		["GRACEOFAIRTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				8835, -- [1]
				8837, -- [2]
				10627, -- [3]
				10628, -- [4]
				25359, -- [5]
				25401, -- [6]
				25966, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 136046,
			["name"] = "Grace of Air Totem",
		},
		["CONJUREFOOD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2822,
			["id"] = {
				587, -- [1]
				597, -- [2]
				608, -- [3]
				619, -- [4]
				990, -- [5]
				991, -- [6]
				1249, -- [7]
				1250, -- [8]
				1251, -- [9]
				6129, -- [10]
				6130, -- [11]
				6641, -- [12]
				8736, -- [13]
				10144, -- [14]
				10145, -- [15]
				10146, -- [16]
				10147, -- [17]
				28612, -- [18]
				28613, -- [19]
				27389, -- [20]
				33717, -- [21]
			},
			["icon"] = 133952,
			["name"] = "Conjure Food",
		},
		["GLYPHOFRAPIDCHARGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Rapid Charge",
			["icon"] = 132918,
			["id"] = {
				57162, -- [1]
				58355, -- [2]
				58409, -- [3]
			},
		},
		["SHADOWYTAROT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Shadowy Tarot",
			["icon"] = 132918,
			["id"] = {
				59491, -- [1]
			},
		},
		["BLOCK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				107, -- [1]
			},
			["icon"] = 132110,
			["name"] = "Block",
		},
		["SWORDGUARDEMBROIDERY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				55775, -- [1]
				55776, -- [2]
				55777, -- [3]
			},
			["icon"] = 236282,
			["name"] = "Swordguard Embroidery",
		},
		["SAVAGESARONITESKULLSHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55312, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Savage Saronite Skullshield",
		},
		["RUNECLOTHCLOAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runecloth Cloak",
			["icon"] = 132149,
			["id"] = {
				18409, -- [1]
			},
		},
		["ORNATESARONITEGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56553, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Ornate Saronite Gauntlets",
		},
		["GOBLINROCKETLAUNCHER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				30563, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Goblin Rocket Launcher",
		},
		["ARTISANLEATHERWORKER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Leatherworker",
			["icon"] = 133611,
			["id"] = {
				10663, -- [1]
			},
		},
		["VENOMWEBSPRAY"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				55508, -- [1]
				54706, -- [2]
				55505, -- [3]
				55506, -- [4]
				55507, -- [5]
				55509, -- [6]
			},
			["castTime"] = 0,
			["icon"] = 136113,
			["name"] = "Venom Web Spray",
		},
		["GLYPHOFHOLYLIGHT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Holy Light",
			["icon"] = 136243,
			["id"] = {
				54937, -- [1]
				54968, -- [2]
				55121, -- [3]
				57029, -- [4]
			},
		},
		["CREATESOULSTONELESSER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				20752, -- [1]
				20766, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 136210,
			["name"] = "Create Soulstone (Lesser)",
		},
		["ICEBANECHESTGUARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				61008, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Icebane Chestguard",
		},
		["TRUESILVERHEALINGRING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Truesilver Healing Ring",
			["icon"] = 136243,
			["id"] = {
				26885, -- [1]
			},
		},
		["RUNICLEATHERHEADBAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runic Leather Headband",
			["icon"] = 136243,
			["id"] = {
				19082, -- [1]
			},
		},
		["CURSEOFSHADOW"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				17862, -- [1]
				17865, -- [2]
				17937, -- [3]
				17938, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 136137,
			["name"] = "Curse of Shadow",
		},
		["BLACKMAGEWEAVEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Black Mageweave Boots",
			["icon"] = 132149,
			["id"] = {
				12073, -- [1]
				12116, -- [2]
			},
		},
		["SAVAGESARONITEGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55309, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Savage Saronite Gauntlets",
		},
		["GLYPHOFWHIRLWIND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				57172, -- [1]
				58370, -- [2]
				58390, -- [3]
			},
			["icon"] = 132918,
			["name"] = "Glyph of Whirlwind",
		},
		["ENCHANTBRACERBRAWN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				27899, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Brawn",
		},
		["SPIKEDCOBALTBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54948, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Spiked Cobalt Bracers",
		},
		["SMELTMITHRIL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Smelt Mithril",
			["icon"] = 136243,
			["id"] = {
				10097, -- [1]
				10099, -- [2]
			},
		},
		["GOBLINBEAMWELDER"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				67324, -- [1]
				67325, -- [2]
				67326, -- [3]
			},
			["icon"] = 136028,
			["name"] = "Goblin Beam Welder",
		},
		["FELIRONHAMMER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29558, -- [1]
			},
			["icon"] = 133043,
			["name"] = "Fel Iron Hammer",
		},
		["WICKEDLEATHERBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Wicked Leather Belt",
			["icon"] = 136243,
			["id"] = {
				19092, -- [1]
			},
		},
		["DISENGAGE"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				781, -- [1]
				6791, -- [2]
				14272, -- [3]
				14273, -- [4]
				14344, -- [5]
				14345, -- [6]
				56446, -- [7]
				57635, -- [8]
				57636, -- [9]
				60932, -- [10]
				60934, -- [11]
				61507, -- [12]
				61508, -- [13]
				68339, -- [14]
				68340, -- [15]
				65869, -- [16]
				65870, -- [17]
			},
			["icon"] = 132294,
			["name"] = "Disengage",
		},
		["SPICEBREAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Spice Bread",
			["icon"] = 134051,
			["id"] = {
				37836, -- [1]
			},
		},
		["BRIGHTSCARLETRUBY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				53947, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Bright Scarlet Ruby",
		},
		["PRISMATICSPHERE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				28027, -- [1]
			},
			["icon"] = 132872,
			["name"] = "Prismatic Sphere",
		},
		["DURABLENERUBHIDECAPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				60640, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Durable Nerubhide Cape",
		},
		["MITHRILCOIF"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Mithril Coif",
			["icon"] = 133137,
			["id"] = {
				9961, -- [1]
				9962, -- [2]
			},
		},
		["SNATCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53542, -- [1]
				50541, -- [2]
				53537, -- [3]
				53538, -- [4]
				53540, -- [5]
				53543, -- [6]
			},
			["castTime"] = 0,
			["icon"] = 136063,
			["name"] = "Snatch",
		},
		["GLYPHOFDISEASE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Disease",
			["icon"] = 136243,
			["id"] = {
				63334, -- [1]
				63959, -- [2]
				64267, -- [3]
			},
		},
		["FLYINGMACHINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				44153, -- [1]
				44155, -- [2]
			},
			["icon"] = 132240,
			["name"] = "Flying Machine",
		},
		["GHOSTWEAVEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Ghostweave Gloves",
			["icon"] = 132149,
			["id"] = {
				18413, -- [1]
			},
		},
		["FELIRONCHAINGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29552, -- [1]
			},
			["icon"] = 132945,
			["name"] = "Fel Iron Chain Gloves",
		},
		["NESINGWARY4000"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				60874, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Nesingwary 4000",
		},
		["BLASTWAVE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1831, -- [1]
				11113, -- [2]
				13018, -- [3]
				13019, -- [4]
				13020, -- [5]
				13021, -- [6]
				13023, -- [7]
				13024, -- [8]
				13025, -- [9]
				13026, -- [10]
				15091, -- [11]
				15744, -- [12]
				16046, -- [13]
				17145, -- [14]
				17277, -- [15]
				20229, -- [16]
				22424, -- [17]
				23039, -- [18]
				23113, -- [19]
				23331, -- [20]
				25049, -- [21]
				30092, -- [22]
				27133, -- [23]
				30600, -- [24]
				33061, -- [25]
				33933, -- [26]
				36278, -- [27]
				38064, -- [28]
				38536, -- [29]
				38712, -- [30]
				39001, -- [31]
				39038, -- [32]
				42944, -- [33]
				42945, -- [34]
				58970, -- [35]
				60290, -- [36]
				61362, -- [37]
				66044, -- [38]
				70407, -- [39]
			},
			["icon"] = 135903,
			["name"] = "Blast Wave",
		},
		["ARCANESHOT"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = -999500,
			["id"] = {
				3044, -- [1]
				3048, -- [2]
				14281, -- [3]
				14282, -- [4]
				14283, -- [5]
				14284, -- [6]
				14285, -- [7]
				14286, -- [8]
				14287, -- [9]
				14352, -- [10]
				14353, -- [11]
				14354, -- [12]
				14355, -- [13]
				14356, -- [14]
				14357, -- [15]
				14358, -- [16]
				27019, -- [17]
				34829, -- [18]
				35401, -- [19]
				36293, -- [20]
				36609, -- [21]
				36623, -- [22]
				38807, -- [23]
				49044, -- [24]
				49045, -- [25]
				51742, -- [26]
				55624, -- [27]
				58973, -- [28]
				69989, -- [29]
			},
			["icon"] = 132218,
			["name"] = "Arcane Shot",
		},
		["ENCHANTBOOTSMINORSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7863, -- [1]
				13391, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Boots - Minor Stamina",
		},
		["ACIDSPIT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				55753, -- [1]
				9591, -- [2]
				15653, -- [3]
				20657, -- [4]
				20821, -- [5]
				21059, -- [6]
				24334, -- [7]
				25052, -- [8]
				26050, -- [9]
				28969, -- [10]
				34290, -- [11]
				44477, -- [12]
				48132, -- [13]
				55749, -- [14]
				55750, -- [15]
				55751, -- [16]
				55752, -- [17]
				55754, -- [18]
				56098, -- [19]
				59270, -- [20]
				61597, -- [21]
				66880, -- [22]
			},
			["castTime"] = 0,
			["icon"] = 136007,
			["name"] = "Acid Spit",
		},
		["ENCHANTSHIELDTOUGHSHIELD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				27944, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Shield - Tough Shield",
		},
		["SPELLWEAVEROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56028, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Spellweave Robe",
		},
		["THORIUMBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Thorium Bracers",
			["icon"] = 132612,
			["id"] = {
				16644, -- [1]
			},
		},
		["BLACKARROW"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["id"] = {
				3674, -- [1]
				3675, -- [2]
				14296, -- [3]
				14363, -- [4]
				20733, -- [5]
				20734, -- [6]
				59712, -- [7]
				63668, -- [8]
				63669, -- [9]
				63670, -- [10]
				63671, -- [11]
				63672, -- [12]
				64102, -- [13]
			},
			["castTime"] = -999500,
			["icon"] = 136181,
			["name"] = "Black Arrow",
		},
		["ELIXIROFAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Agility",
			["icon"] = 136243,
			["id"] = {
				11449, -- [1]
				11483, -- [2]
			},
		},
		["BLACKDUSKWEAVELEGGINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				55925, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Black Duskweave Leggings",
		},
		["MIXOLOGY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Mixology",
			["icon"] = 134735,
			["id"] = {
				53042, -- [1]
			},
		},
		["ICEBORNEHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				60608, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Iceborne Helm",
		},
		["TELEPORTDARNASSUS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				3565, -- [1]
				3578, -- [2]
			},
			["icon"] = 135755,
			["name"] = "Teleport: Darnassus",
		},
		["ARCANEINTELLECT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				1459, -- [1]
				1460, -- [2]
				1461, -- [3]
				1472, -- [4]
				1473, -- [5]
				1474, -- [6]
				1475, -- [7]
				3065, -- [8]
				3066, -- [9]
				10156, -- [10]
				10157, -- [11]
				10158, -- [12]
				13326, -- [13]
				16876, -- [14]
				27126, -- [15]
				27393, -- [16]
				36880, -- [17]
				39235, -- [18]
				42995, -- [19]
				42999, -- [20]
				45525, -- [21]
			},
			["icon"] = 135932,
			["name"] = "Arcane Intellect",
		},
		["FIREGUARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34535, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Fireguard",
		},
		["WIZARDWEAVETURBAN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Wizardweave Turban",
			["icon"] = 132149,
			["id"] = {
				18450, -- [1]
			},
		},
		["INCINERATE"] = {
			["maxRange"] = 10,
			["minRange"] = 0,
			["id"] = {
				19397, -- [1]
				18459, -- [2]
				18460, -- [3]
				19396, -- [4]
				23308, -- [5]
				23309, -- [6]
				29722, -- [7]
				32231, -- [8]
				32707, -- [9]
				36832, -- [10]
				38401, -- [11]
				38918, -- [12]
				39083, -- [13]
				40239, -- [14]
				41960, -- [15]
				43971, -- [16]
				44519, -- [17]
				46043, -- [18]
				47837, -- [19]
				47838, -- [20]
				53493, -- [21]
				69973, -- [22]
			},
			["name"] = "Incinerate",
			["icon"] = 135813,
			["castTime"] = 0,
		},
		["APPRENTICEJEWELCRAFTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Jewelcrafter",
			["icon"] = 134071,
			["id"] = {
				25245, -- [1]
			},
		},
		["SCORPIDPOISON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				24587, -- [1]
				6411, -- [2]
				24583, -- [3]
				24584, -- [4]
				24586, -- [5]
				24588, -- [6]
				24589, -- [7]
				24640, -- [8]
				24641, -- [9]
				27060, -- [10]
				27361, -- [11]
				55728, -- [12]
			},
			["castTime"] = 0,
			["icon"] = 132274,
			["name"] = "Scorpid Poison",
		},
		["DARKARCTICCHESTPIECE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				51570, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Dark Arctic Chestpiece",
		},
		["MASTERFIRSTAID"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 18816,
			["id"] = {
				27029, -- [1]
				54255, -- [2]
			},
			["icon"] = 135966,
			["name"] = "Master First Aid",
		},
		["BLAZEGUARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34537, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Blazeguard",
		},
		["HURRICANE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Hurricane",
			["icon"] = 136018,
			["id"] = {
				16914, -- [1]
				16915, -- [2]
				17401, -- [3]
				17402, -- [4]
				17406, -- [5]
				24922, -- [6]
				27530, -- [7]
				27012, -- [8]
				32717, -- [9]
				40090, -- [10]
				42230, -- [11]
				42231, -- [12]
				42232, -- [13]
				42233, -- [14]
				48466, -- [15]
				48467, -- [16]
				55881, -- [17]
				63272, -- [18]
				63557, -- [19]
			},
		},
		["HEAVYGRINDINGSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Heavy Grinding Stone",
			["icon"] = 135245,
			["id"] = {
				3337, -- [1]
				3348, -- [2]
			},
		},
		["HATOFWINTRYDOOM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56018, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Hat of Wintry Doom",
		},
		["EXPERTHERBALIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Expert Herbalist",
			["icon"] = 136246,
			["id"] = {
				3571, -- [1]
			},
		},
		["GREATSTAMINA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				61686, -- [1]
				4187, -- [2]
				4188, -- [3]
				4189, -- [4]
				4190, -- [5]
				4191, -- [6]
				4192, -- [7]
				4193, -- [8]
				4194, -- [9]
				4195, -- [10]
				4196, -- [11]
				4197, -- [12]
				4198, -- [13]
				4199, -- [14]
				4200, -- [15]
				4201, -- [16]
				4202, -- [17]
				5041, -- [18]
				5042, -- [19]
				5048, -- [20]
				5049, -- [21]
				24533, -- [22]
				24534, -- [23]
				24535, -- [24]
				24536, -- [25]
				24537, -- [26]
				24538, -- [27]
				24539, -- [28]
				24540, -- [29]
				24541, -- [30]
				24636, -- [31]
				27364, -- [32]
				61687, -- [33]
				61688, -- [34]
			},
			["castTime"] = 0,
			["icon"] = 136112,
			["name"] = "Great Stamina",
		},
		["RUNEDETERNIUMROD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 30000,
			["name"] = "Runed Eternium Rod",
			["icon"] = 134923,
			["id"] = {
				32667, -- [1]
			},
		},
		["HEAVYBLASTINGPOWDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Heavy Blasting Powder",
			["icon"] = 136243,
			["id"] = {
				3945, -- [1]
				4006, -- [2]
			},
		},
		["CLOAKOFSHADOWS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				31224, -- [1]
				39666, -- [2]
				65961, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 136177,
			["name"] = "Cloak of Shadows",
		},
		["NERUBIANBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				60622, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Nerubian Bracers",
		},
		["SCROLLOFAGILITYVIII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				58483, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Agility VIII",
		},
		["LIONHEARTEXECUTIONER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				36259, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Lionheart Executioner",
		},
		["IRONBUCKLE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Iron Buckle",
			["icon"] = 133607,
			["id"] = {
				8768, -- [1]
				8769, -- [2]
			},
		},
		["SAVAGESARONITEBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55305, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Savage Saronite Bracers",
		},
		["BRONZESHORTSWORD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Bronze Shortsword",
			["icon"] = 135274,
			["id"] = {
				2742, -- [1]
				2759, -- [2]
			},
		},
		["MITHRILTUBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Mithril Tube",
			["icon"] = 136243,
			["id"] = {
				12589, -- [1]
				12632, -- [2]
			},
		},
		["GLYPHOFFOCUS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				62080, -- [1]
				62161, -- [2]
				62162, -- [3]
			},
			["icon"] = 136243,
			["name"] = "Glyph of Focus",
		},
		["CALLOFTHEWILD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53434, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 236159,
			["name"] = "Call of the Wild",
		},
		["ENCHANTBOOTSMINORSPEED"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13890, -- [1]
				13891, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Boots - Minor Speed",
		},
		["FIRENOVA"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				--1535, -- [1]
				8349, -- [2]
				8350, -- [3]
				8351, -- [4]
				8443, -- [5]
				8502, -- [6]
				8503, -- [7]
				8504, -- [8]
				8505, -- [9]
				8506, -- [10]
				8507, -- [11]
				8508, -- [12]
				8509, -- [13]
				11306, -- [14]
				11307, -- [15]
				11308, -- [16]
				11309, -- [17]
				11310, -- [18]
				11311, -- [19]
				11312, -- [20]
				11313, -- [21]
				11969, -- [22]
				11970, -- [23]
				12470, -- [24]
				16079, -- [25]
				16635, -- [26]
				17366, -- [27]
				18432, -- [28]
				20203, -- [29]
				20602, -- [30]
				23462, -- [31]
				26073, -- [32]
				--8498, -- [33]
				--8499, -- [34]
				--11314, -- [35]
				--11315, -- [36]
				25535, -- [37]
				25537, -- [38]
				25546, -- [39]
				25547, -- [40]
				30941, -- [41]
				32167, -- [42]
				33132, -- [43]
				33775, -- [44]
				37371, -- [45]
				38728, -- [46]
				43464, -- [47]
				46551, -- [48]
				61163, -- [49]
				61649, -- [50]
				61650, -- [51]
				61654, -- [52]
				61655, -- [53]
				61657, -- [54]
				69667, -- [55]
				78723, -- [56]
			},
			["icon"] = 135824,
			["name"] = "Fire Nova",
		},
		["APPRENTICEALCHEMIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Apprentice Alchemist",
			["icon"] = 136240,
			["id"] = {
				2275, -- [1]
			},
		},
		["SHACKLEUNDEAD"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				9484, -- [1]
				1425, -- [2]
				9485, -- [3]
				9486, -- [4]
				10955, -- [5]
				10956, -- [6]
				11444, -- [7]
				40135, -- [8]
				68342, -- [9]
			},
			["name"] = "Shackle Undead",
			["icon"] = 136091,
			["castTime"] = 1500,
		},
		["ENCHANTCLOAKMAJORARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				27961, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Major Armor",
		},
		["SCROLLOFAGILITYVII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				58482, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Agility VII",
		},
		["GLYPHOFWATERMASTERY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Water Mastery",
			["icon"] = 136243,
			["id"] = {
				55436, -- [1]
				57251, -- [2]
			},
		},
		["DEEPTHUNDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34548, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Deep Thunder",
		},
		["PORTALDALARAN"] = {
			["maxRange"] = 10,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				53142, -- [1]
				73324, -- [2]
			},
			["icon"] = 237508,
			["name"] = "Portal: Dalaran",
		},
		["SNAKETRAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				34600, -- [1]
				43449, -- [2]
				43485, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 132211,
			["name"] = "Snake Trap",
		},
		["COLDWEATHERFLYING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				54197, -- [1]
			},
			["icon"] = 135833,
			["name"] = "Cold Weather Flying",
		},
		["FROSTWOVENSHOULDERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55902, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostwoven Shoulders",
		},
		["FEAR"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["id"] = {
				5782, -- [1]
				654, -- [2]
				663, -- [3]
				1045, -- [4]
				1397, -- [5]
				5783, -- [6]
				6213, -- [7]
				6214, -- [8]
				6215, -- [9]
				6216, -- [10]
				12096, -- [11]
				12542, -- [12]
				22678, -- [13]
				26070, -- [14]
				26580, -- [15]
				27641, -- [16]
				27990, -- [17]
				29168, -- [18]
				30002, -- [19]
				26661, -- [20]
				29321, -- [21]
				30530, -- [22]
				30584, -- [23]
				30615, -- [24]
				31358, -- [25]
				31970, -- [26]
				32241, -- [27]
				33547, -- [28]
				33924, -- [29]
				34259, -- [30]
				38154, -- [31]
				38595, -- [32]
				38660, -- [33]
				39119, -- [34]
				39176, -- [35]
				39210, -- [36]
				39415, -- [37]
				41150, -- [38]
				46561, -- [39]
				51240, -- [40]
				59669, -- [41]
				65809, -- [42]
				68950, -- [43]
			},
			["name"] = "Fear",
			["icon"] = 136183,
			["castTime"] = 1500,
		},
		["BLOODRAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Bloodrage",
			["icon"] = 132277,
			["id"] = {
				2687, -- [1]
				2688, -- [2]
				29131, -- [3]
			},
		},
		["GOLDPOWERCORE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Gold Power Core",
			["icon"] = 136243,
			["id"] = {
				12584, -- [1]
				12628, -- [2]
			},
		},
		["FELCLOTHROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Felcloth Robe",
			["icon"] = 132149,
			["id"] = {
				18451, -- [1]
			},
		},
		["ICEBOUNDFORTITUDE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				48792, -- [1]
				58130, -- [2]
				58837, -- [3]
				66023, -- [4]
			},
			["icon"] = 237525,
			["name"] = "Icebound Fortitude",
		},
		["COARSESTONESTATUE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Coarse Stone Statue",
			["icon"] = 136243,
			["id"] = {
				32801, -- [1]
				32802, -- [2]
			},
		},
		["AZURESILKHOOD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Azure Silk Hood",
			["icon"] = 132149,
			["id"] = {
				8760, -- [1]
				8761, -- [2]
			},
		},
		["GLACIALROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				60993, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Glacial Robe",
		},
		["ENCHANTGLOVESAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13815, -- [1]
				13816, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Gloves - Agility",
		},
		["RUNEOFRAZORICE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				53343, -- [1]
			},
			["icon"] = 135842,
			["name"] = "Rune of Razorice",
		},
		["ENCHANTCHESTMINORHEALTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7420, -- [1]
				7422, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Minor Health",
		},
		["SHARKATTACK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				62760, -- [1]
				62759, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 133921,
			["name"] = "Shark Attack",
		},
		["GLYPHOFSLICEANDDICE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Slice and Dice",
			["icon"] = 136243,
			["id"] = {
				56810, -- [1]
				57132, -- [2]
				57303, -- [3]
			},
		},
		["GREENIRONBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Green Iron Bracers",
			["icon"] = 132605,
			["id"] = {
				3501, -- [1]
				3521, -- [2]
			},
		},
		["ENCHANTCLOAKDEFENSE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13635, -- [1]
				13636, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Defense",
		},
		["SMELTKHORIUM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				29361, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Smelt Khorium",
		},
		["ENCHANTCHESTSUPERSTATS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Chest - Super Stats",
			["icon"] = 136244,
			["id"] = {
				44623, -- [1]
			},
		},
		["ENCHANTWEAPONEXCEPTIONALAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Weapon - Exceptional Agility",
			["icon"] = 136244,
			["id"] = {
				44633, -- [1]
			},
		},
		["ENCHANTCHESTMANA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13607, -- [1]
				13609, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Mana",
		},
		["ENCHANTCHESTSTATS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13941, -- [1]
				13942, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Stats",
		},
		["LICKYOURWOUNDS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53426, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 132179,
			["name"] = "Lick Your Wounds",
		},
		["GLYPHOFREJUVENATION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Rejuvenation",
			["icon"] = 136243,
			["id"] = {
				54754, -- [1]
				54755, -- [2]
				54868, -- [3]
				56955, -- [4]
			},
		},
		["EXPLOSIVETRAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				13813, -- [1]
				13814, -- [2]
				14316, -- [3]
				14317, -- [4]
				14372, -- [5]
				14373, -- [6]
				27025, -- [7]
				43444, -- [8]
				49066, -- [9]
				49067, -- [10]
			},
			["icon"] = 135826,
			["name"] = "Explosive Trap",
		},
		["ENCHANTCHESTRESTOREMANAPRIME"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				33991, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Restore Mana Prime",
		},
		["ENCHANTGLOVESASSAULT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				33996, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Gloves - Assault",
		},
		["CUREDISEASE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				528, -- [1]
				1268, -- [2]
				2870, -- [3]
				2874, -- [4]
				28133, -- [5]
			},
			["name"] = "Cure Disease",
			["icon"] = 135935,
			["castTime"] = 0,
		},
		["FROSTPRESENCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				48263, -- [1]
				61261, -- [2]
			},
			["icon"] = 135773,
			["name"] = "Frost Presence",
		},
		["BRIGHTBLOODSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53835, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Bright Bloodstone",
		},
		["FADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				586, -- [1]
				1265, -- [2]
				9578, -- [3]
				9579, -- [4]
				9580, -- [5]
				9581, -- [6]
				9592, -- [7]
				9593, -- [8]
				10941, -- [9]
				10942, -- [10]
				10943, -- [11]
				10944, -- [12]
				12685, -- [13]
				20672, -- [14]
				44036, -- [15]
			},
			["name"] = "Fade",
			["icon"] = 135994,
			["castTime"] = 0,
		},
		["ARMYOFTHEDEAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				42650, -- [1]
				42651, -- [2]
				45486, -- [3]
				45487, -- [4]
				45493, -- [5]
				45494, -- [6]
				49099, -- [7]
				49100, -- [8]
				61382, -- [9]
				61383, -- [10]
				67761, -- [11]
				67762, -- [12]
			},
			["icon"] = 237511,
			["name"] = "Army of the Dead",
		},
		["GLYPHOFMAUL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Maul",
			["icon"] = 136243,
			["id"] = {
				54811, -- [1]
				54858, -- [2]
				56961, -- [3]
			},
		},
		["ENCHANTCLOAKLESSERFIRERESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7861, -- [1]
				7862, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Lesser Fire Resistance",
		},
		["GRAYWOOLENSHIRT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Gray Woolen Shirt",
			["icon"] = 132149,
			["id"] = {
				2406, -- [1]
				2424, -- [2]
			},
		},
		["EXPERTALCHEMIST"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Expert Alchemist",
			["icon"] = 136240,
			["id"] = {
				3465, -- [1]
			},
		},
		["JAGGEDDEEPPERIDOT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28917, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Jagged Deep Peridot",
		},
		["AZURESPELLTHREAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3763,
			["id"] = {
				55632, -- [1]
				56010, -- [2]
			},
			["icon"] = 136243,
			["name"] = "Azure Spellthread",
		},
		["LESSERMYSTICWAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 10000,
			["id"] = {
				14809, -- [1]
				14811, -- [2]
			},
			["icon"] = 135139,
			["name"] = "Lesser Mystic Wand",
		},
		["ARCTICCHESTPIECE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50944, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Arctic Chestpiece",
		},
		["ENCHANTBOOTSSUPERIORAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Boots - Superior Agility",
			["icon"] = 136244,
			["id"] = {
				44589, -- [1]
			},
		},
		["SEARINGTOTEM"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2075, -- [1]
				3599, -- [2]
				6363, -- [3]
				6364, -- [4]
				6365, -- [5]
				6379, -- [6]
				6380, -- [7]
				6381, -- [8]
				10437, -- [9]
				10438, -- [10]
				10439, -- [11]
				10440, -- [12]
				25533, -- [13]
				38116, -- [14]
				39588, -- [15]
				39591, -- [16]
				58699, -- [17]
				58703, -- [18]
				58704, -- [19]
				65997, -- [20]
			},
			["icon"] = 135825,
			["name"] = "Searing Totem",
		},
		["CRAFTEDSOLIDSHOT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Crafted Solid Shot",
			["icon"] = 136243,
			["id"] = {
				3947, -- [1]
				4008, -- [2]
			},
		},
		["ENCHANTGLOVESMAJORAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Gloves - Major Agility",
			["icon"] = 136244,
			["id"] = {
				44529, -- [1]
			},
		},
		["NIGHTSCAPEBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Nightscape Boots",
			["icon"] = 136247,
			["id"] = {
				10558, -- [1]
				10559, -- [2]
			},
		},
		["SHIELDSLAM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Shield Slam",
			["icon"] = 132357,
			["id"] = {
				8242, -- [1]
				15655, -- [2]
				23922, -- [3]
				23923, -- [4]
				23924, -- [5]
				23925, -- [6]
				23926, -- [7]
				23927, -- [8]
				23928, -- [9]
				25258, -- [10]
				29684, -- [11]
				30356, -- [12]
				30688, -- [13]
				46762, -- [14]
				47487, -- [15]
				47488, -- [16]
				49863, -- [17]
				59142, -- [18]
				69903, -- [19]
			},
		},
		["CUDGELOFSARONITEJUSTICE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				56280, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Cudgel of Saronite Justice",
		},
		["VOIDSPHERE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				28028, -- [1]
			},
			["icon"] = 132886,
			["name"] = "Void Sphere",
		},
		["ENCHANTCLOAKMINORRESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7454, -- [1]
				7441, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Minor Resistance",
		},
		["DIVE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				23145, -- [1]
				23146, -- [2]
				23147, -- [3]
				23148, -- [4]
				23149, -- [5]
				23150, -- [6]
				29903, -- [7]
				37156, -- [8]
				37588, -- [9]
				40279, -- [10]
				43187, -- [11]
			},
			["castTime"] = 0,
			["icon"] = 136126,
			["name"] = "Dive",
		},
		["SIMPLELINENBOOTS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Simple Linen Boots",
			["icon"] = 132149,
			["id"] = {
				12045, -- [1]
				12119, -- [2]
			},
		},
		["FROSTSAVAGEROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59587, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostsavage Robe",
		},
		["ENCHANT2HWEAPONGREATERSAVAGERY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant 2H Weapon - Greater Savagery",
			["icon"] = 136244,
			["id"] = {
				44630, -- [1]
			},
		},
		["BOXOFBOMBS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				56468, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Box of Bombs",
		},
		["WIZARDWEAVEROBE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Wizardweave Robe",
			["icon"] = 132149,
			["id"] = {
				18446, -- [1]
			},
		},
		["VAMPIRICTOUCH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				34914, -- [1]
				34916, -- [2]
				34917, -- [3]
				34919, -- [4]
				48159, -- [5]
				48160, -- [6]
				52723, -- [7]
				52724, -- [8]
				60501, -- [9]
				64085, -- [10]
				65490, -- [11]
			},
			["name"] = "Vampiric Touch",
			["icon"] = 135978,
			["castTime"] = 1500,
		},
		["ENCHANTCHESTEXCEPTIONALMANA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Chest - Exceptional Mana",
			["icon"] = 135913,
			["id"] = {
				27958, -- [1]
			},
		},
		["MITHRILFRAGBOMB"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 941,
			["name"] = "Mithril Frag Bomb",
			["icon"] = 135826,
			["id"] = {
				12421, -- [1]
				12603, -- [2]
				12638, -- [3]
			},
		},
		["SHADOWFIEND"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				34433, -- [1]
			},
			["name"] = "Shadowfiend",
			["icon"] = 136199,
			["castTime"] = 0,
		},
		["ENCHANTBOOTSICEWALKER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Boots - Icewalker",
			["icon"] = 136244,
			["id"] = {
				60623, -- [1]
			},
		},
		["ETHEREALINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Ethereal Ink",
			["icon"] = 132918,
			["id"] = {
				57713, -- [1]
			},
		},
		["ENCHANTBRACERASSAULT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				34002, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Assault",
		},
		["ENCHANTSHIELDLESSERSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13485, -- [1]
				13499, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Shield - Lesser Spirit",
		},
		["CELESTIALINK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Celestial Ink",
			["icon"] = 132918,
			["id"] = {
				57709, -- [1]
			},
		},
		["SOLIDSTONESTATUE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Solid Stone Statue",
			["icon"] = 134230,
			["id"] = {
				32804, -- [1]
				32808, -- [2]
			},
		},
		["ENCHANTCLOAKSUPERIORAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["name"] = "Enchant Cloak - Superior Agility",
			["icon"] = 136244,
			["id"] = {
				44500, -- [1]
			},
		},
		["HOWLINGBLAST"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				49184, -- [1]
				51409, -- [2]
				51410, -- [3]
				51411, -- [4]
				53536, -- [5]
				61061, -- [6]
				61066, -- [7]
			},
			["icon"] = 135833,
			["name"] = "Howling Blast",
		},
		["ENCHANTBRACERMINORAGILITY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7779, -- [1]
				7796, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Minor Agility",
		},
		["VENGEANCEBINDINGS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55298, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Vengeance Bindings",
		},
		["HORNEDCOBALTHELM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54949, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Horned Cobalt Helm",
		},
		["ASPECTOFTHEBEAST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				13161, -- [1]
				13162, -- [2]
				61669, -- [3]
			},
			["icon"] = 132252,
			["name"] = "Aspect of the Beast",
		},
		["VIPERSTING"] = {
			["maxRange"] = 35,
			["minRange"] = 5,
			["castTime"] = -999500,
			["id"] = {
				3034, -- [1]
				2898, -- [2]
				14279, -- [3]
				14280, -- [4]
				14350, -- [5]
				14351, -- [6]
				31407, -- [7]
				37551, -- [8]
				39413, -- [9]
				65881, -- [10]
			},
			["icon"] = 132157,
			["name"] = "Viper Sting",
		},
		["RUNEOFSWORDSHATTERING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				53323, -- [1]
			},
			["icon"] = 132269,
			["name"] = "Rune of Swordshattering",
		},
		["ASPECTOFTHEPACK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				13159, -- [1]
				13160, -- [2]
			},
			["icon"] = 132267,
			["name"] = "Aspect of the Pack",
		},
		["ICEBANETREADS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				61010, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Icebane Treads",
		},
		["ENCHANTBRACERMAJORINTELLECT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				34001, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Major Intellect",
		},
		["DUSTCLOUD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				50285, -- [1]
				7272, -- [2]
				26072, -- [3]
				54404, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 132156,
			["name"] = "Dust Cloud",
		},
		["DRUMSOFTHEWILD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				69388, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Drums of the Wild",
		},
		["BOLTOFWOOLENCLOTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Bolt of Woolen Cloth",
			["icon"] = 136249,
			["id"] = {
				2964, -- [1]
				2966, -- [2]
			},
		},
		["FINDMINERALS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				2580, -- [1]
				8388, -- [2]
				8389, -- [3]
			},
			["icon"] = 136025,
			["name"] = "Find Minerals",
		},
		["GLYPHOFGOUGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Gouge",
			["icon"] = 136243,
			["id"] = {
				56809, -- [1]
				57125, -- [2]
				57295, -- [3]
			},
		},
		["HEAVYARMORKIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Heavy Armor Kit",
			["icon"] = 136247,
			["id"] = {
				3780, -- [1]
				3781, -- [2]
			},
		},
		["COMMANDINGSHOUT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Commanding Shout",
			["icon"] = 132351,
			["id"] = {
				469, -- [1]
				22440, -- [2]
				45517, -- [3]
				47439, -- [4]
				47440, -- [5]
			},
		},
		["EYESOFTHEBEAST"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 1882,
			["id"] = {
				1002, -- [1]
				2899, -- [2]
			},
			["icon"] = 132150,
			["name"] = "Eyes of the Beast",
		},
		["GURUSELIXIR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53749, -- [1]
				53848, -- [2]
			},
			["icon"] = 134735,
			["name"] = "Guru's Elixir",
		},
		["GRACEOFTHEMANTIS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53450, -- [1]
				53451, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 133571,
			["name"] = "Grace of the Mantis",
		},
		["SHADOWWORDDEATH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				32379, -- [1]
				32409, -- [2]
				32996, -- [3]
				41375, -- [4]
				47697, -- [5]
				48157, -- [6]
				48158, -- [7]
				51818, -- [8]
				56920, -- [9]
			},
			["name"] = "Shadow Word: Death",
			["icon"] = 136149,
			["castTime"] = 0,
		},
		["GEMCUTTING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				28875, -- [1]
			},
			["icon"] = 135998,
			["name"] = "Gemcutting",
		},
		["THUNDERSTORM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				51490, -- [1]
				52717, -- [2]
				53071, -- [3]
				55825, -- [4]
				57784, -- [5]
				59154, -- [6]
				59156, -- [7]
				59158, -- [8]
				59159, -- [9]
				60010, -- [10]
				71935, -- [11]
			},
			["icon"] = 237589,
			["name"] = "Thunderstorm",
		},
		["GLYPHOFSHADOWBURN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Shadowburn",
			["icon"] = 136243,
			["id"] = {
				56229, -- [1]
				56295, -- [2]
				57272, -- [3]
			},
		},
		["WOOLENBAG"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Woolen Bag",
			["icon"] = 136249,
			["id"] = {
				3757, -- [1]
				3785, -- [2]
			},
		},
		["CURSEOFAGONY"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				980, -- [1]
				981, -- [2]
				1014, -- [3]
				1015, -- [4]
				1029, -- [5]
				1296, -- [6]
				1297, -- [7]
				6217, -- [8]
				6218, -- [9]
				11711, -- [10]
				11712, -- [11]
				11713, -- [12]
				11714, -- [13]
				11715, -- [14]
				11716, -- [15]
				14868, -- [16]
				14875, -- [17]
				17771, -- [18]
				18266, -- [19]
				18671, -- [20]
				27218, -- [21]
				29930, -- [22]
				32418, -- [23]
				37334, -- [24]
				39672, -- [25]
				46190, -- [26]
				47863, -- [27]
				47864, -- [28]
				70391, -- [29]
				65814, -- [30]
				69404, -- [31]
			},
			["name"] = "Curse of Agony",
			["icon"] = 136139,
			["castTime"] = 0,
		},
		["LUNARCRESCENT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 50000,
			["id"] = {
				34543, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Lunar Crescent",
		},
		["TRUESHOTAURA"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				19506, -- [1]
				1563, -- [2]
				20905, -- [3]
				20906, -- [4]
				20938, -- [5]
				31519, -- [6]
			},
			["icon"] = 132329,
			["name"] = "Trueshot Aura",
		},
		["ASPECTOFTHEVIPER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				34074, -- [1]
				34075, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132160,
			["name"] = "Aspect of the Viper",
		},
		["PORTALTHERAMORE"] = {
			["maxRange"] = 10,
			["minRange"] = 0,
			["castTime"] = 9408,
			["id"] = {
				49360, -- [1]
			},
			["icon"] = 135749,
			["name"] = "Portal: Theramore",
		},
		["NOISEMACHINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				56467, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Noise Machine",
		},
		["SCROLLOFSTRENGTHVII"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				58490, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Scroll of Strength VII",
		},
		["BLACKMAGEWEAVEGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Black Mageweave Gloves",
			["icon"] = 132149,
			["id"] = {
				12053, -- [1]
				12104, -- [2]
			},
		},
		["SHADOWFLAME"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				37377, -- [1]
				22539, -- [2]
				22682, -- [3]
				22972, -- [4]
				22975, -- [5]
				22976, -- [6]
				22977, -- [7]
				22978, -- [8]
				22979, -- [9]
				22980, -- [10]
				22981, -- [11]
				22982, -- [12]
				22983, -- [13]
				22984, -- [14]
				22985, -- [15]
				22986, -- [16]
				22992, -- [17]
				22993, -- [18]
				37378, -- [19]
				47897, -- [20]
				47960, -- [21]
				51337, -- [22]
				51338, -- [23]
				61290, -- [24]
				61291, -- [25]
			},
			["name"] = "Shadowflame",
			["icon"] = 136243,
			["castTime"] = 0,
		},
		["RUNECLOTHTUNIC"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runecloth Tunic",
			["icon"] = 132149,
			["id"] = {
				18407, -- [1]
			},
		},
		["QUICKSUNCRYSTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				53856, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Quick Sun Crystal",
		},
		["CIRCLEOFHEALING"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				34861, -- [1]
				34863, -- [2]
				34864, -- [3]
				34865, -- [4]
				34866, -- [5]
				41455, -- [6]
				48088, -- [7]
				48089, -- [8]
				49306, -- [9]
				61964, -- [10]
			},
			["name"] = "Circle of Healing",
			["icon"] = 135887,
			["castTime"] = 0,
		},
		["EMBOSSEDLEATHERCLOAK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Embossed Leather Cloak",
			["icon"] = 136247,
			["id"] = {
				2162, -- [1]
				2178, -- [2]
			},
		},
		["GOBLINDEVILEDCLAMS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Goblin Deviled Clams",
			["icon"] = 134433,
			["id"] = {
				6500, -- [1]
				6503, -- [2]
			},
		},
		["PICKLOCK"] = {
			["maxRange"] = 5,
			["minRange"] = 0,
			["id"] = {
				1804, -- [1]
				6461, -- [2]
				6463, -- [3]
				6480, -- [4]
			},
			["castTime"] = 5000,
			["icon"] = 136058,
			["name"] = "Pick Lock",
		},
		["ICEBORNECHESTGUARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				50938, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Iceborne Chestguard",
		},
		["HEMORRHAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				16511, -- [1]
				6185, -- [2]
				13027, -- [3]
				17347, -- [4]
				17348, -- [5]
				26864, -- [6]
				30478, -- [7]
				37331, -- [8]
				45897, -- [9]
				48660, -- [10]
				65954, -- [11]
			},
			["castTime"] = 0,
			["icon"] = 136168,
			["name"] = "Hemorrhage",
		},
		["EXPERTFIRSTAID"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 18816,
			["name"] = "Expert First Aid",
			["icon"] = 135966,
			["id"] = {
				19903, -- [1]
				7925, -- [2]
				54254, -- [3]
			},
		},
		["DRAINLIFE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				689, -- [1]
				699, -- [2]
				709, -- [3]
				714, -- [4]
				725, -- [5]
				736, -- [6]
				1367, -- [7]
				1368, -- [8]
				1369, -- [9]
				7651, -- [10]
				7652, -- [11]
				7653, -- [12]
				11699, -- [13]
				11700, -- [14]
				11701, -- [15]
				11702, -- [16]
				12693, -- [17]
				16375, -- [18]
				16414, -- [19]
				16608, -- [20]
				17173, -- [21]
				17238, -- [22]
				17620, -- [23]
				18084, -- [24]
				18557, -- [25]
				18815, -- [26]
				18817, -- [27]
				20743, -- [28]
				21170, -- [29]
				24300, -- [30]
				24435, -- [31]
				24585, -- [32]
				24618, -- [33]
				26693, -- [34]
				27994, -- [35]
				29155, -- [36]
				27219, -- [37]
				27220, -- [38]
				30412, -- [39]
				34107, -- [40]
				34696, -- [41]
				35748, -- [42]
				36224, -- [43]
				36655, -- [44]
				36825, -- [45]
				37992, -- [46]
				38817, -- [47]
				39676, -- [48]
				43417, -- [49]
				44294, -- [50]
				46155, -- [51]
				46291, -- [52]
				46466, -- [53]
				47857, -- [54]
				55646, -- [55]
				64159, -- [56]
				64160, -- [57]
				69066, -- [58]
				71838, -- [59]
				71839, -- [60]
			},
			["name"] = "Drain Life",
			["icon"] = 136169,
			["castTime"] = 0,
		},
		["COPPERMACE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["name"] = "Copper Mace",
			["icon"] = 133476,
			["id"] = {
				2737, -- [1]
				2754, -- [2]
			},
		},
		["SHADOWWARD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				6229, -- [1]
				535, -- [2]
				6232, -- [3]
				11739, -- [4]
				11740, -- [5]
				11741, -- [6]
				11742, -- [7]
				28610, -- [8]
				28611, -- [9]
				47890, -- [10]
				47891, -- [11]
			},
			["name"] = "Shadow Ward",
			["icon"] = 136121,
			["castTime"] = 0,
		},
		["REVIVE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Revive",
			["icon"] = 135955,
			["id"] = {
				24341, -- [1]
				50763, -- [2]
				50764, -- [3]
				50765, -- [4]
				50766, -- [5]
				50767, -- [6]
				50768, -- [7]
				50769, -- [8]
				51918, -- [9]
			},
		},
		["COPPERDAGGER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Copper Dagger",
			["icon"] = 135650,
			["id"] = {
				8880, -- [1]
				8881, -- [2]
			},
		},
		["FLASKOFENDLESSRAGE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				53760, -- [1]
				53903, -- [2]
			},
			["icon"] = 236880,
			["name"] = "Flask of Endless Rage",
		},
		["BRILLIANTSARONITEGAUNTLETS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55056, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Brilliant Saronite Gauntlets",
		},
		["GLYPHOFARCANESHOT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Arcane Shot",
			["icon"] = 136243,
			["id"] = {
				56841, -- [1]
				56870, -- [2]
				56995, -- [3]
				61389, -- [4]
			},
		},
		["CHAOSBOLT"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				50796, -- [1]
				51287, -- [2]
				59170, -- [3]
				59171, -- [4]
				59172, -- [5]
				69576, -- [6]
			},
			["name"] = "Chaos Bolt",
			["icon"] = 236291,
			["castTime"] = 2500,
		},
		["SAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				2070, -- [1]
				652, -- [2]
				6770, -- [3]
				6771, -- [4]
				11297, -- [5]
				11298, -- [6]
				30980, -- [7]
				51724, -- [8]
			},
			["castTime"] = 0,
			["icon"] = 132310,
			["name"] = "Sap",
		},
		["ARTISANJEWELCRAFTER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Artisan Jewelcrafter",
			["icon"] = 134073,
			["id"] = {
				28899, -- [1]
			},
		},
		["CREATEHEALTHSTONE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				5699, -- [1]
				1049, -- [2]
				5700, -- [3]
				23813, -- [4]
				23814, -- [5]
				23815, -- [6]
				28023, -- [7]
				--6201, -- [8]
				--6202, -- [9]
				--11729, -- [10]
				27230, -- [12]
				47871, -- [13]
				47878, -- [14]
			},
			["name"] = "Create Healthstone",
			["icon"] = 135230,
			["castTime"] = 3000,
		},
		["DISARMTRAP"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["id"] = {
				1842, -- [1]
				1845, -- [2]
			},
			["castTime"] = 1000,
			["icon"] = 136162,
			["name"] = "Disarm Trap",
		},
		["EXPOSEARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				8647, -- [1]
				8648, -- [2]
				8649, -- [3]
				8650, -- [4]
				8651, -- [5]
				8652, -- [6]
				11197, -- [7]
				11198, -- [8]
				11199, -- [9]
				11200, -- [10]
				26866, -- [11]
				48669, -- [12]
				60842, -- [13]
			},
			["castTime"] = 0,
			["icon"] = 132354,
			["name"] = "Expose Armor",
		},
		["SEDUCTION"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				6358, -- [1]
				6359, -- [2]
				20407, -- [3]
				29490, -- [4]
				30850, -- [5]
				31865, -- [6]
			},
			["castTime"] = 1424,
			["icon"] = 136175,
			["name"] = "Seduction",
		},
		["ARCTICWRISTGUARDS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 2000,
			["id"] = {
				51571, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Arctic Wristguards",
		},
		["MINDSOOTHE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				453, -- [1]
				8126, -- [2]
				8192, -- [3]
				8193, -- [4]
				10953, -- [5]
				10954, -- [6]
			},
			["name"] = "Mind Soothe",
			["icon"] = 135933,
			["castTime"] = 0,
		},
		["SACREDSHIELD"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Sacred Shield",
			["icon"] = 236249,
			["id"] = {
				53601, -- [1]
				58597, -- [2]
			},
		},
		["ENCHANT2HWEAPONLESSERIMPACT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13529, -- [1]
				13531, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant 2H Weapon - Lesser Impact",
		},
		["ENCHANTCLOAKLESSERPROTECTION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13421, -- [1]
				13422, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Cloak - Lesser Protection",
		},
		["SOVEREIGNSHADOWDRAENITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				28936, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Sovereign Shadow Draenite",
		},
		["SWIFTFLIGHTFORM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Swift Flight Form",
			["icon"] = 132128,
			["id"] = {
				40120, -- [1]
				40123, -- [2]
			},
		},
		["GLYPHOFDARKDEATH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Dark Death",
			["icon"] = 136243,
			["id"] = {
				63333, -- [1]
				63958, -- [2]
				64266, -- [3]
			},
		},
		["HEAVYQUIVER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Heavy Quiver",
			["icon"] = 136247,
			["id"] = {
				9193, -- [1]
				9209, -- [2]
			},
		},
		["ROAROFSACRIFICE"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				53480, -- [1]
				67481, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132121,
			["name"] = "Roar of Sacrifice",
		},
		["CURSEOFTONGUES"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				1714, -- [1]
				956, -- [2]
				5736, -- [3]
				11719, -- [4]
				11720, -- [5]
				12889, -- [6]
				13338, -- [7]
				15470, -- [8]
				25195, -- [9]
			},
			["name"] = "Curse of Tongues",
			["icon"] = 136140,
			["castTime"] = 0,
		},
		["MASTERSINSCRIPTIONOFTHEAXE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 4000,
			["id"] = {
				61117, -- [1]
			},
			["icon"] = 237171,
			["name"] = "Master's Inscription of the Axe",
		},
		["GLYPHOFICYTOUCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Glyph of Icy Touch",
			["icon"] = 132918,
			["id"] = {
				57219, -- [1]
				58631, -- [2]
				58718, -- [3]
			},
		},
		["DIVINEHYMN"] = {
			["maxRange"] = 40,
			["minRange"] = 0,
			["id"] = {
				64843, -- [1]
				64844, -- [2]
				70619, -- [3]
			},
			["name"] = "Divine Hymn",
			["icon"] = 237540,
			["castTime"] = 0,
		},
		["EVASION"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				4086, -- [1]
				5277, -- [2]
				5278, -- [3]
				15087, -- [4]
				26669, -- [5]
				31379, -- [6]
				37683, -- [7]
				38541, -- [8]
				70190, -- [9]
				67354, -- [10]
				67378, -- [11]
				67380, -- [12]
			},
			["castTime"] = 0,
			["icon"] = 136205,
			["name"] = "Evasion",
		},
		["MONSTROUSBITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				55495, -- [1]
				54680, -- [2]
				55496, -- [3]
				55497, -- [4]
				55498, -- [5]
				55499, -- [6]
			},
			["castTime"] = 0,
			["icon"] = 133726,
			["name"] = "Monstrous Bite",
		},
		["DAGGERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1180, -- [1]
				15988, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 132321,
			["name"] = "Daggers",
		},
		["ENCHANTWEAPONLESSERSTRIKING"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13503, -- [1]
				13504, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Weapon - Lesser Striking",
		},
		["GREENWOOLENVEST"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Green Woolen Vest",
			["icon"] = 136249,
			["id"] = {
				2399, -- [1]
				2421, -- [2]
			},
		},
		["CULLINGTHEHERD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				61680, -- [1]
				52858, -- [2]
				61681, -- [3]
				70893, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 237401,
			["name"] = "Culling the Herd",
		},
		["STURDYCOBALTQUICKBLADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				55200, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Sturdy Cobalt Quickblade",
		},
		["LIGHTEARTHFORGEDBLADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				36125, -- [1]
			},
			["icon"] = 135411,
			["name"] = "Light Earthforged Blade",
		},
		["GOBLINDRAGONGUN"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				12908, -- [1]
				12919, -- [2]
				13183, -- [3]
				13184, -- [4]
				13466, -- [5]
				13479, -- [6]
				21833, -- [7]
				21910, -- [8]
				22739, -- [9]
				22741, -- [10]
				27603, -- [11]
				27604, -- [12]
				29513, -- [13]
				44272, -- [14]
				44273, -- [15]
				46185, -- [16]
				46186, -- [17]
			},
			["icon"] = 136243,
			["name"] = "Goblin Dragon Gun",
		},
		["SPIKEDCOBALTCHESTPIECE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54944, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Spiked Cobalt Chestpiece",
		},
		["RUNICLEATHERBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Runic Leather Bracers",
			["icon"] = 136243,
			["id"] = {
				19065, -- [1]
			},
		},
		["BLOODPACT"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["id"] = {
				27268, -- [1]
				6307, -- [2]
				7804, -- [3]
				7805, -- [4]
				7871, -- [5]
				7872, -- [6]
				7873, -- [7]
				11766, -- [8]
				11767, -- [9]
				11768, -- [10]
				11769, -- [11]
				20318, -- [12]
				20319, -- [13]
				20320, -- [14]
				20321, -- [15]
				20397, -- [16]
				47982, -- [17]
			},
			["castTime"] = 0,
			["icon"] = 136124,
			["name"] = "Blood Pact",
		},
		["SMELTBRONZE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["name"] = "Smelt Bronze",
			["icon"] = 136243,
			["id"] = {
				2659, -- [1]
				3314, -- [2]
			},
		},
		["HEAVYWOOLENGLOVES"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Heavy Woolen Gloves",
			["icon"] = 132149,
			["id"] = {
				3843, -- [1]
				3879, -- [2]
			},
		},
		["WOLVERINEBITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53508, -- [1]
			},
			["castTime"] = 0,
			["icon"] = 132131,
			["name"] = "Wolverine Bite",
		},
		["DEVOURMAGIC"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				27276, -- [1]
				17012, -- [2]
				19505, -- [3]
				19731, -- [4]
				19734, -- [5]
				19736, -- [6]
				19737, -- [7]
				19738, -- [8]
				19739, -- [9]
				20426, -- [10]
				20427, -- [11]
				20428, -- [12]
				27277, -- [13]
				27495, -- [14]
				27496, -- [15]
				48011, -- [16]
				67518, -- [17]
			},
			["castTime"] = 0,
			["icon"] = 136075,
			["name"] = "Devour Magic",
		},
		["EAGLEEYE"] = {
			["maxRange"] = 50000,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				6197, -- [1]
				6198, -- [2]
			},
			["icon"] = 132172,
			["name"] = "Eagle Eye",
		},
		["FELIRONCHAINBRACERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				29553, -- [1]
			},
			["icon"] = 132612,
			["name"] = "Fel Iron Chain Bracers",
		},
		["TREMORTOTEM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				8143, -- [1]
				8144, -- [2]
				65992, -- [3]
			},
			["icon"] = 136108,
			["name"] = "Tremor Totem",
		},
		["ENCHANTGLOVESGREATERSTRENGTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				20013, -- [1]
			},
			["icon"] = 135913,
			["name"] = "Enchant Gloves - Greater Strength",
		},
		["SARONITEDEFENDER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				54557, -- [1]
			},
			["icon"] = 136241,
			["name"] = "Saronite Defender",
		},
		["PHASESHIFT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				4511, -- [1]
				4630, -- [2]
				8611, -- [3]
				8612, -- [4]
				20329, -- [5]
				29309, -- [6]
				29315, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 136164,
			["name"] = "Phase Shift",
		},
		["MITHRILFILIGREE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["name"] = "Mithril Filigree",
			["icon"] = 136243,
			["id"] = {
				25615, -- [1]
			},
		},
		["WISPSPIRIT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Wisp Spirit",
			["icon"] = 136116,
			["id"] = {
				20585, -- [1]
			},
		},
		["BOOKOFCLEVERTRICKS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["id"] = {
				59496, -- [1]
			},
			["icon"] = 132918,
			["name"] = "Book of Clever Tricks",
		},
		["SWIPE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53532, -- [1]
				769, -- [2]
				779, -- [3]
				780, -- [4]
				1432, -- [5]
				1433, -- [6]
				3139, -- [7]
				9754, -- [8]
				9755, -- [9]
				9908, -- [10]
				9909, -- [11]
				27554, -- [12]
				31279, -- [13]
				50256, -- [14]
				53498, -- [15]
				53526, -- [16]
				53528, -- [17]
				53529, -- [18]
				53533, -- [19]
			},
			["castTime"] = 0,
			["icon"] = 134296,
			["name"] = "Swipe",
		},
		["ENCHANTCHESTHEALTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				7857, -- [1]
				7858, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Chest - Health",
		},
		["SUMMONWATERELEMENTAL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				31687, -- [1]
				17162, -- [2]
				35593, -- [3]
				36459, -- [4]
				38622, -- [5]
				40130, -- [6]
				45067, -- [7]
				70907, -- [8]
				70908, -- [9]
			},
			["icon"] = 135862,
			["name"] = "Summon Water Elemental",
		},
		["OWLSFOCUS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53516, -- [1]
				53514, -- [2]
				53515, -- [3]
			},
			["castTime"] = 0,
			["icon"] = 132192,
			["name"] = "Owl's Focus",
		},
		["ARCANEMISSILES"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				5143, -- [1]
				5144, -- [2]
				5145, -- [3]
				5146, -- [4]
				5147, -- [5]
				5148, -- [6]
				6631, -- [7]
				6632, -- [8]
				6637, -- [9]
				7269, -- [10]
				7270, -- [11]
				8416, -- [12]
				8417, -- [13]
				8418, -- [14]
				8419, -- [15]
				8420, -- [16]
				8421, -- [17]
				10211, -- [18]
				10212, -- [19]
				10213, -- [20]
				10214, -- [21]
				10273, -- [22]
				10274, -- [23]
				15735, -- [24]
				15736, -- [25]
				15790, -- [26]
				15791, -- [27]
				22272, -- [28]
				22273, -- [29]
				25345, -- [30]
				25346, -- [31]
				25416, -- [32]
				25979, -- [33]
				31751, -- [34]
				27075, -- [35]
				27076, -- [36]
				29955, -- [37]
				29956, -- [38]
				31742, -- [39]
				31743, -- [40]
				33031, -- [41]
				33419, -- [42]
				33462, -- [43]
				33552, -- [44]
				33553, -- [45]
				33832, -- [46]
				33833, -- [47]
				33988, -- [48]
				33989, -- [49]
				34446, -- [50]
				34447, -- [51]
				35033, -- [52]
				35034, -- [53]
				38263, -- [54]
				38264, -- [55]
				38699, -- [56]
				38700, -- [57]
				38703, -- [58]
				38704, -- [59]
				39414, -- [60]
				42843, -- [61]
				42844, -- [62]
				42845, -- [63]
				42846, -- [64]
				58529, -- [65]
				58531, -- [66]
				61592, -- [67]
				61593, -- [68]
			},
			["icon"] = 136096,
			["name"] = "Arcane Missiles",
		},
		["ELIXIROFDEFENSE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["name"] = "Elixir of Defense",
			["icon"] = 136243,
			["id"] = {
				3177, -- [1]
				3186, -- [2]
			},
		},
		["DRAGONSTOMPERS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 12500,
			["id"] = {
				60605, -- [1]
			},
			["icon"] = 136247,
			["name"] = "Dragonstompers",
		},
		["GLYPHOFREBIRTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Glyph of Rebirth",
			["icon"] = 136243,
			["id"] = {
				54733, -- [1]
				54866, -- [2]
				56953, -- [3]
			},
		},
		["SHADOWBITE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				54051, -- [1]
				54049, -- [2]
				54050, -- [3]
				54052, -- [4]
				54053, -- [5]
			},
			["castTime"] = 0,
			["icon"] = 136214,
			["name"] = "Shadow Bite",
		},
		["LASTSTAND"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				53478, -- [1]
				12975, -- [2]
				12976, -- [3]
				53479, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 136088,
			["name"] = "Last Stand",
		},
		["DEMONICFRENZY"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				32850, -- [1]
				23257, -- [2]
				32851, -- [3]
				32852, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 136146,
			["name"] = "Demonic Frenzy",
		},
		["BLOODTAP"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				7122, -- [1]
				28470, -- [2]
				45529, -- [3]
				51135, -- [4]
				54790, -- [5]
			},
			["icon"] = 132278,
			["name"] = "Blood Tap",
		},
		["TRANSMUTETITANIUM"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				60350, -- [1]
			},
			["icon"] = 237045,
			["name"] = "Transmute: Titanium",
		},
		["DUSKWEAVEBELT"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				55914, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Duskweave Belt",
		},
		["CREATEHEALTHSTONEGREATER"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["id"] = {
				5702, -- [1]
				11729, -- [2]
				23816, -- [3]
				23817, -- [4]
				23818, -- [5]
			},
			["castTime"] = 0,
			["icon"] = 135230,
			["name"] = "Create Healthstone (Greater)",
		},
		["DARKJADEFOCUSINGLENS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				56205, -- [1]
			},
			["icon"] = 134071,
			["name"] = "Dark Jade Focusing Lens",
		},
		["ICEBARRIER"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				11426, -- [1]
				2890, -- [2]
				13031, -- [3]
				13032, -- [4]
				13033, -- [5]
				13037, -- [6]
				13038, -- [7]
				13039, -- [8]
				27134, -- [9]
				33245, -- [10]
				33405, -- [11]
				43038, -- [12]
				43039, -- [13]
				69787, -- [14]
			},
			["icon"] = 135988,
			["name"] = "Ice Barrier",
		},
		["NORTHRENDALCHEMYRESEARCH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 10000,
			["id"] = {
				60893, -- [1]
			},
			["icon"] = 136240,
			["name"] = "Northrend Alchemy Research",
		},
		["BLESSINGOFSACRIFICE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				6940, -- [1]
				6941, -- [2]
				20729, -- [3]
				20730, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 135966,
			["name"] = "Blessing of Sacrifice",
		},
		["ENCHANTBRACERGREATERSTRENGTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 5000,
			["id"] = {
				13939, -- [1]
				13940, -- [2]
			},
			["icon"] = 135913,
			["name"] = "Enchant Bracer - Greater Strength",
		},
		["TURNUNDEAD"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				1011, -- [1]
				2878, -- [2]
				5253, -- [3]
				5627, -- [4]
				5629, -- [5]
				10326, -- [6]
				10327, -- [7]
				19725, -- [8]
			},
			["castTime"] = 3000,
			["icon"] = 136235,
			["name"] = "Turn Undead",
		},
		["FEIGNDEATH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				5384, -- [1]
				5385, -- [2]
				28728, -- [3]
				37493, -- [4]
				42557, -- [5]
				51329, -- [6]
				57626, -- [7]
				71598, -- [8]
				67691, -- [9]
			},
			["icon"] = 132293,
			["name"] = "Feign Death",
		},
		["DEADLYBLUNDERBUSS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Deadly Blunderbuss",
			["icon"] = 136243,
			["id"] = {
				3936, -- [1]
				3998, -- [2]
			},
		},
		["LAVABREATH"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				58609, -- [1]
				19272, -- [2]
				21333, -- [3]
				38814, -- [4]
				58604, -- [5]
				58605, -- [6]
				58607, -- [7]
				58608, -- [8]
				58610, -- [9]
				58611, -- [10]
			},
			["castTime"] = 0,
			["icon"] = 135831,
			["name"] = "Lava Breath",
		},
		["LIGHTNINGBREATH"] = {
			["maxRange"] = 20,
			["minRange"] = 0,
			["id"] = {
				25009, -- [1]
				15797, -- [2]
				17157, -- [3]
				20535, -- [4]
				20536, -- [5]
				20543, -- [6]
				20627, -- [7]
				20630, -- [8]
				24844, -- [9]
				24845, -- [10]
				25008, -- [11]
				25010, -- [12]
				25011, -- [13]
				25012, -- [14]
				25013, -- [15]
				25014, -- [16]
				25015, -- [17]
				25016, -- [18]
				25017, -- [19]
				36594, -- [20]
				38058, -- [21]
				38109, -- [22]
				38113, -- [23]
				38133, -- [24]
				38193, -- [25]
				40420, -- [26]
				49537, -- [27]
				59963, -- [28]
			},
			["castTime"] = 0,
			["icon"] = 136048,
			["name"] = "Lightning Breath",
		},
		["SCOURGESTRIKE"] = {
			["maxRange"] = 100,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				28265, -- [1]
				55090, -- [2]
				55265, -- [3]
				55270, -- [4]
				55271, -- [5]
				70890, -- [6]
				71488, -- [7]
			},
			["icon"] = 135990,
			["name"] = "Scourge Strike",
		},
		["POISONS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				2842, -- [1]
				2995, -- [2]
			},
			["castTime"] = 0,
			["icon"] = 136242,
			["name"] = "Poisons",
		},
		["INSTANTPOISON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				8679, -- [1]
				8680, -- [2]
				8681, -- [3]
				8700, -- [4]
				8701, -- [5]
				8810, -- [6]
				11344, -- [7]
				11345, -- [8]
				11346, -- [9]
				28428, -- [10]
				41189, -- [11]
				59242, -- [12]
			},
			["castTime"] = 3000,
			["icon"] = 132273,
			["name"] = "Instant Poison",
		},
		["CUREPOISON"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				526, -- [1]
				536, -- [2]
				1315, -- [3]
				3212, -- [4]
				8946, -- [5]
				8947, -- [6]
				26677, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 136067,
			["name"] = "Cure Poison",
		},
		["WOUNDPOISON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				13218, -- [1]
				13219, -- [2]
				13220, -- [3]
				13221, -- [4]
				13222, -- [5]
				13223, -- [6]
				13224, -- [7]
				13225, -- [8]
				13226, -- [9]
				13227, -- [10]
				13231, -- [11]
				13232, -- [12]
				13233, -- [13]
				30984, -- [14]
				36974, -- [15]
				39665, -- [16]
				43461, -- [17]
				54074, -- [18]
				65962, -- [19]
			},
			["castTime"] = 0,
			["icon"] = 134197,
			["name"] = "Wound Poison",
		},
		["CRIPPLINGPOISON"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				3408, -- [1]
				3409, -- [2]
				3420, -- [3]
				3422, -- [4]
				3423, -- [5]
				11201, -- [6]
				11202, -- [7]
				25809, -- [8]
				30981, -- [9]
				44289, -- [10]
			},
			["castTime"] = 3000,
			["icon"] = 132274,
			["name"] = "Crippling Poison",
		},
		["SUNDERARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				7386, -- [1]
				7404, -- [2]
				7405, -- [3]
				7406, -- [4]
				8380, -- [5]
				8381, -- [6]
				11596, -- [7]
				11597, -- [8]
				11598, -- [9]
				11599, -- [10]
				11971, -- [11]
				13444, -- [12]
				15502, -- [13]
				15572, -- [14]
				16145, -- [15]
				21081, -- [16]
				24317, -- [17]
				25051, -- [18]
				27991, -- [19]
				25225, -- [20]
				30901, -- [21]
				47467, -- [22]
				48893, -- [23]
				50370, -- [24]
				53618, -- [25]
				54188, -- [26]
				57807, -- [27]
				58461, -- [28]
				58567, -- [29]
				59350, -- [30]
				59608, -- [31]
				64978, -- [32]
				65936, -- [33]
				71554, -- [34]
			},
			["castTime"] = 0,
			["icon"] = 132363,
			["name"] = "Sunder Armor",
		},
		["DETERRENCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				19263, -- [1]
				31567, -- [2]
				67801, -- [3]
				65871, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 132369,
			["name"] = "Deterrence",
		},
		["GORE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				35294, -- [1]
				4102, -- [2]
				4733, -- [3]
				5150, -- [4]
				32019, -- [5]
				35290, -- [6]
				35291, -- [7]
				35292, -- [8]
				35293, -- [9]
				35295, -- [10]
				35299, -- [11]
				35300, -- [12]
				35302, -- [13]
				35303, -- [14]
				35304, -- [15]
				35305, -- [16]
				35306, -- [17]
				35307, -- [18]
				35308, -- [19]
				48130, -- [20]
				51751, -- [21]
				59264, -- [22]
			},
			["castTime"] = 0,
			["icon"] = 132184,
			["name"] = "Gore",
		},
		["CONJUREMANACITRINE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				10053, -- [1]
				10055, -- [2]
			},
			["castTime"] = 3000,
			["icon"] = 134116,
			["name"] = "Conjure Mana Citrine",
		},
		["WICKEDLEATHERARMOR"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 25000,
			["name"] = "Wicked Leather Armor",
			["icon"] = 136243,
			["id"] = {
				19098, -- [1]
			},
		},
		["FROSTWOVENWRISTWRAPS"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 3000,
			["id"] = {
				56031, -- [1]
			},
			["icon"] = 136249,
			["name"] = "Frostwoven Wristwraps",
		},
		["PHANTOMBLADE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 45000,
			["id"] = {
				10007, -- [1]
				10008, -- [2]
			},
			["icon"] = 135350,
			["name"] = "Phantom Blade",
		},
		["CONFLAGRATE"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				17962, -- [1]
				18930, -- [2]
				18931, -- [3]
				18932, -- [4]
				18933, -- [5]
				18934, -- [6]
				18935, -- [7]
			},
			["castTime"] = 0,
			["icon"] = 135807,
			["name"] = "Conflagrate",
		},
		["DETECTLESSERINVISIBILITY"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				132, -- [1]
				2971, -- [2]
				3099, -- [3]
				6512, -- [4]
			},
			["castTime"] = 0,
			["icon"] = 136153,
			["name"] = "Detect Lesser Invisibility",
		},
		["CURSEOFRECKLESSNESS"] = {
			["maxRange"] = 30,
			["minRange"] = 0,
			["id"] = {
				704, -- [1]
				7650, -- [2]
				7658, -- [3]
				7659, -- [4]
				7660, -- [5]
				7661, -- [6]
				11717, -- [7]
				11718, -- [8]
				16231, -- [9]
			},
			["castTime"] = 0,
			["icon"] = 136225,
			["name"] = "Curse of Recklessness",
		},
		["COUNTERATTACK"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["id"] = {
				19306, -- [1]
				20909, -- [2]
				20910, -- [3]
				20942, -- [4]
				20943, -- [5]
				27067, -- [6]
				48998, -- [7]
				48999, -- [8]
				52881, -- [9]
				52883, -- [10]
			},
			["icon"] = 132336,
			["name"] = "Counterattack",
		},
		["WILDGROWTH"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Wild Growth",
			["icon"] = 136224,
			["id"] = {
				34161, -- [1]
				48438, -- [2]
				52948, -- [3]
				52949, -- [4]
				53248, -- [5]
				53249, -- [6]
				53251, -- [7]
				55066, -- [8]
				61750, -- [9]
				61751, -- [10]
			},
		},
		["SMELTFELSTEEL"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 1500,
			["id"] = {
				29360, -- [1]
			},
			["icon"] = 136243,
			["name"] = "Smelt Felsteel",
		},
		["BEASTTRAINING"] = {
			["id"] = {
				5149, -- [1]
				5300, -- [2]
			},
			["maxRange"] = 0,
			["minRange"] = 0,
			["castTime"] = 0,
			["name"] = "Beast Training",
			["icon"] = 132162,
		},
		["FIRERESISTANCE"] = {
			["maxRange"] = 0,
			["minRange"] = 0,
			["id"] = {
				541, -- [1]
				2868, -- [2]
				4057, -- [3]
				8185, -- [4]
				10534, -- [5]
				10535, -- [6]
				23992, -- [7]
				24439, -- [8]
				24440, -- [9]
				24441, -- [10]
				24442, -- [11]
				24444, -- [12]
				24445, -- [13]
				24463, -- [14]
				24464, -- [15]
				24468, -- [16]
				24470, -- [17]
				24472, -- [18]
				27533, -- [19]
				28765, -- [20]
				25562, -- [21]
				27053, -- [22]
				27351, -- [23]
				58738, -- [24]
				58740, -- [25]
			},
			["name"] = "Fire Resistance",
			["icon"] = 136235,
			["castTime"] = 3000,
		},
		["MINDNUMBINGPOISONIII"] = {
			["id"] = {
				11400, -- [1]
				11398, -- [2]
				11399, -- [3]
			},
			["icon"] = 136066,
			["name"] = "Mind-numbing Poison III",
		},
		["MINDNUMBINGPOISONII"] = {
			["id"] = {
				8694, -- [1]
				8692, -- [2]
				8693, -- [3]
			},
			["icon"] = 136066,
			["name"] = "Mind-numbing Poison II",
		},
		["INSTANTPOISONIV"] = {
			["id"] = {
				11341, -- [1]
				11335, -- [2]
				11338, -- [3]
			},
			["icon"] = 132273,
			["name"] = "Instant Poison IV",
		},
		["DEADLYPOISON"] = {
			["id"] = {
				2835, -- [1]
				2818, -- [2]
				2823, -- [3]
				2843, -- [4]
				2844, -- [5]
				3583, -- [6]
				10022, -- [7]
				11360, -- [8]
				11361, -- [9]
				13582, -- [10]
				21787, -- [11]
				21788, -- [12]
				25412, -- [13]
				25974, -- [14]
				32970, -- [15]
				32971, -- [16]
				34616, -- [17]
				34655, -- [18]
				34657, -- [19]
				36872, -- [20]
				38519, -- [21]
				38520, -- [22]
				41191, -- [23]
				41192, -- [24]
				41485, -- [25]
				43580, -- [26]
				43581, -- [27]
				56145, -- [28]
				56149, -- [29]
				59479, -- [30]
				59482, -- [31]
				63755, -- [32]
				63756, -- [33]
				67710, -- [34]
				67711, -- [35]
				72329, -- [36]
			},
			["icon"] = 132290,
			["name"] = "Deadly Poison",
		},
		["MINDNUMBINGPOISON"] = {
			["id"] = {
				5763, -- [1]
				5760, -- [2]
				5761, -- [3]
				5768, -- [4]
				8695, -- [5]
				11401, -- [6]
				25810, -- [7]
				34615, -- [8]
				41190, -- [9]
			},
			["icon"] = 136066,
			["name"] = "Mind-numbing Poison",
		},
		["CRIPPLINGPOISON"] = {
			["id"] = {
				3420, -- [1]
				3408, -- [2]
				3409, -- [3]
				3422, -- [4]
				3423, -- [5]
				11201, -- [6]
				11202, -- [7]
				25809, -- [8]
				30981, -- [9]
				44289, -- [10]
			},
			["icon"] = 132274,
			["name"] = "Crippling Poison",
		},
		["INSTANTPOISONIII"] = {
			["id"] = {
				8691, -- [1]
				8688, -- [2]
				8689, -- [3]
			},
			["icon"] = 132273,
			["name"] = "Instant Poison III",
		},
		["DEADLYPOISONV"] = {
			["id"] = {
				25347, -- [1]
				25349, -- [2]
				25351, -- [3]
			},
			["icon"] = 132290,
			["name"] = "Deadly Poison V",
		},
		["INSTANTPOISONV"] = {
			["id"] = {
				11342, -- [1]
				11336, -- [2]
				11339, -- [3]
			},
			["icon"] = 132273,
			["name"] = "Instant Poison v",
		},
		["DEADLYPOISONIII"] = {
			["id"] = {
				11357, -- [1]
				11353, -- [2]
				11355, -- [3]
			},
			["icon"] = 132290,
			["name"] = "Deadly Poison III",
		},
		["INSTANTPOISONVI"] = {
			["id"] = {
				11343, -- [1]
				11337, -- [2]
				11340, -- [3]
			},
			["icon"] = 132273,
			["name"] = "Instant Poison VI",
		},
		["DEADLYPOISONIV"] = {
			["id"] = {
				11358, -- [1]
				11354, -- [2]
				11356, -- [3]
			},
			["icon"] = 132290,
			["name"] = "Deadly Poison IV",
		},
		["DEADLYPOISONII"] = {
			["id"] = {
				2837, -- [1]
				2819, -- [2]
				2824, -- [3]
			},
			["icon"] = 132290,
			["name"] = "Deadly Poison II",
		},
		["INSTANTPOISONII"] = {
			["id"] = {
				8687, -- [1]
				8685, -- [2]
				8686, -- [3]
			},
			["icon"] = 132273,
			["name"] = "Instant Poison II",
		},
		["WOUNDPOISON"] = {
			["id"] = {
				13220, -- [1]
				13218, -- [2]
				13219, -- [3]
				13221, -- [4]
				--13222, -- [5]
				--13223, -- [6]
				--13224, -- [7]
				--13225, -- [8]
				--13226, -- [9]
				--13227, -- [10]
				13231, -- [11]
				13232, -- [12]
				13233, -- [13]
				30984, -- [14]
				36974, -- [15]
				39665, -- [16]
				43461, -- [17]
				54074, -- [18]
				65962, -- [19]
			},
			["icon"] = 132274,
			["name"] = "Wound Poison",
		},
		["INSTANTPOISON"] = {
			["id"] = {
				8681, -- [1]
				8679, -- [2]
				8680, -- [3]
				8700, -- [4]
				8701, -- [5]
				8810, -- [6]
				11344, -- [7]
				11345, -- [8]
				11346, -- [9]
				28428, -- [10]
				41189, -- [11]
				59242, -- [12]
			},
			["icon"] = 132273,
			["name"] = "Instant Poison",
		},
		["WOUNDPOISONII"] = {
			["id"] = {
				13228, -- [1]
				13222, -- [2]
				13225, -- [3]
			},
			["icon"] = 132274,
			["name"] = "Wound Poison II",
		},
		["WOUNDPOISONIV"] = {
			["id"] = {
				13230, -- [1]
				13224, -- [2]
				13227, -- [3]
			},
			["icon"] = 132274,
			["name"] = "Wound Poison IV",
		},
		["CRIPPLINGPOISONII"] = {
			["id"] = {
				3421, -- [1]
			},
			["icon"] = 134799,
			["name"] = "Crippling Poison II",
		},
		["WOUNDPOISONIII"] = {
			["id"] = {
				13229, -- [1]
				13223, -- [2]
				13226, -- [3]
			},
			["icon"] = 132274,
			["name"] = "Wound Poison III",
		},
	}
