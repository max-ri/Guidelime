local addonName, addon = ...
local L = addon.L

local function replaceCode(typ, text)
	local found = false
	local newCode = "[" .. addon.codes[typ] .. text .. "]"
	local newText = addon.editorFrame.textBox:GetText():gsub("%[" .. addon.codes[typ] .. ".-%]", function() found = true; return newCode; end)
	if found then
		addon.editorFrame.textBox:SetText(newText)
	else
		addon.editorFrame.textBox:Insert(newCode .. "\n")
	end
end

function addon.showEditPopupNAME(typ, guide)
	local popup = addon.createPopupFrame(nil, function(popup)
		local min = tonumber(popup.textboxMinlevel:GetText())
		if min == nil and popup.textboxMinlevel:GetText() ~= "" then error ("not a number") end
		local max = tonumber(popup.textboxMaxlevel:GetText())
		if max == nil and popup.textboxMaxlevel:GetText() ~= "" then error ("not a number") end
		replaceCode(typ, (min or "") .. "-" .. (max or "") .. popup.textboxName:GetText())
	end, true, 140)
	popup.textName = popup:CreateFontString(nil, popup, "GameFontNormal")
	popup.textName:SetText(L.NAME)
	popup.textName:SetPoint("TOPLEFT", 20, -20)
	popup.textboxName = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
	popup.textboxName:SetFontObject("GameFontNormal")
	if guide.title ~= nil then popup.textboxName:SetText(guide.title) end
	popup.textboxName:SetPoint("TOPLEFT", 120, -20)
	popup.textboxName:SetHeight(10)
	popup.textboxName:SetWidth(420)
	popup.textboxName:SetTextColor(255,255,255,255)
	popup.textMinlevel = popup:CreateFontString(nil, popup, "GameFontNormal")
	popup.textMinlevel:SetText(L.MINIMUM_LEVEL)
	popup.textMinlevel:SetPoint("TOPLEFT", 20, -50)
	popup.textboxMinlevel = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
	popup.textboxMinlevel:SetFontObject("GameFontNormal")
	if guide.minLevel ~= nil then popup.textboxMinlevel:SetText(guide.minLevel) end
	popup.textboxMinlevel:SetPoint("TOPLEFT", 120, -50)
	popup.textboxMinlevel:SetHeight(10)
	popup.textboxMinlevel:SetWidth(50)
	popup.textboxMinlevel:SetTextColor(255,255,255,255)
	popup.textMaxlevel = popup:CreateFontString(nil, popup, "GameFontNormal")
	popup.textMaxlevel:SetText(L.MAXIMUM_LEVEL)
	popup.textMaxlevel:SetPoint("TOPLEFT", 20, -80)
	popup.textboxMaxlevel = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
	popup.textboxMaxlevel:SetFontObject("GameFontNormal")
	if guide.maxLevel ~= nil then popup.textboxMaxlevel:SetText(guide.maxLevel) end
	popup.textboxMaxlevel:SetPoint("TOPLEFT", 120, -80)
	popup.textboxMaxlevel:SetHeight(10)
	popup.textboxMaxlevel:SetWidth(50)
	popup.textboxMaxlevel:SetTextColor(255,255,255,255)
	popup:Show()
end

function addon.showEditPopupDETAILS(typ, guide)
	local popup = addon.createPopupFrame(nil, function(popup)
		replaceCode(typ, " " .. popup.textboxName:GetText())
	end, true, 200)
	popup.textName = popup:CreateFontString(nil, popup, "GameFontNormal")
	popup.textName:SetText(L.DETAILS)
	popup.textName:SetPoint("TOPLEFT", 20, -20)
	popup.textboxName = CreateFrame("EditBox", nil, popup)
	popup.textboxName:SetFontObject("GameFontNormal")
	if guide.detailsRaw ~= nil then popup.textboxName:SetText(guide.detailsRaw) end
	popup.textboxName:SetPoint("TOPLEFT", 90, -20)
	popup.textboxName:SetMultiLine(true)
	popup.textboxName:SetWidth(450)
	popup.textboxName:SetTextColor(255,255,255,255)
	popup:Show()
end

local function addEditButton(typ, prev)
	local button = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
	button.typ = typ
	button:SetWidth(30)
	button:SetHeight(25)
	if addon.icons[typ] ~= nil then
	    button.texture = button:CreateTexture(nil, "TOOLTIP")
	    button.texture:SetTexture(addon.icons[typ])
	    button.texture:SetAllPoints(button)
		button.texture:SetTexCoord(-0.5,1.5,-0.5,1.5)
    	button:SetNormalTexture(button.texture)
	else
		button:SetText(addon.codes[typ])
	end
	if prev == nil then
		button:SetPoint("TOPLEFT", addon.editorFrame.scrollFrame, "TOPRIGHT", 30, 0)
	else
		button:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -1)
	end
	button.tooltip = L["EDITOR_TOOLTIP_" .. typ]
	if button.tooltip ~= nil then
		button:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show() end)
		button:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	end
	button:SetScript("OnClick", function(self)
		local showEditPopup = addon["showEditPopup" .. self.typ]
		if showEditPopup ~= nil then
			showEditPopup(self.typ, addon.parseGuide(addon.editorFrame.textBox:GetText(), L.CUSTOM_GUIDES))
		else
			addon.editorFrame.textBox:Insert("[" .. addon.codes[typ] .. "]\n") 
		end
	end)
	return button
end

function addon.fillEditor()
	addon.editorFrame = CreateFrame("FRAME", nil, addon.guidesFrame)
	addon.editorFrame.name = L.EDITOR
	addon.editorFrame.parent = addonName
	InterfaceOptions_AddCategory(addon.editorFrame)

	addon.editorFrame.title = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
	addon.editorFrame.title:SetText(addonName .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version") .." - " .. L.EDITOR)
	addon.editorFrame.title:SetPoint("TOPLEFT", 20, -20)
	addon.editorFrame.title:SetFontObject("GameFontNormalLarge")
	local prev = addon.editorFrame.title
	
	addon.editorFrame.text1 = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
	if GuidelimeDataChar.currentGuide ~= nil then
		addon.editorFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. (GuidelimeDataChar.currentGuide.name or "") .. "\n")
	else
		addon.editorFrame.text1:SetText(L.CURRENT_GUIDE .. ":\n")
	end
	addon.editorFrame.text1:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -30)
	prev = addon.editorFrame.text1
	
    addon.editorFrame.scrollFrame = CreateFrame("ScrollFrame", nil, addon.editorFrame, "UIPanelScrollFrameTemplate")
    addon.editorFrame.scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -40)
    addon.editorFrame.scrollFrame:SetPoint("RIGHT", addon.editorFrame, "RIGHT", -80, 0)
    addon.editorFrame.scrollFrame:SetPoint("BOTTOM", addon.editorFrame, "BOTTOM", 0, 60)

    local content = CreateFrame("Frame", nil, addon.editorFrame.scrollFrame) 
    content:SetSize(1, 1) 
    addon.editorFrame.scrollFrame:SetScrollChild(content)
	
	addon.editorFrame.textBox = CreateFrame("EditBox", nil, content)
	if GuidelimeDataChar.currentGuide ~= nil and addon.guides[GuidelimeDataChar.currentGuide.name] ~= nil then
		addon.editorFrame.textBox:SetText(addon.guides[GuidelimeDataChar.currentGuide.name].text)
	end
	addon.editorFrame.textBox:SetMultiLine(true)
	addon.editorFrame.textBox:SetFontObject("GameFontNormal")
	addon.editorFrame.textBox:SetWidth(550)
	addon.editorFrame.textBox:SetPoint("TOPLEFT", content, "BOTTOMLEFT", 0, 0)
	addon.editorFrame.textBox:SetTextColor(255,255,255,255)

	prev = addEditButton("NAME")
	prev = addEditButton("DETAILS", prev)
	prev = addEditButton("GUIDE_APPLIES", prev)
	prev = addEditButton("APPLIES", prev)
	prev = addEditButton("OPTIONAL", prev)
	prev = addEditButton("COMPLETE_WITH_NEXT", prev)
	prev = addEditButton("QUEST", prev)
	prev = addEditButton("GOTO", prev)
	prev = addEditButton("XP", prev)
	prev = addEditButton("HEARTH", prev)
	prev = addEditButton("FLY", prev)
	prev = addEditButton("TRAIN", prev)
	prev = addEditButton("SET_HEARTH", prev)
	prev = addEditButton("GET_FLIGHT_POINT", prev)
	prev = addEditButton("VENDOR", prev)
	prev = addEditButton("REPAIR", prev)

	addon.editorFrame.saveBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
	addon.editorFrame.saveBtn:SetWidth(120)
	addon.editorFrame.saveBtn:SetHeight(30)
	addon.editorFrame.saveBtn:SetText(L.SAVE_GUIDE)
	addon.editorFrame.saveBtn:SetPoint("BOTTOMLEFT", addon.editorFrame, "BOTTOMLEFT", 20, 20)
	addon.editorFrame.saveBtn:SetScript("OnClick", function()
		local guide = addon.parseGuide(addon.editorFrame.textBox:GetText(), L.CUSTOM_GUIDES)
		local msg
		if GuidelimeData.customGuides == nil or GuidelimeData.customGuides[guide.name] == nil then
			msg = string.format(L.SAVE_MSG, guide.name)
		else
			msg = string.format(L.OVERWRITE_MSG, guide.name)
		end
		addon.createPopupFrame(msg, function()
			if GuidelimeData.customGuides == nil then GuidelimeData.customGuides = {} end
			GuidelimeData.customGuides[guide.name] = guide.text
			GuidelimeDataChar.currentGuide = {name = guide.name, skip = {}}
			ReloadUI()
		end, true):Show()
	end)
end

function addon.showEditor()
	if not addon.dataLoaded then loadData() end
	InterfaceOptionsFrame_Show() 
	InterfaceOptionsFrame_OpenToCategory(addon.editorFrame)
end
