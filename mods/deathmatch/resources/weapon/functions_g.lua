--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]


weapon_fire_disabled = {
	[14] = 'Flowers', -- yeah flowers are beautiful. so don't ruin it.
}


weapon_ammoless = {
	[0] = 'Fist',
	[1] = 'Brass Knuckles',
	[2] = 'Golf Club',
	[3] = 'Nightstick',
	[4] = 'Knife',
	[5] = 'Baseball Bat',
	[6] = 'Shovel',
	[7] = 'Pool Cue',
	[8] = 'Katana',
	[9] = 'Chainsaw',
	[43] = 'Camera',
	[10] = 'Long Purple Dildo',
	[11] = 'Short tan Dildo',
	[12] = 'Vibrator',
	[15] = 'Cane',
	[14] = 'Flowers',
	[44] = 'Night-Vision Goggles',
	[45] = 'Infrared Goggles',
	[46] = 'Parachute',
	[16] = 'Grenade',
	[17] = 'Tear Gas',
	[18] = 'Molotov Cocktails',
	[37] = 'Flamethrower',
	[39] = 'Satchel',
	[40] = 'Satchel Remote',
	[41] = 'Spraycan',
	[42] = 'Fire Extinguisher',
}

function isWeapAmmoless(weap_id)
	return weapon_ammoless[weap_id]
end

weapon_infinite_ammo = {
	[37] = 'Flamethrower',
	[43] = 'Camera',
	[46] = 'Parachute',
	[41] = 'Spraycan',
	[42] = 'Fire Extinguisher',
}

function isQueueEmpty(q)
	for i, k in pairs(q) do
		return false
	end
	return true
end

function getAmmoPerClip(id)
	if id == 0 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.fist' ))
	elseif id == 1 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.brassknuckle' ))
	elseif id == 2 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.golfclub' ))
	elseif id == 3 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.nightstick' ))
	elseif id == 4 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.knife' ))
	elseif id == 5 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.bat' ))
	elseif id == 6 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.shovel' ))
	elseif id == 7 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.poolstick' ))
	elseif id == 8 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.katana' ))
	elseif id == 9 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.chainsaw' ))
	elseif id == 10 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.dildo' ))
	elseif id == 11 then
		return tonumber(get( getResourceName( getThisResource( ) ).. 'dildo2' ))
	elseif id == 12 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.vibrator' ))
	elseif id == 13 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.vibrator2' ))
	elseif id == 14 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.flower' ))
	elseif id == 15 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.cane' ))
	elseif id == 16 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.grenade' ))
	elseif id == 17 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.teargas' ))
	elseif id == 18 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.molotov' ))
	elseif id == 22 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.colt45' ))
	elseif id == 23 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.silenced' ))
	elseif id == 24 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.deagle' ))
	elseif id == 25 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.shotgun' ))
	elseif id == 26 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.sawed-off' ))
	elseif id == 27 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.combatshotgun' ))
	elseif id == 28 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.uzi' ))
	elseif id == 29 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.mp5' ))
	elseif id == 30 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.ak-47' ))
	elseif id == 31 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.m4' ))
	elseif id == 32 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.tec-9' ))
	elseif id == 33 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.rifle' ))
	elseif id == 34 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.sniper' ))
	elseif id == 35 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.rocketlauncher' ))
	elseif id == 37 then -- flamethrower
		return tonumber(get( getResourceName( getThisResource( ) ).. '.flamethrower' ))
	elseif id == 39 then -- Satchel
		return tonumber(get( getResourceName( getThisResource( ) ).. '.satchel' ))
	elseif id == 40 then -- Satchel remote (Bomb)
		return tonumber(get( getResourceName( getThisResource( ) ).. '.satcheldetonator' ))
	elseif id == 41 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.spraycan' ))
	elseif id == 42 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.fireextinguisher' ))
	elseif id == 43 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.camera' ))
	elseif id == 44 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.nightvision' ))
	elseif id == 45 then
		return tonumber(get( getResourceName( getThisResource( ) ).. '.infrared' ))
	--elseif id == 46 then -- Parachute
	end
end

function canRetrieve(player, itemId, itemValue)
	local gun = exports.global:explode(':', itemValue)
	local serial = gun[ itemId == 115 and 2 or 3 ]
	local serial_info = serial and exports.global:retrieveWeaponDetails( serial )
	if serial_info and serial_info[2] and tonumber(serial_info[2]) then
		local gun_source = tonumber(serial_info[2])
		local gun_creator = tonumber(serial_info[3])
		-- duty weapon / theorically impossible but still worth to mention
		if gun_source == 2 then
			return false , "This "..(itemId==115 and gun[3] or 'ammopack').." is a duty weapon. You are not allowed to retrieve it."
		elseif gun_source == 3 and gun_creator ~= getElementData(player, 'dbid') and (not exports.integration:isPlayerAdmin(player)) then
			return false, "This "..(itemId==115 and gun[3] or 'ammopack').." is authorized under "..(exports.cache:getCharacterNameFromID(gun_creator) or "someone").."'s firearm license act. You are not allowed to retrieve it."
		end
	end
	return true
end

function isWeaponCCWP(player, itemId, itemValue) 
	local gun = exports.global:explode(':', itemValue)
	local serial = gun[ itemId == 115 and 2 or 3 ]
	local serial_info = serial and exports.global:retrieveWeaponDetails( serial )
	if serial_info and serial_info[2] and tonumber(serial_info[2]) then
		local gun_source = tonumber(serial_info[2])
		if gun_source == 3 then
			return true
		end
	end
	return false
end

-- this function returns differently depends on whether you call it from client or server.
function getPlayerWeaponFromDbid(player, dbid, check_inv)
	-- if called from client then always check inv
	if triggerServerEvent then
		check_inv = true
	end

	if check_inv then
		for inv_slot, itemCheck in ipairs(exports['item-system']:getItems( player ) ) do
			if (itemCheck[1] == 115 or itemCheck[1] == 116) and tonumber(itemCheck[3]) == dbid then
				return itemCheck, inv_slot
			end
		end
	else
		-- search weapons
		if weapons[player] then
			for slot, weap in pairs(weapons[player]) do
				for dbid_, w in pairs(weap) do
					if dbid_ == dbid then
						return w
					end
				end
			end
		end
	end
end

function modifyWeaponValue(itemValue, index, value)
	local values = exports.global:explode(':', itemValue)
	-- check and fill in all the empty fields before it
	for i=1, index do
		if values[i] == nil then
			values[i] = ''
		end
	end
	values[index] = value
	return exports.global:implode(':', values)
end
