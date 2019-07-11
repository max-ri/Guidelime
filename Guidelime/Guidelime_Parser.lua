local addonName, addon = ...

--[[
codes:
 - N Name and level of the guide [N(min)-(max)(name)]
 - NX Name and level of the next guide proposed after finishing this [NX(min)-(max)(name)]
 - D details of the guide [D(details)]
 - GA guide applies to [GA(race),(class),(faction),...]
 - Q [QA/T/C/S/W(id)[,objective](title)] quest accept/turnin/complete/skip
 - L [L(x).(y)[zone] ] loc
 - G [G(x).(y)[zone] ] goto
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
	COMPLETE_WITH_NEXT = "C",
	QUEST = "Q",
	GOTO = "G",
	LOC = "L",
	XP = "XP",
	HEARTH = "H",
	FLY = "F",
	TRAIN = "T",
	SET_HEARTH = "S",
	GET_FLIGHT_POINT = "P",
	VENDOR = "V",
	REPAIR = "R"
}

function addon.parseGuide(guide, group)
	if type(guide) == "string" then
		guide = {text = guide}
	elseif #guide > 0 then
		guide = {steps = guide}
	end
	if guide.text ~= nil then
		guide.steps = {}
		guide.text:gsub("([^\n]+)", function(c)
			if c ~= nil and c ~= "" then
				table.insert(guide.steps, {text = c:gsub("\\\\","\n")})
			end
		end)
	end
	guide.currentZone = nil
	for i, step in ipairs(guide.steps) do
		addon.parseLine(step, guide)	
	end
	if group ~= nil and group:sub(1,10) == "Guidelime_" then
		guide.group = group:sub(11)
	elseif group ~= nil then
		guide.group = group
	else
		guide.group = "other guides"--L.OTHER_GUIDES
	end
	if guide.title ~= nil then 
		guide.name = guide.title
	else
		guide.name = ""
	end
	if guide.minLevel ~= nil or guide.maxLevel ~= nil then
		guide.name = " " .. guide.name
		if guide.maxLevel ~= nil then guide.name = guide.maxLevel .. guide.name end
		guide.name = "-" .. guide.name
		if guide.minLevel ~= nil then guide.name = guide.minLevel .. guide.name end
	end
	guide.name = guide.group .. " " .. guide.name
	return guide
end

function addon.parseLine(step, guide)
	if step.text == nil then return end
	step.elements = {}
	local t = step.text:gsub("(.-)%[(.-)%]", function(text, code)
		if text ~= "" then
			local element = {}
			element.t = "TEXT"
			element.text = text
			table.insert(step.elements, element)
		end
		
		if code:sub(1, 2) == addon.codes.NEXT then
			code:sub(2):gsub("(%d*)%s*-%s*(%d*)%s*(.*)", function (minLevel, maxLevel, title)
				--print("LIME: \"".. (group or "") .. "\",\"" .. minLevel .. "\",\"" .. maxLevel .. "\",\"" .. title .. "\"")
				guide.next = minLevel .. "-" .. maxLevel .. " " .. title
			end, 1)
		elseif code:sub(1, 1) == addon.codes.NAME then
			code:sub(2):gsub("(%d*)%s*-%s*(%d*)%s*(.*)", function (minLevel, maxLevel, title)
				--print("LIME: \"".. (group or "") .. "\",\"" .. minLevel .. "\",\"" .. maxLevel .. "\",\"" .. title .. "\"")
				guide.minLevel = tonumber(minLevel)
				guide.maxLevel = tonumber(maxLevel)
				guide.title = title
			end, 1)
		elseif code:sub(1, 1) == addon.codes.DETAILS then
			guide.detailsRaw = code:sub(2):gsub("%s*(.*)", "%1", 1)
			guide.details = guide.detailsRaw
				:gsub("(www%.[%w%./#%-%?]*)", "|cFFAAAAAA%1|r")
				:gsub("(https://[%w%./#%-%?]*)", "|cFFAAAAAA%1|r")
				:gsub("(http://[%w%./#%-%?]*)", "|cFFAAAAAA%1|r")
				:gsub("(http://[%w%./#%-%?]*)", "|cFFAAAAAA%1|r")
				:gsub("%*([^%*]+)%*", "|cFFFFD100%1|r")
				:gsub("%*%*","%*")
		elseif code:sub(1, 1) == addon.codes.QUEST then
			local element = {}
			if code:sub(2, 2) == "A" or code:sub(2, 2) == "P" then
				element.t = "ACCEPT"
			elseif code:sub(2, 2) == "T" then
				element.t = "TURNIN"
			elseif code:sub(2, 2) == "C" then
				element.t = "COMPLETE"
			elseif code:sub(2, 2) == "S" then
				element.t = "SKIP"
			elseif code:sub(2, 2) == "W" then
				element.t = "WORK"
			else
				error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
			end
			code:sub(3):gsub("(%d+),?(%d*)%s*(.*)", function(id, objective, title)
				element.questId = tonumber(id)
				if objective ~= "" then element.objective = tonumber(objective) end
				if title == "-" then
					element.title = ""
				elseif title == nil or title == "" then
					element.title = addon.questsDB[element.questId].name
				else
					element.title = title
				end
				if addon.questsDB[element.questId] == nil then error("loading guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": unknown quest id " .. element.questId .. "\" in line \"" .. step.text .. "\"") end
				--elseif addon.debugging and addon.questsDB[element.questId].name ~= element.title:sub(1, #addon.questsDB[element.questId].name) then
				--	error("loading guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": wrong title for quest " .. element.questId .. " \"" .. element.title .. "\" instead of \"" .. addon.questsDB[element.questId].name .. "\" in line \"" .. step.text .. "\"")
				--end
				if step.race == nil and addon.questsDB[element.questId].races ~= nil then 
					step.race = {}
					for i, r in pairs(addon.questsDB[element.questId].races) do step.race[i] = r end
				end
				if step.class == nil and addon.questsDB[element.questId].classes ~= nil then 
					step.class = {}
					for i, r in pairs(addon.questsDB[element.questId].classes) do step.class[i] = r end
				end
				if step.faction == nil and addon.questsDB[element.questId].faction ~= nil then step.faction = addon.questsDB[element.questId].faction end
				if addon.questsDB[element.questId].sort ~= nil and addon.mapIDs[addon.questsDB[element.questId].sort] ~= nil then guide.currentZone = addon.mapIDs[addon.questsDB[element.questId].sort] end
				table.insert(step.elements, element)
			end, 1)
		elseif code:sub(1, 2) == addon.codes.GUIDE_APPLIES then
			code:sub(3):upper():gsub(" ",""):gsub("([^,]+)", function(c)
				if addon.isClass(c) then
					if guide.class == nil then guide.class = {} end
					table.insert(guide.class, addon.getClass(c))
				elseif addon.isRace(c) then
					if guide.race == nil then guide.race = {} end
					table.insert(guide.race, addon.getRace(c))
				elseif addon.isFaction(c) then
					guide.faction = addon.getFaction(c)
				else
					error("code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
				end
			end)
		elseif code:sub(1, 1) == addon.codes.APPLIES then
			code:sub(2):upper():gsub(" ",""):gsub("([^,]+)", function(c)
				if addon.isClass(c) then
					if step.class == nil then step.class = {} end
					table.insert(step.class, addon.getClass(c))
				elseif addon.isRace(c) then
					if step.race == nil then step.race = {} end
					table.insert(step.race, addon.getRace(c))
				elseif addon.isFaction(c) then
					step.faction = addon.getFaction(c)
				else
					error("code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
				end
			end)
		elseif code:sub(1, 1) == addon.codes.GOTO then
			code:gsub("G(%d+%.?%d*),%s?(%d+%.?%d*),?%s?(%d*%.?%d*)(.*)", function(x, y, radius, zone)
				local element = {}
				element.t = "GOTO"
				element.x = tonumber(x)
				element.y = tonumber(y)
				if radius ~= "" then element.radius = tonumber(radius) else element.radius = addon.DEFAULT_GOTO_RADIUS end
				if zone ~= "" then guide.currentZone = addon.mapIDs[zone] end
				element.mapID = guide.currentZone
				if element.mapID == nil then error("zone not found for [" .. code .. "] in line \"" .. step.text .. "\"") end
				table.insert(step.elements, element)
			end, 1)
		elseif code:sub(1, 1) == addon.codes.LOC then
			code:gsub("L(%d+%.?%d*),%s?(%d+%.?%d*)(.*)", function(x, y, zone)
				local element = {}
				element.t = "LOC"
				element.x = tonumber(x)
				element.y = tonumber(y)
				if zone ~= "" then guide.currentZone = addon.mapIDs[zone] end
				element.mapID = guide.currentZone
				if element.mapID == nil then error("zone not found for [" .. code .. "] in line \"" .. step.text .. "\"") end
				table.insert(step.elements, element)
			end, 1)
		elseif code:sub(1, 2) == addon.codes.XP then
			code:gsub("XP(%d+)([%+%-%.]?)(%d*)(.*)", function(level, t, xp, text)
				local element = {}
				element.t = "LEVEL"
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
				table.insert(step.elements, element)
			end, 1)
		elseif code:sub(1, 1) == addon.codes.OPTIONAL then
			local element = {}
			element.t = "TEXT"
			element.text = code:sub(2)
			if element.text ~= "" then 
				table.insert(step.elements, element)
			end
			step.optional = true
		elseif code:sub(1, 1) == addon.codes.COMPLETE_WITH_NEXT then
			local element = {}
			element.t = "TEXT"
			element.text = code:sub(2)
			if element.text ~= "" then 
				table.insert(step.elements, element)
			end
			step.completeWithNext = true
		else
			local found = false
			for k, v in pairs(addon.codes) do
				if code:sub(1, 1) == v then
					local element = {}
					element.t = k
					element.text = code:sub(2)
					table.insert(step.elements, element)
					found = true
					break
				end
			end
			if not found then error("code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"") end
		end
		found = true
		return ""
	end)
	if t ~= nil and t ~= "" then
		local element = {}
		element.t = "TEXT"
		element.text = t
		table.insert(step.elements, element)
	end
end
