--[[--------------------------------------------------
	GUI Editor
	client
	menu_manager.lua
	
	manage the initial creation of all the right click menus
--]]--------------------------------------------------

gMenus = {}

function createMenus()
	if gMenus.main then
		return
	end
	
	createMenu_scrollbarSub()
	createMenu_creation()
	createMenu_moveSub()
	createMenu_resizeSub()
	createMenu_loadSub()
	createMenu_outputTypeSub()
	createMenu_dimensionsSub()
	createMenu_undoSub()
	createMenu_redoSub()
	createMenu_copySub()
	createMenu_positionCodeSub()
	createMenu_gridlistItemSub()
	
	createMenu_multipleMoveSub()
	createMenu_multipleResizeSub()
	createMenu_multipleCopySub()
	
	
	createMenu_dxDimensionsLineSub()
	createMenu_dxDimensionsSub()
	
	createMenu_resolutionPreview()
	
	
	createMenu_dxLine()	
	createMenu_dxRectangle()	
	createMenu_dxText()
	createMenu_dxImage()
	
	createMenu_dxItems()	
	

	createMenu_main()
	
	createMenu_window()
	createMenu_button()
	createMenu_memo()
	createMenu_label()
	createMenu_checkbox()
	createMenu_edit()
	createMenu_progressbar()
	createMenu_radiobutton()
	createMenu_gridlist()
	createMenu_tabpanel()
	createMenu_tab()
	createMenu_staticimage()
	createMenu_scrollbar()
	createMenu_scrollpane()
	createMenu_combobox()
	
	createMenu_notLoaded()
	createMenu_noLoad()
	
	createMenu_multiple()
end

