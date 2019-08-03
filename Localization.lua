local addonName, addon = ...

function getLocalizedStrings(locale)
local L = {}

if locale == "enUS" then

L.TITLE = addonName
L.SHOW_MAINFRAME = "Show window"
L.LOCK_MAINFRAME = "Lock window"
L.LOAD_MESSAGE = "Guidelime: Loading guide \"%s\""
L.HIDE_COMPLETED_STEPS = "Hide completed steps"
L.HIDE_UNAVAILABLE_STEPS = "Hide unavailable steps"
L.CURRENT_GUIDE = "Current guide"
L.AVAILABLE_GUIDES = "Available guides"
L.DETAILS = "Details"
L.MAIN_FRAME_WIDTH = "Window width"
L.MAIN_FRAME_HEIGHT = "Window height"
L.MAIN_FRAME_ALPHA = "Window alpha"
L.MAX_NUM_OF_STEPS = "Number of steps shown (0 = unlimited)"
L.MAX_NUM_OF_MARKERS = "Number of map markers (0 = unlimited)"
L.SHOW_ARROW = "Show arrow"
L.ARROW_ALPHA = "Arrow alpha"
L.ARROW_STYLE = "Arrow style"
L.ARROW_STYLE1 = "lime"
L.ARROW_STYLE2 = "arrow"
L.MISSING_PREQUEST = "The following quest was skipped:"
L.MISSING_PREQUESTS = "The following quests were skipped:"
L.OTHER_GUIDES = "Other guides"
L.LOAD_GUIDE = "Load guide"
L.RESET_GUIDE = "Reset guide"
L.EDIT_GUIDE = "Edit guide"
L.URL = "URL"
L.QUEST_REQUIRED_LEVEL = "Required level for %s is %s"
L.STEP_MANUAL = "Click here when you have completed this step"
L.STEP_SKIP = "Click here in order to skip this step"
L.STEP_FOLLOWUP_QUEST = "If you skip %s you will miss the following quest later on"
L.STEP_FOLLOWUP_QUESTS = "If you skip %s you will miss the following quests later on"
L.SHOW_SUGGESTED_QUEST_LEVELS = "Show suggested level for a quest"
L.SHOW_MINIMUM_QUEST_LEVELS = "Show minimum level for a quest"
L.SHOW_TOOLTIPS = "Show tooltips"
L.NO_GUIDE_LOADED = "You have not yet selected a guide. Click here in order to start by loading a guide."
L.GUIDE_FINISHED = "Your current guide has been finished. Click here in order to load another guide."
L.GUIDE_FINISHED_NEXT = "Your current guide has been finished. Click here in order to continue with %s."
L.AUTO_COMPLETE_QUESTS = "Automatically accept/turn in quests"
L.EDITOR = "Editor"
L.SAVE_GUIDE = "Save guide"
L.CUSTOM_GUIDES = "Custom guides"
L.SAVE_MSG = "Save guide as \"%s\"?" 
L.OVERWRITE_MSG = "Overwrite existing guide \"%s\"?" 
L.EDITOR_TOOLTIP_NAME = "Set name and level range of the guide\ne.g.: \"[N1-6Coldridge Valley]\""
L.EDITOR_TOOLTIP_NEXT = "Set name and level range of the next guide following the current guide\ne.g.: \"[NX6-12Dun Morogh]\""
L.EDITOR_TOOLTIP_DETAILS = "Enter detailed guide description\ne.g.: \"[D My personal guide to the gnome/dwarf starting zone]\""
L.EDITOR_TOOLTIP_GUIDE_APPLIES = "Set which faction/races/classes this guide applies to\ne.g.: \"[GA Dwarf,Gnome]\""
L.EDITOR_TOOLTIP_APPLIES = "Set which faction/races/classes the current step applies to\ne.g.: \"[A Dwarf,Rogue]\""
L.EDITOR_TOOLTIP_OPTIONAL = "Mark the current step as optional\ni.e.: \"[O]\""
L.EDITOR_TOOLTIP_OPTIONAL_COMPLETE_WITH_NEXT = "Mark the current step to be automatically completed whenever the following step is completed\ni.e.: \"[OC]\""
L.EDITOR_TOOLTIP_QUEST = "Add a quest\ne.g.: \"[QA179]\" or \"[QC3361,2 A Refugee's Quandary]\""
L.EDITOR_TOOLTIP_GOTO = "Add coordinates of a target location\ne.g.: \"[G 29.93,71.2 Dun Morogh]\""
L.EDITOR_TOOLTIP_LOC = "Add coordinates of an additional location\ne.g.: \"[L 29.93,71.2 Dun Morogh]\""
L.EDITOR_TOOLTIP_XP = "This step requires the player to have reached a certain level / amount of experience on the current level\ne.g.: \"[XP8.5 half way to 9]\""
L.EDITOR_TOOLTIP_HEARTH = "The player should use the hearthstone\ni.e.: \"[H]\""
L.EDITOR_TOOLTIP_FLY = "The player should take a flight\ni.e.: \"[F]\""
L.EDITOR_TOOLTIP_TRAIN = "The player should visit the trainer\ni.e.: \"[T]\""
L.EDITOR_TOOLTIP_SET_HEARTH = "The player should set the hearthstone at the inn\ni.e.: \"[S]\""
L.EDITOR_TOOLTIP_GET_FLIGHT_POINT = "The player should get a new flight point\ni.e.: \"[P]\""
L.EDITOR_TOOLTIP_VENDOR = "The player should vendor / resupply here\ni.e.: \"[V]\""
L.EDITOR_TOOLTIP_REPAIR = "The player should repair here\ni.e.: \"[R]\""
L.EDITOR_TOOLTIP_ZONE = "This is not required for all but the first coordinates. If omitted it is assumed that it is in the same zone as previous coordinates."
L.NAME = "Name"
L.MINIMUM_LEVEL = "Minimum level"
L.MAXIMUM_LEVEL = "Maximum level"
L.QUEST_ACCEPT = "Accept" 
L.QUEST_TURNIN = "Turn in"
L.QUEST_COMPLETE = "Complete" 
L.QUEST_SKIP = "Skip"
L.QUEST_S_TOOLTIP = "Only use this to point out to the player not to accept a certain quest"
L.QUEST_NAME = "Quest name"
L.QUEST_NAME_TOOLTIP = "Text to be shown. If omitted the name of the quest will be shown. If this is \"-\" no text will be shown"
L.QUEST_ID = "Quest id"
L.QUEST_ID_TOOLTIP = "Quest id. If omitted a quest of the given name is searched. Since names can be ambiguous you might have to enter the quest id."
L.QUEST_OBJECTIVE = "Quest objective"
L.QUEST_OBJECTIVE_TOOLTIP = "Number of the objective that should be completed (1 for first, 2 for second, ...). Can be specified when only a single objective is to be tracked. If omitted all objectives are required."
L.QUEST_ADD_COORDINATES = "Add coordinates"
L.QUEST_ADD_COORDINATES_TOOLTIP = "If coordinates for a quest step are present in the quests database, a go to step will be added"
L.XP_LEVEL = "Level only"
L["XP_LEVEL+"] = "Points obtained"
L["XP_LEVEL-"] = "Points remaining"
L["XP_LEVEL%"] = "Percentage"
L["XP_LEVEL+_TOOLTIP"] = "Player has to have reached the specified level and has to have obtained the specified amount of points"
L["XP_LEVEL-_TOOLTIP"] = "Player has to have at most the specified amount of points remaining until reaching the specified level"
L["XP_LEVEL%_TOOLTIP"] = "Player has to have reached the specified level and has to have obtained the specified percentage of points towards the next level"
L.XP_TEXT = "Text"
L.XP_TEXT_TOOLTIP = "Text to be shown. If omitted this element will be shown as \"%s\"."
L.SHOW_MAP = "Show on map"
L.QUEST_INFO = "Quest info"
L.SUGGESTED_LEVEL = "Suggested level"
L.TYPE = "Type" -- as in type of a quest; elite, ...
L.GOTO_INFO = "Coordinates info"
L.QUEST_ACCEPT_POS = "Started by"
L.QUEST_COMPLETE_POS = "Completed with"
L.QUEST_TURNIN_POS = "Turned in at"
L.AT = "at" -- as in npc xyz at (12,34)
L.ERROR_CODE_NOT_RECOGNIZED = "Parsing guide \"%s\": code [%s] not recognized in line \"%s\""
L.ERROR_GUIDE_HAS_NO_NAME = "Guide has no name"
L.ERROR_CODE_ZONE_NOT_FOUND = "Parsing guide \"%s\": zone not found in code [%s] in line \"%s\""
L.ERROR_NOT_A_NUMBER = "%s is not a number"
L.ERROR_QUEST_NOT_FOUND = "Quest \"%s\" was not found"
L.ERROR_QUEST_NOT_UNIQUE = "There is more than one quest \"%s\". Enter one of these ids: "
L.ERROR_ZONE_NOT_FOUND = "\"%s\" is not a zone. Enter one of these zone names: "
L.ERROR_OUT_OF_RANGE = "%s is not between %s and %s"
L.ERROR_QUEST_RACE_ONLY = "This quest is for the following races only: "
L.ERROR_QUEST_CLASS_ONLY = "This quest is for the following classes only: "
L.ZONE = "Zone"
L.LEVEL = "Level"
L.PART = "part" -- as in quest series: "The Missing Diplomat" part 17
L.CATEGORY = "Category"
L.QUEST_CHAIN = "Quest chain"
L.NEXT = "Next" -- as in next quest
L.PREVIOUS = "Previous" -- as in previous quest
L.OBJECTIVE = "Objective"
L.ENGLISH_NAME = "English name"
L.SKIP_CUTSCENES = "Skip cutscenes"
L.USE_QUESTIE_AS_DATA_SOURCE = "Use 'Questie' as data source"
L.USE_QUESTIE_AS_DATA_SOURCE_TOOLTIP = "When the addon 'Questie' is installed, it can be used as data source for quest coordinates.\nIt might contain more information than the internal quest database such as quest mob spawn locations."
L.USE_INTERNAL_DATA_SOURCE = "Use internal quest data source"
L.ADD_QUEST_COORDINATES = "Add quest coordinates"
L.ADD_QUEST_COORDINATES_MESSAGE = "Adds quest coordinates to all quest steps if available in the quest database. Existing quest coordinates will be replaced."
L.ADDED_QUEST_COORDINATES_MESSAGE = "%s quest coordinates have been added."
L.REMOVE_ALL_COORDINATES = "Remove all coordinates"
L.REMOVE_ALL_COORDINATES_MESSAGE = "All coordinate steps ([G...]) will be removed."
L.REMOVED_COORDINATES_MESSAGE = "%s coordinates have been removed."
L.AUTO_ADD_COORDINATES = "Automatically add coordinates to quest steps without coordinates"
L.DISCARD_CHANGES = "Discard changes"
L.IMPORT_GUIDE = "Import guide"
L.IMPORT_GUIDE_MESSAGE = "Import a guide written in plain text. Quest names should be in quotation marks(\"\"). Occasionally correct quest IDs have to be added manually. Lines with missing IDs or other errors will be marked. Marks are removed when you fix the errors and import again."
L.Alliance = "Alliance"
L.Horde = "Horde"

-- word lists used by the plain text parser

-- word lists for detecting the type of a quest. matched expression can run over the quest itself but it has to start before the quest e.g. `turn "xyz" in`
L.WORD_LIST_ACCEPT = " accept ; get ; pick up ; pick .- up ; take "
L.WORD_LIST_COMPLETE = " do ; complete ; kill ; loot ; finish "
L.WORD_LIST_TURN_IN = " turn in ; turn .- in ; deliver "
L.WORD_LIST_SKIP = " skip ; ignore "

-- word lists for detecting when a quest name is followed by its part in a quest series there is a general case (N) and as much specific ones as needed (1-...)
L.WORD_LIST_PART_N = " part (%d) ; (%d)th part " -- the part number must be captured with ()
L.WORD_LIST_PART_1 = " first part ; 1st part "
L.WORD_LIST_PART_2 = " second part ; 2nd part "
L.WORD_LIST_PART_3 = " third part ; 3rd part "
L.WORD_LIST_PART_4 = " fourth part "
L.WORD_LIST_NEXT_PART = " next part "

-- word lists for detecting when previous quest steps are being referenced
-- prefix and suffix which should not be part of the resulting quest tag can be captured with ()
L.WORD_LIST_COMPLETE_LAST = "( complete )it( );( finish )it( )"
L.WORD_LIST_TURN_IN_LAST = "( turn )it( in )"
L.WORD_LIST_COMPLETE_LAST_TWO = "( complete )both( );( finish )both( )"
L.WORD_LIST_TURN_IN_LAST_TWO = "( turn )both( in )"

-- word lists for catching the word quest when no specific quest tag could be found e.g. `turn in all remaining quests`
L.WORD_LIST_QUESTS = " quests "
L.WORD_LIST_QUEST = " quest "

-- word lists for detecting non-quest steps
-- prefix and suffix which should not be part of the resulting quest tag can be captured with ()
L.WORD_LIST_XP = "( level )%d+( );( grind until )%d+( );( req. )%d+( )"
L.WORD_LIST_SET_HEARTH = "( set hearth in )%a+( );( set hearth to )%a+( );( set hearthstone in )%a+( );( set hearthstone to )%a+( );( )(set hearth );( )(set hearthstone )" 
L.WORD_LIST_HEARTH = "( hearth to )%a+( );( )(hearth )"
L.WORD_LIST_FLY = "( fly to )%a+( );( )(fly )"
L.WORD_LIST_GET_FLIGHT_POINT = "( get flight ?point in )%a+( );( activate flight ?point in )%a+( );( get flight ?point )%a+( );( activate flight ?point )%a+( );( get )%a+( flight ?point );( activate )%a+( flight ?point );( )(flight ?point )"
L.WORD_LIST_VENDOR = " purchase ; buy ; vendor"
L.WORD_LIST_REPAIR = " repair "
L.WORD_LIST_TRAIN = " train ; skills "


elseif locale == "deDE" then

L.TITLE = addonName
L["ADD_QUEST_COORDINATES"] = "Koordinaten hinzufügen"
L["ADD_QUEST_COORDINATES_MESSAGE"] = "Es werden Quest-Koordinaten zu allen Schritten hinzugefügt, sofern diese in der Quest-Datenbank vorliegen. Vorhandene Quest-Koordinaten werden ersetzt."
L["ADDED_QUEST_COORDINATES_MESSAGE"] = "%s Quest-Koordinaten wurden hinzugefügt."
L["Alliance"] = "Allianz"
L["ARROW_ALPHA"] = "Richtungspfeil-Alpha"
L["ARROW_STYLE"] = "Richtungspfeil-Stil"
L["ARROW_STYLE1"] = "Limette"
L["ARROW_STYLE2"] = "Pfeil"
L["AT"] = "in"
L["AUTO_ADD_COORDINATES"] = "Automatisch Koordinaten für Quest-Schritte ergänzen, bei denen diese fehlen"
L["AUTO_COMPLETE_QUESTS"] = "Quests automatisch annehmen/einlösen"
L["AVAILABLE_GUIDES"] = "Verfügbare Guides"
L["CATEGORY"] = "Kategorie"
L["CURRENT_GUIDE"] = "Aktueller Guide"
L["CUSTOM_GUIDES"] = "Eigene Guides"
L["DETAILS"] = "Details"
L["DISCARD_CHANGES"] = "Änderungen verwerfen"
L["EDIT_GUIDE"] = "Guide bearbeiten"
L["EDITOR"] = "Editor"
L["EDITOR_TOOLTIP_APPLIES"] = [=[Einstellen für welche Faktion/Rassen/Klassen der aktuelle Schritt gültig ist
z.B.: "[A Dwarf,Rogue]"]=]
L["EDITOR_TOOLTIP_DETAILS"] = [=[Detaillierte Guidebeschreibung eingeben
z.B.: "[D Mein eigener Guide für das Startgebiet der Gnome und Zwerge]"]=]
L["EDITOR_TOOLTIP_FLY"] = [=[Der Spieler soll eine Flugroute nehmen
d.h.: "[F]"]=]
L["EDITOR_TOOLTIP_GET_FLIGHT_POINT"] = [=[Der Spieler soll einen neuen Flugpunkt aktivieren
d.h.: "[P]"]=]
L["EDITOR_TOOLTIP_GOTO"] = [=[Koordinaten eines Zielpunktes hinzufügen
z.B.: "[G 29.93,71.2 Dun Morogh]"]=]
L["EDITOR_TOOLTIP_GUIDE_APPLIES"] = [=[Einstellen für welche Faktion/Rassen/Klassen der Guide verwendet werden kann (englische Bezeichnungen)
z.B.: "[GA Dwarf,Gnome]"]=]
L["EDITOR_TOOLTIP_HEARTH"] = [=[Der Spieler soll den Ruhestein verwenden
d.h.: "[H]"]=]
L["EDITOR_TOOLTIP_LOC"] = "Koordinaten eines zusätzlichen Punktes hinzufügen\\nz.B.: \\\"[L 29.93,71.2 Dun Morogh]\\\""
L["EDITOR_TOOLTIP_NAME"] = [=[Namen und Stufenbereich des Guides angeben
z.B.: "[N1-6Coldridgetal]"]=]
L["EDITOR_TOOLTIP_NEXT"] = [=[Namen und Stufenbereich des Guides angeben der auf diesen folgt
z.B.: "[NX6-12Dun Morogh]"]=]
L["EDITOR_TOOLTIP_OPTIONAL"] = [=[Den aktuellen Schritt als optional markieren
d.h.: "[O]"]=]
L["EDITOR_TOOLTIP_OPTIONAL_COMPLETE_WITH_NEXT"] = [=[Der aktuelle Schritt soll automatisch als erledigt markiert werden, sobald der darauffolgende Schritt erledigt ist
d.h.: "[OC]"]=]
L["EDITOR_TOOLTIP_QUEST"] = [=[Eine Quest hinzufügen
z.B.: "[QA179]" oder "[QC3361,2 Dilemma eines Flüchtlings]"]=]
L["EDITOR_TOOLTIP_REPAIR"] = [=[Der Spieler soll reparieren
d.h.: "[R]"]=]
L["EDITOR_TOOLTIP_SET_HEARTH"] = [=[Der Spieler soll den Ruhestein in der Taverne binden
d.h.: "[S]"]=]
L["EDITOR_TOOLTIP_TRAIN"] = [=[Der Spieler soll den Trainer aufsuchen
d.h.: "[T]"]=]
L["EDITOR_TOOLTIP_VENDOR"] = [=[Der Spieler soll verkaufen / sich neu ausrüsten
d.h.: "[V]"]=]
L["EDITOR_TOOLTIP_XP"] = [=[Bei diesem Schritt wird vom Spieler erwartet, dass eine bestimmter Stufe / ein bestimmtes Maß an Erfahrung erreicht worden ist
z.B.: "[XP8.5 die Hälfte der Stufe bis 9]"]=]
L["EDITOR_TOOLTIP_ZONE"] = "Diese Angabe ist nur für die ersten Koordinaten erforderlich. Wenn keine Zone angegeben wird, wird angenommen, dass die Zone dieselbe ist wie bei vorangehenden Koordinaten."
L["ENGLISH_NAME"] = "Name (Englisch)"
L["ERROR_CODE_NOT_RECOGNIZED"] = "Lese Guide \"%s\": Code [%s] nicht erkannt in Zeile \"%s\""
L["ERROR_CODE_ZONE_NOT_FOUND"] = "Lese Guide \"%s\": Zone nicht gefunden in Code [%s] in Zeile \"%s\""
L["ERROR_GUIDE_HAS_NO_NAME"] = "Guide hat keinen Namen"
L["ERROR_NOT_A_NUMBER"] = "%s ist keine Zahl"
L["ERROR_OUT_OF_RANGE"] = "%s ist nicht zwischen %s und %s"
L["ERROR_QUEST_CLASS_ONLY"] = "Diese Quest ist nur für die folgenden Klassen verfügbar: "
L["ERROR_QUEST_NOT_FOUND"] = "Quest \"%s\" nicht gefunden"
L["ERROR_QUEST_NOT_UNIQUE"] = "Es gibt mehr als eine Quest \"%s\". Eine der folgenden IDs angeben: "
L["ERROR_QUEST_RACE_ONLY"] = "Diese Quest ist nur für die folgenden Rassen verfügbar: "
L["ERROR_ZONE_NOT_FOUND"] = "\"%s\" ist keine Zone. Bitte einer der folgenden Zonen eingeben: "
L["GOTO_INFO"] = "Koordinaten-Info"
L["GUIDE_FINISHED"] = "Der aktuelle Guide ist abgeschlossen. Klicke hier um einen neuen Guide auszuwählen."
L["GUIDE_FINISHED_NEXT"] = "Der aktuelle Guide ist abgeschlossen. Klicke hier um mit %s fortzufahren."
L["HIDE_COMPLETED_STEPS"] = "Abgeschlossene Schritte verstecken"
L["HIDE_UNAVAILABLE_STEPS"] = "Nicht verfügbare Schritte verstecken"
L["Horde"] = "Horde"
L["LEVEL"] = "Stufe"
L["LOAD_GUIDE"] = "Guide laden"
L["LOAD_MESSAGE"] = "Guidelime: Lade Guide \"%s\""
L["LOCK_MAINFRAME"] = "Fenster feststellen"
L["MAIN_FRAME_ALPHA"] = "Fenster-Alpha"
L["MAIN_FRAME_HEIGHT"] = "Fensterhöhe"
L["MAIN_FRAME_WIDTH"] = "Fensterbreite"
L["MAX_NUM_OF_MARKERS"] = "Kartenmarkierungen (0 = unbegrenzt)"
L["MAX_NUM_OF_STEPS"] = "Angezeigte Schritte (0 = unbegrenzt)"
L["MAXIMUM_LEVEL"] = "Maximal-Stufe"
L["MINIMUM_LEVEL"] = "Minimal-Stufe"
L["MISSING_PREQUEST"] = "Folgende Quest wurde übersprungen:"
L["MISSING_PREQUESTS"] = "Folgende Quests wurden übersprungen:"
L["NAME"] = "Name"
L["NEXT"] = "Nächste"
L["NO_GUIDE_LOADED"] = "Du hast noch keinen Guide ausgewählt. Klicke hier um einen Guide auszuwählen."
L["OBJECTIVE"] = "Ziel"
L["OTHER_GUIDES"] = "Andere Guides"
L["OVERWRITE_MSG"] = "Den vorhandenen Guide \"%s\" überschreiben?"
L["PART"] = "Teil"
L["PREVIOUS"] = "Vorhergehende"
L["QUEST_ACCEPT"] = "Annehmen"
L["QUEST_ACCEPT_POS"] = "Fängt an bei"
L["QUEST_ADD_COORDINATES"] = "Koordinaten hinzufügen"
L["QUEST_ADD_COORDINATES_TOOLTIP"] = "Sofern in der Quest-Datenbank verfügbar, wird ein Koordinaten-Schritt ([G...]) hinzugefügt"
L["QUEST_CHAIN"] = "Quest-Reihe"
L["QUEST_COMPLETE"] = "Erledigen"
L["QUEST_COMPLETE_POS"] = "Erledigt durch"
L["QUEST_ID"] = "Quest-ID"
L["QUEST_ID_TOOLTIP"] = "Quest-ID. Wenn nicht angegeben wird nach einer Quest mit dem angegebenen Namen gesucht. Da der Name nicht eindeutig sein muss, kann es erforderlich sein die ID anzugeben."
L["QUEST_INFO"] = "Quest-Info"
L["QUEST_NAME"] = "Quest-Name"
L["QUEST_NAME_TOOLTIP"] = "Angezeigter Text. Wenn nich angegeben wird der Name der Quest angezeigt. Wird \"-\" angegeben wird kein Text angezeigt."
L["QUEST_OBJECTIVE"] = "Questziel"
L["QUEST_OBJECTIVE_TOOLTIP"] = "Nummer des Questziel welches vervollständigt werden soll (1 für das Erste, 2 für das Zweite, ...). Kann angegeben werden wenn nur ein einzelnes Ziel verfolgt wird. Wenn es nicht angegeben wird, sind alle Ziele erforderlich."
L["QUEST_REQUIRED_LEVEL"] = "Mindeststufe für %s ist %s"
L["QUEST_S_TOOLTIP"] = "Verwenden wenn der Spieler darauf aufmerksam gemacht werden soll eine bestimmte Quest nicht anzunehmen"
L["QUEST_SKIP"] = "Überspringen"
L["QUEST_TURNIN"] = "Abgeben"
L["QUEST_TURNIN_POS"] = "Abgegeben bei"
L["REMOVE_ALL_COORDINATES"] = "Koordinaten entfernen"
L["REMOVE_ALL_COORDINATES_MESSAGE"] = "Alle Koordinaten-Schritte ([G...]) werden entfernt."
L["REMOVED_COORDINATES_MESSAGE"] = "%s Koordinaten wurden entfernt."
L["RESET_GUIDE"] = "Guide zurücksetzen"
L["SAVE_GUIDE"] = "Guide speichern"
L["SAVE_MSG"] = "Guide speichern als \"%s\"?"
L["SHOW_ARROW"] = "Richtungspfeil anzeigen"
L["SHOW_MAINFRAME"] = "Fenster anzeigen"
L["SHOW_MAP"] = "Auf der Karte anzeigen"
L["SHOW_MINIMUM_QUEST_LEVELS"] = "Erforderliche Stufe einer Quest anzeigen"
L["SHOW_QUEST_LEVELS"] = "Quest-Stufe anzeigen"
L["SHOW_SUGGESTED_QUEST_LEVELS"] = "Empfohlene Stufe einer Quest anzeigen"
L["SHOW_TOOLTIPS"] = "Tooltips anzeigen"
L["SKIP_CUTSCENES"] = "Zwischensequenzen überspringen"
L["STEP_FOLLOWUP_QUEST"] = "Wenn du %s überspringst, kannst du folgende Quest später nicht erledigen"
L["STEP_FOLLOWUP_QUESTS"] = "Wenn du %s überspringst, kannst du folgende Quests nicht erledigen"
L["STEP_MANUAL"] = "Hier klicken, wenn dieser Schritt erledigt ist"
L["STEP_SKIP"] = "Hier klicken, um diesen Schritt zu überspringen"
L["SUGGESTED_LEVEL"] = "Empfohlene Stufe"
L["TYPE"] = "Art"
L["URL"] = "URL"
L["USE_INTERNAL_DATA_SOURCE"] = "Interne Quest-Datenbank verwenden"
L["USE_QUESTIE_AS_DATA_SOURCE"] = "'Questie' als Datenquelle verwenden"
L["USE_QUESTIE_AS_DATA_SOURCE_TOOLTIP"] = [=[Wenn das Addon 'Questie' installiert ist, kann dieses als Datenquelle für Quest-Koordinaten genutzt werden.
Dort sind eventuell Informationen vorhanden, die in der internen Quest-Datenbank nicht zur Verfügung stehen, wie beispielsweise Koordinaten von Quest-Gegnern.]=]
L["XP_LEVEL"] = "Nur Stufe"
L["XP_LEVEL-"] = "Verbleibende Punkte"
L["XP_LEVEL%"] = "Prozentualer Anteil"
L["XP_LEVEL%_TOOLTIP"] = "Der Spieler muss die angegebene Stufe sowie zusätzlich den angebenen prozentualen Anteil an Erfahrungspunkten bis zum Erreichen der nächsten Stufe erreicht haben"
L["XP_LEVEL-_TOOLTIP"] = "Dem Spieler dürfen höchstens die angegebene Anzahl Erfahrungspunkte bis zum Erreichen der angegebenen Stufe fehlen"
L["XP_LEVEL+"] = "Erhaltene Punkte"
L["XP_LEVEL+_TOOLTIP"] = "Der Spieler muss die angegebene Stufe sowie zusätzlich die angegebene Anzahl Erfahrungspunkte erreicht haben"
L["XP_TEXT"] = "Text"
L["XP_TEXT_TOOLTIP"] = "Angezeigter Text. Wenn kein Text angegeben wird, wird \"%s\" angezeigt."
L["ZONE"] = "Zone"

elseif locale == "frFR" then

L.TITLE = addonName
L["Alliance"] = "Alliance"
L["ARROW_ALPHA"] = "Transparence de la flèche"
L["ARROW_STYLE"] = "Style de la flèche"
L["ARROW_STYLE1"] = "lime"
L["ARROW_STYLE2"] = "flèche"
L["AUTO_COMPLETE_QUESTS"] = "Automatiquement accepter / rendre les quêtes"
L["AVAILABLE_GUIDES"] = "Guides disponibles"
L["CATEGORY"] = "Catégorie "
L["CURRENT_GUIDE"] = "Guide actuel"
L["CUSTOM_GUIDES"] = "Guides personnalisés"
L["DETAILS"] = "Détails"
L["EDIT_GUIDE"] = "Modifier le guide"
L["EDITOR"] = "Éditeur"
L["EDITOR_TOOLTIP_APPLIES"] = [=[Indiquer à quelle faction / races / classes s'applique l'étape actuelle,
par exemple : "[A Dwarf,Rogue]"]=]
L["EDITOR_TOOLTIP_DETAILS"] = [=[Entrer une description détaillée du guide,
par exemple : "[D Mon guide pour la zone de départ nain / gnome]"]=]
L["EDITOR_TOOLTIP_FLY"] = "Le joueur devrait prendre un trajet aérien : \"[F]\""
L["EDITOR_TOOLTIP_GET_FLIGHT_POINT"] = "Le joueur devrait prendre un nouveau point de trajet aérien : \"[P]\""
L["EDITOR_TOOLTIP_GOTO"] = [=[Ajouter les coordonnées d'une destination cible,
par exemple : "[G 29.93,71.2 Dun Morogh]"]=]
L["EDITOR_TOOLTIP_GUIDE_APPLIES"] = [=[Indiquer à quelle faction / races / classes s'applique ce guide,
par exemple : "[GA Dwarf,Gnome]"]=]
L["EDITOR_TOOLTIP_HEARTH"] = "Le joueur devrait utiliser sa pierre de foyer : \"[H]\""
L["EDITOR_TOOLTIP_LOC"] = "Ajouter les coordonnées d'un lieu supplémentaire, par exemple : \"[L 29.93,71.2 Dun Morogh]\""
L["EDITOR_TOOLTIP_NAME"] = [=[Entrer le nom et la fourchette de niveau du guide,
par exemple : "[N1-6Coldridge Valley]"]=]
L["EDITOR_TOOLTIP_NEXT"] = [=[Entrer le nom et la fourchette de niveau du guide suivant le guide actuel,
par exemple : "[NX6-12Dun Morogh]"]=]
L["EDITOR_TOOLTIP_OPTIONAL"] = "Marque l'étape actuelle comme étant optionnelle : \"[O]\""
L["EDITOR_TOOLTIP_OPTIONAL_COMPLETE_WITH_NEXT"] = "Marque l'étape actuelle pour être automatiquement complétée dès que l'étape suivante est complétée : \"[OC]\""
L["EDITOR_TOOLTIP_QUEST"] = [=[Ajouter une quête,
par exemple : "[QA179]" ou "[QC3361,2 Les malheurs d'un réfugié]"]=]
L["EDITOR_TOOLTIP_REPAIR"] = "Le joueur devrait réparer ici : \"[R]\""
L["EDITOR_TOOLTIP_SET_HEARTH"] = "Le joueur devrait lier sa pierre de foyer à l'auberge : \"[S]\""
L["EDITOR_TOOLTIP_TRAIN"] = "Le joueur devrait visiter l'entraineur de sa classe : \"[T]\""
L["EDITOR_TOOLTIP_VENDOR"] = "Le joueur devrait vendre / se réapprovisionner ici : \"[V]\""
L["EDITOR_TOOLTIP_XP"] = [=[Cette étape nécessite que le joueur ait atteint un certain niveau / une certaine quantité d'expérience du niveau actuel,
par exemple : "[XP8.5 à mi-chemin de 9]"]=]
L["EDITOR_TOOLTIP_ZONE"] = "Ce n'est pas nécessaire pour toutes les coordonnées sauf la première. Si omis, il est supposé qu'il se trouve dans la même zone que les coordonnées précédentes."
L["ENGLISH_NAME"] = "Nom anglais"
L["ERROR_CODE_NOT_RECOGNIZED"] = "Analyse du guide \"%s\" : le code [%s] n'est pas reconnu à la ligne \"%s\""
L["ERROR_CODE_ZONE_NOT_FOUND"] = "Analyse du guide \"%s\" : la zone [%s] n'est pas trouvée à la ligne \"%s\""
L["ERROR_GUIDE_HAS_NO_NAME"] = "Le guide n'a pas de nom"
L["ERROR_NOT_A_NUMBER"] = "%s n'est pas un nombre"
L["ERROR_OUT_OF_RANGE"] = "%s n'est pas entre %s et %s"
L["ERROR_QUEST_CLASS_ONLY"] = "Cette quête est seulement pour les classes suivantes :"
L["ERROR_QUEST_NOT_FOUND"] = "La quête \"%s\" n'a pas été trouvée"
L["ERROR_QUEST_NOT_UNIQUE"] = "Il y a plus d'une fois la quête \"%s\". Entrer un de ces identifiants :"
L["ERROR_QUEST_RACE_ONLY"] = "Cette quête est seulement pour les races suivantes :"
L["ERROR_ZONE_NOT_FOUND"] = "\"%s\" n'est pas une zone. Entrer un de ces noms de zone :"
L["GOTO_INFO"] = "Coordonnées"
L["GUIDE_FINISHED"] = "Le guide actuel est terminé. Cliquer ici pour charger un autre guide."
L["GUIDE_FINISHED_NEXT"] = "Le guide actuel est terminé. Cliquer ici pour continuer avec %s."
L["HIDE_COMPLETED_STEPS"] = "Cacher les étapes terminées"
L["HIDE_UNAVAILABLE_STEPS"] = "Cacher les étapes indisponibles"
L["Horde"] = "Horde"
L["LEVEL"] = "Niveau"
L["LOAD_GUIDE"] = "Charger le guide"
L["LOAD_MESSAGE"] = "Guidelime : Chargement du guide \"%s\""
L["LOCK_MAINFRAME"] = "Verrouiller la fenêtre"
L["MAIN_FRAME_ALPHA"] = "Transparence de la fenêtre"
L["MAIN_FRAME_HEIGHT"] = "Hauteur de la fenêtre"
L["MAIN_FRAME_WIDTH"] = "Largeur de la fenêtre"
L["MAX_NUM_OF_MARKERS"] = "Nombre de marqueurs sur la carte (0 = illimité)"
L["MAX_NUM_OF_STEPS"] = "Nombre d'étapes affichées (0 = illimité)"
L["MAXIMUM_LEVEL"] = "Niveau maximum"
L["MINIMUM_LEVEL"] = "Niveau minimum "
L["MISSING_PREQUEST"] = "La quête suivante a été passée :"
L["MISSING_PREQUESTS"] = "Les quêtes suivantes ont été passées :"
L["NAME"] = "Nom "
L["NEXT"] = "Suivant"
L["NO_GUIDE_LOADED"] = "Vous n'avez pas sélectionné de guide. Cliquez ici pour charger un guide."
L["OBJECTIVE"] = "Objectif "
L["OTHER_GUIDES"] = "Autres guides"
L["OVERWRITE_MSG"] = "Écraser le guide existant \"%s\" ?"
L["PART"] = "partie"
L["PREVIOUS"] = "Précédent"
L["QUEST_ACCEPT"] = "Accepter"
L["QUEST_COMPLETE"] = "Compléter"
L["QUEST_CHAIN"] = "Suite de quête"
L["QUEST_ID"] = "Identifiant de la quête"
L["QUEST_ID_TOOLTIP"] = "Identifiant de la quête. Si omis, une quête du nom donné est recherchée. Comme les noms peuvent être ambigus, vous devrez peut-être entrer l'identifiant de la quête."
L["QUEST_INFO"] = "Quête"
L["QUEST_NAME"] = "Nom de la quête"
L["QUEST_NAME_TOOLTIP"] = "Texte à afficher. Si omis, le nom de la quête sera affiché. Si \"-\" est entré aucun texte ne s'affichera."
L["QUEST_OBJECTIVE"] = "Objectif de la quête"
L["QUEST_OBJECTIVE_TOOLTIP"] = "Nombre d'objectifs à compléter (1 pour le premier, 2 pour le second...). Peut être spécifié quand un seul objectif doit être suivi. Si omis, tous les objectifs sont requis."
L["QUEST_REQUIRED_LEVEL"] = "Le niveau requis pour %s est %s"
L["QUEST_SKIP"] = "Passer"
L["QUEST_S_TOOLTIP"] = "Ne l'utilisez que pour indiquer au joueur de ne pas accepter une quête précise"
L["QUEST_TURNIN"] = "Rendre"
L["RESET_GUIDE"] = "Réinitialiser le guide"
L["SAVE_GUIDE"] = "Enregistrer le guide"
L["SAVE_MSG"] = "Enregistrer le guide sous \"%s\" ?"
L["SHOW_ARROW"] = "Afficher la flèche"
L["SHOW_MAINFRAME"] = "Afficher la fenêtre"
L["SHOW_MAP"] = "Afficher sur la carte"
L["SHOW_QUEST_LEVELS"] = "Afficher le niveau des quêtes"
L["SHOW_TOOLTIPS"] = "Afficher les infobulles"
L["STEP_FOLLOWUP_QUEST"] = "Si vous passez la quête %s vous n'aurez pas accès à la quête suivante plus tard"
L["STEP_FOLLOWUP_QUESTS"] = "Si vous passez la quête %s vous n'aurez accès aux quêtes suivantes plus tard"
L["STEP_MANUAL"] = "Cliquez ici lorsque vous avez complété cette étape"
L["STEP_SKIP"] = "Cliquez ici pour passer cette étape"
L["URL"] = "URL"
L["XP_LEVEL"] = "Niveau seulement"
L["XP_LEVEL-"] = "Points d'expérience restants"
L["XP_LEVEL%"] = "Pourcentage"
L["XP_LEVEL%_TOOLTIP"] = "Le joueur doit avoir atteint le niveau spécifié et doit avoir obtenu le pourcentage spécifié de points d'expérience vers le niveau suivant"
L["XP_LEVEL-_TOOLTIP"] = "Le joueur doit avoir au plus la quantité de points d'expérience restants spécifiée pour atteindre le niveau spécifié"
L["XP_LEVEL+"] = "Points d'expérience obtenus"
L["XP_LEVEL+_TOOLTIP"] = "Le joueur doit avoir atteint le niveau spécifié et doit avoir obtenu la quantité spécifiée de points d'expérience"
L["XP_TEXT"] = "Texte"
L["XP_TEXT_TOOLTIP"] = "Texte à afficher. Si omis, cette élément s'affichera comme \"%s\"."
L["ZONE"] = "Zone"

end
return L
end

addon.defaultL = getLocalizedStrings("enUS")
addon.L = setmetatable(getLocalizedStrings(GetLocale()), {__index = addon.defaultL})

function addon.testLocalization()
	if not addon.debugging then return end
	for i, locale in ipairs({"deDE", "enGB", "enUS", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW"}) do
		local L = getLocalizedStrings(locale)
		if next(L) ~= nil then
			for key, value in pairs(addon.defaultL) do
				if L[key] == nil then
					print("LIME: " .. locale .. " L." .. key .. " is missing")
				end
			end
		else
			--print("LIME: " .. locale .. " is missing")
		end		
	end	
end
