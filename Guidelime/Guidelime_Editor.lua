local addonName, addon = ...
local L = addon.L

local function setQuestInfo(id)
	if id == nil or addon.getQuestNameById(id) == nil then return end
	local text = L.NAME .. ": " .. addon.COLOR_WHITE .. addon.getQuestNameById(id) .. " (#" .. id .. ")|r\n"
	local quest = addon.questsDB[id]
	if quest ~= nil then
		if quest.name ~= addon.getQuestNameById(id) then text = text .. L.ENGLISH_NAME .. ": " .. addon.COLOR_WHITE .. quest.name .. "|r\n" end
		text = text .. L.CATEGORY .. ": " .. addon.COLOR_WHITE .. quest.sort .. "|r\n"
		text = text .. L.MINIMUM_LEVEL .. ": " .. addon.COLOR_WHITE .. quest.req .. "|r\n"
		text = text .. L.SUGGESTED_LEVEL .. ": " .. addon.COLOR_WHITE .. quest.level .. "|r\n"
		if quest.type ~= nul then text = text .. L.TYPE .. ": " .. addon.COLOR_WHITE .. quest.type .. "|r\n" end
		text = text .. L.OBJECTIVE .. ": " .. addon.COLOR_WHITE .. addon.getQuestObjective(id) .. "|r\n"
		if quest.series ~= nil or quest.next ~= nil or quest.prev ~= nil then
			text = text .. "\n" .. L.QUEST_CHAIN
			if quest.series ~= nil then text = text .. addon.COLOR_WHITE .. " (" .. L.PART .. " " .. quest.series .. ")|r" end
			text = text .. "\n"
			if quest.next ~= nil then text = text .. L.NEXT .. ": " .. addon.COLOR_WHITE .. addon.getQuestNameById(quest.next) .. " (#" .. quest.next .. ")|r\n" end
			if quest.prev ~= nil then text = text .. L.PREVIOUS .. ": " .. addon.COLOR_WHITE .. addon.getQuestNameById(quest.prev) .. " (#" .. quest.prev .. ")|r\n" end
		end
	end
	local first = true
	for _, key in ipairs({"ACCEPT", "COMPLETE", "TURNIN"}) do
		local objectives = addon.getQuestObjectives(id, key)
		if objectives ~= nil and #objectives > 0 then
			if first then text = text .. "\n" end
			first = false
			text = text .. L["QUEST_"..key.."_POS"] .. " "
			local count = 0
			for index, objective in ipairs(objectives) do
				if objective.type ~= nil then
					text = text .. "|T" .. addon.icons[objective.type] .. ":12|t"
				else
					text = text .. "|T" .. addon.icons[key] .. ":12|t"
				end
				text = text .. addon.COLOR_WHITE .. (objective.names[1] or "?")
				if #objective.names > 1 then
					text = text .. "("
					for i = 2, #objective.names do
						text = text .. ", " .. objective.names[i]
					end
					text = text .. ")"
				end
				local positions = addon.getQuestPositions(id, key, index)
				if positions ~= nil and #positions > 0 then
					text = text .. "|r " .. L.AT .. addon.COLOR_WHITE .. "\n"
					for i, pos in ipairs(positions) do
						pos.t = "LOC"
						pos.markerTyp = objective.type
						pos.questId = id
						pos.questType = key
						pos.objective = index
						addon.addMapIcon(pos, false, true)
						if i <= 10 then
							text = text .. addon.getMapMarkerText(pos) ..
								"(" .. pos.x .. "," .. pos.y .. " " .. pos.zone .. ") "
						elseif i == 11 then
							text = text .. (#positions - 10) .. " " .. L.MORE_POSITIONS
						end
					end
					count = count + #positions
				end
				text = text .. "|r\n"
			end
			if count > 1 then
				local pos = addon.getQuestPosition(id, key)
				if pos ~= nil then
					pos.t = "GOTO"
					pos.questId = id
					pos.questType = key
					addon.addMapIcon(pos, false, true)
					text = text .. "\n-> " .. addon.COLOR_WHITE .. addon.getMapMarkerText(pos) .. 
						"(" .. pos.x .. "," .. pos.y .. " " .. pos.zone .. ")|r\n"
				end
			end
		end
	end
	addon.editorFrame.questInfo:SetText(text)
end

local function setEditorMapIcons(guide)
	local highlight = true
	local prev
	if addon.editorFrame.gotoInfo ~= nil then
		for i, text in ipairs(addon.editorFrame.gotoInfo) do
			text:Hide()
		end
	end
	addon.editorFrame.gotoInfo = {}
	for i, step in ipairs(guide.steps) do
		for j, element in ipairs(step.elements) do
			if element.t == "LOC" or element.t == "GOTO" then
				addon.addMapIcon(element, addon.editorFrame.selection == element, true)
				local text = CreateFrame("EditBox", nil, addon.editorFrame.gotoInfoContent)
				text:SetEnabled(false)
				text:SetWidth(200)
				text:SetMultiLine(true)
				text:SetFontObject("GameFontNormal")
				text:SetTextColor(1,1,1,1)
				text:SetText(addon.COLOR_LIGHT_BLUE .. step.line .. "|r " .. element.x .. ", " .. element.y .. " " .. addon.getMapMarkerText(element))
				if prev == nil then
					text:SetPoint("TOPLEFT", addon.editorFrame.gotoInfoContent, "TOPLEFT", 0, 0)
				else
					text:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
				end
				text:SetScript("OnMouseUp", function(self, button)
					if addon.isDoubleClick(addon.editorFrame.gotoInfoContent) then
						addon["showEditPopup" .. element.t](element.t, guide, element)
					else
						addon.editorFrame.selection = element
						setEditorMapIcons(guide)
					end
				end)
				prev = text
				table.insert(addon.editorFrame.gotoInfo, text)
			end
		end
	end
end

local function getElementByPos(pos, guide)
	for i, step in ipairs(guide.steps) do
		for j, element in ipairs(step.elements) do
			--print(element.startPos .. "-" .. element.endPos)
			if element.startPos <= pos and element.endPos >= pos then
				return element
			end
		end
	end
end

local function parseGuide(strict)
	local guide = addon.parseGuide(addon.editorFrame.textBox:GetText():gsub("¦","|"), nil, strict or false)
	local l = 0
	local textWithLines = (addon.editorFrame.textBox:GetText():gsub("[¦|]",",") .. "\n"):gsub("([^\n\r]-)[\n\r]", function(t)
		l = l + 1 
		return l .. "|c00000000" .. t:sub(#("" .. l) + 1) .. "|r\n"
	end)
	addon.editorFrame.linesBox:SetText(textWithLines)
	
	if guide == nil then return end
	
	local pos = addon.editorFrame.textBox:GetCursorPosition() + 1
	addon.editorFrame.selection = getElementByPos(pos, guide)

	addon.removeMapIcons()
	addon.hideArrow()
	if addon.editorFrame.selection ~= nil then setQuestInfo(addon.editorFrame.selection.questId) end
	setEditorMapIcons(guide)
	addon.showMapIcons()
	return guide
end

local function insertCode(typ, text, replace, firstElement, lastElement)
	local oldText = addon.editorFrame.textBox:GetText()
	local startPos = addon.editorFrame.textBox:GetCursorPosition() + 1
	if lastElement == nil then lastElement = firstElement end
	local newCode = (text or "")
	if typ ~= nil then newCode = "[" .. addon.codes[typ] .. newCode .. "]" end
	local newText
	if firstElement ~= nil then
		startPos = firstElement.startPos
		newText = oldText:sub(1, startPos - 1) .. newCode .. oldText:sub(lastElement.endPos + 1)
		if addon.debugging then	print("LIME: replacing \"" .. oldText:sub(firstElement.startPos, lastElement.endPos) .. "\" with \"" .. newCode .. "\"") end
	else
		if replace then
			if text == nil or text == "" then 
				newCode = "" 
			else 
				replace = false 
			end
			local endPos
			local s, e = addon.editorFrame.textBox:GetText():find("%[" .. addon.codes[typ] .. ".-%]")
			if s ~= nil then
				replace = true
				startPos = s
				newText = oldText:sub(1, startPos - 1) .. newCode .. oldText:sub(e + 1)
			end
		end
		if not replace then
			if startPos == nil then startPos = #oldText end
			newText = oldText:sub(1, startPos - 1) .. newCode .. oldText:sub(startPos)
		end
	end
	addon.editorFrame.textBox:SetText(newText:gsub("|","¦"))
	addon.editorFrame.textBox:HighlightText(startPos - 1, startPos + #newCode - 1)
	addon.editorFrame.textBox:SetCursorPosition(startPos - 1)
	parseGuide()
end

local function createEditPopup(okFunc, height)
	local popup = addon.createPopupFrame(nil, okFunc, true, height)
	popup:SetScript("OnHide", function(self)
		if self:GetParent() ~= UIParent then addon.popupFrame = self:GetParent() else addon.popupFrame = nil end
		if addon.popupFrame == addon.editorFrame then addon.editorFrame.textBox:SetEnabled(true) end
	end)
	addon.editorFrame.textBox:SetEnabled(false)
	return popup
end

function addon.showEditPopupNAME(typ, guide)
	local popup = createEditPopup(function(popup)
		local min = tonumber(popup.textboxMinlevel:GetText())
		if min == nil and popup.textboxMinlevel:GetText() ~= "" then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.MINIMUM_LEVEL)):Show()
			return false
		end
		local max = tonumber(popup.textboxMaxlevel:GetText())
		if max == nil and popup.textboxMaxlevel:GetText() ~= "" then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.MAXIMUM_LEVEL)):Show() 
			return false
		end
		if popup.textboxName:GetText() == "" then
			addon.createPopupFrame(L.ERROR_GUIDE_HAS_NO_NAME):Show() 
			return false
		end
		insertCode(typ, (min or "") .. "-" .. (max or "") .. popup.textboxName:GetText(), true)
	end, 140)
	popup.textboxMinlevel = addon.addTextbox(popup, L.MINIMUM_LEVEL, 100)
	popup.textboxMinlevel.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxMinlevel:SetPoint("TOPLEFT", 140, -20)
	popup.textboxMaxlevel = addon.addTextbox(popup, L.MAXIMUM_LEVEL, 100)
	popup.textboxMaxlevel.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxMaxlevel:SetPoint("TOPLEFT", 140, -50)
	popup.textboxName = addon.addTextbox(popup, L.NAME, 400)
	popup.textboxName.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxName:SetPoint("TOPLEFT", 140, -80)
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
	local popup = createEditPopup(function(popup)
		if popup.textboxName:GetText() == "" then
			addon.createPopupFrame(L.ERROR_GUIDE_HAS_NO_NAME):Show() 
			return false
		end
		insertCode(typ, " " .. popup.textboxName:GetText(), true)
	end, 200)
	popup.textName = popup:CreateFontString(nil, popup, "GameFontNormal")
	popup.textName:SetText(L.DETAILS)
	popup.textName:SetPoint("TOPLEFT", 20, -20)
	popup.textboxName = CreateFrame("EditBox", nil, popup)
	popup.textboxName:SetFontObject("GameFontNormal")
	if guide.detailsRaw ~= nil then popup.textboxName:SetText(guide.detailsRaw) end
	popup.textboxName:SetPoint("TOPLEFT", 90, -20)
	popup.textboxName:SetMultiLine(true)
	popup.textboxName:SetWidth(450)
	popup.textboxName:SetTextColor(1,1,1,1)
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
		if faction == nil and guide.races ~= nil then faction = addon.races[guide.races[1]] end
		if faction == nil and guide.classes ~= nil then
			for i, class in ipairs(guide.classes) do
				if addon.classesWithFaction[class] ~= nil then faction = addon.classesWithFaction[class] end
			end
		end
		--if addon.debugging then print("LIME :", faction) end
		for key, box in pairs(popup.checkboxes) do
			if addon.isFaction(key) and faction ~= nil then
				box:SetEnabled(false)
			elseif addon.isRace(key) and 
				((faction ~= nil and faction ~= addon.races[key]) or 
				(guide.races ~= nil and not addon.contains(guide.races, key)) or
				(guide.races ~= nil and #guide.races == 1)) then
				box:SetEnabled(false)
			elseif addon.isClass(key) and 
				((faction ~= nil and addon.classesWithFaction[key] ~= nil and faction ~= addon.classesWithFaction[key]) or 
				(guide.classes ~= nil and not addon.contains(guide.classes, key)) or
				(guide.classes ~= nil and #guide.classes == 1)) then
				box:SetEnabled(false)
			end
		end
	end
	for _, faction in ipairs(addon.factions) do
		local box = popup.checkboxes[faction]
		if box:IsEnabled() then
			box.text:SetText(L[faction])
		else
			box.text:SetText(addon.COLOR_INACTIVE .. L[faction])
		end
	end
	for _, class in ipairs(addon.classes) do
		local box = popup.checkboxes[class]
		if box:IsEnabled() then
			box.text:SetText(addon.getLocalizedClass(class))
		else
			box.text:SetText(addon.COLOR_INACTIVE .. addon.getLocalizedClass(class))
		end
	end
	for _, race in ipairs(addon.races) do
		local box = popup.checkboxes[race]
		if box:IsEnabled() then
			box.text:SetText(addon.getLocalizedRace(race))
		else
			box.text:SetText(addon.COLOR_INACTIVE .. addon.getLocalizedRace(class))
		end
	end
end

function addon.showEditPopupAPPLIES(typ, guide, selection)
	local step 
	if selection ~= nil then step = selection.step end
	local popup = createEditPopup(function(popup)
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
		insertCode(typ, text, typ == "GUIDE_APPLIES", selection)
	end, 300)
	
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
			if guide.classes ~= nil and addon.contains(guide.classes, class) then
				popup.checkboxes[class]:SetChecked(true)
				if addon.classesWithFaction[class] ~= nil then popup.checkboxes[addon.classesWithFaction[class]]:SetChecked(true) end
			end
		elseif typ == "APPLIES" then
			if step ~= nil and step.classes ~= nil and addon.contains(step.classes, class) then
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
			if guide.races ~= nil and addon.contains(guide.races, race) then 
				popup.checkboxes[race]:SetChecked(true)
				popup.checkboxes[faction]:SetChecked(true)
			end
		elseif typ == "APPLIES" then
			if step ~= nil and step.races ~= nil and addon.contains(step.races, race) then 
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

function addon.showEditPopupQUEST(typ, guide, selection)
	local popup = createEditPopup(function(popup)
		local text = popup.textboxName:GetText()
		local id = tonumber(popup.textboxId:GetText())
		if id == nil and popup.textboxId:GetText() ~= "" then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.QUEST_ID)):Show()
			return false
		end
		if id == nil then
			local ids = addon.getPossibleQuestIdsByName(text, nil, guide.faction, guide.race, guide.class)
			if ids == nil or #ids == 0 then
				addon.createPopupFrame(string.format(L.ERROR_QUEST_NOT_FOUND, text)):Show()
				return false
			elseif #ids > 1 then
				addon.createPopupFrame(string.format(L.ERROR_QUEST_NOT_UNIQUE, text) .. table.concat(ids, ", ")):Show()
				return false
			elseif popup.textboxObjective:GetText() ~= "" and tonumber(popup.textboxObjective:GetText()) == nil then
				addon.createPopupFrame(L.ERROR_NOT_A_NUMBER, L.QUEST_OBJECTIVE):Show()
				return false
			end
			id = ids[1]
		else
			if addon.questsDB[id] == nil then 
				addon.createPopupFrame(string.format(L.ERROR_QUEST_NOT_FOUND, id)):Show() 
				return false
			end
			if text == "" then text = addon.getQuestNameById(id) end
		end
		local newCode, firstElement, lastElement = addon.addQuestTag(guide, selection, id, popup.key, tonumber(popup.textboxObjective:GetText()), text, popup.checkboxCoords:GetChecked())
		if newCode == nil then return false end
		insertCode(nil, newCode, false, firstElement, lastElement)
	end, 210)
	popup.checkboxes = {}
	for i, key in ipairs({"ACCEPT", "COMPLETE", "TURNIN", "SKIP"}) do
		popup.checkboxes[key] = addon.addCheckbox(popup, L["QUEST_" .. key], L["QUEST_" .. key .. "_TOOLTIP"])
		popup.checkboxes[key]:SetPoint("TOPLEFT", -110 + i * 130, -10)
		popup.checkboxes[key]:SetScript("OnClick", function()
			for k, box in pairs(popup.checkboxes) do
				box:SetChecked(k == key)
			end
			popup.key = key
			if key == "COMPLETE" then
				popup.textboxObjective:Show()
				popup.textboxObjective.text:Show()
			else
				popup.textboxObjective:Hide()
				popup.textboxObjective.text:Hide()
			end
		end)
	end
	popup.key = "ACCEPT"
	if selection ~= nil then popup.key = selection.t end
	popup.checkboxes[popup.key]:SetChecked(true)
	popup.textboxId = addon.addTextbox(popup, L.QUEST_ID, 370, L.QUEST_ID_TOOLTIP)
	popup.textboxId.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxId:SetPoint("TOPLEFT", 170, -50)
	popup.textQuestname = popup:CreateFontString(nil, popup, "GameFontNormal")
	popup.textQuestname:SetPoint("TOPLEFT", 280, -50)
	if selection ~= nil then 
		popup.textboxId:SetText(selection.questId) 
		popup.textQuestname:SetText(addon.getQuestNameById(selection.questId))
	end
	popup.textboxId:SetScript("OnTextChanged", function(self) 
		popup.textQuestname:SetText(addon.getQuestNameById(tonumber(popup.textboxId:GetText())) or "")
		addon.removeMapIcons()
		addon.hideArrow()
		setQuestInfo(tonumber(popup.textboxId:GetText()))
		addon.showMapIcons()
	end)
	popup.textboxName = addon.addTextbox(popup, L.QUEST_NAME, 370, L.QUEST_NAME_TOOLTIP)
	popup.textboxName.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxName:SetPoint("TOPLEFT", 170, -80)
	if selection ~= nil then 
		if selection.title == "" then 
			popup.textboxName:SetText("-") 
		else 
			popup.textboxName:SetText(selection.title or "") 
		end 
	end
	popup.textboxObjective = addon.addTextbox(popup, L.QUEST_OBJECTIVE, 370, L.QUEST_OBJECTIVE_TOOLTIP)
	popup.textboxObjective.text:SetPoint("TOPLEFT", 20, -110)
	popup.textboxObjective:SetPoint("TOPLEFT", 170, -110)
	if popup.key ~= "COMPLETE" then
		popup.textboxObjective:Hide()
		popup.textboxObjective.text:Hide()
	end
	if selection ~= nil then popup.textboxObjective:SetText(selection.objective or "") end
	popup.checkboxCoords = addon.addCheckbox(popup, L.QUEST_ADD_COORDINATES, L.QUEST_ADD_COORDINATES_TOOLTIP)
	popup.checkboxCoords:SetPoint("TOPLEFT", 20, -140)
	popup:Show()
end

function addon.showEditPopupGOTO(typ, guide, selection)
	if selection ~= nil and 
		#selection.step.elements > selection.index and 
		addon.getSuperCode(selection.step.elements[selection.index + 1].t) == "QUEST" then 
		addon.showEditPopupQUEST("QUEST", guide, selection.step.elements[selection.index + 1])
		return
	end
	local popup = createEditPopup(function(popup)
		local x = tonumber(popup.textboxX:GetText())
		if x == nil then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, "X")):Show()
			return false
		end
		local y = tonumber(popup.textboxY:GetText())
		if y == nil then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, "Y")):Show() 
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
			addon.createPopupFrame(msg):Show()
			return false
		end
		insertCode(typ, x .. "," .. y .. zone, false, selection)
	end, 140)
	popup.textboxX = addon.addTextbox(popup, "X", 100)
	popup.textboxX.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxX:SetPoint("TOPLEFT", 120, -20)
	popup.textboxY = addon.addTextbox(popup, "Y", 100)
	popup.textboxY.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxY:SetPoint("TOPLEFT", 120, -50)
	popup.textboxZone = addon.addTextbox(popup, L.ZONE, 420, L.EDITOR_TOOLTIP_ZONE)
	popup.textboxZone.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxZone:SetPoint("TOPLEFT", 120, -80)

	if selection ~= nil then	
		popup.textboxX:SetText(selection.x)
		popup.textboxY:SetText(selection.y)
		popup.textboxZone:SetText(addon.zoneNames[selection.mapID] or "")
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

function addon.showEditPopupXP(typ, guide, selection)
	local popup = createEditPopup(function(popup)
		local level, xp = popupXPCodeValues(popup)
		if level == nil then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.LEVEL)):Show()
			return false
		end
		if popup.key ~= "" and xp == nil then 
			addon.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L["XP_LEVEL" .. popup.key])):Show() 
			return false
		end
		if popup.key == "%" and (xp < 0 or xp >= 100) then 
			addon.createPopupFrame(string.format(L.ERROR_OUT_OF_RANGE, L["XP_LEVEL" .. popup.key], 0, 100)):Show()
			return false
		end
		local text = popup.textboxText:GetText()
		if text ~= "" then text = " " .. text end
		insertCode("XP", level .. (popup.key or "") .. (xp or "") .. text, false, selection)
	end, 170)
	popup.textboxLevel = addon.addTextbox(popup, L.LEVEL, 100)
	popup.textboxLevel.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxLevel:SetPoint("TOPLEFT", 140, -20)
	if selection ~= nil then popup.textboxLevel:SetText(selection.level) end
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
	if selection ~= nil and selection.xp ~= nil then
		if selection.xpType == "REMAINING" then
			popup.key = "-"
		elseif selection.xpType == "PERCENTAGE" then
			popup.key = "."
		else
			popup.key = "+"
		end
	end
	popup.checkboxes[popup.key]:SetChecked(true)
	popup.textboxXP = addon.addTextbox(popup, "", 100)
	popup.textboxXP.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxXP:SetPoint("TOPLEFT", 140, -80)
	if selection ~= nil and selection.xp ~= nil then popup.textboxXP:SetText(selection.xp) end
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
	if selection ~= nil then popup.textboxText:SetText(selection.text) end
	popup:Show()
end

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
			if guide ~= nil then 
				if addon.editorFrame.selection ~= nil and addon.getSuperCode(addon.editorFrame.selection.t) == self.typ then
					showEditPopup(addon.editorFrame.selection.t, guide, addon.editorFrame.selection)
				else
					showEditPopup(self.typ, guide) 
				end
			end
		else
			insertCode(typ)
		end
	end)
	return button
end

local function customGuideLoaded()
	if GuidelimeDataChar.currentGuide == nil or GuidelimeData.customGuides == nil then return end
	if not GuidelimeDataChar.currentGuide:sub(1, #L.CUSTOM_GUIDES) == L.CUSTOM_GUIDES then return end
	local name = GuidelimeDataChar.currentGuide:sub(#L.CUSTOM_GUIDES + 2)
	if GuidelimeData.customGuides[name] == nil then return end
	return name
end

function addon.showEditor()
	if not addon.dataLoaded then loadData() end

	if addon.isEditorShowing() then
		addon.editorFrame:Hide()
		return
	end
	
	InterfaceOptionsFrame:Hide() 

	if addon.editorFrame == nil then
		addon.editorFrame = addon.createPopupFrame(nil, nil, false, 700)
		addon.editorFrame:SetWidth(1220)
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
		addon.editorFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. (GuidelimeDataChar.currentGuide or "") .. "\n")
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
	    addon.editorFrame.scrollFrame:SetPoint("BOTTOMRIGHT", addon.editorFrame, "BOTTOMRIGHT", -340, 60)
	    local content = CreateFrame("Frame", nil, addon.editorFrame.scrollFrame) 
	    content:SetSize(1, 1) 
	    addon.editorFrame.scrollFrame:SetScrollChild(content)
		
		addon.editorFrame.textBox = CreateFrame("EditBox", nil, content)
		if GuidelimeDataChar.currentGuide ~= nil and addon.guides[GuidelimeDataChar.currentGuide] ~= nil then
			addon.editorFrame.textBox:SetText(addon.guides[GuidelimeDataChar.currentGuide].text:gsub("|","¦"))
		end
		addon.editorFrame.textBox:SetMultiLine(true)
		addon.editorFrame.textBox:SetFontObject("ChatFontNormal")
		addon.editorFrame.textBox:SetPoint("TOPLEFT", content, "TOPLEFT", 30, 0)
		addon.editorFrame.textBox:SetTextColor(1,1,1,1)
		addon.editorFrame.textBox:SetWidth(addon.editorFrame:GetWidth() - 390)
		addon.editorFrame.textBox:SetScript("OnMouseUp", function(self, button)
			if not addon.editorFrame.textBox:IsEnabled() then return end
			local lastSelectionPos
			if addon.editorFrame.selection ~= nil then lastSelectionPos = addon.editorFrame.selection.startPos end
			local guide = parseGuide()
			if guide ~= nil and addon.editorFrame.selection ~= nil and addon.isDoubleClick(self) and lastSelectionPos == addon.editorFrame.selection.startPos then
				local showPopup = addon["showEditPopup" .. addon.getSuperCode(addon.editorFrame.selection.t)]
				if showPopup ~= nil then
					showPopup(addon.editorFrame.selection.t, guide, addon.editorFrame.selection)
				elseif addon.editorFrame.selection.t == "TEXT" then
					local text = addon.editorFrame.selection.text
					local pos = addon.editorFrame.textBox:GetCursorPosition() - addon.editorFrame.selection.startPos + 2
					local wordEnd = text:find("[%s%p]", pos)
					if wordEnd == nil then wordEnd = #text else wordEnd = wordEnd - 1 end
					local wordStart = text:reverse():find("[%s%p]", #text + 1 - pos)
					if wordStart == nil then wordStart = 1 else wordStart = #text + 2 - wordStart end
					addon.editorFrame.textBox:HighlightText(addon.editorFrame.selection.startPos + wordStart - 2, addon.editorFrame.selection.startPos + wordEnd - 1)
				else
					addon.editorFrame.textBox:HighlightText(addon.editorFrame.selection.startPos - 1, addon.editorFrame.selection.endPos)
				end
			end
		end)
		addon.editorFrame:SetScript("OnKeyDown", nil)
		addon.editorFrame.textBox:SetScript("OnKeyDown", function(self,key) 
			if key == "ESCAPE" then
				addon.editorFrame:Hide()
			elseif key == "ENTER" or key == "UP" or key == "DOWN" or key == "LEFT" or key == "RIGHT" then
				C_Timer.After(0.01, parseGuide)
			end
		end)

		addon.editorFrame.linesBox = CreateFrame("EditBox", nil, content)
		addon.editorFrame.linesBox:SetEnabled(false)
		addon.editorFrame.linesBox:SetMultiLine(true)
		addon.editorFrame.linesBox:SetFontObject("ChatFontNormal")
		addon.editorFrame.linesBox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
		addon.editorFrame.linesBox:SetTextColor(0.6,0.8,1,1)
		addon.editorFrame.linesBox:SetWidth(addon.editorFrame:GetWidth() - 390)
		addon.editorFrame.linesBox:SetFrameLevel(0)
		
		addon.editorFrame.questInfoText = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
		addon.editorFrame.questInfoText:SetText(L.QUEST_INFO)
		addon.editorFrame.questInfoText:SetPoint("TOPLEFT", addon.editorFrame.scrollFrame, "TOPRIGHT", 40, 0)
		prev = addon.editorFrame.questInfoText
		
	    addon.editorFrame.questInfoScrollFrame = CreateFrame("ScrollFrame", nil, addon.editorFrame, "UIPanelScrollFrameTemplate")
	    addon.editorFrame.questInfoScrollFrame:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	    addon.editorFrame.questInfoScrollFrame:SetPoint("BOTTOMRIGHT", prev, "BOTTOMLEFT", 260, -170)
	    local content = CreateFrame("Frame", nil, addon.editorFrame.questInfoScrollFrame) 
	    content:SetSize(1, 1) 
	    addon.editorFrame.questInfoScrollFrame:SetScrollChild(content)
		addon.editorFrame.questInfo = CreateFrame("EditBox", nil, content)
		addon.editorFrame.questInfo:SetEnabled(false)
		addon.editorFrame.questInfo:SetWidth(240)
		addon.editorFrame.questInfo:SetMultiLine(true)
		addon.editorFrame.questInfo:SetFontObject("GameFontNormal")
		addon.editorFrame.questInfo:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
		prev = addon.editorFrame.questInfoScrollFrame

		addon.editorFrame.gotoInfoText = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
		addon.editorFrame.gotoInfoText:SetText(L.GOTO_INFO)
		addon.editorFrame.gotoInfoText:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
		prev = addon.editorFrame.gotoInfoText
		
	    addon.editorFrame.gotoInfoScrollFrame = CreateFrame("ScrollFrame", nil, addon.editorFrame, "UIPanelScrollFrameTemplate")
	    addon.editorFrame.gotoInfoScrollFrame:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	    addon.editorFrame.gotoInfoScrollFrame:SetPoint("RIGHT", prev, "LEFT", 260, 0)
	    addon.editorFrame.gotoInfoScrollFrame:SetPoint("BOTTOM", addon.editorFrame, "BOTTOMLEFT", 0, 100)
	    addon.editorFrame.gotoInfoContent = CreateFrame("Frame", nil, addon.editorFrame.gotoInfoScrollFrame) 
	    addon.editorFrame.gotoInfoContent:SetSize(1, 1) 
	    addon.editorFrame.gotoInfoScrollFrame:SetScrollChild(addon.editorFrame.gotoInfoContent)

		addon.editorFrame.mapBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
		addon.editorFrame.mapBtn:SetWidth(160)
		addon.editorFrame.mapBtn:SetHeight(30)
		addon.editorFrame.mapBtn:SetText(L.SHOW_MAP)
		addon.editorFrame.mapBtn:SetPoint("TOPLEFT", addon.editorFrame.gotoInfoScrollFrame, "BOTTOMLEFT", 0, -10)
		addon.editorFrame.mapBtn:SetScript("OnClick", function()
			ToggleWorldMap()
		end)

		addon.editorFrame.saveBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
		addon.editorFrame.saveBtn:SetWidth(160)
		addon.editorFrame.saveBtn:SetHeight(30)
		addon.editorFrame.saveBtn:SetText(L.SAVE_GUIDE)
		addon.editorFrame.saveBtn:SetPoint("BOTTOMLEFT", addon.editorFrame, "BOTTOMLEFT", 20, 20)
		addon.editorFrame.saveBtn:SetScript("OnClick", function()
			local guide = parseGuide(true)
			if guide == nil then return end
			local msg
			if GuidelimeData.customGuides == nil or GuidelimeData.customGuides[guide.name] == nil then
				msg = string.format(L.SAVE_MSG, guide.name)
			else
				msg = string.format(L.OVERWRITE_MSG, guide.name)
			end
			addon.createPopupFrame(msg, function()
				if GuidelimeData.customGuides == nil then GuidelimeData.customGuides = {} end
				GuidelimeData.customGuides[guide.name] = guide.text
				GuidelimeDataChar.currentGuide = L.CUSTOM_GUIDES .. " " .. guide.name
				ReloadUI()
			end, true):Show()
		end)

		addon.editorFrame.deleteBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
		addon.editorFrame.deleteBtn:SetWidth(160)
		addon.editorFrame.deleteBtn:SetHeight(30)
		addon.editorFrame.deleteBtn:SetText(L.DELETE_GUIDE)
		addon.editorFrame.deleteBtn:SetPoint("BOTTOMLEFT", addon.editorFrame, "BOTTOMLEFT", 200, 20)
		addon.editorFrame.deleteBtn:SetScript("OnClick", function()
			if customGuideLoaded() then
				addon.createPopupFrame(string.format(L.DELETE_MSG, customGuideLoaded()), function()
					GuidelimeData.customGuides[customGuideLoaded()] = nil
					ReloadUI()
				end, true):Show()
			end
		end)
		
		addon.editorFrame.discardBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
		addon.editorFrame.discardBtn:SetWidth(160)
		addon.editorFrame.discardBtn:SetHeight(30)
		addon.editorFrame.discardBtn:SetText(L.DISCARD_CHANGES)
		addon.editorFrame.discardBtn:SetPoint("BOTTOMLEFT", addon.editorFrame, "BOTTOMLEFT", 380, 20)
		addon.editorFrame.discardBtn:SetScript("OnClick", function()
			if GuidelimeDataChar.currentGuide ~= nil and addon.guides[GuidelimeDataChar.currentGuide] ~= nil then
				addon.editorFrame.textBox:SetText(addon.guides[GuidelimeDataChar.currentGuide].text:gsub("|","¦"))
			else
				addon.editorFrame.textBox:SetText("")
			end
			parseGuide()
		end)

		addon.editorFrame.addCoordinatesBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
		addon.editorFrame.addCoordinatesBtn:SetWidth(160)
		addon.editorFrame.addCoordinatesBtn:SetHeight(30)
		addon.editorFrame.addCoordinatesBtn:SetText(L.ADD_QUEST_COORDINATES)
		addon.editorFrame.addCoordinatesBtn:SetPoint("BOTTOMLEFT", addon.editorFrame, "BOTTOMLEFT", 560, 20)
		addon.editorFrame.addCoordinatesBtn:SetScript("OnClick", function()
			addon.createPopupFrame(L.ADD_QUEST_COORDINATES_MESSAGE, function()
			local guide = parseGuide()
			if guide ~= nil then 
				local text, count = addon.addQuestCoordinates(guide)
				if count > 0 then
					addon.editorFrame.textBox:SetText(text:gsub("|","¦"))
					parseGuide()
				end
				C_Timer.After(0.2, function()
					addon.createPopupFrame(string.format(L.ADDED_QUEST_COORDINATES_MESSAGE, count)):Show()
				end)
			end
			end, true):Show()
		end)

		addon.editorFrame.removeCoordinatesBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
		addon.editorFrame.removeCoordinatesBtn:SetWidth(160)
		addon.editorFrame.removeCoordinatesBtn:SetHeight(30)
		addon.editorFrame.removeCoordinatesBtn:SetText(L.REMOVE_ALL_COORDINATES)
		addon.editorFrame.removeCoordinatesBtn:SetPoint("BOTTOMLEFT", addon.editorFrame, "BOTTOMLEFT", 740, 20)
		addon.editorFrame.removeCoordinatesBtn:SetScript("OnClick", function()
			addon.createPopupFrame(L.REMOVE_ALL_COORDINATES_MESSAGE, function()
				local guide = parseGuide()
				if guide ~= nil then 
					local text, count = addon.removeAllCoordinates(guide)
					if count > 0 then
						addon.editorFrame.textBox:SetText(text:gsub("|","¦"))
						parseGuide()
					end
					C_Timer.After(0.2, function()
						addon.createPopupFrame(string.format(L.REMOVED_COORDINATES_MESSAGE, count)):Show()
					end)
				end
			end, true):Show()
		end)

		addon.editorFrame.importBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
		addon.editorFrame.importBtn:SetWidth(160)
		addon.editorFrame.importBtn:SetHeight(30)
		addon.editorFrame.importBtn:SetText(L.IMPORT_GUIDE)
		addon.editorFrame.importBtn:SetPoint("BOTTOMLEFT", addon.editorFrame, "BOTTOMLEFT", 920, 20)
		addon.editorFrame.importBtn:SetScript("OnClick", function()
			addon.createPopupFrame(L.IMPORT_GUIDE_MESSAGE, function()
				local text = addon.importPlainText(addon.editorFrame.textBox:GetText())
				addon.editorFrame.textBox:SetText(text:gsub("|","¦"))
				parseGuide()
			end, true):Show()
		end)

	else
		addon.popupFrame = addon.editorFrame
	end
	addon.editorFrame:Show()
	addon.editorFrame.deleteBtn:SetEnabled(customGuideLoaded())
	parseGuide()
end

function addon.isEditorShowing()
	return addon.editorFrame ~= nil and addon.editorFrame:IsVisible()
end
