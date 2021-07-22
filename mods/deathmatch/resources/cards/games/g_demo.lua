-- cards in a typical deck
local colors = { { utf8.char(9824), 's', 'Spades' }, { utf8.char(9829), 'h', 'Hearts' } }
local values = { 'J', 'K', 'Q' }

-- build the deck
local deck = { cards = {} }
for _, color in ipairs(colors) do
    for _, value in ipairs(values) do
        table.insert(deck.cards, { label = value .. color[1], image = value:lower() .. color[2] })
    end
end

decks['demo'] = deck
