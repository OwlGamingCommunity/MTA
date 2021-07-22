--
-- c_exported_functions.lua
--

function createPointLight(posX,posY,posZ,colorR,colorG,colorB,colorA,attenuation,...)
	local reqParam = {posX,posY,posZ,colorR,colorG,colorB,colorA,attenuation}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param~=nil and (type(param) == "number")
	end
	local optParam = {...}
	if not isThisValid or (#optParam > 3 or #reqParam ~= 8 ) or (countParam ~= 8) then 
		return false 
	end
	if (type(optParam[1]) ~= "boolean") then
		optParam[1] = true
	end
	if (type(optParam[2]) ~= "number") then
		optParam[2] = -1
	end
	if (type(optParam[3]) ~= "number") then
		optParam[3] = -1
	end
	local normalShadow =  optParam[1]
	local lightDimension = optParam[2]
	local lightInterior = optParam[3]
	local lightElementID = funcTable.create(1,posX,posY,posZ,colorR*colorA,colorG*colorA,colorB*colorA,colorA,dirX,dirY,dirZ,false,0,0,0,attenuation,normalShadow
		,lightDimension,lightInterior)
	local lightElement = createElement("LightSource", tostring(lightElementID))
	return lightElement
end

function createSpotLight(posX,posY,posZ,colorR,colorG,colorB,colorA,dirX,dirY,dirZ,isEuler,falloff,theta,phi,attenuation,...)
	local reqParam = {posX,posY,posZ,colorR,colorG,colorB,colorA,dirX,dirY,dirZ,falloff,theta,phi,attenuation}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param~=nil and (type(param) == "number")
	end
	local optParam = {...}
	if not isThisValid or (#optParam > 3 or #reqParam ~= 14 ) or (countParam ~= 14) then
		return false 
	end
	if (type(optParam[1]) ~= "boolean") then
		optParam[1] = true
	end
	if (type(optParam[2]) ~= "number") then
		optParam[2] = -1
	end
	if (type(optParam[3]) ~= "number") then
		optParam[3] = -1
	end
	local normalShadow =  optParam[1]
	local lightDimension = optParam[2]
	local lightInterior = optParam[3]
	local lightElementID = funcTable.create(2,posX,posY,posZ,colorR*colorA,colorG*colorA,colorB*colorA,colorA,dirX,dirY,dirZ,isEuler,falloff,theta,phi,attenuation,normalShadow
			,lightDimension,lightInterior)
	local lightElement = createElement("LightSource", tostring(lightElementID))
	return lightElement
end

function destroyLight(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if type(lightElementID) == "number" then
		return destroyElement(w) and funcTable.destroy(lightElementID)
	else
		return false
	end
end

function setLightDimension(w,dimension)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(dimension) == "number") then 
		lightTable.inputLights[lightElementID].dimension = dimension
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightDimension(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return lightTable.inputLights[lightElementID].dimension
		else
			return false
		end
	else
		return false
	end
end

function setLightInterior(w,interior)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(interior) == "number") then 
		lightTable.inputLights[lightElementID].interior = interior
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightInterior(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return lightTable.inputLights[lightElementID].interior
		else
			return false
		end
	else
		return false
	end
end

function setLightDirection(w,dirX,dirY,dirZ,...)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	local reqParam = {lightElementID,dirX,dirY,dirZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if lightTable.inputLights[lightElementID] and isThisValid then
		local optParam = {...}
		if (lightTable.inputLights[lightElementID].lType == 2) and (#optParam <= 1) and (countParam == 4) then
			if optParam[1]==true then 
				local eul2vecX,eul2vecY,eul2vecZ = getVectorFromEulerXZ(dirX,dirY,dirZ) 
				lightTable.inputLights[lightElementID].dir = {eul2vecX,eul2vecY,eul2vecZ}
			else
				lightTable.inputLights[lightElementID].dir = {dirX,dirY,dirZ}
			end
			lightTable.isInValChanged = true
			return true
		else
			return false
		end
	else
		return false
	end
end

function getLightDirection(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].lType == 2) and (lightTable.inputLights[lightElementID].enabled == true) then
			return unpack(lightTable.inputLights[lightElementID].dir)
		else
			return false
		end
	else
		return false
	end
end

function setLightPosition(w,posX,posY,posZ)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	local reqParam = {lightElementID,posX,posY,posZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if lightTable.inputLights[lightElementID] and isThisValid  and (countParam == 4) then
		lightTable.inputLights[lightElementID].pos = {posX,posY,posZ}
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightPosition(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return unpack(lightTable.inputLights[lightElementID].pos)
		else
			return false
		end
	else
		return false
	end
end

function setLightColor(w,colorR,colorG,colorB,colorA)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	local reqParam = {lightElementID,colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if lightTable.inputLights[lightElementID] and isThisValid  and (countParam == 5)  then
		lightTable.inputLights[lightElementID].color = {colorR*colorA,colorG*colorA,colorB*colorA,colorA}
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightColor(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return unpack(lightTable.inputLights[lightElementID].color)
		else
			return false
		end
	else
		return false
	end
end

function setLightAttenuation(w,attenuation)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(attenuation) == "number") then 
		lightTable.inputLights[lightElementID].attenuation = attenuation
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightAttenuation(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return lightTable.inputLights[lightElementID].attenuation
		else
			return false
		end
	else
		return false
	end
end

function setLightNormalShading(w,normalShadow)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(normalShadow) == "boolean") then
		lightTable.inputLights[lightElementID].normalShadow = normalShadow
		lightTable.isInValChanged = true
		return true
	else
		return false
	end
end

function getLightNormalShading(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) then
			return lightTable.inputLights[lightElementID].normalShadow
		else
			return false
		end
	else
		return false
	end
end

function setLightFalloff(w,falloff)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and type(falloff) == "number" then	
		if (lightTable.inputLights[lightElementID].lType == 2) then	
			lightTable.inputLights[lightElementID].falloff = falloff
			lightTable.isInValChanged = true
			return true
		else
			return false
		end
	else
		return false
	end
end

function getLightFalloff(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) and (lightTable.inputLights[lightElementID].lType == 2) then
			return lightTable.inputLights[lightElementID].falloff
		else
			return false
		end
	else
		return false
	end
end

function setLightTheta(w,theta)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(theta) == "number") then 
		if (lightTable.inputLights[lightElementID].lType == 2) then 
			lightTable.inputLights[lightElementID].theta = theta
			lightTable.isInValChanged = true
			return true
		else
			return false
		end
	else
		return false
	end
end

function getLightTheta(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) and (lightTable.inputLights[lightElementID].lType == 2) then
			return lightTable.inputLights[lightElementID].theta
		else
			return false
		end
	else
		return false
	end
end

function setLightPhi(w,phi)
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] and (type(phi) == "number") then 
		if (lightTable.inputLights[lightElementID].lType == 2) then 
			lightTable.inputLights[lightElementID].phi = phi
			lightTable.isInValChanged = true
			return true
		else
			return false
		end
	else
		return false
	end
end	

function getLightPhi(w)
	if not isElement(w) then 
		return false
	end
	local lightElementID = tonumber(getElementID(w))
	if lightTable.inputLights[lightElementID] then
		if (lightTable.inputLights[lightElementID].enabled == true) and (lightTable.inputLights[lightElementID].lType == 2) then
			return lightTable.inputLights[lightElementID].phi
		else
			return false
		end
	else
		return false
	end
end

function setMaxLights(maxLights)
	if (type(maxLights) == "number") then
		if ( maxLights >= 0 and maxLights <= 15 ) then
			return funcTable.setMaxLights(maxLights)
		else
			return false
		end
	else
		return false
	end
end

function setVertexLights(maxLights)
	if (type(maxLights) == "number") then
		if ( maxLights >= 0 and maxLights <= 15 ) then
			return funcTable.setVertexLights(maxLights)
		else
			return false
		end
	else
		return false
	end
end

function setWorldNormalShading(isTrue)
	if (type(isTrue) == "boolean") then
		return funcTable.setWorldNormalShading(isTrue)
	else
		return false
	end
end

function setNormalShading(isWrd,isVeh,isPed)
	if (type(isWrd) == "boolean") and (type(isVeh) == "boolean") and (type(isPed) == "boolean") then
		return funcTable.setNormalShading(isWrd,isVeh,isPed)
	else
		return false
	end
end

function setForceVertexLights(isWrd,isVeh,isPed)
	if (type(isWrd) == "boolean") and (type(isVeh) == "boolean") and (type(isPed) == "boolean") then
		return funcTable.setForceVertexLights(isWrd,isVeh,isPed)
	else
		return false
	end
end

function setShadersLayered(isWrd,isVeh,isPed)
	if (type(isWrd) == "boolean") and (type(isVeh) == "boolean") and (type(isPed) == "boolean") then
		funcTable.setShadersLayered(isWrd,isVeh,isPed)
		return true
	else
		return false
	end
end

function setGenerateBumpNormals(isGenerated,...)
	if (type(isGenerated) == "boolean") then
		local optParam = {...}
		if (#optParam > 4) then
			return false 
		end		
		local isThisValid = true
		if (#optParam > 0) then
			for m, param in ipairs(optParam) do
				isThisValid = isThisValid and param and (type(param) == "number")
			end
		end
		if not isThisValid then
			return false
		end
		texSize = optParam[1] or 512
		stX = optParam[2] or 1
		stY = optParam[3] or 1
		stZ = optParam[4] or 1
		return funcTable.generateBumpNormals(isGenerated,texSize,stX,stY,stZ)
	else
		return false
	end
end

function setTextureBrightness(value)
	if (type(value) == "number") then
		return funcTable.setTextureBrightness(value)
	else
		return false
	end
end

function setLightsDistFade(dist1,dist2)
	if (type(dist1) == "number") and (type(dist2) == "number") then
		return funcTable.setDistFade(dist1,dist2)
	else
		return false
	end
end

function setLightsEffectRange(value)
	if type(value) == "number" then
		return funcTable.setEffectRange(value)
	else
		return false
	end
end

function setShaderForcedOn(value)
	if (type(value) == "boolean") then
		return funcTable.setShadersForcedOn(value)
	else
		return false
	end
end

function setShaderTimeOut(value)
	if (type(value) == "number") then
		return funcTable.setShadersTimeOut(value)
	else
		return false
	end
end

function setShaderNightMod(nMod)
	if (type(nMod) == "boolean") then
		return funcTable.setShaderNightMod(nMod)
	else
		return false
	end
end	

function setShaderPedDiffuse(nDif)
	if (type(nDif) == "boolean") then
		return funcTable.setShaderPedDiffuse(nDif)
	else
		return false
	end
end	

function setShaderDayTime(nMod)
	if (type(nMod) == "number") then
		return funcTable.setShaderDayTime(nMod)
	else
		return false
	end
end

function setDirLightEnable(isEnabled)
	if (type(isEnabled) == "boolean") then
		return funcTable.setDirLightEnable(isEnabled)
	else
		return false
	end
end

function setDirLightColor(colorR,colorG,colorB,colorA)
	local reqParam = {colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid  and (countParam == 4)  then
		funcTable.setDirLightColor(colorR*colorA,colorG*colorA,colorB*colorA,colorA)		
		return true
	else
		return false
	end
end

function setDirLightDirection(dirX,dirY,dirZ,...)
	local reqParam = {dirX,dirY,dirZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid then
		local optParam = {...}
		if (#optParam <= 1) and (countParam == 3) then
			if optParam[1]==true then 
				local eul2vecX,eul2vecY,eul2vecZ = getVectorFromEulerXZ(dirX,dirY,dirZ) 
				funcTable.setDirLightDirection(eul2vecX,eul2vecY,eul2vecZ,true)
			else
				funcTable.setDirLightDirection(dirX,dirY,dirZ,false)
			end
			return true
		else
			return false
		end
	else
		return false
	end
end

function setDirLightRange(lRange)
	if (type(lRange) == "number") then
		if (lRange>0) then
			return funcTable.setDirLightRange(lRange)
		else
			return false
		end
	else
		return false
	end
end

function setDiffLightEnable(isEnabled)
	if (type(isEnabled) == "boolean") then
		return funcTable.setDiffLightEnable(isEnabled)
	else
		return false
	end
end

function setDiffLightColor(colorR,colorG,colorB,colorA)
	local reqParam = {colorR,colorG,colorB,colorA}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid  and (countParam == 4)  then
		funcTable.setDiffLightColor(colorR*colorA,colorG*colorA,colorB*colorA,colorA)		
		return true
	else
		return false
	end
end

function setDiffLightRange(lRange)
	if (type(lRange) == "number") then
		if (lRange>0) then
			return funcTable.setDiffLightRange(lRange)
		else
			return false
		end
	else
		return false
	end
end

function setNightSpotEnable(isEnabled)
	if (type(isEnabled) == "boolean") then
		return funcTable.setNightSpotEnable(isEnabled)
	else
		return false
	end
end

function setNightSpotRadius(lRange)
	if (type(lRange) == "number") then
		if (lRange>0) then
			return funcTable.setNightSpotRadius(lRange)
		else
			return false
		end
	else
		return false
	end
end

function setNightSpotPosition(posX,posY,posZ)
	local reqParam = {posX,posY,posZ}
	local isThisValid = true
	local countParam = 0
	for m, param in ipairs(reqParam) do
		countParam = countParam + 1
		isThisValid = isThisValid and param and (type(param) == "number")
	end
	if isThisValid  and (countParam == 3)  then
		funcTable.setNightSpotPosition(posX,posY,posZ)		
		return true
	else
		return false
	end
end

function isInNightTime()
	if getElementData(localPlayer, "dynamic_lighting") ~= "0" then
		local hour, minutes = getTime()
   		return hour>=21 or hour<6
   	else
   		return true
   	end
end
