--[[--------------------------------------------------
	GUI Editor
	client
	multiple_element.lua
	
	manages selection of multiple elements at once
--]]--------------------------------------------------


Multiple = {
	dragging = false,
	drag = nil,
	parent = nil,
	inside = {},
	
	imageOffset = 3,
	
	-- wrappers to support using multiple elements in various areas of guieditor
	Mover = {},
	Sizer = {},
}


function Multiple.click(button, state, absoluteX, absoluteY)
	if button == "left" and state == "up" then
		if Multiple.drag then
			Multiple.stopDragging()
		end
	end
	
	if button == "middle" and state == "down" then
		if Multiple.drag then
			Multiple.stopDragging()
		end
		
		if resolutionPreview.active then
			return
		end
		
		Multiple.dragging = true
		Multiple.parent = guiGetHoverElement()
		Multiple.drag = {startX = absoluteX, startY = absoluteY, endX = absoluteX, endY = absoluteY}
	elseif button == "middle" and state == "up" then
		Multiple.dragging = false
	end
end


function Multiple.stopDragging()
	if Multiple.drag then
		for _,e in ipairs(Multiple.parent and getElementChildren(Multiple.parent) or guiGetScreenElements()) do
			if relevant(e) and guiGetVisible(e) then
				if guiNeedsBorder(e) then
					setElementData(e, "guieditor:drawBorder", false)
				end
			end
		end		
		
		Multiple.parent = nil
		Multiple.drag = nil
		Multiple.inside = {}
	end
end


function Multiple.move(absoluteX, absoluteY)
	if Multiple.dragging and Multiple.drag then
		Multiple.drag.endX = absoluteX
		Multiple.drag.endY = absoluteY
		
		local dragW = math.max(Multiple.drag.startX, Multiple.drag.endX) - math.min(Multiple.drag.startX, Multiple.drag.endX)
		local dragH = math.max(Multiple.drag.startY, Multiple.drag.endY) - math.min(Multiple.drag.startY, Multiple.drag.endY)
		
		for _,e in ipairs(Multiple.parent and getElementChildren(Multiple.parent) or guiGetScreenElements()) do
			if relevant(e) and guiGetVisible(e) --[[and guiGetProperty(e, "MousePassThroughEnabled") == "False"]] then
				local x, y = guiGetAbsolutePosition(e)
				local w, h = guiGetSize(e, false)

				local oX, oY = rectangleOverlap(x, y, w, h, math.min(Multiple.drag.startX, Multiple.drag.endX), math.min(Multiple.drag.startY, Multiple.drag.endY), dragW, dragH)
				if oX and oY then
					if not Multiple.inside[e] then
						Multiple.inside[e] = {x = x + (w / 2), y = y + (h / 2)}
					end	
				else
					if Multiple.inside[e] then
						Multiple.inside[e] = nil
					end
				end
				
				if guiNeedsBorder(e) then
					setElementData(e, "guieditor:drawBorder", true)
				end	
			end
		end
	end
end


addEventHandler("onClientRender", root,
	function()
		if not gEnabled then
			return
		end
	
		if Multiple.drag then
			dxDrawLine(Multiple.drag.startX, Multiple.drag.startY, Multiple.drag.endX, Multiple.drag.startY, tocolor(unpack(gColours.primary)), 1, true)
			dxDrawLine(Multiple.drag.startX, Multiple.drag.endY, Multiple.drag.endX, Multiple.drag.endY, tocolor(unpack(gColours.primary)), 1, true)
			
			dxDrawLine(Multiple.drag.startX, Multiple.drag.startY, Multiple.drag.startX, Multiple.drag.endY, tocolor(unpack(gColours.primary)), 1, true)
			dxDrawLine(Multiple.drag.endX, Multiple.drag.startY, Multiple.drag.endX, Multiple.drag.endY, tocolor(unpack(gColours.primary)), 1, true)
			
			for e,pos in pairs(Multiple.inside) do
				dxDrawImage(pos.x - 4, pos.y - 4, 8, 8, "images/dx_elements/radio_button.png", 0, 0, 0, tocolor(unpack(gColours.tertiary)), true)
			end
			
			dxDrawText(tostring(table.count(Multiple.inside)), Multiple.drag.startX, Multiple.drag.startY, Multiple.drag.endX, Multiple.drag.startY + 13, tocolor(unpack(gColours.primary)), 1, "default", "center", "top", false, false, true)
		end
	end
)





function Multiple.Mover.add(element, moveX, moveY)
	if element and type(element) == "table" then
		for e in pairs(element) do
			Mover.add(e, moveX, moveY, true)
		end
	end
end


function Multiple.Sizer.add(element, sizeX, sizeY)
	if element and type(element) == "table" then
		for e in pairs(element) do
			Sizer.add(e, sizeX, sizeY, true)
		end
	end	
end


function Multiple.setElementText(element)
	local mbox = MessageBox_Input:create()
	mbox.onAccept = 
		function()
			local text = guiGetText(mbox.input)

			local action = {}
			
			for e in pairs(element) do
				action[#action + 1] = {}
				
				action[#action].ufunc = guiSetText
				action[#action].uvalues = {e, guiGetText(e)}
				
				guiSetText(e, text)		
				
				action[#action].rfunc = guiSetText
				action[#action].rvalues = {e, text}				
			end
			
			if #action > 0 then
				action.description = "Set element texts"
				UndoRedo.add(action)
			end
		end
end


function Multiple.guiSetAlpha(element, value, convert, down)
	if element and type(element) == "table" then
		-- on down, called before first change
		if down == true then
			for e in pairs(element) do
				local action = {}
						
				action[#action + 1] = {}
				action[#action].ufunc = guiSetAlpha
				action[#action].uvalues = {e, guiGetAlpha(e)}

				setElementData(e, "guieditor.internal:actionAlpha", action)	
			end	
		-- on up, called just before final change
		elseif down == false then
			local action = {}
			
			for e in pairs(element) do	
				local a = getElementData(e, "guieditor.internal:actionAlpha")

				a[#a].rfunc = guiSetAlpha
				a[#a].rvalues = {e, guiGetAlpha(e)}

				if action then
					action = UndoRedo.join(action, a)
				else
					action = a
				end
				
				setElementData(e, "guieditor.internal:actionAlpha", nil)	
			end
			
			if action then
				action.description = "Set n alpha"
			
				UndoRedo.add(action)
			end
		-- regular change
		else
			for e in pairs(element) do
				guiSetAlpha(e, value, true)			
			end
		end
	end
end



function Multiple.guiRemove(element, createAction)
	if element and type(element) == "table" then
		local action = {}
	
		for e in pairs(element) do
			local dx = DX_Element.getDXFromElement(e)
						
			if dx then
				dx:dxRemove()
			end
			
			guiRemove(e, false)

			action[#action + 1] = {}
			action[#action] = {ufunc = guiRestore, uvalues = {e}, rfunc = guiRemove, rvalues = {e}, __destruct = {ufunc = guiDelete, urvalues = {e}}}
			
			if dx then 				
				action[#action + 1] = {}
				action[#action] = 
					{
						ufunc = DX_Element.dxRestore, 
						uvalues = {dx},
						rfunc = DX_Element.dxRemove, 
						rvalues = {dx},					
					}	
			end
		end
		
		action.description = "Remove elements"
		
		UndoRedo.add(action)
	end
end


function Multiple.copyGUIElement(element)
	if element and type(element) == "table" then
		local action = {}
		
		action.description = "Copy elements"
		
		for e in pairs(element) do
			local c = copyGUIElement(e, true)

			action[#action + 1] = {}
			action[#action] = {ufunc = guiRemove, uvalues = {c}, rfunc = guiRestore, rvalues = {c}, __destruct = {rfunc = guiDelete, rvalues = {c}}}
		end
		
		UndoRedo.add(action)			
		
		if table.count(element) > 1 then
			ContextBar.add("Copies of the elements have been made on top of the originals")
		else
			ContextBar.add("A copy of the element has been made on top of the original")
		end
	end
end


function Multiple.copyGUIElementChildren(element, silent)
	if element and type(element) == "table" then
		local action = {}
		
		action.description = "Copy elements"
		
		for e in pairs(element) do
			local c = copyGUIElementChildren(e, silent)

			action[#action + 1] = {}
			action[#action] = {ufunc = guiRemove, uvalues = {c}, rfunc = guiRestore, rvalues = {c}, __destruct = {rfunc = guiDelete, rvalues = {c}}}
		end
		
		UndoRedo.add(action)			
		
		if table.count(element) > 1 then
			ContextBar.add("Copies of the elements have been made on top of the originals")
		else
			ContextBar.add("A copy of the element has been made on top of the original")
		end
	end
end