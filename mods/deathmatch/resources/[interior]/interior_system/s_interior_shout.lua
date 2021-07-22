--Interior Shouting
function trunklateText( thePlayer, text, factor )
    --[[
    if getElementData(thePlayer, "alcohollevel") and (getElementData(thePlayer, "alcohollevel") > 0) then
        local level = math.ceil( getElementData(thePlayer,"alcohollevel") * #text / ( factor or 15 ) )
        for i = 1, level do
            x = math.random( 1, #text )
            -- dont replace spaces
            if text.sub( x, x ) == ' ' then
                i = i - 1
            else
                local a, b = text:sub( 1, x - 1 ) or "", text:sub( x + 1 ) or ""
                local c = ""
                if math.random( 1, 6 ) == 1 then
                    c = string.char(math.random(65,90))
                else
                    c = string.char(math.random(97,122))
                end
                text = a .. c .. b
            end
        end
    end
    ]]
    return text
end

outToInRadius = 25
inToOutRadius = 15
function interiorShout( thePlayer, commandName, ... )
    local playerName = getPlayerName(thePlayer)
    local language, languagename = exports['chat-system']:getCurrentLanguage(thePlayer, commandName)
    if language == 0 then
        return
    end

    local r, g, b = 255, 255, 255
    local focus = getElementData(thePlayer, "focus")
    local message = trunklateText(thePlayer, table.concat({...}, " "))
    if type(focus) == "table" then
        for player, color in pairs(focus) do
            if player == thePlayer then
                r, g, b = unpack(color)
            end
        end
    end
    --[[
    local message2 = call(getResourceFromName("language-system"), "applyLanguage", thePlayer, nearbyPlayer, message, language)
    message2 = trunklateText(nearbyPlayer, message2)
    local r, g, b = 255, 255, 255
    local focus = getElementData(nearbyPlayer, "focus")
    if type(focus) == "table" then
        for player, color in pairs(focus) do
            if player == thePlayer then
                r, g, b = unpack(color)
            end
        end
    end
    ]]--
    -- Start ext -> int comms
    local x, y, z = getElementPosition(thePlayer)
    local dimension = getElementDimension(thePlayer)
    local possibleInteriors = exports.pool:getPoolElementsByType('interior')
    for _, interior in ipairs(possibleInteriors) do
        local interiorEntrance = getElementData(interior, "entrance")
        local interiorExit = getElementData(interior, "exit")
        for _, point in ipairs( { interiorEntrance, interiorExit } ) do
            if (point.dim == dimension) then
                local distance = getDistanceBetweenPoints3D(x, y, z, point.x, point.y, point.z)
                if (distance <= outToInRadius) then
                    local dbid = getElementData(interior, "dbid")
                    local interiorName = getElementData(interior, "name")
                    local players = exports.pool:getPoolElementsByType("player")
                    for key, value in ipairs(players) do
                        local logged = getElementData(value, "loggedin")
                        if (logged==1) then
                            local dimension = getElementDimension(value)
                            local dadimension = getElementDimension(thePlayer)
                            if (dimension==dbid) and (dadimension~=dimension) then
                                local message2 = call(getResourceFromName("language-system"), "applyLanguage", thePlayer, value, message, language)
                                local message = trunklateText( thePlayer, message2 )
                                outputChatBox("["..languagename.."] " .. playerName:gsub("_", " ") .. " shouts: " .. message.."!", value, 200, 200, 200)
                            end
                        end
                    end
                end
            end
        end
    end
    -- Start int -> ext comms
    local x, y, z = getElementPosition(thePlayer)
    local dimension = getElementDimension(thePlayer)
    local possibleInteriors = exports.pool:getPoolElementsByType('interior')
    for _, interior in ipairs(possibleInteriors) do
        local interiorEntrance = getElementData(interior, "entrance")
        local interiorExit = getElementData(interior, "exit")
        for _, point in ipairs( { interiorEntrance, interiorExit } ) do
            if (point.dim == dimension) then
                local distance = getDistanceBetweenPoints3D(x, y, z, point.x, point.y, point.z)
                if (distance <= 60) and (dimension>0) then -- what is the point of this if they are outside anyways??
                    local dbid = getElementData(interior, "dbid")
                    local query = exports.mysql:query("SELECT x, y, z, dimensionwithin, interiorwithin FROM interiors WHERE id='"..dbid.."'")
                    local row = mysql:fetch_assoc(query)
                    local cx = tonumber(row["x"])
                    local cy = tonumber(row["y"])
                    local cz = tonumber(row["z"])
                    local dimensionwithin = tonumber(row["dimensionwithin"])
                    local interiorwithin = tonumber(row["interiorwithin"])
                    local interiorName = getElementData(interior, "name")
                    shoutCol = createColSphere(cx, cy, cz, inToOutRadius)
                    setElementDimension(shoutCol, dimensionwithin)
                    setElementInterior(shoutCol, interiorwithin)
                    -- Now we put the chat to the player
                    local players = exports.pool:getPoolElementsByType("player")
                    for key, value in ipairs(players) do
                        local logged = getElementData(value, "loggedin")
                        if (logged==1) then
                            local isPlayerInTheCol = isElementWithinColShape(value, shoutCol)
                            local dimension = getElementDimension(value)
                            local dadimension = getElementDimension(thePlayer)
                            if (isPlayerInTheCol) and (value~=thePlayer) and (dadimension~=dimension) then
                                local message2 = call(getResourceFromName("language-system"), "applyLanguage", thePlayer, value, message, language)
                                local message = trunklateText( thePlayer, message2 )
                                outputChatBox("["..languagename.."] " .. playerName:gsub("_", " ") .. " shouts: " .. message.."!", value, 200, 200, 200)
                            end
                        end
                    end
                    -- Okay all done trying that now delete the col because yeah...
                    destroyElement(shoutCol)
                    shoutCol = nil
                end
            end
        end
    end
end
addCommandHandler("s", interiorShout, false, false)
for i = 1, 3 do
    addCommandHandler("s" .. i, interiorShout, false, false)
end
