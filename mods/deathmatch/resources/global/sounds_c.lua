--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function playSoundError()
	playSoundFrontEnd(4)
end

function playSoundSuccess()
	playSoundFrontEnd(13)
end

function playSoundCreate()
	playSoundFrontEnd(6)
end

function playSoundAlert()
	playSound("sounds/invite.ogg")
end

function playSound3D_ (soundPath, looped, distance, volume, throttled)
	local x, y, z = getElementPosition(source)
	local sound = playSound3D ( soundPath, x, y, z, looped , throttled )
	setSoundMaxDistance(sound, distance)
	getSoundVolume(sound, volume)
	setElementInterior(sound, getElementInterior(source))
	setElementDimension(sound, getElementDimension(source))
end
addEvent('global:playSound3D', true)
addEventHandler('global:playSound3D', root, playSound3D_)

