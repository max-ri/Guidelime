local addonName, addon = ...
local L = addon.L

local HBD = LibStub("HereBeDragons-2.0")
local HBDPins = LibStub("HereBeDragons-Pins-2.0")

addon.D = addon.D or {}; local D = addon.D     -- Data/Data
addon.FM = addon.FM or {}; local FM = addon.FM -- Data/FlightmasterDB
addon.PT = addon.PT or {}; local PT = addon.PT -- Data/PositionTools
addon.CG = addon.CG or {}; local CG = addon.CG -- CurrentGuide
addon.E = addon.E or {}; local E = addon.E     -- Editor
addon.F = addon.F or {}; local F = addon.F     -- Frames
addon.MW = addon.MW or {}; local MW = addon.MW -- MainWindow

addon.M = addon.M or {}; local M = addon.M     -- Map

M.MAX_MAP_INDEX = 59
M.SPECIAL_MAP_INDEX = {monster = 60, item = 61, object = 62, npc = 63, LOC = 63}
M.mapIcons = {}

local function createIconFrame(t, index)
    local f = CreateFrame("Button")
	
	local frameLevel, layer = 7 - index, "OVERLAY"
	if frameLevel < -8 then frameLevel = frameLevel + 16; layer = "ARTWORK" end
	if frameLevel < -8 then frameLevel = frameLevel + 16; layer = "BORDER" end
	if frameLevel < -8 then frameLevel = frameLevel + 16; layer = "BACKGROUND" end
	if frameLevel < -8 then frameLevel = -8 end
    f.texture = f:CreateTexture(nil, layer, nil, frameLevel)
	M.setMapIconTexture(f, t)
	if t ~= "GOTO" then
		index = M.SPECIAL_MAP_INDEX[t]
	elseif index > M.MAX_MAP_INDEX then
		index = M.SPECIAL_MAP_INDEX.LOC
	end
	f.texture:SetTexCoord((index % 8) / 8, (index % 8 + 1) / 8, math.floor(index / 8) / 8, (math.floor(index / 8) + 1) / 8)
	-- dont mess with my icon
	f.texture.SetTexCoord = function() end
	f.texture.SetBackdrop = function() end
	f.texture.SetBackdropColor = function() end
	f.texture.SetBackdropBorderColor = function() end
	f.SetTexCoord = function() end
	f.SetBackdrop = function() end
	f.SetBackdropColor = function() end
	f.SetBackdropBorderColor = function() end
	f.isSkinned = true
	
    f.texture:SetAllPoints(f)

    f:SetPoint("CENTER", 0, 0)
    f:EnableMouse(false)
	f:SetScript("OnEnter", function(self) 
		if self.tooltip ~= nil and self.tooltip ~= "" then 
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32)
			GameTooltip:SetText(self.tooltip); GameTooltip:Show()
			F.showingTooltip = true 
		end 
	end)
	f:SetScript("OnLeave", function(self) 
		if self.tooltip ~= nil and self.tooltip ~= "" and F.showingTooltip then 
			GameTooltip:Hide()
			F.showingTooltip = false 
		end 
	end)

    function f:Unload()
        HBDPins:RemoveMinimapIcon(M, self);
        HBDPins:RemoveWorldMapIcon(M, self);
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

function M.setMapIconTexture(f, t)
	if t ~= "GOTO" then t = "LOC" end
    f.texture:SetTexture(addon.icons["MAP_MARKER_" .. GuidelimeData["mapMarkerStyle" .. t]])
	f.texture:SetAlpha(GuidelimeData["mapMarkerAlpha" .. t])
    f.texture:SetWidth(GuidelimeData["mapMarkerSize" .. t])
    f.texture:SetHeight(GuidelimeData["mapMarkerSize" .. t])
    f:SetWidth(GuidelimeData["mapMarkerSize" .. t])
    f:SetHeight(GuidelimeData["mapMarkerSize" .. t])
end

function M.setMapIconTextures()
	for t, icons in pairs(M.mapIcons) do
		for i = 0, #icons do
			if icons[i] ~= nil then
				M.setMapIconTexture(icons[i].map, t)
				M.setMapIconTexture(icons[i].minimap, t)
			end
		end
	end
end

local function createMapIcon(t, i)
	if i == nil then
		i = #M.mapIcons[t] + 1
	end
	M.mapIcons[t][i] = {}
	M.mapIcons[t][i].map = createIconFrame(t, i)
	M.mapIcons[t][i].minimap = createIconFrame(t, i)
	M.mapIcons[t][i].index = i
	M.mapIcons[t][i].inUse = false
	return M.mapIcons[t][i]
end

local function getMapIcon(t, element, highlight)
	if M.mapIcons[t] == nil then M.mapIcons[t] = {} end
	if highlight then 
		if M.mapIcons[t][0] == nil then createMapIcon(t, 0) end
		return M.mapIcons[t][0] 
	end
	if M.mapIcons[t] ~= nil then
		for i, mapIcon in ipairs(M.mapIcons[t]) do
			if mapIcon.inUse then 
				if mapIcon.mapID == element.mapID and mapIcon.x == element.x and mapIcon.y == element.y then
					return mapIcon
				end
			else
				return mapIcon
			end
		end
	end
	return createMapIcon(t)		
end

function M.getMapTooltip(element)
	if not GuidelimeData.showTooltips then return end
	local tooltip
	if element and element.attached and element.attached.questId then 
		tooltip = CG.getQuestIcon(element.attached.questId, element.attached.t, element.attached.objective, element.attached.finished) .. 
			CG.getQuestText(element.attached.questId, element.attached.t, nil, element.step and element.step.active) 
		if element.attached.t ~= "ACCEPT" then
			local objectives
			if element.attached.t == "TURNIN" then
				objectives = true
			elseif element.attached.objective ~= nil then
				objectives = {element.attached.objective}
			elseif element.objectives ~= nil then
				objectives = element.objectives
			else
				objectives = true
			end
			local obj = CG.getQuestObjectiveText(element.attached.questId, objectives, "    ", element.npcId, element.objectId)
			if obj ~= "" then tooltip = tooltip .. "\n" .. obj end
		end
	end
	if tooltip == nil and element and element.step ~= nil then tooltip = CG.getStepText(element.step) end
	if element and element.estimate then if tooltip == nil then tooltip = L.ESTIMATE else tooltip = tooltip .. "\n" .. L.ESTIMATE end end
	return tooltip
end

function M.addMapIcon(element, highlight, ignoreMaxNumOfMarkers)
	if element.x == nil or element.y == nil or element.mapID == nil then return end	
	local mapIcon = getMapIcon(element.markerTyp or element.t, element, highlight)
	if mapIcon == nil then return end
	if not ignoreMaxNumOfMarkers then
		if element.t == "GOTO" and mapIcon.index >= GuidelimeData.maxNumOfMarkersGOTO and GuidelimeData.maxNumOfMarkersGOTO > 0 then return end
		if not element.step.active and element.t ~= "GOTO" then return end
	end
	mapIcon.instance = element.instance
	mapIcon.wx = element.wx
	mapIcon.wy = element.wy	
	mapIcon.mapID = element.mapID
	mapIcon.x = element.x
	mapIcon.y = element.y
	local tooltip = M.getMapTooltip(element)
	if not mapIcon.inUse then
		mapIcon.map.tooltip = tooltip
		mapIcon.minimap.tooltip = tooltip
	elseif tooltip ~= nil then
		mapIcon.map.tooltip = (mapIcon.map.tooltip or "") .. "\n" .. tooltip
		mapIcon.minimap.tooltip = (mapIcon.minimap.tooltip or "") .. "\n" .. tooltip
	end
	mapIcon.inUse = true
	element.mapIndex = mapIcon.index
	--if addon.debugging then print("LIME : addMapIcon", element.mapID, element.x / 100, element.y / 100, highlight) end
end

function M.removeMapIcons()
	HBDPins:RemoveAllWorldMapIcons(M)
	HBDPins:RemoveAllMinimapIcons(M)
	for _, icons in pairs(M.mapIcons) do
		for i, mapIcon in pairs(icons) do
			mapIcon.inUse = false
		end
	end
	for i, step in ipairs(CG.currentGuide.steps) do
		for j, element in ipairs(step.elements) do
			element.mapIndex = nil
		end
	end
end

local function showMapIcon(mapIcon, t)
	if mapIcon ~= nil and mapIcon.inUse then
		if t ~= "GOTO" then t = "LOC" end
		-- Hack for Scarlet Enclave: world map icons are not shown in Scarlet Enclave therefore use map icon
		-- map icons are not useful for other zones on the other hand as then the icon will only appear in the map of the given zone and not in others
		if mapIcon.mapID == 124 then
			if GuidelimeData["showMapMarkers" .. t] then HBDPins:AddWorldMapIconMap(M, mapIcon.map, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, 3) end
			if GuidelimeData["showMinimapMarkers" .. t] and not M.hideMinimapIconsAndArrowWhileBuffed then HBDPins:AddMinimapIconMap(M, mapIcon.minimap, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, true, mapIcon.index == 0) end
		else
			if GuidelimeData["showMapMarkers" .. t] then HBDPins:AddWorldMapIconWorld(M, mapIcon.map, mapIcon.instance, mapIcon.wx, mapIcon.wy, 3) end
			if GuidelimeData["showMinimapMarkers" .. t] and not M.hideMinimapIconsAndArrowWhileBuffed then HBDPins:AddMinimapIconWorld(M, mapIcon.minimap, mapIcon.instance, mapIcon.wx, mapIcon.wy, true, mapIcon.index == 0) end
		end
	end
end

function M.showMapIcons()
	for t, icons in pairs(M.mapIcons) do
		for i = #icons, 0, -1 do
			showMapIcon(icons[i], t)
		end
	end
	if M.updateFrame == nil then
		M.updateFrame = CreateFrame("frame")
		M.updateFrame:SetScript("OnUpdate", M.updateArrow)
	end
	if M.arrowFrame == nil then
		M.arrowFrame = CreateFrame("FRAME", nil, UIParent)
		M.arrowFrame:SetPoint(GuidelimeDataChar.arrowRelative, UIParent, GuidelimeDataChar.arrowRelative, GuidelimeDataChar.arrowX, GuidelimeDataChar.arrowY)
	    M.arrowFrame.texture = M.arrowFrame:CreateTexture(nil, "OVERLAY")
	    M.setArrowTexture()
	    M.arrowFrame.texture:SetAllPoints()
		M.arrowFrame:SetAlpha(GuidelimeDataChar.arrowAlpha)
		M.arrowFrame:SetWidth(GuidelimeDataChar.arrowSize)
		M.arrowFrame:SetHeight(GuidelimeDataChar.arrowSize)
		M.arrowFrame:SetMovable(true)
		M.arrowFrame:EnableMouse(true)
		M.arrowFrame:SetScript("OnMouseDown", function(this) 
			if not GuidelimeDataChar.arrowLocked then M.arrowFrame:StartMoving() end
		end)
		M.arrowFrame:SetScript("OnMouseUp", function(this) 
			M.arrowFrame:StopMovingOrSizing() 
			local _
			_, _, GuidelimeDataChar.arrowRelative, GuidelimeDataChar.arrowX, GuidelimeDataChar.arrowY = M.arrowFrame:GetPoint()
		end)
		M.arrowFrame.text = M.arrowFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		M.arrowFrame.text:SetPoint("TOP", M.arrowFrame, "BOTTOM", 0, 0)
		M.arrowFrame:SetScript("OnEnter", function(self) 
			if D.isAlive() then
				self.tooltip = M.getMapTooltip(self.element)
			else
				self.tooltip = L.ARROW_TOOLTIP_CORPSE
			end
			if self.tooltip ~= nil and self.tooltip ~= "" then 
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32)
				GameTooltip:SetText(self.tooltip)
				GameTooltip:Show()
				F.showingTooltip = true 
			end 
		end)
		M.arrowFrame:SetScript("OnLeave", function(self) 
			if self.tooltip ~= nil and self.tooltip ~= "" and F.showingTooltip then 
				GameTooltip:Hide()
				F.showingTooltip = false 
			end 
		end)
	end
end

function M.getMapMarkerText(element)
	local index = element.mapIndex
	if element.t ~= "GOTO" then
		index = M.SPECIAL_MAP_INDEX[element.markerTyp or element.t]
	elseif index > M.MAX_MAP_INDEX then
		index = M.SPECIAL_MAP_INDEX.LOC
	end
	local t = element.t
	if t ~= "GOTO" then t = "LOC" end
	return "|T" .. addon.icons["MAP_MARKER_" .. GuidelimeData["mapMarkerStyle" .. t]] .. ":15:15:0:1:512:512:" .. 
		index % 8 * 64 .. ":" .. (index % 8 + 1) * 64 .. ":" .. 
		math.floor(index / 8) * 64 .. ":" .. (math.floor(index / 8) + 1) * 64 .. ":::|t"
end

function M.setArrowTexture()
	if GuidelimeData.arrowStyle == 1 then
		M.arrowFrame.texture:SetTexture(addon.icons.MAP_LIME_ARROW)
		M.arrowFrame.texture:SetVertexColor(1,1,1)
	elseif GuidelimeData.arrowStyle == 2 then
		M.arrowFrame.texture:SetTexture(addon.icons.MAP_ARROW)
		M.arrowFrame.texture:SetVertexColor(0.5,1,0.2)
	end
	M.arrowFrame:SetWidth(GuidelimeDataChar.arrowSize)
	M.arrowFrame:SetHeight(GuidelimeDataChar.arrowSize)
end

function M.getArrowIconText()
	local col, row = 0, 0
	if M.arrowFrame ~= nil and M.arrowFrame.col ~= nil then col = M.arrowFrame.col end
	if M.arrowFrame ~= nil and M.arrowFrame.row ~= nil then row = M.arrowFrame.row end
	if GuidelimeData.arrowStyle == 1 then
		return "|T" .. addon.icons.MAP_LIME_ARROW .. ":15:15:0:1:512:512:" .. 
			col * 64 .. ":" .. (col + 1) * 64 .. ":" .. 
			row * 64 .. ":" .. (row + 1) * 64 .. ":::|t"
	elseif GuidelimeData.arrowStyle == 2 then
		return "|T" .. addon.icons.MAP_ARROW .. ":15:15:0:1:512:512:" .. 
			col * 56 .. ":" .. (col + 1) * 56 .. ":" .. 
			row * 42 .. ":" .. (row + 1) * 42 .. ":127:255:51|t"
	end
end

M.updateArrowCount = 0
function M.updateArrow()
	D.wx, D.wy, D.instance = HBD:GetPlayerWorldPosition()
	D.face = GetPlayerFacing()
	if D.wx == nil or D.wy == nil or D.face == nil then return end
	if M.arrowFrame == nil then return end
	if not MW.mainFrame or not MW.mainFrame:IsShown() or not GuidelimeDataChar.showArrow then 
		if M.arrowFrame:IsShown() then M.arrowFrame:Hide() end
		return 
	end
	
	M.arrowX, M.arrowY = nil, nil
	if not D.isAlive() then
		local corpse = HBD:GetPlayerZone() and C_DeathInfo.GetCorpseMapPosition(HBD:GetPlayerZone())
		if corpse ~= nil then
			M.arrowX, M.arrowY = HBD:GetWorldCoordinatesFromZone(corpse.x, corpse.y, HBD:GetPlayerZone())
			M.arrowInstance = D.instance
		end
	elseif not M.hideMinimapIconsAndArrowWhileBuffed and M.arrowFrame.element ~= nil and 
		M.arrowFrame.element.wx ~= nil and M.arrowFrame.element.wy ~= nil and 
		not M.arrowFrame.element.completed then
		M.arrowX, M.arrowY, M.arrowInstance = M.arrowFrame.element.wx, M.arrowFrame.element.wy, M.arrowFrame.element.instance
	end
	
	if M.arrowX == nil or M.arrowY == nil then 
		if M.lastArrowX and M.lastArrowY and M.arrowRadius2 then
			local dist2 = (D.wx - M.lastArrowX) * (D.wx - M.lastArrowX) + (D.wy - M.lastArrowY) * (D.wy - M.lastArrowY)
			if M.lastArrowInstance ~= D.instance or (dist2 >= M.arrowRadius2 * CG.GOTO_HYSTERESIS_FACTOR and M.lastDistance2 and M.lastDistance2 <= M.arrowRadius2 * CG.GOTO_HYSTERESIS_FACTOR) then
				if addon.debugging then print("LIME: position left") end
				CG.updateSteps()
				M.lastArrowX, M.lastArrowY, M.lastArrowInstance = nil, nil, nil
			end
			M.lastDistance2 = dist2
		end
	else
		M.lastArrowX, M.lastArrowY, M.lastArrowInstance = M.arrowX, M.arrowY, M.arrowInstance
	end
	
	local angle, dist2, alpha
	if M.arrowX == nil or M.arrowY == nil or M.arrowInstance ~= D.instance then
		angle = math.pi
		alpha = 0.25
	else
		angle = D.face - math.atan2(M.arrowX - D.wx, M.arrowY - D.wy)
		dist2 = (D.wx - M.arrowX) * (D.wx - M.arrowX) + (D.wy - M.arrowY) * (D.wy - M.arrowY)
		if M.arrowFrame.element and M.arrowFrame.element.radius then
			M.arrowRadius2 = M.arrowFrame.element.radius * M.arrowFrame.element.radius
			if dist2 < M.arrowRadius2 and (not M.lastDistance2 or M.lastDistance2 >= M.arrowRadius2) then
				if addon.debugging then print("LIME: position reached") end
				CG.updateSteps()
			end
		else
			M.arrowRadius2 = nil
		end
		M.lastDistance2 = dist2
		alpha = 1
	end
	if GuidelimeData.arrowStyle == 1 then
		local index = angle * 32 / math.pi
		if index >= 64 then index = index - 64 elseif index < 0 then index = index + 64 end
		M.arrowFrame.col = math.floor(index % 8)
		M.arrowFrame.row = math.floor(index / 8)
		M.arrowFrame.texture:SetTexCoord(M.arrowFrame.col / 8, (M.arrowFrame.col + 1) / 8, M.arrowFrame.row / 8, (M.arrowFrame.row + 1) / 8)
		M.arrowFrame.texture:SetVertexColor(1,1,1,alpha)
	elseif GuidelimeData.arrowStyle == 2 then
		local index = -angle * 54 / math.pi
		if index < 0 then index = index + 108 end
		if index < 0 then index = index + 108 end
		M.arrowFrame.col = math.floor(index % 9)
		M.arrowFrame.row = math.floor(index / 9)
		M.arrowFrame.texture:SetTexCoord(M.arrowFrame.col * 56 / 512, (M.arrowFrame.col + 1) * 56 / 512, M.arrowFrame.row * 42 / 512, (M.arrowFrame.row + 1) * 42 / 512)
		M.arrowFrame.texture:SetVertexColor(0.5,1,0.2,alpha)
	end
	if M.arrowFrame.element and M.arrowFrame.element.completed then
		M.arrowFrame.text:SetText(L.ARROW_POSITION_REACHED)
		M.arrowFrame.text:Show()
	elseif M.arrowX == nil or M.arrowY == nil then
		M.arrowFrame.text:SetText(L.ARROW_CURRENT_STEP)
		M.arrowFrame.text:Show()
	elseif M.arrowInstance ~= D.instance then
		M.arrowFrame.text:SetText(string.format(L.ARROW_GO_TO_INSTANCE, GetRealZoneText(M.arrowInstance)))
		M.arrowFrame.text:Show()
	elseif GuidelimeData.arrowDistance then
	 	local dist = math.floor(math.sqrt(dist2))
		M.arrowFrame.text:SetText(dist .. " " .. L.YARDS)
		M.arrowFrame.text:Show()
	else
		M.arrowFrame.text:Hide()
	end
	if M.arrowFrame.element and M.arrowFrame.element.step then 
		CG.updateStepText(M.arrowFrame.element.step.index) 
	end
	if not M.arrowFrame:IsShown() then M.arrowFrame:Show() end
	M.updateArrowCount = M.updateArrowCount + 1
	if M.updateArrowCount > 500 then
		M.updateArrowCount = 0
		if M.arrowFrame.element and (M.arrowFrame.element.specialLocation == "NEAREST_FLIGHT_POINT" or M.arrowFrame.element.estimate) then
			M.updateStepsMapIcons()
		end
	end
end

function M.showArrow(element)
	if M.arrowFrame ~= nil then
		M.arrowFrame.element = element 
	end
	M.lastDistance2 = nil
end

function M.hideArrow()
	if M.arrowFrame ~= nil then 
		M.arrowFrame.element = nil
	end
end

function M.updateStepsMapIcons()
	if E.isEditorShowing() or CG.currentGuide == nil then return end
	M.removeMapIcons()
	local arrowElement
	local highlight = true
	local activeGoto
	for _, step in ipairs(CG.currentGuide.steps) do
		if not step.skip and not step.completed and step.available and
			(step.reputation == nil or D.isRequiredReputation(step.reputation, step.repMin, step.repMax)) then
			for _, element in ipairs(step.elements) do
				if element.t == "GOTO" and step.active then
					activeGoto = element
					if element.specialLocation == "NEAREST_FLIGHT_POINT" and D.wx ~= nil and D.wy ~= nil then
						local fp = FM.getNearestFlightPoint(D.wx, D.wy, D.instance, D.faction)
						for k,v in pairs(fp or {}) do element[k] = v end
						if addon.debugging then print("LIME: nearest flight point", element.x, element.y, element.mapID, element.wx, element.wy, element.instance) end
					elseif element.attached and element.attached.questId and D.wx ~= nil and D.wy ~= nil then
						CG.updatePosElement(PT.getQuestPosition(element.attached.questId, element.attached.t, CG.getQuestActiveObjectives(element.attached.questId, element.attached.objective), D), element)
						if addon.debugging and element.x then print("LIME: quest position", element.x, element.y, element.mapID, element.wx, element.wy, element.instance) end
					elseif element.attached and element.type == "COLLECT_ITEM" and D.wx ~= nil and D.wy ~= nil then
						CG.updatePosElement(PT.getItemPosition(element.attached.itemId, D), element)
						if addon.debugging and element.x then print("LIME: quest position", element.x, element.y, element.mapID, element.wx, element.wy, element.instance) end
					elseif element.attached and element.type == "TARGET" and D.wx ~= nil and D.wy ~= nil then
						CG.updatePosElement(PT.getNPCPosition(element.attached.targetNpcId, D), element)
						if addon.debugging and element.x then print("LIME: quest position", element.x, element.y, element.mapID, element.wx, element.wy, element.instance) end
					end
					if not element.completed and element.x ~= nil then
						M.addMapIcon(element, highlight)
						if highlight then
							if GuidelimeDataChar.showArrow then 
								arrowElement = element
							end
							highlight = false
						end
					end
				elseif (element.t == "LOC" or element.t == "GOTO") and 
					not element.completed and element.specialLocation == nil and 
						(element.attached == nil or not element.attached.completed) and
						(element.attached == nil or element.attached.t ~= "COMPLETE" or CG.isQuestObjectiveActive(element.attached.questId, element.objectives, element.attached.objective)) then 
					M.addMapIcon(element, false) 
				end
			end
		end
	end
	M.showArrow(arrowElement or activeGoto) 
	M.showMapIcons()
end
