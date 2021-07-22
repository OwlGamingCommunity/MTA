function loadAllPerks( targetPlayer )
	if isElement( targetPlayer ) then
		local logged = getElementData(targetPlayer, "account:loggedin")
		if (logged == true) then
			local gameAccountID = getElementData(targetPlayer, "account:id")
			if (gameAccountID) then
				if (gameAccountID > 0) then
					--default values
					setElementData(targetPlayer, "donation:nametag", false, true)
					--
					local mysqlResult = exports.mysql:query("SELECT `perkID`,`perkValue`, `expirationDate` FROM `donators` WHERE `accountID`='".. tostring(gameAccountID) .."' AND (`expirationDate` IS NULL OR `expirationDate` > NOW()) ")
					local perksTable = { }
					if (mysqlResult) then
						while true do
							local mysqlRow = exports.mysql:fetch_assoc(mysqlResult)
							if not mysqlRow then break end
							perksTable[ tonumber(mysqlRow["perkID"]) ] = tonumber(mysqlRow["perkValue"]) or mysqlRow["perkValue"]
							if tonumber(mysqlRow["perkID"]) == 11 then -- nametags
								setElementData(targetPlayer, "donation:nametag", true, true)
								setElementData(targetPlayer, "donation:nametag:expiredate", mysqlRow["expirationDate"], true)
							end
						end
					end
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "donation-system:perks", perksTable)
					exports.mysql:free_result(mysqlResult)
					return true
				end
			end
		end
	end
	return false
end

function updatePerkValue (targetPlayer, perkID, newValue)
	newValue = tostring(newValue)
	if not tonumber(perkID) then
		return false
	end
	
	perkID = tonumber(perkID)
	
	if perkID == 1 and exports.global:isStaffOnDuty(targetPlayer) then
		exports.anticheat:changeProtectedElementDataEx(targetPlayer, "pmblocked", newValue)
		return true
	end
	
	if (hasPlayerPerk(targetPlayer, perkID)) then
		local gameAccountID = getElementData(targetPlayer, "account:id")
		if (gameAccountID) then
			if (gameAccountID > 0) then
				exports.mysql:query_free("UPDATE `donators` SET `perkValue`='" .. exports.mysql:escape_string(newValue) .. "' WHERE `accountID`='".. tostring(gameAccountID)  .."' AND `perkID`='".. exports.mysql:escape_string(tostring(perkID)) .."'")
				local perkTable = getElementData(targetPlayer, "donation-system:perks")				
				perkTable[ perkID ] = newValue
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "donation-system:perks", perkTable)
				return true
			end
		end
	end
	return false
end
addEvent("donators:updatePerkValue", true)
addEventHandler("donators:updatePerkValue", root, updatePerkValue)

function givePlayerPerk(targetPlayer, perkID, perkValue, days, points, ...)
	if not isElement( targetPlayer ) then
		return false, "Internal script error 100.1"
	end
	
	if not tonumber(perkID) then
		return false, "Internal script error 100.2"
	end
	
	if not perkValue then
		perkValue = 1
	end
	
	if not tonumber(days) then
		return false, "Internal script error 100.3"
	end
	
	if not tonumber(points) then
		return false, "Internal script error 100.4"
	end
	
	perkValue = tostring(perkValue)
	perkID = tostring(perkID)
	points = tonumber(points)
	curGC = getElementData(targetPlayer, "credits")
	local logged = getElementData(targetPlayer, "account:loggedin")
	if (logged == false) then
		return false, "Player is not logged in"
	end
	
	if not points or points < 0 then
		return false, "Internal script error 100.5"
	end
	
	local gameAccountID = getElementData(targetPlayer, "account:id")
	local characterID = getElementData(targetPlayer, "account:character:id")
	if (gameAccountID) then
		if (gameAccountID > 0) then
			-- Handle the special perks first.
			if (tonumber(perkID) == 14) then -- Add an int slot
				if (characterID and tonumber(characterID) > 0) then
					local nextMaxInts = tonumber( getElementData(targetPlayer, "maxinteriors") )+1
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "maxinteriors", nextMaxInts)
					dbExec(exports.mysql:getConn("core"), "UPDATE `accounts` SET `credits`=credits-? WHERE `id`=?", points, gameAccountID)
					exports.mysql:query_free("UPDATE `characters` SET `maxinteriors`='"..tostring(nextMaxInts).."' WHERE `id`='".. tostring(characterID) .."'")
					setElementData(targetPlayer, "credits", curGC-points)
					loadAllPerks(targetPlayer)
					executeCommandHandler("stats", targetPlayer)
					addPurchaseHistory(targetPlayer, (donationPerks[tonumber(perkID)][1] or "").." ("..nextMaxInts..")", -points)
					return true, "Perk activated: Increased max. interiors to " .. nextMaxInts .. "."
				end
			elseif (tonumber(perkID) == 15) then -- Add a vehicle slot
				if (characterID and tonumber(characterID) > 0) then
					local currentMaxVehicles = tonumber( getElementData(targetPlayer, "maxvehicles") )+1
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "maxvehicles", currentMaxVehicles)
					dbExec(exports.mysql:getConn("core"), "UPDATE `accounts` SET `credits`=credits-? WHERE `id`=?", points, gameAccountID)
					exports.mysql:query_free("UPDATE `characters` SET `maxvehicles`='"..tostring(currentMaxVehicles).."' WHERE `id`='".. tostring(characterID) .."'")
					setElementData(targetPlayer, "credits", curGC-points)
					loadAllPerks(targetPlayer)
					executeCommandHandler("stats", targetPlayer)
					addPurchaseHistory(targetPlayer, (donationPerks[tonumber(perkID)][1] or "").." ("..currentMaxVehicles..")", -points)
					return true, "Perk activated: Increased max. vehicles to " .. currentMaxVehicles .. "."
				end
			elseif (tonumber(perkID) == 42) then -- Extra char slot
				if (characterID and tonumber(characterID) > 0) then
					dbExec( exports.mysql:getConn('mta'), "UPDATE account_details SET max_characters=max_characters+1 WHERE account_id=? ", gameAccountID )
					dbExec( exports.mysql:getConn('core'), "UPDATE accounts SET credits=credits-? WHERE id=? ", points, gameAccountID )
					setElementData(targetPlayer, "credits", curGC-points)
					loadAllPerks(targetPlayer)
					addPurchaseHistory(targetPlayer, (donationPerks[tonumber(perkID)][1] or "").."", -points)
					return true, "Perk activated: "..(donationPerks[tonumber(perkID)][1] or "")
				end
			elseif (tonumber(perkID) == 16) then -- Username change permit
				if (characterID and tonumber(characterID) > 0) then
					local parameters = {...}
					local username = parameters[1]
					local valid, reason = checkValidUsername(username)
					if not valid then
						return false, reason
					end
					
					local mysqlQ = dbQuery(exports.mysql:getConn("core"), "SELECT `username` FROM `accounts` WHERE `username` = ?", username)
					local mysqlQ = dbPoll(mysqlQ, 10000)
					if #mysqlQ ~= 0 then
						return false, "This name is already taken"
					end
					exports['admin-system']:addAdminHistory(gameAccountID, 0, "Username renamed from "..getElementData(targetPlayer, "account:username").." to "..(username), 6)

					dbExec(exports.mysql:getConn("core"), "UPDATE `accounts` SET `username`=?, `credits`=credits-? WHERE `id`=?", username, points, gameAccountID)
					setElementData(targetPlayer, "credits", curGC-points)
					loadAllPerks(targetPlayer)
					
					local oldUsername = getElementData(targetPlayer, "account:username")
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "account:username", username, true)
					
					triggerClientEvent(targetPlayer, "donation-system:username:close", targetPlayer)
					executeCommandHandler("stats", targetPlayer)
					addPurchaseHistory(targetPlayer, (donationPerks[tonumber(perkID)][1] or "").." ("..oldUsername.." -> "..username..")", -points)
					return true, "Perk activated: Your username has been changed from '"..oldUsername.."' to '"..username.."' successfully."
				end
			--[[
			elseif (tonumber(perkID) == 17) then -- Character name change permit
				if (characterID and tonumber(characterID) > 0) then
					local parameters = {...}
					local charname = parameters[1]
					local valid, reason = exports.account:checkValidCharacterName(charname)
					if not valid then
						return false, reason
					end
					
					local newCharname = string.gsub(charname, " ", "_")
					local newCharnameFixed = string.gsub(charname, "_", " ")
					
					local mysqlQ = exports.mysql:query("SELECT `charactername` FROM `characters` WHERE `charactername` = '"..exports.mysql:escape_string(newCharname).."'")
					if exports.mysql:num_rows(mysqlQ) ~= 0 then
						return false, "This name is already taken"
					end
					
					local currentChar = getPlayerName(targetPlayer)
					local currentCharFixed = string.gsub(currentChar, "_", " ")
					local playedHours = getElementData(targetPlayer, "hoursplayed")
					
					
					exports.mysql:query_free("INSERT INTO `adminhistory` SET `user_char`='N/A', `user`='"..exports.mysql:escape_string(gameAccountID).."', `action`='6', `reason`='Charname renamed from "..exports.mysql:escape_string(currentCharFixed).." to "..exports.mysql:escape_string(newCharnameFixed).."', `admin`='"..gameAccountID.."', `admin_char`='N/A' ")
					
					exports.mysql:query_free("UPDATE `characters` SET `charactername`='"..exports.mysql:escape_string(newCharname).."' WHERE `account`='".. tostring(gameAccountID) .."' AND `id`='"..characterID.."' ")
					
					exports.mysql:query_free("UPDATE `accounts` SET `credits`=credits-".. ((playedHours <= 5) and "1" or points) .." WHERE `id`='".. tostring(gameAccountID) .."'")
					
					loadAllPerks(targetPlayer)
					
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "legitnamechange", 1, false)
					setPlayerName(targetPlayer, tostring(newCharname))
					exports['cache']:clearCharacterName( characterID )
					--triggerClientEvent(targetPlayer, "updateName", targetPlayer, characterID)
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "legitnamechange", 0, false)
					
					triggerClientEvent(targetPlayer, "donation-system:charname:close", targetPlayer)
					executeCommandHandler("stats", targetPlayer)
					addPurchaseHistory(targetPlayer, (donationPerks[tonumber(perkID)][1] or "").." ("..currentCharFixed.." -> "..newCharnameFixed..")", -points)
					return true, "Perk activated: Your character name has been changed from '"..currentCharFixed.."' to '"..newCharnameFixed.."' successfully."
				end
			]]
			elseif (tonumber(perkID) == 18) or (tonumber(perkID) == 19) then -- Create phone with custom number.
				if (characterID and tonumber(characterID) > 0) then
					local parameters = {...}
					local number = tonumber(parameters[1])
					
					local valid, reason = checkValidNumber(number, (tonumber(perkID) == 19))
					if not valid then
						return false, reason
					end
					
					local mysqlQ = exports.mysql:query("SELECT `phonenumber` FROM `phones` WHERE `phonenumber` = '"..number.."'")
					if exports.mysql:num_rows(mysqlQ) ~= 0 then
						return false, "Number is already taken"
					end
					
					if exports.global:giveItem(targetPlayer, 2, number) then
						exports.mysql:query_free("INSERT INTO `phones` (`phonenumber`, `boughtby`) VALUES ('"..tostring(number).."', '".. tostring(characterID) .."')")
						dbExec( exports.mysql:getConn('core'), "UPDATE accounts SET credits=credits-? WHERE id=? ", points, gameAccountID )
						setElementData(targetPlayer, "credits", curGC-points)
						loadAllPerks(targetPlayer)
						triggerClientEvent(targetPlayer, "donation-system:phone:close", targetPlayer)
						addPurchaseHistory(targetPlayer, (donationPerks[tonumber(perkID)][1] or "").." ("..number..")", -points)
						return true, "Perk activated: You received the phone with number " .. number .. "."
					else
						return false, "Your inventory is full"
					end
				end
			elseif tonumber(perkID) == 24 or tonumber(perkID) == 25 or tonumber(perkID) == 26 then --Unique selection screen
				exports.mysql:query_free("INSERT INTO `donators` (accountID, perkID, perkValue) VALUES ('".. tostring(gameAccountID)  .."', '".. exports.mysql:escape_string(perkID) .."', '".. exports.mysql:escape_string(perkValue) .."' )")
				dbExec( exports.mysql:getConn('core'), "UPDATE accounts SET credits=credits-? WHERE id=? ", points, gameAccountID )
				setElementData(targetPlayer, "credits", curGC-points)
				loadAllPerks(targetPlayer)
				addPurchaseHistory(targetPlayer, (donationPerks[tonumber(perkID)][1] or "").."", -points)
				return true, "Perk activated"
			elseif tonumber(perkID) == 9 then -- Dupont extra slot
				dbExec( exports.mysql:getConn('core'), "UPDATE accounts SET credits=credits-? WHERE id=? ", points, gameAccountID )
				exports.mysql:query_free("UPDATE characters SET max_clothes=max_clothes+1 WHERE `id`='".. tostring(characterID) .."'")
				setElementData(targetPlayer, "credits", curGC-points)
				loadAllPerks(targetPlayer)
				addPurchaseHistory(targetPlayer, (donationPerks[tonumber(perkID)][1] or "").."", -points)
				return true, "Perk activated: Increased max manufacture slot."
			else -- Handle the regular perks
				exports.mysql:query_free("INSERT INTO `donators` (accountID, perkID, perkValue, expirationDate) VALUES ('".. tostring(gameAccountID)  .."', '".. exports.mysql:escape_string(perkID) .."', '".. exports.mysql:escape_string(perkValue) .."', NOW() + interval " .. tostring(days).." day)")
				
				dbExec( exports.mysql:getConn('core'), "UPDATE accounts SET credits=credits-? WHERE id=? ", points, gameAccountID )
				setElementData(targetPlayer, "credits", curGC-points)
				loadAllPerks(targetPlayer)
				exports.global:updateNametagColor(targetPlayer)
				addPurchaseHistory(targetPlayer, (donationPerks[tonumber(perkID)][1] or "").."", -points)
				return true, "Perk activated"
			end
		end
	end
	return false, "Player is not logged in"
end 

function addPurchaseHistory(thePlayer, perkName, cost)
	local id = nil
	if isElement(thePlayer) and getElementType(thePlayer) == "player" then
		id = getElementData(thePlayer, "account:id")
	else
		id = thePlayer
		if not tonumber(id) then
			if not exports.mysql:query_free("INSERT INTO `don_purchases` SET `name`='"..exports.global:toSQL(perkName).."', `cost`='"..exports.global:toSQL(cost).."', `account`=(SELECT `id` FROM `accounts` WHERE `username`='"..id.."')  ") then
				outputDebugString("[DONATION] Failed to add purchase history of "..tostring(perkName))
				return false
			else
				return true
			end
		end
	end
	if not exports.mysql:query_free("INSERT INTO `don_purchases` SET `name`='"..exports.global:toSQL(perkName).."', `cost`='"..exports.global:toSQL(cost).."', `account`='"..id.."'  ") then
		outputDebugString("[DONATION] Failed to add purchase history of "..tostring(perkName))
	end

	if getElementType(thePlayer) == "player" then
		exports.logs:dbLog(thePlayer, 26, thePlayer, "Purchase logs: "..perkName.." - Cost: "..cost.." GCs")
	end
end

function onCharacterSpawn(characterName, factionID)
	--[[
	loadAllPerks(source)
	local togNewsPerk, togNewsStatus = hasPlayerPerk(source, 3)
	if (togNewsPerk) then
		exports.anticheat:changeProtectedElementDataEx(source, "tognews", tonumber(togNewsStatus), false)
	end
	]]
	exports.global:updateNametagColor(source)
end
addEventHandler("onCharacterLogin", getRootElement(), onCharacterSpawn)

function takeGC(thePlayer, amount)
	if not amount or not tonumber(amount) or tonumber(amount) <= 0 then
		return false, "Invalid amount"
	else
		amount = tonumber(amount)
		local id = nil
		if getElementType(thePlayer) == "player" then
			id = getElementData(thePlayer,"account:id")
		else
			if not tonumber(thePlayer) then
				return false, "Internal Error - takeGC"
			else
				id = thePlayer
			end
		end

		local currentGC = dbQuery(exports.mysql:getConn("core"), "SELECT `credits` FROM `accounts` WHERE `id`=?  LIMIT 1", id)
		local currentGC = dbPoll(currentGC, 10000)
		if currentGC and #currentGC == 1 then
			currentGC = tonumber(currentGC[1].credits)
			if currentGC < amount then
				return false, "Player lacks of game coins"
			end
		
			if dbExec(exports.mysql:getConn("core"), "UPDATE `accounts` SET `credits`=`credits`-? WHERE `id`=? ", amount, id) then
				setElementData(thePlayer, "credits", currentGC-amount)
				return true
			else
				return false, "Database error"
			end
		end
	end
end

function giveAccountGC(account, amount, historyNote)
	if not amount or not tonumber(amount) or tonumber(amount) <= 0 then
		return false, "Invalid amount"
	elseif not account or not tonumber(account) or tonumber(account) <= 0 then
		return false, "Invalid account"
	else
		dbExec( exports.mysql:getConn('core'), "UPDATE accounts SET credits=credits+? WHERE id=? ", amount, account )
		if historyNote then
			dbExec( exports.mysql:getConn('mta'), "INSERT INTO don_purchases SET name=?, cost=?, account=? ", historyNote, amount, account )
		end
		return true
	end
end