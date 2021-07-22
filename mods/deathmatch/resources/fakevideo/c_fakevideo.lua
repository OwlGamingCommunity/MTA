--fakevideo
--Script allows replacing textures in the game with a range of remote pictures to make animated textures
--Created by Exciter, 21.06.2014 (DD.MM.YYYY).
--Based upon iG texture-system (based on Exciter's uG/RPP texture-system), shader_cinema_fl by Ren712, and OwlGaming/Cat's fixes to texture-system based on mabako-clothingstore. 

--exports
global = exports.global
integration = exports.integration

--settings
theItemID = 165
defaultLoadImg = "load.png"
shaderDataDefault = {brightness = -0.25, scrollX = 0, scrollY = 0, xScale = 1, yScale = 1, rotAngle = 0, alpha = 1, grayScale = 0, redColor = 0, grnColor = 0, bluColor = 0, xOffset = 0, yOffset = 0 }

--cache
fakevideos = {}
loaded = {}
disabledFakevids = {}
streaming = {}
animQueue = {}

--define vars
local loaded = {}
resourceRoot = getResourceRootElement(getThisResource())
root = getRootElement()
localPlayer = getLocalPlayer()

local function getPath(id, frame)
	return "@cache/"..tostring(id).."_"..tostring(frame)..".tex"
end

function addTexture(id, texName, object, loadimg, shaderData)
	--outputDebugString("addTexture")
	if not texName then
		outputDebugString("fakevideo/c_fakevideo: addTexture - texName not given")
		return
	end
	if not object then object = nil end
	-- current dimension?
	local dimension = getElementDimension(localPlayer)
	local data = fakevideos[id]
	local texture, shader, t

	if not shaderData then
		shaderData = {}
	end

	if not loaded[texName] then
		loaded[texName] = {}
	end

	local shadData
	if object then
		if (#loaded[texName] == 1) then
			if loaded[texName][1].object == object then
				shadData = loaded[texName][1]
			end
		else
			for k,v in ipairs(loaded[texName]) do
				if v.object == object then
					shadData = v
					break
				end
			end
		end
	elseif (#loaded[texName] == 1) then
		shadData = loaded[texName][1]
	end

	--start with placeholder (loading img)
	if not shadData then
		if loadimg then
			if not fileExists("files/"..loadimg) then
				loadimg = defaultLoadImg
			end
		else
			loadimg = defaultLoadImg
		end
		texture = dxCreateTexture("files/"..loadimg, "argb", true, "clamp", "2d", 1)
		if texture then
			--shader, t = dxCreateShader('shaders/replacement.fx', 0, 0, true, 'world,object')
			shader, t = dxCreateShader('shaders/texreptransform.fx', 0, 0, true, 'world,object')
			if shader then
				local radian=math.rad(shaderData.rotAngle or shaderDataDefault.rotAngle)
				-- If the image is too bright, you can darken it
				dxSetShaderValue ( shader, "gBrighten", shaderData.brightness or shaderDataDefault.brightness )
				-- Set the angle, grayscaled, rgb
				dxSetShaderValue ( shader, "gRotAngle", radian )
				dxSetShaderValue ( shader, "gGrayScale", shaderData.grayScale or shaderDataDefault.grayScale )
				dxSetShaderValue ( shader, "gRedColor", shaderData.redColor or shaderDataDefault.redColor )
				dxSetShaderValue ( shader, "gGrnColor", shaderData.grnColor or shaderDataDefault.grnColor )
				dxSetShaderValue ( shader, "gBluColor", shaderData.bluColor or shaderDataDefault.bluColor )
				-- Set image alpha (1 max)
				dxSetShaderValue ( shader, "gAlpha", shaderData.alpha or shaderDataDefault.alpha )
				-- Set scrolling (san set negative and positive values)
				dxSetShaderValue ( shader, "gScrRig",  shaderData.scrollX or shaderDataDefault.scrollX)
		        dxSetShaderValue ( shader, "gScrDow", shaderData.scrollY or shaderDataDefault.scrollY)
				-- Scale and offset (don't need to change that)
		        dxSetShaderValue ( shader, "gHScale", shaderData.xScale or shaderDataDefault.xScale )
				dxSetShaderValue ( shader, "gVScale", shaderData.yScale or shaderDataDefault.yScale )
				dxSetShaderValue ( shader, "gHOffset", shaderData.xOffset or shaderDataDefault.xOffset )
				dxSetShaderValue ( shader, "gVOffset", shaderData.yOffset or shaderDataDefault.yOffset ) 

				--dxSetShaderValue(shader, 'Tex0', texture)
				dxSetShaderValue(shader, 'gTexture', texture)
				engineApplyShaderToWorldTexture(shader, texName, object)
				if not loaded[texName] then
					loaded[texName] = {}
				end
				shadData = { id = id, texture = texture, shader = shader, object = object }
				table.insert(loaded[texName], shadData)
			else
				outputDebugString('creating shader for tex ' .. data.texture .. ' failed.', 2)
				destroyElement(texture)
			end
		else
			outputDebugString('creating texture for tex ' .. data.texture .. ' failed', 2)
		end
	end

	local allExist = true
	for i = 1, #data.frames do
		local path = getPath(id, i)
		if not fileExists(path) then
			allExist = false
			break
		end
	end
	--outputDebugString("allExist="..tostring(allExist))
	if allExist then
		if streaming[id] then
			streaming[id] = nil
		end

		if not shadData then
			destroyElement(texture)
			outputDebugString("fakevideo/c_fakevideo addTexture - Shader does not exist for " .. texName, 2)
			return
		end

		local textureTable = {}
		for i = 1, #data.frames do
			local path = getPath(id, i)
			texture = dxCreateTexture(path, "argb", true, "clamp", "2d", 1)
			table.insert(textureTable, texture)
		end
		
		local overrideSpeed = shaderData.speed or shaderDataDefault.speed

		local animData = {id = id, textures = textureTable, shader = shadData.shader, texname = texName, currentFrame = 1, lastTick = 0, speed = overrideSpeed }
		--setTimer(table.insert, 3000, 1, animQueue, animData)
		table.insert(animQueue, animData)
	else
		if not streaming[id] then
			streaming[id] = true
			triggerServerEvent('fakevideo:stream', resourceRoot, id, texName, object, loadimg)
		end
	end
end

function removeTexture(id, texName, object)
	if object then
		if texName then
			for k,v in ipairs(loaded[texName]) do
				if v.object == object then
					for k2,v2 in ipairs(animQueue) do
						if v2.shader == v.shader then
							for k3,v3 in ipairs(v2.textures) do
								destroyElement(v3)
							end
							table.remove(animQueue, k2)
							break
						end
					end
					engineRemoveShaderFromWorldTexture(v.shader, texName, object)
					table.remove(loaded[texName], k)
					break
				end
			end
		else
			for k,v in pairs(loaded) do
				for k2,v2 in ipairs(v) do
					if v2.object == object then
						for k3,v3 in ipairs(animQueue) do
							if v3.shader == v2.shader then
								for k4,v4 in ipairs(v3.textures) do
									destroyElement(v4)
								end
								table.remove(animQueue, k3)
								break
							end
						end
						engineRemoveShaderFromWorldTexture(v2.shader, k, object)
						loaded[k] = nil
						break
					end
				end
			end
		end
	else
		if texName then
			if (#loaded[texName] == 1) then
				local v = loaded[texName][1]
				for k2,v2 in ipairs(animQueue) do
					if v2.shader == v.shader then
						for k3,v3 in ipairs(v2.textures) do
							destroyElement(v3)
						end
						table.remove(animQueue, k2)
						break
					end
				end
				engineRemoveShaderFromWorldTexture(v.shader, texName, object)
				loaded[texName] = nil
			end
		end
	end
end

function removeAllTextures()
	for k,v in pairs(loaded) do
		removeTexture(0, k)
	end
	animQueue = {}
	loaded = {}
	disabledFakevids = {}
end

rendering = false
local sw, sh = guiGetScreenSize ( )
local lastDebug
function renderAnims()
	local debugString = ""
	for k,v in ipairs(animQueue) do
		local id = v.id
		local data = fakevideos[id]
		local speed = v.speed or data.speed
		local currentFrame = v.currentFrame
		local totalFrames = #v.textures
		local textures = v.textures
		local shader = v.shader
		local lastTick = v.lastTick
		--debugString = debugString..tostring((getTickCount() - lastTick)).." > "..tostring(speed)
		if ((getTickCount() - lastTick) > speed) and speed > 0 then
			debugString = debugString.."OK"
			nextFrame = currentFrame + 1
			if nextFrame > totalFrames then
				nextFrame = 1
			end
			getLastTick = getTickCount()
		    if textures[nextFrame] then
				--dxSetShaderValue(shader, "Tex0", textures[nextFrame])
				local result = dxSetShaderValue(shader, "gTexture", textures[nextFrame])
				v.currentFrame = nextFrame
				v.lastTick = getTickCount()
				lastDebug = "result="..tostring(result).." Frame="..tostring(nextFrame)
			end
		end
	end
	if debugMode then
		dxDrawText ( "DEBUG: "..tostring(lastDebug).." - "..tostring(debugString), sw * 0.02, sh * 0.65, sw, sh, tocolor ( 255, 255, 255, 255 ), 1.0, "default-bold" )
	end
end

local testValues = {
	["none"] = true,
	["no_mem"] = true,
	["low_mem"] = true,
	["no_shader"] = true
}
function testmode(cmd, value)
	if integration:isPlayerScripter(localPlayer) then
		if testValues[value] then
			dxSetTestMode(value)
			outputChatBox("Test mode set to "..value..".", 220, 175, 20, false)
		else
			outputChatBox("Invalid test mode entered.", 245, 20, 20, false)
		end
	end
end
addCommandHandler("setdxtestmode", testmode)

function godebug(cmd)
	if integration:isPlayerScripter(localPlayer) then
		debugMode = not debugMode
	end
end
addCommandHandler("debugfakevideo", godebug)

function updateTexturesOnNewDimension(dimension, toLoad)
	local thisDimension = getElementDimension(localPlayer)
	if(dimension ~= thisDimension) then
		--outputDebugString("fakevideo/c_fakevideo: updateTextureOnNewDimension: dimension mismatch")
		return false
	end
	--remove old anims
	if rendering then
		removeEventHandler("onClientHUDRender", root, renderAnims)
	end
	removeAllTextures()

	--get anims in this dimension
	local newAnims = toLoad or {} --format {id = id, texname = texture, object = object, loadimg = pathToLoadingImg, shaderData = shaderData}
	
	--[[
	if(dimension == 691) then
		table.insert(newAnims, {id = 2, texname = "drvin_screen", object = nil, loadimg = "clubtec_load.png"})
	elseif(dimension == 0) then
		table.insert(newAnims, {id = 6, texname = "drvin_screen", object = nil, loadimg = "clubtec_load.png"})
	end
	--]]

	--load new anims
	for k,v in ipairs(newAnims) do
		addTexture(v.id, v.texname, v.object, v.loadimg, v.shaderData)
	end

	--start rendering
	if(#newAnims > 0) then
		addEventHandler("onClientHUDRender", root, renderAnims)
		rendering = true
	end
	return true
end
addEvent('fakevideo:updateDimension', true)
addEventHandler('fakevideo:updateDimension', resourceRoot, updateTexturesOnNewDimension)

-- file we asked for is there
addEvent('fakevideo:file', true)
addEventHandler( 'fakevideo:file', resourceRoot,
	function(id, framesPixels, texName, object, loadimg)
		for key,data in ipairs(framesPixels) do
			local file = fileCreate(getPath(id, data.frame))
			local written = fileWrite(file, data.pixels)
			fileClose(file)
			if written ~= data.size then
				fileDelete(getPath(id, data.frame))
			end
		end
		--addTexture(id, texName, object, loadimg)
		setTimer(addTexture, 3000, 1, id, texName, object, loadimg)
	end, false)

addEvent('fakevideo:removeOne', true)
addEventHandler('fakevideo:removeOne', root,
	function(id, texName, object)
		removeTexture(id, texName, object)
	end, false)

addEvent('fakevideo:addOne', true)
addEventHandler('fakevideo:addOne', root,
	function(id, texName, object, loadimg, shaderData)
		addTexture(id, texName, object, loadimg, shaderData)
	end)

addEvent('fakevideo:updateShader', true)
addEventHandler('fakevideo:updateShader', root, function(texName, object, shaderData, newTexName, newObject, oldOverrideSpeed, newOverrideSpeed)
	--outputDebugString("texName='"..tostring(texName).."' object='"..tostring(object).."' shaderData='"..tostring(shaderData).."'")
	local shader
	local loadedData
	local loadedDataNum
	--outputDebugString("loaded[texName]="..tostring(loaded[texName]))
	if not object and loaded[texName] then
		shader = loaded[texName][1].shader
		loadedData = loaded[texName][1]
		loadedDataNum = 1
		--outputDebugString("loaded[texName][1].shader="..tostring(loaded[texName][1].shader))
	else
		if loaded[texName] then
			for k,v in ipairs(loaded[texName]) do
				if v.object == object then
					shader = v.shader
					loadedData = loaded[texName][k]
					loadedDataNum = k
					break
				end
			end
		end	
	end
	--outputDebugString("shader="..tostring(shader))
	if shader then
		if(texName ~= newTexName or object ~= newObject or oldOverrideSpeed ~= newOverrideSpeed) then --if the texture or object to replace changed
			--TODO: if object changed
			engineRemoveShaderFromWorldTexture(shader, texName, object)
			local newLoadedData = { id = loadedData.id, texture = loadedData.texture, shader = shader, object = newObject, speed = newOverrideSpeed }
			table.remove(loaded[texName], loadedDataNum)
			if not loaded[newTexName] then loaded[newTexName] = {} end
			table.insert(loaded[newTexName], newLoadedData)
			engineApplyShaderToWorldTexture(shader, newTexName, newObject)
			local animQueueNum
			local animDataOld
			for k,v in ipairs(animQueue) do
				if v.shader == shader then
					animQueueNum = k
					animDataOld = v
					break
				end
			end
			if animQueueNum and animDataOld then
				local animData = animDataOld
				--local animData = {id = animDataOld.id, textures = animDataOld.textures, shader = shader, texname = newTexName, currentFrame = animDataOld.currentFrame, lastTick = animDataOld.lastTick, speed = newOverrideSpeed }
				table.remove(animQueue, animQueueNum)
				animData.shader = shader
				animData.texname = newTexName
				animData.speed = newOverrideSpeed
				table.insert(animQueue, animData)
			end
		end
		local radian=math.rad(shaderData.rotAngle or shaderDataDefault.rotAngle)
		dxSetShaderValue ( shader, "gBrighten", shaderData.brightness or shaderDataDefault.brightness )
		dxSetShaderValue ( shader, "gRotAngle", radian )
		dxSetShaderValue ( shader, "gGrayScale", shaderData.grayScale or shaderDataDefault.grayScale )
		dxSetShaderValue ( shader, "gRedColor", shaderData.redColor or shaderDataDefault.redColor )
		dxSetShaderValue ( shader, "gGrnColor", shaderData.grnColor or shaderDataDefault.grnColor )
		dxSetShaderValue ( shader, "gBluColor", shaderData.bluColor or shaderDataDefault.bluColor )
		dxSetShaderValue ( shader, "gAlpha", shaderData.alpha or shaderDataDefault.alpha )
		dxSetShaderValue ( shader, "gScrRig",  shaderData.scrollX or shaderDataDefault.scrollX)
		dxSetShaderValue ( shader, "gScrDow", shaderData.scrollY or shaderDataDefault.scrollY)
		dxSetShaderValue ( shader, "gHScale", shaderData.xScale or shaderDataDefault.xScale )
		dxSetShaderValue ( shader, "gVScale", shaderData.yScale or shaderDataDefault.yScale )
		dxSetShaderValue ( shader, "gHOffset", shaderData.xOffset or shaderDataDefault.xOffset )
		dxSetShaderValue ( shader, "gVOffset", shaderData.yOffset or shaderDataDefault.yOffset )
	end
end)

addEvent('fakevideo:initialSync', true)
addEventHandler('fakevideo:initialSync', resourceRoot, function(cacheTable)
	fakevideos = cacheTable
	--outputDebugString("Client received "..tostring(#cacheTable).." fakevideos")
end)

addEventHandler('onClientResourceStart', resourceRoot, function(res)
	triggerServerEvent('fakevideo:syncNewClient', resourceRoot)
	triggerServerEvent('fakevideo:loadDimension', resourceRoot, getElementDimension(localPlayer))
end)

function refreshCalls(res)
	global = exports.global
	integration = exports.integration
end
addEventHandler("onClientResourceStart", getRootElement(), refreshCalls)