--[[
--	Copyright (C) Root Gaming - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, December 2012
]]--

local SCREEN_X, SCREEN_Y = guiGetScreenSize()
local resourceName = getResourceName( getThisResource( ) )

------------------------------------------
function tolls ( locked )
	showCursor( true, true )
	local window = { }
	local width = 520
	local height = 590
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window.window = guiCreateWindow( x, y, width, height, "MDC Toll System", false )
	
	window.tollImage = guiCreateStaticImage ( 10, 30, 500, 500, ":gps/map.jpg", false, window.window )
	
	window.toll1 = guiCreateStaticImage( 22, 132, 10, 10, ( locked[ 1 ] and ":mdc/img/red.png" or ":mdc/img/green.png" ), false, window.tollImage )
	addEventHandler( "onClientGUIClick", window.toll1,
		function()
			triggerServerEvent( resourceName..":toggle_toll", localPlayer, 1 )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	, false )
	window.toll2 = guiCreateStaticImage( 150, 154, 10, 10, ( locked[ 2 ] and ":mdc/img/red.png" or ":mdc/img/green.png" ), false, window.tollImage )
	addEventHandler( "onClientGUIClick", window.toll2,
		function()
			triggerServerEvent( resourceName..":toggle_toll", localPlayer, 2 )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	, false )
	window.toll3 = guiCreateStaticImage( 231, 213, 10, 10, ( locked[ 3 ] and ":mdc/img/red.png" or ":mdc/img/green.png" ), false, window.tollImage )
	addEventHandler( "onClientGUIClick", window.toll3,
		function()
			triggerServerEvent( resourceName..":toggle_toll", localPlayer, 3 )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	, false )
	window.toll4 = guiCreateStaticImage( 286, 202, 10, 10, ( locked[ 4 ] and ":mdc/img/red.png" or ":mdc/img/green.png" ), false, window.tollImage )
	addEventHandler( "onClientGUIClick", window.toll4,
		function()
			triggerServerEvent( resourceName..":toggle_toll", localPlayer, 4 )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	, false )
	window.toll5 = guiCreateStaticImage( 390, 198, 10, 10, ( locked[ 5 ] and ":mdc/img/red.png" or ":mdc/img/green.png" ), false, window.tollImage )
	addEventHandler( "onClientGUIClick", window.toll5,
		function()
			triggerServerEvent( resourceName..":toggle_toll", localPlayer, 5 )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	, false )
	window.toll6 = guiCreateStaticImage( 118, 313, 10, 10, ( locked[ 6 ] and ":mdc/img/red.png" or ":mdc/img/green.png" ), false, window.tollImage )
	addEventHandler( "onClientGUIClick", window.toll6,
		function()
			triggerServerEvent( resourceName..":toggle_toll", localPlayer, 6 )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	, false )
	window.toll7 = guiCreateStaticImage( 125, 352, 10, 10, ( locked[ 7 ] and ":mdc/img/red.png" or ":mdc/img/green.png" ), false, window.tollImage )
	addEventHandler( "onClientGUIClick", window.toll7,
		function()
			triggerServerEvent( resourceName..":toggle_toll", localPlayer, 7 )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	, false )
	window.toll8 = guiCreateStaticImage( 118, 372, 10, 10, ( locked[ 8 ] and ":mdc/img/red.png" or ":mdc/img/green.png" ), false, window.tollImage )
	addEventHandler( "onClientGUIClick", window.toll8,
		function()
			triggerServerEvent( resourceName..":toggle_toll", localPlayer, 8 )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	, false )
	
	window.toll9 = guiCreateStaticImage( 33, 425, 10, 10, ( locked[ 9 ] and ":mdc/img/red.png" or ":mdc/img/green.png" ), false, window.tollImage )
	addEventHandler( "onClientGUIClick", window.toll9,
		function()
			triggerServerEvent( resourceName..":toggle_toll", localPlayer, 9 )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	, false )
	window.toll10 = guiCreateStaticImage( 250, 375, 10, 10, ( locked[ 10 ] and ":mdc/img/red.png" or ":mdc/img/green.png" ), false, window.tollImage )
	addEventHandler( "onClientGUIClick", window.toll10,
		function()
			triggerServerEvent( resourceName..":toggle_toll", localPlayer, 10 )
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
		end
	, false )
	
	window.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, window.window )
	addEventHandler( "onClientGUIClick", window.closeButton, 
		function ()
			guiSetVisible( window.window, false )
			destroyElement( window.window )
			window = { }
			triggerServerEvent( "mdc:main", localPlayer )
		end
	, false )
end

------------------------------------------
addEvent( resourceName..":tolls", true )
addEventHandler( resourceName..":tolls", root, tolls )