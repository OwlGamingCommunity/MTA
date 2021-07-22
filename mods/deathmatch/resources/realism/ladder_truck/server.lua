part1 = {}
part2 = {}
part3 = {}
part4 = {}
a = {}

-- Begin of Ladder Truck parts
function collisionLad ()
    local vehicles = getElementsByType("vehicle")
    for i,a in ipairs(vehicles) do
        if (getElementModel(a) == 544) then
			if not part1[a] then 
				-- firetruck
				vx, vy, vz = getElementPosition(a)
				dim = getElementDimension(a)
				int = getElementInterior(a)
				-- ladder parts
				part1[a] = createObject ( 1644, vx, vy, vz, 0,0,180)
				part2[a] = createObject ( 3007, vx, vy, vz, 0,0,0)
				part3[a] = createObject ( 3008, vx, vy, vz, 0,0,0)
				part4[a] = createObject ( 3008, vx, vy-0.1, vz+0.1, 0,0,0)
				-- set interior and dimension
				setElementDimension(part1[a], dim)
				setElementDimension(part2[a], dim)
				setElementDimension(part3[a], dim)
				setElementDimension(part4[a], dim)
			
				setElementInterior(part1[a], int)
				setElementInterior(part2[a], int)
				setElementInterior(part3[a], int)
				setElementInterior(part4[a], int)
				-- ladder position
				lx,ly,lz = getElementPosition(part2[a])
				-- ladder rotation
				lrx, lry, lrz = getElementRotation(part1[a])
				-- ladder attachment to firetruck
				attachElements ( part1[a], a, 0, -4, 1.55, 0, 0, lrz)
				attachElements ( part2[a], part1[a], 0, 0.5, 0.17, 0, 0, lrz+180)
				attachElements ( part3[a], part2[a], 0, 0, 0, 0, 0, lrz+180)
				attachElements ( part4[a], part3[a], 0, 0, 0.05, 0, 0, lrz+180)
			end	
        end
    end
end
addEventHandler('onResourceStart', resourceRoot, collisionLad)
 
-- rotation from the ladder
function changeRotation(changeRotation, cond)
	local ladderT = getPedOccupiedVehicle(source)
    if (getElementModel(ladderT) == 544) then
        local x, y, z, rx, ry, rz = getElementAttachedOffsets(part1[ladderT])
		
		setElementAttachedOffsets(part1[ladderT], x, y, z, rx, ry, changeRotation)
    end
end	
addEvent("changeRotation", true)
addEventHandler("changeRotation", root, changeRotation)

-- Length of the ladder (Extension)
function changeLength(changeLength, cond)
	local ladderT = getPedOccupiedVehicle(source)
    if (getElementModel(ladderT) == 544) then
        local x, y, z, rx, ry, rz = getElementAttachedOffsets(part3[ladderT])
		local x2, y2, z2, rx2, ry2, rz2 = getElementAttachedOffsets(part4[ladderT])
		
		setElementAttachedOffsets(part3[ladderT], x, changeLength, z, rx, ry, rz)
		if ( changeLength >= -0.89) then
			setElementAttachedOffsets(part4[ladderT], x2, changeLength, z2, rx2, ry2, rz2)
		else
			setElementAttachedOffsets(part4[ladderT], x2, changeLength+1.8, z2, rx2, ry2, rz2)
		end	
    end
end	
addEvent("changeLength", true)
addEventHandler("changeLength", root, changeLength)

-- Height of the ladder
function changeHeight(changeHeight, cond)
	local ladderT = getPedOccupiedVehicle(source)
    if (getElementModel(ladderT) == 544) then
        local x, y, z, rx, ry, rz = getElementAttachedOffsets(part2[ladderT])
		
		setElementAttachedOffsets(part2[ladderT], x, y, z, changeHeight, ry, rz)
    end
end	
addEvent("changeHeight", true)
addEventHandler("changeHeight", root, changeHeight)

-- Reloadveh solution
function respawnLadder()
	if getElementType(source) == "vehicle" and getElementModel(source) == 544 then
		setTimer(collisionLad, 2000, 1)
		if isElement(part1[source]) then
			destroyElement(part1[source])
		end
		if isElement(part2[source]) then
			destroyElement(part2[source])
		end	
		if isElement(part3[source]) then
			destroyElement(part3[source])
		end	
		if isElement(part4[source]) then
			destroyElement(part4[source])
		end	
	end		
end	
addEventHandler("onElementDestroy", root, respawnLadder)

-- Interior enter fix
function setLadderIntFunc()
	local veh = getPedOccupiedVehicle(client)
	if (veh and getElementModel(veh) == 544) then
		setTimer(setLadderInt, 5000, 1, client)
	end	
end
addEventHandler("elevator:enter", root, setLadderIntFunc)

function setLadderInt(plr)
	local dim = getElementDimension(plr)
	local int = getElementInterior(plr)
	local veh = getPedOccupiedVehicle(plr)
	if (veh and getElementModel(veh) == 544) then
		setElementDimension(part1[veh], dim)
		setElementDimension(part2[veh], dim)
		setElementDimension(part3[veh], dim)
		setElementDimension(part4[veh], dim)
		
		setElementInterior(part1[veh], int)
		setElementInterior(part2[veh], int)
		setElementInterior(part3[veh], int)
		setElementInterior(part4[veh], int)
	end	
end	
addCommandHandler("fixladder", setLadderInt)
