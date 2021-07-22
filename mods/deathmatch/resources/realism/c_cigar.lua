local l_cigar = { }
local r_cigar = { }
local deagle = { }
local isLocalPlayerSmokingBool = false
function setSmoking(player, state, hand)
	setElementData(player,"smoking",state, false)
	if not (hand) or (hand == 0) then
		setElementData(player, "smoking:hand", 0, false)
	else
		setElementData(player, "smoking:hand", 1, false)
	end

	if (isElement(player)) then
		if (state) then
			playerExitsVehicle(player)
		else
			playerEntersVehicle(player)
		end
	end
end

function playerExitsVehicle(player)
	if (getElementData(player, "smoking")) then
		playerEntersVehicle(player)
		if (getElementData(player, "smoking:hand") == 1) then
			r_cigar[player] = createCigarModel(player, 3027)
		else
			l_cigar[player] = createCigarModel(player, 3027)
		end
	end
end

function playerEntersVehicle(player)
	if (l_cigar[player]) then
		if (isElement( l_cigar[player] )) then
			destroyElement( l_cigar[player] )
		end
		l_cigar[player] = nil
	end
	if (r_cigar[player]) then
		if (isElement( r_cigar[player] )) then
			destroyElement( r_cigar[player] )
		end
		r_cigar[player] = nil
	end
end

function removeSigOnExit()
	playerExitsVehicle(source)
end
addEventHandler("onPlayerQuit", getRootElement(), removeSigOnExit)

function syncCigarette(state, hand)
	if (isElement(source)) then
		if (state) then
			setSmoking(source, true, hand)
		else
			setSmoking(source, false, hand)
		end
	end
end
addEvent( "realism:smokingsync", true )
addEventHandler( "realism:smokingsync", getRootElement(), syncCigarette, righthand )

addEventHandler( "onClientResourceStart", getResourceRootElement(),
	function ( startedRes )
		triggerServerEvent("realism:smoking.request", getLocalPlayer())
	end
);

function createCigarModel(player, modelid)
	if (l_cigar[player] ~= nil) then
		local currobject = l_cigar[player]
		if (isElement(currobject)) then
			destroyElement(currobject)
			l_cigar[player] = nil
		end
	end
	
	local object = createObject(modelid, 0,0,0)

	setElementCollisionsEnabled(object, false)
	return object
end

function updateCig()
	isLocalPlayerSmokingBool = false
	-- left hand
	for thePlayer, theObject in pairs(l_cigar) do
		if (isElement(thePlayer)) then
			if (thePlayer == getLocalPlayer()) then
				isLocalPlayerSmokingBool = true
			end
			local bx, by, bz = getPedBonePosition(thePlayer, 36)
			local x, y, z = getElementPosition(thePlayer)
			local r = getPedRotation(thePlayer)
			local dim = getElementDimension(thePlayer)
			local int = getElementInterior(thePlayer)
			r = r + 300
			if (r > 360) then
				r = r - 360
			end
			
			local ratio = r/360
		
			--moveObject ( theObject, 1, bx, by, bz )
			--setElementPosition(theObject, bx - 0.04, by + 0.06, bz - 0.06)
			setElementPosition(theObject, bx, by, bz)
			setElementRotation(theObject, 60, 270, r)
			setElementDimension(theObject, dim)
			setElementInterior(theObject, int)
		end
	end

	-- right hand
    for thePlayer, theObject in pairs(r_cigar) do
        if (isElement(thePlayer)) then
            if (thePlayer == getLocalPlayer()) then
                isLocalPlayerSmokingBool = true
            end
            local bx, by, bz = getPedBonePosition(thePlayer, 26)
            local x, y, z = getElementPosition(thePlayer)
            local r = getPedRotation(thePlayer)
            local dim = getElementDimension(thePlayer)
            local int = getElementInterior(thePlayer)
            r = r + 100
            if (r > 360) then
                r = r - 360
            end
            
            local ratio = r/360
        
            --moveObject ( theObject, 1, bx, by, bz )
            setElementPosition(theObject, bx, by, bz)
            setElementRotation(theObject, -60, 50, r-60)
            setElementDimension(theObject, dim)
            setElementInterior(theObject, int)
        end
    end 
end
addEventHandler("onClientPreRender", getRootElement(), updateCig)

function isLocalPlayerSmoking()
	return isLocalPlayerSmokingBool
end