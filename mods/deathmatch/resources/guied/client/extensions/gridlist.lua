--[[--------------------------------------------------
	GUI Editor
	client/extensions/
	gridlist.lua
	
	Extends the standard gui gridlist with extra functionality
--]]--------------------------------------------------

local indefinite = tostring((-1)^0.5)
local rowHeight = 14

local nextFrameChecks = {}
local nextFrameScrolls = {}

addEvent("onClientGUIGridListScroll", false)
addEvent("onClientGUIGridListScrollbarsVisible", false)


guiCreateGridList_ = guiCreateGridList
function guiCreateGridList(x, y, w, h, relative, parent)
	local gridlist = guiCreateGridList_(x, y, w, h, relative, parent)
	
	if exists(gridlist) then
		setElementData(gridlist, "guieditor.internal:gridlistScrollbarVisibility", {vertical = false, horizontal = false})
		
		return gridlist
	end
	
	return false
end

-- returns the absolute x, y, width and height information for the given item
-- will return coordinates that are beyond the bounds of the gridlist if the item is not currently visible
function guiGridListGetItemBounds(gridlist, rowID, columnID)
	if not exists(gridlist) or not rowID or rowID == -1 or not columnID or columnID == -1 then
		return 0, 0, 0, 0
	end

	local columns = getElementData(gridlist, "guieditor.internal:gridlistColumns") or {}
	
	if #columns ==  0 then
		return 0, 0, 0, 0
	end
	
	local x, y = guiGetAbsolutePosition(gridlist, false)
	local w, h = guiGetSize(gridlist, false)
	local requiresSave = false

	-- heights of the side paddings
	local leftOffset, topOffset, rightOffset, bottomOffset = guiGridListGetBorderWidths(gridlist)
	
	local scrollableHeight = h - topOffset - bottomOffset
	local scrollableWidth = w - leftOffset - rightOffset
	
	-- effective is the total width of the scrollable pane (including hidden stuff)
	local effectiveHeight = guiGridListGetRowCount(gridlist) * rowHeight
	local effectiveWidth = getElementData(gridlist, "guieditor.internal:gridlistEffectiveWidth")
	local realWidth = columns[columnID] and columns[columnID].cumulativeWidth or nil
	local columnWidth = 0

	if not effectiveWidth then
		effectiveWidth = 0
		
		for i = 1, guiGridListGetColumnCount(gridlist) do
			local cw = guiGridListGetColumnWidth(gridlist, i)
			
			if i == columnID then
				realWidth = effectiveWidth
				columnWidth = cw
			end

			effectiveWidth = effectiveWidth + cw
		end
		
		setElementData(gridlist, "guieditor.internal:gridlistEffectiveWidth", effectiveWidth)
	else
		if not realWidth then
			realWidth = 0
			requiresSave = true
			
			for i = 1, columnID - 1 do
				realWidth = realWidth + guiGridListGetColumnWidth(gridlist, i)
			end	

			columns[columnID].cumulativeWidth = realWidth
		end
		
		columnWidth = guiGridListGetColumnWidth(gridlist, columnID)
	end

	if requiresSave then
		setElementData(gridlist, "guieditor.internal:gridlistColumns", columns)
	end

	-- obscuredArea / 100
	local scrollPerRow = (effectiveHeight - scrollableHeight) / 100
	local scrollPerColumn = (effectiveWidth - scrollableWidth) / 100
	
	-- real position of the item, not accounting for scroll
	local realHeight = rowID * rowHeight
	
	local vScroll = guiGridListGetVerticalScrollPosition(gridlist)
	local hScroll = guiGridListGetHorizontalScrollPosition(gridlist)
	
	if tostring(vScroll) == indefinite then
		vScroll = 0
	end
	
	if tostring(hScroll) == indefinite then
		hScroll = 0
	end
	
	-- adjusting according to the scroll amount
	local adjustedHeight = realHeight - (vScroll * scrollPerRow)
	local adjustedWidth = realWidth - (hScroll * scrollPerColumn)
	
	return math.round(x + leftOffset + adjustedWidth), math.round(y + topOffset + adjustedHeight), columnWidth, rowHeight
end


-- similar to guiGridListGetItemBounds but adjusted for the position of the item standard text
function guiGridListGetItemTextBounds(gridlist, rowID, columnID, bounds)
	local x, y, w, h
	
	if not bounds then
		x, y, w, h = guiGridListGetItemBounds(gridlist, rowID, columnID)
	else
		x, y, w, h = bounds[1], bounds[2], bounds[3], bounds[4]
	end
	
	if x and y then
		local columns = getElementData(gridlist, "guieditor.internal:gridlistColumns") or {}
		
		if columns[columnID] and columns[columnID].originalFirst and columnID == 1 then
		--if columnID == 1 then
			x = x + 12
			w = w - 12
		end
	end
	
	return x, y, w, h
end


-- returns whether or not the vertical and horizontal scrollbars are showing
function guiGridListGetScrollBars(gridlist)
	local vert = tostring(guiGridListGetVerticalScrollPosition(gridlist))
	local horz = tostring(guiGridListGetHorizontalScrollPosition(gridlist))
	
	return vert ~= "-0" and vert ~= indefinite, horz ~= "-0" and horz ~= indefinite
end


-- returns the widths of the gridlist borders around the scrollable area
function guiGridListGetBorderWidths(gridlist)
	if not exists(gridlist) then
		return -1, -1, -1, -1
	end

	local v, h = guiGridListGetScrollBars(gridlist)
	local left, top, right, bottom = 8, 25, 8, 8
	
	if v then
		right = 19
	end
	
	if h then
		bottom = 19
	end
	
	return left, top, right, bottom
end


-- patch this and save the column width
guiGridListAddColumn_ = guiGridListAddColumn
function guiGridListAddColumn(gridlist, title, width)
	local colID = guiGridListAddColumn_(gridlist, title, width)
	
	if colID then
		local columns = getElementData(gridlist, "guieditor.internal:gridlistColumns") or {}
		local w = guiGetSize(gridlist, false)
		
		columns[#columns + 1] = {width = width * w, originalFirst = guiGridListGetColumnCount(gridlist) == 1}

		setElementData(gridlist, "guieditor.internal:gridlistColumns", columns)
		
		-- adjust the effective width
		local effectiveWidth = getElementData(gridlist, "guieditor.internal:gridlistEffectiveWidth")
		
		if effectiveWidth then
			effectiveWidth = effectiveWidth + (width * w)
			setElementData(gridlist, "guieditor.internal:gridlistEffectiveWidth", effectiveWidth)
		end	
		
		guiGridListCalculateScrollbarVisibility(gridlist)
		
		-- bugfix for this returning false when first created, despite columns being movable by default
		if not guiGridListGetColumnsMovable(gridlist) then
			guiGridListSetColumnsMovable(gridlist, true)
			guiGridListSetColumnsMovable(gridlist, false)
		end
	end
	
	return colID
end


-- patch this so we can remove the column from our cache
guiGridListRemoveColumn_ = guiGridListRemoveColumn
function guiGridListRemoveColumn(gridlist, columnID) 
	if exists(gridlist) and guiGridListRemoveColumn_(gridlist, columnID) then
		-- update our internal column data
		local columns = getElementData(gridlist, "guieditor.internal:gridlistColumns") or {}
		local oldWidth = 0
		
		if #columns > 0 then
			oldWidth = columns[columnID].width
			table.remove(columns, columnID)
		end
		
		setElementData(gridlist, "guieditor.internal:gridlistColumns", columns)
		
		
		-- adjust the effective width
		local effectiveWidth = getElementData(gridlist, "guieditor.internal:gridlistEffectiveWidth")
		
		if effectiveWidth then
			effectiveWidth = effectiveWidth - oldWidth
			setElementData(gridlist, "guieditor.internal:gridlistEffectiveWidth", effectiveWidth)
		end	
		
		guiGridListCalculateScrollbarVisibility(gridlist)
		
		-- update our internal custom data
		local totalData = getElementData(gridlist, "guieditor.internal:gridlistData") or {}
		
		for row = 0, row < guiGridListGetRowCount(gridlist) do
			if totalData[row] ~= nil then
				for j = 1, guiGridListGetColumnCount(gridlist) + 1 do
					if j == columnID then
						if exists(totalData[row][j].label) then
							destroyElement(totalData[row][j].label)
						end
					elseif j > columnID then
						totalData[row][j - 1] = totalData[row][j]
					end
				end
			end
		end
		
		setElementData(gridlist, "guieditor.internal:gridlistData", totalData)
		
		return true
	end
	
	return false
end


guiGridListAddRow_ = guiGridListAddRow
function guiGridListAddRow(gridlist)
	local row = guiGridListAddRow_(gridlist)
	
	if row and tonumber(row) then
		guiGridListCalculateScrollbarVisibility(gridlist)
		
		nextFrameChecks[gridlist] = true
		
		return row
	end
	
	return false
end


guiGridListRemoveRow_ = guiGridListRemoveRow
function guiGridListRemoveRow(gridlist, rowID) 
	if guiGridListRemoveRow_(gridlist, rowID) then
		local totalData = getElementData(gridlist, "guieditor.internal:gridlistData") or {}
		
		if #totalData > 0 then
			for row = 0, guiGridListGetRowCount(gridlist) + 1 do
				if row == rowID then
					for col = 1, guiGridListGetColumnCount(gridlist) do
						if totalData[row] ~= nil and totalData[row][col] ~= nil and exists(totalData[row][col].label) then
							destroyElement(totalData[row][col].label)
						end
					end				
				elseif row > rowID then
					totalData[row - 1] = totalData[row]
					totalData[row] = nil
				end
			end
		end
		
		setElementData(gridlist, "guieditor.internal:gridlistData", totalData)		
		
		guiGridListCalculateScrollbarVisibility(gridlist)
		
		return true
	end
	
	return false
end


guiGridListInsertRowAfter_ = guiGridListInsertRowAfter
function guiGridListInsertRowAfter(gridlist, rowID) 
	if guiGridListInsertRowAfter_(gridlist, rowID) then
		local totalData = getElementData(gridlist, "guieditor.internal:gridlistData") or {}
		
		for row = guiGridListGetRowCount(gridlist), 0, -1 do
			if row > rowID then
				totalData[row + 1] = totalData[row]
				totalData[row] = nil
			elseif row == rowID then
			--	totalData[row] = nil
			end
		end
		
		setElementData(gridlist, "guieditor.internal:gridlistData", totalData)		

		guiGridListCalculateScrollbarVisibility(gridlist)	

		return true
	end
	
	return false
end


--guiGridListSetItemData_ = guiGridListSetItemData
function guiGridListSetCustomItemData(gridlist, rowID, columnID, data)
	if not exists(gridlist) or rowID == -1 or columnID == -1 then
		return false
	end
	
	local totalData = getElementData(gridlist, "guieditor.internal:gridlistData") or {}
	
	if not totalData[rowID] then	
		totalData[rowID] = {}
	end
	
	totalData[rowID][columnID] = data
	
	setElementData(gridlist, "guieditor.internal:gridlistData", totalData)
	
	return true
end


function guiGridListGetCustomItemData(gridlist, rowID, columnID) 
	if not exists(gridlist) or rowID == -1 or columnID == -1 then
		return false
	end
	
	local totalData = getElementData(gridlist, "guieditor.internal:gridlistData") or {}
	
	if totalData[rowID] == nil or totalData[rowID][columnID] == nil then
		return
	end
	
	return totalData[rowID][columnID]
end


function guiGridListAddCustomItemData(gridlist, rowID, columnID, key, value)
	if not exists(gridlist) or rowID == -1 or columnID == -1 then
		return false
	end
	
	local currentData = guiGridListGetCustomItemData(gridlist, rowID, columnID)
	
	if currentData == nil then
		guiGridListSetCustomItemData(gridlist, rowID, columnID, {[key] = value})
		return true
	end
	
	currentData[key] = value
	
	guiGridListSetCustomItemData(gridlist, rowID, columnID, currentData)
	
	return true
end





-- patch this to keep track of the column width
guiGridListAutoSizeColumn_ = guiGridListAutoSizeColumn
function guiGridListAutoSizeColumn(gridlist, columnID)
	if guiGridListAutoSizeColumn_(gridlist, columnID) then
		local columns = getElementData(gridlist, "guieditor.internal:gridlistColumns") or {}
		
		if #columns > 0 and columns[columnID] then
			local textWidth = guiGridListGetColumnTextWidth(gridlist, columnID)

			-- minimum size of a column
			if textWidth < 20 then
				textWidth = 20
			end
			
			-- wrap this onto a SetColumnWidth call since they do the same thing anyway
			guiGridListSetColumnWidth(gridlist, columnID, textWidth, false)
		end
		
		return true
	end
	
	return false
end


-- get the width of the columns longest item (via text width)
function guiGridListGetColumnTextWidth(gridlist, columnID) 
	if not exists(gridlist) or columnID == -1 then
		return 0
	end

	local rowCount = guiGridListGetRowCount(gridlist)
	
	if rowCount then
		local biggestWidth = 0

		for i = 0, rowCount - 1 do
			local t = guiGridListGetItemText(gridlist, i, columnID)
			
			if t then 
				local width = dxGetTextWidth(t)

				if width > biggestWidth then
					biggestWidth = width
				end
			end
		end
		
		return biggestWidth
	end
	
	return 0
end


-- patch this to keep track of the column width
guiGridListSetColumnWidth_ = guiGridListSetColumnWidth
function guiGridListSetColumnWidth(gridlist, columnID, width, relative)
	if guiGridListSetColumnWidth_(gridlist, columnID, width, relative) then
		local columns = getElementData(gridlist, "guieditor.internal:gridlistColumns") or {}
		
		if #columns > 0 and columns[columnID] then
			local w = guiGetSize(gridlist, false)
			local oldWidth = columns[columnID].width
			
			if relative then
				columns[columnID].width = guiGridListClampColumnWidth(gridlist, width, true)
			else
				columns[columnID].width = guiGridListClampColumnWidth(gridlist, width, false)
			end
			
			local count = guiGridListGetColumnCount(gridlist)
			
			-- recalculate the cumulative width (the width from x = 0, x = this)
			if count >= (columnID + 1) then
				for i = columnID + 1, count do
					if columns[i].cumulativeWidth then
						columns[i].cumulativeWidth = columns[i].cumulativeWidth + (columns[columnID].width - oldWidth)
					end
				end
			end
			
			setElementData(gridlist, "guieditor.internal:gridlistColumns", columns)	

			-- adjust the effective width
			local effectiveWidth = getElementData(gridlist, "guieditor.internal:gridlistEffectiveWidth")
			
			if effectiveWidth then
				effectiveWidth = effectiveWidth + (columns[columnID].width - oldWidth)
				setElementData(gridlist, "guieditor.internal:gridlistEffectiveWidth", effectiveWidth)
			end
			
			guiGridListCalculateScrollbarVisibility(gridlist)		
		end
		
		return true
	end
	
	return false
end


-- return the absolute width of the column
-- minimum width = 20px?
function guiGridListGetColumnWidth(gridlist, columnID) 
	if not exists(gridlist) or columnID == -1 then
		return -1
	end

	local columns = getElementData(gridlist, "guieditor.internal:gridlistColumns") or {}
	
	if columns[columnID] then
		return columns[columnID].width
	end
	
	return -1
end


-- clamp the column width within the minimum value range
function guiGridListClampColumnWidth(gridlist, width, relative)
	local w = guiGetSize(gridlist, false)
	
	if relative then
		return w * width < 20 and 20 or width
	else
		return width < 20 and 20 or width
	end
end


-- returns the x, y, width and height of the visible part of an item
-- will return nonsense data (e.g. 0 width) if the item is not visible at all
-- useful to e.g. draw a rectangle box over the item without clipping the gridlist borders
function guiGridListGetItemVisibleBounds(gridlist, rowID, columnID, bounds)
	if not exists(gridlist) or rowID == -1 or columnID == -1 then
		return 0, 0, 0, 0
	end
	
	local x, y = guiGetAbsolutePosition(gridlist)
	local w, h = guiGetSize(gridlist, false)
	
	local itemX, itemY, itemWidth, itemHeight

	if not bounds then
		itemX, itemY, itemWidth, itemHeight = guiGridListGetItemBounds(gridlist, rowID, columnID)
	else
		itemX, itemY, itemWidth, itemHeight = bounds[1], bounds[2], bounds[3], bounds[4]
	end
	
	local visibleX, visibleY, visibleWidth, visibleHeight = itemX, itemY, itemWidth, itemHeight
	local left, top, right, bottom = guiGridListGetBorderWidths(gridlist)
	
	if itemX < (x + left) then
		visibleWidth = math.max((itemX + itemWidth) - (x + left), 0)
		visibleX = itemX + (itemWidth - visibleWidth)
	elseif (itemX + itemWidth) > (x + w - right) then
		visibleWidth = math.max((x + w - right) - itemX, 0)
	end
	
	if itemY < (y + top) then
		visibleHeight = math.max((itemY + itemHeight) - (y + top), 0)
		visibleY = itemY + (itemHeight - visibleHeight)
	elseif (itemY + itemHeight) > (y + h - bottom) then
		visibleHeight = math.max((y + h - bottom) - itemY, 0)
	end
	
	return visibleX, visibleY, visibleWidth, visibleHeight
end


-- check if an x/y point is within the visible (scrollable) bounds of the gridlist
function guiGridListIsPointWithinVisibleBounds(gridlist, pointX, pointY)
	if not exists(gridlist) then
		return false
	end
	
	local x, y = guiGetAbsolutePosition(gridlist)
	local w, h = guiGetSize(gridlist, false)
	local left, top, right, bottom = guiGridListGetBorderWidths(gridlist)
	
	return valueInRange(pointX, x + left, x + w - right) and valueInRange(pointY, y + top, y + h - bottom)
end


function guiGridListCalculateScrollbarVisibility(gridlist)
	local vertical, horizontal = guiGridListGetScrollBars(gridlist)
	local visibility = getElementData(gridlist, "guieditor.internal:gridlistScrollbarVisibility") or {}
	
	if (vertical ~= toBool(visibility.vertical)) or (horizontal ~= toBool(visibility.horizontal)) then
		triggerEvent("onClientGUIGridListScrollbarsVisible", gridlist, vertical, horizontal, toBool(visibility.vertical), toBool(visibility.horizontal))
		setElementData(gridlist, "guieditor.internal:gridlistScrollbarVisibility", {vertical = vertical, horizontal = horizontal})
	end
end


guiGridListSetScrollBars_ = guiGridListSetScrollBars
function guiGridListSetScrollBars(gridlist, horizontal, vertical)
	if guiGridListSetScrollBars(gridlist, horizontal, vertical) then
		guiGridListCalculateScrollbarVisibility(gridlist)
		
		return true
	end
	
	return false
end

-- set whether column sorting is enabled
guiGridListSetSortingEnabled_ = guiGridListSetSortingEnabled
function guiGridListSetSortingEnabled(gridlist, enabled)
	if not exists(gridlist) then
		return false
	end
	
	guiGridListSetSortingEnabled_(gridlist, enabled)
	
	setElementData(gridlist, "guieditor:sortingEnabled", enabled)
	
	return true
end


-- returns whether column sorting is enabled
function guiGridListGetSortingEnabled(gridlist)
	return getElementData(gridlist, "guieditor:sortingEnabled") == true
end


-- set whether columns are movable (dragable)
function guiGridListSetColumnsMovable(gridlist, movable)
	if not exists(gridlist) then
		return false
	end
	
	guiSetProperty(gridlist, "ColumnsMovable", movable and "True" or "False")
	
	return true
end


-- returns whether columns are movable (dragable)
function guiGridListGetColumnsMovable(gridlist)
	return guiGetProperty(gridlist, "ColumnsMovable") == "True"
end


guiGridListClear_ = guiGridListClear
function guiGridListClear(gridlist)
	local rowCount = guiGridListGetRowCount(gridlist)
	
	if guiGridListClear_(gridlist) then
		--setElementData(gridlist, "guieditor.internal:gridlistColumns", {})
		setElementData(gridlist, "guieditor.internal:gridlistEffectiveWidth", nil)
	
		local totalData = getElementData(gridlist, "guieditor.internal:gridlistData") or {}

		for row = 0, rowCount do
			if totalData[row] ~= nil then
				--outputDebug("some rows")
				for col = 1, guiGridListGetColumnCount(gridlist) do
					if totalData[row][col] ~= nil then
						--outputDebug("some cols")
						if exists(totalData[row][col].label) then
							destroyElement(totalData[row][col].label)
							totalData[row][col].label = nil
						end
					end
				end
			end
		end
		
		totalData = nil
		
		setElementData(gridlist, "guieditor.internal:gridlistData", {})
		
		guiGridListCalculateScrollbarVisibility(gridlist)
		
		return true
	end
	
	return false
end


function guiGridListSetItemTextOverlay(gridlist, rowID, columnID, text, replaceText)
	if not exists(gridlist) or rowID == -1 or columnID == -1 then
		return false
	end
	
	local mask = getElementData(gridlist, "guieditor.internal:gridlistMaskLabel")
	local left, top, right, bottom = guiGridListGetBorderWidths(gridlist)
	
	if not exists(mask) then
		local w, h = guiGetSize(gridlist, false)
		
		mask = guiCreateLabel(left, top, w - left - right, h - top - bottom, "", false, gridlist)
		guiSetProperty(mask, "MousePassThroughEnabled", "True")

		setElementData(gridlist, "guieditor.internal:gridlistMaskLabel", mask)
	end

	local currentData = guiGridListGetCustomItemData(gridlist, rowID, columnID)
	local label
	
	if not currentData or not currentData.label then
		label = guiCreateLabel(0, 0, 0, 0, text, false, mask)
		guiSetProperty(label, "MousePassThroughEnabled", "True")
		--guiSetFont(label, "default-small")
		--guiLabelSetColor(label, 120, 120, 120)    
		guiLabelSetColor(label, unpack(gColours.grey))   
	else
		label = currentData.label
	end
	
	local x, y, w, h = guiGridListGetItemTextBounds(gridlist, rowID, columnID)	
	local gx, gy = guiGetAbsolutePosition(gridlist)

	guiSetPosition(label, x - gx - left, y - gy - top - 1, false)
	guiSetSize(label, w, h, false)
	
	--outputDebug("Creating at " ..tostring(x)..", " .. tostring(y)..", for row " .. tostring(rowID).." col " .. tostring(columnID).."")
	
	if not replaceText then
		local t = guiGridListGetItemText(gridlist, rowID, columnID)
		local tw = dxGetTextWidth(t)
		
		guiSetText(label, string.rep(" ", math.ceil(tw / 4)) .. text)
	end
	
	guiGridListAddCustomItemData(gridlist, rowID, columnID, "label", label)
	guiGridListAddCustomItemData(gridlist, rowID, columnID, "labelReplaceText", replaceText)
	
	return label
end


function guiGridListResizeMask(gridlist)
	local mask = getElementData(gridlist, "guieditor.internal:gridlistMaskLabel")

	if exists(mask) then
		local left, top, right, bottom = guiGridListGetBorderWidths(gridlist)
		local w, h = guiGetSize(gridlist, false)
		
		guiSetSize(mask, w - left - right, h - top - bottom, false)
	end	
end


function guiGridListRepositionOverlays(gridlist)
	local totalData = getElementData(gridlist, "guieditor.internal:gridlistData") or {}

	local gx, gy = guiGetAbsolutePosition(gridlist)
	local gw, gh = guiGetSize(gridlist, false)
						
	for row = 0, guiGridListGetRowCount(gridlist) do
		if totalData[row] ~= nil then
			for col = 1, guiGridListGetColumnCount(gridlist) do
				if totalData[row][col] ~= nil then
					if exists(totalData[row][col].label) then
						local x, y, w, h = guiGridListGetItemTextBounds(gridlist, row, col)	
						
						guiSetPosition(totalData[row][col].label, x - gx - 8, y - gy - 25 - 1, false)
						guiSetSize(totalData[row][col].label, w, h, false)
						
						
						--[[
						local xv, yv, wv, hv = guiGridListGetItemVisibleBounds(gridlist, row, col)
						
						if wv > 0 and hv > 0 then
							guiSetPosition(totalData[row][col].label, xv - gx, yv - gy, false)
							guiSetSize(totalData[row][col].label, wv, hv, false)
						elseif wv == 0 or hv == 0 then
							guiSetSize(totalData[row][col].label, 0, 0, false)
						end
						]]
					end
				end
			end
		end
	end
end


addEventHandler("onClientGUISize", root,
	function() 
		if getElementType(source) == "gui-gridlist" then
			guiGridListResizeMask(source)
		end
	end
)

addEventHandler("onClientMouseWheel", root,
    function(up_down)
		if getElementType(source) == "gui-gridlist" then
			local left, top, right, bottom = guiGridListGetBorderWidths(source)
			local x, y = guiGetAbsolutePosition(source)
			local w, h = guiGetSize(source, false)
			local cx, cy = getCursorPosition(true)
			
			if cx >= x and cx <= (x + w) and cy >= (y + top) and cy <= (y + h) then
				if cy > (y + h - bottom) then
					nextFrameScrolls[source] = false
				else
					nextFrameScrolls[source] = true
				end
			end
		end
    end
)


addEventHandler("onClientGUIGridListScroll", resourceRoot,
	function(vertical, scrollAmount)
		guiGridListRepositionOverlays(source)
	end
)


addEventHandler("onClientGUIGridListScrollbarsVisible", resourceRoot,
	function(vertical, horizontal, oldVertical, oldHorizontal)
		--outputDebug("Scrollbars changed: v: " .. tostring(oldVertical) .. " -> " .. tostring(vertical) .. ", h: " .. tostring(oldHorizontal) .. " -> " .. tostring(horizontal))
	
		guiGridListResizeMask(source)
	end
)


local currentGridlistResize = nil
local currentGridlistDrag = nil
local currentlyScrolling = {horizontal = false, vertical = false}

-- we need to catch click events so that we can track people resizing or moving columns and update our cache data
-- this catches clicks on the specific trigger areas for resizing and dragging
addEventHandler("onClientGUIMouseDown", root,
    function(button, absoluteX, absoluteY)
        if button == "left" then
			if getElementType(source) == "gui-gridlist" then	
				local x, y = guiGetAbsolutePosition(source)
				local w, h = guiGetSize(source, false)

				-- inside gridlist bounds
				if (absoluteX > x and absoluteX < (x + w)) and (absoluteY > y and absoluteY < (y + h)) then
					local vert, horz = guiGridListGetScrollBars(source)
					
					-- within the header area
					if (absoluteY > (y + 2) and absoluteY <= (y + 24)) and (not vert or (vert and absoluteX < (x + w - 19))) then
						local movable = guiGridListGetColumnsMovable(source)
						
						for i = 0, guiGridListGetColumnCount(source) - 1 do
							local ix, _, iw = guiGridListGetItemBounds(source, 0, i + 1)
							
							-- off the scrollable area, since we are going from 0..n X everything after this point will be off too
							if ix > (x + w) then
								return
							end
							
							if ix > x then
								-- 8 is the sizable area width, 7 for the gridlist left border
								if currentGridlistDrag == nil and (absoluteX >= (ix + iw - 7) and absoluteX <= (ix + iw + 8 - 7 - 2)) then
									currentGridlistResize = {gridlist = source, x = absoluteX, columnID = i + 1, width = iw}
									return
								elseif currentGridlistResize == nil and movable and (absoluteX >= (ix) and absoluteX <= (ix + iw - 8)) then
									currentGridlistDrag = {
										gridlist = source, 
										columnID = i + 1, 
										x = absoluteX, 
										y = absoluteY, 
										bounds = {xMin = ix, xMax = ix + iw - 8, yMin = y + 3, yMax = y + 24}
									}
									return
								end
							end
						end
					else
						-- thumb is 19px tall?
						if vert and absoluteX >= (x + w - 19) and absoluteX < (x + w) --[[and absoluteY >= (y + 19)]] and absoluteY < (y + h - 20) then
							vScroll = guiGridListGetVerticalScrollPosition(source)
							
							local scrollHeight = (h - 19 - 19 - 20) - 19
							local scroll = math.floor(scrollHeight * (vScroll / 100))
							
							if (absoluteY >= (y + 19 + scroll) and absoluteY < (y + 19 + scroll + 19)) then
								currentlyScrolling.vertical = true
							else
								currentlyScrolling.verticalClick = true
							end
							
							currentlyScrolling.element = source
						elseif horz and absoluteX < (x + w - 20) and absoluteY >= (y + h - 19) and absoluteY < (y + h) then
							hScroll = guiGridListGetHorizontalScrollPosition(source)

							local scrollWidth = (w - 19 - 19 - 20) - 19
							local scroll = math.floor(scrollWidth * (hScroll / 100))
							
							if (absoluteX >= (x + 19 + scroll) and absoluteX < (x + 19 + scroll + 19)) then
								currentlyScrolling.horizontal = true
							else
								currentlyScrolling.horizontalClick = true
							end	
							
							currentlyScrolling.element = source
						end
					end
				end
			end
        end
    end
)
 
-- this catches mouse ups for detecting when resizing or dragging has finished
addEventHandler("onClientClick", root,
    function(button, state, absoluteX, absoluteY, worldX, worldY, worldZ, clickedElement)
        if button == "left" and state == "up" then
			if currentGridlistResize then
				-- update our cache data
				guiGridListSetColumnWidth(currentGridlistResize.gridlist, currentGridlistResize.columnID, currentGridlistResize.width + (absoluteX - currentGridlistResize.x), false)

				-- resizing smaller when at the end of the scrollable area creates funny business with the scrollable area width
				-- not worth trying to figure out wtf went on, so as it is no longer correct just blank our cache
				-- cache is rebuilt next time one of the width functions is called
				if math.ceil(guiGridListGetHorizontalScrollPosition(currentGridlistResize.gridlist)) == 100 then
					setElementData(currentGridlistResize.gridlist, "guieditor.internal:gridlistEffectiveWidth", false)
				end
				
				currentGridlistResize = nil
			end
			
			if currentGridlistDrag then
				if currentGridlistDrag.passedThreshhold then
					local x, y = guiGetAbsolutePosition(currentGridlistDrag.gridlist)
					local w, h = guiGetSize(currentGridlistDrag.gridlist, false)
					
					for i = 0, guiGridListGetColumnCount(currentGridlistDrag.gridlist) - 1 do
						local ix, _, iw = guiGridListGetItemBounds(currentGridlistDrag.gridlist, 0, i + 1)
						
						if ix > (x + w) then
							return
						end
						
						if ix > x then
							if valueInRange(absoluteX, ix, ix + iw - 7) and valueInRange(absoluteY, currentGridlistDrag.bounds.yMin, currentGridlistDrag.bounds.yMax) then
								--outputDebug("swapped " .. tostring(currentGridlistDrag.columnID) .. " to " .. tostring(i + 1))
								
								local columns = getElementData(currentGridlistDrag.gridlist, "guieditor.internal:gridlistColumns") or {} 
								
								for j = math.min(currentGridlistDrag.columnID, i + 1), math.max(currentGridlistDrag.columnID, i + 1) do
									columns[j].cumulativeWidth = nil
								end
								
								local temp = table.remove(columns, currentGridlistDrag.columnID)
								table.insert(columns, i + 1, temp)
								
								setElementData(currentGridlistDrag.gridlist, "guieditor.internal:gridlistColumns", columns)	
								
								currentGridlistDrag = nil
								return
							end
						end
					end
				end
				
				currentGridlistDrag = nil
			end
			
			if currentlyScrolling.vertical or currentlyScrolling.horizontal then
				currentlyScrolling.element = nil
				currentlyScrolling.previous = nil
				currentlyScrolling.vertical = false
				currentlyScrolling.horizontal = false
			end
			
			if currentlyScrolling.verticalClick then
				triggerEvent("onClientGUIGridListScroll", currentlyScrolling.element, true, guiGridListGetVerticalScrollPosition(currentlyScrolling.element))
				
				currentlyScrolling.element = nil
				currentlyScrolling.previous = nil
				currentlyScrolling.verticalClick = false
			end
			
			if currentlyScrolling.horizontalClick then
				triggerEvent("onClientGUIGridListScroll", currentlyScrolling.element, false, guiGridListGetHorizontalScrollPosition(currentlyScrolling.element))
				
				currentlyScrolling.element = nil
				currentlyScrolling.previous = nil
				currentlyScrolling.horizontalClick = false
			end			
        end
    end
)
 
-- track any currently active column resize or move actions
addEventHandler("onClientCursorMove", root,
    function(_, _, absoluteX, absoluteY)
        if currentGridlistResize then
			guiGridListSetColumnWidth(currentGridlistResize.gridlist, currentGridlistResize.columnID, currentGridlistResize.width + (absoluteX - currentGridlistResize.x), false)
		end
		
		if currentGridlistDrag then
			if valueInRange(absoluteX, currentGridlistDrag.bounds.xMin, currentGridlistDrag.bounds.xMax) and
				valueInRange(absoluteY, currentGridlistDrag.bounds.yMin, currentGridlistDrag.bounds.yMax) then
				
				local deltaX = absoluteX - currentGridlistDrag.x
				local deltaY = absoluteY - currentGridlistDrag.y
				
				-- 12 is the movement threshhold
				-- see: https://code.google.com/p/mtasa-blue/source/browse/trunk/vendor/cegui-0.4.0-custom/src/elements/CEGUIListHeaderSegment.cpp
				if ((deltaX > 12) or (deltaX < -12)) or ((deltaY > 12) or (deltaY < -12)) then
					currentGridlistDrag.passedThreshhold = true
				end
			end
		end
		
		if currentlyScrolling.vertical then
			local _, y = guiGetAbsolutePosition(currentlyScrolling.element)
			local _, h = guiGetSize(currentlyScrolling.element, false)

			if absoluteY >= (y + 19) and absoluteY < (y + h - 20 - 19) then				
				local scroll = guiGridListGetVerticalScrollPosition(currentlyScrolling.element)
				
				if scroll ~= currentlyScrolling.previous then
					triggerEvent("onClientGUIGridListScroll", currentlyScrolling.element, true, scroll)
					currentlyScrolling.previous = scroll
				end
			end
		end
		
		if currentlyScrolling.horizontal then
			local x = guiGetAbsolutePosition(currentlyScrolling.element)
			local w = guiGetSize(currentlyScrolling.element, false)

			if absoluteX >= (x + 19) and absoluteX < (x + w - 20 - 19) then				
				local scroll = guiGridListGetHorizontalScrollPosition(currentlyScrolling.element)
				
				if scroll ~= currentlyScrolling.previous then
					triggerEvent("onClientGUIGridListScroll", currentlyScrolling.element, false, scroll)
					currentlyScrolling.previous = scroll
				end
			end
		end
    end
)

addEventHandler("onClientRender", root,
    function()
		for gridlist,_ in pairs(nextFrameChecks) do
			guiGridListCalculateScrollbarVisibility(gridlist)
			nextFrameChecks[gridlist] = nil
		end
		
		for gridlist,vertical in pairs(nextFrameScrolls) do
			local scroll
			
			if vertical then
				scroll = guiGridListGetVerticalScrollPosition(gridlist)
			else
				scroll = guiGridListGetHorizontalScrollPosition(gridlist)
			end
			
			if scroll ~= currentlyScrolling.previous then
				triggerEvent("onClientGUIGridListScroll", gridlist, vertical, scroll)
			end
			
			currentlyScrolling.previous = scroll
			nextFrameScrolls[gridlist] = nil
		end
	end
)

--[[
addEventHandler("onClientResourceStart", resourceRoot,
    function()
        -- testthing = guiCreateGridList(600, 350, 400, 200, false)
		-- guiGridListSetSelectionMode(testthing, 3)
        -- guiGridListAddColumn(testthing, "thing 0.2", 0.2)
		-- guiGridListAddColumn(testthing, "thing 0.3", 0.3)

		-- guiGridListAddRow(testthing)
		-- guiGridListSetItemText(testthing, 0, 1, "1a", false, false)
		-- guiGridListSetItemText(testthing, 0, 2, "hello there", false, false)
		
		-- --guiGridListAutoSizeColumn(testthing, 2)
		-- --guiGridListSetColumnWidth(testthing, 1, 21, false)
		
		-- guiGridListSetColumnsMovable(testthing, true)
		
        -- for i = 1, 50 do
            -- guiGridListAddRow(testthing)
			-- guiGridListSetItemText(testthing, i, 1, tostring(i), false, false)
			
			-- local c = guiGridListAddColumn(testthing, "thing" .. tostring(i), 0.1)
			-- guiGridListSetItemText(testthing, 0, c, tostring(i), false, false)
        -- end
		-- guiGridListSetSelectedItem(testthing, 3, 1)
	

	    testthing = guiCreateGridList(600, 350, 400, 200, false)
		guiGridListSetSelectionMode(testthing, 3)

		guiGridListAddColumn(testthing, "Col 1", 0.9)
		guiGridListAddColumn(testthing, "Col 2", 0.4)
		guiGridListAddColumn(testthing, "Col 3", 0.4)
		guiGridListAddColumn(testthing, "Col 4", 0.4)
		
        for row = 0, 20 do
			guiGridListAddRow(testthing)
		
			for col = 1, 2 do
				guiGridListSetItemText(testthing, row, col, "text", false, false)
				guiGridListSetItemTextOverlay(testthing, row, col, " - hello  " .. tostring(col))
			end
        end	
    end
)

addEventHandler("onClientRender", root,
    function()
		local row,col = guiGridListGetSelectedItem(testthing)	
		local x, y = guiGridListGetItemBounds(testthing, row, col)
		local v, h = guiGridListGetScrollBars(testthing)
		
		local a = -1
		local b = 0
		local c = a * 0
        dxDrawText(tostring(guiGridListGetHorizontalScrollPosition(testthing)), 48, 447, 295, 478, tocolor(255, 0, 0, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
		
		local validDrag = currentGridlistDrag ~= nil and currentGridlistDrag.passedThreshhold or false
		dxDrawText(tostring(validDrag), 48, 467, 295, 498, tocolor(255, 0, 0, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
		
		
		local visibility = getElementData(testthing, "guieditor.internal:gridlistScrollbarVisibility") or {}
		dxDrawText("Scrollbars: " .. tostring(visibility.vertical) .. ", " .. tostring(visibility.horizontal), 48, 487, 295, 528, tocolor(255, 0, 0, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
		
		--guiGridListSetSelectedItem(testthing, 0, 1)
			
		dxDrawText("Selected: " .. tostring(row) .. ", " .. tostring(col), 48, 507, 295, 548, tocolor(255, 0, 0, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
		
		local width = guiGridListGetColumnWidth(testthing, 1)
		dxDrawText("Col width: " .. tostring(width), 48, 527, 295, 568, tocolor(255, 0, 0, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
		
		local cx, cy = getCursorPosition(true)
		if not cx then
			cx, cy = 0,0
		end
		
		dxDrawText(string.format("Cursor: %d, %d", cx, cy), 48, 547, 295, 588, tocolor(255, 0, 0, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
		
		dxDrawText("Selected text: '" .. guiGridListGetItemText(testthing, row, col) .. "'", 48, 567, 295, 608, tocolor(255, 0, 0, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)

		dxDrawImage(x - 5, y - 5, 10, 10, ":GUIEditor/images/dx_elements/radio_button.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
		
		local xt, yt, wt, ht = guiGridListGetItemTextBounds(testthing, row, col)
		local bx, by, bw, bh = guiGridListGetItemVisibleBounds(testthing, row, col)
		dxDrawRectangle(bx, by, bw, bh, tocolor(252, 49, 1, 255), true)
		
		if guiGridListIsPointWithinVisibleBounds(testthing, xt, yt) then
			dxDrawText(guiGridListGetItemText(testthing, row, col), xt, yt, xt + guiGridListGetColumnWidth(testthing, col), yt + rowHeight, tocolor(255, 255, 255, 255), 1, "default", "left", "top", true, false, true)
			
			local tw = dxGetTextWidth(guiGridListGetItemText(testthing, row, col))
			
			dxDrawText(" - blah blah blah", xt + tw, yt, xt + wt, yt + ht, tocolor(0, 0, 0, 255), 1, "default", "left", "bottom", true, false, true, false, true)
		end
		
		dxDrawText("Scrolling: v: " .. tostring(currentlyScrolling.vertical) .. ", h: " .. tostring(currentlyScrolling.horizontal), 48, 587, 295, 628, tocolor(255, 0, 0, 255), 1.00, "default-bold", "left", "top", false, false, false, false, false)
	end
)
]]