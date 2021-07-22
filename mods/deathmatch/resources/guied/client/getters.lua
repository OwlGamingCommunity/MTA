--[[--------------------------------------------------
	GUI Editor
	client
	getters.lua
	
	creates getters for all the gui functions that we need by wrapping the setters
--]]--------------------------------------------------


--[[--------------------------------------------------
	colour
--]]--------------------------------------------------
function guiSetColour(element, r, g, b, a)
	if exists(element) then
		local t = stripGUIPrefix(getElementType(element))
		
		if t == "label" then
			guiLabelSetColor(element, r, g, b)
		elseif t == "window" then
			guiSetProperty(element, "CaptionColour", rgbaToHex(r, g, b, a))
		elseif t == "staticimage" then
			local col = rgbaToHex(r, g, b, a)
			
			guiSetProperty(element, "ImageColours", string.format("tl:%s tr:%s bl:%s br:%s", tostring(col), tostring(col), tostring(col), tostring(col)))
		elseif t == "combobox" then
			guiSetProperty(element, "NormalEditTextColour", rgbaToHex(r, g, b, a))
		else
			guiSetProperty(element, "NormalTextColour", rgbaToHex(r, g, b, a))
		end
	end
end
function guiSetColourReverse(r, g, b, a, element)
	if getElementData(element, "guieditor.internal:dxElement") then
		local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
		
		if dx.dxType then
			local action = {}
			action[#action + 1] = {}
			action[#action].ufunc = DX_Element.colour
			action[#action].uvalues = {dx, dx.colour_[1], dx.colour_[2], dx.colour_[3], dx.colour_[4]}
			action[#action].rfunc = DX_Element.colour
			action[#action].rvalues = {dx, r, g, b, a}
			
			action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." colour"
			UndoRedo.add(action)		
		
			dx:colour(r, g, b, a)
		end
		
		return
	end
	
	local action = {}
	action[#action + 1] = {}
	local currentR, currentG, currentB, currentA = guiGetColour(element)
	action[#action].ufunc = guiSetColour
	action[#action].uvalues = {element, currentR, currentG, currentB, currentA}
	action[#action].rfunc = guiSetColour
	action[#action].rvalues = {element, r, g, b, a}
	
	action.description = "Set "..stripGUIPrefix(getElementType(element)).." colour"
	UndoRedo.add(action)
	
	guiSetColour(element, r, g, b, a)
end
function guiSetColourReverseClean(r, g, b, a, element)
	if getElementData(element, "guieditor.internal:dxElement") then
		local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
		
		if dx.dxType then
			dx:colour(r, g, b, a)
		end
		
		return
	end

	guiSetColour(element, r, g, b, a)
end
function guiSetColourClean(element, r, g, b, a)
	guiSetColourReverseClean(r, g, b, a, element)
end

function guiGetColour(element)
	local elementType = stripGUIPrefix(getElementType(element))
	
	if elementType == "button" or
		elementType == "checkbox" or
		elementType == "memo" or
		elementType == "edit" or
		elementType == "radiobutton" then
		
		local a, r, g, b = getColorFromString("#"..guiGetProperty(element, "NormalTextColour"))
		return r, g, b, a
	elseif elementType == "combobox" then
		local a, r, g, b = getColorFromString("#"..guiGetProperty(element, "NormalEditTextColour"))
		return r, g, b, a		
	elseif elementType == "window" then
		local a, r, g, b = getColorFromString("#"..guiGetProperty(element, "CaptionColour"))
		return r, g, b, a
	-- tl:aarrggbb tr:aarrggbb bl:aarrggbb br:aarrggbb
	elseif elementType == "label" then
		local col = guiGetProperty(element, "TextColours"):sub(4, 11)
		
		local a, r, g, b = getColorFromString("#"..col)
		return r, g, b, a
	elseif elementType == "staticimage" then
		local col = guiGetProperty(element, "ImageColours"):sub(4, 11)
		
		local a, r, g, b = getColorFromString("#"..col)
		return r, g, b, a		
	else
		return 0, 0, 0, 255
	end
end


--[[--------------------------------------------------
	read only
--]]--------------------------------------------------
function guiSetReadOnly(element, readOnly, undoable)
	local elementType = stripGUIPrefix(getElementType(element))
	
	if undoable then
		local action = {}
			
		action[#action + 1] = {}
		action[#action].ufunc = guiSetReadOnly
		action[#action].uvalues = {element, guiGetReadOnly(element)}
		action[#action].rfunc = guiSetReadOnly
		action[#action].rvalues = {element, readOnly}
			
		action.description = "Set "..elementType.." ".. (readOnly == true and "read only" or "editable")
		UndoRedo.add(action)		
	end

	setElementData(element, "guieditor:readOnly", readOnly)
	
	if elementType == "memo" then
		guiMemoSetReadOnly(element, readOnly)
	elseif elementType == "edit" then
		guiEditSetReadOnly(element, readOnly)
	end
end


function guiGetReadOnly(element)
	return getElementData(element, "guieditor:readOnly") == true
end



--[[--------------------------------------------------
	windows
--]]--------------------------------------------------
guiWindowSetMovable_ = guiWindowSetMovable
function guiWindowSetMovable(element, movable, undoable)
	if exists(element) then
		if managed(element) then
			setElementData(element, "guieditor:windowMovable", movable)
		end
		
		guiWindowSetMovable_(element, movable)
		
		if undoable then
			local action = {}
		
			action[#action + 1] = {}
			action[#action].ufunc = guiWindowSetMovable
			action[#action].uvalues = {element, not movable}
			action[#action].rfunc = guiWindowSetMovable
			action[#action].rvalues = {element, movable}
		
			action.description = "Set window movable"		
			UndoRedo.add(action)
		end
	end
end

function guiWindowGetMovable(element)
	return getElementData(element, "guieditor:windowMovable") == true
end



guiWindowSetSizable_ = guiWindowSetSizable
function guiWindowSetSizable(element, sizable, undoable)
	if exists(element) then
		if managed(element) then
			setElementData(element, "guieditor:windowSizable", sizable)
		end
		
		guiWindowSetSizable_(element, sizable)
		
		if undoable then
			local action = {}
			
			action[#action + 1] = {}
			action[#action].ufunc = guiWindowSetSizable
			action[#action].uvalues = {element, not sizable}
			action[#action].rfunc = guiWindowSetSizable
			action[#action].rvalues = {element, sizable}
			
			action.description = "Set window sizable"
			UndoRedo.add(action)
		end
	end
end

function guiWindowGetSizable(element)
	return getElementData(element, "guieditor:windowSizable") == true
end



--[[--------------------------------------------------
	label
--]]--------------------------------------------------
function guiLabelSetWordwrap(label, wordwrap, undoable)
	if getElementData(label, "guieditor.internal:dxElement") then
		local dx = DX_Element.getDXFromElement(label)
			
		if dx.dxType then
			if undoable then
				local action = {}
				action[#action + 1] = {}
				action[#action].ufunc = DX_Text.wordwrap
				action[#action].uvalues = {dx, dx.wordwrap_}
				action[#action].rfunc = DX_Text.wordwrap
				action[#action].rvalues = {dx, wordwrap}

				action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." wordwrap"
				UndoRedo.add(action)		
			end
			
			dx:wordwrap(wordwrap)
		end
		
		return
	end


	if undoable then
		local action = {}
			
		action[#action + 1] = {}
		action[#action].ufunc = guiLabelSetWordwrap
		action[#action].uvalues = {label, guiLabelGetWordwrap(label)}
		action[#action].rfunc = guiLabelSetWordwrap
		action[#action].rvalues = {label, wordwrap}
			
		action.description = "Set label wordwrap"
		UndoRedo.add(action)		
	end	

	setElementData(label, "guieditor:wordwrap", wordwrap)
	
	guiLabelSetHorizontalAlign(label, getElementData(label, "guieditor:horizontalAlignment") or "left", wordwrap)
end

function guiLabelGetWordwrap(label)
	if getElementData(label, "guieditor.internal:dxElement") then
		local dx = DX_Element.getDXFromElement(label)

		return dx.wordwrap_
	end

	return getElementData(label, "guieditor:wordwrap") == true
end


guiLabelSetHorizontalAlign_ = guiLabelSetHorizontalAlign
function guiLabelSetHorizontalAlign(label, horz, wordwrap, undoable)
	if undoable then
		if horz ~= guiLabelGetHorizontalAlign(label) then
			local action = {}
				
			action[#action + 1] = {}
			action[#action].ufunc = guiLabelSetHorizontalAlign
			action[#action].uvalues = {label, guiLabelGetHorizontalAlign(label)}
			action[#action].rfunc = guiLabelSetHorizontalAlign
			action[#action].rvalues = {label, horz}
				
			action.description = "Set label h-alignment (" .. tostring(horz) .. ")"
			UndoRedo.add(action)	
		end
	end	

	setElementData(label, "guieditor:horizontalAlignment", horz)
	
	guiLabelSetHorizontalAlign_(label, horz, wordwrap == nil and getElementData(label, "guieditor:wordwrap") or wordwrap)
	
	if wordwrap and not getElementData(label, "guieditor:wordwrap") then
		setElementData(label, "guieditor:wordwrap", true)
	end
end
function guiLabelSetHorizontalAlignFromMenu(label, horz, generateAction)
	local horzString = guiLabelAlignmentIDToString(label, horz, false)
	
	if exists(label) then
		if getElementData(label, "guieditor.internal:dxElement") then
			local dx = DX_Element.getDXFromElement(label)
			
			if dx.dxType then
				if generateAction and dx.alignX_ ~= horzString then
					local action = {}
					action[#action + 1] = {}
					action[#action].ufunc = DX_Text.alignX
					action[#action].uvalues = {dx, dx.alignX_}
					action[#action].rfunc = DX_Text.alignX
					action[#action].rvalues = {dx, horzString}
					
					action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." h-alignment (" .. tostring(horzString) .. ")"
					UndoRedo.add(action)		
				end
				
				dx:alignX(horzString)
			end
			
			return
		end

		guiLabelSetHorizontalAlign(label, horzString, nil, generateAction)
	end
end


function guiLabelGetHorizontalAlign(label)
	if getElementData(label, "guieditor.internal:dxElement") then
		local dx = DX_Element.getDXFromElement(label)
		
		return dx.alignX_ or "left"
	end

	return getElementData(label, "guieditor:horizontalAlignment") or "left"
end


guiLabelSetVerticalAlign_ = guiLabelSetVerticalAlign
function guiLabelSetVerticalAlign(label, vert, undoable)
	if undoable then
		if vert ~= guiLabelGetVerticalAlign(label) then
			local action = {}
				
			action[#action + 1] = {}
			action[#action].ufunc = guiLabelSetVerticalAlign
			action[#action].uvalues = {label, guiLabelGetVerticalAlign(label)}
			action[#action].rfunc = guiLabelSetVerticalAlign
			action[#action].rvalues = {label, vert}
				
			action.description = "Set label v-alignment (" .. tostring(vert) .. ")"
			UndoRedo.add(action)	
		end
	end	

	setElementData(label, "guieditor:verticalAlignment", vert)
	
	guiLabelSetVerticalAlign_(label, vert)
end
function guiLabelSetVerticalAlignFromMenu(label, vert, generateAction)
	local vertString = guiLabelAlignmentIDToString(label, vert, true)

	if exists(label) then
		if getElementData(label, "guieditor.internal:dxElement") then
			local dx = DX_Element.getDXFromElement(label)
			
			if dx.dxType then
				if generateAction and dx.alignY ~= vertString then
					local action = {}
					action[#action + 1] = {}
					action[#action].ufunc = DX_Text.alignY
					action[#action].uvalues = {dx, dx.alignY_}
					action[#action].rfunc = DX_Text.alignY
					action[#action].rvalues = {dx, vertString}
					
					action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." v-alignment (" .. tostring(vertString) .. ")"
					UndoRedo.add(action)		
				end
				
				dx:alignY(vertString)
			end
			
			return
		end

		guiLabelSetVerticalAlign(label, vertString, generateAction)
	end
end

function guiLabelGetVerticalAlign(label)
	if getElementData(label, "guieditor.internal:dxElement") then
		local dx = DX_Element.getDXFromElement(label)
		
		return dx.alignY_ or "top"
	end

	return getElementData(label, "guieditor:verticalAlignment") or "top"
end


function guiLabelAlignmentIDToString(label, id, vertical)
	if vertical then
		if id == "top" or id == "center" or id == "bottom" then
			return id
		elseif id == 1 then
			return "top"
		elseif id == 2 then
			return "center"
		else
			return "bottom"
		end
	else
		if id == "left" or id == "center" or id == "right" then
			return id
		elseif id == 1 then
			return "left"
		elseif id == 2 then
			return "center"
		else
			return "right"
		end
	end
	
	return ""
end


--[[--------------------------------------------------
	edit
--]]--------------------------------------------------
guiEditSetMasked_ = guiEditSetMasked
function guiEditSetMasked(element, masked, undoable)
	if undoable then
		local action = {}
				
		action[#action + 1] = {}
		action[#action].ufunc = guiEditSetMasked
		action[#action].uvalues = {element, guiEditGetMasked(element)}
		action[#action].rfunc = guiEditSetMasked
		action[#action].rvalues = {element, masked}
				
		action.description = "Set edit "..(masked and "" or "un").."masked"
		UndoRedo.add(action)	
	end	

	setElementData(element, "guieditor:masked", masked)
	
	guiEditSetMasked_(element, masked)	
end

function guiEditGetMasked(element)
	return getElementData(element, "guieditor:masked") == true
end


guiEditSetMaxLength_ = guiEditSetMaxLength
function guiEditSetMaxLength(element, length, undoable)
	if length == "" then
		length = 0
	end
	
	if undoable then
		local action = {}
				
		action[#action + 1] = {}
		action[#action].ufunc = guiEditSetMaxLength
		action[#action].uvalues = {element, guiEditGetMaxLength(element)}
		action[#action].rfunc = guiEditSetMaxLength
		action[#action].rvalues = {element, length}
				
		action.description = "Set edit max length "..tostring(length)
		UndoRedo.add(action)	
	end	

	setElementData(element, "guieditor:maxLength", length)
	
	guiEditSetMaxLength_(element, length)	
end

function guiEditGetMaxLength(element)
	return getElementData(element, "guieditor:maxLength")
end


--[[--------------------------------------------------
	combo box
--]]--------------------------------------------------
guiComboBoxGetItemText_ = guiComboBoxGetItemText
function guiComboBoxGetItemText(element, item)
	if exists(element) and tonumber(item) and item ~= -1 then
		local oldItem = guiComboBoxGetSelected(element)
		guiComboBoxSetSelected(element, item)
		local text = guiGetProperty(element, "Text")
		guiComboBoxSetSelected(element, oldItem)
		
		return text
	end
end


function guiComboBoxGetItemCount(element)
	if exists(element) then
		local i = 0
		local item = guiComboBoxGetSelected(element)
		
		while guiComboBoxSetSelected(element, i) and i < 500 do
			i = i + 1
		end
		
		if item and item ~= -1 then
			guiComboBoxSetSelected(element, item)
		else
			guiComboBoxSetSelected(element, -1)
		end
		
		return i
	end
	
	return 0
end