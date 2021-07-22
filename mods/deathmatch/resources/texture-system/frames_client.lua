addEvent ( "frames:showFrameGUI", true )
addEvent ( "frames:showTextureSelection", true )
addEvent ( "frames:loadClientInteriorTexture", true )

local frameGUI = { }
local shaders = { }
worldShaders = { }
local rendering = false
local selectedID = 1
local frameURL = ""
local sw, sh = guiGetScreenSize ( )
local visibleTextures = { }
local extensions = {
	[".jpg"] = true,
	[".png"] = true,
}
local invalidModels = {
	--["fridge_1b"] = false,
	["radardisc"] = true,
	["shad_ped"] = true,
	["radar_north"] = true,
	["radar_centre"] = true,
	["shad_exp"] = true,
	["coronastar"] = true,
	["cloudmasked"] = true,
}

local KEYS =
{
	PREVIOUS = 'a',
	CONFIRM = 's',
	NEXT = 'd',
	CANCEL = 'w'
}

-- fetch updated list for this interior
addEventHandler ( "onClientResourceStart", resourceRoot,
	function()
		triggerServerEvent("frames:loadInteriorTextures", resourceRoot, getElementDimension(localPlayer))
	end)

function frames_showFrameGUI ( itemSlot )
	if not frameGUI["window"] then
		local width = 400
		local height = 119
		local x = ( sw - width ) / 2
		local y = ( sh - height ) / 2

		slot = itemSlot

		frameGUI["window"] = guiCreateWindow ( x, y, width, height, "Update picture frame URL", false )
		frameGUI["url"] = guiCreateEdit ( 10, 25, 379, 25, "http://www.example.com/picture.png", false, frameGUI["window"] )
		frameGUI["save"] = guiCreateButton ( 10, 55, 379, 25, "Save URL", false, frameGUI["window"] )
		frameGUI["cancel"] = guiCreateButton ( 10, 85, 379, 25, "Cancel", false, frameGUI["window"] )

		guiWindowSetSizable ( frameGUI["window"], false )
		guiSetInputEnabled ( true )

		addEventHandler ( "onClientGUIClick", frameGUI["window"], frames_buttonClick )
	else
		frames_hideFrameGUI ( )
	end
end

function frames_buttonClick ( button, state )
	if button == "left" and state == "up" then
		if source == frameGUI["save"] then
			local url = guiGetText ( frameGUI["url"] )
			local valid, error = isURLValid ( url )

			if valid then
				triggerServerEvent ( "item-system:saveTextureURL", localPlayer, slot, url )
				frames_hideFrameGUI ( )
			else
				outputChatBox ( error, 255, 0, 0, false )
			end
		elseif source == frameGUI["url"] then
			local url = guiGetText ( source )

			if url == "http://www.example.com/picture.png" then
				guiSetText ( source, "" )
			end
		elseif source == frameGUI["cancel"] then
			frames_hideFrameGUI ( )
		end
	end
end

function frames_hideFrameGUI ( )
	if frameGUI["window"] then
		destroyElement ( frameGUI["window"] )
		frameGUI["window"] = nil
		guiSetInputEnabled ( false )
	end
end

function isURLValid ( url )
	local url = url:lower()
	local _extensions = ""

	if url:find("cef+http://", 1, true) or url:find("cef+https://", 1, true) then
		return true
	else
		if string.find(url, "http://", 1, true) or string.find(url, "https://", 1, true) then
			local domain = url:match("[%w%.]*%.(%w+%.%w+)")
			if domain ~= "imgur.com" then
				return false, "Image must be from imgur"
			end
		else
			return false, "Invalid URL"
		end
	end

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

	return false, "Invalid image extension. Accepted types are: " .. _extensions
end

function frames_showTextureSelection ( slot, textureURL, imgData )
	local integration = exports.integration
	local global = exports.global
	local dimension = getElementDimension ( localPlayer )
	local interior = getElementInterior( localPlayer )

	if (dimension > 0 and interior > 0) or (integration:isPlayerHeadAdmin(localPlayer) and global:isAdminOnDuty(localPlayer)) or (integration:isPlayerScripter(localPlayer) and global:isStaffOnDuty(localPlayer)) then
		if (dimension < 20000 and exports.global:hasItem(localPlayer, 4, dimension)) or (dimension < 20000 and exports.global:hasItem(localPlayer, 5, dimension)) or (dimension > 20000 and exports.global:hasItem(localPlayer, 3, dimension-20000)) or (exports.integration:isPlayerAdmin(localPlayer) and exports.global:isAdminOnDuty(localPlayer)) or (exports.integration:isPlayerScripter(localPlayer) and exports.global:isStaffOnDuty(localPlayer)) or (dimension == 0) or (interior == 0) then
			rendering = not rendering

			if rendering then
				visibleTextures = { }

				-- currently replaced?
				local thisInterior = savedTextures[getElementDimension(localPlayer)] or {}
				local tmpBlocked = {}
				for k, v in pairs(thisInterior) do
					tmpBlocked[v.texture] = true
				end

				for _, name in ipairs ( engineGetVisibleTextureNames ( ) ) do
					if not invalidModels[name] and not tmpBlocked[name] then
						table.insert ( visibleTextures, name )
					end
				end

				if textureURL:sub(1, 4) == "cef+" then
					texture = dxCreateTexture ( "browser_placeholder.jpg", "argb", true, "clamp", "2d", 1 )
				else
					texture = dxCreateTexture ( imgData, "argb", true, "clamp", "2d", 1 )

					-- Resolution check
					if texture then
						local width, height = dxGetMaterialSize ( texture )

						if width > 1024 or height > 1024 then
							outputChatBox ( "Texture cannot have a width and height greater than 1024px.", 255, 0, 0, false )
							return
						end
					end
				end

				shaders[localPlayer] = dxCreateShader ( "shaders/replacement.fx", 1, 100, true, "world,object" )

				if shaders[localPlayer] then
					dxSetShaderValue ( shaders[localPlayer], "Tex0", texture )
					engineApplyShaderToWorldTexture ( shaders[localPlayer], visibleTextures[selectedID], nil, true )

					for _, v in pairs(KEYS) do
						bindKey ( v, "down", frames_keySwitch, slot, textureURL )
					end
					setElementFrozen(localPlayer, true)
					playSoundFrontEnd(5)
					addEventHandler ( "onClientRender", root, frames_renderTextureSelection )
				end
			else
				frames_hidePreview ( )
			end
		else
			outputChatBox ( "You do not own this interior.", 255, 0, 0, false )
		end
	elseif dimension <= 0 then
		outputChatBox ( "You are not inside an interior.", 255, 0, 0, false )
	end
end

function frames_keySwitch ( key, state, slot, textureURL )
	if key == KEYS.PREVIOUS then -- Previous
		engineRemoveShaderFromWorldTexture ( shaders[localPlayer], visibleTextures[selectedID] )
		playSoundFrontEnd(2)
		if selectedID > 1 then
			selectedID = selectedID - 1
		else
			selectedID = #visibleTextures
		end
	elseif key == KEYS.NEXT then -- Next
		engineRemoveShaderFromWorldTexture ( shaders[localPlayer], visibleTextures[selectedID] )
		playSoundFrontEnd(2)
		if selectedID < #visibleTextures then
			selectedID = selectedID + 1
		else
			selectedID = 1
		end
	elseif key == KEYS.CONFIRM then -- Enter
		playSoundFrontEnd(6)
		-- Reset the URL (Remove old texture from URL)
		local min, max = string.find ( textureURL, ";", 1, true )

		if min then
			textureURL = string.sub ( textureURL, 1, min - 1 )
		end

		triggerServerEvent ( "item-system:saveTextureURL", localPlayer, slot, textureURL .. ";" .. visibleTextures[selectedID] )
		frames_hidePreview ( )
	elseif key == KEYS.CANCEL then
		frames_hidePreview ( )
	end
end

function frames_renderTextureSelection ( )
	dxDrawText ( selectedID .. "/" .. #visibleTextures .. ": " .. visibleTextures[selectedID], sw * 0.02, sh * 0.6, sw, sh, tocolor ( 255, 255, 255, 255 ), 1.0, "default-bold" )
	dxDrawText ( "Next: " .. KEYS.NEXT, sw * 0.02, sh * 0.63, sw, sh, tocolor ( 255, 255, 255, 255 ), 1.0, "default-bold" )
	dxDrawText ( "Previous: " .. KEYS.PREVIOUS, sw * 0.02, sh * 0.65, sw, sh, tocolor ( 255, 255, 255, 255 ), 1.0, "default-bold" )
	dxDrawText ( "Confirm: " .. KEYS.CONFIRM, sw * 0.02, sh * 0.67, sw, sh, tocolor ( 255, 255, 255, 255 ), 1.0, "default-bold" )
	dxDrawText ( "Cancel: " .. KEYS.CANCEL, sw * 0.02, sh * 0.69, sw, sh, tocolor ( 255, 255, 255, 255 ), 1.0, "default-bold" )

	if isElement ( texture ) then
		engineApplyShaderToWorldTexture ( shaders[localPlayer], visibleTextures[selectedID], nil, true )
	end
end

function frames_hidePreview ( )
	rendering = false

	for _, v in pairs(KEYS) do
		unbindKey ( v, "down", frames_keySwitch )
	end
	setElementFrozen(localPlayer, false)

	engineRemoveShaderFromWorldTexture ( shaders[localPlayer], visibleTextures[selectedID] )

	selectedID = 1

	if isElement ( texture ) then
		destroyElement ( texture )
	end

	removeEventHandler ( "onClientRender", root, frames_renderTextureSelection )
end

function frames_loadClientInteriorTexture ( imgData, textureName, interior )
	if not worldShaders[interior] then
		worldShaders[interior] = {
			textures = {
				{
					name = textureName,
					texture = dxCreateTexture ( imgData, "argb", true, "clamp", "2d", 1 ),
					shader = dxCreateShader ( "shaders/replacement.fx", 1, 100, true, "world,object" ),
				},
			},
		}
	else
		table.insert ( worldShaders[interior].textures,
			{
				name = textureName,
				texture = dxCreateTexture ( imgData, "argb", true, "clamp", "2d", 1 ),
				shader = dxCreateShader ( "shaders/replacement.fx", 1, 100, true, "world,object" ),
			}
		)
	end

	for i,v in ipairs ( worldShaders[interior].textures ) do
		local width, height = dxGetMaterialSize ( v.texture )

		if width > 1000 or height > 1000 then
			if exports.global:hasItem ( localPlayer, 4, interior ) or exports.global:hasItem ( localPlayer, 5, interior ) then
				outputChatBox ( "Not loading " .. v.name .. " as the width or height is greater than 1000px, please remove it with /texlist.", 255, 0, 0, false )
			end

			return
		end

		dxSetShaderValue ( v.shader, "Tex0", v.texture )
		engineApplyShaderToWorldTexture ( v.shader, v.name, nil, true )
	end
end

function frames_removeClientInteriorTextures ( client, interior, dimension )
	if localPlayer ~= client or not worldShaders[dimension] then return end

	for i, _ in pairs ( worldShaders ) do
		local textures = worldShaders[i].textures
		if not textures then return end
		for texIndex,v in ipairs ( textures ) do
			engineRemoveShaderFromWorldTexture ( v.shader, v.name )
			if isElement ( v.texture ) then
				destroyElement ( v.texture )
			end
			if isElement ( v.shader ) then
				destroyElement ( v.shader )
			end
			worldShaders[i].textures[texIndex] = nil
		end
	end
end
addEventHandler("onClientInteriorChange", root, frames_removeClientInteriorTextures)

coronastar = dxCreateShader ( "shaders/replacement.fx" )

if isElement ( coronastar ) then
	engineApplyShaderToWorldTexture ( coronastar, "coronastar" )
	local coronastartex = dxCreateTexture ( "files/coronastar.jpg" )

	if coronastartex then
		dxSetShaderValue ( coronastar, "Tex0", coronastartex )
	end
end

addEventHandler ( "frames:showFrameGUI", root, frames_showFrameGUI )
addEventHandler ( "frames:showTextureSelection", root, frames_showTextureSelection )
addEventHandler ( "frames:loadClientInteriorTexture", root, frames_loadClientInteriorTexture )
