local addonName, addon = ...
local L = addon.L

addon.D = addon.D or {}; local D = addon.D     -- Data/Data
addon.CG = addon.CG or {}; local CG = addon.CG -- CurrentGuide
addon.E = addon.E or {}; local E = addon.E     -- Editor
addon.F = addon.F or {}; local F = addon.F     -- Frames
addon.EV = addon.EV or {}; local EV = addon.EV -- Events
addon.MW = addon.MW or {}; local MW = addon.MW -- MainWindow
addon.O = addon.O or {}; local O = addon.O     -- Options

addon.G = addon.G or {}; local G = addon.G     -- Guides

G.GUIDE_LIST_URL = "https://github.com/max-ri/guidelime/wiki/GuideList"

local function setGuideBackdrop(guideFrame, hover)
	if guideFrame == nil then return end
	if hover and guideFrame.name ~= GuidelimeDataChar.currentGuide then
		guideFrame:SetBackdropColor(0.5,0.5,1,1)
	elseif guideFrame.searchHighlight then
		guideFrame:SetBackdropColor(0.2,0.6,0.2,1)
	elseif guideFrame.name == GuidelimeDataChar.currentGuide then
		guideFrame:SetBackdropColor(1,1,0,1)
	else
		guideFrame:SetBackdropColor(0,0,0,0)
	end
end

local function cleanSearchText(text)
	return (text or ""):lower():gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function guideMatchesSearch(name, guide, searchText)
	return cleanSearchText(name):find(searchText, 1, true) ~= nil or
		cleanSearchText(guide.title):find(searchText, 1, true) ~= nil or
		cleanSearchText(guide.group):find(searchText, 1, true) ~= nil
end

local function scrollToGuide(guideFrame)
	local scrollFrame = G.guidesFrame and G.guidesFrame.guidesScrollFrame
	if scrollFrame == nil or guideFrame == nil then return end

	local frameTop, frameBottom = guideFrame:GetTop(), guideFrame:GetBottom()
	local scrollTop, scrollBottom = scrollFrame:GetTop(), scrollFrame:GetBottom()
	if frameTop == nil or frameBottom == nil or scrollTop == nil or scrollBottom == nil then return end

	local scroll = scrollFrame:GetVerticalScroll() or 0
	local range = scrollFrame:GetVerticalScrollRange() or 0
	if frameTop > scrollTop then
		scroll = scroll - (frameTop - scrollTop) - 5
	elseif frameBottom < scrollBottom then
		scroll = scroll + (scrollBottom - frameBottom) + 5
	else
		return
	end
	scroll = math.max(0, math.min(scroll, range))
	scrollFrame:SetVerticalScroll(scroll)
	if scrollFrame.ScrollBar ~= nil then scrollFrame.ScrollBar:SetValue(scroll) end
end

local function showGuideSearchMatch(matchIndex)
	if G.guidesFrame == nil or G.guidesFrame.searchMatches == nil then return end
	local name = G.guidesFrame.searchMatches[matchIndex]
	local guideFrame = name ~= nil and G.guidesFrame.guides and G.guidesFrame.guides[name]
	if guideFrame == nil then return end

	G.guidesFrame.searchMatchIndex = matchIndex
	G.guidesFrame.searchMatch = name
	guideFrame.searchHighlight = true
	setGuideBackdrop(guideFrame)
	scrollToGuide(guideFrame)
end

local function updateGuideSearch(resetMatch)
	if G.guidesFrame == nil then return end
	if G.guidesFrame.guides ~= nil then
		for _, guideFrame in pairs(G.guidesFrame.guides) do
			guideFrame.searchHighlight = false
			setGuideBackdrop(guideFrame)
		end
	end
	G.guidesFrame.searchMatch = nil
	G.guidesFrame.searchMatches = {}

	local searchBox = G.guidesFrame.searchBox
	local searchText = cleanSearchText(searchBox and searchBox:GetText())
	if searchText == "" or G.guidesFrame.guides == nil then
		G.guidesFrame.searchText = searchText
		G.guidesFrame.searchMatchIndex = nil
		return
	end

	for _, name in ipairs(G.guidesFrame.guideOrder or {}) do
		local guide = addon.guides[name]
		local guideFrame = G.guidesFrame.guides[name]
		if guide ~= nil and guideFrame ~= nil and guideMatchesSearch(name, guide, searchText) then
			table.insert(G.guidesFrame.searchMatches, name)
		end
	end

	if #G.guidesFrame.searchMatches == 0 then
		G.guidesFrame.searchText = searchText
		G.guidesFrame.searchMatchIndex = nil
		return
	end

	if resetMatch or G.guidesFrame.searchText ~= searchText or G.guidesFrame.searchMatchIndex == nil or G.guidesFrame.searchMatchIndex > #G.guidesFrame.searchMatches then
		G.guidesFrame.searchMatchIndex = 1
	end
	G.guidesFrame.searchText = searchText
	showGuideSearchMatch(G.guidesFrame.searchMatchIndex)
end

local function nextGuideSearchMatch()
	if G.guidesFrame == nil then return end
	local searchText = cleanSearchText(G.guidesFrame.searchBox and G.guidesFrame.searchBox:GetText())
	if searchText == "" then return end
	if G.guidesFrame.searchText ~= searchText or G.guidesFrame.searchMatches == nil or #G.guidesFrame.searchMatches == 0 then
		updateGuideSearch(true)
		return
	end

	if G.guidesFrame.guides ~= nil and G.guidesFrame.searchMatch ~= nil and G.guidesFrame.guides[G.guidesFrame.searchMatch] ~= nil then
		G.guidesFrame.guides[G.guidesFrame.searchMatch].searchHighlight = false
		setGuideBackdrop(G.guidesFrame.guides[G.guidesFrame.searchMatch])
	end
	local nextIndex = (G.guidesFrame.searchMatchIndex or 0) + 1
	if nextIndex > #G.guidesFrame.searchMatches then nextIndex = 1 end
	showGuideSearchMatch(nextIndex)
end

local function hideGuideSearch()
	if G.guidesFrame == nil or G.guidesFrame.searchBox == nil then return end
	G.guidesFrame.searchBox:SetText("")
	G.guidesFrame.searchBox:ClearFocus()
	G.guidesFrame.searchBox:Hide()
	updateGuideSearch(true)
end

local function showGuideSearch()
	if G.guidesFrame == nil or G.guidesFrame.searchBox == nil then return end
	G.guidesFrame.searchBox:Show()
	G.guidesFrame.searchBox:SetFocus()
	G.guidesFrame.searchBox:HighlightText()
	updateGuideSearch(true)
end

function G.loadGuide(name)
	if addon.debugging then print("LIME: load guide", name) end

	local previousGuide = GuidelimeDataChar.currentGuide
	GuidelimeDataChar.currentGuide = name
	
	if G.guidesFrame ~= nil then
		if G.guidesFrame.guides ~= nil and previousGuide ~= nil and G.guidesFrame.guides[previousGuide] ~= nil then
			setGuideBackdrop(G.guidesFrame.guides[previousGuide])
		end
		if G.guidesFrame.guides ~= nil and G.guidesFrame.guides[name] ~= nil then
			setGuideBackdrop(G.guidesFrame.guides[name])
		end
		G.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. name .. "\n")
	end
	if E.editorFrame ~= nil then
		E.editorFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. name .. "\n")
		if addon.guides[name] ~= nil then
			E.editorFrame.textBox:SetText(addon.guides[name].text:gsub("|","¦"))
		end
	end
	if addon.guides[name] ~= nil then 
		GuidelimeData.lastGuideGroup = addon.guides[name].group
	end
	CG.loadCurrentGuide(true)
	EV.updateFromQuestLog()
	if GuidelimeDataChar.mainFrameShowing then
		MW.updateMainFrame()
	else
		GuidelimeDataChar.mainFrameShowing = true
		if O.optionsFrame ~= nil then O.optionsFrame.mainFrameShowing:SetChecked(true) end
		MW.showMainFrame()
	end
end

local function resetGuide() 
	if GuidelimeDataChar.currentGuide == nil then return end
	GuidelimeDataChar.guideSkip[GuidelimeDataChar.currentGuide] = {}
	G.loadGuide(GuidelimeDataChar.currentGuide)
end

local function selectGuide(name)
	if addon.guides[name].reputation == nil or
		D.hasRequirements(addon.guides[name]) then
		G.loadGuide(name)
	end
end

function G.showGuides()
	if not addon.dataLoaded then loadData() end

	if G.isGuidesShowing() then
		G.guidesFrame:Hide()
		return
	end
	
	if InterfaceOptionsFrame then
		InterfaceOptionsFrame:Hide() 
	else
		HideUIPanel(SettingsPanel)
	end
	if E.isEditorShowing() then E.editorFrame:Hide() end 

	if G.guidesFrame == nil then
		G.guidesFrame = F.createPopupFrame(nil, nil, false, 700)
		G.guidesFrame:SetWidth(800)
		G.guidesFrame:SetPoint(GuidelimeDataChar.guidesFrameRelative, UIParent, GuidelimeDataChar.guidesFrameRelative, GuidelimeDataChar.guidesFrameX, GuidelimeDataChar.guidesFrameY)
		
		G.guidesFrame.okBtn:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
		G.guidesFrame.okBtn:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight")
		G.guidesFrame.okBtn:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
		G.guidesFrame.okBtn:ClearAllPoints()
		G.guidesFrame.okBtn:SetPoint("TOPRIGHT", G.guidesFrame, -10, -10)
		G.guidesFrame.okBtn:SetSize(24, 24)
		G.guidesFrame.okBtn:SetText(nil)
	
		G.guidesFrame.title = G.guidesFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		local version = GetAddOnMetadata and GetAddOnMetadata(addonName, "version") or C_AddOns.GetAddOnMetadata(addonName, "version")
		local title = GetAddOnMetadata and GetAddOnMetadata(addonName, "title") or C_AddOns.GetAddOnMetadata(addonName, "title")
		G.guidesFrame.title:SetText(title .. " |cFFFFFFFF" .. version)
		G.guidesFrame.title:SetPoint("TOPLEFT", G.guidesFrame, "TOPLEFT", 20, -20)
		G.guidesFrame.title:SetFontObject("GameFontNormalLarge")
		local prev = G.guidesFrame.title
		
		G.guidesFrame.text1 = G.guidesFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		G.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. (GuidelimeDataChar.currentGuide or "") .. "\n")
		G.guidesFrame.text1:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -30)
		prev = G.guidesFrame.text1
		
		G.guidesFrame.text2 = G.guidesFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		G.guidesFrame.text2:SetText(L.AVAILABLE_GUIDES .. ":\n")
		G.guidesFrame.text2:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
		prev = G.guidesFrame.text2

		G.guidesFrame.searchBtn = CreateFrame("BUTTON", nil, G.guidesFrame, "UIPanelButtonTemplate")
		G.guidesFrame.searchBtn:SetFrameLevel(G.guidesFrame:GetFrameLevel() + 3)
		G.guidesFrame.searchBtn:SetSize(24, 20)
		G.guidesFrame.searchBtn:SetPoint("TOPRIGHT", G.guidesFrame, "TOPRIGHT", -45, -79)
		G.guidesFrame.searchBtn.icon = G.guidesFrame.searchBtn:CreateTexture(nil, "ARTWORK")
		G.guidesFrame.searchBtn.icon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")
		G.guidesFrame.searchBtn.icon:SetSize(14, 14)
		G.guidesFrame.searchBtn.icon:SetPoint("CENTER")
		F.setTooltip(G.guidesFrame.searchBtn, SEARCH or "Search")
		G.guidesFrame.searchBtn:SetScript("OnClick", function()
			if G.guidesFrame.searchBox:IsShown() then
				hideGuideSearch()
			else
				showGuideSearch()
			end
		end)

		G.guidesFrame.searchBox = CreateFrame("EditBox", nil, G.guidesFrame, "InputBoxTemplate")
		G.guidesFrame.searchBox:SetFrameLevel(G.guidesFrame:GetFrameLevel() + 3)
		G.guidesFrame.searchBox:SetSize(250, 20)
		G.guidesFrame.searchBox:SetPoint("RIGHT", G.guidesFrame.searchBtn, "LEFT", -6, 0)
		G.guidesFrame.searchBox:SetFontObject("GameFontNormal")
		G.guidesFrame.searchBox:SetAutoFocus(false)
		G.guidesFrame.searchBox:SetScript("OnTextChanged", function() updateGuideSearch(true) end)
		G.guidesFrame.searchBox:SetScript("OnEnterPressed", nextGuideSearchMatch)
		G.guidesFrame.searchBox:SetScript("OnEscapePressed", hideGuideSearch)
		G.guidesFrame.searchBox:Hide()

	    local scrollFrame = CreateFrame("ScrollFrame", nil, G.guidesFrame, "UIPanelScrollFrameTemplate")
	    scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -20)
	    scrollFrame:SetPoint("RIGHT", G.guidesFrame, "RIGHT", -30, 0)
	    scrollFrame:SetPoint("BOTTOM", G.guidesFrame, "BOTTOM", 0, 160)
		G.guidesFrame.guidesScrollFrame = scrollFrame

	    G.guidesFrame.content = CreateFrame("Frame", nil, scrollFrame)
	    G.guidesFrame.content:SetSize(1, 1) 
	    scrollFrame:SetScrollChild(G.guidesFrame.content)

		G.guidesFrame.guideListMessage = F.addMultilineText(G.guidesFrame.content, 
			string.format(L.GUIDE_LIST, "|cFFAAAAAA" .. G.GUIDE_LIST_URL), 
			550, nil, function()
				InterfaceOptionsFrame:Hide()
				F.showUrlPopup(G.GUIDE_LIST_URL) 
			end)
	
		prev = scrollFrame
		
		G.guidesFrame.text3 = G.guidesFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		G.guidesFrame.text3:SetText(L.DETAILS .. ":\n")
		G.guidesFrame.text3:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
		prev = G.guidesFrame.text3
	
	    scrollFrame = CreateFrame("ScrollFrame", nil, G.guidesFrame, "UIPanelScrollFrameTemplate")
	    scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -20)
	    scrollFrame:SetPoint("RIGHT", G.guidesFrame, "RIGHT", -30, 0)
	    scrollFrame:SetPoint("BOTTOM", G.guidesFrame, "BOTTOM", 0, 60)
	
	    local content = CreateFrame("Frame", nil, scrollFrame) 
	    content:SetSize(1, 1) 
	    scrollFrame:SetScrollChild(content)
	
		G.guidesFrame.textDetails = F.addMultilineText(content, nil, 550, nil, function()
			if G.guidesFrame.textDetails.url ~= nil then 
				InterfaceOptionsFrame:Hide()
				F.showUrlPopup(G.guidesFrame.textDetails.url) 
			end
		end)
		G.guidesFrame.textDetails:SetPoint("TOPLEFT", content, "BOTTOMLEFT", 0, 0)
		G.guidesFrame.textDetails:SetTextColor(1,1,1,1)
		if addon.guides[GuidelimeDataChar.currentGuide] ~= nil and addon.guides[GuidelimeDataChar.currentGuide].details ~= nil then
			G.guidesFrame.textDetails:SetText(addon.guides[GuidelimeDataChar.currentGuide].details)
			G.guidesFrame.textDetails.url = addon.guides[GuidelimeDataChar.currentGuide].detailsUrl or ""
		end
		
		G.guidesFrame.loadBtn = CreateFrame("BUTTON", nil, G.guidesFrame, "UIPanelButtonTemplate")
		G.guidesFrame.loadBtn:SetWidth(140)
		G.guidesFrame.loadBtn:SetHeight(30)
		G.guidesFrame.loadBtn:SetText(L.RESET_GUIDE)
		G.guidesFrame.loadBtn:SetPoint("BOTTOMLEFT", G.guidesFrame, "BOTTOMLEFT", 20, 20)
		G.guidesFrame.loadBtn:SetScript("OnClick", resetGuide)
	
		G.guidesFrame.loadBtn = CreateFrame("BUTTON", nil, G.guidesFrame, "UIPanelButtonTemplate")
		G.guidesFrame.loadBtn:SetWidth(140)
		G.guidesFrame.loadBtn:SetHeight(30)
		G.guidesFrame.loadBtn:SetText(L.EDIT_GUIDE)
		G.guidesFrame.loadBtn:SetPoint("BOTTOMLEFT", G.guidesFrame, "BOTTOMLEFT", 160, 20)
		G.guidesFrame.loadBtn:SetScript("OnClick", E.showEditor)

	end
	prev = G.guidesFrame.content

	if addon.debugging then print("LIME:", D.faction, D.race, D.class) end

	local groups = {}
	local groupNames = {}
	for name, guide in pairs(addon.guides) do
		if D.applies(guide) then
			if groups[guide.group] == nil then 
				groups[guide.group] = {} 
				table.insert(groupNames, guide.group)
			end
			table.insert(groups[guide.group], name)
		end
	end
	table.sort(groupNames)
	
	if G.guidesFrame.groups ~= nil then
		for _, group in pairs(G.guidesFrame.groups) do
			group:Hide()
		end
	end
	if G.guidesFrame.guides ~= nil then
		for _, guide in pairs(G.guidesFrame.guides) do
			guide:Hide()
		end
	end
	if G.guidesFrame.messages ~= nil then
		for _, message in pairs(G.guidesFrame.messages) do
			message:Hide()
		end
	end
	G.guidesFrame.groups = {}
	G.guidesFrame.guides = {}
	G.guidesFrame.messages = {}
	G.guidesFrame.guideOrder = {}
	
	for i, group in ipairs(groupNames) do
		local guides = groups[group]
		table.sort(guides, function(a, b)
			local ga = addon.guides[a]
			local gb = addon.guides[b]
			if (ga.minLevel ~= nil or gb.minLevel ~= nil) and ga.minLevel ~= gb.minLevel then return (ga.minLevel or 0) < (gb.minLevel or 0) end
			if (ga.maxLevel ~= nil or gb.maxLevel ~= nil) and ga.maxLevel ~= gb.maxLevel then return (ga.maxLevel or 0) < (gb.maxLevel or 0) end
			return (ga.name or "") < (gb.name or "")
		end)
		
		--[[
		local downloadMinLevel, downloadMaxLevel, download, downloadUrl
		for j, name in ipairs(guides) do
			local guide = addon.guides[name]
			--if addon.debugging then print("LIME: guide", group, name) end
			
			if guide.next ~= nil and #guide.next > 0 and (addon.guides[group .. ' ' .. guide.next[1] ] == nil) and guide.download ~= nil then
				downloadMinLevel, downloadMaxLevel, download, downloadUrl = guide.downloadMinLevel, guide.downloadMaxLevel, guide.download, guide.downloadUrl 	
			end
		end
		if download == nil or GuidelimeData.displayDemoGuides then]]
		
		G.guidesFrame.groups[group] = G.guidesFrame.content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		if prev == G.guidesFrame.content then
			G.guidesFrame.groups[group]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
		else
			G.guidesFrame.groups[group]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -10, -10)
		end
		G.guidesFrame.groups[group]:SetText(group)
		prev = G.guidesFrame.groups[group]
		for j, name in ipairs(guides) do
			local guide = addon.guides[name]
			table.insert(G.guidesFrame.guideOrder, name)

			local text = ""
			if guide.minLevel ~= nil then
				text = text .. MW.getLevelColor(guide.minLevel) .. guide.minLevel .. "|r"
			end
			if guide.minLevel ~= nil or guide.maxLevel ~= nil then
				text = text .. "-"
			end
			if guide.maxLevel ~= nil then
				text = text .. MW.getLevelColor(guide.maxLevel) .. guide.maxLevel .. "|r"
			end
			if guide.minLevel ~= nil or guide.maxLevel ~= nil then
				text = text .. " "
			end
			if guide.title ~= nil then
				if D.hasRequirements(guide) then
					text = text .. MW.COLOR_INACTIVE
				else
					text = text .. MW.COLOR_WHITE
				end					
				text = text .. guide.title .. "|r"
			end
			G.guidesFrame.guides[name] = F.addMultilineText(G.guidesFrame.content, text, 550, nil, function(self)
				selectGuide(self.name)
			end)
			if j == 1 then
				G.guidesFrame.guides[name]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 10, -5)
			else
				G.guidesFrame.guides[name]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
			end
			G.guidesFrame.guides[name]:SetTextColor(1,1,1,1)
			G.guidesFrame.guides[name]:SetBackdrop({
				--bgFile = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight",
				bgFile = "Interface\\AddOns\\" .. addonName .. "\\Icons\\TitleHighlight",
				tile = false, edgeSize = 1
			})
			G.guidesFrame.guides[name].name = name
			G.guidesFrame.guides[name].guide = guide
			G.guidesFrame.guides[name].searchHighlight = name == G.guidesFrame.searchMatch
			setGuideBackdrop(G.guidesFrame.guides[name])
			G.guidesFrame.guides[name]:SetScript("OnEnter", function(self)
				G.guidesFrame.textDetails:SetText(self.guide.details or "")
				G.guidesFrame.textDetails.url = self.guide.detailsUrl or ""
				setGuideBackdrop(self, true)
			end)
			G.guidesFrame.guides[name]:SetScript("OnLeave", function(self)
				if GuidelimeDataChar.currentGuide ~= nil and addon.guides[GuidelimeDataChar.currentGuide] ~= nil then
					G.guidesFrame.textDetails:SetText(addon.guides[GuidelimeDataChar.currentGuide].details or "")
					G.guidesFrame.textDetails.url = addon.guides[GuidelimeDataChar.currentGuide].detailsUrl or ""
				end
				setGuideBackdrop(self)
			end)
			prev = G.guidesFrame.guides[name]
		end
		--[[if download ~= nil then
			G.guidesFrame.messages[group] = F.addMultilineText(G.guidesFrame.content, 
				string.format(L.DOWNLOAD_FULL_GUIDE, downloadMinLevel, downloadMaxLevel, download, "\n|cFFAAAAAA" .. downloadUrl), 
				550, nil, function()
					InterfaceOptionsFrame:Hide()
					F.showUrlPopup(downloadUrl) 
				end)
			G.guidesFrame.messages[group]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -5)
			prev = G.guidesFrame.messages[group]
		end]]
	end

	if prev == G.guidesFrame.content then
		G.guidesFrame.guideListMessage:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
	else
		G.guidesFrame.guideListMessage:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -10, -20)
	end

	G.guidesFrame:Show()
	updateGuideSearch()
end

function G.isGuidesShowing()
	return G.guidesFrame ~= nil and G.guidesFrame:IsVisible()
end

function G.selectStartGuide()
	local raceStarterZoneDict
	if select(4, GetBuildInfo()) >= 40000 then
		raceStarterZoneDict = {
			Dwarf = {'dwarf', 'dunmorogh', 'coldridgevalley'},
			Gnome = {'gnome', 'gnomeregan'},
			Human = {'human', 'elwynnforest', 'northshireabbey'},
			NightElf = {'nightelf', 'shadowglen', 'teldrassil'},
			Orc = {'orc', 'durotar', 'valleyoftrials'},
			Tauren = {'tauren', 'mulgore', 'campnarache'},
			Troll = {'troll', 'durotar', 'echoisles'},
			Undead = {'undead', 'tirisfalglades', 'deathknell'},
	        Draenei = {'draenei', 'azuremystisle'},
	        BloodElf = {'bloodelf', 'eversongwoods'},
	        Worgen = {'worgen', 'gilneas'},
	        Goblin = {'goblin', 'kezan'},
	        Pandaren = {'pandaren', 'wanderingisle', 'monk'}
		}
	else
		raceStarterZoneDict = {
	    	Dwarf = {'dwarf', 'dunmorogh', 'coldridgevalley'},
	    	Gnome = {'gnome', 'dunmorogh', 'coldridgevalley'},
	    	Human = {'human', 'elwynnforest', 'northshireabbey'},
	    	NightElf = {'nightelf', 'shadowglen', 'teldrassil'},
	    	Orc = {'orc', 'durotar', 'valleyoftrials'},
	    	Tauren = {'tauren', 'mulgore', 'campnarache'},
	    	Troll = {'troll', 'durotar', 'valleyoftrials'},
	    	Undead = {'undead', 'tirisfalglades', 'deathknell'},
			Draenei = {'draenei', 'azuremystisle'},
			BloodElf = {'bloodelf', 'eversongwoods'},
			Worgen = {'worgen', 'gilneas'},
			Goblin = {'goblin', 'kezan'},
			Pandaren = {'pandaren', 'wanderingisle'},
			Skyborne = {'skyborne', 'zephrasisle'}
		}
	end
	local matchingGuides = {}
	for name, guide in pairs(addon.guides) do
		if guide.minLevel == 1 then
			local n = guide.title:lower():gsub("%s+", "")
			for _, phrase in ipairs(raceStarterZoneDict[D.race]) do
				if string.find(n, phrase) then
					table.insert(matchingGuides, name)
					break
				end
			end
		end
	end
	if #matchingGuides > 1 and GuidelimeData.lastGuideGroup ~= nil then
		local filteredGuides = {}
		for _, name in ipairs(matchingGuides) do 
			if addon.guides[name].group == GuidelimeData.lastGuideGroup then
				table.insert(filteredGuides, name)
			end
			if #filteredGuides > 0 then matchingGuides = filteredGuides end
		end
	end
	if #matchingGuides > 0 then
		return matchingGuides[1]
	end
	if addon.debugging then print("LIME: no matching starting guide was found")	end
end
