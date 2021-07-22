--[[--------------------------------------------------
	GUI Editor
	client
	util.lua
	
	common utility functions
--]]--------------------------------------------------


function isBool(b)
	return b == true or b == false
end


function toBool(b)
	return b == "true" or b == "True" or b == true
end


function asString(v)
	if type(v) == "userdata" then
		local t = getElementType(v)
		
		if t == "player" then
			return tostring(t) .. "["..tostring(getPlayerName(v)).."]"
		end
		
		return tostring(t) .. " ["..tostring(v).."]"
	end
	
	return tostring(v)
end


--[[--------------------------------------------------
	return the absolute position of an element, regardless of its parents
--]]--------------------------------------------------
function guiGetAbsolutePosition(element)
	local x, y = guiGetPosition(element, false)
	
	if getElementType(element) == "gui-tab" then
		y = y + guiGetProperty(guiGetParent(element), "AbsoluteTabHeight")
	end	
	
	local parent = guiGetParent(element)
	
	while parent do
		local tempX, tempY = guiGetPosition(parent, false)
		
		x = x + tempX
		y = y + tempY
		
		if getElementType(parent) == "gui-tab" then
			y = y + guiGetProperty(guiGetParent(parent), "AbsoluteTabHeight")
		end
		
		parent = guiGetParent(parent)
	end
	
	return x, y
end


--[[--------------------------------------------------
	return the gui parent of a gui element
--]]--------------------------------------------------
function guiGetParent(element)
	local parent = getElementParent(element)
	
	if parent then
		local t = getElementType(parent)
		
		if t and t:find('gui-...') and t ~= 'guiroot' then
			return parent
		end
	end
	
	return nil
end


--[[--------------------------------------------------
	return the width/height of the parent of a gui element,
	regardless of whether the parent is a gui element or the screen
--]]--------------------------------------------------
function guiGetParentSize(element)
	local parent = guiGetParent(element)
	
	if parent then
		return guiGetSize(parent, false)
	else
		return guiGetScreenSize()
	end
end


--[[--------------------------------------------------
	get all gui elements with the same parent as the given element
--]]--------------------------------------------------
function guiGetSiblings(element)
	if exists(element) and guiGetParent(element) then
		return getElementChildren(guiGetParent(element))
	else
		return guiGetScreenElements()
	end
end


--[[--------------------------------------------------
	get all direct children of guiroot
--]]--------------------------------------------------
function guiGetScreenElements(all)
	-- put all existing child gui elements of guiroot into a table
	local guiElements = {}
	
	for _,guiType in ipairs(gGUITypes) do
		for _,element in ipairs(getElementsByType(guiType)) do
			if getElementType(getElementParent(element))=="guiroot" then
				if all or relevant(element) then
					--if getElementType(element) ~= "gui-scrollbar" and getElementType(element) ~= "gui-scrollpane" then
						table.insert(guiElements, element)
					--end
				end
			end
		end
	end

	return guiElements
end


--[[--------------------------------------------------
	easy way to set the rollover colour of a label
--]]--------------------------------------------------
function setRolloverColour(element, rollover, rolloff)
	setElementData(element, "guieditor:rollonColour", rollover)
	setElementData(element, "guieditor:rolloffColour", rolloff)

	addEventHandler("onClientMouseEnter", element, rollover_on, false)
	addEventHandler("onClientMouseLeave", element, rollover_off, false)
end


function rollover_on()
	guiSetColour(source, unpack(getElementData(source, "guieditor:rollonColour")))
end


function rollover_off()
	guiSetColour(source, unpack(getElementData(source, "guieditor:rolloffColour")))
end


--[[--------------------------------------------------
	patch getCursorPosition to return both relative and absolute position types
--]]--------------------------------------------------
getCursorPosition_ = getCursorPosition
function getCursorPosition(absolute)
	if not absolute then
		return getCursorPosition_()
	else
		local x, y = getCursorPosition_()
		
		if x and y then
			x = x * gScreen.x
			y = y * gScreen.y
			
			return x, y
		end
	end
	
	return false
end


--[[--------------------------------------------------
	patch getElementData to have inherit = false by default
--]]--------------------------------------------------
getElementData_ = getElementData
function getElementData(element, data, inherit)
	if not exists(element) then
		outputDebugString("Bad element at getElementData(_, " .. tostring(data) .. ", " .. tostring(inherit) .. ")")
		return
	end
	
	if getElementInvalidData(element, data) then
		return getElementInvalidData(element, data)
	end

	if inherit == nil then
		inherit = false
	end
	
	return getElementData_(element, data, inherit)
end


--[[--------------------------------------------------
	patch setElementData to divert data with invalid types to
	setElementInvalidData automatically
--]]--------------------------------------------------
setElementData_ = setElementData
function setElementData(element, key, value)
	if not exists(element) then
		outputDebugString("Bad element at setElementData(_, " .. tostring(key) .. ", " .. tostring(value) .. ")")
		return
	end
	
	if type(value) == "function" then
		return setElementInvalidData(element, key, value)
	end
	
	if type(value) == "table" then
		if table.find(value, "function", type) then
			return setElementInvalidData(element, key, value)
		end
	end
	
	if getElementInvalidData(element, key) then
		return setElementInvalidData(element, key, value)
	end
	
	return setElementData_(element, key, value)
end


--[[--------------------------------------------------
	a data cache for saving information that is not allowed in normal element data
	eg: function pointers
--]]--------------------------------------------------
__invalidData = {}

function setElementInvalidData(element, key, value)
	outputDebug("set data '"..tostring(key).."' = "..tostring(value), "INVALID_DATA")
	
	if not __invalidData[element] then
		__invalidData[element] = {}
	end
	
	__invalidData[element][key] = value
	return true
end


function getElementInvalidData(element, key)
	outputDebug("get data '"..tostring(key).."' from "..asString(element), "INVALID_DATA")
	
	if __invalidData[element] and __invalidData[element][key] then
		return __invalidData[element][key]
	end
	
	return nil
end


--[[--------------------------------------------------
	patch guiSetVisible to block changing the visibility of 'dead' elements
	ie: those that have been 'deleted', but still exist in the undo buffer
--]]--------------------------------------------------
guiSetVisible_ = guiSetVisible
function guiSetVisible(element, visible)
	if getElementData(element, "guieditor:removed") then
		return
	end
	
	return guiSetVisible_(element, visible)
end


--[[--------------------------------------------------
	patch guiGetPosition to account for code positions
--]]--------------------------------------------------
guiGetPosition_ = guiGetPosition
function guiGetPosition(element, relative, checkCode, parentW, parentH)
	if checkCode and getElementData(element, "guieditor:positionCode") then
		local output = split(getElementData(element, "guieditor:positionCode"), ",")

		local sX, sY = PositionCoder.formatOutput(element, output[1], output[2], parentW, parentH)
		
		local ranX, resultX = pcall(loadstring(sX))
		local ranY, resultY = pcall(loadstring(sY))
		
		if ranX and ranY then
			return resultX, resultY
		end
	end
	
	return guiGetPosition_(element, relative)
end


--[[--------------------------------------------------
	patch guiSetAlpha to auto convert 0-100 to 0-1
--]]--------------------------------------------------
guiSetAlpha_ = guiSetAlpha
function guiSetAlpha(element, alpha, convert)
	if exists(element) then
		if convert then
			alpha = alpha / 100
		end

		return guiSetAlpha_(element, alpha)
	end
end



guiProgressBarSetProgress_ = guiProgressBarSetProgress
function guiProgressBarSetProgress(element, progress)
	if exists(element) then
		guiProgressBarSetProgress_(element, progress)
	end
end



--[[--------------------------------------------------
	patch guiSetSize to fix tab sizes
--]]--------------------------------------------------
guiSetSize_ = guiSetSize
function guiSetSize(element, w, h, relative)
	if getElementType(element) == "gui-tabpanel" then
		-- the size of the tab button changes depending on the size of the tab panel when the tab is added
		-- eg: add a tab to a 20x20 tab panel and the button will be sized to ~80% of the parent
		-- add a tab to a 500x500 tab panel and the button will be closer to ~20% of the parent
		-- once this has been set at creation time it never changes again, even if the tab panel is resized
		-- so we have to change it manually

		local h2 = h
		-- if it is relative, transform back into absolute
		if relative then
			local pH = gScreen.y
			
			if guiGetParent(element) then
				_, pH = guiGetSize(guiGetParent(element), false)
			end
			
			h2 = h * pH
		end
		
		guiSetProperty(element, "TabHeight", 25 / h2)
		--guiSetProperty(element, "AbsoluteTabHeight", 25)
	end
	
	return guiSetSize_(element, w, h, relative)
end


--[[--------------------------------------------------
	table extensions
--]]--------------------------------------------------
function table.create(keys, value)
	local result = {}
	
	for _,k in ipairs(keys) do
		result[k] = value
	end
	
	return result
end


function table.find(t, target, func)
	if type(t) == "table" then
		for key, value in pairs(t) do	
			if (func and func(value) or value) == target then
				return true
			end
			
			if type(value) == "table" then
				if table.find(value, target, func) then
					return true
				end
			end
		end
	end
	
	return false
end


function table.copy(theTable)
	local t = {}
	for k, v in pairs(theTable) do
		if type(v) == "table" then
			t[k] = table.copy(v)
		else
			t[k] = v
		end
	end
	return t
end


function table.count(t)
	local c = 0
	
	for v in pairs(t) do
		c = c + 1
	end
	
	return c
end


function table.merge(a, b)
	local t = {}
	
	for i,v in ipairs(a) do
		t[i] = v
	end
	
	for k,v in ipairs(b) do
		t[#t + 1] = v
	end
	
	return t
end


function rgbToHex(r, g, b)
  return string.format("%02X%02X%02X", r, g, b)
end

function rgbaToHex(r, g, b, a)
  return string.format("%02X%02X%02X%02X", a, r, g, b)
end


function string.insert(s, insert, pos)
	return string.sub(s, 0, pos) .. tostring(insert) .. string.sub(s, pos + 1)
end

function string.overwrite(s, insert, startPos, endPos)
	return string.sub(s, 0, startPos) .. tostring(insert) .. string.sub(s, endPos + 1)
end


function string.trim(s)
	return s:match('^()%s*$') and '' or s:match('^%s*(.*%S)')
end


function string.contains(str, match, plain)
	local s, e = str:find(match, 0, plain == true or plain == nil)

	return (s and e and s ~= -1 and e ~= -1)
end	


function string.gsubIgnoreCase(str, match, rep)
	match = string.gsub(match, "%a", 
		function(c)
			return string.format("[%s%s]", string.lower(c), string.upper(c))
		end
	)
	
	str = str:gsub(match, rep)
	
	return str
end


function string.cleanSpace(str)
	return str:gsub(" ", "")
end


function string.limit(str, length)
	local limited = false
	
	while dxGetTextWidth(str, 1, "default") > length do
		str = str:sub(1, -2)
		
		if not limited then
			limited = true
		end
	end
	
	return str, limited
end


function string.firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function string.lines(str)
	local t = {}
	
	local function helper(line) 
		table.insert(t, line) 
		return "" 
	end
	
	helper((str:gsub("(.-)\r?\n", helper)))
	
	return t
end


function math.lerp(from, to, t)
    return from + (to - from) * t
end


function stripGUIPrefix(s)
	if type(s) == "string" then
		return s:sub(5)
	else
		--outputDebug("Invalid type "..type(s).." in stripGUIPrefix", "GENERAL")
		return ""
	end
end


function guiGetFriendlyName(element)
	return string.firstToUpper(stripGUIPrefix(getElementType(element)))
end


function exists(e)
	return e and isElement(e)
end


--[[--------------------------------------------------
	check if an element should be included in regular operations
	ie: was it created by the editor, does it exist outside the undo buffer
--]]--------------------------------------------------
function relevant(e)
	if managed(e) and 
		not getElementData(e, "guieditor:removed") and 
		not getElementData(e, "guieditor.internal:noLoad") then
		return true
	end
	
	return
end


function removed(e)
	return exists(e) and getElementData(e, "guieditor:removed")
end


function managed(e)
	return getElementData(e, "guieditor:managed")
end


function hasText(e)
	if exists(e) and managed(e) then
		local elementType = stripGUIPrefix(getElementType(e))
		
		if elementType == "edit" or elementType == "memo" then
			return true
		end
	end
	
	return false
end


function hasColour(e)
	if exists(e) --[[and managed(e)]] then
		local elementType = stripGUIPrefix(getElementType(e))
		
		if elementType == "window" or 
			elementType == "button" or 
			elementType == "label" or 
			elementType == "checkbox" or 
			elementType == "combobox" or 
			elementType == "edit" or 
			elementType == "radiobutton" or 
			elementType == "staticimage" or
			elementType == "memo" or
			elementType == "combobox" then
			return true
		end
	end
	
	return false
end

function doOnChildren(element, func, ...)
	func(element, ...)

	for _,e in ipairs(getElementChildren(element)) do
		doOnChildren(e, func, ...)
	end
end


function valueInRange(value, minimum, maximum)
	return (value >= minimum) and (value <= maximum)
end


function valueInRangeUnordered(value, range1, range2)
	return (value >= math.min(range1, range2)) and (value <= math.max(range1, range2))
end


function elementOverlap(a, b)
	local aX, aY = guiGetPosition(a, false)
	local aW, aH = guiGetSize(a, false)
	
	local bX, bY = guiGetPosition(b, false)
	local bW, bH = guiGetSize(b, false)

	return rectangleOverlap(aX, aY, aW, aH, bX, bY, bW, bH)
end


function rectangleOverlap(aX, aY, aW, aH, bX, bY, bW, bH)
	local xOverlap = valueInRange(aX, bX, bX + bW) or valueInRange(bX, aX, aX + aW)
	local yOverlap = valueInRange(aY, bY, bY + bH) or valueInRange(bY, aY, aY + aH)
	
	return xOverlap, yOverlap	
end


function pointOverlap(element, x, y)
	local ex, ey = guiGetAbsolutePosition(element)
	local w, h = guiGetSize(element, false)
	
	return valueInRange(x, ex, ex + w) or valueInRange(y, ey, ey + h)
end

--[[
function fromcolor(colour)
	a = math.floor(colour / 16777216)
	local a_ = a
		
	if (colour < 0) then
		a = 256 + a
	end
		
	colour = colour - (16777216 * a_)
	r = math.floor(colour / 65536)
	colour = colour - (65536 * r)
	g = math.floor(colour / 256)
	colour = colour - (256 * g)
	b = colour
	
	return r, g, b, a
end
]]
function fromcolor(colour)
	if colour then
		local hex = string.format("%08X", colour)
		local a, r, g, b = getColorFromString("#"..hex)
		return r, g, b, a
	end
	
	return 255,255,255,255
end


function math.round(value)
	return math.floor(value + 0.5)
end


Group = {}
Group.__index = Group

Group.addOrCreate = 
	function(groups, item, value)
		local placed = false
		
		for _, group in ipairs(groups) do
			if group:add(item, value) then
				placed = true
				break
			end
		end

		if not placed then	
			groups[#groups + 1] = Group:create(item, value)
		end		
	end

function Group:create(item, value)
	local new = setmetatable(
		{
			items = {}
		},
		Group
	)
	
	if item ~= nil and value ~= nil then
		new:add(item, value)
	end
	
	return new
end

function Group:add(item, value)
	if not self.items[item] then
		self.items[item] = value
		
		return true
	end
	
	return false
end	

function Group:contains(item, value)
	for i, v in pairs(self.items) do
		if (item ~= nil and item == i) then
			return true
		end
		
		if (value ~= nil and value == v) then
			return true
		end
	end
end

function Group:count() 
	return table.count(self.items)
end