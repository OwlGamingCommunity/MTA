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

function editAccountPayable()
	GUIEditor.window[2] = guiCreateWindow(860, 248, 303, 191, "Edit Account", false)
	guiWindowSetSizable(GUIEditor.window[2], false)

	GUIEditor.label[4] = guiCreateLabel(10, 28, 115, 16, "Recipient:", false, GUIEditor.window[2])

	GUIEditor.label[5] = guiCreateLabel(10, 58, 115, 16, "Amount:", false, GUIEditor.window[2])
	GUIEditor.label[6] = guiCreateLabel(10, 86, 115, 16, "Description:", false, GUIEditor.window[2])
	GUIEditor.edit[8] = guiCreateEdit(89, 24, 205, 24, "Bob's Food Distributing", false, GUIEditor.window[2])
	GUIEditor.edit[9] = guiCreateEdit(89, 54, 205, 24, "100", false, GUIEditor.window[2])
	GUIEditor.edit[10] = guiCreateEdit(89, 82, 205, 24, "Weekly food delivery for supplies", false, GUIEditor.window[2])
	GUIEditor.button[10] = guiCreateButton(9, 113, 285, 28, "Edit Account", false, GUIEditor.window[2])
	GUIEditor.button[11] = guiCreateButton(10, 151, 283, 28, "Cancel", false, GUIEditor.window[2])
end