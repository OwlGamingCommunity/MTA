--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

mysql = exports.mysql
debugmode = true
local lockTimer = nil

MTAoutputChatBox = outputChatBox
function outputChatBox( text, visibleTo, r, g, b, colorCoded )
	if text then
		if string.len(text) > 128 then -- MTA Chatbox size limit
			MTAoutputChatBox( string.sub(text, 1, 127), visibleTo, r, g, b, colorCoded  )
			outputChatBox( string.sub(text, 128), visibleTo, r, g, b, colorCoded  )
		else
			MTAoutputChatBox( text, visibleTo, r, g, b, colorCoded  )
		end
	end
end

function spawnRoute(thePlayer, spawnNewRoute)
	--local currentRoute = getElementData(thePlayer, "job-system-trucker:currentRoute") or false
	local currentSpot = handledSpot(thePlayer)
	if currentSpot and not spawnNewRoute then
		triggerClientEvent(thePlayer, "truckerjob:spawnRoute", thePlayer, currentSpot) -- CONTINUE THE CURRENT ROUTE.
	else
		local selectedRoute = selectAFreeSpot(thePlayer)
		if not selectedRoute then
			exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "There is no customer orders to do at the moment, please stand by...")
		else
			local pX, pY = getElementPosition(thePlayer)
			local distance = getDistanceBetweenPoints2D(pX, pY, selectedRoute[1], selectedRoute[2])
			selectedRoute[9] = distance
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "job-system-trucker:currentRoute", selectedRoute)
			triggerClientEvent(thePlayer, "truckerjob:spawnRoute", thePlayer, selectedRoute)
			if distance > 0 then
				--triggerClientEvent(thePlayer, "job-system:trucker:killTimerCountDown", thePlayer)
				triggerClientEvent(thePlayer, "job-system:trucker:startTimeoutClock", thePlayer, distance)
			end
		end
	end

	--local currentTruckRuns = getElementData(thePlayer, "job-system-trucker:truckruns") or 0

	triggerClientEvent(thePlayer, "spawnFinishMarkerTruckJob", thePlayer)
end
addEvent("job-system:trucker:spawnRoute", true)
addEventHandler("job-system:trucker:spawnRoute", root, spawnRoute)

function handledSpot(thePlayer)
	local cur = getElementData(thePlayer, "job-system-trucker:currentRoute")
	if cur then
		return routes[cur.index], cur.index
	end
	return false, 0
end

function freeSpot(thePlayer)
	local cur = getElementData(thePlayer, "job-system-trucker:currentRoute")
	if cur then
		if routes[cur.index] and routes[cur.index][5] then
			routes[cur.index][5] = nil
		end
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "job-system-trucker:currentRoute", nil)
	end
end

-- save progress on player quit.
addEventHandler("onPlayerQuit", root, function( reason )
	if getElementData(source, "job") == 1 then
		freeSpot(source)
		local truckingRuns = getElementData(source, "job-system-trucker:truckruns") or false
		if truckingRuns and truckingRuns ~= 0 then
			dbExec( exports.mysql:getConn('mta'), "UPDATE jobs SET jobTruckingRuns=? WHERE jobCharID=? AND jobID=1 ", truckingRuns, getElementData(source, "dbid") )
		end
	end
end)

function getTruckCapacity(element)
	if truckerJobVehicleInfo[getElementModel(element)] then
		return truckerJobVehicleInfo[getElementModel(element)][2] -- Weight
	else
		return false
	end
end

function giveTruckingMoney(vehicle)
	local takenWeight = takeRemainingCrates(vehicle)
	if takenWeight then
		exports.hud:sendBottomNotification(source, "RS Haul Operator:", "RS Haul has unloaded "..takenWeight.." Kg(s) of supplies remaining in the back. ")
	end
	-- level up and reset runs/wage
	local vehicle = getPedOccupiedVehicle(source)
	if getElementData(vehicle, "job") ~= 1 then
		exports.hud:sendBottomNotification(source, "RS Haul Operator:", "Man..You have to use RS Haul vehicle.")
	else
		local truckModel = getElementModel(vehicle)
		local truck = truckerJobVehicleInfo[truckModel]
		if truck then
			local charID = getElementData(source, "dbid")
			local currentProgress = getElementData(source, "jobProgress") or 0
			local truckruns = getElementData(source, "job-system-trucker:truckruns") or 0
			local truckrunsTilNextLevel = level[getElementData(source, "jobLevel")] or false
			local notified = false
			if truckruns > 0 then
				if truckrunsTilNextLevel then
					local truckrunCarry = (currentProgress + truckruns) - truckrunsTilNextLevel
					if truckrunCarry >= 0 then -- level up
						local currentJobLevel = getElementData(source, "jobLevel") or 1
						dbExec( exports.mysql:getConn('mta'), "UPDATE jobs SET jobLevel=?, jobProgress=?, jobTruckingRuns=0 WHERE jobID=1 AND jobCharID=? ", currentJobLevel + 1, truckrunCarry, charID )
						local info = {
							{string.upper("Delivery Job New Achievement!"), 255,194,14,255,1,"default-bold"},
							{""},
							{"Congratulations! You've just obtained new Delivery Driver Certificate Level "..tostring(currentJobLevel+1)..".", 0,255,0,255,1,"default"},
						}
						triggerClientEvent(source, "hudOverlay:drawOverlayBottomCenter", source, info )
						notified = true
					else
						dbExec( exports.mysql:getConn('mta'), "UPDATE jobs SET jobProgress=?, jobTruckingRuns=0 WHERE jobID=1 AND jobCharID=? ", currentProgress+truckruns, charID )
					end
				else
					dbExec( exports.mysql:getConn('mta'), "UPDATE jobs SET jobProgress=?, jobTruckingRuns=0 WHERE jobID=1 AND jobCharID=? ", currentProgress+truckruns, charID )
				end

				exports["job-system"]:fetchJobInfoForOnePlayer(source)

				if not notified then
					if not truckrunsTilNextLevel then
						exports.hud:sendBottomNotification(source, "Delivery Job New Achievement!", "Progress: "..(getElementData(source, "jobProgress") or 0).." truck runs (You mastered this job).")
					else
						exports.hud:sendBottomNotification(source, "Delivery Job New Achievement!", "Progress: "..math.floor((getElementData(source, "jobProgress") or 0)/truckrunsTilNextLevel*100).."%")
					end
				end
				playSoundFX(vehicle)
			end

		else
			exports.hud:sendBottomNotification(source, "RS Haul Operator:", "Man..You have to use RS Haul vehicle.")
		end
	end

	-- RESET SHIT
	freeSpot(source)
	exports.anticheat:changeProtectedElementDataEx(source, "job-system-trucker:currentRoute", false)
	exports.anticheat:changeProtectedElementDataEx(source, "job-system-trucker:truckruns", 0)
	exports.anticheat:changeProtectedElementDataEx(source, "job-system-trucker:currentRouteID", -1)
	triggerClientEvent(source, "job-system:trucker:showSupplySpot", source)
	triggerClientEvent(source,"truckerjob:clearRoute", source)
	triggerClientEvent(source,"job-system:trucker:killTimerCountDown", source)

	-- respawn the vehicle
	setTimer(respawnTruck, 1000, 1, source, vehicle)
	setTimer(updateOverLay, 1000*3, 1, source)
end
addEvent("giveTruckingMoney", true)
addEventHandler("giveTruckingMoney", root, giveTruckingMoney)

function respawnTruck(source, vehicle)
	exports.anticheat:changeProtectedElementDataEx(source, "realinvehicle", 0, false)
	removePedFromVehicle(source, vehicle)
	respawnVehicle(vehicle)
	setVehicleLocked(vehicle, false)
	setElementVelocity(vehicle,0,0,0)

	setElementDimension ( vehicle, getElementData(vehicle, "dimension") )
	setElementInterior ( vehicle, getElementData(vehicle, "interior") )
end

function takeRemainingCrates(vehicle)
	if vehicle then
		local weight = 0
		for key, item in pairs(exports["item-system"]:getItems(vehicle)) do
			if tonumber(item[1]) == 121 then
				if exports.global:takeItem(vehicle, item[1], item[2]) then
					weight = weight + (tonumber(item[2]) or 0)
				end
			end
		end

		if weight > 0 then
			playSoundFX(vehicle)
			return weight
		else
			return false
		end
	else
		return false
	end
end

-- PREVENT DRIVER WITH LOWER SKILL GETTING VEHICLE WITH THE HIGHER LEVEL SKILL
function startEnterTruck(thePlayer, seat, jacked)
	local truckModel = getElementModel(source)
	if getElementData(source,"job") == 1 and truckerJobVehicleInfo[truckModel] then
		local truckLevelRequire = truckerJobVehicleInfo[truckModel][1]
		local playerJobLevel = getElementData(thePlayer, "jobLevel") or 0
		if playerJobLevel < truckLevelRequire then
			local truckName = getVehicleNameFromModel(truckModel)
			if truckLevelRequire == 1 then
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "You're not RS Haul Employee, please register for this job at City Hall.")
			else
				exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator:", "You're required Delivery Driver Level "..truckLevelRequire.." Certificate to drive this "..truckName..".")
			end
			if isTimer(lockTimer) then
				killTimer(lockTimer)
				lockTimer = nil
			end
			setVehicleLocked(source, true)
			lockTimer = setTimer(setVehicleLocked, 5000, 1, source, false)
		end
	end
end
addEventHandler("onVehicleStartEnter", root, startEnterTruck)

function checkTruckingEnterVehicle(thePlayer, seat)
	if seat == 0 and getElementData(source,"job") == 1 and getElementData(thePlayer,"job") == 1 then
		local curentCrates = exports['item-system']:getCarriedWeight(source, 121)
		triggerClientEvent(thePlayer, "job-system:trucker:showSupplySpot", thePlayer)
		if curentCrates <= 0 then
			exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator: Your truck is empty!", "Return to RS Haul station to reload your truck with supplies crates!")
		else
			exports.hud:sendBottomNotification(thePlayer, "RS Haul Operator: ", "Your truck has "..exports.global:formatWeight(curentCrates).." of supplies in the back. Deliver them to our customer's places!")
			spawnRoute(thePlayer)
		end
		local currentTruckRuns = getElementData(thePlayer, "job-system-trucker:truckruns") or 0

		if currentTruckRuns > 0 then
			triggerClientEvent(thePlayer, "spawnFinishMarkerTruckJob", thePlayer)
		end
		updateOverLay(thePlayer, {carried=curentCrates})
	end
end
addEventHandler("onVehicleEnter", root, checkTruckingEnterVehicle)

function exitJobVeh(thePlayer, seat)
	if seat == 0 and getElementData(source,"job") == 1 and getElementData(thePlayer,"job") == 1 then
		updateOverLay(thePlayer)
	end
end
addEventHandler("onVehicleExit", root, exitJobVeh)

function startLoadingUp()
	local vehicle = getPedOccupiedVehicle(source)
	if not vehicle then
		exports.hud:sendBottomNotification(source, "RS Haul Operator: ", "Man, where is your truck?")
		return false
	end
	if getElementData(vehicle, "job") ~= 1 then
		exports.hud:sendBottomNotification(source, "RS Haul Operator: ", "Man..You have to use RS Haul vehicle.")
		triggerClientEvent(source, "job-system:trucker:leaveStationLoadup", source, true)
		return false
	end
	local truckModel = getElementModel(vehicle)
	local truck = truckerJobVehicleInfo[truckModel]
	if truck then
		local curentCrates = exports['item-system']:getCarriedWeight(vehicle, 121)
		-- make sure to never ever overload a vehicle
		local crateWeight = math.min( getRandomRequiredWeight(truckModel), truck[2] - curentCrates )

		if crateWeight > 0 then
			local gave, why = exports["item-system"]:giveItem( vehicle, 121, crateWeight)
			if gave then
				playSoundFX(vehicle)
			else
				outputChatBox(why, source, 255,0,0)
			end
		else
			exports.hud:sendBottomNotification(source, "RS Haul Operator: ", "Your truck is full and can not load anymore of supplies! Drive to the yellow blips to complete deliveries.")
			triggerClientEvent(source, "job-system:trucker:leaveStationLoadup", source, true)
		end
		updateOverLay(source, {carried=curentCrates})
	end
end
addEvent("job-system:trucker:startLoadingUp", true)
addEventHandler("job-system:trucker:startLoadingUp", root, startLoadingUp)

function updateOverLay(thePlayer, data)
	triggerClientEvent(thePlayer, "job-system:trucker:UpdateOverLay", thePlayer, data)
end

function startEnterTruck(thePlayer, seat, jacked)
	if seat == 0 and truckerJobVehicleInfo[getElementModel(source)] and getElementData(thePlayer,"job") == 1 and jacked then -- if someone try to jack the driver stop him
		if isTimer(lockTimer) then
			killTimer(lockTimer)
			lockTimer = nil
		end
		setVehicleLocked(source, true)
		lockTimer = setTimer(setVehicleLocked, 5000, 1, source, false)
	end
end
addEventHandler("onVehicleStartEnter", root, startEnterTruck)

function checkIfPlayerTruckHasEnoughtShit()
	local vehicle = getPedOccupiedVehicle(source)
	if getElementData(vehicle, "job") ~= 1 then
		exports.hud:sendBottomNotification(source, "RS Haul Operator: ", "Man..You have to use RS Haul vehicle.")
		return false
	end

	local truckModel = getElementModel(vehicle)
	local truck = truckerJobVehicleInfo[truckModel]
	if not truck then
		exports.hud:sendBottomNotification(source, "RS Haul Operator: ", "Man..RS Haul doesn't allow this model of vehicle.")
		return false
	end

	local success, marker, droppedWeight, supplies_remain = unloadCrates(source, vehicle)
	local distance = marker[9]
	if success then
		local earned = calculateEarning( source, droppedWeight, getElementHealth(vehicle), distance)
		local formartedEarned = exports.global:formatMoney(tostring(earned))
		exports.global:giveMoney( source, earned )
		exports.anticheat:changeProtectedElementDataEx(source, "job-system-trucker:truckruns",(getElementData(source, "job-system-trucker:truckruns") or 0) + 1)
		exports.hud:sendBottomNotification(source, "RS Haul Operator: ", "Customer paid you $"..formartedEarned.." for delivering "..exports.global:formatWeight(droppedWeight).." of supplies over a distance of "..exports.global:formatLength(distance)..".")
	else
		exports.hud:sendBottomNotification(source, "RS Haul Operator: ", marker.." Return to RS Haul's warehouse first.")
	end

	if supplies_remain and supplies_remain > 0 then
		spawnRoute(source, true)
	else
		triggerClientEvent(source,"truckerjob:clearRoute", source)
		freeSpot( source )
	end
	updateOverLay(source, {carried=supplies_remain})
end
addEvent("truckerjob:checkIfPlayerTruckHasEnoughtShit", true)
addEventHandler("truckerjob:checkIfPlayerTruckHasEnoughtShit", root, checkIfPlayerTruckHasEnoughtShit)

function unloadCrates(thePlayer, veh)
	if getVehicleOccupant(veh) == thePlayer then
		local truckModel = getElementModel(veh)
		local truck = truckerJobVehicleInfo[truckModel]
		if not truck then
			return false, "RS Haul doesn't allow this vehicle model."
		end
		local currentSpot = handledSpot(thePlayer)
		if currentSpot then
			currentSpot[4] = currentSpot[4] or getRandomRequiredWeight(truckModel)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "job-system-trucker:currentRoute", currentSpot) -- update weight to client GUI.
			-- just take all supplies from the truck first.
			local whatPlayerHas = 0
			for key, item in pairs(exports["item-system"]:getItems(veh)) do
				if item[1] == 121 then
					if tonumber(item[2]) and tonumber(item[2]) > 0 then
						exports["item-system"]:takeItem(veh, 121,item[2])
						whatPlayerHas = whatPlayerHas + tonumber(item[2])
					end
				end
			end
			if whatPlayerHas > 0 then
				local value = currentSpot[4]
				if type(currentSpot[4]) == 'table' then
					value = 50
				end
				local truck_remain = exports.global:round( math.max( 0, whatPlayerHas - value ), 2 )
				local supplies_dropped = exports.global:round( whatPlayerHas - truck_remain, 2 )
				-- give the truck what's remained after dropping off.
				if truck_remain > 0 then
					exports["item-system"]:giveItem(veh, 121, tostring(truck_remain) )
				end
				-- if it was an actual order from real player.
				if currentSpot[8] and tonumber(currentSpot[8]) > 0 then
					updateActualOrder( currentSpot, currentSpot[4] )
				end
				-- finish it.
				playSoundFX( veh )
				return true, currentSpot, supplies_dropped, truck_remain
			else
				return false, "Your truck is empty."
			end
		else
			return false, "((Script Error Code 407))"
		end
	else
		return false, "You can not use other people's vehicle."
	end

	return false, "((Script Error Code 412))"
end

function updateActualOrder( marker, supplies_dropped )
	-- now update interior supplies.
	local interior = exports.pool:getElement( 'interior', marker[8] )
	if interior and not tonumber(supplies_dropped) then
		local status = getElementData( interior, 'status' )
		local supplies = fromJSON(status.supplies)
		for i, v in pairs(supplies_dropped) do
			supplies[i] = (supplies[i] or 0) + v
		end
		status.supplies = toJSON(supplies)
		exports.anticheat:setEld( interior, 'status', status, 'all' )
		dbExec( exports.mysql:getConn('mta'), "UPDATE interiors SET supplies=? WHERE id=?", toJSON(supplies), marker[8] )
	end
	-- now determine whether or not the marker will be removed.
	for i, route in pairs( routes ) do
		if route[7] == marker[7] then
			table.remove( routes, i )
			dbExec( exports.mysql:getConn('mta'), "DELETE FROM jobs_trucker_orders WHERE orderID=?", marker[7] )
			break
		end
	end
end

function updateNextCheckpoint(pointid)
	if not pointid then pointid = -1 end
	exports.anticheat:changeProtectedElementDataEx(source, "job-system-trucker:currentRouteID",pointid )
end
addEvent("updateNextCheckpoint", true)
addEventHandler("updateNextCheckpoint", root, updateNextCheckpoint)

function restoreTruckingJob()
	if getElementData(source, "job") == 1 then
		triggerClientEvent(source, "restoreTruckerJob", source)
	end
end
addEventHandler("restoreJob", root, restoreTruckingJob)

function respawnAllTrucks()
	local vehicles = exports.pool:getPoolElementsByType("vehicle")
	local counter = 0

	for k, theVehicle in ipairs(vehicles) do
		local dbid = getElementData(theVehicle, "dbid")
		if dbid and dbid > 0 then
			if getElementData(theVehicle, "job") == 1 then
				local driver = getVehicleOccupant(theVehicle)
				local pass1 = getVehicleOccupant(theVehicle, 1)
				local pass2 = getVehicleOccupant(theVehicle, 2)
				local pass3 = getVehicleOccupant(theVehicle, 3)

				if not pass1 and not pass2 and not pass3 and not driver and not getVehicleTowingVehicle(theVehicle) and #getAttachedElements(theVehicle) == 0 then
					if isElementAttached(theVehicle) then
						detachElements(theVehicle)
					end
					respawnVehicle(theVehicle)
					setVehicleLocked(theVehicle, false)
					setElementInterior(theVehicle, getElementData(theVehicle, "interior"))
					setElementDimension(theVehicle, getElementData(theVehicle, "dimension"))
					exports.anticheat:changeProtectedElementDataEx(theVehicle, "vehicle:radio", 0, true)
					counter = counter + 1
				end
			end
		end
	end
	return counter
end
--setTimer(respawnAllTrucks, 60000*5, 0) -- Check and respawn every 5 minutes.

function restartResource()
	for key,player in pairs (getElementsByType("player")) do
		if getElementData(player, "job") == 1 and getPedOccupiedVehicle(player) and getElementData(getPedOccupiedVehicle(player), "job") == 1 then
			checkTruckingEnterVehicle(player, 0)
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, restartResource)

function enteringRSHaulWarehouse1()
	local veh = getPedOccupiedVehicle(source)
	if isElement(veh) then
		setElementAngularVelocity(veh, 0, 0, 0)
		setElementPosition(veh, 1540.7763671875, 1610.8740234375, 15.559964179993)
		setElementRotation(veh,0, 0, 180)
		setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
		setElementInterior(veh, 0)
		setElementDimension(veh, 66)
	end
	--fadeCamera (source, true , 1)
end
addEvent("job-system:trucker:enteringRSHaulWarehouse1", true)
addEventHandler("job-system:trucker:enteringRSHaulWarehouse1", root, enteringRSHaulWarehouse1)

function enteringRSHaulWarehouse2()
	local veh = getPedOccupiedVehicle(source)
	if isElement(veh) then
		setElementAngularVelocity(veh, 0, 0, 0)
		setElementPosition(veh, 1534.1630859375, 1611.2021484375, 15.560300827026)
		setElementRotation(veh,0, 0, 180)
		setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
		setElementInterior(veh, 0)
		setElementDimension(veh, 66)
	end
	--fadeCamera (source, true , 1)
end
addEvent("job-system:trucker:enteringRSHaulWarehouse2", true)
addEventHandler("job-system:trucker:enteringRSHaulWarehouse2", root, enteringRSHaulWarehouse2)

function spawnRouteIfSupplied(player, vehicle)
	local currentCrates = 0
	items = exports['item-system']:getItems( vehicle )
	for i, k in pairs(items) do
		if k[1] == 121 then
			currentCrates = currentCrates + k[2]
		end
	end

	if currentCrates > 0 and not getElementData(player, "job-system-trucker:currentRoute") then
		spawnRoute(player)
	end
end

function exitingRSHaulWarehouse1()
	local veh = getPedOccupiedVehicle(source)
	if isElement(veh) then
		setElementAngularVelocity(veh, 0, 0, 0)
		setElementPosition(veh, -66.40234375, -1120.1865234375, 1.1872147321701 )
		setElementRotation(veh,0, 0, 70)
		setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
		setElementInterior(veh, 0)
		setElementDimension(veh, 0)
    end
    spawnRouteIfSupplied(source, veh)

	--fadeCamera (source, true , 1)
end
addEvent("job-system:trucker:exitingRSHaulWarehouse1", true)
addEventHandler("job-system:trucker:exitingRSHaulWarehouse1", root, exitingRSHaulWarehouse1)

function exitingRSHaulWarehouse2(player)
	local veh = getPedOccupiedVehicle(source)
	if isElement(veh) then
		setElementAngularVelocity(veh, 0, 0, 0)
		setElementPosition(veh, -63.0458984375, -1111.25, 1.1973638534546 )
		setElementRotation(veh,0, 0, 70)
		setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
		setElementInterior(veh, 0)
		setElementDimension(veh, 0)
	end
	spawnRouteIfSupplied(source, veh)

	--fadeCamera (veh, true , 1)
end
addEvent("job-system:trucker:exitingRSHaulWarehouse2", true)
addEventHandler("job-system:trucker:exitingRSHaulWarehouse2", root, exitingRSHaulWarehouse2)

addEventHandler("onResourceStart", resourceRoot, function ()
	fetchOrders()
	for key, thePlayer in pairs(getTruckers()) do
		exports.hud:sendBottomNotification(thePlayer, "Delivery Job Script Update", "A Developer has updated the trucker job system. Please re-enter the truck if you're currently in one.")
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "job-system-trucker:currentRoute", false)
	end
end)

function getTruckers()
	local truckers = {}
	for key, thePlayer in pairs(getElementsByType("player")) do
		if getElementData(thePlayer, "job") == 1 then
			table.insert(truckers, thePlayer)
		end
	end
	return truckers
end

function notifyTruckers(content, notify_off_duty)
	for dbid, player in ipairs(exports.pool:getPoolElementsByType('playerByDbid')) do
		if getElementData(player, "job") == 1 then
			if notify_off_duty then
				outputChatBox(content, player, 120, 255, 80)
			else
				local veh = getPedOccupiedVehicle(player)
				if veh and getElementData(veh, 'job') == 1 then
					outputChatBox(content, player, 120, 255, 80)
				end
			end
		end
	end
end
