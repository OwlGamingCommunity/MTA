-- reverse carshop
local BICYCLES = {[481] = true, [510] = true, [509] = true}
local cOutsideCol = createColCuboid(2185.671875, -1983.1474609375, 13, 15.5, 15.5, 6)
setElementID(cOutsideCol, 'crusher')
createBlip(2185.671875, -1983.1474609375, 13, 11, 2, 255, 0, 0, 255, 0, 300) -- Crusher

local cOutsideColBoat =  createColCuboid ( 2228.6396484375, -2771.1708984375, -1.4731507301331, 29, 60, 9 )
setElementID(cOutsideColBoat, 'boat_crusher')
createBlip(2245.259765625, -2746.1962890625, 3.6514446735382, 11, 2, 255, 0, 0, 255, 0, 300) -- Boat Crusher

function resetPrice(theVehicle, matching)
	if isElement(theVehicle) and getElementType(theVehicle) == "vehicle" then
		if getElementData(theVehicle, "crushing") then
			exports.anticheat:changeProtectedElementDataEx(theVehicle, "crushing")

			local thePlayer = getVehicleOccupant(theVehicle)
			if thePlayer then
				outputChatBox("Come back when you've thought about it!", thePlayer, 255, 194, 14)
				triggerClientEvent(thePlayer, 'crusher:hide', thePlayer)
			end
		end
	end
end
addEventHandler( "onColShapeLeave", cOutsideCol, resetPrice)
addEventHandler( "onColShapeLeave", cOutsideColBoat, resetPrice)
--

local function isBicycle(model)
	return BICYCLES[model] or false
end

function getVehiclePriceFromTable(vehicle)
	local mass = getModelHandling(vehicle.model).mass

	if vehicle.tokenUsed or not mass then
		return 0
	end

	if isBicycle(vehicle.model) then
		return 50
	end

	local massBasedValue = math.floor(mass * 3)
	if vehicle.price and massBasedValue >= vehicle.price then
		return vehicle.price / 2
	end

	return massBasedValue
end


function getVehiclePrice(theVehicle)
	return getVehiclePriceFromTable({
		model = getElementModel(theVehicle),
		tokenUsed = getElementData(theVehicle, "token"),
		price = tonumber(getElementData(theVehicle, "carshop:cost"))
	})
end

function showMoreInformation(thePlayer, matching, theVehicle)
	if isElement(thePlayer) and matching and getElementType(thePlayer) == "player" then
		local theVehicle = getPedOccupiedVehicle(thePlayer)
		if theVehicle and getVehicleOccupant(theVehicle) == thePlayer then -- player is driver
			if getElementData(theVehicle, "owner") == getElementData(thePlayer, "dbid") then
				local price = getVehiclePrice(theVehicle)
				if getElementData(theVehicle, "requires.vehpos") then
					outputChatBox("(( Please park your vehicle and come back. ))", thePlayer, 255, 0, 0)
				elseif price == 0 and not getElementData(theVehicle, "token") then
					outputChatBox("This " .. exports.global:getVehicleName(theVehicle) .. " ain't worth anything.", thePlayer, 255, 0, 0 )
					outputChatBox("(( Contact an admin to sell your special vehicle. ))", thePlayer, 255, 194, 14)
				elseif getVehicleType(theVehicle) == "Trailer" then
					outputChatBox("This " .. exports.global:getVehicleName(theVehicle) .. " cannot be crushed.", thePlayer, 255, 0, 0 )
					outputChatBox("(( Contact an admin to sell your special vehicle. ))", thePlayer, 255, 194, 14)
				else
					setElementData(theVehicle, "crushing", price, false)
					triggerClientEvent(thePlayer, 'crusher:show', theVehicle, price)
				end
			else
				outputChatBox("Got the Registration for that? Sorry, Bro', can't touch it then.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addEventHandler( "onColShapeHit", cOutsideCol, showMoreInformation)
addEventHandler( "onColShapeHit", cOutsideColBoat, showMoreInformation)

function crushCar()
	local thePlayer = client
	local theVehicle = source
	if theVehicle and thePlayer then
		if getElementData( theVehicle, "owner" ) == getElementData( thePlayer, "dbid" ) then
			local price = getElementData(theVehicle, "crushing")
			local dbid = tonumber( getElementData( theVehicle, "dbid" ) )
			if price and price >= 0 and dbid > 0 then
				dbExec( exports.mysql:getConn('mta'), "UPDATE `vehicles` SET deleted=1 WHERE id=? ", dbid )
				triggerClientEvent( thePlayer, 'crusher:hide', thePlayer )

				exports.global:giveMoney( thePlayer, price )
				exports['item-system']:deleteAll( 3, dbid )
				exports['item-system']:clearItems( theVehicle )
				exports['global']:takeItem( thePlayer, 3, dbid )

				-- notify
				outputChatBox("You crushed your " .. exports.global:getVehicleName(theVehicle) .. " for $" .. exports.global:formatMoney(price) .. ".", thePlayer, 0, 255, 0)
				exports.global:sendMessageToAdmins("[VEHICLE] Removing vehicle #" .. dbid .. " (Crushed by " .. getPlayerName(thePlayer):gsub("_", " ") .. ").")

				-- logs
				exports.vehicle_manager:addVehicleLogs( dbid, 'crushed', thePlayer )
				exports.logs:dbLog( thePlayer, 6, { thePlayer, theVehicle }, "CRUSHERDELETED ".. price )

				-- meh
				for _, p in pairs( getVehicleOccupants( theVehicle ) ) do
					exports.anticheat:setEld( p, "realinvehicle", 0 )
				end

				destroyElement( theVehicle )
			end
		end
	end
end
addEvent( 'crusher:delete', true )
addEventHandler('crusher:delete', root, crushCar)
