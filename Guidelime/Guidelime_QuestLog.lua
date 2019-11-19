
local addonName, addon = ...
local L = addon.L

function addon.updateQuestLog()
	local numEntries, numQuests = GetNumQuestLogEntries();
	
	if (numEntries == 0) then return end
	
	local questIndex, questLogTitle, title, level, _, isHeader, questCheck, questCheckXOfs, id
	for i = 1, QUESTS_DISPLAYED, 1 do
		questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		
		if (questIndex <= numEntries) then
			title, level, _, isHeader, _, _, _, id = GetQuestLogTitle(questIndex)
			
			if (not isHeader) then
				if GuidelimeData.showQuestLevels then
					title = format("  [%d] ", level) .. title
				end
				if GuidelimeData.showQuestIds then
					title = title .. format(" (#%d)", id)
				end
				--title = title .. " |T" .. addon.icons.MAP .. ":12|t"
				questLogTitle = _G["QuestLogTitle"..i]
				questCheck = _G["QuestLogTitle"..i.."Check"]
				questLogTitle:SetText(title)
				QuestLogDummyText:SetText(title)
				questCheck:SetPoint("LEFT", questLogTitle, "LEFT", QuestLogDummyText:GetWidth()+24, 0);
				
				--questLogTitle.tooltip = "tooltip"
				--questLogTitle:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show(); addon.showingTooltip = true end end)
				--questLogTitle:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" and addon.showingTooltip then GameTooltip:Hide(); addon.showingTooltip = false end end)
			end
		end
	end
end
QuestLogFrame:HookScript('OnUpdate', addon.updateQuestLog)
