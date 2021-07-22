local sw, sh = guiGetScreenSize ( )
local gui = { }
localPlayer = getLocalPlayer()

function frames_showTexGUI ( )
	local interiorID = getElementDimension ( localPlayer )
	local interiorWorld = getElementInterior( localPlayer )
	
	if (interiorID > 0 and interiorWorld > 0) or (exports.integration:isPlayerLeadAdmin(localPlayer) and exports.global:isAdminOnDuty(localPlayer)) or (exports.integration:isPlayerScripter(localPlayer) and exports.global:isStaffOnDuty(localPlayer)) then
		if (interiorID < 20000 and exports.global:hasItem(localPlayer, 4, interiorID)) or (interiorID < 20000 and exports.global:hasItem(localPlayer, 5, interiorID)) or (interiorID > 20000 and exports.global:hasItem(localPlayer, 3, interiorID-20000)) or (exports.integration:isPlayerAdmin(localPlayer) and exports.global:isAdminOnDuty(localPlayer)) or (exports.integration:isPlayerScripter(localPlayer) and exports.global:isStaffOnDuty(localPlayer)) or (interiorID == 0) then
			if not gui.window then
				local width = 600
				local height = 460
				local x = ( sw - width ) / 2
				local y = ( sh - height ) / 2
				
				local windowTitle = "Texture list for interior ID #" .. interiorID
				if(interiorID > 20000) then
					windowTitle = "Texture list for interior of vehicle #" .. interiorID - 20000
					if(not exports.global:hasItem(localPlayer, 3, interiorID-20000)) then
						windowTitle = "Texture list for interior of vehicle #" .. interiorID - 20000 .. " (Admin access)"
					end
				elseif(interiorWorld == 0) then
					windowTitle = "Texture list for exterior region #" .. interiorID .. " (Admin access)"
				else
					if(not exports.global:hasItem(localPlayer, 4, interiorID) and not exports.global:hasItem(localPlayer, 5, interiorID)) then
						windowTitle = "Texture list for interior ID #"..interiorID.." (Admin access)"
					end
				end
				gui.window = guiCreateWindow ( x, y, width, height, windowTitle, false )
				gui.list = guiCreateGridList ( 10, 25, width - 20, height - 150, false, gui.window )
				gui.remove = guiCreateButton ( 10, height - 120, width - 20, 25, "Remove selected texture", false, gui.window )
				gui.rotate = guiCreateButton ( 10, height - 90, width - 20, 25, "Rotate selected texture by 90°", false, gui.window )
				gui.removeall = guiCreateButton ( 10, height - 60, width - 20, 25, "Remove all textures", false, gui.window )
				gui.cancel = guiCreateButton ( 10, height - 30, width - 20, 25, "Cancel", false, gui.window )
				
				guiGridListAddColumn ( gui.list, "ID", 0.1 ) 
				guiGridListAddColumn ( gui.list, "Texture", 0.2 ) 
				guiGridListAddColumn ( gui.list, "URL", 0.8 ) 

				guiWindowSetSizable ( gui.window, false )
				guiSetEnabled ( gui.remove, false )
				guiSetEnabled ( gui.rotate, false )
				showCursor ( true )
				
				frames_fillTexList( savedTextures[getElementDimension(localPlayer)] or {})
				
				addEventHandler ( "onClientGUIClick", gui.window, frames_texWindowClick )
				addEventHandler("onClientGUIDoubleClick", gui.window, frames_texWindowDoubleClick)
			else
				frames_hideTexGUI ( )
			end
		else
			outputChatBox ( "You do not own this interior.", 255, 0, 0, false )
		end
	else
		outputChatBox ( "You are not inside an interior.", 255, 0, 0, false )
	end
end

function frames_texWindowClick ( button, state )
	if button == "left" and state == "up" then
		if source == gui.cancel then
			frames_hideTexGUI ( )
		elseif source == gui.list then
			local texID = guiGridListGetItemText ( gui.list, guiGridListGetSelectedItem ( gui.list ), 1 )
			triggerEvent("frames:list", resourceRoot, getElementDimension(localPlayer), savedTextures[getElementDimension(localPlayer)])
			
			if texID ~= "" then
				guiSetEnabled ( gui.remove, true )
				guiSetEnabled ( gui.rotate, true )
				triggerServerEvent("frames:highlightTexture", resourceRoot, tonumber(texID))
			else
				guiSetEnabled ( gui.remove, false )
				guiSetEnabled ( gui.rotate, false )
			end
		elseif source == gui.remove then
			local texID = guiGridListGetItemText ( gui.list, guiGridListGetSelectedItem ( gui.list ), 1 )

			if texID ~= "" then
				guiSetEnabled(gui.list, false)
				triggerServerEvent ( "frames:delete", resourceRoot, tonumber( texID ) )
			end
		elseif source == gui.rotate then
			local texID = guiGridListGetItemText ( gui.list, guiGridListGetSelectedItem ( gui.list ), 1 )

			if texID ~= "" then
				triggerServerEvent ( "frames:updateRotation", resourceRoot, tonumber( texID ) )
			end
		elseif source == gui.removeall then
			guiSetEnabled ( gui.remove, false )
			guiSetEnabled ( gui.rotate, false )
			triggerServerEvent ( "frames:deleteAll", resourceRoot )
		end
	end
end


function frames_texWindowDoubleClick()
    if source == gui.list then
        local url = guiGridListGetItemText ( gui.list, guiGridListGetSelectedItem ( gui.list ), 3 )
        if url ~= "" then
            outputChatBox("URL copied to clipboard.")
            setClipboard(url)
        end
    end
end

function frames_hideTexGUI ( )
	if gui.window then
		if (guiGridListGetSelectedItem(gui.list) ~= -1) then 
			triggerEvent("frames:list", resourceRoot, getElementDimension(localPlayer), savedTextures[getElementDimension(localPlayer)])
		end
		destroyElement ( gui.window )
		gui.window = nil
		
		showCursor ( false )
	end
end

function frames_reloadList ( )
	guiSetEnabled(gui.list, true)
	frames_fillTexList( savedTextures[getElementDimension(localPlayer)] or {})
end

addEvent("frames:reloadList", true)
addEventHandler("frames:reloadList", localPlayer, frames_reloadList)

function frames_fillTexList ( texList )
	if gui.list then
		guiGridListClear ( gui.list )
	end
	
	local any = false
	for _, tex in pairs ( texList ) do
		any = true
		local row = guiGridListAddRow ( gui.list )
		
		guiGridListSetItemText ( gui.list, row, 1, tex.id, false, false )
		guiGridListSetItemText ( gui.list, row, 2, tex.texture, false, false )
		guiGridListSetItemText ( gui.list, row, 3, tex.url, false, false )
	end

	if not any then
		guiGridListSetItemText ( gui.list, guiGridListAddRow ( gui.list ), 1, "None", true, false )
		return
	end
end

addCommandHandler ( "texlist", frames_showTexGUI )
