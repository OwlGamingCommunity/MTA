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


function fireEmployee( )
	window.window[2] = guiCreateWindow(313, 424, 279, 135, "Fire Employee: John Smith", false)
	guiWindowSetSizable(window.window[2], false)

	window.label[6] = guiCreateLabel(14, 25, 255, 32, "Are you sure you want to fire John Smith?", false, window.window[2])
	window.button[7] = guiCreateButton(9, 50, 260, 30, "Yes", false, window.window[2])
	window.button[8] = guiCreateButton(9, 90, 260, 30, "No", false, window.window[2])
end