
function triggerStrobesServer(thePlayer)
	if getPedOccupiedVehicleSeat( thePlayer )== 0 then
		local theVehicle = getPedOccupiedVehicle( thePlayer )
		local hasStrobe = false
		if exports["item-system"]:hasItem(theVehicle, 61) or exports["item-system"]:hasItem(theVehicle, 140) or exports["item-system"]:hasItem(theVehicle, 144) then -- strobes
			hasStrobe = true
			--outputDebugString("had")
		end
		if ( getVehicleName( theVehicle ) == 'Police LV' ) or ( getVehicleName( theVehicle ) == 'Police SF' ) or ( getVehicleName( theVehicle ) == 'FBI rancher' ) or ( getVehicleName( theVehicle ) == 'Police LS' ) or hasStrobe then
		    for key, player in ipairs ( getElementsByType('player') ) do
                triggerClientEvent( player, 'flashOn', player, theVehicle ) -- Passing the Police cruiser client side too!
            end
		end
	end
end

-- [ Bind the key to all players server-side ]
function bindSirenKey( )
    for key, allPlayers in ipairs ( getElementsByType('player') ) do
        bindKey( allPlayers, 'x', 'down', triggerStrobesServer )
    end    
end
--addEventHandler('onResourceStart', resourceRoot, bindSirenKey )


--addCommandHandler("togglestrobes", triggerStrobesServer)
