--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Original author: Ren712
* ***********************************************************************************************************************
]]

shaderTable = { worldShader = {} , smVersion = 0 , isStarted = false , isTimeOut = false, isError = false, isConfigChanged = false }
lightTable = { inputLights = {} , outputLights = {} , thisLight = 0 , isInNrChanged = false, isInValChanged = false }
funcTable = {}

---------------------------------------------------------------------------------------------------
-- editable variables
---------------------------------------------------------------------------------------------------
					
local edgeTolerance = 0.39 -- cull the lights that are off the screen
local effectRange = 300 -- effect max range
local isEffectForcedOn = true -- set true to force the effects to stay on despite no light sources 
								-- (useful if changed shaderSettings.gBrightness)
local effectTimeOut = 3 -- how much time does the effect turn off after 0 lights synced (in seconds)
local shaderSettings = {
				gIsLayered = {false, true, true}, -- set world, vehicle and ped effect layered
				gNormalShading = {true, true, true}, -- enables world,vehicle,ped self shadowing ( may be bugged for rotated objects on a custom map)
				gGenerateBumpNormals = false, -- generate bump normals from color texture (hogs few fps)
				gTextureSize = 512.0, -- generated normat texture size (256 or 512 recomended)
				gNormalStrength = {1,1,1}, -- Bump strength (0-1)
				gDistFade = {120, 100}, -- [0]MaxEffectFade,[1]MinEffectFade
				gMaxLights = 8, -- how many light effects can be streamed in at once (max 15)
				gBrightness = 0.5, -- modify texture brightness 0 - fully obscured 1 - normal brightness
				gNightMod = true, -- enable nightMod effect - requires proper manipulation of setTextureBrightness and SetShaderDayTime, 
									-- also some additional shaders.
				gDayTime = 1, -- another additional variable to control texture colors - requires setShaderNightMod(true)
				gPedDiffuse = true, -- enable or disable gta directional lights for ped.
				dirLight = { enabled = false, dir = {0,0,-1}, col = {0,0,0,0}, range = 40}, -- this is a single directional light table (stould stay unaltered)
				diffLight = { enabled = false, col = {0,0,0,0}, range = 40 } ,-- this is a single diffuse light table (stould stay unaltered)
				nightSpot = { enabled = false, pos = {0,0,0}, radius = 40 } -- this is a single diffuse light table (stould stay unaltered)				
				}

---------------------------------------------------------------------------------------------------
-- texture lists
---------------------------------------------------------------------------------------------------
local removeList = {
						"",	-- unnamed
						"basketball2","skybox_tex*","flashlight_*",                -- other
						"muzzle_texture*",                                         -- guns
						"font*","radar*","sitem16","snipercrosshair",              -- hud
						"siterocket","cameracrosshair",                            -- hud
						"fireba*","wjet6",                                         -- flame
						"vehiclegeneric256","vehicleshatter128",                   -- vehicles
						"*shad*",                                                  -- shadows
						"coronastar","coronamoon","coronaringa",
						"coronaheadlightline",                                     -- coronas
						"lunar",                                                   -- moon
						"tx*",                                                     -- grass effect
						"lod*",                                                    -- lod models
						"cj_w_grad",                                               -- checkpoint texture
						"*cloud*",                                                 -- clouds
						"*smoke*",                                                 -- smoke
						"sphere_cj",                                               -- nitro heat haze mask
						"particle*",                                               -- particle skid and maybe others
						"water*","newaterfal1_256",
						"boatwake*","splash_up","carsplash_*",
						"boatsplash",
						"gensplash","wjet4","bubbles","blood*",                    -- splash
						"fist","*icon","headlight*",
						"unnamed","sphere",	
						"sl_dtwinlights*","nitwin01_la","sfnite*","shad_exp",
						"vgsn_nl_strip","blueshade*",
						"royaleroof01_64","flmngo05_256","flmngo04_256",
						"casinolights6lit3_256"                                    -- some shinemaps and anims
					}

local reApplyList = {
					"ws_tunnelwall2smoked", "shadover_law",
					"greenshade_64", "greenshade2_64", "venshade*", 
					"blueshade2_64","blueshade4_64","greenshade4_64",
					"metpat64shadow","bloodpool_*"
					}

---------------------------------------------------------------------------------------------------
-- main light functions
---------------------------------------------------------------------------------------------------
function funcTable.create(lType,posX,posY,posZ,colorR,colorG,colorB,colorA,dirX,dirY,dirZ,isEuler,falloff,theta,phi,attenuation,normalShadow)
	local w = findEmptyEntry(lightTable.inputLights)
	if not lightTable.inputLights[w] then lightTable.inputLights[w] ={}	end
	lightTable.inputLights[w].enabled = true
	lightTable.inputLights[w].lType = lType
	lightTable.inputLights[w].pos = {posX,posY,posZ}
	lightTable.inputLights[w].color = {colorR,colorG,colorB,colorA}	
	lightTable.inputLights[w].attenuation = attenuation
	lightTable.inputLights[w].normalShadow = normalShadow
	if (lType > 1) then 
		if isEuler then 
			local eul2vecX,eul2vecY,eul2vecZ = getVectorFromEulerXZ(dirX,dirY,dirZ) 
			lightTable.inputLights[w].dir = {eul2vecX,eul2vecY,eul2vecZ}
		else
			lightTable.inputLights[w].dir = {dirX,dirY,dirZ}
		end
		lightTable.inputLights[w].falloff = falloff
		lightTable.inputLights[w].theta = theta
		lightTable.inputLights[w].phi = phi
	end
	outputDebugString('Created Light TYPE: '..lType..' ID:'..w)
	lightTable.isInNrChanged = true
	return w
end

function funcTable.destroy(w)
	if lightTable.inputLights[w] then
		lightTable.inputLights[w].enabled = false
		lightTable.isInNrChanged = true
		outputDebugString('Destroyed Light ID:'..w)
		return true
	else
		outputDebugString('Have Not Destroyed Light ID:'..w)
		return false 
	end
end

function funcTable.setMaxLights(maxLights)
	shaderSettings.gMaxLights = maxLights
	funcTable.refreshSettings()
	shaderTable.isConfigChanged = true
	if isEffectForcedOn then
		if funcTable.forceStop() then 
			return funcTable.forceStart()
		end
	else
		return funcTable.forceStop() or funcTable.forceStart()		
	end
end

function funcTable.setWorldNormalShading(isWrd)
	shaderSettings.gNormalShading[1] = isWrd
	funcTable.refreshSettings()
	shaderTable.isConfigChanged = true
	if isEffectForcedOn then
		if funcTable.forceStop() then 
			return funcTable.forceStart()
		end
	else
		return funcTable.forceStop() or funcTable.forceStart()		
	end
end

function funcTable.setNormalShading(isWrd,isVeh,isPed)
	shaderSettings.gNormalShading = {isWrd,isVeh,isPed}
	funcTable.refreshSettings()
	shaderTable.isConfigChanged = true
	if isEffectForcedOn then
		if funcTable.forceStop() then 
			return funcTable.forceStart()
		end
	else
		return funcTable.forceStop() or funcTable.forceStart()		
	end
end

function funcTable.setDistFade(w,v)
	if ((w <= effectRange) and (w >= v)) then
		shaderSettings.gDistFade = {w,v}
		if shaderTable.isStarted then
			return funcTable.refreshGlobalShaderValues()
		else
			return true
		end
	else
		return false
	end
end

function funcTable.setEffectRange(w)
	if (w > 0) then
		effectRange = w
		funcTable.refreshSettings()
		if isEffectForcedOn then
			if funcTable.forceStop() then 
				return funcTable.forceStart()
			end
		else
			return funcTable.forceStop() or funcTable.forceStart()		
		end
	else
		return false
	end
end

function funcTable.setShadersLayered(isWrd,isVeh,isPed)
	shaderSettings.gIsLayered = {isWrd,isVeh,isPed}
	funcTable.refreshSettings()
	shaderTable.isConfigChanged = true
	if isEffectForcedOn then
		if funcTable.forceStop() then 
			return funcTable.forceStart()
		end
	else
		return funcTable.forceStop() or funcTable.forceStart()		
	end
end

function funcTable.generateBumpNormals(isGenerated,texSize,stX,stY,stZ)
	shaderSettings.gGenerateBumpNormals = isGenerated
	shaderSettings.gTextureSize = texSize
	shaderSettings.gNormalStrength = {stX,stY,stZ}
	funcTable.refreshSettings()
	shaderTable.isConfigChanged = true
	if isEffectForcedOn then
		if funcTable.forceStop() then 
			return funcTable.forceStart()
		end
	else
		return funcTable.forceStop() or funcTable.forceStart()		
	end
end

function funcTable.setShadersForcedOn(w)
	if type(w)=="boolean" then
		isEffectForcedOn = w
		outputDebugString('Pixel Lighting: shaders forced '..tostring(isEffectForcedOn) )
		if isEffectForcedOn then
			return funcTable.forceStart()
		else
			return true
		end
	else
		return false
	end
end

function funcTable.setShadersTimeOut(w)
	if type(w)=="number" then
		effectTimeOut = w
		outputDebugString('Pixel Lighting: effect timeout '..tostring(effectTimeOut)..' sec' )
		return true
	else
		return false
	end
end

function funcTable.setShaderNightMod(w)
	shaderSettings.gNightMod = w
	shaderTable.isConfigChanged = true
	funcTable.refreshSettings()
	if isEffectForcedOn then
		if funcTable.forceStop() then 
			return funcTable.forceStart()
		end
	else
		return funcTable.forceStop() or funcTable.forceStart()		
	end
end

function funcTable.setShaderPedDiffuse(w)
	shaderSettings.gPedDiffuse = w
	funcTable.refreshSettings()
	if isEffectForcedOn then
		if funcTable.forceStop() then 
			return funcTable.forceStart()
		end
	else
		return funcTable.forceStop() or funcTable.forceStart()		
	end
end

function funcTable.setShaderDayTime(w)
	if ((w <= 1) and (w >= 0)) then
		shaderSettings.gDayTime = w
	else
		return false
	end
end

function funcTable.setTextureBrightness(w)
	if ((w <= 1) and (w >= 0)) then
		shaderSettings.gBrightness = w
		return true
	else
		return false
	end
end

function funcTable.setDirLightEnable(isTrue)
	shaderSettings.dirLight.enabled = isTrue
	shaderTable.isConfigChanged = true
	funcTable.refreshSettings()
	if isEffectForcedOn then
		if funcTable.forceStop() then 
			return funcTable.forceStart()
		end
	else
		return funcTable.forceStop() or funcTable.forceStart()		
	end
end

function funcTable.setDirLightColor(colorR,colorG,colorB,colorA)
	shaderSettings.dirLight.col = {colorR,colorG,colorB,colorA}
	funcTable.applyDirLightSettings(shaderTable.worldShader[1])
	--funcTable.applyDirLightSettings(shaderTable.worldShader[2])
	--funcTable.applyDirLightSettings(shaderTable.worldShader[3])
	return true
end

function funcTable.setDirLightRange(lRange)
	shaderSettings.dirLight.range = lRange
	funcTable.applyDirLightSettings(shaderTable.worldShader[1])
	--funcTable.applyDirLightSettings(shaderTable.worldShader[2])
	--funcTable.applyDirLightSettings(shaderTable.worldShader[3])
	return true
end

function funcTable.setDirLightDirection(dirX,dirY,dirZ,isEuler)
	if isEuler then
		local eul2vecX,eul2vecY,eul2vecZ = getVectorFromEuler(dirX,dirY,dirZ) 
		shaderSettings.dirLight.dir =  {eul2vecX,eul2vecY,eul2vecZ}
	else
		shaderSettings.dirLight.dir =  {dirX,dirY,dirZ}
	end
	funcTable.applyDirLightSettings(shaderTable.worldShader[1])
	--funcTable.applyDirLightSettings(shaderTable.worldShader[2])
	--funcTable.applyDirLightSettings(shaderTable.worldShader[3])
	return true
end

function funcTable.setDiffLightEnable(isTrue)
	shaderSettings.diffLight.enabled = isTrue
	shaderTable.isConfigChanged = true
	funcTable.refreshSettings()
	if isEffectForcedOn then
		if funcTable.forceStop() then 
			return funcTable.forceStart()
		end
	else
		return funcTable.forceStop() or funcTable.forceStart()		
	end
end

function funcTable.setDiffLightColor(colorR,colorG,colorB,colorA)
	shaderSettings.diffLight.col = {colorR,colorG,colorB,colorA}
	funcTable.applyDiffLightSettings(shaderTable.worldShader[1])
	--funcTable.applyDiffLightSettings(shaderTable.worldShader[2])
	--funcTable.applyDiffLightSettings(shaderTable.worldShader[3])
	return true
end

function funcTable.setDiffLightRange(lRange)
	shaderSettings.diffLight.range = lRange
	funcTable.applyDiffLightSettings(shaderTable.worldShader[1])
	--funcTable.applyDiffLightSettings(shaderTable.worldShader[2])
	--funcTable.applyDiffLightSettings(shaderTable.worldShader[3])
	return true
end

function funcTable.setNightSpotEnable(isTrue)
	shaderSettings.nightSpot.enabled = isTrue
	shaderTable.isConfigChanged = true
	funcTable.refreshSettings()
	if isEffectForcedOn then
		if funcTable.forceStop() then 
			return funcTable.forceStart()
		end
	else
		return funcTable.forceStop() or funcTable.forceStart()		
	end
end

function funcTable.setNightSpotPosition(posX,posY,posZ)
	shaderSettings.nightSpot.pos = {posX,posY,posZ}
	funcTable.applyNightSpotSettings(shaderTable.worldShader[1])
	--funcTable.applyNightSpotSettings(shaderTable.worldShader[2])
	--funcTable.applyNightSpotSettings(shaderTable.worldShader[3])
	return true
end

function funcTable.setNightSpotRadius(lRange)
	shaderSettings.nightSpot.radius = lRange
	funcTable.applyNightSpotSettings(shaderTable.worldShader[1])
	--funcTable.applyNightSpotSettings(shaderTable.worldShader[2])
	--funcTable.applyNightSpotSettings(shaderTable.worldShader[3])
	return true
end

---------------------------------------------------------------------------------------------------
-- disable all lights
---------------------------------------------------------------------------------------------------
function funcTable.clearLights()
	for v=0,shaderSettings.gMaxLights,1 do
		local lightEnableStr = 'gLight'..v..'Enable'
		dxSetShaderValue( shaderTable.worldShader[1],lightEnableStr, false )
		--dxSetShaderValue( shaderTable.worldShader[2],lightEnableStr, false )
		--dxSetShaderValue( shaderTable.worldShader[3],lightEnableStr, false )
	end
end

---------------------------------------------------------------------------------------------------
-- apply night mod values
---------------------------------------------------------------------------------------------------
function funcTable.applyNightModValues()
	for shNr=1,1,1 do
		dxSetShaderValue ( shaderTable.worldShader[shNr],"gBrightness", shaderSettings.gBrightness )
		dxSetShaderValue ( shaderTable.worldShader[shNr],"gDayTime", shaderSettings.gDayTime)
	end
end
			
---------------------------------------------------------------------------------------------------
-- creating and sorting a table of active lights
---------------------------------------------------------------------------------------------------
local tickCount = getTickCount()
addEventHandler("onClientPreRender",root, function()
	if (#lightTable.inputLights == 0) then
		return 
	end
	if lightTable.isInNrChanged then 
		lightTable.outputLights = sortedOutput(lightTable.inputLights,true,shaderSettings.gDistFade[1],shaderSettings.gMaxLights)		
		lightTable.isInNrChanged = false
		return
	end
		if lightTable.isInValChanged or ( tickCount + 200 < getTickCount() ) then 
			lightTable.outputLights = sortedOutput(lightTable.inputLights,true,shaderSettings.gDistFade[1],shaderSettings.gMaxLights)
			lightTable.isInValChanged = false
			tickCount = getTickCount()
		end
end
,true ,"low-1")

---------------------------------------------------------------------------------------------------
-- set shader values of active lights
---------------------------------------------------------------------------------------------------
addEventHandler("onClientPreRender", root, function()
	if ((#lightTable.outputLights == 0) and not isEffectForcedOn and not shaderTable.isTimeOut) then
		return
	end 
	if shaderTable.isStarted then 
		funcTable.clearLights()
		if shaderSettings.gNightMod then
			funcTable.applyNightModValues()
		end
	else 
		return 
	end
	lightTable.thisLight = 0
	for index,this in ipairs(lightTable.outputLights) do
		if this.dist <= shaderSettings.gDistFade[1] and this.enabled and lightTable.thisLight < shaderSettings.gMaxLights then
			local isOnScrX, isOnScrY, isOnScrZ = getScreenFromWorldPosition ( this.pos[1], this.pos[2], this.pos[3], edgeTolerance, true )
			if (((isOnScrX and isOnScrY and isOnScrZ) or (this.dist <= shaderSettings.gDistFade[1]*0.15))) then
				local lightEnableStr = 'gLight'..lightTable.thisLight..'Enable'
				local lightTypeStr = 'gLight'..lightTable.thisLight..'Type'
				local lightColorStr = 'gLight'..lightTable.thisLight..'Diffuse'
				local lightAttenuStr = 'gLight'..lightTable.thisLight..'Attenuation'
				local lightSelfShadStr = 'gLight'..lightTable.thisLight..'NormalShadow'				
				local lightPositiStr = 'gLight'..lightTable.thisLight..'Position'
			
				dxSetShaderValue( shaderTable.worldShader[1],lightEnableStr,true )
				dxSetShaderValue( shaderTable.worldShader[1],lightTypeStr,this.lType)			
				dxSetShaderValue( shaderTable.worldShader[1],lightPositiStr,this.pos[1],this.pos[2],this.pos[3])
				dxSetShaderValue( shaderTable.worldShader[1],lightColorStr,this.color[1],this.color[2],this.color[3],this.color[4])
				dxSetShaderValue( shaderTable.worldShader[1],lightAttenuStr,this.attenuation)
				dxSetShaderValue( shaderTable.worldShader[1],lightSelfShadStr,this.normalShadow)
			--[[
				dxSetShaderValue( shaderTable.worldShader[2],lightEnableStr,true )
				dxSetShaderValue( shaderTable.worldShader[2],lightTypeStr,this.lType)				
				dxSetShaderValue( shaderTable.worldShader[2],lightPositiStr,this.pos[1],this.pos[2],this.pos[3])
				dxSetShaderValue( shaderTable.worldShader[2],lightColorStr,this.color[1],this.color[2],this.color[3],this.color[4])
				dxSetShaderValue( shaderTable.worldShader[2],lightAttenuStr,this.attenuation)
			
				dxSetShaderValue( shaderTable.worldShader[3],lightEnableStr,true )
				dxSetShaderValue( shaderTable.worldShader[3],lightTypeStr,this.lType)				
				dxSetShaderValue( shaderTable.worldShader[3],lightPositiStr,this.pos[1],this.pos[2],this.pos[3])
				dxSetShaderValue( shaderTable.worldShader[3],lightColorStr,this.color[1],this.color[2],this.color[3],this.color[4])
				dxSetShaderValue( shaderTable.worldShader[3],lightAttenuStr,this.attenuation)
			]]
				if (this.lType==2) then
					local lightDirectStr = 'gLight'..lightTable.thisLight..'Direction'
					local lightFalloffStr = 'gLight'..lightTable.thisLight..'Falloff'
					local lightThetaStr = 'gLight'..lightTable.thisLight..'Theta'
					local lightPhiStr = 'gLight'..lightTable.thisLight..'Phi'
			
					dxSetShaderValue( shaderTable.worldShader[1],lightDirectStr,this.dir)
					dxSetShaderValue( shaderTable.worldShader[1],lightFalloffStr,this.falloff)
					dxSetShaderValue( shaderTable.worldShader[1],lightThetaStr,this.theta)
					dxSetShaderValue( shaderTable.worldShader[1],lightPhiStr,this.phi)
--[[
					dxSetShaderValue( shaderTable.worldShader[2],lightDirectStr,this.dir)
					dxSetShaderValue( shaderTable.worldShader[2],lightFalloffStr,this.falloff)
					dxSetShaderValue( shaderTable.worldShader[2],lightThetaStr,this.theta)
					dxSetShaderValue( shaderTable.worldShader[2],lightPhiStr,this.phi)

					dxSetShaderValue( shaderTable.worldShader[3],lightDirectStr,this.dir)
					dxSetShaderValue( shaderTable.worldShader[3],lightFalloffStr,this.falloff)
					dxSetShaderValue( shaderTable.worldShader[3],lightThetaStr,this.theta)
					dxSetShaderValue( shaderTable.worldShader[3],lightPhiStr,this.phi)
]]
				end
				lightTable.thisLight = lightTable.thisLight + 1
			end
		end
	end
end
,true ,"low-2")

---------------------------------------------------------------------------------------------------
-- add or remove shader settings 
---------------------------------------------------------------------------------------------------
function funcTable.applyDirLightSettings(theShader)
	if shaderTable.isStarted then 
		dxSetShaderValue( theShader,"gDirLightEnable",shaderSettings.dirLight.enabled )
		dxSetShaderValue( theShader,"gDirLightDiffuse",shaderSettings.dirLight.col )
		dxSetShaderValue( theShader,"gDirLightDirection",shaderSettings.dirLight.dir )
		dxSetShaderValue( theShader,"gDirLightRange",shaderSettings.dirLight.range )
	end
end

function funcTable.applyDiffLightSettings(theShader)
	if shaderTable.isStarted then 
	dxSetShaderValue( theShader,"gDiffLightEnable",shaderSettings.diffLight.enabled )
	dxSetShaderValue( theShader,"gDiffLightDiffuse",shaderSettings.diffLight.col )
	dxSetShaderValue( theShader,"gDiffLightRange",shaderSettings.diffLight.range )
	end
end

function funcTable.applyNightSpotSettings(theShader)
	if shaderTable.isStarted then 
	dxSetShaderValue( theShader,"gNightSpotEnable",shaderSettings.nightSpot.enabled )
	dxSetShaderValue( theShader,"gNightSpotPosition",shaderSettings.nightSpot.pos )
	dxSetShaderValue( theShader,"gNightSpotRadius",shaderSettings.nightSpot.radius )
	end
end


function funcTable.applyShaderSettings(theShader)
	dxSetShaderValue( theShader,"gDistFade",shaderSettings.gDistFade )
	dxSetShaderValue( theShader,"gTextureSize",shaderSettings.gTextureSize )
	dxSetShaderValue( theShader,"gNormalStrength",shaderSettings.gNormalStrength )
	dxSetShaderValue( theShader,"gBrightness", shaderSettings.gBrightness )
	dxSetShaderValue( theShader,"gDayTime", shaderSettings.gDayTime)
	dxSetShaderValue( theShader,"gDirLightEnable",shaderSettings.dirLight.enabled )
	dxSetShaderValue( theShader,"gDirLightDiffuse",shaderSettings.dirLight.col )
	dxSetShaderValue( theShader,"gDirLightDirection",shaderSettings.dirLight.dir )
	dxSetShaderValue( theShader,"gDirLightRange",shaderSettings.dirLight.range )
	dxSetShaderValue( theShader,"gDiffLightEnable",shaderSettings.diffLight.enabled )
	dxSetShaderValue( theShader,"gDiffLightDiffuse",shaderSettings.diffLight.col )
	dxSetShaderValue( theShader,"gDiffLightRange",shaderSettings.diffLight.range )
	dxSetShaderValue( theShader,"gNightSpotEnable",shaderSettings.nightSpot.enabled )
	dxSetShaderValue( theShader,"gNightSpotPosition",shaderSettings.nightSpot.pos )
	dxSetShaderValue( theShader,"gNightSpotradius",shaderSettings.nightSpot.radius )
	engineApplyShaderToWorldTexture ( theShader, "*" )

	-- remove shader from world texture
	for _,removeMatch in ipairs(removeList) do
		engineRemoveShaderFromWorldTexture ( theShader, removeMatch )	
	end	
	-- reapply shader to world texture
	for _,applyMatch in ipairs(reApplyList) do
		engineApplyShaderToWorldTexture ( theShader, applyMatch )	
	end
	-- a hacky way to deal with layered vehicle effects with nightMod
	if shaderSettings.gIsLayered[2]==false and shaderSettings.gNightMod==true then
		engineApplyShaderToWorldTexture ( theShader, "vehiclegeneric256" )
	end
end

function funcTable.removeShaderSettings(theShader)
	engineRemoveShaderFromWorldTexture ( theShader, "*" )
end

function funcTable.refreshGlobalShaderValues()
	if shaderTable.isStarted then
		for shNr=1,1,1 do
			dxSetShaderValue ( shaderTable.worldShader[shNr],"gDistFade",shaderSettings.gDistFade )
			dxSetShaderValue ( shaderTable.worldShader[shNr],"gTextureSize",shaderSettings.gTextureSize )
			dxSetShaderValue ( shaderTable.worldShader[shNr],"gNormalStrength",shaderSettings.gNormalStrength )
			dxSetShaderValue ( shaderTable.worldShader[shNr],"gBrightness", shaderSettings.gBrightness )
			dxSetShaderValue ( shaderTable.worldShader[shNr],"gDayTime", shaderSettings.gDayTime)
		end
		return true
	else
		return false
	end
end

---------------------------------------------------------------------------------------------------
-- create , destroy or refresh shaders 
---------------------------------------------------------------------------------------------------
function funcTable.createWorldLightShader(ligNumber,isLayer,isWrdSobel,isNightMod,isPedDiffuse,isShading,isDirLight,isDiffuse,isNightSpot,isSM3)
	if shaderTable.isStarted then return end
	if shaderTable.isConfigChanged then
		if not createLightShaderFiles(ligNumber,isLayer,isWrdSobel,isNightMod,isPedDiffuse,isShading,isDirLight,isDiffuse,isNightSpot,isSM3) then 
			outputDebugString('Pixel Lighting: Shader files not created!',255,0,0) 
			return 
		end
	end
	shaderTable.isConfigChanged = false
	shaderTable.worldShader[1] = dxCreateShader ( "shaders/dynamic_wrd.fx",1,effectRange,isLayer[1],"world,object")
	--shaderTable.worldShader[2] = dxCreateShader ( "shaders/dynamic_veh.fx",1,effectRange,isLayer[2],"vehicle")
	--shaderTable.worldShader[3] = dxCreateShader ( "shaders/dynamic_ped.fx",1,effectRange,isLayer[3],"ped")
	shaderTable.isStarted = shaderTable.worldShader[1] --and shaderTable.worldShader[2] and shaderTable.worldShader[3]
	if not shaderTable.isStarted then 
		return false 
	else
		funcTable.applyShaderSettings(shaderTable.worldShader[1])
		--funcTable.applyShaderSettings(shaderTable.worldShader[2])
		--funcTable.applyShaderSettings(shaderTable.worldShader[3])
		return true
	end
end

function funcTable.destroyWorldLightShader()
	if shaderTable.isStarted then
		funcTable.removeShaderSettings(shaderTable.worldShader[1])
		--funcTable.removeShaderSettings(shaderTable.worldShader[2])
		--funcTable.removeShaderSettings(shaderTable.worldShader[3])
		destroyElement ( shaderTable.worldShader[1] )
		shaderTable.worldShader[1] = nil
		--destroyElement ( shaderTable.worldShader[2] )
		--shaderTable.worldShader[2] = nil
		--destroyElement ( shaderTable.worldShader[3] )
		--shaderTable.worldShader[3] = nil
		shaderTable.isStarted = false
		return true
	else
		return false
	end
end

function funcTable.refreshSettings()
	if shaderTable.isStarted then
		engineRemoveShaderFromWorldTexture ( shaderTable.worldShader[1], "*" )
		--engineRemoveShaderFromWorldTexture ( shaderTable.worldShader[2], "*" )
		--engineRemoveShaderFromWorldTexture ( shaderTable.worldShader[3], "*" )
		funcTable.applyShaderSettings(shaderTable.worldShader[1])
		--funcTable.applyShaderSettings(shaderTable.worldShader[2])
		--funcTable.applyShaderSettings(shaderTable.worldShader[3])
		return true
	else
		return false
	end
end

---------------------------------------------------------------------------------------------------
-- onClientResourceStart 
---------------------------------------------------------------------------------------------------		
addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	local ver = getVersion ().sortable
	local build = string.sub( ver, 9, 13 )
	if build<"04938" or ver < "1.3.1" then 
		outputDebugString('Pixel Lighting: is not compatible with this client version!',255,0,0)
		return
	end
	shaderTable.smVersion = vCardPSVer()
	if (shaderTable.smVersion~="3") then 
		outputDebugString('Pixel Lighting: shader model 3 not supported',255,0,0)
		shaderSettings.gMaxLights = 1
	end
	shaderTable.isConfigChanged = true
	checkNightMode()
	funcTable.forceStart()
	if not shaderTable.isStarted  then 
		outputDebugString('Pixel Lighting: failed to start shaders!',255,0,0)
		shaderTable.isError = true
		return
	else
		outputDebugString('Pixel Lighting: started',0,255,0)			
	end
	setTimer(checkNightMode, 3000, 0)
end
)

---------------------------------------------------------------------------------------------------
-- create or destroy shaders (depending on the number of synced lights) 
---------------------------------------------------------------------------------------------------
local currentCount = getTickCount ()
addEventHandler("onClientRender", root, function()
	if shaderTable.isError or isEffectForcedOn then 
		return 
	end
	if (#lightTable.outputLights == 0) then
		shaderTable.isTimeOut = true
		if (getTickCount () < (currentCount + effectTimeOut * 1000)) then 
			return 
		end
		shaderTable.isTimeOut = false
		funcTable.forceStop()
	else
		funcTable.forceStart()
		currentCount = getTickCount ()
	end
end		
,true ,"low-3")	


function funcTable.forceStart()
	if not shaderTable.isStarted then
		if (shaderTable.smVersion=="3") then 
			shaderTable.isStarted = funcTable.createWorldLightShader(shaderSettings.gMaxLights-1, shaderSettings.gIsLayered, shaderSettings.gGenerateBumpNormals, shaderSettings.gNightMod, shaderSettings.gPedDiffuse, shaderSettings.gNormalShading,shaderSettings.dirLight.enabled,shaderSettings.diffLight.enabled,shaderSettings.nightSpot.enabled,true)
		elseif (shaderTable.smVersion=="2") then
			shaderTable.isStarted = funcTable.createWorldLightShader(0, shaderSettings.gIsLayered, false, shaderSettings.gNightMod, shaderSettings.gPedDiffuse, shaderSettings.gNormalShading,shaderSettings.dirLight.enabled,shaderSettings.diffLight.enabled,shaderSettings.nightSpot.enabled,false)
		end 
		if shaderTable.isStarted then 
			outputDebugString('Pixel Lighting: started shaders',3,0,255,0 )			
		else
			shaderTable.isError = true
			outputDebugString('Pixel Lighting: failed to start shaders!',3,255,0,0)
		end
	end
	return shaderTable.isStarted
end

function funcTable.forceStop()
	if shaderTable.isStarted then
		shaderTable.isStarted = not funcTable.destroyWorldLightShader()
		outputDebugString('Pixel Lighting: stopped shaders',3,0,255,0 )	
	end
	return not shaderTable.isStarted
end

addEventHandler ( "onClientElementDataChange", localPlayer, function(dataName)
	if dataName == 'graphic_shader_darker_night' or dataName == 'dynamic_lighting' or dataName == 'dynamic_lighting_nighttime_only' then
		checkNightMode()
	end
end)

addEventHandler( 'onClientInteriorChange', root, function()
	checkNightMode()
end )

function checkNightMode()
	local old = shaderSettings.gNightMod
	local int = getElementInterior(localPlayer)
	local dim = getElementDimension(localPlayer)
	if int == 0 and dim == 0 then
		shaderSettings.gNightMod = getElementData( localPlayer, 'loggedin' ) == 1 and getElementData( localPlayer, 'dynamic_lighting' ) ~= '0' and getElementData( localPlayer, 'graphic_shader_darker_night' ) ~= '0' and isInNightTime()
	else
		shaderSettings.gNightMod = false
	end

	shaderSettings.gBrightness = shaderSettings.gNightMod and 0.4 or 1
	isEffectForcedOn = shaderSettings.gNightMod
	if old ~= shaderSettings.gNightMod then
		funcTable.forceStop()
		funcTable.forceStart()
	end
end
