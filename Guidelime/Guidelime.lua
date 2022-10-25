local addonName, addon = ...
local L = addon.L

local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

Guidelime = {}

addon.CONTACT_DISCORD = "Borick#7318"
addon.CONTACT_CURSEFORGE = "rickrob"
addon.CONTACT_REDDIT = "u/borick23"

SLASH_Guidelime1 = "/lime"
SLASH_Guidelime2 = "/guidelime"
function SlashCmdList.Guidelime(msg)
	if msg == '' then Guidelime.toggleMainFrame()
	elseif msg == 'debug true' and not addon.debugging then GuidelimeData.debugging = true; ReloadUI()
	elseif msg == 'debug false' and addon.debugging then GuidelimeData.debugging = false; ReloadUI()
	elseif msg == 'complete' then addon.CG.simulateCompleteCurrentSteps()
	elseif msg == 'skip' then addon.CG.skipCurrentSteps()
	elseif msg == 'questie true' and not GuidelimeData.dataSourceQuestie then GuidelimeData.dataSourceQuestie = true; ReloadUI()
	elseif msg == 'questie false' and GuidelimeData.dataSourceQuestie then GuidelimeData.dataSourceQuestie = false; ReloadUI()
	--elseif msg == 'quests' then addon.checkQuests()
	end
end

-- for key bindings
_G["BINDING_HEADER_GUIDELIME"] = "Guidelime"
_G["BINDING_NAME_GUIDELIME_TOGGLE"] = L.SHOW_MAINFRAME
_G["BINDING_NAME_GUIDELIME_TOGGLE_MAP_MARKERS"] = L.SHOW_MARKERS_ON .. " " .. L.MAP
_G["BINDING_NAME_GUIDELIME_TOGGLE_MINIMAP_MARKERS"] = L.SHOW_MARKERS_ON .. " " .. L.MINIMAP

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
	TARGET_BUTTON = "Interface\\Icons\\Ability_Hunter_Snipershot",
	MULTI_TARGET_BUTTON = "Interface\\Icons\\Ability_Hunter_FocusedAim",
	-- normally class icons could be obtained by using SetTextCoord with CLASS_ICON_TCOORDS[class] on "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
	-- but since this is not so easily done e.g. in EasyMenu we provide alternative class icons here (cf https://wowpedia.fandom.com/wiki/Class_icon)
	DEATHKNIGHT = "Interface\\Icons\\spell_deathknight_classicon",
	DRUID = "Interface\\Icons\\inv_misc_monsterclaw_04",
	HUNTER = "Interface\\Icons\\inv_weapon_bow_07",
	MAGE = "Interface\\Icons\\inv_staff_13",
	PALADIN = "Interface\\Icons\\inv_hammer_01",
	PRIEST = "Interface\\Icons\\inv_staff_30",
	ROGUE = "Interface\\Icons\\inv_throwingknife_04",
	SHAMAN = "Interface\\Icons\\inv_jewelry_talisman_04",
	WARLOCK = "Interface\\Icons\\spell_nature_drowsy",
	WARRIOR = "Interface\\Icons\\inv_sword_27",

	--LOC = "Interface\\Icons\\Ability_Tracking",
	--KILL = "Interface\\Icons\\Ability_Creature_Cursed_02",
	--MAP = "Interface\\Icons\\Ability_Spy",
	--NOTE = "Interface\\Icons\\INV_Misc_Note_01",
	--USE = "Interface\\Icons\\INV_Misc_Bag_08",
	--BUY = "Interface\\Icons\\INV_Misc_Coin_01",
	--BOAT = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
}

addon.guides = {}
addon.dataLoaded = false

function Guidelime.registerGuide(guide, group)
	guide = addon.GP.parseGuide(guide, group, nil, true)
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
		maxNumOfMarkersLOC = 50,
		arrowStyle = 1,
		arrowDistance = false,
		skipCutscenes = true,
		dataSource = "QUESTIE",
		autoAddCoordinates = true,
		displayDemoGuides = true,
		fontColorACCEPT = addon.MW.COLOR_QUEST_DEFAULT,
		fontColorCOMPLETE = addon.MW.COLOR_QUEST_DEFAULT,
		fontColorTURNIN = addon.MW.COLOR_QUEST_DEFAULT,
		fontColorSKIP = addon.MW.COLOR_QUEST_DEFAULT,
		autoAcceptQuests = "Current",
		autoTurnInQuests = "Current",
		autoSelectFlight = true,
		showQuestIds = false,
		showMapMarkersInGuide = true,
		targetRaidMarkers = true,
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
		showTitle = true,
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
		version = GetAddOnMetadata(addonName, "version"),
		completedSteps = {},
		showTargetButtons = "LEFT",
		showUseItemButtons = "LEFT",
		showMinimapButton = true
	}
	if GuidelimeData == nil then GuidelimeData = {} end
	if GuidelimeDataChar == nil then GuidelimeDataChar = {} end
	for option, default in pairs(defaultOptions) do
		if GuidelimeData[option] == nil then GuidelimeData[option] = default end
	end
	for option, default in pairs(defaultOptionsChar) do
		if GuidelimeDataChar[option] == nil then GuidelimeDataChar[option] = default end
	end

	GuidelimeDataChar.version:gsub("(%d+).(%d+)", function(major, minor)
		if GuidelimeData.debugging then print("LIME: last saved character data version", major, minor) end
		if tonumber(major) < 1 or (tonumber(major) == 1 and tonumber(minor) < 2) then
			--changed default value for showUnavailableSteps
			GuidelimeDataChar.showUnavailableSteps = true
			GuidelimeDataChar.version = GetAddOnMetadata(addonName, "version")
		end
		if tonumber(major) == 0 and tonumber(minor) < 41 then
			GuidelimeDataChar.autoCompleteQuest = nil
		end
		if tonumber(major) == 0 and tonumber(minor) < 28 then
			--GuidelimeDataChar.currentGuide.skip was replaced with GuidelimeDataChar.guideSkip and GuidelimeDataChar.currentGuide.name with GuidelimeDataChar.currentGuide. Therefore remove.
			GuidelimeDataChar.currentGuide = nil
		end
	end, 1)
	GuidelimeData.version:gsub("(%d+).(%d+)", function(major, minor)
		if GuidelimeData.debugging then print("LIME: last saved data version", major, minor) end
		if tonumber(major) < 3 or (tonumber(major) == 3 and tonumber(minor) < 11) then
			-- new name for internal database is DB
			if GuidelimeData.dataSource == "INTERNAL" then GuidelimeData.dataSource = "DB" end
		end
		if tonumber(major) < 3 then
			-- autoCompleteQuest is removed and replaced with autoAcceptQuests and autoTurnInQuests
			-- if old value was true new value should be set to the new default "Current"
			GuidelimeData.autoAcceptQuests = (GuidelimeData.autoCompleteQuest ~= false and "Current") or false
			GuidelimeData.autoTurnInQuests = GuidelimeData.autoAcceptQuests
			GuidelimeData.autoCompleteQuest = nil
			GuidelimeData.version = GetAddOnMetadata(addonName, "version")
		end
		if tonumber(major) < 2 or (tonumber(major) == 2 and tonumber(minor) < 15) then
			-- dataSourceQuestie is removed and replaced with dataSource which should be set to "QUESTIE"
			-- (even when Questie is not installed; it will only be changed to "INTERNAL" when internal was selected manually)
			GuidelimeData.dataSourceQuestie = nil
		end
		if tonumber(major) < 2 or (tonumber(major) == 2 and tonumber(minor) < 13) then
			--if maxNumOfMarkersLOC was unchanged change to new default value of 50
			if GuidelimeData.maxNumOfMarkersLOC == 15 then GuidelimeData.maxNumOfMarkersLOC = 50 end
		end
		if tonumber(major) < 2 then
			--changed default value for dataSourceQuestie
			GuidelimeData.dataSourceQuestie = true
		end
		if tonumber(major) < 1 or (tonumber(major) == 1 and tonumber(minor) < 28) then
			--hide option debugging, dataSourceQuestie
			GuidelimeData.debugging = false
			addon.debugging = false
			--GuidelimeData.dataSourceQuestie = false
		end
		if tonumber(major) == 0 and tonumber(minor) < 39 then
			--removed options mapMarkerStyle, mapMarkerSize, autoAddCoordinates
			GuidelimeData.mapMarkerStyle = nil
			GuidelimeData.mapMarkerSize = nil
			GuidelimeData.autoAddCoordinates = nil
		end
		if tonumber(major) == 0 and tonumber(minor) < 36 then
			--options reworked; remove everything old
			GuidelimeData.hideCompletedSteps = nil
			GuidelimeData.hideUnavailableSteps = nil
			GuidelimeData.maxNumOfStepsGOTO = nil
			GuidelimeData.maxNumOfStepsLOC = nil
		end
		if tonumber(major) == 0 and tonumber(minor) < 21 then
			--autoAddCoordinates default changed to true; reset for everyone
			GuidelimeData.autoAddCoordinates = true
		end
		if tonumber(major) == 0 and tonumber(minor) < 18 then
			-- maxNumOfMarkers is deprecated
			GuidelimeData.maxNumOfMarkers = nil
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
		end
	end, 1)

	addon.debugging = GuidelimeData.debugging
	addon.dataSource = GuidelimeData.dataSource
	if not addon[addon.dataSource].isDataSourceInstalled or not addon[addon.dataSource].isDataSourceInstalled() then 
		addon.dataSource = addon.QUESTIE.isDataSourceInstalled() and "QUESTIE" or (addon.CLASSIC_CODEX.isDataSourceInstalled() and "CLASSIC_CODEX" or "DB") 
	end

	if GuidelimeData.customGuides ~= nil then
		for _, guide in pairs(GuidelimeData.customGuides) do
			Guidelime.registerGuide(guide, L.CUSTOM_GUIDES)
		end
	end

	addon.CG.loadCurrentGuide(false)

	addon.G.fillGuides()
	addon.O.fillOptions()

	addon.dataLoaded = true

	if addon.debugging then Guidelime.addon = addon end
	--if addon.debugging then addon.testLocalization() end
	addon.setupMinimapButton()
end

function addon.setupMinimapButton()
	if not LibDBIcon:GetMinimapButton(addonName) then
	    LibDBIcon:Register(addonName, LibDataBroker:NewDataObject(addonName, 
		{
	        type = "data source",
	        label = addonName,
	        icon = "Interface\\Addons\\" .. addonName .. "\\Icons\\lime",
	        tocname = addonName,
	        OnClick = function(_, button)
				if not IsShiftKeyDown() then
		            if button == "LeftButton" then
		                Guidelime.toggleMainFrame()
		            else
						addon.O.showOptions()
		            end
				else
		            if button == "LeftButton" then
		                Guidelime.toggleMapMarkers()
		            else
						Guidelime.toggleMinimapMarkers()
		            end
				end
	        end,
	        OnTooltipShow = function(tooltip)
	            tooltip:AddLine(addonName)
	            tooltip:AddLine(addon.MW.COLOR_INACTIVE .. L.LEFT_CLICK .. ":|r " .. (GuidelimeDataChar.mainFrameShowing and L.HIDE_MAINFRAME or L.SHOW_MAINFRAME))
	            tooltip:AddLine(addon.MW.COLOR_INACTIVE .. L.RIGHT_CLICK .. ":|r " .. GAMEOPTIONS_MENU)
	            tooltip:AddLine(addon.MW.COLOR_INACTIVE .. L.SHIFT_LEFT_CLICK .. ":|r " .. ((GuidelimeData.showMapMarkersGOTO or GuidelimeData.showMapMarkersLOC) and L.HIDE_MARKERS_ON or L.SHOW_MARKERS_ON) .. " " .. L.MAP)
	            tooltip:AddLine(addon.MW.COLOR_INACTIVE .. L.SHIFT_RIGHT_CLICK .. ":|r " .. ((GuidelimeData.showMinimapMarkersGOTO or GuidelimeData.showMinimapMarkersLOC) and L.HIDE_MARKERS_ON or L.SHOW_MARKERS_ON) .. " " .. L.MINIMAP)
	        end
	    }), GuidelimeData)
		addon.minimapButtonFlash = LibDBIcon:GetMinimapButton(addonName):CreateAnimationGroup()
		local flash = addon.minimapButtonFlash:CreateAnimation("Alpha")
		flash:SetOrder(1)
		flash:SetDuration(0.5)
		flash:SetFromAlpha(0)
		flash:SetToAlpha(1)
		addon.minimapButtonFlash:SetToFinalAlpha(true)
	end
	if (GuidelimeDataChar.showMinimapButton == "hiddenMainFrame" and not GuidelimeDataChar.mainFrameShowing) or GuidelimeDataChar.showMinimapButton == true then
		LibDBIcon:Show(addonName)
	else
		LibDBIcon:Hide(addonName)
	end
end

--[[
local function listAliasQuests(completed, id, excludeIds)
	local text = ""
	for _, id2 in ipairs(addon.QT.getPossibleQuestIdsByName(addon.DB.questsDB[id].name)) do
		if id2 ~= id and not addon.D.contains(excludeIds, ids) then
			text = text .. "Quest \"" .. addon.DB.questsDB[id2].name .. "\"(" .. id2 .. ") "
			if not completed[id2] then text = text .. "not " end
			text = text .. "completed.\r"
		end
	end
	return text
end

function addon.checkQuests()
	local completed = addon.QT.GetQuestsCompleted()
	local count = 0
	local text = ""
	for id, value in pairs(completed) do
		count = count + 1
		if addon.DB.questsDB[id] ~= nil then
			local missingPrequests = addon.QT.getMissingPrequests(id, function(id) return completed[id] end)
			local found = false
			local ids = {id}
			for _, pid in ipairs(missingPrequests) do
				text = text .. "Quest \"" .. addon.DB.questsDB[id].name .. "\"(" .. id .. ") was completed but prequest \"" .. addon.DB.questsDB[pid].name .. "\"(" .. pid .. ") was not.\r"
				text = text .. listAliasQuests(completed, pid, ids)
				table.insert(ids, pid)
				found = true
			end
			if addon.DB.questsDB[id].replacement ~= nil and not completed[addon.DB.questsDB[id].replacement] then
				text = text .. "Quest \"" .. addon.DB.questsDB[id].name .. "\"(" .. id .. ") was completed but is marked as being replaced by \"" .. addon.DB.questsDB[addon.DB.questsDB[id].replacement].name .. "\"(" .. addon.DB.questsDB[id].replacement .. ") which is not completed.\r"
				table.insert(ids, addon.DB.questsDB[id].replacement)
				found = true
			end
			if not addon.D.applies(addon.DB.questsDB[id]) then
				text = text .. "Quest \"" .. addon.DB.questsDB[id].name .. "\"(" .. id .. ") was completed but is marked as being unavailable for this character.\r"
				found = true
			end
			--if addon.DB.questsDB[id].replaces ~= nil and not completed[addon.DB.questsDB[id].replaces] then
			--	text = text .. "Quest \"" .. addon.DB.questsDB[id].name .. "\"(" .. id .. ") was completed but is marked as being replacement for \"" .. addon.DB.questsDB[addon.DB.questsDB[id].replaces].name .. "\"(" .. addon.DB.questsDB[id].replaces .. ") which is not completed.\r"
			--	table.insert(ids, addon.DB.questsDB[id].replaces)
			--	found = true
			--end
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
			(addon.D.level or "?")  .. " " .. (addon.D.race or "?")  .. " " .. (addon.D.class or "?")  .. "," ..
			" at " .. date("%Y/%m/%d %H:%M:%S", GetServerTime()) .. 
			" with " .. GetAddOnMetadata(addonName, "title") .. " " .. GetAddOnMetadata(addonName, "version") .. "\r\n" .. text
		text = string.format(L.CHECK_QUESTS, addon.CONTACT_DISCORD, addon.CONTACT_CURSEFORGE, addon.CONTACT_REDDIT) .. "\r\n" .. text
		text = string.format(L.CHECK_QUESTS_COMPLETED, count) .. ".\r" .. text
		local popup = addon.F.showCopyPopup(text, "", 0, 500, true)
	end
end
]]