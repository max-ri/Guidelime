local addonName, addon = ...
local L = addon.L

--[[
codes:
 - N Name and level range of the guide [N(min)-(max)(name)]
 - NX Name and level range of the next guide proposed after finishing this [NX(min)-(max)(name)]
 - D details of the guide [D(details)]
 - GA guide applies to [GA(race),(class),(faction),...]
 - Q [QA/T/C/S(id)[,objective](title)] quest accept/turnin/complete/skip    -- QW is deprecated; replaced by [QC...][O]
 - L [L(x),(y)[zone] ] loc
 - G [G(x),(y)[zone] ] goto
 - XP [XP (level)[.(percentage)/+(points)/-(points remaining)] experience
 - H hearth
 - F fly
 - T train
 - S set hearth
 - P get flight point
 - V vendor
 - R repair
 - A applies to [A(race),(class),(faction),...]
 - O optional step
 - C complete this step along with the next one
]]

addon.codes = {
	NAME = "N",
	NEXT = "NX",
	DETAILS = "D",
	DOWNLOAD = "DL",
	GUIDE_APPLIES = "GA",
	APPLIES = "A",
	OPTIONAL = "O",
	OPTIONAL_COMPLETE_WITH_NEXT = "OC",
	QUEST = "Q",
		ACCEPT = "QA",
		COMPLETE = "QC",
		TURNIN = "QT",
		SKIP = "QS",
	GOTO = "G",
	LOC = "L",
	XP = "XP",
	HEARTH = "H",
	FLY = "F",
	TRAIN = "T",
	SET_HEARTH = "S",
	GET_FLIGHT_POINT = "P",
	VENDOR = "V",
	REPAIR = "R",
	AUTO_ADD_COORDINATES_GOTO = "GG",
	AUTO_ADD_COORDINATES_LOC = "GL",
--deprecated
	COMPLETE_WITH_NEXT = "C", -- same as OC
	PICKUP = "QP", -- same as QA
	WORK = "QW", -- same as QC but optional
}

addon.COLOR_INACTIVE = "|cFF666666"

addon.codesReverse = {}
for k, v in pairs(addon.codes) do addon.codesReverse[v] = k end

function addon.getSuperCode(code)
	if code == "ACCEPT" then return "QUEST" end
	if code == "TURNIN" then return "QUEST" end
	if code == "COMPLETE" then return "QUEST" end
	if code == "SKIP" then return "QUEST" end
	if code == "PICKUP" then return "QUEST" end
	if code == "WORK" then return "QUEST" end
	return code
end

function addon.parseGuide(guide, group, strict, nameOnly)
	if strict == nil then strict = true end
	if type(guide) == "string" then
		guide = {text = guide}
	elseif #guide > 0 then
		guide = {steps = guide}
	end
	if guide.text ~= nil then
		local pos = 1
		guide.lines = 1
		guide.steps = {}
		guide.next = {}
		guide.autoAddCoordinatesGOTO = true
		guide.autoAddCoordinatesLOC = true
		local t = guide.text:gsub("\\\\[\n\r]", "\\\\"):gsub("([^\n\r]-)[\n\r]", function(c)
			if c ~= nil and c ~= "" then
				local step = {text = c, startPos = pos, line = guide.lines, guide = guide}
				table.insert(guide.steps, step)
				pos = pos + #c + 1
				if addon.debugging and guide.text:sub(step.startPos, step.startPos + #c - 1) ~= c then
					print("LIME: parsing guide \"" .. guide.text:sub(step.startPos, step.startPos + #c - 1) .. "\" should be \"" .. c .. "\" at " .. step.startPos .. "-" .. (step.startPos + #c - 1))
				end
			else
				pos = pos + 1
			end
			guide.lines = guide.lines + 1
			return ""
		end)
		if t ~= nil and t ~= "" then
			table.insert(guide.steps, {text = t, startPos = pos, line = guide.lines, guide = guide})
			guide.lines = guide.lines + 1
		end
	end
	guide.currentZone = nil
	for i, step in ipairs(guide.steps) do
		if not addon.parseLine(step, guide, strict, nameOnly) then return end
	end
	if group ~= nil and group:sub(1,10) == "Guidelime_" then
		guide.group = group:sub(11)
	elseif group ~= nil then
		guide.group = group
	end
	guide.name = guide.title or ""
	if guide.minLevel ~= nil or guide.maxLevel ~= nil then
		guide.name = " " .. guide.name
		if guide.maxLevel ~= nil then guide.name = guide.maxLevel .. guide.name end
		guide.name = "-" .. guide.name
		if guide.minLevel ~= nil then guide.name = guide.minLevel .. guide.name end
	end
	if guide.group ~= nil then guide.name = guide.group .. " " .. guide.name end
	
	if strict and guide.title == nil or guide.title == "" then 
		addon.createPopupFrame(L.ERROR_GUIDE_HAS_NO_NAME):Show()
	else	
		return guide
	end
end

local function textFormatting(text, color)
	local url
	local formatted = text:gsub("(https://[%w%./#%-%?=#]*)", function(u) url = u; return "|cFFAAAAAA" .. u .. "|r" end)
		:gsub("(http://[%w%./#%-%?=#]*)", function(u) url = u; return "|cFFAAAAAA" .. u .. "|r" end)
		:gsub("(www%.[%w%./#%-%?=#]*)", function(u) if url == nil then url = u end; return "|cFFAAAAAA" .. u .. "|r" end)
		:gsub("%*([^\n\r]-)%*", (color or "|cFFFFD100") .. "%1|r")
		:gsub("%*%*","%*")
	local formattedInactive = formatted:gsub("|r", addon.COLOR_INACTIVE)
	return formatted, formattedInactive, url, formatted:gsub("%s", "") == ""
end

function addon.parseLine(step, guide, strict, nameOnly)
	if step.text == nil then return end
	step.elements = {}
	local lastAutoStep
	local previousAutoStep
	local autoStepOptional
	local err = false
	local pos = step.startPos
	step.text = step.text:gsub("\\\\"," \n"):gsub("%-%-.*", "")
	local t = step.text:gsub("(.-)%[(.-)%]", function(text, code)
		if text ~= "" then
			local element = {}
			element.t = "TEXT"
			element.text, element.textInactive, element.url, element.empty = textFormatting(text, addon.COLOR_WHITE)
			if element.text ~= nil then
				element.startPos = pos
				pos = pos + #text
				element.endPos = pos - 1
				element.index = #step.elements + 1
				element.step = step
				table.insert(step.elements, element)
			end
		end
		local element = {}
		element.startPos = pos
		pos = pos + #code + 2
		element.endPos = pos - 1
		element.index = #step.elements + 1
		element.step = step
		element.t = addon.codesReverse[code:sub(1, 2)]
		if element.t == nil then element.t = addon.codesReverse[code:sub(1, 1)] end
		if element.t == nil then 
			addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
			err = true
			return ""
		end		
		table.insert(step.elements, element)
		local tag = code:sub(#addon.codes[element.t] + 1) --:gsub("^%s*","")
		
		if element.t == "NEXT" then
			local _, c = tag:gsub("%s*(%d*%.?%d*)%s*%-?%s*(%d*%.?%d*)%s*(.*)", function (minLevel, maxLevel, title)
				if guide.next == nil then guide.next = {} end
				if minLevel ~= "" or maxLevel ~= "" then
					title = " " .. title
					if maxLevel ~= "" then title = maxLevel .. title end
					title = "-" .. title
					if minLevel ~= "" then title = minLevel .. title end
				end
				table.insert(guide.next, title)
			end, 1)
			if c ~= 1 then
				addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "NAME" then
			local rest, c = tag:gsub("%s*(%d*%.?%d*)%s*%-?%s*(%d*%.?%d*)%s*(.*)", function (minLevel, maxLevel, title)
				guide.minLevel = tonumber(minLevel)
				guide.maxLevel = tonumber(maxLevel)
				guide.title = title
				return ""
			end, 1)
			if c ~= 1 or rest ~= "" then
				addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "DETAILS" then
			guide.detailsRaw = tag:gsub("%s*(.*)", "%1", 1)
			guide.details, _, guide.detailsUrl = textFormatting(guide.detailsRaw)
		elseif element.t == "DOWNLOAD" then
			local _, c = tag:gsub("%s*(%d*%.?%d*)%s*%-?%s*(%d*%.?%d*)%s*([^%s]*)%s(.*)", function (minLevel, maxLevel, url, name)
				guide.downloadMinLevel = tonumber(minLevel)
				guide.downloadMaxLevel = tonumber(maxLevel)
				guide.download = name
				guide.downloadUrl = url
			end, 1)
			if c ~= 1 then
				addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "GUIDE_APPLIES" then
			tag:upper():gsub(" ",""):gsub("([^,]+)", function(c)
				if addon.isClass(c) then
					if guide.classes == nil then guide.classes = {} end
					table.insert(guide.classes, addon.getClass(c))
				elseif addon.isRace(c) then
					if guide.races == nil then guide.races = {} end
					table.insert(guide.races, addon.getRace(c))
				elseif addon.isFaction(c) then
					guide.faction = addon.getFaction(c)
				else
					addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end)
		elseif nameOnly then
			return ""
		elseif element.t == "AUTO_ADD_COORDINATES_GOTO" then
			if tag:upper():gsub(" ","") == "ON" then
				guide.autoAddCoordinatesGOTO = true
			elseif tag:upper():gsub(" ","") == "OFF" then
				guide.autoAddCoordinatesGOTO = false
			else
				addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "AUTO_ADD_COORDINATES_LOC" then
			if tag:upper():gsub(" ","") == "ON" then
				guide.autoAddCoordinatesGOTO = true
			elseif tag:upper():gsub(" ","") == "OFF" then
				guide.autoAddCoordinatesGOTO = false
			else
				addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif addon.getSuperCode(element.t) == "QUEST" then
			if element.t == "PICKUP" then
				element.t = "ACCEPT"
			elseif element.t == "WORK" then
				element.t = "COMPLETE"
				element.optional = true
			elseif element.t == "QUEST" then
				element.t = "COMPLETE"
			end
			local _, c = tag:gsub("%s*([%d/%?]+),?(%d*)%s*(.-)%s*$", function(id, objective, title)
				element.questId = tonumber(id)
				if element.questId == nil then
					if strict then 
						addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					else
						element.questId = id
					end
				end
				if addon.questsDB[element.questId] ~= nil and addon.questsDB[element.questId].replacement ~= nil then
					element.questId = addon.questsDB[element.questId].replacement
				end
				if objective ~= "" then element.objective = tonumber(objective) end
				if title == "-" then
					element.title = ""
				elseif title ~= "" and (not strict or addon.questsDB[element.questId] == nil or title ~= addon.questsDB[element.questId].name) then
					element.title = title
				end
				--if addon.debugging and addon.questsDB[element.questId] == nil then 
				--	print("LIME: loading guide \"" .. (guide.title or "") .. "\": unknown quest id " .. (element.questId or "") .. "\" in line \"" .. (step.line or "") .. " " .. step.text .. "\"") 
				--end
				--elseif addon.debugging and addon.questsDB[element.questId].name ~= element.title:sub(1, #addon.questsDB[element.questId].name) then
				--	error("loading guide \"" .. GuidelimeDataChar.currentGuide.title .. "\": wrong title for quest " .. element.questId .. " \"" .. element.title .. "\" instead of \"" .. addon.questsDB[element.questId].name .. "\" in line \"" .. step.text .. "\"")
				--end
				if addon.questsDB[element.questId] ~= nil then
					if step.races == nil and addon.getQuestRaces(element.questId) ~= nil then 
						step.races = {}
						for i, r in pairs(addon.getQuestRaces(element.questId)) do step.races[i] = r end
					end
					if step.classes == nil and addon.getQuestClasses(element.questId) ~= nil then 
						step.classes = {}
						for i, r in pairs(addon.getQuestClasses(element.questId)) do step.classes[i] = r end
					end
					if step.faction == nil and addon.getQuestFaction(element.questId) ~= nil then step.faction = addon.getQuestFaction(element.questId) end
					if addon.questsDB[element.questId].sort ~= nil and addon.mapIDs[addon.questsDB[element.questId].sort] ~= nil then 
						guide.currentZone = addon.mapIDs[addon.questsDB[element.questId].sort] 
					end
				end
				if element.t ~= "SKIP" then 
					previousAutoStep = lastAutoStep
					lastAutoStep = element 
				end
			end, 1)
			if c ~= 1 then
				addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "APPLIES" then
			tag:upper():gsub(" ",""):gsub("([^,]+)", function(c)
				if addon.isClass(c) then
					if step.classes == nil then step.classes = {} end
					table.insert(step.classes, addon.getClass(c))
				elseif addon.isRace(c) then
					if step.races == nil then step.races = {} end
					table.insert(step.races, addon.getRace(c))
				elseif addon.isFaction(c) then
					step.faction = addon.getFaction(c)
				else
					addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end)
		elseif element.t == "GOTO" then
			local _, c = tag:gsub("%s*(%d+%.?%d*)%s?,%s?(%d+%.?%d*)%s?,?%s?(%d*%.?%d*)%s?(.*)", function(x, y, radius, zone)
				element.x = tonumber(x)
				element.y = tonumber(y)
				if radius ~= "" then element.radius = tonumber(radius) end
				if element.radius == nil or element.radius == 0 then element.radius = addon.DEFAULT_GOTO_RADIUS end
				if zone ~= "" then guide.currentZone = addon.mapIDs[addon.getZoneName(zone)] end
				element.mapID = guide.currentZone
				if element.mapID == nil then 
					addon.createPopupFrame(string.format(L.ERROR_CODE_ZONE_NOT_FOUND, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
				element.wx, element.wy, element.instance = HBD:GetWorldCoordinatesFromZone(element.x / 100, element.y / 100, element.mapID)
				step.hasGoto = true
			end, 1)
			if c ~= 1 then
				addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "LOC" then
			local _, c = tag:gsub("%s*(%d+%.?%d*)%s?,%s?(%d+%.?%d*)%s?(.*)", function(x, y, zone)
				element.x = tonumber(x)
				element.y = tonumber(y)
				if zone ~= "" then guide.currentZone = addon.mapIDs[addon.getZoneName(zone)] end
				element.mapID = guide.currentZone
				if element.mapID == nil then 
					addon.createPopupFrame(string.format(L.ERROR_CODE_ZONE_NOT_FOUND, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
				element.wx, element.wy, element.instance = HBD:GetWorldCoordinatesFromZone(element.x / 100, element.y / 100, element.mapID)
				step.hasLoc = true
			end, 1)
			if c ~= 1 then
				addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "XP" then
			local _, c = tag:gsub("%s*(%d+)([%+%-%.]?)(%d*)(.*)", function(level, t, xp, text)
				element.level = tonumber(level)
				if text ~= "" then
					element.text, element.textInactive, _ = textFormatting(text:gsub("%s*(.*)", "%1", 1))
				end
				if element.text == nil then
					element.text = level .. t .. xp
					element.textInactive = element.text
				end
				if t == "+" then
					element.xp = tonumber(xp)
					step.xp = true
				elseif t == "-" then
					element.xpType = "REMAINING"
					element.xp = tonumber(xp)
					element.level = element.level - 1
					step.xp = true
				elseif t == "." then
					element.xpType = "PERCENTAGE"
					element.xp = tonumber("0." .. xp)
					step.xp = true
				end
				lastAutoStep = element
			end, 1)
			if c ~= 1 then
				addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "OPTIONAL_COMPLETE_WITH_NEXT" then
			element.text, element.textInactive, _ = textFormatting(tag)
			step.completeWithNext = true
			step.optional = true
		elseif element.t == "COMPLETE_WITH_NEXT" then
			element.text, element.textInactive, _ = textFormatting(tag)
			step.completeWithNext = true
			step.optional = true
		elseif element.t == "OPTIONAL" then
			element.text, element.textInactive, _ = textFormatting(tag)
			if lastAutoStep ~= nil then
				lastAutoStep.optional = true
				lastAutoStep = previousAutoStep
				autoStepOptional = true
			else
				step.optional = true
			end
		elseif element.t == "FLY" or element.t == "GET_FLIGHT_POINT" then
			if tag:gsub(" ", "") ~= "" then
				element.text, element.textInactive = textFormatting(tag)
				element.flightmaster = addon.getFlightmasterByPlace(tag, step.faction or guide.faction)
--TODO: active this error check
--				if element.flightmaster == nil then
--					addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
--					err = true
--				end
			end
		else
			element.text, element.textInactive = textFormatting(tag)
		end
		return ""
	end)
	if autoStepOptional and lastAutoStep == nil then step.optional = true end
	if err then return end
	if t ~= nil and t ~= "" then
		local element = {}
		element.t = "TEXT"
		element.text, element.textInactive, element.url, element.empty = textFormatting(t, addon.COLOR_WHITE)
		if element.text ~= nil then
			element.startPos = pos 
			element.endPos = pos + #t - 1
			element.index = #step.elements + 1
			element.step = step
			table.insert(step.elements, element)
		end
	end
	return true
end
