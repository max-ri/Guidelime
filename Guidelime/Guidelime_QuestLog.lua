
local addonName, addon = ...
local L = addon.L

function addon.updateQuestLog()
	if not GuidelimeData.showQuestLevels and not GuidelimeData.showQuestIds and not GuidelimeData.showTooltips then return end

	local numEntries, numQuests = GetNumQuestLogEntries();
	
	if (numEntries == 0) then return end
	
	local questIndex, questLogTitle, title, level, _, isHeader, isComplete, questCheck, questCheckXOfs, id, tooltip
	for i = 1, QUESTS_DISPLAYED, 1 do
		questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		
		if (questIndex <= numEntries) then
			title, level, _, isHeader, _, isComplete, _, id = GetQuestLogTitle(questIndex)
			
			if (not isHeader) then
				local newTitle = title
				if GuidelimeData.showQuestLevels then
					local qtype = ""
					if addon.getQuestType(id) == "Dungeon" then 
						qtype = "D" 
					elseif addon.getQuestType(id) == "Raid" then 
						qtype = "R" 
					elseif addon.getQuestType(id) == "Group" then 
						qtype = "P" 
					elseif addon.getQuestType(id) == "Elite" then 
						qtype = "+" 
					end
					newTitle = format("  [%d%s] ", level, qtype) .. title
				end
				if GuidelimeData.showQuestIds then
					newTitle = newTitle .. format(" (#%d)", id)
				end
				tooltip = ""
				if addon.scannedQuests[id] then
					tooltip = tooltip .. "|T" .. addon.icons.MAP .. ":12|t" .. L.QUEST_CONTAINED_IN_GUIDE .. "\n"
					for _, entry in ipairs(addon.scannedQuests[id]) do
						tooltip = tooltip .. addon.getQuestIcon(id, entry.t, nil, isComplete)
						if GuidelimeData.showLineNumbers then tooltip = tooltip .. entry.line .. " " end
						tooltip = tooltip .. entry.name .. "\n"
					end
				else
					tooltip = tooltip .. "|T" .. addon.icons.MAP .. ":12|t" .. L.QUEST_NOT_CONTAINED_IN_GUIDE
				end
				if newTitle ~= title or GuidelimeData.showTooltips then
					questLogTitle = _G["QuestLogTitle"..i]
					questCheck = _G["QuestLogTitle"..i.."Check"]
					questLogTitle:SetText(newTitle)
					QuestLogDummyText:SetText(newTitle)
					questCheck:SetPoint("LEFT", questLogTitle, "LEFT", QuestLogDummyText:GetWidth()+24, 0);
					if GuidelimeData.showTooltips and tooltip ~= "" then
						questLogTitle.tooltip = tooltip
						questLogTitle:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show(); addon.showingTooltip = true end end)
						questLogTitle:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" and addon.showingTooltip then GameTooltip:Hide(); addon.showingTooltip = false end end)
					end
				end
			end
		end
	end
end
QuestLogFrame:HookScript('OnUpdate', addon.updateQuestLog)
