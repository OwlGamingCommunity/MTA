function glue()
	local player = getLocalPlayer()
	local myVehicle = getPedOccupiedVehicle(player)
	if myVehicle and getElementAttachedTo(myVehicle) then
		triggerServerEvent("unglueVehicle", myVehicle)
	elseif not myVehicle and getElementAttachedTo(player) then
		triggerServerEvent("ungluePlayer", player)
	else
		if not myVehicle then
			local vehicle = getPedContactElement(player)
			if getElementType(vehicle) == "vehicle" then
				
				local px, py, pz = getElementPosition(player)
				local vx, vy, vz = getElementPosition(vehicle)
				local sx = px - vx
				local sy = py - vy
				local sz = pz - vz
				
				local rotpX = 0
				local rotpY = 0
				local rotpZ = getPedRotation(player)
				
				local rotvX,rotvY,rotvZ = getElementRotation(vehicle)
				
				local t = math.rad(rotvX)
				local p = math.rad(rotvY)
				local f = math.rad(rotvZ)
				
				local ct = math.cos(t)
				local st = math.sin(t)
				local cp = math.cos(p)
				local sp = math.sin(p)
				local cf = math.cos(f)
				local sf = math.sin(f)
				
				local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
				local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
				local y = st*sz - sf*ct*sx + cf*ct*sy
				
				local rotX = rotpX - rotvX
				local rotY = rotpY - rotvY
				local rotZ = rotpZ - rotvZ
				
				local slot = getPedWeaponSlot(player)

				triggerServerEvent("gluePlayer", player, slot, vehicle, x, y, z, rotX, rotY, rotZ)
			end
		else
			local attachMe, attachedTo
			local vehicles = getElementsByType("vehicle")
			local closest, cdist = nil, 100
			local mx,my,mz = getElementPosition(myVehicle)
			for k,v in ipairs(vehicles) do
				if isElementStreamedIn(v) and v ~= myVehicle then
					local x,y,z = getElementPosition(v)
					local tmpdist = getDistanceBetweenPoints3D(x,y,z,mx,my,mz)
					if tmpdist < cdist then
						cdist = tmpdist
						closest = v
					end
				end
			end

			if cdist > 5 or cdist == nil then
				return false
			end

			local vtype = getElementModel(myVehicle)
			if vtype == (487 or 548 or 425 or 417 or 488 or 497 or 563 or 447 or 469) then
				attachMe = closest
				attachedTo = myVehicle
			else 
				attachMe = myVehicle
				attachedTo = closest
			end
			
			local px, py, pz = getElementPosition(attachedTo)
			local vx, vy, vz = getElementPosition(attachMe)
			local sx = px - vx
			local sy = py - vy
			local sz = pz - vz
			
			local rotpX, rotpY, rotpZ = getElementRotation(attachedTo)
			local rotvX, rotvY, rotvZ = getElementRotation(attachMe)
			
			local t = math.rad(rotvX)
			local p = math.rad(rotvY)
			local f = math.rad(rotvZ)
			
			local ct = math.cos(t)
			local st = math.sin(t)
			local cp = math.cos(p)
			local sp = math.sin(p)
			local cf = math.cos(f)
			local sf = math.sin(f)
			
			local z = ct*cp*sz + (sf*st*cp + cf*sp)*sx + (-cf*st*cp + sf*sp)*sy
			local x = -ct*sp*sz + (-sf*st*sp + cf*cp)*sx + (cf*st*sp + sf*cp)*sy
			local y = st*sz - sf*ct*sx + cf*ct*sy
			
			local rotX = rotpX - rotvX
			local rotY = rotpY - rotvY
			local rotZ = rotpZ - rotvZ
			
				
			triggerServerEvent("glueVehicle", attachMe, attachedTo, x*-1, y*-1, z*-1, rotX, rotY, rotZ)
		end
	end
end
addCommandHandler("glue",glue)