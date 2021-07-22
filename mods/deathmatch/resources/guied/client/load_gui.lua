--[[--------------------------------------------------
	GUI Editor
	client
	load_gui.lua
	
	manages copying, creating and loading given gui elements
--]]--------------------------------------------------


local blockedProperties = {
	["TabTextPadding"] = true, 
	["RelativeTabTextPadding"] = true,
	--["WindowRenderer"] = true,
	["BottomRightFrameImage"] = true,
	["TopLeftFrameImage"] = true,
	["LeftFrameImage"] = true,
	["BottomLeftFrameImage"] = true,
	["BackgroundImage"] = true,
	["BottomFrameImage"] = true,
	["RightFrameImage"] = true,
	["TopRightFrameImage"] = true,
	["TopFrameImage"] = true,
	["MouseCursorImage"] = true,
	["Image"] = true,
	["NESWSizingCursorImage"] = true,
	["NSSizingCursorImage"] = true,
	["NWSESizingCursorImage"] = true,
	["EWSizingCursorImage"] = true,
	["HoverImage"] = true,
	["NormalImage"] = true,
	["PushedImage"] = true,
	[""] = true,
}

function setupGUIElement(element, ...)
	if not exists(element) then
		outputDebug("Invalid element in setupGUIElement", "GENERAL")
		return
	end
	
	if getElementData(element, "guieditor.internal:noLoad") then
		return
	end

	local args = {...}
	
	if guiNeedsBorder(element) then
		setElementData(element, "guieditor:border", true)
	end
	
	local elementType = stripGUIPrefix(getElementType(element))
	elementType = string.lower(tostring(elementType) or "")	
	
	setElementData(element, "guieditor:relative", false)
	setElementData(element, "guieditor:managed", true)	
	
	if elementType == "window" then
		-- set the window to movable (because this is the default state for user made windows)
		-- but then set the window actually not movable, skipping the element data (because we want people to move using the right click menu)
		guiWindowSetMovable(element, true)
		guiWindowSetMovable_(element, false)
		guiWindowSetSizable(element, false)
	elseif elementType == "button" then
	elseif elementType == "memo" then
	elseif elementType == "label" then
		if string.lower(guiGetProperty(element, "HorizontalAlignment")) ~= guiLabelGetHorizontalAlign(element) then
			guiLabelSetHorizontalAlign(element, string.lower(guiGetProperty(element, "HorizontalAlignment")))
		end
		
		-- this property seems to always be "Top" regardless of the actual alignment
		--if string.lower(guiGetProperty(element, "VerticalAlignment")) ~= guiLabelGetVerticalAlign(element) then
		--	guiLabelSetVerticalAlign(element, string.lower(guiGetProperty(element, "VerticalAlignment")))
		--end
		
		if guiGetProperty(element, "VerticalAlignment") == "TopAligned" and guiLabelGetVerticalAlign(element) ~= "top" then
			guiLabelSetVerticalAlign(element, "top")
		elseif guiGetProperty(element, "VerticalAlignment") == "VertCentred" and guiLabelGetVerticalAlign(element) ~= "center" then
			guiLabelSetVerticalAlign(element, "center")
		elseif guiGetProperty(element, "VerticalAlignment") == "BottomAligned" and guiLabelGetVerticalAlign(element) ~= "bottom" then
			guiLabelSetVerticalAlign(element, "bottom")
		end
		
		if not guiLabelGetWordwrap(element) and guiGetProperty(element, "HorzFormatting"):find("WordWrap") then
			local val = guiGetProperty(element, "HorzFormatting")
			
			guiLabelSetWordwrap(element, true)

			if val == "WordWrapCentred" then
				guiLabelSetHorizontalAlign(element, "center")
			elseif val == "WordWrapLeftAligned" then
				guiLabelSetHorizontalAlign(element, "left")
			elseif val == "WordWrapRightAligned" then
				guiLabelSetHorizontalAlign(element, "right")
			end
		end
	elseif elementType == "checkbox" then
	elseif elementType == "edit" then
		guiEditSetMaxLength(element, 65535)
	elseif elementType == "progressbar" then
	elseif elementType == "radiobutton" then
	elseif elementType == "gridlist" then
		guiGridListSetSelectionMode(element, 2)
	elseif elementType == "tabpanel" then
		if getElementData(element, "guieditor.internal:needsTab") then
			-- tabpanels without any tabs on do not capture any mouse events
			-- so we have to put a tab on when we create the tab panel
			-- 19/07/14 - that is now actually fixed, but mta now forces tabs onto empty tabpanels (very inconsistently..?)
			-- so set one up ourselves to stop it having a silly tab name
			local tab = createGUIElementFromType("tab", nil, nil, nil, nil, nil, element)
			setupGUIElement(tab)
		end
	elseif elementType == "tab" then
		--guiSetProperty(guiGetParent(element), "TabTextPadding", 0.07)
	elseif elementType == "staticimage" then
		if not getElementData(element, "guieditor:imagePath") then
			local path = "images/examples/mtalogo.png"
			guiStaticImageLoadImage(element, path)
			setElementData(element, "guieditor:imagePath", path)
			local w, h = getImageSize(path)
			setElementData(element, "guieditor:imageSize", {width = w, height = h})
		end
	elseif elementType == "scrollbar" then
		local redirect = guiCreateLabel(0, 0, 1, 1, "", true, element)
		guiSetProperty(redirect, "MousePassThroughEnabled", "True")
		gRightClickHack[redirect] = true		
		setElementData(element, "guieditor.internal:mask", redirect)
		setElementData(redirect, "guieditor.internal:redirect", element)	
		setElementData(redirect, "guieditor.internal:noLoad", true)	
	elseif elementType == "scrollpane" then	
		local redirect = guiCreateLabel(0, 0, 1, 1, "", true, element)
		setElementData(element, "guieditor.internal:mask", redirect)
		setElementData(redirect, "guieditor.internal:redirect", element)
		setElementData(redirect, "guieditor.internal:noLoad", true)		
	elseif elementType == "combobox" then
		--[[
		local redirect = guiCreateLabel(0, 0, 1, 1, "", true, element)
		guiSetProperty(redirect, "MousePassThroughEnabled", "True")
		gRightClickHack[redirect] = true
		setElementData(element, "guieditor.internal:mask", redirect)
		setElementData(redirect, "guieditor.internal:redirect", element)	
		setElementData(redirect, "guieditor.internal:noLoad", true)
		]]
	elseif elementType == "dx_line" then
		guiSetProperty(element, "MousePassThroughEnabled", "True")
	elseif elementType == "dx_rectangle" then
		guiSetProperty(element, "MousePassThroughEnabled", "True")
	elseif elementType == "dx_image" then
		guiSetProperty(element, "MousePassThroughEnabled", "True")
	elseif elementType == "dx_text" then
		guiSetProperty(element, "MousePassThroughEnabled", "True")
	end
	
	setElementVariable(element)	
	
	cacheProperties(element)
end


function cacheProperties(element)
	local elementType = getElementType(element)
	
	--if gDefaults.properties[elementType] then
	--	return
	--end
	
	if not Properties.data.widgets or not Properties.data.widgets[Properties.guiMap[elementType]] then
		return
	end

	if not gDefaults.properties[elementType] then
		gDefaults.properties[elementType] = {}
	end
	
	if elementType ~= "gui-gridlist" then
		for name,value in pairs(guiGetProperties(element)) do
			if gDefaults.properties[elementType][name] == nil then
				gDefaults.properties[elementType][name] = value
			end
		end
	end
	
	if Properties.data.widgets and Properties.data.widgets[Properties.guiMap[elementType]] then
		for i,name in ipairs(Properties.data.widgets[Properties.guiMap[elementType]]) do
			if gDefaults.properties[elementType][name] == nil then
				gDefaults.properties[elementType][name] = guiGetProperty(element, name)
			end
		end	
	end
end


function loadGUIElement(element, ignoreChildren)
	if not ignoreChildren then
		doOnChildren(element, setupGUIElement)
	else
		setupGUIElement(element)
	end
end


function createGUIElementFromType(elementType, x, y, w, h, relative, parent, ...)
	local element
	local args = {...}
	
	if elementType == "window" then
		element = guiCreateWindow(x, y, w, h, "", false, parent)		
	elseif elementType == "button" then
		element = guiCreateButton(x, y, w, h, "", false, parent)
	elseif elementType == "memo" then
		element = guiCreateMemo(x, y, w, h, "", false, parent)
	elseif elementType == "label" then
		element = guiCreateLabel(x, y, w, h, "", false, parent)
	elseif elementType == "checkbox" then
		element = guiCreateCheckBox(x, y, w, h, "", false, false, parent)
	elseif elementType == "edit" then
		element = guiCreateEdit(x, y, w, h, "", false, parent)
	elseif elementType == "progressbar" then
		element = guiCreateProgressBar(x, y, w, h, false, parent)
	elseif elementType == "radiobutton" then
		element = guiCreateRadioButton(x, y, w, h, "", false, parent)
	elseif elementType == "gridlist" then
		element = guiCreateGridList(x, y, w, h, false, parent)
	elseif elementType == "tabpanel" then
		element = guiCreateTabPanel(x, y, w, h, false, parent)
		
		if args[1] then
			setElementData(element, "guieditor.internal:needsTab", true)
		end
	elseif elementType == "tab" then
		element = guiCreateTab(args[1] or "Tab", parent)
	elseif elementType == "staticimage" then
		element = guiCreateStaticImage(x, y, w, h, args[1], false, parent)
		setElementData(element, "guieditor:imagePath", args[1])
		setElementData(element, "guieditor:imageSize", args[2])
	elseif elementType == "scrollbar" then
		element = guiCreateScrollBar(x, y, w, h, args[1] == true, false, parent)
	elseif elementType == "scrollpane" then
		element = guiCreateScrollPane(x, y, w, h, false, parent)	
	elseif elementType == "combobox" then
		element = guiCreateComboBox(x, y, w, h, "", false, parent)
		
	elseif elementType == "dx_line" then
		element = guiCreateLabel(x, y, w, h, "", false, parent)
		guiSetProperty(element, "MousePassThroughEnabled", "True")
		local dx = DX_Line:create(x, y, x + w, y + h, {255, 255, 255, 255}, 1, false, element)
		setElementData(element, "guieditor.internal:dxElement", dx.id)
	elseif elementType == "dx_rectangle" then
		element = guiCreateLabel(x, y, w, h, "", false, parent)
		guiSetProperty(element, "MousePassThroughEnabled", "True")
		local dx = DX_Rectangle:create(x, y, w, h, {255, 255, 255, 255}, false, element)
		setElementData(element, "guieditor.internal:dxElement", dx.id)
	elseif elementType == "dx_image" then
		element = guiCreateLabel(x, y, w, h, "", false, parent)
		guiSetProperty(element, "MousePassThroughEnabled", "True")
		local dx = DX_Image:create(x, y, w, h, args[1], 0, 0, 0, {255, 255, 255, 255}, false, element)
		setElementData(element, "guieditor.internal:dxElement", dx.id)
		setElementData(element, "guieditor:imagePath", args[1])
		setElementData(element, "guieditor:imageSize", args[2])
	elseif elementType == "dx_text" then
		element = guiCreateLabel(x, y, w, h, "", false, parent)
		guiSetProperty(element, "MousePassThroughEnabled", "True")
		local dx = DX_Text:create("", x, y, w, h, {255, 255, 255, 255}, 1, "default", "left", "top", false, false, false, false, false, element)
		setElementData(element, "guieditor.internal:dxElement", dx.id)
	end
	
	return element
end


function copyGUIElement(element, silent, parent, ...)
	local elementType = stripGUIPrefix(getElementType(element))
	elementType = string.lower(tostring(elementType) or "")
	
	local args = {...}
	
	local x, y = guiGetPosition(element, false)
	local w, h = guiGetSize(element, false)
	parent = parent or guiGetParent(element)
	
	if exists(parent) and getElementType(parent) == "guiroot" then
		parent = nil
	end
	
	local creationArgs = {}
	
	if elementType == "staticimage" then
		creationArgs = {getElementData(element, "guieditor:imagePath"), getElementData(element, "guieditor:imageSize")}
	elseif elementType == "scrollbar" then
		creationArgs = {not toBool(guiGetProperty(element, "VerticalScrollbar"))}
	end
	
	local copy = createGUIElementFromType(elementType, x, y, w, h, false, parent, unpack(creationArgs))
	
	-- copy all guieditor element data
	for data,_ in pairs(gDataNames) do
		if data ~= "guieditor:variable" and data ~= "guieditor:variablePlaceholder" then
			if getElementData(element, data) ~= nil then
				setElementData(copy, data, getElementData(element, data))
			end
		end
	end
	
	setupGUIElement(copy, unpack(creationArgs))
	
	setElementData(copy, "guieditor:relative", getElementData(element, "guieditor:relative"))
	
	-- calling guiGetProperties on a gridlist crashes mta
	if elementType ~= "gridlist" then
		for name,value in pairs(guiGetProperties(element)) do
			if not blockedProperties[name] then
				--guiSetProperty(copy, name, value)
			end
		end	
	end	
	
	guiSetAlpha(copy, guiGetAlpha(element))
	guiSetText(copy, guiGetText(element))
	guiSetFont(copy, guiGetFont(element))
	
	if hasColour(element) then
		guiSetColour(copy, guiGetColour(element))
	end
	
	
	
	if getElementData(element, "guieditor:positionCode") then
		setElementData(copy, "guieditor:positionCode", getElementData(element, "guieditor:positionCode"))
	end
	
	if elementType == "window" then
		if getElementData(element, "guieditor:windowMovable") ~= nil then
			guiWindowSetMovable(copy, getElementData(element, "guieditor:windowMovable"))
			
			if guiWindowGetMovable(copy) then
				guiWindowSetMovable_(copy, false)
			end
		end
		
		if getElementData(element, "guieditor:windowSizable") ~= nil then
			guiWindowSetSizable(copy, getElementData(element, "guieditor:windowSizable"))
		end		
	elseif elementType == "button" then
	
	elseif elementType == "memo" then
		guiSetReadOnly(copy, guiGetReadOnly(element))
	elseif elementType == "label" then	
		guiLabelSetWordwrap(copy, guiLabelGetWordwrap(element))
		guiLabelSetHorizontalAlign(copy, guiLabelGetHorizontalAlign(element))
		guiLabelSetVerticalAlign(copy, guiLabelGetVerticalAlign(element))
	elseif elementType == "checkbox" then
		guiCheckBoxSetSelected(copy, guiCheckBoxGetSelected(element))
	elseif elementType == "edit" then
		guiEditSetMaxLength(copy, guiEditGetMaxLength(element))
		guiEditSetMasked(copy, guiEditGetMasked(element))
		guiSetReadOnly(copy, guiGetReadOnly(element))
	elseif elementType == "progressbar" then
		guiProgressBarSetProgress(copy, guiProgressBarGetProgress(element))
	elseif elementType == "radiobutton" then
		guiRadioButtonSetSelected(copy, guiRadioButtonGetSelected(element))
	elseif elementType == "gridlist" then
		if guiGridListGetColumnCount(element) > 0 then
			for i = 1, guiGridListGetColumnCount(element) do
				local title = getElementData(element, "guieditor:gridlistColumnTitle."..tostring(i))
				
				guiGridListAddColumn(copy, title or " ", 0)
				
				guiGridListSetColumnWidth(copy, i, 0.95 / guiGridListGetColumnCount(element), true)
			end		
		end
		
		if guiGridListGetRowCount(element) > 0 then
			for k = 1, guiGridListGetRowCount(element) do
				local row = guiGridListAddRow(copy)

				for i = 1, guiGridListGetColumnCount(element) do
					if guiGridListGetItemText(element, row, i) == "" then
						guiGridListSetItemText(copy, row, i, "-", false, false)
					else
						guiGridListSetItemText(copy, row, i, guiGridListGetItemText(element, row, i), false, false)
					end
					
					local r,g,b,a = guiGridListGetItemColor(element, row, i)
					
					if r and g and b then
						guiGridListSetItemColor(copy, row, i, r, g, b, a or 255)
					end
				end
			end		
		end
	elseif elementType == "tabpanel" then
		if not args[1] then
			for i,tab in ipairs(getElementChildren(element)) do
				copyGUIElement(tab, true, copy)
			end	
		end
	elseif elementType == "tab" then	
	elseif elementType == "staticimage" then
	elseif elementType == "scrollbar" then
		guiScrollBarSetScrollPosition(copy, guiScrollBarGetScrollPosition(element))
	elseif elementType == "scrollpane" then
	elseif elementType == "combobox" then
		local i = 0
		local item = guiComboBoxGetSelected(element)
		
		while guiComboBoxSetSelected(element, i) and i < 500 do
			guiComboBoxAddItem(copy, tostring(guiComboBoxGetItemText(element, i)))
			
			i = i + 1
		end
		
		if item and item ~= -1 then
			guiComboBoxSetSelected(copy, item)
			guiComboBoxSetSelected(element, item)
		else
			guiComboBoxSetSelected(element, -1)
		end
	end
	
	
	if getElementData(element, "guieditor.internal:dxElement") then
		local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
							
		if dx.dxType == gDXTypes.line then
			local dx_ = DX_Line:create(dx.startX, dx.startY, dx.endX, dx.endY, dx.colour_, dx.width, dx.postGUI_, copy)
			dx_.anchor = dx.anchor
			dx_.shadow_ = dx.shadow_
			dx_.outline_ = dx.outline_
			setElementData(copy, "guieditor.internal:dxElement", dx_.id)
		elseif dx.dxType == gDXTypes.rectangle then
			local dx_ = DX_Rectangle:create(dx.x, dx.y, dx.width, dx.height, dx.colour_, dx.postGUI_, copy)
			dx_.shadow_ = dx.shadow_
			dx_.outline_ = dx.outline_
			setElementData(copy, "guieditor.internal:dxElement", dx_.id)
		elseif dx.dxType == gDXTypes.image then
			local dx_ = DX_Image:create(dx.x, dx.y, dx.width, dx.height, dx.filepath, dx.rotation_, dx.rOffsetX_, dx.rOffsetY_, dx.colour_, dx.postGUI_, copy)
			setElementData(copy, "guieditor.internal:dxElement", dx_.id)
		elseif dx.dxType == gDXTypes.text then
			local dx_ = DX_Text:create(dx.text_, dx.x, dx.y, dx.width, dx.height, dx.colour_, dx.scale_, dx.font_, dx.alignX_, dx.alignY_, dx.clip_, dx.wordwrap_, dx.postGUI_, dx.colourCoded_, dx.subPixelPositioning, copy)
			setElementData(copy, "guieditor.internal:dxElement", dx_.id)			
		end
		
		guiSetProperty(copy, "MousePassThroughEnabled", "True")
	end
	
	
	if not silent then
		ContextBar.add("A copy of the "..elementType.." has been made on top of the original")
		
		local action = {}
		action[#action + 1] = {}
		action[#action] = {ufunc = guiRemove, uvalues = {copy}, rfunc = guiRestore, rvalues = {copy}, __destruct = {rfunc = guiDelete, rvalues = {copy}}}
		
		action.description = "Copy " .. stripGUIPrefix(getElementType(copy))
		
		UndoRedo.add(action)
		
		Mover.add(copy)
	end
	
	return copy
end


function copyGUIElementChildren(element, silent)
	if exists(element) then
		local copy = copyGUIElementChild(element)
		
		if not silent then
			local elementType = stripGUIPrefix(getElementType(element))
			
			ContextBar.add("A copy of the "..elementType.." has been made on top of the original")
			
			local action = {}
			action[#action + 1] = {}
			action[#action] = {ufunc = guiRemove, uvalues = {copy}, rfunc = guiRestore, rvalues = {copy}, __destruct = {rfunc = guiDelete, rvalues = {copy}}}
			
			action.description = "Copy " .. stripGUIPrefix(getElementType(copy))
			
			UndoRedo.add(action)			
		end		
		
		return copy
	end
end


function copyGUIElementChild(element, parent)
	local c = copyGUIElement(element, true, parent, true)

	for _,e in ipairs(getElementChildren(element)) do
		copyGUIElementChild(e, c)
	end
	
	return c
end	