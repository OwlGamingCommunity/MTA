--[[--------------------------------------------------
	GUI Editor
	client
	dx_editbox.lua
	
	creates a dx editbox widget for use in the right click menus
--]]--------------------------------------------------

local gKeysPressed = {}
local gCapslock = false

DX_Editbox = {}
DX_Editbox.__index = DX_Editbox
DX_Editbox.instances = {}
DX_Editbox.inUse = 
	function()
		for _,e in ipairs(DX_Editbox.instances) do
			if e:visible() and e.edit then
				return true
			end
		end
		
		return false
	end


function DX_Editbox:create(x, y, w, h, text)
	local new = setmetatable(
		{
			x = x,
			y = y,
			width = w,
			height = h,
			text = text,
			scale = 1,
			font = "default",
			alignment = {
				horizontal = "left",
				vertical = "top"
			},
			textColour = {255, 255, 255, 255},
			backgroundEditColour = {255, 255, 255, 50},
			highlightColour = {255, 255, 255, 50},
			hoverColour = {120, 120, 120, 50},
			caratColour = {0, 0, 200, 255},
			caratBlink = 0,
			filter = gFilters.characters,
			visible_ = false,
			postGUI = true,
			enabled_ = true,
			selected = {},
		},
		DX_Editbox
	)
	
	DX_Editbox.instances[#DX_Editbox.instances + 1] = new
	
	return new
end


function DX_Editbox:getEditableTextDimensions()
	if self.replace then
		local s,e = string.find(self.text, self.replace, 0, false)
		
		if s and e then
			local text = self.text
			local height = dxGetFontHeight(self.scale, self.font)
			local startY = self.y
			
			local prefix = string.sub(text, 1, s - 1)
			local suffix = string.sub(text, e + 1)
			-- find all instances of \n before the %value match
			local _, count = string.gsub(prefix, "\n", "")
			if count and count > 0 then
		
				startY = startY + (height * count)
				
				local s2, e2 = string.find(string.reverse(prefix), "\n", 0, false)
				
				outputDebug("find in (".. string.reverse(prefix) ..") "..tostring(s2), "MULTILINE_EDITBOX")

				if s2 and e2 then
					prefix = string.sub(prefix, -s2)
					outputDebug("prefix: '"..tostring(prefix).."'", "MULTILINE_EDITBOX")
				end
			end
			
			-- count all instances of \n after the %value match
			_, count2 = string.gsub(suffix, "\n", "")

			local startX = dxGetTextWidth(prefix, self.scale, self.font) + self.x			
			local width = dxGetTextWidth(self.edit and self.edit.text or self:getReplacement(), self.scale, self.font)
			
			
			if self.alignment.vertical == "center" then
				startY = (self.y + (self.height / 2)) - ((height * (count + 1 + count2)) / 2) + (height * count)
			-- multi line won't work with this alignment - here's my number, fix later maybe
			elseif self.alignment.vertical == "bottom" then
				startY = self.y + self.height - height
			end
			
			width = math.min(width, self.width - (startX - self.x))
						
			local buffer = 1
			
			return startX - buffer, startY, width + (buffer * 2), height
		else
			--outputDebugString("DX_Editbox:getEditableTextDimensions: error looking for '"..tostring(self.replace).."' in '"..tostring(self.text).."'")
		end	
	end
	
	return self.x, self.y, self.width, self.height
end


function DX_Editbox:getEditCaratPosition()
	return self:getPositionFromCharacterIndex(self.edit.carat)
end


function DX_Editbox:getPositionFromCharacterIndex(index)
	if self.edit then
		local text = string.sub(self.edit.text, 0, index)
		local width = dxGetTextWidth(text, self.scale, self.font)
		
		if width > 0 then
			--width = width + 2
		end
		
		return width
	end	
end


function DX_Editbox:visible(v)
	if v ~= nil then
		self.visible_ = v
	else
		return self.visible_
	end
end


function DX_Editbox:position(x, y)
	if x then
		self.x = x
		self.y = y
	else
		return self.x, self.y
	end
end


function DX_Editbox:size(width, height)
	if width then
		self.width = width
		self.height = height
	else
		return self.width, self.height
	end
end


function DX_Editbox:enabled(value)
	if value ~= nil then
		self.enabled_ = value
	else
		return self.enabled_
	end
end


function DX_Editbox:setReplacement(replace, replaceWith, ...)
	self.replace = replace
	self.replaceWith = replaceWith
	self.replaceWithArgs = {...}
end


function DX_Editbox:getReplacement()
	if self.replaceWithArgs then
		return self.replaceWith(unpack(self.replaceWithArgs))
	else
		return self.replaceWith()
	end
	
	return 
end


function DX_Editbox:startEditing(x, y, w, h)	
	self.edit = {}
																	
	self.edit.x = x
	self.edit.y = y
	self.edit.w = w
	self.edit.h = h
	self.edit.editable = true

	if self.replace then
		self.edit.text = tostring(self:getReplacement())
	else
		self.edit.text = self.text
	end
									
	self.edit.carat = #self.edit.text
	
	if self.onEditStart then
		self.onEditStart()
	end
	
	guiSetInputMode("no_binds")
end


function DX_Editbox:stopEditing()
	if not self.edit then
		return
	end
	
	if self.replace then
		
	else
		self.text = self.edit.text
	end

	if self.onEditStop then
		self.onEditStop(self)
	end

	self.edit = nil
	self.selected = {}
		
	if not DX_Editbox.inUse() then
		guiSetInputMode(gDefaultInputMode)
	end		
	
	if self.onEditStopped then
		self.onEditStopped(self)
	end	
end


function DX_Editbox:onEditedHandler(added)
	if added and not filterInput(self.filter, self.edit.text) then
		self.edit.text = string.sub(self.edit.text, 0, self.edit.carat - 1) .. string.sub(self.edit.text, self.edit.carat +  1)
		self.edit.carat = self.edit.carat - 1
		return
	end

	self.edit.x, self.edit.y, self.edit.w, self.edit.h = self:getEditableTextDimensions()

	if self.onEdited then
		self.onEdited(self)
	end
end


function DX_Editbox:setCaratBlink(alpha)
	self.caratBlink = getTickCount()
	
	if alpha then
		self.caratColour[4] = alpha
	else
		self.caratColour[4] = self.caratColour[4] > 0 and 0 or 255
	end
end


function DX_Editbox:draw()
	if self:visible() then	
		if self.edit then
			dxDrawRectangle(self.edit.x, self.edit.y, self.edit.w, self.edit.h, tocolor(unpack(self.backgroundEditColour)), self.postGUI)

			local w,_,_,_ = self:getEditCaratPosition()
			
			if self.edit.x + w <= self.x + self.width then
				dxDrawLine(0,0,0,0, tocolor(255, 255, 255, 255), 0)
				dxDrawLine(self.edit.x + w, self.edit.y, self.edit.x + w, self.edit.y + self.edit.h, tocolor(unpack(self.caratColour)), 2, self.postGUI)				
			end
		else 
			if self.hovered and self:enabled() then
				local x, y, w, h = self:getEditableTextDimensions()
				dxDrawRectangle(x, y, w, h, tocolor(unpack(self.hoverColour)), self.postGUI)
			end
		end		
				
		local t = ""

		if self.replace then
			t = self.text:gsub(self.replace, self.edit and self.edit.text or self:getReplacement())
		elseif self.edit then
			t = self.edit.text
		else
			t = self.text
		end

		dxDrawText(
			t,
			--self.text:gsub(self.replace or "", (self.edit and self.edit.text) or (self.replaceWith and self.replaceWith()) or ""), 
			self.x, 
			self.y, 
			self.x + self.width, 
			self.y + self.height, 		
			tocolor(unpack(self.textColour)), 
			self.scale, 
			self.font, 
			self.alignment.horizontal, 
			self.alignment.vertical,
			true,
			false,
			self.postGUI
		)
		
		if self.edit then
			if self.selected then
				if self.selected.start and self.selected.finish then
					local x = self:getPositionFromCharacterIndex(math.min(self.selected.start, self.selected.finish))
					local w = self:getPositionFromCharacterIndex(math.max(self.selected.start, self.selected.finish)) - x
					
					dxDrawRectangle(self.edit.x + x, self.edit.y, w, self.edit.h, tocolor(unpack(self.highlightColour)), self.postGUI) 
				end
			end
			
			local w,_,_,_ = self:getEditCaratPosition()
			
			if self.edit.x + w <= self.x + self.width then
				-- fix for bizarre dx line bug
				-- random (or not so random), completely unconnected lines elsewhere on the screen were taking on the 
				-- line width of whatever line was drawn here. So draw with a width of 1 and cross our fingers it happens on something with 1 width
				dxDrawLine(0,0,0,0, tocolor(255, 255, 255, 255), 1, self.postGUI)
				
				dxDrawLine(self.edit.x + w, self.edit.y, self.edit.x + w, self.edit.y + self.edit.h, tocolor(unpack(self.caratColour)), 2, self.postGUI)					
			end
		end			
	end
end


addEventHandler("onClientDoubleClick", root,
	function(button, absoluteX, absoluteY)
		if not gEnabled then
			return
		end
	
		if not isCursorShowing() then
			return
		end
		
		if button == "left" then
			for _,editbox in ipairs(DX_Editbox.instances) do
				if editbox:visible() and editbox:enabled() then
					local x, y, w, h = editbox:getEditableTextDimensions()
										
					if absoluteX > x and absoluteX < (x + w) and
						absoluteY > y and absoluteY < (y + h) then
						if not editbox.edit then
							editbox:startEditing(x, y, w, h)
							break
						end
					else
						if editbox.edit --[[and item.mouseState == Menu.mouseStates.on]] then
							editbox:stopEditing()
							break
						end
					end
				end
			end			
		end	
	end
)



function keyPressed(button, pressed)
	if pressed then
		for _,editbox in ipairs(DX_Editbox.instances) do
			if editbox.edit and editbox:enabled() and (editbox.edit.editable == nil or editbox.edit.editable == true) then
				local used
				
				if button == "arrow_l" then
					if editbox.edit.carat > 0 then
						editbox.edit.carat = editbox.edit.carat - 1
						used = true
					end
				elseif button == "arrow_r" then
					if editbox.edit.carat < #editbox.edit.text then
						editbox.edit.carat = editbox.edit.carat + 1
						used = true
					end
				elseif button == "backspace" then
					if editbox.selected and editbox.selected.start and editbox.selected.finish and math.abs(editbox.selected.finish - editbox.selected.start) > 0 then
						editbox.edit.text = string.sub(editbox.edit.text, 0, math.min(editbox.selected.finish, editbox.selected.start)) .. string.sub(editbox.edit.text, math.max(editbox.selected.finish, editbox.selected.start) + 1)                     
						editbox.edit.carat = math.min(editbox.selected.finish, editbox.selected.start)
						editbox:onEditedHandler()
						used = true			
					elseif editbox.edit.carat > 0 then
						editbox.edit.text = string.sub(editbox.edit.text, 0, editbox.edit.carat - 1) .. string.sub(editbox.edit.text, editbox.edit.carat + 1)                     
						editbox.edit.carat = editbox.edit.carat - 1
						editbox:onEditedHandler()
						used = true
					end
				elseif button == "delete" then
					if editbox.selected and editbox.selected.start and editbox.selected.finish and math.abs(editbox.selected.finish - editbox.selected.start) > 0 then
						editbox.edit.text = string.sub(editbox.edit.text, 0, math.min(editbox.selected.finish, editbox.selected.start)) .. string.sub(editbox.edit.text, math.max(editbox.selected.finish, editbox.selected.start) + 1)                     
						editbox.edit.carat = math.min(editbox.selected.finish, editbox.selected.start)
						editbox:onEditedHandler()
						used = true					
					elseif editbox.edit.carat < #editbox.edit.text then
						editbox.edit.text = string.sub(editbox.edit.text, 0, editbox.edit.carat) .. string.sub(editbox.edit.text, editbox.edit.carat + 2)
						editbox:onEditedHandler()
						used = true
					end
				elseif button == "enter" then
					editbox:stopEditing()
				elseif button == "space" then
					if editbox.selected and editbox.selected.start and editbox.selected.finish and math.abs(editbox.selected.finish - editbox.selected.start) > 0 then
						keyPressed("delete", true)
						keyPressed("delete", false)
					end
					
					editbox.edit.text = string.insert(editbox.edit.text, " ", editbox.edit.carat)
					editbox.edit.carat = editbox.edit.carat + 1
					editbox:onEditedHandler(" ")
					used = true
				elseif button == "capslock" then
					--gCapslock = not gCapslock
				elseif button == "home" then
					editbox.edit.carat = 0
				elseif button == "end" then
					editbox.edit.carat = #editbox.edit.text
				elseif gCharacterKeys[button] or gCharacterKeys[string.lower(button)] then
					if editbox.selected and editbox.selected.start and editbox.selected.finish and math.abs(editbox.selected.finish - editbox.selected.start) > 0 then
						keyPressed("delete", true)
						keyPressed("delete", false)
					end
					
					--editbox.edit.text = string.insert(editbox.edit.text, gCapslock and string.upper(button) or button, editbox.edit.carat)
					editbox.edit.text = string.insert(editbox.edit.text, button, editbox.edit.carat)
					
					editbox.edit.carat = editbox.edit.carat + 1
					
					--editbox:onEditedHandler(gCapslock and string.upper(button) or button)
					editbox:onEditedHandler(button)
					used = true
				end
				
				if used then
					editbox:setCaratBlink(255)
					editbox.selected = {}
					
					if not gKeysPressed[button] then
						gKeysPressed[button] = getTickCount() + 500
					else
						gKeysPressed[button] = getTickCount()
					end
				end
			end
		end	
	else
		if gKeysPressed[button] then
			gKeysPressed[button] = nil
		end
	end
end
addEventHandler("onClientKey", root, 
	function(button, pressed)
		if not gEnabled then
			return
		end
	
		-- let onClientCharacter handle the single characters
		if not gCharacterKeys[button] then
			keyPressed(button, pressed)
		end
	end
)
addEventHandler("onClientCharacter", root,
	function(c)
		if not gEnabled then
			return
		end
	
		keyPressed(c, true)
		keyPressed(c, false)
	end
)


addEventHandler("onClientRender", root,
	function()
		if not gEnabled then
			return
		end
	
		local currentTick = getTickCount()
		
		for _,editbox in ipairs(DX_Editbox.instances) do
			if editbox.edit then		
				if currentTick > (editbox.caratBlink + 400) then
					editbox:setCaratBlink()
				end
			end
		end
		
		for key,tick in pairs(gKeysPressed) do
			if currentTick > (tick + 40) then
				keyPressed(key, true)
			end	
		end
	end
)


addEventHandler("onClientClick", root,
	function(button, state, absoluteX, absoluteY)
		if not gEnabled then
			return
		end
	
		if not isCursorShowing() then
			return
		end
		
		if button == "left" and state == "down" then
			for _,editbox in ipairs(DX_Editbox.instances) do	
				if editbox.edit and editbox:enabled() then	
					editbox.selected = {}
					
					local x, y, w, h = editbox:getEditableTextDimensions()
											
					--if absoluteX > x and absoluteX < (x + w) and
					--	absoluteY > y and absoluteY < (y + h) then
					if absoluteY > y and absoluteY < (y + h) then	
						local aX = absoluteX
						
						if absoluteX < x then
							aX = x
						elseif absoluteX > (x + w) then
							aX = x + w
						end
						
						local diff = aX - x
						
						for i = 1, #editbox.edit.text do
							local text = string.sub(editbox.edit.text, 0, i)
							local width = dxGetTextWidth(text, editbox.scale, editbox.font)
							
							if width > diff then							
								local char = string.sub(editbox.edit.text, i, i)
								local charWidth = dxGetTextWidth(char, editbox.scale, editbox.font)	
								
								if (width - (charWidth / 2)) > diff then
									editbox.edit.carat = i - 1
									editbox:setCaratBlink(255)
									break
								else
									editbox.edit.carat = i 
									editbox:setCaratBlink(255)
									break
								end
							end
						end
						
						editbox.dragging = {tick = getTickCount()}
						editbox.selected.start = editbox.edit.carat
					end
				end
			end	
		elseif button == "left" and state == "up" then
			for _,editbox in ipairs(DX_Editbox.instances) do
				if editbox.dragging then	
					editbox.dragging = nil
				end
			end
		end
	end
)


addEventHandler("onClientCursorMove", root,
	function(x, y, absoluteX, absoluteY)
		if not gEnabled then
			return
		end

		for _,editbox in ipairs(DX_Editbox.instances) do
			if editbox:visible() then
				local x, y, w, h = editbox:getEditableTextDimensions()
										
				if absoluteX > x and absoluteX < (x + w) and
					absoluteY > y and absoluteY < (y + h) then
					editbox.hovered = true
					
					if editbox.edit and editbox.dragging and editbox.dragging.tick < (getTickCount() - 100) then
						local diff = absoluteX - x
						
						for i = 1, #editbox.edit.text do
							local text = string.sub(editbox.edit.text, 0, i)
							local width = dxGetTextWidth(text, editbox.scale, editbox.font)
							
							if width > diff then							
								local char = string.sub(editbox.edit.text, i, i)
								local charWidth = dxGetTextWidth(char, editbox.scale, editbox.font)	
								
								if (width - (charWidth / 2)) > diff then
									editbox.selected.finish = i - 1
									break
								else
									editbox.selected.finish = i 
									break
								end
							end
						end	
					end
				else
					editbox.hovered = false
				end
			end
		end
	end
)