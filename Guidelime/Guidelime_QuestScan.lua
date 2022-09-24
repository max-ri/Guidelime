local addonName, addon = ...
local L = addon.L

function addon.resetScannedQuests()
	if addon.debugging then print("LIME: reset scanned quests") end
	addon.scannedQuests = {}
	addon.scannedGuides = {}
end

function addon.scanGuideQuests(guide)
	if not addon.guides[guide] or addon.scannedGuides[guide] then return end
	local time
	if addon.debugging then time = debugprofilestop() end
	for _,step in ipairs(addon.guides[guide].steps) do
		for _, element in ipairs(step.elements) do
			if element.questId then
				if not addon.scannedQuests[element.questId] then addon.scannedQuests[element.questId] = {} end
				local entry = {name = guide, line = step.line, t = element.t}
				table.insert(addon.scannedQuests[element.questId], entry)
			end
		end
	end
	if addon.debugging then print("LIME: scanning quests for " .. guide .. " in " .. math.floor(debugprofilestop() - time) .. " ms") end
	addon.scannedGuides[guide] = true
	for _, next in ipairs(addon.guides[guide].next) do
		addon.scanGuideQuests(addon.guides[guide].group .. " " .. next)
	end
end