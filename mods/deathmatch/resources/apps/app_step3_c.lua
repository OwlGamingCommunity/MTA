--MAXIME
local guiStep3 = {}
local info = "Your application is being reviewed..\nPlease stand by!"
function startStep3(infoFromServer)
	triggerEvent("account:hideRules", localPlayer)
	
	destroyGUIPart3()
	if infoFromServer then
		info = infoFromServer
	end
	
	local sWidth,sHeight = guiGetScreenSize() 
	
	local line = 15
	local startY = sHeight*0.45
	local width = 800
	local startX = (sWidth-width)/2
	local panelH = 130
	local panelW = width/2
	local margin = 30
	guiStep3.intro = guiCreateLabel(startX, startY, width, line*10, info , false )
	guiLabelSetHorizontalAlign(guiStep3.intro, "center", true)
	guiLabelSetVerticalAlign(guiStep3.intro, "center", true)
	guiLabelSetColor(guiStep3.intro,0,255,0)
	startX = startX-10
	startY = startY+10
	
	
	guiStep3.back = guiCreateButton ( 0.40, 0.81, 0.1, 0.04, "Server Rules", true)
	guiStep3.retake = guiCreateButton ( 0.5, 0.81, 0.1, 0.04, "Take new application", true)
	guiSetEnabled(guiStep3.retake, false)
	addEventHandler ( "onClientGUIClick", guiStep3.retake, function()
		destroyGUIPart3()
		triggerServerEvent("apps:retakeApplicationPart2", localPlayer)
	end, false)
	addEventHandler ( "onClientGUIClick", guiStep3.back, function()
		killTimer1()
		hideGUIPart(guiStep3)
		triggerEvent("account:showRules",localPlayer, 2)
	end, false)
	
end
addEvent("apps:startStep3", true)
addEventHandler("apps:startStep3", root, startStep3)

function destroyGUIPart3()
	for i, gui in pairs (guiStep3) do
		if gui and isElement(gui) then
			destroyElement(gui)
		end
	end
	guiStep3 = {}
end
addEvent("apps:destroyGUIPart3", true)
addEventHandler("apps:destroyGUIPart3", root, destroyGUIPart3)
