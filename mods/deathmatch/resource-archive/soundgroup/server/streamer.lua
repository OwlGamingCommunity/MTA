local streamerRadius = 1
local streamer

function runStreamer( )
	streamer = createColSphere( areaData.x, areaData.y, areaData.z, streamerRadius )
	
	if ( streamer ) then
		setElementInterior( streamer, areaData.interior )
		setElementDimension( streamer, areaData.dimension )
		
		local function trigger( element, matchingDimension )
			if ( getElementType( element ) == "player" ) and ( matchingDimension ) then
				triggerClientEvent( element, "soundgroup:streamer", element, eventName == "onColShapeHit" )
			end 
		end
		addEventHandler( "onColShapeHit", streamer, trigger )
		addEventHandler( "onColShapeLeave", streamer, trigger )
		
		for _, player in ipairs( getElementsByType( "player" ) ) do
			if ( isElementWithinColShape( player, streamer ) ) then
				updateStreamer( player, true )
			else
				updateStreamer( player, false )
			end
		end
	end
end

function updateStreamer( player, hitOrLeft )
	return triggerClientEvent( player, "soundgroup:streamer", player, hitOrLeft )
end