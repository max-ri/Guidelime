addon = {}
addon.guides = {}
addon.debugging = true

-- Here Be Dragons does not run outside of client, but is used to transform coordinates; therefore we fake transforming coordinates here
-- (only used to transform zone coordinates to world and back to zone in the end)
HBD = {}
function HBD:GetZoneCoordinatesFromWorld(x, y, map)
	if map == nil then return end
	return x, y, map
end
function HBD:GetWorldCoordinatesFromZone(x, y, map)
	if map == nil then return end
	return x, y, map
end
function HBD:GetLocalizedMap(mapID) return addon.zoneNames[mapID] end
function LibStub(lib) 
	if lib == "HereBeDragons-2.0" then return HBD end
end
function GetBuildInfo() return nil,nil,nil,11302 end
function GetLocale() return "enUS" end
function addon.createPopupFrame(msg) error(msg) end
function GetAddOnMetadata(addonName) return addonName end

GuidelimeData = {}
Guidelime = {}

function Guidelime.registerGuide(guide, group)
	guide = addon.parseGuide(guide, group)
	if guide == nil then error("There were errors parsing the guide \"" .. guide.name .. "\"") end
	addon.guides[guide.name] = guide
	if guide.faction == nil and guide.race ~= nil then guide.faction = addon.races[guide.race[1]] end
	if guide.faction == nil and guide.class ~= nil then
		for _, class in ipairs(guide.class) do
			guide.faction = addon.classesWithFaction[class]
			if guide.faction ~= nil then break end
		end
	end
end

assert(loadfile("Localization.lua"))(nil, addon)
assert(loadfile("Guidelime_Parser.lua"))(nil, addon)
assert(loadfile("Data\\Guidelime_Data.lua"))(nil, addon)
assert(loadfile("Data\\Guidelime_MapDB.lua"))(nil, addon)
assert(loadfile("Data\\Guidelime_QuestsDB.lua"))(nil, addon)
assert(loadfile("Data\\Guidelime_QuestsTools.lua"))(nil, addon)
assert(loadfile("Data\\Guidelime_FlightmasterDB.lua"))(nil, addon)
assert(loadfile("Data\\Guidelime_FlightmasterDB_Locales.lua"))(nil, addon)

local tocfile = arg[1]
if tocfile == nil then error("Pass a guide addon's toc-file as an argument. E.g.: runScanQuests.lua ..\\Guidelime_ahmp\\Guidelime_ahmp.toc") end
local path = tocfile:sub(1, #tocfile - tocfile:reverse():find("\\"))
local f = io.open(tocfile, "r")
local toc = f:read("*all")
toc:gsub("([^\n]+)", function(line)
	if line ~= "" and line:sub(1, 2) ~= "##" then
		assert(loadfile(path .. "\\" .. line))(nil, addon)
	end
end)

for name, guide in pairs(addon.guides) do
	if guide.next ~= nil then
		for i, next in ipairs(guide.next) do
			if guide.group ~= nil and guide.group ~= "" then next = guide.group .. " " .. next end
			if addon.guides[next] == nil then error("part " .. next .. " not found") end
			addon.guides[next].isNext = true
		end
	end
end

addon.immediateTurnin = {}
addon.itemStart = {}

for id, quest in pairs(addon.questsDB) do
	if quest.gather == nil and quest.interact == nil and quest.kill == nil and 
		quest.source ~= nil and quest.deliver ~= nil and
		#quest.source == 1 and #quest.deliver == 1 and
		quest.source[1].type == quest.deliver[1].type and
		quest.source[1].id == quest.deliver[1].id then
		addon.immediateTurnin[id] = true
	elseif quest.interact == nil and quest.kill == nil and 
		quest.source ~= nil and quest.gather ~= nil and
		#quest.source == 1 and quest.source[1].type == "item" and #quest.gather == 1 and
		quest.source[1].id == quest.gather[1] then
		addon.itemStart[id] = true
	end
end

local function addError(guide, line, err)
	if addon.errors[guide] == nil then addon.errors[guide] = {} end
	err = ("   " .. line):reverse():sub(1, 3):reverse() .. " " .. err
	if not addon.contains(addon.errors[guide], err) then table.insert(addon.errors[guide], err) end
end

local function scanQuests(guide, quests, acceptOptional, turninOptional)

	if addon.acceptedQuests[guide.name] == nil or #addon.acceptedQuests[guide.name] > #quests then addon.acceptedQuests[guide.name] = quests end
	local currentQuests = {}
	local numQuests = 0
	for id, value in pairs(quests) do 
		currentQuests[id] = value 
		if value then numQuests = numQuests + 1 end
	end
	if addon.maxNumQuests[guide.name] == nil or addon.maxNumQuests[guide.name] < numQuests then addon.maxNumQuests[guide.name] = numQuests end
	local currentAcceptOptional = {}; for id, value in pairs(acceptOptional) do currentAcceptOptional[id] = value end
	local currentTurninOptional = {}; for id, value in pairs(turninOptional) do currentTurninOptional[id] = value end
	for i, step in ipairs(guide.steps) do
		if addon.applies(step) then
			for j, element in ipairs(step.elements) do
				if element.t == "ACCEPT" then
					if addon.questsDB[element.questId].prequests ~= nil then
						local missingPrequests = addon.getMissingPrequests(element.questId, function(id) 
							if quests[id] == false then
								if addon.prequests[guide.name] == nil then addon.prequests[guide.name] = {} end
								addon.prequests[guide.name][id] = true
							end
							return currentQuests[id] == false
						end)
						for _, id in ipairs(missingPrequests) do
							addError(guide.name, i, "ERROR: quest " .. element.questId .. " accepted but prequest " .. id .. " was not turned in")
						end
					end
					if currentQuests[element.questId] == false then
						addError(guide.name, i, "ERROR: quest " .. element.questId .. " accepted after it has been turned in in " .. addon.turnedIn[element.questId] .. " " .. addon.turnedInLine[element.questId])
					elseif currentQuests[element.questId] == true and not currentAcceptOptional[element.questId] and not step.completeWithNext then
						addError(guide.name, i, "WARNING: quest " .. element.questId .. " accepted after it has been accepted in " .. addon.acceptedIn[element.questId] .. " " .. addon.acceptedInLine[element.questId])
					elseif currentQuests[element.questId] == nil then
						currentQuests[element.questId] = true
						addon.acceptedIn[element.questId] = guide.name
						addon.acceptedInLine[element.questId] = i
						if step.completeWithNext then currentAcceptOptional[element.questId] = true end
						numQuests = numQuests + 1
						if addon.maxNumQuests[guide.name] <= 20 and numQuests > 20 then
							addError(guide.name, i, "ERROR: quest " .. element.questId .. " accepted after 20 or more quests had been accepted")
						end
						if addon.maxNumQuests[guide.name] < numQuests then
							addon.maxNumQuests[guide.name] = numQuests
						end
					elseif currentAcceptOptional[element.questId] then
						currentAcceptOptional[element.questId] = step.completeWithNext
					end
				elseif element.t == "COMPLETE" then
					if currentQuests[element.questId] == nil then
						if addon.itemStart[element.questId] then
							addError(guide.name, i, "WARNING: quest " .. element.questId .. " completed but was never accepted (started by an item)")
						else
							addError(guide.name, i, "ERROR: quest " .. element.questId .. " completed but was never accepted")
						end
						currentQuests[element.questId] = true
						addon.acceptedIn[element.questId] = guide.name
						addon.acceptedInLine[element.questId] = i
						if step.completeWithNext then currentAcceptOptional[element.questId] = true end
					end
				elseif element.t == "TURNIN" then
					if currentQuests[element.questId] == false and not currentTurninOptional[element.questId] and not step.completeWithNext then
						addError(guide.name, i, "WARNING: quest " .. element.questId .. " turned in after it has been turned in in " .. addon.turnedIn[element.questId] .. " " .. addon.turnedInLine[element.questId])
					elseif currentQuests[element.questId] ~= false then
						if currentQuests[element.questId] == nil then
							if addon.itemStart[element.questId] then
								addError(guide.name, i, "WARNING: quest " .. element.questId .. " turned in but was never accepted (item start)")
							elseif addon.immediateTurnin[element.questId] then
								addError(guide.name, i, "WARNING: quest " .. element.questId .. " turned in but was never accepted (quest can be turned in immediately)")
							else
								addError(guide.name, i, "ERROR: quest " .. element.questId .. " turned in but was never accepted")
							end
						end
						currentQuests[element.questId] = false
						if step.completeWithNext then currentTurninOptional[element.questId] = true end
						addon.turnedIn[element.questId] = guide.name
						addon.turnedInLine[element.questId] = i
						numQuests = numQuests - 1
					elseif currentTurninOptional[element.questId] then
						currentTurninOptional[element.questId] = step.completeWithNext
					end
				elseif element.t == "FLY" or element.t == "GET_FLIGHT_POINT" then
					if element.text ~= nil and element.flightmaster == nil then
						addError(guide.name, i, "ERROR: flight point \"" .. element.text .. "\" not recognized")
					end
				end
			end
		end
	end
	if guide.next ~= nil and #guide.next > 0 then
		for i, next in ipairs(guide.next) do
			if guide.group ~= nil and guide.group ~= "" then next = guide.group .. " " .. next end
			scanQuests(addon.guides[next], currentQuests, currentAcceptOptional, currentTurninOptional)
		end
	else
		for id, value in pairs(currentQuests) do
			if value then addon.notTurnedIn[id] = true end
		end
	end
end

addon.errors = {}
addon.acceptedIn = {}
addon.acceptedInLine = {}
addon.turnedIn = {}
addon.turnedInLine = {}
addon.prequests = {}
addon.maxNumQuests = {}
addon.acceptedQuests = {}
addon.notTurnedIn = {}

for race, faction in pairs(addon.races) do
	for _, class in ipairs(addon.classesPerRace[race]) do
		addon.faction = faction
		addon.race = race
		addon.class = class
		for _, guide in pairs(addon.guides) do
			if addon.applies(guide) then
				if guide.next ~= nil and #guide.next > 0 and not guide.isNext then
					scanQuests(guide, {}, {}, {})
				end
			end
		end
	end
end

local names = {}
for name, guide in pairs(addon.guides) do
	table.insert(names, name)
end
table.sort(names)
local count = 0
for _, name in ipairs(names) do
	for id, _ in pairs(addon.notTurnedIn) do
		if addon.acceptedIn[id] == name then
			addError(name, addon.acceptedInLine[id], "WARNING: quest " .. id .. " is never turned in")
		end
	end
	if addon.errors[name] ~= nil then
		table.sort(addon.errors[name])
		print()
		print(name)
		for _, err in ipairs(addon.errors[name]) do
			print(err)
			if err:sub(5,9) == "ERROR" then count = count + 1 end
		end
	end
end
if count > 0 then print(count .. " errors\n") end

for _, name in ipairs(names) do
	print()
	print(name)	
	if addon.maxNumQuests[name]	== nil then
		print("not tested")
	else
		if addon.prequests[name] ~= nil then
			local text = ""
			for id, value in pairs(addon.prequests[name]) do
				if value then
					text = text .. "[QT" .. id .. "],"
				end
			end
			if text ~= "" then
				print("Required prequests: " .. text:sub(1, #text - 1))
			end
		end
		if addon.acceptedQuests[name] ~= nil then
			local text = ""
			for id, value in pairs(addon.acceptedQuests[name]) do
				if value and not addon.notTurnedIn[id] then
					text = text .. "[QA" .. id .. "],"
				end
			end
			if text ~= "" then
				print("Accepted quests at the start: " .. text:sub(1, #text - 1))
			end
		end
		print ("Maximum Number of quests: " .. addon.maxNumQuests[name])
	end
end

	