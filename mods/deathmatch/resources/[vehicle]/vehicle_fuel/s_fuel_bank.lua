local mysql = exports.mysql

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

function getCardInfo(theCard) -- 1. card owner name, 2. card number, 3. card owner id, 4. limit type
	if not theCard or not theCard[2] then
		return "?", "?", false
	end
	
	theCard = explode(";", theCard[2])
	return exports.cache:getCharacterNameFromID(theCard[2]) , theCard[1] or "?", theCard[2] or false, theCard[3] or 1
end

function checkPINCode(enteredCode)
	local playerName = getPlayerName(source)
	local playerGender = (getElementData(source,"gender") == 0) and "sir" or "madam"
	
	local foundAnATMCard = getATMCardFromATMMachine(thePlayer)
	if not foundAnATMCard then
		exports.hud:sendBottomNotification(source,"ATM Machine is not working properly!", "This is really weird, the card you've just inserted, It's gone magically!")
		return false
	end
	
	local cardOwner, cardNumber, cardOwnerCharID = getCardInfo(foundAnATMCard)
	--outputDebugString(cardOwner.." - "..cardNumber.." - "..cardOwnerCharID)
	local check = mysql:query_fetch_assoc("SELECT `card_locked`, `card_pin`, `card_number` FROM `atm_cards` WHERE `card_number`='"..cardNumber.."' AND `card_pin`='"..enteredCode.."' ")
	if not check or not check["card_number"] then
			triggerClientEvent(source, "fuel:respondToATMInterfacePIN", source, "Access Denied", 255,0,0, "failedLessThan3")
		return false
	end
	
	if check["card_locked"] == "1" then
		triggerClientEvent(source, "fuel:respondToATMInterfacePIN", source, "ERROR: This ATM card is not usable.", 255,0,0, "locked", cardNumber )
		return false
	end
	
	triggerClientEvent(source, "fuel:respondToATMInterfacePIN", source, "Access Granted!", 70,255,14, "success" )
	
end
addEvent( "fuel:checkPINCode", true )
addEventHandler( "fuel:checkPINCode", getRootElement(), checkPINCode )