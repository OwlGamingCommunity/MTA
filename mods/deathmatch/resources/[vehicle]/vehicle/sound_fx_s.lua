--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function blinkLightsAndSoundOnLockUnlock(theVehicle)
	if getVehicleType(theVehicle) == "Automobile" then
		local speed = 500
		setVehicleOverrideLights ( theVehicle, 1 )
		setTimer(setVehicleOverrideLights, speed, 1, theVehicle, 2 )
		setTimer(setVehicleOverrideLights, speed*2, 1, theVehicle, 1)
		exports.anticheat:setEld( theVehicle, 'lights', 0 , 'all' )
		for i, player in pairs( exports.global:getNearbyElements( theVehicle, 'player' ) ) do
			triggerClientEvent( player, "playCarToglockSoundFX", theVehicle )
		end
	end
end

function playCarToglockSoundFxInside(theVehicle, lockState)
	if getVehicleType(theVehicle) == "Automobile" then
		for i = 0, getVehicleMaxPassengers( theVehicle ) do
			local player = getVehicleOccupant( theVehicle, i )
			if player then
				triggerClientEvent( player, "playCarToglockSoundFxInside", resourceRoot, lockState )
			end
		end
	end
end

local function playHorn ( thePlayer, key, keyState )
    local theVehicle = getPedOccupiedVehicle ( thePlayer )
    if ( not theVehicle ) then
       return
    end

    if ( getElementModel ( theVehicle ) == 537 ) or ( getElementModel( theVehicle ) == 538 ) then
        triggerClientEvent ( "vehicleHorn", root, ( keyState == "down" and true or false ), theVehicle )
    end
end

addEventHandler ( "onResourceStart", resourceRoot,
    function ( )
        for _, player in ipairs ( getElementsByType ( "player" ) ) do
            bindKey ( player, "H", "down", playHorn )
            bindKey ( player, "H", "up", playHorn )
        end
    end
    )

addEventHandler ( "onPlayerJoin", root,
    function ( )
        bindKey ( source, "H", "down", playHorn )
        bindKey ( source, "H", "up", playHorn )
    end
)
