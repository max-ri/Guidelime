local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")
HBDPins = LibStub("HereBeDragons-Pins-2.0")

addon.mapIcons = {}

local function createIconFrame(t, index, minimap)
    local f = CreateFrame("Button", addonName .. t .. index .. minimap, nil)
    f:SetFrameStrata("TOOLTIP")
	f:SetFrameLevel(index)
    f:SetWidth(16)
    f:SetHeight(16)
    f.texture = f:CreateTexture(nil, "TOOLTIP")
    f.texture:SetTexture(addon.icons.MAP_MARKER)
	if index >= 64 or t == "LOC" then index = 63 end
	f.texture:SetTexCoord((index % 8) / 8, (index % 8 + 1) / 8, math.floor(index / 8) / 8, (math.floor(index / 8) + 1) / 8)
    f.texture:SetWidth(16)
    f.texture:SetHeight(16)
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

local function getMapIcon(element, highlight)
	if addon.mapIcons[element.t] == nil then addon.mapIcons[element.t] = {} end
	if highlight then 
		if addon.mapIcons[element.t][0] == nil then createMapIcon(element.t, 0) end
		return addon.mapIcons[element.t][0] 
	end
	if addon.mapIcons[element.t] ~= nil then
		for i, mapIcon in ipairs(addon.mapIcons[element.t]) do
			if mapIcon.inUse then 
				if mapIcon.mapID == element.mapID and mapIcon.x == element.x and mapIcon.y == element.y then
					return mapIcon
				end
			else
				return mapIcon
			end
		end
	end
	return createMapIcon(element.t)		
end

function addon.addMapIcon(element, highlight, ignoreMaxNumOfMarkers)
	local mapIcon = getMapIcon(element, highlight)
	if mapIcon == nil then return end
	if not ignoreMaxNumOfMarkers and 
		not element.step.active and 
		GuidelimeData["maxNumOfSteps" .. element.t] ~= 0 and 
		element.step.index - addon.currentGuide.lastActiveIndex >= GuidelimeData["maxNumOfSteps" .. element.t] then 
		return 
	end
	mapIcon.inUse = true
	mapIcon.mapID = element.mapID
	mapIcon.x = assert(element.x)
	mapIcon.y = assert(element.y)
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

local function showMapIcon(mapIcon)
	if mapIcon ~= nil and mapIcon.inUse then
		local x, y, instance = HBD:GetWorldCoordinatesFromZone(mapIcon.x / 100, mapIcon.y / 100, mapIcon.mapID)
		if x ~= nil then
			HBDPins:AddWorldMapIconWorld(addon, mapIcon.map, instance, x, y, 3)
			HBDPins:AddMinimapIconWorld(addon, mapIcon.minimap, instance, x, y, mapIcon.index == 0)
		elseif addon.debugging then
			print("LIME: error transforming coordinates", mapIcon.x, mapIcon.y, mapIcon.mapID)
		end
	end
end

function addon.showMapIcons()
	for _, icons in pairs(addon.mapIcons) do
		for i = #icons, 0, -1 do
			showMapIcon(icons[i])
		end
	end
end

function addon.getMapMarkerText(element)
	local index = element.mapIndex
	if index >= 64 or element.t == "LOC" then index = 63 end
	return "|T" .. addon.icons.MAP_MARKER .. ":15:15:0:1:512:512:" .. 
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
	if GuidelimeData.arrowStyle == 1 then
		return "|T" .. addon.icons.MAP_LIME_ARROW .. ":15:15:0:1:512:512:" .. 
			addon.arrowFrame.col * 64 .. ":" .. (addon.arrowFrame.col + 1) * 64 .. ":" .. 
			addon.arrowFrame.row * 64 .. ":" .. (addon.arrowFrame.row + 1) * 64 .. ":::|t"
	elseif GuidelimeData.arrowStyle == 2 then
		return "|T" .. addon.icons.MAP_ARROW .. ":15:15:0:1:512:512:" .. 
			addon.arrowFrame.col * 56 .. ":" .. (addon.arrowFrame.col + 1) * 56 .. ":" .. 
			addon.arrowFrame.row * 42 .. ":" .. (addon.arrowFrame.row + 1) * 42 .. ":127:255:51|t"
	end
end

function addon.updateArrow()
	if addon.arrowFrame ~= nil then
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
	end
end

function addon.showArrow(element)
	if element.x == nil or element.y == nil or element.mapID == nil or addon.x == nil or addon.y == nil or addon.face == nil then return end
	addon.arrowX, addon.arrowY = HBD:GetWorldCoordinatesFromZone(element.x / 100, element.y / 100, element.mapID)
	if addon.arrowX == nil or addon.arrowY == nil then return end
	
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
				addon.arrowFrame:StartMoving()
			end)
			addon.arrowFrame:SetScript("OnMouseUp", function(this) 
				addon.arrowFrame:StopMovingOrSizing() 
				local _
				_, _, GuidelimeDataChar.arrowRelative, GuidelimeDataChar.arrowX, GuidelimeDataChar.arrowY = addon.arrowFrame:GetPoint()
			end)
		end
		addon.arrowFrame:Show()
	end
	addon.updateArrow()
end

function addon.hideArrow()
	if addon.arrowFrame ~= nil then addon.arrowFrame:Hide() end
end