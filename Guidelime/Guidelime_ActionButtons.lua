local addonName, addon = ...
local L = addon.L

-- for key bindings
BINDING_HEADER_GUIDELIME = "Guidelime"
BINDING_NAME_GUIDELIME_TOGGLE = L.SHOW_MAINFRAME
BINDING_NAME_GUIDELIME_TARGET_1 = string.format(L.TARGET_X, 1)
BINDING_NAME_GUIDELIME_TARGET_2 = string.format(L.TARGET_X, 2)
BINDING_NAME_GUIDELIME_TARGET_3 = string.format(L.TARGET_X, 3)
BINDING_NAME_GUIDELIME_TARGET_4 = string.format(L.TARGET_X, 4)
BINDING_NAME_GUIDELIME_TARGET_5 = string.format(L.TARGET_X, 5)
BINDING_NAME_GUIDELIME_USE_ITEM_1 = string.format(L.USE_ITEM_X, 1)
BINDING_NAME_GUIDELIME_USE_ITEM_2 = string.format(L.USE_ITEM_X, 2)
BINDING_NAME_GUIDELIME_USE_ITEM_3 = string.format(L.USE_ITEM_X, 3)
BINDING_NAME_GUIDELIME_USE_ITEM_4 = string.format(L.USE_ITEM_X, 4)
BINDING_NAME_GUIDELIME_USE_ITEM_5 = string.format(L.USE_ITEM_X, 5)

function addon.resetButtons(buttons)
	if not buttons then return end
	for _, button in pairs(buttons) do
		if button:IsShown() then
			if InCombatLockdown() then
				addon.updateAfterCombat = true
				return 
			end
			ClearOverrideBindings(button)
			button:Hide()
		end
	end
end

-- ordering of raid markers to use
-- default to triangle because it is green
addon.targetRaidMarkerIndex = {4, 6, 2, 3, 1, 5, 7, 8}	

function addon.getTargetButtonIconText(i, raidMarker)
	local marker = addon.targetRaidMarkerIndex[i]
	if marker and (GuidelimeData.targetRaidMarkersor or raidMarker) then
		local x1, y1 = (marker - 1) % 4 * 0.25, marker > 4 and 0.25 or 0
		local x2, y2 = x1 + 0.25, y1 + 0.25
		return "|TInterface\\TargetingFrame\\UI-RaidTargetingIcons:12:12:0:0:512:512:" .. (x1*512) .. ":" .. (x2*512) .. ":" .. (y1*512) .. ":".. (y2*512) .. "|t"
	end
	return "|T" .. addon.icons.TARGET_BUTTON .. ":12|t"
end

function addon.createTargetButton(i)
	local button = addon.mainFrame.targetButtons[i]
	if not button then
		button = CreateFrame("BUTTON", "GuidelimeTargetButton" .. i, addon.mainFrame, "SecureActionButtonTemplate,ActionButtonTemplate")
		button.index = i
		button:SetAttribute("type", "macro")
		button.texture = button:CreateTexture(nil, "BACKGROUND")
		button.texture:SetTexture(addon.icons.TARGET_BUTTON)
		button.texture:SetPoint("TOPLEFT", button, -2, 1)					
		button.texture:SetPoint("BOTTOMRIGHT", button, 2, -2)
		local marker = addon.targetRaidMarkerIndex[i]
		if GuidelimeData.targetRaidMarkers and marker then
			button.texture2 = button:CreateTexture(nil, "OVERLAY")
			button.texture2:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
			SetRaidTargetIconTexture(button.texture2, addon.targetRaidMarkerIndex[i])
			button.texture2:SetPoint("TOPLEFT", button, 20, -22)					
			button.texture2:SetPoint("BOTTOMRIGHT", button, -2, 0)
		end
		button.hotkey = button:CreateFontString(nil, button, "NumberFontNormalSmallGray")
		button.hotkey:SetSize(32, 10)
		button.hotkey:SetPoint("TOPRIGHT", button, 0, -1)
		button.hotkey:SetJustifyH("RIGHT")
		addon.mainFrame.targetButtons[i] = button
	end
	button:ClearAllPoints()
	return button
end

function addon.updateTargetButtons()
	if not addon.mainFrame then return end
	if addon.mainFrame.targetButtons == nil then
		addon.mainFrame.targetButtons = {}
	else
		addon.resetButtons(addon.mainFrame.targetButtons)
	end
	if not GuidelimeDataChar.showTargetButtons or not addon.currentGuide or not addon.currentGuide.firstActiveIndex then return end
	local i = 1
	for s = addon.currentGuide.firstActiveIndex, addon.currentGuide.lastActiveIndex do
		local step = addon.currentGuide.steps[s]
		if step.active then
			for _, element in ipairs(step.elements) do
				if element.t == "TARGET" and element.targetNpcId > 0 and not (step.targetElement and element.generated) and not (element.attached and element.attached.completed) then
					if addon.debugging then print("LIME: show target button for npc", element.targetNpcId) end
					if InCombatLockdown() then
						addon.updateAfterCombat = true
						return 
					end
					local button = addon.createTargetButton(i)
					element.targetButton = button
					button:SetPoint("TOP" .. GuidelimeDataChar.showTargetButtons, addon.mainFrame, "TOP" .. GuidelimeDataChar.showTargetButtons, 
						GuidelimeDataChar.showTargetButtons == "LEFT" and -36 or (GuidelimeDataChar.mainFrameShowScrollBar and 60 or 37), 
						41 - i * 42)
					local name = addon.getNPCName(element.targetNpcId)
					local marker = addon.targetRaidMarkerIndex[i]
					if name then
						if button.npc and name ~= button.npc then button.previousNpc = button.npc end
						button.npc = name
						button:SetAttribute("macrotext", 
							(GuidelimeData.targetRaidMarkers and marker and button.previousNpc and 
							"/cleartarget\n" ..
							"/targetexact " .. button.previousNpc .. "\n" ..
							"/script if UnitExists('target') and GetRaidTargetIndex('target') == " .. marker .. " then SetRaidTarget('target', 0) end\n"
							or "") ..
							"/cleartarget\n" ..
							"/targetexact " .. name .. "\n" ..
							(GuidelimeData.targetRaidMarkers and marker and 
							"/script if GetRaidTargetIndex('target') ~= " .. marker .. " then SetRaidTarget('target', " .. marker .. ") end"
							or "")
						)
						addon.setTooltip(button, string.format(L.TARGET_TOOLTIP, name))
						local key = GetBindingKey("GUIDELIME_TARGET_" .. i)
						if key then
							button.hotkey:SetText(_G["KEY_" .. key] or key)
							SetOverrideBindingClick(button, true, key, "GuidelimeTargetButton" .. i)
							if addon.debugging then print("LIME: binding " .. key .. " to target " .. name) end
						end
					end
					button:Show()
					i = i + 1
				end
			end
		end
	end
	addon.numberOfTargetButtons = i - 1
end

function addon.createUseItemButton(i)
	local button = addon.mainFrame.useButtons[i]
	if not button then
		button = CreateFrame("BUTTON", "GuidelimeUseItemButton" .. i, addon.mainFrame, "SecureActionButtonTemplate,ActionButtonTemplate")
		button:SetAttribute("type", "item")
		button.texture = button:CreateTexture(nil,"BACKGROUND")
		button.texture:SetPoint("TOPLEFT", button, -2, 1)					
		button.texture:SetPoint("BOTTOMRIGHT", button, 2, -2)
		button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        button.cooldown:SetSize(32, 32)
        button.cooldown:SetPoint("CENTER", button, "CENTER", 0, 0)
		button.hotkey = button:CreateFontString(nil, button, "NumberFontNormalSmallGray")
		button.hotkey:SetSize(32, 10)
		button.hotkey:SetPoint("TOPRIGHT", button, 0, -1)
		button.hotkey:SetJustifyH("RIGHT")
		button.count = button:CreateFontString(nil, button, "NumberFontNormal")
		button.count:SetPoint("BOTTOMRIGHT", button, -1, 1)
		button.count:SetJustifyH("RIGHT")
		button.Update = function(self)
            local start, duration, enable = GetItemCooldown(self.itemId)
            if enable == 1 and duration > 0 then
                self.cooldown:Show()
                self.cooldown:SetCooldown(start, duration)
            else
                self.cooldown:Hide()
            end
		end
		addon.mainFrame.useButtons[i] = button
	end
	button.cooldown:Hide()
	button:ClearAllPoints()
	return button
end

function addon.updateUseItemButtons()
	if not addon.mainFrame then return end
	if addon.mainFrame.useButtons == nil then
		addon.mainFrame.useButtons = {}
	else
		addon.resetButtons(addon.mainFrame.useButtons)
	end
	if not GuidelimeDataChar.showUseItemButtons or not addon.currentGuide or not addon.currentGuide.firstActiveIndex then return end
	local i = 1
	local startIndex = GuidelimeDataChar.showUseItemButtons == GuidelimeDataChar.showTargetButtons and addon.numberOfTargetButtons or 0
	for s = addon.currentGuide.firstActiveIndex, addon.currentGuide.lastActiveIndex do
		local step = addon.currentGuide.steps[s]
		if step.active then
			for _, element in ipairs(step.elements) do
				if element.t == "USE_ITEM" and element.useItemId > 0 and not (step.useItemElement and element.generated) and not (element.attached and element.attached.completed) then
					if addon.debugging then print("LIME: show use item button for item", element.useItemId) end
					if InCombatLockdown() then
						addon.updateAfterCombat = true
						return 
					end
					local button = addon.createUseItemButton(i)
					button:SetPoint("TOP" .. GuidelimeDataChar.showUseItemButtons, addon.mainFrame, "TOP" .. GuidelimeDataChar.showUseItemButtons, 
						GuidelimeDataChar.showUseItemButtons == "LEFT" and -36 or (GuidelimeDataChar.mainFrameShowScrollBar and 60 or 37), 
						41 - (i + startIndex) * 42)
					button.itemId = element.useItemId
					button.texture:SetTexture(GetItemIcon(button.itemId))
					local count = GetItemCount(button.itemId)
					button.count:SetText(count > 1 and count or "")
					local enabled = count > 0
					button.texture:SetAlpha((enabled and 1) or 0.2)
					local name = addon.getItemName(button.itemId)
					if name then
						button:SetAttribute("item", name)
						--addon.setTooltip(button, name .. "\n" .. (addon.getUseItemTooltip(button.itemId) or ""))
						addon.setTooltip(button, "item:" .. button.itemId .. ":0:0:0:0:0:0:0", GameTooltip.SetHyperlink)
						local key = GetBindingKey("GUIDELIME_USE_ITEM_" .. i)
						if key then
							button.hotkey:SetText(_G["KEY_" .. key] or key)
							SetOverrideBindingClick(button, true, key, "GuidelimeUseItemButton" .. i)
							if addon.debugging then print("LIME: binding " .. key .. " to " .. name) end
						end
					end
					button:Show()
					button:Update()
					i = i + 1
				end
			end
		end
	end
end
