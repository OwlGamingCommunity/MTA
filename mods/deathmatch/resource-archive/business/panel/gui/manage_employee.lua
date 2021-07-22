local window = { }

local months = { 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' }

function outputDate( timestamp )
	local t = getRealTime( timestamp )
	return months[ t.month + 1 ] .. ' ' .. t.monthday .. ', ' .. tostring( t.year + 1900 )
end

function manageEmployee( business, character, characterName, rank, wage, phone, lastActive, dateHired, address, leader, row )
	if window.window then
		destroyElement( window.window )
		window.window = nil
		guiSetInputEnabled( false )
		return
	end
	local width = 275
	local height = 340
	local x = ( screenX - width ) / 2
	local y = ( screenY - height ) / 2
	window.window = guiCreateWindow( x, y, width, height, 'Manage Employee: ' .. characterName, false )
	guiWindowSetSizable(window.window, false)
	guiSetInputEnabled( true )

	window.label = { }
	window.edit = { }

	window.label[1] = guiCreateLabel(10, 30, 75, 20, 'Name:', false, window.window)
	window.edit[1] = guiCreateLabel(95, 30, 175, 20, characterName, false, window.window)

	window.label[2] = guiCreateLabel(10, 58, 75, 20, 'Title:', false, window.window)
	window.edit[2] = guiCreateEdit(90, 58, 175, 20, rank, false, window.window)

	window.label[3] = guiCreateLabel(10, 86, 75, 20, 'Wage:', false, window.window)
	window.edit[3] = guiCreateEdit(90, 86, 175, 20, wage, false, window.window)

	window.label[4] = guiCreateLabel(10, 114, 75, 20, 'Phone:', false, window.window)
	window.edit[4] = guiCreateEdit(90, 114, 175, 20, phone, false, window.window)

	window.label[5] = guiCreateLabel(10, 142, 75, 20, 'Address:', false, window.window)
	window.edit[5] = guiCreateEdit(90, 142, 175, 20, address, false, window.window)

	window.label[6] = guiCreateLabel(10, 170, 75, 20, 'Date Hired:', false, window.window)
	window.edit[6] = guiCreateLabel(95, 170, 175, 20, outputDate( dateHired ), false, window.window)

	window.label[7] = guiCreateLabel(10, 198, 75, 20, 'Last Active:', false, window.window)
	window.edit[7] = guiCreateLabel(95, 198, 175, 20, lastActive, false, window.window)

	window.label[8] = guiCreateLabel(10, 226, 75, 20, 'Leader:', false, window.window)
	window.edit[8] = guiCreateCheckBox(95, 226, 175, 20, 'Leader', ( tonumber( leader ) == 1 ), false, window.window)

	window.update = guiCreateButton(10, 260, 705, 30, 'Update Employee', false, window.window)
	addEventHandler( 'onClientGUIClick', window.update, 
		function ()
			local name = guiGetText( window.edit[1] )
			local rank = guiGetText( window.edit[2] )
			local wage = guiGetText( window.edit[3] )
			local phone = guiGetText( window.edit[4] )
			local address = guiGetText( window.edit[5] )
			local leader = guiCheckBoxGetSelected ( window.edit[8] ) and 1 or 0
			triggerServerEvent( 'business:manageEmployee', localPlayer, business, character, characterName, rank, wage, phone, address, leader, row )
			outputChatBox( 'You have updated employee ' .. characterName .. '.', 100, 255, 100 )
			manageEmployee()
		end, false 
	)
	window.close = guiCreateButton(10, 300, 705, 30, 'Cancel', false, window.window)
	addEventHandler( 'onClientGUIClick', window.close, manageEmployee, false )
end