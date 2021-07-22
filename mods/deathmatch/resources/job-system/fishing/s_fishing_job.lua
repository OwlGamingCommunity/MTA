local items = exports['item-system']
local fishItem = 273
local FishType = {
    [1] = {fishname = "Chinese Mitten Crab", fishweight = 0.5, zone = 1},
    [2] = {fishname = "Starry Flounder", fishweight = 11, zone = 1},
    [3] = {fishname = "San Andreas Freshwater Shrimp", fishweight = 1, zone = 1},
    [4] = {fishname = "Pacific Lamprey", fishweight = 0.6, zone = 1},
    [5] = {fishname = "Western Brook Lamprey", fishweight = 0.1, zone = 1},
    [6] = {fishname = "White Sturgeon", fishweight = 99, zone = 1},
    [7] = {fishname = "American Shad", fishweight = 6, zone = 1},
    [8] = {fishname = "Chinook Salmon", fishweight = 74, zone = 1},
    [9] = {fishname = "Pink Salmon", fishweight = 8, zone = 1},
    [10] = {fishname = "Rainbow Trout", fishweight = 26, zone = 1},
    [11] = {fishname = "Striped Bass", fishweight = 68, zone = 1},
    [12] = {fishname = "Blue Catfish", fishweight = 81, zone = 1},
    [13] = {fishname = "Albacore", fishweight = 72, zone = 2},
    [14] = {fishname = "Skipjack Tuna", fishweight = 41, zone = 2},
    [15] = {fishname = "Mackerel Tuna", fishweight = 15, zone = 2},
    [16] = {fishname = "Atlantic Salmon", fishweight = 101, zone = 2},
    [17] = {fishname = "Chinook Salmon", fishweight = 134, zone = 2},
    [18] = {fishname = "Black Sea Bass", fishweight = 5, zone = 2},
    [19] = {fishname = "Sheepshead", fishweight = 25, zone = 2},
    [20] = {fishname = "Scup", fishweight = 4, zone = 2},
    [21] = {fishname = "Marbled Electric Ray", fishweight = 3, zone = 2},
    [22] = {fishname = "Atlantic Spadefish", fishweight = 19, zone = 2},
    [23] = {fishname = "Red Drum", fishweight = 55, zone = 2},
}

function giveCatch(ThePlayer)
    local x, y, z = getElementPosition(ThePlayer)
    local keyset = {}
    
    if ( y >= 3000 ) or ( y <= -3000 ) or ( x >= 3000 ) or ( x <= -3000) then
        whichZone = 2
    else 
        whichZone = 1
    end

    for i, v in ipairs(FishType) do
        if (v.zone == whichZone) then
            table.insert(keyset, i)
        end
    end

    ourFish = FishType[math.random(#keyset)] 

    if items:hasSpaceForItem(ThePlayer, fishItem, 1) then
        items:giveItem(ThePlayer, fishItem, tostring(ourFish.fishname) .. ":" .. tostring(ourFish.fishweight))
        outputChatBox("You've caught a " .. tostring(ourFish.fishname) .. "!", ThePlayer, 0, 255, 0)
    end
end

-- Added this function due to item system not allowing items to be taken clientside.
function takeRod(ThePlayer)
    items:takeItem(ThePlayer, 49, 1)
end

function getPayRate(client, money)
	local hours = tonumber(getElementData(client, "hoursplayed"))
	local rate = money
	local hoursrate = math.floor(hours*(rate*0.03))

	if hours>=10 then
		rate = rate-hoursrate
		if rate < 10 then
			rate = 10
		end
	end
    return rate
end

function GenerateFishPayment(ThePlayer)
    local fishininventory = items:countItems(ThePlayer, fishItem)
    local fishCount = 0
    local perFishCost = 0
    local calculate = 0
    local fishPrice = 0

    if (fishininventory == 0) then
        return exports.global:sendLocalText(ThePlayer, "[English] Fisherman John says: I can't buy thin air, you need to catch some fish bro.", 255, 255, 255, 10)
    end

    -- Checks their inventory for the fish items.

    for i, v in ipairs(items:getItems(ThePlayer)) do
        local ItemID, ItemValue = unpack(v)
        if ItemID == fishItem then
            fishCount = fishCount + 1
        end
    end

    --Generate a price 
    local perFishCost = math.random(20, 80)
    local calculate = perFishCost * fishCount
    local fishPrice = calculate

    fishPrice = getPayRate(ThePlayer, fishPrice)

    triggerClientEvent(ThePlayer, "fishing:SellFishGUI", ThePlayer, fishCount, fishPrice)
end

function sellTheFish(ThePlayer, price)
    for i, v in ipairs(items:getItems(ThePlayer)) do
        local ItemID, ItemValue = unpack(v)
        if ItemID == fishItem then
            items:takeItem(ThePlayer, fishItem)
        end
    end
    exports.global:sendLocalText(ThePlayer, "[English] Fisherman John says: Thanks for the fish, heres some cash!", 255, 255, 255, 10)
    exports.global:giveMoney(ThePlayer, price)
end

-- Commands and Events
addEvent("fishing:giveCatch", true)
addEvent("fishing:takeRod", true)
addEvent("fishing:GeneratePayment", true)
addEvent("fishing:sellFish", true)
addEventHandler("fishing:giveCatch", root, giveCatch)
addEventHandler("fishing:takeRod", root, takeRod)
addEventHandler("fishing:GeneratePayment", root, GenerateFishPayment)
addEventHandler("fishing:sellFish", root, sellTheFish)
