addon = {}
addon.debugging = true

function LibStub() end
function GetBuildInfo() return nil,nil,nil,11302 end

Questie = {}
-- only used for one quest in Questie; you can change to Horde but it will almost always not make a difference
function UnitFactionGroup() return "Alliance" end

function GetLocale() return "enUS" end

-- Questie is required for getting names of quest objectives
GuidelimeData =
{
	dataSourceQuestie = true
}

assert(loadfile "Localization.lua")(nil, addon)
assert(loadfile "Guidelime_Import.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_Data.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_QuestsDB.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_QuestsTools.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_Questie.lua")(nil, addon)

-- path to Questie might need to be adjusted
assert(loadfile "..\\QuestieDev-master\\Database\\questDB.lua")(nil, addon)
assert(loadfile "..\\QuestieDev-master\\Database\\spawnDB.lua")(nil, addon)
assert(loadfile "..\\QuestieDev-master\\Database\\zoneDB.lua")(nil, addon)
assert(loadfile "..\\QuestieDev-master\\Database\\objectDB.lua")(nil, addon)
-- this file looks like it might change in upcoming questie?
assert(loadfile "..\\QuestieDev-master\\Database\\TEMP_questie4items.lua")(nil, addon)

local L = addon.L
local test = "Go up to the north islands and do __________________________________ and \"In Defense of the King's Lands\" Part 3"
local wordListMap = {}
local questPattern = "\"([^\"]+)\""
wordListMap[" " .. questPattern .. " "] = function(...) print("nopart", ...) end
wordListMap[" " .. questPattern .. L.WORD_LIST_PART_N:gsub(";", "; " .. questPattern)] = function(...) print("part", ...) end
wordListMap[L.WORD_LIST_PART_N] = function(...) s, e, part = ...; q = questname; part = tonumber(part) end
local i = 1
while L["WORD_LIST_PART_" .. i] ~= nil do
	wordListMap[" " .. questPattern .. L["WORD_LIST_PART_" .. i]:gsub(";", "; " .. questPattern)] = function(...) s, e, q = ...; part = i end
	wordListMap[L["WORD_LIST_PART_".. i]] = function(...) s, e = ...; q = questname; part = i end
	i = i + 1
end
wordListMap[L.WORD_LIST_NEXT_PART] = function(...) s, e = ...; q = questname
	if questids ~= nil and #questids == 1 and addon.questsDB[questids[1]] ~= nil and addon.questsDB[questids[1]].series ~= nil then 
		part = addon.questsDB[questids[1]].series + 1
	else
		part = 2
	end
end
wordListMap[L.WORD_LIST_COMPLETE_LAST] = function(...) s, e, pre, post = ...; typ = "C" end
wordListMap[L.WORD_LIST_TURN_IN_LAST] = function(...) s, e, pre, post = ...; typ = "T" end
wordListMap[L.WORD_LIST_COMPLETE_LAST_TWO] = function(...) s, e, pre, post = ...; typ = "C"; lastTwo = true end
wordListMap[L.WORD_LIST_TURN_IN_LAST_TWO] = function(...) s, e, pre, post = ...; typ = "T"; lastTwo = true end

addon.findInLists(test, wordListMap)

local f = io.open(arg[1], "r")
local text = f:read("*all")
f:close()

local text = addon.importPlainText(text)

print(text)
