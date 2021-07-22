local mysql = exports.mysql

-- GET VEHICLE KEY OR INTERIOR KEY / MAXIME
function getKey(thePlayer, commandName)
	if exports.integration:isPlayerTrialAdmin(thePlayer)	then
		local adminName = getPlayerName(thePlayer):gsub(" ", "_")
		local veh = getPedOccupiedVehicle(thePlayer)
		if veh then
			local vehID = getElementData(veh, "dbid")
			
			givePlayerItem(thePlayer, "giveitem" , adminName, "3" , tostring(vehID))
			
			return true
		else
			local intID = getElementDimension(thePlayer)
			if intID then
				local foundIntID = false
				local keyType = false
				local possibleInteriors = getElementsByType("interior")
				for _, theInterior in pairs (possibleInteriors) do
					if getElementData(theInterior, "dbid") == intID then
						local intType = getElementData(theInterior, "status").type 
						if intType == 0 or intType == 2 or intType == 3 then
							keyType = 4 --Yellow key
						else
							keyType = 5 -- Pink key
						end
						foundIntID = intID
						break
					end
				end
				
				if foundIntID and keyType then
					givePlayerItem(thePlayer, "giveitem" , adminName, tostring(keyType) , tostring(foundIntID))
					
					return true
				else
					outputChatBox(" You're not in any vehicle or possible interior.", thePlayer, 255,0 ,0 )
					return false
				end
			end
		end
	end
end
addCommandHandler("getkey", getKey, false, false)

function generateFakeIdentity(player, cmd)
	if exports.integration:isPlayerLeadAdmin(player) then
		if getElementData(player, "fakename") then
			exports.anticheat:changeProtectedElementDataEx(player, "fakename", false, true)
			outputChatBox("Fake identity removed.",player)
			return false
		end
		
		local name = exports.global:createRandomMaleName()
		
		exports.anticheat:changeProtectedElementDataEx(player, "fakename", name, true)
		outputChatBox("Fake identity activated.",player)
		triggerEvent("fakemyid", player)
	end
end
addCommandHandler("fakeme", generateFakeIdentity, false, false)

function setSvPassword(thePlayer, commandName, password)
	if exports.integration:isPlayerLeadAdmin(thePlayer) or exports.integration:isPlayerLeadScripter(thePlayer) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Password without spaces, empty to remove pw] - Set/remove server's password", thePlayer, 255, 194, 14)
		if password and string.len(password) > 0 then
			if setServerPassword(password) then
				exports.global:sendMessageToStaff("[SYSTEM] "..exports.global:getPlayerFullIdentity(thePlayer).." has set server's password to '"..password.."'.", true)
			end
		else
			if setServerPassword('') then
				exports.global:sendMessageToStaff("[SYSTEM] "..exports.global:getPlayerFullIdentity(thePlayer).." has removed server's password.", true)
			end
		end
	end
end
addCommandHandler("setserverpassword", setSvPassword, false, false)
addCommandHandler("setserverpw", setSvPassword, false, false)


