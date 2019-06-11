local addonName, addon = ...

local L = {}

L.TITLE = addonName
L.SOME_OPTION = "some option"

local locale = GetLocale()

if locale == "deDE" then

L.SOME_OPTION = "eine Einstellung"

end

addon.L = L
