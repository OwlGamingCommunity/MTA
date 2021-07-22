--MAXIME 
--ATM Card system

function getATMCardFromATMMachine(theATM)
	local items = exports["item-system"]:getItems(theATM) 
	local foundAnATMCard = false
	
	if not items then
		return false
	end
	
	for key, item in pairs(items) do
		if tonumber(item[1]) == 150 then
			foundAnATMCard = item
			break
		end
	end
	
	if not foundAnATMCard then
		return false
	else
		return foundAnATMCard
	end
end

function getCardInfo(theCard) -- 1. card owner name, 2. card number, 3. card owner id, 4. limit type
	if not theCard or not theCard[2] then
		return "?", "?", false
	end
	
	theCard = explode(";", theCard[2])
	return exports.cache:getCharacterNameFromID(theCard[2]) , theCard[1] or "?", theCard[2] or false, theCard[3] or 1
end

function isAnyOneElseAround(theAtm) 
	local ax, ay, az = getElementPosition( theAtm )
	for _, player in pairs(getElementsByType("player")) do
		if player ~= localPlayer then
			local px, py, pz = getElementPosition( player ) 
			if getDistanceBetweenPoints3D( px, py, pz, ax, ay, az ) < 1.3 then 
				return true
			end
		end
	end
	return false
end

function updateBankMoney(thePlayer, charID, money, transfer)
	if not charID or not tonumber(charID) or not money or not tonumber(money) then
		return false
	else
		charID = tonumber(charID)
		money = math.abs(money)
	end

	if charID < 0 then -- faction id
		local factionId = -charID
		local foundFaction = nil
		--outputDebugString(factionId)
		for _, faction in pairs(getElementsByType("team")) do
			--outputDebugString(tonumber(getElementData(faction, "id")) )
			if factionId == tonumber(getElementData(faction, "id")) then
				foundFaction = faction
				break
			end
		end

		if not foundFaction then 
			outputDebugString ("bank / atm / didn't find the faction from id ")
			return false
		end

		if not transfer then
			return exports.global:setMoney(foundFaction, money)
		else
			if transfer == "minus" then
				return exports.global:takeMoney(foundFaction, money)
			elseif transfer == "plus" then
				return exports.global:giveMoney(foundFaction, money)
			else
				return false
			end
		end
	else
		if not transfer then
			for _, player in pairs(getElementsByType("player")) do
				if tonumber(charID) == tonumber(getElementData(player, "dbid")) then
					setElementDataEx(player, "bankmoney", tonumber(money) or 0, true)
				end
			end
			
			--UPDATE TO SQL
			if not mysql:query_free("UPDATE `characters` SET `bankmoney`='"..money.."' WHERE `id`='"..charID.."' ") then
				outputDebugString("[BANK] Failed to update bankmoney to SQL!")
				return false
			end
			return true
		else
			if transfer == "minus" then
				for _, player in pairs(getElementsByType("player")) do
					if tonumber(charID) == tonumber(getElementData(player, "dbid")) then
						local current = getElementData(player, "bankmoney")
						if tonumber(money) > current then
							return false
						end
						setElementDataEx(player, "bankmoney", current-tonumber(money), true)
					end
				end
				--UPDATE TO SQL
				if not mysql:query_free("UPDATE `characters` SET `bankmoney`=bankmoney-"..money.." WHERE `id`='"..charID.."' ") then
					outputDebugString("[BANK] Failed to update bankmoney to SQL!")
					return false
				end
				return true
			elseif transfer == "plus" then
				for _, player in pairs(getElementsByType("player")) do
					if tonumber(charID) == tonumber(getElementData(player, "dbid")) then
						setElementDataEx(player, "bankmoney", getElementData(player, "bankmoney")+tonumber(money), true)
					end
				end
				--UPDATE TO SQL
				if not mysql:query_free("UPDATE `characters` SET `bankmoney`=bankmoney+"..money.." WHERE `id`='"..charID.."' ") then
					outputDebugString("[BANK] Failed to update bankmoney to SQL!")
					return false
				end
				return true
			else
				outputDebugString("Error in g_atm_functions.lua / line 70++")
				return false
			end
		end
	end
end

function toSQL(text)
	return tostring(text):gsub("'","''")
end

function no_(text)
	return tostring(text):gsub("_", " ")
end

--ANTI-ALT->ALT
function areYouAltAlting(thePlayer, card1, target_id)
	local playerAccID = getElementData(thePlayer, "account:id")
	local playerCharID = getElementData(thePlayer, "dbid")
	local playerName = getPlayerName(thePlayer)
	
	if not target_id then --IF WITHDRAW
		if playerCharID ~= tonumber(card1[3]) then
			local antiAltAlt = mysql:query_fetch_assoc("SELECT `charactername` FROM `characters` WHERE `characters`.`account`='"..toSQL(playerAccID).."' AND `characters`.`id`='"..toSQL(card1[3]).."' LIMIT 1") or false
			if antiAltAlt and antiAltAlt["charactername"] and string.len(antiAltAlt["charactername"])>0 then --DETECTED ALT-ALT BETWEEN CHARS IN SAME ACCOUNT
				return "between alts"
			end
			
			--[[local cardOwnerIP = mysql:query_fetch_assoc(" SELECT `ip` FROM accounts a LEFT JOIN characters c ON a.id = c.account WHERE c.id='"..toSQL(card1[3]).."' LIMIT 1") or false
			local qh = dbQuery("SELECT `ip` FROM accounts WHERE id=? LIMIT 1", playerAccID)
			local playerIP = dbPoll(qh, 10000) or false
			if cardOwnerIP and playerIP and #playerIP > 0 and cardOwnerIP == playerIP[1].ip then -- DETECTED ALT-ALT OVER ACCOUNTS ON THE SAME IP ADDRESS
				return "between chars over the same ip"
			end]]
			
			local cardOwnerSerial = mysql:query_fetch_assoc(" SELECT `mtaserial` FROM account_details a LEFT JOIN characters c ON a.account_id = c.account WHERE c.id='"..toSQL(card1[3]).."' LIMIT 1") or false
			local playerSerial = getPlayerSerial(thePlayer)
			if cardOwnerSerial and playerSerial and cardOwnerSerial == playerSerial then -- DETECTED ALT-ALT OVER ACCOUNTS ON THE SAME MTA SERIAL
				return "between chars over the same mtaserial"
			end
		end
	elseif target_id then -- TRANSFER
		local antiAltAlt = mysql:query_fetch_assoc("SELECT `charactername` FROM `characters` WHERE `characters`.`account`='"..toSQL(playerAccID).."' AND `characters`.`id`='"..toSQL(target_id).."' LIMIT 1") or false
		if antiAltAlt and antiAltAlt["charactername"] and string.len(antiAltAlt["charactername"])>0 then --DETECTED ALT-ALT BETWEEN CHARS IN SAME ACCOUNT
			return "between alts"
		end
		
		--[[local cardOwnerIP = mysql:query_fetch_assoc(" SELECT `ip` FROM accounts a LEFT JOIN characters c ON a.id = c.account WHERE c.id='"..toSQL(target_id).."' LIMIT 1") or false
		local playerIP = mysql:query_fetch_assoc(" SELECT `ip` FROM accounts WHERE id='"..toSQL(playerAccID).."' LIMIT 1") or false
		if cardOwnerIP and playerIP and cardOwnerIP == playerIP then -- DETECTED ALT-ALT OVER ACCOUNTS ON THE SAME IP ADDRESS
			return "between chars over the same ip"
		end]]
		
		local cardOwnerSerial = mysql:query_fetch_assoc(" SELECT `mtaserial` FROM account_details a LEFT JOIN characters c ON a.account_id = c.account WHERE c.id='"..toSQL(target_id).."' LIMIT 1") or false
		local playerSerial = getPlayerSerial(thePlayer)
		if cardOwnerSerial and playerSerial and cardOwnerSerial == playerSerial then -- DETECTED ALT-ALT OVER ACCOUNTS ON THE SAME MTA SERIAL
			return "between chars over the same mtaserial"
		end
	end
	return false
	
end

function disableATMCard(carNo)
	mysql:query_free("UPDATE `atm_cards` SET `card_locked`='1' WHERE `card_number`='"..carNo.."' ")
end

function copyATMCardNumber(text)
	if setClipboard(text) then
		exports.hud:sendBottomNotification(getLocalPlayer(), "ATM Machine", "Copied '"..text.."' to clipboard.")
	end
end
addEvent("bank:copyATMCardNumber", true)
addEventHandler("bank:copyATMCardNumber", getRootElement(), copyATMCardNumber)

------------------------END ATM CARD SYSTEM----------------------------
function saveBank( thePlayer )
	if getElementData( thePlayer, "loggedin" ) == 1 then
		mysql:query_free("UPDATE characters SET bankmoney=" .. mysql:escape_string((tonumber(getElementData( thePlayer, "bankmoney" )) or 0)) .. " WHERE id=" .. mysql:escape_string(getElementData( thePlayer, "dbid" )))
	end
end

function explode(div,str) -- credit: http://richard.warburton.it
  if (div=='') then return false end
  local pos,arr = 0,{}
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,true) end do
	table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
	pos = sp + 1 -- Jump past current divider
  end
  table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  return arr
end

local withdraws = {} 
local limitedAmount = 10000 --dollars
local limitedInterval = 1000*60*60*5 --hours
local limits = {
		[1] = 10000,
		[2] = 50000,
		[3] = 0,
	}

function isThisTransactionWithinLimitation(cardNumber,amount, limitType)
	if not cardNumber or not amount or not tonumber(amount) or not limitType or not tonumber(limitType) then
		return false, "Internal Error"
	end

	amount = tonumber(amount)
	limitType = tonumber(limitType)

	if limits[limitType] == 0 then
		return true
	end

	if not withdraws[cardNumber] then
		withdraws[cardNumber] = {}
	end

	local total = 0
	local now = getTickCount()
	local start = now - limitedInterval
	for timestamp, amount in pairs (withdraws[cardNumber]) do
		if timestamp > start then
			total = total + amount
		end
	end

	total = total + amount

	if total > limits[limitType] then
		return false, "You can only withdraw/transfer $"..exports.global:formatMoney(limits[limitType]).." from this ATM card a day ((Every "..math.floor(limitedInterval/60/60/1000).." hours))\n You have already made in total of $"..exports.global:formatMoney(total-amount).." worth of transactions recently."
	end

	return true
end

function addTransactionLimit(cardNumber, amount, limitType)
	if not cardNumber or not amount or not tonumber(amount) or not limitType or not tonumber(limitType) then
		return false, "Internal Error"
	end

	amount = tonumber(amount)
	limitType = tonumber(limitType)

	if limits[limitType] == 0 then
		return true
	end

	if not withdraws[cardNumber] then
		withdraws[cardNumber] = {}
	end

	local now = getTickCount()
	withdraws[cardNumber][now] = amount

	return true
end