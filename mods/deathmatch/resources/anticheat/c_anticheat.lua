--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local localPlayer = getLocalPlayer()
local timer = false
local kills = 0
function checkDM(killer)
	if (killer==localPlayer) then
		kills = kills + 1
		
		if (kills>=3) then
			triggerServerEvent("alertAdminsOfDM", localPlayer, kills)
		end
		
		if not (timer) then
			timer = true
			setTimer(resetDMCD, 120000, 1)
		end
	end
end
addEventHandler("onClientPlayerWasted", getRootElement(), checkDM)

function resetDMCD()
	kills = 0
	timer = false
end

--[[
0: Grenade
1: Molotov
2: Rocket
3: Rocket Weak
4: Car
5: Car Quick
6: Boat
7: Heli
8: Mine
9: Object
10: Tank Grenade
11: Small
12: Tiny
]]

-- If the explosion doesn't come from a verified source, it must be illegal.
function cancelExplosion(x, y, z, theType)
	if getElementType(source) == "player" and source == localPlayer then
		if theType == 0 and getElementData(source, "ac:projectile:16") then -- Grenade
			setElementData(source, "ac:projectile:16", false)
		elseif theType == 0 and getElementData(source, "ac:projectile:39") then -- Satchel
			setElementData(source, "ac:projectile:39", false)
		elseif theType == 1 and getElementData(source, "ac:projectile:18") then -- Molotov
			setElementData(source, "ac:projectile:18", false)
		elseif (theType == 2 or theType == 3) and getElementData(source, "ac:launcher") then
			setElementData(source, "ac:launcher", (getElementData(source, "ac:launcher") == 1 and false) or getElementData(source, "ac:launcher") - 1)
		else
			cancelEvent()
		end
	end
end
addEventHandler("onClientExplosion", getRootElement(), cancelExplosion)

-- Detect when a projectile is thrown, and save it in element data.
function projectileCreation(creator) 
	local projectileType = getProjectileType(source)
	if projectileType == 16 or projectileType == 18 or projectileType == 19 or projectileType == 20 or projectileType == 39 then
		setElementData(creator, "ac:projectile:" .. projectileType, true)
	end
end 
addEventHandler("onClientProjectileCreation", getRootElement(), projectileCreation) 

-- Detect when a player fires a rocket launcher.
function fireExplosive(weapon)
	if weapon == 35 or weapon == 36 then
		if getElementData(source, "ac:launcher") then
			setElementData(source, "ac:launcher", getElementData(source, "ac:launcher") + 1)
		else
			setElementData(source, "ac:launcher", 1)
		end
	end
end
addEventHandler("onClientPlayerWeaponFire", getRootElement(), fireExplosive)