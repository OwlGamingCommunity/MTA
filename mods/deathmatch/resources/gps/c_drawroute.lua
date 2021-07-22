local g_screenX,g_screenY = guiGetScreenSize()
local localPlayer = getLocalPlayer()

--Radar position/size 
local rel = { 	pos_x = 0.0625,
				pos_y = 0.76333333333333333333333333333333,
				size_x = 0.15,
				size_y = 0.175
}

local abs = { 	pos_x = math.floor(rel.pos_x * g_screenX),
				pos_y = math.floor(rel.pos_y * g_screenY),
				size_x = math.floor(rel.size_x * g_screenX),
				size_y = math.floor(rel.size_y * g_screenY)
}
abs.half_size_x =  abs.size_x/2
abs.half_size_y =  abs.size_y/2
abs.center_x = abs.pos_x + abs.half_size_x
abs.center_y = abs.pos_y +abs.half_size_y
local minBound = 0.1*g_screenY

addEvent ( "drawGPS", true )
route = {}
targetx, targety, targetz = nil
vehicle = nil
vehiclerot = nil
vehicleoffset = nil

function drawGPS ( newroute, tx, ty, tz, nvehicle )
	route = newroute
	
	targetx = tx
	targety = ty
	targetz = tz
	
	soundPlayed = false
	
	vehicle = nvehicle
end
addEventHandler ( "drawGPS", getRootElement(), drawGPS )

function getVehicleOffset(pos)
	local m = getElementMatrix ( vehicle )
	
	-- Substract the vehicle position from the player position
	pos[1] = pos[1]-m[4][1]
	pos[2] = pos[2]-m[4][2]
	pos[3] = pos[3]-m[4][3]
	
	-- Multiply the offsetted player position by the inverse vehicle rotation matrix
	local newPos = {}
	newPos[1] = pos[1] * m[1][1] + pos[2] * m[1][2] + pos[3] * m[1][3]
	--newPos[2] = pos[1] * m[2][1] + pos[2] * m[2][2] + pos[3] * m[2][3] We don't need the Y component (remove the comment to use for in front - in back
	--newPos[3] = pos[1] * m[3][1] + pos[2] * m[3][2] + pos[3] * m[3][3] We don't need the Z component
	
	if ( newPos[1] > 0 ) then
		return 2 -- right
	elseif ( newPos[1] < 0 ) then
		return 1 -- left
	else
		return 0 -- aligned
	end
end
local soundPlayer = false

function recalcRoute()
	local x, y, z = getElementPosition(localPlayer)
	
	--soundPlayed = false
	
	local newroute = calculatePathByCoords(targetx, targety, targetz, x, y, z)
	
	if ( newroute ) then
		drawGPS ( newroute, targetx, targety, targetz, vehicle )
	end
end

addEventHandler ( "onClientRender", getRootElement(),
	function()
		if (route) then
			for k,node in ipairs(route) do
				local bDraw = true
				
				if (#route==1) then -- reached our destination
					drawGPS(nil, nil, nil, nil, nil)
					
					if (vehicleoffset==0) then
						outputChatBox("GPS: Arriving at destination on Right", 255, 194, 15)
					else
						outputChatBox("GPS: Arriving at destination on Right", 255, 194, 15)
					end
					return
				end
				
				if (k==#route) then
					local px, py, pz = getElementPosition(getLocalPlayer())
					distance = getDistanceBetweenPoints2D(px, py, node.x, node.y)

					if (distance<10) then
						bDraw = false
						table.remove(route, k) -- pop this one off the route
						--soundPlayed = false
					elseif (distance>50) then
						bDraw = false
						recalcRoute()
						--soundPlayed = false
					end
				end
			
				vx, vy, vz = getElementRotation(vehicle)
				local x = node.x
				local y =  node.y
				local pos = { x, y, 0 }
				vehicleoffset = getVehicleOffset(pos)
				
				
				if (vehiclerot) then
					if ( vz >= vehiclerot + 80  and vehicleoffset==0) then
						soundPlayed = false
						vehiclerot = vz
					elseif ( vz <= vehiclerot - 80  and vehicleoffset==1) then
						soudPlayed = false
						vehiclerot = vz
					end
				end
			
				if not (soundPlayed) then
					soundPlayed = true
					
					vehiclerot = vz
					if (vehicleoffset==2) then -- RIGHT
						playSound("Right.wav")
					elseif (vehicleoffset==1) then
						playSound("Left.wav")
					else
						soundPlayed = false
					end
				end
			
				if ( bDraw ) then
					local x,y = getScreenRadarPositionFromWorld ( node.x, node.y )
					if x and y then
						local previousNode = route[k-1]
						if previousNode then
							endX,endY = getScreenRadarPositionFromWorld ( previousNode.x, previousNode.y )
							if endX and endY then
								dxDrawLine ( x, y, endX, endY, tocolor(251,139,0,180), 5 )
							end
						end
					end
				end
			end
		end
	end
)

function getRadarScreenRadius ( angle ) --Since the radar is not a perfect ciricle, we work out the screen size of the radius at a certain angle
	return math.abs((math.sin(angle)*(abs.half_size_x - abs.half_size_y))) + abs.half_size_y
end


function getScreenRadarPositionFromWorld (posX,posY)
	if not isPlayerMapVisible() then --Render to the radar
		local cameraTarget = getCameraTarget()
		local x,y,camRot
		--Are we in fixed camera mode?
		if not cameraTarget then
			x,y,_,lx,ly = getCameraMatrix()
			camRot = getVectorRotation(x,y,lx,ly)
		else
			x,y = getElementPosition(cameraTarget)
			local vehicle = getPedOccupiedVehicle(localPlayer)
			if ( vehicle ) then
				--Look back works on all vehicles
				if getControlState"vehicle_look_behind" or
				( getControlState"vehicle_look_left" and getControlState"vehicle_look_right" ) or
				--Look left/right on any vehicle except planes and helis (these rotate them)
				( getVehicleType(vehicle)~="Plane" and getVehicleType(vehicle)~="Helicopter" and 
				( getControlState"vehicle_look_left" or getControlState"vehicle_look_right" ) ) then
					camRot = -math.rad(getPedRotation(localPlayer))
				else
					local px,py,_,lx,ly = getCameraMatrix()
					camRot = getVectorRotation(px,py,lx,ly)
				end
			elseif getControlState"look_behind" then
				camRot = -math.rad(getPedRotation(localPlayer))
			else
				local px,py,_,lx,ly = getCameraMatrix()
				camRot = getVectorRotation(px,py,lx,ly)
			end
		end
		local toBlipRot = getVectorRotation(x,y,posX,posY )
		local blipRot = toBlipRot - camRot
		--Get the screen radius at that rotation
		local radius = getRadarScreenRadius ( blipRot )
		local radarRadius = getRadarRadius()
		local distance = getDistanceBetweenPoints2D ( x,y,posX,posY )
		if (distance <= radarRadius) then
			radius = (distance/radarRadius)*radius
			local tx = radius * math.sin(blipRot) + abs.center_x
			local ty = -radius * math.cos(blipRot) + abs.center_y
			--
			return tx,ty
		end
		return false
	else --Render to f11 map
		local minX,minY,maxX,maxY = getPlayerMapBoundingBox()
		local sizeX = maxX - minX
		local sizeY = maxY - minY
		--
		sizeX = sizeX/6000
		sizeY = sizeY/6000
		--
		local mapX = posX + 3000
		local mapY = posY + 3000
		mapX = mapX*sizeX + minX
		mapY = maxY - mapY*sizeY
		return mapX,mapY
	end
end

--Simple RotZ calc (Only need RotZ since we're in 2D)
function getVectorRotation (px, py, lx, ly )
	local rotz = 6.2831853071796 - math.atan2 ( ( lx - px ), ( ly - py ) ) % 6.2831853071796
 	return -rotz
end
