function giveTruckingMoney(wage)
	exports.global:giveMoney(source, wage)
end
addEvent("giveTruckingMoney", true)
addEventHandler("giveTruckingMoney", getRootElement(), giveTruckingMoney)

function respawnTruck(vehicle)
	removePedFromVehicle(source, vehicle)
	respawnVehicle(vehicle)
	setVehicleLocked(vehicle, false)
end
addEvent("respawnTruck", true)
addEventHandler("respawnTruck", getRootElement(), respawnTruck)

function playerQuitJob()
	exports.anticheat:changeProtectedElementDataEx(source, "job", 0, true)
end
addEvent("quitjob", true)
addEventHandler("quitjob", getRootElement(), playerQuitJob)