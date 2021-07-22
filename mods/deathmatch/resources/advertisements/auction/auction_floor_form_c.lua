local bidVehicle = nil

local FloorBidForm = setmetatable({
    developmentMode = false,
    url = 'http://mta/local/auction/floor_bid.htm',

    init = function (self, vehicle)
        bidVehicle = vehicle
        local data = {
            model = vehicle:getData("maximemodel"),
            brand = vehicle:getData("brand"),
            year = vehicle:getData("year"),
            vin = vehicle:getData("dbid"),
            plate = vehicle:getPlateText(),
            starting_bid = vehicle:getData("auction_vehicle:starting_bid"),
            current_bid = vehicle:getData("auction_vehicle:current_bid"),
            current_bidder_id = vehicle:getData("auction_vehicle:current_bidder_id"),
            minimum_increase = vehicle:getData("auction_vehicle:minimum_increase"),
            buyout = vehicle:getData("auction_vehicle:buyout"),
            description = vehicle:getData("auction_vehicle:description"),
            expiry = vehicle:getData("auction_vehicle:expiry"),
        }

        self:executeJavascript("vm.init('"..self.javascriptJsonEncode(data, true).."');")
    end;
}, {
    __index = BrowserManager
})

function openFloorBidForm(vehicle)
    FloorBidForm:open()
    showCursor(true, true)
    guiSetInputMode('no_binds')

    addEventHandler("onClientBrowserDocumentReady", FloorBidForm.browser, function ()
        FloorBidForm:init(vehicle)
    end)
end

function closeFloorBidForm()
    if FloorBidForm:isOpen() then
        FloorBidForm:close()
    end
    showCursor(false)
    guiSetInputMode('allow_binds')
    bidVehicle = nil
end

addEvent("floor-bid:cancel", false)
addEventHandler("floor-bid:cancel", root, function ()
    closeFloorBidForm()
end)

addEvent("floor-bid:submit", false)
addEventHandler("floor-bid:submit", root, function (data)
    data = fromJSON(data)
    data.vehicleAuctionId = bidVehicle:getData("auction_vehicle:id")
    triggerServerEvent("floor-bid:submit", resourceRoot, data)
    closeFloorBidForm()
end)

addEvent("floor-bid:buyout", false)
addEventHandler("floor-bid:buyout", root, function ()
    local data = {
        vehicleAuctionId = bidVehicle:getData("auction_vehicle:id")
    }

    triggerServerEvent("floor-bid:buyout", resourceRoot, data)
    closeFloorBidForm()
end)

addEventHandler("onClientResourceStop", resourceRoot, closeFloorBidForm)