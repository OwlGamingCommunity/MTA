
bindKey( 'f5', 'up', 'business')

screenX, screenY = guiGetScreenSize()

local window = {
    toptab = {},
    tab = {},
    label = {},
    panels = {},
    edit = {},

    -- gridlists
    employees = {},
    accounts = {},
    banking = {},
    vehicles = {},
    properties = {},

    button = {},
    memo = {}
}

function panel( ) -- b is the businesses the player has access to see.
	if window.window then
		destroyElement( window.window )
		window = {
		    toptab = {},
		    tab = {},
		    label = {},
		    panels = {},
		    edit = {},

		    -- gridlists
		    employees = {},
		    accounts = {},
		    banking = {},
		    vehicles = {},
		    properties = {},

		    button = {},
		    memo = {}
		}
		showCursor( false )
		return
	end

	showCursor( true )

	local width = 800
	local height = 400
	local x = ( screenX - width ) / 2
	local y = ( screenY - height ) / 2
	window.window = guiCreateWindow( x, y, width, height, 'Business Manager', false )
	guiWindowSetSizable( window.window, false )

	window.panel = guiCreateTabPanel( 10, 25, 780, 325, false, window.window )

	window.close = guiCreateButton( 10, 360, 780, 40, 'Close', false, window.window )
	addEventHandler( 'onClientGUIClick', window.close, 
		function ( )
			triggerServerEvent( 'business:close', localPlayer )
			panel()
		end, false )
end
addEvent( 'business:open', true )
addEventHandler( 'business:open', root, panel )

addEvent( 'business:close', true )
addEventHandler( 'business:close', root, 
	function ( )
	 	if window.window then
			destroyElement( window.window )
			window = {
			    toptab = {},
			    tab = {},
			    label = {},
			    panels = {},
			    edit = {},

			    -- gridlists
			    employees = {},
			    accounts = {},
			    banking = {},
			    vehicles = {},
			    properties = {},

			    button = {},
			    memo = {}
			}
			showCursor( false )
			return
		end
	 end 
)



function addBusiness ( id, title, bank_card, created_by )
	if window.panel then 
		window.toptab[ id ] = guiCreateTab( title, window.panel )

		window.panels[ id ] = guiCreateTabPanel( 5, 10, 770, 285, false, window.toptab[ id ] )

		window.tab[ id ] = { }

		-- EMPLOYEES
		window.tab[ id ][ 1 ] = guiCreateTab( 'Employees', window.panels[ id ] )

		window.employees[ id ] = guiCreateGridList( 5, 10, 600, 245, false, window.tab[ id ][ 1 ])
		guiGridListAddColumn( window.employees[ id ], 'Employee', 0.3 )
		guiGridListAddColumn( window.employees[ id ], 'Title', 0.2 )
		guiGridListAddColumn( window.employees[ id ], 'Wage', 0.1 )
		guiGridListAddColumn( window.employees[ id ], 'Phone', 0.1 )
		guiGridListAddColumn( window.employees[ id ], 'Last Active', 0.15 )
		guiGridListAddColumn( window.employees[ id ], 'Address', 0.3 )

		window.button[1] = guiCreateButton(610, 10, 150, 30, 'Hire Employee', false, window.tab[ id ][ 1 ])
		addEventHandler( 'onClientGUIClick', window.button[1], function() hireEmployee( id ) end, false )
		window.button[2] = guiCreateButton(610, 45, 150, 30, 'Manage Employee', false, window.tab[ id ][ 1 ])
		addEventHandler( 'onClientGUIClick', window.button[2], 
			function() 
				local row, col = guiGridListGetSelectedItem( window.employees[ id ] )

				local character = guiGridListGetItemData ( window.employees[ id ], row, 1 )
				local leader = guiGridListGetItemData ( window.employees[ id ], row, 2 )
				local dateHired = guiGridListGetItemData ( window.employees[ id ], row, 3 )
				local characterName = guiGridListGetItemText ( window.employees[ id ], row, 1 )
				local rank = guiGridListGetItemText ( window.employees[ id ], row, 2 )
				local wage = guiGridListGetItemText ( window.employees[ id ], row, 3 )
				local phone = guiGridListGetItemText ( window.employees[ id ], row, 4 )
				local lastActive = guiGridListGetItemText ( window.employees[ id ], row, 5 )
				local address = guiGridListGetItemText ( window.employees[ id ], row, 6 )
				manageEmployee( id, character, characterName, rank, wage, phone, lastActive, dateHired, address, leader, row ) 

			end, false 
		)
		window.button[3] = guiCreateButton(610, 80, 150, 30, 'Fire Employee', false, window.tab[ id ][ 1 ])

		-- ACCOUNTS PAYABLE
		window.tab[ id ][ 2 ] = guiCreateTab( 'Accounts Payable', window.panels[ id ] )

		window.accounts[ id ] = guiCreateGridList( 5, 10, 600, 245, false, window.tab[ id ][ 2 ])
		guiGridListAddColumn(window.accounts[ id ], 'Recipient', 0.3)
		guiGridListAddColumn(window.accounts[ id ], 'Amount', 0.3)
		guiGridListAddColumn(window.accounts[ id ], 'Description', 0.3)
		
		window.button[4] = guiCreateButton(610, 10, 150, 30, 'Add Account', false, window.tab[ id ][ 2 ])
		window.button[5] = guiCreateButton(610, 45, 150, 30, 'Edit Account', false, window.tab[ id ][ 2 ])
		window.button[6] = guiCreateButton(610, 80, 150, 30, 'Remove Account', false, window.tab[ id ][ 2 ])

		-- BANK RECORDS
		window.tab[ id ][ 3 ] = guiCreateTab( 'Bank Records', window.panels[ id ] )

		window.banking[ id ] = guiCreateGridList(5, 10, 750, 245, false, window.tab[ id ][ 3 ])
		guiGridListAddColumn(window.banking[ id ], 'Date', 0.1)
		guiGridListAddColumn(window.banking[ id ], 'From', 0.1)
		guiGridListAddColumn(window.banking[ id ], 'To', 0.1)
		guiGridListAddColumn(window.banking[ id ], 'Debit', 0.1)
		guiGridListAddColumn(window.banking[ id ], 'Credit', 0.1)
		guiGridListAddColumn(window.banking[ id ], 'Description', 0.1)
		

		-- VEHICLES
		window.tab[ id ][ 4 ] = guiCreateTab( 'Vehicles', window.panels[ id ] )

		window.vehicles[ id ] = guiCreateGridList( 5, 10, 600, 245, false, window.tab[ id ][ 4 ])
		guiGridListAddColumn(window.vehicles[ id ], 'ID', 0.1)
		guiGridListAddColumn(window.vehicles[ id ], 'Year', 0.1)
		guiGridListAddColumn(window.vehicles[ id ], 'Make', 0.1)
		guiGridListAddColumn(window.vehicles[ id ], 'Model', 0.1)
		guiGridListAddColumn(window.vehicles[ id ], 'Rental Price', 0.1)
		guiGridListAddColumn(window.vehicles[ id ], 'Rented To', 0.1)
		window.button[7] = guiCreateButton(610, 10, 150, 30, 'Transfer Ownership', false, window.tab[ id ][ 4 ])
		window.button[8] = guiCreateButton(610, 45, 150, 30, 'Set Rental', false, window.tab[ id ][ 4 ])
		window.button[9] = guiCreateButton(610, 80, 150, 30, 'Respawn Vehicle', false, window.tab[ id ][ 4 ])
		window.button[10] = guiCreateButton(610, 115, 150, 30, 'Respawn All', false, window.tab[ id ][ 4 ])

		-- PROPERTIES
		window.tab[ id ][ 5 ] = guiCreateTab( 'Properties', window.panels[ id ] )

		window.properties[ id ] = guiCreateGridList( 5, 10, 600, 245, false, window.tab[ id ][ 5 ])
		guiGridListAddColumn(window.properties[ id ], 'ID', 0.2)
		guiGridListAddColumn(window.properties[ id ], 'Name', 0.2)
		guiGridListAddColumn(window.properties[ id ], 'Address', 0.2)
		guiGridListAddColumn(window.properties[ id ], 'Rental Price', 0.2)
		window.button[11] = guiCreateButton(610, 10, 150, 30, 'Transfer Ownership', false, window.tab[ id ][ 5 ])
		window.button[12] = guiCreateButton(610, 45, 150, 30, 'Set Rental', false, window.tab[ id ][ 5 ])
	end
end
addEvent( 'business:add', true )
addEventHandler( 'business:add', root, addBusiness )



function addEmployees( id, employees )
	for _, employee in pairs( employees ) do
		local row = guiGridListAddRow(window.employees[ id ])
		guiGridListSetItemText(window.employees[ id ], row, 1, employee.charactername:gsub("_"," "), false, false)
		if tonumber( employee.leader ) == 1 then
			guiGridListSetItemColor(window.employees[ id ], row, 1, 255, 100, 0, 255)
		end
		guiGridListSetItemText(window.employees[ id ], row, 2, employee.rank, false, false)
		guiGridListSetItemText(window.employees[ id ], row, 3, employee.wage, false, true)
		guiGridListSetItemText(window.employees[ id ], row, 4, employee.phone, false, true)
		local login = "Never"
		if employee.lastlogin then
			if ( tonumber( employee.lastlogin ) == 0 ) then
				login = "Today"
			elseif ( employee.lastlogin == 1 ) then
				login = tostring(employee.lastlogin) .. " day ago"
			else
				login = tostring(employee.lastlogin) .. " days ago"
			end
		end
		guiGridListSetItemText(window.employees[ id ], row, 5, login, false, false)
		if getPlayerFromName( employee.charactername ) then
			guiGridListSetItemColor(window.employees[ id ], row, 5, 0, 255, 0, 255)
		else
			guiGridListSetItemColor(window.employees[ id ], row, 5, 255, 0, 0, 255)
		end

		guiGridListSetItemText(window.employees[ id ], row, 6, employee.address, false, true)

		
		guiGridListSetItemData(window.employees[ id ], row, 1, employee.id ) -- set name data to employee id
		guiGridListSetItemData(window.employees[ id ], row, 2, employee.leader ) -- set rank data to leader
		guiGridListSetItemData(window.employees[ id ], row, 3, employee.date_hired ) -- set wage data to date hired
	end
end
addEvent( 'business:employees', true )
addEventHandler( 'business:employees', root, addEmployees )

function addAccounts( accounts )
	guiGridListAddRow(window.accounts[ id ])
	guiGridListSetItemText(window.accounts[ id ], 0, 1, 'Bobs Food Distributing', false, false)
	guiGridListSetItemText(window.accounts[ id ], 0, 2, '$100', false, false)
	guiGridListSetItemText(window.accounts[ id ], 0, 3, 'Weekly food delivery for supplies', false, false)
end

function addBanking( banking )
	for i = 1, 3 do
		guiGridListAddRow(window.gridlist[3])
	end
	guiGridListSetItemText(window.gridlist[3], 0, 1, '10/6/2014', false, false)
	guiGridListSetItemText(window.gridlist[3], 0, 2, '-', false, false)
	guiGridListSetItemText(window.gridlist[3], 0, 3, 'Bobs Food Distributing', false, false)
	guiGridListSetItemText(window.gridlist[3], 0, 4, '', false, false)
	guiGridListSetItemText(window.gridlist[3], 0, 5, '$100', false, false)
	guiGridListSetItemColor(window.gridlist[3], 0, 5, 252, 0, 0, 255)
	guiGridListSetItemText(window.gridlist[3], 0, 6, 'DELIVERY', false, false)
	guiGridListSetItemText(window.gridlist[3], 1, 1, '10/6/2014', false, false)
	guiGridListSetItemText(window.gridlist[3], 1, 2, 'Bill Mahoney', false, false)
	guiGridListSetItemText(window.gridlist[3], 1, 3, '-', false, false)
	guiGridListSetItemText(window.gridlist[3], 1, 4, '$25', false, false)
	guiGridListSetItemColor(window.gridlist[3], 1, 4, 53, 251, 0, 255)
	guiGridListSetItemText(window.gridlist[3], 1, 5, '', false, false)
	guiGridListSetItemText(window.gridlist[3], 1, 6, 'Food Bought', false, false)
	guiGridListSetItemText(window.gridlist[3], 2, 1, '10/6/2014', false, false)
	guiGridListSetItemText(window.gridlist[3], 2, 2, 'SUMMARY', false, false)
	guiGridListSetItemText(window.gridlist[3], 2, 3, 'SUMMARY', false, false)
	guiGridListSetItemText(window.gridlist[3], 2, 4, '', false, false)
	guiGridListSetItemText(window.gridlist[3], 2, 5, '$75', false, false)
	guiGridListSetItemColor(window.gridlist[3], 2, 5, 253, 0, 0, 255)
	guiGridListSetItemText(window.gridlist[3], 2, 6, '', false, false)
end