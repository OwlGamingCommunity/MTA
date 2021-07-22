local snowTireID = 212

function enterVehicle(thePlayer, seat, jacked)
	if seat == 0 then
		local hasSnowTire = exports.global:hasItem(source, snowTireID)
		triggerClientEvent(thePlayer, "shader_snow_ground:applySlippery", root, source, hasSnowTire)
	end
end
addEventHandler("onVehicleEnter", getRootElement(), enterVehicle)

function checkAllVehicles()
	for k, vehicle in ipairs(exports.pool:getPoolElementsByType("vehicle")) do
		local driver = getVehicleController(vehicle)
		if driver then
			local vType = getVehicleType(vehicle) 
			if vType == "Plane" or vType == "Helicopter" or vType == "Boat" or vType == "Train" then
				--excempt
			else
				local hasSnowTire = exports.global:hasItem(vehicle, snowTireID)
				triggerLatentClientEvent(driver, "shader_snow_ground:applySlippery", 50000, false, root, vehicle, hasSnowTire)
			end
		end
	end
end
addEventHandler("onResourceStart", resourceRoot, checkAllVehicles)

function activateIceSkating()
	triggerEvent("events:skating", root)
end
addEventHandler("onResourceStart", resourceRoot, activateIceSkating)
