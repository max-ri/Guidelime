local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")
HBDPins = LibStub("HereBeDragons-Pins-2.0")

addon.mapIcons = {}

local function createIconFrame(index, minimap)
    local f = CreateFrame("Button", addonName .. index .. minimap, nil)

    f:SetFrameStrata("TOOLTIP");
    f:SetWidth(16)
    f:SetHeight(16)
    f.texture = f:CreateTexture(nil, "TOOLTIP")
    f.texture:SetTexture(addon.icons.MAP_MARKER)
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

local function createMapIcon(i)
	if i == nil then
		if #addon.mapIcons >= 63 then return nil end
		i = #addon.mapIcons + 1
	end
	addon.mapIcons[i] = createIconFrame(i, 0)
	addon.mapIcons[i].minimap = createIconFrame(i, 1)
	addon.mapIcons[i].index = i
	addon.mapIcons[i].inUse = false
	return addon.mapIcons[i]
end

local function getMapIcon(element, highlight)
	if highlight then 
		if addon.mapIcons[0] == nil then createMapIcon(0) end
		return addon.mapIcons[0] 
	end
	for i, mapIcon in ipairs(addon.mapIcons) do
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

function addon.addMapIcon(element, highlight)
	local mapIcon = getMapIcon(element, highlight)
	if mapIcon ~= nil and mapIcon.index < GuidelimeData.maxNumOfMarkers then
		mapIcon.inUse = true
		mapIcon.mapID = element.mapID
		mapIcon.x = assert(element.x)
		mapIcon.y = assert(element.y)
		element.mapIndex = mapIcon.index
		--if addon.debugging then print("LIME : addMapIcon", element.mapID, element.x / 100, element.y / 100, highlight) end
	end
end

function addon.removeMapIcons()
	HBDPins:RemoveAllWorldMapIcons(addon)
	HBDPins:RemoveAllMinimapIcons(addon)
	for i, mapIcon in pairs(addon.mapIcons) do
		mapIcon.inUse = false
	end
	for i, step in ipairs(addon.currentGuide.steps) do
		for j, element in ipairs(step.elements) do
			element.mapIndex = nil
		end
	end
end

local function showMapIcon(mapIcon)
	if mapIcon ~= nil and mapIcon.inUse then
		--if addon.debugging then print("LIME: map icon", mapIcon.mapID, mapIcon.x, mapIcon.y) end
		HBDPins:AddWorldMapIconMap(addon, mapIcon, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, 3)
		HBDPins:AddMinimapIconMap(addon, mapIcon.minimap, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, true, true)
	end
end

function addon.showMapIcons()
	for i = #addon.mapIcons, 0, -1 do
		showMapIcon(addon.mapIcons[i])
	end
end

function addon.updateArrow()
	if addon.arrowFrame ~= nil then
		local angle = addon.face - math.atan2(addon.arrowX - addon.x, addon.arrowY - addon.y)
		local index = angle * 32 / math.pi
		if index >= 64 then index = index - 64 elseif index < 0 then index = index + 64 end
		addon.arrowFrame.col = math.floor(index % 8)
		addon.arrowFrame.row = math.floor(index / 8)
		addon.arrowFrame.texture:SetTexCoord(addon.arrowFrame.col / 8, (addon.arrowFrame.col + 1) / 8, addon.arrowFrame.row / 8, (addon.arrowFrame.row + 1) / 8)
		--if addon.debugging then print("lime: arrow", angle) end
	end
end

function addon.showArrow(element)
	if element.x == nil or element.y == nil or element.mapID == nil or addon.x == nil or addon.y == nil or addon.face == nil then return end
	
	if GuidelimeDataChar.showArrow then
		if addon.arrowFrame == nil then
			addon.arrowFrame = CreateFrame("FRAME", nil, UIParent)
			addon.arrowFrame:SetWidth(64)
			addon.arrowFrame:SetHeight(64)
			addon.arrowFrame:SetPoint(GuidelimeDataChar.arrowRelative, UIParent, GuidelimeDataChar.arrowRelative, GuidelimeDataChar.arrowX, GuidelimeDataChar.arrowY)
		    addon.arrowFrame.texture = addon.arrowFrame:CreateTexture(nil, "OVERLAY")
		    addon.arrowFrame.texture:SetTexture("Interface/Addons/" .. addonName .. "/Icons/lime_arrow")
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
		addon.arrowX, addon.arrowY = HBD:GetWorldCoordinatesFromZone(element.x / 100, element.y / 100, element.mapID)
		addon.arrowFrame:Show()
	end
	addon.updateArrow()
end

function addon.hideArrow()
	if addon.arrowFrame ~= nil then addon.arrowFrame:Hide() end
end