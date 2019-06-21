local addonName, addon = ...
local L = addon.L

function addon.loadOptionsFrame()
	if not addon.dataLoaded then loadData() end

	addon.fillGuides()
	addon.fillOptions()
end

function addon.fillGuides()
    addon.guidesFrame = CreateFrame("Frame", nil, UIParent)
    addon.guidesFrame.name = addonName
    InterfaceOptions_AddCategory(addon.guidesFrame)
	
    local scrollframe = CreateFrame("ScrollFrame", nil, addon.guidesFrame) 
    scrollframe:SetPoint('TOPLEFT', 5, -5)
    scrollframe:SetPoint('BOTTOMRIGHT', -5, 5)
    scrollframe:EnableMouseWheel(true)
    scrollframe:SetScript('OnMouseWheel', function(self, direction)
        if direction == 1 then
            scroll_value = math.max(self:GetVerticalScroll() - 50, 1)
            self:SetVerticalScroll(scroll_value)
            self:GetParent().scrollbar:SetValue(scroll_value) 
        elseif direction == -1 then
            scroll_value = math.min(self:GetVerticalScroll() + 50, 250)
            self:SetVerticalScroll(scroll_value)
            self:GetParent().scrollbar:SetValue(scroll_value)
        end
    end)
    addon.guidesFrame.scrollframe = scrollframe 

    local scrollbar = CreateFrame("Slider", nil, scrollframe, "UIPanelScrollBarTemplate") 
    scrollbar:SetPoint("TOPLEFT", addon.guidesFrame, "TOPRIGHT", -20, -20) 
    scrollbar:SetPoint("BOTTOMLEFT", addon.guidesFrame, "BOTTOMRIGHT", -20, 20) 
    scrollbar:SetMinMaxValues(1, 250) 
    scrollbar:SetValueStep(1) 
    scrollbar.scrollStep = 1 
    scrollbar:SetValue(0) 
    scrollbar:SetWidth(16) 
    scrollbar:SetScript("OnValueChanged", 
    function (self, value) 
    self:GetParent():SetVerticalScroll(value) 
    end) 
    local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND") 
    scrollbg:SetAllPoints(scrollbar) 
    scrollbg:SetColorTexture(0, 0, 0, 0.6) 
    addon.guidesFrame.scrollbar = scrollbar
    
    local content = CreateFrame("Frame", nil, scrollframe) 
    content:SetSize(1, 1) 
    scrollframe.content = content 
    scrollframe:SetScrollChild(content)

	addon.guidesFrame.title = content:CreateFontString(nil, content, "GameFontNormal")
	addon.guidesFrame.title:SetText(addonName .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version"))
	addon.guidesFrame.title:SetPoint("TOPLEFT", content, "TOPLEFT", 20, -20)
	addon.guidesFrame.title:SetFontObject("GameFontNormalLarge")
	local prev = addon.guidesFrame.title
	
	addon.guidesFrame.text1 = content:CreateFontString(nil, content, "GameFontNormal")
	if GuidelimeDataChar.currentGuide ~= nil then
		addon.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. GuidelimeDataChar.currentGuide.name .. "\n")
	else
		addon.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ":\n")
	end
	addon.guidesFrame.text1:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -30)
	prev = addon.guidesFrame.text1
	
	addon.guidesFrame.text2 = content:CreateFontString(nil, content, "GameFontNormal")
	addon.guidesFrame.text2:SetText(L.AVAILABLE_GUIDES .. ":\n")
	addon.guidesFrame.text2:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
	prev = addon.guidesFrame.text2

	local groups = {}
	for name, guide in pairs(addon.guides) do
		if groups[guide.group] == nil then groups[guide.group] = {} end
		table.insert(groups[guide.group], name)
	end
	
	local i = 1
	addon.guidesFrame.groups = {}
	addon.guidesFrame.guides = {}
	for group, guides in pairs(groups) do
		addon.guidesFrame.groups[group] = content:CreateFontString(nil, content, "GameFontNormal")
		addon.guidesFrame.groups[group]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
		addon.guidesFrame.groups[group]:SetText(group)
		prev = addon.guidesFrame.groups[group]

		for j, name in ipairs(guides) do
			local guide = addon.guides[name]
			
			addon.guidesFrame.guides[i] = CreateFrame("EditBox", nil, content)
			addon.guidesFrame.guides[i]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
			addon.guidesFrame.guides[i]:EnableMouse(false)
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
				bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
				tile = true, tileSize = 32, edgeSize = 0
			})
			addon.guidesFrame.guides[i].index = i
			addon.guidesFrame.guides[i].guide = guide
			if name == GuidelimeDataChar.currentGuide.name then
				addon.guidesFrame.selectedIndex = i
				addon.guidesFrame.guides[i]:SetBackdropColor(255,255,255,128)	
			else
				addon.guidesFrame.guides[i]:SetBackdropColor(0,0,0,0)	
			end
			addon.guidesFrame.guides[i]:SetScript("OnMouseUp", function(self)
				addon.guidesFrame.guides[addon.guidesFrame.selectedIndex]:SetBackdropColor(0,0,0,0)	
				addon.guidesFrame.selectedIndex = self.index
				self:SetBackdropColor(255,255,255,128)
				addon.guidesFrame.textDetails:SetText(self.guide.details or "")
	    		self:ClearFocus()
			end)
			prev = addon.guidesFrame.guides[i]
			i = i + 1
		end
	end
		
	addon.guidesFrame.text3 = content:CreateFontString(nil, content, "GameFontNormal")
	addon.guidesFrame.text3:SetText(L.DETAILS .. ":\n")
	addon.guidesFrame.text3:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
	prev = addon.guidesFrame.text3

	addon.guidesFrame.textDetails = CreateFrame("EditBox", nil, content)
	addon.guidesFrame.textDetails:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	addon.guidesFrame.textDetails:SetMultiLine(true)
	addon.guidesFrame.textDetails:EnableMouse(false)
	addon.guidesFrame.textDetails:SetAutoFocus(false)
	addon.guidesFrame.textDetails:SetFontObject("GameFontNormal")
	addon.guidesFrame.textDetails:SetWidth(550)
	addon.guidesFrame.textDetails:SetTextColor(255,255,255,255)
	addon.guidesFrame.textDetails:SetText(addon.guides[GuidelimeDataChar.currentGuide.name].details or "")
	
	--addon.guidesFrame.scrollframe.content:SetHeight(100)
	--addon.guidesFrame.scrollframe:UpdateScrollChildRect();
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
	local checkbox = addCheckOption(GuidelimeDataChar, "mainFrameLocked", L.LOCK_MAINFRAME, nil, function()
		if GuidelimeDataChar.mainFrameLocked then
			addon.mainFrame.lockBtn:SetButtonState("NORMAL")
		else
			addon.mainFrame.lockBtn:SetButtonState("PUSHED")
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox
	checkbox = addCheckOption(GuidelimeDataChar, "hideCompletedSteps", L.HIDE_COMPLETED_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			addon.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 8)
	prev = checkbox
	local slider = addSliderOption(GuidelimeDataChar, "mainFrameWidth", 50, 800, 1, L.MAIN_FRAME_WIDTH, nil, function()
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
	slider:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -30)
	slider = addSliderOption(GuidelimeDataChar, "mainFrameHeight", 50, 600, 1, L.MAIN_FRAME_HEIGHT, nil, function()
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
	slider:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 270, -30)
end

function addon.showGuides()
	if not addon.dataLoaded then loadData() end
	InterfaceOptionsFrame_Show() 
	InterfaceOptionsFrame_OpenToCategory(addon.guidesFrame)

	addon.guidesFrame.scrollframe.content:SetHeight(addon.guidesFrame.scrollframe:GetHeight())
	addon.guidesFrame.scrollframe:UpdateScrollChildRect();

end

function addon.showOptions()
	if not addon.dataLoaded then loadData() end
	InterfaceOptionsFrame_Show() 
	InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame)
end
