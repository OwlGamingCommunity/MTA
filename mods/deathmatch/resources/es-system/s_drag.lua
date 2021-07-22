--[[
Made by Adams for OwlGaming.
Do not use without my permission.
Or you're an faggot.
Brah.

]]

--[[function carryPlayer(thePlayer, commandName, targetPlayer)
	if not (targetPlayer) then
				outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick]", thePlayer, 255, 194, 14)
			else
				local username = getPlayerName(thePlayer)
				local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
				
				if targetPlayer then
					if targetPlayer == thePlayer then
						outputChatBox("You can't carry yourself!", thePlayer, 255, 194, 14)
						return
					end
					
					if not getElementData(thePlayer, "carryplayer") == true then
						local x, y, z = getElementPosition(thePlayer)
						local tx, ty, tz = getElementPosition(targetPlayer)
						local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
						local theVehicle = getPedOccupiedVehicle(thePlayer)
						local theVehicleT = getPedOccupiedVehicle(targetPlayer)
						if not theVehicle and not theVehicleT then
							if distance < 3 then
								outputChatBox("Sending a carry request to "..getPlayerName(targetPlayer):gsub("_", " ").." ", thePlayer, 255, 194, 14)
								outputChatBox("You have received a carry request from "..getPlayerName(targetPlayer):gsub("_", " ")..", type /acceptcarry to accept.", targetPlayer, 255, 194, 14)
								
								setElementData(targetPlayer, "carryRequest", thePlayer)
							else
								outputChatBox("You're too far away from "..getPlayerName(targetPlayer):gsub("_", " ").."!", thePlayer, 255, 194, 14)
							end
						else
							outputChatBox("You can't carry someone inside a vehicle!", thePlayer, 255, 194, 14)
						end
					else
						outputChatBox("You're already carrying somebody!", thePlayer, 255, 194, 14)
					end
				end
			end
end
addCommandHandler("carry", carryPlayer)

function acceptCarry(thePlayer)
	local requestPlayer = getElementData(thePlayer, "carryRequest")
	if requestPlayer then
		local x, y, z = getElementPosition(thePlayer)
		local tx, ty, tz = getElementPosition(requestPlayer)
		local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
		if distance < 3 then
			triggerEvent("allowCarry", thePlayer, requestPlayer, thePlayer)
			setElementData(thePlayer, "carryRequest", nil)
			
			outputChatBox("You have accepted a carry request from "..getPlayerName(thePlayer):gsub("_", " ")..".", thePlayer, 255, 194, 14)
			outputChatBox(""..getPlayerName(requestPlayer):gsub("_", " ").." has accepted your request to carry them.", requestPlayer, 255, 194, 14)
		else
			outputChatBox("You're too far away from "..getPlayerName(requestPlayer):gsub("_", " ").."!", thePlayer, 255, 194, 14)
			setElementData(thePlayer, "carryRequest", nil)
		end
	end
end
addCommandHandler("acceptcarry", acceptCarry)

function denyCarry(thePlayer)
	local requestPlayer = getElementData(thePlayer, "carryRequest")
	if requestPlayer then
			outputChatBox(""..getPlayerName(thePlayer):gsub("_", " ").." has denied your request to carry them..", requestPlayer, 255, 194, 14)
			outputChatBox("You have denied "..getPlayerName(requestPlayer):gsub("_", " ").."'s request to carry you.", thePlayer, 255, 194, 14)
			
			setElementData(thePlayer, "carryRequest", nil)
	end
end
addCommandHandler("denycarry", denyCarry)

function allowCarry(thePlayer, carryPlayer)
	local x, y, z = getElementPosition(thePlayer)
	local rx, ry, rz = getElementRotation(thePlayer)
	
	attachElements(carryPlayer, thePlayer, 0.2, 0, 0.35)
	
	exports.global:applyAnimation(carryPlayer, "FAT", "idle_tired", 1, 1, 0, 1)
	
	toggleControl(thePlayer, "sprint", false)
	toggleControl(thePlayer, "jump", false)
	
	setElementData(thePlayer, "carryplayer", true)
	
	rotationTimer = setTimer ( function()
	local rxx, ryy, rzz = getElementRotation(thePlayer)
		setElementRotation(carryPlayer, rxx, ryy, rzz-180)
	end, 100, 0 )
end
addEvent("allowCarry", true)
addEventHandler("allowCarry", getRootElement(), allowCarry)

function dropPlayer(thePlayer, commandName)
	if getElementData(thePlayer, "carryplayer") == true then
		if isTimer(rotationTimer) then killTimer(rotationTimer) end
		
		local carriedPlayers = getAttachedElements(thePlayer)
		for k, v in ipairs (carriedPlayers) do
			if getElementType(v) == "player" then
				detachElements(v, thePlayer)
				local x, y, z = getElementPosition(thePlayer)
				setElementPosition(v, x, y, z)
				
				outputChatBox("You have dropped "..getPlayerName(v):gsub("_", " ")..".", thePlayer, 255, 194, 14)
				outputChatBox(""..getPlayerName(thePlayer):gsub("_", " ").." has dropped you.", v, 255, 194, 14)
				
				setElementData(thePlayer, "carryplayer", false)
				toggleControl(thePlayer, "sprint", true)
				toggleControl(thePlayer, "jump", true)
				
				setPedAnimation(v)
				
				break
			end
		end
	end
end
addCommandHandler("drop", dropPlayer)

function stopEnter(theVehicle, seat, jacked)
	if getElementData(source, "carryplayer") == true then
		cancelEvent()
		outputChatBox("You can't enter a vehicle whilst carrying someone!", source, 255, 194, 14)
	end
end
addEventHandler("onPlayerVehicleEnter", getRootElement(), stopEnter)]]