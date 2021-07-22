lawVehicles = { [416]=true, [433]=true, [427]=true, [490]=true, [528]=true, [407]=true, [544]=true, [523]=true, [470]=true, [598]=true, [596]=true, [597]=true, [599]=true, [432]=true, [601]=true }

function syncRadio(station)
	local vehicle = getPedOccupiedVehicle(source)
	local seat = getPedOccupiedVehicleSeat(source)

	if (vehicle) then
		exports.anticheat:changeProtectedElementDataEx(vehicle, "radiostation", station, false)
		for i = 0, getVehicleMaxPassengers(vehicle) do
			if (i~=seat) then
				local occupant = getVehicleOccupant(vehicle, i)
				if (occupant) then
					triggerClientEvent(occupant, "syncRadio", occupant, station)
				end
			end
		end
	end
end
addEvent("sendRadioSync", true)
addEventHandler("sendRadioSync", getRootElement(), syncRadio)

function setRadioOnEnter(player)
	if not (lawVehicles[getElementModel(source)]) then
		local station = getElementData(source, "radiostation")
		if not station then
			station = math.random(1, 12)
			exports.anticheat:changeProtectedElementDataEx(source, "radiostation", station, false)
		end
		triggerClientEvent(player, "syncRadio", player, station)
	else
		triggerClientEvent(player, "syncRadio", player, 0)
	end
end
addEventHandler("onVehicleEnter", getRootElement(), setRadioOnEnter)