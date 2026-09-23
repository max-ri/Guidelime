local addonName, addon = ...

-- Classic globals missing on modern clients (WoW: Forever). Each falls back to the C_ namespace only when the global is gone.
-- Kept addon-local on purpose: defining these globals would make other addons believe they run on Classic.

addon.GetSpellInfo = GetSpellInfo or function(id)
	local i = id and C_Spell.GetSpellInfo(id)
	if i then return i.name, C_Spell.GetSpellSubtext(i.spellID), i.iconID, i.castTime, i.minRange, i.maxRange, i.spellID end
end

addon.GetSpellCooldown = GetSpellCooldown or function(id)
	local c = C_Spell.GetSpellCooldown(id)
	if c then return c.startTime, c.duration, c.isEnabled, c.modRate end
end

addon.UnitAura = UnitAura or function(unit, i, filter)
	local a = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)
	if a then return a.name, a.icon, a.applications, a.dispelName, a.duration, a.expirationTime, a.sourceUnit, a.isStealable, a.nameplateShowPersonal, a.spellId end
end

addon.GetItemInfo = GetItemInfo or C_Item.GetItemInfo
addon.GetItemCount = GetItemCount or C_Item.GetItemCount
addon.GetItemIcon = GetItemIcon or C_Item.GetItemIconByID
addon.GetQuestInfo = C_QuestLog.GetQuestInfo or C_QuestLog.GetTitleForQuestID

-- ponytail: professions only (no weapon skills); covers the profession checks Guidelime uses
local profs = {}
addon.GetNumSkillLines = GetNumSkillLines or function()
	profs = {}
	for _, index in pairs({GetProfessions()}) do profs[#profs + 1] = index end -- pairs skips nil gaps
	return #profs
end
addon.GetSkillLineInfo = GetSkillLineInfo or function(i)
	local name, _, rank, max = GetProfessionInfo(profs[i])
	return name, false, nil, rank, nil, nil, max
end
