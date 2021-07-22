addEvent("lses:ped:start", true)
function lsesPedStart(pedName)
	exports['global']:sendLocalText(client, pedName.." says: Hello, how can I help you today?", 255, 255, 255, 10)
end
addEventHandler("lses:ped:start", getRootElement(), lsesPedStart)

addEvent("lses:ped:help", true)
function lsesPedHelp(pedName)
	exports['global']:sendLocalText(client, pedName.." says: Really?! One moment!", 255, 255, 255, 10)
	exports['global']:sendLocalText(client, pedName.." [RADIO]: Someone needs assistance at the hospital reception!", 255, 255, 255, 10)
	for key, value in ipairs( exports.factions:getPlayersInFaction(164) ) do
		outputChatBox("[RADIO] This is dispatch, we've got an incident, over.", value, 0, 183, 239)
		outputChatBox("[RADIO] Situation: Someone needs assistance!, over.  ((" .. getPlayerName(client):gsub("_"," ") .. "))", value, 0, 183, 239)
		outputChatBox("[RADIO] Location: All Saints General Hospital, at the reception desk, over.", value, 0, 183, 239)
	end
end
addEventHandler("lses:ped:help", getRootElement(), lsesPedHelp)

addEvent("lses:ped:appointment", true)
function lsesPedAppointment(pedName)
	exports['global']:sendLocalText(client, pedName.." says: I'll notify who I can, please take a seat while waiting.", 255, 255, 255, 10)
	for key, value in ipairs( exports.factions:getPlayersInFaction(164) ) do
		outputChatBox("[RADIO] Reception here, we've got someone here for an appointment, over. ((" .. getPlayerName(client):gsub("_"," ") .. "))", value, 0, 183, 239)
		outputChatBox("[RADIO] Location: All Saints General, at the reception desk, over.", value, 0, 183, 239)
	end
end
addEventHandler("lses:ped:appointment", getRootElement(), lsesPedAppointment)

function pedOutputChat(ped, chat, text, theClient, language)
	if not ped then return end
	if not client then client = theClient end
	if not client then return end
	if not tonumber(language) then language = 1 end
	if chat == "me" then
		local name = getElementData(ped, "name") or exports.global:getPlayerName(ped)
		local message = tostring(text)
		exports.global:sendLocalText(client, " *"..string.gsub(name, "_", " ")..( message:sub(1, 1) == "'" and "" or " ")..message, 255, 51, 102)
	elseif chat == "hospitalpa" then
		local name = getElementData(ped, "name") or exports.global:getPlayerName(ped)
		local message = tostring(text)
		exports['chat-system']:radio(ped, -5, message, chat)
	else
		exports['chat-system']:localIC(ped, tostring(text), language)
	end
end
addEvent("lses:ped:outputchat", true)
addEventHandler("lses:ped:outputchat", getResourceRootElement(), pedOutputChat)