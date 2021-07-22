--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Original author: Ren712
* ***********************************************************************************************************************
]]

local shotLiTable = {} 
local projTable = {}

local gWorldNormalShadow = false 
local gGunLightAttenuation = 4 
local gExplLightAttenuation = 14
local gRockLightAttenuation = 12
local lightMaxDistance = 70

local rocketColor = {1,0.8,0.8,1}
local explosionColor = {1,0.5,0,1}
local weaponShotColor = {0.7,0.7,0,1}
----------------------------------------------------------------------------------------------------------------------------
-- light handling
----------------------------------------------------------------------------------------------------------------------------
addEventHandler("onClientPreRender", root, function()
	if shotLiTable.shLiNumber > 0 then
		for index,this in ipairs(getElementsByType("player")) do
			if shotLiTable[this].enabled then
				local x1,y1,z1 = getPedBonePosition(this, 25)
				if isElement(shotLiTable[this].element) then
					exports.dynamic_lighting:setLightPosition(shotLiTable[this].element,x1,y1,z1)
				end
			end
		end
	end
end
)

function createWorldLight(lightAttenuation)
	local isTrue = exports.dynamic_lighting:createPointLight(0,0,3,0,0,0,0,lightAttenuation,gWorldNormalShadow)
	if isTrue then shotLiTable.shLiNumber = shotLiTable.shLiNumber + 1 end
	return isTrue
end

function destroyWorldLight(this)
	local isTrue = exports.dynamic_lighting:destroyLight(this)
	if isTrue then shotLiTable.shLiNumber = shotLiTable.shLiNumber - 1 end
	return isTrue
end

----------------------------------------------------------------------------------------------------------------------------
-- weapon fire
----------------------------------------------------------------------------------------------------------------------------
function createShotFlash(this,posX,posY,posZ)
	local camX,camY,camZ = getCameraMatrix()
	local camDist = getDistanceBetweenPoints3D ( posX,posY,posZ,camX,camY,camZ )
	local ispastDist = lightMaxDistance < camDist
	local col = weaponShotColor
	if shotLiTable[this].enabled and not shotLiTable[source].flash then
		exports.dynamic_lighting:setLightColor(shotLiTable[this].element,col[1],col[2],col[3],1) 
		countTillSpotFade( this, 60 )
		shotLiTable[source].flash = true
		return
	end
	if shotLiTable[this].enabled~=true then
		if not ispastDist then
			shotLiTable[this].element = createWorldLight(gGunLightAttenuation)
			exports.dynamic_lighting:setLightColor(shotLiTable[this].element,col[1],col[2],col[3],1) 
			shotLiTable[this].enabled = true
			countTillSpotDestroy( this, 60*40 )
			countTillSpotFade( this, 60 )
		end
	end
end

function countTillSpotDestroy( source, timeout )
	setTimer ( function ()
		destroyWorldLight(shotLiTable[source].element)
		shotLiTable[source].enabled = false
	end, timeout, 1 )
	return true
end

function countTillSpotFade( source, timeout )
	setTimer ( function ()
		exports.dynamic_lighting:setLightColor(shotLiTable[source].element,0,0,0,1)
		shotLiTable[source].flash = false
	end, timeout, 1 )
	return true
end

addEventHandler("onClientPlayerWeaponFire", root, function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement, posX, posY, posZ)
    if ((weapon >= 22) and (weapon <=32)) then
		if not shotLiTable[source] then
			shotLiTable[source] = {}
			shotLiTable[source].enabled = false
			shotLiTable[source].flash = false
			shotLiTable[source].element = false
		end
        createShotFlash(source,posX,posY,posZ)
    end
end
)

----------------------------------------------------------------------------------------------------------------------------
-- explosions
----------------------------------------------------------------------------------------------------------------------------
createFlashProjectile = {}
function createFlashProjectile.grenade(elID,posX,posY,posZ)
	local camX,camY,camZ = getCameraMatrix()
	local camDist = getDistanceBetweenPoints3D ( posX, posY, posZ, camX, camY, camZ )
	local ispastDist = lightMaxDistance < camDist
	if not ispastDist then
		if not projTable[elID] then projTable[elID] = {} end
		projTable[elID].element = createWorldLight(gExplLightAttenuation)
		exports.dynamic_lighting:setLightColor(projTable[elID].element,0,0,0,1)
		exports.dynamic_lighting:setLightPosition(projTable[elID].element, posX, posY, posZ)		
		createGrenadeFlash( elID, posX, posY, posZ)
	end
end

function createGrenadeFlash( elID, posX, posY, posZ )
		local getLastTick = getTickCount ( )
		projTable[elID].timer = setTimer ( function()
			local col = explosionColor
			local preVal = math.min(((getTickCount ( ) - getLastTick)/900),1)
			local easinVal = getEasingValue(preVal,"SineCurve")		
			exports.dynamic_lighting:setLightColor(projTable[elID].element, col[1], col[2], col[3], easinVal)
			if preVal == 1 then 
				destroyWorldLight(projTable[elID].element)
				projTable[elID].enabled = nil
				if isTimer(projTable[elID].timer) then killTimer(projTable[elID].timer) end
				return true
			end
		end, 70, 13 )
	return true
end

addEventHandler( "onClientExplosion", getRootElement(), function(posX, posY, posZ, theType)
	if getElementType( source ) == "player" then
		local elID = findEmptyEntry(projTable)
		projTable[elID] = {}
		projTable[elID].enabled = true
		projTable[elID].timer = false
		projTable[elID].element = false
		projTable[elID].object = source
		createFlashProjectile.grenade(elID, posX, posY, posZ)
	end
end 
)

----------------------------------------------------------------------------------------------------------------------------
-- rocket
----------------------------------------------------------------------------------------------------------------------------
function createFlashProjectile.rocket(elID)
	local camX,camY,camZ = getCameraMatrix()
	local posX, posY, posZ = getElementPosition(projTable[elID].object)
	local camDist = getDistanceBetweenPoints3D ( posX, posY, posZ, camX, camY, camZ )
	local ispastDist = lightMaxDistance < camDist
	if not ispastDist then
		if not projTable[elID] then projTable[elID] = {} end
		projTable[elID].element = createWorldLight(gRockLightAttenuation)
		exports.dynamic_lighting:setLightColor(projTable[elID].element,0,0,0,1)
		exports.dynamic_lighting:setLightPosition(projTable[elID].element, posX, posY, posZ)		
		createRocketFlash( elID, posX, posY, posZ)
	end
end

function createRocketFlash( elID, posX, posY, posZ )
	local getLastTick = getTickCount ( )
		projTable[elID].timer = setTimer ( function()
			if not isElement(projTable[elID].object) then 
				destroyWorldLight(projTable[elID].element)
				projTable[elID].enabled = nil
				if isTimer(projTable[elID].timer) then killTimer(projTable[elID].timer) end
				return true
			else
				local col = rocketColor
				posX, posY, posZ = getElementPosition(projTable[elID].object)
				local easinVal = math.max(math.random(),0.4)
				exports.dynamic_lighting:setLightColor(projTable[elID].element, col[1], col[2], col[3], easinVal)
				exports.dynamic_lighting:setLightPosition(projTable[elID].element, posX, posY, posZ)
			end
		end, 70, 0 )	
	return true
end

addEventHandler( "onClientProjectileCreation", getRootElement(),function( creator )
	local zeType = getProjectileType( source )
	if zeType == 19 and getElementType( creator ) == "player" then
		local elID = findEmptyEntry(projTable)
		projTable[elID] = {}
		projTable[elID].enabled = true
		projTable[elID].timer = false
		projTable[elID].element = false
		projTable[elID].object = source
		createFlashProjectile.rocket(elID)
	end
end
)

----------------------------------------------------------------------------------------------------------------------------
-- shadred
----------------------------------------------------------------------------------------------------------------------------
function findEmptyEntry(inTable)
	for index,value in ipairs(inTable) do
		if not value.enabled then
			return index
		end
	end
	return #inTable + 1
end

----------------------------------------------------------------------------------------------------------------------------
-- onClient resource events (shot flash)
----------------------------------------------------------------------------------------------------------------------------
addEventHandler("onClientResourceStart", getResourceRootElement( getThisResource()), function()
	shotLiTable.shLiNumber = 0
	for index,this in ipairs(getElementsByType("player")) do
		if not shotLiTable[this] then
			shotLiTable[this] = {}
			shotLiTable[this].enabled = false
			shotLiTable[this].flash = false
			shotLiTable[this].element = false
		end	
	end
end
)

addEventHandler("onClientResourceStop", getResourceRootElement( getThisResource()), function()
	for index,this in ipairs(getElementsByType("player")) do
		if shotLiTable[this].enabled then
			if isElement(shotLiTable[this].element) then
				shotLiTable[this].enabled = not destroyLight(shotLiTable[this].element)
			end
		end
	end	
end
)

----------------------------------------------------------------------------------------------------------------------------
-- Player join/quit 
----------------------------------------------------------------------------------------------------------------------------
addEventHandler("onClientPlayerJoin", getRootElement(), function()
	if not shotLiTable[source] then
		shotLiTable[source] = {}
		shotLiTable[source].enabled = false
		shotLiTable[source].flash = false
		shotLiTable[source].element = false
	end	
end
)

addEventHandler("onClientPlayerQuit", getRootElement(), function()
	if shotLiTable[source] then
		if isElement(shotLiTable[source].element) then
			exports.dynamic_lighting:destroyLight(shotLiTable[this].element)
			shotLiTable[source].element = nil
		end
		shotLiTable[source].enabled = nil
		shotLiTable[source].flash = nil
		shotLiTable[source] = nil
	end	
end
)

