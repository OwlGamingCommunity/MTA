enabled = true

local renderlist = {
--[[
	{ gui-window, texture, children = {
			element, texures = {}
		}
	}
]]
}

function hasPlayerEnabledUI()
	-- chaos, check if the player has the UI turned on in F10 settings
	return enabled
end

function renderlistAddChild(parent, child)
	for i, v in ipairs(renderlist) do
		if v[1] == parent then
			table.insert(renderlist[i].children, child)
			break
		end
	end
end

function renderlistDeleteChild(parent, child)
	for i, v in ipairs(renderlist) do
		if v[1] == parent then
			for p, k in ipairs(renderlist[i].children) do
				if k[1] == child then
					table.remove(renderlist[i].children, p)
					break
				end
			end
			break
		end
	end
end

function renderlistDelete(window)
	for i, v in ipairs(renderlist) do
		if v[1] == window then
			table.remove(renderlist, i)
			break
		end
	end
	for _, k in ipairs(getElementsByType("gui-window")) do
		if getElementData(k, "Owl-GUI") then
			for _, p in ipairs(getAllElementChildren(k)) do
				if getElementType(p) == "gui-button" then
					setElementData(p, "ui:alpha", (isWindowClear(k) or k == renderlist[#renderlist][1]) and 255 or 60)
				elseif getElementType(p) ~= "gui-tabpanel" then
					guiSetAlpha(p, (isWindowClear(k) or k == renderlist[#renderlist][1]) and (getElementType(p) == "gui-gridlist" and 0.8 or 1.0) or 0.2)
				end
			end
		end
	end
	checkChatBox()
end

function checkChatBox()
	local chatbox = getChatboxLayout()
	local width = (325*chatbox['chat_width'])
	local height = dxGetFontHeight(chatbox['text_scale'], "default-bold")*chatbox['chat_lines']
	for i, v in ipairs(getElementsByType("gui-window")) do
		local wX, wY = guiGetPosition(v, false)
		if (wX < 15+width) and (wY < 15+height) and guiGetVisible(v) and getElementData(v, "Owl-GUI") then
			if isChatVisible() then
				showChat(false)
			end
			return
		end
	end
	showChat(true)
end

function doesRectanglesCollide(X1, Y1, sizeX1, sizeY1, X2, Y2, sizeX2, sizeY2)
	local centreX1, centreY1 = X1 + sizeX1 / 2, Y1 + sizeY1 / 2
	local centreX2, centreY2 = X2 + sizeX2 / 2, Y2 + sizeY2 / 2
	
	local distanceX = centreX1 - centreX2
	local distanceY = centreY1 - centreY2 
	
	if distanceX < 0 then
		distanceX = -distanceX
	end
	if distanceY < 0 then
		distanceY = -distanceY
	end
	
	if distanceX <= sizeX1 / 2 + sizeX2 / 2 and distanceY <= sizeY1 / 2 + sizeY2 / 2 then
		return true
	end
	return false
end


function isWindowClear(element)
	local x1, y1 = guiGetPosition(element, false)
	local w1, h1 = guiGetSize(element, false)
	for i, v in ipairs(getElementsByType("gui-window")) do
		if v ~= element and guiGetVisible(v) and getElementData(v, "Owl-GUI") then
			local x2, y2 = guiGetPosition(v, false)
			local w2, h2 = guiGetSize(v, false)
			if doesRectanglesCollide(x1, y1, w1, h1, x2, y2, w2, h2) or doesRectanglesCollide(x2, y2, w2, h2, x1, y1, w1, h1) then
				return false
			end
		end
	end
	return true
end

function getAllElementChildren(element, children)
	if not children then children = {} end
	for i, v in ipairs(getElementChildren(element)) do
		table.insert(children, v)
		if getElementType(v) == "gui-tabpanel" then
			children = getAllElementChildren(v, children)
		elseif getElementType(v) == "gui-tab" then
			children = getAllElementChildren(v, children)
		elseif getElementType(v) == "gui-scrollpane" then
			children = getAllElementChildren(v, children)
		end
	end
	return children
end

function guiGetWindowFromElement(element)
	if getElementType(element) == "gui-window" then
		return element
	elseif getElementType(element) == "guiroot" then
		return false
	else
		return guiGetWindowFromElement(getElementParent(element))
	end
end

function convertUI(element)
	if hasPlayerEnabledUI() and element and isElement(element) then
		if getElementType(element) == "gui-button" then
			guiConvertButton(element, guiGetWindowFromElement(element))
		elseif getElementType(element) == "gui-gridlist" then
			guiSetAlpha(element, 0.8)
		elseif getElementType(element) == "gui-window" then
			guiConvertWindow(element)
		elseif getElementType(element) == "gui-tabpanel" then
			guiConvertTabPanel(element, guiGetWindowFromElement(element))
		end
		for i, v in ipairs(getAllElementChildren(element)) do
			if getElementType(v) == "gui-tabpanel" then
				guiConvertTabPanel(v, guiGetWindowFromElement(element))
			elseif getElementType(v) == "gui-button" then
				guiConvertButton(v, guiGetWindowFromElement(element))
			end
		end
	end
end
addEvent("hud:convertUI", false)
addEventHandler("hud:convertUI", localPlayer, convertUI)

function drawWindowGUI(element, windowTexture)
	if not element or not isElement(element) then
		renderlistDelete(element)
	else
		if guiGetVisible(element) then
			local x, y = guiGetPosition(element, false)
			local width, height = guiGetSize(element, false)

			if getElementData(element, "ui:text") ~= guiGetText(element) then
				for i, v in ipairs(renderlist) do
					if v[1] == element then
						local windowTexture = dxCreateRenderTarget(width, height, true)
						dxSetRenderTarget(windowTexture)
						dxDrawRectangle(0, 0, width, height, tocolor(20, 20, 20, 180)) -- main window
						dxDrawRectangle(0, 0, width, 18, tocolor(20, 20, 20, 200)) -- titlebar
						dxDrawLine(0, 19, width, 19, tocolor(0, 170, 255, 225), 2.0)
						dxDrawText(guiGetText(element), 0, 0, width, 19, tocolor(255, 255, 255, 240), 1.0, "default-bold", "center", "center", true)
						dxSetRenderTarget()

						renderlist[i][2] = windowTexture
					end
				end
			end

			dxDrawImage(x, y, width, height, windowTexture)
		end
	end
end

function guiConvertWindow(element)
	setElementData(element, "Owl-GUI", true)
	guiSetAlpha(element, 0)
	for i, v in ipairs(getElementChildren(element)) do
		guiSetProperty(v, "InheritsAlpha", "False")
	end

	local width, height = guiGetSize(element, false)
	local text = guiGetText(element)
	setElementData(element, "ui:text", text)

	local windowTexture = dxCreateRenderTarget(width, height, true)
	if windowTexture then
		dxSetRenderTarget(windowTexture)
		dxDrawRectangle(0, 0, width, height, tocolor(20, 20, 20, 180)) -- main window
		dxDrawRectangle(0, 0, width, 18, tocolor(20, 20, 20, 200)) -- titlebar
		dxDrawLine(0, 19, width, 19, tocolor(0, 170, 255, 225), 2.0)
		dxDrawText(text, 0, 0, width, 19, tocolor(255, 255, 255, 240), 1.0, "default-bold", "center", "center", true)
		dxSetRenderTarget()

		table.insert(renderlist, { element, windowTexture, children = {} })
	end

	for _, k in ipairs(getElementsByType("gui-window")) do
		if getElementData(k, "Owl-GUI") then
			for _, p in ipairs(getAllElementChildren(k)) do
				if getElementType(p) == "gui-button" then
					setElementData(p, "ui:alpha", (isWindowClear(k) or k == element) and 255 or 60)
				elseif getElementType(p) ~= "gui-tabpanel" then
					guiSetAlpha(p, (isWindowClear(k) or k == element) and (getElementType(p) == "gui-gridlist" and 0.8 or 1.0) or 0.2)
				end
			end
		end
	end
	
	-- check if any others are currently in the dead-zone
	for i, v in ipairs(getElementsByType("gui-window")) do
		local wX, wY = guiGetPosition(v, false)
		if (wX < 15+width) and (wY < 15+height) and guiGetVisible(v) then
			showChat(false)
		end
	end

	return true
end

function drawTabPanelGUI(element, textures)
	if element and isElement(element) then
		if guiGetVisible(element) then
			local x, y = guiGetNestedPosition(element)
			local panelWidth, panelHeight = guiGetSize(element, false)

			local difference = getElementData(guiGetSelectedTab(element), "ui:difference")
			local tabwidth = dxGetTextWidth(guiGetText(guiGetSelectedTab(element)), 1.0, "default")+19
			
			local difference = 0
			for i, v in ipairs(getElementChildren(element)) do
				if guiGetProperty(v, "InheritsAlpha") == "True" then
					guiSetProperty(v, "InheritsAlpha", "False")
				end
				local text = guiGetText(v)
				local width, height = dxGetTextWidth(text, 1.0, "default")+19, 21

				dxDrawRectangle(x + difference, y, width, height+1, tocolor(20, 20, 20, 200))
				dxDrawText(text, x + difference, y, x+difference+width, y+height, tocolor(255, 255, 255, 240), 1.0, "default", "center", "center", true)
				if guiGetSelectedTab(element) == v then
					dxDrawLine(x+difference, y+20, x+difference+tabwidth, y+20, tocolor(0, 170, 255, 225), 1.0)
				end

				difference = difference+dxGetTextWidth(text, 1.0, "default")+19
			end

			dxDrawRectangle(x, y + 22, panelWidth, panelHeight - 22, tocolor(20, 20, 20, 200))
		end
	end
end

function guiConvertTabPanel(panel, window)
	guiSetAlpha(panel, 0)
	local difference = 0
	local panelWidth, panelHeight = guiGetSize(panel, false)
	local panelTexture = dxCreateRenderTarget(panelWidth, panelHeight, true)
	setElementData(panel, "Owl-GUI", true)

	for i, v in ipairs(getElementChildren(panel)) do
		guiSetProperty(v, "InheritsAlpha", "False")
	end
	
	renderlistAddChild(window, { panel, textures = { panelTexture } })

	return true
end

function guiConvertButton(element, window)
	setElementData(element, "Owl-GUI", true)
	guiSetAlpha(element, 0)

	local width, height = guiGetSize(element, false)
	local text = guiGetText(element)
	setElementData(element, "ui:text", text)
	setElementData(element, "ui:alpha", 255)

	local buttonTexture = dxCreateRenderTarget(width, height, true)
	local buttonHoverTexture = dxCreateRenderTarget(width, height, true)
	local buttonHoverTexture = dxCreateRenderTarget(width, height, true)
	local buttonClickTexture = dxCreateRenderTarget(width, height, true)
	local buttonDisabledTexture = dxCreateRenderTarget(width, height, true)

	if buttonTexture and buttonHoverTexture and buttonClickTexture then
		dxSetRenderTarget(buttonTexture)
		dxDrawRectangle(0, 0, width, height, tocolor(52, 152, 219, 225))
		dxDrawText(text, 0, 0, width, height, tocolor(255, 255, 255, 240), 1.0, "default", "center", "center", true, true)

		dxSetRenderTarget(buttonHoverTexture)
		dxDrawRectangle(0, 0, width, height, tocolor(10, 107, 172, 225))
		dxDrawText(text, 0, 0, width, height, tocolor(255, 255, 255, 240), 1.0, "default", "center", "center", true, true)

		dxSetRenderTarget(buttonClickTexture)
		dxDrawRectangle(0, 0, width, height, tocolor(12, 86, 135, 225))
		dxDrawText(text, 0, 0, width, height, tocolor(255, 255, 255, 240), 1.0, "default", "center", "center", true, true)

		dxSetRenderTarget(buttonDisabledTexture)
		dxDrawRectangle(0, 0, width, height, tocolor(80, 80, 80, 225))
		dxDrawText(text, 0, 0, width, height, tocolor(150, 150, 150, 240), 1.0, "default", "center", "center", true, true)
		dxSetRenderTarget()

		renderlistAddChild(window, { element, textures = { buttonTexture, buttonHoverTexture, buttonClickTexture, buttonDisabledTexture } })
	end
end

function drawButtonGUI(element, textures)
	if element and isElement(element) then
		if guiGetVisible(element) then
			local x, y = guiGetNestedPosition(element)
			local width, height = guiGetSize(element, false)
			local color = tocolor(255, 255, 255, getElementData(element, "ui:alpha"))

			-- check if there are any differences
			if getElementData(element, "ui:text") ~= guiGetText(element) then
				renderlistDeleteChild(guiGetWindowFromElement(element), element)
				guiConvertButton(element, guiGetWindowFromElement(element))
			end

			if guiGetProperty(element, "Disabled") == "True" then
				dxDrawImage(x, y, width, height, textures[4], 0, 0, 0, color)
			else
				if isCursorWithinRectangle(x, y, width, height) then
					if getKeyState("mouse1") then
						dxDrawImage(x, y, width, height, textures[3], 0, 0, 0, color)
					else
						dxDrawImage(x, y, width, height, textures[2], 0, 0, 0, color)
					end
				else
					dxDrawImage(x, y, width, height, textures[1], 0, 0, 0, color)
				end
			end
		end
	end
end

function isCursorWithinRectangle(x, y, width, height)
	if isCursorShowing() then
		local screenWidth, screenHeight = guiGetScreenSize()
		local cx, cy = getCursorPosition()
		cx, cy = cx*screenWidth, cy*screenHeight
		if (cx > x and cx < x+width) and (cy > y and cy < y+height) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function guiGetNestedPosition(element, x, y)
	if not x or not y then
		x, y = 0, 0
	end
	if element and isElement(element) and getElementType(element) ~= "guiroot" then
		local elementX, elementY = guiGetPosition(element, false)
		if getElementType(element) == "gui-tab" then
			elementY = elementY + 24
		elseif getElementType(element) == "gui-scrollpane" then
			elementX = elementX - 23
			elementY = elementY - 21
		end
		x = x + elementX
		y = y + elementY
		local parent = getElementParent(element)
		if parent and isElement(parent) then
			return guiGetNestedPosition(parent, x, y)
		else
			return x, y
		end
	else
		return x, y
	end
end

addEventHandler("onClientGUIMove", getRootElement(), function()
	if hasPlayerEnabledUI() and getElementData(source, "Owl-GUI") then
		local chatbox = getChatboxLayout()
		local width = (325*chatbox['chat_width'])
		local height = dxGetFontHeight(chatbox['text_scale'], "default-bold")*chatbox['chat_lines']
		local x, y = guiGetPosition(source, false)
		if (x < 15+width) and (y < 15+height) then
			showChat(false)
		else
			checkChatBox()
		end
		local wx, wy = guiGetPosition(source, false)
		local wwidth, wheight = guiGetSize(source, false)
		for _, k in ipairs(getElementsByType("gui-window")) do
			local x, y = guiGetPosition(k, false)
			local width, height = guiGetSize(k, false)
			if getElementData(k, "Owl-GUI") and (doesRectanglesCollide(wx, wy, wwidth, wheight, x, y, width, height) or doesRectanglesCollide(x, y, width, height, wx, wy, wwidth, wheight)) then
				for _, p in ipairs(getAllElementChildren(k)) do
					if getElementType(p) == "gui-button" then
						setElementData(p, "ui:alpha", (isWindowClear(k) or k == source) and 255 or 60)
					elseif getElementType(p) ~= "gui-tabpanel" then
						guiSetAlpha(p, (isWindowClear(k) or k == source) and (getElementType(p) == "gui-gridlist" and 0.8 or 1.0) or 0.2)
					end
				end
			end
		end
	end
end)

addEventHandler("onClientClick", getRootElement(), function(button, state) -- not using onClientGUIClick because it doesn't support state == "down"
	if hasPlayerEnabledUI() then
		for i, v in ipairs(getElementsByType("gui-window")) do
			local x, y = guiGetPosition(v, false)
			local width, height = guiGetSize(v, false)
			if isCursorWithinRectangle(x, y, width, 20) and guiGetVisible(v) and getElementData(v, "Owl-GUI") then
				for _, k in ipairs(renderlist) do
					if k[1] == v and getElementType(source) ~= "gui-button" then
						table.insert(renderlist, k) -- removes & re-adds the row to the bottom of the table
						table.remove(renderlist, _)
						break
					end
				end
				for _, k in ipairs(getElementsByType("gui-window")) do
					if getElementData(k, "Owl-GUI") then
						for _, p in ipairs(getAllElementChildren(k)) do
							if getElementType(p) == "gui-button" then
								setElementData(p, "ui:alpha", (isWindowClear(k) or k == v) and 255 or 60)
							elseif getElementType(p) ~= "gui-tabpanel" then
								guiSetAlpha(p, (isWindowClear(k) or k == v) and (getElementType(p) == "gui-gridlist" and 0.8 or 1.0) or 0.2)
							end
						end
					end
				end
				break
			end
		end
	end
end)

addEventHandler("onClientRender", getRootElement(), function()
	if hasPlayerEnabledUI() then
		for _, v in ipairs(renderlist) do
			drawWindowGUI(v[1], v[2])
			for _, k in ipairs(v.children) do
				if isElement(k[1]) then
					if getElementType(k[1]) == "gui-tabpanel" then
						drawTabPanelGUI(k[1], k.textures)
					elseif getElementType(k[1]) == "gui-tab" then
						drawTabGUI(k[1], k.textures)
					elseif getElementType(k[1]) == "gui-button" then
						drawButtonGUI(k[1], k.textures)
					end
				end
			end
		end
	end
end, false, "low-1")


--[[
===============================
===== RESTORE =================
===============================
]]


function guiReset(resource, value)
	if not resource then resource = getThisResource() end
	if resource == getThisResource() or (value and value == "0") then
		-- This script is designed to revert all GUI to default if the resource restarts or stops.
		for i, v in ipairs(getElementsByType("gui-window")) do
			if getElementData(v, "Owl-GUI") then
				guiSetAlpha(v, 0.8)
				for p, k in ipairs(getElementChildren(v)) do
					guiSetProperty(k, "InheritsAlpha", "True")
				end
				setElementData(v, "Owl-GUI", false)
			end
		end
		for i, v in ipairs(getElementsByType("gui-tabpanel")) do
			if getElementData(v, "Owl-GUI") then
				guiSetAlpha(v, 1.0)
				for p, k in ipairs(getElementChildren(v)) do
					guiSetProperty(k, "InheritsAlpha", "True")
				end
				setElementData(v, "Owl-GUI", false)
			end
		end
		for i, v in ipairs(getElementsByType("gui-button")) do
			if getElementData(v, "Owl-GUI") then
				guiSetAlpha(v, 1.0)
				setElementData(v, "Owl-GUI", false)
			end
		end
		for i, v in ipairs(getElementsByType("gui-gridlist")) do
			guiSetAlpha(v, 0.9)
		end
		renderlist = {}
	end

    if value then
        enabled = (value ~= "0")
    end
end
addEventHandler("onClientResourceStop", getRootElement(), guiReset)
addEventHandler("onClientMinimize", getRootElement(), guiReset)
addEvent("hud:guiReset", true)
addEventHandler("hud:guiReset", getRootElement(), guiReset)


function guiRestore()
	if hasPlayerEnabledUI() then
		for _, windows in ipairs(getElementsByType("gui-window")) do
			if not getElementData(windows, "Owl-GUI") and guiGetVisible(windows) then
				convertUI(windows)
			end
		end
	end
end
addEventHandler("onClientRestore", getRootElement(), guiRestore)


--[[
============================
======= DEBUG ==============
============================
]]


-- This is a temporary command and converts all on-screen default GUI to the new one for testing purposes.
--[[addCommandHandler("convert", function()
	for i, v in ipairs(getElementsByType("gui-window")) do
		if not getElementData(v, "Owl-GUI") and guiGetVisible(v) then
			convertUI(v)
		end
	end
end)]]
