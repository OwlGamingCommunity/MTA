local shots = 0
local weapons = {
	[22] = "pistol",
	--[23] = "pistol", Disabled cus silenced brah
	[24] = "pistol",
	[25] = "shotgun",
	[26] = "shotgun",
	[27] = "shotgun",
	[28] = "sub-machine gun",
	[29] = "sub-machine gun",
	[32] = "sub-machine gun",
	[30] = "assault rifle",
	[31] = "assault rifle",
	[33] = "rifle",
	[34] = "rifle",
	[35] = "rocket launcher",
}

addEventHandler ( "onClientPlayerWeaponFire", localPlayer,
	function ( weapon )
		if weapons[weapon] then
			-- PAINTBALL
			if getElementData(localPlayer, "paintball") == 2 then
				return
			end
			-- ^^

			if weapon == 24 and getElementData(localPlayer, "deaglemode") == 0 then
				return
			else
				if shots < 1 then
					shots = shots + 1
				elseif shots >= 1 then
					if not isTimer ( shotTimer ) then
						shots = 0
						shotTimer = setTimer ( function ( ) end, 60000, 1 )
						
						triggerServerEvent ( "weaponDistrict:doDistrict", localPlayer, weapons[weapon] )
					end
				end
			end
		end
	end )