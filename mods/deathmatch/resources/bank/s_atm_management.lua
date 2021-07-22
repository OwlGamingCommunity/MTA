local noSpawnZone = createColSphere(275.6396484375, -2051.4541015625, 3088.8173828125, 25)

function createATM(thePlayer, commandName, withdraw, deposit)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		if isElementWithinColShape(thePlayer, noSpawnZone) then
			outputChatBox("Fuck you Choov", thePlayer, 0, 255, 255)
		elseif not (withdraw) or not (deposit) then
			outputChatBox("SYNTAX: /" .. commandName .. " [WITHDRAW LIMIT / 0 = Infinite] [DEPOSIT - 1 = true, 0 = false]", thePlayer, 255, 194, 14)
			outputChatBox("Type /atmfast to add a default ATM.", thePlayer, 255, 194, 14)
		elseif (tonumber(withdraw)) and (tonumber(deposit)) then
			local dimension = getElementDimension(thePlayer)
			local interior = getElementInterior(thePlayer)
			local x, y, z  = getElementPosition(thePlayer)
			local rotation = getPedRotation(thePlayer)
			local withdrawlimit = tonumber(withdraw)
			local depositlimit = tonumber(deposit)
			z = z - 0.3
			if (tonumber(deposit) > 1) or (tonumber(deposit) < 0) then
				outputChatBox("SYNTAX: /" .. commandName .. " [WITHDRAW LIMIT / 0 = Infinite] [DEPOSIT - 1 = true, 0 = false]", thePlayer, 255, 194, 14)
			else
				local id = mysql:query_insert_free("INSERT INTO atms SET x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .. "', z='" .. mysql:escape_string(z) .. "', dimension='" .. mysql:escape_string(dimension) .. "', interior='" .. mysql:escape_string(interior) .. "', rotation='" .. mysql:escape_string(rotation) .. "', deposit='" ..mysql:escape_string(depositlimit).. "', `limit`="..mysql:escape_string(withdrawlimit))
					
				if (id) then
					local object = createObject(2942, x, y, z, 0, 0, rotation-180)
					exports.pool:allocateElement(object)
					setElementDimension(object, dimension)
					setElementInterior(object, interior)
					setElementDataEx(object, "depositable", tonumber(deposit), false)
					setElementDataEx(object, "limit", tonumber(withdraw), false)
				
					local px = x + math.sin(math.rad(-rotation)) * 0.8
					local py = y + math.cos(math.rad(-rotation)) * 0.8
					local pz = z
			
					setElementDataEx(object, "dbid", id, true)

					x = x + ((math.cos(math.rad(rotation)))*5)
					y = y + ((math.sin(math.rad(rotation)))*5)
					setElementPosition(thePlayer, x, y, z)
			
					outputChatBox("ATM created with ID #" .. id .. "!", thePlayer, 0, 255, 0)
				else
					outputChatBox("There was an error while creating an ATM. Try again.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("addatm", createATM, false, false)

function createFastATM(thePlayer, commandName)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		if isElementWithinColShape(thePlayer, noSpawnZone) then
			outputChatBox("Fuck you Choov", thePlayer, 0, 255, 255)
		else
			local dimension = getElementDimension(thePlayer)
			local interior = getElementInterior(thePlayer)
			local x, y, z  = getElementPosition(thePlayer)
			local rotation = getPedRotation(thePlayer)
		
			z = z - 0.3
		
			local id = mysql:query_insert_free("INSERT INTO atms SET x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .. "', z='" .. mysql:escape_string(z) .. "', dimension='" .. mysql:escape_string(dimension) .. "', interior='" .. mysql:escape_string(interior) .. "', rotation='" .. mysql:escape_string(rotation) .. "',`limit`=5000")
				
			if (id) then
				local object = createObject(2942, x, y, z, 0, 0, rotation-180)
				exports.pool:allocateElement(object)
				setElementDimension(object, dimension)
				setElementInterior(object, interior)
				setElementDataEx(object, "depositable", 0, false)
				setElementDataEx(object, "limit", 5000, false)
			
				local px = x + math.sin(math.rad(-rotation)) * 0.8
				local py = y + math.cos(math.rad(-rotation)) * 0.8
				local pz = z
			
				setElementDataEx(object, "dbid", id, true)

				x = x + ((math.cos(math.rad(rotation)))*5)
				y = y + ((math.sin(math.rad(rotation)))*5)
				setElementPosition(thePlayer, x, y, z)
			
				outputChatBox("ATM created with ID #" .. id .. "!", thePlayer, 0, 255, 0)
			else
				outputChatBox("There was an error while creating an ATM. Try again.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("atmfast", createFastATM, false, false)

function loadAllATMs()
	local result = mysql:query("SELECT id, x, y, z, rotation, dimension, interior, deposit, `limit` FROM atms")
	local counter = 0
	
	if (result) then
		local continue = true
		while continue do
			local row = mysql:fetch_assoc(result)
			if not row then break end
			
			local id = tonumber(row["id"])
			local x = tonumber(row["x"])
			local y = tonumber(row["y"])
			local z = tonumber(row["z"])

			local rotation = tonumber(row["rotation"])
			local dimension = tonumber(row["dimension"])
			local interior = tonumber(row["interior"])
			local deposit = tonumber(row["deposit"])
			local limit = tonumber(row["limit"])
			
			local object = createObject(2942, x, y, z, 0, 0, rotation-180)
			exports.pool:allocateElement(object)
			setElementDimension(object, dimension)
			setElementInterior(object, interior)
			setElementDataEx(object, "depositable", deposit, false)
			setElementDataEx(object, "limit", limit, false)
			
			local px = x + math.sin(math.rad(-rotation)) * 0.8
			local py = y + math.cos(math.rad(-rotation)) * 0.8
			local pz = z
			
			setElementDataEx(object, "dbid", id, true)
			
			counter = counter + 1
		end
		mysql:free_result(result)
	end
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllATMs)

function deleteATM(thePlayer, commandName, id)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		if not (id) then
			outputChatBox("SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
		else
			id = tonumber(id)
				
			local counter = 0
			local objects = getElementsByType("object", getResourceRootElement())
			for k, theObject in ipairs(objects) do
				local objectID = getElementData(theObject, "dbid")
				if (objectID==id) then
					destroyElement(theObject)
					counter = counter + 1
				end
			end
			
			if (counter>0) then -- ID Exists
				local query = mysql:query_free("DELETE FROM atms WHERE id='" .. mysql:escape_string(id) .. "'")
				
				outputChatBox("ATM #" .. id .. " Deleted!", thePlayer, 0, 255, 0)
			else
				outputChatBox("ATM ID does not exist!", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("delatm", deleteATM, false, false)

function getNearbyATMs(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Nearby ATMs:", thePlayer, 255, 126, 0)
		local count = 0
		
		for k, theObject in ipairs(getElementsByType("object", resourceRoot)) do
			local x, y, z = getElementPosition(theObject)
			local distance = getDistanceBetweenPoints3D(posX, posY, posZ, x, y, z)
			if (distance<=10) then
				local dbid = getElementData(theObject, "dbid")
				outputChatBox("   ATM with ID " .. dbid .. ".", thePlayer)
				count = count + 1
			end
		end
		
		if (count==0) then
			outputChatBox("   None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("nearbyatms", getNearbyATMs, false, false)

function getATMName(theAtm)
	return "ATM Machine ID#"..getElementData(theAtm, "dbid").." at "..exports.global:getElementZoneName(theAtm)
end

