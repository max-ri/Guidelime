local addonName, addon = ...
local L = addon.L


function addon.getQuestNameById(id)
	if addon.quests[id] ~= nil and addon.quests[id].name ~= nil then
		return addon.quests[id].name
	end
	local locale = GetLocale()
	if locale == "frFR" then
		return addon.questsDB[id].name_fr
	elseif locale == "deDE" then
		return addon.questsDB[id].name_de
	elseif locale == "zhCN" or locale == "zhTW" then
		return addon.questsDB[id].name_cn
	elseif locale == "esES" or locale == "esMX" then
		return addon.questsDB[id].name_es
	elseif locale == "ruRU" then
		return addon.questsDB[id].name_ru
	else
		return addon.questsDB[id].name
	end
end

function addon.getPossibleQuestIdsByName(name)
	if addon.questsDBReverse == nil then
		addon.questsDBReverse = {}
		for id, quest in pairs(addon.questsDB) do
			local n = addon.getQuestNameById(id):upper()
			if addon.questsDBReverse[n] == nil then addon.questsDBReverse[n] = {} end
			table.insert(addon.questsDBReverse[n], id)
			if quest.series ~= nil then
				local n2 = n .. " " .. L.PART:upper() .. " " .. quest.series
				if addon.questsDBReverse[n2] == nil then addon.questsDBReverse[n2] = {} end
				table.insert(addon.questsDBReverse[n2], id)
			end
			if n:upper() ~= addon.questsDB[id].name:upper() then
				n = addon.questsDB[id].name:upper()
				if addon.questsDBReverse[n] == nil then addon.questsDBReverse[n] = {} end
				table.insert(addon.questsDBReverse[n], id)
				if quest.series ~= nil then
					local n2 = n .. " PART " .. quest.series
					if addon.questsDBReverse[n2] == nil then addon.questsDBReverse[n2] = {} end
					table.insert(addon.questsDBReverse[n2], id)
				end
			end
		end
	end
	local filteredName = name:gsub("%(",""):gsub("%)",""):gsub("pt%.","part"):upper()
	local ids = addon.questsDBReverse[filteredName]
	if ids == nil and filteredName:sub(#filteredName - 5,#filteredName - 1) == "PART " then 
		return addon.getPossibleQuestIdsByName(filteredName:sub(1, #filteredName - 7)) 
	end
	return ids
end
