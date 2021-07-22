-- Backup Truck - Beeping Sound (By Cyanide)

local soundElement = { }

local beepingTrucksArray = -- Removed SAN vehicles because of Fields.
{ 
	[486] = true, -- Dozer
	[406] = true, -- Dumper
	[573] = true, -- Dune
	[455] = true, -- FlatBed
	[407] = true, -- FireTruck
	[427] = true, -- Enforcer
	[416] = true, -- Ambulance
	[578] = true, -- DFT
	[544] = true, -- Firetruck (Ladder)
	[456] = true, -- Yankee
	[414] = true, -- Mule
	[515] = true, -- RoadTrain
	[403] = true, -- LineRunner
	[514] = true, -- LineRunner (Tank Commando thing)
	[525] = true, -- Towtruck
	[443] = true  -- Packer
}

function isVehicleThatBeeps( vehicleModel )
	return beepingTrucksArray[getElementModel( vehicleModel )]
end

function doBeep()
	local localPlayer = getLocalPlayer( )

	local elementVehicle = getPedOccupiedVehicle ( localPlayer )
	
	if not elementVehicle then
		if getElementData( localPlayer, "backupbleepers:goingBackwards" ) then
			setElementData( localPlayer, "backupbleepers:goingBackwards", false )	
		end
		return false
	end
	if beepingTrucksArray[getElementModel(elementVehicle)] and (isObjectGoingBackwards(elementVehicle, true)) then
		setElementData( localPlayer, "backupbleepers:goingBackwards", true )
	elseif getElementData( localPlayer, "backupbleepers:goingBackwards" ) and not isObjectGoingBackwards(elementVehicle, true) then
		setElementData( localPlayer, "backupbleepers:goingBackwards", false )
	end
end

addEventHandler( "onClientResourceStart", getResourceRootElement( ),  -- getElementRoot() makes it trigger for every loaded resource...
	function() 
		setTimer( doBeep, 400, 0 ) 
	end 
)

addEventHandler ( "onClientElementDataChange", getRootElement(),
	function ( elementData )
	
		if elementData ~= "backupbleepers:goingBackwards" then
			return false
		end
		
		if not getPedOccupiedVehicle(source) then
			return false
		end

		if not isVehicleThatBeeps( getPedOccupiedVehicle( source ) ) then
			return false
		end
		
		for idx, i in ipairs(getElementsByType( "player" )) do -- Looping through all players to attach the sound.
			local
				elementVehicle = getPedOccupiedVehicle ( i )
				
			if getElementData( i, "backupbleepers:goingBackwards" ) then -- if goingBackwards was set to true.
				if not soundElement[elementVehicle] then
					local x, y, z = getElementPosition(elementVehicle)
					soundElement[elementVehicle]  =  playSound3D( "TruckBackingUpBeep.mp3", x, y, z, true )
					attachElements( soundElement[elementVehicle], elementVehicle )
		
				end
			elseif not getElementData( i, "backupbleepers:goingBackwards" ) then -- if goingBackwards was set to false.
				if isElement(soundElement[elementVehicle]) then
					stopSound(soundElement[elementVehicle])
				end
				soundElement[elementVehicle] = nil
			end
		end
	end 
)

function isObjectGoingBackwards( theVehicle, second )
	if not theVehicle or not isElement (theVehicle) or not getVehicleOccupant ( theVehicle, 0 ) or not getPedControlState(localPlayer, "brake_reverse") then
		return false
	end

	x, y, z = getElementVelocity ( theVehicle )
	z = ( function( a, b, c ) return c end ) ( getElementRotation ( theVehicle ) )
	local returnValue = false

	if x == 0 or y == 0 then
		return false
	end
	
	local xx, yy, zz = getElementRotation( theVehicle )
	
	if (xx == 90 or yy == 90) or (xx == 180 or yy == 180) or (xx == 270 or yy == 270) or (xx == 0 or yy == 0) then
		return false
	end
	
	if z > 0 and z < 90 and not (x < 0 and y > 0) then -- Front left
		--outputDebugString("a x:"..x.." y:"..y.." z:"..z)
		returnValue = true
	elseif z > 90 and  z < 180 and not (x < 0 and y < 0) then -- Back left
		--outputDebugString("B x:"..x.." y:"..y.." z:"..z)
		returnValue = true
	elseif  z > 180 and z < 270 and not (x > 0 and y < 0) then -- Back right
		--outputDebugString("c x:"..x.." y:"..y.." z:"..z)
		returnValue = true
	elseif  z > 270 and z < 360 and not (x > 0 and y > 0) then -- Back right
		--outputDebugString("d x:"..x.." y:"..y.." z:"..z)
		returnValue = true
	end  
	
	if not second then
		returnValue = isObjectGoingBackwards( theVehicle, true )
	end	
	
	return returnValue
end
