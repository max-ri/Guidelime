local addonName, addon = ...

local L = {}

L.TITLE = addonName
L.SHOW_MAINFRAME = "show window"
L.LOAD_MESSAGE = "Guidelime: Loading guide \"%s\""

local locale = GetLocale()

if locale == "deDE" then

L.SHOW_MAINFRAME = "Fenster anzeigen"
L.LOAD_MESSAGE = "Guidelime: Lade Guide \"%s\""

end

addon.L = L
