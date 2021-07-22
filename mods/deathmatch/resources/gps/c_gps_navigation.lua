local blip, marker

local function destroyPreviousGps()
    if blip ~= nil then
        destroyElement(blip)
        destroyElement(marker)
    end

    blip, marker = nil, nil
end

addCommandHandler("gps", function (command, zipCode)
    if not exports.global:hasItem(localPlayer, 111) then
        outputChatBox("You do not have a GPS.", 255, 100, 100)
        return
    end

    if not zipCode or not tonumber(zipCode) then
        if blip ~= nil then
            destroyPreviousGps()
            outputChatBox('GPS cleared.', 100, 100, 255)
        end

        outputChatBox("Syntax: /" .. command .. " [zip code]", 255, 255, 255)
        return
    end

    local dbid, entrance = exports['interior_system']:findProperty(player, zipCode)
    if not entrance then
        outputChatBox("No such property with that zip code.", 255, 100, 100)
        return
    end

    if getElementDimension(entrance) ~= 0 then
        outputChatBox("That zip code is not available with this system.", 255, 100, 100)
        return
    end

    destroyPreviousGps()

    local x, y, z = getElementPosition(entrance)

    blip = createBlip(x, y, z, 0, 2, 100, 255, 100)
    marker = createMarker(x, y, z, "checkpoint", 1, 100, 255, 100, 255)
    addEventHandler("onClientMarkerHit", marker, function (hitPlayer)
        if hitPlayer == localPlayer then
            destroyPreviousGps()
            outputChatBox("You have arrived!", 100, 255, 100)
        end
    end)

    outputChatBox("The destination has been loaded onto your GPS, highlighted in green.", 100, 255, 100)
end, false, false)