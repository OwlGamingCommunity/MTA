--[[--------------------------------------------------
	GUI Editor
	client
	gui_properties.lua
	
	manage viewing and changing element properties
--]]--------------------------------------------------


Properties = {
	gui = {},
	data = {},
	
	-- map the gui elements to their property element names
	guiMap = {
		["gui-window"] = "FrameWindow",
		["gui-button"] = "Button",
		["gui-label"] = "StaticText",
		["gui-checkbox"] = "Checkbox",
		["gui-memo"] = "MultiLineEditbox",
		["gui-edit"] = "Editbox",
		["gui-gridlist"] = "MultiColumnList",
		["gui-progressbar"] = "ProgressBar",
		["gui-tabpanel"] = "TabControl",
		["gui-tab"] = "TabContentPane",
		["gui-radiobutton"] = "RadioButton",
		["gui-staticimage"] = "StaticImage",
		["gui-scrollpane"] = "ScrollablePane",
		["gui-scrollbar"] = "HorizontalScrollbar",
		["gui-combobox"] = "Combobox"
	}
}


function Properties.create()
	Properties.loadData()
	
	Properties.gui.wndMain = guiCreateWindow(10, gScreen.y - 350 - 10, 280, 350, "Properties", false)
	guiWindowSetSizable(Properties.gui.wndMain, false)
	guiWindowTitlebarButtonAdd(Properties.gui.wndMain, "Close", "right", Properties.close)
	guiWindowTitlebarButtonAdd(Properties.gui.wndMain, "Help", "left", function() Tutorial.startByID("properties") end)
	
	-- first screen, element type
	Properties.gui.tabElement = guiCreateGridList(10, 25, 260, 315, false, Properties.gui.wndMain)
	Properties.gui.paneElement = guiCreateScrollPane(30, 0, 200, 315, false, Properties.gui.tabElement)
	
	if Properties.data.widgets then
		Properties.gui.lblElement = {}
		
		for i,name in ipairs(Properties.data.widgetOrder) do
			Properties.gui.lblElement[i] = guiCreateLabel(0, (i - 1) * 20, 200, 20, name, false, Properties.gui.paneElement)
			guiLabelSetVerticalAlign(Properties.gui.lblElement[i], "center")
			setRolloverColour(Properties.gui.lblElement[i], gColours.primary, gColours.defaultLabel)
			
			addEventHandler("onClientGUIClick", Properties.gui.lblElement[i], Properties.clickWidget, false)
		end
	else
		Properties.gui.lblElement = {}
		
		Properties.gui.lblElement[1] = guiCreateLabel(0, 0, 200, 20, "Could not load properties file. Panic!", false, Properties.gui.paneElement)
		guiLabelSetVerticalAlign(Properties.gui.lblElement[1], "center")		
	end

	-- second screen, property type
	Properties.gui.tabProperty = guiCreateGridList(10, 25, 0, 315, false, Properties.gui.wndMain)
	Properties.gui.paneProperty = guiCreateScrollPane(30, 0, 200, 315, false, Properties.gui.tabProperty)
	
	Properties.gui.lblProperty = {}
	Properties.gui.lblProperty[1] = guiCreateLabel(0, 0, 200, 20, "[NO ELEMENT SELECTED]", false, Properties.gui.paneProperty)
	guiLabelSetVerticalAlign(Properties.gui.lblProperty[1], "center")
	guiLabelSetHorizontalAlign(Properties.gui.lblProperty[1], "center")

	-- third screen, property description
	Properties.gui.tabDescription = guiCreateGridList(10, 25, 0, 315, false, Properties.gui.wndMain)
	Properties.gui.paneDescription = guiCreateScrollPane(30, 0, 200, 315, false, Properties.gui.tabDescription)

	Properties.gui.lblDescriptionTitle = guiCreateLabel(0, 5, 200, 40, "[NO PROPERTY SELECTED]", false, Properties.gui.paneDescription)
	guiLabelSetVerticalAlign(Properties.gui.lblDescriptionTitle, "top")
	guiLabelSetHorizontalAlign(Properties.gui.lblDescriptionTitle, "center", true)	
	guiSetFont(Properties.gui.lblDescriptionTitle, "clear-normal")
	
	Properties.gui.lblDescription = guiCreateLabel(0, 40, 200, 235, "", false, Properties.gui.paneDescription)
	guiLabelSetVerticalAlign(Properties.gui.lblDescription, "center")
	guiLabelSetHorizontalAlign(Properties.gui.lblDescription, "center", true)	
	
	Properties.gui.lblCurrentValue = guiCreateLabel(0, 248, 200, 40, "Current value:", false, Properties.gui.paneDescription)
	guiLabelSetVerticalAlign(Properties.gui.lblCurrentValue, "bottom")
	guiLabelSetHorizontalAlign(Properties.gui.lblCurrentValue, "center", true)	
	setRolloverColour(Properties.gui.lblCurrentValue, gColours.primary, gColours.defaultLabel)
	
	addEventHandler("onClientGUIClick", Properties.gui.lblCurrentValue, 
		function()
			if Properties.currentValue or Properties.settingValue then
				return
			end
			
			if not Properties.element or not Properties.currentProperty then
				return
			end
			
			Properties.currentValue = true
			
			local mbox = MessageBox_Info:create(nil, "Current value:\n" .. guiGetProperty(Properties.element, Properties.currentProperty))
			guiWindowTitlebarButtonAdd(mbox.window, "Copy", "left", 
				function() 
					setClipboard(guiGetProperty(Properties.element, Properties.currentProperty)) 
					ContextBar.add("Property value copied to clipboard")
				end
			)
			mbox.onClose = 
				function() 
					Properties.currentValue = false
				end
			
			guiWindowSetSizable(mbox.window, true)
			
			local _,h = guiGetSize(mbox.accept, false)
			local x,y = guiGetPosition(mbox.accept, false)
			local _,h2 = guiGetSize(mbox.window, false)
			setElementData(mbox.accept, "guiSnapTo", {[gGUISides.left] = 0.25, [gGUISides.right] = 0.25, [gGUISides.bottom] = h2 - y - h, [gGUIDimensions.height] = h})
			setElementData(mbox.description, "guiSnapTo", {[gGUISides.left] = 0.05, [gGUISides.right] = 0.05, [gGUISides.top] = 0.15, [gGUISides.bottom] = 0.35})
		end
	, false)
	

	--[[
	Properties.gui.lblNewValue = guiCreateLabel(0, 290, 30, 20, "Set:", false, Properties.gui.paneDescription)
	guiLabelSetVerticalAlign(Properties.gui.lblNewValue, "center")
	guiLabelSetHorizontalAlign(Properties.gui.lblNewValue, "left")	
	
	Properties.gui.edtNewValue = guiCreateEdit(30, 290, 170, 20, "", false, Properties.gui.paneDescription)
	]]
	
	Properties.gui.btnNewValue = guiCreateButton(50, 293, 100, 20, "Set value", false, Properties.gui.paneDescription)
	addEventHandler("onClientGUIClick", Properties.gui.btnNewValue,
		function(button, state)
			if button == "left" and state == "up" then
				if Properties.settingValue or Properties.currentValue then
					return
				end
				
				if not Properties.element or not Properties.currentProperty then
					return
				end
			
				Properties.settingValue = true

				local mbox = MessageBox_Input:create(false, "Set Property", "Enter the new property value:", "Set")
				mbox.onAcceptArgs = {Properties.element, Properties.currentProperty}
				mbox.onAccept =
					function(text, element, property)
						local action = {}
						action[#action + 1] = {}
						action[#action].ufunc = guiSetProperty
						action[#action].uvalues = {element, property, guiGetProperty(element, property)}
						action[#action].rfunc = guiSetProperty
						action[#action].rvalues = {element, property, text}
						
						action[#action + 1] = {}
						action[#action].ufunc = Properties.updateDescription
						action[#action].uvalues = {}
						action[#action].rfunc = Properties.updateDescription
						action[#action].rvalues = {}						
						
						action.description = "Set "..stripGUIPrefix(getElementType(element)).." property"
						UndoRedo.add(action)
						
						guiSetProperty(element, property, text)
						
						local properties = getElementData(element, "guieditor:properties") or {}
						properties[property] = true
						setElementData(element, "guieditor:properties", properties)
						
						Properties.updateDescription()
						
						Properties.settingValue = false
					end		
				mbox.onClose = 
					function()
						Properties.settingValue = false
					end
			end
		end
	, false)
	
	-- crush stuff
	Properties.gui.lblElementForwardCrush = guiCreateLabel(240, 0, 20, 315, "<\n\n\n\n<\n\n\n\n<\n\n\n\n<\n\n\n\n<\n\n\n\n<", false, Properties.gui.tabElement)
	guiLabelSetVerticalAlign(Properties.gui.lblElementForwardCrush, "center")
	guiLabelSetHorizontalAlign(Properties.gui.lblElementForwardCrush, "center")
	guiSetColour(Properties.gui.lblElementForwardCrush, unpack(gColours.grey))
	setRolloverColour(Properties.gui.lblElementForwardCrush, gColours.primary, gColours.grey)
	setCrushToggle(Properties.gui.lblElementForwardCrush, 200, 260, Properties.gui.tabElement, Properties.gui.tabProperty, true)	
	
	Properties.gui.lblPropertyBackwardCrush = guiCreateLabel(0, 0, 20, 315, ">\n\n\n\n>\n\n\n\n>\n\n\n\n>\n\n\n\n>\n\n\n\n>", false, Properties.gui.tabProperty)
	guiLabelSetVerticalAlign(Properties.gui.lblPropertyBackwardCrush, "center")
	guiLabelSetHorizontalAlign(Properties.gui.lblPropertyBackwardCrush, "center")
	guiSetColour(Properties.gui.lblPropertyBackwardCrush, unpack(gColours.grey))
	setRolloverColour(Properties.gui.lblPropertyBackwardCrush, gColours.primary, gColours.grey)
	-- simulate a click on the crush toggle above so that it collapses 
	-- (it can't be clicked manually since it is now off the side of the parent element)
	addEventHandler("onClientGUIClick", Properties.gui.lblPropertyBackwardCrush,
		function(button, state)
			if button == "left" and state == "up" then
				triggerEvent("onClientGUIClick", Properties.gui.lblElementForwardCrush, "left", "up")
			end
		end
	, false)
	
	Properties.gui.lblPropertyForwardCrush = guiCreateLabel(240, 0, 20, 315, "<\n\n\n\n<\n\n\n\n<\n\n\n\n<\n\n\n\n<\n\n\n\n<", false, Properties.gui.tabProperty)
	guiLabelSetVerticalAlign(Properties.gui.lblPropertyForwardCrush, "center")
	guiLabelSetHorizontalAlign(Properties.gui.lblPropertyForwardCrush, "center")
	guiSetColour(Properties.gui.lblPropertyForwardCrush, unpack(gColours.grey))
	setRolloverColour(Properties.gui.lblPropertyForwardCrush, gColours.primary, gColours.grey)
	setCrushToggle(Properties.gui.lblPropertyForwardCrush, 200, 260, Properties.gui.tabProperty, Properties.gui.tabDescription, true)		
	
	Properties.gui.lblDescriptionBackwardCrush = guiCreateLabel(0, 0, 20, 315, ">\n\n\n\n>\n\n\n\n>\n\n\n\n>\n\n\n\n>\n\n\n\n>", false, Properties.gui.tabDescription)
	guiLabelSetVerticalAlign(Properties.gui.lblDescriptionBackwardCrush, "center")
	guiLabelSetHorizontalAlign(Properties.gui.lblDescriptionBackwardCrush, "center")
	guiSetColour(Properties.gui.lblDescriptionBackwardCrush, unpack(gColours.grey))
	setRolloverColour(Properties.gui.lblDescriptionBackwardCrush, gColours.primary, gColours.grey)
	addEventHandler("onClientGUIClick", Properties.gui.lblDescriptionBackwardCrush,
		function(button, state)
			if button == "left" and state == "up" then
				triggerEvent("onClientGUIClick", Properties.gui.lblPropertyForwardCrush, "left", "up")
			end
		end
	, false)	
	
	guiSetVisible(Properties.gui.wndMain, false)
	
	doOnChildren(Properties.gui.wndMain, setElementData, "guieditor.internal:noLoad", true)
end


function Properties.loadProperties(widget)
	if Properties.gui.lblProperty then
		for _,v in ipairs(Properties.gui.lblProperty) do
			destroyElement(v)
		end
	end
		
	if widget and widget ~= "" and Properties.data.widgets and Properties.data.widgets[widget] then
		Properties.gui.lblProperty = {}
		Properties.currentWidget = widget
		
		for i,name in ipairs(Properties.data.widgets[widget]) do
			Properties.gui.lblProperty[i] = guiCreateLabel(0, (i - 1) * 20, 200, 20, name, false, Properties.gui.paneProperty)
			
			guiLabelSetVerticalAlign(Properties.gui.lblProperty[i], "center")
			setRolloverColour(Properties.gui.lblProperty[i], gColours.primary, gColours.defaultLabel)
			
			addEventHandler("onClientGUIClick", Properties.gui.lblProperty[i], Properties.clickProperty, false)
		end
		
		-- there are some properties that the xml lists don't have
		if Properties.element and getElementType(Properties.element) ~= "gui-gridlist" then
			for name,value in pairs(guiGetProperties(Properties.element)) do
				if not table.find(Properties.data.widgets[widget], name) then
					local i = #Properties.gui.lblProperty + 1
					Properties.gui.lblProperty[i] = guiCreateLabel(0, (i - 1) * 20, 200, 20, name, false, Properties.gui.paneProperty)
					
					guiLabelSetVerticalAlign(Properties.gui.lblProperty[i], "center")
					setRolloverColour(Properties.gui.lblProperty[i], gColours.primary, gColours.defaultLabel)
					doOnChildren(Properties.gui.lblProperty[i], setElementData, "guieditor.internal:noLoad", true)
					
					addEventHandler("onClientGUIClick", Properties.gui.lblProperty[i], Properties.clickProperty, false)					
				end
			end
		end
	else
		Properties.gui.lblProperty[1] = guiCreateLabel(0, 0, 200, 20, "[NONE SELECTED]", false, Properties.gui.paneProperty)
		guiLabelSetVerticalAlign(Properties.gui.lblProperty[1], "center")
		doOnChildren(Properties.gui.lblProperty[1], setElementData, "guieditor.internal:noLoad", true)
		
		Properties.currentWidget = ""
	end	
end


function Properties.loadData()
	local file = xmlLoadFile("cegui/cegui_property_descriptions.xml")
	
	if file then
		Properties.data.properties = {}
		
		for i,node in ipairs(xmlNodeGetChildren(file)) do
			Properties.data.properties[xmlNodeGetAttribute(node, "name")] = xmlNodeGetAttribute(node, "description")
		end
		
		xmlUnloadFile(file)
	else
		outputDebug("Error loading 'cegui_property_descriptions.xml'")
	end
	
	
	file = xmlLoadFile("cegui/cegui_widgets.xml")
	
	if file then
		Properties.data.widgets = {}
		Properties.data.widgetOrder = {}
		
		for i,node in ipairs(xmlNodeGetChildren(file)) do
			local name = xmlNodeGetAttribute(node, "name")
			Properties.data.widgets[name] = {}
			
			table.insert(Properties.data.widgetOrder, name)
			
			for i,prop in ipairs(xmlNodeGetChildren(node)) do
				Properties.data.widgets[name][i] = xmlNodeGetAttribute(prop, "name")
			end
		end
		
		xmlUnloadFile(file)
	else
		outputDebug("Error loading 'cegui_widgets.xml'")
	end
end


function Properties.clickWidget(button, state)
	if button == "left" and state == "up" then
		for i,item in ipairs(Properties.gui.lblElement) do
			if getElementData(item, "guieditor.internal:selectedWidget") then
				setElementData(item, "guieditor.internal:selectedWidget", nil)
				setElementData(item, "guieditor:rolloffColour", gColours.defaultLabel)
				
				guiSetColour(item, unpack(gColours.defaultLabel))				
			end
		end
		
		setElementData(source, "guieditor.internal:selectedWidget", true)
		setElementData(source, "guieditor:rolloffColour", gColours.secondary)
		
		guiSetColour(source, unpack(gColours.secondary))
		
		triggerEvent("onClientGUIClick", Properties.gui.lblElementForwardCrush, "left", "up")
		
		Properties.loadProperties(guiGetText(source))
	end
end


function Properties.clickProperty(button, state)
	if button == "left" and state == "up" then
		for i,item in ipairs(Properties.gui.lblProperty) do
			if getElementData(item, "guieditor.internal:selectedWidget") then
				setElementData(item, "guieditor.internal:selectedWidget", nil)
				setElementData(item, "guieditor:rolloffColour", gColours.defaultLabel)
				
				guiSetColour(item, unpack(gColours.defaultLabel))				
			end
		end
		
		Properties.currentProperty = guiGetText(source)
		
		setElementData(source, "guieditor.internal:selectedWidget", true)
		setElementData(source, "guieditor:rolloffColour", gColours.secondary)
		
		guiSetColour(source, unpack(gColours.secondary))	
	
		if Properties.data.properties[guiGetText(source)] then
			guiSetText(Properties.gui.lblDescription, Properties.data.properties[guiGetText(source)])	
		else
			guiSetText(Properties.gui.lblDescription, "[NO DESCRIPTION AVAILABLE]")	
		end
		
		guiSetText(Properties.gui.lblDescriptionTitle, "(" .. Properties.currentWidget .. ")\n" .. guiGetText(source) .. ":")
		
		Properties.updateDescription()
		
		triggerEvent("onClientGUIClick", Properties.gui.lblPropertyForwardCrush, "left", "up")
	end
end


function Properties.updateDescription()	
	if not Properties.gui or not Properties.gui.wndMain then
		return
	end
	
	if not guiGetVisible(Properties.gui.wndMain) then
		return
	end
	
	if Properties.element then
		guiSetText(Properties.gui.lblCurrentValue, "Current value: " .. guiGetProperty(Properties.element, Properties.currentProperty))
	else
		guiSetText(Properties.gui.lblCurrentValue, "Current value: [NO ELEMENT]")
	end
end


function Properties.open(element)
	if not Properties.gui.wndMain then
		Properties.create()
	end
	
	if guiGetVisible(Properties.gui.wndMain) then
		ContextBar.add("The properties window is already in use")
		return
	end

	if element and exists(element) then
		Properties.element = element
	
		local elementName = Properties.guiMap[getElementType(element)]
		
		if elementName then
			for i,item in ipairs(Properties.gui.lblElement) do
				if elementName == guiGetText(item) then
					setElementData(item, "guieditor.internal:selectedWidget", true)
					setElementData(item, "guieditor:rolloffColour", gColours.secondary)
					
					guiSetColour(item, unpack(gColours.secondary))		
					
					triggerEvent("onClientGUIClick", Properties.gui.lblElementForwardCrush, "left", "up")

					Properties.loadProperties(guiGetText(item))	
				else
					setElementData(item, "guieditor.internal:selectedWidget", nil)
					setElementData(item, "guieditor:rolloffColour", gColours.defaultLabel)
					
					guiSetColour(item, unpack(gColours.defaultLabel))						
				end
			end		
		end
	end
	
	guiSetVisible(Properties.gui.wndMain, true)
	guiBringToFront(Properties.gui.wndMain)
end


function Properties.close()
	if not guiGetVisible(Properties.gui.wndMain) then
		return
	end
	
	-- reset all the panes
	if getCrush(Properties.gui.lblPropertyForwardCrush).direction == -1 then
		triggerEvent("onClientGUIClick", Properties.gui.lblPropertyForwardCrush, "left", "up")
	end	
	
	if getCrush(Properties.gui.lblElementForwardCrush).direction == -1 then
		triggerEvent("onClientGUIClick", Properties.gui.lblElementForwardCrush, "left", "up")
	end
	
	Properties.element = nil

	guiSetVisible(Properties.gui.wndMain, false)
end