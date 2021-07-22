function isPlayerInWater()
	local x, y, z = getElementPosition(localPlayer) 
	local waterlevel = getWaterLevel(x, y, z, true)
	if waterlevel then
		return true
	else
		return false
	end
end

local isRenderingSurf = false
local surfElement

--debug
local useDebugMarkers = true
local useDebugLines = true
local cameraDirect = true

function getPositionFromElementOffset(element, offX, offY, offZ)
	local m = getElementMatrix(element)
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z
end

function angle(vec1, vec2)
	-- Calculate the angle by applying law of cosines
	return math.acos(vec1:dot(vec2)/(vec1.length*vec2.length))
end

function angle2(x, y)
	return math.atan2(x, y)
end

function renderSurf()
	if not isElement(surfElement) then stopSurfing() end
	local px, py, pz = getElementPosition(surfElement)
	
	--set z position of board based on water level
	wz = getWaterLevel(px, py, pz, true)
	local newZ = pz
	if wz then newZ = wz+0.01 end
	--setElementPosition(surfElement, px, py, newZ)

	if not startPos then
		startPos = { px, py, newZ }
	end

	--get matrix
	local front = { getPositionFromElementOffset(surfElement, 0, 2, 0) }
	local back = { getPositionFromElementOffset(surfElement, 0, -2, 0) }
	local left = { getPositionFromElementOffset(surfElement, -1, 0, 0) }
	local right = { getPositionFromElementOffset(surfElement, 1, 0, 0) }
	local frontWater = getWaterLevel(front[1], front[2], front[3], true)
	local backWater = getWaterLevel(back[1], back[2], back[3], true)
	local leftWater = getWaterLevel(left[1], left[2], left[3], true)
	local rightWater = getWaterLevel(right[1], right[2], right[3], true)
	if not frontWater then frontWater = 0 end
	if not backWater then backWater = 0 end
	if not leftWater then leftWater = 0 end
	if not rightWater then rightWater = 0 end
	front[3] = frontWater
	back[3] = backWater
	left[3] = leftWater
	right[3] = rightWater

	if useDebugMarkers then
		setElementPosition(frontMarker, front[1], front[2], frontWater)
		setElementPosition(backMarker, back[1], back[2], backWater)
		setElementPosition(leftMarker, left[1], left[2], leftWater)
		setElementPosition(rightMarker, right[1], right[2], rightWater)
	end
	if useDebugLines then
		dxDrawLine3D(front[1], front[2], frontWater, back[1], back[2], backWater, tocolor(0, 250, 0, 200))
		dxDrawLine3D(left[1], left[2], leftWater, right[1], right[2], rightWater, tocolor(0, 250, 0, 200))
		if startPos then
			dxDrawLine3D(startPos[1], startPos[2], startPos[3], px, py, newZ, tocolor(0, 0, 0, 200))
		end
	end

	--get direction of board based on camera
	local oldRot = { getElementRotation(surfElement) }
	local direction
	if cameraDirect then
		local cx, cy, cz, lx, ly, lz = getCameraMatrix()
		direction = math.deg( math.atan2( ly - cy, lx - cx ) ) - 90
	else
		direction = oldRot[3]
	end
	setPedRotation(localPlayer, direction)

	--get angle of board based on waves
	local frontVector = Vector3(front[1], front[2], front[3])
	local backVector = Vector3(back[1], back[2], back[3])
	local leftVector = Vector3(left[1], left[2], left[3])
	local rightVector = Vector3(right[1], right[2], right[3])
	angleX, angleY = 0, 0
	--if(front[3] ~= back[3]) then
		--angleX = angle(frontVector, backVector)
		angleX = angle2(front[3], back[3])
	--end
	--if(left[3] ~= right[3]) then
		--angleY = angle(leftVector, rightVector)
		angleY = angle2(left[3], right[3])
	--end

	if back[3] > front[3] then
		angleX = -angleX
	end 
	if right[3] > left[3] then
		angleY = -angleY
	end

	--set board rotations
	--angleX = tonumber(angleX) or 0
	--angleY = tonumber(angleY) or 0

	if not tonumber(angleX) then outputDebugString("error: angleX = "..tostring(angleX)) end
	if not tonumber(angleY) then outputDebugString("error: angleY = "..tostring(angleY)) end
	if not tonumber(direction) then outputDebugString("error: direction = "..tostring(direction)) end
	--if angleX > 0 or angleY > 0 then
		--outputDebugString("angleX="..tostring(angleX).." angleY="..tostring(angleY).." direction="..tostring(direction))
	--end

	--[[
	if angleX > 0 then
		angleX = angleX
	end
	if angleY > 0 then
		angleY = angleY
	end
	--]]

	--angleX = math.floor(angleX)
	--angleY = math.floor(angleY)

	--if angleX > 0 or angleY > 0 then
	--	outputDebugString("angleX="..tostring(angleX).." angleY="..tostring(angleY).." direction="..tostring(direction))
	--end

	--angleX = math.deg(angleX)
	--angleY = math.deg(angleY)

	local maxAngleX = 30
	local maxAngleY = 30

	if angleX > maxAngleX then
		angleX = maxAngleX
	end
	if angleX < -maxAngleX then
		angleX = -maxAngleX
	end
	if angleY > maxAngleY then
		angleX = maxAngleX
	end
	if angleY < -maxAngleY then
		angleY = -maxAngleY
	end

	outputDebugString("angleX="..tostring(angleX).." angleY="..tostring(angleY).." direction="..tostring(direction))

	setElementRotation(surfElement, angleX, angleY, direction)

	--set velocity
	if not wz then
		setElementVelocity(surfElement, 0, 0, 0) --stop movement if board hits shore (out of water)
	else
		--[[
		local velocityX, velocityY, velocityZ = 0, 0, 0
		if angleX > 0 then
			velocityX = angleX
		end
		if angleY > 0 then
			velocityY = angleY
		end
		setElementVelocity(surfElement, velocityX, velocityY, velocityZ)
		--]]
	end

end

surfMovementDebugOutput = false
function surfMovement()
	surfMovementDebugOutput = not surfMovementDebugOutput

	if not isElement(surfElement) then stopSurfing() end
	local px, py, pz = getElementPosition(surfElement)
	
	--set z position of board based on water level
	wz = getWaterLevel(px, py, pz, true)
	local newZ = pz
	if wz then newZ = wz+0.01 end
	--setElementPosition(surfElement, px, py, newZ)

	--get matrix
	local front = { getPositionFromElementOffset(surfElement, 0, 2, 0) }
	local back = { getPositionFromElementOffset(surfElement, 0, -2, 0) }
	local left = { getPositionFromElementOffset(surfElement, -1, 0, 0) }
	local right = { getPositionFromElementOffset(surfElement, 1, 0, 0) }
	local frontWater = getWaterLevel(front[1], front[2], front[3], true)
	local backWater = getWaterLevel(back[1], back[2], back[3], true)
	local leftWater = getWaterLevel(left[1], left[2], left[3], true)
	local rightWater = getWaterLevel(right[1], right[2], right[3], true)
	if not frontWater then frontWater = 0 end
	if not backWater then backWater = 0 end
	if not leftWater then leftWater = 0 end
	if not rightWater then rightWater = 0 end
	front[3] = frontWater
	back[3] = backWater
	left[3] = leftWater
	right[3] = rightWater

	--get direction of board based on camera
	local oldRot = { getElementRotation(surfElement) }
	local direction
	if cameraDirect then
		local cx, cy, cz, lx, ly, lz = getCameraMatrix()
		direction = math.deg( math.atan2( ly - cy, lx - cx ) ) - 90
	else
		direction = oldRot[3]
	end
	--setPedRotation(localPlayer, direction)

	if direction ~= oldRot[3] then
		relativeDirection = direction - oldRot[3]
		relativeDirection = math.deg(math.atan2(direction, oldRot[3]))
	else
		relativeDirection = 0
	end

	--get angle of board based on waves
	local frontVector = Vector3(front[1], front[2], front[3])
	local backVector = Vector3(back[1], back[2], back[3])
	local leftVector = Vector3(left[1], left[2], left[3])
	local rightVector = Vector3(right[1], right[2], right[3])
	angleX, angleY = 0, 0
	--if(front[3] ~= back[3]) then
		--angleX = angle(frontVector, backVector)
		angleX = angle2(front[3], back[3])
	--end
	--if(left[3] ~= right[3]) then
		--angleY = angle(leftVector, rightVector)
		angleY = angle2(left[3], right[3])
	--end

	if back[3] > front[3] then
		angleX = -angleX
	end 
	if right[3] > left[3] then
		angleY = -angleY
	end

	if angleX ~= oldRot[1] then
		relativeAngleX = angleX -oldRot[1]
	else
		relativeAngleX = 0
	end
	if angleY ~= oldRot[2] then
		relativeAngleY = angleY - oldRot[2]
	else
		relativeAngleY = 0
	end

	relativeAngleX = math.floor(relativeAngleX)
	relativeAngleY = math.floor(relativeAngleX)
	relativeDirection = math.floor(relativeDirection)

	if surfMovementDebugOutput then
		--outputDebugString(tostring(relativeAngleX)..", "..tostring(relativeAngleY)..", "..tostring(relativeDirection))
	end

	--moveObject(surfElement, 500, px, py, newZ, relativeAngleX, relativeAngleY, relativeDirection, "Linear")

	--setElementRotation(surfElement, angleX, angleY, direction)
end

function surfVelocity()
	if not isElement(surfElement) then stopSurfing() end

	if wz then
		local velocityX, velocityY, velocityZ = 0, 0, 0
		if angleX > 0 then
			velocityX = angleX
		end
		if angleY > 0 then
			velocityY = angleY
		end

		local maxVelocity = 1
		if velocityX > maxVelocity then
			velocityX = maxVelocity
		end
		if velocityY > maxVelocity then
			velocityY = maxVelocity
		end

		setElementVelocity(surfElement, velocityX, velocityY, velocityZ)
		outputDebugString("setElementVelocity(surfElement, "..tostring(velocityX)..", "..tostring(velocityY)..", 0)")
	end
end

function startSurfing(element)
	if isRenderingSurf then
		stopSurfing()
	end
	if isElement(element) then
		surfElement = element
		if useDebugMarkers then
			frontMarker = createMarker(0, 0, 0, "corona", 0.2, 255, 238, 0, 255)
			backMarker = createMarker(0, 0, 0, "corona", 0.2, 255, 238, 0, 255)
			leftMarker = createMarker(0, 0, 0, "corona", 0.2, 255, 238, 0, 255)
			rightMarker = createMarker(0, 0, 0, "corona", 0.2, 255, 238, 0, 255)
		end
		if useDebugLines then
			startPos = nil
		end
		isRenderingSurf = true
		addEventHandler("onClientRender", root, renderSurf)
		movementTimer = setTimer(surfMovement, 500, 0)
		velocityTimer = setTimer(surfVelocity, 3000, 0)
	end
end
addEvent("activities:surf:start", true)
addEventHandler("activities:surf:start", localPlayer, startSurfing, false)

function stopSurfing()
	if isRenderingSurf then
		killTimer(velocityTimer)
		velocityTimer = nil
		killTimer(movementTimer)
		movementTimer = nil
		removeEventHandler("onClientRender", root, renderSurf)
		surfElement = nil
		if useDebugMarkers then
			destroyElement(frontMarker)
			destroyElement(backMarker)
			destroyElement(leftMarker)
			destroyElement(rightMarker)
		end
	end
end
addEvent("activities:surf:stop", true)
addEventHandler("activities:surf:stop", localPlayer, stopSurfing, false)