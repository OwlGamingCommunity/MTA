--
-- c_water.lua
--

local myShader
local timer
function update( )
	if getElementData(localPlayer, "graphic_shaderwater") ~= "0" then
		if myShader then
			return
		end
		-- Create shader
		myShader, tec = dxCreateShader ( "water.fx" )

		if not myShader then
			-- outputChatBox( "Could not create shader. Please use debugscript 3" )
		else
			--outputDebugString( "water shader: Using technique " .. tec )

			-- Set textures
			local textureVol = dxCreateTexture ( "images/smallnoise3d.dds" );
			local textureCube = dxCreateTexture ( "images/cube_env256.dds" );
			dxSetShaderValue ( myShader, "microflakeNMapVol_Tex", textureVol );
			dxSetShaderValue ( myShader, "showroomMapCube_Tex", textureCube );

			-- Apply to global txd 13
			engineApplyShaderToWorldTexture ( myShader, "waterclear256" )
			
			timer = setTimer(
				function()
					if myShader then
						local r,g,b,a = getWaterColor()
						dxSetShaderValue ( myShader, "gWaterColor", r/255, g/255, b/255, a/255 );
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
addEventHandler( "onClientResourceStart", resourceRoot, update )
addEvent("accounts:settings:graphic_shaderwater", false)
addEventHandler( "accounts:settings:graphic_shaderwater", root, update )

