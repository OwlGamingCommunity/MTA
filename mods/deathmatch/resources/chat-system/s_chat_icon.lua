local chaticonsHidden = { }

function sendChatIconShown()
	local px, py, pz = getElementPosition(client)

	for key, value in ipairs(getElementsByType("player")) do
		local vx, vy, vz = getElementPosition(value)
			
		if ( getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) <= 25 ) and chaticonsHidden[value]==nil then -- only send if they can see it and have chaticons enabled
			triggerClientEvent(value, "addChatter", client)
		end
	end
end
addEvent("chat1", true)
addEventHandler("chat1", getRootElement(), sendChatIconShown)

function sendChatIconHidden()
	local px, py, pz = getElementPosition(client)
	for key, value in ipairs(getElementsByType("player")) do
		local vx, vy, vz = getElementPosition(value)
		
		if ( getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz) <= 25 ) and chaticonsHidden[value]==nil then -- only send if they can see it and have chaticons enabled, persons out of range who COULD see it before, are handled clientside
			triggerClientEvent(value, "delChatter", client)
		end
	end
end
addEvent("chat0", true)
addEventHandler("chat0", getRootElement(), sendChatIconHidden)

function storeChatIconShown()
	chaticonsHidden[client] = nil
end
addEvent("chaticon1", true)
addEventHandler("chaticon1", getRootElement(), storeChatIconShown)

function storeChatIconHidden()
	chaticonsHidden[client] = true
end
addEvent("chaticon0", true)
addEventHandler("chaticon0", getRootElement(), storeChatIconHidden)