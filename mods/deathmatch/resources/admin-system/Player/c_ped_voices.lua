addEventHandler( "onClientElementStreamIn", getRootElement( ),
	function ( )
		if getElementType( source ) == "player" then
			setPedVoice( source, "PED_TYPE_DISABLED" )
		end
	end
)

addEventHandler( "onClientResourceStart", getResourceRootElement(),
	function ( startedRes )
		for key, value in ipairs( getElementsByType( "player" ) ) do
			if getElementDimension( value ) < 65000 then
				setPedVoice( value, "PED_TYPE_DISABLED" )
			end
		end
	end
)