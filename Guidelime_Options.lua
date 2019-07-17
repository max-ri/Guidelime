local addonName, addon = ...
local L = addon.L

function addon.fillOptions()
	addon.optionsFrame = CreateFrame("FRAME", nil, addon.guidesFrame)
	addon.optionsFrame.name = GAMEOPTIONS_MENU
	addon.optionsFrame.parent = GetAddOnMetadata(addonName, "title")
	InterfaceOptions_AddCategory(addon.optionsFrame)

	addon.optionsFrame.title = addon.optionsFrame:CreateFontString(nil, addon.optionsFrame, "GameFontNormal")
	addon.optionsFrame.title:SetText(GetAddOnMetadata(addonName, "title") .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version") .." - " .. GAMEOPTIONS_MENU)
	addon.optionsFrame.title:SetPoint("TOPLEFT", 20, -20)
	addon.optionsFrame.title:SetFontObject("GameFontNormalLarge")
	local prev = addon.optionsFrame.title

	addon.optionsFrame.options = {}		
	local checkbox = addon.addCheckOption(addon.optionsFrame, GuidelimeDataChar, "mainFrameShowing", L.SHOW_MAINFRAME, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.showMainFrame()
		elseif addon.mainFrame ~= nil then
			HBDPins:RemoveAllWorldMapIcons(Guidelime)
			HBDPins:RemoveAllMinimapIcons(Guidelime)
			addon.mainFrame:Hide()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox
	
	local slider = addon.addSliderOption(addon.optionsFrame, GuidelimeDataChar, "mainFrameWidth", 50, 800, 1, L.MAIN_FRAME_WIDTH, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame:SetWidth(GuidelimeDataChar.mainFrameWidth) 
			addon.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		end
	end)
	slider:SetScript("OnMouseUp", function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -10)
	slider = addon.addSliderOption(addon.optionsFrame, GuidelimeDataChar, "mainFrameHeight", 50, 600, 1, L.MAIN_FRAME_HEIGHT, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame:SetHeight(GuidelimeDataChar.mainFrameHeight) 
			addon.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		end
	end)
	slider:SetScript("OnMouseUp", function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -50)
	local slider = addon.addSliderOption(addon.optionsFrame, GuidelimeDataChar, "mainFrameAlpha", 0, 1, 0.01, L.MAIN_FRAME_ALPHA, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame:SetBackdropColor(1,1,1,GuidelimeDataChar.mainFrameAlpha)
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -90)
	
	slider = addon.addSliderOption(addon.optionsFrame, GuidelimeData, "maxNumOfSteps", 0, 20, 1, L.MAX_NUM_OF_STEPS)
	slider:SetScript("OnMouseUp", function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -130)
	
	local checkbox = addon.addCheckOption(addon.optionsFrame, GuidelimeDataChar, "mainFrameLocked", L.LOCK_MAINFRAME, nil, function()
		if GuidelimeDataChar.mainFrameLocked then
	    	addon.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Unlocked-Down")
	    	addon.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Locked-Up")
		else
	    	addon.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Unlocked-Down")
	    	addon.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Locked-Up")
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox
	
	checkbox = addon.addCheckOption(addon.optionsFrame, GuidelimeDataChar, "autoCompleteQuest", L.AUTO_COMPLETE_QUESTS)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox

	checkbox = addon.addCheckOption(addon.optionsFrame, GuidelimeDataChar, "hideCompletedSteps", L.HIDE_COMPLETED_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox
	
	checkbox = addon.addCheckOption(addon.optionsFrame, GuidelimeDataChar, "hideUnavailableSteps", L.HIDE_UNAVAILABLE_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox
	
	checkbox = addon.addCheckOption(addon.optionsFrame, GuidelimeDataChar, "showArrow", L.SHOW_ARROW, nil, function()
		if addon.arrowFrame ~= nil then
			if GuidelimeDataChar.showArrow then
				addon.arrowFrame:Show()
			else
				addon.arrowFrame:Hide()
			end
			addon.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox
	
	slider = addon.addSliderOption(addon.optionsFrame, GuidelimeData, "arrowStyle", 1, 2, 1, L.ARROW_STYLE, nil, 
	function(self)
		self.editbox:SetText(L["ARROW_STYLE" .. GuidelimeData.arrowStyle])
    	self.editbox:SetCursorPosition(0)
	end)
	slider:SetScript("OnMouseUp", function()
		if addon.arrowFrame ~= nil then
			addon.setArrowTexture()
			addon.updateSteps() 
		end
	end)
	slider.editbox:SetText(L["ARROW_STYLE" .. GuidelimeData.arrowStyle])
    slider.editbox:SetCursorPosition(0)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -10)

	slider = addon.addSliderOption(addon.optionsFrame, GuidelimeDataChar, "arrowAlpha", 0, 1, 0.01, L.ARROW_ALPHA, nil, function()
		if addon.arrowFrame ~= nil then 
			addon.arrowFrame:SetAlpha(GuidelimeDataChar.arrowAlpha)
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -50)

	slider = addon.addSliderOption(addon.optionsFrame, GuidelimeData, "maxNumOfMarkers", 0, 62, 1, L.MAX_NUM_OF_MARKERS)
	slider:SetScript("OnMouseUp", function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateSteps()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -90)
	
	checkbox = addon.addCheckOption(addon.optionsFrame, GuidelimeData, "showQuestLevels", L.SHOW_QUEST_LEVELS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	checkbox = addon.addCheckOption(addon.optionsFrame, GuidelimeData, "showTooltips", L.SHOW_TOOLTIPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox
end

function addon.showOptions()
	if not addon.dataLoaded then loadData() end
	InterfaceOptionsFrame_Show() 
	InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame)
end
