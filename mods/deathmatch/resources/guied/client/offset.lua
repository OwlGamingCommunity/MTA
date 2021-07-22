Offset = {
	active = false,
	fresh = false,
	element = nil,
	x = 0,
	y = 0,
}


function Offset.fromElement(element)
	Offset.element = element
	Offset.active = false
	
	local m = MessageBox_InputDouble:create("Set Values", "Offset X:", "Offset Y:", gFilters.numberInt)
	m.onAccept = Offset.set
end


--[[--------------------------------------------------
	GUI Editor
	client
	offset.lua
	
	manages the element offset function
--]]--------------------------------------------------


function Offset.set(x, y)
	Offset.x = tonumber(x) or 0
	Offset.y = tonumber(y) or 0
	
	Offset.active = true
	Offset.fresh = true
	Offset.awaitingInput = nil
	
	ContextBar.add("Left click on an element to offset it")
end


function Offset.click(button, state, absoluteX, absoluteY)
	if button == "left" and state == "up" then
		if Offset.active then
			if guiGetHoverElement() then
				local hover = guiGetHoverElement()
				
				if managed(hover) then				
					if Offset.element and Offset.element ~= hover and guiGetParent(Offset.element) == guiGetParent(hover) then
						if getElementData(hover, "guieditor:positionCode") and Settings.loaded.position_code_movement_warning.value then
							local m = MessageBox_Continue:create("That element is using lua code to calculate its position, if you move it now it will overwrite that code.\n\nAre you sure you want to continue?", "Yes", "No")
							m.onAffirmative = 
								function(element)
									local x, y = guiGetPosition(Offset.element, false)

									guiSetPosition(element, x + Offset.x, y + Offset.y, false)
									Offset.element = element
									
									setElementData(element, "guieditor:positionCode", nil)
									setTimer(
										function()
											Offset.awaitingInput = nil
										end,
									50, 1)
								end
							m.onAffirmativeArgs = {hover}
							Offset.awaitingInput = true
							
							return
						end

						local x, y = guiGetPosition(Offset.element, false)

						guiSetPosition(hover, x + Offset.x, y + Offset.y, false)
						Offset.element = hover
					end
					
					ContextBar.add("Right click (or left click an empty space) to cancel")
				end
			else
				if not Offset.fresh and not Offset.awaitingInput then
					Offset.disable()
				end
			end
			
			if Offset.fresh then
				Offset.fresh = false
			end
		end
	elseif button == "right" then
		if Offset.active and not Offset.awaitingInput then
			Offset.disable()
		end
	end
end


function Offset.disable()
	Offset.active = false
	Offset.element = nil
	Offset.awaitingInput = nil
end


addEventHandler("onClientRender", root,
	function()
		if not gEnabled then
			return
		end
	
		if Offset.active then
			local x, y = guiGetAbsolutePosition(Offset.element)
			
			local r, g, b, a = unpack(gColours.primary)
			
			dxDrawLine(x, y, x + Offset.x, y + Offset.y, tocolor(r, g, b, 100), 1, true)
			
			dxDrawLine(x + Offset.x, y + Offset.y, x + Offset.x + 60, y + Offset.y, tocolor(unpack(gColours.primary)), 1, true)
			dxDrawLine(x + Offset.x, y + Offset.y, x + Offset.x, y + Offset.y + 60, tocolor(unpack(gColours.primary)), 1, true)

			dxDrawLine(x + Offset.x, y + Offset.y, x + Offset.x + 40, y + Offset.y, tocolor(unpack(gColours.primary)), 3, true)
			dxDrawLine(x + Offset.x, y + Offset.y, x + Offset.x, y + Offset.y + 40, tocolor(unpack(gColours.primary)), 3, true)
			
			dxDrawLine(x + Offset.x, y + Offset.y, x + Offset.x + 20, y + Offset.y, tocolor(unpack(gColours.primary)), 5, true)
			dxDrawLine(x + Offset.x, y + Offset.y, x + Offset.x, y + Offset.y + 20, tocolor(unpack(gColours.primary)), 5, true)
		end
	end
)