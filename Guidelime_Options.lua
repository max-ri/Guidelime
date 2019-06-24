local addonName, addon = ...
local L = addon.L

function addon.loadOptionsFrame()
	if not addon.dataLoaded then loadData() end

	addon.fillGuides()
	addon.fillOptions()
end
local function loadSelectedGuide() 
	addon.guidesFrame.loadBtn:SetText(L.RESET_GUIDE)
	GuidelimeDataChar.currentGuide = {name = addon.guidesFrame.guides[addon.guidesFrame.selectedIndex].guide.name, skip = {}}
	addon.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. GuidelimeDataChar.currentGuide.name .. "\n")
	addon.loadGuide()
	addon.updateFromQuestLog()
	if GuidelimeDataChar.mainFrameShowing then
		addon.updateMainFrame()
	end
end

function addon.fillGuides()
    addon.guidesFrame = CreateFrame("Frame", nil, UIParent)
    addon.guidesFrame.name = addonName
    InterfaceOptions_AddCategory(addon.guidesFrame)
	
	addon.guidesFrame.title = addon.guidesFrame:CreateFontString(nil, addon.guidesFrame, "GameFontNormal")
	addon.guidesFrame.title:SetText(addonName .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version"))
	addon.guidesFrame.title:SetPoint("TOPLEFT", addon.guidesFrame, "TOPLEFT", 20, -20)
	addon.guidesFrame.title:SetFontObject("GameFontNormalLarge")
	local prev = addon.guidesFrame.title
	
	addon.guidesFrame.text1 = addon.guidesFrame:CreateFontString(nil, addon.guidesFrame, "GameFontNormal")
	if GuidelimeDataChar.currentGuide ~= nil then
		addon.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. GuidelimeDataChar.currentGuide.name .. "\n")
	else
		addon.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ":\n")
	end
	addon.guidesFrame.text1:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -30)
	prev = addon.guidesFrame.text1
	
	addon.guidesFrame.text2 = addon.guidesFrame:CreateFontString(nil, addon.guidesFrame, "GameFontNormal")
	addon.guidesFrame.text2:SetText(L.AVAILABLE_GUIDES .. ":\n")
	addon.guidesFrame.text2:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = addon.guidesFrame.text2

    local scrollFrame = CreateFrame("ScrollFrame", nil, addon.guidesFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -20)
    scrollFrame:SetPoint("RIGHT", addon.guidesFrame, "RIGHT", -30, 0)
    scrollFrame:SetPoint("BOTTOM", addon.guidesFrame, "BOTTOM", 0, 160)

    local content = CreateFrame("Frame", nil, scrollFrame) 
    content:SetSize(1, 1) 
    scrollFrame:SetScrollChild(content)
	prev = content

	local groups = {}
	local groupNames = {}
	for name, guide in pairs(addon.guides) do
		if groups[guide.group] == nil then 
			groups[guide.group] = {} 
		table.insert(groupNames, guide.group)
		end
		table.insert(groups[guide.group], name)
	end
	table.sort(groupNames)
	
	local i = 1
	addon.guidesFrame.groups = {}
	addon.guidesFrame.guides = {}
	for _, group, guides in ipairs(groupNames) do
		local guides = groups[group]
		table.sort(guides)
		addon.guidesFrame.groups[group] = content:CreateFontString(nil, content, "GameFontNormal")
		addon.guidesFrame.groups[group]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
		addon.guidesFrame.groups[group]:SetText(group)
		prev = addon.guidesFrame.groups[group]

		for j, name in ipairs(guides) do
			local guide = addon.guides[name]
			if addon.debugging then print("LIME: group ", group, name) end
			
			addon.guidesFrame.guides[i] = CreateFrame("EditBox", nil, content)
			addon.guidesFrame.guides[i]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
			addon.guidesFrame.guides[i]:SetMultiLine(true)
			addon.guidesFrame.guides[i]:SetAutoFocus(false)
			addon.guidesFrame.guides[i]:SetFontObject("GameFontNormal")
			addon.guidesFrame.guides[i]:SetWidth(550)
			addon.guidesFrame.guides[i]:SetTextColor(255,255,255,255)
			local text = "    "
			if guide.minLevel ~= nil then
				text = text .. addon.getLevelColor(guide.minLevel) .. guide.minLevel .. "|r"
			end
			if guide.minLevel ~= nil or guide.maxLevel ~= nil then
				text = text .. "-"
			end
			if guide.maxLevel ~= nil then
				text = text .. addon.getLevelColor(guide.maxLevel) .. guide.maxLevel .. "|r"
			end
			if guide.minLevel ~= nil or guide.maxLevel ~= nil then
				text = text .. " "
			end
			if guide.title ~= nil then
				text = text .. guide.title
			end
			addon.guidesFrame.guides[i]:SetText(text)
			addon.guidesFrame.guides[i]:SetBackdrop({
				--bgFile = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight",
				bgFile = "Interface\\AddOns\\Guidelime\\Icons\\TitleHighlight",
				tile = false, edgeSize = 0
			})
			addon.guidesFrame.guides[i].index = i
			addon.guidesFrame.guides[i].guide = guide
			if name == GuidelimeDataChar.currentGuide.name then
				addon.guidesFrame.selectedIndex = i
				addon.guidesFrame.guides[i]:SetBackdropColor(1,1,0,1)	
			else
				addon.guidesFrame.guides[i]:SetBackdropColor(0,0,0,0)	
			end
			addon.guidesFrame.guides[i]:SetScript("OnMouseUp", function(self)
				addon.guidesFrame.guides[addon.guidesFrame.selectedIndex]:SetBackdropColor(0,0,0,0)	
				addon.guidesFrame.selectedIndex = self.index
				self:SetBackdropColor(1,1,0,1)
				addon.guidesFrame.textDetails:SetText(self.guide.details or "")
				if GuidelimeDataChar.currentGuide.name == self.guide.name then
					addon.guidesFrame.loadBtn:SetText(L.RESET_GUIDE)
				else
					addon.guidesFrame.loadBtn:SetText(L.LOAD_GUIDE)
				end
				-- Double-Click?				
			    if self.timer ~= nil and self.timer < time() then
			        self.timer = nil
			    elseif self.timer ~= nil and self.timer == time() then
			        self.timer = nil
					loadSelectedGuide()
			    else
			        self.timer = time()
			    end
			end)
			addon.guidesFrame.guides[i]:SetScript("OnEnter", function(self)
				if addon.guidesFrame.selectedIndex ~= self.index then
					self:SetBackdropColor(0.5,0.5,1,1)	
				end
			end)
			addon.guidesFrame.guides[i]:SetScript("OnLeave", function(self)
				if addon.guidesFrame.selectedIndex ~= self.index then
					self:SetBackdropColor(0,0,0,0)	
				end
			end)
    		addon.guidesFrame.guides[i]:SetScript("OnEditFocusGained", function (self) self:ClearFocus() end)
			addon.guidesFrame.guides[i]:SetAutoFocus(false)
			prev = addon.guidesFrame.guides[i]
			i = i + 1
		end
	end
	prev = scrollFrame
	
	addon.guidesFrame.text3 = addon.guidesFrame:CreateFontString(nil, addon.guidesFrame, "GameFontNormal")
	addon.guidesFrame.text3:SetText(L.DETAILS .. ":\n")
	addon.guidesFrame.text3:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
	prev = addon.guidesFrame.text3

	addon.guidesFrame.textDetails = CreateFrame("EditBox", nil, addon.guidesFrame)
	addon.guidesFrame.textDetails:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	addon.guidesFrame.textDetails:SetMultiLine(true)
	addon.guidesFrame.textDetails:SetFontObject("GameFontNormal")
	addon.guidesFrame.textDetails:SetWidth(550)
	addon.guidesFrame.textDetails:SetTextColor(255,255,255,255)
	addon.guidesFrame.textDetails:SetText(addon.guides[GuidelimeDataChar.currentGuide.name].details or "")
    addon.guidesFrame.textDetails:SetScript("OnEditFocusGained", function (self) self:ClearFocus() end)
	addon.guidesFrame.textDetails:SetAutoFocus(false)
	
	addon.guidesFrame.loadBtn = CreateFrame("BUTTON", nil, addon.guidesFrame, "UIPanelButtonTemplate")
	addon.guidesFrame.loadBtn:SetWidth(120)
	addon.guidesFrame.loadBtn:SetHeight(30)
	addon.guidesFrame.loadBtn:SetText(L.RESET_GUIDE)
	addon.guidesFrame.loadBtn:SetPoint("BOTTOMLEFT", addon.guidesFrame, "BOTTOMLEFT", 20, 20)
	addon.guidesFrame.loadBtn:SetScript("OnClick", loadSelectedGuide)
end

local function addSliderOption(optionsTable, option, min, max, step, text, tooltip, updateFunction, mouseUpFunction)
    local slider = CreateFrame("Slider", addonName .. option, addon.optionsFrame, "OptionsSliderTemplate")
	addon.optionsFrame.options[option] = slider
    slider.editbox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
	slider:SetValue(optionsTable[option])
    slider.text = _G[addonName .. option .. "Text"]
    slider.text:SetText(text)
    slider.textLow = _G[addonName .. option .. "Low"]
    slider.textHigh = _G[addonName .. option .. "High"]
    slider.textLow:SetText(floor(min))
    slider.textHigh:SetText(floor(max))
    slider.textLow:SetTextColor(0.8,0.8,0.8)
    slider.textHigh:SetTextColor(0.8,0.8,0.8)
    slider:SetObeyStepOnDrag(true)
    slider.editbox:SetSize(45,30)
    slider.editbox:ClearAllPoints()
    slider.editbox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    slider.editbox:SetText(tostring(optionsTable[option]))
    slider.editbox:SetCursorPosition(0)
    slider.editbox:SetAutoFocus(false)
    slider:SetScript("OnValueChanged", function(self)
        slider.editbox:SetText(tostring(slider:GetValue()))
		optionsTable[option] = slider:GetValue()
		if updateFunction ~= nil then updateFunction() end
    end)
	if mouseUpFunction ~= nil then
		slider:SetScript("OnMouseUp", mouseUpFunction)
	end
    slider.editbox:SetScript("OnEnterPressed", function()
        local val = slider.editbox:GetText()
        if tonumber(val) then
            slider:SetValue(val)
            slider.editbox:ClearFocus()
			if mouseUpFunction ~= nil then mouseUpFunction() end
        end
    end)
	if tooltip ~= nil then
		slider:SetScript("OnEnter", function(this) GameTooltip:SetOwner(this, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(tooltip); GameTooltip:Show() end)
		slider:SetScript("OnLeave", function(this) GameTooltip:Hide() end)
	end
    return slider
end


local function addCheckOption(optionsTable, option, text, tooltip, updateFunction)
	local checkbox = CreateFrame("CheckButton", addonName .. option, addon.optionsFrame, "UICheckButtonTemplate")
	addon.optionsFrame.options[option] = checkbox
	checkbox.text:SetText(text)
	checkbox.text:SetFontObject("GameFontNormal")
	if tooltip ~= nil then
		checkbox:SetScript("OnEnter", function(this) GameTooltip:SetOwner(this, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(tooltip); GameTooltip:Show() end)
		checkbox:SetScript("OnLeave", function(this) GameTooltip:Hide() end)
	end
	if optionsTable[option] ~= false then checkbox:SetChecked(true) end
	checkbox:SetScript("OnClick", function()
		optionsTable[option] = checkbox:GetChecked() 
		if updateFunction ~= nil then updateFunction() end
	end)
	return checkbox
end

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
	local checkbox = addCheckOption(GuidelimeDataChar, "mainFrameShowing", L.SHOW_MAINFRAME, nil, function()
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
	
	local sliderW = addSliderOption(GuidelimeDataChar, "mainFrameWidth", 50, 800, 1, L.MAIN_FRAME_WIDTH, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame:SetWidth(GuidelimeDataChar.mainFrameWidth) 
			addon.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		end
	end, 
	function()
		if addon.debugging then print("LIME: change width",GuidelimeDataChar.mainFrameWidth, GuidelimeDataChar.mainFrameHeight) end
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	sliderW:SetPoint("TOPLEFT", prev, "TOPLEFT", 250, -20)
	sliderH = addSliderOption(GuidelimeDataChar, "mainFrameHeight", 50, 600, 1, L.MAIN_FRAME_HEIGHT, nil, function()
		if addon.mainFrame ~= nil then 
			addon.mainFrame:SetHeight(GuidelimeDataChar.mainFrameHeight) 
			addon.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		end
	end, 
	function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	sliderH:SetPoint("TOPLEFT", prev, "TOPLEFT", 250, -60)
	
	local checkbox = addCheckOption(GuidelimeDataChar, "mainFrameLocked", L.LOCK_MAINFRAME, nil, function()
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
	
	checkbox = addCheckOption(GuidelimeDataChar, "hideCompletedSteps", L.HIDE_COMPLETED_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox
	
	checkbox = addCheckOption(GuidelimeData, "showQuestLevels", L.SHOW_QUEST_LEVELS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox
end

function addon.showGuides()
	if not addon.dataLoaded then loadData() end
	InterfaceOptionsFrame_Show() 
	InterfaceOptionsFrame_OpenToCategory(addon.guidesFrame)

	--addon.guidesFrame.scrollframe.content:SetHeight(addon.guidesFrame.scrollframe:GetHeight())
	--addon.guidesFrame.scrollframe:UpdateScrollChildRect();

end

function addon.showOptions()
	if not addon.dataLoaded then loadData() end
	InterfaceOptionsFrame_Show() 
	InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame)
end
