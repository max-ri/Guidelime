local addonName, addon = ...
local L = addon.L

addon.D = addon.D or {}; local D = addon.D     -- Data/Data
addon.SP = addon.SP or {}; local SP = addon.SP -- Data/SpellDB
addon.EV = addon.EV or {}; local EV = addon.EV -- Events
addon.F = addon.F or {}; local F = addon.F     -- Frames
addon.CG = addon.CG or {}; local CG = addon.CG -- CurrentGuide
addon.M = addon.M or {}; local M = addon.M     -- Map
addon.MW = addon.MW or {}; local MW = addon.MW -- MainWindow
addon.QT = addon.QT or {}; local QT = addon.QT -- Data/QuestTools

addon.AB = addon.AB or {}; local AB = addon.AB -- ActionButtons

-- for key bindings
_G["BINDING_NAME_GUIDELIME_TARGET_1"] = L.TARGET_1
_G["BINDING_NAME_GUIDELIME_USE_ITEM_1"] = string.format(L.USE_ITEM_X, 1)
for i = 2, 5 do
	_G["BINDING_NAME_GUIDELIME_TARGET_" .. i] = string.format(L.TARGET_X, i)
	_G["BINDING_NAME_GUIDELIME_USE_ITEM_" .. i] = string.format(L.USE_ITEM_X, i)
end

function AB.resetButtons(buttons)
	if not buttons then return end
	for _, button in pairs(buttons) do
		if button:IsShown() then
			if InCombatLockdown() then
				EV.updateAfterCombat = true
				return 
			end
			ClearOverrideBindings(button)
			button:Hide()
		end
	end
end

-- ordering of raid markers to use
-- default to triangle because it is green
AB.targetRaidMarkerIndex = {4, 6, 2, 3, 1, 5, 7, 8}	

function AB.getTargetButtonIconText(i, raidMarker)
	local marker = AB.targetRaidMarkerIndex[i]
	if marker and (GuidelimeData.targetRaidMarkers or raidMarker) then
		return "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_" .. marker .. ":12|t"
	end
	return "|T" .. addon.icons.TARGET_BUTTON .. ":12|t"
end

function AB.createTargetButton(i)
	local button = MW.mainFrame.targetButtons[i]
	if not button then
		button = CreateFrame("BUTTON", "GuidelimeTargetButton" .. i, MW.mainFrame, "SecureActionButtonTemplate,ActionButtonTemplate")
		button.index = i
		button:SetAttribute("type", "macro")
		button.texture = button:CreateTexture(nil, "BACKGROUND")
		button.texture:SetTexture(i == "Multi" and addon.icons.MULTI_TARGET_BUTTON or addon.icons.TARGET_BUTTON)
		button.texture:SetPoint("TOPLEFT", button, -2, 1)					
		button.texture:SetPoint("BOTTOMRIGHT", button, 2, -2)
		local marker = AB.targetRaidMarkerIndex[i]
		if GuidelimeData.targetRaidMarkers and marker then
			button.texture2 = button:CreateTexture(nil, "OVERLAY")
			button.texture2:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
			SetRaidTargetIconTexture(button.texture2, AB.targetRaidMarkerIndex[i])
			button.texture2:SetPoint("TOPLEFT", button, 20, -22)					
			button.texture2:SetPoint("BOTTOMRIGHT", button, -2, 0)
		end
		button.hotkey = button:CreateFontString(nil, "ARTWORK", "NumberFontNormalSmallGray")
		button.hotkey:SetSize(32, 10)
		button.hotkey:SetPoint("TOPRIGHT", button, 0, -1)
		button.hotkey:SetJustifyH("RIGHT")
		MW.mainFrame.targetButtons[i] = button
	end
	button:ClearAllPoints()
	return button
end

-- global function to be used in the macro: Set target marker on target if it does not have one already; remove existing marker when no target
function LIME_Mark(iconId)
	SetRaidTarget("player", iconId)
	SetRaidTarget("player", 0)
	if UnitGUID("target") and not GetRaidTargetIndex("target") then SetRaidTarget("target", iconId) end
end

local function getTargetMacro(t)
	return "/targetexact " .. t.name .. 
		(t.marker and "\n/run LIME_Mark(".. t.marker .. ")" or "")
end

local function getTargetMacroMulti(targets)
	local macro = ""
	for i, t in ipairs(targets) do
		local m = getTargetMacro(t)
		if #macro + #m + 1 > 1023 then
			if addon.debugging then print("LIME: target macro multi is too long") end
			return macro
		end
		macro = macro .. m .. "\n"
	end
	if addon.debugging then print("LIME: target macro multi length is", #macro) end
	return macro
end

local function getTooltipHint(newline, disable)
	if disable or GuidelimeData.keyBound then return "" end
	return (newline and "\n" or "") .. MW.COLOR_INACTIVE .. L.TOOLTIP_HINT_KEY_BIND_BUTTON .. "|r"
end

local function getTargetTooltip(t, last)
	return GuidelimeData.showTooltips and 
		(table.concat({string.format(L.TARGET_TOOLTIP, MW.COLOR_WHITE .. t.name .. "|r"), M.getMapTooltip(t.element)}, "\n") ..
		getTooltipHint(true, last == false))
		
end

local function getTargetTooltipMulti(targets)
	if not GuidelimeData.showTooltips then return end
	local tooltips = {}
	for i, t in ipairs(targets) do
		tooltips[i] = getTargetTooltip(t, i == #targets)
	end
	return table.concat(tooltips, "\n")
end

local function keyBindButton(button, bindingName, buttonName, functionName)
	local key = GetBindingKey(bindingName)
	if key then
		button.hotkey:SetText(_G["KEY_" .. key] or key)
		SetOverrideBindingClick(button, true, key, buttonName)
		if addon.debugging then print("LIME: binding " .. key .. " to " .. functionName) end
		GuidelimeData.keyBound = true
	end
end

function AB.updateTargetButtons()
	if not MW.mainFrame then return end
	if MW.mainFrame.targetButtons == nil then
		MW.mainFrame.targetButtons = {}
	else
		AB.resetButtons(MW.mainFrame.targetButtons)
	end
	if not GuidelimeDataChar.showTargetButtons or not CG.currentGuide or not CG.currentGuide.firstActiveIndex then return end
	local targets = {}
	local i = 1
	for s = CG.currentGuide.firstActiveIndex, CG.currentGuide.lastActiveIndex do
		local step = CG.currentGuide.steps[s]
		if step.active then
			for _, element in ipairs(step.elements) do
				if element.t == "TARGET" and element.targetNpcId > 0 and 
					(not step.targetElement or not element.generated) and 
					(not element.attached or not element.attached.completed) and
					(not element.attached or element.attached.t ~= "COMPLETE" or CG.isQuestObjectiveActive(element.attached.questId, element.objectives, element.attached.objective)) then
					if addon.debugging then print("LIME: show target button for npc", element.targetNpcId) end
					if InCombatLockdown() then
						EV.updateAfterCombat = true
						return 
					end
					local name = QT.getNPCName(element.targetNpcId)
					if name and not D.contains(targets, function(t) return t.name == name end) then
						targets[i] = {name = name, element = element, index = i, marker = GuidelimeData.targetRaidMarkers and AB.targetRaidMarkerIndex[i]}
						if GuidelimeDataChar.maxNumOfTargetButtons > 0 and i >= GuidelimeDataChar.maxNumOfTargetButtons then break end
						i = i + 1
					end
				end
			end
		end
	end
	local pos = 1
	if #targets > 1 then
		local button = AB.createTargetButton("Multi")
		button:SetPoint("TOP" .. GuidelimeDataChar.showTargetButtons, MW.mainFrame, "TOP" .. GuidelimeDataChar.showTargetButtons, 
			GuidelimeDataChar.showTargetButtons == "LEFT" and -36 or (GuidelimeDataChar.mainFrameShowScrollBar and 60 or 37), -2)
		button:SetAttribute("macrotext", "/cleartarget\n" .. getTargetMacroMulti(targets))
		F.setTooltip(button, getTargetTooltipMulti(targets))
		keyBindButton(button, "GUIDELIME_TARGET_1", "GuidelimeTargetButtonMulti", "multi target")
		button:Show()
		pos = 2
	end
	for _, t in ipairs(targets) do
		local button = AB.createTargetButton(t.index)
		t.element.targetButton = button
		button:SetPoint("TOP" .. GuidelimeDataChar.showTargetButtons, MW.mainFrame, "TOP" .. GuidelimeDataChar.showTargetButtons, 
			GuidelimeDataChar.showTargetButtons == "LEFT" and -36 or (GuidelimeDataChar.mainFrameShowScrollBar and 60 or 37), 
			39 - pos * 41)
		button.npc = t.name
		button:SetAttribute("macrotext", "/cleartarget\n" .. getTargetMacro(t))
		F.setTooltip(button, getTargetTooltip(t))
		keyBindButton(button, "GUIDELIME_TARGET_" .. pos, "GuidelimeTargetButton" .. t.index, t.name)
		button:Show()
		pos = pos + 1
	end
	AB.numberOfTargetButtons = pos - 1
end

function AB.createUseItemButton(i)
	local button = MW.mainFrame.useButtons[i]
	if not button then
		button = CreateFrame("BUTTON", "GuidelimeUseItemButton" .. i, MW.mainFrame, "SecureActionButtonTemplate,ActionButtonTemplate")
		button.texture = button:CreateTexture(nil,"BACKGROUND")
		button.texture:SetPoint("TOPLEFT", button, -2, 1)					
		button.texture:SetPoint("BOTTOMRIGHT", button, 2, -2)
		button.cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
        button.cooldown:SetSize(32, 32)
        button.cooldown:SetPoint("CENTER", button, "CENTER", 0, 0)
		button.hotkey = button:CreateFontString(nil, "ARTWORK", "NumberFontNormalSmallGray")
		button.hotkey:SetSize(32, 10)
		button.hotkey:SetPoint("TOPRIGHT", button, 0, -1)
		button.hotkey:SetJustifyH("RIGHT")
		button.count = button:CreateFontString(nil, "ARTWORK", "NumberFontNormal")
		button.count:SetPoint("BOTTOMRIGHT", button, -1, 1)
		button.count:SetJustifyH("RIGHT")
		button.Update = function(self)
            local start, duration, enable
			if self.spellId then
            	start, duration, enable = GetSpellCooldown(self.spellId)
			else
            	start, duration, enable = QT.GetItemCooldown(self.itemId)
			end
            if enable == 1 and duration > 0 then
                self.cooldown:Show()
                self.cooldown:SetCooldown(start, duration)
            else
                self.cooldown:Hide()
            end
		end
		MW.mainFrame.useButtons[i] = button
	end
	button.spellId = nil
	button.cooldown:Hide()
	button:ClearAllPoints()
	return button
end

function AB.updateUseItemButtons()
	if not MW.mainFrame then return end
	if MW.mainFrame.useButtons == nil then
		MW.mainFrame.useButtons = {}
	else
		AB.resetButtons(MW.mainFrame.useButtons)
	end
	if not GuidelimeDataChar.showUseItemButtons or not CG.currentGuide or not CG.currentGuide.firstActiveIndex then return end
	local i = 1
	local startPos = GuidelimeDataChar.showUseItemButtons == GuidelimeDataChar.showTargetButtons and AB.numberOfTargetButtons and AB.numberOfTargetButtons > 0 and (AB.numberOfTargetButtons * 42 + 5) or 0
	local previousIds = {}
	for s = CG.currentGuide.firstActiveIndex, CG.currentGuide.lastActiveIndex do
		local step = CG.currentGuide.steps[s]
		if step.active then
			for _, element in ipairs(step.elements) do
				if element.t == "USE_ITEM" and element.useItemId > 0 and
					not (step.useItemElement and element.generated) and not (element.attached and element.attached.completed) and
					not D.contains(previousIds, element.useItemId) then
					if addon.debugging then print("LIME: show use item button for item", element.useItemId) end
					if InCombatLockdown() then
						EV.updateAfterCombat = true
						return 
					end
					local button = AB.createUseItemButton(i)
					button:SetPoint("TOP" .. GuidelimeDataChar.showUseItemButtons, MW.mainFrame, "TOP" .. GuidelimeDataChar.showUseItemButtons, 
						GuidelimeDataChar.showUseItemButtons == "LEFT" and -36 or (GuidelimeDataChar.mainFrameShowScrollBar and 60 or 37), 
						39 - i * 41 - startPos)
					button.itemId = element.useItemId
					button.texture:SetTexture(GetItemIcon(button.itemId))
					local count = GetItemCount(button.itemId)
					button.count:SetText(count > 1 and count or "")
					button.texture:SetAlpha((count > 0 and 1) or 0.2)
					local name = QT.getItemName(button.itemId)
					if name then
						button:SetAttribute("type", "item")
						button:SetAttribute("item", name)
						--F.setTooltip(button, name .. "\n" .. (QT.getUseItemTooltip(button.itemId) or ""))
						F.setTooltip(button, "item:" .. button.itemId, function(self, s) 
							GameTooltip:SetHyperlink(s)
							GameTooltip:AddLine(getTooltipHint())
						end)
						keyBindButton(button, "GUIDELIME_USE_ITEM_" .. i, "GuidelimeUseItemButton" .. i, name)
					end
					button:Show()
					button:Update()
					table.insert(previousIds, element.useItemId)
					i = i + 1
				elseif element.t == "SPELL" and element.spellId ~= 0 and not element.completed then
					local id = element.spellId or SP.getSpellId(element.spell)
					if addon.debugging then print("LIME: show button for spell", id) end
					if InCombatLockdown() then
						EV.updateAfterCombat = true
						return 
					end
					local name, _, icon = GetSpellInfo(id)
					if name then
						local button = AB.createUseItemButton(i)
						button:SetPoint("TOP" .. GuidelimeDataChar.showUseItemButtons, MW.mainFrame, "TOP" .. GuidelimeDataChar.showUseItemButtons, 
							GuidelimeDataChar.showUseItemButtons == "LEFT" and -36 or (GuidelimeDataChar.mainFrameShowScrollBar and 60 or 37), 
							39 - i * 41 - startPos)
						button.spellId = id
						button.texture:SetTexture(icon or addon.icons.SPELL)
						button.texture:SetAlpha(1)
						button:SetAttribute("type", "spell")
						button:SetAttribute("spell", name)
						if not IsSpellKnown(id) then
							local index = SP.getTradeSkillIndex(name)
							if index then
								button:SetAttribute("type", "macro")
								button:SetAttribute("macrotext", "/run DoTradeSkill(" .. index .. ")")
								local count = select(3, GetTradeSkillInfo(index))
								button.count:SetText(count)
								button.texture:SetAlpha((count > 0 and 1) or 0.2)
							else
								button:SetAlpha(0.2)
							end
						end
						F.setTooltip(button, "spell:" .. id, function(self, s) 
							GameTooltip:SetHyperlink(s)
							GameTooltip:AddLine(getTooltipHint())
						end)
						keyBindButton(button, "GUIDELIME_USE_ITEM_" .. i, "GuidelimeUseItemButton" .. i, name)
						button:Show()
						button:Update()
						if GuidelimeDataChar.maxNumOfItemButtons > 0 and i >= GuidelimeDataChar.maxNumOfItemButtons then break end
						i = i + 1
					end
				end
			end
		end
	end
end