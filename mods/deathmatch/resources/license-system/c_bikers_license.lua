local localPlayer = getLocalPlayer()

guiIntroLabel1B = nil
guiIntroProceedButtonB = nil
guiIntroWindowB = nil
guiQuestionLabelB = nil
guiQuestionAnswer1RadioB = nil
guiQuestionAnswer2RadioB = nil
guiQuestionAnswer3RadioB = nil
guiQuestionWindowB = nil
guiFinalPassTextLabelB = nil
guiFinalFailTextLabelB = nil
guiFinalRegisterButtonB = nil
guiFinalCloseButtonB = nil
guiFinishWindowB = nil

-- variable for the max number of possible questions
local NoQuestions = 10
local NoQuestionToAnswer = 7
local correctAnswers = 0
local passPercent = 80
		
selection = {}

-- functon makes the intro window for the quiz
function createlicenseBikeTestIntroWindow()
	showCursor(true)
	local screenwidth, screenheight = guiGetScreenSize ()
	
	local Width = 450
	local Height = 200
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
	
	guiIntroWindowB = guiCreateWindow ( X , Y , Width , Height , "Bike Theory Test" , false )
	
	guiCreateStaticImage (0.35, 0.1, 0.3, 0.2, "banner.png", true, guiIntroWindowB)
	
	guiIntroLabel1B = guiCreateLabel(0, 0.3,1, 0.5, [[You will now proceed with the motorcycle theory test. You will
be given seven questions based on basic driving theory. You must score
a minimum of 80 percent to pass.

Good luck.]], true, guiIntroWindowB)
	
	guiLabelSetHorizontalAlign ( guiIntroLabel1B, "center", true )
	guiSetFont ( guiIntroLabel1B,"default-bold-small")
	
	guiIntroProceedButtonB = guiCreateButton ( 0.4 , 0.75 , 0.2, 0.1 , "Start Test" , true ,guiIntroWindowB)
	
	addEventHandler ( "onClientGUIClick", guiIntroProceedButtonB,  function(button, state)
		if(button == "left" and state == "up") then
		
			-- start the quiz and hide the intro window
			startLicenceBikeTest()
			guiSetVisible(guiIntroWindowB, false)
		
		end
	end, false)
	
end

-- done bike up to here

-- function create the question window
function createBikeLicenseQuestionWindow(number)

	local screenwidth, screenheight = guiGetScreenSize ()
	
	local Width = 450
	local Height = 200
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
	
	-- create the window
	guiQuestionWindowB = guiCreateWindow ( X , Y , Width , Height , "Question "..number.." of "..NoQuestionToAnswer , false )
	
	guiQuestionLabelB = guiCreateLabel(0.1, 0.2, 0.9, 0.2, selection[number][1], true, guiQuestionWindowB)
	guiSetFont ( guiQuestionLabelB,"default-bold-small")
	guiLabelSetHorizontalAlign ( guiQuestionLabelB, "left", true)
	
	
	if not(selection[number][2]== "nil") then
		guiQuestionAnswer1RadioB = guiCreateRadioButton(0.1, 0.4, 0.9,0.1, selection[number][2], true,guiQuestionWindowB)
	end
	
	if not(selection[number][3] == "nil") then
		guiQuestionAnswer2RadioB = guiCreateRadioButton(0.1, 0.5, 0.9,0.1, selection[number][3], true,guiQuestionWindowB)
	end
	
	if not(selection[number][4]== "nil") then
		guiQuestionAnswer3RadioB = guiCreateRadioButton(0.1, 0.6, 0.9,0.1, selection[number][4], true,guiQuestionWindowB)
	end
	
	-- if there are more questions to go, then create a "next question" button
	if(number < NoQuestionToAnswer) then
		guiQuestionNextButtonB = guiCreateButton ( 0.4 , 0.75 , 0.2, 0.1 , "Next Question" , true ,guiQuestionWindowB)
		
		addEventHandler ( "onClientGUIClick", guiQuestionNextButtonB,  function(button, state)
			if(button == "left" and state == "up") then
				
				local selectedAnswer = 0
			
				-- check all the radio buttons and seleted the selectedAnswer variabe to the answer that has been selected
				if(guiRadioButtonGetSelected(guiQuestionAnswer1RadioB)) then
					selectedAnswer = 1
				elseif(guiRadioButtonGetSelected(guiQuestionAnswer2RadioB)) then
					selectedAnswer = 2
				elseif(guiRadioButtonGetSelected(guiQuestionAnswer3RadioB)) then
					selectedAnswer = 3
				else
					selectedAnswer = 0
				end
				
				-- don't let the player continue if they havn't selected an answer
				if(selectedAnswer ~= 0) then
					
					-- if the selection is the same as the correct answer, increase correct answers by 1
					if(selectedAnswer == selection[number][5]) then
						correctAnswers = correctAnswers + 1
					end
				
					-- hide the current window, then create a new window for the next question
					guiSetVisible(guiQuestionWindowB, false)
					createBikeLicenseQuestionWindow(number+1)
				end
			end
		end, false)
		
	else
		guiQuestionSumbitButtonB = guiCreateButton ( 0.4 , 0.75 , 0.3, 0.1 , "Submit Answers" , true ,guiQuestionWindowB)
		
		-- handler for when the player clicks submit
		addEventHandler ( "onClientGUIClick", guiQuestionSumbitButtonB,  function(button, state)
			if(button == "left" and state == "up") then
				
				local selectedAnswer = 0
			
				-- check all the radio buttons and seleted the selectedAnswer variabe to the answer that has been selected
				if(guiRadioButtonGetSelected(guiQuestionAnswer1RadioB)) then
					selectedAnswer = 1
				elseif(guiRadioButtonGetSelected(guiQuestionAnswer2RadioB)) then
					selectedAnswer = 2
				elseif(guiRadioButtonGetSelected(guiQuestionAnswer3RadioB)) then
					selectedAnswer = 3
				elseif(guiRadioButtonGetSelected(guiQuestionAnswer4RadioB)) then
					selectedAnswer = 4
				else
					selectedAnswer = 0
				end
				
				-- don't let the player continue if they havn't selected an answer
				if(selectedAnswer ~= 0) then
					
					-- if the selection is the same as the correct answer, increase correct answers by 1
					if(selectedAnswer == selection[number][5]) then
						correctAnswers = correctAnswers + 1
					end
				
					-- hide the current window, then create the finish window
					guiSetVisible(guiQuestionWindowB, false)
					createBikeTestFinishWindow()


				end
			end
		end, false)
	end
end


-- funciton create the window that tells the
function createBikeTestFinishWindow()

	local score = math.floor((correctAnswers/NoQuestionToAnswer)*100)

	local screenwidth, screenheight = guiGetScreenSize ()
		
	local Width = 450
	local Height = 200
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
		
	-- create the window
	guiFinishWindowB = guiCreateWindow ( X , Y , Width , Height , "End of test.", false )
	
	if(score >= passPercent) then
	
		guiCreateStaticImage (0.35, 0.1, 0.3, 0.2, "pass.png", true, guiFinishWindowB)
	
		guiFinalPassLabelB = guiCreateLabel(0, 0.3, 1, 0.1, "Congratulations! You have passed this section of the test.", true, guiFinishWindowB)
		guiSetFont ( guiFinalPassLabelB,"default-bold-small")
		guiLabelSetHorizontalAlign ( guiFinalPassLabelB, "center")
		guiLabelSetColor ( guiFinalPassLabelB ,0, 255, 0 )
		
		guiFinalPassTextLabelB = guiCreateLabel(0, 0.4, 1, 0.4, "You scored "..score.."%, and the pass mark is "..passPercent.."%. Well done!" ,true, guiFinishWindowB)
		guiLabelSetHorizontalAlign ( guiFinalPassTextLabelB, "center", true)
		
		guiFinalRegisterButtonB = guiCreateButton ( 0.35 , 0.8 , 0.3, 0.1 , "Continue" , true ,guiFinishWindowB)
		
		-- if the player has passed the quiz and clicks on register
		addEventHandler ( "onClientGUIClick", guiFinalRegisterButtonB,  function(button, state)
			if(button == "left" and state == "up") then
				-- set player date to say they have passed the theory.
				

				initiateBikeTest()
				-- reset their correct answers
				correctAnswers = 0
				toggleAllControls ( true )
				--cleanup
				destroyElement(guiIntroLabel1B)
				destroyElement(guiIntroProceedButtonB)
				destroyElement(guiIntroWindowB)
				destroyElement(guiQuestionLabelB)
				destroyElement(guiQuestionAnswer1RadioB)
				destroyElement(guiQuestionAnswer2RadioB)
				destroyElement(guiQuestionAnswer3RadioB)
				destroyElement(guiQuestionWindowB)
				destroyElement(guiFinalPassTextLabelB)
				destroyElement(guiFinalRegisterButtonB)
				destroyElement(guiFinishWindowB)
				guiIntroLabel1B = nil
				guiIntroProceedButtonB = nil
				guiIntroWindowB = nil
				guiQuestionLabelB = nil
				guiQuestionAnswer1RadioB = nil
				guiQuestionAnswer2RadioB = nil
				guiQuestionAnswer3RadioB = nil
				guiQuestionWindowB = nil
				guiFinalPassTextLabelB = nil
				guiFinalRegisterButtonB = nil
				guiFinishWindowB = nil
				
				correctAnswers = 0
				selection = {}
				
				showCursor(false)
			end
		end, false)
		
	else -- player has failed, 
	
		guiCreateStaticImage (0.35, 0.1, 0.3, 0.2, "fail.png", true, guiFinishWindowB)
	
		guiFinalFailLabelB = guiCreateLabel(0, 0.3, 1, 0.1, "Sorry, you have not passed this time.", true, guiFinishWindowB)
		guiSetFont ( guiFinalFailLabelB,"default-bold-small")
		guiLabelSetHorizontalAlign ( guiFinalFailLabelB, "center")
		guiLabelSetColor ( guiFinalFailLabelB ,255, 0, 0 )
		
		guiFinalFailTextLabelB = guiCreateLabel(0, 0.4, 1, 0.4, "You scored "..math.ceil(score).."%, and the pass mark is "..passPercent.."%." ,true, guiFinishWindowB)
		guiLabelSetHorizontalAlign ( guiFinalFailTextLabelB, "center", true)
		
		guiFinalCloseButtonB = guiCreateButton ( 0.2 , 0.8 , 0.25, 0.1 , "Close" , true ,guiFinishWindowB)
		
		-- if player click the close button
		addEventHandler ( "onClientGUIClick", guiFinalCloseButtonB,  function(button, state)
			if(button == "left" and state == "up") then
				destroyElement(guiIntroLabel1B)
				destroyElement(guiIntroProceedButtonB)
				destroyElement(guiIntroWindowB)
				destroyElement(guiQuestionLabelB)
				destroyElement(guiQuestionAnswer1RadioB)
				destroyElement(guiQuestionAnswer2RadioB)
				destroyElement(guiQuestionAnswer3RadioB)
				destroyElement(guiQuestionWindowB)
				destroyElement(guiFinalPassTextLabelB)
				destroyElement(guiFinalRegisterButtonB)
				destroyElement(guiFinishWindowB)
				guiIntroLabel1B = nil
				guiIntroProceedButtonB = nil
				guiIntroWindowB = nil
				guiQuestionLabelB = nil
				guiQuestionAnswer1RadioB = nil
				guiQuestionAnswer2RadioB = nil
				guiQuestionAnswer3RadioB = nil
				guiQuestionWindowB = nil
				guiFinalPassTextLabelB = nil
				guiFinalRegisterButtonB = nil
				guiFinishWindowB = nil
				
				selection = {}
				correctAnswers = 0
				
				showCursor(false)
			end
		end, false)
	end
	
end
 
 -- function starts the quiz
 function startLicenceBikeTest()
 
	-- choose a random set of questions
	chooseBikeTestQuestions()
	-- create the question window with question number 1
	createBikeLicenseQuestionWindow(1)
 
 end
 
 
 -- functions chooses the questions to be used for the quiz
 function chooseBikeTestQuestions()
 
	-- loop through selections and make each one a random question
	for i=1, 10 do
		-- pick a random number between 1 and the max number of questions
		local number = math.random(1, NoQuestions)
		
		-- check to see if the question has already been selected
		if(testBikeQuestionAlreadyUsed(number)) then
			repeat -- if it has, keep changing the number until it hasn't
				number = math.random(1, NoQuestions)
			until (testBikeQuestionAlreadyUsed(number) == false)
		end
		
		-- set the question to the random one
		selection[i] = questionsBike[number]
	end
 end
 
 
 -- function returns true if the queston is already used
 function testBikeQuestionAlreadyUsed(number)
 
	local same = 0
 
	-- loop through all the current selected questions
	for i, j in pairs(selection) do
		-- if a selected question is the same as the new question
		if(j[1] == questionsBike[number][1]) then
			same = 1 -- set same to 1
		end
		
	end
	
	-- if same is 1, question already selected to return true
	if(same == 1) then
		return true
	else
		return false
	end
 end

---------------------------------------
------ Practical Driving Test ---------
---------------------------------------
 
testBikeRoute = {
	{ 1092.20703125, -1759.1591796875, 13.023070335388 },	-- Start, DoL Parking 
	{ 1167.5771484375, -1743.3544921875, 13.066892623901 }, -- DoL exit, turning right
	{ 1173.171875, -1843.9365234375, 13.07141494751 }, -- Headed towards Governors office
	{ 1319.13671875, -1854.3408203125, 13.052598953247 }, -- Riding towards Idlewood
	{ 1382.615234375, -1873.7451171875, 13.052177429199 }, -- ^^
	{ 1559.7392578125, -1875.140625, 13.050706863403 }, -- Turning towards PD
	{ 1571.5244140625, -1859.8037109375, 13.050792694092 }, -- ^^
	{ 1571.8427734375, -1740.0810546875, 13.050458908081 }, -- Stop at PD, turn right
	{ 1680.7255859375, -1734.396484375, 13.055520057678 }, -- Stop at SAN, turn left
	{ 1691.6259765625, -1715.3349609375, 13.050860404968 }, -- ^^
	{ 1691.5712890625, -1599.6298828125, 13.054371833801 }, -- End of SAN, behind PD turn left
	{ 1669.734375, -1590.0703125, 13.051850318909 }, -- Heading past PD
	{ 1518.28515625, -1590.2666015625, 13.052554130554 }, -- Next to PD
	{ 1426.9873046875, -1590.0029296875, 13.058673858643 }, -- At intersection on commerce
	{ 1319.5224609375, -1569.0380859375, 13.042145729065 }, -- Stop @ St. Lawrence, turn right
	{ 1359.40234375, -1416.8935546875, 13.050371170044 }, -- Turn left towards ASH @ speed cam
	{ 1331.08984375, -1395.2607421875, 13.012241363525 }, -- ^^
	{ 1136.51171875, -1393.3408203125, 13.176746368408 }, -- Next to ASH
	{ 1012.11328125, -1393.45703125, 12.736813545227 }, -- Heading down the road
	{ 837.7568359375, -1392.7607421875, 13.025742530823 }, -- ^^
	{ 804.1962890625, -1392.9248046875, 13.181559562683 }, -- Turn right at Vinyl Countdown
	{ 800.14453125, -1370.953125, 13.049411773682 }, -- ^^
	{ 799.982421875, -1285.041015625, 13.049916267395 }, -- Heading towards Dillimore
	{ 799.6279296875, -1161.751953125, 23.290950775146 }, -- ^^
	{ 797.2490234375, -1061.5009765625, 24.365398406982 }, -- Turn left @ Dillimore road
	{ 755.2783203125, -1054.138671875, 23.414789199829 }, -- ^^
	{ 707.0498046875, -1114.193359375, 17.771127700806 }, -- Going towards Bank
	{ 657.474609375, -1190.5693359375, 17.324506759644 }, -- ^^
	{ 629.720703125, -1208.3291015625, 17.772462844849 }, -- Turn left at bank
	{ 622.671875, -1230.0146484375, 17.729223251343 }, -- ^^
	{ 627.8359375, -1308.2685546875, 13.577067375183 }, -- Going towards Beach
	{ 630.0869140625, -1425.345703125, 13.397357940674 }, -- ^^
	{ 630.3798828125, -1572.8544921875, 15.133798599243 }, -- ^^
	{ 632.1416015625, -1660.2255859375, 15.142672538757 }, -- Turn left into road
	{ 654.5322265625, -1674.0439453125, 14.000010490417 }, -- ^^
	{ 803.4462890625, -1677.0830078125, 13.050843238831 }, -- End of road, turn left
	{ 812.54296875, -1662.7041015625, 13.043465614319 }, -- ^^
	{ 832.4482421875, -1623.37109375, 13.052579879761 }, -- Heading back towards DoL
	{ 895.9052734375, -1574.603515625, 13.050440788269 }, -- ^^
	{ 1028.7724609375, -1574.8671875, 13.051753044128 }, -- turn right towards DoL
	{ 1034.87890625, -1589.0283203125, 13.051016807556 }, -- ^^
	{ 1035.052734375, -1699.5732421875, 13.050029754639 }, -- Turn left towards DoL
	{ 1049.9208984375, -1714.2490234375, 13.053936004639 }, -- ^^
	{ 1165.490234375, -1714.7138671875, 13.40420627594 }, -- Turn right into DoL
	{ 1172.11328125, -1734.9443359375, 13.159434318542 }, -- ^^
	{ 1085.056640625, -1740.5791015625, 13.152918815613 },	-- DoL End road
}

testBike = { [468]=true } -- Mananas need to be spawned at the start point.
local vehicleIdUsedToStartTest = nil

local blip = nil
local marker = nil

function initiateBikeTest()
	triggerServerEvent("theoryBikeComplete", getLocalPlayer())
	local x, y, z = testBikeRoute[1][1], testBikeRoute[1][2], testBikeRoute[1][3]
	blip = createBlip(x, y, z, 0, 2, 0, 255, 0, 255)
	marker = createMarker(x, y, z, "checkpoint", 4, 0, 255, 0, 150) -- start marker.
	addEventHandler("onClientMarkerHit", marker, startBikeTest)
	
	outputChatBox("#FF9933You are now ready to take your practical driving examination. Collect a DoL test bike and begin the route.", 255, 194, 14, true)
	
end

function startBikeTest(element)
	if element == getLocalPlayer() then
		local vehicle = getPedOccupiedVehicle(getLocalPlayer())
		if not vehicle or not testBike[getElementModel(vehicle)] then
			outputChatBox("#FF9933You must be riding a DoL test bike when passing through the checkpoints.", 255, 0, 0, true ) -- Wrong  type.
		else
			destroyElement(blip)
			destroyElement(marker)
			
			setElementData(getLocalPlayer(), "drivingTest.marker", 2, false)
			vehicleIdUsedToStartTest = getElementData(vehicle, "dbid")

			local x1,y1,z1 = nil -- Setup the first checkpoint
			x1 = testBikeRoute[2][1]
			y1 = testBikeRoute[2][2]
			z1 = testBikeRoute[2][3]
			setElementData(getLocalPlayer(), "drivingTest.checkmarkers", #testBikeRoute, false)

			blip = createBlip(x1, y1 , z1, 0, 2, 255, 0, 255, 255)
			marker = createMarker( x1, y1,z1 , "checkpoint", 4, 255, 0, 255, 150)
				
			addEventHandler("onClientMarkerHit", marker, UpdateBikeCheckpoints)
				
			outputChatBox("#FF9933You will need to complete the route without damaging the test bike. Good luck and drive safe.", 255, 194, 14, true)
		end
	end
end

function UpdateBikeCheckpoints(element)
	if (element == localPlayer) then
		local vehicle = getPedOccupiedVehicle(getLocalPlayer())
		if not vehicle or not testBike[getElementModel(vehicle)] then
			outputChatBox("You must be on a DoL test bike when passing through the check points.", 255, 0, 0) -- Wrong car type.
		elseif getElementData(vehicle, "dbid") ~= vehicleIdUsedToStartTest then
			outputChatBox("You are not using the bike you started this test with.", 255, 194, 14)
			outputChatBox("You have failed the practical driving test.", 255, 0, 0)

			destroyElement(blip)
			destroyElement(marker)
			blip = nil
			marker = nil
		else
			destroyElement(blip)
			destroyElement(marker)
			blip = nil
			marker = nil
				
			local m_number = getElementData(getLocalPlayer(), "drivingTest.marker")
			local max_number = getElementData(getLocalPlayer(), "drivingTest.checkmarkers")
			
			if (tonumber(max_number-1) == tonumber(m_number)) then -- if the next checkpoint is the final checkpoint.
				outputChatBox("#FF9933Park your bike at the #FF66CCin the parking lot #FF9933to complete the test.", 255, 194, 14, true)
				
				local newnumber = m_number+1
				setElementData(getLocalPlayer(), "drivingTest.marker", newnumber, false)
					
				local x2, y2, z2 = nil
				x2 = testBikeRoute[newnumber][1]
				y2 = testBikeRoute[newnumber][2]
				z2 = testBikeRoute[newnumber][3]
				
				marker = createMarker( x2, y2, z2, "checkpoint", 4, 255, 0, 255, 150)
				blip = createBlip( x2, y2, z2, 0, 2, 255, 0, 255, 255)
				
				
				addEventHandler("onClientMarkerHit", marker, EndBikeTest)
			else
				local newnumber = m_number+1
				setElementData(getLocalPlayer(), "drivingTest.marker", newnumber, false)
						
				local x2, y2, z2 = nil
				x2 = testBikeRoute[newnumber][1]
				y2 = testBikeRoute[newnumber][2]
				z2 = testBikeRoute[newnumber][3]
						
				marker = createMarker( x2, y2, z2, "checkpoint", 4, 255, 0, 255, 150)
				blip = createBlip( x2, y2, z2, 0, 2, 255, 0, 255, 255)
				
				addEventHandler("onClientMarkerHit", marker, UpdateBikeCheckpoints)
			end
		end
	end
end

function EndBikeTest(element)
	if (element == localPlayer) then
		local vehicle = getPedOccupiedVehicle(getLocalPlayer())
		if not vehicle or not testBike[getElementModel(vehicle)] then
			outputChatBox("You must be on a DoL test bike when passing through the check points.", 255, 0, 0)
		else
			local vehicleHealth = getElementHealth ( vehicle )
			if getElementData(vehicle, "dbid") ~= vehicleIdUsedToStartTest then
				outputChatBox("You are not using the bike you started this test with.", 255, 194, 14)
				outputChatBox("You have failed the practical driving test.", 255, 0, 0)
			elseif (vehicleHealth >= 800) then
				----------
				-- PASS --
				----------
				outputChatBox("After inspecting the vehicle we can see no damage.", 255, 194, 14)
				triggerServerEvent("acceptBikeLicense", getLocalPlayer())
			
			else
				----------
				-- Fail --
				----------
				outputChatBox("After inspecting the vehicle we can see that it's damage.", 255, 194, 14)
				outputChatBox("You have failed the practical driving test.", 255, 0, 0)
			end
			
			destroyElement(blip)
			destroyElement(marker)
			triggerServerEvent('takeBackHelmet', localPlayer)
			blip = nil
			marker = nil
		end
	end
end
