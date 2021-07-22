mysql = exports.mysql

tags = {1524, 1525, 1526, 1527, 1528, 1529, 1530, 1531 }

function makeTagObject(cx, cy, cz, rot, interior, dimension)
	local tag = getElementData(source, "tag")
	if (tag~=9) then
		local dbid = getElementData(client, "account:character:id")
		local obj = createObject(tags[tag], cx, cy, cz, 0, 0, rot+90)
		exports.pool:allocateElement(obj)
		setElementDimension(obj, dimension)
		setElementInterior(obj, interior)
		
		local id = mysql:query_insert_free("INSERT INTO tags SET creator='"..mysql:escape_string(dbid).."', x='" .. mysql:escape_string(cx) .. "', y='" .. mysql:escape_string(cy) .. "', z='" .. mysql:escape_string(cz) .. "', interior='" .. mysql:escape_string(interior) .. "', dimension='" .. mysql:escape_string(dimension) .. "', rx='0', ry='0', rz='" .. mysql:escape_string(rot+90) .. "', modelid='" .. mysql:escape_string(tags[tag]) .. "', creationdate=NOW()")
		exports.global:sendLocalMeAction(source, "tags the wall.")
		exports.anticheat:changeProtectedElementDataEx(obj, "dbid", id, false)
		exports.anticheat:changeProtectedElementDataEx(obj, "creator", dbid, false)
		exports.anticheat:changeProtectedElementDataEx(obj, "type", "tag")
		outputChatBox("You have tagged the wall!", source, 255, 194, 14)
	else
		local distance = 5
		local colshape = createColSphere(cx, cy, cz, distance)
		exports.pool:allocateElement(colshape)
		local objects = getElementsWithinColShape(colshape, "object")
		
		local object = nil
		for key, value in ipairs(objects) do
			local objtype = getElementData(value, "type")
			if objtype=="tag" then
				local tx, ty, tz = getElementPosition(value)
				local tdistance = getDistanceBetweenPoints3D(cx,cy,cz,tx,ty,tz)
				if tdistance < distance then
					object = value
					distance = tdistance
				end
			end
		end
		
		if (object) then
			local id = getElementData(object, "dbid")
			outputChatBox("You removed the tag. You earnt $30 for doing so.", source, 255, 194, 14)
			exports.global:giveMoney(source, 30)
			destroyElement(object)
			local query = mysql:query_free("DELETE FROM tags WHERE id='" .. mysql:escape_string(id) .. "'")
		end
		destroyElement(colshape)
	end
end
addEvent("createTag", true )
addEventHandler("createTag", getRootElement(), makeTagObject)

function clearNearbyTag(thePlayer)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local x, y, z = getElementPosition(thePlayer)
		local object = nil
		local dist = 999999
		for key, value in ipairs(exports.global:getNearbyElements(thePlayer, "object")) do
			local objtype = getElementData(value, "type")
			if (objtype=="tag") then
				local ox, oy, oz = getElementPosition(value)
				local distance = getDistanceBetweenPoints3D(x, y, z, ox, oy, oz)
				if (distance<dist) then
					object = value
					dist = distance
				end
			end
		end
		
		if (object) then
			local id = getElementData(object, "dbid")
			destroyElement(object)
			local query = mysql:query_free("DELETE FROM tags WHERE id='" .. mysql:escape_string(id) .. "'")
			outputChatBox("Deleted tag with ID #" .. id .. ".", thePlayer, 0, 255, 0)
		else
			outputChatBox("You are not near any tag.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("delnearbytag", clearNearbyTag, false, false)

function showNearbyTags(thePlayer)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local x, y, z = getElementPosition(thePlayer)
		local count = 0
		outputChatBox("Nearby Spraytags:", thePlayer, 255, 126, 0)
		for key, value in ipairs(exports.global:getNearbyElements(thePlayer, "object")) do
			local objtype = getElementData(value, "type")
			if (objtype=="tag") then
				local id = getElementData(value, "dbid")
				local ownerName = exports['cache']:getCharacterName(getElementData(value, "creator"), true):gsub("_", " ") or "?"
				outputChatBox("  #"..id .." by " .. ownerName, thePlayer, 255, 126, 0)
				count = count + 1
			end
		end
		if (count==0) then
			outputChatBox("   None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("nearbytags", showNearbyTags, false, false)

function loadAllTags(res)
	-- delete old tags
	mysql:query_free("DELETE FROM tags WHERE DATEDIFF(NOW(), creationdate) > 7")
	
	-- Load current ones
	local result = mysql:query("SELECT * FROM tags")
	local count = 0
	local highest = 0
	
	if (result) then
		local run = true
		while run do
			local row = exports.mysql:fetch_assoc(result)
			if not (row) then
				break
			end
			
			local id = tonumber(row["id"])
					
			local x = tonumber(row["x"])
			local y = tonumber(row["y"])
			local z = tonumber(row["z"])
				
			local interior = tonumber(row["interior"])
			local dimension = tonumber(row["dimension"])
				
			local rx = tonumber(row["rx"])
			local ry = tonumber(row["ry"])
			local rz = tonumber(row["rz"])
			local modelid = tonumber(row["modelid"])
				
			local object = createObject(modelid, x, y, z, rx, ry, rz)
			exports.pool:allocateElement(object)
			setElementInterior(object, interior)
			setElementDimension(object, dimension)
			exports.anticheat:changeProtectedElementDataEx(object, "dbid", id, false)
			exports.anticheat:changeProtectedElementDataEx(object, "type", "tag")
			exports.anticheat:changeProtectedElementDataEx(object, "creator", tonumber(row["creator"]))
			count = count + 1
			if id > highest then
				highest = id
			end
		end

		--mysql:query_free("ALTER TABLE `tags` AUTO_INCREMENT = " .. mysql:escape_string((highest + 1))) Not needed.
		
	end
	mysql:free_result(result)
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllTags)

function setTag(thePlayer, commandName, newTag)
	if not (newTag) then
		outputChatBox("SYNTAX: " .. commandName .. " [Tag # 1->8].", thePlayer, 255, 194, 14)
	elseif getElementData(thePlayer, "tag") == 9 then
		outputChatBox("You can't set your tag while on City Maintenance.", thePlayer, 255, 0, 0)
	else
		local newTag = math.floor(tonumber(newTag) or 0)
		if (newTag>0) and (newTag<9) then
			
			--if (teamName~="Park Avenue Nortenos XIV") and (newTag==5) then -- Nortenos
			--	outputChatBox("You can't use this tag.", thePlayer, 255, 0, 0)
			--[[elseif (teamName~="Los Depredadores 13") and (newTag==4) then -- LD
				outputChatBox("You can't use this tag.", thePlayer, 255, 0, 0)
			elseif (teamName~="East Seville Saints") and (newTag==8) then -- ESS
				outputChatBox("You can't use this tag.", thePlayer, 255, 0, 0)]]
			--else
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "tag", newTag, false)
				outputChatBox("Tag changed to #" .. newTag .. ".", thePlayer, 0, 255, 0)
				mysql:query_free("UPDATE characters SET tag=" .. mysql:escape_string(newTag) .. " WHERE id = " .. mysql:escape_string(getElementData(thePlayer, "dbid")))
			--end
		else
			outputChatBox("Invalid value, please enter a value between 1 and 8.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("settag", setTag)