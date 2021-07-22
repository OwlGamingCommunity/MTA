local DATE = 23
local SPONSORS = {
	"Howard for CC!",
	"Los Santos Pawn®",
	"Covington Trucking LLC, Transporting Specialists Based In Blueberry",
	"Last Drop Logistics, Safe, Professional and Secure",
	"Rationalist Homeland Workers Party",
	"RSR Corp"
}

-- spawn bunny at Verona Mall
addEventHandler("onResourceStart", resourceRoot, function()
	local bunny = createPed(245, 1127.5828857422, -1443.3576660156, 15.798126220703)
	exports.anticheat:changeProtectedElementDataEx(bunny, "nametag", true)
	exports.anticheat:changeProtectedElementDataEx(bunny, "name", "Easter Bunny")
	setElementData(bunny, "rpp.npc.type", "easter")
	setElementFrozen(bunny, true)
end)

-- create colshapes around eggs
addEventHandler("onColShapeHit", resourceRoot, function(thePlayer)
	if getElementData(source, "easterColShape") then
		local currentCount = getElementData(thePlayer, "easter:egg") or 0

		outputChatBox("You have found an easter egg! You now have "..tonumber(currentCount + 1).." eggs. Exchange it at Verona Mall!", thePlayer)
		outputChatBox("WARNING: This special events does not save egg counts. Exchange them before logging off!", thePlayer, 255, 0, 0)
		setElementData(thePlayer, "easter:egg", currentCount+1)
		destroyElement(getElementData(source, "eggElement"))
		destroyElement(source)
	end
end)

-- MAKE SURE TO DISABLE LOTTERY SYSTEM
-- give chocolate and ticket
function exchange(ped)
	local eggCount = getElementData(client, "easter:egg")
	
	if not eggCount then
		eggCount = 0
	end

	if eggCount >= 1 then
		exports.global:sendLocalText(ped, " * Easter Bunny checks the eggs "..string.gsub(getPlayerName(client), "_", " ").." is offering.", 255, 51, 102)
		exports.global:sendLocalText(ped, "[English] Easter Bunny says: Here's your chocolate and tickets for our grand prize next week!", 255, 255, 255, 10)
		outputChatBox("You have been given "..eggCount.." chocolates and tickets. After the " .. DATE .. "rd of April, come back to this Bunny to redeem your lottery ticket if you won.", client)
		local file = fileOpen("easter/lottery.txt")

		removeElementData(client, "easter:egg") -- remove the eggs
		for i=1, eggCount do
			exports.global:giveItem(client, 89, "A delicious easter bunny chocolate.")

			local lotteryNumber = tostring(math.random(10000,99999))
			exports.global:giveItem(client, 68, lotteryNumber)
			fileSetPos(file, fileGetSize(file))
			fileWrite(file, lotteryNumber.."\r\n")
		end
		fileClose(file)
		exports.global:sendLocalText(ped, "[English] Easter Bunny says: This years event was sponsored by " .. SPONSORS[math.random(1, 6)] .. ".", 255, 255, 255, 10)
	else
		exports.global:sendLocalText(ped, "[English] Easter Bunny says: If you want some chocolate, I want my eggs!", 255, 255, 255, 10)
	end
end
addEvent("easter:exchange", true)
addEventHandler("easter:exchange", root, exchange)

-- Change these winners every year based on the file
local winners = {77110, 69701, 93306, 48060, 82892}
local prizeMoney = 7500 -- $$
function redeem(ped)
	local realTime = getRealTime()

	if realTime.monthday <= DATE then 
		return exports.global:sendLocalText(ped, "[English] Easter Bunny says: Sorry my friend, its not time to redeem! Come back on the " .. DATE .. "rd.", 255, 255, 255, 10)	
	end

	local win = false

	for k, v in pairs(winners) do
		if exports.global:hasItem(client, 68, v) then
			win = true
			winners[k] = nil
			exports.global:takeItem(client, 68, v)
			break
		end
	end

	exports.global:sendLocalText(ped, " * Easter Bunny checks the tickets "..string.gsub(getPlayerName(client), "_", " ").." is presenting.", 255, 51, 102)
	if win then
		exports.global:sendLocalText(ped, "[English] Easter Bunny says: CONGRATULATIONS, BUNNY BUDDY! Here's your prize!", 255, 255, 255, 10)	
		exports.global:giveMoney(client, prizeMoney)
	else
		exports.global:sendLocalText(ped, "[English] Easter Bunny says: Sorry my friend, you are not a winner!", 255, 255, 255, 10)	
	end
end
addEvent("easter:redeem", true)
addEventHandler("easter:redeem", root, redeem)