local addonName, addon = ...
local L = addon.L


HBD = LibStub("HereBeDragons-2.0")

addon.frame = CreateFrame("Frame", addonName .. "Frame", UIParent)
Guidelime = {}

addon.COLOR_QUEST_DEFAULT = "|cFF59C4F1"
addon.COLOR_LEVEL_RED = "|cFFFF1400"
addon.COLOR_LEVEL_ORANGE = "|cFFFFA500"
addon.COLOR_LEVEL_YELLOW = "|cFFFFFF00"
addon.COLOR_LEVEL_GREEN = "|cFF008000"
addon.COLOR_LEVEL_GRAY = "|cFF808080"
addon.COLOR_WHITE = "|cFFFFFFFF"
addon.COLOR_LIGHT_BLUE = "|cFF99CCFF"
addon.MAINFRAME_ALPHA_MAX = 85
addon.AUTO_COMPLETE_DELAY = 0.01
addon.DEFAULT_GOTO_RADIUS = 10

addon.CONTACT_DISCORD = "Borick#7318"
addon.CONTACT_CURSEFORGE = "rickrob"
addon.CONTACT_REDDIT = "u/borick23"


function addon.getLevelColor(level)
	if level > addon.level + 4 then
		return addon.COLOR_LEVEL_RED
	elseif level > addon.level + 2 then
		return addon.COLOR_LEVEL_ORANGE
	elseif level >= addon.level - 2 then
		return addon.COLOR_LEVEL_YELLOW
	elseif level >= addon.level - 4 - math.min(4, math.floor(addon.level / 10)) then
		return addon.COLOR_LEVEL_GREEN
	else
		return addon.COLOR_LEVEL_GRAY
	end
end

addon.icons = {
	MAP = "Interface\\Addons\\" .. addonName .. "\\Icons\\lime",
	MAP_ARROW = "Interface\\Addons\\" .. addonName .. "\\Icons\\Arrow",
	MAP_LIME_ARROW = "Interface\\Addons\\" .. addonName .. "\\Icons\\lime_arrow",
	MAP_MARKER_1 = "Interface\\Addons\\" .. addonName .. "\\Icons\\lime_marker",
	MAP_MARKER_2 = "Interface\\Addons\\" .. addonName .. "\\Icons\\lime_marker_friz_green",
	MAP_MARKER_3 = "Interface\\Addons\\" .. addonName .. "\\Icons\\lime_marker_friz",
	COMPLETED = "Interface\\Buttons\\UI-CheckBox-Check",
	UNAVAILABLE = "Interface\\Buttons\\UI-GroupLoot-Pass-Up", -- or rather "Interface\\Buttons\\UI-StopButton" (yellow x) ?

	QUEST = "Interface\\GossipFrame\\ActiveQuestIcon",
	ACCEPT = "Interface\\GossipFrame\\AvailableQuestIcon",
	ACCEPT_UNAVAILABLE = "Interface\\Addons\\" .. addonName .. "\\Icons\\questunavailable",
	COMPLETE = "Interface\\GossipFrame\\WorkOrderGossipIcon",
	WORK = "Interface\\GossipFrame\\WorkOrderGossipIcon",
	TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon",
	TURNIN_INCOMPLETE = "Interface\\GossipFrame\\IncompleteQuestIcon",
	npc = "Interface\\GossipFrame\\ChatBubbleGossipIcon",
	monster = "Interface\\GossipFrame\\BattleMasterGossipIcon",
	item = "Interface\\GossipFrame\\VendorGossipIcon",
	object = "Interface\\GossipFrame\\BinderGossipIcon",
	SET_HEARTH = "Interface\\Addons\\" .. addonName .. "\\Icons\\set_hearth", -- made from "Interface\\Icons\\INV_Drink_05", nicer than the actual "Interface\\GossipFrame\\BinderGossipIcon" ?
	VENDOR = "Interface\\GossipFrame\\VendorGossipIcon",
	REPAIR = "Interface\\Addons\\" .. addonName .. "\\Icons\\repair", -- made from "Interface\\Icons\\Trade_BlackSmithing",
	HEARTH = "Interface\\Addons\\" .. addonName .. "\\Icons\\hearth", -- made from "Interface\\Icons\\INV_Misc_Rune_01",
	FLY = "Interface\\GossipFrame\\TaxiGossipIcon",
	TRAIN = "Interface\\GossipFrame\\TrainerGossipIcon",
	GET_FLIGHT_POINT = "Interface\\Addons\\" .. addonName .. "\\Icons\\getflightpoint",
	GOTO = "Interface\\Addons\\" .. addonName .. "\\Icons\\lime0",
	LOC = "Interface\\Addons\\" .. addonName .. "\\Icons\\lime",

	--LOC = "Interface\\Icons\\Ability_Tracking",
	--KILL = "Interface\\Icons\\Ability_Creature_Cursed_02",
	--MAP = "Interface\\Icons\\Ability_Spy",
	--NOTE = "Interface\\Icons\\INV_Misc_Note_01",
	--USE = "Interface\\Icons\\INV_Misc_Bag_08",
	--BUY = "Interface\\Icons\\INV_Misc_Coin_01",
	--BOAT = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
}

local _
_, addon.class = UnitClass("player"); addon.class = addon.getClass(addon.class)
_, addon.race = UnitRace("player"); addon.race = addon.getRace(addon.race)
addon.faction = UnitFactionGroup("player")
addon.level = UnitLevel("player")
addon.xp = UnitXP("player")
addon.xpMax = UnitXPMax("player")
addon.y, addon.x, addon.z, addon.instance = UnitPosition("player")
addon.face = GetPlayerFacing()

addon.guides = {}
addon.dataLoaded = false

function Guidelime.registerGuide(guide, group)
	guide = addon.parseGuide(guide, group, nil, true)
	if guide == nil then error("There were errors parsing the guide \"" .. guide.name .. "\"") end
	if addon.debugging then print("LIME: ", guide.name) end
	if addon.debugging and addon.guides[guide.name] ~= nil then 
		print("Guide \"" .. guide.name .. "\" was overwritten") 
	end
	addon.guides[guide.name] = guide
	return guide
end

function addon.loadData()
	local defaultOptions = {
		debugging = false,
		showLineNumbers = false,
		showQuestLevels = false,
		showMinimumQuestLevels = false,
		showTooltips = true,
		maxNumOfSteps = 0,
		mapMarkerStyleGOTO = 1,
		mapMarkerStyleLOC = 2,
		mapMarkerAlphaGOTO = 1,
		mapMarkerAlphaLOC = 0.5,
		mapMarkerSizeGOTO = 16,
		mapMarkerSizeLOC = 16,
		showMapMarkersGOTO = true,
		showMapMarkersLOC = true,
		showMinimapMarkersGOTO = true,
		showMinimapMarkersLOC = true,
		maxNumOfMarkersGOTO = 10,
		maxNumOfMarkersLOC = 15,
		arrowStyle = 1,
		arrowDistance = false,
		skipCutscenes = true,
		dataSourceQuestie = false,
		autoAddCoordinates = true,
		displayDemoGuides = true,
		fontColorACCEPT = addon.COLOR_QUEST_DEFAULT,
		fontColorCOMPLETE = addon.COLOR_QUEST_DEFAULT,
		fontColorTURNIN = addon.COLOR_QUEST_DEFAULT,
		fontColorSKIP = addon.COLOR_QUEST_DEFAULT,
		autoCompleteQuest = true,
		autoSelectFlight = true,
		showQuestIds = false,
		version = GetAddOnMetadata(addonName, "version")
	}
	local defaultOptionsChar = {
		mainFrameX = 0,
		mainFrameY = 0,
		mainFrameRelative = "RIGHT",
		mainFrameShowing = true,
		mainFrameLocked = false,
		mainFrameWidth = 350,
		mainFrameHeight = 400,
		mainFrameAlpha = 0.5,
		mainFrameFontSize = 14,
		mainFrameShowScrollBar = true,
		showCompletedSteps = false,
		showUnavailableSteps = true,
		showArrow = true,
		arrowX = 0,
		arrowY = -20,
		arrowRelative = "TOP",
		arrowLocked = false,
		arrowAlpha = 0.8,
		arrowSize = 64,
		editorFrameX = 0,
		editorFrameY = 0,
		editorFrameRelative = "CENTER",
		guideSkip = {},
		guideSize = {},
		version = GetAddOnMetadata(addonName, "version")
	}
	if GuidelimeData == nil then GuidelimeData = {} end
	if GuidelimeDataChar == nil then GuidelimeDataChar = {} end
	for option, default in pairs(defaultOptions) do
		if GuidelimeData[option] == nil then GuidelimeData[option] = default end
	end
	for option, default in pairs(defaultOptionsChar) do
		if GuidelimeDataChar[option] == nil then GuidelimeDataChar[option] = default end
	end

	addon.debugging = GuidelimeData.debugging

	GuidelimeDataChar.version:gsub("(%d+).(%d+)", function(major, minor)
		if tonumber(major) == 1 and tonumber(minor) < 2 then
			--changed default value for showUnavailableSteps
			GuidelimeDataChar.showUnavailableSteps = true
			GuidelimeDataChar.version = GetAddOnMetadata(addonName, "version")
		end
		if tonumber(major) == 0 and tonumber(minor) < 41 then
			GuidelimeDataChar.autoCompleteQuest = nil
			GuidelimeDataChar.version = GetAddOnMetadata(addonName, "version")
		end
		if tonumber(major) == 0 and tonumber(minor) < 28 then
			--GuidelimeDataChar.currentGuide.skip was replaced with GuidelimeDataChar.guideSkip and GuidelimeDataChar.currentGuide.name with GuidelimeDataChar.currentGuide. Therefore remove.
			GuidelimeDataChar.currentGuide = nil
			GuidelimeDataChar.version = GetAddOnMetadata(addonName, "version")
		end
	end, 1)
	GuidelimeData.version:gsub("(%d+).(%d+)", function(major, minor)
		if tonumber(major) == 1 and tonumber(minor) < 28 then
			--hide option debugging, dataSourceQuestie
			GuidelimeData.debugging = false
			addon.debugging = false
			GuidelimeData.dataSourceQuestie = false
			GuidelimeData.version = GetAddOnMetadata(addonName, "version")
		end
		if tonumber(major) == 0 and tonumber(minor) < 39 then
			--removed options mapMarkerStyle, mapMarkerSize, autoAddCoordinates
			GuidelimeData.mapMarkerStyle = nil
			GuidelimeData.mapMarkerSize = nil
			GuidelimeData.autoAddCoordinates = nil
			GuidelimeData.version = GetAddOnMetadata(addonName, "version")
		end
		if tonumber(major) == 0 and tonumber(minor) < 36 then
			--options reworked; remove everything old
			GuidelimeData.hideCompletedSteps = nil
			GuidelimeData.hideUnavailableSteps = nil
			GuidelimeData.maxNumOfStepsGOTO = nil
			GuidelimeData.maxNumOfStepsLOC = nil
			GuidelimeData.version = GetAddOnMetadata(addonName, "version")
		end
		if tonumber(major) == 0 and tonumber(minor) < 21 then
			--autoAddCoordinates default changed to true; reset for everyone
			GuidelimeData.autoAddCoordinates = true
			GuidelimeData.version = GetAddOnMetadata(addonName, "version")
		elseif tonumber(major) == 0 and tonumber(minor) < 18 then
			-- maxNumOfMarkers is deprecated
			GuidelimeData.maxNumOfMarkers = nil
			GuidelimeData.version = GetAddOnMetadata(addonName, "version")
		end
		if tonumber(major) == 0 and tonumber(minor) < 10 then
			-- before 0.010 custom guides were saved with a key prefixed with L.CUSTOM_GUIDES. This produces different keys when language is changed. Therefore remove.
			if GuidelimeData.customGuides ~= nil then
				local guides = GuidelimeData.customGuides
				GuidelimeData.customGuides = {}
				for name, guide in pairs(guides) do
					if name:sub(1, 14) == "Custom guides " then name = name:sub(15) end
					GuidelimeData.customGuides[name] = guide
				end
			end
			GuidelimeData.version = GetAddOnMetadata(addonName, "version")
		end
	end, 1)

	if GuidelimeData.customGuides ~= nil then
		for _, guide in pairs(GuidelimeData.customGuides) do
			Guidelime.registerGuide(guide, L.CUSTOM_GUIDES)
		end
	end

	addon.loadCurrentGuide()

	addon.fillGuides()
	addon.fillOptions()

	addon.dataLoaded = true

	if addon.debugging then addon.testLocalization() end
end

function addon.loadCurrentGuide()

	addon.currentGuide = {}
	addon.currentGuide.name = GuidelimeDataChar.currentGuide
	addon.currentGuide.steps = {}
	addon.quests = {}
	
	local guide = addon.guides[GuidelimeDataChar.currentGuide]
	
	if guide == nil then
		if addon.debugging then
			print("LIME: available guides:")
			for name in pairs(addon.guides) do
				print("LIME: " .. name)
			end
			print("LIME: guide \"" .. (GuidelimeDataChar.currentGuide or "") .. "\" not found")
		end
		GuidelimeDataChar.currentGuide = nil
		addon.currentGuide.name = nil
		return
	end
	addon.currentGuide.next = guide.next
	addon.currentGuide.group = guide.group
	if GuidelimeDataChar.guideSkip[GuidelimeDataChar.currentGuide] == nil or GuidelimeDataChar.guideSize[GuidelimeDataChar.currentGuide] ~= #guide.steps then
		GuidelimeDataChar.guideSkip[GuidelimeDataChar.currentGuide] = {}
		GuidelimeDataChar.guideSize[GuidelimeDataChar.currentGuide] = #guide.steps
	end

	--print(format(L.LOAD_MESSAGE, addon.currentGuide.name))
	local time
	if addon.debugging then time = debugprofilestop() end
	guide = addon.parseGuide(guide, guide.group)
	if addon.debugging then print("LIME: parseGuide " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	if guide == nil then return end
	addon.guides[GuidelimeDataChar.currentGuide] = guide

	local completed = GetQuestsCompleted()

	for _, step in ipairs(guide.steps) do
		local loadLine = addon.applies(step)
		local filteredElements = {}
		for _, element in ipairs(step.elements) do
			if not element.generated and
				((element.text ~= nil and element.text ~= "") or 
				(element.t ~= "TEXT" and element.t ~= "NAME" and element.t ~= "NEXT" and element.t ~= "DETAILS" and element.t ~= "GUIDE_APPLIES" and element.t ~= "APPLIES" and element.t ~= "DOWNLOAD" and element.t ~= "AUTO_ADD_COORDINATES_GOTO" and element.t ~= "AUTO_ADD_COORDINATES_LOC"))
			then
				table.insert(filteredElements, element)
			end
		end
		step.elements = filteredElements
		if #step.elements == 0 then loadLine = false end
		if loadLine then
			table.insert(addon.currentGuide.steps, step)
			step.index = #addon.currentGuide.steps
			local i = 1
			local lastGoto
			while i <= #step.elements do
				local element = step.elements[i]
				element.available = true

				if element.t == "ACCEPT" or element.t == "COMPLETE" or element.t == "TURNIN" or element.t == "XP" then
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
					if addon.quests[element.questId] == nil then addon.quests[element.questId] = {} end
					addon.quests[element.questId].title = element.title
					addon.quests[element.questId].completed = completed[element.questId] ~= nil and completed[element.questId]
					addon.quests[element.questId].finished = addon.quests[element.questId].completed
					if addon.questsDB[element.questId] ~= nil and addon.questsDB[element.questId].prequests ~= nil then
						for _, id in ipairs(addon.questsDB[element.questId].prequests) do
							if addon.applies(addon.questsDB[id]) then
								if addon.quests[id] == nil then addon.quests[id] = {} end
								addon.quests[id].completed = completed[id] ~= nil and completed[id]
								if addon.quests[id].followup == nil then addon.quests[id].followup = {} end
								table.insert(addon.quests[id].followup, element.questId)
							end
						end
					end
					if addon.quests[element.questId].lastStep == nil then addon.quests[element.questId].lastStep = {} end
					addon.quests[element.questId].lastStep[element.t] = element
					if element.t == "COMPLETE" and addon.quests[element.questId].objectives == nil then
						addon.quests[element.questId].objectives = {}
						local objectives = addon.getQuestObjectives(element.questId)
						if objectives ~= nil then
							for i, objective in ipairs(objectives) do
								addon.quests[element.questId].objectives[i] = {type = objective.type, desc = objective.names[1]}
							end
						end
					end
					if guide.autoAddCoordinatesGOTO and (GuidelimeData.showMapMarkersGOTO or GuidelimeData.showMinimapMarkersGOTO) and not step.hasGoto and not element.optional then
						local gotoElement = addon.getQuestPosition(element.questId, element.t, element.objective)
						if gotoElement ~= nil then
							gotoElement.t = "GOTO"
							gotoElement.step = step
							gotoElement.radius = addon.DEFAULT_GOTO_RADIUS + gotoElement.radius
							gotoElement.generated = true
							gotoElement.available = true
							gotoElement.attached = element
							table.insert(step.elements, i, gotoElement)
							for j = i, #step.elements do
								step.elements[j].index = j
							end
							i = i + 1
							if lastGoto ~= nil then lastGoto.lastGoto = false end
							gotoElement.lastGoto = true
							lastGoto = gotoElement
						end
					end						
				elseif element.t == "FLY" then
					if guide.autoAddCoordinatesGOTO and (GuidelimeData.showMapMarkersGOTO or GuidelimeData.showMinimapMarkersGOTO) and not step.hasGoto and not element.optional then
						local gotoElement = {}
						gotoElement.t = "GOTO"
						gotoElement.specialLocation = "NEAREST_FLIGHT_POINT"
						gotoElement.step = step
						gotoElement.radius = addon.DEFAULT_GOTO_RADIUS
						gotoElement.generated = true
						gotoElement.available = true
						gotoElement.attached = element
						table.insert(step.elements, i, gotoElement)
						for j = i, #step.elements do
							step.elements[j].index = j
						end
						i = i + 1
						if lastGoto ~= nil then lastGoto.lastGoto = false end
						gotoElement.lastGoto = true
						lastGoto = gotoElement
					end						
				elseif element.t == "GET_FLIGHT_POINT" then
					if guide.autoAddCoordinatesGOTO and (GuidelimeData.showMapMarkersGOTO or GuidelimeData.showMinimapMarkersGOTO) and not step.hasGoto and not element.optional then
						local gotoElement = {}
						gotoElement.wx, gotoElement.wy, gotoElement.instance = addon.getFlightPoint(element.flightmaster)
						if gotoElement.wx ~= nil then
							gotoElement.t = "GOTO"
							gotoElement.step = step
							gotoElement.radius = addon.DEFAULT_GOTO_RADIUS
							gotoElement.generated = true
							gotoElement.available = true
							gotoElement.attached = element
							table.insert(step.elements, i, gotoElement)
							for j = i, #step.elements do
								step.elements[j].index = j
							end
							i = i + 1
							if lastGoto ~= nil then lastGoto.lastGoto = false end
							gotoElement.lastGoto = true
							lastGoto = gotoElement
						end
					end						
				end
				i = i + 1
			end
			if step.manual == nil then step.manual = true end
			if step.completeWithNext == nil then step.compleWithNext = false end
			if step.completeWithNext then step.optional = true end
			if step.optional == nil then step.optional = false end
			step.skip = GuidelimeDataChar.guideSkip[addon.currentGuide.name][#addon.currentGuide.steps] or false
			step.active = false
			step.wasActive = false
			step.completed = false
			step.available = true
		end
	end
	if addon.debugging then print("LIME: loadCurrentGuide " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
end

local function loadStepOnActivation(i)
	local time
	if addon.debugging then time = debugprofilestop() end
	local step = addon.currentGuide.steps[i]
	if addon.guides[GuidelimeDataChar.currentGuide].autoAddCoordinatesLOC and (GuidelimeData.showMapMarkersLOC or GuidelimeData.showMinimapMarkersLOC) and not step.hasLoc then
		local j = 1
		while j <= #step.elements do
			local element = step.elements[j]
			if element.questId ~= nil then
				local objectives = addon.getQuestObjectives(element.questId, element.t)						
				if objectives ~= nil then
					local a, b = element.objective, element.objective
					if element.objective == nil then a = 1; b = #objectives end
					for o = a, b do
						local positions = addon.getQuestPositionsLimited(element.questId, element.t, o, GuidelimeData.maxNumOfMarkersLOC, true)
						if positions ~= nil and #positions > 1 then
							for _, locElement in ipairs(positions) do
								locElement.t = "LOC"
								locElement.markerTyp = objectives[o].type
								locElement.step = step
								locElement.generated = true
								locElement.available = true
								locElement.index = j
								locElement.attached = element
								table.insert(step.elements, j, locElement)
								j = j + 1
							end
						end
					end
					for k = j, #step.elements do
						step.elements[k].index = k
					end
				end
			end
			j = j + 1
		end
	end
	if addon.debugging then print("LIME: loadStepOnActivation " .. i .. " " .. math.floor(debugprofilestop() - time) .. " ms") end
end

function addon.getQuestText(id, t, title, colored)
	local q = ""
	if (GuidelimeData.showQuestLevels or GuidelimeData.showMinimumQuestLevels) and addon.questsDB[id] ~= nil then
		q = q .. "["
		if GuidelimeData.showMinimumQuestLevels then
			q = q .. addon.COLOR_LIGHT_BLUE .. (addon.questsDB[id].req or "")
		end
		if GuidelimeData.showMinimumQuestLevels and GuidelimeData.showQuestLevels then
			if colored == true then
				q = q .. "|r"
			else
				q = q .. addon.COLOR_INACTIVE
			end
			q = q .. "-"
		end
		if GuidelimeData.showQuestLevels then
			q = q .. addon.getLevelColor(addon.questsDB[id].level) .. (addon.questsDB[id].level or "")
			if addon.questsDB[id].type == "Dungeon" then 
				q = q .. "D" 
			elseif addon.questsDB[id].type == "Raid" then 
				q = q .. "R" 
			elseif addon.questsDB[id].type == "Elite" then 
				q = q .. "+" 
			end
		end
		if colored == true then
			q = q .. "|r"
		else
			q = q .. addon.COLOR_INACTIVE
		end
		q = q .. "]"
	end
	if colored == nil or colored then q = q .. GuidelimeData["fontColor" .. (t or "ACCEPT")] end
	q = q .. (title or addon.getQuestNameById(id) or id)
	if GuidelimeData.showQuestIds then q = q .. "(#" .. id .. ")" end
	if colored == nil or colored then q = q .. "|r" end
	return q
end

local function getSkipQuests(id, skipQuests, newSkipQuests)
	if newSkipQuests == nil then newSkipQuests = {} end
	if addon.quests[id] ~= nil and addon.quests[id].followup ~= nil and #addon.quests[id].followup > 0 then
		for _, fid in ipairs(addon.quests[id].followup) do
			if addon.currentGuide.unavailableQuests[fid] == nil and skipQuests[fid] == nil then
				table.insert(newSkipQuests, fid)
				skipQuests[fid] = true
				getSkipQuests(fid, skipQuests, newSkipQuests)
			end
		end
	end
	return newSkipQuests
end

function addon.getQuestObjectiveIcon(id, objective)
	if addon.quests[id] == nil or addon.quests[id].objectives == nil then return "" end
	local a, b = objective, objective
	if objective == nil then a = 1; b = #addon.quests[id].objectives end
	local text = ""
	local icons = {}
	for i = a, b do
		local o = addon.quests[id].objectives[i]
		if o ~= nil and not o.done then
			local type = o.type
			if type == nil or addon.icons[type] == nil then type = "COMPLETE" end
			if icons[type] == nil then
				text = text .. "|T" .. addon.icons[type] .. ":12|t"
				icons[type] = true
			end
		end
	end
	return text
end	

function addon.getQuestObjectiveText(id, objectives, indent, npcId, objectId)
	local objectiveList = addon.getQuestObjectives(id)
	if objectiveList == nil then return "" end
	if objectives == true then
		objectives = {}; for i = 1, #objectiveList do objectives[i] = i end
	end
	local text = ""
	if npcId ~= nil and (#objectives ~= 1 or objectiveList[objectives[1]] == nil or (objectiveList[objectives[1]].type ~= "npc" and objectiveList[objectives[1]].type ~= "monster")) then
		if addon["creaturesDB_" .. GetLocale()] ~= nil and addon["creaturesDB_" .. GetLocale()][npcId] ~= nil then
			text = (indent or "") .. "|T" .. addon.icons.monster .. ":12|t" .. addon["creaturesDB_" .. GetLocale()][npcId]
		elseif npcId ~= nil and addon.creaturesDB[npcId] ~= nil then
			text = (indent or "") .. "|T" .. addon.icons.monster .. ":12|t" .. addon.creaturesDB[npcId].name
		end
	elseif objectId ~= nil and (#objectives ~= 1 or objectiveList[objectives[1]] == nil or objectiveList[objectives[1]].type ~= "object") then
		if addon["objectsDB_" .. GetLocale()] ~= nil and addon["objectsDB_" .. GetLocale()][objectId] ~= nil then
			text = (indent or "") .. "|T" .. addon.icons.object .. ":12|t" .. addon["objectsDB_" .. GetLocale()][objectId]
		elseif objectId ~= nil and addon.objectsDB[objectId] ~= nil then
			text = (indent or "") .. "|T" .. addon.icons.object .. ":12|t" .. addon.objectsDB[objectId].name
		end
	end
	for _, i in ipairs(objectives) do
		local o
		if addon.quests[id] ~= nil and addon.quests[id].logIndex ~= nil and addon.quests[id].objectives ~= nil then	o = addon.quests[id].objectives[i] end
		if o == nil and objectiveList[i] ~= nil then
			if text ~= "" then text = text .. "\n" end
			local type = objectiveList[i].type
			if type == nil or addon.icons[type] == nil then type = "COMPLETE" end
			text = text	.. (indent or "") .. "- " .. "|T" .. addon.icons[type] .. ":12|t" .. (objectiveList[i].names[1] or "")
		elseif o ~= nil and not o.done and o.desc ~= nil and o.desc ~= "" then
			local icon = addon.getQuestObjectiveIcon(id, i)
			if text ~= "" then text = text .. "\n" end
			text = text .. (indent or "") .. "- " .. icon .. o.desc
		end
	end
	return text
end

function addon.getQuestIcon(questId, t, objective, finished)
	if t == "ACCEPT" and addon.questsDB[questId] ~= nil and addon.questsDB[questId].req > addon.level then
		return "|T" .. addon.icons.ACCEPT_UNAVAILABLE .. ":12|t"
	elseif t == "TURNIN" and not finished then
		return "|T" .. addon.icons.TURNIN_INCOMPLETE .. ":12|t"
	elseif t == "COMPLETE" then
		return addon.getQuestObjectiveIcon(questId, objective)
	else
		return "|T" .. (addon.icons[t] or addon.icons.COMPLETE) .. ":12|t"
	end
end

function addon.getElementIcon(element, prevElement)
	if element.completed and element.t ~= "GOTO" then
		return "|T" .. addon.icons.COMPLETED .. ":12|t"
	elseif element.available == false then
		return "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
	elseif addon.getSuperCode(element.t) == "QUEST" then
		return addon.getQuestIcon(element.questId, element.t, element.objective, element.finished)
	elseif element.t == "LOC" or element.t == "GOTO" then
		if element.t == "LOC" and ((prevElement ~= nil and prevElement.t == "LOC") or (element.markerTyp ~= nil)) then
			-- Dont show an icon for subsequent LOC elements. Also dont show LOC for quest steps since there would be the same icon twice
			return ""
		elseif element.mapIndex == 0 and addon.arrowFrame ~= nil and GuidelimeDataChar.showArrow then
			return addon.getArrowIconText()
		elseif element.mapIndex ~= nil then
			return addon.getMapMarkerText(element)
		end
	elseif addon.icons[element.t] ~= nil then
		return "|T" .. addon.icons[element.t] .. ":12|t"
	end
	return ""
end

function addon.getStepText(step)
	local text = ""
	local tooltip = ""
	local skipTooltip = ""
	local skipText = ""
	local skipQuests = {}
	local trackQuest = {}
	local url
	if GuidelimeData.showLineNumbers then text = text .. step.line .. " " end
	if not step.active then
		text = text .. addon.COLOR_INACTIVE
	elseif step.manual then
		skipTooltip = L.STEP_MANUAL
	else
		skipTooltip = L.STEP_SKIP
	end
	local prevElement
	for _, element in ipairs(step.elements) do
		text = text .. addon.getElementIcon(element, prevElement)
		if element.available and not element.completed and element.t == "ACCEPT" and addon.questsDB[element.questId] ~= nil and addon.questsDB[element.questId].req > addon.level then
			if tooltip ~= "" then tooltip = tooltip .. "\n" end
			local q = addon.getQuestText(element.questId, element.t)
			tooltip = tooltip .. L.QUEST_REQUIRED_LEVEL:format(q, addon.questsDB[element.questId].req)
		end
		if element.text ~= nil then
			if step.active then
				text = text .. element.text
			else
				text = text .. element.textInactive
			end
			if element.url ~= nil then url = element.url end
		end
		if addon.getSuperCode(element.t) == "QUEST" then
			text = text .. addon.getQuestText(element.questId, element.t, element.title, step.active)
			if element.available and not element.completed then
				if addon.quests[element.questId].lastStep[element.t] == element then
					local newSkipQuests = getSkipQuests(element.questId, skipQuests)
					if #newSkipQuests > 0 then
						if skipText ~= "" then skipText = skipText .. "\n\n" end
						if #newSkipQuests == 1 then
							skipText = skipText .. L.STEP_FOLLOWUP_QUEST:format(addon.getQuestText(element.questId, element.t)) ..":\n"
						else
							skipText = skipText .. L.STEP_FOLLOWUP_QUESTS:format(addon.getQuestText(element.questId, element.t)) ..":\n"
						end
						for _, id in ipairs(newSkipQuests) do
							skipText = skipText .. "\n|T" .. addon.icons.UNAVAILABLE .. ":12|t" .. addon.getQuestText(id)
						end
						if #newSkipQuests == 1 then
							skipText = skipText .. "\n\n" .. L.STEP_FOLLOWUP_QUEST_CONT:format(addon.getQuestText(element.questId, element.t))
						else
							skipText = skipText .. "\n\n" .. L.STEP_FOLLOWUP_QUESTS_CONT:format(addon.getQuestText(element.questId, element.t))
						end
					end
				end
				if element.t == "COMPLETE" or element.t == "TURNIN" then
					if element.objective == nil then
						trackQuest[element.questId] = true
					elseif trackQuest[element.questId] ~= true then
						if trackQuest[element.questId] == nil then trackQuest[element.questId] = {} end
						if not addon.contains(trackQuest[element.questId], element.objective) then table.insert(trackQuest[element.questId], element.objective) end
					end
				end
			end
		end
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
			tooltip = tooltip .. " " ..addon.getQuestText(id)
		end
	end
	for id, objectives in pairs(trackQuest) do
		if step.active then
			text = text .. "\n" .. addon.getQuestObjectiveText(id, objectives, "    ")
		else
			if tooltip ~= "" then tooltip = tooltip .. "\n" end
			tooltip = tooltip .. addon.getQuestObjectiveText(id, objectives)
		end
	end
	return text, tooltip, skipText, skipTooltip, url
end

local function updateStepText(i)
	local step = addon.currentGuide.steps[i]
	if addon.mainFrame.steps == nil or addon.mainFrame.steps[i] == nil or addon.mainFrame.steps[i].textBox == nil or not addon.mainFrame.steps[i].visible then return end
	local text, tooltip, skipText, skipTooltip, url = addon.getStepText(step)
	if text ~= addon.mainFrame.steps[i].textBox:GetText() then
		addon.mainFrame.steps[i].textBox:SetText(text)
	end
	addon.mainFrame.steps[i].textBox.url = url
	addon.mainFrame.steps[i].skipText = skipText
	if GuidelimeData.showTooltips then
		addon.mainFrame.steps[i].textBox.tooltip = tooltip
		addon.mainFrame.steps[i].tooltip = skipTooltip
	else
		addon.mainFrame.steps[i].textBox.tooltip = nil
		addon.mainFrame.steps[i].tooltip = nil
	end
end

local function updateStepCompletion(i, completedIndexes)
	local step = addon.currentGuide.steps[i]

	local wasCompleted = step.completed
	if not step.manual then	step.completed = nil end
	for _, element in ipairs(step.elements) do
		if element.t == "ACCEPT" then
			element.completed = addon.quests[element.questId].completed or addon.quests[element.questId].logIndex ~= nil
			if step.completed == nil or not element.completed then step.completed = element.completed end
		elseif element.t == "COMPLETE" then
			element.completed =
				addon.quests[element.questId].completed or
				addon.quests[element.questId].finished or
				(element.objective ~= nil and 
					addon.quests[element.questId].objectives ~= nil and 
					addon.quests[element.questId].objectives[element.objective] ~= nil and
					addon.quests[element.questId].objectives[element.objective].done)
			if step.completed == nil or not element.completed then step.completed = element.completed end
		elseif element.t == "TURNIN" then
			element.finished = addon.quests[element.questId].finished
			element.completed = addon.quests[element.questId].completed
			if step.completed == nil or not element.completed then step.completed = element.completed end
		elseif element.t == "XP" then
			element.completed = element.level <= addon.level
			if element.xp ~= nil and element.level == addon.level then
				if element.xpType == "REMAINING" then
					if element.xp < (addon.xpMax - addon.xp) then element.completed = false end
				elseif element.xpType == "PERCENTAGE" then
					if addon.xpMax == 0 or element.xp > (addon.xp / addon.xpMax) then element.completed = false end
				else
					if element.xp > addon.xp then element.completed = false end
				end
			end
			if step.completed == nil or not element.completed then step.completed = element.completed end
		end
	end
	-- check goto last so that go to does not matter when all other objectives are completed
	local nonGotoCompleted = step.completed or wasCompleted
	for _, element in ipairs(step.elements) do
		if element.t == "GOTO"  then
			--if addon.debugging then print("LIME : zone coordinates", x, y, element.mapID) end
			if nonGotoCompleted or step.skip then
				element.completed = true
			elseif element.attached ~= nil and element.attached.completed then
				element.completed = true
			elseif element.completed and not element.lastGoto and element.attached == nil then
				-- do not reactivate unless it is the last goto of the step
			elseif addon.x ~= nil and addon.y ~= nil and element.wx ~= nil and element.wy ~= nil and addon.instance == element.instance and addon.alive and step.active then
				local radius = element.radius * element.radius
				-- add some hysteresis
				if element.completed then radius = radius * 1.6 end
				element.completed = (addon.x - element.wx) * (addon.x - element.wx) + (addon.y - element.wy) * (addon.y - element.wy) <= radius
			else
				element.completed = false
			end
			if step.completed == nil or not element.completed then step.completed = element.completed end
		end
	end
	if step.completed == nil then step.completed = step.completeWithNext and wasCompleted end

	if i < #addon.currentGuide.steps and step.completeWithNext ~= nil and step.completeWithNext then
		local nstep = addon.currentGuide.steps[i + 1]
		local c = nstep.completed or nstep.skip
		if step.completed ~= c then
			--if addon.debugging then print("LIME: complete with next ", i - 1, c, nstep.skip, nstep.available) end
			step.completed = c
		end
	end

	if step.completed ~= wasCompleted and not addon.contains(completedIndexes, i) then
		table.insert(completedIndexes, i)
	end
end

local function updateStepAvailability(i, changedIndexes, scheduled)
	local step = addon.currentGuide.steps[i]
	local wasAvailable = step.available
	step.available = nil
	step.missingPrequests = {}
	step.skippedQuests = {}
	for _, element in ipairs(step.elements) do
		element.available = true
		if element.t == "ACCEPT" then
			if not element.completed then
				local missingPrequests = addon.getMissingPrequests(element.questId, function(id) return addon.quests[id].completed or scheduled.TURNIN[id] end)
				if #missingPrequests > 0 then
					element.available = false
					addon.currentGuide.unavailableQuests[element.questId] = true
					for _, id in ipairs(missingPrequests) do
						if not addon.contains(step.missingPrequests, id) then
							table.insert(step.missingPrequests, id)
						end
					end
				end
			end
		elseif element.t == "COMPLETE" or element.t == "TURNIN" then
			if not scheduled.ACCEPT[element.questId] and not element.completed and addon.quests[element.questId].logIndex == nil then
				element.available = false
				if scheduled.SKIP[element.questId] then
					if not addon.contains(step.skippedQuests, element.questId) then
						table.insert(step.skippedQuests, element.questId)
					end
				else
					if not addon.contains(step.missingPrequests, element.questId) then
						table.insert(step.missingPrequests, element.questId)
					end
				end
			end
		end
		if element.t == "ACCEPT" or element.t == "COMPLETE" or element.t == "TURNIN" then
			if not step.skip and element.available then
				scheduled[element.t][element.questId] = true
			elseif not scheduled[element.t][element.questId] and step.skip and not element.completed and addon.quests[element.questId].lastStep[element.t] == element then
				element.available = false
				scheduled.SKIP[element.questId] = true
			end
			if not element.completed then step.available = step.available and element.available end
			if not element.completed then step.available = step.available or element.available end
		elseif element.t == "XP" then
			if not element.completed then step.available = true end			
		end
	end
	if step.available == nil then step.available = true end
	if step.manual and not step.completed then step.available = true end

	if step.available ~= wasAvailable and not addon.contains(changedIndexes, i) then
		table.insert(changedIndexes, i)
	end
end

local function updateStepsCompletion(changedIndexes)
	--if addon.debugging then print("LIME: update steps completion") end
	addon.currentGuide.unavailableQuests = {}
	repeat
		local numNew = #changedIndexes
		local scheduled = {ACCEPT = {}, COMPLETE = {}, TURNIN = {}, SKIP = {}}
		for i, step in ipairs(addon.currentGuide.steps) do
			updateStepCompletion(i, changedIndexes)
			updateStepAvailability(i, changedIndexes, scheduled)
			if addon.mainFrame.steps ~= nil and addon.mainFrame.steps[i] ~= nil and addon.mainFrame.steps[i].visible then
				addon.mainFrame.steps[i]:SetChecked(step.completed or step.skip)
				addon.mainFrame.steps[i]:SetEnabled(not step.completed or step.skip)
			end
		end
	until(numNew == #changedIndexes)
	--if addon.debugging then print("LIME: changed", #changedIndexes) end
end

local function stepIsVisible(step)
	return ((not step.completed and (not step.skip or not step.available)) or GuidelimeDataChar.showCompletedSteps) and
			(step.available or GuidelimeDataChar.showUnavailableSteps)
end

local function keepFading()
	local update = false
	local isFading = false
	for i, step in ipairs(addon.currentGuide.steps)	do
		if step.fading ~= nil then
			if not stepIsVisible(step) then
				step.active = false
				--if addon.debugging then print("LIME: fade out", i, step.fading) end
				if step.fading <= 0 then
					step.fading = nil
					--if addon.debugging then print("LIME: fade out", i) end
					update = true
				else
					step.fading = step.fading - 0.05
					if addon.mainFrame.steps ~= nil and addon.mainFrame.steps[i] ~= nil and addon.mainFrame.steps[i].visible then
						addon.mainFrame.steps[i]:SetAlpha(step.fading)
					end
					isFading = true
				end
			else
				step.fading = nil
				if addon.mainFrame.steps ~= nil and addon.mainFrame.steps[i] ~= nil and addon.mainFrame.steps[i].visible then addon.mainFrame.steps[i]:SetAlpha(1) end
			end
		end
	end
	if isFading then
		C_Timer.After(0.1, function()
			keepFading()
		end)
	elseif update and (not GuidelimeDataChar.showCompletedSteps or not GuidelimeDataChar.showUnavailableSteps) then
		addon.updateMainFrame()
	end
end

local function fadeoutStep(indexes)
	for _, i in ipairs(indexes) do
		local step = addon.currentGuide.steps[i]
		step.fading = 1
	end
	keepFading()
end

local function stopFading()
	for _, step in ipairs(addon.currentGuide.steps)	do
		step.fading = nil
	end
end

local function updateStepsActivation()
	addon.currentGuide.activeQuests = {}
	for i, step in ipairs(addon.currentGuide.steps) do
		step.active = not step.completed and not step.skip and step.available
		if step.active then
			for j, pstep in ipairs(addon.currentGuide.steps) do
				if j == i then break end
				if not pstep.optional and not pstep.skip and not pstep.completed and pstep.available then
					step.active = false
					break
				end
			end
		end
		if step.active then
			for _, element in ipairs(step.elements) do
				if not element.completed and (element.t == "ACCEPT" or element.t == "TURNIN") then
					table.insert(addon.currentGuide.activeQuests, element.questId)
				end
			end
			if not step.wasActive then
				loadStepOnActivation(i)
				step.wasActive = true
			end
		end
	end
	-- accepting a follow up: maybe a quest dialog is still open and the quest just became active? try to accept it in that case
	if addon.contains(addon.currentGuide.activeQuests, addon.lastQuestOpened) then 
		AcceptQuest()
	end
end

local function updateFirstActiveIndex()
	local oldFirstActiveIndex = addon.currentGuide.firstActiveIndex
	addon.currentGuide.firstActiveIndex = nil
	addon.currentGuide.lastActiveIndex = nil
	for i, step in ipairs(addon.currentGuide.steps) do
		if (step.active or step.fading ~= nil) then
			if addon.currentGuide.firstActiveIndex == nil then addon.currentGuide.firstActiveIndex = i end
			addon.currentGuide.lastActiveIndex = i
		end
	end
	if addon.mainFrame.message ~= nil then
		for _, message in ipairs(addon.mainFrame.message) do
			if addon.currentGuide.firstActiveIndex ~= nil then
				message:Hide()
			else
				message:Show()
			end
		end
	end
	--if addon.debugging then print("LIME: firstActiveIndex ", addon.currentGuide.firstActiveIndex) end
	return oldFirstActiveIndex ~= addon.currentGuide.firstActiveIndex
end

local function getQuestActiveObjectives(id, objective)
	local objectiveList = addon.getQuestObjectives(id)
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
		if addon.quests[id] ~= nil and addon.quests[id].logIndex ~= nil and addon.quests[id].objectives ~= nil then	o = addon.quests[id].objectives[i] end
		if o == nil or (not o.done and o.desc ~= nil and o.desc ~= "") then
			table.insert(active, i)
		end
	end
	return active
end

function addon.updateStepsMapIcons()
	if addon.isEditorShowing() or addon.currentGuide == nil then return end
	addon.removeMapIcons()
	local hideArrow = true
	local highlight = true
	for _, step in ipairs(addon.currentGuide.steps) do
		if not step.skip and not step.completed and step.available then
			for _, element in ipairs(step.elements) do
				if element.t == "GOTO" and step.active and not element.completed then
					if element.specialLocation == "NEAREST_FLIGHT_POINT" and addon.x ~= nil and addon.y ~= nil then
						element.wx, element.wy, element.instance = addon.getNearestFlightPoint(addon.x, addon.y, addon.instance, addon.faction)
					end
					if element.wx ~= nil then
						addon.addMapIcon(element, highlight)
						if highlight then
							if GuidelimeDataChar.showArrow and addon.instance == element.instance then 
								addon.showArrow(element)
								hideArrow = false 
							end
							highlight = false
						end
					end
				elseif (element.t == "LOC" or element.t == "GOTO") and not element.completed and element.specialLocation == nil then
					local found = true
					if element.objectives ~= nil and element.attached ~= nil and element.attached.questId ~= nil then
						local objectives = getQuestActiveObjectives(element.attached.questId, element.attached.objective)
						found = false
						for _, o in ipairs(element.objectives) do
							if addon.contains(objectives, o) then found = true; break; end
						end
					end
					if found then addon.addMapIcon(element, false) end
				end
			end
		end
	end
	if hideArrow then addon.hideArrow() end
	addon.showMapIcons()
end

function addon.updateStepsText(scrollToFirstActive)
	--if addon.debugging then print("LIME: update step texts") end
	if addon.mainFrame == nil then return end
	if addon.currentGuide == nil then return end
	for i in ipairs(addon.currentGuide.steps) do
		updateStepText(i)
	end
	if scrollToFirstActive then
		C_Timer.After(0.2, function()
			if addon.currentGuide.firstActiveIndex ~= nil and
				addon.mainFrame.steps ~= nil and
				addon.mainFrame.steps[addon.currentGuide.firstActiveIndex] ~= nil and
				addon.mainFrame.steps[addon.currentGuide.firstActiveIndex]:GetTop() ~= nil then
				addon.mainFrame.scrollFrame:SetVerticalScroll(
					addon.mainFrame:GetTop()
					- addon.mainFrame.steps[addon.currentGuide.firstActiveIndex]:GetTop()
					+ addon.mainFrame.scrollFrame:GetVerticalScroll()
					- 20)
			end
		end)
	end
end

function addon.updateSteps(completedIndexes)
	if addon.mainFrame == nil then return end
	if addon.currentGuide == nil then return end
	if addon.showingTooltip then GameTooltip:Hide(); addon.showingTooltip = false end
	if completedIndexes == nil then completedIndexes = {} end
	--local time
	--if addon.debugging then time = debugprofilestop() end
	--if addon.debugging then print("LIME: update steps " .. GetTime()) end
	updateStepsCompletion(completedIndexes)
	--if addon.debugging then print("LIME: updateStepsCompletion " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	updateStepsActivation()
	--if addon.debugging then print("LIME: updateStepsActivation " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	fadeoutStep(completedIndexes)
	--if addon.debugging then print("LIME: fadeoutStep " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	local scrollToFirstActive = updateFirstActiveIndex()
	--if addon.debugging then print("LIME: updateFirstActiveIndex " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	addon.updateStepsMapIcons()
	--if addon.debugging then print("LIME: updateStepsMapIcons " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	addon.updateStepsText(scrollToFirstActive)
	--if addon.debugging then print("LIME: updateStepsText " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
end

local function showContextMenu()
	EasyMenu({
		{text = L.AVAILABLE_GUIDES .. "...", checked = addon.isGuidesShowing(), func = addon.showGuides},
		{text = GAMEOPTIONS_MENU .. "...", checked = addon.isOptionsShowing(), func = addon.showOptions},
		{text = L.EDITOR .. "...", checked = addon.isEditorShowing(), func = addon.showEditor},
		{text = L.SHOW_COMPLETED_STEPS, checked = GuidelimeDataChar.showCompletedSteps, func = function()
			GuidelimeDataChar.showCompletedSteps = not GuidelimeDataChar.showCompletedSteps
			if addon.optionsFrame ~= nil then
				addon.optionsFrame.showCompletedSteps:SetChecked(GuidelimeDataChar.showCompletedSteps)
			end
			addon.updateMainFrame()
		end},
		{text = L.SHOW_UNAVAILABLE_STEPS, checked = GuidelimeDataChar.showUnavailableSteps, func = function()
			GuidelimeDataChar.showUnavailableSteps = not GuidelimeDataChar.showUnavailableSteps
			if addon.optionsFrame ~= nil then
				addon.optionsFrame.showUnavailableSteps:SetChecked(GuidelimeDataChar.showUnavailableSteps)
			end
			addon.updateMainFrame()
		end}
	}, CreateFrame("Frame", nil, nil, "UIDropDownMenuTemplate"), "cursor", 0 , 0, "MENU");
end

local function setStepSkip(value, a, b)
	if a == nil then a = 1; b = #addon.currentGuide.steps end
	if b == nil then b = a end
	local indexes = {}
	for i = a, b do
		local step = addon.currentGuide.steps[i]
		step.skip = value
		GuidelimeDataChar.guideSkip[addon.currentGuide.name][i] = step.skip
		table.insert(indexes, i)
	end
	if not value and not GuidelimeDataChar.showUnavailableSteps then
		addon.updateMainFrame()
	else
		addon.updateSteps(indexes)
	end
end

local function skipCurrentSteps()
	if addon.currentGuide ~= nil and addon.currentGuide.firstActiveIndex ~= nil and
		addon.currentGuide.lastActiveIndex ~= nil then
		setStepSkip(true, addon.currentGuide.firstActiveIndex, addon.currentGuide.lastActiveIndex)
	end
end

function addon.completeSemiAutomaticByType(t)
	if addon.currentGuide ~= nil and addon.currentGuide.firstActiveIndex ~= nil and
		addon.currentGuide.lastActiveIndex ~= nil then
		for i = addon.currentGuide.firstActiveIndex, addon.currentGuide.lastActiveIndex do
			local step = addon.currentGuide.steps[i]
			--if addon.debugging then print("LIME:", step.text, step.optional) end
			for _, element in ipairs(step.elements) do
				if not element.completed and element.t == t then
					addon.completeSemiAutomatic(element)
					return
				end
			end
		end
	end
end

function addon.completeSemiAutomatic(element)
	element.completed = true
	local step = element.step
	local complete = true
	if not step.manual then
		for _, element in ipairs(step.elements) do
			if not element.optional then
				if element.t == "ACCEPT" or
					element.t == "COMPLETE" or
					element.t == "TURNIN" or
					element.t == "XP" then
					if not element.completed then 
						addon.updateSteps()
						return
					end
				end
			end
		end
	end
	setStepSkip(true, step.index) 
end

function addon.updateMainFrame(reset)
	if addon.mainFrame == nil then return end
	if addon.debugging then print("LIME: updating main frame") end

	if addon.showingTooltip then GameTooltip:Hide(); addon.showingTooltip = false end
	if addon.mainFrame.steps == nil then
		addon.mainFrame.steps = {}
	else
		for _, step in pairs(addon.mainFrame.steps) do
			if step.visible then
				step.visible = false
				step:Hide()
			end
		end
		if reset then addon.mainFrame.steps = {} end
	end
	if addon.mainFrame.message ~= nil then
		for _, message in ipairs(addon.mainFrame.message) do
			message:Hide()
		end
	end
	addon.mainFrame.message = {}
	stopFading()

	if addon.currentGuide == nil or addon.currentGuide.name == nil then
		if addon.debugging then print("LIME: No guide loaded") end
		addon.mainFrame.message[1] = addon.addMultilineText(addon.mainFrame.scrollChild, L.NO_GUIDE_LOADED, addon.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button)
			if (button == "RightButton") then
				showContextMenu()
			else
				addon.showGuides()
			end
		end)
		addon.mainFrame.message[1]:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize)
		addon.mainFrame.message[1]:SetPoint("TOPLEFT", addon.mainFrame.scrollChild, "TOPLEFT", 10, -25)
		addon.mainFrame.message[1]:Show()
	else
		addon.mainFrame.message = {}
		local nextGuides = {}
		local demo = false
		if addon.currentGuide.next ~= nil then
			for i, next in ipairs(addon.currentGuide.next) do
				if addon.guides[addon.currentGuide.group .. " " .. next] == nil and addon.currentGuide.download ~= nil then 
					demo = true
				elseif addon.applies(addon.guides[addon.currentGuide.group .. " " .. next]) then
					table.insert(nextGuides, next)
				end
			end
		end
		if nextGuides == {} then
			addon.mainFrame.message[1] = addon.addMultilineText(addon.mainFrame.scrollChild, L.GUIDE_FINISHED, addon.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button)
				if (button == "RightButton") then
					showContextMenu()
				else
					addon.showGuides()
				end
			end)
			addon.mainFrame.message[1]:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize)
			addon.mainFrame.message[1]:Hide()
			local guide = addon.guides[addon.currentGuide.name]
			if demo then
				addon.mainFrame.message[2] = addon.addMultilineText(addon.mainFrame.scrollChild, 
					string.format(L.DOWNLOAD_FULL_GUIDE, guide.downloadMinLevel, guide.downloadMaxLevel, guide.download, "\n|cFFAAAAAA" .. guide.downloadUrl), 
					addon.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button)
					if (button == "RightButton") then
						showContextMenu()
					else
						addon.showUrlPopup(guide.downloadUrl) 
					end
				end)
				addon.mainFrame.message[2]:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize)
				addon.mainFrame.message[2]:Hide()
			end
		else
			for i, next in ipairs(nextGuides) do
				local msg
				if i == 1 then
					msg = L.GUIDE_FINISHED_NEXT:format(addon.COLOR_WHITE .. next .. "|r")
				else
					msg = L.GUIDE_FINISHED_NEXT_ALT:format(addon.COLOR_WHITE .. next .. "|r")
				end
				addon.mainFrame.message[i] = addon.addMultilineText(addon.mainFrame.scrollChild, msg, addon.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button)
					if (button == "RightButton") then
						showContextMenu()
					else
						addon.loadGuide(addon.currentGuide.group .. " " .. next)
					end
				end)
				addon.mainFrame.message[i]:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize)
				addon.mainFrame.message[i]:Hide()
			end
		end
		
		--if addon.debugging then print("LIME: Showing guide " .. addon.currentGuide.name) end
		addon.updateSteps()

		local time
		if addon.debugging then time = debugprofilestop() end

		addon.mainFrame.titleBox:SetText(addon.currentGuide.name)
		addon.mainFrame.titleBox:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize)
		local prev = addon.mainFrame.titleBox
		for i, step in ipairs(addon.currentGuide.steps) do
			if stepIsVisible(step) then
				if step.active or GuidelimeData.maxNumOfSteps == 0 or i - addon.currentGuide.lastActiveIndex < GuidelimeData.maxNumOfSteps then
					if addon.mainFrame.steps[i] == nil then 
						addon.mainFrame.steps[i] = addon.addCheckbox(addon.mainFrame.scrollChild, nil, "") 
						addon.mainFrame.steps[i]:SetScript("OnClick", function()
							if not addon.mainFrame.steps[i]:GetChecked() or addon.mainFrame.steps[i].skipText == nil or addon.mainFrame.steps[i].skipText == "" then
								setStepSkip(addon.mainFrame.steps[i]:GetChecked(), i)
							else
								addon.mainFrame.steps[i]:SetChecked(false)
								local _, lines = addon.mainFrame.steps[i].skipText:gsub("\n", "\n")
								--if addon.debugging then print("LIME: " .. addon.mainFrame.steps[i].skipText .. lines) end
								addon.createPopupFrame(addon.mainFrame.steps[i].skipText, function()
									addon.mainFrame.steps[i]:SetChecked(true)
									setStepSkip(true, i)
								end, true, 120 + lines * 10):Show()
							end
						end)
						addon.mainFrame.steps[i].textBox = addon.addMultilineText(addon.mainFrame.steps[i], nil, addon.mainFrame.scrollChild:GetWidth() - 40, "", function(self, button)
							if button == "RightButton" then
								showContextMenu()
							elseif self.url ~= nil then
								addon.showUrlPopup(self.url) 
							end
						end)
						addon.mainFrame.steps[i].textBox:SetFont(GameFontNormal:GetFont(), GuidelimeDataChar.mainFrameFontSize)
						addon.mainFrame.steps[i].textBox:SetPoint("TOPLEFT", addon.mainFrame.steps[i], "TOPLEFT", 35, -9)
					end
					addon.mainFrame.steps[i]:SetAlpha(1)
					addon.mainFrame.steps[i]:Show()
					addon.mainFrame.steps[i].visible = true
					addon.mainFrame.steps[i]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -35, -2)
					addon.mainFrame.steps[i]:SetChecked(step.completed or step.skip)
					addon.mainFrame.steps[i]:SetEnabled(not step.completed or step.skip)

					addon.mainFrame.steps[i].textBox:Show()
					updateStepText(i)

					prev = addon.mainFrame.steps[i].textBox
				end
			end
		end

		for i, message in ipairs(addon.mainFrame.message) do
			if i == 1 then
				message:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -25, -15)
			else
				message:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -15)
			end
			prev = message
		end
		
		if addon.debugging then print("LIME: updateMainFrame " .. math.floor(debugprofilestop() - time) .. " ms"); time = debugprofilestop() end
	end
end

function addon.showMainFrame()

	if not addon.dataLoaded then addon.loadData() end

	if addon.mainFrame == nil then
		--if addon.debugging then print("LIME: initializing main frame") end
		addon.mainFrame = CreateFrame("FRAME", nil, UIParent)
		addon.mainFrame:SetWidth(GuidelimeDataChar.mainFrameWidth)
		addon.mainFrame:SetHeight(GuidelimeDataChar.mainFrameHeight)
		addon.mainFrame:SetPoint(GuidelimeDataChar.mainFrameRelative, UIParent, GuidelimeDataChar.mainFrameRelative, GuidelimeDataChar.mainFrameX, GuidelimeDataChar.mainFrameY)
		addon.mainFrame.bg = addon.mainFrame:CreateTexture(nil, "BACKGROUND")
		addon.mainFrame.bg:SetAllPoints(addon.mainFrame)
		addon.mainFrame.bg:SetColorTexture(0, 0, 0, GuidelimeDataChar.mainFrameAlpha)
		addon.mainFrame:SetFrameLevel(999)
		addon.mainFrame:SetMovable(true)
		addon.mainFrame:EnableMouse(true)
		addon.mainFrame:SetScript("OnMouseDown", function(self, button)
			if (button == "LeftButton" and not GuidelimeDataChar.mainFrameLocked) then addon.mainFrame:StartMoving() end
		end)
		addon.mainFrame:SetScript("OnMouseUp", function(self, button)
			if (button == "LeftButton") then
				addon.mainFrame:StopMovingOrSizing()
				local _
				_, _, GuidelimeDataChar.mainFrameRelative, GuidelimeDataChar.mainFrameX, GuidelimeDataChar.mainFrameY = addon.mainFrame:GetPoint()
			elseif (button == "RightButton") then
				showContextMenu()
			end
		end)

		addon.mainFrame.scrollFrame = CreateFrame("SCROLLFRAME", nil, addon.mainFrame, "UIPanelScrollFrameTemplate")
		addon.mainFrame.scrollFrame:SetAllPoints(addon.mainFrame)

		addon.mainFrame.scrollChild = CreateFrame("FRAME", nil, addon.mainFrame)
		addon.mainFrame.scrollFrame:SetScrollChild(addon.mainFrame.scrollChild);
		addon.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		addon.mainFrame.scrollChild:SetHeight(addon.mainFrame:GetHeight())
		
		if not GuidelimeDataChar.mainFrameShowScrollBar then addon.mainFrame.scrollFrame.ScrollBar:SetAlpha(0) end

		addon.mainFrame.titleBox = addon.addMultilineText(addon.mainFrame.scrollChild, nil, addon.mainFrame.scrollChild:GetWidth() - 40, "")
		addon.mainFrame.titleBox:SetPoint("TOPLEFT", addon.mainFrame.scrollChild, "TOPLEFT", 35, -14)
		
		if addon.firstLogUpdate then
			addon.updateMainFrame()
		end

		addon.mainFrame.doneBtn = CreateFrame("BUTTON", "doneBtn", addon.mainFrame)
		addon.mainFrame.doneBtn:SetFrameLevel(9999)
		addon.mainFrame.doneBtn:SetSize(24, 24)
		addon.mainFrame.doneBtn:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
		addon.mainFrame.doneBtn:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight")
		addon.mainFrame.doneBtn:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
		addon.mainFrame.doneBtn:SetPoint("TOPRIGHT", addon.mainFrame, "TOPRIGHT", 0,0)
		addon.mainFrame.doneBtn:SetScript("OnClick", function()
			addon.hideMainFrame()
		end)

		addon.mainFrame.lockBtn = CreateFrame("BUTTON", "lockBtn", addon.mainFrame)
		addon.mainFrame.lockBtn:SetFrameLevel(9999)
		addon.mainFrame.lockBtn:SetSize(24, 24)
		addon.mainFrame.lockBtn:SetPoint("TOPRIGHT", addon.mainFrame, "TOPRIGHT", -20,0)
		if GuidelimeDataChar.mainFrameLocked then
			addon.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Unlocked-Down")
			addon.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Locked-Up")
		else
			addon.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Unlocked-Down")
			addon.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Locked-Up")
		end
		addon.mainFrame.lockBtn:SetScript("OnClick", function()
			GuidelimeDataChar.mainFrameLocked = not GuidelimeDataChar.mainFrameLocked
			if addon.optionsFrame ~= nil then addon.optionsFrame.mainFrameLocked:SetChecked(GuidelimeDataChar.mainFrameLocked) end
			if GuidelimeDataChar.mainFrameLocked then
				addon.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Unlocked-Down")
				addon.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Locked-Up")
			else
				addon.mainFrame.lockBtn:SetNormalTexture("Interface/Buttons/LockButton-Unlocked-Down")
				addon.mainFrame.lockBtn:SetPushedTexture("Interface/Buttons/LockButton-Locked-Up")
			end
		end)

		if addon.debugging then
			addon.mainFrame.reloadBtn = CreateFrame("BUTTON", nil, addon.mainFrame, "UIPanelButtonTemplate")
			addon.mainFrame.reloadBtn:SetFrameLevel(9999)
			addon.mainFrame.reloadBtn:SetWidth(12)
			addon.mainFrame.reloadBtn:SetHeight(16)
			addon.mainFrame.reloadBtn:SetText( "R" )
			addon.mainFrame.reloadBtn:SetPoint("TOPRIGHT", addon.mainFrame, "TOPRIGHT", -45, -4)
			addon.mainFrame.reloadBtn:SetScript("OnClick", function()
				ReloadUI()
			end)
		end
	end
	addon.mainFrame:Show()
	addon.updateSteps()
	GuidelimeDataChar.mainFrameShowing = true
	if addon.optionsFrame ~= nil then addon.optionsFrame.mainFrameShowing:SetChecked(true) end
end

function addon.hideMainFrame()
	if addon.mainFrame ~= nil then addon.mainFrame:Hide() end
	addon.removeMapIcons()
	GuidelimeDataChar.mainFrameShowing = false
	if addon.optionsFrame ~= nil then addon.optionsFrame.mainFrameShowing:SetChecked(false) end
end

local function simulateCompleteCurrentSteps()
	if addon.currentGuide ~= nil and addon.currentGuide.firstActiveIndex ~= nil and
		addon.currentGuide.lastActiveIndex ~= nil then
		--if addon.debugging then print("LIME:", addon.currentGuide.firstActiveIndex, addon.currentGuide.lastActiveIndex) end
		for i = addon.currentGuide.firstActiveIndex, addon.currentGuide.lastActiveIndex do
			local step = addon.currentGuide.steps[i]
			--if addon.debugging then print("LIME:", step.text, step.optional) end
			for _, element in ipairs(step.elements) do
				if not element.completed then
					if element.t == "ACCEPT" then
						if addon.quests[element.questId] == nil then addon.quests[element.questId] = {} end
						addon.quests[element.questId].logIndex = -1
					elseif element.t == "COMPLETE" then
						if addon.quests[element.questId] == nil then addon.quests[element.questId] = {} end
						addon.quests[element.questId].finished = true
					elseif element.t == "TURNIN" then
						if addon.quests[element.questId] == nil then addon.quests[element.questId] = {} end
						addon.quests[element.questId].completed = true
					end
				end
			end
		end
		addon.updateSteps()
	end
end

local function listAliasQuests(completed, id, excludeIds)
	local text = ""
	for _, id2 in ipairs(addon.getPossibleQuestIdsByName(addon.questsDB[id].name)) do
		if id2 ~= id and not addon.contains(excludeIds, ids) then
			text = text .. "Quest \"" .. addon.questsDB[id2].name .. "\"(" .. id2 .. ") "
			if not completed[id2] then text = text .. "not " end
			text = text .. "completed.\r"
		end
	end
	return text
end

function addon.checkQuests()
	local completed = GetQuestsCompleted()
	local count = 0
	local text = ""
	for id, value in pairs(completed) do
		count = count + 1
		if addon.questsDB[id] ~= nil then
			local missingPrequests = addon.getMissingPrequests(id, function(id) return completed[id] end)
			local found = false
			local ids = {id}
			for _, pid in ipairs(missingPrequests) do
				text = text .. "Quest \"" .. addon.questsDB[id].name .. "\"(" .. id .. ") was completed but prequest \"" .. addon.questsDB[pid].name .. "\"(" .. pid .. ") was not.\r"
				text = text .. listAliasQuests(completed, pid, ids)
				table.insert(ids, pid)
				found = true
			end
			if addon.questsDB[id].replacement ~= nil and not completed[addon.questsDB[id].replacement] then
				text = text .. "Quest \"" .. addon.questsDB[id].name .. "\"(" .. id .. ") was completed but is marked as being replaced by \"" .. addon.questsDB[addon.questsDB[id].replacement].name .. "\"(" .. addon.questsDB[id].replacement .. ") which is not completed.\r"
				table.insert(ids, addon.questsDB[id].replacement)
				found = true
			end
			if not addon.applies(addon.questsDB[id]) then
				text = text .. "Quest \"" .. addon.questsDB[id].name .. "\"(" .. id .. ") was completed but is marked as being unavailable for this character.\r"
				found = true
			end
			--[[if addon.questsDB[id].replaces ~= nil and not completed[addon.questsDB[id].replaces] then
				text = text .. "Quest \"" .. addon.questsDB[id].name .. "\"(" .. id .. ") was completed but is marked as being replacement for \"" .. addon.questsDB[addon.questsDB[id].replaces].name .. "\"(" .. addon.questsDB[id].replaces .. ") which is not completed.\r"
				table.insert(ids, addon.questsDB[id].replaces)
				found = true
			end]]
			if found then text = text .. listAliasQuests(completed, id, ids) .. "\r" end
		--else
			--text = text .. "Unknown quest " .. id .. " completed.\r"
		end
	end
	if text == "" then 
		print ("LIME: " .. string.format(L.CHECK_QUESTS_COMPLETED, count))
		print ("LIME: " .. L.CHECK_QUESTS_NO_INCONSISTENCIES) 
	else 
		local regions = {"US", "KR", "EU", "TW", "CN", "?"}
		text = "Reported by " .. (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")  .. "(" .. regions[GetCurrentRegion() or 6] .. "), " .. 
			(addon.level or "?")  .. " " .. (addon.race or "?")  .. " " .. (addon.class or "?")  .. "," ..
			" at " .. date("%Y/%m/%d %H:%M:%S", GetServerTime()) .. 
			" with " .. GetAddOnMetadata(addonName, "title") .. " " .. GetAddOnMetadata(addonName, "version") .. "\r\n" .. text
		text = string.format(L.CHECK_QUESTS, addon.CONTACT_DISCORD, addon.CONTACT_CURSEFORGE, addon.CONTACT_REDDIT) .. "\r\n" .. text
		text = string.format(L.CHECK_QUESTS_COMPLETED, count) .. ".\r" .. text
		local popup = addon.showCopyPopup(text, "", 0, 500, true)
	end
end

SLASH_Guidelime1 = "/lime"
SLASH_Guidelime2 = "/guidelime"
function SlashCmdList.Guidelime(msg)
	if msg == '' then if GuidelimeDataChar.mainFrameShowing then addon.hideMainFrame() else addon.showMainFrame() end
	elseif msg == 'debug true' and not addon.debugging then GuidelimeData.debugging = true; ReloadUI()
	elseif msg == 'debug false' and addon.debugging then GuidelimeData.debugging = false; ReloadUI()
	elseif msg == 'complete' then simulateCompleteCurrentSteps()
	elseif msg == 'skip' then skipCurrentSteps()
	elseif msg == 'questie true' and not GuidelimeData.dataSourceQuestie then GuidelimeData.dataSourceQuestie = true; ReloadUI()
	elseif msg == 'questie false' and GuidelimeData.dataSourceQuestie then GuidelimeData.dataSourceQuestie = false; ReloadUI()
	elseif msg == 'quests' then addon.checkQuests()
	end
end
