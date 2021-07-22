--[[--------------------------------------------------
	GUI Editor
	client
	attacher.lua
	
	manage attaching and detaching elements to/from each other
--]]--------------------------------------------------


Attacher = {	
	item = nil
}


function Attacher.detach(element, ignoreWarnings)
	if not exists(element) then
		return
	end
	
	--[[
	if not ignoreWarnings and not managed(element) then
		local m = MessageBox_Continue:create("Some elements that have been loaded from elsewhere cannot be completely copied. Detaching this element may result in some element properties being reset.\n\nAre you sure you want to continue?", "Yes", "No")
		m.onAffirmative = Attacher.detach
		m.onAffirmativeArgs = {element, true}
		return
	end
	]]
	
	local x, y = guiGetAbsolutePosition(element)
	
	local copy = copyGUIElement(element, true, guiRoot)
	
	guiRemove(element, false)
	
	guiSetPosition(copy, x, y, false)
	
	local action = {}
	action[#action + 1] = {
		ufunc = guiRestore, 
		uvalues = {element}, 
		rfunc = guiRemove, 
		rvalues = {element}, 
		__destruct = {ufunc = guiDelete, urvalues = {element}}
	}
	action[#action + 1] = {
		ufunc = guiRemove, 
		uvalues = {copy}, 
		rfunc = guiRestore, 
		rvalues = {copy}, 
		__destruct = {ufunc = guiDelete, urvalues = {copy}}
	}
	
	action.description = "Detach " .. guiGetFriendlyName(element)
	
	UndoRedo.add(action)
		
	ContextBar.add(guiGetFriendlyName(element) .. " detached from parent")
end

function Attacher.add(element, ignoreWarnings)
	if not exists(element) then
		return
	end
	
	--[[
	if not ignoreWarnings and not managed(element) then
		local m = MessageBox_Continue:create("Some elements that have been loaded from elsewhere cannot be completely copied. Attaching this element may result in some element properties being reset.\n\nAre you sure you want to continue?", "Yes", "No")
		m.onAffirmative = Attacher.add
		m.onAffirmativeArgs = {element, true}
		return
	end
	]]
	
	Attacher.item = element
	
	ContextBar.add("Left click on the parent element to attach to")
end

function Attacher.attach(element, newParent)
	if not exists(newParent) or newParent == element then
		return
	end
	
	local x, y = guiGetAbsolutePosition(Attacher.item)
	local w, h = guiGetSize(Attacher.item, false)
	
	local ex, ey = guiGetAbsolutePosition(newParent)
	local ew, eh = guiGetSize(newParent, false)
	
	if x < ex then	
		x = ex + 1
	elseif (x + w) > (ex + ew) then
		x = ex + ew - w - 1
	end
	
	if y < ey then
		y = ey + 1
	elseif (y + h) > (ey + eh) then
		y = ey + eh - h - 1
	end
		
	local adjustedX = x - ex
	local adjustedY = y - ey
	
	local copy = copyGUIElement(Attacher.item, true, newParent)

	guiRemove(Attacher.item, false)

	guiSetPosition(copy, adjustedX, adjustedY, false)
	guiSetSize(copy, w, h, false)
	
	local action = {}
	action[#action + 1] = {
		ufunc = guiRestore, 
		uvalues = {element}, 
		rfunc = guiRemove, 
		rvalues = {element}, 
		__destruct = {ufunc = guiDelete, urvalues = {element}}
	}
	action[#action + 1] = {
		ufunc = guiRemove, 
		uvalues = {copy}, 
		rfunc = guiRestore, 
		rvalues = {copy}, 
		__destruct = {ufunc = guiDelete, urvalues = {copy}}
	}
	
	action.description = "Attach " .. guiGetFriendlyName(element)
	
	UndoRedo.add(action)
	
	ContextBar.add(guiGetFriendlyName(element) .. " attached to new parent")
	
	Attacher.clear()
end


function Attacher.click(button, state, absoluteX, absoluteY)
	if not exists(Attacher.item) then
		return
	end
	
	if button == "left" then
		if state == "down" then
			local element = guiGetHoverElement()

			if exists(element) then
				Attacher.attach(Attacher.item, element)
				return
			end
			
			Attacher.clear()
		elseif state == "up" then
			
		end	
	end
end


function Attacher.clear()
	Attacher.item = nil
end


function Attacher.enter(source, absoluteX, absoluteY)
	if not exists(Attacher.item) then
		return
	end
	
	if source == Attacher.item then
		return
	end
	
	addToSelectionList(source)
end


function Attacher.leave(source, absoluteX, absoluteY)
	if gDrawSelectionList[source] then
		gDrawSelectionList[source] = nil
	end	
end