
JSON = assert(loadfile "JSON.lua")() -- one-time load of the routines
assert(loadfile "tableShow.lua")()

local f = io.open("quests.json", "r")
local json = f:read("*all")
local quests = JSON:decode(json)

-- convert strings to numbers
local questsConverted = {}
for id, quest in pairs(quests) do
	questsConverted[tonumber(id)] = quest
	quest.req = tonumber(quest.req)
	quest.prev = tonumber(quest.prev)
	quest.next = tonumber(quest.next)
	quest.followup = tonumber(quest.followup)
	if quest.reward ~= nil then
		local reward = {}
		for i, r in ipairs(quest.reward) do
			reward[i] = tonumber(r)
		end
		quest.reward = reward
	end
	if quest.repgain ~= nil then
		local repgain = {}
		for fid, rep in pairs(quest.repgain) do
			repgain[tonumber(fid)] = tonumber(rep)
		end
		quest.repgain = repgain
	end
end

f = io.open("..\\Data\\Guidelime_QuestsDB.lua", "w")
f:write("local addonName, addon = ...\n\n")
f:write("-- source: https://github.com/TyrsDev/WoW-Classic-Quests\n")
f:write("-- Thanks to TyrsDev!\n\n")
f:write(table.show(questsConverted, "addon.questsDB"))
f:close()




