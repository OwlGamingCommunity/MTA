--[[--------------------------------------------------
	GUI Editor
	client
	crush.lua
	
	a simple way to slide gui elements into view from the side of their parent
--]]--------------------------------------------------


Crush = {
	toggles = {},
	list = {},
}

function crushElement()
	if not gEnabled then
		return
	end
	
	local tick = getTickCount()
	
	for element, c in pairs(Crush.list) do
		if c.active then
			local w, h = guiGetSize(element, false)
			local x, y = guiGetPosition(element, false)
			
			local fY, fH
			
			if c.follower then
				_, fY = guiGetPosition(c.follower, false)
				_, fH = guiGetSize(c.follower, false)
			end
			
			if c.direction == -1 then
				w = w + (1 - ((tick - c.previousTick) / c.length) * c.width)
			else
				w = w + (((tick - c.previousTick) / c.length) * c.width)
			end			
			
			if c.direction == -1 and w <= 0 then
				guiSetSize(element, 0, h, false)
				c.active = false
				
				if c.follower then
					guiSetPosition(c.follower, x, fY, false)
					guiSetSize(c.follower, c.width, fH, false)
				end					
			elseif c.direction == 1 and w >= c.width then
				guiSetSize(element, c.width, h, false)
				c.active = false
				
				if c.follower then
					guiSetPosition(c.follower, x + c.width, fY, false)
					guiSetSize(c.follower, 0, fH, false)
				end				
			else
				guiSetSize(element, w, h, false)	
				
				if c.follower then
					guiSetPosition(c.follower, x + w, fY, false)
					guiSetSize(c.follower, c.width - w, fH, false)
				end
			end
			
			c.previousTick = tick
		end
	end
end
addEventHandler("onClientRender", root, crushElement)


function setCrushToggle(toggle, length, width, elementToCrush, follower, keepColour)
	Crush.toggles[toggle] = elementToCrush
	
	Crush.list[elementToCrush] = {
		length = length,
		active = false,
		width = width,
		follower = follower,
		previousTick = getTickCount(),
		keepColour = keepColour,
	}
	
	if follower and not keepColour then
		guiSetColour(follower, unpack(gColours.secondary))
	end
end


function getCrush(element)
	return Crush.list[Crush.toggles[element]]
end


addEventHandler("onClientGUIClick", root, 
	function(button, state)
		if button == "left" and state == "up" then
			if Crush.toggles[source] then
				local element = Crush.toggles[source]

				Crush.list[element].previousTick = getTickCount()				
				Crush.list[element].active = true
				
				if not Crush.list[element].direction or Crush.list[element].direction == 1 then
					Crush.list[element].direction = -1	
					--guiSetText(source, ">>")
					guiSetText(source, guiGetText(source):gsub("<", ">"))
					
					if not Crush.list[element].keepColour then
						setElementData(source, "guieditor:rolloffColour", gColours.tertiary)
					end
				elseif Crush.list[element].direction == -1 then
					Crush.list[element].direction = 1
					--guiSetText(source, "<<")
					guiSetText(source, guiGetText(source):gsub(">", "<"))
					
					if not Crush.list[element].keepColour then
						setElementData(source, "guieditor:rolloffColour", gColours.defaultLabel)
					end
				end	
			end
		end
	end
)
