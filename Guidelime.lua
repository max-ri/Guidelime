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
Guidelime.y, Guidelime.x, Guidelime.zone = UnitPosition("player")
Guidelime.guides = {}
Guidelime.mapIcons = {}

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

local function loadGuide(guide)

	if GuidelimeDataChar.currentGuide == nil then GuidelimeDataChar.currentGuide = {} end
	if GuidelimeDataChar.currentGuide.name == nil then 
		GuidelimeDataChar.currentGuide.name = "Demo" 
		GuidelimeDataChar.currentGuide.skip = {}
	end
	
	Guidelime.currentGuide = Guidelime.guides[GuidelimeDataChar.currentGuide.name] 
	Guidelime.quests = {}
	
	--print(format(L.LOAD_MESSAGE, Guidelime.currentGuide.name))
	
	local completed = GetQuestsCompleted()
	
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		if step.text ~= nil then
			if step.zone == nil then step.zone = Guidelime.currentGuide.zone end
			step.elements = {}
			local t = step.text
			local found
			repeat
				found = false
				t = string.gsub(t, "(.-)%[(.-)%]", function(text, code)
					if text ~= nil then
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
							if debugging then print("LIME: quest ".. code) end
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
						string.gsub(code, "L(%d+), *(%d+)", function(x, y)
							element.x = tonumber(x)
							element.y = tonumber(y)
							element.mapID = mapIDs[step.zone]
						end)
						table.insert(step.elements, element)
					elseif string.sub(code, 1, 1) == "G" then
						local element = {}
						element.t = "GOTO"
						string.gsub(code, "G(%d+), *(%d+)", function(x, y)
							element.x = tonumber(x)
							element.y = tonumber(y)
							element.mapID = mapIDs[step.zone]
						end)
						table.insert(step.elements, element)
					else
						if debugging then print("LIME: code ".. code) end
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
		
		step.canComplete = step.level ~= nil or step.xp ~= nil
		step.trackQuest = {}
		for j, element in ipairs(step.elements) do
			if element.questId ~= nil then
				if element.t ~= "SKIP" then step.canComplete = true end
				if Guidelime.quests[element.questId] == nil then
					Guidelime.quests[element.questId] = {}
					Guidelime.quests[element.questId].title = element.title
					Guidelime.quests[element.questId].completed = completed[element.questId] ~= nil and completed[element.questId]
					Guidelime.quests[element.questId].finished = Guidelime.quests[element.questId].completed
				elseif debugging and element.title ~= nil and element.title ~= "" and Guidelime.quests[element.questId].title ~= element.title then
					print("LIME: quest id ".. element.questId .. " title " .. Guidelime.quests[element.questId].title .. " / " .. element.title)
				end
				if element.t == "COMPLETE" or element.t == "TURNIN" then
					step.trackQuest[element.questId] = true
				end
			end
			if element.t == "GOTO" then step.canComplete = true end
		end
		step.visible = GuidelimeDataChar.currentGuide.skip[i] == nil or not GuidelimeDataChar.currentGuide.skip[i]
		if step.visible then
			if step.race ~= nil then
				local found = false
				for i, race in ipairs(step.race) do
					if race == Guidelime.race then found = true; break end
				end
				if not found then step.visible = false end
			end
			if step.class ~= nil then
				local found = false
				for i, class in ipairs(step.class) do
					if class == Guidelime.class then found = true; break end
				end
				if not found then step.visible = false end
			end
		end
	end
end

local function fadeoutStep(indexes)
	local keepFading = {}
	local update = false
	for _, i in ipairs(indexes) do
		step = Guidelime.currentGuide.steps[i]
		if step == nil then return end
		if not step.completed and not GuidelimeDataChar.currentGuide.skip[i] then
			step.fading = nil
			Guidelime_mainFrame.steps[i]:SetAlpha(1)
		end		
		if step.fading == nil then step.fading = 1 end
		if step.fading > 0 then
			step.fading = step.fading - 0.05
			Guidelime_mainFrame.steps[i]:SetAlpha(step.fading)
			table.insert(keepFading, i)
		else
			step.visible = false
			local found = false
			for j, step2 in ipairs(Guidelime.currentGuide.steps) do
				if step2.visible == true and step2.fading ~= nil and step2.fading > 0 then
					found = true
					break
				end
			end
			if not found then update = true end
		end			
	end
	if update then Guidelime_updateMainFrame() end
	if #keepFading > 0 then
		C_Timer.After(0.1, function() 
			fadeoutStep(keepFading)
		end)
	end
end

local function updateStepText(i)
	step = Guidelime.currentGuide.steps[i]
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
				if element.t=="TEXT" then
					text = text .. element.text
				elseif Guidelime.quests[element.questId] ~= nil then
					if step.active  and Guidelime.currentGuide.colorQuest ~= nil then
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
	if step.active and step.canComplete then
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
	else
		element.mapIndex = nil
	end
end

local function isStepCompleted(step)
	if (step.canComplete == nil or not step.canComplete) then return false end
	
	if step.level ~= nil and step.level > Guidelime.level then return false end
	
	if step.xp ~= nil and step.level == Guidelime.level then
		if step.xpType == "REMAINING" then
			if step.xp < (Guidelime.xpMax - Guidelime.xp) then return false end
		elseif step.xpType == "PERCENTAGE" then
			if step.xp > (Guidelime.xp / Guidelime.xpMax) then return false end
		else
			if step.xp > Guidelime.xp then return false end
		end
	end
	
	for j, element in ipairs(step.elements) do
		if element.t == "PICKUP" then
			if not Guidelime.quests[element.questId].completed and Guidelime.quests[element.questId].logIndex == nil then 
				return false
			end
		elseif element.t == "COMPLETE" then
			if not Guidelime.quests[element.questId].completed and not Guidelime.quests[element.questId].finished then 
				return false
			end
		elseif element.t == "TURNIN" then
			if debugging and Guidelime.quests[element.questId] == nil then print("LIME : quest nil in ", step.text) end
			if not Guidelime.quests[element.questId].completed then 
				return false
			end
		elseif element.t == "GOTO" then
			if not step.active then return false end
			if element.zone ~= Guidelime.zone then return false end
			if Guidelime.x > element.x + 1 or Guidelime.x < element.x - 1 then return false end
			if Guidelime.y > element.y + 1 or Guidelime.y < element.y - 1 then return false end
		end
	end
	
	return true
end

local function updateStep(i)
	step = Guidelime.currentGuide.steps[i]
	step.completed = false
	step.active = step.levelRequired == nil or step.levelRequired <= Guidelime.level
	if step.active then
		for j, pstep in ipairs(Guidelime.currentGuide.steps) do
			if j == i then break end
			if (pstep.required == nil or pstep.required) and pstep.visible and not pstep.completed and not GuidelimeDataChar.currentGuide.skip[j] then
				step.active = false
				break 
			end
		end
	end
	if Guidelime_mainFrame.steps ~= nil and Guidelime_mainFrame.steps[i] ~= nil then 
		Guidelime_mainFrame.steps[i]:SetEnabled(step.active)
	end

	local completed = isStepCompleted(step)
	
	if step.visible and not completed then
		for j, element in ipairs(step.elements) do
			if element.t == "LOC" or element.t == "GOTO" then
				mapIcon = addMapIcon(element)
			end
		end
	end
	
	updateStepText(i)
	
	if not completed then return false end
	
	step.completed = true
	if Guidelime_mainFrame.steps ~= nil and Guidelime_mainFrame.steps[i] ~= nil then 
		Guidelime_mainFrame.steps[i]:SetChecked(true)
		return true
	else 
		step.visible = false 
		return false
	end
end

local function updateSteps()
	if Guidelime.currentGuide == nil then return end
	HBDPins:RemoveAllWorldMapIcons(Guidelime)
	HBDPins:RemoveAllMinimapIcons(Guidelime)
	for i, mapIcon in ipairs(Guidelime.mapIcons) do
		mapIcon.inUse = false
	end
	local fadeIndexes = {}
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		if updateStep(i) then table.insert(fadeIndexes, i) end
	end
	if #fadeIndexes > 0 then fadeoutStep(fadeIndexes) end
	for i = #Guidelime.mapIcons, 1, -1 do
		local mapIcon = Guidelime.mapIcons[i]
		if mapIcon.inUse then
			HBDPins:AddWorldMapIconMap(Guidelime, mapIcon, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, 3)
			HBDPins:AddMinimapIconMap(Guidelime, mapIcon.minimap, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, true, true)
		end
	end
end

local function updateStepTexts()
	if Guidelime.currentGuide == nil then return end
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		updateStepText(i)
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
	updateSteps()
	
	if Guidelime.currentGuide == nil then
		if debugging then print("LIME: No guide loaded") end
	else
		--if debugging then print("LIME: Showing guide " .. Guidelime.currentGuide.name) end
		
		local prev = nil
		for i, step in ipairs(Guidelime.currentGuide.steps) do
			if step.visible then
				Guidelime_mainFrame.steps[i] = CreateFrame("CheckButton", nil, Guidelime_mainFrame.scrollChild, "UICheckButtonTemplate")
				if prev == nil then
					Guidelime_mainFrame.steps[i]:SetPoint("TOPLEFT", Guidelime_mainFrame.scrollChild, "TOPLEFT", 0, -14)
				else
					Guidelime_mainFrame.steps[i]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -35, -2)
				end
				Guidelime_mainFrame.steps[i]:SetEnabled(step.active)
				Guidelime_mainFrame.steps[i]:SetScript("OnClick", function() 
					GuidelimeDataChar.currentGuide.skip[i] = Guidelime_mainFrame.steps[i]:GetChecked()
					if Guidelime_mainFrame.steps[i]:GetChecked() then
						fadeoutStep({i})
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
			Guidelime_mainFrame:Hide()
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
	updateSteps()
end

Guidelime:RegisterEvent('QUEST_LOG_UPDATE', Guidelime)
function Guidelime:QUEST_LOG_UPDATE()
	--if debugging then print("LIME: QUEST_LOG_UPDATE", Guidelime.firstLogUpdate) end
	Guidelime.xp = UnitXP("player")
	Guidelime.xpMax = UnitXPMax("player")
	Guidelime.y, Guidelime.x, _, Guidelime.zone = UnitPosition("player")
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
					if step.visible and step.active and step.xp ~= nil then
						questChanged = true
					end
				end
			end
			
			if checkCompleted then
				if questFound then
					updateStepTexts()
				end
				C_Timer.After(1, function(questChanged) 
					local completed = GetQuestsCompleted()
					for id, q in pairs(Guidelime.quests) do
						if completed[id] and not q.completed then
							questChanged = true
							q.finished = true
							q.completed = true
						end
					end
					if questChanged then updateSteps() end
				end)
			elseif questChanged then 
				updateSteps() 
			elseif questFound then
				updateStepTexts()
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
