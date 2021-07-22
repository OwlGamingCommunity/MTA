local vehiclePositionCols = {}
local KEYMASTER_VEHICLE_POSITIONS = {
    {position = Vector3(1284, -1615, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
    {position = Vector3(1279, -1615, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
    {position = Vector3(1274, -1615, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
    {position = Vector3(1269, -1615, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
    {position = Vector3(1264, -1615, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
    {position = Vector3(1259, -1614, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
    {position = Vector3(1254, -1614, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
    {position = Vector3(1249, -1614, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
    {position = Vector3(1244, -1614, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
    {position = Vector3(1239, -1614, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
    {position = Vector3(1234, -1614, 13.2), rotation = Vector3(0, 0, 318), interior = 0, dimension = 0},
}

local KEYMASTER_VEHICLE_AWAITING_PICKUP_POSITIONS = {
    -- first row
    {position = Vector3(1363, 0, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -4, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -8, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -12, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -16, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -20, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -24, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -28, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -32, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -36, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -40, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1363, -44, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},

    -- second row
    {position = Vector3(1370, 0, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -4, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -8, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -12, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -16, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -20, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -24, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -28, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -32, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -36, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -40, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
    {position = Vector3(1370, -44, 1001), rotation = Vector3(0, 0, 270), interior = 1, dimension = 3946},
}

local function moveVehicle (vehicle, slot)
    local position = KEYMASTER_VEHICLE_AWAITING_PICKUP_POSITIONS[slot]
    if not position then
        return -- If the lot is full, leave the car on the auction floor.
    end

    vehicle:setData("auction_vehicle:awaiting_pickup", true)
    vehicle:setPosition(position.position)
    vehicle:setRotation(position.rotation)
    vehicle:setDimension(position.dimension)
    vehicle:setInterior(position.interior)
    vehicle:setFrozen(true)
end

function moveVehicleToPickupAvailableLot(vehicle, slot)
    if slot then
        moveVehicle(vehicle, slot)
        return
    end

    exports.mysql:getConn('mta'):query(
        function (handle, vehicle)
            local results = handle:poll(0)
            if #results ~= 1 then return end
            local slot = results[1].awaiting_pickup_count

            moveVehicle(vehicle, slot)
        end,
        {vehicle},
        "SELECT COUNT(0) as awaiting_pickup_count FROM vehicle_auctions WHERE awaiting_key_pickup = true"
    )
end

local function findAvailablePickupSlot()
    for _, outsideCol in pairs(vehiclePositionCols) do
        local elementsWithin = outsideCol:getElementsWithin()
        if #elementsWithin == 0 then
            return outsideCol:getData("index")
        end
    end

    return nil
end

function moveVehicleToPickupLot(vehicle)
    local slot = findAvailablePickupSlot()
    if not slot then
        return
    end
    local position = KEYMASTER_VEHICLE_POSITIONS[slot]
    if not position then
        return
    end

    vehicle:setPosition(position.position)
    vehicle:setRotation(position.rotation)
    vehicle:setDimension(position.dimension)
    vehicle:setInterior(position.interior)
    vehicle:setFrozen(false)
end

addEventHandler("onResourceStart", resourceRoot, function ()
    exports.mysql:getConn('mta'):query(
        function (handle)
            local results = handle:poll(0)

            for position, auction in pairs(results) do
                local vehicle = exports.pool:getElement("vehicle", auction.vehicle_id)

                removeVehicleAuctionData(vehicle)
                moveVehicleToPickupAvailableLot(vehicle, position)
            end
        end,
        "SELECT * FROM vehicle_auctions WHERE awaiting_key_pickup = true"
    )

    for index, outsidePosition in pairs(KEYMASTER_VEHICLE_POSITIONS) do
        local colShape = ColShape.Sphere(outsidePosition.position, 2)
        colShape:setData("index", index)
        table.insert(vehiclePositionCols, colShape)
    end
end)

addEvent("keymaster:get-available-keys", true)
addEventHandler("keymaster:get-available-keys", resourceRoot, function ()
    exports.mysql:getConn('mta'):query(
        function (handle, player)
            local results = handle:poll(0)

            for i, k in pairs(results) do
                local vehicle = exports.pool:getElement("vehicle", k.vehicle_id)
                results[i].vehicle_name = getVehicleFullName(vehicle)
            end

            triggerClientEvent(player, "keymaster:create-menu", player, results)
        end,
        {client},
        "SELECT id, vehicle_id FROM vehicle_auctions WHERE awaiting_key_pickup = true AND current_bidder_id = ?",
        client:getData('dbid')
    )
end)

addEvent("keymaster:get-key", true)
addEventHandler("keymaster:get-key", resourceRoot, function (auction)
    exports.mysql:getConn('mta'):query(
        function (handle, player)
            local results = handle:poll(0)
            if #results ~= 1 then return end
            local auction = results[1]
            local vehicle = exports.pool:getElement("vehicle", auction.vehicle_id)

            exports.global:giveItem(player, 3, auction.vehicle_id)
            moveVehicleToPickupLot(vehicle)
            vehicle:removeData("auction_vehicle:awaiting_pickup")
            exports.mysql:getConn('mta'):exec('DELETE FROM vehicle_auctions WHERE id = ?', auction.id)
            outputChatBox("You've been given the key to your " .. getVehicleFullName(vehicle) .. ".", player, 100, 255, 100)
            outputChatBox("Please pick it up at the north side of the lot.", player, 100, 255, 100)
            outputChatBox("Don't forget to /park your vehicle after picking it up!", player, 100, 255, 100)
        end,
        {client},
        "SELECT * FROM vehicle_auctions WHERE awaiting_key_pickup = true AND current_bidder_id = ? AND id = ?",
        client:getData('dbid'),
        auction.id
    )
end)
