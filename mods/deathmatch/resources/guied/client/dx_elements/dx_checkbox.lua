--[[--------------------------------------------------
	GUI Editor
	client
	dx_checkbox.lua
	
	creates a dx checkbox widget for use in the right click menus
--]]--------------------------------------------------

DX_Checkbox = {}
DX_Checkbox.__index = DX_Checkbox
DX_Checkbox.instances = {}

function DX_Checkbox:create(x, y, width, height, selected)
	local new = setmetatable(
		{
			x = x,
			y = y,
			width = width,
			height = height,
			selected_ = selected,
			borderColour = {255, 255, 255, 100},
			visible_ = true,
			postGUI = true,
			enabled_ = true,
		},
		DX_Checkbox
	)
	
	DX_Checkbox.instances[#DX_Checkbox.instances + 1] = new
	
	return new
end


function DX_Checkbox:position(x, y)
	if x then
		self.x = x
		self.y = y
	else
		return self.x, self.y
	end
end


function DX_Checkbox:size(width, height)
	if width then
		self.width = width
		self.height = height
	else
		return self.width, self.height
	end
end


function DX_Checkbox:selected(selected)
	if selected ~= nil then
		if self:enabled() then
			self.selected_ = selected
		end
	else
		return self.selected_
	end
end	


function DX_Checkbox:visible(visible)
	if visible ~= nil then
		self.visible_ = visible
	else
		return self.visible_
	end
end


function DX_Checkbox:enabled(value)
	if value ~= nil then
		self.enabled_ = value
	else
		return self.enabled_
	end
end


function DX_Checkbox:draw()
	if self:visible() then
		if self.borderColour then
			dxDrawLine(self.x, self.y + 1, self.x + self.width, self.y + 1, tocolor(unpack(self.borderColour)), 1)
			dxDrawLine(self.x, self.y, self.x, self.y + self.height - 2, tocolor(unpack(self.borderColour)), 1)
			dxDrawLine(self.x, self.y + self.height - 2, self.x + self.width, self.y + self.height - 2, tocolor(unpack(self.borderColour)), 1)
			dxDrawLine(self.x + self.width, self.y, self.x + self.width, self.y + self.height - 2, tocolor(unpack(self.borderColour)), 1)
		end
				
		if self:selected() then
			dxDrawImage(self.x, self.y, self.width, self.height, "images/dx_elements/checkbox_tick.png", 0, 0, 0, tocolor(255, 255, 255, 255), self.postGUI)
		else
			--dxDrawImage(self.x, self.y, self.width, self.height, "images/dx_elements/checkbox_tick.png", 0, 0, 0, tocolor(50, 50, 50, 150), self.postGUI)
		end
	end
end