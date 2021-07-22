function startRappel(x, y, z, gz)
	local r = getPedRotation(source)
	
	local seat = getPedOccupiedVehicleSeat(source)
	
	if (seat==0 or seat==2) then -- left hand side
		r = r + 90
	else
		r = r - 90
	end
	
	setPedRotation(source, r)
	
	local slot = getPedWeaponSlot(source)
	local invisible = createObject (1337, x, y, z, 0, 0, r)
	setElementAlpha(invisible, 0)
	exports.anticheat:changeProtectedElementDataEx(source, "realinvehicle", 0, false)
	removePedFromVehicle(source)
	attachElements(source, invisible)
	moveObject(invisible, 2000, x, y, gz, 0, 0, 0)
	exports.pool:allocateElement(invisible)
	setTimer(stopRappel, 2000, 1, invisible, source, slot)
	exports.global:applyAnimation(source, "PARACHUTE", "PARA_float", true, 1.0, false, false)
	
	for key, value in ipairs(exports.global:getNearbyElements(invisible, "player", 100)) do
		triggerClientEvent(value, "createRope", value, x, y, z, gz)
	end
end
addEvent("startRappel", true)
addEventHandler("startRappel", getRootElement(), startRappel)

function stopRappel(object, player, slot)
	detachElements(player, object)
	exports.global:removeAnimation(player)
	setPedWeaponSlot(player, slot)
	destroyElement(object)
end
	