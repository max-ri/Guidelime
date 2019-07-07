local addonName, addon = ...
local L = addon.L

function addon.fillEditor()
	addon.editorFrame = CreateFrame("FRAME", nil, addon.guidesFrame)
	addon.editorFrame.name = L.EDITOR
	addon.editorFrame.parent = addonName
	InterfaceOptions_AddCategory(addon.editorFrame)

	addon.editorFrame.title = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
	addon.editorFrame.title:SetText(addonName .. " |cFFFFFFFF" .. GetAddOnMetadata(addonName, "version") .." - " .. L.EDITOR)
	addon.editorFrame.title:SetPoint("TOPLEFT", 20, -20)
	addon.editorFrame.title:SetFontObject("GameFontNormalLarge")
	local prev = addon.editorFrame.title
	
	addon.editorFrame.text1 = addon.editorFrame:CreateFontString(nil, addon.editorFrame, "GameFontNormal")
	if GuidelimeDataChar.currentGuide ~= nil then
		addon.editorFrame.text1:SetText(L.CURRENT_GUIDE .. ": |cFFFFFFFF" .. (GuidelimeDataChar.currentGuide.name or "") .. "\n")
	else
		addon.editorFrame.text1:SetText(L.CURRENT_GUIDE .. ":\n")
	end
	addon.editorFrame.text1:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -30)
	prev = addon.editorFrame.text1
	
    local scrollFrame = CreateFrame("ScrollFrame", nil, addon.editorFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", prev, "TOPLEFT", 0, -40)
    scrollFrame:SetPoint("RIGHT", addon.editorFrame, "RIGHT", -30, 0)
    scrollFrame:SetPoint("BOTTOM", addon.editorFrame, "BOTTOM", 0, 60)

    local content = CreateFrame("Frame", nil, scrollFrame) 
    content:SetSize(1, 1) 
    scrollFrame:SetScrollChild(content)
	prev = content
	
	addon.editorFrame.textBox = CreateFrame("EditBox", nil, content)
	if GuidelimeDataChar.currentGuide ~= nil and addon.guides[GuidelimeDataChar.currentGuide.name] ~= nil then
		addon.editorFrame.textBox:SetText(addon.guides[GuidelimeDataChar.currentGuide.name].text)
	end
	addon.editorFrame.textBox:SetMultiLine(true)
	addon.editorFrame.textBox:SetFontObject("GameFontNormal")
	addon.editorFrame.textBox:SetWidth(550)
	addon.editorFrame.textBox:SetPoint("TOPLEFT", content, "BOTTOMLEFT", 0, 0)
	addon.editorFrame.textBox:SetTextColor(255,255,255,255)

	addon.editorFrame.saveBtn = CreateFrame("BUTTON", nil, addon.editorFrame, "UIPanelButtonTemplate")
	addon.editorFrame.saveBtn:SetWidth(120)
	addon.editorFrame.saveBtn:SetHeight(30)
	addon.editorFrame.saveBtn:SetText(L.SAVE_GUIDE)
	addon.editorFrame.saveBtn:SetPoint("BOTTOMLEFT", addon.editorFrame, "BOTTOMLEFT", 20, 20)
	addon.editorFrame.saveBtn:SetScript("OnClick", function()
		local guide = addon.parseGuide(addon.editorFrame.textBox:GetText(), L.CUSTOM_GUIDES)
		if GuidelimeData.customGuides == nil then GuidelimeData.customGuides = {} end
		GuidelimeData.customGuides[guide.name] = guide.text
		GuidelimeDataChar.currentGuide = {name = guide.name, skip = {}}
		ReloadUI()
	end)
end

function addon.showEditor()
	if not addon.dataLoaded then loadData() end
	InterfaceOptionsFrame_Show() 
	InterfaceOptionsFrame_OpenToCategory(addon.editorFrame)
end
