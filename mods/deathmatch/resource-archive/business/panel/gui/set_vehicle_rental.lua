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

function setVehicleRental()
	GUIEditor.window[2] = guiCreateWindow(897, 219, 284, 193, "Rent Vehicle: 2014 Jeep Cherokee", false)
	guiWindowSetSizable(GUIEditor.window[2], false)

	GUIEditor.label[2] = guiCreateLabel(10, 34, 114, 15, "Rent To:", false, GUIEditor.window[2])
	GUIEditor.edit[2] = guiCreateEdit(98, 30, 171, 24, "John Smith", false, GUIEditor.window[2])
	GUIEditor.button[16] = guiCreateButton(11, 109, 263, 32, "Rent Vehicle", false, GUIEditor.window[2])
	GUIEditor.button[17] = guiCreateButton(10, 151, 264, 32, "Cancel", false, GUIEditor.window[2])
	GUIEditor.edit[3] = guiCreateEdit(98, 64, 171, 24, "300", false, GUIEditor.window[2])
	GUIEditor.label[3] = guiCreateLabel(10, 69, 114, 15, "Rental Price:", false, GUIEditor.window[2])    
end