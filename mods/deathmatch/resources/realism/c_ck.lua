local wCK, gCK, bClose

addEvent( "showCKList", true )
addEventHandler( "showCKList", getLocalPlayer(),
	function( names, data )
		if wCK then
			destroyElement( wCK )
			wCK = nil
			
			showCursor( false )
		else
			local sx, sy = guiGetScreenSize()
			local windowname = data == 2 and "In Remembrance of ..." or "Missing People"
			wCK = guiCreateWindow( sx / 2 - 125, sy / 2 - 250, 250, 500, "(( " .. windowname .. " ))", false )
			
			gCK = guiCreateGridList( 0.03, 0.04, 0.94, 0.88, true, wCK )
			local colName = guiGridListAddColumn( gCK, "Name", 0.93 )
			for key, name in pairs( names ) do
				local row = guiGridListAddRow( gCK )
				guiGridListSetItemText( gCK, row, colName, name:gsub("_", " "), false, false, false )
			end
			
			bClose = guiCreateButton( 0.03, 0.93, 0.94, 0.07, "Close", true, wCK )
			addEventHandler( "onClientGUIClick", bClose,
				function( button, state )
					if button == "left" and state == "up" then
						destroyElement( wCK )
						wCK = nil
						
						showCursor( false )
					end
				end, false
			)
			
			showCursor( true )
		end
	end
)

local lPlayer = getLocalPlayer()
local ckGUIState = nil
ax, ay = nil
ckBody = nil

function clickCKBody(button, state, absX, absY, wx, wy, wz, element)
	local lPlayer = source
	if getElementData(lPlayer, "exclusiveGUI") then
		return
	end
	if (button=="right") and (state=="down") then
		for k, v in pairs(getElementsByType("ped", getResourceRootElement())) do
			if isElementStreamedIn(v) and getElementHealth(v) == 0 then
				local x, y, z = getElementPosition(v)
				local distance = getDistanceBetweenPoints3D(wx, wy, wz, x, y, z)
				if (distance<=1.4) then
					if (ckGUIState == 1) then
						hideCKInfo()
					else
						showCursor(true)
						ax = absX
						ay = absY
						ckBody = v
						triggerServerEvent("ck:info", v)
						return
					end
				end
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickCKBody)

function showCKInfo(text, name)
	hideCKInfo()
	
	ckInfoWindow = guiCreateWindow(ax, ay, 350, 200, name and ( "A corpse (( " .. name .. " )) " ) or "A corpse of a dead body.", false)

	local txt1 = guiCreateMemo(0.05, 0.12, 0.89, 0.7, tostring(text), true, ckInfoWindow)
	guiSetFont(txt1, "default-bold-small")
	guiMemoSetReadOnly (txt1, true)

	local cbutton = guiCreateButton(0.05, 0.85, 0.87, 0.1, "Close Menu", true, ckInfoWindow)
	addEventHandler("onClientGUIClick", cbutton, hideCKInfo, false)
	
	ckGUIState = 1
end
addEvent("ck:show", true)
addEventHandler("ck:show", getRootElement(), showCKInfo)

function hideCKInfo()
	if ckGUIState == 1 then
		showCursor(false)
		destroyElement(ckInfoWindow)
		ckGUIState = 0
	end
end

