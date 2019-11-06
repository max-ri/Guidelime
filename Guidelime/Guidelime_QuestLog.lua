
local addonName, addon = ...
local L = addon.L

function addon.updateQuestLog()
	local numEntries, numQuests = GetNumQuestLogEntries();
	
	if (numEntries == 0) then return end
	
	local questIndex, questLogTitle, title, level, _, isHeader, questCheck, questCheckXOfs, id
	for i = 1, QUESTS_DISPLAYED, 1 do
		questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		
		if (questIndex <= numEntries) then
			questLogTitle = _G["QuestLogTitle"..i]
			questCheck = _G["QuestLogTitle"..i.."Check"]
			title, level, _, isHeader, _, _, _, id = GetQuestLogTitle(questIndex)
			
			if (not isHeader) then
				if GuidelimeData.showQuestLevels then
					title = format("  [%d] ", level) .. title
				end
				if GuidelimeData.showQuestIds then
					title = title .. format(" (#%d)", id)
				end
				questLogTitle:SetText(title)
				QuestLogDummyText:SetText(title)
			end

			questCheck:SetPoint("LEFT", questLogTitle, "LEFT", QuestLogDummyText:GetWidth()+24, 0);
		end
	end
end
QuestLogFrame:HookScript('OnUpdate', addon.updateQuestLog)
