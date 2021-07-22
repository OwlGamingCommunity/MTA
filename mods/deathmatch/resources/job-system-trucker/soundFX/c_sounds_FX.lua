function playSoundFX(distance)
	local sound = playSound3D("soundFX/"..tostring(math.random(1,6))..".mp3", getElementPosition( source ))
	setSoundMaxDistance( sound, distance )
	setElementDimension(sound, getElementDimension(source))
	setElementInterior(sound, getElementInterior(source))
end
addEvent("truckerjob:playSoundFX", true)
addEventHandler("truckerjob:playSoundFX", root,playSoundFX)