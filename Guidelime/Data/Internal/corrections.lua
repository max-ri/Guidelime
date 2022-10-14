local addonName, addon = ...
addon.DB = addon.DB or {}; local DB = addon.DB

-- https://github.com/max-ri/Guidelime/issues/47 -- race restrictions on quest chains introducing flight paths
DB.questsDB[6181].race = {"Human"}            -- A Swift Message
DB.questsDB[6281].race = {"Human"}            -- Continue to Stormwind
DB.questsDB[6261].race = {"Human"}            -- Dungar Longdrink
DB.questsDB[6285].race = {"Human"}            -- Return to Lewis
DB.questsDB[6387].race = {"Dwarf", "Gnome"}   -- Honor Students
DB.questsDB[6391].race = {"Dwarf", "Gnome"}   -- Ride to Ironforge
DB.questsDB[6388].race = {"Dwarf", "Gnome"}   -- Gryth Thurden
DB.questsDB[6392].race = {"Dwarf", "Gnome"}   -- Return to Brock
DB.questsDB[6344].race = {"NightElf"}         -- Nessa Shadowsong
DB.questsDB[6341].race = {"NightElf"}         -- The Bounty of Teldrassil
DB.questsDB[6342].race = {"NightElf"}         -- Flight to Auberdine
DB.questsDB[6343].race = {"NightElf"}         -- Return to Nessa
DB.questsDB[6365].race = {"Orc", "Troll"}     -- Meats to Orgrimmar
DB.questsDB[6384].race = {"Orc", "Troll"}     -- Ride to Orgrimmar
DB.questsDB[6385].race = {"Orc", "Troll"}     -- Doras the Wind Rider Master
DB.questsDB[6386].race = {"Orc", "Troll"}     --	Return to the Crossroads
DB.questsDB[6361].race = {"Tauren"}           -- A Bundle of Hides
DB.questsDB[6362].race = {"Tauren"}           -- Ride to Thunder Bluff
DB.questsDB[6363].race = {"Tauren"}           -- Tal the Wind Rider Master
DB.questsDB[6364].race = {"Tauren"}           -- Return to Jahan
DB.questsDB[6321].race = {"Undead"}           -- Supplying the Sepulcher
DB.questsDB[6323].race = {"Undead"}           -- Ride to the Undercity
DB.questsDB[6322].race = {"Undead"}           -- Michael Garrett
DB.questsDB[6324].race = {"Undead"}           -- Return to Podrig

-- "Crown of the Earth pt. 5"#934 (Fill the Amethyst Phial...) has been replaced with Crown of the Earth pt. 5"#7383
DB.questsDB[934].replacement = 7383

-- issues with horde cloth donation quests
-- trolls: 7833 wool - 7834 silk - 7835 mageweave - 7836 + 7837 runecloth   npc=14727
-- orcs: 7826 wool - 7827 silk - 7831 mageweave - 7824 + 7832 runecloth   npc=14726
DB.questsDB[7835].followup = 7836
DB.questsDB[7836].prev = 7835
DB.questsDB[7836].prequests = {[1] = 7835}
DB.questsDB[7836].source = {[1] = {["id"] = 14727; ["type"] = "npc"}}
DB.questsDB[7836].deliver = {[1] = {["id"] = 14727; ["type"] = "npc"}}
DB.questsDB[7837].source = {[1] = {["id"] = 14727; ["type"] = "npc"}}
DB.questsDB[7837].deliver = {[1] = {["id"] = 14727; ["type"] = "npc"}}
DB.questsDB[7831].followup = 7824
DB.questsDB[7824].prev = 7831
DB.questsDB[7824].prequests = {[1] = 7831}
DB.questsDB[7824].source = {[1] = {["id"] = 14726; ["type"] = "npc"}}
DB.questsDB[7824].deliver = {[1] = {["id"] = 14726; ["type"] = "npc"}}
DB.questsDB[7832].source = {[1] = {["id"] = 14726; ["type"] = "npc"}}
DB.questsDB[7832].deliver = {[1] = {["id"] = 14726; ["type"] = "npc"}}

-- night elf version "Donation of Wool" has wrong id
DB.questsDB[7792] = DB.questsDB[7797]
DB.questsDB[7797] = nil
DB.questsDB[7798].prequests = { 7792 }

-- issues with ironforge cloth donation quests
-- dwarf: 7802 wool - 7803 silk - 7804 mageweave - 7805 + 7806 runecloth   npc=14723
-- gnome: 7807 wool - 7808 silk - 7809 mageweave - 7811 + 7812 runecloth   npc=14724
DB.questsDB[7808].followup = 7809
DB.questsDB[7809].prev = 7808
DB.questsDB[7809].prequests = {[1] = 7808}
DB.questsDB[7803].followup = 7804
DB.questsDB[7804].prev = 7803
DB.questsDB[7804].prequests = {[1] = 7803}

DB.questsDB[7802].source = {[1] = {["id"] = 14723; ["type"] = "npc"}}
DB.questsDB[7802].deliver = {[1] = {["id"] = 14723; ["type"] = "npc"}}
DB.questsDB[7803].source = {[1] = {["id"] = 14723; ["type"] = "npc"}}
DB.questsDB[7803].deliver = {[1] = {["id"] = 14723; ["type"] = "npc"}}
DB.questsDB[7804].source = {[1] = {["id"] = 14723; ["type"] = "npc"}}
DB.questsDB[7804].deliver = {[1] = {["id"] = 14723; ["type"] = "npc"}}

DB.questsDB[7807].source = {[1] = {["id"] = 14724; ["type"] = "npc"}}
DB.questsDB[7807].deliver = {[1] = {["id"] = 14724; ["type"] = "npc"}}
DB.questsDB[7808].source = {[1] = {["id"] = 14724; ["type"] = "npc"}}
DB.questsDB[7808].deliver = {[1] = {["id"] = 14724; ["type"] = "npc"}}
DB.questsDB[7809].source = {[1] = {["id"] = 14724; ["type"] = "npc"}}
DB.questsDB[7809].deliver = {[1] = {["id"] = 14724; ["type"] = "npc"}}


-- "Heeding the Call" (druid bear form quest) source npc for 5926 / 5928 are switched, reported by WittyWalnut137
DB.questsDB[5926].source = {[1] = {["id"] = 6746; ["type"] = "npc"}}
DB.questsDB[5928].source = {[1] = {["id"] = 3064; ["type"] = "npc"}}

-- Timerbaw Hold quests replaced
DB.questsDB[6131].replacement = 8460
DB.questsDB[6221].replacement = 8461
DB.questsDB[6241].replacement = 8464

-- wrong name "Thunderbrew Lager" for "Thunderbrew"#117
DB.questsDB[117].name = "Thunderbrew"   -- reported by WittyWalnut137
DB.questLocalesConverted["deDE"][117].name = "Donnerbräu"
DB.questLocalesConverted["esES"][117].name = "Cebatruenos"
DB.questLocalesConverted["esMX"][117].name = "Cebatruenos"
DB.questLocalesConverted["frFR"][117].name = "La Tonnebière"
DB.questLocalesConverted["ruRU"][117].name = "Громоварское"
DB.questLocalesConverted["koKR"][117].name = "썬더브루 맥주"

-- "Elmore's Task"#1097 can be started by Verner Osgood and Smith Argus; reported by WittyWalnut137
DB.questsDB[1097].source[2] = {["id"] = 415; ["type"] = "npc"}

-- prequests: Requires one of
DB.questsDB[1122].oneOfPrequests = true
DB.questsDB[5092].oneOfPrequests = true
DB.questsDB[5096].oneOfPrequests = true
DB.questsDB[5149].oneOfPrequests = true
DB.questsDB[6383].oneOfPrequests = true
DB.questsDB[4024].oneOfPrequests = true
DB.questsDB[794].oneOfPrequests = true   -- warlocks only have to do their own version of "Vile Familiars" (1499), reported by WittyWalnut137/shawnrobinson1977, confirmed on my warlock
DB.questsDB[990].oneOfPrequests = true
DB.questsDB[5922].oneOfPrequests = true
DB.questsDB[6126].oneOfPrequests = true

-- optional breadcrumb
DB.questsDB[473].prequests = { 455 }   -- "Report to Captain Stoutfist"#473 can only be accepted after having completed "The Algaz Gauntlet"#455 (see https://github.com/max-ri/Guidelime/issues/107)
DB.questsDB[464].prequests = nil       -- "War Banners"#464 can be accepted without having completed "Report to Captain Stoutfist"#473
DB.questsDB[1880].prequests = nil      -- mage lvl 10 quest, seen on my mage
DB.questsDB[1861].prequests = nil      -- mage lvl 10 quest, seen on my mage
DB.questsDB[1302].prequests = nil      -- James Hyal, reported by Branislav
DB.questsDB[691].prequests = nil       -- Worth Its Weight in Gold, reported by Branislav
DB.questsDB[484].prequests = nil       -- Young Crocolisk Skins, reported by Branislav / ahmp(in his guide)
DB.questsDB[4136].prequests = nil      -- Ribbly Screwspigot, reported by Mushroozard
DB.questsDB[5096].prequests = nil      -- Scarlet Diversions, marked as one of but apparently available without any! reported by Mushroozard
DB.questsDB[4134].prequests = nil      -- Lost Thunderbrew Recipe, reported by Mushroozard
DB.questsDB[5082].prequests = nil      -- Threat of the Winterfall, reported by Mushroozard
DB.questsDB[5887].prequests = { 4102 } -- Salve via Hunting, reported by Mushroozard
DB.questsDB[4768].prequests = nil      -- The Darkstone Tablet, reported by Mushroozard
DB.questsDB[207].prequests = { 204 }   -- Kurzen's Mystery, reported by InsaneKane / ahmp(in his guide); (one of) the correct prerequisite(s) is "Bad Medicine"#204 as seen by Zarant (https://youtu.be/Nu1Y_Caf-Ds?t=19302) (probably "Second Rebellion"#203 too because that are the prerequisites for "Special Forces"#574 as well)
DB.questsDB[429].prequests = nil       -- Wild Hearts, reported by Olo
DB.questsDB[1884].prequests = nil      -- Ju-Ju Heaps, reported by Olo (another mage lvl 10)
DB.questsDB[1204].prequests = nil      -- Mudrock Soup and Bugs, reported by Zarant
DB.questsDB[1395].prequests = nil      -- Supplies for Nethergarde, reported by Zarant
DB.questsDB[4126].prequests = nil      -- Hurley Blackbreath, reported by Zarant
DB.questsDB[5149].prequests = nil      -- Pamela's Doll, marked as one of but apparently available without any! reported by Zarant
DB.questsDB[4764].prequests = nil      -- Doomrigger's Clasp, reported by Zarant
DB.questsDB[4734].prequests = nil      -- Egg Freezing, reported by Zarant
DB.questsDB[2518].prequests = nil      -- Tears of the Moon, reported by Zarant
DB.questsDB[3447].prequests = { 3444 } -- Secret of the Circle; prequest "Into the Depths"#3446 definitely wrong reported by WittyWalnut137; correct prequest according to wowhead is "The Stone Circle"#3444
DB.questsDB[3981].prequests = { 3906 } -- Commander Gor'shak; prequest "Disharmony of Fire"#3907 definitely wrong reported by WittyWalnut137; correct prequest according to wowhead is "Disharmony of Flame"#3906
DB.questsDB[732].prequests = nil

-- https://github.com/max-ri/Guidelime/issues/120
DB.questsDB[614].faction = nil;
DB.questsDB[615].faction = nil;
DB.questsDB[615].faction = "Alliance";
DB.questsDB[8553].faction = nil;
DB.questsDB[5238].faction = "Horde";
DB.questsDB[5092].oneOfPrequests = nil;
DB.questsDB[5092].prequests = nil;
DB.questsDB[8551].faction = nil;
DB.questsDB[353].prequests = nil
