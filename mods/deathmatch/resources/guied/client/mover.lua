--[[--------------------------------------------------
	GUI Editor
	client
	mover.lua
	
	manage the moving of elements within the editor
--]]--------------------------------------------------


Mover = {	
	items = {},
	state = "up",
	divideValue = 0,
}


addEventHandler("onClientResourceStart", resourceRoot,	
	function()
		bindKey("mouse_wheel_up", "down", Mover.divide)
		bindKey("mouse_wheel_down", "down", Mover.divide)
	end
)


function Mover.add(element, moveX, moveY, ignoreWarnings)
	if type(element) == "table" then
		if element.dxType then
			element = element.element
		end
	end

	if not element or not exists(element) then
		return
	end
	
	if not ignoreWarnings and getElementData(element, "guieditor:positionCode") and Settings.loaded.position_code_movement_warning.value then
		local m = MessageBox_Continue:create("That element is using lua code to calculate its position, if you move it now it will overwrite that code.\n\nAre you sure you want to continue?", "Yes", "No")
		m.onAffirmative = Mover.positionCodeAdd
		m.onAffirmativeArgs = {element, moveX, moveY}
		return
	end
	
	if getElementData(element, "guieditor:positionCode") then
		setElementData(element, "guieditor:positionCode", nil)
	end
	
	outputDebug("Mover.add("..asString(element)..", "..tostring(moveX)..", "..tostring(moveY)..")", "MOVER")
	
	moveX = (moveX == nil and true or moveX)
	moveY = (moveY == nil and true or moveY)
	
	local w, h = guiGetSize(element, false)
	local action = UndoRedo.generateActionUndo(UndoRedo.presets.position, element)
	
	ContextBar.add("Click and drag to move the element")
	
	table.insert(Mover.items, {element = element, moveX = moveX, moveY = moveY, undo = action, width = w, height = h})
end	


function Mover.positionCodeAdd(element, moveX, moveY)
	setElementData(element, "guieditor:positionCode", nil)
	ContextBar.add("Click and drag to move the element")
	Mover.add(element, moveX, moveY)
end


function Mover.clear()
	outputDebug("Mover.clear()", "MOVER")
	
	local action = {}
	
	for i = #Mover.items, 1, -1 do
		if Mover.items[i].processed then
			for _,e in ipairs(guiGetSiblings(Mover.items[i].element)) do
				if guiNeedsBorder(e) then
					setElementData(e, "guieditor:drawBorder", nil)				
				end
			end	
			
			local a = UndoRedo.generateActionRedo(UndoRedo.presets.position, Mover.items[i].element, Mover.items[i].undo)

			if action then
				action = UndoRedo.join(action, a)
			else
				action = a
			end
					
			table.remove(Mover.items, i)		
		end
	end
	
	if #action > 0 then
		action.description = "Set element position"
		
		UndoRedo.add(action)
	end
	
	Mover.divideValue = 0
end


function Mover.click(button, state, absoluteX, absoluteY)
	if button == "left" then
		Mover.state = state
		
		if state == "down" then
			for _,item in ipairs(Mover.items) do
				local x, y = guiGetAbsolutePosition(item.element)
				
				item.offset = {}
				item.offset.x = absoluteX - x
				item.offset.y = absoluteY - y
				
				item.position = {}
				item.position.x = x
				item.position.y = y
				
				item.processed = true
				
				for _,e in ipairs(guiGetSiblings(item.element)) do
					if guiNeedsBorder(e) and relevant(e) then
						setElementData(e, "guieditor:drawBorder", true)
					end
				end	
			end			
		elseif state == "up" then
			Mover.clear()
		end	
	end
end


function Mover.move(absoluteX, absoluteY)
	if Mover.state == "down" and Mover.divideValue == 0 then
		for _,item in ipairs(Mover.items) do
			local x, y = absoluteX - item.offset.x, absoluteY - item.offset.y
			local _x, _y = guiGetPosition(item.element, false)

			local parent = guiGetParent(item.element)
			
			if parent then
				local pX, pY = guiGetAbsolutePosition(parent)
				
				x = x - pX
				y = y - pY
			end	
			
			if (item.moveX and item.moveY) then
				guiSetPosition(item.element, x, y, false)
			elseif item.moveX then
				guiSetPosition(item.element, x, _y, false)
			elseif item.moveY then
				guiSetPosition(item.element, _x, y, false)
			end
			
			guiSetSize(item.element, item.width, item.height, false)
		end
	end
end


function Mover.active()
	return Mover.state == "down" and #Mover.items > 0
end


function Mover.divide(key, keyState)
	if Mover.state ~= "down" or #Mover.items == 0 then
		return
	end
	
	local dir = 0
	
	if key == "mouse_wheel_up" then
		dir = 1
	elseif key == "mouse_wheel_down" then
		dir = -1
	end
	
	Mover.divideValue = math.max(Mover.divideValue + dir, 0)
end


addEventHandler("onClientRender", root,
	function()
		if not gEnabled then
			return
		end
	
		if Mover.divideValue > 0 and Mover.state == "down" and #Mover.items > 0 then
			for _,item in ipairs(Mover.items) do
				local parentW, parentH = gScreen.x, gScreen.y
				local x, y = 0, 0
				
				if guiGetParent(item.element) then
					parentW, parentH = guiGetSize(guiGetParent(item.element), false)
					x, y = guiGetAbsolutePosition(guiGetParent(item.element))
				end
				
				local size = parentW / (Mover.divideValue + 1)
				local cx, cy = getCursorPosition(true)			
				local closest = {}
				
				for i = 1, Mover.divideValue do
					dxDrawLine(x + (i * size), y, x + (i * size), y + parentH, tocolor(255, 0 ,0, 180), 2, true)
					
					local x2 = cx - (x + (i * size))
					
					if not closest.dist or (x2 * x2) < closest.dist then
						closest.dist = x2 * x2
						closest.id = i
					end
				end
				
				if closest.id then
					local w = guiGetSize(item.element, false)
					local _, ey = guiGetPosition(item.element, false)	
					
					guiSetPosition(item.element, (closest.id * size) - (w / 2), ey, false)
				end
			end
		end
	end
)

