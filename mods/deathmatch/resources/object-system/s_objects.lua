local objects = {}

addEventHandler("onResourceStart", resourceRoot, function ()
	dbQuery(function (handle)
		local results = dbPoll(handle, 0)

		for _, row in ipairs(results) do
			loadDimension(row.dimension)
		end
	end, exports.mysql:getConn('mta'), "SELECT distinct(`dimension`) FROM `objects` ORDER BY `dimension` ASC")
end)

--[[
-- Loads all objects from the database for a single dimension from
-- either the objects table or temporary objects table.
--]]
function loadDimension(dimension, onComplete)
	objects[dimension] = {}

	dbQuery(function (handle)
		local results = dbPoll(handle, 0)

		for _, row in ipairs(results) do
			table.insert(objects[dimension], {
				model = row.model, 
				x = row.posX, 
				y = row.posY, 
				z = row.posZ, 
				rot_x = row.rotX,
				rot_y = row.rotY, 
				rot_z = row.rotZ, 
				interior = row.interior, 
				is_solid = row.solid == 1, 
				is_double_sided = row.doublesided == 1, 
				id = tostring(row.id), 
				scale = row.scale, 
				is_breakable = row.breakable == 1, 
				alpha = row.alpha or 255
			})
		end

        syncDimension(dimension)

        if type(onComplete) == 'function' then
            onComplete(#objects[dimension])
        end
	end, exports.mysql:getConn('mta'), "SELECT * FROM objects WHERE dimension = ?", dimension)
end

--[[
-- Called by the UCP to process uploading a custom interior.
--]]
function processCustomInterior(player, command, dimension, playerUsername, userId)
    dimension = dimension and tonumber(dimension) or 0
    if dimension < 1 then
        return false
    end

    exports.global:sendMessageToAdmins("[UCP] Player "..playerUsername.." has uploaded a custom interior for property ID#"..dimension..".")

    if userId then
        exports['interior-manager']:addInteriorLogs(dimension, 'Uploaded custom interior.', userId)
    end

	loadDimension(tonumber(dimension), function (objectCount)
		exports.interior_system:realReloadInterior(dimension)

        exports.global:sendMessageToAdmins("[UCP] Loaded "..objectCount.." interior custom objects to property ID#"..dimension)
	end)
end

--[[
-- Used by the interior system when changing interior ID or removing 
-- an interior to clear out any objects from a previous custom int.
--]]
function removeInteriorObjects(dimension)
	dbExec(exports.mysql:getConn('mta'), "DELETE FROM objects WHERE dimension = ?", dimension)
	objects[dimension] = nil
	triggerClientEvent("object:clear", root, dimension)
end

--[[
-- Transfers all of the cached objects from the server
-- to the player's client who requested so they can be
-- created as actual objects.
--]]
function transferDimension(player, dimension)
	if dimension and objects[dimension] then
		triggerClientEvent(player, "object:sync", root, objects[dimension], dimension)
	else
		triggerClientEvent(player, "object:safeTrue", root)
	end
end

--[[
-- Used by loadDimension to transfer the loaded objects to any
-- players who are currently in the dimension that was loaded.
--]]
function syncDimension(dimension)
	for _, player in ipairs(exports.pool:getPoolElementsByType("player")) do
		if dimension == getElementDimension(player) then
			transferDimension(player, dimension)
		end
	end
end

addEvent("object:requestsync", true)
addEventHandler("object:requestsync", root, function (dimension)
	transferDimension(source, dimension)
end)

addEvent("onPlayerInteriorChange", true)
addEventHandler("onPlayerInteriorChange", root, function (interior, dim)
	triggerClientEvent("onClientInteriorChange", root, client, interior, dim)
end)

addCommandHandler("reloadinterior", function (player, command, dimension)
	if not exports.integration:isPlayerTrialAdmin(player) then
		return
	end

	if not dimension then
		outputChatBox("Syntax: /" .. command .. " [dimension] - Reloads all custom objects uploaded to the interior.", player, 255, 255, 255)
	end

	loadDimension(dimension, function (objectCount)
		outputChatBox("You have successfully re-created the " .. objectCount .. " objects in dimension " .. dimension .. ".", player, 100, 255, 100)
	end)
end, false, false)