-- // Chaos

PrisonGUI = {
    gridlist = {},
    column = {},
    window = {},
    button = {},
    label = {}
}

ToggleGateGUI = {
    button = {},
    window = {},
    combobox = {},
    label = {}
}

newPrisonerGUI = {
    edit = {},
    button = {},
    window = {},
    label = {},
    memo = {}
}

result = {}
-- { row.id, row.charid, row.charactername, row.jail_time, row.convictionDate, row.updatedBy, row.charges, row.cell, row.fine }

function PrisonGUIF(result)
        showCursor(true)

        local scr = {guiGetScreenSize()}
        local w, h = 928, 324
        local x, y = (scr[1]/2)-(w/2), (scr[2]/2)-(h/2)
        PrisonGUI.window[1] = guiCreateWindow(x, y, w, h, "Prison system", false)
        guiWindowSetSizable(PrisonGUI.window[1], false)

        PrisonGUI.gridlist[1] = guiCreateGridList(9, 21, 902, 217, false, PrisonGUI.window[1])
        guiGridListSetSortingEnabled(PrisonGUI.gridlist[1], true)
        PrisonGUI.column[1] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Unique ID", 0.1)
        PrisonGUI.column[7] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Cell", 0.05)
        PrisonGUI.column[2] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Name", 0.2)
        PrisonGUI.column[3] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Conviction date", 0.15)
        PrisonGUI.column[4] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Released in days", 0.1)
        PrisonGUI.column[8] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Released in hours", 0.1)
        PrisonGUI.column[10] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Online minutes", 0.08)
        PrisonGUI.column[5] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Last updated by", 0.1)
        PrisonGUI.column[9] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Fine", 0.1)
        PrisonGUI.column[6] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Charges", 0.5)

        PrisonGUI.button[1] = guiCreateButton(13, 241, 100, 73, "Close", false, PrisonGUI.window[1])
        guiSetProperty(PrisonGUI.button[1], "NormalTextColour", "FFAAAAAA")
        PrisonGUI.button[2] = guiCreateButton(129, 243, 119, 30, "Release prisoner", false, PrisonGUI.window[1])
        guiSetProperty(PrisonGUI.button[2], "NormalTextColour", "FFAAAAAA")
        PrisonGUI.button[3] = guiCreateButton(130, 280, 119, 30, "Add new prisoner", false, PrisonGUI.window[1])
        guiSetProperty(PrisonGUI.button[3], "NormalTextColour", "FFAAAAAA")
        PrisonGUI.button[4] = guiCreateButton(263, 243, 119, 30, "Update prisoner", false, PrisonGUI.window[1])
        guiSetProperty(PrisonGUI.button[4], "NormalTextColour", "FFAAAAAA")
        PrisonGUI.button[5] = guiCreateButton(588, 242, 134, 30, "Toggle gate number", false, PrisonGUI.window[1])
        guiSetProperty(PrisonGUI.button[5], "NormalTextColour", "FFAAAAAA")
        PrisonGUI.button[6] = guiCreateButton(588, 282, 134, 30, "Toggle all gates", false, PrisonGUI.window[1])
        guiSetProperty(PrisonGUI.button[6], "NormalTextColour", "FFAAAAAA")

        if pd_offline_jail or exports.integration:isPlayerTrialAdmin(getLocalPlayer()) then
            PrisonGUI.button[7] = guiCreateButton(263, 280, 119, 30, "Add offline prisoner", false, PrisonGUI.window[1])
            guiSetProperty(PrisonGUI.button[7], "NormalTextColour", "FFAAAAAA")
            addEventHandler("onClientGUIClick", PrisonGUI.button[7], function()
                addPrisonerGUI(source)
            end, false)
        end

        for _,res in ipairs(result) do
            local row = guiGridListAddRow( PrisonGUI.gridlist[1] )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[1], tostring( res[1] ), false, true )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[2], tostring( res[3] ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[3], tostring( res[5] ), false, false )
            if getPlayerFromName(tostring(res[3])) then
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[2], 0, 255, 0)
            end
            -- Time for some math...
            local days, hours, remainingtime = cleanMath(res[4])
            if remainingtime <= 0 and tonumber(res[10]) > 0 then
                days = "Awaiting"
                hours = "Online Time"
            end
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[4], tostring( days ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[8], tostring( hours ), false, false )
            if days=="Life" then
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 255, 0, 0)
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 255, 0, 0)
            elseif days=="Awaiting" and hours=="Release" then
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 255, 255, 0)
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 255, 255, 0)
            elseif hours=="Online Time" then
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 0, 93, 1)
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 0, 93, 1)
            end
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[5], tostring( res[6] ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[6], tostring( res[7] ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[7], tostring( res[8] ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[9], tostring( res[9] ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[10], tostring( res[10] ), false, false )
        end

        updateGates()

        addEventHandler("onClientGUIClick", PrisonGUI.button[1], function() -- Close
            destroyElement(PrisonGUI.window[1])
            showCursor(false)
        end, false )

        addEventHandler("onClientGUIClick", PrisonGUI.button[3], function()
            addPrisonerGUI(source)
        end, false)

        addEventHandler("onClientGUIClick", PrisonGUI.button[2], function()
            local r, c = guiGridListGetSelectedItem ( PrisonGUI.gridlist[1] )
            if r>=0 and c>=0 then
                local removeid = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 1 )
                local targetPlayer = getPlayerFromName(guiGridListGetItemText(PrisonGUI.gridlist[1], r, 3))
                if not isCloseTo(getLocalPlayer(), targetPlayer) then
                    outputChatBox("You must be near this prisoner to remove them.", 255, 0, 0)
                    return
                end
                triggerServerEvent("removePrisoner", resourceRoot, removeid, true)
            else
                outputChatBox("Make a selection first.", 255, 0, 0)
            end
            end, false)

        addEventHandler("onClientGUIClick", PrisonGUI.button[4], function()
            local r, c = guiGridListGetSelectedItem ( PrisonGUI.gridlist[1] )
            if r>=0 and c>=0 then
                local targetPlayer = getPlayerFromName(guiGridListGetItemText(PrisonGUI.gridlist[1], r, 3))
                if not isCloseTo(getLocalPlayer(), targetPlayer) then
                    outputChatBox("You must be near this prisoner to update them.", 255, 0, 0)
                    return
                end
                local ID = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 1 )
                local name = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 3 )
                local cell = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 2 )
                local days = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 5 )
                local hours = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 6 )
                local charges = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 10 )
                local fines = guiGridListGetItemText(PrisonGUI.gridlist[1], r, 9)
                local r = r+1
                addPrisonerGUI(source, name, cell, days, hours, charges, r, fines, ID)
            elseif r==-1 then
                outputChatBox("Make a selection first.", 255, 0, 0)
            end
            end, false)

        addEventHandler("onClientGUIDoubleClick", PrisonGUI.gridlist[1], gridlistDoubleClick, false) -- had to put it by refresh because of MTA bugs

        addEventHandler("onClientGUIClick", PrisonGUI.button[5], function() -- Toggle 1 gate
            toggleGate()
            end, false)

        addEventHandler("onClientGUIClick", PrisonGUI.button[6], function() -- Toggle all gates
                if getElementDimension(getLocalPlayer(  )) == gateDim then
                    local gui = {}
                    gui._placeHolders = {}

                    local screenWidth, screenHeight = guiGetScreenSize()
                    local windowWidth, windowHeight = 265, 143
                    local left = screenWidth/2 - windowWidth/2
                    local top = screenHeight/2 - windowHeight/2
                    gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Toggle all gates", false)
                    guiWindowSetSizable(gui["_root"], false)

                    gui["label"] = guiCreateLabel(10, 35, 231, 56, "Are you sure you want to toggle all the\n gates in the prison?", false, gui["_root"])
                    guiLabelSetHorizontalAlign(gui["label"], "center", false)
                    guiLabelSetVerticalAlign(gui["label"], "center")

                    gui["pushButton"] = guiCreateButton(30, 95, 81, 31, "Yes", false, gui["_root"])
                        addEventHandler("onClientGUIClick", gui["pushButton"], function()
                            triggerServerEvent("triggerAllGates", resourceRoot)
                            setTimer(updateGates, 500, 1)
                            destroyElement(gui["_root"])
                            local gui = nil
                        end, false)


                    gui["pushButton_2"] = guiCreateButton(150, 95, 81, 31, "No", false, gui["_root"])
                        addEventHandler("onClientGUIClick", gui["pushButton_2"], function()
                            destroyElement(gui["_root"])
                            local gui = nil
                        end, false)
                else
                    outputChatBox("You must be in the same interior/dimension as the gates.", 255, 0, 0)
                end
            end, false)

end
addEvent("PrisonGUI", true)
addEventHandler("PrisonGUI", getRootElement(), PrisonGUIF)

addEvent("PrisonGUI:Close", true)
addEventHandler("PrisonGUI:Close", getRootElement(),
    function ()
        destroyElement(PrisonGUI.window[1])
        showCursor( false )
    end
)

function gridlistDoubleClick()
    local r, c = guiGridListGetSelectedItem ( PrisonGUI.gridlist[1] )
    if r>=0 and c>=0 then
        local targetPlayer = getPlayerFromName(guiGridListGetItemText(PrisonGUI.gridlist[1], r, 3))
        if not isCloseTo(getLocalPlayer(), targetPlayer) then
            outputChatBox("You must be near this prisoner to update them.", 255, 0, 0)
            return
        end
        local ID = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 1 )
        local name = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 3 )
        local cell = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 2 )
        local days = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 5 )
        local hours = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 6 )
        local charges = guiGridListGetItemText ( PrisonGUI.gridlist[1], r, 10 )
        local fines = guiGridListGetItemText(PrisonGUI.gridlist[1], r, 9)
        local r = r+1

        addPrisonerGUI(source, name, cell, days, hours, charges, r, fines, ID)
    elseif r==-1 or c==-1 then
        outputChatBox("Make a selection first.", 255, 0, 0)
    end
end

addEvent( "PrisonGUI:Refresh", true )
addEventHandler( "PrisonGUI:Refresh", localPlayer, function(result)
        destroyElement(PrisonGUI.gridlist[1]) -- I don't want to have to do this either but MTA get cancer if you try to fill a gridlist when a user has a sort option on. It's a pain in my dick.

        PrisonGUI.gridlist[1] = guiCreateGridList(9, 21, 902, 217, false, PrisonGUI.window[1])
        guiGridListSetSortingEnabled(PrisonGUI.gridlist[1], true)
        PrisonGUI.column[1] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Unique ID", 0.1)
        PrisonGUI.column[7] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Cell", 0.05)
        PrisonGUI.column[2] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Name", 0.2)
        PrisonGUI.column[3] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Conviction date", 0.15)
        PrisonGUI.column[4] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Released in days", 0.1)
        PrisonGUI.column[8] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Released in hours", 0.1)
        PrisonGUI.column[10] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Online minutes", 0.08)
        PrisonGUI.column[5] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Last updated by", 0.1)
        PrisonGUI.column[9] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Fine", 0.1)
        PrisonGUI.column[6] = guiGridListAddColumn(PrisonGUI.gridlist[1], "Charges", 0.5)

        for _,res in ipairs(result) do
            local row = guiGridListAddRow( PrisonGUI.gridlist[1] )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[1], tostring( res[1] ), false, true )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[2], tostring( res[3] ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[3], tostring( res[5] ), false, false )
            if getPlayerFromName(tostring(res[3])) then
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[2], 0, 255, 0)
            end
            -- Time for some math...
            local days, hours, remainingtime = cleanMath(res[4])
            if remainingtime <= 0 and tonumber(res[10]) > 0 then
                days = "Awaiting"
                hours = "Online Time"
            end
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[4], tostring( days ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[8], tostring( hours ), false, false )
            if days=="Life" then
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 255, 0, 0)
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 255, 0, 0)
            elseif days=="Awaiting" and hours=="Release" then
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 255, 255, 0)
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 255, 255, 0)
            elseif hours=="Online Time" then
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[4], 0, 93, 1)
                guiGridListSetItemColor(PrisonGUI.gridlist[1], row, PrisonGUI.column[8], 0, 93, 1)
            end
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[5], tostring( res[6] ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[6], tostring( res[7] ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[7], tostring( res[8] ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[9], tostring( res[9] ), false, false )
            guiGridListSetItemText( PrisonGUI.gridlist[1], row, PrisonGUI.column[10], tostring( res[10] ), false, false )
        end
        addEventHandler("onClientGUIDoubleClick", PrisonGUI.gridlist[1], gridlistDoubleClick, false)
        outputChatBox("List Updated.")
    end
, false)

-- Offline add source = 1
function addPrisonerGUI(source, name, cell, days, hours, charges, row, fines, jailID)
    if isElement(newPrisonerGUI.window[1]) then
        destroyElement(newPrisonerGUI.window[1])
    end
    local arrestLocation = isInArrestColshape(getLocalPlayer())
    if arrestLocation then
        local scr = {guiGetScreenSize() }
        local w, h = 329, 279
        local x, y = (scr[1]/2)-(w/2), (scr[2]/2)-(h/2)
        guiSetInputEnabled(true)
        newPrisonerGUI.window[1] = guiCreateWindow(x, y, w, h, "Add new prisoner", false)
        guiWindowSetSizable(newPrisonerGUI.window[1], false)

        newPrisonerGUI.button[1] = guiCreateButton(13, 241, 123, 28, "Cancel", false, newPrisonerGUI.window[1])
        guiSetProperty(newPrisonerGUI.button[1], "NormalTextColour", "FFAAAAAA")
        newPrisonerGUI.button[2] = guiCreateButton(170, 241, 123, 28, "Add prisoner", false, newPrisonerGUI.window[1])
        guiSetProperty(newPrisonerGUI.button[2], "NormalTextColour", "FFAAAAAA")
        newPrisonerGUI.edit[5] = guiCreateEdit(150, 48, 66, 20, "", false, newPrisonerGUI.window[1])
        guiSetText(newPrisonerGUI.edit[5], "0")
        newPrisonerGUI.edit[1] = guiCreateEdit(79, 21, 140, 21, "", false, newPrisonerGUI.window[1])

        if source==PrisonGUI.button[3] then
            newPrisonerGUI.label[1] = guiCreateLabel(13, 22, 67, 15, "Name/ID:", false, newPrisonerGUI.window[1])
            guiSetFont(newPrisonerGUI.label[1], "default-bold-small")
            newPrisonerGUI.label[4] = guiCreateLabel(226, 25, 72, 17, "Not found", false, newPrisonerGUI.window[1])
            guiLabelSetColor(newPrisonerGUI.label[4], 255, 0, 0)
            guiSetEnabled(newPrisonerGUI.button[2], false)
            addEventHandler("onClientGUIChanged", newPrisonerGUI.edit[1], checkNameExists)
        elseif source==PrisonGUI.button[7] then
            newPrisonerGUI.label[1] = guiCreateLabel(15, 22, 67, 15, "Exact Name:", false, newPrisonerGUI.window[1])
            guiSetFont(newPrisonerGUI.label[1], "default-bold-small")

            guiSetEnabled(newPrisonerGUI.edit[5], false)
        end

        newPrisonerGUI.label[2] = guiCreateLabel(12, 147, 77, 15, "Charges:", false, newPrisonerGUI.window[1])
        guiSetFont(newPrisonerGUI.label[2], "default-bold-small")
        newPrisonerGUI.memo[1] = guiCreateMemo(11, 162, 308, 69, "", false, newPrisonerGUI.window[1])
        newPrisonerGUI.label[3] = guiCreateLabel(14, 48, 30, 15, "Cell:", false, newPrisonerGUI.window[1])
        guiSetFont(newPrisonerGUI.label[3], "default-bold-small")
        newPrisonerGUI.edit[2] = guiCreateComboBox(45, 48, 66, 200, "", false, newPrisonerGUI.window[1])

        newPrisonerGUI.label[8] = guiCreateLabel(120, 48, 30, 15, "Fine:", false, newPrisonerGUI.window[1])
        guiSetFont(newPrisonerGUI.label[8], "default-bold-small")
        guiEditSetMaxLength(newPrisonerGUI.edit[5], 6)

        newPrisonerGUI.label[5] = guiCreateLabel(13, 96, 51, 15, "Days:", false, newPrisonerGUI.window[1])
        guiSetFont(newPrisonerGUI.label[5], "default-bold-small")
        newPrisonerGUI.label[6] = guiCreateLabel(7, 77, 301, 15, "============Conviction Time==========", false, newPrisonerGUI.window[1])
        guiLabelSetHorizontalAlign(newPrisonerGUI.label[6], "center", false)
        newPrisonerGUI.label[7] = guiCreateLabel(148, 96, 51, 15, "Hours:", false, newPrisonerGUI.window[1])
        guiSetFont(newPrisonerGUI.label[7], "default-bold-small")
        newPrisonerGUI.edit[3] = guiCreateEdit(60, 97, 78, 40, "", false, newPrisonerGUI.window[1])
        newPrisonerGUI.edit[4] = guiCreateEdit(199, 96, 83, 41, "", false, newPrisonerGUI.window[1])
        guiSetText(newPrisonerGUI.edit[3], "0")
        guiSetText(newPrisonerGUI.edit[4], "0")

        if name then
            guiSetText(newPrisonerGUI.edit[1], name)
            guiSetText(newPrisonerGUI.edit[2], cell)
            guiSetText(newPrisonerGUI.edit[3], days)
            guiSetText(newPrisonerGUI.edit[4], hours)
            guiSetText(newPrisonerGUI.memo[1], charges)
            guiSetText(newPrisonerGUI.edit[5], fines)
            guiSetText(newPrisonerGUI.window[1], "Update Prisoner") -- All about the cosmedics baby
            guiSetText(newPrisonerGUI.button[2], "Update Prisoner")

            guiSetEnabled(newPrisonerGUI.edit[1], false) -- Can't trust people trying to change the name while in the update window.
            guiSetEnabled(newPrisonerGUI.edit[5], false)
            if not tonumber(days) then
                guiSetEnabled(newPrisonerGUI.edit[3], false)
                guiSetEnabled(newPrisonerGUI.edit[4], false)
            end

            comboNum = -1
            for _, value in pairs(getCells(arrestLocation)) do
                guiComboBoxAddItem(newPrisonerGUI.edit[2], _)
                comboNum = comboNum+1
            end
            guiComboBoxAddItem(newPrisonerGUI.edit[2], cell)
            guiComboBoxSetSelected(newPrisonerGUI.edit[2], comboNum+1)
        else
            for _, value in pairs(getCells(arrestLocation)) do
                guiComboBoxAddItem(newPrisonerGUI.edit[2], _)
            end
        end

        addEventHandler("onClientGUIClick", newPrisonerGUI.button[2], function()
            if overLimit(guiGetText(newPrisonerGUI.edit[3]), guiGetText(newPrisonerGUI.edit[4])) then -- Returns true if over hour limit
                outputChatBox("You are attempting to jail someone over the "..tonumber(hourLimit).." hour limit.", 255, 0, 0) return end

            local item = guiComboBoxGetSelected(newPrisonerGUI.edit[2])
            if item==-1 then
                outputChatBox("Make a cell selection first.", 255, 0, 0) return end

            if string.len(guiGetText(newPrisonerGUI.edit[1])) > 0 then
                local cell = guiComboBoxGetItemText(newPrisonerGUI.edit[2], item)
                if source==PrisonGUI.button[3] then -- Online add
                    if tonumber(guiGetText(newPrisonerGUI.edit[5])) <= 100000 then
                        if tonumber(guiGetText(newPrisonerGUI.edit[4]))+tonumber(guiGetText(newPrisonerGUI.edit[3])) >= 1 then
                            triggerServerEvent("addPrisoner", resourceRoot,
                            user,
                            cell, -- Cell
                            guiGetText(newPrisonerGUI.edit[3]),-- Days
                            guiGetText(newPrisonerGUI.edit[4]), -- Hours
                            guiGetText(newPrisonerGUI.memo[1]), -- Charges
                            math.floor(guiGetText(newPrisonerGUI.edit[5])),
                            true)
                        else
                            outputChatBox("Please enter a higher conviction amount.", 255, 0, 0)
                        end
                    else
                        outputChatBox("The maximum fine amount is $100,000.", 255, 0, 0)
                    end
                elseif source==PrisonGUI.button[4] or source==PrisonGUI.gridlist[1] then -- Update info
                    online = false
                    name = guiGetText(newPrisonerGUI.edit[1])
                    local players = getElementsByType("player")
                    for key, value in ipairs(players) do
                        if getPlayerName(value) == guiGetText(newPrisonerGUI.edit[1]) then -- Run this clientside to reduce stress on the server
                            name = value
                            online = true
                        end
                    end
                    triggerServerEvent("changePrisoner", resourceRoot,
                    name, -- Name
                    cell, -- Cell
                    guiGetText(newPrisonerGUI.edit[3]),-- Days
                    guiGetText(newPrisonerGUI.edit[4]), -- Hours
                    guiGetText(newPrisonerGUI.memo[1]), -- Charges
                    jailID,
                    online)
                else
                    if tonumber(guiGetText(newPrisonerGUI.edit[4]))+tonumber(guiGetText(newPrisonerGUI.edit[3])) > 1 then -- Offline Add
                        triggerServerEvent("addPrisoner", resourceRoot,
                        guiGetText(newPrisonerGUI.edit[1]), -- Name
                        cell, -- Cell
                        guiGetText(newPrisonerGUI.edit[3]),-- Days
                        guiGetText(newPrisonerGUI.edit[4]), -- Hours
                        guiGetText(newPrisonerGUI.memo[1]), -- Charges
                        math.floor(guiGetText(newPrisonerGUI.edit[5])),
                        false)
                    else
                        outputChatBox("Please enter a higher conviction amount.", 255, 0, 0)
                    end
                end
                destroyElement(newPrisonerGUI.window[1])
                guiSetInputEnabled(false)
            else
                outputChatBox("Did you enter a name?", 255, 0, 0)
            end
        end, false)

        addEventHandler("onClientGUIClick", newPrisonerGUI.button[1], function()
            destroyElement(newPrisonerGUI.window[1])
            guiSetInputEnabled(false)
        end, false)
    else
        outputChatBox("You must be in an arrest area.", 255, 0, 0)
    end
end

function toggleGate()
    if isElement(ToggleGateGUI.window[1]) then
        destroyElement(ToggleGateGUI.window[1])
    end

        local scr = {guiGetScreenSize() }
        local w, h = 272, 200
        local x, y = (scr[1]/2)-(w/2), (scr[2]/2)-(h/2)
        ToggleGateGUI.window[1] = guiCreateWindow(x, y, w, h, "Toggle a gate", false)
        guiWindowSetSizable(ToggleGateGUI.window[1], false)

        ToggleGateGUI.combobox[1] = guiCreateComboBox(9, 25, 253, 200, "", false, ToggleGateGUI.window[1])
        ToggleGateGUI.button[1] = guiCreateButton(11, 54, 120, 37, "Toggle Gate", false, ToggleGateGUI.window[1])
        guiSetProperty(ToggleGateGUI.button[1], "NormalTextColour", "FFAAAAAA")
        ToggleGateGUI.button[2] = guiCreateButton(136, 54, 120, 37, "Cancel", false, ToggleGateGUI.window[1])
        guiSetProperty(ToggleGateGUI.button[2], "NormalTextColour", "FFAAAAAA")
        --ToggleGateGUI.label[1] = guiCreateLabel(13, 100, 270, 100, "Here you can toggle one gate at a time.\nThe gates are named after the ID associated\nwith the cell.", false, ToggleGateGUI.window[1])
        ToggleGateGUI.label[1] = guiCreateLabel(183, 120, 45, 20, "Opened", false, ToggleGateGUI.window[1])
        ToggleGateGUI.label[2] = guiCreateLabel(183, 140, 40, 20, "Closed", false, ToggleGateGUI.window[1])
        guiLabelSetColor(ToggleGateGUI.label[1], 0, 255, 0)
        guiLabelSetColor(ToggleGateGUI.label[2], 255, 0, 0)
        local tab = 2
        currentx = 13
        currenty = 100
        for _, value in pairs(getElementData(resourceRoot, "gates")) do
            local tab = tab+1
            guiComboBoxAddItem(ToggleGateGUI.combobox[1], _)
            ToggleGateGUI.label[tab] = guiCreateLabel(currentx, currenty, 30, 20, _, false, ToggleGateGUI.window[1])
            if value[14] == 0 then
                guiLabelSetColor(ToggleGateGUI.label[tab], 255, 0, 0)
            else
                guiLabelSetColor(ToggleGateGUI.label[tab], 0, 255, 0)
            end
            currenty = currenty+15
            if currenty == 190 then
                currentx = currentx+40
                currenty = 100
            end
        end

        addEventHandler("onClientGUIClick", ToggleGateGUI.button[1], function()
            local item = guiComboBoxGetSelected(ToggleGateGUI.combobox[1])
            if item>-1 then
                if getElementDimension(getLocalPlayer(  )) == gateDim then
                    local gateID = guiComboBoxGetItemText(ToggleGateGUI.combobox[1], item)
                    triggerServerEvent("triggerAGate", resourceRoot, gateID)
                    destroyElement(ToggleGateGUI.window[1])
                    setTimer(updateGates, 500, 1)
                else
                    outputChatBox("You must be in the same interior/dimension as the gates.", 255, 0, 0)
                end
            else
                outputChatBox("Select a gate first.", 255, 0, 0)
            end
        end, false)

        addEventHandler("onClientGUIClick", ToggleGateGUI.button[2], function()
            destroyElement(ToggleGateGUI.window[1])
        end, false)
end

function checkNameExists()
    local found = nil
    local count = 0


    local text = guiGetText(newPrisonerGUI.edit[1])
    if text and #text > 0 then
        local players = getElementsByType("player")
        if tonumber(text) then
            local id = tonumber(text)
            for key, value in ipairs(players) do
                if getElementData(value, "playerid") == id then
                    found = value
                    count = 1
                    break
                end
            end
        elseif text=="*" then
            found = getLocalPlayer()
            count = 1
        else
            for key, value in ipairs(players) do
                local username = string.lower(tostring(getPlayerName(value)))
                if string.find(username, string.lower(text)) then
                    count = count + 1
                    found = value
                    break
                end
            end
        end
    end

    if (count>1) then
        guiSetText(newPrisonerGUI.label[4], "Multiple Found.")
        guiLabelSetColor(newPrisonerGUI.label[4], 255, 255, 0)
        guiSetEnabled(newPrisonerGUI.button[2], false)
    elseif (count==1) then
        guiSetText(newPrisonerGUI.label[4], "(ID #" .. getElementData(found, "playerid") .. ")")
        guiLabelSetColor(newPrisonerGUI.label[4], 0, 255, 0)
        user = found
        guiSetEnabled(newPrisonerGUI.button[2], true)
    elseif (count==0) then
        guiSetText(newPrisonerGUI.label[4], "Not found.")
        guiLabelSetColor(newPrisonerGUI.label[4], 255, 0, 0)
        guiSetEnabled(newPrisonerGUI.button[2], false)
    end
end

function overLimit(days, hours)
    if hourLimit == 0 then
        return false
    end

    local days = tonumber(days)*24
    local hours = tonumber(hours)

    if not days or not hours then -- Are you trying to enter a string?
        return true
    end

    local sum = days+hours

    if sum>hourLimit then
        return true
    end

    return false
end

function updateGates()
    if isElement(PrisonGUI.label[1]) then
        destroyElement(PrisonGUI.label[1])
        destroyElement(PrisonGUI.label[2])
    end
    closed = 0
    open = 0
    for _,res in pairs(getElementData(resourceRoot, "gates")) do
        if res[14] == 0 then
            closed = closed+1
        else
            open = open+1
        end
    end
    PrisonGUI.label[1] = guiCreateLabel(750, 287, 100, 30, open.." Gates Open", false, PrisonGUI.window[1])
    PrisonGUI.label[2] = guiCreateLabel(750, 247, 100, 30, closed.." Gates Closed", false, PrisonGUI.window[1])
    guiLabelSetColor(PrisonGUI.label[1], 0, 255, 0)
    guiLabelSetColor(PrisonGUI.label[2], 255, 0, 0)
end

function prisonPed()
    local ped = createPed(283, 1430.2734375, 1503.0810546875, 10.878900527954)
    setPedAnimation(ped, "COP_AMBIENT", "Coplook_loop", -1, true, false, false)
    setElementFrozen(ped, true)
    setElementRotation(ped, 0, 0, 244.56)
    setElementDimension(ped, 851)
    setElementInterior(ped, 3)

    setElementData(ped, 'name', 'John G. Fox', false)
    setElementData(ped, "talk", 1, true)

    addEventHandler( 'onClientPedWasted', ped,
        function()
            setTimer(
                function()
                    destroyElement(ped)
                    createShopPed()
                end, 20000, 1)
        end, false)

    addEventHandler( 'onClientPedDamage', ped, cancelEvent, false )
end
addEventHandler("onClientResourceStart", resourceRoot, prisonPed)
