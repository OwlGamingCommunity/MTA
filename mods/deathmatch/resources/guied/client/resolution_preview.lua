--[[--------------------------------------------------
	GUI Editor
	client
	resolution_preview.lua
	
	allows gui created within the editor to be 'previewed' in an on-screen view port at a chosen resolution
--]]--------------------------------------------------


resolutionPreview = {
	resX = gScreen.x,
	resY = gScreen.y,
	viewCorner = {
		x = 0,
		y = 0
	},
	fadeSize = 10000,
	fadeColour = tocolor(0, 0, 0, 180),
	fadeLineColour = tocolor(unpack(gColours.primary)),
	active = false,
	hidden = {},
}

function resolutionPreview.setup()
	if resolutionPreview.active then
		resolutionPreview.undo()
		return
	end
	
	outputDebug("resolutionPreview.setup()", "RESOLUTION_PREVIEW")

	resolutionPreview.active = true
	
	resolutionPreview.center()
	
	for _, element in ipairs(guiGetScreenElements(true)) do
		if not relevant(element) and not getElementData(element, "guieditor:alwaysVisible") then
			resolutionPreview.hidden[element] = guiGetVisible(element)
			guiSetVisible(element, false)
		end
	end
	
	local guiElements = {}	
	local elementQueue = guiGetScreenElements()
	
	-- process every gui element we have (breadth first)
	for _, element in ipairs(elementQueue) do
		local relative = getElementData(element, "guieditor:relative")
		local x, y = guiGetPosition(element, relative, true, resolutionPreview.resX, resolutionPreview.resY)
		local w, h = guiGetSize(element, relative)
		
		local pX, pY = 0, 0
		
		if not guiGetParent(element) then
			pX = resolutionPreview.viewCorner.x
			pY = resolutionPreview.viewCorner.y
		end
		
		local pW, pH = 0, 0
		
		if not guiGetParent(element) then
			pW = resolutionPreview.resX
			pH = resolutionPreview.resY
		end
		
		guiElements[#guiElements + 1] = {
			element = element,
			x = x,
			y = y,
			w = w,
			h = h,
			pX = pX,
			pY = pY,
			pW = pW,
			pH = pH
		}
		
		for _,child in ipairs(getElementChildren(element)) do
			if relevant(child) and getElementData(child, "guieditor:relative") then
				elementQueue[#elementQueue + 1] = child
			end
		end	
	end
	
	
	for _,element in ipairs(guiElements) do
		if guiGetParent(element.element) then
			local w, h = guiGetSize(guiGetParent(element.element), false)
			resolutionPreview.process(element.element, element.x, element.y, element.w, element.h, element.pX, element.pY, w, h)
		else
			resolutionPreview.process(element.element, element.x, element.y, element.w, element.h, element.pX, element.pY, element.pW, element.pH)
		end
	end
	
	resolutionPreview._save = guiElements
	
	addEventHandler("onClientPreRender", root, resolutionPreview.drawView)
end


function resolutionPreview.process(element, x, y, w, h, parentX, parentY, parentW, parentH)
	if getElementData(element, "guieditor:relative") then
		x = x * parentW
		y = y * parentH
		guiSetPosition(element, parentX + x, parentY + y, false)
			
		w = w * parentW
		h = h * parentH
		guiSetSize(element, w, h, false)
	else
		guiSetPosition(element, parentX + x, parentY + y, false)
	end		
end


function resolutionPreview.drawView()
	-- left
	dxDrawRectangle(resolutionPreview.viewCorner.x - resolutionPreview.fadeSize, resolutionPreview.viewCorner.y - resolutionPreview.fadeSize, resolutionPreview.fadeSize, resolutionPreview.fadeSize, resolutionPreview.fadeColour, true)
	dxDrawRectangle(resolutionPreview.viewCorner.x - resolutionPreview.fadeSize, resolutionPreview.viewCorner.y, resolutionPreview.fadeSize, resolutionPreview.resY, resolutionPreview.fadeColour, true)
	dxDrawRectangle(resolutionPreview.viewCorner.x - resolutionPreview.fadeSize, resolutionPreview.viewCorner.y + resolutionPreview.resY, resolutionPreview.fadeSize, resolutionPreview.fadeSize, resolutionPreview.fadeColour, true)

	-- top
	dxDrawRectangle(resolutionPreview.viewCorner.x, resolutionPreview.viewCorner.y - resolutionPreview.fadeSize, resolutionPreview.resX, resolutionPreview.fadeSize, resolutionPreview.fadeColour, true)
	
	-- right
	dxDrawRectangle(resolutionPreview.viewCorner.x + resolutionPreview.resX, resolutionPreview.viewCorner.y - resolutionPreview.fadeSize, resolutionPreview.fadeSize, resolutionPreview.fadeSize, resolutionPreview.fadeColour, true)
	dxDrawRectangle(resolutionPreview.viewCorner.x + resolutionPreview.resX, resolutionPreview.viewCorner.y, resolutionPreview.fadeSize, resolutionPreview.resY, resolutionPreview.fadeColour, true)
	dxDrawRectangle(resolutionPreview.viewCorner.x + resolutionPreview.resX, resolutionPreview.viewCorner.y + resolutionPreview.resY, resolutionPreview.fadeSize, resolutionPreview.fadeSize, resolutionPreview.fadeColour, true)
	
	-- bototm
	dxDrawRectangle(resolutionPreview.viewCorner.x, resolutionPreview.viewCorner.y + resolutionPreview.resY, resolutionPreview.resX, resolutionPreview.fadeSize, resolutionPreview.fadeColour, true)
	
	dxDrawLine(resolutionPreview.viewCorner.x, resolutionPreview.viewCorner.y, resolutionPreview.viewCorner.x + resolutionPreview.resX, resolutionPreview.viewCorner.y, resolutionPreview.fadeLineColour, 2, true)
	dxDrawLine(resolutionPreview.viewCorner.x, resolutionPreview.viewCorner.y, resolutionPreview.viewCorner.x, resolutionPreview.viewCorner.y + resolutionPreview.resY, resolutionPreview.fadeLineColour, 2, true)
	dxDrawLine(resolutionPreview.viewCorner.x + resolutionPreview.resX - 1, resolutionPreview.viewCorner.y, resolutionPreview.viewCorner.x + resolutionPreview.resX - 1, resolutionPreview.viewCorner.y + resolutionPreview.resY , resolutionPreview.fadeLineColour, 2, true)
	dxDrawLine(resolutionPreview.viewCorner.x, resolutionPreview.viewCorner.y + resolutionPreview.resY - 1, resolutionPreview.viewCorner.x + resolutionPreview.resX, resolutionPreview.viewCorner.y + resolutionPreview.resY - 1, resolutionPreview.fadeLineColour, 2, true)		

	local width = math.max(
		dxGetTextWidth(" Screen Resolution ", 1, "default"),
		dxGetTextWidth(string.format("[ %d x %d ]", resolutionPreview.resX, resolutionPreview.resY), 1, "default")
	)
	local y = resolutionPreview.viewCorner.y
	
	if y < 15 then
		y = 15
	end	
	
	dxDrawText(
		string.format("Screen Resolution\n[ %d x %d ]", resolutionPreview.resX, resolutionPreview.resY),
		resolutionPreview.viewCorner.x + ((resolutionPreview.resX - width) / 2), 
		y - 30, 
		resolutionPreview.viewCorner.x + ((resolutionPreview.resX + width) / 2), 
		y, 		
		resolutionPreview.fadeLineColour, 
		1, "default-bold", "center", "center", true, false, true
	)
	
	y = resolutionPreview.viewCorner.y + resolutionPreview.resY
	
	if y > (gScreen.y - 15) then
		y = gScreen.y - 15
	end
	
	width = dxGetTextWidth("[ Click and drag to move this view window ]", 1, "default")
	
	dxDrawText(
		"[ Click and drag to move this view window ]",
		resolutionPreview.viewCorner.x + ((resolutionPreview.resX - width) / 2), 
		y, 
		resolutionPreview.viewCorner.x + ((resolutionPreview.resX + width) / 2), 
		y + 15, 		
		resolutionPreview.fadeLineColour, 
		1, "default-bold", "center", "center", true, false, true
	)	
end


function resolutionPreview.undo()
	outputDebug("resolutionPreview.undo()", "RESOLUTION_PREVIEW")
	
	if not resolutionPreview._save then
		return
	end	
	
	for _,element in ipairs(resolutionPreview._save) do
		if exists(element.element) then
			local relative = getElementData(element.element, "guieditor:relative")
			local x, y = element.x, element.y
			
			if getElementData(element.element, "guieditor:positionCode") then
				x, y = guiGetPosition(element.element, false, true)
			end
			
			guiSetPosition(element.element, x, y, relative)
			guiSetSize(element.element, element.w, element.h, relative)
		end
	end	
	
	for element, visible in pairs(resolutionPreview.hidden) do
		guiSetVisible(element, visible)
	end	
	
	removeEventHandler("onClientPreRender", root, resolutionPreview.drawView)
	
	resolutionPreview._save = nil
	resolutionPreview.active = false
	resolutionPreview.hidden = {}
end


function resolutionPreview.setResolution(width, height)
	local rWidth, rHeight = width, height
	
	outputDebug("resolutionPreview.setResolution("..tostring(width)..", "..tostring(height)..")", "RESOLUTION_PREVIEW")
	
	-- passed a menu item
	if type(width) == "table" then
		local text = width.text
		
		-- if it has an editbox, grab the actual value
		if width.editbox then
			text = width.replaceValue
		end
		
		text = string.lower(text)
		
		local t = split(text, "x")

		rWidth = tonumber(t[1])
		rHeight = tonumber(t[2])
		
		if not rWidth or not rHeight then
			outputDebug("Invalid resolution in resolutionPreview.setResolution ["..tostring(rWidth)..", "..tostring(rHeight).."]", "RESOLUTION_PREVIEW")
			return
		end
	end

	resolutionPreview.resX = rWidth
	resolutionPreview.resY = rHeight
	
	-- passed the parent item (the item clicked in the parent menu to open the current child menu)
	-- simulate a click on that item (used to simulate a click on the main preview item when clicking the children)
	if height and type(height) == "table" then
		--height:setValue(not height:getValue())
		if not height:getValue() then
			height:clickHandler()
		else
			resolutionPreview.undo()
			resolutionPreview.setup()
		end
	end	
end


function resolutionPreview.updateResolution(width, height)
	if resolutionPreview.active then
		resolutionPreview.undo()
	end
	
	resolutionPreview.setResolution(width, height)
	resolutionPreview.setup()
end


function resolutionPreview.center()
	-- center the view
	resolutionPreview.viewCorner.x = (gScreen.x - resolutionPreview.resX) / 2
	resolutionPreview.viewCorner.y = (gScreen.y - resolutionPreview.resY) / 2	
end


function resolutionPreview.click(button, state, x, y)
	if resolutionPreview.active then
		if button == "left" then
			if state == "down" then
				resolutionPreview.drag = {startX = x, startY = y, x = x, y = y}
			elseif state == "up" then
				resolutionPreview.drag = nil
			end
		end
	end
end


function resolutionPreview.move(x, y)
	if resolutionPreview.active and resolutionPreview.drag then
		local moveX, moveY = x - resolutionPreview.drag.x, y - resolutionPreview.drag.y

		resolutionPreview.viewCorner.x = resolutionPreview.viewCorner.x + moveX
		resolutionPreview.viewCorner.y = resolutionPreview.viewCorner.y + moveY
		
		resolutionPreview.drag.x = x
		resolutionPreview.drag.y = y
		
		for _,element in ipairs(resolutionPreview._save) do
			if not guiGetParent(element.element) then
				local eX, eY = guiGetPosition(element.element, false)
				
				-- bug with guiGetPosition
				if eX < 0 then
					eX = eX - 1
				end
				
				if eY < 0 then
					eY = eY - 1
				end
				
				guiSetPosition(element.element, eX + moveX, eY + moveY, false)
			end
		end		
	end
end

function resolutionPreview.prepareMenu() 
	gMenus.main:getItem(1):setEnabled(false)
	gMenus.main:getItem(2):setEnabled(false)
	
	for i = 4, #gMenus.main.items - 1 do
		gMenus.main:getItem(i):setEnabled(false)
	end
end

