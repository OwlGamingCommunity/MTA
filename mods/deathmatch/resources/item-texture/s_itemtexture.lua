--item-texture
--Script that handles texture replacements for world items
--Created by Exciter, 24.06.2014 (DD.MM.YYYY).
--Based upon iG texture-system (based on Exciter's uG/RPP texture-system) and OwlGaming/Cat's fixes to texture-system based on mabako-clothingstore.
--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

pool = exports.pool
items = exports['item-system']
artifacts = exports.artifacts

local pending = {}
local added = {}
local addedServerOnly = {}
local addedElement = {}
local isInitializing = false
local clientsWaitingOnInitial = {}

local debugMode = false

addEventHandler('onResourceStart', resourceRoot,
	function()
		isInitializing = true

		local artifactsData = artifacts:getArtifacts()
		for k,v in ipairs(pool:getPoolElementsByType("player")) do
			local playerArtifacts = artifacts:getPlayerArtifacts(v, true)
			for k2,v2 in ipairs(playerArtifacts) do
				local artifactElement = v2[1]
				local artifactID = v2[2]
				local artifactTexture = artifactsData[artifactID][11]
				if artifactTexture then
					for k3,v3 in ipairs(artifactTexture) do
						addTexture(artifactElement, v3[2], v3[1], true)
					end
				end
			end
		end

		local worldItems = getElementsByType("object", getResourceRootElement(getResourceFromName("item-world")))
		outputDebugString("item-texture: Loading textures for "..tostring(#worldItems).." world items")
		for k,v in ipairs(worldItems) do
			local itemID = tonumber(getElementData(v, "itemID")) or 0
			if itemID > 0 then
				local itemValue = getElementData(v, "itemValue")
				local metadata = getElementData(v, "metadata")
				local texture = items:getItemTexture(itemID, itemValue, metadata)
				if texture then
					for k2,v2 in ipairs(texture) do
						addTexture(v, v2[2], v2[1], true)
					end
				end
			end
		end

		local vehicles = pool:getPoolElementsByType("vehicle")
		for k,v in ipairs(vehicles) do
			local textures = getElementData(v, "textures")
			if textures then
				if type(textures) == "table" then
					for k2,v2 in ipairs(textures) do
						addTexture(v, v2[1], v2[2], true)
					end
				end
			end
		end

		outputDebugString("item-texture: "..tostring(#clientsWaitingOnInitial).." clients waiting on initial sync.")
		isInitializing = false
		if clientsWaitingOnInitial then
			outputDebugString("item-texture: "..tostring(#added).." textured elements were added for initial sync.")
			setTimer(triggerClientEvent, 2000, 1, clientsWaitingOnInitial, "item-texture:initialSync", resourceRoot, added)
			--triggerClientEvent(clientsWaitingOnInitial, 'item-texture:initialSync', resourceRoot, added)
		end
		clientsWaitingOnInitial = {}
	end)

function getPath(url)
	return 'cache/' .. md5(tostring(url)) .. '.tex'
end

-- loads a texture from url
function loadFromURL(element, texName, url)
	fetchRemote(url, "textures", function(str, errno)
			if str == 'ERROR' then
				outputDebugString('item-texture: loadFromURL - unable to fetch ' .. tostring(url))
				if getElementType(element) == 'vehicle' then
					removeVehicleTexture(element, texName)
				else
					removeTexture(element, texName)
				end
			else
				local file = fileCreate(getPath(url))
				fileWrite(file, str)
				fileClose(file)

				if pending[url] then
					triggerLatentClientEvent(pending[url], 'item-texture:file', resourceRoot, element, texName, url, str, #str)
					pending[url] = nil
				end
			end
		end)
end

-- send frames to the client
addEvent( 'item-texture:stream', true )
addEventHandler( 'item-texture:stream', resourceRoot,
	function(element, texName, url)
		local path = getPath(url)
		if fileExists(path) then
			local file = fileOpen(path, true)
			if file then
				local size = fileGetSize(file)
				if size <= 0 then
					fileClose(file)
					return
				end
				local content = fileRead(file, size)

				if #content == size then
					triggerLatentClientEvent(client, 'item-texture:file', resourceRoot, element, texName, url, content, size)
				else
					outputDebugString('item-texture:stream - file ' .. path .. ' read ' .. #content .. ' bytes, but is ' .. size .. ' bytes long')
				end
				fileClose(file)
			else
				outputDebugString('item-texture:stream - file ' .. path .. ' existed but could not be opened?')
			end
		else
			-- try to reload the file from the given url
			if pending[url] then
				table.insert(pending[url], client)
			else
				pending[url] = { client }
				loadFromURL(element, texName, url)
			end
		end
	end, false)

-- exported
function addTexture(element, texName, url, serverOnly)
	--outputDebugString("addTexture("..tostring(element)..", "..tostring(texName)..", "..tostring(url)..", "..tostring(serverOnly)..")")
	--TODO: Make it a way so we only add the texture for players that can see/is nearby the element, including a way to check for and add textures when player gets near a untextured element that should be textured
	table.insert(added, {element, texName, url})
	addedElement[element] = true
	if not serverOnly and not isInitializing then
		triggerClientEvent('item-texture:addOne', resourceRoot, element, texName, url)
	else
		--table.insert(addedServerOnly, {element, texName, url})
	end
end

function removeTexture(element, texName)
	for k,v in ipairs(added) do
		if texName then
			if v[1] == element and v[2] == texName then
				table.remove(added, k)
				addedElement[element] = nil
			end
		else
			if v[1] == element then
				table.remove(added, k)
				addedElement[element] = nil
			end
		end
	end
	triggerClientEvent('item-texture:removeOne', resourceRoot, element, texName)
end

addEventHandler("onElementDestroy", root, function()
	if addedElement[source] then
		removeTexture(source)
	end
end)

addEvent("item-texture:syncNewClient", true)
addEventHandler("item-texture:syncNewClient", root, function()
	if isInitializing then
		table.insert(clientsWaitingOnInitial, client)
	else
		triggerClientEvent(client, 'item-texture:initialSync', resourceRoot, added)
	end
end)

function validateFileFromURL(url)
	local host = getHost(url)
	if host == "imgur.com" then
		local apiURL = string.match(url:match("^.*%/(.*)"), "(%w+)%.")
		local apiURL = "https://api.imgur.com/3/image/" .. apiURL
		local options = {
			queueName = "textures",
			connectionAttempts = 5,
			headers = {Authorization = "Client-ID " .. tostring(get("imgurClient"))}
		}
		fetchRemote(apiURL, options, function(data, errno, client, url)
				if not errno.success then
					local text = "The API could not be reached. (ERROR #"..tostring(errno.statusCode)..")"
					triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
					return false, text
				else
					local table = fromJSON(data)
					if table and table.success == true and table.data then
						local width, height, size = table.data.width, table.data.height, table.data.size

						if size > maxFileSize then
							local text = "The filesize exceeds the maximum allowed filesize for item textures ("..tostring(math.floor(maxFileSize/1000)).."kb)."
							triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
							return false, text
						elseif width > maxWidth or height > maxHeight then
							local text = "The width or height exceeds the maximum allowed width or height for item textures (".. maxWidth ..", " .. maxHeight .. ")."
							triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
							return false, text
						else
							local options = {
								queueName = "textures",
								connectionAttempts = 5,
								postIsBinary = true
							}

							fetchRemote(url, options, function(str, errno, client, url)
									if not errno.success then
										local text = "The URL could not be reached. Please check that you entered the correct URL and that the URL is reachable. (ERROR #"..tostring(errno.statusCode)..")"
										triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
										return false, text
									else
										local path = getPath( tostring(url) )
										local file = fileCreate(path)
										fileWrite(file, str)
										fileClose(file)

										triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, true)
										return true
									end
								end, {client, url})
						end
					else
						local text = "Something went wrong with the API.. (".. ((table and table.data and table.data.error) or "N/A") .. ")"
						triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
						return false, text
					end
				end
			end,
		{client, url})
	elseif host == "icweb.org" then
		local apiURL = "http://icweb.org/imageapi.php"
		local apiKey = get("icwebAPIkey") or "owlhowl"
		local options = {
			queueName = "textures",
			connectionAttempts = 5,
			formFields = { AuthKey = tostring(apiKey), url=url }
		}

		fetchRemote(apiURL, options, function(data, errno, client, url)
				if not errno.success then
					local text = "The API could not be reached. (ERROR #"..tostring(errno.statusCode)..")"
					triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
					return false, text
				else
					local table = fromJSON(data)
					--outputDebugString("table.success="..tostring(table.success))
					if table and table.success == true and table.data then
						local width, height, size = table.data.width, table.data.height, table.data.size

						if size > maxFileSize then
							local text = "The filesize exceeds the maximum allowed filesize for item textures ("..tostring(math.floor(maxFileSize/1000)).."kb)."
							triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
							return false, text
						elseif width > maxWidth or height > maxHeight then
							local text = "The width or height exceeds the maximum allowed width or height for item textures (".. maxWidth ..", " .. maxHeight .. ")."
							triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
							return false, text
						else
							local options = {
								queueName = "textures",
								connectionAttempts = 5,
								postIsBinary = true
							}

							fetchRemote(url, options, function(str, errno, client, url)
									if not errno.success then
										local text = "The URL could not be reached. Please check that you entered the correct URL and that the URL is reachable. (ERROR #"..tostring(errno.statusCode)..")"
										triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
										return false, text
									else
										local path = getPath( tostring(url) )
										local file = fileCreate(path)
										fileWrite(file, str)
										fileClose(file)

										triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, true)
										return true
									end
								end, {client, url})
						end
					else
						local text = "Something went wrong with the API (".. ((table and table.error) or "N/A") .. ")"
						triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
						return false, text
					end
				end
			end,
		{client, url})
	else
		local text = "Invalid host."
		triggerClientEvent(client, 'item-texture:fileValidationResult', root, url, false, text)
		return false, text
	end
end
addEvent("item-texture:validateFile", true)
addEventHandler("item-texture:validateFile", resourceRoot, validateFileFromURL)