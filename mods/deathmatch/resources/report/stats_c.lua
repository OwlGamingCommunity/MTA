--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local sync_interval = 5 -- 5 minutes.
local online = 0
local duty = 0

addEventHandler( 'onClientResourceStop', resourceRoot, function()
	exports.data:save( online, 'online' )
	exports.data:save( duty, 'duty' )
end )

addEventHandler( 'onClientResourceStart', resourceRoot, function( startedRes )
	-- load stats in case resource was restarted.
	online = exports.data:load( 'online' ) or online
	duty = exports.data:load( 'duty' ) or duty

	-- count online time, and duty time in minutes.
	setTimer ( function()
		if exports.integration:isPlayerSupporter( localPlayer ) or exports.integration:isPlayerTrialAdmin( localPlayer ) or exports.integration:isPlayerTester( localPlayer ) or exports.integration:isPlayerVCTMember( localPlayer ) then
			if getElementData( localPlayer, 'loggedin' ) == 1 then
				online = online + 1
				if exports.integration:isPlayerSupporter( localPlayer, true ) or exports.integration:isPlayerTrialAdmin( localPlayer, true ) then
					duty = duty + 1
				end
			end
			-- sync stats to server.
			if online >= sync_interval or duty >= sync_interval then
				syncStats()
			end
		end
	end , 60000, 0 )
end )

function syncStats()
	if online > 0 or duty > 0 then
		triggerLatentServerEvent( 'report:syncStats', resourceRoot, online, duty ) -- latent because it's no urgent.
		online = 0
		duty = 0
	end
end

