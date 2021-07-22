--item-texture
--Script that handles texture replacements for world items
--Created by Exciter, 24.06.2014 (DD.MM.YYYY).
--Based upon iG texture-system (based on Exciter's uG/RPP texture-system) and OwlGaming/Cat's fixes to texture-system based on mabako-clothingstore.

local loaded = {}
local streaming = {}
local unshaded = {}
local textureName = nil
local veh = nil
-- Used for changing the colors back from white if you are previewing
local oldColor = nil
previewTimer = nil

local debugMode = false

local allowedImageHosts = {
	--hosts with an API for doing checks before server downloads image
	--if you add another public host here, make sure to also add use of its API in s_vehtex.lua validateVehicleTexture()
	["imgur.com"] = true,
	["icweb.org"] = true,
}

function getPath(url)
	return '@cache/' .. md5(tostring(url)) .. '.tex'
end

function addTexture(element, texName, url, isPreview)
	if debugMode then
		outputDebugString("element='"..tostring(element).."' texName='"..tostring(texName).."' url='"..tostring(url).."'")
	end
	if not isElement(element) then return false end
	if not unshaded[element] then unshaded[element] = {} end
	if not isElementStreamedIn(element) then
		table.insert(unshaded[element], {texName, url})
		return true
	end
	if unshaded[element] then
		for k,v in ipairs(unshaded[element]) do
			if v[1] == texName then
				table.remove(unshaded[element], k)
			end
		end
	end 
	if isURL(url) then --path is a URL (remote)
		if not streaming[element] then streaming[element] = {} end
		local path = getPath(url)
		if fileExists(path) then
			streaming[element][texName] = nil
			local data
			if loaded[element] then
				for k,v in ipairs(loaded[element]) do
					if v.texname == texName then
						data = v
						break
					end
				end
			end

			if data then --shader exist
				local shader = data.shader
				local oldTex = data.texture
				--local newTex = dxCreateTexture(path, "argb", true, "clamp", "2d", 1)
				local newTex = dxCreateTexture(path)
				destroyElement(oldTex)
				data.texture = newTex
				dxSetShaderValue(shader, "gTexture", newTex)
				if isPreview then
					oldColor = {getVehicleColor(element, true)}
					setVehicleColor(element, 255, 255, 255) 
					previewTimer = setTimer(stopPreview, 30000, 1, element, texName)
					outputChatBox("Your preview will end in 30 seconds or /cancelpreview.", 255, 194, 14)
					textureName = texName 
					veh = element
				end	
			else
				--local texture = dxCreateTexture(path, "argb", true, "clamp", "2d", 1)
				local texture = dxCreateTexture(path)
				if texture then
					local shader, t = dxCreateShader('shaders/replacement.fx', 0, 0, true, 'world,object,vehicle')
					if shader then
						dxSetShaderValue(shader, 'Tex0', texture)
						engineApplyShaderToWorldTexture(shader, texName, element)
						if not loaded[element] then
							loaded[element] = {}
						end
						if isPreview then
							oldColor = {getVehicleColor(element, true)}
							setVehicleColor(element, 255, 255, 255) 
							previewTimer = setTimer(stopPreview, 30000, 1, element, texName)
							outputChatBox("Your preview will end in 30 seconds or /cancelpreview.", 255, 194, 14)
							textureName = texName 
							veh = element
						end	
						table.insert(loaded[element], { texname = texName, texture = texture, shader = shader, url = url })
					else
						outputDebugString('creating shader for tex ' .. texName .. ' failed.', 2)
						destroyElement(texture)
					end
				else
					outputDebugString('creating texture for tex ' .. texName .. ' failed', 2)
				end
			end
		else
			if not streaming[element][texName] and not isPreview then
				streaming[element][texName] = true
				triggerServerEvent('item-texture:stream', resourceRoot, element, texName, url)
			elseif not streaming[element][texName] and isPreview then
				createPreviewFile(element, texName, url)	
			end
		end
	else --path is local file
		local path = url
		if fileExists(path) then
			local data
			if loaded[element] then
				for k,v in ipairs(loaded[element]) do
					if v.texname == texName then
						data = v
						break
					end
				end
			end

			if data then --shader exist
				local shader = data.shader
				local oldTex = data.texture
				--local newTex = dxCreateTexture(path, "argb", true, "clamp", "2d", 1)
				local newTex = dxCreateTexture(path)
				destroyElement(oldTex)
				data.texture = newTex
				dxSetShaderValue(shader, "gTexture", newTex)
				if isPreview then
					oldColor = {getVehicleColor(element, true)}
					setVehicleColor(element, 255, 255, 255) 
					previewTimer = setTimer(stopPreview, 30000, 1, element, texName)
					outputChatBox("Your preview will end in 30 seconds or /cancelpreview.", 255, 194, 14)
					textureName = texName 
					veh = element
				end	
			else
				--local texture = dxCreateTexture(path, "argb", true, "clamp", "2d", 1)
				local texture = dxCreateTexture(path)
				if texture then
					local shader, t = dxCreateShader('shaders/replacement.fx', 0, 0, true, 'world,object,vehicle')
					if shader then
						dxSetShaderValue(shader, 'Tex0', texture)
						engineApplyShaderToWorldTexture(shader, texName, element)
						if not loaded[element] then
							loaded[element] = {}
						end
						if isPreview then 
							oldColor = {getVehicleColor(element, true)}
							setVehicleColor(element, 255, 255, 255) 
							previewTimer = setTimer(stopPreview, 30000, 1, element, texName)
							outputChatBox("Your preview will end in 30 seconds or /cancelpreview.", 255, 194, 14)
							textureName = texName 
							veh = element
						end	
						table.insert(loaded[element], { texname = texName, texture = texture, shader = shader, url = url })
					else
						outputDebugString('creating shader for tex ' .. texName .. ' failed.', 2)
						destroyElement(texture)
					end
				else
					outputDebugString('creating texture for tex ' .. texName .. ' failed', 2)
				end
			end
		else
			outputDebugString("item-texture/c_textureitem: addTexture: local file '"..tostring(path).."' does not exist")
		end
	end
end

function removeTexture(element, texName)
	if texName then
		if unshaded[element] then
			local count = 0
			for k,v in ipairs(unshaded[element]) do
				if v[1] == texName then
					table.remove(unshaded[element], k)
					count = count + 1
				end
			end
			if count > 0 then
				return true
			end
		end
		local loadedEntryNum
		if loaded[element] then
			for k,v in ipairs(loaded[element]) do
				if v.texname == texName then
					data = v
					loadedEntryNum = k
					break
				end
			end
		end
		local result = engineRemoveShaderFromWorldTexture(data.shader, texName, element)
		if isElement(data.texture) then
			destroyElement(data.texture)
		end	
		if isElement(data.shader) then
			destroyElement(data.shader)
		end	
		table.remove(loaded[element], loadedEntryNum)
		textureName, veh, previewTimer = nil
		return result
	else
		if unshaded[element] then unshaded[element] = nil return true end
		if loaded[element] then
			for k,v in ipairs(loaded[element]) do
				engineRemoveShaderFromWorldTexture(v.shader, texName, element)
				destroyElement(v.texture)
				destroyElement(v.shader)
			end
			loaded[element] = nil	
			textureName, veh, previewTimer = nil
			return true
		end
	end
	textureName, veh, previewTimer = nil
	return false
end

-- file we asked for is there
addEvent('item-texture:file', true)
addEventHandler( 'item-texture:file', resourceRoot,
	function(element, texName, url, content, size, isPreview)
		local file = fileCreate(getPath(url))
		local written = fileWrite(file, content)
		fileClose(file)

		if written ~= size then
			fileDelete(getPath(url))
		else
			addTexture(element, texName, url, isPreview)
		end
	end, false)

function createPreviewFile(element, texName, url)
	fetchRemote(url, "textures", function(str, errno)
		if str == 'ERROR' then
			outputDebugString('item-texture: loadFromURL - unable to fetch ' .. tostring(url))
			removeTexture(element, texName)
		else
			local file = fileCreate(getPath(url))
			fileWrite(file, str)
			fileClose(file)
			if written ~= #str then
				fileDelete(getPath(url))
			else
				addTexture(element, texName, url, true)
			end
		end
	end
	)
end		
	
addEvent('item-texture:removeOne', true)
addEventHandler('item-texture:removeOne', resourceRoot,
	function(element, texName, plr)
		removeTexture(element, texName)
	end, false)

addEvent('item-texture:addOne', true)
addEventHandler('item-texture:addOne', resourceRoot,
	function(element, texName, url, plr)
		addTexture(element, texName, url, isPreview)
	end)


function validateFileFromURL(url)
	local path = getPath(url)
	if fileExists(path) then --file already exists, so we can simply check filesize
		local file = fileOpen(path, true)
		local size = fileGetSize(file)
		fileClose(file)
		if size > maxFileSize then
			local text = "The filesize exceeds the maximum allowed filesize for item textures ("..tostring(math.floor(maxFileSize/1000)).."kb)."
			triggerEvent("item-texture:fileValidationResult", root, url, false, text)
			return false
		else
			triggerEvent("item-texture:fileValidationResult", root, url, true)
			return true
		end
	else --we need to get info from server
		triggerServerEvent("item-texture:validateFile", resourceRoot, url)
		return false
	end
end
addEvent("item-texture:fileValidationResult", true)

function godebug(cmd)
	if exports.integration:isPlayerScripter(localPlayer) then
		debugMode = not debugMode
		outputChatBox("item-texture debug set to "..tostring(debugMode))
	end
end
addCommandHandler("debugitemtexture", godebug)

--[[addEventHandler("onClientElementStreamIn", getRootElement(),
    function ( )
        local elementType = getElementType( source )
        if elementType == "object" or elementType == "vehicle" then
        	if unshaded[source] and #unshaded[source] > 0 then
				local thisNum = #unshaded[source]
				local timesRan = 0
				--outputDebugString("unshaded:"..tostring(thisNum))
				local i = 1
				while i <= #unshaded[source] do
					timesRan = timesRan + 1
					local v = unshaded[source][i]
					local k = i
					if debugMode then
						--outputDebugString("IN: "..tostring(elementType))
						outputDebugString("IN: addTexture("..tostring(getElementType(source))..", "..tostring(v[1])..", "..tostring(v[2])..") (#"..tostring(timesRan).."/"..tostring(thisNum)..")")
					end
					addTexture(source, v[1], v[2])
				end
				if debugMode then
					outputDebugString("timesRan="..tostring(timesRan))
				end
        	end
        	if elementType == "object" then
	        	--gate hack
	        	if(getElementData(source, "gate")) then
	        		setObjectBreakable(source, false)
	        	end
	        	--breakable hack
	        	--local modelid = getElementModel(source)
	        end
        end
    end
);]]

running = false
setTimer(
	function ( )
		if not running then
			running = true
			for key,elementType in ipairs({"object", "vehicle"}) do
				for k,element in ipairs(getElementsByType(elementType, root, true)) do
					if isElementOnScreen(element) then
						if unshaded[element] and #unshaded[element] > 0 then
							local thisNum = #unshaded[element]
							local timesRan = 0
							--outputDebugString("unshaded:"..tostring(thisNum))
							local i = 1
							while i <= #unshaded[element] do
								timesRan = timesRan + 1
								local v = unshaded[element][i]
								local k = i
								if debugMode then
									--outputDebugString("IN: "..tostring(elementType))
									outputDebugString("IN: addTexture("..tostring(getElementType(element))..", "..tostring(v[1])..", "..tostring(v[2])..") (#"..tostring(timesRan).."/"..tostring(thisNum)..")")
								end
								addTexture(element, v[1], v[2])
							end
						end
					end
				end
			end
			running = false
		end
	end,
2000, 0)

addEventHandler("onClientElementStreamOut", getRootElement(),
    function ( )
       local elementType = getElementType( source )
       if elementType == "object" or elementType == "vehicle" then
        	if loaded[source] and #loaded[source] > 0 then
        		local thisNum = #loaded[source]
        		local timesRan = 0
				local i = 1
				while i <= #loaded[source] do
					timesRan = timesRan + 1
					local k = i
					local v = loaded[source][i]

					local texname = v.texname
					local url = v.url
					if debugMode then
						--outputDebugString("OUT: "..tostring(elementType))
						outputDebugString("OUT: removeTexture("..tostring(getElementType(source))..", "..tostring(texname)..") (#"..tostring(timesRan).."/"..tostring(thisNum)..")")
					end
					removeTexture(source, texname)
					if not unshaded[source] then
						unshaded[source] = {}
					end
					table.insert(unshaded[source], {texname, url})
				end
        	end
        end
    end
);

addEvent('item-texture:initialSync', true)
addEventHandler('item-texture:initialSync', resourceRoot, function(cacheTable)
	outputDebugString("item-texture: You received initial sync for "..tostring(#cacheTable).." elements.")
	for k,v in ipairs(cacheTable) do
		addTexture(v[1], v[2], v[3])
	end
end)

addEventHandler('onClientResourceStart', resourceRoot, function(res)
	triggerServerEvent('item-texture:syncNewClient', resourceRoot)
	blankDecals()
end)

function stopPreview(element, texName)
	setVehicleColor(element, unpack(oldColor))
	removeTexture(element, texName)
	oldColor = nil
end	

function cancelPreview()
	if isTimer(previewTimer) then
		killTimer(previewTimer)
		stopPreview(veh, textureName)
		textureName, veh, previewTimer = nil
		outputChatBox("You have cancelled your preview.", 255, 194, 14)
	else
		outputChatBox("You are currently not previewing a vehicle wrap.", 255, 194, 14)
	end
end	
addCommandHandler("cancelpreview", cancelPreview)