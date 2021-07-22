--Vehicle textures
--Script that handles texture replacements for vehicles
--Created by Exciter, 01.01.2015 (DD.MM.YYYY).
local maxFileSize = 100000
local maxWidth = 1200
local maxHeight = 1200

function addVehicleTexture(theVehicle, texName, texURL) --Exciter
	local thePlayer = source
	if(not theVehicle or not texName or not texURL) then
		return false
	end
	if not getElementType(theVehicle) == "vehicle" then
		return false
	end
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then
		if string.len(texURL) >= 50 then
			outputChatBox("URL Length is too long! Maybe use a host like imgur.", thePlayer, 255, 0, 0)
		return end
		local mysql = exports.mysql
		local textures = getElementData(theVehicle, "textures") or {}
		table.insert(textures, {texName, texURL})
		local vehID = tonumber(getElementData(theVehicle, "dbid")) or 0
		if vehID > 0 then
			local newdata = toJSON(textures)
			dbExec(exports.mysql:getConn("mta"), "UPDATE vehicles SET textures=? WHERE id=?", newdata, vehID)
		end
		exports.anticheat:changeProtectedElementDataEx(theVehicle, "textures", textures, true)
		addTexture(theVehicle, texName, texURL)
	end
end
addEvent("vehtex:addTexture", true)
addEventHandler("vehtex:addTexture", getRootElement( ), addVehicleTexture)

function removeVehicleTexture(theVehicle, texName) --Exciter
	local thePlayer = source
	if(not theVehicle or not texName) then
		return false
	end
	if not getElementType(theVehicle) == "vehicle" then
		return false
	end
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer)) then
		local mysql = exports.mysql
		local textures = getElementData(theVehicle, "textures") or {}
		for k,v in ipairs(textures) do
			if(v[1] == texName) then
				table.remove(textures, k)
				break
			end
		end

		local vehID = tonumber(getElementData(theVehicle, "dbid")) or 0
		if vehID > 0 then
			local newdata = toJSON(textures)
			dbExec(exports.mysql:getConn("mta"), "UPDATE vehicles SET textures=? WHERE id=?", newdata, vehID)
		end
		exports.anticheat:changeProtectedElementDataEx(theVehicle, "textures", textures, true)
		removeTexture(theVehicle, texName)
	end
end
addEvent("vehtex:removeTexture", true)
addEventHandler("vehtex:removeTexture", getRootElement( ), removeVehicleTexture)

function validateVehicleTexture(theVehicle, texName, url)
	local host = getHost(url)
	if host == "imgur.com" then
		local apiURL = string.match(url:match("^.*%/(.*)"), "(%w+)%.") --> I'm not too great with regex
		local apiURL = "https://api.imgur.com/3/image/" .. apiURL
		local options = {
			queueName = "textures",
			connectionAttempts = 5,
			headers = {Authorization = "Client-ID " .. tostring(get("imgurClient"))}
		}

		fetchRemote(apiURL, options, function(data, errno, client, theVehicle, url)
				if not errno.success then
					--outputDebugString('item-texture/s_vehtex: loadFromURL - unable to fetch ' .. tostring(url))
					local text = "The API could not be reached. (ERROR #"..tostring(errno.statusCode)..")"
					triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
					removeVehicleTexture(theVehicle, texName)
				else
					
					local table = fromJSON(data)
					if table and table.success == true and table.data then
						local width, height, size = table.data.width, table.data.height, table.data.size

						if size > maxFileSize then
							local text = "The filesize exceeds the maximum allowed filesize for vehicle textures ("..tostring(math.floor(maxFileSize/1000)).."kb)."
							triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
						elseif width > maxWidth or height > maxHeight then
							local text = "The width or height exceeds the maximum allowed width or height for vehicle textures (".. maxWidth ..", " .. maxHeight .. ")."
							triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
						else
							local options = {
								queueName = "textures",
								connectionAttempts = 5,
								postIsBinary = true
							}

							fetchRemote(url, options, function(str, errno, client, theVehicle, url)
									if not errno.success then
										local text = "The URL could not be reached. Please check that you entered the correct URL and that the URL is reachable. (ERROR #"..tostring(errno.statusCode)..")"
										triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
									else
										local path = getPath( tostring(url) )
										local file = fileCreate(path)
										fileWrite(file, str)
										fileClose(file)

										triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, true)
									end
								end, {client, theVehicle, url})
						end
					else
						local text = "Something went wrong with the API.. (".. ((table and table.data and table.data.error) or "N/A") .. ")"
						triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
					end
				end
			end,
		{client, theVehicle, url})
	elseif host == "icweb.org" then
		local apiURL = "http://icweb.org/imageapi.php"
		local apiKey = get("icwebAPIkey") or "owlhowl"
		local options = {
			queueName = "textures",
			connectionAttempts = 5,
			formFields = { AuthKey = tostring(apiKey), url=url }
		}

		fetchRemote(apiURL, options, function(data, errno, client, theVehicle, url)
				if not errno.success then
					local text = "The API could not be reached. (ERROR #"..tostring(errno.statusCode)..")"
					triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
					removeVehicleTexture(theVehicle, texName)
				else
					local table = fromJSON(data)
					outputDebugString("table.success="..tostring(table.success))
					if table and table.success == true and table.data then
						local width, height, size = table.data.width, table.data.height, table.data.size

						if size > maxFileSize then
							local text = "The filesize exceeds the maximum allowed filesize for vehicle textures ("..tostring(math.floor(maxFileSize/1000)).."kb)."
							triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
						elseif width > maxWidth or height > maxHeight then
							local text = "The width or height exceeds the maximum allowed width or height for vehicle textures (".. maxWidth ..", " .. maxHeight .. ")."
							triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
						else
							local options = {
								queueName = "textures",
								connectionAttempts = 5,
								postIsBinary = true
							}

							fetchRemote(url, options, function(str, errno, client, theVehicle, url)
									if not errno.success then
										local text = "The URL could not be reached. Please check that you entered the correct URL and that the URL is reachable. (ERROR #"..tostring(errno.statusCode)..")"
										triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
									else
										local path = getPath( tostring(url) )
										local file = fileCreate(path)
										fileWrite(file, str)
										fileClose(file)

										triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, true)
									end
								end, {client, theVehicle, url})
						end
					else
						local text = "Something went wrong with the API (".. ((table and table.error) or "N/A") .. ")"
						triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
					end
				end
			end,
		{client, theVehicle, url})		
	else
		local text = "Invalid host."
		triggerClientEvent(client, 'vehtex:fileValidationResult', resourceRoot, theVehicle, texName, url, false, text)
	end
end
addEvent("vehtex:validateFile", true)
addEventHandler("vehtex:validateFile", resourceRoot, validateVehicleTexture)

function requestAPIkey(vehicle, texname, texurl)
	local host = getHost(texurl)
	if host == "imgur.com" then
		local apiKey = get("imgurClient")
		triggerClientEvent(client, "vehtex:validatePreviewFile", resourceRoot, vehicle, texname, texurl, host, apiKey)
	elseif host == "icweb.org" then
		local apiKey = get("icwebAPIkey") or "owlhowl"
		triggerClientEvent(client, "vehtex:validatePreviewFile", resourceRoot, vehicle, texname, texurl, host, apiKey)
	end
end	
addEvent("vehtex:prepareValidation", true)
addEventHandler("vehtex:prepareValidation", resourceRoot, requestAPIkey) 