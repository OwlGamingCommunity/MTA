local syncedElements = { }
local weaponmodels = { [1]=331, [2]=333, [3]=326, [4]=335, [5]=336, [6]=337, [7]=338, [8]=339, [9]=341, [15]=326, [22]=346, [23]=347, [24]=348, [25]=349, [26]=350, [27]=351, [28]=352, [29]=353, [32]=372, [30]=355, [31]=356, [33]=357, [34]=358, [35]=359, [36]=360, [37]=361, [38]=362, [16]=342, [17]=343, [18]=344, [39]=363, [41]=365, [42]=366, [43]=367, [10]=321, [11]=322, [12]=323, [14]=325, [44]=368, [45]=369, [46]=371, [40]=364, [100]=373 }


function isBackboneAllowed(weaponID)
	if (weaponID == 24 or weaponID == 25 or weaponID == 27 or weaponID == 30 or weaponID == 31 or weaponID == 33 or weaponID == 34) then
		return true
	end
	return false
end


function updateBackbone()
	local thePlayer = source

	syncedElements[thePlayer] = { } 
	triggerClientEvent("realism:backbone.removeBackboneItem", source, source)
	
	local currentWeapon = getPedWeapon(thePlayer)
	for i=0, 12 do
		local weapon = getPedWeapon(thePlayer, i)
		if (weapon and weapon ~= currentWeapon) then
			local ammo = getPedTotalAmmo(thePlayer, i)
			if ammo > 0 then
				if isBackboneAllowed(weapon) then
					outputDebugString("ohai")
					triggerClientEvent("realism:backbone.addBackboneItem", source, source, weaponmodels[weapon])
					table.insert(syncedElements[thePlayer], weapon)
				end
			end
		end
	end
end
addEventHandler("onPlayerWeaponSwitch", getRootElement(), updateBackbone )
addEventHandler("onCharacterLogin", getRootElement(), updateBackbone)
addEventHandler("onPedWeaponSwitch", getRootElement(), updateBackbone)

addEvent("realism:backbone.request", true)
function requestBackBone()
	local players = exports.pool:getPoolElementsByType("player")
	for k, thePlayer in ipairs(players) do
		if (syncedElements[thePlayer]) then
			for _, weapon in ipairs(syncedElements[thePlayer]) do
				triggerClientEvent(client, "realism:backbone.addBackboneItem", thePlayer, thePlayer, weaponmodels[weapon])
			end
		end
	end
end
addEventHandler("realism:backbone.request", getRootElement(), requestBackBone)
