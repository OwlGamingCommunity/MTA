function doCheck(sourcePlayer, command, ...)
	if (exports.integration:isPlayerTrialAdmin(sourcePlayer) or exports.integration:isPlayerSupporter(sourcePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. command .. " [Partial Player Name / ID] or [Username]", sourcePlayer, 255, 194, 14)
		else
			local checkTarget = exports.global:findPlayerByPartialNick(sourcePlayer, table.concat({...},"_"), true)
			if (checkTarget) then
				local logged = getElementData(checkTarget, "loggedin")

				if (logged==0) then
					outputChatBox("Player is not logged in.", sourcePlayer, 255, 0, 0)
				else
					if checkTarget and isElement(checkTarget) then
						local ip = getPlayerIP(checkTarget)
						local adminreports = tonumber(getElementData(checkTarget, "adminreports"))
						local donPoints = nil

						-- get admin note
						local note = ""
						local points = "?"
						local warns = "?"
						local transfers = "?"
						

						local qh = dbQuery(exports.mysql:getConn("mta"), "SELECT adminnote, warns FROM account_details WHERE account_id =?", getElementData(checkTarget, "account:id"))
						local result = dbPoll( qh, 10000 )
						if result then 
							note = result[1]["adminnote"] or ""
							warns = result[1]["warns"] 
						else
							dbFree(qh)
						end

						local qh = dbQuery(exports.mysql:getConn("core"), "SELECT punishpoints, credits FROM accounts WHERE id=?", getElementData(checkTarget, "account:id"))
						local result = dbPoll( qh, 10000 )
						if result and #result > 0 then
							points = result[1]["punishpoints"] or "?" 
							donPoints = result[1]["credits"] or "?"
						else
							dbFree(qh)
						end

						local query = dbQuery(exports.mysql:getConn("mta"), "SELECT action, COUNT(*) as numbr FROM adminhistory WHERE user = ?", getElementData(checkTarget, "account:id"))
						local result = dbPoll(query, 10000)
						local history = {}

						if result then 
							for _, row in ipairs(result) do 
								if not (row.action == false and row.numbr == 0) then 
									table.insert(history, {tonumber(row.action), tonumber(row.numbr)})
								end
							end
						else
							dbFree(query)
						end
						
						local hoursAcc = 0
						local query = dbQuery(exports.mysql:getConn("mta"), "SELECT SUM(hoursPlayed) AS hours FROM `characters` WHERE account = ?", getElementData(checkTarget, "account:id"))
						local result = dbPoll(query, 10000)
						if result[1] then
							hoursAcc = tonumber(result[1]["hours"])
						else 
							dbFree(query)
						end

						local bankmoney = getElementData(checkTarget, "bankmoney") or -1
						local money = getElementData(checkTarget, "money") or -1

						local adminlevel = exports.global:getPlayerAdminTitle(checkTarget)

						local hoursPlayed = getElementData( checkTarget, "hoursplayed" )
						local username = getElementData( checkTarget, "account:username" )
						local accountID = getElementData( checkTarget, "account:id" )
						local offline = false

						exports.logs:dbLog( sourcePlayer, 4, checkTarget, "ONLINE CHECK" )
						triggerClientEvent( sourcePlayer, "onCheck", checkTarget, ip, adminreports, donPoints, note, history, warns, points, transfers, bankmoney, money, adminlevel, hoursPlayed, username, hoursAcc, accountID, offline)
					end
				end
			else
				local offlineTarget = (...)
				local preparedQuery = "SELECT * FROM accounts WHERE username = ?"
				dbQuery(function(qh, offlineTarget)
					local result = dbPoll(qh, 0)
					local accountData_core = result[1]
					if accountData_core then 
						local accountid = accountData_core["id"]
						local username = accountData_core["username"]
						local admin = tonumber(accountData_core["admin"])
						local supporter = tonumber(accountData_core["supporter"])
						local scripter = tonumber(accountData_core["scripter"])
						local mapper = tonumber(accountData_core["mapper"])
						local vct = tonumber(accountData_core["vct"])
						local fmt = tonumber(accountData_core["fmt"])
						local ip = accountData_core["ip"]
						local credits = accountData_core["credits"]
						local points = accountData_core["punishpoints"] or "?"

						for _, v in pairs(getElementsByType("player")) do
							if (username == getElementData(v, "account:username")) and not (getElementData(v, "loggedin") == 0) then
								return doCheck(sourcePlayer, "check", getPlayerName(v))
							end
						end

						local query = dbQuery(exports.mysql:getConn("mta"), "SELECT action, COUNT(*) as numbr FROM adminhistory WHERE user = ? GROUP BY action", accountid)
						local result = dbPoll(query, 10000)
						local history = {}

						if result then 
							for _, row in ipairs(result) do 
								table.insert(history, {tonumber(row.action), tonumber(row.numbr)})
							end
						else 
							dbFree(query)
						end

						local hoursAcc = 0
						local query = dbQuery(exports.mysql:getConn("mta"), "SELECT SUM(hoursPlayed) AS hours FROM `characters` WHERE account = ?", accountid)
						local result = dbPoll(query, 10000)
						if result[1] then
							hoursAcc = tonumber(result[1]["hours"])
						else 
							dbFree(query)
						end

						local adminreports = 0
						local adminnote = ""
						local warns = ""
						
						local query = dbQuery(exports.mysql:getConn("mta"), "SELECT adminnote, adminreports, warns FROM account_details WHERE account_id = ?", accountid)
						local result = dbPoll(query, 10000)
						if result[1] then
							adminnote = result[1]["adminnote"] or ""
							adminreports = tonumber(result[1]["adminreports"])
							warns = result[1]["warns"]
						else 
							dbFree(query)
						end

						if ( admin > 0 ) and not ( admin == 10 ) then
							adminlevel = exports.integration:getStaffTitle(1, admin)
						elseif ( supporter > 0 ) then
							adminlevel = exports.integration:getStaffTitle(2, supporter)
						elseif ( scripter > 0 ) then 
							adminlevel = exports.integration:getStaffTitle(4, scripter)
						elseif ( vct > 0 ) then 
							adminlevel = exports.integration:getStaffTitle(3, vct)
						elseif ( mapper > 0 ) then 
							adminlevel = exports.integration:getStaffTitle(5, mapper)
						elseif (fmt > 0) then 
							adminlevel = exports.integration:getStaffTitle(6, fmt) 
						else 
							adminlevel = "Player"
						end

						local bankmoney = 0
						local money = 0
						local offline = true
						
						
						exports.logs:dbLog(sourcePlayer, 4, sourcePlayer, "OFFLINE CHECK ON:" .. offlineTarget)
						triggerClientEvent(sourcePlayer, "onCheck", sourcePlayer, ip, adminreports, credits, adminnote, history, warns, points, transfers, bankmoney, money, adminlevel, hoursPlayed, username, hoursAcc, accountid, offline)
					else 
						outputChatBox("Account/Player '"..offlineTarget.."' not found", sourcePlayer, 255, 0, 0)
					end
					dbFree(qh)
				end, {qh, offlineTarget}, exports.mysql:getConn("core"), preparedQuery, offlineTarget)
			end
		end
	end
end
addEvent("checkCommandEntered", true)
addEventHandler("checkCommandEntered", getRootElement(), doCheck)

function savePlayerNote(dbid, username, text)
	if exports.integration:isPlayerTrialAdmin(client) or exports.integration:isPlayerSupporter(client) then
		if dbid then 
			local result = mysql:query_free("UPDATE account_details SET adminnote = '" .. mysql:escape_string(text) .. "' WHERE account_id = '" .. mysql:escape_string(dbid) .. "';" )
			if result then
				outputChatBox( "Note for the " .. username .. " has been updated.", client, 0, 255, 0 )
			else
				outputChatBox( "Note Update failed.", client, 255, 0, 0 )
			end
		else
			outputChatBox( "Unable to get Account ID.", client, 255, 0, 0 )
		end
	end
end
addEvent( "savePlayerNote", true )
addEventHandler( "savePlayerNote", getRootElement(), savePlayerNote )

function showAdminHistory( target )
	if source and isElement(source) and getElementType(source) == "player" then
		client = source
	end

	if not (exports.integration:isPlayerTrialAdmin( client ) or exports.integration:isPlayerSupporter( client )) then
		if client ~= target then
			return false
		end
	end

	local targetID = getElementData( target, "account:id" )
	if targetID then
		local result = mysql:query("SELECT DATE_FORMAT(date,'%b %d, %Y at %h:%i %p') AS date, action, h.admin AS hadmin, reason, duration, c.charactername AS user_char, h.id as recordid FROM adminhistory h LEFT JOIN characters c ON h.user_char=c.id WHERE user = " .. mysql:escape_string(targetID) .. " ORDER BY h.id DESC" )
		if result then
			local info = {}
			local continue = true
			while continue do
				local row = mysql:fetch_assoc(result)
				if not row then break end
				local record = {}

				record[1] = row["date"]
				record[2] = row["action"]
				record[3] = row["reason"]
				record[4] = row["duration"]
				record[5] = exports.cache:getUsernameFromId(row["hadmin"]) or "SYSTEM"
				record[6] = row["user_char"] == mysql_null() and "N/A" or row["user_char"]
				record[7] = row["recordid"]
				record[8] = row["hadmin"] == mysql_null() and "SYSTEM" or row["hadmin"]

				table.insert( info, record )
			end

			triggerClientEvent( client, "cshowAdminHistory", target, info, tostring( getElementData( target, "account:username" ) ) )
			mysql:free_result( result )
		else
			outputChatBox( "Failed to retrieve history.", client, 255, 0, 0)
		end
	else
		outputChatBox("Unable to find the account id.", client, 255, 0, 0)
	end
end
addEvent( "showAdminHistory", true )
addEventHandler( "showAdminHistory", getRootElement(), showAdminHistory )

function showOfflineAdminHistory( gameaccountid, name )
	if (exports.integration:isPlayerTrialAdmin( source ) or exports.integration:isPlayerSupporter( source )) and tonumber(gameaccountid) then
		local targetID = gameaccountid
		local result = mysql:query("SELECT DATE_FORMAT(date,'%b %d, %Y at %h:%i %p') AS date, action, h.admin AS hadmin, reason, duration, c.charactername AS user_char, h.id as recordid FROM adminhistory h LEFT JOIN characters c ON h.user_char=c.id WHERE user = " .. mysql:escape_string(targetID) .. " ORDER BY h.id DESC" )
		if result then
			local info = {}
			local continue = true
			while continue do
				local row = mysql:fetch_assoc(result)
				if not row then break end
				local record = {}
				record[1] = row["date"]
				record[2] = row["action"]
				record[3] = row["reason"]
				record[4] = row["duration"]
				record[5] = row["username"] == exports.cache:getUsernameFromId(row["hadmin"]) or "SYSTEM"
				record[6] = row["user_char"] == mysql_null() and "N/A" or row["user_char"]
				record[7] = row["recordid"]
				record[8] = row["hadmin"] == mysql_null() and "SYSTEM" or row["hadmin"]

				table.insert( info, record )
			end
			triggerClientEvent( source, "cshowAdminHistory", source, info, name or gameaccountid )
			mysql:free_result( result )
		else
			outputChatBox( "Failed to retrieve history.", source, 255, 0, 0)
		end
	end
end
addEvent( "showOfflineAdminHistory", true )
addEventHandler( "showOfflineAdminHistory", getRootElement(), showOfflineAdminHistory )

function removeAdminHistoryLine(ID)
	if not ID then return end

	local sqlQuery = mysql:query_fetch_assoc("SELECT * FROM `adminhistory` WHERE `id`='".. mysql:escape_string(tostring(ID)).."'")
	if sqlQuery then
		if (tonumber(sqlQuery["action"]) == 4) then -- Warning
			local accountNumber = tostring(sqlQuery["user"])
			mysql:query_free("UPDATE `account_details` SET `warns`=warns-1 WHERE `account_id`='"..mysql:escape_string(accountNumber).."' AND `warns` > 0")
			for i, player in pairs(getElementsByType("player")) do
				if getElementData(player, "account:id") == tonumber(accountNumber) then
					local currentwarns = getElementData(player, "warns")
					if not currentwarns then currentwarns = 1 end
					local warns = currentwarns - 1
					exports.anticheat:changeProtectedElementDataEx(player, "warns", warns, false)
					break
				end
			end
		elseif (tonumber(sqlQuery["action"]) == 8) then -- /punish
			local accountNumber = tostring(sqlQuery["user"])
			dbExec(exports.mysql:getConn("core"), "UPDATE `accounts` SET `punishpoints`=GREATEST(punishpoints-?, 0) WHERE `ID`=? AND `punishpoints` > 0", sqlQuery["duration"], accountNumber)
			for i, player in pairs(getElementsByType("player")) do
				if getElementData(player, "account:id") == tonumber(accountNumber) then
					local currentpoints = getElementData(player, "punishment:points")
					local points = currentpoints - tonumber(sqlQuery["duration"])
					if points < 0 then points = 0 end
					exports.anticheat:changeProtectedElementDataEx(player, "punishment:points", points, false)
					break
				end
			end		
		end

		mysql:query_free("DELETE FROM `adminhistory` WHERE `id`='".. mysql:escape_string(tostring(ID)) .."'")
		if source then
			outputChatBox("Admin history entry #"..ID.." removed", source, 0, 255, 0)
			exports.logs:dbLog("ac"..getElementData(source, "account:id"), 4,{"ac"..sqlQuery["user"], "ac"..sqlQuery["admin"]}, "HISTORY REMOVAL: CREATOR ID: "..sqlQuery["admin"].." TYPE: ".. sqlQuery["action"] .." - ".. sqlQuery["reason"])
		end
		mysql:free_result( sqlQuery )
	end
end
addEvent( "admin:removehistory", true)
addEventHandler( "admin:removehistory", getRootElement(), removeAdminHistoryLine )

addCommandHandler( "history",
	function( thePlayer, commandName, ... )
		if not (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
			if (...) then
				outputChatBox("Only Admins or Supporters can check other's player admin history.", thePlayer, 255, 0, 0)
				return false
			end
		end

		local targetPlayer = thePlayer
		if (...) then
			targetPlayer = exports.global:findPlayerByPartialNick(thePlayer, table.concat({...},"_"))
		end

		if targetPlayer then
			local logged = getElementData(targetPlayer, "loggedin")
			if (logged==0) then
				outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
			else
				triggerEvent("showAdminHistory", thePlayer, targetPlayer)
			end
		else
			local targetPlayerName = table.concat({...},"_")
			-- select by charactername
			local result = mysql:query("SELECT account FROM characters WHERE charactername = '" .. mysql:escape_string(targetPlayerName ) .. "'" )
			if result then
				if mysql:num_rows( result ) == 1 then
					local row = mysql:fetch_assoc(result)
					local id = row["account"] or '0'
					triggerEvent("showOfflineAdminHistory", thePlayer, id, targetPlayerName)
					mysql:free_result( result )
					return
				else
					-- select by account
					local targetPlayerName = table.concat({...}," ")
					local id = tonumber(exports.cache:getIdFromUsername(targetPlayerName))
					if id then
						triggerEvent("showOfflineAdminHistory", thePlayer, id, targetPlayerName)
						return
					end
				end
				mysql:free_result( result )
			end
			mysql:free_result( result )
			outputChatBox("Player not found or multiple were found.", thePlayer, 255, 0, 0)
		end
	end
)


addEvent("admin:showInventory", true)
addEventHandler("admin:showInventory", getRootElement(),
	function ()
		 executeCommandHandler( "showinv", client, getElementData(source, "playerid") )
	end
)

function addAdminHistory(user, admin, reason, action, duration)
	local user_char = "NULL"
	if tonumber(admin) == 0 then
		admin = "NULL"
	end
	if not action or not tonumber(action) then
		action = getHistoryAction(action)
	end
	if not action then
		action = 6
	end
	if not duration or not tonumber(duration) then
		duration = 0
	end
	if isElement(user) then
		user_char = getElementData(user, "dbid") or "NULL"
		user = getElementData(user, "account:id")
	end
	if isElement(admin) then
		admin = getElementData(admin, "account:id")
	end
	if not tonumber(user) or not (tonumber(admin) or tostring(admin) == "NULL") or not reason then
		return false
	end
	return mysql:query_free("INSERT INTO adminhistory SET admin="..admin..", user="..user..", user_char="..user_char..", action="..action..", duration="..duration..", reason='"..mysql:escape_string(reason).."' ")
end
