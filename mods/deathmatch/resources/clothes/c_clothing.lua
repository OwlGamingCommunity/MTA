local loaded = { --[[ [clothing] = {tex = texture, shader = shader} ]] }
local streaming = { --[[ [clothing] = {players} ]] }

local players = {}

-- skins with 2+ texture names:	12, 19, 21, 28, 30, 40, 46, 47, 55, 91, 93, 98, 100, 107, 110, 115, 116, 141, 156, 174, 223, 233, 249
local accessoires = { watchcro = true, neckcross = true, earing = true, glasses = true, specsm = true }
local function getPrimaryTextureName(model)
	for k, v in ipairs(engineGetModelTextureNames(model)) do
		if not accessoires[v] then
			return v
		end
	end
end

-- returns the file path for a texture file
function getPath(clothing)
	return '@cache/' .. tostring(clothing) .. '.tex'
end

addCommandHandler('getclothingtexture',
	function(command, model)
		local model = tonumber(model) or getElementModel(localPlayer)
		outputChatBox('Model ' .. model .. ' has ' .. (getPrimaryTextureName(model) or 'N/A') .. ' as primary texture.', 255, 127, 0)
	end)

function getSkin(command)
	local skin = getElementModel(localPlayer)
	local clothing = getElementData(localPlayer, "clothing:id") or "N/A"
	outputChatBox("This is skin #"..skin.." with the clothing ID #"..clothing)
end
addCommandHandler("skininfo", getSkin)
addCommandHandler("gskin", getSkin)
addCommandHandler("getskin", getSkin)

-- adds clothing to a player, possibly streaming it from the server if needed
function addClothing(player, clothing, event)
	removeClothing(player, event)
	local texName = getPrimaryTextureName(getElementModel(player))

	-- does the shader for the relevant skin already exist?
	local L = loaded[clothing]
	if L then
		players[player] = { id = clothing, texName = texName }
		if getElementData(player, 'clothing:id') == clothing then
			engineApplyShaderToWorldTexture(L.shader, texName, player)
		end
	else
		-- shader not yet created, do we have the file available locally?
		local getNew = true
		local path = getPath(clothing)
		if fileExists(path) then
			getNew = false

			local texture = dxCreateTexture(path)
			if texture then
				local shader, t = dxCreateShader('tex.fx', 0, 0, true, 'ped')
				if shader then
					dxSetShaderValue(shader, 'tex', texture)

					local texName = getPrimaryTextureName(getElementModel(player))
					engineApplyShaderToWorldTexture(shader, texName, player)

					loaded[clothing] = { texture = texture, shader = shader }
					players[player] = { id = clothing, texName = texName }
				else
					outputDebugString('creating shader for player ' .. getPlayerName(player) .. ' failed.', 2)
					destroyElement(texture)
				end
			else
				outputDebugString('creating texture for player ' .. getPlayerName(player) .. ' failed (Path: ' .. path .. ') Deleting file...', 2)
				fileDelete(path)
			end
		end
		if getNew then
			-- clothing not yet downloaded
			if streaming[clothing] then
				table.insert(streaming[clothing], player)
			else
				streaming[clothing] = { player }
				triggerServerEvent('clothing:stream', resourceRoot, clothing)
			end
			players[player] = { id = clothing, texName = texName, pending = true }
		end
	end
end

-- remove the clothes - that's rather easy
function removeClothing(player, event)
	local clothes = players[player]
	if clothes and loaded[clothes.id] and isElement(loaded[clothes.id].shader) then
		-- possibly clean up shaders
		local stillUsed = false
		for p, data in pairs(players) do
			if p ~= player and data.id == clothes.id then
				stillUsed = true
				break
			end
		end

		if stillUsed then
			if not clothes.pending then
				-- just remove the shader from that one player
				engineRemoveShaderFromWorldTexture(loaded[clothes.id].shader, clothes.texName, player)
			end
		else
			-- destroy the shader and texture since no player uses it
			local L = loaded[clothes.id]
			if L then
				destroyElement(L.texture)
				destroyElement(L.shader)

				loaded[clothes.id] = nil
			end
		end
		players[player] = nil
	end
end

-- file we asked for is there
addEvent('clothing:file', true)
addEventHandler( 'clothing:file', resourceRoot,
	function(id, content)
		if dxGetPixelsFormat(content) then
			local file = fileCreate(getPath(id))
			local written = fileWrite(file, content)
			fileClose(file)

			for _, player in ipairs(streaming[id]) do
				addClothing(player, id, 'clothing:file')
			end

			streaming[id] = nil
		else
			-- Remove invalid file
			triggerServerEvent('clothing:delete', resourceRoot, tonumber(clothing))
		end
	end, false)

-- initialize all skins upon resource startup
addEventHandler( 'onClientResourceStart', resourceRoot,
	function()
		for _, name in ipairs({'player', 'ped'}) do
			for _, p in ipairs(getElementsByType(name)) do
				if isElementStreamedIn(p) then
					local clothing = getElementData(p, 'clothing:id')
					if clothing then
						addClothing(p, clothing, 'onClientResourceStart')
					end
				end
			end
		end
	end)

-- apply skins when people are to be streamed in.
addEventHandler( 'onClientElementStreamIn', root,
	function()
		if getElementType(source) == 'player' or getElementType(source) == 'ped' then
			local clothing_id = getElementData(source, 'clothing:id')
			if clothing_id then
				addClothing(source, clothing_id, 'onClientElementStreamIn')
			end
		end
	end)

-- remove them when streamed out
addEventHandler( 'onClientElementStreamOut', root,
	function()
		if getElementType(source) == 'player' or getElementType(source) == 'ped' then
			if getElementData(source, 'clothing:id') then
				removeClothing(source, 'onClientElementStreamOut')
			end
		end
	end)

-- remove them when they quit
addEventHandler( 'onClientPlayerQuit', root,
	function()
		if getElementData(source, 'clothing:id') then
			removeClothing(source, 'onClientPlayerQuit')
		end
	end)

addEventHandler( 'onClientElementDestroy', root,
	function()
		if getElementType(source) == 'ped' and getElementData(source, 'clothing:id') then
			removeClothing(source, 'onClientElementDestroy')
		end
	end)

-- apply changed clothing
addEventHandler( 'onClientElementDataChange', root,
	function(name)
		if (getElementType(source) == 'player' or getElementType(source) == 'ped') and isElementStreamedIn(source) and name == 'clothing:id' then
			local clothing_id = getElementData(source, 'clothing:id')
			if clothing_id then
				addClothing(source, clothing_id, 'onClientElementDataChange')
			else
				removeClothing(source, 'onClientElementDataChange')
			end
		end
	end)

local function flushSkin(type)
	local count = 0
	for i, p in pairs(getElementsByType(type)) do
		if isElementStreamedIn(p) and isElementOnScreen(p) then
			local id = getElementData(p, 'clothing:id')
			if id then
				removeClothing(p, 'flush')
				local path = getPath(id)
				if fileExists(path) then
					fileDelete(path)
					count = count + 1
				end
				streaming[id] = nil
				addClothing(p, id, 'flush')
			end
		end
	end
	return count
end

function flushSkins()
	outputChatBox(flushSkin('player')+flushSkin('ped').." skins have been flushed.")
end
addCommandHandler('flushskins', flushSkins, false)
