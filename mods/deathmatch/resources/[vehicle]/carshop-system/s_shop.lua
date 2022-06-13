-- MAXIME
local rc = 10
local bmx = 0
local bike = 15
local low = 25
local offroad = 35
local sport = 100
local van = 50
local bus = 75
local truck = 200
local boat = 300 -- except dinghy
local heli = 500
local plane = 750
local race = 75
local minute = 10 -- CARSHOP UPDATE INTERVAL IN MINUTE
local spawnedShopVehicles = {}
local vehicleTaxes = {
	offroad, low, sport, truck, low, low, 1000, truck, truck, 200, -- dumper, stretch
	low, sport, low, van, van, sport, truck, heli, van, low,
	low, low, low, van, low, 1000, low, truck, van, sport, -- hunter
	boat, bus, 1000, truck, offroad, van, low, bus, low, low, -- rhino
	van, rc, low, truck, 500, low, boat, heli, bike, 0, -- monster, tram
	van, sport, boat, boat, boat, truck, van, 10, low, van, -- caddie
	plane, bike, bike, bike, rc, rc, low, low, bike, heli,
	van, bike, boat, 20, low, low, plane, sport, low, low, -- dinghy
	sport, bmx, van, van, boat, 10, 75, heli, heli, offroad, -- baggage, dozer
	offroad, low, low, boat, low, offroad, low, heli, van, van,
	low, rc, low, low, low, offroad, sport, low, van, bmx,
	bmx, plane, plane, plane, truck, truck, low, low, low, plane,
	plane * 10, bike, bike, bike, truck, van, low, low, truck, low, -- hydra
	10, 20, offroad, low, low, low, low, 0, 0, offroad, -- forklift, tractor, 2x train
	low, sport, low, van, truck, low, low, low, rc, low,
	low, low, van, plane, van, low, 500, 500, race, race, -- 2x monster
	race, low, race, heli, rc, low, low, low, offroad, 0, -- train trailer
	0, 10, 10, offroad, 15, low, low, 3*plane, truck, low,-- train trailer, kart, mower, sweeper, at400
	low, bike, van, low, van, low, bike, race, van, low,
	0, van, 2*plane, plane, rc, boat, low, low, low, offroad, -- train trailer, andromeda
	low, truck, race, sport, low, low, low, low, low, van,
	low, low
}

local global = exports.global
local mysql = exports.mysql
local currentYear = getRealTime().year+1900

function SmallestID() -- finds the smallest ID in the SQL instead of auto increment
	local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM vehicles AS e1 LEFT JOIN vehicles AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result then
		local id = tonumber(result["nextID"]) or 1
		return id
	end
	return false
end

function carshop_updateVehicles( forceUpdate )
	--CLEAR SPAWNED VEHICLES AT SHOPS
	for i, veh in pairs(spawnedShopVehicles) do
		if veh[1] and isElement(veh[1]) and getElementType(veh[1]) == "vehicle" then
			destroyElement(veh[1])
			destroyElement(veh[2])
		end
	end
	spawnedShopVehicles = {}

	local blocking = { }

	for key, value in ipairs( getElementsByType( "player" ) ) do
		local x, y, z = getElementPosition( value )
		table.insert(blocking, { x, y, z, getElementInterior( value ), getElementDimension( value ), true } )
	end

	for key, value in ipairs( getElementsByType( "vehicle" ) ) do
		local x, y, z = getElementPosition( value )
		table.insert(blocking, { x, y, z, getElementInterior( value ), getElementDimension( value ), false, value } )
	end

	for dealerID = 1, #shops do
		if #shops[dealerID]["spawnpoints"] > 0 then
			for k, v in ipairs( shops[dealerID]["spawnpoints"] ) do
				local canPopulate2 = true
				for _, va in ipairs( blocking ) do
					if (v[4] == va[4] and v[5] == va[5]) then
						local distance = getDistanceBetweenPoints3D( v[1], v[2], v[3], va[1], va[2], va[3] )
						if distance < 4 then
							canPopulate2 = false
							if va[7] and isElement(va[7]) and getElementType(va[7]) == "vehicle" then
								respawnVehicle(va[7])
							end
							break
						end
					end
				end

				local vehicleData = getRandomVehicleFromCarshop(dealerID)
				if canPopulate2 and vehicleData then
					local letter1 = string.char(math.random(65,90))
					local letter2 = string.char(math.random(65,90))
					local plate = letter1 .. letter2 .. math.random(0, 9) .. " " .. math.random(1000, 9999)
					local model = tonumber(vehicleData.vehmtamodel)
					--getVehicleModelFromName(data[1]) or tonumber(data[1])

					local vehicle = createVehicle( model , v[1], v[2], v[3], v[4], v[5], v[6], plate  )
					local vehBrand = vehicleData["vehbrand"]
					local vehModel = vehicleData["vehmodel"]
					local vehPrice = tonumber(vehicleData["vehprice"])
					local vehTax = tonumber(vehicleData["vehtax"])
					local vehYear = tonumber(vehicleData["vehyear"])

					local odometer = 0
					if vehYear < currentYear - 1 then
						local yearsSince = currentYear - vehYear - 1
						for i = 1, yearsSince do
							odometer = odometer + math.random(60, 500)
						end
					end

					local vehicle_shop_id = tonumber(vehicleData["id"])
					if not (vehicle and vehBrand and vehModel and vehPrice and vehTax and vehYear and vehicle_shop_id) then
						outputDebugString("failed to spawn a "..data[1])
						--next
					else

						setElementInterior(vehicle, v[4])
						setElementDimension(vehicle, v[5])
						setVehicleLocked( vehicle, true )
						setTimer(setElementFrozen, 180, 1, vehicle, true )
						setVehicleDamageProof( vehicle, true )
						setVehicleVariant(vehicle, exports.vehicle:getRandomVariant(getElementModel(vehicle)))
						v["vehicle"] = vehicle

						local x = v[1] - ( ( math.cos ( math.rad (  v[6] ) ) ) * 1.5 )
						local y = v[2] - ( ( math.sin ( math.rad (  v[6] ) ) ) * 1.5 )
						local tempPickup = nil
						if dealerID == 6 then -- Boatshop
							tempPickup = createPickup(v[1], v[2], v[3]+1, 3, 1239)
						else
							tempPickup = createPickup(x, y, v[3], 3, 1239)
						end
						table.insert(spawnedShopVehicles, {vehicle, tempPickup})
						exports.anticheat:changeProtectedElementDataEx(tempPickup, "carshop:parentCar", v["vehicle"], false)

						exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "brand", vehBrand , true)
						exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "maximemodel", vehModel , true)
						exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "year", vehYear , true)
						exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "odometer", odometer , true)
						exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "carshop:cost", vehPrice , true)
						exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "carshop", dealerID, true)
						exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "carshop:childPickup", tempPickup, false)
						exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "carshop:taxcost", vehTax, true)
						exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "dbid", -1, true)

						exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "vehicle_shop_id", vehicle_shop_id, true)
						for i = 1, 5, 1 do
							exports.anticheat:changeProtectedElementDataEx(v["vehicle"], "description:" .. i, "", true)
						end

						notifyEveryoneWhoOrderedThisModel(shops[dealerID]["name"], shops[dealerID]["nicename"], vehicle_shop_id, vehYear, vehBrand, vehModel, vehPrice)
					end
				end
			end
		end
	end
end

function carshop_pickupUse(thePlayer)
	local parentCar = getElementData(source, "carshop:parentCar")
	if parentCar and isElement(parentCar) then
		local costCar = getElementData(parentCar, "carshop:cost")
		local costTax = getElementData(parentCar, "carshop:taxcost")
		if costCar and costTax then
			triggerClientEvent(thePlayer, "carshop:showInfo", parentCar, costCar, costTax)
		end
		cancelEvent()
	end
end
addEventHandler("onPickupHit", getResourceRootElement(), carshop_pickupUse)

function refreshCarShops(thePlayer, _, fromvehmang)
	if exports.integration:isPlayerLeadAdmin(thePlayer) then
		killTimer(refreshTimer)
		carshop_updateVehicles(true)
		refreshTimer = setTimer( carshop_updateVehicles, 1000*60*minute, 0, false )
		outputChatBox("Carshops refreshed, Timer restarted.", thePlayer, 0, 255, 0)

		local staffUsername = getElementData(thePlayer, "account:username")
		local staffTitle = exports.global:getPlayerAdminTitle(thePlayer)
		exports.global:sendMessageToAdmins("[CARSHOPS] "..staffTitle.." "..staffUsername.." Manually Refreshed the Carshops.")
		exports.logs:dbLog(thePlayer, 4, thePlayer, "RESETCARSHOP")
	else
		outputChatBox("You must now be a lead admin to use this function.", thePlayer, 255, 0, 0)
	end
end
addCommandHandler("restartcarshops", refreshCarShops)
addCommandHandler("refreshcarshops", refreshCarShops)


function carshop_Initalize( )
	carshop_updateVehicles( true )
	refreshTimer = setTimer( carshop_updateVehicles, 1000*60*minute, 0, false )
end
addEventHandler( "onResourceStart", getResourceRootElement(), carshop_Initalize)

function carshop_blockEnterVehicle(thePlayer)
	local isCarShop = getElementData(source, "carshop")
	if (isCarShop) then
		local costCar = getElementData(source, "carshop:cost")

		local payByCash = true
		local payByBank = true

		if not exports.global:hasMoney(thePlayer, costCar) or costCar == 0 then
			payByCash = false
		end

		local money = getElementData(thePlayer, "bankmoney") - costCar
		if money < 0 or costCar == 0 then
			payByBank = false
		end

		triggerClientEvent(thePlayer, "carshop:buyCar", source, costCar, payByCash, payByBank)
	end
	cancelEvent()
end
addEventHandler( "onVehicleEnter", getResourceRootElement(), carshop_blockEnterVehicle)
addEventHandler( "onVehicleStartEnter", getResourceRootElement(), carshop_blockEnterVehicle)

function carshop_buyVehicle(paymentMethod)
	if not client then
		return false
	end

	local isCarshopVehicle = getElementData(source, "carshop")
	if not isCarshopVehicle then
		return false
	end

	local isOverlayDisabled = getElementData(client, "hud:isOverlayDisabled")

	if not exports.global:canPlayerBuyVehicle(client) then
		if isOverlayDisabled then
			outputChatBox("You have already reached the maximum number of vehicles", client, 0, 255, 0)
		else
			exports.hud:sendBottomNotification(client, "Maximum vehicle limit", "You have already reached the maximum number of vehicles. /stats for details.")
		end
		return false
	end

	local costCar = getElementData(source, "carshop:cost")
	if (paymentMethod == "cash") then
		if not exports.global:hasMoney(client, costCar) or costCar == 0 then
			if isOverlayDisabled then
				outputChatBox("You don't have enough money on hand for this pal..", client, 0, 255, 0)
			else
				exports.hud:sendBottomNotification(client, "Money is always a problem..", "You don't have enough money on hand for this pal..")
			end
			return false
		else
			exports.global:takeMoney(client, costCar)
		end
	elseif (paymentMethod == "bank") then
		local money = getElementData(client, "bankmoney") - costCar
		if money < 0 or costCar == 0 then
			if isOverlayDisabled then
				outputChatBox("You don't have enough money in your bank account for this pal..", client, 0, 255, 0)
			else
				exports.hud:sendBottomNotification(client, "Money is always a problem..", "You don't have enough money in your bank account for this pal..")
			end
			return false
		else
			exports.anticheat:changeProtectedElementDataEx(client, "bankmoney", money, false)
			mysql:query_free("UPDATE characters SET bankmoney=" .. mysql:escape_string((tonumber(money) or 0)) .. " WHERE id=" .. mysql:escape_string(getElementData( client, "dbid" )))
		end
	elseif (paymentMethod == "token") then
		if costCar <= 35000 then
			if not exports.global:takeItem(client, 263) then
				outputChatBox("There was an issue processing your request.", client, 255, 0 ,0)
				return false
			end
		else
			outputChatBox("You cannot use a token on a car worth over $35,000.", client, 255, 0, 0)
			return false
		end
	else
		if isOverlayDisabled then
			outputChatBox("No.", client, 0, 255, 0)
		else
			exports.hud:sendBottomNotification(client, "No!", "Just no...")
		end
		return false
	end

	local result = mysql:query_fetch_assoc("SELECT stock FROM vehicles_shop WHERE id="..getElementData(source, "vehicle_shop_id"))
	if result then
		if tonumber(result["stock"]) < 1 then
			if isOverlayDisabled then
				outputChatBox("Sorry, it appears this one is taken.", client, 0, 255, 0)
			else
				exports.hud:sendBottomNotification(client, "Stock", "Sorry it appears this model is currently out of stock.")
			end
			return false
		end
	end

	local dbid = getElementData(client, "account:character:id")
	local modelID = getElementModel(source)
	local x, y, z = getElementPosition(source)
	local rx, ry, rz = getElementRotation(source)
	local odometer = tonumber(getElementData(source, 'odometer')) * 1000
	local col = { getVehicleColor(source) }
	local color1 = toJSON( {col[1], col[2], col[3]} )
	local color2 = toJSON( {col[4], col[5], col[6]} )
	local color3 = toJSON( {col[7], col[8], col[9]} )
	local color4 = toJSON( {col[10], col[11], col[12]} )
	local letter1 = string.char(math.random(65,90))
	local letter2 = string.char(math.random(65,90))
	local var1, var2 = getVehicleVariant(source)
	local plate = letter1 .. letter2 .. math.random(0, 9) .. " " .. math.random(1000, 9999)
	local locked = 1
	local vehShopID = getElementData(source, "vehicle_shop_id") or 0
	local smallestID = SmallestID()
	if getVehicleType(source) == "BMX" then locked = 0 end
	local insertid = mysql:query_insert_free("INSERT INTO vehicles SET id='"..mysql:escape_string(smallestID).."', model='" .. mysql:escape_string(modelID) .. "', x='" .. mysql:escape_string(x) .. "', y='" .. mysql:escape_string(y) .. "', z='" .. mysql:escape_string(z) .. "', rotx='" .. mysql:escape_string(rx) .. "', roty='" .. mysql:escape_string(ry) .. "', rotz='" .. mysql:escape_string(rz) .. "', color1='" .. mysql:escape_string(color1) .. "', color2='" .. mysql:escape_string(color2) .. "', color3='" .. mysql:escape_string(color3) .. "', color4='" .. mysql:escape_string(color4) .. "', faction='-1', owner='" .. mysql:escape_string(dbid) .. "', plate='" .. mysql:escape_string(plate) .. "', currx='" .. mysql:escape_string(x) .. "', curry='" .. mysql:escape_string(y) .. "', currz='" .. mysql:escape_string(z) .. "', currrx='0', currry='0', currrz='" .. mysql:escape_string(rz) .. "', locked='" .. mysql:escape_string(locked) .. "',variant1="..var1..",variant2="..var2..",description1='', description2='', description3='',description4='',description5='', creationDate=NOW(), createdBy='-1', vehicle_shop_id='"..mysql:escape_string(vehShopID).."',odometer='".. mysql:escape_string(odometer).."', tokenUsed=" .. (paymentMethod == "token" and "1" or "0"))

	if not insertid then
		return false
	end

	exports.logs:dbLog(client, 6, "ve"..tostring(insertid), "BOUGHTNEWCAR "..getVehicleNameFromModel(modelID).." (Custom Model ID #"..vehShopID..", Price: $"..exports.global:formatMoney(costCar)..")")
	call( getResourceFromName( "item-system" ), "deleteAll", 3, insertid )
	exports.global:giveItem( client, 3, insertid )
	local tempPickup = getElementData(source,"carshop:childPickup")
	if (isElement(tempPickup)) then
		destroyElement(tempPickup)
	end
	destroyElement(source)
	exports.vehicle:reloadVehicle(insertid)

	local license = (getElementData(client, "license.car") == 1) and "" or "You don't have a drivers license. You better not drive this on the street."

	if isOverlayDisabled then
		outputChatBox("Congratulations, you just bought a vehicle!", client)
		outputChatBox("Make sure to /park it at the respawnspot you want within an hour,", client)
		outputChatBox("otherwise the vehicle will get deleted, non-recoverable.", client)
		outputChatBox(license, client)
		outputChatBox("Edit the vehicle description using /ed or /editdescription.", client)
	else
		local content = {}
		table.insert(content, {"Make sure to /park it at the respawnspot you want within an hour or the vehicle will get deleted!"})
		table.insert(content, {license})
		table.insert(content, {"Edit the vehicle description using /ed or /editdescription."})

		exports.hud:sendBottomNotification(client, "Congratulations, you just bought a vehicle!", content, 30)
	end

	local adminID = getElementData(client, "account:id")
	local addLog = mysql:query_free("INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES ('"..tostring(insertid).."', 'bought from carshop', '"..adminID.."')") or false
	if not addLog then
		outputDebugString("Failed to add vehicle logs.")
	end
	local reduceStock = mysql:query_free("UPDATE `vehicles_shop` SET `stock`=`stock`-1 WHERE `id`="..vehShopID)

	triggerEvent("vehicle-manager:handling:orderVehicle:cancel", client)
end
addEvent("carshop:buyCar", true)
addEventHandler("carshop:buyCar", getRootElement(), carshop_buyVehicle)

local vehicleColors
function getRandomVehicleColor( vehicle )
	if not vehicleColors then
		vehicleColors = { }
		local file = fileOpen( "vehiclecolors.conf", true )
		while not fileIsEOF( file ) do
			local line = fileReadLine( file )
			if #line > 0 and line:sub( 1, 1 ) ~= "#" then
				local model = tonumber( gettok( line, 1, string.byte(' ') ) )
				if not vehicleColors[ model ] then
					vehicleColors[ model ] = { }
				end
				vehicleColors[ model ][ #vehicleColors[ model ] + 1 ] = {
					tonumber( gettok( line, 2, string.byte(' ') ) ),
					tonumber( gettok( line, 3, string.byte(' ') ) ) or nil,
				}
			end
		end
		fileClose( file )
	end

	local colors = vehicleColors[ getElementModel( vehicle ) ]
	if colors then
		return unpack( colors[ math.random( 1, #colors ) ] )
	end
end

function fileReadLine( file )
	local buffer = ""
	local tmp
	repeat
		tmp = fileRead( file, 1 ) or nil
		if tmp and tmp ~= "\r" and tmp ~= "\n" then
			buffer = buffer .. tmp
		end
	until not tmp or tmp == "\n" or tmp == ""

	return buffer
end

function isForSale(vehicle)
	if type(vehicle) == "number" then
	elseif type(vehicle) == "string" then
		vehicle = tonumber(vehicle)
	elseif isElement(vehicle) and getElementType(vehicle) == "vehicle" then
		vehicle = getElementModel(vehicle)
	else
		return false
	end
	for _, shop in ipairs(shops) do
		for _, data in ipairs(shop.prices) do
			if getVehicleModelFromName(data[1]) == vehicle then
				return true
			end
		end
	end
	return false
end

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

function notifyEveryoneWhoOrderedThisModel(shopname, shopnicename, vehicle_shop_id, vehYear, vehBrand, vehModel, vehPrice)
	for i, player in pairs (getElementsByType("player")) do
		if shopname and shopnicename and vehicle_shop_id and vehYear and vehBrand and vehModel and vehPrice then
			local orderedVehID = getElementData(player, "carshop:grotti:orderedvehicle:"..shopname) or false
			if orderedVehID and tonumber(orderedVehID) == tonumber(vehicle_shop_id) then
				if exports.global:hasItem(player, 2) then
					local languageslot = getElementData(player, "languages.current") or 1
					local language = getElementData(player, "languages.lang" .. languageslot)
					local languagename = call(getResourceFromName("language-system"), "getLanguageName", language)
					local playerName = exports.global:getPlayerName(player)
					local itemName = vehYear.." "..vehBrand.." "..vehModel

					exports.global:sendLocalText(player, "*"..playerName.." receives a text message.", 255, 51, 102, 30, {}, true)
					outputChatBox("["..languagename.."] SMS from "..shopnicename..": Hello! As you have ordered, we now have a "..itemName.." in stock for $"..exports.global:formatMoney(vehPrice)..". Come check it out!" , player, 120, 255, 80)
				end
			end
		end
	end
end

function isAlreadySpawned(shopID, randomID)
	for k,v in pairs(shops[tonumber(shopID)]["spawnpoints"]) do
		if isElement(v["vehicle"]) then
			local id = getElementData(v["vehicle"], "vehicle_shop_id")
			if id == randomID then
				outputDebugString("Carshop / Duplicate Spawn, retrying..")
				return true
			end
		end
	end
	return false
end

function getRandomVehicleFromCarshop(shopID)
	if shopID and tonumber(shopID) then
		local preparedQuery = "SELECT * FROM `vehicles_shop` WHERE `enabled` = '1' AND `spawnto`='"..exports.global:toSQL(shopID).."' AND `stock`>0 "
		local q1 = mysql:query(preparedQuery)
		if not q1 then
			outputDebugString("Database error / getRandomVehicleFromCarshop / carshop-sytem / s_shop.lua")
			return false
		end
		local tempTable = {}
		while true do
			local row = mysql:fetch_assoc(q1)
			if not row then break end
			for i=1,tonumber(row.spawn_rate) do
				table.insert(tempTable, row )
			end
		end
		mysql:free_result(q1)
		if #tempTable > 0 then
			local count = 0
			local ran
			repeat
				if count > 5 then
					return tempTable[0]
				else
					ran = math.random( 1, #tempTable )
					count = count+1
				end
			until not isAlreadySpawned(shopID, tempTable[ran].id)
			return tempTable[ran]
		else
			return false
		end
	end
end
