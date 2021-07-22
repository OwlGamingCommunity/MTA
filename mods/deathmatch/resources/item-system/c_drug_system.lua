addEvent( "onClientVehicleEnterDelayed" )

wChemistrySet, gChemicals, colChemSlot, colChemName, chemItems, bMixItems, bChemClose = nil

function showChemistrySet()
	if not (wItems) then
		if not (wChemistrySet) then
			local width, height = 600, 500
			local scrWidth, scrHeight = guiGetScreenSize()
			local x = scrWidth/2 - (width/2)
			local y = scrHeight/2 - (height/2)
			
			wChemistrySet = guiCreateWindow(x, y, width, height, "Chemistry Set", false)
			guiWindowSetSizable(wChemistrySet, false)
			
			local items = getItems(getLocalPlayer())
					
			chemItems = { }
			
			if items then
				for slot, item in ipairs(items) do
					if item and item[1] >= 30 and item[1] <= 33 then
						chemItems[slot] = { }
						chemItems[slot][1] = getItemName(item[1])
						chemItems[slot][2] = item[1]
						chemItems[slot][3] = slot
					end
				end
			end
			
			
			-- ITEMS
			gChemicals = guiCreateGridList(0.025, 0.05, 0.95, 0.85, true, wChemistrySet)
			
			colChemSlot = guiGridListAddColumn(gChemicals, "Slot", 0.1)
			colChemName = guiGridListAddColumn(gChemicals, "Name", 0.855)
			
			guiGridListSetSelectionMode(gChemicals, 1)
			
			for k, v in pairs(chemItems) do
				local itemid = tonumber(chemItems[k][2])

				local itemtype = getItemType(itemid)
			
				if (itemtype) then
					local row = guiGridListAddRow(gChemicals)
					guiGridListSetItemText(gChemicals, row, colChemSlot, tostring(chemItems[k][3]), false, true)
					guiGridListSetItemText(gChemicals, row, colChemName, tostring(chemItems[k][1]), false, false)
				end
			end

			-- buttons
			bMixItems = guiCreateButton(0.05, 0.91, 0.7, 0.15, "Mix Selected", true, wChemistrySet)
			addEventHandler("onClientGUIClick", bMixItems, mixItems, false)
			guiSetEnabled(bMixItems, false)
			
			bChemClose = guiCreateButton(0.8, 0.91, 0.15, 0.15, "Close", true, wChemistrySet)

			addEventHandler("onClientGUIClick", gChemicals, checkSelectedItems, false)
			addEventHandler("onClientGUIClick", bChemClose, hideChemistrySet, false)
			showCursor(true)
		else
			hideChemistrySet()
		end
	end
end

function hideChemistrySet()
	colChemSlot = nil
	colChemName = nil
	
	destroyElement(gChemicals)
	gChemicals = nil
	
	chemItems = nil
	
	destroyElement(wChemistrySet)
	wChemistrySet = nil
	
	showCursor(false)
end

function checkSelectedItems()
	if (guiGridListGetSelectedCount(gChemicals)==4) then
		guiSetEnabled(bMixItems, true)
	else
		guiSetEnabled(bMixItems, false)
	end
end

function mixItems(button, state)
	if (button=="left" and state=="up") then
		if (guiGridListGetSelectedCount(gChemicals)==4) then
			selected = guiGridListGetSelectedItems(gChemicals)
			
			if (selected) then
				local row1 = selected[1]["row"]
				local row2 = selected[3]["row"]
				
				local row1slot = tonumber(guiGridListGetItemText(gChemicals, row1, 1))
				local row2slot = tonumber(guiGridListGetItemText(gChemicals, row2, 1))

				local row1item = chemItems[row1slot][2]
				local row2item = chemItems[row2slot][2]
				
				local row1name = chemItems[row1slot][1]
				local row2name = chemItems[row2slot][1]
				
				triggerServerEvent("mixDrugs", getLocalPlayer(), row1item, row2item, row1name, row2name)
			end
		end
		
		hideChemistrySet()
	end
end

local localPlayer = getLocalPlayer()

-- DRUG 1 EFFECT
local vehicles = nil
local weather = nil
drug1effect = false
drug1timer = nil
function doDrug1Effect()
	if not (drug1effect) then
		drug1effect = true
		weather = getWeather()
		setSkyGradient(0, 0, 255, 0, 0, 255)
		
		
		if not (drug1effect) then
			local x, y, z = getElementPosition(localPlayer)
			vehicles = { }
			for i = 1, 20 do
				vehicles[i] = createVehicle(423, x+(i*3), y+(i*3), z)
				setVehicleColor(vehicles[i], 126, 126, 126, 126)
			end
		end
		setTimer(setWeather, 100, 1, 9)
	end
	
	drug1timer = setTimer(resetDrug1Effect, 300000, 1)
end

function resetDrug1Effect()
	drug1effect = false
	resetSkyGradient()
	setTimer(setWeather, 100, 1, weather)
	if (vehicles) then
		for key, value in ipairs(vehicles) do
			destroyElement(value)
		end
	end
	vehicles = nil
end

-- DRUG 2 EFFECT
drug2effect = false
drug2timer = nil
function doDrug2Effect()
	if not (drug2effect) then
		drug2effect = true
		addEventHandler("onClientPlayerDamage", getLocalPlayer(), cancelEvent)
		drug2timer = setTimer(resetDrug2Effect, 300000, 1)
	end
end

function resetDrug2Effect()
	drug2effect = false
	removeEventHandler("onClientPlayerDamage", getLocalPlayer(), cancelEvent)
end

-- DRUG 3 EFFECT
drug3effect = false
drug3timer = nil
function doDrug3Effect()
	if not (drug3effect) then
		drug3effect = true
		setSkyGradient(255, 128, 255, 255, 128, 255)
		drug3timer = setTimer(resetDrug3Effect, 600000, 1)
		weather = getWeather()
		--setGameSpeed(0.3)
	end
end

function resetDrug3Effect()
	drug3effect = false
	resetSkyGradient()
	setTimer(setWeather, 100, 1, weather)
	--setGameSpeed(1)
end

-- DRUG 4 EFFECT
drug4effect = false
drug4timer = nil
local peds = nil
function doDrug4Effect()
	if not (drug4effect) then
		peds = { }
		drug4effect = true
		setSkyGradient(255, 128, 255, 255, 128, 255)
		drug4timer = setTimer(resetDrug4Effect, 300000, 1)
		weather = getWeather()
		
		addEventHandler("onClientRender", getRootElement(), createRandomPeds)
	end
end

local count = 1
function createRandomPeds()
	if (count<25) then
		local x, y, z = getElementPosition(localPlayer)
		local rand1 = math.random(1, 5)
		local rand2 = math.random(1, 5)
		
		peds[count] = createPed(264, x+rand1, y+rand2, z)
		count = count + 1
	end
end

function resetDrug4Effect()
	drug4effect = false
	resetSkyGradient()
	setTimer(setWeather, 100, 1, weather)
	removeEventHandler("onClientRender", getRootElement(), createRandomPeds)
	
	if peds then
		for key, value in ipairs(peds) do
			destroyElement(value)
		end
	end
	peds = nil
end

-- DRUG 5 EFFECT
drug5effect = false
drug5timer = nil
function doDrug5Effect()
	if not (drug5effect) then
		drug5effect = true
		setSkyGradient(0, 0, 0, 0, 0, 0)
		weather = getWeather()
		setTimer(setWeather, 100, 1, 9)
		drug5timer = setTimer(resetDrug5Effect, 300000, 1)
		addEventHandler("onClientVehicleEnterDelayed", getRootElement(), resetDrug5Effect)
		--setGameSpeed(1.5)
	end
end

function resetDrug5Effect(thePlayer)
	if not thePlayer or thePlayer == getLocalPlayer() then
		drug5effect = false
		--setGameSpeed(1)
		resetSkyGradient()
		setTimer(setWeather, 100, 1, weather)
		removeEventHandler("onClientVehicleEnterDelayed", getRootElement(), resetDrug5Effect)
	end
end

-- DRUG 6 EFFECT
drug6effect = false
drug6timer = nil
drug6timer2 = nil
function doDrug6Effect()
	if not (drug6effect) then
		drug6effect = true
		weather = getWeather()
		setSkyGradient(255, 0, 0, 0, 255, 0)
		drug6timer = setTimer(resetDrug6Effect, 300000, 1)
		addEventHandler("onClientPlayerDamage", getLocalPlayer(), cancelEvent)
		--setGameSpeed(0.5)
		drug6timer2 = setTimer(doRandomMessage, 15000, 5)
	end
end

local drugMessages = { "Fuck You Pal!", "Wow man, your flyyyyyyyying!", "We need some drugs PAL!", "Some of the ol' Love Fist Fury!", "Yo mannnnnnnnnnn, why are your legs turned to mush?", "You wanna dance muthafucka?", "Dude, I want some of that shit. What is it?", "I'mma call the cops." }

function doRandomMessage()
	local x, y, z = getElementPosition(localPlayer)
	local colSphere = createColSphere(x, y, z, 10)
	
	local players = getElementsByType("player")

	for key, value in ipairs(players) do
		if (value~=localPlayer) then
			local px, py , pz = getElementPosition(value)
			if (getDistanceBetweenPoints3D(x, y, z, px, py, pz)<15) then
				local rand2 = math.random(1, #drugMessages)
				local charname = getPlayerName(value)
				charname = string.gsub(tostring(charname), "_", " ")
				outputChatBox(charname .. " Says: " .. drugMessages[rand2], 255, 255, 255)
				break
			end
		end
	end
end

function resetDrug6Effect()
	drug6effect = false
	--setGameSpeed(1)
	removeEventHandler("onClientPlayerDamage", getLocalPlayer(), cancelEvent)
end

function resetAllDrugs()
	if isTimer(drug1Timer) then
		killTimer(drug1Timer)
		drug1Timer = nil
		
		resetDrug1Effect()
	end
	
	if isTimer(drug2Timer) then
		killTimer(drug2Timer)
		drug2Timer = nil
	
		resetDrug2Effect()
	end
	
	if isTimer(drug3Timer) then
		killTimer(drug3Timer)
		drug3Timer = nil
		
		resetDrug3Effect()
	end
	
	if isTimer(drug4Timer) then
		killTimer(drug4Timer)
		drug4Timer = nil
		
		resetDrug4Effect()
	end
	
	if isTimer(drug5Timer) then
		killTimer(drug5Timer)
		drug5Timer = nil
		
		resetDrug5Effect()
	end
	
	if isTimer(drug6Timer) then
		killTimer(drug6Timer)
		drug6Timer = nil
		
		resetDrug6Effect()
	end
	
	if isTimer(drug6Timer2) then
		killTimer(drug6Timer2)
		drug6Timer2 = nil
	end
end
addEventHandler("onClientChangeChar", getRootElement(), resetAllDrugs)

addEventHandler("onClientVehicleEnter", getRootElement(), 
	function( player )
		if player == getLocalPlayer() then
			setTimer(
				function( source )
					if isPedInVehicle( getLocalPlayer( ) ) then
						triggerEvent( "onClientVehicleEnterDelayed", source, getLocalPlayer( ) )
					end
				end, 500, 1, source
			)
		end
	end
)
