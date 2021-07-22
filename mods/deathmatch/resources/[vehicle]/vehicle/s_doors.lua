function controlVehicleDoor(door, position)

	if not (isElement(source)) then
		return
	end
	
	if (isVehicleLocked(source)) then
		return
	end
	
	vehicle1x, vehicle1y, vehicle1z = getElementPosition ( source )
	player1x, player1y, player1z = getElementPosition ( client )
	if not (getPedOccupiedVehicle ( client ) == source) and not (getDistanceBetweenPoints2D ( vehicle1x, vehicle1y, player1x, player1y ) < 5) then
		return
	end
	
	local ratio = position/100
	if position == 0 then
		ratio = 0
	elseif position == 100 then
		ratio = 1
	end
	setVehicleDoorOpenRatio(source, door, ratio, 0.5)
end		
addEvent("vehicle:control:doors", true)
addEventHandler("vehicle:control:doors", getRootElement(), controlVehicleDoor)

function controlRamp(theVehicle)
	local playerVehicle = getPedOccupiedVehicle(client)
	
	if not (isElement(theVehicle) and theVehicle == playerVehicle) then
		outputChatBox("You need to be in the vehicle to use this button.", client, 255, 0, 0)
		return
	end
	
	if not (exports['item-system']:hasItem(theVehicle, 117)) then
		outputChatBox("You need the item in the cars inventory before you can do this!", client, 255, 0, 0)
		return
	end

	if not (getElementData(theVehicle, "handbrake") == 1) then
		outputChatBox("You need to handbrake the vehicle before you can deploy the ramp!", client, 255, 0, 0)
		return
	end
	
	if not (getElementModel(theVehicle) == 578) then
		outputChatBox("This vehicle is not compatible with this type of ramp!", client, 255, 0, 0)
		return
	end
	
	local rampObject = getElementData(theVehicle, "vehicle:ramp:object")
	if not (rampObject) or not (isElement(rampObject)) then
		if (getElementModel(theVehicle) == 578) then
			local vehiclePositionX, vehiclePositionY, vehiclePositionZ = getElementPosition(theVehicle)
			local vehicleRotationX, vehicleRotationY, vehicleRotationZ = getElementRotation(theVehicle)
		
			rampObject = createObject(16644, vehiclePositionX +0.37, vehiclePositionY -15.41, vehiclePositionZ -2.05, vehicleRotationX +180, vehicleRotationY +10, vehicleRotationZ + 90) 
			--attachElements( rampObject, theVehicle, 0.37, -15.45, -2.05, 180, 10, 90)
			attachElements( rampObject, theVehicle, 0.37, -15.4, -2.05, 180, 10, 90)
			setElementPosition(theVehicle, getElementPosition(theVehicle))
			exports.anticheat:changeProtectedElementDataEx(theVehicle, "vehicle:ramp:object", rampObject, false)
		end
	else
		destroyElement(rampObject)
		exports.anticheat:changeProtectedElementDataEx(theVehicle, "vehicle:ramp:object", nil, false)
	end
end
addEvent("vehicle:control:ramp", true)
addEventHandler("vehicle:control:ramp", getRootElement(), controlRamp)
--[[	OLD RAMP MODEL REMOVED BY ANTHONY, ADDED NEW ONE SENT FROM MAT.T
	if not (getElementModel(theVehicle) == 578) then
		outputChatBox("This vehicle is not compatible with this type of ramp!", client, 255, 0, 0)
		return
	end
	
	local rampObject = getElementData(theVehicle, "vehicle:ramp:object")
	if not (rampObject) or not (isElement(rampObject)) then
		if (getElementModel(theVehicle) == 578) then
			local vehiclePositionX, vehiclePositionY, vehiclePositionZ = getElementPosition(theVehicle)
			local vehicleRotationX, vehicleRotationY, vehicleRotationZ = getElementRotation(theVehicle)
		
			rampObject = createObject(5152, vehiclePositionX + 0.1, vehiclePositionY - 7.65, vehiclePositionZ  - 1.3, vehicleRotationX, vehicleRotationY, vehicleRotationZ + 90) 
			attachElements( rampObject, theVehicle, 0.1, -7.65, -1.3, 0, 0, 90) 
			setElementPosition(theVehicle, getElementPosition(theVehicle))
			exports.anticheat:changeProtectedElementDataEx(theVehicle, "vehicle:ramp:object", rampObject, false)
		end
	else
		destroyElement(rampObject)
		exports.anticheat:changeProtectedElementDataEx(theVehicle, "vehicle:ramp:object", nil, false)
	end
end
addEvent("vehicle:control:ramp", true)
addEventHandler("vehicle:control:ramp", getRootElement(), controlRamp)]]

function checkRamp(sourcePlayer)
	local theVehicle = source
	if not (isElement(theVehicle)) then
		return
	end
	
	local rampObject = getElementData(theVehicle, "vehicle:ramp:object")
	if rampObject then
		destroyElement(rampObject)
		exports.anticheat:changeProtectedElementDataEx(theVehicle, "vehicle:ramp:object", nil, false)
	end
end
addEventHandler("vehicle:handbrake:lifted", getRootElement(), checkRamp)
