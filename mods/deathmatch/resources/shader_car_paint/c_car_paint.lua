--
-- c_car_paint.lua
--
--[[
addEventHandler( "onClientResourceStart", resourceRoot,
	function()

		-- Version check
		if getVersion ().sortable < "1.1.0" then
			outputChatBox( "Resource is not compatible with this client." )
			return
		end

		-- Create shader
		local myShader, tec = dxCreateShader ( "car_paint.fx" )

		if not myShader then
			outputChatBox( "Could not create shader. Please use debugscript 3" )
		else
			outputChatBox( "Using technique " .. tec )

			-- Set textures
			local textureVol = dxCreateTexture ( "images/smallnoise3d.dds" );
			local textureCube = dxCreateTexture ( "images/cube_env256.dds" );
			dxSetShaderValue ( myShader, "sRandomTexture", textureVol );
			dxSetShaderValue ( myShader, "sReflectionTexture", textureCube );

			-- Apply to world texture
			engineApplyShaderToWorldTexture ( myShader, "vehiclegrunge256" )
			engineApplyShaderToWorldTexture ( myShader, "?emap*" )
		end
	end
)
]]

local myShader
local timer
function update( )
	if getElementData(localPlayer, "graphic_shaderveh") ~= "0" then
		-- Create shader
		myShader, tec = dxCreateShader ( "car_paint.fx" )
		
		if not myShader then
			-- outputChatBox( "Could not create shader. Please use debugscript 3" )
		else
			--outputDebugString( "water shader: Using technique " .. tec )

			local textureVol = dxCreateTexture ( "images/smallnoise3d.dds" );
			local textureCube = dxCreateTexture ( "images/cube_env256.dds" );
			dxSetShaderValue ( myShader, "sRandomTexture", textureVol );
			dxSetShaderValue ( myShader, "sReflectionTexture", textureCube );

			-- Apply to world texture
			engineApplyShaderToWorldTexture ( myShader, "vehiclegrunge256" )
			engineApplyShaderToWorldTexture ( myShader, "?emap*" )
			
			timer = setTimer(
				function()
					if myShader then
						local r,g,b,a = getWaterColor()
						dxSetShaderValue ( myShader, "gVehicleColor", r/255, g/255, b/255, a/255 );
					end
				end,
				5000,
				0
			)
		end
	else
		if myShader then
			destroyElement(myShader)
			killTimer(timer)
			myShader = nil
		end
	end
end

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()), update )
addEvent("accounts:settings:graphic_shaderveh", false)
addEventHandler( "accounts:settings:graphic_shaderveh", root, update )

--[[
function disableVehicleShader()
	if not myShader then return end

	-- Destroy all elements
	destroyElement( myShader )
	myShader = false
end]]
