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

function transferPropertyOwnership()
	GUIEditor.window[1] = guiCreateWindow(897, 58, 284, 151, "Transfer Ownership", false)
	guiWindowSetSizable(GUIEditor.window[1], false)

	GUIEditor.label[1] = guiCreateLabel(10, 34, 114, 15, "Transfer To:", false, GUIEditor.window[1])
	GUIEditor.edit[1] = guiCreateEdit(98, 30, 171, 24, "John Smith", false, GUIEditor.window[1])
	GUIEditor.button[14] = guiCreateButton(9, 66, 265, 32, "Process Transfer", false, GUIEditor.window[1])
	GUIEditor.button[15] = guiCreateButton(10, 108, 265, 32, "Cancel", false, GUIEditor.window[1])
end