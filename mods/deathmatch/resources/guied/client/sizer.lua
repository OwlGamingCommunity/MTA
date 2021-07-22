--[[--------------------------------------------------
	GUI Editor
	client
	sizer.lua
	
	manage the sizing of elements within the editor
--]]--------------------------------------------------


Sizer = {	
	items = {},
	state = "up"
}

local gFreeSize = {topLeft = 1, topRight = 2, bottomLeft = 3, bottomLeft = 4}


function Sizer.add(element, sizeX, sizeY, useOffset, ignoreAction, constrain)
	local dx
	
	if type(element) == "table" then
		if element.dxType then
			dx = element
			element = element.element
		end
	end
	
	if not dx then
		dx = DX_Element.getDXFromElement(element)
	end

	if not exists(element) then
		return
	end
	
	local constraint = -1
	
	if constrain then 
		local w, h = guiGetSize(element, false)
		constraint = w / h
		sizeX = true
		sizeY = true
	end
	
	sizeX = (sizeX == nil and true or sizeX)
	sizeY = (sizeY == nil and true or sizeY)
	
	if useOffset then
		useOffset = {}
	end

	if not ignoreAction then
		local action = UndoRedo.generateActionUndo(UndoRedo.presets.size, element)	
		setElementData(element, "guieditor.internal:actionSizer", action)
	end
	
	ContextBar.add("Click and drag to resize the element")

	table.insert(Sizer.items, {element = element, sizeX = sizeX, sizeY = sizeY, offset = useOffset, anchor = dx and dx.anchor or false, constraint = constraint})
end	


function Sizer.clear()
	--Sizer.items = {}
	
	local action = {}
	
	for i = #Sizer.items, 1, -1 do
		if Sizer.items[i].processed then
			if exists(Sizer.items[i].element) then
				local x, y
				
				if getElementData(Sizer.items[i].element, "guieditor.internal:dxElement") then
					local dx = DX_Element.getDXFromElement(Sizer.items[i].element)
					
					if dx.dxType == gDXTypes.line then
						dx.ignoreSizing = nil
					
						local mX, mY = getCursorPosition(true)
						x, y = guiGetPosition(Sizer.items[i].element, false)
					
						guiSetPosition(Sizer.items[i].element, math.min(Sizer.items[i].position.x, mX), math.min(Sizer.items[i].position.y, mY), false)
						guiSetSize(Sizer.items[i].element, math.max(Sizer.items[i].position.x, mX) - math.min(Sizer.items[i].position.x, mX), math.max(Sizer.items[i].position.y, mY) - math.min(Sizer.items[i].position.y, mY), false)	
					end
				end				
			
				if getElementData(Sizer.items[i].element, "guieditor.internal:actionSizer") then
					local a = getElementData(Sizer.items[i].element, "guieditor.internal:actionSizer")
					
					a = UndoRedo.generateActionRedo(UndoRedo.presets.size, Sizer.items[i].element, a)

					if action then
						if Sizer.items[i].anchor then
							local dx = DX_Element.getDXFromElement(Sizer.items[i].element)
							
							local ac = {}
							
							ac[#ac + 1] = {}
							ac[#ac].ufunc = 
								function(d, a)
									d.anchor = a
								end
							ac[#ac].uvalues = {dx, Sizer.items[i].anchor}
							
							ac[#ac + 1] = {}
							ac[#ac].rfunc = 
								function(d, a)
									d.anchor = a
								end
							ac[#ac].rvalues = {dx, dx.anchor}	

							ac[#ac + 1] = {}
							ac[#ac].ufunc = guiSetPosition
							ac[#ac].uvalues = {Sizer.items[i].element, x, y, false}								
							
							local newX, newY = guiGetPosition(Sizer.items[i].element, false)
							ac[#ac + 1] = {}
							ac[#ac].rfunc = guiSetPosition
							ac[#ac].rvalues = {Sizer.items[i].element, newX, newY, false}								

							a = UndoRedo.join(ac, a)
						end
					
						action = UndoRedo.join(action, a)
					else
						action = a
					end

					setElementData(Sizer.items[i].element, "guieditor.internal:actionSizer", nil)
				end

				for _,e in ipairs(guiGetSiblings(Sizer.items[i].element)) do
					if guiNeedsBorder(e) then
						setElementData(e, "guieditor:drawBorder", nil)
					end
				end	
				
				if getElementType(Sizer.items[i].element) == "gui-tabpanel" then
					--local tab = createGUIElementFromType("tab", nil, nil, nil, nil, nil, Sizer.items[i].element, "tab1")
					--setElementData(element, "guieditor:drawBorder", true)
					--setupGUIElement(tab)
				end
			end
			
			table.remove(Sizer.items, i)	
		end
	end	
	
	if action and #action > 0 then
		action.description = "Resize element(s)"
		UndoRedo.add(action)
	end	
end


function Sizer.click(button, state, absoluteX, absoluteY)
	if button == "left" then
		Sizer.state = state
		
		if state == "down" then
			for _,item in ipairs(Sizer.items) do
				local x, y = guiGetAbsolutePosition(item.element)
				local w, h = guiGetSize(item.element, false)
				
				if item.offset then
					item.offset.x = absoluteX - (x + w)
					item.offset.y = absoluteY - (y + h)		
				end
				
				item.position = {}
				item.position.x = x
				item.position.y = y
				
				item.elementType = getElementType(item.element)
				
				if getElementData(item.element, "guieditor.internal:dxElement") then
					local dx = DX_Element.getDXFromElement(item.element)
					item.elementType = DX_Element.getType(dx.dxType)
								
					if item.elementType == "dx_line" then
						if dx.anchor == 1 then
							
						elseif dx.anchor == 2 then
							item.position.x = x + w
						elseif dx.anchor == 3 then
							item.position.y = y + h
						elseif dx.anchor == 4 then
							item.position.x = x + w
							item.position.y = y + h
						end
						
						dx.ignoreSizing = true
					end
				end

				item.processed = true
				
				for _,e in ipairs(guiGetSiblings(item.element)) do
					if relevant(e) and guiNeedsBorder(e) then
						setElementData(e, "guieditor:drawBorder", true)
					end
				end					
			end			
		elseif state == "up" then
			Sizer.clear()
		end	
	end
end


function Sizer.move(absoluteX, absoluteY)
	if Sizer.state == "down" then
		for _,item in ipairs(Sizer.items) do
			local eW, eH = guiGetSize(item.element, false)
			local eX, eY = guiGetPosition(item.element, false)
			
			local x, y = Creator.clampSize(absoluteX - item.position.x - (item.offset and item.offset.x or 0), absoluteY - item.position.y - (item.offset and item.offset.y or 0), item.elementType)
				
			eW, eH = Creator.clampSize(eW, eH, item.elementType)
				
			if (item.sizeX and item.sizeY) then
				if item.constraint > 0 then
					if y < x / item.constraint then
						guiSetSize(item.element, y * item.constraint, y, false)
					else
						guiSetSize(item.element, x, x / item.constraint, false)
					end
				else
					guiSetSize(item.element, x, y, false)
				end
			elseif item.sizeX then
				guiSetSize(item.element, x, eH, false)
			elseif item.sizeY then
				guiSetSize(item.element, eW, y, false)
			end
				
			if item.elementType == "dx_line" then
				local dx = DX_Element.getDXFromElement(item.element)	
					
				dx.endX = absoluteX
				dx.endY = absoluteY
					
				if dx.startX <= dx.endX then
					if dx.startY <= dx.endY then
						dx.anchor = 1
					else
						dx.anchor = 3
					end
				else
					if dx.startY <= dx.endY then
						dx.anchor = 2
					else
						dx.anchor = 4
					end					
				end		
			end	
		end
	end
end


function Sizer.active()
	return Sizer.state == "down" and #Sizer.items > 0
end
