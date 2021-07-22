


function CreateHelpCenter()
	if(Window == nil) then
		Window = {}
		Label = {}
		Image = {}
		Window[1] = guiCreateWindow(296,266,437,276,"Quick help",false)
		Window[2] = guiCreateWindow(304,330,424,115,"Quick help",false)
		guiSetAlpha(Window[1],1)

		Label[1] = guiCreateLabel(0.0389,0.1400,0.9245,0.0543,"Where can I see the available commands?",true,Window[1])
		Label[2] = guiCreateLabel(0.0401,0.2348,0.9175,0.581,"",true,Window[2])
		Label[3] = guiCreateLabel(0.3042,0.8348,0.4976,0.1304,"Click anywhere on the window to close it",true,Window[2])
		Label[4] = guiCreateLabel(0.8032,0.9022,0.1716,0.0616,"Close window",true,Window[1])
		Label[5] = guiCreateLabel(0.0389,0.2100,0.9245,0.0543,"How can I make the chatbox look better?",true,Window[1])
		Label[6] = guiCreateLabel(0.0389,0.2800,0.9245,0.0543,"I jump in a car, but I can't drive!",true,Window[1])
		Label[7] = guiCreateLabel(0.0389,0.3500,0.9245,0.0543,"How do I bind keys to commands?",true,Window[1])
		Label[8] = guiCreateLabel(0.0389,0.4200,0.9245,0.0543,"How do I contact the admins?",true,Window[1])
		Label[9] = guiCreateLabel(0.0389,0.4900,0.9245,0.0543,"Where can I get more info about roleplay basics?",true,Window[1])
		Label[10] = guiCreateLabel(0.0389,0.5600,0.9245,0.0543,"Sometimes when I use commands they don't work!",true,Window[1])
		Label[11] = guiCreateLabel(0.0389,0.6300,0.9245,0.0543,"I have a problem and its not listed here!",true,Window[1])
		
		Image[1] = guiCreateStaticImage(0.7529,0.1268,0.1487,0.2029,"info.png",true,Window[1])

		guiSetAlpha(Label[1],1)
		guiLabelSetVerticalAlign(Label[1],"top")
		guiLabelSetHorizontalAlign(Label[1],"left",false)
		guiSetFont(Label[1],"default-bold-small")
		
		for i=5,11 do
			guiSetAlpha(Label[i],1)
			guiLabelSetVerticalAlign(Label[i],"top")
			guiLabelSetHorizontalAlign(Label[i],"left",false)
			guiSetFont(Label[i],"default-bold-small")
		end
		
		guiLabelSetVerticalAlign(Label[2],"top")
		guiLabelSetHorizontalAlign(Label[2],"left",true)
		guiSetFont(Label[2],"default-bold-small")
		
		guiLabelSetVerticalAlign(Label[3],"top")
		guiLabelSetHorizontalAlign(Label[3],"left",false)
		guiSetFont(Label[3],"default-small")
		
		guiSetAlpha(Label[4],1)
		guiLabelSetVerticalAlign(Label[4],"top")
		guiLabelSetHorizontalAlign(Label[4],"left",false)
		
		guiSetAlpha(Image[1],1)
		guiSetVisible(Window[1], true)
		guiSetVisible(Window[2], false)
		showCursor(true)
		addEventHandler( "onClientGUIClick", Label[4], DestroyHelpCenter, false)
		addEventHandler( "onClientGUIClick", Window[2], HideSelection)
		addEventHandler( "onClientGUIClick", Label[1], function() Selection(1) end, false)
		addEventHandler( "onClientGUIClick", Label[5], function() Selection(2) end, false)
		addEventHandler( "onClientGUIClick", Label[6], function() Selection(3) end, false)
		addEventHandler( "onClientGUIClick", Label[7], function() Selection(4) end, false)
		addEventHandler( "onClientGUIClick", Label[8], function() Selection(5) end, false)
		addEventHandler( "onClientGUIClick", Label[9], function() Selection(6) end, false)
		addEventHandler( "onClientGUIClick", Label[10], function() Selection(7) end, false)
		addEventHandler( "onClientGUIClick", Label[11], function() Selection(8) end, false)
		
	end
end
addCommandHandler("helpme", CreateHelpCenter)

function DestroyHelpCenter()
	removeEventHandler( "onClientGUIClick", Label[4], DestroyHelpCenter, false)
	removeEventHandler( "onClientGUIClick", Label[3], HideSelection, false)
	removeEventHandler( "onClientGUIClick", Label[1], function() Selection(1) end, false)
	removeEventHandler( "onClientGUIClick", Label[5], function() Selection(2) end, false)
	removeEventHandler( "onClientGUIClick", Label[6], function() Selection(3) end, false)
	removeEventHandler( "onClientGUIClick", Label[7], function() Selection(4) end, false)
	removeEventHandler( "onClientGUIClick", Label[8], function() Selection(5) end, false)
	removeEventHandler( "onClientGUIClick", Label[9], function() Selection(6) end, false)
	removeEventHandler( "onClientGUIClick", Label[10], function() Selection(7) end, false)
	removeEventHandler( "onClientGUIClick", Label[11], function() Selection(8) end, false)
	
	guiSetVisible(Window[1], false)
	guiSetVisible(Window[2], false)
	showCursor(false)
	elements = getElementChildren(Window[1])
	for k,v in ipairs(elements) do
		destroyElement(v)
		v = nil
	end
	elements = getElementChildren(Window[2])
	for k,v in ipairs(elements) do
		destroyElement(v)
		v = nil
	end
	destroyElement(Window[1])
	destroyElement(Window[2])
	Window = nil
	Label = nil
	Image = nil
end

function HideSelection()
	guiSetVisible(Window[2], false)
	guiSetVisible(Window[1], true)
end

function Selection(opt)
	guiSetVisible(Window[1], false)
	guiSetVisible(Window[2], true)
	
	if(opt == 1) then
		xml = getResourceConfig("1.xml")
		entry = xmlNodeGetValue(xml)  
		guiSetText(Label[2], entry)
	elseif(opt == 2) then
		xml = getResourceConfig("2.xml")
		entry = xmlNodeGetValue(xml)  
		guiSetText(Label[2], entry)
	elseif(opt == 3) then
		xml = getResourceConfig("3.xml")
		entry = xmlNodeGetValue(xml)  
		guiSetText(Label[2], entry)
	elseif(opt == 4) then
		xml = getResourceConfig("4.xml")
		entry = xmlNodeGetValue(xml)  
		guiSetText(Label[2], entry)
	elseif(opt == 5) then
		xml = getResourceConfig("5.xml")
		entry = xmlNodeGetValue(xml)  
		guiSetText(Label[2], entry)
	elseif(opt == 6) then
		xml = getResourceConfig("6.xml")
		entry = xmlNodeGetValue(xml)  
		guiSetText(Label[2], entry)
	elseif(opt == 7) then
		xml = getResourceConfig("7.xml")
		entry = xmlNodeGetValue(xml)  
		guiSetText(Label[2], entry)
	elseif(opt == 8) then
		xml = getResourceConfig("8.xml")
		entry = xmlNodeGetValue(xml)  
		guiSetText(Label[2], entry)
	end
end

