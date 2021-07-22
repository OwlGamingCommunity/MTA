--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local viewDistance = 50
local lookTimer = { }
local scrWidth, scrHeight = guiGetScreenSize()
local sx = scrWidth/2
local sy = scrHeight/2

local nearby_npcs = { }
local nearby_vehs = { }
local nearby_players = { }

function getLocalCoord()

end

local rendering = false
function onClientLookAtRender()
	rendering = true
	if not isPedOnFire(localPlayer) then
		local x, y, z = getWorldFromScreenPosition(sx, sy, viewDistance)
		setPedLookAt(localPlayer, x, y, z, 10000, 2000)
		-- sync local head to near by players
		if exports.global:countTable(nearby_players) > 0 then
			triggerServerEvent( 'realism:lookat:sync', localPlayer, nearby_players, { x, y, z } )
		end
	end
end

function lookAtClosestElement()
	local element = getClosestPlayer()
	if not element then
		element = getClosestPeds()
	end
	if not element then
		element = getClosestVehicle()
	end
	if element then
		setPedLookAt (localPlayer, 0, 0, 0, 3500, 1000, element)
	end
end

function getClosestPlayer()
	for dbid, player in pairs( nearby_players ) do
		local x,y,z = getElementPosition(player)			
		local cx,cy,cz = getCameraMatrix()
		local distance = getDistanceBetweenPoints3D(cx,cy,cz,x,y,z)
		if distance <= viewDistance and (player~=localPlayer) then --Within radius viewDistance
			local px,py,pz = getScreenFromWorldPosition(x,y,z,0.05)
			if px and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false) then	
				return player
			end
		end
	end
end

function getClosestPeds()
	for dbid, player in pairs( nearby_npcs ) do
		local x,y,z = getElementPosition(player)			
		local cx,cy,cz = getCameraMatrix()
		local distance = getDistanceBetweenPoints3D(cx,cy,cz,x,y,z)
		if distance <= viewDistance and (player~=localPlayer) then --Within radius viewDistance
			local px,py,pz = getScreenFromWorldPosition(x,y,z,0.05)
			if px and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false) then	
				return player
			end
		end
	end
end

function getClosestVehicle()
	for dbid, player in pairs( nearby_vehs ) do
		local x,y,z = getElementPosition(player)			
		local cx,cy,cz = getCameraMatrix()
		local distance = getDistanceBetweenPoints3D(cx,cy,cz,x,y,z)
		if distance <= viewDistance and (player~=localPlayer) then --Within radius viewDistance
			local px,py,pz = getScreenFromWorldPosition(x,y,z,0.05)
			if px and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false) then	
				return player
			end
		end
	end
end

addEventHandler('onClientElementStreamIn', root, function ()
	if getElementType(source) == 'ped' then
		nearby_npcs[ getElementData(source, 'dbid') ] = source
	elseif getElementType(source) == 'player' then
		nearby_players[ getElementData(source, 'dbid') ] = source
	elseif getElementType(source) == 'vehicle' then
		nearby_vehs[ getElementData(source, 'dbid') ] = source
	end
end)
addEventHandler('onClientElementStreamOut', root, function ()
	if getElementType(source) == 'ped' then
		nearby_npcs[ getElementData(source, 'dbid') ] = nil
	elseif getElementType(source) == 'player' then
		nearby_players[ getElementData(source, 'dbid') ] = nil
	elseif getElementType(source) == 'vehicle' then
		nearby_vehs[ getElementData(source, 'dbid') ] = nil
	end
end)

function npcLookAtYou()
	for dbid, npc in pairs(nearby_npcs) do
		if npc and isElement(npc) and isElementOnScreen(npc) then
			setPedLookAt ( npc, 0, 0, 0, 5000, 1000, localPlayer )
			--outputDebugString(exports.global:getPlayerName(npc)..' looks at '..exports.global:getPlayerName(localPlayer))
		end
	end
end

function updateLookAt()
	-- reset stuff
	setPedLookAt (localPlayer, 0, 0, 0, 0 )
	if lookTimer[1] and isTimer(lookTimer[1]) then
		killTimer(lookTimer[1])
		lookTimer[1] = nil
	end
	if lookTimer[2] and isTimer(lookTimer[2]) then
		killTimer(lookTimer[2])
		lookTimer[2] = nil
	end
	-- set stuff
	local state = tonumber(getElementData(localPlayer, "head_turning") or 0) or 0
	if state == 1 then
		lookTimer[1] = setTimer(lookAtClosestElement, 3000, 0)
	elseif state == 2 then
		lookTimer[2] = setTimer(onClientLookAtRender, 2000, 0)
	end
end
addEvent("realism:updateLookAt", false)
addEventHandler( "realism:updateLookAt", root, updateLookAt )

addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()),
    function ( startedRes )
		updateLookAt()
		setTimer(npcLookAtYou, 3000, 0)
    end
)
