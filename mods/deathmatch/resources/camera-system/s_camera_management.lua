function loadAllTrafficCams(res)
	dbQuery(function(qh)
		local result = dbPoll(qh, 0)
		for _, row in pairs(result) do 
			loadOneTrafficCam(row["id"])
		end
	end, exports.mysql:getConn("mta"), "SELECT id FROM `speedcams` ORDER BY `id` ASC")
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllTrafficCams)

function loadOneTrafficCam(id)
	local query = dbQuery(exports.mysql:getConn("mta"), "SELECT * FROM `speedcams` WHERE `id`= ?", id)
	local result = dbPoll(query, -1)
	local row = result[1]
	if (row) then
		local id = tonumber(row["id"])
		local maxspeed = tonumber(row["maxspeed"])
		local interior = tonumber(row["interior"])
		local dimension = tonumber(row["dimension"])
		local x = tonumber(row["x"])
		local y = tonumber(row["y"])
		local z = tonumber(row["z"])-4
		local radius = tonumber(row["radius"])
		
		local enabled
		local state = tonumber(row["enabled"])
		
		if (state == 1) then
			enabled = true
		else
			enabled = false
		end

		-- And spawn it
		local colTube = createColTube(x, y, z, radius, 15)
		exports.pool:allocateElement(colTube)
		exports.anticheat:changeProtectedElementDataEx(colTube, "speedcam", true, false)
		exports.anticheat:changeProtectedElementDataEx(colTube, "speedcam:dbid", id, false)
		exports.anticheat:changeProtectedElementDataEx(colTube, "speedcam:maxspeed", maxspeed, false)
		exports.anticheat:changeProtectedElementDataEx(colTube, "speedcam:enabled", enabled, false)
			
		setElementInterior(colTube, interior)
		setElementDimension(colTube, dimension)
		
		-- Hook it up to the event system
		addEventHandler("onColShapeHit", colTube, monitorSpeed)
		addEventHandler("onColShapeLeave", colTube, stopMonitorSpeed)
	end
end

function createTrafficCam(thePlayer, commandName, maxSpeed)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		if not (maxSpeed) then
			outputChatBox("SYNTAX: /" .. commandName .. " [trigger speed in KPH]", thePlayer, 255, 194, 14)
		else
			if (tonumber(maxSpeed) > 35) then
				local x, y, z = getElementPosition(thePlayer)
				local dimension = getElementDimension(thePlayer)
				local interior = getElementInterior(thePlayer)
				
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "speedcam:new", true, false)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "speedcam:new:x", x, false)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "speedcam:new:y", y, false)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "speedcam:new:z", z, false)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "speedcam:new:dimension", dimension, false)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "speedcam:new:interior", interior, false)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "speedcam:new:maxspeed", tonumber(maxSpeed), false)
				outputChatBox("Okay, stored. Now set the outside of the speedcam with /setradius.", thePlayer, 255, 0, 0)
			else
				outputChatBox("The trigger speed needs to be above 35 KPH.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("addspeedcam", createTrafficCam, false, false)

function setTrafficCamRadius(thePlayer, commandName)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		local checkPoint = getElementData(thePlayer, "speedcam:new")
		if (checkPoint) then
			--outputDebugString("asd")
			-- Load saved data
			local x = getElementData(thePlayer, "speedcam:new:x")
			local y = getElementData(thePlayer, "speedcam:new:y")
			local z = getElementData(thePlayer, "speedcam:new:z")
			local dimension = getElementData(thePlayer, "speedcam:new:dimension")
			local interior = getElementData(thePlayer, "speedcam:new:interior")
			local maxspeed = getElementData(thePlayer, "speedcam:new:maxspeed")
			
			-- Fetch new data
			local newx, newy, newz = getElementPosition(thePlayer)
			local newdimension = getElementDimension(thePlayer)
			local newinterior = getElementInterior(thePlayer)
			
			-- Calulate radius
			local radius = math.floor(getDistanceBetweenPoints2D(x, y, newx, newy))
			if (radius > 99) then
				outputChatBox("Radius is too big.", thePlayer, 255, 0, 0)
			else
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "speedcam:new", false, false)
				local query = dbQuery(exports.mysql:getConn("mta"), "INSERT INTO `speedcams` SET `enabled` = 1, `radius` = ?, `maxspeed` = ?, `x` = ?, `y` = ?, `z` = ?, `interior` = ?, `dimension` = ?", radius, maxspeed, x, y, z, interior, dimension)
				local _, _, id = dbPoll(query, 1000)
				if (id) then
					outputChatBox("Speed camera created.", thePlayer, 0, 255, 0)
					loadOneTrafficCam(id)
				else
					outputChatBox("Failed to create speedcam.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("setradius", setTrafficCamRadius, false, false)

function delTrafficCam(thePlayer, commandName)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		local colShape = nil
			
		for key, possibleSpeedcam in ipairs(exports.pool:getPoolElementsByType("colshape")) do
			local isSpeedcam = getElementData(possibleSpeedcam, "speedcam")
			if (isSpeedcam) then
				if (isElementWithinColShape(thePlayer, possibleSpeedcam)) then
					colShape = possibleSpeedcam
				end
			end
		end
		--colShape = true
		if (colShape) then
			local id = getElementData(colShape, "speedcam:dbid")
			dbExec(exports.mysql:getConn("mta"), "DELETE FROM `speedcams` WHERE id = ?", id)
			outputChatBox("Speedcam #" .. id .. " deleted.", thePlayer)
			destroyElement(colShape)
		else
			outputChatBox("You are not in a speed camera.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("delspeedcam", delTrafficCam, false, false)

function getNearbyTrafficCams(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Nearby Speedcams:", thePlayer, 255, 126, 0)
		local found = false
		
		for k, theColshape in ipairs(exports.pool:getPoolElementsByType("colshape")) do
			local isSpeedcam = getElementData(theColshape, "speedcam")
			if (isSpeedcam) then
				local x, y = getElementPosition(theColshape)
				local distance = getDistanceBetweenPoints2D(posX, posY, x, y)
				if (distance<=20) then
					local dbid = getElementData(theColshape, "speedcam:dbid")
					local enabled = getElementData(theColshape, "speedcam:enabled")
					if (enabled) then
						outputChatBox("   ID " .. dbid .. " - Enabled.", thePlayer, 255, 126, 0)
					else
						outputChatBox("   ID " .. dbid .. " - Disabled.", thePlayer, 255, 126, 0)
					end
					found = true
				end
			end
		end
		
		if not (found) then
			outputChatBox("   None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("nearbyspeedcams", getNearbyTrafficCams, false, false)

function toggleTrafficCam(theColshape)
	local isSpeedcam = getElementData(theColshape, "speedcam")
	if (isSpeedcam) then
		local currentStatus = getElementData(theColshape, "speedcam:enabled")
		local dbid = getElementData(theColshape, "speedcam:dbid")
		exports.anticheat:changeProtectedElementDataEx(theColshape, "speedcam:enabled",  not currentStatus, false)
		if (newStatus == false) then
			dbExec(exports.mysql:getConn("mta"), "UPDATE `speedcams` SET `enabled`=1 WHERE `id`= ?", dbid)
			return 2
		else
			dbExec(exports.mysql:getConn("mta"), "UPDATE `speedcams` SET `enabled`=0 WHERE `id`= ?", dbid)
			return 1
		end
	end

end