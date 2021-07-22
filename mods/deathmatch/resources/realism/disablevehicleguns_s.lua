local disabled = {[425] = true, [520] = true, [476] = true, [464] = true, [430] = true, [432] = true, [447] = true}

addEventHandler("onPlayerVehicleEnter", root,
    function(vehicle)
        local enabled = not disabled[getElementModel(vehicle)]
        if getElementType( source ) == "player" then
            toggleControl(source, 'vehicle_fire', enabled)
            toggleControl(source, 'vehicle_secondary_fire', enabled)
        end
    end)

addEventHandler("onResourceStart", resourceRoot,
    function()
        for _, player in ipairs(getElementsByType("player")) do
            local vehicle = getPedOccupiedVehicle(player)
            if vehicle then
                local enabled = not disabled[getElementModel(vehicle)]
                toggleControl(player, 'vehicle_fire', enabled)
                toggleControl(player, 'vehicle_secondary_fire', enabled)
            end
        end
    end)
