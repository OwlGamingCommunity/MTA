--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function isGun(id) return getSlotFromWeapon(id) >= 2 and getSlotFromWeapon(id) <= 7 end

function clientWeaponAndAmmoCheck(player, dbid, id)
	local has_ammo, loaded_ammo, duty
	for inv_slot, item in ipairs(exports['item-system']:getItems( player )) do
		if item[1] == 115 and item[3] == dbid then
			local gunDetails = exports.global:explode(':', item[2])
			loaded_ammo = tonumber(gunDetails[4] or 0) or 0
			local serialNumberCheck = exports.global:retrieveWeaponDetails(gunDetails[2])
			duty = tonumber(serialNumberCheck[2]) == 2
		elseif item[1] == 116 and not has_ammo and not duty then
			local gunDetails = exports.global:explode(':', item[2])
			local ammo, ammo_id = getAmmoForWeapon( id )
			if ammo and tonumber(gunDetails[1]) == ammo_id then
				if tonumber(gunDetails[2]) > 0 then
					has_ammo = true
				end
			end
		end

		if has_ammo and loaded_ammo then
			break
		end
	end
	return has_ammo, loaded_ammo, duty
end

function satchelCreation(creator) 
	local projectileType = getProjectileType(source)
	if projectileType == 39 then
		triggerServerEvent("weapon:removeSatchel", creator, creator, projectileType)
	end
end 
addEventHandler("onClientProjectileCreation", getRootElement(), satchelCreation)