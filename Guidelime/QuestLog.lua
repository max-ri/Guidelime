
local addonName, addon = ...
local L = addon.L

addon.QT = addon.QT or {}; local QT = addon.QT -- Data/QuestTools
addon.CG = addon.CG or {}; local CG = addon.CG -- CurrentGuide
addon.F = addon.F or {}; local F = addon.F     -- Frames
addon.QS = addon.QS or {}; local QS = addon.QS -- QuestScan

addon.QL = addon.QL or {}; local QL = addon.QL -- QuestLog

function QL.updateQuestLog()
	if not GuidelimeData.showQuestLevels and not GuidelimeData.showQuestIds and not GuidelimeData.showTooltips then return end

	local numEntries, numQuests = GetNumQuestLogEntries();
	
	if (numEntries == 0) then return end
	
	local questIndex, questLogTitle, title, level, _, isHeader, isComplete, id, tooltip
	for i = 1, QUESTS_DISPLAYED, 1 do
		questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame);
		
		if (questIndex <= numEntries) then
			title, level, _, isHeader, _, isComplete, _, id = GetQuestLogTitle(questIndex)
			
			if (not isHeader) then
				local newTitle = title
				if GuidelimeData.showQuestLevels then
					local qtype = ""
					if QT.getQuestType(id) == "Dungeon" then 
						qtype = "D" 
					elseif QT.getQuestType(id) == "Raid" then 
						qtype = "R" 
					elseif QT.getQuestType(id) == "Group" then 
						qtype = "P" 
					elseif QT.getQuestType(id) == "Elite" then 
						qtype = "+" 
					end
					newTitle = format("  [%d%s] ", level, qtype) .. title
				end
				if GuidelimeData.showQuestIds then
					newTitle = newTitle .. format(" (#%d)", id)
				end
				tooltip = ""
				if QS.scannedQuests[id] then
					tooltip = tooltip .. "|T" .. addon.icons.MAP .. ":12|t" .. L.QUEST_CONTAINED_IN_GUIDE .. "\n"
					for _, entry in ipairs(QS.scannedQuests[id]) do
						tooltip = tooltip .. CG.getQuestIcon(id, entry.t, nil, isComplete)
						if GuidelimeData.showLineNumbers then tooltip = tooltip .. entry.line .. " " end
						tooltip = tooltip .. entry.name .. "\n"
					end
				else
					tooltip = tooltip .. "|T" .. addon.icons.MAP .. ":12|t" .. L.QUEST_NOT_CONTAINED_IN_GUIDE
				end
				if newTitle ~= title or GuidelimeData.showTooltips then
					questLogTitle = QuestLogListScrollFrame.buttons[i]
					questLogTitle:SetText(newTitle)
					QuestLogTitleButton_Resize(questLogTitle);
					if GuidelimeData.showTooltips and tooltip ~= "" then
						questLogTitle.tooltip = tooltip
						questLogTitle:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show(); F.showingTooltip = true end end)
						questLogTitle:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" and F.showingTooltip then GameTooltip:Hide(); F.showingTooltip = false end end)
					end
				end
			end
		end
	end
end
QuestLogFrame:HookScript('OnUpdate', QL.updateQuestLog)

function QL.showQuestLogFrame(questId)
	local questLogIndex = GetQuestLogIndexByID(questId)
	if questLogIndex == 0 then return end
	
	-- if Questie is installed we use Questie's TrackerUtils as it handles (and hopefully gets updates for) possible quest log addons (Thanks!)
	local TrackerUtils = QuestieLoader and QuestieLoader:ImportModule("TrackerUtils")
	if TrackerUtils then return TrackerUtils:ShowQuestLog({Id = questId}) end

    SelectQuestLogEntry(questLogIndex)
    if not QuestLogFrame:IsShown() and not InCombatLockdown() then 
		ShowUIPanel(QuestLogFrame)
    end
    QuestLog_UpdateQuestDetails()
    QuestLog_Update()
end
