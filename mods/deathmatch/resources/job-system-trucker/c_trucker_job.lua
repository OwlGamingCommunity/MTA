local blip, endblip, loadupBlip
local jobstate = 1
local route = 0
local oldroute = -1
local marker, endmarker, endmarker2, loadupMarker
local deliveryStopTimer = nil
local timerLoadUp, cancelRouteTimer

local staticMarkers = {}
local staticBlips = {}
local staticPoints = {
	["loadupBlip"] = { -47.01171875, -1122.2060546875, 10.203268051147, 0 , 0},
	["loadupEntrance1"] = { -34.57421875, -1133.0339355469, 3.5, 0, 0},
	["loadupEntrance2"] = { -32.55859375, -1127.3454589844, 3.5, 0, 0},
	["loadup1"] = { 1543.376953125, 1585.0205078125, 10, 0, 66},
	["loadup2"] = { 1526.568359375, 1584.86328125, 10, 0, 66},
	["loadupExit1"] = { 1543.171875, 1578.125, 10, 0, 66},
	["loadupExit2"] = { 1525.9375, 1578.14453125, 10, 0, 66},
}

local truckerJobVehicleInfo = {
--  Model   (1)Capacity (2)Level (3)Price/Crate (4)CrateWeight (5)Earning/Crate
	[440] = {40, 1, 15, 20, 100}, -- Rumpo
	[499] = {80, 2, 35, 50, 150}, -- Benson
	[414] = {160, 3, 55, 100, 200}, -- Mule
	[498] = {200, 4, 75, 140, 250}, -- Boxville
	[456] = {300, 5, 75, 140, 300}, -- Yankee
}

function resetTruckerJob()
	jobstate = 1
	oldroute = -1
	
	if (isElement(marker)) then
		destroyElement(marker)
		marker = nil
	end
	
	if (isElement(blip)) then
		destroyElement(blip)
		blip = nil
	end
	
	if (isElement(endmarker)) then
		destroyElement(endmarker)
		endmarker = nil
	end
	
	if (isElement(endmarker2)) then
		destroyElement(endmarker2)
		endmarker2 = nil
	end
	
	if (isElement(endcolshape)) then
		destroyElement(endcolshape)
		endcolshape = nil
	end
	
	if (isElement(endblip)) then
		destroyElement(endblip)
		endblip = nil
	end
	
	for key, element in pairs(staticMarkers) do
		if (isElement(element)) then
			destroyElement(element)
			element = nil
		end
	end
	
	for key, element in pairs(staticBlips) do
		if (isElement(element)) then
			destroyElement(element)
			element = nil
		end
	end
	
	if (isElement(loadupBlip)) then
		destroyElement(loadupBlip)
		loadupBlip = nil
	end

	if deliveryStopTimer then
		killTimer(deliveryStopTimer)
		deliveryStopTimer = nil
	end
end
addEventHandler("onClientChangeChar", root, resetTruckerJob)

function displayTruckerJob(notext, spwan)
	-- if (jobstate==0) then
		-- jobstate = 1
		blip = createBlip(-69.087890625, -1111.1103515625, 0.64266717433929, 51, 2, 255, 127, 255)
		
		if not notext then
			exports.hud:sendBottomNotification(localPlayer, "RS Haul Operator:", "Approach the Grey Truck Icon on your radar and enter the RS Haul's vehicle to start your job.")
		end
	-- end
end

addEvent("restoreTruckerJob", true)
addEventHandler("restoreTruckerJob", root, function() displayTruckerJob(true) end )


function showSupplySpot()
	local localPlayer = localPlayer
	--Bip on top of warehouse
	if not isElement(staticBlips["loadupBlip"]) then
		staticBlips["loadupBlip"] = createBlip(staticPoints["loadupBlip"][1], staticPoints["loadupBlip"][2], staticPoints["loadupBlip"][3], 0, 2, 0, 255, 0)
		-- Entrance 1
		staticMarkers["loadupEntrance1"] = createMarker(staticPoints["loadupEntrance1"][1], staticPoints["loadupEntrance1"][2], staticPoints["loadupEntrance1"][3], "cylinder", 3, 255, 255, 255, 100, localPlayer)
		addEventHandler("onClientMarkerHit", staticMarkers["loadupEntrance1"], enteringRSHaulWarehouse1)
		-- Entrance 2
		staticMarkers["loadupEntrance2"] = createMarker(staticPoints["loadupEntrance2"][1], staticPoints["loadupEntrance2"][2], staticPoints["loadupEntrance2"][3], "cylinder", 3, 255, 255, 255, 100,localPlayer)
		addEventHandler("onClientMarkerHit", staticMarkers["loadupEntrance2"], enteringRSHaulWarehouse2)
		-- Loadup 1
		staticMarkers["loadup1"] = createMarker(staticPoints["loadup1"][1], staticPoints["loadup1"][2], staticPoints["loadup1"][3], "cylinder", 3, 0, 255, 0, 100,localPlayer)
		setElementInterior(staticMarkers["loadup1"], staticPoints["loadup1"][4])
		setElementDimension(staticMarkers["loadup1"], staticPoints["loadup1"][5])
		addEventHandler("onClientMarkerHit", staticMarkers["loadup1"], waitAtStationLoadup)
		addEventHandler("onClientMarkerLeave", staticMarkers["loadup1"], leaveStationLoadup)
		-- Loadup 2
		staticMarkers["loadup2"] = createMarker(staticPoints["loadup2"][1], staticPoints["loadup2"][2], staticPoints["loadup2"][3], "cylinder", 3, 0, 255, 0, 100,localPlayer)
		setElementInterior(staticMarkers["loadup2"], staticPoints["loadup2"][4])
		setElementDimension(staticMarkers["loadup2"], staticPoints["loadup2"][5])
		addEventHandler("onClientMarkerHit", staticMarkers["loadup2"], waitAtStationLoadup)
		addEventHandler("onClientMarkerLeave", staticMarkers["loadup2"], leaveStationLoadup)
		-- Exit 1
		staticMarkers["loadupExit1"] = createMarker(staticPoints["loadupExit1"][1], staticPoints["loadupExit1"][2], staticPoints["loadupExit1"][3], "cylinder", 3, 255, 255, 255, 100, localPlayer)
		setElementInterior(staticMarkers["loadupExit1"], staticPoints["loadupExit1"][4])
		setElementDimension(staticMarkers["loadupExit1"], staticPoints["loadupExit1"][5])
		addEventHandler("onClientMarkerHit", staticMarkers["loadupExit1"], exitingRSHaulWarehouse1)
		-- Exit 2
		staticMarkers["loadupExit2"] = createMarker(staticPoints["loadupExit2"][1], staticPoints["loadupExit2"][2], staticPoints["loadupExit2"][3], "cylinder", 3, 255, 255, 255, 100,localPlayer)
		setElementInterior(staticMarkers["loadupExit2"], staticPoints["loadupExit2"][4])
		setElementDimension(staticMarkers["loadupExit2"], staticPoints["loadupExit2"][5])
		addEventHandler("onClientMarkerHit", staticMarkers["loadupExit2"], exitingRSHaulWarehouse2)
	end
end
addEvent("job-system:trucker:showSupplySpot", true)
addEventHandler("job-system:trucker:showSupplySpot", localPlayer, showSupplySpot)

function enteringRSHaulWarehouse1(thePlayer)
	-- if getElementData(thePlayer, "account:username") ~= "Maxime" then
		-- outputChatBox(" Our scripters are working on scripting this part, please standby.", thePlayer, 255,0,0)
		-- return false 
	-- end
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then
		return false
	end
	if getElementData(vehicle, "job") ~= 1 then
		--outputChatBox(" Only Trucks from RS Haul are allowed to get inside.", 255,0,0)
		return false
	end
	
	local number, vehs = getTrucksInsideWarehouse()
	
	if number >= 2 then
		--outputChatBox(" There are already 2 Truckers inside, please wait until they're done.",255,0,0)
		return false
	end
	--fadeCamera ( false, 1, 0, 0, 0 )
	triggerServerEvent("job-system:trucker:enteringRSHaulWarehouse1", thePlayer)
end

function enteringRSHaulWarehouse2(thePlayer)
	-- if getElementData(thePlayer, "account:username") ~= "Maxime" then
		-- outputChatBox(" Our scripters are working on scripting this part, please standby.",thePlayer, 255,0,0)
		-- return false
	-- end	
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then
		return false
	end
	if getElementData(vehicle, "job") ~= 1 then
		--outputChatBox(" Only Trucks from RS Haul are allowed to get inside.", 255,0,0)
		return false
	end
	
	local number, vehs = getTrucksInsideWarehouse()
	
	if number >= 2 then
		--outputChatBox(" There are already 2 Truckers inside, please wait until they're done.",255,0,0)
		return false
	end
	--fadeCamera ( false, 1, 0, 0, 0 )
	triggerServerEvent("job-system:trucker:enteringRSHaulWarehouse2", thePlayer)
end

function exitingRSHaulWarehouse1(thePlayer)
	if getElementDimension(thePlayer) ~= 66 then return end
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then
		return false
	end
	--fadeCamera ( false, 1, 0, 0, 0 )
	triggerServerEvent("job-system:trucker:exitingRSHaulWarehouse1", thePlayer)
end

function exitingRSHaulWarehouse2(thePlayer)
	if getElementDimension(thePlayer) ~= 66 then return end
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then
		return false
	end
	--fadeCamera ( false, 1, 0, 0, 0 )
	triggerServerEvent("job-system:trucker:exitingRSHaulWarehouse2", thePlayer)
end

function getTrucksInsideWarehouse()
	local count = 0 
	local vehs = {}
	for key, theVehicle in pairs(getElementsByType("vehicle")) do
		if getElementData(theVehicle, "job") == 1 and getElementInterior(theVehicle) == 0 and getElementDimension(theVehicle) == 66 then
			local driver = getVehicleOccupant(theVehicle)
			local pass1 = getVehicleOccupant(theVehicle, 1)
			local pass2 = getVehicleOccupant(theVehicle, 2)
			local pass3 = getVehicleOccupant(theVehicle, 3)
			if driver or pass1 or pass2 or pass3 then				
				count = count + 1
				table.insert(vehs, theVehicle)
			end
		end
	end
	return count, vehs
end

function leaveStationLoadup(destroyBlip)
	if getElementDimension(localPlayer) ~= 66 then return end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and getVehicleController(vehicle) == localPlayer and isTimer(timerLoadUp) then
		killTimer(timerLoadUp)
		timerLoadUp = nil
		--[[if destroyBlip then
			if isElement(staticMarkers["loadupEntrance2"]) then
				destroyElement(loadupMarker)
			end
			if isElement(loadupBlip) then
				destroyElement(loadupBlip)
			end
		end]]
	end
end
addEvent("job-system:trucker:leaveStationLoadup", true)
addEventHandler("job-system:trucker:leaveStationLoadup", root, leaveStationLoadup)

addEventHandler("onClientPlayerVehicleExit", localPlayer, function (vehicle, seat)
	if getElementData(localPlayer, 'job') == 1 and isTimer(timerLoadUp) then
		killTimer(timerLoadUp)
		timerLoadUp = nil
	end
end)

function startTruckerJob(routeid)
	
end
addEvent("startTruckJob", true)
addEventHandler("startTruckJob", root, startTruckerJob)

function waitAtStationLoadup(thePlayer)
	if getElementDimension(thePlayer) ~= 66 then return end
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if thePlayer == localPlayer and vehicle and getVehicleController(vehicle) == localPlayer then
		if getElementHealth(vehicle) < 900 then
			exports.hud:sendBottomNotification(localPlayer, "RS Haul Operator:", "You need to get your truck repaired first..")
		else
			if not timerLoadUp then
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "Now waiting a moment while your truck is being loaded up with supply crates.")
				timerLoadUp = setTimer(function ()
					triggerServerEvent("job-system:trucker:startLoadingUp", thePlayer)
				end, 2000, 0)
				
			end
			--
			--addEventHandler("onClientMarkerLeave", marker, checkWaitAtDelivery)
		end
	end
end

function drawBuyLoadWindow(thePlayer)
	wRSHaulLoadup = guiCreateWindow(312,344,204,149,"RS Haul Delivery Station",false)
	guiWindowSetSizable(wRSHaulLoadup,false)
	lNumberOfCrates = guiCreateLabel(13,25,176,19,"Number of Supply Crates: 0",false,wRSHaulLoadup)
	guiSetFont(lNumberOfCrates,"default-bold-small")
	lCost = guiCreateLabel(13,68,176,19,"Cost: $0",false,wRSHaulLoadup)
	guiSetFont(lCost,"default-bold-small")
	scrollbar = guiCreateScrollBar(13,44,176,20,true,false,wRSHaulLoadup)
	lMoney = guiCreateLabel(13,87,176,19,"Your money: $0",false,wRSHaulLoadup)
	guiSetFont(lMoney,"default-bold-small")
	bBuyLoad = guiCreateButton(9,111,94,28,"Buy & Load up",false,wRSHaulLoadup)
	bCancel = guiCreateButton(107,111,88,28,"Cancel",false,wRSHaulLoadup)
end



function getCurrentCrates(vehicle)
	local count = 0
	for key, item in pairs(exports["item-system"]:getItems(vehicle)) do 
		if item[1] == 121 then -- supply box
			count = count + 1
		end
	end
	return count
end

function spawnFinishMarkerTruckJob()
	if not endmarker then
		endblip = createBlip(-52.025390625 , -1120.236328125, 10.132701873779, 0, 2, 255, 0, 0)
		
		endmarker2 = createMarker(-52.025390625 , -1120.236328125, 10.132701873779, "checkpoint", 4, 255, 0, 0, 150)
		setMarkerIcon(endmarker2, "finish")
		
		endmarker = createMarker(1534.900390625, 1582.810546875, 9, "cylinder", 4, 255, 0, 0, 150)
		setMarkerIcon(endmarker, "finish")
		setElementInterior(endmarker, 0)
		setElementDimension(endmarker, 66)
		
		addEventHandler("onClientMarkerHit", endmarker, endDelivery)
	end
end
addEvent("spawnFinishMarkerTruckJob", true)
addEventHandler("spawnFinishMarkerTruckJob", root, spawnFinishMarkerTruckJob)

function loadNewCheckpointTruckJob()
	
end

addEvent("loadNewCheckpointTruckJob", true)
addEventHandler("loadNewCheckpointTruckJob", root, loadNewCheckpointTruckJob)

function countInkeepableObjects(items)
	local counter = 0
	local keepable = {[118] = true, [121] = true}
	for _, item in pairs(items) do
		if not keepable[item[1]] then
			counter = counter + 1
		end
	end
	return counter
end

function endDelivery(thePlayer)
	if thePlayer == localPlayer then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		local id = getElementModel(vehicle) or 0
		if not vehicle or getVehicleController(vehicle) ~= localPlayer then
			exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "You must be in a RS Haul's vehicle to complete deliverys.")
		else
			local health = getElementHealth(vehicle)
			if health <= 900 then
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "This truck is damaged, fix it first.")
			else
				if countInkeepableObjects(exports['item-system']:getItems(vehicle)) > 0 then
					outputChatBox('Please remove any items from the vehicle before completing this RS Haul run.', 255, 0, 0)
					return
				end

				triggerServerEvent("giveTruckingMoney", localPlayer, vehicle)
				resetTruckerJob()
				displayTruckerJob(true)
			end
		end
	end
end

function clearRoute()
	
	if isElement(marker) then
		destroyElement(marker)
	end
	
	if isElement(blip) then
		destroyElement(blip)
	end
	
end
addEvent( "truckerjob:clearRoute", true)
addEventHandler("truckerjob:clearRoute", root , clearRoute)

function spawnRoute(route)
	local x, y, z = route[1], route[2], route[3]
	local radius, r, g, b, trans = 4, 255, 200, 0, 100
	
	if tonumber(route[8]) and (tonumber(route[8]) > 0) then
		radius, r, g, b, trans = 20, 219, 48, 0, 200
	end
	
	if isElement(marker) then
		destroyElement(marker)
	end
	
	if isElement(blip) then
		destroyElement(blip)
	end
	
	blip = createBlip(x, y, z, 0, 2, r, g, b)
	marker = createMarker(x, y, z, "checkpoint", radius, r, g, b, trans)
	addEventHandler("onClientMarkerHit", marker, waitAtDelivery)
end
addEvent( "truckerjob:spawnRoute", true)
addEventHandler("truckerjob:spawnRoute", root , spawnRoute)
 
function waitAtDelivery(thePlayer)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if thePlayer == localPlayer and vehicle and getVehicleController(vehicle) == localPlayer then
		if getElementHealth(vehicle) < 900 then
			exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "You need to get your truck repaired.")
		else
			deliveryStopTimer = setTimer(checkIfPlayerTruckHasEnoughtShit, 5000, 1)
			triggerEvent("job-system:trucker:killTimerCountDown", localPlayer)
			exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "Wait a moment while your truck is processed.")
			addEventHandler("onClientMarkerLeave", marker, checkWaitAtDelivery)
		end 
	end
end

function checkWaitAtDelivery(thePlayer)
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and thePlayer == localPlayer and getVehicleController(vehicle) == localPlayer then
		if getElementHealth(vehicle) >= 900 then
			--outputChatBox("You didn't wait at the dropoff point.", 255, 0, 0)
			if deliveryStopTimer then
				killTimer(deliveryStopTimer)
				deliveryStopTimer = nil
			end
			removeEventHandler("onClientMarkerLeave", source, checkWaitAtDelivery)
		end
	end
end

function checkIfPlayerTruckHasEnoughtShit()
	deliveryStopTimer = nil
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and getVehicleController(vehicle) == localPlayer  then
		if getElementData(vehicle, "job") ~= 1 then
			exports.hud:sendBottomNotification(localPlayer, "RS Haul Operator:", "Man..You have to use RS Haul vehicle.")
			return false
		end
		--spawnFinishMarkerTruckJob()
		triggerLatentServerEvent("truckerjob:checkIfPlayerTruckHasEnoughtShit", localPlayer)	
	else
		exports.hud:sendBottomNotification(localPlayer, "RS Haul Operator:", "You must be in the Truck to complete deliverys.")
	end
end