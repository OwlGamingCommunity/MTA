--[[--------------------------------------------------
	GUI Editor
	client
	context_bar.lua
	
	manages the context bar for the editor
	(the bar at the bottom of the screen)
--]]--------------------------------------------------


ContextBar = {
	height = 28,
	speed = 20,
	step = 2,
	life = 8000,
	update = 0,
	textColour = {unpack(gColours.primary)},
	lineColour = {0, 0, 0},
	entries = {}
}


function ContextBar.add(text)
	if not gEnabled then
		return
	end
	
	local y = gScreen.y - ContextBar.height
	
	if #ContextBar.entries > 0 then
		if ContextBar.entries[#ContextBar.entries].text == text then
			return
		end
		
		y = ContextBar.entries[#ContextBar.entries].y - ContextBar.height
	end
	
	local pixelsPerSecond = (1000 / ContextBar.speed) * ContextBar.step
	local alphaStep = (gScreen.y - y - ContextBar.height) / pixelsPerSecond
	
	ContextBar.entries[#ContextBar.entries + 1] = {
		text = text, 
		creation = getTickCount(),
		y = y, 
		landed = false, 
		alphaStep = alphaStep == 0 and 0.05 or (1 / ((alphaStep * 1000) / ContextBar.speed)),
		alpha = alphaStep == 0 and 1 or 0,
	}
end


addEventHandler("onClientRender", root,
	function()
		for _,bar in ipairs(ContextBar.entries) do
			dxDrawRectangle(0, bar.y, gScreen.x, ContextBar.height, tocolor(0, 0, 0, math.lerp(0, 170, bar.alpha)), true)
			dxDrawText(bar.text, 0, bar.y, gScreen.x, bar.y + ContextBar.height, tocolor(ContextBar.textColour[1], ContextBar.textColour[2], ContextBar.textColour[3], math.lerp(0, 255, bar.alpha)), 1, "default-bold", "center", "center", true, true, true)
			
			dxDrawLine(0, bar.y, gScreen.x, bar.y, tocolor(ContextBar.lineColour[1], ContextBar.lineColour[2], ContextBar.lineColour[3], math.lerp(0, 255, bar.alpha)), 1, true)
		end
		
		local tick = getTickCount()
		
		if tick > (ContextBar.update + ContextBar.speed) then
			ContextBar.update = tick
			
			if #ContextBar.entries > 1 then
				for i = #ContextBar.entries, 1, -1 do
					if ContextBar.entries[i].y > gScreen.y then
						table.remove(ContextBar.entries, i)
					else
						ContextBar.entries[i].alpha = math.min(1, ContextBar.entries[i].alpha + ContextBar.entries[i].alphaStep)
						ContextBar.entries[i].y = ContextBar.entries[i].y + ContextBar.step
						
						-- make sure we always align the last in the list exactly with the bottom of the screen
						if i ~= 1 and #ContextBar.entries == 2 and ContextBar.entries[i].y > (gScreen.y - ContextBar.height) then
							ContextBar.entries[i].y = gScreen.y - ContextBar.height
						end
					end
				end
			elseif #ContextBar.entries == 1 then
				if not ContextBar.entries[1].landed then
					ContextBar.entries[1].landed = true
					ContextBar.entries[1].creation = tick
				end

				if tick > (ContextBar.entries[1].creation + ContextBar.life) then					
					ContextBar.entries[1].alpha = ContextBar.entries[1].alpha - ContextBar.entries[1].alphaStep
					
					if ContextBar.entries[1].alpha <= 0 then
						ContextBar.entries[1] = nil
					end
				end
			end
		end
	end
)
