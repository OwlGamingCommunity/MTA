--[[--------------------------------------------------
	GUI Editor
	client
	item_dx.lua
	
	define right click menu items for dx items
--]]--------------------------------------------------

function createItem_drawing()
	return MenuItem_Text:create("Drawing"):set({onClickClose = false})
end


function createItem_dxLine()
	return MenuItem_Text:create("DX Line"):set({onClick = Creator.set, onClickArgs = {"dx_line", "__menu"}})
end

function createItem_dxRectangle()
	return MenuItem_Text:create("DX Rectangle"):set({onClick = Creator.set, onClickArgs = {"dx_rectangle", "__menu"}})
end

function createItem_dxImage()
	return MenuItem_Text:create("DX Image"):set({onClick = Creator.set, onClickArgs = {"dx_image", "__menu"}})
end


function createItem_dxImage()
	return MenuItem_Text:create("DX Image"):set(
		{
			onClick = ImagePicker.openFromMenu, 
			onClickArgs = {
				"__menu",
				function(row, col, text, resource, guiParent, size)
					setTimer(
						function()
							Creator.set("dx_image", guiParent, ":" .. resource .. "/" .. text, size)
						end,
					100, 1)
				end,
			},
		}
	)
end

function createItem_dxText()
	return MenuItem_Text:create("DX Text"):set({onClick = Creator.set, onClickArgs = {"dx_text", "__menu"}})
end



function createItem_dxDeletion()
	return MenuItem_Text:create("Delete"):set(
		{
			onClick = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
						
					if dx then
						dx:dxRemove()
						guiRemove(element, true)
					end
				end,
			onClickArgs = {"__gui"}
		}
	)
end

function createItem_dxLineResize()
	return MenuItem_Text:create("Resize"):set({onClick = Sizer.add, onClickArgs = {"__gui"}})
end

function createItem_dxMoveToBack()
	return MenuItem_Text:create("Move to back"):set(
		{
			onClick = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
						
					if dx then
						dx:order(1)
					end
				end,
			onClickArgs = {"__gui"}
		}
	)
end

function createItem_dxMoveToFront()
	return MenuItem_Text:create("Move to front"):set(
		{
			onClick = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
						
					if dx then
						dx:order(#DX_Element.instances)
					end
				end,
			onClickArgs = {"__gui"}
		}
	)
end

function createItem_dxMoveBack()
	return MenuItem_Text:create("Step back"):set(
		{
			onClick = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
						
					if dx then
						dx:orderMoveDown()
					end
				end,
			onClickArgs = {"__gui"}
		}
	)
end

function createItem_dxMoveForward()
	return MenuItem_Text:create("Step forward"):set(
		{
			onClick = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
						
					if dx then				
						dx:orderMoveUp()
					end
				end,
			onClickArgs = {"__gui"}
		}
	)
end


function createItem_dxLineWidth()
	return MenuItem_Text:create("Width: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( dx and dx.width or 1)
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:setWidth(tonumber(editbox.edit.text) or dx.width)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			editbox = {filter = gFilters.numberInt}, 
			itemID = "dxLineWidth",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:lineWidthInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:lineWidthInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set Line Width", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "line width.\n\nNote: input is not filtered for invalid characters!", "Set width")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
								if dx then
									dx:setWidth(tonumber(text) or dx.width)
								end
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:lineWidthInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},			
		}
	)
end




function createItem_dxDimensions()
	return MenuItem_Text:create("Dimensions"):set({onClickClose = false})
end


function createItem_dxDimensionsStartX()
	return MenuItem_Text:create("Set Start X: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%.3f", (dx and dx.startX or 0)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:setStartX(tonumber(editbox.edit.text) or dx.startX)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			itemID = "dxDimensionStartX",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionXInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionXInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set X Position", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "Start X position.\n\nNote: input is not filtered for invalid characters!", "Set position")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:setStartX(tonumber(text) or dx.startX)
								end
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


function createItem_dxDimensionsStartY()
	return MenuItem_Text:create("Set Start Y: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%.3f", (dx and dx.startY or 0)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:setStartY(tonumber(editbox.edit.text) or dx.startY)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			itemID = "dxDimensionStartY",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionYInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionYInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set Y Position", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "Start Y position.\n\nNote: input is not filtered for invalid characters!", "Set position")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:setStartY(tonumber(text) or dx.startY)
								end
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


function createItem_dxDimensionsEndX()
	return MenuItem_Text:create("Set End X: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%.3f", (dx and dx.endX or 0)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:setEndX(tonumber(editbox.edit.text) or dx.endX)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			itemID = "dxDimensionEndX",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionEndXInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionEndXInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set X Position", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "End X position.\n\nNote: input is not filtered for invalid characters!", "Set position")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:setEndX(tonumber(text) or dx.endX)
								end
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:dimensionEndXInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},			
		}
	)
end


function createItem_dxDimensionsEndY()
	return MenuItem_Text:create("Set End Y: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%.3f", (dx and dx.endY or 0)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:setEndY(tonumber(editbox.edit.text) or dx.endY)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			itemID = "dxDimensionEndY",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionEndYInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionEndYInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set Y Position", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "End Y position.\n\nNote: input is not filtered for invalid characters!", "Set position")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:setEndY(tonumber(text) or dx.endY)
								end
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:dimensionEndYInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},			
		}
	)
end



------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- squares
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
function createItem_dxDimensionsX()
	return MenuItem_Text:create("Set X: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%.3f", (dx and dx.x or 0)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:setX(tonumber(editbox.edit.text) or dx.x)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			itemID = "dxDimensionX",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionXInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionXInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set X Position", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "X position.\n\nNote: input is not filtered for invalid characters!", "Set position")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:setX(tonumber(text) or dx.x)
								end
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


function createItem_dxDimensionsY()
	return MenuItem_Text:create("Set Y: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%.3f", (dx and dx.y or 0)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:setY(tonumber(editbox.edit.text) or dx.y)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			itemID = "dxDimensionY",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionYInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionYInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set Y Position", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "Y position.\n\nNote: input is not filtered for invalid characters!", "Set position")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:setY(tonumber(text) or dx.y)
								end
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


function createItem_dxDimensionsWidth()
	return MenuItem_Text:create("Set Width: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%.3f", (dx and dx.width or 0)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:setWidth(tonumber(editbox.edit.text) or dx.width)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			itemID = "dxDimensionWidth",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionWidthInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionWidthInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set Width", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "width.\n\nNote: input is not filtered for invalid characters!", "Set Width")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:setWidth(tonumber(text) or dx.width)
								end
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


function createItem_dxDimensionsHeight()
	return MenuItem_Text:create("Set Height: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%.3f", (dx and dx.height or 0)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:setHeight(tonumber(editbox.edit.text) or dx.height)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			itemID = "dxDimensionHeight",
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:dimensionHeightInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:dimensionHeightInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set Height", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "height.\n\nNote: input is not filtered for invalid characters!", "Set Height")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:setHeight(tonumber(text) or dx.height)
								end
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


function createItem_dxScale()
	return MenuItem_Text:create("Scale: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberFloat},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%.3f", (dx and dx.scale_ or 1)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:scale(tonumber(editbox.edit.text) or dx.scale_)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:scaleInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:scaleInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set Scale", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "scale.\n\nNote: input is not filtered for invalid characters!", "Set Scale")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:scale(tonumber(text) or dx.scale_)
								end
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:scaleInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},			
		}
	)
end


function createItem_clip()
	return MenuItem_Toggle:create(false, "Clip"):set(
		{
			onClickClose = false, 
			onClick = 
				function(element, clip, undoable)
					if getElementData(element, "guieditor.internal:dxElement") then
						local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
							
						if dx.dxType then
							if undoable then
								local action = {}
								action[#action + 1] = {}
								action[#action].ufunc = DX_Text.clip
								action[#action].uvalues = {dx, dx.clip_}
								action[#action].rfunc = DX_Text.clip
								action[#action].rvalues = {dx, clip}

								action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." clip"
								UndoRedo.add(action)		
							end
							
							dx:clip(clip)
						end
						
						return
					end				
				end, 
			onClickArgs = {"__gui", "__value", true}, 
			itemID = "clip"
		}
	)
end


function createItem_colourCoded()
	return MenuItem_Toggle:create(false, "Colour Coded"):set(
		{
			onClickClose = false, 
			onClick = 
				function(element, colourCoded, undoable)
					if getElementData(element, "guieditor.internal:dxElement") then
						local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
							
						if dx.dxType then
							if undoable then
								local action = {}
								action[#action + 1] = {}
								action[#action].ufunc = DX_Text.colourCoded
								action[#action].uvalues = {dx, dx.colourCoded_}
								action[#action].rfunc = DX_Text.colourCoded
								action[#action].rvalues = {dx, colourCoded}

								action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." colour coded"
								UndoRedo.add(action)		
							end
							
							dx:colourCoded(colourCoded)
						end
						
						return
					end				
				end, 
			onClickArgs = {"__gui", "__value", true}, 
			itemID = "colourCoded"
		}
	)
end


function createItem_dxRotation()
	local m = MenuItem_Slider:create("Rotation: %value/360"):set(
		{
			onClickClose = false, 
			onDown = 
				function(element, value)
					if exists(element) then
						if getElementData(element, "guieditor.internal:dxElement") then
							local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
								
							if dx.dxType then			
								local action = {}
								action[#action + 1] = {}
								action[#action].ufunc = DX_Image.rotation
								action[#action].uvalues = {dx, dx.rotation_}
								
								setElementInvalidData(element, "guieditor.internal:dxImageRotationAction", action)
							end
						end
					end	
				end, 
			onDownArgs = {"__gui", "__value"}, 
			onClick = 
				function(element, value)
					if exists(element) then
						if getElementData(element, "guieditor.internal:dxElement") then
							local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
								
							if dx.dxType then					
								local action = getElementInvalidData(element, "guieditor.internal:dxImageRotationAction")
								action[#action].rfunc = DX_Image.rotation
								action[#action].rvalues = {dx, value}		

								action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." rot (" .. tostring(value) .. ")"
								UndoRedo.add(action)
								
								setElementInvalidData(element, "guieditor.internal:dxImageRotationAction", nil)
							end
						end
					end
				end, 
			onClickArgs = {"__gui", "__value"}, 
			onChange = 
				function(element, value)
					if exists(element) then
						if getElementData(element, "guieditor.internal:dxElement") then
							local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
								
							if dx.dxType then
								dx.rotation_ = value
							end
						end
					end
				end, 
			onChangeArgs = {"__gui", "__value"}, 
			itemID = "dxRotation",
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
	
	m.slider.minValue = 0
	m.slider.maxValue = 360
	
	return m
end


function createItem_dxRotOffsetX()
	return MenuItem_Text:create("Rot Offset X: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%i", (dx and dx.rOffsetX_ or 1)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:rOffsetX(tonumber(editbox.edit.text) or dx.rOffsetX_)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:rOffsetXInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:rOffsetXInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set Rotation Offset X", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "x rotation offset.\n\nNote: input is not filtered for invalid characters!", "Set Offset")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:rOffsetX(tonumber(text) or dx.rOffsetX_)
								end
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:rOffsetXInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},			
		}
	)
end


function createItem_dxRotOffsetY()
	return MenuItem_Text:create("Rot Offset Y: %value"):set(
		{
			onClickClose = false, 
			editbox = {filter = gFilters.numberInt},
			replaceValue = 
				function(element)
					local dx = DX_Element.getDXFromElement(element)
					
					return tonumber( string.format("%i", (dx and dx.rOffsetY_ or 1)) )
				end, 
			replaceValueArgs = {"__gui"}, 
			onEditStop = 
				function(editbox, element)
					local dx = DX_Element.getDXFromElement(element)
					
					if dx then
						dx:rOffsetY(tonumber(editbox.edit.text) or dx.rOffsetY_)
					end
				end,
			onEditStopArgs = {"__gui"}, 
			button = "images/arrow_out.png",
			buttonShowOnHover = true,
			onButtonClick =
				function(element)
					if getElementData(element, "guieditor.internal:rOffsetYInput") then
						return
					end
					
					setElementData(element, "guieditor.internal:rOffsetYInput", true)
					
					local dx = DX_Element.getDXFromElement(element)
					local mbox = MessageBox_Input:create(false, "Set Rotation Offset Y", "Enter the " .. (dx and DX_Element.getTypeFriendly(dx.dxType).." " or "") .. "y rotation offset.\n\nNote: input is not filtered for invalid characters!", "Set Offset")
					mbox:descriptionLines(2)
					setElementData(mbox.input, "guieditor:filter", gFilters.noSpace)
					mbox.onAccept = 
						function(text, element)
							if text ~= "" then
								local dx = DX_Element.getDXFromElement(element)
					
								if dx then
									dx:rOffsetY(tonumber(text) or dx.rOffsetY_)
								end
							end
						end
					mbox.onAcceptArgs = {element}
					mbox.onClose = 
						function(element)
							setElementData(element, "guieditor.internal:rOffsetYInput", nil)
						end
					mbox.onCloseArgs = {element}
				end,
			onButtonClickArgs = {"__gui"},			
		}
	)
end


function createItem_postGUI()
	return MenuItem_Toggle:create(false, "Post GUI"):set(
		{
			onClickClose = false, 
			onClick = 
				function(element, postGUI, undoable)
					if getElementData(element, "guieditor.internal:dxElement") then
						local dx = DX_Element.ids[getElementData(element, "guieditor.internal:dxElement")]
							
						if dx.dxType then
							if undoable then
								local action = {}
								action[#action + 1] = {}
								action[#action].ufunc = DX_Text.postGUI
								action[#action].uvalues = {dx, dx.postGUI_}
								action[#action].rfunc = DX_Text.postGUI
								action[#action].rvalues = {dx, postGUI}

								action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." postGUI"
								UndoRedo.add(action)		
							end
							
							dx:postGUI(postGUI)
						end
						
						return
					end				
				end, 
			onClickArgs = {"__gui", "__value", true}, 
			itemID = "postGUI"
		}
	)
end


function createItem_dxShadow()
	return MenuItem_Toggle:create(false, "Shadow"):set(
		{
			onClickClose = false,
			onClick = 
				function(element, shadowed)
					local dx = DX_Element.getDXFromElement(element)
						
					if dx then
						dx:shadow(shadowed)
					end
				end,
			onClickArgs = {"__gui", "__value"},
			itemID = "shadow"
		}
	)
end

function createItem_dxShadowColour()
	return MenuItem_Text:create("Set shadow colour"):set(
		{
			onClick =
				function(element)
					local dx = DX_Element.getDXFromElement(element)
						
					if not dx then
						return
					end
					
					local cache = dx.shadowColour_
					
					colorPicker.openSelect()
					
					colorPicker.onClose = 
						function(r, g, b, a, element)
							--outputDebug("colour: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b) .. ", " .. tostring(a))
							local action = {}
							action[#action + 1] = {}
							action[#action].ufunc = DX_Element.set
							action[#action].uvalues = {dx, "shadowColour_", {cache[1], cache[2], cache[3], cache[4]}}
							action[#action].rfunc = DX_Element.set
							action[#action].rvalues = {dx, "shadowColour_", {r, g, b, a}}
							
							action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." shadow colour"
							UndoRedo.add(action)							
							
							dx.shadowColour_ = {r, g, b, a}
						end
					colorPicker.onCloseArgs = {element}
					
					colorPicker.onUpdateSelectedValue = 						
						function(r, g, b, a, element)
							dx.shadowColour_ = {r, g, b, a}
						end
					colorPicker.onUpdateSelectedValueArgs = {element}
					
					colorPicker.onIgnore = 						
						function(element, r, g, b, a)
							dx.shadowColour_ = {r, g, b, a}
						end
					colorPicker.onIgnoreArgs = {element, unpack(cache)}
				end,
			onClickArgs = {"__gui"},
			--[[
			condition = 
				function(element) 
					local dx = DX_Element.getDXFromElement(element)
						
					if dx then
						return dx:shadow()
					end
					
					return false
				end,
			conditionArgs = {"__gui"}
			]]
		}
	)
end


function createItem_dxOutline()
	return MenuItem_Toggle:create(false, "Outline"):set(
		{
			onClickClose = false,
			onClick = 
				function(element, outlined)
					local dx = DX_Element.getDXFromElement(element)
						
					if dx then
						dx:outline(outlined)
					end
				end,
			onClickArgs = {"__gui", "__value"},
			itemID = "outline"
		}
	)
end

function createItem_dxOutlineColour()
	return MenuItem_Text:create("Set outline colour"):set(
		{
			onClick =
				function(element)
					local dx = DX_Element.getDXFromElement(element)
						
					if not dx then
						return
					end
					
					local cache = dx.outlineColour_
					
					colorPicker.openSelect()
					
					colorPicker.onClose = 
						function(r, g, b, a, element)
							--outputDebug("colour: " .. tostring(r) .. ", " .. tostring(g) .. ", " .. tostring(b) .. ", " .. tostring(a))
							
							local action = {}
							action[#action + 1] = {}
							action[#action].ufunc = DX_Element.set
							action[#action].uvalues = {dx, "outlineColour_", {cache[1], cache[2], cache[3], cache[4]}}
							action[#action].rfunc = DX_Element.set
							action[#action].rvalues = {dx, "outlineColour_", {r, g, b, a}}
							
							action.description = "Set ".. DX_Element.getTypeFriendly(dx.dxType) .." outline colour"
							UndoRedo.add(action)								
							
							dx.outlineColour_ = {r, g, b, a}
						end
					colorPicker.onCloseArgs = {element}
					
					colorPicker.onUpdateSelectedValue = 						
						function(r, g, b, a, element)
							dx.outlineColour_ = {r, g, b, a}
						end
					colorPicker.onUpdateSelectedValueArgs = {element}
					
					colorPicker.onIgnore = 						
						function(element, r, g, b, a)
							dx.outlineColour_ = {r, g, b, a}
						end
					colorPicker.onIgnoreArgs = {element, unpack(cache)}
				end,
			onClickArgs = {"__gui"}
		}
	)
end