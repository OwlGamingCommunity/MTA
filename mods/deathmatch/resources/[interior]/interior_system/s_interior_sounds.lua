local function findHouse(house, source)
    if house then
        if getElementType(house) == "interior" then
            local entrance = getElementData(house, "entrance")
            local interiorExit = getElementData(house, "exit")

            return { entrance, interiorExit }
        elseif getElementType(house) == "elevator" then
            local elevatorEntrance = getElementData(house, "entrance")
            local elevatorExit = getElementData(house, "exit")

            if elevatorEntrance and elevatorExit then
                return {
                    { x = elevatorEntrance[1], y = elevatorEntrance[2], z = elevatorEntrance[3], dim = elevatorEntrance[5] },
                    { x = elevatorExit[1], y = elevatorExit[2], z = elevatorExit[3], dim = elevatorExit[5] },
                }
            else
                return findHouse(nil, source)
            end
        else
            local found
            local minDistance = 20
            local pPosX, pPosY, pPosZ = getElementPosition(source)
            local dimension = getElementDimension(source)

            local possibleInteriors = exports.pool:getPoolElementsByType("interior")
            for _, interior in ipairs(possibleInteriors) do
                local entrance = getElementData(interior, "entrance")
                local interiorExit = getElementData(interior, "exit")
                for _, point in ipairs( { entrance, interiorExit } ) do
                    if (point.dim == dimension) then
                        local distance = getDistanceBetweenPoints3D(pPosX, pPosY, pPosZ, point.x, point.y, point.z) or 20
                        if (distance < minDistance) then
                            found = interior
                            minDistance = distance
                        end
                    end
                end
            end

            if found then
                local entrance = getElementData(found, "entrance")
                local interiorExit = getElementData(found, "exit")

                return { entrance, interiorExit }
            end
        end
    end
    return nil
end

function playInteriorSound(eventName, house, source)
    local sentTo = {}
    for _, interiorElement in ipairs(findHouse(house, source) or {}) do
        for _, nearbyPlayer in ipairs(exports.pool:getPoolElementsByType("player")) do
            if isElement(nearbyPlayer) and getElementData(nearbyPlayer, "loggedin") == 1 and not sentTo[nearbyPlayer] then
                if getDistanceBetweenPoints3D(interiorElement.x, interiorElement.y, interiorElement.z, getElementPosition(nearbyPlayer)) < 20 and getElementDimension(nearbyPlayer) == interiorElement.dim then
                    sentTo[nearbyPlayer] = true
                    triggerClientEvent(nearbyPlayer, eventName, source, interiorElement.x, interiorElement.y, interiorElement.z)
                end
            end
        end
    end
end

function doorUnlockSound(house, source)
    playInteriorSound("doorUnlockSound", house, source)
end

function doorLockSound(house, source)
    playInteriorSound("doorLockSound", house, source)
end

function doorGoThru(house, source)
    playInteriorSound("doorGoThru", house, source)
end

function playerKnocking(house, source)
    playInteriorSound("playerKnock", house, source)
end
addEvent("onKnocking", true)
addEventHandler("onKnocking", root, function(house) playerKnocking(house, source) end)
