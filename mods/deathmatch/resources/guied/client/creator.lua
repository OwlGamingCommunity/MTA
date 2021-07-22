--[[--------------------------------------------------
	GUI Editor
	client
	creator.lua
	
	manage the creation of elements within the editor
--]]--------------------------------------------------


Creator = {
	item = nil,
	guiHover = nil,

	size = {
		minimum = {
			w = 15, 
			h = 15,
			memo = {w = 20, h = 20},
			staticimage = {w = 2, h = 2},
			dx_line = {w = 0, h = 0},
			dx_image = {w = 0, h = 0},
			dx_rectangle = {w = 0, h = 0},
			dx_text = {w = 0, h = 0},
		},
	}
}

function Creator.set(element, menu, ...)
	element = string.lower(tostring(element) or "")

	Creator.item = element
	Creator.itemArgs = {...}
	
	ContextBar.add("Hold left click and drag to create the "..element)

	if menu then
		if type(menu) == "table" then
			Creator.guiParent = menu.guiParent
		else
			Creator.guiParent = menu
		end
	end
end


function Creator.create(elementType, x, y, parent)
	elementType = string.lower(tostring(elementType) or "")

	outputDebug("Creator.create("..elementType.." ("..asString(parent).."), ...)", "CREATOR")

	x, y = Creator.parsePosition(x, y, parent)
	local w, h = Creator.getSizeMinimum(elementType)
	
	local args = {}
	
	if elementType == "tabpanel" then
		args[1] = true
	elseif elementType == "staticimage" or elementType == "scrollbar" or elementType == "dx_image" then
		args = Creator.itemArgs
	end
	
	local element = createGUIElementFromType(elementType, x, y, w, h, false, parent, unpack(args))

	if guiNeedsBorder(element) then
		setElementData(element, "guieditor:drawBorder", true)	
	end
	
	setupGUIElement(element)

	UndoRedo.generateActionUndo(UndoRedo.presets.create, element)
	
	Sizer.add(element, true, true, false, true)	
end



function Creator.clear()
	Creator.item = nil
	Creator.guiParent = nil
end



function Creator.click(button, state, absoluteX, absoluteY)
	if state == "down" then
		if button == "right" then
			Creator.clear()
		else
			if Creator.item then
				Creator.create(Creator.item, absoluteX, absoluteY, Creator.guiParent)
				Creator.clear()
			end
		end
	end
end


--[[--------------------------------------------------
	takes an absolute screen position and returns the same screen position relative to a specified element
--]]--------------------------------------------------
function Creator.parsePosition(x, y, parent)
	if parent and exists(parent) then
		local parentX, parentY = guiGetAbsolutePosition(parent)

		return x - parentX, y - parentY
	end

	return x, y
end


--[[--------------------------------------------------
	clamp the given size between the size restraints
--]]--------------------------------------------------
function Creator.clampSize(w, h, elementType)
	local minimumW, minimumH = Creator.getSizeMinimum(elementType)
	
	if w < minimumW then
		w = minimumW
	end

	if h < minimumH then
		h = minimumH
	end

	return w, h
end


function Creator.getSizeMinimum(elementType)
	local w, h = Creator.size.minimum.w, Creator.size.minimum.h
	
	if elementType then
		if elementType:find("gui-") then
			elementType = stripGUIPrefix(elementType)
		end
		
		if Creator.size.minimum[elementType] then
			w = Creator.size.minimum[elementType].w
			h = Creator.size.minimum[elementType].h
		end
	end

	return w, h
end


function Creator.enter(element, absoluteX, absoluteY)
	Creator.guiHover = element
end


function Creator.leave(element, absoluteX, absoluteY)
	Creator.guiHover = nil
end


function Creator.move(element, absoluteX, absoluteY)
	Creator.guiHover = element
end


function guiGetHoverElement()
	--return exists(Creator.guiHover) and Creator.guiHover or nil
	
	if exists(Creator.guiHover) then
		local element = Creator.guiHover
		
		-- if a masked element has snuck through, target and destroy
		if getElementData(element, "guieditor.internal:mask") then
			element = getElementData(element, "guieditor.internal:mask")
		end
		
		if getElementData(element, "guieditor.internal:redirect") then
			return getElementData(element, "guieditor.internal:redirect")
		end
		
		return element
	end	
	
	return nil
end
