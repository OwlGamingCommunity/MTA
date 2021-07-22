local stretcherArray = { }

function hasPlayerStretcherSpawned( playerElement )
	return isElement(playerElement) and stretcherArray[playerElement] and true or false
end
addEvent( "stretcher:hasPlayerStretcherSpawned", true )
addEventHandler( "stretcher:hasPlayerStretcherSpawned", getRootElement( ), hasPlayerStretcherSpawned )

function isPedStretcherOccupied( playerElement )
	return (getElementData(  stretcherArray[ playerElement ], "realism:stretcher:playerOnIt") and isElement(getElementData(  stretcherArray[ playerElement ], "realism:stretcher:playerOnIt"))) --and getElementAttachedTo ( stretcherArray[ playerElement ] ) == getElementData(  stretcherArray[ playerElement ], "realism:stretcher:playerOnIt")
end
addEvent( "stretcher:isPedStretcherOccupied", true )
addEventHandler( "stretcher:isPedStretcherOccupied", getRootElement( ), isPedStretcherOccupied )

function destroyStretcher( playerElement, vehicle )

	if not playerElement and source then
		playerElement = source
	end

	if  stretcherArray[ playerElement ] then
		if vehicle and isElement(vehicle) then
			local patient = getElementData(stretcherArray[playerElement], "realism:stretcher:playerOnIt")
			--outputDebugString("patient="..tostring(patient).." element="..tostring(isElement(patient)))
			--outputDebugString("attachedTo="..tostring(getElementAttachedTo(stretcherArray[playerElement])))
			if(isElement(patient)) then --and getElementAttachedTo(stretcherArray[playerElement]) == patient
				takePedFromStretcher(patient, playerElement)
				local patientSeats = {2,3,4,5,1}
				local warpResult = false
				for k,v in ipairs(patientSeats) do
					warpResult = warpPedIntoVehicle(patient, vehicle, v)
					if warpResult then
						break
					end
				end
				--outputDebugString("warpResult="..tostring(warpResult))
				if not warpResult then
					outputChatBox("The "..tostring(exports.global:getVehicleName(vehicle)).." does not have space for any more patients.", playerElement, 255, 0, 0)
				else
					setElementData(patient, "realism:stretcher:isInAmbulanceOnStretcher", true, true)
				end
			end
		end
		detachElements( stretcherArray[ playerElement ], playerElement )
		destroyElement( stretcherArray[ playerElement ] )
		stretcherArray[ playerElement ] = false
		setElementData(playerElement, "realism:stretcher:hasStretcher", false, true)
		return true
	end
	return false
end
addEvent( "stretcher:destroyStretcher", true )
addEventHandler( "stretcher:destroyStretcher", getRootElement( ), destroyStretcher )

function leaveStretcher( playerElement )

	if not playerElement and source then
		playerElement = source
	end

	if  stretcherArray[ playerElement ] then
		triggerClientEvent( playerElement, "stretcher:getPositionInFrontOfElement", getRootElement( ), playerElement, false, "leave" )
	end
end
addEvent( "stretcher:leaveStretcher", true )
addEventHandler( "stretcher:leaveStretcher", getRootElement( ), leaveStretcher )

function takeStretcher( stretcher, playerElement )

	if not playerElement and source then
		playerElement = source
	end

	if  isElement(stretcher) and getElementType(stretcher) == "object" then
		if not stretcherArray[playerElement] then
			stretcherArray[ playerElement ] = stretcher
			triggerClientEvent( playerElement, "stretcher:getPositionInFrontOfElement", getRootElement( ), playerElement, false, "take" )
		end
	end
end
addEvent( "stretcher:takeStretcher", true )
addEventHandler( "stretcher:takeStretcher", getRootElement( ), takeStretcher )

function createStretcher( playerElement, vehicle )
	if not playerElement and source then
		playerElement = source
	end

	if (getPedOccupiedVehicle(playerElement)) then
		return
	end

	if hasPlayerStretcherSpawned( playerElement ) then
		if vehicle then
			exports.global:sendLocalMeAction(playerElement, "puts the stretcher inside the "..tostring(exports.global:getVehicleName(vehicle))..".")
		else
			exports.global:sendLocalMeAction(playerElement, "puts the stretcher inside.")
		end
		destroyStretcher( playerElement, vehicle )
	else
		if vehicle then
			exports.global:sendLocalMeAction(playerElement, "takes out a stretcher from the "..tostring(exports.global:getVehicleName(vehicle))..".")
		else
			exports.global:sendLocalMeAction(playerElement, "takes out a stretcher.")
		end
		triggerClientEvent( playerElement, "stretcher:getPositionInFrontOfElement", getRootElement( ), playerElement, vehicle )
	end
end
addEvent( "stretcher:createStretcher", true )
addEventHandler( "stretcher:createStretcher", getRootElement( ), createStretcher )

function getPositionInFrontOfElement( playerElement, x, y, z, vehicle, action )
	if(action == "leave") then
		if(isElement(stretcherArray[playerElement])) then
			setElementCollisionsEnabled(stretcherArray[ playerElement ], true)
			detachElements( stretcherArray[ playerElement ], playerElement )
			setElementPosition(stretcherArray[playerElement], x, y, z - 0.5)
			local rz, rx, ry = getElementRotation(playerElement, "ZXY")
			setElementRotation(stretcherArray[playerElement], rz, rx, ry, "ZXY")

			stretcherArray[ playerElement ] = false
			setElementData(playerElement, "realism:stretcher:hasStretcher", false, true)
		else
			stretcherArray[playerElement] = false
		end
	elseif(action == "take") then
		if(isElement(stretcherArray[playerElement])) then
			setElementPosition(stretcherArray[playerElement], x, y, z - 0.5)
			setElementRotation(stretcherArray[playerElement], 0, 0, 0)
			attachElements(stretcherArray[playerElement], playerElement, 0, 0, -0.5)
			local attach_x, attach_y, attach_z = getElementPosition( stretcherArray[ playerElement ] )
			detachElements( stretcherArray[ playerElement ], playerElement )
			distance = getDistanceBetweenPoints2D( x, y, attach_x, attach_y )
			attachElements( stretcherArray[ playerElement ], playerElement, 0, distance, -0.5 )
			setElementCollisionsEnabled(stretcherArray[ playerElement ], false)
			-- Used for tracking clientside
			setElementData(playerElement, "realism:stretcher:hasStretcher",  stretcherArray[ playerElement ], true)
			setElementData(stretcherArray[ playerElement ], "realism:stretcher:ownedBy", playerElement, true)
		else
			stretcherArray[playerElement] = false
		end
	else
		if not hasPlayerStretcherSpawned( playerElement ) then
			stretcherArray[ playerElement ] = createObject ( 2146, x, y, z - 0.5, 0, 0, 0 )
			attachElements( stretcherArray[ playerElement ], playerElement, 0, 0, -0.5 )
			local attach_x, attach_y, attach_z = getElementPosition( stretcherArray[ playerElement ] )
			detachElements( stretcherArray[ playerElement ], playerElement )
			distance = getDistanceBetweenPoints2D( x, y, attach_x, attach_y )
			attachElements( stretcherArray[ playerElement ], playerElement, 0, distance, -0.5 )
			setElementCollisionsEnabled(stretcherArray[ playerElement ], false)
			-- Used for tracking clientside
			--outputDebugString(tostring(stretcherArray[playerElement]))
			setElementData(playerElement, "realism:stretcher:hasStretcher",  stretcherArray[ playerElement ], true)
			setElementData(  stretcherArray[ playerElement ], "realism:stretcher:ownedBy", playerElement, true)

			if vehicle and isElement(vehicle) then
				local patient = false
				local passengers = getVehicleOccupants(vehicle)
				--outputDebugString("#passengers="..tostring(#passengers).." : "..tostring(passengers))
				for k,v in pairs(passengers) do
					if(k ~= 0) then
						--outputDebugString("k is not 0 but "..tostring(k))
						--outputDebugString(tostring(getElementData(v, "realism:stretcher:isInAmbulanceOnStretcher")))
						if getElementData(v, "realism:stretcher:isInAmbulanceOnStretcher") then
							patient = v
							break
						end
					end
				end
				if patient then
					removePedFromVehicle(patient)
					movePedOntoStretcher(patient, playerElement)
					setElementData(patient, "realism:stretcher:isInAmbulanceOnStretcher", false, true)
				end
			end
		end
	end
end
addEvent( "stretcher:getPositionInFrontOfElement", true )
addEventHandler( "stretcher:getPositionInFrontOfElement", getRootElement( ), getPositionInFrontOfElement )

function setStretcherInterior(player, interior, dimension)
	if stretcherArray[player] then
		--outputDebugString("is stretcher")
		if(isElement(stretcherArray[player])) then
			--outputDebugString("is stretcher element")
			if interior then
				--outputDebugString("int")
				setElementInterior(stretcherArray[player], interior)
			end
			if dimension then
				--outputDebugString("dim")
				setElementDimension(stretcherArray[player], dimension)
			end
			--outputDebugString("occupied="..tostring(isPedStretcherOccupied(player)))
			if isPedStretcherOccupied(player) then
				--outputDebugString("is occupied")
				local patient = getElementData(stretcherArray[player], "realism:stretcher:playerOnIt")
				if(isElement(patient)) then --and getElementAttachedTo(stretcherArray[player]) == patient
					--outputDebugString("patient is element")
					--if interior then
					--	setElementInterior(patient, interior)
					--end
					--if dimension then
					--	setElementDimension(patient, dimension)
					--end
					local interiortable = {false, false, false, interior, dimension}
					triggerClientEvent(patient, "setPlayerInsideInterior", getRootElement(), interiortable, getRootElement())
				end
			end
		end
	end
end

addEventHandler("onPlayerInteriorChange", getRootElement( ),
	function( toInterior, toDimension)
		setStretcherInterior(client, toInterior, toDimension)
	end
)


function checkPedEnterVehicleWithStretcher( clientid )
	if hasPlayerStretcherSpawned( clientid ) then
		cancelEvent( ) -- Cannot enter a vehicle with a stretcher
	end
end
addEventHandler ( "onVehicleStartEnter", getRootElement(), checkPedEnterVehicleWithStretcher )

function movePedOntoStretcher(	targetElement, playerElement )
	if not source and playerElement then
		source = playerElement
	end
	if not targetElement or not isElement(targetElement) then
		return false -- Target player does not exist
	end

	if not hasPlayerStretcherSpawned( source ) then
		return false -- Stretcher does not exist
	end
	if getPedOccupiedVehicle( targetElement ) then
		return false -- Target player is in a vehicle :(
	end
	if isPedStretcherOccupied( source ) then
		return false -- Stretcher already in use.
	end


	local sourceX, sourceY, sourceZ = getElementPosition(source)
	local targetX, targetY, targetZ = getElementPosition(targetElement)
	if getDistanceBetweenPoints3D(sourceX, sourceY, sourceZ, targetX, targetY, targetZ ) > 10 then
		return false -- Far distance between the two players
	end

	attachElements( targetElement, stretcherArray[ source ], 0, 0, 1.5 )
	exports.global:applyAnimation( targetElement, "CRACK", "crckdeth2", -1, true )
	setElementData(  stretcherArray[ source ], "realism:stretcher:playerOnIt", targetElement, true )

end
addEvent( "stretcher:movePedOntoStretcher", true )
addEventHandler( "stretcher:movePedOntoStretcher", getRootElement( ), movePedOntoStretcher )

function takePedFromStretcher(	targetElement, playerElement )
	if not source and playerElement then
		source = playerElement
	end
	if not targetElement or not isElement(targetElement) then
		return false -- Target player does not exist
	end

	if not hasPlayerStretcherSpawned( source ) then
		return false -- Stretcher does not exist
	end

	if getPedOccupiedVehicle( targetElement ) then
		return false -- Target player is in a vehicle :(
	end

	local sourceX, sourceY, sourceZ = getElementPosition(source)
	local targetX, targetY, targetZ = getElementPosition(targetElement)
	if getDistanceBetweenPoints3D(sourceX, sourceY, sourceZ,  targetX, targetY, targetZ ) > 10 then
		return false -- Far distance between the two players
	end

	detachElements( targetElement, stretcherArray[ source ], 0, 0, 1.5 )
	exports.global:removeAnimation(targetElement)
	setElementData(  stretcherArray[ source ], "realism:stretcher:playerOnIt", false, false )
end
addEvent( "stretcher:takePedFromStretcher", true )
addEventHandler( "stretcher:takePedFromStretcher", getRootElement( ), takePedFromStretcher )
