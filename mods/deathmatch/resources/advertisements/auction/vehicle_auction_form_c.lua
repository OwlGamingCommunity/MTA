local VehicleAuctionForm = setmetatable({
    developmentMode = false,
    url = 'http://mta/local/auction/form.htm',

    init = function (self, vehicle, screenSize)
        local vehicleData = {
            odometer = math.floor(exports.realism:getDistanceTraveled() / 1000),
            model = getElementData(vehicle, "maximemodel"),
            brand = getElementData(vehicle, "brand"),
            year = getElementData(vehicle, "year"),
            vin = getElementData(vehicle, "dbid"),
            plate = getVehiclePlateText(vehicle),
            screenSize = screenSize
        }

        self:executeJavascript("vm.init('"..self.javascriptJsonEncode(vehicleData, true).."');")
    end;
}, {
    __index = BrowserManager
})

function openVehicleAuctionForm()
    VehicleAuctionForm:open()
    showCursor(true, true)
    guiSetInputMode('no_binds')

    addEventHandler("onClientBrowserDocumentReady", VehicleAuctionForm.browser, function ()
        VehicleAuctionForm:init(localPlayer.vehicle, {guiGetScreenSize()})
    end)
end

function closeAuctionForm()
    VehicleAuctionForm:close()
    showCursor(false)
    guiSetInputMode('allow_binds')
end

addEvent("vehicle-auction:confirmed", false)
addEventHandler("vehicle-auction:confirmed", root, function ()
    pedGivesDriverForm()
end)

addEvent("vehicle-auction:cancel", false)
addEventHandler("vehicle-auction:cancel", root, function ()
    closeAuctionForm()
    auctionRequestCancelled()
end)

addEvent("vehicle-auction:submit", false)
addEventHandler("vehicle-auction:submit", root, function (data)
    data = fromJSON(data)
    triggerServerEvent("vehicle-auction:submit", resourceRoot, data)
end)