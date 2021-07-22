
function initialize(res)
	local spawnedPed = createPed(141, 1955.8125, -2181.121, 13.587)
	setPedRotation(spawnedPed, 231)
	setElementFrozen(spawnedPed, true)
	--setElementDimension(spawnedPed, 9)
	--setElementInterior(spawnedPed, 6)
	setElementData(spawnedPed, "talk", 1)
	setElementData(spawnedPed, "name", "Evelyn Branson")
	exports.anticheat:changeProtectedElementDataEx(spawnedPed, "languages.lang1" , 1, false)
	exports.anticheat:changeProtectedElementDataEx(spawnedPed, "languages.lang1skill", 100, false)
	exports.anticheat:changeProtectedElementDataEx(spawnedPed, "languages.lang2" , 2, false)
	exports.anticheat:changeProtectedElementDataEx(spawnedPed, "languages.lang2skill", 100, false)
	exports.anticheat:changeProtectedElementDataEx(spawnedPed, "languages.current", 1, false)	
end
--addEventHandler("onResourceStart", getResourceRootElement(), initialize)

function pedOutputChat(ped, chat, text, theClient, language)
	if not ped then return end
	if not client then client = theClient end
	if not client then return end
	if not tonumber(language) then language = 1 end
	if chat == "me" then
		local name = getElementData(ped, "name") or exports.global:getPlayerName(ped)
		local message = tostring(text)
		exports.global:sendLocalText(client, " *"..string.gsub(name, "_", " ")..( message:sub(1, 1) == "'" and "" or " ")..message, 255, 51, 102)
	else
		exports['chat-system']:localIC(ped, tostring(text), language)
	end
end
addEvent("airport:ped:outputchat", true)
addEventHandler("airport:ped:outputchat", getResourceRootElement(), pedOutputChat)

function pedDialog_FAA_getLicenses(ped)
	local licenses = exports.mdc:getPlayerPilotLicenses(client) or {}
	local message = "hands a list to "..tostring(exports.global:getPlayerName(client)).."."
	pedOutputChat(ped, "me", message, client)
	triggerClientEvent(client, "airport:getLicensesCallback", getResourceRootElement(), licenses)
end
addEvent("airport:getLicenses", true)
addEventHandler("airport:getLicenses", getResourceRootElement(), pedDialog_FAA_getLicenses)

function pedDialog_FAA_sendMessage(ped, message)
	pedOutputChat(client, "local", "Tell your bosses "..tostring(message)..".", client)
	local employees = exports.factions:getPlayersInFaction(47) or {}
	if #employees > 0 then
		pedOutputChat(ped, "local", "Alright. I'll pass on the message. Thanks!", client)
		pedOutputChat(ped, "me", "sends a text message.", client)
		local pedName = getElementData(ped, "name")
		if pedName then
			pedName = pedName.." (Receptionist)"
		else
			pedName = "Receptionist"
		end
		for key, value in ipairs(employees) do
			outputChatBox("[English] SMS from '"..tostring(pedName).."' [#5555]: " .. message, value, 120, 255, 80)
		end
	else
		pedOutputChat(ped, "local", "Sorry, I can't reach anyone. Please come back or call 5555 later.", client)
	end
end
addEvent("airport:ped:receptionistFAA:sendMessage", true)
addEventHandler("airport:ped:receptionistFAA:sendMessage", getResourceRootElement(), pedDialog_FAA_sendMessage)

function pedDialog_VMAT_spawn(ped, callsign)
	local success, reason = exports.global:giveItem(client, 264, callsign)
	if success then
		if ped then
			local message = "hands a VMAT device to "..tostring(exports.global:getPlayerName(client)).."."
			pedOutputChat(ped, "me", message, client)
		end
		triggerClientEvent(client, "item:updateclient", client)
	else
		local message = "Hmm. This doesn't look right."
		pedOutputChat(ped, "local", message, client)
		outputChatBox("ERROR: " .. tostring(reason), client, 255, 0, 0)
	end
end
addEvent("airport:spawnVMAT", true)
addEventHandler("airport:spawnVMAT", getResourceRootElement(), pedDialog_VMAT_spawn)