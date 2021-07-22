--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

synced_ammo = nil
local ammo_sync_cooldown = 1000
ammo_sync_queue = {}
local has_ammo = true
ammos = {}

function syncAmmo()
	if not isQueueEmpty(ammo_sync_queue) then
		if triggerServerEvent('weapon:syncAmmo', resourceRoot, ammo_sync_queue) then
			synced_ammo = nil
			ammo_sync_queue = {}
		end
	end
end


addEventHandler('onClientRender', root, function()
	if isControlEnabled ( 'fire' ) and not canPlayerShoot() then
		toggleControl('fire', false)
		toggleControl('action', false)
	elseif not isControlEnabled('fire') and canPlayerShoot() and getElementData(localPlayer, "firemode") ~= 1 then
		toggleControl('fire', true)
		toggleControl('action', true)
	end

	-- synce ammo to server
	if synced_ammo and getTickCount() - synced_ammo > ammo_sync_cooldown then
		syncAmmo()
	end
end)

function canPlayerShoot()
	if getElementData(localPlayer, 'restrain') == 1 then
		return false, 'Restrained.'
	end

	if switching then
		return false, 'Switching..'
	end

	if reloading then
		return false, 'Reloading..'
	end

	if weapon_fire_disabled[getPedWeapon(localPlayer)] then
		return false, ''
	end

	if weapon_ammoless[getPedWeapon(localPlayer)] then
		return true
	end

	local ammo = getPedTotalAmmo(localPlayer) - 1
	if ammo <= 0 then
		return false, 'Out of ammo!'
	else
		return true, ammo..' ammo loaded.'
	end
end

function traceBullet(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
	if not (weapon == 39 or weapon == 40) then
		if source == localPlayer and not weapon_infinite_ammo[weapon] and getElementData(localPlayer, "paintball") ~= 2 then
			local slot = getPedWeaponSlot(source)
			local dbid = using_weapon[slot]
			ammo_sync_queue[dbid] = ammo-1
			synced_ammo = getTickCount()
			local can, why = canPlayerShoot()
			if not can then
				if why == 'Out of ammo!' then
					playSound("sounds/no_ammo.mp3")
					triggerServerEvent('global:playSound3D', localPlayer, ':weapon/sounds/no_ammo.mp3', false, 20, 100, false, true)
					outputChatBox(why.." Hit 'R' to reload.", 200,200,200)
				else
					outputChatBox(why, 255,0,0)
				end
			end
		end
	end
end
addEventHandler ( "onClientPlayerWeaponFire", root, traceBullet )

function removeWeapon(weapon)
	ammo_sync_queue[weapon] = 0
	syncAmmo()
end

-- simulate a clicking sound effect when no ammo
addEventHandler('onClientKey', root, function (btn, press)
	if btn == 'mouse1' and press and not isCursorShowing() and getPedWeapon(localPlayer) > 0 and not weapon_ammoless[getPedWeapon(localPlayer)] and not canPlayerShoot() then
		playSound("sounds/no_ammo.mp3")
		triggerServerEvent('global:playSound3D', localPlayer, ':weapon/sounds/no_ammo.mp3', false, 20, 100, false, true)
		if not pressed then
			addEventHandler('onClientRender', root, renderWeaponSelector)
		end
		pressed = getTickCount()
	end
end)

local GUIEditor = {
    button = {},
    window = {}
}

function weaponInteract(item)
	local item_values = exports.global:explode( ":", item[2] )
	local serial_info = exports.global:retrieveWeaponDetails( item_values[2] )
	local gun_source = tonumber(serial_info[2])

	if gun_source == 2 then
		outputChatBox("You can not modify duty weapon.", 255, 0, 0)
		playSoundFrontEnd(4)
	else
		closeWeaponInteract()
        GUIEditor.window[1] = guiCreateWindow(677, 403, 177, 105, item_values[3] or "Unknown Weapon" , false)
        guiWindowSetSizable(GUIEditor.window[1], false)
        exports.global:centerWindow(GUIEditor.window[1])

		GUIEditor.button[1] = guiCreateButton(9, 26, 158, 20, "Unload", false, GUIEditor.window[1])
		guiSetEnabled(GUIEditor.button[1], false)
		local loaded_ammo = tonumber(item_values[4]) or 0

		if not isPedDoingGangDriveby(localPlayer) and loaded_ammo > 0 then
			guiSetEnabled(GUIEditor.button[1], true)
		end

        GUIEditor.button[2] = guiCreateButton(9, 51, 158, 20, "Edit", false, GUIEditor.window[1])
        guiSetEnabled(GUIEditor.button[2], gun_source ~= 2 and (weapon_ammoless[tonumber(item_values[1])]~=nil or exports.integration:isPlayerTrialAdmin(localPlayer, true) or exports.integration:isPlayerSupporter(localPlayer, true) or not item_values[5] or (item_values[5] and item_values[5]~="1") ) )

        GUIEditor.button[3] = guiCreateButton(9, 76, 158, 20, "Close", false, GUIEditor.window[1])

        addEventHandler('onClientGUIClick', GUIEditor.window[1], function()
        	if source == GUIEditor.button[3] then
        		closeWeaponInteract()
        	elseif source == GUIEditor.button[2] then
        		openEditor(item)
        	elseif source == GUIEditor.button[1] then
        		local id = tonumber(item_values[1])
				if isGun(id) and not weapon_ammoless[id] then
					local has_ammo, loaded_ammo, duty = clientWeaponAndAmmoCheck(localPlayer, item[3], id)
					if loaded_ammo and loaded_ammo > 0 then
						if reloading then
							playSoundFrontEnd(4)
							outputChatBox("Please wait...", 255,0,0)
						else
							reloading = true
							syncAmmo()
        					closeWeaponInteract()
        					triggerServerEvent( 'weapon:unload', resourceRoot, item[3], loaded_ammo )
        				end
        			else
        				playSoundFrontEnd(4)
						outputChatBox("Your "..item_values[3].." is empty.", 255,0,0)
        			end
        		else
        			playSoundFrontEnd(4)
					outputChatBox("This weapon doesn't use ammo.", 255,0,0)
        		end
        	end
        end)
		addEventHandler('account:changingchar', root, closeWeaponInteract)
	end
end
addEvent('weapon:interact', false)
addEventHandler('weapon:interact', root, weaponInteract)

function closeWeaponInteract()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
		GUIEditor.window[1] = nil
		removeEventHandler('account:changingchar', root, closeWeaponInteract)
	end
	closeEditor()
end