local addonName, addon = ...
local L = addon.L

local debugging

HBD = LibStub("HereBeDragons-2.0")
HBDPins = LibStub("HereBeDragons-Pins-2.0")


Guidelime = CreateFrame("Frame")
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

local dataLoaded = false

local COLOR_INACTIVE = "|cFF666666"

local mapIDs = {
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
	debugging = GuidelimeData.debugging

	--if debugging then print("LIME: Initializing...") end

	dataLoaded = true
end

local function parseLine(step)
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
				elseif string.sub(code, 2, 2) == "W" then
					element.t = "WORK"
				else
					error("parsing guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": code not recognized for [" .. code .. "] in line \"" .. step.text .. "\"")
				end
				string.gsub(string.sub(code, 3), "(%d+)(.*)", function(id, title)
					element.questId = tonumber(id)
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
					if zone ~= "" then Guidelime.currentZone = mapIDs[zone] end
					element.mapID = Guidelime.currentZone
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
					if zone ~= "" then Guidelime.currentZone = mapIDs[zone] end
					element.mapID = Guidelime.currentZone
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
			parseLine(step)	
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
					elseif debugging and element.title ~= nil and element.title ~= "" and Guidelime.quests[element.questId].title ~= element.title then
						error("loading guide \"" .. GuidelimeDataChar.currentGuide.name .. "\": different titles for quest " .. element.questId .. "\"" .. Guidelime.quests[element.questId].title .. "\" / \"" .. element.title .. "\" in line \"" .. step.text .. "\"")
					end
					if element.t == "COMPLETE" or element.t == "TURNIN" or element.t == "WORK" then
						step.trackQuest[element.questId] = true
					end
				end
			end
			if lastGoalGoto then step.completeWithNext = true end
			step.skip = GuidelimeDataChar.currentGuide.skip[#Guidelime.currentGuide.steps] ~= nil and GuidelimeDataChar.currentGuide.skip[#Guidelime.currentGuide.steps]
			step.active = false
			step.completed = false
		end
	end
	
	-- output complete parsed guide for debugging only
	--if debugging then
	--	Guidelime.currentGuide.skip = GuidelimeDataChar.currentGuide.skip
	--	GuidelimeDataChar.currentGuide = Guidelime.currentGuide
	--end
end

local function updateStepText(i)
	local step = Guidelime.currentGuide.steps[i]
	if Guidelime_mainFrame.steps == nil or Guidelime_mainFrame.steps[i] == nil or Guidelime_mainFrame.steps[i].textBox == nil then return end
	local text = ""
	if not step.active then
		text = text .. COLOR_INACTIVE
	end
	if (step.elements == nil) then
		text = text .. "?"
	else
		for j, element in ipairs(step.elements) do
			if element.hidden == nil or not element.hidden then
				if element.t == "TEXT" or element.t == "LEVEL" then
					text = text .. element.text
				elseif Guidelime.quests[element.questId] ~= nil then
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
				elseif element.t == "LOC" or element.t == "GOTO" then
					if element.mapIndex ~= nil then
						text = text .. "|TInterface\\Addons\\Guidelime\\Icons\\lime" .. element.mapIndex .. ":12|t"
					else
						text = text .. "|TInterface\\Addons\\Guidelime\\Icons\\lime:12|t"
					end
				end
			end
		end
	end
	if step.active then
		for id, v in pairs(step.trackQuest) do
			if Guidelime.quests[id].logIndex ~= nil then
				for k=1, GetNumQuestLeaderBoards(Guidelime.quests[id].logIndex) do
					local desc, typ, done = GetQuestLogLeaderBoard(k, Guidelime.quests[id].logIndex)
					--if debugging then print("LIME: ", desc,typ,done) end
					if not done and desc ~= nil and desc ~= "" then 
						text = text .. "\n    - " .. desc 
					end
				end
			end
		end
	end
	Guidelime_mainFrame.steps[i].textBox:SetText(text)
end

local function createIconFrame(i, minimap)
    local f = CreateFrame("Button", "Guidelime" .. i .. minimap, nil)

    f:SetFrameStrata("TOOLTIP");
    f:SetWidth(16)
    f:SetHeight(16)
    f.texture = f:CreateTexture(nil, "TOOLTIP")
    f.texture:SetTexture("Interface\\AddOns\\Guidelime\\Icons\\lime" .. i .. ".blp")
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
		--eif debugging then print("Guidelime : AddWorldMapIconMap", element.mapID, element.x / 100, element.y / 100) end
	end
end

local function queryPosition()
	if Guidelime.queryingPosition then return end
	Guidelime.queryingPosition = true
	C_Timer.After(2, function() 
		Guidelime.queryingPosition = false
		local y, x = UnitPosition("player")
		--if debugging then print("LIME : queryingPosition", x, y) end
		if x ~= Guidelime.x or y ~= Guidelime.y then
			Guidelime.x = x
			Guidelime.y = y
			Guidelime_updateSteps()
		else
			queryPosition()
		end
	end)
end

local function updateStepCompletion(i)
	local step = Guidelime.currentGuide.steps[i]
	if (step.canComplete == nil or not step.canComplete) then step.completed = false; return end
	
	for j, element in ipairs(step.elements) do
		if element.t == "PICKUP" then
			if not Guidelime.quests[element.questId].completed and Guidelime.quests[element.questId].logIndex == nil then step.completed = false; return false end
		elseif element.t == "COMPLETE" then
			if not Guidelime.quests[element.questId].completed and not Guidelime.quests[element.questId].finished then step.completed = false; return false end
		elseif element.t == "TURNIN" then
			if not Guidelime.quests[element.questId].completed then 	step.completed = false; return false end
		elseif element.t == "GOTO" then
			if step.completed or not step.active or step.skip then return false end
			local x, y = HBD:GetZoneCoordinatesFromWorld(Guidelime.x, Guidelime.y, element.mapID, false)
			--if debugging then print("LIME : zone coordinates", x, y, element.mapID) end
			if x == nil or y == nil then step.completed = false; return false end
			x = x * 100; y = y * 100
			if (x - element.x) * (x - element.x) + (y - element.y) * (y - element.y) > element.radius * element.radius then step.completed = false; return false end
		elseif element.t == "LEVEL" then
			if element.level > Guidelime.level then step.completed = false; return false end
			if element.xp ~= nil and element.level == Guidelime.level then
				if element.xpType == "REMAINING" then
					if element.xp < (Guidelime.xpMax - Guidelime.xp) then step.completed = false; return false end
				elseif element.xpType == "PERCENTAGE" then
					if element.xp > (Guidelime.xp / Guidelime.xpMax) then step.completed = false; return false end
				else
					if element.xp > Guidelime.xp then step.completed = false; return false end
				end
			end			
		end
	end
	if not step.completed then
		step.completed = true
		return true
	end
	return false
end

local function updateStepsCompletion()
	local completedIndexes = {}
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		if updateStepCompletion(i) then
			table.insert(completedIndexes, i)
		end
	end
	-- another parse in reverse in order to deal with completeWithNext
	for i = #Guidelime.currentGuide.steps, 1, -1 do
		local step = Guidelime.currentGuide.steps[i]
		if i < #Guidelime.currentGuide.steps then
			local nstep = Guidelime.currentGuide.steps[i+1]
			if not step.completed and step.completeWithNext and nstep.completed then
				step.completed = true
				table.insert(completedIndexes, i)
			end
		end
		if Guidelime_mainFrame.steps ~= nil and Guidelime_mainFrame.steps[i] ~= nil then 
			Guidelime_mainFrame.steps[i]:SetChecked(step.completed or step.skip)
		end
	end
	--if debugging then print("LIME: completed ", #completedIndexes) end
	return completedIndexes
end

local function fadeoutStep(indexes)
	--if debugging then print("LIME: fade out", #indexes) end
	local keepFading = {}
	local update = false
	for _, i in ipairs(indexes) do
		step = Guidelime.currentGuide.steps[i]
		if Guidelime_mainFrame.steps[i] ~= nil then
			if not step.completed and not step.skip then
				step.fading = nil
				Guidelime_mainFrame.steps[i]:SetAlpha(1)
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
					Guidelime_mainFrame.steps[i]:SetAlpha(step.fading)
					table.insert(keepFading, i)
				end			
			end
		end
	end
	if update then 
		if GuidelimeDataChar.hideCompletedSteps then
			Guidelime_updateMainFrame() 
		else
			Guidelime_updateSteps() 
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
		if Guidelime_mainFrame.steps ~= nil and Guidelime_mainFrame.steps[i] ~= nil then 
			Guidelime_mainFrame.steps[i]:SetEnabled(step.active or step.skip)
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
			--if debugging then print("LIME: map icon", mapIcon.mapID, mapIcon.x, mapIcon.y) end
			HBDPins:AddWorldMapIconMap(Guidelime, mapIcon, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, 3)
			HBDPins:AddMinimapIconMap(Guidelime, mapIcon.minimap, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, true, true)
		end
	end
end

local function updateStepsText()
	--if debugging then print("LIME: update step texts") end
	if Guidelime.currentGuide == nil then return end
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		updateStepText(i)
	end
end

function Guidelime_updateSteps()
	--if debugging then print("LIME: update steps") end
	if Guidelime.currentGuide == nil then return end
	local completedIndexes = updateStepsCompletion()
	updateStepsActivation()
	updateStepsMapIcons()
	updateStepsText()
	if #completedIndexes > 0 and Guidelime_mainFrame.steps ~= nil then
		fadeoutStep(completedIndexes) 
	end
end

function Guidelime_updateMainFrame()
	--if debugging then print("LIME: updating main frame") end
	
	if Guidelime_mainFrame.steps ~= nil then
		for k, step in pairs(Guidelime_mainFrame.steps) do
			step:Hide()
		end
	end
	Guidelime_mainFrame.steps = {}
	
	if Guidelime.currentGuide == nil then 
		loadGuide()
	end
	Guidelime_updateSteps()
	
	if Guidelime.currentGuide == nil then
		if debugging then print("LIME: No guide loaded") end
	else
		--if debugging then print("LIME: Showing guide " .. Guidelime.currentGuide.name) end
		
		local prev = nil
		for i, step in ipairs(Guidelime.currentGuide.steps) do
			if (not step.completed and not step.skip) or not GuidelimeDataChar.hideCompletedSteps then
				Guidelime_mainFrame.steps[i] = CreateFrame("CheckButton", nil, Guidelime_mainFrame.scrollChild, "UICheckButtonTemplate")
				if prev == nil then
					Guidelime_mainFrame.steps[i]:SetPoint("TOPLEFT", Guidelime_mainFrame.scrollChild, "TOPLEFT", 0, -14)
				else
					Guidelime_mainFrame.steps[i]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -35, -2)
				end
				Guidelime_mainFrame.steps[i]:SetEnabled(step.active or step.skip)
				Guidelime_mainFrame.steps[i]:SetChecked(step.completed or step.skip)
				Guidelime_mainFrame.steps[i]:SetScript("OnClick", function() 
					local step = Guidelime.currentGuide.steps[i]
					step.skip = Guidelime_mainFrame.steps[i]:GetChecked()
					GuidelimeDataChar.currentGuide.skip[i] = step.skip
					if step.skip then
						fadeoutStep({i})
					else
						Guidelime_updateSteps()
					end
				end)
				
				Guidelime_mainFrame.steps[i].textBox=CreateFrame("EditBox", nil, Guidelime_mainFrame.steps[i])
				Guidelime_mainFrame.steps[i].textBox:SetPoint("TOPLEFT", Guidelime_mainFrame.steps[i], "TOPLEFT", 35, -9)
				Guidelime_mainFrame.steps[i].textBox:SetMultiLine(true)
				Guidelime_mainFrame.steps[i].textBox:EnableMouse(false)
				Guidelime_mainFrame.steps[i].textBox:SetAutoFocus(false)
				Guidelime_mainFrame.steps[i].textBox:SetFontObject("GameFontNormal")
				Guidelime_mainFrame.steps[i].textBox:SetWidth(Guidelime_mainFrame.scrollChild:GetWidth() - 35)
				updateStepText(i)
				
				prev = Guidelime_mainFrame.steps[i].textBox
			end
		end
	end
	Guidelime_mainFrame.scrollChild:SetHeight(Guidelime_mainFrame:GetHeight())
	Guidelime_mainFrame.scrollFrame:UpdateScrollChildRect();
end

local function showMainFrame()
	
	if not dataLoaded then loadData() end
	
	if Guidelime_mainFrame == nil then
		--if debugging then print("LIME: initializing main frame") end
		local initParent = UIParent
		Guidelime_mainFrame = CreateFrame("FRAME", nil, initParent)
		Guidelime_mainFrame:SetWidth(GuidelimeDataChar.mainFrameWidth)
		Guidelime_mainFrame:SetHeight(GuidelimeDataChar.mainFrameHeight)
		Guidelime_mainFrame:SetPoint(GuidelimeDataChar.mainFrameRelative, UIParent, GuidelimeDataChar.mainFrameRelative, GuidelimeDataChar.mainFrameX, GuidelimeDataChar.mainFrameY)
		Guidelime_mainFrame:SetBackdrop({
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			tile = true, tileSize = 32, edgeSize = 0
		})
		Guidelime_mainFrame:SetFrameLevel(999)
		Guidelime_mainFrame:SetMovable(true)
		Guidelime_mainFrame:EnableMouse(true)
		Guidelime_mainFrame:SetScript("OnMouseDown", function(this, button) 
			if (button == "LeftButton") then Guidelime_mainFrame:StartMoving() end
		end)
		Guidelime_mainFrame:SetScript("OnMouseUp", function(this, button) 
			if (button == "LeftButton") then 
				Guidelime_mainFrame:StopMovingOrSizing() 
				local _
				_, _, GuidelimeDataChar.mainFrameRelative, GuidelimeDataChar.mainFrameX, GuidelimeDataChar.mainFrameY = Guidelime_mainFrame:GetPoint()
			elseif (button == "RightButton") then
				Guidelime_showOptions()
			end
		end)
		
		Guidelime_mainFrame.scrollFrame = CreateFrame("SCROLLFRAME", nil, Guidelime_mainFrame, "UIPanelScrollFrameTemplate")
		Guidelime_mainFrame.scrollFrame:SetAllPoints(Guidelime_mainFrame)
		
		Guidelime_mainFrame.scrollChild = CreateFrame("FRAME", nil, Guidelime_mainFrame)
		Guidelime_mainFrame.scrollFrame:SetScrollChild(Guidelime_mainFrame.scrollChild);
		--Guidelime_mainFrame.scrollChild:SetAllPoints(Guidelime_mainFrame)
		Guidelime_mainFrame.scrollChild:SetWidth(350)
		
		if Guidelime.firstLogUpdate then 
			Guidelime_updateMainFrame() 
		elseif Guidelime.currentGuide == nil then 
			loadGuide()
		end

		Guidelime_mainFrame.doneBtn = CreateFrame("BUTTON", nil, Guidelime_mainFrame, "UIPanelButtonTemplate")
		Guidelime_mainFrame.doneBtn:SetWidth(12)
		Guidelime_mainFrame.doneBtn:SetHeight(14)
		Guidelime_mainFrame.doneBtn:SetText( "X" )
		Guidelime_mainFrame.doneBtn:SetPoint("TOPRIGHT", Guidelime_mainFrame, "TOPRIGHT", -5, -5)
		Guidelime_mainFrame.doneBtn:SetScript("OnClick", function() 
			Guidelime_mainFrame:Hide() 
			HBDPins:RemoveAllWorldMapIcons(Guidelime)
			HBDPins:RemoveAllMinimapIcons(Guidelime)
			GuidelimeDataChar.mainFrameShowing = false
		end)
	
		if debugging then
			Guidelime_mainFrame.reloadBtn = CreateFrame("BUTTON", nil, Guidelime_mainFrame, "UIPanelButtonTemplate")
			Guidelime_mainFrame.reloadBtn:SetWidth(12)
			Guidelime_mainFrame.reloadBtn:SetHeight(14)
			Guidelime_mainFrame.reloadBtn:SetText( "R" )
			Guidelime_mainFrame.reloadBtn:SetPoint("TOPRIGHT", Guidelime_mainFrame, "TOPRIGHT", -25, -5)
			Guidelime_mainFrame.reloadBtn:SetScript("OnClick", function() 
				ReloadUI()
			end)
		end
	end
	Guidelime_mainFrame:Show()
	Guidelime_updateSteps()
	GuidelimeDataChar.mainFrameShowing = true
end

local function addCheckOption(optionsFrame, optionsTable, option, previous, text, tooltip, updateFunction)
	optionsFrame.options[option] = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
	optionsFrame.options[option]:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 8)
	optionsFrame.options[option].text:SetText(text)
	optionsFrame.options[option].text:SetFontObject("GameFontNormal")
	if tooltip ~= nil then
		optionsFrame.options[option]:SetScript("OnEnter", function(this) GameTooltip:SetOwner(this, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(tooltip); GameTooltip:Show() end)
		optionsFrame.options[option]:SetScript("OnLeave", function(this) GameTooltip:Hide() end)
	end
	if optionsTable[option] ~= false then optionsFrame.options[option]:SetChecked(true) end
	optionsFrame.options[option]:SetScript("OnClick", function()
		optionsTable[option] = optionsFrame.options[option]:GetChecked() 
		if updateFunction ~= nil then updateFunction() end
	end)
	return optionsFrame.options[option]
end

local function fillOptions(optionsFrame)
	optionsFrame.subtitle_options = optionsFrame:CreateFontString(nil, optionsFrame, "GameFontNormal")
	optionsFrame.subtitle_options:SetText(GAMEOPTIONS_MENU..":\n")
	optionsFrame.subtitle_options:SetPoint("TOPLEFT", 20, -30 )
	local prev = optionsFrame.subtitle_options

	optionsFrame.options = {}		
	prev = addCheckOption(optionsFrame, GuidelimeDataChar, "mainFrameShowing", prev, L.SHOW_MAINFRAME, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			showMainFrame()
		elseif Guidelime_mainFrame ~= nil then
			HBDPins:RemoveAllWorldMapIcons(Guidelime)
			HBDPins:RemoveAllMinimapIcons(Guidelime)
			Guidelime_mainFrame:Hide()
		end
	end)
	prev = addCheckOption(optionsFrame, GuidelimeDataChar, "hideCompletedSteps", prev, L.HIDE_COMPLETED_STEPS, nil, function()
		if GuidelimeDataChar.mainFrameShowing then
			Guidelime_updateMainFrame()
		end
	end)
end

function Guidelime_showOptions()
	
	if not dataLoaded then loadData() end
	
	if Guidelime_optionsFrame == nil then
		local initParent = UIParent
		Guidelime_optionsFrame = CreateFrame("FRAME", nil, initParent)
		Guidelime_optionsFrame:SetWidth(350)
		Guidelime_optionsFrame:SetHeight(400)
		Guidelime_optionsFrame:SetPoint("CENTER", UIParent, "CENTER")
		Guidelime_optionsFrame:SetBackdrop({
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11}
		})
		Guidelime_optionsFrame:SetFrameLevel(999)
		Guidelime_optionsFrame:SetMovable(true)
		Guidelime_optionsFrame:SetScript("OnKeyDown", function(this,key) 
			if key == "ESCAPE" then
				Guidelime_optionsFrame:SetPropagateKeyboardInput(false)
				Guidelime_optionsFrame:Hide()
			end 
		end)
		  
		Guidelime_optionsFrame.header = CreateFrame("FRAME", nil, Guidelime_optionsFrame)
		Guidelime_optionsFrame.header:SetSize(384, 64)
		Guidelime_optionsFrame.header:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Header"})
		Guidelime_optionsFrame.header:SetPoint("TOP", Guidelime_optionsFrame, "TOP", 0, 12)
		Guidelime_optionsFrame.header:EnableMouse(true)
		Guidelime_optionsFrame.header:SetScript("OnMouseDown", function(this) this:GetParent():StartMoving() end)
		Guidelime_optionsFrame.header:SetScript("OnMouseUp", function(this) this:GetParent():StopMovingOrSizing() end)
		Guidelime_optionsFrame.header.text = Guidelime_optionsFrame.header:CreateFontString(nil, Guidelime_optionsFrame.header, "GameFontNormal")
		Guidelime_optionsFrame.header.text:SetText( L.TITLE )
		Guidelime_optionsFrame.header.text:SetPoint("TOP", 0, -14)
		
		fillOptions(Guidelime_optionsFrame)

		Guidelime_optionsFrame.doneBtn = CreateFrame("BUTTON", nil, Guidelime_optionsFrame, "UIPanelButtonTemplate")
		Guidelime_optionsFrame.doneBtn:SetWidth(128)
		Guidelime_optionsFrame.doneBtn:SetHeight(24)
		Guidelime_optionsFrame.doneBtn:SetText( DONE )
		Guidelime_optionsFrame.doneBtn:SetPoint("BOTTOMRIGHT", Guidelime_optionsFrame, "BOTTOMRIGHT", -20, 20)
		Guidelime_optionsFrame.doneBtn:SetScript("OnClick", function() 
			Guidelime_optionsFrame:SetPropagateKeyboardInput(false)
			Guidelime_optionsFrame:Hide() 
		end)
	end
	Guidelime_optionsFrame:SetPropagateKeyboardInput(true)
	Guidelime_optionsFrame:Show()
end

-- Register events and call functions
Guidelime:SetScript("OnEvent", function(self, event, ...)
	Guidelime[event](self, ...)
end)

Guidelime:RegisterEvent('PLAYER_ENTERING_WORLD', Guidelime)
function Guidelime:PLAYER_ENTERING_WORLD()
	if debugging then print("LIME: Player entering world...") end
	if not dataLoaded then loadData() end
	local o = CreateFrame("FRAME")
	o.name = L.TITLE
	InterfaceOptions_AddCategory(o)
	fillOptions(o)
	if GuidelimeDataChar.mainFrameShowing then showMainFrame() end
end

Guidelime:RegisterEvent('PLAYER_LEVEL_UP', Guidelime)
function Guidelime:PLAYER_LEVEL_UP(level)
	if debugging then print("LIME: You reached level " .. level .. ". Grats!") end
	Guidelime.level = level
	Guidelime_updateSteps()
end

Guidelime:RegisterEvent('QUEST_LOG_UPDATE', Guidelime)
function Guidelime:QUEST_LOG_UPDATE()
	--if debugging then print("LIME: QUEST_LOG_UPDATE", Guidelime.firstLogUpdate) end
	Guidelime.xp = UnitXP("player")
	Guidelime.xpMax = UnitXPMax("player")
	Guidelime.y, Guidelime.x = UnitPosition("player")
	--if debugging then print("LIME: QUEST_LOG_UPDATE", UnitPosition("playe r")) end
	
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
			if q.logIndex == nil then
				if questLog[id] ~= nil then
					questFound = true
					questChanged = true
					q.logIndex = questLog[id].index
					q.finished = questLog[id].finished
					--if debugging then print("LIME: new log entry ".. id .. " finished", q.finished) end
				end
			else
				if questLog[id] == nil then
					checkCompleted = true
					q.logIndex = nil
					--if debugging then print("LIME: removed log entry ".. id) end
				else
					questFound = true
					if q.logIndex ~= questLog[id].index or q.finished ~= questLog[id].finished then
						questChanged = true
						q.logIndex = questLog[id].index
						q.finished = questLog[id].finished
						--if debugging then print("LIME: changed log entry ".. id .. " finished", q.finished) end
					end
				end
			end
		end

		if Guidelime.firstLogUpdate == nil then
			Guidelime_updateMainFrame()
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
						Guidelime_updateSteps()
					else
						-- quest was abandoned so redraw erverything since completed steps might have to be done again
						Guidelime_updateMainFrame()
					end
				end)
			elseif questChanged then 
				Guidelime_updateSteps() 
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
	elseif msg == 'debug true' and not debugging then debugging = true; print('LIME: Debugging enabled')
	elseif msg == 'debug false' and debugging then debugging = false; print('LIME: Debugging disabled') end
	GuidelimeData.debugging = debugging
end
