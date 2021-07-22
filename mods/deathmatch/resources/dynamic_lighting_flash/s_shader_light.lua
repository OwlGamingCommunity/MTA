--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Original author: Ren712
* ***********************************************************************************************************************
]]

local isFlon = {}
local isFlen = {}

function remotePlayerJoin()
	isFlon[source]=false
	isFlen[source]=false
	for _,playa in ipairs(getElementsByType("player")) do		
		triggerClientEvent (source,"flashlight:enable",root,isFlen[playa],playa)
		triggerClientEvent (source,"flashOnPlayerSwitch",root,isFlon[playa],playa)
	end		
end
addEvent("onPlayerStartRes",true)
addEventHandler("onPlayerStartRes", root, remotePlayerJoin)

function remotePlayerQuit()
	isFlon[source]=false
	isFlen[source]=false
	triggerClientEvent ("flashOnPlayerQuit",root,source)
end
addEventHandler("onPlayerQuit", root, remotePlayerQuit)

function remoteSwitch(isON)
	isFlon[source]=isON 
	triggerClientEvent ("flashOnPlayerSwitch",root,isFlon[source],source)
	if isON then
		exports.realism:setForceWalkStyle( source, 57 )
	else
		exports.realism:unsetForceWalkStyle( source )
	end
end
addEvent("onSwitchLight",true)
addEventHandler("onSwitchLight", root, remoteSwitch)

function remoteEnable(isEN, nearbyPlayers)
	isFlen[source]=isEN 
	for i, p in pairs( nearbyPlayers ) do
		if p and isElement(p) then
			triggerClientEvent (p, "flashlight:enable", resourceRoot, isEN, source)
		end
	end
end
addEvent("flashlight:enable",true)
addEventHandler("flashlight:enable", root, remoteEnable)
 
function getPlayerInterior()
	local interior = getElementInterior(source)
	triggerClientEvent ("flashOnPlayerInter",root,source,interior)
end 
addEvent("onPlayerGetInter",true)
addEventHandler("onPlayerGetInter", root, getPlayerInterior)