local addonName, addon = ...
local L = addon.L

local LibDBIcon = LibStub("LibDBIcon-1.0")

addon.QT = addon.QT or {}; local QT = addon.QT -- Data/QuestTools
addon.D = addon.D or {}; local D = addon.D     -- Data/Data
addon.AB = addon.AB or {}; local AB = addon.AB -- ActionButtons
addon.CG = addon.CG or {}; local CG = addon.CG -- CurrentGuide
addon.E = addon.E or {}; local E = addon.E     -- Editor
addon.EV = addon.EV or {}; local EV = addon.EV -- Events
addon.F = addon.F or {}; local F = addon.F     -- Frames
addon.G = addon.G or {}; local G = addon.G     -- Guides
addon.M = addon.M or {}; local M = addon.M     -- Map
addon.MW = addon.MW or {}; local MW = addon.MW -- MainWindow

addon.O = addon.O or {}; local O = addon.O     -- Options

local function HexToRGB(hex)
	local rhex, ghex, bhex = string.sub(hex, 5, 6), string.sub(hex, 7, 8), string.sub(hex, 9, 10)
	return tonumber(rhex, 16) / 255, tonumber(ghex, 16) / 255, tonumber(bhex, 16) / 255
end

local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("|cFF%02x%02x%02x", r*255, g*255, b*255)
end

local function showColorPicker(color, callback)
	ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = false, nil;
	local r,g,b = HexToRGB(color)
	ColorPickerFrame.previousValues = {r,g,b,1};
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = callback, nil, nil;
	ColorPickerFrame:SetColorRGB(r,g,b);
	ColorPickerFrame:Hide(); -- Need to run the OnShow handler.
	ColorPickerFrame:Show();
end

local function getColorPickerColor()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	return RGBToHex(r, g, b)
end

function O.fillOptions()
	O.optionsFrame = CreateFrame("FRAME", nil, nil)
	O.optionsFrame.name = addonName
	InterfaceOptions_AddCategory(O.optionsFrame)

	O.optionsFrame.title = O.optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	O.optionsFrame.title:SetText(GetAddOnMetadata(addonName, "title") .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version") .." - " .. GAMEOPTIONS_MENU)
	O.optionsFrame.title:SetPoint("TOPLEFT", 20, -20)
	O.optionsFrame.title:SetFontObject("GameFontNormalLarge")
	local prev = O.optionsFrame.title

    local scrollFrame = CreateFrame("ScrollFrame", nil, O.optionsFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -20)
    scrollFrame:SetPoint("RIGHT", O.optionsFrame, "RIGHT", -30, 0)
    scrollFrame:SetPoint("BOTTOM", O.optionsFrame, "BOTTOM", 0, 10)

    local content = CreateFrame("Frame", nil, scrollFrame) 
    content:SetSize(1, 1) 
    scrollFrame:SetScrollChild(content)
	prev = content
	content.options = {}		

	local importButton = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	importButton:SetWidth(270)
	importButton:SetHeight(24)
	importButton:SetText(L.IMPORT_SETTINGS)
	importButton:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -4)
	importButton:SetScript("OnClick", function()
		local menu = {}
		local oppositeFaction = {}
		if GuidelimeData.chars then
			for guid, settings in pairs(GuidelimeData.chars) do
				if guid ~= UnitGUID("player") then
					local _, class, _, race, sex, name, realm = GetPlayerInfoByGUID(guid)
					if name then
						local menuItem = {
							text = D.getRaceIconText(race, sex, 18) ..
								D.getClassIconText(class, 18) .. " " ..
								--"|T" .. addon.icons[class] .. ":18|t " ..
								name .. (realm ~= "" and ("-" .. (realm or "?")) or ""), 
							colorCode = "|c" .. select(4, GetClassColor(class)),
							-- icon = addon.icons[class],
							notCheckable = true, 
							func = function()
								GuidelimeDataChar = settings
								ReloadUI()
							end
						}
						if D.races[race] == D.races[D.race] then
							menu[#menu + 1] = menuItem
						else
							oppositeFaction[#oppositeFaction + 1] = menuItem
						end
					end
				end
			end
			if #oppositeFaction > 0 then
				menu[#menu + 1] = { text = D.races[D.race] == "Alliance" and L.Horde or L.Alliance, notCheckable = true, isTitle = true }
				for _, menuItem in ipairs(oppositeFaction) do
					menu[#menu + 1] = menuItem
				end
			end
			if #menu > 0 then
				EasyMenu(menu, CreateFrame("Frame", "GuidelimeImportMenu", nil, "UIDropDownMenuTemplate"), "cursor", 0 , 0, "MENU")
			end
		end
	end)
	prev = importButton

	local defaultButton = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	defaultButton:SetWidth(310)
	defaultButton:SetHeight(24)
	defaultButton:SetText(L.DEFAULT_SETTINGS)
	defaultButton:SetPoint("TOPLEFT", prev, "TOPRIGHT", 0, 0)
	defaultButton:SetScript("OnClick", function()
		GuidelimeData.defaultCharOptions = GuidelimeDataChar
	end)

	--[[local button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(205)
	button:SetHeight(24)
	button:SetText(L.EDIT_KEYBINDINGS)
	button:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -4)
	button:SetScript("OnClick", function()
		ShowUIPanel(KeyBindingFrame, true)
	end)]]

	F.addCheckOption(content, GuidelimeDataChar, "showMinimapButton", L.SHOW_MINIMAP_BUTTON, nil, function()
		content.options.showMinimapButtonHiddenMainframe:SetChecked(false)
		addon.setupMinimapButton()
	end)
	content.options.showMinimapButton:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	content.options.showMinimapButtonHiddenMainframe = F.addCheckbox(content, L.ONLY_WHEN_MAINFRAME_HIDDEN)
	if GuidelimeDataChar.showMinimapButton == "hiddenMainFrame" then 
		content.options.showMinimapButtonHiddenMainframe:SetChecked(true) 
		content.options.showMinimapButton:SetChecked(false)
	end
	content.options.showMinimapButtonHiddenMainframe:SetScript("OnClick", function(checkbox)
		GuidelimeDataChar.showMinimapButton = checkbox:GetChecked() and "hiddenMainFrame"
		content.options.showMinimapButton:SetChecked(false)
		addon.setupMinimapButton()
	end)
	content.options.showMinimapButtonHiddenMainframe:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 180, -10)

	prev = content.options.showMinimapButton

	-- Guide window options

	O.optionsFrame.titleGuideWindow = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	O.optionsFrame.titleGuideWindow:SetText("|cFFFFFFFF___ " .. L.GUIDE_WINDOW:gsub("^%l", string.upper) .. " _______________________________________________________")
	O.optionsFrame.titleGuideWindow:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	O.optionsFrame.titleGuideWindow:SetFontObject("GameFontNormalLarge")
	local prev = O.optionsFrame.titleGuideWindow

	O.optionsFrame.mainFrameShowing = F.addCheckOption(content, GuidelimeDataChar, "mainFrameShowing", L.SHOW_MAINFRAME, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			MW.showMainFrame()
		else
			MW.hideMainFrame()
		end
	end)
	O.optionsFrame.mainFrameShowing:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = O.optionsFrame.mainFrameShowing
	
	local button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(130)
	button:SetHeight(24)
	button:SetText(L.RESET_POSITION)
	button:SetPoint("TOPLEFT", prev, "TOPLEFT", 180, -4)
	button:SetScript("OnClick", function()
		GuidelimeDataChar.mainFrameX = 0
		GuidelimeDataChar.mainFrameY = 0
		GuidelimeDataChar.mainFrameRelative = "RIGHT"
		if MW.mainFrame ~= nil then
			MW.mainFrame:ClearAllPoints()
			MW.mainFrame:SetPoint(GuidelimeDataChar.mainFrameRelative, UIParent, GuidelimeDataChar.mainFrameRelative, GuidelimeDataChar.mainFrameX, GuidelimeDataChar.mainFrameY)
		end
	end)

	O.optionsFrame.mainFrameWidth = F.addSliderOption(content, GuidelimeDataChar, "mainFrameWidth", 250, 1000, 1, L.MAIN_FRAME_WIDTH, nil, function()
		if MW.mainFrame ~= nil then 
			MW.mainFrame:SetWidth(GuidelimeDataChar.mainFrameWidth) 
			MW.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
			MW.mainFrame.titleBox:SetWidth(GuidelimeDataChar.mainFrameWidth - 40)
		end
	end, function()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame(true)
		end
	end)
	O.optionsFrame.mainFrameWidth:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -10)
	O.optionsFrame.mainFrameHeight = F.addSliderOption(content, GuidelimeDataChar, "mainFrameHeight", 250, 1000, 1, L.MAIN_FRAME_HEIGHT, nil, function()
		if MW.mainFrame ~= nil then 
			MW.mainFrame:SetHeight(GuidelimeDataChar.mainFrameHeight) 
			MW.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		end
	end, function()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	O.optionsFrame.mainFrameHeight:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -50)
	local slider = F.addSliderOption(content, GuidelimeDataChar, "mainFrameAlpha", 0, 1, 0.01, L.MAIN_FRAME_ALPHA, nil, function()
		if MW.mainFrame ~= nil then 
			MW.mainFrame.bg:SetColorTexture(0, 0, 0, GuidelimeDataChar.mainFrameAlpha)
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -90)
	
	slider = F.addSliderOption(content, GuidelimeDataChar, "mainFrameFontSize", 8, 24, 1, L.MAIN_FRAME_FONT_SIZE, nil, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame(true)
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -130)

	slider = F.addSliderOption(content, GuidelimeData, "maxNumOfSteps", 0, 50, 1, L.MAX_NUM_OF_STEPS, nil, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -180)

	O.optionsFrame.mainFrameLocked = F.addCheckOption(content, GuidelimeDataChar, "mainFrameLocked", L.LOCK_MAINFRAME, nil, function()
		if GuidelimeDataChar.mainFrameLocked then
	    	MW.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Unlocked-Down")
	    	MW.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Locked-Up")
		else
	    	MW.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Unlocked-Down")
	    	MW.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Locked-Up")
		end
	end)
	O.optionsFrame.mainFrameLocked:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = O.optionsFrame.mainFrameLocked
	
	O.optionsFrame.showCompletedSteps = F.addCheckOption(content, GuidelimeDataChar, "mainFrameShowScrollBar", L.MAIN_FRAME_SHOW_SCROLLBAR, nil, function()
		MW.mainFrame.scrollFrame.ScrollBar:SetAlpha(GuidelimeDataChar.mainFrameShowScrollBar and 1 or 0)
		MW.mainFrame.scrollFrame.ScrollBar:SetEnabled(GuidelimeDataChar.mainFrameShowScrollBar)
		MW.mainFrame.scrollFrame.ScrollBar:SetFrameLevel(GuidelimeDataChar.mainFrameShowScrollBar and 1000 or 0)
		if GuidelimeDataChar.showUseItemButtons == "RIGHT" or GuidelimeDataChar.showTargetButtons == "RIGHT" then
			AB.updateTargetButtons()
			AB.updateUseItemButtons()
		end
	end)
	O.optionsFrame.showCompletedSteps:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = O.optionsFrame.showCompletedSteps

	O.optionsFrame.showTitle = F.addCheckOption(content, GuidelimeDataChar, "showTitle", L.SHOW_GUIDE_TITLE, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	O.optionsFrame.showTitle:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = O.optionsFrame.showTitle

	O.optionsFrame.showCompletedSteps = F.addCheckOption(content, GuidelimeDataChar, "showCompletedSteps", L.SHOW_COMPLETED_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	O.optionsFrame.showCompletedSteps:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = O.optionsFrame.showCompletedSteps
	
	O.optionsFrame.showUnavailableSteps = F.addCheckOption(content, GuidelimeDataChar, "showUnavailableSteps", L.SHOW_UNAVAILABLE_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	O.optionsFrame.showUnavailableSteps:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = O.optionsFrame.showUnavailableSteps
	
	checkbox = F.addCheckOption(content, GuidelimeData, "showQuestLevels", L.SHOW_SUGGESTED_QUEST_LEVELS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			CG.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	checkbox = F.addCheckOption(content, GuidelimeData, "showMinimumQuestLevels", L.SHOW_MINIMUM_QUEST_LEVELS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			CG.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	local text = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetText(L.SHOW_TARGET_BUTTONS)
	text:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = text
	local choices = {"LEFT", "RIGHT"}
	for i, v in ipairs(choices) do
		content.options["showTargetButtons" .. v] = F.addCheckbox(content, L["BUTTONS_" .. v])
		content.options["showTargetButtons" .. v]:SetChecked(GuidelimeDataChar.showTargetButtons == v)
		content.options["showTargetButtons" .. v]:SetScript("OnClick", function()
			if InCombatLockdown() then 
				content.options["showTargetButtons" .. v]:SetChecked(GuidelimeDataChar.showTargetButtons == v)
				return 
			end
			GuidelimeDataChar.showTargetButtons = content.options["showTargetButtons" .. v]:GetChecked() and v
			for _, v2 in ipairs(choices) do
				content.options["showTargetButtons" .. v2]:SetChecked(GuidelimeDataChar.showTargetButtons == v2)
			end
			CG.loadCurrentGuide(false)
			EV.updateFromQuestLog()
			if GuidelimeDataChar.mainFrameShowing then
				MW.updateMainFrame()
			end
		end)
		content.options["showTargetButtons" .. v]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", (i - 1) * 180, 0)
	end
	local slider = F.addSliderOption(content, GuidelimeDataChar, "maxNumOfTargetButtons", 0, 20, 1, L.MAX_NUM_OF_TARGET_BUTTONS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -20)
	
	local markers = ""
	for i, _ in ipairs(AB.targetRaidMarkerIndex) do markers = markers .. AB.getTargetButtonIconText(i, true) end
	checkbox = F.addCheckOption(content, GuidelimeData, "targetRaidMarkers", string.format(L.TARGET_RAID_MARKERS, markers), nil, function()
		if InCombatLockdown() then 
			content.options.targetRaidMarkers:SetChecked(not content.options.targetRaidMarkers:GetChecked())
			GuidelimeData.targetRaidMarkers = content.options.targetRaidMarkers:GetChecked()
			return 
		end
		if MW.mainFrame then
			AB.resetButtons(MW.mainFrame.targetButtons)
			MW.mainFrame.targetButtons = nil
		end
		if GuidelimeDataChar.mainFrameShowing then
			CG.updateStepsText()
			AB.updateTargetButtons()
			AB.updateUseItemButtons()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -30)
	prev = checkbox

	local text = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetText(L.SHOW_USE_ITEM_BUTTONS)
	text:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = text
	local choices = {"LEFT", "RIGHT"}
	for i, v in ipairs(choices) do
		content.options["showUseItemButtons" .. v] = F.addCheckbox(content, L["BUTTONS_" .. v])
		content.options["showUseItemButtons" .. v]:SetChecked(GuidelimeDataChar.showUseItemButtons == v)
		content.options["showUseItemButtons" .. v]:SetScript("OnClick", function()
			if InCombatLockdown() then 
				content.options["showUseItemButtons" .. v]:SetChecked(GuidelimeDataChar.showUseItemButtons == v)
				return 
			end
			GuidelimeDataChar.showUseItemButtons = content.options["showUseItemButtons" .. v]:GetChecked() and v
			for _, v2 in ipairs(choices) do
				content.options["showUseItemButtons" .. v2]:SetChecked(GuidelimeDataChar.showUseItemButtons == v2)
			end
			CG.loadCurrentGuide(false)
			EV.updateFromQuestLog()
			if GuidelimeDataChar.mainFrameShowing then
				MW.updateMainFrame()
			end
			
		end)
		content.options["showUseItemButtons" .. v]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", (i - 1) * 180, 0)
	end
	local slider = F.addSliderOption(content, GuidelimeDataChar, "maxNumOfItemButtons", 0, 20, 1, L.MAX_NUM_OF_ITEM_BUTTONS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -20)

	text = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	text:SetText(L.SELECT_COLORS)
	text:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -40)
	prev = text

	button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(100)
	button:SetHeight(20)
	button:SetText(GuidelimeData.fontColorACCEPT .. L.QUEST_ACCEPT)
	button:SetPoint("TOPLEFT", prev, "TOPLEFT", 110, 4)
	button:SetScript("OnClick", function()
		showColorPicker(GuidelimeData.fontColorACCEPT, function()
			GuidelimeData.fontColorACCEPT = getColorPickerColor()
			button:SetText(GuidelimeData.fontColorACCEPT .. L.QUEST_ACCEPT)
			if GuidelimeDataChar.mainFrameShowing then
				CG.updateStepsText()
			end
		end)
	end)
	local button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(100)
	button:SetHeight(20)
	button:SetText(GuidelimeData.fontColorCOMPLETE .. L.QUEST_COMPLETE)
	button:SetPoint("TOPLEFT", prev, "TOPLEFT", 210, 4)
	button:SetScript("OnClick", function()
		showColorPicker(GuidelimeData.fontColorCOMPLETE, function()
			GuidelimeData.fontColorCOMPLETE = getColorPickerColor()
			button:SetText(GuidelimeData.fontColorCOMPLETE .. L.QUEST_COMPLETE)
			if GuidelimeDataChar.mainFrameShowing then
				CG.updateStepsText()
			end
		end)
	end)
	local button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(100)
	button:SetHeight(20)
	button:SetText(GuidelimeData.fontColorTURNIN .. L.QUEST_TURNIN)
	button:SetPoint("TOPLEFT", prev, "TOPLEFT", 110, -16)
	button:SetScript("OnClick", function()
		showColorPicker(GuidelimeData.fontColorTURNIN, function()
			GuidelimeData.fontColorTURNIN = getColorPickerColor()
			button:SetText(GuidelimeData.fontColorTURNIN .. L.QUEST_TURNIN)
			if GuidelimeDataChar.mainFrameShowing then
				CG.updateStepsText()
			end
		end)
	end)
	local button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(100)
	button:SetHeight(20)
	button:SetText(GuidelimeData.fontColorSKIP .. L.QUEST_SKIP)
	button:SetPoint("TOPLEFT", prev, "TOPLEFT", 210, -16)
	button:SetScript("OnClick", function()
		showColorPicker(GuidelimeData.fontColorSKIP, function()
			GuidelimeData.fontColorSKIP = getColorPickerColor()
			button:SetText(GuidelimeData.fontColorSKIP .. L.QUEST_SKIP)
			if GuidelimeDataChar.mainFrameShowing then
				CG.updateStepsText()
			end
		end)
	end)

	-- Arrow options

	O.optionsFrame.titleArrow = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	O.optionsFrame.titleArrow:SetText("|cFFFFFFFF___ " .. L.ARROW .. " _____________________________________________________________________")
	O.optionsFrame.titleArrow:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -30)
	O.optionsFrame.titleArrow:SetFontObject("GameFontNormalLarge")
	prev = O.optionsFrame.titleArrow

	checkbox = F.addCheckOption(content, GuidelimeDataChar, "showArrow", L.SHOW_ARROW, nil, function()
		if M.arrowFrame ~= nil then
			if GuidelimeDataChar.showArrow then
				M.arrowFrame:Show()
			else
				M.arrowFrame:Hide()
			end
			CG.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox
	
	local button = CreateFrame("BUTTON", nil, content, "UIPanelButtonTemplate")
	button:SetWidth(130)
	button:SetHeight(24)
	button:SetText(L.RESET_POSITION)
	button:SetPoint("TOPLEFT", checkbox, "TOPLEFT", 180, -4)
	button:SetScript("OnClick", function()
		GuidelimeDataChar.arrowX = 0
		GuidelimeDataChar.arrowY = -20
		GuidelimeDataChar.arrowRelative = "TOP"
		if M.arrowFrame ~= nil then
			M.arrowFrame:SetPoint(GuidelimeDataChar.arrowRelative, UIParent, GuidelimeDataChar.arrowRelative, GuidelimeDataChar.arrowX, GuidelimeDataChar.arrowY)
		end
	end)

	slider = F.addSliderOption(content, GuidelimeData, "arrowStyle", 1, 2, 1, L.ARROW_STYLE, nil, 
	function(self)
		self.editbox:SetText("   " .. M.getArrowIconText())
    	self.editbox:SetCursorPosition(0)
		if M.arrowFrame ~= nil then
			M.setArrowTexture()
		end
	end, function()
		if M.arrowFrame ~= nil then
			CG.updateSteps() 
		end
	end)
	slider.editbox:SetText("   " .. M.getArrowIconText())
    slider.editbox:SetCursorPosition(0)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -10)

	slider = F.addSliderOption(content, GuidelimeDataChar, "arrowAlpha", 0, 1, 0.01, L.ARROW_ALPHA, nil, function()
		if M.arrowFrame ~= nil then 
			M.arrowFrame:SetAlpha(GuidelimeDataChar.arrowAlpha)
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -50)

	slider = F.addSliderOption(content, GuidelimeDataChar, "arrowSize", 16, 256, 1, L.ARROW_SIZE, nil, function()
		if M.arrowFrame ~= nil then 
			M.arrowFrame:SetWidth(GuidelimeDataChar.arrowSize)
			M.arrowFrame:SetHeight(GuidelimeDataChar.arrowSize)
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -90)

	checkbox = F.addCheckOption(content, GuidelimeDataChar, "arrowLocked", L.LOCK_ARROW)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	checkbox = F.addCheckOption(content, GuidelimeData, "arrowDistance", L.SHOW_DISTANCE, nil, function()
		if M.arrowFrame ~= nil then 
			CG.updateSteps() 
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	-- Waypoint options

	O.optionsFrame.titleMapMarkersGoto = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	O.optionsFrame.titleMapMarkersGoto:SetText("|cFFFFFFFF___ " .. string.format(L.MAP_MARKERS_GOTO, M.getMapMarkerText({t = "GOTO", mapIndex = 0}) .. "," .. M.getMapMarkerText({t = "GOTO", mapIndex = 1}) .. "," .. M.getMapMarkerText({t = "GOTO", mapIndex = 2}) .. "," .. M.getMapMarkerText({t = "GOTO", mapIndex = 3})) .. " _______________________________________________________")
	O.optionsFrame.titleMapMarkersGoto:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
	O.optionsFrame.titleMapMarkersGoto:SetFontObject("GameFontNormalLarge")
	prev = O.optionsFrame.titleMapMarkersGoto

	O.optionsFrame.textShowMarkersGOTO = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	O.optionsFrame.textShowMarkersGOTO:SetText(L.SHOW_MARKERS_ON)
	O.optionsFrame.textShowMarkersGOTO:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
	prev = O.optionsFrame.textShowMarkersGOTO

	slider = F.addSliderOption(content, GuidelimeData, "maxNumOfMarkersGOTO", 0, 50, 1, L.MAX_NUM_OF_MARKERS, nil, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			CG.updateSteps()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -20)

	slider = F.addSliderOption(content, GuidelimeData, "mapMarkerStyleGOTO", 1, 3, 1, L.MAP_MARKER_STYLE, nil, function(self)
		self.editbox:SetText(M.getMapMarkerText({t = "GOTO", mapIndex = 0}) .. M.getMapMarkerText({t = "GOTO", mapIndex = 1}))
    	self.editbox:SetCursorPosition(0)
		O.optionsFrame.titleMapMarkersGoto:SetText("|cFFFFFFFF___ " .. string.format(L.MAP_MARKERS_GOTO, M.getMapMarkerText({t = "GOTO", mapIndex = 0}) .. "," .. M.getMapMarkerText({t = "GOTO", mapIndex = 1}) .. "," .. M.getMapMarkerText({t = "GOTO", mapIndex = 2}) .. "," .. M.getMapMarkerText({t = "GOTO", mapIndex = 3})) .. " _______________________________________________________")
	end, function()
		M.setMapIconTextures()
		CG.updateSteps() 
	end)
	slider.editbox:SetText(M.getMapMarkerText({t = "GOTO", mapIndex = 0}) .. M.getMapMarkerText({t = "GOTO", mapIndex = 1}))
    slider.editbox:SetCursorPosition(0)
	
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -70)

	slider = F.addSliderOption(content, GuidelimeData, "mapMarkerSizeGOTO", 8, 32, 1, L.MAP_MARKER_SIZE, nil, nil, function()
		M.setMapIconTextures()
		CG.updateSteps() 
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -110)

	slider = F.addSliderOption(content, GuidelimeData, "mapMarkerAlphaGOTO", 0, 1, 0.01, L.MAP_MARKER_ALPHA, nil, nil, function()
		M.setMapIconTextures()
		CG.updateSteps() 
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -150)

	O.optionsFrame.showMapMarkersGOTO = F.addCheckOption(content, GuidelimeData, "showMapMarkersGOTO", L.MAP, nil, function()
		CG.loadCurrentGuide(false)
		EV.updateFromQuestLog()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	O.optionsFrame.showMapMarkersGOTO:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = O.optionsFrame.showMapMarkersGOTO
	
	O.optionsFrame.showMinimapMarkersGOTO = F.addCheckOption(content, GuidelimeData, "showMinimapMarkersGOTO", L.MINIMAP, nil, function()
		CG.loadCurrentGuide(false)
		EV.updateFromQuestLog()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	O.optionsFrame.showMinimapMarkersGOTO:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = O.optionsFrame.showMinimapMarkersGOTO

	checkbox = F.addCheckOption(content, GuidelimeData, "showMapMarkersInGuide", L.GUIDE_WINDOW, nil, function()
		CG.updateStepsText()
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	-- Additional markers options

	O.optionsFrame.titleMapMarkersLoc = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	O.optionsFrame.titleMapMarkersLoc:SetText("|cFFFFFFFF___ " .. string.format(L.MAP_MARKERS_LOC, M.getMapMarkerText({t = "monster"}) .. "," .. M.getMapMarkerText({t = "item"}) .. "," .. M.getMapMarkerText({t = "object"}) .. "," .. M.getMapMarkerText({t = "LOC"})) .. " _______________________________________________________")
	O.optionsFrame.titleMapMarkersLoc:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -100)
	O.optionsFrame.titleMapMarkersLoc:SetFontObject("GameFontNormalLarge")
	prev = O.optionsFrame.titleMapMarkersLoc

	O.optionsFrame.textShowMarkersGOTO = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	O.optionsFrame.textShowMarkersGOTO:SetText(L.SHOW_MARKERS_ON)
	O.optionsFrame.textShowMarkersGOTO:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
	prev = O.optionsFrame.textShowMarkersGOTO

	slider = F.addSliderOption(content, GuidelimeData, "maxNumOfMarkersLOC", 0, 100, 1, L.MAX_NUM_OF_MARKERS, nil, nil, function()
		CG.loadCurrentGuide(false)
		EV.updateFromQuestLog()
		if GuidelimeDataChar.mainFrameShowing then
			CG.updateSteps()
		end
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -20)

	slider = F.addSliderOption(content, GuidelimeData, "mapMarkerStyleLOC", 1, 3, 1, L.MAP_MARKER_STYLE, nil, function(self)
		self.editbox:SetText(M.getMapMarkerText({t = "monster"}) .. M.getMapMarkerText({t = "item"}))
    	self.editbox:SetCursorPosition(0)
		O.optionsFrame.titleMapMarkersLoc:SetText("|cFFFFFFFF___ " .. string.format(L.MAP_MARKERS_LOC, M.getMapMarkerText({t = "monster"}) .. "," .. M.getMapMarkerText({t = "item"}) .. "," .. M.getMapMarkerText({t = "object"}) .. "," .. M.getMapMarkerText({t = "LOC"})) .. " _______________________________________________________")
	end, function()
		M.setMapIconTextures()
		CG.updateSteps() 
	end)
	slider.editbox:SetText(M.getMapMarkerText({t = "monster"}) .. M.getMapMarkerText({t = "item"}))
    slider.editbox:SetCursorPosition(0)
	
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -70)

	slider = F.addSliderOption(content, GuidelimeData, "mapMarkerSizeLOC", 8, 32, 1, L.MAP_MARKER_SIZE, nil, nil, function()
		M.setMapIconTextures()
		CG.updateSteps() 
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -110)

	slider = F.addSliderOption(content, GuidelimeData, "mapMarkerAlphaLOC", 0, 1, 0.01, L.MAP_MARKER_ALPHA, nil, nil, function()
		M.setMapIconTextures()
		CG.updateSteps() 
	end)
	slider:SetPoint("TOPLEFT", prev, "TOPLEFT", 350, -150)

	O.optionsFrame.showMapMarkersLOC = F.addCheckOption(content, GuidelimeData, "showMapMarkersLOC", L.MAP, nil, function()
		CG.loadCurrentGuide(false)
		EV.updateFromQuestLog()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	O.optionsFrame.showMapMarkersLOC:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = O.optionsFrame.showMapMarkersLOC

	O.optionsFrame.showMinimapMarkersLOC = F.addCheckOption(content, GuidelimeData, "showMinimapMarkersLOC", L.MINIMAP, nil, function()
		CG.loadCurrentGuide(false)
		EV.updateFromQuestLog()
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	O.optionsFrame.showMinimapMarkersLOC:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = O.optionsFrame.showMinimapMarkersLOC

	-- General options
	
	O.optionsFrame.titleGeneral = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	O.optionsFrame.titleGeneral:SetText("|cFFFFFFFF___ " .. L.GENERAL_OPTIONS .. " _______________________________________________________")
	O.optionsFrame.titleGeneral:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -100)
	O.optionsFrame.titleGeneral:SetFontObject("GameFontNormalLarge")
	prev = O.optionsFrame.titleGeneral
	
	for _, option in ipairs({"Accept", "TurnIn"}) do
		local text = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		text:SetText(L["AUTO_" .. string.upper(option) .. "_QUESTS"])
		text:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
		prev = text
	
		local choices = {"Current", "Guide", "All"}
		for i, v in ipairs(choices) do
			content.options["auto" .. option .. "Quests" .. v] = F.addCheckbox(content, L[string.upper(v) .. "_QUESTS"])
			content.options["auto" .. option .. "Quests" .. v]:SetChecked(GuidelimeData["auto" .. option .. "Quests"] == v)
			content.options["auto" .. option .. "Quests" .. v]:SetScript("OnClick", function()
				GuidelimeData["auto" .. option .. "Quests"] = content.options["auto" .. option .. "Quests" .. v]:GetChecked() and v
				for _, v2 in ipairs(choices) do
					content.options["auto" .. option .. "Quests" .. v2]:SetChecked(GuidelimeData["auto" .. option .. "Quests"] == v2)
				end
			end)
			content.options["auto" .. option .. "Quests" .. v]:SetPoint("TOPLEFT", prev, "TOPLEFT", 30 + i * 150, 10)
		end
	end

	checkbox = F.addCheckOption(content, GuidelimeData, "autoSelectFlight", L.AUTO_SELECT_FLIGHT)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox

	checkbox = F.addCheckOption(content, GuidelimeData, "autoTrain", L.AUTO_TRAIN)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox
	
	checkbox = F.addCheckOption(content, GuidelimeData, "skipCutscenes", L.SKIP_CUTSCENES, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			CG.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	--[[checkbox = F.addCheckOption(content, GuidelimeData, "displayDemoGuides", L.DISPLAY_DEMO_GUIDES, nil, G.fillGuides)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox]]

	checkbox = F.addCheckOption(content, GuidelimeData, "showTooltips", L.SHOW_TOOLTIPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			CG.updateStepsText()
			AB.updateTargetButtons()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	-- Debugging options

	O.optionsFrame.titleDebugging = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	O.optionsFrame.titleDebugging:SetText("|cFFFFFFFF___ " .. L.DEBUGGING_OPTIONS .. " _______________________________________________________")
	O.optionsFrame.titleDebugging:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	O.optionsFrame.titleDebugging:SetFontObject("GameFontNormalLarge")
	prev = O.optionsFrame.titleDebugging

	--[[checkbox = F.addCheckOption(content, GuidelimeData, "debugging", L.DEBUGGING, nil, function()
		addon.debugging = GuidelimeData.debugging
		if GuidelimeDataChar.mainFrameShowing then
			MW.updateMainFrame()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox]]

	checkbox = F.addCheckOption(content, GuidelimeData, "showLineNumbers", L.SHOW_LINE_NUMBERS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			CG.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	prev = checkbox

	checkbox = F.addCheckOption(content, GuidelimeData, "showQuestIds", L.SHOW_QUEST_IDS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			CG.updateStepsText()
		end
	end)
	checkbox:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
	prev = checkbox

	local sources = {"QUESTIE", "CLASSIC_CODEX", "DB"}
	for i, source in ipairs(sources) do
		content.options["dataSource" .. source] = F.addCheckbox(content, L["DATA_SOURCE_" .. source], L["DATA_SOURCE_TOOLTIP_" .. source])
		content.options["dataSource" .. source]:SetChecked(addon.dataSource == source)
		content.options["dataSource" .. source]:SetScript("OnClick", function()
			if addon.dataSource == source then content.options["dataSource" .. source]:SetChecked(true); return end
			addon.dataSource = source
			GuidelimeData.dataSource = source
			for _, source2 in ipairs(sources) do
				content.options["dataSource" .. source2]:SetChecked(addon.dataSource == source2)
			end
			QT.resetCachedQuestData()			
			if GuidelimeDataChar.mainFrameShowing and GuidelimeData.autoAddCoordinates then
				CG.loadCurrentGuide(false)
				EV.updateFromQuestLog()
				MW.updateMainFrame(true)
			end
		end)
		content.options["dataSource" .. source]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, i == 1 and -10 or 0)
		content.options["dataSource" .. source]:SetEnabled(addon[source].isDataSourceInstalled())
		if not addon[source].isDataSourceInstalled() then content.options["dataSource" .. source]:GetFontString():SetTextColor(0.4, 0.4, 0.4) end
		prev = content.options["dataSource" .. source]
	end
end

function O.isOptionsShowing()
	return InterfaceOptionsFrame:IsShown() and InterfaceOptionsFramePanelContainer.displayedPanel == O.optionsFrame
end

function O.showOptions()
	if not addon.dataLoaded then loadData() end
	if O.isOptionsShowing() then 
		InterfaceOptionsFrame:Hide()
	else
		if E.isEditorShowing() then E.editorFrame:Hide() end
		InterfaceAddOnsList_Update()
		InterfaceOptionsFrame_OpenToCategory(addonName)
	end
end

function O.toggleOptions(optionsTable, ...)
	local options = {...}
	if D.contains(options, function(o) return optionsTable[o] end) then
		for _, o in ipairs(options) do
			optionsTable[o .. "Prev"] = optionsTable[o]
			optionsTable[o] = false
		end
	else
		for _, o in ipairs(options) do
			optionsTable[o] = optionsTable[o .. "Prev"] == nil or optionsTable[o .. "Prev"]
		end
	end
	if O.optionsFrame ~= nil then
		for _, o in ipairs(options) do
			O.optionsFrame[o]:SetChecked(optionsTable[o])
		end
	end
end
