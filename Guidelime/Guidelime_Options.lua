local addonName, addon = ...
local L = addon.L

function addon.fillOptions()
	addon.optionsFrame = CreateFrame("FRAME", nil, addon.guidesFrame)
	addon.optionsFrame.name = GAMEOPTIONS_MENU
	addon.optionsFrame.parent = addonName
	InterfaceOptions_AddCategory(addon.optionsFrame)

	addon.optionsFrame.title = addon.optionsFrame:CreateFontString(nil, addon.optionsFrame, "GameFontNormal")
	addon.optionsFrame.title:SetText(addonName .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version") .." - " .. GAMEOPTIONS_MENU)
	addon.optionsFrame.title:SetPoint("TOPLEFT", 25, -24)
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
	
	local sliderW = addon.addSliderOption(addon.optionsFrame, GuidelimeDataChar, "mainFrameWidth", 50, 800, 1, L.MAIN_FRAME_WIDTH, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame:SetWidth(GuidelimeDataChar.mainFrameWidth) 
			addon.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		end
	end)
	sliderW:SetScript("OnMouseUp", function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	sliderW:SetPoint("TOPLEFT", prev, "TOPLEFT", 250, -20)
	sliderH = addon.addSliderOption(addon.optionsFrame, GuidelimeDataChar, "mainFrameHeight", 50, 600, 1, L.MAIN_FRAME_HEIGHT, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame:SetHeight(GuidelimeDataChar.mainFrameHeight) 
			addon.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		end
	end)
	sliderH:SetScript("OnMouseUp", function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	sliderH:SetPoint("TOPLEFT", prev, "TOPLEFT", 250, -60)
	sliderA = addon.addSliderOption(addon.optionsFrame, GuidelimeDataChar, "mainFrameAlpha", 0, 1, 0.01, L.MAIN_FRAME_ALPHA, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame:SetBackdropColor(0,0,0,GuidelimeDataChar.mainFrameAlpha)
		end
	end)
	sliderA:SetPoint("TOPLEFT", prev, "TOPLEFT", 250, -100)
	
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
	
	checkbox = addon.addCheckOption(addon.optionsFrame, GuidelimeDataChar, "hideCompletedSteps", L.HIDE_COMPLETED_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox
	
	checkbox = addon.addCheckOption(addon.optionsFrame, GuidelimeDataChar, "hideUnavailableSteps", L.HIDE_UNAVAILABLE_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox
	
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
