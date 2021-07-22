--MAXIME
--[[
function playerPressedKey(button, press) -- "R" to auto walk
    if (press) and button == "r" then -- Only output when they press it down
        if getPedWeaponSlot(localPlayer) == 0 then
			setControlState("walk", true)
			setControlState("forwards", true)
		end
    end
end
addEventHandler("onClientKey", root, playerPressedKey)
]]