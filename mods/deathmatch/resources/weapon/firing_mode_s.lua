--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function updateFireMode(mode)
	if ( tonumber(mode) and (tonumber(mode) >= 0 and tonumber(mode) <= 1) ) then
		exports.anticheat:setEld(client, "firemode", mode, 'one')
		triggerEvent('global:playSound3D', client, ':weapon/sounds/firingmode.mp3', false, 20, 100, false, false)
		if not (isPedDucked(client)) and not isPedInVehicle(client) then
			exports.global:applyAnimation(client, "BUDDY", "buddy_reload", 1000, false, true, true)
		end
		executeCommandHandler ( 'ame', client, "switches the firing mode to "..(mode == 0 and 'full-auto' or 'semi-auto')..".")
	end
end
addEvent("firemode", true)
addEventHandler("firemode", getRootElement(), updateFireMode)