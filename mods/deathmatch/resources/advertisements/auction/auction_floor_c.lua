local activeAuctionFloor = nil

local function formatNumberAsCommaSeparated (amount)
    local formatted = amount
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if (k == 0) then
            break
        end
    end
    return formatted
end

local function shouldShowInfoBar (vehicle)
    local cameraX, cameraY, cameraZ = getCameraMatrix()

    local isAuctionVehicle = vehicle:getData("auction_vehicle")
    local viewingDescription = getKeyState("lalt")
    local isNearby = getDistanceBetweenPoints3D(vehicle:getPosition(), localPlayer:getPosition()) < 20
    local isInSight = isLineOfSightClear(cameraX, cameraY, cameraZ, vehicle:getPosition(), true, true, false, true, false, false, true, vehicle) and isElementOnScreen(vehicle)

    return isAuctionVehicle and isNearby and isInSight and not viewingDescription
end

local function timeRemaining(expiry)
    local now = getElementData(root, "server:Timestamp")
    local secondsLeft = expiry - now

    if secondsLeft < 0 then
        return 'None'
    end

    local minutesLeft = math.floor(secondsLeft / 60)
    local hoursLeft = math.floor(minutesLeft / 60)
    local daysLeft = math.floor(hoursLeft / 24)

    local str = ""

    if daysLeft > 0 then
        str = daysLeft .. (daysLeft > 1 and " Days" or " Day")
    elseif hoursLeft > 0 then
        str = hoursLeft .. (hoursLeft > 1 and " Hours" or " Hour")
    elseif minutesLeft > 0 then
        str = minutesLeft .. (minutesLeft > 1 and " Minutes" or " Minute")
    else
        str = secondsLeft .. (secondsLeft > 1 and " Seconds" or " Second")
    end

    return str
end

local function renderVehicle (vehicle)
    if not shouldShowInfoBar(vehicle) then
        return
    end

    local isAuctioneer = vehicle:getData("auction_vehicle:created_by") == localPlayer:getData('dbid')
    local _, _, _, _, _, dz = getElementBoundingBox(vehicle)
    local vehiclePosition = vehicle:getPosition()
    vehiclePosition:setZ(vehiclePosition.z + 0.5 + dz)

    local sx, sy = getScreenFromWorldPosition(vehiclePosition)
    if not sx or not sy then
        return
    end

    local text = vehicle:getData("year") .. " " .. vehicle:getData("brand") .. " " .. vehicle:getData("maximemodel")
        .. "\n Description: " .. vehicle:getData("auction_vehicle:description")
        .. "\n\n" .. timeRemaining(tonumber(vehicle:getData("auction_vehicle:expiry"))) .. " Remaining"
        .. "\nCurrent Bid $" .. formatNumberAsCommaSeparated(vehicle:getData("auction_vehicle:current_bid"))
        .. "\nBuyout $" .. formatNumberAsCommaSeparated(vehicle:getData("auction_vehicle:buyout"))


    if not isAuctioneer then
        text = text .. "\n\nPress 'F' to bid"
    end

    -- background
    local width = dxGetTextWidth(text)
    local height = dxGetFontHeight() * (isAuctioneer and 6 or 8)
    dxDrawRectangle(sx - width / 2 - 10, sy - height / 2 - 10, width + 20, height + 20, tocolor(0, 0, 0, 50))

    -- text
    dxDrawText(text, sx, sy, sx, sy, tocolor(255, 255, 255, 255), 1, "default", "center", "center")
end

local function renderVehicleAuctionData ()
    local vehicles = activeAuctionFloor:getElementsWithin("vehicle")
    if #vehicles == 0 then
        vehicles = getElementsByType("vehicle", root, true)
    end
    for _, vehicle in pairs(vehicles) do
        renderVehicle(vehicle)
    end
end

local function enteringAuctionFloor (player, matchingDimension)
    if player ~= localPlayer or not matchingDimension then
        return
    end
    activeAuctionFloor = source

    -- remove first in case they left via interior change so never triggered the leaving event.
    removeEventHandler("onClientRender", root, renderVehicleAuctionData)

    addEventHandler("onClientRender", root, renderVehicleAuctionData)
end

local function leavingAuctionFloor (player, matchingDimension)
    if player ~= localPlayer or not matchingDimension then
        return
    end
    activeAuctionFloor = nil
    removeEventHandler("onClientRender", root, renderVehicleAuctionData)
end

local shapesAttached = {}
local function registerColShapeEvents()
    for _, shape in pairs(getElementsByType("colshape")) do
        if shape:getData('auction_floor') and not shapesAttached[shape] then
            addEventHandler("onClientColShapeHit", shape, enteringAuctionFloor)
            addEventHandler("onClientColShapeLeave", shape, leavingAuctionFloor)
            shapesAttached[shape] = true
        end
    end
end

addEvent("vehicle-auction:col-shapes-created", true)
addEventHandler("vehicle-auction:col-shapes-created", resourceRoot, registerColShapeEvents, false)
addEventHandler("onClientResourceStart", resourceRoot, registerColShapeEvents, false)

addEventHandler("onClientVehicleStartEnter", root, function (player)
    if player ~= localPlayer then
        return
    end

    local isAuctionVehicle = source:getData("auction_vehicle")
    if not isAuctionVehicle then
        return
    end

    cancelEvent()

    local auctioneer = source:getData("auction_vehicle:created_by")
    if auctioneer == localPlayer:getData('dbid') then
        return
    end

    if getDistanceBetweenPoints3D(source:getPosition(), localPlayer:getPosition()) > 5 then
        return
    end

    openFloorBidForm(source)
end)