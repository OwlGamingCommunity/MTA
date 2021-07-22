--[[--------------------------------------------------
	GUI Editor
	client
	menu_main.lua
	
	create the main element right click menus
--]]--------------------------------------------------


--[[--------------------------------------------------
	main menu, used when right clicking the screen
--]]--------------------------------------------------
function createMenu_main()
	gMenus.main = Menu:create("Main Menu", 155, 0, 0)
	
	gMenus.main:addItem(createItem_creation()):setChild(gMenus.create_.id)
	gMenus.main:addItem(createItem_drawing()):setChild(gMenus.dxItems.id)
	gMenus.main:addItem(createItem_resolution()):setChild(gMenus.resolutionPreview.id)
	gMenus.main:addItem(createItem_undo()):setChild(gMenus.undoSub.id)
	gMenus.main:addItem(createItem_redo()):setChild(gMenus.redoSub.id)
	gMenus.main:addItem(createItem_output())
	gMenus.main:addItem(createItem_loadCode())
	gMenus.main:addItem(createItem_share())
	gMenus.main:addItem(createItem_settings())
	gMenus.main:addItem(createItem_help())
	gMenus.main:addItem(createItem_tutorial())
	gMenus.main:addItem(createItem_checkUpdate())
	gMenus.main:addItem(createItem_cancel())
end



function createMenu_window()
	gMenus.window = Menu:create("Window")
	
	gMenus.window:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.window:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.window:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.window:addItem(createItem_text())
	gMenus.window:addItem(createItem_colour())
	gMenus.window:addItem(createItem_alpha())
	gMenus.window:addItem(createItem_variable())	
	gMenus.window:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.window:addItem(createItem_windowMovable())
	gMenus.window:addItem(createItem_windowSizable())
	gMenus.window:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.window:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.window:addItem(createItem_properties())
	gMenus.window:addItem(createItem_moveToBack())
	gMenus.window:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.window:addItem(createItem_parent())
	gMenus.window:addItem(createItem_deletion())
	gMenus.window:addItem(createItem_locked())
	gMenus.window:addItem(createItem_cancel())
end


function createMenu_button()
	gMenus.button = Menu:create("Button")
	
	gMenus.button:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.button:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.button:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.button:addItem(createItem_text())
	gMenus.button:addItem(createItem_colour())
	gMenus.button:addItem(createItem_font())
	gMenus.button:addItem(createItem_fontSize())
	gMenus.button:addItem(createItem_alpha())
	gMenus.button:addItem(createItem_variable())
	gMenus.button:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.button:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.button:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.button:addItem(createItem_properties())
	gMenus.button:addItem(createItem_moveToBack())	
	gMenus.button:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.button:addItem(createItem_detachFromElement())
	gMenus.button:addItem(createItem_attachToElement())
	gMenus.button:addItem(createItem_parent())
	gMenus.button:addItem(createItem_deletion())	
	gMenus.button:addItem(createItem_locked())
	gMenus.button:addItem(createItem_cancel())
end


function createMenu_memo()
	gMenus.memo = Menu:create("Memo")
	
	gMenus.memo:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.memo:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.memo:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.memo:addItem(createItem_text())
	gMenus.memo:addItem(createItem_readOnly())
	gMenus.memo:addItem(createItem_alpha())
	gMenus.memo:addItem(createItem_variable())
	gMenus.memo:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.memo:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.memo:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.memo:addItem(createItem_properties())
	gMenus.memo:addItem(createItem_moveToBack())	
	gMenus.memo:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.memo:addItem(createItem_detachFromElement())
	gMenus.memo:addItem(createItem_attachToElement())
	gMenus.memo:addItem(createItem_parent())
	gMenus.memo:addItem(createItem_deletion())	
	gMenus.memo:addItem(createItem_locked())
	gMenus.memo:addItem(createItem_cancel())	
end


function createMenu_label()
	gMenus.label = Menu:create("Label")
	
	gMenus.label:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.label:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.label:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.label:addItem(createItem_text())
	gMenus.label:addItem(createItem_colour())
	gMenus.label:addItem(createItem_font())
	gMenus.label:addItem(createItem_fontSize())
	gMenus.label:addItem(createItem_wordwrap())	
	gMenus.label:addItem(createItem_alpha())
	gMenus.label:addItem(createItem_variable())
	gMenus.label:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.label:addItem(createItem_horizontalAlignment())
	gMenus.label:addItem(createItem_verticalAlignment())		
	gMenus.label:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.label:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.label:addItem(createItem_properties())
	gMenus.label:addItem(createItem_moveToBack())	
	gMenus.label:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.label:addItem(createItem_detachFromElement())
	gMenus.label:addItem(createItem_attachToElement())
	gMenus.label:addItem(createItem_parent())
	gMenus.label:addItem(createItem_deletion())	
	gMenus.label:addItem(createItem_locked())
	gMenus.label:addItem(createItem_cancel())	
end


function createMenu_checkbox()
	gMenus.checkbox = Menu:create("Checkbox")
	
	gMenus.checkbox:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.checkbox:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.checkbox:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.checkbox:addItem(createItem_text())
	gMenus.checkbox:addItem(createItem_colour())
	gMenus.checkbox:addItem(createItem_font())
	gMenus.checkbox:addItem(createItem_fontSize())
	gMenus.checkbox:addItem(createItem_alpha())
	gMenus.checkbox:addItem(createItem_variable())
	gMenus.checkbox:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.checkbox:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.checkbox:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.checkbox:addItem(createItem_properties())
	gMenus.checkbox:addItem(createItem_moveToBack())	
	gMenus.checkbox:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.checkbox:addItem(createItem_detachFromElement())
	gMenus.checkbox:addItem(createItem_attachToElement())
	gMenus.checkbox:addItem(createItem_parent())
	gMenus.checkbox:addItem(createItem_deletion())	
	gMenus.checkbox:addItem(createItem_locked())
	gMenus.checkbox:addItem(createItem_cancel())	
end


function createMenu_edit()
	gMenus.edit = Menu:create("Edit")
	
	gMenus.edit:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.edit:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.edit:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.edit:addItem(createItem_text())
	gMenus.edit:addItem(createItem_colour())
	gMenus.edit:addItem(createItem_readOnly())
	gMenus.edit:addItem(createItem_masked())
	gMenus.edit:addItem(createItem_maxLength())
	gMenus.edit:addItem(createItem_alpha())
	gMenus.edit:addItem(createItem_variable())
	gMenus.edit:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.edit:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.edit:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.edit:addItem(createItem_properties())
	gMenus.edit:addItem(createItem_moveToBack())	
	gMenus.edit:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.edit:addItem(createItem_detachFromElement())
	gMenus.edit:addItem(createItem_attachToElement())
	gMenus.edit:addItem(createItem_parent())
	gMenus.edit:addItem(createItem_deletion())	
	gMenus.edit:addItem(createItem_locked())
	gMenus.edit:addItem(createItem_cancel())	
end


function createMenu_progressbar()
	gMenus.progressbar = Menu:create("Progress bar")
	
	gMenus.progressbar:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.progressbar:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.progressbar:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.progressbar:addItem(createItem_alpha())
	gMenus.progressbar:addItem(createItem_variable())
	gMenus.progressbar:addItem(createItem_progress())
	gMenus.progressbar:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.progressbar:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.progressbar:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.progressbar:addItem(createItem_properties())
	gMenus.progressbar:addItem(createItem_moveToBack())	
	gMenus.progressbar:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.progressbar:addItem(createItem_detachFromElement())
	gMenus.progressbar:addItem(createItem_attachToElement())
	gMenus.progressbar:addItem(createItem_parent())
	gMenus.progressbar:addItem(createItem_deletion())	
	gMenus.progressbar:addItem(createItem_locked())
	gMenus.progressbar:addItem(createItem_cancel())
end


function createMenu_radiobutton()
	gMenus.radiobutton = Menu:create("Radio button")
	
	gMenus.radiobutton:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.radiobutton:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.radiobutton:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.radiobutton:addItem(createItem_text())
	gMenus.radiobutton:addItem(createItem_colour())
	gMenus.radiobutton:addItem(createItem_font())
	gMenus.radiobutton:addItem(createItem_fontSize())
	gMenus.radiobutton:addItem(createItem_alpha())
	gMenus.radiobutton:addItem(createItem_variable())
	gMenus.radiobutton:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.radiobutton:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.radiobutton:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.radiobutton:addItem(createItem_properties())
	gMenus.radiobutton:addItem(createItem_moveToBack())	
	gMenus.radiobutton:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.radiobutton:addItem(createItem_detachFromElement())
	gMenus.radiobutton:addItem(createItem_attachToElement())
	gMenus.radiobutton:addItem(createItem_parent())
	gMenus.radiobutton:addItem(createItem_deletion())	
	gMenus.radiobutton:addItem(createItem_locked())
	gMenus.radiobutton:addItem(createItem_cancel())
end


function createMenu_gridlist()
	gMenus.gridlist = Menu:create("Gridlist")
	
	gMenus.gridlist:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.gridlist:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.gridlist:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.gridlist:addItem(createItem_alpha())
	gMenus.gridlist:addItem(createItem_addColumn())
	gMenus.gridlist:addItem(createItem_removeColumn())
	gMenus.gridlist:addItem(createItem_addRow())
	gMenus.gridlist:addItem(createItem_removeRow())
	gMenus.gridlist:addItem(createItem_gridlistItem()):setChild(gMenus.gridlistItemSub.id)
	gMenus.gridlist:addItem(createItem_variable())
	gMenus.gridlist:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.gridlist:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.gridlist:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.gridlist:addItem(createItem_properties())
	gMenus.gridlist:addItem(createItem_moveToBack())	
	gMenus.gridlist:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.gridlist:addItem(createItem_detachFromElement())
	gMenus.gridlist:addItem(createItem_attachToElement())
	gMenus.gridlist:addItem(createItem_parent())
	gMenus.gridlist:addItem(createItem_deletion())	
	gMenus.gridlist:addItem(createItem_locked())
	gMenus.gridlist:addItem(createItem_cancel())
end


function createMenu_tabpanel()
	gMenus.tabpanel = Menu:create("Tab panel")
	
	gMenus.tabpanel:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.tabpanel:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.tabpanel:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.tabpanel:addItem(createItem_alpha())
	gMenus.tabpanel:addItem(createItem_addTab())
	gMenus.tabpanel:addItem(createItem_variable())
	gMenus.tabpanel:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.tabpanel:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.tabpanel:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.tabpanel:addItem(createItem_properties())
	gMenus.tabpanel:addItem(createItem_moveToBack())	
	gMenus.tabpanel:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.tabpanel:addItem(createItem_detachFromElement())
	gMenus.tabpanel:addItem(createItem_attachToElement())
	gMenus.tabpanel:addItem(createItem_parent())
	gMenus.tabpanel:addItem(createItem_deletion())	
	gMenus.tabpanel:addItem(createItem_locked())
	gMenus.tabpanel:addItem(createItem_cancel())
end


function createMenu_tab()
	gMenus.tab = Menu:create("Tab")
	
	gMenus.tab:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.tab:addItem(createItem_text())
	gMenus.tab:addItem(createItem_addTab())
	gMenus.tab:addItem(createItem_deleteTab())
	gMenus.tab:addItem(createItem_variable())
	gMenus.tab:addItem(createItem_properties())
	gMenus.tab:addItem(createItem_parent())
	gMenus.tab:addItem(createItem_cancel())
end


function createMenu_staticimage()
	gMenus.staticimage = Menu:create("Image")
	
	gMenus.staticimage:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.staticimage:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.staticimage:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.staticimage:addItem(createItem_colour())
	gMenus.staticimage:addItem(createItem_alpha())
	gMenus.staticimage:addItem(createItem_variable())
	gMenus.staticimage:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.staticimage:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.staticimage:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.staticimage:addItem(createItem_properties())
	gMenus.staticimage:addItem(createItem_moveToBack())	
	gMenus.staticimage:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.staticimage:addItem(createItem_detachFromElement())
	gMenus.staticimage:addItem(createItem_attachToElement())
	gMenus.staticimage:addItem(createItem_parent())
	gMenus.staticimage:addItem(createItem_deletion())	
	gMenus.staticimage:addItem(createItem_locked())
	gMenus.staticimage:addItem(createItem_cancel())
end


function createMenu_scrollbar()
	gMenus.scrollbar = Menu:create("Scrollbar")
	
	gMenus.scrollbar:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.scrollbar:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.scrollbar:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.scrollbar:addItem(createItem_alpha())
	gMenus.scrollbar:addItem(createItem_variable())
	gMenus.scrollbar:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.scrollbar:addItem(createItem_scrollPosition())
	gMenus.scrollbar:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.scrollbar:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.scrollbar:addItem(createItem_properties())
	gMenus.scrollbar:addItem(createItem_moveToBack())	
	gMenus.scrollbar:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.scrollbar:addItem(createItem_detachFromElement())
	gMenus.scrollbar:addItem(createItem_attachToElement())
	gMenus.scrollbar:addItem(createItem_parent())
	gMenus.scrollbar:addItem(createItem_deletion())	
	gMenus.scrollbar:addItem(createItem_locked())
	gMenus.scrollbar:addItem(createItem_cancel())
end


function createMenu_scrollpane()
	gMenus.scrollpane = Menu:create("Scrollpane")
	
	gMenus.scrollpane:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.scrollpane:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.scrollpane:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.scrollpane:addItem(createItem_alpha())
	gMenus.scrollpane:addItem(createItem_variable())
	gMenus.scrollpane:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.scrollpane:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.scrollpane:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.scrollpane:addItem(createItem_properties())
	gMenus.scrollpane:addItem(createItem_moveToBack())	
	gMenus.scrollpane:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.scrollpane:addItem(createItem_detachFromElement())
	gMenus.scrollpane:addItem(createItem_attachToElement())
	gMenus.scrollpane:addItem(createItem_parent())
	gMenus.scrollpane:addItem(createItem_deletion())	
	gMenus.scrollpane:addItem(createItem_locked())
	gMenus.scrollpane:addItem(createItem_cancel())
end


function createMenu_combobox()
	gMenus.combobox = Menu:create("Combobox")
	
	gMenus.combobox:addItem(createItem_creation()):setChild(gMenus.create.id)
	gMenus.combobox:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.combobox:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.combobox:addItem(createItem_addComboItem())
	gMenus.combobox:addItem(createItem_setComboItemText())
	gMenus.combobox:addItem(createItem_removeComboItem())
	gMenus.combobox:addItem(createItem_font())
	gMenus.combobox:addItem(createItem_fontSize())
	gMenus.combobox:addItem(createItem_colour())
	gMenus.combobox:addItem(createItem_alpha())
	gMenus.combobox:addItem(createItem_variable())
	gMenus.combobox:addItem(createItem_outputType()):setChild(gMenus.outputTypeSub.id)
	gMenus.combobox:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.combobox:addItem(createItem_dimensions()):setChild(gMenus.dimensionsSub.id)
	gMenus.combobox:addItem(createItem_properties())
	gMenus.combobox:addItem(createItem_moveToBack())	
	gMenus.combobox:addItem(createItem_copy()):setChild(gMenus.copySub.id)
	gMenus.combobox:addItem(createItem_detachFromElement())
	gMenus.combobox:addItem(createItem_attachToElement())
	gMenus.combobox:addItem(createItem_parent())
	gMenus.combobox:addItem(createItem_deletion())	
	gMenus.combobox:addItem(createItem_locked())
	gMenus.combobox:addItem(createItem_cancel())
end


function createMenu_notLoaded()
	gMenus.notLoaded = Menu:create("Not loaded", 120)
	
	gMenus.notLoaded:addItem(createItem_notLoaded())
	gMenus.notLoaded:addItem(createItem_load()):setChild(gMenus.loadSub.id)
end


function createMenu_loadSub()
	gMenus.loadSub = Menu:create("Load", 130)
	
	gMenus.loadSub:addItem(createItem_loadNoChildren())
end


function createMenu_resolutionPreview()
	gMenus.resolutionPreview = Menu:create("Resolution Preview")
	
	gMenus.resolutionPreview:addItem(createItem_resolution640x480())
	gMenus.resolutionPreview:addItem(createItem_resolution800x600())
	gMenus.resolutionPreview:addItem(createItem_resolution1024x768())
	gMenus.resolutionPreview:addItem(createItem_resolution1280x768())
	gMenus.resolutionPreview:addItem(createItem_resolution1280x1024())
	gMenus.resolutionPreview:addItem(createItem_resolution1440x900())
	gMenus.resolutionPreview:addItem(createItem_resolution1680x1050())
	gMenus.resolutionPreview:addItem(createItem_resolution1920x1080())
	gMenus.resolutionPreview:addItem(createItem_resolution1920x1200())
	gMenus.resolutionPreview:addItem(createItem_resolutionCustomTitle())
	gMenus.resolutionPreview:addItem(createItem_resolutionCustom())
end


function createMenu_noLoad()
	gMenus.noLoad = Menu:create("Load", 100)
	
	gMenus.noLoad:addItem(createItem_noLoad())
end





function createMenu_dxItems()
	gMenus.dxItems = Menu:create("DX Items")
	
	gMenus.dxItems:addItem(createItem_dxLine())
	gMenus.dxItems:addItem(createItem_dxRectangle())
	gMenus.dxItems:addItem(createItem_dxImage())
	gMenus.dxItems:addItem(createItem_dxText())
end



function createMenu_dxLine()
	gMenus.dxLine = Menu:create("DX Line")
	
	gMenus.dxLine:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.dxLine:addItem(createItem_dxLineResize())
	gMenus.dxLine:addItem(createItem_colour())
	gMenus.dxLine:addItem(createItem_dxLineWidth())
	gMenus.dxLine:addItem(createItem_outputType())
	gMenus.dxLine:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.dxLine:addItem(createItem_dxDimensions()):setChild(gMenus.dxDimensionsLineSub.id)
	gMenus.dxLine:addItem(createItem_dxMoveToBack())	
	gMenus.dxLine:addItem(createItem_dxMoveToFront())	
	gMenus.dxLine:addItem(createItem_dxMoveBack())	
	gMenus.dxLine:addItem(createItem_dxMoveForward())	
	gMenus.dxLine:addItem(createItem_postGUI())	
	gMenus.dxLine:addItem(createItem_copy())
	gMenus.dxLine:addItem(createItem_dxDeletion())	
	gMenus.dxLine:addItem(createItem_locked())
	gMenus.dxLine:addItem(createItem_cancel())
end


function createMenu_dxRectangle()
	gMenus.dxRectangle = Menu:create("DX Rectangle")
	
	gMenus.dxRectangle:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.dxRectangle:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.dxRectangle:addItem(createItem_colour())
	gMenus.dxRectangle:addItem(createItem_dxShadow())	
	gMenus.dxRectangle:addItem(createItem_dxShadowColour())	
	gMenus.dxRectangle:addItem(createItem_dxOutline())	
	gMenus.dxRectangle:addItem(createItem_dxOutlineColour())	
	gMenus.dxRectangle:addItem(createItem_outputType())
	gMenus.dxRectangle:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.dxRectangle:addItem(createItem_dxDimensions()):setChild(gMenus.dxDimensionsSub.id)
	gMenus.dxRectangle:addItem(createItem_dxMoveToBack())	
	gMenus.dxRectangle:addItem(createItem_dxMoveToFront())	
	gMenus.dxRectangle:addItem(createItem_dxMoveBack())	
	gMenus.dxRectangle:addItem(createItem_dxMoveForward())	
	gMenus.dxRectangle:addItem(createItem_postGUI())	
	gMenus.dxRectangle:addItem(createItem_copy())
	gMenus.dxRectangle:addItem(createItem_dxDeletion())	
	gMenus.dxRectangle:addItem(createItem_locked())
	gMenus.dxRectangle:addItem(createItem_cancel())
end


function createMenu_dxText()
	gMenus.dxText = Menu:create("DX Text")
	
	gMenus.dxText:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.dxText:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.dxText:addItem(createItem_text())
	gMenus.dxText:addItem(createItem_colour())
	gMenus.dxText:addItem(createItem_font())
	gMenus.dxText:addItem(createItem_fontSize())
	gMenus.dxText:addItem(createItem_dxScale())
	gMenus.dxText:addItem(createItem_horizontalAlignment())
	gMenus.dxText:addItem(createItem_verticalAlignment())		
	gMenus.dxText:addItem(createItem_wordwrap())		
	gMenus.dxText:addItem(createItem_clip())		
	gMenus.dxText:addItem(createItem_colourCoded())		
	gMenus.dxText:addItem(createItem_dxShadow())	
	gMenus.dxText:addItem(createItem_dxShadowColour())		
	gMenus.dxText:addItem(createItem_dxOutline())	
	gMenus.dxText:addItem(createItem_dxOutlineColour())		
	gMenus.dxText:addItem(createItem_outputType())	
	gMenus.dxText:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.dxText:addItem(createItem_dxDimensions()):setChild(gMenus.dxDimensionsSub.id)
	gMenus.dxText:addItem(createItem_dxMoveToBack())	
	gMenus.dxText:addItem(createItem_dxMoveToFront())	
	gMenus.dxText:addItem(createItem_dxMoveBack())	
	gMenus.dxText:addItem(createItem_dxMoveForward())	
	gMenus.dxText:addItem(createItem_postGUI())	
	gMenus.dxText:addItem(createItem_copy())
	gMenus.dxText:addItem(createItem_dxDeletion())	
	gMenus.dxText:addItem(createItem_locked())
	gMenus.dxText:addItem(createItem_cancel())
end


function createMenu_dxImage()
	gMenus.dxImage = Menu:create("DX Image")
	
	gMenus.dxImage:addItem(createItem_move()):setChild(gMenus.moveSub.id)
	gMenus.dxImage:addItem(createItem_resize()):setChild(gMenus.resizeSub.id)
	gMenus.dxImage:addItem(createItem_colour())
	gMenus.dxImage:addItem(createItem_dxRotation())
	gMenus.dxImage:addItem(createItem_dxRotOffsetX())
	gMenus.dxImage:addItem(createItem_dxRotOffsetY())
	gMenus.dxImage:addItem(createItem_outputType())
	gMenus.dxImage:addItem(createItem_positionCode()):setChild(gMenus.positionCodeSub.id)
	gMenus.dxImage:addItem(createItem_dxDimensions()):setChild(gMenus.dxDimensionsSub.id)
	gMenus.dxImage:addItem(createItem_dxMoveToBack())	
	gMenus.dxImage:addItem(createItem_dxMoveToFront())	
	gMenus.dxImage:addItem(createItem_dxMoveBack())	
	gMenus.dxImage:addItem(createItem_dxMoveForward())	
	gMenus.dxImage:addItem(createItem_postGUI())	
	gMenus.dxImage:addItem(createItem_copy())
	gMenus.dxImage:addItem(createItem_dxDeletion())	
	gMenus.dxImage:addItem(createItem_locked())
	gMenus.dxImage:addItem(createItem_cancel())
end
