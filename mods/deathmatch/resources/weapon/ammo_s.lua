--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function givePlayerAmmo(giver, taker, weap_id, ammo_id, rounds )
	if giver and taker and weap_id and not weapon_ammoless[weap_id] then
		local ammo = ammo_id and ammunition[ammo_id] or getAmmoForWeapon( weap_id )
		if ammo then
			ammo.rounds = tonumber(rounds) or ammo.rounds
			local serial = exports.global:createWeaponSerial( 1, getElementData(giver, 'dbid'), getElementData(taker, 'dbid') )
			local given, why = exports.global:giveItem(taker, 116, ammo.id..':'..ammo.rounds..':'..serial)
			if given then
				return given, ammo, serial
			else
				return given, ammo, why
			end
		else
			return false, nil, "Could not find any suitable ammunition for this weapon."
		end
	end
end