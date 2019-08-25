local addonName, addon = ...
local L = addon.L

addon.GUIDE_LIST_URL = "https://github.com/max-ri/guidelime/wiki/GuideList"

function addon.loadGuide(name)
	if addon.debugging then print("LIME: load guide", name) end
	
	if GuidelimeDataChar.currentGuide ~= nil and addon.guidesFrame.guides[GuidelimeDataChar.currentGuide] ~= nil then
		addon.guidesFrame.guides[GuidelimeDataChar.currentGuide]:SetBackdropColor(0,0,0,0)	
	end
	addon.guidesFrame.guides[name]:SetBackdropColor(1,1,0,1)
	GuidelimeDataChar.currentGuide = name
	if addon.guidesFrame ~= nil then
		addon.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. name .. "\n")
	end
	if addon.editorFrame ~= nil then
		addon.editorFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. name .. "\n")
		if addon.guides[GuidelimeDataChar.currentGuide] ~= nil then
			addon.editorFrame.textBox:SetText(addon.guides[GuidelimeDataChar.currentGuide].text:gsub("|","¦"))
		end
	end
	addon.loadCurrentGuide()
	addon.updateFromQuestLog()
	if GuidelimeDataChar.mainFrameShowing then
		addon.updateMainFrame()
	else
		GuidelimeDataChar.mainFrameShowing = true
		if addon.optionsFrame ~= nil then addon.optionsFrame.options.mainFrameShowing:SetChecked(true) end
		addon.showMainFrame()
	end
end

local function resetGuide() 
	GuidelimeDataChar.guideSkip[GuidelimeDataChar.currentGuide] = {}
	addon.loadGuide(GuidelimeDataChar.currentGuide)
end

function addon.fillGuides()
	if addon.guidesFrame == nil then
    	addon.guidesFrame = CreateFrame("Frame", nil, UIParent)
    	addon.guidesFrame.name = GetAddOnMetadata(addonName, "title")
    	InterfaceOptions_AddCategory(addon.guidesFrame)
	
		addon.guidesFrame.title = addon.guidesFrame:CreateFontString(nil, addon.guidesFrame, "GameFontNormal")
		addon.guidesFrame.title:SetText(GetAddOnMetadata(addonName, "title") .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version"))
		addon.guidesFrame.title:SetPoint("TOPLEFT", addon.guidesFrame, "TOPLEFT", 20, -20)
		addon.guidesFrame.title:SetFontObject("GameFontNormalLarge")
		local prev = addon.guidesFrame.title
		
		addon.guidesFrame.text1 = addon.guidesFrame:CreateFontString(nil, addon.guidesFrame, "GameFontNormal")
		addon.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. (GuidelimeDataChar.currentGuide or "") .. "\n")
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
	
	    addon.guidesFrame.content = CreateFrame("Frame", nil, scrollFrame) 
	    addon.guidesFrame.content:SetSize(1, 1) 
	    scrollFrame:SetScrollChild(addon.guidesFrame.content)

		addon.guidesFrame.guideListMessage = addon.addMultilineText(addon.guidesFrame.content, 
			string.format(L.GUIDE_LIST, "|cFFAAAAAA" .. addon.GUIDE_LIST_URL), 
			550, nil, function()
				InterfaceOptionsFrame:Hide()
				addon.showUrlPopup(addon.GUIDE_LIST_URL) 
			end)
	
		prev = scrollFrame
		
		addon.guidesFrame.text3 = addon.guidesFrame:CreateFontString(nil, addon.guidesFrame, "GameFontNormal")
		addon.guidesFrame.text3:SetText(L.DETAILS .. ":\n")
		addon.guidesFrame.text3:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
		prev = addon.guidesFrame.text3
	
	    scrollFrame = CreateFrame("ScrollFrame", nil, addon.guidesFrame, "UIPanelScrollFrameTemplate")
	    scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -20)
	    scrollFrame:SetPoint("RIGHT", addon.guidesFrame, "RIGHT", -30, 0)
	    scrollFrame:SetPoint("BOTTOM", addon.guidesFrame, "BOTTOM", 0, 60)
	
	    local content = CreateFrame("Frame", nil, scrollFrame) 
	    content:SetSize(1, 1) 
	    scrollFrame:SetScrollChild(content)
	
		addon.guidesFrame.textDetails = addon.addMultilineText(content, nil, 550, nil, function()
			if addon.guidesFrame.textDetails.url ~= nil then 
				InterfaceOptionsFrame:Hide()
				addon.showUrlPopup(addon.guidesFrame.textDetails.url) 
			end
		end)
		addon.guidesFrame.textDetails:SetPoint("TOPLEFT", content, "BOTTOMLEFT", 0, 0)
		addon.guidesFrame.textDetails:SetTextColor(255,255,255,255)
		if addon.guides[GuidelimeDataChar.currentGuide] ~= nil and addon.guides[GuidelimeDataChar.currentGuide].details ~= nil then
			addon.guidesFrame.textDetails:SetText(addon.guides[GuidelimeDataChar.currentGuide].details)
			addon.guidesFrame.textDetails.url = addon.guides[GuidelimeDataChar.currentGuide].detailsUrl or ""
		end
		
		addon.guidesFrame.loadBtn = CreateFrame("BUTTON", nil, addon.guidesFrame, "UIPanelButtonTemplate")
		addon.guidesFrame.loadBtn:SetWidth(140)
		addon.guidesFrame.loadBtn:SetHeight(30)
		addon.guidesFrame.loadBtn:SetText(L.RESET_GUIDE)
		addon.guidesFrame.loadBtn:SetPoint("BOTTOMLEFT", addon.guidesFrame, "BOTTOMLEFT", 20, 20)
		addon.guidesFrame.loadBtn:SetScript("OnClick", resetGuide)
	
		addon.guidesFrame.loadBtn = CreateFrame("BUTTON", nil, addon.guidesFrame, "UIPanelButtonTemplate")
		addon.guidesFrame.loadBtn:SetWidth(140)
		addon.guidesFrame.loadBtn:SetHeight(30)
		addon.guidesFrame.loadBtn:SetText(L.EDIT_GUIDE)
		addon.guidesFrame.loadBtn:SetPoint("BOTTOMLEFT", addon.guidesFrame, "BOTTOMLEFT", 160, 20)
		addon.guidesFrame.loadBtn:SetScript("OnClick", addon.showEditor)

	end
	prev = addon.guidesFrame.content

	if addon.debugging then print("LIME:", addon.faction, addon.race, addon.class) end

	local groups = {}
	local groupNames = {}
	for name, guide in pairs(addon.guides) do
		local showGuide = true
		if guide.race ~= nil then
			if not addon.contains(guide.race, addon.race) then showGuide = false end
		end
		if guide.class ~= nil then
			if not addon.contains(guide.class, addon.class) then showGuide = false end
		end
		if guide.faction ~= nil and guide.faction ~= addon.faction then showGuide = false end
		if showGuide then
			if groups[guide.group] == nil then 
				groups[guide.group] = {} 
				table.insert(groupNames, guide.group)
			end
			table.insert(groups[guide.group], name)
		end
	end
	table.sort(groupNames)
	
	if addon.guidesFrame.groups ~= nil then
		for _, group in pairs(addon.guidesFrame.groups) do
			group:Hide()
		end
	end
	if addon.guidesFrame.guides ~= nil then
		for _, guide in pairs(addon.guidesFrame.guides) do
			guide:Hide()
		end
	end
	if addon.guidesFrame.messages ~= nil then
		for _, message in pairs(addon.guidesFrame.messages) do
			message:Hide()
		end
	end
	addon.guidesFrame.groups = {}
	addon.guidesFrame.guides = {}
	addon.guidesFrame.messages = {}
	
	for i, group in ipairs(groupNames) do
		local guides = groups[group]
		table.sort(guides, function(a, b)
			local ga = addon.guides[a]
			local gb = addon.guides[b]
			if (ga.minLevel ~= nil or gb.minLevel ~= nil) and ga.minLevel ~= gb.minLevel then return (ga.minLevel or 0) < (gb.minLevel or 0) end
			if (ga.maxLevel ~= nil or gb.maxLevel ~= nil) and ga.maxLevel ~= gb.maxLevel then return (ga.maxLevel or 0) < (gb.maxLevel or 0) end
			return (ga.name or "") < (gb.name or "")
		end)
		
		local downloadMinLevel, downloadMaxLevel, download, downloadUrl
		for j, name in ipairs(guides) do
			local guide = addon.guides[name]
			--if addon.debugging then print("LIME: guide", group, name) end
			
			if guide.next ~= nil and #guide.next > 0 and addon.guides[group .. guide.next[1]] == nil and guide.download ~= nil then
				downloadMinLevel, downloadMaxLevel, download, downloadUrl = guide.downloadMinLevel, guide.downloadMaxLevel, guide.download, guide.downloadUrl 	
			end
		end
		
		if download == nil or GuidelimeData.displayDemoGuides then
			addon.guidesFrame.groups[group] = addon.guidesFrame.content:CreateFontString(nil, addon.guidesFrame.content, "GameFontNormal")
			if prev == addon.guidesFrame.content then
				addon.guidesFrame.groups[group]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
			else
				addon.guidesFrame.groups[group]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -10, -10)
			end
			addon.guidesFrame.groups[group]:SetText(group)
			prev = addon.guidesFrame.groups[group]
			for j, name in ipairs(guides) do
				local guide = addon.guides[name]
	
				local text = ""
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
				addon.guidesFrame.guides[name] = addon.addMultilineText(addon.guidesFrame.content, text, 550, nil, function(self)
					addon.loadGuide(self.name)
				end)
				if j == 1 then
					addon.guidesFrame.guides[name]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 10, -5)
				else
					addon.guidesFrame.guides[name]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
				end
				addon.guidesFrame.guides[name]:SetTextColor(255,255,255,255)
				addon.guidesFrame.guides[name]:SetBackdrop({
					--bgFile = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight",
					bgFile = "Interface\\AddOns\\" .. addonName .. "\\Icons\\TitleHighlight",
					tile = false, edgeSize = 0
				})
				addon.guidesFrame.guides[name].name = name
				addon.guidesFrame.guides[name].guide = guide
				if name == GuidelimeDataChar.currentGuide then
					addon.guidesFrame.guides[name]:SetBackdropColor(1,1,0,1)	
				else
					addon.guidesFrame.guides[name]:SetBackdropColor(0,0,0,0)	
				end
				addon.guidesFrame.guides[name]:SetScript("OnEnter", function(self)
					addon.guidesFrame.textDetails:SetText(self.guide.details or "")
					addon.guidesFrame.textDetails.url = self.guide.detailsUrl or ""
					if self.name ~= GuidelimeDataChar.currentGuide then
						self:SetBackdropColor(0.5,0.5,1,1)	
					end
				end)
				addon.guidesFrame.guides[name]:SetScript("OnLeave", function(self)
					if GuidelimeDataChar.currentGuide ~= nil and addon.guides[GuidelimeDataChar.currentGuide] ~= nil then
						addon.guidesFrame.textDetails:SetText(addon.guides[GuidelimeDataChar.currentGuide].details or "")
						addon.guidesFrame.textDetails.url = addon.guides[GuidelimeDataChar.currentGuide].detailsUrl or ""
					end
					if self.name ~= GuidelimeDataChar.currentGuide then
						self:SetBackdropColor(0,0,0,0)	
					end
				end)
				prev = addon.guidesFrame.guides[name]
			end
			if download ~= nil then
				addon.guidesFrame.messages[group] = addon.addMultilineText(addon.guidesFrame.content, 
					string.format(L.DOWNLOAD_FULL_GUIDE, downloadMinLevel, downloadMaxLevel, download, "\n|cFFAAAAAA" .. downloadUrl), 
					550, nil, function()
						InterfaceOptionsFrame:Hide()
						addon.showUrlPopup(downloadUrl) 
					end)
				addon.guidesFrame.messages[group]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -5)
				prev = addon.guidesFrame.messages[group]
			end
		end
	end

	if prev == addon.guidesFrame.content then
		addon.guidesFrame.guideListMessage:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
	else
		addon.guidesFrame.guideListMessage:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -10, -20)
	end
end

function addon.isGuidesShowing()
	return InterfaceOptionsFrame:IsShown() and InterfaceOptionsFramePanelContainer.displayedPanel == addon.guidesFrame
end

function addon.showGuides()
	if not addon.dataLoaded then loadData() end
	if addon.isGuidesShowing() then 
		InterfaceOptionsFrame:Hide()
	else
		if addon.isEditorShowing() then addon.editorFrame:Hide() end
		-- calling twice ensures guides are shown. calling once might only show game options. why? idk
		InterfaceOptionsFrame_OpenToCategory(addon.guidesFrame)
		InterfaceOptionsFrame_OpenToCategory(addon.guidesFrame)
	end
end


