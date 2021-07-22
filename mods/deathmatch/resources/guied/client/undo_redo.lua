--[[--------------------------------------------------
	GUI Editor
	client
	und_redo.lua


	Each undo/redo group is defined as a series of 'actions'		
	Basic action structure:

	action = {
		{
			ufunc = guiSetText,
			uvalues = {gui-element, newText},
			
			rfunc = guiSetText,
			rvalues = {gui-element, oldText}
		}
			
		{
			ufunc = guiSetAlpha,
			uvalues = {gui-element, newAlpha},
			
			rfunc = guiSetAlpha,
			rvalues = {gui-element, oldAlpha}
		}			
	}
		
	When the group is undone, ufunc will be called with the uvalues arguments for each action going sequentially forwards through the group
	When the group is redone, rfunc will be called with the rvalues arguments for each action, going sequentially backwards through the group
--]]--------------------------------------------------


UndoRedo = {
	undoList = {},
	redoList = {},
	
	bufferSize = 100,
	visualBufferSize = 10,
	
	presets = {
		position = 1,
		size = 2,
		create = 3,
		delete = 4,
	}
}


addEventHandler("onClientResourceStart", resourceRoot,
	function()
		UndoRedo.updateGUI()
	end
)


function UndoRedo.add(action)
	outputDebug("add "..tostring(action).." ("..tostring(action.description)..")", "UNDO_REDO")
	
	if #UndoRedo.undoList == UndoRedo.bufferSize then
		UndoRedo.processDestructor(UndoRedo.undoList[UndoRedo.bufferSize], "undo")
		
		UndoRedo.undoList[UndoRedo.bufferSize] = nil
	end

	table.insert(UndoRedo.undoList, 1, action)
	
	UndoRedo.updateGUI()
end


function UndoRedo.remove()
	outputDebug("remove", "UNDO_REDO")
	
	if #UndoRedo.undoList > 0 then
		if #UndoRedo.redoList == UndoRedo.bufferSize then	
			--UndoRedo.processDependancies(UndoRedo.redoList[UndoRedo.bufferSize])
			UndoRedo.processDestructor(UndoRedo.redoList[UndoRedo.bufferSize], "redo")
			
			UndoRedo.redoList[#UndoRedo.redoList] = nil
		end

		table.insert(UndoRedo.redoList, 1, UndoRedo.undoList[1])	

		table.remove(UndoRedo.undoList, 1)
	end
	
	UndoRedo.updateGUI()
end


function UndoRedo.undo()
	local action = UndoRedo.undoList[1]
	
	outputDebug("undo " .. tostring(action).." ("..tostring(action and action.description or "nil")..")", "UNDO_REDO")
	
	if action then
		for i,v in ipairs(action) do
			local ret 
			
			if v.ufunc then
				ret = v.ufunc(unpack(v.uvalues or {}))
			end		
		end
		
		if action.description then
			ContextBar.add("Undo: " .. action.description)
		end
		
		UndoRedo.remove()
	else
		ContextBar.add("There are no more actions to undo")
	end
	
	UndoRedo.updateGUI()
end


function UndoRedo.redo()
	local action = UndoRedo.redoList[1]

	outputDebug("redo " .. tostring(action).." ("..tostring(action and action.description or "nil")..")", "UNDO_REDO")
	
	if action then
		for i,v in ipairs(action) do
			local ret 
			
			if v.rfunc then
				ret = v.rfunc(unpack(v.rvalues or {}))
			end		
		end
		
		UndoRedo.add(action)
		
		if action.description then
			ContextBar.add("Redo: " .. action.description)
		end
		
		table.remove(UndoRedo.redoList, 1)
	else
		ContextBar.add("There are no more actions to redo")
	end	
	
	UndoRedo.updateGUI()
end


function UndoRedo.generateActionUndo(actionType, element, action)
	if not action then
		action = {}
		action[1] = {}
	end
	
	--action = action or {}
	
	if actionType == UndoRedo.presets.position then
		local x,y = guiGetPosition(element, false)
		
		--action[#action + 1] = {}
		
		action[#action].ufunc = guiSetPosition
		action[#action].uvalues = {element, x, y, false}
		--action[#action].requires = {element}
		action.description = "Set " .. stripGUIPrefix(getElementType(element)) .. " position"
	elseif actionType == UndoRedo.presets.size then
		local w,h = guiGetSize(element, false)
		
		--action[#action + 1] = {}
		
		action[#action].ufunc = guiSetSize
		action[#action].uvalues = {element, w, h, false}
		--action[#action].requires = {element}
		action.description = "Set " .. stripGUIPrefix(getElementType(element)) .. " size"
	elseif actionType == UndoRedo.presets.create then
		--action[#action + 1] = {}
		
		action[#action] = {ufunc = guiRemove, uvalues = {element}, rfunc = guiRestore, rvalues = {element}, __destruct = {rfunc = guiDelete, rvalues = {element}}--[[, dependancies = {element}]]}
		
		action.description = "Create " .. stripGUIPrefix(getElementType(element))
		
		local dx = DX_Element.getDXFromElement(element)
		if dx then
			action[#action + 1] = {}
			action[#action] = 
				{
					ufunc = DX_Element.dxRemove, 
					uvalues = {dx},
					rfunc = DX_Element.dxRestore, 
					rvalues = {dx},					
				}
				
			action.description = "Create " .. DX_Element.getTypeFriendly(dx.dxType)
		end
		
		UndoRedo.add(action)
	elseif actionType == UndoRedo.presets.delete then
		--action[#action + 1] = {}
		
		action[#action] = {ufunc = guiRestore, uvalues = {element}, rfunc = guiRemove, rvalues = {element}, __destruct = {ufunc = guiDelete, uvalues = {element}}--[[, dependancies = {element}]]}
		
		action.description = "Delete " .. stripGUIPrefix(getElementType(element))
		
		local dx = DX_Element.getDXFromElement(element)
		if dx then
			action[#action + 1] = {}
			action[#action] = 
				{
					ufunc = DX_Element.dxRestore, 
					uvalues = {dx},
					rfunc = DX_Element.dxRemove, 
					rvalues = {dx},					
				}
				
			action.description = "Delete " .. DX_Element.getTypeFriendly(dx.dxType)
		end		
		
		UndoRedo.add(action)		
	end
	
	return action
end


function UndoRedo.generateActionRedo(actionType, element, action)
	if not action then
		action = {}
		action[1] = {}
	end
	
	if actionType == UndoRedo.presets.position then
		local x,y = guiGetPosition(element, false)
		
		--action[#action + 1] = {}
		
		action[#action].rfunc = guiSetPosition
		action[#action].rvalues = {element, x, y, false}
	elseif actionType == UndoRedo.presets.size then
		local w,h = guiGetSize(element, false)
		
		--action[#action + 1] = {}
		
		action[#action].rfunc = guiSetSize
		action[#action].rvalues = {element, w, h, false}
	elseif actionType == UndoRedo.presets.create then
		--action[#action + 1] = {}
		
		action[#action] = {ufunc = guiRemove, uvalues = {element}, rfunc = guiRestore, rvalues = {element}, __destruct = {rfunc = guiDelete, rvalues = {element}}}
		UndoRedo.add(action)	
	elseif actionType == UndoRedo.presets.delete then
		--action[#action + 1] = {}
		
		action[#action] = {ufunc = guiRestore, uvalues = {element}, rfunc = guiRemove, rvalues = {element}, __destruct = {ufunc = guiDelete, uvalues = {element}}--[[, dependancies = {element}]]}
		UndoRedo.add(action)		
	end
	
	return action
end


function UndoRedo.merge(primary, secondary)
	local action = {}

	for i,v in ipairs(secondary) do
		action[i] = {}
		
		action[i].ufunc = primary[i].ufunc
		action[i].uvalues = primary[i].uvalues
		action[i].rfunc = v.rfunc
		action[i].rvalues = v.rvalues
	end
	
	return action
end


function UndoRedo.mergeAndAdd(primary, secondary)
	local action = UndoRedo.merge(primary, secondary)
	
	UndoRedo.add(action)
end


function UndoRedo.join(primary, secondary)
	local action = {}
	
	for i,v in ipairs(primary) do
		action[#action + 1] = {}
		
		--for _,a in ipairs(v) do
			if v.ufunc then
				action[#action].ufunc = v.ufunc
				action[#action].uvalues = v.uvalues				
			end	

			if v.rfunc then
				action[#action].rfunc = v.rfunc
				action[#action].rvalues = v.rvalues
			end
		--end
	end
	
	for i,v in ipairs(secondary) do
		action[#action + 1] = {}
		
		--for _,a in ipairs(v) do
			if v.ufunc then
				action[#action].ufunc = v.ufunc
				action[#action].uvalues = v.uvalues				
			end	

			if v.rfunc then
				action[#action].rfunc = v.rfunc
				action[#action].rvalues = v.rvalues
			end
		--end
	end
	
	return action
end

-- called when an item is permanently removed from the undo/redo stack
function UndoRedo.processDestructor(action, t)
	if action then
		outputDebug("processing destructor "..tostring(action), "UNDO_REDO")
		for _,a in ipairs(action) do
			if a.__destruct then
				if t == "undo" then
					if a.__destruct.ufunc then
						a.__destruct.ufunc(unpack(a.__destruct.uvalues or {}))
					end
				elseif t == "redo" then
					if a.__destruct.rfunc then
						a.__destruct.rfunc(unpack(a.__destruct.rvalues or {}))
					end
				end				
			end		
		end
	end	
end


function UndoRedo.processDependancies(action)
	outputDebug("checking dependancies "..tostring(action), "UNDO_REDO")
	if action then
		local removal = {}
		
		for _,a in ipairs(action) do
			if a.dependancies then
				for i,listEntry in ipairs(UndoRedo.redoList) do
					for _,ac in ipairs(listEntry) do		
						if ac.requires then
							for _,dependancy in pairs(a.dependancies) do
								if table.find(ac.requires, dependancy) then
									removal[#removal + 1] = i
								end
							end
						end
					end
				end
								
			end
		end
		
		for i = #removal, 1, -1 do
			if UndoRedo.redoList[removal[i]] ~= action then
				UndoRedo.redoList[removal[i]] = nil
			end
		end
	end	
end



function UndoRedo.updateGUI()
	if not gEnabled then
		return
	end
	
	local t = ""
	
	for i, action in ipairs(UndoRedo.undoList) do
		if i > UndoRedo.visualBufferSize then
			t = t .. "\n..."
			break
		end
		
		t = t .. (i > 1 and "\n" or "") .. tostring(i) .. ": " .. (action.description or "[NO DESCRIPTION]")
	end
	
	if t == "" then
		t = "[NONE]"
	end
	
	gMenus.undoSub.items[2]:setText(t)
	
	t = ""
	for i, action in ipairs(UndoRedo.redoList) do
		if i > UndoRedo.visualBufferSize then
			t = t .. "\n..."
			break
		end
		
		t = t .. (i > 1 and "\n" or "") .. tostring(i) .. ": " .. (action.description or "[NO DESCRIPTION]")
	end
	
	if t == "" then
		t = "[NONE]"
	end
	
	gMenus.redoSub.items[2]:setText(t)	
end


function UndoRedo.findUndo(conditions)
	UndoRedo.find(conditions, UndoRedo.undoList)
end


function UndoRedo.findRedo(conditions)
	UndoRedo.find(conditions, UndoRedo.redoList)
end

--[[ 
	find an action that matches the given conditions

	e.g. to match a guiSetAlpha(element, 50) call:
	
	{
		{property = "ufunc", propertyValue = guiSetAlpha},
		{property = "uvalues", propertyValue = element, propertyIndex = 1},
		{property = "uvalues", propertyValue = 50, propertyIndex = 2}
	}
]]
function UndoRedo.find(conditions, list) 
	if list == nil then
		list = table.merge(UndoRedo.undoList, UndoRedo.redoList)
	end
	
	for i, action in ipairs(list) do
		local match = true
		local item
		
		outputDebug("matching conditions for: " .. tostring(action.description), "UNDO_REDO_CONDITION")
		
		for _, actionItem in ipairs(action) do
			for _, condition in ipairs(conditions) do
				if not condition.passed then
					if condition.index then
						if type(actionItem[condition.property]) == "table" and #actionItem[condition.property] >= condition.index then
							if actionItem[condition.property][condition.index] == condition.propertyValue then
								outputDebug("condition match: " .. condition.property .. "[" .. tostring(condition.index) .. "] matches " .. tostring(condition.propertyValue), "UNDO_REDO_CONDITION")
								condition.passed = true
							else
								outputDebug("condition different: " .. condition.property .. "[" .. tostring(condition.index) .. "] found " .. tostring(actionItem[condition.property][condition.index]) .. " expected " .. tostring(condition.propertyValue), "UNDO_REDO_CONDITION")
							end
						end
					else
						if actionItem[condition.property] == condition.propertyValue then
							outputDebug("condition match: " .. condition.property .. " matches " .. tostring(condition.propertyValue), "UNDO_REDO_CONDITION")
							condition.passed = true						
						else 
							outputDebug("condition different: " .. condition.property .. " found " .. tostring(actionItem[condition.property]) .. " expected " .. tostring(condition.propertyValue), "UNDO_REDO_CONDITION")
						end
					end
				end
			end
		end
		
		for _, condition in ipairs(conditions) do
			if not condition.passed then
				match = false
				break
			end
		end

		if match then
			return action
		end
	end
end



function UndoRedo.guiSetAlpha(element, alpha, convert, down)
	if exists(element) then
		if convert then
			alpha = alpha / 100
		end
		
		if down then		
			local action = {}
				
			action[#action + 1] = {}
			action[#action].ufunc = guiSetAlpha
			action[#action].uvalues = {element, guiGetAlpha(element)}

			setElementData(element, "guieditor.internal:actionAlpha", action)
		else
			local action = getElementData(element, "guieditor.internal:actionAlpha")
				
			action[#action + 1] = {}
			action[#action].rfunc = guiSetAlpha
			action[#action].rvalues = {element, alpha}

			setElementData(element, "guieditor.internal:actionAlpha", nil)

			action.description = "Set alpha "..tostring(alpha * 100)
			
			UndoRedo.add(action)
		end
	end
end


function UndoRedo.guiProgressBarSetProgress(element, progress, down)
	if exists(element) then
		if down then		
			local action = {}
				
			action[#action + 1] = {}
			action[#action].ufunc = guiProgressBarSetProgress
			action[#action].uvalues = {element, guiProgressBarGetProgress(element)}

			setElementData(element, "guieditor.internal:actionProgress", action)
		else
			local action = getElementData(element, "guieditor.internal:actionProgress")
				
			action[#action + 1] = {}
			action[#action].rfunc = guiProgressBarSetProgress
			action[#action].rvalues = {element, progress}

			setElementData(element, "guieditor.internal:actionProgress", nil)

			action.description = "Set progress "..tostring(progress)
			
			UndoRedo.add(action)
		end		
	end
end


function UndoRedo.guiScrollBarSetScrollPosition(element, scroll, down)
	if exists(element) then
		if down then		
			local action = {}
				
			action[#action + 1] = {}
			action[#action].ufunc = guiScrollBarSetScrollPosition
			action[#action].uvalues = {element, guiScrollBarGetScrollPosition(element)}

			setElementData(element, "guieditor.internal:actionScroll", action)
		else
			local action = getElementData(element, "guieditor.internal:actionScroll")
				
			action[#action + 1] = {}
			action[#action].rfunc = guiScrollBarSetScrollPosition
			action[#action].rvalues = {element, scroll}

			setElementData(element, "guieditor.internal:actionScroll", nil)

			action.description = "Set scroll "..tostring(scroll)
			
			UndoRedo.add(action)
		end
	end
end



function UndoRedo.setFontSize(element, size, down)
	if exists(element) then
		local dx = DX_Element.getDXFromElement(element)
			
		if down then		
			local action = {}
				
			action[#action + 1] = {}
			action[#action].ufunc = FontPicker.setFontSize
			
			if dx then
				action[#action].uvalues = {FontPicker, element, dx.fontSize}
			else
				action[#action].uvalues = {FontPicker, element, getElementData(element, "guieditor:fontSize")}
			end
			
			setElementData(element, "guieditor.internal:actionFontSize", action)
		else
			local action = getElementData(element, "guieditor.internal:actionFontSize")
				
			action[#action + 1] = {}
			action[#action].rfunc = FontPicker.setFontSize
			action[#action].rvalues = {FontPicker, element, size}

			setElementData(element, "guieditor.internal:actionFontSize", nil)

			action.description = "Set font size "..tostring(size)
			
			UndoRedo.add(action)
		end
	end
end

--[[
addCommandHandler("undo", UndoRedo.undo)
addCommandHandler("redo", UndoRedo.redo)
]]