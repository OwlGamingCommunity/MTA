function extinguisherInfinite(weapon, ammo)
	if weapon == 42 and ammo == 4500 then
		triggerServerEvent("fdextinguisher:supply", resourceRoot)
	end
end
addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer(), extinguisherInfinite )
