local isFlashing = { } 
local flash = { }
local Timer = { }
local carTimer = { }
local phaseCruiser = { }

phase = 0

function triggerStrobesClient(theCruiser)
	local defaultLight = getVehicleOverrideLights(theCruiser)
	if ( not isFlashing[ theCruiser ] ) then
		setVehicleOverrideLights(theCruiser, 2)
		phaseCruiser [ theCruiser ] = 1
		isFlashing [ theCruiser ] = true
		Timer [ theCruiser ] = setTimer(toggleSwitch, 250, 0, theCruiser)
	else
		killTimer(Timer[ theCruiser ])
		isFlashing[ theCruiser ] = nil
		setVehicleOverrideLights(theCruiser, defaultLight)
		setVehicleLightState(theCruiser, 0, 0)
		setVehicleLightState(theCruiser, 1, 0)
		phaseCruiser [ theCruiser ] = 0
	end
end
--addCommandHandler("togglestrobes", triggerStrobesClient)
addEvent("flashOn", true)
addEventHandler("flashOn", getRootElement(), triggerStrobesClient)

function toggleSwitch(theCruiser)
	if phaseCruiser [ theCruiser ] == 1 then
		setVehicleLightState(theCruiser, 0, 0)
		setVehicleLightState(theCruiser, 1, 1)
		carTimer[ theCruiser ] = setTimer ((function() phaseCruiser [ theCruiser ] = 2 end), 50, 1)
	end
	if phaseCruiser [ theCruiser ] == 2 then
		setVehicleLightState(theCruiser, 0, 1)
		setVehicleLightState(theCruiser, 1, 0)
		carTimer[ theCruiser ] = setTimer ((function() phaseCruiser [ theCruiser ] = 1 end), 50, 1)
	end
end
