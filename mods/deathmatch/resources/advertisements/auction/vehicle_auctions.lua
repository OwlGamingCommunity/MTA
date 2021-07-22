local PLAYER_EXIT_POSITION = Vector3(1286, -1667, 13.5)
local PLAYER_EXIT_ROTATION = Vector3(0, 0, 270)
local AUCTIONEER_FACTION = 20 -- San Andreas Network.
local AUCTIONEER_FACTION_NAME = "San Andreas Network"
local COMPLETE_AUCTIONS_INTERVAL = 60000 -- Complete any finished auctions every minute.

function getVehicleFullName(vehicle)
    return vehicle:getData("year") .. ' ' .. vehicle:getData("brand") .. ' ' .. vehicle:getData("maximemodel")
end

local function getAdvertisementString(vehicle)
    local vehicleName = getVehicleFullName(vehicle)
    local miles = math.ceil(vehicle:getData("odometer") / 1000)

    return "AUCTION: " .. vehicleName .. " with " .. miles .. " miles."
end

local function returnPreviousBid(characterId, bid, vehicle)
    local player = exports.global:getPlayerFromCharacterID(characterId)

    if isElement(player) and getElementType(player) == 'player' then
        exports.bank:giveBankMoney(player, bid)
    else
        exports.mysql:getConn('mta'):exec("UPDATE characters SET bankmoney = bankmoney + ? WHERE id = ?", bid, characterId)
    end

    exports.global:takeMoney(getTeamFromName(AUCTIONEER_FACTION_NAME), bid)
    exports.bank:addBankTransactionLog(-AUCTIONEER_FACTION, characterId, bid, 3, "Vehicle Auction Bid Refund", "You were outbid on: " .. getVehicleFullName(vehicle))
end

addCommandHandler("expireauctions", function (player, command)
    if not exports.integration:isPlayerLeadScripter(player) then
        return
    end

    exports.mysql:getConn('mta'):exec("UPDATE vehicle_auctions SET expiry = 1000000000")
    outputChatBox("Expired all auctions.", player, 100, 100, 255)
end)

local function debitAuctioneerFaction(actor, vehicle, amount)
    exports.global:takeMoney(getTeamFromName(AUCTIONEER_FACTION_NAME), amount)
    exports.bank:addBankTransactionLog(-AUCTIONEER_FACTION, actor, amount, 3, "Vehicle Auction Completed", "Your " .. getVehicleFullName(vehicle) .. " was sold.")
end

local function paySellerFaction(auction, vehicle, isBuyout)
    local amount = isBuyout and auction.buyout or auction.current_bid
    local faction = exports.pool:getElement('team', auction.created_by_faction)

    exports.global:giveMoney(faction, amount)

    debitAuctioneerFaction(-auction.created_by_faction, vehicle, amount)
end

local function paySeller(auction, vehicle, isBuyout)
    if auction.created_by_faction then
        paySellerFaction(auction, vehicle, isBuyout)
        return
    end

    local player = exports.global:getPlayerFromCharacterID(auction.created_by)
    local amount = isBuyout and auction.buyout or auction.current_bid

    if isElement(player) and getElementType(player) == 'player' then
        exports.bank:giveBankMoney(player, amount)
    else
        exports.mysql:getConn('mta'):exec("UPDATE characters SET bankmoney = bankmoney + ? WHERE id = ?", amount, auction.created_by)
    end

    debitAuctioneerFaction(auction.created_by, vehicle, amount)
end

local function completeAuction(auction)
    exports.mysql:getConn('mta'):exec("DELETE FROM advertisements WHERE id = ?", auction.advertisement_id)
    exports.mysql:getConn('mta'):exec("DELETE FROM vehicle_auctions WHERE id = ?", auction.id)
end

local function giveKey(player, vehicleId)
    if not exports.global:hasSpaceForItem(player, 3, vehicleId) then
        outputChatBox("You do not have any space on you to hold a key.", person, 255, 100, 100)
        return
    end

    exports.global:giveItem(player, 3, vehicleId)
end

function removeVehicleAuctionData(vehicle)
    vehicle:setFrozen(false)
    vehicle:setData("auction_vehicle", false, true)
    vehicle:removeData("auction_vehicle:id")
    vehicle:removeData("auction_vehicle:description")
    vehicle:removeData("auction_vehicle:starting_bid")
    vehicle:removeData("auction_vehicle:minimum_increase")
    vehicle:removeData("auction_vehicle:expiry")
    vehicle:removeData("auction_vehicle:current_bid")
    vehicle:removeData("auction_vehicle:current_bidder_id")
    vehicle:removeData("auction_vehicle:buyout")
    vehicle:removeData("auction_vehicle:created_by")
end

setTimer(function ()
    exports.mysql:getConn('mta'):query(
        function (handle)
            local results = handle:poll(0)

            for _, auction in pairs(results) do
                local vehicle = exports.pool:getElement("vehicle", auction.vehicle_id)

                -- if current_bidder_id is null, alert owner that their auction completed without any bids, and they need to pickup their vehicle.
                if not auction.current_bidder_id then
                    -- Set the current bidder to the seller, so they can come pick their car up.
                    exports.mysql:getConn('mta'):exec("UPDATE vehicle_auctions SET awaiting_key_pickup = true, current_bidder_id = ? WHERE id = ?", auction.created_by, auction.id)
                    removeVehicleAuctionData(vehicle)
                    moveVehicleToPickupAvailableLot(vehicle)

                    exports.announcement:makePlayerNotification(sellerAccountId, "Vehicle Auction Finished Without Sale", "Your " .. getVehicleFullName(vehicle) .. " had no bids! Please pickup your vehicle at the auction center.", "other")
                    return
                end

                -- sell auction vehicle
                sellAuctionVehicle(auction.current_bidder_id, vehicle, auction)
                removeVehicleAuctionData(vehicle)
                exports.mysql:getConn('mta'):exec("UPDATE vehicle_auctions SET awaiting_key_pickup = true WHERE id = ?", auction.id)
                moveVehicleToPickupAvailableLot(vehicle)

                -- pay seller
                paySeller(auction, vehicle, false)

                -- notify seller
                local sellerAccountId = getAccountIdFromCharacter(auction.created_by)
                exports.announcement:makePlayerNotification(sellerAccountId, "Vehicle Auction Completed", "Your " .. getVehicleFullName(vehicle) .. " has been sold for $" .. auction.current_bid .. "!", "other")

                -- notify buyer
                local buyerAccountId = getAccountIdFromCharacter(auction.current_bidder_id)
                exports.announcement:makePlayerNotification(buyerAccountId, "Vehicle Auction Won!", "You won the auction for the " .. getVehicleFullName(vehicle) .. "! Pickup your vehicle at the auction center.", "other")
            end
        end,
        "SELECT * FROM vehicle_auctions WHERE expiry < ? AND awaiting_key_pickup = false",
        getRealTime().timestamp -- TODO: this is probably not correct.
    )
end, COMPLETE_AUCTIONS_INTERVAL, 0)

local function acceptingNewAuctions()
    local handle = exports.mysql:getConn('mta'):query("SELECT COUNT(0) AS active_auctions FROM vehicle_auctions WHERE awaiting_key_pickup = false")
    local results = handle:poll(1000)
    if #results ~= 1 then return false end

    return results[1].active_auctions < #AUCTION_FLOOR_VEHICLE_POSITIONS
end

addEvent("vehicle-auction:submit", true)
addEventHandler("vehicle-auction:submit", resourceRoot, function (data)
    local vehicle = getPedOccupiedVehicle(client)
    local vehicleFaction = tonumber(vehicle:getData('faction'))

    if vehicleFaction > 0 then
        if not exports.factions:hasMemberPermissionTo(client, vehicleFaction, "add_member") then
            outputChatBox("You must be the faction leader to sell this vehicle.")
            return
        end
    elseif vehicle:getData('owner') ~= client:getData('dbid') then
        outputChatBox("You cannot auction a vehicle you don't own.", client, 255, 100, 100)
        client:fadeCamera(true)
        triggerClientEvent(client, "vehicle-auction:created", client)
        return
    end

    if vehicle:getData('token') then
        outputChatBox("You cannot auction a token vehicle.", client, 255, 100, 100)
        client:fadeCamera(true)
        triggerClientEvent(client, "vehicle-auction:created", client)
        return
    end

    if not acceptingNewAuctions() then
        outputChatBox("This auction center is not accepting new auctions right now.", client, 255, 100, 100)
        client:fadeCamera(true)
        triggerClientEvent(client, "vehicle-auction:created", client)
        return
    end

    data.start = getRealTime().timestamp
    data.expiry = data.start + parseExpiryToSeconds(data.end_date)

    createAdvertisement(client, {
        name = client:getName():gsub('_', ' '),
        advertisement = getAdvertisementString(vehicle),
        phone = '',
        address = '',
        section = "Vehicles",
        faction = vehicleFaction > 0 and vehicleFaction or nil,
        start = data.start,
        expiry = data.expiry
    }, function (sender, advertisementId)

        exports.mysql:getConn('mta'):exec(
            "INSERT INTO vehicle_auctions (vehicle_id, advertisement_id, description, starting_bid, minimum_increase, buyout, expiry, created_by, created_by_faction) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
            sender.vehicle:getData('dbid'),
            advertisementId,
            data.description,
            data.starting_bid,
            data.minimum_increase,
            data.buyout,
            data.expiry,
            sender:getData('dbid'),
            vehicleFaction > 0 and vehicleFaction or nil
        )

        triggerClientEvent(sender, "vehicle-auction:created", sender)
        sender:fadeCamera(false)
        exports.hud:sendBottomNotification(sender, "Vehicle Auctioned!", "Your vehicle has been put on auction! You can view the auction in the advertisements panel.")
        setTimer(function ()
            local vehicle = sender.vehicle
            sender:removeFromVehicle()
            loadAuctionFloorVehicles() -- move the vehicle to the auction floor.
            sender:setPosition(PLAYER_EXIT_POSITION)
            sender:setRotation(PLAYER_EXIT_ROTATION)
            sender:fadeCamera(true)
        end, 2000, 1)
    end)
end)

addEvent("floor-bid:submit", true)
addEventHandler("floor-bid:submit", resourceRoot, function (data)
    exports.mysql:getConn('mta'):query(
        function (handle, player, data)
            local results = handle:poll(0)
            if not #results == 1 then return end
            local auction = results[1]
            local bid = tonumber(data.bid)
            local characterId = player:getData('dbid')

            if player:getData('account:id') == getAccountIdFromCharacter(auction.created_by) then
                outputChatBox("You can't interact with this auction!", player, 255, 100, 100)
                return
            end

            if auction.created_by_faction then
                local faction, _ = exports.factions:isPlayerInFaction(player, auction.created_by_faction)
                if faction then
                    outputChatBox("You can't interact with this auction!", player, 255, 100, 100)
                    return
                end
            end

            if not exports.global:canPlayerBuyVehicle(player) then
                outputChatBox("You must have available vehicle slots to bid.", player, 255, 100, 100)
                return
            end

            if auction.expiry < getRealTime().timestamp then
                outputChatBox("This auction already finished!", player, 255, 100, 100)
                return
            end

            if bid < auction.starting_bid then
                outputChatBox("Bid must exceed minimum bid.", player, 255, 100, 100)
                return
            end

            if type(auction.current_bid) == 'number' and bid < (auction.current_bid + auction.minimum_increase) then
                outputChatBox("Bid must exceed current bid by at least the minimum increase.", player, 255, 100, 100)
                return
            end

            if bid > auction.buyout then
                outputChatBox("Bid cannot exceed buyout, click buyout instead!", player, 255, 100, 100)
                return
            end

            local vehicle = exports.pool:getElement("vehicle", auction.vehicle_id)
            if not vehicle then
                outputChatBox("Could not find that auction vehicle.", player, 255, 100, 100)
                return
            end

            -- Take the current bid amount from the character bidding.
            if not exports.bank:takeBankMoney(player, tonumber(data.bid), false) then
                outputChatBox("Insufficient bank balance to bid.", player, 255, 100, 100)
                return
            end
            exports.global:giveMoney(getTeamFromName(AUCTIONEER_FACTION_NAME), tonumber(data.bid))
            exports.bank:addBankTransactionLog(characterId, -AUCTIONEER_FACTION, tonumber(data.bid), 2 , "Vehicle Auction Bid", "You bid on: " .. getVehicleFullName(vehicle))

            -- Return the previous bidder their bid money.
            if auction.current_bidder_id ~= nil then
                returnPreviousBid(auction.current_bidder_id, auction.current_bid, vehicle)
            end

            exports.mysql:getConn('mta'):exec("UPDATE vehicle_auctions SET current_bidder_id = ?, current_bid = ? WHERE id = ?", characterId, bid, auction.id)
            vehicle:setData("auction_vehicle:current_bid", bid)
            vehicle:setData("auction_vehicle:current_bidder_id", characterId)

            outputChatBox("You have successfully bid $" .. bid .. " on the " .. getVehicleFullName(vehicle) .. ".", player, 100, 255, 100)
        end,
        {client, data},
        "SELECT * FROM vehicle_auctions WHERE id = ?",
        data.vehicleAuctionId
    )
end)

addEvent("floor-bid:buyout", true)
addEventHandler("floor-bid:buyout", resourceRoot, function (data)
    exports.mysql:getConn('mta'):query(
        function (handle, player)
            local results = handle:poll(0)
            if not #results == 1 then return end
            local auction = results[1]
            local characterId = player:getData('dbid')

            if player:getData('account:id') == getAccountIdFromCharacter(auction.created_by) then
                outputChatBox("You can't interact with this auction!", player, 255, 100, 100)
                return
            end

            local vehicle = exports.pool:getElement("vehicle", auction.vehicle_id)
            if not vehicle then
                outputChatBox("Could not find that auction vehicle.", player, 255, 100, 100)
                return
            end

            if auction.expiry < getRealTime().timestamp then
                outputChatBox("This auction already finished!", player, 255, 100, 100)
                return
            end

            if not exports.global:canPlayerBuyVehicle(player) then
                outputChatBox("You must have available vehicle slots to buy this vehicle.", player, 255, 100, 100)
                return
            end

            if not exports.bank:takeBankMoney(player, tonumber(auction.buyout), false) then
                outputChatBox("Insufficient bank balance to buyout.", player, 255, 100, 100)
                return
            end
            exports.global:giveMoney(getTeamFromName(AUCTIONEER_FACTION_NAME), tonumber(auction.buyout))
            exports.bank:addBankTransactionLog(characterId, -AUCTIONEER_FACTION, tonumber(auction.buyout), 2 , "Vehicle Auction Buyout", "Bought " .. getVehicleFullName(vehicle))

            paySeller(auction, vehicle, true)
            if auction.current_bidder_id ~= nil then
                returnPreviousBid(auction.current_bidder_id, auction.current_bid, vehicle)
            end
            sellAuctionVehicle(characterId, vehicle, auction)
            removeVehicleAuctionData(vehicle)
            giveKey(player, auction.vehicle_id)
            completeAuction(auction)

            -- notify seller
            local sellerAccountId = getAccountIdFromCharacter(auction.created_by)
            exports.announcement:makePlayerNotification(sellerAccountId, "Vehicle Auction Completed", "Your " .. getVehicleFullName(vehicle) .. " has been sold for $" .. auction.buyout .. "!", "other")

            -- notify buyer
            local buyerAccountId = getAccountIdFromCharacter(characterId)
            exports.announcement:makePlayerNotification(buyerAccountId, "Vehicle Auction Won!", "You won the auction for the " .. getVehicleFullName(vehicle) .. "!", "other")
        end,
        {client},
        "SELECT * FROM vehicle_auctions WHERE id = ?",
        data.vehicleAuctionId
    )
end)