
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

-- issues with horde cloth donation quests
-- trolls: 7833 wool - 7834 silk - 7835 mageweave - 7836 + 7837 runecloth   npc=14727
-- orcs: 7826 wool - 7827 silk - 7831 mageweave - 7824 + 7832 runecloth   npc=14726
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
addon.questsDB[7832].source = {[1] = {["id"] = 14726; ["type"] = "npc"}}
addon.questsDB[7832].deliver = {[1] = {["id"] = 14726; ["type"] = "npc"}}

-- night elf version "Donation of Wool" has wrong id
addon.questsDB[7792] = addon.questsDB[7797]
addon.questsDB[7797] = nil
addon.questsDB[7798].prequests = { 7792 }

-- issues with ironforge cloth donation quests
-- dwarf: 7802 wool - 7803 silk - 7804 mageweave - 7805 + 7806 runecloth   npc=14723
-- gnome: 7807 wool - 7808 silk - 7809 mageweave - 7811 + 7812 runecloth   npc=14724
addon.questsDB[7808].followup = 7809
addon.questsDB[7809].prev = 7808
addon.questsDB[7809].prequests = {[1] = 7808}
addon.questsDB[7803].followup = 7804
addon.questsDB[7804].prev = 7803
addon.questsDB[7804].prequests = {[1] = 7803}

addon.questsDB[7802].source = {[1] = {["id"] = 14723; ["type"] = "npc"}}
addon.questsDB[7802].deliver = {[1] = {["id"] = 14723; ["type"] = "npc"}}
addon.questsDB[7803].source = {[1] = {["id"] = 14723; ["type"] = "npc"}}
addon.questsDB[7803].deliver = {[1] = {["id"] = 14723; ["type"] = "npc"}}
addon.questsDB[7804].source = {[1] = {["id"] = 14723; ["type"] = "npc"}}
addon.questsDB[7804].deliver = {[1] = {["id"] = 14723; ["type"] = "npc"}}

addon.questsDB[7807].source = {[1] = {["id"] = 14724; ["type"] = "npc"}}
addon.questsDB[7807].deliver = {[1] = {["id"] = 14724; ["type"] = "npc"}}
addon.questsDB[7808].source = {[1] = {["id"] = 14724; ["type"] = "npc"}}
addon.questsDB[7808].deliver = {[1] = {["id"] = 14724; ["type"] = "npc"}}
addon.questsDB[7809].source = {[1] = {["id"] = 14724; ["type"] = "npc"}}
addon.questsDB[7809].deliver = {[1] = {["id"] = 14724; ["type"] = "npc"}}


-- "Heeding the Call" (druid bear form quest) source npc for 5926 / 5928 are switched, reported by WittyWalnut137
addon.questsDB[5926].source = {[1] = {["id"] = 6746; ["type"] = "npc"}}
addon.questsDB[5928].source = {[1] = {["id"] = 3064; ["type"] = "npc"}}

-- Timerbaw Hold quests replaced
addon.questsDB[6131].replacement = 8460
addon.questsDB[6221].replacement = 8461
addon.questsDB[6241].replacement = 8464

-- wrong name "Thunderbrew Lager" for "Thunderbrew"#117
addon.questsDB[117].name = "Thunderbrew"   -- reported by WittyWalnut137
addon.questLocalesConverted["deDE"][117].name = "Donnerbräu"
addon.questLocalesConverted["esES"][117].name = "Cebatruenos"
addon.questLocalesConverted["esMX"][117].name = "Cebatruenos"
addon.questLocalesConverted["frFR"][117].name = "La Tonnebière"
addon.questLocalesConverted["ruRU"][117].name = "Громоварское"
addon.questLocalesConverted["koKR"][117].name = "썬더브루 맥주"

-- "Elmore's Task"#1097 can be started by Verner Osgood and Smith Argus; reported by WittyWalnut137
addon.questsDB[1097].source[2] = {["id"] = 415; ["type"] = "npc"}

-- prequests: Requires one of
addon.questsDB[1122].oneOfPrequests = true
addon.questsDB[5092].oneOfPrequests = true
addon.questsDB[5096].oneOfPrequests = true
addon.questsDB[5149].oneOfPrequests = true
addon.questsDB[6383].oneOfPrequests = true
addon.questsDB[4024].oneOfPrequests = true
addon.questsDB[794].oneOfPrequests = true   -- warlocks only have to do their own version of "Vile Familiars" (1499), reported by WittyWalnut137/shawnrobinson1977, confirmed on my warlock
addon.questsDB[990].oneOfPrequests = true
addon.questsDB[5922].oneOfPrequests = true
addon.questsDB[6126].oneOfPrequests = true

-- optional breadcrumb
addon.questsDB[473].prequests = { 455 }   -- "Report to Captain Stoutfist"#473 can only be accepted after having completed "The Algaz Gauntlet"#455 (see https://github.com/max-ri/Guidelime/issues/107)
addon.questsDB[464].prequests = nil       -- "War Banners"#464 can be accepted without having completed "Report to Captain Stoutfist"#473
addon.questsDB[1880].prequests = nil      -- mage lvl 10 quest, seen on my mage
addon.questsDB[1861].prequests = nil      -- mage lvl 10 quest, seen on my mage
addon.questsDB[1302].prequests = nil      -- James Hyal, reported by Branislav
addon.questsDB[691].prequests = nil       -- Worth Its Weight in Gold, reported by Branislav
addon.questsDB[484].prequests = nil       -- Young Crocolisk Skins, reported by Branislav / ahmp(in his guide)
addon.questsDB[4136].prequests = nil      -- Ribbly Screwspigot, reported by Mushroozard
addon.questsDB[5096].prequests = nil      -- Scarlet Diversions, marked as one of but apparently available without any! reported by Mushroozard
addon.questsDB[4134].prequests = nil      -- Lost Thunderbrew Recipe, reported by Mushroozard
addon.questsDB[5082].prequests = nil      -- Threat of the Winterfall, reported by Mushroozard
addon.questsDB[5887].prequests = { 4102 } -- Salve via Hunting, reported by Mushroozard
addon.questsDB[4768].prequests = nil      -- The Darkstone Tablet, reported by Mushroozard
addon.questsDB[207].prequests = { 204 }   -- Kurzen's Mystery, reported by InsaneKane / ahmp(in his guide); (one of) the correct prerequisite(s) is "Bad Medicine"#204 as seen by Zarant (https://youtu.be/Nu1Y_Caf-Ds?t=19302) (probably "Second Rebellion"#203 too because that are the prerequisites for "Special Forces"#574 as well)
addon.questsDB[429].prequests = nil       -- Wild Hearts, reported by Olo
addon.questsDB[1884].prequests = nil      -- Ju-Ju Heaps, reported by Olo (another mage lvl 10)
addon.questsDB[1204].prequests = nil      -- Mudrock Soup and Bugs, reported by Zarant
addon.questsDB[1395].prequests = nil      -- Supplies for Nethergarde, reported by Zarant
addon.questsDB[4126].prequests = nil      -- Hurley Blackbreath, reported by Zarant
addon.questsDB[5149].prequests = nil      -- Pamela's Doll, marked as one of but apparently available without any! reported by Zarant
addon.questsDB[4764].prequests = nil      -- Doomrigger's Clasp, reported by Zarant
addon.questsDB[4734].prequests = nil      -- Egg Freezing, reported by Zarant
addon.questsDB[2518].prequests = nil      -- Tears of the Moon, reported by Zarant
addon.questsDB[3447].prequests = { 3444 } -- Secret of the Circle; prequest "Into the Depths"#3446 definitely wrong reported by WittyWalnut137; correct prequest according to wowhead is "The Stone Circle"#3444
addon.questsDB[3981].prequests = { 3906 } -- Commander Gor'shak; prequest "Disharmony of Fire"#3907 definitely wrong reported by WittyWalnut137; correct prequest according to wowhead is "Disharmony of Flame"#3906
addon.questsDB[732].prequests = nil

-- https://github.com/max-ri/Guidelime/issues/120
addon.questsDB[614].faction = nil;
addon.questsDB[615].faction = nil;
addon.questsDB[615].faction = "Alliance";
addon.questsDB[8553].faction = nil;
addon.questsDB[5238].faction = "Horde";
addon.questsDB[5092].oneOfPrequests = nil;
addon.questsDB[5092].prequests = nil;
addon.questsDB[8551].faction = nil;
addon.questsDB[353].prequests = nil
