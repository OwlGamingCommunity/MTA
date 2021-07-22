mysql = exports.mysql
function setElementDataEx(theElement, theParameter, theValue, syncToClient, noSyncAtall)
	if syncToClient == nil then
		syncToClient = false
	end
	
	if noSyncAtall == nil then
		noSyncAtall = false
	end
	
	if tonumber(theValue) then
		theValue = tonumber(theValue)
	end
	
	exports.anticheat:changeProtectedElementDataEx(theElement, theParameter, theValue, syncToClient, noSyncAtall)
	return true
end


addEventHandler( "onResourceStart", getResourceRootElement(),
	function()
		-- delete all old wiretransfers
		mysql:query_free("DELETE FROM wiretransfers WHERE time < NOW() - INTERVAL 4 WEEK" )
	end
)

function showGeneralServiceGUI(atm, ped)
	local factions = getElementData(client, "faction")

	local fTable = {}	
	for k,v in pairs(factions) do
		if exports.factions:hasMemberPermissionTo(client, k, "manage_finance") then
			fTable[k] = v
		end
	end

	local deposit = true
	local withdraw = true
	local limit = 0
	
	--outputDebugString(money)
	--outputDebugString(exports.global:getMoney(client))
	triggerClientEvent(client, "showBankUI", getRootElement(), fTable, deposit, limit, withdraw, ped)
end
addEvent( "bank:showGeneralServiceGUI", true )
addEventHandler( "bank:showGeneralServiceGUI", getRootElement(), showGeneralServiceGUI )

function withdrawMoneyPersonal(amount)
	local state = tonumber(getElementData(client, "loggedin")) or 0
	if (state == 0) then
		return
	end
	
	local money = getElementData(client, "bankmoney") - amount
	if money >= 0 then
		exports.global:giveMoney(client, amount, true)
		
		setElementDataEx(client, "bankmoney", money, true)
		saveBank(client)
		
		mysql:query_free("INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. mysql:escape_string(getElementData(client, "dbid")) .. ", 0, " .. mysql:escape_string(amount) .. ", '', 0)" )

		outputChatBox("You withdrew $" .. exports.global:formatMoney(amount) .. " from your personal account.", client, 255, 194, 14)
		exports.logs:dbLog(client, 25, client, "WITHDRAW " .. amount.. " - REMAINING $"..money)
	else
		outputChatBox( "No.", client, 255, 0, 0 )
	end
end
addEvent("withdrawMoneyPersonal", true)
addEventHandler("withdrawMoneyPersonal", getRootElement(), withdrawMoneyPersonal)

function depositMoneyPersonal(amount)
	local state = tonumber(getElementData(client, "loggedin")) or 0
	if (state == 0) then
		return
	end
	if exports.global:takeMoney(client, amount, nil, true) then
			local money = getElementData(client, "bankmoney")
			setElementDataEx(client, "bankmoney", money+amount, true)
			saveBank(client)
			mysql:query_free("INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (0, " .. mysql:escape_string(getElementData(client, "dbid")) .. ", " .. mysql:escape_string(amount) .. ", '', 1)" )
			outputChatBox("You deposited $" .. exports.global:formatMoney(amount) .. " into your personal account.", client, 255, 194, 14)
			exports.logs:dbLog(client, 25, client, "DEPOSIT " .. amount.. " - REMAINING $"..money+amount)
	else
		outputChatBox("You don't have that amount in one sorted money item.", client, 255, 194, 14)
	end
end
addEvent("depositMoneyPersonal", true)
addEventHandler("depositMoneyPersonal", getRootElement(), depositMoneyPersonal)

function withdrawMoneyBusiness(amount, factionID)
	local state = tonumber(getElementData(client, "loggedin")) or 0
	if (state == 0) then
		return
	end
	
	local theTeam = exports.factions:getFactionFromID(factionID)
	if exports.global:takeMoney(theTeam, amount) then
		if exports.global:giveMoney(client, amount) then
			mysql:query_free("INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. mysql:escape_string(-getElementData(theTeam, "id")) .. ", " .. mysql:escape_string(getElementData(client, "dbid")) .. ", " .. mysql:escape_string(amount) .. ", '', 4)" ) 
			outputChatBox("You withdrew $" .. exports.global:formatMoney(amount) .. " from your business account.", client, 255, 194, 14)
			exports.logs:dbLog(client, 25, theTeam, "WITHDRAW FROM BUSINESS " .. amount)
		end
	end
end
addEvent("withdrawMoneyBusiness", true)
addEventHandler("withdrawMoneyBusiness", getRootElement(), withdrawMoneyBusiness)

function depositMoneyBusiness(amount, factionID)
	local state = tonumber(getElementData(client, "loggedin")) or 0
	if (state == 0) then
		return
	end
	if exports.global:takeMoney(client, amount) then
		local theTeam = exports.factions:getFactionFromID(factionID)
		if exports.global:giveMoney(theTeam, amount) then
			mysql:query_free("INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. mysql:escape_string(getElementData(client, "dbid")) .. ", " .. mysql:escape_string(-getElementData(theTeam, "id")) .. ", " .. mysql:escape_string(amount) .. ", '', 5)" )
			outputChatBox("You deposited $" .. exports.global:formatMoney(amount) .. " into your business account.", client, 255, 194, 14)
			exports.logs:dbLog(client, 25, theTeam, "DEPOSIT TO BUSINESS " .. amount)
		end
	else
	outputChatBox("You don't have that amount in one sorted money item.", client, 255, 194, 14)
	end
end
addEvent("depositMoneyBusiness", true)
addEventHandler("depositMoneyBusiness", getRootElement(), depositMoneyBusiness)

function transferMoneyToPersonal( fromFactionId, name, amount, reason )
	if getElementData( client, "loggedin" ) == 1 then
		-- validate and format amount.
		if not amount or not tonumber(amount) or tonumber(amount) <=0 then
			return not outputChatBox( "Invalid amount to transfer.", client, 255, 0, 0 )
		else
			amount = math.floor(tonumber(amount))
		end
		
		-- validate and format reason
		if not reason then
			reason = "N/A"
		end

		local sender = nil
		-- sending from faction bank.
		if fromFactionId then
			sender = exports.pool:getElement( 'team', fromFactionId )
			if not sender then 
				return not outputChatBox( "Transaction failed. Error Code: 147", client, 255, 0, 0 )
			end
		-- sending from personal bank.
		else
			sender = client
		end

		-- receiver must be found to continue.
		local receiver = getTeamFromName( name ) or getPlayerFromName( string.gsub(name," ","_") )
		local receiver_bank = nil
		local receiver_name = receiver and ( getElementType( receiver ) == 'player' and getPlayerName( receiver ) or getTeamName( receiver ) )

		-- if receiver not found, chance is that it's an offline player. Let's check that.
		if not receiver then
			local senderAccountID = getElementData(sender, "account:id") -- Adding this check so we can compare the sender and receiver account IDs.
			local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT id, bankmoney, charactername, account FROM characters WHERE charactername=? LIMIT 1 ", string.gsub( name," ","_" ) )
			local res, nums, _ = dbPoll( qh, 10000 )
			if res then
				if nums > 0 then
					receiver = res[1]['id']
					receiver_bank = res[1]['bankmoney']
					receiver_name = res[1]['charactername']

					if tonumber(res[1]['account']) == tonumber(senderAccountID) then -- Uh oh... bad boy!
						exports.global:sendWrnToStaff(exports.global:getPlayerFullIdentity(sender).." ("..getPlayerName(sender).." to "..receiver_name..") has attempted an ALT to ALT via bank transfer, but was stopped by script.", "ALT>ALT")
						return not outputChatBox( "You may not transfer money to one of your alternative characters.", client, 255, 0, 0 )
					end
				else
					return not outputChatBox( "Recipients not found with '"..name.."'. Try with a faction name or a character name.", client, 255, 0, 0 )
				end
			else
				dbFree( qh )
				return not outputChatBox( "Interal Error! Code: 169", client, 255, 0, 0 )
			end
		end

		-- sender must not be receiver, obviously.
		if sender == receiver then
			return not outputChatBox( "You can't wiretransfer money to yourself. ", client, 255, 0, 0 )
		end

		-- now take money from sender first.
		if hasBankMoney( sender, amount ) then
			if takeBankMoney( sender, amount ) then
				-- if receiver_bank is not null then, receiver must be an offline player.
				if receiver_bank then
					dbExec( exports.mysql:getConn('mta'), "UPDATE characters SET bankmoney=bankmoney+? WHERE id=?", amount, receiver )
				else
					if not giveBankMoney( receiver, amount ) then
						outputDebugString( "[BANK] Took bankmoney from sender, but unable to give receiver. Code 188." )
					end
				end
				
				-- logs
				local sender_dbid = getElementType( sender ) == 'player' and getElementData( sender, 'dbid' ) or -fromFactionId
				local receiver_dbid = receiver_bank and receiver or ( getElementType( receiver ) == 'player' and getElementData( receiver, 'dbid' ) or -getElementData( receiver, 'id' ) )
				addBankTransactionLog( sender_dbid, receiver_dbid, amount, fromFactionId and 3 or 2, reason )
				local sender_name = getElementType( sender ) == 'player' and getPlayerName( sender ) or getTeamName( sender )
				local famount = exports.global:formatMoney( amount )
				exports.logs:dbLog( client, 25, { sender, isElement( receiver ) and receiver or "ch" .. receiver_dbid }, "TRANSFERRED $"..famount.." FROM "..sender_name.." TO " .. receiver_name )
				return outputChatBox("You transferred $" .. famount .. " from your "..(fromFactionId and "business" or "personal").." account to "..receiver_name..".", client, 255, 194, 14)
			else
				return not outputChatBox("Interal Error! Code 197", client, 255, 0, 0 )
			end
		else
			return not outputChatBox("Transaction failed. Insufficient balance.", client, 255,0, 0)
		end
	end
end
addEvent("transferMoneyToPersonal", true)
addEventHandler("transferMoneyToPersonal", getRootElement(), transferMoneyToPersonal)

-- TRANSACTION HISTORY STUFF

--[[
	Transaction Types:
	0: Withdraw Personal
	1: Deposit Personal
	2: Transfer from Personal to Personal
	3: Transfer from Business to Personal
	4: Withdraw Business
	5: Deposit Business
	6: Wage/State Benefits
	7: everything in payday except Wage/State Benefits
	8: faction budget
	9: fuel
	10: repair
	11: Taxes
	12: Bank Interest
	13: Sales
	14: Insurance
	15: Supplies
	16: Impound
]]

function tellTransfersPersonal(cardInfo)
	local dbid = getElementData(client, "dbid")
	if cardInfo then
		dbid = cardInfo
	end
	tellTransfers(client, dbid, "recievePersonalTransfer")
end

function tellTransfersBusiness(name)
	local dbid = exports.factions:getFactionIDFromName(name)
	--local dbid = tonumber(getElementData(getPlayerTeam(client), "id")) or 0
	if dbid > 0 then
		tellTransfers(client, -dbid, "recieveBusinessTransfer")
	end
end

function tellTransfers(source, dbid, event)
	local where = ""
	if type(dbid) == "table" then
		where = "( ( `from` = (SELECT `card_owner` FROM `atm_cards` WHERE `card_number` = '" .. dbid[2] .. "' LIMIT 1) ) OR (`to` = (SELECT `card_owner` FROM `atm_cards` WHERE `card_number` = '" .. dbid[2] .. "' LIMIT 1) ) )"
	else
		where = "( `from` = " .. dbid .. " OR `to` = " .. dbid .. " )"
	end
	
	if tonumber(dbid) and dbid < 0 then
		where = where .. " AND type != 6" -- skip paydays for factions 
	else
		where = where .. " AND type != 4 AND type != 5" -- skip stuff that's not paid from bank money
	end
	
	-- `w.time` - INTERVAL 1 hour as 'newtime'
	-- hour correction
	
	local query = mysql:query("SELECT w.*, c.charactername as characterfrom, c2.charactername as characterto,w.`time` as 'newtime' FROM wiretransfers w LEFT JOIN characters c ON c.id = `from` LEFT JOIN characters c2 ON c2.id = `to` WHERE "..where.." ORDER BY id DESC LIMIT 40;")
	if query then
		local continue = true
		while continue do
			row = mysql:fetch_assoc(query)
			if not row then break end
			
			local id = tonumber(row["id"])
			local amount = tonumber(row["amount"])
			local time = row["newtime"]
			local type = tonumber(row["type"])
			local reason = row["reason"]
			if reason == mysql_null() then
				reason = ""
			end
			
			local from, to = "-", "-"
			if row["characterfrom"] ~= mysql_null() then
				from = row["characterfrom"]:gsub("_", " ")
				if row["from_card"] ~= mysql_null() then
					from = from.." ("..row["from_card"]..")"
				end
			elseif tonumber(row["from"]) then
				num = tonumber(row["from"]) 
				if num < 0 then
					local theTeam = exports.pool:getElement("team", -num)
					from = theTeam and getTeamName(exports.pool:getElement("team", -num)) or "-"
				elseif num == 0 and ( type == 6 or type == 7 ) then
					from = "Government"
				end
			end
			if row["characterto"] ~= mysql_null() then
				to = row["characterto"]:gsub("_", " ")
				if row["to_card"] ~= mysql_null() then
					to = to.." ("..row["to_card"]..")"
				end
			elseif tonumber(row["to"]) and tonumber(row["to"]) < 0 then
				local theTeam = exports.pool:getElement("team", -tonumber(row["to"]))
				if theTeam then
					to = getTeamName(theTeam)
				end
			end
				
			if amount > 0 then
				if tonumber(dbid) then  -- Not ATM
					if tostring(row["from"]) == tostring(dbid) then
						amount = -amount
					end
				elseif tostring(row["from_card"]) == tostring(dbid[2]) or tostring(row["from"]) == tostring(dbid[4])  then
					amount = -amount
				end 
			end
			
			
			--if type >= 2 and type <= 5 and tonumber(row['from']) == dbid then
			--	amount = -amount
			--end
			
			--[[if amount < 0 then
				amount = "-$" .. -amount
			else
				amount = "$" .. amount
			end]]
			local details = "-"
			if row["details"] ~= mysql_null() then
				details = row["details"]
			end
			triggerClientEvent(source, event, source, id, amount, time, type, from, to, reason, details, dbid)
		end
		mysql:free_result(query)
	else
		outputDebugString("Mysql error @ s_bank_system.lua\tellTransfers", 2)
	end
end

addEvent("tellTransfersPersonal", true)
addEventHandler("tellTransfersPersonal", getRootElement(), tellTransfersPersonal)

addEvent("tellTransfersBusiness", true)
addEventHandler("tellTransfersBusiness", getRootElement(), tellTransfersBusiness)

function addBankTransactionLog(fromAccount, toAccount, amount, type, reason, details, fromCard, toCard)
	if not amount or not tonumber(amount) or not type or not tonumber(type) or fromAccount == toAccount then
		return false
	end

	local sql = "INSERT INTO wiretransfers SET `amount` = '"..amount.."', type = '"..type.."' "
	if fromAccount then
		sql = sql..", `from` = '"..exports.global:toSQL(fromAccount).."' "
	end
	if fromCard then
		sql = sql..", `from_card` = '"..exports.global:toSQL(fromCard).."' "
	end
	if toCard then
		sql = sql..", `to_card` = '"..exports.global:toSQL(toCard).."' "
	end
	if toAccount then
		sql = sql..", `to` = '"..exports.global:toSQL(toAccount).."' "
	end 
	if reason then
		sql = sql..", `reason` = '"..exports.global:toSQL(reason).."' "
	end
	if details then
		sql = sql..", `details` = '"..exports.global:toSQL(details).."' "
	end

	return mysql:query_free(sql) 
end
addEvent("addBankTransactionLog", true)
addEventHandler("addBankTransactionLog", getRootElement(), addBankTransactionLog)


--MAXIME
function hasBankMoney(thePlayer, amount)
	amount = tonumber(amount) 
	amount = math.floor(math.abs(amount))
	if getElementType(thePlayer) == "player" then
		return getElementData(thePlayer, "bankmoney") >= amount
	elseif getElementType(thePlayer) == "team" then
		return getElementData(thePlayer, "money") >= amount
	end
end

function takeBankMoney(thePlayer, amount, force)
	amount = tonumber(amount)
	amount = math.floor(math.abs(amount))
	if not force and not hasBankMoney(thePlayer, amount) then
		return false, "Lack of money in bank"
	end
	if getElementType(thePlayer) == "player" then
		return setElementDataEx(thePlayer, "bankmoney", getElementData(thePlayer, "bankmoney")-amount, true) and mysql:query_free("UPDATE `characters` SET `bankmoney`=bankmoney-"..amount.." WHERE `id`='"..getElementData(thePlayer, "dbid").."' ") 
	elseif getElementType(thePlayer) == "team" then
		return setElementDataEx(thePlayer, "money", getElementData(thePlayer, "money")-amount, true) and mysql:query_free("UPDATE `factions` SET `bankbalance`=bankbalance-"..amount.." WHERE `id`='"..getElementData(thePlayer, "id").."' ") 
	end
end

function giveBankMoney(thePlayer, amount)
	if not thePlayer then return end
	amount = tonumber(amount)
	amount = math.floor(math.abs(amount))
	if getElementType(thePlayer) == "player" then
		return setElementDataEx(thePlayer, "bankmoney", getElementData(thePlayer, "bankmoney")+amount, true) and mysql:query_free("UPDATE `characters` SET `bankmoney`=bankmoney+"..amount.." WHERE `id`='"..getElementData(thePlayer, "dbid").."' ") 
	elseif getElementType(thePlayer) == "team" then
		return setElementDataEx(thePlayer, "money", getElementData(thePlayer, "money")+amount, true) and mysql:query_free("UPDATE `factions` SET `bankbalance`=bankbalance+"..amount.." WHERE `id`='"..getElementData(thePlayer, "id").."' ") 
	end
end

function setBankMoney(thePlayer, amount)
	amount = tonumber(amount)
	amount = math.floor(math.abs(amount))
	if getElementType(thePlayer) == "player" then
		return setElementDataEx(thePlayer, "bankmoney", amount, true) and mysql:query_free("UPDATE `characters` SET `bankmoney`="..amount.." WHERE `id`='"..getElementData(thePlayer, "dbid").."' ") 
	elseif getElementType(thePlayer) == "team" then
		return setElementDataEx(thePlayer, "money", amount, true) and mysql:query_free("UPDATE `factions` SET `bankbalance`="..amount.." WHERE `id`='"..getElementData(thePlayer, "id").."' ") 
	end
end
