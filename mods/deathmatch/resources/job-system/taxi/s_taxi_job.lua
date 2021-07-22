addEventHandler( "onVehicleRespawn", getRootElement( ),
	function( )
		if isVehicleTaxiLightOn( source ) then
			setVehicleTaxiLightOn( source, false )
		end
	end
)

addEventHandler( "onVehicleStartExit", getRootElement( ),
	function( player, seat, jacked )
		if isVehicleTaxiLightOn( source ) then
			setVehicleTaxiLightOn( source, false )
		end
	end
)

function toggleTaxiLight(thePlayer, commandName)
	local theVehicle = getPedOccupiedVehicle(thePlayer)
	if theVehicle then
		if getVehicleController(theVehicle) == thePlayer and getElementModel(theVehicle) == 438 or getElementModel(theVehicle) == 420 then
			setVehicleTaxiLightOn(theVehicle, not isVehicleTaxiLightOn(theVehicle))
		end
	end
end
addCommandHandler("taxilight", toggleTaxiLight, false, false)