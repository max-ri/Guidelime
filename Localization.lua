local addonName, addon = ...

local L = {}

L.TITLE = addonName
L.SHOW_MAINFRAME = "show window"
L.LOAD_MESSAGE = "Guidelime: Loading guide \"%s\""
L.HIDE_COMPLETED_STEPS = "hide completed steps"
L.CURRENT_GUIDE = "Current guide"
L.AVAILABLE_GUIDES = "Available guides"
L.DETAILS = "Details"
L.MAIN_FRAME_WIDTH = "Window width"
L.MAIN_FRAME_HEIGHT = "Window height"

local locale = GetLocale()

if locale == "deDE" then

L.SHOW_MAINFRAME = "Fenster anzeigen"
L.LOAD_MESSAGE = "Guidelime: Lade Guide \"%s\""
L.HIDE_COMPLETED_STEPS = "Abgeschlossene Schritte verstecken"
L.CURRENT_GUIDE = "Aktueller Guide"
L.AVAILABLE_GUIDES = "Verfügbare Guides"
L.DETAILS = "Details"
L.MAIN_FRAME_WIDTH = "Fensterbreite"
L.MAIN_FRAME_HEIGHT = "Fensterhöhe"

end

addon.L = L
