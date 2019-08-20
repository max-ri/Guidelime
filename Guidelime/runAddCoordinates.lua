addon = {}

-- Here Be Dragons does not run outside of client, but is used to transform coordinates; therefore we fake transforming coordinates here
-- (only used to transform zone coordinates to world and back to zone in the end)
HBD = {}
function HBD:GetZoneCoordinatesFromWorld(x, y, map)
	if map == nil then return end
	return x, y, map
end
function HBD:GetWorldCoordinatesFromZone(x, y, map)
	if map == nil then return end
	return x, y, map
end
function LibStub(lib) 
	if lib == "HereBeDragons-2.0" then return HBD end
end

function GetBuildInfo() return nil,nil,nil,11302 end

Questie = {}
-- only used for one quest in Questie; you can change to Horde but it will almost always not make a difference
function UnitFactionGroup() return "Alliance" end

-- only used for error messages
function GetLocale() return "enUS" end
function addon.createPopupFrame(msg) error(msg) end

-- only Questie data source can be used, since transforming world coordinates would be required for using internal database
GuidelimeData =
{
	dataSourceQuestie = true
}

assert(loadfile "Localization.lua")(nil, addon)
assert(loadfile "Guidelime_Parser.lua")(nil, addon)
assert(loadfile "Guidelime_EditorTools.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_Data.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_MapDB.lua")(nil, addon)
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

local guide = addon.parseGuide(text, nil, false)
local text, count = addon.addQuestCoordinates(guide)

print(text)
