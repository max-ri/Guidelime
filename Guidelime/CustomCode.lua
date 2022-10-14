local addonName, addon = ...
local L = addon.L

addon.D = addon.D or {}; local D = addon.D     -- Data/Data

addon.CC = addon.CC or {}; local CC = addon.CC -- CustomCode

function CC.parseCustomLuaCode()
	CC.wipeFrameData()
	local guide = addon.guides[GuidelimeDataChar.currentGuide]
	if not (guide and guide.group) then return end
	local groupTable = Guidelime[guide.group]
	if not groupTable then Guidelime[guide.group] = true end
	

	if type(groupTable) == "table" then
		local frameCounter = 0
		groupTable.__index = groupTable

		for stepLine, step in ipairs(guide.steps) do
			if D.applies(step) then 
				if step.eval and step.event then
					local args = {}
					local eval = nil
					for arg in step.eval:gmatch('[^,]+') do
						if not eval then
							eval = arg:gsub("%s","")
						else
							local c = string.match(arg,"^%s*(.*%S+)%s*$")
							if c then table.insert(args,c) end
						end
					end
					if eval then
						frameCounter = frameCounter + 1
						step.event = step.event:gsub("%s","")
						if step.event == "" then 
							step.event = groupTable[eval]() or "OnStepActivation"
						end
						local eventList = {}
						for event in step.event:gmatch('[^,]+') do
							table.insert(eventList,event)
						end
						CC.registerStep(groupTable,eventList,eval,args,frameCounter,guide,step)
					end
				end
			end
		end
	end
end

function CC.registerStep(self,eventList,eval,args,frameCounter,guide,step)

	if frameCounter > #CC.customCodeData+1  then
		return
	end
	if #CC.customCodeData < frameCounter then
		table.insert(CC.customCodeData,CreateFrame("Frame"))
	end

	if type(self[eval]) ~= "function" then
		return 
	end

	local frame = CC.customCodeData[frameCounter]
	frame.data = {}
	frame.data.guide = guide
	frame.data.step = step
	frame.args = args

	setmetatable(frame.data, self)

	local function EventHandler(s,...) --Executes the function if step is active or if it's specified on a 0 element step (e.g. guide name)
		if s.data.step.active or #s.data.step.elements == 0 or s.data.persistent then 
			self[eval](s.data,args,...)
		end
	end
	local OnUpdate
	for _,eventRaw in pairs(eventList) do
		local event = {}
		eventRaw:gsub("[^:]+",function(e)
			table.insert(event,e)
		end)
		
		--print(eval,event)
		if event[1] == "OnUpdate" then
			OnUpdate = true
			frame:SetScript("OnUpdate",EventHandler)
		elseif event[1] == "OnLoad" then
			self[eval](frame.data,args,"OnLoad")
		elseif event[1] == "OnStepActivation" then
			frame.OnStepActivation = self[eval]
		elseif event[1] == "OnStepCompletion" then
			frame.OnStepCompletion = self[eval]
		elseif event[1] == "OnStepUpdate" then
			frame.OnStepUpdate = self[eval]
		else
			if #event == 1 then
				if not pcall(frame.RegisterEvent,frame,event[1]) then
					print("Error loading guide: Ignoring invalid event name at line "..step.line..": "..event[1])
				end
			else
				if not pcall(frame.RegisterUnitEvent,frame,unpack(event)) then
					print("Error loading guide: Ignoring invalid event name at line "..step.line)
				end
			end
		end
	end
	if not OnUpdate then
		CC.customCodeData[frameCounter]:SetScript("OnEvent",EventHandler)
	end
end

function CC.wipeFrameData()
	if not CC.customCodeData then
		CC.customCodeData = {}
	end
	for _,frame in pairs(CC.customCodeData) do
		frame:SetScript("OnUpdate", nil)
		frame:SetScript("OnEvent", nil)
		frame:UnregisterAllEvents()
		frame.OnStepActivation = nil
		frame.OnStepCompletion = nil
		frame.OnStepUpdate = nil
		frame.args = nil
		if frame.data then
			frame.data.persistent = nil
			frame.data.timer = nil
		end
		frame.data = nil
	end
end
