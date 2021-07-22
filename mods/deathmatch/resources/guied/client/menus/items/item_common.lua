--[[--------------------------------------------------
	GUI Editor
	client
	item_common.lua
	
	define common right click menu items that are (generally) used in more than one place
--]]--------------------------------------------------

function createItem_cancel()
	return MenuItem_Text:create("Cancel"):set({onClick = Menu.close, onClickArgs = {"__menu"}})
end


function createItem_creation()
	return MenuItem_Text:create("Create"):set({onClickClose = false})
end


function createItem_deletion()
	return MenuItem_Text:create("Delete"):set({onClick = guiRemove, onClickArgs = {"__gui", true}})
end


function createItem_copy()
	return MenuItem_Text:create("Copy"):set({onClick = copyGUIElement, onClickArgs = {"__gui"}})
end


function createItem_copyChildren()
	return MenuItem_Text:create("Copy (include children)"):set({onClick = copyGUIElementChildren, onClickArgs = {"__gui"}})
end


function createItem_positionCode()
	return MenuItem_Text:create("Set position code"):set({onClick = PositionCoder.open, onClickArgs = {"__gui"}})
end


function createItem_positionCodePreset(name, index)
	return MenuItem_Text:create(name):set({onClick = PositionCoder.open, onClickArgs = {"__gui", index}, presetIndex = index})
end


function createItem_outputType()
	local m = MenuItem_Radio:create({"Absolute", "Relative"}, "Output type:"):set(
		{
			onClickClose = false, 
			onClick = setElementOutputType, 
			onClickArgs = {"__gui", "__self"}, 
			itemID = "outputType"
		}
	)
	m:setSelected(1)
	
	return m
end


function createItem_outputTypeHelp()
	return MenuItem_Text:create("What is the difference\nbetween absolute\nand relative?", {horizontal = "center"}):set({onClick = Tutorial.startByID, onClickArgs = {"output"}})
end



function createItem_variable()
	return MenuItem_Text:create("Variable:\n%value"):set(
		{
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:variableInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:variableInput", true)
					
					local elementType = stripGUIPrefix(getElementType(element))
					local mbox = MessageBox_Input:create(false, "Variable name", "Enter the name of the "..elementType.." variable.\n\nNote: input is not filtered for invalid characters!", "Set variable")
					mbox:descriptionLines(2)
					mbox:setText(getElementVariable(element))
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local var = getElementData(element, "guieditor:variable")
								
								local action = {}
								action[#action + 1] = {}
								action[#action].ufunc = setElementData	
								action[#action].uvalues = {element, "guieditor:variable", var}	
								
								if not var then
									action[#action + 1] = {}
									action[#action].ufunc = setElementData							
									action[#action].uvalues = {element, "guieditor:variablePlaceholder", getElementData(element, "guieditor:variablePlaceholder")}
								end
									
								setElementData(element, "guieditor.internal:actionVariable", action)
								
								-- trick it with a fake editbox object
								setElementVariableFromMenu({edit = {text = text}}, element)
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:variableInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},
			onClickClose = false, 
			--clickable = false, 
			replaceValue = getElementVariable, 
			replaceValueArgs = {"__gui"}, 
			editbox = {filter = gFilters.variable}, 
			onEditStop = 
				function(editbox, element)
					if hasText(element) then
						guiSetReadOnly(element, false)
					end	
					
					setElementVariableFromMenu(editbox, element)
				end,
			onEditStopArgs = {"__gui"},
			onEditStart = 	
				function(_, element)
					if hasText(element) then
						guiSetReadOnly(element, true)
					end		
					
					local var = getElementData(element, "guieditor:variable")
					
					local action = {}
					action[#action + 1] = {}
					action[#action].ufunc = setElementData	
					action[#action].uvalues = {element, "guieditor:variable", var}	
					
					if not var then
						action[#action + 1] = {}
						action[#action].ufunc = setElementData							
						action[#action].uvalues = {element, "guieditor:variablePlaceholder", getElementData(element, "guieditor:variablePlaceholder")}
					end
						
					setElementData(element, "guieditor.internal:actionVariable", action)
				end,
			onEditStartArgs = {"__gui"}
		}
	)
end


function createItem_colour()
	return MenuItem_Text:create("Set colour"):set(
		{
			onClick = --colorPicker.openSelect,
				function(element)
					setElementData(element, "guieditor.internal:colourCache", {guiGetColour(element)})
					
					colorPicker.openSelect()
					
					colorPicker.onClose = 
						function(r, g, b, a, element)
							guiSetColourClean(element, unpack(getElementData(element, "guieditor.internal:colourCache")))
							guiSetColourReverse(r, g, b, a, element)
						end
					colorPicker.onCloseArgs = {element}
					
					colorPicker.onUpdateSelectedValue = guiSetColourReverseClean
					colorPicker.onUpdateSelectedValueArgs = {element}
					
					colorPicker.onIgnore = guiSetColourClean
					colorPicker.onIgnoreArgs = {element, unpack(getElementData(element, "guieditor.internal:colourCache"))}
				end,
			onClickArgs = {"__gui"}
		}
	)
end


function createItem_text()
	return MenuItem_Text:create("Set text"):set({onClick = setElementText, onClickArgs = {"__gui"}})
end


function createItem_alpha()
	return MenuItem_Slider:create("Alpha: %value/100"):set(
		{
			onClickClose = false, 
			onDown = UndoRedo.guiSetAlpha, 
			onDownArgs = {"__gui", "__value", true, true}, 
			onClick = UndoRedo.guiSetAlpha, 
			onClickArgs = {"__gui", "__value", true}, 
			onChange = guiSetAlpha, 
			onChangeArgs = {"__gui", "__value", true}, 
			itemID = "alpha",
			onEditStop = 
				function(editbox, element)
					if hasText(element) then
						guiSetReadOnly(element, false)
					end	
				end,
			onEditStopArgs = {"__gui"},
			onEditStart = 	
				function(_, element)
					if hasText(element) then
						guiSetReadOnly(element, true)
					end		
				end,
			onEditStartArgs = {"__gui"}		
		}
	)
end


function createItem_parent()
	return MenuItem_Text:create("Parent Menu"):set({itemID = "parent"})
end


function createItem_moveToBack()
	return MenuItem_Text:create("Move to back"):set({onClick = guiMoveToBack, onClickArgs = {"__gui"}})
end


function createItem_properties()
	return MenuItem_Text:create("Properties"):set({onClick = Properties.open, onClickArgs = {"__gui"}})
end


function createItem_font()
	return MenuItem_Text:create("Set font"):set({onClick = FontPicker.open, onClickArgs = {FontPicker, "__gui"}})
end

function createItem_fontSize()
	return MenuItem_Slider:create("Font size: %value", nil, nil, nil, 150):set(
		{
			onClickClose = false, 
			onDown = UndoRedo.setFontSize, 
			onDownArgs = {"__gui", "__value", true}, 
			onClick = UndoRedo.setFontSize, 
			onClickArgs = {"__gui", "__value", false}, 
			onChange = FontPicker.setFontSize, 
			onChangeArgs = {FontPicker, "__gui", "__value"}, 
			itemID = "fontSize",
			onEditStop = 
				function(editbox, element)
					if hasText(element) then
						guiSetReadOnly(element, false)
					end	
				end,
			onEditStopArgs = {"__gui"},
			onEditStart = 	
				function(_, element)
					if hasText(element) then
						guiSetReadOnly(element, true)
					end		
				end,
			onEditStartArgs = {"__gui"},	
			condition = 
				function(element)
					if exists(element) then
						local dx = DX_Element.getDXFromElement(element)
						
						if dx then
							return dx.fontPath ~= nil
						else
							if guiGetFont(element) ~= gDefaults.font[getElementType(element)] then
								return getElementData(element, "guieditor:font") ~= nil
							end
						end
					end
				end,
			conditionArgs = {"__gui"}
		}
	)
end


--[[--------------------------------------------------
	items that are used solely in the main menu (right click the screen)
--]]--------------------------------------------------
function createItem_undo()
	return MenuItem_Text:create("Undo"):set({onClick = UndoRedo.undo})
end


function createItem_redo()
	return MenuItem_Text:create("Redo"):set({onClick = UndoRedo.redo})
end


function createItem_undoList()
	return MenuItem_Text:create(""):set({onClickClose = false, clickable = false})
end


function createItem_redoList()
	return MenuItem_Text:create(""):set({onClickClose = false, clickable = false})
end


function createItem_output()
	return MenuItem_Text:create("Output"):set({onClick = Output.generateCode, padding = {left = 5, right = 5, top = 0, bottom = 0}})
end


function createItem_settings()
	return MenuItem_Text:create("Settings"):set({onClick = Settings.openGUI})
end


function createItem_help()
	return MenuItem_Text:create("Help"):set({onClick = HelpWindow.open})
end


function createItem_loadCode()
	return MenuItem_Text:create("Load Code"):set({onClick = LoadCode.open})
end


function createItem_checkUpdate()
	return MenuItem_Text:create("Check for updates"):set({onClick = checkForUpdates, onClickArgs = {false}})
end


function createItem_share()
	return MenuItem_Text:create("Share GUI"):set({onClick = Share.open})
end


function createItem_tutorial()
	return MenuItem_Text:create("Tutorial"):set({onClick = Tutorial.startByID, onClickArgs = {"main"}})
end

function createItem_locked()
	return MenuItem_Toggle:create(false, "Locked"):set(
		{
			onClickClose = false, 
			onClick = setElementData,
			onClickArgs = {"__gui", "guieditor:locked", "__value"}, 
			itemID = "locked",
			condition = 
				function(menu)
					return menu.controlHeld
				end,
			conditionArgs = {"__menu"}
		}
	)
end

--[[--------------------------------------------------
	move
--]]--------------------------------------------------
function createItem_move()
	return MenuItem_Text:create("Move"):set({onClick = Mover.add, onClickArgs = {"__gui"}})
end


function createItem_moveX()
	return MenuItem_Text:create("Move X"):set({onClick = Mover.add, onClickArgs = {"__gui", true, false}})
end


function createItem_moveY()
	return MenuItem_Text:create("Move Y"):set({onClick = Mover.add, onClickArgs = {"__gui", false, true}})
end


--[[--------------------------------------------------
	resize
--]]--------------------------------------------------
function createItem_resize()
	return MenuItem_Text:create("Resize"):set({onClick = Sizer.add, onClickArgs = {"__gui"}})
end

function createItem_resizeContrained()
	return MenuItem_Text:create("Resize (constrained)"):set({onClick = Sizer.add, onClickArgs = {"__gui", true, true, false, false, true}})
end

function createItem_resizeX()
	return MenuItem_Text:create("Resize Width"):set({onClick = Sizer.add, onClickArgs = {"__gui", true, false}})
end


function createItem_resizeY()
	return MenuItem_Text:create("Resize Height"):set({onClick = Sizer.add, onClickArgs = {"__gui", false, true}})
end

function createItem_resizeFitWidth()
	return MenuItem_Text:create("Fit Parent Width"):set(
		{
			onClick = 
				function(element)
					local x, y = guiGetPosition(element, false)
					guiSetPosition(element, 0, y, false)
					
					local pW = guiGetParentSize(element, false)
					local w, h = guiGetSize(element, false)
					
					
					local action = {}
					action[#action + 1] = {}
					action[#action].ufunc = guiSetPosition
					action[#action].uvalues = {element, x, y, false}
					action[#action].rfunc = guiSetPosition
					action[#action].rvalues = {element, 0, y, false}
					
					action[#action + 1] = {}
					action[#action].ufunc = guiSetSize
					action[#action].uvalues = {element, w, h, false}
					action[#action].rfunc = guiSetSize
					action[#action].rvalues = {element, pW, h, false}
					
					guiSetSize(element, pW, h, false)
					
					
					action.description = "Fit "..guiGetFriendlyName(element).." to parent width"
					UndoRedo.add(action)
				end, 
			onClickArgs = {"__gui"}
		}
	)
end

function createItem_resizeFitHeight()
	return MenuItem_Text:create("Fit Parent Height"):set(
		{
			onClick = 
				function(element)
					local x, y = guiGetPosition(element, false)
					local newY = 0
					
					-- windows freak out if they have anything above y=10
					if guiGetParent(element) then
						if getElementType(guiGetParent(element)) == "gui-window" then
							newY = 10
						end
					end
					
					guiSetPosition(element, x, newY, false)
					
					local _, pH = guiGetParentSize(element, false)
					local w, h = guiGetSize(element, false)
						
					guiSetSize(element, w, pH, false)
					
					
					local action = {}
					action[#action + 1] = {}
					action[#action].ufunc = guiSetPosition
					action[#action].uvalues = {element, x, y, false}
					action[#action].rfunc = guiSetPosition
					action[#action].rvalues = {element, x, newY, false}
					
					action[#action + 1] = {}
					action[#action].ufunc = guiSetSize
					action[#action].uvalues = {element, w, h, false}
					action[#action].rfunc = guiSetSize
					action[#action].rvalues = {element, w, pH, false}
					
					action.description = "Fit "..guiGetFriendlyName(element).." to parent height"
					UndoRedo.add(action)
				end, 
			onClickArgs = {"__gui"}
		}
	)
end


--[[--------------------------------------------------
	dimensions
--]]--------------------------------------------------
function createItem_dimensions()
	return MenuItem_Text:create("Dimensions"):set({onClickClose = false})
end


function createItem_dimensionsX()
	return MenuItem_Text:create("Set X: %value"):set(
		{
			onClickClose = false, 
			replaceValue = guiGetXPositionForMenu, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = guiSetXPositionFromMenu,
			onEditStopArgs = {"__gui"}, 
			itemID = "dimensionX",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionXInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionXInput", true)
					
					local elementType = stripGUIPrefix(getElementType(element))
					local mbox = MessageBox_Input:create(false, "Set X Position", "Enter the "..elementType.." X position.\n\nNote: input is not filtered for invalid characters!", "Set position")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								-- trick it with a fake editbox object
								guiSetXPositionFromMenu({edit = {text = text}}, element)
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:dimensionXInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},			
		}
	)
end


function createItem_dimensionsY()
	return MenuItem_Text:create("Set Y: %value"):set(
		{
			onClickClose = false, 
			replaceValue = guiGetYPositionForMenu, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = guiSetYPositionFromMenu, 
			onEditStopArgs = {"__gui"}, 
			itemID = "dimensionY",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionYInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionYInput", true)
					
					local elementType = stripGUIPrefix(getElementType(element))
					local mbox = MessageBox_Input:create(false, "Set Y Position", "Enter the "..elementType.." Y position.\n\nNote: input is not filtered for invalid characters!", "Set position")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								-- trick it with a fake editbox object
								guiSetYPositionFromMenu({edit = {text = text}}, element)
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:dimensionYInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},	
		}
	)
end


function createItem_dimensionsWidth()
	return MenuItem_Text:create("Set Width: %value"):set(
		{
			onClickClose = false, 
			replaceValue = guiGetWidthForMenu, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = guiSetWidthFromMenu, 
			onEditStopArgs = {"__gui"}, 
			itemID = "dimensionWidth",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionWidthInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionWidthInput", true)
					
					local elementType = stripGUIPrefix(getElementType(element))
					local mbox = MessageBox_Input:create(false, "Set Width", "Enter the "..elementType.." width.\n\nNote: input is not filtered for invalid characters!", "Set width")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								-- trick it with a fake editbox object
								guiSetWidthFromMenu({edit = {text = text}}, element)
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:dimensionWidthInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},				
		}
	)
end


function createItem_dimensionsHeight()
	return MenuItem_Text:create("Set Height: %value"):set(
		{
			onClickClose = false, 
			replaceValue = guiGetHeightForMenu, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = guiSetHeightFromMenu, 
			onEditStopArgs = {"__gui"}, 
			itemID = "dimensionHeight",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionHeightInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionHeightInput", true)
					
					local elementType = stripGUIPrefix(getElementType(element))
					local mbox = MessageBox_Input:create(false, "Set Height", "Enter the "..elementType.." height.\n\nNote: input is not filtered for invalid characters!", "Set height")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								-- trick it with a fake editbox object
								guiSetHeightFromMenu({edit = {text = text}}, element)
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:dimensionHeightInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},				
		}
	)
end


function createItem_offsetFrom()
	return MenuItem_Text:create("Offset from this element"):set({onClick = Offset.fromElement, onClickArgs = {"__gui"}})
end	

--[[--------------------------------------------------
	not loaded menu items
--]]--------------------------------------------------

function createItem_notLoaded()
	return MenuItem_Text:create("This %value\nis not loaded", {horizontal = "center"}):set(
		{
			clickable = false,
			replaceValue = 
				function(gui)
					return stripGUIPrefix(getElementType(gui))
				end, 
			replaceValueArgs = {"__gui"}, 
			cannotEdit = true,
		}
	)
end


function createItem_load()
	return MenuItem_Text:create("Load"):set({onClick = loadGUIElement, onClickArgs = {"__gui"}})
end


function createItem_loadNoChildren()
	return MenuItem_Text:create("Load (ignore children)"):set({onClick = loadGUIElement, onClickArgs = {"__gui", true}})
end


function createItem_noLoad()
	return MenuItem_Text:create("This gui element\ncannot be\nloaded", {horizontal = "center"}):set({clickable = false})
end


--[[--------------------------------------------------
	items for creating each element type
	
	window
	button
	memo
	label
	checkbox
	edit
	gridlist
	progress bar
	tab panel
	tab
	radio button
	static image
	scrollpane
	scrollbar
	combo box
--]]--------------------------------------------------

function createItem_window()
	return MenuItem_Text:create("Window"):set({onClick = Creator.set, onClickArgs = {"window", "__menu"}})
end

function createItem_button()
	return MenuItem_Text:create("Button"):set({onClick = Creator.set, onClickArgs = {"button", "__menu"}})
end

function createItem_memo()
	return MenuItem_Text:create("Memo"):set({onClick = Creator.set, onClickArgs = {"memo", "__menu"}})
end

function createItem_label()
	return MenuItem_Text:create("Label"):set({onClick = Creator.set, onClickArgs = {"label", "__menu"}})
end

function createItem_checkbox()
	return MenuItem_Text:create("Checkbox"):set({onClick = Creator.set, onClickArgs = {"checkbox", "__menu"}})
end

function createItem_edit()
	return MenuItem_Text:create("Edit box"):set({onClick = Creator.set, onClickArgs = {"edit", "__menu"}})
end

function createItem_progressbar()
	return MenuItem_Text:create("Progress bar"):set({onClick = Creator.set, onClickArgs = {"progressbar", "__menu"}})
end

function createItem_radiobutton()
	return MenuItem_Text:create("Radio button"):set({onClick = Creator.set, onClickArgs = {"radiobutton", "__menu"}})
end

function createItem_gridlist()
	return MenuItem_Text:create("Gridlist"):set({onClick = Creator.set, onClickArgs = {"gridlist", "__menu"}})
end

function createItem_tabpanel()
	return MenuItem_Text:create("Tab panel"):set({onClick = Creator.set, onClickArgs = {"tabpanel", "__menu"}})
end

function createItem_staticimage()
	return MenuItem_Text:create("Image"):set(
		{
			onClick = ImagePicker.openFromMenu, 
			onClickArgs = {
				"__gui",
				function(row, col, text, resource, guiParent, size)
					setTimer(
						function()
							Creator.set("staticimage", guiParent, ":" .. resource .. "/" .. text, size)
						end,
					100, 1)
				end,
			},
		}
	)
end

function createItem_scrollbar()
	return MenuItem_Text:create("Scrollbar"):set({onClickClose = false})
end 

function createItem_scrollbarHorizontal()
	return MenuItem_Text:create("Scrollbar Horizontal"):set({onClick = Creator.set, onClickArgs = {"scrollbar", "__menu", true}})
end 

function createItem_scrollbarVertical()
	return MenuItem_Text:create("Scrollbar Vertical"):set({onClick = Creator.set, onClickArgs = {"scrollbar", "__menu", false}})
end 

function createItem_scrollpane()
	return MenuItem_Text:create("Scrollpane"):set({onClick = Creator.set, onClickArgs = {"scrollpane", "__menu"}})
end 

function createItem_combobox()
	return MenuItem_Text:create("Combobox"):set({onClick = Creator.set, onClickArgs = {"combobox", "__menu"}})
end 
--[[--------------------------------------------------
	window items
--]]--------------------------------------------------
function createItem_windowMovable()
	--return MenuItem_Toggle:create(true, "Movable"):set({onClickClose = false, onClick = guiWindowSetMovable, onClickArgs = {"__gui", "__value", true}, itemID = "windowMovable"})
	return MenuItem_Toggle:create(true, "Movable"):set({onClickClose = false, onClick = setElementData, onClickArgs = {"__gui", "guieditor:windowMovable", "__value"}, itemID = "windowMovable"})
end


function createItem_windowSizable()
	--return MenuItem_Toggle:create(false, "Sizable"):set({onClickClose = false, onClick = guiWindowSetSizable, onClickArgs = {"__gui", "__value", true}, itemID = "windowSizable"})
	return MenuItem_Toggle:create(false, "Sizable"):set({onClickClose = false, onClick = setElementData, onClickArgs = {"__gui", "guieditor:windowSizable", "__value"}, itemID = "windowSizable"})
end

--[[--------------------------------------------------
	memo
--]]--------------------------------------------------
function createItem_readOnly()
	return MenuItem_Toggle:create(false, "Read only"):set({onClickClose = false, onClick = guiSetReadOnly, onClickArgs = {"__gui", "__value", true}, itemID = "readOnly"})
end


--[[--------------------------------------------------
	label
--]]--------------------------------------------------
function createItem_wordwrap()
	return MenuItem_Toggle:create(false, "Wordwrap"):set({onClickClose = false, onClick = guiLabelSetWordwrap, onClickArgs = {"__gui", "__value", true}, itemID = "wordwrap"})
end

function createItem_horizontalAlignment()
	local m = MenuItem_Slider:create("Horizontal align: %value"):set(
		{
			onClickClose = false, 
			onClick = --guiLabelSetHorizontalAlignFromMenu, 
				function(element, value, generateAction)
					guiLabelSetHorizontalAlignFromMenu(element, getElementData(element, "guieditor.internal:alignmentCache"), false)
					guiLabelSetHorizontalAlignFromMenu(element, value, generateAction)
				end,
			onClickArgs = {"__gui", "__value", true}, 
			onDown = 
				function(element)
					setElementData(element, "guieditor.internal:alignmentCache", guiLabelGetHorizontalAlign(element))
				end,
			onDownArgs = {"__gui"}, 
			itemID = "horizontalAlign",
			onChange = guiLabelSetHorizontalAlignFromMenu, 
			onChangeArgs = {"__gui", "__value", false}, 
		}
	)
	
	m.slider.minValue = 1
	m.slider.maxValue = 3
	m.slider.snapToBoundaries = true
	m.slider.drawBoundaries = true
	m.slider:value(1)
	m.editbox:enabled(false)
	
	m.editbox:setReplacement("%%value", 
		function(item)
			local v = item:value()
			
			if v == 1 then
				return "left"
			elseif v == 2 then
				return "center"
			else
				return "right"
			end
		end, 
	m.slider)
	
	return m
end

function createItem_verticalAlignment()
	local m = MenuItem_Slider:create("Vertical align: %value"):set(	
		{
			onClickClose = false, 
			onClick = --guiLabelSetVerticalAlignFromMenu, 
				function(element, value, generateAction)
					guiLabelSetVerticalAlignFromMenu(element, getElementData(element, "guieditor.internal:alignmentCache"), false)
					guiLabelSetVerticalAlignFromMenu(element, value, generateAction)
				end,
			onClickArgs = {"__gui", "__value", true}, 
			onDown = 
				function(element)
					setElementData(element, "guieditor.internal:alignmentCache", guiLabelGetVerticalAlign(element))
				end,
			onDownArgs = {"__gui"}, 
			itemID = "verticalAlign",
			onChange = guiLabelSetVerticalAlignFromMenu, 
			onChangeArgs = {"__gui", "__value", false}, 
		}
	)
	
	m.slider.minValue = 1
	m.slider.maxValue = 3
	m.slider.snapToBoundaries = true
	m.slider.drawBoundaries = true
	m.slider:value(1)
	m.editbox:enabled(false)
	
	m.editbox:setReplacement("%%value", 
		function(item)
			local v = item:value()
			
			if v == 1 then
				return "top"
			elseif v == 2 then
				return "center"
			else
				return "bottom"
			end
		end, 
	m.slider)
	
	return m
end


--[[--------------------------------------------------
	edit
--]]--------------------------------------------------
function createItem_masked()
	return MenuItem_Toggle:create(false, "Masked"):set({onClickClose = false, onClick = guiEditSetMasked, onClickArgs = {"__gui", "__value", true}, itemID = "masked"})
end

function createItem_maxLength()
	return MenuItem_Text:create("Max length: %value"):set(
		{
			onClickClose = false, 
			replaceValue = guiEditGetMaxLength, 
			replaceValueArgs = {"__gui"}, 
			editbox = {filter = gFilters.numberInt}, 
			onEditStop = 
				function(editbox, element)
					guiEditSetMaxLength(element, editbox.edit.text, true)
					
					if hasText(element) then
						guiSetReadOnly(element, false)
					end					
				end,
			onEditStopArgs = {"__gui"},
			onEditStart = 	
				function(_, element)
					if hasText(element) then
						guiSetReadOnly(element, true)
					end
				end,
			onEditStartArgs = {"__gui"},
		}
	)	
end


--[[--------------------------------------------------
	progress
--]]--------------------------------------------------
function createItem_progress()
	return MenuItem_Slider:create("Progress: %value/100"):set(
		{
			onClickClose = false, 
			onDown = UndoRedo.guiProgressBarSetProgress, 
			onDownArgs = {"__gui", "__value", true}, 
			onClick = UndoRedo.guiProgressBarSetProgress, 
			onClickArgs = {"__gui", "__value", false}, 
			onChange = guiProgressBarSetProgress, 
			onChangeArgs = {"__gui", "__value"}, 
			itemID = "progress",
		}
	)
end

--[[--------------------------------------------------
	gridlist
--]]--------------------------------------------------
function createItem_addColumn()
	return MenuItem_Text:create("Add Column"):set(
		{
			onClick = 
				function(element)
					local mbox = MessageBox_Input:create(false, "Column name", "Enter the name of the column", "Add column")
					mbox.onAccept = 
						function(text, element)
							local col = guiGridListAddColumn(element, text, 0)
							setElementData(element, "guieditor:gridlistColumnTitle."..tostring(col), text)
							
							for i = 1, guiGridListGetColumnCount(element) do
								guiGridListSetColumnWidth(element, i, 0.9 / guiGridListGetColumnCount(element), true)
								
								for k = 0, guiGridListGetRowCount(element) do
									if guiGridListGetItemText(element, k, i) == "" then
										guiGridListSetItemText(element, k, i, "-", false, false)
									end
								end
							end
						end
					mbox.onAcceptArgs = {element}
				end, 
			onClickArgs = {"__gui"}
		}
	)
end


function createItem_removeColumn()
	return MenuItem_Text:create("Remove Column"):set(
		{
			onClick = 
				function(element)
					local mbox = MessageBox_Input:create(false, "Column name", "Enter the name of the column", "Remove column")
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								for i = 0, guiGridListGetColumnCount(element) do
									if getElementData(element, "guieditor:gridlistColumnTitle."..tostring(i)) == text then
										guiGridListRemoveColumn(element, i)
										return
									end
								end
							end
							
							--ContextBar.add("No gridlist column was found with that name")
							MessageBox_Info:create("No column found", "No column was found matching that name")
						end
					mbox.onAcceptArgs = {element}
				end, 
			onClickArgs = {"__gui"}
		}
	)
end


function createItem_addRow()
	return MenuItem_Text:create("Add row"):set(
		{
			onClick = 
				function(element)
					local row = guiGridListAddRow(element)
					
					if guiGridListGetColumnCount(element) > 0 then
						for i = 0, guiGridListGetColumnCount(element) do
							guiGridListSetItemText(element, row, i, "-", false, false)
						end					
					else
						ContextBar.add("You must add a column before rows can be created")
					end
				end, 
			onClickArgs = {"__gui"}
		}
	)
end


function createItem_removeRow()
	return MenuItem_Text:create("Remove row"):set(
		{
			onClick = 
				function(element)
					local row, col = guiGridListGetSelectedItem(element)
					
					if row and col and row ~= -1 and col ~= - 1 then
						guiGridListRemoveRow(element, row)
					else
						ContextBar.add("No row is currently selected")
					end			
				end, 
			onClickArgs = {"__gui"}
		}
	)
end


function createItem_gridlistItem()
	return MenuItem_Text:create("Item"):set({onClickClose = false})
end

function createItem_gridlistItemText()
	return MenuItem_Text:create("Set text"):set(
		{
			onClick = 
				function(element)
					local mbox = MessageBox_Input:create(false, "Item text", "Enter the text for the gridlist item", "Set text")
					mbox.onAccept = 
						function(text, element)
							local row, col = guiGridListGetSelectedItem(element)
							
							if row and col and row ~= -1 and col ~= -1 then
								guiGridListSetItemText(element, row, col, text, false, false)
							end
						end
					mbox.onAcceptArgs = {element}
				end, 
			onClickArgs = {"__gui"}
		}
	)
end

function createItem_gridlistItemColour()
	local f = 
		function(r, g, b, a, element)
			local row, col = guiGridListGetSelectedItem(element)
							
			if row and col and row ~= -1 and col ~= -1 then
				guiGridListSetItemColor(element, row, col, r, g, b, a)
			end			
		end
		
	local m = MenuItem_Text:create("Set colour"):set(
		{
			--onClick = colorPicker.openSelect, 
			--onClickArgs = {f, "__gui"}
			
			onClick =
				function(element)
					local row, col = guiGridListGetSelectedItem(element)
							
					if row and col and row ~= -1 and col ~= -1 then
						setElementData(element, "guieditor.internal:colourCache", {guiGridListGetItemColor(element, row, col)})
						
						colorPicker.openSelect(nil, element)
						
						colorPicker.onClose = 
							function(r, g, b, a, element)
								local row, col = guiGridListGetSelectedItem(element)
												
								if row and col and row ~= -1 and col ~= -1 then
									--guiGridListSetItemColor(element, row, col, unpack(getElementData(element, "guieditor.internal:colourCache")))
									
									local action = {}
									action[#action + 1] = {}
									local currentR, currentG, currentB, currentA = unpack(getElementData(element, "guieditor.internal:colourCache"))
									action[#action].ufunc = guiGridListSetItemColor
									action[#action].uvalues = {element, row, col, currentR, currentG, currentB, currentA}
									action[#action].rfunc = guiGridListSetItemColor
									action[#action].rvalues = {element, row, col, r, g, b, a}
									
									action.description = "Set "..stripGUIPrefix(getElementType(element)).." item colour (row: "..tostring(row)..", col: "..tostring(col)..")"
									UndoRedo.add(action)
									
									guiGridListSetItemColor(element, row, col, r, g, b, a)
								end		
							end
						colorPicker.onCloseArgs = {element}
						
						colorPicker.onUpdateSelectedValue = f
						colorPicker.onUpdateSelectedValueArgs = {element}
						
						colorPicker.onIgnore = 
							function(element)
								local row, col = guiGridListGetSelectedItem(element)
												
								if row and col and row ~= -1 and col ~= -1 then
									guiGridListSetItemColor(element, row, col, unpack(getElementData(element, "guieditor.internal:colourCache")))
								end			
							end
						colorPicker.onIgnoreArgs = {element}
					end
				end,
			onClickArgs = {"__gui"}
		}
	)
	
	return m
end


--[[--------------------------------------------------
	tab panel
--]]--------------------------------------------------
function createItem_addTab()
	return MenuItem_Text:create("Add tab"):set(
		{
			onClick = 
				function(element)
					local mbox = MessageBox_Input:create(false, "Tab name", "Enter the title for the tab", "Create tab")
					mbox.onAccept = 
						function(text, element)
							local parent = element
							
							if getElementType(element) == "gui-tab" then
								parent = getElementParent(element)
							end
							
							local tab = createGUIElementFromType("tab", nil, nil, nil, nil, nil, parent, text)
							setupGUIElement(tab)						
						
							local action = {}
							
							action[#action + 1] = {
								ufunc = guiRemove, 
								uvalues = {tab}, 
								rfunc = guiRestore, 
								rvalues = {tab}, 
								__destruct = {rfunc = guiDelete, rvalues = {tab}}
							}
		
							action.description = "Add tab ("..tostring(text)..")"

							UndoRedo.add(action)
						end
					mbox.onAcceptArgs = {element}
				end, 
			onClickArgs = {"__gui"}
		}
	)	
end

--[[--------------------------------------------------
	tab
--]]--------------------------------------------------
function createItem_deleteTab()
	return MenuItem_Text:create("Delete tab"):set(
		{
			onClick = 
				function(element)
					if #getElementChildren(guiGetParent(element)) == 1 then
						ContextBar.add("You cannot delete all tabs from a tab panel")
						return
					end
					
					local mbox = MessageBox_Continue:create("Are you sure you want to delete this tab?\n("..tostring(guiGetText(element))..")", "Delete", "Cancel")
					mbox.onAffirmative = 
						function(element)
							local action = {}
							
							action[#action + 1] = {
								ufunc = guiRestore, 
								uvalues = {element}, 
								rfunc = guiRemove, 
								rvalues = {element}, 
								__destruct = {ufunc = guiDelete, uvalues = {element}}
							}
		
							action.description = "Delete tab ("..tostring(guiGetText(element))..")"

							UndoRedo.add(action)						
						
							--guiDeleteTab(element, guiGetParent(element))						
							guiRemove(element)	
							guiSetSelectedTab(guiGetParent(element), getElementChildren(guiGetParent(element))[1])
						end
					mbox.onAffirmativeArgs = {element}
				end, 
			onClickArgs = {"__gui"}
		}
	)	
end


--[[--------------------------------------------------
	resize image
--]]--------------------------------------------------
function createItem_resizeImage()
	return MenuItem_Text:create("Set default size\n(%value)"):set(
		{
			onClick = 
				function(element)
					local size = getElementData(element, "guieditor:imageSize")
					
					if size.width and size.height then
						local action = UndoRedo.generateActionUndo(UndoRedo.presets.size, element)
						
						guiSetSize(element, size.width, size.height, false)
						
						UndoRedo.add(UndoRedo.generateActionRedo(UndoRedo.presets.size, element, action))
					else
						ContextBar.add("That image does not have a default width and size")
					end
				end,
			onClickArgs = {"__gui"},
			replaceValue = 
				function(element)
					local size = getElementData(element, "guieditor:imageSize")
					
					if size and size.width and size.height then
						return tostring(size.width) .. " x " .. tostring(size.height)
					else
						return "unknown x unknown"
					end
				end, 
			replaceValueArgs = {"__gui"}, 
			condition = 
				function(element)
					if not exists(element) then
						return false
					end
					
					local dx = DX_Element.getDXFromElement(element)
						
					if dx then
						return dx.dxType == gDXTypes.image
					end
					
					return getElementType(element) == "gui-staticimage"
				end,
			conditionArgs = {"__gui"}
		}
	)
end


--[[--------------------------------------------------
	scrollbar
--]]--------------------------------------------------

function createItem_scrollPosition()
	return MenuItem_Slider:create("Scroll: %value/100"):set(
		{
			onClickClose = false, 
			onDown = UndoRedo.guiScrollBarSetScrollPosition, 
			onDownArgs = {"__gui", "__value", true}, 
			onClick = UndoRedo.guiScrollBarSetScrollPosition, 
			onClickArgs = {"__gui", "__value"}, 
			onChange = 
				function(gui, value) 
					if exists(gui) then
						guiScrollBarSetScrollPosition(gui, value)
					end
				end,
			onChangeArgs = {"__gui", "__value"}, 
			itemID = "scroll",
			onEditStop = 
				function(editbox, element)
					if hasText(element) then
						guiSetReadOnly(element, false)
					end	
				end,
			onEditStopArgs = {"__gui"},
			onEditStart = 	
				function(_, element)
					if hasText(element) then
						guiSetReadOnly(element, true)
					end		
				end,
			onEditStartArgs = {"__gui"}		
		}
	)
end


--[[--------------------------------------------------
	combobox 
--]]--------------------------------------------------
function createItem_addComboItem()
	return MenuItem_Text:create("Add item"):set(
		{
			onClick = 
				function(element)
					local mbox = MessageBox_Input:create(false, "Combo item text", "Enter the text for the combobox item", "Add item")
					mbox.onAccept = 
						function(text, element)
							local item = guiComboBoxAddItem(element, text)					
						
							local action = {}
							
							action[#action + 1] = {
								ufunc = guiComboBoxRemoveItem, 
								uvalues = {element, item}, 
								rfunc = guiComboBoxAddItem, 
								rvalues = {element, text}, 
							}
		
							action.description = "Add combo item ("..tostring(text)..")"

							UndoRedo.add(action)
						end
					mbox.onAcceptArgs = {element}
				end, 
			onClickArgs = {"__gui"}
		}
	)	
end

function createItem_removeComboItem()
	return MenuItem_Text:create("Remove selected item"):set(
		{
			onClick = 
				function(element)
					local item = guiComboBoxGetSelected(element)
					
					if item and item ~= -1 then
						guiComboBoxRemoveItem(element, item)
					else
						ContextBar.add("No combobox item is currently selected")
					end
				end, 
			onClickArgs = {"__gui"}
		}
	)	
end

function createItem_setComboItemText()
	return MenuItem_Text:create("Set selected item text"):set(
		{
			onClick = 
				function(element)
					local item = guiComboBoxGetSelected(element)
					
					if item and item ~= -1 then
						local currentText = guiComboBoxGetItemText(element, item)

						local mbox = MessageBox_Input:create(false, "Combo item text", "Enter the text for the combobox item", "Set item text")
						
						if #currentText > 0 then
							guiSetText(mbox.input, currentText)
						end
						
						mbox.onAccept = 
							function(text, element, item)	
								-- this crashes mta, overwritten with a fixed version in getters.lua
								local oldText = guiComboBoxGetItemText(element, item)
								--local oldText = guiGetProperty(element, "Text")
								
								guiComboBoxSetItemText(element, item, text)					
							
								local action = {}
								
								action[#action + 1] = {
									ufunc = guiComboBoxSetItemText, 
									uvalues = {element, item, oldText}, 
									rfunc = guiComboBoxSetItemText, 
									rvalues = {element, item, text}, 
								}
			
								action.description = "Set combo item text ("..tostring(text)..")"
								
								UndoRedo.add(action)
							end
						mbox.onAcceptArgs = {element, item}
					else
						ContextBar.add("No combobox item is currently selected")
					end
				end, 
			onClickArgs = {"__gui"}
		}
	)	
end


function createItem_attachToElement()
	return MenuItem_Text:create("Attach"):set(
		{
			onClick = Attacher.add, 
			onClickArgs = {"__gui"}, 
			condition = 
				function(element)
					if not exists(element) then
						return false
					end
					
					return guiGetParent(element) == nil
				end,
			conditionArgs = {"__gui"}	
		}
	)
end

function createItem_detachFromElement()
	return MenuItem_Text:create("Detach"):set(
		{
			onClick = Attacher.detach, 
			onClickArgs = {"__gui"},
			condition = 
				function(element)
					if not exists(element) then
						return false
					end
					
					return guiGetParent(element) ~= nil
				end,
			conditionArgs = {"__gui"}
		}
	)
end

