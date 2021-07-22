--[[ Heligrab - Client ]]--


helicopter_offsets = {
["News Chopper"] = {
					x = 1.15,
					z = -1.05,
					front = 2.9,
					back = -1.1,
					-- defaults to facing inward (0) regardless of side/vehicle, facing adds to the default rotation (ie: 180 means facing out regardless of side/vehicle)
					facing = 0,
					-- default leg state (for vehicles that support it)
					legs = "down",
					-- number of people that can grab this vehicle simultaneously, call ToggleHangingWeightLimit(false) serverside to remove this
					limit = 6
					},
["Police Maverick"] = {
					x = 1.15,
					z = -1.05,
					front = 2.9,
					back = -1.1,
					facing = 0,
					legs = "down",
					limit = 8
					},
["Cargobob"] = {
					x = 1.8,
					z = .2,
					front = 3.6,
					back = -0.8,
					facing = 180,
					legs = "up",
					limit = 6
					},
["Raindance"] = {
					x = 1.25,
					z = -1.2,
					front = 1.6,
					back = 1.1,
					facing = 0,
					legs = "down",
					limit = 2
					},
["Seasparrow"] = {
					x = 1.2,
					z = -0.6,
					front = 2.0,
					back = -1.5,
					facing = 0,
					legs = "down",
					limit = 6
					},
["Hunter"] = {
					x = 2.4,
					z = -0.9,
					front = 1.3,
					back = -0.1,
					facing = 0,
					legs = "down",
					limit = 2
					},
["Leviathan"] = {
					x = 2.7,
					z = 0.0,
					front = 1.8,
					back = -0.8,
					facing = 0,
					legs = "down",
					limit = 4
					},
["Sparrow"] = {
					x = 1.15,
					z = -0.9,
					front = 2.6,
					back = -0.6,
					facing = 0,
					legs = "down",
					limit = 6
					},
["Maverick"] = {
					x = 1.15,
					z = -1.05,
					front = 2.9,
					back = -1.1,
				--	bottom = -5,
					facing = 0,
					legs = "down",
					limit = 8
					}
}

root = getRootElement()
local_player = getLocalPlayer()


local hanging_weight_limits = true

function SetHangingWeightLimit(state)
	if state == true or state == false then
		hanging_weight_limits = state
	end
end
addEvent("ToggleHangingWeightLimit",true)
addEventHandler("ToggleHangingWeightLimit",root,SetHangingWeightLimit)


local debug_data = false
-- all the currently streamed in (grabable) vehicles
local vehicles = {}
-- distance your hands must be from the helicopter to be able to grab
local grab_distance = 1.2
-- distance from the helicopter(s) before you begin tracking them and checking for grabs
local track_distance = 8
-- distance the grab point must be from the ground before you are automatically dropped
ground_drop_distance = 1.5
-- distance the grab point must be away from the ground before you lift your legs up
local feet_up_distance = 3
local feet_down_gap = 2
-- information about the targetted heli/side
local target = {distance = track_distance, side = "", heliname = "", line_percent = -1}
local removed = false



addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),function()
	-- ask the server for the current hanging_weight_limit value
	--triggerServerEvent("RequestHangingWeightLimit",local_player)
	
	
	-- load all streamed helicopters into the tracking table
	for _,v in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(v) then
			if getVehicleType(v)=="Helicopter" then
				table.insert(vehicles,v)
			end
		end
	end

	addCommandHandler("grab",function()
		if not getElementData(local_player,"hanging") then
			if target.vehicle and target.distance <= grab_distance then
				if isPlayerDead(local_player) or getElementHealth(local_player) <= 0.2 then
					return
				end
				
				-- dont want people grabbing whilst inside the helicopter (or another vehicle if they can get close enough)
				if isPedInVehicle(local_player) then
					outputChatBox("You are already inside a vehicle!")
					return
				end
				
				target.vehiclename = getVehicleName(target.vehicle)
				
				-- trace a line from the grab point down ground_drop_distance+0.2 (slightly below the height level at which you'd automatically be dropped)
				local collision,_,_,_,element = processLineOfSight(target.point[1],target.point[2],target.point[3],target.point[1],target.point[2],target.point[3]-(ground_drop_distance+0.2),true,true,false,true,false,true,false,false,target.vehicle)
				
				-- if it collides with the player then ignore it
				if collision and element == local_player then collision = false end
				
				-- the grab point is too close to the ground (or an element) and we dont want people hanging onto grounded helicopters
				if collision then
					outputChatBox("That helicopter has barely left the ground yet!")
					return
				end
				
				if hanging_weight_limits then
					-- limit the number of people hanging per helicopter
					local count = 0
					for i,v in ipairs(getElementsByType("player")) do
						local player_hanging = getElementData(v,"hanging")
						if player_hanging and player_hanging.heli == target.vehicle then
							count = count + 1
						end
					end
					
					if count >= helicopter_offsets[target.vehiclename].limit then
						outputChatBox("That helicopter can't take any more weight!")
						return
					end
				end
				
				
			--	outputChatBox("Grab ["..target.side.."] (heli)")
			
				triggerEvent("MakePlayerGrabHeli",local_player,target.vehicle,target.side,target.line_percent)
			end
		end
	end)
	
	addEventHandler("onClientRender", getRootElement(), function()
		if not getElementData(local_player,"hanging") and getControlState('jump') and getPedSimplestTask(local_player) == 'TASK_SIMPLE_IN_AIR' then
			if target.vehicle and target.distance <= grab_distance and not cooldown then
				cooldown = setTimer(function() cooldown = nil end, 400, 1)
				if isPlayerDead(local_player) or getElementHealth(local_player) <= 0.2 then
					return
				end
				
				-- dont want people grabbing whilst inside the helicopter (or another vehicle if they can get close enough)
				if isPedInVehicle(local_player) then
					return
				end
			
				target.vehiclename = getVehicleName(target.vehicle)
				
				-- trace a line from the grab point down ground_drop_distance+0.2 (slightly below the height level at which you'd automatically be dropped)
				local collision,_,_,_,element = processLineOfSight(target.point[1],target.point[2],target.point[3],target.point[1],target.point[2],target.point[3]-(ground_drop_distance+0.2),true,true,false,true,false,true,false,false,target.vehicle)
				
				-- if it collides with the player then ignore it
				if collision and element == local_player then collision = false end
				
				-- the grab point is too close to the ground (or an element) and we dont want people hanging onto grounded helicopters
				if collision then
					return
				end
				
				if hanging_weight_limits then
					-- limit the number of people hanging per helicopter
					local count = 0
					for i,v in ipairs(getElementsByType("player")) do
						local player_hanging = getElementData(v,"hanging")
						if player_hanging and player_hanging.heli == target.vehicle then
							count = count + 1
						end
					end
					
					if count >= helicopter_offsets[target.vehiclename].limit then
						return
					end
				end
				
				
			--	outputChatBox("Grab ["..target.side.."] (heli)")
			
				triggerEvent("MakePlayerGrabHeli",local_player,target.vehicle,target.side,target.line_percent)
			end
		end
	end)
	
--	bindKey("g","down","grab")
	
	addCommandHandler("drop",function() triggerEvent("PlayerDrop",local_player,"manual",target.vehicle) end)
--	bindKey("r","down","drop")
end)



function GrabHeli(heli,side,line_percent)
	target.vehicle = heli
	target.side = side
	target.line_percent = line_percent
	target.vehiclename = getVehicleName(heli)
	
	setElementData(source,"hanging",{side = side, heli = heli, line_percent = line_percent, legs_up = false})
	
	-- not sure if these are entirely necessary
	setElementVelocity(source,0,0,0)
	setPedAnimation(source,nil,nil)
	
	local x = helicopter_offsets[target.vehiclename].x
	if side and side == "left" then x = -x end
	
	local diff = math.abs(helicopter_offsets[target.vehiclename].front - helicopter_offsets[target.vehiclename].back)
	
	target.offsets = {}
	target.offsets.x = x
	target.offsets.y = helicopter_offsets[target.vehiclename].back + (diff*(math.abs(line_percent-1)))
	target.offsets.z = helicopter_offsets[target.vehiclename].z
	
	triggerServerEvent("PlayerGrabVehicle",source,heli)
	
	removed = false
	-- originally this was done on render, however 50ms is sufficient 
	target.timer = setTimer(UpdateHangingEffect,50,0)
end
addEvent("MakePlayerGrabHeli",true)
addEventHandler("MakePlayerGrabHeli",root,GrabHeli)



addEventHandler("onClientResourceStop",getResourceRootElement(getThisResource()),function()
	detachElements(local_player,target.vehicle)
	setPedAnimation(local_player,nil)
	setElementData(local_player,"hanging",nil)
	
	if target.timer then
		killTimer(target.timer)
	end
	target.timer = nil
	
	toggleControl("enter_exit",true)
	toggleControl("enter_passenger",true)
	removed = false
end)


-- check distance from the ground for legs/auto drops/collisions
-- local player
function UpdateHangingEffect()
	if getElementData(local_player,"hanging") then
		local player_hanging = getElementData(local_player,"hanging")
		
		-- uh oh, we are hanging but also inside a vehicle, can happen with the warp code used to put players into vehicles that sit on water (seasparrow,leviathan) as onClientEnterVehicle isnt triggered in this case (if your enter_passenger key is also your grab key)
		if not removed and isPedInVehicle(local_player) then
			-- remove ourselves from the vehicle
			triggerServerEvent("RemoveHangingPedFromVehicle",local_player)
			removed = true
		end
		
		-- we were in a vehicle, we've now been removed so detach and hope the render handler will take care of us
	--	if removed and not isPedInVehicle(local_player) then
		--	detachElements(local_player,player_hanging.heli)
		--	removed = false
	--	end
	
		-- get the position feet_up_distance below the grab point and the grab point
		local matrix = getElementMatrix(target.vehicle)
		
		target.offsets.drop_x = target.offsets.x * matrix[1][1] + target.offsets.y * matrix[2][1] + target.offsets.z-feet_up_distance * matrix[3][1] + matrix[4][1]
		target.offsets.drop_y = target.offsets.x * matrix[1][2] + target.offsets.y * matrix[2][2] + target.offsets.z-feet_up_distance * matrix[3][2] + matrix[4][2]
		target.offsets.drop_z = target.offsets.x * matrix[1][3] + target.offsets.y * matrix[2][3] + target.offsets.z-feet_up_distance * matrix[3][3] + matrix[4][3]
		
		local grab_x = target.offsets.x * matrix[1][1] + target.offsets.y * matrix[2][1] + target.offsets.z * matrix[3][1] + matrix[4][1]
		local grab_y = target.offsets.x * matrix[1][2] + target.offsets.y * matrix[2][2] + target.offsets.z * matrix[3][2] + matrix[4][2]
		local grab_z = target.offsets.x * matrix[1][3] + target.offsets.y * matrix[2][3] + target.offsets.z * matrix[3][3] + matrix[4][3]
		
		local collision,col_x,col_y,col_z,col_element = processLineOfSight(grab_x,grab_y,grab_z,target.offsets.drop_x,target.offsets.drop_y,target.offsets.drop_z,true,true,false,true,false,true,false,false,local_player)
		
		-- if the collision that was found is the helicopter itself (eg: when hanging on a cargobob) then ignore it.
		if collision and col_element == target.vehicle then
			collision = false
		end
		
		if collision then
			local dist = getDistanceBetweenPoints3D(grab_x,grab_y,grab_z,col_x,col_y,col_z)
			-- approx player height, player is too close to something (either a collision or the ground) so drop
			if dist <= ground_drop_distance then
				triggerEvent("PlayerDrop",local_player,"collision",player_hanging.heli)
				return
			end
			
			if dist <= (ground_drop_distance+feet_up_distance) then
				local _,anim = getPedAnimation(local_player)
				-- lift up the legs
				if anim ~= "FIN_LegsUp_Loop" and player_hanging.legs_up == false then
					setElementData(local_player,"hanging",{side = target.side, heli = target.vehicle, line_percent = target.line_percent, legs_up = true})
				end
				return
			end
		else
			-- no collision, not near the ground so set default leg state
			local _,anim = getPedAnimation(local_player)
			if helicopter_offsets[target.vehiclename].legs == "down" then
				if anim ~= "FIN_Hang_Loop" and player_hanging.legs_up == true then
					setElementData(local_player,"hanging",{side = target.side, heli = target.vehicle, line_percent = target.line_percent, legs_up = false})
				end
			elseif helicopter_offsets[target.vehiclename].legs == "up" then
				if anim ~= "FIN_LegsUp_Loop" and player_hanging.legs_up == false then
					setElementData(local_player,"hanging",{side = target.side, heli = target.vehicle, line_percent = target.line_percent, legs_up = true})
				end
						
			end
		end
	end
end


function DropPlayer(reason,vehicle,force)
	if getElementData(source,"hanging") or force then
		if source == local_player then
			-- tell everyone else we're dropping
			triggerServerEvent("PlayerDropFromHeli",source,vehicle,reason)
	
			-- helis that we get warped into (and dont trigger onClientVehicleEnter) when on the surface of the water are a pain
			-- those with their drop key bound to enter_exit will be put into the drivers seat when they drop, this will remove them
			if (target.vehiclename == "Seasparrow" or target.vehiclename == "Leviathan") then
				-- remove ourselves from the vehicle
				setTimer(function()
					if isPedInVehicle(local_player) then
						triggerServerEvent("RemoveHangingPedFromVehicle",local_player)
					end
				end,50,10)
			end
			
			setElementData(source,"hanging",nil)
			
			if target.timer then
				killTimer(target.timer)
			end
			target.timer = nil

			toggleControl("enter_exit",true)
			toggleControl("enter_passenger",true)
			removed = false
		end
		
		if vehicle then
			detachElements(source,vehicle)
		end
		setPedAnimation(source,nil)
	end
end
addEvent("PlayerDrop",true)
addEventHandler("PlayerDrop",root,DropPlayer)


addCommandHandler("forcedrop",function(player)
	local player_hanging = getElementData(player,"hanging")
	local vehicle = nil
	if player_hanging then
		vehicle = player_hanging.heli
	end
	
	triggerEvent("PlayerDrop",player,"force drop",vehicle,true)
end)


addEventHandler("onClientRender",root,function()
	-- not hanging, track helis for local player
	if not getElementData(local_player,"hanging") then
		for _,heli in ipairs(vehicles) do
			if heli and isElement(heli) then
				if isElementOnScreen(heli) then
					-- no point getting the player position just for this check, so get one hand position now (which we will be using again later anyway)
					local left_hand_x,left_hand_y,left_hand_z = getPedBonePosition(local_player,36)
					local hx,hy,hz = getElementPosition(heli)
					-- if its within range to begin checking
					if getDistanceBetweenPoints3D(hx,hy,hz,left_hand_x,left_hand_y,left_hand_z) < track_distance then
							
						local matrix = getElementMatrix(heli)
						local veh_name = getVehicleName(heli)
						
						local offset = {}
						offset.x = helicopter_offsets[veh_name].x
						offset.front = helicopter_offsets[veh_name].front
						offset.back = helicopter_offsets[veh_name].back
						offset.z = helicopter_offsets[veh_name].z
						
						-- Get the transformation of the 4 points (left/right side of the helicopter)
						local right = {}
						right.front_x = offset.x * matrix[1][1] + offset.front * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
						right.front_y = offset.x * matrix[1][2] + offset.front * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
						right.front_z = offset.x * matrix[1][3] + offset.front * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]
						
						right.back_x = offset.x * matrix[1][1] + offset.back * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
						right.back_y = offset.x * matrix[1][2] + offset.back * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
						right.back_z = offset.x * matrix[1][3] + offset.back * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]
						
						local left = {}
						left.front_x = -offset.x * matrix[1][1] + offset.front * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
						left.front_y = -offset.x * matrix[1][2] + offset.front * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
						left.front_z = -offset.x * matrix[1][3] + offset.front * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]
						
						left.back_x = -offset.x * matrix[1][1] + offset.back * matrix[2][1] + offset.z * matrix[3][1] + matrix[4][1]
						left.back_y = -offset.x * matrix[1][2] + offset.back * matrix[2][2] + offset.z * matrix[3][2] + matrix[4][2]
						left.back_z = -offset.x * matrix[1][3] + offset.back * matrix[2][3] + offset.z * matrix[3][3] + matrix[4][3]
						
						local right_hand_x,right_hand_y,right_hand_z = getPedBonePosition(local_player,26)
						-- should really check both hands against each side, but its a barely noticable loss
						right.point,right.line_percent,right.dist = GetPointIntersectOnLine(right_hand_x,right_hand_y,right_hand_z,right.front_x,right.front_y,right.front_z,right.back_x,right.back_y,right.back_z)
						left.point,left.line_percent,left.dist = GetPointIntersectOnLine(left_hand_x,left_hand_y,left_hand_z,left.front_x,left.front_y,left.front_z,left.back_x,left.back_y,left.back_z)
						
						
						-- if the right side is closer (or they are both equal distance, in which case default to right)
						if right.dist <= left.dist then
							-- if this heli and this side are already the targetted heli/side, update the current info
							if target.vehicle == heli and target.side == "right" then
								target.distance = right.dist
								target.line_percent = right.line_percent
								target.point = right.point
							end
							
							-- if the distance to the right side of this helicopter is less than the distance to the currently targeted helicopter (or they are equal, in which case default to this new one)
							if right.dist < target.distance then
								target.vehicle = heli
								target.distance = right.dist
								target.side = "right"
								target.point = right.point
								target.line_percent = right.line_percent
							end
						else
							if target.vehicle == heli and target.side == "left" then
								target.distance = left.dist
								target.line_percent = left.line_percent
								target.point = left.point
							end
							
							if left.dist < target.distance then
								target.vehicle = heli
								target.distance = left.dist	
								target.side = "left"
								target.point = left.point
								target.line_percent = left.line_percent
							end
						end
						
						if debug_data then
							dxDrawText(string.format("tracking %d vehicles",#vehicles),5,400,50,50,tocolor(255,50,0),1,"default-bold")
							if target.vehicle then
								dxDrawText(string.format("target: %s",getVehicleName(target.vehicle)),5,415,50,50,tocolor(255,50,0),1,"default-bold")
							else
								dxDrawText(string.format("target: nil"),5,415,50,50,tocolor(255,50,0),1,"default-bold")
							end
							dxDrawText(string.format("target dist: %.4f",target.distance),5,430,50,50,tocolor(255,50,0),1,"default-bold")
							dxDrawText(string.format("target side: %s",target.side),5,445,50,50,tocolor(255,50,0),1,"default-bold")
							dxDrawText(string.format("target t: %.4f",target.line_percent),5,460,50,50,tocolor(255,50,0),1,"default-bold")
							dxDrawText(string.format("right dist: %.4f",right.dist),5,475,50,50,tocolor(255,50,0),1,"default-bold")
							dxDrawText(string.format("left dist: %.4f",left.dist),5,490,50,50,tocolor(255,50,0),1,"default-bold")
						end
					end
				end
			end
		end
	end
	
	-- check attachments, animations and rotations for all players
	for _,p in ipairs(getElementsByType("player")) do
		if isElement(p) and isElementStreamedIn(p) then
			local player_hanging = getElementData(p,"hanging") 
			if player_hanging then
				-- attach to heli
				if not isElementAttached(p) then
					local x = helicopter_offsets[getVehicleName(player_hanging.heli)].x
					if player_hanging.side and player_hanging.side == "left" then x = -x end
					
					local diff = math.abs(helicopter_offsets[getVehicleName(player_hanging.heli)].front - helicopter_offsets[getVehicleName(player_hanging.heli)].back)
				
					attachElements(p,player_hanging.heli,x,helicopter_offsets[getVehicleName(player_hanging.heli)].back + (diff*(math.abs(player_hanging.line_percent-1))),helicopter_offsets[getVehicleName(player_hanging.heli)].z)
				end
				
				-- set the hanging animation, check for leg up/down changes
				local _,anim = getPedAnimation(p)
				if anim == "FIN_Hang_Loop" then
					if player_hanging.legs_up == true then
						setPedAnimation(p,"FINALE","FIN_LegsUp_Loop",-1,true,false,false)
					end
				elseif anim == "FIN_LegsUp_Loop" then
					if player_hanging.legs_up == false then
						setPedAnimation(p,"FINALE","FIN_Hang_Loop",-1,true,false,false)
					end
			--	elseif anim ~= "FIN_Hang_Loop" and anim ~= "FIN_LegsUp_Loop" then
				else
					if player_hanging.legs_up then
						setPedAnimation(p,"FINALE","FIN_LegsUp_Loop",-1,true,false,false)
					else
						setPedAnimation(p,"FINALE","FIN_Hang_Loop",-1,true,false,false)
					end
				end
				
				-- set hanging rotation
				local _,_,rz = getElementRotation(player_hanging.heli)
				local zrot = 90
				if player_hanging.side then
					if player_hanging.side == "left" then zrot = -90 elseif player_hanging.side == "right" then zrot = 90 end
				end
				setPedRotation(p,rz+zrot+helicopter_offsets[getVehicleName(player_hanging.heli)].facing)
			end
		end
	end
end)


function GetPointIntersectOnLine(px,py,pz,x1,y1,z1,x2,y2,z2)
	local line_direction = {x2-x1,y2-y1,z2-z1}
	
	local t = Dot(line_direction,{px-x1,py-y1,pz-z1}) / Dot(line_direction,line_direction)
	
	if t>1 then t = 1 end
	if t<0 then t = 0 end

	local p = {x1+((x2-x1)*t),y1+((y2-y1)*t),z1+((z2-z1)*t)}
	
	return p,t,getDistanceBetweenPoints3D(p[1],p[2],p[3],px,py,pz)
end


function Dot(p1,p2)
	return p1[1]*p2[1] + p1[2]*p2[2] + p1[3]*p2[3]
end


-- track all the helicopters streamed in
addEventHandler("onClientElementStreamIn",root,function()
	if getElementType(source)=="vehicle" then
		if getVehicleType(source)=="Helicopter" then
			table.insert(vehicles,source)
		end
--	elseif getElementType(source)=="player" then
	end
end)


-- this doesnt seem to trigger when a vehicle is destroyed, so we have to get that from the server with onElementDestroy
addEventHandler("onClientElementStreamOut",root,function()
	if getElementType(source)=="vehicle" then
		if getVehicleType(source)=="Helicopter" then
			for i,v in ipairs(vehicles) do
				if source == v then
					table.remove(vehicles,i)

					-- if the target heli streamed out (ie: there are no other helis closer)
					if source == target.vehicle then
						target.vehicle = nil
						target.distance = track_distance
					end
					break
				end
			end
		end
	end
end)


addEvent("onClientVehicleDestroy",true)
addEventHandler("onClientVehicleDestroy",root,function(vehicle)
	for i,v in ipairs(vehicles) do
		if vehicle == v then
			table.remove(vehicles,i)
			
			if vehicle == target.vehicle then
				target.vehicle = nil
				target.distance = track_distance
			end
			break
		end
	end
end)


function onClientVehicleStartEnter(player,seat)
--	if player == local_player then outputChatBox("vehicle start enter") end
	if player == local_player and getElementData(player,"hanging") then
--		outputChatBox("vehicle start enter cancelled")
		cancelEvent()
	end
end
addEventHandler("onClientVehicleStartEnter",root,onClientVehicleStartEnter)


function onClientPlayerWasted()
	-- died whilst hanging, so drop
	if source == local_player then
		local player_hanging = getElementData(source,"hanging")
		if player_hanging then
			triggerEvent("PlayerDrop",local_player,"dead",player_hanging.heli)
		end
	end
end
addEventHandler("onClientPlayerWasted",root,onClientPlayerWasted)
