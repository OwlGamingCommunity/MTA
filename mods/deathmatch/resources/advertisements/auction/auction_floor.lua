AUCTION_FLOOR_VEHICLE_POSITIONS = {
    {position = Vector3(1263, -1670, 13.5), rotation = Vector3(0, 0, 53), dimension = 0, interior = 0},
    {position = Vector3(1251, -1670, 12.5), rotation = Vector3(0, 0, 53), dimension = 0, interior = 0},

    {position = Vector3(1242, -1670, 11.8), rotation = Vector3(0, 0, 320), dimension = 0, interior = 0},
    {position = Vector3(1234, -1670, 11.8), rotation = Vector3(0, 0, 320), dimension = 0, interior = 0},
    {position = Vector3(1226, -1670, 11.8), rotation = Vector3(0, 0, 320), dimension = 0, interior = 0},

    {position = Vector3(1263, -1645, 13.5), rotation = Vector3(0, 0, 145), dimension = 0, interior = 0},
    {position = Vector3(1251, -1649, 12.5), rotation = Vector3(0, 0, 145), dimension = 0, interior = 0},

    {position = Vector3(1240, -1649, 11.8), rotation = Vector3(0, 0, 220), dimension = 0, interior = 0},
    {position = Vector3(1232, -1649, 11.8), rotation = Vector3(0, 0, 220), dimension = 0, interior = 0},
    {position = Vector3(1224, -1649, 11.8), rotation = Vector3(0, 0, 220), dimension = 0, interior = 0},
}

local AUCTION_FLOOR_LOCATIONS = {
    {position = Vector2(1213, -1677), size = Vector2(55, 40), dimension = 0, interior = 0}
}

local function loadAuctionFloorColShapes()
    for _, floorLocation in pairs(AUCTION_FLOOR_LOCATIONS) do
        local shape = ColShape.Rectangle(floorLocation.position, floorLocation.size)
        shape:setDimension(floorLocation.dimension)
        shape:setInterior(floorLocation.interior)
        shape:setData("auction_floor", true, true)
    end

    setTimer(function ()
        triggerClientEvent("vehicle-auction:col-shapes-created", resourceRoot)
    end, 5000, 1)
end

local function loadAuctionFloorVehicle(positionKey, auction)
    local vehicle = exports.pool:getElement("vehicle", auction.vehicle_id)
    if not vehicle then
        return
    end

    local spawn = AUCTION_FLOOR_VEHICLE_POSITIONS[positionKey]
    if not spawn then
        return
    end

    vehicle:setFrozen(false)
    vehicle:setPosition(spawn.position)
    vehicle:setRotation(spawn.rotation)
    vehicle:setDimension(spawn.dimension)
    vehicle:setInterior(spawn.interior)
    setVehicleEngineState(vehicle, false)
    vehicle:setLocked(true)
    vehicle:fix()
    vehicle:setOverrideLights(1)
    vehicle:setData('lights', 0, true)
    setTimer(setElementFrozen, 2000, 1, vehicle, true)

    vehicle:setData("auction_vehicle", true, true)
    vehicle:setData("auction_vehicle:id", auction.id, true)
    vehicle:setData("auction_vehicle:description", auction.description, true)
    vehicle:setData("auction_vehicle:starting_bid", auction.starting_bid, true)
    vehicle:setData("auction_vehicle:minimum_increase", auction.minimum_increase, true)
    vehicle:setData("auction_vehicle:expiry", auction.expiry, true)
    vehicle:setData("auction_vehicle:current_bid", auction.current_bid or auction.starting_bid, true)
    vehicle:setData("auction_vehicle:current_bidder_id", auction.current_bidder_id, true)
    vehicle:setData("auction_vehicle:buyout", auction.buyout, true)
    vehicle:setData("auction_vehicle:created_by", auction.created_by, true)
end

function loadAuctionFloorVehicles()
    exports.mysql:getConn("mta"):query(function (handle)
        local results = handle:poll(0)

        for key, auction in pairs(results) do
            loadAuctionFloorVehicle(key, auction)
        end
    end, "SELECT * FROM vehicle_auctions WHERE awaiting_key_pickup = false ORDER BY id DESC LIMIT ?", #AUCTION_FLOOR_VEHICLE_POSITIONS)
end

addEventHandler("onResourceStart", resourceRoot, function ()
    loadAuctionFloorColShapes()
    loadAuctionFloorVehicles()
end, false)