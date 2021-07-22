function unsitInHelicopter(vehicle)
	local seat = getElementData(client, "seat")
	
	if (isElement(vehicle)) then
		if not (getElementType(vehicle)=="vehicle") then
			local vehicles = exports.pool:getPoolElementsByType("vehicle")
			local helicopters = { }
			for key, value in ipairs(vehicles) do
				if (getElementModel(value)==497) or (getElementModel(value)==563) or (getElementModel(value) == 469) then
					table.insert(helicopters, value)
				end
			end
			
			for key, value in ipairs(helicopters) do
				local players = getElementData(value, "players")
				
				if (players) then
					local removed = false
					for key, value in ipairs(players) do
						if (value==client) then
							removed = true
							table.remove(players, key)
						end
					end
					
					if (removed) then
						exports.anticheat:changeProtectedElementDataEx(value, "players", players, true)
					end
				end
			end
			
			exports.anticheat:changeProtectedElementDataEx(client, "seat")
			detachElements(client, vehicle)
			exports.global:removeAnimation(client)
		elseif (seat) and (seat>0) then
			local players = getElementData(vehicle, "players")
			
			for key, value in ipairs(players) do
				if (value==client) then
					table.remove(players, key)
				end
			end
			exports.anticheat:changeProtectedElementDataEx(vehicle, "players", players, true)
			exports.anticheat:changeProtectedElementDataEx(client, "seat")
			detachElements(client, vehicle)
			exports.global:removeAnimation(client)
		end
	end
end
addEvent("unsitInHelicopter", true)
addEventHandler("unsitInHelicopter", getRootElement(), unsitInHelicopter)

function sitInHelicopter(vehicle)
	local players = getElementData(vehicle, "players")
	
	--[[for key, value in ipairs(players) do
		if not isElement( argument ) or not getElementType( argument ) == "player" then
			table.remove(players, key)
		elseif not isElementAttached ( value ) then
			exports.anticheat:changeProtectedElementDataEx(value, "seat")
			table.remove(players, key)
		elseif value == source then
			exports.anticheat:changeProtectedElementDataEx(value, "seat")
			table.remove(players, key)
		end
	end]]
	
	if (not players) or (#players<3) then
		local seat = 0
		if not (players) then
			players = { }
			seat = 1
		end
		
		
		local s1 = false
		local s2 = false
		local s3 = false

		for key, value in ipairs(players) do
			if (key==1) then
				s1 = true
			elseif (key==2) then
				s2 = true
			elseif (key==3) then
				s3 = true
			end
		end
		
		if not (s1) then
			seat = 1
			
			local x, y, z = getElementPosition(vehicle)
			local rx, ry, rz = getVehicleRotation(vehicle)
			x = x - math.sin(math.rad(rz))*1.01
			y = y - math.cos(math.rad(rz))*1.01
			
			attachElements(client, vehicle, -1.3, 0, 0)
			setPedRotation(client, rz+90)
			exports.global:applyAnimation(client, "FOOD", "FF_Sit_Look", 999999, true, true, false)
			setPedWeaponSlot(client, 5)
		elseif not (s2) then
			seat = 2
			
			local x, y, z = getElementPosition(vehicle)
			local rx, ry, rz = getVehicleRotation(vehicle)
			x = x + math.sin(math.rad(rz))*1.01
			y = y + math.cos(math.rad(rz))*1.01
			
			attachElements(client, vehicle, 1.3, 0, 0)
			setPedRotation(client, rz-90)
			exports.global:applyAnimation(client, "FOOD", "FF_Sit_Look", 999999, true, true, false)
			setPedWeaponSlot(client, 5)
		elseif not (s3) then
			seat = 3
			
			local x, y, z = getElementPosition(vehicle)
			local rx, ry, rz = getVehicleRotation(vehicle)
			x = x + math.sin(math.rad(rz))*1.01
			y = y + math.cos(math.rad(rz))*1.01
			
			attachElements(client, vehicle, 1.3, 1, 0)
			setPedRotation(client, rz-90)
			exports.global:applyAnimation(client, "FOOD", "FF_Sit_Look", 999999, true, true, false)
			setPedWeaponSlot(client, 5)		
		end
		
		players[seat] = client
		exports.anticheat:changeProtectedElementDataEx(client, "seat", seat)
		
		exports.anticheat:changeProtectedElementDataEx(vehicle, "players", players, true)
	else
		outputChatBox("This helicopter is full.", client, 255, 0, 0)
	end
end
addEvent("sitInHelicopter", true)
addEventHandler("sitInHelicopter", getRootElement(), sitInHelicopter)