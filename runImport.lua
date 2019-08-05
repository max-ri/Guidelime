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

local f = io.open(arg[1], "r")
local text = f:read("*all")
f:close()

local text = addon.importPlainText(text)

print(text)
