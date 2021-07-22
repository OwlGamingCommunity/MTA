-- cards in a typical deck
local colors = {
    { utf8.char(9824), 's', 'Spades' },
    { utf8.char(9829), 'h', 'Hearts' },
    { utf8.char(9830), 'd', 'Diamonds' },
    { utf8.char(9827), 'c', 'Clubs' }
}
local values = { '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A' }

-- build the deck
local deck = { cards = {} }
for _, color in ipairs(colors) do
    for _, value in ipairs(values) do
        table.insert(deck.cards, { label = value .. color[1], image = value:lower() .. color[2] })
    end
end

-- card decks with item value 1 use this deck.
decks[1] = deck

-- in case no deck for the given item value exists, we also use this deck.
decks['default'] = deck
