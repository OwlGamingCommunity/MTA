function playAlarmAroundTheArea(x, y, z, dist)
	local fdAlarm = playSound3D("beeperFD/alarm.mp3", x, y, z, true)
	setSoundMaxDistance(fdAlarm, dist)
	setSoundMinDistance(fdAlarm, dist/2)
	--reps: (7*4sec)-1sec
	setTimer(function()
			stopSound(fdAlarm)
		end, 27000, 1)
end
addEvent("playAlarmAroundTheArea", true)
addEventHandler("playAlarmAroundTheArea", localPlayer, playAlarmAroundTheArea)

function playPagerSfxAround()
	local x, y, z = getElementPosition(source)
	local int, dim = getElementInterior(source), getElementDimension(source)
	local pagerSound = playSound3D("beeperFD/pager.mp3", x, y, z)
	setSoundVolume(pagerSound, 0.8)
	setElementInterior(pagerSound, int)
	setElementDimension(pagerSound, dim)
end
addEvent("playPagerSfxAround", true)
addEventHandler("playPagerSfxAround", localPlayer, playPagerSfxAround)