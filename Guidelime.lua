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
addon.AUTO_COMPLETE_DELAY = 1.7
addon.DEFAULT_GOTO_RADIUS = 0.3

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
	MAP_MARKER = "Interface\\Addons\\" .. addonName .. "\\Icons\\lime_marker",
	COMPLETED = "Interface\\Buttons\\UI-CheckBox-Check",
	UNAVAILABLE = "Interface\\Buttons\\UI-GroupLoot-Pass-Up", -- or rather "Interface\\Buttons\\UI-StopButton" (yellow x) ?
	
	QUEST = "Interface\\GossipFrame\\ActiveQuestIcon",
	ACCEPT = "Interface\\GossipFrame\\AvailableQuestIcon",
	ACCEPT_UNAVAILABLE = "Interface\\Addons\\" .. addonName .. "\\Icons\\questunavailable",
	COMPLETE = "Interface\\GossipFrame\\BattleMasterGossipIcon",
	WORK = "Interface\\GossipFrame\\BattleMasterGossipIcon",
	TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon",
	TURNIN_INCOMPLETE = "Interface\\GossipFrame\\IncompleteQuestIcon",
	SET_HEARTH = "Interface\\Addons\\" .. addonName .. "\\Icons\\set_hearth", -- made from "Interface\\Icons\\INV_Drink_05", nicer than the actual "Interface\\GossipFrame\\BinderGossipIcon" ?
	VENDOR = "Interface\\GossipFrame\\VendorGossipIcon",
	REPAIR = "Interface\\Addons\\" .. addonName .. "\\Icons\\repair", -- made from "Interface\\Icons\\Trade_BlackSmithing",
	HEARTH = "Interface\\Addons\\" .. addonName .. "\\Icons\\hearth", -- made from "Interface\\Icons\\INV_Misc_Rune_01",
	FLY = "Interface\\GossipFrame\\TaxiGossipIcon",
	TRAIN = "Interface\\GossipFrame\\TrainerGossipIcon",
	GET_FLIGHT_POINT = "Interface\\Addons\\" .. addonName .. "\\Icons\\getflightpoint",
	GOTO = "Interface\\Addons\\" .. addonName .. "\\Icons\\lime0",
	
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
addon.y, addon.x = UnitPosition("player")
addon.face = GetPlayerFacing()

addon.guides = {}
addon.queryingPositions = false
addon.dataLoaded = false

function Guidelime.registerGuide(guide, group)
	guide = addon.parseGuide(guide, group)	
	if guide == nil then error("There were errors parsing the guide \"" .. guide.name .. "\"") end
	if addon.debugging then print("LIME: ", guide.name) end
	if addon.guides[guide.name] ~= nil then error("There is more than one guide with the name \"" .. guide.name .. "\"") end
	addon.guides[guide.name] = guide
	return guide
end

function addon.loadData()
	local defaultOptions = {
		debugging = false,
		showQuestLevels = false,
		showTooltips = true,
		maxNumOfMarkers = 10,
		maxNumOfSteps = 0,
		arrowStyle = 1,
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
		hideCompletedSteps = true,
		hideUnavailableSteps = true,
		autoCompleteQuest = true,
		showArrow = true,
		arrowX = 0,
		arrowY = -20,
		arrowRelative = "TOP",
		arrowAlpha = 0.8,
		editorFrameX = 0,
		editorFrameY = 0,
		editorFrameRelative = "CENTER",
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
	
	GuidelimeData.version:gsub("(%d+).(%d+)", function(major, minor)
		if tonumber(major) == 0 and tonumber(minor) < 10 then
			-- before 0.010 custom guides were saved with a key prefixed with L.CUSTOM_GUIDES. This produces different keys when language is changed. Therefore remove.
			local guides = GuidelimeData.customGuides
			GuidelimeData.customGuides = {}
			for name, guide in pairs(guides) do
				if name:sub(1, 14) == "Custom guides " then name = name:sub(15) end
				GuidelimeData.customGuides[name] = guide
			end
			GuidelimeData.version = GetAddOnMetadata(addonName, "version")
		end
	end, 1)
	
	if GuidelimeData.customGuides ~= nil then
		for name, guide in pairs(GuidelimeData.customGuides) do
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
			print("LIME: availbale guides:")
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
			for j, element in ipairs(step.elements) do
				element.available = true
				
				if element.t == "ACCEPT" or element.t == "COMPLETE" or element.t == "TURNIN" or element.t == "LEVEL" then 
					if step.manual == nil then step.manual = false end
					if element.optional == nil or not element.optional then step.completeWithNext = false end
				elseif element.t == "TRAIN" or element.t == "VENDOR" or element.t == "REPAIR" or element.t == "SET_HEARTH" or element.t == "GET_FLIGHT_POINT" then 
					step.manual = true
					if step.completeWithNext == nil then step.completeWithNext = false end
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
						if addon.questsDB[element.questId] ~= nil and addon.questsDB[element.questId].prequests ~= nil then
							for i, id in ipairs(addon.questsDB[element.questId].prequests) do
								if addon.quests[id] == nil then addon.quests[id] = {} end
								addon.quests[id].completed = completed[id] ~= nil and completed[id]
								if addon.quests[id].followup == nil then addon.quests[id].followup = {} end
								table.insert(addon.quests[id].followup, element.questId)
							end
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
	q = q .. (title or addon.getQuestNameById(id))
	if colored == nil or colored then q = q .. "|r" end
	return q
end

local function getSkipQuests(id, skipQuests, newSkipQuests)
	if newSkipQuests == nil then newSkipQuests = {} end
	if addon.quests[id].followup ~= nil and #addon.quests[id].followup > 0 then
		for k, fid in ipairs(addon.quests[id].followup) do
			if addon.currentGuide.unavailableQuests[fid] == nil and skipQuests[fid] == nil then
				table.insert(newSkipQuests, fid)
				skipQuests[fid] = true
				getSkipQuests(fid, skipQuests, newSkipQuests)
			end
		end
	end
	return newSkipQuests
end

local function updateStepText(i)
	local step = addon.currentGuide.steps[i]
	if addon.mainFrame.steps == nil or addon.mainFrame.steps[i] == nil or addon.mainFrame.steps[i].textBox == nil then return end
	local text = ""
	local tooltip = ""
	local skipTooltip = ""
	local skipText = ""
	local skipQuests = {}
	local trackQuest = {}
	if addon.debugging then text = text .. step.line .. " " end
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
		if not element.available then
			text = text .. "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
		elseif element.completed and element.t ~= "GOTO" then
			text = text .. "|T" .. addon.icons.COMPLETED .. ":12|t"
		elseif element.t == "ACCEPT" and addon.questsDB[element.questId] ~= nil and addon.questsDB[element.questId].req > addon.level then
			text = text .. "|T" .. addon.icons.ACCEPT_UNAVAILABLE .. ":12|t"
			if tooltip ~= "" then tooltip = tooltip .. "\n" end
			local q = getQuestText(element.questId, "ACCEPT")
			tooltip = tooltip .. L.QUEST_REQUIRED_LEVEL:format(q, addon.questsDB[element.questId].req)
		elseif element.t == "TURNIN" and not element.finished then
			text = text .. "|T" .. addon.icons.TURNIN_INCOMPLETE .. ":12|t"
		elseif element.t == "LOC" or element.t == "GOTO" then
			if element.mapIndex == 0 and addon.arrowFrame ~= nil and GuidelimeDataChar.showArrow then
				text = text .. addon.getArrowIconText()
			elseif element.mapIndex ~= nil then
				text = text .. "|T" .. addon.icons.MAP_MARKER .. ":15:15:0:1:512:512:" .. 
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
		if element.available and not element.completed and element.questId ~= nil and not element.optional then
			local newSkipQuests = getSkipQuests(element.questId, skipQuests)
			if #newSkipQuests > 0 then
				if skipText ~= "" then skipText = skipText .. "\n\n" end
				if #newSkipQuests == 1 then
					skipText = skipText .. L.STEP_FOLLOWUP_QUEST:format(getQuestText(element.questId, element.t)) ..":\n"
				else
					skipText = skipText .. L.STEP_FOLLOWUP_QUESTS:format(getQuestText(element.questId, element.t)) ..":\n"
				end
				for k, id in ipairs(newSkipQuests) do
					skipText = skipText .. "\n|T" .. addon.icons.UNAVAILABLE .. ":12|t" .. getQuestText(id, "ACCEPT")
				end
			end
			if element.t == "COMPLETE" or element.t == "TURNIN" then
				if element.objective == nil then
					trackQuest[element.questId] = true
				else
					trackQuest[element.questId] = element.objective
				end
			end
		end
	end
	if step.missingPrequests ~= nil and #step.missingPrequests > 0 then
		if tooltip ~= "" then tooltip = tooltip .. "\n" end
		tooltip = tooltip .. "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
		if #step.missingPrequests == 1 then
			tooltip = tooltip .. L.MISSING_PREQUEST
		else
			tooltip = tooltip .. L.MISSING_PREQUESTS
		end
		for i, id in ipairs(step.missingPrequests) do
			tooltip = tooltip .. " " ..getQuestText(id, "TURNIN")
		end			
	end
	for id, v in pairs(trackQuest) do
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
	addon.mainFrame.steps[i].skipText = skipText
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
		if x ~= addon.x or y ~= addon.y or face ~= addon.face then
			addon.x = x
			addon.y = y
			addon.face = face
			addon.updateSteps()
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
		if element.optional == nil or not element.optional then
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
	
	if step.completed ~= wasCompleted and not addon.contains(completedIndexes, i) then
		table.insert(completedIndexes, i)
	end	
end

local function updateStepAvailability(i, changedIndexes, skipped)
	local step = addon.currentGuide.steps[i]
	local wasAvailable = step.available
	step.available = nil
	step.missingPrequests = {}
	for j, element in ipairs(step.elements) do
		element.available = true
		if element.t == "ACCEPT" then
			if addon.questsDB[element.questId] ~= nil and addon.questsDB[element.questId].prequests ~= nil then
				for i, id in ipairs(addon.questsDB[element.questId].prequests) do
					if not addon.quests[id].completed and skipped.TURNIN[id] then
						element.available = false
						if not addon.contains(step.missingPrequests, id) then
							table.insert(step.missingPrequests, id)
						end						
						addon.currentGuide.unavailableQuests[element.questId] = true
					end
				end
			end
		elseif element.t == "COMPLETE" then
			if skipped.ACCEPT[element.questId] and not element.completed then 
				element.available = false 
				if not addon.contains(step.missingPrequests, element.questId) then
					table.insert(step.missingPrequests, element.questId)
				end
			end
		elseif element.t == "TURNIN" then
			if (skipped.ACCEPT[element.questId] or skipped.COMPLETE[element.questId]) and not element.completed then 
				element.available = false 
				if not addon.contains(step.missingPrequests, element.questId) then
					table.insert(step.missingPrequests, element.questId)
				end
			end
		end
		if element.t == "ACCEPT" or element.t == "COMPLETE" or element.t == "TURNIN" then
			if not step.skip and element.available then
				skipped[element.t][element.questId] = false
			elseif skipped[element.t][element.questId] == nil and (step.skip or not element.available) then
				skipped[element.t][element.questId] = true
			end
			if not element.completed then step.available = step.available or element.available end
		elseif element.t == "LEVEL" then
			if not element.completed then step.available = true end
		end
	end
	if step.available == nil then step.available = true end
	if step.manual and not step.completed then step.available = true end

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
	--if addon.debugging then print("LIME: update steps completion") end
	addon.currentGuide.unavailableQuests = {}
	repeat
		local numNew = #changedIndexes
		local skipped = {ACCEPT = {}, COMPLETE = {}, TURNIN = {}}
		for i, step in ipairs(addon.currentGuide.steps) do
			updateStepCompletion(i, changedIndexes)
			updateStepAvailability(i, changedIndexes, skipped)
			if addon.mainFrame.steps ~= nil and addon.mainFrame.steps[i] ~= nil then 
				addon.mainFrame.steps[i]:SetChecked(step.completed or step.skip)
				addon.mainFrame.steps[i]:SetEnabled((not step.completed and step.available) or step.skip)
			end
		end
	until(numNew == #changedIndexes)
	--if addon.debugging then print("LIME: changed", #changedIndexes) end
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
			for j, element in ipairs(step.elements) do
				if not element.completed and (element.t == "ACCEPT" or element.t == "TURNIN") then
					table.insert(addon.currentGuide.activeQuests, element.questId)
				end
			end
		end
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
		if addon.currentGuide.firstActiveIndex ~= nil then
			addon.mainFrame.message:Hide()
		else
			addon.mainFrame.message:Show()
		end
	end
	--if addon.debugging then print("LIME: firstActiveIndex ", addon.currentGuide.firstActiveIndex) end
	return oldFirstActiveIndex ~= addon.currentGuide.firstActiveIndex
end

function addon.updateStepsMapIcons()
	if addon.isEditorShowing() or addon.currentGuide == nil then return end
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
				elseif (element.t == "LOC" or element.t == "GOTO") and not element.completed then
					addon.addMapIcon(element, false)
				end
			end
		end
	end
	addon.showMapIcons()
end

function addon.updateStepsText(scrollToFirstActive)
	--if addon.debugging then print("LIME: update step texts") end
	if addon.mainFrame == nil then return end
	if addon.currentGuide == nil then return end
	for i, step in ipairs(addon.currentGuide.steps) do
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
					- 14)
			end
		end)
	end
end

function addon.updateSteps(completedIndexes)
	--if addon.debugging then print("LIME: update steps") end
	if addon.mainFrame == nil then return end
	if addon.currentGuide == nil then return end
	if completedIndexes == nil then completedIndexes = {} end
	updateStepsCompletion(completedIndexes)
	updateStepsActivation()
	addon.updateStepsMapIcons()
	fadeoutStep(completedIndexes) 
	addon.updateStepsText(updateFirstActiveIndex())
end

local function showContextMenu()
	EasyMenu({
		{text = L.AVAILABLE_GUIDES .. "...", checked = addon.isGuidesShowing(), func = addon.showGuides},
		{text = GAMEOPTIONS_MENU .. "...", checked = addon.isOptionsShowing(), func = addon.showOptions},
		{text = L.EDITOR .. "...", checked = addon.isEditorShowing(), func = addon.showEditor},
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

local function setStepSkip(i, value)
	local step = addon.currentGuide.steps[i]
	step.skip = value
	GuidelimeDataChar.currentGuide.skip[i] = step.skip
	if not step.skip and GuidelimeDataChar.hideUnavailableSteps then
		addon.updateMainFrame()
	else 
		addon.updateSteps({i})
	end
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
		local count = 0
		for i, step in ipairs(addon.currentGuide.steps) do
			if ((not step.completed and not step.skip) or not GuidelimeDataChar.hideCompletedSteps) and 
				(step.available or not GuidelimeDataChar.hideUnavailableSteps) then
				if not step.active and i > addon.currentGuide.lastActiveIndex then count = count + 1 end
				if step.active or GuidelimeData.maxNumOfSteps == 0 or count < GuidelimeData.maxNumOfSteps then
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
						if not addon.mainFrame.steps[i]:GetChecked() or addon.mainFrame.steps[i].skipText == nil or addon.mainFrame.steps[i].skipText == "" then
							setStepSkip(i, addon.mainFrame.steps[i]:GetChecked())
						else
							addon.mainFrame.steps[i]:SetChecked(false)
							local _, lines = addon.mainFrame.steps[i].skipText:gsub("\n", "\n")
							if addon.debugging then print("LIME: " .. addon.mainFrame.steps[i].skipText .. lines) end
							addon.createPopupFrame(addon.mainFrame.steps[i].skipText, function() 
								addon.mainFrame.steps[i]:SetChecked(true)
								setStepSkip(i, true)
							end, true, 120 + lines * 10):Show()
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
		end
		if prev == nil then
			addon.mainFrame.message:SetPoint("TOPLEFT", addon.mainFrame.scrollChild, "TOPLEFT", 10, -25)
		else
			addon.mainFrame.message:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -25, -15)
		end
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
		addon.mainFrame:SetBackdrop({
			bgFile = "Interface/Addons/" .. addonName .. "/Icons/Black", tile = false
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


SLASH_Guidelime1 = "/lime"
function SlashCmdList.Guidelime(msg)
	if msg == '' then addon.showMainFrame()
	elseif msg == 'debug true' and not addon.debugging then GuidelimeData.debugging = true; ReloadUI()
	elseif msg == 'debug false' and addon.debugging then GuidelimeData.debugging = false; ReloadUI() end
end
