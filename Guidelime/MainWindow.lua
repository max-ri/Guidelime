local addonName, addon = ...
local L = addon.L

local HBD = LibStub("HereBeDragons-2.0")

addon.D = addon.D or {}; local D = addon.D     -- Data/Data
addon.QT = addon.QT or {}; local QT = addon.QT -- Data/QuestTools
addon.AB = addon.AB or {}; local AB = addon.AB -- ActionButtons
addon.CG = addon.CG or {}; local CG = addon.CG -- CurrentGuide
addon.E = addon.E or {}; local E = addon.E     -- Editor
addon.EV = addon.EV or {}; local EV = addon.EV -- Events
addon.F = addon.F or {}; local F = addon.F     -- Frames
addon.G = addon.G or {}; local G = addon.G     -- Guides
addon.M = addon.M or {}; local M = addon.M     -- Map
addon.O = addon.O or {}; local O = addon.O     -- Options
addon.QL = addon.QL or {}; local QL = addon.QL -- QuestLog

addon.MW = addon.MW or {}; local MW = addon.MW -- MainWindow

MW.COLOR_QUEST_DEFAULT = "|cFF59C4F1"
MW.COLOR_LEVEL_RED = "|cFFFF1400"
MW.COLOR_LEVEL_ORANGE = "|cFFFFA500"
MW.COLOR_LEVEL_YELLOW = "|cFFFFFF00"
MW.COLOR_LEVEL_GREEN = "|cFF008000"
MW.COLOR_LEVEL_GRAY = "|cFF808080"
MW.COLOR_WHITE = "|cFFFFFFFF"
MW.COLOR_LIGHT_BLUE = "|cFF99CCFF"
MW.COLOR_INACTIVE = "|cFF666666"

function MW.getLevelColor(level)
	if level == nil then
		return MW.COLOR_LEVEL_GRAY
	elseif level > D.level + 4 then
		return MW.COLOR_LEVEL_RED
	elseif level > D.level + 2 then
		return MW.COLOR_LEVEL_ORANGE
	elseif level >= D.level - 2 then
		return MW.COLOR_LEVEL_YELLOW
	elseif level >= D.level - 4 - math.min(4, math.floor(D.level / 10)) then
		return MW.COLOR_LEVEL_GREEN
	else
		return MW.COLOR_LEVEL_GRAY
	end
end

function MW.getRequiredLevelColor(level)
	if level == nil or level <= D.level then
		return MW.COLOR_LIGHT_BLUE
	else
		return MW.COLOR_LEVEL_RED
	end
end

function MW.showContextMenu(inMainFrame, questId)
	local menu = {
		{text = L.AVAILABLE_GUIDES .. "...", checked = G.isGuidesShowing(), func = G.showGuides},
		{text = GAMEOPTIONS_MENU .. "...", checked = O.isOptionsShowing(), func = O.showOptions},
	}
	if inMainFrame then
		menu[#menu + 1] = {text = L.EDITOR .. "...", checked = E.isEditorShowing(), func = E.showEditor}
		menu[#menu + 1] = {text = L.SHOW_GUIDE_TITLE, checked = GuidelimeDataChar.showTitle, func = function()
			GuidelimeDataChar.showTitle = not GuidelimeDataChar.showTitle
			if O.optionsFrame ~= nil then
				O.optionsFrame.showTitle:SetChecked(GuidelimeDataChar.showTitle)
			end
			MW.updateMainFrame()
		end}
		menu[#menu + 1] = {text = L.SHOW_COMPLETED_STEPS, checked = GuidelimeDataChar.showCompletedSteps, func = function()
			GuidelimeDataChar.showCompletedSteps = not GuidelimeDataChar.showCompletedSteps
			if O.optionsFrame ~= nil then
				O.optionsFrame.showCompletedSteps:SetChecked(GuidelimeDataChar.showCompletedSteps)
			end
			MW.updateMainFrame()
		end}
		menu[#menu + 1] = {text = L.SHOW_UNAVAILABLE_STEPS, checked = GuidelimeDataChar.showUnavailableSteps, func = function()
			GuidelimeDataChar.showUnavailableSteps = not GuidelimeDataChar.showUnavailableSteps
			if O.optionsFrame ~= nil then
				O.optionsFrame.showUnavailableSteps:SetChecked(GuidelimeDataChar.showUnavailableSteps)
			end
			MW.updateMainFrame()
		end}
	end
	menu[#menu + 1] = {text = L.SHOW_MARKERS_ON .. " " .. L.MAP, checked = GuidelimeData.showMapMarkersGOTO or GuidelimeData.showMapMarkersLOC, func = Guidelime.toggleMapMarkers}
	menu[#menu + 1] = {text = L.SHOW_MARKERS_ON .. " " .. L.MINIMAP, checked = GuidelimeData.showMinimapMarkersGOTO or GuidelimeData.showMinimapMarkersLOC, func = Guidelime.toggleMinimapMarkers}
	if questId then
		menu[#menu + 1] = {text = L.WOWHEAD_OPEN_QUEST, notCheckable = true, func = function()
			F.showUrlPopup((select(4, GetBuildInfo()) < 20000 and L.WOWHEAD_URL_CLASSIC or L.WOWHEAD_URL_WOTLK) .. "/quest=" .. questId)
		end}
	end
	menu[#menu + 1] = {text = _G.CLOSE, notCheckable = true, func = function(self) self:Hide() end}
	EasyMenu(menu, CreateFrame("Frame", "GuidelimeContextMenu", nil, "UIDropDownMenuTemplate"), "cursor", 0 , 0, "MENU")
end

function Guidelime.toggleMapMarkers()
	O.toggleOptions(GuidelimeData, "showMapMarkersGOTO", "showMapMarkersLOC")
	MW.updateMainFrame()
end

function Guidelime.toggleMinimapMarkers()
	O.toggleOptions(GuidelimeData, "showMinimapMarkersGOTO", "showMinimapMarkersLOC")
	MW.updateMainFrame()
end

function MW.updateMainFrame(reset)
	if MW.mainFrame == nil or not GuidelimeDataChar.mainFrameShowing then return end
	if addon.debugging then print("LIME: updating main frame") end

	if F.showingTooltip then GameTooltip:Hide(); F.showingTooltip = false end
	if MW.mainFrame.steps == nil then
		MW.mainFrame.steps = {}
	else
		for _, step in pairs(MW.mainFrame.steps) do
			if step.visible then
				step.visible = false
				step:Hide()
			end
		end
		if reset then MW.mainFrame.steps = {} end
	end
	if MW.mainFrame.message ~= nil then
		for _, message in ipairs(MW.mainFrame.message) do
			message:Hide()
		end
	end
	MW.mainFrame.message = {}
	CG.stopFading()

	if CG.currentGuide == nil or CG.currentGuide.name == nil then
		if addon.debugging then print("LIME: No guide loaded") end
		MW.mainFrame.message[1] = F.addMultilineText(MW.mainFrame.scrollChild, L.NO_GUIDE_LOADED, MW.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button)
			if (button == "RightButton") then
				MW.showContextMenu(true)
			else
				G.showGuides()
			end
		end)
		MW.mainFrame.message[1]:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize, "")
		MW.mainFrame.message[1]:SetPoint("TOPLEFT", MW.mainFrame.scrollChild, "TOPLEFT", 10, -25)
		MW.mainFrame.message[1]:Show()
	else
		MW.mainFrame.message = {}
		local nextGuides = {}
		local demo = false
		if CG.currentGuide.next ~= nil then
			for i, next in ipairs(CG.currentGuide.next) do
				if addon.guides[CG.currentGuide.group .. " " .. next] == nil and CG.currentGuide.download ~= nil then 
					demo = true
				elseif D.applies(addon.guides[CG.currentGuide.group .. " " .. next]) then
					table.insert(nextGuides, next)
				end
			end
		end
		if #nextGuides > 0 then
			local i = 1
			for _, next in ipairs(nextGuides) do
				local g = addon.guides[CG.currentGuide.group .. " " .. next]
				if g ~= nil and 
					D.applies(g) and
					(g.reputation == nil or D.isRequiredReputation(g.reputation, g.repMin, g.repMax)) then
					local msg
					if i == 1 then
						msg = L.GUIDE_FINISHED_NEXT:format(MW.COLOR_WHITE .. next .. "|r")
					else
						msg = L.GUIDE_FINISHED_NEXT_ALT:format(MW.COLOR_WHITE .. next .. "|r")
					end
					MW.mainFrame.message[i] = F.addMultilineText(MW.mainFrame.scrollChild, msg, MW.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button)
						if (button == "RightButton") then
							MW.showContextMenu(true)
						else
							G.loadGuide(CG.currentGuide.group .. " " .. next)
						end
					end)
					MW.mainFrame.message[i]:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize, "")
					MW.mainFrame.message[i]:Hide()
					i = i + 1
				end
			end
		end
		if #MW.mainFrame.message == 0 then
			MW.mainFrame.message[1] = F.addMultilineText(MW.mainFrame.scrollChild, L.GUIDE_FINISHED, MW.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button)
				if (button == "RightButton") then
					MW.showContextMenu(true)
				else
					G.showGuides()
				end
			end)
			MW.mainFrame.message[1]:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize, "")
			MW.mainFrame.message[1]:Hide()
			local guide = addon.guides[CG.currentGuide.name]
			if demo then
				MW.mainFrame.message[2] = F.addMultilineText(MW.mainFrame.scrollChild, 
					string.format(L.DOWNLOAD_FULL_GUIDE, guide.downloadMinLevel, guide.downloadMaxLevel, guide.download, "\n|cFFAAAAAA" .. guide.downloadUrl), 
					MW.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button)
					if (button == "RightButton") then
						MW.showContextMenu(true)
					else
						F.showUrlPopup(guide.downloadUrl) 
					end
				end)
				MW.mainFrame.message[2]:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize, "")
				MW.mainFrame.message[2]:Hide()
			end
		end
		
		--if addon.debugging then print("LIME: Showing guide " .. CG.currentGuide.name) end
		CG.updateSteps()

		local time
		if addon.debugging then time = debugprofilestop() end

		local prev
		if GuidelimeDataChar.showTitle then
			MW.mainFrame.titleBox:SetText(CG.currentGuide.name)
			MW.mainFrame.titleBox:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize, "")
			MW.mainFrame.titleBox:Show()
			prev = MW.mainFrame.titleBox
		else
			MW.mainFrame.titleBox:Hide()
		end
		for i, step in ipairs(CG.currentGuide.steps) do
			if CG.stepIsVisible(step) then
				if step.active or GuidelimeData.maxNumOfSteps == 0 or (CG.currentGuide.lastActiveIndex ~= nil and i - CG.currentGuide.lastActiveIndex < GuidelimeData.maxNumOfSteps) then
					if MW.mainFrame.steps[i] == nil then 
						MW.mainFrame.steps[i] = F.addCheckbox(MW.mainFrame.scrollChild, nil, "") 
						MW.mainFrame.steps[i]:SetScript("OnClick", function()
							if not MW.mainFrame.steps[i]:GetChecked() or MW.mainFrame.steps[i].skipText == nil or MW.mainFrame.steps[i].skipText == "" then
								CG.setStepSkip(MW.mainFrame.steps[i]:GetChecked(), i)
							else
								MW.mainFrame.steps[i]:SetChecked(false)
								local _, lines = MW.mainFrame.steps[i].skipText:gsub("\n", "\n")
								--if addon.debugging then print("LIME: " .. MW.mainFrame.steps[i].skipText .. lines) end
								F.createPopupFrame(MW.mainFrame.steps[i].skipText, function()
									MW.mainFrame.steps[i]:SetChecked(true)
									CG.setStepSkip(true, i)
								end, true, 120 + lines * 10):Show()
							end
						end)
						MW.mainFrame.steps[i].textBox = F.addMultilineText(MW.mainFrame.steps[i], nil, nil, "", function(self, button)
							local j = CG.getElementByTextPos(self:GetCursorPosition(), i)
							local element = CG.currentGuide.steps[i].elements[j]
							if not element then return end
							if button == "RightButton" then
								MW.showContextMenu(true, element.questId)
							else
								if element.questId then
									QL.showQuestLogFrame(element.questId)
								elseif element.url then
									F.showUrlPopup(element.url) 
								end
							end
						end)
						MW.mainFrame.steps[i].textBox:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize, "")
					end
					MW.mainFrame.steps[i].textBox:SetPoint("TOPLEFT", MW.mainFrame.steps[i], "TOPLEFT", 35, -9)
					MW.mainFrame.steps[i].textBox:SetWidth(MW.mainFrame.scrollChild:GetWidth() - 40)
					MW.mainFrame.steps[i]:SetAlpha(1)
					MW.mainFrame.steps[i]:Show()
					MW.mainFrame.steps[i].visible = true
					if prev then
						MW.mainFrame.steps[i]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -35, -2)
					else
						MW.mainFrame.steps[i]:SetPoint("TOPLEFT", MW.mainFrame.scrollChild, "TOPLEFT", 0, -5)
					end
					MW.mainFrame.steps[i]:SetChecked(step.completed or step.skip)
					MW.mainFrame.steps[i]:SetEnabled(not step.completed or step.skip)

					MW.mainFrame.steps[i].textBox:Show()
					CG.updateStepText(i)

					prev = MW.mainFrame.steps[i].textBox
				end
			end
		end

		MW.mainFrame.bottomElement = prev

		for i, message in ipairs(MW.mainFrame.message) do
			if not prev then
				message:SetPoint("TOPLEFT", MW.mainFrame.scrollChild, "TOPLEFT", 0, -5)
			elseif i == 1 then
				message:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -25, -15)
			else
				message:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -15)
			end
			prev = message
		end
		
		if addon.debugging then print("LIME: updateMainFrame " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
		CG.scrollToFirstActive()
	end
end

function MW.showMainFrame()
	if not addon.dataLoaded then addon.loadData() end

	GuidelimeDataChar.mainFrameShowing = true
	if MW.mainFrame == nil then
		--if addon.debugging then print("LIME: initializing main frame") end
		MW.mainFrame = CreateFrame("FRAME", nil, UIParent)
		MW.mainFrame:SetWidth(GuidelimeDataChar.mainFrameWidth)
		MW.mainFrame:SetHeight(GuidelimeDataChar.mainFrameHeight)
		MW.mainFrame:SetPoint(GuidelimeDataChar.mainFrameRelative, UIParent, GuidelimeDataChar.mainFrameRelative, GuidelimeDataChar.mainFrameX, GuidelimeDataChar.mainFrameY)
		MW.mainFrame.bg = MW.mainFrame:CreateTexture(nil, "BACKGROUND")
		MW.mainFrame.bg:SetAllPoints(MW.mainFrame)
		MW.mainFrame.bg:SetColorTexture(0, 0, 0, GuidelimeDataChar.mainFrameAlpha)
		MW.mainFrame:SetFrameLevel(998)
		MW.mainFrame:SetMovable(true)
		MW.mainFrame:EnableMouse(true)
		MW.mainFrame:SetResizable(true)
		MW.mainFrame:SetScript("OnMouseDown", function(self, button)
			if (button == "LeftButton" and not GuidelimeDataChar.mainFrameLocked) then MW.mainFrame:StartMoving() end
		end)
		MW.mainFrame:SetScript("OnMouseUp", function(self, button)
			if (button == "LeftButton") then
				MW.mainFrame:StopMovingOrSizing()
				local _
				_, _, GuidelimeDataChar.mainFrameRelative, GuidelimeDataChar.mainFrameX, GuidelimeDataChar.mainFrameY = MW.mainFrame:GetPoint()
			elseif (button == "RightButton") then
				MW.showContextMenu(true)
			end
		end)
		MW.mainFrame.sizeGrabber = CreateFrame("Button", nil, MW.mainFrame)
		MW.mainFrame.sizeGrabber:SetFrameLevel(999)
		MW.mainFrame.sizeGrabber:SetSize(16, 16)
		MW.mainFrame.sizeGrabber:SetPoint("BOTTOMRIGHT", MW.mainFrame, "BOTTOMRIGHT", -1, 3)
		MW.mainFrame.sizeGrabber:SetNormalTexture("Interface/CHATFRAME/UI-ChatIM-SizeGrabber-Down")
		MW.mainFrame.sizeGrabber:SetHighlightTexture("Interface/CHATFRAME/UI-ChatIM-SizeGrabber-Highlight", "ADD")
		MW.mainFrame.sizeGrabber:SetScript("OnMouseDown", function(self, button)
			if not GuidelimeDataChar.mainFrameLocked then MW.mainFrame:StartSizing() end
		end)
		MW.mainFrame.sizeGrabber:SetScript("OnMouseUp", function(self, button)
			MW.mainFrame:StopMovingOrSizing()
			GuidelimeDataChar.mainFrameWidth, GuidelimeDataChar.mainFrameHeight = MW.mainFrame:GetSize()
			MW.mainFrame.scrollChild:SetSize(MW.mainFrame:GetSize())
			MW.mainFrame.titleBox:SetWidth(GuidelimeDataChar.mainFrameWidth - 40)
			if O.optionsFrame then
				O.optionsFrame.mainFrameWidth:SetValue(GuidelimeDataChar.mainFrameWidth)
				O.optionsFrame.mainFrameHeight:SetValue(GuidelimeDataChar.mainFrameHeight)
			end
			MW.updateMainFrame(true)
		end)
		if GuidelimeDataChar.mainFrameLocked then MW.mainFrame.sizeGrabber:Hide() end
		
		MW.mainFrame.scrollFrame = CreateFrame("SCROLLFRAME", nil, MW.mainFrame, "UIPanelScrollFrameTemplate")
		MW.mainFrame.scrollFrame:SetAllPoints(MW.mainFrame)

		MW.mainFrame.scrollChild = CreateFrame("FRAME", nil, MW.mainFrame)
		MW.mainFrame.scrollFrame:SetScrollChild(MW.mainFrame.scrollChild);
		MW.mainFrame.scrollChild:SetSize(MW.mainFrame:GetSize())
		
		if not GuidelimeDataChar.mainFrameShowScrollBar then 
			MW.mainFrame.scrollFrame.ScrollBar:SetAlpha(0) 
			MW.mainFrame.scrollFrame.ScrollBar:SetEnabled(false)
			MW.mainFrame.scrollFrame.ScrollBar:SetFrameLevel(0)
		end
		
		MW.mainFrame.titleBox = F.addMultilineText(MW.mainFrame.scrollChild, nil, MW.mainFrame.scrollChild:GetWidth() - 40, "")
		MW.mainFrame.titleBox:SetPoint("TOPLEFT", MW.mainFrame.scrollChild, "TOPLEFT", 35, -14)
		
		if EV.firstLogUpdate then
			EV.updateFromQuestLog()
			MW.updateMainFrame()
		end

		MW.mainFrame.doneBtn = CreateFrame("BUTTON", "doneBtn", MW.mainFrame)
		MW.mainFrame.doneBtn:SetFrameLevel(9999)
		MW.mainFrame.doneBtn:SetSize(24, 24)
		MW.mainFrame.doneBtn:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
		MW.mainFrame.doneBtn:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight")
		MW.mainFrame.doneBtn:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
		MW.mainFrame.doneBtn:SetPoint("TOPRIGHT", MW.mainFrame, "TOPRIGHT", 0,0)
		MW.mainFrame.doneBtn:SetScript("OnClick", function()
			MW.hideMainFrame()
		end)

		MW.mainFrame.lockBtn = CreateFrame("BUTTON", "lockBtn", MW.mainFrame)
		MW.mainFrame.lockBtn:SetFrameLevel(9999)
		MW.mainFrame.lockBtn:SetSize(24, 24)
		MW.mainFrame.lockBtn:SetPoint("TOPRIGHT", MW.mainFrame, "TOPRIGHT", -20,0)
		if GuidelimeDataChar.mainFrameLocked then
			MW.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Unlocked-Down")
			MW.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Locked-Up")
		else
			MW.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Unlocked-Down")
			MW.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Locked-Up")
		end
		MW.mainFrame.lockBtn:SetScript("OnClick", function()
			GuidelimeDataChar.mainFrameLocked = not GuidelimeDataChar.mainFrameLocked
			if O.optionsFrame ~= nil then O.optionsFrame.mainFrameLocked:SetChecked(GuidelimeDataChar.mainFrameLocked) end
			if GuidelimeDataChar.mainFrameLocked then
				MW.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Unlocked-Down")
				MW.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Locked-Up")
				MW.mainFrame.sizeGrabber:Hide()
			else
				MW.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Unlocked-Down")
				MW.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Locked-Up")
				MW.mainFrame.sizeGrabber:Show()
			end
		end)

		if addon.debugging then
			MW.mainFrame.reloadBtn = CreateFrame("BUTTON", nil, MW.mainFrame, "UIPanelButtonTemplate")
			MW.mainFrame.reloadBtn:SetFrameLevel(9999)
			MW.mainFrame.reloadBtn:SetSize(12, 16)
			MW.mainFrame.reloadBtn:SetText("R")
			MW.mainFrame.reloadBtn:SetPoint("TOPRIGHT", MW.mainFrame, "TOPRIGHT", -45, -4)
			MW.mainFrame.reloadBtn:SetScript("OnClick", function() ReloadUI() end)
			MW.mainFrame.inspectBtn = CreateFrame("BUTTON", nil, MW.mainFrame, "UIPanelButtonTemplate,SecureActionButtonTemplate")
			MW.mainFrame.inspectBtn:SetFrameLevel(9999)
			MW.mainFrame.inspectBtn:SetSize(12, 16)
			MW.mainFrame.inspectBtn:SetText("T")
			MW.mainFrame.inspectBtn:SetPoint("TOPRIGHT", MW.mainFrame, "TOPRIGHT", -60, -4)
			MW.mainFrame.inspectBtn:SetAttribute("type", "macro")
			MW.mainFrame.inspectBtn:SetAttribute("macrotext","/tinspect Guidelime.addon")
		end
	end
	MW.mainFrame:Show()
	CG.updateSteps()
	if O.optionsFrame ~= nil then O.optionsFrame.mainFrameShowing:SetChecked(true) end
	addon.setupMinimapButton()
end

function MW.hideMainFrame()
	if MW.mainFrame ~= nil then MW.mainFrame:Hide() end
	M.removeMapIcons()
	GuidelimeDataChar.mainFrameShowing = false
	if O.optionsFrame ~= nil then O.optionsFrame.mainFrameShowing:SetChecked(false) end
	addon.setupMinimapButton()
	addon.minimapButtonFlash:Play()
end

function Guidelime.toggleMainFrame()
	if GuidelimeDataChar.mainFrameShowing then 
		addon.MW.hideMainFrame() 
	else 
		addon.MW.showMainFrame()
	end
end
