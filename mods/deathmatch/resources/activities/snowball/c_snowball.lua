function throwThatSnow()
	local x, y, z = getPositionInfrontOfElement(localPlayer)
	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	local hit, px, py, pz, hitElement = processLineOfSight(playerX, playerY, playerZ, x, y, z)
	local doAme = false
	if not hit then
		z = getGroundPosition(x, y, z)
	else
		x, y, z = px, py, pz
		if hitElement then
			if getElementType(hitElement) == "player" then
				doAme = hitElement
			end
		end		
	end
	triggerServerEvent("xmas:snow:throw", resourceRoot, localPlayer, x, y, z, doAme, hit)
end
addEvent("xmas:snow:shoot", true)
addEventHandler("xmas:snow:shoot", resourceRoot, throwThatSnow)

function getPositionInfrontOfElement(element, meters) 
    if not element or not isElement(element) then 
        return false 
    end 
    if not meters then 
        meters = 10
    end 
    local posX, posY, posZ = getElementPosition(element) 
    local _, _, rotation = getElementRotation(element) 
    posX = posX - math.sin(math.rad(rotation)) * meters 
    posY = posY + math.cos(math.rad(rotation)) * meters 
    return posX, posY, posZ 
end

function makeBallSplash(x, y, z)
	local effect = createEffect("water_splash", x, y, z)
	setTimer(function()
		destroyElement(effect)
	end, 500, 1)
end
addEvent("xmas:snow:effect", true)
addEventHandler("xmas:snow:effect", resourceRoot, makeBallSplash)

function playSnowballSound3d(x, y, z)
	playSound3D("snowball/snowballhit.wav", x, y, z)
end
addEvent("xmas:snow:sound3d", true)
addEventHandler("xmas:snow:sound3d", resourceRoot, playSnowballSound3d)

function playSnowballSound()
	local sound = playSound("snowball/snowballhit.wav")
	setSoundVolume(sound, 1)

	fadeCamera(false, 1, 255, 255, 255)
	setTimer(function()
		fadeCamera(true)
	end, 200, 1)
end
addEvent("xmas:snow:sound", true)
addEventHandler("xmas:snow:sound", resourceRoot, playSnowballSound)