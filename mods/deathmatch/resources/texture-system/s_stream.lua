local mysql = exports.mysql
savedTextures = {}
integration = exports.integration
global = exports.global
textureItemID = 147

addEventHandler('onResourceStart', resourceRoot,
	function()
		local count = 0
		local result = mysql:query("SELECT * FROM interior_textures")
		local time = getTickCount()
		if result then
			while true do
				row = mysql:fetch_assoc(result)
				if not row then break end

				row.interior = tonumber(row.interior)
				row.id = tonumber(row.id)
				row.rotation = tonumber(row.rotation)
				if not savedTextures[row.interior] then
					savedTextures[row.interior] = {}
				end
				savedTextures[row.interior][row.id] = { id = row.id, texture = row.texture, url = row.url, rotation = row.rotation }

				count = count + 1
			end

			outputDebugString('Loaded ' .. count .. ' texture records for all interiors in ' .. math.ceil(getTickCount() - time) .. 'ms')
			mysql:free_result(result)
		end
	end)

--
function getPath(url)
	return 'cache/' .. md5(tostring(url)) .. '.tex'
end

-- loads a skin from an url
function loadFromURL(url, interior, id)
	fetchRemote(url, function(str, errno)
			if str == 'ERROR' then
				-- outputDebugString('clothing:stream - unable to fetch ' .. url)
			else
				local file = fileCreate(getPath(url))
				fileWrite(file, str)
				fileClose(file)

				local data = savedTextures[interior][id]
				if data and data.pending then
					triggerLatentClientEvent(data.pending, 'frames:file', resourceRoot, id, url, str, #str)
					data.pending = nil
				end
			end
		end)
end


-- send frames to the client
addEvent( 'frames:stream', true )
addEventHandler( 'frames:stream', resourceRoot,
	function(interior, id)
		local interior = tonumber(interior)
		local id = tonumber(id)
		-- if its not a number, this'll fail
		if type(id) == 'number' and type(interior) == 'number' then
			local data = savedTextures[interior] and savedTextures[interior][id]
			if data then
				local path = getPath(data.url)
				if fileExists(path) then
					local file = fileOpen(path, true)
					if file then
						local size = fileGetSize(file)
						if tonumber(size) > 0 then
							local content = fileRead(file, size)

							if #content == size then
								triggerLatentClientEvent(client, 'frames:file', resourceRoot, id, data.url, content, size)
							else
								outputDebugString('frames:stream - file ' .. path .. ' read ' .. #content .. ' bytes, but is ' .. size .. ' bytes long')
							end
						end
						fileClose(file)
					else
						outputDebugString('frames:stream - file ' .. path .. ' existed but could not be opened?')
					end
				else
					-- try to reload the file from the given url
					if data.pending then
						table.insert(data.pending, client)
					else
						data.pending = { client }
						loadFromURL(data.url, interior, id)
					end
				end
			else
				outputDebugString('frames:stream - frames #' .. interior .. '/' .. id .. ' do not exist.')
			end
		end
	end, false)

--
function initial(_, dimension)
	if not dimension then dimension = getElementDimension(client) end
	triggerClientEvent(client or source, 'frames:list', resourceRoot, dimension, savedTextures[dimension])
end
addEvent("frames:loadInteriorTextures", true)
addEventHandler("frames:loadInteriorTextures", resourceRoot, initial)
addEventHandler("onPlayerInteriorChange", root, initial)

addEvent("frames:delete", true)
addEventHandler("frames:delete", resourceRoot,
	function(id, interior, dimension)
		--TODO: Get interior and dimension from the texture id instead of the player, to avoid potential abuse.
		if not dimension then dimension = getElementDimension(client) end
		if not interior then interior = getElementInterior(client) end
		if (dimension > 0 and interior > 0) or (exports.integration:isPlayerHeadAdmin(client) and exports.global:isAdminOnDuty(client)) or (exports.integration:isPlayerScripter(client) and exports.global:isStaffOnDuty(client)) then
			if (dimension < 20000 and exports.global:hasItem(client, 4, dimension)) or (dimension < 20000 and exports.global:hasItem(client, 5, dimension)) or (dimension > 20000 and exports.global:hasItem(client, 3, dimension-20000)) or (exports.integration:isPlayerAdmin(client) and exports.global:isAdminOnDuty(client)) or (exports.integration:isPlayerScripter(client) and exports.global:isStaffOnDuty(client)) or (dimension == 0) then
				local data = savedTextures[dimension]
				if not data or not data[id] then
					outputChatBox("This isn't even your texture?", client, 255, 0, 0)
				else
					local success = mysql:query_free("DELETE FROM interior_textures WHERE id = '" .. mysql:escape_string ( id ) .. "' AND interior = '" .. mysql:escape_string( dimension ) .. "'" )
					if success then
						outputChatBox("Deleted Texture with ID " .. id .. ".", client, 0, 255, 0)

						-- sorta tell everyone who is inside
						for k,v in ipairs(getElementsByType"player") do
							if getElementDimension(v) == dimension then
								triggerClientEvent(v, 'frames:removeOne', resourceRoot, dimension, id)
							end
						end

						local thisData = data[id]
						--give the removed texture as a picture frame item with the same values
						exports['item-system']:giveItem(client, textureItemID, tostring(thisData.url)..";"..tostring(thisData.texture))
						exports['item-system']:deleteAll(248, id)

						triggerClientEvent(client, 'frames:reloadList', client)
						savedTextures[dimension][id] = nil
					else
						outputChatBox("Failed to remove texture ID " .. id .. ".", client, 255, 0, 0)
					end
				end
			else
				outputChatBox("You need a key.", client, 255, 0, 0)
			end
		else
			outputChatBox("You need to be in an interior to retexture.", client, 255, 0, 0, false)
		end
	end)

--

addEvent("frames:updateURL", true)
addEventHandler("frames:updateURL", resourceRoot,
	function(id, url, interior, dimension)
		--TODO: Get interior and dimension from the texture id instead of the player, to avoid potential abuse.
		if not dimension then dimension = getElementDimension(client) end
		if not interior then interior = getElementInterior(client) end
		if (dimension > 0 and interior > 0) or (exports.integration:isPlayerHeadAdmin(client) and exports.global:isAdminOnDuty(client)) or (exports.integration:isPlayerScripter(client) and exports.global:isStaffOnDuty(client)) then
			if (exports.global:hasItem(client, 248, id) or dimension < 20000 and exports.global:hasItem(client, 4, dimension)) or (dimension < 20000 and exports.global:hasItem(client, 5, dimension)) or (dimension > 20000 and exports.global:hasItem(client, 3, dimension-20000)) or (exports.integration:isPlayerAdmin(client) and exports.global:isAdminOnDuty(client)) or (exports.integration:isPlayerScripter(client) and exports.global:isStaffOnDuty(client)) or (dimension == 0) then
				local data = savedTextures[dimension]
				if not data or not data[id] then
					outputChatBox("This isn't even your texture?", client, 255, 0, 0)
				else
					local success = mysql:query_free("UPDATE interior_textures SET url = '" .. mysql:escape_string(url) .. "' WHERE id = '" .. mysql:escape_string ( id ) .. "' AND interior = '" .. mysql:escape_string( dimension ) .. "'" )
					if success then
						outputChatBox("Updated Texture with ID " .. id .. ".", client, 0, 255, 0)

						local thisData = data[id]
						thisData.url = url

						-- sorta tell everyone who is inside
						for k,v in ipairs(getElementsByType"player") do
							if getElementDimension(v) == dimension then
								triggerClientEvent(v, 'frames:removeOne', resourceRoot, dimension, id)
								triggerClientEvent(v, 'frames:addOne', resourceRoot, dimension, thisData)
							end
						end

						savedTextures[dimension][id] = thisData
					else
						outputChatBox("Failed to update texture.", client, 255, 0, 0)
					end
				end

			else
				outputChatBox("You need a key.", client, 255, 0, 0)
			end
		else
			outputChatBox("You need to be in an interior to retexture.", client, 255, 0, 0, false)
		end
	end)

addEvent("frames:updateRotation", true)
addEventHandler("frames:updateRotation", resourceRoot,
	function(id, interior, dimension)
		--TODO: Get interior and dimension from the texture id instead of the player, to avoid potential abuse.
		if not dimension then dimension = getElementDimension(client) end
		if not interior then interior = getElementInterior(client) end
		if (dimension > 0 and interior > 0) or (exports.integration:isPlayerHeadAdmin(client) and exports.global:isAdminOnDuty(client)) or (exports.integration:isPlayerScripter(client) and exports.global:isStaffOnDuty(client)) then
			if (exports.global:hasItem(client, 248, id) or dimension < 20000 and exports.global:hasItem(client, 4, dimension)) or (dimension < 20000 and exports.global:hasItem(client, 5, dimension)) or (dimension > 20000 and exports.global:hasItem(client, 3, dimension-20000)) or (exports.integration:isPlayerAdmin(client) and exports.global:isAdminOnDuty(client)) or (exports.integration:isPlayerScripter(client) and exports.global:isStaffOnDuty(client)) or (dimension == 0) then
				local data = savedTextures[dimension]
				if not data or not data[id] then
					outputChatBox("This isn't even your texture?", client, 255, 0, 0)
				else
					local thisData = data[id]
					local currentRotation = thisData.rotation or 0
					currentRotation = (currentRotation + 90) % 360

					local success = mysql:query_free("UPDATE interior_textures SET rotation = '" .. mysql:escape_string(currentRotation) .. "' WHERE id = '" .. mysql:escape_string ( id ) .. "' " )
					if success then
						outputChatBox("Updated Texture with ID " .. id .. ".", client, 0, 255, 0)

						thisData.rotation = currentRotation

						-- sorta tell everyone who is inside
						for k,v in ipairs(getElementsByType"player") do
							if getElementDimension(v) == dimension then
								triggerClientEvent(v, 'frames:removeOne', resourceRoot, dimension, id)
								triggerClientEvent(v, 'frames:addOne', resourceRoot, dimension, thisData)
							end
						end

						savedTextures[dimension][id] = thisData
					else
						outputChatBox("Failed to update texture.", client, 255, 0, 0)
					end
				end

			else
				outputChatBox("You need a key.", client, 255, 0, 0)
			end
		else
			outputChatBox("You need to be in an interior to retexture.", client, 255, 0, 0, false)
		end
	end)

-- exported
function newTexture(source, url, texture, interior, dimension)
	--TODO: Get interior and dimension from the texture id instead of the player, to avoid potential abuse.
	if not dimension then dimension = getElementDimension(source) end
	if not interior then interior = getElementInterior(source) end
	if (dimension > 0 and interior > 0) or (exports.integration:isPlayerHeadAdmin(source) and exports.global:isAdminOnDuty(source)) or (exports.integration:isPlayerScripter(source) and exports.global:isStaffOnDuty(source)) then
		if (dimension < 20000 and exports.global:hasItem(source, 4, dimension)) or (dimension < 20000 and exports.global:hasItem(source, 5, dimension)) or (dimension > 20000 and exports.global:hasItem(source, 3, dimension-20000)) or (exports.integration:isPlayerAdmin(source) and exports.global:isAdminOnDuty(source)) or (exports.integration:isPlayerScripter(source) and exports.global:isStaffOnDuty(source)) or (dimension == 0) then

			if url:sub(1, 4) == "cef+" then
				-- browser page
			elseif string.len(url) >= 50 then
				outputChatBox("URL is too long.", source, 255, 0 ,0)
				return
			end

			-- check if said texture is already replaced
			if savedTextures[dimension] then
				for k, v in pairs(savedTextures[dimension]) do
					if v.texture:lower() == texture:lower() then
						outputChatBox('This texture is already replaced, please remove it first with /texlist.', source, 255, 0, 0)
						return false
					end
				end
			end

			local id = mysql:query_insert_free("INSERT INTO interior_textures SET interior = '" .. mysql:escape_string(dimension) .. "', texture = '" .. mysql:escape_string(texture) .. "', url = '" .. mysql:escape_string(url) .. "'")
			if id then
				local row = { id = id, texture = texture, url = url, rotation = 0 }
				if not savedTextures[dimension] then
					savedTextures[dimension] = {}
				end
				savedTextures[dimension][id] = row

				for k, v in ipairs(getElementsByType"player") do
					if getElementDimension(v) == dimension then
						triggerClientEvent(v, 'frames:addOne', resourceRoot, dimension, row)
					end
				end

				outputChatBox ( "Texture successfully replaced!", source, 0, 255, 0 )
				return true
			end
			outputChatBox ( "Failed to replace texture.", source, 255, 0, 0 )
			return false
		else
			outputChatBox("You do not own this interior.", source, 255, 0, 0, false)
			return false
		end
	else
		outputChatBox("You need to be in an interior to retexture.", source, 255, 0, 0, false)
		return false
	end
	return false
end

addEvent("frames:highlightTexture", true)
addEventHandler("frames:highlightTexture", resourceRoot,
    function( texID )
        triggerClientEvent(client, 'frames:highlightTexture', client, texID)
	end
)

addEvent("frames:deleteAll", true)
addEventHandler("frames:deleteAll", resourceRoot,
    function(  )
        local interior = getElementDimension(client)
        if global:hasItem(client, 4, interior) or global:hasItem(client, 5, interior) or (integration:isPlayerAdmin(client) and global:isAdminOnDuty(client)) or (interior==0) then
            local data = savedTextures[interior]
            if not data then
                outputChatBox("You don't have any texture to delete.", client, 255, 0, 0)
            else
                local success = mysql:query_free("DELETE FROM interior_textures WHERE interior = '" .. mysql:escape_string( interior ) .. "'" )
                if success then
                    outputChatBox("All textures have been removed.", client, 0, 255, 0)
 
                    -- sorta tell everyone who is inside
                    for k,v in ipairs(getElementsByType("player")) do
                        if getElementDimension(v) == interior then
                            triggerClientEvent(v, 'frames:removeAll', resourceRoot, interior)
                        end
                    end
 
                    local thisData = data
                    --give the removed texture as a picture frame item with the same values
                    for k, v in pairs(data) do
                        exports['item-system']:giveItem(client, textureItemID, tostring(v.url)..";"..tostring(v.texture))
                    end
                    triggerClientEvent(client, 'frames:reloadList', client)
                    savedTextures[interior] = nil
                else
                    outputChatBox("Failed to remove texture ID " .. id .. ".", client, 255, 0, 0)
                end
            end
        else
            outputChatBox("You need a key.", client, 255, 0, 0)
        end
	end
)
