local images = { }
local searched = {}
local refresh_rate = 0 --hours , 0 = never recache.
local default_avatar_size = 0

local function getPath(url)
	return 'images_cache/' .. md5(tostring(url)) .. '.tex'
end

-- Leave 'data' parameter empty if you intend to add a new image from URL.
-- Maxime / 2015.6.28
function addImage(id, url, data)
	if not id then
		outputDebugString("[CACHE] images / Server / addImage / url are required parameters.")
		return
	end

	if data then
		images[id] = data

		--Check and clear this image data if it is already been cached in server's file system.
		local filename = removeImage(id)

		local file = fileCreate(filename)
		local size = fileWrite(file, data)
		fileClose(file)
		if size and size>0 then
			outputDebugString("[CACHE] Images / Server / addImage / Cached image - "..id.." in server's file system as '"..filename.."'.Total: "..exports.global:formatMoney(math.floor(size/1000)).."KB")
		else
			outputDebugString("[CACHE] Images / Server / addImage / Couln't cache image - "..id.." in server's file system.")
		end
	else
		fetchRemote (url, "cache/images", 3, addImageAsync, "", true, url, source, id)
	end
end
addEvent("cache:addImage", true)
addEventHandler("cache:addImage", root, addImage)

local function sendImageToClient(client_to_sync, id, data)
	-- would be a disater of source is nil, it would send to all clients, we don't want that.
	if client_to_sync and isElement(client_to_sync) and getElementType(client_to_sync) == 'player' then
		if triggerLatentClientEvent(client_to_sync, "cache:addImage", 50000, false, client_to_sync, id, data) then
			--outputDebugString("[CACHE] Images / Server / sendImageToClient / Sending image data to "..getPlayerName(client_to_sync).." limited at 50KB/s - "..tostring(id))
			return true
		end
	end
end

function addImageAsync(data, errno, url, client_to_sync, id)
	if errno == 0 then
		addImage(id, url, data)
		sendImageToClient(client_to_sync, id, data)
		searched[id] = getTickCount()
	else
		--outputDebugString("[CACHE] Images / Server / addImageAsync / Couldn't fetch image - "..tostring(id)..". Error Code: "..errno)
	end
end

function getImage(id, url)
	if not images[id] then
		-- Check file system
		local filename = getPath(id)
		if fileExists ( filename ) then
			local file = fileOpen(filename, true)
			if file then
				local size = fileGetSize(file)
				if tonumber(size) > 0 then
					images[id] = fileRead(file, size)
					-- Check if the image from server is up to date with id's.
					verifyServerImageFile(id, url, size)
				end
				fileClose(file)
			end
		end
	end

	-- if image is found somewhere on server .
	if images[id] then
		-- if image is older than refresh_rate, fetch it from id again to recache.
		local recached = false
		if searched[id] and refresh_rate > 0 and getTickCount() - searched[id] > 1000*60*60*refresh_rate then
			--outputDebugString("[CACHE] images / Server / getImage / cache refreshing and requested new image from server: "..id)
			-- Recache on server and also sent the file to client to recache client side for the player that requested for it.
			recached = triggerEvent('cache:addImage', source, id, url)
		end
		-- Send the current image to client who requested for this.
		if not recached then
			sendImageToClient(source, id, images[id])
		end
	else -- if image is NOT found anywhere on server, fetch it from URL again then send to client who requested it.
		--outputDebugString("[CACHE] images / Server / getImage / fetching image from URL: "..url)
		triggerEvent('cache:addImage', source, id, url)
	end
	return images[url]
end
addEvent("cache:getImage", true)
addEventHandler("cache:getImage", root, getImage)

function verifyClientImageFile(id, size)
	local filename = getPath(id)
	if fileExists ( filename ) then
		local file = fileOpen(filename, true)
		if file then
			local sizeServer = fileGetSize(file)
			if size ~= sizeServer then
				-- rebuilt image if it's not existed on server.
				if not images[id] then
					images[id] = fileRead(file, sizeServer)
				end
				sendImageToClient(source, id, images[id])
				--outputDebugString("[CACHE] Images / Server / verifyClientImageFile / Sending new image data to "..getPlayerName(source))
			end
			fileClose(file)
		end
	else -- if file doesn't exist on server, it shouldn't be on client.
		images[id] = nil
		triggerClientEvent(source, "cache:removeImage", source, id)
	end
end
addEvent("cache:verifyClientImageFile", true)
addEventHandler("cache:verifyClientImageFile", root, verifyClientImageFile)

function verifyServerImageFile(id, url, size)
	-- There will be no URL sent to the server if the user is offline so keep the cached image
	if url then
		fetchRemote (url, "cache/images", 3, function(data, errno, url, id)
			if errno == 0 then
				addImage(id, url, data)
				--outputDebugString("[CACHE] Images / Server / verifyServerImageFile / Done for "..id)
			else
				removeImage(id)
			end
		end, "", true, url, id)
	end
end
addEvent("cache:verifyServerImageFile", true)
addEventHandler("cache:verifyServerImageFile", root, verifyServerImageFile)

function removeImage(id, remove_from_client_too)
	images[id] = nil
	--Check if this image data is already been cached in server's file system.
	local filename = getPath(id)
	if fileExists ( filename ) then -- if yes, clear it.
		fileDelete(filename)
	end
	if remove_from_client_too and source and getElementType(source) == 'player' then
		triggerClientEvent(source, "cache:removeImage", source, id)
	end
	--outputDebugString("[CACHE] / images / server / removeImage / Requested by "..(source and getPlayerName(source) or "SYSTEM")..", Done for "..id)
	return filename
end
addEvent("cache:removeImage", true)
addEventHandler("cache:removeImage", root, removeImage)
