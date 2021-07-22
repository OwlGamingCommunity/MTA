--Warning, not sure who originally made this but it's very noobish and messy. If you're about to modify this, better remake a new one :< / maxime - Sorry maxime no time for that right now
local mysql = exports.mysql
local serverRegFee = 2000

function getPlateList()
	--local allVehicles = getElementsByType("vehicle")
	local vehicleTable = { }
	local playerDBID = getElementData(client,"dbid")
	if not playerDBID then
		return
	end
	for _,vehicleElement in ipairs( exports.pool:getPoolElementsByType("vehicle") ) do
		if (getElementData(vehicleElement, "owner")) and (tonumber(getElementData(vehicleElement, "owner")) == tonumber(playerDBID)) and exports.vehicle:hasVehiclePlates(vehicleElement) then
			local vehicleID = getElementData(vehicleElement, "dbid")
			table.insert(vehicleTable, { vehicleID, vehicleElement } )
		end
	end
	triggerClientEvent(client, "vehicle-plate-system:clist", client, vehicleTable)
end
addEvent("vehicle-plate-system:list", true)
addEventHandler("vehicle-plate-system:list", getRootElement(), getPlateList)

function getRegisterList()
	--local allVehicles = getElementsByType("vehicle")
	local vehicleTable = { }
	local playerDBID = getElementData(client,"dbid")
	if not playerDBID then
		return
	end
	for _,vehicleElement in ipairs( exports.pool:getPoolElementsByType("vehicle") ) do
		local faction = tonumber(getElementData(vehicleElement, "faction"))
		if (getElementData(vehicleElement, "owner") and tonumber(getElementData(vehicleElement, "owner")) == tonumber(playerDBID)) and exports.vehicle:hasVehiclePlates(vehicleElement) then
			local vehicleID = getElementData(vehicleElement, "dbid")
			table.insert(vehicleTable, { vehicleID, vehicleElement, faction = false} )
		elseif faction > 0 and exports.factions:hasMemberPermissionTo(client, faction, "respawn_vehs") then
			local vehicleID = getElementData(vehicleElement, "dbid")
			table.insert(vehicleTable, { vehicleID, vehicleElement, faction = faction } )
		end
	end
	triggerClientEvent(client, "vehicle-plate-system:rlist", client, vehicleTable)
end
addEvent("vehicle-plate-system:registerlist", true)
addEventHandler("vehicle-plate-system:registerlist", getRootElement(), getRegisterList)

function getInsuranceList()
	--local allVehicles = getElementsByType("vehicle")
	local vehicleTable = { }
	local playerDBID = getElementData(client,"dbid")
	if not playerDBID then
		return
	end
	for _,vehicleElement in ipairs( exports.pool:getPoolElementsByType("vehicle") ) do
		if (getElementData(vehicleElement, "owner")) and (tonumber(getElementData(vehicleElement, "owner")) == tonumber(playerDBID)) then
			local vehicleID = getElementData(vehicleElement, "dbid")
			local insuranceData = exports.insurance:getVehicleInsuranceData(vehicleID)
			if insuranceData then
				table.insert(vehicleTable, { vehicleID, vehicleElement, insuranceData } )
			end
		end
	end
	triggerClientEvent(client, "vehicle-plate-system:ilist", client, vehicleTable)
end
addEvent("vehicle-plate-system:insurancelist", true)
addEventHandler("vehicle-plate-system:insurancelist", getRootElement(), getInsuranceList)

function pedTalk(state)
	if (state == 1) then
		--exports.global:sendLocalText(source, "Gabrielle McCoy says: Welcome! Would you be unregistering, registering or changing your vehice plates today?", 255, 255, 255, 10)
		--outputChatBox("The fee is $".. exports.global:formatMoney(serverRegFee) .. " per vehicle.", source, 200, 200, 200)
	elseif (state == 2) then
		--exports.global:sendLocalText(source, "[English] Gabrielle McCoy says: Sorry but the fee to register new plates is $" .. exports.global:formatMoney(serverRegFee) .. ". Please come back once you have the money.", 255, 255, 255, 10)
		outputChatBox(source, "You lack of GCs to activate this feature.", 255,0,0)
	elseif (state == 3) then
		--exports.global:sendLocalText(source, "[English] Gabrielle McCoy says: That is great! Lets get everything set up for you in our system.", 255, 255, 255, 10)
	elseif (state == 4) then
		exports.global:sendLocalText(source, "[English] Gabrielle McCoy says: No? Well I hope you change your mind later. Have a nice day!", 255, 255, 255, 10)
	elseif (state == 5) then
		exports.global:sendLocalText(source, " *Gabrielle McCoy begins inputting the information into her computer.", 255, 51, 102)
		exports.global:sendLocalText(source, "[English] Gabrielle McCoy says: Alright, you should be good to go, I'll send someone out to deal with your vehicles license plate. Have a nice day!", 255, 255, 255, 10)
	elseif (state == 6) then
		exports.global:sendLocalText(source, "[English] Gabrielle McCoy says: Hmmm. According to our records, that is already a registered license plate.", 255, 255, 255, 10)
	elseif (state == 7) then
		exports.global:sendLocalText(source, "[English] Gabrielle McCoy says: Well, I'm sorry but your vehicle doesn't require a registered plate or papers.", 255, 255, 255, 10)
	elseif (state == 8) then
		exports.global:sendLocalText(source, "[English] Gabrielle McCoy says: I'm sorry but are you the owner of this vehicle on papers?", 255, 255, 255, 10)
	end
end
addEvent("platePedTalk", true)
addEventHandler("platePedTalk", getRootElement(), pedTalk)

function setNewInfo(data, car)
	if not (data) or not (car) then
		outputChatBox("Internal Error", client, 255,0,0)
		return false
	end

	local tvehicle = exports.pool:getElement("vehicle", car)
	if not exports.vehicle:hasVehiclePlates(tvehicle) then
		triggerEvent("platePedTalk", client, 7)
		return false
	end
	if getElementData(client, "dbid") ~= getElementData(tvehicle, "owner") then
		triggerEvent("platePedTalk", client, 8)
		return false
	end

	local cquery = mysql:query_fetch_assoc("SELECT COUNT(*) as no FROM `vehicles` WHERE `plate`='".. mysql:escape_string(data).."'")
	if (tonumber(cquery["no"]) > 0) then
		triggerEvent("platePedTalk", client, 6)
		return false
	end

	local perk = exports.donators:getPerks(23)
	if exports.donators:takeGC(client, perk[2]) then
		exports.donators:addPurchaseHistory(client, perk[1].. " (Plate: '"..data.."' for '"..exports.global:getVehicleName(tvehicle).."')", -perk[2])
		mysql:query_free("UPDATE `vehicles` SET `plate`='" .. mysql:escape_string(data) .. "' WHERE `id` = '" .. mysql:escape_string(car) .. "'")
		exports.anticheat:changeProtectedElementDataEx(tvehicle, "plate", data, true)
		setVehiclePlateText(tvehicle, data )
		triggerEvent("platePedTalk", client, 5)
		return true
	else
		triggerEvent("platePedTalk", client, 2)
		return false
	end
end
addEvent("sNewPlates", true)
addEventHandler("sNewPlates", getRootElement(), setNewInfo)

function setNewReg(car)
	if not (car) then
		return false
	end

	local tvehicle = exports.pool:getElement("vehicle", car)
	if getElementData(source, "dbid") ~= getElementData(tvehicle, "owner") and not exports.factions:hasMemberPermissionTo(source, getElementData(tvehicle, "faction"), "respawn_vehs") then
		triggerEvent("platePedTalk", source, 8)
		return false
	end

	if not exports.vehicle:hasVehiclePlates(tvehicle) and getElementData(tvehicle, "registered") == 0 then -- Attempting to register a vehicle with no plates
		triggerEvent("platePedTalk", source, 7)
		return false
	end

	if getElementData(tvehicle, "registered") == 0 then
		data = 1
	else
		data = 0
	end

	if not exports.global:takeMoney(source, data == 1 and 175 or 50) then
		exports.global:sendLocalText(source, "[English] Gabrielle McCoy says: Could I have $"..(data == 1 and 175 or 50).." please?", 255, 255, 255, 10)
	end
 
	exports.anticheat:changeProtectedElementDataEx(tvehicle, "registered", data, true)
	dbExec(exports.mysql:getConn('mta'), "UPDATE `vehicles` SET registered= ? WHERE id = ?", data, car)
	dbExec(exports.mysql:getConn('mta'), "INSERT INTO `mdc_dmv` SET `char`=?, `vehicle`=?, `status`=? ", getElementData(source, "dbid"), car, data)
	exports.logs:dbLog( source, 6, { source, car }, "VEHICLE REGISTERATION SET TO ".. data )

	triggerEvent("platePedTalk", source, 5)
end
addEvent("sNewReg", true)
addEventHandler("sNewReg", getRootElement(), setNewReg)

function givePaperToSellVehicle(thePlayer)
	source = thePlayer
	exports.global:takeMoney(thePlayer, 100)
	exports.global:giveItem(thePlayer, 173, 1)
end
addEvent("givePaperToSellVehicle", true)
addEventHandler("givePaperToSellVehicle", getResourceRootElement(), givePaperToSellVehicle)

function grabTax(vin)
	local tax = getElementData(exports.pool:getElement("vehicle", tonumber(vin)), "carshop:taxcost")
	triggerClientEvent(client, "plate:updateTaxLabel", client, tax)
end
addEvent("plate:grabTax", true)
addEventHandler("plate:grabTax", resourceRoot, grabTax)