--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function reload(dbid, duty)
	triggerEvent('global:playSound3D', client, ':weapon/sounds/reload_1.mp3', false, 20, 100, false, false)
	if not (isPedDucked(client)) and not isPedInVehicle(client) then
		exports.global:applyAnimation(client, "BUDDY", "buddy_reload", 4000, true, true, true)
	end

	refreshWeaponsAndAmmoTables(client)

	local weap = getPlayerWeaponFromDbid(client, dbid)
	if weap then
		weap.loaded_ammo = weap.loaded_ammo or 0
		local id = weap.id
		local slot = weap.slot
		if duty then
			if weapons[client][slot][dbid].duty then
				local total_ammo = getPedTotalAmmo( client, getPedWeaponSlot(client) ) - 1
				local one_pack = getWeaponProperty( id , "std", "maximum_clip_ammo")
				local ammo_in_clip = getPedAmmoInClip(client)
				local ammo_lost = one_pack - ammo_in_clip
				setWeaponAmmo ( client , id , total_ammo+1, one_pack )
				executeCommandHandler ( 'ame', client, "reloads "..(getElementData(client, 'gender') == 0 and "his" or "her").." "..weap.name..".")
			end
		else
			local ammo_, ammo_id = getAmmoForWeapon( id )
			local ammopack = ammo_ and ammopacks[client][ammo_id]
			if ammopack and ammopack.ammo > 0 then
				local remain = 0
				local ammo = weap.loaded_ammo + ammopack.ammo
				if ammo > getAmmoPerClip(id) then
					remain = ammo-getAmmoPerClip(id)
					ammo = getAmmoPerClip(id)
				end

				weapons[client][slot][dbid].loaded_ammo = ammo
				local newValue = modifyWeaponValue( weapons[client][slot][dbid].itemValue, 4, ammo )
				exports['item-system']:updateItemValue(client, weap.inv_slot, newValue )
				
				if remain > 0 then
					newValue = modifyWeaponValue( ammopack.itemValue, 2, remain )
					exports['item-system']:updateItemValue(client, ammopack.inv_slot, newValue )
				else
					exports['item-system']:takeItemFromSlot(client, ammopack.inv_slot, false, true)
				end
				setWeaponAmmo(client, id, 0)
				giveWeapon(client, id, ammo+1, false)
				outputDebugString("[WEAPON] Server / reload / giveWeapon: "..getPlayerName(client).." ("..dbid..") "..weap.name..", bullets="..ammo)
				executeCommandHandler ( 'ame', client, "reloads "..(getElementData(client, 'gender') == 0 and "his" or "her").." "..weap.name..".")
			end
		end
	end
	setTimer(triggerEvent, 1500, 1, 'global:playSound3D', client, ':weapon/sounds/reload_2.mp3', false, 20, 100, false, false)
	setTimer(triggerEvent, 4000, 1, 'global:playSound3D', client, ':weapon/sounds/reload_3.mp3', false, 20, 100, false, false)
	triggerClientEvent(client, 'weapon:reload:callback', resourceRoot)
end
addEvent('weapon:reload', true)
addEventHandler('weapon:reload', resourceRoot, reload)

function unload(dbid, client_ammo)
	refreshWeaponsAndAmmoTables(client)
	local weap = getPlayerWeaponFromDbid(client, dbid)
	if weap then
		weap.loaded_ammo = weap.loaded_ammo or 0
		if weap.loaded_ammo > 0 and weap.loaded_ammo == client_ammo then
			-- set loaded ammo to 0
			local slot = weap.slot
			local ammo_had = weapons[client][slot][dbid].loaded_ammo
			weapons[client][slot][dbid].loaded_ammo = 0
			local newValue = modifyWeaponValue( weap.itemValue, 4, 0 )
			exports['item-system']:updateItemValue( client, weap.inv_slot, newValue )
			-- give player an ammopack
			local ammo_, ammo_id = getAmmoForWeapon( weap.id )
			exports.global:giveItem(client, 116, ammo_id..':'..ammo_had)
			-- some anim, sound and visual effects
			triggerEvent('global:playSound3D', client, ':weapon/sounds/reload_1.mp3', false, 20, 100, false, false)
			executeCommandHandler ( 'ame', client, "unloads "..(getElementData(client, 'gender') == 0 and "his" or "her").." "..weap.name..".")
			if not (isPedDucked(client)) and not isPedInVehicle(client) then
				exports.global:applyAnimation(client, "BUDDY", "buddy_reload", 4000, true, true, true)
			end
			triggerClientEvent(client, 'weapon:reload:callback', resourceRoot)
			return
		end
	end
	outputChatBox( "Errors occurred while unloading weapon.", client, 255, 0, 0 )
	triggerClientEvent(client, 'weapon:reload:callback', resourceRoot)
end
addEvent('weapon:unload', true)
addEventHandler('weapon:unload', resourceRoot, unload)