function SANJob(pedName)
	exports['global']:sendLocalText(source, pedName .. " says: We have many well paid positions available! Check our website for more information.", 255, 255, 255, 10)
end
addEvent("SAN:Job", true)
addEventHandler("SAN:Job", getRootElement(), SANJob)


function SANContactUs(pedName, reason)
	if (string.len(reason) == 0) then
		exports['global']:sendLocalText(client, pedName.." says: Really?! What do you expect me to tell them?", 255, 255, 255, 10)
		outputChatBox("You never entered a reason!", client)
		return
	end
	
	exports['global']:sendLocalText(client, pedName.." says: No problem, let me try to call someone over for you!", 255, 255, 255, 10)
	
	local SANStaff = exports.factions:getPlayersInFaction( 20 )
	
	if (#SANStaff > 0) then
		exports['global']:sendLocalText(client, pedName.." [RADIO]: Someone needs assistance at HQ!", 255, 255, 255, 10)
		for key, value in pairs( SANStaff ) do
			outputChatBox("[RADIO] Hi everyone, it's Victoria here! I hope you're all having a good day.", value, 0, 183, 239)
			outputChatBox("[RADIO] Got a person in the HQ lobby who wants to speak with someone. ((" .. getPlayerName(client):gsub("_"," ") .. "))", value, 0, 183, 239)
			outputChatBox("[RADIO] Situation: " .. reason, value, 0, 183, 239)
		end
	else
	exports['global']:sendLocalText(client, pedName.." says: Sorry, there is nobody available right now.", 255, 255, 255, 10)
	end
end
addEvent("SAN:CU", true)
addEventHandler("SAN:CU", getRootElement(), SANContactUs)