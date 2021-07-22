--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function modifyWeapon(dbid, values)
	local weap, inv_slot = getPlayerWeaponFromDbid(client, dbid, true)
	local finale = nil
	if weap then
		local finale = nil
		for i, v in pairs(values) do
			finale = modifyWeaponValue((finale or weap[2]), i, v)
		end
		if finale then
			exports['item-system']:updateItemValue(client, inv_slot, finale )
			updateLocalGuns(client)
		end
	end
end
addEvent("weapon:modify", true)
addEventHandler("weapon:modify", resourceRoot, modifyWeapon)
