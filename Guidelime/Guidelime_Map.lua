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

local function createMapIcon()
	if #addon.mapIcons >= 9 then return nil end
	local i = #addon.mapIcons + 1
	addon.mapIcons[i] = createIconFrame(addon.icons.MAP .. i, 0)
	addon.mapIcons[i].minimap = createIconFrame(addon.icons.MAP .. i, 1)
	addon.mapIcons[i].index = i
	addon.mapIcons[i].inUse = false
	return addon.mapIcons[i]
end

local function getHightlightIcon()
	if addon.highlightIcon == nil then
		addon.highlightIcon = createIconFrame(addon.icons.MAP_HIGHLIGHT, 0)
		addon.highlightIcon.minimap = createIconFrame(addon.icons.MAP_HIGHLIGHT, 1)
		addon.highlightIcon.index = 0
		addon.arrowIcon = createIconFrame(addon.icons.MAP_0, 0)
		addon.arrowIcon.minimap = createIconFrame(addon.icons.MAP_0, 1)
		addon.arrowIcon.index = 0
	end
	return addon.highlightIcon
end

local function getMapIcon(element, highlight)
	if highlight then return getHighlightIcon() end
	if addon.highlightIcon ~= nil and addon.highlightIcon.inUse and addon.highlightIcon.mapID == element.mapID and addon.hightlighIcon.x == element.x and addon.highlightIcon.y == element.y then
		return addon.arrowIcon
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
	local mapIcon = getMapIcon(element)
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
		mapIcon.highlight = false
	end
	for i, step in ipairs(addon.currentGuide.steps) do
		for j, element in ipairs(step.elements) do
			element.mapIndex = nil
		end
	end
end

function addon.showMapIcons()
	for i = #addon.mapIcons, 1, -1 do
		local mapIcon = addon.mapIcons[i]
		if mapIcon.inUse then
			--if addon.debugging then print("LIME: map icon", mapIcon.mapID, mapIcon.x, mapIcon.y) end
			HBDPins:AddWorldMapIconMap(addon, mapIcon, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, 3)
			HBDPins:AddMinimapIconMap(addon, mapIcon.minimap, mapIcon.mapID, mapIcon.x / 100, mapIcon.y / 100, true, true)
		end
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