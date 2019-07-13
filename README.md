# Guidelime

A WoW Classic addon for leveling guides with automatic progress updates

## What does it do?

Guides are shown as a list of steps where the progress is updated automatically as much as possible (quests picked up / completed, quest 
items looted / mobs killed, etc). Only for some steps completion has to be confirmed manually (such as resupplying, getting new skills, etc). 
Locations referenced in the guide are shown on the map and minimap. Also there is an arrow pointing in the direction towards the next step.

The addon comes with an editor so even if the number of guides included is small (yet) it is very easy to create your own guides or to import
your favorite guide.

<img src="https://i.imgur.com/6aCB623.png" alt="Guidelime"/>

*This is for WoW Classic. It will not run on private servers and/or BFA.*

## How do I write a guide?

Guides are written as simple text files where each line describes one step of the guide. In order to make use of the different features of the addon certain codes can be inserted. These codes are always put in brackets `[]` starting with a capital letters (such as `QA` for accepting or quest, `G` go to coordinates and so on) which defines what kind of code it is.

The following codes can be used:

### Codes that contain information about your guide

These codes should each only be used once in your guide. (If there is more than one of a kind, all but the last one will be ignored.) You can put them anywhere in your guide. At the beginning would make most sense. It makes no difference whether you put each on a separate line of text or all in the same line.

#### `N` Name and level range of the guide 

This sets the name and level range of your guide. This defines how the guide will show up in the guide selection list.

Example: `[N 1-6 Coldridge Valley]`

#### `D` Detailed guide description

Here you can give a more detailed description of your guide. This will be shown below the guide selection list whenever the user mouses over your guide. You should describe what the player can expect from your guide whenever this is not clear from the given level range and zone alone. You can also put your name, your website / youtube channel / twitch stream / or whatever you want people to know about you here.

Example: `[D My personal guide to the gnome/dwarf starting zone]`

#### `NX` Name and level range of the next guide

Whenever this is set and a player finishes your guide the user can proceed with the guide named here with only one click. So if you are writing a series of guides this should be used to connect one guide of the series with the next.

Example: `[NX 6-12 Dun Morogh]`

#### `GA` Faction / races / classes this guide applies to

Here you can set what players will be seeing your guide in the guides list. You can put any combination of a faction, races, or classes here, separated by commas. Names are case-insensitive and can contain spaces (use English names). For guides for the starting zones you would put the respective races here. Later guides would only specify the factiond. Maybe you are writing a guide only for a specific class? (Maybe for one of the lengthy class quest chains?) You can then put that class here and only players of that class will be able to see and select this guide.

Example: `[GA Dwarf,Gnome]`

### Codes for steps with automatic completion detection

For all of these codes a small icon will be displayed. It will be replaced with a check mark once completion has been detected. When all steps on one line are completed the checkbox for this line will be checked and the line will disappear.

#### `Q` Quests

This is for steps dealing with quests. You can have more than one quest code on one line if multiple quests are adressed at the same time e.g. turning in a quest and accepting the follow up. The `Q` is always followed by a second letter specifying which type of quest step it is:
* `A` Accept a quest
* `C` Complete a quest
* `T` Turn in a quest
* `S` Skip a quest (only use this to point out to the player not to accept a certain quest e.g. when it is not worth the time or if it is to be done at a later time)

Next you need to specify the id of the quest. Since quest names are not unique it is mandatory to specify the exact id of the quest. When using the "Add a quest"-button of the inbuilt editor you can enter the unique name of a quest and the corresponding id will be filled in. Whenever there are multiple quests of the same name you will need external tools to find out the id of the quest. (You will usually find the id e.g. by looking at the url of the page of the quest in any database website.) 

After the id you can specify the text that will be shown for this step. If omitted the name of the quest will be shown. (In case of quest series no part 1/2/3 will be shown. The name will appear in the same way as it does in the quest log. If the part should be shown you have to specify it in the text.) You can put a `-` here if you don't want any text to be shown.

For completing quests there is also the possibility to specify that only one specific objective is to be completed. For this case put the number of the objective that should be completed (1 for first, 2 for second, ...) after the id of the quest separated with a comma.

Some examples:

`Accept [QA179]` (Since no text is given quest name is added and this will show up as _Accept **Dwarven Outfitters**_)

`Loot the chest for [QC3361,2 A Refugee's Quandary]` (For this quest the chest is the second step. Please look up the correct order of the objectives when using this.)

`Go do [QC237 In Defense of the King's Lands Part 2] if you haven't done so already, [QT237 turn it in] & accept [QA263 Part 3]` (If text is specified this will be used instead of the name of the quest)

`Complete [QC263-][QC2038 both quests]`

#### `G` Go to

Here you can specify coordinates the player should go to. Coordinates of upcoming steps will be shown on the map and minimap. Whenever a step becomes active an arrow will appear pointing towards the specified coordinates. When the player reaches the coordinates the arrrow will disappear. 

Coordinates are specified by their x and y value separated by a comma optionally followed by the respective's zone name (English names only). If the zone name is omitted coordinates are assumed to be in the same zone as previous coordinates. For the first pair of coordinates the zone name must not be omitted.

Example: `[G 29.93,71.2 Dun Morogh]`

#### `XP` Level and experience points

At certain points the player might be required to have obtained a certain level in order to continue e.g. in order to be able to pick up a quest. Ideally your guide should tell the player where to do some grinding in advance instead of letting the player find out that he is too low level when he is standing in front of the npc where there may not even be any mobs nearby. Considering the player might have skipped parts of your guide, you can tell the player in regular intervals what his current progress should be in order to not run into problems later on. By using the `XP`-code this can be done in a way which will be tracked automatically by the addon.

First specify the level the player has to have reached. This can be a fractional number in order to specify the fraction of the next level the player needs to have reached already. Alternatively to a fractional number you can also specify that the player should have obtained a certain amount of experience points towards the next level by writing `(level)+(amount of points)` or that the player should be missing at most a certain amount of experience points until reaching the specified level by writing `(level)-(amount of points)`

After the level you can optionally specify a text to be shown. If no text is specified the level is shown as it is entered.

Examples:

`Kill trolls in the area for [QC182 The Troll Cave][O] until you are level [XP4]`

`Grind until [XP18]`

`You should be [XP8.5 half way to 9] now`

`You should be about [XP6-500 500 to 6] now`

### Codes for steps without automatic completion detection

All of the following do not (yet) have automatic detection built in. Except for the first two codes (`H` and `F`) which only represent means of traveling, the player will have to manually click on the checkbox in order to confirm he has done what is asked for so that the step disappears from his list.

#### `H` Use hearthstone

As this only tells the player how to get to the place where he needs to go, this does not need to be checked off manually. Instead this step will complete itself automatically whenever the next step is completed.

Example: `[H]Hearth to Thelsamar`

#### `F` Take a flight

Again this only tells the player how to travel to the next step. Therefore this step will also complete itself automatically whenever the next step is completed.

Example: `[H]Fly to Thelsamar`

#### `T` Visit trainer

Example: `[T]Get new skills at your trainer`

#### `S` Set hearthstone

Example : `[S]Set hearth in Goldshire`

#### `P` Get a new flight point

Detection of whether the player has activated a flight path is not (yet) built in. This might or might not be added at a later time.

Example: `[P]Activate the flight point in Thelsamar`

#### `V` Vendor / `R` Repair

Example: `You can [V]sell vendor loot and resupply and [R] repair here`

### Codes that contain extra information concerning one step of your guide

#### `A` Faction / races / classes this step applies to

Similar to 'GA' you can set to which players one step of your guide applies. Again you can put any combination of a faction, races, or classes here, separated by commas. Names are case-insensitive and can contain spaces (use English names). For players that do not meet the criteria the whole line of the guide will not show up. 

When steps address class-/race-specific quests technically you are not required to use the `A`-code since the addon would detect that and not show the whole line in any way. But for making it easier for you to read your guide you might still want to specify it.

Sometimes it might be required to have some lines only show up for certain races / classes even if no race-/class-quests are addressed directly. E.g. certain races might not be required to run and pick up a new flight point but can fly instead since they will have to have come that way earlier anyway. Or when the guide does address a class quest this might change the way or the order other quests are done since the player takes a different route.

Examples:

`Accept [QA3109 Encrypted Rune][A Dwarf,Rogue]` (This actually is the same as just `Accept [QA3109 Encrypted Rune]`)

`In the troll cave keep left until you find and kill Grik'nir the Cold for [QC218 The Stolen Journal][A Warrior,Mage,Hunter,Rogue,Priest,Paladin]` (In the demo guide this step does not show up for warlocks because warlocks need to kill other mobs in that cave for their class quest)

#### `O` optional

If you mark one step as optional the next step in the guide will become active at the same time. The player is not required to complete this step in order to go on with the guide.

When the `O` is followed by `C` this means that this step should be considered completed as well as soon as the next step is completed.  Sometimes a step is only required in order to start with the next (usually going somewhere). Therefore it will be considered completed once the next step is started.

Examples:

`Kill troggs along your way for [QC170 A New Threat][O]` (You do not have to kill all of the troggs for your quest just kill some while you are on your way to the next step. Therefore the next step will be active immediately when you reach this step.)

`Kill trolls in the area for [QC182 The Troll Cave][O] until you are level [XP4]` (Note that here only killing the trolls is optional. Reaching level 4 is not. Therefore this step will be completed only once level 4 is reached even when not all trolls are killed.)

`Grind up to the Dam[G46.05,13.61][OC]`

`Take the tram to Stormwind[OC]
Turn in [G 55.51,12.51 Stormwind City][QT2041 Speak with Shoni]`

## What is missing?

#### More guides

Right now there are only demo guides for testing out the addon. Guides for 1-60 Alliance will likely be released shortly after launch. Horde
guides will be added later on.

If you are a guide creator and you have your own guides that you would like to see in Guidelime feel free to contact me.

#### Documentation

Instructions on how to put your own guides into a separate addon will be added soon.

#### Improved editor

The editor will soon be complemented with powerful features for importing guides so that creating your own guides will be even easier.

#### Localization

The German version will be finished soon. A Spanish version will follow afterwards. If anyone would volunteer to do translations for other languages please contact me.

The guides itself are language specific. The guides I am currently working on are in English language only. But using the editor you can create guides in your own language.

## How do I open the window again when I have closed id?

Type `/lime` or go to *Interface Options*, *AddOns*, *Guidelime*, *Options* and click on show window.

## Contact 

Discord: https://discord.gg/kDXMHsV

You'd like to support me?

<a href='https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=max_r_%40web.de&item_name=Guidelime&currency_code=EUR'><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif"/></a>
