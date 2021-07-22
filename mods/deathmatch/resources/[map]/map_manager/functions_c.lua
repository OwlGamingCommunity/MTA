--[[
* ***********************************************************************************************************************
* Copyright (c) 2016 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local GUIEditor = {
    button = {},
    window = {},
    label = {},
    memo = {}
}

local function generateMapContent( objects )
	local buffer = '<map edf:definitions="editor_main">'
	for i, obj in ipairs( objects ) do
        if string.find(tostring(obj.id), "removeWorldObject") then
	        buffer = buffer..'\n    '..'<removeWorldObject id="object ('..i..')" radius="'..obj.radius..'" interior="'..obj.interior..'" model="'..obj.model..'" posX="'..obj.posX..'" posY="'..obj.posY..'" posZ="'..obj.posZ..'" rotX="'..obj.rotX..'" rotY="'..obj.rotY..'" rotZ="'..obj.rotZ..'"></removeWorldObject>'
	    else
            buffer = buffer..'\n    '..'<object id="object ('..i..')" breakable="'..( obj.breakable == 0 and 'false' or 'true' )..'" interior="0" alpha="'..( obj.alpha and obj.alpha or 255 )..'" model="'..obj.model..'" doublesided="'..( obj.doublesided == 0 and 'false' or 'true' )..'" scale="'..( obj.scale and obj.scale or '1.0000000' )..'" dimension="0" posX="'..obj.posX..'" posY="'..obj.posY..'" posZ="'..obj.posZ..'" rotX="'..obj.rotX..'" rotY="'..obj.rotY..'" rotZ="'..obj.rotZ..'"></object>'
        end
    end
	buffer = buffer..'\n</map>'
	return buffer
end

addEvent( 'map:exportinteriormap', true )
addEventHandler( 'map:exportinteriormap', resourceRoot, function ( objects )
	closeExporter()
    GUIEditor.window[1] = guiCreateWindow(562, 184, 800, 600, "Map Objects Exporter - Interior #"..objects[1].dimension, false)
    guiWindowSetSizable(GUIEditor.window[1], false)
    exports.global:centerWindow( GUIEditor.window[1] )
    local content = generateMapContent( objects )
    GUIEditor.memo[1] = guiCreateMemo(9, 22, 781, 525, content or "Error..", false, GUIEditor.window[1])
    GUIEditor.button[1] = guiCreateButton(679, 557, 111, 29, "Close", false, GUIEditor.window[1])
    GUIEditor.button[2] = guiCreateButton(558, 557, 111, 29, "Save to file", false, GUIEditor.window[1])
    GUIEditor.button[3] = guiCreateButton(437, 557, 111, 29, "Copy to clipboard", false, GUIEditor.window[1])
    GUIEditor.label[1] = guiCreateLabel(13, 556, 401, 30, "Description: "..( objects[1].comment and objects[1].comment or "N/A" ), false, GUIEditor.window[1])
    guiLabelSetVerticalAlign(GUIEditor.label[1], "center")  

    addEventHandler( 'onClientGUIClick', GUIEditor.window[1], function ()
    	if source == GUIEditor.button[1] then
    		closeExporter()
    	elseif source == GUIEditor.button[2] then
    		local file = fileCreate( 'exported/'..objects[1].dimension..'.map' )
    		if file then
    			fileWrite( file, content )
    			fileClose( file )
    			exports.global:playSoundSuccess()
    			outputChatBox( "Done! File is located in your MTA folder at '/mods/deathmatch/resources/map_manager/exported/"..objects[1].dimension..".map" )	
    		else
    			exports.global:playSoundError()
    			outputChatBox( "Errors occurred while writing data to file." )
    		end
    	elseif source == GUIEditor.button[3] then
    		if setClipboard ( content ) then
    			exports.global:playSoundSuccess()
    			outputChatBox( "Copied" )
    		end
    	end
    end )

    addEventHandler( 'account:changingchar', root, closeExporter )
end )

addEvent( 'map:exportexteriormap', true )
addEventHandler( 'map:exportexteriormap', resourceRoot, function ( objects )
    closeExporter()
    GUIEditor.window[1] = guiCreateWindow(562, 184, 800, 600, "Map Objects Exporter - Map ID #"..objects[1].map_id, false)
    guiWindowSetSizable(GUIEditor.window[1], false)
    exports.global:centerWindow( GUIEditor.window[1] )
    local content = generateMapContent( objects )
    GUIEditor.memo[1] = guiCreateMemo(9, 22, 781, 525, content or "Error..", false, GUIEditor.window[1])
    GUIEditor.button[1] = guiCreateButton(679, 557, 111, 29, "Close", false, GUIEditor.window[1])
    GUIEditor.button[2] = guiCreateButton(558, 557, 111, 29, "Save to file", false, GUIEditor.window[1])
    GUIEditor.button[3] = guiCreateButton(437, 557, 111, 29, "Copy to clipboard", false, GUIEditor.window[1])
    GUIEditor.label[1] = guiCreateLabel(13, 556, 401, 30, "Description: "..( objects[1].comment and objects[1].comment or "N/A" ), false, GUIEditor.window[1])
    guiLabelSetVerticalAlign(GUIEditor.label[1], "center")  

    addEventHandler( 'onClientGUIClick', GUIEditor.window[1], function ()
        if source == GUIEditor.button[1] then
            closeExporter()
        elseif source == GUIEditor.button[2] then
            local file = fileCreate( 'exported/Exterior-'..objects[1].map_id..'.map' )
            if file then
                fileWrite( file, content )
                fileClose( file )
                exports.global:playSoundSuccess()
                outputChatBox( "Done! File is located in your MTA folder at '/mods/deathmatch/resources/map_manager/exported/Exterior-"..objects[1].map_id..".map" )  
            else
                exports.global:playSoundError()
                outputChatBox( "Errors occurred while writing data to file." )
            end
        elseif source == GUIEditor.button[3] then
            if setClipboard ( content ) then
                exports.global:playSoundSuccess()
                outputChatBox( "Copied" )
            end
        end
    end )

    addEventHandler( 'account:changingchar', root, closeExporter )
end )

function closeExporter()
	if GUIEditor.window[1] and isElement( GUIEditor.window[1] ) then
		destroyElement( GUIEditor.window[1] )
		GUIEditor.window[1] = nil
		removeEventHandler( 'account:changingchar', root, closeExporter )
	end
end

