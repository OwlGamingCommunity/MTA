--[[
--	Copyright (C) Root Gaming - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, December 2012
]]--

local SCREEN_X, SCREEN_Y = guiGetScreenSize()
local resourceName = getResourceName( getThisResource( ) )

------------------------------------------
function search_noresult ( )
	local window = { }
	local width = 240
	local height = 110
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window.window = guiCreateWindow( x, y, width, height, "MDC Search - No Results!", false )
	
	window.errorLabel = guiCreateLabel( 10, 30, width - 20, 20, "We couldn't find any matches for that!", false, window.window )
	
	
	window.closeButton = guiCreateButton( 10, 60, width - 20, 40, "Close", false, window.window )
	addEventHandler( "onClientGUIClick", window.closeButton, 
		function ()
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
			search( )
		end
	)
end

------------------------------------------
addEvent( resourceName .. ":search_noresult", true )
addEventHandler( resourceName .. ":search_noresult", root, search_noresult )