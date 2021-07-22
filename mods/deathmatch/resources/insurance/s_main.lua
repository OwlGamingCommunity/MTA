local mysql = exports.mysql

local datatable = { } -- key: vehicleID
local factionstable = { } -- key: factionID

function updateClientCache(updateTo, newTalbes)
	triggerClientEvent(updateTo, "insurance:updateClientCache", updateTo, newTalbes)
end

addEventHandler("onResourceStart", resourceRoot,
	function()
		local result = mysql:query( "SELECT `factionID`, `name`, `gen_maxi`, `news`, `subscription` FROM `insurance_factions`" )
		while result do
			local row = mysql:fetch_assoc( result )
			if not row then
				break
			end
			factionstable[tonumber(row.factionID)] = row
		end
		mysql:free_result( result )

		local result = mysql:query( "SELECT * FROM `insurance_data`" )
		while result do
			local row = mysql:fetch_assoc( result )
			if not row then
				break
			end
			datatable[tonumber(row.vehicleid)] = row
		end
		mysql:free_result( result )

		setTimer( sqlSaveDatatable, 18000000, 0) -- every 5 hours

	end)

function getVehicleInsuranceData(vin) --exported function to get insurance data on a vehicle. False if vehicle is not insured. /Exciter
	if tonumber(vin) then
		vin = tonumber(vin)
		if datatable[vin] then
			local data = datatable[vin]
			local insuredByName = factionstable[tonumber(data.insurancefaction)].name or ""
			data["insurancecompanyname"] = insuredByName
			return data
		end
	end
	return false
end

function openGUI(thePlayer)
	local faction = exports.factions:getCurrentFactionDuty(thePlayer)
	--outputDebugString("insurance/s_main: openGUI f="..tostring(faction).." t="..tostring(factionstable))
	--outputDebugString(tostring(factionstable[faction]))
	if faction and factionstable[faction] then
		updateClientCache(thePlayer, {datatable, factionstable})
		triggerClientEvent(thePlayer, "insurance:mainGUI", resourceRoot, factionstable[faction]) -- ya , but this function can bring with it the tables to client too
	end
end
addCommandHandler("insurance", openGUI)

function doSqlStuff(sqlType, factionID, newdata)
	factionID = tonumber(factionID)
	if not tonumber(factionID) then return false end
	mysql:query_free("UPDATE `insurance_factions` SET `"..sqlType.."`='"..mysql:escape_string(newdata).."' WHERE `factionID`="..factionID)
	factionstable[factionID][sqlType] = newdata
	updateClientCache(source, {datatable, factionstable}) -- source here is the player that triggered this event.
end
addEvent("insurance:sql", true)
addEventHandler("insurance:sql", resourceRoot, doSqlStuff)

function calculatePremium(carshopPrice, maxigen, change)
	if not carshopPrice then return false end
	carshopPrice = tonumber(carshopPrice)

	local basePrice = carshopPrice * tonumber(maxigen)

	if tonumber(change) then
		local advancedPrice = basePrice * change
		return math.ceil(advancedPrice)
	else
		return math.ceil(basePrice)
	end
end

function getVehicleData(id)
	if not id then return false end
	local theVehicle = exports.pool:getElement("vehicle", tonumber(id))
	if not theVehicle then return false end

	if theVehicle then -- if vehicle element is found
		local plate = getElementData(theVehicle, "plate") or "false_plate"
		local owner = getElementData(theVehicle, "owner")
		local ownerName = exports['cache']:getCharacterName(owner, true) or "REF. SUP."
		local brand = getElementData(theVehicle, "brand") or "false_brand"
		local model = getElementData(theVehicle, "maximemodel") or "false_model"
		local year = getElementData(theVehicle, "year") or "false_year"
		local carshopPrice = getElementData(theVehicle, "carshop:cost") or 0

		return tonumber(carshopPrice), brand, model, year, ownerName, plate
	end
end

function sellInfo(id)
	local price, brand, model, year, owner, plate = getVehicleData(id)

	if brand and model and year and owner then
		triggerClientEvent("insurance:clientrecieve:sell", source, owner, year, brand, model)
	end
end
addEvent("insurance:sellinfo", true)
addEventHandler("insurance:sellinfo", root, sellInfo)

function calculateFromClient(id, factionID, charge)
	if not id then return false end
	id = tonumber(id)

	local price, brand, model, year, name, plate = getVehicleData(id)
	if not price then return false end

	if tonumber(charge) then
		local estimatedpremium = calculatePremium(price, factionstable[factionID]["gen_maxi"])
		local premium = calculatePremium(price, factionstable[factionID]["gen_maxi"], charge)
		triggerClientEvent("insurance:clientrecieve", source, name, year, brand, model, plate, price, estimatedpremium, premium)
	else
		local estimatedpremium = calculatePremium(price, factionstable[factionID]["gen_maxi"])
		triggerClientEvent("insurance:clientrecieve", source, name, year, brand, model, plate, price, estimatedpremium)
	end
end
addEvent("insurance:calculate", true)
addEventHandler("insurance:calculate", root, calculateFromClient)

function sellPremium(customerId, price, vehicle, protection)
	local salesman = source
	--let's try a safe way. / thinking of another way to make this cuz it's calling out and calling back too many times. kinda lost.

	--local customer = exports.pool:getElement("player", customerId) -- yeah it think it does
	local customer = customerId
	if isElement(salesman) and isElement(customer) and tonumber(price) and tonumber(vehicle) and protection then
		if tonumber(price) < 0 or tonumber(price) > 50000 then return false end
		price = math.ceil(tonumber(price))

		local theVehicle = exports.pool:getElement("vehicle", tonumber(vehicle))
		if not theVehicle then return false end

		local carshop, brand, model, year, ownerName, plate = getVehicleData(tonumber(vehicle))
		local formatText = year.." "..brand.." "..model
		--LOL I'm lost in your script. ya / I don't even understand how your system works. /like i don't know how insurance works
		triggerClientEvent(customer, "insurance:confirmgui", root, tostring(price), formatText, salesman, vehicle, protection)
	end -- not sure, i'm lost
end
addEvent("insurance:sell", true)
addEventHandler("insurance:sell", root, sellPremium) -- yeah so source can be player

function clientSideOutputChatBox(element, string)
	if isElement(element) then
		outputChatBox(string, element)
	end
end
addEvent("insurance:outputchatbox", true)
addEventHandler("insurance:outputchatbox", resourceRoot, clientSideOutputChatBox)

function finalizePurchase(salesman, customer, carid, protection, premium, factionid)
	if isElement(customer) and carid and protection and premium and factionid then
		local theVehicle = exports.pool:getElement("vehicle", tonumber(carid))
		if theVehicle then
			carid = tonumber(carid)
			exports.anticheat:setEld(theVehicle, "insurance:fee", tonumber(premium))
			exports.anticheat:setEld(theVehicle, "insurance:faction", tonumber(factionid))
			local realTime = getRealTime()
			local date = string.format("%04d/%02d/%02d", realTime.year + 1900, realTime.month + 1, realTime.monthday )
			local q = exports.mysql:query("INSERT INTO `insurance_data` (`customername`, `vehicleid`, `protection`, `deductible`, `date`, `claims`, `cashout`, `premium`, `insurancefaction`) VALUES ('"..string.gsub(getPlayerName(customer), "_", " ").."', '"..exports.mysql:escape_string(tonumber(carid)).."', '"..exports.mysql:escape_string(protection).."', '0', '"..date.."', '0', '0', '"..exports.mysql:escape_string(tonumber(premium)).."', '"..exports.mysql:escape_string(tonumber(factionid)).."')")
			local newid = mysql:insert_id( )
			mysql:free_result(q)

			datatable[carid] = {}
			datatable[carid]["policyid"] = newid
			datatable[carid]["customername"] = string.gsub(getPlayerName(customer), "_", " ")
			datatable[carid]["vehicleid"] = tonumber(carid)
			datatable[carid]["protection"] = protection
			datatable[carid]["deductible"] = 0
			datatable[carid]["date"] = date
			datatable[carid]["claims"] = 0
			datatable[carid]["cashout"] = 0
			datatable[carid]["premium"] = tonumber(premium)
			datatable[carid]["insurancefaction"] = tonumber(factionid)

			outputChatBox("You have accepted the insurance plan. It is valid as of now. To cancel, please contact the company.", customer)
			outputChatBox("The customer has accepted the insurance plan.", salesman) --sec didn't actually fix anything.

			updateClientCache(salesman, {datatable, factionstable}) -- Why don't you put those outputchatbox here, so it can notify actualy result.
		end
	end
end
addEvent("insurance:finalpurchase", true)
addEventHandler("insurance:finalpurchase", root, finalizePurchase)

function cancelPolicy(vehicleID, thePlayer) -- why don't you put it a localplayer, but resourceroot, cuz clearly localplayer is the one that clicked the GUI
	if vehicleID then
		if not client then client = thePlayer end
		vehicleID = tonumber(vehicleID)
		if datatable[vehicleID] then --check if this vehicle is insured
			if tonumber(datatable[vehicleID]["vehicleid"]) == vehicleID then
				local policyid = datatable[vehicleID]["policyid"]
				--local success = exports.mysql:query_free("UPDATE `owl_mta`.`vehicles` SET `insurancefee`='0', `insurancefaction`='0' WHERE `id`='"..exports.mysql:escape_string(tonumber(vehicleID)).."'")
				local success = true
				local success2 = exports.mysql:query_free("DELETE FROM `insurance_data` WHERE `policyid`='"..exports.mysql:escape_string(policyid).."'")
				local theVehicle = exports.pool:getElement("vehicle", tonumber(vehicleID))
				local success3 = false
				if theVehicle then
					exports.anticheat:setEld(theVehicle, "insurance:fee", 0)
					exports.anticheat:setEld(theVehicle, "insurance:faction", 0)
					success3 = true
				end
				datatable[vehicleID] = nil
				updateClientCache(source, {datatable, factionstable})

				--outputChatBox("SYSTEM... [database2]="..tostring(success2).." | [policy number]="..tostring(success3), client)
				if success and success2 and success3 and client then
					outputChatBox("Insurance policy #"..policyid.." has been cancelled.", client)
					return true
				end
			end
		end
	end
	return false
end
addEvent("insurance:cancel", true)
addEventHandler("insurance:cancel", root, cancelPolicy)

--[[

CREATE TABLE `owl_mta`.`insurance_factions` (
  `factionID` INT NOT NULL,
  `name` VARCHAR(45) NOT NULL,
  `gen_maxi` FLOAT NOT NULL DEFAULT 0.005,
  `news` TEXT NULL,
  `subscription` TEXT NULL,
  `totalincome` FLOAT NULL,
  `totalclaims` FLOAT NULL,
  PRIMARY KEY (`factionID`));

ALTER TABLE `owl_mta`.`vehicles`
ADD COLUMN `insurancefee` INT(10) NOT NULL DEFAULT '0' AFTER `business`,
ADD COLUMN `insurancefaction` INT(10) NOT NULL DEFAULT '0' AFTER `insurancefee`;

CREATE TABLE `owl_mta`.`insurance_data` (
  `policyid` INT NOT NULL AUTO_INCREMENT,
  `customername` VARCHAR(45) NOT NULL,
  `vehicleid` INT NOT NULL,
  `protection` VARCHAR(45) NOT NULL,
  `deductible` INT NOT NULL,
  `date` DATE NOT NULL,
  `claims` FLOAT NOT NULL,
  `cashout` FLOAT NOT NULL,
  `premium` INT NOT NULL,
  PRIMARY KEY (`policyid`));


ALTER TABLE `owl_mta`.`insurance_factions`
DROP COLUMN `totalclaims`,
DROP COLUMN `totalincome`;


  ***** TO DO ******
	payday: display as text

]]
local function formatVehIds(table) --converts vehicle ids table into a text string for bank transaction logs.
	local ids = ""
	for i, vehid in pairs(table) do
	ids = ids..ids..", "
	end
	return string.sub(ids, 1, string.len(ids)-2) -- remove 2 last characters from string ", "
end

function analyzeInsurance(data, playerId) -- edit in payday resource to pass playerId here too
	local totalFee = 0
	local totalFeePerVehicles = {}
	local totalFeePerFactions = {}
	if data then
		for vehid, insurance in pairs(data) do
			for iFaction, fee in pairs(insurance) do
				--Create data based on vehicle id
				if not totalFeePerVehicles[vehid] then totalFeePerVehicles[vehid] = {} end
				if not totalFeePerVehicles[vehid]['ifaction'] then totalFeePerVehicles[vehid]['ifaction'] = iFaction end
				if not totalFeePerVehicles[vehid]['fee'] then totalFeePerVehicles[vehid]['fee'] = 0 end
				totalFeePerVehicles[vehid]['fee'] = totalFeePerVehicles[vehid]['fee'] + fee
				if not datatable[vehid]['cashout'] then
	 				datatable[vehid]['cashout'] = 0
				end
				datatable[vehid]['cashout'] = datatable[vehid]['cashout'] + fee

				--Create data based on insurance faction id
				if not totalFeePerFactions[iFaction] then totalFeePerFactions[iFaction] = {} end
				if not totalFeePerFactions[iFaction]['fee'] then totalFeePerFactions[iFaction]['fee'] = 0 end
				if not totalFeePerFactions[iFaction]['vehs'] then totalFeePerFactions[iFaction]['vehs'] = {} end
				totalFeePerFactions[iFaction]['fee'] = totalFeePerFactions[iFaction]['fee'] + fee
				table.insert(totalFeePerFactions[iFaction]['vehs'], vehid)

				--Create total fee on all vehicles from all insurance faction ids of the player
				totalFee = totalFee + fee
			end
		end
	end

	return totalFee, totalFeePerVehicles, totalFeePerFactions
end

--[[Return values for the above function / MAXIME
1. totalFee : Total insurance fees on all vehicles of the player
2. totalFeePerVehicles : A list of vehicles from a player
- index : vehicle id
- values : A list with 2 elements
 	.ifaction : insurance faction id the vehicle registered to
 	.fee : fee for the vehicle
3. totalFeePerFactions : A list of insurance factions
- index : faction id
- values : A list of 2 elements
	. fee : total fee the faction gets from all vehicles of the player
	. vehs : a list of veh ids that the insurance faction takes fees from
]]

function paynsprayClaims(vehicleid, amount) -- this is triggered everytime an insured vehicle goes into the paynspray
	if not vehicleid or not amount then return false end
	amount = tonumber(amount)
	vehicleid = tonumber(vehicleid)

	if datatable[vehicleid] then
		local newClaimsTotal = tonumber(datatable[vehicleid]["claims"]) + amount
		datatable[vehicleid]["claims"] = newClaimsTotal
		local r = mysql:query_free("UPDATE `insurance_data` SET `claims`="..mysql:escape_string(newClaimsTotal).." WHERE `vehicleid`="..vehicleid)

		updateClientCache(source, {datatable, factionstable})
	end
end
addEvent("insurance:claims", true)
addEventHandler("insurance:claims", root, paynsprayClaims)

function sqlSaveDatatable() -- this is triggered when resource stops and every 5 hours
	outputDebugString("Saving insurance data.")
	for k, v in pairs(datatable) do
		local r = mysql:query_free("UPDATE `insurance_data` SET `claims`="..v['claims']..", `cashout`="..v['cashout'].." WHERE `vehicleid`="..k)
		if not r then
			outputDebugString( "ERROR: [insurance] "..path.." - FAILED TO SAVE SQL DATA")
		end
	end
end
addEventHandler("onResourceStop", resourceRoot, sqlSaveDatatable)
