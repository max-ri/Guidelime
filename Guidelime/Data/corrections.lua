
-- This file contains all the differences between the Guidelime data files and the source database by TyrsDev (https://github.com/TyrsDev/WoW-Classic-Database)
-- If any errors are found they should be added here, then the data files can be generated again


-- https://github.com/max-ri/Guidelime/issues/47 -- race restrictions on quest chains introducing flight paths
addon.questsDB[6181].race = {"Human"}            -- A Swift Message
addon.questsDB[6281].race = {"Human"}            -- Continue to Stormwind
addon.questsDB[6261].race = {"Human"}            -- Dungar Longdrink
addon.questsDB[6285].race = {"Human"}            -- Return to Lewis
addon.questsDB[6387].race = {"Dwarf", "Gnome"}   -- Honor Students
addon.questsDB[6391].race = {"Dwarf", "Gnome"}   -- Ride to Ironforge
addon.questsDB[6388].race = {"Dwarf", "Gnome"}   -- Gryth Thurden
addon.questsDB[6392].race = {"Dwarf", "Gnome"}   -- Return to Brock
addon.questsDB[6344].race = {"NightElf"}         -- Nessa Shadowsong
addon.questsDB[6341].race = {"NightElf"}         -- The Bounty of Teldrassil
addon.questsDB[6342].race = {"NightElf"}         -- Flight to Auberdine
addon.questsDB[6343].race = {"NightElf"}         -- Return to Nessa
addon.questsDB[6365].race = {"Orc", "Troll"}     -- Meats to Orgrimmar
addon.questsDB[6384].race = {"Orc", "Troll"}     -- Ride to Orgrimmar
addon.questsDB[6385].race = {"Orc", "Troll"}     -- Doras the Wind Rider Master
addon.questsDB[6386].race = {"Orc", "Troll"}     --	Return to the Crossroads
addon.questsDB[6361].race = {"Tauren"}           -- A Bundle of Hides
addon.questsDB[6362].race = {"Tauren"}           -- Ride to Thunder Bluff
addon.questsDB[6363].race = {"Tauren"}           -- Tal the Wind Rider Master
addon.questsDB[6364].race = {"Tauren"}           -- Return to Jahan
addon.questsDB[6321].race = {"Undead"}           -- Supplying the Sepulcher
addon.questsDB[6323].race = {"Undead"}           -- Ride to the Undercity
addon.questsDB[6322].race = {"Undead"}           -- Michael Garrett
addon.questsDB[6324].race = {"Undead"}           -- Return to Podrig

-- "Crown of the Earth pt. 5"#934 (Fill the Amethyst Phial...) has been replaced with Crown of the Earth pt. 5"#7383
addon.questsDB[934].replacement = 7383

-- https://github.com/max-ri/Guidelime/issues/107
addon.questsDB[473].prequests = { 455 } -- "Report to Captain Stoutfist"#473 can only be accepted after having completed "The Algaz Gauntlet"#455
addon.questsDB[464].prequests = {}      -- "War Banners"#464 can be accepted without having completed "Report to Captain Stoutfist"#473

-- issues with horde cloth donation quests
addon.questsDB[7835].followup = 7836
addon.questsDB[7836].prev = 7835
addon.questsDB[7836].prequests = {[1] = 7835}
addon.questsDB[7836].source = {[1] = {["id"] = 14727; ["type"] = "npc"}}
addon.questsDB[7836].deliver = {[1] = {["id"] = 14727; ["type"] = "npc"}}
addon.questsDB[7837].source = {[1] = {["id"] = 14727; ["type"] = "npc"}}
addon.questsDB[7837].deliver = {[1] = {["id"] = 14727; ["type"] = "npc"}}

addon.questsDB[7831].followup = 7824
addon.questsDB[7824].prev = 7831
addon.questsDB[7824].prequests = {[1] = 7831}
addon.questsDB[7824].source = {[1] = {["id"] = 14726; ["type"] = "npc"}}
addon.questsDB[7824].deliver = {[1] = {["id"] = 14726; ["type"] = "npc"}}
addon.questsDB[7824].source = {[1] = {["id"] = 14726; ["type"] = "npc"}}
addon.questsDB[7832].deliver = {[1] = {["id"] = 14726; ["type"] = "npc"}}

-- wrong quest name "Thunderbrew Lager" changed to "Thunderbrew"
addon.questsDB[117].name = "Thunderbrew"
questLocalesConverted["deDE"][117].name = "Donnerbräu"
questLocalesConverted["ruRU"][117].name = "Громоварское"
questLocalesConverted["frFR"][117].name = "La Tonnebière"
questLocalesConverted["esES"][117].name = "Cebatruenos"
questLocalesConverted["esMX"][117].name = "Cebatruenos"

-- https://github.com/max-ri/Guidelime/issues/120
addon.questsDB[614].faction = nil;
addon.questsDB[615].faction = nil;
addon.questsDB[615].faction = "Alliance";
addon.questsDB[8553].faction = nil;
addon.questsDB[5238].faction = "Horde";
addon.questsDB[5092].oneOfPrequests = nil;
addon.questsDB[5092].prequests = {};
addon.questsDB[8551].faction = nil;
addon.questsDB[353].prequests = {}

