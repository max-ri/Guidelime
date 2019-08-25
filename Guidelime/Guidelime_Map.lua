local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")
HBDPins = LibStub("HereBeDragons-Pins-2.0")

addon.MAX_MAP_INDEX = 59
addon.SPECIAL_MAP_INDEX = {monster = 60, item = 61, object = 62, npc = 63, LOC = 63}
addon.mapIcons = {}


local function createIconFrame(t, index, minimap)
    local f = CreateFrame("Button", addonName .. t .. index .. minimap, nil)
    f:SetFrameStrata("TOOLTIP")
	f:SetFrameLevel(index)
    f.texture = f:CreateTexture(nil, "TOOLTIP")
	addon.setMapIconTexture(f)
	if t ~= "GOTO" then
		index = addon.SPECIAL_MAP_INDEX[t]
	elseif index > addon.MAX_MAP_INDEX then
		index = addon.SPECIAL_MAP_INDEX.LOC
	end
	f.texture:SetTexCoord((index % 8) / 8, (index % 8 + 1) / 8, math.floor(index / 8) / 8, (math.floor(index / 8) + 1) / 8)
    f.texture:SetAllPoints(f)

    f:SetPoint("CENTER", 0, 0)
    f:EnableMouse(false)

    function f:Unload()
        HBDPins:RemoveMinimapIcon(addon, self);
        HBDPins:RemoveWorldMapIcon(addon, self);
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

function addon.setMapIconTexture(f)
    f.texture:SetTexture(addon.icons["MAP_MARKER_" .. GuidelimeData.mapMarkerStyle])
    f.texture:SetWidth(GuidelimeData.mapMarkerSize)
    f.texture:SetHeight(GuidelimeData.mapMarkerSize)
    f:SetWidth(GuidelimeData.mapMarkerSize)
    f:SetHeight(GuidelimeData.mapMarkerSize)
end

function addon.setMapIconTextures()
	for t, icons in pairs(addon.mapIcons) do
		for i = 0, #icons do
			if icons[i] ~= nil then
				addon.setMapIconTexture(icons[i].map)
				addon.setMapIconTexture(icons[i].minimap)
			end
		end
	end
end

local function createMapIcon(t, i)
	if i == nil then
		i = #addon.mapIcons[t] + 1
	end
	addon.mapIcons[t][i] = {}
	addon.mapIcons[t][i].map = createIconFrame(t, i, 0)
	addon.mapIcons[t][i].minimap = createIconFrame(t, i, 1)
	addon.mapIcons[t][i].index = i
	addon.mapIcons[t][i].inUse = false
	return addon.mapIcons[t][i]
end

local function getMapIcon(t, element, highlight)
	if addon.mapIcons[t] == nil then addon.mapIcons[t] = {} end
	if highlight then 
		if addon.mapIcons[t][0] == nil then createMapIcon(t, 0) end
		return addon.mapIcons[t][0] 
	end
	if addon.mapIcons[t] ~= nil then
		for i, mapIcon in ipairs(addon.mapIcons[t]) do
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

function addon.addMapIcon(element, highlight, ignoreMaxNumOfMarkers)
	local mapIcon = getMapIcon(element.markerTyp or element.t, element, highlight)
	if mapIcon == nil then return end
	if not ignoreMaxNumOfMarkers then
		if element.t == "GOTO" and mapIcon.index >= GuidelimeData.maxNumOfMarkersGOTO and GuidelimeData.maxNumOfMarkersGOTO > 0 then return end
		if not element.step.active and element.t ~= "GOTO" then return end
	end
	mapIcon.inUse = true
	mapIcon.instance = assert(element.instance)
	mapIcon.wx = assert(element.wx)
	mapIcon.wy = assert(element.wy)
	element.mapIndex = mapIcon.index
	--if addon.debugging then print("LIME : addMapIcon", element.mapID, element.x / 100, element.y / 100, highlight) end
end

function addon.removeMapIcons()
	HBDPins:RemoveAllWorldMapIcons(addon)
	HBDPins:RemoveAllMinimapIcons(addon)
	for _, icons in pairs(addon.mapIcons) do
		for i, mapIcon in pairs(icons) do
			mapIcon.inUse = false
		end
	end
	for i, step in ipairs(addon.currentGuide.steps) do
		for j, element in ipairs(step.elements) do
			element.mapIndex = nil
		end
	end
end

local function showMapIcon(mapIcon, t)
	if mapIcon ~= nil and mapIcon.inUse then
		if t ~= "GOTO" then t = "LOC" end
		if GuidelimeData["showMapMarkers" .. t] then HBDPins:AddWorldMapIconWorld(addon, mapIcon.map, mapIcon.instance, mapIcon.wx, mapIcon.wy, 3) end
		if GuidelimeData["showMinimapMarkers" .. t] then HBDPins:AddMinimapIconWorld(addon, mapIcon.minimap, mapIcon.instance, mapIcon.wx, mapIcon.wy, mapIcon.index == 0) end
	end
end

function addon.showMapIcons()
	for t, icons in pairs(addon.mapIcons) do
		for i = #icons, 0, -1 do
			showMapIcon(icons[i], t)
		end
	end
end

function addon.getMapMarkerText(element)
	local index = element.mapIndex
	if element.t ~= "GOTO" then
		index = addon.SPECIAL_MAP_INDEX[element.markerTyp or element.t]
	elseif index > addon.MAX_MAP_INDEX then
		index = addon.SPECIAL_MAP_INDEX.LOC
	end
	return "|T" .. addon.icons["MAP_MARKER_" .. GuidelimeData.mapMarkerStyle] .. ":15:15:0:1:512:512:" .. 
		index % 8 * 64 .. ":" .. (index % 8 + 1) * 64 .. ":" .. 
		math.floor(index / 8) * 64 .. ":" .. (math.floor(index / 8) + 1) * 64 .. ":::|t"
end

function addon.setArrowTexture()
	if GuidelimeData.arrowStyle == 1 then
		addon.arrowFrame.texture:SetTexture(addon.icons.MAP_LIME_ARROW)
		addon.arrowFrame.texture:SetVertexColor(1,1,1)
		addon.arrowFrame:SetHeight(64)
		addon.arrowFrame:SetWidth(64)
	elseif GuidelimeData.arrowStyle == 2 then
		addon.arrowFrame.texture:SetTexture(addon.icons.MAP_ARROW)
		addon.arrowFrame.texture:SetVertexColor(0.5,1,0.2)
		addon.arrowFrame:SetHeight(42)
		addon.arrowFrame:SetWidth(56)
	end
end

function addon.getArrowIconText()
	local col, row = 0, 0
	if addon.arrowFrame ~= nil and addon.arrowFrame.col ~= nil then col = addon.arrowFrame.col end
	if addon.arrowFrame ~= nil and addon.arrowFrame.row ~= nil then row = addon.arrowFrame.row end
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

function addon.updateArrow()
	if addon.arrowFrame ~= nil and addon.arrowX ~= nil and addon.arrowY ~= nil then
		addon.face = GetPlayerFacing()
		local angle = addon.face - math.atan2(addon.arrowX - addon.x, addon.arrowY - addon.y)
		if GuidelimeData.arrowStyle == 1 then
			local index = angle * 32 / math.pi
			if index >= 64 then index = index - 64 elseif index < 0 then index = index + 64 end
			addon.arrowFrame.col = math.floor(index % 8)
			addon.arrowFrame.row = math.floor(index / 8)
			addon.arrowFrame.texture:SetTexCoord(addon.arrowFrame.col / 8, (addon.arrowFrame.col + 1) / 8, addon.arrowFrame.row / 8, (addon.arrowFrame.row + 1) / 8)
		elseif GuidelimeData.arrowStyle == 2 then
			local index = -angle * 54 / math.pi
			if index < 0 then index = index + 108 end
			if index < 0 then index = index + 108 end
			addon.arrowFrame.col = math.floor(index % 9)
			addon.arrowFrame.row = math.floor(index / 9)
			addon.arrowFrame.texture:SetTexCoord(addon.arrowFrame.col * 56 / 512, (addon.arrowFrame.col + 1) * 56 / 512, addon.arrowFrame.row * 42 / 512, (addon.arrowFrame.row + 1) * 42 / 512)
		end
		if GuidelimeData.arrowDistance then
		 	local dist = math.floor(math.sqrt((addon.x - addon.arrowX) * (addon.x - addon.arrowX) + (addon.y - addon.arrowY) * (addon.y - addon.arrowY)))
			addon.arrowFrame.text:SetText(dist .. " " .. L.YARDS)
			addon.arrowFrame.text:Show()
		else
			addon.arrowFrame.text:Hide()
		end
	end
end

function addon.showArrow(element)
	if element.wx == nil or element.wy == nil or element.instance ~= addon.instance or addon.x == nil or addon.y == nil or addon.face == nil then return end
	addon.arrowX, addon.arrowY = element.wx, element.wy
	
	if GuidelimeDataChar.showArrow then
		if addon.arrowFrame == nil then
			addon.arrowFrame = CreateFrame("FRAME", nil, UIParent)
			addon.arrowFrame:SetWidth(64)
			addon.arrowFrame:SetHeight(64)
			addon.arrowFrame:SetPoint(GuidelimeDataChar.arrowRelative, UIParent, GuidelimeDataChar.arrowRelative, GuidelimeDataChar.arrowX, GuidelimeDataChar.arrowY)
		    addon.arrowFrame.texture = addon.arrowFrame:CreateTexture(nil, "OVERLAY")
		    addon.setArrowTexture()
		    addon.arrowFrame.texture:SetAllPoints()
			addon.arrowFrame:SetAlpha(GuidelimeDataChar.arrowAlpha)
			addon.arrowFrame:SetMovable(true)
			addon.arrowFrame:EnableMouse(true)
			addon.arrowFrame:SetScript("OnMouseDown", function(this) 
				if not GuidelimeDataChar.arrowLocked then addon.arrowFrame:StartMoving() end
			end)
			addon.arrowFrame:SetScript("OnMouseUp", function(this) 
				addon.arrowFrame:StopMovingOrSizing() 
				local _
				_, _, GuidelimeDataChar.arrowRelative, GuidelimeDataChar.arrowX, GuidelimeDataChar.arrowY = addon.arrowFrame:GetPoint()
			end)
			addon.arrowFrame.text = addon.arrowFrame:CreateFontString(nil, addon.arrowFrame, "GameFontNormal")
			addon.arrowFrame.text:SetPoint("TOP", addon.arrowFrame, "BOTTOM", 0, 0)
			addon.arrowFrame.update = CreateFrame("frame")
			addon.arrowFrame.update:SetScript("OnUpdate", addon.updateArrow)
		end
		addon.arrowFrame:Show()
	end
	addon.updateArrow()
end

function addon.hideArrow()
	if addon.arrowFrame ~= nil then addon.arrowFrame:Hide() end
end