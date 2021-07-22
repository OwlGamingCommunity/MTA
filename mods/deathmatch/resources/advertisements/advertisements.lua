local RESULTS_PER_PAGE = 10
local SAN_FACTION_ID = 20
local COOLDOWN_MINUTES = 5
local coolDown = {}
local lastExpiryCheck = 0

local function getSectionFromName(section)
    local sections = {"Services", "Vehicles", "Real Estate", "Community", "Jobs", "Personals"}

    for sectionId, sectionName in ipairs(sections) do
        if section == sectionName then
            return sectionId
        end
    end

    return nil
end

function parseExpiryToSeconds(expiry)
    return 60 * 60 * expiry
end

local function now()
	return tonumber(getRealTime().timestamp)
end

local function checkForExpiredAdvertisements()
    if now() - lastExpiryCheck < (60 * COOLDOWN_MINUTES) then -- we'll only run deletes every 5 minutes.
        return
    end

    lastExpiryCheck = now()

    exports.mysql:getConn('mta'):exec('DELETE FROM advertisements WHERE expiry < ?', now())
end

local function canManageAdvertisement(player, advertisement)
    if exports.integration:isPlayerTrialAdmin(player) then
        return true
    end

    if getElementData(player, 'dbid') == advertisement.created_by then
        return true
    end

    local factionId = tonumber(advertisement.faction) or 0

    return factionId > 0 and exports.factions:isPlayerInFaction(player, factionId)
end

function createAdvertisement(sender, advertisement, onComplete)
    local handle = exports.mysql:getConn('mta'):query(
        function (handle, sender)
            local _, _, lastInsertId = handle:poll(0)

            onComplete(sender, lastInsertId)
        end,
        {sender},
        "INSERT INTO advertisements (advertisement, name, section, phone, address, start, expiry, created_by, faction) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        advertisement.advertisement,
        advertisement.name,
        getSectionFromName(advertisement.section),
        advertisement.phone,
        advertisement.address,
        advertisement.start,
        advertisement.expiry,
        tonumber(getElementData(sender, "dbid")),
        advertisement.faction
    )
end

local function updateAdvertisement(sender, advertisement, onComplete)
    exports.mysql:getConn('mta'):query(function (handle, sender)
        local result = handle:poll(0)

        if not canManageAdvertisement(sender, result[1]) then
            return
        end

        exports.mysql:getConn('mta'):exec(
            "UPDATE advertisements SET advertisement = ?, name = ?, section = ?, phone = ?, address = ?, start = ?, expiry = ?, faction = ? WHERE id = ?",
            advertisement.advertisement,
            advertisement.name,
            getSectionFromName(advertisement.section),
            advertisement.phone,
            advertisement.address,
            advertisement.start,
            advertisement.expiry,
            advertisement.faction,
            advertisement.id
        )

        onComplete(sender, advertisement.id)
    end, {sender}, "SELECT * FROM advertisements WHERE id = ?", advertisement.id)
end

addEvent('advertisements:fetch-page', true)
addEventHandler('advertisements:fetch-page', root, function (page, section)
    checkForExpiredAdvertisements()

    local receiver = client or source
    page = page or 1

    local query = IndexQuery()
        :from('advertisements')
        :setPerPage(RESULTS_PER_PAGE)
        :setPage(page)
        :orderBy('start', 'desc')

    if type(section) == 'string' and section ~= 'nil' and getSectionFromName(section) ~= nil then
        query:where('section', getSectionFromName(section))
    end

    local totalPages = query:getPageCount()

    query:exec(function (handle, receiver)
        local results = handle:poll(0)

        triggerClientEvent(receiver, 'advertisements:receive-page', receiver, results, page, totalPages)
    end, receiver)
end)

addEvent('advertisements:fetch-single', true)
addEventHandler('advertisements:fetch-single', root, function (id)
    local receiver = client or source
    exports.mysql:getConn('mta'):query(function (handle, receiver)
        local result = handle:poll(0)

        triggerClientEvent(receiver, 'advertisements:receive-single', receiver, result[1]) -- todo: handle not found id.
    end, {receiver}, [[
        SELECT advertisements.*, characters.charactername, factions.name as faction_name
        FROM advertisements
        JOIN characters ON characters.id = advertisements.created_by
        LEFT JOIN factions ON factions.id = advertisements.faction
        WHERE advertisements.id = ?
    ]], id)
end)

addEvent('advertisements:post-advertisement', true)
addEventHandler('advertisements:post-advertisement', root, function (advertisement)
    advertisement.start = getRealTime().timestamp
    advertisement.expiry = advertisement.start + parseExpiryToSeconds(advertisement.expiry)

    local onComplete = function (sender, advertisementId)
        triggerEvent('advertisements:fetch-single', sender, advertisementId)
    end

    if (advertisement.id) then
        updateAdvertisement(client, advertisement, onComplete)
    else
        createAdvertisement(client, advertisement, onComplete)
    end
end)

local function transferBankFunds(player, advertisement)
    local factionId = tonumber(advertisement.faction) or 0

    -- I've made this return false so that adverts that admins push don't charge the admin
    if getElementData(player, 'dbid') ~= advertisement.created_by then
        return false
    end

    if factionId > 0 then
        if not exports.bank:takeBankMoney(exports.factions:getFactionFromID(factionId), 100) then
            triggerClientEvent(player, 'advertisements:push-insufficient-funds', player, true)
            return false
        end

        exports.bank:giveBankMoney(exports.factions:getFactionFromID(SAN_FACTION_ID), 100)
        exports.bank:addBankTransactionLog(-factionId, -SAN_FACTION_ID, 100, 2, "Advertisement Income")

        return true
    end

    if not exports.bank:takeBankMoney(player, 100) then
        triggerClientEvent(player, 'advertisements:push-insufficient-funds', player)
        return false
    end

    exports.bank:giveBankMoney(exports.factions:getFactionFromID(SAN_FACTION_ID), 100)
    exports.bank:addBankTransactionLog(getElementData(player, "dbid"), -SAN_FACTION_ID, 100, 2, "Advertisement Income")

    return true
end

local function parseAdvertisementText(player, advertisement)
    local text = "ADVERT: " .. advertisement.advertisement

    if #advertisement.phone > 0 and advertisement.phone ~= "N/A" and advertisement.phone ~= " " and advertisement.phone ~= "0" then
        text = string.format("%s | #%s", text, advertisement.phone)
    end

    if exports.integration:isPlayerTrialAdmin(player) then
        text = string.format("%s (( %s ))", text, advertisement.charactername:gsub("_", " "))
    end

    return text
end

addEvent('advertisements:push', true)
addEventHandler('advertisements:push', root, function (id)
    if coolDown[id] and coolDown[id] >= now() - (60 * COOLDOWN_MINUTES) then
        triggerClientEvent(client, 'advertisements:push-cooldown', client)
        return
    end

    exports.mysql:getConn('mta'):query(
        function (handle, sender)
            local result = handle:poll(0)
            if not result or not result[1] then return end

            if not canManageAdvertisement(sender, result[1]) then
                return
            end

            if not (transferBankFunds(sender, result[1]) or exports.integration:isPlayerTrialAdmin(sender)) then
                return
            end

            coolDown[id] = now()
            for _, player in pairs(getElementsByType('player')) do
                local hasTogAd, togAdState = exports.donators:hasPlayerPerk(player, 2)
                if getElementData(player, 'loggedin') == 1 and (not hasTogAd or tonumber(togAdState) ~= 1) then
                    outputChatBox(parseAdvertisementText(player, result[1]), player, 0, 255, 0)
                end
            end
        end,
        {client},
        'SELECT advertisements.*, characters.charactername FROM advertisements JOIN characters ON characters.id = advertisements.created_by WHERE advertisements.id = ?',
        id
    )
end)

addEvent('advertisements:delete', true)
addEventHandler('advertisements:delete', root, function (id)
    exports.mysql:getConn('mta'):query(function (handle, sender)
        local result = handle:poll(0)

        if not canManageAdvertisement(sender, result[1]) then
            return
        end

        exports.mysql:getConn('mta'):exec('DELETE FROM advertisements WHERE id = ?', result[1].id)

        triggerEvent('advertisements:fetch-page', sender) -- return user to home page.

    end, {client}, "SELECT * FROM advertisements WHERE id = ?", id)
end)

