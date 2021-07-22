function makeKey(thePlayer, commandName, keyType, keyID)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		if(getElementData(thePlayer,"job")==6)then
			if not (keyType) or not (keyID) then
				outputChatBox("SYNTAX: /" .. commandName .. " [Key Type: 1=House 2=Business 3=Vehicle] [Key ID]", thePlayer, 255, 194, 14)
			else
				if not exports.global:hasMoney(thePlayer, 25) then
					outputChatBox("You do not have enough money to duplicate a key.", thePlayer, 255, 0, 0)
				else
					-- Translate keytype to key item IDs.
					if (tonumber(keyType) == 1) then
						itemID = 4 --House Key
						keyname = "house key"
					elseif(tonumber(keyType) == 2) then
						itemID = 5 -- Business Key
						keyname = "business key"
					elseif(tonumber(keyType) == 3) then
						itemID = 3 -- Vehicle Key
						keyname = "vehicle key"
					end
					local success = exports.global:hasItem(thePlayer, tonumber(itemID), tonumber(keyID))
					if(success)then -- does the player have the key?
						exports.global:giveItem(thePlayer, tonumber(itemID), tonumber(keyID)) -- create a ket for the locksmith.
						exports.global:takeMoney(thePlayer, 25) -- take the cost of making the key from the locksmith.
						outputChatBox("You have duplicated a ".. keyname .." ".. keyID .." at a cost of $15.", thePlayer)
						exports.global:sendLocalMeAction(thePlayer,"duplicates a ".. keyname ..".")
					else
						outputChatBox("You do not have that key.", thePlayer, 255, 0, 0)
					end
				end
			end
		end
	end
end
addCommandHandler("copykey", makeKey, false, false)