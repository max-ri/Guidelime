local addonName, addon = ...
local L = addon.L

function addon.addSliderOption(frame, optionsTable, option, min, max, step, text, tooltip, updateFunction, afterUpdateFunction)
    local slider = CreateFrame("Slider", addonName .. option, frame, "OptionsSliderTemplate")
	frame.options[option] = slider
    slider.editbox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
	slider:SetValue(optionsTable[option])
    slider.text = _G[addonName .. option .. "Text"]
    slider.text:SetText(text)
    slider.textLow = _G[addonName .. option .. "Low"]
    slider.textHigh = _G[addonName .. option .. "High"]
    slider.textLow:SetText(floor(min))
    slider.textHigh:SetText(floor(max))
    slider.textLow:SetTextColor(0.8,0.8,0.8)
    slider.textHigh:SetTextColor(0.8,0.8,0.8)
    slider:SetObeyStepOnDrag(true)
    slider.editbox:SetSize(45,30)
    slider.editbox:ClearAllPoints()
    slider.editbox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    slider.editbox:SetText(tostring(optionsTable[option]))
    slider.editbox:SetCursorPosition(0)
    slider.editbox:SetAutoFocus(false)
    slider:SetScript("OnValueChanged", function(self)
        slider.editbox:SetText(tostring(math.floor(slider:GetValue() * 100) / 100))
    	slider.editbox:SetCursorPosition(0)
		optionsTable[option] = slider:GetValue()
		if addon.debuggging then print("OnValueChanged", slider:GetValue()) end
		if updateFunction ~= nil then updateFunction(self) end
    end)
	slider:SetScript("OnMouseUp", function()
		if afterUpdateFunction ~= nil then afterUpdateFunction(self) end
	end)
    slider.editbox:SetScript("OnEnterPressed", function()
        local val = slider.editbox:GetText()
        if tonumber(val) then
            slider:SetValue(tonumber(val))
            slider.editbox:ClearFocus()
			optionsTable[option] = slider:GetValue()
			if addon.debuggging then print("OnEnterPressed", slider:GetValue()) end
			if updateFunction ~= nil then updateFunction(self) end
			if afterUpdateFunction ~= nil then afterUpdateFunction(self) end
        end
    end)
	if tooltip ~= nil then
		slider.tooltip = tooltip
		slider:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show(); addon.showingTooltip = true end end)
		slider:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" and addon.showingTooltip then GameTooltip:Hide(); addon.showingTooltip = false end end)
	end
    return slider
end

function addon.addCheckbox(frame, text, tooltip)
	local checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	if text ~= nil then
		checkbox.text:SetText(text)
		checkbox.text:SetFontObject("GameFontNormal")
	end
	if tooltip ~= nil then
		checkbox.tooltip = tooltip
		checkbox:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show(); addon.showingTooltip = true end end)
		checkbox:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" and addon.showingTooltip then GameTooltip:Hide(); addon.showingTooltip = false end end)
	end
	return checkbox
end

function addon.addCheckOption(frame, optionsTable, option, text, tooltip, updateFunction)
	local checkbox = addon.addCheckbox(frame, text, tooltip)
	frame.options[option] = checkbox
	if optionsTable[option] ~= false then checkbox:SetChecked(true) end
	checkbox:SetScript("OnClick", function()
		optionsTable[option] = checkbox:GetChecked() 
		if updateFunction ~= nil then updateFunction() end
	end)
	return checkbox
end

function addon.isDoubleClick(frame)
	if frame.timer == nil or frame.timer < GetTime() - 1 then
	    frame.timer = GetTime()
	elseif frame.timer ~= nil then
	    frame.timer = nil
		return true
	end
end

function addon.addMultilineText(frame, text, width, tooltip, clickFunc, doubleClickFunc)
	textbox = CreateFrame("EditBox", nil, frame)
	textbox:SetMultiLine(true)
	textbox:SetFontObject("GameFontNormal")
	if text ~= nil then textbox:SetText(text) end
	if tooltip ~= nil then
		textbox.tooltip = tooltip
		textbox:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32); GameTooltip:SetText(self.tooltip); GameTooltip:Show(); addon.showingTooltip = true end end)
		textbox:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" and addon.showingTooltip then GameTooltip:Hide(); addon.showingTooltip = false end end)
	end
	if clickFunc ~= nil or doubleClickFunc ~= nil then
		textbox:SetScript("OnMouseUp", function(self, button)
			if clickFunc ~= nil then clickFunc(self, button) end
			if doubleClickFunc ~= nil and addon.isDoubleClick(self) then
				doubleClickFunc(self, button)
			end
		end)
	end
	textbox:SetScript("OnEditFocusGained", function (self) self:ClearFocus() end)
	textbox:SetAutoFocus(false)
	textbox:SetWidth(width)

	return textbox
end

function addon.addTextbox(frame, text, width, tooltip)
	local textbox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	textbox.text = frame:CreateFontString(nil, frame, "GameFontNormal")
	textbox.text:SetText(text)
	textbox:SetFontObject("GameFontNormal")
	textbox:SetHeight(10)
	textbox:SetWidth(width)
	textbox:SetTextColor(1,1,1,1)
	if tooltip ~= nil then
		textbox.tooltip = tooltip
		textbox:SetScript("OnEnter", function(self) if self.tooltip ~= nil and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32);  GameTooltip:SetText(self.tooltip); GameTooltip:Show(); addon.showingTooltip = true end end)
		textbox:SetScript("OnLeave", function(self) if self.tooltip ~= nil and self.tooltip ~= "" and addon.showingTooltip then GameTooltip:Hide(); addon.showingTooltip = false end end)
	end
	return textbox
end

function addon.createPopupFrame(message, okFunc, hasCancel, height)
	addon.popupFrame = CreateFrame("FRAME", nil, addon.popupFrame or UIParent)
	addon.popupFrame:SetWidth(550)
	if height == nil then height = 150 end
	addon.popupFrame:SetHeight(height)
	addon.popupFrame:SetPoint("CENTER", UIParent, "CENTER")
	addon.popupFrame:SetBackdrop({
		bgFile = "Interface/Addons/" .. addonName .. "/Icons/Black", --"Interface/DialogFrame/UI-DialogBox-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		tile = false, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11}
	})
	addon.popupFrame:SetBackdropColor(0,0,0,1)
	--addon.popupFrame:SetFrameStrata("DIALOG")
	addon.popupFrame:SetFrameLevel(addon.popupFrame:GetParent():GetFrameLevel() + 2)
	addon.popupFrame:SetMovable(true)
	addon.popupFrame:SetScript("OnKeyDown", function(self,key) 
		if key == "ESCAPE" then
			self:Hide(); 
		end 
	end)
	addon.popupFrame:EnableMouse(true)
	addon.popupFrame:SetScript("OnMouseDown", function(this) this:StartMoving() end)
	addon.popupFrame:SetScript("OnMouseUp", function(this) this:StopMovingOrSizing() end)
	addon.popupFrame:SetScript("OnHide", function(self)
		if self:GetParent() ~= UIParent then addon.popupFrame = self:GetParent() else addon.popupFrame = nil end
	end)
	
	if message ~= nil then
		addon.popupFrame.message = addon.popupFrame:CreateFontString(nil, addon.popupFrame, "GameFontNormal")	
		addon.popupFrame.message:SetWidth(530)
		addon.popupFrame.message:SetWordWrap(true)
		addon.popupFrame.message:SetText(message);
		addon.popupFrame.message:SetPoint("TOP", 0, -30 )
	end

	addon.popupFrame.okBtn = CreateFrame("BUTTON", nil, addon.popupFrame, "UIPanelButtonTemplate")
	addon.popupFrame.okBtn:SetSize(128, 24)
	addon.popupFrame.okBtn:SetText( OKAY )
	if hasCancel then
		addon.popupFrame.okBtn:SetPoint("BOTTOM", addon.popupFrame, -70, 12)
	else
		addon.popupFrame.okBtn:SetPoint("BOTTOM", addon.popupFrame, 70, 12)
	end
	addon.popupFrame.okBtn:SetScript("OnClick", function(self) 
		if okFunc ~= nil and okFunc(self:GetParent()) == false then return end
		self:GetParent():Hide()
	end)

	if hasCancel then
		addon.popupFrame.cancelBtn = CreateFrame("BUTTON", nil, addon.popupFrame, "UIPanelButtonTemplate")
		addon.popupFrame.cancelBtn:SetSize(128, 24)
		addon.popupFrame.cancelBtn:SetText( CANCEL )
		addon.popupFrame.cancelBtn:SetPoint("BOTTOM", addon.popupFrame, 70, 12)
		addon.popupFrame.cancelBtn:SetScript("OnClick", function(self) 
			self:GetParent():Hide()
		end)
	end

	return addon.popupFrame
end

function addon.showUrlPopup(url)
	local popup = addon.createPopupFrame(nil, nil, false, 80)
	popup.textboxName = addon.addTextbox(popup, L.URL, 420)
	popup.textboxName.text:SetPoint("TOPLEFT", 20, -20)
	popup.textboxName:SetPoint("TOPLEFT", 120, -20)
	popup.textboxName:SetText(url)
	popup.textboxName:SetFocus()
	popup.textboxName:HighlightText(false)
	popup:Show()
end
