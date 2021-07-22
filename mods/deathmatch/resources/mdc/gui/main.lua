--[[
--	Copyright (C) Root Gaming - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, December 2012
]]--

local SCREEN_X, SCREEN_Y = guiGetScreenSize()
local resourceName = getResourceName( getThisResource( ) )
mainW = {}
------------------------------------------
function getMDCAccountID( )
	return getElementData( getLocalPlayer( ), "dbid" )
end

function main ( warrants, apb, impounds, calls, anpr )
	closeMainW()
	--outputChatBox( "Experimental MDC system! Any feedback or bugs you find within this system please let us know via http://bugs.owlgaming.net/view.php?id=616 ASAP.", 255, 0, 0 )
	showCursor( true, true )
	local width = 700
	local height = 500
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	local _, _, org_name = canAccess( localPlayer, 'name' )
	mainW.window = guiCreateWindow( x, y, width, height, (org_name and (org_name.." -") or "").. "MDC Main", false )
	
	local spacer = 10
	local quarter = width / 4
	local button = { x = spacer, y = 30, width = quarter - spacer, height = 50 }
	
	--Search Button
	mainW.searchButton = guiCreateButton( button.x, button.y, button.width, button.height, "Search DB", false, mainW.window )
	addEventHandler( "onClientGUIClick", mainW.searchButton, 
		function( )
			search()
		end
	, false )
	mainW.searchButtonImage = guiCreateStaticImage ( 5, 5, 40, 40, ":mdc/img/search.png", false, mainW.searchButton )
	local active_faction, level, can = canAccess( localPlayer, 'canSeeWarrants' )
	if can then
		--Add APB Button
		button.x = button.x + button.width + spacer
		mainW.addButton = guiCreateButton( button.x, button.y, button.width, button.height, "Add APB/ANPR", false, mainW.window )
		addEventHandler( "onClientGUIClick", mainW.addButton, 
			function( )
				guiSetVisible( mainW.window, false )
				destroyElement( mainW.window )
				window = { }
				add_apb()
			end
		, false )
		mainW.searchButtonImage = guiCreateStaticImage ( 5, 5, 40, 40, ":mdc/img/add.png", false, mainW.addButton )
	end
		
	--System Admin Button
	local level, active_faction = getAdminLevel( localPlayer )
	if level == 2 then
		button.x = button.x + button.width + spacer
		mainW.accountButton = guiCreateButton( button.x, button.y, button.width, button.height, "System Admin", false, mainW.window )
		addEventHandler( "onClientGUIClick", mainW.accountButton, 
			function( )
				guiSetVisible( mainW.window, false )
				destroyElement( mainW.window )
				window = { }
				triggerServerEvent( resourceName .. ":system_admin", localPlayer, active_faction )
			end
		, false )
		mainW.searchButtonImage = guiCreateStaticImage ( 5, 5, 40, 40, ":mdc/img/settings.png", false, mainW.accountButton )
	end
	
	
	--Toll system button
	local active_faction, level, can = canAccess( localPlayer, 'canSeeWarrants' )
	if can then
		button.x = button.x + button.width + spacer
		mainW.tollsButton = guiCreateButton( button.x, button.y, button.width, button.height, "Tolls", false, mainW.window )
		addEventHandler( "onClientGUIClick", mainW.tollsButton,
			function ()
				guiSetVisible( mainW.window, false )
				destroyElement( mainW.window )
				window = { }
				triggerServerEvent( resourceName .. ":tolls", localPlayer )
			end
		, false )
	end
	mainW.mainPanel	= guiCreateTabPanel ( 10, 90, width - 15, height - 150, false, mainW.window )
	
	mainW.apbTab		= guiCreateTab( "APB", mainW.mainPanel )
	mainW.apbTable		= guiCreateGridList ( 10, 10, width - 35, height - 190, false, mainW.apbTab )
	
	mainW.personCol	= guiGridListAddColumn( mainW.apbTable, "Person", 0.25 )
	mainW.wantedCol	= guiGridListAddColumn( mainW.apbTable, "APB", 0.5 )
	mainW.issuedByCol	= guiGridListAddColumn( mainW.apbTable, "Issued By", 0.25 )
	mainW.timeCol	= guiGridListAddColumn( mainW.apbTable, "Date", 0.15 )
	
	if ( #apb > 0 ) then
		for i = 1, #apb, 1 do
			local row = guiGridListAddRow ( mainW.apbTable )
			guiGridListSetItemText( mainW.apbTable, row, mainW.personCol, apb[ i ][ 1 ]:gsub( "_", " " ), false, false )
			guiGridListSetItemText( mainW.apbTable, row, mainW.wantedCol, apb[ i ][ 2 ], false, false )
			local issuedByText
			local factionShortName = ""
			if(apb[ i ][ 5 ] == apb[ i ][ 3 ]) then
				issuedByText = apb[ i ][ 5 ]
			else
				issuedByText = (apb[ i ][ 5 ] or 'Unknown') .. " (" .. (apb[ i ][ 3 ] or 'Unknown') .. ")"
			end
			guiGridListSetItemText( mainW.apbTable, row, mainW.issuedByCol, issuedByText, false, false )
			guiGridListSetItemData( mainW.apbTable, row, mainW.personCol, apb[ i ][ 4 ] )
			local time = getRealTime(apb[i][6])
			guiGridListSetItemText( mainW.apbTable, row, mainW.timeCol, time.year + 1900 .. "-" .. (string.len(tostring(time.month + 1)) == 1 and "0" .. time.month + 1 or time.month + 1) .. "-" .. (string.len(tostring(time.monthday)) == 1 and "0" .. time.monthday or time.monthday), false, false)
		end
		
		addEventHandler( "onClientGUIDoubleClick", mainW.apbTable,
			function ( )
				local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.apbTable )
				local characterName = guiGridListGetItemText( mainW.apbTable, selectedRow, mainW.personCol )
				local description = guiGridListGetItemText( mainW.apbTable, selectedRow, mainW.wantedCol )
				local issuedBy = guiGridListGetItemText( mainW.apbTable, selectedRow, mainW.issuedByCol )
				local id = guiGridListGetItemData( mainW.apbTable, selectedRow, mainW.personCol )
				--triggerServerEvent( resourceName .. ":search", localPlayer, characterName, 0 )
				view_apb( id, characterName, description, issuedBy )
				
				guiSetVisible( mainW.window, false )
				destroyElement( mainW.window )
				window = { }
			end
		, false )
		
	else
		local row = guiGridListAddRow ( mainW.apbTable )
		guiGridListSetItemText ( mainW.apbTable, row, mainW.personCol, "No APBs", false, false )
	end
	
	if canAccess( localPlayer, 'canSeeWarrants' ) then
		mainW.warrantTab	= guiCreateTab( "Warrants", mainW.mainPanel )
		mainW.warrantTable	= guiCreateGridList ( 10, 10, width - 35, height - 190, false, mainW.warrantTab )
		mainW.charCol		= guiGridListAddColumn( mainW.warrantTable, "Suspect", 0.25 )
		mainW.warrantCol	= guiGridListAddColumn( mainW.warrantTable, "Warrant", 0.45 )
		mainW.issuedCol	= guiGridListAddColumn( mainW.warrantTable, "Issued By", 0.25 )
		
		if ( #warrants > 0 ) then
			for i = 1, #warrants, 1 do
				local row = guiGridListAddRow ( mainW.warrantTable )
				guiGridListSetItemText( mainW.warrantTable, row, mainW.charCol, warrants[ i ][ 1 ]:gsub( "_", " " ), false, false )
				guiGridListSetItemText( mainW.warrantTable, row, mainW.warrantCol, warrants[ i ][ 2 ], false, false )
				local issuedByText
				if(warrants[ i ][ 4 ] == warrants[ i ][ 3 ]) then
					issuedByText = warrants[ i ][ 4 ]
				else
					issuedByText = warrants[ i ][ 4 ] .. " (" .. warrants[ i ][ 3 ] .. ")"
				end
				guiGridListSetItemText( mainW.warrantTable, row, mainW.issuedCol, issuedByText, false, false )
				--guiGridListSetItemData( mainW.warrantTable, row, mainW.propCol, warrants[ i ][ 1 ] )
			end
			
			addEventHandler( "onClientGUIDoubleClick", mainW.warrantTable,
				function ( )
					local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.warrantTable )
					local characterName = guiGridListGetItemText( mainW.warrantTable, selectedRow, mainW.charCol )
					triggerServerEvent( resourceName .. ":search", localPlayer, characterName, 0 )
					
					guiSetVisible( mainW.window, false )
					destroyElement( mainW.window )
					window = { }
				end
			, false )
			
		else
			local row = guiGridListAddRow ( mainW.warrantTable )
			guiGridListSetItemText ( mainW.warrantTable, row, mainW.charCol, "No Warrants", false, false )
		end
	end

	if canAccess( localPlayer, 'canSeeWarrants' ) then
		mainW.anprTab		= guiCreateTab( "ANPR", mainW.mainPanel )
		mainW.anprTable		= guiCreateGridList ( 10, 10, width - 35, height - 190, false, mainW.anprTab )
		
		mainW.plateCol	= guiGridListAddColumn( mainW.anprTable, "Vehicle Plate", 0.25 )
		mainW.descCol	= guiGridListAddColumn( mainW.anprTable, "Wanted for", 0.5 )
		mainW.issuedByColumn	= guiGridListAddColumn( mainW.anprTable, "Issued By", 0.25 )
		if ( #anpr > 0 ) then
			for i = 1, #anpr, 1 do
				local row = guiGridListAddRow ( mainW.anprTable )
				guiGridListSetItemText( mainW.anprTable, row, mainW.plateCol, anpr[ i ][ 1 ], false, false )
				guiGridListSetItemText( mainW.anprTable, row, mainW.descCol, anpr[ i ][ 2 ], false, false )
				local issuedByText
				local factionShortName = ""
				if(anpr[ i ][ 5 ] == anpr[ i ][ 3 ]) then
					issuedByText = anpr[ i ][ 5 ]
				else
					issuedByText = anpr[ i ][ 5 ] .. " (" .. anpr[ i ][ 3 ] .. ")"
				end
				guiGridListSetItemText( mainW.anprTable, row, mainW.issuedByColumn, issuedByText, false, false )
				guiGridListSetItemData( mainW.anprTable, row, mainW.plateCol, anpr[ i ][ 4 ] )
			end
			
			addEventHandler( "onClientGUIDoubleClick", mainW.anprTable,
				function ( )
					local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.anprTable )
					local characterName = guiGridListGetItemText( mainW.anprTable, selectedRow, mainW.plateCol )
					local description = guiGridListGetItemText( mainW.anprTable, selectedRow, mainW.descCol ) 
					local issuedBy = guiGridListGetItemText( mainW.anprTable, selectedRow, mainW.issuedByColumn )
					local id = guiGridListGetItemData( mainW.anprTable, selectedRow, mainW.plateCol )
					--triggerServerEvent( resourceName .. ":search", getLocalPlayer(), characterName, 0 )
					view_anpr( id, characterName, description, issuedBy )
					
					guiSetVisible( mainW.window, false )
					destroyElement( mainW.window )
					window = { }
				end
			, false )
			
		else
			local row = guiGridListAddRow ( mainW.anprTable )
			guiGridListSetItemText ( mainW.anprTable, row, mainW.plateCol, "No ANPRs", false, false )
		end
	end	

	--Impounds / Maxime / 2015.2.1
	mainW.imps_lots	= guiCreateTab( "Impounds", mainW.mainPanel )
	mainW.imps_lots_list	= guiCreateGridList ( 10, 10, width - 35, height - 190, false, mainW.imps_lots )
	mainW.imps_lots_list_col_dep = guiGridListAddColumn( mainW.imps_lots_list, "Department", 0.1 )
	mainW.imps_lots_list_col_lane = guiGridListAddColumn( mainW.imps_lots_list, "Lane", 0.05 )
	mainW.imps_lots_list_col_days = guiGridListAddColumn( mainW.imps_lots_list, "Release Date", 0.2 )
	mainW.imps_lots_list_col_fine = guiGridListAddColumn( mainW.imps_lots_list, "Fine ($)", 0.1 )
	mainW.imps_lots_list_col_model = guiGridListAddColumn( mainW.imps_lots_list, "Model", 0.4 )

	mainW.imps_lots_list_col_plate = guiGridListAddColumn( mainW.imps_lots_list, "Plate", 0.1 )
	mainW.imps_lots_list_col_vin = guiGridListAddColumn( mainW.imps_lots_list, "VIN", 0.1 )
	
	mainW.imps_lots_list_col_id = guiGridListAddColumn( mainW.imps_lots_list, "((Veh ID))", 0.08 )

	for i, oneLane in pairs(impounds) do
		local row = guiGridListAddRow ( mainW.imps_lots_list )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_dep, oneLane.impounder == 1 and "LSPD" or oneLane.impounder == 50 and "SCoSA" or "RT", false, false )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_lane, oneLane.lane, false, true )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_model, oneLane.name or "-", false, false )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_plate, oneLane.plate or "-", false, false )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_vin, oneLane.vin or "-", false, false )
		local release = "Seized"
		local fine = oneLane.fine and exports.global:formatMoney(oneLane.fine) or "-"
		if oneLane.id then
			if not oneLane.release_date then
				release = "Seized"
				fine = "Irrelevant"
			else
				release = oneLane.release_date
			end
		else
			release = "-"
		end
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_days,release , false, false )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_fine, fine, false, true )
		guiGridListSetItemText( mainW.imps_lots_list, row, mainW.imps_lots_list_col_id, oneLane.id or "-", false, true )
	end
	addEventHandler( "onClientGUIDoubleClick", mainW.imps_lots_list,
		function ( )
			local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.imps_lots_list )
			local vehid = guiGridListGetItemText( mainW.imps_lots_list, selectedRow, mainW.imps_lots_list_col_vin )
			if vehid ~= "-" then
				triggerServerEvent( resourceName .. ":search", localPlayer, vehid, 3 )
				togWin( mainW.window, false )
			end
		end
	, false )
	--mainW.warrantCol	= guiGridListAddColumn( mainW.warrantTable, "Warrant", 0.45 )
	--mainW.issuedCol	= guiGridListAddColumn( mainW.warrantTable, "Issued By", 0.25 )
	
	if canAccess( localPlayer, 'canSeeCalls' ) then
		mainW.callsTab			= guiCreateTab( "911 Calls", mainW.mainPanel )
		mainW.callsTable		= guiCreateGridList( 10, 10, width - 35, height - 190, false, mainW.callsTab )
		mainW.callerCol		= guiGridListAddColumn( mainW.callsTable, "Caller", 0.2 )
		mainW.phoneCol			= guiGridListAddColumn( mainW.callsTable, "Phone Number", 0.12 )
		mainW.convoCol			= guiGridListAddColumn( mainW.callsTable, "Description", 0.5 )
		mainW.timeCol			= guiGridListAddColumn( mainW.callsTable, "Time", 0.1 )
		
		if not calls then calls = {} end
		if ( #calls > 0 ) then
			for i = 1, #calls, 1 do
				local row = guiGridListAddRow ( mainW.callsTable )
				guiGridListSetItemText( mainW.callsTable, row, mainW.callerCol, (calls[ i ][ 2 ] or "N/A"):gsub("_", " "), false, false )
				guiGridListSetItemData( mainW.callsTable, row, mainW.callerCol, calls[ i ][ 1 ] )
				guiGridListSetItemText( mainW.callsTable, row, mainW.phoneCol, calls[ i ][ 3 ], false, false )
				guiGridListSetItemText( mainW.callsTable, row, mainW.convoCol, calls[ i ][ 4 ], false, false )
				guiGridListSetItemText( mainW.callsTable, row, mainW.timeCol, calls[ i ][ 5 ], false, false )
			end
			
			addEventHandler("onClientGUIClick", mainW.callsTable,
				function (button)
					if button == "left" then
						local rcMenu = exports.rightclick:create("Action...")
						local row = {}
						
						row.viewDetails = exports.rightclick:addRow("View 911 details")

						local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.callsTable )
						local characterName = guiGridListGetItemText( mainW.callsTable, selectedRow, mainW.callerCol )
						if characterName ~= "N/A" then
							row.viewMdc = exports.rightclick:addRow("View MDC file")
							addEventHandler("onClientGUIClick", row.viewMdc, 
							function ()
								local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.callsTable )
								local characterName = guiGridListGetItemText( mainW.callsTable, selectedRow, mainW.callerCol )
								if characterName ~= "N/A" then
									triggerServerEvent( resourceName .. ":search", localPlayer, characterName, 0 )
								
									guiSetVisible( mainW.window, false )
									destroyElement( mainW.window )
									window = { }
								end
							end
							, false)
						end

						addEventHandler("onClientGUIClick", row.viewDetails, 
							function ()
								local selectedRow, selectedCol = guiGridListGetSelectedItem( mainW.callsTable )
								local characterName = guiGridListGetItemText( mainW.callsTable, selectedRow, mainW.callerCol )
								local phonenumber = guiGridListGetItemText( mainW.callsTable, selectedRow, mainW.phoneCol )
								local description = guiGridListGetItemText( mainW.callsTable, selectedRow, mainW.convoCol )
								local time = guiGridListGetItemText( mainW.callsTable, selectedRow, mainW.timeCol )
								exports.hud:sendBottomNotification(localPlayer, "Mobile Data Computer", "Caller: "..characterName.." - Phone number: "..phonenumber.." - Description: "..description.." - Time:"..time )
							end
						, false)
					end
				end
			, false )

			
		else
			local row = guiGridListAddRow ( mainW.callsTable )
			guiGridListSetItemText ( mainW.callsTable, row, mainW.callerCol, "No 911 Calls", false, false )
		end
	end
	
	
	mainW.closeButton = guiCreateButton( 10, height - 50, width - 20, 40, "Close", false, mainW.window )
	addEventHandler( "onClientGUIClick", mainW.closeButton, 
		function ()
			closeMainW()
		end
	, false )
end
addEvent( 'mdc:main', true )
addEventHandler( 'mdc:main', root, main )

function closeMainW()
	if mainW.window and isElement(mainW.window) then
		destroyElement(mainW.window)
		mainW.window = nil
		closeVehWin()
		closeSearchGui()
		showCursor( false, false )
		guiSetInputEnabled(false)
	end
end

function togWin(element, state)
	if element and isElement(element) then
		guiSetEnabled(element, state)
	end
end