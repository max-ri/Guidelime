# Guidelime

A WoW Classic and Burning Crusade Classic addon for leveling guides with automatic progress updates

## What does it do?

Guides are shown as a list of steps where the progress is updated automatically as much as possible (quests picked up / completed, quest 
items looted / mobs killed, etc). Only for some steps completion has to be confirmed manually (such as resupplying, getting new skills, etc). 
Locations referenced in the guide are shown on the map and minimap. Also there is an arrow pointing in the direction towards the next step.

It competely supports Burning Crusade Classic. There are guides for Draenei and Blood Elf starting zones, as well as Alliance and Horde Outland guides for 58-70. There are also special guides for boosted characters in order to level from 58-60 without going to Outland.

The addon comes with an editor so even if the number of guides included is small (yet) it is very easy to create your own guides or to import
your favorite guide.

<img src="https://i.imgur.com/6aCB623.png" alt="Guidelime"/>

*This is for WoW Classic and Burning Crusade Classic. It will not run on private servers and/or Shadowlands. (If you only want to take a look at the editor e.g., it will load on Shadowlands if you select "load out of date addons".)*

## Where do I find guides for the addon?

See <a href="https://github.com/max-ri/Guidelime/wiki/GuideList">list of all available guides</a> for a complete list of guides that have been written for Guidelime so far.

## How do I write a guide?

<a href="https://github.com/max-ri/Guidelime/wiki/WriteAGuide">How do I write a guide?</a>

## How do I publish a guide?

<a href="https://github.com/max-ri/Guidelime/wiki/PublishAGuide">How do I publish a guide?</a>

## How do I install the addon?

When you download the zip file from this page (click "Clone or Download" then "Download Zip") you will find a *Guidelime* folder (inside the *Guidelime-master* folder). Copy this folder into your *Addons* folder.

By using this method you will always get to most recent version of the addon (*master*) including all changes that are being made as soon as they are published.

Alternatively you can also download the addon from https://www.curseforge.com/wow/addons/guidelime or install it via the Twitch client. This way you will get the latest stable release. (Which currently is also being updated in average once a day.)

## How do I install a guide?
To install a guide please visit the list of guides mentioned above.

Once you have downloaded the guide, copy the .lua script files from the download folder to (for example) /path/to/wow/Interface\AddOns\Guidelime\DemoGuides\Horde

Next open the DemoGuides.xml (located: Interface\AddOns\Guidelime\DemoGuides\DemoGuides.xml).

Copy the format of the other script imports in this file, and add your own guide, for example:
```xml
<Script file="Horde\Bustea's Horde Leveling guide\Bustea's 41-45 leveling.lua"/>
```

Save the file and voila! You now have installed the Bustea's Horde 41-45 guide, you will be able to select it from the Guidelime menu on next game launch.

## What is missing?

#### More guides

If you are a guide creator and you have your own guides that you would like to see in Guidelime feel free to contact me.

#### Localization

The addon is currently available in English, German, French, Russian and Chinese. If anyone would volunteer to do translations for other languages please contact me.

The guides itself are language specific. The guides I am currently working on are in English language only. But using the editor you can create guides in your own language.

## How do I open the window again after I closed it accidentally?

Type `/lime` or go to *Interface Options*, *AddOns*, *Guidelime*, *Options* and click on show window.

## FAQ

Some more questions concerning this addon are answered in the <a href="https://github.com/max-ri/Guidelime/wiki/FAQ">FAQ</a>

## Contact 

Discord: https://discord.gg/kDXMHsV

You'd like to support me?

<a href='https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=max_r_%40web.de&item_name=Guidelime&currency_code=EUR'><img src="https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif"/></a>
