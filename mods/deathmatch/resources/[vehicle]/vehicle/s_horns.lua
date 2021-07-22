hornDisabled = {
	--[490] = true,
	[523] = true,
	[544] = true,
}

addEventHandler("onVehicleEnter", getRootElement(), function (thePlayer, seat, jacked)
	if seat == 0 and hornDisabled[getElementModel(source)] and isControlEnabled(thePlayer, "horn") then
		toggleControl(thePlayer, "horn", false)
	end
end)

addEventHandler("onVehicleExit", getRootElement(), function (thePlayer, seat, jacked)
	if seat == 0 and hornDisabled[getElementModel(source)] and not isControlEnabled(thePlayer, "horn") then
		toggleControl(thePlayer, "horn", true)
	end
end)
