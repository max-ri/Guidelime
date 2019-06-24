local addonName, addon = ...

--[[
codes:
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
]]

function addon.parseLine(step)
	if step.text == nil then return end
	step.elements = {}
	local t = step.text
	local found
	repeat
		found = false
		t = string.gsub(t, "(.-)%[(.-)%]", function(text, code)
			if text ~= "" then
				local element = {}
				element.t = "TEXT"
				element.text = text
				table.insert(step.elements, element)
			end
			if string.sub(code, 1, 1) == "Q" then
				local element = {}
				if string.sub(code, 2, 2) == "P" then
					element.t = "PICKUP"
				elseif string.sub(code, 2, 2) == "T" then
					element.t = "TURNIN"
				elseif string.sub(code, 2, 2) == "C" then
					element.t = "COMPLETE"
				elseif string.sub(code, 2, 2) == "S" then
					element.t = "SKIP"
				else
					error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
				end
				string.gsub(string.sub(code, 3), "(%d+),?(%d*)(.*)", function(id, objective, title)
					element.questId = tonumber(id)
					if objective ~= "" then element.objective = tonumber(objective) end
					if title == "-" then
						element.hidden = true
					else
						element.title = title
					end
				end)
				table.insert(step.elements, element)
			elseif string.sub(code, 1, 1) == "L" then
				local element = {}
				element.t = "LOC"
				string.gsub(code, "L(%d+%.?%d*), ?(%d+%.?%d*)(.*)", function(x, y, zone)
					element.x = tonumber(x)
					element.y = tonumber(y)
					if zone ~= "" then addon.currentZone = addon.mapIDs[zone] end
					element.mapID = addon.currentZone
					if element.mapID == nil then error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": zone not found for [" .. code .. "] in line \"" .. step.text .. "\"") end
				end)
				table.insert(step.elements, element)
			elseif string.sub(code, 1, 1) == "G" then
				local element = {}
				element.t = "GOTO"
				string.gsub(code, "G(%d+%.?%d*), ?(%d+%.?%d*),? ?(%d*%.?%d*)(.*)", function(x, y, radius, zone)
					element.x = tonumber(x)
					element.y = tonumber(y)
					if radius ~= "" then element.radius = tonumber(radius) else element.radius = 1 end
					if zone ~= "" then addon.currentZone = addon.mapIDs[zone] end
					element.mapID = addon.currentZone
					if element.mapID == nil then error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": zone not found for [" .. code .. "] in line \"" .. step.text .. "\"") end
				end)
				table.insert(step.elements, element)
			elseif string.sub(code, 1, 2) == "XP" then
				local element = {}
				element.t = "LEVEL"
				string.gsub(code, "XP(%d+)([%+%-%.]?)(%d*)(.*)", function(level, t, xp, text)
					element.level = tonumber(level)
					if text ~= "" and string.sub(text, 1, 1) == " " then
						element.text = string.sub(text, 2)
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
			elseif string.sub(code, 1, 1) == "H" then
				local element = {}
				element.t = "HEARTH"
				element.text = string.sub(code, 2)
				table.insert(step.elements, element)
			elseif string.sub(code, 1, 1) == "F" then
				local element = {}
				element.t = "FLY"
				element.text = string.sub(code, 2)
				table.insert(step.elements, element)
			elseif string.sub(code, 1, 1) == "T" then
				local element = {}
				element.t = "TRAIN"
				element.text = string.sub(code, 2)
				table.insert(step.elements, element)
			elseif string.sub(code, 1, 1) == "S" then
				local element = {}
				element.t = "SETHEARTH"
				element.text = string.sub(code, 2)
				table.insert(step.elements, element)
			elseif string.sub(code, 1, 1) == "P" then
				local element = {}
				element.t = "GETFLIGHTPOINT"
				element.text = string.sub(code, 2)
				table.insert(step.elements, element)
			elseif string.sub(code, 1, 1) == "V" then
				local element = {}
				element.t = "VENDOR"
				element.text = string.sub(code, 2)
				table.insert(step.elements, element)
			elseif string.sub(code, 1, 1) == "R" then
				local element = {}
				element.t = "REPAIR"
				element.text = string.sub(code, 2)
				table.insert(step.elements, element)
			else
				error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
			end
			found = true
			return ""
		end)
	until(not found)
	if t ~= nil then
		local element = {}
		element.t = "TEXT"
		element.text = t
		table.insert(step.elements, element)
	end
end
