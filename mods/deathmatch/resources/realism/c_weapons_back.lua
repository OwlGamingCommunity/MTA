--[[
weapons = { }

function weaponSwitch(prevSlot, newSlot)
	local weapon = getPedWeapon(source, prevSlot)
	local newWeapon = getPedWeapon(source, newSlot)
	
	if (weapons[source] == nil) then
		weapons[source] = { }
	end
	
	if (weapon == 30 or weapon == 31 or weapon == 25 or weapon == 27 or weapon == 33 or weapon == 34) and (isPedInVehicle(source)==false) then
		if (weapons[source][1] == nil or weapons[source][2] ~= weapon or weapons[source][3] ~= isPedDucked(source)) then -- Model never created
			weapons[source][1] = createModel(source, weapon)
			weapons[source][2] = weapon
			weapons[source][3] = isPedDucked(source)
		else
			local object = weapons[source][1]
			destroyElement(object)
			weapons[source] = nil
		end
	elseif weapons[source] and weapons[source][1] and ( newWeapon == 30 or newWeapon == 31 or newWeapon == 25 or newWeapon == 27 or newWeapon == 33 or newWeapon == 34 or getPedTotalAmmo(source, 5) == 0 ) then
		local object = weapons[source][1]
		destroyElement(object)
		weapons[source] = nil
	end
end
addEventHandler("onPlayerWeaponSwitch", getRootElement(), weaponSwitch)
addEventHandler("onClientPlayerWeaponSwitch", getRootElement(), weaponSwitch)

function playerEntersVehicle(player)
	if (weapons[player]) then
		local object = weapons[player][1]
		
		if (isElement(object)) then
			destroyElement(object)
		end
	end
end
addEventHandler("onClientVehicleEnter", getRootElement(), playerEntersVehicle)

function playerExitsVehicle(player)
	if (weapons[player]) and ( getPedTotalAmmo(player, 5) or 0 ) > 0 then
		local weapon = weapons[player][2]
		
		if (weapon) then
			weapons[player][1] = createModel(player, weapon)
			weapons[player][3] = isPedDucked(player)
		end
	end
end
addEventHandler("onClientVehicleExit", getRootElement(), playerExitsVehicle)

function createModel(player, weapon)
	local bx, by, bz = getPedBonePosition(player, 3)
	local x, y, z = getElementPosition(player)
	local r = getPedRotation(player)
				
	crouched = isPedDucked(player)
	
	local ox, oy, oz = bx-x-0.13, by-y-0.25, bz-z+0.25
	
	if (crouched) then
		oz = -0.025
	end
	
	local objectID = 355

	if (weapon==31) then
		objectID = 356
	elseif (weapon==30) then
		objectID = 355
	elseif (weapon==25) then
		objectID = 349
	elseif (weapon==27) then
		objectID = 351
	elseif (weapon==33) then
		objectID = 357
	elseif (weapon==34) then
		objectID = 358
	end
	
	local currobject = weapons[player][1]
	if (isElement(currobject)) then
		destroyElement(currobject)
	end
	
	local object = createObject(objectID, x, y, z)
	attachElements(object, player, ox, oy, oz, 0, 60, 0)
	setElementCollisionsEnabled(object, false)
	return object
end]]