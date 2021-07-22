Settings = {}
Settings.var = {}
local scx, scy = guiGetScreenSize()

function setcpRLEffectVehicle()
    local v = Settings.var
	v.renderDistance = 60 -- max render distance of the shader effect
	v.scXY = {scx, scy} -- reflection screensource resolution (can be scx,scy)
	v.isEffectlayered = {false, false} -- should the carpaint,windshield effects be layered
	v.normalXY = 0.2 -- deformation strength (0-1.0) 1.0 = the highest (X and Y of vector)
	v.normalZ = 0.2 -- deformation strength (0-1.0) 1.0 = the highest (Z of vector)
	v.bumpSize = 0.0 -- for car paint
	v.envIntensity = {0.45, 0.99} -- intensity of the reflection effect
	v.brightnessMul = {1.2, 1.5} -- multiply after brightpass
	v.brightpassPower = {2.5, 2.0} -- 1-5
	v.brightnessAdd = {0.1, 0.1} -- before bright pass
	v.brightpassCutoff = {0.00, 0.00} -- cutoff lower light spectrum
	v.specularValue = {0.7, 0.7} -- gtasa vehicle specular value (0-1)
	v.refTexValue = {0.1, 0.1} -- gtasa reflection texture visibility
	v.uvMul = {2.0,0.5} -- uv multiply
	v.uvMov = {0,-2.8} -- uv move
end

--a table of additional texture names:	
	local texturegrun = {
			"predator92body128", "monsterb92body256a", "monstera92body256a", "andromeda92wing","fcr90092body128",
			"hotknifebody128b", "hotknifebody128a", "rcbaron92texpage64", "rcgoblin92texpage128", "rcraider92texpage128",
			"rctiger92body128","rhino92texpage256", "petrotr92interior128","artict1logos","rumpo92adverts256","dash92interior128",
			"coach92interior128","combinetexpage128","policemiami86body128","01","policemiami868bit128","hotdog92body256",
			"raindance92body128", "cargobob92body256", "andromeda92body", "at400_92_256", "nevada92body256",
			"polmavbody128a" , "sparrow92body128" , "hunterbody8bit256a" , "seasparrow92floats64" ,
			"dodo92body8bit256" , "cropdustbody256", "beagle256", "hydrabody256", "rustler92body256",
			"shamalbody256", "skimmer92body128", "stunt256", "maverick92body128", "leviathnbody8bit256" }

function startCarPaintRefLite()
		if cpRLEffectEnabled then return end
		local v = Settings.var
		setcpRLEffectVehicle()

		-- Create shader files
		createShaderFiles(v.isEffectlayered[1],v.isEffectlayered[2])

		local layerString = ""
		if v.isEffectlayered[1] then layerString = "_layer" else layerString = "" end
		paintShader, tec = dxCreateShader ( "fx/car_paint"..layerString..".fx",2 ,v.renderDistance ,v.isEffectlayered[1],"vehicle" )
		myScreenSource = dxCreateScreenSource( v.scXY[1], v.scXY[2] )
		if v.isEffectlayered[2] then layerString = "_layer" else layerString = "" end
		glassShader, tec = dxCreateShader ( "fx/car_glass"..layerString..".fx",2 , v.renderDistance , v.isEffectlayered[2], "vehicle" )
		shatterShader, tec = dxCreateShader ( "fx/car_glass"..layerString..".fx",2 , v.renderDistance , v.isEffectlayered[2], "vehicle" )

		-- Destroy shader files
		destroyShaderFiles(v.isEffectlayered[1],v.isEffectlayered[2])

		textureVol = dxCreateTexture ( "images/smallnoise3d.dds" )
		if paintShader and glassShader and shatterShader and textureVol and myScreenSource then

			addEventHandler ( "onClientPreRender", getRootElement (), updateScreen )
			-- Set textures

			dxSetShaderValue ( paintShader, "sRandomTexture", textureVol )
			dxSetShaderValue ( paintShader, "sReflectionTexture", myScreenSource )
			dxSetShaderValue ( glassShader, "sReflectionTexture", myScreenSource )
			dxSetShaderValue ( shatterShader, "sReflectionTexture", myScreenSource )


			dxSetShaderValue ( paintShader, "sNorFacXY", v.normalXY)
			dxSetShaderValue ( paintShader, "sNorFacZ", v.normalZ)
			dxSetShaderValue ( paintShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue ( paintShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue ( paintShader, "bumpSize", v.bumpSize )
			dxSetShaderValue ( paintShader, "envIntensity", v.envIntensity[1])
			dxSetShaderValue ( paintShader, "specularValue", v.specularValue[1])
			dxSetShaderValue ( paintShader, "refTexValue", v.refTexValue[1])

			dxSetShaderValue ( paintShader, "sPower", v.brightpassPower[1])			
			dxSetShaderValue ( paintShader, "sAdd", v.brightnessAdd[1])
			dxSetShaderValue ( paintShader, "sMul", v.brightnessMul[1])
			dxSetShaderValue ( paintShader, "sCutoff", v.brightpassCutoff[1])

			dxSetShaderValue ( glassShader, "sNorFacXY", v.normalXY)
			dxSetShaderValue ( glassShader, "sNorFacZ", v.normalZ)
			dxSetShaderValue ( glassShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue ( glassShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue ( glassShader, "envIntensity", v.envIntensity[2])
			dxSetShaderValue ( glassShader, "specularValue", v.specularValue[2])
			dxSetShaderValue ( glassShader, "refTexValue", v.refTexValue[2])

			dxSetShaderValue ( glassShader, "sPower", v.brightpassPower[2])			
			dxSetShaderValue ( glassShader, "sAdd", v.brightnessAdd[2])
			dxSetShaderValue ( glassShader, "sMul", v.brightnessMul[2])
			dxSetShaderValue ( glassShader, "sCutoff", v.brightpassCutoff[2])
			dxSetShaderValue ( glassShader, "isShatter", false)

			dxSetShaderValue ( shatterShader, "sNorFacXY", v.normalXY)
			dxSetShaderValue ( shatterShader, "sNorFacZ", v.normalZ)
			dxSetShaderValue ( shatterShader, "uvMul", v.uvMul[1],v.uvMul[2])
			dxSetShaderValue ( shatterShader, "uvMov", v.uvMov[1],v.uvMov[2])
			dxSetShaderValue ( shatterShader, "envIntensity", v.envIntensity[2])
			dxSetShaderValue ( shatterShader, "specularValue", v.specularValue[2])
			dxSetShaderValue ( shatterShader, "refTexValue", v.refTexValue[2])

			dxSetShaderValue ( shatterShader, "sPower", v.brightpassPower[2])			
			dxSetShaderValue ( shatterShader, "sAdd", v.brightnessAdd[2])
			dxSetShaderValue ( shatterShader, "sMul", v.brightnessMul[2])
			dxSetShaderValue ( shatterShader, "sCutoff", v.brightpassCutoff[2])			
			dxSetShaderValue ( shatterShader, "isShatter", true)

			-- Apply to world texture
			engineApplyShaderToWorldTexture ( paintShader, "vehiclegrunge256" )
			engineApplyShaderToWorldTexture ( paintShader, "?emap*" )
			engineApplyShaderToWorldTexture ( glassShader, "vehiclegeneric256" )
			engineApplyShaderToWorldTexture ( shatterShader, "vehicleshatter128" )

			for _,addList in ipairs(texturegrun) do
			engineApplyShaderToWorldTexture (paintShader, addList )
		    end	
			cpRLEffectEnabled = true
		else	
			outputChatBox( "Could not create shader. Please use debugscript 3",255,0,0 ) return		
		end
end

function stopCarPaintRefLite()
	if not cpRLEffectEnabled then return end
	removeEventHandler ( "onClientPreRender", getRootElement (), updateScreen )
	engineRemoveShaderFromWorldTexture ( paintShader,"*" )
	destroyElement( paintShader )
	paintShader = nil
	engineRemoveShaderFromWorldTexture ( glassShader,"*" )
	destroyElement( glassShader )
	glassShader = nil
	engineRemoveShaderFromWorldTexture ( shatterShader,"*" )
	destroyElement( shatterShader )
	shatterShader = nil
	destroyElement( textureVol )
	textureVol = nil
	destroyElement(myScreenSource)
	myScreenSource = nil
	cpRLEffectEnabled = false
end

function updateScreen()
	if myScreenSource then
		dxUpdateScreenSource( myScreenSource)
	end
end