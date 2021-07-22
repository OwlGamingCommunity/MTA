local heli = nil

function updateRotor()
	if isElement(heli) then
		if not getVehicleEngineState( heli ) and getHelicopterRotorSpeed( heli ) > 0 then
			local new = getHelicopterRotorSpeed( heli ) - 0.0012
			setHelicopterRotorSpeed( heli, math.max( 0, new ) )
		end
	else
		disableRotorUpdate()
	end
end

function disableRotorUpdate()
	if heli then
		heli = nil
		removeEventHandler( "onClientPlayerVehicleExit", getLocalPlayer(), disableRotorUpdate )
		removeEventHandler( "onClientPreRender", getRootElement(), updateRotor ) -- Pre
	end
end

function enableRotorUpdate( theVehicle )
	if getVehicleType( theVehicle ) == "Helicopter" then
		heli = theVehicle
		
		addEventHandler( "onClientPlayerVehicleExit", getLocalPlayer(), disableRotorUpdate )
		addEventHandler( "onClientPreRender", getRootElement(), updateRotor ) -- Pre
	end
end
addEventHandler( "onClientPlayerVehicleEnter", getLocalPlayer(), enableRotorUpdate )