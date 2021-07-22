function onlineBanking()
    local factions = getElementData(client, "faction")

    local fTable = {}    
    for k,v in pairs(factions) do
        if exports.factions:hasMemberPermissionTo(client, k, "manage_finance") then
            fTable[k] = v
        end
    end

    triggerClientEvent(client, "showBankUI", getRootElement(), fTable, false, 0, false)
end
addEvent("computers:onlineBanking", true)
addEventHandler("computers:onlineBanking", getRootElement(), onlineBanking)
