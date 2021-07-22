--[[--------------------------------------------------
	GUI Editor
	client
	dx_radiobutton.lua
	
	creates a dx radiobutton widget for use in the right click menus
--]]--------------------------------------------------

DX_Radiobutton = {}
DX_Radiobutton.__index = DX_Radiobutton
DX_Radiobutton.instances = {}

function DX_Radiobutton:create(x, y, width, height, selected, group)
	local new = setmetatable(
		{
			x = x,
			y = y,
			width = width,
			height = height,
			borderColour = {255, 255, 255, 150},
			selected_ = selected,
			visible_ = true,
			postGUI = true,
			enabled_ = true,
			group = group or gRadioButtonGroupID
		},
		DX_Radiobutton
	)
	
	DX_Radiobutton.instances[#DX_Radiobutton.instances + 1] = new
	
	return new
end


function DX_Radiobutton:position(x, y)
	if x then
		self.x = x
		self.y = y
	else
		return self.x, self.y
	end
end


function DX_Radiobutton:size(width, height)
	if width then
		self.width = width
		self.height = height
	else
		return self.width, self.height
	end
end


function DX_Radiobutton:selected(selected)
	if selected ~= nil then
		if self:enabled() then
			if selected then
				for _,button in ipairs(DX_Radiobutton.instances) do
					if button ~= self and button.group == self.group then
						button.selected_ = false
					end
				end
			end

			self.selected_ = selected
		end
	else
		return self.selected_
	end
end	


function DX_Radiobutton:visible(visible)
	if visible ~= nil then
		self.visible_ = visible
	else
		return self.visible_
	end
end


function DX_Radiobutton:enabled(value)
	if value ~= nil then
		self.enabled_ = value
	else
		return self.enabled_
	end
end


function DX_Radiobutton:draw()
	if self:visible() then
		if self.borderColour then
			local quarter = self.width / 4
			
			dxDrawLine(self.x + quarter, self.y + quarter, self.x + self.width - quarter, self.y + quarter, tocolor(unpack(self.borderColour)), 1)
			dxDrawLine(self.x + quarter, self.y + quarter, self.x + quarter, self.y + self.height - quarter - 1, tocolor(unpack(self.borderColour)), 1)
			dxDrawLine(self.x + quarter, self.y + self.height - 1 - quarter, self.x + self.width - quarter, self.y + self.height - 1 - quarter, tocolor(unpack(self.borderColour)), 1)
			dxDrawLine(self.x + self.width - quarter, self.y + quarter, self.x + self.width - quarter, self.y + self.height - quarter - 1, tocolor(unpack(self.borderColour)), 1)			
		end
				
		if self:selected() then
			dxDrawImage(self.x, self.y, self.width, self.height, "images/dx_elements/radio_button.png", 0, 0, 0, tocolor(255, 255, 255, 255), self.postGUI)
		end
	end
end