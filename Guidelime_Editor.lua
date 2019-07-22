local addonName, addon = ...
local L = addon.L

local function setEditorMapIcons(guide)
	addon.removeMapIcons()
	addon.hideArrow()
	local highlight = true
	for i, step in ipairs(guide.steps) do
		for j, element in ipairs(step.elements) do
			if element.t == "LOC" or element.t == "GOTO" then
				addon.addMapIcon(element, i == addon.editorFrame.selectedStepIndex and j == addon.editorFrame.selectedElementIndex, true)
			end
		end
	end
	addon.showMapIcons()
end

local function getElementByPos(pos, guide)
	for i, step in ipairs(guide.steps) do
		for j, element in ipairs(step.elements) do
			--print(element.startPos .. "-" .. element.endPos)
			if element.startPos <= pos and element.endPos >= pos then
				return step, element, i, j
			end
		end
	end
end

local function parseGuide()
	local guide = addon.parseGuide(addon.editorFrame.textBox:GetText())
	local lines = {}
	for i = 1, guide.lines do lines[i] = i end
	local pos = addon.editorFrame.textBox:GetCursorPosition() + 1
	addon.editorFrame.selectedStep, addon.editorFrame.selectedElement, addon.editorFrame.selectedStepIndex, addon.editorFrame.selectedElementIndex = getElementByPos(pos, guide)
	addon.editorFrame.linesBox:SetText(table.concat(lines, "\n"))
	setEditorMapIcons(guide)
	return guide
end

local function insertCode(typ, text, element, replace)
	local newCode = "[" .. addon.codes[typ] .. (text or "") .. "]"
	if element ~= nil then
		local oldText = addon.editorFrame.textBox:GetText()
		local newText = oldText:sub(1, element.startPos - 1) .. newCode .. oldText:sub(element.endPos + 1)
		if addon.debugging then	print("LIME: replacing \"" .. oldText:sub(element.startPos, element.endPos) .. "\" with \"" .. newCode .. "\"") end
		addon.editorFrame.textBox:SetText(newText)
		addon.editorFrame.textBox:HighlightText(element.startPos - 1, element.endPos - 1)
		return
	elseif replace then
		if text == nil or text == "" then 
			newCode = "" 
		else 
			replace = false 
		end
		local s, e = addon.editorFrame.textBox:GetText():find("%[" .. addon.codes[typ] .. ".-%]")
		if s ~= nil then
			replace = true
			local oldText = addon.editorFrame.textBox:GetText()
			local newText = oldText:sub(1, s - 1) .. newCode .. oldText:sub(e + 1)
			addon.editorFrame.textBox:SetText(newText)
			addon.editorFrame.textBox:HighlightText(s, s + #newCode)
		end
	end
	if not replace then
		addon.editorFrame.textBox:Insert(newCode)
		addon.editorFrame.textBox:HighlightText(addon.editorFrame.textBox:GetCursorPosition() - #newCode, addon.editorFrame.textBox:GetCursorPosition())
	end
end

function addon.showEditPopupNAME(typ, guide, step, element)
	local popup = addon.createPopupFrame(nil, function(popup)
		local min = tonumber(popup.textboxMinlevel:GetText())
		if min == nil and popup.textboxMinlevel:GetText() ~= "" then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.MINIMUM_LEVEL))
			return false
		end
		local max = tonumber(popup.textboxMaxlevel:GetText())
		if max == nil and popup.textboxMaxlevel:GetText() ~= "" then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.MAXIMUM_LEVEL)) 
			return false
		end
		if popup.textboxName:GetText() == "" then
			addon.createPopupFrame(L.ERROR_GUIDE_HAS_NO_NAME) 
			return false
		end
		insertCode(typ, (min or "") .. "-" .. (max or "") .. popup.textboxName:GetText(), nil, true)
	end, true, 140)
	popup.textboxMinlevel = addon.addTextbox(popup, L.MINIMUM_LEVEL, 100)
	popup.textboxMinlevel.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxMinlevel:SetPoint("TOPLEFT", 120, -20)
	popup.textboxMaxlevel = addon.addTextbox(popup, L.MAXIMUM_LEVEL, 100)
	popup.textboxMaxlevel.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxMaxlevel:SetPoint("TOPLEFT", 120, -50)
	popup.textboxName = addon.addTextbox(popup, L.NAME, 420)
	popup.textboxName.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxName:SetPoint("TOPLEFT", 120, -80)
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

function addon.showEditPopupDETAILS(typ, guide, step, element)
	local popup = addon.createPopupFrame(nil, function(popup)
		if popup.textboxName:GetText() == "" then
			addon.createPopupFrame(L.ERROR_GUIDE_HAS_NO_NAME) 
			return false
		end
		insertCode(typ, " " .. popup.textboxName:GetText(), nil, true)
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

function addon.showEditPopupAPPLIES(typ, guide, step, element)
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
		insertCode(typ, text, element, typ == "GUIDE_APPLIES")
	end, true, 300)
	
	popup.checkboxes = {}
	local left = {}
	for i, faction in ipairs(addon.factions) do
		popup.checkboxes[faction] = addon.addCheckbox(popup, L[faction])
		left[faction] = 20 + i * 160
		popup.checkboxes[faction]:SetPoint("TOPLEFT", left[faction], -20)
		if typ == "GUIDE_APPLIES" then
			if guide.faction ~= nil and guide.faction == faction then popup.checkboxes[faction]:SetChecked(true) end
		elseif typ == "APPLIES" then
			if step ~= nil and step.faction ~= nil and step.faction == faction then popup.checkboxes[faction]:SetChecked(true) end
		end
		popup.checkboxes[faction]:SetScript("OnClick", function()
			addon.popupAppliesSetEnabledCheckboxes(popup, typ, guide)
		end)
	end
	for i, class in ipairs(addon.classes) do
		popup.checkboxes[class] = addon.addCheckbox(popup, addon.getLocalizedClass(class))
		popup.checkboxes[class]:SetPoint("TOPLEFT", 20, 5 - i * 25)
		if typ == "GUIDE_APPLIES" then
			if guide.class ~= nil and addon.contains(guide.class, class) then
				popup.checkboxes[class]:SetChecked(true)
				if addon.classesWithFaction[class] ~= nil then popup.checkboxes[addon.classesWithFaction[class]]:SetChecked(true) end
			end
		elseif typ == "APPLIES" then
			if step ~= nil and step.class ~= nil and addon.contains(step.class, class) then
				popup.checkboxes[class]:SetChecked(true)
				if addon.classesWithFaction[class] ~= nil then popup.checkboxes[addon.classesWithFaction[class]]:SetChecked(true) end
			end
		end
		popup.checkboxes[class]:SetScript("OnClick", function()
			if addon.classesWithFaction[class] ~= nil and popup.checkboxes[class]:GetChecked() then popup.checkboxes[addon.classesWithFaction[class]]:SetChecked(true) end
			addon.popupAppliesSetEnabledCheckboxes(popup, typ, guide)
		end)
	end
	local count = {}
	for race, faction in pairs(addon.races) do
		popup.checkboxes[race] = addon.addCheckbox(popup, addon.getLocalizedRace(race))
		if count[faction] == nil then count[faction] = 1 else count[faction] = count[faction] + 1 end
		popup.checkboxes[race]:SetPoint("TOPLEFT", left[faction], -50 - count[faction] * 30)
		if typ == "GUIDE_APPLIES" then
			if guide.race ~= nil and addon.contains(guide.race, race) then 
				popup.checkboxes[race]:SetChecked(true)
				popup.checkboxes[faction]:SetChecked(true)
			end
		elseif typ == "APPLIES" then
			if step ~= nil and step.race ~= nil and addon.contains(step.race, race) then 
				popup.checkboxes[race]:SetChecked(true)
				popup.checkboxes[faction]:SetChecked(true)
			end
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

function addon.showEditPopupQUEST(typ, guide, step, element)
	local popup = addon.createPopupFrame(nil, function(popup)
		local text = popup.textboxName:GetText()
		local id = tonumber(popup.textboxId:GetText())
		if id == nil and popup.textboxId:GetText() ~= "" then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.QUEST_ID))
			return false
		end
		if id == nil then
			local ids = addon.getPossibleQuestIdsByName(text, guide.faction, guide.race, guide.class)
			if ids == nil or #ids == 0 then
				addon.createPopupFrame(string.format(L.ERROR_QUEST_NOT_FOUND, text)) 
				return false
			elseif #ids > 1 then
				addon.createPopupFrame(string.format(L.ERROR_QUEST_NOT_UNIQUE, text) .. table.concat(ids, ", "))
				return false
			elseif popup.textboxObjective:GetText() ~= "" and tonumber(popup.textboxObjective:GetText()) == nil then
				addon.createPopupFrame(L.ERROR_NOT_A_NUMBER, L.QUEST_OBJECTIVE) 
				return false
			end
			id = ids[1]
		else
			if addon.questsDB[id] == nil then 
				addon.createPopupFrame(string.format(L.ERROR_QUEST_NOT_FOUND, id)) 
				return false
			end
			if text == "" then text = addon.getQuestNameById(id) end
		end
		local objective = ""
		if (popup.key == "C" or popup.key == "W") and tonumber(popup.textboxObjective:GetText()) ~= nil then
			objective = "," .. popup.textboxObjective:GetText()
		end
		local applies = ""
		if addon.questsDB[id].races ~= nil or addon.questsDB[id].faction ~= nil then
			local races = {}
			local qraces = addon.questsDB[id].races
			if qraces == nil then qraces = addon.racesPerFaction[addon.questsDB[id].faction] end
			if guide.race ~= nil then
				for i, race in ipairs(guide.race) do
					if addon.contains(qraces, race) then table.insert(races, race) end
				end
				if #races == #guide.race then races = nil end
			elseif guide.faction ~= nil then
				for i, race in ipairs(addon.racesPerFaction[guide.faction]) do
					if addon.contains(qraces, race) then table.insert(races, race) end
				end
				if #races == #addon.racesPerFaction[guide.faction] then races = nil end
			else
				races = addon.questsDB[id].races
			end
			if races ~= nil then 
				if #races == 0 then
					local racesLoc = {}
					for i, race in ipairs(qraces) do
						table.insert(racesLoc, addon.getLocalizedRace(race))
					end
					addon.createPopupFrame(L.ERROR_QUEST_RACE_ONLY .. table.concat(racesLoc, ", "))
					return false
				end
				applies = applies .. table.concat(races, ",")
			end
		end
		if addon.questsDB[id].classes ~= nil or addon.questsDB[id].faction ~= nil then
			local classes = {}
			local qclasses = addon.questsDB[id].classes
			if qclasses == nil then qclasses = addon.classesPerFaction[addon.questsDB[id].faction] end
			if guide.class ~= nil then
				for i, class in ipairs(guide.class) do
					if addon.contains(qclasses, class) then table.insert(classes, class) end
				end
				if #classes == #guide.class then classes = nil end
			elseif guide.faction ~= nil then
				for i, class in ipairs(addon.classesPerFaction[guide.faction]) do
					if addon.contains(qclasses, class) then table.insert(classes, class) end
				end
				if #classes == #addon.classesPerFaction[guide.faction] then classes = nil end
			else
				classes = addon.questsDB[id].classes
			end
			if classes ~= nil then
				if #classes == 0 then
					local classesLoc = {}
					for i, class in ipairs(addon.questsDB[id].classes) do
						table.insert(classesLoc, addon.getLocalizedClass(class))
					end
					addon.createPopupFrame(L.ERROR_QUEST_CLASS_ONLY .. table.concat(classesLoc, ", "))
					return false
				end
				applies = applies .. table.concat(classes, ",")
			end
		end
		if applies ~= "" then applies = "][A " .. applies end
		insertCode("QUEST", popup.key .. id .. objective .. text .. applies, element)
	end, true, 180)
	popup.checkboxes = {}
	for i, key in ipairs({"A", "C", "T", "S"}) do
		popup.checkboxes[key] = addon.addCheckbox(popup, L["QUEST_" .. key], L["QUEST_" .. key .. "_TOOLTIP"])
		popup.checkboxes[key]:SetPoint("TOPLEFT", -110 + i * 130, -10)
		popup.checkboxes[key]:SetScript("OnClick", function()
			for k, box in pairs(popup.checkboxes) do
				box:SetChecked(k == key)
			end
			popup.key = key
			if key == "C" then
				popup.textboxObjective:Show()
				popup.textboxObjective.text:Show()
			else
				popup.textboxObjective:Hide()
				popup.textboxObjective.text:Hide()
			end
		end)
	end
	popup.key = "A"
	if element ~= nil then popup.key = element.t:sub(1, 1) end
	popup.checkboxes[popup.key]:SetChecked(true)
	popup.textboxId = addon.addTextbox(popup, L.QUEST_ID, 100, L.QUEST_ID_TOOLTIP)
	popup.textboxId.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxId:SetPoint("TOPLEFT", 140, -50)
	popup.textQuestname = popup:CreateFontString(nil, popup, "GameFontNormal")
	popup.textQuestname:SetPoint("TOPLEFT", 260, -50)
	if element ~= nil then 
		popup.textboxId:SetText(element.questId) 
		popup.textQuestname:SetText(addon.getQuestNameById(element.questId))
	end
	popup.textboxId:SetScript("OnTextChanged", function(self) 
		popup.textQuestname:SetText(addon.getQuestNameById(tonumber(popup.textboxId:GetText())) or "")
	end)
	popup.textboxName = addon.addTextbox(popup, L.QUEST_NAME, 400, L.QUEST_NAME_TOOLTIP)
	popup.textboxName.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxName:SetPoint("TOPLEFT", 140, -80)
	if element ~= nil then if element.title == "" then popup.textboxName:SetText("-") else popup.textboxName:SetText(element.title) end end
	popup.textboxObjective = addon.addTextbox(popup, L.QUEST_OBJECTIVE, 100, L.QUEST_OBJECTIVE_TOOLTIP)
	popup.textboxObjective.text:SetPoint("TOPLEFT", 20, -110)
	popup.textboxObjective:SetPoint("TOPLEFT", 140, -110)
	if popup.key ~= "C" then
		popup.textboxObjective:Hide()
		popup.textboxObjective.text:Hide()
	end
	if element ~= nil then popup.textboxObjective:SetText(element.objective or "") end
	popup:Show()
end
addon.showEditPopupACCEPT = addon.showEditPopupQUEST
addon.showEditPopupCOMPLETE = addon.showEditPopupQUEST
addon.showEditPopupTURNIN = addon.showEditPopupQUEST
addon.showEditPopupSKIP = addon.showEditPopupQUEST

function addon.showEditPopupGOTO(typ, guide, step, element)
	local popup = addon.createPopupFrame(nil, function(popup)
		local x = tonumber(popup.textboxX:GetText())
		if x == nil then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, "X"))
			return false
		end
		local y = tonumber(popup.textboxY:GetText())
		if y == nil then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, "Y")) 
			return false
		end
		local zone = popup.textboxZone:GetText()
		if zone ~= "" and addon.mapIDs[zone] == nil then 
			local msg = string.format(L.ERROR_ZONE_NOT_FOUND, zone)
			local first = true
			for zone, id in pairs(addon.mapIDs) do
				if not first then msg = msg .. ", " end
				msg = msg .. zone
				first = false
			end
			addon.createPopupFrame(msg)
			return false
		end
		insertCode(typ, x .. "," .. y .. zone, element)
	end, true, 140)
	popup.textboxX = addon.addTextbox(popup, "X", 100)
	popup.textboxX.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxX:SetPoint("TOPLEFT", 120, -20)
	popup.textboxY = addon.addTextbox(popup, "Y", 100)
	popup.textboxY.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxY:SetPoint("TOPLEFT", 120, -50)
	popup.textboxZone = addon.addTextbox(popup, L.ZONE, 420, L.EDITOR_TOOLTIP_ZONE)
	popup.textboxZone.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxZone:SetPoint("TOPLEFT", 120, -80)

	if element ~= nil then	
		popup.textboxX:SetText(element.x)
		popup.textboxY:SetText(element.y)
		popup.textboxZone:SetText(addon.zoneNames[element.mapID] or "")
	else	
		local x, y = HBD:GetPlayerZonePosition()
		popup.textboxX:SetText(math.floor(x * 10000) / 100)
		popup.textboxY:SetText(math.floor(y * 10000) / 100)
		local mapID = HBD:GetPlayerZone()
		popup.textboxZone:SetText(addon.zoneNames[mapID] or mapID)
	end
	popup:Show()
end
addon.showEditPopupLOC = addon.showEditPopupGOTO

local function popupXPCodeValues(popup)
	local level = tonumber(popup.textboxLevel:GetText())
	local xp
	if popup.key ~= "" then
		xp = math.floor(tonumber(popup.textboxXP:GetText()))
	end
	return level, xp
end

function addon.showEditPopupXP(typ, guide, step, element)
	local popup = addon.createPopupFrame(nil, function(popup)
		local level, xp = popupXPCodeValues(popup)
		if level == nil then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.LEVEL))
			return false
		end
		if popup.key ~= "" and xp == nil then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L["XP_LEVEL" .. popup.key])) 
			return false
		end
		if popup.key == "%" and (xp < 0 or xp >= 100) then 
			addon.createPopupFrame(string.format(L.ERROR_OUT_OF_RANGE, L["XP_LEVEL" .. popup.key], 0, 100))
			return false
		end
		local text = popup.textboxText:GetText()
		if text ~= "" then text = " " .. text end
		insertCode("XP", level .. (popup.key or "") .. (xp or "") .. text, element)
	end, true, 170)
	popup.textboxLevel = addon.addTextbox(popup, L.LEVEL, 100)
	popup.textboxLevel.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxLevel:SetPoint("TOPLEFT", 140, -20)
	if element ~= nil then popup.textboxLevel:SetText(element.level) end
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
				popup.textboxXP.text:SetText(L["XP_LEVEL" .. key])
			end
		end)
	end
	popup.key = ""
	if element ~= nil and element.xp ~= nil then
		if element.xpType == "REMAINING" then
			popup.key = "-"
		elseif element.xpType == "PERCENTAGE" then
			popup.key = "."
		else
			popup.key = "+"
		end
	end
	popup.checkboxes[popup.key]:SetChecked(true)
	popup.textboxXP = addon.addTextbox(popup, "", 100)
	popup.textboxXP.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxXP:SetPoint("TOPLEFT", 140, -80)
	if element ~= nil and element.xp ~= nil then popup.textboxXP:SetText(element.xp) end
	if popup.key == "" then
		popup.textboxXP:Hide()
		popup.textboxXP.text:Hide()
	else
		popup.textboxXP.text:SetText(L["XP_LEVEL" .. popup.key])
	end
	popup.textboxText = addon.addTextbox(popup, L.XP_TEXT, 400)
	popup.textboxText.text:SetPoint("TOPLEFT", 20, -110)
	popup.textboxText:SetPoint("TOPLEFT", 140, -110)
	popup.textboxText:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32)
		local level, xp = popupXPCodeValues(popup)
		GameTooltip:SetText(L.XP_TEXT_TOOLTIP:format((level or "") .. (popup.key or "") .. (xp or "")))
		GameTooltip:Show() 
	end)
	popup.textboxText:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	if element ~= nil then popup.textboxText:SetText(element.text) end
	popup:Show()
end
addon.showEditPopupLEVEL = addon.showEditPopupXP

local function addEditButton(typ, prev, point, offsetX, offsetY)
	local button = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
	button.typ = typ
	button:SetWidth(30)
	button:SetHeight(24)
	if addon.icons[typ] ~= nil then
	    button.texture = button:CreateTexture(nil, "TOOLTIP")
	    button.texture:SetTexture(addon.icons[typ])
	    button.texture:SetAllPoints(button)
		button.texture:SetTexCoord(-0.5,1.5,-0.5,1.5)
    	button:SetNormalTexture(button.texture)
	else
		button:SetText(addon.codes[typ])
	end
	button:SetPoint("TOPLEFT", prev, point or "TOPRIGHT", offsetX or 0, offsetY or 0)
	button.tooltip = L["EDITOR_TOOLTIP_" .. typ]
	if button.tooltip ~= nil then
		button:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show() end)
		button:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	end
	button:SetScript("OnClick", function(self)
		local showEditPopup = addon["showEditPopup" .. self.typ]
		if showEditPopup ~= nil then
			local guide = parseGuide()
			if guide ~= nil then showEditPopup(self.typ, guide) end
		else
			insertCode(typ)
		end
	end)
	return button
end

function addon.showEditor()
	if not addon.dataLoaded then loadData() end

	if addon.isEditorShowing() then
		addon.editorFrame:Hide()
		return
	end
	
	InterfaceOptionsFrame:Hide() 

	if addon.editorFrame == nil then
		addon.editorFrame = addon.createPopupFrame(nil, nil, false, 800)
		addon.editorFrame:SetWidth(1400)
		addon.editorFrame:SetPoint(GuidelimeDataChar.editorFrameRelative, UIParent, GuidelimeDataChar.editorFrameRelative, GuidelimeDataChar.editorFrameX, GuidelimeDataChar.editorFrameY)
		addon.editorFrame:SetScript("OnHide", function(self)
			addon.updateStepsMapIcons()
			addon.popupFrame = nil
		end)
		addon.editorFrame:SetScript("OnMouseUp", function(this) 
			addon.editorFrame:StopMovingOrSizing()
			local _
			_, _, GuidelimeDataChar.editorFrameRelative, GuidelimeDataChar.editorFrameX, GuidelimeDataChar.editorFrameY = addon.editorFrame:GetPoint()
		end)
		addon.editorFrame.Hide_ = addon.editorFrame.Hide
		addon.editorFrame.Hide = function(self)
			while addon.editorFrame ~= addon.popupFrame do
				addon.popupFrame:Hide()
			end
			addon.editorFrame.Hide_(self)
		end
		
		addon.editorFrame.okBtn:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
		addon.editorFrame.okBtn:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight")
		addon.editorFrame.okBtn:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
		addon.editorFrame.okBtn:ClearAllPoints()
		addon.editorFrame.okBtn:SetPoint("TOPRIGHT", addon.editorFrame, -10, -10)
		addon.editorFrame.okBtn:SetSize(24, 24)
		addon.editorFrame.okBtn:SetText(nil)
		
		addon.editorFrame.title = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
		addon.editorFrame.title:SetText(GetAddOnMetadata(addonName, "title") .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version") .." - " .. L.EDITOR)
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
		
		local firstButton = addEditButton("NAME", prev, "TOPLEFT", 0, -30)
		prev = addEditButton("DETAILS", firstButton)
		prev = addEditButton("NEXT", prev)
		prev = addEditButton("GUIDE_APPLIES", prev)

		prev = addEditButton("QUEST", prev, "TOPRIGHT", 3)
		prev = addEditButton("GOTO", prev)
		prev = addEditButton("LOC", prev)
		prev = addEditButton("XP", prev)

		prev = addEditButton("HEARTH", prev, "TOPRIGHT", 3)
		prev = addEditButton("FLY", prev)
		prev = addEditButton("TRAIN", prev)
		prev = addEditButton("SET_HEARTH", prev)
		prev = addEditButton("GET_FLIGHT_POINT", prev)
		prev = addEditButton("VENDOR", prev)
		prev = addEditButton("REPAIR", prev)

		prev = addEditButton("APPLIES", prev, "TOPRIGHT", 3)
		prev = addEditButton("OPTIONAL", prev)
		prev = addEditButton("OPTIONAL_COMPLETE_WITH_NEXT", prev, "TOPRIGHT", 3)
		prev = firstButton

	    addon.editorFrame.scrollFrame = CreateFrame("ScrollFrame", nil, addon.editorFrame, "UIPanelScrollFrameTemplate")
	    addon.editorFrame.scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -40)
	    addon.editorFrame.scrollFrame:SetPoint("RIGHT", addon.editorFrame, "RIGHT", -300, 0)
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
		addon.editorFrame.textBox:SetPoint("TOPLEFT", content, "TOPLEFT", 30, 0)
		addon.editorFrame.textBox:SetTextColor(1,1,1,1)
		addon.editorFrame.textBox:SetWidth(addon.editorFrame:GetWidth() - 350)
		addon.editorFrame.textBox:SetScript("OnMouseUp", function(self, button)
			--if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:Hide() end
			--self.tooltip = nil
			--if element ~= nil then self.tooltip = element.t end
			if addon.isDoubleClick(self) then
				local guide = parseGuide()
				if addon.editorFrame.selectedElement ~= nil and addon["showEditPopup" .. addon.editorFrame.selectedElement.t] ~= nil then
					addon["showEditPopup" .. addon.editorFrame.selectedElement.t](addon.editorFrame.selectedElement.t, guide, addon.editorFrame.selectedStep, addon.editorFrame.selectedElement)
				end
			end
			--if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show() end
		end)
		--addon.editorFrame.textBox:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show() end end)
		--addon.editorFrame.textBox:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:Hide() end end)

		addon.editorFrame.linesBox = CreateFrame("EditBox", nil, content)
		addon.editorFrame.linesBox:SetEnabled(false)
		addon.editorFrame.linesBox:SetMultiLine(true)
		addon.editorFrame.linesBox:SetFontObject("GameFontNormal")
		addon.editorFrame.linesBox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
		addon.editorFrame.linesBox:SetTextColor(0.6,0.8,1,1)
		addon.editorFrame.linesBox:SetWidth(25)
		
		addon.editorFrame.questInfoText = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
		addon.editorFrame.questInfoText:SetText(L.QUEST_INFO)
		addon.editorFrame.questInfoText:SetPoint("TOPLEFT", addon.editorFrame.scrollFrame, "TOPRIGHT", 40, 0)
		prev = addon.editorFrame.questInfoText
		
		addon.editorFrame.questInfo = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
		addon.editorFrame.questInfo:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 20)
		addon.editorFrame.questInfo:SetTextColor(1,1,1,1)
		addon.editorFrame.questInfo:SetHeight(200)
		prev = addon.editorFrame.questInfo

		addon.editorFrame.gotoInfoText = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
		addon.editorFrame.gotoInfoText:SetText(L.GOTO_INFO)
		addon.editorFrame.gotoInfoText:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 20)
		prev = addon.editorFrame.gotoInfoText
		
		addon.editorFrame.gotoInfo = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
		addon.editorFrame.gotoInfo:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 20)
		addon.editorFrame.gotoInfo:SetTextColor(1,1,1,1)
		addon.editorFrame.gotoInfo:SetHeight(485)
		
		addon.editorFrame:SetScript("OnKeyDown", nil)
		addon.editorFrame.textBox:SetScript("OnKeyDown", function(self,key) 
			if key == "ESCAPE" then
				addon.editorFrame:Hide()
			elseif key == "ENTER" or key == "]" then
				C_Timer.After(0.01, parseGuide)
			end
		end)
		addon.editorFrame.textBox:SetScript("OnEnter", function(self) 
			--if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show() end 
			addon.editorFrame.textBox:SetEnabled(true)
		end)

		addon.editorFrame.saveBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
		addon.editorFrame.saveBtn:SetWidth(140)
		addon.editorFrame.saveBtn:SetHeight(30)
		addon.editorFrame.saveBtn:SetText(L.SAVE_GUIDE)
		addon.editorFrame.saveBtn:SetPoint("BOTTOMLEFT", addon.editorFrame, "BOTTOMLEFT", 20, 20)
		addon.editorFrame.saveBtn:SetScript("OnClick", function()
			local guide = parseGuide()
			if guide == nil then return end
			if guide.title == nil or guide.title == "" then 
				addon.createPopupFrame(L.ERROR_GUIDE_HAS_NO_NAME)
				return
			end
			local msg
			if GuidelimeData.customGuides == nil or GuidelimeData.customGuides[guide.name] == nil then
				msg = string.format(L.SAVE_MSG, guide.name)
			else
				msg = string.format(L.OVERWRITE_MSG, guide.name)
			end
			addon.createPopupFrame(msg, function()
				if GuidelimeData.customGuides == nil then GuidelimeData.customGuides = {} end
				GuidelimeData.customGuides[guide.name] = guide.text
				GuidelimeDataChar.currentGuide = {name = L.CUSTOM_GUIDES .. " " .. guide.name, skip = {}}
				ReloadUI()
			end, true):Show()
		end)

		addon.editorFrame.mapBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
		addon.editorFrame.mapBtn:SetWidth(140)
		addon.editorFrame.mapBtn:SetHeight(30)
		addon.editorFrame.mapBtn:SetText(L.SHOW_MAP)
		addon.editorFrame.mapBtn:SetPoint("TOPLEFT", addon.editorFrame.gotoInfo, "BOTTOMLEFT", 0, 20)
		addon.editorFrame.mapBtn:SetScript("OnClick", function()
			addon.editorFrame.textBox:SetEnabled(false)
			ToggleWorldMap()
			--addon.editorFrame:Hide(); 
		end)
	else
		addon.popupFrame = addon.editorFrame
	end
	addon.editorFrame:Show()
	parseGuide()
end

function addon.isEditorShowing()
	return addon.editorFrame ~= nil and addon.editorFrame:IsVisible()
end
