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

function G.loadGuide(name)
	if addon.debugging then print("LIME: load guide", name) end
	
	if G.guidesFrame ~= nil then
		if GuidelimeDataChar.currentGuide ~= nil and G.guidesFrame.guides[GuidelimeDataChar.currentGuide] ~= nil then
			G.guidesFrame.guides[GuidelimeDataChar.currentGuide]:SetBackdropColor(0,0,0,0)	
		end
		G.guidesFrame.guides[name]:SetBackdropColor(1,1,0,1)
		G.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. name .. "\n")
	end
	if E.editorFrame ~= nil then
		E.editorFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. name .. "\n")
		if addon.guides[name] ~= nil then
			E.editorFrame.textBox:SetText(addon.guides[name].text:gsub("|","¦"))
		end
	end
	GuidelimeDataChar.currentGuide = name
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
	
	InterfaceOptionsFrame:Hide() 

	if G.guidesFrame == nil then
		G.guidesFrame = F.createPopupFrame(nil, nil, false, 700)
		G.guidesFrame:SetWidth(800)
		G.guidesFrame:SetPoint(GuidelimeDataChar.editorFrameRelative, UIParent, GuidelimeDataChar.editorFrameRelative, GuidelimeDataChar.editorFrameX, GuidelimeDataChar.editorFrameY)
		
		G.guidesFrame.okBtn:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
		G.guidesFrame.okBtn:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight")
		G.guidesFrame.okBtn:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
		G.guidesFrame.okBtn:ClearAllPoints()
		G.guidesFrame.okBtn:SetPoint("TOPRIGHT", G.guidesFrame, -10, -10)
		G.guidesFrame.okBtn:SetSize(24, 24)
		G.guidesFrame.okBtn:SetText(nil)
	
		G.guidesFrame.title = G.guidesFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		G.guidesFrame.title:SetText(GetAddOnMetadata(addonName, "title") .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version"))
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
	
	    local scrollFrame = CreateFrame("ScrollFrame", nil, G.guidesFrame, "UIPanelScrollFrameTemplate")
	    scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -20)
	    scrollFrame:SetPoint("RIGHT", G.guidesFrame, "RIGHT", -30, 0)
	    scrollFrame:SetPoint("BOTTOM", G.guidesFrame, "BOTTOM", 0, 160)
	
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
			if name == GuidelimeDataChar.currentGuide then
				G.guidesFrame.guides[name]:SetBackdropColor(1,1,0,1)	
			else
				G.guidesFrame.guides[name]:SetBackdropColor(0,0,0,0)	
			end
			G.guidesFrame.guides[name]:SetScript("OnEnter", function(self)
				G.guidesFrame.textDetails:SetText(self.guide.details or "")
				G.guidesFrame.textDetails.url = self.guide.detailsUrl or ""
				if self.name ~= GuidelimeDataChar.currentGuide then
					self:SetBackdropColor(0.5,0.5,1,1)	
				end
			end)
			G.guidesFrame.guides[name]:SetScript("OnLeave", function(self)
				if GuidelimeDataChar.currentGuide ~= nil and addon.guides[GuidelimeDataChar.currentGuide] ~= nil then
					G.guidesFrame.textDetails:SetText(addon.guides[GuidelimeDataChar.currentGuide].details or "")
					G.guidesFrame.textDetails.url = addon.guides[GuidelimeDataChar.currentGuide].detailsUrl or ""
				end
				if self.name ~= GuidelimeDataChar.currentGuide then
					self:SetBackdropColor(0,0,0,0)	
				end
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
end

function G.isGuidesShowing()
	return G.guidesFrame ~= nil and G.guidesFrame:IsVisible()
end
