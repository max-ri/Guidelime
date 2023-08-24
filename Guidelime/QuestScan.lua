local addonName, addon = ...
local L = addon.L

addon.QS = addon.QS or {}; local QS = addon.QS

function QS.resetScannedQuests()
	if addon.debugging then print("LIME: reset scanned quests") end
	QS.scannedQuests = {}
	QS.scannedGuides = {}
end

function QS.scanGuideQuests(guide)
	if not addon.guides[guide] or QS.scannedGuides[guide] then return end
	local time
	if addon.debugging then time = debugprofilestop() end
	if addon.guides[guide].steps ~= nil then
		for _,step in ipairs(addon.guides[guide].steps) do
			if step.elements ~= nil then
				for _, element in ipairs(step.elements) do
					if element.questId then
						if not QS.scannedQuests[element.questId] then QS.scannedQuests[element.questId] = {} end
						local entry = {name = guide, line = step.line, t = element.t}
						table.insert(QS.scannedQuests[element.questId], entry)
					end
				end
			end
		end
	end
	if addon.debugging then print("LIME: scanning quests for " .. guide .. " in " .. math.floor(debugprofilestop() - time) .. " ms") end
	QS.scannedGuides[guide] = true
	for _, next in ipairs(addon.guides[guide].next) do
		QS.scanGuideQuests(addon.guides[guide].group .. " " .. next)
	end
end