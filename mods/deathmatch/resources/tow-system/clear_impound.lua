local TOWING_FACTION_ID = 4
local DELETE_REASON = "Deleted by impound cleaner."
local MAXIMUM_IMPOUND_DAYS = 14
local IMPOUNDED_QUERY = [[
    SELECT vehicles.id, vehicles.model, vehicles.tokenUsed, vehicles_custom.price
        FROM vehicles
        LEFT JOIN vehicles_custom ON vehicles.id = vehicles_custom.id
        WHERE Impounded <> 0 AND (? - Impounded) > ? AND deleted = 0
]]

local function clearImpoundCallback(queryHandle)
    local impoundedVehicles = queryHandle:poll(0)
    local deletedVehiclesValue = 0

    for _, vehicle in pairs(impoundedVehicles) do
        deletedVehiclesValue = deletedVehiclesValue + exports['carshop-system']:getVehiclePriceFromTable(vehicle)
        exports.vehicle_manager:systemDeleteVehicle(vehicle.id, DELETE_REASON)
    end

    if deletedVehiclesValue > 0 then
        local faction = exports.factions:getFactionFromID(TOWING_FACTION_ID)
        if exports.bank:giveBankMoney(faction, deletedVehiclesValue) then
            exports.bank:addBankTransactionLog(nil, -TOWING_FACTION_ID, deletedVehiclesValue, 16, "Impound vehicles sold.")
            exports.logs:dbLog("SYSTEM", 25, {faction}, "$"..exports.global:formatMoney(deletedVehiclesValue).." Impound vehicles sold by inactivity scanner")
        end
    end
end

function clearImpound()
    local connection = exports.mysql:getConn()
    local dayOfYear = getRealTime().yearday

    connection:query(clearImpoundCallback, IMPOUNDED_QUERY, dayOfYear, MAXIMUM_IMPOUND_DAYS)
end
