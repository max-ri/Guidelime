local addonName, addon = ...

--[[
codes:
 - N Name and level of the guide [N(min)-(max)(name)]
 - NX Name and level of the next guide proposed after finishing this [NX(min)-(max)(name)]
 - D details of the guide [D(details)]
 - GA guide applies to [GA(race),(class),(faction),...]
 - Q [QP/T/C/S/W(id)[,objective](title)] quest pickup/turnin/complete/skip
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

function addon.parseGuide(guide, group)
	if type(guide) == "string" then
		guide = {text = guide}
	end
	if guide.text ~= nil then
		guide.steps = {}
		guide.text:gsub("([^\n]+)", function(c)
			if c ~= nil and c ~= "" then
				table.insert(guide.steps, {text = c})
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

local function isClass(c)
	return c == "WARRIOR" or c == "ROGUE" or c == "MAGE" or c == "WARLOCK" or c == "HUNTER" or c == "PRIEST" or c == "DRUID" or c == "PALADIN" or c == "SHAMAN"
end

local function isRace(c)
	return c == "HUMAN" or c == "NIGHTELF" or c == "DWARF" or c == "GNOME" or c == "ORC" or c == "TROLL" or c == "TAUREN" or c == "UNDEAD" or c == "SCOURGE" or c == "BLOODELF" or c == "DRAENEI"
end

local function isFaction(c)
	return c == "ALLIANCE" or c == "HORDE"
end

function addon.parseLine(step, guide)
	if step.text == nil then return end
	step.elements = {}
	local t = step.text:gsub("\\\\","\n"):gsub("(.-)%[(.-)%]", function(text, code)
		if text ~= "" then
			local element = {}
			element.t = "TEXT"
			element.text = text
			table.insert(step.elements, element)
		end
		if code:sub(1, 1) == "N" then
			if code:sub(2, 2) == "X" then
				code:sub(2):gsub("(%d*)%s?-%s?(%d*)%s?(.*)", function (minLevel, maxLevel, title)
					--print("LIME: \"".. (group or "") .. "\",\"" .. minLevel .. "\",\"" .. maxLevel .. "\",\"" .. title .. "\"")
					guide.next = minLevel .. "-" .. maxLevel .. " " .. title
				end, 1)
			else
				code:sub(2):gsub("(%d*)%s?-%s?(%d*)%s?(.*)", function (minLevel, maxLevel, title)
					--print("LIME: \"".. (group or "") .. "\",\"" .. minLevel .. "\",\"" .. maxLevel .. "\",\"" .. title .. "\"")
					guide.minLevel = tonumber(minLevel)
					guide.maxLevel = tonumber(maxLevel)
					guide.title = title
				end, 1)
			end
		elseif code:sub(1, 1) == "D" then
			guide.details = code:sub(2)
				:gsub("(www%.[%w%./#%-%?]*)", function(url) return "|cFFAAAAAA" .. url .. "|r" end)
				:gsub("(https://[%w%./#%-%?]*)", function(url) return "|cFFAAAAAA" .. url .. "|r" end)
				:gsub("(http://[%w%./#%-%?]*)", function(url) return "|cFFAAAAAA" .. url .. "|r" end)
				:gsub("(http://[%w%./#%-%?]*)", function(url) return "|cFFAAAAAA" .. url .. "|r" end)
				:gsub("%*([^%*]+)%*", function(text) return "|cFFFFD100" .. text .. "|r" end)
				:gsub("%*%*","%*")
		elseif code:sub(1, 1) == "Q" then
			local element = {}
			if code:sub(2, 2) == "P" then
				element.t = "PICKUP"
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
			code:sub(3):gsub("(%d+),?(%d*)(.*)", function(id, objective, title)
				element.questId = tonumber(id)
				if objective ~= "" then element.objective = tonumber(objective) end
				if title == "-" then
					element.hidden = true
				else
					element.title = title
				end
				if addon.questsDB[element.questId] == nil then error("loading guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": unknown quest id " .. element.questId .. "\" in line \"" .. step.text .. "\"") end
				if element.title == nil or element.title == "" then
					element.title = addon.questsDB[element.questId].name
				elseif addon.debugging and addon.questsDB[element.questId].name ~= element.title:sub(1, #addon.questsDB[element.questId].name) then
					error("loading guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": wrong title for quest " .. element.questId .. " \"" .. element.title .. "\" instead of \"" .. addon.questsDB[element.questId].name .. "\" in line \"" .. step.text .. "\"")
				end
				if step.race == nil and addon.questsDB[element.questId].races ~= nil then step.race = addon.questsDB[element.questId].races end
				if step.class == nil and addon.questsDB[element.questId].classes ~= nil then step.class = addon.questsDB[element.questId].classes end
				if step.faction == nil and addon.questsDB[element.questId].faction ~= nil then step.faction = addon.questsDB[element.questId].faction end
				if addon.questsDB[element.questId].sort ~= nil and addon.mapIDs[addon.questsDB[element.questId].sort] ~= nil then guide.currentZone = addon.mapIDs[addon.questsDB[element.questId].sort] end
				table.insert(step.elements, element)
			end, 1)
		elseif code:sub(1, 1) == "L" then
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
		elseif code:sub(1, 1) == "G" then
			if code:sub(2, 2) == "A" then
				code:sub(3):upper():gsub(" ",""):gsub("([^,]+)", function(c)
					if isClass(c) then
						if guide.class == nil then guide.class = {} end
						table.insert(guide.class, c)
					elseif isRace(c) then
						if guide.race == nil then guide.race = {} end
						if c == "UNDEAD" then c = "SCOURGE" end
						table.insert(guide.race, c)
					elseif isFaction(c) then
						guide.faction = c
					else
						error("code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
					end
				end)
			else
				code:gsub("G(%d+%.?%d*),%s?(%d+%.?%d*),?%s?(%d*%.?%d*)(.*)", function(x, y, radius, zone)
					local element = {}
					element.t = "GOTO"
					element.x = tonumber(x)
					element.y = tonumber(y)
					if radius ~= "" then element.radius = tonumber(radius) else element.radius = 1 end
					if zone ~= "" then guide.currentZone = addon.mapIDs[zone] end
					element.mapID = guide.currentZone
					if element.mapID == nil then error("zone not found for [" .. code .. "] in line \"" .. step.text .. "\"") end
					table.insert(step.elements, element)
				end, 1)
			end
		elseif code:sub(1, 2) == "XP" then
			code:gsub("XP(%d+)([%+%-%.]?)(%d*)(.*)", function(level, t, xp, text)
				local element = {}
				element.t = "LEVEL"
				element.level = tonumber(level)
				if text ~= "" and text:sub(1, 1) == " " then
					element.text = text:sub(2)
				elseif text ~= "" then
					element.text = text
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
		elseif code:sub(1, 1) == "H" then
			local element = {}
			element.t = "HEARTH"
			element.text = code:sub(2)
			table.insert(step.elements, element)
		elseif code:sub(1, 1) == "F" then
			local element = {}
			element.t = "FLY"
			element.text = code:sub(2)
			table.insert(step.elements, element)
		elseif code:sub(1, 1) == "T" then
			local element = {}
			element.t = "TRAIN"
			element.text = code:sub(2)
			table.insert(step.elements, element)
		elseif code:sub(1, 1) == "S" then
			local element = {}
			element.t = "SETHEARTH"
			element.text = code:sub(2)
			table.insert(step.elements, element)
		elseif code:sub(1, 1) == "P" then
			local element = {}
			element.t = "GETFLIGHTPOINT"
			element.text = code:sub(2)
			table.insert(step.elements, element)
		elseif code:sub(1, 1) == "V" then
			local element = {}
			element.t = "VENDOR"
			element.text = code:sub(2)
			table.insert(step.elements, element)
		elseif code:sub(1, 1) == "R" then
			local element = {}
			element.t = "REPAIR"
			element.text = code:sub(2)
			table.insert(step.elements, element)
		elseif code:sub(1, 1) == "O" then
			local element = {}
			element.t = "TEXT"
			element.text = code:sub(2)
			if element.text ~= "" then 
				table.insert(step.elements, element)
			end
			step.optional = true
		elseif code:sub(1, 1) == "C" then
			local element = {}
			element.t = "TEXT"
			element.text = code:sub(2)
			if element.text ~= "" then 
				table.insert(step.elements, element)
			end
			step.completeWithNext = true
		elseif code:sub(1, 1) == "A" then
			code:sub(2):upper():gsub(" ",""):gsub("([^,]+)", function(c)
				if isClass(c) then
					if step.class == nil then step.class = {} end
					table.insert(step.class, c)
				elseif isRace(c) then
					if step.race == nil then step.race = {} end
					if c == "UNDEAD" then c = "SCOURGE" end
					table.insert(step.race, c)
				elseif isFaction(c) then
					step.faction = c
				else
					error("code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
				end
			end)
		else
			error("code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
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
