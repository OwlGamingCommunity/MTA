--[[--------------------------------------------------
	GUI Editor
	client
	menu_common.lua
	
	creates all the common right click menus menus that are (generally) used in more than one place 
	(ie: the 'create' menu is used on the main menu, and on all the gui element menus)
--]]--------------------------------------------------


--[[--------------------------------------------------
	creation menu, used for creating all gui elements
--]]--------------------------------------------------
function createMenu_creation()
	gMenus.create = Menu:create("Create Item")
	
	--gMenus.create:addItem(createItem_window())
	gMenus.create:addItem(createItem_button())
	gMenus.create:addItem(createItem_memo())
	gMenus.create:addItem(createItem_label())
	gMenus.create:addItem(createItem_checkbox())
	gMenus.create:addItem(createItem_edit())
	gMenus.create:addItem(createItem_progressbar())
	gMenus.create:addItem(createItem_radiobutton())
	gMenus.create:addItem(createItem_gridlist())
	gMenus.create:addItem(createItem_tabpanel())
	gMenus.create:addItem(createItem_staticimage())
	gMenus.create:addItem(createItem_scrollbar()):setChild(gMenus.scrollbarSub.id)
	gMenus.create:addItem(createItem_scrollpane())
	gMenus.create:addItem(createItem_combobox())
	
	createMenu_creation_()
end


function createMenu_creation_()
	gMenus.create_ = Menu:create("Create Item")
	
	gMenus.create_:addItem(createItem_window())
	gMenus.create_:addItem(createItem_button())
	gMenus.create_:addItem(createItem_memo())
	gMenus.create_:addItem(createItem_label())
	gMenus.create_:addItem(createItem_checkbox())
	gMenus.create_:addItem(createItem_edit())
	gMenus.create_:addItem(createItem_progressbar())
	gMenus.create_:addItem(createItem_radiobutton())
	gMenus.create_:addItem(createItem_gridlist())
	gMenus.create_:addItem(createItem_tabpanel())
	gMenus.create_:addItem(createItem_staticimage())
	gMenus.create_:addItem(createItem_scrollbar()):setChild(gMenus.scrollbarSub.id)
	gMenus.create_:addItem(createItem_scrollpane())
	gMenus.create_:addItem(createItem_combobox())
end

--[[--------------------------------------------------
	scrollbar sub-menu
--]]--------------------------------------------------
function createMenu_scrollbarSub()
	gMenus.scrollbarSub = Menu:create("Scrollbars")

	gMenus.scrollbarSub:addItem(createItem_scrollbarHorizontal())
	gMenus.scrollbarSub:addItem(createItem_scrollbarVertical())
end


--[[--------------------------------------------------
	element copy sub-menu
--]]--------------------------------------------------
function createMenu_copySub()
	gMenus.copySub = Menu:create("Copy")

	gMenus.copySub:addItem(createItem_copyChildren())
end


function createMenu_multipleCopySub()
	gMenus.multipleCopySub = Menu:create("Copy")

	gMenus.multipleCopySub:addItem(createItem_multipleCopyChildren())
end

--[[--------------------------------------------------
	element move sub-menu
--]]--------------------------------------------------
function createMenu_moveSub()
	gMenus.moveSub = Menu:create("Movement")

	gMenus.moveSub:addItem(createItem_moveX())
	gMenus.moveSub:addItem(createItem_moveY())
end


--[[--------------------------------------------------
	element resize sub-menu
--]]--------------------------------------------------
function createMenu_resizeSub()
	gMenus.resizeSub = Menu:create("Resize")

	gMenus.resizeSub:addItem(createItem_resizeX())
	gMenus.resizeSub:addItem(createItem_resizeY())
	gMenus.resizeSub:addItem(createItem_resizeImage())
	gMenus.resizeSub:addItem(createItem_resizeFitWidth())
	gMenus.resizeSub:addItem(createItem_resizeFitHeight())
	gMenus.resizeSub:addItem(createItem_resizeContrained())
end


--[[--------------------------------------------------
	output type sub-menu
--]]--------------------------------------------------
function createMenu_outputTypeSub()
	gMenus.outputTypeSub = Menu:create("Output Type")

	gMenus.outputTypeSub:addItem(createItem_outputTypeHelp())
end


--[[--------------------------------------------------
	position sub-menu
--]]--------------------------------------------------
function createMenu_dimensionsSub()
	gMenus.dimensionsSub = Menu:create("Dimensions")
	
	gMenus.dimensionsSub:addItem(createItem_dimensionsX())
	gMenus.dimensionsSub:addItem(createItem_dimensionsY())
	gMenus.dimensionsSub:addItem(createItem_dimensionsWidth())
	gMenus.dimensionsSub:addItem(createItem_dimensionsHeight())
	gMenus.dimensionsSub:addItem(createItem_offsetFrom())
end


--[[--------------------------------------------------
	multiple selection menu
--]]--------------------------------------------------
function createMenu_multiple()
	gMenus.multiple = Menu:create("Multiple Selection")
	
	--gMenus.multiple:addItem(createItem_alpha())
	gMenus.multiple:addItem(createItem_multipleMove()):setChild(gMenus.multipleMoveSub.id)
	gMenus.multiple:addItem(createItem_multipleResize()):setChild(gMenus.multipleResizeSub.id)
	gMenus.multiple:addItem(createItem_multipleText())
	gMenus.multiple:addItem(createItem_multipleAlpha())
	gMenus.multiple:addItem(createItem_multipleCopy()):setChild(gMenus.multipleCopySub.id)
	gMenus.multiple:addItem(createItem_multipleDeletion())
	gMenus.multiple:addItem(createItem_cancel())
end


--[[--------------------------------------------------
	multiple selection move sub-menu
--]]--------------------------------------------------
function createMenu_multipleMoveSub()
	gMenus.multipleMoveSub = Menu:create("Movement")
	
	gMenus.multipleMoveSub:addItem(createItem_multipleMoveX())
	gMenus.multipleMoveSub:addItem(createItem_multipleMoveY())
end


--[[--------------------------------------------------
	multiple selection resize sub-menu
--]]--------------------------------------------------
function createMenu_multipleResizeSub()
	gMenus.multipleResizeSub = Menu:create("Resize")

	gMenus.multipleResizeSub:addItem(createItem_multipleResizeX())
	gMenus.multipleResizeSub:addItem(createItem_multipleResizeY())
end


--[[--------------------------------------------------
	undo sub menu
--]]--------------------------------------------------
function createMenu_undoSub()
	gMenus.undoSub = Menu:create("Undo Actions", 200)

	gMenus.undoSub:addItem(createItem_undoList())
end


--[[--------------------------------------------------
	redo sub menu
--]]--------------------------------------------------
function createMenu_redoSub()
	gMenus.redoSub = Menu:create("Redo Actions", 200)

	gMenus.redoSub:addItem(createItem_redoList())
end


--[[--------------------------------------------------
	gridlist item sub menu
--]]--------------------------------------------------
function createMenu_gridlistItemSub()
	gMenus.gridlistItemSub = Menu:create("Gridlist item")

	gMenus.gridlistItemSub:addItem(createItem_gridlistItemText())
	gMenus.gridlistItemSub:addItem(createItem_gridlistItemColour())
	
	gMenus.gridlistItemSub.onOpen = 
		function(menu)
			local element = menu:getGUI()
			
			if exists(element) then
				-- disable so that we the item doesn't get deselected when clicking the menu option
				guiSetEnabled(element, false)
			
				local row, col = guiGridListGetSelectedItem(element)
							
				if row and col and row ~= -1 and col ~= -1 then
					menu:setClickable(true, true)
					return
				end				
			end
			
			menu:setClickable(false, true)
		end
		
	gMenus.gridlistItemSub.onClose =
		function(menu)
			local element = menu:getGUI()
			
			if exists(element) then
				guiSetEnabled(element, true)			
			end
		end		
end


--[[--------------------------------------------------
	dx dimension sub menu
--]]--------------------------------------------------
function createMenu_dxDimensionsLineSub()
	gMenus.dxDimensionsLineSub = Menu:create("Dimensions")
	
	gMenus.dxDimensionsLineSub:addItem(createItem_dxDimensionsStartX())
	gMenus.dxDimensionsLineSub:addItem(createItem_dxDimensionsStartY())
	gMenus.dxDimensionsLineSub:addItem(createItem_dxDimensionsEndX())
	gMenus.dxDimensionsLineSub:addItem(createItem_dxDimensionsEndY())
	--gMenus.dxDimensionsLineSub:addItem(createItem_offsetFrom())
end

function createMenu_dxDimensionsSub()
	gMenus.dxDimensionsSub = Menu:create("Dimensions")
	
	gMenus.dxDimensionsSub:addItem(createItem_dxDimensionsX())
	gMenus.dxDimensionsSub:addItem(createItem_dxDimensionsY())
	gMenus.dxDimensionsSub:addItem(createItem_dxDimensionsWidth())
	gMenus.dxDimensionsSub:addItem(createItem_dxDimensionsHeight())
	--gMenus.dxDimensionsSub:addItem(createItem_offsetFrom())
end


--[[--------------------------------------------------
	position code sub menu
--]]--------------------------------------------------
function createMenu_positionCodeSub()
	gMenus.positionCodeSub = Menu:create("Presets", 190)
	gMenus.positionCodeSub.onPreOpen = 
		function() 
			gMenus.positionCodeSub:removeAllItems()

			for i,preset in ipairs(PositionCoder.presets) do
				local t, limited = string.limit(preset.description, gMenus.positionCodeSub.width - 20)
				
				if limited then
					t = t .. "..."
				end
				
				-- reuse items if they are hanging around in memory anyway
				local item = MenuItem.get({{property = "text", value = t}, {property = "presetIndex", value = i}})
				
				if item then
					gMenus.positionCodeSub:addItem(item)
				else
					gMenus.positionCodeSub:addItem(createItem_positionCodePreset(t, i))
				end
			end
		end
	
	PositionCoder.loadFile()
end