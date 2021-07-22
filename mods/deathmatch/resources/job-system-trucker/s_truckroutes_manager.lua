--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

routes = { --[[(1,2,3)coordinates (4)RequiringWeight (5)DriverOnJog (6)Location Name (7)OrderID (8)OrderInterior (9)Distance from to driver   ]]
	[1] = {  -69.306640625, -1132.767578125, 1.1973875761032, { ["115:6"] = 5 }, nil, "Shovel Delivery", 1, 956, 10 },
}

local function SmallestID() -- finds the smallest ID in the SQL instead of auto increment
	local result1 = mysql:query_fetch_assoc("SELECT MIN(e1.orderID+1) AS nextID FROM jobs_trucker_orders AS e1 LEFT JOIN jobs_trucker_orders AS e2 ON e1.orderID +1 = e2.orderID WHERE e2.orderID IS NULL")
	if result1 then
		return result1["nextID"] ~= mysql_null() and tonumber(result1["nextID"]) or 1
	end
	return false
end

local function addRouteIfNotExisted(route)
	local existed = false
	for i, r in pairs(routes) do
		if r[7] == route[7] then
			existed = true
			break
		end
	end
	if not existed then
		return table.insert(routes, route)
	end
end

local function hasOrder(int)
	for i, r in pairs(routes) do
		if tonumber(r[8]) == tonumber(int) then
			return true
		end
	end
end

function fetchOrders()
	dbQuery( function ( qh )
		local res, nums, id = dbPoll( qh, 0 )
		if res then
			for i, row in ipairs( res ) do
				addRouteIfNotExisted( { row["orderX"], row["orderY"], row["orderZ"], row["orderWeight"], false, row["orderName"], row["orderID"], row["orderInterior"] } )
			end
			outputDebugString("[TRUCKER] Refreshed "..nums.." orders.")
		else
			dbFree( qh )
		end
	end, exports.mysql:getConn('mta'), "SELECT * FROM jobs_trucker_orders " )
end

function addOrder(int, supplies, x, y, z, name)
	if int and hasOrder(int) then
		return false, "You already had a pending order. Please wait until it's delivered to place a new one."
	else
		local qh = dbQuery( exports.mysql:getConn('mta'), "INSERT INTO jobs_trucker_orders SET orderX=?, orderY=?, orderZ=?, orderName=?, orderInterior=?, orderSupplies=?", x, y, z, name, int or 0, toJSON(supplies) )
		local res, nums, id = dbPoll( qh, 10000 )
		if res and nums > 0 then
			local r = { tonumber(x), tonumber(y), tonumber(z) , supplies, false, name, id, int or 0 }
			-- insert to routes table.
			table.insert(routes, r)
			return true
		else
			return false, "Database error. Code 76"
		end
	end
end

function checkActiveRoutes(thePlayer, commandName)
	if (exports.integration:isPlayerScripter(thePlayer)) then
		local count = 0
		outputChatBox("All active Routes:", thePlayer)
		for i = 1, #routes do
			if routes[i] and routes[i][5] then
				outputChatBox("    "..getPlayerName(routes[i][5]):gsub("_", " ").." is working in Route #"..i.." - "..(routes[i][6] or "Unknown").." ("..(routes[i][4] or "0").." kg)", thePlayer)
				count = count + 1
			end
		end
		outputChatBox(count.." active Routes.", thePlayer)
	else
		outputChatBox("Only Full Admin and above can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("checkactiveroutes", checkActiveRoutes, false, false)

function showActualOrders(thePlayer, commandName)
	if (exports.integration:isPlayerScripter(thePlayer)) then
		local count = 0
		local tempRoutes = {}
		outputChatBox("[TRUCKER] All Actual Orders:", thePlayer)
		for i = 1, #routes do
			if routes[i] and tonumber(routes[i][8]) and (tonumber(routes[i][8]) > 0) then
				table.insert(tempRoutes, routes[i])
				outputChatBox("     Order ID #"..routes[i][7].." - "..(routes[i][6] or "Unknown").." (Int ID#"..routes[i][8]..", "..(routes[i][4] or "0").." kg)", thePlayer)
				if debugmode then
					outputDebugString("     Order ID #"..routes[i][7].." - "..(routes[i][6] or "Unknown").." (Int ID#"..routes[i][8]..", "..(routes[i][4] or "0").." kg)")
				end
				count = count + 1
			end
		end
		outputChatBox(count.." actual orders", thePlayer)
		if debugmode then
			outputDebugString(count.." actual orders")
		end
		if count > 0 then
			triggerClientEvent(thePlayer, "job-system-trucker:displayAllMarkers", thePlayer, tempRoutes)
		end
	else
		outputChatBox("Only Full Admins can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("showActualOrders", showActualOrders, false, false)

function showAllTruckMarkers(thePlayer, commandName, ...)
	if (exports.integration:isPlayerScripter(thePlayer)) then
		local count = 0
		local tempRoutes = {}
		local search = ... and table.concat({...}, ' '):lower() or nil
		outputChatBox("[TRUCKER] All Truck Markers:", thePlayer)
		for i = 1, #routes do
			if routes[i] then
				table.insert(tempRoutes, routes[i])

				if not search or (routes[i][6] and routes[i][6]:lower():find(search, nil, true)) then
					outputChatBox("Order ID #"..routes[i][7]..", Name: "..(routes[i][6] or " ")..", Worker: "..(routes[i][5] and getPlayerName(routes[i][5]) or " ")..", Kg: "..(routes[i][4] or "0")..", To Int ID#: "..(routes[i][8] == 0 and "Generic" or routes[i][8]), thePlayer)
					if debugmode then
						outputDebugString("Order ID #"..routes[i][7]..", Name: "..(routes[i][6] or " ")..", Worker: "..(routes[i][5] and getPlayerName(routes[i][5]) or " ")..", Kg: "..(routes[i][4] or "0")..", To Int ID#: "..(routes[i][8] == 0 and "Generic" or routes[i][8]))
					end
				end
				count = count + 1
			end
		end
		outputChatBox(count.." Markers", thePlayer)
		if debugmode then
			outputDebugString(count.." Markers")
		end
		if count > 0 then
			triggerClientEvent(thePlayer, "job-system-trucker:displayAllMarkers", thePlayer, tempRoutes)
		end
	else
		outputChatBox("Only Full Admins can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("showAllTruckMarkers", showAllTruckMarkers, false, false)

function scripterFetchActualOrders(thePlayer, commandName)
	if (exports.integration:isPlayerScripter(thePlayer)) then
		fetchOrders()
		outputChatBox("Done", thePlayer)
	end
end
addCommandHandler("fetchActualOrders", scripterFetchActualOrders, false, false)

function addOrderManually(thePlayer, commandName , ...)
	if (exports.integration:isPlayerScripter(thePlayer)) then
		if not (...) then
			outputChatBox( "SYNTAX: /" .. commandName .. " [Location Name]", thePlayer, 255, 194, 14 )
			return false
		end
		local orderName = table.concat({...}, " ")
		local x, y, z = getElementPosition(thePlayer)
		if addOrder(nil, {}, x, y, z, orderName ) then
			outputChatBox("Successfully added order ("..orderName..") into SQL manuanlly.", thePlayer, 0,255,0)
		else
			outputChatBox("Failed to add order '"..orderName.."' into SQL manuanlly.", thePlayer, 255,0,0)
		end
	end
end
addCommandHandler("addtruckerjobmarker", addOrderManually, false, false)

function delMarker(id)
	for i, route in pairs( routes ) do
		if route[7] == tonumber(id) then
			if routes[5] and isElement(routes[5]) then
				outputChatBox(getPlayerName(routes[5]):gsub("_", " ").." is currently working on this route. Please wait for him to complete it.", client, 255,0,0)
			else
				table.remove( routes, i )
				dbExec( exports.mysql:getConn('mta'), "DELETE FROM jobs_trucker_orders WHERE orderID=?", id )
				outputChatBox("Deleted marker ID #"..id..".", client, 0,255,0)
			end
			break
		end
	end
end
addEvent("truckerjob:delMarker", true)
addEventHandler("truckerjob:delMarker", root, delMarker)

local function getFreeActualOrder()
	for i, route in pairs(routes) do
		if route[8] and tonumber(route[8]) and tonumber(route[8]) > 0 then -- is actual order
			if not (route[5] and isElement(route[5]) and getElementType(route[5]) == "player") then -- is unoccupied
				return i
			end
		end
	end
end

local attempts = {}
function selectAFreeSpot(thePlayer)
	-- check and get some required parameters
	if #routes < 1 then
		return false
	end
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then
		return false
	end

	-- check if it exceeded max attempts
	local pid = getElementData(thePlayer, "dbid")
	attempts[pid] = (attempts[pid] or 0)+1

	-- always check for actual order on first attempt.
	local rand, isActualOrder = nil
	if attempts[pid] == 1 then
		rand = getFreeActualOrder()
	end

	-- if actual order not found, randomize generic a order.
	if not rand then
		rand = math.random(1, #routes)
	end
	local route = routes[rand]

	-- check if route is occupied
	if route[5] and isElement(route[5]) and getElementType(route[5]) == "player" then
		return selectAFreeSpot(thePlayer) -- start over again with another route.
	end

	-- from here to below, it should have got a free route. Let's finish it.
	-- free the previous route.
	freeSpot(thePlayer)

	-- assign to new route
	routes[rand][5] = thePlayer

	if route[8] and tonumber(route[8]) and tonumber(route[8]) > 0 then -- if it is an actual order from other players
		isActualOrder = "Actual (For interior ID#"..route[8]..")"
		-- notify truckers
		local jobLevel = getElementData(thePlayer, 'jobLevel')
		notifyTruckers("RS Haul Operator: Order #"..routes[rand][7].." - Delivery to "..routes[rand][6].." has been assigned to Trucker "..jobLevel.." - "..exports.global:getPlayerName(thePlayer)..".", true)
	else
		-- if for any reasons, markers don't have required supplies set, so let's generate some.
		if not route[4] or not tonumber(route[4]) or tonumber(route[4]) <= 0 then
			routes[rand][4] = getRandomRequiredWeight(getElementModel(vehicle))
		end
		isActualOrder = "Simulated (Supplies: "..routes[rand][4]..")"
	end

	--outputDebugString("[TRUCKER] Player "..getPlayerName(thePlayer):gsub("_", " ").." accepted order '"..tostring(route[6]).."' , Marker Info: "..isActualOrder)

	-- set its index, reset attempts, then return
	routes[rand].index = rand
	attempts[pid] = nil


	return routes[rand]
end
