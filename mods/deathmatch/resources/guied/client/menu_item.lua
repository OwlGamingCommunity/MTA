--[[--------------------------------------------------
	GUI Editor
	client
	menu_item.lua
	
	handles the right click menu items
--]]--------------------------------------------------

gCharacterKeys = table.create({ 
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	--"backspace", "enter", "space", "lshift", "rshift", "lctrl", "rctrl", "capslock", 
	"[", "]", ";", ",", "-", "_", ".", "/", "#", "\\", "=" 
}, true)


gItemTypes = {
	item = 0,
	text = 1,
	slider = 2,
	radio = 3,
	toggle = 4,
}


--[[----------------------------------------------
	main menu item class
	holds functionality common to all types of menu item
]]------------------------------------------------

MenuItem = {}
MenuItem.__index = MenuItem
MenuItem.instances = {}

MenuItem.getFromID = function(id) return MenuItem.instances[id] end

MenuItem.get = 
	function(conditions) 
		for _,item in ipairs(MenuItem.instances) do
			local match = true
			
			for _, condition in ipairs(conditions) do
				if item[condition.property] ~= condition.value then
					match = false
					break
				end
			end
			
			if match then
				return item
			end
		end
	end

function MenuItem:create()
	local new = setmetatable(
		{
			position = {x = 0, y = 0},
			textColour = {255, 255, 255, 255},
			textHighlightColour = {unpack(gColours.primary)},
			backgroundColour = {0, 0, 0, 160},
			backgroundHighlightColour = {0, 0, 0, 170},
			borderHighlightColour = {0, 0, 0, 80},
			borderHighlightWidth = 1,	
			height = 15,
			width = 0,
			padding = {left = 5, right = 5, top = 3, bottom = 3},
			mouseState = Menu.mouseStates.off,
			menu = false,
			clickable = true,
			enabled = true,
			onClickClose = true,
			id = #MenuItem.instances + 1,
			itemType = gItemTypes.item,
			borderWidth = {bottom = 1},
			borderColour = {0, 0, 0, 20},
			
			buttonMouseState = Menu.mouseStates.off,
			buttonColour = tocolor(220, 220, 220, 200),
			buttonHoverColour = tocolor(255, 255, 255, 255),
		},
		MenuItem
	)
	
	MenuItem.instances[#MenuItem.instances + 1] = new
	
	return new
end


function MenuItem:draw()
	if not self:visible() then
		return
	end
		
	dxDrawRectangle(self.position.x, self.position.y, self.width, self.height, tocolor(unpack(self.mouseState == Menu.mouseStates.off and self.backgroundColour or self.backgroundHighlightColour)), self.menu.postGUI)
	
	if self.borderColour and self.borderWidth then
		if type(self.borderWidth) == "number" then
			dxDrawLine(self.position.x, self.position.y, self.position.x + self.width, self.position.y, tocolor(unpack(self.borderColour)), self.borderWidth, self.menu.postGUI)
			dxDrawLine(self.position.x, self.position.y, self.position.x, self.position.y + self.height, tocolor(unpack(self.borderColour)), self.borderWidth, self.menu.postGUI)
			dxDrawLine(self.position.x, self.position.y + self.height, self.position.x + self.width, self.position.y + self.height, tocolor(unpack(self.borderColour)), self.borderWidth, self.menu.postGUI)
			dxDrawLine(self.position.x + self.width, self.position.y, self.position.x + self.width, self.position.y + self.height, tocolor(unpack(self.borderColour)), self.borderWidth, self.menu.postGUI)
		elseif type(self.borderWidth) == "table" then
			if self.borderWidth.top then
				dxDrawLine(self.position.x, self.position.y, self.position.x + self.width, self.position.y, tocolor(unpack(self.borderColour)), self.borderWidth.top, self.menu.postGUI)
			end
			
			if self.borderWidth.left then
				dxDrawLine(self.position.x, self.position.y, self.position.x, self.position.y + self.height, tocolor(unpack(self.borderColour)), self.borderWidth.left, self.menu.postGUI)
			end	

			if self.borderWidth.bottom then
				dxDrawLine(self.position.x, self.position.y + self.height, self.position.x + self.width, self.position.y + self.height, tocolor(unpack(self.borderColour)), self.borderWidth.bottom, self.menu.postGUI)
			end	

			if self.borderWidth.right then
				dxDrawLine(self.position.x + self.width, self.position.y, self.position.x + self.width, self.position.y + self.height, tocolor(unpack(self.borderColour)), self.borderWidth.right, self.menu.postGUI)
			end			
		end
	end	
	
	if self.borderHighlightColour and self.borderHighlightWidth and self.mouseState == Menu.mouseStates.on then
		dxDrawLine(self.position.x, self.position.y, self.position.x + self.width, self.position.y, tocolor(unpack(self.borderHighlightColour)), self.borderHighlightWidth, self.menu.postGUI)
		dxDrawLine(self.position.x, self.position.y, self.position.x, self.position.y + self.height, tocolor(unpack(self.borderHighlightColour)), self.borderHighlightWidth, self.menu.postGUI)
		dxDrawLine(self.position.x, self.position.y + self.height, self.position.x + self.width, self.position.y + self.height, tocolor(unpack(self.borderHighlightColour)), self.borderHighlightWidth, self.menu.postGUI)
		dxDrawLine(self.position.x + self.width, self.position.y, self.position.x + self.width, self.position.y + self.height, tocolor(unpack(self.borderHighlightColour)), self.borderHighlightWidth, self.menu.postGUI)
	end
	
	if self.menu and self.menu.children[self.id] then
		dxDrawImage(self.position.x + self.width - 8 - self.padding.right, self.position.y + (self.height / 2) - 4, 8, 8, "images/dx_elements/slider_end.png", 180, 0, 0, tocolor(255, 255, 255, 255), self.menu.postGUI)
	elseif self.button then
		if self.buttonShowOnHover then
			if self.mouseState == Menu.mouseStates.on then
				dxDrawImage(self.position.x + self.width - 10 - self.padding.right, self.position.y + 2, 14, 14, self.button, 0, 0, 0, self.buttonMouseState == Menu.mouseStates.on and self.buttonHoverColour or self.buttonColour, self.menu.postGUI)		
			end
		else
			if self.buttonMouseState == Menu.mouseStates.on then
				dxDrawImage(self.position.x + self.width - 10 - self.padding.right, self.position.y + 2, 14, 14, self.button, 0, 0, 0, self.buttonMouseState == Menu.mouseStates.on and self.buttonHoverColour or self.buttonColour, self.menu.postGUI)	
			end
		end
	end
end


function MenuItem:setEnabled(enabled)
	self.enabled = enabled
	
	--if not ignoreDX then
		if self.editbox then
			self.editbox:enabled(enabled)
		end
		
		if self.slider then
			self.slider:enabled(enabled)
		end
		
		if self.toggle then
			self.toggle:enabled(enabled)
		end
		
		if self.radios then
			for i,radio in ipairs(self.radios) do
				radio.button:enabled(enabled)
			end
		end
	--end
end


function MenuItem:setPosition(x, y)
	self.position.x = x
	self.position.y = y
end


function MenuItem:usable()
	if self.menu and self.menu.visible and self.clickable and self:visible() then
		return true
	end
	
	return
end

function MenuItem:visible()
	if self.condition then
		if self.conditionArgs then
			local args = self:parseArgs(self.conditionArgs)	
	
			return self.condition(unpack(args))
		else
			return self.condition()
		end
	end
	
	return true
end


function MenuItem:clickHandler()
	if self.onClick then
		if self.onClickArgs then
			local args = self:parseArgs(self.onClickArgs)	

			self.onClick(unpack(args))
		else
			self.onClick(self)
		end
	end
	
	if self.onClickClose then
		if self.menu then
			self.menu:close(true)
		end
	end
end


function MenuItem:downHandler()
	if self.onDown then
		if self.onDownArgs then
			local args = self:parseArgs(self.onDownArgs)	

			self.onDown(unpack(args))
		else
			self.onDown(self)
		end
	end
end


function MenuItem:upHandler()
	if self.onUp then
		if self.onUpArgs then
			local args = self:parseArgs(self.onUpArgs)	

			self.onUp(unpack(args))
		else
			self.onUp(self)
		end
	end
end


function MenuItem:buttonClickHandler()
	if self.onButtonClick then
		if self.onButtonClickArgs then
			local args = self:parseArgs(self.onButtonClickArgs)	

			self.onButtonClick(unpack(args))
		else
			self.onButtonClick(self)
		end
	end
end


function MenuItem:parseArgs(args_)
	local args = {}
	
	for _,arg in ipairs(args_) do
		if arg == "__menu" then
			args[#args + 1] = self.menu
		elseif arg == "__self" then
			args[#args + 1] = self
		elseif arg == "__gui" then
			local gui
			
			if self.menu and self.menu.guiParent then
				gui = self.menu.guiParent	
			elseif self.menu and self.menu:getParent(true) and Menu.getFromID(self.menu:getParent(true)).guiParent then
				gui = Menu.getFromID(self.menu:getParent(true)).guiParent
			else
				gui = false
			end
			
			if gui and type(gui) == "table" and gui.dxType then
				gui = gui.element
			end
			
			args[#args + 1] = gui
		elseif string.find(tostring(arg), "__sibling") then
			local t = split(arg, ":")
			
			local sibling = tonumber(t[2])
		
			if sibling and self.menu and self.menu.items[sibling] then
				args[#args + 1] = MenuItem.getFromID(self.menu.items[sibling + 1].id)
			else
				args[#args + 1] = false
			end
		elseif arg == "__parentItem" then
			if self.menu and self.menu.parent and Menu.getFromID(self.menu.parent) then
				for id, menu in pairs(Menu.getFromID(self.menu.parent).children) do
					if menu == self.menu.id then
						args[#args + 1] = MenuItem.getFromID(id)
						break
					end
				end
			else
				args[#args + 1] = false
			end
		elseif arg == "__value" then
			if self.getValue then
				args[#args + 1] = self:getValue()
			end
		elseif arg == "__guiSelection" then
			if self.menu and self.menu.guiSelection then
				args[#args + 1] = self.menu.guiSelection
			elseif self.menu and self.menu:getParent(true) and Menu.getFromID(self.menu:getParent(true)).guiSelection then
				args[#args + 1] = Menu.getFromID(self.menu:getParent(true)).guiSelection				
			else
				args[#args + 1] = false
			end
		else
			args[#args + 1] = arg
		end
	end	
	
	return args
end


function MenuItem:enterHandler()
	self.mouseState = Menu.mouseStates.on

	if self.onEnter then
		self.onEnter(self)
	end
	
	if self.menu then
		self.menu:itemEnterHandler(self)
	end	
end


function MenuItem:exitHandler()
	self.mouseState = Menu.mouseStates.off
	
	if self.onExit then
		self.onExit(self)
	end
	
	if self.menu then
		self.menu:itemExitHandler(self)
	end
end


function MenuItem:set(t)
	if type(t) == "table" then
		for key,value in pairs(t) do
			if type(value) == "table" then
				if not self[key] then
					self[key] = {}
				end
				
				for k,v in pairs(value) do
					self[key][k] = v
				end
			else
				self[key] = value
			end
		end
	end
	
	return self
end



function MenuItem:setChild(childID)
	if not self.menu then
		return
	end
	
	self.menu.children[self.id] = childID
end



function MenuItem:positionCodeAccept()
	if self.menu then
		if (self.menu.guiParent) or (self.menu:getParent(true) and Menu.getFromID(self.menu:getParent(true)).guiParent) then
			setElementData(self.menu.guiParent or Menu.getFromID(self.menu:getParent(true)).guiParent, "guieditor:positionCode", nil)	
		end

		if self.menu:getParent(true) then
			Menu.getFromID(self.menu:getParent(true)):setEnabled(true)
		end		
	end
	
	if self.editboxCodeWarning then
		self.editboxCodeWarning = nil
	end

	if self.editbox then
		if self.editbox.edit then
			self.editbox.edit.editable = true
		end
	end
end


function MenuItem:positionCodeDecline()	
	if self.menu:getParent(true) then
		Menu.getFromID(self.menu:getParent(true)):setEnabled(true)
	end	
	
	if self.editboxCodeWarning then
		self.editboxCodeWarning = nil
	end	

	if self.editbox then
		if self.editbox.edit then
			self.editbox:stopEditing()	
		end
	end
end



--[[----------------------------------------------
	Menu item with just text
]]------------------------------------------------
MenuItem_Text = {}

setmetatable(MenuItem_Text, {__index = MenuItem})

function MenuItem_Text:create(text, alignment, font, scale)
	local item = MenuItem:create()
	
	alignment = alignment or {}

	item.text = text
	item.alignment = {horizontal = alignment.horizontal or "left", vertical = alignment.vertical or "center"}
	item.font = font or "default"
	item.scale = scale or 1
	item.padding = {left = 5, right = 5, top = 0, bottom = 0}
	item.itemType = gItemTypes.text
	
	local _, count = string.gsub(item.text, "\n", "")
	item.height = item.height + (item.height * count)
	
	item = setmetatable(item, {__index = MenuItem_Text})
	
	if string.find(item.text, "%%value") then
		item.editbox = DX_Editbox:create(0, 0, 0, 0, text)	
		
		item.editbox.alignment = item.alignment
		item.editbox:setReplacement("%%value", item.getValue, item)
		item.editbox.filter = gFilters.charactersBasic
		item.editbox.onEditStart = 
			function()
				if item.cannotEdit then
					return item.editbox:stopEditing()
				end
				--item.menu:setEnabled(false, true)

				if (item.itemID == "dimensionX" or item.itemID == "dimensionY") and item.menu then
					if (item.menu.guiParent) or (item.menu:getParent(true) and Menu.getFromID(item.menu:getParent(true)).guiParent) then
						if getElementData(item.menu.guiParent or Menu.getFromID(item.menu:getParent(true)).guiParent, "guieditor:positionCode")	then
							if item.editboxCodeWarning then
								item.editboxCodeWarning:negative()
							end
							
							if Settings.loaded.position_code_movement_warning.value then
								item.editboxCodeWarning = MessageBox_Continue:create("That element is using lua code to calculate its position, if you set the position now it will overwrite that code.\n\nAre you sure you want to continue?", "Yes", "No")
								item.editboxCodeWarning.onAffirmative = MenuItem.positionCodeAccept
								item.editboxCodeWarning.onAffirmativeArgs = {item}
								item.editboxCodeWarning.onNegative = MenuItem.positionCodeDecline
								item.editboxCodeWarning.onNegativeArgs = {item}
								
								if item.menu:getParent(true) then
									Menu.getFromID(item.menu:getParent(true)):setEnabled(false)
								end
								
								item.editbox:enabled(true)

								item.editbox.edit.editable = false							
								return
							end
						end
					end
				end
				
				if item.onEditStart then
					if item.onEditStartArgs then
						local args = item:parseArgs(item.onEditStartArgs)
						
						item.onEditStart(editbox, unpack(args))
					else
						item.onEditStart(editbox)
					end
				end				

				item.menu:setEnabled(false)
				item.editbox:enabled(true)
			end
			
		item.editbox.onEditStop = 
			function(editbox)
				item.menu:setEnabled(true, true)
				
				if type(item.replaceValue) == "string" then
					item.replaceValue = editbox.edit.text
				end			
				
				if item.onEditStop then
					if item.onEditStopArgs then
						local args = item:parseArgs(item.onEditStopArgs)
						
						item.onEditStop(editbox, unpack(args))
					else
						item.onEditStop(editbox)
					end
				end
			end
			
		item.editbox.onEditStopped = 
			function(editbox)							
				if item.editboxCodeWarning then
					item.editboxCodeWarning:negative()
				end	
			end
			
		item.editbox.onEdited = 
			function(editbox)
				if item.onEdited then
					if item.onEditedArgs then
						local args = item:parseArgs(item.onEditedArgs)
						
						item.onEdited(editbox, unpack(args))
					else
						item.onEdited(editbox)
					end
				end						
			end
	end
	
	return item
end


function MenuItem_Text:setPosition(x, y)
	MenuItem.setPosition(self, x, y)
	
	if self.editbox then
		self.editbox:position(self.position.x + self.padding.left, self.position.y + self.padding.top)
		self.editbox:size(self.width - self.padding.left - self.padding.right, self.height - self.padding.top - self.padding.bottom)
	end
end


function MenuItem_Text:setVisible(visible)
	if self.editbox then
		self.editbox:stopEditing()
		self.editbox:visible(visible)
	end
end


function MenuItem_Text:setText(text)
	self.text = tostring(text)
	
	self.height = 15
	local _, count = string.gsub(self.text, "\n", "")
	self.height = self.height + (self.height * count)	
	
	self.menu:calculateHeight()
end


function MenuItem_Text:getValue(item)
	if self.replaceValue then
		if type(self.replaceValue) == "function" then
			if self.replaceValueArgs then
				local args = self:parseArgs(self.replaceValueArgs)

				return self.replaceValue(unpack(args))
			else			
				return self.replaceValue()
			end
		else
			return self.replaceValue
		end
	end
	
	return ""
end


function MenuItem_Text:enterHandler()
	MenuItem.enterHandler(self)
	
	if self.editbox then
		self.editbox.textColour = self.textHighlightColour
	end
end


function MenuItem_Text:exitHandler()
	MenuItem.exitHandler(self)
	
	if self.editbox then
		self.editbox.textColour = self.textColour
	end
end


function MenuItem_Text:draw()
	if not self:visible() then
		return
	end
	
	MenuItem.draw(self, self.position.x, self.position.y, self.width, self.menu.postGUI)

	if self.editbox then
		self.editbox:draw()
	else
		dxDrawText(
			self.text, 
			self.position.x + self.padding.left, 
			self.position.y + self.padding.top, 
			self.position.x + self.width - self.padding.right, 
			self.position.y + self.height - self.padding.bottom, 		
			tocolor(unpack(self.mouseState == Menu.mouseStates.off and self.textColour or self.textHighlightColour)), 
			self.scale, 
			self.font, 
			self.alignment.horizontal, 
			self.alignment.vertical,
			true,
			false,
			self.menu.postGUI
		)
	end
end





--[[----------------------------------------------
	Menu item with a usable slider bar
]]------------------------------------------------
MenuItem_Slider = {}

setmetatable(MenuItem_Slider, {__index = MenuItem})

function MenuItem_Slider:create(text, alignment, font, scale, maxValue)
	local item = MenuItem:create()
	
	alignment = alignment or {}

	item.text = text
	item.alignment = {horizontal = alignment.horizontal or "left", vertical = alignment.vertical or "top"}
	item.font = font or "default"
	item.scale = scale or 1
	--item.slide = 100
	item.slider = DX_Slider:create(0, 0, 0 ,0)
	item.height = 35
	item.sliderHeight = 16
	item.padding.top = 1
	item.padding.bottom = 1
	item.editbox = DX_Editbox:create(0, 0, 0, 0, text)	
	item.itemType = gItemTypes.slider
	item = setmetatable(item, {__index = MenuItem_Slider})

	item.slider.onChange = item.onSliderChange
	item.slider.onChangeArgs = {item}
	
	if maxValue and type(maxValue) == "number" then
		item.slider.maxValue = maxValue
	end

	item.editbox:setReplacement("%%value", item.getValue, item)
	item.editbox.filter = gFilters.numberInt
	item.editbox.onEditStart = 
		function()
			item.menu:setEnabled(false)
			item.editbox:enabled(true)
			
			if item.onEditStart then
				if item.onEditStartArgs then
					local args = item:parseArgs(item.onEditStartArgs)
						
					item.onEditStart(editbox, unpack(args))
				else
					item.onEditStart(editbox)
				end
			end					
		end
		
	item.editbox.onEditStop = 
		function()
			item.menu:setEnabled(true)
			
			if item.onEditStop then
				if item.onEditStopArgs then
					local args = item:parseArgs(item.onEditStopArgs)
						
					item.onEditStop(editbox, unpack(args))
				else
					item.onEditStop(editbox)
				end
			end			
		end
		
	item.editbox.onEdited = 
		function(editbox)
			item:setValue(editbox.edit.text or 0)
			
			if item.onEdited then
				if item.onEditedArgs then
					local args = item:parseArgs(item.onEditedArgs)
						
					item.onEdited(editbox, unpack(args))
				else
					item.onEdited(editbox)
				end
			end					
		end
	
	return item
end


function MenuItem_Slider:setPosition(x, y)
	MenuItem.setPosition(self, x, y)
	
	self.slider:position(self.position.x + self.padding.left, self.position.y + self.height - self.sliderHeight - self.padding.bottom)
	self.slider:size(self.width - self.padding.left - self.padding.right, self.sliderHeight)

	self.slider:updatePointerPosition(self.slider:value())
	
	self.editbox:position(self.position.x + self.padding.left, self.position.y + self.padding.top)
	self.editbox:size(self.width - self.padding.left - self.padding.right, self.height - self.padding.top - self.padding.bottom)
end


function MenuItem_Slider:setEnabled(enabled)
	MenuItem.setEnabled(self, enabled)
end


function MenuItem_Slider:setVisible(visible)
	self.slider.postGUI = self.menu.postGUI
	self.slider:visible(visible)
	
	self.editbox:stopEditing()
	self.editbox:visible(visible)
end


function MenuItem_Slider:getValue()
	return self.slider:value()
end


function MenuItem_Slider:setValue(value)
	value = tonumber(value)
	
	if value then
		self.slider:value(value)
	else
		outputDebug("Invalid value passed to MenuItem_Slider:setValue( "..tostring(value)..")", "MENU_ITEM")
	end
end


function MenuItem_Slider:onSliderChange()
	if self.onChange then
		local args = self:parseArgs(self.onChangeArgs or {})	
		
		self.onChange(unpack(args))
	end	
end


function MenuItem_Slider:enterHandler()
	MenuItem.enterHandler(self)
	
	self.editbox.textColour = self.textHighlightColour
end


function MenuItem_Slider:exitHandler()
	MenuItem.exitHandler(self)
	
	self.editbox.textColour = self.textColour
end


function MenuItem_Slider:draw()
	if not self:visible() then
		return
	end
	
	MenuItem.draw(self, self.position.x, self.position.y, self.width, self.menu.postGUI)
	--[[
	dxDrawText(
		self.text:gsub("%%value", self.edit and self.edit.text or self:getValue()), 
		self.position.x + self.padding.left, 
		self.position.y + self.padding.top, 
		self.position.x + self.width - self.padding.right, 
		self.position.y + self.height - self.padding.bottom, 		
		tocolor(unpack(self.mouseState == Menu.mouseStates.off and self.textColour or self.textHighlightColour)), 
		self.scale, 
		self.font, 
		self.alignment.horizontal, 
		self.alignment.vertical,
		true,
		false,
		self.menu.postGUI
	)]]

	self.slider:draw()
	self.editbox:draw()
end






--[[----------------------------------------------
	Menu item with a set of radio buttons
]]------------------------------------------------
MenuItem_Radio = {}

setmetatable(MenuItem_Radio, {__index = MenuItem})

function MenuItem_Radio:create(radios, title, scale, font)
	local item = MenuItem:create()
	
	item.radios = {}
	item.height = 20 + (#radios * 15)
	
	item.padding.top = 2
	item.padding.bottom = item.padding.bottom
	item.text = title
	item.scale = scale or 1
	item.font = font or "default"
	item.itemType = gItemTypes.radio
	
	for i,name in ipairs(radios) do
		item.radios[i] = {}
		item.radios[i].name = name	
		item.radios[i].button = DX_Radiobutton:create(0, 0, 0, 0, false)
	end

	gRadioButtonGroupID = gRadioButtonGroupID + 1
	
	item = setmetatable(item, {__index = MenuItem_Radio})

	return item
end


function MenuItem_Radio:setPosition(x, y)
	MenuItem.setPosition(self, x, y)
	
	for i,radio in ipairs(self.radios) do
		radio.button:position(self.position.x + self.padding.left, self.position.y + self.padding.top + (i * 15))
		radio.button:size(16, 16)
	end
end


function MenuItem_Radio:setVisible(visible)
	for _,radio in ipairs(self.radios) do
		radio.button.postGUI = self.menu.postGUI
		radio.button:visible(visible)	
	end	
end


function MenuItem_Radio:getValue()
	for i,radio in ipairs(self.radios) do
		if radio.button:selected() then
			return i
		end
	end
	
	return
end


function MenuItem_Radio:setSelected(index)
	if not index then
		return
	end

	for i,radio in ipairs(self.radios) do
		if i == index then
			radio.button:selected(true)
		else
			radio.button:selected(false)
		end
	end	
end


function MenuItem_Radio:getSelected()
	for i,radio in ipairs(self.radios) do
		if radio.button:selected() then
			return i
		end
	end	
	
	return nil
end


function MenuItem_Radio:clickHandler(ignoreWarning)
	local guiElement
	if self.menu and self.menu:getParent(true) and Menu.getFromID(self.menu:getParent(true)).guiParent then	
		guiElement = Menu.getFromID(self.menu:getParent(true)).guiParent
		
		if guiElement and not isElement(guiElement) and type(guiElement) == "table" and guiElement.dxType then
			guiElement = guiElement.element
		end
		
		if not ignoreWarning then
			if not getElementData(guiElement, "guieditor:relative") and getElementData(guiElement, "guieditor:positionCode") and Settings.loaded.position_code_movement_warning.value then
				local m = MessageBox_Continue:create("That element is using lua code to calculate its position, changing the output type will overwrite that code.\n\nAre you sure you want to continue?", "Yes", "No")
				m.onAffirmative = MenuItem_Radio.clickHandler
				m.onAffirmativeArgs = {self, true}
				return
			end
		end
		
		if getElementData(guiElement, "guieditor:positionCode") then
			setElementData(guiElement, "guieditor:positionCode", nil)
		end	
	end
	

	local selected
	
	for i,radio in ipairs(self.radios) do
		if radio.button:selected() then
			selected = i
			break
		end
	end
	
	if not selected then
		selected = 0
	end
	
	local action = {}
	action[#action + 1] = {}
	action[#action].ufunc = 
		function(s, gui, select) 
			MenuItem_Radio.setSelected(s)
			
			if exists(gui) then
				setElementOutputType(gui, select == 2)
			end
		end
	action[#action].uvalues = {self, guiElement, selected}

	selected = selected + 1
		
	if selected > #self.radios then
		selected = 1
	end
	
	action[#action + 1] = {}
	action[#action].rfunc = 
		function(s, gui, select) 
			MenuItem_Radio.setSelected(s)
			
			if exists(gui) then
				setElementOutputType(gui, select == 2)
			end
		end
	action[#action].rvalues = {self, guiElement, selected}
	
	action.description = "Set radio selection"
	
	UndoRedo.add(action)		
	
	self.radios[selected].button:selected(true)
	
	MenuItem.clickHandler(self)
end


function MenuItem_Radio:draw()
	if not self:visible() then
		return
	end
	
	MenuItem.draw(self, self.position.x, self.position.y, self.width, self.menu.postGUI)

	dxDrawText(
		self.text, 
		self.position.x + self.padding.left, 
		self.position.y + self.padding.top, 
		self.position.x + self.width - self.padding.right, 
		self.position.y + self.height - self.padding.bottom, 		
		tocolor(unpack(self.mouseState == Menu.mouseStates.off and self.textColour or self.textHighlightColour)), 
		self.scale, 
		self.font, 
		"left", 
		"top",
		true,
		false,
		self.menu.postGUI
	)
	
	for i,radio in ipairs(self.radios) do
		dxDrawText(
			radio.name, 
			self.position.x + self.padding.left + 20, 
			self.position.y + self.padding.top + (i * 15), 
			self.position.x + self.width - self.padding.right, 
			self.position.y + self.padding.top + ((i + 1) * 15),
			tocolor(unpack(self.mouseState == Menu.mouseStates.off and self.textColour or self.textHighlightColour)), 
			self.scale, 
			self.font,
			"left",
			"top",
			true,
			false,
			self.menu.postGUI
		)	

		radio.button:draw()
	end
end







--[[----------------------------------------------
	Menu item with a toggleable checkbox
]]------------------------------------------------
MenuItem_Toggle = {}

setmetatable(MenuItem_Toggle, {__index = MenuItem})

function MenuItem_Toggle:create(selected, text, scale, font, alignment)
	local item = MenuItem:create()

	alignment = alignment or {}

	item.text = text
	item.alignment = {horizontal = alignment.horizontal or "left", vertical = alignment.vertical or "center"}
	item.font = font or "default"
	item.scale = scale or 1
	item.toggle = DX_Checkbox:create(0, 0, 0, 0, selected)
	item.toggleWidth = 16
	item.itemType = gItemTypes.toggle
	
	item = setmetatable(item, {__index = MenuItem_Toggle})

	return item
end


function MenuItem_Toggle:setPosition(x, y)
	MenuItem.setPosition(self, x, y)
	
	self.toggle:size(self.toggleWidth, 16)
end


function MenuItem_Toggle:setVisible(visible)
	self.toggle.postGUI = self.menu.postGUI
	self.toggle:visible(visible)
end


function MenuItem_Toggle:getValue()
	return self.toggle:selected()
end


function MenuItem_Toggle:setValue(value)
	self.toggle:selected(value)
end


function MenuItem_Toggle:clickHandler()
	self:setValue(not self:getValue())
	
	if self.onChange then
		if self.onChangeArgs then
			local args = self:parseArgs(self.onChangeArgs)	

			self.onChange(self:getValue(), unpack(args))
		else
			self.onChange(self:getValue())
		end
	end
	
	MenuItem.clickHandler(self)
end


function MenuItem_Toggle:draw()
	if not self:visible() then
		return
	end
	
	MenuItem.draw(self, self.position.x, self.position.y, self.width, self.menu.postGUI)

	if self.alignment.horizontal == "left" then
		dxDrawText(
			self.text, 
			self.position.x + self.padding.left + self.toggleWidth + self.padding.left, 
			self.position.y + self.padding.top, 
			self.position.x + self.width - self.padding.right, 
			self.position.y + self.height, 		
			tocolor(unpack(self.mouseState == Menu.mouseStates.off and self.textColour or self.textHighlightColour)), 
			self.scale, 
			self.font, 
			self.alignment.horizontal, 
			self.alignment.vertical,
			true,
			false,
			self.menu.postGUI
		)
	
		--self.toggle:position(self.position.x + self.width - self.padding.right - self.toggleWidth, self.position.y)
		self.toggle:position(self.position.x + self.padding.left, self.position.y)
	elseif self.alignment.horizontal == "right" then
		dxDrawText(
			self.text, 
			self.position.x + self.padding.left, 
			self.position.y + self.padding.top, 
			self.position.x + self.width - self.padding.right - self.toggleWidth - self.padding.right, 
			self.position.y + self.height, 		
			tocolor(unpack(self.mouseState == Menu.mouseStates.off and self.textColour or self.textHighlightColour)), 
			self.scale, 
			self.font, 
			self.alignment.horizontal, 
			self.alignment.vertical,
			true,
			false,
			self.menu.postGUI
		)	
	
		--self.toggle:position(self.position.x + self.padding.left, self.position.y)
		self.toggle:position(self.position.x + self.width - self.padding.right, self.position.y)
	end

	self.toggle:draw()
end











addEventHandler("onClientCursorMove", root,
	function(relativeX, relativeY, absoluteX, absoluteY)
		if not gEnabled then
			return
		end
	
		if not isCursorShowing() then
			return
		end
		
		for _,item in ipairs(MenuItem.instances) do
			if item:usable() and item.enabled then
				-- inside the item
				if absoluteX > item.position.x and absoluteX < (item.position.x + item.width) and
					absoluteY > item.position.y and absoluteY < (item.position.y + item.height) then
					
					if item.mouseState == Menu.mouseStates.off then
						item:enterHandler()
					end
					
					if item.button then
						if absoluteX > ((item.position.x + item.width) - 15) and absoluteX < (item.position.x + item.width) and
							absoluteY > (item.position.y + 1) and absoluteY < (item.position.y + 15) then
							item.buttonMouseState = Menu.mouseStates.on
						else
							item.buttonMouseState = Menu.mouseStates.off
						end
					end
				else
					if item.lockMouse then
						local x, y = absoluteX, absoluteY
						
						if absoluteX < item.position.x then
							x = item.position.x
						elseif absoluteX > item.position.x + item.width then
							x = item.position.x + item.width
						end
						
						if absoluteY < item.position.y then
							y = item.position.y
						elseif absoluteY > item.position.y + item.height then
							y = item.position.y + item.height
						end			

						setCursorPosition(x, y)
					else
						if item.buttonMouseState == Menu.mouseStates.on then
							item.buttonMouseState = Menu.mouseStates.off
						end
						
						if item.mouseState == Menu.mouseStates.on then
							item:exitHandler()			
						end	
					end
				end
			elseif not item.menu or not item.menu.visible then			
				if item.mouseState == Menu.mouseStates.on then
					item:exitHandler()
				end
			end
		end
	end
)




function menuItemClick(button, state, absoluteX, absoluteY)
	if not isCursorShowing() then
		return
	end
		
	if button == "left" then
		if state == "down" then
			for _,item in ipairs(MenuItem.instances) do
				if item:usable() and item:visible() then
					if item.mouseState == Menu.mouseStates.on then
						item.lockMouse = true
						item:downHandler()
					end
				end
			end			
		elseif state == "up" then
			for _,item in ipairs(MenuItem.instances) do
				if item:usable() and item:visible() then
					if item.lockMouse then
						item.lockMouse = false
						item:upHandler()
					end
					
					if item.buttonMouseState == Menu.mouseStates.on then
						item:buttonClickHandler()
					elseif item.mouseState == Menu.mouseStates.on then
						item:clickHandler()
					end
				end
			end			
		end
	end
end
