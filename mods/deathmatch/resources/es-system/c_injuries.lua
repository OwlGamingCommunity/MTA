function stopHeadshots( attacker, weapon, bodypart )
	if localPlayer == source and weapon == 37 and not attacker then -- Some fire
		local faction = getCurrentFactionDuty(source)
		if faction == 2 then
			cancelEvent()
		end
	end

	local veh = getPedOccupiedVehicle(localPlayer)
	if veh and isVehicleDamageProof(veh) then 
		cancelEvent()
	end

	if bodypart == 9 then
		if weapon == 24 then
			local deagleMode = getElementData(attacker, "deaglemode")
			if deagleMode == 0 then -- Tazer cancel headshot
				cancelEvent()
			end
		end

		local skinID = getElementModel(source)
		if skinID == 285 or skinID == 287 then -- army and swat skins, RPly with helmet
			setElementHealth(source, math.max(0, getElementHealth(source) - 10))
			cancelEvent()
		end
	end
end
addEventHandler("onClientPlayerDamage", getLocalPlayer(), stopHeadshots)
