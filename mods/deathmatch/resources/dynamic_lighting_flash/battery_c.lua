--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local battery_draining_rate = 10000 -- miliseconds, the greater = the slower battery is drained.
local battery_draining_unit = 1 -- percentage per battery_draining_rate.
local battery_draining_timer

function getBattery( player )
	if not player then player = localPlayer end
	local item = getFlashLightItem( player, item_dbid )
	return item and item[2] or 0
end

function toggleBatteryDrainer( state )
	if battery_draining_timer and isTimer( battery_draining_timer ) then
		killTimer(battery_draining_timer)
		battery_draining_timer = nil
	end

	if state then
		battery_draining_timer = setTimer(function()
			local batt = math.max( 0, getBattery( ) - battery_draining_unit )
			-- latent cuz this isn't important.
			triggerLatentServerEvent( 'flash:battery:drain', resourceRoot, batt, item_dbid )
			if batt == 0 then
				toggleLight( false )
			end
		end, battery_draining_rate, 0)
	end
end

