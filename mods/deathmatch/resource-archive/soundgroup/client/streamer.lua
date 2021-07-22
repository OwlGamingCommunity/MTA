addEvent( "soundgroup:streamer", true )
addEventHandler( "soundgroup:streamer", root,
	function( hitOrLeft )
		local elements = { }
		
		for _, element in ipairs( getElementsByType( "marker" ) ) do
			table.insert( elements, element )
		end
		
		for _, element in ipairs( getElementsByType( "colshape" ) ) do
			table.insert( elements, element )
		end
		
		for _, element in ipairs( getElementsByType( "pickup" ) ) do
			table.insert( elements, element )
		end
		
		for _, element in ipairs( elements ) do
			local isSoundGroupLight = getElementData( element, "soundgroup:light" )
			
			if ( ( not isSoundGroupLight ) and ( getElementDimension( element ) == ( hitOrLeft and ( areaData and areaData.dimension or 0 ) or 65534 ) ) ) or ( isSoundGroupLight ) then
				setElementDimension( element, ( hitOrLeft and ( isSoundGroupLight and ( areaData and areaData.dimension or 0 ) or 65534 ) or ( isSoundGroupLight and 65534 or ( areaData and areaData.dimension or 0 ) ) ) )
			end
		end
	end
)