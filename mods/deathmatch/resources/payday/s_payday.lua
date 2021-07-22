--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local mysql = exports.mysql

local incomeTax = 0
local taxVehicles = {}
local insuranceVehicles = {}
local vehicleCount = {}
local taxHouses = {}
local rentalHouses = {}
local threads = { }
local threadTimer = nil
local govAmount = 10000000
local unemployedPay = 200

function payWage(player, pay, faction, tax)
	local dbid = tonumber(getElementData(player, "dbid"))
	local governmentIncome = 0
	local bankmoney = getElementData(player, "bankmoney")
	local noWage = pay == 0
	local donatormoney = 0
	local startmoney = bankmoney

	if (exports.donators:hasPlayerPerk(player, 4)) then
		donatormoney = donatormoney + 25
	end

	if (exports.donators:hasPlayerPerk(player, 5)) then
		donatormoney = donatormoney + 75
	end

 	local interest = 0
 	local cP = 0
 	if bankmoney > 0 then
		interest = math.min(1000, math.floor(2 * math.sqrt(bankmoney)))
		cP = interest / bankmoney * 100
	end

	if interest ~= 0 then
		dbExec( exports.mysql:getConn('mta'), "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (-17, ?, ?, 'BANKINTEREST', 12)", dbid, interest )
	end

	bankmoney = bankmoney + math.max( 0, pay ) + interest + donatormoney

	if not faction then
		if bankmoney > 25000 then
			noWage = true
			pay = 0
		elseif pay > 0 then
			governmentIncome = governmentIncome - pay
			dbExec( exports.mysql:getConn('mta'), "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (-3, ?, ?, 'STATEBENEFITS', 6)", dbid, pay )
		else
			pay = 0
		end
	else
		if pay > 0 then
			local teamid = faction
			if teamid <= 0 then
				teamid = 0
			else
				teamid = -teamid
			end

			local freeWageAmount = getElementData(exports.factions:getFactionFromID(faction), "before_wage_charge")
			if pay > freeWageAmount then
				dbExec(exports.mysql:getConn('mta'), "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (?, ?, ?, 'WAGE', 6)", teamid, dbid, pay - freeWageAmount)
			end
		else
			pay = 0
		end
	end

	if tax > 0 then
		pay = pay - tax
		bankmoney = bankmoney - tax
		governmentIncome = governmentIncome + tax
		dbExec( exports.mysql:getConn('mta'), "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (?, -3, ?, 'INCOMETAX', 11)", dbid, tax )
	end

	local vtax = taxVehicles[ dbid ] or 0
	if vtax > 0 then
		vtax = math.min( vtax, bankmoney )
		bankmoney = bankmoney - vtax
		governmentIncome = governmentIncome + vtax
		dbExec( exports.mysql:getConn('mta'), "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (?, -3, ?, 'VEHICLETAX', 11)", dbid, vtax )
	end

	--vehicle insurance
	local totalInsFee, totalInsFeePerVehicles, totalInsFeePerFactions = 0, {}, {}
	if exports.global:isResourceRunning("insurance") and  exports.global:isResourceRunning("factions") then
		totalInsFee, totalInsFeePerVehicles, totalInsFeePerFactions = exports.insurance:analyzeInsurance(insuranceVehicles[ dbid ], getElementData(player, "dbid"))
		if totalInsFee > 0 then
			if bankmoney >= totalInsFee then
				bankmoney = bankmoney - totalInsFee
				for factionId, data in pairs(totalInsFeePerFactions) do
					if data.fee > 0 then
						local theFaction = exports.factions:getFactionFromID(factionId)
						if exports.bank:giveBankMoney(theFaction, data.fee) then
							exports.bank:addBankTransactionLog(dbid, -factionId, data.fee, 14, "Insurance fees for "..(#(data.vehs)).." vehicles: "..tostring(table.concat(data.vehs, ", "))..".")
						end
					end
				end
			else
				totalInsFee = -1
				if  exports.global:isResourceRunning("announcement") then
					local customerName = getPlayerName(player):gsub("_", " ")
					for factionId, data in pairs(totalInsFeePerFactions) do
						local details = 'List of insured vehicles from customer '..customerName..":\n\n"
						for i, vehid in pairs(data.vehs) do
							details = details..'Vehicle VIN #'..vehid.."\n"
						end
						details = details.."\nTotal: $"..exports.global:formatMoney(data.fee)
						exports.factions:sendNotiToAllFactionMembers(factionId, customerName.." has failed to pay his total insurance fees of $"..exports.global:formatMoney(data.fee).." over his "..(#(data.vehs)).." vehicles.", details)
					end
				end
			end
		end
	end

	local ptax = taxHouses[ dbid ] or 0
	if ptax > 0 then
		ptax = math.floor( ptax )
		ptax = math.min( ptax, bankmoney )
		bankmoney = bankmoney - ptax
		governmentIncome = governmentIncome + ptax
		dbExec( exports.mysql:getConn('mta'), "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (?, -3, ?, 'PROPERTYTAX', 11)", dbid, ptax )
	end

	-- solve interior rentals
	local total_int_rentals = 0
	if rentalHouses[ dbid ] and not exports.donators:hasPlayerPerk(player, 41) then
		for int_id, cost in pairs( rentalHouses[ dbid ] ) do
			if bankmoney >= cost then
				bankmoney = bankmoney - cost
				total_int_rentals = total_int_rentals + cost
				dbExec( exports.mysql:getConn('mta'), "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (?, 0, ?, 'HOUSERENT', 6)", dbid, cost )
			else
				if exports.global:isResourceRunning("interior_system") then
					exports.interior_system:publicSellProperty( player, int_id, false, true )
					-- let them know
					local account = exports.cache:getAccountFromCharacterId(dbid) or {id = 0, username="No-one"}
					local characterName = exports.cache:getCharacterNameFromID(dbid) or "No-one"
					if account then
						exports.announcement:makePlayerNotification(account.id, characterName.." could not afford rent of interior ID #"..int_id..".", "You have lost this interior because the rental contract was broken.\nCould not afford $"..exports.global:formatMoney(cost).." for the rent of the interior.", "interior_inactivity_scanner")
					end
					-- leave some history for administrative purposes.
					exports["interior-manager"]:addInteriorLogs(int_id, "Broke rental contract (Could not afford $"..exports.global:formatMoney(cost)..")", player)
				end
			end
		end
	end

	-- save the bankmoney
	exports.anticheat:changeProtectedElementDataEx(player, "bankmoney", bankmoney, true)

	-- let the client tell them the (bad) news
	local grossincome = pay+interest+donatormoney-total_int_rentals-vtax-ptax-totalInsFee
	triggerClientEvent(player, "cPayDay", player, faction, noWage and -1 or pay, 0, interest, donatormoney, tax, incomeTax, vtax, ptax, total_int_rentals, totalInsFee, grossincome, cP)

	return governmentIncome
end

function processFactionTaxes(taxVehicles, taxHouses, rentalHouses)
	local totalTaxPaid = {}

	for k,v in pairs(taxVehicles) do
		if k<0 and v>0 then -- Must be a faction
			local team = exports.factions:getFactionFromID(-k)
			if team then
				if not totalTaxPaid[-k] then totalTaxPaid[-k] = 0 end
				totalTaxPaid[-k] = v or 0
				exports.global:takeMoney(team, v, true)
				exports.bank:addBankTransactionLog(k, -3, v, 11, "Vehicle Taxes to Government" )
			end
		end
	end

	for k,v in pairs(taxHouses) do
		if k<0 and v>0 then -- Must be a faction
			local team = exports.factions:getFactionFromID(-k)
			if team then
				if not totalTaxPaid[-k] then totalTaxPaid[-k] = 0 end
				totalTaxPaid[-k] = totalTaxPaid[-k] + v
				exports.global:takeMoney(team, v, true)
				exports.bank:addBankTransactionLog(k, -3, v, 11, "Interior Taxes to Government")
			end
		end
	end

	for k,v in pairs(rentalHouses) do
		if k<0 and v>0 then -- Must be a faction
			local team = exports.factions:getFactionFromID(-k)
			if team then
				if not totalTaxPaid[-k] then totalTaxPaid[-k] = 0 end
				totalTaxPaid[-k] = totalTaxPaid[-k] + v
				exports.global:takeMoney(team, v, true)
				exports.bank:addBankTransactionLog(k, -3, v, 11, "Interior Rent Taxes to Government")
			end
		end
	end
end

function payAllWages(isForcePayday)
	if isForcePayday then
		outputDebugString('[PAYDAY] Server / payAllWages / Ran (Forced).')
	else
		outputDebugString('[PAYDAY] Server / payAllWages / Ran.')
		local mins = getRealTime().minute
		local minutes = 60 - mins
		if (minutes < 15) then
			minutes = minutes + 60
		end
		setTimer(payAllWages, 60000*minutes, 1, false)
	end
	loadWelfare( )
	threads = { }
	taxVehicles = {}
	vehicleCount = {}
	insuranceVehicles = {}
	local inactiveVehicles = {}
	inactiveVehicles.soon = 0
	inactiveVehicles.processed = 0

	local assetCounter = {}

	for _, theFaction in pairs(exports.pool:getPoolElementsByType("team")) do 
		local factionId = getElementData(theFaction, "id")
		if factionId then
			assetCounter[factionId] = 0
		end
	end

	for _, veh in pairs(getElementsByType("vehicle")) do
		if isElement(veh) then
			local owner, faction, registered = tonumber(getElementData(veh, "owner")) or 0, tonumber(getElementData(veh, "faction")) or 0, tonumber(getElementData(veh, "registered")) or 0
			local vehid = getElementData(veh, "dbid") or 0
			if vehid >0 and faction <= 0 and owner > 0 then
				-- Vehicle inactivity scanner / MAXIME / 2015.1.11

				local deletedByScanner = nil
				local vehicleInactivityScannerActive = (get("inactivityscanner_vehicles") == "1" or false)
				--outputDebugString("test = "..tostring(get("inactivityscanner_vehicles")))
				if vehicleInactivityScannerActive then
					--outputDebugString("Deleting inactive vehicles")
					local active, reason, secs = exports.vehicle:isActive(veh)
					if not exports.vehicle:isProtected(veh) then
						if active then
							if reason and tonumber(reason) then
								inactiveVehicles.soon = inactiveVehicles.soon + 1
								local name = exports.global:getVehicleName(veh)
								local account = exports.cache:getAccountFromCharacterId(owner) or {id = 0, username="No-one"}
								local characterName = exports.cache:getCharacterNameFromID(owner) or "No-one"
								--outputDebugString(account.username or "idk")
								if owner > 0 and account then
									local remainTime = exports.datetime:formatSeconds(reason)
									exports.announcement:makePlayerNotification(account.id, "WARNING! Vehicle ID #"..vehid.." ("..name..") is about to be taken away from "..characterName.."'s possession by the vehicle inactivity scanner", "Your vehicle was marked as inactive because your character hasn't been logged in game for longer than 30 days or no body has ever started its engine for longer than 14 days while parking outdoor. \n\nAn inactive vehicle is a waste of resources and thus far the vehicle's ownership was removed or stripped from your possession to give other players opportunities to buy and use it more efficiently.\n\nThis vehicle wasn't unprotected. To prevent this to happen again to other vehicles of yours, you may want to spend your GC(s) to protect it from the inactive vehicle scanner on UCP.\n\nYou have exactly "..remainTime.." to reactivate your vehicle before it's too late!", "vehicle_inactivity_scanner")
								end
							end
						else
							local name = exports.global:getVehicleName(veh)
							if exports.vehicle_manager:systemDeleteVehicle(vehid, "Deleted by Inactivity Scanner. Reason: "..reason) then
								inactiveVehicles.processed = inactiveVehicles.processed + 1
								local account = exports.cache:getAccountFromCharacterId(owner) or {id = 0, username="No-one"}
								local characterName = exports.cache:getCharacterNameFromID(owner) or "No-one"
								if owner > 0 and account then
									exports.announcement:makePlayerNotification(account.id, "Vehicle ID #"..vehid.." ("..name..") was taken away from "..characterName.."'s possession by the vehicle inactivity scanner.", "Reason: "..reason..". Your vehicle was marked as inactive because your character hasn't been logged in game for longer than 30 days or no body has ever started its engine for longer than 14 days while parking outdoor. \n\nAn inactive vehicle is a waste of resources and thus far the vehicle's ownership was removed or stripped from your possession to give other players opportunities to buy and use it more efficiently.\n\nThis vehicle wasn't unprotected. To prevent this to happen again to other vehicles of yours, you may want to spend your GC(s) to protect it from the inactive vehicle scanner on UCP.", "vehicle_inactivity_scanner")
								end
								--exports.global:sendMessageToAdmins("[VEHICLE] Vehicle ID #"..vehid.." ("..name..", owner: "..characterName.." - "..account.username..") has been deleted by the vehicle inactivity scanner. "..reason)
								deletedByScanner = true
							end
						end
					end
				end

				if registered == 1 and not deletedByScanner then
					--Taxes
					local tax = tonumber(getElementData(veh, "carshop:taxcost")) or 25
					if tax > 0 then
						taxVehicles[owner] = ( taxVehicles[owner] or 0 ) + ( tax * 1 )
						--[[vehicleCount[owner] = ( vehicleCount[owner] or 0 ) + 1
						if vehicleCount[owner] > 3 then -- $75 for having too much vehicles, per vehicle more than 3
							taxVehicles[owner] = taxVehicles[owner] + 50
						end]]
					end

					--Insurance
					if exports.global:isResourceRunning("insurance") then
						local insuranceFee = getElementData(veh, "insurance:fee") or 0
						insurancefee = tonumber(insurancefee)
						local insuranceFaction = getElementData(veh, "insurance:faction") or 0
						insuranceFaction = tonumber(insuranceFaction)
						if insuranceFee > 0 and insuranceFaction > 0 then
							if not insuranceVehicles[owner] then insuranceVehicles[owner] = {} end
							if not insuranceVehicles[owner][vehid] then insuranceVehicles[owner][vehid] = {} end
							if not insuranceVehicles[owner][vehid][insuranceFaction] then insuranceVehicles[owner][vehid][insuranceFaction] = 0 end
							insuranceVehicles[owner][vehid][insuranceFaction] = insuranceVehicles[owner][vehid][insuranceFaction] + insuranceFee
						end
					end
				end
			elseif faction > 0 and vehid > 0 and registered == 1 and (getRealTime().hour+1) % 6 == 0 then -- Every 6 hours
				local type = exports.factions:getFactionType(faction)
				if type and (tonumber(type) < 2 or tonumber(type) > 4) then -- Legal factions
					local factionAssetLimit = getElementData(exports.factions:getFactionFromID(faction), "before_tax_value")
					local tax = tonumber(getElementData(veh, "carshop:taxcost")) or 25
					local cost = tonumber(getElementData(veh, "carshop:cost"))

					if assetCounter[faction] > factionAssetLimit then
						taxVehicles[-faction] = ( taxVehicles[-faction] or 0 ) + ( tax * 1 )
					end

					assetCounter[faction] = assetCounter[faction] + cost
				end
			end
		end
	end

	if inactiveVehicles.processed > 0 then
		exports.global:sendMessageToAdmins("[VEHICLE] Inactivity Scanner has just deleted "..inactiveVehicles.processed.." inactive vehicles and detected "..inactiveVehicles.soon.." vehicles possibly becoming inactive within next 12 hours.")
	end

	-- count all player props
	taxHouses = { }
	rentalHouses = { }
	local inactiveInteriors = {}
	inactiveInteriors.soon = 0
	inactiveInteriors.processed = 0
	for _, property in pairs( getElementsByType( "interior" ) ) do
		local interiorStatus = getElementData(property, "status")
		local cost = interiorStatus.cost or 0
		local owner = interiorStatus.owner or 0
		local faction = interiorStatus.faction or 0
		local type = interiorStatus.type
		local intid = getElementData(property, "dbid")
		local name = getElementData(property, "name")
		if cost > 0 and owner > 0 and faction <= 0 then
			-- residentals & businesses
			if type < 2 then
				local propertyTax = getPropertyTaxRate(interiorStatus.type)
				taxHouses[ owner ] = ( taxHouses[ owner ] or 0 ) + propertyTax * cost
			-- rentable interiors
			elseif type == 3 then
				rentalHouses[ owner ] = rentalHouses[ owner ] or { }
				rentalHouses[ owner ][ intid ] = ( rentalHouses[ owner ][ intid ] or 0 ) + cost
			end
		elseif owner >= -1 and cost > 0 and faction > 0 then
			local ftype = exports.factions:getFactionType(faction)
			if tonumber(ftype) and (tonumber(ftype) < 2 or tonumber(ftype) > 4) then -- Legal factions
				-- residentals & businesses
				if type < 2 then
					local propertyTax = getPropertyTaxRate(interiorStatus.type, true) -- True indicates it is a faction interior
					local factionAssetLimit = getElementData(exports.factions:getFactionFromID(faction), "before_tax_value")

					if assetCounter[faction] > factionAssetLimit then
						taxHouses[ -faction ] = ( taxHouses[ -faction ] or 0 ) + propertyTax * cost
					end

					assetCounter[faction] = assetCounter[faction] + cost
					-- rentable interiors
				elseif type == 3 then
					rentalHouses[ -faction ] = rentalHouses[ -faction ] or { }
					rentalHouses[ -faction ][ intid ] = ( rentalHouses[ -faction ][ intid ] or 0 ) + cost
				end
			end
		end

		-- Interior inactivity scanner
		local interiorInactivityScannerActive = (get("inactivityscanner_interiors") == "1" or false)
		--outputDebugString("inactivityscanner_interiors="..tostring(get("inactivityscanner_interiors")))
		if interiorInactivityScannerActive then
			--outputDebugString("Deleting inactive interiors.")
			local active, reason = exports.interior_system:isActive(property)
			if not exports.interior_system:isProtected(property) then
				if active then
					if reason and tonumber(reason) then
						inactiveInteriors.soon = inactiveInteriors.soon + 1
						local account = exports.cache:getAccountFromCharacterId(owner) or {id = 0, username="No-one"}
						local characterName = exports.cache:getCharacterNameFromID(owner) or "No-one"
						if owner > 0 and account then
							local remainTime = exports.datetime:formatSeconds(reason)
							exports.announcement:makePlayerNotification(account.id, "WARNING! Interior ID #"..intid.." ("..name..") is about to be taken away from "..characterName.."'s possession by the interior inactivity scanner", "Your interior was marked as inactive because no body has ever entered it for the last 14 days or your character(who owns it) hasn't been logged in game for 30 days.\n\nAn inactive interior is a waste of resources and thus far the interior's ownership was stripped from your possession to give other players opportunities to buy and use it more efficiently.\n\nThis interior wasn't unprotected. To prevent this to happen again to other interiors of yours, you may want to spend your GC(s) to protect it from the inactive interior scanner on UCP.\n\nYou have exactly "..remainTime.." to reactivate your property before it's too late!", "interior_inactivity_scanner")
						end
					end
				else
					if exports.interior_system:unownProperty(intid, "Forcesold by Inactivity Scanner. Reason: "..reason) then
						local account = exports.cache:getAccountFromCharacterId(owner) or {id = 0, username="No-one"}
						local characterName = exports.cache:getCharacterNameFromID(owner) or "No-one"
						if owner > 0 and account then
							exports.announcement:makePlayerNotification(account.id, "Interior ID #"..intid.." ("..name..") was taken away from "..characterName.."'s possession by the interior inactivity scanner.", "Reason: "..reason..". Your interior was marked as inactive because no body has ever entered it for the last 14 days or your character(who owns it) hasn't been logged in game for 30 days.\n\nAn inactive interior is a waste of resources and thus far the interior's ownership was stripped from your possession to give other players opportunities to buy and use it more efficiently.\n\nThis interior wasn't unprotected. To prevent this to happen again to other interiors of yours, you may want to spend your GC(s) to protect it from the inactive interior scanner on UCP.", "interior_inactivity_scanner")
						end
						inactiveInteriors.processed = inactiveInteriors.processed + 1
					end
				end
			end
		end
	end

	if inactiveInteriors.processed > 0 then
		exports.global:sendMessageToAdmins("[INTERIOR] Inactivity Scanner has just forcesold "..inactiveInteriors.processed.." inactive interiors and detected "..inactiveInteriors.soon.." interiors possibly becoming inactive within next 12 hours.")
	end

	-- Call to the tow system to clean up any excessively long impounded vehicles.
	if getRealTime().hour == 5 then
		exports['tow-system']:clearImpound()
	end

	-- Check shellcasings for > 1 week old ones daily at 3am
	if getRealTime().hour == 2 then
		triggerEvent('item-system:shellcasings', root)
	end

	-- Get some data
	govAmount = 1000000 --exports.global:getMoney(getTeamFromName("Government of Los Santos"))
	incomeTax = exports.global:getIncomeTaxAmount()

	for _, value in ipairs( getElementsByType('player') ) do
		if (tonumber(getElementData(value, "loggedin")) == 1) then
			local co = coroutine.create(doPayDayPlayer)
			coroutine.resume(co, value, isForcePayday)
			table.insert(threads, co)
		end
	end

	processFactionTaxes(taxVehicles, taxHouses, rentalHouses)

	-- trigger one event to run whatever functions anywhere that needs to be executed hourly
	triggerEvent('payday:run', resourceRoot)

	threadTimer = setTimer(resumeThreads, 1000, 0)
end

function resumeThreads()
	local inFor = false
	for threadRow, threadValue in ipairs(threads) do
		if coroutine.status(threadValue) ~= "dead" then
			inFor = true
			coroutine.resume(threadValue)
			table.remove(threads,threadRow)
			break
		end
	end

	if not inFor then
		killTimer(threadTimer)
	end
end

local licenseCheck = {
	"car",
	"bike",
	"boat",
	"fish",
	"gun",
	"gun2"
}

function doPayDayPlayer(value, isForcePayday)
	if not isForcePayday then
		coroutine.yield()
	end

	if not ( isElement( value ) and getElementType( value ) == 'player' ) then -- only run payday for players?
		return
	end

	local sqlupdate = ""
	local logged = getElementData(value, "loggedin")
	local timeinserver = getElementData(value, "timeinserver")
	local dbid = getElementData( value, "dbid" )
	if ((logged==1) and (timeinserver>=58) and (getPlayerIdleTime(value) < 600000)) or isForcePayday then
		for i = 1, #licenseCheck do
			local license = getElementData(value, "license."..licenseCheck[i])
			if license and license < 0 then
				if tonumber(license) == -1 then
					sqlupdate = sqlupdate .. ", "..licenseCheck[i].."_license = "..licenseCheck[i].."_license + 2" -- Brings it back online.
					exports.anticheat:changeProtectedElementDataEx(value, "license."..licenseCheck[i], license + 2, true)
				else
					sqlupdate = sqlupdate .. ", "..licenseCheck[i].."_license = "..licenseCheck[i].."_license + 1"
					exports.anticheat:changeProtectedElementDataEx(value, "license."..licenseCheck[i], license + 1, true)
				end
			end
		end

		local playerFaction = getElementData(value, "faction")
		local duty = getElementData(value, "duty") or 0
        if duty > 0 then
           	local foundPackage = exports.factions:getCurrentFactionDuty(value)

            if not foundPackage then
                triggerEvent("duty:offduty", value)
                outputChatBox("You don't have access to the duty you are using anymore - thus, removed.", value, 255, 0, 0)
            end

			local factionType = exports.factions:getPlayerFactionTypes(value)

			if ((factionType[2]) or (factionType[3]) or (factionType[4]) or (factionType[5]) or (factionType[6]) or (factionType[7])) and foundPackage then -- Factions with wages
				local team = exports.factions:getFactionFromID(foundPackage)
				local wages = getElementData(team,"wages")
				local freeWageAmount = getElementData(team, "before_wage_charge")

				local factionRank = playerFaction[foundPackage].rank
				local rankWage = tonumber( wages[factionRank] )

				local taxes = 0

				if rankWage > freeWageAmount then 
					exports.global:takeMoney(team, rankWage - freeWageAmount)
					taxes = math.ceil(incomeTax * rankWage) 
				else 
					taxes = math.ceil(incomeTax * rankWage)
				end

				govAmount = govAmount + payWage(value, rankWage, foundPackage, taxes)
			else
				if unemployedPay >= govAmount then
					unemployedPay = -1
				end
				govAmount = govAmount + payWage( value, unemployedPay, false, 0 )
			end
		else
			if unemployedPay >= govAmount then
				unemployedPay = -1
			end
			govAmount = govAmount + payWage( value, unemployedPay, false, 0 )
			--outputDebugString(unemployedPay.." "..govAmount)
		end
		exports.anticheat:changeProtectedElementDataEx(value, "timeinserver", math.max(0, timeinserver-60), false, true)
		local hoursplayed = getElementData(value, "hoursplayed") or 0
		setPlayerAnnounceValue ( value, "score", hoursplayed+1 )
		exports.anticheat:setEld(value, "hoursplayed", hoursplayed+1, 'all')
		dbExec( exports.mysql:getConn('mta'), "UPDATE characters SET hoursplayed = hoursplayed + 1, bankmoney=? "..sqlupdate.." WHERE id=? ", getElementData( value, "bankmoney" ), dbid )
		--Referring
		if getElementData(value, "referrer") and getElementData(value, "hoursplayed") == 50 then
			local gc2Award = 150
			dbExec( exports.mysql:getConn('core'), "UPDATE `accounts` SET `credits`=`credits`+? WHERE `id`=? ", gc2Award, getElementData(value, "referrer") )
			dbExec( exports.mysql:getConn('mta'), "INSERT INTO `don_purchases` SET `name`=?, `cost`=?, `account`=? ", "Referring reward - Your friend '"..getElementData(value, "account:username").."' who has reached 50 hoursplayed on character '"..exports.global:getPlayerName(value).."'", gc2Award, getElementData(value, "referrer") )
			exports.global:sendMessageToAdmins("[ACHIEVEMENT] Player '"..exports.cache:getUsernameFromId(getElementData(value, "referrer")).."' has been rewarded with "..gc2Award.." GC(s) for referring his friend '"..getElementData(value, "account:username").."' who has reached 50 hoursplayed on character '"..exports.global:getPlayerName(value).."'! ")
			exports.announcement:makePlayerNotification(getElementData(value, "referrer"), "Congratulations! You were rewarded with "..gc2Award.." GC(s) for referring your friend", getElementData(value, "account:username").." has reached 50 hoursplayed on character "..exports.global:getPlayerName(value)..".")
			exports.announcement:makePlayerNotification(getElementData(value, "account:id"), exports.cache:getUsernameFromId(getElementData(value, "referrer")).." was rewarded with "..gc2Award.." GC(s) for referring you", "You have reached 50 hoursplayed on character "..exports.global:getPlayerName(value).."! Congratulations and thank you for playing.")
		end
	elseif (getPlayerIdleTime(value) > 600000) then
		--exports.global:sendMessageToAdmins("[PAYDAY] No payday for '"..getPlayerName(value):gsub("_", " ").."' as they've gone 10 minutes without movement.")
	elseif (logged==1) and (timeinserver) and (timeinserver<60) then
		outputChatBox("You have not played long enough to receive a payday. (You require another " .. 60-timeinserver .. " minutes of play.)", value, 255, 0, 0)
	end
end

function adminDoPaydayAll(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) and (exports.integration:isPlayerLeadAdmin(thePlayer)) then
		outputChatBox("Pay day has been successfully forced for all players", thePlayer, 0, 255, 0)
		exports.global:sendMessageToAdmins("[PAYDAY]: " .. exports.global:getPlayerFullIdentity(thePlayer) .. " has forced payday for ALL players")
		payAllWages(true)
	end
end
addCommandHandler("forcepaydayall", adminDoPaydayAll)

function adminDoPaydayOne(thePlayer, commandName, targetPlayerName)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		if not targetPlayerName then
			outputChatBox("SYNTAX: /".. commandName .. " [Partial Player Nick / ID]", thePlayer, 255, 194, 14)
		else
			local logged = getElementData(thePlayer, "loggedin")
			if (logged==1) then
				targetPlayer = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerName)
				if targetPlayer then
					if getElementData(targetPlayer, "loggedin") == 1 then
						outputChatBox("Pay day successfully forced for player " .. getPlayerName(targetPlayer):gsub("_", " "), thePlayer, 0, 255, 0)
						exports.global:sendMessageToAdmins("[PAYDAY]: " .. exports.global:getPlayerFullIdentity(thePlayer) .. " has forced payday for player " .. getPlayerName(targetPlayer))
						doPayDayPlayer(targetPlayer, true)
					else
						outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
						return
					end
				else
					outputChatBox("Failed to force payday.", thePlayer, 255, 0, 0)
					return
				end
			end
		end
	end
end
addCommandHandler("forcepayday", adminDoPaydayOne)

function timeSaved(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		local timeinserver = getElementData(thePlayer, "timeinserver")

		if (timeinserver>60) then
			timeinserver = 60
		end

		outputChatBox("You currently have " .. timeinserver .. " Minutes played.", thePlayer, 255, 195, 14)
		outputChatBox("You require another " .. 60-timeinserver .. " Minutes to obtain a payday.", thePlayer, 255, 195, 14)
	end
end
addCommandHandler("timesaved", timeSaved)

function loadWelfare( )
	local result = mysql:query_fetch_assoc( "SELECT value FROM settings WHERE name = 'welfare'" )
	if result then
		if not result.value then
			mysql:query_free( "INSERT INTO settings (name, value) VALUES ('welfare', " .. unemployedPay .. ")" )
		else
			unemployedPay = tonumber( result.value ) or 200
		end
	end
end

function startResource()
	local mins = getRealTime().minute
	local minutes = 60 - mins
	setTimer(payAllWages, 60000*minutes, 1, false)
	loadWelfare( )
	addEvent('payday:run', true)
end
addEventHandler("onResourceStart", getResourceRootElement(), startResource)
