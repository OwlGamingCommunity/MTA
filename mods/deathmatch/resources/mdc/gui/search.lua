--[[
--	Copyright (C) Root Gaming - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, December 2012
]]--

local SCREEN_X, SCREEN_Y = guiGetScreenSize()
local resourceName = getResourceName( getThisResource( ) )
searchW = {}
------------------------------------------
function search ( )
	closeSearchGui()
	togWin( mainW.window, false )
	guiSetInputEnabled ( true )
	local window = { }
	local width = 400
	local height = 200
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	searchW.window = guiCreateWindow( x, y, width, height, "MDC Search", false )
	
	local DEFAULT_SEARCH_TEXT = "Enter Search..."
	searchW.searchEdit = guiCreateEdit( 10, 30, width - 20, 40, DEFAULT_SEARCH_TEXT, false, searchW.window )
	addEventHandler( "onClientGUIClick", searchW.searchEdit,
		function()
			if guiGetText(source) == DEFAULT_SEARCH_TEXT then
				guiSetText(source, "")
			end
		end
	, false)
	
	searchW.searchCombo = guiCreateComboBox ( 10, 80, width - 20, 95, "Select a search type", false, searchW.window )
	guiComboBoxAddItem( searchW.searchCombo, "Person" )

	if canAccess( localPlayer, 'canSeeVehicles' ) then
		guiComboBoxAddItem( searchW.searchCombo, "Vehicle by Plate" )
	end
	if canAccess( localPlayer, 'canSeeProperties' ) then
		guiComboBoxAddItem( searchW.searchCombo, "Property by ZIP Code (( ID ))" )
	end
	if canAccess( localPlayer, 'canSeeVehicles' ) then
		guiComboBoxAddItem( searchW.searchCombo, "Vehicle by VIN" )
	end
	
	searchW.goButton = guiCreateButton( 10, 110, width - 20, 40, "Search!", false, searchW.window )
	addEventHandler( "onClientGUIClick", searchW.goButton, 
		function ()
			local query = guiGetText( searchW.searchEdit )
			local queryType = guiComboBoxGetSelected ( searchW.searchCombo ) -- This is not a accurate way of checking the query type as it is dependent on the individuals permissions.
			local queryType = guiComboBoxGetItemText( searchW.searchCombo, queryType )
			closeSearchGui()
			triggerServerEvent( resourceName ..":search", localPlayer, query, queryType )
		end
	, false )
	searchW.closeButton = guiCreateButton( 10, 160, width - 20, 40, "Close", false, searchW.window )
	addEventHandler( "onClientGUIClick", searchW.closeButton, 
		function ()
			closeSearchGui()
		end
	, false )
end

function closeSearchGui()
	if searchW.window and isElement(searchW.window) then
		guiSetInputEnabled ( false )
		guiSetVisible( searchW.window, false )
		destroyElement(searchW.window)
		togWin( mainW.window, true )
	end
end

function search_noresult ( )
	local window = { }
	local width = 240
	local height = 110
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	searchW.window = guiCreateWindow( x, y, width, height, "MDC Search - No Results!", false )
	
	searchW.errorLabel = guiCreateLabel( 10, 30, width - 20, 20, "We couldn't find any matches for that!", false, searchW.window )
	
	
	searchW.closeButton = guiCreateButton( 10, 60, width - 20, 40, "Close", false, searchW.window )
	addEventHandler( "onClientGUIClick", searchW.closeButton, 
		function ()
			guiSetVisible( searchW.window, false )
			destroyElement( searchW.window )
			window = { }
			search( )
		end
	, false )
end

function search_error ( )
	local window = { }
	local width = 210
	local height = 110
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	searchW.window = guiCreateWindow( x, y, width, height, "MDC Search Error", false )
	
	searchW.errorLabel = guiCreateLabel( 10, 30, width - 20, 20, "You need to select a search type!", false, searchW.window )
	
	
	searchW.closeButton = guiCreateButton( 10, 60, width - 20, 40, "Close", false, searchW.window )
	addEventHandler( "onClientGUIClick", searchW.closeButton, 
		function ()
			guiSetVisible( searchW.window, false )
			destroyElement( searchW.window )
			window = { }
			search( )
		end
	, false )
end

------------------------------------------
addEvent( resourceName .. ":search_error", true )
addEvent( resourceName .. ":search_noresult", true )
addEventHandler( resourceName .. ":search_error", root, search_error )
addEventHandler( resourceName .. ":search_noresult", root, search_noresult )