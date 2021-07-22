--[[--------------------------------------------------
	GUI Editor
	client
	image_picker.lua
	
	creates the image picker gui
--]]--------------------------------------------------


ImagePicker = {
	gui = {},
	expanded,
	maxImageSize = 190,
	minImageSize = 5,
}


addEvent("guieditor:client_getImages", true)
addEventHandler("guieditor:client_getImages", root,
	function(images, permission)
		if images then
			local sortable = {}
			
			for name,_ in pairs(images) do
				sortable[#sortable + 1] = name
			end
			
			table.sort(sortable)
			
			ImagePicker.images = images
			ImagePicker.sorted = sortable
			local permissionWarning = ""
			
			if isBool(permission) and not permission then
				permissionWarning = "\n\n(Access to general.ModifyOtherObjects is needed to request images)"
			end
			
			if guiGetVisible(ImagePicker.gui.wndMain) then
				ImagePicker.gui.expandingGrid:setData(images, sortable, getResourceName(getThisResource()))

				if ImagePicker.reloading then
					if #sortable > 0 then
						MessageBox_Info:create("Image Picker Refresh", "Image list successfully updated from the server.")
					else
						MessageBox_Info:create("Image Picker Refresh", "Could not get the image list from the server.\n\nPlease check ACL permissions" .. permissionWarning)
					end
				else
					if #sortable == 0 then
						MessageBox_Info:create("Image Picker Refresh", "Could not get the image list from the server.\n\nPlease check ACL permissions" .. permissionWarning)
					end
				end
			end
		else
			if ImagePicker.reloading then
				MessageBox_Info:create("Image Picker Refresh", "Image list could not be updated from the server (request limit reached).\n\nTry again later.")
			end
		end
		
		ImagePicker.reloading = nil
	end
)


function ImagePicker.create()
	ImagePicker.gui.wndMain = guiCreateWindow((gScreen.x - 500) / 2, (gScreen.y - 400) / 2, 500, 400, "Image Picker", false)
	guiWindowSetSizable(ImagePicker.gui.wndMain, false)
	guiWindowTitlebarButtonAdd(ImagePicker.gui.wndMain, "Close", "right", ImagePicker.close)

	guiWindowTitlebarButtonAdd(ImagePicker.gui.wndMain, "Select", "left", 
		function()
			if ImagePicker.current then
				ImagePicker.select(ImagePicker.current.row, ImagePicker.current.col, ImagePicker.current.text, ImagePicker.current.resource, ImagePicker.current.data)
			end
		end
	)
	
	guiWindowTitlebarButtonAdd(ImagePicker.gui.wndMain, "Reload List", "left", 
		function()
			ImagePicker.reloading = true
			
			triggerServerEvent("guieditor:server_getImages", localPlayer)
		end
	)	
	
	
	ImagePicker.gui.expandingGrid = ExpandingGridList:create(10, 20, 250, 370, false, ImagePicker.gui.wndMain)
	ImagePicker.gui.expandingGrid:addColumn("Resource images")
	
	guiGridListAddRow(ImagePicker.gui.expandingGrid.gridlist)
	guiGridListSetItemText(ImagePicker.gui.expandingGrid.gridlist, 0, 1, "Loading...", true, false)
	
	ImagePicker.gui.expandingGrid.onRowClick = ImagePicker.preview
	ImagePicker.gui.expandingGrid.onRowDoubleClick = ImagePicker.select
	ImagePicker.gui.expandingGrid.onHeaderClick = 
		function()
			ImagePicker.current = nil
		end
	
	ImagePicker.gui.lblDescription = guiCreateLabel(260, 25, 240, 75, "Preview:", false, ImagePicker.gui.wndMain)
	guiLabelSetVerticalAlign(ImagePicker.gui.lblDescription, "center")
	guiLabelSetHorizontalAlign(ImagePicker.gui.lblDescription, "center")
	
	ImagePicker.gui.imgPreview = guiCreateStaticImage(285, 105, 190, 190, "images/arrow_out.png", false, ImagePicker.gui.wndMain)
	guiSetSize(ImagePicker.gui.imgPreview, 0, 0, false)
	
	ImagePicker.gui.imgBorderTL = guiCreateStaticImage(285, 105, 75, 1, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	ImagePicker.gui.imgBorderTR = guiCreateStaticImage(400, 105, 75, 1, "images/dot_white.png", false, ImagePicker.gui.wndMain)				
	ImagePicker.gui.imgBorderBL = guiCreateStaticImage(285, 295, 75, 1, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	ImagePicker.gui.imgBorderBR = guiCreateStaticImage(400, 295, 75, 1, "images/dot_white.png", false, ImagePicker.gui.wndMain)
		
	ImagePicker.gui.imgBorderLT = guiCreateStaticImage(285, 105, 1, 75, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	ImagePicker.gui.imgBorderLB = guiCreateStaticImage(285, 220, 1, 75, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	ImagePicker.gui.imgBorderRT = guiCreateStaticImage(475, 105, 1, 75, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	ImagePicker.gui.imgBorderRB = guiCreateStaticImage(475, 220, 1, 75, "images/dot_white.png", false, ImagePicker.gui.wndMain)
	
	local colour = gAreaColours.secondary
		
	guiSetProperty(ImagePicker.gui.imgBorderTL, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", colour, colour, colour, colour))
	guiSetProperty(ImagePicker.gui.imgBorderTR, "ImageColours", string.format("tl:00%s tr:FF%s bl:00%s br:FF%s", colour, colour, colour, colour))	
	guiSetProperty(ImagePicker.gui.imgBorderBL, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", colour, colour, colour, colour))
	guiSetProperty(ImagePicker.gui.imgBorderBR, "ImageColours", string.format("tl:00%s tr:FF%s bl:00%s br:FF%s", colour, colour, colour, colour))	
	
	guiSetProperty(ImagePicker.gui.imgBorderLT, "ImageColours", string.format("tl:FF%s tr:FF%s bl:00%s br:00%s", colour, colour, colour, colour))
	guiSetProperty(ImagePicker.gui.imgBorderLB, "ImageColours", string.format("tl:00%s tr:00%s bl:FF%s br:FF%s", colour, colour, colour, colour))	
	guiSetProperty(ImagePicker.gui.imgBorderRT, "ImageColours", string.format("tl:FF%s tr:FF%s bl:00%s br:00%s", colour, colour, colour, colour))
	guiSetProperty(ImagePicker.gui.imgBorderRB, "ImageColours", string.format("tl:00%s tr:00%s bl:FF%s br:FF%s", colour, colour, colour, colour))	
	
	
	ImagePicker.gui.lblInstructions = guiCreateLabel(260, 300, 240, 70, "Please start the resource\n\nto use this image", false, ImagePicker.gui.wndMain)
	guiLabelSetVerticalAlign(ImagePicker.gui.lblInstructions, "center")
	guiLabelSetHorizontalAlign(ImagePicker.gui.lblInstructions, "center")	
	guiSetVisible(ImagePicker.gui.lblInstructions, false)
	guiSetColour(ImagePicker.gui.lblInstructions, unpack(gColours.primary))
	
	--ImagePicker.gui.btnStart = guiCreateButton(300, 370, 160, 20, "Start resource", false, ImagePicker.gui.wndMain)
	--guiSetEnabled(ImagePicker.gui.btnStart, false)
	--guiSetVisible(ImagePicker.gui.btnStart, false)
	
	guiSetVisible(ImagePicker.gui.wndMain, false)
	doOnChildren(ImagePicker.gui.wndMain, setElementData, "guieditor.internal:noLoad", true)
end


function ImagePicker.open(images, sorted)
	if not ImagePicker.gui.wndMain then
		ImagePicker.create()
	else
		if guiGetVisible(ImagePicker.gui.wndMain) then
			ContextBar.add("The image picker is already open")
			return false
		end
	end

	--if not ImagePicker.startPermission then
		--guiSetEnabled(ImagePicker.gui.btnStart, false)
	--else
		--guiSetEnabled(ImagePicker.gui.btnStart, true)
	--end	

	if images or sorted then
		ImagePicker.images = images
		ImagePicker.sorted = sorted
		
		ImagePicker.gui.expandingGrid:setData(images, sorted, getResourceName(getThisResource()))
	elseif ImagePicker.images or ImagePicker.sorted then
		ImagePicker.gui.expandingGrid:setData(ImagePicker.images, ImagePicker.sorted, getResourceName(getThisResource()))
	else
		triggerServerEvent("guieditor:server_getImages", localPlayer)
	end
	
	guiSetVisible(ImagePicker.gui.wndMain, true)
	guiBringToFront(ImagePicker.gui.wndMain)
	
	return true
end


function ImagePicker.openFromMenu(parent, select, selectArgs)
	if ImagePicker.open() then
		ImagePicker.guiParent = parent
		
		ImagePicker.onSelect = select
		ImagePicker.onSelectArgs = selectArgs
	end
end


function ImagePicker.close()
	guiSetVisible(ImagePicker.gui.wndMain, false)
	ImagePicker.reloading = nil
end


function ImagePicker.preview(row, col, text, resource, data)
	ImagePicker.current = nil

	if not fileExists(":" .. resource .. "/" .. text) or not guiStaticImageLoadImage(ImagePicker.gui.imgPreview, ":" .. resource .. "/" .. text) then
		guiSetVisible(ImagePicker.gui.imgPreview, false)

		guiSetText(ImagePicker.gui.lblInstructions, "Please start the resource\n'"..resource.."'\nto use this image")
		guiSetVisible(ImagePicker.gui.lblInstructions, true)
		--guiSetVisible(ImagePicker.gui.btnStart, true)
		
		guiSetText(ImagePicker.gui.lblDescription, "Preview:\n\n["..tostring(resource).."]\n"..tostring(text))
	else
		ImagePicker.current = {
			row = row,
			col = col,
			text = text,
			resource = resource,
			data = data
		}
	
		local imageWidth, imageHeight = getImageSize(":" .. resource .. "/" .. text)
		local width, height = imageWidth, imageHeight
		
		if width and height then
			if width >= height then
				if width > ImagePicker.maxImageSize then
					width = ImagePicker.maxImageSize
					
					height = height / (imageWidth / width)
				elseif height < ImagePicker.minImageSize then
					height = ImagePicker.minImageSize
					
					width = width * (height / imageHeight)
				end
			else
				if height > ImagePicker.maxImageSize then
					height = ImagePicker.maxImageSize
					
					width = width / (imageHeight / height)
				elseif width < ImagePicker.minImageSize then
					width = ImagePicker.minImageSize
					
					height = height * (width / imageWidth)
				end			
			end
			
			-- 285, 105
			guiSetPosition(ImagePicker.gui.imgPreview, 285 + ((ImagePicker.maxImageSize - width) / 2), 105 + ((ImagePicker.maxImageSize - height) / 2), false)
			guiSetSize(ImagePicker.gui.imgPreview, width, height, false)
			
			guiSetText(ImagePicker.gui.lblDescription, "Preview:\n\n["..tostring(resource).."]\n"..tostring(text).."\n"..tostring(imageWidth).." x "..tostring(imageHeight))
		else
			guiSetText(ImagePicker.gui.lblDescription, "Preview:\n\n["..tostring(resource).."]\n"..tostring(text))
			
			guiSetPosition(ImagePicker.gui.imgPreview, 285, 105, false)		
			guiSetSize(ImagePicker.gui.imgPreview, ImagePicker.maxImageSize, ImagePicker.maxImageSize, false)			
		end
	
	
		guiSetVisible(ImagePicker.gui.imgPreview, true)
		guiSetVisible(ImagePicker.gui.lblInstructions, false)
		--guiSetVisible(ImagePicker.gui.btnStart, false)
	end
end


function ImagePicker.select(row, col, text, resource)
	if text:find("png") and fileExists(":" .. resource .. "/" .. text) then
		-- create image
		if ImagePicker.onSelect then
			local width, height = getImageSize(":" .. resource .. "/" .. text)
		
			ImagePicker.onSelect(row, col, text, resource, ImagePicker.guiParent, {width = width, height = height}, unpack(ImagePicker.onSelectArgs or {}))
		end
		
		ImagePicker.close()
	end
end


-- png file format information:
-- http://www.libpng.org/pub/png/spec/1.2/PNG-Chunks.html#C.IHDR
function getImageSize(path)
	if fileExists(path) then
		local file = fileOpen(path, true)
		
		if file then
			local width, height
			local data = fileRead(file, 100)
			local _,e = data:find("IHDR")

			if e then
				width = tonumber(string.format("%02X%02X%02X%02X", string.byte(data, e + 1, e + 4)), 16)
				height = tonumber(string.format("%02X%02X%02X%02X", string.byte(data, e + 5, e + 8)), 16)
			end
			
			fileClose(file)  
			
			return width, height
		end
	end
	
	return
end