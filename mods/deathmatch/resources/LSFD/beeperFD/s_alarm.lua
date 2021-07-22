local x1, y1, z1 = 1721.361328125, -1120.359375, 24.085935592651
local FDID = 2

function triggerTheAlarm(thePlayer)
	if not exports.factions:isPlayerInFaction(thePlayer, FDID) then
		return false
	end

	--[[
	local x, y, z = getElementPosition(thePlayer)
	local distance = getDistanceBetweenPoints3D(x1, y1, z1, x, y, z)
	if (distance > 5) then
		return false
	end
	--]]

	--Play alarm at FD
	local dist = 100 --distance for FD alarm
	local colshape = createColSphere(x1, y1, z1, dist)
	triggerClientEvent(getElementsWithinColShape(colshape, "player"), "playAlarmAroundTheArea", thePlayer, x1, y1, z1, dist)
	destroyElement(colshape)

	--Notify FD members with a beeper
	local beepers = {}
	local sendSoundTo = {} -- {playerToPlaySoundFor, playerWhosBeeperIsBeeping}
	for k, v in ipairs(exports.factions:getPlayersInFaction(FDID)) do
		if exports.global:hasItem(v, 217) then
			outputChatBox("[BEEPER] " .. exports.global:getPlayerName(thePlayer) .. " has triggered the LSFD alarm.", v, 245, 40, 135)
			triggerEvent('sendAme', v, "'s beeper beeps.")
			table.insert(beepers, v)
		end
	end
	for k, v in ipairs(beepers) do
		local beeperX, beeperY, beeperZ = getElementPosition(v)
		local beeperInt = getElementInterior(v)
		local beeperDim = getElementDimension(v)
		local colshape = createColSphere(beeperX, beeperY, beeperZ, 5)
		setElementInterior(colshape, beeperInt)
		setElementDimension(colshape, beeperDim)
		for k2, v2 in ipairs(getElementsWithinColShape(colshape, "player")) do
			local thisInt = getElementInterior(v2)
			local thisDim = getElementDimension(v2)
			if thisInt == beeperInt and thisDim == beeperDim then
				table.insert(sendSoundTo, {v2, v})
			end
		end
		destroyElement(colshape)	
	end
	for k, v in ipairs(sendSoundTo) do
		triggerClientEvent(v[1], "playPagerSfxAround", v[2])
	end
end
addCommandHandler("alarm", triggerTheAlarm)
