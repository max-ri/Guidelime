local addonName, addon = ...

addon.SK = addon.SK or {}; local SK = addon.SK     -- Data/SkillDB

SK.skills = {
	ALCHEMY = { icon = "Interface\\Icons\\Trade_Alchemy", learnedBy = {2275, 2280, 3465, 11612, 28597, 51303}},
	HERBALISM = { icon = "Interface\\Icons\\Trade_Herbalism", learnedBy = {2372, 2373, 3571, 11994, 28696, 50301}},
	INSCRIPTION = { icon = "Interface\\Icons\\inv_inscription_tradeskill01", learnedBy = {45375, 45376, 45377, 45378, 45379, 45380}},
	ENGINEERING = { icon = "Interface\\Icons\\Trade_Engineering", learnedBy = {4039, 4040, 4041, 12657, 30351, 51305}},
	MINING = { icon = "Interface\\Icons\\Trade_Mining", learnedBy = {2581, 2582, 3568, 10249, 29355, 50309}},
	ENCHANTING = { icon = "Interface\\Icons\\trade_engraving", learnedBy = {7414, 7415, 7416, 13921, 28030, 51312}},
	LEATHERWORKING = { icon = "Interface\\Icons\\Trade_LeatherWorking", learnedBy = {2155, 2154, 3812, 10663, 32550, 51301}},
	JEWELCRAFTING = { icon = "Interface\\Icons\\inv_misc_gem_01", learnedBy = {25245, 25246, 28896, 28899, 28901, 51310}},
	TAILORING = { icon = "Interface\\Icons\\Trade_Tailoring", learnedBy = {3911, 3912, 3913, 12181, 26791, 51308}},
	SKINNING = { icon = "Interface\\Icons\\inv_misc_pelt_wolf_01", learnedBy = {8615, 8619, 8620, 10769, 32679, 50307}},
	BLACKSMITHING = { icon = "Interface\\Icons\\Trade_BlackSmithing", learnedBy = {2020, 2021, 3539, 9786, 29845, 51298}},

	FIRSTAID = { icon = "Interface\\Icons\\spell_holy_sealofsacrifice", learnedBy = {3279, 3280, 19903, 10847, 27029, 50299}},
	FISHING = { icon = "Interface\\Icons\\Trade_Fishing", learnedBy = {7733, 7734, 19889, 18249, 33100, 51293}},
	COOKING = { icon = "Interface\\Icons\\inv_misc_food_15", learnedBy = {2551, 3412, 19886, 18261, 33361, 51295}},

	RIDING = { icon = "Interface\\Icons\\Ability_Mount_RidingHorse", learnedBy = {33388, 33391, 34090, 34091}},
	
	SWORDS = {icon = "Interface\\Icons\\ability_meleedamage"},
	AXES = {icon = "Interface\\Icons\\inv_axe_01"},
	BOWS = {icon = "Interface\\Icons\\INV_Weapon_Bow_05"},
	GUNS = {icon = "Interface\\Icons\\INV_Weapon_Rifle_01"},
	MACES = {icon = "Interface\\Icons\\INV_Mace_01"},
	TWOHANDEDSWORDS = {icon = "Interface\\Icons\\ability_meleedamage"},
	DEFENSE = {icon = "Interface\\Icons\\Ability_Defend"},
	DUALWIELD = {icon = "Interface\\Icons\\Ability_DualWield"},
	STAVES = {icon = "Interface\\Icons\\INV_Staff_08"},
	TWOHANDEDMACES = {icon = "Interface\\Icons\\inv_mace_04"},
	UNARMED = {icon = "Interface\\Icons\\ability_golemthunderclap"},
	TWOHANDEDAXES = {icon = "Interface\\Icons\\inv_axe_04"},
	DAGGERS = {icon = "Interface\\Icons\\ability_steelmelee"},
	THROWN = {icon = "Interface\\Icons\\inv_throwingknife_02"},
	CROSSBOWS = {icon = "Interface\\Icons\\inv_weapon_crossbow_01"},
	WANDS = {icon = "Interface\\Icons\\ability_shootwand"},
	POLEARMS = {icon = "Interface\\Icons\\inv_spear_06"},
	FISTWEAPONS = {icon = "Interface\\Icons\\inv_gauntlets_04"},
	PLATEMAIL = {icon = "Interface\\Icons\\inv_chest_plate01"},
	MAIL = {icon = "Interface\\Icons\\inv_chest_chain_05"},
	LEATHER = {icon = "Interface\\Icons\\inv_chest_leather_09"},
	CLOTH = {icon = "Interface\\Icons\\inv_chest_cloth_21"},
	SHIELD = {icon = "Interface\\Icons\\inv_shield_04"},
	LOCKPICKING = {icon = "Interface\\Icons\\spell_nature_moonkey"}
 }

function SK.getSkill(name)
	local p = name:upper():gsub("[ %-]","")
	return SK.skills[p] and p
end

function SK.isSkill(name)
	return SK.getSkill(name) ~= nil
end

function SK.getLocalizedName(name)
	return SK.skillDB_Locales[GetLocale()][name]
end

function SK.getSkillRank(name)
	local locName = SK.getLocalizedName(name)
	for i = 1, GetNumSkillLines() do
    	local skillName, header, _, rank, _, _, max = GetSkillLineInfo(i)
    	if not header and skillName == locName then
			--if addon.debugging then print("LIME: found", name, name == locName and "" or locName, "rank", rank) end
			return rank, max
		end
	end
	--if addon.debugging then print("LIME: not found", name, name == locName and "" or locName) end
end

function SK.isRequiredSkill(name, skillMin, skillMax, maxSkillMin)
	local value, valueMax = SK.getSkillRank(name)
	if skillMin ~= nil and (value or 0) < skillMin then return false end
	if skillMax ~= nil and (value or 0) >= skillMax then return false end
	if maxSkillMin ~= nil and (valueMax or 0) < maxSkillMin then return false end
	return true
end

function SK.getSkillIcon(name)
	return SK.skills[name] and SK.skills[name].icon
end

function SK.getSkillLearnedBy(name)
	return SK.skills[name] and SK.skills[name].learnedBy
end

function SK.getMaxSkillLearnedBySpell(id)
	if SK.maxSkillLearnedBy == nil then
		SK.maxSkillLearnedBy = {}
		local maxSkill = { 75, 125, 225, 300, 375, 450 }
		for name, S in pairs(SK.skills) do
			if S.learnedBy ~= nil then
				for i, id in ipairs(S.learnedBy) do
					SK.maxSkillLearnedBy[id] = { name, maxSkill[i] }
				end
			end
		end
	end
	if SK.maxSkillLearnedBy[id] ~= nil then 
		return unpack(SK.maxSkillLearnedBy[id]) 
	end
end
	
	