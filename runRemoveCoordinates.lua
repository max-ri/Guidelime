addon = {}

function GetBuildInfo() return nil,nil,nil,11302 end

-- only used for error messages
function GetLocale() return "enUS" end
function addon.createPopupFrame(msg) error(msg) end

assert(loadfile "Localization.lua")(nil, addon)
assert(loadfile "Guidelime_Parser.lua")(nil, addon)
assert(loadfile "Guidelime_EditorTools.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_Data.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_MapDB.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_QuestsDB.lua")(nil, addon)

local f = io.open(arg[1], "r")
local text = f:read("*all")
f:close()

local guide = addon.parseGuide(text)
local text, count = addon.removeAllCoordinates(guide)

print(text)
