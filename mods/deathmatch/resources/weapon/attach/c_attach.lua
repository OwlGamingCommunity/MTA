--[[
	attach_c.lua
	Allows players to customize weapon attachment coordinates with a live
	editor and saves the coordinates to a local XML file
]]

local bones = {
	"Head", "Neck", "Spine", "Pelvis", "Left clavicle", "Right clavicle",
	"Left shoulder", "Right shoulder", "Left elbow", "Right elbow",
	"Left hand", "Right hand", "Left hip", "Right hip", "Left knee", "Right knee",
	"Left ankle", "Right ankle", "Left foot", "Right foot"
}

local defaultWeaponPositions = {
	[22] = {22, 14, 0.1, 0.11, -0.05, 180, 90, -90},
	[23] = {23, 14, 0.1, 0.11, -0.05, 180, 90, -90},
	[24] = {24, 14, 0.1, 0.11, -0.05, 180, 90, -90},
	[25] = {25, 3, 0, -0.15, 0.245, 8, 90, 0},
	[26] = {26, 13, -0.07, 0.11, -0.05, 180, 90, -90},
	[27] = {27, 3, 0, -0.15, 0.245, 8, 90, 0},
	[28] = {28, 14, 0.1, 0.11, -0.05, 180, 90, -90},
	[29] = {29, 14, 0.1, 0.11, -0.05, 180, 90, -90},
	[30] = {30, 3, 0.175, 0.2, 0.125, 180, 240, 5},
	[31] = {31, 3, 0.175, 0.2, 0.125, 180, 240, 5},
	[32] = {32, 14, 0.1, 0.11, -0.05, 180, 90, -90},
	[33] = {33, 3, 0, -0.13, -0.245, -3, 270, 0},
	[34] = {34, 3, 0, -0.13, -0.245, -3, 270, 0},
}

local xmlPath = ":resources/attachments.xml"
local weaponTable = {}
local editingSkin, editingWeapon, editingObject, remoteObject
local sWin, weaponsGridList, btnSelectionEdit, btnSelectionClose
local eWin, bonesComboBox, posEditBox, btnEditSave, btnEditReset, btnEditClose

-------------------------------------------------------------------------------------

--[[
	Method saveWeaponTable
	Saves the weapon attachment coordinates to a local XML file
]]
function saveWeaponTable()
	local xml = xmlCreateFile(xmlPath, "attachments")

	for skinID, attachments in pairs(weaponTable) do
		local skinNode = xmlCreateChild(xml, "skin")

		xmlNodeSetAttribute(skinNode, "id", skinID)

		for i, p in pairs(attachments) do
			local weaponNode = xmlCreateChild(skinNode, "weapon")

			xmlNodeSetAttribute(weaponNode, "id", p[1])
			xmlNodeSetAttribute(weaponNode, "bone", p[2])
			xmlNodeSetAttribute(weaponNode, "x", p[3])
			xmlNodeSetAttribute(weaponNode, "y", p[4])
			xmlNodeSetAttribute(weaponNode, "z", p[5])
			xmlNodeSetAttribute(weaponNode, "rx", p[6])
			xmlNodeSetAttribute(weaponNode, "ry", p[7])
			xmlNodeSetAttribute(weaponNode, "rz", p[8])
		end
	end

	xmlSaveFile(xml)
	xmlUnloadFile(xml)
end

--[[
	Method loadWeaponTable
	Loads the weapon attachment coordinates from a local XML file
]]
function loadWeaponTable()
	local xml = xmlLoadFile(xmlPath)

	if xml then
		for i, skinNode in pairs(xmlNodeGetChildren(xml)) do
			local skinID = tonumber(xmlNodeGetAttribute(skinNode, "id"))
			weaponTable[skinID] = {}

			for j, weaponNode in pairs(xmlNodeGetChildren(skinNode)) do
				local id   = tonumber(xmlNodeGetAttribute(weaponNode, "id"))
				local bone = tonumber(xmlNodeGetAttribute(weaponNode, "bone"))
				local x    = tonumber(xmlNodeGetAttribute(weaponNode, "x"))
				local y    = tonumber(xmlNodeGetAttribute(weaponNode, "y"))
				local z    = tonumber(xmlNodeGetAttribute(weaponNode, "z"))
				local rx   = tonumber(xmlNodeGetAttribute(weaponNode, "rx"))
				local ry   = tonumber(xmlNodeGetAttribute(weaponNode, "ry"))
				local rz   = tonumber(xmlNodeGetAttribute(weaponNode, "rz"))

				-- Validate the values before loading them into the table
				if math.abs(x) <= 0.5 and math.abs(y) <= 0.5 and math.abs(z) <= 0.5 then
					if bone <= #bones then
						table.insert(weaponTable[skinID], {id, bone, x, y, z, rx, ry, rz})
					end
				end
			end
		end

		xmlUnloadFile(xml)
	end
end

--[[
	Method getAttachmentPositionMatrix
	Retrieves the weapon attachment coordinates from a specific weapon from the table

	@param weapon - the GTASA weapon ID of the weapon to load the coordinates of
]]
function getAttachmentPositionMatrix(weapon)
	local skinID = getElementModel(localPlayer)

	if weaponTable[skinID] then
		for i, p in pairs(weaponTable[skinID]) do
			if p[1] == weapon then
				return p
			end
		end
	end

	--  Fall back to defaults if no attachment is found
	return defaultWeaponPositions[weapon] or {weapon, 14, 0.1, 0.11, -0.05, 180, 90, -90}
end

--[[
	Method createSelectionWindow
	Creates a window on the lower right corner to select which weapons will be attached
]]
function createSelectionWindow()
	if sWin then
		closeSelectionWindow("left", "up")
	end

	if eWin then
		closeEditWindow("left", "up")
	end


	showCursor(true)
	local sx, sy = guiGetScreenSize()
	sWin = guiCreateWindow(sx - 225, sy - 250, 200, 200, "Weapon Attachments", false)

	weaponsGridList = guiCreateGridList(0, 24, 200, 130, false, sWin)
	guiGridListSetSelectionMode(weaponsGridList, 0)
	guiGridListSetSortingEnabled(weaponsGridList, false)
	local weaponID = guiGridListAddColumn(weaponsGridList, "ID", 0.2)
	local weaponName = guiGridListAddColumn(weaponsGridList, "Weapon", 0.5)
	local weaponAttached = guiGridListAddColumn(weaponsGridList, "Att.", 0.2)
	addEventHandler("onClientGUIDoubleClick", weaponsGridList, doubleClickedWeapon, false)
	populateWeaponGridList()

	local help = guiCreateLabel(12, 155, 200, 10, "Double click to toggle attachment.", false, sWin)
	guiSetFont(help, "default-small")

	btnSelectionEdit = guiCreateButton(0, 170, 90, 20, "Edit", false, sWin)
	addEventHandler("onClientGUIClick", btnSelectionEdit, createEditWindow, false)

	btnSelectionClose = guiCreateButton(100, 170, 90, 20, "Close", false, sWin)
	addEventHandler("onClientGUIClick", btnSelectionClose, closeSelectionWindow, false)
end
addCommandHandler("togattach", createSelectionWindow)
addCommandHandler("toggleattach", createSelectionWindow)

--[[
	Method populateWeaponGridList
	Populates weaponsGridList with information on which weapons are selected for attachment
]]
function populateWeaponGridList()
	for i = 1, 12 do
		local weapon = getPedWeapon(localPlayer, i)

		if weapon ~= 0 then
			local row = guiGridListAddRow(weaponsGridList)

			guiGridListSetItemText(weaponsGridList, row, 1, weapon, false, true)
			guiGridListSetItemText(weaponsGridList, row, 2, getWeaponNameFromID(weapon), false, false)
			guiGridListSetItemText(weaponsGridList, row, 3, getElementData(localPlayer,
				"attachingWeapon" .. weapon) and "Yes" or "No", false, false)
		end
	end
end

--[[
	Method doubleClickedWeapon
	Event handler to toggle attachment status of a weapon and repopulate weaponsGridList
]]
function doubleClickedWeapon()
	local row, col = guiGridListGetSelectedItem(source)
	local id = tonumber(guiGridListGetItemText(source, row, 1))
	local name = guiGridListGetItemText(source, row, 2)

	if id then
		if not getElementData(localPlayer, "attachingWeapon" .. id) then
			setElementData(localPlayer, "attachingWeapon" .. id, true, true)

			local currentWeapon = getPedWeapon(localPlayer)

			if id ~= currentWeapon then
				triggerServerEvent("createWeaponModel", localPlayer, unpack(getAttachmentPositionMatrix(id)))
			end
		else
			setElementData(localPlayer, "attachingWeapon" .. id, false, true)
			triggerServerEvent("destroyWeaponModel", localPlayer, id)
		end

		guiGridListClear(source)
		populateWeaponGridList()
	end
end

--[[
	Method closeSelectionWindow
	Destroys the selection window
]]
function closeSelectionWindow(button, state)
	if button == "left" and state == "up" then
		if sWin then
			removeEventHandler("onClientGUIDoubleClick", weaponsGridList, doubleClickedWeapon)
			removeEventHandler("onClientGUIClick", btnSelectionEdit, createEditWindow)
			removeEventHandler("onClientGUIClick", btnSelectionClose, closeSelectionWindow)

			destroyElement(sWin)
			sWin = nil
			showCursor(false)
		end
	end
end

--[[
	Method createEditWindow
	Creates a window on the lower right corner to edit weapon attachment coordinates
]]
function createEditWindow()
	if eWin then
		closeEditWindow("left", "up")
	end

	local row, col = guiGridListGetSelectedItem(weaponsGridList)
	local id = tonumber(guiGridListGetItemText(weaponsGridList, row, 1))
	local name = guiGridListGetItemText(weaponsGridList, row, 2)
	local skin = getElementModel(localPlayer)

	if not id then return end

	editingSkin = skin
	editingWeapon = id
	remoteObject = getElementData(localPlayer, "attachedSlot" .. getSlotFromWeapon(editingWeapon))


	guiSetVisible(sWin, false)
	guiSetInputMode('no_binds_when_editing')

	local sx, sy = guiGetScreenSize()
	eWin = guiCreateWindow(sx - 250, sy - 375, 225, 325, "Edit Weapon Attachment", false)
	guiWindowSetSizable(eWin, false)

	guiCreateLabel(10, 26, 210, 15,
		"Editing " .. name .. " (" .. id .. ") for skin #" .. skin, false, eWin)

	guiCreateLabel(10, 52, 50, 15, "Bone:", false, eWin)
	bonesComboBox = guiCreateComboBox(65, 50, 150, 150, "Select", false, eWin)

	for index, bone in ipairs(bones) do
		guiComboBoxAddItem(bonesComboBox, "(" .. index .. ") " .. bone)
	end

	local originalPos = getAttachmentPositionMatrix(id)
	guiComboBoxSetSelected(bonesComboBox, originalPos[2] - 1)

	posEditBox = {}

	local function getEditPositions()
		return tonumber(guiGetText(posEditBox[1])) or 0,
			   tonumber(guiGetText(posEditBox[2])) or 0,
			   tonumber(guiGetText(posEditBox[3])) or 0,
			   tonumber(guiGetText(posEditBox[4])) or 0,
			   tonumber(guiGetText(posEditBox[5])) or 0,
			   tonumber(guiGetText(posEditBox[6])) or 0
	end

	addEventHandler("onClientGUIComboBoxAccepted", bonesComboBox,
		function ()
			if isElement(editingObject) then
				destroyElement(editingObject)
			end

			local bone = guiComboBoxGetSelected(bonesComboBox) + 1
			local x, y, z, rx, ry, rz = getEditPositions()

			editingObject = createEditingObject(editingWeapon, bone, x, y, z, rx, ry, rz)

			if isElement(remoteObject) then
				setElementAlpha(remoteObject, 0)
			end
		end,
	false)

	for i, name in ipairs({"PosX", "PosY", "PosZ", "RotX", "RotY", "RotZ"}) do
		local j = 30 * i + 50

		guiCreateLabel(10, j + 2, 50, 15, name .. ":", false, eWin)
		posEditBox[i] = guiCreateEdit(65, j, 150, 20, originalPos[i + 2], false, eWin)

		addEventHandler("onClientGUIChanged", posEditBox[i],
			function ()
				local bone = guiComboBoxGetSelected(bonesComboBox) + 1
				local x, y, z, rx, ry, rz = getEditPositions()

				if math.abs(x) > 0.5 or math.abs(y) > 0.5 or math.abs(z) > 0.5 then
					guiSetEnabled(btnEditSave, false)
				else
					if isElement(editingObject) then
						exports.bone_attach:attachElementToBone(editingObject,
							localPlayer, bone, x, y, z, rx, ry, rz)
					end

					guiSetEnabled(btnEditSave, true)
				end
			end,
		false)
	end

	btnEditSave = guiCreateButton(0, 295, 67, 20, "Save", false, eWin)
	addEventHandler("onClientGUIClick", btnEditSave, saveWeaponAttachment, false)

	btnEditReset = guiCreateButton(78, 295, 67, 20, "Default", false, eWin)
	addEventHandler("onClientGUIClick", btnEditReset, resetWeaponAttachment, false)

	btnEditClose = guiCreateButton(146, 295, 67, 20, "Close", false, eWin)
	addEventHandler("onClientGUIClick", btnEditClose, closeEditWindow, false)

	local help = guiCreateLabel(10, 255, 210, 35, "X, Y and Z offsets must be between -0.5 and 0.5.\n" ..
		"Press 'm' at anytime to look around.", false, eWin)
	guiSetFont(help, "default-small")

	local bone = guiComboBoxGetSelected(bonesComboBox) + 1
	local x, y, z, rx, ry, rz = getEditPositions()
	editingObject = createEditingObject(editingWeapon, bone, x, y, z, rx, ry, rz)
	triggerServerEvent("alphaWeaponModel", localPlayer, editingWeapon, true)

	showCursor(false)
end

--[[
	Method createEditingObect
	Creates a local weapon model attached to the ped's bone to guide when editing position

	@param weapon - the GTASA weapon ID of the weapon to be attached
	@param bone   - bone ID to attach the weapon model to, refer to resource bone_attach
	@param x      - the x-offset of the weapon from the bone
	@param y      - the y-offset of the weapon from the bone
	@param z      - the z-offset of the weapon from the bone
	@param rx     - angle of the weapon with respect to the x-axis
	@param ry     - angle of the weapon with respect to the y-axis
	@param rz     - angle of the weapon with respect to the z-axis
]]
function createEditingObject(weapon, bone, x, y, z, rx, ry, rz)
	local slot = getSlotFromWeapon(weapon)
	local object = getElementData(localPlayer, "attachedSlot" .. slot)

	if isElement(object) then
		setElementAlpha(object, 0)
	end

	object = createObject(models[editingWeapon], x, y, z)
	setElementCollisionsEnabled(object, false)
	setElementInterior(object, getElementInterior(localPlayer))
	setElementDimension(object, getElementDimension(localPlayer))
	exports.bone_attach:attachElementToBone(object, localPlayer, bone, x, y, z, rx, ry, rz)

	return object
end

--[[
	Method saveWeaponAttachment
	Saves the weapon attachment coordinates to the XML file when the save button is clicked on
	and redraws the synced object if the weapon was selected for attachment
]]
function saveWeaponAttachment(button, state)
	if button == "left" and state == "up" then
		if not weaponTable[editingSkin] then
			weaponTable[editingSkin] = {}
		end

		-- Remove the existing data on the weapon
		for i, p in pairs(weaponTable[editingSkin]) do
			if p[1] == editingWeapon then
				weaponTable[editingSkin][i] = nil
			end
		end

		table.insert(weaponTable[editingSkin], {
			editingWeapon, guiComboBoxGetSelected(bonesComboBox) + 1,
			tonumber(guiGetText(posEditBox[1])) or 0,
			tonumber(guiGetText(posEditBox[2])) or 0,
			tonumber(guiGetText(posEditBox[3])) or 0,
			tonumber(guiGetText(posEditBox[4])) or 0,
			tonumber(guiGetText(posEditBox[5])) or 0,
			tonumber(guiGetText(posEditBox[6])) or 0
		})

		saveWeaponTable()

		if isElement(editingObject) then
			exports.bone_attach:attachElementToBone(editingObject,
				localPlayer, unpack(getAttachmentPositionMatrix(editingWeapon)))

			if isElement(remoteObject) then
				setElementAlpha(remoteObject, 0)
			end
		end

		outputChatBox("Saved position of (" .. editingWeapon .. ") " .. getWeaponNameFromID(editingWeapon) ..
			" for skin #" .. editingSkin .. ".", 0, 255, 0)
	end
end

--[[
	Method resetWeaponAttachment
	Removes the weapon attachment coordinates from the XML file when the reset button is clicked on
	and redraws the synced object if the weapon was selected for attachment
]]
function resetWeaponAttachment(button, state)
	if button == "left" and state == "up" then
		if weaponTable[editingSkin] then
			for i, p in pairs(weaponTable[editingSkin]) do
				if p[1] == editingWeapon then
					weaponTable[editingSkin][i] = nil
				end
			end

			saveWeaponTable()
		end

		local originalPos = getAttachmentPositionMatrix(editingWeapon)

		guiComboBoxSetSelected(bonesComboBox, originalPos[2] - 1)

		for i = 1, 6 do
			guiSetText(posEditBox[i], originalPos[i + 2])
		end

		if isElement(editingObject) then
			exports.bone_attach:attachElementToBone(editingObject,
				localPlayer, unpack(getAttachmentPositionMatrix(editingWeapon)))

			if isElement(remoteObject) then
				setElementAlpha(remoteObject, 0)
			end
		end

		outputChatBox("Reset position of (" .. editingWeapon .. ") " .. getWeaponNameFromID(editingWeapon) ..
			" for skin #" .. editingSkin .. " to default.", 0, 255, 0)
	end
end

--[[
	Method closeEditWindow
	Destroys the weapon attachment coordinates editor window
]]
function closeEditWindow(button, state)
	if button == "left" and state == "up" then
		if eWin then
			if getElementData(localPlayer, "attachingWeapon" .. editingWeapon) then
				if getPedWeapon(localPlayer) ~= editingWeapon then
					triggerServerEvent("createWeaponModel", localPlayer,
						unpack(getAttachmentPositionMatrix(editingWeapon)))
				end
			end

			if isElement(remoteObject) then
				setElementAlpha(remoteObject, 255)
			end

			if isElement(editingObject) then
				destroyElement(editingObject)
			end

			editingSkin = false
			editingWeapon = false
			editingObject = nil

			removeEventHandler("onClientGUIClick", btnEditSave, saveWeaponAttachment)
			removeEventHandler("onClientGUIClick", btnEditReset, resetWeaponAttachment)
			removeEventHandler("onClientGUIClick", btnEditClose, closeEditWindow)

			destroyElement(eWin)
			eWin = nil
		end

		if sWin then
			guiSetVisible(sWin, true)
			guiSetInputMode('allow_binds')
		end
	end
end

addEventHandler("onClientPlayerWeaponSwitch", root,
	function (prev, curr)
		-- Unattach current weapon and attach the previous one if it was selected for attachment
		triggerServerEvent("destroyWeaponModel", localPlayer, getPedWeapon(localPlayer, curr))

		if getElementData(localPlayer, "attachingWeapon" .. getPedWeapon(localPlayer, prev)) then
			triggerServerEvent("createWeaponModel", localPlayer, unpack(
				getAttachmentPositionMatrix(getPedWeapon(localPlayer, prev))
			))
		end
	end
)

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		loadWeaponTable()

		for i, model in pairs(models) do
			if getElementData(localPlayer, "attachingWeapon" .. i) then
				if getPedWeapon(localPlayer, getSlotFromWeapon(i)) == i and getPedWeapon(localPlayer) ~= i then
					triggerServerEvent("createWeaponModel", localPlayer, unpack(getAttachmentPositionMatrix(i)))
				end
			end
		end
	end
)

--[[
	Event requestWeaponModel
	Tells the server to create a weapon model with the specific attachment data from the client

	@param weapon - the GTASA weapon ID of the weapon to be attached
]]
addEvent("requestWeaponModel", true)
addEventHandler("requestWeaponModel", root,
	function(weapon)
		triggerServerEvent("createWeaponModel", source, unpack(getAttachmentPositionMatrix(weapon)))
	end
)


addEventHandler("onClientVehicleExit", root,
	function (player, seat)
		if player ~= localPlayer then
			return
		end

		for i, model in pairs(models) do
			if getElementData(localPlayer, "attachingWeapon" .. i) then
    			if getPedWeapon(localPlayer, getSlotFromWeapon(i)) == i and getPedWeapon(localPlayer) ~= i then
    				triggerServerEvent("createWeaponModel", localPlayer, unpack(getAttachmentPositionMatrix(i)))
    			end
			end
		end
	end
)
