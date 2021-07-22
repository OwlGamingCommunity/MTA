function updateItemThings()
	--outputDebugString("itemThingsUpdate")
	local vehicle = getPedOccupiedVehicle(localPlayer)
	local shown = false
	if hasItem(localPlayer, 111) then
		shown = true
	elseif vehicle then
		if (tonumber(getElementData(vehicle, "job")) or 0) > 0 then
			-- job vehicle
			shown = true
		elseif getElementData(vehicle, "owner") == -2 and getElementData(vehicle, "faction") == -1 and getElementModel(vehicle) == 468 and getElementData(localPlayer,"license.bike") == 3 then
			-- dmv test bike
			shown = true
		elseif getElementData(vehicle, "owner") == -2 and getElementData(vehicle, "faction") == -1 and getElementModel(vehicle) == 410 and getElementData(localPlayer,"license.car") == 3 then
			-- dmv test car
			shown = true
		end
	end
	setPlayerHudComponentVisible("radar", shown)
	isPlayerGPSShowing = shown
end
addEvent("item:updateclient", true)
addEventHandler("item:updateclient", getRootElement(), updateItemThings)
addEventHandler("onCharacterLogin", getRootElement(), updateItemThings)
addEventHandler("onClientPlayerVehicleEnter", getLocalPlayer(), updateItemThings)
addEventHandler("onClientPlayerVehicleExit", getLocalPlayer(), updateItemThings)
