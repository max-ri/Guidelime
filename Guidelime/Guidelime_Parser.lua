local addonName, addon = ...

--[[
codes:
 - N Name and level of the guide [N(min)-(max)(name)]
 - NX Name and level of the next guide proposed after finishing this [NN(min)-(max)(name)]
 - D details of the guide [D(details)]
 - GA guide applies to [GA(race),(class),(faction),...]
 - Q [QP/T/C/S(id)[,objective](title)] quest pickup/turnin/complete/skip
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

function addon.parseGuide(guide, addonName)
	if guide.text ~= nil then
		guide.steps = {}
		guide.text:gsub("([^\n]+)", function(c)
			if c ~= nil and c ~= "" then
				table.insert(guide.steps, {text = c})
			end
		end)
	end
	for i, step in ipairs(guide.steps) do
		addon.parseLine(step, guide)	
	end
	if guide.group == nil then
		if addonName ~= nil and addonName:sub(1,10) == "Guidelime_" then
			guide.group = addonName:sub(11)
		elseif addonName ~= nil then
			guide.group = addonName
		else
			guide.group = L.OTHER_GUIDES
		end
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
	local t = step.text
	local found
	repeat
		found = false
		t = t:gsub("(.-)%[(.-)%]", function(text, code)
			if text ~= "" then
				local element = {}
				element.t = "TEXT"
				element.text = text
				table.insert(step.elements, element)
			end
			if code:sub(1, 1) == "N" then
				if code:sub(2, 2) == "X" then
					guide.next = code:sub(3)
				else
					code:sub(2):gsub("(.*) ?(%d*) ?- ?(%d*) ?(.*)", function (group, minLevel, maxLevel, title)
						guide.group = group
						guide.minLevel = tonumber(minLevel)
						guide.maxLevel = tonumber(maxLevel)
						guide.title = title
					end)
				end
			elseif code:sub(1, 1) == "D" then
				guide.details = code:sub(2)
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
				end)
				table.insert(step.elements, element)
			elseif code:sub(1, 1) == "L" then
				local element = {}
				element.t = "LOC"
				code:gsub("L(%d+%.?%d*), ?(%d+%.?%d*)(.*)", function(x, y, zone)
					element.x = tonumber(x)
					element.y = tonumber(y)
					if zone ~= "" then addon.currentZone = addon.mapIDs[zone] end
					element.mapID = addon.currentZone
					if element.mapID == nil then error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": zone not found for [" .. code .. "] in line \"" .. step.text .. "\"") end
				end)
				table.insert(step.elements, element)
			elseif code:sub(1, 1) == "G" then
				elseif code:sub(2, 1) == "A" then
					code:sub(3):upper():gsub(" ",""):gsub("([^,]+)", function(c)
						if isClass(c) then
							if guide.class == nil then guide.class = {} end
							table.insert(guide.class, c)
						elseif isRace(c) then
							if guide.race == nil then guide.race = {} end
							if c == "UNDEAD" then c = "SCOURGE" end
							table.insert(guide.race, c)
						elseif isFaction(c) then
							if guide.faction == nil then guide.faction = {} end
							table.insert(guide.faction, c)
						else
							error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
						end
					end)
				else
					local element = {}
					element.t = "GOTO"
					code:gsub("G(%d+%.?%d*), ?(%d+%.?%d*),? ?(%d*%.?%d*)(.*)", function(x, y, radius, zone)
						element.x = tonumber(x)
						element.y = tonumber(y)
						if radius ~= "" then element.radius = tonumber(radius) else element.radius = 1 end
						if zone ~= "" then addon.currentZone = addon.mapIDs[zone] end
						element.mapID = addon.currentZone
						if element.mapID == nil then error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": zone not found for [" .. code .. "] in line \"" .. step.text .. "\"") end
					end)
					table.insert(step.elements, element)
				end
			elseif code:sub(1, 2) == "XP" then
				local element = {}
				element.t = "LEVEL"
				code:gsub("XP(%d+)([%+%-%.]?)(%d*)(.*)", function(level, t, xp, text)
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
				end)
				table.insert(step.elements, element)
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
						if step.faction == nil then step.faction = {} end
						table.insert(step.faction, c)
					else
						error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
					end
				end)
			else
				error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
			end
			found = true
			return ""
		end)
	until(not found)
	if t ~= nil and t ~= "" then
		local element = {}
		element.t = "TEXT"
		element.text = t
		table.insert(step.elements, element)
	end
end
