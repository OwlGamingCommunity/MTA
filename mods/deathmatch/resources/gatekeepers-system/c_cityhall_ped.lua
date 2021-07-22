local vmOptionMenu

function popupJesPedMenu()
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	closevmPedMenu()
	local width, height = 200, 150
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)

	vmOptionMenu = guiCreateStaticImage(x, y, width, height, ":resources/window_body.png", false)
	local l1 = guiCreateLabel(0, 0.08, 1, 0.25, "What can I help you with?", true, vmOptionMenu)
	guiLabelSetHorizontalAlign(l1, "center")
	local bJob = guiCreateButton(0.05, 0.3, 0.87, 0.18, "I want to apply for a job.", true, vmOptionMenu)
	addEventHandler("onClientGUIClick", bJob, bJobF, false)

	local bID = guiCreateButton(0.05, 0.5, 0.87, 0.18, "I need a new ID card. ($5)", true, vmOptionMenu)
	addEventHandler("onClientGUIClick", bID, newIDCard, false)

	local bSomethingElse = guiCreateButton(0.05, 0.7, 0.87, 0.18, "I'm fine, thanks.", true, vmOptionMenu)
	addEventHandler("onClientGUIClick", bSomethingElse, otherButtonFunction, false)

	showCursor(true)
end
addEvent("cityhall:jesped", true)
addEventHandler("cityhall:jesped", getRootElement(), popupJesPedMenu)

function closevmPedMenu()
	if vmOptionMenu and isElement(vmOptionMenu) then
		destroyElement(vmOptionMenu)
		vmOptionMenu = nil
	end
	showCursor(false)
end

function bJobF()
	closevmPedMenu()
	triggerEvent("onEmployment", getLocalPlayer())
end

function newIDCard()
	closevmPedMenu()
	triggerServerEvent("cityhall:makeIdCard", getLocalPlayer())
end

function otherButtonFunction()
	closevmPedMenu()
end
