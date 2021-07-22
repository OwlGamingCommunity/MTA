--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

mysql = exports.mysql
local useShopsWithNoItems = false
profitRate = tonumber(get( "profitRate" ))
oneSupply = tonumber(get( "oneSupply" ))
setElementData(resourceRoot, 'oneSupply', oneSupply)

local skins = { { 211, 217 }, { 179 }, false, { 178 }, { 82 }, { 80, 81 }, { 28, 29 }, { 169 }, { 171, 172 }, { 142 }, { 171 }, { 171, 172 }, {71}, { 50 }, { 1 }, { 118 }, {118} }

function createShopKeeper(x,y,z,interior,dimension,id,shoptype,rotation, skin, sPendingWage, sIncome, sCapacity, currentCap, sSales, pedName, sContactInfo, faction_belong, faction_access)
	if not g_shops[shoptype] then
		outputDebugString("Trying to locate shop #" .. id .. " with invalid shoptype " .. shoptype)
		return
	end

	if shoptype == 17 then
		if tonumber(dimension) == 0 and tonumber(interior) == 0 then
			return false
		end
	end

	if not skin then
		skin = 0

		if shoptype == 3 then
			skin = 168
			-- needs differences for burgershot etc
			if interior == 5 then
				skin = 155
			elseif interior == 9 then
				skin = 167
			elseif interior == 10 then
				skin = 205
			end
			-- interior 17 = donut shop
		elseif shoptype == 16 then
			skin = 27
		else
			-- clothes, interior 5 = victim
			-- clothes, interior 15 = binco
			-- clothes, interior 18 = zip
			skin = skins[shoptype][math.random( 1, #skins[shoptype] )]
		end
	end

	local customskin = false
	if string.find(skin, ":") then -- if it's a custom one
		local t = split(skin, ":")
		if tonumber(t[2]) > 0 then
			customskin = tonumber(t[2])
		end
		skin = tonumber(t[1])
	end

	skin = tonumber(skin) or 0
	if skin < 0 then skin = 0 end
	local ped = createPed(tonumber(skin), x, y, z)
	if ped then
		setElementRotation(ped, 0, 0, rotation)
		setElementDimension(ped, dimension)
		setElementInterior(ped, interior)

		if customskin then
			setElementData(ped, "clothing:id", customskin)
		end

		if shoptype == 17 then
			setElementData(ped, "customshop", true)
		elseif shoptype == 18 or shoptype == 19 then --Faction Drop NPCs
			exports.anticheat:changeProtectedElementDataEx(ped, "faction_belong", faction_belong, true)
			exports.anticheat:changeProtectedElementDataEx(ped, "faction_access", faction_access, true)
		end

		setElementData(ped, "talk", 1, true)
		setElementData(ped, "name", pedName, true)
		setElementData(ped, "shopkeeper", true)

		setElementFrozen(ped, true)

		setElementData(ped, "dbid", tonumber(id), true)
		setElementData(ped, "ped:type", "shop", false)
		setElementData(ped, "shoptype", shoptype, false)
		setElementData(ped, "rotation", rotation, false)
		exports.anticheat:setEld(ped, "sPendingWage", tonumber(sPendingWage) or 0, 'all')
		exports.anticheat:setEld(ped, "sIncome", tonumber(sIncome) or 0, 'all')
		setElementData(ped, "sCapacity", sCapacity, true)
		setElementData(ped, "currentCap", currentCap, true)
		setElementData(ped, "sSales", sSales, true)
		setElementData(ped, "sContactInfo", sContactInfo, true)

		exports.pool:allocateElement(ped)
	else
		outputDebugString("Shopkeeper #"..tonumber(id).." failed to load.", 2)
	end
end

function delNearbyGeneralshops(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Deleting Nearby Shop NPC(s):", thePlayer, 255, 126, 0)
		local count = 0

		local dimension = getElementDimension(thePlayer)

		for k, thePed in ipairs(getElementsByType("ped", resourceRoot)) do
			local pedType = getElementData(thePed, "ped:type")
			if (pedType) then
				if (pedType=="shop") then
					local x, y = getElementPosition(thePed)
					local distance = getDistanceBetweenPoints2D(posX, posY, x, y)
					local cdimension = getElementDimension(thePed)
					if (distance<=10) and (dimension==cdimension) then
						local dbid = getElementData(thePed, "dbid")
						local shoptype = getElementData(thePed, "shoptype")
						if removeGeneralShop(thePlayer, "delshop", dbid) then
							--outputChatBox("   Deleted Shop with ID #" .. dbid .. " and type "..shoptype..".", thePlayer, 255, 126, 0)
							count = count + 1
						end
					end
				end
			end
		end

		if (count==0) then
			outputChatBox("   Deleted None.", thePlayer, 255, 126, 0)
		else
			outputChatBox("   Deleted "..count.." None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("delnearbyshops", delNearbyGeneralshops, false, false)
addCommandHandler("delnearbynpcs", delNearbyGeneralshops, false, false)

function createGeneralshop(thePlayer, commandName, shoptype, skin, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local shoptype = tonumber(shoptype)
		if not shoptype or not g_shops[shoptype] then
			outputChatBox("SYNTAX: /" .. commandName .. " [shop type] [skin, -1 = random] [Firstname Lastname, -1 = random]", thePlayer, 255, 194, 14)
			for k, v in ipairs(g_shops) do
				outputChatBox("TYPE " .. k .. " = " .. v.name, thePlayer, 200, 200, 200)
			end
			return false
		end

		if not skin or tonumber(skin) == -1 then --Random
			skin = exports.global:getRandomSkin()
		end

		if skin then
			local skinTest = skin
			if string.find(skinTest, ":") then
				local t = split(skinTest, ":")
				skinTest = tonumber(t[1])
			end
			local ped = createPed(tonumber(skinTest), 0, 0, 3)
			if not ped then
				outputChatBox("Invalid Skin.", thePlayer, 255, 0, 0)
				return
			else
				destroyElement(ped)
			end
		else
			skin = -1
		end

		local x, y, z = getElementPosition(thePlayer)
		local dimension = getElementDimension(thePlayer)
		local interior = getElementInterior(thePlayer)
		local _, _, rotation = getElementRotation(thePlayer)

		if shoptype == 17 then
			if dimension == 0 and interior == 0 then
				outputChatBox("Custom shop must be created in a business interior.", thePlayer, 255, 0, 0)
				return false
			end
		end

		local pedName = table.concat({...}, "_") or false

		if not pedName or pedName=="" or (tonumber(pedName) and tonumber(pedName) == -1) then
			pedName = exports.global:createRandomMaleName()
			pedName = string.gsub(pedName, " ", "_")
		end

		local iCan, why = canIUseThisName(pedName)
		if not iCan then
			outputChatBox(why, thePlayer, 255, 0, 0)
			return false
		end

		local id = false
		id = mysql:query_insert_free("INSERT INTO shops SET pedName='"..exports.global:toSQL(pedName).."', x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .. "', z='" .. mysql:escape_string(z) .. "', dimension='" .. mysql:escape_string(dimension) .. "', interior='" .. mysql:escape_string(interior) .. "', shoptype='" .. mysql:escape_string(shoptype) .. "', rotationz='" .. mysql:escape_string(rotation) .. "', skin='".. mysql:escape_string(skin).."' ")

		if (id) then
			createShopKeeper(x,y,z,interior,dimension,id,tonumber(shoptype),rotation,skin ~= -1 and skin, 0, 0, 10, 0, "", pedName, {"", "", "", ""}, 0, 0)
		else
			outputChatBox("Error creating shop.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("makeshop", createGeneralshop, false, false)

function getNearbyGeneralshops(thePlayer, commandName)
	local posX, posY, posZ = getElementPosition(thePlayer)
	local dimension = getElementDimension(thePlayer)
	local count = 0

	local id, entrance, exit, _, found = exports['interior_system']:findProperty(thePlayer, dimension)
	local status = (found and getElementData(found, "status")) or false

	if (found and status.owner == getElementData(thePlayer, "dbid")) or exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) then
		outputChatBox("Nearby Shop NPC(s):", thePlayer, 255, 126, 0)
		for k, thePed in ipairs(getElementsByType("ped", resourceRoot)) do
			local pedType = getElementData(thePed, "ped:type")
			if (pedType) then
				if (pedType=="shop") then
					local x, y = getElementPosition(thePed)
					local distance = getDistanceBetweenPoints2D(posX, posY, x, y)
					local cdimension = getElementDimension(thePed)
					if (distance<=10) and (dimension==cdimension) then
						local dbid = getElementData(thePed, "dbid")
						local shoptype = getElementData(thePed, "shoptype")
						local pedName = getElementData(thePed, "name") or "Unnamed"
						outputChatBox("   Shop ID #" .. dbid .. ", type "..shoptype..", name: "..tostring(pedName):gsub("_", " "), thePlayer, 255, 126, 0)
						count = count + 1
					end
				end
			end
		end
		if (count==0) then
			outputChatBox("   None.", thePlayer, 255, 126, 0)
		end
	else
		outputChatBox("Non-staff members can only use this command in their own interiors.", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("nearbyshops", getNearbyGeneralshops, false, false)
addCommandHandler("nearbynpcs", getNearbyGeneralshops, false, false)
function moveNPCshop(thePlayer, commandName, value)
	local dim = getElementDimension(thePlayer)
	local interior = exports.pool:getElement("interior", dim)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or (interior and getElementData(interior, "status").owner == getElementData(thePlayer, "dbid"))) then

	if not tonumber(value) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Shop ID]", thePlayer, 255, 194, 14)
		return
	end

	local possibleShops = getElementsByType("ped", resourceRoot)
	local foundShop = false
		for _, shop in ipairs(possibleShops) do
			if getElementData(shop,"shopkeeper") and (tonumber(getElementData(shop, "dbid")) == tonumber(value)) then
				foundShop = shop
				break
			end
		end

	if not foundShop then
		outputChatBox("No shop founded with ID #"..value, thePlayer, 255, 0, 0)
		return
	elseif getElementDimension(foundShop) ~= dim then
		outputChatBox("The shop must be in the same interior as you are trying to move it to.", thePlayer, 255, 0, 0)
		return
	end

	local x, y, z = getElementPosition(thePlayer)
	local int = getElementInterior(thePlayer)
	local rot, rot1, rot2 = getElementRotation(thePlayer)

	change = mysql:query_insert_free("UPDATE shops SET x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .. "', z='" .. mysql:escape_string(z) .. "', dimension='" .. mysql:escape_string(dim) .. "', interior='" .. mysql:escape_string(int) .. "', rotationz='" .. mysql:escape_string(rot2) .. "' WHERE id=".. mysql:escape_string(tonumber(value)))

	setElementPosition(foundShop, x, y, z)
	setElementDimension(foundShop, dim)
	setElementInterior(foundShop, int)
	setElementRotation(foundShop, rot, rot1, rot2)

	outputChatBox("Updated shop position.", thePlayer, 0, 255, 0)

	end
end
addCommandHandler("moveshop", moveNPCshop)
addCommandHandler("movenpc", moveNPCshop)

function gotoShop(thePlayer, commandName, shopID)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not tonumber(shopID) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Shop ID]", thePlayer, 255, 194, 14)
		else
			local possibleShops = getElementsByType("ped", resourceRoot)
			local foundShop = false
			for _, shop in ipairs(possibleShops) do
				if getElementData(shop,"shopkeeper") and (tonumber(getElementData(shop, "dbid")) == tonumber(shopID)) then
					foundShop = shop
					break
				end
			end

			if not foundShop then
				outputChatBox("No shop founded with ID #"..shopID, thePlayer, 255, 0, 0)
				return false
			end

			local x, y, z = getElementPosition(foundShop)
			local dim = getElementDimension(foundShop)
			local int = getElementInterior(foundShop)
			local _, _, rot = getElementRotation(foundShop)
			startGoingToShop(thePlayer, x,y,z,rot,int,dim,shopID)
		end
	end
end
addCommandHandler("gotoshop", gotoShop, false, false)

function startGoingToShop(thePlayer, x,y,z,r,interior,dimension,shopID)
	-- Maths calculations to stop the player being stuck in the target
	x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
	y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )

	setCameraInterior(thePlayer, interior)

	if (isPedInVehicle(thePlayer)) then
		local veh = getPedOccupiedVehicle(thePlayer)
		setElementAngularVelocity(veh, 0, 0, 0)
		setElementInterior(thePlayer, interior)
		setElementDimension(thePlayer, dimension)
		setElementInterior(veh, interior)
		setElementDimension(veh, dimension)
		setElementPosition(veh, x, y, z + 1)
		warpPedIntoVehicle ( thePlayer, veh )
		setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
	else
		setElementPosition(thePlayer, x, y, z)
		setElementInterior(thePlayer, interior)
		setElementDimension(thePlayer, dimension)
	end
	outputChatBox(" You have teleported to shop ID#"..shopID, thePlayer)
end

function removeGeneralShop(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (id) or not tonumber(id) then
			outputChatBox("SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
			return false
		end

		local counter = 0
		for k, thePed in ipairs(getElementsByType("ped", resourceRoot)) do
			local pedType = getElementData(thePed, "ped:type")
			if (pedType) then
				if (pedType=="shop") then
					local dbid = getElementData(thePed, "dbid")
					if (tonumber(id) == dbid) then
						if (getElementData(thePlayer, "shop:removing") and getElementData(thePlayer, "shop:removing") == dbid) or getElementData(thePed, "shoptype") ~= 17 then
							destroyElement(thePed)
							if mysql:query_free("DELETE FROM shops WHERE id='" .. mysql:escape_string(dbid) .. "' LIMIT 1") and	mysql:query_free("DELETE FROM shop_products WHERE npcID='" .. mysql:escape_string(dbid) .. "' ") and mysql:query_free("DELETE FROM shop_contacts_info WHERE npcID='" .. mysql:escape_string(dbid) .. "' ") then
								outputChatBox("Successfully deleted and removed shop #" .. dbid .. " from the database.", thePlayer, 0, 255, 0)
							else
								outputChatBox("Error: shop does not exist.", thePlayer, 255, 0, 0)
								return false
							end
							counter = counter + 1
							setElementData(thePlayer, "shop:removing", false)
						else
							setElementData(thePlayer, "shop:removing", dbid)
							outputChatBox("Warning: by deleting this shop, all items within it will be deleted and they cannot be restored! Type /" .. commandName .. " " .. dbid .. " to continue.", thePlayer, 255, 0, 0)
							return true
						end
					end
				end
			end
		end

		if (counter == 0) then
			outputChatBox("Error: shop does not exist.", thePlayer, 255, 0, 0)
			return false
		end
		return true
	end
end
addCommandHandler("delshop", removeGeneralShop, false, false)
addCommandHandler("deleteshop", removeGeneralShop, false, false)

function loadAllGeneralshops(res)
	local result = mysql:query("SELECT `shops`.`id` AS `id`, `x`, `y`, `z`, `dimension`, `interior`, `shoptype`, `rotationz`, `skin`, `sPendingWage`, `sIncome`, `sCapacity`, `sSales`, `pedName`, `sOwner`, `sPhone`, `sEmail`, `sForum`, `faction_belong`, `faction_access` FROM `shops` LEFT JOIN `shop_contacts_info` ON `shops`.`id` = `shop_contacts_info`.`npcID`")

	while result do
		local row = exports.mysql:fetch_assoc(result)
		if not (row) then
			break
		end

		local id = tonumber(row["id"])
		local x = tonumber(row["x"])
		local y = tonumber(row["y"])
		local z = tonumber(row["z"])

		local dimension = tonumber(row["dimension"])
		local interior = tonumber(row["interior"])
		local shoptype = tonumber(row["shoptype"])
		local rotation = tonumber(row["rotationz"])
		local skin = row["skin"]
		local sPendingWage = tonumber(row["sPendingWage"])
		local sIncome = tonumber(row["sIncome"])
		local sCapacity = tonumber(row["sCapacity"])
		local currentCap = 0
		local sSales = row["sSales"]
		local pedName = row["pedName"] or false

		if shoptype == 17 then -- custom store
			local cap = mysql:query_fetch_assoc("SELECT COUNT(*) as `currentCap` FROM `shop_products` WHERE `npcID` = '"..id.."' ")
			cap = cap and cap['currentCap']
			currentCap = tonumber(cap) or 0
		end

		local sContactInfo = {row["sOwner"],row["sPhone"],row["sEmail"],row["sForum"]}
		local faction_belong = tonumber(row["faction_belong"])
		local faction_access = tonumber(row["faction_access"])

		createShopKeeper(x,y,z,interior,dimension,id,shoptype,rotation,skin ~= -1 and skin, sPendingWage, sIncome, sCapacity, currentCap, sSales, pedName, sContactInfo, faction_belong, faction_access)
	end
	mysql:free_result(result)
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllGeneralshops)

function loadOneShop(shopID)
	local result = mysql:query("SELECT `shops`.`id` AS `id`, `x`, `y`, `z`, `dimension`, `interior`, `shoptype`, `rotationz`, `skin`, `sPendingWage`, `sIncome`, `sCapacity`, `sSales`, `pedName`, `sOwner`, `sPhone`, `sEmail`, `sForum`, `faction_belong`, `faction_access` FROM `shops` LEFT JOIN `shop_contacts_info` ON `shops`.`id` = `shop_contacts_info`.`npcID` WHERE `shops`.`id` = '"..tostring(shopID).."' LIMIT 1")


	local row = exports.mysql:fetch_assoc(result)
	if not (row) then
		return false
	end

	local id = tonumber(row["id"])
	local x = tonumber(row["x"])
	local y = tonumber(row["y"])
	local z = tonumber(row["z"])

	local dimension = tonumber(row["dimension"])
	local interior = tonumber(row["interior"])
	local shoptype = tonumber(row["shoptype"])
	local rotation = tonumber(row["rotationz"])
	local skin = row["skin"]
	local sPendingWage = tonumber(row["sPendingWage"])
	local sIncome = tonumber(row["sIncome"])
	local sCapacity = tonumber(row["sCapacity"])
	local currentCap = 0
	local sSales = row["sSales"]
	local pedName = row["pedName"] or false

	if shoptype == 17 then -- custom store
		local cap = mysql:query_fetch_assoc("SELECT COUNT(*) as `currentCap` FROM `shop_products` WHERE `npcID` = '"..id.."' ")
		cap = cap and cap['currentCap']
		currentCap = tonumber(cap) or 0
	end

	local sContactInfo = {row["sOwner"],row["sPhone"],row["sEmail"],row["sForum"]}
	local faction_belong = tonumber(row["faction_belong"])
	local faction_access = tonumber(row["faction_access"])

	createShopKeeper(x,y,z,interior,dimension,id,shoptype,rotation,skin ~= -1 and skin, sPendingWage, sIncome, sCapacity, currentCap, sSales, pedName, sContactInfo, faction_belong, faction_access)

	mysql:free_result(result)
	return true
end

function reloadGeneralShop(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (id) then
			id = getElementData(thePlayer, "shop:mostRecentDeleteShop") or false
			if not id then
				outputChatBox("SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
				return false
			end
		end

		if loadOneShop(id) then
			outputChatBox("Reloaded shop ID#"..id..".",thePlayer, 0,255,0)
		else
			outputChatBox("Reloaded shop ID#"..id..".",thePlayer, 255,0,0)
		end
	end
end
addCommandHandler("reloadshop", reloadGeneralShop, false, false)
addCommandHandler("reloadnpc", reloadGeneralShop, false, false)
addCommandHandler("reloadped", reloadGeneralShop, false, false)

function renamePed(thePlayer, commandName, id, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		if not tonumber(id) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Shop ID] [Firstname LastName]", thePlayer, 255, 194, 14)
			return false
		end
		id = math.floor(tonumber(id))
		local pedName = table.concat({...}, "_")

		if pedName == "" then
			outputChatBox("SYNTAX: /" .. commandName .. " [Shop ID] [Firstname LastName]", thePlayer, 255, 194, 14)
			return false
		end

		local iCan, why = canIUseThisName(pedName)
		if not iCan then
			outputChatBox(why, thePlayer, 255, 0, 0)
			return false
		end

		if not mysql:query_free("UPDATE `shops` SET `pedName`='"..tostring(pedName):gsub("'","''").."' WHERE `id`='"..tostring(id).."' ") then
			outputChatBox("Failed to rename this NPC, please report as bug.",thePlayer, 255,0,0)
			return false
		end

		for k, thePed in ipairs(getElementsByType("ped", resourceRoot)) do
			local pedType = getElementData(thePed, "ped:type")
			if (pedType) then
				if (pedType=="shop") then
					local dbid = getElementData(thePed, "dbid")
					if (tonumber(id)==dbid) then
						destroyElement(thePed)
					end
				end
			end
		end

		if loadOneShop(id) then
			outputChatBox("Renamed shop ID#"..id.." to '"..tostring(pedName):gsub("_"," ").."'.",thePlayer, 0,255,0)
		else
			outputChatBox("Failed to reload this NPC, please report as bug.",thePlayer, 255,0,0)
		end
	end
end
addCommandHandler("renameped", renamePed, false, false)
addCommandHandler("renamenpc", renamePed, false, false)
addCommandHandler("renameshop", renamePed, false, false)

-- end of loading shops, this be store keeper thing below --

function clickStoreKeeper()
	local success, currentUser = canIAccessThisShop(source, client)
	if not success then
		outputChatBox(currentUser.." is currently using this NPC, please wait a moment.", client, 255,0,0)
		return false
	end

	local shoptype = getElementData(source, "shoptype")
	local id = getElementData(source, "dbid")

	local race, gender = nil, nil
	if(shoptype == 5) then -- if its a clothes shop, we also need the players race
		gender = getElementData(client,"gender")
		race = getElementData(client,"race")
	end

	if tonumber(shoptype) == 17 then
		local products = {}
		local shopProducts = mysql:query("SELECT * FROM `shop_products` WHERE `npcID`='"..id.."' ORDER BY `pDate` DESC")
		while true do
			local pRow = mysql:fetch_assoc(shopProducts)
			if not pRow then break end
			local pMetadata
			if pRow["pMetadata"] and pRow["pMetadata"] ~= mysql_null() then
				pMetadata = fromJSON(pRow["pMetadata"]) or {}
			else
				pMetadata = {}
			end
			table.insert(products, { id, pRow["pItemID"], pRow["pItemValue"], pRow["pDesc"], pRow["pPrice"], pRow["pDate"], pRow["pID"], pMetadata } )
		end
		mysql:free_result(shopProducts)
		if setShopCurrentUser(source, client) then
			triggerClientEvent(client, "showGeneralshopUI", source, shoptype, race, gender, 0, products)
		else
			outputDebugString("setShopCurrentUser failed.")
		end
	elseif tonumber(shoptype) == 18 then --Faction Drop NPC - General Items

	elseif tonumber(shoptype) == 19 then -- Faction Drop NPC - WEAPONS
		local products = {}
		local shopProducts = mysql:query("SELECT `npcID`, `pItemID`, `pItemValue`, `pDesc`, `pPrice`, `pDate`, `pID`, `pQuantity`, `pSetQuantity`, `pRestockInterval`, `pRestockedDate`, DATEDIFF((`pRestockedDate` + interval `pRestockInterval` day),NOW()) AS `pRestockIn`, `pMetadata` FROM `shop_products` WHERE `npcID`='"..id.."' ORDER BY `pID` DESC")
		while true do
			local pRow = mysql:fetch_assoc(shopProducts)
			if not pRow then break end
			local pMetadata
			if pRow["pMetadata"] and pRow["pMetadata"] ~= mysql_null() then
				pMetadata = fromJSON(pRow["pMetadata"]) or {}
			else
				pMetadata = {}
			end
			pRow['pMetadata'] = pMetadata
			table.insert(products, pRow )
		end
		mysql:free_result(shopProducts)

		if setShopCurrentUser(source, client) then
			triggerClientEvent(client, "showGeneralshopUI", source, shoptype, race, gender, 0, products)
		else
			outputDebugString("setShopCurrentUser failed.")
		end
	else
		if setShopCurrentUser(source, client) then
			-- perk 8 = 20% discount in shops
			triggerClientEvent(client, "showGeneralshopUI", source, shoptype, race, gender, getDiscount(client, shoptype))
		else
			outputDebugString("setShopCurrentUser failed.")
		end
	end

end
addEvent("shop:keeper", true)
addEventHandler("shop:keeper", getResourceRootElement(), clickStoreKeeper)

addEvent("shop:buy", true)
addEventHandler( "shop:buy", resourceRoot, function( index )
	local shoptype = getElementData( source, "shoptype")
	local error = "S-" .. tostring( shoptype ) .. "-" .. tostring( getElementData( source, "dbid") )

	local shop = g_shops[ shoptype or -1 ]
	_G['shop'] = shop
	if not shop then
		outputChatBox("Error " .. error .. "-NE, report at bugs.owlgaming.net.", client, 255, 0, 0 )
		return
	end

	local race = getElementData( client, "race" )
	local gender = getElementData( client, "gender" )
	updateItems( shoptype, race, gender ) -- should modify /shop/ too, as shop is a reference to g_shops[type].

	-- get some info about int
	local interior = exports.pool:getElement('interior', getElementDimension( source ))
	local status, supplies = {}, {}
	if interior then
		status = getElementData(interior, "status")
		supplies = fromJSON(status.supplies)
	end

	-- fetch the selected item
	local item = getItemFromIndex( shoptype, index, true, interior )
	if not item then
		outputChatBox("Error " .. error .. "-NEI-" .. index .. ", report at bugs.owlgaming.net.", client, 255, 0, 0 )
		return
	end

	-- is this item reduced?
	local price = math.ceil( getDiscount( client, shoptype ) * item.price )

	-- checking space
	if not exports.global:hasSpaceForItem( client, item.itemID, item.itemValue ) then
		outputChatBox("Your inventory is full.", client, 255, 0, 0)
		return
	end

	--checking age
	if item.minimum_age and getElementData(client, "age") < item.minimum_age then
		outputChatBox( "You need to be " .. item.minimum_age .. " years or older to buy this.", client, 255, 0, 0 )
		return
	end

	-- check for money
	if not exports.global:hasMoney( client, price ) then
		outputChatBox( "You lack the money to buy this " .. item.name .. ".", client, 255, 0, 0 )
		return
	end

	-- Check further more for certain items, get the itemValue ready to give.
	local itemID, itemValue = item.itemID, item.itemValue or 1
	-- If it's a phone, get the available number ready.
	if itemID == 2 then
		local attempts = 0
		while true do
			-- generate a larger phone number if we're totally out of numbers and/or too lazy to perform more than 20+ checks.
			attempts = attempts + 1
			itemValue = math.random(311111, attempts < 20 and 899999 or 8999999)

			local mysqlQ = mysql:query("SELECT `phonenumber` FROM `phones` WHERE `phonenumber` = '" .. itemValue .. "'")
			if mysql:num_rows(mysqlQ) == 0 then
				mysql:free_result(mysqlQ)
				break
			end
			mysql:free_result(mysqlQ)
		end
	elseif itemID == 68 then -- Lottery Tickets / Check and
		outputChatBox( "This item is temporarily disabled.", client, 255, 0, 0 )
		--Code for this at the bottom of the file.
		return
	elseif itemID == 115 or itemID == 116 then
		if item.license and getElementData( client, "license.gun" ) ~= 1 then
			outputChatBox( "You lack a weapon license.", client, 255, 0, 0 )
			return
		else
			local characterDatabaseID = getElementData(client, "dbid")
			local serial = exports.global:createWeaponSerial( item.license and 3 or 1, characterDatabaseID, characterDatabaseID )
			local w = itemValue
			if itemID == 115 then
				itemValue = w .. ":" .. serial .. ":" .. item.name..":0"
				if exports.global:hasSpaceForItem(client, itemID, itemValue) then
					addPurchaseLogs(tonumber(getElementData(source, "dbid")), client, item.name, itemValue, price, serial, "N/A", FORUM_AMMUNATION)
				end
			elseif itemID == 116 then
				local amount = item.ammo or 10
				itemValue = w .. ":" .. amount .. ":" .. serial
				if exports.global:hasSpaceForItem(client, itemID, itemValue) then
					addPurchaseLogs(tonumber(getElementData(source, "dbid")), client, item.name, itemValue, price, serial, "N/A", FORUM_AMMUNATION)
				end
			end
		end
	end

	-- Take money and give item
	if exports.global:takeMoney( client, price ) and exports.global:giveItem( client, itemID, itemValue, item.metadata ) then
		outputChatBox( "You bought this " .. item.name .. " for $" .. exports.global:formatMoney( price ) .. ".", client, 0, 255, 0 )
	else
		outputChatBox( "Error!", client, 255, 0, 0 )
		return
	end

	-- Some items needs more than just an item in player inventory, here is where to do it
	if itemID == 2 then
		mysql:query_free("INSERT INTO `phones` (`phonenumber`, `boughtby`) VALUES ('"..tostring(itemValue).."', '"..mysql:escape_string(tostring(getElementData(client, "account:character:id") or 0)).."')")
		outputChatBox("Your number is #" .. itemValue .. ".", client, 255, 194, 14 )
	elseif itemID == 114 then -- vehicle mods
		outputChatBox("To add this item to any vehicle, go into a garage and double-click the item while sitting inside.", client, 255, 194, 14 )
	elseif itemID == 115 then -- log weapon purchases
		exports.logs:dbLog( client, 36, client, "bought WEAPON - " .. itemValue )

		local govMoney = math.floor( price / 6 )
		exports.global:giveMoney(getTeamFromName("Government of Los Santos"), govMoney)
		price = price - govMoney -- you'd obviously get less if the gov asks for percentage.
	elseif itemID == 116 then -- log weapon purchases
		exports.logs:dbLog( client, 36, client, "bought AMMO - " .. itemValue )

		local govMoney = math.floor( price / 6 )
		exports.global:giveMoney(getTeamFromName("Government of Los Santos"), govMoney)
		price = price - govMoney -- you'd obviously get less if the gov asks for percentage.
	end

	-- Deduct interior supplies / except for ints made in world map or or not in an active business
	if interior and isActiveBusiness(interior) and status.type ~= 2 then
		-- give profit / what kind of interior and who can get profit is defined in the giveProfit() function.
		triggerClientEvent("updateShopGUI", client, interior, shoptype, index)
		giveProfit(interior, source, client, item, price)
		takeSupplies(interior, itemID, itemValue, getMetaItemName(item))
	end

	-- May leave so logs here but I'm too asleep atm / max
end )

function collectMoney(int)
	-- source = the shop
	-- client = the player
	-- int = the business

	-- permission check
	local can, why = canPlayerCollectProfit(client, source, int)
	if not can then
		return outputChatBox(why, client, 255, 0, 0)
	end

	-- prepair some info
	local ped_id = getElementData(source, "dbid")
	local sIncome = tonumber(getElementData(source, "sIncome")) or 0
	local sPendingWage = tonumber(getElementData(source, "sPendingWage")) or 0
	local faction = why
	local profit = sIncome - sPendingWage

	if profit > 0 then -- if profit is positive.
		-- reset shop's income & wage
		if setShopStats(source, 'sPendingWage', 0) and setShopStats(source, 'sIncome', 0) then
			if faction then
				if exports.bank:giveBankMoney(faction, profit) then
					exports.bank:addBankTransactionLog(0, -getElementData(faction, 'id'), profit, 13, 'Income from shopkeeper '..tostring(getPedName(source)), getPedName(source))
					playCollectMoneySound(source)
					outputChatBox("Total $"..exports.global:formatMoney(profit).." net income has been transferred to "..getTeamName(faction).."'s bank.", client, 0, 255, 0)
					if destroyElement(source) then
						return loadOneShop(ped_id)
					end
				end
			else
				if exports.global:giveMoney(client, profit) then
					playCollectMoneySound(source)
					if destroyElement(source) then
						return loadOneShop(ped_id)
					end
				end
			end
		else
			outputChatBox("Internal error! Could not reset shop stats.", client, 255,0,0)
			return false
		end
	else
		solvePendingWage(client, source, client)
		--outputChatBox("You must pay the NPC his wage first because your net income is negative.", client, 255, 0, 0)
		return false
	end

	-- just in case
	return false
end
addEvent("shop:collectMoney", true )
addEventHandler("shop:collectMoney", getRootElement(), collectMoney)

function solvePendingWage(payer, ped, solver)
	-- if wage is not positive, assuming everything is done
	local wage = tonumber(getElementData(ped, "sPendingWage")) or 0
	if wage <= 0 then
		return 0
	end

	-- preparing some info
	local pedName = getPedName(ped)
	local took_money = false

	if getElementType(payer) == 'player' then
		local playerName = exports.global:getPlayerName(payer)
		if exports.global:takeMoney(payer, wage) then
			playPayWageSound(ped )
			took_money = true
		end
	elseif getElementType(payer) == 'team' then
		if exports.bank:takeBankMoney(payer, wage) then
			playPayWageSound(ped )
			took_money = true
			-- leave some bank transaction logs
			exports.bank:addBankTransactionLog(-getElementData(payer, 'id'), 0, wage, 3, 'NPC wage', pedName)
		end
	end

	-- now finally we can clear the wage on npc
	if took_money then
		setShopStats(ped, 'sPendingWage', 0)
		local id = getElementData(ped, 'dbid')
		if destroyElement(ped) then
			loadOneShop(id)
		end
		return wage
	end

	-- just in case
	return 0
end
addEvent("shop:solvePendingWage", true )
addEventHandler("shop:solvePendingWage", getRootElement(), solvePendingWage)

function checkSupplies(thePlayer)
    local dbid, entrance, exit, inttype,interiorElement = exports.interior_system:findProperty( thePlayer )

    if (dbid==0) then
        outputChatBox("You are not in a business.", thePlayer, 255, 0, 0)
    else
        local interiorStatus = getElementData(interiorElement, "status")
        local owner = interiorStatus.owner

        if exports.integration:isPlayerTrialAdmin(thePlayer) or tonumber(owner)==getElementData(thePlayer, "dbid") or exports.global:hasItem(thePlayer, 4, dbid) or exports.global:hasItem(thePlayer, 5, dbid) then
            outputChatBox("You can check supplies of a business by opening the respective shop GUI.", thePlayer, 255, 194, 14)
        else
            outputChatBox("You are not in a business or do you do own the business.", thePlayer, 255, 0, 0)
        end
    end
end
addCommandHandler("checksupplies", checkSupplies, false, false)

function canIUseThisName(pedName)
	local checkName = mysql:query("SELECT `id` FROM `characters` WHERE `charactername`='".. mysql:escape_string( pedName ) .."'")
	local row3 = {}
	if checkName then
		row3 = mysql:fetch_assoc(checkName) or false
		mysql:free_result(checkName)
	end
	if row3 then
		return false, "An other player's character has already used this name '"..pedName.."'."
	end

	local checkName2 = mysql:query("SELECT `id` FROM `shops` WHERE `pedName`='".. mysql:escape_string( pedName ) .."'")
	local row33 = {}
	if checkName2 then
		row33 = mysql:fetch_assoc(checkName2) or false
		mysql:free_result(checkName2)
	end
	if row33 then
		return false, "An other shop has already used this name '"..pedName.."'."
	end
	return true, "This name is cool"
end

function updateShopSupplies(interiorID, supplies, thePlayer, cost, pedName)
	local status = getElementData(source, "status")
	local updateSupplies = fromJSON(status.supplies)
	local haulSupplies = {}
	for i, v in pairs(supplies) do
		updateSupplies[i] = (updateSupplies[i] or 0) + math.ceil(v/2)
		haulSupplies[i] = math.floor(v/2)
	end

	local success, why = exports['job-system-trucker']:remoteOrderSupplies(thePlayer, haulSupplies, cost, false)
	if success then
		local query = mysql:query_free("UPDATE interiors SET supplies='" .. mysql:escape_string(toJSON(updateSupplies)) .. "' WHERE id='" .. interiorID .. "'")
		if query then
			status.supplies = toJSON(updateSupplies)
			setElementData(source, "status", status)
			exports.bank:takeBankMoney(thePlayer, cost)
			exports.bank:addBankTransactionLog(getElementData(thePlayer, "dbid"), nil, cost, 0, "SHOP RESTOCK", "Purchased "..tostring(cost).."$ worth of supplies for business ID"..tostring(interiorID), nil, nil)
			storeKeeperSay(thePlayer, "We have stocked your business with half of your order. The other half has been sent to RS Haul delivery drivers.", pedName)
		end
	else
		outputChatBox(why, thePlayer, 255, 0, 0)
	end
end
addEvent("updateShopSupplies", true)
addEventHandler("updateShopSupplies", getRootElement(), updateShopSupplies)


--[[

		if not exports["lottery-system"]:canThisPlayerBuyTicket(client) then
			outputChatBox( "One player now can only buy one lottery ticket every 20 minutes.", client, 255, 0, 0 )
			outputChatBox( "You've already bought another lottery ticket not long ago, please try again later.", client, 255, 0, 0 )
			return false
		end

		local lotteryJackpot = exports['lottery-system']:getLotteryJackpot()
		if tonumber(lotteryJackpot) == -1 then
			outputChatBox( "Sorry, someone already won the lottery. Please wait for the next draw.", client, 255, 0, 0 )
			return
		else
			local updatedJackpot = tonumber(lotteryJackpot) + math.ceil(price * 2 / 3)
			exports['lottery-system']:updateLotteryJackpot(updatedJackpot)

			local lotteryTicketNumber = 0
			local lotteryTicketNumber = getElementData(client, 'test:nextPickedLotteryNumber') or math.random(2,48) -- Pick a random number for the lottery ticket number between 2 and 48
			itemValue = tonumber(lotteryTicketNumber)

			if tonumber(lotteryTicketNumber) == tonumber(exports['lottery-system']:getLotteryNumber()) then
				setTimer(function(player, jp) exports['global']:giveMoney(player, jp) end, 100, 1, client, updatedJackpot)
				outputChatBox( "You won! Jackpot: $" .. exports.global:formatMoney(updatedJackpot) .. ".", client, 0, 255, 0 )

				exports['lottery-system']:lotteryDraw()

				for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
					if (getElementData(value, "loggedin")==1) then
						outputChatBox("[NEWS] " .. getPlayerName(client):gsub("_"," ") .. " won the lottery jackpot of $" .. exports.global:formatMoney(updatedJackpot) .. ".", value, 200, 100, 200)
					end
				end
				exports['lottery-system']:updateLotteryJackpot(-1)
				-- Timer to re-enable lottery 10 minutes after a ticket has been drawn.
				setTimer(function ()
					exports['lottery-system']:updateLotteryJackpot(0)
				end, 600000, 1)

				wonTheLottery = true
			else
				outputChatBox( "Sorry, your number did not get picked. You lost. You got number " .. lotteryTicketNumber .. ".", client, 255, 0, 0 )
			end
			lotteryTicketNumber = 0
		end

]]
