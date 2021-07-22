local count = 0
local noteTimer = nil
local weapons = {
	[22] = "9mm",
	[23] = "9mm",
	[24] = ".45",
	[25] = "12 Gauge",
	[26] = "12 Gauge",
	[27] = "12 Gauge",
	[28] = "9mm",
	[29] = "9mm",
	[30] = "7.62mm",
	[31] = "5.56mm",
	[32] = "9mm",
	[33] = "7.62mm",
	[34] = "7.62mm", 
}

addEventHandler("onClientPlayerWeaponFire", localPlayer, function (weapon)
    count = count + 1

    if isTimer(noteTimer) then
        killTimer(noteTimer)
    end

    noteTimer = setTimer(createCasings, 1000, 1, weapon)
end)

function createCasings(weapon)
	if (weapon == 24 and getElementData(localPlayer, "deaglemode") == 0 or getElementData(localPlayer, "deaglemode") == 2 ) then return end
	if (weapon == 25 and getElementData(localPlayer, "shotgunmode")	== 0) then return end
	if getElementData(localPlayer, "paintball") and getElementData(localPlayer, "paintball") == 2 then return end
	if not weapons[weapon] then return end
	local x, y, z = calculatePosition(localPlayer)
	triggerServerEvent("item-system:dropGunNote", root, weapon, weapons[weapon], x, y, z, count > 1, count)
	count = 0
	noteTimer = nil
end

function calculatePosition(thePlayer)
	if (isElement(thePlayer)) then
		local matrix = getElementMatrix(thePlayer)
		local oldX = 0
		local oldY = 1
		local oldZ = 0
		local x = oldX * matrix[1][1] + oldY * matrix [2][1] + oldZ * matrix [3][1] + matrix [4][1]
		local y = oldX * matrix[1][2] + oldY * matrix [2][2] + oldZ * matrix [3][2] + matrix [4][2]
		local z = oldX * matrix[1][3] + oldY * matrix [2][3] + oldZ * matrix [3][3] + matrix [4][3]

		local z = getGroundPosition( x, y, z + 2 )
		return x, y, z
	else
		return false
	end
end
