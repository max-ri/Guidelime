local addonName, addon = ...
local L = addon.L

addon.F = addon.F or {}; local F = addon.F

function F.setTooltip(frame, tooltip, setupFunction)
	frame.tooltip = tooltip
	if tooltip then	
		frame:SetScript("OnEnter", function(self) if self.tooltip and self.tooltip ~= "" then GameTooltip:SetOwner(self, "ANCHOR_RIGHT",0,-32); (setupFunction or GameTooltip.SetText)(GameTooltip, self.tooltip); GameTooltip:Show(); F.showingTooltip = true end end)
		frame:SetScript("OnLeave", function(self) if self.tooltip and self.tooltip ~= "" and F.showingTooltip then GameTooltip:Hide(); F.showingTooltip = false end end)
	end
end

function F.addSliderOption(frame, optionsTable, option, min, max, step, text, tooltip, updateFunction, afterUpdateFunction)
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
	F.setTooltip(slider, tooltip)
    return slider
end

function F.addCheckbox(frame, text, tooltip)
	local checkbox = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	if text ~= nil then
		local textString = checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		textString:SetText(text)
		textString:SetPoint("LEFT", checkbox, "RIGHT", 0, 0)
		checkbox:SetFontString(textString)
	end
	F.setTooltip(checkbox, tooltip)
	return checkbox
end

function F.addCheckOption(frame, optionsTable, option, text, tooltip, updateFunction)
	local checkbox = F.addCheckbox(frame, text, tooltip)
	frame.options[option] = checkbox
	if optionsTable[option] ~= false then checkbox:SetChecked(true) end
	checkbox:SetScript("OnClick", function()
		optionsTable[option] = checkbox:GetChecked() 
		if updateFunction ~= nil then updateFunction() end
	end)
	return checkbox
end

function F.isDoubleClick(frame)
	if frame.timer == nil or frame.timer < GetTime() - 1 then
	    frame.timer = GetTime()
	elseif frame.timer ~= nil then
	    frame.timer = nil
		return true
	end
end

function F.addMultilineText(frame, text, width, tooltip, clickFunc, doubleClickFunc)
	textbox = CreateFrame("EditBox", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
	textbox:SetMultiLine(true)
	textbox:SetFontObject("GameFontNormal")
	if text ~= nil then textbox:SetText(text) end
	F.setTooltip(textbox, tooltip)
	if clickFunc ~= nil or doubleClickFunc ~= nil then
		textbox:SetScript("OnMouseUp", function(self, button)
			if clickFunc ~= nil then clickFunc(self, button) end
			if doubleClickFunc ~= nil and F.isDoubleClick(self) then
				doubleClickFunc(self, button)
			end
		end)
	end
	textbox:SetScript("OnEditFocusGained", function (self) self:ClearFocus() end)
	textbox:SetAutoFocus(false)
	if width then textbox:SetWidth(width) end

	return textbox
end

function F.addTextbox(frame, text, width, tooltip)
	local textbox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
	textbox.text = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	textbox.text:SetText(text)
	textbox:SetFontObject("GameFontNormal")
	textbox:SetHeight(10)
	textbox:SetWidth(width)
	textbox:SetTextColor(1,1,1,1)
	F.setTooltip(textbox, tooltip)
	return textbox
end

function F.createPopupFrame(message, okFunc, hasCancel, height)
	F.popupFrame = CreateFrame("FRAME", nil, F.popupFrame or UIParent, BackdropTemplateMixin and "BackdropTemplate")
	F.popupFrame:SetWidth(550)
	if height == nil then height = 150 end
	F.popupFrame:SetHeight(height)
	F.popupFrame:SetPoint("CENTER", UIParent, "CENTER")
	F.popupFrame:SetBackdrop({
		bgFile = "Interface/Addons/" .. addonName .. "/Icons/Black", --"Interface/DialogFrame/UI-DialogBox-Background",
		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
		tile = false, edgeSize = 32,
		insets = { left = 11, right = 12, top = 12, bottom = 11}
	})
	F.popupFrame:SetBackdropColor(0,0,0,1)
	F.popupFrame:SetFrameStrata("DIALOG")
	F.popupFrame:SetFrameLevel(F.popupFrame:GetParent():GetFrameLevel() + 2)
	F.popupFrame:SetMovable(true)
	F.popupFrame:SetScript("OnKeyDown", function(self,key) 
		if key == "ESCAPE" then
			self:Hide(); 
		end 
	end)
	F.popupFrame:EnableMouse(true)
	F.popupFrame:SetScript("OnMouseDown", function(this) this:StartMoving() end)
	F.popupFrame:SetScript("OnMouseUp", function(this) this:StopMovingOrSizing() end)
	F.popupFrame:SetScript("OnHide", function(self)
		if self:GetParent() ~= UIParent then F.popupFrame = self:GetParent() else F.popupFrame = nil end
	end)
	
	if message ~= nil then
		F.popupFrame.message = F.popupFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")	
		F.popupFrame.message:SetWidth(530)
		F.popupFrame.message:SetWordWrap(true)
		F.popupFrame.message:SetText(message);
		F.popupFrame.message:SetPoint("TOP", 0, -30 )
	end

	F.popupFrame.okBtn = CreateFrame("BUTTON", nil, F.popupFrame, "UIPanelButtonTemplate")
	F.popupFrame.okBtn:SetSize(128, 24)
	F.popupFrame.okBtn:SetText( OKAY )
	if hasCancel then
		F.popupFrame.okBtn:SetPoint("BOTTOM", F.popupFrame, -70, 12)
	else
		F.popupFrame.okBtn:SetPoint("BOTTOM", F.popupFrame, 70, 12)
	end
	F.popupFrame.okBtn:SetScript("OnClick", function(self) 
		if okFunc ~= nil and okFunc(self:GetParent()) == false then return end
		self:GetParent():Hide()
	end)

	if hasCancel then
		F.popupFrame.cancelBtn = CreateFrame("BUTTON", nil, F.popupFrame, "UIPanelButtonTemplate")
		F.popupFrame.cancelBtn:SetSize(128, 24)
		F.popupFrame.cancelBtn:SetText( CANCEL )
		F.popupFrame.cancelBtn:SetPoint("BOTTOM", F.popupFrame, 70, 12)
		F.popupFrame.cancelBtn:SetScript("OnClick", function(self) 
			self:GetParent():Hide()
		end)
	end

	return F.popupFrame
end

function F.showUrlPopup(url)
	return F.showCopyPopup(url, L.URL, 100, 120, true)
end

function F.showCopyPopup(value, text, textwidth, height, multiline)
	local popup = F.createPopupFrame(nil, nil, false, height)
	if multiline then
    	local scrollFrame = CreateFrame("ScrollFrame", nil, popup, "UIPanelScrollFrameTemplate")
    	scrollFrame:SetPoint("TOPLEFT", popup, "TOPLEFT", 0, -20)
    	scrollFrame:SetPoint("RIGHT", popup, "RIGHT", -30, 0)
    	scrollFrame:SetPoint("BOTTOM", popup, "BOTTOM", 0, 40)
    	local content = CreateFrame("Frame", nil, scrollFrame) 
    	content:SetSize(1, 1) 
    	scrollFrame:SetScrollChild(content)
		popup.textbox = CreateFrame("EditBox", nil, content)
		popup.textbox:SetMultiLine(true)
		popup.textbox:SetFontObject("GameFontNormal")
		popup.textbox:SetWidth(550 - textwidth - 30)
		popup.textbox.text = popup:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		popup.textbox.text:SetText(text)
	else
		popup.textbox = F.addTextbox(popup, text, 550 - textwidth - 30)
	end
	popup.textbox.text:SetPoint("TOPLEFT", 20, -20)
	popup.textbox:SetPoint("TOPLEFT", 20 + textwidth, -20)
	popup.textbox:SetText(value)
	popup.textbox:SetFocus()
	popup.textbox:HighlightText()
	popup:Show()
	return popup
end

function F.SetResizeBounds(frame, minW, minH, maxW, maxH)
	if frame.SetResizeBounds ~= nil then
		frame:SetResizeBounds(minW, minH, maxW, maxH)
	else
		frame:SetMinResize(minW, minH)
		if maxW ~= nil or maxH ~= nil then frame:SetMaxResize(max) end
	end
end
