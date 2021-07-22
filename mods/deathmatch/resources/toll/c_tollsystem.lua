local wPedRightClick, bTalkToPed, bClosePedMenu, closing, selectedElement = nil
local wGui = nil
local sent = false

function pedDamage()
	cancelEvent()
end
addEventHandler("onClientPedDamage", getResourceRootElement(), pedDamage)

function onQuestionShow(questionArray)
	selectedElement = source
	local screenwidth, screenheight = guiGetScreenSize()
	local w, h = 150, 75
	local x = (screenwidth - w)/2
	local y = (screenheight - h)/2
	local verticalPos = 0.3
	if not (wGui) then
		wGui = guiCreateStaticImage(x ,y , w, h , ":resources/window_body.png", false)
		local l1 = guiCreateLabel(0, 0.08, 1, 0.25, "Conversation", true, wGui)
		guiLabelSetHorizontalAlign(l1, "center")
		for answerID, answerStr in ipairs(questionArray) do
			if (answerStr) then
				local option = 	guiCreateButton( 0.05, verticalPos, 0.87, 0.25, answerStr, true, wGui )
				setElementData(option, "option", answerID, false)
				setElementData(option, "optionstr", answerStr, false)
				addEventHandler( "onClientGUIClick", option, answerConvo, false )
			end
			verticalPos = verticalPos + 0.3
		end
		showCursor(true)
	end
end
addEvent( "toll:interact", true )
addEventHandler( "toll:interact", getRootElement(), onQuestionShow )

function answerConvo( mouseButton )
	if (mouseButton == "left") then
		theButton = source
		local option = getElementData(theButton, "option")
		if (option) then
			local optionstr = getElementData(theButton, "optionstr")
			triggerServerEvent("toll:interact", selectedElement, option, optionstr)
			cleanGUI()
		end
	end
end

function cleanGUI()
	destroyElement(wGui)
	wGui = nil
	showCursor(false)
end
