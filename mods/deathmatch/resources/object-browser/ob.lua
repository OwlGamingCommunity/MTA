loaded = false
local preloaded = false
index = 0
index2 = 0
index3 = 0

function rObject ()
	if previewobj then
		local x, y, z = getElementRotation(previewobj)
		setElementRotation (previewobj, x, y, z+0.5)
	elseif sObject then
		local sx, sy, wx, wy, wz = getCursorPosition()
		setElementPosition (sObject, wx, wy, wz)
	end
end

function changeobj ()
	if guiGetVisible (objbrowser) == true then
		if previewobj then
			destroyElement (previewobj)
		end
		local name = guiGridListGetItemText (grid, guiGridListGetSelectedItem ( grid ), 1)
		local x, y, z = getElementPosition (getLocalPlayer())
		local id = gettok ( name, 1, string.byte(':') )
		id = tonumber(id)
		previewobj = createObject (tonumber(id), x+40, y+40, z+80)
		local radius = getElementRadius(previewobj)
		outputChatBox("("..string.gsub(gettok(name,1,string.byte(':'))," ","")..") "..gettok(name,2,string.byte(':')),0,255,0)
		outputChatBox("Radius: "..radius,0,255,0)
		if(radius<0.300) then radius=0.300
		--elseif(radius>160) then radius=radius-(radius/7) end  --still doesn't fix some, so a less-accurate method is used on next line.
		elseif(radius>130) then radius=125 end
		radius = radius*1.25
		
		--certain objects don't show up correctly even with these changes, so we'll make custom handlers for those:
		if(id==1612) then radius = 40
		elseif(id==9829) then radius = 120
		elseif(id==9956) then radius = 120
		end
		
		setCameraPosition((x+40+radius), (y+40), (z+80+radius))
		setTimer (function() setCameraLookAt(x+40,y+40,z+80) end, 100, 1)
		if handled == false then
			toggleCameraFixedMode (true)
			addEventHandler ("onClientRender", getLocalPlayer(), rObject)
			handled = true
		end
	end
end

function openobjectsPre()
	if(preloaded==false) then
		outputChatBox("1st Time Loading Items.  This may take SEVERAL minutes... BE PATIENT!",255,0,0)
		setTimer(openobjects,300,1)
		preloaded = true
	else
		openobjects()
	end
end

function openobjects ()
	showCursor (true)
	handled = false
	guiSetVisible (objbrowser, true)
	local x, y, z = getElementPosition (getLocalPlayer())
	if loaded == false then
	xml = getResourceConfig("obj.xml")
	index = 0
	index2 = 0
	index3 = 0
    column = guiGridListAddColumn( grid, "Main", 0.85 )
	group = true
	group2 = true
	object = true
	while group ~= false do 
		group = xmlFindChild (xml, "group", index)
		--outputChatBox (tostring(group))
		local row = guiGridListAddRow ( grid )
		local name = xmlNodeGetAttribute (group, "name")
		if name ~= false then
        guiGridListSetItemText ( grid, row, column, tostring(name), true, false )
		end
			while group2 ~= false do 
				group2 = xmlFindChild (group, "group", index2)
				--outputChatBox (tostring(group2))
				local row2 = guiGridListAddRow ( grid )
				local name2 = xmlNodeGetAttribute (group2, "name")
				if name2 ~= false then
				guiGridListSetItemText ( grid, row2, column, "  "..tostring(name2), true, false )
				end
				while object ~= false do 
					object = xmlFindChild (group2, "object", index3)
					--outputChatBox (tostring(object))
					if object ~= false then
						local row3 = guiGridListAddRow ( grid )
						local name3 = xmlNodeGetAttribute (object, "name")
						local id = xmlNodeGetAttribute (object, "id")
						guiGridListSetItemText ( grid, row3, column, "    "..tostring(id)..":"..tostring(name3), false, false )
					end
					index3 = index3 + 1
				end
				object = true
				index3 =  0
				index2 = index2 + 1
				--group2 = false --uncomment this line to make loading super quick but only do 1 data set (for debug only)
			end
		group2 = true
		index2 = 0
		index = index + 1
		loaded = true
	end
	xmlUnloadFile(xml)
	end
end

function scroll (key, state)
	if guiGetVisible (objbrowser) == true then
		local r, c = guiGridListGetSelectedItem (grid)
		if key == "arrow_u" then
			guiGridListSetSelectedItem ( grid, r-1, 1 )
			changeobj ()
		elseif key == "arrow_d" then
			guiGridListSetSelectedItem ( grid, r+1, 1 )
			changeobj ()
		end
	end
end

function startup ()
	objbrowser = guiCreateWindow (0.7, 0.2, 0.3, 0.8, "Objects", true)
	objclose = guiCreateButton (0.25, 0.95, 0.5, 0.05, "Close", true, objbrowser)
	grid = guiCreateGridList (0, 0.1, 1, 0.8, true, objbrowser) 
	bindKey ("arrow_u", "down", scroll)
	bindKey ("arrow_d", "down", scroll)
	addEventHandler  ( "onClientGUIClick", grid, changeobj)
	addEventHandler ( "onClientGUIClick", objclose, 
		function ()
			showCursor (false)
			guiSetVisible (objbrowser, false)
			if previewobj then
				destroyElement (previewobj)
			end
			toggleCameraFixedMode (false)
			setCameraTarget (getLocalPlayer())
			removeEventHandler ("onClientRender", getLocalPlayer(), rObject)
			handled = false
		end
	)
	guiSetVisible (objbrowser, false)
	guiSetVisible (window, false) 
end

addCommandHandler ("objbrowser", openobjectsPre)
addCommandHandler ("obj", openobjectsPre)
addEventHandler ("onClientResourceStart", getResourceRootElement (getThisResource()), startup)