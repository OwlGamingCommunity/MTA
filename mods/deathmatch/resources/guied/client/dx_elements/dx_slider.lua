--[[--------------------------------------------------
	GUI Editor
	client
	dx_slider.lua
	
	creates a dx slider widget for use in the right click menus
--]]--------------------------------------------------

DX_Slider = {}
DX_Slider.__index = DX_Slider
DX_Slider.instances = {}

function DX_Slider:create(x, y, width, height)
	local new = setmetatable(
		{
			x = x,
			y = y,
			width = width,
			height = height,
			minValue = 0,
			maxValue = 100,
			pointer = {
				value = 0,
				position = 0,
				width = 16,
				height = 16,
				dragging = false,
			},
			margin = 10,
			snapToBoundaries = false,
			drawBoundaries = false,
			enabled_ = true,
			visible_ = false,
			postGUI = true,
		},
		DX_Slider
	)
	
	DX_Slider.instances[#DX_Slider.instances + 1] = new
	
	return new
end


function DX_Slider:position(x, y)
	if x then
		self.x = x
		self.y = y
	else
		return self.x, self.y
	end
end


function DX_Slider:size(width, height)
	if width then
		self.width = width
		self.height = height
	else
		return self.width, self.height
	end
end


function DX_Slider:visible(visible)
	if visible ~= nil then
		self.visible_ = visible
		
		if not visible then
			self.pointer.dragging = false
		end
	else
		return self.visible_
	end
end


function DX_Slider:value(value)
	if value then
		value = math.round(value)
		self.pointer.value = value
		self:updatePointerPosition(value)
	else
		return self.pointer.value
	end
end


function DX_Slider:enabled(value)
	if value ~= nil then
		self.enabled_ = value
	else
		return self.enabled_
	end
end


function DX_Slider:isMouseOnPointer(x, y)
	if x >= (self.x + self.pointer.position) and x <= (self.x + self.pointer.position + self.pointer.width) and
		y >= (self.y + (self.height / 2) - (self.pointer.height / 2)) and y <= (self.y + (self.height / 2) + (self.pointer.height / 2)) then
		return true
	end
	
	return false
end


function DX_Slider:updatePointerPosition(value)
	local width = self.width - 20
	local position
	local newValue

	if value then
		newValue = value
		
		position = (value / self.maxValue) * width
	else
		local x = getCursorPosition(true)
		
		position = x - self.x - 10
		
		if position > self.width then
			position = self.width
		end
		
		local percent = position / width	
		
		percent = math.min(math.max(percent, 0), 1)	
		
		newValue = math.floor(self.minValue + (percent * (self.maxValue - self.minValue)) + 0.5)
	end

	self.pointer.value = math.min(math.max(newValue, self.minValue), self.maxValue)

	position = math.min(math.max(position, 0), width)
	
	local newPosition = position - (self.pointer.width / 2) + 10
	
	if self.snapToBoundaries then
		newPosition = ((width / ((self.maxValue - self.minValue))) * ((self.pointer.value - self.minValue))) - (self.pointer.width / 2) + 10		
	end
	
	if self.pointer.position ~= newPosition then
		self.pointer.position = newPosition

		if self.onChange and self:visible() then
			self.onChange(unpack(self.onChangeArgs or {}))
		end
	end
end


function DX_Slider:draw()
	if self:visible() then
		--dxDrawLine(self.x, self.y + (self.height / 2), self.x + self.width, self.y + (self.height / 2), tocolor(200, 200, 200, 255), 1, self.postGUI)
		dxDrawLine(self.x + 1, self.y + (self.height / 2), self.x + self.width - 2, self.y + (self.height / 2), tocolor(100, 100, 100, 100), 1, self.postGUI)
		
		dxDrawLine(self.x + 1, self.y + (self.height / 2) - 1, self.x + self.width - 2, self.y + (self.height / 2) - 1, tocolor(unpack(gColours.primary)), 1, self.postGUI)
		dxDrawLine(self.x + 1, self.y + (self.height / 2) + 1, self.x + self.width - 2, self.y + (self.height / 2) + 1, tocolor(unpack(gColours.primary)), 1, self.postGUI)
		
		dxDrawImage(self.x, self.y, self.height, self.height, "images/dx_elements/slider_end.png", 0, 0, 0, tocolor(255, 255, 255, 255), self.postGUI)
		dxDrawImage(self.x + self.width - self.height, self.y, self.height, self.height, "images/dx_elements/slider_end.png", 180, 0, 0, tocolor(255, 255, 255, 255), self.postGUI)
		
		if self.drawBoundaries then
			for i = 0, (self.maxValue - self.minValue), 1 do
				local pos = (((self.width - 20) / ((self.maxValue - self.minValue) )) * (i)) - (4) + 10
				dxDrawImage(self.x + pos, self.y + 4, 8, 8, "images/dx_elements/radio_button.png", 0, 0, 0, tocolor(255, 255, 255, 255), self.postGUI)
			end
		end
		
		if self.pointer.dragging then
			self:updatePointerPosition()
		end
		
		dxDrawImage(self.x + self.pointer.position, self.y + (self.height / 2) - (self.pointer.height / 2), self.pointer.width, self.pointer.height, "images/dx_elements/slider_pointer.png", 0, 0, 0, tocolor(255, 255, 255, 255), self.postGUI)
	end
end


addEventHandler("onClientClick", root,
	function(button, state, absoluteX, absoluteY)
		if not gEnabled then
			return
		end
	
		if button == "left" then
			if state == "down" then
				for _,slider in ipairs(DX_Slider.instances) do
					if slider:enabled() and slider:isMouseOnPointer(absoluteX, absoluteY) then
						slider.pointer.dragging = true
					end
				end
			elseif state == "up" then
				for _,slider in ipairs(DX_Slider.instances) do
					if slider.pointer.dragging then
						slider.pointer.dragging = false
					end
				end
			end
		end
	end
)