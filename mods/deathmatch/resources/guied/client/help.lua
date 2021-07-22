--[[--------------------------------------------------
	GUI Editor
	client
	help.lua
	
	creates the in-game help gui
--]]--------------------------------------------------


HelpWindow = {
	gui = {},
	-- currently showing items, changes depending on search
	items = {},
	itemsGrouped = {},
	-- cached list of all items
	baseItems = {},
	baseItemsGrouped = {},	
	searchTimer,
	defaultTitle = "Help",
	defaultDescription = [[Click on the text field above to search for help on a topic.
	
	Any information relevant to your search will display in the dropdown menu. 
	
	Double clicking the item in the menu will load a full description.
	]]
}


function HelpWindow.create()
    HelpWindow.gui.wndMain = guiCreateWindow((gScreen.x - 600) / 2, (gScreen.y - 400) / 2, 600, 400, "Help Documentation", false)
	guiWindowSetSizable(HelpWindow.gui.wndMain, false)
	guiWindowTitlebarButtonAdd(HelpWindow.gui.wndMain, "Close", "right", HelpWindow.close)
	guiSetAlpha(HelpWindow.gui.wndMain, 0.90) 
 
	HelpWindow.gui.list = ExpandingGridList:create(10, 27, 580, 0, false, HelpWindow.gui.wndMain)
	HelpWindow.gui.list:addColumn("Items", 0.95)
	HelpWindow.gui.list.maxRows = 20
	guiSetProperty(HelpWindow.gui.list.gridlist, "InheritsAlpha", "False")
	
    HelpWindow.gui.edtSearch = guiCreateEdit(-1, -7, 582, 27, "Search...", false, HelpWindow.gui.list.gridlist)
  	guiSetProperty(HelpWindow.gui.edtSearch, "InheritsAlpha", "False")
	guiSetProperty(HelpWindow.gui.edtSearch, "ClippedByParent", "False")
	guiSetProperty(HelpWindow.gui.edtSearch, "AlwaysOnTop", "True")
	
	HelpWindow.gui.lblTitle = guiCreateLabel(10, 48, 580, 20, "", false, HelpWindow.gui.wndMain)
	guiSetProperty(HelpWindow.gui.lblTitle, "MousePassThroughEnabled", "True")
	guiSetFont(HelpWindow.gui.lblTitle, "default-bold-small")   
	guiLabelSetHorizontalAlign(HelpWindow.gui.lblTitle, "center", true)
	guiLabelSetVerticalAlign(HelpWindow.gui.lblTitle, "bottom")
	guiSetColour(HelpWindow.gui.lblTitle, unpack(gColours.primary))
	
	HelpWindow.gui.imgTitleLeft = guiCreateStaticImage(10, 70, 290, 1, "images/dot_white.png", false, HelpWindow.gui.wndMain)
	HelpWindow.gui.imgTitleRight = guiCreateStaticImage(300, 70, 290, 1, "images/dot_white.png", false, HelpWindow.gui.wndMain)
	guiSetProperty(HelpWindow.gui.imgTitleLeft, "ImageColours", string.format("tl:00%s tr:FF%s bl:00%s br:FF%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(HelpWindow.gui.imgTitleRight, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))
	
	HelpWindow.gui.lblDescription = guiCreateLabel(10, 73, 580, 317, "", false, HelpWindow.gui.wndMain)
	guiLabelSetHorizontalAlign(HelpWindow.gui.lblDescription, "center", true)
	guiLabelSetVerticalAlign(HelpWindow.gui.lblDescription, "top")
	guiSetProperty(HelpWindow.gui.lblDescription, "MousePassThroughEnabled", "True")
	
	addEventHandler("onClientGUIChanged", HelpWindow.gui.edtSearch,
		function()
			if HelpWindow.searchTimer and isTimer(HelpWindow.searchTimer) then
				killTimer(HelpWindow.searchTimer)
			end
				
			if guiGetText(source) == "" then
				HelpWindow.showDefaults()
			else
				HelpWindow.searchTimer = setTimer(HelpWindow.search, 400, 1, guiGetText(source))
			end
		end
	, false)
	addEventHandler("onClientGUIFocus", HelpWindow.gui.edtSearch,
		function()
			if guiGetText(source) == "Search..." then
				guiSetText(source, "")
			end
		end
	, false)		
	
	HelpWindow.gui.list.onRowDoubleClick = 
		function(row, col, text, resource, data)
			HelpWindow.resizeList(true)
			
			local description = HelpWindow.items[text].text or "[NO DESCRIPTION]"
			guiSetText(HelpWindow.gui.lblDescription, description:gsub("\\n","\n") .. "\n\nTags: " .. table.concat(HelpWindow.items[text].tags, ', '))
			
			guiSetText(HelpWindow.gui.lblTitle, text)
		end
		
	HelpWindow.gui.list.onRowSetText = 
		function(row, col, text)	
			local additional
			
			if HelpWindow.items[text] then
				additional = HelpWindow.items[text].text or false
			end
			
			if not additional and HelpWindow.baseItemsGrouped[text] then
				additional = "Group header"
			end
			
			if additional then
				guiGridListSetItemTextOverlay(HelpWindow.gui.list.gridlist, row, col, " - " .. additional, false)
			end
		end
		
	HelpWindow.gui.list.onRowExpand = HelpWindow.resizeList
	HelpWindow.gui.list.onRowCollapse = HelpWindow.resizeList
	HelpWindow.gui.list.onPopulated = HelpWindow.resizeList

	guiSetVisible(HelpWindow.gui.wndMain, false)
	
	HelpWindow.load()
	doOnChildren(HelpWindow.gui.wndMain, setElementData, "guieditor.internal:noLoad", true)
end


function HelpWindow.open()
	if not HelpWindow.gui.wndMain then
		HelpWindow.create()
	end
	
	guiSetText(HelpWindow.gui.edtSearch, "Search...")
	guiSetText(HelpWindow.gui.lblTitle, HelpWindow.defaultTitle)
	guiSetText(HelpWindow.gui.lblDescription, HelpWindow.defaultDescription)
	
	HelpWindow.showDefaults()
	
	guiSetVisible(HelpWindow.gui.wndMain, true)
	guiBringToFront(HelpWindow.gui.wndMain)
end


function HelpWindow.close()
	if not HelpWindow.gui.wndMain then
		return
	end
	
	guiSetVisible(HelpWindow.gui.wndMain, false)
end


function HelpWindow.showDefaults()
	HelpWindow.itemsGrouped = table.copy(HelpWindow.baseItemsGrouped)
	HelpWindow.gui.list:setData(HelpWindow.itemsGrouped)	
end


function HelpWindow.load()
	local file = xmlLoadFile("client/help_documentation.xml")
	
	if file then
		for i,node in ipairs(xmlNodeGetChildren(file)) do
			local name = xmlNodeGetAttribute(node, "name") or "[NO NAME]"
			local description = xmlNodeGetAttribute(node, "description") or "[NO DESCRIPTION]"
			local group = xmlNodeGetAttribute(node, "groups") or "[NO GROUPS]"
			local groups = split(group, ',')
			local tag = xmlNodeGetAttribute(node, "tags") or ""
			local tags = split(tag, ',')
			
			HelpWindow.items[name] = {text = description, groups = groups, tags = tags}
			HelpWindow.baseItems[name] = {text = description, groups = groups, tags = tags}
			
			for k,g in ipairs(groups) do
				-- quick fix to ignore the all items group, should really be removed from the xml
				if g ~= "All Items" then
					if not HelpWindow.itemsGrouped[g] then
						HelpWindow.itemsGrouped[g] = {}
					end
					
					if not HelpWindow.baseItemsGrouped[g] then
						HelpWindow.baseItemsGrouped[g] = {}
					end			
					
					HelpWindow.itemsGrouped[g][ #HelpWindow.itemsGrouped[g] + 1 ] = name
					HelpWindow.baseItemsGrouped[g][ #HelpWindow.baseItemsGrouped[g] + 1 ] = name
				end
			end
		end
		
		HelpWindow.gui.list:setData(HelpWindow.itemsGrouped)
		
		xmlUnloadFile(file)
	else
		outputDebug("Couldn't open help_documentation.xml file")
	end
end



function HelpWindow.search(text)
	if not HelpWindow.gui.wndMain then
		return
	end
	
	if text == "Search..." then
		return
	end
	
	if not text then
		HelpWindow.itemsGrouped = table.copy(HelpWindow.baseItemsGrouped)
		HelpWindow.gui.list:setData(HelpWindow.itemsGrouped)
		return
	end

	--local t = table.copy(HelpWindow.baseItemsGrouped)
	text = string.lower(text)
	
	local nameMatches = {}
	local groupMatches = {}
	local tagMatches = {}
	
	for itemName, data in pairs(HelpWindow.baseItems) do
		if string.lower(itemName) == text then
			table.insert(nameMatches, 1, itemName)
		elseif string.contains(string.lower(itemName), text, true) then
			nameMatches[#nameMatches + 1] = itemName
		end
		
		for _,tag in ipairs(data.tags or {}) do
			if string.lower(tag or "") == text then
				if not table.find(tagMatches, itemName) and not table.find(nameMatches, itemName) then
					table.insert(tagMatches, 1, itemName)
				end
			elseif string.contains(string.lower(tag or ""), text, true) then
				if not table.find(tagMatches, itemName) and not table.find(nameMatches, itemName) then
					table.insert(tagMatches, 1, itemName)
				end				
			end
		end
	end
	
	for groupName, items in pairs(HelpWindow.baseItemsGrouped) do
		if string.lower(groupName) == text then
			table.insert(groupMatches, 1, groupName)
		elseif string.contains(string.lower(groupName), text, true) then
			groupMatches[#groupMatches + 1] = groupName
		end
	end
	

	local merged = table.merge(table.merge(nameMatches, groupMatches), tagMatches)
	
	HelpWindow.itemsGrouped = HelpWindow.baseItemsGrouped
	HelpWindow.gui.list:setData(HelpWindow.baseItemsGrouped, merged)
end


function HelpWindow.resizeList(hide)
	if not HelpWindow.gui.wndMain then
		return
	end
	
	local w, h = guiGetSize(HelpWindow.gui.list.gridlist, false)
	
	if hide == true then
		guiSetSize(HelpWindow.gui.list.gridlist, w, 0, false)
	else
		-- 14 is the height of a single row
		local height = math.min(guiGridListGetRowCount(HelpWindow.gui.list.gridlist), HelpWindow.gui.list.maxRows or 0) * 14
		
		local left, top, right, bottom = guiGridListGetBorderWidths(HelpWindow.gui.list.gridlist)
		
		guiSetSize(HelpWindow.gui.list.gridlist, w, height + top + bottom, false)
		
		guiGridListRepositionOverlays(HelpWindow.gui.list.gridlist)
	end
end


function HelpWindow.click()
	if not HelpWindow.gui.wndMain then
		return
	end
	
	local element = guiGetHoverElement()
	
	if not exists(element) or element == HelpWindow.gui.wndMain or element == HelpWindow.gui.lblDescription then
		HelpWindow.resizeList(true)
	elseif exists(element) and element == HelpWindow.gui.edtSearch then
		HelpWindow.resizeList()
	end
end


-- not used
function splitLinesForLabel(text, width, splitter)
	local lineWidth = 0
	local words = {}
	local space = " "
	
	if splitter == "" then
		text:gsub(".", function(c)
			words[#words + 1] = c
		end)
		
		space = ""
	else
		words = split(text, splitter or ' ')
	end
	
	local line = ""
	local i = 1
	local outputLines = {}
	
	while true do
		if i > #words then
			outputLines[#outputLines + 1] = line
			break
		end
	
		local oldLine = line
		line = line .. (line ~= "" and space or "") .. words[i]
		
		-- if the new line is too long
		if dxGetTextWidth(line) > width then
			-- if the next word on its own is longer than the width
			if dxGetTextWidth(words[i]) > width then
				line = oldLine
				
				local oldLineSpaced = line..space
				local lineCount = oldLineSpaced:len()
				local wordSplit = splitLinesForLabel(oldLineSpaced .. words[i], width, "")
				
				if #wordSplit > 0 then
					wordSplit[1] = wordSplit[1]:sub(lineCount + 1)
				end
				
				for k = 1, #wordSplit do
					if k == 1 then
						words[i] = wordSplit[k]
					else
						table.insert(words, i + (k - 1), wordSplit[k])
					end
				end
			else
				-- remove the last added word, and set this line as done
				outputLines[#outputLines + 1] = oldLine
				line = ""
			end
		else
			i = i + 1
		end
	end
	
	return outputLines
end