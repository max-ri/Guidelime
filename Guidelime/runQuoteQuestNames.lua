addon = {}

assert(loadfile "Data\\Guidelime_QuestsDB.lua")(nil, addon)

local f = io.open(arg[1], "r")
local text = f:read("*all")
f:close()

for _, quest in pairs(addon.questsDB) do
	text = text:gsub(quest.name, "\"" .. quest.name .. "\"")
end

print(text)
