function handleOdoMeterRequest(totalDistance, syncDistance)
	if not totalDistance then
		local theVehicle = getPedOccupiedVehicle(client)
		if theVehicle == source then
			local totDistance = getElementData(theVehicle,"odometer") or 0
			triggerClientEvent(client, "realism:distance", theVehicle, totDistance)			
		end
	else
		if not syncDistance then
			return
		end
		local theVehicle = getPedOccupiedVehicle(client)
		if theVehicle == source then
			local theSeat = getPedOccupiedVehicleSeat(client)
			if theSeat == 0 then
				local totDistance = getElementData(theVehicle,"odometer") or 0
				exports.anticheat:changeProtectedElementDataEx(theVehicle, 'odometer', totDistance + syncDistance, false )
				depeteFuel(theVehicle, syncDistance)
			end
		end
	end
end
addEvent("realism:distance", true)
addEventHandler("realism:distance", getRootElement(), handleOdoMeterRequest)

function depeteFuel(theVehicle, syncDistance)
	return -- TODO
end

function syncOdoOnEnter(thePlayer)
	local odometer = getElementData(source, "odometer") or 0
	triggerClientEvent(thePlayer, "realism:distance", source, odometer)
end
addEventHandler("onVehicleEnter", getRootElement(), syncOdoOnEnter)
