local addonName, addon = ...
local L = addon.L

local HBD = LibStub("HereBeDragons-2.0")

addon.D = addon.D or {}; local D = addon.D     -- Data/Data
addon.DM = addon.DM or {}; local DM = addon.DM -- Data/MapDB
addon.PT = addon.PT or {}; local PT = addon.PT -- Data/PositionTools
addon.QT = addon.QT or {}; local QT = addon.QT -- Data/QuestTools
addon.ET = addon.ET or {}; local ET = addon.ET -- EditorTools
addon.F = addon.F or {}; local F = addon.F     -- Frames
addon.GP = addon.GP or {}; local GP = addon.GP -- GuideParser
addon.I = addon.I or {}; local I = addon.I     -- Import
addon.M = addon.M or {}; local M = addon.M     -- Map
addon.MW = addon.MW or {}; local MW = addon.MW -- MainWindow

addon.E = addon.E or {}; local E = addon.E     -- Editor

local function setQuestInfo(id)
	if id == nil or QT.getQuestNameById(id) == nil then return end
	local text = L.NAME .. ": " .. MW.COLOR_WHITE .. (QT.getQuestNameById(id) or "?") .. " (#" .. id .. ")|r\n"
	if QT.getQuestNameById(id) ~= nil then
		--if quest.name ~= QT.getQuestNameById(id) then text = text .. L.ENGLISH_NAME .. ": " .. MW.COLOR_WHITE .. quest.name .. "|r\n" end
		if QT.getQuestSort(id) ~= nil then text = text .. L.CATEGORY .. ": " .. MW.COLOR_WHITE .. QT.getQuestSort(id) .. "|r\n" end
		text = text .. L.MINIMUM_LEVEL .. ": " .. MW.COLOR_WHITE .. (QT.getQuestMinimumLevel(id) or "?") .. "|r\n"
		text = text .. L.SUGGESTED_LEVEL .. ": " .. MW.COLOR_WHITE .. (QT.getQuestLevel(id) or "?") .. "|r\n"
		if QT.getQuestType(id) ~= nil then text = text .. L.TYPE .. ": " .. MW.COLOR_WHITE .. QT.getQuestType(id) .. "|r\n" end
		text = text .. L.OBJECTIVE .. ": " .. MW.COLOR_WHITE .. (QT.getQuestObjective(id) or "?") .. "|r\n"
		if QT.getQuestClasses(id) ~= nil then
			text = text .. CLASS .. ": " .. MW.COLOR_WHITE 
			for i, class in ipairs(QT.getQuestClasses(id)) do
				if i > 1 then text = text .. ", " end
				text = text .. D.getLocalizedClass(class)
			end
			text = text .. "|r\n"
		end
		if QT.getQuestRaces(id) ~= nil then
			text = text .. RACE .. ": " .. MW.COLOR_WHITE 
			for i, race in ipairs(QT.getQuestRaces(id)) do
				if i > 1 then text = text .. ", " end
				text = text .. D.getLocalizedRace(race)
			end
			text = text .. "|r\n"
		end
		if QT.getQuestFaction(id) ~= nil then text = text .. FACTION .. ": " .. MW.COLOR_WHITE .. L[QT.getQuestFaction(id)] .. "|r\n" end
		
		if QT.getQuestSeries(id) ~= nil or QT.getQuestNext(id) ~= nil or QT.getQuestPrev(id) ~= nil then
			text = text .. "\n" .. L.QUEST_CHAIN
			if QT.getQuestSeries(id) ~= nil then text = text .. MW.COLOR_WHITE .. " (" .. L.PART .. " " .. QT.getQuestSeries(id) .. ")|r" end
			text = text .. "\n"
			if QT.getQuestNext(id) ~= nil then text = text .. L.NEXT .. ": " .. MW.COLOR_WHITE .. (QT.getQuestNameById(QT.getQuestNext(id)) or "?") .. " (#" .. QT.getQuestNext(id) .. ")|r\n" end
			if QT.getQuestPrev(id) ~= nil then text = text .. L.PREVIOUS .. ": " .. MW.COLOR_WHITE .. (QT.getQuestNameById(QT.getQuestPrev(id)) or "?") .. " (#" .. QT.getQuestPrev(id) .. ")|r\n" end
		end
	end
	local first = true
	for _, key in ipairs({"ACCEPT", "COMPLETE", "TURNIN"}) do
		local objectives = QT.getQuestObjectives(id, key)
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
				text = text .. MW.COLOR_WHITE .. (objective.names[1] or "?")
				if #objective.names > 1 then
					text = text .. "("
					for i = 2, #objective.names do
						text = text .. ", " .. objective.names[i]
					end
					text = text .. ")"
				end
				local positions = QT.getQuestPositions(id, key, index)
				if positions ~= nil and #positions > 0 then
					text = text .. "|r " .. L.AT .. MW.COLOR_WHITE .. "\n"
					for i, pos in ipairs(positions) do
						pos.t = "LOC"
						pos.markerTyp = objective.type
						pos.questId = id
						pos.questType = key
						pos.objective = index
						M.addMapIcon(pos, false, true)
						if i <= 10 then
							text = text .. M.getMapMarkerText(pos) ..
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
				local pos = PT.getQuestPosition(id, key)
				if pos ~= nil then
					pos.t = "GOTO"
					pos.questId = id
					pos.questType = key
					M.addMapIcon(pos, false, true)
					text = text .. "\n-> " .. MW.COLOR_WHITE .. M.getMapMarkerText(pos) .. 
						"(" .. pos.x .. "," .. pos.y .. " " .. pos.zone .. ")|r\n"
				end
			end
		end
	end
	E.editorFrame.questInfo:SetText(text)
end

local function setEditorMapIcons(guide)
	local highlight = true
	local prev
	if E.editorFrame.gotoInfo ~= nil then
		for i, text in ipairs(E.editorFrame.gotoInfo) do
			text:Hide()
		end
	end
	E.editorFrame.gotoInfo = {}
	for i, step in ipairs(guide.steps) do
		for j, element in ipairs(step.elements) do
			if element.t == "LOC" or element.t == "GOTO" then
				M.addMapIcon(element, E.editorFrame.selection == element, true)
				local text = CreateFrame("EditBox", nil, E.editorFrame.gotoInfoContent)
				text:SetEnabled(false)
				text:SetWidth(200)
				text:SetMultiLine(true)
				text:SetFontObject("GameFontNormal")
				text:SetTextColor(1,1,1,1)
				text:SetText(MW.COLOR_LIGHT_BLUE .. step.line .. "|r " .. element.x .. ", " .. element.y .. " " .. M.getMapMarkerText(element))
				if prev == nil then
					text:SetPoint("TOPLEFT", E.editorFrame.gotoInfoContent, "TOPLEFT", 0, 0)
				else
					text:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, 0)
				end
				text:SetScript("OnMouseUp", function(self, button)
					if F.isDoubleClick(E.editorFrame.gotoInfoContent) then
						E["showEditPopup" .. element.t](element.t, guide, element)
					else
						E.editorFrame.selection = element
						setEditorMapIcons(guide)
					end
				end)
				prev = text
				table.insert(E.editorFrame.gotoInfo, text)
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
	local guide = GP.parseGuide(E.editorFrame.textBox:GetText():gsub("¦","|"), nil, strict or false)
	local l = 0
	local textWithLines = (E.editorFrame.textBox:GetText():gsub("[¦|]",",") .. "\n"):gsub("([^\n\r]-)[\n\r]", function(t)
		l = l + 1 
		return l .. "|c00000000" .. t:sub(#("" .. l) + 1) .. "|r\n"
	end)
	E.editorFrame.linesBox:SetText(textWithLines)
	
	if guide == nil then return end
	
	local pos = E.editorFrame.textBox:GetCursorPosition() + 1
	E.editorFrame.selection = getElementByPos(pos, guide)

	M.removeMapIcons()
	M.hideArrow()
	if E.editorFrame.selection ~= nil then setQuestInfo(E.editorFrame.selection.questId) end
	setEditorMapIcons(guide)
	M.showMapIcons()
	return guide
end

local function insertCode(typ, text, replace, firstElement, lastElement)
	local oldText = E.editorFrame.textBox:GetText()
	local startPos = E.editorFrame.textBox:GetCursorPosition() + 1
	if lastElement == nil then lastElement = firstElement end
	local newCode = (text or "")
	if typ ~= nil then newCode = "[" .. GP.codes[typ] .. newCode .. "]" end
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
			local s, e = E.editorFrame.textBox:GetText():find("%[" .. GP.codes[typ] .. ".-%]")
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
	E.editorFrame.textBox:SetText(newText:gsub("|","¦"))
	E.editorFrame.textBox:HighlightText(startPos - 1, startPos + #newCode - 1)
	E.editorFrame.textBox:SetCursorPosition(startPos - 1)
	parseGuide()
end

local function createEditPopup(okFunc, height)
	local popup = F.createPopupFrame(nil, okFunc, true, height)
	popup:SetScript("OnHide", function(self)
		if self:GetParent() ~= UIParent then F.popupFrame = self:GetParent() else F.popupFrame = nil end
		if F.popupFrame == E.editorFrame then E.editorFrame.textBox:SetEnabled(true) end
	end)
	E.editorFrame.textBox:SetEnabled(false)
	return popup
end

function E.showEditPopupNAME(typ, guide)
	local popup = createEditPopup(function(popup)
		local min = tonumber(popup.textboxMinlevel:GetText())
		if min == nil and popup.textboxMinlevel:GetText() ~= "" then 
			F.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.MINIMUM_LEVEL)):Show()
			return false
		end
		local max = tonumber(popup.textboxMaxlevel:GetText())
		if max == nil and popup.textboxMaxlevel:GetText() ~= "" then 
			F.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.MAXIMUM_LEVEL)):Show() 
			return false
		end
		if popup.textboxName:GetText() == "" then
			F.createPopupFrame(L.ERROR_GUIDE_HAS_NO_NAME):Show() 
			return false
		end
		insertCode(typ, (min or "") .. "-" .. (max or "") .. popup.textboxName:GetText(), true)
	end, 140)
	popup.textboxMinlevel = F.addTextbox(popup, L.MINIMUM_LEVEL, 100)
	popup.textboxMinlevel.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxMinlevel:SetPoint("TOPLEFT", 140, -20)
	popup.textboxMaxlevel = F.addTextbox(popup, L.MAXIMUM_LEVEL, 100)
	popup.textboxMaxlevel.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxMaxlevel:SetPoint("TOPLEFT", 140, -50)
	popup.textboxName = F.addTextbox(popup, L.NAME, 400)
	popup.textboxName.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxName:SetPoint("TOPLEFT", 140, -80)
	if typ == "NAME" then
		if guide.title ~= nil then popup.textboxName:SetText(guide.title) end
		if guide.minLevel ~= nil then popup.textboxMinlevel:SetText(guide.minLevel) end
		if guide.maxLevel ~= nil then popup.textboxMaxlevel:SetText(guide.maxLevel) end
	elseif typ == "NEXT" and guide.next ~= nil then
		guide.next[1]:gsub("(%d*)%s*-%s*(%d*)%s*(.*)", function (minLevel, maxLevel, title)
			if title ~= nil then popup.textboxName:SetText(title) end
			if minLevel ~= nil then popup.textboxMinlevel:SetText(minLevel) end
			if maxLevel ~= nil then popup.textboxMaxlevel:SetText(maxLevel) end
		end, 1)
	end
	popup:Show()
end
E.showEditPopupNEXT = E.showEditPopupNAME

function E.showEditPopupDETAILS(typ, guide)
	local popup = createEditPopup(function(popup)
		if popup.textboxName:GetText() == "" then
			F.createPopupFrame(L.ERROR_GUIDE_HAS_NO_NAME):Show() 
			return false
		end
		insertCode(typ, " " .. popup.textboxName:GetText(), true)
	end, 200)
	popup.textName = popup:CreateFontString(nil, "ARTWORK", "GameFontNormal")
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

function E.popupAppliesSetEnabledCheckboxes(popup, typ, guide)
	local faction
	local factionLocked = false
	for i, class in ipairs(D.classes) do
		if popup.checkboxes[class]:GetChecked() then
			if D.classesWithFaction[class] ~= nil then faction = D.classesWithFaction[class]; break end
		end
	end
	if faction == nil then
		for race, f in pairs(D.races) do
			if popup.checkboxes[race]:GetChecked() then	faction = f; break end
		end
	end
	if faction == nil then
		for i, f in ipairs(D.factions) do
			if popup.checkboxes[f]:GetChecked() then faction = f; break	end
		end
	else
		factionLocked = true
	end		
	for key, box in pairs(popup.checkboxes) do
		if D.isFaction(key) then
			box:SetEnabled(not factionLocked and (faction == nil or faction == key))
		elseif D.isRace(key) then
			box:SetEnabled(faction == nil or faction == D.races[key])
		else
			box:SetEnabled(faction == nil or D.classesWithFaction[key] == nil or faction == D.classesWithFaction[key])
		end
	end
	if typ == "APPLIES" then
		-- also respect restrictions from GUIDE_APPLIES
		local faction = guide.faction
		if faction == nil and guide.races ~= nil then faction = D.races[guide.races[1]] end
		if faction == nil and guide.classes ~= nil then
			for i, class in ipairs(guide.classes) do
				if D.classesWithFaction[class] ~= nil then faction = D.classesWithFaction[class] end
			end
		end
		--if addon.debugging then print("LIME :", faction) end
		for key, box in pairs(popup.checkboxes) do
			if D.isFaction(key) and faction ~= nil then
				box:SetEnabled(false)
				box:SetChecked(faction == key)
			elseif D.isRace(key) and 
				((faction ~= nil and faction ~= D.races[key]) or 
				(guide.races ~= nil and not D.contains(guide.races, key)) or
				(guide.races ~= nil and #guide.races == 1)) then
				box:SetEnabled(false)
				box:SetChecked(guide.races ~= nil and D.contains(guide.races, key))
			elseif D.isClass(key) and 
				((faction ~= nil and D.classesWithFaction[key] ~= nil and faction ~= D.classesWithFaction[key]) or 
				(guide.classes ~= nil and not D.contains(guide.classes, key)) or
				(guide.classes ~= nil and #guide.classes == 1)) then
				box:SetEnabled(false)
				box:SetChecked(guide.classes ~= nil and D.contains(guide.classes, key))
			end
		end
	end
	for _, faction in ipairs(D.factions) do
		local box = popup.checkboxes[faction]
		if box:IsEnabled() then
			box.text:SetText(L[faction])
		else
			box.text:SetText(MW.COLOR_INACTIVE .. L[faction])
		end
	end
	for _, class in ipairs(D.classes) do
		local box = popup.checkboxes[class]
		if box:IsEnabled() then
			box.text:SetText(D.getLocalizedClass(class))
		else
			box.text:SetText(MW.COLOR_INACTIVE .. D.getLocalizedClass(class))
		end
	end
	for _, race in ipairs(D.races) do
		local box = popup.checkboxes[race]
		if box:IsEnabled() then
			box.text:SetText(D.getLocalizedRace(race))
		else
			box.text:SetText(MW.COLOR_INACTIVE .. D.getLocalizedRace(class))
		end
	end
end

function E.showEditPopupAPPLIES(typ, guide, selection)
	local step 
	if selection ~= nil then step = selection.step end
	local popup = createEditPopup(function(popup)
		local text = ""
		local factionLocked = false
		for i, class in ipairs(D.classes) do
			if popup.checkboxes[class]:GetChecked() then
				if text ~= "" then text = text .. "," end
				text = text .. class
				if D.classesWithFaction[class] ~= nil then factionLocked = true end
			end
		end
		for race, faction in pairs(D.races) do
			if popup.checkboxes[race]:GetChecked() then
				if text ~= "" then text = text .. "," end
				text = text .. race
				factionLocked = true
			end
		end
		if not factionLocked then
			for i, faction in ipairs(D.factions) do
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
	for i, faction in ipairs(D.factions) do
		popup.checkboxes[faction] = F.addCheckbox(popup, L[faction])
		left[faction] = 20 + i * 160
		popup.checkboxes[faction]:SetPoint("TOPLEFT", left[faction], -20)
		if typ == "GUIDE_APPLIES" then
			if guide.faction ~= nil and guide.faction == faction then popup.checkboxes[faction]:SetChecked(true) end
		elseif typ == "APPLIES" then
			if step ~= nil and step.faction ~= nil and step.faction == faction then popup.checkboxes[faction]:SetChecked(true) end
		end
		popup.checkboxes[faction]:SetScript("OnClick", function()
			E.popupAppliesSetEnabledCheckboxes(popup, typ, guide)
		end)
	end
	for i, class in ipairs(D.classes) do
		popup.checkboxes[class] = F.addCheckbox(popup, D.getLocalizedClass(class))
		popup.checkboxes[class]:SetPoint("TOPLEFT", 20, 5 - i * 25)
		if typ == "GUIDE_APPLIES" then
			if guide.classes ~= nil and D.contains(guide.classes, class) then
				popup.checkboxes[class]:SetChecked(true)
				if D.classesWithFaction[class] ~= nil then popup.checkboxes[D.classesWithFaction[class]]:SetChecked(true) end
			end
		elseif typ == "APPLIES" then
			if step ~= nil and step.classes ~= nil and D.contains(step.classes, class) then
				popup.checkboxes[class]:SetChecked(true)
				if D.classesWithFaction[class] ~= nil then popup.checkboxes[D.classesWithFaction[class]]:SetChecked(true) end
			end
		end
		popup.checkboxes[class]:SetScript("OnClick", function()
			if D.classesWithFaction[class] ~= nil and popup.checkboxes[class]:GetChecked() then popup.checkboxes[D.classesWithFaction[class]]:SetChecked(true) end
			E.popupAppliesSetEnabledCheckboxes(popup, typ, guide)
		end)
	end
	local count = {}
	for race, faction in pairs(D.races) do
		popup.checkboxes[race] = F.addCheckbox(popup, D.getLocalizedRace(race))
		if count[faction] == nil then count[faction] = 1 else count[faction] = count[faction] + 1 end
		popup.checkboxes[race]:SetPoint("TOPLEFT", left[faction], -50 - count[faction] * 30)
		if typ == "GUIDE_APPLIES" then
			if guide.races ~= nil and D.contains(guide.races, race) then 
				popup.checkboxes[race]:SetChecked(true)
				popup.checkboxes[faction]:SetChecked(true)
			end
		elseif typ == "APPLIES" then
			if step ~= nil and step.races ~= nil and D.contains(step.races, race) then 
				popup.checkboxes[race]:SetChecked(true)
				popup.checkboxes[faction]:SetChecked(true)
			end
		end
		popup.checkboxes[race]:SetScript("OnClick", function()
			if popup.checkboxes[race]:GetChecked() then popup.checkboxes[faction]:SetChecked(true) end
			E.popupAppliesSetEnabledCheckboxes(popup, typ, guide)
		end)
	end
	E.popupAppliesSetEnabledCheckboxes(popup, typ, guide)		
	popup:Show()
end
E.showEditPopupGUIDE_APPLIES = E.showEditPopupAPPLIES

function E.showEditPopupQUEST(typ, guide, selection)
	local popup = createEditPopup(function(popup)
		local text = popup.textboxName:GetText()
		local id = tonumber(popup.textboxId:GetText())
		if id == nil and popup.textboxId:GetText() ~= "" then 
			F.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.QUEST_ID)):Show()
			return false
		end
		if id == nil then
			local ids = QT.getPossibleQuestIdsByName(text, nil, guide.faction, guide.race, guide.class)
			if ids == nil or #ids == 0 then
				F.createPopupFrame(string.format(L.ERROR_QUEST_NOT_FOUND, text)):Show()
				return false
			elseif #ids > 1 then
				F.createPopupFrame(string.format(L.ERROR_QUEST_NOT_UNIQUE, text) .. table.concat(ids, ", ")):Show()
				return false
			elseif popup.textboxObjective:GetText() ~= "" and tonumber(popup.textboxObjective:GetText()) == nil then
				F.createPopupFrame(L.ERROR_NOT_A_NUMBER, L.QUEST_OBJECTIVE):Show()
				return false
			end
			id = ids[1]
		else
			if QT.getQuestNameById(id) == nil then 
				F.createPopupFrame(string.format(L.ERROR_QUEST_NOT_FOUND, id)):Show() 
				return false
			end
			if text == "" then text = QT.getQuestNameById(id) end
		end
		local newCode, firstElement, lastElement = ET.addQuestTag(guide, selection, id, popup.key, tonumber(popup.textboxObjective:GetText()), text, popup.checkboxCoords:GetChecked())
		if newCode == nil then return false end
		insertCode(nil, newCode, false, firstElement, lastElement)
	end, 210)
	popup.checkboxes = {}
	for i, key in ipairs({"ACCEPT", "COMPLETE", "TURNIN", "SKIP"}) do
		popup.checkboxes[key] = F.addCheckbox(popup, L["QUEST_" .. key], L["QUEST_" .. key .. "_TOOLTIP"])
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
	popup.textboxId = F.addTextbox(popup, L.QUEST_ID, 370, L.QUEST_ID_TOOLTIP)
	popup.textboxId.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxId:SetPoint("TOPLEFT", 170, -50)
	popup.textQuestname = popup:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	popup.textQuestname:SetPoint("TOPLEFT", 280, -50)
	if selection ~= nil then 
		popup.textboxId:SetText(selection.questId) 
		popup.textQuestname:SetText(QT.getQuestNameById(selection.questId))
	end
	popup.textboxId:SetScript("OnTextChanged", function(self) 
		popup.textQuestname:SetText(QT.getQuestNameById(tonumber(popup.textboxId:GetText())) or "")
		M.removeMapIcons()
		M.hideArrow()
		setQuestInfo(tonumber(popup.textboxId:GetText()))
		M.showMapIcons()
	end)
	popup.textboxName = F.addTextbox(popup, L.QUEST_NAME, 370, L.QUEST_NAME_TOOLTIP)
	popup.textboxName.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxName:SetPoint("TOPLEFT", 170, -80)
	if selection ~= nil then 
		if selection.title == "" then 
			popup.textboxName:SetText("-") 
		else 
			popup.textboxName:SetText(selection.title or "") 
		end 
	end
	popup.textboxObjective = F.addTextbox(popup, L.QUEST_OBJECTIVE, 370, L.QUEST_OBJECTIVE_TOOLTIP)
	popup.textboxObjective.text:SetPoint("TOPLEFT", 20, -110)
	popup.textboxObjective:SetPoint("TOPLEFT", 170, -110)
	if popup.key ~= "COMPLETE" then
		popup.textboxObjective:Hide()
		popup.textboxObjective.text:Hide()
	end
	if selection ~= nil then popup.textboxObjective:SetText(selection.objective or "") end
	popup.checkboxCoords = F.addCheckbox(popup, L.QUEST_ADD_COORDINATES, L.QUEST_ADD_COORDINATES_TOOLTIP)
	popup.checkboxCoords:SetPoint("TOPLEFT", 20, -140)
	popup:Show()
end

function E.showEditPopupGOTO(typ, guide, selection)
	if selection ~= nil and 
		#selection.step.elements > selection.index and 
		GP.getSuperCode(selection.step.elements[selection.index + 1].t) == "QUEST" then 
		E.showEditPopupQUEST("QUEST", guide, selection.step.elements[selection.index + 1])
		return
	end
	local popup = createEditPopup(function(popup)
		local x = tonumber(popup.textboxX:GetText())
		if x == nil then 
			F.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, "X")):Show()
			return false
		end
		local y = tonumber(popup.textboxY:GetText())
		if y == nil then 
			F.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, "Y")):Show() 
			return false
		end
		local zone = popup.textboxZone:GetText()
		if zone ~= "" and DM.mapIDs[zone] == nil then 
			local msg = string.format(L.ERROR_ZONE_NOT_FOUND, zone)
			local first = true
			for zone, id in pairs(DM.mapIDs) do
				if not first then msg = msg .. ", " end
				msg = msg .. zone
				first = false
			end
			F.createPopupFrame(msg):Show()
			return false
		end
		insertCode(typ, x .. "," .. y .. zone, false, selection)
	end, 140)
	popup.textboxX = F.addTextbox(popup, "X", 100)
	popup.textboxX.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxX:SetPoint("TOPLEFT", 120, -20)
	popup.textboxY = F.addTextbox(popup, "Y", 100)
	popup.textboxY.text:SetPoint("TOPLEFT", 20, -50)
	popup.textboxY:SetPoint("TOPLEFT", 120, -50)
	popup.textboxZone = F.addTextbox(popup, L.ZONE, 420, L.EDITOR_TOOLTIP_ZONE)
	popup.textboxZone.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxZone:SetPoint("TOPLEFT", 120, -80)

	if selection ~= nil then	
		popup.textboxX:SetText(selection.x)
		popup.textboxY:SetText(selection.y)
		popup.textboxZone:SetText(DM.zoneNames[selection.mapID] or "")
	else	
		local x, y = HBD:GetPlayerZonePosition()
		popup.textboxX:SetText(math.floor(x * 10000) / 100)
		popup.textboxY:SetText(math.floor(y * 10000) / 100)
		local mapID = HBD:GetPlayerZone()
		popup.textboxZone:SetText(DM.zoneNames[mapID] or mapID)
	end
	popup:Show()
end
E.showEditPopupLOC = E.showEditPopupGOTO

local function popupXPCodeValues(popup)
	local level = tonumber(popup.textboxLevel:GetText())
	local xp
	if popup.key ~= "" then
		xp = math.floor(tonumber(popup.textboxXP:GetText()))
	end
	return level, xp
end

function E.showEditPopupXP(typ, guide, selection)
	local popup = createEditPopup(function(popup)
		local level, xp = popupXPCodeValues(popup)
		if level == nil then 
			F.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L.LEVEL)):Show()
			return false
		end
		if popup.key ~= "" and xp == nil then 
			F.createPopupFrame(string.format(L.ERROR_NOT_A_NUMBER, L["XP_LEVEL" .. popup.key])):Show() 
			return false
		end
		if popup.key == "%" and (xp < 0 or xp >= 100) then 
			F.createPopupFrame(string.format(L.ERROR_OUT_OF_RANGE, L["XP_LEVEL" .. popup.key], 0, 100)):Show()
			return false
		end
		local text = popup.textboxText:GetText()
		if text ~= "" then text = " " .. text end
		insertCode("XP", level .. (popup.key or "") .. (xp or "") .. text, false, selection)
	end, 170)
	popup.textboxLevel = F.addTextbox(popup, L.LEVEL, 100)
	popup.textboxLevel.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxLevel:SetPoint("TOPLEFT", 140, -20)
	if selection ~= nil then popup.textboxLevel:SetText(selection.level) end
	popup.checkboxes = {}
	for i, key in ipairs({"", "+", "-", "%"}) do
		popup.checkboxes[key] = F.addCheckbox(popup, L["XP_LEVEL" .. key], L["XP_LEVEL" .. key .. "_TOOLTIP"])
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
	popup.textboxXP = F.addTextbox(popup, "", 100)
	popup.textboxXP.text:SetPoint("TOPLEFT", 20, -80)
	popup.textboxXP:SetPoint("TOPLEFT", 140, -80)
	if selection ~= nil and selection.xp ~= nil then popup.textboxXP:SetText(selection.xp) end
	if popup.key == "" then
		popup.textboxXP:Hide()
		popup.textboxXP.text:Hide()
	else
		popup.textboxXP.text:SetText(L["XP_LEVEL" .. popup.key])
	end
	popup.textboxText = F.addTextbox(popup, L.XP_TEXT, 400)
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
	local button = CreateFrame("BUTTON", nil, E.editorFrame, "UIPanelButtonTemplate")
	button.typ = typ
	button:SetWidth(30)
	button:SetHeight(24)
	if addon.icons[typ] ~= nil then
	    button.texture = button:CreateTexture(nil, "ARTWORK")
	    button.texture:SetTexture(addon.icons[typ])
	    button.texture:SetAllPoints(button)
		button.texture:SetTexCoord(-0.5,1.5,-0.5,1.5)
    	button:SetNormalTexture(button.texture)
	else
		button:SetText(GP.codes[typ])
	end
	button:SetPoint("TOPLEFT", prev, point or "TOPRIGHT", offsetX or 0, offsetY or 0)
	button.tooltip = L["EDITOR_TOOLTIP_" .. typ]
	if button.tooltip ~= nil then
		button:SetScript("OnEnter", function(self) GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show() end)
		button:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	end
	button:SetScript("OnClick", function(self)
		local showEditPopup = E["showEditPopup" .. self.typ]
		if showEditPopup ~= nil then
			local guide = parseGuide()
			if guide ~= nil then 
				if E.editorFrame.selection ~= nil and GP.getSuperCode(E.editorFrame.selection.t) == self.typ then
					showEditPopup(E.editorFrame.selection.t, guide, E.editorFrame.selection)
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

function E.showEditor()
	if not addon.dataLoaded then loadData() end

	if E.isEditorShowing() then
		E.editorFrame:Hide()
		return
	end
	
	InterfaceOptionsFrame:Hide() 

	if E.editorFrame == nil then
		E.editorFrame = F.createPopupFrame(nil, nil, false, 700)
		E.editorFrame:SetWidth(1220)
		E.editorFrame:SetPoint(GuidelimeDataChar.editorFrameRelative, UIParent, GuidelimeDataChar.editorFrameRelative, GuidelimeDataChar.editorFrameX, GuidelimeDataChar.editorFrameY)
		E.editorFrame:SetScript("OnHide", function(self)
			M.updateStepsMapIcons()
			F.popupFrame = nil
		end)
		E.editorFrame:SetScript("OnMouseUp", function(this) 
			E.editorFrame:StopMovingOrSizing()
			local _
			_, _, GuidelimeDataChar.editorFrameRelative, GuidelimeDataChar.editorFrameX, GuidelimeDataChar.editorFrameY = E.editorFrame:GetPoint()
		end)
		E.editorFrame.Hide_ = E.editorFrame.Hide
		E.editorFrame.Hide = function(self)
			while E.editorFrame ~= F.popupFrame do
				F.popupFrame:Hide()
			end
			E.editorFrame.Hide_(self)
		end
		
		E.editorFrame.okBtn:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
		E.editorFrame.okBtn:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight")
		E.editorFrame.okBtn:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
		E.editorFrame.okBtn:ClearAllPoints()
		E.editorFrame.okBtn:SetPoint("TOPRIGHT", E.editorFrame, -10, -10)
		E.editorFrame.okBtn:SetSize(24, 24)
		E.editorFrame.okBtn:SetText(nil)
		
		E.editorFrame.title = E.editorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		E.editorFrame.title:SetText(GetAddOnMetadata(addonName, "title") .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version") .." - " .. L.EDITOR)
		E.editorFrame.title:SetPoint("TOPLEFT", 20, -20)
		E.editorFrame.title:SetFontObject("GameFontNormalLarge")
		local prev = E.editorFrame.title
		
		E.editorFrame.text1 = E.editorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		E.editorFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. (GuidelimeDataChar.currentGuide or "") .. "\n")
		E.editorFrame.text1:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -30)
		prev = E.editorFrame.text1
		
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

	    E.editorFrame.scrollFrame = CreateFrame("ScrollFrame", nil, E.editorFrame, "UIPanelScrollFrameTemplate")
	    E.editorFrame.scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -40)
	    E.editorFrame.scrollFrame:SetPoint("BOTTOMRIGHT", E.editorFrame, "BOTTOMRIGHT", -340, 60)
	    local content = CreateFrame("Frame", nil, E.editorFrame.scrollFrame) 
	    content:SetSize(1, 1) 
	    E.editorFrame.scrollFrame:SetScrollChild(content)
		
		E.editorFrame.textBox = CreateFrame("EditBox", nil, content)
		if GuidelimeDataChar.currentGuide ~= nil and addon.guides[GuidelimeDataChar.currentGuide] ~= nil then
			E.editorFrame.textBox:SetText(addon.guides[GuidelimeDataChar.currentGuide].text:gsub("|","¦"))
		end
		E.editorFrame.textBox:SetMultiLine(true)
		E.editorFrame.textBox:SetFontObject("ChatFontNormal")
		E.editorFrame.textBox:SetPoint("TOPLEFT", content, "TOPLEFT", 30, 0)
		E.editorFrame.textBox:SetTextColor(1,1,1,1)
		E.editorFrame.textBox:SetWidth(E.editorFrame:GetWidth() - 390)
		E.editorFrame.textBox:SetScript("OnMouseUp", function(self, button)
			if not E.editorFrame.textBox:IsEnabled() then return end
			local lastSelectionPos
			if E.editorFrame.selection ~= nil then lastSelectionPos = E.editorFrame.selection.startPos end
			local guide = parseGuide()
			if guide ~= nil and E.editorFrame.selection ~= nil and F.isDoubleClick(self) and lastSelectionPos == E.editorFrame.selection.startPos then
				local showPopup = E["showEditPopup" .. GP.getSuperCode(E.editorFrame.selection.t)]
				if showPopup ~= nil then
					showPopup(E.editorFrame.selection.t, guide, E.editorFrame.selection)
				elseif E.editorFrame.selection.t == "TEXT" then
					local text = E.editorFrame.selection.text
					local pos = E.editorFrame.textBox:GetCursorPosition() - E.editorFrame.selection.startPos + 2
					local wordEnd = text:find("[%s%p]", pos)
					if wordEnd == nil then wordEnd = #text else wordEnd = wordEnd - 1 end
					local wordStart = text:reverse():find("[%s%p]", #text + 1 - pos)
					if wordStart == nil then wordStart = 1 else wordStart = #text + 2 - wordStart end
					E.editorFrame.textBox:HighlightText(E.editorFrame.selection.startPos + wordStart - 2, E.editorFrame.selection.startPos + wordEnd - 1)
				else
					E.editorFrame.textBox:HighlightText(E.editorFrame.selection.startPos - 1, E.editorFrame.selection.endPos)
				end
			end
		end)
		E.editorFrame:SetScript("OnKeyDown", nil)
		E.editorFrame.textBox:SetScript("OnKeyDown", function(self,key) 
			if key == "ESCAPE" then
				E.editorFrame:Hide()
			elseif key == "ENTER" or key == "UP" or key == "DOWN" or key == "LEFT" or key == "RIGHT" then
				C_Timer.After(0.01, parseGuide)
			end
		end)

		E.editorFrame.linesBox = CreateFrame("EditBox", nil, content)
		E.editorFrame.linesBox:SetEnabled(false)
		E.editorFrame.linesBox:SetMultiLine(true)
		E.editorFrame.linesBox:SetFontObject("ChatFontNormal")
		E.editorFrame.linesBox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
		E.editorFrame.linesBox:SetTextColor(0.6,0.8,1,1)
		E.editorFrame.linesBox:SetWidth(E.editorFrame:GetWidth() - 390)
		E.editorFrame.linesBox:SetFrameLevel(0)
		
		E.editorFrame.questInfoText = E.editorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		E.editorFrame.questInfoText:SetText(L.QUEST_INFO)
		E.editorFrame.questInfoText:SetPoint("TOPLEFT", E.editorFrame.scrollFrame, "TOPRIGHT", 40, 0)
		prev = E.editorFrame.questInfoText
		
	    E.editorFrame.questInfoScrollFrame = CreateFrame("ScrollFrame", nil, E.editorFrame, "UIPanelScrollFrameTemplate")
	    E.editorFrame.questInfoScrollFrame:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	    E.editorFrame.questInfoScrollFrame:SetPoint("BOTTOMRIGHT", prev, "BOTTOMLEFT", 260, -170)
	    local content = CreateFrame("Frame", nil, E.editorFrame.questInfoScrollFrame) 
	    content:SetSize(1, 1) 
	    E.editorFrame.questInfoScrollFrame:SetScrollChild(content)
		E.editorFrame.questInfo = CreateFrame("EditBox", nil, content)
		E.editorFrame.questInfo:SetEnabled(false)
		E.editorFrame.questInfo:SetWidth(240)
		E.editorFrame.questInfo:SetMultiLine(true)
		E.editorFrame.questInfo:SetFontObject("GameFontNormal")
		E.editorFrame.questInfo:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)
		prev = E.editorFrame.questInfoScrollFrame

		E.editorFrame.gotoInfoText = E.editorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		E.editorFrame.gotoInfoText:SetText(L.GOTO_INFO)
		E.editorFrame.gotoInfoText:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -20)
		prev = E.editorFrame.gotoInfoText
		
	    E.editorFrame.gotoInfoScrollFrame = CreateFrame("ScrollFrame", nil, E.editorFrame, "UIPanelScrollFrameTemplate")
	    E.editorFrame.gotoInfoScrollFrame:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -10)
	    E.editorFrame.gotoInfoScrollFrame:SetPoint("RIGHT", prev, "LEFT", 260, 0)
	    E.editorFrame.gotoInfoScrollFrame:SetPoint("BOTTOM", E.editorFrame, "BOTTOMLEFT", 0, 100)
	    E.editorFrame.gotoInfoContent = CreateFrame("Frame", nil, E.editorFrame.gotoInfoScrollFrame) 
	    E.editorFrame.gotoInfoContent:SetSize(1, 1) 
	    E.editorFrame.gotoInfoScrollFrame:SetScrollChild(E.editorFrame.gotoInfoContent)

		E.editorFrame.mapBtn = CreateFrame("BUTTON", nil, E.editorFrame, "UIPanelButtonTemplate")
		E.editorFrame.mapBtn:SetWidth(160)
		E.editorFrame.mapBtn:SetHeight(30)
		E.editorFrame.mapBtn:SetText(L.SHOW_MAP)
		E.editorFrame.mapBtn:SetPoint("TOPLEFT", E.editorFrame.gotoInfoScrollFrame, "BOTTOMLEFT", 0, -10)
		E.editorFrame.mapBtn:SetScript("OnClick", function()
			ToggleWorldMap()
		end)

		E.editorFrame.saveBtn = CreateFrame("BUTTON", nil, E.editorFrame, "UIPanelButtonTemplate")
		E.editorFrame.saveBtn:SetWidth(160)
		E.editorFrame.saveBtn:SetHeight(30)
		E.editorFrame.saveBtn:SetText(L.SAVE_GUIDE)
		E.editorFrame.saveBtn:SetPoint("BOTTOMLEFT", E.editorFrame, "BOTTOMLEFT", 20, 20)
		E.editorFrame.saveBtn:SetScript("OnClick", function()
			local guide = parseGuide(true)
			if guide == nil then return end
			local msg
			if GuidelimeData.customGuides == nil or GuidelimeData.customGuides[guide.name] == nil then
				msg = string.format(L.SAVE_MSG, guide.name)
			else
				msg = string.format(L.OVERWRITE_MSG, guide.name)
			end
			F.createPopupFrame(msg, function()
				if GuidelimeData.customGuides == nil then GuidelimeData.customGuides = {} end
				GuidelimeData.customGuides[guide.name] = guide.text
				GuidelimeDataChar.currentGuide = L.CUSTOM_GUIDES .. " " .. guide.name
				ReloadUI()
			end, true):Show()
		end)

		E.editorFrame.deleteBtn = CreateFrame("BUTTON", nil, E.editorFrame, "UIPanelButtonTemplate")
		E.editorFrame.deleteBtn:SetWidth(160)
		E.editorFrame.deleteBtn:SetHeight(30)
		E.editorFrame.deleteBtn:SetText(L.DELETE_GUIDE)
		E.editorFrame.deleteBtn:SetPoint("BOTTOMLEFT", E.editorFrame, "BOTTOMLEFT", 200, 20)
		E.editorFrame.deleteBtn:SetScript("OnClick", function()
			if customGuideLoaded() then
				F.createPopupFrame(string.format(L.DELETE_MSG, customGuideLoaded()), function()
					GuidelimeData.customGuides[customGuideLoaded()] = nil
					ReloadUI()
				end, true):Show()
			end
		end)
		
		E.editorFrame.discardBtn = CreateFrame("BUTTON", nil, E.editorFrame, "UIPanelButtonTemplate")
		E.editorFrame.discardBtn:SetWidth(160)
		E.editorFrame.discardBtn:SetHeight(30)
		E.editorFrame.discardBtn:SetText(L.DISCARD_CHANGES)
		E.editorFrame.discardBtn:SetPoint("BOTTOMLEFT", E.editorFrame, "BOTTOMLEFT", 380, 20)
		E.editorFrame.discardBtn:SetScript("OnClick", function()
			if GuidelimeDataChar.currentGuide ~= nil and addon.guides[GuidelimeDataChar.currentGuide] ~= nil then
				E.editorFrame.textBox:SetText(addon.guides[GuidelimeDataChar.currentGuide].text:gsub("|","¦"))
			else
				E.editorFrame.textBox:SetText("")
			end
			parseGuide()
		end)

		E.editorFrame.addCoordinatesBtn = CreateFrame("BUTTON", nil, E.editorFrame, "UIPanelButtonTemplate")
		E.editorFrame.addCoordinatesBtn:SetWidth(160)
		E.editorFrame.addCoordinatesBtn:SetHeight(30)
		E.editorFrame.addCoordinatesBtn:SetText(L.ADD_QUEST_COORDINATES)
		E.editorFrame.addCoordinatesBtn:SetPoint("BOTTOMLEFT", E.editorFrame, "BOTTOMLEFT", 560, 20)
		E.editorFrame.addCoordinatesBtn:SetScript("OnClick", function()
			F.createPopupFrame(L.ADD_QUEST_COORDINATES_MESSAGE, function()
			local guide = parseGuide()
			if guide ~= nil then 
				local text, count = ET.addQuestCoordinates(guide)
				if count > 0 then
					E.editorFrame.textBox:SetText(text:gsub("|","¦"))
					parseGuide()
				end
				C_Timer.After(0.2, function()
					F.createPopupFrame(string.format(L.ADDED_QUEST_COORDINATES_MESSAGE, count)):Show()
				end)
			end
			end, true):Show()
		end)

		E.editorFrame.removeCoordinatesBtn = CreateFrame("BUTTON", nil, E.editorFrame, "UIPanelButtonTemplate")
		E.editorFrame.removeCoordinatesBtn:SetWidth(160)
		E.editorFrame.removeCoordinatesBtn:SetHeight(30)
		E.editorFrame.removeCoordinatesBtn:SetText(L.REMOVE_ALL_COORDINATES)
		E.editorFrame.removeCoordinatesBtn:SetPoint("BOTTOMLEFT", E.editorFrame, "BOTTOMLEFT", 740, 20)
		E.editorFrame.removeCoordinatesBtn:SetScript("OnClick", function()
			F.createPopupFrame(L.REMOVE_ALL_COORDINATES_MESSAGE, function()
				local guide = parseGuide()
				if guide ~= nil then 
					local text, count = ET.removeAllCoordinates(guide)
					if count > 0 then
						E.editorFrame.textBox:SetText(text:gsub("|","¦"))
						parseGuide()
					end
					C_Timer.After(0.2, function()
						F.createPopupFrame(string.format(L.REMOVED_COORDINATES_MESSAGE, count)):Show()
					end)
				end
			end, true):Show()
		end)

		E.editorFrame.importBtn = CreateFrame("BUTTON", nil, E.editorFrame, "UIPanelButtonTemplate")
		E.editorFrame.importBtn:SetWidth(160)
		E.editorFrame.importBtn:SetHeight(30)
		E.editorFrame.importBtn:SetText(L.IMPORT_GUIDE)
		E.editorFrame.importBtn:SetPoint("BOTTOMLEFT", E.editorFrame, "BOTTOMLEFT", 920, 20)
		E.editorFrame.importBtn:SetScript("OnClick", function()
			F.createPopupFrame(L.IMPORT_GUIDE_MESSAGE, function()
				local text = I.importPlainText(E.editorFrame.textBox:GetText())
				E.editorFrame.textBox:SetText(text:gsub("|","¦"))
				parseGuide()
			end, true):Show()
		end)

	else
		F.popupFrame = E.editorFrame
	end
	E.editorFrame:Show()
	E.editorFrame.deleteBtn:SetEnabled(customGuideLoaded())
	parseGuide()
end

function E.isEditorShowing()
	return E.editorFrame ~= nil and E.editorFrame:IsVisible()
end
