--[[--------------------------------------------------
	GUI Editor
	client
	main.lua
	
	Released as is, you are free to do whatever you want with the code
	
	For any questions please try the following:
		MTA forum post: http://forum.mtasa.com/viewtopic.php?f=108&t=22831
		MTA community post: http://community.mtasa.com/index.php?p=resources&s=details&id=141
		PM me on the MTA forum (user 'Remp'): http://forum.mtasa.com/ucp.php?i=pm&mode=compose&u=25266
		Find me on GTANet irc (user 'Remp')
	

	Bugs/issues:
		- cannot get the original filepath of a gui image
		- many other elements have properties that can be set and never got
		- gridlists crash guiGetProperties
		- guiGetFont does not return an element when a custom font is used
			
	Wishlist:
		- make multiple selection right click menu smarter when selecting many of the same element type
		- better editbox support (highlighting from outside the bounds, multiline editing)
		- GUI Editor wiki page
		- Output in OO format
		- Document all new changes
		- add undo/redo actions for gridlist options
		- Fix the problems with relative DX loading/output
		
	Changes:

--]]--------------------------------------------------

gEnabled = false

gFilepathPrefix = ":"..tostring(getResourceName(resource)).."/"

gRadioButtonGroupID = 1

gScreen = {}
gScreen.x, gScreen.y = guiGetScreenSize()

gGUISides = {left = 0, right = 1, top = 2, bottom = 3}
gGUIDimensions = {width = 4, height = 5}
gEventPriorities = {
	elementSelectRender = "high+101",
	elementBorderRender = "high+100",
	DXElementRender = "high+10",

	snappingRender = "low-100",
	hackClick = "low-99999"
}

gColours = {
	primary = {255, 69, 59, 255}, -- red
	secondary = {255, 118, 46, 255}, -- orange
	tertiary = {232, 42, 104, 255}, -- pink
	
	defaultLabel = {255, 255, 255},
	grey = {120, 120, 120},
	--primaryLight = {255, 153, 145, 255},
	primaryLight = {237, 126, 119, 255},
}
-- primary, secondary, tertiary, quaternary, quinary, senary, septenary, octonary, nonary, and denary

gAreaColours = {
	primary = "777777",
	secondary = "CCCCCC",
	
	dark = "000000",
}
gAreaColours.primaryPacked = {gAreaColours.primary, gAreaColours.primary, gAreaColours.primary, gAreaColours.primary}
gAreaColours.secondaryPacked = {gAreaColours.secondary, gAreaColours.secondary, gAreaColours.secondary, gAreaColours.secondary}
gAreaColours.darkPacked = {gAreaColours.dark, gAreaColours.dark, gAreaColours.dark, gAreaColours.dark}

gGUITypes = {
	"gui-window",
	"gui-button",
	"gui-label",
	"gui-checkbox",
	"gui-memo",
	"gui-edit",
	"gui-gridlist",
	"gui-progressbar",
	"gui-tabpanel",
	"gui-tab",
	"gui-radiobutton",
	"gui-staticimage",
	"gui-scrollpane",
	"gui-scrollbar",
	"gui-combobox"
}

gFonts = {
	"default-normal",
	"default-small",
	"default-bold-small",
	"clear-normal",
	"sa-header",
	"sa-gothic",
}

gDXFonts = {
	"default",
	"default-bold",
	"clear",
	"arial",
	"sans",
	"pricedown",
	"bankgothic",
	"diploma",
	"beckett",
}


gDefaults = {
	alpha = {
		["gui-window"] = 80,
		["gui-button"] = 100,
		["gui-label"] = 100,
		["gui-checkbox"] = 100,
		["gui-memo"] = 100,
		["gui-edit"] = 100,
		["gui-gridlist"] = 100,
		["gui-progressbar"] = 100,
		["gui-tabpanel"] = 100,
		["gui-tab"] = 100,
		["gui-radiobutton"] = 100,
		["gui-staticimage"] = 100,
		["gui-scrollpane"] = 100,
		["gui-scrollbar"] = 100,
		["gui-combobox"] = 100,
	},
	
	colour = {
		["gui-window"] = {r = 255, g = 255, b = 255, a = 255},
		["gui-button"] = {r = 124, g = 124, b = 124, a = 255},
		["gui-label"] = {r = 255, g = 255, b = 255, a = 255},
		["gui-checkbox"] = {r = 255, g = 255, b = 255, a = 255},
		["gui-memo"] = {r = 0, g = 0, b = 0, a = 255},
		["gui-edit"] = {r = 0, g = 0, b = 0, a = 255},
		["gui-gridlist"] = nil,
		["gui-progressbar"] = nil,
		["gui-tabpanel"] = nil,
		["gui-tab"] = nil,
		["gui-radiobutton"] = {r = 255, g = 255, b = 255, a = 255},
		["gui-staticimage"] = {r = 255, g = 255, b = 255, a = 255},
		["gui-scrollpane"] = nil,
		["gui-scrollbar"] = nil,
		["gui-combobox"] = {r = 0, g = 0, b = 0, a = 255},
	},
	
	properties = {},
	
	font = {
		["gui-window"] = "default-normal",
		["gui-button"] = "default-normal",
		["gui-label"] = "default-normal",
		["gui-checkbox"] = "default-normal",
		["gui-memo"] = "default-normal",
		["gui-edit"] = "default-normal",
		["gui-gridlist"] = "default-normal",
		["gui-progressbar"] = "default-normal",
		["gui-tabpanel"] = "default-normal",
		["gui-tab"] = "default-normal",
		["gui-radiobutton"] = "default-normal",
		["gui-staticimage"] = "default-normal",
		["gui-scrollpane"] = "default-normal",
		["gui-scrollbar"] = "default-normal",
		["gui-combobox"] = "default-normal",
	}
}


gCustomFonts = {}

gDataNames = {}
gDefaultInputMode = "no_binds_when_editing"
guiSetInputMode(gDefaultInputMode)


gRightClickHack = {}
gDrawSelectionList = {}


addEventHandler("onClientResourceStart", resourceRoot,
	function()
		setup()
	end
)

--[[
addEventHandler("onClientKey", root,
	function(button, downOrUp)
		if downOrUp == false then
			if button == "g" then
				if getKeyState("lctrl") or getKeyState("lshift") then
					switch()
				end
			elseif button == "lctrl" then
				if getKeyState("g") then
					switch()
				end		
			elseif button == "lshift" then
				if getKeyState("g") then
					switch()
				end
			end
		end
	end
)
]]
bindKey("g", "down",
	function()
		if getKeyState("lshift") then
			switch()
		end
	end
)
bindKey("lshift", "down",
	function()
		if getKeyState("g") then
			switch()
		end
	end
)



function setup()
	if gEnabled then
		Settings.setup()
		
		if toBool(Settings.loaded.guieditor_update_check.value) then
			checkForUpdates(true)
		end

		createMenus()
		
		showCursor(true)		
	end
end


function switch()
	if gEnabled then
		ContextBar.add("GUI Editor disabled")
		gEnabled = false
		showCursor(false)
	else
		gEnabled = true
		setup()
		ContextBar.add("GUI Editor enabled")	
		UndoRedo.updateGUI()
	end
end
addCommandHandler("guied", switch)


function checkForUpdates(automatic)
	if not gEnabled then
		return
	end
	
	triggerServerEvent("guieditor:server_checkUpdateStatus", localPlayer, automatic)
end


addEvent("guieditor:client_getUpdateStatus", true)
addEventHandler("guieditor:client_getUpdateStatus", root,
	function(automatic, update, newVersion, oldVersion)
		if update then
			local mbox = MessageBox_Info:create("Update Available", "There is a new version of GUI Editor available at community.mtasa.com\n\nCurrent Version: "..tostring(oldVersion).."\nNew Version: "..tostring(newVersion))
		else
			if not automatic then
				if update == nil then
					local mbox = MessageBox_Info:create("Error", "Could not get update status.\nCheck ACL permissions and website availability.\n\nCurrent Version: "..tostring(oldVersion))
				else
					local mbox = MessageBox_Info:create("No Updates Available", "You are running the latest version of the GUI Editor.\n\nCurrent Version: "..tostring(oldVersion))
				end
			end
		end
	end
)



addEventHandler("onClientClick", root,
	function(button, state, absoluteX, absoluteY)
		if not gEnabled then
			return
		end
		
		if button == "right" and state == "up" then
			for i, menu in ipairs(Menu.instances) do
				if menu.visible then
					menu:close()
				end
			end	

			local t = Tutorial.active()
			if t then
				if t.id ~= "main" then
					return
				end
			end
			
			if table.count(Multiple.inside) > 0 then
				gMenus.multiple:open(absoluteX, absoluteY)
				gMenus.multiple.guiSelection = Multiple.inside
				return
			else
				gMenus.multiple.guiSelection = nil
			end
			
			
			local dx, index = dxGetHoverElement()
			
			-- dx above gui elements
			if dx and dx:postGUI() then
				if resolutionPreview.active then
					resolutionPreview.prepareMenu() 
					gMenus.main:open(absoluteX, absoluteY, true)
					return
				end

				if dx.dxType == gDXTypes.line then
					gMenus.dxLine:open(absoluteX, absoluteY, dx)
				elseif dx.dxType == gDXTypes.rectangle then
					gMenus.dxRectangle:open(absoluteX, absoluteY, dx)
				elseif dx.dxType == gDXTypes.image then
					gMenus.dxImage:open(absoluteX, absoluteY, dx)
				elseif dx.dxType == gDXTypes.text then
					gMenus.dxText:open(absoluteX, absoluteY, dx)
				end
				return
			end			
			
			local e = guiGetHoverElement()
			
			-- dx below gui elements
			if (not e) and dx and (not dx:postGUI()) then
				if resolutionPreview.active then
					resolutionPreview.prepareMenu() 
					gMenus.main:open(absoluteX, absoluteY, true)
					return
				end

				if dx.dxType == gDXTypes.line then
					gMenus.dxLine:open(absoluteX, absoluteY, dx, true)
				elseif dx.dxType == gDXTypes.rectangle then
					gMenus.dxRectangle:open(absoluteX, absoluteY, dx, true)
				elseif dx.dxType == gDXTypes.image then
					gMenus.dxImage:open(absoluteX, absoluteY, dx, true)
				elseif dx.dxType == gDXTypes.text then
					gMenus.dxText:open(absoluteX, absoluteY, dx, true)
				end
				return			
			end
			
			if not e then
				if resolutionPreview.active then
					resolutionPreview.prepareMenu() 
				else
					for i = 1, #gMenus.main.items - 1 do
						gMenus.main:getItem(i):setEnabled(true)
					end					
				end
			
				gMenus.main:open(absoluteX, absoluteY, true)
			else
				if resolutionPreview.active then
					resolutionPreview.prepareMenu() 
					gMenus.main:open(absoluteX, absoluteY, true)
					return
				end
					
				--if getElementData(e, "guieditor.internal:redirect") then
				--	e = getElementData(e, "guieditor.internal:redirect")
				--end

				if managed(e) then
					local elementType = string.lower(getElementType(e))
					elementType = stripGUIPrefix(elementType)
					
					if gMenus[elementType] then
						gMenus[elementType]:open(absoluteX, absoluteY, e, true)
					else
						gMenus.main:open(absoluteX, absoluteY, true)
					end
				else
					if getElementData(e, "guieditor.internal:noLoad") then
						gMenus.noLoad:open(absoluteX, absoluteY)
					else
						gMenus.notLoaded:open(absoluteX, absoluteY, true)
					end
				end
			end		
		elseif button == "left" and state == "up" then
			
		end
		
		menuItemClick(button, state, absoluteX, absoluteY)
		
		menuClick(button, state, absoluteX, absoluteY)
		
		Creator.click(button, state, absoluteX, absoluteY)
		
		Sizer.click(button, state, absoluteX, absoluteY)
		Mover.click(button, state, absoluteX, absoluteY)
				
		resolutionPreview.click(button, state, absoluteX, absoluteY)
		
		Offset.click(button, state, absoluteX, absoluteY)
		Attacher.click(button, state, absoluteX, absoluteY)
		
		Multiple.click(button, state, absoluteX, absoluteY)
		
		HelpWindow.click(button, state, absoluteX, absoluteY)
	end
)


addEventHandler("onClientMouseEnter", root,
	function(absoluteX, absoluteY)
		if not gEnabled then
			return
		end

		Creator.enter(source, absoluteX, absoluteY)
		Attacher.enter(source, absoluteX, absoluteY)
	end
)


addEventHandler("onClientMouseLeave", root,
	function(absoluteX, absoluteY)
		if not gEnabled then
			return
		end
		
		Creator.leave(source, absoluteX, absoluteY)
		Attacher.leave(source, absoluteX, absoluteY)
	end
)


--[[--------------------------------------------------
	nasty hack to get elements that don't trigger mouse events to work
	
	each broken element is masked with a gui label completely covering it
	the label has MousePassThroughEnabled set to true so it doesn't capture any mouse events
	this means that left click will still interact with the original element (eg: open the combo box dropdown, drag the scrollbar pointer)
	
	we bind right click and on down we set MousePassThroughEnabled to false, so the labels capture mouse events again
	then we force a mouse movement (that the user doesn't see), which forces all the mouse events to update and trigger for the labels
	once the onClientClick event has completed firing (and we have done everything we need to with the right click menus)
	we set MousePassThroughEnabled back to true so the original elements can be interacted with again
	
	known problems:
		- when editboxes or memos have input focus, right clicks on broken elements don't work until you click them (to give them focus)
		- borders don't get drawn (because the enter/exit events don't fire)
		- scrollpane scrollbars cannot be dragged
			- this is a choice between either non-dragable scrollbars, or not having a border
			- since having no border would make them completely useless, having non working scrollbars and being semi-useful is the best choice
			
	Update 19/07/2014
		The mouse events now trigger for all gui elements properly. However, mouse events for children of those fixed elements are now wrong. 
		E.g. a label that is a child of a scrollpane will trigger onClientMouseEnter when the mouse is nowhere near the label
		Keeping this hack in until this is fixed in mta
--]]--------------------------------------------------
addEventHandler("onClientClick", root,
	function(button, state, absoluteX, absoluteY)
		if not gEnabled then
			return
		end
		
		if button == "right" and state == "up" then
			for element in pairs(gRightClickHack) do
				if exists(element) then
					guiSetProperty(element, "MousePassThroughEnabled", "True")
					guiSetProperty(getElementData(element, "guieditor.internal:redirect"), "ZOrderChangeEnabled", "True")
					--guiSetProperty(element, "RiseOnClick", "True")
				end
			end
		end
	end,
true, gEventPriorities.hackClick)


bindKey("mouse2", "down",
	function()
		if not gEnabled then
			return
		end
		
		for _,guiType in ipairs(gGUITypes) do
			for element in pairs(gRightClickHack) do
				if exists(element) then
					guiSetProperty(element, "MousePassThroughEnabled", "False")
					guiSetProperty(getElementData(element, "guieditor.internal:redirect"), "ZOrderChangeEnabled", "False")
					--guiSetProperty(element, "RiseOnClick", "False")
					guiBringToFront(element)
					
					for i,v in ipairs(guiGetSiblings(element)) do
						if v ~= element then
							guiBringToFront(v)
						end
					end
				end
			end
		end

		jiggleMouse()
	end
)



--[[--------------------------------------------------
	moved mouse over a GUI element
--]]--------------------------------------------------
addEventHandler("onClientMouseMove", root,
	function(absoluteX, absoluteY)
		if not gEnabled then
			return
		end

		Creator.move(source, absoluteX, absoluteY)
	end
)

--[[--------------------------------------------------
	moved mouse
--]]--------------------------------------------------
addEventHandler("onClientCursorMove", root,
	function(x, y, absoluteX, absoluteY)
		if not gEnabled then
			return
		end
		
		Sizer.move(absoluteX, absoluteY)
		Mover.move(absoluteX, absoluteY)
		
		resolutionPreview.move(absoluteX, absoluteY)
		
		Multiple.move(absoluteX, absoluteY)
		
		Snapping.snap()
	end
)



--[[--------------------------------------------------
	force trigger any gui cursor move/on/off events
--]]--------------------------------------------------
function jiggleMouse()
	if not gEnabled then
		return
	end
		
	local x, y = getCursorPosition(true)
	
	if x then
		setCursorPosition(x, y + 1)
		setCursorPosition(x, y)
	end
end



--[[--------------------------------------------------
	border drawing
--]]--------------------------------------------------
local drawBorderList = {}

addEventHandler("onClientRender", root,
	function()
		if not gEnabled then
			return
		end

		local dx, index = dxGetHoverElement()
		
		if dx then
			-- draw border
			if dx.dxType == gDXTypes.line then
				
			elseif dx.dxType == gDXTypes.rectangle then
			
			elseif dx.dxType == gDXTypes.text or dx.dxType == gDXTypes.image then
				drawBorderRaw(dx.x, dx.y, dx.width, dx.height)
			end	
		end			
		
		if guiGetHoverElement() and not Menu.anyOpen() then
			local element = guiGetHoverElement()
			
			if getElementData(element, "guieditor:border") then
				drawBorder(element)
			end
		end
		
		for _,e in ipairs(drawBorderList) do
			if exists(e) then
				drawBorder(e)
			end
		end
	end
,true, gEventPriorities.elementBorderRender)


function drawBorder(element)
	if not gEnabled then
		return
	end
	
	if not removed(element) then
		local x, y = guiGetAbsolutePosition(element)
		local w, h = guiGetSize(element, false)
		
		drawBorderRaw(x, y, w, h)
	end
end

function drawBorderRaw(x, y, w, h)
	if not gEnabled then
		return
	end
	
	if x and y and w and h then
		dxDrawLine(x, y, x + w, y, tocolor(unpack(gColours.tertiary)), 1, true)
		dxDrawLine(x, y, x, y + h, tocolor(unpack(gColours.tertiary)), 1, true)
		dxDrawLine(x + w, y, x + w, y + h, tocolor(unpack(gColours.tertiary)), 1, true)
		dxDrawLine(x, y + h, x + w, y + h, tocolor(unpack(gColours.tertiary)), 1, true)
	end
end


addEventHandler("onClientElementDataChange", root,
	function(data, oldValue)
		if not gEnabled then
			return
		end
		
		-- track all the element datas we use. This gives us an always accurate list at any point in time of which element datas any given element could have
		-- easier than defining them manually and forgetting to update the list when you add new ones
		if string.find(data, "guieditor:", 1, true) then
			gDataNames[data] = true
		end
		
		if data == "guieditor:drawBorder" then
			if getElementData(source, "guieditor:drawBorder") then
				table.insert(drawBorderList, source)
			else
				for i,e in ipairs(drawBorderList) do
					if e == source then
						table.remove(drawBorderList, i)
						break
					end
				end
			end
		elseif data == "guiSnapTo" and getElementData(source, "guiSnapTo") then
			local p = guiGetParent(source)
			
			if p and exists(p) then
				setElementData(p, "childSnaps", true)
			end
		end
	end
)


addEventHandler("onClientElementDestroy", root,
	function()
		if not gEnabled then
			return
		end
		
		for i,e in ipairs(drawBorderList) do
			if e == source then
				table.remove(drawBorderList, i)
				break
			end
		end
	end
)

function guiNeedsBorder(element)
	if exists(element) then
		if getElementData(element, "guieditor.internal:dxElement") then
			local dx = DX_Element.getDXFromElement(element)
			
			if dx then
				if dx.dxType == gDXTypes.text or dx.dxType == gDXTypes.image then
					return true
				end
			end
			
			return
		end
		
		local t = stripGUIPrefix(getElementType(element))
	
		return t == "label" or t == "checkbox" or t == "radiobutton" or t == "staticimage" or t == "scrollpane" or t == "combobox"
	end
	
	return false
end


--[[--------------------------------------------------
	selection drawing
--]]--------------------------------------------------
addEventHandler("onClientRender", root,
	function()
		if not gEnabled then
			return
		end
		
		for element,pos in pairs(gDrawSelectionList) do
			dxDrawImage(pos.x - (pos.s /  2), pos.y - (pos.s / 2), pos.s, pos.s, "images/dx_elements/radio_button.png", 0, 0, 0, tocolor(unpack(gColours.tertiary)), true)
		end
	end
,true, gEventPriorities.elementSelectRender)


function addToSelectionList(element, size)
	local x, y = guiGetAbsolutePosition(element)
	local w, h = guiGetSize(element, false)
	size = tonumber(size) or 8

	if not gDrawSelectionList[element] then
		gDrawSelectionList[element] = {x = x + (w / 2), y = y + (h / 2), s = size}
	end
end

function removeFromSelectionList(element)
	gDrawSelectionList[element] = nil
end


addEventHandler("onClientGUIFocus", guiRoot,
	function()
		if getElementType(source) == "gui-edit" or getElementType(source) == "gui-memo" and not DX_Editbox.inUse() then
			guiSetInputMode(gDefaultInputMode)
		end
	end
)


--[[--------------------------------------------------
	set element as deleted
--]]--------------------------------------------------

function guiRemove(element, createAction)
	guiSetVisible(element, false)
	setElementData(element, "guieditor:drawBorder", nil)
	
	doOnChildren(element, setElementData, "guieditor:removed", true)
	
	if createAction then
		UndoRedo.generateActionUndo(UndoRedo.presets.delete, element)
	end
end


function guiRestore(element)
	doOnChildren(element, setElementData, "guieditor:removed", nil)
	
	guiSetVisible(element, true)
end


function guiDelete(element)
	destroyElement(element)
end



function setElementOutputType(element, outputType)
	local t = outputType
	
	-- radio button menu item
	if type(outputType) == "table" then
		local i = outputType:getSelected()
		
		if i then
			t = i == 2
		end
	end

	if isBool(t) then	
		setElementData(element, "guieditor:relative", t)
	end
end


function setElementText(element)
	local multiline = false
	local t = getElementType(element)
	
	if t == "gui-button" or t == "gui-label" or t == "gui-memo" then
		multiline = true
	end
	
	local action = {}
	local currentText = guiGetText(element)
	
	if getElementData(element, "guieditor.internal:dxElement") then
		local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
		
		if dx.dxType then
			action[#action + 1] = {}
			action[#action].ufunc = DX_Text.text
			action[#action].uvalues = {dx, dx.text_}
			
			currentText = dx:text()
		end
	else
		action[#action + 1] = {}
		action[#action].ufunc = guiSetText
		action[#action].uvalues = {element, guiGetText(element)}
	end
	
	setElementData(element, "guieditor.internal:actionUndoText", action)
	
	local mbox = MessageBox_Input:create(multiline)
	mbox.element = element
	mbox:setText(currentText)
	mbox.onPostAccept =
		function()
			local action = getElementData(element, "guieditor.internal:actionUndoText")
			
			if getElementData(element, "guieditor.internal:dxElement") then
				local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
				
				if dx.dxType then
					action[#action + 1] = {}
					action[#action].rfunc = DX_Text.text
					action[#action].rvalues = {dx, guiGetText(element)}
				end
				
				action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." text"

				dx:text(guiGetText(element))
				guiSetText(element, "")
			else
				action[#action + 1] = {}
				action[#action].rfunc = guiSetText
				action[#action].rvalues = {element, guiGetText(element)}
				
				action.description = "Set " ..stripGUIPrefix(getElementType(element)).. " text"
			end
			
			UndoRedo.add(action)
			
			setElementData(element, "guieditor.internal:actionUndoText", nil)
		end
end


function divider(parent, x, y, width, colour)
	imgDividerLeft = guiCreateStaticImage(x, y, width / 2, 1, "images/dot_white.png", false, parent)
	imgDividerRight = guiCreateStaticImage(x + (width / 2), y, width / 2, 1, "images/dot_white.png", false, parent)
				
	if not colour then
		colour = gAreaColours.secondary
	end
				
	guiSetProperty(imgDividerLeft, "ImageColours", string.format("tl:00%s tr:FF%s bl:00%s br:FF%s", colour, colour, colour, colour))
	guiSetProperty(imgDividerRight, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", colour, colour, colour, colour))
	
	return imgDividerLeft, imgDividerRight
end



-- fix for guiGetFont not actually returning an element when custom fonts are used
-- this only becomes a problem for us when loading gui code
-- so when we create a custom font from code, save the filepath against the font
-- then when we set the font on an element, transfer the path data to the element
guiSetFont_ = guiSetFont
function guiSetFont(element, font)	
	guiSetFont_(element, font)

	if exists(font) and getElementData(font, "guieditor:font") then
		setElementData(element, "guieditor:font", getElementData(font, "guieditor:font"))
	end
end



function dxGetHoverElement()
	if #DX_Element.instances > 0 then
		local absoluteX, absoluteY = getCursorPosition(true)
		local e = guiGetHoverElement()
		
		-- go backwards so we get the one that is on top
		for i = #DX_Element.instances, 1, -1 do
			if (not e) or (DX_Element.instances[i].postGUI) then
				local dx = DX_Element.instances[i]
				
				if dx then
					if dx.dxType == gDXTypes.line then
						-- get distance to line
						if distToLineSquared({x = absoluteX, y = absoluteY}, {x = dx.startX, y = dx.startY}, {x = dx.endX, y = dx.endY}) <= math.max(square(dx.width or 0), square(5)) then
							return dx, i
						end
					elseif dx.dxType == gDXTypes.rectangle or dx.dxType == gDXTypes.image or dx.dxType == gDXTypes.text then
						if (absoluteX > dx.x and absoluteX < (dx.x + dx.width)) and
							(absoluteY > dx.y and absoluteY < (dx.y + dx.height)) then
							return dx, i
						end		
					end
				else
					-- something has gone wrong
					table.remove(DX_Element.instances, i)
				end
			end
		end	
	end
end




function square(x) 
	return x * x
end

function dist2(s, e)
	return square(s.x - e.x) + square(s.y - e.y) 
end

function distToLineSquared(p, s, e)
	local length = dist2(s, e)
	
	if (length == 0) then
		return dist2(p, s)
	end
	
	local t = ((p.x - s.x) * (e.x - s.x) + (p.y - s.y) * (e.y - s.y)) / length
	
	if (t < 0) then
		return dist2(p, s)
	end
	
	if (t > 1) then
		return dist2(p, e)
	end
	
	return dist2(p, {x = s.x + t * (e.x - s.x), y = s.y + t * (e.y - s.y)})
end

function distToLine(p, s, e)
	return math.sqrt(distToLineSquared(p, s, e))
end






local cancelNextSizeTrigger = {}
local delayedPositioning = {}
local delayedSizing = {}

addEventHandler("onClientGUISize", getResourceGUIElement(),
	function()
		if not gEnabled then
			return
		end
		
		if cancelNextSizeTrigger[source] then
			cancelNextSizeTrigger[source] = nil
			return true
		end
	
		local parentWidth, parentHeight = guiGetSize(source, false)
		
		if getElementData(source, "childSnaps") then
			for _,child in ipairs(getElementChildren(source)) do			
				if getElementData(child, "guiSnapTo") then	
					local left, top, right, bottom, w, h
					
					for side, value in pairs(getElementData(child, "guiSnapTo")) do
						if side and value then						
							if side == gGUISides.left then
								left = (value <= 1 and parentWidth * value or value)
							elseif side == gGUISides.right then
								right = (value <= 1 and parentWidth * value or value)	
							elseif side == gGUISides.top then
								top = (value <= 1 and parentHeight * value or value)					
							elseif side == gGUISides.bottom then
								bottom = (value <= 1 and parentHeight * value or value)	
							elseif side == gGUIDimensions.width then
								w = value
							elseif side == gGUIDimensions.height then
								h = value
							end
						end
					end	
					
					local x, y = guiGetPosition(child, false)
					local width, height = guiGetSize(child, false)	
					
					if delayedPositioning[child] then
						x, y = delayedPositioning[child][1], delayedPositioning[child][2]
					end
					
					if delayedSizing[child] then
						width, height = delayedSizing[child][1], delayedSizing[child][2]
					end
					
					if left and right then
						--guiSetPosition(child, left, y, false)
						--cancelNextSizeTrigger[child] = true
						--guiSetSize(child, parentWidth - left - right, height, false)
						delayedPositioning[child] = {left, y, false}
						delayedSizing[child] = {parentWidth - left - right, height, false}
					elseif left then
						--guiSetPosition(child, left, y, false)
						--cancelNextSizeTrigger[child] = true
						--guiSetSize(child, width, height, false)
						delayedPositioning[child] = {left, y, false}
						delayedSizing[child] = {width, height, false}
					elseif right then
						--guiSetPosition(child, parentWidth - width - right, y, false)
						--cancelNextSizeTrigger[child] = true
						--guiSetSize(child, width, height, false)
						delayedPositioning[child] = {parentWidth - width - right, y, false}
						delayedSizing[child] = {width, height, false}
					end
					
					width = guiGetSize(child, false)
					x = guiGetPosition(child, false)
					
					if delayedPositioning[child] then
						x = delayedPositioning[child][1]
					end
					
					if delayedSizing[child] then
						width = delayedSizing[child][1]
					end					
					
					if top and bottom then
						--guiSetPosition(child, x, top, false)
						--cancelNextSizeTrigger[child] = true
						--guiSetSize(child, width, parentHeight - top - bottom, false)
						delayedPositioning[child] = {x, top, false}
						delayedSizing[child] = {width, parentHeight - top - bottom, false}
					elseif top then
						--guiSetPosition(child, x, top, false)
						--cancelNextSizeTrigger[child] = true
						--guiSetSize(child, width, height, false)
						delayedPositioning[child] = {x, top, false}
						delayedSizing[child] = {width, height, false}
					elseif bottom then
						--guiSetPosition(child, x, parentHeight - height - bottom, false)
						--cancelNextSizeTrigger[child] = true
						--guiSetSize(child, width, height, false)
						delayedPositioning[child] = {x, parentHeight - height - bottom, false}
						delayedSizing[child] = {width, height, false}
					end
					
					if w and h then
						--cancelNextSizeTrigger[child] = true
						--guiSetSize(child, w, h, false)
						delayedSizing[child] = {w, h, false}
					elseif h then
						--cancelNextSizeTrigger[child] = true
						--guiSetSize(child, width, h, false)
						delayedSizing[child] = {width, h, false}
					elseif w then
						--cancelNextSizeTrigger[child] = true
						--guiSetSize(child, w, height, false)
						delayedSizing[child] = {w, height, false}
					end
				end
				
				
				if getElementData(child, "guieditor:positionCode") then
					local w,h = guiGetPosition(child, false, true, parentWidth, parentHeight)
					guiSetPosition(child, w, h, false)
				end
			end
		end
		
		if getElementData(source, "guiSizeMinimum") then
			local size = getElementData(source, "guiSizeMinimum")
			local width, height = guiGetSize(source, false)
			local cx, cy = getCursorPosition(true)
			local x, y = guiGetAbsolutePosition(source)
			
			if width < size.w and height < size.h then
				cancelNextSizeTrigger[source] = true
				guiSetSize(source, size.w, size.h, false)
				setCursorPosition(x + size.w, y + size.h)
			elseif width < size.w then	
				cancelNextSizeTrigger[source] = true
				guiSetSize(source, size.w, height, false)
				setCursorPosition(x + size.w, cy)
			elseif height < size.h then
				cancelNextSizeTrigger[source] = true
				guiSetSize(source, width, size.h, false)
				setCursorPosition(cx, y + size.h)
			end
		end
	end
)

-- do this weirdness to help prevent some of the crazy recursion you get when calling guiSetSize inside onClientGUISize
-- doesn't help that much and is pretty nasty, but probably worth keeping anyway
addEventHandler("onClientPreRender", root,
	function()
		if not gEnabled then
			return
		end
	
		for e,s in pairs(delayedPositioning) do
			if exists(e) then
				guiSetPosition(e, s[1], s[2], s[3])
			end
		end	
		delayedPositioning = {}		
	
		for e,s in pairs(delayedSizing) do
			if exists(e) then
				guiSetSize(e, s[1], s[2], s[3])
			end
		end	
		delayedSizing = {}	
	end
)