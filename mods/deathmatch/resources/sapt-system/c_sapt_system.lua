ibis = { }

--[[ Global, needed client variables ]]--
-- Variables to know if the client is currently editing the data
routeEdit = false
destinationEdit = false
lineEdit = false

-- Variable to know the amount of times the client hits the keypad numbers, to select the data
keypadClicks = 0

-- Variables to save the data to show on the GUI
nextStop = ""
thisStop = ""
destinationName = ""
line = "000"
route = "000"
destinationCode = "000"
currentStop = 0
totalStops = 0

-- Markers
marker = nil
blip = nil

-- The route ID the client will be doing (Database ID)
routeID = 0

-- Variable used for temporarly save data
tempVariable = nil

-- Misc (Marker and Blip)
marker = {}
blip = {}
--[[ End of the global variables ]]--

function fetchDataClient(destinations, routes, stops)
	cDestinations = destinations
	cRoutes = routes
	cStops = stops
end
addEvent("client:sapt_fetchData", true)
addEventHandler("client:sapt_fetchData", localPlayer, fetchDataClient)

function getDataReady()
	-- Destinations and Routes tables
	cDestinations = { }
	cRoutes = { }
	cStops = { }
end
addEventHandler("onClientResourceStart", localPlayer, getDataReady)

function drawIBIS()
	if (isElement(ibis.Window)) then destroyElement(ibis.Window) end

	-- If it's the first time the player opens the GUI (Enters the bus), it will fetch the data from the database - To avoid multiple queries
	if (cDestinations == nil) and (cRoutes == nil) then triggerServerEvent("server:sapt_fetchData", localPlayer) end

	local cWidth, cHeight = guiGetScreenSize()
	local width, height = 689, 168
	local x = (cWidth/2) - (width/2)
	local y = (cHeight/2) - (height/2) - 250
	ibis.Window = guiCreateWindow(x, y, 689, 168, "IBIS Control Panel", false)
	guiWindowSetSizable(ibis.Window, false)

	ibis.bPrevStop = guiCreateButton(16, 119, 53, 35, "<", false, ibis.Window)
	addEventHandler("onClientGUIClick", ibis.bPrevStop, previousCheckpoint, false)
	ibis.bNextAnn = guiCreateButton(76, 118, 59, 36, "Announce", false, ibis.Window)
	addEventHandler("onClientGUIClick", ibis.bNextAnn, annCheckpoint, false)
	ibis.bNextStop = guiCreateButton(141, 118, 57, 36, ">", false, ibis.Window)
	addEventHandler("onClientGUIClick", ibis.bNextStop, nextCheckpoint, false)
	ibis.bSetLine = guiCreateButton(250, 119, 70, 35, "Line", false, ibis.Window)
	addEventHandler("onClientGUIClick", ibis.bSetLine, updateLine, false)
	ibis.bSetRoute = guiCreateButton(330, 119, 70, 35, "Route", false, ibis.Window)
	addEventHandler("onClientGUIClick", ibis.bSetRoute, updateRoute, false)
	ibis.bSetDestination = guiCreateButton(410, 119, 70, 35, "Destination", false, ibis.Window)
	addEventHandler("onClientGUIClick", ibis.bSetDestination, updateDestination, false)

	ibis.bKey = { }
	ibis.bKey[1] = guiCreateButton(502, 27, 49, 39, "1", false, ibis.Window)
	ibis.bKey[2] = guiCreateButton(561, 27, 49, 39, "2", false, ibis.Window)
	ibis.bKey[3] = guiCreateButton(620, 27, 49, 39, "3", false, ibis.Window)
	ibis.bKey[4] = guiCreateButton(502, 71, 49, 39, "4", false, ibis.Window)
	ibis.bKey[5] = guiCreateButton(561, 71, 49, 39, "5", false, ibis.Window)
	ibis.bKey[6] = guiCreateButton(620, 71, 49, 39, "6", false, ibis.Window)
	ibis.bKey[7] = guiCreateButton(502, 117, 49, 37, "7", false, ibis.Window)
	ibis.bKey[8] = guiCreateButton(561, 117, 49, 37, "8", false, ibis.Window)
	ibis.bKey[9] = guiCreateButton(620, 115, 49, 39, "9", false, ibis.Window)
	ibis.bKey[10] = guiCreateButton(443, 27, 49, 39, "0", false, ibis.Window)
	ibis.bKey[11] = guiCreateButton(443, 71, 49, 39, "OK", false, ibis.Window)
	local i = 1
	while (i <= 11) do
		addEventHandler("onClientGUIClick", ibis.bKey[i], onKeypadClick, false)
		i = i + 1
	end

	ibis.mScreen = guiCreateMemo(22, 29, 407, 60, "TURNING IBIS on...", false, ibis.Window)
	guiMemoSetReadOnly(ibis.mScreen, true)
	setTimer(updateScreenFull, 1500, 1)

	ibis.lLine = guiCreateLabel(26, 89, 24, 14, "Line", false, ibis.Window)
	ibis.lRoute = guiCreateLabel(60, 89, 35, 14, "Route", false, ibis.Window)
	ibis.lDestination = guiCreateLabel(105, 89, 35, 14, "Dest.", false, ibis.Window)
	ibis.lCurrentStop = guiCreateLabel(145, 89, 53, 14, "Curr.Stop", false, ibis.Window)
	ibis.lTotalStops = guiCreateLabel(208, 89, 62, 14, "Total stops", false, ibis.Window)
end
addEvent("client:sapt_drawIBIS", true)
addEventHandler("client:sapt_drawIBIS", localPlayer, drawIBIS)

-- Functions to update the values of lines, destinations and the routes to take
function onKeypadClick()
	if lineEdit then
		if guiGetText(source) ~= "OK" then
			if keypadClicks == 0 then
				tempVariable = "00" .. guiGetText(source)
				updateScreen("Set line: " .. tempVariable)
				keypadClicks = keypadClicks + 1
			elseif keypadClicks == 1 then
				tempVariable = "0" .. tempVariable:sub(3) .. guiGetText(source)
				updateScreen("Set line: " .. tempVariable)
				keypadClicks = keypadClicks + 1
			elseif keypadClicks == 2 then
				tempVariable = "" .. tempVariable:sub(2) .. guiGetText(source)
				updateScreen("Set line: " .. tempVariable)
				keypadClicks = keypadClicks + 1
			end
		else
			triggerServerEvent("server:sapt_checkData", localPlayer, 0, tempVariable, false)
		end
	elseif routeEdit then
		if guiGetText(source) ~= "OK" then
			if keypadClicks == 0 then
				tempVariable = "00" .. guiGetText(source)
				updateScreen("Line set: " .. line .. "\nSet route: " .. tempVariable)
				keypadClicks = keypadClicks + 1
			elseif keypadClicks == 1 then
				tempVariable = "0" .. tempVariable:sub(3) .. guiGetText(source)
				updateScreen("Line set: " .. line .. "\nSet route: " .. tempVariable)
				keypadClicks = keypadClicks + 1
			elseif keypadClicks == 2 then
				tempVariable = "" .. tempVariable:sub(2) .. guiGetText(source)
				updateScreen("Line set: " .. line .. "\nSet route: " .. tempVariable)
				keypadClicks = keypadClicks + 1
			end
		else
			triggerServerEvent("server:sapt_checkData", localPlayer, 1, tempVariable, line)
		end
	elseif destinationEdit then
		if guiGetText(source) ~= "OK" then
			if keypadClicks == 0 then
				tempVariable = "00" .. guiGetText(source)
				updateScreen("Set destination: " .. tempVariable)
				keypadClicks = keypadClicks + 1
			elseif keypadClicks == 1 then
				tempVariable = "0" .. tempVariable:sub(3) .. guiGetText(source)
				updateScreen("Set destination: " .. tempVariable)
				keypadClicks = keypadClicks + 1
			elseif keypadClicks == 2 then
				tempVariable = "" .. tempVariable:sub(2) .. guiGetText(source)
				updateScreen("Set destination: " .. tempVariable)
				keypadClicks = keypadClicks + 1
			end
		else
			triggerServerEvent("server:sapt_checkData", localPlayer, 2, tempVariable, false)
		end
	end
end

function checkDataClient(typeOfData, dataCorrect, otherValues)
	--[[ Types of data:
		0: Fetch Line from SQL
		1: Fetch Route from SQL
		2: Fetch Destination from SQL ]]--
	if (typeOfData == 0) then
		if lineEdit and dataCorrect == 0 then
			updateScreen("Set line: 000\nLine does not exist, try another!")
			tempVariable = nil
			keypadClicks = 0
		elseif lineEdit and dataCorrect == 1 then
			line = tempVariable -- Set the line to what the client has chosen
			destinationCode = "000"
			destinationName = ""
			route = "000"
			tempVariable = nil -- Reset the temporary variable to be used again later
			lineEdit = false
			keypadClicks = 0
			updateScreenFull()
		end
	elseif (typeOfData == 1) then
		if routeEdit and dataCorrect == 0 then
			updateScreen("Line set: " .. line .. "\nSet route: 000\nRoute does not exist on the set line, try another!")
			tempVariable = nil
			keypadClicks = 0
		elseif routeEdit and dataCorrect == 1 then
			route = tempVariable -- Set the route to what the client has chosen
			destinationCode = tostring(otherValues[1]) -- Automatically set the default destination for the route
			routeID = otherValues[2] -- Database route id, to be later used to fetch the stops
			destinationName = cDestinations[tostring(destinationCode)]["name"]
			routeEdit = false
			keypadClicks = 0

			tempVariable = cStops[tostring(routeID)]
			totalStops = tonumber(tempVariable["totalStops"])
			currentStop = 0

			tempVariable = cStops[tostring(routeID)][tostring(currentStop+1)]
			nextStop = tostring(tempVariable["name"])

			tempVariable = nil
			updateScreenFull()
		end
	elseif (typeOfData == 2) then
		if destinationEdit and dataCorrect == 0 then
			updateScreen("Set destination: 000\nDestination does not exist, try another!")
			tempVariable = nil
			keypadClicks = 0
		elseif destinationEdit and dataCorrect == 1 then
			destinationCode = tempVariable -- Set the destination to what the client has chosen
			destinationName = cDestinations[tostring(destinationCode)]["name"]
			tempVariable = nil -- Reset the temporary variable to be used again later
			destinationEdit = false
			keypadClicks = 0
			updateScreenFull()
		end
	end
end
addEvent("client:sapt_checkData", true)
addEventHandler("client:sapt_checkData", localPlayer, checkDataClient)
-- End of those

-- Functions to update the IBIS text
function updateScreen(theText)
	guiSetText(ibis.mScreen, theText)
end
function updateScreenFull(fetchSomeData)
	updateScreen("Next stop: " .. nextStop .. "\nDestination: " .. destinationName .. "\n" .. line .. "     " .. route .. "     " .. destinationCode .. "       " .. currentStop .. "              " .. totalStops)
end
-- End of those

-- Functions called by the Keypad clicks
function updateLine()
	if routeEdit == false and destinationEdit == false and lineEdit == false then
		updateScreen("Set line: 000")
		lineEdit = true
	end
end
function updateRoute()
	if routeEdit == false and destinationEdit == false and lineEdit == false then
		if (line == "000") then
			updateScreen("Please select a line first")
			return
		end
		updateScreen("Line set: " .. line .. "\nSet route: 000")
		routeEdit = true
	end
end
function updateDestination()
	if routeEdit == false and destinationEdit == false and lineEdit == false then
		updateScreen("Set destination: 000")
		destinationEdit = true
	end
end
-- End of those

-- Previous, Next and Announce buttons functions
function previousCheckpoint()
	if (line ~= "000") and (route ~= "000") then
		if totalStops == 0 then return end -- Stop if no stops available

		if currentStop == 0 then return end
		currentStop = currentStop - 1

		tempVariable = cStops[tostring(routeID)][tostring(currentStop+1)]
		nextStop = tostring(tempVariable["name"])
		x, y, z = tempVariable["posX"], tempVariable["posY"], tempVariable["posZ"]
		tempVariable = nil


		createCheckpoint(x, y, z, false)
		updateScreenFull()
	end
end
function nextCheckpoint()
	if (line ~= "000") and (route ~= "000") then
		if totalStops == 0 then return end -- Stop if no stops available

		if currentStop+1 == totalStops then return end
		currentStop = currentStop + 1

		tempVariable = cStops[tostring(routeID)][tostring(currentStop+1)]
		nextStop = tostring(tempVariable["name"])
		x, y, z = tempVariable["posX"], tempVariable["posY"], tempVariable["posZ"]
		tempVariable = nil


		createCheckpoint(x, y, z, false)
		updateScreenFull()
	end
end
local nospam = nil
function annCheckpoint()
	setTimer(function ()
			nospam = false
		end, 10000, 1)

	if (line ~= "000") and (route ~= "000") and nospam ~= true then
		if totalStops == 0 then return end -- Stop if no stops available
		nospam = true

		if currentStop == 0 then
			tempVariable = cStops[tostring(routeID)][tostring(currentStop+1)]
			nextStop = tostring(tempVariable["name"])
			x, y, z = tempVariable["posX"], tempVariable["posY"], tempVariable["posZ"]
			tempVariable = nil
			thisStop = ""
		else
			tempVariable = cStops[tostring(routeID)][tostring(currentStop+1)]
			local tempVariable2 = cStops[tostring(routeID)][tostring(currentStop)]
			if currentStop == totalStops then
				nextStop = ""
				tempVariable = cStops[tostring(routeID)][tostring(currentStop)]
				thisStop = tostring(tempVariable["name"]) .. " (End of Service)"
				x, y, z = false, false, false
				tempVariable = nil
			elseif (currentStop + 1) == totalStops then
				nextStop = tostring(tempVariable["name"]) .. " (End of Service)"
				thisStop = tostring(tempVariable2["name"])
				x, y, z = tempVariable["posX"], tempVariable["posY"], tempVariable["posZ"]
			else
				nextStop = tostring(tempVariable["name"])
				thisStop = tostring(tempVariable2["name"])
				x, y, z = tempVariable["posX"], tempVariable["posY"], tempVariable["posZ"]
			end
			tempVariable = nil
			tempVariable2 = nil
		end

		createCheckpoint(x, y, z, true)
		updateScreenFull()
		currentStop = currentStop + 1
	end
end
addCommandHandler("busann", annCheckpoint, false)
-- End of those

-- Send local message
function announceStop()
	triggerServerEvent("sapt:server_announceStops", localPlayer, thisStop, nextStop)
end
-- end

-- Stopping the current route
function stopRoute()
	currentStop = 0
	totalStops = 0
	thisStop = ""
	nextStop = ""
	route = "000"
	destinationCode = "000"
	destinationName = ""

	if isElement(marker) then destroyElement(marker) end
	if isElement(blip) then destroyElement(blip) end

	updateScreenFull(true)
end
addEvent("client:sapt_stopRoute", true)
addEventHandler("client:sapt_stopRoute", localPlayer, stopRoute)
-- End of that

-- Function to create checkpoints
function createCheckpoint(posX, posY, posZ, announce)
	if (announce) then announceStop() end

	if isElement(marker) then destroyElement(marker) end
	if isElement(blip) then destroyElement(blip) end

	if x and y and z then
		marker = createMarker(posX, posY, posZ, "checkpoint", 2.5, 255, 0, 0, 255)
		blip = createBlipAttachedTo(marker)
	else
		-- If the posX, posY and posZ values are false, means its the end of the route, therefor route is over!
		stopRoute()
	end
end
-- End of that

function closeIBIS()
	if (isElement(ibis.Window)) then
		destroyElement(ibis.lTotalStops)
		destroyElement(ibis.lCurrentStop)
		destroyElement(ibis.lDestination)
		destroyElement(ibis.lRoute)
		destroyElement(ibis.lLine)
		destroyElement(ibis.mScreen)
		destroyElement(ibis.bSetDestination)
		destroyElement(ibis.bSetRoute)
		destroyElement(ibis.bSetLine)
		destroyElement(ibis.bNextStop)
		destroyElement(ibis.bNextAnn)
		destroyElement(ibis.bPrevStop)
		local i = 1
		while (i <= 10) do
			destroyElement(ibis.bKey[i])
			i=i+1
		end
		destroyElement(ibis.Window)

		ibis = { }
	end
end
addEvent("client:sapt_closeIBIS", true)
addEventHandler("client:sapt_closeIBIS", localPlayer, closeIBIS)
