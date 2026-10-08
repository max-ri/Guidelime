local addonName, addon = ...
local L = addon.L

addon.QT = addon.QT or {}; local QT = addon.QT
addon.CG = addon.CG or {}; local CG = addon.CG
addon.QS = addon.QS or {}; local QS = addon.QS

addon.MF = addon.MF or {}
local MF = addon.MF

local function buildTooltip(id)
	local isComplete = C_QuestLog.IsComplete and C_QuestLog.IsComplete(id)
	local tooltip = ""
	if QS.scannedQuests and QS.scannedQuests[id] then
		tooltip = tooltip .. "|T" .. addon.icons.MAP .. ":12|t" .. L.QUEST_CONTAINED_IN_GUIDE .. "\n"
		for _, entry in ipairs(QS.scannedQuests[id]) do
			tooltip = tooltip .. CG.getQuestIcon(id, entry.t, nil, isComplete)
			if GuidelimeData.showLineNumbers then tooltip = tooltip .. entry.line .. " " end
			tooltip = tooltip .. entry.name .. "\n"
		end
	else
		tooltip = "|T" .. addon.icons.MAP .. ":12|t" .. L.QUEST_NOT_CONTAINED_IN_GUIDE
	end
	return tooltip
end

MF.baseTitle = {}
local function decorateQuestRow(frame)
	local id = frame.questID
	if not id then return end
	local title = addon.GetQuestInfo(id)
	if not title then return end

	if frame.Text and frame.Text.GetText and frame.Text.SetText then
		local text = frame.Text:GetText()
		if text and (text == title or text:find(title, 1, true)) then 
			local newTitle = MF.baseTitle[id] or frame.Text:GetText()
			if not MF.baseTitle[id] then MF.baseTitle[id] = newTitle end
			local qtype = nil
			if QT.getQuestType(id) == "Dungeon" then qtype = "D"
			elseif QT.getQuestType(id) == "Raid" then qtype = "R"
			elseif QT.getQuestType(id) == "Group" then qtype = "P"
			elseif QT.getQuestType(id) == "Elite" then qtype = "+" end
			if qtype and newTitle then
				newTitle = newTitle:gsub("%[(%d+)%]", "[%1" .. qtype .. "]")
			end
			if GuidelimeData.showQuestIds then newTitle = newTitle .. format(" (#%d)", id) end
			if frame.Text:GetText() ~= newTitle then frame.Text:SetText(newTitle) end

			if GuidelimeData.showTooltips and frame.HookScript then
				if not frame.guidelimeTooltipHooked then
					frame:HookScript("OnEnter", function(self)
						-- The row's original OnEnter has already populated GameTooltip.
						-- Add Guidelime's details after those lines instead of replacing them.
						GameTooltip:AddLine(" ")
						for line in buildTooltip(self.guidelimeTooltipHooked):gmatch("[^\n]+") do
							GameTooltip:AddLine(line, 1, 1, 1, true)
						end
						GameTooltip:Show()
					end)
				end
				frame.guidelimeTooltipHooked = id
			end
		end
	end
end

local function scanFrame(frame, depth)
	if not frame or depth > 5 then return end
	decorateQuestRow(frame)
	if frame.GetChildren then
		for _, child in ipairs({frame:GetChildren()}) do scanFrame(child, depth + 1) end
	end
end

function MF.update()
	if not addon.dataLoaded or not QS.scannedQuests or not GuidelimeData then return end
	if not GuidelimeData.showQuestLevels and not GuidelimeData.showQuestIds and not GuidelimeData.showTooltips then return end
	-- Quest UI is loaded on demand and its exact parent differs between client builds.
	-- Search the map frame descendants for quest rows carrying a quest ID.
	if WorldMapFrame then scanFrame(WorldMapFrame, 0) end
end

local function install()
	if not WorldMapFrame or MF.hooked then return end
	WorldMapFrame:HookScript("OnUpdate", function(self, elapsed)
		MF.elapsed = (MF.elapsed or 0) + elapsed
		if MF.elapsed >= 0.5 then MF.elapsed = 0; MF.update() end
	end)
	MF.hooked = true
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("QUEST_LOG_UPDATE")
loader:RegisterEvent("QUEST_ACCEPTED")
loader:RegisterEvent("QUEST_REMOVED")
loader:SetScript("OnEvent", function(_, event, loadedAddon)
	if event == "ADDON_LOADED" and loadedAddon ~= "Blizzard_WorldMap" then return end
	install()
	MF.update()
end)
install()
