local rosie = createPed(141, -1347.033203125, -188.302734375, 14.151561737061)
local lsesOptionMenu = nil
setPedRotation(rosie, 296.709533)
setElementFrozen(rosie, true)
setElementDimension(rosie, 9)
setElementInterior(rosie, 6)
--setPedAnimation(rosie, "INT_OFFICE", "OFF_Sit_Idle_Loop", -1, true, false, false)
setElementData(rosie, "talk", 1, false)
setElementData(rosie, "name", "Rosie Jenkins", false)
--[[
local jacob = createPed(277, -1794.3291015625, 647.0517578125, 960.38513183594)
local lsesOptionMenu = nil
setPedRotation(jacob, 57)
setElementFrozen(jacob, true)
setElementDimension(jacob, 8)
setElementInterior(jacob, 1)
setElementData(jacob, "talk", 1, false)
setElementData(jacob, "name", "Jacob Greenaway", false)]]

function popupSFESPedMenu()
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if not lsesOptionMenu then
		local width, height = 150, 100
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)

		lsesOptionMenu = guiCreateWindow(x, y, width, height, "How can we help you?", false)

		bPhotos = guiCreateButton(0.05, 0.2, 0.87, 0.2, "I need help", true, lsesOptionMenu)
		addEventHandler("onClientGUIClick", bPhotos, helpButtonFunction, false)

		bAdvert = guiCreateButton(0.05, 0.5, 0.87, 0.2, "Appointment", true, lsesOptionMenu)
		addEventHandler("onClientGUIClick", bAdvert, appointmentButtonFunction, false)
		
		bSomethingElse = guiCreateButton(0.05, 0.8, 0.87, 0.2, "I'm fine, thanks.", true, lsesOptionMenu)
		addEventHandler("onClientGUIClick", bSomethingElse, otherButtonFunction, false)
		triggerServerEvent("lses:ped:start", getLocalPlayer(), getElementData(rosie, "name"))
		showCursor(true)
	end
end
addEvent("lses:popupPedMenu", true)
addEventHandler("lses:popupPedMenu", getRootElement(), popupSFESPedMenu)

function closeSFESPedMenu()
	destroyElement(lsesOptionMenu)
	lsesOptionMenu = nil
	showCursor(false)
end

function helpButtonFunction()
	closeSFESPedMenu()
	triggerServerEvent("lses:ped:help", getLocalPlayer(), getElementData(rosie, "name"))
end

function appointmentButtonFunction()
	closeSFESPedMenu()
	triggerServerEvent("lses:ped:appointment", getLocalPlayer(), getElementData(rosie, "name"))
end

function otherButtonFunction()
	closeSFESPedMenu()
end


local pedDialogWindow
local thePed
function pedDialog_hospital(ped)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	thePed = ped
	local width, height = 500, 345
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)
	if pedDialogWindow and isElement(pedDialogWindow) then
		destroyElement(pedDialogWindow)
	end
	pedDialogWindow = guiCreateWindow(x, y, width, height, "Hospital Front Desk", false)

	b1 = guiCreateButton(10, 30, width-20, 40, "I need a doctor now, someone's dying!", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b1,
		function()
			endDialog()
			if thePed then
				triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "local", "We're dispatching a team here ASAP, please remain calm.")
				setTimer(function()
						triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "hospitalpa", "Code Critical at front desk, Code Critical at front desk, response team to front desk ASAP.")
					end, 3000, 1)
			end
		end, false)

	b2 = guiCreateButton(10, 75, width-20, 40, "I need someone to help me or a friend to the Emergency Room.", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b2,
		function()
			endDialog()
			if thePed then
				triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "local", "We're dispatching someone here to help you, please remain calm.")
				setTimer(function()
						triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "hospitalpa", "Staff member to the front desk please to assist a patient to E.R.")
					end, 4000, 1)
			end
		end, false)

	b3 = guiCreateButton(10, 120, width-20, 40, "I'm here to schedule an appointment or check-up.", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b3,
		function()
			endDialog()
			if thePed then
				triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "local", "Okay, I'm sending someone down.")
				setTimer(function()
						triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "hospitalpa", "Staff member to the front desk please to assist a patient for check-up or appointment.")
					end, 5000, 1)
			end
		end, false)

	b4 = guiCreateButton(10, 165, width-20, 40, "I'm here to see a friend who is staying in the hospital for a extended period.", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b4,
		function()
			endDialog()
			if thePed then
				triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "local", "Please head to the Inpatient Services room, down the hall and first elevator on the left. A nurse will be there to assist you.")
			end
		end, false)

	b5 = guiCreateButton(10, 210, width-20, 40, "I'm here to see a friend who is in the Emergency Room or Outpatient Services.", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b5,
		function()
			endDialog()
			if thePed then
				triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "local", "I'm sending a staff member down to assist you, please be mindful we have a 1 visitor policy in the E.R.")
				setTimer(function()
						triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "hospitalpa", "Staff member to the front desk please to assist a visitor to the E.R or Outpatient Services.")
					end, 5000, 1)
			end
		end, false)

	b6 = guiCreateButton(10, 255, width-20, 40, "I just need to talk to a staff member.", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b6,
		function()
			endDialog()
			if thePed then
				triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "local", "Okay, I'll send one down.")
				setTimer(function()
						triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "hospitalpa", "Staff member to the front desk please to assist a visitor requesting a staff member.")
					end, 5000, 1)
			end
		end, false)

	b7 = guiCreateButton(10, 300, width-20, 40, "Uhm. Never mind.", false, pedDialogWindow)
	addEventHandler("onClientGUIClick", b7, pedDialog_hospital_noHelp, false)

	--showCursor(true)

	triggerServerEvent("airport:ped:outputchat", getResourceRootElement(), thePed, "local", "Welcome to the LSIA reception. Can I help you?")
end
addEvent("lses:ped:hospitalfrontdesk", true)
addEventHandler("lses:ped:hospitalfrontdesk", getRootElement(), pedDialog_hospital)

function endDialog()
	if pedDialogWindow and isElement(pedDialogWindow) then
		destroyElement(pedDialogWindow)
		pedDialogWindow = nil
	end
end

function pedDialog_hospital_noHelp()
	endDialog()
	if thePed then
		triggerServerEvent("lses:ped:outputchat", getResourceRootElement(), thePed, "local", "Okay.")
	end
end