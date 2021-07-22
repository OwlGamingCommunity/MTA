--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local function canPlayerStartEngine( veh, player )
	-- civ vehicles
	local dbid = getElementData(veh, "dbid") or -1
	if dbid < 0 then
		return true
	end

	-- job vehicles
	if ( getElementData(veh, 'job') or 0 ) ~= 0 then
		return true
	end

	-- DoL cars
	if not getElementData( veh, "owner" ) or getElementData( veh, "owner" ) == -2 then
		if getElementData( player, "license.car.cangetin" ) and getElementModel( veh ) == 410 and getElementData( player ,"license.car") == 3 then
			return true
		elseif getElementData( player, "license.bike.cangetin" ) and getElementModel( veh ) == 468 and getElementData( player ,"license.bike") == 3 then
			return true
		end
	end

	-- admin on duty
	if exports.integration:isPlayerTrialAdmin( player, true ) or exports.integration:isPlayerSupporter(player, true) then
		return true
	end

	-- faction vehicles
	local vfact = tonumber( getElementData(veh, "faction") or -1 )
	if vfact ~= -1 and exports.factions:isPlayerInFaction(player, vfact) then
		return true
	end

	-- if has already been hotwired
	if getElementData(veh, "hotwired") then 
		return true
	end
	
	-- has key
	return exports.global:hasItem( player, 3, dbid ) or exports.global:hasItem( veh, 3, dbid )
end

function toggleEngine( )
	local veh = getPedOccupiedVehicle( localPlayer )
	if veh and getElementData( localPlayer, "realinvehicle" ) == 1 then
		if getPedOccupiedVehicleSeat( localPlayer ) == 0 then
			if not enginelessVehicle[ getElementModel( veh ) ] then
				if getVehicleEngineState( veh ) then
					setVehicleEngineState( veh, false ) -- client side, need to do once more on server to sync.
					triggerServerEvent( 'vehicle:engine:stop', resourceRoot, veh )
					toggleControl( 'accelerate', false )
					toggleControl( 'brake_reverse', false )
				else
					if canPlayerStartEngine( veh, localPlayer ) then
						triggerServerEvent( 'vehicle:engine:start', resourceRoot, exports.global:getNearbyElements( veh, 'player' ), veh )
					else
						exports.hud:sendBottomNotification( localPlayer, exports.global:getVehicleName( veh ), "You require a key to start this vehicle." )
						playSoundFrontEnd(4)
					end
				end
			end
		end
	end
end
addEvent( 'vehicle:toggleEngine', false )
addEventHandler( 'vehicle:toggleEngine', root, toggleEngine )

addEventHandler( 'onClientResourceStart', resourceRoot, function()
	bindKey( "j", "down", toggleEngine )
end)

-- Disable engine and vehicle control state as soon as player starts getting in or get in vehicles. Because by default in GTA, vehicle get started automatically when player gets in.
-- Disable them first then enable them from server as soon as possible.
addEventHandler( 'onClientVehicleStartEnter', root, function( player, seat, door )
	if player == localPlayer and seat == 0 then
		if enginelessVehicle[ getElementModel(source) ] then
			toggleControl( 'accelerate', true )
			toggleControl( 'brake_reverse', true )
		else
			toggleControl( 'accelerate', false )
			toggleControl( 'brake_reverse', false )
		end
	end
end)

addEventHandler( 'onClientVehicleEnter', root, function( player , seat )
	if player == localPlayer and seat == 0 and not enginelessVehicle[ getElementModel(source) ] then
		setVehicleEngineState( source, false )
	end
end)
