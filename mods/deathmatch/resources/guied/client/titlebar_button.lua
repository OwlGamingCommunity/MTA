--[[--------------------------------------------------
	GUI Editor
	client
	titlebar_button.lua
	
	adds titlebar buttons to gui windows
	(ie: hover buttons that sit within the title bar of a window, aligned to the left or right)
--]]--------------------------------------------------


gWindowTitlebarButtons = {
	defaultColour = {160, 160, 160},
	defaultDivider = "|",
}

function guiWindowTitlebarButtonAdd(window, text, alignment, onClick, ...)
	local offset = getElementData(window, "guieditor:titlebarButton_"..alignment) or 5
	local w = guiGetSize(window, false)
	
	-- don't add a divider before the first item
	if offset > 10 then
		local width = dxGetTextWidth(gWindowTitlebarButtons.defaultDivider, 1, "default")
		local label	= guiCreateLabel(alignment == "left" and offset or w - offset - width, 2, width, 15, gWindowTitlebarButtons.defaultDivider, false, window)
		
		guiLabelSetColor(label, unpack(gWindowTitlebarButtons.defaultColour))
		guiLabelSetHorizontalAlign(label, "center", false)	
		guiSetProperty(label, "ClippedByParent", "False")
		guiSetProperty(label, "AlwaysOnTop", "True")
		
		if alignment == "right" then
			setElementData(label, "guiSnapTo", {[gGUISides.right] = offset})
		end
		
		offset = offset + width + 5
	end
		
	local width = dxGetTextWidth(text, 1, "default")
	local label = guiCreateLabel(alignment == "left" and offset or w - offset - width, 2, width, 15, text, false, window)
	
	guiLabelSetColor(label, unpack(gWindowTitlebarButtons.defaultColour))
	guiLabelSetHorizontalAlign(label, "center", false)
	guiSetProperty(label, "ClippedByParent", "False")
	guiSetProperty(label, "AlwaysOnTop", "True")
	
	if alignment == "right" then
		setElementData(label, "guiSnapTo", {[gGUISides.right] = offset})
	end	
		
	offset = offset + width + 5
	
	local args = {...}
	
	for i,v in ipairs(args) do
		if v == "__self" then
			args[i] = label
		end
	end
	
	addEventHandler("onClientGUIClick", label, 
		function(button, state)
			if button == "left" and state == "up" then
				if onClick then 
					onClick(unpack(args or {})) 
				end 
			end
		end, 
	false)
	setRolloverColour(label, gColours.primary, gWindowTitlebarButtons.defaultColour)
	--addEventHandler("onClientMouseEnter", label, function() guiLabelSetColor(label, unpack(gColours.primary)) end, false)
	--addEventHandler("onClientMouseLeave", label, function() guiLabelSetColor(label, unpack(gWindowTitlebarButtons.defaultColour)) end, false)
	
	setElementData(window, "guieditor:titlebarButton_" .. alignment, offset)
end


