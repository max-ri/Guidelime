local addonName, addon = ...

local L = {}

L.TITLE = addonName
L.SHOW_MAINFRAME = "show window"
L.LOCK_MAINFRAME = "lock window"
L.LOAD_MESSAGE = "Guidelime: Loading guide \"%s\""
L.HIDE_COMPLETED_STEPS = "hide completed steps"
L.HIDE_UNAVAILABLE_STEPS = "hide unavailable steps"
L.CURRENT_GUIDE = "Current guide"
L.AVAILABLE_GUIDES = "Available guides"
L.DETAILS = "Details"
L.MAIN_FRAME_WIDTH = "Window width"
L.MAIN_FRAME_HEIGHT = "Window height"
L.MAIN_FRAME_ALPHA = "Window Alpha"
L.SHOW_ARROW = "show arrow"
L.ARROW_ALPHA = "Arrow alpha"
L.MISSING_PREQUEST = "The following quest is skipped:"
L.MISSING_PREQUESTS = "The following quests are skipped:"
L.OTHER_GUIDES = "Other guides"
L.LOAD_GUIDE = "Load guide"
L.RESET_GUIDE = "Reset guide"
L.QUEST_REQUIRED_LEVEL = "Required level for %s is %s"
L.STEP_MANUAL = "Click here when you have completed this step"
L.STEP_SKIP = "Click here in order to skip this step"
L.STEP_FOLLOWUP_QUEST = "If you skip this step you will miss %s later on"
L.STEP_FOLLOWUP_QUESTS = "If you skip this step you will miss %s quests later on"
L.SHOW_QUEST_LEVELS = "show quest levels"
L.SHOW_TOOLTIPS = "show tooltips"
L.NO_GUIDE_LOADED = "You have not yet selected a guide. Click here in order to start by loading a guide."
L.GUIDE_FINISHED = "Your current guide has been finished. Click here in order to load another guide."
L.GUIDE_FINISHED_NEXT = "Your current guide has been finished. Click here in order to continue with %s."

local locale = GetLocale()

if locale == "deDE" then

L.SHOW_MAINFRAME = "Fenster anzeigen"
L.LOCK_MAINFRAME = "Fenster feststellen"
L.LOAD_MESSAGE = "Guidelime: Lade Guide \"%s\""
L.HIDE_COMPLETED_STEPS = "Abgeschlossene Schritte verstecken"
L.HIDE_UNAVAILABLE_STEPS = "Nicht verfügbare Schritte verstecken"
L.CURRENT_GUIDE = "Aktueller Guide"
L.AVAILABLE_GUIDES = "Verfügbare Guides"
L.DETAILS = "Details"
L.MAIN_FRAME_WIDTH = "Fensterbreite"
L.MAIN_FRAME_HEIGHT = "Fensterhöhe"
L.MAIN_FRAME_ALPHA = "Fenster-Alpha"
L.SHOW_ARROW = "Richtungspfeil anzeigen"
L.ARROW_ALPHA = "Richtungspfeil-Alpha"
L.MISSING_PREQUEST = "Folgende Quest wird übersprungen:"
L.MISSING_PREQUESTS = "Folgende Quests werden übersprungen:"
L.OTHER_GUIDES = "Andere Guides"
L.LOAD_GUIDE = "Guide laden"
L.RESET_GUIDE = "Guide zurücksetzen"
L.QUEST_REQUIRED_LEVEL = "Mindestlevel für %s ist %s"
L.STEP_MANUAL = "Hier klicken, wenn dieser Schritt erledigt ist"
L.STEP_MANUAL = "Hier klicken, um diesen Schritt zu überspringen"
L.STEP_FOLLOWUP_QUEST = "Wenn du diesen Schritt überspringst, kannst du später %s nicht erledigen"
L.STEP_FOLLOWUP_QUESTS = "Wenn du diesen Schritt überspringst, kannst du später %s Quests nicht erledigen"
L.SHOW_QUEST_LEVELS = "Quest-Level anzeigen"
L.SHOW_TOOLTIPS = "Tooltips anzeigen"
L.NO_GUIDE_LOADED = "Du hast noch keinen Guide ausgewählt. Klicke hier um einen Guide auszuwählen."
L.GUIDE_FINISHED = "Der aktuelle Guide ist abgeschlossen. Klicke hier um einen neuen Guide auszuwählen."
L.GUIDE_FINISHED_NEXT = "Der aktuelle Guide ist abgeschlossen. Klicke hier um mit %s fortzufahren."

end

addon.L = L
