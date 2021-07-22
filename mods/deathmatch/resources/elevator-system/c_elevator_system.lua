addEventHandler( "onClientPlayerVehicleEnter", getLocalPlayer(),
	function( vehicle )
		setElementData( vehicle, "groundoffset", 0.2 + getElementDistanceFromCentreOfMassToBaseOfModel( vehicle ) )
	end
)

addEvent( "CantFallOffBike", true )
addEventHandler( "CantFallOffBike", getLocalPlayer(),
	function( )
		--outputDebugString("setPedCanBeKnockedOffBike")
		setPedCanBeKnockedOffBike( getLocalPlayer(), false )
		setTimer( setPedCanBeKnockedOffBike, 5000, 1, getLocalPlayer(), true )
	end
)