mysql = exports.mysql
--MAXIME

function check(thePlayer)
	local userid = getElementData(thePlayer, "account:id")
	local serialAccepted = false

	local result = mysql:query_fetch_assoc("SELECT `id` FROM `serial_whitelist` WHERE `userid`=".. userid .." AND `serial`='"..getPlayerSerial(thePlayer).."' AND `status`='1' LIMIT 1")
	if result and result['id'] and tonumber(result['id']) then
		mysql:query_free("UPDATE `serial_whitelist` SET `serial`='"..getPlayerSerial(thePlayer).."', `last_login_ip`='"..getPlayerIP(thePlayer).."', `last_login_date`=NOW() WHERE `userid`=".. userid .." AND `id`='"..result['id'].."' AND `status`='1' ")
		return true
	end

	if exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerFMTMember(thePlayer) then
		exports.global:sendMessageToAdmins("[SYSTEM] POSSIBLE STAFF ACCOUNT BREACHED! - Someone has illegally tried log into "..exports.global:getPlayerFullIdentity(thePlayer, 2, true).." account from a strange PC. (SERIAL: "..getPlayerSerial(thePlayer).." , IP: "..getPlayerIP(thePlayer)..")")
		return false
	else
		local addedSerials = mysql:query_fetch_assoc("SELECT COUNT(*) AS `count` FROM `serial_whitelist` WHERE `userid`=".. userid .." AND `status`='1' ")['count']
		if tonumber(addedSerials) > 0 then
			return false
		else 
			return true
		end
	end
end

function addSerialWhiteList(thePlayer, commandName, username, serial)
	if exports.integration:isPlayerLeadAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		if not username or not serial then
			outputChatBox("SYNTAX: /" .. commandName .. " [Exact Username] [Serial]", thePlayer, 255, 194, 14)
			return false
		end
		local user = mysql:query_fetch_assoc("SELECT `id`, `username` FROM `accounts` WHERE `username`='".. exports.global:toSQL(username) .."' LIMIT 1")
		if not user or not user['id'] or not tonumber(user['id']) then
			outputChatBox("No such username found.", thePlayer, 255,0,0)
			return false
		end
		if mysql:query_free("INSERT INTO `serial_whitelist` SET `userid`='"..user['id'].."', `serial`='"..exports.global:toSQL(serial).."' ") then
			outputChatBox("Serial whitelist successfully added for account '"..user['username'].."' with serial '"..serial.."'.", thePlayer, 0,255,0)
			exports.global:sendMessageToAdmins("[SYSTEM] "..exports.global:getPlayerFullIdentity(thePlayer, 2, true).." has added '"..user['username'].."' with serial '"..serial.."' to serial whitelist. ")
			return true
		else
			outputChatBox("Serial whitelist has failed to add.", thePlayer, 255,0,0)
			return false
		end
	end
end
--addCommandHandler("addserialwl", addSerialWhiteList, false, false)

function delSerialWhiteList(thePlayer, commandName, id)
	if exports.integration:isPlayerLeadAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		if not id or not tonumber(id) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Whitelist ID]", thePlayer, 255, 194, 14)
			return false
		end

		local existing = mysql:query_fetch_assoc("SELECT `serial_whitelist`.`id`, `username`, `serial` FROM `serial_whitelist` LEFT JOIN `accounts` ON `serial_whitelist`.`userid`=`accounts`.`id` WHERE `serial_whitelist`.`id`='"..id.."' LIMIT 1")
		if not existing or not existing['username'] then
			outputChatBox("Serial whitelist removing failed.", thePlayer, 255,0,0)
			return false
		end
		if mysql:query_free("DELETE FROM `serial_whitelist` WHERE `id`='"..id.."' ") then
			outputChatBox("Serial whitelist successfully removed from account '"..existing['username'].."' with serial '"..existing['serial'].."'.", thePlayer, 0,255,0)
			exports.global:sendMessageToAdmins("[SYSTEM] "..exports.global:getPlayerFullIdentity(thePlayer, 2, true).." has removed '"..existing['username'].."' with serial '"..existing['serial'].."' from the serial whitelist. ")
			return true
		else
			outputChatBox("Serial whitelist removing failed.", thePlayer, 255,0,0)
			return false
		end
	end
end
--addCommandHandler("delserialwl", delSerialWhiteList, false, false)

function showAllWhiteList(thePlayer, commandName)
	if exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		local whitelists = {}
		local mQuery1 = mysql:query("SELECT `serial_whitelist`.`id`, `username`, `serial` FROM `serial_whitelist` LEFT JOIN `accounts` ON `serial_whitelist`.`userid`=`accounts`.`id` ORDER BY `username`")
		while true do
			local row = mysql:fetch_assoc(mQuery1)
			if not row then break end
			table.insert(whitelists, row )
		end
		mysql:free_result(mQuery1)
		
		outputChatBox("SERIAL WHITELIST:", thePlayer, 255, 194, 14)
		
		if #whitelists < 1 then
			outputChatBox("  Serial Whitelist is empty. /addserialwl to add.", thePlayer, 255,0,0)
		end

		for i = 1, #whitelists do
			outputChatBox("  #"..whitelists[i]['id'].." - "..whitelists[i]['username'].." - "..whitelists[i]['serial'], thePlayer, 255, 194, 14)
		end
		outputChatBox("TIPS: /whitelists, /addserialwl /delserialwl", thePlayer, 255, 194, 14)
	end
end
--addCommandHandler("whitelists", showAllWhiteList, false, false)


