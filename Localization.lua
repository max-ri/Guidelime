local addonName, addon = ...

local L = {}

L.TITLE = addonName
L.SHOW_MAINFRAME = "show window"
L.LOCK_MAINFRAME = "lock window"
L.LOAD_MESSAGE = "Guidelime: Loading guide \"%s\""
L.HIDE_COMPLETED_STEPS = "hide completed steps"
L.CURRENT_GUIDE = "Current guide"
L.AVAILABLE_GUIDES = "Available guides"
L.DETAILS = "Details"
L.MAIN_FRAME_WIDTH = "Window width"
L.MAIN_FRAME_HEIGHT = "Window height"
L.MISSING_PREQUEST = "The following required quest was not completed:"
L.MISSING_PREQUESTS = "The following required quests were not completed:"
L.OTHER_GUIDES = "Other guides"
L.LOAD_GUIDE = "Load guide"
L.RESET_GUIDE = "Reset guide"

local locale = GetLocale()

if locale == "deDE" then

L.SHOW_MAINFRAME = "Fenster anzeigen"
L.LOCK_MAINFRAME = "Fenster feststellen"
L.LOAD_MESSAGE = "Guidelime: Lade Guide \"%s\""
L.HIDE_COMPLETED_STEPS = "Abgeschlossene Schritte verstecken"
L.CURRENT_GUIDE = "Aktueller Guide"
L.AVAILABLE_GUIDES = "Verfügbare Guides"
L.DETAILS = "Details"
L.MAIN_FRAME_WIDTH = "Fensterbreite"
L.MAIN_FRAME_HEIGHT = "Fensterhöhe"
L.OTHER_GUIDES = "Andere Guides"
L.LOAD_GUIDE = "Guide laden"
L.RESET_GUIDE = "Guide zurücksetzen"

end

addon.L = L
