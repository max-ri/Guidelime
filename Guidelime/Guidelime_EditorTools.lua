local addonName, addon = ...
local L = addon.L

local function adjustPositions(guide, i, j, diff)
	for k = i, #guide.steps do
		local step = guide.steps[k]
		for l, element in ipairs(step.elements) do
			if k > i or l > j then
				element.startPos = element.startPos + diff
				element.endPos = element.endPos + diff
			end
		end
	end
end

function addon.removeAllCoordinates(guide)
	local text = guide.text
	local count = 0
	for i, step in ipairs(guide.steps) do
		for j, element in ipairs(step.elements) do
			if element.t == "GOTO" then
				count = count + 1
				local oldTag = text:sub(element.startPos, element.endPos)
				if addon.debugging then print("LIME: removing", oldTag) end
				text = text:sub(1, element.startPos - 1) .. text:sub(element.endPos + 1)
				adjustPositions(guide, i, j, -#oldTag)
			end
		end
	end
	return text, count
end

function addon.addQuestCoordinates(guide)
	local text = guide.text
	local count = 0
	for i, step in ipairs(guide.steps) do
		for j, element in ipairs(step.elements) do
			if addon.getSuperCode(element.t) == "QUEST" then
				local tag, first, last, coords = addon.addQuestTag(guide, element, element.questId, element.t, element.objective, element.title, true)
				if tag == nil then
					if addon.debugging then print("LIME: error reading quest tag \"" .. text:sub(element.startPos, element.endPos) .. "\"") end
				else
					local oldTag = text:sub(first.startPos, last.endPos)
					if coords ~= "" and tag ~= oldTag then
						count = count + 1
						if addon.debugging then print("LIME: replacing", oldTag, "with", tag) end
						text = text:sub(1, first.startPos - 1) .. tag .. text:sub(last.endPos + 1)
						adjustPositions(guide, i, j, #tag - #oldTag)
					end
				end
			end
		end
	end
	return text, count
end

function addon.addQuestTag(guide, selection, id, key, objectiveIndex, text, addCoordinates)
	if addon.questsDB[id] == nil then return end
	local firstElement, lastElement = selection, selection
	local objective = ""
	if key == "COMPLETE" and objectiveIndex ~= nil then
		objective = "," .. objectiveIndex
	end
	local coords = ""
	if addCoordinates then
		local pos = addon.getQuestPosition(id, key, objectiveIndex)
		if pos ~= nil then
			if pos.radius == 0 then
				coords = "[G" .. pos.x .. "," .. pos.y .. pos.zone .. "]"
			else
				coords = "[G" .. pos.x .. "," .. pos.y .. "," .. (pos.radius + addon.DEFAULT_GOTO_RADIUS) .. pos.zone .. "]"
			end
			if firstElement ~= nil and firstElement.index > 1 and firstElement.step.elements[firstElement.index - 1].t == "GOTO" then 
				firstElement = firstElement.step.elements[firstElement.index - 1] 
			elseif lastElement ~= nil and #lastElement.step.elements > lastElement.index and lastElement.step.elements[lastElement.index + 1].t == "GOTO" then 
				lastElement = lastElement.step.elements[lastElement.index + 1] 
			end
		end
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
				addon.createPopupFrame(L.ERROR_QUEST_RACE_ONLY .. table.concat(racesLoc, ", ") .. " (#" .. id .. ")"):Show()
				return
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
				addon.createPopupFrame(L.ERROR_QUEST_CLASS_ONLY .. table.concat(classesLoc, ", ")):Show()
				return
			end
			if applies ~= "" then applies = applies .. "," end
			applies = applies .. table.concat(classes, ",")
		end
	end
	if applies ~= "" then 
		applies = "[A " .. applies .. "]"
		if lastElement ~= nil and #lastElement.step.elements > lastElement.index and lastElement.step.elements[lastElement.index + 1].t == "APPLIES" then 
			lastElement = lastElement.step.elements[lastElement.index + 1] 
		end
	end
	text = text or ""
	if text ~= "" then text = " " .. text end
	return coords .. "[" .. addon.codes["QUEST"] .. key:sub(1, 1) .. id .. objective .. text  .. "]" .. applies, firstElement, lastElement, coords
end
