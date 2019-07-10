local addonName, addon = ...
local L = addon.L

local function insertCode(typ, text, replace)
	local newCode = "[" .. addon.codes[typ] .. (text or "") .. "]\n"
	if replace then
		if text == nil or text == "" then 
			newCode = "" 
		else 
			replace = false 
		end
		local newText = addon.editorFrame.textBox:GetText():gsub("%[" .. addon.codes[typ] .. ".-%]\n", function() replace = true; return newCode; end)
		if replace then	addon.editorFrame.textBox:SetText(newText) end
	end
	if not replace then
		addon.editorFrame.textBox:Insert(newCode)
	end
end

function addon.showEditPopupNAME(typ, guide)
	local popup = addon.createPopupFrame(nil, function(popup)
		local min = tonumber(popup.textboxMinlevel:GetText())
		if min == nil and popup.textboxMinlevel:GetText() ~= "" then error (L.MINIMUM_LEVEL .. " is not a number") end
		local max = tonumber(popup.textboxMaxlevel:GetText())
		if max == nil and popup.textboxMaxlevel:GetText() ~= "" then error (L.MAXIMUM_LEVEL .. " is not a number") end
		insertCode(typ, (min or "") .. "-" .. (max or "") .. popup.textboxName:GetText(), true)
	end, true, 140)
	popup.textboxName = addon.addTextbox(popup, L.NAME, 420)
	popup.textboxName.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxName:SetPoint("TOPLEFT", 120, -20)
	popup.textboxMinlevel = addon.addTextbox(popup, L.MINIMUM_LEVEL, 420)
	popup.textboxMinlevel.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxMinlevel:SetPoint("TOPLEFT", 120, -50)
	popup.textboxMaxlevel = addon.addTextbox(popup, L.MAXIMUM_LEVEL, 420)
	popup.textboxMaxlevel.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxMaxlevel:SetPoint("TOPLEFT", 120, -80)
	if typ == "NAME" then
		if guide.title ~= nil then popup.textboxName:SetText(guide.title) end
		if guide.minLevel ~= nil then popup.textboxMinlevel:SetText(guide.minLevel) end
		if guide.maxLevel ~= nil then popup.textboxMaxlevel:SetText(guide.maxLevel) end
	elseif typ == "NEXT" and guide.next ~= nil then
		guide.next:gsub("(%d*)%s*-%s*(%d*)%s*(.*)", function (minLevel, maxLevel, title)
			if title ~= nil then popup.textboxName:SetText(title) end
			if minLevel ~= nil then popup.textboxMinlevel:SetText(minLevel) end
			if maxLevel ~= nil then popup.textboxMaxlevel:SetText(maxLevel) end
		end, 1)
	end
	popup:Show()
end
addon.showEditPopupNEXT = addon.showEditPopupNAME

function addon.showEditPopupDETAILS(typ, guide)
	local popup = addon.createPopupFrame(nil, function(popup)
		insertCode(typ, " " .. popup.textboxName:GetText(), true)
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

function addon.popupAppliesSetEnabledCheckboxes(popup, typ, guide)
	local faction
	local factionLocked = false
	for i, class in ipairs(addon.classes) do
		if popup.checkboxes[class]:GetChecked() then
			if addon.classesWithFaction[class] ~= nil then faction = addon.classesWithFaction[class]; break end
		end
	end
	if faction == nil then
		for race, f in pairs(addon.races) do
			if popup.checkboxes[race]:GetChecked() then	faction = f; break end
		end
	end
	if faction == nil then
		for i, f in ipairs(addon.factions) do
			if popup.checkboxes[f]:GetChecked() then faction = f; break	end
		end
	else
		factionLocked = true
	end		
	for key, box in pairs(popup.checkboxes) do
		if addon.isFaction(key) then
			box:SetEnabled(not factionLocked and (faction == nil or faction == key))
		elseif addon.isRace(key) then
			box:SetEnabled(faction == nil or faction == addon.races[key])
		else
			box:SetEnabled(faction == nil or addon.classesWithFaction[key] == nil or faction == addon.classesWithFaction[key])
		end
	end
	if typ == "APPLIES" then
		-- also respect restrictions from GUIDE_APPLIES
		local faction = guide.faction
		if faction == nil and guide.race ~= nil then faction = addon.races[guide.race[1]] end
		if faction == nil and guide.class ~= nil then
			for i, class in ipairs(guide.class) do
				if addon.classesWithFaction[class] ~= nil then faction = addon.classesWithFaction[class] end
			end
		end
		if addon.debugging then print("LIME :", faction) end
		for key, box in pairs(popup.checkboxes) do
			if addon.isFaction(key) and faction ~= nil then
				box:SetEnabled(false)
			elseif addon.isRace(key) and 
				((faction ~= nil and faction ~= addon.races[key]) or 
				(guide.race ~= nil and not addon.contains(guide.race, key)) or
				(guide.race ~= nil and #guide.race == 1)) then
				box:SetEnabled(false)
			elseif addon.isClass(key) and 
				((faction ~= nil and addon.classesWithFaction[key] ~= nil and faction ~= addon.classesWithFaction[key]) or 
				(guide.class ~= nil and not addon.contains(guide.class, key)) or
				(guide.class ~= nil and #guide.class == 1)) then
				box:SetEnabled(false)
			end
		end
	end
	for key, box in pairs(popup.checkboxes) do
		if box:IsEnabled() then
			box.text:SetText(L[key])
		else
			box.text:SetText(addon.COLOR_INACTIVE .. L[key])
		end
	end
end

function addon.showEditPopupAPPLIES(typ, guide)
	local popup = addon.createPopupFrame(nil, function(popup)
		local text = ""
		local factionLocked = false
		for i, class in ipairs(addon.classes) do
			if popup.checkboxes[class]:GetChecked() then
				if text ~= "" then text = text .. "," end
				text = text .. class
				if addon.classesWithFaction[class] ~= nil then factionLocked = true end
			end
		end
		for race, faction in pairs(addon.races) do
			if popup.checkboxes[race]:GetChecked() then
				if text ~= "" then text = text .. "," end
				text = text .. race
				factionLocked = true
			end
		end
		if not factionLocked then
			for i, faction in ipairs(addon.factions) do
				if popup.checkboxes[faction]:GetChecked() then
					if text ~= "" then text = text .. "," end
					text = text .. faction
				end
			end
		end		
		if text ~= "" then text = " " .. text end
		insertCode(typ, text, typ == "GUIDE_APPLIES")
	end, true, 300)
	
	popup.checkboxes = {}
	local left = {}
	for i, faction in ipairs(addon.factions) do
		popup.checkboxes[faction] = addon.addCheckbox(popup, L[faction])
		left[faction] = 20 + i * 160
		popup.checkboxes[faction]:SetPoint("TOPLEFT", left[faction], -20)
		if typ == "GUIDE_APPLIES" and guide.faction ~= nil and guide.faction == faction then popup.checkboxes[faction]:SetChecked(true) end
		popup.checkboxes[faction]:SetScript("OnClick", function()
			addon.popupAppliesSetEnabledCheckboxes(popup, typ, guide)
		end)
	end
	for i, class in ipairs(addon.classes) do
		popup.checkboxes[class] = addon.addCheckbox(popup, L[class])
		popup.checkboxes[class]:SetPoint("TOPLEFT", 20, 5 - i * 25)
		if typ == "GUIDE_APPLIES" and guide.class ~= nil and addon.contains(guide.class, class) then 
			popup.checkboxes[class]:SetChecked(true)
			if addon.classesWithFaction[class] ~= nil then popup.checkboxes[addon.classesWithFaction[class]]:SetChecked(true) end
		end
		popup.checkboxes[class]:SetScript("OnClick", function()
			if addon.classesWithFaction[class] ~= nil and popup.checkboxes[class]:GetChecked() then popup.checkboxes[addon.classesWithFaction[class]]:SetChecked(true) end
			addon.popupAppliesSetEnabledCheckboxes(popup, typ, guide)
		end)
	end
	local count = {}
	for race, faction in pairs(addon.races) do
		popup.checkboxes[race] = addon.addCheckbox(popup, L[race])
		if count[faction] == nil then count[faction] = 1 else count[faction] = count[faction] + 1 end
		popup.checkboxes[race]:SetPoint("TOPLEFT", left[faction], -50 - count[faction] * 30)
		if typ == "GUIDE_APPLIES" and guide.race ~= nil and addon.contains(guide.race, race) then 
			popup.checkboxes[race]:SetChecked(true)
			popup.checkboxes[faction]:SetChecked(true)
		end
		popup.checkboxes[race]:SetScript("OnClick", function()
			if popup.checkboxes[race]:GetChecked() then popup.checkboxes[faction]:SetChecked(true) end
			addon.popupAppliesSetEnabledCheckboxes(popup, typ, guide)
		end)
	end
	addon.popupAppliesSetEnabledCheckboxes(popup, typ, guide)		
	popup:Show()
end
addon.showEditPopupGUIDE_APPLIES = addon.showEditPopupAPPLIES

function addon.showEditPopupQUEST(typ, guide)
	local popup = addon.createPopupFrame(nil, function(popup)
		local text = popup.textboxName:GetText()
		local id = tonumber(text)
		if id == nil then
			local ids = addon.getPossibleQuestIdsByName(text)
			if ids == nil then
				error("Quest \"" .. text .. "\" was not found")
			elseif #ids > 1 then
				local msg = "More than one quest \"" .. text .. "\" was found. Enter one of these ids: "
				for i, id in ipairs(ids) do
					if i > 1 then msg = msg .. ", " end
					msg = msg .. id
				end
				error(msg)
			end
			id = ids[1]
		else
			text = addon.getQuestNameById(id)
		end
		--if text == addon.getQuestNameById(id) then text = "" end
		local objective = ""
		if (popup.key == "C" or popup.key == "W") and popup.textboxObjective:GetText() ~= "" then
			objective = "," .. popup.textboxObjective:GetText()
		end
		insertCode(typ, popup.key .. id .. objective .. text)
	end, true, 150)
	popup.checkboxes = {}
	for i, key in ipairs({"A", "C", "T", "W", "S"}) do
		popup.checkboxes[key] = addon.addCheckbox(popup, L["QUEST_" .. key], L["QUEST_" .. key .. "_TOOLTIP"])
		popup.checkboxes[key]:SetPoint("TOPLEFT", -80 + i * 100, -10)
		popup.checkboxes[key]:SetScript("OnClick", function()
			for k, box in pairs(popup.checkboxes) do
				box:SetChecked(k == key)
			end
			popup.key = key
			if key == "C" or key == "W" then
				popup.textboxObjective:Show()
				popup.textboxObjective.text:Show()
			else
				popup.textboxObjective:Hide()
				popup.textboxObjective.text:Hide()
			end
		end)
	end
	popup.key = "P"
	popup.checkboxes[popup.key]:SetChecked(true)
	popup.textboxName = addon.addTextbox(popup, L.QUEST_NAME, 410, L.QUEST_NAME_TOOLTIP)
	popup.textboxName.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxName:SetPoint("TOPLEFT", 130, -50)
	popup.textboxObjective = addon.addTextbox(popup, L.QUEST_OBJECTIVE, 420, L.QUEST_OBJECTIVE_TOOLTIP)
	popup.textboxObjective.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxObjective:SetPoint("TOPLEFT", 120, -80)
	popup.textboxObjective:Hide()
	popup.textboxObjective.text:Hide()
	popup:Show()
end

function addon.showEditPopupGOTO(typ, guide)
	local popup = addon.createPopupFrame(nil, function(popup)
		local x = tonumber(popup.textboxX:GetText())
		if x == nil then error ("X is not a number") end
		local y = tonumber(popup.textboxY:GetText())
		if y == nil then error ("Y is not a number") end
		local zone = popup.textboxZone:GetText()
		if zone ~= "" and addon.mapIDs[zone] == nil then 
			error (zone .. " is not a zone") 
			local msg = zone .. " is not a zone. Enter one of these zone names: "
			local first = true
			for zone, id in pairs(addon.mapIDs) do
				if not first then msg = msg .. ", " end
				msg = msg .. zone
				first = false
			end
			error(msg)
		end
		insertCode(typ, x .. "," .. y .. zone)
	end, true, 140)
	popup.textboxX = addon.addTextbox(popup, "X", 420)
	popup.textboxX.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxX:SetPoint("TOPLEFT", 120, -20)
	popup.textboxY = addon.addTextbox(popup, "Y", 420)
	popup.textboxY.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxY:SetPoint("TOPLEFT", 120, -50)
	popup.textboxZone = addon.addTextbox(popup, L.ZONE, 420, L.EDITOR_TOOLTIP_ZONE)
	popup.textboxZone.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxZone:SetPoint("TOPLEFT", 120, -80)
	
	local x, y = HBD:GetPlayerZonePosition()
	popup.textboxX:SetText(math.floor(x * 10000) / 100)
	popup.textboxY:SetText(math.floor(y * 10000) / 100)
	local mapID = HBD:GetPlayerZone()
	popup.textboxZone:SetText(addon.zoneNames[mapID])
	popup:Show()
end

local function popupXPCodeValues(popup)
	local level = tonumber(popup.textboxLevel:GetText())
	local xp
	if popup.key ~= "" then
		xp = math.floor(tonumber(popup.textboxXP:GetText()))
	end
	return level, xp
end

function addon.showEditPopupXP(typ, guide)
	local popup = addon.createPopupFrame(nil, function(popup)
		local level, xp = popupXPCodeValues(popup)
		if level == nil then error (L.LEVEL .. " is not a number") end
		if popup.key ~= "" and xp == nil then error (L["XP_LEVEL" .. popup.key] .. " is not a number") end
		if popup.key == "%" and (xp < 0 or xp >= 100) then error (L["XP_LEVEL" .. popup.key] .. " is not between 0 and 100") end
		local text = popup.textboxText:GetText()
		if text ~= "" then text = " " .. text end
		insertCode(typ, level .. (popup.key or "") .. (xp or "") .. text)
	end, true, 170)
	popup.textboxLevel = addon.addTextbox(popup, L.LEVEL, 420)
	popup.textboxLevel.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxLevel:SetPoint("TOPLEFT", 120, -20)
	popup.checkboxes = {}
	for i, key in ipairs({"", "+", "-", "%"}) do
		popup.checkboxes[key] = addon.addCheckbox(popup, L["XP_LEVEL" .. key], L["XP_LEVEL" .. key .. "_TOOLTIP"])
		popup.checkboxes[key]:SetPoint("TOPLEFT", -110 + i * 130, -40)
		popup.checkboxes[key]:SetScript("OnClick", function()
			popup.key = key
			for k, box in pairs(popup.checkboxes) do
				box:SetChecked(k == key)
			end
			if key == "" then
				popup.textboxXP:Hide()
				popup.textboxXP.text:Hide()
			else
				popup.textboxXP:Show()
				popup.textboxXP.text:Show()
				popup.textboxXP.text:SetText(L["XP" .. key])
			end
		end)
	end
	popup.key = ""
	popup.checkboxes[popup.key]:SetChecked(true)
	popup.textboxXP = addon.addTextbox(popup, "", 420)
	popup.textboxXP.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxXP:SetPoint("TOPLEFT", 120, -80)
	popup.textboxXP:Hide()
	popup.textboxXP.text:Hide()
	popup.textboxText = addon.addTextbox(popup, L.XP_TEXT, 420)
	popup.textboxText.text:SetPoint("TOPLEFT", 20, -110)
	popup.textboxText:SetPoint("TOPLEFT", 120, -110)
	popup.textboxText:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32)
		local level, xp = popupXPCodeValues(popup)
		GameTooltip:SetText(L.XP_TEXT_TOOLTIP:format((level or "") .. (popup.key or "") .. (xp or "")))
		GameTooltip:Show() 
	end)
	popup.textboxText:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	
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
		button:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
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
			insertCode(typ)
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
	addon.editorFrame.textBox:SetEnabled(false)
	
	addon.editorFrame.textBox:SetScript("OnShow", function(self) 
		addon.editorFrame.textBox:SetEnabled(true)
	end)
	addon.editorFrame.textBox:SetScript("OnHide", function(self) 
		addon.editorFrame.textBox:SetEnabled(false)
	end)

	prev = addEditButton("NAME")
	prev = addEditButton("NEXT", prev)
	prev = addEditButton("DETAILS", prev)
	prev = addEditButton("GUIDE_APPLIES", prev)
	prev = addEditButton("APPLIES", prev)
	prev = addEditButton("OPTIONAL", prev)
	prev = addEditButton("COMPLETE_WITH_NEXT", prev)
	prev = addEditButton("QUEST", prev) -- TODO
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
	addon.editorFrame:Hide()
end

function addon.showEditor()
	if not addon.dataLoaded then loadData() end
	InterfaceOptionsFrame_Show() 
	InterfaceOptionsFrame_OpenToCategory(addon.editorFrame)
end
