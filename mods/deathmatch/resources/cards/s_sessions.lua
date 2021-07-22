-- manage all playing card "sessions"
-- a session, for where this script is concerned, is play session with a single host and multiple participatns.
local sessions = {}
local joined_seat_ids = 0

local function triggerSessionEvent(session, eventName, ...)
    for player, _ in pairs(session.players) do
        triggerClientEvent(player, eventName, ...)
    end
end

-- remove the player from any active session
function leaveSession(player)
    local session = sessions[player]
    if not session then return end

    if session.host == player then
        triggerSessionEvent(session, "cards:session_closed", resourceRoot)

        for p, _ in pairs(session.players) do
            sessions[p] = nil
        end

        triggerEvent("sendAme", player, "packs their " .. session.item.name .. " away.", 255, 51, 102)
    else
        session.players[player] = nil
        session.seats[player] = nil

        sessions[player] = nil

        triggerSessionEvent(session, "cards:player_left_session", resourceRoot, player, session.seats)
    end
end

addEvent("cards:leave_session", true)
addEventHandler("cards:leave_session", root, function() leaveSession(client or source) end)
addEventHandler("onPlayerQuit", root, function() leaveSession(source) end)

-- we only care if the player dropped his last card deck of that kind
addEvent("cards:leave_session_if_host")
addEventHandler("cards:leave_session_if_host", root, function(itemValue)
    local session = sessions[source]
    if session and session.host == source and session.item.value == (itemValue or 1) then
        leaveSession(source)
    end
end)

-- join an existing session
function joinSession(player, host)
    leaveSession(player)

    local session = sessions[host]
    if not session then
        return false, "player is not hosting a session"
    end

    -- assign a seat; we never decrease this though -- eventually that doesn't matter unless you play millions of games
    joined_seat_ids = joined_seat_ids + 1
    session.seats[player] = { joined_seat_ids, player }

    -- send all current players a notification the player joined
    triggerSessionEvent(session, "cards:player_join_session", resourceRoot, player, joined_seat_ids)

    -- empty hand
    session.players[player] = {}

    -- sync current game state
    sessions[player] = session
    triggerClientEvent(player, "cards:setup_session", resourceRoot, { players = session.players, host = host, seats = session.seats, deck_left = session.deck_left })
    return true
end
addEvent("cards:invite_player", true)
addEventHandler("cards:invite_player", root, function(playerToInvite)
    client = client or source
    if not isElement(playerToInvite) then return end

    -- are we hosting the session?
    local session = sessions[client]
    if not session or session.host ~= client then return end

    if not sessions[playerToInvite] then
        if joinSession(playerToInvite, client) then
            -- sucessfully joined
        else
            outputChatBox("Unable to invite " .. getPlayerName(playerToInvite):gsub("_", " ") .. ".", client, 255, 0, 0)
        end
    else
        outputChatBox(getPlayerName(playerToInvite):gsub("_", " ") .. " is already playing.", client, 255, 0, 0)
    end
end)

-- player clicked on a card deck
function openCardDeck(player, itemValue, itemName)
    leaveSession(player)

    itemName = itemName or "card deck"
    itemValue = itemValue or 1

    triggerEvent("sendAme", player, "opens their " .. itemName .. ".", 255, 51, 102)

    local session = {
        host = player,
        item = { name = itemName, value = itemValue },

        -- players each have a hand
        players = { [player] = {} },

        -- seating order for players: cards on the table, then host always sits first
        seats = {
            [player] = { -1, player }
        },
        deck_count = math.max(1, exports['item-system']:countItems(player, 77, itemValue)),
        game = decks[itemValue] or decks['default']
    }
    shuffleCards(session)

    sessions[player] = session

    -- sync initial card state
    triggerClientEvent(player, "cards:setup_session", resourceRoot, { players = session.players, host = player, seats = session.seats, deck_left = session.deck_left })
end

-- shuffle a card deck
function shuffleCards(session)
    local deck_count = session.deck_count
    local deck = {}

    -- make sure we're not adding any cards that are actually still in play (realism etc.)
    local cards_in_play = {}
    for _, cards in pairs(session.players) do
        for _, v in ipairs(cards) do
            local card = v.card
            cards_in_play[card] = (cards_in_play[card] or 0) + 1
        end
    end

    -- build a deck copy
    for _, card in ipairs(session.game.cards) do
        -- insert deck_count cards of this type
        for i = 1, deck_count do
            local in_play = cards_in_play[card] or 0
            if in_play > 0 then
                cards_in_play[card] = in_play - 1
            else
                cards_in_play[card] = nil
                table.insert(deck, card)
            end
        end
    end

    local shuffled_deck = {}
    while #deck > 0 do
        local id = math.random(1, #deck)
        table.insert(shuffled_deck, deck[id])
        table.remove(deck, id)
    end

    session.card_pile = shuffled_deck
    session.next_card_to_draw = 1
    session.deck_left = #session.card_pile
end

function playerShuffleCards()
    local session = sessions[client]
    if session and session.host == client then
        shuffleCards(session)

        triggerEvent("sendAme", client, "shuffles their " .. session.item.name .. ".", 255, 51, 102)
        triggerSessionEvent(session, "cards:shuffled", resourceRoot, session.deck_left)
    end
end

addEvent("cards:shuffle", true)
addEventHandler("cards:shuffle", resourceRoot, playerShuffleCards)
--
function drawCard(session)
    local deck = session.card_pile
    local card = deck[session.next_card_to_draw]
    if card then
        session.next_card_to_draw = session.next_card_to_draw + 1
        session.deck_left = session.deck_left - 1
        return card
    else
        return false, 'card deck is emtpy'
    end
end

function dealCard(dealt_to, shown)
    local session = sessions[client]
    if session and session.host == client and session.players[dealt_to] and #session.players[dealt_to] < MAX_CARDS then
        local card, error = drawCard(session)
        if card then
            table.insert(session.players[dealt_to], { card = card, shown = shown })
            triggerSessionEvent(session, "cards:dealt_card", resourceRoot, dealt_to, { card = card, shown = shown }, session.deck_left)

            local cardName = "face-down card"
            if shown then
                cardName = card.label
            end

            if dealt_to == client then
                triggerEvent("sendAme", client, "takes a " .. cardName .. ".", 255, 51, 102)
            else
                triggerEvent("sendAme", client, "deals a " .. cardName .. " to " .. getPlayerName(dealt_to):gsub("_", " ") .. ".", 255, 51, 102)
            end
        else
            outputChatBox("You deck is empty, shuffle it before dealing more cards.", client, 255, 0, 0)
        end
    end
end

addEvent("cards:deal_card", true)
addEventHandler("cards:deal_card", resourceRoot, dealCard)

--
function newGame()
    local session = sessions[client]
    if session and session.host == client then
        for player, _ in pairs(session.players) do
            session.players[player] = {}
        end

        triggerEvent("sendAme", client, "puts all cards onto the discard pile.", 255, 51, 102)
        triggerSessionEvent(session, "cards:started_new_game", resourceRoot)
    end
end

addEvent("cards:new_game", true)
addEventHandler("cards:new_game", resourceRoot, newGame)

--
function revealCard(card_no)
    local session = sessions[client]
    if session then
        local any = false
        local cards = session.players[client]

        if card_no then -- we want to show a single card
            local card = cards[card_no]
            if card and not card.shown then
                card.shown = true
                triggerEvent("sendAme", client, "reveals a " .. card.card.label .. ".", 255, 51, 102)
                triggerSessionEvent(session, "cards:update_hand", resourceRoot, client, cards)
            end
        else -- reveal all cards
            local displayed_labels = {}
            for _, card in ipairs(cards) do
                if not card.shown then
                    card.shown = true
                    any = true
                end
                table.insert(displayed_labels, card.card.label)
            end

            if any then
                triggerEvent("sendAme", client, "reveals their cards: " .. table.concat(displayed_labels, " ") .. ".", 255, 51, 102)
                triggerSessionEvent(session, "cards:update_hand", resourceRoot, client, cards)
            end
        end
    end
end

addEvent("cards:reveal", true)
addEventHandler("cards:reveal", resourceRoot, revealCard)
