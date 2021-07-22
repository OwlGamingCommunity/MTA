local session

function setupSession(session_data)
    -- players
    -- host
    -- seats

    session = session_data
    rebuildGUI()

    setElementData(localPlayer, "cards:host", session.host == localPlayer, false)
end

addEvent("cards:setup_session", true)
addEventHandler("cards:setup_session", resourceRoot, setupSession)

function closeSession()
    outputDebugString("Session closed")
    session = nil
    destroyGUI()

    setElementData(localPlayer, "cards:host", false, false)
end

addEvent("cards:session_closed", true)
addEventHandler("cards:session_closed", resourceRoot, closeSession)
addEventHandler("account:character:select", localPlayer, closeSession)

function playerJoin(player, seat)
    session.players[player] = {}

    table.insert(session.seats, { seat, player })
    -- rebuild the whole seating layout
    rebuildGUI()
end

addEvent("cards:player_join_session", true)
addEventHandler("cards:player_join_session", resourceRoot, playerJoin)

function playerQuit(player, new_seat_assignments)
    if player == localPlayer then
        closeSession()
    else
        session.seats = new_seat_assignments

        -- show current on-hands cards.
        if session.host == localPlayer then
            local text = getPlayerName(player):gsub("_", " ") .. " left the card game."
            if #session.players[player] > 0 then
                text = text .. " Cards:"
                for _, card in ipairs(session.players[player]) do
                    text = text .. " " .. card.card.label
                end
                text = text .. "."
            end
            outputChatBox("(( " .. text .. " ))", 255, 255, 0)
        end

        -- rebuild the whole seating layout
        rebuildGUI()
    end
end

addEvent("cards:player_left_session", true)
addEventHandler("cards:player_left_session", resourceRoot, playerQuit)

addEventHandler("onClientResourceStop", resourceRoot, function()
    setElementData(localPlayer, "cards:host", false, false)
end)

--
-- GUI
--
local screenWidth, screenHeight = guiGetScreenSize()
local menu_width = 110

local card_width, card_height = 100 / 2, 145 / 2
local card_padding = 10
local name_width = 200
local cards_window_width = (card_width + card_padding) * MAX_CARDS + name_width + 20

local player_gui = {}

local wMenu, wCards, bDeck
function createGUI()
    destroyGUI()
    createMenuGUI()
    createCardsGUI()
end

function createMenuGUI()
    local host = session.host == localPlayer

    local height = host and 105 or 80

    local action_width = menu_width - 10

    --
    -- menu
    --

    wMenu = guiCreateWindow(screenWidth - menu_width - cards_window_width, screenHeight - height, menu_width, height, "Session", false)
    guiWindowSetMovable(wMenu, true)
    guiWindowSetSizable(wMenu, false)

    -- actions
    local x = 5
    local y = 25
    if host then
        local bNew = guiCreateButton(x, y, action_width, 20, "New Game", false, wMenu)
        addEventHandler("onClientGUIClick", bNew, function(button, state)
            if button == "left" and state == "up" then
                triggerServerEvent("cards:new_game", resourceRoot)
                guiSetEnabled(wMenu, false)
            end
        end, false)
        y = y + 25
    end

    bDeck = guiCreateButton(x, y, action_width, 20, (host and "Shuffle" or "Deck") .. " (" .. tostring(session.deck_left) .. ")", false, wMenu)
    if host then
        addEventHandler("onClientGUIClick", bDeck, function(button, state)
            if button == "left" and state == "up" then
                triggerServerEvent("cards:shuffle", resourceRoot)
                guiSetEnabled(wMenu, false)
            end
        end, false)
    else
        guiSetEnabled(bDeck, false)
    end
    y = y + 25

    local bClose = guiCreateButton(x, y, action_width, 20, "Leave", false, wMenu)
    addEventHandler("onClientGUIClick", bClose, function(button, state)
        if button == "left" and state == "up" then
            triggerServerEvent("cards:leave_session", resourceRoot)
            guiSetEnabled(wMenu, false)
            destroyGUI()
        end
    end, false)
end

function createCardsGUI()
    local host = session.host == localPlayer
    local seats = {}
    for _, p in pairs(session.seats) do table.insert(seats, p) end
    table.sort(seats, function(a, b) return a[1] <= b[1] end)

    local height = (card_height + card_padding) * #seats + 30
    wCards = guiCreateWindow(screenWidth - cards_window_width, screenHeight - height, cards_window_width, height, "Table", false)
    guiWindowSetMovable(wCards, true)
    guiWindowSetSizable(wCards, false)

    local y = 25
    -- create the player stuffs
    for _, p in ipairs(seats) do
        local player = p[2]
        local gui = { cards = {}, player = player }

        local playerName = getPlayerName(player):gsub("_", " ")
        if player == session.host then playerName = playerName .. "\n(Dealer)" end

        local offset = -5
        if host then offset = offset + 25 end
        if player == localPlayer then offset = offset + 25 end

        local lName = guiCreateLabel(10, y, name_width, card_height - offset, playerName, false, wCards)
        guiSetFont(lName, "default-bold-small")
        guiLabelSetHorizontalAlign(lName, "center", true)
        guiLabelSetVerticalAlign(lName, "center")

        -- reveal all cards button for the local player
        if player == localPlayer then
            gui.revealAll = guiCreateButton(10, y + card_height - offset, name_width - 5, 20, "Reveal All", false, wCards)
            addEventHandler("onClientGUIClick", gui.revealAll, function(button, state)
                if button == "left" and state == "up" then
                    triggerServerEvent("cards:reveal", resourceRoot)
                end
            end, false)
            offset = offset - 25
        end

        if host then
           -- buttons to deal face up/face down cards
            gui.dealFaceUp = guiCreateButton(10, y + card_height - offset, name_width / 2 - 5, 20, "Deal Face Up", false, wCards)
            addEventHandler("onClientGUIClick", gui.dealFaceUp, function(button, state)
                if button == "left" and state == "up" then
                    triggerServerEvent("cards:deal_card", resourceRoot, player, true)
                end
            end, false)

            gui.dealFaceDown = guiCreateButton(10 + name_width / 2, y + card_height - offset, name_width / 2 - 5, 20, "Deal Face Down", false, wCards)
            addEventHandler("onClientGUIClick", gui.dealFaceDown, function(button, state)
                if button == "left" and state == "up" then
                    triggerServerEvent("cards:deal_card", resourceRoot, player, false)
                end
            end, false)
        end

        -- card placeholders
        for i = 1, MAX_CARDS do
            local x = name_width + 20 + (i - 1) * (card_width + card_padding)

            local image = guiCreateStaticImage(x, y, card_width, card_height, "assets/transparent.png", false, wCards)
            guiSetEnabled(image, false)

            local reveal = guiCreateButton(x - 2, y + card_height - 18, card_width + 4, 20, "Reveal", false, wCards)
            addEventHandler("onClientGUIClick", reveal, function(button, state)
                if button == "left" and state == "up" then
                    triggerServerEvent("cards:reveal", resourceRoot, i)
                end
            end, false)
            guiSetVisible(reveal, false)

            gui.cards[i] = { image = image, reveal = reveal }
        end

        -- save the gui elements
        player_gui[player] = gui

        -- draw cards if we have any
        redrawCards(player)

        y = y + card_height + 10
    end
end

function destroyGUI()
    if wMenu then
        destroyElement(wMenu)
        wMenu = nil
    end

    if wCards then
        destroyElement(wCards)
        wCards = nil
    end
end

function rebuildGUI()
    destroyGUI()
    createGUI()
end

---
function redrawCards(player)
    if not player_gui[player] then return end
    local gui = player_gui[player]
    local count = 0
    local can_reveal_any = false
    for i = 1, MAX_CARDS do
        local card = session.players[player][i]
        local item = gui.cards[i]
        if card then
            count = count + 1
            if player == localPlayer or card.shown then
                guiStaticImageLoadImage(item.image, "assets/cards/" .. card.card.image .. ".png")
            else
                guiStaticImageLoadImage(item.image, "assets/cards/back.png")
            end
            guiSetVisible(item.reveal, player == localPlayer and not card.shown)
            can_reveal_any = can_reveal_any or (player == localPlayer and not card.shown)
        else
            guiStaticImageLoadImage(item.image, "assets/transparent.png")
            guiSetVisible(item.reveal, false)
        end
    end

    if session.host == localPlayer then
        guiSetEnabled(gui.dealFaceUp, count < MAX_CARDS)
        guiSetEnabled(gui.dealFaceDown, count < MAX_CARDS)
    end
    if gui.revealAll then
        guiSetVisible(gui.revealAll, can_reveal_any)
    end
end

addEvent("cards:dealt_card", true)
addEventHandler("cards:dealt_card", resourceRoot, function(player, card, deck_left)
    session.deck_left = deck_left
    guiSetText(bDeck, (session.host == localPlayer and "Shuffle" or "Deck") .. " (" .. tostring(session.deck_left) .. ")")

    table.insert(session.players[player], card)
    redrawCards(player)
end)

function updateHand(player, cards)
    session.players[player] = cards
    redrawCards(player)
end

addEvent("cards:update_hand", true)
addEventHandler("cards:update_hand", resourceRoot, updateHand)

addEvent("cards:started_new_game", true)
addEventHandler("cards:started_new_game", resourceRoot, function()
    for player, _ in pairs(session.players) do
        session.players[player] = {}
        redrawCards(player)
    end
    guiSetEnabled(wMenu, true)
end)

addEvent("cards:shuffled", true)
addEventHandler("cards:shuffled", resourceRoot, function(deck_left)
    session.deck_left = deck_left
    guiSetText(bDeck, (session.host == localPlayer and "Shuffle" or "Deck") .. " (" .. tostring(session.deck_left) .. ")")
    guiSetEnabled(wMenu, true)
end)
