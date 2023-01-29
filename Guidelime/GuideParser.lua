local addonName, addon = ...
local L = addon.L

local HBD = LibStub("HereBeDragons-2.0")

addon.D = addon.D or {}; local D = addon.D     -- Data/Data
addon.FM = addon.FM or {}; local FM = addon.FM -- Data/FlightMasterDB
addon.DM = addon.DM or {}; local DM = addon.DM -- Data/MapDB
addon.QT = addon.QT or {}; local QT = addon.QT -- Data/QuestsTools
addon.SK = addon.SK or {}; local SK = addon.SK -- Data/SkillDB
addon.SP = addon.SP or {}; local SP = addon.SP -- Data/SpellDB
addon.F = addon.F or {}; local F = addon.F     -- Frames
addon.CG = addon.CG or {}; local CG = addon.CG -- CurrentGuide
addon.MW = addon.MW or {}; local MW = addon.MW -- MainWindow

addon.GP = addon.GP or {}; local GP = addon.GP -- GuideParser

--[[
codes:
 - N Name and level range of the guide [N(min)-(max)(name)]
 - NX Name and level range of the next guide proposed after finishing this [NX(min)-(max)(name)]
 - D details of the guide [D(details)]
 - GA guide applies to [GA(race),(class),(faction),(reputation),...]
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
 - A applies to [A(race),(class),(faction),(reputation),...]
 - O optional step
 - OC complete this step along with the next one
 - CI collect item
 - REP acquire reputation
 - GG ON/OFF enable/disable automatically generating goto coordinates
 - GL ON/OFF enable/disable automatically generating additional loc coordinates
 - UI use item
 - GI ON/OFF enable/disable automatically generating use item
 - TAR target npc
 - GT ON/OFF enable/disable automatically generating target
 - SP cast spell
 - LE learn skill/spell
 - SK skill up
]]

GP.codes = {
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
	COLLECT_ITEM = "CI",
	REPUTATION = "REP",
	USE_ITEM = "UI",
	AUTO_ADD_USE_ITEM = "GI",
	AUTO_ADD_TARGET = "GT",
	TARGET = "TAR",
	SPELL = "SP",
	LEARN = "LE",
	SKILL = "SK",
--deprecated
	COMPLETE_WITH_NEXT = "C", -- same as OC
	PICKUP = "QP", -- same as QA
	WORK = "QW", -- same as QC but optional
}

GP.codesReverse = {}
for k, v in pairs(GP.codes) do GP.codesReverse[v] = k end

function GP.getSuperCode(code)
	if code == "ACCEPT" then return "QUEST" end
	if code == "TURNIN" then return "QUEST" end
	if code == "COMPLETE" then return "QUEST" end
	if code == "SKIP" then return "QUEST" end
	if code == "PICKUP" then return "QUEST" end
	if code == "WORK" then return "QUEST" end
	return code
end

function GP.parseGuide(guide, group, strict, nameOnly)
	local time
	if addon.debugging then time = debugprofilestop() end
	
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
		guide.itemUpdateIndices = {}
		guide.autoAddCoordinatesGOTO = true
		guide.autoAddCoordinatesLOC = true
		guide.autoAddUseItem = true
		guide.autoAddTarget = true
		guide.unknownQuests = 0
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
		if not GP.parseLine(step, guide, strict, nameOnly) then return end
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

	if addon.debugging then print("LIME: parseGuide " .. guide.name .. (nameOnly and " names only" or "") .. " in " .. math.floor(debugprofilestop() - time) .. " ms") end
	
	if strict and guide.title == nil or guide.title == "" then 
		F.createPopupFrame(L.ERROR_GUIDE_HAS_NO_NAME):Show()
	else	
		return guide
	end
end

local function textFormatting(text, color)
	local url
	local formatted = text:gsub("(https?://[%w%./#%-%?=#]*)", function(u) if not url then url = u else url = url .. "\n" .. u end; return "|cFFAAAAAA" .. u .. "|r" end)
		:gsub("(www%.[%w%./#%-%?=#]*)", function(u) if not url then url = u elseif not url:find(u) then url = url .. "\n" .. u end; return "|cFFAAAAAA" .. u .. "|r" end)
		:gsub("%*([^\n\r]-)%*", (color or "|cFFFFD100") .. "%1|r")
		:gsub("%*%*","%*")
	local formattedInactive = formatted:gsub("|r", MW.COLOR_INACTIVE)
	return formatted, formattedInactive, url, formatted:gsub("%s", "") == ""
end

function GP.parseLine(step, guide, strict, nameOnly)
	if step.text == nil then return end
	if not string.match(step.text,"%-%-.*%-%-") then
		step.event, step.eval = string.match(step.text,"%-%-(.*)>>(.*)")
	end
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
			element.text, element.textInactive, element.url, element.empty = textFormatting(text, MW.COLOR_WHITE)
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
		element.t = GP.codesReverse[code:sub(1, 3)]
		if element.t == nil then element.t = GP.codesReverse[code:sub(1, 2)] end
		if element.t == nil then element.t = GP.codesReverse[code:sub(1, 1)] end
		if element.t == nil then 
			F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
			err = true
			return ""
		end		
		table.insert(step.elements, element)
		local tag = code:sub(#GP.codes[element.t] + 1):gsub("^%s*","")
		
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
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
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
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
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
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "GUIDE_APPLIES" then
			tag:upper():gsub(" ",""):gsub("([^,%d%-<>]+)%s*(%d*)([<>]?)%s*(%-?%d*)", function(c, value1, less, value2)
				if D.isClass(c) then
					if guide.classes == nil then guide.classes = {} end
					table.insert(guide.classes, D.getClass(c))
				elseif D.isRace(c) then
					if guide.races == nil then guide.races = {} end
					table.insert(guide.races, D.getRace(c))
				elseif D.isFaction(c) then
					guide.faction = D.getFaction(c)
				elseif c == "SP" and value1 ~= "" and value2 ~= "" then
					guide.spellReq = SP.getSpellById(value1)
					if less == "<" then
						guide.spellMax = tonumber(value2)
					else
						guide.spellMin = tonumber(value2)
					end
					-- if none specified spell rank 1 is required
					if guide.spellMin == nil and guide.spellMax == nil then guide.spellMin = 1 end
				elseif value1 ~= "" and (less ~= "" or value2 ~= "") then
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				elseif D.isReputation(c) then
					guide.reputation = D.getReputation(c)
					if less == "<" then
						guide.repMax = tonumber(value1 == "" and value2 or value1)
					else
						guide.repMin = tonumber(value1 == "" and value2 or value1)
					end
					-- if none specified friendly reputation is required
					if guide.repMin == nil and guide.repMax == nil then guide.repMin = 3000 end
				elseif SK.isSkill(c) then
					step.skillReq = SK.getSkill(c)
					if less == "<" then
						guide.skillMax = tonumber(value1 == "" and value2 or value1)
					else
						guide.skillMin = tonumber(value1 == "" and value2 or value1)
					end
					-- if none specified skill rank 1 is required
					if guide.skillMin == nil and guide.skillMax == nil then guide.skillMin = 1 end
				elseif SP.isSpell(c) then
					guide.spellReq = SP.getSpell(c)
					if less == "<" then
						guide.spellMax = tonumber(value1 == "" and value2 or value1)
					else
						guide.spellMin = tonumber(value1 == "" and value2 or value1)
					end
					-- if none specified spell rank 1 is required
					if guide.spellMin == nil and guide.spellMax == nil then guide.spellMin = 1 end
				else
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end)
		elseif GP.getSuperCode(element.t) == "QUEST" then
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
						F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					else
						element.questId = id
					end
				end
				if not nameOnly then
					if not QT.isQuestId(element.questId) then guide.unknownQuests = guide.unknownQuests + 1 end
					if QT.getQuestReplacement(element.questId) ~= nil then
						element.questId = QT.getQuestReplacement(element.questId)
					end
					if objective ~= "" then element.objective = tonumber(objective) end
					if title == "-" then
						element.title = ""
					-- here we used to have a feature to replace an english quest name with the localized name whenever the english name is written out in the guide
					-- this is disabled since right now there is not a way to get the non-localized quest name
					elseif title ~= "" --[[ and (not strict or DB.questsDB[element.questId] == nil or title ~= DB.questsDB[element.questId].name) ]] then
						element.title = title
					end
					if step.races == nil and QT.getQuestRaces(element.questId) ~= nil then 
						step.races = {}
						for i, r in pairs(QT.getQuestRaces(element.questId)) do step.races[i] = r end
					end
					if step.classes == nil and QT.getQuestClasses(element.questId) ~= nil then 
						step.classes = {}
						for i, r in pairs(QT.getQuestClasses(element.questId)) do step.classes[i] = r end
					end
					if step.faction == nil and QT.getQuestFaction(element.questId) ~= nil then 
						step.faction = QT.getQuestFaction(element.questId) 
					end
					if step.reputation == nil and QT.getQuestReputation(element.questId) ~= nil then
						step.reputation, step.repMin, step.repMax = QT.getQuestReputation(element.questId)
					end
					-- here we use internal data only intentionally
					-- guides should not parse with errors or not depending on data source used
					-- (i.e. omitting zone on the first zone is no longer supported for guides with quests not contained in internal data e.g. TBC)
					if QT.getQuestZone(element.questId) ~= nil and DM.mapIDs[QT.getQuestZone(element.questId)] ~= nil then 
						guide.currentZone = DM.mapIDs[QT.getQuestZone(element.questId)] 
					end
					if element.t ~= "SKIP" then 
						previousAutoStep = lastAutoStep
						lastAutoStep = element 
					end
				end
			end, 1)
			if c ~= 1 then
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif nameOnly then
			return ""
		elseif element.t == "AUTO_ADD_COORDINATES_GOTO" then
			if tag:upper():gsub(" ","") == "ON" then
				guide.autoAddCoordinatesGOTO = true
			elseif tag:upper():gsub(" ","") == "OFF" then
				guide.autoAddCoordinatesGOTO = false
			else
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "AUTO_ADD_COORDINATES_LOC" then
			if tag:upper():gsub(" ","") == "ON" then
				guide.autoAddCoordinatesGOTO = true
			elseif tag:upper():gsub(" ","") == "OFF" then
				guide.autoAddCoordinatesGOTO = false
			else
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "AUTO_ADD_TARGET" then
			if tag:upper():gsub(" ","") == "ON" then
				guide.autoAddTarget = true
			elseif tag:upper():gsub(" ","") == "OFF" then
				guide.autoAddTarget = false
			else
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "AUTO_ADD_USE_ITEM" then
			if tag:upper():gsub(" ","") == "ON" then
				guide.autoAddUseItem = true
			elseif tag:upper():gsub(" ","") == "OFF" then
				guide.autoAddUseItem = false
			else
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "APPLIES" then
			local classes, races = {}, {}
			tag:upper():gsub(" ",""):gsub("([^,%d%-<>]+)%s*(%d*)([<>]?)%s*(%-?%d*)", function(c, value1, less, value2)
				if D.isClass(c) then
					table.insert(classes, D.getClass(c))
				elseif D.isRace(c) then
					table.insert(races, D.getRace(c))
				elseif D.isFaction(c) then
					step.faction = D.getFaction(c)
				elseif c == "SP" and value1 ~= "" and value2 ~= "" then
					step.spellReq = SP.getSpellById(value1)
					if less == "<" then
						step.spellMax = tonumber(value2)
					else
						step.spellMin = tonumber(value2)
					end
					-- if none specified spell rank 1 is required
					if step.spellMin == nil and step.spellMax == nil then step.spellMin = 1 end
				elseif c == "IT" and value1 ~= "" then
					step.itemReq = tonumber(value1)
					-- note that itemMin is not "minimum number of items", but "greater than" (not "greater or equal"), analog itemMax
					if less == "<" then
						-- if value2 is not filled, assume we don't want that item at all, so <1
						step.itemMax = tonumber(value2) or 1
					elseif less == ">" then
						-- if value2 is not filled, assume we want at least one of these items, so >0
						step.itemMin = tonumber(value2) or 0
					end
					-- if neither min nor max is set, check for "exists", that is: at least one, so >0
					if step.itemMin == nil and step.itemMax == nil then
						step.itemMin = 0
					end
				elseif value1 ~= "" and (less ~= "" or value2 ~= "") then
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				elseif D.isReputation(c) then
					step.reputation = D.getReputation(c)
					if less == "<" then
						step.repMax = tonumber(value1 == "" and value2 or value1)
					else
						step.repMin = tonumber(value1 == "" and value2 or value1)
					end
					-- if none specified friendly reputation is required
					if step.repMin == nil and step.repMax == nil then step.repMin = 3000 end
				elseif SK.isSkill(c) then
					step.skillReq = SK.getSkill(c)
					if less == "<" then
						step.skillMax = tonumber(value1 == "" and value2 or value1)
					else
						step.skillMin = tonumber(value1 == "" and value2 or value1)
					end
					-- if none specified skill rank 1 is required
					if step.skillMin == nil and step.skillMax == nil then step.skillMin = 1 end
				elseif SP.isSpell(c) then
					step.spellReq = SP.getSpell(c)
					if less == "<" then
						step.spellMax = tonumber(value1 == "" and value2 or value1)
					else
						step.spellMin = tonumber(value1 == "" and value2 or value1)
					end
					-- if none specified spell rank 1 is required
					if step.spellMin == nil and step.spellMax == nil then step.spellMin = 1 end
				else
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end)
			if #classes > 0 then step.classes = classes end
			if #races > 0 then step.races = races end
		elseif element.t == "GOTO" then
			local _, c = tag:gsub("%s*(%d+%.?%d*)%s?,%s?(%d+%.?%d*)%s?,?%s?(%d*%.?%d*)%s?(.*)", function(x, y, radius, zone)
				element.x = tonumber(x)
				element.y = tonumber(y)
				if radius ~= "" then element.radius = tonumber(radius) end
				if element.radius == nil or element.radius == 0 then element.radius = CG.DEFAULT_GOTO_RADIUS end
				if zone ~= "" then guide.currentZone = DM.mapIDs[DM.getZoneName(zone)] end
				element.mapID = guide.currentZone
				if element.mapID == nil then 
					F.createPopupFrame(string.format(L.ERROR_CODE_ZONE_NOT_FOUND, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
				element.wx, element.wy, element.instance = HBD:GetWorldCoordinatesFromZone(element.x / 100, element.y / 100, element.mapID)
				step.hasGoto = true
			end, 1)
			if c ~= 1 then
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "LOC" then
			local _, c = tag:gsub("%s*(%d+%.?%d*)%s?,%s?(%d+%.?%d*)%s?(.*)", function(x, y, zone)
				element.x = tonumber(x)
				element.y = tonumber(y)
				if zone ~= "" then guide.currentZone = DM.mapIDs[DM.getZoneName(zone)] end
				element.mapID = guide.currentZone
				if element.mapID == nil then 
					F.createPopupFrame(string.format(L.ERROR_CODE_ZONE_NOT_FOUND, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
				element.wx, element.wy, element.instance = HBD:GetWorldCoordinatesFromZone(element.x / 100, element.y / 100, element.mapID)
				step.hasLoc = true
			end, 1)
			if c ~= 1 then
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
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
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "REPUTATION" then
			local _, c = tag:gsub("([^%d%-<>]+)%s*([<>]?)%s*(%-?%d*)%s*(.*)", function(c, less, value, text)
				if D.isReputation(c) then
					element.reputation = D.getReputation(c)
					if less == "<" then
						element.repMax = tonumber(value)
					else
						element.repMin = tonumber(value)
					end
					-- if none specified friendly reputation is required
					if element.repMin == nil and element.repMax == nil then element.repMin = 3000 end
					if text ~= "" then
						if text == "-" then text = "" end
						element.text, element.textInactive, _ = textFormatting(text:gsub("%s*(.*)", "%1", 1))
					end
					if element.text == nil then
						element.text = D.getLocalizedReputation(element.reputation)
						element.textInactive = element.text
					end
					lastAutoStep = element
				else
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end, 1)
			if c ~= 1 then
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "LEARN" then
			local _, c = tag:gsub("([^,%d%-]+)%s*(%d*)%s*(%d*)%s*(.*)", function(c, value1, value2, text)
				--if addon.debugging then print("LIME: LEARN", c, value1, value2, text) end
				c = c:upper():gsub(" ","")
				if c == "SP" and value1 ~= "" then
					element.spell = SP.getSpellById(tonumber(value1))
					element.spellMin = tonumber(value2) or 1
				elseif value2 ~= "" then
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				elseif SK.isSkill(c) then
					element.skill = SK.getSkill(c)
					if element.skill == "RIDING" then
						element.skillMin = tonumber(value1) or 1
					else
						element.maxSkillMin = tonumber(value1) or 1
					end
				elseif SP.isSpell(c) then
					element.spell = SP.getSpell(c)
					element.spellMin = tonumber(value1) or 1
				else
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
				if text ~= "" then
					if text == "-" then text = "" end
					element.text, element.textInactive, _ = textFormatting(text:gsub("%s*(.*)", "%1", 1))
				end
				if element.text == nil then
					if element.spell then
						element.text = SP.getLocalizedName(element.spell)
					elseif element.skill then
						element.text = SK.getLocalizedName(element.skill)
					end
					element.textInactive = element.text
				end
				lastAutoStep = element
			end, 1)
			if c ~= 1 then
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "SKILL" then
			local _, c = tag:gsub("([^,%d%-]+)%s*(%d*)%s*(.*)", function(c, value, text)
				--if addon.debugging then print("LIME: SKILL", c, value, text) end
				c = c:upper():gsub(" ","")
				if SK.isSkill(c) then
					element.skill = SK.getSkill(c)
					element.skillMin = tonumber(value) or 1
				else
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
				if text ~= "" then
					if text == "-" then text = "" end
					element.text, element.textInactive, _ = textFormatting(text:gsub("%s*(.*)", "%1", 1))
				end
				if element.text == nil then
					element.text = SK.getLocalizedName(element.skill)
					element.textInactive = element.text
				end
				lastAutoStep = element
			end, 1)
			if c ~= 1 then
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
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
				element.flightmaster = FM.getFlightmasterByPlace(tag, step.faction or guide.faction or D.faction)
				if element.flightmaster == nil then
--TODO: active this error check
--					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
--					err = true
					if addon.debugging then print("LIME: flight point not recognized -", tag) end
				end
			end
		elseif element.t == "COLLECT_ITEM" then
			local _, c = tag:gsub("%s*(%d+),?(%d*)%s*(.-)%s*$", function(id, qty, title)	
				if id ~= "" then
					element.itemId = tonumber(id)
					element.qty = tonumber(qty) or 1
					if title == "-" then
						element.title = ""
					elseif title ~= "" then
						element.title = title
					end
				else
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end, 1)
			if c ~= 1 then
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "USE_ITEM" then
			local _, c = tag:gsub("%s*(%d+)%s*(.-)%s*$", function(id, title)	
				if id ~= "" then
					element.useItemId = tonumber(id)
					if title == "-" then
						element.title = ""
					elseif title ~= "" then
						element.title = title
					end
				else
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end, 1)
			if c ~= 1 then
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "TARGET" then
			local _, c = tag:gsub("%s*(%d+)%s*(.-)%s*$", function(id, title)	
				if id ~= "" then
					element.targetNpcId = tonumber(id)
					if title == "-" then
						element.title = ""
					elseif title ~= "" then
						element.title = title
					end
				else
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end, 1)
			if c ~= 1 then
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
			end
		elseif element.t == "SPELL" then
			local _, c = tag:gsub("%s*([%w%d]+)%s*(.-)%s*$", function(spell, title)	
				element.spellId = tonumber(spell)
				element.spell = element.spellId and SP.getSpellById(element.spellId) or SP.getSpell(spell)
				if element.spellId or element.spell then
					if title == "-" then
						element.title = ""
					elseif title ~= "" then
						element.title = title
					end
				else
					F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
					err = true
				end
			end, 1)
			if c ~= 1 then
				F.createPopupFrame(string.format(L.ERROR_CODE_NOT_RECOGNIZED, guide.title or "", code, (step.line or "") .. " " .. step.text)):Show()
				err = true
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
		element.text, element.textInactive, element.url, element.empty = textFormatting(t, MW.COLOR_WHITE)
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
