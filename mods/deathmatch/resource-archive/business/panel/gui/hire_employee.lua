local window = {
    tab = {},
    label = {},
    tabpanel = {},
    edit = {},
    gridlist = {},
    window = {},
    button = {},
    memo = {}
}

function hireEmployee( business )
	if window.window[ 1 ] then
		destroyElement( window.window[ 1 ] )
		window.window[ 1 ] = nil
		guiSetInputEnabled( false )
		return
	end
	window.window[1] = guiCreateWindow(18, 424, 279, 273, 'Hire Employee', false)
	guiWindowSetSizable(window.window[1], false)
	guiSetInputEnabled( true )

	window.label[1] = guiCreateLabel(10, 26, 143, 20, 'Employee Name:', false, window.window[1])
	window.label[2] = guiCreateLabel(10, 56, 143, 20, 'Job Title:', false, window.window[1])
	window.label[3] = guiCreateLabel(10, 86, 143, 20, 'Wage:', false, window.window[1])
	window.label[4] = guiCreateLabel(10, 116, 143, 20, 'Phone Number:', false, window.window[1]) 
	window.label[5] = guiCreateLabel(10, 146, 143, 20, 'Address:', false, window.window[1])
	window.edit[1] = guiCreateEdit(117, 23, 147, 23, '', false, window.window[1]) -- name
	window.edit[2] = guiCreateEdit(117, 53, 147, 23, '', false, window.window[1]) -- rank
	window.edit[3] = guiCreateEdit(117, 83, 147, 23, '', false, window.window[1]) -- wage
	window.edit[4] = guiCreateEdit(117, 113, 147, 23, '', false, window.window[1]) -- phone 
	window.edit[5] = guiCreateEdit(117, 143, 147, 23, '', false, window.window[1]) -- address


	window.button[5] = guiCreateButton(9, 233, 255, 30, 'Cancel', false, window.window[1])
	addEventHandler( 'onClientGUIClick', window.button[5], hireEmployee, false )
	window.button[6] = guiCreateButton(10, 193, 255, 30, 'Hire', false, window.window[1])
	addEventHandler( 'onClientGUIClick', window.button[6], 
		function ()
			local name = guiGetText( window.edit[ 1 ] )
			local rank = guiGetText( window.edit[ 2 ] )
			local wage = guiGetText( window.edit[ 3 ] )
			local phone = guiGetText( window.edit[ 4 ] )
			local address = guiGetText( window.edit[ 5 ] )
			if not getPlayerFromName( name:gsub(" ", "_")) then
				outputChatBox( 'We could not find anyone online with that name.', localPlayer, 255, 100, 100 )
				return
			end
			triggerServerEvent( "business:hireEmployee", localPlayer, business, name, rank, wage, phone, address )
			hireEmployee()
		end
	, false )
end