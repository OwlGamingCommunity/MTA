--    ____        __     ____  __            ____               _           __
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/
--                                 /____/                /___/
--Server side script: Special christmas season features
--Last updated 25.11.2017 by Exciter
--Copyright 2008, The Roleplay Project (www.roleplayproject.com)

--SETTINGS:
local colaTruckID = 8460 --VIN of the coke truck --16142
local colaTruckTrailerID = 8461 --VIN of the coke trailer --16138
local santaCharID = 19379 --Character ID of Santa Claus
local santaCokeID = 210 --item ID for the coke bottle item
local santaLotteryTicketID = 211 --item ID for the lottery ticket item
local maxBottlesPerPersonPerRound = 3 --maximum number of bottles one player can get from Santa per round
local santaSpawnPosition = "left" --set where santa spawn should be spawned when out of truck. Use either {offX, offY, offZ} (offset from truck), "left" (left of truck) or "right" (right of truck).
local santaSpawnRotation = false --Set a float to override rotation of santa ped. If false, script will calculate rotation to face away from truck.
local christmasLotteryPrizes = {
	--itemID,value,metadata
	{210,"1"}, --A coke bottle
	{17,"1"}, --Watch
	{10,"1"}, --Dice
	{55,"Santa Claus. 1, North Pole."}, --Business Card
	{113,"3"}, --Pack of glowsticks
	{160,"1"}, --Briefcase
	{91,"1"}, --Eggnog
	{92,"1"}, --Turkey
	{93,"1"}, --Christmas Pudding
	{94,"1"}, --Christmas Present
	{213,"1"}, --Pinnekjott
	{240, "1"}, -- Christmas Hat
}
local sponsors = {
	"Ho! Ho! Ho! This years prizes are presented in part by AutoHub - RSR Corp., where Santa buys his cars!",
	"Merry Christmas. Remember, Abu's fast food - Best food in town!",
	"Merry Christmas from Mercedes-Benz of San Andreas, the best or nothing!",
	"Here you are.. Dreaming big? Dreaming Sparta. Join now at https://spartainc.info/"
}
local debugXmas = false --debug mode true/false

--globals
local colaTruck = false
local colaTruckTrailer = false
local santa = false
local santaTimer = false
local colaDrinkers = {}

function xmasDebug(thePlayer, commandName)
	if exports.integration:isPlayerScripter(thePlayer) then
		debugXmas = not debugXmas
		outputChatBox("debugXmas set to "..tostring(debugXmas))
	end
end
addCommandHandler("debugxmas", xmasDebug)

function isItChristmas()
	local realtime = getRealTime()
	if(realtime.month == 11) then --and realtime.monthday > 21 --December
		return true
	end
	return false
end

function saySlogan()
	local slogan = math.random(1,#sponsors)
	slogan = sponsors[slogan]
	exports.global:sendLocalText(santa, "[English] Santa Claus says: " .. slogan, 255, 255, 255, 10)
end

function initiateSanta()
	if isItChristmas() then
		if debugXmas then
			outputDebugString("xmas: Yes this is christmas!")
		end
		local minWait, maxWait = 50, 80 --minutes
		local time = math.random(60000*minWait,60000*maxWait) --between 50 and 120 minutes
		santaTimer = setTimer(santaArrives, time, 1)
		if not colaTruck then
			for k,v in ipairs(getElementsByType("Vehicle")) do
				if(getElementData(v, "dbid") == colaTruckID) then
					colaTruck = v
				elseif(getElementData(v, "dbid") == colaTruckTrailerID) then
					colaTruckTrailer = v
				end
				if colaTruck and colaTruckTrailer then
					break
				end
			end
		end
		if not colaTruck then
			if debugXmas then
				outputDebugString("xmas: Cola truck not found! Cancelling christmas.")
			end
			killTimer(santaTimer)
			return
		end
		setVehicleEngineState(colaTruck, false)
		if not santa or isPedDead(santa) then
			if santa then
				destroyElement(santa)
				santa = false
			end

			santa = createPed(245, 0, 0, 0)

			--exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.type", "santa")
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.name", "Santa Claus")
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.gender", 0)
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.nametag", false)
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.behav", 0)

			--owl specifics
			exports.anticheat:changeProtectedElementDataEx(santa, "nametag", false)
			exports.anticheat:changeProtectedElementDataEx(santa, "name", "Santa Claus")

			respawnVehicle(colaTruck)
			if colaTruckTrailer then
				respawnVehicle(colaTruckTrailer)
				fixVehicle(colaTruckTrailer)
				setVehicleOverrideLights(colaTruckTrailer, 1) --off
				setElementFrozen(colaTruckTrailer,true)
			end
			setVehicleLocked(colaTruck, false)
			warpPedIntoVehicle(santa, colaTruck, 0)
			setVehicleLocked(colaTruck, true)
			setVehicleOverrideLights(colaTruck, 1) --off
			fixVehicle(colaTruck)
			setElementFrozen(colaTruck,true)
			setVehicleEngineState(colaTruck, false)
			setTimer(setVehicleEngineState, 4000, 1, colaTruck, false)
		end
		if debugXmas then
			outputDebugString("xmas: Santa will go to work in "..tostring(math.floor(time/60000)).." minutes.")
		end
		initializeDrinking()
	end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), initiateSanta)

function santaArrives()
	if debugXmas then
		outputDebugString("xmas: Santa is coming to work.")
	end
	if santaTimer then
		killTimer(santaTimer)
		santaTimer = nil
	end
	respawnVehicle(colaTruck)
	if colaTruckTrailer then
		respawnVehicle(colaTruckTrailer)
		fixVehicle(colaTruckTrailer)
		setVehicleOverrideLights(colaTruckTrailer, 2) --on
		setElementFrozen(colaTruckTrailer,true)
	end
	fixVehicle(colaTruck)
	setElementFrozen(colaTruck,true)
	setVehicleOverrideLights(colaTruck, 2) --on
	santaTimer = setTimer(santaDeparts, 120000, 1) --2 minutes
	exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.nametag", true)
	exports.anticheat:changeProtectedElementDataEx(santa, "nametag", true)
	resetBottleCounter()
	triggerClientEvent("xmas:santaSound", getRootElement(), "arrive", santa)
	setTimer(function()
		setVehicleLocked(colaTruck, true)
		if isPedInVehicle(santa) then
			setVehicleLocked(colaTruck, false)
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.type", "santa")
			removePedFromVehicle(santa)
			local offX, offY, offZ, rot = 2, 0.5, 0, false
			if type(santaSpawnPosition) == "string" then
				if santaSpawnPosition == "left" then
					offX, offY, offZ = -2, 0.5, 0
				elseif santaSpawnPosition == "right" then
					offX, offY, offZ = 2, 0.5, 0
				end
			elseif(type(santaSpawnPosition) == "table") then
				offX, offY, offZ = unpack(santaSpawnPosition)
			end
			local x, y, z = getPositionFromElementOffset(colaTruck,offX,offY,offZ)
			if santaSpawnRotation and type(santaSpawnRotation) == "number" then
				rot = santaSpawnRotation
			else
				rot = 0
				local truckX, truckY, truckZ = getElementPosition(colaTruck)
				rot = findRotation(truckX, truckY, x, y)
			end
			--setElementPosition(santa, x-0.5,y-2,z)
			--setElementRotation(santa, 0, 0, 180)
			--setElementPosition(santa, x-2,y+0.5,z)
			--setElementRotation(santa, 0, 0, 90)
			setElementPosition(santa, x, y, z)
			setElementRotation(santa, 0, 0, rot)
			setVehicleLocked(colaTruck, true)
			setTimer(setElementFrozen,3000,1,santa,true)
		end
		exports.global:applyAnimation(santa, "DANCING", "DAN_Down_A", 8000, false, true, true)
	end, 5000, 1) --5 seconds
end

function santaDeparts()
	if santaTimer then
		killTimer(santaTimer)
		santaTimer = nil
	end
	setElementFrozen(santa, false)
	triggerClientEvent("xmas:santaSound", getRootElement(), "depart", santa)
	santaTimer = setTimer(
	function()
		if not isPedInVehicle(santa) then
			setVehicleLocked(colaTruck, false)
		end
	end, 29000, 1) --29 seconds
	setTimer(function()
		setVehicleLocked(colaTruck, true)
		exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.nametag", false)
		exports.anticheat:changeProtectedElementDataEx(santa, "nametag", false)
		if not isPedInVehicle(santa) then
			if colaTruckTrailer then
				fixVehicle(colaTruckTrailer)
				setVehicleOverrideLights(colaTruckTrailer, 1) --off
			end
			setVehicleLocked(colaTruck, false)
			warpPedIntoVehicle(santa, colaTruck, 0)
			setVehicleLocked(colaTruck, true)
			setVehicleOverrideLights(colaTruck, 1) --off
			fixVehicle(colaTruck)
			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.type", false)
		end
		setVehicleEngineState(colaTruck, false)
	end, 35000, 1) --35 seconds
	initiateSanta()
end

function getPositionFromElementOffset(element, offX, offY, offZ)
	local m = getElementMatrix ( element ) -- Get the matrix
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1] -- Apply transform
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z -- Return the transformed point
end

function findRotation(x1, y1, x2, y2) 
	local t = -math.deg(math.atan2(x2 - x1, y2 - y1))
	return t < 0 and t + 360 or t
end

function doNotEnterColaTruck(thePlayer, seat, jacked, door)
	if colaTruck then
		if source == colaTruck then
			if not exports.integration:isPlayerScripter(thePlayer) and getElementData(thePlayer,"dbid") ~= santaCharID then
				outputChatBox("That truck is for santa only!",thePlayer,255,0,0)
				cancelEvent()
				if isPedInVehicle(thePlayer) then
					removePedFromVehicle(thePlayer)
				end
			else
				outputChatBox("Please don't bother santa.",thePlayer,255,0,0)
			end
		end
	end
end
addEventHandler("onVehicleStartEnter", getRootElement(), doNotEnterColaTruck)

function checkPrizeCar(thePlayer, seat, jacked)
	if(seat == 0) then
		if(tonumber(getElementData(source,"owner")) == santaCharID and getElementData(source,"faction") == -1) then --if it's santa's car
			local dbid = tonumber(getElementData(source,"dbid"))
			local hasItem, itemSlot, itemValue = exports.global:hasItem(thePlayer, 3, dbid) --has player key to the car
			if hasItem then
				if(getElementData(thePlayer,"dbid") ~= santaCharID) then
					local query = exports.mysql:query_free("UPDATE vehicles SET owner = '" .. exports.mysql:escape_string(getElementData(thePlayer, "dbid")) .. "' WHERE id='" .. exports.mysql:escape_string(dbid) .. "'")
					if query then
						exports.anticheat:changeProtectedElementDataEx(source, "owner", getElementData(thePlayer, "dbid"))
						local adminID = getElementData(thePlayer, "account:id")
						local addLog = exports.mysql:query_free("INSERT INTO `vehicle_logs` (`vehID`, `action`, `actor`) VALUES ('"..tostring(dbid).."', 'Won vehicle from Santas Christmas Lottery.', '"..adminID.."')") or false
						if not addLog then
							outputDebugString("xmas/s_xmas: Failed to add vehicle logs.")
						end
						
						local vehicleName = tostring(exports.global:getVehicleName(source))

						exports.global:sendMessageToAdmins(tostring(getPlayerName(thePlayer)).." won a "..vehicleName.." in Santa's Christmas Lottery!")

						exports['item-system']:deleteAll(3, dbid)
						exports['item-system']:giveItem(thePlayer, 3, dbid)

						outputChatBox("Congratulations! You won this "..vehicleName.." in Santa's Christmas Lottery!",thePlayer,0,255,0)
						outputChatBox("You are now the owner of this wonderful car.",thePlayer,0,255,0)
						outputChatBox("Remember to /park it!",thePlayer,0,255,0)
					end
				end
			end
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), checkPrizeCar)

function forceSanta(thePlayer, commandName)
	if(exports.integration:isPlayerScripter(thePlayer)) then
		if santa then
			outputChatBox("Forcing Santa to go to work...",thePlayer)
			santaArrives()
		else
			outputChatBox("Sorry. Santa is at the north pole!",thePlayer,255,0,0)
		end
	end
end
addCommandHandler("forcesanta", forceSanta)

function getSantaWait(thePlayer, commandName)
	if(exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerLeadAdmin(thePlayer)) then
		if santa then
			local timeLeft = getTimerDetails(santaTimer)
			outputChatBox(tostring(math.floor(timeLeft/60000)).." minutes left for Santa.",thePlayer)
		else
			outputChatBox("Sorry. Santa is at the north pole!",thePlayer,255,0,0)
		end
	end
end
addCommandHandler("howlongsanta", getSantaWait)

function fixSanta(thePlayer, commandName)
	if(exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerAdmin(thePlayer)) then
		if santa then
			if debugXmas then
				outputDebugString("xmas: Resetting Santa.")
			end
			if santaTimer then
				killTimer(santaTimer)
				santaTimer = nil
			end
			respawnVehicle(colaTruck)
			if colaTruckTrailer then
				respawnVehicle(colaTruckTrailer)
				setElementFrozen(colaTruckTrailer,true)
			end
			setElementFrozen(colaTruck,true)

			exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.nametag", false)
			exports.anticheat:changeProtectedElementDataEx(santa, "nametag", false)
			if not isPedInVehicle(santa) then
				if colaTruckTrailer then
					fixVehicle(colaTruckTrailer)
					setVehicleOverrideLights(colaTruckTrailer, 1) --off
				end
				setVehicleLocked(colaTruck, false)
				warpPedIntoVehicle(santa, colaTruck, 0)
				setVehicleLocked(colaTruck, true)
				setVehicleOverrideLights(colaTruck, 1) --off
				fixVehicle(colaTruck)
				exports.anticheat:changeProtectedElementDataEx(santa, "rpp.npc.type", false)
			end
			setVehicleEngineState(colaTruck, false)
			outputChatBox("Santa was reset.",thePlayer)
		else
			outputChatBox("Sorry. Santa is at the north pole!",thePlayer,255,0,0)
		end
	end
end
addCommandHandler("fixsanta", fixSanta)

function christmasCoke(thePlayer) --Give chances of lottery prizes when drinking a coke
	local santaCars = {}
	for k,v in ipairs(getElementsByType("Vehicle")) do
		if(tonumber(getElementData(v,"owner")) == santaCharID and getElementData(v,"faction") == -1) then
			table.insert(santaCars,v)
		end
	end
	if(#santaCars > 0) then
		local chance = 1 --percentage chance of getting a car
		local chanceSuper = 1 --percentage chance of getting a supercar
		for k,v in ipairs(santaCars) do
			local vehID = tonumber(getElementData(v,"dbid"))
			local thisChance = 0
			if (vehID ~= colaTruckID and vehID ~= colaTruckTrailerID) then
				-- Don't sell the cola truck or trailer
				
				if(vehID == 4781) then --enter supercar ids here
					thisChance = chanceSuper
				elseif(getElementData(thePlayer,"dbid") == santaCharID) then
					thisChance = 100
				else
					thisChance = chance
				end

				if math.random(100) >= thisChance then --if no car won
					--do nothing, we'll give the chance of other prizes at the end of this func
					break
				else
					if exports['item-system']:giveItem(thePlayer, 3, vehID) then --give the vehicle key
						outputChatBox("You found a car key in the bottle!",thePlayer,0,255,0)
						local gender = tonumber(getElementData(thePlayer, "gender")) or 0
						local gendertext
						if gender > 0 then
							gendertext = "her"
						else
							gendertext = "his"
						end
						triggerEvent('sendAme', thePlayer, "finds a car key in "..tostring(gendertext).." christmas coca-cola bottle.")
					end
					return
				end
			end
		end
	end

	if math.random(100) >= 40 then
		--no prize
	else
		local prizes = christmasLotteryPrizes
		local prize = math.random(1,#prizes)
		local ticketValue = prize+89027548951875
		if exports['item-system']:giveItem(thePlayer, santaLotteryTicketID, tostring(ticketValue)) then --give a christmas lottery ticket
			--outputChatBox("You found a christmas lottery ticket in the bottle!",thePlayer,0,255,0)
			local gender = tonumber(getElementData(thePlayer, "gender")) or 0
			local gendertext
			if gender > 0 then
				gendertext = "her"
			else
				gendertext = "his"
			end
			triggerEvent('sendAme', thePlayer, "finds a lottery ticket in "..tostring(gendertext).." christmas coca-cola bottle.")
		end
	end
end

function useLotteryTicket(ped, itemSlot) --Redeem Santa's Christmas Lottery ticket
	local thePlayer = client
	if ped == santa then
		local hasItem, itemID, itemValue, itemIndex, itemProtected, metadata
		if itemSlot then
			itemID, itemValue, itemIndex, itemProtected, metadata = unpack(exports['item-system']:getItems(thePlayer)[itemSlot])
			if itemID == santaLotteryTicketID then
				hasItem = true
			end
		else
			itemID = santaLotteryTicketID
			hasItem, itemSlot, itemValue, itemIndex, metadata = exports['item-system']:hasItem(thePlayer, santaLotteryTicketID)
		end
		if hasItem then
			local pedName = getElementData(santa, "name")
			local ticketItemName = exports['item-system']:getItemName(itemID, itemValue, metadata)
			triggerEvent('sendAme', thePlayer, "gives "..tostring(pedName).." a "..tostring(ticketItemName)..".")
			exports['item-system']:takeItemFromSlot(thePlayer, itemSlot)
			setTimer(function()
				local prizes = christmasLotteryPrizes
				local prize = tonumber(itemValue)-89027548951875
				if prizes[prize] then
					if exports['item-system']:giveItem(thePlayer, prizes[prize][1], prizes[prize][2], false, false, prizes[prize][3]) then
						local itemName = exports['item-system']:getItemName(prizes[prize][1], prizes[prize][2], prizes[prize][3])
						local playerName = getPlayerName(thePlayer):gsub("_", " ")
						triggerEvent('sendAme', santa, "gives "..tostring(playerName).." a "..tostring(itemName)..".")
						outputChatBox("You won a "..tostring(itemName)..".", thePlayer, 0, 250, 0)

						saySlogan()
					else
						outputChatBox("You don't have enough space in your inventory.", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("Sorry, you won nothing on that ticket.", thePlayer, 255, 0, 0)
					outputDebugString("xmas:useLotteryTicket(): Christmas lottery prize was "..tostring(prize).." (invalid)")
				end
			end, 1000, 1)
		end
	end
end
addEvent("xmas:useChristmasLotteryTicket", true)
addEventHandler("xmas:useChristmasLotteryTicket", getRootElement(), useLotteryTicket)

function getCokeFromSanta(ped)
	local thePlayer = client
	if ped == santa then
		if colaDrinkers[thePlayer] then
			if colaDrinkers[thePlayer] >= maxBottlesPerPersonPerRound then
				outputChatBox("Save some for others!", thePlayer, 255, 0, 0)
				return
			end
		else
			colaDrinkers[thePlayer] = 0
		end

		if exports['item-system']:giveItem(thePlayer, santaCokeID, "1") then
			colaDrinkers[thePlayer] = colaDrinkers[thePlayer]+1
			local playerName = getPlayerName(thePlayer):gsub("_", " ")
			triggerEvent('sendAme', santa, "gives "..tostring(playerName).." a coke.")
			saySlogan()
		end
	end
end
addEvent("xmas:santaGetCoke", true)
addEventHandler("xmas:santaGetCoke", getRootElement(), getCokeFromSanta)

function resetBottleCounter()
	colaDrinkers = {}
end

function initializeDrinking()
	for k,v in ipairs(getElementsByType("Player")) do
		setElementData(v,"drinking",false)
	end
end