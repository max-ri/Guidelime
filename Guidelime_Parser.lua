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
--deprecated
	COMPLETE_WITH_NEXT = "C", -- same as OC
	PICKUP = "QP", -- same as QA
	WORK = "QW", -- same as QC but optional
}

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

function addon.parseGuide(guide, group, strict)
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
		local t = guide.text:gsub("([^\n\r]-)[\n\r]", function(c)
			if c ~= nil and c ~= "" then
				local step = {text = c:gsub("\\\\"," \n"), startPos = pos, line = guide.lines, guide = guide}
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
			table.insert(guide.steps, {text = t:gsub("\\\\"," \n"), startPos = pos, line = guide.lines, guide = guide})
			guide.lines = guide.lines + 1
		end
	end
	guide.currentZone = nil
	for i, step in ipairs(guide.steps) do
		if not addon.parseLine(step, guide, strict) then return end
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

function addon.parseLine(step, guide, strict)
	if step.text == nil then return end
	step.elements = {}
	local lastAutoStep
	local err = false
	local pos = step.startPos
	local t = step.text:gsub("(.-)%[(.-)%]", function(text, code)
		if text ~= "" then
			local element = {}
			element.t = "TEXT"
			element.text = text
			element.startPos = pos
			pos = pos + #text
			element.endPos = pos - 1
			element.index = #step.elements + 1
			element.step = step
			table.insert(step.elements, element)
			if addon.debugging and step.text:sub(element.startPos - step.startPos + 1, element.endPos - step.startPos + 1) ~= text then
				print("LIME: parsing guide \"" .. step.text:sub(element.startPos - step.startPos + 1, element.endPos - step.startPos + 1) .. "\" should be \"" .. text .. "\" at " .. element.startPos .. "-" .. element.endPos .. " in " .. pos0 .. "->" .. step.text)
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
			addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.name or "", code, (step.line or "") .. " " .. step.text)):Show()
			err = true
			return ""
		end		
		table.insert(step.elements, element)
		local tag = code:sub(#addon.codes[element.t] + 1)
		
		if addon.debugging and step.text:sub(element.startPos - step.startPos + 1, element.endPos - step.startPos + 1) ~= ("["..code.."]") then
			print("LIME: parsing guide \"[" .. step.text:sub(element.startPos - step.startPos + 1, element.endPos - step.startPos + 1) .. "]\" should be \"" .. code .. "\" at " .. element.startPos .. "-" .. element.endPos .. " in " .. pos0 .. "->" .. step.text)
		end
		if element.t == "NEXT" then
			tag:gsub("%s*(%d*)%s*-%s*(%d*)%s*(.*)", function (minLevel, maxLevel, title)
				--print("LIME: \"".. (group or "") .. "\",\"" .. minLevel .. "\",\"" .. maxLevel .. "\",\"" .. title .. "\"")
				guide.next = minLevel .. "-" .. maxLevel .. " " .. title
			end, 1)
		elseif element.t == "NAME" then
			tag:gsub("%s*(%d*)%s*-%s*(%d*)%s*(.*)", function (minLevel, maxLevel, title)
				--print("LIME: \"".. (group or "") .. "\",\"" .. minLevel .. "\",\"" .. maxLevel .. "\",\"" .. title .. "\"")
				guide.minLevel = tonumber(minLevel)
				guide.maxLevel = tonumber(maxLevel)
				guide.title = title
			end, 1)
		elseif element.t == "DETAILS" then
			guide.detailsRaw = tag:gsub("%s*(.*)", "%1", 1)
			guide.details = guide.detailsRaw
				:gsub("(https://[%w%./#%-%?]*)", function(url) guide.detailsUrl = url; return "|cFFAAAAAA" .. url .. "|r" end)
				:gsub("(http://[%w%./#%-%?]*)", function(url) guide.detailsUrl = url; return "|cFFAAAAAA" .. url .. "|r" end)
				:gsub("(www%.[%w%./#%-%?]*)", function(url) if guide.detailsUrl == nil then guide.detailsUrl = url end; return "|cFFAAAAAA" .. url .. "|r" end)
				:gsub("%*([^%*]+)%*", "|cFFFFD100%1|r")
				:gsub("%*%*","%*")
		elseif addon.getSuperCode(element.t) == "QUEST" then
			if element.t == "PICKUP" then
				element.t = "ACCEPT"
			elseif element.t == "WORK" then
				element.t = "COMPLETE"
				element.optional = true
			end
			tag:gsub("%s*([%d/%?]+),?(%d*)%s*(.*)", function(id, objective, title)
				element.questId = tonumber(id)
				if element.questId == nil then
					if strict then 
						addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.name or "", code, (step.line or "") .. " " .. step.text)):Show()
					else
						element.questId = id
					end
				end
				if objective ~= "" then element.objective = tonumber(objective) end
				if title == "-" then
					element.title = ""
				elseif title ~= "" then
					element.title = title
				end
				--if addon.debugging and addon.questsDB[element.questId] == nil then 
				--	print("LIME: loading guide \"" .. (guide.name or "") .. "\": unknown quest id " .. (element.questId or "") .. "\" in line \"" .. (step.line or "") .. " " .. step.text .. "\"") 
				--end
				--elseif addon.debugging and addon.questsDB[element.questId].name ~= element.title:sub(1, #addon.questsDB[element.questId].name) then
				--	error("loading guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": wrong title for quest " .. element.questId .. " \"" .. element.title .. "\" instead of \"" .. addon.questsDB[element.questId].name .. "\" in line \"" .. step.text .. "\"")
				--end
				if addon.questsDB[element.questId] ~= nil then
					if step.race == nil and addon.questsDB[element.questId].races ~= nil then 
						step.race = {}
						for i, r in pairs(addon.questsDB[element.questId].races) do step.race[i] = r end
					end
					if step.class == nil and addon.questsDB[element.questId].classes ~= nil then 
						step.class = {}
						for i, r in pairs(addon.questsDB[element.questId].classes) do step.class[i] = r end
					end
					if step.faction == nil and addon.questsDB[element.questId].faction ~= nil then step.faction = addon.questsDB[element.questId].faction end
					if addon.questsDB[element.questId].sort ~= nil and addon.mapIDs[addon.questsDB[element.questId].sort] ~= nil then 
						guide.currentZone = addon.mapIDs[addon.questsDB[element.questId].sort] 
					end
				end
				if element.t ~= "SKIP" then lastAutoStep = element end
			end, 1)
		elseif element.t == "GUIDE_APPLIES" then
			tag:upper():gsub(" ",""):gsub("([^,]+)", function(c)
				if addon.isClass(c) then
					if guide.class == nil then guide.class = {} end
					table.insert(guide.class, addon.getClass(c))
				elseif addon.isRace(c) then
					if guide.race == nil then guide.race = {} end
					table.insert(guide.race, addon.getRace(c))
				elseif addon.isFaction(c) then
					guide.faction = addon.getFaction(c)
				else
					addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.name or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end)
		elseif element.t == "APPLIES" then
			tag:upper():gsub(" ",""):gsub("([^,]+)", function(c)
				if addon.isClass(c) then
					if step.class == nil then step.class = {} end
					table.insert(step.class, addon.getClass(c))
				elseif addon.isRace(c) then
					if step.race == nil then step.race = {} end
					table.insert(step.race, addon.getRace(c))
				elseif addon.isFaction(c) then
					step.faction = addon.getFaction(c)
				else
					addon.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.name or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end)
		elseif element.t == "GOTO" then
			tag:gsub("%s*(%d+%.?%d*),%s?(%d+%.?%d*),?%s?(%d*%.?%d*)%s?(.*)", function(x, y, radius, zone)
				element.x = tonumber(x)
				element.y = tonumber(y)
				if radius ~= "" then element.radius = tonumber(radius) else element.radius = addon.DEFAULT_GOTO_RADIUS end
				if zone ~= "" then guide.currentZone = addon.mapIDs[zone] end
				element.mapID = guide.currentZone
				if element.mapID == nil then 
					addon.createPopupFrame(string.format(L.ERROR_CODE_ZONE_NOT_FOUND, guide.name or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
				step.hasGoto = true
			end, 1)
		elseif element.t == "LOC" then
			tag:gsub("%s*(%d+%.?%d*),%s?(%d+%.?%d*)%s?(.*)", function(x, y, zone)
				element.x = tonumber(x)
				element.y = tonumber(y)
				if zone ~= "" then guide.currentZone = addon.mapIDs[zone] end
				element.mapID = guide.currentZone
				if element.mapID == nil then 
					addon.createPopupFrame(string.format(L.ERROR_CODE_ZONE_NOT_FOUND, guide.name or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end, 1)
		elseif element.t == "XP" then
			tag:gsub("%s*(%d+)([%+%-%.]?)(%d*)(.*)", function(level, t, xp, text)
				element.level = tonumber(level)
				if text ~= "" then
					element.text = text:gsub("%s*(.*)", "%1", 1)
				else
					element.text = level .. t .. xp
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
		elseif element.t == "OPTIONAL_COMPLETE_WITH_NEXT" then
			element.text = tag
			step.completeWithNext = true
		elseif element. t == "COMPLETE_WITH_NEXT" then
			element.text = tag
			step.completeWithNext = true
		elseif element.t == "OPTIONAL" then
			element.text = tag
			if lastAutoStep ~= nil then
				lastAutoStep.optional = true
			else
				step.optional = true
			end
		else
			element.text = tag
		end
		return ""
	end)
	if err then return end
	if t ~= nil and t ~= "" then
		local element = {}
		element.t = "TEXT"
		element.text = t
		element.startPos = pos 
		element.endPos = pos + #t - 1
		element.index = #step.elements + 1
		element.step = step
		table.insert(step.elements, element)
	end
	return not err
end
