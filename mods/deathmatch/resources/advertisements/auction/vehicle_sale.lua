local function takeExistingOwnersKey(vehicleId)
    exports['item-system']:deleteAll(3, vehicleId)
end

local function changeVehicleOwnershipData(vehicle, buyerId)
	local vehicleId = vehicle:getData("dbid")

    exports.mysql:getConn('mta'):exec(
		"UPDATE vehicles SET faction = -1, owner = ?, tokenUsed = 0, lastUsed = NOW() WHERE id = ?", buyerId, vehicleId
	)

	exports.anticheat:changeProtectedElementDataEx(vehicle, "faction", -1, true)
	exports.anticheat:changeProtectedElementDataEx(vehicle, "owner", buyerId, true)
	exports.anticheat:changeProtectedElementDataEx(vehicle, "owner_last_login", exports.datetime:now(), true)
	exports.anticheat:changeProtectedElementDataEx(vehicle, "lastused", exports.datetime:now(), true)
end

local function removeVehicleInsurance(vehicleId)
    exports.mysql:getConn('mta'):exec("DELETE FROM insurance_data WHERE vehicleid = ?", vehicleId)
end

local function logSale(vehicle, buyerId, auction)
	local vehicleId = vehicle:getData("dbid")
    local buyerName = exports.cache:getCharacterNameFromID(buyerId)

    local sellerName = nil
    if not auction.created_by_faction then
        sellerName = exports.cache:getCharacterNameFromID(auction.created_by)
    else
        sellerName = exports.cache:getFactionNameFromId(auction.created_by_faction)
    end

    exports.mysql:getConn('mta'):exec(
        "INSERT INTO vehicle_logs (vehID, `action`, `actor`) VALUES (?, ?, ?)",
        vehicleId,
        "Auctioned to " .. buyerName,
        getAccountIdFromCharacter(auction.created_by)
    )

    local actor = nil
    if not auction.created_by_faction then
        actor = "ch" .. auction.created_by
    else
        actor = "fa" .. auction.created_by_faction
    end

	exports.logs:dbLog(
        actor,
        6,
        {vehicle, actor, "ch" .. buyerId},
        "AUCTION '".. getVehicleName(vehicle).."' '".. sellerName .."' => '".. buyerName .."'"
    )
end

function sellAuctionVehicle(buyerId, vehicle, auction)
    local vehicleId = vehicle:getData("dbid")

    changeVehicleOwnershipData(vehicle, buyerId)
    takeExistingOwnersKey(vehicleId)
    removeVehicleInsurance(vehicleId)
    logSale(vehicle, buyerId, auction)
end