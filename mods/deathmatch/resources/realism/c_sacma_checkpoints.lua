localPlayer = getLocalPlayer()
targetPlayerID, found, targetPlayerName, isTargetPlayerValid = nil

local host = nil

local checkPoint = nil

local chkX, chkY, chkZ = nil
local int, dim = 0, 0
local laps = nil
local chkRadius = 5

local racers = { }
local racersInfo = { }
local finished = 0

local lapPosition = { }
------------------------------- SACMA Racing Menu ----------------------------------------------
wSACMA = nil
lSACMA = { }
gridSACMAcol = { }

optMenu = {
    button = {},
    window = {},
    edit = {},
    label = {}
}

bSACMAsetpos, bSACMAgotopos, bSACMAsetradius, bSACMAsetlaps, bSACMAaddracer, bSACMAremracer, bSACMApreprace, bSACMAstartrace, bSACMAclose = nil

function openRacesMenu()
	if (exports.integration:isPlayerAdmin(localPlayer)) or (exports.integration:isPlayerScripter(localPlayer)) or (exports.integration:isPlayerVehicleConsultant(localPlayer)) then
		if (isElement(wSACMA)) then return end
		if (isElement(host)) and (localPlayer ~= host) then return end
		
		host = localPlayer
		
		showCursor(true)
		
		local screenwidth, screenheight = guiGetScreenSize()
		local Width = 588
		local Height = 399
		local X = (screenwidth - Width)/2
		local Y = (screenheight - Height)/2
		
		wSACMA = guiCreateWindow(X, Y, Width, Height, "SACMA Racing Event Manager", false)
		guiWindowSetSizable(wSACMA, false)

		-----------------[[ Positioning Options ]]-----------------
		lSACMA[1] = guiCreateLabel(14, 33, 369, 17, "Checkpoint Position: " .. (chkX or "N/A") .. ", " .. (chkY or "N/A") .. ", " .. (chkZ or "N/A"), false, wSACMA)
		lSACMA[2] = guiCreateLabel(14, 51, 154, 17, "Interior: " .. int, false, wSACMA)
		lSACMA[3] = guiCreateLabel(169, 51, 214, 17, "Dimension: " .. dim, false, wSACMA)
		bSACMAgotopos = guiCreateButton(387, 40, 90, 23, "Goto Pos", false, wSACMA)
		guiSetFont(bSACMAgotopos, "default-bold-small")
		addEventHandler("onClientGUIClick", bSACMAgotopos, gotoCheckpointPosition, false)
		bSACMAsetpos = guiCreateButton(489, 40, 89, 23, "Set Pos", false, wSACMA)
		guiSetFont(bSACMAsetpos, "default-bold-small")
		addEventHandler("onClientGUIClick", bSACMAsetpos, setCheckpointPosition, false)
		-----------------------------------------------------------
		
		lSACMA[4] = guiCreateLabel(14, 73, 564, 17, "__________________________________________________________________________________________________________________________________", false, wSACMA)

		-----------------[[ Checkpoint Options ]]------------------
		lSACMA[5] = guiCreateLabel(14, 98, 369, 17, "Checkpoint Radius: " .. chkRadius, false, wSACMA)
		bSACMAsetradius = guiCreateButton(393, 95, 179, 23, "Set Radius", false, wSACMA)
		guiSetFont(bSACMAsetradius, "default-bold-small")
		addEventHandler("onClientGUIClick", bSACMAsetradius, setRadiusGUI, false)
		-----------------------------------------------------------
		
		lSACMA[6] = guiCreateLabel(14, 111, 564, 17, "__________________________________________________________________________________________________________________________________", false, wSACMA)

		-----------------[[ Laps Options ]]------------------------
		lSACMA[7] = guiCreateLabel(14, 136, 369, 17, "Number of Laps: " .. (laps or "N/A"), false, wSACMA)
		bSACMAsetlaps = guiCreateButton(393, 133, 179, 23, "Set Laps", false, wSACMA)
		guiSetFont(bSACMAsetlaps, "default-bold-small")
		addEventHandler("onClientGUIClick", bSACMAsetlaps, setLapsGUI, false)
		-----------------------------------------------------------
		
		lSACMA[8] = guiCreateLabel(14, 149, 564, 17, "__________________________________________________________________________________________________________________________________", false, wSACMA)

		-----------------[[ Racers Menu and Options ]]-------------
		lSACMA[9] = guiCreateLabel(14, 174, 369, 17, "Current Racers: " .. #racers, false, wSACMA)

		gridSACMA = guiCreateGridList(12, 201, 563, 160, false, wSACMA)
		gridSACMAcol[1] = guiGridListAddColumn(gridSACMA, "ID", 0.1)
		gridSACMAcol[2] = guiGridListAddColumn(gridSACMA, "Veh (VIN)", 0.1)
		gridSACMAcol[3] = guiGridListAddColumn(gridSACMA, "Name", 0.4)
		gridSACMAcol[4] = guiGridListAddColumn(gridSACMA, "Racer Number", 0.15)
		gridSACMAcol[5] = guiGridListAddColumn(gridSACMA, "Finish Position", 0.25)
		for i = 1, #racers do
			if (isElement(racers[i])) then
				local row = guiGridListAddRow(gridSACMA)
				
				guiGridListSetItemText(gridSACMA, row, gridSACMAcol[1], getElementData(racers[i], "playerid"), false, false)
				guiGridListSetItemText(gridSACMA, row, gridSACMAcol[2], (racersInfo[racers[i]].racerVeh or "N/A"), false, false)
				guiGridListSetItemText(gridSACMA, row, gridSACMAcol[3], string.gsub(getPlayerName(racers[i]), "_", " ") .. " (" .. getElementData(racers[i], "account:username") .. ")", false, false)
				guiGridListSetItemText(gridSACMA, row, gridSACMAcol[4], (racersInfo[racers[i]].racerNumb or "N/A"), false, false)
				guiGridListSetItemText(gridSACMA, row, gridSACMAcol[5], (racersInfo[racers[i]].finished or "Racing"), false, false)
			end
		end
		addEventHandler( "onClientGUIDoubleClick", gridSACMA, updateRacerGUI, false )
		
		bSACMAremracer = guiCreateButton(387, 171, 90, 23, "Remove Racer", false, wSACMA)
		guiSetFont(bSACMAremracer, "default-bold-small")
		addEventHandler("onClientGUIClick", bSACMAremracer, removeRacer, false)
		
		bSACMAaddracer = guiCreateButton(488, 171, 90, 23, "Add Racer", false, wSACMA)
		guiSetFont(bSACMAaddracer, "default-bold-small")
		addEventHandler("onClientGUIClick", bSACMAaddracer, addRacerGUI, false)
		-----------------------------------------------------------
		
		-----------------[[ Race Start and other Options ]]--------
		bSACMApreprace = guiCreateButton(12, 366, 179, 23, "Prepare Checkpoint", false, wSACMA)
		guiSetFont(bSACMApreprace, "default-bold-small")
		if (chkX == nil) then guiSetEnabled(bSACMApreprace, false) end
		addEventHandler("onClientGUIClick", bSACMApreprace, createStartingCheckpoint, false)
		
		bSACMAstartrace = guiCreateButton(204, 366, 179, 23, "Update Information", false, wSACMA)
		guiSetFont(bSACMAstartrace, "default-bold-small")
		guiSetEnabled(bSACMAstartrace, false)
		
		bSACMAclose = guiCreateButton(397, 366, 179, 23, "Close Menu", false, wSACMA)
		guiSetFont(bSACMAclose, "default-bold-small")
		guiSetProperty(bSACMAclose, "NormalTextColour", "FFF30B0C")
		addEventHandler("onClientGUIClick", bSACMAclose, closeRacesMenu, false)
		-----------------------------------------------------------
	end
end
addCommandHandler("sacmaraces", openRacesMenu, false, false)

function closeRacesMenu()
	if (isElement(wSACMA)) then
		destroyElement(wSACMA)
		wSACMA = nil
		lSACMA = { }
		gridSACMAcol = { }
		
		showCursor(false)
		guiSetInputEnabled(false)

		bSACMAsetpos, bSACMAgotopos, bSACMAsetradius, bSACMAsetlaps, bSACMAaddracer, bSACMAremracer, bSACMApreprace, bSACMAstartrace, bSACMAclose = nil
	end
end

function updateGUIinfo()
	if not (isElement(wSACMA)) then return end
	
	guiSetText(lSACMA[1], "Checkpoint Position: " .. (chkX or "N/A") .. ", " .. (chkY or "N/A") .. ", " .. (chkZ or "N/A"))
	guiSetText(lSACMA[2], "Interior: " .. int)
	guiSetText(lSACMA[3], "Dimension: " .. dim)
	guiSetText(lSACMA[5], "Checkpoint Radius: " .. chkRadius)
	guiSetText(lSACMA[7], "Number of Laps: " .. (laps or "N/A"))
end

function setCheckpointPosition()
	chkX, chkY, chkZ = getElementPosition(localPlayer)
	int = getElementInterior(localPlayer)
	dim = getElementDimension(localPlayer)
	
	updateGUIinfo()
	guiSetEnabled(bSACMApreprace, true)
	
	outputChatBox("Checkpoint position successfully updated!", 255, 194, 14)
end

function gotoCheckpointPosition()
	if (chkX ~= nil) then
		setElementInterior(localPlayer, int)
		setElementDimension(localPlayer, dim)
		setElementPosition(localPlayer, chkX, chkY, chkZ)
		
		outputChatBox("Successfully teleported!", 255, 194, 14)
	else
		outputChatBox("You must set the position first!", 255, 0, 0)
	end
end

function removeRacer()
	local selectedRow, selectedCol = guiGridListGetSelectedItem(gridSACMA)
	if (selectedRow == -1) or (selectedCol == -1) then
		outputChatBox("Select a player first????", 255, 0, 0)
		return
	end
	
	local selectedRow = guiGridListGetSelectedItem(gridSACMA)
	local racerID = guiGridListGetItemText(gridSACMA, selectedRow, 1)
	
	local racerElement = nil
	local id = tonumber(racerID)
	for key, value in ipairs(racers) do
		if getElementData(value, "playerid") == id then
			racers[id] = nil
			racersInfo[value] = { }
			guiGridListRemoveRow(gridSACMA, selectedRow)
		end
	end
end

function updateRacerGUI()
	if (isElement(optMenu.window[1])) then return end
	
	local selectedRow = guiGridListGetSelectedItem(gridSACMA)
	local racerID = guiGridListGetItemText(gridSACMA, selectedRow, 1)
	local racerVeh = guiGridListGetItemText(gridSACMA, selectedRow, 2)
	local racerName = guiGridListGetItemText(gridSACMA, selectedRow, 3)
	local racerNumb = guiGridListGetItemText(gridSACMA, selectedRow, 4)
	
	optMenu.window[1] = guiCreateWindow(423, 340, 380, 152, "Update Racer", false)
	guiWindowSetSizable(optMenu.window[1], false)

	optMenu.label[1] = guiCreateLabel(20, 25, 340, 18, "Vehicle VIN", false, optMenu.window[1])
	optMenu.label[2] = guiCreateLabel(20, 69, 340, 18, "Racer Number", false, optMenu.window[1])
	
	optMenu.edit[1] = guiCreateEdit(10, 43, 355, 27, racerVeh, false, optMenu.window[1])
	addEventHandler("onClientGUIFocus", optMenu.edit[1], function ()
		guiSetText(optMenu.edit[1] , "")
	end, false)
	optMenu.edit[2] = guiCreateEdit(10, 87, 355, 27, racerNumb, false, optMenu.window[1])
	addEventHandler("onClientGUIFocus", optMenu.edit[2], function ()
		guiSetText(optMenu.edit[2] , "")
	end, false)
	
	optMenu.button[1] = guiCreateButton(20, 120, 158, 22, "Update", false, optMenu.window[1])
	guiSetFont(optMenu.button[1], "default-bold-small")
	addEventHandler("onClientGUIClick", optMenu.button[1], function ()
		local racerElement = nil
		local id = tonumber(racerID)
		for key, value in ipairs(getElementsByType("player")) do
			if getElementData(value, "playerid") == id then
				racerElement = value
				break
			end
		end
		
		if (isElement(racerElement)) then
			racersInfo[racerElement] = { }
			racersInfo[racerElement].racerVeh = guiGetText(optMenu.edit[1])
			racersInfo[racerElement].racerNumb = guiGetText(optMenu.edit[2])
			racersInfo[racerElement].currentLap = 0
			
			guiGridListSetItemText(gridSACMA, selectedRow, 2, tostring(guiGetText(optMenu.edit[1])), false, false)
			guiGridListSetItemText(gridSACMA, selectedRow, 4, tostring(guiGetText(optMenu.edit[2])), false, false)
		end
		
		closeOptMenu()
	end, false)
	optMenu.button[2] = guiCreateButton(197, 120, 158, 22, "Cancel", false, optMenu.window[1])
	guiSetFont(optMenu.button[2], "default-bold-small")
	guiSetProperty(optMenu.button[2], "NormalTextColour", "FFFF0000")
	addEventHandler("onClientGUIClick", optMenu.button[2], closeOptMenu, false)
end

function setLapsGUI()
	if (isElement(optMenu.window[1])) then return end
	
	guiSetInputEnabled(true)
	
	optMenu.window[1] = guiCreateWindow(423, 340, 380, 108, "Set Laps", false)
	guiWindowSetSizable(optMenu.window[1], false)
	
	optMenu.edit[1] = guiCreateEdit(10, 35, 355, 27, "Laps Amount", false, optMenu.window[1])
	addEventHandler("onClientGUIFocus", optMenu.edit[1], function ()
		guiSetText(optMenu.edit[1] , "")
	end, false)
	
	optMenu.button[1] = guiCreateButton(18, 76, 158, 22, "Update", false, optMenu.window[1])
	guiSetFont(optMenu.button[1], "default-bold-small")
	addEventHandler("onClientGUIClick", optMenu.button[1], updateLaps, false)
	
	optMenu.button[2] = guiCreateButton(197, 76, 158, 22, "Cancel", false, optMenu.window[1])
	guiSetFont(optMenu.button[2], "default-bold-small")
	guiSetProperty(optMenu.button[2], "NormalTextColour", "FFFF0000")
	addEventHandler("onClientGUIClick", optMenu.button[2], closeOptMenu, false)
end
function updateLaps()
	local text = guiGetText(optMenu.edit[1])
	if (text == "") or (text == "Laps Amount") or (tonumber(text) < 1) then
		outputChatBox("Invalid laps amount.", 255, 0, 0)
		return
	end
	
	laps = tonumber(text)
	outputChatBox("Number of laps successfully updated!", 255, 194, 14)
	
	updateGUIinfo()
	closeOptMenu()
end

function setRadiusGUI()
	if (isElement(optMenu.window[1])) then return end
	
	guiSetInputEnabled(true)
	
	optMenu.window[1] = guiCreateWindow(423, 340, 380, 108, "Set Radius", false)
	guiWindowSetSizable(optMenu.window[1], false)
	
	optMenu.edit[1] = guiCreateEdit(10, 35, 355, 27, "Radius Value (Best between 15 - 25)", false, optMenu.window[1])
	addEventHandler("onClientGUIFocus", optMenu.edit[1], function ()
		guiSetText(optMenu.edit[1] , "")
	end, false)
	
	optMenu.button[1] = guiCreateButton(18, 76, 158, 22, "Update", false, optMenu.window[1])
	guiSetFont(optMenu.button[1], "default-bold-small")
	addEventHandler("onClientGUIClick", optMenu.button[1], updateRadius, false)
	
	optMenu.button[2] = guiCreateButton(197, 76, 158, 22, "Cancel", false, optMenu.window[1])
	guiSetFont(optMenu.button[2], "default-bold-small")
	guiSetProperty(optMenu.button[2], "NormalTextColour", "FFFF0000")
	addEventHandler("onClientGUIClick", optMenu.button[2], closeOptMenu, false)
end
function updateRadius()
	local text = guiGetText(optMenu.edit[1])
	if (text == "") or (text == "Radius Value (Best between 15 - 25)") or (tonumber(text) < 1) then
		outputChatBox("Invalid radius.", 255, 0, 0)
		return
	end
	
	chkRadius = tonumber(text)
	outputChatBox("Checkpoint radius successfully updated!", 255, 194, 14)
	
	updateGUIinfo()
	closeOptMenu()
end

function addRacerGUI()
	if (isElement(optMenu.window[1])) then return end
	
	guiSetInputEnabled(true)
	
	optMenu.window[1] = guiCreateWindow(423, 340, 380, 108, "Add Racer", false)
	guiWindowSetSizable(optMenu.window[1], false)

	optMenu.label[1] = guiCreateLabel(20, 25, 340, 18, "Adding Racer:", false, optMenu.window[1])
	optMenu.edit[1] = guiCreateEdit(10, 43, 355, 27, "Player Partial Name/ID", false, optMenu.window[1])
	addEventHandler("onClientGUIFocus", optMenu.edit[1], function ()
		guiSetText(optMenu.edit[1] , "")
	end, false)
	addEventHandler("onClientGUIChanged", optMenu.edit[1], checkNameExists)
	
	optMenu.button[1] = guiCreateButton(18, 76, 158, 22, "Add Racer", false, optMenu.window[1])
	guiSetFont(optMenu.button[1], "default-bold-small")
	addEventHandler("onClientGUIClick", optMenu.button[1], addRacer, false)
	
	optMenu.button[2] = guiCreateButton(197, 76, 158, 22, "Cancel", false, optMenu.window[1])
	guiSetFont(optMenu.button[2], "default-bold-small")
	guiSetProperty(optMenu.button[2], "NormalTextColour", "FFFF0000")
	addEventHandler("onClientGUIClick", optMenu.button[2], closeOptMenu, false)
end
function addRacer()
	if isTargetPlayerValid then
		racers[targetPlayerID] = found
		racersInfo[found] = { }
		racersInfo[found].racerVeh = "N/A"
		racersInfo[found].racerNumb = "N/A"
		racersInfo[found].currentLap = 0
		
		outputChatBox(string.gsub(targetPlayerName, "_", " ") .. " was added to the race!", 0, 255, 0)
		
		local row = guiGridListAddRow(gridSACMA)
		guiGridListSetItemText(gridSACMA, row, gridSACMAcol[1], getElementData(found, "playerid"), false, false)
		guiGridListSetItemText(gridSACMA, row, gridSACMAcol[2], racersInfo[found].racerVeh, false, false)
		guiGridListSetItemText(gridSACMA, row, gridSACMAcol[3], string.gsub(targetPlayerName, "_", " ") .. " (" .. getElementData(found, "account:username") .. ")", false, false)
		guiGridListSetItemText(gridSACMA, row, gridSACMAcol[4], racersInfo[found].racerNumb, false, false)
		guiGridListSetItemText(gridSACMA, row, gridSACMAcol[5], (racersInfo[found].finished or "Racing"), false, false)
		
		closeOptMenu()
	else
		outputChatBox("Select a valid player!", 255, 0, 0)
	end
end

function closeOptMenu()
	if (isElement(optMenu.window[1])) then
		destroyElement(optMenu.window[1])
		
		optMenu = {
			window = { },
			edit = { },
			button = { },
			label = { }
		}
	end
end

function checkNameExists(theEditBox)
	local count = 0
	
	local text = guiGetText(theEditBox)
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
		isTargetPlayerValid = false
		guiSetText(optMenu.label[1], "Adding Racer: ".."Multiple Found.")
		guiLabelSetColor(optMenu.label[1], 255, 255, 0)
	elseif (count==1) then
		if (isElement(racers[tonumber(getElementData(found, "playerid"))])) then
			isTargetPlayerValid = false
			guiSetText(optMenu.label[1], "Adding Racer: ".."Player is already in the race!")
			guiLabelSetColor(optMenu.label[1], 255, 255, 0)
		else
			isTargetPlayerValid = true
			targetPlayerName = string.gsub(getPlayerName(found), "_", " ")
			guiSetText(optMenu.label[1], "Adding Racer: " .. targetPlayerName .. " (ID #" .. getElementData(found, "playerid") .. ")")
			guiLabelSetColor(optMenu.label[1], 0, 255, 0)
			targetPlayerID = getElementData(found, "playerid")
		end
	elseif (count==0) then
		isTargetPlayerValid = false
		
		guiSetText(optMenu.label[1], "Adding Racer: ".."Player not found.")
		guiLabelSetColor(optMenu.label[1], 255, 0, 0)
	end
end
------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------
function createStartingCheckpoint()
	if (isElement(checkPoint)) then destroyElement(checkPoint) end
	
	checkPoint = createColRectangle(chkX, chkY, chkRadius, chkRadius)
	setElementInterior(checkPoint, int)
	setElementDimension(checkPoint, dim)
	
	for i = 1, laps+1 do
		lapPosition[i] = 0
	end
end

function updateRacersPositionLap(newLap)
	for i = 1, guiGridListGetRowCount(gridSACMA) do
		local id = guiGridListGetItemText(gridSACMA, i, 1)
		
		guiGridListSetItemText(gridSACMA, i, gridSACMAcol[1], guiGridListGetItemText(gridSACMA, i, 1), false, false)
		guiGridListSetItemText(gridSACMA, i, gridSACMAcol[2], guiGridListGetItemText(gridSACMA, i, 2), false, false)
		guiGridListSetItemText(gridSACMA, i, gridSACMAcol[3], guiGridListGetItemText(gridSACMA, i, 3), false, false)
		guiGridListSetItemText(gridSACMA, i, gridSACMAcol[4], guiGridListGetItemText(gridSACMA, i, 4), false, false)
		guiGridListSetItemText(gridSACMA, i, gridSACMAcol[5], newLap, false, false)
	end
end

function onCheckPointLeave(thePlayer)
	if (source == checkPoint) then
		local playerID = getElementData(thePlayer, "playerid")
		if (isElement(racers[playerID])) then
				local currentLap = racersInfo[racers[playerID]].currentLap
				local newLap = currentLap + 1
				
				if (newLap == laps) then
					lapPosition[newLap] = lapPosition[newLap] + 1
					racersInfo[racers[playerID]].currentLap = newLap
					updateRacersPositionLap(newLap)
					outputChatBox(string.gsub(getPlayerName(thePlayer), "_", " ") .. " is on the last lap! Placed: " .. lapPosition[newLap], 0, 255, 0)
				elseif (newLap == (laps+1)) then
					lapPosition[newLap] = lapPosition[newLap] + 1
					outputChatBox(string.gsub(getPlayerName(thePlayer), "_", " ") .. " finished the race in position #: " .. lapPosition[newLap], 0, 255, 0)
					racersInfo[racers[playerID]].finished = finished
					updateRacersPositionLap(newLap)
					
					if (finished == #racers) then
						laps = nil
						destroyElement(checkPoint)
						checkPoint = nil
					end
				else
					updateRacersPositionLap(newLap)
					lapPosition[newLap] = lapPosition[newLap] + 1
					racersInfo[racers[playerID]].currentLap = newLap
					outputChatBox(string.gsub(getPlayerName(thePlayer), "_", " ") .. " is on lap " .. newLap .. ". Position: " .. lapPosition[newLap], 0, 255, 0)
				end
		end
	end
end
addEventHandler("onClientColShapeLeave", getRootElement(), onCheckPointLeave)
