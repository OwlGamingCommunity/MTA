local isBallInHand = false
local balls = { }

function gBall(ballid)
	balls [ ballid ] = source
    setElementCollisionsEnabled(source, false)
end
addEvent("basketball:announceball" , true )
addEventHandler("basketball:announceball",getRootElement(),gBall)

function onResourceStart(resource)
	if (resource == getThisResource()) then
		if #balls == 0 then
			triggerServerEvent("basketball:announceball", source)
		end
	end
end
addEventHandler("onClientResourceStart", getRootElement(), onResourceStart)


function updateBallStatus(ballElement, isBallInHand, doDropball)
	if (isBallInHand) then
		local boX, boY, boZ = getPedBonePosition(source, 26)
		local boZ = boZ - 0.1
		setElementPosition(ballElement, boX, boY, boZ)
		
		if source == getLocalPlayer() then
			isBallInHand = true
		end
	else
		if doDropball then
			local pX,pY,pZ = getElementPosition(source)
			local pZ = pZ - 0.9
			setElementPosition(ballElement, pX, pY, pZ)
		end		
		
		if source == getLocalPlayer() then
			isBallInHand = false
		end
	end
end
addEvent("basketball:cstatus",true)
addEventHandler("basketball:cstatus",getRootElement(),updateBallStatus)

function updateBallPositions()
	for ballID,ballElement in pairs(balls) do
		local personHoldingIt = getElementData(ballElement, "heldby")
		if personHoldingIt then
			if (isElement(personHoldingIt)) then
				local pX,pY,pZ = getPedBonePosition(personHoldingIt, 26)
				local pZ = pZ - 0.1
				setElementPosition(ballElement, pX, pY, pZ)
			end
		end
	end
end
addEventHandler("onClientRender", getRootElement(), updateBallPositions)

function togBall(commandName)
	if isPedInVehicle(getLocalPlayer()) then
		return
	end
	local pX,pY,pZ=getElementPosition(getLocalPlayer())
	
	for ballID,ballObject in pairs(balls) do
		local bX,bY,bZ=getElementPosition(ballObject)
			if getDistanceBetweenPoints2D(pX,pY,bX,bY ) < 1 then
				if not isBallInHand then
					setPedWeaponSlot(getLocalPlayer(),0)
					triggerServerEvent("basketball:status", ballObject, not isBallInHand)
				end
			end
	end
end
addCommandHandler("pickball",togBall)

function playBoardSound(bSound, theBasket)
	local playerX, playerY, playerZ = getElementPosition( getLocalPlayer() )
	local basketX, basketY, basketZ = getElementPosition( theBasket )
	if getDistanceBetweenPoints3D(playerX, playerY, playerZ, basketX, basketY, basketZ ) < 30 then
		if (bSound == 1) then
			local theSound = playSound3D("bball-sounds/board.ogg", basketX, basketY, basketZ)
		elseif (bSound == 2) then
			local theSound = playSound3D("bball-sounds/drible.ogg", basketX, basketY, basketZ)
			setSoundVolume(theSound, 0.2)
		elseif (bSound == 3) then
			local theSound = playSound3D("bball-sounds/board.ogg", basketX, basketY, basketZ)
			setSoundMaxDistance(theSound, 15)
		elseif (bSound == 4) then
			local theSound = playSound3D("bball-sounds/boardhit.ogg", basketX, basketY, basketZ)
			setSoundVolume(theSound, 0.5)
			setSoundMaxDistance(theSound, 18)
		end
	end
end
addEvent("bball:soundBoard",true)
addEventHandler("bball:soundBoard",getLocalPlayer(), playBoardSound )