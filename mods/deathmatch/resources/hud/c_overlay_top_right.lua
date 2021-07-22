local localPlayer = getLocalPlayer()
local show = false
local width, height = 246,300
local sx, sy = guiGetScreenSize()
local content = {}
local timerClose = nil
local cooldownTime = 20 --seconds
local BizNoteFont20 = dxCreateFont ( ":resources/BizNote.ttf" , 20 )
local toBeDrawnWidth = width
local justClicked = false
function drawOverlayTopRight(info, widthNew, posXOffsetNew, posYOffsetNew, cooldown)
	local pinned = getElementData(localPlayer, "hud:pin")
	if not pinned and timerClose and isTimer(timerClose) then
		killTimer(timerClose)
		timerClose = nil
	end
	if info then
		content = info
		content[1][1] = string.sub(content[1][1], 1, 1)..string.sub(content[1][1], 2)
	else
		return false
	end
	
	if posXOffsetNew then
		posXOffset = posXOffsetNew
	end
	if posYOffsetNew then
		posYOffset = posYOffsetNew
	end
	if cooldown then
		cooldownTime = cooldown
	end
	if content then
		show = true
	end
	
	toBeDrawnWidth = width
	
	playSoundFrontEnd ( 101 )
	if cooldownTime ~= 0 and not pinned then
		timerClose = setTimer(function()
			show = false
			setElementData(localPlayer, "hud:overlayTopRight", 0, false)
		end, cooldownTime*1000, 1)
	end
	
	for i=1, #info do
		outputConsole(info[i][1] or "")
	end
end
addEvent("hudOverlay:drawOverlayTopRight", true)
addEventHandler("hudOverlay:drawOverlayTopRight", localPlayer, drawOverlayTopRight)

addEventHandler("onClientRender",getRootElement(), function ()
	if show and not getElementData(localPlayer, "integration:previewPMShowing") and getElementData(localPlayer, 'loggedin') == 1 then 
		if ( getPedWeapon( localPlayer ) ~= 43 or not getPedControlState( localPlayer, "aim_weapon" ) ) then
			local posXOffset, posYOffset = 0, 0
			local hudDxHeight = getElementData(localPlayer, "hud:whereToDisplayY") or 0
			if hudDxHeight then
				posYOffset = posYOffset + hudDxHeight + 40
			end
			
			local reportDxHeight = getElementData(localPlayer, "report-system:dxBoxHeight") or 0
			if reportDxHeight then
				posYOffset = posYOffset + reportDxHeight
			end
			
			dxDrawRectangle(sx-toBeDrawnWidth-5+posXOffset, 5+posYOffset, toBeDrawnWidth, 16*(#content)+30, tocolor(0, 0, 0, 100), false)
			
			local pinned = getElementData(localPlayer, "hud:pin")
			if isCursorShowing() then
				local cursorX, cursorY, cwX, cwY, cwZ = getCursorPosition()
				cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
				if justClicked and isInBox( cursorX, cursorY, sx-5+posXOffset-35, sx-5+posXOffset-35 + 25, (5+posYOffset)+10, (5+posYOffset)+10 + 25 ) then
					if pinned then
						unpinIt()
					else
						pinIt()
					end
					playToggleSound()
				end
			end
			justClicked = false
			dxDrawImage ( sx-5+posXOffset-35, (5+posYOffset)+10, 25, 25, (pinned and "images/pinned.png" or "images/pin.png" ),0, 0, 0, tocolor(255,255,255), false )
			
			setElementData(localPlayer, "hud:overlayTopRight", 16*(#content)+30+5, false)
			for i=1, #content do
				if content[i] then
					local currentWidth = dxGetTextWidth ( (content[i][1] or "" ) , 1 , "default") + 30
					if currentWidth > toBeDrawnWidth then
						toBeDrawnWidth = currentWidth
					end
					
					if i == 1 or content[i][7] == "title" then --Title
						if not BizNoteFont20 then
							BizNoteFont20 = dxCreateFont ( ":resources/BizNote.ttf" , 20 )
						end
						dxDrawText( content[i][1] or "" , sx-toBeDrawnWidth+20+posXOffset, (16*i)+posYOffset, toBeDrawnWidth-5, 15, tocolor (content[i][2] or 70,content[i][3] or 200,content[i][4] or 14, content[i][5] or 255), 1, BizNoteFont20 )
					else
						dxDrawText( content[i][1] or "" , sx-toBeDrawnWidth+10+posXOffset, (16*i)+posYOffset, toBeDrawnWidth-5, 15, tocolor ( content[i][2] or 255, content[i][3] or 255, content[i][4] or 255, content[i][5] or 255 ), content[i][6] or 1, content[i][7] or "default" )
					end
				end
			end
		end
	end
end, false)

function pinIt()
	setElementData(localPlayer, "hud:pin", true, false)
	if timerClose and isTimer(timerClose) then
		killTimer(timerClose)
		timerClose = nil
	end
end

function unpinIt()
	pinIt()
	setElementData(localPlayer, "hud:pin", false, false)
	timerClose = setTimer(function()
		show = false
		setElementData(localPlayer, "hud:overlayTopRight", 0, false)
	end, 3000, 1)
end

--TO DETECT CLICK ON DX BOX / MAXIME
addEventHandler( "onClientClick", root,
	function( button, state )
		if show and button == "left" and state == "up" then
			justClicked = true
			--outputDebugString("clicked")
		end
	end
)