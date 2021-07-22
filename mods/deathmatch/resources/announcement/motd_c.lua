--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local GUIEditor = {
    gridlist = {},
    window = {},
    button = {},
    edit = {},
    label = {},
    memo = {}, 
    combobox = {},
    checkbox = {},
    audience = {},
    gridcol = {},
}
local motdList = nil
function openMotdManager(motdList1)
    if not canPlayerAccessMotdManager(localPlayer) then
        return false
    end
    staffTitles = exports.integration:getStaffTitles()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
        if motdList1 then
            motdList = motdList1
            guiSetVisible(GUIEditor.gridlist[1], true)
            guiSetVisible(GUIEditor.label["loading"], false)
            guiSetEnabled(GUIEditor.button[1], true)
            guiGridListClear(GUIEditor.gridlist[1])
            for i=1, #motdList do
                local row = guiGridListAddRow(GUIEditor.gridlist[1])
                guiGridListSetItemText(GUIEditor.gridlist[1], row, GUIEditor.gridcol.title, motdList[i].title, false, false)
                local audiencesText = ''
                local audiences = fromJSON(motdList[i].audiences)
                for i, audience in ipairs(audiences) do
                    if audience[1] == 0 and audience[2] == 0 then
                        audiencesText = audiencesText.."Player, "
                    elseif staffTitles[audience[1]][audience[2]] then
                        audiencesText = audiencesText..staffTitles[audience[1]][audience[2]]..", "
                    end
                end
                audiencesText = string.sub(audiencesText, 1, string.len(audiencesText)-2)
                guiGridListSetItemText(GUIEditor.gridlist[1], row, GUIEditor.gridcol.audiences, audiencesText, false, false)
                guiGridListSetItemText(GUIEditor.gridlist[1], row, GUIEditor.gridcol.expiration_date, motdList[i].expiration_date.." ("..(motdList[i].active == "1" and "Active" or "Expired")..")", false, false)
                guiGridListSetItemText(GUIEditor.gridlist[1], row, GUIEditor.gridcol.dismissable, motdList[i].dismissable == "1" and "Yes" or "No", false, false)
                guiGridListSetItemText(GUIEditor.gridlist[1], row, GUIEditor.gridcol.creation_date, motdList[i].creation_date, false, false)
                guiGridListSetItemText(GUIEditor.gridlist[1], row, GUIEditor.gridcol.author, motdList[i].author or "N/A", false, false)
                guiGridListSetItemText(GUIEditor.gridlist[1], row, GUIEditor.gridcol.id, motdList[i].id, false, false)
            end
        end
    else
        showCursor(true)
        GUIEditor.window[1] = guiCreateWindow(412, 210, 800, 354, "MOTD - Message of the Day", false)
        guiWindowSetSizable(GUIEditor.window[1], false)
        exports.global:centerWindow(GUIEditor.window[1])

        GUIEditor.gridlist[1] = guiCreateGridList(9, 28, 781, 276, false, GUIEditor.window[1])
        
        GUIEditor.gridcol.title = guiGridListAddColumn(GUIEditor.gridlist[1], "MOTD Title", 0.3)
        GUIEditor.gridcol.audiences = guiGridListAddColumn(GUIEditor.gridlist[1], "Audiences", 0.3)
        GUIEditor.gridcol.expiration_date = guiGridListAddColumn(GUIEditor.gridlist[1], "Expiration Date", 0.25)
        GUIEditor.gridcol.dismissable = guiGridListAddColumn(GUIEditor.gridlist[1], "Dismissable", 0.05)
        GUIEditor.gridcol.author =  guiGridListAddColumn(GUIEditor.gridlist[1], "Author", 0.1)
        GUIEditor.gridcol.creation_date = guiGridListAddColumn(GUIEditor.gridlist[1], "Creation Date", 0.2)
        GUIEditor.gridcol.id = guiGridListAddColumn(GUIEditor.gridlist[1], "ID", 0.05)

        GUIEditor.button[1] = guiCreateButton(10, 314, 388, 30, "Create new MOTD", false, GUIEditor.window[1])
        guiSetFont(GUIEditor.button[1], "default-bold-small")
        addEventHandler("onClientGUIClick", GUIEditor.button[1], function()
            if source == GUIEditor.button[1] then
                createNewMotd()
            end
        end)
        GUIEditor.button[2] = guiCreateButton(402, 314, 388, 30, "Close", false, GUIEditor.window[1])
        guiSetFont(GUIEditor.button[2], "default-bold-small")    
        addEventHandler("onClientGUIClick", GUIEditor.button[2], function()
        	if source == GUIEditor.button[2] then
        		closeMotdManager()
        	end
        end)
        if not motdList then
            guiSetVisible(GUIEditor.gridlist[1], false)
            GUIEditor.label["loading"] = guiCreateLabel(9, 28, 781, 276, "Loading..\n\nTIPS: Double click to edit, double right click to delete.", false, GUIEditor.window[1])
            guiLabelSetHorizontalAlign(GUIEditor.label["loading"], "center", false)
            guiLabelSetVerticalAlign(GUIEditor.label["loading"], "center")
            guiSetEnabled(GUIEditor.button[1], false)
            triggerServerEvent("getMotdList", localPlayer)
        end
        addEventHandler( "onClientGUIDoubleClick", GUIEditor.gridlist[1], function(button, state)
            local selectedRow, selectedCol = guiGridListGetSelectedItem( GUIEditor.gridlist[1] ) -- get double clicked item in the gridlist
            local motdId = guiGridListGetItemText( GUIEditor.gridlist[1], selectedRow, 7 ) -- get its text
            if selectedRow ~= -1 then
                if button == "left" then
                    createNewMotd(motdId)
                end
            end
        end, false )
    end
end
addEvent("openMotdManager", true)
addEventHandler("openMotdManager", root, openMotdManager)
addCommandHandler("motd", openMotdManager, false, false)

function closeMotdManager()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
        showCursor(false)
        closeNewMotd()
        closeDeleteMotd()
        motdList = nil
	end
end

function deleteMOTD(motdId)
    closeDeleteMotd()
    if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
        guiSetEnabled(GUIEditor.window[1], false)
    end 
    GUIEditor.window[3] = guiCreateWindow(684, 373, 339, 137, "Confirmation", false)
    guiWindowSetSizable(GUIEditor.window[3], false)
    exports.global:centerWindow(GUIEditor.window[3])
    local motd = getMotdFromId(motdId)
    GUIEditor.label[100] = guiCreateLabel(14, 25, 315, 63, "You're about to delete MOTD ID #"..motdId.." made by "..motd.author.." on "..motd.creation_date..".\nThis action can not be undone, are you sure you want to proceed?", false, GUIEditor.window[3])
    guiLabelSetHorizontalAlign(GUIEditor.label[100], "left", true)
    GUIEditor.button[101] = guiCreateButton(15, 97, 153, 25, "Yes", false, GUIEditor.window[3])
    GUIEditor.button[102] = guiCreateButton(168, 97, 153, 25, "No", false, GUIEditor.window[3])
    addEventHandler("onClientGUIClick", GUIEditor.button[101], function()
        if source == GUIEditor.button[101] then
            triggerServerEvent("deleteMOTD", localPlayer, motdId)
            closeDeleteMotd()
            exports.global:playSoundSuccess()
        end
    end)
    addEventHandler("onClientGUIClick", GUIEditor.button[102], function()
        if source == GUIEditor.button[102] then
            closeDeleteMotd()
        end
    end)
end

function closeDeleteMotd()
    if GUIEditor.window[3] and isElement(GUIEditor.window[3]) then
        destroyElement(GUIEditor.window[3])
        if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
            guiSetEnabled(GUIEditor.window[1], true)
        end
    end
end

function createNewMotd(motdId)
    closeNewMotd()
    guiSetInputEnabled(true)
    if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
        guiSetEnabled(GUIEditor.window[1], false)
    end 
	
	local confirm = false
    local motd = getMotdFromId(motdId)
    staffTitles = exports.integration:getStaffTitles()
    local audiences = motd and fromJSON(motd.audiences) or {}
    local aHeight = 17
    local count = 0
    for i = 1, #staffTitles do
        local team = staffTitles[i]
        for j = #team, 1, -1 do
            count = count + 1
        end
    end
    count = count + 1

    local yExtend = count*aHeight - aHeight*12
    if yExtend < 0 then yExtend = 0 end

    GUIEditor.window[2] = guiCreateWindow(611, 279, 800, 354+yExtend, motdId and ("Edit MOTD ID #"..motdId) or "Create new MOTD", false)
    guiWindowSetSizable(GUIEditor.window[2], false)
    exports.global:centerWindow(GUIEditor.window[2])
    
    GUIEditor.label[1] = guiCreateLabel(17, 34, 81, 29, "Title:", false, GUIEditor.window[2])
    guiSetFont(GUIEditor.label[1], "default-bold-small")
    guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
    GUIEditor.edit[1] = guiCreateEdit(98, 34, 438, 29, motd and motd.title or "", false, GUIEditor.window[2])
    guiEditSetMaxLength(GUIEditor.edit[1], 70)
    GUIEditor.label[2] = guiCreateLabel(17, 63, 81, 29, "Content:", false, GUIEditor.window[2])
    guiSetFont(GUIEditor.label[2], "default-bold-small")
    guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
    GUIEditor.memo[1] = guiCreateMemo(16, 97, 520, 240, motd and motd.content or "", false, GUIEditor.window[2])
    GUIEditor.label[3] = guiCreateLabel(98, 69, 420, 19, "", false, GUIEditor.window[2])
    guiLabelSetColor ( GUIEditor.label[3], 255,0,0 )
    guiLabelSetHorizontalAlign(GUIEditor.label[3], "center", false)
    guiLabelSetVerticalAlign(GUIEditor.label[3], "center")
    GUIEditor.label[4] = guiCreateLabel(554, 34, 65, 29, "Expire in:", false, GUIEditor.window[2])
    guiSetFont(GUIEditor.label[4], "default-bold-small")
    guiLabelSetVerticalAlign(GUIEditor.label[4], "center")
    GUIEditor.combobox[1] = guiCreateComboBox(615, 37, 165, 22, "Never", false, GUIEditor.window[2])
    guiComboBoxAddItem(GUIEditor.combobox[1], "Never")
    guiComboBoxAddItem(GUIEditor.combobox[1], "1 day")
    guiComboBoxAddItem(GUIEditor.combobox[1], "2 days")
    guiComboBoxAddItem(GUIEditor.combobox[1], "3 days")
    guiComboBoxAddItem(GUIEditor.combobox[1], "1 week")
    guiComboBoxAddItem(GUIEditor.combobox[1], "2 weeks")
    guiComboBoxAddItem(GUIEditor.combobox[1], "1 month")
    guiComboBoxAddItem(GUIEditor.combobox[1], "2 months")
    guiComboBoxAddItem(GUIEditor.combobox[1], "6 months")
    guiComboBoxAddItem(GUIEditor.combobox[1], "1 year")
    exports.global:guiComboBoxAdjustHeight(GUIEditor.combobox[1], 9)

    GUIEditor.checkbox[1] = guiCreateCheckBox(689, 73, 91, 13, "Dismissable", false, false, GUIEditor.window[2])
    guiSetFont(GUIEditor.checkbox[1], "default-bold-small")
    if motd and motd.dismissable == "0" then
        guiCheckBoxSetSelected(GUIEditor.checkbox[1], false)
    else
        guiCheckBoxSetSelected(GUIEditor.checkbox[1], true)
    end

    GUIEditor.label[5] = guiCreateLabel(554, 63, 65, 29, "Audience:", false, GUIEditor.window[2])
    guiSetFont(GUIEditor.label[5], "default-bold-small")
    guiLabelSetVerticalAlign(GUIEditor.label[5], "center")

    local count2 = 0
    for i = 1, #staffTitles do
        local team = staffTitles[i]
        GUIEditor.audience[i] = {}
        for j = #team, 1, -1 do
            count2 = count2 + 1
            GUIEditor.audience[i][j] = guiCreateCheckBox(554, 80+aHeight*count2, 226, 17, team[j], false, false, GUIEditor.window[2])
            for l, audience in pairs(audiences) do
                if audience[1] == i and audience[2] == j then
                    guiCheckBoxSetSelected(GUIEditor.audience[i][j], true)
                end
            end
        end
    end
    count2 = count2 + 1
    
    GUIEditor.audience[0] = guiCreateCheckBox(554, 80+aHeight*count2, 226, 17, "Player", false, false, GUIEditor.window[2])
    if motd then
        for m, audience in pairs(audiences) do
            if audience[1] == 0 and audience[2] == 0 then
                guiCheckBoxSetSelected(GUIEditor.audience[0], true)
            end
        end
    else
        guiCheckBoxSetSelected(GUIEditor.audience[0], true)
    end

    
    --local curWinW, curWinH = guiGetSize(GUIEditor.window[2], false)
    --guiSetSize(GUIEditor.window[2], curWinW, curWinH+yExtend, false)
    local curWinW, curWinH = guiGetSize(GUIEditor.memo[1], false)
    guiSetSize(GUIEditor.memo[1], curWinW, curWinH+yExtend, false)

	GUIEditor.button[5] = guiCreateButton(669, 288+yExtend, 111, 22, "Delete", false, GUIEditor.window[2])
    guiSetFont(GUIEditor.button[5], "default-bold-small")
    GUIEditor.button[4] = guiCreateButton(554, 315+yExtend, 111, 22, "Close", false, GUIEditor.window[2])
    guiSetFont(GUIEditor.button[4], "default-bold-small")
    GUIEditor.button[3] = guiCreateButton(669, 315+yExtend, 111, 22, "Save", false, GUIEditor.window[2])
    guiSetFont(GUIEditor.button[3], "default-bold-small")

    addEventHandler("onClientGUIClick", GUIEditor.window[2], function()
		if source == GUIEditor.button[4] then
            closeNewMotd()
        elseif source == GUIEditor.button[3] then
            local title = guiGetText(GUIEditor.edit[1])
            local content = guiGetText(GUIEditor.memo[1])
            if string.len(title) > 0 and string.len(content) > 1 then
                local expire = guiComboBoxGetSelected ( GUIEditor.combobox[1] )
                local dismissable = guiCheckBoxGetSelected(GUIEditor.checkbox[1]) and 1 or 0
                local audiences = {}
                if guiCheckBoxGetSelected(GUIEditor.audience[0]) then
                    table.insert(audiences, {0, 0})
                end
                for i = 1, #staffTitles do
                    local team = staffTitles[i]
                    for j = #team, 1, -1 do
                        if guiCheckBoxGetSelected(GUIEditor.audience[i][j]) then
                            table.insert(audiences, {i, j})
                        end
                    end
                end
                if #audiences > 0 then
                    triggerServerEvent("saveMotd", localPlayer, title, content, expire, dismissable, audiences, tonumber(motdId))
                    closeNewMotd()
                    exports.global:playSoundSuccess()
                else
                    guiSetText(GUIEditor.label[3], "Please select at least one target audience group.")
                end
            else
                guiSetText(GUIEditor.label[3], "Please enter Title and Content.")
            end
		elseif source == GUIEditor.button[5] then
			if confirm then
				triggerServerEvent("deleteMOTD", localPlayer, motdId)
				closeNewMotd()
			else	
				guiSetText(GUIEditor.button[5], "Are you sure?")
				confirm = true
			end
        end
    end)
end

function closeNewMotd()
    if GUIEditor.window[2] and isElement(GUIEditor.window[2]) then
        destroyElement(GUIEditor.window[2])
        guiSetInputEnabled(false)
        if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
            guiSetEnabled(GUIEditor.window[1], true)
        end
    end
end

function getMotdFromId(motdId)
    motdId = tonumber(motdId)
    if motdList then
        for i, motd in pairs(motdList) do
            if tonumber(motd.id) == motdId then
                return motd
            end
        end
    else
        return {}
    end
end
