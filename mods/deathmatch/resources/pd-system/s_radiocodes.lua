local mysql = exports.mysql

function refreshPdCodes()
   local content = {}
   content.codes = mysql:query_fetch_assoc("SELECT `value` FROM `settings` WHERE `name`='pdcodes' ")["value"]
   content.procedures = mysql:query_fetch_assoc("SELECT `value` FROM `settings` WHERE `name`='pdprocedures' ")["value"]
   triggerClientEvent(client, "displayPdCodes", client, content)
end
addEvent("refreshPdCodes", true)
addEventHandler("refreshPdCodes", root, refreshPdCodes)

function updatePdCodes(contentFromClient)
	local isInPD, _ = exports.factions:isPlayerInFaction(client, 1)
	local pdLeader = exports.factions:hasMemberPermissionTo(client, 1, "edit_motd")
	local isInHP, _  = exports.factions:isPlayerInFaction(client, 59)
	local hpLeader = exports.factions:hasMemberPermissionTo(client, 59, "edit_motd")

	if ((isInPD and pdLeader) or (isInHP and hpLeader)) and contentFromClient then
		if contentFromClient.codes then
			if mysql:query_free("UPDATE `settings` SET `value`= '"..exports.global:toSQL(contentFromClient.codes).."' WHERE `name`='pdcodes' ") then
				outputChatBox("Codes saved successfully!", client)
			end
		end
		if contentFromClient.procedures then
			if mysql:query_free("UPDATE `settings` SET `value`= '"..exports.global:toSQL(contentFromClient.procedures).."' WHERE `name`='pdprocedures' ") then
				outputChatBox("Procedures saved successfully!", client)
			end
		end
	end
end
addEvent("updatePdCodes", true)
addEventHandler("updatePdCodes", getRootElement(), updatePdCodes)