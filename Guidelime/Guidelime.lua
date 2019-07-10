local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")

addon.frame = CreateFrame("Frame", addonName .. "Frame", UIParent)
Guidelime = {}

addon.COLOR_INACTIVE = "|cFF666666"
addon.COLOR_QUEST_DEFAULT = "|cFF59C4F1"
addon.COLOR_LEVEL_RED = "|cFFFF1400"
addon.COLOR_LEVEL_ORANGE = "|cFFFFA500"
addon.COLOR_LEVEL_YELLOW = "|cFFFFFF00"
addon.COLOR_LEVEL_GREEN = "|cFF008000"
addon.COLOR_LEVEL_GRAY = "|cFF808080"
addon.MAINFRAME_ALPHA_MAX = 85
addon.AUTO_COMPLETE_DELAY = 0.8

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
	MAP = "Interface\\Addons\\Guidelime\\Icons\\lime",
	MAP_ARROW = "Interface\\Addons\\Guidelime\\Icons\\lime_arrow",
	MAP_MARKER = "Interface\\Addons\\Guidelime\\Icons\\lime_marker",
	COMPLETED = "Interface\\Buttons\\UI-CheckBox-Check",
	UNAVAILABLE = "Interface\\Buttons\\UI-GroupLoot-Pass-Up", -- or rather "Interface\\Buttons\\UI-StopButton" (yellow x) ?
	
	QUEST = "Interface\\GossipFrame\\ActiveQuestIcon",
	ACCEPT = "Interface\\GossipFrame\\AvailableQuestIcon",
	ACCEPT_UNAVAILABLE = "Interface\\Addons\\Guidelime\\Icons\\questunavailable",
	COMPLETE = "Interface\\GossipFrame\\BattleMasterGossipIcon",
	WORK = "Interface\\GossipFrame\\BattleMasterGossipIcon",
	TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon",
	TURNIN_INCOMPLETE = "Interface\\GossipFrame\\IncompleteQuestIcon",
	SET_HEARTH = "Interface\\Addons\\Guidelime\\Icons\\set_hearth", -- made from "Interface\\Icons\\INV_Drink_05", nicer than the actual "Interface\\GossipFrame\\BinderGossipIcon" ?
	VENDOR = "Interface\\GossipFrame\\VendorGossipIcon",
	REPAIR = "Interface\\Addons\\Guidelime\\Icons\\repair", -- made from "Interface\\Icons\\Trade_BlackSmithing",
	HEARTH = "Interface\\Addons\\Guidelime\\Icons\\hearth", -- made from "Interface\\Icons\\INV_Misc_Rune_01",
	FLY = "Interface\\GossipFrame\\TaxiGossipIcon",
	TRAIN = "Interface\\GossipFrame\\TrainerGossipIcon",
	GET_FLIGHT_POINT = "Interface\\Addons\\Guidelime\\Icons\\getflightpoint",
	GOTO = "Interface\\Addons\\Guidelime\\Icons\\lime0",
	
	--LOC = "Interface\\Icons\\Ability_Tracking",
	--GOTO = "Interface\\Icons\\Ability_Tracking",

	--KILL = "Interface\\Icons\\Ability_Creature_Cursed_02",
	--MAP = "Interface\\Icons\\Ability_Spy",
	--SETHEARTH = "Interface\\AddOns\\TourGuide\\resting.tga",
	--NOTE = "Interface\\Icons\\INV_Misc_Note_01",
	--USE = "Interface\\Icons\\INV_Misc_Bag_08",
	--BUY = "Interface\\Icons\\INV_Misc_Coin_01",
	--BOAT = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
}

addon.factions = {"Alliance", "Horde"}
addon.races = {Human = "Alliance", NightElf = "Alliance", Dwarf = "Alliance", Gnome = "Alliance", Orc = "Horde", Troll = "Horde", Tauren = "Horde", Undead = "Horde"}
addon.classes = {"Warrior", "Rogue", "Mage", "Warlock", "Hunter", "Priest", "Druid", "Paladin", "Shaman"}
addon.classesWithFaction = {Paladin = "Alliance", Shaman = "Horde"}

function addon.getClass(class)
	for i, c in ipairs(addon.classes) do
		if c:upper() == class:upper() then return c end
	end
end
function addon.isClass(class)
	return addon.getClass(class) ~= nil
end
function addon.getRace(race)
	for r, f in pairs(addon.races) do
		if r:upper() == race:upper() then return r end
	end
	if race:upper() == "SCOURCE" then return "Undead" end
end
function addon.isRace(race)
	return addon.getRace(race) ~= nil
end
function addon.getFaction(faction)
	for i, f in ipairs(addon.factions) do
		if f:upper() == faction:upper() then return f end
	end
end
function addon.isFaction(faction)
	return addon.getFaction(faction) ~= nil
end


local _
_, addon.class = UnitClass("player")
_, addon.race = UnitRace("player"); addon.race = addon.race:upper()
addon.faction = UnitFactionGroup("player")
addon.level = UnitLevel("player")
addon.xp = UnitXP("player")
addon.xpMax = UnitXPMax("player")
addon.y, addon.x = UnitPosition("player")
addon.face = GetPlayerFacing()

addon.guides = {}
addon.queryingPositions = false
addon.dataLoaded = false

function addon.contains(array, value)
	for i, v in ipairs(array) do
		if type(value) == "function" then
			if value(v) then return true end
		else
			if v == value then return true end
		end
	end
	return false
end

function addon.containsIgnoreCase(array, value)
	return addon.contains(array, function(v) return v:upper() == value:upper() end)
end

function addon.containsKey(table, value)
	for k, v in pairs(table) do
		if type(value) == "function" then
			if value(k) then return true end
		else
			if k == value then return true end
		end
	end
	return false
end

function Guidelime.registerGuide(guide, group)
	guide = addon.parseGuide(guide, group)	
	if addon.debugging then print("LIME: ", guide.name) end
	if addon.guides[guide.name] ~= nil then error("There is more than one guide with the name \"" .. guide.name .. "\"") end
	addon.guides[guide.name] = guide
	return guide
end

local function loadData()
	local defaultOptions = {
		debugging = false,
		showQuestLevels = false,
		showTooltips = true,
		maxNumOfMarkers = 10
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
		hideCompletedSteps = true,
		hideUnavailableSteps = true,
		autoCompleteQuest = true,
		showArrow = true,
		arrowX = 0,
		arrowY = -20,
		arrowRelative = "TOP",
		arrowAlpha = 0.8
	}
	if GuidelimeData == nil then
		GuidelimeData = {
			version = version
		}
	end
	if GuidelimeDataChar == nil then
		GuidelimeDataChar = {
			version = version
		}
	end
	for option, default in pairs(defaultOptions) do
		if GuidelimeData[option] == nil then GuidelimeData[option] = default end
	end
	for option, default in pairs(defaultOptionsChar) do
		if GuidelimeDataChar[option] == nil then GuidelimeDataChar[option] = default end
	end
	
	addon.debugging = GuidelimeData.debugging
	
	if GuidelimeData.customGuides ~= nil then
		for name, guide in pairs(GuidelimeData.customGuides) do
			Guidelime.registerGuide(guide, L.CUSTOM_GUIDES)
		end
	end
	
	addon.loadCurrentGuide()
	
	addon.dataLoaded = true

	--if addon.debugging then print("LIME: Initializing...") end
end

function addon.loadCurrentGuide()

	if GuidelimeDataChar.currentGuide == nil then GuidelimeDataChar.currentGuide = {} end
	if GuidelimeDataChar.currentGuide.skip == nil then 
		GuidelimeDataChar.currentGuide.skip = {}
	end
		
	addon.currentGuide = {}
	addon.currentGuide.name = GuidelimeDataChar.currentGuide.name
	addon.currentGuide.steps = {}
	addon.quests = {}
	if addon.guides[GuidelimeDataChar.currentGuide.name] == nil then 
		if addon.debugging then
			print("LIME: available guides:")
			for name, guide in pairs(addon.guides) do
				print("LIME: " .. name)
			end
			print("LIME: guide \"" .. (GuidelimeDataChar.currentGuide.name or "") .. "\" not found")
		end
		GuidelimeDataChar.currentGuide.name = nil
		addon.currentGuide.name = nil
		return
	end
	addon.currentGuide.next = addon.guides[GuidelimeDataChar.currentGuide.name].next
	addon.currentGuide.group = addon.guides[GuidelimeDataChar.currentGuide.name].group
	
	--print(format(L.LOAD_MESSAGE, addon.currentGuide.name))
	
	local completed = GetQuestsCompleted()

	for i, step in ipairs(addon.guides[GuidelimeDataChar.currentGuide.name].steps) do
		local loadLine = true
		if step.race ~= nil then
			if not addon.contains(step.race, addon.race) then loadLine = false end
		end
		if step.class ~= nil then
			if not addon.contains(step.class, addon.class) then loadLine = false end
		end
		if step.faction ~= nil and step.faction ~= addon.faction then loadLine = false end
		if #step.elements == 0 then loadLine = false end
		if loadLine then
			table.insert(addon.currentGuide.steps, step) 
			step.trackQuest = {}
			for j, element in ipairs(step.elements) do
				element.available = true
				
				if element.t == "ACCEPT" or element.t == "COMPLETE" or element.t == "TURNIN" or element.t == "LEVEL" then 
					if step.manual == nil then step.manual = false end
					step.completeWithNext = false
				elseif element.t == "TRAIN" or element.t == "VENDOR" or element.t == "REPAIR" or element.t == "SET_HEARTH" or element.t == "GET_FLIGHT_POINT" then 
					step.manual = true
					step.completeWithNext = false
				elseif element.t == "GOTO" then 
					if step.manual == nil then step.manual = false end
					if step.completeWithNext == nil then step.completeWithNext = true end
				elseif element.t == "FLY" or element.t == "HEARTH" then 
					if step.completeWithNext == nil then step.completeWithNext = true end
				end
				if element.questId ~= nil then
					if addon.quests[element.questId] == nil then
						if addon.quests[element.questId] == nil then addon.quests[element.questId] = {} end
						addon.quests[element.questId].title = element.title
						addon.quests[element.questId].completed = completed[element.questId] ~= nil and completed[element.questId]
						addon.quests[element.questId].finished = addon.quests[element.questId].completed
						if addon.questsDB[element.questId].prequests ~= nil then
							for i, id in ipairs(addon.questsDB[element.questId].prequests) do
								if addon.quests[id] == nil then addon.quests[id] = {} end
								addon.quests[id].completed = completed[id] ~= nil and completed[id]
								if addon.quests[id].followup == nil then addon.quests[id].followup = {} end
								table.insert(addon.quests[id].followup, element.questId)
							end
						end
					end
					if element.t == "COMPLETE" or element.t == "TURNIN" or element.t == "WORK" then
						if element.objective == nil then
							step.trackQuest[element.questId] = true
						else
							step.trackQuest[element.questId] = element.objective
						end
					end
				end
			end
			if step.manual == nil then step.manual = true end
			if step.completeWithNext == nil then step.compleWithNext = not step.manual end
			if step.completeWithNext then step.optional = true end
			if step.optional == nil then step.optional = false end
			step.skip = GuidelimeDataChar.currentGuide.skip[#addon.currentGuide.steps] ~= nil and GuidelimeDataChar.currentGuide.skip[#addon.currentGuide.steps]
			step.active = false
			step.completed = false
			step.available = true
		end
	end
	
	-- output complete parsed guide for debugging only
	--if addon.debugging then
	--	addon.currentGuide.skip = GuidelimeDataChar.currentGuide.skip
	--	GuidelimeDataChar.currentGuide = addon.currentGuide
	--end
end

local function getQuestText(id, t, title, colored)
	local q = ""
	if GuidelimeData.showQuestLevels then
		q = q .. addon.getLevelColor(addon.questsDB[id].level)
		q = q .. "[" .. addon.questsDB[id].level .. "] "
		if colored == nil or colored then 
			q = q .. "|r"
		else
			q = q .. addon.COLOR_INACTIVE
		end
	end
	if colored == nil or colored then q = q .. addon.COLOR_QUEST_DEFAULT end
	q = q .. (title or addon.questsDB[id].name)
	if colored == nil or colored then q = q .. "|r" end
	return q
end

local function updateStepText(i)
	local step = addon.currentGuide.steps[i]
	if addon.mainFrame.steps == nil or addon.mainFrame.steps[i] == nil or addon.mainFrame.steps[i].textBox == nil then return end
	local text = ""
	local tooltip = ""
	local skipTooltip = ""
	if addon.debugging then text = text .. i .. " " end
	if not step.active then
		text = text .. addon.COLOR_INACTIVE
	elseif step.manual then
		if skipTooltip ~= "" then skipTooltip = skipTooltip .. "\n" end
		skipTooltip = L.STEP_MANUAL
	else
		if skipTooltip ~= "" then skipTooltip = skipTooltip .. "\n" end
		skipTooltip = L.STEP_SKIP
	end
	for j, element in ipairs(step.elements) do
		if element.hidden == nil or not element.hidden then
			if not element.available then
				text = text .. "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
			elseif element.completed then
				text = text .. "|T" .. addon.icons.COMPLETED .. ":12|t"
			elseif element.t == "ACCEPT" and addon.questsDB[element.questId].req > addon.level then
				text = text .. "|T" .. addon.icons.ACCEPT_UNAVAILABLE .. ":12|t"
				if tooltip ~= "" then tooltip = tooltip .. "\n" end
				local q = getQuestText(element.questId, "ACCEPT")
				tooltip = tooltip .. L.QUEST_REQUIRED_LEVEL:format(q, addon.questsDB[element.questId].req)
			elseif element.t == "TURNIN" and not element.finished then
				text = text .. "|T" .. addon.icons.TURNIN_INCOMPLETE .. ":12|t"
			elseif element.t == "LOC" or element.t == "GOTO" then
				if element.mapIndex == 0 and addon.arrowFrame ~= nil then
					text = text .. "|T" .. addon.icons.MAP_ARROW .. ":12:12:0:0:512:512:" .. 
						addon.arrowFrame.col * 64 .. ":" .. (addon.arrowFrame.col + 1) * 64 .. ":" .. 
						addon.arrowFrame.row * 64 .. ":" .. (addon.arrowFrame.row + 1) * 64 .. ":::|t"
				elseif element.mapIndex ~= nil then
					text = text .. "|T" .. addon.icons.MAP_MARKER .. ":12:12:0:0:512:512:" .. 
						element.mapIndex % 8 * 64 .. ":" .. (element.mapIndex % 8 + 1) * 64 .. ":" .. 
						math.floor(element.mapIndex / 8) * 64 .. ":" .. (math.floor(element.mapIndex / 8) + 1) * 64 .. ":::|t"
				else
					text = text .. "|T" .. addon.icons.MAP .. ":12|t"
				end
			elseif addon.icons[element.t] ~= nil then
				text = text .. "|T" .. addon.icons[element.t] .. ":12|t"
			end			
			if element.text ~= nil then
				text = text .. element.text
			end
			if addon.quests[element.questId] ~= nil then
				text = text .. getQuestText(element.questId, element.t, element.title, step.active)
			end
		end
		if element.available and not element.completed and element.questId ~= nil and addon.quests[element.questId].followup ~= nil and #addon.quests[element.questId].followup > 0 then
			if skipTooltip ~= "" then skipTooltip = skipTooltip .. "\n" end
			skipTooltip = skipTooltip .. "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
			if #addon.quests[element.questId].followup == 1 then
				skipTooltip = skipTooltip .. L.STEP_FOLLOWUP_QUEST:format(getQuestText(addon.quests[element.questId].followup[1], "ACCEPT"))
			else
				skipTooltip = skipTooltip .. L.STEP_FOLLOWUP_QUESTS:format(#addon.quests[element.questId].followup)
			end
		end
	end
	if step.missingPrequests ~= nil and #step.missingPrequests > 0 then
		if tooltip ~= "" then tooltip = tooltip .. "\n" end
		tooltip = tooltip .. "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
		if #step.missingPrequests == 1 then
			tooltip = tooltip .. L.MISSING_PREQUEST .. " "
		else
			tooltip = tooltip .. L.MISSING_PREQUESTS .. " "
		end
		for i, id in ipairs(step.missingPrequests) do
			tooltip = tooltip .. getQuestText(id, "TURNIN")
		end			
	end
	for id, v in pairs(step.trackQuest) do
		if addon.quests[id].logIndex ~= nil and addon.quests[id].objectives ~= nil then
			if type(v) == "number" then
				if addon.debugging then print("LIME: objective ", v) end
				local o = addon.quests[id].objectives[v]
				if o ~= nil and not o.done and o.desc ~= nil and o.desc ~= "" then 
					if step.active then
						text = text .. "\n    - " .. o.desc
					else
						if tooltip ~= "" then tooltip = tooltip .. "\n" end
						tooltip = tooltip .. "- " .. o.desc
					end
				end
			else
				for i, o in ipairs(addon.quests[id].objectives) do
					if not o.done and o.desc ~= nil and o.desc ~= "" then 
						if step.active then
							text = text .. "\n    - " .. o.desc
						else
							if tooltip ~= "" then tooltip = tooltip .. "\n" end
							tooltip = tooltip .. "- " .. o.desc
						end
					end
				end
			end
		end
	end
	addon.mainFrame.steps[i].textBox:SetText(text)
	if GuidelimeData.showTooltips then
		addon.mainFrame.steps[i].textBox.tooltip = tooltip
		addon.mainFrame.steps[i].tooltip = skipTooltip
	else
		addon.mainFrame.steps[i].textBox.tooltip = nil
		addon.mainFrame.steps[i].tooltip = nil
	end
end

local function queryPosition()
	if addon.queryingPosition then return end
	addon.queryingPosition = true
	C_Timer.After(0.2, function() 
		addon.queryingPosition = false
		local y, x = UnitPosition("player")
		local face = GetPlayerFacing()
		--if addon.debugging then print("LIME : queryingPosition", x, y) end
		if x ~= addon.x or y ~= addon.y then
			addon.x = x
			addon.y = y
			addon.face = face
			addon.updateSteps()
		elseif face ~= addon.face then
			addon.face = face
			addon.updateArrow()		
			queryPosition()
		else
			queryPosition()
		end
	end)
end

local function updateStepCompletion(i, completedIndexes)
	local step = addon.currentGuide.steps[i]

	local wasCompleted = step.completed
	if not step.manual then	step.completed = nil end
	for j, element in ipairs(step.elements) do
		if element.t == "ACCEPT" then
			element.completed = addon.quests[element.questId].completed or addon.quests[element.questId].logIndex ~= nil
			if step.completed == nil or not element.completed then step.completed = element.completed end
		elseif element.t == "COMPLETE" then
			element.completed = 
				addon.quests[element.questId].completed or 
				addon.quests[element.questId].finished or
				(element.objective ~= nil and addon.quests[element.questId].objectives ~= nil and addon.quests[element.questId].objectives[element.objective].done)
			if step.completed == nil or not element.completed then step.completed = element.completed end
		elseif element.t == "TURNIN" then
			element.finished = addon.quests[element.questId].finished
			element.completed = addon.quests[element.questId].completed
			if step.completed == nil or not element.completed then step.completed = element.completed end
		elseif element.t == "LEVEL" then
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
	-- check goto last so that goto only matters when there are no other objectives completed
	for j, element in ipairs(step.elements) do
		if element.t == "GOTO" then
			if not wasCompleted and not step.completed and step.active and not step.skip and not element.completed then
				local x, y = HBD:GetZoneCoordinatesFromWorld(addon.x, addon.y, element.mapID, false)
				--if addon.debugging then print("LIME : zone coordinates", x, y, element.mapID) end
				if x ~= nil and y ~= nil then
					x = x * 100; y = y * 100;
					element.completed = (x - element.x) * (x - element.x) + (y - element.y) * (y - element.y) <= element.radius * element.radius
				else
					element.completed = false
				end
				if step.completed == nil or not element.completed then step.completed = element.completed end
			end
		end
	end
	if step.completed == nil then step.completed = step.completeWithNext and wasCompleted end
	
	if i < #addon.currentGuide.steps and step.completeWithNext ~= nil and step.completeWithNext then
		local nstep = addon.currentGuide.steps[i + 1]
		local c = nstep.completed or nstep.skip
		if step.completed ~= c then
			if addon.debugging then print("LIME: complete with next ", i - 1, c, nstep.skip, nstep.available) end
			step.completed = c
		end
	end
	
	if step.completed ~= wasCompleted then
		table.insert(completedIndexes, i)
	end	
end

local function updateStepAvailability(i, changedIndexes, marked)
	local step = addon.currentGuide.steps[i]
	
	local wasAvailable = step.available
	step.available = true
	step.missingPrequests = {}
	for j, element in ipairs(step.elements) do
		element.available = true
		if element.t == "ACCEPT" then
			if addon.questsDB[element.questId].prequests ~= nil then
				for i, id in ipairs(addon.questsDB[element.questId].prequests) do
					if not addon.quests[id].completed and marked.TURNIN[id] == nil then
						element.available = false
						if not addon.contains(step.missingPrequests, id) then
							table.insert(step.missingPrequests, id)
						end
					end
				end
			end
			if step.skip and element.available then
				marked.SKIP_ACCEPT[element.questId] = true
			end
		elseif element.t == "COMPLETE" then
			if marked.SKIP_ACCEPT[element.questId] == true and 
				not element.completed and 
				addon.quests[element.questId].logIndex == nil 
			then 
				element.available = false 
				if not addon.contains(step.missingPrequests, element.questId) then
					table.insert(step.missingPrequests, element.questId)
				end
			end
			if step.skip and element.available then
				marked.SKIP_COMPLETE[element.questId] = true
			end
		elseif element.t == "TURNIN" then
			if marked.SKIP_ACCEPT[element.questId] == true and 
				not element.completed and 
				addon.quests[element.questId].logIndex == nil 
			then 
				element.available = false 
				if not addon.contains(step.missingPrequests, element.questId) then
					table.insert(step.missingPrequests, element.questId)
				end
			end
			if marked.SKIP_COMPLETE[element.questId] ~= nil and 
				not element.completed then 
				element.available = false 
			end
			if not step.skip and element.available then
				marked.TURNIN[element.questId] = true
			end
		end
		if not element.available then step.available = false end
	end

	if i < #addon.currentGuide.steps and step.completeWithNext ~= nil and step.completeWithNext then 
		local nstep = addon.currentGuide.steps[i + 1]
		if step.available ~= nstep.available then
			if addon.debugging then print("LIME: complete with next ", i, nstep.skip, nstep.available) end
			step.available = nstep.available
		end
	end

	if step.available ~= wasAvailable and not addon.contains(changedIndexes, i) then
		table.insert(changedIndexes, i)
	end
end

local function updateStepsCompletion(changedIndexes)
	if addon.debugging then print("LIME: update steps completion") end
	local newIndexes
	repeat
		newIndexes = {}
		local marked = {SKIP_ACCEPT = {}, SKIP_COMPLETE = {}, TURNIN = {}}
		for i, step in ipairs(addon.currentGuide.steps) do
			updateStepCompletion(i, newIndexes)
			updateStepAvailability(i, newIndexes, marked)
			if addon.mainFrame.steps ~= nil and addon.mainFrame.steps[i] ~= nil then 
				addon.mainFrame.steps[i]:SetChecked(step.completed or step.skip)
				addon.mainFrame.steps[i]:SetEnabled((not step.completed and step.available) or step.skip)
			end
		end
		for _, i in ipairs(newIndexes) do
			if not addon.contains(changedIndexes, i) then
		 		table.insert(changedIndexes, i)
			--elseif addon.debugging then
			--	error("step " .. i .. " changed more than once")
			end
		end
	until(#newIndexes == 0)
	if addon.debugging then print("LIME: changed ", #changedIndexes) end
end

local function keepFading()
	local update = false
	local isFading = false
	for i, step in ipairs(addon.currentGuide.steps)	do
		if step.fading ~= nil then
			if (GuidelimeDataChar.hideCompletedSteps and (step.completed or step.skip)) or
			   (GuidelimeDataChar.hideUnavailableSteps and not step.available) then
				step.active = false
				--if addon.debugging then print("LIME: fade out", i, step.fading) end
				if step.fading <= 0 then
					step.fading = nil
					--if addon.debugging then print("LIME: fade out", i) end
					update = true 
				else
					step.fading = step.fading - 0.05
					if addon.mainFrame.steps ~= nil and addon.mainFrame.steps[i] ~= nil then 
						addon.mainFrame.steps[i]:SetAlpha(step.fading) 
					end
					isFading = true
				end	
			else		
				step.fading = nil
				if addon.mainFrame.steps ~= nil and addon.mainFrame.steps[i] ~= nil then addon.mainFrame.steps[i]:SetAlpha(1) end
			end
		end
	end
	if isFading then
		C_Timer.After(0.1, function() 
			keepFading()
		end)
	elseif update and (GuidelimeDataChar.hideCompletedSteps or GuidelimeDataChar.hideUnavailableSteps) then
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
	for i, step in ipairs(addon.currentGuide.steps)	do
		step.fading = nil
	end
end

local function updateStepsActivation()
	addon.currentGuide.firstActiveIndex = nil
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
			if addon.currentGuide.firstActiveIndex == nil then
				addon.currentGuide.firstActiveIndex = i
			end
			for j, element in ipairs(step.elements) do
				if not element.completed and (element.t == "ACCEPT" or element.t == "TURNIN") then
					table.insert(addon.currentGuide.activeQuests, element.questId)
				end
			end
		end
	end
	if addon.mainFrame.message ~= nil then
		if addon.currentGuide.firstActiveIndex ~= nil then
			addon.mainFrame.message:Hide()
		else
			addon.mainFrame.message:Show()
		end
	end
end

local function updateStepsMapIcons()
	if addon.currentGuide == nil then return end
	addon.removeMapIcons()
	addon.hideArrow()
	local highlight = true
	for i, step in ipairs(addon.currentGuide.steps) do
		if not step.skip and not step.completed and step.available then
			for j, element in ipairs(step.elements) do
				if element.t == "GOTO" and step.active and not element.completed then
					addon.addMapIcon(element, highlight)
					if highlight then
						if GuidelimeDataChar.showArrow then addon.showArrow(element) end
						queryPosition()
						highlight = false
					end
				elseif element.t == "LOC" or element.t == "GOTO" then
					addon.addMapIcon(element, false)
				end
			end
		end
	end
	addon.showMapIcons()
end

function addon.updateStepsText()
	--if addon.debugging then print("LIME: update step texts") end
	if addon.mainFrame == nil then return end
	if addon.currentGuide == nil then return end
	for i, step in ipairs(addon.currentGuide.steps) do
		updateStepText(i)
	end
	C_Timer.After(0.2, function() 
		-- scroll to first active
		if addon.currentGuide.firstActiveIndex ~= nil and 
			addon.mainFrame.steps ~= nil and
			addon.mainFrame.steps[addon.currentGuide.firstActiveIndex] ~= nil and 
			addon.mainFrame.steps[addon.currentGuide.firstActiveIndex]:GetTop() ~= nil then 
			addon.mainFrame.scrollFrame:SetVerticalScroll(
				addon.mainFrame:GetTop()
				- addon.mainFrame.steps[addon.currentGuide.firstActiveIndex]:GetTop()
				+ addon.mainFrame.scrollFrame:GetVerticalScroll()
				- 14)
		end
	end)
end

function addon.updateSteps(completedIndexes)
	--if addon.debugging then print("LIME: update steps") end
	if addon.mainFrame == nil then return end
	if addon.currentGuide == nil then return end
	if completedIndexes == nil then completedIndexes = {} end
	updateStepsCompletion(completedIndexes)
	updateStepsActivation()
	updateStepsMapIcons()
	addon.updateStepsText()
	fadeoutStep(completedIndexes) 
end

local function showContextMenu()
	EasyMenu({
		{text = L.AVAILABLE_GUIDES .. "...", func = function() addon.showGuides() end},
		{text = GAMEOPTIONS_MENU .. "...", func = function() addon.showOptions() end},
		{text = L.EDITOR .. "...", func = function() addon.showEditor() end},
		{text = L.HIDE_COMPLETED_STEPS, checked = GuidelimeDataChar.hideCompletedSteps or GuidelimeDataChar.hideUnavailableSteps, func = function()
			GuidelimeDataChar.hideCompletedSteps = not GuidelimeDataChar.hideCompletedSteps and not GuidelimeDataChar.hideUnavailableSteps
			GuidelimeDataChar.hideUnavailableSteps = GuidelimeDataChar.hideCompletedSteps
			if addon.optionsFrame ~= nil then 
				addon.optionsFrame.options.hideCompletedSteps:SetChecked(GuidelimeDataChar.hideCompletedSteps) 
				addon.optionsFrame.options.hideUnavailableSteps:SetChecked(GuidelimeDataChar.hideUnavailableSteps) 
			end
			addon.updateMainFrame()
		end}
	}, CreateFrame("Frame", nil, nil, "UIDropDownMenuTemplate"), "cursor", 0 , 0, "MENU");
end

function addon.updateMainFrame()
	if addon.mainFrame == nil then return end
	if addon.debugging then print("LIME: updating main frame") end
	
	GameTooltip:Hide()
	if addon.mainFrame.allSteps ~= nil then
		for k, step in pairs(addon.mainFrame.allSteps) do
			step:Hide()
		end
	end
	addon.mainFrame.steps = {}
	addon.mainFrame.allSteps = {}
	if addon.mainFrame.message ~= nil then
		addon.mainFrame.message:Hide()
		addon.mainFrame.message = nil
	end
	stopFading()
	
	if addon.currentGuide.name == nil then
		if addon.debugging then print("LIME: No guide loaded") end
		addon.mainFrame.message = addon.addMultilineText(addon.mainFrame.scrollChild, L.NO_GUIDE_LOADED, addon.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button)
			if (button == "RightButton") then
				showContextMenu()
			else
				addon.showGuides()
			end
		end)
		addon.mainFrame.message:SetPoint("TOPLEFT", addon.mainFrame.scrollChild, "TOPLEFT", 10, -25)
	else
		--if addon.debugging then print("LIME: Showing guide " .. addon.currentGuide.name) end

		if addon.currentGuide.next == nil then
			addon.mainFrame.message = addon.addMultilineText(addon.mainFrame.scrollChild, 
				L.GUIDE_FINISHED, addon.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button)
				if (button == "RightButton") then
					showContextMenu()
				else
					addon.showGuides()
				end
			end)
		else
			addon.mainFrame.message = addon.addMultilineText(addon.mainFrame.scrollChild, 
				L.GUIDE_FINISHED_NEXT:format("|cFFFFFFFF" .. addon.currentGuide.next .. "|r"), addon.mainFrame.scrollChild:GetWidth() - 20, nil, function(self, button) 
				if (button == "RightButton") then
					showContextMenu()
				else
					addon.loadGuide(addon.currentGuide.group .. " " .. addon.currentGuide.next)
				end
			end)
		end

		addon.updateSteps()
		
		local prev = nil
		for i, step in ipairs(addon.currentGuide.steps) do
			if ((not step.completed and not step.skip) or not GuidelimeDataChar.hideCompletedSteps) and 
				(step.available or not GuidelimeDataChar.hideUnavailableSteps) then
				addon.mainFrame.steps[i] = addon.addCheckbox(addon.mainFrame.scrollChild, nil, "")
				table.insert(addon.mainFrame.allSteps, addon.mainFrame.steps[i])
				if prev == nil then
					addon.mainFrame.steps[i]:SetPoint("TOPLEFT", addon.mainFrame.scrollChild, "TOPLEFT", 0, -14)
				else
					addon.mainFrame.steps[i]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -35, -2)
				end
				addon.mainFrame.steps[i]:SetChecked(step.completed or step.skip)
				addon.mainFrame.steps[i]:SetEnabled((not step.completed and step.available) or step.skip)
				addon.mainFrame.steps[i]:SetScript("OnClick", function() 
					local step = addon.currentGuide.steps[i]
					step.skip = addon.mainFrame.steps[i]:GetChecked()
					GuidelimeDataChar.currentGuide.skip[i] = step.skip
					if not step.skip and GuidelimeDataChar.hideUnavailableSteps then
						addon.updateMainFrame()
					else 
						addon.updateSteps({i})
					end
				end)
				
				addon.mainFrame.steps[i].textBox = addon.addMultilineText(addon.mainFrame.steps[i], nil, addon.mainFrame.scrollChild:GetWidth() - 40, "", function(self, button)
					if (button == "RightButton") then
						showContextMenu()
					end
				end)
				addon.mainFrame.steps[i].textBox:SetPoint("TOPLEFT", addon.mainFrame.steps[i], "TOPLEFT", 35, -9)
				updateStepText(i)
				
				prev = addon.mainFrame.steps[i].textBox
			end
		end
		if prev == nil then
			addon.mainFrame.message:SetPoint("TOPLEFT", addon.mainFrame.scrollChild, "TOPLEFT", 10, -25)
		else
			addon.mainFrame.message:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -25, -15)
		end
	end
end

function addon.showMainFrame()
	
	if not addon.dataLoaded then loadData() end
	
	if addon.mainFrame == nil then
		--if addon.debugging then print("LIME: initializing main frame") end
		addon.mainFrame = CreateFrame("FRAME", nil, UIParent)
		addon.mainFrame:SetWidth(GuidelimeDataChar.mainFrameWidth)
		addon.mainFrame:SetHeight(GuidelimeDataChar.mainFrameHeight)
		addon.mainFrame:SetPoint(GuidelimeDataChar.mainFrameRelative, UIParent, GuidelimeDataChar.mainFrameRelative, GuidelimeDataChar.mainFrameX, GuidelimeDataChar.mainFrameY)
		addon.mainFrame:SetBackdrop({
			bgFile = "Interface/Addons/Guidelime/Icons/Black", tile = false
		})
		addon.mainFrame:SetBackdropColor(1,1,1,GuidelimeDataChar.mainFrameAlpha)
		addon.mainFrame:SetFrameLevel(999)
		addon.mainFrame:SetMovable(true)
		addon.mainFrame:EnableMouse(true)
		addon.mainFrame:SetScript("OnMouseDown", function(this, button) 
			if (button == "LeftButton" and not GuidelimeDataChar.mainFrameLocked) then addon.mainFrame:StartMoving() end
		end)
		addon.mainFrame:SetScript("OnMouseUp", function(this, button) 
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
		
		if addon.firstLogUpdate then 
			addon.updateMainFrame() 
		end

		addon.mainFrame.doneBtn = CreateFrame("BUTTON", "doneBtn", addon.mainFrame)
    	addon.mainFrame.doneBtn:SetSize(24, 24)
    	addon.mainFrame.doneBtn:SetNormalTexture("Interface/Buttons/UI-Panel-MinimizeButton-Up")
    	addon.mainFrame.doneBtn:SetHighlightTexture("Interface/Buttons/UI-Panel-MinimizeButton-Highlight")
    	addon.mainFrame.doneBtn:SetPushedTexture("Interface/Buttons/UI-Panel-MinimizeButton-Down")
		addon.mainFrame.doneBtn:SetPoint("TOPRIGHT", addon.mainFrame, "TOPRIGHT", 0,0)
		addon.mainFrame.doneBtn:SetScript("OnClick", function() 
			addon.mainFrame:Hide()  
			addon.removeMapIcons()
			GuidelimeDataChar.mainFrameShowing = false
			addon.optionsFrame.options.mainFrameShowing:SetChecked(false)
		end)
	
		addon.mainFrame.lockBtn = CreateFrame("BUTTON", "lockBtn", addon.mainFrame)
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
			if addon.optionsFrame ~= nil then addon.optionsFrame.options.mainFrameLocked:SetChecked(GuidelimeDataChar.mainFrameLocked) end
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
end

-- Register events and call functions
addon.frame:SetScript("OnEvent", function(self, event, ...)
	addon.frame[event](self, ...)
end)

addon.frame:RegisterEvent('PLAYER_ENTERING_WORLD')
function addon.frame:PLAYER_ENTERING_WORLD()
	--if addon.debugging then print("LIME: Player entering world...") end
	if not addon.dataLoaded then loadData() end
	
	addon.fillGuides()
	addon.fillOptions()
	addon.fillEditor()
	
	if GuidelimeDataChar.mainFrameShowing then addon.showMainFrame() end
end

addon.frame:RegisterEvent('PLAYER_LEVEL_UP')
function addon.frame:PLAYER_LEVEL_UP(level)
	if addon.debugging then print("LIME: You reached level " .. level .. ". Grats!") end
	addon.level = level
	addon.updateSteps()
end

function addon.updateFromQuestLog()
	local questLog = {}
	for i=1,GetNumQuestLogEntries() do
		local name, _, _, header, _, completed, _, id = GetQuestLogTitle(i)
		if not header then
			questLog[id] = {}
			questLog[id].index = i
			questLog[id].finished = (completed == 1)
			questLog[id].name = name
		end
	end
	
	local checkCompleted = false
	local questChanged = false
	local questFound = false
	for id, q in pairs(addon.quests) do
		if questLog[id] ~= nil then
			if q.logIndex ~= nil then
				questFound = true
				if q.logIndex ~= questLog[id].index or q.finished ~= questLog[id].finished then
					questChanged = true
					q.logIndex = questLog[id].index
					q.finished = questLog[id].finished
					--if addon.debugging then print("LIME: changed log entry ".. id .. " finished", q.finished) end
				end
			else
				questFound = true
				questChanged = true
				q.logIndex = questLog[id].index
				q.finished = questLog[id].finished
				q.name = questLog[id].name
				--if addon.debugging then print("LIME: new log entry ".. id .. " finished", q.finished) end
			end
			if q.objectives == nil then q.objectives = {} end
			for k = 1, GetNumQuestLeaderBoards(q.logIndex) do
				local desc, _, done = GetQuestLogLeaderBoard(k, addon.quests[id].logIndex)
				if q.objectives[k] == nil or desc ~= q.objectives[k] or done ~= q.objectives[k].done then
					questChanged = true
					q.objectives[k] = {desc = desc, done = done}
				end					
			end
		else
			if q.logIndex ~= nil then
				checkCompleted = true
				q.logIndex = nil
				--if addon.debugging then print("LIME: removed log entry ".. id) end
			end
		end
	end
	return checkCompleted, questChanged, questFound
end

addon.frame:RegisterEvent('QUEST_LOG_UPDATE')
function addon.frame:QUEST_LOG_UPDATE()
	--if addon.debugging then print("LIME: QUEST_LOG_UPDATE", addon.firstLogUpdate) end
	addon.xp = UnitXP("player")
	addon.xpMax = UnitXPMax("player")
	addon.y, addon.x = UnitPosition("player")
	
	if addon.quests ~= nil then 
		local checkCompleted, questChanged, questFound = addon.updateFromQuestLog()

		if addon.firstLogUpdate == nil then
			addon.updateMainFrame()
		else
			if not questChanged then
				if addon.contains(addon.currentGuide.steps, function(s) return not s.skip and not s.completed and s.active and s.xp ~= nil end) then 
					questChanged = true 
				end
			end
			
			if checkCompleted then
				if questFound then
					addon.updateStepsText()
				end
				C_Timer.After(1, function() 
					local completed = GetQuestsCompleted()
					local questCompleted = false
					for id, q in pairs(addon.quests) do
						if completed[id] and not q.completed then
							questCompleted = true
							q.finished = true
							q.completed = true
						end
					end
					if questCompleted == true or not GuidelimeDataChar.hideCompletedSteps then
						addon.updateSteps()
					else
						-- quest was abandoned so redraw erverything since completed steps might have to be done again
						addon.updateMainFrame()
					end
				end)
			elseif questChanged then 
				addon.updateSteps() 
			elseif questFound then
				addon.updateStepsText()
			end
		end
	end
	addon.firstLogUpdate = true
end

addon.frame:RegisterEvent('GOSSIP_SHOW')
function addon.frame:GOSSIP_SHOW()
	if GuidelimeDataChar.autoCompleteQuest then 
		if addon.debugging then print ("LIME: GOSSIP_SHOW", GetGossipActiveQuests()) end
		if addon.debugging then print ("LIME: GOSSIP_SHOW", GetGossipAvailableQuests()) end
		local q = { GetGossipActiveQuests() }
		local selectActive = nil
		local selectAvailable = nil
		addon.openNpcAgain = false
		for i = 1, GetNumGossipActiveQuests() do
			local name = q[(i-1) * 7 + 1]
			if addon.contains(addon.currentGuide.activeQuests, function(id) return name == addon.getQuestNameById(id) end) then
				if selectActive == nil then
					selectActive = i
				else
					addon.openNpcAgain = true
				end			
			end
		end
		q = { GetGossipAvailableQuests() }
		for i = 1, GetNumGossipAvailableQuests() do
			local name = q[(i-1) * 7 + 1]
			if addon.contains(addon.currentGuide.activeQuests, function(id) return name == addon.getQuestNameById(id) end) then
				if selectActive == nil and selectAvailable == nil then
					selectAvailable = i
				else
					addon.openNpcAgain = true
				end			
			end
		end

		if selectActive ~= nil then
			C_Timer.After(addon.AUTO_COMPLETE_DELAY, function() 
				if addon.debugging then print ("LIME: GOSSIP_SHOW selectActive", selectActive) end
				SelectGossipActiveQuest(selectActive)
			end)
		elseif selectAvailable ~= nil then
			C_Timer.After(addon.AUTO_COMPLETE_DELAY, function() 
				if addon.debugging then print ("LIME: GOSSIP_SHOW selectAvailable", selectAvailable) end
				SelectGossipAvailableQuest(selectAvailable)
			end)
		end
	end
end

addon.frame:RegisterEvent('QUEST_GREETING')
function addon.frame:QUEST_GREETING()
	if addon.debugging then 
		print ("LIME: QUEST_GREETING")
	end
end

addon.frame:RegisterEvent('QUEST_DETAIL')
function addon.frame:QUEST_DETAIL()
	local id = GetQuestID()
	if addon.debugging then print ("LIME: QUEST_DETAIL", id) end
	if GuidelimeDataChar.autoCompleteQuest and addon.currentGuide.activeQuests ~= nil and addon.contains(addon.currentGuide.activeQuests, id) then 
		C_Timer.After(addon.AUTO_COMPLETE_DELAY, function() 
			AcceptQuest()
			if addon.openNpcAgain then 
				--todo
			end
		end)
	end
end

addon.frame:RegisterEvent('QUEST_PROGRESS')
function addon.frame:QUEST_PROGRESS()
	local id = GetQuestID()
	if addon.debugging then print ("LIME: QUEST_PROGRESS", id) end
	if IsQuestCompletable() and GuidelimeDataChar.autoCompleteQuest and addon.contains(addon.currentGuide.activeQuests, id) then 
		C_Timer.After(addon.AUTO_COMPLETE_DELAY, function() 
			CompleteQuest()
			if addon.openNpcAgain then 
				--todo
			end
		end)
	end
end

addon.frame:RegisterEvent('QUEST_COMPLETE')
function addon.frame:QUEST_COMPLETE()
	local id = GetQuestID()
	if GuidelimeDataChar.autoCompleteQuest and addon.contains(addon.currentGuide.activeQuests, id) then 
		if addon.debugging then print ("LIME: QUEST_COMPLETE", id) end
		if (GetNumQuestChoices() <= 1) then
			C_Timer.After(addon.AUTO_COMPLETE_DELAY, function() 
		        GetQuestReward(1)
		    end)
		end
	end
end

SLASH_Guidelime1 = "/lime"
function SlashCmdList.Guidelime(msg)
	if msg == '' then addon.showMainFrame() 
	elseif msg == 'debug true' and not addon.debugging then addon.debugging = true; print('LIME: addon.debugging enabled')
	elseif msg == 'debug false' and addon.debugging then addon.debugging = false; print('LIME: addon.debugging disabled') end
	GuidelimeData.debugging = addon.debugging
end
