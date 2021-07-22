--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function playSound3D (soundPath, looped, distance, volume, throttled, excluded_root)
	for i, player in pairs(getNearbyElements(source, 'player', distance)) do
		if player == source and not excluded_root then
			triggerClientEvent(player, 'global:playSound3D', source, soundPath, looped or false, distance or 10, volume or 100, throttled or false)
		elseif player ~= source then
			triggerClientEvent(player, 'global:playSound3D', source, soundPath, looped or false, distance or 10, volume or 100, throttled or false)
		end

	end
end
addEvent('global:playSound3D', true)
addEventHandler('global:playSound3D', root, playSound3D)