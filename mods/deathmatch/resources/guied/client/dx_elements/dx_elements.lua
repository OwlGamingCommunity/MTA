--[[--------------------------------------------------
	GUI Editor
	client
	dx_elements.lua
	
	handles dx line, rectangle, image and text management within the editor
--]]--------------------------------------------------


gDXTypes = {line = 1, rectangle = 2, image = 3, text = 4}
gDXAnchor = {topLeft = 1, topRight = 2, bottomLeft = 3, bottomRight = 4}
local gDXTypeString = {"dx_line", "dx_rectangle", "dx_image", "dx_text"}
local gDXTypeFriendlyString = {"DX Line", "DX Rectangle", "DX Image", "DX Text"}

DX_Element = {}
DX_Element.__index = DX_Element
DX_Element.instances = {}
DX_Element.currentID = 1
DX_Element.ids = {}

DX_Element.getType = 
	function(id)
		return gDXTypeString[id]
	end
	
DX_Element.getTypeFriendly = 
	function(id)
		return gDXTypeFriendlyString[id]
	end	
	
DX_Element.getDXFromElement = 
	function(element)
		if exists(element) then
			local dx = getElementData(element, "guieditor.internal:dxElement")
			
			if dx then
				dx = DX_Element.ids[dx]
					
				return dx
			end
		end
	end
	
DX_Element.reorder = 
	function()
		for i,dx in ipairs(DX_Element.instances) do
			dx.order_ = i
		end	
	end



function DX_Element:create()
	DX_Element.currentID = DX_Element.currentID + 1
	
	local new = setmetatable(
		{
			order_ = #DX_Element.instances + 1,
			id = DX_Element.currentID,
		},
		DX_Element
	)
	
	DX_Element.instances[#DX_Element.instances + 1] = new
	DX_Element.ids[DX_Element.currentID] = new
	
	return new
end


function DX_Element:colour(r, g, b, a)
	if r and g and b then
		self.colour_ = {r, g, b, a or 255}
	else
		return unpack(self.colour_)
	end
end	


function DX_Element:order(newOrder)
	if newOrder then
		table.remove(DX_Element.instances, self.order_)
		table.insert(DX_Element.instances, newOrder, self)

		DX_Element.reorder()
	else
		return self.order_
	end
end


function DX_Element:orderMoveUp()
	if self:order() < #DX_Element.instances then
		self:order(self:order() + 1)
	end
end


function DX_Element:orderMoveDown()
	if self:order() > 1 then
		self:order(self:order() - 1)
	end
end


function DX_Element:dxRemove(hardRemove)
	if not self.removed then
		table.remove(DX_Element.instances, self:order())
		
		if not hardRemove then
			self.removed = true
			self.orderSaved = self:order()
		else
			self = nil
		end
		
		DX_Element.reorder()
	end
end


function DX_Element:dxRestore()
	if self.removed then	
		self.removed = nil
		
		-- make sure the table gets properly ordered
		if self.orderSaved > 1 and #DX_Element.instances < self.orderSaved then
			while (#DX_Element.instances < self.orderSaved) do
				self.orderSaved = self.orderSaved - 1
				
				if self.orderSaved <= 1 then
					break
				end
			end
		end
		
		table.insert(DX_Element.instances, self.orderSaved, self)
		
		DX_Element.reorder()
	end
end


function DX_Element:postGUI(value)
	if value ~= nil then
		self.postGUI_ = value
	else
		return self.postGUI_
	end
end


function DX_Element:set(key, value)
	self[key] = value
end


function DX_Element:setX(value, ignoreUndo)
	if value then
		if not ignoreUndo then
			local action = {}
									
			action[#action + 1] = {}
			action[#action].ufunc = 
				function(d, a)
					d:setX(a, true)
				end
			action[#action].uvalues = {self, self.x}
							
			action[#action + 1] = {}
			action[#action].rfunc = 
				function(d, a)
					d:setX(a, true)
				end
			action[#action].rvalues = {self, tonumber(value) or self.x}				
			
			action.description = "DX X ("..tostring(tonumber(value) or self.x)..")"
			
			UndoRedo.add(action)
		end
		
		self.x = tonumber(value) or self.x
		
		guiSetPosition(self.element, self.x, self.y, false)
	end
end


function DX_Element:setY(value, ignoreUndo)
	if value then
		if not ignoreUndo then
			local action = {}
							
			action[#action + 1] = {}
			action[#action].ufunc = 
				function(d, a)
					d:setY(a, true)
				end
			action[#action].uvalues = {self, self.y}
							
			action[#action + 1] = {}
			action[#action].rfunc = 
				function(d, a)
					d:setY(a, true)
				end
			action[#action].rvalues = {self, tonumber(value) or self.y}				
			
			action.description = "DX Y ("..tostring(tonumber(value) or self.y)..")"
			
			UndoRedo.add(action)
		end
		
		self.y = tonumber(value) or self.y
		
		guiSetPosition(self.element, self.x, self.y, false)
	end
end


function DX_Element:setWidth(value, ignoreUndo)
	if value then
		if not ignoreUndo then
			local action = {}
							
			action[#action + 1] = {}
			action[#action].ufunc = 
				function(d, a)
					d:setWidth(a, true)
				end
			action[#action].uvalues = {self, self.width}
							
			action[#action + 1] = {}
			action[#action].rfunc = 
				function(d, a)
					d:setWidth(a, true)
				end
			action[#action].rvalues = {self, tonumber(value) or self.width}		

			action.description = "DX width ("..tostring(tonumber(value) or self.width)..")"
			
			UndoRedo.add(action)
		end
		
		self.width = tonumber(value) or self.width
		
		if self.width and self.height then
			guiSetSize(self.element, self.width, self.height, false)
		end
	end
end


function DX_Element:setHeight(value, ignoreUndo)
	if value then
		if not ignoreUndo then
			local action = {}
							
			action[#action + 1] = {}
			action[#action].ufunc = 
				function(d, a)
					d:setHeight(a, true)
				end
			action[#action].uvalues = {self, self.height}
							
			action[#action + 1] = {}
			action[#action].rfunc = 
				function(d, a)
					d:setHeight(a, true)
				end
			action[#action].rvalues = {self, tonumber(value) or self.height}				
			
			action.description = "DX height ("..tostring(tonumber(value) or self.height)..")"
			
			UndoRedo.add(action)
		end
		
		self.height = tonumber(value) or self.height
		
		if self.width and self.height then
			guiSetSize(self.element, self.width, self.height, false)
		end
	end
end


function DX_Element:shadow(value)
	if value ~= nil then
		local action = {}
						
		action[#action + 1] = {}
		action[#action].ufunc = 
			function(d, s)
				d.shadow_ = s
			end
		action[#action].uvalues = {self, self.shadow_}
						
		action[#action + 1] = {}
		action[#action].rfunc = 
			function(d, s)
				d.shadow_ = s
			end
		action[#action].rvalues = {self, value}				

		action.description = "Set " .. tostring(DX_Element.getTypeFriendly(self.dxType)) .. " shadow ("..tostring(value)..")"
		
		UndoRedo.add(action)	
	
		self.shadow_ = value
	else
		return self.shadow_
	end
end	


function DX_Element:outline(value)
	if value ~= nil then
		local action = {}
						
		action[#action + 1] = {}
		action[#action].ufunc = 
			function(d, o)
				d.outline_ = o
			end
		action[#action].uvalues = {self, self.outline_}
						
		action[#action + 1] = {}
		action[#action].rfunc = 
			function(d, o)
				d.outline_ = o
			end
		action[#action].rvalues = {self, value}				

		action.description = "Set " .. tostring(DX_Element.getTypeFriendly(self.dxType)) .. " outline ("..tostring(value)..")"
		
		UndoRedo.add(action)	
	
		self.outline_ = value
	else
		return self.outline_
	end
end


function DX_Element:match(other)
	return false
end




DX_Line = {}
setmetatable(DX_Line, {__index = DX_Element})

function DX_Line:create(startX, startY, endX, endY, colour, width, postGUI, element)
	local item = DX_Element:create()
	
	item.startX = startX
	item.startY = startY
	item.endX = endX
	item.endY = endY
	item.width = width
	item.colour_ = colour
	item.postGUI_ = postGUI
	item.dxType = gDXTypes.line
	item.anchor = gDXAnchor.topLeft
	item.element = element

	item = setmetatable(item, {__index = DX_Line})
	
	return item
end


function DX_Line:recalculateGUIPosition()		
	if self.startX <= self.endX then
		if self.startY <= self.endY then
			self.anchor = gDXAnchor.topLeft
		else
			self.anchor = gDXAnchor.bottomLeft
		end
	else
		if self.startY <= self.endY then
			self.anchor = gDXAnchor.topRight
		else
			self.anchor = gDXAnchor.bottomRight
		end					
	end	
	
	local x, y = math.min(self.startX, self.endX), math.min(self.startY, self.endY)
	local w, h = math.max(self.startX, self.endX) - math.min(self.startX, self.endX), math.max(self.startY, self.endY) - math.min(self.startY, self.endY)
	guiSetPosition(self.element, x, y, false) guiSetSize(self.element, w, h, false)	
end


function DX_Line:setStartX(value, ignoreUndo)
	if value then
		if not ignoreUndo then
			local action = {}
							
			action[#action + 1] = {}
			action[#action].ufunc = 
				function(d, a)
					d:setStartX(a, true)
				end
			action[#action].uvalues = {self, self.startX}
							
			action[#action + 1] = {}
			action[#action].rfunc = 
				function(d, a)
					d:setStartX(a)
				end
			action[#action].rvalues = {self, tonumber(value) or self.startX}				
			
			action.description = "DX line Start X ("..tostring(tonumber(value) or self.startX)..")"
			
			UndoRedo.add(action)
		end
		
		self.startX = tonumber(value) or self.startX
		
		if self.dxType == gDXTypes.line then
			self:recalculateGUIPosition()
		end			
	end
end


function DX_Line:setStartY(value, ignoreUndo)
	if value then
		if not ignoreUndo then
			local action = {}
							
			action[#action + 1] = {}
			action[#action].ufunc = 
				function(d, a)
					d:setStartY(a)
				end
			action[#action].uvalues = {self, self.startY}
							
			action[#action + 1] = {}
			action[#action].rfunc = 
				function(d, a)
					d:setStartY(a)
				end
			action[#action].rvalues = {self, tonumber(value) or self.startY}				
			
			action.description = "DX line Start Y ("..tostring(tonumber(value) or self.startY)..")"
			
			UndoRedo.add(action)
		end
		
		self.startY = tonumber(value) or self.startY
		
		if self.dxType == gDXTypes.line then
			self:recalculateGUIPosition()
		end	
	end
end


function DX_Line:setEndX(value, ignoreUndo)
	if value then
		if not ignoreUndo then
			local action = {}
							
			action[#action + 1] = {}
			action[#action].ufunc = 
				function(d, a)
					d:setEndX(a)
				end
			action[#action].uvalues = {self, self.endX}
							
			action[#action + 1] = {}
			action[#action].rfunc = 
				function(d, a)
					d:setEndX(a)
				end
			action[#action].rvalues = {self, tonumber(value) or self.endX}				
			
			action.description = "DX line End X ("..tostring(tonumber(value) or self.endX)..")"
			
			UndoRedo.add(action)
		end
		
		self.endX = tonumber(value) or self.endX
		
		if self.dxType == gDXTypes.line then
			self:recalculateGUIPosition()
		end	
	end
end


function DX_Line:setEndY(value, ignoreUndo)
	if value then
		if not ignoreUndo then
			local action = {}
							
			action[#action + 1] = {}
			action[#action].ufunc = 
				function(d, a)
					d:setEndY(a)
				end
			action[#action].uvalues = {self, self.endY}
							
			action[#action + 1] = {}
			action[#action].rfunc = 
				function(d, a)
					d:setEndY(a)
				end
			action[#action].rvalues = {self, tonumber(value) or self.endY}				
			
			action.description = "DX line End Y ("..tostring(tonumber(value) or self.endY)..")"
			
			UndoRedo.add(action)
		end
		
		self.endY = tonumber(value) or self.endY
		
		if self.dxType == gDXTypes.line then
			self:recalculateGUIPosition()
		end	
	end
end


DX_Rectangle = {}
setmetatable(DX_Rectangle, {__index = DX_Element})

function DX_Rectangle:create(x, y, width, height, colour, postGUI, element)
	local item = DX_Element:create()
	
	item.x = x
	item.y = y
	item.width = width
	item.height = height
	item.colour_ = colour
	item.postGUI_ = postGUI
	item.dxType = gDXTypes.rectangle
	item.element = element
	item.shadow_ = false
	item.shadowColour_ = {0, 0, 0, 255}
	item.outline_ = false
	item.outlineColour_ = {0, 0, 0, 255}

	item = setmetatable(item, {__index = DX_Rectangle})
	
	return item
end


function DX_Rectangle:match(other)
	return (self.dxType == other.dxType and
			self.postGUI_ == other.postGUI_) or 
			(other.dxType == gDXTypes.line and
			self.postGUI_ == other.postGUI_)
end


function DX_Rectangle:isShadow(other)
	--[[
	return self.dxType == other.dxType and
			self.x == other.x - 1 and 
			self.y == other.y - 1 and
			self.width == other.width and 
			self.height == other.height and
			other.colour_[1] == 0 and 
			other.colour_[2] == 0 and 
			other.colour_[3] == 0 and 
			other.colour_[4] == 255
	]]
	
	if other.dxType == gDXTypes.line then
			--other.colour_[1] == 0 and
			--other.colour_[2] == 0 and 
			--other.colour_[3] == 0 and 
			--other.colour_[4] == 255 then
			
				 -- bottomLeft >
			if (self.x - 1 == other.startX and 
				 self.y + self.height == other.startY and
				 self.x + self.width == other.endX and
				 self.y + self.height == other.endY) then 	
				return gDXAnchor.bottomLeft
			end
			
				 -- bottomRight ^
			if (self.x + self.width == other.startX and 
				 self.y + self.height == other.startY and
				 self.x + self.width == other.endX and
				 self.y - 1 == other.endY) then 
				return gDXAnchor.bottomRight
			end
	end
	
	return	
end


function DX_Rectangle:isOutline(other)
	--[[ rectangle
	return self.x == other.x + 1 and
			self.y == other.y + 1 and
			self.width == other.width - 2 and
			self.height == other.height - 2 and
			other.colour_[1] == 0 and
			other.colour_[2] == 0 and 
			other.colour_[3] == 0 and 
			other.colour_[4] == 255
	]]
	
	if other.dxType == gDXTypes.line then
			--other.colour_[1] == 0 and
			--other.colour_[2] == 0 and 
			--other.colour_[3] == 0 and 
			--other.colour_[4] == 255 then
			
				-- topLeft \/
			if (self.x - 1 == other.startX and 
				 self.y - 1 == other.startY and
				 self.x - 1 == other.endX and
				 self.y + self.height == other.endY) then
				return gDXAnchor.topLeft
			end
				
				 -- topRight <
			if (self.x + self.width == other.startX and 
				 self.y - 1 == other.startY and
				 self.x - 1 == other.endX and
				 self.y - 1 == other.endY) then 
				return gDXAnchor.topRight
			end
			
				 -- bottomLeft >
			if (self.x - 1 == other.startX and 
				 self.y + self.height == other.startY and
				 self.x + self.width == other.endX and
				 self.y + self.height == other.endY) then 	
				return gDXAnchor.bottomLeft
			end
			
				 -- bottomRight ^
			if (self.x + self.width == other.startX and 
				 self.y + self.height == other.startY and
				 self.x + self.width == other.endX and
				 self.y - 1 == other.endY) then 
				return gDXAnchor.bottomRight
			end
	end
	
	return
end


DX_Image = {}
setmetatable(DX_Image, {__index = DX_Element})

function DX_Image:create(x, y, width, height, filepath, rotation, rotationOffsetX, rotationOffsetY, colour, postGUI, element)
	local item = DX_Element:create()
	
	item.x = x
	item.y = y
	item.width = width
	item.height = height
	item.filepath = filepath
	item.rotation_ = rotation
	item.rOffsetX_ = rotationOffsetX
	item.rOffsetY_ = rotationOffsetY
	item.colour_ = colour
	item.postGUI_ = postGUI
	item.dxType = gDXTypes.image
	item.element = element

	item = setmetatable(item, {__index = DX_Image})
	
	return item
end


function DX_Image:rotation(value)
	if value then
		self.rotation_ = value
	else
		return self.rotation_
	end
end	


function DX_Image:rOffsetX(value)
	if value then
		local action = {}
						
		action[#action + 1] = {}
		action[#action].ufunc = 
			function(d, a)
				d.rOffsetX_ = a
			end
		action[#action].uvalues = {self, self.rOffsetX_}
						
		action[#action + 1] = {}
		action[#action].rfunc = 
			function(d, a)
				d.rOffsetX_ = a
			end
		action[#action].rvalues = {self, tonumber(value) or self.rOffsetX_}				
		
		action.description = "Set DX rot offset x ("..tostring(tonumber(value) or self.rOffsetX_)..")"
		
		UndoRedo.add(action)		
	
		self.rOffsetX_ = value
	else
		return self.rOffsetX_
	end
end	


function DX_Image:rOffsetY(value)
	if value then
		local action = {}
						
		action[#action + 1] = {}
		action[#action].ufunc = 
			function(d, a)
				d.rOffsetY_ = a
			end
		action[#action].uvalues = {self, self.rOffsetY_}
						
		action[#action + 1] = {}
		action[#action].rfunc = 
			function(d, a)
				d.rOffsetY_ = a
			end
		action[#action].rvalues = {self, tonumber(value) or self.rOffsetY_}				
		
		action.description = "Set DX rot offset y ("..tostring(tonumber(value) or self.rOffsetY_)..")"
		
		UndoRedo.add(action)		
		
		self.rOffsetY_ = value
	else
		return self.rOffsetY_
	end
end	


DX_Text = {}
setmetatable(DX_Text, {__index = DX_Element})

function DX_Text:create(text, x, y, width, height, colour, scale, font, alignX, alignY, clip, wordwrap, postGUI, colourCoded, subPixelPositioning, element)
	local item = DX_Element:create()

	item.text_ = text
	item.x = x
	item.y = y
	item.width = width
	item.height = height
	item.colour_ = colour
	item.scale_ = scale
	item.font_ = font
	item.alignX_ = alignX
	item.alignY_ = alignY
	item.clip_ = clip
	item.wordwrap_ = wordwrap
	item.postGUI_ = postGUI
	item.colourCoded_ = colourCoded
	item.subPixelPositioning = subPixelPositioning
	item.dxType = gDXTypes.text
	item.element = element
	item.shadow_ = false
	item.shadowColour_ = {0, 0, 0, 255}
	item.outline_ = false
	item.outlineColour_ = {0, 0, 0, 255}
	
	item = setmetatable(item, {__index = DX_Text})
	
	return item
end


function DX_Text:text(value)
	if value then
		self.text_ = value
	else
		return self.text_
	end
end	


function DX_Text:scale(value)
	if value then
		local action = {}
						
		action[#action + 1] = {}
		action[#action].ufunc = 
			function(d, a)
				d.scale_ = a
			end
		action[#action].uvalues = {self, self.scale_}
						
		action[#action + 1] = {}
		action[#action].rfunc = 
			function(d, a)
				d.scale_ = a
			end
		action[#action].rvalues = {self, tonumber(value) or self.scale_}				
		
		action.description = "Set DX Text scale ("..tostring(tonumber(value) or self.scale_)..")"
		
		UndoRedo.add(action)	
	
		self.scale_ = value
	else
		return self.scale_
	end
end	


function DX_Text:font(value, path, size)
	if value then
		self.font_ = value
		self.fontPath = path
		self.fontSize = size
	else
		return self.font_
	end
end	


function DX_Text:alignX(value)
	if value then
		self.alignX_ = value
	else
		return self.alignX_
	end
end	


function DX_Text:alignY(value)
	if value then
		self.alignY_ = value
	else
		return self.alignY_
	end
end	


function DX_Text:wordwrap(value)
	if value ~= nil then
		self.wordwrap_ = value
	else
		return self.wordwrap_
	end
end	



function DX_Text:clip(value)
	if value ~= nil then
		self.clip_ = value
	else
		return self.clip_
	end
end	


function DX_Text:colourCoded(value)
	if value ~= nil then
		self.colourCoded_ = value
		
		if value then
			self:wordwrap(false)
			self:clip(false)
		end
	else
		return self.colourCoded_
	end
end	


function DX_Text:match(other)
	return self.text_ == other.text_ and
			self.scale_ == other.scale_ and
			self.font_ == other.font_ and
			self.alignX_ == other.alignX_ and
			self.alignY_ == other.alignY_ and
			self.clip_ == other.clip_ and
			self.wordwrap_ == other.wordwrap_ and
			self.postGUI_ == other.postGUI_ and
			self.colourCoded_ == other.colourCoded_ and
			self.subPixelPositioning == other.subPixelPositioning
end


function DX_Text:isShadow(other)
	return self.x == other.x - 1 and 
			self.y == other.y - 1 and
			self.width == other.width and 
			self.height == other.height
			--other.colour_[1] == 0 and 
			--other.colour_[2] == 0 and 
			--other.colour_[3] == 0 and 
			--other.colour_[4] == 255
end


function DX_Text:isOutline(other)
	if --other.colour_[1] == 0 and 
		--other.colour_[2] == 0 and 
		--other.colour_[3] == 0 and 
		--other.colour_[4] == 255 and 
		self.width == other.width and 
		self.height == other.height then
		if self.x == other.x + 1 and self.y == other.y + 1 then
			return 1
		elseif self.x == other.x + 1 and self.y == other.y - 1 then
			return 2
		elseif self.x == other.x - 1 and self.y == other.y + 1 then
			return 3
		elseif self.x == other.x - 1 and self.y == other.y - 1 then
			return 4
		end
	end
	
	return
end


addEventHandler("onClientRender", root,
	function()
		if not gEnabled then
			return
		end
	
		for i,dx in ipairs(DX_Element.instances) do
			if dx.dxType == gDXTypes.line then
				dxDrawLine(dx.startX, dx.startY, dx.endX, dx.endY, tocolor(unpack(dx.colour_)), dx.width, dx.postGUI_)
			elseif dx.dxType == gDXTypes.rectangle then
				if dx:shadow() then
					--dxDrawRectangle(dx.x + 1, dx.y + 1, dx.width, dx.height, tocolor(0, 0, 0, 255), dx.postGUI_)
					-- bottom
					dxDrawLine(dx.x - 1, dx.y + dx.height, dx.x + dx.width, dx.y + dx.height, tocolor(unpack(dx.shadowColour_)), 1, dx.postGUI_)
					-- right
					dxDrawLine(dx.x + dx.width, dx.y - 1, dx.x + dx.width, dx.y + dx.height, tocolor(unpack(dx.shadowColour_)), 1, dx.postGUI_)					
				end
				
				if dx:outline() then
					--dxDrawRectangle(dx.x - 1, dx.y - 1, dx.width + 2, dx.height + 2, tocolor(0, 0, 0, 255), dx.postGUI_)
					-- left
					dxDrawLine(dx.x - 1, dx.y - 1, dx.x - 1, dx.y + dx.height, tocolor(unpack(dx.outlineColour_)), 1, dx.postGUI_)
					-- bottom
					dxDrawLine(dx.x - 1, dx.y + dx.height, dx.x + dx.width, dx.y + dx.height, tocolor(unpack(dx.outlineColour_)), 1, dx.postGUI_)
					-- right
					dxDrawLine(dx.x + dx.width, dx.y - 1, dx.x + dx.width, dx.y + dx.height, tocolor(unpack(dx.outlineColour_)), 1, dx.postGUI_)
					-- top
					dxDrawLine(dx.x - 1, dx.y - 1, dx.x + dx.width, dx.y - 1, tocolor(unpack(dx.outlineColour_)), 1, dx.postGUI_)
				end
				
				dxDrawRectangle(dx.x, dx.y, dx.width, dx.height, tocolor(unpack(dx.colour_)), dx.postGUI_)
			elseif dx.dxType == gDXTypes.image then
				dxDrawImage(dx.x, dx.y, dx.width, dx.height, dx.filepath, dx.rotation_, dx.rOffsetX_, dx.rOffsetY_, tocolor(unpack(dx.colour_)), dx.postGUI_)
			elseif dx.dxType == gDXTypes.text then
				if dx:shadow() then
					dxDrawText(dx.text_, dx.x + 1, dx.y + 1, dx.x + 1 + dx.width, dx.y + 1 + dx.height, tocolor(unpack(dx.shadowColour_)), dx.scale_, dx.font_, dx.alignX_, dx.alignY_, dx.clip_, dx.wordwrap_, dx.postGUI_, dx.colourCoded_, dx.subPixelPositioning)
				end	

				if dx:outline() then
					dxDrawText(dx.text_, dx.x - 1, dx.y - 1, dx.x - 1 + dx.width, dx.y - 1 + dx.height, tocolor(unpack(dx.outlineColour_)), dx.scale_, dx.font_, dx.alignX_, dx.alignY_, dx.clip_, dx.wordwrap_, dx.postGUI_, dx.colourCoded_, dx.subPixelPositioning)
					dxDrawText(dx.text_, dx.x + 1, dx.y - 1, dx.x + 1 + dx.width, dx.y - 1 + dx.height, tocolor(unpack(dx.outlineColour_)), dx.scale_, dx.font_, dx.alignX_, dx.alignY_, dx.clip_, dx.wordwrap_, dx.postGUI_, dx.colourCoded_, dx.subPixelPositioning)
					dxDrawText(dx.text_, dx.x + 1, dx.y + 1, dx.x + 1 + dx.width, dx.y + 1 + dx.height, tocolor(unpack(dx.outlineColour_)), dx.scale_, dx.font_, dx.alignX_, dx.alignY_, dx.clip_, dx.wordwrap_, dx.postGUI_, dx.colourCoded_, dx.subPixelPositioning)
					dxDrawText(dx.text_, dx.x - 1, dx.y + 1, dx.x - 1 + dx.width, dx.y + 1 + dx.height, tocolor(unpack(dx.outlineColour_)), dx.scale_, dx.font_, dx.alignX_, dx.alignY_, dx.clip_, dx.wordwrap_, dx.postGUI_, dx.colourCoded_, dx.subPixelPositioning)
				end

				dxDrawText(dx.text_, dx.x, dx.y, dx.x + dx.width, dx.y + dx.height, tocolor(unpack(dx.colour_)), dx.scale_, dx.font_, dx.alignX_, dx.alignY_, dx.clip_, dx.wordwrap_, dx.postGUI_, dx.colourCoded_, dx.subPixelPositioning)
			end
		end
	end
, true, gEventPriorities.DXElementRender)





addEventHandler("onClientGUISize", root,
	function()
		if not gEnabled then
			return
		end
	
		if getElementData(source, "guieditor.internal:dxElement") then
			local dx = DX_Element.ids[getElementData(source, "guieditor.internal:dxElement")]

			if dx.ignoreSizing then
				return
			end
			
			local x, y = guiGetPosition(source, false)
			local w, h = guiGetSize(source, false)

			if dx.dxType == gDXTypes.line then
				if dx.anchor == gDXAnchor.topLeft then
					dx.startX = x
					dx.startY = y
					dx.endX = x + w
					dx.endY = y + h
				elseif dx.anchor == gDXAnchor.topRight then
					dx.startX = x + w
					dx.startY = y
					dx.endX = x
					dx.endY = y + h
				elseif dx.anchor == gDXAnchor.bottomLeft then
					dx.startX = x
					dx.startY = y + h
					dx.endX = x + w
					dx.endY = y
				elseif dx.anchor == gDXAnchor.bottomRight then
					dx.startX = x + w
					dx.startY = y + h
					dx.endX = x
					dx.endY = y
				end
			elseif dx.dxType == gDXTypes.rectangle or dx.dxType == gDXTypes.image or dx.dxType == gDXTypes.text then
				dx.x = x
				dx.y = y
				dx.width = w
				dx.height = h
			end
		end
	end
)



addEventHandler("onClientGUIMove", root,
	function()
		if not gEnabled then
			return
		end
	
		if getElementData(source, "guieditor.internal:dxElement") then
			local dx = DX_Element.ids[getElementData(source, "guieditor.internal:dxElement")]

			local x, y = guiGetPosition(source, false)
			local w, h = guiGetSize(source, false)

			if dx.dxType == gDXTypes.line then
				--[[
				1 ------ 2
				|        |
				|        |
				3 ------ 4
				]]

				if dx.anchor == gDXAnchor.topLeft then
					dx.startX = x
					dx.startY = y
					dx.endX = x + w
					dx.endY = y + h
				elseif dx.anchor == gDXAnchor.topRight then
					dx.startX = x + w
					dx.startY = y
					dx.endX = x
					dx.endY = y + h
				elseif dx.anchor == gDXAnchor.bottomLeft then
					dx.startX = x
					dx.startY = y + h
					dx.endX = x + w
					dx.endY = y
				elseif dx.anchor == gDXAnchor.bottomRight then
					dx.startX = x + w
					dx.startY = y + h
					dx.endX = x
					dx.endY = y
				end
			elseif dx.dxType == gDXTypes.rectangle or dx.dxType == gDXTypes.image or dx.dxType == gDXTypes.text then
				dx.x = x
				dx.y = y
				dx.width = w
				dx.height = h
			end
		end
	end
)