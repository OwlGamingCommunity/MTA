function cameraEffect()
	fadeCamera(false, 0.5, 255, 255, 255)
	setTimer(fadeCamera, 300, 0.5, true)
end
addEvent("speedcam:cameraEffect", true)
addEventHandler("speedcam:cameraEffect", getRootElement(), cameraEffect)

function beep()
	local sound = playSound("beep-24.mp3") --Play the beep
	setSoundVolume(sound, 0.7) -- set the sound volume to 70%
end
addEvent("beep", true)
addEventHandler("beep", getRootElement(), beep)