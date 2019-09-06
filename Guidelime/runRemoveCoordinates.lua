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
function HBD:GetLocalizedMap(map) return addon.zoneNames[map] end

function LibStub(lib) 
	if lib == "HereBeDragons-2.0" then return HBD end
end

function GetBuildInfo() return nil,nil,nil,11302 end

-- only used for error messages
function GetLocale() return "enUS" end
function addon.createPopupFrame(msg) error(msg) end

GuidelimeData = {}

assert(loadfile "Localization.lua")(nil, addon)
assert(loadfile "Guidelime_Parser.lua")(nil, addon)
assert(loadfile "Guidelime_EditorTools.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_Data.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_MapDB.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_QuestsDB.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_QuestsTools.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_FlightmasterDB.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_FlightmasterDB_Locales.lua")(nil, addon)

local f = io.open(arg[1], "r")
local text = f:read("*all")
f:close()

local guide = addon.parseGuide(text)
local text, count = addon.removeAllCoordinates(guide)

print(text)
