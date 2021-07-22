--[[--------------------------------------------------
	GUI Editor
	client
	coder.lua
	
	a window that allows users to enter basic code to compute the position of an element
	eg: '(screenW - width) / 2' - this will center the element on the screen (horizontally)
	
	These positions will affect both in-editor positions and editor output code
--]]--------------------------------------------------

PositionCoder = {
	height = 195,
	width = 425,
	loaded = false,
	
	source = nil,
	presets = {
		{x = "(parentW - width) / 2", y = "(parentH - height) / 2", description = "Center - centers the element within its parent (or the screen)"},
		{x = "parentW - width - 10", y = "(parentH - height) / 2", description = "Snap right - snaps to the right side of the parent (or the screen)"},
		{x = "10", y = "(parentH - height) / 2", description = "Snap left - snaps to the left side of the parent (or the screen)"},
	},
	
	testString = "guiSetPosition(element, %s, %s, false)",
}


function PositionCoder.create()
	PositionCoder.gui = {}
	
	PositionCoder.gui.wndMain = guiCreateWindow((gScreen.x - PositionCoder.width) / 2, (gScreen.y - PositionCoder.height) / 2, PositionCoder.width, PositionCoder.height, "Position Coder", false)	
	guiWindowSetSizable(PositionCoder.gui.wndMain, false)

	PositionCoder.gui.lblDesc = guiCreateLabel(10, 25, PositionCoder.width - 20, 15, "Enter the code that will manage the position of the element:", false, PositionCoder.gui.wndMain)
	guiLabelSetHorizontalAlign(PositionCoder.gui.lblDesc, "center", false)
	
	PositionCoder.gui.edtPositionX = guiCreateEdit(10, 50, PositionCoder.width - 20, 25, "x = ", false, PositionCoder.gui.wndMain)
	PositionCoder.gui.edtPositionY = guiCreateEdit(10, 85, PositionCoder.width - 20, 25, "y = ", false, PositionCoder.gui.wndMain)
	setElementData(PositionCoder.gui.edtPositionX, "guieditor:previousText", "x = ")
	setElementData(PositionCoder.gui.edtPositionY, "guieditor:previousText", "y = ")
	PositionCoder.gui.lblResult = guiCreateLabel(15, 120, PositionCoder.width - 30, 30, "Test Result: -", false, PositionCoder.gui.wndMain)

	PositionCoder.gui.btnDone = guiCreateButton(PositionCoder.width - 60, 155, 50, 30, "Done", false, PositionCoder.gui.wndMain)
	
	PositionCoder.gui.lblVariables = guiCreateLabel(10, 150, PositionCoder.width - 80, 40, "Preset Variables:\n  'parentW' and 'parentH' represent the element parent size (or screen size)\n  'width' and 'height' represent the elements dimensions", false, PositionCoder.gui.wndMain)
	guiSetFont(PositionCoder.gui.lblVariables, "default-small")

	PositionCoder.gui.lblPresets = guiCreateLabel(50, 200, PositionCoder.width - 100, 15, "Presets:", false, PositionCoder.gui.wndMain)
	guiLabelSetHorizontalAlign(PositionCoder.gui.lblPresets, "center", false)
	

	PositionCoder.gui.scroller = guiCreateScrollPane(10, 225, PositionCoder.width - 20, 45, false, PositionCoder.gui.wndMain)
	guiSetProperty(PositionCoder.gui.scroller, "ClippedByParent", "False")
	
	PositionCoder.gui.presets = {}
	
	PositionCoder.gui.btnAddPreset = guiCreateButton(PositionCoder.width - 100, 200, 90, 20, "Add as preset", false, PositionCoder.gui.wndMain)
	guiSetEnabled(PositionCoder.gui.btnAddPreset, false)
	
	addEventHandler("onClientGUIClick", PositionCoder.gui.btnAddPreset,
		function(button, state)
			if button == "left" and state == "up" then
				PositionCoder.addPreset()
			end
		end
	, false)

	addEventHandler("onClientGUIChanged", PositionCoder.gui.edtPositionX,
		function()
			local text = guiGetText(source)

			if text:sub(1, 4) ~= "x = " then
				if text == "" then
					guiSetText(source, "x = ")
				else
					guiSetText(source, getElementData(source, "guieditor:previousText"))
				end
			else
				setElementData(source, "guieditor:previousText", text)
			end
			
			PositionCoder.runTest()
		end
	, false)
	
	
	addEventHandler("onClientGUIChanged", PositionCoder.gui.edtPositionY,
		function()
			local text = guiGetText(source)

			if text:sub(1, 4) ~= "y = " then
				if text == "" then
					guiSetText(source, "y = ")
				else
					guiSetText(source, getElementData(source, "guieditor:previousText"))
				end
			else
				setElementData(source, "guieditor:previousText", text)
			end
			
			PositionCoder.runTest()
		end
	, false)	
	
	addEventHandler("onClientGUIClick", PositionCoder.gui.btnDone, PositionCoder.done, false)
	
	
	guiWindowTitlebarButtonAdd(PositionCoder.gui.wndMain, "Run Test", "left", 
		function()
			PositionCoder.runTest()
		end
	)
	
	guiWindowTitlebarButtonAdd(PositionCoder.gui.wndMain, "Presets", "left", PositionCoder.togglePresets)
	--guiWindowTitlebarButtonAdd(PositionCoder.gui.wndMain, "blah3", "left")
	
	guiWindowTitlebarButtonAdd(PositionCoder.gui.wndMain, "Close", "right", PositionCoder.close)
	
	doOnChildren(PositionCoder.gui.wndMain, setElementData, "guieditor.internal:noLoad", true)
end


function PositionCoder.togglePresets() 
	local w, h = guiGetSize(PositionCoder.gui.wndMain, false)
	
	-- collapse
	if h > 200 then
		guiSetSize(PositionCoder.gui.wndMain, w, 195, false)
		destroyElement(PositionCoder.gui.imgDividerLeft)
		destroyElement(PositionCoder.gui.imgDividerRight)
		
		PositionCoder.destroyPresets()		
	-- expand
	else
		guiSetSize(PositionCoder.gui.wndMain, w, 285, false)
		guiSetSize(PositionCoder.gui.scroller, w - 20, 50, false)
		guiSetSize(PositionCoder.gui.btnAddPreset, 90, 20, false)
		PositionCoder.gui.imgDividerLeft, PositionCoder.gui.imgDividerRight = divider(PositionCoder.gui.wndMain, 20, 195, w - 40)
		PositionCoder.loadPresets()
	end
end

function PositionCoder.open(element, presetToLoad)
	if not PositionCoder.gui then
		PositionCoder.create(presetToLoad)
		
		PositionCoder.loadFile()
	end
	
	local action = {}
	action[#action + 1] = {}
	action[#action].ufunc = guiSetPosition
	local x,y = guiGetPosition(element, false)
	action[#action].uvalues = {element, x, y, false}	
	
	action[#action + 1] = {}
	action[#action].ufunc = setElementData
	action[#action].uvalues = {element, "guieditor:positionCode", nil}

	action[#action + 1] = {}
	action[#action].ufunc = setElementData
	action[#action].uvalues = {element, "guieditor:relative", getElementData(element, "guieditor:relative")}		
	
	setElementData(element, "guieditor.internal:actionPositionCode", action)
	
	if getElementData(element, "guieditor:positionCode") then
		local p = split(getElementData(element, "guieditor:positionCode"), ",")
		
		guiSetText(PositionCoder.gui.edtPositionX, "x = " .. p[1])
		guiSetText(PositionCoder.gui.edtPositionY, "y =" .. p[2])		
	else
		guiSetText(PositionCoder.gui.edtPositionX, "x = ")
		guiSetText(PositionCoder.gui.edtPositionY, "y = ")
	end
	
	guiSetText(PositionCoder.gui.lblResult, "Test Result: -")
	
	PositionCoder.testString = "guiSetPosition(element, %s, %s, false)"

	PositionCoder.source = element
	
	guiSetVisible(PositionCoder.gui.wndMain, true)
	guiBringToFront(PositionCoder.gui.wndMain)
	
					
	if presetToLoad then
		presetToLoad = tonumber(presetToLoad)
		
		if presetToLoad and presetToLoad <= #PositionCoder.presets then
			PositionCoder.togglePresets()
			
			triggerEvent("onClientGUIClick", PositionCoder.gui.presets[presetToLoad].preset)
			
			PositionCoder.done()
		end
	end
end


function PositionCoder.close()
	guiSetVisible(PositionCoder.gui.wndMain, false)
	
	local w = guiGetSize(PositionCoder.gui.wndMain, false)
	guiSetSize(PositionCoder.gui.wndMain, w, 195, false)
	
	if exists(PositionCoder.gui.imgDivider) then
		destroyElement(PositionCoder.gui.imgDivider)
	end
	
	PositionCoder.destroyPresets()		
	
	if PositionCoder.source and exists(PositionCoder.source) then
		local action = getElementData(PositionCoder.source, "guieditor.internal:actionPositionCode")
		if action then
			action[#action + 1] = {}
			action[#action].rfunc = guiSetPosition
			local x,y = guiGetPosition(PositionCoder.source, false)
			action[#action].rvalues = {PositionCoder.source, x, y, false}	

			action[#action + 1] = {}
			action[#action].rfunc = setElementData
			action[#action].rvalues = {PositionCoder.source, "guieditor:positionCode", getElementData(PositionCoder.source, "guieditor:positionCode")}

			action[#action + 1] = {}
			action[#action].rfunc = setElementData
			action[#action].rvalues = {PositionCoder.source, "guieditor:relative", getElementData(PositionCoder.source, "guieditor:relative")}		

			action.description = "Position code"
			
			UndoRedo.add(action)
			
			setElementData(PositionCoder.source, "guieditor.internal:actionPositionCode", nil)
		end
	end
	
	PositionCoder.source = nil
end


function PositionCoder.done(button, state)
	if (not button and not state) or (type(button) == "gui-button") or (button == "left" and state == "up") then
		button = exists(button) and button or source
		
		local x, y = PositionCoder.getOutput()
		
		local sX, sY = PositionCoder.formatOutput(PositionCoder.source, x, y)
		
		local resultX, errorX = PositionCoder.runOutput(sX)
		local resultY, errorY = PositionCoder.runOutput(sY)
		
		outputDebug(string.format("Result x: %s, %s", resultX, errorX or ""), "POSITION_CODER")
		outputDebug(string.format("Result y: %s, %s", resultY, errorY or ""), "POSITION_CODER")
		
		if ((not errorX) or (errorX == "")) and ((not errorY) or (errorY == "")) then
			PositionCoder.setPositionCode(PositionCoder.source, x, y, resultX, resultY)
		--[[
			if PositionCoder.source and exists(PositionCoder.source) then
				guiSetPosition(PositionCoder.source, resultX, resultY, false)
				setElementData(PositionCoder.source, "guieditor:positionCode", x .. ", " .. y)
				setElementData(PositionCoder.source, "guieditor:relative", false)
			elseif PositionCoder.source and type(PositionCoder.source) == "table" and PositionCoder.source.dxType then
				if PositionCoder.source.dxType == gDXTypes.line then
					PositionCoder.source.startX = PositionCoder.source.startX + (resultX - PositionCoder.source.startX)
					PositionCoder.source.startY = PositionCoder.source.startY + (resultY - PositionCoder.source.startY)
					PositionCoder.source.endX = PositionCoder.source.endX + (resultX - PositionCoder.source.endX)
					PositionCoder.source.endY = PositionCoder.source.endY + (resultY - PositionCoder.source.endY)
				elseif PositionCoder.source.dxType == gDXTypes.rectangle or PositionCoder.source.dxType == gDXTypes.image or PositionCoder.source.dxType == gDXTypes.text then
					PositionCoder.source.x = PositionCoder.source.x + (resultX - PositionCoder.source.x)
					PositionCoder.source.y = PositionCoder.source.y + (resultY - PositionCoder.source.y)			
				end
				
				local x, y = guiGetPosition(PositionCoder.source.element, false)
				guiSetPosition(PositionCoder.source.element, x + (resultX - x), y + (resultY - y), false)
			end]]
		else
			guiSetText(PositionCoder.gui.btnDone, "Error")
			return
		end
	end
	
	PositionCoder.close()
end


function PositionCoder.setPositionCode(element, x, y, posX, posY)
	if element and exists(element) then
		guiSetPosition(element, posX, posY, false)
		setElementData(element, "guieditor:positionCode", x .. ", " .. y)
		setElementData(element, "guieditor:relative", false)
	elseif element and type(element) == "table" and element.dxType then
		if element.dxType == gDXTypes.line then
			element.startX = element.startX + (posX - element.startX)
			element.startY = element.startY + (posY - element.startY)
			element.endX = element.endX + (posX - element.endX)
			element.endY = element.endY + (posY - element.endY)
		elseif element.dxType == gDXTypes.rectangle or element.dxType == gDXTypes.image or element.dxType == gDXTypes.text then
			element.x = element.x + (posX - element.x)
			element.y = element.y + (posY - element.y)			
		end
				
		local x, y = guiGetPosition(element.element, false)
		guiSetPosition(element.element, x + (posX - x), y + (posY - y), false)
	end
end


function PositionCoder.runTest()
	--if not PositionCoder.source then
	--	return
	--end
	
	local x, y = PositionCoder.getOutput()		
	local sX, sY = PositionCoder.formatOutput(PositionCoder.source, x, y)
			
	local resultX, errorX = PositionCoder.runOutput(sX)
	local resultY, errorY = PositionCoder.runOutput(sY)
			
	if ((not errorX) or (errorX == "")) and ((not errorY) or (errorY == "")) and (x ~= "" and y ~= "") then			
		guiSetText(PositionCoder.gui.btnDone, "Done")
		guiSetEnabled(PositionCoder.gui.btnAddPreset, true)
		guiSetColour(PositionCoder.gui.lblResult, unpack(gColours.defaultLabel))
	else
		guiSetText(PositionCoder.gui.btnDone, "Error")
		guiSetEnabled(PositionCoder.gui.btnAddPreset, false)
		guiSetColour(PositionCoder.gui.lblResult, unpack(gColours.primary))
	end
			
	guiSetText(PositionCoder.gui.lblResult, string.format("Test Result: " .. PositionCoder.testString, resultX, resultY))
end


function PositionCoder.getOutput()
	local x = guiGetText(PositionCoder.gui.edtPositionX):sub(5)
	local y = guiGetText(PositionCoder.gui.edtPositionY):sub(5)

	outputDebug(string.format("Output: x: %s, y: %s", x, y), "POSITION_CODER")

	return x, y	
end


function PositionCoder.formatOutput(element, x, y, parentW, parentH)
	local w, h = 0, 0
	local pW, pH = -1, -1
	
	if exists(element) then
		w, h = guiGetSize(element, false)
		
		if guiGetParent(element) then
			pW, pH = guiGetSize(guiGetParent(element), false)
		end
	end
	
	pW = parentW or pW
	pH = parentH or pH
	
	return string.format("local parentW, parentH = %s, %s; if parentW == -1 then parentW, parentH = guiGetScreenSize() end; local width, height = %s, %s; return %s", pW, pH, w, h, x),
			string.format("local parentW, parentH = %s, %s; if parentW == -1 then parentW, parentH = guiGetScreenSize() end; local width, height = %s, %s; return %s", pW, pH, w, h, y)
end


function PositionCoder.runOutput(output)
	local func, errorMessage = loadstring(output)
	
	if errorMessage then
		return "ERROR", errorMessage
	end
	
	local ran, result = pcall(func)
	
	if not ran then
		return "ERROR", result
	end
	
	if not result then
		return "ERROR", "ERROR"
	end
	
	if tonumber(result) then
		return string.format("%.2f", result)
	end
	
	return "ERROR", "ERROR"
end

--[[--------------------------------------------------
	presets
--]]--------------------------------------------------

function PositionCoder.loadPresets()
	PositionCoder.destroyPresets()
	
	local w = guiGetSize(PositionCoder.gui.scroller, false)
	
	for i,preset in ipairs(PositionCoder.presets) do	
		PositionCoder.gui.presets[i] = {}
			
		PositionCoder.gui.presets[i].preset = guiCreateLabel(0, (i - 1) * 15, w - 40, 15, preset.description, false, PositionCoder.gui.scroller)

		setRolloverColour(PositionCoder.gui.presets[i].preset,  gColours.primary, {255, 255, 255, 255})
			
		addEventHandler("onClientGUIClick", PositionCoder.gui.presets[i].preset, 
			function()
				guiSetText(PositionCoder.gui.edtPositionX, "x = " .. preset.x)
				guiSetText(PositionCoder.gui.edtPositionY, "y = " .. preset.y)	
				guiSetText(PositionCoder.gui.btnDone, "Done")
			end
		, false)

		if preset.removable then
			PositionCoder.gui.presets[i].delete = guiCreateStaticImage(w-40, ((i - 1) * 15), 16, 16, "images/cross.png", false, PositionCoder.gui.scroller)
			guiSetAlpha(PositionCoder.gui.presets[i].delete, 0)
				
				
			addEventHandler("onClientGUIClick", PositionCoder.gui.presets[i].delete, 
				function()
					local mbox = MessageBox_Continue:create("Are you sure you want to delete that preset?\nNote: This action cannot be undone\n\n("..tostring(preset.description)..")", "Delete", "Cancel")
					guiWindowSetMovable(mbox.window, false)
						
					mbox.onAffirmative = 	
						function()
							table.remove(PositionCoder.presets, i)
							PositionCoder.loadPresets()
							PositionCoder.saveFile()
						end
				end
			, false)
				
				
			addEventHandler("onClientMouseEnter", PositionCoder.gui.presets[i].preset, 
				function()
					guiSetAlpha(PositionCoder.gui.presets[i].delete, 1)
				end
			, false)
				
			addEventHandler("onClientMouseLeave", PositionCoder.gui.presets[i].preset, 
				function()
					guiSetAlpha(PositionCoder.gui.presets[i].delete, 0)
				end
			, false)
				
				
			addEventHandler("onClientMouseEnter", PositionCoder.gui.presets[i].delete, 
				function()
					guiSetAlpha(PositionCoder.gui.presets[i].delete, 1)
				end
			, false)
			
			addEventHandler("onClientMouseLeave", PositionCoder.gui.presets[i].delete, 
				function()
					guiSetAlpha(PositionCoder.gui.presets[i].delete, 0)
				end
			, false)		
		end
			
			
		local w = guiGetSize(PositionCoder.gui.scroller, false)
		local mainW = guiGetSize(PositionCoder.gui.wndMain, false)
			
		if i == 4 then
			guiSetSize(PositionCoder.gui.wndMain, mainW, PositionCoder.height + 90 + 15, false)
			guiSetSize(PositionCoder.gui.scroller, w, 65, false)		
		elseif i == 5 then
			guiSetSize(PositionCoder.gui.wndMain, mainW, PositionCoder.height + 90 + 30, false)
			guiSetSize(PositionCoder.gui.scroller, w, 80, false)
		elseif i == 6 then
			guiSetSize(PositionCoder.gui.wndMain, mainW, PositionCoder.height + 90 + 45, false)
			guiSetSize(PositionCoder.gui.scroller, w, 95, false)	
		elseif i == 7 then
			guiSetSize(PositionCoder.gui.wndMain, mainW, PositionCoder.height + 90 + 60, false)
			guiSetSize(PositionCoder.gui.scroller, w, 110, false)			
		end
	end
end


function PositionCoder.addPreset()
	local x, y = PositionCoder.getOutput()
	
	if x and y and x ~= "" and y ~= "" then
		local mbox = MessageBox_Input:create(false, "Description", "Enter the preset description:", "Add preset")
		mbox:maxLength(68)
		mbox.onAccept = 
			function(text, x, y)
				if PositionCoder.source then
					PositionCoder.presets[#PositionCoder.presets + 1] = {x = x, y = y, description = text, removable = true}
					
					PositionCoder.loadPresets()
					
					PositionCoder.saveFile()
				end
			end
		mbox.onAcceptArgs = {x, y}
	end
end


function PositionCoder.destroyPresets()
	if PositionCoder.gui.presets then
		for i,v in ipairs(PositionCoder.gui.presets) do
			destroyElement(v.preset)
			
			if v.delete then
				destroyElement(v.delete)
			end
		end
	end	
	
	PositionCoder.gui.presets = {}	
end


function PositionCoder.loadFile()
	if PositionCoder.loaded then
		return
	end
	
	local file = xmlLoadFile("settings.xml")
	
	if not file then
		return
	end
	
	if file then
		PositionCoder.loaded = true
		
		local base = getChild(file, "position_coder", 0)
		
		for i,node in ipairs(xmlNodeGetChildren(base)) do
			local x = xmlNodeGetAttribute(node, "x")
			local y = xmlNodeGetAttribute(node, "y")
			local description = xmlNodeGetAttribute(node, "description")
			
			if x and y and description then
				PositionCoder.presets[#PositionCoder.presets + 1] = {x = x, y = y, description = description, removable = true}
			end
		end
		
		xmlUnloadFile(file)
	end
end


function PositionCoder.saveFile()
	local file = xmlLoadFile("settings.xml")
	
	if not file then
		return
	end
	
	if file then
		local base = getChild(file, "position_coder", 0)
		
		if base then
			for i,node in ipairs(xmlNodeGetChildren(base)) do
				xmlDestroyNode(node)
			end
			
			for i, preset in pairs(PositionCoder.presets) do
				if i > 3 then
					local node = xmlCreateChild(base, "preset")
					if node then
						xmlNodeSetAttribute(node, "x", tostring(preset.x))
						xmlNodeSetAttribute(node, "y", tostring(preset.y))
						xmlNodeSetAttribute(node, "description", tostring(preset.description))
					else
						outputDebugString("Failed to save GUI Editor position coder preset ("..tostring(preset.description)..")")
					end
				end
			end		
		end
		
		xmlSaveFile(file)
		xmlUnloadFile(file)
	end	
end