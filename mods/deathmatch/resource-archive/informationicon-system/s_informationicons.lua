mysql = exports.mysql

-- Done by Anthony
local informationicons = { }

function SmallestID() -- finds the smallest ID in the SQL instead of auto increment
	local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM informationicons AS e1 LEFT JOIN informationicons AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result then
		local id = tonumber(result["nextID"]) or 1
		return id
	end
	return false
end

function makeInformationIcon(thePlayer, commandName, ...)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
	if ... then
		local arg = {...}
		local information = table.concat( arg, " " )
		local x, y, z = getElementPosition(thePlayer)
		--z = z + 0.5 only use for i object
		local rx, ry, rz = getElementRotation(thePlayer)
		local interior = getElementInterior(thePlayer)
		local dimension = getElementDimension(thePlayer)
		local id = SmallestID()
		local createdby = getPlayerName(thePlayer):gsub("_", " ")
		local query = mysql:query_free("INSERT INTO informationicons SET id="..mysql:escape_string(id)..",createdby='"..mysql:escape_string(createdby).."',x='"..mysql:escape_string(x).."', y='"..mysql:escape_string(y).."', z='"..mysql:escape_string(z).."', rx='"..mysql:escape_string(rx).."', ry='"..mysql:escape_string(ry).."', rz='"..mysql:escape_string(rz).."', interior='"..mysql:escape_string(interior).."', dimension='"..mysql:escape_string(dimension).."', information='"..mysql:escape_string(information).."'")
		if query then
			informationicons[id] = createPickup(x, y, z, 3, 1239, 0)--createObject(1239, x, y, z, rx, ry, rz)
			setElementInterior(informationicons[id], interior)
			setElementDimension(informationicons[id], dimension)
			setElementData(informationicons[id], "informationicon:id", id)
			setElementData(informationicons[id], "informationicon:createdby", createdby)
			setElementData(informationicons[id], "informationicon:x", x)
			setElementData(informationicons[id], "informationicon:y", y)
			setElementData(informationicons[id], "informationicon:z", z)
			setElementData(informationicons[id], "informationicon:rx", rx)
			setElementData(informationicons[id], "informationicon:ry", ry)
			setElementData(informationicons[id], "informationicon:rz", rz)
			setElementData(informationicons[id], "informationicon:interior", interior)
			setElementData(informationicons[id], "informationicon:dimension", dimension)
			setElementData(informationicons[id], "informationicon:information", information)
			outputChatBox("Information icon created with ID: "..id, thePlayer, 0, 255, 0)
		else
			outputChatBox("Error creating information icon. Please report on the mantis.", thePlayer, 255, 0, 0)
		end
		else
			outputChatBox("SYNTAX: /addii [Information]", thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("addii", makeInformationIcon, false, false)

function saveAllInformationIcons()
	for key, value in ipairs (informationicons) do
		local id = getElementData(informationicons[key], "informationicon:id")
		local createdby = getElementData(informationicons[key], "informationicon:createdby")
		local x = getElementData(informationicons[key], "informationicon:x")
		local y = getElementData(informationicons[key], "informationicon:y")
		local z = getElementData(informationicons[key], "informationicon:z")
		local rx = getElementData(informationicons[key], "informationicon:rx")
		local ry = getElementData(informationicons[key], "informationicon:ry")
		local rz = getElementData(informationicons[key], "informationicon:rz")
		local interior = getElementData(informationicons[key], "informationicon:interior")
		local dimension = getElementData(informationicons[key], "informationicon:dimension")
		local information = getElementData(informationicons[key], "informationicon:information")
		mysql:query_free("UPDATE informationicons SET createdby = '" .. mysql:escape_string(createdby) .. "', x = '" .. mysql:escape_string(x) .. "', y = '" .. mysql:escape_string(y) .. "', z = '" .. mysql:escape_string(z) .. "', rx = '" .. mysql:escape_string(rx) .. "', ry = '" .. mysql:escape_string(ry) .. "', rz = '" .. mysql:escape_string(rz) .. "', interior = '" .. mysql:escape_string(interior) .. "', dimension = '" .. mysql:escape_string(dimension) .. "', information = '" .. mysql:escape_string(information) .. "' WHERE id='" .. mysql:escape_string(id) .. "'")
	end
end
addEventHandler("onResourceStop", getResourceRootElement(), saveAllInformationIcons)


function loadAllInformationIcons()
	local ticks = getTickCount( )
	local counter = 0
	local result = mysql:query("SELECT * FROM `informationicons`")
	while true do
		local row = mysql:fetch_assoc(result)
		if not row then break end
		local id = tonumber(row["id"])
		local createdby = tostring(row["createdby"])
		local x = tonumber(row["x"])
		local y = tonumber(row["y"])
		local z = tonumber(row["z"])
		local rx = tonumber(row["rx"])
		local ry = tonumber(row["ry"])
		local rz = tonumber(row["rz"])
		local interior = tonumber(row["interior"])
		local dimension = tonumber(row["dimension"])
		local information = tostring(row["information"])
		informationicons[id] = createPickup(x, y, z, 3, 1239, 0)--createObject(1239, x, y, z, rx, ry, rz)
		setElementInterior(informationicons[id], interior)
		setElementDimension(informationicons[id], dimension)
		setElementData(informationicons[id], "informationicon:id", id)
		setElementData(informationicons[id], "informationicon:createdby", createdby)
		setElementData(informationicons[id], "informationicon:x", x)
		setElementData(informationicons[id], "informationicon:y", y)
		setElementData(informationicons[id], "informationicon:z", z)
		setElementData(informationicons[id], "informationicon:rx", rx)
		setElementData(informationicons[id], "informationicon:ry", ry)
		setElementData(informationicons[id], "informationicon:rz", rz)
		setElementData(informationicons[id], "informationicon:interior", interior)
		setElementData(informationicons[id], "informationicon:dimension", dimension)
		setElementData(informationicons[id], "informationicon:information", information)
		counter = counter + 1
	end
	outputDebugString("Loaded " .. counter .. " information icons in " .. ( getTickCount( ) - ticks ) .. "ms")
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllInformationIcons)

function getNearbyInformationIcons(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Nearby Information Icons:", thePlayer, 255, 126, 0)
		local count = 0
		for key, value in ipairs (informationicons) do
			local dbid = getElementData(informationicons[key], "informationicon:id")
			if dbid then
				local x, y, z = getElementPosition(informationicons[key])
				local distance = getDistanceBetweenPoints3D(posX, posY, posZ, x, y, z)
				if distance <= 10 and getElementDimension(informationicons[key]) == getElementDimension(thePlayer) and getElementInterior(informationicons[key]) == getElementInterior(thePlayer) then
					local createdby = getElementData(informationicons[key], "informationicon:createdby")
					local information = getElementData(informationicons[key], "informationicon:information")
					outputChatBox("   #" .. dbid .. " by " .. createdby .. " - Icon: " .. information, thePlayer, 255, 126, 0)
					count = count + 1
				end
			end
		end		
		if (count==0) then
			outputChatBox("   None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("nearbyii", getNearbyInformationIcons, false, false)

function deleteInformationIcon(thePlayer, commandName, ID)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if tonumber(ID) then
			local ID = tonumber(ID)
			if informationicons[ID] then
				for k,v in pairs(getAllElementData(informationicons[ID])) do
					removeElementData(informationicons[ID],k)
				end
				destroyElement(informationicons[ID])
				local query = mysql:query_free("DELETE FROM informationicons WHERE id='"..mysql:escape_string(ID).."'")
				if query then
					informationicons[ID] = nil
					outputChatBox("Information icon ID: "..ID.." deleted.", thePlayer, 0, 255, 0)
				else
					outputChatBox("Error deleting information icon. Please report on the mantis.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("An information icon with that ID does not exist.", thePlayer, 255, 0, 0)
			end
		else
			outputChatBox("SYNTAX: /delii [ID]", thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("delii", deleteInformationIcon, false, false)