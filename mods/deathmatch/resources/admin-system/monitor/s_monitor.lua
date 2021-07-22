function doMonitorList(sourcePlayer, command, targetPlayerName, ...)
	if (exports.integration:isPlayerTrialAdmin(sourcePlayer) or exports.integration:isPlayerSupporter(sourcePlayer)) then
		if not targetPlayerName then
			local dataTable = { }
			for key, value in ipairs( getElementsByType( "player" ) ) do
				local loggedin = getElementData(value, "loggedin")
				if (loggedin == 1) then
					local reason = getElementData(value, "admin:monitor")
					if reason and #reason > 0 then
						local playerAccount = getElementData(value, "account:username")
						local playerName = getPlayerName(value):gsub("_", " ")
						table.insert(dataTable, { playerAccount, playerName, reason } )
					end
				end
			end
			triggerClientEvent( sourcePlayer, "onMonitorPopup", sourcePlayer, dataTable, exports.integration:isPlayerTrialAdmin(sourcePlayer) or exports.integration:isPlayerSupporter(sourcePlayer))		
		else
			if not ... then
				outputChatBox("SYNTAX: /" .. command .. " [player] [reason]", sourcePlayer, 255, 194, 14)
			else
				local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(sourcePlayer, targetPlayerName)
				if targetPlayer then
					local accountID = tonumber(getElementData(targetPlayer, "account:id"))
					local month = getRealTime().month + 1
					local timeStr = tostring(getRealTime().monthday) .. "/" ..tostring(month)  
					local reason = table.concat({...}, " ") .. " (" .. getElementData(sourcePlayer, "account:username") .. " "..timeStr..")"
					if exports.mysql:query_free("UPDATE account_details SET monitored = '" .. exports.mysql:escape_string(reason) .. "' WHERE account_id = " .. exports.mysql:escape_string(accountID)) then
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "admin:monitor", reason, false)
						outputChatBox("You added " .. getPlayerName(targetPlayer):gsub("_", " ") .. " to the monitor list.", sourcePlayer, 0, 255, 0)
					end
				end
			end
		end
	end
end
addCommandHandler("monitor", doMonitorList)

addEvent("monitor:onSaveEdittedMonitor", true)
addEventHandler("monitor:onSaveEdittedMonitor", getRootElement( ),
	function (sourcePlayer, username, monitorContent, targetPlayerName1)
		local staffUsername = getElementData(sourcePlayer, "account:username")
		local month = getRealTime().month + 1
		local timeStr = tostring(getRealTime().monthday) .. "/" ..tostring(month)  
		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(sourcePlayer, targetPlayerName1)
		local reason = monitorContent .. " (" .. staffUsername .. " "..timeStr..")"
		if exports.mysql:query_free("UPDATE account_details SET monitored = '" .. exports.mysql:escape_string(reason) .. "' WHERE account_id = '" .. exports.mysql:escape_string(exports.cache:getIdFromUsername(username)).."'") then
			exports.anticheat:changeProtectedElementDataEx(targetPlayer, "admin:monitor", reason, false)
			outputChatBox("[MONITOR] You updated " .. username .. " to the monitor list.", sourcePlayer, 0, 255, 0)
			doMonitorList(sourcePlayer, "monitor") 
			local staffTitle = exports.global:getPlayerAdminTitle(sourcePlayer)
			exports.global:sendMessageToAdmins("[MONITOR] "..staffTitle.." "..staffUsername.." modified monitor on player '"..targetPlayerName.."' ("..monitorContent..").")
			exports.global:sendMessageToSupporters("[MONITOR] "..staffTitle.." "..staffUsername.." modified monitor on player '"..targetPlayerName.."' ("..monitorContent..").")
		else
			outputChatBox("[MONITOR] Failed to update " .. username .. " to the monitor list.", sourcePlayer, 255, 0, 0) 
		end
	end	
)

function offlineMonitorADD(sourcePlayer, command, username, ...)
	if (exports.integration:isPlayerTrialAdmin(sourcePlayer) or exports.integration:isPlayerSupporter(sourcePlayer)) then
		if not ... then
			triggerClientEvent(sourcePlayer, "monitor:oadd", sourcePlayer)
			--outputChatBox("SYNTAX: /" .. command .. " [username] [reason]", sourcePlayer, 255, 194, 14)
		else
			local name = mysql:query_fetch_assoc("SELECT `account_id`, `monitored` FROM `account_details` WHERE `account_id` = '" .. mysql:escape_string(exports.cache:getIdFromUsername(username)) .. "'" )
			if name then
				local uid = name["account_id"]
				local uname = username
			
				local month = getRealTime().month + 1
				local timeStr = tostring(getRealTime().monthday) .. "/" ..tostring(month)  
				local staffUsername = getElementData(sourcePlayer, "account:username")
				
				local reasonTemp = table.concat({...}, " ")
				local reason =  reasonTemp .. " (" .. staffUsername .. " "..timeStr..")"
				
				
				
				if name["monitored"] and #name["monitored"] > 0 then
					reason = name["monitored"] .. " | "..reason
				end
				
				if exports.mysql:query_free("UPDATE account_details SET monitored = '" .. exports.mysql:escape_string(reason) .. "' WHERE account_id = " .. exports.mysql:escape_string(uid)) then
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "admin:monitor", reason, false)
					outputChatBox("You added " .. username .. " to the monitor list.", sourcePlayer, 0, 255, 0)
					local staffTitle = exports.global:getPlayerAdminTitle(sourcePlayer)
					exports.global:sendMessageToAdmins("[OMONITOR] "..staffTitle.." "..staffUsername.." added an offline monitor on player '"..username.."' ("..reasonTemp..").")
					exports.global:sendMessageToSupporters("[OMONITOR] "..staffTitle.." "..staffUsername.." added an offline monitor on player '"..username.."' ("..reasonTemp..").")
				end
			end
		end
	end
end
addCommandHandler("omonitor", offlineMonitorADD)

function offlineMonitorADD2(sourcePlayer, command, username, ...)
	if (exports.integration:isPlayerTrialAdmin(sourcePlayer) or exports.integration:isPlayerSupporter(sourcePlayer)) then
		if not ... then
			triggerClientEvent(sourcePlayer, "monitor:oadd2", sourcePlayer)
			--outputChatBox("SYNTAX: /" .. command .. " [username] [reason]", sourcePlayer, 255, 194, 14)
		else
			local name = mysql:query_fetch_assoc("SELECT `id`,`username`, `monitored` FROM `account_details` WHERE `account_id` = '" .. mysql:escape_string(exports.cache:getIdFromUsername(username)) .. "'" )
			if name then
				local uname = name["username"]
				local uid = name["id"]
			
				local month = getRealTime().month + 1
				local timeStr = tostring(getRealTime().monthday) .. "/" ..tostring(month)  
			
				local reason =  table.concat({...}, " ") .. " (" .. getElementData(sourcePlayer, "account:username") .. " "..timeStr..")"
				
				
				
				if name["monitored"] and #name["monitored"] > 0 then
					reason = name["monitored"] .. " | "..reason
				end
				
				if exports.mysql:query_free("UPDATE account_details SET monitored = '" .. exports.mysql:escape_string(reason) .. "' WHERE account_id = " .. exports.mysql:escape_string(uid)) then
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "admin:monitor", reason, false)
					outputChatBox("You added " .. name["username"] .. " to the monitor list.", sourcePlayer, 0, 255, 0)
				end
			end
		end
	end
end
addCommandHandler("omonitor2", offlineMonitorADD2)

addEvent("monitor:add", true)
addEventHandler("monitor:add", getRootElement( ),
	function( name, reason)
		if exports.integration:isPlayerTrialAdmin(client) or exports.integration:isPlayerSupporter(client) then
			offlineMonitorADD(client, "omonitor", name, reason)
		end
	end
)

addEvent("monitor:checkUsername", true)
addEventHandler("monitor:checkUsername", getRootElement( ),
	-- function( name, reason)
		-- if exports.integration:isPlayerTrialAdmin(client) or exports.integration:isPlayerSupporter(client) then
			-- offlineMonitorADD(client, "omonitor", name, reason)
		-- end
	-- end
	function (username)
		local name = mysql:query_fetch_assoc("SELECT `account_id`,`username`, `monitored` FROM `account_details` WHERE `username` = '" .. mysql:escape_string(exports.cache:getIdFromUsername(username)) .. "'" )
			if name then
				local uname = name["username"]
				local uid = name["id"]
				local month = getRealTime().month + 1
				local timeStr = tostring(getRealTime().monthday) .. "/" ..tostring(month)  
				--local reason =  table.concat({...}, " ") .. " (" .. getElementData(sourcePlayer, "account:username") .. " "..timeStr..")"
				
				triggerClientEvent()
			else
			
			
			end
	end
)

addEvent("monitor:remove", true)
addEventHandler("monitor:remove", getRootElement( ),
	function( )
		if exports.integration:isPlayerTrialAdmin(client) or exports.integration:isPlayerSupporter(client) then
			local staffUsername = getElementData(client, "account:username")
			local playerUsername = getElementData(source, "account:username")
			local accountID = tonumber(getElementData(source, "account:id"))
			if exports.mysql:query_free("UPDATE account_details SET monitored = '' WHERE account_id = " .. exports.mysql:escape_string(accountID)) then
				exports.anticheat:changeProtectedElementDataEx(source, "admin:monitor", false, false)
				outputChatBox("You removed " .. getPlayerName(source):gsub("_", " ") .. " from the monitor list.", client, 0, 255, 0)
				
				local staffTitle = exports.global:getPlayerAdminTitle(client)
				exports.global:sendMessageToAdmins("[MONITOR] "..staffTitle.." "..staffUsername.." removed monitor on player '"..playerUsername.."'.")
				exports.global:sendMessageToSupporters("[MONITOR] "..staffTitle.." "..staffUsername.." removed monitor on player '"..playerUsername.."'.")
				
				doMonitorList(client)
			end
		end
	end
)


--[[
function onCharacterLogin(characterName, factionID)
	local thePlayer = source
	local reason = getElementData(thePlayer, "admin:monitor")
	if reason and #reason > 0 then
		local playerAccount = getElementData(thePlayer, "account:username")
		local playerName = getPlayerName(thePlayer):gsub("_", " ")
		exports.global:sendMessageToAdmins("[MONITOR] Player '"..playerName.."' ("..playerAccount..") logged in. MR: "..reason)
	end
end
addEventHandler("onCharacterLogin", getRootElement(), onCharacterLogin)]]