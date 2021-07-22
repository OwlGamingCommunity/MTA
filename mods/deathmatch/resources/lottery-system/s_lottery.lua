mysql = exports.mysql

local lotteryNumber = 0
local lotteryJackpot = 0

function loadJackpot( )
	local result = mysql:query_fetch_assoc( "SELECT value FROM settings WHERE name = 'lottery'" )
	if not result or not result.value then
		mysql:query_free( "INSERT INTO settings (name, value) VALUES ('lottery', 0)" )
		lotteryJackpot = 0
	else
		lotteryJackpot = tonumber( result.value ) or 0
		if lotteryJackpot < 0 then
			lotteryJackpot = 0
		end
	end

	local result = mysql:query_fetch_assoc( "SELECT value FROM settings WHERE name = 'lotteryNumber'" )
	if not result or not result.value then
		lotteryNumber = math.random(2, 48)
		mysql:query_free( "INSERT INTO settings (name, value) VALUES ('lotteryNumber', " .. lotteryNumber.. ")" )
	else
		lotteryNumber = tonumber( result.value )
	end
end
addEventHandler( "onResourceStart", resourceRoot, loadJackpot )


function getLotteryJackpot()
	return lotteryJackpot
end

function updateLotteryJackpot(updatedJackpot)
	lotteryJackpot = updatedJackpot
	mysql:query_free("UPDATE settings SET value = " .. updatedJackpot .. " WHERE name = 'lottery'" )
end

function getLotteryNumber()
	return lotteryNumber
end

function lotteryDraw()
	exports['item-system']:deleteAll(68)

	for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
		if (getElementData(value, "loggedin")==1) then
			outputChatBox("[NEWS] The lottery was drawn! Number: " .. lotteryNumber .. ". Don't forget to purchase your lottery tickets!", value, 200, 100, 200)
			--exports['global']:giveMoney(getTeamFromName("San Andreas News Network"), 10) -- wtf, why did they even get money?
		end
	end

	lotteryNumber = math.random(2,48) -- Pick a random number for the lottery between 2 and 48
	mysql:query_free("UPDATE settings SET value = " .. lotteryNumber .. " WHERE name = 'lotteryNumber'" )

	updateLotteryJackpot(0)
end
--addEventHandler("onResourceStart", getResourceRootElement(), lotteryDraw)
setTimer(lotteryDraw, 86400000, 0) -- Lottery draw every 24 hours
--setTimer(lotteryDraw, 3600000, 0) -- Lottery draw every hour

function lotteryCheckJackpot(thePlayer, commandName)
	if getLotteryJackpot() == -1 then
		outputChatBox( "Sorry, someone already won the lottery.", thePlayer, 255, 0, 0 )
	else
		outputChatBox( "Current Lottery Jackpot: $" .. getLotteryJackpot(), thePlayer, 0, 255, 0 )
	end
end
addCommandHandler("checkjackpot", lotteryCheckJackpot, false, false)

function lotteryCheckNumber(thePlayer, commandName)
	if getLotteryJackpot() == -1 then
		outputChatBox( "Sorry, someone already won the lottery.", thePlayer, 255, 0, 0 )
	else
		outputChatBox("Current Lottery Number: " .. lotteryNumber, thePlayer, 0, 255, 0)
	end
end
addCommandHandler("checknumber", lotteryCheckNumber, false, false)

--The following codes are to prevent buying too many tickets in a short period of time to whore money - Maxime
local ticketBuyers = {}
local cooldown = 20 -- minutes
function canThisPlayerBuyTicket(theBuyer)
	if theBuyer and isElement(theBuyer) and getElementType(theBuyer) == "player" then
		local accountID = getElementType(theBuyer, "account:id")
		if ticketBuyers[accountID] then
			return false
		else
			ticketBuyers[accountID] = true
			setTimer(function()
				ticketBuyers[accountID] = nil
			end, cooldown*1000*60, 1) --
			return true
		end
	end
end