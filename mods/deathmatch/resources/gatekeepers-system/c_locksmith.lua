-- configs
local npcmodel = 161 -- skin ID of the ped
local x, y, z =  1471.9091796875, -1936.6123046875, 290.70001220703 -- location of the ped
local rot = 0 -- rotation of the ped
local int = 1 -- interior of the ped
local dim = 9 -- dimension of the ped
local name = "Georgio Dupont" -- first and last name of the ped
local cost = 50 -- cost in dollars per key
-- end of configs

local localPlayer = getLocalPlayer()
local inprocess = false
local factionInteriors = {}

function createLocksmithNPC()
	local ped = createPed(npcmodel, x, y, z)
	setElementFrozen(ped, true)
	setElementRotation(ped, 0, 0, rot)
	setElementDimension(ped, dim)
	setElementInterior(ped, int)

	setElementData(ped, 'name', name, false)
	setElementData(ped, "talk", 1, true)

	addEventHandler( 'onClientPedWasted', ped,
		function()
			setTimer(
				function()
					destroyElement(ped)
					createShopPed()
				end, 30000, 1)
		end, false)

	addEventHandler( 'onClientPedDamage', ped, cancelEvent, false )
end

--addEventHandler( 'onClientResourceStart', resourceRoot, createLocksmithNPC )



local GUIEditor = {
    edit = {},
    button = {},
    window = {},
    label = {},
    combobox = {}
}
function createGUI()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end

	triggerServerEvent("locksmithNPC:getFactionInts", resourceRoot)

	GUIEditor.window[1] = guiCreateWindow(656, 279, 272, 180, "Key Duplicator", false)
	guiWindowSetSizable(GUIEditor.window[1], false)

	GUIEditor.label[1] = guiCreateLabel(0.03, 0.12, 0.93, 0.09, "Hi! What would you like to copy today?", true, GUIEditor.window[1])
	GUIEditor.combobox[1] = guiCreateComboBox(0.03, 0.27, 0.47, 0.69, "", true, GUIEditor.window[1])
	guiComboBoxAddItem(GUIEditor.combobox[1], "House Key")
	guiComboBoxAddItem(GUIEditor.combobox[1], "Business Key")
	guiComboBoxAddItem(GUIEditor.combobox[1], "Vehicle Key")
	guiComboBoxAddItem(GUIEditor.combobox[1], "Garage Remote")
	guiComboBoxAddItem(GUIEditor.combobox[1], "Elevator Remote")

	GUIEditor.edit[1] = guiCreateEdit(0.52, 0.41, 0.43, 0.13, "Key ID", true, GUIEditor.window[1])
	GUIEditor.label[2] = guiCreateLabel(0.53, 0.29, 0.40, 0.12, "Key ID", true, GUIEditor.window[1])
	GUIEditor.label[3] = guiCreateProgressBar(0.53, 0.60, 0.42, 0.10, true, GUIEditor.window[1])
	GUIEditor.button[1] = guiCreateButton(0.53, 0.75, 0.23, 0.18, "Duplicate", true, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[1], function ()
			if not inprocess then
				local type = guiGetText(GUIEditor.combobox[1]) or "Error"
				local id = guiGetText(GUIEditor.edit[1]) or "ID Error"
				duplicateKey(type, id)
			end
		end, false)

	GUIEditor.button[2] = guiCreateButton(0.76, 0.75, 0.19, 0.18, "Close", true, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[2], function ()
			destroyElement(GUIEditor.window[1])
			guiSetInputEnabled(false)
		end, false)
		
	guiSetInputEnabled(true)
	
	triggerEvent("hud:convertUI", localPlayer, GUIEditor.window[1])
end
addEvent("locksmithGUI", true)
addEventHandler("locksmithGUI", localPlayer, createGUI)

function setFactionInteriors(data)
	factionInteriors = data
end
addEvent("locksmithNPC:setFactionInteriors", true)
addEventHandler("locksmithNPC:setFactionInteriors", localPlayer, setFactionInteriors)

function duplicateKey(type, id)
	local keytype = nil
	local factionKey = false
	
	for k,v in pairs(factionInteriors) do 
		if v == tonumber(id) then
			factionKey = true
		end
	end

	if not tonumber(id) then -- checks if its an actual number
		guiSetText( GUIEditor.label[1], "The ID you have entered is incorrect." )
		guiLabelSetColor( GUIEditor.label[1], 255, 0, 0 )
		setTimer(function ()
				if isElement(GUIEditor.label[1]) then
					guiSetText(GUIEditor.label[1], "Hi! What would you like to copy today?")
					guiLabelSetColor(GUIEditor.label[1], 255, 255, 255)
				end
			end, 2000, 1)
		return
	end

	if type == "House Key" then keytype = 4 end
	if type == "Business Key" then keytype = 5 end
	if type == "Vehicle Key" then keytype = 3 end
	if type == "Garage Remote" then keytype = 98 end
	if type == "Elevator Remote" then keytype = 73 end
	if not tonumber(keytype) then -- if hasn't chosen any key type from dropdown menu
		guiSetText( GUIEditor.label[1], "You have not chosen a key type." )
		guiLabelSetColor( GUIEditor.label[1], 255, 0, 0 )
		setTimer(function ()
				if isElement(GUIEditor.label[1]) then
					guiSetText(GUIEditor.label[1], "Hi! What would you like to copy today?")
					guiLabelSetColor(GUIEditor.label[1], 255, 255, 255)
				end
			end, 2000, 1)
		return
	end

	if not exports.global:hasItem( getLocalPlayer(), tonumber(keytype), tonumber(id) ) then -- checks if you actually have the key on you
		if not factionKey then -- Check if it's not a faction key
			guiSetText( GUIEditor.label[1], "You're not authorized to duplicate this key." )
			guiLabelSetColor( GUIEditor.label[1], 255, 0, 0 )
			setTimer(function ()
					if isElement(GUIEditor.label[1]) then
						guiSetText(GUIEditor.label[1], "Hi! What would you like to copy today?")
						guiLabelSetColor(GUIEditor.label[1], 255, 255, 255)
					end
				end, 2000, 1)
			return
		end
	end

	if not exports.global:hasMoney(getLocalPlayer(), cost) then -- checks if the player has enough money to get it duplicated
		guiSetText( GUIEditor.label[1], "You need at least 50$ to duplicate a key." )
		guiLabelSetColor( GUIEditor.label[1], 255, 0, 0 )
		setTimer(function ()
				if isElement(GUIEditor.label[1]) then
					guiSetText(GUIEditor.label[1], "Hi! What would you like to copy today?")
					guiLabelSetColor(GUIEditor.label[1], 255, 255, 255)
				end
			end, 2000, 1)
		return
	end

	guiSetText(GUIEditor.label[1], "Duplicating...")
	guiLabelSetColor(GUIEditor.label[1], 0, 255, 0)

	guiProgressBarSetProgress(GUIEditor.label[3], 0)
	inprocess = true
	setTimer( function()
		if isElement(GUIEditor.label[3]) then
			guiProgressBarSetProgress (GUIEditor.label[3], guiProgressBarGetProgress(GUIEditor.label[3]) + 5 )
		end
	end, 500, 20)
	setTimer(function ()
		if isElement(GUIEditor.window[1]) then
			guiSetText(GUIEditor.label[1], "Duplicated!")
			inprocess = false

			triggerServerEvent("locksmithNPC:givekey", resourceRoot, getLocalPlayer(), keytype, id, cost)
		end
	end, 10000, 1)
end
