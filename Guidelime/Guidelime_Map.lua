local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")
HBDPins = LibStub("HereBeDragons-Pins-2.0")

addon.mapIcons = {}

local function createIconFrame(texture, minimap)
    local f = CreateFrame("Button", "Guidelime" .. texture .. minimap, nil)

    f:SetFrameStrata("TOOLTIP");
    f:SetWidth(16)
    f:SetHeight(16)
    f.texture = f:CreateTexture(nil, "TOOLTIP")
    f.texture:SetTexture(texture)
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

local function createMapIcon(i)
	if i == nil then
		if #addon.mapIcons >= 9 then return nil end
		i = #addon.mapIcons + 1
	end
	addon.mapIcons[i] = createIconFrame(addon.icons.MAP .. i, 0)
	addon.mapIcons[i].minimap = createIconFrame(addon.icons.MAP .. i, 1)
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
	if mapIcon ~= nil then
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
	for i, mapIcon in ipairs(addon.mapIcons) do
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
	for i = #addon.mapIcons + 1, 0, -1 do
		showMapIcon(addon.mapIcons[i])
	end
end

function addon.showArrow(element)
	if element.x == nil or element.y == nil or element.mapID == nil or addon.x == nil or addon.y == nil then return end
	local x, y = HBD:GetWorldCoordinatesFromZone(element.x / 100, element.y / 100, element.mapID)
	local angle = math.atan2(x - addon.x, y - addon.y)
	if addon.debugging then print("LIME: arrow", x, y, addon.x, addon.y, angle) end
	--todo
end

function addon.hideArrow()
end