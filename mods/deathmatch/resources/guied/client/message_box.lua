--[[--------------------------------------------------
	GUI Editor
	client
	message_box.lua
	
	manages various types of generic message box
--]]--------------------------------------------------


MessageBox = {}
MessageBox.__index = MessageBox


function MessageBox:create(x, y, w, h)
	w = w or 300
	h = h or 150

	x = x or ((gScreen.x - w) / 2)
	y = y or ((gScreen.y - h) / 2)

	local new = setmetatable(
		{
			x = x,
			y = y,
			w = w,
			h = h,
			window = guiCreateWindow(x, y, w, h, "", false),
		},
		MessageBox
	)
	
	guiWindowSetSizable(new.window, false)
	guiWindowSetMovable(new.window, false)
	guiSetProperty(new.window, "AlwaysOnTop", "True")
	
	doOnChildren(new.window, setElementData, "guieditor.internal:noLoad", true)

	return new
end


function MessageBox:close()
	if self.onClose then
		self.onClose(unpack(self.onCloseArgs or {}))
	end
	
	if exists(self.window) then
		destroyElement(self.window)
	end
	
	self = nil
end



--[[----------------------------------------------

]]------------------------------------------------
MessageBox_Error = {}

setmetatable(MessageBox_Error, {__index = MessageBox})

function MessageBox_Error:create()
	local item = MessageBox:create()
	
	--item.blah = blah
	
	item = setmetatable(item, {__index = MessageBox_Error})
	
	return item
end



--[[----------------------------------------------
	A message box with affirmative and negative choices
]]------------------------------------------------
MessageBox_Continue = {}

setmetatable(MessageBox_Continue, {__index = MessageBox})

function MessageBox_Continue:create(message, yes, no)
	local item = MessageBox:create()
	
	item = setmetatable(item, {__index = MessageBox_Continue})
	
	guiSetText(item.window, "Warning")
	guiWindowSetMovable(item.window, true)
	
	item.description = guiCreateLabel(0.05, 0.15, 0.9, 0.6, tostring(message), true, item.window)
	guiLabelSetHorizontalAlign(item.description, "center", true)
	
	item.buttonYes = guiCreateButton(0.1, 0.8, 0.3, 0.15, yes or "Yes", true, item.window)
	item.buttonNo = guiCreateButton(0.6, 0.8, 0.3, 0.15, no or "No", true, item.window)
	--guiSetColour(item.buttonYes, unpack(gColours.secondary))
	--guiSetColour(item.buttonNo, unpack(gColours.secondary))
	
	addEventHandler("onClientGUIClick", item.buttonYes,
		function(button, state)
			if button == "left" and state == "up" then
				item:affirmative()
			end
		end
	, false)
	
	addEventHandler("onClientGUIClick", item.buttonNo,
		function(button, state)
			if button == "left" and state == "up" then
				item:negative()
			end
		end
	, false)	

	-- this doesn't work, maybe problem with passing custom metatables through bind args?
	--bindKey("enter", "down", item.affirmative, item)
	
	item.bindFunc = function() item:affirmative() end
	bindKey("enter", "down", item.bindFunc)

	doOnChildren(item.window, setElementData, "guieditor.internal:noLoad", true)
	
	return item
end


function MessageBox_Continue:affirmative()
	if self.onAffirmative then
		self.onAffirmative(unpack(self.onAffirmativeArgs or {}))
	end
	
	if self.bindFunc then
		unbindKey("enter", "down", self.bindFunc)
	end
	
	self:close()
end


function MessageBox_Continue:negative()
	if self.onNegative then
		self.onNegative(unpack(self.onNegativeArgs or {}))
	end
	
	if self.bindFunc then
		unbindKey("enter", "down", self.bindFunc)
	end
	
	self:close()
end



--[[----------------------------------------------
	message box with input area
]]------------------------------------------------
MessageBox_Input = {}

setmetatable(MessageBox_Input, {__index = MessageBox})

function MessageBox_Input:create(multiline, title, description, acceptText)
	local item = MessageBox:create(nil, nil, nil, 120)
	
	guiSetText(item.window, title or "Set Text")
	guiWindowTitlebarButtonAdd(item.window, "Close", "right", function() item:close() end)
	
	item.multiline = multiline
	
	if multiline then
		guiWindowTitlebarButtonAdd(item.window, "Multi-line", "left", 
			function()  
				local w,h  = guiGetSize(item.window, false)
				
				if guiGetVisible(item.inputMemo) then
					guiSetSize(item.window, w, 120, false)
					guiSetVisible(item.inputMemo, false)
					guiSetVisible(item.input, true)
					
					guiSetPosition(item.buttonChange, (item.w - 100) / 2, item.h - 30, false)
					
					guiSetText(item.input, string.gsub(guiGetText(item.inputMemo), "\n", "\\n"):sub(1, -3))
					guiBringToFront(item.input)
				else
					guiSetSize(item.window, w, 270, false)
					guiSetSize(item.inputMemo, w - 20, 180, false)
					guiSetVisible(item.inputMemo, true)
					guiSetVisible(item.input, false)
					
					guiSetPosition(item.buttonChange, (item.w - 100) / 2, 270 - 30, false)
					
					guiSetText(item.inputMemo, string.gsub(guiGetText(item.input), "\\n", "\n"))
					guiBringToFront(item.inputMemo)
				end
			end
		)
	end
	
	item.description = guiCreateLabel(10, 25, item.w - 20, 20, description or "Enter the new text:", false, item.window)
	guiLabelSetHorizontalAlign(item.description, "center", true)
	
	item.input = guiCreateEdit(10, item.h - 10 - 20 - 40, item.w - 20, 30, "", false, item.window)
	guiBringToFront(item.input)
	item.inputMemo = guiCreateMemo(10, 50, item.w - 20, 200, "", false, item.window)
	guiSetVisible(item.inputMemo, false)
	
	item.buttonChange = guiCreateButton((item.w - 100) / 2, item.h - 30, 100, 20, acceptText or "Update text", false, item.window)
	
	-- do this instead
	addEventHandler("onClientGUIAccepted", item.input,
		function() 
			item:updateText()
		end,
	false)	
	
	addEventHandler("onClientGUIClick", item.buttonChange,
		function(button, state)
			if button == "left" and state == "up" then
				item:updateText()
			end
		end
	, false)
	
	item = setmetatable(item, {__index = MessageBox_Input})
	
	doOnChildren(item.window, setElementData, "guieditor.internal:noLoad", true)
	
	return item
end


function MessageBox_Input:descriptionLines(lines)
	local more = lines * 15
	
	local w, h = guiGetSize(self.window, false)
	guiSetSize(self.window, w, h + more, false)
	self.h = self.h + more
	
	guiSetSize(self.description, self.w - 20, 20 + more, false)
	
	guiSetPosition(self.input, 10, self.h - 10 - 20 - 40, false)

	guiSetPosition(self.buttonChange, (self.w - 100) / 2, self.h - 30, false)
end


function MessageBox_Input:setText(text)
	guiSetText(self.input, text:gsub("\n", "\\n"))
	guiSetText(self.inputMemo, text)	
end


function MessageBox_Input:maxLength(length)
	guiSetProperty(self.input, "MaxTextLength", length)
	guiSetProperty(self.inputMemo, "MaxTextLength", length)
end

function MessageBox_Input:updateText()
	local text = guiGetText(self.input)
			
	if guiGetVisible(self.inputMemo) then
		text = guiGetText(self.inputMemo):sub(1, -2)
	end
	
	if self.onAccept then
		self.onAccept(text, unpack(self.onAcceptArgs or {}))
	else
		if self.element then
			if self.multiline then
				guiSetText(self.element, text:gsub("\\n","\n"))
			else
				guiSetText(self.element, text)
			end
			
			if self.onPostAccept then
				self.onPostAccept(unpack(self.onPostAcceptArgs or {}))
			end
		end
	end
	
	if self.bindFunc then
		unbindKey("enter", "down", self.bindFunc)
	end

	self:close()
end



--[[----------------------------------------------
	message box with double input area (ie: for x/y or w/h)
]]------------------------------------------------
MessageBox_InputDouble = {}

setmetatable(MessageBox_InputDouble, {__index = MessageBox})

function MessageBox_InputDouble:create(title, leftDesc, rightDesc, filter)
	local item = MessageBox:create(nil, nil, nil, 120)
	
	guiSetText(item.window, title or "Set Values")
	guiWindowTitlebarButtonAdd(item.window, "Close", "right", function() item:close() end)
		
	item.descriptionLeft = guiCreateLabel(10, 30, (item.w / 2) - 20, 25, leftDesc or "Value 1:", false, item.window)	
	guiLabelSetHorizontalAlign(item.descriptionLeft, "center", true)
	item.descriptionRight = guiCreateLabel((item.w / 2) + 10, 30, (item.w / 2) - 20, 25, rightDesc or "Value 2:", false, item.window)	
	guiLabelSetHorizontalAlign(item.descriptionRight, "center", true)
	
	item.inputLeft = guiCreateEdit(10, 55, (item.w / 2) - 20, 30, "", false, item.window)
	item.inputRight = guiCreateEdit((item.w / 2) + 10, 55, (item.w / 2) - 20, 30, "", false, item.window)
	setElementData(item.inputLeft, "guieditor:filter", filter)
	setElementData(item.inputRight, "guieditor:filter", filter)
	
	guiBringToFront(item.inputLeft)
	
	item.buttonChange = guiCreateButton((item.w - 100) / 2, item.h - 30, 100, 20, "Accept", false, item.window)
	
	item = setmetatable(item, {__index = MessageBox_InputDouble})
	
	addEventHandler("onClientGUIClick", item.buttonChange,
		function(button, state)
			if button == "left" and state == "up" then
				item:accept()
			end
		end
	, false)
	
	doOnChildren(item.window, setElementData, "guieditor.internal:noLoad", true)
	
	return item
end


function MessageBox_InputDouble:accept()
	if self.onAccept then
		local valueLeft = guiGetText(self.inputLeft)
		local valueRight = guiGetText(self.inputRight)
		
		self.onAccept(valueLeft, valueRight, unpack(self.onAcceptArgs or {}))
	end

	self:close()
end



--[[----------------------------------------------
	message box with information text and a single accept button
]]------------------------------------------------
MessageBox_Info = {}

setmetatable(MessageBox_Info, {__index = MessageBox})

function MessageBox_Info:create(title, information)
	local item = MessageBox:create()
	
	item = setmetatable(item, {__index = MessageBox_Info})
	
	guiSetText(item.window, title or "Information")
	guiWindowSetMovable(item.window, true)
	guiWindowTitlebarButtonAdd(item.window, "Close", "right", function() item:close() end)
	
	item.description = guiCreateLabel(0.05, 0.15, 0.9, 0.6, tostring(information), true, item.window)
	guiLabelSetHorizontalAlign(item.description, "center", true)
	guiLabelSetVerticalAlign(item.description, "center")
	
	item.accept = guiCreateButton(0.25, 0.8, 0.5, 0.15, "Ok", true, item.window)
	--guiSetColour(item.accept, unpack(gColours.secondary))
	
	guiBringToFront(item.window)
	
	addEventHandler("onClientGUIClick", item.accept,
		function(button, state)
			if button == "left" and state == "up" then
				item:close()
			end
		end
	, false)

	item.bindFunc = function() item:close() end
	bindKey("enter", "down", item.bindFunc)
	
	doOnChildren(item.window, setElementData, "guieditor.internal:noLoad", true)

	return item
end
