function createGunNote(weapon, calibre, x, y, z, multiple, count)
    if not multiple then
        giveItem(client, 271, calibre.." casing")
        local itemExists, itemID, itemValue = hasItem(client, 271, calibre.." casing")
        if itemID then
            triggerEvent("dropItem", client, itemID, x, y, z, false, false, true)
        end
    elseif multiple then
        giveItem(client, 271, tostring(count).." casings of " ..calibre)
        local itemExists, itemID, itemValue = hasItem(client, 271, tostring(count).." casings of " ..calibre)
        if itemID then
            triggerEvent("dropItem", client, itemID, x, y, z, false, false, true)
        end
    end
end
addEvent("item-system:dropGunNote", true)
addEventHandler( "item-system:dropGunNote", root, createGunNote)

-- Called from payday
function startOldCasingsCheck()
    local connection = exports.mysql:getConn("mta")
    dbQuery(checkOldCasings, connection, "SELECT id FROM `worlditems` WHERE itemid=271 AND protected=0 AND creationdate IS NOT NULL AND DATEDIFF(NOW(), creationdate) > 7")
end
addEvent("item-system:shellcasings", false)
addEventHandler("item-system:shellcasings", root, startOldCasingsCheck)

function checkOldCasings(query)
    local connection = exports.mysql:getConn("mta")
    local objectsTable = {}
    
    local pollResult = dbPoll(query, 0)
    if not pollResult then 
        dbFree(query) 
    else
        for index, value in ipairs(pollResult) do
            local id = value["id"]
            local theObject = exports.pool:getElement("object", tonumber(id))
            if (theObject) then
                destroyElement(theObject)
            end
        end

        -- Blanket query to remove all results from the previous query
        dbExec(connection, "DELETE FROM `worlditems` WHERE itemid=271 AND protected=0 AND creationdate IS NOT NULL AND DATEDIFF(NOW(), creationdate) > 7")
    end
end
