local actual_block = nil
local IFP = {
	-- Name of the block specified in animations.xml , filePath to the ifp file.
	[1] = { blockName = "OWL", path = "custom/owl.ifp"},
}
ani_all = {}

function xmlToTable(xmlFile, index)
	local xml = getResourceConfig(xmlFile)
	if not xml then
		return false
	end
	local result
	if index then
		result = dumpXMLToTable(xmlFindChild(xml, "group", index), "anim")
	else
		result = dumpXMLToTable(xml, "group")
	end
	
	xmlUnloadFile(xml)
	return result
end

function dumpXMLToTable(parentNode, key)
	local results = {}
	local i = 0
	local groupNode = xmlFindChild(parentNode, key, i)
	while groupNode do
		local group = {'group', name=xmlNodeGetAttribute(groupNode, 'name'), index=i}
		table.insert(results, group)
		i = i + 1
		groupNode = xmlFindChild(parentNode, key, i)
	end
	return results
end

function ani_start()
	local width, height = guiGetScreenSize()
	ani_window = guiCreateWindow(width-560, height-(height/2), 550, 312, "Animations", false)
	guiWindowSetSizable(ani_window,false)

	ani_tab_panel = guiCreateTabPanel(10, 27, 530, 275, false, ani_window)

	ani_tab_all = guiCreateTab("All", ani_tab_panel)
		ani_grid = guiCreateGridList(7, 8, 513, 193, false, ani_tab_all)
		guiGridListSetSortingEnabled(ani_grid, false)
		
			addEventHandler("onClientGUIDoubleClick", ani_grid, ani_animation, false)
		
			guiGridListAddColumn(ani_grid, "", 0.9)
		
		ani_loop = guiCreateCheckBox(10, 221, 104, 15, "Repeat", false, false, ani_tab_all)

		ani_button = guiCreateButton(119, 221, 93, 21, "Start", false, ani_tab_all)
			addEventHandler("onClientGUIClick", ani_button, ani_animation, false)
			
		ani_add_favourites = guiCreateButton(222, 221, 93, 21, "Favourite", false, ani_tab_all)
			addEventHandler("onClientGUIClick", ani_add_favourites, ani_add, false)
		
		ani_close = guiCreateButton(325, 221, 93, 21, "Close", false, ani_tab_all)
			addEventHandler("onClientGUIClick", ani_close, ani_zamknij, false)

	ani_tab_favourites = guiCreateTab("Favourites", ani_tab_panel)
		addEventHandler("onClientGUITabSwitched", ani_tab_favourites, ani_getfavourites)
		ani_grid_fav = guiCreateGridList(7, 8, 513, 193, false, ani_tab_favourites)
		guiGridListSetSortingEnabled(ani_grid_fav, false)
		
			guiGridListAddColumn(ani_grid_fav, "Block", 0.3)
			guiGridListAddColumn(ani_grid_fav, "Animation", 0.4)
			guiGridListAddColumn(ani_grid_fav, "Command", 0.25)
			addEventHandler("onClientGUIDoubleClick", ani_grid_fav, ani_animation, false)
		
		ani_loop_fav = guiCreateCheckBox(10, 221, 104, 15, "Repeat", false, false, ani_tab_favourites)

		ani_button_fav = guiCreateButton(119, 221, 93, 21, "Start", false, ani_tab_favourites)
			addEventHandler("onClientGUIClick", ani_button_fav, ani_animation, false)
			
		ani_add_favourites_fav = guiCreateButton(222, 221, 93, 21, "Delete", false, ani_tab_favourites)
			addEventHandler("onClientGUIClick", ani_add_favourites_fav, ani_del, false)
		
		ani_close_fav = guiCreateButton(325, 221, 93, 21, "Close", false, ani_tab_favourites)
			addEventHandler("onClientGUIClick", ani_close_fav, ani_zamknij, false)

	guiSetVisible(ani_window,false)
	
	ani_getall()
	
	xmlFile = ani_loadfile()
	ani_aktualizuj(true)
end

function ani_loadfile()
	local file = xmlLoadFile("favourite.xml")
	if not file then
		file = xmlCreateFile("favourite.xml", "favourites")
	end
	
	xmlSaveFile(file)
	
	if xmlFindChild(file, "animation", 0) then
		local childrens = xmlNodeGetChildren(file)
		
		for key, node in pairs(childrens) do
			local anim = xmlNodeGetAttribute(node, "animation")
			local block = xmlNodeGetAttribute(node, "block")
			
			if not isAnimation(block, anim) then
				xmlDestroyNode(node)
				xmlSaveFile(file)
			end
		end
	end

	return file
end

function isAnimation(block, name)
	for key, value in pairs(ani_all) do
		if value.group == block and value.anim == name then
			return true
		end
	end
	return false
end

function ani_zamknij()
	if guiGetVisible(ani_window) then
		guiSetVisible(ani_window, false)
		showCursor(false)	
	end
end

function ani_otworz()
	if not guiGetVisible(ani_window) then
		guiSetVisible(ani_window, true)
		showCursor(true)
	end
end
	
function ani_add()
	local tekst = guiGridListGetItemText(ani_grid, guiGridListGetSelectedItem(ani_grid), 1)
	if tekst ~= "" then
		if tekst ~= "..." then
			if actual_block and tekst then
				if isAnimation(actual_block, tekst) then
					local add_confirm_window = guiCreateWindow(648, 361, 296, 125, "Animations", false)
					guiWindowSetSizable(add_confirm_window, false)
					guiSetInputEnabled(true)

					local add_confirm_label = guiCreateLabel(11, 34, 270, 20, "Command shortcut (leave blank for none):", false, add_confirm_window)
					local add_confirm_edit = guiCreateEdit(10, 60, 276, 25, "", false, add_confirm_window)
					local add_confirm_back = guiCreateButton(11, 95, 108, 20, "Back", false, add_confirm_window)
					local add_confirm_save = guiCreateButton(178, 95, 108, 20, "Save", false, add_confirm_window)
					
					addEventHandler("onClientGUIClick", add_confirm_window, function()
						if source == add_confirm_save then
							if string.match(guiGetText(add_confirm_edit), "%w") then
								local child = xmlCreateChild(xmlFile, "animation")
								
								xmlNodeSetAttribute(child, "block", actual_block)
								xmlNodeSetAttribute(child, "animation", tekst)
								if guiGetText(add_confirm_edit) ~= "" then
									xmlNodeSetAttribute(child, "command", guiGetText(add_confirm_edit))
									outputChatBox("You can use your animation by typing /anim " .. guiGetText(add_confirm_edit) .. ".", 0, 255, 0)
								end
								
								xmlSaveFile(xmlFile)
								
								destroyElement(add_confirm_window)
								guiSetInputEnabled(false)
							else
								guiSetText(add_confirm_label, "Invalid characters detected!")
							end
						elseif source == add_confirm_back then
							destroyElement(add_confirm_window)
							guiSetInputEnabled(false)
						end
					end)
				end
			end
		end
	end
end

function ani_del()
	local selected = guiGridListGetSelectedItem(ani_grid_fav)
	if tekst ~= -1 then
		local tekst = guiGridListGetItemText(ani_grid_fav, selected, 1)
		if tekst ~= "" then
			if tekst ~= "..." then
				local block = guiGridListGetItemText(ani_grid_fav, selected, 1)
				local index = tonumber(guiGridListGetItemData(ani_grid_fav, selected, 1))
				local animation = guiGridListGetItemText(ani_grid_fav, selected, 2)
				
				if block and animation then
					local node = xmlFindChild(xmlFile, "animation", index-1)
					if node then
						xmlDestroyNode(node)
					end
					xmlSaveFile(xmlFile)
					ani_getfavourites()
				end
			end
		end
	end
end

function ani_getfavourites()
	if xmlFile then
		if guiGridListClear(ani_grid_fav) then
			for key, node in pairs(xmlNodeGetChildren(xmlFile)) do
				local block = xmlNodeGetAttribute(node, "block")
				local anim = xmlNodeGetAttribute(node, "animation")
				local command = xmlNodeGetAttribute(node, "command") or "N/A"
			
				local row = guiGridListAddRow(ani_grid_fav)
				guiGridListSetItemText(ani_grid_fav, row, 1, tostring(block), false, false)
				guiGridListSetItemText(ani_grid_fav, row, 2, tostring(anim), false, false)
				guiGridListSetItemData(ani_grid_fav, row, 1, tostring(key))
				guiGridListSetItemText(ani_grid_fav, row, 3, tostring(command), false, false)
			end
		end
	end
end

function ani_animation()
	if source == ani_grid then
		local tekst = guiGridListGetItemText(ani_grid, guiGridListGetSelectedItem(ani_grid), 1)
		if teskt ~= "" then
			if tekst == "..." then
				ani_aktualizuj(true)
				actual_block = nil
			else
				if guiGridListGetItemText(ani_grid, 0, 1) ~= "..." then
					actual_block = tekst
					ani_aktualizuj(false,tonumber(guiGridListGetItemData(ani_grid, guiGridListGetSelectedItem(ani_grid), 1)))
				else
					if tekst == "" then
						applyAnimation()
					else
						applyAnimation(actual_block,tekst,guiCheckBoxGetSelected(ani_loop))
					end
				end
			end
		end
	else
		local block = guiGridListGetItemText(ani_grid_fav, guiGridListGetSelectedItem(ani_grid_fav), 1)
		local anim = guiGridListGetItemText(ani_grid_fav, guiGridListGetSelectedItem(ani_grid_fav), 2)
		if teskt ~= "" then
			applyAnimation(block,anim,guiCheckBoxGetSelected(ani_loop_fav))
		end
	end
end

function ani_getall()
	for key, node in pairs(xmlToTable("animations.xml")) do
		for index, grupa in pairs(xmlToTable("animations.xml", node.index)) do
			table.insert(ani_all, { ["group"] = node.name, ["anim"] = grupa.name } )
		end
	end
end

function ani_aktualizuj(stan,index)
	if guiGridListClear(ani_grid) then
		if stan then
			for _, grupa in pairs(xmlToTable("animations.xml")) do
				local row = guiGridListAddRow(ani_grid)
				guiGridListSetItemText(ani_grid, row, 1, tostring(grupa["name"]), false, false)
				guiGridListSetItemData(ani_grid, row, 1, tostring(grupa["index"]))
				guiGridListSetItemText(ani_grid, row, 2, tostring(grupa["name"]), false, false)
			end
		else
			if index then
				local row = guiGridListAddRow(ani_grid)
				guiGridListSetItemText(ani_grid, row, 1, "...", false, false)
				
				for _, grupa in pairs(xmlToTable("animations.xml", index)) do
					local row = guiGridListAddRow(ani_grid)
					guiGridListSetItemText(ani_grid, row, 1, tostring(grupa["name"]), false, false)
					guiGridListSetItemData(ani_grid, row, 1, tostring(grupa["index"]))
				end
			end
		end
	end
end

function applyAnimation(block,ani,loop)
	for customAnimationBlockIndex, customAnimationBlock in ipairs ( IFP ) do 
		if (block == customAnimationBlock.blockName) then
			setPedAnimation ( localPlayer, tostring(block), tostring(ani), 0, loop, true, true)
			triggerServerEvent ( "onCustomAnimationSet", resourceRoot, localPlayer, tostring(block), tostring(ani), loop )
			isLocalPlayerAnimating = true
		else
			triggerServerEvent("AnimationSet", getLocalPlayer(), tostring(block), tostring(ani), loop)
		end
	end
end

function ani_init()
	if not guiGetVisible(ani_window) then
		ani_otworz()
	else
		ani_zamknij()
	end
end
addCommandHandler("animselect", ani_init)

function ani_stop()
	applyAnimation()
end
addCommandHandler("animstop", ani_stop)

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), ani_start)

function commandAnimation(command, shortcut)
	if not shortcut then
		outputChatBox("Syntax: /" .. command .. " [animation shortcut]", 255, 215, 0)
		outputChatBox("To assign animation shortcuts, use /animselect.", 255, 215, 0)
	else
		if xmlFile then
			for key, node in pairs(xmlNodeGetChildren(xmlFile)) do
				if xmlNodeGetAttribute(node, "command") and string.lower(xmlNodeGetAttribute(node, "command")) == string.lower(shortcut) then
					local block = xmlNodeGetAttribute(node, "block")
					local anim = xmlNodeGetAttribute(node, "animation")
					if isAnimation(block, anim) then
						applyAnimation(block, anim, false)
					end
				end
			end
		end
	end
end
addCommandHandler("anim", commandAnimation)

function loadCustomAnimations()
	for customAnimationBlockIndex, customAnimationBlock in ipairs ( IFP ) do 
		local ifp = engineLoadIFP ( customAnimationBlock.path, customAnimationBlock.blockName )
		if not ifp then
			outputDebugString ("Failed to load '"..customAnimationBlock.path.."'")
		end
	end
	triggerServerEvent ( "onCustomAnimationSyncRequest", resourceRoot, localPlayer )
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), loadCustomAnimations)

addEvent ("onClientCustomAnimationSyncRequest", true )
addEventHandler ("onClientCustomAnimationSyncRequest", root,
    function ( playerAnimations )
        for player, anims in pairs ( playerAnimations ) do 
            if isElement ( player ) then 
                if anims.current then 
                    setPedAnimation ( player, anims.current[1], anims.current[2] ) 
                end
                if anims.replacedPedBlock then 
                    ReplacePedBlockAnimations ( player, anims.replacedPedBlock )
                end
            end
        end 
    end 
)

addEvent ("onClientCustomAnimationSet", true )
addEventHandler ("onClientCustomAnimationSet", root,
	function ( blockName, animationName, loop )
        if source == localPlayer then return end
        if blockName == false then 
            setPedAnimation ( source, false )
            return
        end 
		setPedAnimation ( source, blockName, animationName, 0, loop, true, true )
    end 
)

addEvent ("onClientCustomAnimationReplace", true )
addEventHandler ("onClientCustomAnimationReplace", root,
    function ( ifpIndex )
        if source == localPlayer then return end
        ReplacePedBlockAnimations ( source, ifpIndex )
    end 
)

addEvent ("onClientCustomAnimationRestore", true )
addEventHandler ("onClientCustomAnimationRestore", root,
    function ( blockName )
        if source == localPlayer then return end
        engineRestoreAnimation ( source, blockName )
    end 
)

setTimer ( 
    function ()
        if isLocalPlayerAnimating then 
            if not getPedAnimation (localPlayer) then
                isLocalPlayerAnimating = false
                triggerServerEvent ( "onCustomAnimationStop", resourceRoot, localPlayer )
            end
        end
    end, 100, 0
)