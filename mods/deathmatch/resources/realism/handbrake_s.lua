local handbrakeTimer = {}
local someExceptions = {
	[573] = true,
	[556] = true,
	[444] = true, --Monster Truck
}
function toggleHandbrake( player, vehicle, forceOnGround, commandName )
	local handbrake = getElementData(vehicle, "handbrake")
	local kickstand = false
	if commandName == nil then
		kickstand = getVehicleType(vehicle) == 'BMX' or getVehicleType(vehicle) == 'Bike'
	else
		kickstand = commandName == 'kickstand'
	end
	--outputDebugString(tostring(kickstand) .. " " .. tostring(commandName) .. " " .. tostring(forceOnGround))
	if (handbrake == 0) then
		if getVehicleType(vehicle) == 'BMX' or getVehicleType(vehicle) == 'Bike' then
			if not kickstand then
				outputChatBox('This vehicle has no handbrake.', player, 255, 0, 0)
			elseif not isVehicleOnGround(vehicle) and not forceOnGround then
				outputChatBox('You need to be on the ground for this to work.', player, 255, 0, 0)
			elseif math.floor(exports.global:getVehicleVelocity(vehicle)) > 2 then
				outputChatBox("This doesn't work while driving...", player, 255, 0, 0)
			else
				exports.anticheat:changeProtectedElementDataEx(vehicle, "handbrake", 1, true)
				setElementFrozen(vehicle, true)
			end
		elseif (isVehicleOnGround(vehicle) or forceOnGround) or getVehicleType(vehicle) == "Boat" or getVehicleType(vehicle) == "Helicopter" or someExceptions[getElementModel(vehicle)] then
			if kickstand then
				outputChatBox('This vehicle has no kickstand.', player, 255, 0, 0)
				return false
			end
			setControlState ( player, "handbrake", true )
			exports.anticheat:changeProtectedElementDataEx(vehicle, "handbrake", 1, true)
			handbrakeTimer[vehicle] = setTimer(function ()
				setElementFrozen(vehicle, true)
				--outputChatBox("Handbrake has been applied.", player, 0, 255, 0)
				setControlState ( player, "handbrake", false )
			end, 3000, 1)
			playSoundHandbrake(vehicle, "on")
		end
	else
		if getVehicleType(vehicle) == 'BMX' or getVehicleType(vehicle) == 'Bike' then
			if not kickstand then
				outputChatBox('This vehicle has no handbrake.', player, 255, 0, 0)
				return
			end
		else
			if kickstand then
				outputChatBox('This vehicle has no kickstand.', player, 255, 0, 0)
				return
			end
		end

		if isTimer(handbrakeTimer[vehicle]) then
			killTimer(handbrakeTimer[vehicle])
			setControlState ( player, "handbrake", false )
		end
		exports.anticheat:changeProtectedElementDataEx(vehicle, "handbrake", 0, true)
		setElementFrozen(vehicle, false) 
		--outputChatBox("Handbrake has been released.", player, 0, 255, 0)
		triggerEvent("vehicle:handbrake:lifted", vehicle, player)
		playSoundHandbrake(vehicle, "off")
	end	
end

addEvent("vehicle:handbrake:lifted", true)

addEvent("vehicle:handbrake", true)
addEventHandler( "vehicle:handbrake", root, function(forceOnGround, commandName) toggleHandbrake( client, source, forceOnGround, commandName ) end )


function playSoundHandbrake(veh, state)
	local maxSeats = getVehicleMaxPassengers( veh )
	if maxSeats and tonumber(maxSeats) and tonumber(maxSeats) > 0 then
		for i = 0, maxSeats do
			local player = getVehicleOccupant( veh, i )
			if player then
				triggerClientEvent(player, "playSoundHandbrake", player, state)
			end
		end
	end
end
