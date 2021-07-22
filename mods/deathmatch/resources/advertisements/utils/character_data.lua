function getAccountIdFromCharacter(characterId)
    local player = exports.global:getPlayerFromCharacterID(characterId)
    if player then
        return player:getData("account:id")
    end

    local handle = exports.mysql:getConn('mta'):query("SELECT account FROM characters WHERE id = ?", characterId)
    local results = handle:poll(1000)

    if type(results) == 'table' and #results == 1 then
        return results[1].account
    end

    return nil
end