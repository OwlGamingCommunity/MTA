local wPedRightClick, bTalkToPed, bClosePedMenu, closing, selectedElement = nil
local wGui = nil
local sent = false
local localPlayer = getLocalPlayer()

function pedDamage()
	cancelEvent()
end
addEventHandler("onClientPedDamage", getResourceRootElement(), pedDamage)

function onQuestionShow(questionArray)
	selectedElement = source
	local Width = 300
	local Height = 450
	local screenwidth, screenheight = guiGetScreenSize()
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
	local verticalPos = 0.05
	if not (wGui) then
		wGui = guiCreateStaticImage(X, Y, Width, Height, ":resources/window_body.png", false )

		for answerID, answerStr in ipairs(questionArray) do
			if (answerStr) then
				local option = guiCreateButton( 0.05, verticalPos, 0.9, 0.2, answerStr, true, wGui )
				setElementData(option, "option", answerID, false)
				setElementData(option, "optionstr", answerStr, false)
				addEventHandler( "onClientGUIClick", option, answerConvo, false )
			end
			verticalPos = verticalPos + 0.2
		end
		showCursor(true)
	end
end
addEvent( "fuel:convo", true )
addEventHandler( "fuel:convo", getRootElement(), onQuestionShow )

function answerConvo( mouseButton )
	if (mouseButton == "left") then
		theButton = source
		local option = getElementData(theButton, "option")
		if (option) then
			local optionstr = getElementData(theButton, "optionstr")
			triggerServerEvent("fuel:convo", selectedElement, option, optionstr)
			cleanGUI()
		end
	end
end

function cleanGUI()
	destroyElement(wGui)
	wGui = nil
	showCursor(false)
end

local wPIN, Label_Keypad_Number, Label_Error, bEnter = nil
local enteredCode = "0000"
function requestATMInterfacePIN(theATM, atmLocationName)
	selectedElement = source
	if getElementData(getLocalPlayer(), "exclusiveGUI") or isPedDead(localPlayer) then
		return false
	end
	if not (wPIN) then
		setElementData(getLocalPlayer(), "exclusiveGUI", true, false)
		local width, height = 600, 400
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)

		wPIN = guiCreateWindow(x, y, width, height, "POS Machine at "..(atmLocationName or "Unknown Area"), false)
			guiWindowSetSizable(wPIN, false)

		local tabPanel = guiCreateTabPanel(0.05, 0.05, 0.9, 0.85, true, wPIN)
		local tabPersonal = guiCreateTab("Please Enter PIN code", tabPanel)

		local posXOffset = 265
		local posYOffset = -105
		local soundID = 33
		enteredCode = "0000"

        Label_Keypad_Number = guiCreateLabel(20,30,220,80,enteredCode,false,tabPersonal)
            guiSetFont(Label_Keypad_Number,"sa-gothic")
            guiLabelSetVerticalAlign(Label_Keypad_Number,"center")
            guiLabelSetHorizontalAlign(Label_Keypad_Number,"center",false)
		Label_Error = guiCreateLabel(20,90,220,30,"Please enter 4 digitals of PIN Code",false,tabPersonal)
			guiLabelSetVerticalAlign(Label_Error,"center")
            guiLabelSetHorizontalAlign(Label_Error,"center",false)
        local Button_1 = guiCreateButton(0+posXOffset,116+posYOffset,78,66,"1",false,tabPersonal)
            guiSetFont(Button_1,"sa-header")
		addEventHandler( "onClientGUIClick", Button_1, function ()
			playSoundFrontEnd ( soundID )
			updateCode(guiGetText(Button_1))
		end, false )

        local Button_2 = guiCreateButton(88+posXOffset,116+posYOffset,78,66,"2",false,tabPersonal)
            guiSetFont(Button_2,"sa-header")
		addEventHandler( "onClientGUIClick", Button_2, function ()
			playSoundFrontEnd ( soundID )
			updateCode(guiGetText(Button_2))
		end, false )

        local Button_3 = guiCreateButton(176+posXOffset,116+posYOffset,78,66,"3",false,tabPersonal)
            guiSetFont(Button_3,"sa-header")
		addEventHandler( "onClientGUIClick", Button_3, function ()
			playSoundFrontEnd ( soundID )
			updateCode(guiGetText(Button_3))
		end, false )

        local Button_4 = guiCreateButton(0+posXOffset,192+posYOffset,78,66,"4",false,tabPersonal)
            guiSetFont(Button_4,"sa-header")
		addEventHandler( "onClientGUIClick", Button_4, function ()
			playSoundFrontEnd ( soundID )
			updateCode(guiGetText(Button_4))
		end, false )

        local Button_5 = guiCreateButton(88+posXOffset,192+posYOffset,78,66,"5",false,tabPersonal)
            guiSetFont(Button_5,"sa-header")
		addEventHandler( "onClientGUIClick", Button_5, function ()
			playSoundFrontEnd ( soundID )
			updateCode(guiGetText(Button_5))
		end, false )

        local Button_6 = guiCreateButton(176+posXOffset,192+posYOffset,78,66,"6",false,tabPersonal)
            guiSetFont(Button_6,"sa-header")
		addEventHandler( "onClientGUIClick", Button_6, function ()
			playSoundFrontEnd ( soundID )
			updateCode(guiGetText(Button_6))
		end, false )

        local Button_7 = guiCreateButton(0+posXOffset,268+posYOffset,78,66,"7",false,tabPersonal)
            guiSetFont(Button_7,"sa-header")
		addEventHandler( "onClientGUIClick", Button_7, function ()
			playSoundFrontEnd ( soundID )
			updateCode(guiGetText(Button_7))
		end, false )

        local Button_8 = guiCreateButton(88+posXOffset,268+posYOffset,78,66,"8",false,tabPersonal)
            guiSetFont(Button_8,"sa-header")
		addEventHandler( "onClientGUIClick", Button_8, function ()
			playSoundFrontEnd ( soundID )
			updateCode(guiGetText(Button_8))
		end, false )

        local Button_9 = guiCreateButton(176+posXOffset,268+posYOffset,78,66,"9",false,tabPersonal)
            guiSetFont(Button_9,"sa-header")
		addEventHandler( "onClientGUIClick", Button_9, function ()
			playSoundFrontEnd ( soundID )
			updateCode(guiGetText(Button_9))
		end, false )

		local Button_0 = guiCreateButton(88+posXOffset,344+posYOffset,78,66,"0",false,tabPersonal)
            guiSetFont(Button_0,"sa-header")
		addEventHandler( "onClientGUIClick", Button_0, function ()
			playSoundFrontEnd ( soundID )
			updateCode(guiGetText(Button_0))
		end, false )

        local Button_star = guiCreateButton(0+posXOffset,344+posYOffset,78,66,"*",false,tabPersonal)
            guiSetFont(Button_star,"sa-header")
		addEventHandler( "onClientGUIClick", Button_star, function ()
			playSoundFrontEnd ( soundID )
		end, false )

        local Button_sharp = guiCreateButton(176+posXOffset,344+posYOffset,78,66,"#",false,tabPersonal)
            guiSetFont(Button_sharp,"sa-header")
		addEventHandler( "onClientGUIClick", Button_sharp, function ()
			playSoundFrontEnd ( soundID )
		end, false )

		bEnter = guiCreateButton(20,268+posYOffset,225,66,"Enter",false,tabPersonal)
		addEventHandler( "onClientGUIClick", bEnter, function ()
			guiSetEnabled(bEnter, false)
			triggerServerEvent("fuel:checkPINCode", localPlayer, enteredCode)
		end, false )

        local bClose = guiCreateButton(20,344+posYOffset,225,66,"Exit",false,tabPersonal)
		addEventHandler( "onClientGUIClick", bClose, function ()
			closeATMInterfacePIN()
		end, false )

		function updateCode(digital)
			enteredCode = enteredCode..digital
			local len = string.len(enteredCode)
			enteredCode = string.sub(enteredCode, len-3, len)
			guiSetText(Label_Keypad_Number, enteredCode)
		end
	end
end
addEvent("fuel:requestATMInterfacePIN", true)
addEventHandler("fuel:requestATMInterfacePIN", getRootElement(), requestATMInterfacePIN)

function respondToATMInterfacePIN(Label_Error_Msg, r,g,b, action, otherInfo)
	enteredCode = "0000"
	if Label_Keypad_Number and Label_Error then
		guiSetText(Label_Keypad_Number, enteredCode)
		guiSetText(Label_Error, Label_Error_Msg)
		guiLabelSetColor(Label_Error, r,g,b)
	end

	if action == "cardRemoved" then
		exports.hud:sendBottomNotification(localPlayer, "Point of Sale Machine", "POS Machine is not working properly due to ATM card was removed.")
		setTimer(closeATMInterfacePIN, 2000, 1)
	elseif action == "failedLessThan3" then
		exports.hud:sendBottomNotification(localPlayer, "Point of Sale Machine", "Access Denied. Entered incorrect PIN.")
		guiSetEnabled(bEnter, true)
	elseif action == "locked" then
		exports.hud:sendBottomNotification(localPlayer, "Point of Sale Machine", "ATM Card Number '"..otherInfo.."' is locked and not usable, please contact the Bank.")
		guiSetEnabled(bEnter, true)
	elseif action == "success" then
		exports.hud:sendBottomNotification(localPlayer, "Point of Sale Machine", "Access Granted!")
		closeATMInterfacePIN()
		local option = 2
		local optionstr = "accepted"
		triggerServerEvent("fuel:convo", selectedElement, option, optionstr)
	end
end
addEvent("fuel:respondToATMInterfacePIN", true)
addEventHandler("fuel:respondToATMInterfacePIN", getRootElement(), respondToATMInterfacePIN)

function closeATMInterfacePIN()
	setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
	showCursor(false)
	--playSoundFrontEnd ( 32 )
	if wPIN then
		destroyElement(wPIN)
		wPIN = nil
	end
end
--PREVENT ABUSER TO CHANGE CHAR
addEventHandler ( "account:changingchar", getRootElement(), closeATMInterfacePIN )
addEventHandler("onClientChangeChar", getRootElement(), closeATMInterfacePIN)
