--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function getFlashLightItem( player, dbid )
	if not player then player = localPlayer end
	for slot, item in pairs( exports['item-system']:getItems( player ) ) do
		if item[3] == dbid then
			item[2] = tonumber(item[2]) or 0
			return item, slot
		end
	end
end