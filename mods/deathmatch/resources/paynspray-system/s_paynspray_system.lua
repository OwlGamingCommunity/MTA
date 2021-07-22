ARMORED_CARS = { [427]=true, [528]=true, [432]=true, [601]=true, [428]=true } -- Enforcer, FBI Truck, Rhino, SWAT Tank, Securicar
GOVERNMENT_VEHICLE = { [416]=true, [427]=true, [490]=true, [528]=true, [407]=true, [544]=true, [523]=true, [596]=true, [597]=true, [598]=true, [599]=true, [601]=true, [428]=true }
PAYING_FACTIONS = { [1]=true, [2]=true, [3]=true, [4]=true, [5]=true, [47]=true, [59]=true, [50]=true, [164]=true}
RECEIVING_FACTION = 4

function createSpray(thePlayer, commandName)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		local x, y, z = getElementPosition(thePlayer)
		local interior = getElementInterior(thePlayer)
		local dimension = getElementDimension(thePlayer)
		
		dbQuery(
			function(qh)
				local _, _, insertId = dbPoll(qh, 0)
				local shape = createColSphere(x, y, z, 5)
				exports.pool:allocateElement(shape)
				setElementInterior(shape, interior)
				setElementDimension(shape, dimension)
				exports.anticheat:changeProtectedElementDataEx(shape, "dbid", insertId, false)
		
				local sprayblip = createBlip(x, y, z, 63, 2, 255, 0, 0, 255, 0, 300)
				exports.anticheat:changeProtectedElementDataEx(sprayblip, "dbid", insertId, false)
				exports.pool:allocateElement(sprayblip)
		
				outputChatBox("Pay 'N Spray spawned with ID #" .. insertId .. ".", thePlayer, 0, 255, 0)
			end,
		exports.mysql:getConn("mta"), "INSERT INTO paynspray SET x=?, y=?, z=?, interior=?, dimension=?", x, y, z, interior, dimension)

	end
end
addCommandHandler("makepaynspray", createSpray, false, false)

function loadAllSprays(res)
	-- Set Garages Open
	setGarageOpen(8, true)
	setGarageOpen(11, true)
	setGarageOpen(12, true)
	setGarageOpen(19, true) -- Wangs
	setGarageOpen(27, true) -- Juniper Hollow

	dbQuery(
		function(qh)
			local result = dbPoll(qh, 0)
			for _, row in ipairs(result) do 
				local id = tonumber(row["id"])
				local x = tonumber(row["x"])
				local y = tonumber(row["y"])
				local z = tonumber(row["z"])
		
				local interior = tonumber(row["interior"])
				local dimension = tonumber(row["dimension"])
		
				local sprayblip = createBlip(x, y, z, 63, 2, 255, 0, 0, 255, 0, 300)
				exports.anticheat:changeProtectedElementDataEx(sprayblip, "dbid", id, false)
				exports.pool:allocateElement(sprayblip)
		
				local shape = createColSphere(x, y, z, 5)
				exports.pool:allocateElement(shape)
				setElementInterior(shape, interior)
				setElementDimension(shape, dimension)
				exports.anticheat:changeProtectedElementDataEx(shape, "dbid", id, false)		
			end
		end, 
	exports.mysql:getConn("mta"), "SELECT id, x, y, z, interior, dimension FROM paynspray")
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllSprays)

function getNearbySprays(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Nearby Pay 'N Sprays:", thePlayer, 255, 126, 0)
		local count = 0

		for k, theColshape in ipairs(getElementsByType("colshape", getResourceRootElement())) do
			local x, y = getElementPosition(theColshape)
			local distance = getDistanceBetweenPoints2D(posX, posY, x, y)
			if (distance<=10) then
				local dbid = getElementData(theColshape, "dbid")
				outputChatBox("   Pay 'N Spray with ID " .. dbid .. ".", thePlayer, 255, 126, 0)
				count = count + 1
			end
		end

		if (count==0) then
			outputChatBox("   None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("nearbypaynsprays", getNearbySprays, false, false)

function delSpray(thePlayer, commandName)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		local colShape = nil

		for key, value in ipairs(getElementsByType("colshape", getResourceRootElement())) do
			if (isElementWithinColShape(thePlayer, value)) then
				colShape = value
			end
		end

		if (colShape) then
			local id = getElementData(colShape, "dbid")
			dbExec(exports.mysql:getConn("mta"), "DELETE FROM paynspray WHERE id=?", id)

			outputChatBox("Pay 'N Spray #" .. id .. " deleted.", thePlayer)
			destroyElement(colShape)

			for key, value in ipairs(getElementsByType("blip", getResourceRootElement())) do
				if getElementData(value, "dbid") == id then
					destroyElement(value)
				end
			end
		else
			outputChatBox("You are not in a Pay 'N Spray.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("delpaynspray", delSpray, false, false)

function doesPayForRepair(factionT)
	for k,v in pairs(factionT) do
		if PAYING_FACTIONS[k] then
			return k
		end
	end
	return
end

function shapeHit(element, matchingDimension)
	if (isElement(element)) and (getElementType(element)=="vehicle") and (matchingDimension) then
		local thePlayer = getVehicleOccupant(element)

		if (thePlayer) then
			local factionPlayer = getElementData(thePlayer, "faction")
			local factionVehicle = getElementData(element, "faction")

			local vehicleHealth = getElementHealth(element)

			if (vehicleHealth >= 1000) then
				outputChatBox("Welcome to the repair garage. Your " .. exports.global:getVehicleName(element) .. " is fine. If you have any problems with it in the future, come back!", thePlayer, 255, 194, 14)
			else
				local playerMoney = exports.global:getMoney(thePlayer, true)
				if playerMoney == 0 and not factionPlayer[factionVehicle] and not doesPayForRepair(factionPlayer) and not PAYING_FACTIONS[factionVehicle] then
					outputChatBox("You cannot afford to have your car worked on, sorry.", thePlayer, 255, 0, 0)
				else
					outputChatBox("Welcome to the repair garage. Please wait while we evaluate your " .. exports.global:getVehicleName(element) .. ".", thePlayer, 255, 194, 14)
					setTimer(sprayEffect, 2500, 1, element, thePlayer, source)
					setTimer(spraySoundEffect, 2000, 5, thePlayer, source)
				end
			end
		end
	end
end
addEventHandler("onColShapeHit", getResourceRootElement(), shapeHit)

function spraySoundEffect(thePlayer, shape)
	if (isElementWithinColShape(thePlayer, shape)) then
		playSoundFrontEnd(thePlayer, 46)
	end
end

local costDamageRatio = 1.25

function sprayEffect(vehicle, thePlayer, shape)
	if (isElementWithinColShape(thePlayer, shape)) then
		local completefix = false
		local vehicleHealth = getElementHealth(vehicle)
		local toFix = 0

		local damage = 1000 - vehicleHealth
		damage = math.floor(damage)
		local estimatedCosts = math.floor(damage * costDamageRatio)

		local factionPlayer = getElementData(thePlayer, "faction")
		local factionVehicle = getElementData(vehicle, "faction")
		if not factionPlayer[factionVehicle] or not doesPayForRepair(factionPlayer) or not PAYING_FACTIONS[factionVehicle] then
			completefix = false
			local playerMoney = exports.global:getMoney(thePlayer, true)
			estimatedCosts =  math.floor ( toFix * costDamageRatio )

			if getElementData(vehicle, "dbid") > 0 then
				local vehicleCarshopPrice = tonumber(getElementData(vehicle, "carshop:cost") or 30000)
				--outputDebugString(vehicleCarshopPrice)
				estimatedCosts = math.floor ( ( vehicleCarshopPrice / 25 ) * ( damage / 1000 ) )
			else
				outputChatBox("OOC: (( This is a temporary vehicle. Repair is free. ))", thePlayer, 255, 194, 14)
				estimatedCosts = 0
			end

			--insurance, anumaz 2015-02-04
			local insured = getElementData(vehicle, "insurance:faction") or 0
			if insured > 0 then
				local insurerElement = exports.pool:getElement("team", insured)
				exports.global:takeMoney(insurerElement, estimatedCosts, true)
				outputChatBox("BILL: Your insurance company has been sent a bill of $".. exports.global:formatMoney(estimatedCosts) ..", please wait while we repair your vehicle.", thePlayer, 0, 255, 0)
				triggerEvent("insurance:claims", root, getElementData(vehicle, "dbid"), estimatedCosts)
				completefix = true
				setElementFrozen(vehicle, true)
				
				local rapidTowingElement = exports.pool:getElement("team", RECEIVING_FACTION)
				exports.global:giveMoney(rapidTowingElement, estimatedCosts, true) -- to Rapid towing
				
				--bank transaction log
				local vin = getElementData(vehicle, "dbid")
				dbExec(exports.mysql:getConn("mta"), "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (?, ?, ?, 'Insurance claim (?)', 14)", -getElementData(insurerElement, "id"), -getElementData(rapidTowingElement, "id"), estimatedCosts, vin)
			else
				triggerClientEvent(thePlayer, "paynspray:Invoice", thePlayer, estimatedCosts)
				setElementData(thePlayer, "paynspray:bill", estimatedCosts, true)
				completefix = false
			end
			-- end of insurance
		else
			local theTeam = exports.factions:getFactionFromID(factionVehicle)
			if exports.global:takeMoney(theTeam, estimatedCosts, true) then
				completefix = true
				setElementFrozen(vehicle, true)
				outputChatBox("The bill will be sent to your employer, please wait while we repair.", thePlayer, 0, 255, 0)
				dbExec(exports.mysql:getConn("mta"), "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (?,?,?,?,?)", -getElementData(theTeam, "id"), -getElementData(exports.pool:getElement("team", RECEIVING_FACTION), "id"), estimatedCosts, 'Repair', 10)
			end
		end

		--[[exports.global:giveMoney(getTeamFromName("326 Enterprises"), estimatedCosts)]]

		if (completefix) then
			setTimer(function()
				fixVehicle(vehicle)
				for i = 0, 5 do
					setVehicleDoorState(vehicle, i, 0)
				end
				outputChatBox("Your vehicle is now repaired!", thePlayer, 0, 255, 0)
				setElementFrozen(vehicle, false)
			end, 5000, 1)
		end

		if ARMORED_CARS[ getElementModel( vehicle ) ] or getElementData(vehicle, "bulletproof") == 1 then
			setVehicleDamageProof(vehicle, true)
		else
			setVehicleDamageProof(vehicle, false)
		end
		if (getElementData(vehicle, "Impounded") == 0) then
			exports.anticheat:changeProtectedElementDataEx(vehicle, "enginebroke", 0, false)
		end

		exports.logs:dbLog(thePlayer, 6, {  vehicle }, "REPAIR PAYNSPRAY")
	else
		outputChatBox("You forgot to wait for your repair!", thePlayer, 255, 0, 0)
	end
end

function pnsOnEnter(player, seat)
	if seat == 0 then
		for k, v in ipairs(getElementsByType("colshape", getResourceRootElement())) do
			if isElementWithinColShape(source, v) then
				triggerEvent( "onColShapeHit", v, source, getElementDimension(v) == getElementDimension(source))
			end
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), pnsOnEnter)

function acceptedInvoice(paymentType)
	if client and client ~= source then return false end
	local vehicle = getPedOccupiedVehicle(client)
	local faction = exports.factions:getFactionFromID(RECEIVING_FACTION)

	if paymentType == PAY_BY_CARD then 
		if not exports.bank:takeBankMoney(client, getElementData(client, "paynspray:bill")) then return outputChatBox("You do not have enough bank funds to pay for the repair.", client, 255, 100, 100) end
		exports.bank:addBankTransactionLog(getElementData(client, 'dbid'), -RECEIVING_FACTION, getElementData(client, "paynspray:bill"), 10, "PAYNSPRAY")
	elseif paymentType == PAY_BY_CASH then
		if not exports.global:takeMoney(client, getElementData(client, "paynspray:bill"), true) then return outputChatBox("You do not have enough cash to pay for the repair.", client, 255, 100, 100) end
	end

	exports.global:giveMoney(faction, getElementData(client, "paynspray:bill"), true)
	outputChatBox("You've paid your invoice, please wait while we repair your car.", client, 0, 255, 0)
		
	removeElementData(client, "paynspray:bill")
	toggleControl(client, "accelerate", false)
	toggleControl(client, "brake_reverse", false)

	setTimer(function(player)
		fixVehicle(vehicle)
		for door = 0, 5 do
			setVehicleDoorState(vehicle, door, 0)
		end
		outputChatBox("Your vehicle is now repaired!", player, 0, 255, 0)
		toggleControl(player, "accelerate", true)
		toggleControl(player, "brake_reverse", true)
	end, 5000, 1, client)
end
addEvent("pns:PayInvoice", true)
addEventHandler("pns:PayInvoice", root, acceptedInvoice)
