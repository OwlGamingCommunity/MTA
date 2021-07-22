electionUI = {
    button = {},
    window = {},
    label = {},
	combobox = {},
	gridlist = {},
	edit = {}
}
function electionsGUI()
    local alreadyVoted = getElementData(localPlayer, "electionsvoted")
    local hours = tonumber(getElementData(localPlayer, "account:hours"))
    if alreadyVoted == 1 then outputChatBox("You have already voted!", 255, 0, 0) return end
    if hours < 10 then outputChatBox("You do not have enough hours to vote.", 255, 0, 0) return end
	if isElement(electionUI.window[1]) then return false end

	electionUI.window[1] = guiCreateWindow(579, 295, 316, 191, "Election Vote", false)
	guiWindowSetSizable(electionUI.window[1], false)

	electionUI.button[1] = guiCreateButton(0.09, 0.68, 0.34, 0.24, "Vote", true, electionUI.window[1])
	addEventHandler("onClientGUIClick", electionUI.button[1], function ()
			local selection = guiGetText(electionUI.combobox[1])
			if selection == "Please choose" then return false end
			triggerServerEvent("elections:refresh", resourceRoot, selection)
			if isElement(electionUI.window[1]) then destroyElement(electionUI.window[1]) end
		end, false)
	electionUI.button[2] = guiCreateButton(0.55, 0.68, 0.34, 0.24, "Close", true, electionUI.window[1])
	addEventHandler("onClientGUIClick", electionUI.button[2], function ()
			if isElement(electionUI.window[1]) then destroyElement(electionUI.window[1]) end
		end, false)
	electionUI.label[1] = guiCreateLabel(0.05, 0.12, 0.89, 0.12, "Please choose and then click 'Vote'", true, electionUI.window[1])
	electionUI.combobox[1] = guiCreateComboBox(0.05, 0.26, 0.89, 0.41, "Please choose", true, electionUI.window[1])
	
	for _, candidates in ipairs(getElementData(resourceRoot, "elections:votes")) do 
		guiComboBoxAddItem(electionUI.combobox[1], candidates['electionsname'])
	end
end
addEvent("elections:votegui", true)
addEventHandler("elections:votegui", localPlayer, electionsGUI)

function electionManager()
	if not exports.integration:isPlayerHeadAdmin(localPlayer) then 
		return 
	end

	if isElement(electionUI.window[2]) then 
		return 
	end

	showCursor(true)
	electionUI.window[2] = guiCreateWindow(708, 362, 373, 273, "Election Manager", false)
	guiWindowSetSizable(electionUI.window[2], false)

	electionUI.gridlist[1] = guiCreateGridList(9, 30, 354, 192, false, electionUI.window[2])
	local col = guiGridListAddColumn(electionUI.gridlist[1], "Candidates", 0.5)
	guiGridListAddColumn(electionUI.gridlist[1], "Votes", 0.5)
	guiSetAlpha(electionUI.gridlist[1], 0.90)

	for _, candidates in ipairs(getElementData(resourceRoot, "elections:votes")) do 
		guiGridListAddRow(electionUI.gridlist[1], candidates['electionsname'], candidates['votes'])
	end

	electionUI.button[3] = guiCreateButton(10, 232, 52, 30, "Add", false, electionUI.window[2])
	electionUI.button[4] = guiCreateButton(70, 232, 52, 30, "Remove", false, electionUI.window[2])
	electionUI.button[5] = guiCreateButton(190, 232, 52, 30, "Close", false, electionUI.window[2]) 
	electionUI.button[8] = guiCreateButton(130, 232, 52, 30, "Reset", false, electionUI.window[2])  

	addEventHandler("onClientGUIClick", electionUI.button[3], function(button)
		if button ~= "left" then return end
		if isElement(electionUI.window[3]) then return end
		electionUI.window[3] = guiCreateWindow(748, 439, 360, 124, "Election Manager - Add Name", false)
		guiWindowSetSizable(electionUI.window[3], false)
		guiSetInputEnabled(true)

        electionUI.edit[1] = guiCreateEdit(9, 24, 341, 46, "", false, electionUI.window[3])
        electionUI.button[6] = guiCreateButton(10, 81, 159, 33, "Cancel", false, electionUI.window[3])
		electionUI.button[7] = guiCreateButton(191, 81, 159, 33, "Add", false, electionUI.window[3])
		addEventHandler("onClientGUIClick", electionUI.button[6], function(button)
			if button ~= "left" then return end
			destroyElement(electionUI.window[3])
			guiSetInputEnabled(false)
		end, false)

		addEventHandler("onClientGUIClick", electionUI.button[7], function(button)
			if button ~= "left" then return end
			triggerServerEvent("elections:add", resourceRoot, guiGetText(electionUI.edit[1]))
			destroyElement(electionUI.window[2])
			destroyElement(electionUI.window[3])
			showCursor(false)
			guiSetInputEnabled(false)
		end, false)
	end, false)

	addEventHandler("onClientGUIClick", electionUI.button[4], function(button)
		if button ~= "left" then return end
		local row = guiGridListGetSelectedItem(electionUI.gridlist[1])
		if row == -1 then return end
		triggerServerEvent("elections:remove", resourceRoot, guiGridListGetItemText(electionUI.gridlist[1], row, col))
		destroyElement(electionUI.window[2])
		showCursor(false)
	end, false)

	addEventHandler("onClientGUIClick", electionUI.button[5], function(button)
		if button ~= "left" then return end
		destroyElement(electionUI.window[2])
		showCursor(false)
	end, false)

	addEventHandler("onClientGUIClick", electionUI.button[8], function(button)
		if button ~= "left" then return end 
		triggerServerEvent("elections:reset", resourceRoot)
		destroyElement(electionUI.window[2])
		showCursor(false)
	end, false)
end
addCommandHandler("electionmanager", electionManager)