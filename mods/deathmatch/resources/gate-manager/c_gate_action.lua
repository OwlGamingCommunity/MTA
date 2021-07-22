--Maxime
localPlayer = getLocalPlayer()
local activeSounds = {}
local debugGateDistance = false

function clickOnGate(button, state, absX, absY, wx, wy, wz, element)
	if (element) and (getElementType(element)=="object") and (button=="left") and (state=="down") then
		local isGate = getElementData(element, "gate")
		if isGate then
			if (canPlayerReachGate(element, localPlayer, debugGateDistance)) then
				triggerServerEvent("gate:trigger", element)
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickOnGate, true)

function openTheGate(commandName, password)
	for _, theGate in ipairs(getElementsByType("object")) do
		--outputChatBox("loop")
		local isGate = getElementData(theGate, "gate")
		if isGate then
			if (canPlayerReachGate(theGate, localPlayer)) then
				triggerServerEvent("gate:trigger", theGate, password)
			end
		end
	end
end
addCommandHandler("gate", openTheGate)


function canPlayerReachGate(theGate, thePlayer, printDistance)
	if thePlayer and isElement(thePlayer)  and theGate and isElement(theGate) then
		if getElementDimension(thePlayer) ~= getElementDimension(theGate) or getElementInterior(thePlayer) ~= getElementInterior(theGate) then
			return false
		end

		local distance =  getGateTriggerDistance(theGate, thePlayer)
		if distance > 0 then
			local x, y, z = getElementPosition(thePlayer)
			local wx, wy, wz = getElementPosition(theGate)
			if printDistance then
				outputChatBox("realDistance="..tostring(math.ceil(getDistanceBetweenPoints3D(x, y, z, wx, wy, wz))).." triggerDistance="..tostring(distance))
			end
			--outputDebugString("realDistance="..tostring(getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)).." triggerDistance="..tostring(distance))
			if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz) <= distance) then
				return true
			end
		else
			--outputDebugString("triggerDistance is 0")
		end
	end
	return false
end

function getGateTriggerDistance(theGate, thePlayer)
	local isGate = getElementData(theGate, "gate")
	if isGate == true then
		if thePlayer and isElement(thePlayer) and isPedInVehicle(thePlayer) then
			local customTriggerDistance = getElementData(theGate, "gate:triggerDistanceVehicle")
			if customTriggerDistance then
				customTriggerDistance = tonumber(customTriggerDistance) or 20
				return customTriggerDistance
			end
			return 20
		else
			local customTriggerDistance = getElementData(theGate, "gate:triggerDistance")
			if customTriggerDistance then
				customTriggerDistance = tonumber(customTriggerDistance) or 5
				return customTriggerDistance
			end
			return 5
		end
	end
	return 0
end

function playGateSound(theGate, state, location, soundname)
	if activeSounds[theGate] then
		destroyElement(activeSounds[theGate])
		activeSounds[theGate] = false
	end
	if soundname == "metalgate" then
		local sound = playSound3D("sound/"..(state and "gate_open.mp3" or "gate_close.mp3"), location[1], location[2], location[3])
		if sound then
			setSoundMaxDistance( sound, 50 )
			setSoundVolume(sound, 0.7)
			setElementInterior(sound, location[4])
			setElementDimension(sound, location[5])
		end
	elseif soundname == "alarmbell" then
		local sound = playSound3D("sound/alarmbell.wav", location[1], location[2], location[3], true)
		if sound then
			setSoundMinDistance(sound, 30)
			setSoundMaxDistance(sound, 100)
			setElementInterior(sound, location[4])
			setElementDimension(sound, location[5])
			activeSounds[theGate] = sound
		end
	end
end
addEvent("playGateSound", true)
addEventHandler("playGateSound", resourceRoot, playGateSound)

function stopGateSound(theGate)
	if activeSounds[theGate] then
		destroyElement(activeSounds[theGate])
		activeSounds[theGate] = false
	end
end
addEvent("stopGateSound", true)
addEventHandler("stopGateSound", resourceRoot, stopGateSound)

function godebug(cmd)
	if debugGateDistance then
		outputChatBox("Hiding gate distance.")
	else
		outputChatBox("Click a gate to get the distance.")
	end
	debugGateDistance = not debugGateDistance
end
addCommandHandler("showgatedistance", godebug)
