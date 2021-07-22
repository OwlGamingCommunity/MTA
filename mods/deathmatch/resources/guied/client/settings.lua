--[[--------------------------------------------------
	GUI Editor
	client
	settings.lua
	
	manages the gui editor settings
	(loading / saving / interface)
--]]--------------------------------------------------


Settings = {
	gui = {},
	default = {
		--guieditor_tutorial_completed = {value = false, type = "boolean"},
		--guieditor_tutorial_version = {value = "1.0", type = "string"},
		guieditor_update_check = {value = true, type = "boolean"},

		snapping = {value = true, type = "boolean"},
		snapping_precision = {value = 3, type = "number"},
		snapping_influence = {value = 300, type = "number"},
		snapping_recommended = {value = 10, type = "number"},	

		position_code_movement_warning = {value = true, type = "boolean"},
		
		load_code_parse_calculations = {value = true, type = "boolean"},
		
		output_window_autosize = {value = true, type = "boolean"},
		-- either implement these or add them to the depreciated list
		--screen_output_type = {value = false, type = "boolean"}
		--child_output_type = {value = false, type = "boolean"}
	},
	loaded = {
	
	},
}
Settings.areaColourPacked = {Settings.areaColour, Settings.areaColour, Settings.areaColour, Settings.areaColour}

gDeprecatedSettings = {child_output_type = true, screen_output_type = true, guieditor_tutorial_version = true, guieditor_tutorial_completed = true}


function Settings.setup()
	if Settings.gui.wndMain then
		return
	end
	
	Settings.loadFile()
	Settings.createGUI()
	
	Snapping.updateValues()
end


--[[--------------------------------------------------
	GUI things below
--]]--------------------------------------------------

function Settings.createGUI()
	Settings.gui.wndMain = guiCreateWindow((gScreen.x - 280) / 2, (gScreen.y - 320) / 2, 280, 320, "Settings", false)
	guiWindowSetSizable(Settings.gui.wndMain, false)
	guiWindowTitlebarButtonAdd(Settings.gui.wndMain, "Cancel", "right", Settings.closeGUI)
	guiWindowTitlebarButtonAdd(Settings.gui.wndMain, "Save", "left", Settings.saveGUI)
	
	--[[--------------------------------------------------
		update
	--]]--------------------------------------------------
	Settings.gui.chkUpdateCheck = guiCreateCheckBox(20, 30, 230, 20, "Automatically check for updates", toBool(Settings.loaded.guieditor_update_check.value), false, Settings.gui.wndMain)
	
	Settings.gui.lblUpdateCheckCrush = guiCreateLabel(250, 30, 20, 20, "<<", false, Settings.gui.wndMain)
	setRolloverColour(Settings.gui.lblUpdateCheckCrush, gColours.primary, gColours.defaultLabel)

	Settings.gui.lblUpdateHelp = guiCreateLabel(20, 25, 0, 30, "Let the GUI Editor automatically check\nfor updates when it starts.", false, Settings.gui.wndMain)
	guiLabelSetVerticalAlign(Settings.gui.lblUpdateHelp, "center")
	setCrushToggle(Settings.gui.lblUpdateCheckCrush, 250, 230, Settings.gui.chkUpdateCheck, Settings.gui.lblUpdateHelp)
	
	Settings.gui.imgUpdateAreaLeft = guiCreateStaticImage(10, 25, 1, 30, "images/dot_white.png", false, Settings.gui.wndMain)
	Settings.gui.imgUpdateAreaTop = guiCreateStaticImage(10, 25, 260, 1, "images/dot_white.png", false, Settings.gui.wndMain)
	Settings.gui.imgUpdateAreaBottom = guiCreateStaticImage(10, 55, 260, 1, "images/dot_white.png", false, Settings.gui.wndMain)
	guiSetProperty(Settings.gui.imgUpdateAreaLeft, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Settings.gui.imgUpdateAreaTop, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Settings.gui.imgUpdateAreaBottom, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))
	
	
	--[[--------------------------------------------------
		snapping
	--]]--------------------------------------------------
	Settings.gui.chkSnapping = guiCreateCheckBox(20, 70, 230, 20, "Enable snapping", toBool(Settings.loaded.snapping.value), false, Settings.gui.wndMain)	
	Settings.gui.lblSnappingCrush = guiCreateLabel(250, 70, 20, 20, "<<", false, Settings.gui.wndMain)
	setRolloverColour(Settings.gui.lblSnappingCrush, gColours.primary, gColours.defaultLabel)
	Settings.gui.lblSnappingHelp = guiCreateLabel(20, 65, 0, 30, "Let an element being moved 'snap' to\nthe edges of nearby elements.", false, Settings.gui.wndMain)
	guiLabelSetVerticalAlign(Settings.gui.lblSnappingHelp, "center")
	setCrushToggle(Settings.gui.lblSnappingCrush, 250, 230, Settings.gui.chkSnapping, Settings.gui.lblSnappingHelp)	
	
	addEventHandler("onClientGUIClick", Settings.gui.chkSnapping, 
		function(button, state)
			if button == "left" and state == "up" then
				if guiCheckBoxGetSelected(Settings.gui.chkSnapping) then
					guiSetEnabled(Settings.gui.lblSnappingPrecision, true)
					guiSetEnabled(Settings.gui.lblSnappingInfluence, true)
					guiSetEnabled(Settings.gui.lblSnappingOffset, true)
				else
					guiSetEnabled(Settings.gui.lblSnappingPrecision, false)
					guiSetEnabled(Settings.gui.lblSnappingInfluence, false)
					guiSetEnabled(Settings.gui.lblSnappingOffset, false)
				end
			end
		end
	, false)
	
	
	-- precision
	Settings.gui.lblSnappingPrecision = guiCreateLabel(20, 95, 230, 30, "", false, Settings.gui.wndMain)
	Settings.gui.lblSnappingPrecisionDescription = guiCreateLabel(0, 5, 60, 20, "Precision: ", false, Settings.gui.lblSnappingPrecision)
	Settings.gui.lblSnappingPrecisionEdit = guiCreateEdit(70, 5, 100, 20, tostring(Settings.loaded.snapping_precision.value), false, Settings.gui.lblSnappingPrecision)
	setElementData(Settings.gui.lblSnappingPrecisionEdit, "guieditor:filter", gFilters.numberInt)
	--Settings.gui.lblSnappingPrecisionDefault = guiCreateLabel(175, 5, 30, 20, "Default", false, Settings.gui.lblSnappingPrecision)
	--guiSetFont(Settings.gui.lblSnappingPrecisionDefault, "default-small")
	--guiLabelSetVerticalAlign(Settings.gui.lblSnappingPrecisionDefault, "center")
	--setRolloverColour(Settings.gui.lblSnappingPrecisionDefault, gColours.primary, gColours.defaultLabel)
	Settings.gui.lblSnappingPrecisionCrush = guiCreateLabel(250, 100, 20, 20, "<<", false, Settings.gui.wndMain)
	setRolloverColour(Settings.gui.lblSnappingPrecisionCrush, gColours.primary, gColours.defaultLabel)
	Settings.gui.lblSnappingPrecisionHelp = guiCreateLabel(20, 95, 0, 30, "The pixel distance from an edge an\nelement needs to be before it 'snaps'.", false, Settings.gui.wndMain)
	guiLabelSetVerticalAlign(Settings.gui.lblSnappingPrecisionHelp, "center")
	setCrushToggle(Settings.gui.lblSnappingPrecisionCrush, 250, 230, Settings.gui.lblSnappingPrecision, Settings.gui.lblSnappingPrecisionHelp)	
	
	Settings.gui.imgSnappingPrecisionReset = guiCreateStaticImage(190, 8, 14, 14, "images/reset.png", false, Settings.gui.lblSnappingPrecision)
	Settings.gui.lblSnappingPrecisionReset = guiCreateLabel(180, 2, 34, 30, "reset to default", false, Settings.gui.lblSnappingPrecision)
	guiSetFont(Settings.gui.lblSnappingPrecisionReset, "default-small")
	guiSetColour(Settings.gui.lblSnappingPrecisionReset, unpack(gColours.primary))
	guiLabelSetVerticalAlign(Settings.gui.lblSnappingPrecisionReset, "top")
	guiLabelSetHorizontalAlign(Settings.gui.lblSnappingPrecisionReset, "center", true)
	guiSetVisible(Settings.gui.lblSnappingPrecisionReset, false)
	
	addEventHandler("onClientMouseEnter", Settings.gui.imgSnappingPrecisionReset, 
		function() 
			guiSetVisible(Settings.gui.lblSnappingPrecisionReset, true)
			guiSetVisible(Settings.gui.imgSnappingPrecisionReset, false)
		end, 
	false)
	
	addEventHandler("onClientMouseLeave", Settings.gui.lblSnappingPrecisionReset, 
		function() 
			guiSetVisible(Settings.gui.lblSnappingPrecisionReset, false) 
			guiSetVisible(Settings.gui.imgSnappingPrecisionReset, true) 
		end, 
	false)
	
	addEventHandler("onClientGUIClick", Settings.gui.lblSnappingPrecisionReset,
		function()
			guiSetText(Settings.gui.lblSnappingPrecisionEdit, tostring(Settings.default.snapping_precision.value))
		end,
	false)
	
	
	-- influence
	Settings.gui.lblSnappingInfluence = guiCreateLabel(20, 125, 230, 30, "", false, Settings.gui.wndMain)
	Settings.gui.lblSnappingInfluenceDescription = guiCreateLabel(0, 5, 60, 20, "Influence: ", false, Settings.gui.lblSnappingInfluence)
	Settings.gui.lblSnappingInfluenceEdit = guiCreateEdit(70, 5, 100, 20, tostring(Settings.loaded.snapping_influence.value), false, Settings.gui.lblSnappingInfluence)
	setElementData(Settings.gui.lblSnappingInfluenceEdit, "guieditor:filter", gFilters.numberInt)
	Settings.gui.lblSnappingInfluenceCrush = guiCreateLabel(250, 130, 20, 20, "<<", false, Settings.gui.wndMain)
	setRolloverColour(Settings.gui.lblSnappingInfluenceCrush, gColours.primary, gColours.defaultLabel)
	Settings.gui.lblSnappingInfluenceHelp = guiCreateLabel(20, 125, 0, 30, "Only elements within this distance\ncan be snapped to.", false, Settings.gui.wndMain)
	guiLabelSetVerticalAlign(Settings.gui.lblSnappingInfluenceHelp, "center")
	setCrushToggle(Settings.gui.lblSnappingInfluenceCrush, 250, 230, Settings.gui.lblSnappingInfluence, Settings.gui.lblSnappingInfluenceHelp)	

	Settings.gui.imgSnappingInfluenceReset = guiCreateStaticImage(190, 8, 14, 14, "images/reset.png", false, Settings.gui.lblSnappingInfluence)
	Settings.gui.lblSnappingInfluenceReset = guiCreateLabel(180, 2, 34, 30, "reset to default", false, Settings.gui.lblSnappingInfluence)
	guiSetFont(Settings.gui.lblSnappingInfluenceReset, "default-small")
	guiSetColour(Settings.gui.lblSnappingInfluenceReset, unpack(gColours.primary))
	guiLabelSetVerticalAlign(Settings.gui.lblSnappingInfluenceReset, "top")
	guiLabelSetHorizontalAlign(Settings.gui.lblSnappingInfluenceReset, "center", true)
	guiSetVisible(Settings.gui.lblSnappingInfluenceReset, false)
	
	addEventHandler("onClientMouseEnter", Settings.gui.imgSnappingInfluenceReset, 
		function() 
			guiSetVisible(Settings.gui.lblSnappingInfluenceReset, true)
			guiSetVisible(Settings.gui.imgSnappingInfluenceReset, false)
		end, 
	false)
	
	addEventHandler("onClientMouseLeave", Settings.gui.lblSnappingInfluenceReset, 
		function() 
			guiSetVisible(Settings.gui.lblSnappingInfluenceReset, false) 
			guiSetVisible(Settings.gui.imgSnappingInfluenceReset, true) 
		end, 
	false)
	
	addEventHandler("onClientGUIClick", Settings.gui.lblSnappingInfluenceReset,
		function()
			guiSetText(Settings.gui.lblSnappingInfluenceEdit, tostring(Settings.default.snapping_influence.value))
		end,
	false)	
	
	-- offset
	Settings.gui.lblSnappingOffset = guiCreateLabel(20, 155, 230, 30, "", false, Settings.gui.wndMain)
	Settings.gui.lblSnappingOffsetDescription = guiCreateLabel(0, 5, 60, 20, "Offset: ", false, Settings.gui.lblSnappingOffset)
	Settings.gui.lblSnappingOffsetEdit = guiCreateEdit(70, 5, 100, 20, tostring(Settings.loaded.snapping_recommended.value), false, Settings.gui.lblSnappingOffset)
	setElementData(Settings.gui.lblSnappingOffsetEdit, "guieditor:filter", gFilters.numberInt)
	Settings.gui.lblSnappingOffsetCrush = guiCreateLabel(250, 160, 20, 20, "<<", false, Settings.gui.wndMain)
	setRolloverColour(Settings.gui.lblSnappingOffsetCrush, gColours.primary, gColours.defaultLabel)
	Settings.gui.lblSnappingOffsetHelp = guiCreateLabel(20, 155, 0, 30, "Add additional snap points this far\nfrom the egdes of elements.", false, Settings.gui.wndMain)
	guiLabelSetVerticalAlign(Settings.gui.lblSnappingOffsetHelp, "center")
	setCrushToggle(Settings.gui.lblSnappingOffsetCrush, 250, 230, Settings.gui.lblSnappingOffset, Settings.gui.lblSnappingOffsetHelp)		
	
	Settings.gui.imgSnappingOffsetReset = guiCreateStaticImage(190, 8, 14, 14, "images/reset.png", false, Settings.gui.lblSnappingOffset)
	Settings.gui.lblSnappingOffsetReset = guiCreateLabel(180, 2, 34, 30, "reset to default", false, Settings.gui.lblSnappingOffset)
	guiSetFont(Settings.gui.lblSnappingOffsetReset, "default-small")
	guiSetColour(Settings.gui.lblSnappingOffsetReset, unpack(gColours.primary))
	guiLabelSetVerticalAlign(Settings.gui.lblSnappingOffsetReset, "top")
	guiLabelSetHorizontalAlign(Settings.gui.lblSnappingOffsetReset, "center", true)
	guiSetVisible(Settings.gui.lblSnappingOffsetReset, false)
	
	addEventHandler("onClientMouseEnter", Settings.gui.imgSnappingOffsetReset, 
		function() 
			guiSetVisible(Settings.gui.lblSnappingOffsetReset, true)
			guiSetVisible(Settings.gui.imgSnappingOffsetReset, false)
		end, 
	false)
	
	addEventHandler("onClientMouseLeave", Settings.gui.lblSnappingOffsetReset, 
		function() 
			guiSetVisible(Settings.gui.lblSnappingOffsetReset, false) 
			guiSetVisible(Settings.gui.imgSnappingOffsetReset, true) 
		end, 
	false)	

	addEventHandler("onClientGUIClick", Settings.gui.lblSnappingOffsetReset,
		function()
			guiSetText(Settings.gui.lblSnappingOffsetEdit, tostring(Settings.default.snapping_recommended.value))
		end,
	false)	
	
	
	if toBool(Settings.loaded.snapping.value) then	
		guiSetEnabled(Settings.gui.lblSnappingPrecision, true)
		guiSetEnabled(Settings.gui.lblSnappingInfluence, true)
		guiSetEnabled(Settings.gui.lblSnappingOffset, true)
	else
		guiSetEnabled(Settings.gui.lblSnappingPrecision, false)
		guiSetEnabled(Settings.gui.lblSnappingInfluence, false)
		guiSetEnabled(Settings.gui.lblSnappingOffset, false)	
	end	
	
	Settings.gui.imgSnappingAreaLeft = guiCreateStaticImage(10, 65, 1, 120, "images/dot_white.png", false, Settings.gui.wndMain)
	Settings.gui.imgSnappingAreaTop = guiCreateStaticImage(10, 65, 260, 1, "images/dot_white.png", false, Settings.gui.wndMain)
	Settings.gui.imgSnappingAreaBottom = guiCreateStaticImage(10, 185, 260, 1, "images/dot_white.png", false, Settings.gui.wndMain)
	guiSetProperty(Settings.gui.imgSnappingAreaLeft, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Settings.gui.imgSnappingAreaTop, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Settings.gui.imgSnappingAreaBottom, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))
	
	--[[--------------------------------------------------
		position code movement warning
	--]]--------------------------------------------------
	Settings.gui.chkPositionCodeMovementWarning = guiCreateCheckBox(20, 200, 230, 20, "Enable position code move warning", toBool(Settings.loaded.position_code_movement_warning.value), false, Settings.gui.wndMain)
	
	Settings.gui.lblPositionCodeMovementWarningCrush = guiCreateLabel(250, 200, 20, 20, "<<", false, Settings.gui.wndMain)
	setRolloverColour(Settings.gui.lblPositionCodeMovementWarningCrush, gColours.primary, gColours.defaultLabel)

	Settings.gui.lblPositionCodeMovementWarningHelp = guiCreateLabel(20, 195, 0, 30, "Show a warning when trying to move\nan element that uses position code.", false, Settings.gui.wndMain)
	guiLabelSetVerticalAlign(Settings.gui.lblPositionCodeMovementWarningHelp, "center")
	setCrushToggle(Settings.gui.lblPositionCodeMovementWarningCrush, 250, 230, Settings.gui.chkPositionCodeMovementWarning, Settings.gui.lblPositionCodeMovementWarningHelp)
	
	Settings.gui.imgPositionCodeAreaLeft = guiCreateStaticImage(10, 195, 1, 30, "images/dot_white.png", false, Settings.gui.wndMain)
	Settings.gui.imgPositionCodeAreaTop = guiCreateStaticImage(10, 195, 260, 1, "images/dot_white.png", false, Settings.gui.wndMain)
	Settings.gui.imgPositionCodeAreaBottom = guiCreateStaticImage(10, 225, 260, 1, "images/dot_white.png", false, Settings.gui.wndMain)
	guiSetProperty(Settings.gui.imgPositionCodeAreaLeft, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Settings.gui.imgPositionCodeAreaTop, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Settings.gui.imgPositionCodeAreaBottom, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))	
	
	
	--[[--------------------------------------------------
		load code calculations
	--]]--------------------------------------------------
	Settings.gui.chkLoadCodeCalculations = guiCreateCheckBox(20, 240, 230, 20, "Load code position calculations", toBool(Settings.loaded.load_code_parse_calculations.value), false, Settings.gui.wndMain)
	
	Settings.gui.lblLoadCodeCalculationsCrush = guiCreateLabel(250, 240, 20, 20, "<<", false, Settings.gui.wndMain)
	setRolloverColour(Settings.gui.lblLoadCodeCalculationsCrush, gColours.primary, gColours.defaultLabel)

	Settings.gui.lblLoadCodeCalculationsHelp = guiCreateLabel(20, 235, 0, 30, "Attempt to parse position calculations \nwhen loading code. 'Help' for more info.", false, Settings.gui.wndMain)
	guiLabelSetVerticalAlign(Settings.gui.lblLoadCodeCalculationsHelp, "center")
	--guiSetFont(Settings.gui.lblLoadCodeCalculationsHelp, "default-small")
	setCrushToggle(Settings.gui.lblLoadCodeCalculationsCrush, 250, 230, Settings.gui.chkLoadCodeCalculations, Settings.gui.lblLoadCodeCalculationsHelp)
	
	Settings.gui.imgLoadCodeAreaLeft = guiCreateStaticImage(10, 235, 1, 30, "images/dot_white.png", false, Settings.gui.wndMain)
	Settings.gui.imgLoadCodeAreaTop = guiCreateStaticImage(10, 235, 260, 1, "images/dot_white.png", false, Settings.gui.wndMain)
	Settings.gui.imgLoadCodeAreaBottom = guiCreateStaticImage(10, 265, 260, 1, "images/dot_white.png", false, Settings.gui.wndMain)
	guiSetProperty(Settings.gui.imgLoadCodeAreaLeft, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Settings.gui.imgLoadCodeAreaTop, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Settings.gui.imgLoadCodeAreaBottom, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))	
	
	--[[--------------------------------------------------
		output window autosize
	--]]--------------------------------------------------
	Settings.gui.chkOutputWindowAutosize = guiCreateCheckBox(20, 280, 230, 20, "Automatically size output window", toBool(Settings.loaded.output_window_autosize.value), false, Settings.gui.wndMain)
	
	Settings.gui.lblOutputWindowAutosizeCrush = guiCreateLabel(250, 280, 20, 20, "<<", false, Settings.gui.wndMain)
	setRolloverColour(Settings.gui.lblOutputWindowAutosizeCrush, gColours.primary, gColours.defaultLabel)

	Settings.gui.lblOutputWindowAutosizeHelp = guiCreateLabel(20, 275, 0, 30, "Attempt to automatically resize the\ncode output window to fit code length.", false, Settings.gui.wndMain)
	guiLabelSetVerticalAlign(Settings.gui.lblOutputWindowAutosizeHelp, "center")
	setCrushToggle(Settings.gui.lblOutputWindowAutosizeCrush, 290, 230, Settings.gui.chkOutputWindowAutosize, Settings.gui.lblOutputWindowAutosizeHelp)
	
	Settings.gui.imgOutputWindowAreaLeft = guiCreateStaticImage(10, 275, 1, 30, "images/dot_white.png", false, Settings.gui.wndMain)
	Settings.gui.imgOutputWindowAreaTop = guiCreateStaticImage(10, 275, 260, 1, "images/dot_white.png", false, Settings.gui.wndMain)
	Settings.gui.imgOutputWindowAreaBottom = guiCreateStaticImage(10, 305, 260, 1, "images/dot_white.png", false, Settings.gui.wndMain)
	guiSetProperty(Settings.gui.imgOutputWindowAreaLeft, "ImageColours", string.format("tl:FF%s tr:FF%s bl:FF%s br:FF%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Settings.gui.imgOutputWindowAreaTop, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))
	guiSetProperty(Settings.gui.imgOutputWindowAreaBottom, "ImageColours", string.format("tl:FF%s tr:00%s bl:FF%s br:00%s", unpack(gAreaColours.primaryPacked)))	
	
	
	guiSetVisible(Settings.gui.wndMain, false)
	doOnChildren(Settings.gui.wndMain, setElementData, "guieditor.internal:noLoad", true)
	--setElementData(Settings.gui.wndMain, "guieditor.internal:noLoad", true)
end


function Settings.closeGUI()
	guiSetVisible(Settings.gui.wndMain, false)
	
	guiCheckBoxSetSelected(Settings.gui.chkUpdateCheck, toBool(Settings.loaded.guieditor_update_check.value))
	guiCheckBoxSetSelected(Settings.gui.chkSnapping, toBool(Settings.loaded.snapping.value))
	guiSetText(Settings.gui.lblSnappingPrecisionEdit, tostring(Settings.loaded.snapping_precision.value))
	guiSetText(Settings.gui.lblSnappingInfluenceEdit, tostring(Settings.loaded.snapping_influence.value))
	guiSetText(Settings.gui.lblSnappingOffsetEdit, tostring(Settings.loaded.snapping_recommended.value))	
	guiCheckBoxSetSelected(Settings.gui.chkLoadCodeCalculations, toBool(Settings.loaded.load_code_parse_calculations.value))
	guiCheckBoxSetSelected(Settings.gui.chkOutputWindowAutosize, toBool(Settings.loaded.output_window_autosize.value))
	
	Snapping.updateValues()
end


function Settings.openGUI()
	guiSetVisible(Settings.gui.lblSnappingPrecisionReset, false)
	guiSetVisible(Settings.gui.imgSnappingPrecisionReset, true)

	guiSetVisible(Settings.gui.lblSnappingInfluenceReset, false)
	guiSetVisible(Settings.gui.imgSnappingInfluenceReset, true)

	guiSetVisible(Settings.gui.lblSnappingOffsetReset, false)
	guiSetVisible(Settings.gui.imgSnappingOffsetReset, true)

	guiSetVisible(Settings.gui.wndMain, true)
	guiBringToFront(Settings.gui.wndMain, true)
end


function Settings.saveGUI()
	Settings.loaded.guieditor_update_check.value = guiCheckBoxGetSelected(Settings.gui.chkUpdateCheck)
	
	Settings.loaded.snapping.value = guiCheckBoxGetSelected(Settings.gui.chkSnapping)
	Settings.loaded.snapping_precision.value = tonumber(guiGetText(Settings.gui.lblSnappingPrecisionEdit))
	Settings.loaded.snapping_influence.value = tonumber(guiGetText(Settings.gui.lblSnappingInfluenceEdit))
	Settings.loaded.snapping_recommended.value = tonumber(guiGetText(Settings.gui.lblSnappingOffsetEdit))	
	
	Settings.loaded.position_code_movement_warning.value = guiCheckBoxGetSelected(Settings.gui.chkPositionCodeMovementWarning)
	
	Settings.loaded.load_code_parse_calculations.value = guiCheckBoxGetSelected(Settings.gui.chkLoadCodeCalculations)
	
	Settings.loaded.output_window_autosize.value = guiCheckBoxGetSelected(Settings.gui.chkOutputWindowAutosize)
	
	Settings.saveFile()
	
	Settings.closeGUI()
	
	ContextBar.add("Settings saved")
end


function Settings.saveFile()
	local file = xmlLoadFile("settings.xml")
	
	if not file then
		Settings.createFile()
		
		file = xmlLoadFile("settings.xml")
		
		if not file then
			return
		end
	end
	
	-- old version, make it conform to new layout
	if xmlNodeGetName(file) == "settings" then
		xmlNodeSetName(file, "guieditor")
	end
	
	-- remove nodes that are sitting below the base guieditor (previously settings) node
	-- they now exist within \guieditor\settings instead
	for i,node in ipairs(xmlNodeGetChildren(file)) do
		local value = xmlNodeGetValue(node)
		if Settings.default[xmlNodeGetName(node)] then
			xmlDestroyNode(node)
		end
	end		
	
	local base = getChild(file, "settings", 0)
	
	if base then
		for name, setting in pairs(Settings.loaded) do
			local node = getChild(base, tostring(name), 0)
			if node then
				xmlNodeSetValue(node, tostring(setting.value))
			else
				outputDebug("Failed to save GUI Editor '"..tostring(name).."' setting.")
			end
		end
	end
	
	xmlSaveFile(file)
	xmlUnloadFile(file)
	
	return
end


function Settings.createFile()
	local file = xmlLoadFile("settings.xml")
	
	if not file then
		file = xmlCreateFile("settings.xml", "guieditor")
		
		if file then
			outputDebug("Created GUI Editor settings file successfully.")
		else
			outputDebug("Could not create GUI Editor settings file (Uh oh!)")
			return
		end
	end
	
	local base = xmlCreateChild(file, "settings")
	
	if base then
		for name, setting in pairs(Settings.default) do
			local node = xmlCreateChild(base, tostring(name))
			if node then
				xmlNodeSetValue(node, tostring(setting.value))
			else
				outputDebug("Failed to create GUI Editor '"..tostring(name).."' setting.")
			end
		end
	end
	
	xmlSaveFile(file)
	xmlUnloadFile(file)
	
	return
end


function getChild(parent, name, index)
	local child = xmlFindChild(parent, name, index)
	if not child then 
		child = xmlCreateChild(parent, name) 
	end
	
	return child
end


function Settings.loadFile()
	local file = xmlLoadFile("settings.xml")
	
	if not file then
		outputDebug("Couldnt find GUI Editor settings file. Creating...")
		Settings.createFile()
		
		file = xmlLoadFile("settings.xml")
	end
	
	if file then
		local base

		-- old version
		if xmlNodeGetName(file) == "settings" then
			base = file
		-- new version
		elseif xmlNodeGetName(file) == "guieditor" then
			base = getChild(file, "settings", 0)
		end
		
		if base then
			for i,node in ipairs(xmlNodeGetChildren(base)) do
				local value = xmlNodeGetValue(node)
				if value and xmlNodeGetName(node) ~= "settings" then
					local name = xmlNodeGetName(node)
					-- silly side effect of having shitty settings to begin with
					-- redirect deprecated names onto their new counterparts
					name = checkOutdatedNodes(node)
					
					if not gDeprecatedSettings[name] then
						local formatted = formatValue(value, name)
						if formatted ~= nil then
							Settings.loaded[name] = {}
							Settings.loaded[name].value = formatted
							Settings.loaded[name].type = Settings.default[name].type					
						else
							outputDebug("Failed to load GUI Editor '"..name.."' setting. Using default...")
							Settings.loaded[name] = {}
							Settings.loaded[name].value = Settings.default[name].value		
							Settings.loaded[name].type = Settings.default[name].type					
						end
					else
						xmlDestroyNode(node)
					end
				end
			end
			
			for name, setting in pairs(Settings.default) do
				if not Settings.loaded[name] then
					outputDebug("Couldn't find GUI Editor '"..name.."' setting. Using default...")
					Settings.loaded[name] = {}
					Settings.loaded[name].value = setting.value
					Settings.loaded[name].type = setting.type
				end
			end	
		else
			outputDebug("Couldn't find GUI Editor settings node. Using defaults...")
			for name, setting in pairs(Settings.default) do
				Settings.loaded[name] = {}
				Settings.loaded[name].value = setting.value
				Settings.loaded[name].type = setting.type
			end			
		end
		
		xmlSaveFile(file)
		xmlUnloadFile(file)
	else
		outputDebug("Failed to load GUI Editor settings. Using defaults...")
		for name, setting in pairs(Settings.default) do
			Settings.loaded[name] = {}
			Settings.loaded[name].value = setting.value
			Settings.loaded[name].type = setting.type
		end		
	end
	
	Settings.saveFile()

	return	
end


function formatValue(value, name)	
	if name and Settings.default[name] then
		if Settings.default[name].type == "string" then
			return tostring(value)
		elseif Settings.default[name].type == "number" then
			return tonumber(value)
		elseif Settings.default[name].type == "boolean" then
			return loadstring("return "..tostring(value))()
		end
	end
	return nil
end


function checkOutdatedNodes(node)
	local name = xmlNodeGetName(node)
	
	if name == "tutorial" then
		xmlDestroyNode(node)
		outputDebug("Destroying deprecated GUI Editor settings node '"..name.."'.", "SETTINGS")
		return "guieditor_tutorial_completed"
	elseif name == "tutorialversion" then
		xmlDestroyNode(node)
		outputDebug("Destroying deprecated GUI Editor settings node '"..name.."'.", "SETTINGS")
		return "guieditor_tutorial_version"	
	elseif name == "updatecheck" then
		xmlDestroyNode(node)
		outputDebug("Destroying deprecated GUI Editor settings node '"..name.."'.", "SETTINGS")
		return "guieditor_update_check"
	end
	return name
end
