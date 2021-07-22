mysql = exports.mysql

function checkTicket(thePlayer, theCommand)
	local logged = getElementData(thePlayer, "loggedin")
	local playerID = getElementData(thePlayer, "playerid")
	if (logged==1) then
		if not isPedInVehicle(thePlayer) then
			outputChatBox("You must be in a vehicle to check if there is any unpaid tickets.", thePlayer, 255, 0, 0)
		else
			local vehicle = getPedOccupiedVehicle(thePlayer)
			local carID = getElementData(vehicle, "dbid")
			local model = getElementModel(vehicle)
			local mQuery = mysql:query("SELECT `id`, `reason`, `amount`, `issuer`, `time` FROM `pd_tickets` WHERE `vehid`='"..mysql:escape_string(carID).."' ORDER BY `id` ASC")
			outputChatBox(">>> Start of Tickets <<<", thePlayer, 17, 77, 207)
			while true do
				local row = mysql:fetch_assoc(mQuery)
				if not row then break end
				local issuerName = exports['cache']:getCharacterName(row["issuer"])
				if issuerName == false then
					issuerName = "Unknown"
				end
				if tonumber(row["amount"]) >= 0 then
					outputChatBox("TICKET #" ..tostring(row["id"]), thePlayer, 237, 240, 239)
					outputChatBox("Issued by: " ..issuerName, thePlayer, 237, 240, 239)
					outputChatBox("Time issued: " ..row["time"], thePlayer, 237, 240, 239)
					outputChatBox("Amount: $" ..row["amount"], thePlayer, 237, 240, 239)
					outputChatBox("Reason: " ..row["reason"], thePlayer, 237, 240, 239)
					outputChatBox(" ", thePlayer)
				end
			end
			mysql:free_result(mQuery)
			outputChatBox(" >> None", thePlayer, 237, 240, 239)
			outputChatBox("You can pay these tickets at your local Department of Motor Vehicles. (( /payticket [ID] ))", thePlayer)
			outputChatBox(">>> End of Tickets <<<", thePlayer, 17, 77, 207)
		end
	end
end
addCommandHandler("tickets", checkTicket)

function payTicket(thePlayer, theCommand, id)
	local logged = getElementData(thePlayer, "loggedin")
		if (logged==1) then
		if not id or not (tonumber(id)) then
			outputChatBox("SYNTAX: /"..theCommand.." [ticketID]", thePlayer, 255, 194, 14)
		else
			local mQuery = mysql:query("SELECT `reason`, `amount`, `issuer` FROM `pd_tickets` WHERE `id`='"..mysql:escape_string(id).."' ORDER BY `id` ASC")
				local row = mysql:fetch_assoc(mQuery)
				if not row then 
					outputChatBox("[ERR-424-001-34324]", thePlayer, 255, 0, 0)
				else
				local amount = tonumber(row["amount"])
				local issuerCharID = tonumber(row["issuer"])
				local issuer = exports['cache']:getCharacterName(row["issuer"])
				local reason = tostring(row["reason"])
				mysql:free_result(mQuery) -- We got all the info we need, let's set free this query! Good luck with life, mQuery!
				local money = exports.global:getMoney(thePlayer)
				local bankmoney = getElementData(thePlayer, "bankmoney")
				local takeFromCash = math.min( money, amount )
				local takeFromBank = amount - takeFromCash
				exports.global:takeMoney(thePlayer, takeFromCash)
				local tax = exports.global:getTaxAmount()
			local qWeimy = mysql:query("SELECT `faction_id` FROM `characters` WHERE `id` ='"..issuerCharID.."'")
				local faggot = mysql:fetch_assoc(qWeimy)
				if not faggot then
					outputChatBox("[ERR-FGGT-WEIMY-034]", thePlayer, 255, 0, 0)
				else
				local issuerFaction = 1
					issuerFaction = tonumber(faggot["faction_id"])
				if issuerFaction == 4 then
					issuerFaction = "326 Enterprises"
				elseif issuerFaction == 1 then
					issuerFaction = "Los Santos Police Department"
				else
					issuerFaction = "San Andreas State Police"
				end
					mysql:free_result(mWeimy) -- Since we don't need this fucking faggot query anymore, we release him into the free.
					exports.global:giveMoney( getTeamFromName(issuerFaction), math.ceil((1-tax)*amount) )
					exports.global:giveMoney( getTeamFromName("Government of Los Santos"), math.ceil(tax*amount) )
					mysql:query_free("DELETE FROM `pd_tickets` WHERE `id`='"..mysql:escape_string(id).."'")
					outputChatBox("You have paid ticket #" ..id.." for the amount of $"..amount..".", thePlayer, 0, 255, 0)
					outputChatBox("The ticket you paid was issued to you by "..issuer.. " on behalf of " ..issuerFaction, thePlayer, 0, 255, 0)
					if takeFromBank > 0 then
						outputChatBox("Since you don't have enough money with you, $" .. exports.global:formatMoney(takeFromBank) .. " have been taken from your bank account.", thePlayer)
						exports.anticheat:changeProtectedElementDataEx(thePlayer, "bankmoney", bankmoney - takeFromBank, false)
					end
				end
			end
		end
	end
end
addCommandHandler("payticket", payTicket)

function issueTicket(thePlayer, theCommand, theVehicle, amount, ...)
	local logged = getElementData(thePlayer, "loggedin")
	if (logged==1) then
		local issuerID = getElementData(thePlayer, "account:character:id")
		local team = getPlayerTeam(thePlayer)
		if (getTeamName(team) == "Los Sa326 Enterprises(getTeamName(team) == "Los Santos Police Department") or (getTeamName(team) == "San Andreas State Police") then
			if not (theVehicle) or not (amount) or not (tonumber(theVehicle)) or not (tonumber(amount)) or not (...) then
				outputChatBox("SYNTAX: /" ..theCommand.. " [vehID] [amount] [reason]", thePlayer, 255, 194, 14)
			else
				local reason = table.concat( { ... }, " " )
				mysql:query_free("INSERT INTO `pd_tickets` (`reason`, `vehid`, `amount`, `issuer`, `time`) VALUES ('".. mysql:escape_string(reason) .."', "..mysql:escape_string(theVehicle)..", "..mysql:escape_string(amount)..", "..mysql:escape_string(issuerID)..", NOW() - interval 1 hour)")
				outputChatBox(" >>> Ticket successfully issued.", thePlayer, 0, 255, 0)
				local teamMembers = getPlayersInTeam(team)
				local charname = getPlayerName(thePlayer):gsub("_", " ")
				local factionID = getElementData(thePlayer, "faction")
				local factionRank = getElementData(thePlayer, "factionrank")
				local factionRanks = getElementData(team, "ranks")
				local factionRankTitle = factionRanks[factionRank]
				for key, value in ipairs(teamMembers) do
					outputChatBox("" .. factionRankTitle .. " " .. charname .." has issued a vehicle ticket to VIN " ..tonumber(theVehicle).. " with the amount $" ..tonumber(amount).." for the reason: " ..reason.. ".", value, 0, 102, 255)
				end
			end
		end
	end
end
addCommandHandler("ticketveh", issueTicket)

function showAllTickets(thePlayer, theCommand)
	local logged = getElementData(thePlayer, "loggedin")
	if (logged==1) then
		local team = getPlayerTeam(thePlayer)
		if (getTeamName(team) == "326 Enterprises") or (getTeamName(team) == "Los Santos Police Department") or (getTeamName(team) == "San Andreas State Police") then
		local mQuery = mysql:query("SELECT `id`, `vehid`, `reason`, `amount`, `issuer`, `time` FROM `pd_tickets` ORDER BY `id` ASC")
			outputChatBox(">>> Start of Tickets <<<", thePlayer, 17, 77, 207)
			while true do
				local row = mysql:fetch_assoc(mQuery)
				if not row then break end
				local issuerName = exports['cache']:getCharacterName(row["issuer"])
				if issuerName == false then
					issuerName = "Unknown"
				end
				if tonumber(row["amount"]) >= 0 then
					outputChatBox("TICKET #" ..tostring(row["id"]), thePlayer, 237, 240, 239)
					outputChatBox("Issued by: " ..issuerName, thePlayer, 237, 240, 239)
					outputChatBox("VIN: "..tonumber(row["vehid"]), thePlayer, 237, 240, 239)
					outputChatBox("Time issued: " ..row["time"], thePlayer, 237, 240, 239)
					outputChatBox("Amount: $" ..row["amount"], thePlayer, 237, 240, 239)
					outputChatBox("Reason: " ..row["reason"], thePlayer, 237, 240, 239)
					outputChatBox(" ", thePlayer)
				end
			end
			mysql:free_result(mQuery)
			outputChatBox(" >> None", thePlayer, 237, 240, 239)
			outputChatBox(">>> End of Tickets <<<", thePlayer, 17, 77, 207)
		end
	end
end
addCommandHandler("vehtickets", showAllTickets)

function checkTicketOne(thePlayer, theCommand, theVehicle)
	local logged = getElementData(thePlayer, "loggedin")
	if (logged==1) then
		local team = getPlayerTeam(thePlayer)
		if (getTeamName(team) == "326 Enterprises") or (getTeamName(team) == "Los Santos Police Department") or (getTeamName(team) == "San Andreas State Police") then
			if not (theVehicle) or not (tonumber(theVehicle)) then
				outputChatBox("SYNTAX: /" ..theCommand.. " [vehID]", thePlayer, 255, 194, 14)
			else
				local mQuery = mysql:query("SELECT `id`, `vehid`, `reason`, `amount`, `issuer`, `time` FROM `pd_tickets` WHERE `vehid` ='" ..mysql:escape_string(theVehicle).."' ORDER BY `id` ASC")
				outputChatBox(">>> Start of Tickets <<<", thePlayer, 17, 77, 207)
				while true do
					local row = mysql:fetch_assoc(mQuery)
					if not row then break end
					local issuerName = exports['cache']:getCharacterName(row["issuer"])
						if issuerName == false then
							issuerName = "Unknown"
						end
					if tonumber(row["amount"]) >= 0 then
						outputChatBox("TICKET #" ..tostring(row["id"]), thePlayer, 237, 240, 239)
						outputChatBox("Issued by: " ..issuerName, thePlayer, 237, 240, 239)
						outputChatBox("VIN: "..tonumber(row["vehid"]), thePlayer, 237, 240, 239)
						outputChatBox("Time issued: " ..row["time"], thePlayer, 237, 240, 239)
						outputChatBox("Amount: $" ..row["amount"], thePlayer, 237, 240, 239)
						outputChatBox("Reason: " ..row["reason"], thePlayer, 237, 240, 239)
						outputChatBox(" ", thePlayer)
					end
				end
				mysql:free_result(mQuery)
				outputChatBox(" >> None", thePlayer, 237, 240, 239)
				outputChatBox(">>> End of Tickets <<<", thePlayer, 17, 77, 207)
			end
		end
	end
end
addCommandHandler("checkvehticket", checkTicketOne)

function delTicket(thePlayer, theCommand, ticketid)
	local logged = getElementData(thePlayer, "loggedin")
	if (logged==1) then
		local team = getPlayerTeam(thePlayer)
		if (getTeamName(team) == "326 Enterprises") or (getTeamName(team) == "Los Santos Police Department") or (getTeamName(team) == "San Andreas State Police") then
			if not (ticketid) or not (tonumber(ticketid)) then
				outputChatBox("SYNTAX: /" ..theCommand.. " [ticketID]", thePlayer, 255, 194, 14)
			else
				mysql:query_free("DELETE FROM `pd_tickets` WHERE `id`='" ..mysql:escape_string(ticketid).."'")
				outputChatBox(" >>> Ticket successfully annulled.", thePlayer, 0, 255, 0)
				local teamMembers = getPlayersInTeam(team)
				local charname = getPlayerName(thePlayer):gsub("_", " ")
				local factionID = getElementData(thePlayer, "faction")
				local factionRank = getElementData(thePlayer, "factionrank")
				local factionRanks = getElementData(team, "ranks")
				local factionRankTitle = factionRanks[factionRank]
				for key, value in ipairs(teamMembers) do
					outputChatBox("" .. factionRankTitle .. " " .. charname .." has annulled a vehicle ticket with the ID " ..ticketid.. ".", value, 237, 181, 26)
				end
			end
		end
	end
end
addCommandHandler("delvehticket", delTicket)

function checkPendingTickets(thePlayer) 
	local vehID = getElementData(source, "dbid")
	local mQuery = mysql:query("SELECT `amount` FROM `pd_tickets` WHERE `vehid` ='" ..mysql:escape_string(vehID).."'")
		while true do
			local row = mysql:fetch_assoc(mQuery)
				if not row then break end
		if row then
			outputChatBox(" ** This vehicle has unpaid tickets attached to the windshield wipers ** ((/tickets))", thePlayer, 255, 51, 102)
		end
	mysql:free_result(mQuery)
	end
end
addEventHandler("onVehicleEnter", getRootElement(), checkPendingTickets)
