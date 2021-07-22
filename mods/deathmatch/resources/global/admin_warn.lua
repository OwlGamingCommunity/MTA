
local warn = 0
local count = 0

local screenX, screenY = guiGetScreenSize( )

local x = screenX - 430
local y = screenY - screenY + 200

function getMessageYPosition( ) 
	count = count + 1
	
	if (count < 20) then
		y = y + 20 
	else
		y = screenY - screenY + 200
		count = 0
	end
	
	return y
end	

function getMessageXPosition( message )
	x = screenX - string.len(message) * 7
	
	return x
end	
	

function sendWarn( message )
	local lWarn = guiCreateLabel( getMessageXPosition( message ), getMessageYPosition(), 500*10, 20, tostring(message), false)
	guiLabelSetColor ( lWarn, 255, 0, 0) 
	guiSetFont( lWarn, "default-bold-small")
	removeLabel( lWarn )
	outputConsole ( message ) 
	
	--
	warn = warn + 1
	if (warn == 1) then
		reposition( )
	end	
end
addEvent("sendWrnMessage", true)
addEventHandler("sendWrnMessage", getLocalPlayer(), sendWarn)	
	
function removeLabel( lWarn )
	setTimer(function() 
		guiSetAlpha ( lWarn, guiGetAlpha(lWarn) - 0.05 )
	end, 500, 15)

	setTimer(function() destroyElement( lWarn ) lWarn = nil end, 15000, 1)
end	

function reposition( )
	setTimer(function() 
		y = screenY - screenY + 200
		count = 0
		warn = 0
	end, 20000, 1)
end	
	