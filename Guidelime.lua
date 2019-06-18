local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")
HBDPins = LibStub("HereBeDragons-Pins-2.0")


Guidelime = CreateFrame("Frame")

Guidelime.COLOR_INACTIVE = "|cFF666666"
Guidelime.COLOR_QUEST_DEFAULT = "|cFF59C4F1"

Guidelime.mapIDs = {
	["The Hinterlands"] = 1425,
	["Moonglade"] = 1450,
	["Thousand Needles"] = 1441,
	["Winterspring"] = 1452,
	["Arathi Highlands"] = 1417,
	["Westfall"] = 1436,
	["Badlands"] = 1418,
	["Searing Gorge"] = 1427,
	["Loch Modan"] = 1432,
	["Eastern Kingdoms"] = 1415,
	["Undercity"] = 1458,
	["Desolace"] = 1443,
	["Warsong Gulch"] = 1460,
	["Tirisfal Glades"] = 1420,
	["Stormwind City"] = 1453,
	["Azshara"] = 1447,
	["The Barrens"] = 1413,
	["Swamp of Sorrows"] = 1435,
	["Azeroth"] = 947,
	["Alterac Mountains"] = 1416,
	["Darkshore"] = 1439,
	["Blasted Lands"] = 1419,
	["Stranglethorn Vale"] = 1434,
	["Eastern Plaguelands"] = 1423,
	["Duskwood"] = 1431,
	["Durotar"] = 1411,
	["Orgrimmar"] = 1454,
	["Ashenvale"] = 1440,
	["Teldrassil"] = 1438,
	["Redridge Mountains"] = 1433,
	["Un'Goro Crater"] = 1449,
	["Mulgore"] = 1412,
	["Ironforge"] = 1455,
	["Felwood"] = 1448,
	["Tanaris"] = 1446,
	["Stonetalon Mountains"] = 1442,
	["Burning Steppes"] = 1428,
	["Deadwind Pass"] = 1430,
	["Dun Morogh"] = 1426,
	["Western Plaguelands"] = 1422,
	["Wetlands"] = 1437,
	["Kalimdor"] = 1414,
	["Arathi Basin"] = 1461,
	["Silverpine Forest"] = 1421,
	["Darnassus"] = 1457,
	["Feralas"] = 1444,
	["Elwynn Forest"] = 1429,
	["Alterac Valley"] = 1459,
	["Thunder Bluff"] = 1456,
	["Dustwallow Marsh"] = 1445,
	["Hillsbrad Foothills"] = 1424,
	["Silithus"] = 1451,
}

Guidelime.icons = {
	MAP = "Interface\\Addons\\Guidelime\\Icons\\lime",
	COMPLETED = "Interface\\Buttons\\UI-CheckBox-Check",
	PICKUP = "Interface\\GossipFrame\\AvailableQuestIcon",
	COMPLETE = "Interface\\GossipFrame\\BattleMasterGossipIcon",
	TURNIN = "Interface\\GossipFrame\\ActiveQuestIcon",
	--LOC = "Interface\\Icons\\Ability_Tracking",
	--GOTO = "Interface\\Icons\\Ability_Tracking",
	HEARTH = "Interface\\Icons\\INV_Misc_Rune_01",
	FLY = "Interface\\GossipFrame\\TaxiGossipIcon",
	TRAIN = "Interface\\GossipFrame\\TrainerGossipIcon",

	--GETFLIGHTPOINT = "Interface\\Icons\\Ability_Hunter_EagleEye",
	--KILL = "Interface\\Icons\\Ability_Creature_Cursed_02",
	--MAP = "Interface\\Icons\\Ability_Spy",
	--SETHEARTH = "Interface\\AddOns\\TourGuide\\resting.tga",
	--NOTE = "Interface\\Icons\\INV_Misc_Note_01",
	--USE = "Interface\\Icons\\INV_Misc_Bag_08",
	--BUY = "Interface\\Icons\\INV_Misc_Coin_01",
	--BOAT = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
}

Guidelime.faction = UnitFactionGroup("player")
Guidelime.class = UnitClass("player")
Guidelime.race = UnitRace("player")
Guidelime.level = UnitLevel("player")
Guidelime.xp = UnitXP("player")
Guidelime.xpMax = UnitXPMax("player")
Guidelime.y, Guidelime.x = UnitPosition("player")

Guidelime.guides = {}
Guidelime.mapIcons = {}
Guidelime.queryingPositions = false
Guidelime.dataLoaded = false

local function loadData()
	local defaultOptions = {
		debugging = false,
	}
	local defaultOptionsChar = {
		mainFrameX = 0,
		mainFrameY = 0,
		mainFrameRelative = "CENTER",
		mainFrameShowing = true,
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
	
	Guidelime.debugging = GuidelimeData.debugging
	Guidelime.dataLoaded = true

	--if Guidelime.debugging then print("LIME: Initializing...") end

end

local function loadGuide(guide)

	if GuidelimeDataChar.currentGuide == nil then GuidelimeDataChar.currentGuide = {} end
	if GuidelimeDataChar.currentGuide.name == nil then 
		GuidelimeDataChar.currentGuide.name = "Demo" 
		GuidelimeDataChar.currentGuide.skip = {}
	end
	
	Guidelime.currentGuide = {}
	Guidelime.currentGuide.name = GuidelimeDataChar.currentGuide.name
	if Guidelime.guides[GuidelimeDataChar.currentGuide.name] == nil then error("guide \"" .. GuidelimeDataChar.currentGuide.name .. "\" not found") end
	for k, v in pairs(Guidelime.guides[GuidelimeDataChar.currentGuide.name]) do
		Guidelime.currentGuide[k] = v
	end
	Guidelime.currentGuide.steps = {}
	Guidelime.quests = {}
	Guidelime.currentZone = nil
	if Guidelime.currentGuide.colorQuest == nil then Guidelime.currentGuide.colorQuest = Guidelime.COLOR_QUEST_DEFAULT end
	
	--print(format(L.LOAD_MESSAGE, Guidelime.currentGuide.name))
	
	local completed = GetQuestsCompleted()
	
	for i, step in ipairs(Guidelime.guides[GuidelimeDataChar.currentGuide.name] .steps) do
		local loadLine = true
		if step.race ~= nil then
			local found = false
			for i, race in ipairs(step.race) do
				if race == Guidelime.race then found = true; break end
			end
			if not found then loadLine = false end
		end
		if step.class ~= nil then
			local found = false
			for i, class in ipairs(step.class) do
				if class == Guidelime.class then found = true; break end
			end
			if not found then loadLine = false end
		end
		if step.faction ~= nil and step.faction ~= Guidelime.faction then loadLine = false end
		if loadLine then
			table.insert(Guidelime.currentGuide.steps, step) 
			Guidelime.parseLine(step)	
			step.trackQuest = {}
			local lastGoalGoto = false
			for j, element in ipairs(step.elements) do
				if element.t == "PICKUP" or element.t == "COMPLETE" or element.t == "TURNIN" then 
					step.canComplete = true 
					lastGoalGoto = false
				elseif element.t == "LEVEL" then 
					step.canComplete = true 
					lastGoalGoto = false
				elseif element.t == "GOTO" then 
					step.canComplete = true 
					lastGoalGoto = true
				end
				if element.questId ~= nil then
					if Guidelime.quests[element.questId] == nil then
						Guidelime.quests[element.questId] = {}
						Guidelime.quests[element.questId].title = element.title
						Guidelime.quests[element.questId].completed = completed[element.questId] ~= nil and completed[element.questId]
						Guidelime.quests[element.questId].finished = Guidelime.quests[element.questId].completed
					elseif Guidelime.debugging and element.title ~= nil and element.title ~= "" and Guidelime.quests[element.questId].title ~= element.title then
						error("loading guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": different titles for quest " .. element.questId .. "\"" .. Guidelime.quests[element.questId].title .. "\" / \"" .. element.title .. "\" in line \"" .. step.text .. "\"")
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
			if lastGoalGoto then step.completeWithNext = true end
			step.skip = GuidelimeDataChar.currentGuide.skip[#Guidelime.currentGuide.steps] ~= nil and GuidelimeDataChar.currentGuide.skip[#Guidelime.currentGuide.steps]
			step.active = false
			step.completed = false
		end
	end
	
	-- output complete parsed guide for Guidelime.debugging only
	--if Guidelime.debugging then
	--	Guidelime.currentGuide.skip = GuidelimeDataChar.currentGuide.skip
	--	GuidelimeDataChar.currentGuide = Guidelime.currentGuide
	--end
end

local function updateStepText(i)
	local step = Guidelime.currentGuide.steps[i]
	if Guidelime.mainFrame.steps == nil or Guidelime.mainFrame.steps[i] == nil or Guidelime.mainFrame.steps[i].textBox == nil then return end
	local text = ""
	if not step.active then
		text = text .. Guidelime.COLOR_INACTIVE
	end
	for j, element in ipairs(step.elements) do
		if element.hidden == nil or not element.hidden then
			if element.completed then
				text = text .. "|T" .. Guidelime.icons.COMPLETED .. ":12|t"
			elseif Guidelime.icons[element.t] ~= nil then
				text = text .. "|T" .. Guidelime.icons[element.t] .. ":12|t"
			end
			if element.text ~= nil then
				text = text .. element.text
			end
			if Guidelime.quests[element.questId] ~= nil then
				if step.active and Guidelime.currentGuide.colorQuest ~= nil then
					if type(Guidelime.currentGuide.colorQuest) == "table" then
						text = text .. Guidelime.currentGuide.colorQuest[element.t]
					else
						text = text .. Guidelime.currentGuide.colorQuest
					end
				end
				text = text .. "[" .. Guidelime.quests[element.questId].title .. "]"
				if step.active and Guidelime.currentGuide.colorQuest ~= nil then
					text = text .."|r"
				end
			end
			if element.t == "LOC" or element.t == "GOTO" then
				if element.mapIndex ~= nil then
					text = text .. "|T" .. Guidelime.icons.MAP .. element.mapIndex .. ":12|t"
				else
					text = text .. "|T" .. Guidelime.icons.MAP .. ":12|t"
				end
			end
		end
	end
	if step.active then
		for id, v in pairs(step.trackQuest) do
			if Guidelime.quests[id].logIndex ~= nil and Guidelime.quests[id].objectives ~= nil then
				if type(v) == "number" then
					local o = Guidelime.quests[id].objectives[v]
					if not o.done and o.desc ~= nil and o.desc ~= "" then 
						text = text .. "\n    - " .. o.desc 
					end
				else
					for i, o in ipairs(Guidelime.quests[id].objectives) do
						if not o.done and o.desc ~= nil and o.desc ~= "" then 
							text = text .. "\n    - " .. o.desc 
						end
					end
				end
			end
		end
	end
	Guidelime.mainFrame.steps[i].textBox:SetText(text)
end

local function createIconFrame(i, minimap)
    local f = CreateFrame("Button", "Guidelime" .. i .. minimap, nil)

    f:SetFrameStrata("TOOLTIP");
    f:SetWidth(16)
    f:SetHeight(16)
    f.texture = f:CreateTexture(nil, "TOOLTIP")
    f.texture:SetTexture(Guidelime.icons.MAP .. i .. ".blp")
    f.texture:SetWidth(16)
    f.texture:SetHeight(16)
    f.texture:SetAllPoints(f)

    f:SetPoint("CENTER", 0, 0)
    f:EnableMouse(false)

    function f:Unload()
        HBDPins:RemoveMinimapIcon(Guidelime, self);
        HBDPins:RemoveWorldMapIcon(Guidelime, self);
        if(self.texture) then
            self.texture:SetVertexColor(1, 1, 1, 1);
        end
        self.miniMapIcon = nil;
		self:SetScript("OnUpdate", nil)
        self:Hide();
    end
    f:Hide()
    return f
end

local function createMapIcon()
	if #Guidelime.mapIcons >= 9 then return nil end
	local i = #Guidelime.mapIcons + 1
	Guidelime.mapIcons[i] = createIconFrame(i, 0)
	Guidelime.mapIcons[i].minimap = createIconFrame(i, 1)
	Guidelime.mapIcons[i].index = i
	Guidelime.mapIcons[i].inUse = false
	return Guidelime.mapIcons[i]
end

local function getMapIcon(element)
	for i, mapIcon in ipairs(Guidelime.mapIcons) do
		if mapIcon.inUse then 
			if mapIcon.mapID == element.mapID and mapIcon.x == element.x and mapIcon.y == element.y then
				return mapIcon
			end
		else
			return mapIcon
		end
	end
	return createMapIcon()		
end

local function addMapIcon(element)
	local mapIcon = getMapIcon(element)
	if mapIcon ~= nil then
		mapIcon.inUse = true
		mapIcon.mapID = element.mapID
		mapIcon.x = element.x
		mapIcon.y = element.y
		element.mapIndex = mapIcon.index
		--eif Guidelime.debugging then print("Guidelime : AddWorldMapIconMap", element.mapID, element.x / 100, element.y / 100) end
	end
end

local function queryPosition()
	if Guidelime.queryingPosition then return end
	Guidelime.queryingPosition = true
	C_Timer.After(2, function() 
		Guidelime.queryingPosition = false
		local y, x = UnitPosition("player")
		--if Guidelime.debugging then print("LIME : queryingPosition", x, y) end
		if x ~= Guidelime.x or y ~= Guidelime.y then
			Guidelime.x = x
			Guidelime.y = y
			Guidelime.updateSteps()
		else
			queryPosition()
		end
	end)
end

local function updateStepCompletion(i)
	local step = Guidelime.currentGuide.steps[i]
	if (step.canComplete == nil or not step.canComplete) then return false end
	
	local completed = true
	for j, element in ipairs(step.elements) do
		if element.t == "PICKUP" then
			element.completed = Guidelime.quests[element.questId].completed or Guidelime.quests[element.questId].logIndex ~= nil
			if not element.completed then completed = false end
		elseif element.t == "COMPLETE" then
			element.completed = 
				Guidelime.quests[element.questId].completed or 
				Guidelime.quests[element.questId].finished or
				(element.objective ~= nil and Guidelime.quests[element.questId].objectives ~= nil and Guidelime.quests[element.questId].objectives[element.objective].done)
			if not element.completed then completed = false end
		elseif element.t == "TURNIN" then
			element.completed = Guidelime.quests[element.questId].completed
			if not element.completed then completed = false end
		elseif element.t == "GOTO" then
			if not step.completed and step.active and not step.skip then
				local x, y = HBD:GetZoneCoordinatesFromWorld(Guidelime.x, Guidelime.y, element.mapID, false)
				--if Guidelime.debugging then print("LIME : zone coordinates", x, y, element.mapID) end
				if x ~= nil and y ~= nil then
					x = x * 100; y = y * 100;
					element.completed = (x - element.x) * (x - element.x) + (y - element.y) * (y - element.y) <= element.radius * element.radius
				else
					element.completed = false
				end
				if not element.completed then completed = false end
			else
				completed = step.completed
			end
		elseif element.t == "LEVEL" then
			element.completed = element.level <= Guidelime.level
			if element.xp ~= nil and element.level == Guidelime.level then
				if element.xpType == "REMAINING" then
					if element.xp < (Guidelime.xpMax - Guidelime.xp) then element.completed = false end
				elseif element.xpType == "PERCENTAGE" then
					if element.xp > (Guidelime.xp / Guidelime.xpMax) then element.completed = false end
				else
					if element.xp > Guidelime.xp then element.completed = false end
				end
			end			
			if not element.completed then completed = false end
		end
	end
	if completed and not step.completed then
		step.completed = true
		return true
	end
	step.completed = completed
	return false
end

local function updateStepsCompletion()
	if Guidelime.debugging then print("LIME: update steps completion") end
	local completedIndexes = {}
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		if updateStepCompletion(i) then
			table.insert(completedIndexes, i)
		end
	end
	-- another pass in reverse in order to deal with completeWithNext
	for i = #Guidelime.currentGuide.steps, 1, -1 do
		local step = Guidelime.currentGuide.steps[i]
		if i < #Guidelime.currentGuide.steps then
			local nstep = Guidelime.currentGuide.steps[i+1]
			if not step.completed and step.completeWithNext ~= nil and step.completeWithNext and nstep.completed and not step.skip then
				if Guidelime.debugging then print("LIME: complete with next ", i) end
				step.completed = true
				table.insert(completedIndexes, i)
			end
		end
		if Guidelime.mainFrame.steps ~= nil and Guidelime.mainFrame.steps[i] ~= nil then 
			Guidelime.mainFrame.steps[i]:SetChecked(step.completed or step.skip)
		end
	end
	--if Guidelime.debugging then print("LIME: completed ", #completedIndexes) end
	return completedIndexes
end

local function fadeoutStep(indexes)
	if Guidelime.debugging then print("LIME: fade out", #indexes) end
	local keepFading = {}
	local update = false
	for _, i in ipairs(indexes) do
		step = Guidelime.currentGuide.steps[i]
		if Guidelime.mainFrame.steps[i] ~= nil then
			if not step.completed and not step.skip then
				step.fading = nil
				Guidelime.mainFrame.steps[i]:SetAlpha(1)
			else	
				step.active = false
				if (step.fading ~= nil and step.fading <= 0) or not GuidelimeDataChar.hideCompletedSteps then
					step.fading = nil
					local found = false
					for j, step2 in ipairs(Guidelime.currentGuide.steps) do
						if step2.fading ~= nil then
							found = true
							break
						end
					end
					if not found then update = true end
				else
					if step.fading == nil then step.fading = 1 end
					step.fading = step.fading - 0.05
					Guidelime.mainFrame.steps[i]:SetAlpha(step.fading)
					table.insert(keepFading, i)
				end			
			end
		end
	end
	if update then 
		if GuidelimeDataChar.hideCompletedSteps then
			Guidelime.updateMainFrame() 
		else
			Guidelime.updateSteps() 
		end			
	end
	if #keepFading > 0 then
		C_Timer.After(0.1, function() 
			fadeoutStep(keepFading)
		end)
	end
end

local function updateStepsActivation()
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		step.active = not step.completed
		if step.active then
			for j, pstep in ipairs(Guidelime.currentGuide.steps) do
				if j == i then break end
				if (pstep.required == nil or pstep.required) and not pstep.skip and not pstep.completed then
					step.active = false
					break 
				end
			end
		end
		if step.active then
			for j, element in ipairs(step.elements) do
				if element.t == "GOTO" then
					queryPosition()
					break
				end
			end
		end
		if Guidelime.mainFrame.steps ~= nil and Guidelime.mainFrame.steps[i] ~= nil then 
			Guidelime.mainFrame.steps[i]:SetEnabled(step.active or step.skip)
		end
	end
end

local function updateStepsMapIcons()
	if Guidelime.currentGuide == nil then return end
	HBDPins:RemoveAllWorldMapIcons(Guidelime)
	HBDPins:RemoveAllMinimapIcons(Guidelime)
	for i, mapIcon in ipairs(Guidelime.mapIcons) do
		mapIcon.inUse = false
	end
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		for j, element in ipairs(step.elements) do
			element.mapIndex = nil
		end
		if not step.skip and not step.completed then
			for j, element in ipairs(step.elements) do
				if element.t == "LOC" or element.t == "GOTO" then
					mapIcon = addMapIcon(element)
				end
			end
		end
	end
	for i = #Guidelime.mapIcons, 1, -1 do
		local mapIcon = Guidelime.mapIcons[i]
		if mapIcon.inUse then
			--if Guidelime.debugging then print("LIME: map icon", mapIcon.mapID, mapIcon.x, mapIcon.y) end
			HBDPins:AddWorldMapIconMap(Guidelime, mapIcon, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, 3)
			HBDPins:AddMinimapIconMap(Guidelime, mapIcon.minimap, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, true, true)
		end
	end
end

local function updateStepsText()
	--if Guidelime.debugging then print("LIME: update step texts") end
	if Guidelime.currentGuide == nil then return end
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		updateStepText(i)
	end
end

function Guidelime.updateSteps()
	--if Guidelime.debugging then print("LIME: update steps") end
	if Guidelime.currentGuide == nil then return end
	local completedIndexes = updateStepsCompletion()
	updateStepsActivation()
	updateStepsMapIcons()
	updateStepsText()
	if #completedIndexes > 0 and Guidelime.mainFrame.steps ~= nil then
		fadeoutStep(completedIndexes) 
	end
end

function Guidelime.updateMainFrame()
	--if Guidelime.debugging then print("LIME: updating main frame") end
	
	if Guidelime.mainFrame.steps ~= nil then
		for k, step in pairs(Guidelime.mainFrame.steps) do
			step:Hide()
		end
	end
	Guidelime.mainFrame.steps = {}
	
	if Guidelime.currentGuide == nil then 
		loadGuide()
	end
	Guidelime.updateSteps()
	
	if Guidelime.currentGuide == nil then
		if Guidelime.debugging then print("LIME: No guide loaded") end
	else
		--if Guidelime.debugging then print("LIME: Showing guide " .. Guidelime.currentGuide.name) end
		
		local prev = nil
		for i, step in ipairs(Guidelime.currentGuide.steps) do
			if (not step.completed and not step.skip) or not GuidelimeDataChar.hideCompletedSteps then
				Guidelime.mainFrame.steps[i] = CreateFrame("CheckButton", nil, Guidelime.mainFrame.scrollChild, "UICheckButtonTemplate")
				if prev == nil then
					Guidelime.mainFrame.steps[i]:SetPoint("TOPLEFT", Guidelime.mainFrame.scrollChild, "TOPLEFT", 0, -14)
				else
					Guidelime.mainFrame.steps[i]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -35, -2)
				end
				Guidelime.mainFrame.steps[i]:SetEnabled(step.active or step.skip)
				Guidelime.mainFrame.steps[i]:SetChecked(step.completed or step.skip)
				Guidelime.mainFrame.steps[i]:SetScript("OnClick", function() 
					local step = Guidelime.currentGuide.steps[i]
					step.skip = Guidelime.mainFrame.steps[i]:GetChecked()
					GuidelimeDataChar.currentGuide.skip[i] = step.skip
					if step.skip then
						fadeoutStep({i})
					else
						Guidelime.updateSteps()
					end
				end)
				
				Guidelime.mainFrame.steps[i].textBox=CreateFrame("EditBox", nil, Guidelime.mainFrame.steps[i])
				Guidelime.mainFrame.steps[i].textBox:SetPoint("TOPLEFT", Guidelime.mainFrame.steps[i], "TOPLEFT", 35, -9)
				Guidelime.mainFrame.steps[i].textBox:SetMultiLine(true)
				Guidelime.mainFrame.steps[i].textBox:EnableMouse(false)
				Guidelime.mainFrame.steps[i].textBox:SetAutoFocus(false)
				Guidelime.mainFrame.steps[i].textBox:SetFontObject("GameFontNormal")
				Guidelime.mainFrame.steps[i].textBox:SetWidth(Guidelime.mainFrame.scrollChild:GetWidth() - 35)
				updateStepText(i)
				
				prev = Guidelime.mainFrame.steps[i].textBox
			end
		end
	end
	Guidelime.mainFrame.scrollChild:SetHeight(Guidelime.mainFrame:GetHeight())
	Guidelime.mainFrame.scrollFrame:UpdateScrollChildRect();
end

function Guidelime.showMainFrame()
	
	if not Guidelime.dataLoaded then loadData() end
	
	if Guidelime.mainFrame == nil then
		--if Guidelime.debugging then print("LIME: initializing main frame") end
		Guidelime.mainFrame = CreateFrame("FRAME", nil, UIParent)
		Guidelime.mainFrame:SetWidth(GuidelimeDataChar.mainFrameWidth)
		Guidelime.mainFrame:SetHeight(GuidelimeDataChar.mainFrameHeight)
		Guidelime.mainFrame:SetPoint(GuidelimeDataChar.mainFrameRelative, UIParent, GuidelimeDataChar.mainFrameRelative, GuidelimeDataChar.mainFrameX, GuidelimeDataChar.mainFrameY)
		Guidelime.mainFrame:SetBackdrop({
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			tile = true, tileSize = 32, edgeSize = 0
		})
		Guidelime.mainFrame:SetFrameLevel(999)
		Guidelime.mainFrame:SetMovable(true)
		Guidelime.mainFrame:EnableMouse(true)
		Guidelime.mainFrame:SetScript("OnMouseDown", function(this, button) 
			if (button == "LeftButton") then Guidelime.mainFrame:StartMoving() end
		end)
		Guidelime.mainFrame:SetScript("OnMouseUp", function(this, button) 
			if (button == "LeftButton") then 
				Guidelime.mainFrame:StopMovingOrSizing() 
				local _
				_, _, GuidelimeDataChar.mainFrameRelative, GuidelimeDataChar.mainFrameX, GuidelimeDataChar.mainFrameY = Guidelime.mainFrame:GetPoint()
			elseif (button == "RightButton") then
				Guidelime.showGuides()
			end
		end)
		
		Guidelime.mainFrame.scrollFrame = CreateFrame("SCROLLFRAME", nil, Guidelime.mainFrame, "UIPanelScrollFrameTemplate")
		Guidelime.mainFrame.scrollFrame:SetAllPoints(Guidelime.mainFrame)
		
		Guidelime.mainFrame.scrollChild = CreateFrame("FRAME", nil, Guidelime.mainFrame)
		Guidelime.mainFrame.scrollFrame:SetScrollChild(Guidelime.mainFrame.scrollChild);
		--Guidelime.mainFrame.scrollChild:SetAllPoints(Guidelime.mainFrame)
		Guidelime.mainFrame.scrollChild:SetWidth(GuidelimeDataChar.mainFrameWidth)
		
		if Guidelime.firstLogUpdate then 
			Guidelime.updateMainFrame() 
		elseif Guidelime.currentGuide == nil then 
			loadGuide()
		end

		Guidelime.mainFrame.doneBtn = CreateFrame("BUTTON", "doneBtn", Guidelime.mainFrame, "UIPanelButtonTemplate")
		Guidelime.mainFrame.doneBtn:SetWidth(12)
		Guidelime.mainFrame.doneBtn:SetHeight(14)
		Guidelime.mainFrame.doneBtn:SetText( "X" )
		--Guidelime.mainFrame.doneBtn.PushedTexture:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
		--Guidelime.mainFrame.doneBtn.NormalTexture:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
		Guidelime.mainFrame.doneBtn:SetPoint("TOPRIGHT", Guidelime.mainFrame, "TOPRIGHT", -5, -5)
		Guidelime.mainFrame.doneBtn:SetScript("OnClick", function() 
			Guidelime.mainFrame:Hide() 
			HBDPins:RemoveAllWorldMapIcons(Guidelime)
			HBDPins:RemoveAllMinimapIcons(Guidelime)
			GuidelimeDataChar.mainFrameShowing = false
			Guidelime.optionsFrame.options.mainFrameShowing:SetChecked(false)
		end)
	
		if Guidelime.debugging then
			Guidelime.mainFrame.reloadBtn = CreateFrame("BUTTON", nil, Guidelime.mainFrame, "UIPanelButtonTemplate")
			Guidelime.mainFrame.reloadBtn:SetWidth(12)
			Guidelime.mainFrame.reloadBtn:SetHeight(14)
			Guidelime.mainFrame.reloadBtn:SetText( "R" )
			Guidelime.mainFrame.reloadBtn:SetPoint("TOPRIGHT", Guidelime.mainFrame, "TOPRIGHT", -25, -5)
			Guidelime.mainFrame.reloadBtn:SetScript("OnClick", function() 
				ReloadUI()
			end)
		end
	end
	Guidelime.mainFrame:Show()
	Guidelime.updateSteps()
	GuidelimeDataChar.mainFrameShowing = true
end

-- Register events and call functions
Guidelime:SetScript("OnEvent", function(self, event, ...)
	Guidelime[event](self, ...)
end)

Guidelime:RegisterEvent('PLAYER_ENTERING_WORLD', Guidelime)
function Guidelime:PLAYER_ENTERING_WORLD()
	--if Guidelime.debugging then print("LIME: Player entering world...") end
	if not Guidelime.dataLoaded then loadData() end
	Guidelime.loadOptionsFrame()
	if GuidelimeDataChar.mainFrameShowing then Guidelime.showMainFrame() end
end

Guidelime:RegisterEvent('PLAYER_LEVEL_UP', Guidelime)
function Guidelime:PLAYER_LEVEL_UP(level)
	if Guidelime.debugging then print("LIME: You reached level " .. level .. ". Grats!") end
	Guidelime.level = level
	Guidelime.updateSteps()
end

Guidelime:RegisterEvent('QUEST_LOG_UPDATE', Guidelime)
function Guidelime:QUEST_LOG_UPDATE()
	--if Guidelime.debugging then print("LIME: QUEST_LOG_UPDATE", Guidelime.firstLogUpdate) end
	Guidelime.xp = UnitXP("player")
	Guidelime.xpMax = UnitXPMax("player")
	Guidelime.y, Guidelime.x = UnitPosition("player")
	--if Guidelime.debugging then print("LIME: QUEST_LOG_UPDATE", UnitPosition("playe r")) end
	
	if Guidelime.quests ~= nil then 
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
		for id, q in pairs(Guidelime.quests) do
			if questLog[id] ~= nil then
				if q.logIndex ~= nil then
					questFound = true
					if q.logIndex ~= questLog[id].index or q.finished ~= questLog[id].finished then
						questChanged = true
						q.logIndex = questLog[id].index
						q.finished = questLog[id].finished
						--if Guidelime.debugging then print("LIME: changed log entry ".. id .. " finished", q.finished) end
					end
				else
					questFound = true
					questChanged = true
					q.logIndex = questLog[id].index
					q.finished = questLog[id].finished
					--if Guidelime.debugging then print("LIME: new log entry ".. id .. " finished", q.finished) end
				end
				q.objectives = {}
				for k=1, GetNumQuestLeaderBoards(q.logIndex) do
					local desc, _, done = GetQuestLogLeaderBoard(k, Guidelime.quests[id].logIndex)
					q.objectives[k] = {desc = desc, done = done}
				end
			else
				if q.logIndex ~= nil then
					checkCompleted = true
					q.logIndex = nil
					--if Guidelime.debugging then print("LIME: removed log entry ".. id) end
				end
			end
		end

		if Guidelime.firstLogUpdate == nil then
			Guidelime.updateMainFrame()
		else
			if not questChanged then
				for i, step in ipairs(Guidelime.currentGuide.steps) do
					if not step.skip and not step.completed and step.active and step.xp ~= nil then
						questChanged = true
					end
				end
			end
			
			if checkCompleted then
				if questFound then
					updateStepsText()
				end
				C_Timer.After(1, function() 
					local completed = GetQuestsCompleted()
					local questCompleted = false
					for id, q in pairs(Guidelime.quests) do
						if completed[id] and not q.completed then
							questCompleted = true
							q.finished = true
							q.completed = true
						end
					end
					if questCompleted == true or not GuidelimeDataChar.hideCompletedSteps then
						Guidelime.updateSteps()
					else
						-- quest was abandoned so redraw erverything since completed steps might have to be done again
						Guidelime.updateMainFrame()
					end
				end)
			elseif questChanged then 
				Guidelime.updateSteps() 
			elseif questFound then
				updateStepsText()
			end
		end
	end
	Guidelime.firstLogUpdate = true
end

SLASH_Guidelime1 = "/lime"
function SlashCmdList.Guidelime(msg)
	if msg == '' then showMainFrame() 
	elseif msg == 'debug true' and not Guidelime.debugging then Guidelime.debugging = true; print('LIME: Guidelime.debugging enabled')
	elseif msg == 'debug false' and Guidelime.debugging then Guidelime.debugging = false; print('LIME: Guidelime.debugging disabled') end
	GuidelimeData.debugging = Guidelime.debugging
end
