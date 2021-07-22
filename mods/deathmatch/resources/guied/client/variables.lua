--[[--------------------------------------------------
	GUI Editor
	client
	variables.lua
	
	management of all the gui element variables within the editor
--]]--------------------------------------------------


local variables = {}

function getElementVariable(element)
	if not exists(element) then
		--outputDebug("Invalid element in getElementVariable(element)")
		return ""
	end
	
	if not relevant(element) then
		return "[NONE]"
	end

	if getElementData(element, "guieditor:variable") then
		return getElementData(element, "guieditor:variable")
	end

	return getElementData(element, "guieditor:variablePlaceholder"), true
end


function setElementVariable(element, variable)
	if variable and variable ~= "" and not isDefaultVariable(element, variable) then
		setElementData(element, "guieditor:variable", variable)
	else
		setElementData(element, "guieditor:variablePlaceholder", getElementData(element, "guieditor:variablePlaceholder") or generateVariable(element))
		
		if getElementData(element, "guieditor:variable") then
			setElementData(element, "guieditor:variable", nil)
		end
	end
end

function setElementVariableFromMenu(editbox, element)
	local action = getElementData(element, "guieditor.internal:actionVariable")
	
	if action then
		action[#action + 1] = {}
		action[#action].rfunc = setElementData
		action[#action].rvalues = {element, "guieditor:variable", editbox.edit.text}	

		action.description = "Set variable"
		
		UndoRedo.add(action)
		
		setElementData(element, "guieditor.internal:actionVariable", nil)
	end
	
	setElementVariable(element, editbox.edit.text)
end


function clearElementVariable(element)
	if getElementData(element, "guieditor:variable") then
		return
	end
	
	local t = getElementType(element)
	
	t = stripGUIPrefix(t)
	
	variables[t][getElementData(element, "guieditor:variableIndex")] = nil
end


function generateVariable(element)
	local t = getElementType(element)
	
	local index = getNextVariableIndex(t)
	
	setElementData(element, "guieditor:variableIndex", index)
	
	return "GUIEditor." .. stripGUIPrefix(t) .. "[" .. index .. "]"
end


function getNextVariableIndex(elementType)
	elementType = stripGUIPrefix(elementType)
	
	if not variables[elementType] then
		variables[elementType] = {}
	end
	
	local index = 0
	
	while (true) do
		index = index + 1
		
		if not variables[elementType][index] then
			variables[elementType][index] = true
			break
		end
	end
	
	return index
end


function reindexPlaceholders()	
	variables = {}
	
	for _,e in ipairs(guiGetScreenElements()) do
		doOnChildren(e, reindexPlaceholder)
	end
end	

	
function reindexPlaceholder(element)
	if exists(element) and relevant(element) and not getElementData(element, "guieditor:variable") then
		local t = stripGUIPrefix(getElementType(element))
			
		setElementData(element, "guieditor:variablePlaceholder", generateVariable(element))
	end
end


function isDefaultVariable(element, variable)
	if exists(element) then
		local s, e = variable:find("GUIEditor.", 0, true)
		
		-- found, and found at the start of the string
		if s and e and s == 1 then
			variable = variable:sub(e + 1)
			
			local elementType = stripGUIPrefix(getElementType(element))
			
			s, e = variable:find(elementType, 0, true)
			
			if s and e and s == 1 then
				variable = variable:sub(e + 1)
				
				local s, e = variable:find("%[%d+%]", 0)
				
				if s and e and s == 1 then
					return true
				end
			end
		end
	end
	
	return false
end