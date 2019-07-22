local addonName, addon = ...
local L = addon.L

function addon.loadGuide(name)
	if addon.debugging then print("LIME: load guide", name) end
	
	if GuidelimeDataChar.currentGuide.name ~= nil then
		addon.guidesFrame.guides[GuidelimeDataChar.currentGuide.name]:SetBackdropColor(0,0,0,0)	
	end
	addon.guidesFrame.guides[name]:SetBackdropColor(1,1,0,1)
	GuidelimeDataChar.currentGuide = {name = name, skip = {}}
	if addon.guidesFrame ~= nil then
		addon.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. name .. "\n")
	end
	if addon.editorFrame ~= nil then
		addon.editorFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. name .. "\n")
		if addon.guides[GuidelimeDataChar.currentGuide.name] ~= nil then
			addon.editorFrame.textBox:SetText(addon.guides[GuidelimeDataChar.currentGuide.name].text)
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
	addon.loadGuide(GuidelimeDataChar.currentGuide.name)
end

local function showUrlPopup(url)
	local popup = addon.createPopupFrame(nil, nil, false, 80)
	popup.textboxName = addon.addTextbox(popup, L.URL, 420)
	popup.textboxName.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxName:SetPoint("TOPLEFT", 120, -20)
	popup.textboxName:SetText(url)
	popup.textboxName:SetFocus()
	popup.textboxName:HighlightText(false)
	popup:Show()
end

function addon.fillGuides()
    addon.guidesFrame = CreateFrame("Frame", nil, UIParent)
    addon.guidesFrame.name = GetAddOnMetadata(addonName, "title")
    InterfaceOptions_AddCategory(addon.guidesFrame)
	
	addon.guidesFrame.title = addon.guidesFrame:CreateFontString(nil, addon.guidesFrame, "GameFontNormal")
	addon.guidesFrame.title:SetText(GetAddOnMetadata(addonName, "title") .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version"))
	addon.guidesFrame.title:SetPoint("TOPLEFT", addon.guidesFrame, "TOPLEFT", 20, -20)
	addon.guidesFrame.title:SetFontObject("GameFontNormalLarge")
	local prev = addon.guidesFrame.title
	
	addon.guidesFrame.text1 = addon.guidesFrame:CreateFontString(nil, addon.guidesFrame, "GameFontNormal")
	if GuidelimeDataChar.currentGuide ~= nil then
		addon.guidesFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. (GuidelimeDataChar.currentGuide.name or "") .. "\n")
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
			--if addon.debugging then print("LIME: guide", group, name) end
			
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
			addon.guidesFrame.guides[name] = addon.addMultilineText(content, text, 550, nil, function(self)
				addon.loadGuide(self.name)
			end)
			addon.guidesFrame.guides[name]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
			addon.guidesFrame.guides[name]:SetTextColor(255,255,255,255)
			addon.guidesFrame.guides[name]:SetBackdrop({
				--bgFile = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight",
				bgFile = "Interface\\AddOns\\" .. addonName .. "\\Icons\\TitleHighlight",
				tile = false, edgeSize = 0
			})
			addon.guidesFrame.guides[name].name = name
			addon.guidesFrame.guides[name].guide = guide
			if name == GuidelimeDataChar.currentGuide.name then
				addon.guidesFrame.guides[name]:SetBackdropColor(1,1,0,1)	
			else
				addon.guidesFrame.guides[name]:SetBackdropColor(0,0,0,0)	
			end
			addon.guidesFrame.guides[name]:SetScript("OnEnter", function(self)
				addon.guidesFrame.textDetails:SetText(self.guide.details or "")
				addon.guidesFrame.textDetails.url = self.guide.detailsUrl or ""
				if self.name ~= GuidelimeDataChar.currentGuide.name then
					self:SetBackdropColor(0.5,0.5,1,1)	
				end
			end)
			addon.guidesFrame.guides[name]:SetScript("OnLeave", function(self)
				if self.name ~= GuidelimeDataChar.currentGuide.name then
					self:SetBackdropColor(0,0,0,0)	
				end
			end)
			prev = addon.guidesFrame.guides[name]
		end
	end
	prev = scrollFrame
	
	addon.guidesFrame.text3 = addon.guidesFrame:CreateFontString(nil, addon.guidesFrame, "GameFontNormal")
	addon.guidesFrame.text3:SetText(L.DETAILS .. ":\n")
	addon.guidesFrame.text3:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
	prev = addon.guidesFrame.text3

    scrollFrame = CreateFrame("ScrollFrame", nil, addon.guidesFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -20)
    scrollFrame:SetPoint("RIGHT", addon.guidesFrame, "RIGHT", -30, 0)
    scrollFrame:SetPoint("BOTTOM", addon.guidesFrame, "BOTTOM", 0, 60)

    content = CreateFrame("Frame", nil, scrollFrame) 
    content:SetSize(1, 1) 
    scrollFrame:SetScrollChild(content)

	addon.guidesFrame.textDetails = addon.addMultilineText(content, nil, 550, nil, function()
		if addon.guidesFrame.textDetails.url ~= nil then showUrlPopup(addon.guidesFrame.textDetails.url) end
	end)
	addon.guidesFrame.textDetails:SetPoint("TOPLEFT", content, "BOTTOMLEFT", 0, 0)
	addon.guidesFrame.textDetails:SetTextColor(255,255,255,255)
	if addon.guides[GuidelimeDataChar.currentGuide.name] ~= nil and addon.guides[GuidelimeDataChar.currentGuide.name].details ~= nil then
		addon.guidesFrame.textDetails:SetText(addon.guides[GuidelimeDataChar.currentGuide.name].details)
		addon.guidesFrame.textDetails.url = addon.guides[GuidelimeDataChar.currentGuide.name].detailsUrl or ""
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


