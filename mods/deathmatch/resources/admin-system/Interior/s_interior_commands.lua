function getPosition(thePlayer, commandName)
	--if (exports.integration:isPlayerTrialAdmin(thePlayer)) or (exports.integration:isPlayerScripter(thePlayer)) then
		local x, y, z = getElementPosition(thePlayer)
		local rx, ry, rz = getElementRotation(thePlayer)
		local dimension = getElementDimension(thePlayer)
		local interior = getElementInterior(thePlayer)
		
		outputChatBox("Position: " .. x .. ", " .. y .. ", " .. z, thePlayer, 255, 194, 14)
		outputChatBox("Rotation: " .. rx .. ", " .. ry .. ", " .. rz, thePlayer, 255, 194, 14)
		outputChatBox("Dimension: " .. dimension, thePlayer, 255, 194, 14)
		outputChatBox("Interior: " .. interior, thePlayer, 255, 194, 14)
		local prepairedText = " "..interior.." "..dimension.." "..x.." "..y.." "..z
		outputChatBox("'"..prepairedText.."' - copied to clipboard", thePlayer, 200, 200, 200)
		triggerClientEvent(thePlayer, "copyPosToClipboard", thePlayer, prepairedText)
	--end
end
addCommandHandler("getpos", getPosition, false, false)

-- /X, /Y, /Z and /XYZ
function setX(thePlayer, commandName, ix)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then
		if not (ix) or not tonumber(ix) then
			outputChatBox("SYNTAX: /" .. commandName .. " [X Value]", thePlayer, 255, 194, 14)
		else
			if (isPedInVehicle(thePlayer)) then
				local x, y, z = getElementPosition(thePlayer)
				local veh = getPedOccupiedVehicle(thePlayer)
				setElementPosition(veh, x+ix, y, z)
			else
				local x, y, z = getElementPosition(thePlayer)
				setElementPosition(thePlayer, x+ix, y, z)
			end
		end
	end
end
addCommandHandler("x", setX)

function setY(thePlayer, commandName, iy)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then
		if not (iy) or not tonumber(iy) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Y Value]", thePlayer, 255, 194, 14)
		else
			if (isPedInVehicle(thePlayer)) then
				local x, y, z = getElementPosition(thePlayer)
				local veh = getPedOccupiedVehicle(thePlayer)
				setElementPosition(veh, x, y+iy, z)
			else
				local x, y, z = getElementPosition(thePlayer)
				setElementPosition(thePlayer, x, y+iy, z)
			end
		end
	end
end
addCommandHandler("y", setY, false, false)

function setZ(thePlayer, commandName, iz)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then
		if not (iz) or not tonumber(iz) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Z Value]", thePlayer, 255, 194, 14)
		else
			if (isPedInVehicle(thePlayer)) then
				local x, y, z = getElementPosition(thePlayer)
				local veh = getPedOccupiedVehicle(thePlayer)
				setElementPosition(veh, x, y, z+iz)
			else
				local x, y, z = getElementPosition(thePlayer)
				setElementPosition(thePlayer, x, y, z+iz)
			end
		end
	end
end
addCommandHandler("z", setZ, false, false)

function setXYZ(thePlayer, commandName, ix, iy, iz)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then
		if not (ix) or not (iy) or not (iz) or not tonumber(ix) or not tonumber(iy) or not tonumber(iz) then
			outputChatBox("SYNTAX: /" .. commandName .. " [X Value][Y Value] [Z Value]", thePlayer, 255, 194, 14)
		else
			if (isPedInVehicle(thePlayer)) then
				local x, y, z = getElementPosition(thePlayer)
				local veh = getPedOccupiedVehicle(thePlayer)
				setElementPosition(veh, x+ix, y+iy, z+iz)
			else
				local x, y, z = getElementPosition(thePlayer)
				setElementPosition(thePlayer, x+ix, y+iy, z+iz)
			end
		end
	end
end
addCommandHandler("xyz", setXYZ, false, false)

function setRot(thePlayer, commandName, z)
	if not tonumber(z) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Z Rotation]", thePlayer, 255, 194, 14)
		return
	end			
	
	local element = thePlayer
	if isPedInVehicle( thePlayer ) and (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then 
		element = getPedOccupiedVehicle( thePlayer )
	elseif isPedInVehicle(thePlayer) and not (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then
		return
	end

	local x, y = getElementRotation(element)		
	setElementRotation( element, x, y, tonumber(z) )
end
addCommandHandler("rot", setRot)