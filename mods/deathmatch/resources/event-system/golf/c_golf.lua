local playZoneCol = createColRectangle(1118.583984375, 2722.94140625, 1419.880859375-1118.583984375, 2863.5302734375-2722.94140625)

local clublist = {
	-- ["name"] = {lowest distance, maximum height, roll distance}
	["Driver"] = {50, 10, 5},
	["3-wood"] = {45, 12, 4.5},
	["Hybrid"] = {30, 15, 4},
	["4-iron"] = {25, 25, 3.5},
	["5-iron"] = {20, 25, 3},
	["6-iron"] = {15, 25, 2},
	["7-iron"] = {12, 32, 1},
	["8-iron"] = {8, 33, 0.5},
	["9-iron"] = {5, 33, 0},
	["putter"] = {2, 0, 0} -- Same as the 9 iron but no angle
}

function startGolf()
	if not isElementWithinColShape(localPlayer, playZoneCol) then return false end
	
	local holdsGolf = getPedWeapon(localPlayer)	
	if holdsGolf ~= 2 then 
		outputChatBox("You must hold your golf club in order to use this feature.") 
		return false 
	end

    if isElement(getElementData(localPlayer, "golf:ball")) then
		local playerX, playerY = getElementPosition(localPlayer)
		local ballX, ballY, ballZ = getElementPosition(getElementData(localPlayer, "golf:ball"))
		if getDistanceBetweenPoints2D(playerX, playerY, ballX, ballY) < 1 then
			golfGUI(getElementData(localPlayer, "golf:ball"))
			setCameraTarget(localPlayer)
			local camx, camy, camz = getCameraMatrix()
			setCameraMatrix(camx, camy, camz+0.6, playerX, playerY, 11.9)
		else
			outputChatBox("You are not close enough to your ball. Alternatively, you may reset it using /resetgolf.")
		end
    else
    	local x, y, z = getElementPosition(localPlayer)
    	local newz = getGroundPosition(x, y, z)
    	triggerServerEvent("golf:spawnball", resourceRoot, x, y, newz, localPlayer)
		setCameraTarget(localPlayer)
		local camx, camy, camz = getCameraMatrix()
		setCameraMatrix(camx, camy, camz+0.6, x, y, 11.9)
    end
end
addEvent("golf:start", true)
addEventHandler("golf:start", root, startGolf)
addCommandHandler("golf", startGolf)

function shootGolf(club, force, ball, rain, wind)
	local golfBall = ball
	if isElement(golfBall) then
		if not clublist[club] then
			outputChatBox("Please select a club.")
		else
			setCameraTarget(localPlayer)
			local distance = clublist[club][1]
			local height = clublist[club][2]

			local addDistance = (force * 5) / 100
			distance = distance + addDistance

			local ballX, ballY, ballZ = getElementPosition(golfBall)
			local endBallX, endBallY, endBallZ = getPositionInfrontOfElement(localPlayer, distance)
			
			-- check wind
			if not club == "putter" then
				local windForce = 0
				if string.find(wind, "Low") then
					windForce = 0.5
				elseif string.find(wind, "Middle") then
					windForce = 1
				elseif string.find(wind, "High") then
					windForce = 2
				end
				if string.find(wind, "East") then endBallX = endBallX + windForce end
				if string.find(wind, "West") then endBallX = endBallX - windForce end
				if string.find(wind, "North") then endBallY = endBallY + windForce end
				if string.find(wind, "South") then endBallY = endBallY - windForce end
			end
			
			
			local rollDistance = clublist[club][3]
			-- if it rains
			if rain == "Rain: Yes" and rollDistance>0 then
				rollDistance = rollDistance / 2
			end
			local rollX, rollY, rollZ = getPositionInfrontOfElement(localPlayer, distance + rollDistance )
			endBallZ = getGroundPosition(endBallX, endBallY, endBallZ)
			rollZ = getGroundPosition(rollX, rollY, rollZ)
			local betweenDistance = getDistanceBetweenPoints2D(ballX, ballY, endBallX, endBallY)
			
			setTimer(function()
				triggerServerEvent("golf:shootgolf", resourceRoot, ballX, ballY, ballZ, endBallX, endBallY, endBallZ, golfBall, height, betweenDistance, localPlayer, rollX, rollY, rollZ, club)
			end, 500, 1)
		end
	else
		outputChatBox("You have no golf ball.")
	end
end

function getPositionInfrontOfElement(element, meters) 
    if not element or not isElement(element) then 
        return false 
    end 
    if not meters then 
        meters = 3 
    end 
    local posX, posY, posZ = getElementPosition(element) 
    local _, _, rotation = getElementRotation(element) 
    posX = posX - math.sin(math.rad(rotation)) * meters 
    posY = posY + math.cos(math.rad(rotation)) * meters 
    return posX, posY, posZ 
end


GUIEditor = {
    label = {},
    button = {},
    window = {},
    scrollbar = {},
    combobox = {}
}

function golfGUI(ball)
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
	showCursor(true)
    GUIEditor.window[1] = guiCreateWindow(830, 248, 237, 337, "Select Golf", false)
    guiWindowSetSizable(GUIEditor.window[1], false)

    GUIEditor.label[1] = guiCreateLabel(0.03, 0.08, 0.89, 0.05, "1. Select a golf club", true, GUIEditor.window[1])
    GUIEditor.combobox[1] = guiCreateComboBox(0.09, 0.14, 0.84, 0.70, "", true, GUIEditor.window[1])
    for k, v in pairs(clublist) do
    	guiComboBoxAddItem(GUIEditor.combobox[1], k)
    end


    GUIEditor.label[2] = guiCreateLabel(0.03, 0.23, 0.89, 0.05, "2. Select the force you want to use", true, GUIEditor.window[1])
    GUIEditor.scrollbar[1] = guiCreateScrollBar(0.08, 0.31, 0.84, 0.04, true, true, GUIEditor.window[1])
    GUIEditor.label[3] = guiCreateLabel(0.08, 0.36, 0.84, 0.06, "Force: Low (0)", true, GUIEditor.window[1])
    addEventHandler("onClientGUIScroll", GUIEditor.scrollbar[1], function()
    	local position = guiScrollBarGetScrollPosition(GUIEditor.scrollbar[1])
    	local word = "Low"
    	if position >= 25 and position < 50 then word = "Low-middle" end
    	if position == 50 then word = "Middle" end
    	if position >= 51 and position < 75 then word = "Middle-high" end
    	if position >= 75 and position < 99 then word = "High" end
    	if position == 100 then word = "Maximum" end

    	guiSetText(GUIEditor.label[3], "Force: "..word.." ("..tostring(position)..")")
    end)

    GUIEditor.label[4] = guiCreateLabel(0.03, 0.44, 0.89, 0.05, "3. Select the rotation", true, GUIEditor.window[1])
    GUIEditor.scrollbar[2] = guiCreateScrollBar(0.08, 0.52, 0.84, 0.04, true, true, GUIEditor.window[1])
    local _, _, currentRotation = getElementRotation(localPlayer)
    guiScrollBarSetScrollPosition(GUIEditor.scrollbar[2], (currentRotation * 100) / 360)
    addEventHandler("onClientGUIScroll", GUIEditor.scrollbar[2], function()
    	local position = guiScrollBarGetScrollPosition(GUIEditor.scrollbar[2])
    	local newRotation = (position*360/100)
    	setElementRotation(localPlayer, 0, 0, newRotation)
    end)        

    GUIEditor.label[5] = guiCreateLabel(0.03, 0.59, 0.89, 0.05, "4. Weather information", true, GUIEditor.window[1])
    GUIEditor.label[6] = guiCreateLabel(0.08, 0.67, 0.89, 0.05, "Wind: direction (speed)", true, GUIEditor.window[1])
    GUIEditor.label[7] = guiCreateLabel(0.08, 0.73, 0.89, 0.05, "Rain: No", true, GUIEditor.window[1])
    local windX, windY = getWindVelocity()
    guiSetText(GUIEditor.label[6], getWindDirection(windX, windY))
    local weather = getWeather()
    if weather == (8 or 16) then guiSetText(GUIEditor.label[7], "Rain: Yes") end

    GUIEditor.button[1] = guiCreateButton(0.07, 0.83, 0.42, 0.13, "Shoot", true, GUIEditor.window[1])
    addEventHandler("onClientGUIClick", GUIEditor.button[1], function()
    	local chosenClubid = guiComboBoxGetSelected(GUIEditor.combobox[1])
    	local chosenClub = guiComboBoxGetItemText(GUIEditor.combobox[1], chosenClubid)

    	if clublist[chosenClub] then
    		shootGolf(chosenClub, guiScrollBarGetScrollPosition(GUIEditor.scrollbar[1]), ball, guiGetText(GUIEditor.label[7]), guiGetText(GUIEditor.label[6]))
    		destroyElement(GUIEditor.window[1])
			showCursor(false)
        end
    end, false)

    GUIEditor.button[2] = guiCreateButton(0.51, 0.83, 0.42, 0.13, "Cancel", true, GUIEditor.window[1])    
    addEventHandler("onClientGUIClick", GUIEditor.button[2], function()
    	destroyElement(GUIEditor.window[1])
		showCursor(false)
    	setPedAnimation(localPlayer)
		setCameraTarget(localPlayer)
    end, false)
	
	triggerEvent("hud:convertUI", localPlayer, GUIEditor.window[1])
end
addEvent("golf:gui", true)
addEventHandler("golf:gui", resourceRoot, golfGUI)

function getWindDirection(x, y)
	local force = "No wind"
	local direction = "N/A"
	if y > 0 then
		direction = "North"
	elseif y < 0 then
		direction = "South"
	end

	if x > 0 then
		direction = direction.."-East"
	elseif x < 0 then
		direction = direction.."-West"
	end

	if x > 0.2 or y > 0.2 then
		force = "Low"
	elseif x > 0.7 or y > 0.7 then
		force = "Middle"
	elseif x > 0.9 or y > 0.9 then
		force = "High"
	end

	local preparedString = "Force: "..force.." | Direction: "..direction
	return preparedString
end