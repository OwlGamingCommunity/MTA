local gui = {}
local curskin = 1
local dummyPed = nil
local languageselected = 1
local selectedMonth1 = "January"
local scrDay = 1

function newCharacter_init()
	guiSetInputEnabled(true)
	setCameraInterior(14)
	setCameraMatrix(254.7190,  -41.1370,  1002, 256.7190,  -41.1370,  1002 )
	dummyPed = createPed(217, 258,  -42,  1002)
	setElementInterior(dummyPed, 14)
	setElementInterior(getLocalPlayer(), 14)
	setPedRotation(dummyPed, 87)
	setElementDimension(dummyPed, getElementDimension(getLocalPlayer()))
	fadeCamera ( true , 1, 0,0,0 )
	local screenX, screenY = guiGetScreenSize()

	gui["_root"] = guiCreateStaticImage(10, screenY/2-225, 255, 475, ":resources/window_body.png", false)
	--guiWindowSetSizable(gui["_root"], false)

	gui["lblCharName"] = guiCreateLabel(10, 25, 91, 16, "Name:", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblCharName"], "left", false)
	guiLabelSetVerticalAlign(gui["lblCharName"], "center")

	gui["txtCharName"] = guiCreateEdit(60, 24, 180, 22, "", false, gui["_root"])
	guiEditSetMaxLength(gui["txtCharName"], 32767)

	gui["lblCharNameExplanation"] = guiCreateLabel(10, 40, 240, 80,"This needs to be in the following format: \n     Firstname Lastname\nFor example: Taylor Jackson.\nYou are not allowed to use famous names.", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblCharNameExplanation"], "left", false)
	guiLabelSetVerticalAlign(gui["lblCharNameExplanation"], "center")

--[[	gui["lblCharDesc"] = guiCreateLabel(10, 125, 230, 100, "When you first spawn type /editlook and describe your character in more detail.", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblCharDesc"], "left", false)
	guiLabelSetVerticalAlign(gui["lblCharDesc"], "center")]]--
	--[[
	gui["memCharDesc"] = guiCreateMemo(10, 145, 231,100, "", false, gui["_root"])

	gui["lblCharDescExplanation"] = guiCreateLabel(10, 245, 231, 61, "Fill in an description of your character, for \nexample how your character looks and\nother special remarks. There is a minimum\nof 50 characters.", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblCharDescExplanation"], "left", false)
	guiLabelSetVerticalAlign(gui["lblCharDescExplanation"], "center")]]

	gui["lblGender"] = guiCreateLabel(10, 160, 46, 13, "Gender:", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblGender"], "left", false)
	guiLabelSetVerticalAlign(gui["lblGender"], "center")
	gui["rbMale"] = guiCreateRadioButton(90, 160, 51, 13, "Male", false, gui["_root"])
	gui["rbFemale"] = guiCreateRadioButton(150, 160, 82, 13, "Female", false, gui["_root"])
	guiRadioButtonSetSelected ( gui["rbMale"], true)
	addEventHandler("onClientGUIClick", gui["rbMale"], newCharacter_updateGender, false)
	addEventHandler("onClientGUIClick", gui["rbFemale"], newCharacter_updateGender, false)

	gui["lblSkin"] = guiCreateLabel(10, 180, 80, 16, "Skin:", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblSkin"], "left", false)
	guiLabelSetVerticalAlign(gui["lblSkin"], "center")

	gui["btnPrevSkin"] = guiCreateButton(50, 180, 80, 16, "Previous", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["btnPrevSkin"], newCharacter_updateGender, false)
	gui["btnNextSkin"] = guiCreateButton(150, 180, 80, 16, "Next", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["btnNextSkin"], newCharacter_updateGender, false)

	gui["lblRace"] = guiCreateLabel(10, 140, 111, 16, "Race:", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblRace"], "left", false)
	guiLabelSetVerticalAlign(gui["lblRace"], "center")

	gui["chkBlack"] =  guiCreateCheckBox ( 60, 140, 55, 16, "Black", true, false, gui["_root"] )
	addEventHandler("onClientGUIClick", gui["chkBlack"] , newCharacter_raceFix, false)
	gui["chkWhite"] =  guiCreateCheckBox ( 120, 140, 55, 16, "White", false, false, gui["_root"] )
	addEventHandler("onClientGUIClick", gui["chkWhite"] , newCharacter_raceFix, false)
	gui["chkAsian"] =  guiCreateCheckBox ( 180, 140, 55, 16, "Asian", false, false, gui["_root"] )
	addEventHandler("onClientGUIClick", gui["chkAsian"] , newCharacter_raceFix, false)

	gui["lblHeight"] = guiCreateLabel(10, 200, 111, 16, "Height", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblHeight"], "left", false)
	guiLabelSetVerticalAlign(gui["lblHeight"], "center")

	gui["scrHeight"] =  guiCreateScrollBar ( 110, 200, 130, 16, true, false, gui["_root"])
	addEventHandler("onClientGUIScroll", gui["scrHeight"], newCharacter_updateScrollBars, false)
	guiSetProperty(gui["scrHeight"], "StepSize", "0.02")

	gui["lblWeight"] = guiCreateLabel(10, 220, 111, 16, "Weight", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblWeight"], "left", false)
	guiLabelSetVerticalAlign(gui["lblWeight"], "center")

	gui["scrWeight"] =  guiCreateScrollBar ( 110, 220, 130, 16, true, false, gui["_root"])
	addEventHandler("onClientGUIScroll", gui["scrWeight"], newCharacter_updateScrollBars, false)
	guiSetProperty(gui["scrWeight"], "StepSize", "0.01")

	gui["lblAge"] = guiCreateLabel(10, 240, 111, 16, "Age", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblAge"], "left", false)
	guiLabelSetVerticalAlign(gui["lblAge"], "center")

	gui["scrAge"] =  guiCreateScrollBar ( 110, 240, 130, 16, true, false, gui["_root"])
	addEventHandler("onClientGUIScroll", gui["scrAge"], newCharacter_updateScrollBars, false)
	guiSetProperty(gui["scrAge"], "StepSize", "0.0120")

	gui["lblDay"] = guiCreateLabel(10, 282, 111, 16, "Day of birth:", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblDay"], "left", false)
	guiLabelSetVerticalAlign(gui["lblDay"], "center")

	gui["scrDay"] =  guiCreateScrollBar ( 110, 285, 130, 16, true, false, gui["_root"])
	addEventHandler("onClientGUIScroll", gui["scrDay"], newCharacter_updateScrollBars, false)
	guiSetProperty(gui["scrDay"], "StepSize", "0.0125")

	gui["lblMonth"] = guiCreateLabel(10, 260, 111, 16, "Month of birth", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblDay"], "left", false)
	guiLabelSetVerticalAlign(gui["lblDay"], "center")


	gui["drpMonth"] =  guiCreateComboBox ( 110, 260, 130, 16, "January", false, gui["_root"])
	guiComboBoxAdjustHeight(gui["drpMonth"], 15)
	guiComboBoxAddItem(gui["drpMonth"], "January")
	guiComboBoxAddItem(gui["drpMonth"], "February")
	guiComboBoxAddItem(gui["drpMonth"], "March")
	guiComboBoxAddItem(gui["drpMonth"], "April")
	guiComboBoxAddItem(gui["drpMonth"], "May")
	guiComboBoxAddItem(gui["drpMonth"], "June")
	guiComboBoxAddItem(gui["drpMonth"], "July")
	guiComboBoxAddItem(gui["drpMonth"], "August")
	guiComboBoxAddItem(gui["drpMonth"], "September")
	guiComboBoxAddItem(gui["drpMonth"], "October")
	guiComboBoxAddItem(gui["drpMonth"], "November")
	guiComboBoxAddItem(gui["drpMonth"], "December")

	addEventHandler ( "onClientGUIComboBoxAccepted", root,
		function ( comboBox )
			if ( comboBox == gui["drpMonth"] ) then
				local item = guiComboBoxGetSelected ( gui["drpMonth"] )
				selectedMonth1 = tostring ( guiComboBoxGetItemText ( gui["drpMonth"] , item ) )
			end
		end, true)



	gui["lblLanguage"] = guiCreateLabel(10, 305, 111, 16, "Language:", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblLanguage"], "left", false)
	guiLabelSetVerticalAlign(gui["lblLanguage"], "center")

	gui["btnLanguagePrev"] = guiCreateButton(110, 305, 16, 16, "<", false, gui["_root"])
	gui["lblLanguageDisplay"] = guiCreateLabel(126, 305, 98, 16, "English", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblLanguageDisplay"], "center", true)
	guiLabelSetVerticalAlign(gui["lblLanguageDisplay"], "center", true)

	gui["btnLanguageNext"] = guiCreateButton(224, 305, 16, 16, ">", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["btnLanguagePrev"] , newCharacter_updateLanguage, false)
	addEventHandler("onClientGUIClick", gui["btnLanguageNext"] , newCharacter_updateLanguage, false)

	gui["btnLangs"] = guiCreateButton(10, 330, 231, 41, "All Languages", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["btnLangs"] , newCharacter_viewAllLangs, false)

	gui["btnCancel"] = guiCreateButton(10, 370+5, 231, 41, "Cancel", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["btnCancel"], newCharacter_cancel, false)

	gui["btnCreateChar"] = guiCreateButton(10,410+10, 231, 41, "Create", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["btnCreateChar"], newCharacter_attemptCreateCharacter, false)
	newCharacter_changeSkin()
	newCharacter_updateScrollBars()
end

function newCharacter_viewAllLangs(button)
	if (source == gui["btnLangs"] and button == "left") then
		if isElement(gui['langWindow']) then return false end

		gui['langWindow'] = guiCreateWindow(720, 339, 339, 446, "Languages", false)
		guiWindowSetSizable(gui['langWindow'], false)
		showCursor(true)
	
		gui['langWindowGrid'] = guiCreateGridList(9, 28, 320, 379, false, gui['langWindow'])
		guiGridListAddColumn(gui['langWindowGrid'], "Languages", 0.9)
	
		for _, value in ipairs(exports['language-system']:getLanguageList()) do 
			guiGridListAddRow(gui['langWindowGrid'], value)
		end
			
		gui['langWindowCloseBtn'] = guiCreateButton(9, 411, 320, 25, "Close", false, gui['langWindow'])
			
		addEventHandler("onClientGUIClick", gui['langWindowCloseBtn'], function(button)
			if (source == gui['langWindowCloseBtn'] and button == "left") then 
				destroyElement(gui['langWindow'])
				gui['langWindow'] = nil
			end
		end)
	
		addEventHandler("onClientGUIDoubleClick", gui['langWindowGrid'], function(button)
		if (button == "left") then 
			local row = guiGridListGetSelectedItem(gui['langWindowGrid'])
			local selectedLang = guiGridListGetItemText(gui['langWindowGrid'], row, 1)
			guiSetText(gui["lblLanguageDisplay"], exports['language-system']:getLanguageName(row + 1))
			languageselected = row + 1
			end
		end)
	end
end

function newCharacter_raceFix()
	guiCheckBoxSetSelected ( gui["chkAsian"], false )
	guiCheckBoxSetSelected ( gui["chkWhite"], false )
	guiCheckBoxSetSelected ( gui["chkBlack"], false )
	if (source == gui["chkBlack"]) then
		guiCheckBoxSetSelected ( gui["chkBlack"], true )
	elseif (source == gui["chkWhite"]) then
		guiCheckBoxSetSelected ( gui["chkWhite"], true )
	elseif (source == gui["chkAsian"]) then
		guiCheckBoxSetSelected ( gui["chkAsian"], true )
	end

	curskin = 1
	newCharacter_changeSkin(0)
end

function newCharacter_updateGender()
	local diff = 0
	if (source == gui["btnPrevSkin"]) then
		diff = -1
	elseif (source == gui["btnNextSkin"]) then
		diff = 1
	else
		curskin = 1
	end
	newCharacter_changeSkin(diff)
end

function newCharacter_updateLanguage()

	if source == gui["btnLanguagePrev"] then
		if languageselected == 1 then
			languageselected = call( getResourceFromName( "language-system" ), "getLanguageCount" )
		else
			languageselected = languageselected - 1
		end
	elseif source == gui["btnLanguageNext"] then
		if languageselected == call( getResourceFromName( "language-system" ), "getLanguageCount" ) then
			languageselected = 1
		else
			languageselected = languageselected + 1
		end
	end

	guiSetText(gui["lblLanguageDisplay"], tostring(call( getResourceFromName( "language-system" ), "getLanguageName", languageselected )))
end

function newCharacter_updateScrollBars()
	local scrollHeight = guiScrollBarGetScrollPosition(gui["scrHeight"])
	scrollHeight = math.floor((scrollHeight / 2) + 150)

	local scrWeight = guiScrollBarGetScrollPosition(gui["scrWeight"])
	scrWeight = math.floor(scrWeight + 50)

	local scrAge = guiScrollBarGetScrollPosition(gui["scrAge"])
	scrAge = math.floor( (scrAge * 0.8 ) + 16 )

	--local scrollHeight = tonumber(guiGetProperty(gui["scrHeight"], "ScrollPosition")) * 100
	--scrollHeight = math.floor((scrollHeight / 2) + 150)
	guiSetText(gui["lblHeight"], "Height: "..scrollHeight.." CM")

	--local scrWeight = tonumber(guiGetProperty(gui["scrWeight"], "ScrollPosition")) * 310
	--scrWeight = math.floor(scrWeight + 40)
	guiSetText(gui["lblWeight"], "Weight: "..scrWeight.." KG")

	--local scrAge = tonumber(guiGetProperty(gui["scrAge"], "ScrollPosition")) * 100
	--scrAge = math.floor( (scrAge * 0.8 ) + 16 )
	guiSetText(gui["lblAge"], "Age: "..scrAge.." years old")

	local year = getBirthday(tonumber(scrAge))
	selectedMonth = monthToNumber(selectedMonth1)
	--outputDebugString(selectedMonth)
	local dayCap = daysInMonth(selectedMonth, year) or 31

	scrDay = (tonumber(guiScrollBarGetScrollPosition(gui["scrDay"]))+1)/100
	scrDay = math.floor( scrDay*dayCap )
	if scrDay == 0 then
		scrDay = 1
	end

	guiSetText(gui["lblDay"], "Day of birth: "..(scrDay or "1"))
end

function newCharacter_changeSkin(diff)
	local array = newCharacters_getSkinArray()
	local skin = 0
	if (diff ~= nil) then
		curskin = curskin + diff
	end

	if (curskin > #array or curskin < 1) then
		curskin = 1
		skin = array[1]
	else
		curskin = curskin
		skin = array[curskin]
	end

	if skin ~= nil then
		setElementModel(dummyPed, tonumber(skin))
	end
end

function newCharacters_getSkinArray()
	local array = { }
	if (guiCheckBoxGetSelected( gui["chkBlack"] )) then -- BLACK
		if (guiRadioButtonGetSelected( gui["rbMale"] )) then -- BLACK MALE
			array = blackMales
		elseif (guiRadioButtonGetSelected( gui["rbFemale"] )) then -- BLACK FEMALE
			array = blackFemales
		else
			outputChatBox("Select a gender first!", 0, 255, 0)
		end
	elseif ( guiCheckBoxGetSelected( gui["chkWhite"] ) ) then -- WHITE
		if ( guiRadioButtonGetSelected( gui["rbMale"] ) ) then -- WHITE MALE
			array = whiteMales
		elseif ( guiRadioButtonGetSelected( gui["rbFemale"] ) ) then -- WHITE FEMALE
			array = whiteFemales
		else
			outputChatBox("Select a gender first!", 0, 255, 0)
		end
	elseif ( guiCheckBoxGetSelected( gui["chkAsian"] ) ) then -- ASIAN
		if ( guiRadioButtonGetSelected( gui["rbMale"] ) ) then -- ASIAN MALE
			array = asianMales
		elseif ( guiRadioButtonGetSelected( gui["rbFemale"] ) ) then -- ASIAN FEMALE
			array = asianFemales
		else
			outputChatBox("Select a gender first!", 0, 255, 0)
		end
	end
	return array
end

function newCharacter_cancel(hideSelection)
	guiSetInputEnabled(false)
	destroyElement(dummyPed)
	destroyElement(gui["_root"])
	if gui['langWindow'] then
		destroyElement(gui['langWindow'])
	end
	gui = {}
	curskin = 1
	dummyPed = nil
	languageselected = 1
	if hideSelection ~= true then
		Characters_showSelection()
	end
	clearChat()
end

function newCharacter_attemptCreateCharacter()
	local characterName = guiGetText(gui["txtCharName"])
	local nameCheckPassed, nameCheckError = checkValidCharacterName(characterName)
	if not nameCheckPassed then
		LoginScreen_showWarningMessage( "Error processing your character name:\n".. nameCheckError )
		return
	end
	--[[
	local characterDescription = guiGetText(gui["memCharDesc"])
	if #characterDescription < 50 then
		LoginScreen_showWarningMessage( "Error processing your character\ndescription: Not long enough." )
		return
	elseif #characterDescription > 128 then
		LoginScreen_showWarningMessage( "Error processing your character\ndescription: Too long." )
		return
	end]]

	local race = 0
	if (guiCheckBoxGetSelected(gui["chkBlack"])) then
		race = 0
	elseif (guiCheckBoxGetSelected(gui["chkWhite"])) then
		race = 1
	elseif (guiCheckBoxGetSelected(gui["chkAsian"])) then
		race = 2
	else
		LoginScreen_showWarningMessage( "Error processing your character race:\nNone selected." )
		return
	end

	local gender = 0
	if (guiRadioButtonGetSelected( gui["rbMale"] )) then
		gender = 0
	elseif (guiRadioButtonGetSelected( gui["rbFemale"] )) then
		gender = 1
	else
		LoginScreen_showWarningMessage( "Error processing your character gender:\nNone selected." )
		return
	end

	local skin = getElementModel( dummyPed )
	if not skin then
		LoginScreen_showWarningMessage( "Error processing your character skin:\nNone selected." )
		return
	end


	local scrollHeight = guiScrollBarGetScrollPosition(gui["scrHeight"])
	scrollHeight = math.floor((scrollHeight / 2) + 150)

	local scrWeight = guiScrollBarGetScrollPosition(gui["scrWeight"])
	scrWeight = math.floor(scrWeight + 50)

	local scrAge = guiScrollBarGetScrollPosition(gui["scrAge"])
	scrAge = math.floor( (scrAge * 0.8 ) + 16 )

	if languageselected == nil then
		LoginScreen_showWarningMessage( "Error processing your character language:\nNone selected." )
		return
	end
	guiSetEnabled(gui["btnCancel"], false)
	guiSetEnabled(gui["btnCreateChar"], false)
	guiSetEnabled(gui["_root"], false)
	fadeCamera(false, 1)
	setTimer(function ()
		selectStartPointGUI(characterName, characterDescription, race, gender, skin, scrollHeight, scrWeight, scrAge, languageselected, selectedMonth, scrDay) --This is the correct place. /MAXIME
	end, 1000, 1)
end

function newCharacter_response(statusID, statusSubID)
	if (statusID == 1) then
		LoginScreen_showWarningMessage( "Oops, something went wrong. Try again\nor contact an administrator.\nError ACC"..tostring(statusSubID) )
	elseif (statusID == 2) then
		if (statusSubID == 1) then
			LoginScreen_showWarningMessage( "This charactername is already in\nuse, sorry :(!" )
		else
			LoginScreen_showWarningMessage( "Oops, something went wrong. Try again\nor contact an administrator.\nError ACD"..tostring(statusSubID) )
		end
	elseif (statusID == 3) then
		newCharacter_cancel(true)
		triggerServerEvent("accounts:characters:spawn", getLocalPlayer(), statusSubID, nil, nil, nil, nil, true)
		triggerServerEvent("updateCharacters", getLocalPlayer())
		--selectStartPointGUI(statusSubID) --Turned out this not where we should have started LOL /Max
		return
	end

	guiSetEnabled(gui["btnCancel"], true)
	guiSetEnabled(gui["btnCreateChar"], true)
	guiSetEnabled(gui["_root"], true)

end
addEventHandler("accounts:characters:new", getRootElement(), newCharacter_response)

local wSelectStartPoint = nil
function selectStartPointGUI(characterName, characterDescription, race, gender, skin, scrollHeight, scrWeight, scrAge, languageselected, selectedMonth, scrDay )
	closeSelectStartPoint() -- Make sure the GUI won't get duplicated and stuck on client's screen at any case.
	showCursor(true)
	guiSetInputEnabled(true)

	--config
	local locations = {
					-- x, 			y,					 z, 			rot    		int, 	dim 	Location Name
		["default"] = {1168.6484375, -1412.576171875, 13.497941017151, 357.72854614258, 0, 0, "A bus stop near the mall"},
		["igs"] = { 1922.9072265625, -1760.6982421875, 13.546875, 0,			0, 		0, 		"A bus stop next in Idlewood"},
		["bus"] = {1749.509765625, -1860.5087890625, 13.578649520874, 359.0744, 	0, 		0, 		"Unity Bus Station"},
		["metro"] = {808.88671875, -1354.6513671875, -0.5078125, 139.5092, 			0, 		0,		"Metro Station"},
		["air"] = {1691.6455078125, -2334.001953125, 13.546875, 0.10711, 			0, 		0,		"Los Santos International Airport"},
		["boat"] = {2809.66015625, -2436.7236328125, 13.628322601318, 90.8995, 		0, 		0,		"Santa Maria Dock"},
	}

	wSelectStartPoint = guiCreateWindow(0,0, 300, 250, "How do you arrive in Los Santos?", false)
	exports.global:centerWindow(wSelectStartPoint)

	local busButton = guiCreateButton(40, 40, 100, 60, "Bus", false, wSelectStartPoint)
	addEventHandler("onClientGUIClick", busButton, function ()
		newCharacter_cancel(true)
		triggerServerEvent("accounts:characters:new", getLocalPlayer(), characterName, characterDescription, race, gender, skin, scrollHeight, scrWeight, scrAge, languageselected, selectedMonth, scrDay, locations.bus)
		closeSelectStartPoint()
	end)

	local metroButton = guiCreateButton(40, 120, 100, 60, "Metro", false, wSelectStartPoint)
	addEventHandler("onClientGUIClick", metroButton, function()
		newCharacter_cancel(true)
		triggerServerEvent("accounts:characters:new", getLocalPlayer(), characterName, characterDescription, race, gender, skin, scrollHeight, scrWeight, scrAge, languageselected, selectedMonth, scrDay, locations.metro)
		closeSelectStartPoint()
	end)

	local airButton = guiCreateButton(160, 40, 100, 60, "Airplane", false, wSelectStartPoint)
	addEventHandler("onClientGUIClick", airButton, function()
		newCharacter_cancel(true)
		triggerServerEvent("accounts:characters:new", getLocalPlayer(), characterName, characterDescription, race, gender, skin, scrollHeight, scrWeight, scrAge, languageselected, selectedMonth, scrDay, locations.air)
		closeSelectStartPoint()
	end)

	local boatButton = guiCreateButton(160, 120, 100, 60, "Boat", false, wSelectStartPoint)
	addEventHandler("onClientGUIClick", boatButton, function()
		newCharacter_cancel(true)
		triggerServerEvent("accounts:characters:new", getLocalPlayer(), characterName, characterDescription, race, gender, skin, scrollHeight, scrWeight, scrAge, languageselected, selectedMonth, scrDay, locations.boat)
		closeSelectStartPoint()
	end)

	--Temporarily disabled new character spawnpoint selector until we set up all the spawnpoint's shops and locations properly. /Maxime
	triggerServerEvent("accounts:characters:new", getLocalPlayer(), characterName, characterDescription, race, gender, skin, scrollHeight, scrWeight, scrAge, languageselected, selectedMonth, scrDay, locations.default)
	closeSelectStartPoint()
	-- end of the disability
end

function closeSelectStartPoint()
	if wSelectStartPoint and isElement(wSelectStartPoint) then
		destroyElement(wSelectStartPoint)
		showCursor(false)
		guiSetInputEnabled(false)
	end
end

function isThisYearLeap(year)
     if (tonumber(year)%4) == 0 then
          return true
     else
          return false
     end
end

function monthToNumber(monthName)
	if not monthName then
		return 1
	else
		if monthName == "January" then
			return 1
		elseif monthName == "February" then
			return 2
		elseif monthName == "March" then
			return 3
		elseif monthName == "April" then
			return 4
		elseif monthName == "May" then
			return 5
		elseif monthName == "June" then
			return 6
		elseif monthName == "July" then
			return 7
		elseif monthName == "August" then
			return 8
		elseif monthName == "September" then
			return 9
		elseif monthName == "October" then
			return 10
		elseif monthName == "November" then
			return 11
		elseif monthName == "December" then
			return 12
		else
			return 1
		end
	end
end

function monthNumberToName(monthNumber)
	if not monthNumber or not tonumber(monthNumber) then
		return "January"
	else
		monthNumber = tonumber(monthNumber)
		if monthNumber == 1 then
			return "January"
		elseif monthNumber == 2 then
			return "February"
		elseif monthNumber == 3 then
			return "March"
		elseif monthNumber == 4 then
			return "April"
		elseif monthNumber == 5 then
			return "May"
		elseif monthNumber == 6 then
			return "June"
		elseif monthNumber == 7 then
			return "July"
		elseif monthNumber == 8 then
			return "August"
		elseif monthNumber == 9 then
			return "September"
		elseif monthNumber == 10 then
			return "October"
		elseif monthNumber == 11 then
			return "November"
		elseif monthNumber == 12 then
			return "December"
		else
			return "January"
		end
	end
end

function daysInMonth(month, year)
	if not month or not year or not tonumber(month) or not tonumber(year) then
		return 31
	else
		month = tonumber(month)
		year = tonumber(year)
	end

	if month == 1 then
		return 31
	elseif month == 2 then
		if isThisYearLeap(year) then
			return 29
		else
			return 28
		end
	elseif month == 3 then
		return 31
	elseif month == 4 then
		 return 30
	elseif month == 5 then
		return 31
	elseif month == 6 then
		return 30
	elseif month == 7 then
		return 31
	elseif month == 8 then
		return 31
	elseif month == 9 then
		return 30
	elseif month == 10 then
		return 31
	elseif month == 11 then
		return 30
	elseif month == 12 then
		return 31
	else
		return 31
	end
end

function getBirthday(age)
	if not age or not tonumber(age) then
		return 2015
	else
		age = tonumber(age)
	end

	local time = getRealTime()
	time.year = time.year + 1900
	return (time.year - age)
end

function getBetterDay(day)
	if not day or not tonumber(day) then
		return "1st"
	else
		day = tonumber(day)
		if day == 1 or day == 21 or day == 31 then
			return day.."st"
		elseif day == 2 or day == 22 then
			return day.."nd"
		elseif day == 3 or day == 23 then
			return day.."rd"
		else
			return day.."th"
		end
	end
end
