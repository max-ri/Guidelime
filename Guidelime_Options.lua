local addonName, addon = ...
local L = addon.L

function Guidelime.loadOptionsFrame()
	Guidelime.guidesFrame = CreateFrame("FRAME")
	Guidelime.guidesFrame.name = L.TITLE
	InterfaceOptions_AddCategory(Guidelime.guidesFrame)
	Guidelime.fillGuides(Guidelime.guidesFrame)

	Guidelime.optionsFrame = CreateFrame("FRAME", nil, Guidelime.guidesFrame)
	Guidelime.optionsFrame.name = GAMEOPTIONS_MENU
	Guidelime.optionsFrame.parent = Guidelime.guidesFrame
	InterfaceOptions_AddCategory(Guidelime.optionsFrame)
	Guidelime.fillOptions(Guidelime.optionsFrame)
end

function Guidelime.fillGuides(guidesFrame)
	guidesFrame.text1 = guidesFrame:CreateFontString(nil, guidesFrame, "GameFontNormal")
	if GuidelimeDataChar.currentGuide ~= nil then
		guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. GuidelimeDataChar.currentGuide.name .. "\n")
	else
		guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ":\n")
	end
	guidesFrame.text1:SetPoint("TOPLEFT", 20, -30)
	
	guidesFrame.text2 = guidesFrame:CreateFontString(nil, guidesFrame, "GameFontNormal")
	guidesFrame.text2:SetText(L.AVAILABLE_GUIDES .. ":\n")
	guidesFrame.text2:SetPoint("TOPLEFT", guidesFrame.text1, "BOTTOMLEFT", 0, 8)
	
	guidesFrame.guidesScrollFrame = CreateFrame("SCROLLFRAME", nil, guidesFrame, "UIPanelScrollFrameTemplate")
	guidesFrame.guidesScrollFrame:SetWidth(guidesFrame:GetWidth() - 100)
	guidesFrame.guidesScrollFrame:SetHeight((guidesFrame:GetHeight() - 100) / 2)
	guidesFrame.guidesScrollFrame:SetPoint("TOPLEFT", guidesFrame.text2, "BOTTOMLEFT", 0, 8)
	
	guidesFrame.guidesScrollChild = CreateFrame("FRAME", nil, guidesFrame)
	guidesFrame.guidesScrollFrame:SetScrollChild(guidesFrame.guidesScrollChild);
	guidesFrame.guidesScrollChild:SetWidth(guidesFrame.guidesScrollFrame:GetWidth()- 50)
	
	guidesFrame.text3 = guidesFrame:CreateFontString(nil, guidesFrame, "GameFontNormal")
	guidesFrame.text3:SetText(L.DETAILS .. ":\n")
	guidesFrame.text3:SetPoint("TOPLEFT", guidesFrame.guidesScrollFrame, "BOTTOMLEFT", 0, 8)
	
	guidesFrame.detailsScrollFrame = CreateFrame("SCROLLFRAME", nil, guidesFrame, "UIPanelScrollFrameTemplate")
	guidesFrame.detailsScrollFrame:SetWidth(guidesFrame:GetWidth() - 30)
	guidesFrame.detailsScrollFrame:SetHeight((guidesFrame:GetHeight() - 100) / 2)
	guidesFrame.detailsScrollFrame:SetPoint("TOPLEFT", guidesFrame.text3, "BOTTOMLEFT", 0, 8)
	
	guidesFrame.detailsScrollChild = CreateFrame("FRAME", nil, guidesFrame)
	guidesFrame.detailsScrollFrame:SetScrollChild(guidesFrame.detailsScrollChild);
	guidesFrame.detailsScrollChild:SetWidth(guidesFrame.detailsScrollFrame:GetWidth())
end

local function addCheckOption(optionsFrame, optionsTable, option, previous, text, tooltip, updateFunction)
	optionsFrame.options[option] = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
	optionsFrame.options[option]:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 8)
	optionsFrame.options[option].text:SetText(text)
	optionsFrame.options[option].text:SetFontObject("GameFontNormal")
	if tooltip ~= nil then
		optionsFrame.options[option]:SetScript("OnEnter", function(this) GameTooltip:SetOwner(this, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(tooltip); GameTooltip:Show() end)
		optionsFrame.options[option]:SetScript("OnLeave", function(this) GameTooltip:Hide() end)
	end
	if optionsTable[option] ~= false then optionsFrame.options[option]:SetChecked(true) end
	optionsFrame.options[option]:SetScript("OnClick", function()
		optionsTable[option] = optionsFrame.options[option]:GetChecked() 
		if updateFunction ~= nil then updateFunction() end
	end)
	return optionsFrame.options[option]
end

function Guidelime.fillOptions(optionsFrame)
	optionsFrame.subtitle = optionsFrame:CreateFontString(nil, optionsFrame, "GameFontNormal")
	--optionsFrame.subtitle:SetText(GAMEOPTIONS_MENU..":\n")
	optionsFrame.subtitle:SetPoint("TOPLEFT", 20, -30 )
	local prev = optionsFrame.subtitle

	optionsFrame.options = {}		
	prev = addCheckOption(optionsFrame, GuidelimeDataChar, "mainFrameShowing", prev, L.SHOW_MAINFRAME, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			Guidelime.showMainFrame()
		elseif Guidelime.mainFrame ~= nil then
			HBDPins:RemoveAllWorldMapIcons(Guidelime)
			HBDPins:RemoveAllMinimapIcons(Guidelime)
			Guidelime.mainFrame:Hide()
		end
	end)
	prev = addCheckOption(optionsFrame, GuidelimeDataChar, "hideCompletedSteps", prev, L.HIDE_COMPLETED_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			Guidelime.updateMainFrame()
		end
	end)
end

function Guidelime.showGuides()
	if not Guidelime.dataLoaded then loadData() end
	InterfaceOptionsFrame_Show() 
	InterfaceOptionsFrame_OpenToCategory(Guidelime.guidesFrame)
end

function Guidelime.showOptions()
	if not Guidelime.dataLoaded then loadData() end
	InterfaceOptionsFrame_Show() 
	InterfaceOptionsFrame_OpenToCategory(Guidelime.optionsFrame)
end
