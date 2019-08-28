local addonName, addon = ...
local L = addon.L

-- Register events and call functions
addon.frame:SetScript("OnEvent", function(self, event, ...)
	addon.frame[event](self, ...)
end)

addon.frame:RegisterEvent('PLAYER_ENTERING_WORLD')
function addon.frame:PLAYER_ENTERING_WORLD()
	--if addon.debugging then print("LIME: Player entering world...") end
	if not addon.dataLoaded then addon.loadData() end
	if GuidelimeDataChar.mainFrameShowing then addon.showMainFrame() end
end

addon.frame:RegisterEvent('PLAYER_LEVEL_UP')
function addon.frame:PLAYER_LEVEL_UP(level)
	C_Timer.After(0.1, function()
		addon.level = level
		addon.xpMax = UnitXPMax("player")
		if addon.debugging then print("LIME: You reached level " .. level .. ". Grats! new xp max is " .. addon.xpMax) end
		addon.updateSteps()
	end)
end

addon.frame:RegisterEvent('PLAYER_XP_UPDATE')
function addon.frame:PLAYER_XP_UPDATE(level)
	addon.xp = UnitXP("player")
	--if addon.debugging then print("LIME: xp is " .. addon.xp) end
	addon.updateSteps()
end

function addon.updateFromQuestLog()
	local questLog = {}
	local isCollapsed = {}
	local currentHeader
	for i=1,GetNumQuestLogEntries() do
		local name, _, _, header, collapsed, completed, _, id = GetQuestLogTitle(i)
		if header then
			isCollapsed[name] = collapsed
			currentHeader = name
		else
			questLog[id] = {}
			questLog[id].index = i
			questLog[id].finished = (completed == 1)
			questLog[id].name = name
			questLog[id].sort = currentHeader
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
				q.sort = questLog[id].sort
				--if addon.debugging then print("LIME: new log entry ".. id .. " finished", q.finished) end
			end
			if q.objectives == nil or #q.objectives ~= GetNumQuestLeaderBoards(q.logIndex) then q.objectives = {} end
			for k = 1, GetNumQuestLeaderBoards(q.logIndex) do
				local desc, type, done = GetQuestLogLeaderBoard(k, addon.quests[id].logIndex)
				if q.objectives[k] == nil or desc ~= q.objectives[k] or done ~= q.objectives[k].done then
					questChanged = true
					q.objectives[k] = {desc = desc, done = done, type = type}
				end					
			end
		else
			if q.logIndex ~= nil and q.logIndex ~= -1 and not isCollapsed[q.sort] then
				checkCompleted = true
				q.logIndex = nil
				--if addon.debugging then print("LIME: removed log entry ".. id) end
			end
		end
	end
	if GuidelimeData.showQuestIds then
		local msg = "LIME: current quests: "
		for id, q in pairs(questLog) do
			msg = msg .. q.name .. "(#" .. id .. "), "
		end
		print(msg:sub(1, #msg - 2))
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
	if GuidelimeData.autoCompleteQuest and not IsShiftKeyDown() then 
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
	if GuidelimeData.autoCompleteQuest and not IsShiftKeyDown() then 
		if addon.debugging then print ("LIME: QUEST_GREETING", GetNumActiveQuests()) end
		if addon.debugging then print ("LIME: QUEST_GREETING", GetNumAvailableQuests()) end
		local selectActive = nil
		local selectAvailable = nil
		addon.openNpcAgain = false
		for i = 1, GetNumActiveQuests() do
			local name = GetActiveTitle(i)
			if addon.contains(addon.currentGuide.activeQuests, function(id) return name == addon.getQuestNameById(id) end) then
				if selectActive == nil then
					selectActive = i
				else
					addon.openNpcAgain = true
				end			
			end
		end
		for i = 1, GetNumAvailableQuests() do
			local name = GetAvailableTitle(i)
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
				if addon.debugging then print ("LIME: QUEST_GREETING selectActive", selectActive) end
				SelectActiveQuest(selectActive)
			end)
		elseif selectAvailable ~= nil then
			C_Timer.After(addon.AUTO_COMPLETE_DELAY, function() 
				if addon.debugging then print ("LIME: QUEST_GREETING selectAvailable", selectAvailable) end
				SelectAvailableQuest(selectAvailable)
			end)
		end
	end
end

addon.frame:RegisterEvent('QUEST_DETAIL')
function addon.frame:QUEST_DETAIL()
	local id = GetQuestID()
	if addon.debugging then print ("LIME: QUEST_DETAIL", id) end
	if GuidelimeData.autoCompleteQuest and not IsShiftKeyDown() and addon.currentGuide.activeQuests ~= nil and addon.contains(addon.currentGuide.activeQuests, id) then 
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
	if IsQuestCompletable() and GuidelimeData.autoCompleteQuest and not IsShiftKeyDown() and addon.contains(addon.currentGuide.activeQuests, id) then 
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
	if GuidelimeData.autoCompleteQuest and not IsShiftKeyDown() and addon.contains(addon.currentGuide.activeQuests, id) then 
		if addon.debugging then print ("LIME: QUEST_COMPLETE", id) end
		if (GetNumQuestChoices() <= 1) then
			C_Timer.After(addon.AUTO_COMPLETE_DELAY, function() 
		        GetQuestReward(1)
		    end)
		end
	end
end

addon.frame:RegisterEvent('CINEMATIC_START')
function addon.frame:CINEMATIC_START()
	if addon.debugging then print ("LIME: CINEMATIC_START") end
	if GuidelimeData.skipCutscenes then
		StopCinematic()
	end
end

addon.frame:RegisterEvent('TAXIMAP_OPENED')
function addon.frame:TAXIMAP_OPENED()
	if addon.debugging then print ("LIME: TAXIMAP_OPENED") end
	if GuidelimeData.autoSelectFlight and not IsShiftKeyDown() and addon.currentGuide ~= nil and addon.currentGuide.firstActiveIndex ~= nil and	addon.currentGuide.lastActiveIndex ~= nil then
		local mapID = C_Map.GetBestMapForUnit("player")
		if not mapID then return end -- no mapID for player found
		for i = addon.currentGuide.firstActiveIndex, addon.currentGuide.lastActiveIndex do
			local step = addon.currentGuide.steps[i]
			for _, element in ipairs(step.elements) do
				if not element.completed then
					if element.flightmaster ~= nil then
						local master = addon.flightmasterDB[element.flightmaster]
						local taxiNodes = C_TaxiMap.GetAllTaxiNodes(mapID)
						for i = 1, #taxiNodes do
							local taxiNodeData = taxiNodes[i]
							if master.place == taxiNodeData.name:sub(1, #master.place) then
								if element.t == "FLY" and taxiNodeData.state == Enum.FlightPathState.Reachable then
									if IsMounted() then Dismount() end -- dismount before using the flightpoint
									if addon.debugging then print ("LIME: Flying to " .. master.place) end
									TakeTaxiNode(taxiNodeData.slotIndex)
									addon.completeSemiAutomatic(element)
								elseif element.t == "GET_FLIGHT_POINT" and taxiNodeData.state == Enum.FlightPathState.Current then
									addon.completeSemiAutomatic(element)
								end
								return
							end
						end
					end
				end
			end
		end
	end
end

addon.frame:RegisterEvent('UI_INFO_MESSAGE')
function addon.frame:UI_INFO_MESSAGE(errorType, message)
	if addon.debugging then print ("LIME: UI_INFO_MESSAGE", errorType, message) end
	if message == ERR_NEWTAXIPATH then
		if addon.debugging then print ("LIME: ERR_NEWTAXIPATH") end
		addon.completeSemiAutomaticByType("GET_FLIGHT_POINT")
	end
end

addon.frame:RegisterEvent('HEARTHSTONE_BOUND')
function addon.frame:HEARTHSTONE_BOUND(errorType, message)
	if addon.debugging then print ("LIME: HEARTHSTONE_BOUND") end
	addon.completeSemiAutomaticByType("SET_HEARTH")
end


addon.frame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
function addon.frame:UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellID)
	if addon.debugging then print ("LIME: UNIT_SPELLCAST_SUCCEEDED", unitTarget, castGUID, spellID) end
	-- hearthstone was used
	if spellID == 8690 then
		addon.completeSemiAutomaticByType("HEARTH")
	end
end
