local seatbeltalert = { [1] = {}, [2] = {}, [3] = {} }

function resStart()
	for key, value in ipairs(getElementsByType("vehicle")) do
		setElementData(value, "seatbeltwarning", nil)
		triggerServerEvent("onVehicleSeatbeltWarning", value)
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), resStart)

function seatBeltWarning()
	local seatbeltwarning = getElementData(source, "seatbeltwarning")
	if not seatbeltwarning then
		seatbeltalert[1][source] = setTimer(doCarSeatBelt, 1000, 20, source)
		setElementData(source, "seatbeltwarning", 1)
		seatbeltalert[2][source] = setTimer(resetSeatBelt, 21000, 1, source)
	end
end
addEvent("startSeatBeltWarning", true)
addEventHandler("startSeatBeltWarning", getRootElement(), seatBeltWarning)

function resetSeatBelt(vehicle)
	if isElement(vehicle) then
		setElementData(vehicle, "seatbeltwarning", nil)
	end
end

function destroyImage(vehicle)
	while isElement(image) do
		destroyElement(image)
	end
	if isTimer(seatbeltalert[3][vehicle]) then
		killTimer(seatbeltalert[3][vehicle])
		seatbeltalert[3][vehicle] = nil
	end
end

function doCarSeatBelt(vehicle)
	if isElement(vehicle) then
	local driver = getVehicleOccupant(vehicle, 0)
	local passenger1 = getVehicleOccupant(vehicle, 1)
	local passenger2 = getVehicleOccupant(vehicle, 2)
	local passenger3 = getVehicleOccupant(vehicle, 3)
	local windowState = getElementData(vehicle, "vehicle:windowstat") or 1

		if driver and passenger1 then
			if (getElementData(driver, "seatbelt") and getElementData(passenger1, "seatbelt")) then
				setElementData(vehicle, "seatbeltwarning", nil)
				if (isTimer(seatbeltalert[1][vehicle])) then
					killTimer(seatbeltalert[1][vehicle])
				end
				if (isTimer(seatbeltalert[2][vehicle])) then
					killTimer(seatbeltalert[2][vehicle])
				end
				if isTimer(seatbeltalert[3][vehicle]) then
					killTimer(seatbeltalert[3][vehicle])
				end
				seatbeltalert[3][vehicle] = nil
				seatbeltalert[2][vehicle] = nil
				seatbeltalert[1][vehicle] = nil
				return
			end
		elseif driver and not passenger1 then
			if (getElementData(driver, "seatbelt")) then
				setElementData(vehicle, "seatbeltwarning", nil)
				if (isTimer(seatbeltalert[1][vehicle])) then
					killTimer(seatbeltalert[1][vehicle])
				end
				if (isTimer(seatbeltalert[2][vehicle])) then
					killTimer(seatbeltalert[2][vehicle])
				end
				if isTimer(seatbeltalert[3][vehicle]) then
					killTimer(seatbeltalert[3][vehicle])
				end
				seatbeltalert[3][vehicle] = nil
				seatbeltalert[2][vehicle] = nil
				seatbeltalert[1][vehicle] = nil
				return
			end
		end

		if getVehicleEngineState ( vehicle ) == false then
			setElementData(vehicle, "seatbeltwarning", nil)
			if (isTimer(seatbeltalert[1][vehicle])) then
				killTimer(seatbeltalert[1][vehicle])
			end
			if (isTimer(seatbeltalert[2][vehicle])) then
				killTimer(seatbeltalert[2][vehicle])
			end
			if isTimer(seatbeltalert[3][vehicle]) then
				killTimer(seatbeltalert[3][vehicle])
			end
			seatbeltalert[3][vehicle] = nil
			seatbeltalert[2][vehicle] = nil
			seatbeltalert[1][vehicle] = nil
			return
		end

		local x, y, z = getElementPosition(vehicle)
		local vDim = getElementDimension(vehicle)
		local vInt = getElementInterior(vehicle)
		local px, py, pz = getElementPosition(localPlayer)
		local pDim = getElementDimension(localPlayer)
		local pInt = getElementDimension(localPlayer)

		if driver == localPlayer or passenger1 == localPlayer then
			if not isElement(image) and getElementData(localPlayer, "hide_hud" ) ~= "0" then
				local x, y = guiGetScreenSize()
				image = guiCreateStaticImage(x - 180, y - 140.5, 64, 64, "seatbelt/seatbelt.png", false)
				seatbeltalert[3][vehicle] = setTimer(destroyImage, 500, 1, vehicle)
			end
		end

		--[[if pDim == vDim and pInt == vInt and getDistanceBetweenPoints3D(x, y, z, px, py, pz) <= 30 then
			local sound = playSound3D("seatbelt/seatbeltwarning.wav", x, y, z)
			if (windowState == 1) and not (localPlayer == driver or localPlayer == passenger1 or localPlayer == passenger2 or localPlayer == passenger3) then
				setSoundVolume(sound, 0.1)
			end
			for i = 2, 5 do
				if doesVehicleHaveDoorOpen(vehicle) then
					setSoundVolume(sound, 0.8)
				end
			end
			setElementDimension( sound, vDim )
			setElementInterior( sound, vInt )
		end]]
	end
end

function doesVehicleHaveDoorOpen(vehicle)
	local isDoorOpen = false
	for i=0,5 do
		local doorState = getVehicleDoorState(vehicle, i)
		if doorState == 1 or doorState == 3 or doorState == 4 then
			isDoorOpen = true
		end
	end

	return isDoorOpen
end

addEventHandler("onClientVehicleExit", getRootElement(), function(thePlayer)
	if isElement(image) then
		destroyElement(image)
	end
	if isTimer(seatbeltalert[3][source]) then
		killTimer(seatbeltalert[3][source])
		seatbeltalert[3][source] = nil
	end
	if isTimer(seatbeltalert[2][source]) then
		killTimer(seatbeltalert[2][source])
		seatbeltalert[2][source] = nil
	end
	if isTimer(seatbeltalert[1][source]) then
		killTimer(seatbeltalert[1][source])
		seatbeltalert[1][source] = nil
	end
end)
