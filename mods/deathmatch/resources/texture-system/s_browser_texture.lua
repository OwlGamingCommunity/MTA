local browserStates = {}

addEvent("frames:browser:requestSync", true)
addEventHandler("frames:browser:requestSync", resourceRoot, function(id)
    if browserStates[id] then
        triggerClientEvent(client, "frames:browser:sync", client, id, browserStates[id])
    end
end)

addEvent("frames:browser:syncPresentation", true)
addEventHandler("frames:browser:syncPresentation", resourceRoot, function(id, page)
    browserStates[id] = { presentation_slide = tonumber(page) or 1 }
    for _, player in ipairs(getElementsByType("player")) do
        if getElementDimension(player) == getElementDimension(client) then
            triggerClientEvent(player, "frames:browser:sync", client, id, browserStates[id])
        end
    end
end)
