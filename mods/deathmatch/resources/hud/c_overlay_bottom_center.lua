local localPlayer = getLocalPlayer()
local show = false
local width, height = 570,100
local woffset, hoffset = 0, 0
local sx, sy = guiGetScreenSize()
local content = {}
local timerClose = getTickCount()
local cooldownTime = 5 --seconds
local toBeDrawnWidth = 0

local function removeRender()
	if show then
		removeEventHandler( "onClientRender", root, clientRender )
		show = false
	end
end

local function makeFonts()
	BizNoteFont18 = BizNoteFont18 or dxCreateFont ( ":resources/BizNote.ttf" , 18 )
end

function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
	if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
		local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
		if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
			for _, v in ipairs( aAttachedFunctions ) do
				if v == func then
					return true
				end
			end
		end
	end

	return false
end

function drawOverlayBottomCenter(info, widthNew, woffsetNew, hoffsetNew, cooldown)
	if getElementData(localPlayer, "loggedin") == 1 then
		makeFonts()
		content = info
		if woffsetNew then
			woffset = woffsetNew
		end
		if hoffsetNew then
			hoffset = hoffsetNew
		end
		
		playSoundFrontEnd ( 101 )	
		toBeDrawnWidth = dxGetTextWidth ( content[1][1] or "" , 1 , BizNoteFont18)
		
		for i=1, #info do
			outputConsole(info[i][1] or "")
		end
		if not show and not isEventHandlerAdded("onClientRender", root, clientRender) then
			addEventHandler( "onClientRender", root, clientRender )
		end
		timerClose = getTickCount()
	else
		removeRender()
	end
end
addEvent("hudOverlay:drawOverlayBottomCenter", true)
addEventHandler("hudOverlay:drawOverlayBottomCenter", localPlayer, drawOverlayBottomCenter)

function clientRender() 
	show = true
	if ( getPedWeapon( localPlayer ) ~= 43 or not getPedControlState( localPlayer, "aim_weapon" ) ) then
		local h = 16*(#content)+30
		local posX = (sx/2)-(toBeDrawnWidth/2)+woffset
		local posY = sy-(h+30)+hoffset
		
		dxDrawRectangle(posX, posY , toBeDrawnWidth, h , tocolor(0, 0, 0, 100), false)
		
		for i=1, #content do
			if content[i] then
				local font = i == 1 and BizNoteFont18 or (content[i][7]) or "default"
				local currentWidth = dxGetTextWidth ( content[i][1] or "" , 1 , font) + 30
				if currentWidth > toBeDrawnWidth then
					toBeDrawnWidth = currentWidth
				end
				dxDrawText( content[i][1] or "" , posX+16, posY+(16*i), toBeDrawnWidth-5, 15, tocolor ( content[i][2] or 255, content[i][3] or 255, content[i][4] or 255, content[i][5] or 255 ), content[i][6] or 1, font )
			end
		end
	end

	if getTickCount() - timerClose > cooldownTime*1000 then
		removeRender()
	end
end