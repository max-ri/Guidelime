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
	COMPLETED = "Interface\\Buttons\\UI-CheckBox-Check",
	UNAVAILABLE = "Interface\\Buttons\\UI-GroupLoot-Pass-Up", -- or rather "Interface\\Buttons\\UI-StopButton" (yellow x) ?
	
	PICKUP = "Interface\\GossipFrame\\AvailableQuestIcon",
	PICKUP_UNAVAILABLE = "Interface\\Addons\\Guidelime\\Icons\\questunavailable",
	COMPLETE = "Interface\\GossipFrame\\BattleMasterGossipIcon",
	TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon",
	TURNIN_INCOMPLETE = "Interface\\GossipFrame\\IncompleteQuestIcon",
	SETHEARTH = "Interface\\Icons\\INV_Drink_05", -- nicer than the actual "Interface\\GossipFrame\\BinderGossipIcon" ?
	VENDOR = "Interface\\GossipFrame\\VendorGossipIcon",
	REPAIR = "Interface\\Icons\\Trade_BlackSmithing",
	HEARTH = "Interface\\Icons\\INV_Misc_Rune_01",
	FLY = "Interface\\GossipFrame\\TaxiGossipIcon",
	TRAIN = "Interface\\GossipFrame\\TrainerGossipIcon",
	GETFLIGHTPOINT = "Interface\\Addons\\Guidelime\\Icons\\getflightpoint",
	
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

addon.faction = UnitFactionGroup("player")
addon.class = UnitClass("player")
addon.race = UnitRace("player")
addon.level = UnitLevel("player")
addon.xp = UnitXP("player")
addon.xpMax = UnitXPMax("player")
addon.y, addon.x = UnitPosition("player")

addon.guides = {}
addon.queryingPositions = false
addon.dataLoaded = false

local function containsWith(array, func)
	for i, v in ipairs(array) do
		if func(v) then return true end
	end
	return false
end

local function contains(array, value)
	return containsWith(array, function(v) return v == value end)
end

function Guidelime.registerGuide(guide)
	if guide.name == nil then
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
		if guide.group ~= nil then
			guide.name = guide.group .. " " .. guide.name
		else
			guide.group = L.OTHER_GUIDES
		end
	end
	if addon.guides[guide.name] ~= nil then error("There is more than one guide with the name \"" .. guide.name .. "\"") end
	addon.guides[guide.name] = guide
end

local function loadData()
	local defaultOptions = {
		debugging = false,
		showQuestLevels = true
	}
	local defaultOptionsChar = {
		mainFrameX = 0,
		mainFrameY = 0,
		mainFrameRelative = "CENTER",
		mainFrameShowing = true,
		mainFrameLocked = false,
		mainFrameWidth = 350,
		mainFrameHeight = 400,
		hideCompletedSteps = true
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
	
	addon.loadGuide()
	
	addon.dataLoaded = true

	--if addon.debugging then print("LIME: Initializing...") end
end

function addon.loadGuide()

	if GuidelimeDataChar.currentGuide == nil then GuidelimeDataChar.currentGuide = {} end
	if GuidelimeDataChar.currentGuide.name == nil then 
		GuidelimeDataChar.currentGuide.name = "Demo 1-6 Dun Morogh" 
	end
	if GuidelimeDataChar.currentGuide.skip == nil then 
		GuidelimeDataChar.currentGuide.skip = {}
	end
		
	addon.currentGuide = {}
	addon.currentGuide.name = GuidelimeDataChar.currentGuide.name
	if addon.guides[GuidelimeDataChar.currentGuide.name] == nil then 
		if addon.debugging then
			print("LIME: available guides:")
			for name, guide in pairs(addon.guides) do
				print("LIME: " .. name)
			end
		end
		GuidelimeDataChar.currentGuide.name = "Demo 1-6 Dun Morogh" 
		addon.currentGuide.name = GuidelimeDataChar.currentGuide.name
		--error("guide \"" .. GuidelimeDataChar.currentGuide.name .. "\" not found") 
	end
	for k, v in pairs(addon.guides[GuidelimeDataChar.currentGuide.name]) do
		addon.currentGuide[k] = v
	end
	addon.currentGuide.steps = {}
	addon.quests = {}
	addon.currentZone = nil
	if addon.currentGuide.colorQuest == nil then addon.currentGuide.colorQuest = addon.COLOR_QUEST_DEFAULT end
	
	--print(format(L.LOAD_MESSAGE, addon.currentGuide.name))
	
	local completed = GetQuestsCompleted()
	
	for i, step in ipairs(addon.guides[GuidelimeDataChar.currentGuide.name].steps) do
		local loadLine = true
		if step.race ~= nil then
			if not contains(step.race, addon.race) then loadLine = false end
		end
		if step.class ~= nil then
			if not contains(step.class, addon.class) then loadLine = false end
		end
		if step.faction ~= nil and step.faction ~= addon.faction then loadLine = false end
		if loadLine then
			table.insert(addon.currentGuide.steps, step) 
			addon.parseLine(step)	
			step.trackQuest = {}
			for j, element in ipairs(step.elements) do
				element.available = true
				
				if element.t == "PICKUP" or element.t == "COMPLETE" or element.t == "TURNIN" or element.t == "LEVEL" then 
					if step.manual == nil then step.manual = false end
					step.completeWithNext = false
				elseif element.t == "TRAIN" or element.t == "VENDOR" or element.t == "REPAIR" or element.t == "SETHEARTH" or element.t == "GETFLIGHTPOINT" then 
					if step.manual == nil then step.manual = true end
					step.completeWithNext = false
				elseif element.t == "GOTO" then 
					if step.manual == nil then step.manual = false end
					if step.completeWithNext == nil then step.completeWithNext = true end
				elseif element.t == "FLY" or element.t == "HEARTH" then 
					if step.manual == nil then step.manual = true end
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
					if element.title == nil or element.title == "" then
						if addon.questsDB[element.questId] == nil then error("loading guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": unknown quest id " .. element.questId .. "\" in line \"" .. step.text .. "\"") end
						element.title = addon.questsDB[element.questId].name
					elseif addon.debugging and addon.questsDB[element.questId].name ~= string.sub(element.title, 1, #addon.questsDB[element.questId].name) then
						error("loading guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": wrong title for quest " .. element.questId .. " \"" .. element.title .. "\" instead of \"" .. addon.questsDB[element.questId].name .. "\" in line \"" .. step.text .. "\"")
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

local function getColorQuest(t)
	if addon.currentGuide.colorQuest == nil then
		return ""
	elseif type(addon.currentGuide.colorQuest) == "table" then
		return addon.currentGuide.colorQuest[t]
	else
		return addon.currentGuide.colorQuest
	end
end

local function getQuestText(id, t, colored)
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
	if colored == nil or colored then q = q .. getColorQuest(t) end
	q = q .. addon.questsDB[id].name
	if colored == nil or colored and addon.currentGuide.colorQuest ~= nil then q = q .. "|r" end
	return q
end

local function updateStepText(i)
	local step = addon.currentGuide.steps[i]
	if addon.mainFrame.steps == nil or addon.mainFrame.steps[i] == nil or addon.mainFrame.steps[i].textBox == nil then return end
	local text = ""
	local tooltip = ""
	local skipTooltip = ""
	if addon.debugging then
		text = text .. i .. " "
	end
	if not step.active then
		text = text .. addon.COLOR_INACTIVE
	elseif step.manual then
		if skipTooltip ~= "" then skipTooltip = skipTooltip .. "\n" end
		skipTooltip = L.STEP_MANUAL
	end
	for j, element in ipairs(step.elements) do
		if element.hidden == nil or not element.hidden then
			if not element.available then
				text = text .. "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
			elseif element.completed then
				text = text .. "|T" .. addon.icons.COMPLETED .. ":12|t"
			elseif element.t == "PICKUP" and addon.questsDB[element.questId].req > addon.level then
				text = text .. "|T" .. addon.icons.PICKUP_UNAVAILABLE .. ":12|t"
				if tooltip ~= "" then tooltip = tooltip .. "\n" end
				local q = getQuestText(element.questId, "PICKUP")
				tooltip = tooltip .. string.format(L.QUEST_REQUIRED_LEVEL, q, addon.questsDB[element.questId].req)
			elseif element.t == "TURNIN" and not element.finished then
				text = text .. "|T" .. addon.icons.TURNIN_INCOMPLETE .. ":12|t"
			elseif addon.icons[element.t] ~= nil then
				text = text .. "|T" .. addon.icons[element.t] .. ":12|t"
			end
			if element.text ~= nil then
				text = text .. element.text
			end
			if addon.quests[element.questId] ~= nil then
				text = text .. getQuestText(element.questId, element.t, step.active)
			end
			if element.t == "LOC" or element.t == "GOTO" then
				if element.mapIndex ~= nil then
					text = text .. "|T" .. addon.icons.MAP .. element.mapIndex .. ":12|t"
				else
					text = text .. "|T" .. addon.icons.MAP .. ":12|t"
				end
			end
		end
		if not element.available and element.missingPrequests ~= nil then
			if tooltip ~= "" then tooltip = tooltip .. "\n" end
			tooltip = tooltip .. "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
			if #element.missingPrequests == 1 then
				tooltip = tooltip .. L.MISSING_PREQUEST .. " "
			else
				tooltip = tooltip .. L.MISSING_PREQUESTS .. " "
			end
			for i, id in ipairs(element.missingPrequests) do
				tooltip = tooltip .. getQuestText(id, "TURNIN")
			end			
		elseif not element.completed and element.questId ~= nil and addon.quests[element.questId].followup ~= nil and #addon.quests[element.questId].followup > 0 then
			if skipTooltip ~= "" then skipTooltip = skipTooltip .. "\n" end
			skipTooltip = skipTooltip .. "|T" .. addon.icons.UNAVAILABLE .. ":12|t"
			if #addon.quests[element.questId].followup == 1 then
				skipTooltip = skipTooltip .. string.format(L.STEP_FOLLOWUP_QUEST, getQuestText(addon.quests[element.questId].followup[1], "PICKUP"))
			else
				skipTooltip = skipTooltip .. string.format(L.STEP_FOLLOWUP_QUESTS, #addon.quests[element.questId].followup)
			end
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
	addon.mainFrame.steps[i].textBox.tooltip = tooltip
	addon.mainFrame.steps[i].tooltip = skipTooltip
end

local function queryPosition()
	if addon.queryingPosition then return end
	addon.queryingPosition = true
	C_Timer.After(2, function() 
		addon.queryingPosition = false
		local y, x = UnitPosition("player")
		--if addon.debugging then print("LIME : queryingPosition", x, y) end
		if x ~= addon.x or y ~= addon.y then
			addon.x = x
			addon.y = y
			addon.updateSteps()
		else
			queryPosition()
		end
	end)
end

local function updateStepCompletion(i, completedIndexes)
	local step = addon.currentGuide.steps[i]

	local wasCompleted = step.completed
	if not step.manual then
		step.completed = nil
		for j, element in ipairs(step.elements) do
			if element.t == "PICKUP" then
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
			elseif element.t == "GOTO" then
				if not wasCompleted and step.active and not step.skip then
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
		if step.completed == nil then step.completed = step.completeWithNext and wasCompleted end
	end
	
	if i > 1 then
		local pstep = addon.currentGuide.steps[i - 1]
		local c = step.completed or step.skip --or not step.available
		if pstep.completed ~= c and pstep.completeWithNext ~= nil and pstep.completeWithNext then
			if addon.debugging then print("LIME: complete with next ", i - 1, c, step.skip, step.available) end
			pstep.completed = c
			table.insert(completedIndexes, i - 1)
		end
	end
	
	if step.completed ~= wasCompleted then
		table.insert(completedIndexes, i)
	end	
end

local function updateStepAvailability(i, changedIndexes, marked)
	local step = addon.currentGuide.steps[i]
	if step.manual then return false end
	
	local wasAvailable = step.available
	step.available = true
	for j, element in ipairs(step.elements) do
		element.available = true
		if element.t == "PICKUP" then
			if addon.questsDB[element.questId].prequests ~= nil then
				element.missingPrequests = {}
				for i, id in ipairs(addon.questsDB[element.questId].prequests) do
					if not addon.quests[id].completed and marked.TURNIN[id] == nil then
						element.available = false
						table.insert(element.missingPrequests, id)
					end
				end
			end
			if not step.skip and element.available then
				marked.PICKUP[element.questId] = true
			end
		elseif element.t == "COMPLETE" then
			if marked.PICKUP[element.questId] == nil and 
				not addon.quests[element.questId].completed and 
				addon.quests[element.questId].logIndex == nil 
			then 
				element.available = false 
			end
			if step.skip and element.available then
				marked.SKIP_COMPLETE[element.questId] = true
			end
		elseif element.t == "TURNIN" then
			if marked.PICKUP[element.questId] == nil and 
				not addon.quests[element.questId].completed and 
				addon.quests[element.questId].logIndex == nil 
			then 
				element.available = false 
			end
			if marked.SKIP_COMPLETE[element.questId] ~= nil then element.available = false end
			if not step.skip and element.available then
				marked.TURNIN[element.questId] = true
			end
		end
		if not element.available then step.available = false end
	end

	if i > 1 then
		local pstep = addon.currentGuide.steps[i - 1]
		if pstep.available ~= step.available and pstep.completeWithNext ~= nil and pstep.completeWithNext then
			if addon.debugging then print("LIME: complete with next ", i - 1, step.skip, step.available) end
			pstep.available = step.available
			table.insert(changedIndexes, i - 1)
		end
	end

	if step.available ~= wasAvailable then
		table.insert(changedIndexes, i)
	end
end

local function updateStepsCompletion(changedIndexes)
	if addon.debugging then print("LIME: update steps completion") end
	local newIndexes
	repeat
		newIndexes = {}
		local marked = {PICKUP = {}, SKIP_COMPLETE = {}, TURNIN = {}}
		for i, step in ipairs(addon.currentGuide.steps) do
			updateStepCompletion(i, newIndexes)
			updateStepAvailability(i, newIndexes, marked)
			if addon.mainFrame.steps ~= nil and addon.mainFrame.steps[i] ~= nil then 
				addon.mainFrame.steps[i]:SetChecked(step.completed or step.skip)
				addon.mainFrame.steps[i]:SetEnabled((not step.completed and step.available) or step.skip)
			end
		end
		for _, i in ipairs(newIndexes) do
			if not contains(changedIndexes, i) then
		 		table.insert(changedIndexes, i)
			elseif addon.debugging then
				error("step " .. i .. " changed more than once")
			end
		end
	until(#newIndexes == 0)
	if addon.debugging then print("LIME: changed ", #changedIndexes) end
end

local function fadeoutStep(indexes)
	--if addon.debugging then print("LIME: fade out", #indexes) end
	if #indexes == 0 then return end
	local keepFading = {}
	local update = false
	for _, i in ipairs(indexes) do
		step = addon.currentGuide.steps[i]
		if not step.completed and not step.skip and step.available then
			step.fading = nil
			if addon.mainFrame.steps ~= nil and addon.mainFrame.steps[i] ~= nil then addon.mainFrame.steps[i]:SetAlpha(1) end
		else	
			step.active = false
			if (step.fading ~= nil and step.fading <= 0) or not GuidelimeDataChar.hideCompletedSteps then
				step.fading = nil
				if not containsWith(addon.currentGuide.steps, function(s) return s.fading ~= nil end) then update = true end
			else
				if step.fading == nil then step.fading = 1 end
				step.fading = step.fading - 0.05
				if addon.mainFrame.steps ~= nil and addon.mainFrame.steps[i] ~= nil then 
					if addon.debugging then print("LIME: fade out", i, step.fading) end
					addon.mainFrame.steps[i]:SetAlpha(step.fading) 
				end
				table.insert(keepFading, i)
			end			
		end
	end
	if update then 
		if GuidelimeDataChar.hideCompletedSteps then
			addon.updateMainFrame() 
		else
			--addon.updateSteps() 
		end			
	end
	if #keepFading > 0 then
		C_Timer.After(0.1, function() 
			fadeoutStep(keepFading)
		end)
	end
end

local function updateStepsActivation()
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
			if containsWith(step.elements, function(e) return e.t == "GOTO" end) then
				queryPosition()
			end
		end
	end
end

local function updateStepsMapIcons()
	if addon.currentGuide == nil then return end
	addon.removeMapIcons()
	for i, step in ipairs(addon.currentGuide.steps) do
		if not step.skip and not step.completed then
			for j, element in ipairs(step.elements) do
				if element.t == "LOC" or element.t == "GOTO" then
					mapIcon = addon.addMapIcon(element)
				end
			end
		end
	end
	addon.showMapIcons()
end

function addon.updateStepsText()
	--if addon.debugging then print("LIME: update step texts") end
	if addon.currentGuide == nil then return end
	for i, step in ipairs(addon.currentGuide.steps) do
		updateStepText(i)
	end
end

function addon.updateSteps(completedIndexes)
	--if addon.debugging then print("LIME: update steps") end
	if addon.currentGuide == nil then return end
	if completedIndexes == nil then completedIndexes = {} end
	updateStepsCompletion(completedIndexes)
	updateStepsActivation()
	updateStepsMapIcons()
	addon.updateStepsText()
	fadeoutStep(completedIndexes) 
end

function addon.updateMainFrame()
	--if addon.debugging then print("LIME: updating main frame") end
	
	if addon.mainFrame.steps ~= nil then
		for k, step in pairs(addon.mainFrame.steps) do
			step:Hide()
		end
	end
	addon.mainFrame.steps = {}
	
	if addon.currentGuide == nil then
		if addon.debugging then print("LIME: No guide loaded") end
	else
		--if addon.debugging then print("LIME: Showing guide " .. addon.currentGuide.name) end
		addon.updateSteps()
		
		local prev = nil
		for i, step in ipairs(addon.currentGuide.steps) do
			if (not step.completed and not step.skip and step.available) or not GuidelimeDataChar.hideCompletedSteps then
				addon.mainFrame.steps[i] = CreateFrame("CheckButton", nil, addon.mainFrame.scrollChild, "UICheckButtonTemplate")
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
					addon.updateSteps({i})
				end)
				addon.mainFrame.steps[i]:SetScript("OnEnter", function(this) if this.tooltip ~= nil and this.tooltip ~= "" then GameTooltip:SetOwner(this, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(this.tooltip); GameTooltip:Show() end end)
				addon.mainFrame.steps[i]:SetScript("OnLeave", function(this) if this.tooltip ~= nil and this.tooltip ~= "" then GameTooltip:Hide() end end)
				
				addon.mainFrame.steps[i].textBox = CreateFrame("EditBox", nil, addon.mainFrame.steps[i])
				addon.mainFrame.steps[i].textBox:SetPoint("TOPLEFT", addon.mainFrame.steps[i], "TOPLEFT", 35, -9)
				addon.mainFrame.steps[i].textBox:SetMultiLine(true)
				addon.mainFrame.steps[i].textBox:SetAutoFocus(false)
				addon.mainFrame.steps[i].textBox:SetFontObject("GameFontNormal")
				addon.mainFrame.steps[i].textBox:SetWidth(addon.mainFrame.scrollChild:GetWidth() - 35)
				addon.mainFrame.steps[i].textBox:SetScript("OnEnter", function(this) if this.tooltip ~= nil and this.tooltip ~= "" then GameTooltip:SetOwner(this, "ANCHOR_RIGHT",0,-32); GameTooltip:SetText(this.tooltip); GameTooltip:Show() end end)
				addon.mainFrame.steps[i].textBox:SetScript("OnLeave", function(this) if this.tooltip ~= nil and this.tooltip ~= "" then GameTooltip:Hide() end end)
    			addon.mainFrame.steps[i].textBox:SetScript("OnEditFocusGained", function (self) self:ClearFocus() end)
				updateStepText(i)
				
				prev = addon.mainFrame.steps[i].textBox
			end
		end
	end
	addon.mainFrame.scrollChild:SetHeight(addon.mainFrame:GetHeight())
	addon.mainFrame.scrollFrame:UpdateScrollChildRect();
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
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			tile = true, tileSize = 32, edgeSize = 0
		})
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
				EasyMenu({
					{text = L.AVAILABLE_GUIDES .. "...", func = function() addon.showGuides() end},
					{text = GAMEOPTIONS_MENU .. "...", func = function() addon.showOptions() end},
					{text = L.HIDE_COMPLETED_STEPS, checked = GuidelimeDataChar.hideCompletedSteps, func = function()
						GuidelimeDataChar.hideCompletedSteps = not GuidelimeDataChar.hideCompletedSteps
						if addon.optionsFrame ~= nil then addon.optionsFrame.options.hideCompletedSteps:SetChecked(GuidelimeDataChar.hideCompletedSteps) end
						addon.updateMainFrame()
					end}
				}, CreateFrame("Frame", "WoWProDropMenu", UIParent, "UIDropDownMenuTemplate"), "cursor", 0 , 0, "MENU");
			end
		end)
		
		addon.mainFrame.scrollFrame = CreateFrame("SCROLLFRAME", nil, addon.mainFrame, "UIPanelScrollFrameTemplate")
		addon.mainFrame.scrollFrame:SetAllPoints(addon.mainFrame)
		
		addon.mainFrame.scrollChild = CreateFrame("FRAME", nil, addon.mainFrame)
		addon.mainFrame.scrollFrame:SetScrollChild(addon.mainFrame.scrollChild);
		--addon.mainFrame.scrollChild:SetAllPoints(addon.mainFrame)
		addon.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		
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
	    --addon.mainFrame.lockBtn:SetHighlightTexture("Interface/Buttons/LockButton-Locked-Highlight")
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
	addon.loadOptionsFrame()
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
		local _, _, _, header, _, completed, _, id = GetQuestLogTitle(i)
		if not header then
			questLog[id] = {}
			questLog[id].index = i
			questLog[id].finished = (completed == 1)
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
				--if addon.debugging then print("LIME: new log entry ".. id .. " finished", q.finished) end
			end
			q.objectives = {}
			for k=1, GetNumQuestLeaderBoards(q.logIndex) do
				local desc, _, done = GetQuestLogLeaderBoard(k, addon.quests[id].logIndex)
				q.objectives[k] = {desc = desc, done = done}
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
	--if addon.debugging then print("LIME: QUEST_LOG_UPDATE", UnitPosition("playe r")) end
	
	if addon.quests ~= nil then 
		local checkCompleted, questChanged, questFound = addon.updateFromQuestLog()

		if addon.firstLogUpdate == nil then
			addon.updateMainFrame()
		else
			if not questChanged then
				if containsWith(addon.currentGuide.steps, function(s) return not s.skip and not s.completed and s.active and s.xp ~= nil end) then 
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

SLASH_Guidelime1 = "/lime"
function SlashCmdList.Guidelime(msg)
	if msg == '' then showMainFrame() 
	elseif msg == 'debug true' and not addon.debugging then addon.debugging = true; print('LIME: addon.debugging enabled')
	elseif msg == 'debug false' and addon.debugging then addon.debugging = false; print('LIME: addon.debugging disabled') end
	GuidelimeData.debugging = addon.debugging
end
