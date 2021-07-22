--[[
	@title
		Teleport Manager
	@author
		Chase
	@copyright
		2015 - OwlGaming
	@description
        Dynamic locations for /gotoplace, revised application for more efficient abilities.
		http://forums.owlgaming.net/showthread.php?36981

        Special thanks to Chaos
--]]
local gui = {}
local data = {}

function openLocationManager(locationData)
    if locationData and type(locationData) == "table" then
        data = locationData
    end

    terminateLocationManager()
    showCursor(true)

    local w, h = 400, 250

    gui.manager = guiCreateWindow(0, 0, w, h, "Teleport Locations Manager", false)
    exports.global:centerWindow(gui.manager)

    gui.grid = guiCreateGridList(10, 23, 380, 172, false, gui.manager)
    gui.colID = guiGridListAddColumn(gui.grid, "ID", 0.1)
    gui.colValue = guiGridListAddColumn(gui.grid, "Value", 0.2)
    gui.colDesc = guiGridListAddColumn(gui.grid, "Description", 0.4)
    gui.colCreator = guiGridListAddColumn(gui.grid, "Creator", 0.2)

    for v, k in pairs(data) do
        gui.row = guiGridListAddRow(gui.grid)
        local a, b = gui.grid, gui.row
        guiGridListSetItemText(a, b, gui.colID, k["id"], false, true)
        guiGridListSetItemText(a, b, gui.colValue, k["location_value"], false, false)
        guiGridListSetItemText(a, b, gui.colDesc, k["location_description"], false, false)
        guiGridListSetItemText(a, b, gui.colCreator, exports.cache:getUsernameFromId(k["location_creator"]) or "Unknown", false, false)
    end

    gui.addNew = guiCreateButton(10, 205, 71, 35, "Add New", false, gui.manager)
    checkElementUse(gui.addNew)
    addEventHandler("onClientGUIClick", gui.addNew, function ()
            openNewLocation()
            exports.global:playSoundSuccess()
    end, false)

    gui.deleteSelected = guiCreateButton(87, 205, 71, 35, "Delete", false, gui.manager)
    checkElementUse(gui.deleteSelected)
    addEventHandler("onClientGUIClick", gui.deleteSelected, function ()
            local r, c = guiGridListGetSelectedItem(gui.grid)
            if r ~= -1 and c ~= -1 then
                local id = guiGridListGetItemText(gui.grid, r, 1)
                triggerServerEvent("deleteLocation", localPlayer, localPlayer, id)
                exports.global:playSoundCreate()
                terminateLocationManager()
                updateLocations()
            else
                exports.global:playSoundError()
                exports.hud:sendBottomNotification(localPlayer, "Location Manager", "Please select a location from the list first.")
            end
    end, false)

    gui.closeWindow = guiCreateButton(299, 205, 91, 35, "Close", false, gui.manager)
    addEventHandler("onClientGUIClick", gui.closeWindow, function ()
            if source == gui.closeWindow then
                terminateLocationManager()
            end
    end, false)

    if not canManage(localPlayer) then
        guiSetEnabled(gui.addNew, false)
        guiSetEnabled(gui.deletedSelected, false)
    end
end
addEvent("client:openLocationManager", true)
addEventHandler("client:openLocationManager", root, openLocationManager)

function terminateLocationManager()
    if gui.manager and isElement(gui.manager) then
        destroyElement(gui.manager)
        gui.manager = nil
        showCursor(false)
        terminateNewLocation()
    end
end

function openNewLocation()
    terminateNewLocation()
    terminateLocationManager()
    showCursor(true)
    guiSetInputEnabled(true)

    if canManage(localPlayer) then

        local w, h = 400, 150
        local status = "Your current position will be used for this marker."
        local c1, c2, c3 = 255, 255, 255 --white
        local r = 1
        local failures = 0
        local fool = getElementData(localPlayer, "account:username")

        gui.newLocation = guiCreateWindow(0, 0, w, h, "Teleport Mark Creator", false)
        exports.global:centerWindow(gui.newLocation)

        gui.valueLabel = guiCreateLabel(10, 53, 54, 15, "Value", false, gui.newLocation)
        gui.valueInput = guiCreateEdit(10, 28, 150, 25, "", false, gui.newLocation)
        checkElementUse(gui.valueInput)

        gui.descLabel = guiCreateLabel(164, 53, 118, 15, "Location Description", false, gui.newLocation)
        gui.descInput = guiCreateEdit(164, 28, 226, 25, "", false, gui.newLocation)
        checkElementUse(gui.descInput)

        gui.localeMessage = guiCreateLabel(10, 78, 380, 22, status, false, gui.newLocation)
        gui.localeStatusColor = guiLabelSetColor(gui.localeMessage, c1, c2, c3)

        gui.newCreate = guiCreateButton(240, 110, 150, 30, "Create", false, gui.newLocation)
        checkElementUse(gui.newCreate)


            -- [[ Create Location Window ]] --
            addEventHandler("onClientGUIClick", gui.newCreate, function ()
                if source == gui.newCreate then --1
                    local newValue = guiGetText(gui.valueInput)
                    local newDesc = guiGetText(gui.descInput)

                    if string.len(newValue) < r or string.len(newDesc) < r then
                        exports.global:playSoundError()

                        -- Easter Egg failure messages
                        local failedGroup = {
                            "Neither the \"Value\" or \"Location Description\" can be left empty!",
                            "Try again fool, you can't leave either field empty!",
                            "Wow, seriously " .. fool ..", just fill something in for both! Not hard!",
                            "You're the reason we can't have nice things.",
                            "You had one freaking job " .. fool .. "!",
                            "Maybe it's not a well paying job, but so what?",
                            "We also need one in the description, if that helps.",
                            "No, but come on, you can't still be alive after failing this hard?",
                            "You need text in both Value and Location Description.",
                            "You need text in both Value and Location Description!",
                            "YoU nEed TExt iN boTh vaLUE aNd LocAtioN deSCRIPTioN!",
                            "Please enter a value for both fields!",
                            "Please enter a value for both fields!",
                            "Please enter a value for both fields!",
                            "Please enter a value for both fields!",
                            "Bye, " .. fool .. ".",
                            "TERMINATE"
                        }

                        if (failures < 17) then
                            failures = failures + 1
                        end

                        failureMessage = failedGroup[failures]
                            -- When it reaches 18, it disables the input OR it will continue to change the text
                            if failureMessage == "TERMINATE" then
                                checkElementUse(gui.descInput, false, "True", "True")
                                guiSetText(gui.localeMessage, failedGroup[1])
                            else
                                local c1, c2, c3 = 255, 0, 0 --red
                                guiLabelSetColor(gui.localeMessage, c1, c2, c3)
                                guiSetText(gui.localeMessage, failureMessage)
                            end

                        return
                    end


                        if string.len(newValue) >= 10 or string.len(newDesc) >= 25 then
                            guiSetText(gui.localeMessage, "Value and description can only be up to 10 and 25 characters long!")
                            local c1, c2, c3 = 255, 0, 0 --red
                            guiLabelSetColor(gui.localeMessage, c1, c2, c3)
						elseif string.find(newValue, " ") then
							guiSetText(gui.localeMessage, "Your value cannot contain a space!")
                            local c1, c2, c3 = 255, 0, 0 --red
                            guiLabelSetColor(gui.localeMessage, c1, c2, c3)
                        else
                            triggerServerEvent("addNewLocation", localPlayer, localPlayer, newValue, newDesc)
                            exports.global:playSoundCreate()
                            updateLocations()
                            terminateNewLocation()

                        end
                end
            end)

    gui.closeNewWindow = guiCreateButton(10, 110, 90, 30, "Cancel", false, gui.newLocation)
    addEventHandler("onClientGUIClick", gui.closeNewWindow,
        function()
            if source == gui.closeNewWindow then
                terminateNewLocation()
            end
        end)
    end
end

function terminateNewLocation()
    if gui.newLocation and isElement(gui.newLocation) then
        destroyElement(gui.newLocation)
        openLocationManager()
        gui.newLocation = nil
        showCursor(true)
        guiSetInputEnabled(false)
    end
end

function updateLocations()
    triggerServerEvent("server:openLocationManager", root, localPlayer)
end

-- [[ Permissions ]] --

function checkElementUse(element, property, value, value2)
    -- automatically will disable buttons, primarily; is used for other statements
    if not property then property = "Disabled" end
    if not value or not value2 then value = "True" value2 = "False"  end

    if exports.integration:isPlayerLeadAdmin(localPlayer) or exports.integration:isPlayerScripter(localPlayer) then
        return guiSetProperty(element, property, value2)
    else
        return guiSetProperty(element, property, value)
    end
end

function canView(thePlayer)
    -- groups who can open /tps
    if exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerLeadAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
        return true
    else
        return false
    end
end

function canManage(thePlayer)
    -- groups who can manage (add, delete) /tps
    -- same definition as checkElementUse()
    if exports.integration:isPlayerLeadAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
        return true
    else
        return false
    end
end
