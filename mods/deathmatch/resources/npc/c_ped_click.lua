local messages = { "F*** off, Punk!", "You're not welcome.", "I'm not selling you anything.", "Find someone else to harrass.", "Get Lost." }

function pedDamage()
	if getElementData(source,"shopkeeper") then
		setElementData(source,"ignores", true, false)
		setTimer(setElementData,300000,1,source,"ignores", nil, true)
		cancelEvent()
	end
end
addEventHandler("onClientPedDamage", getRootElement(), pedDamage)

--[[--Removed by Maxime
function clickPed(button, state, absX, absY, wx, wy, wz, element)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	
	if element and getElementType(element) == "ped" and state=="down" and getElementData(element,"shopkeeper") then
		local x, y, z = getElementPosition(getLocalPlayer())

		if getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=4 then
			if true then --not getElementData(element,"ignores") then
				triggerServerEvent("shop:keeper", element)
			else
				outputChatBox('Storekeeper says: ' .. messages[math.random(1, #messages)])
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickPed, true)
]]