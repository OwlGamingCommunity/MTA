--[[--------------------------------------------------
	GUI Editor
	client
	dimensions_set.lua
	
	some wrappers for some dimension setting functions 
	(right click an element -> 'Dimensions' -> profit?)
--]]--------------------------------------------------


--[[--------------------------------------------------
	x / y
--]]--------------------------------------------------

function guiGetXPosition(element)
	local x = guiGetPosition(element, getElementData(element, "guieditor:relative"))
	return x
end


function guiGetYPosition(element)
	local _,y = guiGetPosition(element, getElementData(element, "guieditor:relative"))
	return y
end


function guiGetXPositionForMenu(element)
	return tonumber( string.format("%.3f", guiGetXPosition(element)) )
end


function guiGetYPositionForMenu(element)
	return tonumber( string.format("%.3f", guiGetYPosition(element)) )
end


function guiSetXPosition(element, x)
	local x_,y = guiGetPosition(element, getElementData(element, "guieditor:relative"))
	
	local action = {}
	action[#action + 1] = {}
	action[#action].ufunc = guiSetPosition
	action[#action].uvalues = {element, x_, y, getElementData(element, "guieditor:relative")}
	action[#action].rfunc = guiSetPosition	
	action[#action].rvalues = {element, x, y, getElementData(element, "guieditor:relative")}
	action.description = "Set "..stripGUIPrefix(getElementType(element)).." x position"
	UndoRedo.add(action)
	
	guiSetPosition(element, x, y, getElementData(element, "guieditor:relative"))
end


function guiSetYPosition(element, y)
	local x,y_ = guiGetPosition(element, getElementData(element, "guieditor:relative"))
	
	local action = {}
	action[#action + 1] = {}
	action[#action].ufunc = guiSetPosition
	action[#action].uvalues = {element, x, y_, getElementData(element, "guieditor:relative")}	
	action[#action].rfunc = guiSetPosition	
	action[#action].rvalues = {element, x, y, getElementData(element, "guieditor:relative")}
	action.description = "Set "..stripGUIPrefix(getElementType(element)).." y position"
	UndoRedo.add(action)
	
	guiSetPosition(element, x, y, getElementData(element, "guieditor:relative"))
end


function guiSetXPositionFromMenu(editbox, element)
	guiSetXPosition(element, tonumber(editbox.edit.text))
end


function guiSetYPositionFromMenu(editbox, element)
	guiSetYPosition(element, tonumber(editbox.edit.text))
end


--[[--------------------------------------------------
	width / height
--]]--------------------------------------------------

function guiGetWidth(element)
	local w = guiGetSize(element, getElementData(element, "guieditor:relative"))
	return w
end


function guiGetHeight(element)
	local _,h = guiGetSize(element, getElementData(element, "guieditor:relative"))
	return h
end


function guiGetWidthForMenu(element)
	return tonumber( string.format("%.3f", guiGetWidth(element)) )
end


function guiGetHeightForMenu(element)
	return tonumber( string.format("%.3f", guiGetHeight(element)) )
end


function guiSetWidth(element, w)
	local w_,h = guiGetSize(element, getElementData(element, "guieditor:relative"))
	
	local action = {}
	action[#action + 1] = {}
	action[#action].ufunc = guiSetSize
	action[#action].uvalues = {element, w_, h, getElementData(element, "guieditor:relative")}	
	action[#action].rfunc = guiSetSize	
	action[#action].rvalues = {element, w, h, getElementData(element, "guieditor:relative")}
	action.description = "Set "..stripGUIPrefix(getElementType(element)).." width"
	UndoRedo.add(action)	
	
	guiSetSize(element, w, h, getElementData(element, "guieditor:relative"))
end


function guiSetHeight(element, h)
	local w,h_ = guiGetSize(element, getElementData(element, "guieditor:relative"))
	
	local action = {}
	action[#action + 1] = {}
	action[#action].ufunc = guiSetSize
	action[#action].uvalues = {element, w, h_, getElementData(element, "guieditor:relative")}	
	action[#action].rfunc = guiSetSize	
	action[#action].rvalues = {element, w, h, getElementData(element, "guieditor:relative")}
	action.description = "Set "..stripGUIPrefix(getElementType(element)).." height"
	UndoRedo.add(action)		
	
	guiSetSize(element, w, h, getElementData(element, "guieditor:relative"))
end


function guiSetWidthFromMenu(editbox, element)
	guiSetWidth(element, tonumber(editbox.edit.text))
end


function guiSetHeightFromMenu(editbox, element)
	guiSetHeight(element, tonumber(editbox.edit.text))
end