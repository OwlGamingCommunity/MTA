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

function addAccountPayable()
	GUIEditor.window[1] = guiCreateWindow(860, 22, 303, 191, "Add Account", false)
	guiWindowSetSizable(GUIEditor.window[1], false)

	GUIEditor.label[1] = guiCreateLabel(10, 28, 115, 16, "Recipient:", false, GUIEditor.window[1])

	GUIEditor.label[2] = guiCreateLabel(10, 58, 115, 16, "Amount:", false, GUIEditor.window[1])
	GUIEditor.label[3] = guiCreateLabel(10, 86, 115, 16, "Description:", false, GUIEditor.window[1])
	GUIEditor.edit[3] = guiCreateEdit(89, 24, 206, 24, "Bob's Food Distributing", false, GUIEditor.window[1])
	GUIEditor.edit[4] = guiCreateEdit(89, 54, 206, 24, "100", false, GUIEditor.window[1])
	GUIEditor.edit[5] = guiCreateEdit(89, 82, 206, 24, "Weekly food delivery for supplies", false, GUIEditor.window[1])
	GUIEditor.button[8] = guiCreateButton(9, 113, 286, 28, "Add Account", false, GUIEditor.window[1])
	GUIEditor.button[9] = guiCreateButton(10, 151, 283, 28, "Cancel", false, GUIEditor.window[1])
end