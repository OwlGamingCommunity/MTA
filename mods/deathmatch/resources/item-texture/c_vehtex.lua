--Vehicle textures
--Script that handles texture replacements for vehicles
--Created by Exciter, 01.01.2015 (DD.MM.YYYY).

local vehicle = nil
local maxFileSize = 100000
local maxWidth = 1200
local maxHeight = 1200

local extraVehTexNames = {
	[596] = {"vehiclepoldecals128","vehiclepoldecals128lod"}, --police LS
	[597] = {"vehiclepoldecals128","vehiclepoldecals128lod"}, --police SF
	[598] = {"vehiclepoldecals128","vehiclepoldecals128lod"}, --police LV
	[599] = {"vehiclepoldecals128","vehiclepoldecals128lod"}, --police ranger
	[427] = {"vehiclepoldecals128","vehiclepoldecals128lod"}, --enforcer
	[497] = {"vehiclepoldecals128","vehiclepoldecals128lod"}, --police maverick
	[575] = {"remapbroadway92body128", "mapbroadway92body256a", "mapbroadway92body256b"}, -- broadway
	[576] = {"remaptornado92body128"} -- Tornado
}
local globalVehTexNames = {
	"vehiclegrunge256", --overrides shader_car_paint and dirt levels
	--"?emap*",
}

local gui = {}
function vehTex_showGui(editVehicle)
	if gui.window then
		vehTex_hideGui()
	end

	vehicle = editVehicle
	if not vehicle then
		outputDebugString("item-texture/c_vehtex: No vehicle given")
		return false
	end

	local sw, sh = guiGetScreenSize()
	local width = 600
	local height = 400
	local x = ( sw - width ) / 2
	local y = ( sh - height ) / 2

	local vehID = getElementData(vehicle, "dbid")

	local windowTitle = "Texture list for vehicle ID #"..tostring(vehID)
	gui.window = guiCreateWindow ( x, y, width, height, windowTitle, false )
	gui.list = guiCreateGridList ( 10, 25, width - 20, height - 120, false, gui.window )
	gui.remove = guiCreateButton ( 10, height - 90, width - 20, 25, "Remove selected texture", false, gui.window )
	gui.add = guiCreateButton ( 10, height - 60, width - 20, 25, "Add new texture", false, gui.window )
	gui.cancel = guiCreateButton ( 10, height - 30, width - 20, 25, "Cancel", false, gui.window )

	guiGridListAddColumn ( gui.list, "Texture", 0.2 )
	guiGridListAddColumn ( gui.list, "URL", 0.8 )

	guiWindowSetSizable ( gui.window, false )
	guiSetEnabled ( gui.remove, false )
	showCursor ( true )

	local currentTextures = getElementData(vehicle, "textures")
	for k,v in ipairs(currentTextures) do
		local row = guiGridListAddRow ( gui.list )
		guiGridListSetItemText ( gui.list, row, 1, v[1], false, false )
		guiGridListSetItemText ( gui.list, row, 2, v[2], false, false )
	end

	addEventHandler ( "onClientGUIClick", gui.window, vehTex_WindowClick )
	addEventHandler("onClientGUIDoubleClick", gui.window, vehTex_copyToClipboard)
end
addEvent("item-texture:vehtex")
addEventHandler("item-texture:vehtex", getRootElement(), vehTex_showGui)

function vehTex_WindowClick ( button, state )
	if button == "left" and state == "up" then
		if source == gui.cancel then
			vehTex_hideGui ( )
		elseif source == gui.list then
			local texID = guiGridListGetItemText ( gui.list, guiGridListGetSelectedItem ( gui.list ), 1 )

			if texID ~= "" then
				guiSetEnabled ( gui.remove, true )
			else
				guiSetEnabled ( gui.remove, false )
			end
		elseif source == gui.add then
			vehTex_addGui()
		elseif source == gui.remove then
			local row, column = guiGridListGetSelectedItem(gui.list)
			local texname = guiGridListGetItemText ( gui.list, row, 1 )
			if texname ~= "" then
				guiGridListRemoveRow(gui.list, row)
				triggerServerEvent("vehtex:removeTexture", getLocalPlayer(), vehicle, texname)
			end
		end
	end
end

function vehTex_copyToClipboard()
    if source == gui.list then
        local url = guiGridListGetItemText ( gui.list, guiGridListGetSelectedItem ( gui.list ), 2 )
        if url then
            outputChatBox("URL copied to clipboard.")
            setClipboard(url)
        end
    end
end

function vehTex_hideGui()
	if gui.window then
		if gui.window2 then
			destroyElement ( gui.window2 )
			gui.window2 = nil
			guiSetInputEnabled(false)
		end
		if gui.window3 then
			destroyElement ( gui.window3 )
			gui.window3 = nil
		end
		destroyElement ( gui.window )
		gui.window = nil
		vehicle = nil

		showCursor ( false )
	end
end

function vehTex_addGui()
	if gui.window2 then
		vehTex_addGui_hide()
	end

	gui.window2 = guiCreateWindow(634, 416, 456, 166, "Add New Vehicle Texture", false)
	guiWindowSetSizable(gui.window2, false)

	gui.addLabel1 = guiCreateLabel(31, 63, 30, 17, "URL:", false, gui.window2)
	gui.addUrl = guiCreateEdit(71, 59, 374, 25, "", false, gui.window2)
	gui.addLabel2 = guiCreateLabel(10, 27, 51, 18, "Texture:", false, gui.window2)
	gui.addCombo = guiCreateComboBox(69, 24, 199, 79, "", false, gui.window2)
	gui.addCancel = guiCreateButton(16, 109, 199, 43, "Cancel", false, gui.window2)
	gui.addApply = guiCreateButton(230, 109, 214, 43, "Apply", false, gui.window2)

	addEventHandler ( "onClientGUIClick", gui.addCancel, vehTex_addGui_hide, false )
	addEventHandler ( "onClientGUIClick", gui.addApply, vehTex_addGui_apply, false )

	guiSetInputEnabled(true)

	local alreadyAdded = {}
	local currentTextures = getElementData(vehicle, "textures")
	for k,v in ipairs(currentTextures) do
		alreadyAdded[v[1]] = true
	end
	local model = getElementModel(vehicle)
	local texnames = engineGetModelTextureNames(tostring(model))
	if extraVehTexNames[model] then
		for k,v in ipairs(extraVehTexNames[model]) do
			table.insert(texnames, v)
		end
	end
	if globalVehTexNames then
		for k,v in ipairs(globalVehTexNames) do
			table.insert(texnames, v)
		end
	end
	for k,v in ipairs(texnames) do
		if not alreadyAdded[tostring(v)] then
			guiComboBoxAddItem(gui.addCombo, tostring(v))
		end
	end
end

function vehTex_addGui_hide()
	if gui.window2 then
		destroyElement ( gui.window2 )
		gui.window2 = nil
		guiSetInputEnabled(false)
		if gui.window3 then
			destroyElement ( gui.window3 )
			gui.window3 = nil
		end
	end
end
function vehTex_error(msg)
	if gui.window3 then
		vehTex_error_hide()
	end
	
	local sw, sh = guiGetScreenSize()
	local width = 400
	local height = 150
	local x = ( sw - width ) / 2
	local y = ( sh - height ) / 2

	gui.window3 = guiCreateWindow(x, y, width, height, "Error", false)
	guiWindowSetSizable(gui.window3, false)

	gui.errorLabel = guiCreateLabel(10, 20, width-20, height-40, tostring(msg), false, gui.window3)
		guiLabelSetHorizontalAlign(gui.errorLabel, "center", true)
		guiLabelSetVerticalAlign(gui.errorLabel, "center")
	gui.errorBtn = guiCreateButton(10, height-35, width-20, 30, "OK", false, gui.window3)
	addEventHandler ( "onClientGUIClick", gui.errorBtn, vehTex_error_hide, false )
end
function vehTex_error_hide()
	if gui.window3 then
		destroyElement ( gui.window3 )
		gui.window3 = nil
	end
	if gui.addApply then
		guiSetEnabled(gui.addApply, true)
		guiSetText(gui.addApply, "Apply")
	end
end
function vehTex_addGui_apply()
	guiSetEnabled(gui.addApply, false)
	guiSetText(gui.addApply, "Please wait...")
	local texurl = guiGetText(gui.addUrl)
	local texname = tostring(guiComboBoxGetItemText(gui.addCombo, guiComboBoxGetSelected(gui.addCombo)))
	if (not texname or texname == "" or texname == " ") then
		vehTex_error("You did not select what texture you want to replace.")
		return false
	end

	local valid, err = isURLValid(texurl)
	if not valid then
		vehTex_error(err)
		return false
	end

	--validate file
	local path = getPath(texurl)
	if fileExists(path) then --file already exists, so we dont need to validate
		outputDebugString("item-texture/c_vehtex: Skip validation")
		vehTex_apply(texname, texurl)
	else
		--we need to download :(
		triggerServerEvent("vehtex:validateFile", resourceRoot, vehicle, texname, texurl)
		guiSetText(gui.addApply, "Please wait. Downloading...")
	end
end
function vehTex_fileValidationResult(editVehicle, texname, texurl, approved, msg)
	if not editVehicle or not vehicle then return false end
	if editVehicle ~= vehicle then return false end
	if approved then
		vehTex_apply(texname, texurl)
		return true
	else
		vehTex_error("File validation failed! \n"..tostring(msg))
		return false
	end
end
addEvent("vehtex:fileValidationResult", true)
addEventHandler("vehtex:fileValidationResult", resourceRoot, vehTex_fileValidationResult) 

function vehTex_apply(texname, texurl)
	local row = guiGridListAddRow ( gui.list )
	guiGridListSetItemText ( gui.list, row, 1, texname, false, false )
	guiGridListSetItemText ( gui.list, row, 2, texurl, false, false )
	triggerServerEvent("vehtex:addTexture", getLocalPlayer(), vehicle, texname, texurl)
	vehTex_addGui_hide()
end
local extensions = {
	[".jpg"] = true,
	[".png"] = true,
}
function isURLValid ( url )
	local url = url:lower()

	if not isURL( url ) then
		return false, "Invalid URL!"
	end

	if not isHostAllowed(url) then
		return false, "Image must be hosted on imgur.com."
	end

	local _extensions = ""

	for extension, _ in pairs ( extensions ) do
		if _extensions ~= "" then
			_extensions = _extensions .. ", " .. extension
		else
			_extensions = extension
		end

		if string.find ( url, extension, 1, true ) then
			return true
		end
	end

	return false, "Only *.jpg and *.png files are allowed."
end

local decals = {
	"vehiclepoldecals128", --police decals
	"newsvan92decal128", --news van logo
	"sanmav92blue64", --news helicopter logo
	"sanmav92blue64b", --news helicopter tailnumber
	"sweeper92decal128", --sweeper logo
	"polmav92sadecal64", --police maverick logo
	"polmav92decal64b", --police maverick tailnumber
	"trash92decal128", --logo for trashmaster and utility truck
	"cement92logo", --cement truck logo
	"dozer92logo128", --bulldozer logo
	"bus92decals128", --bus logo
	"coach92decals128", --coach logo
	"dodo92decal128b", --dodo tailnumber
	"lsfd92badge64", --fire truck logo
	"firetruk92num64", --fire truck number
	"firetruk92decal", --fire truck markings
	"ambulan92decal128", --ambulance markings
	"copbike92decalSA64", -- Police bike back markings
}
function blankDecals()
	decalTex = dxCreateTexture("trans.png")
	decalShad = dxCreateShader("shaders/decal.fx")
	dxSetShaderValue(decalShad, "decal", decalTex)
	for k, v in ipairs(decals) do
		engineApplyShaderToWorldTexture(decalShad, v)
	end
end

-- Preview Mode
function vehTex_prevGui(editVehicle)
	if gui.window4 then
		vehTex_prevGui_hide()
	end
	gui.window4 = guiCreateWindow(634, 416, 456, 166, "Add New Vehicle Texture", false)
	guiWindowSetSizable(gui.window4, false)

	gui.prevLabel1 = guiCreateLabel(31, 63, 30, 17, "URL:", false, gui.window4)
	gui.prevUrl = guiCreateEdit(71, 59, 374, 25, "", false, gui.window4)
	gui.prevLabel2 = guiCreateLabel(10, 27, 51, 18, "Texture:", false, gui.window4)
	gui.prevCombo = guiCreateComboBox(69, 24, 199, 79, "", false, gui.window4)
	gui.prevCancel = guiCreateButton(16, 109, 199, 43, "Cancel", false, gui.window4)
	gui.prevApply = guiCreateButton(230, 109, 214, 43, "Apply", false, gui.window4)

	addEventHandler ( "onClientGUIClick", gui.prevCancel, vehTex_prevGui_hide, false )
	addEventHandler ( "onClientGUIClick", gui.prevApply, vehTex_prevGui_apply, false )

	guiSetInputEnabled(true)

	vehicle = editVehicle
	local alreadyAdded = {}
	local currentTextures = getElementData(vehicle, "textures")
	for k,v in ipairs(currentTextures) do
		alreadyAdded[v[1]] = true
	end
	local model = getElementModel(vehicle)
	local texnames = engineGetModelTextureNames(tostring(model))
	if extraVehTexNames[model] then
		for k,v in ipairs(extraVehTexNames[model]) do
			table.insert(texnames, v)
		end
	end
	if globalVehTexNames then
		for k,v in ipairs(globalVehTexNames) do
			table.insert(texnames, v)
		end
	end
	for k,v in ipairs(texnames) do
		if not alreadyAdded[tostring(v)] then
			guiComboBoxAddItem(gui.prevCombo, tostring(v))
		end
	end
end
addEvent("item-texture:previewVehTex")
addEventHandler("item-texture:previewVehTex", getRootElement(), vehTex_prevGui)

function vehTex_prevGui_hide()
	if gui.window4 then
		destroyElement ( gui.window4 )
		gui.window4 = nil
		guiSetInputEnabled(false)
		if gui.window3 then
			destroyElement ( gui.window3 )
			gui.window3 = nil
		end
	end
end

function vehTex_prevGui_apply()
	guiSetEnabled(gui.prevApply, false)
	guiSetText(gui.prevApply, "Please wait...")
	local texurl = guiGetText(gui.prevUrl)
	local texname = tostring(guiComboBoxGetItemText(gui.prevCombo, guiComboBoxGetSelected(gui.prevCombo)))
	if isTimer(previewTimer) then
		vehTex_error("You can only preview one texture at a time.")
		return
	end	
	if (not texname or texname == "" or texname == " ") then
		vehTex_error("You did not select what texture you want to replace.")
		return false
	end

	local valid, err = isURLValid(texurl)
	if not valid then
		vehTex_error(err)
		return false
	end
	
	--validate file
	local path = getPath(texurl)
	if fileExists(path) then --file already exists, so we dont need to validate
		outputDebugString("item-texture/c_vehtex: Skip validation")
		addTexture(vehicle, texname, texurl, true)
		vehTex_prevGui_hide()
	else
		--we need to download :(
		triggerServerEvent("vehtex:prepareValidation", resourceRoot, vehicle, texname, texurl)
		guiSetText(gui.prevApply, "Please wait. Downloading...")
	end
end

function previewValidationResult(editVehicle, texname, texurl, approved, msg, str)
	if not editVehicle or not vehicle then return false end
	if editVehicle ~= vehicle then return false end
	if approved then			
		addTexture(editVehicle, texname, texurl, true) 
		vehTex_prevGui_hide()
		return true
	else
		vehTex_error("File validation failed! \n"..tostring(msg))
		return false
	end
end
addEvent("vehtex:previewValidationResult", true)
addEventHandler("vehtex:previewValidationResult", resourceRoot, previewValidationResult)

function validateVehicleTexture(theVehicle, texName, url, host, apiKey)
	if host == "imgur.com" then
		if isBrowserDomainBlocked("api.imgur.com") or isBrowserDomainBlocked("i.imgur.com") or isBrowserDomainBlocked("imgur.com") then
			requestBrowserDomains({"imgur.com", "api.imgur.com", "i.imgur.com"})
			return
		end	
		local apiURL = string.match(url:match("^.*%/(.*)"), "(%w+)%.") --> I'm not too great with regex
		local apiURL = "https://api.imgur.com/3/image/" .. apiURL
		local options = {
			queueName = "textures",
			connectionAttempts = 5,
			headers = {Authorization = "Client-ID " .. apiKey}
		}

		fetchRemote(apiURL, options, function(data, errno, theVehicle, url)
				if not errno.success then
					--outputDebugString('item-texture/s_vehtex: loadFromURL - unable to fetch ' .. tostring(url))
					local text = "The API could not be reached. (ERROR #"..tostring(errno.statusCode)..")"
					previewValidationResult(theVehicle, texName, url, false, text)
					removeVehicleTexture(theVehicle, texName)
				else
					local table = fromJSON(data)
					if table and table.success == true and table.data then
						local width, height, size = table.data.width, table.data.height, table.data.size
						if size > maxFileSize then
							local text = "The filesize exceeds the maximum allowed filesize for vehicle textures ("..tostring(math.floor(maxFileSize/1000)).."kb)."
							previewValidationResult(theVehicle, texName, url, false, text)
						elseif width > maxWidth or height > maxHeight then
							local text = "The width or height exceeds the maximum allowed width or height for vehicle textures (".. maxWidth ..", " .. maxHeight .. ")."
							previewValidationResult(theVehicle, texName, url, false, text)
						else
							local options = {
								queueName = "textures",
								connectionAttempts = 5,
								postIsBinary = true
							}
							fetchRemote(url, options, function(str, errno, theVehicle, url)
									if not errno.success then
										local text = "The URL could not be reached. Please check that you entered the correct URL and that the URL is reachable. (ERROR #"..tostring(errno.statusCode)..")"
										previewValidationResult(theVehicle, texName, url, false, text)
									else
										local path = getPath( tostring(url) )
										local file = fileCreate(path)
										fileWrite(file, str)
										fileClose(file)
										previewValidationResult(theVehicle, texName, url, true)
									end
								end, {theVehicle, url})
						end
					else
						local text = "Something went wrong with the API.. (".. ((table and table.data and table.data.error) or "N/A") .. ")"
						previewValidationResult(theVehicle, texName, url, false, text)
					end
				end
			end,
		{theVehicle, url})
	elseif host == "icweb.org" then
		if isBrowserDomainBlocked("icweb.org") then
			requestBrowserDomains({"icweb.org"})
			return
		end	
		local apiURL = "http://icweb.org/imageapi.php"
		local apiKey = apiKey or "owlhowl"
		local options = {
			queueName = "textures",
			connectionAttempts = 5,
			formFields = { AuthKey = tostring(apiKey), url=url }
		}

		fetchRemote(apiURL, options, function(data, errno, client, theVehicle, url)
				if not errno.success then
					local text = "The API could not be reached. (ERROR #"..tostring(errno.statusCode)..")"
					previewValidationResult(theVehicle, texName, url, false, text)
					removeTexture(theVehicle, texName)
				else
					local table = fromJSON(data)
					outputDebugString("table.success="..tostring(table.success))
					if table and table.success == true and table.data then
						local width, height, size = table.data.width, table.data.height, table.data.size

						if size > maxFileSize then
							local text = "The filesize exceeds the maximum allowed filesize for vehicle textures ("..tostring(math.floor(maxFileSize/1000)).."kb)."
							previewValidationResult(ctheVehicle, texName, url, false, text)
						elseif width > maxWidth or height > maxHeight then
							local text = "The width or height exceeds the maximum allowed width or height for vehicle textures (".. maxWidth ..", " .. maxHeight .. ")."
							previewValidationResult(theVehicle, texName, url, false, text)
						else
							local options = {
								queueName = "textures",
								connectionAttempts = 5,
								postIsBinary = true
							}

							fetchRemote(url, options, function(str, errno, client, theVehicle, url)
									if not errno.success then
										local text = "The URL could not be reached. Please check that you entered the correct URL and that the URL is reachable. (ERROR #"..tostring(errno.statusCode)..")"
										previewValidationResult(theVehicle, texName, url, false, text)
									else
										local path = getPath( tostring(url) )
										local file = fileCreate(path)
										fileWrite(file, str)
										fileClose(file)
										previewValidationResult(theVehicle, texName, url, true)
									end
								end, {client, theVehicle, url})
						end
					else
						local text = "Something went wrong with the API (".. ((table and table.error) or "N/A") .. ")"
						previewValidationResult(theVehicle, texName, url, false, text)
					end
				end
			end,
		{client, theVehicle, url})		
	else
		local text = "Invalid host."
		previewValidationResult(theVehicle, texName, url, false, text)
	end
end
addEvent("vehtex:validatePreviewFile", true)
addEventHandler("vehtex:validatePreviewFile", resourceRoot, validateVehicleTexture)

addEventHandler("onClientBrowserWhitelistChange", root,
   function(newDomains)
     if newDomains[1] == "i.imgur.com" or newDomains[1] == "imgur.com" or newDomains[1] == "api.imgur.com" or newDomains[1] == "icweb.org" then
       vehTex_error("Host has been whitelisted, re-apply the texture.")
   end
end
) 
