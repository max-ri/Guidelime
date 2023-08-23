local addonName, addon = ...
local L = addon.L

local HBD = LibStub("HereBeDragons-2.0")

addon.D = addon.D or {}; local D = addon.D     -- Data/Data
addon.FM = addon.FM or {}; local FM = addon.FM -- Data/FlightMasterDB
addon.PT = addon.PT or {}; local PT = addon.PT -- Data/PositionTools
addon.QT = addon.QT or {}; local QT = addon.QT -- Data/QuestTools
addon.SK = addon.SK or {}; local SK = addon.SK -- Data/SkillDB
addon.SP = addon.SP or {}; local SP = addon.SP -- Data/SpellDB
addon.AB = addon.AB or {}; local AB = addon.AB -- ActionButtons
addon.CC = addon.CC or {}; local CC = addon.CC -- CustomCode
addon.EV = addon.EV or {}; local EV = addon.EV -- Events
addon.F = addon.F or {}; local F = addon.F     -- Frames
addon.M = addon.M or {}; local M = addon.M     -- Map
addon.MW = addon.MW or {}; local MW = addon.MW -- MainWindow
addon.GP = addon.GP or {}; local GP = addon.GP -- GuideParser
addon.QS = addon.QS or {}; local QS = addon.QS -- QuestScan

addon.CG = addon.CG or {}; local CG = addon.CG -- CurrentGuide

CG.DEFAULT_GOTO_RADIUS = 6
CG.GOTO_HYSTERESIS_FACTOR = 2

function CG.loadCurrentGuide(reset)

	local guide = addon.guides[GuidelimeDataChar.currentGuide]
	
	CG.quests = {}
	CG.questIds = {}

	if guide == nil then
		if addon.debugging then
			print("LIME: available guides:")
			for name in pairs(addon.guides) do
				print("LIME: " .. name)
			end
			print("LIME: guide \"" .. (GuidelimeDataChar.currentGuide or "") .. "\" not found")
		end
		GuidelimeDataChar.currentGuide = nil
		CG.currentGuide = {steps = {}}
		GuidelimeDataChar.completedSteps = {}
		QS.resetScannedQuests()
		return
	end
	
	if not CG.currentGuide or guide.group ~= CG.currentGuide.group then QS.resetScannedQuests() end

	CG.currentGuide = {}
	CG.currentGuide.name = GuidelimeDataChar.currentGuide
	CG.currentGuide.steps = {}
	CG.currentGuide.next = guide.next
	CG.currentGuide.group = guide.group
	
	if GuidelimeDataChar.guideSize[GuidelimeDataChar.currentGuide] ~= #guide.steps then
		GuidelimeDataChar.completedSteps = {}
		GuidelimeDataChar.guideSkip[GuidelimeDataChar.currentGuide] = {}
		GuidelimeDataChar.guideSize[GuidelimeDataChar.currentGuide] = #guide.steps
	end
	if GuidelimeDataChar.guideSkip[GuidelimeDataChar.currentGuide] == nil then
		GuidelimeDataChar.guideSkip[GuidelimeDataChar.currentGuide] = {}
	end
	if reset then
		GuidelimeDataChar.completedSteps = {}
	end
	--print(format(L.LOAD_MESSAGE, CG.currentGuide.name))
	guide = GP.parseGuide(guide, guide.group)
	if guide == nil then return end
	addon.guides[GuidelimeDataChar.currentGuide] = guide
	if guide.unknownQuests > 0 and select(4, GetBuildInfo()) >= 20000 and addon.dataSource == "DB" then
		CG.currentGuide.steps = {{elements = {{text = 
			(addon.QUESTIE.isDataSourceInstalled() or addon.CLASSIC_CODEX.isDataSourceInstalled()) and L.ERROR_TBC_DATA_SOURCE or L.ERROR_TBC_DATA_SOURCE_INSTALL
		}}}}
		CG.currentGuide.next = nil
		return
	end

	local time
	if addon.debugging then time = debugprofilestop() end

	local completed = QT.GetQuestsCompleted()
	local lastGoto
	for _, step in ipairs(guide.steps) do
		local loadLine = D.applies(step)
		local filteredElements = {}
		for _, element in ipairs(step.elements) do
			if not element.generated and
				((element.text ~= nil and element.text ~= "") or 
				(element.t ~= "TEXT" and element.t ~= "NAME" and element.t ~= "NEXT" and element.t ~= "DETAILS" and element.t ~= "GUIDE_APPLIES" and 
				element.t ~= "DOWNLOAD" and element.t ~= "AUTO_ADD_COORDINATES_GOTO" and element.t ~= "AUTO_ADD_COORDINATES_LOC" and element.t ~= "AUTO_ADD_USE_ITEM"))
			then
				table.insert(filteredElements, element)
			end
		end
		step.elements = filteredElements
		if #step.elements == 0 then loadLine = false end
		if loadLine then
			table.insert(CG.currentGuide.steps, step)
			step.index = #CG.currentGuide.steps
			local i = 1
			while i <= #step.elements do
				local element = step.elements[i]
				element.available = true

				if element.t == "ACCEPT" or element.t == "COMPLETE" or element.t == "TURNIN" or element.t == "XP" or element.t == "REPUTATION" or element.t == "SPELL" or element.t == "LEARN" or element.t == "SKILL" then
					if step.manual == nil then step.manual = false end
				elseif element.t == "TRAIN" or element.t == "VENDOR" or element.t == "REPAIR" or element.t == "SET_HEARTH" or element.t == "GET_FLIGHT_POINT" then
					step.manual = true
				elseif element.t == "GOTO" then
					if step.manual == nil then step.manual = false end
					if lastGoto ~= nil then lastGoto.lastGoto = false end
					element.lastGoto = true
					lastGoto = element
				end
				if element.questId ~= nil then
					if CG.quests[element.questId] == nil then CG.quests[element.questId] = {} end
					if not D.contains(CG.questIds, element.questId) then table.insert(CG.questIds, element.questId) end 
					CG.quests[element.questId].title = element.title
					CG.quests[element.questId].completed = completed[element.questId] ~= nil and completed[element.questId]
					CG.quests[element.questId].finished = CG.quests[element.questId].completed
					if QT.getQuestPrequests(element.questId) ~= nil then
						for _, id in ipairs(QT.getQuestPrequests(element.questId)) do
							if QT.getQuestApplies(id) then
								if CG.quests[id] == nil then CG.quests[id] = {} end
								CG.quests[id].completed = completed[id] ~= nil and completed[id]
								if CG.quests[id].followup == nil then CG.quests[id].followup = {} end
								table.insert(CG.quests[id].followup, element.questId)
							end
						end
					end
					if CG.quests[element.questId].lastStep == nil then CG.quests[element.questId].lastStep = {} end
					CG.quests[element.questId].lastStep[element.t] = element
					if element.t == "COMPLETE" and CG.quests[element.questId].objectives == nil then
						CG.quests[element.questId].objectives = {}
						local objectives = QT.getQuestObjectives(element.questId)
						if objectives ~= nil then
							for i, objective in ipairs(objectives) do
								CG.quests[element.questId].objectives[i] = {type = objective.type, desc = objective.names[1]}
							end
						end
					end
					if guide.autoAddCoordinatesGOTO and (GuidelimeData.showMapMarkersGOTO or GuidelimeData.showMinimapMarkersGOTO) and not step.hasGoto and not step.optional then
						if CG.addElement(CG.updatePosElement(PT.getQuestPosition(element.questId, element.t, element.objective, lastGoto), {t = "GOTO"}), element) then
							i = i + 1 
						end
					end
					if element.races ~= nil or element.classes ~= nil then
						CG.addElement({t = "APPLIES", races = element.races, classes = element.classes, faction = element.faction}, element)
						i = i + 1
					end
				elseif element.t == "FLY" then
					if guide.autoAddCoordinatesGOTO and (GuidelimeData.showMapMarkersGOTO or GuidelimeData.showMinimapMarkersGOTO) and not step.hasGoto and not step.optional then
						CG.addElement({t = "GOTO", specialLocation = "NEAREST_FLIGHT_POINT", radius = CG.DEFAULT_GOTO_RADIUS}, element)
						i = i + 1
					end						
				elseif element.t == "GET_FLIGHT_POINT" then
					if guide.autoAddCoordinatesGOTO and (GuidelimeData.showMapMarkersGOTO or GuidelimeData.showMinimapMarkersGOTO) and not step.hasGoto and not step.optional then
						if CG.addElement(CG.updatePosElement(FM.getFlightPoint(element.flightmaster), {t = "GOTO"}), element) then
							i = i + 1 
						end
					end						
				elseif element.t == "COLLECT_ITEM" then
					if #guide.itemUpdateIndices == 0 or guide.itemUpdateIndices[#guide.itemUpdateIndices] ~= step.index then
						table.insert(guide.itemUpdateIndices,step.index)
					end
					if step.manual == nil then step.manual = false end
					if guide.autoAddCoordinatesGOTO and (GuidelimeData.showMapMarkersGOTO or GuidelimeData.showMinimapMarkersGOTO) and 
						not step.hasGoto and not step.optional and not step.targetElement then
						if CG.addElement(CG.updatePosElement(PT.getItemPosition(element.itemId, lastGoto), {t = "GOTO"}), element) then
							i = i + 1 
						end
					end
				elseif element.t == "USE_ITEM" then
					if not element.generated then step.useItemElement = true end
				elseif element.t == "TARGET" then
					if not element.generated then 
						step.targetElement = true
						if guide.autoAddCoordinatesGOTO and (GuidelimeData.showMapMarkersGOTO or GuidelimeData.showMinimapMarkersGOTO) and not step.hasGoto and not step.optional then
							if CG.addElement(CG.updatePosElement(PT.getNPCPosition(element.targetNpcId, lastGoto), {t = "GOTO"}), element) then	
								i = i + 1 
							end
						end
					end
				elseif guide.autoAddUseItem and not step.useItemElement and element.t == "HEARTH" then
					CG.addElement({t = "USE_ITEM", useItemId = 6948, title = ""}, element, 1)
					i = i + 1
				end
				i = i + 1
			end
			if step.manual == nil then step.manual = true end
			if step.completeWithNext == nil then step.completeWithNext = false end
			if step.completeWithNext then step.optional = true end
			if step.optional == nil then step.optional = false end
			step.skip = GuidelimeDataChar.guideSkip[CG.currentGuide.name][#CG.currentGuide.steps] or GuidelimeDataChar.completedSteps[#CG.currentGuide.steps] or false
			step.active = false
			step.wasActive = false
			step.completed = false
			step.available = true
		end
	end
	if addon.debugging then print("LIME: loadCurrentGuide " .. math.floor(debugprofilestop() - time) .. " ms") end

	CC.parseCustomLuaCode()
	
	QS.scanGuideQuests(guide.name)
end

function CG.addElement(newElement, element, offset, keepIndex)
	if not newElement then return end
	newElement.step = element.step
	newElement.attached = element
	newElement.generated = true
	newElement.available = true
	table.insert(element.step.elements, element.index + (offset or 0), newElement)
	if not keepIndex then
		for j = element.step.index + (offset or 0), #element.step.elements do
			element.step.elements[j].index = j
		end
	else
		newElement.index = element.index + (offset or 0)
	end
	if newElement.t == "GOTO" then
		if lastGoto ~= nil and lastGoto.step.line == element.step.line then lastGoto.lastGoto = false end
		newElement.lastGoto = true
		lastGoto = newElement
	end
	return newElement
end
	
function CG.updatePosElement(pos, element)
	if not pos or not pos.x then return end 
	if not element then element = {} end
	for k,v in pairs(pos) do element[k] = v end
	element.radius = element.radius or CG.DEFAULT_GOTO_RADIUS
	return element
end

function CG.loadStepUseItems(i, recheck)
	local step = CG.currentGuide.steps[i]
	if addon.guides[GuidelimeDataChar.currentGuide].autoAddUseItem and GuidelimeDataChar.showUseItemButtons and not step.useItemElement then
		local j = 1
		local previousUseItems = {}
		while j <= #step.elements do
			local element = step.elements[j]
			if recheck and element.t == "USE_ITEM" then
				table.insert(previousUseItems, element.useItemId)
			elseif element.questId ~= nil and element.available then
				if element.t == "ACCEPT" and not recheck then
					local itemId = QT.getItemStartingQuest(element.questId)
					if itemId then
						CG.addElement({t = "USE_ITEM", useItemId = itemId, title = ""}, element)
						j = j + 1
					end
				elseif element.t == "COMPLETE" or element.t == "TURNIN" then
					local items = QT.getUsableQuestItems(element.questId)
					if items then
						for _, itemId in ipairs(items) do
							if QT.questItemIsFor[itemId] == element.t and not D.contains(previousUseItems, itemId) then
								CG.addElement({t = "USE_ITEM", useItemId = itemId, title = ""}, element)
								j = j + 1
							end
						end
					end
				end
			end
			j = j + 1
		end
	end
end

local function loadStepOnActivation(i)
	local time
	if addon.debugging then time = debugprofilestop() end
	local step = CG.currentGuide.steps[i]
	if addon.guides[GuidelimeDataChar.currentGuide].autoAddCoordinatesLOC and (GuidelimeData.showMapMarkersLOC or GuidelimeData.showMinimapMarkersLOC) and not step.hasLoc then
		local j = 1
		while j <= #step.elements do
			local element = step.elements[j]
			if element.questId ~= nil and element.available then
				local positions = PT.getQuestPositionsLimited(element.questId, element.t, element.objective, GuidelimeData.maxNumOfMarkersLOC, true)
				if positions ~= nil then
					local objectives = QT.getQuestObjectives(element.questId, element.t)						
					for _, pos in ipairs(positions) do
						local locElement = CG.addElement(CG.updatePosElement(pos, {t = "LOC"}),	element, 0, true)
						if element.t == "COMPLETE" then
							locElement.markerTyp = objectives and pos.objectives and pos.objectives[1] and objectives[pos.objectives[1]] and objectives[pos.objectives[1]].type or "LOC"
						else
							locElement.markerTyp = element.t
						end
						j = j + 1
					end
					for k = j, #step.elements do
						step.elements[k].index = k
					end
				end
			elseif element.t == "COLLECT_ITEM" and not step.targetElement then
				local positions = PT.getItemPositionsLimited(element.itemId, GuidelimeData.maxNumOfMarkersLOC, true)
				if positions ~= nil then
					for _, pos in ipairs(positions) do
						CG.addElement(CG.updatePosElement(pos, {t = "LOC", markerTyp = "item"}), element, 0, true)
						j = j + 1
					end
					for k = j, #step.elements do
						step.elements[k].index = k
					end
				end
			elseif element.t == "TARGET" and not element.generated then
				local positions = PT.getNPCPositionsLimited(element.targetNpcId, GuidelimeData.maxNumOfMarkersLOC, true)
				if positions ~= nil then
					for _, pos in ipairs(positions) do
						CG.addElement(CG.updatePosElement(pos, {t = "LOC", markerTyp = "npc"}), element, 0, true)
						j = j + 1
					end
					for k = j, #step.elements do
						step.elements[k].index = k
					end
				end
			end
			j = j + 1
		end
	end
	if addon.guides[GuidelimeDataChar.currentGuide].autoAddTarget and GuidelimeDataChar.showTargetButtons and not step.targetElement then
		local j = 1
		while j <= #step.elements do
			local element = step.elements[j]
			if element.questId ~= nil and element.available then
				local npcs = QT.getQuestNPCs(element.questId, element.t, element.objective)
				if npcs then
					for _, npc in ipairs(npcs) do
						CG.addElement({t = "TARGET", targetNpcId = npc.id, title = "", objectives = npc.objectives}, element)
						j = j + 1
					end
				end
			end
			j = j + 1
		end
	end
	CG.loadStepUseItems(i)
	C_Timer.After(1, function()
		if addon.debugging then print("LIME: recheck use items for step", i) end
		CG.loadStepUseItems(i, true)
		AB.updateUseItemButtons()
	end)
	if addon.debugging then print("LIME: loadStepOnActivation " .. i .. " " .. math.floor(debugprofilestop() - time) .. " ms") end
end

function CG.getQuestText(id, t, title, colored)
	local q = ""
	if (GuidelimeData.showQuestLevels or GuidelimeData.showMinimumQuestLevels) then
		q = q .. "["
		if GuidelimeData.showMinimumQuestLevels then
			q = q .. MW.getRequiredLevelColor(QT.getQuestMinimumLevel(id)) .. (QT.getQuestMinimumLevel(id) or "")
		end
		if GuidelimeData.showMinimumQuestLevels and GuidelimeData.showQuestLevels then
			if colored == true then
				q = q .. "|r"
			else
				q = q .. MW.COLOR_INACTIVE
			end
			q = q .. "-"
		end
		if GuidelimeData.showQuestLevels then
			q = q .. MW.getLevelColor(QT.getQuestLevel(id)) .. (QT.getQuestLevel(id) or "")
			if QT.getQuestType(id) == "Dungeon" then 
				q = q .. "D" 
			elseif QT.getQuestType(id) == "Raid" then 
				q = q .. "R" 
			elseif QT.getQuestType(id) == "Elite" then 
				q = q .. "+" 
			elseif QT.getQuestType(id) == "Group" then 
				q = q .. "P" 
			end
		end
		if colored == true then
			q = q .. "|r"
		else
			q = q .. MW.COLOR_INACTIVE
		end
		q = q .. "]"
	end
	if colored == nil or colored then q = q .. GuidelimeData["fontColor" .. (t or "ACCEPT")] end
	q = q .. (title or QT.getQuestNameById(id) or id)
	if GuidelimeData.showQuestIds then q = q .. "(#" .. id .. ")" end
	if colored == nil or colored then q = q .. "|r" end
	return q
end

local function getSkipQuests(id, skipQuests, newSkipQuests)
	if newSkipQuests == nil then newSkipQuests = {} end
	if CG.quests[id] ~= nil and CG.quests[id].followup ~= nil and #CG.quests[id].followup > 0 then
		for _, fid in ipairs(CG.quests[id].followup) do
			if CG.currentGuide.unavailableQuests[fid] == nil and skipQuests[fid] == nil then
				table.insert(newSkipQuests, fid)
				skipQuests[fid] = true
				getSkipQuests(fid, skipQuests, newSkipQuests)
			end
		end
	end
	return newSkipQuests
end

function CG.getQuestObjectiveIcon(id, objective, showItemIcon)
	if CG.quests[id] == nil or CG.quests[id].objectives == nil then return "" end
	local a, b = objective, objective
	if objective == nil then a = 1; b = #CG.quests[id].objectives end
	local text = ""
	local icons = {}
	for i = a, b do
		local o = CG.quests[id].objectives[i]
		if o ~= nil and not o.done then
			local type = o.type
			if type == nil or addon.icons[type] == nil then type = "COMPLETE" end
			local _,icon
			if type == "item" and showItemIcon then
				local objectives = QT.getQuestObjectives(id)
				if objectives ~= nil and objectives[i] ~= nil and objectives[i].type == 'item' then
					icon = GetItemIcon(objectives[i].ids.item[1])
				end
			end
			if icon == nil and icons[type] == nil then
				icon = addon.icons[type]
				icons[type] = true
			end
			if icon ~= nil then text = text .. "|T" .. icon .. ":12|t" end
		end
	end
	return text
end	

function CG.getQuestObjectiveText(id, objectives, indent, npcId, objectId)
	local objectiveList = QT.getQuestObjectives(id)
	if objectiveList == nil then return "" end
	if objectives == true then
		objectives = {}; for i = 1, #objectiveList do objectives[i] = i end
	end
	local text = ""
	if npcId ~= nil and (#objectives ~= 1 or objectiveList[objectives[1]] == nil or (objectiveList[objectives[1]].type ~= "npc" and objectiveList[objectives[1]].type ~= "monster")) then
		if QT.getNPCName(npcId) ~= nil then
			text = (indent or "") .. "|T" .. addon.icons.monster .. ":12|t" .. QT.getNPCName(npcId)
		end
	elseif objectId ~= nil and (#objectives ~= 1 or objectiveList[objectives[1]] == nil or objectiveList[objectives[1]].type ~= "object") then
		if QT.getObjectName(objectId) ~= nil then
			text = (indent or "") .. "|T" .. addon.icons.object .. ":12|t" .. QT.getObjectName(objectId)
		end
	end
	for _, i in ipairs(objectives) do
		local o
		if CG.quests[id] ~= nil and CG.quests[id].logIndex ~= nil and CG.quests[id].objectives ~= nil then	o = CG.quests[id].objectives[i] end
		if o == nil and objectiveList[i] ~= nil then
			if text ~= "" then text = text .. "\n" end
			local type = objectiveList[i].type
			if type == nil or addon.icons[type] == nil then type = "COMPLETE" end
			text = text	.. (indent or "") .. "- " .. "|T" .. addon.icons[type] .. ":12|t" .. (objectiveList[i].names[1] or "")
		elseif o ~= nil and not o.done and o.desc ~= nil and o.desc ~= "" then
			local icon = CG.getQuestObjectiveIcon(id, i, true)
			if text ~= "" then text = text .. "\n" end
			text = text .. (indent or "") .. "- " .. icon .. o.desc
		end
	end
	return text
end

function CG.getQuestIcon(questId, t, objective, finished)
	if t == "ACCEPT" and (QT.getQuestMinimumLevel(questId) or 0) > D.level then
		return "|T" .. addon.icons.ACCEPT_UNAVAILABLE .. ":12|t"
	elseif t == "TURNIN" and not finished then
		return "|T" .. addon.icons.TURNIN_INCOMPLETE .. ":12|t"
	elseif t == "COMPLETE" then
		return CG.getQuestObjectiveIcon(questId, objective)
	else
		return "|T" .. (addon.icons[t] or addon.icons.COMPLETE) .. ":12|t"
	end
end

function CG.getElementIcon(element, prevElement)
	if element.completed and element.t ~= "GOTO" then
		return "|T" .. addon.icons.COMPLETED .. ":12|t"
	elseif element.available == false then
		return "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
	elseif GP.getSuperCode(element.t) == "QUEST" then
		return CG.getQuestIcon(element.questId, element.t, element.objective, element.finished)
	elseif element.t == "LOC" or element.t == "GOTO" then
		if not GuidelimeData.showMapMarkersInGuide then
			return ""
		elseif element.t == "LOC" and ((prevElement ~= nil and prevElement.t == "LOC") or (element.markerTyp ~= nil)) then
			-- Dont show an icon for subsequent LOC elements. Also dont show LOC for quest steps since there would be the same icon twice
			return ""
		elseif element.mapIndex == 0 and M.arrowFrame ~= nil and GuidelimeDataChar.showArrow then
			return M.getArrowIconText()
		elseif element.mapIndex ~= nil then
			return M.getMapMarkerText(element)
		end
	elseif element.t == "SPELL" or element.t == "LEARN" or element.t == "SKILL" then
		if element.spellId then
			return "|T" .. (select(3, GetSpellInfo(element.spellId)) or addon.icons[element.t]) .. ":12|t"
		elseif element.spell and SP.spells[element.spell] then
			return "|T" .. (SP.spells[element.spell].icon or addon.icons[element.t]) .. ":12|t"
		elseif element.skill then
			return "|T" .. SK.getSkillIcon(element.skill) .. ":12|t"
		end
	elseif element.t == "USE_ITEM" and element.title ~= "" then
		return "|T" .. (GetItemIcon(element.useItemId) or addon.icons.item) .. ":12|t"
	elseif element.t == "APPLIES" then
		local text = ""
		if D.contains(element.races, D.race) and element.faction == nil then
			--text = text .. "|T" .. addon.icons[D.race:upper()] .. ":12|t"
			text = text .. D.getRaceIconText(D.race, D.sex) 
		end
		if D.contains(element.classes, D.class) then
			--text = text .. "|T" .. addon.icons[D.class:upper()] .. ":12|t"
			text = text .. D.getClassIconText(D.class)
		end
		return text
	elseif addon.icons[element.t] ~= nil and (not prevElement or element.t ~= prevElement.t) then
		return "|T" .. addon.icons[element.t] .. ":12|t"
	end
	return ""
end

function CG.getStepText(step)
	local text = ""
	local tooltip = ""
	local skipTooltip = ""
	local skipText = ""
	local skipQuests = {}
	local trackQuest = {}
	local itemText = ""

	if GuidelimeData.showLineNumbers and step.line ~= nil then text = text .. step.line .. " " end
	if not step.active then
		text = text .. MW.COLOR_INACTIVE
	elseif step.manual then
		skipTooltip = L.STEP_MANUAL
	else
		skipTooltip = L.STEP_SKIP
	end
	local prevElement
	for _, element in ipairs(step.elements) do
		element.textStartPos = #text
		text = text .. CG.getElementIcon(element, prevElement)
		if element.available and not element.completed and element.t == "ACCEPT" and (QT.getQuestMinimumLevel(element.questId) or 0) > D.level then
			if tooltip ~= "" then tooltip = tooltip .. "\n" end
			local q = CG.getQuestText(element.questId, element.t)
			tooltip = tooltip .. L.QUEST_REQUIRED_LEVEL:format(q, QT.getQuestMinimumLevel(element.questId))
		end
		if element.text ~= nil then
			if step.active or element.textInactive == nil then
				text = text .. element.text
			else
				text = text .. element.textInactive
			end
		end
		if GP.getSuperCode(element.t) == "QUEST" then
			text = text .. CG.getQuestText(element.questId, element.t, element.title, step.active)
			if element.available and not element.completed then
				if CG.quests[element.questId].lastStep[element.t] == element then
					local newSkipQuests = getSkipQuests(element.questId, skipQuests)
					if #newSkipQuests > 0 then
						if skipText ~= "" then skipText = skipText .. "\n\n" end
						if #newSkipQuests == 1 then
							skipText = skipText .. L.STEP_FOLLOWUP_QUEST:format(CG.getQuestText(element.questId, element.t)) ..":\n"
						else
							skipText = skipText .. L.STEP_FOLLOWUP_QUESTS:format(CG.getQuestText(element.questId, element.t)) ..":\n"
						end
						for _, id in ipairs(newSkipQuests) do
							skipText = skipText .. "\n|T" .. addon.icons.UNAVAILABLE .. ":12|t" .. CG.getQuestText(id)
						end
						if #newSkipQuests == 1 then
							skipText = skipText .. "\n\n" .. L.STEP_FOLLOWUP_QUEST_CONT:format(CG.getQuestText(element.questId, element.t))
						else
							skipText = skipText .. "\n\n" .. L.STEP_FOLLOWUP_QUESTS_CONT:format(CG.getQuestText(element.questId, element.t))
						end
					end
				end
				if element.t == "COMPLETE" or element.t == "TURNIN" then
					if element.objective == nil then
						trackQuest[element.questId] = true
					elseif trackQuest[element.questId] ~= true then
						if trackQuest[element.questId] == nil then trackQuest[element.questId] = {} end
						if not D.contains(trackQuest[element.questId], element.objective) then table.insert(trackQuest[element.questId], element.objective) end
					end
				end
			end
		elseif element.t == "COLLECT_ITEM" then
			local name,_,rarity = EV.GetItemInfo(element.itemId)
			local colour = ITEM_QUALITY_COLORS[1].hex
			if name then
				if step.active then
					colour = ITEM_QUALITY_COLORS[rarity].hex
					local iconId = GetItemIcon(element.itemId)
					local icon = "|T" .. iconId .. ":12|t"
					local count = GetItemCount(element.itemId)
					if count >= element.qty then
						count = element.qty
					end
					itemText = string.format("%s\n    - %s%s: %d/%d",itemText,icon,name,count,element.qty)
				end
			end
			name = element.title or name
			if name and name ~= "" then
				if step.active then
					text = text .. colour .. name .. "|r"
				else
					text = text .. name
				end
			end
		elseif element.t == "USE_ITEM" and element.title ~= "" then
			local name,_,rarity = EV.GetItemInfo(element.useItemId)
			local colour = ITEM_QUALITY_COLORS[1].hex
			if name then
				if step.active then
					colour = ITEM_QUALITY_COLORS[rarity].hex
				end
			end
			name = element.title or name
			if name and name ~= "" then
				if step.active then
					text = text .. colour .. name .. "|r"
				else
					text = text .. name
				end
			end
		elseif element.t == "TARGET" and element.title ~= "" then
			local npc = QT.getNPCName(element.targetNpcId)
			if element.targetButton and element.targetButton.npc == npc then
				text = text .. AB.getTargetButtonIconText(element.targetButton.index)
			end
			local name = element.title or npc
			if name and name ~= "" then
				if step.active then
					text = text .. MW.COLOR_WHITE .. name .. "|r"
				else
					text = text .. name
				end
			end
		elseif element.t == "SPELL" and element.title ~= "" then
			local name = element.title or (GetSpellInfo(element.spellId or SP.getSpellId(element.spell)))
			if name and name ~= "" then
				if step.active then
					text = text .. MW.COLOR_WHITE .. name .. "|r"
				else
					text = text .. name
				end
			end
		elseif element.t == "SKILL" and step.active then
			local rank, max = SK.getSkillRank(element.skill)
			if rank then
				itemText = string.format("\n    - %d/%d", rank, element.skillMin)
			end
		end
		if element.textStartPos == #text then element.empty = true end
		if element.empty == nil or not element.empty then prevElement = element end
	end
	if step.skippedQuests ~= nil and #step.skippedQuests > 0 then
		if tooltip ~= "" then tooltip = tooltip .. "\n" end
		tooltip = tooltip .. "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
		tooltip = tooltip .. L.SKIPPING_QUEST
	elseif step.missingPrequests ~= nil and #step.missingPrequests > 0 then
		if tooltip ~= "" then tooltip = tooltip .. "\n" end
		tooltip = tooltip .. "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
		if #step.missingPrequests == 1 then
			tooltip = tooltip .. L.MISSING_PREQUEST
		else
			tooltip = tooltip .. L.MISSING_PREQUESTS
		end
		for _, id in ipairs(step.missingPrequests) do
			tooltip = tooltip .. " " ..CG.getQuestText(id)
		end
	end
	for id, objectives in pairs(trackQuest) do
		if step.active then
			text = text .. "\n" .. CG.getQuestObjectiveText(id, objectives, "    ")
		else
			if tooltip ~= "" then tooltip = tooltip .. "\n" end
			tooltip = tooltip .. CG.getQuestObjectiveText(id, objectives)
		end
	end
	text = text .. itemText
	return text, tooltip, skipText, skipTooltip
end

function CG.updateStepText(i)
	local step = CG.currentGuide.steps[i]
	if MW.mainFrame.steps == nil or MW.mainFrame.steps[i] == nil or MW.mainFrame.steps[i].textBox == nil or not MW.mainFrame.steps[i].visible then return end
	local text, tooltip, skipText, skipTooltip = CG.getStepText(step)
	if text ~= MW.mainFrame.steps[i].textBox:GetText() then
		MW.mainFrame.steps[i].textBox:SetText(text)
	end
	MW.mainFrame.steps[i].skipText = skipText
	if GuidelimeData.showTooltips then
		MW.mainFrame.steps[i].textBox.tooltip = tooltip
		MW.mainFrame.steps[i].tooltip = skipTooltip
	else
		MW.mainFrame.steps[i].textBox.tooltip = nil
		MW.mainFrame.steps[i].tooltip = nil
	end
end

local function updateStepCompletion(i, completedIndexes)
	local step = CG.currentGuide.steps[i]

	local autoCompleteStep
	local wasCompleted = step.completed
	if not step.manual then	step.completed = nil end
	step.itemsCollected = nil
	for _, element in ipairs(step.elements) do
		if element.t == "ACCEPT" then
			element.completed = CG.quests[element.questId].completed or CG.quests[element.questId].logIndex ~= nil
			if step.completed == nil or not element.completed then step.completed = element.completed end
			autoCompleteStep = true
		elseif element.t == "COMPLETE" then
			element.completed =
				CG.quests[element.questId].completed or
				CG.quests[element.questId].finished or
				(element.objective ~= nil and 
					CG.quests[element.questId].objectives ~= nil and 
					CG.quests[element.questId].objectives[element.objective] ~= nil and
					CG.quests[element.questId].objectives[element.objective].done)
			if step.completed == nil or not element.completed then step.completed = element.completed end
			autoCompleteStep = true
		elseif element.t == "TURNIN" then
			element.finished = CG.quests[element.questId].finished
			element.completed = CG.quests[element.questId].completed
			if step.completed == nil or not element.completed then step.completed = element.completed end
			autoCompleteStep = true
		elseif element.t == "XP" then
			element.completed = element.level <= D.level
			if element.xp ~= nil and element.level == D.level then
				if element.xpType == "REMAINING" then
					if element.xp < (D.xpMax - D.xp) then element.completed = false end
				elseif element.xpType == "PERCENTAGE" then
					if D.xpMax == 0 or element.xp > (D.xp / D.xpMax) then element.completed = false end
				else
					if element.xp > D.xp then element.completed = false end
				end
			end
			if step.completed == nil or not element.completed then step.completed = element.completed end
			autoCompleteStep = true
		elseif element.t == "REPUTATION" then
			element.completed = D.isRequiredReputation(element.reputation, element.repMin, element.repMax)
			if step.completed == nil or not element.completed then step.completed = element.completed end
			autoCompleteStep = true
		elseif element.t == "LEARN" or element.t == "SKILL" then
			if element.spell then
				element.completed = SP.isRequiredSpell(element.spell, element.spellMin, element.spellMax)
			elseif element.skill then
				element.completed = SK.isRequiredSkill(element.skill, element.skillMin, nil, element.maxSkillMin)
			end
			if step.completed == nil or not element.completed then step.completed = element.completed end
			autoCompleteStep = true
		elseif element.t == "COLLECT_ITEM" and step.active then
			if (element.qty > 0 and GetItemCount(element.itemId) >= element.qty) or (element.qty == 0 and GetItemCount(element.itemId) == 0) then
				element.completed = true
				if step.itemsCollected == nil then step.itemsCollected = true end
			else
				element.completed = false
				step.itemsCollected = false
			end
			if step.completed == nil or not element.completed then step.completed = element.completed end
			autoCompleteStep = true
		end
	end
	-- check goto last so that go to does not matter when all other objectives are completed
	local nonGotoCompleted = step.completed or wasCompleted
	for _, element in ipairs(step.elements) do
		if element.t == "GOTO"  then
			--if addon.debugging then print("LIME : zone coordinates", x, y, element.mapID) end
			if nonGotoCompleted then--step.skip check was redundant, this fixes a bug where you were unable to manually reactivate skipped goto steps
				element.completed = true
			elseif element.attached ~= nil and element.attached.completed then
				element.completed = true
			elseif element.completed and not element.lastGoto and element.attached == nil then
				-- do not reactivate unless it is the last goto of the step
			elseif D.wx ~= nil and D.wy ~= nil and element.wx ~= nil and element.wy ~= nil and D.instance == element.instance and D.isAlive() and step.active then
				local radius = element.radius * element.radius
				-- add some hysteresis
				if element.completed then radius = radius * CG.GOTO_HYSTERESIS_FACTOR end
				element.completed = (D.wx - element.wx) * (D.wx - element.wx) + (D.wy - element.wy) * (D.wy - element.wy) <= radius
			else
				element.completed = false
			end
			if step.completed == nil or not element.completed then step.completed = element.completed end
		end
	end
	if step.completed == nil then step.completed = step.completeWithNext and wasCompleted end
	
	--skips the completeWithNext check if the step is already complete, fixing a bug where the step persisted even when all elements were complete
	if not step.completed and i < #CG.currentGuide.steps and step.completeWithNext ~= nil and step.completeWithNext then
		local nstep = CG.currentGuide.steps[i + 1]
		local c = nstep.completed or nstep.skip
		if step.completed ~= c then
			--if addon.debugging then print("LIME: complete with next ", i - 1, c, nstep.skip, nstep.available) end
			step.completed = c
		end
	end

	if step.completed ~= wasCompleted and not D.contains(completedIndexes, i) then
		if not autoCompleteStep then
			GuidelimeDataChar.completedSteps[step.index] = step.completed
		end
		table.insert(completedIndexes, i)
	end
end

local function updateStepAvailability(i, changedIndexes, scheduled)
	local step = CG.currentGuide.steps[i]
	local wasAvailable = step.available
	step.available = nil
	step.missingPrequests = {}
	step.skippedQuests = {}
	for _, element in ipairs(step.elements) do
		element.available = true
		if element.t == "ACCEPT" then
			if not element.completed then
				local missingPrequests = QT.getMissingPrequests(element.questId, function(id) return CG.quests[id].completed or scheduled.TURNIN[id] end)
				if #missingPrequests > 0 then
					element.available = false
					CG.currentGuide.unavailableQuests[element.questId] = true
					for _, id in ipairs(missingPrequests) do
						if not D.contains(step.missingPrequests, id) then
							table.insert(step.missingPrequests, id)
						end
					end
				end
			end
		elseif element.t == "COMPLETE" or element.t == "TURNIN" then
			if not scheduled.ACCEPT[element.questId] and not element.completed and CG.quests[element.questId].logIndex == nil then
				element.available = false
				if scheduled.SKIP[element.questId] then
					if not D.contains(step.skippedQuests, element.questId) then
						table.insert(step.skippedQuests, element.questId)
					end
				else
					if not D.contains(step.missingPrequests, element.questId) then
						table.insert(step.missingPrequests, element.questId)
					end
				end
			end
		end
		if element.t == "ACCEPT" or element.t == "COMPLETE" or element.t == "TURNIN" then
			if not step.skip and element.available then
				scheduled[element.t][element.questId] = true
			elseif not scheduled[element.t][element.questId] and step.skip and not element.completed and CG.quests[element.questId].lastStep[element.t] == element then
				element.available = false
				scheduled.SKIP[element.questId] = true
			end
			if not element.completed then step.available = step.available or false or element.available	end
		elseif element.t == "XP" or element.t == "REPUTATION" or element.t == "LEARN" or element.t == "SKILL" then
			if not element.completed then step.available = true end			
		end
	end
	if step.available == nil then step.available = true end
	if step.manual and not step.completed then step.available = true end

	if step.available ~= wasAvailable and not D.contains(changedIndexes, i) then
		table.insert(changedIndexes, i)
	end
end

local function updateStepsCompletion(changedIndexes)
	--if addon.debugging then print("LIME: update steps completion") end
	CG.currentGuide.unavailableQuests = {}
	repeat
		local numNew = #changedIndexes
		local scheduled = {ACCEPT = {}, COMPLETE = {}, TURNIN = {}, SKIP = {}}
		for i, step in ipairs(CG.currentGuide.steps) do
			updateStepCompletion(i, changedIndexes)
			if step.itemsCollected and step.completed then
				step.skip = true --once all items are collected, don't re-enable the step again if you lose the item later
			end
			updateStepAvailability(i, changedIndexes, scheduled)
			if MW.mainFrame.steps ~= nil and MW.mainFrame.steps[i] ~= nil and MW.mainFrame.steps[i].visible then
				MW.mainFrame.steps[i]:SetChecked(step.completed or step.skip)
				MW.mainFrame.steps[i]:SetEnabled(not step.completed or step.skip)
			end
		end
	until(numNew == #changedIndexes)
	--if addon.debugging then print("LIME: changed", #changedIndexes) end
end

function CG.stepIsVisible(step)
	return ((not step.completed and (not step.skip or not step.available)) or GuidelimeDataChar.showCompletedSteps) and
			(step.available or GuidelimeDataChar.showUnavailableSteps) and
			D.hasRequirements(step)
end

local function keepFading()
	local update = false
	local isFading = false
	for i, step in ipairs(CG.currentGuide.steps)	do
		if step.fading ~= nil then
			if not CG.stepIsVisible(step) then
				step.active = false
				--if addon.debugging then print("LIME: fade out", i, step.fading) end
				if step.fading <= 0 then
					step.fading = nil
					--if addon.debugging then print("LIME: fade out", i) end
					update = true
				else
					step.fading = step.fading - 0.05
					if step.fading < 0 then step.fading = 0 end
					if MW.mainFrame.steps ~= nil and MW.mainFrame.steps[i] ~= nil and MW.mainFrame.steps[i].visible then
						MW.mainFrame.steps[i]:SetAlpha(step.fading)
					end
					isFading = true
				end
			else
				step.fading = nil
				if MW.mainFrame.steps ~= nil and MW.mainFrame.steps[i] ~= nil and MW.mainFrame.steps[i].visible then MW.mainFrame.steps[i]:SetAlpha(1) end
			end
		end
	end
	if isFading then
		C_Timer.After(0.1, function()
			keepFading()
		end)
	elseif update and (not GuidelimeDataChar.showCompletedSteps or not GuidelimeDataChar.showUnavailableSteps) then
		MW.updateMainFrame()
	end
end

local function fadeoutStep(indexes)
	for _, i in ipairs(indexes) do
		local step = CG.currentGuide.steps[i]
		step.fading = 1
	end
	keepFading()
end

function CG.stopFading()
	for _, step in ipairs(CG.currentGuide.steps) do
		step.fading = nil
	end
end

function CG.updateStepsActivation()
	CG.currentGuide.activeQuests = {}
	for i, step in ipairs(CG.currentGuide.steps) do
		step.active = not step.completed and not step.skip and step.available and D.hasRequirements(step)
		if step.active then
			for j, pstep in ipairs(CG.currentGuide.steps) do
				if j == i then break end
				if not pstep.optional and not pstep.skip and not pstep.completed and pstep.available and D.hasRequirements(pstep) then
					step.active = false
					break
				end
			end
		end
		if step.active then
			for _, element in ipairs(step.elements) do
				if not element.completed and (element.t == "ACCEPT" or element.t == "TURNIN") then
					table.insert(CG.currentGuide.activeQuests, element.questId)
				end
			end
			if not step.wasActive then
				loadStepOnActivation(i)
				step.wasActive = true
			end
		end
	end
	-- accepting a follow up: maybe a quest dialog is still open and the quest just became active? try to accept it in that case
	if not IsShiftKeyDown() and EV.isQuestAuto(GuidelimeData.autoAcceptQuests, EV.lastQuestOpened) then
		AcceptQuest()
	end
end

local function updateFirstActiveIndex()
	local oldFirstActiveIndex = CG.currentGuide.firstActiveIndex
	CG.currentGuide.firstActiveIndex = nil
	CG.currentGuide.lastActiveIndex = nil
	for i, step in ipairs(CG.currentGuide.steps) do
		if (step.active or step.fading ~= nil) then
			if CG.currentGuide.firstActiveIndex == nil then CG.currentGuide.firstActiveIndex = i end
			CG.currentGuide.lastActiveIndex = i
		end
	end
	if MW.mainFrame.message ~= nil then
		for _, message in ipairs(MW.mainFrame.message) do
			if CG.currentGuide.firstActiveIndex ~= nil then
				message:Hide()
			else
				message:Show()
			end
		end
	end
	--if addon.debugging then print("LIME: firstActiveIndex ", CG.currentGuide.firstActiveIndex) end
	return oldFirstActiveIndex ~= CG.currentGuide.firstActiveIndex
end

function CG.getQuestActiveObjectives(id, objective)
	local objectiveList = QT.getQuestObjectives(id)
	if objectiveList == nil then return {} end
	local objectives
	if objective == nil then
		objectives = {}; for i = 1, #objectiveList do objectives[i] = i end
	else
		objectives = {objective}
	end
	local active = {}
	for _, i in ipairs(objectives) do
		local o
		if CG.quests[id] ~= nil and CG.quests[id].logIndex ~= nil and CG.quests[id].objectives ~= nil then	o = CG.quests[id].objectives[i] end
		if o == nil or (not o.done and o.desc ~= nil and o.desc ~= "") then
			table.insert(active, i)
		end
	end
	return active
end

function CG.isQuestObjectiveActive(questId, searchObjectives, filterObjective)
	if questId == nil or searchObjectives == nil then return true end
	local objectives = CG.getQuestActiveObjectives(questId, filterObjective)
	local found = false
	for _, o in ipairs(searchObjectives) do
		if D.contains(objectives, o) or o > #QT.getQuestObjectives(questId) then found = true; break; end
	end
	return found
end

function CG.updateStepsText()
	--if addon.debugging then print("LIME: update step texts") end
	if MW.mainFrame == nil then return end
	if CG.currentGuide == nil then return end
	for i in ipairs(CG.currentGuide.steps) do
		CG.updateStepText(i)
	end
end

function CG.scrollToFirstActive()
	C_Timer.After(0.2, function()
		if MW.mainFrame:GetTop() then
			local top = CG.currentGuide.firstActiveIndex ~= nil and 
				MW.mainFrame.steps ~= nil and
				MW.mainFrame.steps[CG.currentGuide.firstActiveIndex] ~= nil and
				MW.mainFrame.steps[CG.currentGuide.firstActiveIndex]:GetTop() ~= nil and
				MW.mainFrame.steps[CG.currentGuide.firstActiveIndex]:GetTop() + MW.GAP
			local bottom = MW.mainFrame.bottomElement and MW.mainFrame.bottomElement:GetBottom()
			for _, message in ipairs(MW.mainFrame.message or {}) do
				if message:IsShown() then 
					bottom = message:GetBottom() 
					if not top then top = message:GetTop() + MW.GAP end
				end
			end
			if bottom and MW.mainFrame.scrollFrame:GetTop() - bottom + MW.mainFrame.scrollFrame:GetVerticalScroll() <= MW.mainFrame.scrollFrame:GetHeight() then
				MW.mainFrame.scrollFrame:SetVerticalScroll(0)
			elseif bottom and top and top < bottom + MW.mainFrame.scrollFrame:GetHeight() then
				MW.mainFrame.scrollFrame:SetVerticalScroll(MW.mainFrame.scrollFrame:GetVerticalScroll() + 
					MW.mainFrame.scrollFrame:GetTop() - bottom - MW.mainFrame.scrollFrame:GetHeight())
			elseif top then
				MW.mainFrame.scrollFrame:SetVerticalScroll(MW.mainFrame.scrollFrame:GetVerticalScroll() + 
					MW.mainFrame.scrollFrame:GetTop() - top)
			end
			if addon.debugging then print("LIME: scrollToFirstActive", MW.mainFrame.scrollFrame:GetVerticalScroll()) end
		end
	end)
end

function CG.updateSteps(completedIndexes)
	if MW.mainFrame == nil then return end
	if CG.currentGuide == nil then return end
	if F.showingTooltip then GameTooltip:Hide(); F.showingTooltip = false end
	if completedIndexes == nil then completedIndexes = {} end

	local customCodeData = CC.customCodeData
	local isStepActive = {}
	if customCodeData then
		for i,v in ipairs(customCodeData) do
			if v.data and v.data.step then
				isStepActive[i] = v.data.step.active
				if v.OnStepUpdate then
					v.OnStepUpdate(v.data,v.args,"OnStepUpdate")
				end
			end
		end
	end

	--local time
	--if addon.debugging then time = debugprofilestop() end
	--if addon.debugging then print("LIME: update steps " .. GetTime()) end
	updateStepsCompletion(completedIndexes)
	--if addon.debugging then print("LIME: updateStepsCompletion " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	CG.updateStepsActivation()
	--if addon.debugging then print("LIME: updateStepsActivation " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	fadeoutStep(completedIndexes)
	--if addon.debugging then print("LIME: fadeoutStep " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	local scrollToFirstActive = updateFirstActiveIndex()
	--if addon.debugging then print("LIME: updateFirstActiveIndex " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	M.updateStepsMapIcons()
	--if addon.debugging then print("LIME: updateStepsMapIcons " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	AB.updateTargetButtons()
	AB.updateUseItemButtons()
	CG.updateStepsText()
	if scrollToFirstActive then	CG.scrollToFirstActive() end
	--if addon.debugging then print("LIME: updateStepsText " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end

	if customCodeData then
		for i,v in ipairs(customCodeData) do
			if v.data and v.data.step then
				local step = v.data.step
				if v.OnStepActivation and step.active and not isStepActive[i] then
					--print(step.index)
					v.OnStepActivation(v.data,v.args,"OnStepActivation")
				elseif v.OnStepCompletion and isStepActive[i] == not step.active and (step.completed or step.skip) then
					v.OnStepCompletion(v.data,v.args,"OnStepCompletion")
				end
			end
		end
	end
end

function CG.setStepSkip(value, a, b)
	if a == nil then a = 1; b = #CG.currentGuide.steps end
	if b == nil then b = a end
	local indexes = {}
	for i = a, b do
		local step = CG.currentGuide.steps[i]
		step.skip = value
		GuidelimeDataChar.guideSkip[CG.currentGuide.name][i] = step.skip
		table.insert(indexes, i)
		GuidelimeDataChar.completedSteps[i] = GuidelimeDataChar.completedSteps[i] and value
	end
	if not value and not GuidelimeDataChar.showUnavailableSteps then
		MW.updateMainFrame()
	else
		CG.updateSteps(indexes)
	end
end

function CG.skipCurrentSteps()
	if CG.currentGuide ~= nil and CG.currentGuide.firstActiveIndex ~= nil and
		CG.currentGuide.lastActiveIndex ~= nil then
		CG.setStepSkip(true, CG.currentGuide.firstActiveIndex, CG.currentGuide.lastActiveIndex)
	end
end

function CG.forEveryActiveElement(func)
	if CG.currentGuide ~= nil and CG.currentGuide.firstActiveIndex ~= nil and
		CG.currentGuide.lastActiveIndex ~= nil then
		for i = CG.currentGuide.firstActiveIndex, CG.currentGuide.lastActiveIndex do
			local step = CG.currentGuide.steps[i]
			--if addon.debugging then print("LIME:", step.text, step.optional) end
			for _, element in ipairs(step.elements) do
				if not element.completed then
					if func(element) == false then return end
				end
			end
		end
	end
end

function CG.completeSemiAutomaticByType(t)
	CG.forEveryActiveElement(function(element)
		if not element.completed and element.t == t then
			CG.completeSemiAutomatic(element)
			return false
		end
	end)
end

function CG.completeSemiAutomatic(element)
	element.completed = true
	local step = element.step
	local complete = true
	if not step.manual and not step.optional then
		for _, element in ipairs(step.elements) do
			if not element.completed and
				(element.t == "ACCEPT" or
				element.t == "COMPLETE" or
				element.t == "TURNIN" or
				element.t == "XP" or 
				element.t == "REPUTATION" or
				element.t == "LEARN" or
				element.t == "SKILL") then
				CG.updateSteps()
				return
			end
		end
	end
	GuidelimeDataChar.completedSteps[step.index] = true
	step.skip = true
	CG.updateSteps({step.index})
end

function CG.getElementByTextPos(pos, step)
	for j, element in ipairs(CG.currentGuide.steps[step].elements) do
		if element.textStartPos > pos then return j - 1 end
	end
	return #CG.currentGuide.steps[step].elements
end

function CG.simulateCompleteCurrentSteps()
	if CG.currentGuide ~= nil and CG.currentGuide.firstActiveIndex ~= nil and
		CG.currentGuide.lastActiveIndex ~= nil then
		--if addon.debugging then print("LIME:", CG.currentGuide.firstActiveIndex, CG.currentGuide.lastActiveIndex) end
		for i = CG.currentGuide.firstActiveIndex, CG.currentGuide.lastActiveIndex do
			local step = CG.currentGuide.steps[i]
			--if addon.debugging then print("LIME:", step.text, step.optional) end
			for _, element in ipairs(step.elements) do
				if not element.completed then
					if element.t == "ACCEPT" then
						if CG.quests[element.questId] == nil then CG.quests[element.questId] = {} end
						CG.quests[element.questId].logIndex = -1
					elseif element.t == "COMPLETE" then
						if CG.quests[element.questId] == nil then CG.quests[element.questId] = {} end
						CG.quests[element.questId].finished = true
					elseif element.t == "TURNIN" then
						if CG.quests[element.questId] == nil then CG.quests[element.questId] = {} end
						CG.quests[element.questId].completed = true
					end
				end
			end
		end
		CG.updateSteps()
	end
end