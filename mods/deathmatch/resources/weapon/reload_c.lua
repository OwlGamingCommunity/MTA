--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

reloading = false

function doReload()
	local id = getPedWeapon(localPlayer)
	if isGun(id) and not weapon_ammoless[id] then
		local slot = getPedWeaponSlot(localPlayer)
		local dbid = using_weapon[slot]
		local has_ammo, loaded_ammo, duty = clientWeaponAndAmmoCheck(localPlayer, dbid, id)
		if has_ammo or duty then
			if reloading then
				playSoundFrontEnd(4)
				outputChatBox("Please wait..", 255,0,0)
			else
				local total_ammo = getPedTotalAmmo( localPlayer, slot ) - 1
				local one_pack = getWeaponProperty( id , "std", "maximum_clip_ammo")
				if duty then
					-- ammo hasn't synced with server.
					local ammo_in_clip = getPedAmmoInClip(localPlayer)
					if loaded_ammo ~= total_ammo then
						playSoundFrontEnd(4)
						outputChatBox("Please wait..", 255,0,0)
					elseif total_ammo > one_pack then
						local ammo_in_clip = getPedAmmoInClip(localPlayer)
						if one_pack ~= 0 and ammo_in_clip < one_pack then
							reloading = true
							syncAmmo()
							triggerServerEvent('weapon:reload', resourceRoot, dbid, duty)
							toggleAllControls(false)
							toggleControl('backwards', true)
							toggleControl('forwards', true)
							toggleControl('left', true)
							toggleControl('right', true)
						end
					else
						playSoundFrontEnd(4)
						outputChatBox("Your duty weapon is out of ammo!", 255,0,0)
					end
				else
					-- ammo hasn't synced with server.
					if loaded_ammo ~= total_ammo then
						playSoundFrontEnd(4)
						outputChatBox("Please wait..", 255,0,0)
					elseif one_pack ~= 0 and total_ammo < one_pack then
						reloading = true
						syncAmmo()
						triggerServerEvent('weapon:reload', resourceRoot, dbid)
						toggleAllControls(false)
						toggleControl('backwards', true)
						toggleControl('forwards', true)
						toggleControl('left', true)
						toggleControl('right', true)
					end
				end
			end
		else
			playSoundFrontEnd(4)
			outputChatBox("You don't have any extra ammopack for this weapon.", 255,0,0)
		end
	end
end

local reload_timer
function callbackReload()
	if reload_timer and isTimer(reload_timer) then killTimer(reload_timer) end
	reload_timer = setTimer(function()
		toggleAllControls(true)
		reloading = false
	end, 4100, 1)
end
addEvent('weapon:reload:callback', true)
addEventHandler('weapon:reload:callback', resourceRoot, callbackReload)

function bindKeys()
	bindKey("r", "down", doReload)
end
addEventHandler("onClientResourceStart", resourceRoot, bindKeys)

addEventHandler('onClientResourceStop', resourceRoot, function ()
	if reloading then
		toggleAllControls(true)
	end
	guiSetInputEnabled(false)
end)


