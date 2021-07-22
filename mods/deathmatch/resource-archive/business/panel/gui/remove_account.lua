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


function removeAccountPayable()
	GUIEditor.window[3] = guiCreateWindow(864, 453, 299, 139, "Remove Account: Bob's Food Distributing", false)
	guiWindowSetSizable(GUIEditor.window[3], false)

	GUIEditor.label[8] = guiCreateLabel(10, 26, 279, 33, "Are you sure you wish to remove account 'Bob's Food Distributing'?", false, GUIEditor.window[3])
	guiLabelSetHorizontalAlign(GUIEditor.label[8], "left", true)
	GUIEditor.button[12] = guiCreateButton(9, 61, 280, 29, "Yes", false, GUIEditor.window[3])
	GUIEditor.button[13] = guiCreateButton(9, 100, 280, 29, "No", false, GUIEditor.window[3]) 
end