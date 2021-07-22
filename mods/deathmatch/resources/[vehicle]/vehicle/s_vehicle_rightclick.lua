addEvent("vehicle:rightclick:fetch_data", true)
addEventHandler("vehicle:rightclick:fetch_data", root, function()
    if not client or getElementType(source) ~= "vehicle" then return end

    -- sync data to the client that they would not reasonably know.
    triggerClientEvent(client, "vehicle:rightclick:data", source,
        -- items in inventory: we can't guarantee the client has access to the inventory prior to opening the right-click menu.
        -- does this vehicle have a ramp?
        exports.global:hasItem(source, 117)
    )
end)
