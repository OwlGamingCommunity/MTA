-- As this is a seasonal event for now, I've used generics for ice. Place them above the water so they won't sink.
-- Object details: Model: 6959, Texture name: greyground25612, texture URL: https://i.imgur.com/Mp59oHH.jpg

function initializeSkating()
    local iceCol = createColCuboid(1932.3125, -1218.3095703125, 18.01155090332, 77, 37, 6) -- Glen Park pond

    addEventHandler( 'onColShapeHit', iceCol, function(thePlayer)
        if isPedDead (thePlayer) ~= true then
            local hasItem = exports.global:hasItem(thePlayer, 274) -- has player ice skates
            if hasItem then
                exports.realism:setForceWalkStyle(thePlayer, 138)
            end
        end
    end)

    addEventHandler( 'onColShapeLeave', iceCol, function(thePlayer)
        if isPedDead (thePlayer) ~= true then
            exports.realism:unsetForceWalkStyle(thePlayer)
        end
    end)
end
addEvent("events:skating")
addEventHandler("events:skating", root, initializeSkating)