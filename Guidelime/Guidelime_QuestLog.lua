
local addonName, addon = ...
local L = addon.L

function addon.updateQuestLog()
	if not GuidelimeData.showQuestLevels and not GuidelimeData.showQuestIds then return end

	local numEntries, numQuests = GetNumQuestLogEntries();
	
	if (numEntries == 0) then return end
	
	local questIndex, questLogTitle, title, level, _, isHeader, questCheck, questCheckXOfs, id
	for i = 1, QUESTS_DISPLAYED, 1 do
		questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		
		if (questIndex <= numEntries) then
			title, level, _, isHeader, _, _, _, id = GetQuestLogTitle(questIndex)
			
			if (not isHeader) then
				local newTitle = title
				if GuidelimeData.showQuestLevels then
					local qtype = ""
					if addon.questsDB[id].type == "Dungeon" then 
						qtype = "D" 
					elseif addon.questsDB[id].type == "Raid" then 
						qtype = "R" 
					elseif addon.questsDB[id].type == "Elite" then 
						qtype = "+" 
					end
					newTitle = format("  [%d%s] ", level, qtype) .. title
				end
				if GuidelimeData.showQuestIds then
					newTitle = title .. format(" (#%d)", id)
				end
				--title = title .. " |T" .. addon.icons.MAP .. ":12|t"
				if newTitle ~= title then
					questLogTitle = _G["QuestLogTitle"..i]
					questCheck = _G["QuestLogTitle"..i.."Check"]
					questLogTitle:SetText(newTitle)
					QuestLogDummyText:SetText(newTitle)
					questCheck:SetPoint("LEFT", questLogTitle, "LEFT", QuestLogDummyText:GetWidth()+24, 0);
				end
				--questLogTitle.tooltip = "tooltip"
				--questLogTitle:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show(); addon.showingTooltip = true end end)
				--questLogTitle:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" and addon.showingTooltip then GameTooltip:Hide(); addon.showingTooltip = false end end)
			end
		end
	end
end
QuestLogFrame:HookScript('OnUpdate', addon.updateQuestLog)
