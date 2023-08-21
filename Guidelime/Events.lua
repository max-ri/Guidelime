local addonName, addon = ...
local L = addon.L

local HBD = LibStub("HereBeDragons-2.0")

addon.D = addon.D or {}; local D = addon.D     -- Data/Data
addon.FM = addon.FM or {}; local FM = addon.FM -- Data/FlightmasterDB
addon.QT = addon.QT or {}; local QT = addon.QT -- Data/QuestTools
addon.SK = addon.SK or {}; local SK = addon.SK -- Data/SkillDB
addon.SP = addon.SP or {}; local SP = addon.SP -- Data/SpellDB
addon.AB = addon.AB or {}; local AB = addon.AB -- ActionButtons
addon.CG = addon.CG or {}; local CG = addon.CG -- CurrentGuide
addon.M = addon.M or {}; local M = addon.M     -- Map
addon.MW = addon.MW or {}; local MW = addon.MW -- MainWindow
addon.QS = addon.QS or {}; local QS = addon.QS -- QuestScan

addon.EV = addon.EV or {}; local EV = addon.EV -- Events

EV.AUTO_COMPLETE_DELAY = 0.01
EV.BAG_UPDATE_DELAY = 0.3

EV.frame = CreateFrame("Frame", addonName .. "Frame", UIParent)

-- Register events and call functions
EV.frame:SetScript("OnEvent", function(self, event, ...)
	--if addon.debugging then print("LIME:", event, ...) end
	EV.frame[event](self, ...)
end)

EV.frame:RegisterEvent('PLAYER_LOGIN')
function EV.frame:PLAYER_LOGIN()
	addon.init()
	C_Timer.After(2, function()
		if not addon.dataLoaded then addon.loadData() end
		if GuidelimeDataChar.mainFrameShowing then MW.showMainFrame() end
	end)
end

EV.frame:RegisterEvent('PLAYER_LEVEL_UP')
function EV.frame:PLAYER_LEVEL_UP(level)
	C_Timer.After(0.1, function()
		D.level = level
		D.xpMax = UnitXPMax("player")
		if addon.debugging then print("LIME: You reached level " .. D.level .. ". Grats! new xp max is " .. D.xpMax) end
		CG.updateSteps()
	end)
end

EV.frame:RegisterEvent('PLAYER_XP_UPDATE')
function EV.frame:PLAYER_XP_UPDATE(level)
	D.xp = UnitXP("player")
	--if addon.debugging then print("LIME: xp is " .. D.xp) end
	CG.updateSteps()
end

EV.frame:RegisterEvent('UPDATE_FACTION')
function EV.frame:UPDATE_FACTION(level)
	MW.updateMainFrame()
end

function EV.updateFromQuestLog()
	local questLog = {}
	local isCollapsed = {}
	local currentHeader
	if C_QuestLog.GetInfo ~= nil then
		local i = 1
		while (true) do	
			local info = C_QuestLog.GetInfo(i)
			if not info then break end
			if info.isHeader then
				isCollapsed[info.title] = info.isCollapsed
				currentHeader = info.title
			else
				questLog[info.questID] = {}
				questLog[info.questID].index = i
				--local completed = true
				--local objectives = C_QuestLog.GetQuestObjectives(info.questID)
				--for i, o in ipairs(objectives) do if not o.finished then completed = false end end
				questLog[info.questID].finished = C_QuestLog.IsComplete(info.questID)
				questLog[info.questID].failed = C_QuestLog.IsFailed(info.questID)
				questLog[info.questID].name = info.title
				questLog[info.questID].sort = currentHeader
			end
			i = i + 1
		end
	else
		for i = 1, GetNumQuestLogEntries() do
			local name, _, _, header, collapsed, completed, _, id = GetQuestLogTitle(i)
			if header then
				isCollapsed[name] = collapsed
				currentHeader = name
			else
				questLog[id] = {}
				questLog[id].index = i
				questLog[id].finished = (completed == 1)
				questLog[id].failed = (completed == -1)
				questLog[id].name = name
				questLog[id].sort = currentHeader	
			end
		end
	end
	
	local checkCompleted = false
	local questChanged = false
	local questFound = false
	local questItemsNeeded = {}
	for _, id in ipairs(CG.questIds) do
		local q = CG.quests[id]
		if questLog[id] ~= nil and not questLog[id].failed then
			local numObjectives = GetNumQuestLeaderBoards(questLog[id].index)
			if numObjectives == 0 then questLog[id].finished = true end
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
				q.sort = questLog[id].sort
				--if addon.debugging then print("LIME: new log entry ".. id .. " finished", q.finished) end
			end
			if q.objectives == nil or #q.objectives ~= numObjectives then q.objectives = {} end
			for k = 1, numObjectives do
				local desc, type, done = GetQuestLogLeaderBoard(k, CG.quests[id].logIndex)
				-- special treatment for item objectives: when the same item needs to be collected for different quests at the same time 
				-- all objectives should be done only when enough items for all quests have been collected
				if type == 'item' then
					local objectives = QT.getQuestObjectives(id)
					if objectives ~= nil and objectives[k] ~= nil and objectives[k].type == 'item' then
						local itemId = objectives[k].ids.item[1]
						local itemName, _, numNeeded = desc:match("([^%d]*)([%d]+)%s*/%s*([%d]+)")
						if numNeeded ~= nil then
							if questItemsNeeded[itemId] ~= nil then 
								local itemCount = GetItemCount(itemId) - questItemsNeeded[itemId]
								numNeeded = tonumber(numNeeded)
								if addon.debugging then print("LIME: item " .. itemId .. " " .. itemName .. " " .. itemCount .. "/" .. numNeeded) end
								if itemCount < numNeeded then
									done = false
									q.finished = false
									desc = itemName .. (itemCount >= 0 and itemCount or 0) .. "/" .. numNeeded
								end
							end
							questItemsNeeded[itemId] = (questItemsNeeded[itemId] or 0) + numNeeded
						else
							if addon.debugging then print("LIME: error parsing item objective text - " .. desc) end
						end
					end
				end
				if q.objectives[k] == nil or desc ~= q.objectives[k] or done ~= q.objectives[k].done then
					questChanged = true
					q.objectives[k] = {desc = desc, done = done, type = type}
				end					
			end
		elseif not q.completed then
			checkCompleted = true
			if q.logIndex ~= nil and q.logIndex ~= -1 and not isCollapsed[q.sort] then
				q.logIndex = nil
				--if addon.debugging then print("LIME: removed log entry ".. id) end
			end
		end
	end
	return checkCompleted, questChanged, questFound
end

local function doQuestUpdate()
	D.xp = UnitXP("player")
	D.xpMax = UnitXPMax("player")
	D.wx, D.wy, D.instance = HBD:GetPlayerWorldPosition()
	
	if CG.quests ~= nil then 
		local checkCompleted, questChanged, questFound = EV.updateFromQuestLog()

		if EV.firstLogUpdate == nil then
			MW.updateMainFrame()
		else
			if not questChanged then
				if D.contains(CG.currentGuide.steps, function(s) return not s.skip and not s.completed and s.active and s.xp ~= nil end) then 
					questChanged = true 
				end
			end
			
			if checkCompleted then
				if questFound then
					CG.updateStepsText()
				end
				C_Timer.After(0.1, function() 
					local completed = QT.GetQuestsCompleted()
					local questCompleted = false
					for id, q in pairs(CG.quests) do
						if completed[id] and not q.completed then
							questCompleted = true
							q.finished = true
							q.completed = true
						end
					end
					if questCompleted == true or GuidelimeDataChar.showCompletedSteps then
						CG.updateSteps()
					else
						-- quest was abandoned so redraw erverything since completed steps might have to be done again
						MW.updateMainFrame()
					end
				end)
			elseif questChanged then 
				CG.updateSteps() 
			elseif questFound then
				CG.updateStepsText()
			end
		end
	end
	EV.firstLogUpdate = true
end

EV.frame:RegisterEvent('QUEST_LOG_UPDATE')
function EV.frame:QUEST_LOG_UPDATE()
	doQuestUpdate()
end

function EV.isQuestAuto(option, id)
	if option == "All" then 
		return true 
	elseif CG.currentGuide == nil then
		return false
	elseif option == "Current" then 
		return CG.currentGuide.activeQuests ~= nil and D.contains(CG.currentGuide.activeQuests, id)
	elseif option == "Guide" then
		return QS.scannedQuests ~= nil and D.containsKey(QS.scannedQuests, id)
	else
		return false
	end
end


EV.frame:RegisterEvent('GOSSIP_SHOW')
function EV.frame:GOSSIP_SHOW()
	if IsShiftKeyDown() then return end
	if GetGossipActiveQuests ~= nil then
		EV.frame.GOSSIP_SHOW_old(self)
		return
	end
	if (GuidelimeData.autoAcceptQuests or GuidelimeData.autoTurnInQuests) then 
		if addon.debugging then print ("LIME: GOSSIP_SHOW", C_GossipInfo.GetActiveQuests()) end
		if addon.debugging then print ("LIME: GOSSIP_SHOW", C_GossipInfo.GetAvailableQuests()) end
		local selectActive = nil
		local selectAvailable = nil
		EV.openNpcAgain = false
		for _, q in ipairs(C_GossipInfo.GetActiveQuests()) do
			if q.isComplete and EV.isQuestAuto(GuidelimeData.autoTurnInQuests, q.questID) then
				if selectActive == nil then
					selectActive = q.questID
				else
					EV.openNpcAgain = true
				end			
			end
		end
		for _, q in ipairs(C_GossipInfo.GetAvailableQuests()) do
			if EV.isQuestAuto(GuidelimeData.autoAcceptQuests, q.questID) then
				if selectActive == nil and selectAvailable == nil then
					selectAvailable = q.questID
				else
					EV.openNpcAgain = true
				end			
			end
		end

		if selectActive ~= nil then
			C_Timer.After(EV.AUTO_COMPLETE_DELAY, function() 
				if addon.debugging then print ("LIME: GOSSIP_SHOW selectActive", selectActive) end
				C_GossipInfo.SelectActiveQuest(selectActive)
			end)
		elseif selectAvailable ~= nil then
			C_Timer.After(EV.AUTO_COMPLETE_DELAY, function() 
				if addon.debugging then print ("LIME: GOSSIP_SHOW selectAvailable", selectAvailable) end
				C_GossipInfo.SelectAvailableQuest(selectAvailable)
			end)
		end
	end
	for _, gossip in ipairs(C_GossipInfo.GetOptions()) do
		if gossip.icon == 132057 then
			if GuidelimeData.autoSelectFlight then
				CG.forEveryActiveElement(function (element)
					if element.t == "FLY" or element.t == "GET_FLIGHT_POINT" then
						if addon.debugging then print ("LIME: GOSSIP_SHOW SelectGossipOption", gossip.gossipOptionID) end
						C_GossipInfo.SelectOption(gossip.gossipOptionID)
						return
					end
				end)
			end
		elseif gossip.icon == 132058 then
			if GuidelimeData.autoTrain then
				CG.forEveryActiveElement(function (element)
					if element.t == "LEARN" and (element.maxSkillMin or element.spell) then
						if addon.debugging then print ("LIME: GOSSIP_SHOW SelectGossipOption", gossip.gossipOptionID) end
						C_GossipInfo.SelectOption(gossip.gossipOptionID)
						SetTrainerServiceTypeFilter("available", 1)
						return
					end
				end)
			end
		end
	end
end

function EV.frame:GOSSIP_SHOW_old()
	if (GuidelimeData.autoAcceptQuests or GuidelimeData.autoTurnInQuests) then 
		if addon.debugging then print ("LIME: GOSSIP_SHOW", GetGossipActiveQuests()) end
		if addon.debugging then print ("LIME: GOSSIP_SHOW", GetGossipAvailableQuests()) end
		local q = { GetGossipActiveQuests() }
		local selectActive = nil
		local selectAvailable = nil
		EV.openNpcAgain = false
		for i = 1, GetNumGossipActiveQuests() do
			local name = q[(i-1) * 6 + 1]
			local complete = q[(i-1) * 6 + 4]
			if complete and EV.isQuestAuto(GuidelimeData.autoTurnInQuests, function(id) return name == QT.getQuestNameById(id) end) then
				if selectActive == nil then
					selectActive = i
				else
					EV.openNpcAgain = true
				end			
			end
		end
		q = { GetGossipAvailableQuests() }
		for i = 1, GetNumGossipAvailableQuests() do
			local name = q[(i-1) * 7 + 1]
			if EV.isQuestAuto(GuidelimeData.autoAcceptQuests, function(id) return name == QT.getQuestNameById(id) end) then
				if selectActive == nil and selectAvailable == nil then
					selectAvailable = i
				else
					EV.openNpcAgain = true
				end			
			end
		end

		if selectActive ~= nil then
			C_Timer.After(EV.AUTO_COMPLETE_DELAY, function() 
				if addon.debugging then print ("LIME: GOSSIP_SHOW selectActive", selectActive) end
				SelectGossipActiveQuest(selectActive)
			end)
		elseif selectAvailable ~= nil then
			C_Timer.After(EV.AUTO_COMPLETE_DELAY, function() 
				if addon.debugging then print ("LIME: GOSSIP_SHOW selectAvailable", selectAvailable) end
				SelectGossipAvailableQuest(selectAvailable)
			end)
		end
	end
	local gossip = {GetGossipOptions()}
	for i = 1, GetNumGossipOptions() do
		if gossip[i * 2] == "taxi" then
			if GuidelimeData.autoSelectFlight then
				CG.forEveryActiveElement(function (element)
					if element.t == "FLY" or element.t == "GET_FLIGHT_POINT" then
						if addon.debugging then print ("LIME: GOSSIP_SHOW SelectGossipOption", i) end
						SelectGossipOption(i)
						return
					end
				end)
			end
		elseif gossip[i * 2] == "trainer" then
			if GuidelimeData.autoTrain then
				CG.forEveryActiveElement(function (element)
					if element.t == "LEARN" and (element.maxSkillMin or element.spell) then
						if addon.debugging then print ("LIME: GOSSIP_SHOW SelectGossipOption", i) end
						SelectGossipOption(i)
						SetTrainerServiceTypeFilter("available", 1)
						return
					end
				end)
			end
		end
	end
end

local function doAutoTrain()
	if IsShiftKeyDown() or not GuidelimeData.autoTrain then return end
	if addon.debugging then print ("LIME: doAutoTrain GetNumTrainerServices", GetNumTrainerServices()) end
	for i = 1, GetNumTrainerServices() do
		local name, _, category = GetTrainerServiceInfo(i)
		if name == nil then break end
		if category == "available" then
			CG.forEveryActiveElement(function (element)
				if element.t == "LEARN" and element.skill and SK.getSkillLearnedBy(element.skill) and (element.maxSkillMin or element.skill == "RIDING") then
					for _, id in ipairs(SK.getSkillLearnedBy(element.skill)) do
						if name == (GetSpellInfo(id)) then
							C_Timer.After(EV.AUTO_COMPLETE_DELAY, function() 
								if addon.debugging then print ("LIME: doAutoTrain BuyTrainerService", i) end
								BuyTrainerService(i)
								CG.updateSteps({element.step.index})
							end)
							return
						end
					end
				elseif element.t == "LEARN" and element.spell then
					if name == (GetSpellInfo(SP.getSpellId(element.spell))) then
						C_Timer.After(EV.AUTO_COMPLETE_DELAY, function() 
							if addon.debugging then print ("LIME: doAutoTrain BuyTrainerService", i) end
							BuyTrainerService(i)
							CG.updateSteps({element.step.index})
						end)
						return
					end
				end
			end)
		end
	end
end

EV.frame:RegisterEvent('TRAINER_UPDATE')
function EV.frame:TRAINER_UPDATE()
	if addon.debugging then print ("LIME: TRAINER_UPDATE") end
	local steps = {}
	CG.forEveryActiveElement(function(element)
		if element.t == "LEARN" then
			table.insert(steps, element.step.index)
		end
	end)
	if #steps > 0 then CG.updateSteps(steps) end
	doAutoTrain()
end

EV.frame:RegisterEvent('TRAINER_SHOW')
function EV.frame:TRAINER_SHOW()
	if addon.debugging then print ("LIME: TRAINER_SHOW") end
	doAutoTrain()
end

EV.frame:RegisterEvent('TRADE_SKILL_SHOW')
function EV.frame:TRADE_SKILL_SHOW()
	if addon.debugging then print ("LIME: TRADE_SKILL_SHOW") end
	local steps = {}
	CG.forEveryActiveElement(function(element)
		if element.t == "LEARN" or element.t == "SPELL" then
			table.insert(steps, element.step.index)
		end
	end)
	if #steps > 0 then 
		CG.updateSteps(steps) 
		AB.updateUseItemButtons()
	end
end

EV.frame:RegisterEvent('QUEST_GREETING')
function EV.frame:QUEST_GREETING()
	if (GuidelimeData.autoAcceptQuests or GuidelimeData.autoTurnInQuests) and not IsShiftKeyDown() then 
		if addon.debugging then print ("LIME: QUEST_GREETING", GetNumActiveQuests()) end
		if addon.debugging then print ("LIME: QUEST_GREETING", GetNumAvailableQuests()) end
		local selectActive = nil
		local selectAvailable = nil
		EV.openNpcAgain = false
		for i = 1, GetNumActiveQuests() do
			local name = GetActiveTitle(i)
			if EV.isQuestAuto(GuidelimeData.autoTurnInQuests, function(id) return name == QT.getQuestNameById(id) end) then
				if selectActive == nil then
					selectActive = i
				else
					EV.openNpcAgain = true
				end			
			end
		end
		for i = 1, GetNumAvailableQuests() do
			local name = GetAvailableTitle(i)
			if EV.isQuestAuto(GuidelimeData.autoAcceptQuests, function(id) return name == QT.getQuestNameById(id) end) then
				if selectActive == nil and selectAvailable == nil then
					selectAvailable = i
				else
					EV.openNpcAgain = true
				end			
			end
		end

		if selectActive ~= nil then
			C_Timer.After(EV.AUTO_COMPLETE_DELAY, function() 
				if addon.debugging then print ("LIME: QUEST_GREETING selectActive", selectActive) end
				SelectActiveQuest(selectActive)
			end)
		elseif selectAvailable ~= nil then
			C_Timer.After(EV.AUTO_COMPLETE_DELAY, function() 
				if addon.debugging then print ("LIME: QUEST_GREETING selectAvailable", selectAvailable) end
				SelectAvailableQuest(selectAvailable)
			end)
		end
	end
end

EV.frame:RegisterEvent('QUEST_DETAIL')
function EV.frame:QUEST_DETAIL()
	EV.lastQuestOpened = GetQuestID()
	if addon.debugging then print ("LIME: QUEST_DETAIL", EV.lastQuestOpened) end
	if not IsShiftKeyDown() and EV.isQuestAuto(GuidelimeData.autoAcceptQuests, EV.lastQuestOpened) then
		C_Timer.After(EV.AUTO_COMPLETE_DELAY, function()
			AcceptQuest()
			if EV.openNpcAgain then 
				--todo
			end
		end)
	end
end

EV.frame:RegisterEvent('QUEST_PROGRESS')
function EV.frame:QUEST_PROGRESS()
	local id = GetQuestID()
	if addon.debugging then print ("LIME: QUEST_PROGRESS", id) end
	if not IsShiftKeyDown() and IsQuestCompletable() and EV.isQuestAuto(GuidelimeData.autoTurnInQuests, id) then
		C_Timer.After(EV.AUTO_COMPLETE_DELAY, function() 
			CompleteQuest()
			if EV.openNpcAgain then 
				--todo
			end
		end)
	end
end

EV.frame:RegisterEvent('QUEST_COMPLETE')
function EV.frame:QUEST_COMPLETE()
	local id = GetQuestID()
	if not IsShiftKeyDown() and EV.isQuestAuto(GuidelimeData.autoTurnInQuests, id) then
		if addon.debugging then print ("LIME: QUEST_COMPLETE", id) end
		if (GetNumQuestChoices() <= 1) then
			C_Timer.After(EV.AUTO_COMPLETE_DELAY, function() 
		        GetQuestReward(1)
		    end)
		end
	end
end

EV.frame:RegisterEvent('CINEMATIC_START')
function EV.frame:CINEMATIC_START()
	if GuidelimeData.skipCutscenes then
		StopCinematic()
	end
end

EV.frame:RegisterEvent('TAXIMAP_OPENED')
function EV.frame:TAXIMAP_OPENED()
	if GuidelimeData.autoSelectFlight and not IsShiftKeyDown() then
		CG.forEveryActiveElement(function(element)
			if element.flightmaster ~= nil then
				local master = FM.flightmasterDB[element.flightmaster]
				if addon.debugging then print("LIME: looking for", master.zone, master.place) end
				for j = 1, NumTaxiNodes() do
					--if addon.debugging then print("LIME: ", TaxiNodeName(j)) end
					if FM.isFlightmasterMatch(master, TaxiNodeName(j)) then
						if element.t == "FLY" and TaxiNodeGetType(j) == "REACHABLE" then
							if IsMounted() then Dismount() end -- dismount before using the flightpoint
							if addon.debugging then print ("LIME: Flying to " .. (master.place or master.zone)) end
							if _G["TaxiButton"..j] then TaxiNodeOnButtonEnter(_G["TaxiButton"..j]) end
							C_Timer.After(0.5, function()
								TakeTaxiNode(j)
							end)
						elseif element.t == "GET_FLIGHT_POINT" and TaxiNodeGetType(j) == "CURRENT" then
							CG.completeSemiAutomatic(element)
						end
						return
					end
				end
			end
		end)
	end
end

EV.frame:RegisterEvent('PLAYER_CONTROL_LOST')
function EV.frame:PLAYER_CONTROL_LOST()
	C_Timer.After(1, function() 
		if UnitOnTaxi("player") then
			if addon.debugging then print ("LIME: UnitOnTaxi") end
			CG.completeSemiAutomaticByType("FLY")
		end
	end)
end

EV.frame:RegisterEvent('UI_INFO_MESSAGE')
function EV.frame:UI_INFO_MESSAGE(errorType, message)
	if message == ERR_NEWTAXIPATH then
		if addon.debugging then print ("LIME: ERR_NEWTAXIPATH") end
		CG.completeSemiAutomaticByType("GET_FLIGHT_POINT")
	end
end

EV.frame:RegisterEvent('HEARTHSTONE_BOUND')
function EV.frame:HEARTHSTONE_BOUND(errorType, message)
	CG.completeSemiAutomaticByType("SET_HEARTH")
end


EV.frame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
function EV.frame:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellID)
	--if addon.debugging then print("LIME: UNIT_SPELLCAST_SUCCEEDED", unitTarget, castGUID, spellID) end
	if spellID == 8690 or spellID == 556 then
		-- hearthstone was used (or Astral Recall)
		CG.completeSemiAutomaticByType("HEARTH")
	end
	CG.forEveryActiveElement(function(element)
		if element.t == "SPELL" and element.spellId == spellID then
			CG.completeSemiAutomatic(element)
		end
	end)
end

EV.frame:RegisterEvent('LEARNED_SPELL_IN_TAB')
function EV.frame:LEARNED_SPELL_IN_TAB(spellID, skillInfoIndex, isGuildPerkSpell)
	if addon.debugging then print("LIME: LEARNED_SPELL_IN_TAB", spellID, skillInfoIndex, isGuildPerkSpell) end
	local steps = {}
	CG.forEveryActiveElement(function(element)
		if element.t == "LEARN" and element.spellId == spellID then
			table.insert(steps, element.step.index)
		end
	end)
	if #steps > 0 then CG.updateSteps(steps) end
end

EV.frame:RegisterEvent('SKILL_LINES_CHANGED')
function EV.frame:SKILL_LINES_CHANGED()
	if addon.debugging then print("LIME: SKILL_LINES_CHANGED") end
	local steps = {}
	CG.forEveryActiveElement(function(element)
		if element.t == "LEARN" or element.t == "SKILL" then
			table.insert(steps, element.step.index)
		end
	end)
	if #steps > 0 then CG.updateSteps(steps) end
end

EV.requestItemInfo = {}
function EV.GetItemInfo(id)
	itemName, itemLink, itemQuality = GetItemInfo(id)
	if not itemName then
		if EV.requestItemInfo[id] == false or EV.requestItemInfo[id] == 50 then
			EV.requestItemInfo[id] = false
		else
			EV.requestItemInfo[id] = (EV.requestItemInfo[id] or 0) + 1
		end
	end
	return itemName, itemLink, itemQuality
end

EV.frame:RegisterEvent('GET_ITEM_INFO_RECEIVED')
function EV.frame:GET_ITEM_INFO_RECEIVED(itemId,success)
	if EV.requestItemInfo[itemId] and success then
		EV.requestItemInfo[itemId] = nil
		CG.updateStepsText()
		AB.updateUseItemButtons()
	end
end

EV.frame:RegisterEvent('BAG_UPDATE')
function EV.frame:BAG_UPDATE()
	if not EV.queueBagUpdate then
		EV.queueBagUpdate = true
		C_Timer.After(EV.BAG_UPDATE_DELAY, function() 
			EV.queueBagUpdate = false
			if addon.debugging then print("LIME: BAG_UPDATE") end
			local guide = GuidelimeDataChar and addon.guides[GuidelimeDataChar.currentGuide]
			if guide and guide.itemUpdateIndices and #guide.itemUpdateIndices > 0 then
				CG.updateSteps(guide.itemUpdateIndices)
			else
				AB.updateUseItemButtons()
			end
		end)
	end
end

EV.frame:RegisterEvent('PLAYER_FARSIGHT_FOCUS_CHANGED')
function EV.frame:PLAYER_FARSIGHT_FOCUS_CHANGED()
	-- This is a hack to work around an issue with HereBeDragons
	-- see https://www.curseforge.com/wow/addons/herebedragons/issues/31
	-- In situations where player is remote controlling coordinates reported by hbd stay on the player character position and minimap icons do not move
	-- Therefore arrow and minimap will be disabled
	-- TODO: Are there other similar "remote-controlled" quest vehicles?
	local spellIds = {
		6196,   -- Far Sight, 
		321297, -- Eyes of the Beast
		6197,   -- Eagle Exe
		51852,  -- Eye of Acherus (in DK intro quest)
	}
	local i = 1
	while (true) do
		local name, _, _, _, _, _, _, _, _, spellId = UnitAura("player", i, "HELPFUL")
		if not name then break end
		--if addon.debugging then print ("LIME: player has buff", name, spellId) end
		if D.contains(spellIds, spellId) then
			if not M.hideMinimapIconsAndArrowWhileBuffed then
				if addon.debugging then print ("LIME: deactivating arrow and minimap due to", name) end
				M.hideMinimapIconsAndArrowWhileBuffed = true
				M.updateStepsMapIcons()
			end
			return
		end
		i = i + 1
	end
	if M.hideMinimapIconsAndArrowWhileBuffed then
		if addon.debugging then print ("LIME: reactivating arrow and minimap") end
		M.hideMinimapIconsAndArrowWhileBuffed = false
		M.updateStepsMapIcons()
	end
end

EV.frame:RegisterEvent('PLAYER_REGEN_ENABLED')
function EV.frame:PLAYER_REGEN_ENABLED()
	if EV.updateAfterCombat then
		EV.updateAfterCombat = false
		AB.updateTargetButtons()
		AB.updateUseItemButtons()
	end
end

EV.frame:RegisterEvent('UPDATE_BINDINGS')
function EV.frame:UPDATE_BINDINGS()
	AB.updateTargetButtons()
	AB.updateUseItemButtons()
end

EV.frame:RegisterEvent('BAG_UPDATE_COOLDOWN')
function EV.frame:BAG_UPDATE_COOLDOWN()
	if not MW.mainFrame or not MW.mainFrame.useButtons then return end
	for _, button in ipairs(MW.mainFrame.useButtons) do
		if button:IsShown() then
			button:Update()
		end
	end
end

EV.frame:RegisterEvent('PLAYER_LOGOUT')
function EV.frame:PLAYER_LOGOUT()
	-- save a copy of character setting for import
	if not GuidelimeData.chars then GuidelimeData.chars = {} end
	GuidelimeData.chars[UnitGUID("player")] = GuidelimeDataChar
end
