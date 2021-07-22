local localPlayer = getLocalPlayer()

guiIntroLabel1Bo = nil
guiIntroProceedButtonBo = nil
guiIntroWindowBo = nil
guiQuestionLabelBo = nil
guiQuestionAnswer1RadioBo = nil
guiQuestionAnswer2RadioBo = nil
guiQuestionAnswer3RadioBo = nil
guiQuestionWindowBo = nil
guiFinalPassTextLabelBo = nil
guiFinalFailTextLabelBo = nil
guiFinalRegisterButtonBo = nil
guiFinalCloseButtonBo = nil
guiFinishWindowBo = nil

-- variable for the max number of possible questions
local NoQuestions = 10
local NoQuestionToAnswer = 7
local correctAnswers = 0
local passPercent = 80
		
selection = {}

-- functon makes the intro window for the quiz
function createlicenseBoatTestIntroWindow()
	showCursor(true)
	local screenwidth, screenheight = guiGetScreenSize ()
	local Width = 450
	local Height = 200
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
	
	guiIntroWindowBo = guiCreateWindow ( X , Y , Width , Height , "Driving Theory Test" , false )
	
	guiCreateStaticImage (0.35, 0.1, 0.3, 0.2, "banner.png", true, guiIntroWindowBo)
	
	guiIntroLabel1Bo = guiCreateLabel(0, 0.3,1, 0.5, [[You will now proceed with the boating theory test. You will
be given seven questions based on boating theory. You must score
a minimum of 90 percent to pass.

Good luck.]], true, guiIntroWindowBo)
	
	guiLabelSetHorizontalAlign ( guiIntroLabel1Bo, "center", true )
	guiSetFont ( guiIntroLabel1Bo,"default-bold-small")
	
	guiIntroProceedButtonBo = guiCreateButton ( 0.4 , 0.75 , 0.2, 0.1 , "Start Test" , true ,guiIntroWindowBo)
	
	addEventHandler ( "onClientGUIClick", guiIntroProceedButtonBo,  function(button, state)
		if(button == "left" and state == "up") then
		
			-- start the quiz and hide the intro window
			startBoatLicenceTest()
			guiSetVisible(guiIntroWindowBo, false)
		
		end
	end, false)
	
end


-- function create the question window
function createBoatLicenseQuestionWindow(number)

	local screenwidth, screenheight = guiGetScreenSize ()
	
	local Width = 450
	local Height = 200
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
	
	-- create the window
	guiQuestionWindowBo = guiCreateWindow ( X , Y , Width , Height , "Question "..number.." of "..NoQuestionToAnswer , false )
	
	guiQuestionLabelBo = guiCreateLabel(0.1, 0.2, 0.9, 0.2, selection[number][1], true, guiQuestionWindowBo)
	guiSetFont ( guiQuestionLabelBo,"default-bold-small")
	guiLabelSetHorizontalAlign ( guiQuestionLabelBo, "left", true)
	
	
	if not(selection[number][2]== "nil") then
		guiQuestionAnswer1RadioBo = guiCreateRadioButton(0.1, 0.4, 0.9,0.1, selection[number][2], true,guiQuestionWindowBo)
	end
	
	if not(selection[number][3] == "nil") then
		guiQuestionAnswer2RadioBo = guiCreateRadioButton(0.1, 0.5, 0.9,0.1, selection[number][3], true,guiQuestionWindowBo)
	end
	
	if not(selection[number][4]== "nil") then
		guiQuestionAnswer3RadioBo = guiCreateRadioButton(0.1, 0.6, 0.9,0.1, selection[number][4], true,guiQuestionWindowBo)
	end
	
	-- if there are more questions to go, then create a "next question" button
	if(number < NoQuestionToAnswer) then
		guiQuestionNextButtonBo = guiCreateButton ( 0.4 , 0.75 , 0.2, 0.1 , "Next Question" , true ,guiQuestionWindowBo)
		
		addEventHandler ( "onClientGUIClick", guiQuestionNextButtonBo,  function(button, state)
			if(button == "left" and state == "up") then
				
				local selectedAnswer = 0
			
				-- check all the radio buttons and seleted the selectedAnswer variabe to the answer that has been selected
				if(guiRadioButtonGetSelected(guiQuestionAnswer1RadioBo)) then
					selectedAnswer = 1
				elseif(guiRadioButtonGetSelected(guiQuestionAnswer2RadioBo)) then
					selectedAnswer = 2
				elseif(guiRadioButtonGetSelected(guiQuestionAnswer3RadioBo)) then
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
					guiSetVisible(guiQuestionWindowBo, false)
					createBoatLicenseQuestionWindow(number+1)
				end
			end
		end, false)
		
	else
		guiQuestionSumbitButtonBo = guiCreateButton ( 0.4 , 0.75 , 0.3, 0.1 , "Submit Answers" , true ,guiQuestionWindowBo)
		
		-- handler for when the player clicks submit
		addEventHandler ( "onClientGUIClick", guiQuestionSumbitButtonBo,  function(button, state)
			if(button == "left" and state == "up") then
				
				local selectedAnswer = 0
			
				-- check all the radio buttons and seleted the selectedAnswer variabe to the answer that has been selected
				if(guiRadioButtonGetSelected(guiQuestionAnswer1RadioBo)) then
					selectedAnswer = 1
				elseif(guiRadioButtonGetSelected(guiQuestionAnswer2RadioBo)) then
					selectedAnswer = 2
				elseif(guiRadioButtonGetSelected(guiQuestionAnswer3RadioBo)) then
					selectedAnswer = 3
				elseif(guiRadioButtonGetSelected(guiQuestionAnswer4RadioBo)) then
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
					guiSetVisible(guiQuestionWindowBo, false)
					createBoatTestFinishWindow()


				end
			end
		end, false)
	end
end


-- funciton create the window that tells the
function createBoatTestFinishWindow()

	local score = math.floor((correctAnswers/NoQuestionToAnswer)*100)

	local screenwidth, screenheight = guiGetScreenSize ()
		
	local Width = 450
	local Height = 200
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
		
	-- create the window
	guiFinishWindowBo = guiCreateWindow ( X , Y , Width , Height , "End of test.", false )
	
	if(score >= passPercent) then
	
		guiCreateStaticImage (0.35, 0.1, 0.3, 0.2, "pass.png", true, guiFinishWindowBo)
	
		guiFinalPassLabelBo = guiCreateLabel(0, 0.3, 1, 0.1, "Congratulations! You have passed the boating theory test.", true, guiFinishWindowBo)
		guiSetFont ( guiFinalPassLabelBo,"default-bold-small")
		guiLabelSetHorizontalAlign ( guiFinalPassLabelBo, "center")
		guiLabelSetColor ( guiFinalPassLabelBo ,0, 255, 0 )
		
		guiFinalPassTextLabelBo = guiCreateLabel(0, 0.4, 1, 0.4, "You scored "..score.."%, and the pass mark is "..passPercent.."%. Well done!" ,true, guiFinishWindowBo)
		guiLabelSetHorizontalAlign ( guiFinalPassTextLabelBo, "center", true)
		
		guiFinalRegisterButtonBo = guiCreateButton ( 0.35 , 0.8 , 0.3, 0.1 , "Continue" , true ,guiFinishWindowBo)
		
		-- if the player has passed the quiz and clicks on register
		addEventHandler ( "onClientGUIClick", guiFinalRegisterButtonBo,  function(button, state)
			if(button == "left" and state == "up") then
				-- set player date to say they have passed the theory.
				

				-- reset their correct answers
				correctAnswers = 0
				toggleAllControls ( true )
				--cleanup
				destroyElement(guiIntroLabel1Bo)
				destroyElement(guiIntroProceedButtonBo)
				destroyElement(guiIntroWindowBo)
				destroyElement(guiQuestionLabelBo)
				destroyElement(guiQuestionAnswer1RadioBo)
				destroyElement(guiQuestionAnswer2RadioBo)
				destroyElement(guiQuestionAnswer3RadioBo)
				destroyElement(guiQuestionWindowBo)
				destroyElement(guiFinalPassTextLabelBo)
				destroyElement(guiFinalRegisterButtonBo)
				destroyElement(guiFinishWindowBo)
				guiIntroLabel1Bo = nil
				guiIntroProceedButtonBo = nil
				guiIntroWindowBo = nil
				guiQuestionLabelBo = nil
				guiQuestionAnswer1RadioBo = nil
				guiQuestionAnswer2RadioBo = nil
				guiQuestionAnswer3RadioBo = nil
				guiQuestionWindowBo = nil
				guiFinalPassTextLabelBo = nil
				guiFinalRegisterButtonBo = nil
				guiFinishWindowBo = nil
				
				correctAnswers = 0
				selection = {}
				
				showCursor(false)
				
				triggerServerEvent("acceptBoatLicense", getLocalPlayer())
			end
		end, false)
		
	else -- player has failed, 
	
		guiCreateStaticImage (0.35, 0.1, 0.3, 0.2, "fail.png", true, guiFinishWindowBo)
	
		guiFinalFailLabelBo = guiCreateLabel(0, 0.3, 1, 0.1, "Sorry, you have not passed this time.", true, guiFinishWindowBo)
		guiSetFont ( guiFinalFailLabelBo,"default-bold-small")
		guiLabelSetHorizontalAlign ( guiFinalFailLabelBo, "center")
		guiLabelSetColor ( guiFinalFailLabelBo ,255, 0, 0 )
		
		guiFinalFailTextLabelBo = guiCreateLabel(0, 0.4, 1, 0.4, "You scored "..math.ceil(score).."%, and the pass mark is "..passPercent.."%." ,true, guiFinishWindowBo)
		guiLabelSetHorizontalAlign ( guiFinalFailTextLabelBo, "center", true)
		
		guiFinalCloseButtonBo = guiCreateButton ( 0.2 , 0.8 , 0.25, 0.1 , "Close" , true ,guiFinishWindowBo)
		
		-- if player click the close button
		addEventHandler ( "onClientGUIClick", guiFinalCloseButtonBo,  function(button, state)
			if(button == "left" and state == "up") then
				destroyElement(guiIntroLabel1Bo)
				destroyElement(guiIntroProceedButtonBo)
				destroyElement(guiIntroWindowBo)
				destroyElement(guiQuestionLabelBo)
				destroyElement(guiQuestionAnswer1RadioBo)
				destroyElement(guiQuestionAnswer2RadioBo)
				destroyElement(guiQuestionAnswer3RadioBo)
				destroyElement(guiQuestionWindowBo)
				destroyElement(guiFinalPassTextLabelBo)
				destroyElement(guiFinalRegisterButtonBo)
				destroyElement(guiFinishWindowBo)
				guiIntroLabel1Bo = nil
				guiIntroProceedButtonBo = nil
				guiIntroWindowBo = nil
				guiQuestionLabelBo = nil
				guiQuestionAnswer1RadioBo = nil
				guiQuestionAnswer2RadioBo = nil
				guiQuestionAnswer3RadioBo = nil
				guiQuestionWindowBo = nil
				guiFinalPassTextLabelBo = nil
				guiFinalRegisterButtonBo = nil
				guiFinishWindowBo = nil
				
				selection = {}
				correctAnswers = 0
				
				showCursor(false)
			end
		end, false)
	end
	
end
 
 -- function starts the quiz
 function startBoatLicenceTest()
 
	-- choose a random set of questions
	chooseBoatTestQuestions()
	-- create the question window with question number 1
	createBoatLicenseQuestionWindow(1)
 
 end
 
 
 -- functions chooses the questions to be used for the quiz
 function chooseBoatTestQuestions()
 
	-- loop through selections and make each one a random question
	for i=1, 10 do
		-- pick a random number between 1 and the max number of questions
		local number = math.random(1, NoQuestions)
		
		-- check to see if the question has already been selected
		if(testBoatQuestionAlreadyUsed(number)) then
			repeat -- if it has, keep changing the number until it hasn't
				number = math.random(1, NoQuestions)
			until (testQuestionAlreadyUsed(number) == false)
		end
		
		-- set the question to the random one
		selection[i] = questionsBoat[number]
	end
 end
 
 
 -- function returns true if the queston is already used
 function testBoatQuestionAlreadyUsed(number)
 
	local same = 0
 
	-- loop through all the current selected questions
	for i, j in pairs(selection) do
		-- if a selected question is the same as the new question
		if(j[1] == questionsBoat[number][1]) then
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