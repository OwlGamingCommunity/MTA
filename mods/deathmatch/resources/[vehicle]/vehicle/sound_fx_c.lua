--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function playCarToglockSoundFX()
	local sound = playSound3D( "sounds/CarAlarmChirp.mp3", getElementPosition( source ) )
	if sound then
		setSoundMaxDistance( sound, 50 )
		setSoundVolume( sound, 0.7 )
		setElementInterior( sound, getElementInterior( source ) )
		setElementDimension( sound, getElementDimension( source ) )
	end
end
addEvent("playCarToglockSoundFX", true)
addEventHandler("playCarToglockSoundFX", root, playCarToglockSoundFX)

function playCarToglockSoundFxInside(lockState)
	playSound(lockState and "sounds/car_lock_inside.mp3" or "sounds/car_unlock_inside.mp3")
end
addEvent("playCarToglockSoundFxInside", true)
addEventHandler("playCarToglockSoundFxInside", resourceRoot, playCarToglockSoundFxInside)

addEvent ( "vehicleHorn", true )
addEventHandler ( "vehicleHorn", root,
    function ( state, theVehicle )
        if isElement ( TrainSound ) and ( state ) then
        	if isTimer(decrease) then
        		killTimer(decrease)
        	end
        	destroyElement(TrainSound)
        end

        if not ( state ) then
        	decrease = setTimer(function()
        		local time, final = getTimerDetails(decrease)
        		if isElement(TrainSound) then
        			if final ~= 1 then
        				local volume = getSoundVolume(TrainSound);
        				setSoundVolume(TrainSound, volume-0.5);
        			else
        				destroyElement(TrainSound)
        			end
        		end

        		end, 300, 10)
        end
            --stopSound ( TrainSound )
        if ( state ) then
            local x, y, z = getElementPosition ( theVehicle )
            TrainSound = playSound3D ( 'sounds/trainHorn.mp3', x, y, z )
            setSoundVolume ( TrainSound, 5.0 )
            setSoundMaxDistance ( TrainSound, 300 )
            attachElements ( TrainSound, theVehicle )
        end
    end
)

local sounds = { }
local function playSoundEngineStart( veh, sound )
    -- destroy the previous sound for this vehicle if any.
    if sounds[ veh ] and isElement( sounds[ veh ] ) then
        destroyElement( sounds[ veh ] )
        sounds[ veh ] = nil
    end

    -- start new sound.
    if sound then
        sounds[ veh ] = playSound3D( sound, getElementPosition( veh ) )
        if sounds[ veh ] then
            setElementInterior( sounds[ veh ], getElementInterior( veh ) )
            setElementDimension( sounds[ veh ], getElementDimension( veh ) )
            attachElements( sounds[ veh ], veh )
        end
    end
end
addEvent( 'vehicle:engine:start:sound', true )
addEventHandler( 'vehicle:engine:start:sound', resourceRoot, playSoundEngineStart )
