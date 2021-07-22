function sendWeaponSwitchToAll(oldSlot, newSlot)
	if (oldSlot == 2 or newSlot == 2 or oldSlot == 5 or newslot == 5) then
		for key, value in ipairs(getElementsByType("player")) do
			if (value ~= source) then
				--triggerClientEvent(value, "onPlayerWeaponSwitch", source, oldSlot, newSlot)
			end
		end
	end
end
addEvent("sendWeaponSwitchToAll", true)
addEventHandler("sendWeaponSwitchToAll", getRootElement(), sendWeaponSwitchToAll)