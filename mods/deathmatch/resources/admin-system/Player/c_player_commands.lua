function nudgeNoise(message, type)
   local sound = playSound("Player/nudge.wav")
   setSoundVolume(sound, 0.5) -- set the sound volume to 50%
   setWindowFlashing(true)

   if message then
	   createTrayNotification(message, type)
   end
end
addEvent("playNudgeSound", true)
addEventHandler("playNudgeSound", getLocalPlayer(), nudgeNoise)
addCommandHandler("playthenoise", nudgeNoise)

function doEarthquake(intensity)
	local x, y, z = getElementPosition(getLocalPlayer())
	createExplosion(x, y, z, -1, false, tonumber(intensity), false)
end
addEvent("doEarthquake", true)
addEventHandler("doEarthquake", getLocalPlayer(), doEarthquake)

function streamASound(link)
	playSound(link)
end
addEvent("playSound", true)
addEventHandler("playSound", getRootElement(), streamASound)

function develop(enable)
	if exports.integration:isPlayerLeadScripter(localPlayer) or 
		exports.integration:isPlayerHeadAdmin(localPlayer) then
		if enable then
			setDevelopmentMode( true )
			outputChatBox("Development Mode Enabled. /showcol, /showsound, /debugscript", 0, 255, 0)
		else
			setDevelopmentMode( false )
			outputChatBox("Development Mode Disabled.", 255, 0, 0)
		end
	end
end
addEvent("admin-system:devmode", true)
addEventHandler("admin-system:devmode", root, develop)

function seeFar(localPlayer, value)
	if not value then outputChatBox("SYNTAX: /seefar [value or -1 to reset it]") end
	if value and tonumber(value) >= 250 and tonumber(value) <= 20000 then
		setFarClipDistance(value)
		outputChatBox("Clip distance set to "..value..".")
	elseif value and tonumber(value) == -1 then
		resetFarClipDistance()
	else
		outputChatBox("Maximum value for render distance is 20000 and minimum is 250.")
	end
end
addCommandHandler("seefar", seeFar)

--CARGO GROUP
local cargoSpawner = {
	button = {},
	window = {},
	edit = {},
	label = {},
	radiobutton = {},
	tabpanel = {},
	tab = {},
	memo = {}
}

local pendingItemCreationData
local pendingURLApproval = {}

function genericAbortWaitForTexture()
	pendingURLApproval = {}
	pendingItemCreationData = nil
end

function buildCargoGUI(admin)
	if not admin then admin = false end
	
	genericAbortWaitForTexture()
	genericAlertClose()

	if cargoSpawner.window[1] and isElement(cargoSpawner.window[1]) then	
		destroyElement(cargoSpawner.window[1])
		guiSetInputEnabled(false)
	end
	
	guiSetInputEnabled(true)
	
	cargoSpawner.window[1] = guiCreateWindow(938, 354, 471, 389, "Generic Items", false)
	guiWindowSetSizable(cargoSpawner.window[1], false)
	exports.global:centerWindow(cargoSpawner.window[1])

	cargoSpawner.button[1] = guiCreateButton(339, 350, 122, 29, "Close", false, cargoSpawner.window[1])
	cargoSpawner.button[3] = guiCreateButton(10, 350, 122, 29, "Reset", false, cargoSpawner.window[1])

	cargoSpawner.tabpanel[1] = guiCreateTabPanel(10, 30, 451, 310, false, cargoSpawner.window[1])

	cargoSpawner.tab[1] = guiCreateTab("Generic (GUI)", cargoSpawner.tabpanel[1])
	cargoSpawner.tab[2] = guiCreateTab("Generic (Code)", cargoSpawner.tabpanel[1])
	cargoSpawner.tab[3] = guiCreateTab("Consumables", cargoSpawner.tabpanel[1])

	--TAB 1: Generic from GUI
	cargoSpawner.label[1] = guiCreateLabel(20, 29, 143, 17, "Price per unit", false, cargoSpawner.tab[1])
	cargoSpawner.label[2] = guiCreateLabel(243, 29, 120, 17, "Quantity (max. 30)", false, cargoSpawner.tab[1])
	cargoSpawner.edit[1] = guiCreateEdit(10, 51, 208, 27, "", false, cargoSpawner.tab[1])
	cargoSpawner.button[2] = guiCreateButton(10, 246, 431, 29, "Create", false, cargoSpawner.tab[1])
	cargoSpawner.edit[2] = guiCreateEdit(233, 51, 208, 27, "1", false, cargoSpawner.tab[1])
	cargoSpawner.edit[3] = guiCreateEdit(10, 126, 208, 27, "", false, cargoSpawner.tab[1])
	cargoSpawner.label[3] = guiCreateLabel(20, 105, 143, 17, "Item name", false, cargoSpawner.tab[1])
	cargoSpawner.label[4] = guiCreateLabel(243, 105, 143, 17, "Item model", false, cargoSpawner.tab[1])
	cargoSpawner.edit[4] = guiCreateEdit(233, 126, 208, 27, "1271", false, cargoSpawner.tab[1])
		
	cargoSpawner.label[5] = guiCreateLabel(131, 180, 143, 17, "Item scale", false, cargoSpawner.tab[1])
	cargoSpawner.edit[5] = guiCreateEdit(121, 201, 208, 27, "1", false, cargoSpawner.tab[1])

	--TAB 2: Generic from code
	cargoSpawner.label[201] = guiCreateLabel(20, 29, 143, 17, "Price per unit", false, cargoSpawner.tab[2])
	cargoSpawner.edit[201] = guiCreateEdit(10, 51, 208, 27, "", false, cargoSpawner.tab[2])

	cargoSpawner.label[202] = guiCreateLabel(243, 29, 120, 17, "Quantity (max. 30)", false, cargoSpawner.tab[2])
	cargoSpawner.edit[202] = guiCreateEdit(233, 51, 208, 27, "1", false, cargoSpawner.tab[2])

	cargoSpawner.label[203] = guiCreateLabel(20, 105, 143, 17, "Paste item code", false, cargoSpawner.tab[2])
	
	cargoSpawner.memo[201] = guiCreateMemo(10, 126, 431, 87, "", false, cargoSpawner.tab[2])

	cargoSpawner.button[201] = guiCreateButton(10, 246, 431, 29, "Create", false, cargoSpawner.tab[2])

	--TAB 3: Consumables
	cargoSpawner.label[301] = guiCreateLabel(20, 29, 143, 17, "Price per unit", false, cargoSpawner.tab[3])
	cargoSpawner.edit[301] = guiCreateEdit(10, 51, 208, 27, "", false, cargoSpawner.tab[3])

	cargoSpawner.label[302] = guiCreateLabel(243, 29, 120, 17, "Quantity (max. 30)", false, cargoSpawner.tab[3])
	cargoSpawner.edit[302] = guiCreateEdit(233, 51, 208, 27, "1", false, cargoSpawner.tab[3])

	cargoSpawner.label[303] = guiCreateLabel(20, 105, 143, 17, "Item name", false, cargoSpawner.tab[3])
	cargoSpawner.edit[303] = guiCreateEdit(10, 126, 208, 27, "", false, cargoSpawner.tab[3])

	cargoSpawner.label[304] = guiCreateLabel(243, 105, 143, 17, "Item model", false, cargoSpawner.tab[3])	
	cargoSpawner.edit[304] = guiCreateEdit(233, 126, 208, 27, "", false, cargoSpawner.tab[3])

	cargoSpawner.label[305] = guiCreateLabel(20, 180, 143, 17, "Item scale", false, cargoSpawner.tab[3])
	cargoSpawner.edit[305] = guiCreateEdit(10, 201, 208, 27, "1", false, cargoSpawner.tab[3])
	guiSetEnabled(cargoSpawner.edit[305], false)
	
	cargoSpawner.radiobutton[301] = guiCreateRadioButton(231, 200, 136, 15, "Generic Food", false, cargoSpawner.tab[3])
	cargoSpawner.radiobutton[302] = guiCreateRadioButton(231, 216, 136, 15, "Generic Drink", false, cargoSpawner.tab[3])
	guiRadioButtonSetSelected(cargoSpawner.radiobutton[301], true)

	cargoSpawner.button[301] = guiCreateButton(10, 246, 431, 29, "Create", false, cargoSpawner.tab[3])


	-- EVENT 
	addEventHandler("onClientGUIClick", cargoSpawner.window[1], function()
		if source == cargoSpawner.button[3] then --reset
			guiSetText(cargoSpawner.edit[1], "")
			guiSetText(cargoSpawner.edit[2], "1")
			guiSetText(cargoSpawner.edit[3], "")
			guiSetText(cargoSpawner.edit[4], "")
			guiSetText(cargoSpawner.edit[5], "1")

			guiSetText(cargoSpawner.edit[201], "")
			guiSetText(cargoSpawner.edit[202], "1")
			guiSetText(cargoSpawner.memo[201], "")

			guiSetText(cargoSpawner.edit[301], "")
			guiSetText(cargoSpawner.edit[302], "1")
			guiSetText(cargoSpawner.edit[303], "")
			guiSetText(cargoSpawner.edit[304], "")
			guiSetText(cargoSpawner.edit[305], "1")
			guiRadioButtonSetSelected(cargoSpawner.radiobutton[302], false)
			guiRadioButtonSetSelected(cargoSpawner.radiobutton[301], true)
		elseif source == cargoSpawner.button[1] then --close window
			destroyElement(cargoSpawner.window[1])
			guiSetInputEnabled(false)
		elseif source == cargoSpawner.button[2] or source == cargoSpawner.button[201] or source == cargoSpawner.button[301] then --create item
			local genericType, price, quantity, name, model, scale, texURL, texName
			if source == cargoSpawner.button[2] then --create generic from GUI
				genericType = 1
				price = tonumber(guiGetText(cargoSpawner.edit[1]))
				quantity = tonumber(guiGetText(cargoSpawner.edit[2]))
				name = guiGetText(cargoSpawner.edit[3])
				model = tonumber(guiGetText(cargoSpawner.edit[4]))
				scale = tonumber(guiGetText(cargoSpawner.edit[5]))
			elseif source == cargoSpawner.button[201] then --create generic from code
				genericType = 1
				price = tonumber(guiGetText(cargoSpawner.edit[201]))
				quantity = tonumber(guiGetText(cargoSpawner.edit[202]))
				local code = exports.global:explode(":", tostring(guiGetText(cargoSpawner.memo[201])))
				name = code[1] or ""
				model = tonumber(code[2]) or 1271
				scale = tonumber(code[3]) or 1
				if code[4] and code[5] then
					texURL = "http://"..code[4]
					texName = code[5]
				end
			elseif source == cargoSpawner.button[301] then --create consumable item
				price = tonumber(guiGetText(cargoSpawner.edit[301]))
				quantity = tonumber(guiGetText(cargoSpawner.edit[302]))
				name = guiGetText(cargoSpawner.edit[303])
				model = tonumber(guiGetText(cargoSpawner.edit[304]))
				scale = tonumber(guiGetText(cargoSpawner.edit[305]))
				if guiRadioButtonGetSelected(cargoSpawner.radiobutton[301]) then
					genericType = 2
				else
					genericType = 3
				end
			end
			
			-- checks
			if not price or (price == 0 and not exports.integration:isPlayerTrialAdmin(localPlayer)) then
				--outputChatBox("You have entered an invalid price.", 255, 0, 0)
				genericAlert("Error", "You have entered an invalid price.", false, false, 255, 0, 0)
				return
			end
			if not quantity or (quantity > 30 or quantity < 1) then
				--outputChatBox("You can only spawn up to 30 items at a time.", 255, 0, 0)
				genericAlert("Error", "You can only spawn up to 30 items at a time.", false, false, 255, 0, 0)
				return
			end
			if string.len(name) < 3 then
				--outputChatBox("You have entered an invalid item name.", 255, 0, 0)
				genericAlert("Error", "You have entered an invalid item name.", false, false, 255, 0, 0)
				return
			end
			if not model then
				--outputChatBox("You have entered an invalid item model.", 255, 0, 0)
				genericAlert("Error", "You have entered an invalid item model.", false, false, 255, 0, 0)
				return
			end
			if not scale and scale > 0 and scale < 10 then
				--outputChatBox("You can only spawn items with a scale bigger than 0 and smaller than 10.", 255, 0, 0)
				genericAlert("Error", "You can only spawn items with a scale bigger than 0 and smaller than 10.", false, false, 255, 0, 0)
				return
			end
			local itemID = (tonumber(genericType) == 1 and 80) or (tonumber(genericType) == 2 and 89) or (tonumber(genericType) == 3 and 95) or false
			local itemValue = genericType == 1 and "1" or name..":"..model
			local metadata = { ['item_name'] = name, ['model'] = model, ['scale'] = scale or 1 }
			if texURL and texName then
				metadata['url'] = texURL
				metadata['texture'] = texName
			end
			local playerMaxCarryWeight = exports['item-system']:getMaxWeight(localPlayer)
			local playerCurrentCarryWeight = exports['item-system']:getCarriedWeight(localPlayer)
			local playerCanCarryWeight = playerMaxCarryWeight - playerCurrentCarryWeight
			local itemWeight = exports['item-system']:getItemWeight(itemID, itemValue, metadata)
			if (itemWeight*quantity) > playerCanCarryWeight then
				genericAlert("Error", "You do not have space in your inventory to carry "..tostring(quantity).." of this item. You can currently carry up to "..tostring(math.floor(playerCanCarryWeight/itemWeight)).." of this item.", false, false, 255, 0, 0)
				return
			end
			if texURL and texName then
				local approved = exports['item-texture']:validateFileFromURL(texURL)
				if not approved then
					pendingItemCreationData = {admin, genericType, price, quantity, name, model, scale, texURL, texName}
					pendingURLApproval[texURL] = true
					genericAlert("Please wait...", "Please wait...\nValidating custom textures...", "Abort", "abortFileValidation")
					return
				end
			end
			-- end checks

			triggerServerEvent("createCargoGeneric", getResourceRootElement(), localPlayer, admin, genericType, price, quantity, name, model, scale, texURL, texName)
		end
	end)
end
addEvent("createCargoGUI", true)
addEventHandler("createCargoGUI", getRootElement(), buildCargoGUI)

function genericAlert(title, text, btnText, btnFunction, r, g, b)
	genericAlertClose()
	if not title then title = "Alert" end
	if not text then text = "" end
	if not btnText then btnText = "Cancel" end
	cargoSpawner.window[2] = guiCreateWindow(0, 0, 200, 150, tostring(title), false)
	guiWindowSetSizable(cargoSpawner.window[2], false)
	exports.global:centerWindow(cargoSpawner.window[2])
	cargoSpawner.label[2001] = guiCreateLabel(20, 30, 160, 71, tostring(text), false, cargoSpawner.window[2])
	guiLabelSetHorizontalAlign(cargoSpawner.label[2001], "center", true)
	guiLabelSetVerticalAlign(cargoSpawner.label[2001], "center")
	if tonumber(r) and tonumber(g) and tonumber(b) then
		guiLabelSetColor(cargoSpawner.label[2001], r, g, b)
	end
	cargoSpawner.button[2001] = guiCreateButton(20, 111, 160, 29, btnText, false, cargoSpawner.window[2])

	if btnFunction == "abortFileValidation" then
		addEventHandler("onClientGUIClick", cargoSpawner.button[2001], function()
			genericAbortWaitForTexture()
			genericAlertClose()
		end, false)
	else
		addEventHandler("onClientGUIClick", cargoSpawner.button[2001], function()
			genericAlertClose()
		end, false)
	end

	guiSetEnabled(cargoSpawner.window[1], false)
end
function genericAlertClose()
	if cargoSpawner.window[2] then
		if isElement(cargoSpawner.window[2]) then
			destroyElement(cargoSpawner.window[2])
		end
		cargoSpawner.window[2] = nil
		guiSetEnabled(cargoSpawner.window[1], true)
	end
end

function genericTextureFileValidationResult(url, result, error)
	if pendingURLApproval[url] then
		if result then
			genericAlertClose()
			if pendingItemCreationData then
				local data = pendingItemCreationData
				triggerServerEvent("createCargoGeneric", resourceRoot, localPlayer, data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9])
			end
			genericAbortWaitForTexture()
		else
			genericAlert("Error", "Texture validation failed:\n"..tostring(error), false, false, 255, 0, 0)
		end
	end
end
addEventHandler("item-texture:fileValidationResult", root, genericTextureFileValidationResult)

function createCargoCommand()
	if exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerScripter(localPlayer) then
		buildCargoGUI(true)
	end
end
addCommandHandler("makegeneric", createCargoCommand)



