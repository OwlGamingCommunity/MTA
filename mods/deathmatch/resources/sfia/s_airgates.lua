local LSIAfactionID = 47

addEventHandler("onResourceStart", getResourceRootElement(),
	function()
		for k, v in ipairs(gates) do
			local shape = createColSphere(v[4][1],v[4][2],v[4][3], v[4][4])
			setElementData(shape, "airport.gate.id", k)
			shapes[k] = shape
			local object = createObject(962, v[5][1], v[5][2], v[5][3])
			setElementRotation(object, v[5][4], v[5][5], v[5][6])
			setElementData(object, "airport.gate.controlbox", true)
			setElementData(object, "airport.gate.id", k)
			local pickup = createPickup(v[6][1], v[6][2], v[6][3], 3, 1318)
			setElementInterior(pickup, v[6][4])
			setElementDimension(pickup, v[6][5])
			setElementData(pickup, "airport.gate.id", k)
			addEventHandler("onPickupHit", pickup, hitGateInside)
			addEventHandler("onPickupLeave", pickup, leaveGate)
			if v[8] then
				createGateOutsidePickup(k)
			end
		end
		for k, v in ipairs(fuelSpots) do
			--local shape = createColSphere(v[1][1],v[1][2],v[1][3], v[1][4])
			--fuelShapes[k] = shape
			local object = createObject(v[2][1], v[2][2], v[2][3], v[2][4])
			setElementRotation(object, v[2][5], v[2][6], v[2][7])
			setElementData(object, "airport.fuel", true)
		end
	end
)

function createGateOutsidePickup(gateID)
	local pickup = createPickup(gates[gateID][7][1], gates[gateID][7][2], gates[gateID][7][3], 3, 1318)
	setElementData(pickup, "airport.gate.id", gateID)
	addEventHandler("onPickupHit", pickup, hitGateOutside)
	addEventHandler("onPickupLeave", pickup, leaveGate)
	outsidePickup[gateID] = pickup
end
function removeGateOutsidePickup(gateID)
	if isElement(outsidePickup[gateID]) then
		destroyElement(outsidePickup[gateID])
	end
	outsidePickup[gateID] = nil
end
function checkOutsidePickup(gateID)
	if isGateOpen(gateID) then
		if getGateConnectedPlane(gateID) then
			if(outsidePickup[gateID]) then
				removeGateOutsidePickup(gateID)
			end
		else
			if not outsidePickup[gateID] then
				createGateOutsidePickup(gateID)
			end
		end
	else
		if(outsidePickup[gateID]) then
			removeGateOutsidePickup(gateID)
		end
	end
end

function hitGateInside(thePlayer)
	if(isElement(thePlayer) and getElementType(thePlayer) == "player") then
		if(getElementDimension(thePlayer) == getElementDimension(source)) then
			local gateID = getElementData(source, "airport.gate.id")
			if(gateID) then
				bindKey(thePlayer, "f", "down", useGate, true, source)
				cancelEvent()
			end
		end
	end
end
function hitGateOutside(thePlayer)
	if(isElement(thePlayer) and getElementType(thePlayer) == "player") then
		if(getElementDimension(thePlayer) == getElementDimension(source)) then
			local gateID = getElementData(source, "airport.gate.id")
			if(gateID) then
				bindKey(thePlayer, "f", "down", useGate, false, source)
				cancelEvent()
			end
		end
	end
end
function useGate(thePlayer, key, keyState, inside, pickup)
	if(isElement(thePlayer) and getElementType(thePlayer) == "player") then
		unbindKey(thePlayer, "f", "down", useGate)
		local x,y,z = getElementPosition(pickup)
		local px,py,pz = getElementPosition(thePlayer)
		local reqDistance
		if inside then
			reqDistance = 1
		else
			reqDistance = 2
		end
		if(getDistanceBetweenPoints3D(x,y,z,px,py,pz) <= reqDistance) then		
			local gateID = getElementData(pickup, "airport.gate.id")
			if(gateID) then
				gateID = tonumber(gateID)
				local isOpen = gates[gateID][8]
				if isOpen then
					local bridge = gates[gateID][9]
					if inside then
						if bridge then
							local airplane = bridge
							if(isElement(airplane) and getElementType(airplane) == "vehicle" and getVehicleType(airplane) == "Plane") then
								if getElementData(airplane, "entrance") then
									triggerEvent("enterVehicleInterior", thePlayer, airplane)
								else
									gates[gateID][8] = false
									outputDebugString("aviation-system: Gate "..tostring(gateID).." bridge element has no interior.")
									outputChatBox("You try the door handle, but it seems to be locked.", thePlayer, 255, 0,0, false)
								end
							else
								gates[gateID][8] = false
								outputDebugString("aviation-system: Gate "..tostring(gateID).." bridge element is not a plane.")
								outputChatBox("You try the door handle, but it seems to be locked.", thePlayer, 255, 0,0, false)
							end
						else
							local teleportArr = {x = gates[gateID][7][1], y = gates[gateID][7][2], z = gates[gateID][7][3], int = 0, dim = 0}
							exports.interior_system:setPlayerInsideInterior3(false, thePlayer, teleportArr)
						end
					else
						if not bridge then
							local teleportArr = {x = gates[gateID][6][1], y = gates[gateID][6][2], z = gates[gateID][6][3], int = gates[gateID][6][4], dim = gates[gateID][6][5]}
							exports.interior_system:setPlayerInsideInterior3(false, thePlayer, teleportArr)
						end					
					end
				else
					outputChatBox("You try the door handle, but it seems to be locked.", thePlayer, 255, 0,0, false)
				end
			end
		else
			outputDebugString("aviation-system: Too far away from gate.")
		end
	end
end
function useGateOutside(thePlayer, key, keyState, pickup)
	if(isElement(thePlayer) and getElementType(thePlayer) == "player") then
		local gateID = getElementData(pickup, "airport.gate.id")
		if(gateID) then
			gateID = tonumber(gateID)
			local isOpen = gates[gateID][8]
			if isOpen then
				local bridge = gates[gateID][9]
				if not bridge then
					local teleportArr = {x = gates[gateID][6][1], y = gates[gateID][6][2], z = gates[gateID][6][3], int = gates[gateID][6][4], dim = gates[gateID][6][5]}
					exports.interior_system:setPlayerInsideInterior3(false, thePlayer, teleportArr)
				end
			else
				outputChatBox("You try the door handle, but it seems to be locked.", thePlayer, 255, 0,0, false)
			end
		end
	end
end
function leaveGate(thePlayer)
	unbindKey(thePlayer, "f", "down", useGate)
end


function isGateOpen(gateID)
	return gates[gateID][8]
end
function setGateOpen(gateID, open)
	gates[gateID][8] = open
	checkOutsidePickup(gateID)
end
addEvent("airport-gates:setGateOpen", true)
addEventHandler("airport-gates:setGateOpen", getRootElement(), setGateOpen)
function toggleGateOpen(gateID)
	gates[gateID][8] = not gates[gateID][8]
	checkOutsidePickup(gateID)
end
addEvent("airport-gates:toggleGateOpen", true)
addEventHandler("airport-gates:toggleGateOpen", getRootElement(), toggleGateOpen)
function connectBridgeToPlane(gateID, element)
	gates[gateID][9] = element
	setElementData(element, "airport.gate.connected", gateID)
end
function disconnectBridge(gateID)
	local element = gates[gateID][9]
	if(isElement(element)) then
		setElementData(element, "airport.gate.connected", false)
	end
	gates[gateID][9] = false
	checkOutsidePickup(gateID)
end
addEvent("airport-gates:disconnectBridge", true)
addEventHandler("airport-gates:disconnectBridge", getRootElement(), disconnectBridge)
function connectBridge(gateID)
	if(isElement(shapes[gateID]) and getElementType(shapes[gateID]) == "colshape") then
		for k,v in ipairs(getElementsWithinColShape(shapes[gateID])) do
			if(getElementType(v) == "vehicle") then
				if(getVehicleType(v) == "Plane") then
					local model = getElementModel(v)
					if(model == 519 or model == 577) then
						connectBridgeToPlane(gateID, v)
						checkOutsidePickup(gateID)
						return v
					end
				end
			end
		end
	end
	checkOutsidePickup(gateID)
	return false
end
addEvent("airport-gates:connectBridge", true)
addEventHandler("airport-gates:connectBridge", getRootElement(), connectBridge)
function getPlaneAtGate(gateID)
	if(isElement(shapes[gateID]) and getElementType(shapes[gateID]) == "colshape") then
		for k,v in ipairs(getElementsWithinColShape(shapes[gateID])) do
			if(getElementType(v) == "vehicle") then
				if(getVehicleType(v) == "Plane") then
					return v
				end
			end
		end
	end
	return false
end
function closeGate(gateID, closed)
	gates[gateID][10] = closed
end
function isPlaneAtGate(plane, gateID)
	if(isElement(plane) and getElementType(plane) == "vehicle" and getVehicleType(plane) == "Plane" and isElement(shapes[gateID]) and getElementType(shapes[gateID]) == "colshape") then
		return isElementWithinColShape(plane, shapes[gateID])
	end
	return false
end
function isPlaneConnectedToGate(plane, gateID)
	if gateID then
		local element = gates[gateID][9]
		if(plane == element) then
			return true
		end
	else
		for k,v in ipairs(gates) do
			local element = v[9]
			if(element and plane == element) then
				return true
			end
		end
	end
	return false
end
function getGateConnectedPlane(gateID, noCheck)
	if noCheck then
		return gates[gateID][9]
	end
	local connected = gates[gateID][9]
	if connected then
		if not isPlaneAtGate(connected, gateID) then
			disconnectBridge(gateID)
			return false
		end
	end
	return connected
end
function getPlaneConnectedGate(plane)
	for k,v in ipairs(gates) do
		local element = v[9]
		if(element and plane == element) then
			return k
		end
	end
	return false
end
function checkGate(gateID)
	local connected = getGateConnectedPlane(gateID, true)
	if connected then
		if not isPlaneAtGate(connected, gateID) then
			disconnectBridge(gateID)
		end
	end
end
addEvent("airport-gates:checkGate", true)
addEventHandler("airport-gates:checkGate", getRootElement(), checkGate)


function serverFillControlGUI(element, gateID)
	local open = isGateOpen(gateID)
	local plane = getPlaneAtGate(gateID)
	local connected = getGateConnectedPlane(gateID)
	triggerClientEvent(source, "airport-gates:fillControlGUI", source, element, gateID, open, plane, connected)
end
addEvent("airport-gates:getGUIdata", true)
addEventHandler("airport-gates:getGUIdata", getRootElement(), serverFillControlGUI)

function getDataForExitingConnectedPlane(gateID, plane)
	local connected = getGateConnectedPlane(gateID)
	if connected and connected == plane then
		return {x = gates[gateID][6][1], y = gates[gateID][6][2], z = gates[gateID][6][3], int = gates[gateID][6][4], dim = gates[gateID][6][5], rot = 0}
	end
	return false
end

function setTempCallsign(thePlayer, commandName, vehID, ...)
	local callsign = table.concat({...}, " ")
	--local realFactionID = getElementData(theElement, "faction") or -1
	local factionLeaderStatus = exports.factions:hasMemberPermissionTo(thePlayer, LSIAfactionID, "respawn_vehs")
	if(factionLeaderStatus or exports.integration:isPlayerAdmin(thePlayer) and exports.global:isAdminOnDuty(thePlayer)) then
		if vehID and callsign then
			local theVehicle = exports.pool:getElement("vehicle", tonumber(vehID))
			if theVehicle then
				if(getVehicleType(theVehicle) == "Helicopter" or getVehicleType(theVehicle) == "Plane") then
					setElementData(theVehicle, "aircallsign", tostring(callsign))
					outputChatBox("Callsign for vehicle #"..tostring(vehID).." set to '"..tostring(callsign).."'.", thePlayer, 0, 255, 0)
				else
					outputChatBox("That vehicle is not an aircraft.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("Invalid Vehicle ID.", thePlayer, 255, 0, 0)
			end
		else
			outputChatBox("SYNTAX: /" .. commandName .. " [vehicleID] [callsign]", thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("setcallsign", setTempCallsign)
function removeTempCallsign(thePlayer, commandName, vehID)
	--local realFactionID = getElementData(theElement, "faction") or -1
	local factionLeaderStatus = exports.factions:hasMemberPermissionTo(thePlayer, LSIAfactionID, "respawn_vehs")
	if(factionLeaderStatus or exports.integration:isPlayerAdmin(thePlayer) and exports.global:isAdminOnDuty(thePlayer)) then
		if vehID then
			local theVehicle = exports.pool:getElement("vehicle", tonumber(vehID))
			if theVehicle then
				setElementData(theVehicle, "aircallsign", false)
				outputChatBox("Callsign for vehicle #"..tostring(vehID).." was cleared.", thePlayer, 0, 255, 0)
			else
				outputChatBox("Invalid Vehicle ID.", thePlayer, 255, 0, 0)
			end
		else
			outputChatBox("SYNTAX: /" .. commandName .. " [vehicleID]", thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("clearcallsign", removeTempCallsign)