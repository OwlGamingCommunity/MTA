-- MAXIME
function showDonationGUI(donor)
	if donor and isElement(donor) and getElementType(donor) == "player" then
		client = donor
	end
	local logged = getElementData(client, "loggedin")
	if (logged==1) then
		local characterID = getElementData(client, "account:character:id")
		if not (characterID) then
			outputDebugString("showDonationGUI / Can't find char ID")
			return false
		end

		setElementData(client, "donation-system:GUI:active", true, false)
		local gameAccountID = getElementData(client, "account:id")
		local obtainedTable = { }
		local availableTable = { }
		local donPoints = 0
		local perkTable = getElementData(client, "donation-system:perks")
		if not (perkTable) then
			perkTable = { }
		end
		for perkID = 1, #donationPerks do
			local perkArr = donationPerks[perkID]
			if perkArr then
				if (perkArr[1] ~= nil) then
					perkArr[4] = perkID
					if (perkTable [ tonumber( perkID) ]) then
						local expirationDate = false
						local mysqlResult = exports.mysql:query_fetch_assoc("SELECT `expirationDate` FROM `donators` WHERE `accountID`='".. tostring(gameAccountID) .."' AND `expirationDate` > NOW() AND `perkID`='"..perkID.."' LIMIT 1")
						if (mysqlResult) then
							expirationDate = tostring(mysqlResult["expirationDate"])
						end
						table.insert(obtainedTable, { perkArr, expirationDate } )
					elseif perkArr[3] >= 1 then
						table.insert(availableTable, perkArr)
					end
				end
			end
		end

		local gameAccountID = getElementData(client, "account:id")
		if (gameAccountID) then
			if (gameAccountID > 0) then
				local mResult1 = dbQuery(exports.mysql:getConn("core"), "SELECT `credits` FROM `accounts` WHERE `id`=?", gameAccountID)
				local mResult1 = dbPoll(mResult1, 10000)
				if (mResult1) then
					donPoints = tonumber(mResult1[1]["credits"]) or 0
				end
			end
		end

		local donation_history = {}

		-- paypal
		local qh = dbQuery( exports.mysql:getConn('core'), "SELECT `txn_id`, `payer_email`, `mc_gross`, `date`, TO_SECONDS(date) AS datesec, `accounts`.`username` AS `donor`, (SELECT `username` FROM `accounts` WHERE `accounts`.`id`=`purchases`.`donated_for`) AS `donated_for` FROM `purchases` LEFT JOIN `accounts` ON `purchases`.`donor` = `accounts`.`id` WHERE `donor`=? OR `donated_for`=? ", gameAccountID, gameAccountID )
		local results = dbPoll( qh, 10000 )
		if results then
			for _, res in pairs( results ) do
				local tab = {}
				tab.id = res.txn_id
				tab.details = "PAYPAL - FROM "..(res.donor or 'UNKNOWN').." ("..res.payer_email..") to "..(res.donated_for or 'UNKNOWN')
				tab.amount = "USD "..res.mc_gross
				tab.date = res.date
				tab.datesec = res.datesec
				table.insert( donation_history, tab )
			end
		else
			dbFree(qh)
		end

		-- mobile
		qh = dbQuery( exports.mysql:getConn('mta'), "SELECT *, TO_SECONDS(date) AS datesec FROM mobile_payments WHERE account=? ", gameAccountID )
		results = dbPoll( qh, 10000 )
		if results then
			for _, res in pairs( results ) do
				local tab = {}
				tab.id = res.payment_id
				tab.details = "MOBILE - FROM "..res.sender_phone.." ("..res.operator.." - "..res.country..")"
				tab.amount = res.currency.." "..res.cost
				tab.date = res.date
				tab.datesec = res.datesec
				table.insert( donation_history, tab )
			end
		else
			dbFree(qh)
		end

		-- bitcoin
		--[[qh = dbQuery( exports.mysql:getConn('mta'), "SELECT *, TO_SECONDS(date) AS datesec FROM btc_invoices WHERE paid=1 AND account=? ", gameAccountID )
		results = dbPoll( qh, 10000 )
		if results then
			for _, res in pairs( results ) do
				local tab = {}
				tab.id = res.invoice_id
				tab.details = "BITCOIN - $"..res.price_in_usd.." (Ƀ"..res.price_in_btc.."), fee: "..res.fee_percent.."%"
				tab.amount = "USD "..res.price_in_usd
				tab.date = res.date
				tab.datesec = res.datesec
				table.insert( donation_history, tab )
			end
		else
			dbFree(qh)
		end]]

		table.sort( donation_history, function( a, b )
			return a.datesec > b.datesec
		end)

		--local recentPurchases = {}
		local globalPurchaseHistory = {}
		if exports.integration:isPlayerLeadAdmin(client) then
			--[[
			local mQuery3 = exports.mysql:query("SELECT `order_id`, `txn_id`, `payer_email`, `mc_gross`, `date`, `accounts`.`username` AS `username` FROM `donates` LEFT JOIN `accounts` ON `donates`.`donor` = `accounts`.`id` ORDER BY `date` DESC LIMIT 25")
			while true do
				local row = exports.mysql:fetch_assoc(mQuery3)
				if not row then break end
				table.insert(recentPurchases, row )
			end
			exports.mysql:free_result(mQuery3)
			]]
			local mQuery7 = exports.mysql:query("SELECT `name`, `cost`, `date`, `account` FROM `don_purchases` WHERE `cost` < 0 ORDER BY `date` DESC LIMIT 100")
			while true do
				local row = exports.mysql:fetch_assoc(mQuery7)
				if not row then break end
				table.insert(globalPurchaseHistory, {row["name"], row["cost"], row["date"], exports.cache:getUsernameFromId(row["account"]) or "Unknown" })
			end
			exports.mysql:free_result(mQuery7)
		end
		--[[
		local topDonorOfAllTimes = {}
		local mQuery4 = exports.mysql:query("SELECT DISTINCT `donor`, `username`, (SELECT SUM(`mc_gross`) FROM `donates` `x` WHERE `x`.`donor`=`d`.`donor`) AS `mc_gross` FROM `donates` `d` LEFT JOIN `accounts` `a` ON `a`.`id`=`d`.`donor` ORDER BY `mc_gross` DESC LIMIT 25")
		while true do
			local row = exports.mysql:fetch_assoc(mQuery4)
			if not row then break end
			table.insert(topDonorOfAllTimes, {row["username"], row["mc_gross"]} )
		end
		exports.mysql:free_result(mQuery4)

		local topDonorOfMonth = {}
		local mQuery5 = exports.mysql:query("SELECT DISTINCT `donor`, `username`, (SELECT SUM(`mc_gross`) FROM `donates` `x` WHERE `x`.`donor`=`d`.`donor` AND month(`x`.`date`)=month(NOW())) AS `mc_gross` FROM `donates` `d` LEFT JOIN `accounts` `a` ON `a`.`id`=`d`.`donor` WHERE month(`d`.`date`)=month(NOW()) ORDER BY `mc_gross` DESC LIMIT 25")
		while true do
			local row = exports.mysql:fetch_assoc(mQuery5)
			if not row then break end
			table.insert(topDonorOfMonth, {row["username"], row["mc_gross"]} )
		end
		exports.mysql:free_result(mQuery5)
		]]
		local purchaseHistory = {}
		local mQuery6 = exports.mysql:query("SELECT `name`, `cost`, `date` FROM `don_purchases` WHERE `account`='"..gameAccountID.."' ORDER BY `date` DESC")
		while true do
			local row = exports.mysql:fetch_assoc(mQuery6)
			if not row then break end
			table.insert(purchaseHistory, {row["name"], row["cost"], row["date"] })
		end
		exports.mysql:free_result(mQuery6)

		triggerClientEvent(client, "donation-system:GUI:open", client, obtainedTable, availableTable, donPoints, donation_history, purchaseHistory, globalPurchaseHistory)
	end
end
addEvent("donation-system:GUI:open", true)
addEventHandler("donation-system:GUI:open", getRootElement(), showDonationGUI)

function activateDonationPerk(thePerk, ...)
	local logged = getElementData(client, "loggedin")
	local donPoints = 0
	if logged~=1 then
		triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "You must be logged in to activate this perk.")
		showDonationGUI(client)
		return false
	end

	local gameAccountID = getElementData(source, "account:id")
	if gameAccountID and gameAccountID > 0 then
		local mResult1 = dbQuery(exports.mysql:getConn("core"), "SELECT `credits` FROM `accounts` WHERE `id`=?", gameAccountID)
		local mResult1 = dbPoll(mResult1, 10000)
		if (mResult1) then
			donPoints = tonumber(mResult1[1]["credits"]) or 0
		else
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Failed to retrieve your data from Server.")
			showDonationGUI(client)
			return false
		end
	else
		triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Failed to retrieve your account ID.")
		showDonationGUI(client)
		return false
	end
	thePerk = tonumber(thePerk)
	local perkDetails = donationPerks[ thePerk ]
	if not perkDetails then
		triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Invalid perk.")
		showDonationGUI(client)
		return false
	end


	if thePerk == 13 then -- GC transfer
		local data = (...)
		if (data.total <= donPoints) then
			local result, message = takeGC(client, data.total)
			if not result then
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Could not Transfer GC. Reason: "..message)
				showDonationGUI(client)
				return false
			end

			addPurchaseHistory(client, "Game Coins Transferred ("..data.amount.." GCs to "..data.target..")", -data.total)
			showDonationGUI(client)

			if dbExec(exports.mysql:getConn("core"), "UPDATE `accounts` SET `credits`=`credits`+? WHERE `username`=? ", data.amount, data.target) then
				for i, player in pairs(getElementsByType("player")) do
					if getElementData(player, "account:username") == data.target then
						local cur = getElementData(player, "credits")
						setElementData(player, "credits", cur+tonumber(data.amount))
						triggerClientEvent(player, "displayAchievement", player, "GAME COINS RECEIVED!", exports.global:getPlayerFullIdentity(client, 1).." has gifted you "..data.amount.." GCs.", data.amount)
						addPurchaseHistory(player, "Game Coins received from "..exports.global:getPlayerFullIdentity(client, 1).." ("..data.amount.." GCs)", data.amount)
						return true
					end
				end
			end
			addPurchaseHistory(data.target, "Game Coins received from "..exports.global:getPlayerFullIdentity(client, 1).." ("..data.amount.." GCs)", data.amount)
		else
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "You lack of GCs to transfer.")
			showDonationGUI(client)
			return false
		end
	elseif thePerk == 14 then -- maxints
		if (tonumber(perkDetails[2])*(tonumber(getElementData(client, "maxinteriors"))-9)*2 <= donPoints) then
			local result, message = givePlayerPerk(client, thePerk, nil, perkDetails[3], tonumber(perkDetails[2])*(tonumber(getElementData(client, "maxinteriors"))-9)*2, ... )
			if not result then
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..message)
				showDonationGUI(client)
				return false
			else
				showDonationGUI(client)
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, message)
				return true
			end
		else
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "You don't have enough points to activate '"..perkDetails[1] .."'")
			showDonationGUI(client)
			return false
		end
	elseif thePerk == 15 then -- maxvehs
		if (tonumber(perkDetails[2])*(tonumber(getElementData(client, "maxvehicles"))-4)*2 <= donPoints) then
			local result, message = givePlayerPerk(client, thePerk, nil, perkDetails[3], tonumber(perkDetails[2])*(tonumber(getElementData(client, "maxvehicles"))-4)*2, ... )
			if not result then
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..message)
				showDonationGUI(client)
				return false
			else
				showDonationGUI(client)
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, message)
				return true
			end
		else
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "You don't have enough points to activate '"..perkDetails[1] .."'")
			showDonationGUI(client)
			return false
		end
	elseif thePerk == 17 then -- keypad door lock
		local data = (...)

		if not data or not data[1] or not data[2] then
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: This interior is defected.")
			showDonationGUI(client)
			return false
		end

		local canPlayerCarryLocks = function ()
			local success, error = exports["item-system"]:loadItems( client )
			if success then
				local carriedWeight = exports["item-system"]:getCarriedWeight(client) or false
				local itemWeight = exports["item-system"]:getItemWeight(169, data[1]) or false
				local maxWeight = exports["item-system"]:getMaxWeight(client) or false
				--outputChatBox(itemWeight)
				if carriedWeight and itemWeight and maxWeight then
					return carriedWeight + itemWeight*2 <= maxWeight
				else
					outputDebugString( "Can't get carriedWeight or itemWeight or maxWeight")
					return false
				end
			else
				outputDebugString("loadItems error: " .. error)
				return false
			end
		end

		if not canPlayerCarryLocks() then
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: Your inventory is full!")
			showDonationGUI(client)
			return false
		end

		local takeGC, takeGcError = takeGC(client, perkDetails[2])
		if not takeGC then
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..takeGcError)
			showDonationGUI(client)
			return false
		end

		if exports.global:giveItem(client, 169, data[1]) and exports.global:giveItem(client, 169, data[1]) then
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Perk Activated! You have recieved a pair of keyless digital keypad door locks.")
			addPurchaseHistory(client, perkDetails[1].." (For "..data[2]..", ID #"..data[1]..")", -perkDetails[2])
			showDonationGUI(client)
			return true
		else
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk, please take screenshot and make a GC refund request on forums.")
			showDonationGUI(client)
			return false
		end
	elseif thePerk == 28 then
		if (perkDetails[2] <= donPoints) then
			local result, message = givePlayerPerk(client, thePerk, nil, perkDetails[3], perkDetails[2], ... )
			if not result then
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..message)
				showDonationGUI(client)
				return false
			else
				showDonationGUI(client)
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Perk Activated! Please switch to 'Activated perks' tab to set up your station.")
				return true
			end
		else
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "You don't have enough points to activate '"..perkDetails[1] .."'")
			showDonationGUI(client)
			return false
		end
	elseif thePerk == 29 then
		if (perkDetails[2] <= donPoints) then
			local result, message = givePlayerPerk(client, thePerk, table.concat({...}, " "), perkDetails[3], perkDetails[2], ... )
			if not result then
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..message)
				showDonationGUI(client)
				return false
			else
				showDonationGUI(client)
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, message)
				return true
			end
		else
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "You don't have enough points to activate '"..perkDetails[1] .."'")
			showDonationGUI(client)
			return false
		end
	elseif thePerk == 32 then
		local currentHoursPlayed = getElementData(client, "hoursplayed") or 0
		if currentHoursPlayed >= 15 then
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: You've already had 15 or more hours played on this character.")
			showDonationGUI(client)
			return false
		end

		local takeGC, takeGcError = takeGC(client, perkDetails[2])
		if not takeGC then
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..takeGcError)
			showDonationGUI(client)
			return false
		end

		setPlayerAnnounceValue ( client, "score", currentHoursPlayed+15 )
		exports.anticheat:changeProtectedElementDataEx(client, "hoursplayed", currentHoursPlayed+15, true)
		exports.mysql:query_free( "UPDATE characters SET hoursplayed = hoursplayed + 15 WHERE id = " .. getElementData(client, "dbid") )
		showDonationGUI(client)
		triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Your character has recieved instant 15 hoursplayed!")
		addPurchaseHistory(client, perkDetails[1], -perkDetails[2])
		return true

	elseif thePerk == 34 then --learn language
		local language = tonumber(table.concat({...}, " ")) or 0
		if language > 0 and language <= exports["language-system"]:getLanguageCount() then
			local langName = exports["language-system"]:getLanguageName(language)
			if langName == "<Invalid/Bugged Language>" then
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: Invalid language!")
				return false
			end
			local hasLanguage, slot = exports["language-system"]:doesPlayerHaveLanguage(client, language)
			if hasLanguage then
				local skill = tonumber(exports["language-system"]:getSkillFromLanguage(client, language)) or 0
				if skill < 100 then
					local result, resultMsg = exports["language-system"]:learnLanguage(client, language, false, 100)
					if result then
						local takeGC, takeGcError = takeGC(client, perkDetails[2])
						if not takeGC then
							--if it fails for GC reasons, reset language value back to what it was
							exports["language-system"]:removeLanguage(client, language)
							exports["language-system"]:learnLanguage(client, language, false, skill)
							triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..takeGcError)
							showDonationGUI(client)
							return false
						else
							showDonationGUI(client)
							triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Your character learned "..tostring(langName).."!")
							addPurchaseHistory(client, perkDetails[1], -perkDetails[2])
							return true
						end
					else
						triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..tostring(resultMsg))
						return false
					end
				else
					triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: Your character already fully learnt "..tostring(langName).."!")
				end
			else
				local result, resultMsg = exports["language-system"]:learnLanguage(client, language, false, 100)
				if result then
					local takeGC, takeGcError = takeGC(client, perkDetails[2])
					if not takeGC then
						--if it fails for GC reasons, revoke the language (as player did not have it before)
						exports["language-system"]:removeLanguage(client, language)
						triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..takeGcError)
						showDonationGUI(client)
						return false
					else
						showDonationGUI(client)
						triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Your character learned "..tostring(langName).."!")
						addPurchaseHistory(client, perkDetails[1], -perkDetails[2])
						return true
					end
				else
					triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..tostring(resultMsg))
					return false
				end
			end
		end

	else
		if (perkDetails[2] <= donPoints) then
			local result, message = givePlayerPerk(client, thePerk, nil, perkDetails[3], perkDetails[2], ... )
			if not result then
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "Error while activating donation perk: "..message)
				showDonationGUI(client)
				return false
			else
				showDonationGUI(client)
				triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, message)
				return true
			end
		else
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 1, "You don't have enough points to activate '"..perkDetails[1] .."'")
			showDonationGUI(client)
			return false
		end
	end
end
addEvent("donation-system:GUI:activate", true)
addEventHandler("donation-system:GUI:activate", getRootElement(), activateDonationPerk)

function removePerk(perkID)
	if not tonumber(perkID) then
		triggerClientEvent(client, "donation-system:getResponseFromServer", client, 2, "Failed to send data to server.")
		showDonationGUI(client)
		return false
	else
		perkID = tostring(perkID)
	end

	if (hasPlayerPerk(client, perkID)) then
		local gameAccountID = getElementData(client, "account:id")
		if gameAccountID and gameAccountID > 0 then
			exports.mysql:query_free("DELETE FROM `donators` WHERE `accountID`='".. tostring(gameAccountID)  .."' AND `perkID`='".. exports.mysql:escape_string(tostring(perkID)) .."' ")
			loadAllPerks(client)
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 2, "Perk removed.")
			showDonationGUI(client)
			return true
		else
			triggerClientEvent(client, "donation-system:getResponseFromServer", client, 2, "Failed to retrieve your account ID.")
			showDonationGUI(client)
			return false
		end
	else
		triggerClientEvent(client, "donation-system:getResponseFromServer", client, 2, "You don't have this perk anymore.")
		showDonationGUI(client)
		return false
	end

	triggerClientEvent(client, "donation-system:getResponseFromServer", client, 2, "Something went wrong.")
	showDonationGUI(client)
	return false
end
addEvent("donation-system:GUI:remove", true)
addEventHandler("donation-system:GUI:remove", getRootElement(), removePerk)

function sortTable(tab)
	for i=1,#tab do
		for j=1, #tab-1 do
			if tonumber(tab[j][2]) < tonumber(tab[j+1][2]) then
				local temp = tab[j+1]
				tab[j+1] = tab[j]
				tab[j] = temp
			end
		end
	end
	return tab
end
