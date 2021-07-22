--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

MTAoutputChatBox = outputChatBox
function outputChatBox( text, visibleTo, r, g, b, colorCoded )
	if text then
		if string.len(text) > 128 then -- MTA Chatbox size limit
			MTAoutputChatBox( string.sub(text, 1, 127), visibleTo, r, g, b, colorCoded  )
			outputChatBox( string.sub(text, 128), visibleTo, r, g, b, colorCoded  )
		else
			MTAoutputChatBox( text, visibleTo, r, g, b, colorCoded  )
		end
	end
end

 function getInteriorOwner( dimension )
	if dimension == 0 then
		return nil, nil
	end

	local dbid, theEntrance, theExit, interiorType, interiorElement = exports["interior_system"]:findProperty(source)
	interiorStatus = getElementData(interiorElement, "status")
	local owner = interiorStatus.owner

	for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
		local id = getElementData(value, "dbid")
		if (id==owner) then
			return owner, value
		end
	end
	return owner, nil -- no player found
end

function hasSupplies(int, supplies)
	if int and getElementType(int) == 'interior' then
		local status = getElementData(int, "status")
		local interiorType = status.type or -1
		if interiorType == 1 then -- business
			local currentSupplies = fromJSON(status.supplies)
			return (currentSupplies[tostring(supplies)] or 0) >= 1, (currentSupplies[tostring(supplies)] or 0) < 1 and "001 - This item is out of stock."
		else
			return false, "This interior is not a business thus far no transaction can be made here."
		end
	else
		return false, "No transaction can be made here."
	end
end

function checkSupply(thePlayer, command, supply)
	--if (getElementData(thePlayer, "scripter_level") or 0) >= 2 then
		if not supply then
			outputChatBox("Syntax: " .. command .. " [itemID:itemValue]", thePlayer, 255, 0, 0)
		else
			local dimension = getElementDimension(thePlayer)
			local interior = nil
			for i, v in ipairs(getElementsByType("interior")) do
				if getElementData(v, "dbid") == dimension then
					interior = v
					break
				end
			end
			if interior then
				local status = getElementData(interior, "status")
				local supplies = fromJSON(status.supplies)
				outputChatBox("This interior (" .. getElementData(interior, "dbid") .. ") has " .. tostring(supplies[tostring(supply)]) .. " supplies for '" .. supply .. "'.", thePlayer)
			else
				outputChatBox("You are not inside of an interior.", thePlayer, 255, 0, 0)
			end
		end
	--end
end
addCommandHandler("checksupply", checkSupply)

function getSuppliesFromPrice(price)
	return price/oneSupply*(100-math.random(0,profitRate))/100
end

function takeSupplies(int, itemID, itemValue, itemMetaName)
	local status = getElementData(int, "status")
	local supplies = fromJSON(status.supplies)

	if bandanas[itemID] then -- bandanas
		if supplies["122"] == 1 then
			supplies["122"] = nil
		else
			supplies["122"] = supplies["122"] - 1
		end
	elseif itemID == 16 then -- clothes
		if supplies["16"] == 1 then
			supplies["16"] = nil
		else
			supplies["16"] = supplies["16"] - 1
		end
	elseif itemID == 114 then
		if supplies["114:" .. vehicle_upgrades[tonumber(itemValue)-999][3]] == 1 then
			supplies["114:" .. vehicle_upgrades[tonumber(itemValue)-999][3]] = nil
		else
			supplies["114:" .. vehicle_upgrades[tonumber(itemValue)-999][3]] = supplies["114:" .. vehicle_upgrades[tonumber(itemValue)-999][3]] - 1
		end
	elseif itemID == 2 then
		if supplies[itemID .. ":1:"] == 1 then
			supplies[itemID .. ":1:"] = nil
		else
			supplies[itemID .. ":1:"] = supplies[itemID .. ":1:"] - 1
		end
	else
		if itemID == 115 then
			itemValue = gettok(itemValue, 1, ":")
		end
		if supplies[itemID .. ":" .. (itemValue or 1) .. ":" .. itemMetaName ] then
			if supplies[itemID .. ":" .. (itemValue or 1) .. ":" .. itemMetaName] == 1 then
				supplies[itemID .. ":" .. (itemValue or 1) .. ":" .. itemMetaName] = nil
			else
				supplies[itemID .. ":" .. (itemValue or 1) .. ":" .. itemMetaName] = supplies[itemID .. ":" .. (itemValue or 1) .. ":" .. itemMetaName] - 1
			end
		else
			if supplies[itemID .. ":" .. (itemValue or 1)] == 1 then
				supplies[itemID .. ":" .. (itemValue or 1)] = nil
			else
				supplies[itemID .. ":" .. (itemValue or 1)] = supplies[itemID .. ":" .. (itemValue or 1)] - 1
			end
		end
	end
	status.supplies = toJSON(supplies)

	return exports.anticheat:changeProtectedElementDataEx(int, "status", status, true) and mysql:query_free("UPDATE `interiors` SET `supplies` = '"..toJSON(supplies).."' WHERE id = " .. mysql:escape_string(getElementData(int,'dbid')))
end

local function isProfitable(player, interior)

	-- is an active business?
	local is, status = isActiveBusiness(interior)
	if not is then
		return false
	end

	-- fetch some info
	local owner = status and status.owner or 0
	local faction_owned = status and status.faction or 0
	local player_id = getElementData(player, 'dbid')

	-- don't do this if faction members buy from their faction business
	if exports.factions:isPlayerInFaction(player, faction_owned) then
		return false
	end

	-- all passed
	return true
end

function giveProfit(interior, ped, player, item, price)
	if isProfitable(player, interior) then
		if not price then 
			price = item.price 
		end
		local currentIncome = tonumber(getElementData(ped, "sIncome")) or 0
		exports.anticheat:setEld(ped, "sIncome", currentIncome + price, 'all')
		playBuySound(ped)
		local playerGender = getElementData(player,"gender")
		local pedName = tostring(getElementData(ped, "name"))
		if string.sub(pedName, 1, 8) == "userdata" then
			pedName = "The Storekeeper"
		end
		pedName = string.gsub(pedName,"_", " ")
		local playerName = getPlayerName(player):gsub("_", " ")
		if playerGender == 0 then
			triggerEvent('sendAme', player, "takes out a couple of dollar notes from his wallet, hands it over to "..pedName)
		else
			triggerEvent('sendAme', player, "takes out a couple of dollar notes from her wallet, hands it over to "..pedName)
		end
		local r = getRealTime()
		local timeString = ("%02d/%02d/%04d %02d:%02d"):format(r.monthday, r.month + 1, r.year+1900, r.hour, r.minute)
		local ownerNoti = "A customer bought a "..item.name.." for $"..exports.global:formatMoney(price).."."
		local logString = "- "..timeString.." : A customer bought a "..item.name.." for $"..exports.global:formatMoney(price)..".\n"

		triggerEvent("sendAme", ped, "gave "..playerName.." a "..item.name..".")
		storeKeeperSay(player, "Here you are. And..", pedName)
		if playerGender == 0 then
			storeKeeperSay(player, "Thank you, sir. Have a nice day!", pedName)
		else
			storeKeeperSay(player, "Thank you, ma'am. Have a nice day!", pedName)
		end

		--notifyAllShopOwners(ped, ownerNoti.." Come and collect the money when you got time ;)")

		local previousSales = getElementData(ped, "sSales") or ""
		logString = string.sub(logString..previousSales,1,5000)
		setElementData(ped, "sSales", logString, true)
		mysql:query_free("UPDATE `shops` SET `sIncome` = `sIncome` + '" .. tostring(price) .. "', `sSales` = '"..logString:gsub("'","''").."' WHERE `id` = '"..tostring(getElementData(ped,"dbid")).."'")
	end
end

function canPlayerCollectProfit(player, ped, int)

	-- check if all parameters exist and valid
	if not (player and getElementType(player) == 'player' and ped and getElementType(ped) == 'ped' and int and getElementType(int) == 'interior') then
		return false, "Internal Error, Code 1."
	end

	-- check if 3 elements are related
	if getElementDimension(player) ~= getElementDimension(ped) or getElementDimension(ped) ~= getElementData(int, 'dbid') then
		return false, "Internal Error, Code 2."
	end

	-- interior check
	local is, status = isActiveBusiness(int)
	if not is then -- if not a business then noone can collect.
		return false, "You can not collect profits from a non business property."
	end
	local faction_id = status and status.faction or 0
	local owner = status and status.owner or 0

	-- if interior is faction owned
	if faction_id > 0 then
		local faction = exports.factions:getFactionFromID(faction_id)
		if exports.factions:isPlayerInFaction(player, faction_id) then
			return true, faction
		else
			return false, "You are not a member of "..getTeamName(faction).."."
		end
	-- if interior is player owned
	elseif owner == getElementData(player, 'dbid') then
		return true
	end

	-- exceptions
	return false, "You don't have sufficient permissions to perform this action."
end

function takeBankMoney(thePlayer, amount)
	local done, why = exports.bank:takeBankMoney(thePlayer, amount)
	if done then
		return done
	else
		outputChatBox(why, thePlayer, 255,0, 0)
	end
end

function playPayWageSound(shopElement)
	local affectedPlayers = { }
	local x, y, z = getElementPosition(shopElement)

	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < 20 then
			local logged = getElementData(nearbyPlayer, "loggedin")
			if logged==1 and getElementDimension(shopElement) == getElementDimension(nearbyPlayer) then
				triggerClientEvent(nearbyPlayer, "shop:playPayWageSound", shopElement)
				table.insert(affectedPlayers, nearbyPlayer)
			end
		end
	end
	return true, affectedPlayers
end

function playCollectMoneySound(shopElement)
	local affectedPlayers = { }
	local x, y, z = getElementPosition(shopElement)

	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < 20 then
			local logged = getElementData(nearbyPlayer, "loggedin")
			if logged==1 and getElementDimension(shopElement) == getElementDimension(nearbyPlayer) then
				triggerClientEvent(nearbyPlayer, "shop:playCollectMoneySound", shopElement)
				table.insert(affectedPlayers, nearbyPlayer)
			end
		end
	end
	return true, affectedPlayers
end

function playBuySound(shopElement)
	local affectedPlayers = { }
	local x, y, z = getElementPosition(shopElement)

	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < 20 then
			local logged = getElementData(nearbyPlayer, "loggedin")
			if logged==1 and getElementDimension(shopElement) == getElementDimension(nearbyPlayer) then
				triggerClientEvent(nearbyPlayer, "shop:playBuySound", shopElement)
				table.insert(affectedPlayers, nearbyPlayer)
			end
		end
	end
	return true, affectedPlayers
end

function getPedName(shopElement)
	local pedName = getElementData(shopElement, "name")
	if not pedName or string.sub(tostring(pedName),1,8) == "userdata" then
		return "The Storekeeper"
	else
		return tostring(pedName):gsub("_", " ")
	end
end

function setShopStats(ped, stat, value)
	--exports.anticheat:setEld(ped, stat, value, 'all') -- idk why setElementData on ped does't work.
	return mysql:query_free("UPDATE `shops` SET `"..stat.."`='"..value.."' WHERE id='"..tostring(getElementData(ped, "dbid")).."' ")
end

-- Do not use this to create shops because it caused ID mismatch with custom shop's products.
function SmallestID() -- finds the smallest ID in the SQL instead of auto increment
	local result1 = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM shops AS e1 LEFT JOIN shops AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result1 then
		return tonumber(result1["nextID"]) or 1
	end
end

function updateShopSalary(thePlayer)
	outputDebugString("BIZ-SYSTEM SETTINGS: wageRate="..settings.wageRate..", limitDebtAmount="..settings.limitDebtAmount..", warningDebtAmount="..settings.warningDebtAmount.."")
	outputDebugString("------------START UPDATING SHOP WAGES------------")
	if thePlayer then
		outputChatBox("BIZ-SYSTEM SETTINGS: wageRate="..settings.wageRate..", limitDebtAmount="..settings.limitDebtAmount..", warningDebtAmount="..settings.warningDebtAmount.."", thePlayer)
		outputChatBox("------------START UPDATING SHOP WAGES------------", thePlayer)
	end
	local count = 0
	local possibleShops = getElementsByType("ped", resourceRoot)
	for _, shop in ipairs(possibleShops) do
		-- only do for custom shop.
		if getElementData(shop, "ped:type") == 'shop' and getElementData(shop, 'shoptype') == 17 then
			local shopID = getElementData(shop, "dbid") or false
			local dim = getElementDimension(shop)
			local business = exports.pool:getElement('interior', dim)
			if isActiveBusiness(business) then
				local status = getElementData(business, "status")
				local locked = status.locked and 1 or 0
				if locked == 0 then
					local sCapacity = tonumber(getElementData(shop, "sCapacity")) or 0
					local sPendingWage = tonumber(getElementData(shop, "sPendingWage")) or 0
					local sNewPendingWage = math.floor((sCapacity/settings.wageRate)) + sPendingWage
					local sIncome = tonumber(getElementData(shop, "sIncome")) or 0
					local sProfit = sIncome-sNewPendingWage
					if sNewPendingWage >= settings.warningDebtAmount then
						notifyAllShopOwners(shop, 1)
					end
					if (sProfit) >= (0-settings.limitDebtAmount) then
						exports.anticheat:setEld(shop, "sPendingWage", sNewPendingWage, 'all')
						local update = mysql:query_free("UPDATE `shops` SET `sPendingWage`='"..tostring(sNewPendingWage).."' WHERE `id`='"..tostring(shopID).."' ") or false
						if update then
							outputDebugString("Shop ID#"..shopID.." Updated Staff Wage "..sPendingWage.." -> "..sNewPendingWage)
							if thePlayer then
								outputChatBox("Shop ID#"..shopID.." Updated Staff Wage "..sPendingWage.." -> "..sNewPendingWage, thePlayer)
							end
						else
							outputDebugString("Shop ID#"..shopID.." Updated Staff Wage Failed.")
							if thePlayer then
								outputChatBox("Shop ID#"..shopID.." Updated Staff Wage Failed.", thePlayer)
							end
							count = count - 1
						end
					else
						local delete = mysql:query_free("DELETE FROM `shops` WHERE `id`='"..tostring(shopID).."' ") or false
						local delete2 = mysql:query_free("DELETE FROM `shop_products` WHERE `npcID`='"..tostring(shopID).."' ") or false
						if delete and delete2 then
							notifyAllShopOwners(shop, 2)
							outputDebugString("Shop ID#"..shopID.." Deleted itself due to the debt exceeds $"..exports.global:formatMoney(settings.limitDebtAmount)..".")
							if thePlayer then
								outputChatBox("Shop ID#"..shopID.." Deleted itself due to the debt exceeds $"..exports.global:formatMoney(settings.limitDebtAmount)..".", thePlayer)
							end
							destroyElement(shop)
							exports.global:sendMessageToAdmins("[BIZ-SYSTEM] Shop ID#"..shopID.." Deleted itself due to the debt exceeded $"..exports.global:formatMoney(settings.limitDebtAmount)..".")
						else
							outputDebugString("Shop ID#"..shopID.." Failed to delete shop eventho the debt exceeded $"..exports.global:formatMoney(settings.limitDebtAmount)..".")
							if thePlayer then
								outputChatBox("Shop ID#"..shopID.." Failed to delete shop eventho the debt exceeded $"..exports.global:formatMoney(settings.limitDebtAmount)..".", thePlayer)
							end
							count = count - 1
						end
					end
					count = count + 1
				end
			end
		end
	end
	outputDebugString("------------UPDATED "..count.." SHOP WAGES------------")
	if thePlayer then
		outputChatBox("------------UPDATED "..count.." SHOP WAGES------------", thePlayer)
		local adminUsername = getElementData(thePlayer, "account:username")
		local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
		local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)

		if hiddenAdmin == 0 then
			exports.global:sendMessageToAdmins("[BIZ-SYSTEM]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").. " ("..adminUsername..") has forced "..count.." custom shops to take wage.")
		else
			exports.global:sendMessageToAdmins("[BIZ-SYSTEM]: A hidden admin has forced "..count.." custom shops to take wage.")
		end
	end
end
addEvent('payday:run', true)
addEventHandler('payday:run', root, updateShopSalary)

function fourceUpdateShopSalary(thePlayer)
	if (exports.integration:isPlayerScripter(thePlayer)) then
		updateShopSalary(thePlayer)
	end
end
addCommandHandler("forceupdateshopwage", fourceUpdateShopSalary)
