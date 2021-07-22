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

function transferVehicleOwnership()
	window.window = guiCreateWindow(897, 58, 284, 151, "Transfer Ownership", false)
	guiWindowSetSizable(window.window, false)

	window.label[1] = guiCreateLabel(10, 34, 114, 15, "Transfer To:", false, window.window)
	window.edit[1] = guiCreateEdit(98, 30, 171, 24, "John Smith", false, window.window)
	window.button[14] = guiCreateButton(9, 66, 265, 32, "Process Transfer", false, window.window)
	window.button[15] = guiCreateButton(10, 108, 265, 32, "Cancel", false, window.window)
end