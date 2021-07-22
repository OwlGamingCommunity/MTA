--
-- people with blips
--
local blips = { }
local exclude = { }

addEvent( "sfia:airtrack:on", true )
addEventHandler( "sfia:airtrack:on", root,
	function( )
		if getElementType( source ) == "vehicle" then
			triggerClientEvent( client, "sfia:airtrack:blips", client, blips )
			
			blips[ client ] = source
			for player in pairs( blips ) do
				triggerClientEvent( player, "sfia:airtrack:on", source )
			end
		end
	end
)

addEvent( "sfia:airtrack:onTower", true )
addEventHandler( "sfia:airtrack:onTower", root,
	function( )
		--blipsTwr[ client ] = source
		blips[ client ] = source
		exclude[ client ] = true
		triggerClientEvent(client, "sfia:airtrack:blips", client, blips)
	end
)

function off( player )
	local vehicle = blips[ player ]
	blips[ player ] = nil
	
	for player in pairs( blips ) do
		if vehicle then
			triggerClientEvent( player, "sfia:airtrack:off", vehicle )
		end
	end
end

addEvent( "sfia:airtrack:off", true )
addEventHandler( "sfia:airtrack:off", root,
	function( )
		off( client )
	end
)
addEventHandler( "onPlayerQuit", root,
	function( )
		off( source )
	end
)

function enterVehicle(thePlayer, seat, jacked) --show radar when entering an aircraft (as aircrafts would have this in cockpit)
	local vehType = getVehicleType(source)
	if(vehType == "Plane" or vehType == "Helicopter") then
		if(seat == 0 or seat == 1) then
			setPlayerHudComponentVisible(thePlayer, "radar", true)
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), enterVehicle)
function exitVehicle(thePlayer, seat, jacked)
	local vehType = getVehicleType(source)
	if(vehType == "Plane" or vehType == "Helicopter") then
		if not exports.global:hasItem(thePlayer, 111) then --hide radar if player dont have the gps item
			setPlayerHudComponentVisible(thePlayer, "radar", false)
		end
	end
end
addEventHandler("onVehicleStartExit", getRootElement(), exitVehicle)

--
-- exported for chat-system
--
function getPlayersInAircraft( )
	local t = {}
	for k, v in ipairs( getElementsByType( "player" ) ) do
		local vehicle = getPedOccupiedVehicle( v )
		if vehicle then
			if trackingMinHeight[ getElementModel( vehicle ) ] then
				table.insert( t, v )
			end
		end
	end
	return t
end
