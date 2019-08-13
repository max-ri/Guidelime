addon = {}
addon.debugging = true

function LibStub() end
function GetBuildInfo() return nil,nil,nil,11302 end

function GetLocale() return "enUS" end

GuidelimeData = {}

assert(loadfile "Localization.lua")(nil, addon)
assert(loadfile "Guidelime_Import.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_Data.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_QuestsDB.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_CreaturesDB.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_ObjectsDB.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_ItemsDB.lua")(nil, addon)
assert(loadfile "Data\\Guidelime_QuestsTools.lua")(nil, addon)

local f = io.open(arg[1], "r")
local text = f:read("*all")
f:close()

local text = addon.importPlainText(text)

print(text)
