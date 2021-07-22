txd = engineLoadTXD ( "silenced.txd" )
engineImportTXD ( txd, 2918 )
dff = engineLoadDFF ( "silenced.dff", 2918 )
engineReplaceModel ( dff, 2918 )
--[[
weapons = { }


function weaponSwitch(prevSlot, newSlot)
	local weapon = getPedWeapon(source, prevSlot)
	local newWeapon = getPedWeapon(source, newSlot)
	
	if (weapons[source] == nil) then
		weapons[source] = { }
	end

	if (weapon == 24) and (isPedInVehicle(source)==false) then
		if (weapons[source][1] == nil or weapons[source][2] ~= weapon or weapons[source][3] ~= isPedDucked(source)) then -- Model never created
			weapons[source][1] = createModel(source, weapon)
			weapons[source][2] = weapon
			weapons[source][3] = isPedDucked(source)
		else
			local object = weapons[source][1]
			destroyElement(object)
			weapons[source] = nil
		end
	elseif weapons[source] and weapons[source][1] and ( newWeapon == 24 or getPedTotalAmmo(source, 2) == 0 ) then
		local object = weapons[source][1]
		if isElement(object) then
			destroyElement(object)
		end
		weapons[source] = nil
	end
end
addEvent("onPlayerWeaponSwitch", true)
addEventHandler("onPlayerWeaponSwitch", getRootElement(), weaponSwitch)
addEventHandler("onClientPlayerWeaponSwitch", getLocalPlayer(), weaponSwitch)

function switchEvent(oldSlot, newSlot)
	triggerServerEvent("sendWeaponSwitchToAll", getLocalPlayer(), oldSlot, newSlot)
end
addEventHandler("onClientPlayerWeaponSwitch", getLocalPlayer(), switchEvent)


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
	if (weapons[player]) and (tonumber(getPedTotalAmmo(player, 2)) or 0) > 0 then
		local weapon = weapons[player][2]
		
		if (weapon) then
			weapons[player][1] = createModel(player, weapon)
			weapons[player][3] = isPedDucked(player)
		end
	end
end
addEventHandler("onClientVehicleExit", getRootElement(), playerExitsVehicle)

function destroyModel()
	if (weapons[value] ~= nil) then
		local object = weapons[value][1]
		destroyElement(object)
		weapons[value] = nil
	end
end
addEventHandler("onClientPlayerWasted", getRootElement(), destroyModel)
addEventHandler("onClientPlayerQuit", getRootElement(), destroyModel)


function createModel(player, weapon)
	local bx, by, bz = getPedBonePosition(player, 41)
	crouched = isPedDucked(player)

	local objectID = 2918
	
	if (weapons[player] ~= nil) then
		local currobject = weapons[player][1]
		if (isElement(currobject)) then
			destroyElement(currobject)
		end
	end
	
	local oz = 0.09
	
	if (crouched) then
		oz = -0.525
	end
	
	local object = createObject(objectID, bx-0.19, by-0.1, oz)
	attachElements(object, player, -0.19, -0.1, oz, 0, 60, 90)
	setElementCollisionsEnabled(object, false)
	return object
end]]
