--[[--------------------------------------------------
	GUI Editor
	client
	item_multiple_selection.lua
	
	define the right click menu items that can be applied to multiple selections
--]]--------------------------------------------------

function createItem_multipleMove()
	return MenuItem_Text:create("Move"):set({onClick = Multiple.Mover.add, onClickArgs = {"__guiSelection"}})
end


function createItem_multipleMoveX()
	return MenuItem_Text:create("Move X"):set({onClick = Multiple.Mover.add, onClickArgs = {"__guiSelection", true, false}})
end


function createItem_multipleMoveY()
	return MenuItem_Text:create("Move Y"):set({onClick = Multiple.Mover.add, onClickArgs = {"__guiSelection", false, true}})
end




function createItem_multipleResize()
	return MenuItem_Text:create("Resize"):set({onClick = Multiple.Sizer.add, onClickArgs = {"__guiSelection"}})
end


function createItem_multipleResizeX()
	return MenuItem_Text:create("Resize X"):set({onClick = Multiple.Sizer.add, onClickArgs = {"__guiSelection", true, false}})
end


function createItem_multipleResizeY()
	return MenuItem_Text:create("Resize Y"):set({onClick = Multiple.Sizer.add, onClickArgs = {"__guiSelection", false, true}})
end


function createItem_multipleText()
	return MenuItem_Text:create("Set text"):set({onClick = Multiple.setElementText, onClickArgs = {"__guiSelection"}})
end


function createItem_multipleAlpha()
	return MenuItem_Slider:create("Alpha: %value/100"):set({onClickClose = false, onDown = Multiple.guiSetAlpha, onDownArgs = {"__guiSelection", "__value", true, true}, onChange = Multiple.guiSetAlpha, onChangeArgs = {"__guiSelection", "__value", true}, onUp = Multiple.guiSetAlpha, onUpArgs = {"__guiSelection", "__value", true, false}})
end


function createItem_multipleDeletion()
	return MenuItem_Text:create("Delete"):set({onClick = Multiple.guiRemove, onClickArgs = {"__guiSelection", true}})
end


function createItem_multipleCopy()
	return MenuItem_Text:create("Copy"):set({onClick = Multiple.copyGUIElement, onClickArgs = {"__guiSelection"}})
end

function createItem_multipleCopyChildren()
	return MenuItem_Text:create("Copy (include children)"):set({onClick = Multiple.copyGUIElementChildren, onClickArgs = {"__guiSelection", true}})
end