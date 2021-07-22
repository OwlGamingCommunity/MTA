

--[[local marker1 = createMarker(1545.55859375, -1659.109375, 4.890625, "cylinder", 5, 255, 194, 14, 150)
exports.pool:allocateElement(marker1)
local marker2 = createMarker(1545.580078125, -1663.462890625, 4.890625, "cylinder", 5, 255, 181, 165, 213)
exports.pool:allocateElement(marker2)]]

-- Nice little guard ped
guard1 = createPed(280, 1544.1591796875, -1632, 13.3828125)
exports.pool:allocateElement(guard1)
setElementFrozen(guard1, true)
setPedRotation(guard1, 90)
setTimer(giveWeapon, 50, 1, guard1, 29, 15000, true)
-- Guard ped @ CPU
--[[guard2 = createPed(280, 616.2255859375, -1510.9697265625, 14.950366020203)
exports.pool:allocateElement(guard2)
setElementFrozen(guard2, true)
setPedRotation(guard2, -90)
setTimer(giveWeapon, 50, 1, guard2, 29, 15000, true)]]

function killMeByPed(element)
	killPed(client, element, 29, 9)
	setPedHeadless(client, true)
end
addEvent("killmebyped", true)
addEventHandler("killmebyped", getRootElement(), killMeByPed)