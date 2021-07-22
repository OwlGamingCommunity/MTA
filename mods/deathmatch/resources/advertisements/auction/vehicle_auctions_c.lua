local MARKER_COORDS = Vector3(1283, -1667, 12)
local MARKER_RADIUS = 4
local MARKER_COLOR = {200, 200, 200}
local PED_COORDS = Vector3(1280, -1672, 13.5)
local PED_NAME = "Derrick Rustico"
local PED_ROTATION = Vector3(0, 0, 320)
local VEHICLE_COORDS = Vector3(1283, -1667, 12.5)
local CAMERA_MATRIX = {position = Vector3(1280, -1674, 14.2), lookingAt = Vector3(1285, -1663, 12.5)}
local DRIVER_SEAT = 0

local initialMarker = nil
local initialPed = nil

local BuyerSequence = setmetatable({
    --[[
        Step 1:
        Stop the vehicle the player is in.
    ]]
    stopVehicle = function (self, vehicle)
        addEventHandler("onClientVehicleStopped", vehicle, onVehicleStopped, false)

        toggleAllControls(false, true, false) -- toggle only GTA controls
        bringVehicleToStop(vehicle)
    end;

    --[[
        Step 2:
        Put the camera and vehicle in the correct position.
        Enable our cinematic screen bars.
        Have the buyer ped walk up to the vehicle.
    ]]
    initiateBuyerSequence = function(self, vehicle)
        localPlayer:setData("auctioning-vehicle", true, false)
        destroyElement(initialMarker)
        removeEventHandler("onClientVehicleStopped", vehicle, onVehicleStopped)

        enableCinematicScreenBars()

        -- todo: take current account setting into account here.
        exports.account:updateAccountSettings("hide_hud", '0')
        exports.account:updateAccountSettings("graphic_chatbub", '1') -- Chat bubbles are necessary for this UI.
        showChat(false)

        local vehicleCenter = vehicle:getDistanceFromCentreOfMassToBaseOfModel()

        vehicle:setPosition(VEHICLE_COORDS:getX(), VEHICLE_COORDS:getY(), VEHICLE_COORDS:getZ() + vehicleCenter)
        vehicle:setRotation(Vector3(0, 0, 90))

        setCameraMatrix(CAMERA_MATRIX.position, CAMERA_MATRIX.lookingAt)

        setPedControlState(initialPed, "walk", true)
        setPedControlState(initialPed, "forwards", true)

        setTimer(function ()
            self:buyerFinishedWalking()
        end, 2000, 1)
    end;

    --[[
        Step 3:
        Buyer asks driver if they're willing to sell the vehicle.
    ]]
    buyerFinishedWalking = function(self)
        setPedControlState(initialPed, "walk", false)
        setPedControlState(initialPed, "forwards", false)
        triggerEvent("addChatBubble", initialPed, "Now that is a beautiful machine! You lookin' to sell?", "say")

        openVehicleAuctionForm()
    end;

    --[[
        Creates the initial marker that the player must hit to begin the buyer sequence.
    ]]
    createInitialMarker = function(self)
        initialMarker = Marker(MARKER_COORDS, "cylinder", MARKER_RADIUS, unpack(MARKER_COLOR))
        initialMarker:setAlpha(155)

        addEventHandler('onClientMarkerHit', initialMarker, function (player, matchingDimension)
            if not matchingDimension or player ~= localPlayer then
                return
            end

            local vehicle = player:getOccupiedVehicle()
            if not vehicle or player.vehicleSeat ~= DRIVER_SEAT then
                return
            end

            self:stopVehicle(vehicle)
        end, false)
    end;

    --[[
        Creates our ped who will talk to the player and walk them through the selling experience.
    ]]
    createInitialPed = function (self)
        initialPed = Ped(125, PED_COORDS)
        initialPed:setRotation(PED_ROTATION)
        initialPed:setData("name", PED_NAME)
        initialPed:setData("nametag", true)

        setTimer(function ()
            if not localPlayer:getData("auctioning-vehicle") then
                if getDistanceBetweenPoints3D(PED_COORDS, initialPed:getPosition()) > 2 then
                    initialPed:setPosition(PED_COORDS)
                end
            end
        end, 10000, 0)
    end;

    --[[
        RESET:
        Resets all of the user's experience back to normal so they can drive away.
    ]]
    reset = function(self)
        -- todo: take current account setting into account here.
        exports.account:updateAccountSettings('hide_hud', '1')
        showChat(true)
        toggleAllControls(true)
        setCameraTarget(localPlayer, localPlayer)
        disableCinematicScreenBars()
        localPlayer:setData("auctioning-vehicle", false, false)
        self:createInitialMarker()
    end
}, {})

function onVehicleStopped()
    -- Sleep for 500ms to ensure the vehicle has settled before we try and teleport it.
    setTimer(function (vehicle)
        BuyerSequence:initiateBuyerSequence(vehicle)
    end, 500, 1, source)
end

function pedGivesDriverForm()
    triggerEvent("addChatBubble", initialPed, "Great! Fill out this form and we'll get the auction online right away!", "say")
    setTimer(triggerEvent, 1000, 1, "addChatBubble", initialPed, PED_NAME .. " hands an auction form to " .. localPlayer.name:gsub("_", " ") ..".", "ame")
end

function auctionRequestCancelled()
    triggerEvent("addChatBubble", initialPed, "Alright, suit yourself!", "say")
    BuyerSequence:reset()
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
    if localPlayer:getData("auctioning-vehicle") then
        BuyerSequence:reset()
    end

    BuyerSequence:createInitialMarker()
    BuyerSequence:createInitialPed()
end)

addEvent("vehicle-auction:created", true)
addEventHandler("vehicle-auction:created", root, function ()
    BuyerSequence:reset()
    closeAuctionForm()
end)
