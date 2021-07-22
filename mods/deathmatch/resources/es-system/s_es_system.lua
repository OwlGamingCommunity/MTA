mysql = exports.mysql

function playerDeath(totalAmmo, killer, killerWeapon)
	if getElementData(source, "dbid") then
		if getElementData(source, "adminjailed") then
			--local team = getPlayerTeam(source)
			spawnPlayer(source, 263.821807, 77.848365, 1001.0390625, 270) --, team)

			setElementModel(source,getElementModel(source))
			--setPlayerTeam(source, team)
			setElementInterior(source, 6)
			setElementDimension(source, getElementData(source, "playerid")+65400)

			setCameraInterior(source, 6)
			setCameraTarget(source)
			fadeCamera(source, true)

			exports.logs:dbLog(source, 34, source, "died in admin jail")
		elseif getElementData(source, "jailed") then
			exports["prison-system"]:checkForRelease(source)
			--[[ local x, y, z = getElementPosition(source)
			local int = getElementInterior(source)
			local dim = getElementDimension(source)
			spawnPlayer(source, x, y, z, 270, getElementModel(source), int, dim, getPlayerTeam(source))
			setCameraInterior(source, int)
			setCameraTarget(source)--]]

			exports.logs:dbLog(source, 34, source, "died in police jail")
		else
			local affected = { }
			table.insert(affected, source)
			local killstr = ' died'
			if (killer) then
				if getElementType(killer) == "player" then
					if (killerWeapon) then
						killstr = ' got killed by '..getPlayerName(killer):gsub("_", " ").. ' ('..getWeaponNameFromID ( killerWeapon )..')'
					else
						killstr = ' died'
					end
					table.insert(affected, killer)
				else
				killstr = ' got killed by an unknown source'
				table.insert(affected, "Unknown")
				end
			end
			-- Remove seatbelt if theres one on
			if 	(getElementData(source, "seatbelt") == true) then
				exports.anticheat:changeProtectedElementDataEx(source, "seatbelt", false, true)
			end

			local victimDropItem = false

			-- if killer and (getElementData(killer, "hoursplayed" ) >= 20) then
				-- victimDropItem = true
			-- end
			changeDeathViewTimer = setTimer(changeDeathView, 3000, 1, source, victimDropItem)

			outputChatBox("If you were killed due to DM or anything similar, /report to get an admin to revive you.", source)
			outputChatBox("If you accept your death, you may lose some of your items - unless revived.", source)

			--outputChatBox("Respawn in 10 seconds.", source)
			--setTimer(respawnPlayer, 10000, 1, source)

			exports.logs:dbLog(source, 34, affected, killstr)
			exports.anticheat:changeProtectedElementDataEx(source, "lastdeath", " [KILL] "..getPlayerName(source):gsub("_", " ") .. killstr, true)
		end
	end
end
addEventHandler("onPlayerWasted", getRootElement(), playerDeath)

function changeDeathView(source, victimDropItem)
	if isElement(source) and isPedDead(source) then
		local x, y, z = getElementPosition(source)
		local rx, ry, rz = getElementRotation(source)
		setCameraMatrix(source, x+6, y+6, z+3, x, y, z)
		triggerClientEvent(source,"es-system:showRespawnButton",source, victimDropItem)
	end
end

function acceptDeath(victimDropItem)
	if isPedDead(client) then
		if victimDropItem then
			local x, y, z = getElementPosition(client)
			for key, item in pairs(exports["item-system"]:getItems(client)) do
				itemID = tonumber(item[1])
				local ammo = false
				if itemID == 116 then
					ammo = exports.global:explode( ":", item[2]  )[2]
				end
				local keepammo = false
				if itemID == 116 or itemID == 115 or itemID == 134 then
					triggerEvent("dropItemOnDead", client, itemID, item[2], x, y, z, ammo, false)
				end
			end
		end

		fadeCamera(client, true)
		outputChatBox("Respawning...", client)
		if isTimer(changeDeathViewTimer) == true then
			killTimer(changeDeathViewTimer)
		end
		respawnPlayer(client, victimDropItem)
		setElementData(client, "canFly", false)
	else
		outputChatBox("You aren't dead!", client, 255, 0, 0)
	end
end
addEvent("es-system:acceptDeath", true)
addEventHandler("es-system:acceptDeath", getRootElement(), acceptDeath)

function logMe( message )
	local logMeBuffer = getElementData(getRootElement(), "killog") or { }
	local r = getRealTime()
	exports.global:sendMessageToAdmins(message)
	table.insert(logMeBuffer,"["..("%02d:%02d"):format(r.hour,r.minute).. "] " ..  message)

	if #logMeBuffer > 30 then
		table.remove(logMeBuffer, 1)
	end
	setElementData(getRootElement(), "killog", logMeBuffer)
end

function logMeNoWrn( message )
	local logMeBuffer = getElementData(getRootElement(), "killog") or { }
	local r = getRealTime()
	table.insert(logMeBuffer,"["..("%02d:%02d"):format(r.hour,r.minute).. "] " ..  message)

	if #logMeBuffer > 30 then
		table.remove(logMeBuffer, 1)
	end
	setElementData(getRootElement(), "killog", logMeBuffer)
end

function readLog(thePlayer)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		local logMeBuffer = getElementData(getRootElement(), "killog") or { }
		outputChatBox("Recent kill list:", thePlayer, 205, 201, 165)
		for a, b in ipairs(logMeBuffer) do
			outputChatBox("- "..b, thePlayer, 205, 201, 165, true)
		end
		outputChatBox("  END", thePlayer, 205, 201, 165)
	end
end
addCommandHandler("showkills", readLog)

function fallProtection(intx, inty, intz)
	local int = getElementInterior(client)
	local dim = getElementDimension(client)
	if isPedDead  ( client ) then
		triggerClientEvent(targetPlayer,"es-system:closeRespawnButton",client)
		if isTimer(changeDeathViewTimer) == true then
			killTimer(changeDeathViewTimer)
		end

		setPedHeadless(client, false)
		setCameraInterior(client, int)
		setCameraTarget(client, client)
		spawnPlayer(client, intx, inty, intz, 0)

		local skin = getElementModel(client)
		setElementModel(client,skin)
		triggerEvent("updateLocalGuns", client)
		exports.global:sendMessageToAdmins("AdmCmd: Fall protection revived "..tostring(getPlayerName(client))..".")
		exports.logs:dbLog(client, 4, client, "REVIVED from PK(Fall Protection)")
	else
		setElementPosition(client, intx, inty, intz)
	end
	setElementInterior(client, int)
	setElementDimension(client, dim)
end
addEvent("fallProtectionRespawn", true)
addEventHandler("fallProtectionRespawn", root, fallProtection)

function respawnPlayer(thePlayer, victimDropItem)
	if (isElement(thePlayer)) then

		if (getElementData(thePlayer, "loggedin") == 0) then
			exports.global:sendMessageToAdmins("AC0x0000004: "..getPlayerName(thePlayer):gsub("_", " ").." died while not in character, triggering blackfade.")
			return
		end
		setPedHeadless(thePlayer, false)

		local cost = math.random(175, 500)
		local tax = exports.global:getTaxAmount()

		exports.global:giveMoney( exports.factions:getFactionFromID(2), math.ceil((1-tax)*cost) )
		exports.global:takeMoney( getTeamFromName("Government of Los Santos"), math.ceil((1-tax)*cost) )

		mysql:query_free("UPDATE characters SET deaths = deaths + 1, health=50 WHERE charactername='" .. mysql:escape_string(getPlayerName(thePlayer)) .. "'")

		setCameraInterior(thePlayer, 0)

		setCameraTarget(thePlayer, thePlayer)

		outputChatBox("You have recieved treatment from Los Santos Fire Department.", thePlayer, 255, 255, 0)

		-- take all drugs
		local count = 0
		for i = 30, 43 do
			while exports.global:hasItem(thePlayer, i) do
				local number = exports['item-system']:countItems(thePlayer, i)
				exports.global:takeItem(thePlayer, i)
				exports.logs:dbLog(thePlayer, 34, thePlayer, "lost "..number.."x item "..tostring(i))
				count = count + 1
			end
		end
		if count > 0 then
			outputChatBox("LSFD Employee: We handed your drugs over to the SFPD.", thePlayer, 255, 194, 14)
		end

		-- take guns
		local removedWeapons = nil
		if not victimDropItem then
			local gunlicense = tonumber(getElementData(thePlayer, "license.gun"))
			local gunlicense2 = tonumber(getElementData(thePlayer, "license.gun2"))
			local items = exports['item-system']:getItems( thePlayer ) -- [] [1] = itemID [2] = itemValue

			local formatedWeapons
			local cor = 0
			for itemSlot, itemCheck in ipairs(items) do
				if itemCheck[1] == 115 then -- Weapon
					-- itemCheck[2]: [1] = gta weapon id, [2] = serial number/Amount of bullets, [3] = weapon/ammo name
					local itemCheckExplode = exports.global:explode(":", itemCheck[2])
					local weapon = tonumber(itemCheckExplode[1])
					if (((weapon >= 16 and weapon <= 40 and (gunlicense == 0 and gunlicense2 == 0) or not exports.weapon:isWeaponCCWP(thePlayer, itemCheck[1], itemCheck[2])) or (weapon == 29 or weapon == 30 or weapon == 32 or weapon ==31 or weapon == 34) and (gunlicense2 == 0)) and (not exports.factions:isInFactionType(thePlayer, 2))) or (weapon >= 35 and weapon <= 38) then
						if exports['item-system']:takeItemFromSlot(thePlayer, itemSlot-cor) then
							cor = cor + 1
							exports.logs:dbLog(thePlayer, 34, thePlayer, "lost a weapon (" ..  itemCheck[2] .. ")")
							for k = 1, 12 do
								triggerEvent("createWepObject", thePlayer, thePlayer, k, 0, getSlotFromWeapon(k))
							end

							if (removedWeapons == nil) then
								removedWeapons = itemCheckExplode[3]
								formatedWeapons = itemCheckExplode[3]
							else
								removedWeapons = removedWeapons .. ", " .. itemCheckExplode[3]
								formatedWeapons = formatedWeapons .. "\n" .. itemCheckExplode[3]
							end
						end
					end
				elseif itemCheck[1] == 116 then
					-- itemCheck[2]: [1] = cartridge id [2] = ammo
					local itemCheckExplode = exports.global:explode(":", itemCheck[2])
					local cart_id = tonumber(itemCheckExplode[1])
					local ammountOfAmmo = tonumber(itemCheckExplode[2])
					if cart_id and gunlicense == 0 and gunlicense2 == 0 then
						if exports['item-system']:takeItemFromSlot(thePlayer, itemSlot-cor) then
							cor = cor+1
							local pack = exports.weapon:getAmmo(cart_id)
							exports.logs:dbLog(thePlayer, 34, thePlayer, "lost a pack of "..pack.cartridge.." ammo. ("..ammountOfAmmo.." rounds)")

							if (removedWeapons == nil) then
								removedWeapons = ammountOfAmmo .. " " .. pack.cartridge
								formatedWeapons = ammountOfAmmo .. " " .. pack.cartridge
							else
								removedWeapons = removedWeapons .. ", " .. ammountOfAmmo .. " rounds of " .. pack.cartridge
								formatedWeapons = formatedWeapons .. "\n" .. ammountOfAmmo .. " rounds of " .. pack.cartridge
							end
						end
					end
				end
			end
		end

		if (removedWeapons~=nil) then
			if gunlicense == 0 and factiontype ~= 2 then
				outputChatBox("LSFD Employee: We have taken away weapons which you did not have a license for. (" .. removedWeapons .. ").", thePlayer, 255, 194, 14)
			else
				outputChatBox("LSFD Employee: We have taken away weapons which you are not allowed to carry. (" .. removedWeapons .. ").", thePlayer, 255, 194, 14)
			end
		end

		local death = getElementData(thePlayer, "lastdeath")
		if removedWeapons ~= nil then
			logMe(death)
			exports.global:sendMessageToAdmins("/showkills to view lost weapons.")
			logMeNoWrn("#FF0033 Lost Weapons: " .. removedWeapons)
		else
			logMe(death)
		end

		local theSkin = getPedSkin(thePlayer)
		--local theTeam = getPlayerTeam(thePlayer)

		local fat = getPedStat(thePlayer, 21)
		local muscle = getPedStat(thePlayer, 23)

		spawnPlayer(thePlayer, 1176.892578125, -1323.828125, 14.04377746582, 275)--, theTeam)
		setElementModel(thePlayer,theSkin)
		--setPlayerTeam(thePlayer, theTeam)
		setElementInterior(thePlayer, 0)
		setElementDimension(thePlayer, 0)

		setPedStat(thePlayer, 21, fat)
		setPedStat(thePlayer, 23, muscle)

		fadeCamera(thePlayer, true, 6)
		triggerClientEvent(thePlayer, "fadeCameraOnSpawn", thePlayer)
		triggerEvent("updateLocalGuns", thePlayer)
		setElementHealth(thePlayer, 50)
	end
end

function recoveryPlayer(thePlayer, commandName, targetPlayer, duration)
	if not (targetPlayer) or not tonumber(duration) or (tonumber(duration) or 0) <= 0 then
		outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Hours]", thePlayer, 255, 194, 14)
	else
		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if targetPlayer then
			local logged = getElementData(thePlayer, "loggedin")

			if (logged==1) then
				if exports.factions:isInFactionType(thePlayer, 4) or (exports.integration:isPlayerTrialAdmin(thePlayer) == true) then
					--if (targetPlayer == thePlayer) then
						local dimension = getElementDimension(thePlayer)
						--if (dimesion==9) then
							local totaltime = tonumber(duration)
							if totaltime < 12 then
								exports.bank:takeBankMoney(targetPlayer, 100*totaltime, true)
								exports.global:giveMoney( exports.factions:getFactionFromID(2), 100*totaltime )

								local dbid = getElementData(targetPlayer, "dbid")
								local timeLeft = getRealTime().timestamp + totaltime * 3600
								mysql:query_free("UPDATE characters SET recovery='1', recoverytime='" .. timeLeft .. "' WHERE id = " .. dbid)

								setElementFrozen(targetPlayer, true)
								setElementData(targetPlayer, "recovery", true)
								outputChatBox("You have successfully put " .. targetPlayerName .. " in recovery for " .. duration .. " hour(s) and charged $".. 100*totaltime ..".", thePlayer, 255, 0, 0)
								exports.global:sendMessageToAdmins("AdmWrn: " .. targetPlayerName .. " was put in recovery for " .. duration .. " hour(s) by " .. getPlayerName(thePlayer):gsub("_"," ") .. ".")
								outputChatBox("You were put in recovery by " .. getPlayerName(thePlayer) .. " for " .. duration .. " hour(s) and charged $".. 100*totaltime ..".", targetPlayer, 255, 0, 0)
								exports.logs:dbLog(thePlayer, 4, targetPlayer, "RECOVERY " .. duration)
							else
								outputChatBox("You cannnot put someone in recovery for that long.", thePlayer, 255, 0, 0)
							end
						--[[else
							outputChatBox("You must be in the hospital to do this command.", thePlayer, 255, 0, 0)
						end]]
					--[[else
						outputChatBox("You cannot recover yourself.", thePlayer, 255, 0, 0)
					end]]
				else
					outputChatBox("You have no basic medic skills, contact the ES.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("The player is not logged in.", thePlayer, 255,0,0)
			end
		end
	end
end
addCommandHandler("recovery", recoveryPlayer)

function scanForRecoveryRelease(player, eventname)
	local tick = getTickCount()
	local counter = 0
	local players = exports.pool:getPoolElementsByType("player")
	for key, value in ipairs(players) do
		local logged = getElementData(value, "loggedin")
		if (logged==1) then -- Check all logged in players.
			local dbid = getElementData(value, "dbid")
			local result = mysql:query_fetch_assoc( "SELECT `recovery`, `recoverytime` FROM `characters` WHERE `id`=" .. mysql:escape_string(dbid) ) -- Check to see if the player is listed as a current recovery patient.
			local inRecovery = tonumber(result["recovery"])
			if (inRecovery == 1) then
				local recoveryEndsAt = tonumber(result["recoverytime"])
				local currentTime = getRealTime().timestamp
				if (recoveryEndsAt <= currentTime) then -- Is the time up? If yes:
					setElementFrozen(value, false)
					setElementData(value, "recovery", false)
					mysql:query_free("UPDATE characters SET recovery='0', recoverytime=NULL WHERE id = " .. dbid) -- Allow them to move, and revert back to recovery type set to 0.
					outputChatBox("You are no longer in recovery!", value, 0, 255, 0) -- Let them know about it!
				else
					setElementFrozen(value, true) -- If they are still in recovery, then make sure they are frozen (if they login).
					setElementData(value, "recovery", true)
					if (player==value) and (eventname=="accounts:characters:spawn") then
						outputChatBox("You are still in recovery.", value, 255,0,0)
					end
				end
			end
		end
	end
	local tickend = getTickCount()
end
setTimer(scanForRecoveryRelease, 500000, 0) -- Check every 5 minutes.

function checktime( thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	if (logged==1) then
        local dbid = getElementData(thePlayer, "dbid")
		local result = mysql:query_fetch_assoc( "SELECT `recovery`, `recoverytime` FROM `characters` WHERE `id`=" .. mysql:escape_string(dbid) ) -- Check to see if the player is listed as a current recovery patient.
		local inRecovery = tonumber(result["recovery"])
        if (inRecovery == 1) then
            local recoveryEndsAt = tonumber(result["recoverytime"])
			local currentTime = getRealTime().timestamp
			if (recoveryEndsAt <= currentTime) then -- Is the time up? If yes:
				setElementFrozen(thePlayer, false)
				setElementData(thePlayer, "recovery", false)
				mysql:query_free("UPDATE characters SET recovery='0', recoverytime=NULL WHERE id = " .. dbid) -- Allow them to move, and revert back to recovery type set to 0.
				outputChatBox("You are no longer in recovery!", thePlayer, 0, 255, 0) -- Let them know about it!
			else
				recoveryEndsAt = recoveryEndsAt - currentTime
				local hoursLeft = math.floor(recoveryEndsAt / 3600)
				recoveryEndsAt = recoveryEndsAt - 3600 * hoursLeft
				local minutesLeft = math.floor(recoveryEndsAt / 60)
           		outputChatBox("You have " .. hoursLeft .. " hour(s) and " .. minutesLeft .. " minute(s) of recovery left.", thePlayer)
           	end
        end
    end
end
addCommandHandler("recoverytime", checktime)

function scanForRecoveryReleaseF10(player, eventname)
	if source and (not player or not isElement(player) or getElementType(player) ~= 'player') then
		player = source
	end

	local logged = getElementData(player, "loggedin")
	if (logged==1) then
		local dbid = getElementData(player, "dbid")
		local result = mysql:query_fetch_assoc( "SELECT `recovery`, `recoverytime` FROM `characters` WHERE `id`=" .. mysql:escape_string(dbid) ) -- Check to see if the player is listed as a current recovery patient.
		local inRecovery = tonumber(result["recovery"])
		if (inRecovery == 1) then
			local recoveryEndsAt = tonumber(result["recoverytime"])
			local currentTime = getRealTime().timestamp
			if (recoveryEndsAt <= currentTime) then -- Is the time up? If yes:
				setElementFrozen(player, false)
				setElementData(player, "recovery", false)
				mysql:query_free("UPDATE characters SET recovery='0', recoverytime=NULL WHERE id = " .. dbid) -- Allow them to move, and revert back to recovery type set to 0.
				outputChatBox("You are no longer in recovery!", player, 0, 255, 0) -- Let them know about it!
			else
				setElementFrozen(player, true) -- If they are still in recovery, then make sure they are frozen (if they login).
				setElementData(player, "recovery", true)
				outputChatBox("You are still in recovery.", player, 255,0,0)
			end
		end
	end
end
addEventHandler("accounts:characters:spawn", getRootElement(), scanForRecoveryReleaseF10)

function prescribe(thePlayer, commandName, ...)
	if exports.factions:isInFactionType(thePlayer, 4) then
		if not (...) then
			outputChatBox("SYNTAX /" .. commandName .. " [prescription value]", thePlayer, 255, 184, 22)
		else
			local itemValue = table.concat({...}, " ")
			itemValue = tonumber(itemValue) or itemValue
			if not(itemValue=="") then
				exports.global:giveItem( thePlayer, 132, itemValue )
				outputChatBox("The prescription '" .. itemValue .. "' has been processed.", thePlayer, 0, 255, 0)
				--exports.global:sendMessageToAdmins(getPlayerName(thePlayer):gsub("_"," ") .. " has made a prescription with the value of: " .. itemValue .. ".")
				exports.logs:dbLog(thePlayer, 4, thePlayer, "PRESCRIPTION " .. itemValue)
			end
		end
	end
end
addCommandHandler("prescribe", prescribe)

-- /revive
function revivePlayerFromPK(thePlayer, commandName, targetPlayer)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (targetPlayer) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				if isPedDead  ( targetPlayer ) then
					triggerClientEvent(targetPlayer,"es-system:closeRespawnButton",targetPlayer)
					if isTimer(changeDeathViewTimer) == true then
						killTimer(changeDeathViewTimer)
					end

					local x,y,z = getElementPosition(targetPlayer)
					local int = getElementInterior(targetPlayer)
					local dim = getElementDimension(targetPlayer)
					local skin = getElementModel(targetPlayer)
					--local team = getPlayerTeam(targetPlayer)

					setPedHeadless(targetPlayer, false)
					setCameraInterior(targetPlayer, int)
					setCameraTarget(targetPlayer, targetPlayer)
					spawnPlayer(targetPlayer, x, y, z, 0)--, team)

					setElementModel(targetPlayer,skin)
					--setPlayerTeam(targetPlayer, team)
					setElementInterior(targetPlayer, int)
					setElementDimension(targetPlayer, dim)
					triggerEvent("updateLocalGuns", targetPlayer)
					local adminTitle = tostring(exports.global:getPlayerAdminTitle(thePlayer))
					outputChatBox("You have been revived by "..tostring(exports.global:getPlayerAdminTitle(thePlayer)).." "..tostring(getPlayerName(thePlayer):gsub("_"," "))..".", targetPlayer, 0, 255, 0)
					outputChatBox("You have revived "..tostring(getPlayerName(targetPlayer):gsub("_"," "))..".", thePlayer, 0, 255, 0)
					exports.global:sendMessageToAdmins("AdmCmd: "..tostring(exports.global:getPlayerAdminTitle(thePlayer)).." "..getPlayerName(thePlayer).." revived "..tostring(getPlayerName(targetPlayer))..".")
					exports.logs:dbLog(thePlayer, 4, targetPlayer, "REVIVED from PK")
				else
					outputChatBox(tostring(getPlayerName(targetPlayer):gsub("_"," ")).." is not dead.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("revive", revivePlayerFromPK, false, false)

local medicalBillFactions = {
		[164] = true, --ASH
	}
local medicalBillInsuranceCoverage = 0.95
local medicalBillMinimumSelfCoverage = 500
function medicalBill(thePlayer, commandName, targetPlayer, amount)
	local dutyFaction = exports.factions:getCurrentFactionDuty(thePlayer)
	if medicalBillFactions[dutyFaction] then
		if not (targetPlayer) or not tonumber(amount) or (tonumber(amount) or 0) <= 0 then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Amount]", thePlayer, 255, 194, 14)
		else
			amount = tonumber(amount)
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				local logged = getElementData(thePlayer, "loggedin")
				if (logged==1) then
					local insurance = 0
					if amount > medicalBillMinimumSelfCoverage then
						insurance = math.floor(amount * medicalBillInsuranceCoverage)
					end
					local toPay = amount - insurance
					if toPay <= medicalBillMinimumSelfCoverage then
						local diff = medicalBillMinimumSelfCoverage - toPay
						if diff > 0 then
							insurance = insurance - diff
						end
					end
					if insurance < 0 then insurance = 0 end
					local date = getRealTime()

					local rankName
					local rank = exports.factions:getPlayerFactionRank(thePlayer, dutyFaction)
					local team = exports.factions:getFactionFromID(dutyFaction)
					local factionRanks = getElementData(team, "ranks")
					if factionRanks then
						rankName = factionRanks[rank]
					else
						rankName = false
						outputDebugString("medicalBill() failed to get rankName.")
						outputDebugString("rank="..tostring(rank).." faction="..tostring(dutyFaction).." team="..tostring(team).. "ranks="..tostring(factionRanks))
					end

					triggerClientEvent(targetPlayer, "es-system:medicalBillClient", targetPlayer, amount, insurance, dutyFaction, thePlayer, date, rankName)
					outputChatBox("Medical bill sent to "..tostring(targetPlayerName)..".", thePlayer, 245, 217, 7)
				else
					outputChatBox("The player is not logged in.", thePlayer, 255,0,0)
				end
			else
				outputChatBox("Player not found.", thePlayer, 255,0,0)
			end
		end
	end
end
addCommandHandler("bill", medicalBill)

function payMedicalBill(customer, doctor, faction, amount, insurance, action)
	if not client then client = customer end
	local toPay = amount - insurance
	if action == 1 then --pay by cash
		if exports.global:takeMoney(client, toPay) then
			local theTeam = exports.factions:getFactionFromID(faction)
			if exports.global:giveMoney(theTeam, amount) then
				local name = exports.global:getPlayerName(client):gsub("_", " ")
				mysql:query_free("INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (0, " .. mysql:escape_string(-getElementData(theTeam, "id")) .. ", " .. mysql:escape_string(amount) .. ", 'Medical bill for "..name.."', 13)" )
				outputChatBox("You paid your medical bill ($"..tostring(exports.global:formatMoney(amount))..").", client, 0, 250, 0)
				outputChatBox(name.." paid their medical bill ($"..tostring(exports.global:formatMoney(amount))..").", doctor, 0, 250, 0)
			end
		else
			outputChatBox("You don't have enough cash to pay the bill. Taking from bank account instead.", client, 255, 0, 0)
			payMedicalBill(client, doctor, faction, amount, insurance, 2)

			local name = exports.global:getPlayerName(client):gsub("_", " ")
			outputChatBox(name.." could not afford to pay the medical bill.", doctor, 255, 0, 0)
		end
	elseif action == 2 then --pay by bank
		if exports.bank:hasBankMoney(client, toPay) then
			if exports.bank:takeBankMoney(client, toPay) then
				local theTeam = exports.factions:getFactionFromID(faction)
				if exports.global:giveMoney(theTeam, amount) then
					local name = exports.global:getPlayerName(client):gsub("_", " ")
					if insurance > 0 then
						mysql:query_free("INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (0, " .. mysql:escape_string(getElementData(client, "dbid")) .. ", " .. mysql:escape_string(insurance) .. ", 'Insurance claim for medical bill', 3)" )
					end
					mysql:query_free("INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. mysql:escape_string(getElementData(client, "dbid")) .. ", " .. mysql:escape_string(-getElementData(theTeam, "id")) .. ", " .. mysql:escape_string(amount) .. ", 'Medical bill', 13)" )
					outputChatBox("You paid your medical bill ($"..tostring(exports.global:formatMoney(amount))..").", client, 0, 250, 0)
					outputChatBox(name.." paid their medical bill ($"..tostring(exports.global:formatMoney(amount))..").", doctor, 0, 250, 0)
				end
			else
				outputChatBox("A transaction error occured. Medical bill not paid.", client, 255, 0, 0)
				local name = exports.global:getPlayerName(client):gsub("_", " ")
				outputChatBox(name.." could not pay the medical bill due to a transaction error.", doctor, 255, 0, 0)
			end
		else
			outputChatBox("You cannot afford to pay the medical bill.", client, 255, 0, 0)
			local name = exports.global:getPlayerName(client):gsub("_", " ")
			outputChatBox(name.." could not afford to pay the medical bill.", doctor, 255, 0, 0)
		end
	elseif action == 3 then --refuse to pay
		local name = exports.global:getPlayerName(client):gsub("_", " ")
		outputChatBox(name.." refused to pay the medical bill.", doctor, 255, 0, 0)
	end
end
addEvent("es-system:payMedicalBill", true)
addEventHandler("es-system:payMedicalBill", getResourceRootElement(), payMedicalBill)
