--Maxime / 2015.02.27
local mysql = exports.mysql
local opc = outputChatBox
local function outputChatBox(msg, t, r,g,b)
	if not r then
		r, g, b = 255, 194, 14
	end
	return opc(msg, t or root, r, g, b)
end

local function printWhoisCharacters(target, data)
	for i, char in ipairs(data) do
		local isOnline = exports.global:findPlayerByPartialNick(target, char.charactername, true)
		outputChatBox("#"..i..": "..(char.charactername and string.gsub(char.charactername, "_", " ") or "N/A").." - "..(isOnline and "Online" or ("Last seen: "..char.lastloginago.." day(s) ago")).." - hoursplayed: ".. char.hoursplayed..", money: $"..exports.global:formatMoney(char.money)..", bank: $"..exports.global:formatMoney(char.bankmoney)..(char.active=="0" and " (Deactivated)" or ""), target)
	end
end

local function queryWhoisCharacter(clue, type)
	local sql = "SELECT id, charactername, account, money, bankmoney, gender, age, hoursplayed,"
	.."DATEDIFF(NOW(), `lastlogin`) AS `lastloginago`, active FROM characters WHERE "
	local chars = {}
	if type == "userid" then
		sql = sql.. "account = "..mysql:escape_string(clue)
	end
	sql = sql .. " ORDER BY lastlogin"
	local q = mysql:query(sql)
	while q do
		local char = mysql:fetch_assoc(q)
		if not char then break end
		table.insert(chars, char)
	end
	mysql:free_result(q)
	return chars
end

local function printWhoisAccount(target, data, forceShowChars)
	for i, acc in ipairs(data) do
		outputChatBox("----------------RESULT #"..i.."----------------", target)
		outputChatBox("-Username: "..(acc.username or "N/A"), target)
		outputChatBox("-Email: "..(acc.email or "N/A"), target)
		outputChatBox("-Registration Date: "..(acc.registerdate or "N/A"), target)
		outputChatBox("-Last login: "..(acc.lastlogin and (acc.lastlogin.." ("..acc.lastloginago.." days ago)") or "N/A"), target)
		outputChatBox("-Serial: "..(acc.mtaserial or "N/A"), target)
		outputChatBox("-IP: "..(acc.ip or "N/A"), target)
		outputChatBox("-Monitor: "..(acc.monitored or "N/A"), target)
		outputChatBox("-Total Characters: "..(acc.totalchars or "N/A"), target)
		if tonumber(acc.totalchars) > 0 and (#data == 1 or forceShowChars) then
			printWhoisCharacters(target, queryWhoisCharacter(acc.id, "userid"))
		end
	end
end

local function queryWhoisAccount(clue, type)
	local sql = "SELECT id, username, email, DATE_FORMAT(registerdate,'%b %d, %Y at %h:%i %p') AS `registerdate`, DATE_FORMAT(lastlogin,'%b %d, %Y at %h:%i %p') AS `lastlogin`, "
	.."DATEDIFF(NOW(), `lastlogin`) AS `lastloginago`, ip, mtaserial, monitored, (SELECT COUNT(*) FROM characters WHERE account=accounts.id) AS `totalchars` FROM accounts WHERE "
	if type == "userid" then
		sql = sql.. "id = "..mysql:escape_string(clue)
		return {mysql:query_fetch_assoc(sql)}
	elseif type == "username" then
		sql = sql.." username LIKE '%"..mysql:escape_string(clue).."%' LIMIT 5"
		local results = {}
		local q = mysql:query(sql)
		while q do
			local result = mysql:fetch_assoc(q)
			if not result then break end
			for k, v in pairs( result ) do
				if v == mysql_null() then
					result[k] = nil
				else
					result[k] = tonumber(result[k]) or result[k]
				end
			end
			table.insert(results, result)
		end
		mysql:free_result(q)
		return results
	elseif type == "charactername" then
		sql = "SELECT a.id, username, email, DATE_FORMAT(registerdate,'%b %d, %Y at %h:%i %p') AS `registerdate`, DATE_FORMAT(a.lastlogin,'%b %d, %Y at %h:%i %p') AS `lastlogin`,"..
"DATEDIFF(NOW(), a.lastlogin) AS `lastloginago`, ip, mtaserial, monitored, (SELECT COUNT(*) FROM characters WHERE account=a.id) AS `totalchars` FROM accounts a LEFT JOIN characters c ON a.id=c.account WHERE charactername LIKE '%"..mysql:escape_string(clue).."%' GROUP BY a.id LIMIT 5;"
		local results = {}
		local q = mysql:query(sql)
		while q do
			local result = mysql:fetch_assoc(q)
			if not result then break end
			for k, v in pairs( result ) do
				if v == mysql_null() then
					result[k] = nil
				else
					result[k] = tonumber(result[k]) or result[k]
				end
			end
			table.insert(results, result)
		end
		mysql:free_result(q)
		return results
	elseif type == "serial" then
		sql = sql.." mtaserial = '"..mysql:escape_string(clue).."' LIMIT 5"
		local results = {}
		local q = mysql:query(sql)
		while q do
			local result = mysql:fetch_assoc(q)
			if not result then break end
			for k, v in pairs( result ) do
				if v == mysql_null() then
					result[k] = nil
				else
					result[k] = tonumber(result[k]) or result[k]
				end
			end
			table.insert(results, result)
		end
		mysql:free_result(q)
		return results
	elseif type == "ip" then
		sql = sql.." ip = '"..mysql:escape_string(clue).."' LIMIT 5"
		local results = {}
		local q = mysql:query(sql)
		while q do
			local result = mysql:fetch_assoc(q)
			if not result then break end
			for k, v in pairs( result ) do
				if v == mysql_null() then
					result[k] = nil
				else
					result[k] = tonumber(result[k]) or result[k]
				end
			end
			table.insert(results, result)
		end
		mysql:free_result(q)
		return results
	end
end

function awhois(thePlayer, cmd, type, ...)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		if not type or not (...) then
			outputChatBox("SYNTAX: /" .. cmd .. " [Type] [Clue]", thePlayer, 255, 194, 14)
			outputChatBox("[Type]: Type of the clue you're tracing for.", thePlayer, 255, 194, 14)
			outputChatBox("   0 : in online players by partial charactername or ID", thePlayer, 255, 194, 14)
			outputChatBox("   1 : by partial username.", thePlayer, 255, 194, 14)
			outputChatBox("   2 : by partial charactername.", thePlayer, 255, 194, 14)
			outputChatBox("   3 : by serial.", thePlayer, 255, 194, 14)
			outputChatBox("   4 : by IP.", thePlayer, 255, 194, 14)
			outputChatBox("[Clue]: Info you got to start tracing.", thePlayer, 255, 194, 14)
			return false
		end
		local clue = table.concat({...}, " ")
		clue = tonumber(clue) or clue
		local counter = nil
		if type == "0" then
			local target = exports.global:findPlayerByPartialNick(thePlayer,clue)
			if target then
				local account = getElementData(target, "account:id")
				if account then
					outputChatBox("[1 result(s) found in online players by partial charactername or ID '"..clue.."']", thePlayer)
					printWhoisAccount(thePlayer, queryWhoisAccount(account, "userid"), true)
				end
			end
		elseif type == "1" then 
			local results = queryWhoisAccount(clue, "username")
			outputChatBox("["..(#results >=5 and "5+" or #results).." result(s) found by partial username '"..clue.."']", thePlayer)
			printWhoisAccount(thePlayer, results, true)
		elseif type == "2" then
			clue = string.gsub(clue, " ", "_")
			local results = queryWhoisAccount(clue, "charactername")
			outputChatBox("["..(#results >=5 and "5+" or #results).." result(s) found by partial charactername '"..clue.."']", thePlayer)
			printWhoisAccount(thePlayer, results)
		elseif type == "3" then
			local results = queryWhoisAccount(clue, "serial")
			outputChatBox("["..(#results >=5 and "5+" or #results).." result(s) found by serial '"..clue.."']", thePlayer)
			printWhoisAccount(thePlayer, results)
		elseif type == "4" then
			local results = queryWhoisAccount(clue, "ip")
			outputChatBox("["..(#results >=5 and "5+" or #results).." result(s) found by IP adddress '"..clue.."']", thePlayer)
			printWhoisAccount(thePlayer, results)
		end
	end
end
--addCommandHandler( "trace", awhois )
--addCommandHandler( "awhois", awhois )


local function showIPAlts(thePlayer, ip)
	dbQuery(
		function(qh, thePlayer, ip)
			local result1 = dbPoll(qh, 0)
			if result1 and #result1 > 0 then
				local result = mysql:query("SELECT `appstate`, `lastlogin` FROM `account_details` WHERE `account_id` = '" .. mysql:escape_string(result1[1].id) .. "' ORDER BY `account_id` ASC" )
				if result then
					local count = 0
					
					outputChatBox( " IP Address: " .. ip, thePlayer)
					while true do
						local row = mysql:fetch_assoc(result)
						if not row then break end
						
						if result1["lastlogin"] == mysql_null() then
							result1["lastlogin"] = "Never"
						end
						
						local text = " #" .. count .. ": " .. tostring(result1[1]["username"])
						
						if tonumber( row["appstate"] ) < 3 then
							text = text .. " (Awaiting App)"
						end
						
						outputChatBox( text, thePlayer)
						
						count = count + 1
					end
					mysql:free_result( result )
				else
					outputChatBox( "Error #9101 - Report on Forums", thePlayer, 255, 0, 0)
				end
			end
		end, {thePlayer, ip}, mysql:getConn("core"), "SELECT `id`, `username` FROM `accounts` WHERE `ip`=? LIMIT 1", ip)
end


function findAltAccIP(thePlayer, commandName, ...)
	if exports.integration:isPlayerTrialAdmin( thePlayer ) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick]", thePlayer, 255, 194, 14)
		else
			local targetPlayerName = table.concat({...}, "_")
			local targetPlayer = exports.global:findPlayerByPartialNick(nil, targetPlayerName)

			if not targetPlayer or getElementData( targetPlayer, "loggedin" ) ~= 1 then
				outputChatBox("Begining output..", thePlayer, 255, 194, 14)
				-- select by charactername
				local char_result = mysql:query_fetch_assoc("SELECT account FROM characters WHERE charactername='"..mysql:escape_string(targetPlayerName).."'")
				if char_result and char_result["account"] then
					dbQuery(function(qh, thePlayer)
						local result = dbPoll(qh, 0)
						if result then
							if #result == 1 then
								local ip = result[1]["ip"] or '0.0.0.0'
								showIPAlts( thePlayer, ip )
								return
							end
						else
							dbFree(qh)
						end
					end, {thePlayer}, mysql:getConn("core"), "SELECT ip FROM accounts WHERE id=? LIMIT 1", char_result["account"] )
					mysql:free_result(char_result)
				end
				
				targetPlayerName = table.concat({...}, " ")
				
				-- select by accountname
				dbQuery(function(qh, thePlayer)
					local result = dbPoll(qh, 0)
					if result then
						if #result >= 1 then
							local ip = result[1]["ip"] or '0.0.0.0'
							showIPAlts( thePlayer, ip )
							return
						end
					else
						dbFree(qh)
					end
				end, {thePlayer}, mysql:getConn("core"), "SELECT ip FROM accounts WHERE username = ?", targetPlayerName )
				
				-- select by ip
				dbQuery(function(qh, thePlayer)
					local result = dbPoll(qh, 0)
					if result then
						if #result >= 1 then
							local ip = result[1]["ip"] or '0.0.0.0'
							showIPAlts( thePlayer, ip )
							return
						end
					else
						dbFree(qh)
					end
				end, {thePlayer}, mysql:getConn("core"), "SELECT ip FROM accounts WHERE ip = ?", targetPlayerName )

				outputChatBox("Done.", thePlayer, 255, 194, 14)
			else -- select by online player
				showIPAlts( thePlayer, getPlayerIP(targetPlayer) )
			end
		end
	end
end
addCommandHandler( "findip", findAltAccIP )
-- END FIND IP --

-- START FINDALTS --
local function showAlts(thePlayer, id, creation)
	result = mysql:query("SELECT `id`, `charactername`, `cked`, `lastlogin`, `creationdate`, `hoursplayed`, `active` FROM `characters` WHERE `account` = '" .. mysql:escape_string(id) .. "' ORDER BY `charactername` ASC" )
	if result then
		local name = mysql:query_fetch_assoc("SELECT `appstate` FROM `account_details` WHERE `account_id` = '" .. mysql:escape_string(id) .. "'" )
		if name then
			local uname = exports.cache:getUsernameFromId(id)
			if uname then
				
				
				outputChatBox( "WHOIS " .. uname .. ": ", thePlayer, 255, 194, 14 )
				
				
				if (tonumber(name["appstate"])) < 3 then
					outputChatBox( "This account didn't pass an application yet.", thePlayer, 255, 0, 0 )	
				end
			else
				outputChatBox( "?", thePlayer )
			end
		else
			outputChatBox( "?", thePlayer )
		end
		
		local count = 0
		while true do
			local row = mysql:fetch_assoc(result)
			if not row then break end
		
			count = count + 1
			local r = 255
			if getPlayerFromName( row["charactername"] ) then
				r = 0
			end
			
			local text = "#" .. count .. ": " .. row["charactername"]:gsub("_", " ")
			if tonumber( row["cked"] ) == 1 then
				text = text .. " (Missing)"
			elseif tonumber( row["cked"] ) == 2 then
				text = text .. " (Buried)"
			end
			
			if row['lastlogin'] ~= mysql_null() then
				text = text .. " - " .. tostring( row['lastlogin'] )
			end
			
			if creation and row['creationdate'] ~= mysql_null() then
				text = text .. " - Created " .. tostring( row['creationdate'] )
			end

			if exports.integration:isPlayerAdmin( thePlayer ) then -- Maxime | Hide faction from Trial and below
				showingFactions = false
				local factions = mysql:query("SELECT faction_id FROM characters_faction WHERE character_id="..tonumber(row["id"]))
				while true do
					local row1 = mysql:fetch_assoc(factions)
					if not row1 then break end

					if not showingFactions then
						text = text .. " - Factions: "
						showingFactions = true 
					end

					local faction = tonumber(row1["faction_id"])
					if faction then
						text = text .. faction .. ","
					end
				end
				mysql:free_result( factions )
			end
			
			local hours = tonumber(row.hoursplayed)
			local newhours = tonumber(row.hoursplayed) + tonumber(row.hoursplayed)
			--outputDebugString(newhours)
			if hours and hours > 0 then
				text = text .. " - " .. hours .. " hours"
			end
			local activated = tonumber(row.active)
			if activated then
				if activated == 0 then
					text = text .. " (Deactivated)"
				end
			end
			outputChatBox( text, thePlayer, r, 255, 0)
		end
		mysql:free_result( result )
	else
		outputChatBox( "Error #9102 - Report on Forums", thePlayer, 255, 0, 0)
	end
end

function findAltChars(thePlayer, commandName, ...)
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerSupporter( thePlayer ) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick]", thePlayer, 255, 194, 14)
		else
			local creation = commandName == "findalts2"
			local targetPlayerName = table.concat({...}, "_")
			local targetPlayer = targetPlayerName == "*" and thePlayer or exports.global:findPlayerByPartialNick(nil, targetPlayerName)
			
			if not targetPlayer or getElementData( targetPlayer, "loggedin" ) ~= 1 then
				-- select by character name
				local result = mysql:query("SELECT account FROM characters WHERE charactername = '" .. mysql:escape_string(targetPlayerName ) .. "'" )
				if result then
					if mysql:num_rows( result ) == 1 then
						local row = mysql:fetch_assoc(result)
						local id = tonumber( row["account"] ) or 0
						mysql:free_result( result )
						showAlts( thePlayer, id, creation )
						return
					end
					mysql:free_result( result )
				end
				
				targetPlayerName = table.concat({...}, " ")
				
				-- select by account name
				local id = exports.cache:getIdFromUsername(targetPlayerName)
				if id then
					showAlts( thePlayer, id, creation )
					return
				end
				
				outputChatBox("Player not found or multiple were found.", thePlayer, 255, 0, 0)
			else
				local id = getElementData( targetPlayer, "account:id" )
				if id then
					showAlts( thePlayer, id, creation )
				else
					outputChatBox("Game Account is unknown.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler( "findalts", findAltChars )
addCommandHandler( "findalts2", findAltChars )
-- END FINDALTS --

-- START FINDSERIAL --
local function showSerialAlts(thePlayer, serial)
	result = mysql:query("SELECT `account_id`, `lastlogin`, `appstate` FROM `account_details` WHERE mtaserial = '" .. mysql:escape_string(serial) .. "'" )
	if result then
		local count = 0
		local continue = true
		while continue do
			local row = mysql:fetch_assoc(result)
			if not row then break end
			count = count + 1
			if (count == 1) then
				outputChatBox( " Serial: " .. serial, thePlayer)
			end
			local username = exports.cache:getUsernameFromId(row["account_id"])
			local text = "#" .. count .. ": " .. username
			
			if tonumber( row["appstate"] ) < 3 then
				text = text .. " (Application not passed)"
			end

			outputChatBox( text, thePlayer)
		end
		mysql:free_result( result )
	else
		outputChatBox( "Error #9101 - Report on bugs.owlgaming.net", thePlayer, 255, 0, 0)
	end
end

function findAltAccSerial(thePlayer, commandName, ...)
	if exports.integration:isPlayerTrialAdmin( thePlayer ) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Nick/Serial]", thePlayer, 255, 194, 14)
		else
			local targetPlayerName = table.concat({...}, "_")
			local targetPlayer = exports.global:findPlayerByPartialNick(nil, targetPlayerName)
			
			if not targetPlayer then --or getElementData( targetPlayer, "loggedin" ) ~= 1 then
				outputChatBox("Begining output..", thePlayer, 255, 194, 14)
				
				-- select by charactername
				local result = mysql:query("SELECT a.`mtaserial` FROM `characters` c LEFT JOIN `account_details` a on c.`account`=a.`account_id` WHERE c.`charactername` = '" .. mysql:escape_string(targetPlayerName ) .. "'" )
				if result then
					if mysql:num_rows( result ) == 1 then
						local row = mysql:fetch_assoc(result)
						local serial = row["mtaserial"] or 'UnknownSerial'
						mysql:free_result( result )
						showSerialAlts( thePlayer, serial )
						return
					end
					mysql:free_result( result )
				end
				
				targetPlayerName = table.concat({...}, " ")
				
				-- select by accountname
				local acc_id = exports.cache:getIdFromUsername(targetPlayerName)
				if acc_id then
					local result = mysql:query("SELECT `mtaserial` FROM `account_details` WHERE `account_id` = '" .. mysql:escape_string(acc_id ) .. "'" )
					if result then
						if mysql:num_rows( result ) == 1 then
							local row = mysql:fetch_assoc(result)
							local serial = row["mtaserial"] or 'UnknownSerial'
							mysql:free_result( result )
							showSerialAlts( thePlayer, serial)
							return
						end
						mysql:free_result( result )
					end
				end
				
				-- select by ip
				dbQuery(function(qh, thePlayer)
					local result = dbPoll(qh, 0)
					if result and #result > 0 then
						local result = mysql:query("SELECT `mtaserial` FROM `account_details` WHERE `account_id` = '" .. result[1].id .. "'" )
						if result then
							if mysql:num_rows( result ) >= 1 then
								local row = mysql:fetch_assoc(result)
								local serial = row["mtaserial"] or 'UnknownSerial'
								mysql:free_result( result )
								showSerialAlts( thePlayer, serial )
								return
							end
							mysql:free_result( result )
						end
					else
						dbFree(qh)
					end
				end, {thePlayer}, mysql:getConn("core"), "SELECT `id` FROM accounts WHERE ip=?", targetPlayerName)

				
				-- select by serial
				local result = mysql:query("SELECT `mtaserial` FROM `account_details` WHERE `mtaserial` = '" .. mysql:escape_string( targetPlayerName ) .. "'" )
				if result then
					if mysql:num_rows( result ) >= 1 then
						local row = mysql:fetch_assoc(result)
						local serial = row["mtaserial"] or 'UnknownSerial'
						mysql:free_result( result )
						showSerialAlts( thePlayer, serial )
						return
					end
					mysql:free_result( result )
				end
				
				outputChatBox("Done.", thePlayer, 255, 194, 14)
			else -- select by online player
				showSerialAlts( thePlayer, getPlayerSerial(targetPlayer) )
			end
		end
	end
end
addCommandHandler( "findserial", findAltAccSerial )
-- END FINDSERIAL --