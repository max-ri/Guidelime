local addonName, addon = ...
local L = addon.L

local debugging

Guidelime = CreateFrame("Frame"), {}
Guidelime.faction = UnitFactionGroup("player")
Guidelime.class = UnitClass("player")
Guidelime.race = UnitRace("player")
Guidelime.level = UnitLevel("player")
Guidelime.guides = {}

local dataLoaded = false

local COLOR_INACTIVE = "|cFF666666"

local function loadData()
	local defaultOptions = {
		debugging = false,
		someOption = true,
		mainFrameX = 0,
		mainFrameY = 0,
		mainFrameRelative = "CENTER",
		mainFrameShowing = true,
	}
	if GuidelimeData == nil then
		GuidelimeData = {
			version = version,
			options = defaultOptions,
		}
	end
	if GuidelimeDataChar == nil then
		GuidelimeDataChar = {}
	end
	for option, default in pairs(defaultOptions) do
		if GuidelimeData.options[option] == nil then GuidelimeData.options[option] = default end
	end
	debugging = GuidelimeData.options.debugging

	if debugging then print("LIME: Initializing...") end

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
	
	local completed = GetQuestsCompleted()
	
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		if step.text ~= nil then
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
						else
							if debugging then print("LIME: quest ".. code) end
						end
						string.gsub(string.sub(code, 3), "(%d+)(.*)", function(id, title)
							element.questId = tonumber(id)
							element.title = title
						end)
						table.insert(step.elements, element)
					elseif string.sub(code, 1, 1) == "L" then
						local element = {}
						element.t = "LOC"
						string.gsub(code, "L(%d+),(%d+)", function(x, y)
							element.x = tonumber(x)
							element.y = tonumber(y)
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
		step.hasQuest = false
		for j, element in ipairs(step.elements) do
			if element.questId ~= nil then
				step.hasQuest = true
				if Guidelime.quests[element.questId] == nil then
					Guidelime.quests[element.questId] = {}
					Guidelime.quests[element.questId].title = element.title
					Guidelime.quests[element.questId].completed = completed[element.questId] ~= nil and completed[element.questId]
					Guidelime.quests[element.questId].finished = Guidelime.quests[element.questId].completed
				elseif debugging and element.title ~= nil and not element.title == "" and not Guidelime.quests[element.questId].title == element.title then
					print("LIME: quest id ".. element.questId .. " title " .. Guidelime.quests[element.questId].title .. " / " .. element.title)
				end
			end
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

local function fadeoutStep(i)
	step = Guidelime.currentGuide.steps[i]
	if step == nil then return end
	if not step.completed and not GuidelimeDataChar.currentGuide.skip[i] then
		step.fading = nil
		mainFrame.steps[i]:SetAlpha(1)
	end		
	if step.fading == nil then step.fading = 1 end
	if step.fading > 0 then
		step.fading = step.fading - 0.05
		mainFrame.steps[i]:SetAlpha(step.fading)
		C_Timer.After(0.1, function() 
			fadeoutStep(i)
		end)		
	else
		step.visible = false
		local found = false
		for j, step2 in ipairs(Guidelime.currentGuide.steps) do
			if step2.visible == true and step2.fading ~= nil and step2.fading > 0 then
				found = true
				break
			end
		end
		if not found then
			Guidelime_updateMainFrame()
		end
	end			
end

local function updateStepText(i)
	step = Guidelime.currentGuide.steps[i]
	if mainFrame.steps[i] == nil or mainFrame.steps[i].textBox == nil then return end
	local text = ""
	if not step.active then
		text = text .. COLOR_INACTIVE
	end
	if (step.elements == nil) then
		text = text .. "?"
	else
		for j, element in ipairs(step.elements) do
			if element.t=="TEXT" then
				text = text..element.text
			elseif Guidelime.quests[element.questId] ~= nil then
				text = text.."["..Guidelime.quests[element.questId].title.."]"
			elseif element.questId ~= nil then
				text = text.."["..element.questId.."]"
			elseif element.t=="LOC" then
				text = text.."("..element.x..","..element.y..")"
			end
		end
	end
	if step.active and step.hasQuest then
		for j, element in ipairs(step.elements) do
			if element.t == "COMPLETE" or element.t == "TURNIN" then
				if Guidelime.quests[element.questId].logIndex ~= nil then
					for k=1, GetNumQuestLeaderBoards() do
						local desc, typ, done = GetQuestLogLeaderBoard(k, Guidelime.quests[element.questId].logIndex)
						--if debugging then print("LIME: ", desc) end
						if not done and desc ~= nil and desc ~= "" then 
							text = text .. "\n    -" .. desc 
						end
					end
				end
			end
		end
	end
	mainFrame.steps[i].textBox:SetText(text)
end

local function updateStep(i)
	step = Guidelime.currentGuide.steps[i]
	step.completed = false
	step.active = step.levelRequired == nil or step.levelRequired <= Guidelime.level
	if step.active then
		for j, pstep in ipairs(Guidelime.currentGuide.steps) do
			if j == i then break end
			if (pstep.required == nil or pstep.required) and pstep.visible and (not pstep.completed) and (not GuidelimeDataChar.currentGuide.skip[j]) then
				step.active = false
				break 
			end
		end
	end
	if mainFrame.steps[i] ~= nil then 
		mainFrame.steps[i]:SetEnabled(step.active)
	end
	
	updateStepText(i)
	
	if (step.hasQuest == nil or not step.hasQuest) and step.level == nil then return end
	
	if step.level ~= nil and step.level > Guidelime.level then return end
	
	for j, element in ipairs(step.elements) do
		if element.t == "PICKUP" then
			if not Guidelime.quests[element.questId].completed and Guidelime.quests[element.questId].logIndex == nil then 
				return
			end
		elseif element.t == "COMPLETE" then
			if not Guidelime.quests[element.questId].completed and not Guidelime.quests[element.questId].finished then 
				return 
			end
		elseif element.t == "TURNIN" then
			if not Guidelime.quests[element.questId].completed then 
				return 
			end
		end
	end
	
	step.completed = true
	if mainFrame.steps[i] ~= nil then 
		mainFrame.steps[i]:SetChecked(true)
		fadeoutStep(i) 
	else 
		step.visible = false 
	end
end

local function updateSteps()
	if Guidelime.currentGuide == nil then return end
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		updateStep(i)
	end
end

local function updateStepTexts()
	if Guidelime.currentGuide == nil then return end
	for i, step in ipairs(Guidelime.currentGuide.steps) do
		updateStepText(i)
	end
end

function Guidelime_updateMainFrame()
	if mainFrame.steps ~= nil then
		for k, step in pairs(mainFrame.steps) do
			step:Hide()
		end
	end
	mainFrame.steps = {}
	
	if Guidelime.currentGuide == nil then 
		loadGuide()
	end
	updateSteps()
	
	local height = 0
	if Guidelime.currentGuide == nil then
		if debugging then print("LIME: No guide loaded") end
	else
		if debugging then print("LIME: Showing guide " .. Guidelime.currentGuide.name) end
		
		local prev = nil
		for i, step in ipairs(Guidelime.currentGuide.steps) do
			if step.visible then
				mainFrame.steps[i] = CreateFrame("CheckButton", nil, mainFrame.scrollChild, "UICheckButtonTemplate")
				if prev == nil then
					mainFrame.steps[i]:SetPoint("TOPLEFT", mainFrame.scrollChild, "TOPLEFT", 0, -14)
				else
					mainFrame.steps[i]:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", -35, -2)
				end
				mainFrame.steps[i]:SetEnabled(step.active)
				mainFrame.steps[i]:SetScript("OnClick", function() 
					GuidelimeDataChar.currentGuide.skip[i] = mainFrame.steps[i]:GetChecked()
					if mainFrame.steps[i]:GetChecked() then
						fadeoutStep(i)
					end
				end)
				
				mainFrame.steps[i].textBox=CreateFrame("EditBox", nil, mainFrame.steps[i])
				mainFrame.steps[i].textBox:SetPoint("TOPLEFT", mainFrame.steps[i], "TOPLEFT", 35, -10)
				mainFrame.steps[i].textBox:SetMultiLine(true)
				mainFrame.steps[i].textBox:EnableMouse(false)
				mainFrame.steps[i].textBox:SetAutoFocus(false)
				mainFrame.steps[i].textBox:SetFontObject("GameFontNormal")
				mainFrame.steps[i].textBox:SetWidth(mainFrame.scrollChild:GetWidth() - 35)
				updateStepText(i)
				
				local _, _, _, _, top = mainFrame.steps[i]:GetPoint()
				height = height + mainFrame.steps[i]:GetHeight() - top
				prev = mainFrame.steps[i].textBox
			end
		end
	end
	mainFrame.scrollChild:SetHeight(height)
	mainFrame.scrollFrame:UpdateScrollChildRect();
end

local function showMainFrame()
	
	if not dataLoaded then loadData() end
	
	if mainFrame == nil then
		local initParent = UIParent
		mainFrame = CreateFrame("FRAME", nil, initParent)
		mainFrame:SetWidth(350)
		mainFrame:SetHeight(400)
		mainFrame:SetPoint(GuidelimeData.options.mainFrameRelative, UIParent, GuidelimeData.options.mainFrameRelative, GuidelimeData.options.mainFrameX, GuidelimeData.options.mainFrameY)
		mainFrame:SetBackdrop({
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			tile = true, tileSize = 32, edgeSize = 0
		})
		mainFrame:SetFrameLevel(999)
		mainFrame:SetMovable(true)
		mainFrame:EnableMouse(true)
		mainFrame:SetScript("OnMouseDown", function(this, button) 
			if (button == "LeftButton") then mainFrame:StartMoving() end
		end)
		mainFrame:SetScript("OnMouseUp", function(this, button) 
			if (button == "LeftButton") then 
				mainFrame:StopMovingOrSizing() 
				local _
				_, _, GuidelimeData.options.mainFrameRelative, GuidelimeData.options.mainFrameX, GuidelimeData.options.mainFrameY = mainFrame:GetPoint()
			elseif (button == "RightButton") then
				Guidelime_showOptions()
			end
		end)
		
		mainFrame.scrollFrame = CreateFrame("SCROLLFRAME", nil, mainFrame, "UIPanelScrollFrameTemplate")
		mainFrame.scrollFrame:SetAllPoints(mainFrame)
		
		mainFrame.scrollChild = CreateFrame("FRAME", nil, mainFrame)
		mainFrame.scrollFrame:SetScrollChild(mainFrame.scrollChild);
		--mainFrame.scrollChild:SetAllPoints(mainFrame)
		mainFrame.scrollChild:SetWidth(350)
		
		Guidelime_updateMainFrame()

		mainFrame.doneBtn = CreateFrame("BUTTON", nil, mainFrame, "UIPanelButtonTemplate")
		mainFrame.doneBtn:SetWidth(12)
		mainFrame.doneBtn:SetHeight(14)
		mainFrame.doneBtn:SetText( "X" )
		mainFrame.doneBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -5, -5)
		mainFrame.doneBtn:SetScript("OnClick", function() 
			mainFrame:Hide() 
			GuidelimeData.options.mainFrameShowing = false
		end)
	
		if debugging then
			mainFrame.reloadBtn = CreateFrame("BUTTON", nil, mainFrame, "UIPanelButtonTemplate")
			mainFrame.reloadBtn:SetWidth(12)
			mainFrame.reloadBtn:SetHeight(14)
			mainFrame.reloadBtn:SetText( "R" )
			mainFrame.reloadBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -25, -5)
			mainFrame.reloadBtn:SetScript("OnClick", function() 
				ReloadUI()
			end)
		end
	end
	mainFrame:Show()
	GuidelimeData.options.mainFrameShowing = true
end

local function addOption(optionsFrame, option, previous, text, tooltip)
	optionsFrame.options[option] = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
	optionsFrame.options[option]:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 8)
	optionsFrame.options[option].text:SetText(text)
	optionsFrame.options[option].text:SetFontObject("GameFontNormal")
	if tooltip ~= nil then
		optionsFrame.options[option]:SetScript("OnEnter", function(this) GameTooltip:SetOwner(this, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(tooltip); GameTooltip:Show() end)
		optionsFrame.options[option]:SetScript("OnLeave", function(this) GameTooltip:Hide() end)
	end
	if GuidelimeData.options[option] ~= false then optionsFrame.options[option]:SetChecked(true) end
	optionsFrame.options[option]:SetScript("OnClick", function() GuidelimeData.options[option] = optionsFrame.options[option]:GetChecked() end)
	return optionsFrame.options[option]
end

local function fillOptions(optionsFrame)
	optionsFrame.subtitle_options = optionsFrame:CreateFontString(nil, optionsFrame, "GameFontNormal")
	optionsFrame.subtitle_options:SetText(GAMEOPTIONS_MENU..":\n")
	optionsFrame.subtitle_options:SetPoint("TOPLEFT", 20, -30 )
	local prev = optionsFrame.subtitle_options

	optionsFrame.options = {}		
	prev = addOption(optionsFrame, "someOption", prev, L.SOME_OPTION)
end

function Guidelime_showOptions()
	
	if not dataLoaded then loadData() end
	
	if optionsFrame == nil then
		local initParent = UIParent
		optionsFrame = CreateFrame("FRAME", nil, initParent)
		optionsFrame:SetWidth(350)
		optionsFrame:SetHeight(400)
		optionsFrame:SetPoint("CENTER", UIParent, "CENTER")
		optionsFrame:SetBackdrop({
			bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
			edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
			tile = true, tileSize = 32, edgeSize = 32,
			insets = { left = 11, right = 12, top = 12, bottom = 11}
		})
		optionsFrame:SetFrameLevel(999)
		optionsFrame:SetMovable(true)
		optionsFrame:SetScript("OnKeyDown", function(this,key) 
			if key == "ESCAPE" then
				optionsFrame:SetPropagateKeyboardInput(false)
				optionsFrame:Hide()
			end 
		end)
		  
		optionsFrame.header = CreateFrame("FRAME", nil, optionsFrame)
		optionsFrame.header:SetSize(384, 64)
		optionsFrame.header:SetBackdrop({ bgFile = "Interface/DialogFrame/UI-DialogBox-Header"})
		optionsFrame.header:SetPoint("TOP", optionsFrame, "TOP", 0, 12)
		optionsFrame.header:EnableMouse(true)
		optionsFrame.header:SetScript("OnMouseDown", function(this) this:GetParent():StartMoving() end)
		optionsFrame.header:SetScript("OnMouseUp", function(this) this:GetParent():StopMovingOrSizing() end)
		optionsFrame.header.text = optionsFrame.header:CreateFontString(nil, optionsFrame.header, "GameFontNormal")
		optionsFrame.header.text:SetText( L.TITLE )
		optionsFrame.header.text:SetPoint("TOP", 0, -14)
		
		fillOptions(optionsFrame)

		optionsFrame.doneBtn = CreateFrame("BUTTON", nil, optionsFrame, "UIPanelButtonTemplate")
		optionsFrame.doneBtn:SetWidth(128)
		optionsFrame.doneBtn:SetHeight(24)
		optionsFrame.doneBtn:SetText( DONE )
		optionsFrame.doneBtn:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT", -20, 20)
		optionsFrame.doneBtn:SetScript("OnClick", function() 
			optionsFrame:SetPropagateKeyboardInput(false)
			optionsFrame:Hide() 
		end)
	end
	optionsFrame:SetPropagateKeyboardInput(true)
	optionsFrame:Show()
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
	if GuidelimeData.options.mainFrameShowing then showMainFrame() end
end

Guidelime:RegisterEvent('PLAYER_LEVEL_UP', Guidelime)
function Guidelime:PLAYER_LEVEL_UP(level)
	if debugging then print("LIME: You reached level " .. level .. ". Grats!") end
	Guidelime.level = level
	updateSteps()
end

Guidelime:RegisterEvent('QUEST_LOG_UPDATE', Guidelime)
function Guidelime:QUEST_LOG_UPDATE()
	--if debugging then print("LIME: QUEST_LOG_UPDATE") end
	if Guidelime.quests == nil then return end
	
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

SLASH_Guidelime1 = "/lime"
function SlashCmdList.Guidelime(msg)
	if msg == '' then showMainFrame() 
	elseif msg == 'debug true' and not debugging then debugging = true; print('LIME: Debugging enabled')
	elseif msg == 'debug false' and debugging then debugging = false; print('LIME: Debugging disabled') end
	GuidelimeData.options.debugging = debugging
end
