--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function isHolding(player)
	return flashLiTable.isFLen[ player ]	
end

function isDynamicLightingEnabled()
	return getElementData(localPlayer, 'dynamic_lighting') ~= '0' and exports.dynamic_lighting:isInNightTime()
end

function removeFlFromPlayer(player)
	destroyWorldLight(player)
	destroyFlashLightShader(player) 
	destroyFlashlightModel(player)
end

function createWorldLight(thisPed)
	if flashLiTable.shLight[thisPed] or ( isSynced==false and thisPed ~= localPlayer )  then 
		return 
	end
	flashLiTable.shLight[thisPed] = exports.dynamic_lighting:createSpotLight(0,0,3,gLightColor[1],gLightColor[2],gLightColor[3],gLightColor[4],0,0,0,flase,gLightFalloff,gLightTheta,gLightPhi,gAttenuation,gWorldSelfShadow)
end

function destroyWorldLight(thisPed)
	if flashLiTable.shLight[thisPed] then
		flashLiTable.shLight[thisPed] = not exports.dynamic_lighting:destroyLight(flashLiTable.shLight[thisPed])
	end
end

function createFlashLightShader(thisPed)
	if flashLiTable.flModel[thisPed] and not flashLiTable.shLiBul[thisPed] and not flashLiTable.shLiRay[thisPed] then
		flashLiTable.shLiBul[thisPed]=dxCreateShader("shaders/shader_lightBulb.fx",1,0,false)
		flashLiTable.shLiRay[thisPed]=dxCreateShader("shaders/shader_lightRays.fx",1,0,true)
		if not flashLiTable.shLiBul[thisPed] or not flashLiTable.shLiRay[thisPed] then
			return
		end		
		engineApplyShaderToWorldTexture ( flashLiTable.shLiBul[thisPed],"flashlight_L", flashLiTable.flModel[thisPed] )
		engineApplyShaderToWorldTexture ( flashLiTable.shLiRay[thisPed], "flashlight_R", flashLiTable.flModel[thisPed] )	
		dxSetShaderValue (flashLiTable.shLiBul[thisPed],"gLightColor",gLightColor)
		dxSetShaderValue (flashLiTable.shLiRay[thisPed],"gLightColor",gLightColor)
	end
end

function destroyFlashLightShader(thisPed)
	if flashLiTable.shLiBul[thisPed] or flashLiTable.shLiRay[thisPed] then
		destroyElement(flashLiTable.shLiBul[thisPed])
		destroyElement(flashLiTable.shLiRay[thisPed])
		flashLiTable.shLiBul[thisPed]=nil
		flashLiTable.shLiRay[thisPed]=nil
	end
end

function playSwitchSound(thisPed)
	pos_x,pos_y,pos_z=getElementPosition (thisPed)
	local flSound = playSound3D("sounds/switch.wav", pos_x, pos_y, pos_z, false) 
	setSoundMaxDistance(flSound,40)
	setSoundVolume(flSound,0.6)
	setElementInterior( flSound, getElementInterior(thisPed) )
	setElementDimension( flSound, getElementDimension(thisPed) )
end