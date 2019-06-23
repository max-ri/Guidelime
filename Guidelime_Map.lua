local addonName, addon = ...
local L = addon.L

HBD = LibStub("HereBeDragons-2.0")
HBDPins = LibStub("HereBeDragons-Pins-2.0")

addon.mapIcons = {}

local function createIconFrame(i, minimap)
    local f = CreateFrame("Button", "Guidelime" .. i .. minimap, nil)

    f:SetFrameStrata("TOOLTIP");
    f:SetWidth(16)
    f:SetHeight(16)
    f.texture = f:CreateTexture(nil, "TOOLTIP")
    f.texture:SetTexture(addon.icons.MAP .. i .. ".blp")
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
	addon.mapIcons[i] = createIconFrame(i, 0)
	addon.mapIcons[i].minimap = createIconFrame(i, 1)
	addon.mapIcons[i].index = i
	addon.mapIcons[i].inUse = false
	return addon.mapIcons[i]
end

local function getMapIcon(element)
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

function addon.addMapIcon(element)
	local mapIcon = getMapIcon(element)
	if mapIcon ~= nil then
		mapIcon.inUse = true
		mapIcon.mapID = element.mapID
		mapIcon.x = element.x
		mapIcon.y = element.y
		element.mapIndex = mapIcon.index
		--eif addon.debugging then print("Guidelime : AddWorldMapIconMap", element.mapID, element.x / 100, element.y / 100) end
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
