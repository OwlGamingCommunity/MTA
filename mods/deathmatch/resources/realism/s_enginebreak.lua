function engineBreak()
	local health = getElementHealth(source)
	local driver = getVehicleController(source)
	local vehID = getElementData(source, "dbid")
	
	if (driver) then
		if (health<=300) then
			local rand = math.random(1, 2)

			if (rand==1) then -- 50% chance
				setVehicleEngineState(source, false)
				exports.anticheat:changeProtectedElementDataEx(source, "engine", 0, false)
				exports.global:sendLocalDoAction(driver, "The engine stalls due to damage.")
				-- Take key / Give key to player when engine off by Anthony
				if exports['global']:hasItem(source, 3, vehID) then
					exports['global']:takeItem(source, 3, vehID)
					exports['global']:giveItem(driver, 3, vehID)
				else
				end
			end
		elseif (health<=400) then
			local rand = math.random(1, 5)

			if (rand==1) then -- 20% chance
				setVehicleEngineState(source, false)
				exports.anticheat:changeProtectedElementDataEx(source, "engine", 0, false)
				exports.global:sendLocalDoAction(driver, "The engine stalls due to damage.")
				-- Take key / Give key to player when engine off by Anthony
				if exports['global']:hasItem(source, 3, vehID) then
					exports['global']:takeItem(source, 3, vehID)
					exports['global']:giveItem(driver, 3, vehID)
				else
				end
			end
		end
	end
end
addEventHandler("onVehicleDamage", getRootElement(), engineBreak)