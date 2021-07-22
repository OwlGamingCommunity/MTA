--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

mysql = exports.mysql
local timerLoadAllVehicles = 1*1000
local stats_numberOfVehs = 0
local timerDelay = 50
local loadedVehicles = 0
local initializeSoFarDetector = 0
local null = mysql_null()

function SmallestID( ) -- finds the smallest ID in the SQL instead of auto increment
	local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM vehicles AS e1 LEFT JOIN vehicles AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result then
		local id = tonumber(result["nextID"]) or 1
		return id
	end
	return false
end

-- WORKAROUND ABIT
function getVehicleName(vehicle)
	return exports.global:getVehicleName(vehicle)
end


-- makeveh helpers
local function hasCreatePermission( player )
	return exports.integration:isPlayerAdmin(player) or exports.integration:isPlayerLeadScripter(player) or exports.integration:isPlayerVehicleConsultant(player)
end

local function printVehicleCreateSyntax( player, command )
	outputChatBox("SYNTAX: /" .. command .. " [ID from Veh Lib] [color1] [color2] [Owner] [Faction Vehicle (1/0)] [-1=carshop price] [Tinted Windows] ", player, 255, 194, 14)
	outputChatBox("NOTE: If it is a faction vehicle, ownership will be given to the ID specified in the owner field.", player, 255, 194, 14)
	outputChatBox("NOTE: If it is a faction vehicle, the cost is taken from the faction fund, rather than the player.", player, 255, 194, 14)
end

-- /makeveh
function createPermanentVehicle(player, command, ...)
	if hasCreatePermission( player ) then
		local args = {...}
		if #args < 7 then -- die out if they didn't enter all the fields.
			printVehicleCreateSyntax( player, command )
			return
		end

		-- die out if we couldn't find the vehicle in vehlib
		local vehShopData = exports.vehicle_manager:getInfoFromVehShopID(tonumber(args[1]))
		if not vehShopData then
			outputChatBox('Invalid vehicle ID Specified, please use a vehicle ID from /vehlib.', player, 255, 100, 100)
			return
		end

		-- die out if the vehlib ID isn't a valid number.
		local id = tonumber(vehShopData.vehmtamodel)
		if not id then -- the vehicle doesn't have a proper ID
			outputChatBox('Vehicle does not have an MTA model set, please set one using /vehlib.', player, 255, 100, 100)
			return
		end

		-- assign our vehicle data variables
		local primaryColor = tonumber(args[2])
		local secondaryColor = tonumber(args[3])
		local owner = args[4]
		local isFactionOwned = tonumber(args[5]) == 1
		local factionID = -1 -- defaults to -1 as no faction.
		local cost = tonumber(args[6])
		local tint = tonumber(args[7])
		local targetPlayer = nil -- to be set if owner is a player, to send them a message of their new vehicle.

		-- determine where to spawn the vehicle.
		local r = getPedRotation(player)
		local x, y, z = getElementPosition(player)
		x = x + ( ( math.cos ( math.rad ( r ) ) ) * 5 )
		y = y + ( ( math.sin ( math.rad ( r ) ) ) * 5 )

		-- faction vehicle create
		if isFactionOwned then
			local theTeam = exports.factions:getFactionFromID(tonumber(owner))
			if not theTeam then
				outputChatBox("Could not find the faction with the ID: " .. owner .. ".", player, 255, 100, 100 )
				return
			end
			factionID = tonumber(owner)
			owner = -1
			if not exports.global:takeMoney(theTeam, cost) then
				outputChatBox("[MAKEVEH] This faction cannot afford this vehicle.", player, 255, 100, 100)
				outputChatBox("That faction cannot afford this vehicle.", player, 255, 100, 100)
				return
			end
		else
			local other, name = exports.global:findPlayerByPartialNick( player, owner )
			if other then
				targetPlayer = other
				owner = getElementData( other, "dbid" ) -- set owner to the character ID of other player.
				if not exports.global:canPlayerBuyVehicle(other) then
					outputChatBox("[MAKEVEH] This player has too many cars.", player, 255, 0, 0)
					outputChatBox("You have too many cars.", other, 255, 0, 0)
					return
				elseif not exports.global:takeMoney(other, cost) then
					outputChatBox("[MAKEVEH] This player cannot afford this vehicle.", player, 255, 0, 0)
					outputChatBox("You cannot afford this vehicle.", other, 255, 0, 0)
					return
				end
			else
				return -- die out if no player found.
			end
		end

		-- create a random vehicle plate
		local letter1 = string.char(math.random(65,90))
		local letter2 = string.char(math.random(65,90))
		local plate = letter1 .. letter2 .. math.random(0, 9) .. " " .. math.random(1000, 9999)

		-- create a vehicle temporarily so we can get its name, colors and validate that it is an actual vehicle.
		local veh = createVehicle(id, x, y, z, 0, 0, r, plate)
		if not veh then
			outputChatBox("Invalid MTA vehicle model specified in vehlib.", player, 255, 100, 100)
			return
		end
		-- set the temp vehicle's color to the entered color scheme.
		setVehicleColor(veh, primaryColor, secondaryColor, primaryColor, secondaryColor)

		-- retrieve the JSON data containing the full car colors
		local col =  { getVehicleColor(veh, true) }
		local color1 = toJSON( {col[1], col[2], col[3]} )
		local color2 = toJSON( {col[4], col[5], col[6]} )
		local color3 = toJSON( {col[7], col[8], col[9]} )
		local color4 = toJSON( {col[10], col[11], col[12]} )

		-- hold onto the vehicle's name and destroy the vehicle
		local vehicleName = getVehicleName(veh)
		destroyElement(veh)

		-- determine the location of the player
		local dimension = getElementDimension(player)
		local interior = getElementInterior(player)

		-- store vehicle variants
		local var1, var2 = exports.vehicle:getRandomVariant(id)

		-- build our query
		local qh = dbQuery( exports.mysql:getConn('mta'), "INSERT INTO vehicles SET id="..exports.mysql:getSmallestID('vehicles')..", model=?, x=?, y=?, z=?, rotx='0', roty='0', rotz=?, "
		.. " color1=?, color2=?, color3=?, color4=?, faction=?, owner=?, plate=?, currx=?, curry=?, currz=?, currrx='0', currry='0', currrz=?, locked=1, interior=?, currinterior=?, "
		.. "dimension=?, currdimension=?, tintedwindows=?, variant1=?, variant2=?, creationDate=NOW(), createdBy=?, `vehicle_shop_id`=? ",
		id, x, y, z, r, color1, color2, color3, color4, factionID, owner, plate, x ,y, z, r, interior, interior, dimension, dimension, tint, var1, var2, getElementData(player, "account:id"), args[1] )

		local result, num_affected_rows, last_insert_id = dbPoll ( qh, 5000 )

		if (result) then

			local owner = ""
			if not isFactionOwned then
				exports.global:giveItem(targetPlayer, 3, tonumber(last_insert_id)) -- give a key to the new vehicle owner if there is one
				owner = getPlayerName( targetPlayer )
			else
				owner = "Faction #" .. factionID
			end

			exports.logs:dbLog(player, 6, { "ve" .. last_insert_id }, "SPAWNVEH '"..vehicleName.."' $"..cost.." "..owner )

			local hiddenAdmin = getElementData(player, "hiddenadmin")
			local adminTitle = exports.global:getPlayerAdminTitle(player)
			local adminUsername = getElementData(player, "account:username")
			local adminID = getElementData(player, "account:id")

			dbExec( exports.mysql:getConn('mta'), "INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES (?, ?, ?) ", last_insert_id, command.." "..vehicleName.." ($"..cost.." - to "..owner..")" , adminID )

			if (hiddenAdmin==0) then
				exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(player) .. " ("..adminUsername..") has spawned a "..vehicleName .. " (ID #" .. last_insert_id .. ") to "..owner.." for $"..cost..".")
				if not isFactionOwned then
					outputChatBox(tostring(adminTitle) .. " " .. getPlayerName(player) .. " has spawned a "..vehicleName .. " (ID #" .. last_insert_id .. ") to "..owner.." for $"..cost..".", targetPlayer, 255, 194, 14)
				end
			else
				exports.global:sendMessageToAdmins("AdmCmd: A Hidden Admin has spawned a "..vehicleName .. " (ID #" .. last_insert_id .. ") to "..owner.." for $"..cost..".")
				if not isFactionOwned then
					outputChatBox("A Hidden Admin has spawned a "..vehicleName .. " (ID #" .. last_insert_id .. ") to "..owner.." for $"..cost..".", targetPlayer, 255, 194, 14)
				end
			end
			outputChatBox("[MAKEVEH] "..vehicleName .. " (ID #" .. last_insert_id .. ") successfully spawned to "..owner..".", player, 0, 255, 0)

			if not isFactionOwned then
				outputChatBox("[MAKEVEH] $"..cost.." has been taken from player's inventory.", player, 0, 255, 0)
				outputChatBox("$"..cost.." has been taken from your inventory.", targetPlayer, 0, 255, 0)
			else
				outputChatBox("[MAKEVEH] $"..cost.." has been taken from player's faction bank.", player, 0, 255, 0)
			end

			reloadVehicle(tonumber(last_insert_id))
		else
			dbFree( qh )
		end
	end
end
addCommandHandler("makeveh", createPermanentVehicle, false, false)

-- /makecivveh
function createCivilianPermVehicle(thePlayer, commandName, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local args = {...}
		if (#args < 4) then
			outputChatBox("SYNTAX: /" .. commandName .. " [id/name] [color1 (-1 for random)] [color2 (-1 for random)] [Job ID -1 for none]", thePlayer, 255, 194, 14)
			outputChatBox("Job 1 = Delivery Driver", thePlayer, 255, 194, 14)
			outputChatBox("Job 2 = Taxi Driver", thePlayer, 255, 194, 14)
			outputChatBox("Job 3 = Bus Driver", thePlayer, 255, 194, 14)
		else
			local vehicleID = tonumber(args[1])
			local col1, col2, job

			if not vehicleID then -- vehicle is specified as name
				local vehicleEnd = 1
				repeat
					vehicleID = getVehicleModelFromName(table.concat(args, " ", 1, vehicleEnd))
					vehicleEnd = vehicleEnd + 1
				until vehicleID or vehicleEnd == #args
				if vehicleEnd == #args then
					outputChatBox("Invalid Vehicle Name.", thePlayer, 255, 0, 0)
					return
				else
					col1 = tonumber(args[vehicleEnd])
					col2 = tonumber(args[vehicleEnd + 1])
					job = tonumber(args[vehicleEnd + 2])
				end
			else
				col1 = tonumber(args[2])
				col2 = tonumber(args[3])
				job = tonumber(args[4])
			end

			local id = vehicleID

			local r = getPedRotation(thePlayer)
			local x, y, z = getElementPosition(thePlayer)
			local interior = getElementInterior(thePlayer)
			local dimension = getElementDimension(thePlayer)
			x = x + ( ( math.cos ( math.rad ( r ) ) ) * 5 )
			y = y + ( ( math.sin ( math.rad ( r ) ) ) * 5 )

			local letter1 = string.char(math.random(65,90))
			local letter2 = string.char(math.random(65,90))
			local plate = letter1 .. letter2 .. math.random(0, 9) .. " " .. math.random(1000, 9999)

			local veh = createVehicle(id, x, y, z, 0, 0, r, plate)
			if not (veh) then
				outputChatBox("Invalid Vehicle ID.", thePlayer, 255, 0, 0)
			else
				local vehicleName = getVehicleName(veh)
				destroyElement(veh)

				local var1, var2 = exports.vehicle:getRandomVariant(id)
				local smallestID = SmallestID()
				local insertid = mysql:query_insert_free("INSERT INTO vehicles SET id='" .. mysql:escape_string(smallestID) .. "', job='" .. mysql:escape_string(job) .. "', model='" .. mysql:escape_string(id) .. "', x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .. "', z='" .. mysql:escape_string(z) .. "', rotx='" .. mysql:escape_string("0.0") .. "', roty='" .. mysql:escape_string("0.0") .. "', rotz='" .. mysql:escape_string(r) .. "', color1='[ [ 0, 0, 0 ] ]', color2='[ [ 0, 0, 0 ] ]', color3='[ [ 0, 0, 0 ] ]', color4='[ [0, 0, 0] ]', faction='-1', owner='-2', plate='" .. mysql:escape_string(plate) .. "', currx='" .. mysql:escape_string(x) .. "', curry='" .. mysql:escape_string(y) .. "', currz='" .. mysql:escape_string(z) .. "', currrx='0', currry='0', currrz='" .. mysql:escape_string(r) .. "', interior='" .. mysql:escape_string(interior) .. "', currinterior='" .. mysql:escape_string(interior) .. "', dimension='" .. mysql:escape_string(dimension) .. "', currdimension='" .. mysql:escape_string(dimension) .. "',variant1="..var1..",variant2="..var2..", creationDate=NOW(), createdBy="..getElementData(thePlayer, "account:id").."")
				if (insertid) then
					reloadVehicle(insertid)
					exports.logs:dbLog(thePlayer, 6, { "ve" .. insertid }, "SPAWNVEH '"..vehicleName.."' CIVILLIAN")

					local adminID = getElementData(thePlayer, "account:id")
					local addLog = mysql:query_free("INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES ('"..tostring(insertid).."', '"..commandName.." "..vehicleName.." (job "..job..")', '"..adminID.."')") or false
					if not addLog then
						outputDebugString("Failed to add vehicle logs.")
					end
				end
			end
		end
	end
end
addCommandHandler("makecivveh", createCivilianPermVehicle, false, false)

function reloadVehicle( id )
	local theVehicle = exports.pool:getElement("vehicle", tonumber(id) )
	if theVehicle then
		removeSafe(tonumber(id))
		exports.vehicle:saveVehicle( theVehicle )
		destroyElement( theVehicle )
	end
	exports.vehicle_load:loadOneVehicle( id )
	return true
end

function vehicleExploded()
	local job = getElementData(source, "job")

	if not job or job<=0 then
		setTimer(respawnVehicle, 60000, 1, source)
	end
end
addEventHandler("onVehicleExplode", getRootElement(), vehicleExploded)

function vehicleRespawn(exploded)
	local id = getElementData(source, "dbid")
	local faction = getElementData(source, "faction")
	local job = getElementData(source, "job")
	local owner = getElementData(source, "owner")
	local windowstat = getElementData(source, "vehicle:windowstat")

	if (job>0) then
		toggleVehicleRespawn(source, true)
		setVehicleRespawnDelay(source, 60000)
		setVehicleIdleRespawnDelay(source, 15 * 60000)
		exports.anticheat:changeProtectedElementDataEx(source, "handbrake", 1, false)
		exports.anticheat:changeProtectedElementDataEx(source, "enginebroke", 0, false)
	end

	-- Set the vehicle armored if it is armored
	local vehid = getElementModel(source)
	if (armoredCars[tonumber(vehid)]) then
		setVehicleDamageProof(source, true)
	else
		setVehicleDamageProof(source, false)
	end

	setVehicleFuelTankExplodable(source, false)
	setVehicleLandingGearDown(source, true)

	exports.anticheat:changeProtectedElementDataEx(source, "dbid", id)
	exports.anticheat:setEld( source, "fuel", exports.vehicle_fuel:getMaxFuel(source) )
	exports.anticheat:setEld( source, "battery", 100 )
	exports.anticheat:setEld( source, "lights", 0 )
	setVehicleOverrideLights(source, 1)
	exports.anticheat:setEld( source, "vehicle:radio", 0, 'all' )
	setVehicleEngineState( source, false )
	exports.anticheat:setEld( source, "engine", 0 )
	exports.anticheat:changeProtectedElementDataEx(source, "vehicle:windowstat", windowstat, false)
	exports.anticheat:changeProtectedElementDataEx(source, "faction", faction)
	exports.anticheat:changeProtectedElementDataEx(source, "owner", owner, false)


	setElementFrozen(source, true)

	-- Set the sirens off
	setVehicleSirensOn(source, false)

	local dimension = getElementData(source, "dimension") or 0
	local interior = getElementData(source, "interior") or 0

	setElementDimension(source, dimension)
	setElementInterior(source, interior)

	-- unlock civ vehicles
	if owner < 0 then
		setVehicleLocked(source, false)
		exports.anticheat:changeProtectedElementDataEx(source, "handbrake", 1, false)
	end

	setElementFrozen(source, getElementData(source, "handbrake") == 1)
end
addEventHandler("onVehicleRespawn", root, vehicleRespawn)

function vehicleExit(thePlayer, seat)
	if (isElement(thePlayer)) then
		toggleControl(thePlayer, 'brake_reverse', true)
		-- For oldcar
		local vehid = getElementData(source, "dbid")
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "lastvehid", vehid, false)
		setPedGravity(thePlayer, 0.008)
		setElementFrozen(thePlayer, false)
	end
end
addEventHandler("onVehicleExit", getRootElement(), vehicleExit)

function destroyTyre(veh)
	local tyre1, tyre2, tyre3, tyre4 = getVehicleWheelStates(veh)

	if (tyre1==1) then
		tyre1 = 2
	end

	if (tyre2==1) then
		tyre2 = 2
	end

	if (tyre3==1) then
		tyre3 = 2
	end

	if (tyre4==1) then
		tyre4 = 2
	end

	if (tyre1==2 and tyre2==2 and tyre3==2 and tyre4==2) then
		tyre3 = 0
	end

	exports.anticheat:changeProtectedElementDataEx(veh, "tyretimer")
	setVehicleWheelStates(veh, tyre1, tyre2, tyre3, tyre4)
end

function damageTyres()
	local tyre1, tyre2, tyre3, tyre4 = getVehicleWheelStates(source)
	local tyreTimer = getElementData(source, "tyretimer")

	if (tyretimer~=1) then
		if (tyre1==1) or (tyre2==1) or (tyre3==1) or (tyre4==1) then
			exports.anticheat:changeProtectedElementDataEx(source, "tyretimer", 1, false)
			local randTime = math.random(5, 15)
			randTime = randTime * 1000
			setTimer(destroyTyre, randTime, 1, source)
		end
	end
end
addEventHandler("onVehicleDamage", getRootElement(), damageTyres)

-- Bind Keys required
function bindKeys()
	local players = exports.pool:getPoolElementsByType("player")
	for k, arrayPlayer in ipairs(players) do
		if not(isKeyBound(arrayPlayer, "l", "down", "lights")) then
			bindKey(arrayPlayer, "l", "down", "lights")
		end

		if not(isKeyBound(arrayPlayer, "k", "down", toggleLock)) then
			bindKey(arrayPlayer, "k", "down", toggleLock)
		end
	end
end

local lockSpam = {}
function toggleLock(source, key, keystate)
	local veh = getPedOccupiedVehicle(source)
	local inVehicle = getElementData(source, "realinvehicle")

	if (not lockSpam[source]) then
		lockSpam[source] = 1
	elseif (lockSpam[source] == 5) then
		outputChatBox("Please refrain from command spamming!", source, 255, 0, 0)
		exports.global:sendMessageToAdmins("AdmWarn: " .. getPlayerName(source) .. " is spamming lock/unlock.")
		outputDebugString( "Possible command spam from: " .. getPlayerName(source) .. " LOCK/UNLOCK")
		return
	else
		lockSpam[source] = lockSpam[source] + 1
	end

	if (veh) and (inVehicle==1) then
		triggerEvent("lockUnlockInsideVehicle", source, veh)
	elseif not veh then
		if getElementDimension(source) >= 19000 then
			local vehicle = exports.pool:getElement("vehicle", getElementDimension(source) - 20000)
			if vehicle and exports['vehicle-interiors']:isNearExit(source, vehicle) then
				local model = getElementModel(vehicle)
				local owner = getElementData(vehicle, "owner")
				local dbid = getElementData(vehicle, "dbid")

				--if (owner ~= -1) then
					if ( getElementData(vehicle, "Impounded") or 0 ) == 0 then
						local locked = isVehicleLocked(vehicle)
						if (locked) then
							setVehicleLocked(vehicle, false)
							triggerEvent('sendAme', source, "unlocks the vehicle doors.")
						else
							setVehicleLocked(vehicle, true)
							local doors = getDoorsFor(getElementModel(vehicle), -1)
							for index, doorEntry in ipairs(doors) do
								setVehicleDoorOpenRatio(vehicle, doorEntry[2], 0, 0.5)
							end
							triggerEvent('sendAme', source, "locks the vehicle doors.")
						end
					else
						outputChatBox("(( You can't lock impounded vehicles. ))", source, 255, 195, 14)
					end
				--else
					--outputChatBox("(( You can't lock civilian vehicles. ))", source, 255, 195, 14)
				--end
				return
			end
		end

		local interiorFound, interiorDistance = exports.interior_system:lockUnlockHouseEvent(source, true)

		local x, y, z = getElementPosition(source)
		local nearbyVehicles = exports.global:getNearbyElements(source, "vehicle", 30)

		local found = nil
		local shortest = 31
		for i, veh in ipairs(nearbyVehicles) do
			local dbid = tonumber(getElementData(veh, "dbid"))
			local distanceToVehicle = getDistanceBetweenPoints3D(x, y, z, getElementPosition(veh))
			if shortest > distanceToVehicle and ( exports.global:isStaffOnDuty(source) or exports.global:hasItem(source, 3, dbid) or exports.factions:isPlayerInFaction(source, getElementData(veh, "faction")) ) then
				shortest = distanceToVehicle
				found = veh
			end
		end

		if (interiorFound and found) then
			if shortest < interiorDistance then
				if getVehicleType(found) == "BMX" and not exports.global:isStaffOnDuty(source) and not exports.global:hasItem(found, 275) then
					return
				end	
				triggerEvent("lockUnlockOutsideVehicle", source, found)
			else
				triggerEvent("lockUnlockHouse", source)
			end
		elseif found then
			if getVehicleType(found) == "BMX" and not exports.global:isStaffOnDuty(source) and not exports.global:hasItem(found, 275) then
				return
			end	
			triggerEvent("lockUnlockOutsideVehicle", source, found)
		elseif interiorFound then
			triggerEvent("lockUnlockHouse", source)
		end
	end
end
addCommandHandler("lock", toggleLock)
addEvent("togLockVehicle", true)
addEventHandler("togLockVehicle", getRootElement(), toggleLock)

setTimer(function() lockSpam = {} end, 5000, 0) -- Clear the table every 5 seconds

function checkLock(thePlayer, seat, jacked)
	local locked = isVehicleLocked(source)

	if (locked) and not (jacked) then
		cancelEvent()
		outputChatBox("The door is locked.", thePlayer)
	end
end
addEventHandler("onVehicleStartExit", getRootElement(), checkLock)

local lightTogs = { }
function toggleLights(source, key, keystate)
	local veh = getPedOccupiedVehicle(source)
	if veh then
		if ( getElementData( veh, 'battery' ) or 100 ) > 0 then
			if getElementData(source, "realinvehicle") == 1 then
				local model = getElementModel(veh)
				if not (lightlessVehicle[model]) then
					local lights = getVehicleOverrideLights(veh)
					local seat = getPedOccupiedVehicleSeat(source)
					local flashers = getElementData(veh, "lspd:flashers")
					if (seat==0 and not flashers) then
						-- if not forced on.
						local light_state = getElementData(veh, 'lights') or 0
						if light_state == 0 then
							light_state = 1
							setVehicleOverrideLights(veh, 2)
							local trailer = getVehicleTowedByVehicle(veh)
							if trailer then
								setVehicleOverrideLights(trailer, 2)
							end
						elseif light_state >= 1 then
							light_state = 0
							setVehicleOverrideLights(veh, 1)
							local trailer = getVehicleTowedByVehicle(veh)
							if trailer then
								setVehicleOverrideLights(trailer, 1)
							end
						end
						exports.anticheat:setEld(veh, "lights", light_state, 'all')
					end
				end
			end
		else
			exports.hud:sendBottomNotification( source, exports.global:getVehicleName(veh), "Battery ran out." )
		end
	end
end
addCommandHandler("lights", toggleLights, false)
addEvent('togLightsVehicle', true)
addEventHandler('togLightsVehicle', root,
	function()
		toggleLights(client)
	end)

--/////////////////////////////////////////////////////////
--Fix for spamming keys to unlock etc on entering
--/////////////////////////////////////////////////////////

-- bike lock fix
function checkBikeLock(thePlayer)
	if (isVehicleLocked(source)) and (getVehicleType(source)=="Bike" or getVehicleType(source)=="Boat" or getVehicleType(source)=="BMX" or getVehicleType(source)=="Quad" or getElementModel(source)==568 or getElementModel(source)==571 or getElementModel(source)==572 or getElementModel(source)==424 or getElementModel(source)==431 or getElementModel(source)==437) then
		if not getElementData(thePlayer, "interiormarker") then
			outputChatBox("That vehicle is locked.", thePlayer, 255, 194, 15)
		end
		cancelEvent()
	end
end
addEventHandler("onVehicleStartEnter", getRootElement(), checkBikeLock)

function setRealInVehicle(thePlayer)
	if isVehicleLocked(source) then
		exports.anticheat:setEld( thePlayer, "realinvehicle", 0, 'one' )
		removePedFromVehicle(thePlayer)
		setVehicleLocked(source, true)
	else
		local vehName = exports.global:getVehicleName( source )
		exports.anticheat:setEld( thePlayer, "realinvehicle", 1, 'one' )

		-- 0000464: Car owner message.
		local owner = getElementData(source, "owner") or -1
		local faction = getElementData(source, "faction") or -1

		if owner < 0 and faction == -1 then
			exports.hud:sendBottomNotification( thePlayer, vehName, "(( This "..vehName.." is a civilian vehicle. ))" )
		elseif (faction==-1) and (owner>0) then
			local ownerName = exports['cache']:getCharacterName(owner)
			if ownerName and exports.integration:isPlayerTrialAdmin( thePlayer, true ) then
				exports.hud:sendBottomNotification( thePlayer, vehName, "(( This "..vehName.." belongs to " .. ownerName .. " ))" )
			end
		elseif (faction~=-1) then
			local factionName = exports.cache:getFactionNameFromId(faction) or "Unknown Faction"
			exports.hud:sendBottomNotification( thePlayer, vehName, "(( This vehicle belongs to " .. factionName .. ". ))" )
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), setRealInVehicle)

function setRealNotInVehicle(thePlayer)
	local locked = isVehicleLocked(source)
	if not (locked) then
		if (thePlayer) then
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "realinvehicle", 0, false)
		end
	end
end
addEventHandler("onVehicleStartExit", getRootElement(), setRealNotInVehicle)

-- Faction vehicles removal script
function removeFromFactionVehicle(thePlayer)
	local vfaction = getElementData( source, "faction" )
	local CanTowDriverEnter = (call(getResourceFromName("tow-system"), "CanTowTruckDriverVehPos", thePlayer) == 2)
	if (vfaction~=-1) then
		local seat = getPedOccupiedVehicleSeat(thePlayer)
		local factionName = "None (to be deleted)"
		for key, value in ipairs(exports.pool:getPoolElementsByType("team")) do
			local id = tonumber(getElementData(value, "id"))
			if (id==vfaction) then
				factionName = getTeamName(value)
				break
			end
		end
		if seat==0 then
			if (CanTowDriverEnter) then
				exports.anticheat:setEld( source, "enginebroke", 1 )
				setVehicleDamageProof( source, true )
				setVehicleEngineState( source, false )
			end
		end
	end

	local Impounded = getElementData(source,"Impounded")
	if (Impounded and Impounded > 0) then
		exports.anticheat:changeProtectedElementDataEx(source, "enginebroke", 1, false)
		setVehicleDamageProof(source, true)
		setVehicleEngineState(source, false)
	end
	if (CanTowDriverEnter) then -- Nabs abusing
		return
	end
	local vjob = tonumber(getElementData(source, "job")) or -1
	local job = getElementData(thePlayer, "job") or -1
	local seat = getPedOccupiedVehicleSeat(thePlayer)

	if (vjob>0) and (seat==0) then
		-- remove masks etc. for civilian job vehicles
		for key, value in pairs(exports['item-system']:getMasks()) do
			if getElementData(thePlayer, value[1]) then
				exports.global:sendLocalMeAction(thePlayer, value[3] .. ".")
				exports.anticheat:changeProtectedElementDataEx(thePlayer, value[1], false, true)
			end
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), removeFromFactionVehicle)

-- engines dont break down
function doBreakdown()
	if exports.global:hasItem(source, 74) then
		while exports.global:hasItem(source, 74) do
			exports.global:takeItem(source, 74)
		end

		blowVehicle(source)
	else
		local health = getElementHealth(source)
		local broke = getElementData(source, "enginebroke")

		if (health<=350) and (broke==0 or broke==false) then
			setElementHealth(source, 300)
			setVehicleDamageProof(source, true)
			setVehicleEngineState(source, false)
			exports.anticheat:changeProtectedElementDataEx(source, "enginebroke", 1, false)
			exports.anticheat:changeProtectedElementDataEx(source, "engine", 0, false)

			local player = getVehicleOccupant(source)
			if player then
				toggleControl(player, 'brake_reverse', false)
			end
		end
	end
end
addEventHandler("onVehicleDamage", getRootElement(), doBreakdown)



------------------------------------------------
-- SELL A VEHICLE
------------------------------------------------
function sellVehicle(thePlayer, commandName, targetPlayerName, itemValue)
	-- can only sell vehicles outdoor, in a dimension is property
	if isPedInVehicle(thePlayer) then
		if not targetPlayerName then
			outputChatBox("SYNTAX: /" .. commandName .. " [partial player name / id]", thePlayer, 255, 194, 14)
			outputChatBox("Sells the Vehicle you're in to that Player.", thePlayer, 255, 194, 14)
			outputChatBox("Ask the buyer to use /pay to recieve the money for the vehicle.", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerName)
			if targetPlayer and getElementData(targetPlayer, "dbid") then
				local px, py, pz = getElementPosition(thePlayer)
				local tx, ty, tz = getElementPosition(targetPlayer)
				if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) < 20 then
					local theVehicle = getPedOccupiedVehicle(thePlayer)
					if theVehicle then
						local vehicleID = getElementData(theVehicle, "dbid")
						local faction = getElementData(theVehicle, "faction")
						local isLeader = exports.factions:hasMemberPermissionTo(thePlayer, faction, "respawn_vehs")
						if getElementData(theVehicle, "owner") == getElementData(thePlayer, "dbid") or isLeader or (exports.integration:isPlayerAdmin(thePlayer, true)) then
							if getElementData(targetPlayer, "dbid") ~= getElementData(theVehicle, "owner") then
								if getElementData(theVehicle, "token") then
									outputChatBox("You cannot sell this vehicle to another player as you purchased it with a token.", thePlayer, 255, 0, 0)
									return
								end
								if exports.global:hasSpaceForItem(targetPlayer, 3, vehicleID) then
									if exports.global:canPlayerBuyVehicle(targetPlayer) then
										--if exports.integration:isPlayerTrialAdmin(thePlayer) --[[or exports['carshop-system']:isForSale(theVehicle)]] then
											local query = mysql:query_free("UPDATE vehicles SET faction=-1, owner = '" .. mysql:escape_string(getElementData(targetPlayer, "dbid")) .. "', tokenUsed=0, lastUsed=NOW() WHERE id='" .. mysql:escape_string(vehicleID) .. "'")
											if query then
												exports.anticheat:changeProtectedElementDataEx(theVehicle, "faction", -1, true)
												exports.anticheat:changeProtectedElementDataEx(theVehicle, "owner", getElementData(targetPlayer, "dbid"), true)
												exports.anticheat:changeProtectedElementDataEx(theVehicle, "owner_last_login", exports.datetime:now(), true)
												exports.anticheat:changeProtectedElementDataEx(theVehicle, "lastused", exports.datetime:now(), true)

												exports.global:takeItem(thePlayer, 3, vehicleID)

												if not exports.global:hasItem(targetPlayer, 3, vehicleID) then
													exports.global:giveItem(targetPlayer, 3, vehicleID)
												end

												outputChatBox("You've successfully sold your " .. exports.global:getVehicleName(theVehicle) .. " to " .. targetPlayerName .. ".", thePlayer, 0, 255, 0)
												outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " sold you a " .. exports.global:getVehicleName(theVehicle) .. ".", targetPlayer, 0, 255, 0)
												outputChatBox("Please remember to /park your " .. exports.global:getVehicleName(theVehicle) .. ".", targetPlayer, 255, 255, 0)

												-- Delete insurance for vehicle
												if exports.global:isResourceRunning("insurance") then
													exports.insurance:cancelPolicy(vehicleID, thePlayer) --Due to cache, it is better to call this function than to do it directly in DB. /Exciter
												else
													dbExec(exports.mysql:getConn('mta'), "DELETE FROM `insurance_data` WHERE `vehicleid` = ?", vehicleID)
												end

												if eventName == "sellVehiclePapers" then
													exports.global:takeItem(thePlayer, 173, itemValue)
													triggerClientEvent(thePlayer, "close:build_carsale_gui", thePlayer)
												end


												local adminID = getElementData(thePlayer, "account:id")
												local addLog = mysql:query_free("INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES ('"..tostring(vehicleID).."', '"..commandName.." to "..getPlayerName(targetPlayer).."', '"..adminID.."')") or false
												if not addLog then
													outputDebugString("Failed to add vehicle logs.")
												end
												exports.logs:dbLog(thePlayer, 6, { theVehicle, thePlayer, targetPlayer }, "SELL '".. getVehicleName(theVehicle).."' '".. (getPlayerName(thePlayer):gsub("_", " ")) .."' => '".. targetPlayerName .."'")

											else
												outputChatBox("Unable to process request - report on http:owlgaming.net/support.php", thePlayer, 255, 0, 0)
											end
										--else
											--outputChatBox("You can not sell special vehicles. Contact an admin via F2 to have it refunded.", thePlayer, 255, 0, 0)
										--end
									else
										outputChatBox(targetPlayerName .. " has already too much vehicles.", thePlayer, 255, 0, 0)
										outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " tried to sell you a car, but you have too much cars already.", targetPlayer, 255, 0, 0)
									end
								else
									outputChatBox(targetPlayerName .. " has no space for the vehicle keys.", thePlayer, 255, 0, 0)
									outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " tried to sell you a car, but you haven't got space for a key.", targetPlayer, 255, 0, 0)
								end
							else
								outputChatBox("You can't sell your own vehicle to yourself.", thePlayer, 255, 0, 0)
							end
						else
							outputChatBox("This vehicle is not yours.", thePlayer, 255, 0, 0)
						end
					else
						outputChatBox("You must be in a Vehicle.", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("You are too far away from " .. targetPlayerName .. ".", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addEvent("sellVehicle", true)
addEventHandler("sellVehicle", getResourceRootElement(), sellVehicle)
addEvent("sellVehiclePapers", true)
addEventHandler("sellVehiclePapers", resourceRoot, sellVehicle)

function toggleSellExceptions (thePlayer, commandName, player)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) and player then
		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, player)
		if getElementData(targetPlayer, "temporarySell") == true then
			setElementData(targetPlayer, "temporarySell", false)
			outputChatBox("You have revoked "..targetPlayerName.." temporary access to use /sell.", thePlayer)
			outputChatBox("An administrator has revoked your temporary access to use /sell.", targetPlayer)
		else
			setElementData(targetPlayer, "temporarySell", true)
			outputChatBox("You have given "..targetPlayerName.." temporary access to use /sell.", thePlayer)
			outputChatBox("An administrator has given you temporary access to use /sell.", targetPlayer)
		end
	elseif not player and (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		outputChatBox("SYNTAX: /"..commandName.." [player] - This gives temporary access for old /sell.", thePlayer)
	end
end
addCommandHandler("tempsell", toggleSellExceptions)

function AdminVehicleSale(thePlayer, commandName, args)
	if isPedInVehicle(thePlayer) then
		local vehType = getVehicleType(getPedOccupiedVehicle(thePlayer))
		if ( vehType == ("Plane" or "Helicopter" or "Boat") or (getElementData(thePlayer, "temporarySell") == true ) or (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) ) and not args then
			outputChatBox("SYNTAX: /" .. commandName .. " [partial player name / id]", thePlayer, 255, 194, 14)
			outputChatBox("Sells the Vehicle you're in to that Player.", thePlayer, 255, 194, 14)
			outputChatBox("Ask the buyer to use /pay to recieve the money for the vehicle.", thePlayer, 255, 194, 14)
		elseif ( vehType == ("Plane" or "Helicopter" or "Boat") or (getElementData(thePlayer, "temporarySell") == true ) or (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) ) and args then
			triggerEvent("sellVehicle", getResourceRootElement(), thePlayer, "sell", args)
		end
	end
end
addCommandHandler("sell", AdminVehicleSale)



function lockUnlockInside(vehicle)
	local model = getElementModel(vehicle)
	local owner = getElementData(vehicle, "owner")
	local dbid = getElementData(vehicle, "dbid")
	local bikes = {[581] = true, [509] = true, [481] = true, [462] = true, [521] = true, [463] = true, [510] = true, [522] = true, [461] = true, [448] = true, [468] = true, [586] = true}

	--if (owner ~= -1) then
		if ( getElementData(vehicle, "Impounded") or 0 ) == 0 then
			if not locklessVehicle[model] or exports.global:hasItem( source, 3, dbid ) then
				if (getElementData(source, "realinvehicle") == 1) and not bikes[model] then
					local locked = isVehicleLocked(vehicle)
					local seat = getPedOccupiedVehicleSeat(source)
					if seat == 0 or seat == 1 or exports.global:hasItem( source, 3, dbid ) then
						playCarToglockSoundFxInside(vehicle, not locked)
						if (locked) then
							setVehicleLocked(vehicle, false)
							triggerEvent('sendAme', source, "unlocks the vehicle doors.")
							exports.logs:dbLog(source, 31, {  vehicle }, "UNLOCK FROM INSIDE")
						else
							setVehicleLocked(vehicle, true)
							local doors = getDoorsFor(getElementModel(vehicle), -1)
							for index, doorEntry in ipairs(doors) do
								setVehicleDoorOpenRatio(vehicle, doorEntry[2], 0, 0.5)
							end
							triggerEvent('sendAme', source, "locks the vehicle doors.")
							exports.logs:dbLog(source, 31, {  vehicle }, "LOCK FROM INSIDE")
						end
					end
				end
			end
		else
			outputChatBox("(( You can't lock impounded vehicles. ))", source, 255, 195, 14)
		end
	--else
		--outputChatBox("(( You can't lock civilian vehicles. ))", source, 255, 195, 14)
	--end

end
addEvent("lockUnlockInsideVehicle", true)
addEventHandler("lockUnlockInsideVehicle", getRootElement(), lockUnlockInside)


local storeTimers = { }

function lockUnlockOutside(vehicle)
	if (not source or exports.integration:isPlayerTrialAdmin(source)) or ( getElementData(vehicle, "Impounded") or 0 ) == 0 then
		local dbid = getElementData(vehicle, "dbid")
		blinkLightsAndSoundOnLockUnlock(vehicle) -- maxime
		--exports.global:applyAnimation(source, "GHANDS", "gsign3LH", 2000, false, false, false)

		if (isVehicleLocked(vehicle)) then
			setVehicleLocked(vehicle, false)
			triggerEvent('sendAme', source, "presses on the key to unlock the vehicle. ((" .. getVehicleName(vehicle) .. "))")
			exports.logs:dbLog(source, 31, {  vehicle }, "UNLOCK FROM OUTSIDE")
		else
			setVehicleLocked(vehicle, true)
			triggerEvent('sendAme', source, "presses on the key to lock the vehicle. ((" .. getVehicleName(vehicle) .. "))")
			local doors = getDoorsFor(getElementModel(vehicle), -1)
			for index, doorEntry in ipairs(doors) do
				setVehicleDoorOpenRatio(vehicle, doorEntry[2], 0, 0.5)
			end
			exports.logs:dbLog(source, 31, {  vehicle }, "LOCK FROM OUTSIDE")
		end

		if (storeTimers[vehicle] == nil) or not (isTimer(storeTimers[vehicle])) then
			storeTimers[vehicle] = setTimer(storeVehicleLockState, 180000, 1, vehicle, dbid)
		end
	end
end
addEvent("lockUnlockOutsideVehicle", true)
addEventHandler("lockUnlockOutsideVehicle", getRootElement(), lockUnlockOutside)

function storeVehicleLockState(vehicle, dbid)
	if (isElement(vehicle)) then
		local newdbid = getElementData(vehicle, "dbid")
		if tonumber(newdbid) > 0 then
			local locked = isVehicleLocked(vehicle)

			local state = 0
			if (locked) then
				state = 1
			end

			local query = mysql:query_free("UPDATE vehicles SET locked='" .. mysql:escape_string(tostring(state)) .. "' WHERE id='" .. mysql:escape_string(tostring(newdbid)) .. "' LIMIT 1")
		end
		storeTimers[vehicle] = nil
	end
end

function fillFuelTank(veh)
	local currFuel = getElementData(veh, "fuel")
	local engine = getElementData(veh, "engine")
	local max = exports.vehicle_fuel:getMaxFuel(getElementModel(veh))
	local hasItem, itemSlot, fuel, itemUniqueID = exports.global:hasItem(source, 57)
	if (math.ceil(currFuel)==max) then
		outputChatBox("This vehicle is already full.", source)
	elseif (fuel==0) then
		outputChatBox("This fuel can is empty.", source, 255, 0, 0)
	elseif (engine==1) then
		outputChatBox("You can not fuel running vehicles. Please stop the engine first.", source, 255, 0, 0)
	else
		local fuelAdded = fuel

		if (fuelAdded+currFuel>max) then
			fuelAdded = max - currFuel
		end

		if not (exports['item-system']:updateItemValue(source, itemSlot, math.floor(fuel - fuelAdded))) then
			outputChatBox("Something went wrong, please /report.", source)
			return
		end

		outputChatBox("You added " .. math.floor(fuelAdded) .. " litres of petrol to your car from your fuel can.", source, 0, 255, 0 )

		local gender = getElementData(source, "gender")
		local genderm = "his"
		if (gender == 1) then
			genderm = "her"
		end
		triggerEvent('sendAme', source, "fills up " .. genderm .. " vehicle from a small petrol canister.")

		exports.anticheat:setEld( veh, "fuel", currFuel+fuelAdded )
		triggerClientEvent(source, "syncFuel", veh, getElementData( veh, 'fuel' ), getElementData( veh, 'battery' ) or 100 )
	end
end
addEvent("fillFuelTankVehicle", true)
addEventHandler("fillFuelTankVehicle", getRootElement(), fillFuelTank)

function getYearDay(thePlayer)
	local time = getRealTime()
	local currYearday = time.yearday

	outputChatBox("Year day is " .. currYearday, thePlayer)
end
addCommandHandler("yearday", getYearDay)

function removeNOS(theVehicle)
	removeVehicleUpgrade(theVehicle, getVehicleUpgradeOnSlot(theVehicle, 8))
	triggerEvent('sendAme', source, "removes NOS from the " .. getVehicleName(theVehicle) .. ".")
	exports.vehicle:saveVehicleMods(theVehicle)
	exports.logs:dbLog(source, 6, {  theVehicle }, "MODDING REMOVENOS")
end
addEvent("removeNOS", true)
addEventHandler("removeNOS", getRootElement(), removeNOS)

-- /VEHPOS /PARK
local destroyTimers = { }
--[[
function createShopVehicle(dbid, ...)
	local veh = createVehicle(unpack({...}))
	exports.pool:allocateElement(veh, dbid)

	exports.anticheat:changeProtectedElementDataEx(veh, "dbid", dbid)
	exports.anticheat:changeProtectedElementDataEx(veh, "requires.vehpos", 1, false)
	local timer = setTimer(checkVehpos, 3600000, 1, veh, dbid)
	table.insert(destroyTimers, {timer, dbid})

	exports['vehicle-interiors']:add( veh )

	return veh
end
]]

function checkVehpos(veh, dbid)
	local requires = getElementData(veh, "requires.vehpos")

	if (requires) then
		if (requires==1) then
			local id = tonumber(getElementData(veh, "dbid"))

			if (id==dbid) then
				destroyElement(veh)
				local query = mysql:query_free("DELETE FROM vehicles WHERE id='" .. mysql:escape_string(id) .. "' LIMIT 1")

				call( getResourceFromName( "item-system" ), "clearItems", veh )
				call( getResourceFromName( "item-system" ), "deleteAll", 3, id )
			end
		end
	end
end

-- VEHPOS
local PershingSquareCol = createColRectangle( 1420, -1775, 130, 257 )
local HospitalCol = createColRectangle( 1166, -1384, 52, 92 )

local function canParkHere( thePlayer, veh )
	if call( getResourceFromName("tow-system"), "cannotVehpos", thePlayer, veh ) and not exports.integration:isPlayerTrialAdmin(thePlayer, true) and not exports.integration:isPlayerSupporter(thePlayer, true) then
		return not outputChatBox("It is not possible to park your vehicle here.", thePlayer, 255, 0, 0)
	elseif isElementWithinColShape( thePlayer, HospitalCol ) and not exports.factions:isPlayerInFaction(thePlayer, 2) and not exports.integration:isPlayerTrialAdmin(thePlayer, true) and not exports.integration:isPlayerSupporter(thePlayer, true) then
		return not outputChatBox("Only Los Santos Emergency Service is allowed to park their vehicles in front of the Hospital.", thePlayer, 255, 0, 0)
	elseif isElementWithinColShape( thePlayer, PershingSquareCol ) and not exports.factions:isPlayerInFaction(thePlayer, 1) and not exports.integration:isPlayerTrialAdmin(thePlayer, true) and not exports.integration:isPlayerSupporter(thePlayer, true) then
		return not outputChatBox("Only Los Santos Police Department is allowed to park their vehicles on Pershing Square.", thePlayer, 255, 0, 0)
	end
	return true
end

local function parkVeh( thePlayer, veh, commandName )
	if canParkHere( thePlayer, veh ) then
		local playerid = getElementData(thePlayer, "dbid")
		local owner = getElementData(veh, "owner")
		local dbid = getElementData(veh, "dbid")
		local carfid = getElementData(veh, "faction")
		local x, y, z = getElementPosition(veh)
		local TowingReturn = call(getResourceFromName("tow-system"), "CanTowTruckDriverVehPos", thePlayer) -- 2 == in towing and in col shape, 1 == colshape only, 0 == not in col shape
		if (owner==playerid and TowingReturn == 0) or exports.global:hasItem(thePlayer, 3, dbid) or TowingReturn == 2 or exports.integration:isPlayerSupporter(thePlayer, true) or exports.integration:isPlayerTrialAdmin(thePlayer, true)  then
			if (dbid<0) then
				outputChatBox("This vehicle is not permanently spawned.", thePlayer, 255, 0, 0)
			else
				if (call(getResourceFromName("tow-system"), "CanTowTruckDriverGetPaid", thePlayer)) then
					-- pd has to pay for this impound
					exports.global:giveMoney(exports.pool:getElement("team", 4), 75)
					exports.global:takeMoney(exports.pool:getElement("team", 4), 75)
				end
				exports.anticheat:changeProtectedElementDataEx(veh, "requires.vehpos")
				local rx, ry, rz = getVehicleRotation(veh)

				local interior = getElementInterior(thePlayer)
				local dimension = getElementDimension(thePlayer)

				dbExec( exports.mysql:getConn('mta'), "UPDATE vehicles SET x=?, y=?, z=?, rotx=?, roty=?, rotz=?, currx=?, curry=?, currz=?, currrx=?, currry=?, currrz=?, interior=?, currinterior=?, dimension=?, currdimension=? WHERE id=?", x, y, z, rx, ry, rz, x, y, z, rx, ry, rz, interior, interior, dimension, dimension, dbid )
				setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
				exports.anticheat:changeProtectedElementDataEx(veh, "respawnposition", {x, y, z, rx, ry, rz}, false)
				exports.anticheat:changeProtectedElementDataEx(veh, "interior", interior)
				exports.anticheat:changeProtectedElementDataEx(veh, "dimension", dimension)
				outputChatBox("Vehicle spawn position set.", thePlayer)
				-- logs
				exports.logs:dbLog(thePlayer, 6, {  veh }, "PARK")
				exports.vehicle_manager:addVehicleLogs( dbid , commandName, thePlayer )

				for key, value in ipairs(destroyTimers) do
					if (tonumber(destroyTimers[key][2]) == dbid) then
						local timer = destroyTimers[key][1]
						if (isTimer(timer)) then
							killTimer(timer)
							table.remove(destroyTimers, key)
						end
					end
				end

				if ( getElementData(veh, "Impounded") or 0 ) > 0 then
					local owner = getPlayerFromName( exports['cache']:getCharacterName( getElementData( veh, "owner" ) ) )
					if isElement( owner ) and exports.global:hasItem( owner, 2 ) then
						outputChatBox("((SFT&R)) #5555 [SMS]: Your " .. getVehicleName(veh) .. " has been impounded. Head over to the impound to release it.", owner, 120, 255, 80)
					end
				end
			end
		end
	end
end

function setVehiclePosition(thePlayer, commandName)
	local veh = getPedOccupiedVehicle(thePlayer)
	if not veh or getElementData(thePlayer, "realinvehicle") == 0 then
		outputChatBox("You are not in a vehicle.", thePlayer, 255, 0, 0)
	else
		parkVeh( thePlayer, veh, commandName )
	end
end
addCommandHandler("vehpos", setVehiclePosition, false, false)
addCommandHandler("park", setVehiclePosition, false, false)

function autoSetVehiclePosition(thePlayer, seat, jacked)
	if thePlayer and seat == 0 then
		if getElementData(thePlayer, "autopark") == "1" then
			parkVeh( thePlayer, source, 'autopark' )
		end
	end
end
addEventHandler("onVehicleExit", getRootElement(), autoSetVehiclePosition)

function toggleAutoPark(thePlayer, commandName)
	--[[local autoPark = getElementData(thePlayer, "autopark")
	local autoParkString
	if autoPark == 1 then
		autoPark = 0
		autoParkString = "Auto park disabled."
	else
		autoPark = 1
		autoParkString = "Auto park enabled."
	end
	local dbid = getElementData(thePlayer, "account:id")
	local query = mysql:query_free("UPDATE accounts SET autopark='".. mysql:escape_string(autoPark) .."' WHERE id = '" .. dbid .. "'")
	if query then
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "autopark", autoPark)
		outputChatBox(autoParkString, thePlayer, 0, 255, 0)
	else
		outputChatBox("MYSQL-ERROR-6969, Please report on the mantis.", thePlayer, 255, 0, 0)
	end
	]]
end
addCommandHandler("toggleautopark", toggleAutoPark, false, false)

function setVehiclePosition2(thePlayer, commandName, vehicleID)
	if exports.integration:isPlayerTrialAdmin( thePlayer ) then
		local vehicleID = tonumber(vehicleID)
		if not vehicleID or vehicleID < 0 then
			outputChatBox( "SYNTAX: /" .. commandName .. " [vehicle id]", thePlayer, 255, 194, 14 )
		else
			local veh = exports.pool:getElement("vehicle", vehicleID)
			if veh then
				exports.anticheat:changeProtectedElementDataEx(veh, "requires.vehpos")
				local x, y, z = getElementPosition(veh)
				local rx, ry, rz = getVehicleRotation(veh)

				local interior = getElementInterior(thePlayer)
				local dimension = getElementDimension(thePlayer)

				local query = mysql:query_free("UPDATE vehicles SET x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .."', z='" .. mysql:escape_string(z) .. "', rotx='" .. mysql:escape_string(rx) .. "', roty='" .. mysql:escape_string(ry) .. "', rotz='" .. mysql:escape_string(rz) .. "', currx='" .. mysql:escape_string(x) .. "', curry='" .. mysql:escape_string(y) .. "', currz='" .. mysql:escape_string(z) .. "', currrx='" .. mysql:escape_string(rx) .. "', currry='" .. mysql:escape_string(ry) .. "', currrz='" .. mysql:escape_string(rz) .. "', interior='" .. mysql:escape_string(interior) .. "', currinterior='" .. mysql:escape_string(interior) .. "', dimension='" .. mysql:escape_string(dimension) .. "', currdimension='" .. mysql:escape_string(dimension) .. "' WHERE id='" .. mysql:escape_string(vehicleID) .. "'")
				setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
				exports.anticheat:changeProtectedElementDataEx(veh, "respawnposition", {x, y, z, rx, ry, rz}, false)
				exports.anticheat:changeProtectedElementDataEx(veh, "interior", interior)
				exports.anticheat:changeProtectedElementDataEx(veh, "dimension", dimension)
				outputChatBox("Vehicle spawn position for #" .. vehicleID .. " set.", thePlayer)
				exports.logs:dbLog(thePlayer, 6, {  veh }, "PARK")
				for key, value in ipairs(destroyTimers) do
					if (tonumber(destroyTimers[key][2]) == vehicleID) then
						local timer = destroyTimers[key][1]

						if (isTimer(timer)) then
							killTimer(timer)
							table.remove(destroyTimers, key)
						end
					end
				end

				if ( getElementData(veh, "Impounded") or 0 ) > 0 then
					local owner = getPlayerFromName( exports['cache']:getCharacterName( getElementData( veh, "owner" ) ) )
					if isElement( owner ) and exports.global:hasItem( owner, 2 ) then
						outputChatBox("((SFT&R)) #5555 [SMS]: Your " .. getVehicleName(veh) .. " has been impounded. Head over to the impound to release it.", owner, 120, 255, 80)
					end
				end
			else
				outputChatBox("Vehicle not found.", thePlayer, 255, 0, 0 )
			end
		end
	end
end
addCommandHandler("avehpos", setVehiclePosition2, false, false)
addCommandHandler("apark", setVehiclePosition2, false, false)

function setVehiclePosition3(veh)
	if call( getResourceFromName("tow-system"), "cannotVehpos", source ) then
		outputChatBox("Only Los Santos Towing & Recovery is allowed to park their vehicles on the Impound Lot.", source, 255, 0, 0)
	elseif isElementWithinColShape( source, HospitalCol ) and not exports.factions:isPlayerInFaction(source, 2) and not exports.integration:isPlayerTrialAdmin(source) then
		outputChatBox("Only Los Santos Emergency Service is allowed to park their vehicles in front of the Hospital.", source, 255, 0, 0)
	elseif isElementWithinColShape( source, PershingSquareCol ) and not exports.factions:isPlayerInFaction(source, 1) and not exports.integration:isPlayerTrialAdmin(source) then
		outputChatBox("Only Los Santos Police Department is allowed to park their vehicles on Pershing Square.", source, 255, 0, 0)
	else
		local playerid = getElementData(source, "dbid")
		local owner = getElementData(veh, "owner")
		local dbid = getElementData(veh, "dbid")
		local x, y, z = getElementPosition(veh)
		local TowingReturn = call(getResourceFromName("tow-system"), "CanTowTruckDriverVehPos", source) -- 2 == in towing and in col shape, 1 == colshape only, 0 == not in col shape
		if (owner==playerid and TowingReturn == 0) or (exports.global:hasItem(source, 3, dbid)) or (TowingReturn == 2) or (exports.integration:isPlayerTrialAdmin(source)) then
			if (dbid<0) then
				outputChatBox("This vehicle is not permanently spawned.", source, 255, 0, 0)
			else
				if (call(getResourceFromName("tow-system"), "CanTowTruckDriverGetPaid", source)) then
					-- pd has to pay for this impound
					exports.global:giveMoney(getTeamFromName("326 Enterprises"), 75)
					exports.global:takeMoney(getTeamFromName("Los Santos Police Department"), 75)
				end
				exports.anticheat:changeProtectedElementDataEx(veh, "requires.vehpos")
				local rx, ry, rz = getVehicleRotation(veh)

				local interior = getElementInterior(source)
				local dimension = getElementDimension(source)

				local query = mysql:query_free("UPDATE vehicles SET x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .."', z='" .. mysql:escape_string(z) .. "', rotx='" .. mysql:escape_string(rx) .. "', roty='" .. mysql:escape_string(ry) .. "', rotz='" .. mysql:escape_string(rz) .. "', currx='" .. mysql:escape_string(x) .. "', curry='" .. mysql:escape_string(y) .. "', currz='" .. mysql:escape_string(z) .. "', currrx='" .. mysql:escape_string(rx) .. "', currry='" .. mysql:escape_string(ry) .. "', currrz='" .. mysql:escape_string(rz) .. "', interior='" .. mysql:escape_string(interior) .. "', currinterior='" .. mysql:escape_string(interior) .. "', dimension='" .. mysql:escape_string(dimension) .. "', currdimension='" .. mysql:escape_string(dimension) .. "' WHERE id='" .. mysql:escape_string(dbid) .. "'")
				setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
				exports.anticheat:changeProtectedElementDataEx(veh, "respawnposition", {x, y, z, rx, ry, rz}, false)
				exports.anticheat:changeProtectedElementDataEx(veh, "interior", interior)
				exports.anticheat:changeProtectedElementDataEx(veh, "dimension", dimension)
				outputChatBox("Vehicle spawn position set.", source)
				exports.logs:dbLog(thePlayer, 6, {  veh }, "PARK")
				for key, value in ipairs(destroyTimers) do
					if (tonumber(destroyTimers[key][2]) == dbid) then
						local timer = destroyTimers[key][1]

						if (isTimer(timer)) then
							killTimer(timer)
							table.remove(destroyTimers, key)
						end
					end
				end

				if ( getElementData(veh, "Impounded") or 0 ) > 0 then
					local owner = getPlayerFromName( exports['cache']:getCharacterName( getElementData( veh, "owner" ) ) )
					if isElement( owner ) and exports.global:hasItem( owner, 2 ) then
						outputChatBox("((SFT&R)) #5555 [SMS]: Your " .. getVehicleName(veh) .. " has been impounded. Head over to the impound to release it.", owner, 120, 255, 80)
					end
				end
			end
		else
			outputChatBox( "You can't park this vehicle.", source, 255, 0, 0 )
		end
	end
end
addEvent( "parkVehicle", true )
addEventHandler( "parkVehicle", getRootElement( ), setVehiclePosition3 )

function setVehiclePosition4(thePlayer, commandName, vehicle)
	local veh
	if not commandName and vehicle then
		if isElement(vehicle) and getElementType(vehicle) == "vehicle" then
			veh = vehicle
		else
			return
		end
	end
	if not veh then veh = getPedOccupiedVehicle(thePlayer) end
	if not veh or commandName and not vehicle and getElementData(thePlayer, "realinvehicle") == 0 then
		outputChatBox("You are not in a vehicle.", thePlayer, 255, 0, 0)
	else
		local playerid = getElementData(thePlayer, "dbid")
		local owner = getElementData(veh, "owner")
		local dbid = getElementData(veh, "dbid")
		local carfid = getElementData(veh, "faction")
		local f, _ = exports.factions:isPlayerInFaction(thePlayer, carfid)
		local leader = exports.factions:hasMemberPermissionTo(thePlayer, carfid, "respawn_vehs")
		if (leader) and (f) then
			exports.anticheat:changeProtectedElementDataEx(veh, "requires.vehpos")

			local x, y, z = getElementPosition(veh)
			local rx, ry, rz = getVehicleRotation(veh)

			local interior = getElementInterior(thePlayer)
			local dimension = getElementDimension(thePlayer)

			local query = mysql:query_free("UPDATE vehicles SET x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .."', z='" .. mysql:escape_string(z) .. "', rotx='" .. mysql:escape_string(rx) .. "', roty='" .. mysql:escape_string(ry) .. "', rotz='" .. mysql:escape_string(rz) .. "', currx='" .. mysql:escape_string(x) .. "', curry='" .. mysql:escape_string(y) .. "', currz='" .. mysql:escape_string(z) .. "', currrx='" .. mysql:escape_string(rx) .. "', currry='" .. mysql:escape_string(ry) .. "', currrz='" .. mysql:escape_string(rz) .. "', interior='" .. mysql:escape_string(interior) .. "', currinterior='" .. mysql:escape_string(interior) .. "', dimension='" .. mysql:escape_string(dimension) .. "', currdimension='" .. mysql:escape_string(dimension) .. "' WHERE id='" .. mysql:escape_string(dbid) .. "'")
			setVehicleRespawnPosition(veh, x, y, z, rx, ry, rz)
			exports.anticheat:changeProtectedElementDataEx(veh, "respawnposition", {x, y, z, rx, ry, rz}, false)
			exports.anticheat:changeProtectedElementDataEx(veh, "interior", interior)
			exports.anticheat:changeProtectedElementDataEx(veh, "dimension", dimension)
			outputChatBox("Vehicle spawn position for #" .. dbid .. " set.", thePlayer)
			exports.logs:dbLog(thePlayer, 6, {  veh }, "PARK")

			local adminID = getElementData(thePlayer, "account:id")
			if not commandName then commandName = "fpark" end
			local addLog = mysql:query_free("INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES ('"..tostring(dbid).."', '"..commandName.."', '"..adminID.."')") or false
			if not addLog then
				outputDebugString("Failed to add vehicle logs.")
			end

			for key, value in ipairs(destroyTimers) do
				if (tonumber(destroyTimers[key][2]) == dbid) then
					local timer = destroyTimers[key][1]

					if (isTimer(timer)) then
						killTimer(timer)
						table.remove(destroyTimers, key)
					end
				end
			end

			if ( getElementData(veh, "Impounded") or 0 ) > 0 then
				local owner = getPlayerFromName( exports['cache']:getCharacterName( getElementData( veh, "owner" ) ) )
				if isElement( owner ) and exports.global:hasItem( owner, 2 ) then
					outputChatBox("((SFT&R)) #5555 [SMS]: Your " .. getVehicleName(veh) .. " has been impounded. Head over to the impound to release it.", owner, 120, 255, 80)
				end
			end
		end
	end
end
addCommandHandler("fvehpos", setVehiclePosition4, false, false)
addCommandHandler("fpark", setVehiclePosition4, false, false)
addEvent( "fparkVehicle", true )
addEventHandler( "fparkVehicle", getRootElement( ), setVehiclePosition4 )

function quitPlayer ( quitReason )
	if (quitReason ~= "Quit") then -- if timed out
		if (isPedInVehicle(source)) then -- if in vehicle
			local vehicleSeat = getPedOccupiedVehicleSeat(source)
			if (vehicleSeat == 0) then	-- is in driver seat?
				local theVehicle = getPedOccupiedVehicle(source)
				local dbid = tonumber(getElementData(theVehicle, "dbid"))
				local passenger1 = getVehicleOccupant( theVehicle , 1 )
				local passenger2 = getVehicleOccupant( theVehicle , 2 )
				local passenger3 = getVehicleOccupant( theVehicle , 3 )
				if not (passenger1) and not (passenger2) and not (passenger3) then
					local vehicleFaction = tonumber(getElementData(theVehicle, "faction"))
					if exports.global:hasItem(source, 3, dbid) or exports.global:hasItem(theVehicle, 3, dbid) or ((exports.factions:isPlayerInFaction(source, vehicleFaction) and (vehicleFaction ~= -1))) then
						if not isVehicleLocked(theVehicle) then -- check if the vehicle aint locked already
							lockUnlockOutside(theVehicle)
							exports.logs:dbLog(thePlayer, 31, {  theVehicle }, "LOCK FROM CRASH")
						end
						local engine = getElementData(theVehicle, "engine")
						if engine == 1 then -- stop the engine when its running
							setVehicleEngineState(theVehicle, false)
							exports.anticheat:changeProtectedElementDataEx(theVehicle, "engine", 0, false)

							if exports.global:hasItem(theVehicle, 3, dbid) and exports.global:hasSpaceForItem(source, 3, dbid) then
								exports.global:takeItem(theVehicle, 3, dbid)
								exports.global:giveItem(source, 3, dbid)
							end
						end
					end
					exports.anticheat:changeProtectedElementDataEx(theVehicle, "handbrake", 1, false)
					setElementVelocity(theVehicle, 0, 0, 0)
					setElementFrozen(theVehicle, true)
				end
			end
		end
	end
end
addEventHandler("onPlayerQuit",getRootElement(), quitPlayer)

function detachVehicle(thePlayer)
	if isPedInVehicle(thePlayer) and getPedOccupiedVehicleSeat(thePlayer) == 0 then
		local veh = getPedOccupiedVehicle(thePlayer)
		if getVehicleTowedByVehicle(veh) then
			detachTrailerFromVehicle(veh)
			outputChatBox("The trailer was detached.", thePlayer, 0, 255, 0)
		else
			outputChatBox("There is no trailer...", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("detach", detachVehicle)

safeTable = {}

function addSafe( dbid, x, y, z, rz, interior )
	local tempobject = createObject(2332, x, y, z, 0, 0, rz)
	setElementInterior(tempobject, interior)
	setElementDimension(tempobject, dbid + 20000)
	safeTable[dbid] = tempobject
end

function removeSafe( dbid )
	if safeTable[dbid] then
		destroyElement(safeTable[dbid])
		safeTable[dbid] = nil
	end
end

function getSafe( dbid )
	return safeTable[dbid]
end


function bindKeysOnJoin()
	bindKey(source, "l", "down", "lights")
	bindKey(source, "k", "down", toggleLock)
end
addEventHandler("onResourceStart", getResourceRootElement(), bindKeys)
addEventHandler("onPlayerJoin", getRootElement(), bindKeysOnJoin)

function manualRealinvehicle(element, status)
	if isElement(element) and getElementType(element) == 'player' and tonumber(status) then
		exports.anticheat:setEld( element, "realinvehicle", tonumber(status))
	end
end
addEvent("vehicle:realinvehicle", true)
addEventHandler("vehicle:realinvehicle", resourceRoot, manualRealinvehicle)