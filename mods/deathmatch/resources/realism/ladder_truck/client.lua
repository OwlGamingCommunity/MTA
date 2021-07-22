local startup = true
local ladderState = false
local ladderHgt = 0
local ladderExt = 0
local ladderRot = 180

function makeGUI()
	if not getPedOccupiedVehicle(localPlayer) then
		outputChatBox( "This command doesn't work if you're not in a Ladder Truck!", 255, 194, 14 )
		return
	end
		if getElementModel(getPedOccupiedVehicle(localPlayer)) == 544 and (not controlPanel) then
			local firetruckElement = getPedOccupiedVehicle (localPlayer)

			local ladderHeight = 0
			local ladderExt = 0
			local ladderRot = 0
			if getElementData(firetruckElement, "fdladder:height") then ladderHeight = getElementData(firetruckElement, "fdladder:height") end
			if getElementData(firetruckElement, "fdladder:extend") then ladderExt = getElementData(firetruckElement, "fdladder:extend") end
			if getElementData(firetruckElement, "fdladder:rotation") then ladderRot = getElementData(firetruckElement, "fdladder:rotation") end

			local width, height = 195, 210
			local sx, sy = guiGetScreenSize()
			local posX = (sx/2)-(width/2)
			local posY = (sy/2)-(height/2)

			local screenW, screenH = guiGetScreenSize()
			controlPanel = guiCreateWindow((screenW - 262) / 2, (screenH - 339) / 2, 262, 339, "Ladder Control Panel", false)
			guiWindowSetSizable(controlPanel, false)

			imageUp = guiCreateStaticImage(96, 72, 59, 63, "ladder_truck/img/ladder-upc.png", false, controlPanel)
			imageLeft = guiCreateStaticImage(36, 135, 60, 63, "ladder_truck/img/ladder-leftc.png", false, controlPanel)
			imageDown = guiCreateStaticImage(96, 198, 59, 63, "ladder_truck/img/ladder-downc.png", false, controlPanel)
			imageRight = guiCreateStaticImage(155, 135, 59, 63, "ladder_truck/img/ladder-rightc.png", false, controlPanel)
			closeButton = guiCreateButton(204, 301, 34, 19, "X", false, controlPanel)
			guiSetProperty(closeButton, "NormalTextColour", "FFAAAAAA")
			imageIn = guiCreateStaticImage(96, 261, 60, 63, "ladder_truck/img/ladder-inc.png", false, controlPanel)
			imageOut = guiCreateStaticImage(95, 10, 60, 63, "ladder_truck/img/ladder-outc.png", false, controlPanel)
			
			showCursor(true)
			guiWindowSetSizable (controlPanel, false)
			guiWindowSetMovable (controlPanel, true)
		elseif (controlPanel and (not guiGetVisible(controlPanel))) then
			guiSetVisible(controlPanel, true)
			showCursor(true)
		elseif (controlPanel and guiGetVisible(controlPanel)) then
			guiSetVisible(controlPanel, false)
			showCursor(false)
	end
end
addCommandHandler("lc", makeGUI)


addEventHandler( "onClientMouseEnter", root,
    function()
        if (source == imageUp) then
           guiStaticImageLoadImage( source, "ladder_truck/img/ladder-up.png")
		elseif (source == imageRight) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-right.png")
		elseif (source == imageLeft) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-left.png")
		elseif (source == imageDown) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-down.png")
		elseif (source == imageIn) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-in.png")
		elseif (source == imageOut) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-out.png")	
		end
    end
)

addEventHandler( "onClientMouseLeave", root,
    function()
        if (source == imageUp) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-upc.png")
		elseif (source == imageRight) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-rightc.png")
		elseif (source == imageLeft) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-leftc.png")
		elseif (source == imageDown) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-downc.png")
		elseif (source == imageIn) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-inc.png")
		elseif (source == imageOut) then
			guiStaticImageLoadImage( source, "ladder_truck/img/ladder-outc.png")		
		end	
	end
)

function closeGUI ()
	if (source == closeButton) then
	destroyElement(guiRoot)
	showCursor(false)
	controlPanel = nil
	end
end
addEventHandler ( "onClientGUIClick", getRootElement(), closeGUI)

function ladderControl(btn, state)
	if (source == imageUp) then	
		if (ladderHgt == -69) then return end
		ladderHgt = ladderHgt - 3
		triggerServerEvent("changeHeight", localPlayer, ladderHgt, true)
	elseif (source == imageDown) then	
		if (ladderHgt == 0) then return end
		ladderHgt = ladderHgt + 3
		triggerServerEvent("changeHeight", localPlayer, ladderHgt, true)	
	elseif (source == imageLeft) then	
		ladderRot = ladderRot + 5
		triggerServerEvent("changeRotation", localPlayer, ladderRot, true)	
	elseif (source == imageRight) then	
		ladderRot = ladderRot - 5
		triggerServerEvent("changeRotation", localPlayer, ladderRot, true)	
	elseif (source == imageIn) then	
		if (ladderExt == 0) then return end
		ladderExt = ladderExt + 0.5
		triggerServerEvent("changeLength", localPlayer, ladderExt, true)	
	elseif (source == imageOut) then	
		if (ladderExt == -6) then return end
		ladderExt = ladderExt - 0.5
		triggerServerEvent("changeLength", localPlayer, ladderExt, true)			
	end	
end
addEventHandler( "onClientGUIClick", root, ladderControl)
