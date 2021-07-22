function showGPS(player)
	local vehicle = getPedOccupiedVehicle(player)

	if (vehicle) then -- In vehicle
		local seat = getPedOccupiedVehicleSeat(player)
		
		if (seat==0) then
			if (exports.global:hasItem(vehicle, 67, nil)) then -- has GPS?
				triggerClientEvent(player, "displayGPS", vehicle)
			end
		end
	end
end