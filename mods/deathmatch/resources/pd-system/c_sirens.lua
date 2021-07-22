local sounds = { }

-- Bind Keys required
function bindKeys(res)
    bindKey("n", "both", toggleSirens)
    bindKey(",", "both", cycleSirens)
    bindKey(".", "both", cycleSirens)

    for key, value in ipairs(getElementsByType("vehicle")) do
        if isElementStreamedIn(value) then
            if getElementData(value, "lspd:siren") then
                sounds[value] = playSound3D("sirens/" .. getElementData( value, "lspd:siren" ) ..".wav", 0, 0, 0, true)
                setElementDimension(sounds[value], getElementDimension(value))
                setElementInterior(sounds[value], getElementInterior(value))
                attachElements( sounds[value], value )
                setSoundVolume(sounds[value], 0.4)
                setSoundMaxDistance(sounds[value], 180)
            end
        end
    end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), bindKeys)

function toggleSirens(_, state)
   local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
   if (theVehicle) then
        local occupants = getVehicleOccupants(theVehicle)
        if occupants[0]==getLocalPlayer() then
        	if state == "up" then
        		if isTimer(horn) then
        			killTimer(horn)
        		end
        		if not getVehicleSirensOn(theVehicle) and getElementData(theVehicle, "lspd:siren") then
        			sirenType = false
        		elseif getVehicleSirensOn(theVehicle) and getElementData(theVehicle, "lspd:siren") ~= 4 then
        			sirenType = false
        		else
        			sirenType = "wail"
        		end
            	triggerServerEvent("lspd:setSirenState", theVehicle, sirenType)
            elseif state == "down" then
            	horn = setTimer( triggerServerEvent, 300, 1, "lspd:setSirenState", theVehicle, "horn" )
            end
        end
    end
end
addCommandHandler("togglesirens", toggleSirens, false)

function streamIn()
    if getElementType( source ) == "vehicle" and getElementData( source, "lspd:siren" ) and not sounds[ source ] then
        sounds[source] = playSound3D("sirens/" .. getElementData( source, "lspd:siren" ) ..".wav", 0, 0, 0, true)
        setElementDimension(sounds[source], getElementDimension(source))
        setElementInterior(sounds[source], getElementInterior(source))
        attachElements( sounds[source], source )
        setSoundVolume(sounds[source], 0.4)
        setSoundMaxDistance(sounds[source], 250)
    end
end
addEventHandler("onClientElementStreamIn", getRootElement(), streamIn)

function streamOut()
    if getElementType( source ) == "vehicle" and sounds[source] then
        destroyElement( sounds[ source ] )
        sounds[ source ] = nil
    end
end
addEventHandler("onClientElementStreamOut", getRootElement(), streamOut)

function cycleSirens( key, state )
   local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
   if (theVehicle) then
        local occupants = getVehicleOccupants(theVehicle)
        if occupants[0]==getLocalPlayer() and getElementData(theVehicle, "lspd:siren") and getElementData(theVehicle, "lspd:siren") ~= 4 then
			if (key == "," or key == ".") and state == "up" then
				triggerServerEvent("lspd:setSirenState", theVehicle, "wail")
			elseif key == "," and state == "down" then
				triggerServerEvent("lspd:setSirenState", theVehicle, "priority")
			elseif key == "." and state == "down" then
				triggerServerEvent("lspd:setSirenState", theVehicle, "yelp")
			end
		end
	end
end

function UpdateSiren( name )
    if name == "lspd:siren" and getElementType( source ) == "vehicle" then
        if not getElementData( source, name ) then
            if sounds[ source ] then
                destroyElement( sounds[ source ] )
                sounds[ source ] = nil
            end
        else
            if sounds[ source ] then
                destroyElement( sounds[ source ] )
                sounds[ source ] = nil
            end
            --outputChatBox( getVehicleModel( source))
            if getElementModel( source ) == 523 then -- disabled double audio on siren for HPV
              return
            end
            sounds[source] = playSound3D("sirens/" .. getElementData( source, "lspd:siren" ) ..".wav", 0, 0, 0, true)
            setElementDimension(sounds[source], getElementDimension(source))
            setElementInterior(sounds[source], getElementInterior(source))
            attachElements( sounds[source], source )
            setSoundVolume(sounds[source], 0.4)
            setSoundMaxDistance(sounds[source], 250)
        end
    end
end
addEventHandler("onClientElementDataChange", getRootElement(), UpdateSiren)
