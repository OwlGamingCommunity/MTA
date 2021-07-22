--fakevideo
--Script allows replacing textures in the game with a range of remote pictures to make animated textures
--Created by Exciter, 21.06.2014 (DD.MM.YYYY).
--Based upon iG texture-system (based on Exciter's uG/RPP texture-system), shader_cinema_fl by Ren712, and OwlGaming/Cat's fixes to texture-system based on mabako-clothingstore.

--settings
theItemID = 165

--cache
fakevideos = {}

--cat's cache solution
addEventHandler("onResourceStart", resourceRoot,
	function()
		local count = 0
		local result = exports.mysql:query("SELECT * FROM textures_animated")
		local time = getTickCount()
		if result then
			while true do
				row = exports.mysql:fetch_assoc(result)
				if not row then break end
				fakevideos[tonumber(row.id)] = { name = row.name, frames = fromJSON(row.frames), speed = tonumber(row.speed), creator = tonumber(row.createdBy), date = row.createdAt }
				--outputDebugString("fakevideos["..tostring(row.id).."] = { name = "..tostring(row.name)..", frames = "..tostring(fromJSON(row.frames))..", speed = "..tostring(row.speed)..", creator = "..tostring(row.createdBy)..", date = "..tostring(row.createdAt).." }")
				count = count + 1
			end
			outputDebugString("Loaded "..count.." animated texture records in "..math.ceil(getTickCount()-time).."ms")
			--outputDebugString("Counting "..#fakevideos.." fakevideos")
			--outputDebugString("fakevideos="..tostring(fakevideos).." fakevideos[3]="..tostring(fakevideos[3]))
			exports.mysql:free_result(result)
		end
	end)

function getPath(id, frame)
	return "cache/"..tostring(id).."_"..tostring(frame)..".tex"
end

function loadFromURL(id, texName, object, loadimg)
	local data = fakevideos[id]
	local frames = data.frames
	if frames and #frames > 0 then
		local framesPixels = {}
		for frame,url in ipairs(frames) do
			fetchRemote(url, function(str, errno)
				if str == "ERROR" then
					outputDebugString("fakevideo/s_fakevideo: "..tostring(errno).." url "..tostring(url))
				else
					local file = fileCreate(getPath(id, frame))
					fileWrite(file, str)
					fileClose(file)
					table.insert(framesPixels, {frame = frame, pixels = str, size = #str})
					if(frame == #frames) then --if this is the last frame
						if data.pending then
							triggerLatentClientEvent(data.pending, "fakevideo:file", resourceRoot, id, framesPixels, texName, object, loadimg)
							data.pending = nil
						end
					end
				end
			end)
		end
	else
		outputDebugString("fakevideo/s_fakevideo: loadFromURL - no such video")
	end
end

-- send frames to the client
addEvent("fakevideo:stream", true)
addEventHandler("fakevideo:stream", resourceRoot,
	function(id, texName, object, loadimg)
		local id = tonumber(id)
		-- if its not a number, this'll fail
		if type(id) == "number" then
			local data = fakevideos[id]
			if data then
				local allExist = true
				for k,v in ipairs(data.frames) do
					local path = getPath(id, k)
					if not fileExists(path) then
						allExist = false
						break
					end
				end
				if allExist then
					local framesPixels = {}
					for frame,url in ipairs(data.frames) do
						local path = getPath(id, frame)
						local file = fileOpen(path, true)
						if file then
							local size = fileGetSize(file)
							local pixels = fileRead(file, size)
							if #pixels == size then
								table.insert(framesPixels, {frame = frame, pixels = pixels, size = size})
							else
								outputDebugString('fakevideo/s_fakevideo:stream - file ' .. path .. ' read ' .. #pixels .. ' bytes, but is ' .. size .. ' bytes long')
							end
							fileClose(file)
						else
							outputDebugString('fakevideo/s_fakevideo:stream - file ' .. path .. ' existed but could not be opened?')
						end
					end
					triggerLatentClientEvent(client, 'fakevideo:file', resourceRoot, id, framesPixels, texName, object, loadimg)
				else
					-- try to load the files from urls
					if data.pending then
						table.insert(data.pending, client)
					else
						data.pending = { client }
						loadFromURL(id, texName, object, loadimg)
					end
				end
			else
				outputDebugString("fakevideo/s_fakevideo:stream - fakevideo #"..id.." do not exist.")
			end
		end
	end, false)

function getElementsInDimension(theType,dimension)
    local elementsInDimension = { }
      for key, value in ipairs(exports.pool:getPoolElementsByType(theType)) do
        if getElementDimension(value)==dimension then
        table.insert(elementsInDimension,value)
        end
      end
      return elementsInDimension
end

function loadDimensionAnimatedTextures(int, dimension)
	if not dimension then dimension = getElementDimension(client or source) end
	local dimensionAnimatedTextures = {} --format {id = id, texname = texture, object = object, loadimg = pathToLoadingImg, shaderData = shaderData}

	--check for video players
	local dimensionObjects = getElementsInDimension("object", dimension)
	for k,v in ipairs(dimensionObjects) do
		if getElementParent(getElementParent(v)) == getResourceRootElement(getResourceFromName("item-world")) then
			if exports.clubtec:isVideoPlayer(v) then
				local powerOn = exports['item-world']:getData(v, "active") == 1 or false
				if powerOn then
					local texName = tostring(getElementData(v, "itemValue"))
					local disc = exports.clubtec:getVideoPlayerCurrentVideoDisc(v) or 0
					if disc < 2 then
						disc = noDisc_id_clubtec
					end
					local shaderData = exports['item-world']:getData(v, "shaderData") or {}
					table.insert(dimensionAnimatedTextures, { id = disc, texname = texName, object = nil, loadimg = "clubtec_load.png", shaderData = shaderData })
				end
			end
		end
	end

	triggerClientEvent(client or source, 'fakevideo:updateDimension', resourceRoot, dimension, dimensionAnimatedTextures)
end
addEvent("fakevideo:loadDimension", true)
addEventHandler("fakevideo:loadDimension", root, loadDimensionAnimatedTextures)
addEventHandler("frames:loadInteriorTextures", root, loadDimensionAnimatedTextures)
addEventHandler("onPlayerInteriorChange", root, loadDimensionAnimatedTextures)

--[[
addEvent("fakevideo:delete", true)
addEventHandler("fakevideo:delete", resourceRoot,
	function(id)
		local interior = getElementDimension(client)
		if global:hasItem(client, 4, interior) or global:hasItem(client, 5, interior) or (integration:isPlayerAdmin(client) and global:isAdminOnDuty(client)) or (interior==0) then
			local data = savedTextures[interior]
			if not data or not data[id] then
				outputChatBox("This isn't even your texture?", client, 255, 0, 0)
			else
				local success = mysql:query_free("DELETE FROM interior_textures WHERE id = '" .. mysql:escape_string ( id ) .. "' AND interior = '" .. mysql:escape_string( interior ) .. "'" )
				if success then
					outputChatBox("Deleted Texture with ID " .. id .. ".", client, 0, 255, 0)

					-- sorta tell everyone who is inside
					for k,v in ipairs(getElementsByType"player") do
						if getElementDimension(v) == interior then
							triggerClientEvent(v, 'frames:removeOne', resourceRoot, interior, id)
						end
					end

					local thisData = data[id]
					--give the removed texture as a picture frame item with the same values
					exports['item-system']:giveItem(client, textureItemID, tostring(thisData.url)..";"..tostring(thisData.texture))

					savedTextures[interior][id] = nil
				else
					outputChatBox("Failed to remove texture ID " .. id .. ".", client, 255, 0, 0)
				end
			end
		else
			outputChatBox("You need a key.", client, 255, 0, 0)
		end
	end)
--]]

addEvent("fakevideo:syncNewClient", true)
addEventHandler("fakevideo:syncNewClient", root, function()
		--outputDebugString("Sending "..tostring(#fakevideos).." fakevideos to client.")
		triggerClientEvent(client, 'fakevideo:initialSync', resourceRoot, fakevideos)
end)
