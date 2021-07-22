--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

profitRate = tonumber(get( getResourceName( getResourceFromName("npc") ).. '.profitRate' ))
oneSupply = tonumber(get( getResourceName( getResourceFromName("npc") ).. '.oneSupply' ))

local function SmallestID() -- finds the smallest ID in the SQL instead of auto increment
	local result1 = mysql:query_fetch_assoc("SELECT MIN(e1.orderID+1) AS nextID FROM jobs_trucker_orders AS e1 LEFT JOIN jobs_trucker_orders AS e2 ON e1.orderID +1 = e2.orderID WHERE e2.orderID IS NULL")
	if result1 then
		return result1["nextID"] ~= mysql_null() and result1["nextID"] or "1"
	end
	return false
end

local function findRootInteriorMarker(dim)
	local foundRootInterior = false
	for key, interior in pairs(getElementsByType("interior")) do
		if dim == getElementData(interior, "dbid") then
			local marker = getElementData(interior, "entrance")
			if marker.int == 0 and marker.dim == 0 then
				return marker.x, marker.y, marker.z, getElementData(interior, "name") or "Unknown"
			else
				return false, marker.dim
			end
			break
		end
	end
end

function orderSupplies(thePlayer, commandName, money)
	money = tonumber(money) or 0
	if money%1~=0 or money <= 0 then
		outputChatBox("SYNTAX: /" .. commandName .. " [Money spend on supplies] - Place an order of supplies to RS Haul to maintain your business.", thePlayer, 255, 194, 14)
		return false
	end
	local done, why = remoteOrderSupplies(thePlayer, money, string.lower(commandName) == "aordersupplies")
	outputChatBox(why,thePlayer, 255, 194, 14)
	return done
end
addCommandHandler("ordersupplies", orderSupplies, false, false)

function adminOrderSupplies(thePlayer, commandName, money)
	if exports.integration:isPlayerAdmin(thePlayer) then
		orderSupplies(thePlayer, commandName, tonumber(money)>5000 and 5000 or money) -- Noone should be able to give away too much supplies as it is expensive as fuck atm.
	end
end
addCommandHandler("aordersupplies", adminOrderSupplies, false, false)

local function canOrderSupplies(player, is_admin, money)
	if money%1~=0 or money <= 0 then
		return false, "Invalid money input."
	end

	-- fetch some info
	local dim = getElementDimension(player)
	local interior = exports.pool:getElement('interior', dim)
	local status = interior and getElementData(interior, 'status')
	local faction_owned = status and status.faction
	local owner = status and status.owner
	local int_type = status and status.type

	if dim <= 0 then
		return false, "You must be inside the business and have pair of keys to be able to order more supplies."
	end

	-- non business
	if int_type ~= 1 then
		return false, "You can not place a supplies order for a non business property"
	end

	-- if faction owned
	if faction_owned and faction_owned > 0 then
		local is_faction_leader = exports.factions:hasMemberPermissionTo(player, faction_owned, "manage_finance")
		local faction = exports.pool:getElement('team', faction_owned)
		if is_faction_leader or is_admin then
			if exports.bank:hasBankMoney(faction, money) then
				return true, faction
			else
				return false, "You don't have $"..exports.global:formatMoney(money).." in the bank of "..getTeamName(faction).."."
			end
		else
			return false, "You must be leader of "..getTeamName(faction).." to place a supplies order for this business."
		end
	end

	-- if player owned
	if is_admin or owner == getElementData(player, 'dbid') or exports.global:hasItem(player,4, dim) or exports.global:hasItem(player,5, dim) then
		if is_admin or exports.global:hasMoney(player, money) then
			return true
		else
			return false, "You don't have $"..exports.global:formatMoney(money).."."
		end
	else
		return false, "You must be the owner of this property or posses a pair of keys to be able to order more supplies."
	end
end

function remoteOrderSupplies(thePlayer, supplies, money, isAdmin)
	if source then thePlayer = source end

	--Find the closest interior on world map.
	local safeCount = 0 -- To prevent freezing server in the worst case.
	local x, y, z, name = findRootInteriorMarker(getElementDimension(thePlayer))
	while not x do
		x, y, z, name = findRootInteriorMarker(y)
		safeCount = safeCount + 1
		if safeCount >= 100 then
			break
		end
	end

	if not x then
		return false, "Your interior has no entrance from world map. Therefore, RS Haul Driver will not be able to reach here. Hit F1 for assistance."
	end

	local done, why = addOrder(getElementDimension(thePlayer), supplies, x, y, z, name)
	if done then
		if isAdmin then
			exports["interior-manager"]:addInteriorLogs(getElementDimension(thePlayer), "aordersupplies ~ $"..money, thePlayer)
		else
			local gender = getElementData(thePlayer, 'gender')
			local customerName = exports.global:getPlayerName(thePlayer)
			notifyTruckers("RS Haul Operator: "..(gender == 0 and "Mr. " or "Mrs. ")..customerName.." ordered supplies to "..name..". Deliver them as soon as you can please.", true)
			if faction then
				if exports.bank:takeBankMoney(faction, money) then
					exports.bank:addBankTransactionLog(-getElementData(faction, 'id'), 0, money, 15, "RS Haul order for "..name.." ("..customerName..")", "RS Haul")
				end
			end
			exports["interior-manager"]:addInteriorLogs(getElementDimension(thePlayer), "ordersupplies ~ $"..money, thePlayer)
		end
		return true, "Half of your order has been sent to the RS Haul delivery drivers."
	else
		return false, why
	end
end
