--
-- c_water.lua
--

local myShaders
local myTextures = { }

local num = 6

function render( )
	if isPlayerMapVisible( ) then
		return
	end
	
	local textures = {engineGetVisibleTextureNames("radar??"), engineGetVisibleTextureNames("radar???")}
	local count = 1
	for _, t in ipairs(textures) do
		for _, name in pairs(t) do
			if not count then
			--	outputDebugString("count = WTF")
			elseif not myShaders[count] then
				--outputDebugString("would need " .. count .. " shaders")
			elseif myShaders[count].texture ~= name then
				if myShaders[count].texture then
					engineRemoveShaderFromWorldTexture(myShaders[count].shader, myShaders[count].texture)
				end
				
				if not myTextures[name] then
					myTextures[name] = dxCreateTexture(name:gsub("radar", "radar/")..".jpg")
				end
				dxSetShaderValue(myShaders[count].shader, "Tex0", myTextures[name])
				myShaders[count].texture = name
				
				engineApplyShaderToWorldTexture(myShaders[count].shader, name)
			end
			count = count + 1
		end
	end
	
	for i = count, num do
		if myShaders[i].texture ~= nil then
			engineRemoveShaderFromWorldTexture(myShaders[i].shader, myShaders[i].texture)
			myShaders[i].texture = nil
		end
	end
	
	for k, v in ipairs(myTextures) do
		for i = 1, num do
			if myShaders[i].texture == k then
				found = true
				break
			end
			
			if not found then
				destroyElement(v)
			end
		end
	end
end

function update( )
	if tonumber( exports.account:loadSavedData("enable_radar_shader", "1") ) == 1 and getElementData(getLocalPlayer(), "graphic_shaderradar") ~= "0" then
		if myShaders then
			return
		end
		
		-- Create shader
		myShaders = {}
		for i = 1, num do
			myShaders[i] = {shader = dxCreateShader ( "radar.fx" )}

			-- outputDebugString( "radar shader" .. i )
		end
		addEventHandler("onClientHUDRender", root, render)
	else
		if myShaders then
			for i = 1, num do
				destroyElement(myShaders[i].shader)
			end
			for k, v in pairs(myTextures) do
				destroyElement(v)
			end
			myShaders = nil
			myTextures = {}
			removeEventHandler("onClientHUDRender", root, render)
		end
	end
end
addEventHandler("accounts:characters:spawn", root, update)

addEventHandler( "onClientResourceStart", resourceRoot, function()
	setTimer(update, 2500, 1)
end)

