--[[--------------------------------------------------
	GUI Editor
	client
	menu.lua
	
	handles the right click menus
--]]--------------------------------------------------

Menu = {}
Menu.__index = Menu
Menu.instances = {}

Menu.getOpen = 
	function()
		local t = {}
		
		for _,m in ipairs(Menu.instances) do
			if m.visible then
				t[#t + 1] = m
			end
		end
		
		return t
	end
Menu.anyOpen = 
	function()
		return #Menu.getOpen() > 0
	end


Menu.mouseStates = {none = 0, on = 1, off = 2}
Menu.egdeBuffer = 5
Menu.closingTime = 250
Menu.getFromID = function(id) return Menu.instances[id] end

function Menu:create(title, width, xPos, yPos)
	local new = setmetatable(
		{
			position = {x = xPos or 0, y = yPos or 0},
			width = width or 150,
			height = 0,
			borderColour = {0, 0, 0, 200},
			borderWidth = 1,
			scrollHintHeight = 15,
			items = {},
			children = {},
			postGUI = true,
			visible = false,
			enabled = true,
			id = #Menu.instances + 1,
			controlHeld = false,
		},
		Menu
	)
	
	local header = MenuItem_Text:create(title, {horizontal = "center"}, "default-bold"):set({
		clickable = false,
		backgroundColour = {0, 0, 0, 180},
		height = 18,
	})

	new:addItem(header)
	
	Menu.instances[#Menu.instances + 1] = new
	
	return new
end


function Menu:addItem(item, pos)
	if pos and tonumber(pos) then
		pos = pos + 1
		table.insert(self.items, pos, item)
		self:calculateItemPositions()
	else
		self.items[#self.items + 1] = item
		self:calculateItemPositions(#self.items)
	end

	item.menu = self
	item.width = self.width
	
	self:calculateHeight()
	
	return item
end


function Menu:calculateHeight()
	local heightOffset = 0
				
	for _,item in ipairs(self.items) do
		if item:visible() then
			heightOffset = heightOffset + item.height
		end
	end	
	
	self.height = heightOffset	
end


function Menu:getItem(index)
	return self.items[index + 1]
end


function Menu:removeItem(index)
	if self.items[index] then
		self.items[index].menu = nil
		
		table.remove(self.items, index)
	end
end

function Menu:removeAllItems() 
	for i = 1, #self.items do
		self:removeItem(2)
	end
	
	self:calculateHeight()
end


function Menu:setVisible(visible)
	self.visible = visible
	
	for _,item in ipairs(self.items) do
		if item.setVisible then
			item:setVisible(visible)
		end
	end	
end


function Menu:setEnabled(enabled, ignoreChildren)
	self.enabled = enabled
	
	for _,item in ipairs(self.items) do
		if item.setEnabled then
			item:setEnabled(enabled)
		end
	end		
	
	if not ignoreChildren then
		for _,id in pairs(self.children) do
			if Menu.getFromID(id).visible then
				return Menu.getFromID(id):setEnabled(enabled)
			end
		end		
	end
end


function Menu:setClickable(clickable, ignoreChildren)
	for i,item in ipairs(self.items) do
		if i > 1 then
			item.clickable = clickable
		end
	end		
	
	if not ignoreChildren then
		for _,id in pairs(self.children) do
			if Menu.getFromID(id).visible then
				return Menu.getFromID(id):setClickable(clickable)
			end
		end		
	end
end


function Menu:setBorder(colour, width)
	self.borderColour = colour
	self.borderWidth = width
end


function Menu:getParent(checkParent)
	if not checkParent then
		return self.parent
	else
		if self.parent then
			return Menu.getFromID(self.parent):getParent(true)
		else
			return self.id
		end
	end
end


function Menu:calculateItemPositions(index)
	-- calculate a specific item in the menu
	if index and tonumber(index) then
		--[[
		self.items[index].position = {
			x = self.position.x,
			y = (index > 1 and (self.items[index - 1].position.y + self.items[index - 1].height) or self.position.y)
		}
		]]
		
		self.items[index]:setPosition(self.position.x, (index > 1 and (self.items[index - 1].position.y + self.items[index - 1].height) or self.position.y))
	-- all items	
	else
		local heightOffset = 0

		for _,item in ipairs(self.items) do
			--item.position = {x = self.position.x, y = self.position.y + heightOffset}
			item:setPosition(self.position.x, self.position.y + heightOffset)
				
			if (item:visible()) then
				heightOffset = heightOffset + item.height
			end
		end		
	end
end


function Menu:isMouseOn(checkChildren)
	if self.mouseState == Menu.mouseStates.on then
		return true
	end
	
	if checkChildren then
		for _,id in pairs(self.children) do
			if Menu.getFromID(id).visible then
				return Menu.getFromID(id):isMouseOn(checkChildren)
			end
		end
	end
	
	return false
end


function Menu:getGUI(checkParent)
	return exists(self.guiParent) and self.guiParent or (checkParent and Menu.getFromID(self:getParent(true)).guiParent or nil)
end


function Menu:open(x, y, guiParent, checkLocked)
	if checkLocked then
		local gui = guiParent
		
		if gui and type(gui) == "table" and gui.dxType then
			gui = gui.element
		end
		
		if getElementData(gui, "guieditor:locked") and not (getKeyState("lctrl") or getKeyState("rctrl")) then
			gMenus.main:open(x, y, true)
			return
		end
	end
	
	self.controlHeld = getKeyState("lctrl") or getKeyState("rctrl")

	if self.onPreOpen then
		self.onPreOpen(self)
	end
	
	for _,id in pairs(self.children) do
		if Menu.getFromID(id).visible then
			Menu.getFromID(id):close()
		end
	end		

	-- if this menu has a guiParent, or its top-level menu parent has a guiParent
	-- then set the dynamic menu items to the correct values for this element
	if guiParent or (self:getParent(true) and Menu.getFromID(self:getParent(true)).guiParent) then
		if guiParent then
			if isBool(guiParent) then
				self.guiParent = guiGetHoverElement()
			else
				self.guiParent = guiParent
			end
		end
		
		local gui = exists(guiParent) and guiParent or Menu.getFromID(self:getParent(true)).guiParent
	
		if gui and type(gui) == "table" and gui.dxType then
			gui = gui.element
		end
		
		-- some menu items need to have their state set according to the state of the gui element
		-- eg: the alpha slider needs to be set to the current alpha value
		for _,item in ipairs(self.items) do
			if item.itemID then
				if item.itemID == "outputType" then
					item:setSelected(getElementData(gui, "guieditor:relative") and 2 or 1)
				elseif item.itemID == "alpha" then
					item:setValue(guiGetAlpha(gui) * 100)
				elseif item.itemID == "dimensionX" or item.itemID == "dimensionY" or
					item.itemID == "dimensionWidth" or item.itemID == "dimensionHeight" then
					item.editbox.filter = getElementData(gui, "guieditor:relative") and gFilters.numberFloat or gFilters.numberInt
				elseif item.itemID == "parent" then
					if guiGetParent(gui) and not self:getParent() then
						local elementType = string.lower(getElementType(guiGetParent(gui)))
				
						elementType = stripGUIPrefix(elementType)
				
						if getElementData(guiGetParent(gui), "guieditor:managed") and gMenus[elementType] then
							item.onClickClose = true
							item.onClick = 
								function() 
									item.menu:close() 
									-- give a 100ms timer to make it visually obvious that the previous menu has closed and a new one has opened
									setTimer(
										function() 
											gMenus[elementType]:open(item.menu.position.x, item.menu.position.y, guiGetParent(gui)) 
											ContextBar.add("The menu for the parent "..elementType.." has been opened")
										end, 
									100, 1) 
								end
						else
							item.onClickClose = false
							item.onClick = nil
						end
					elseif not guiGetParent(gui) and not self:getParent() then
						item.onClickClose = true
						item.onClick = 
							function() 
								item.menu:close() 
								-- give a 100ms timer to make it visually obvious that the previous menu has closed and a new one has opened
								setTimer(
									function() 
										gMenus.main:open(item.menu.position.x, item.menu.position.y, true) 
										ContextBar.add("The menu for the screen has been opened")
									end, 
								100, 1) 
							end										
					else
						item.onClickClose = false
						item.onClick = nil
					end
				elseif item.itemID == "windowMovable" then
					item:setValue(guiWindowGetMovable(gui))
				elseif item.itemID == "windowSizable" then
					item:setValue(guiWindowGetSizable(gui))
				elseif item.itemID == "readOnly" then
					item:setValue(guiGetReadOnly(gui))
				elseif item.itemID == "horizontalAlign" then
					local align = guiLabelGetHorizontalAlign(gui)
					
					if align == "left" then
						item:setValue(1)
					elseif align == "center" then
						item:setValue(2)
					else
						item:setValue(3)
					end
				elseif item.itemID == "verticalAlign" then
					local align = guiLabelGetVerticalAlign(gui)
					
					if align == "top" then
						item:setValue(1)
					elseif align == "center" then
						item:setValue(2)
					else
						item:setValue(3)
					end	
				elseif item.itemID == "wordwrap" then
					item:setValue(guiLabelGetWordwrap(gui))
				elseif item.itemID == "masked" then
					item:setValue(guiEditGetMasked(gui))
				elseif item.itemID == "progress" then
					item:setValue(guiProgressBarGetProgress(gui))
				elseif item.itemID == "scroll" then
					item:setValue(guiScrollBarGetScrollPosition(gui))	
				elseif item.itemID == "clip" then
					local dx = DX_Element.getDXFromElement(gui)
					
					item:setValue(dx:clip())
				elseif item.itemID == "colourCoded" then
					local dx = DX_Element.getDXFromElement(gui)
					
					item:setValue(dx:colourCoded())		
				elseif item.itemID == "postGUI" then
					local dx = DX_Element.getDXFromElement(gui)
					
					item:setValue(dx:postGUI())
				elseif item.itemID == "shadow" then
					local dx = DX_Element.getDXFromElement(gui)
					
					item:setValue(dx:shadow())
				elseif item.itemID == "outline" then
					local dx = DX_Element.getDXFromElement(gui)
					
					item:setValue(dx:outline())
				elseif item.itemID == "fontSize" then
					local dx = DX_Element.getDXFromElement(gui)
					local size
					
					if dx then
						size = dx.fontSize
					else
						size = getElementData(gui, "guieditor:fontSize")
					end
					
					if size then
						item:setValue(size)
					end
				elseif item.itemID == "locked" then
					item:setValue(getElementData(gui, "guieditor:locked"))
				end
			end
		end				
	end
	
	self.position.x = x or self.position.x
	self.position.y = y or self.position.y
	
	self:calculateHeight()
	
	if (self.position.y + self.height) > gScreen.y then
		if self.position.y - self.height < 0 then
			self.position.y = math.max(0, gScreen.y - self.height)
		else
			if self.parent then
				local parentItemHeight = 0
				
				for id, menu in pairs(Menu.getFromID(self.parent).children) do
					if menu == self.id then
						parentItemHeight = MenuItem.getFromID(id).height
						break
					end
				end		

				self.position.y = self.position.y - self.height + parentItemHeight
			else
				self.position.y = self.position.y - self.height
			end
		end
	end
	
	if self.height > gScreen.y then
		self.scrollable = true
	end
	
	if (self.position.x + self.width) > gScreen.x or (self.parent and Menu.getFromID(self.parent).flipped) then
		self.flipped = true
		
		if self.parent then
			if Menu.getFromID(self.parent).flipped then
				local grandparent = Menu.getFromID(Menu.getFromID(self.parent):getParent())
				
				if grandparent and self.position.y > (grandparent.position.y + grandparent.height) then
					self.position.x = Menu.getFromID(self.parent).position.x + Menu.getFromID(self.parent).width
				else
					self.position.x = Menu.getFromID(self.parent).position.x - self.width
				end
			else
				if self.position.y > (Menu.getFromID(self:getParent(true)).position.y + Menu.getFromID(self:getParent(true)).height) then
					self.position.x = Menu.getFromID(self:getParent(false)).position.x - self.width
				else
					self.position.x = Menu.getFromID(self:getParent(true)).position.x - self.width
				end
			end
		else
			self.position.x = self.position.x - self.width
		end
	else
		self.flipped = false
	end
	
	self:calculateItemPositions()
	
	self.mouseState = Menu.mouseStates.none
	self.closeTime = nil

	self:setVisible(true)
	
	self:updateMouseState()	
	
	
	if self.onOpen then
		self.onOpen(self)
	end
	
	return self
end


function Menu:close(closeParent)
	if self.onClose then
		self.onClose(self)
	end

	if self.parent and closeParent then
		Menu.getFromID(self.parent):close(closeParent)
		return
	end

	for _,id in pairs(self.children) do
		if Menu.getFromID(id).visible then
			Menu.getFromID(id):close()
		end
	end		

	for _,item in ipairs(self.items) do
		item.lockMouse = false
		
		if item.editboxCodeWarning then
			item.editboxCodeWarning:negative()
		end
	end			

	self.mouseState = Menu.mouseStates.off

	self:setVisible(false)
	
	self.parent = nil
end


function Menu:itemEnterHandler(item)
	for itemID,id in pairs(self.children) do
		if itemID ~= item.id and Menu.getFromID(id).visible then
			if self.children[item.id] then
				Menu.getFromID(id):close()
			elseif not Menu.getFromID(id).closeTime then
				Menu.getFromID(id).closeTime = getTickCount()
			end
		end
	end	

	if self.children[item.id] then
		Menu.getFromID(self.children[item.id]).parent = self.id
		
		Menu.getFromID(self.children[item.id]).guiParent = self.guiParent
		Menu.getFromID(self.children[item.id]):open(item.position.x + item.width, item.position.y)
	end

	if self.onItemEnter then
		self.onItemEnter(item)
	end
end


function Menu:itemExitHandler(item)
	for itemID,id in pairs(self.children) do
		if itemID == item.id and Menu.getFromID(id).visible then
			if not Menu.getFromID(id).closeTime then
				Menu.getFromID(id).closeTime = getTickCount()
			end
		end
	end	
		
	if self.onItemExit then
		self.onItemExit(item)
	end
end


function Menu:exitHandler()
--[[
	for _,id in pairs(self.children) do
		if Menu.getFromID(id).visible then
			return
		end
	end
]]
	self.mouseState = Menu.mouseStates.off
	
	self:checkAutoClose()

	--self:close()	
	
	if self.onExit then
		self.onExit(self)
	end
end


function Menu:enterHandler()
	self.mouseState = Menu.mouseStates.on
	
	if self.onEnter then
		self.onEnter(self)
	end
end


function Menu:updateMouseState(absoluteX, absoluteY)
	if not isCursorShowing() then
		return
	end
	
	if not absoluteX then
		absoluteX, absoluteY = getCursorPosition()
		
		absoluteX = absoluteX * gScreen.x
		absoluteY = absoluteY * gScreen.y
	end
		
	if self.visible and self.enabled then
		if absoluteX >= self.position.x and absoluteX <= self.position.x + self.width and
			absoluteY >= self.position.y and absoluteY <= self.position.y + self.height then
			if self.mouseState ~= Menu.mouseStates.on then
				self:enterHandler()
			end
		else
			if absoluteX < self.position.x - Menu.egdeBuffer or absoluteX > self.position.x + self.width + Menu.egdeBuffer or
				absoluteY < self.position.y - Menu.egdeBuffer or absoluteY > self.position.y + self.height + Menu.egdeBuffer then
				if self.mouseState == Menu.mouseStates.on then
					self:exitHandler()
				end
			end
		end	
	end
end


function Menu:checkAutoClose()
	if self.parent and not self:isMouseOn(true) then
		self.closeTime = getTickCount()
		
		if not Menu.getFromID(self.parent):isMouseOn() then
			Menu.getFromID(self.parent):checkAutoClose()
		end
	end		
end


addEventHandler("onClientRender", root,
	function()
		local currentTick = getTickCount()
		local done = {}
		for i, menu in ipairs(Menu.instances) do
			if menu.visible then
				if menu.borderColour and menu.borderWidth then
					dxDrawLine(menu.position.x, menu.position.y, menu.position.x + menu.width, menu.position.y, tocolor(unpack(menu.borderColour)), menu.borderWidth, menu.postGUI)
					dxDrawLine(menu.position.x, menu.position.y, menu.position.x, menu.position.y + menu.height, tocolor(unpack(menu.borderColour)), menu.borderWidth, menu.postGUI)
					dxDrawLine(menu.position.x, menu.position.y + menu.height, menu.position.x + menu.width, menu.position.y + menu.height, tocolor(unpack(menu.borderColour)), menu.borderWidth, menu.postGUI)
					dxDrawLine(menu.position.x + menu.width, menu.position.y, menu.position.x + menu.width, menu.position.y + menu.height, tocolor(unpack(menu.borderColour)), menu.borderWidth, menu.postGUI)
				end				

				for k, item in ipairs(menu.items) do
					item:draw()
				end
				
				if menu.scrollable then
					if menu.position.y < 0 then
						dxDrawRectangle(menu.position.x, 0, menu.width, 15, tocolor(0, 0, 0, 255), menu.postGUI)
						
						local section = menu.width / 3
						
						dxDrawLine(menu.position.x + section, menu.scrollHintHeight - 3, menu.position.x + (menu.width / 2), 5, tocolor(255, 255, 255, 255), 1, menu.postGUI)
						dxDrawLine(menu.position.x + section, menu.scrollHintHeight - 5, menu.position.x + (menu.width / 2), 3, tocolor(255, 255, 255, 255), 1, menu.postGUI)
						
						dxDrawLine(menu.position.x + menu.width - section, menu.scrollHintHeight - 3, menu.position.x + (menu.width / 2), 5, tocolor(255, 255, 255, 255), 1, menu.postGUI)
						dxDrawLine(menu.position.x + menu.width - section, menu.scrollHintHeight - 5, menu.position.x + (menu.width / 2), 3, tocolor(255, 255, 255, 255), 1, menu.postGUI)
					end
					
					if menu.position.y + menu.height > gScreen.y then
						dxDrawRectangle(menu.position.x, gScreen.y - 15, menu.width, 15, tocolor(0, 0, 0, 255), menu.postGUI)
						
						local section = menu.width / 3
						
						dxDrawLine(menu.position.x + section, gScreen.y - menu.scrollHintHeight + 5, menu.position.x + (menu.width / 2), gScreen.y - 3, tocolor(255, 255, 255, 255), 1, menu.postGUI)
						dxDrawLine(menu.position.x + section, gScreen.y - menu.scrollHintHeight + 3, menu.position.x + (menu.width / 2), gScreen.y - 5, tocolor(255, 255, 255, 255), 1, menu.postGUI)
						
						dxDrawLine(menu.position.x + menu.width - section, gScreen.y - menu.scrollHintHeight + 5, menu.position.x + (menu.width / 2), gScreen.y - 3, tocolor(255, 255, 255, 255), 1, menu.postGUI)
						dxDrawLine(menu.position.x + menu.width - section, gScreen.y - menu.scrollHintHeight + 3, menu.position.x + (menu.width / 2), gScreen.y - 5, tocolor(255, 255, 255, 255), 1, menu.postGUI)					
					end
					
					if menu:isMouseOn() then
						local x, y = getCursorPosition(true)
						
						if x then
							if (x >= menu.position.x and x <= (menu.position.x + menu.width)) then
								if (y < menu.scrollHintHeight) then
									menu.position.y = menu.position.y + 3

									if menu.position.y > 0 then
										menu.position.y = 0
									end			

									menu:calculateItemPositions()
								elseif (y > (gScreen.y - menu.scrollHintHeight)) then
									menu.position.y = menu.position.y - 3
									
									if menu.position.y + menu.height < gScreen.y then
										menu.position.y = gScreen.y - menu.height
									end								
									
									menu:calculateItemPositions()
								end
							end
						end
					end
				end
			end
			
			if menu.closeTime then
				if currentTick > menu.closeTime + Menu.closingTime then
					if not menu:isMouseOn(true) then
						menu.closeTime = nil
						menu:close()
					end
				end
			end
		end
	end
)


function updateMouseState(relativeX, relativeY, absoluteX, absoluteY)
	if not isCursorShowing() then
		return
	end
	
	for i, menu in ipairs(Menu.instances) do
		menu:updateMouseState(absoluteX, absoluteY)
	end
end
addEventHandler("onClientCursorMove", root, updateMouseState)



function menuClick(button, state, absoluteX, absoluteY)
	if button == "left" and state == "up" then
		for i, menu in ipairs(Menu.instances) do
			if menu.visible and not menu.parent and not menu:isMouseOn(true) then
				menu:close()
			end
		end			
	end
end


addEventHandler("onClientKey", root,
	function(button, pressed)
		if (button == "mouse_wheel_up" or button == "mouse_wheel_down") and pressed then
			for _, menu in ipairs(Menu.instances) do
				if menu.visible and menu.scrollable and menu:isMouseOn() then
					if button == "mouse_wheel_up" then
						menu.position.y = menu.position.y + 20
						
						if menu.position.y > 0 then
							menu.position.y = 0
						end						
					else
						menu.position.y = menu.position.y - 20
						
						if menu.position.y + menu.height < gScreen.y then
							menu.position.y = gScreen.y - menu.height
						end
					end

					menu:calculateItemPositions()
				end
			end				
		end
	end
)