local lsa = { 1610.6416015625, -2634.328125, 13.546875 }

local missiontable = {
	["lva"] = {1588.2001953125, 1226.697265625, 10.8125},
	["sfa"] = {-1349.7265625, -520.638671875, 14.1484375},
	["bca"] = {290.7080078125, 1956.341796875, 17.640625},
	["sta"] = {4093.501953125, 2240.0139160156, 10.987500190735}
}

GUIEditor = {
    gridlist = {},
    window = {},
    button = {},
    column = {}
}
function start_GUI(thePlayer, commandName)
	if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
	GUIEditor.window[1] = guiCreateWindow(659, 293, 254, 309, "Los Santos Aero Club", false)
	guiWindowSetSizable(GUIEditor.window[1], false)
	guiSetProperty(GUIEditor.window[1], "CaptionColour", "FFFE00B3")

	GUIEditor.gridlist[1] = guiCreateGridList(0.04, 0.07, 0.93, 0.72, true, GUIEditor.window[1])
	GUIEditor.column[1] = guiGridListAddColumn(GUIEditor.gridlist[1], "Name", 0.9)
	guiGridListSetSortingEnabled(GUIEditor.gridlist[1], false)

	local pilots_table = getElementData(resourceRoot, "sfia_pilots:table")
	for k,v in ipairs(pilots_table) do
		local row = guiGridListAddRow(GUIEditor.gridlist[1])
		guiGridListSetItemText( GUIEditor.gridlist[1], row, GUIEditor.column[1], v["charactername"], false, false)
	end

	if exports.factions:hasMemberPermissionTo(getLocalPlayer(), 47, "add_member") then
		GUIEditor.button[1] = guiCreateButton(0.04, 0.82, 0.29, 0.13, "Add", true, GUIEditor.window[1])
		addEventHandler("onClientGUIClick", GUIEditor.button[1], addAPilot, false)
		GUIEditor.button[2] = guiCreateButton(0.36, 0.82, 0.29, 0.13, "Revoke", true, GUIEditor.window[1])
		addEventHandler("onClientGUIClick", GUIEditor.button[2], function ()
				local rindex, cindex = guiGridListGetSelectedItem(GUIEditor.gridlist[1])
				local name = guiGridListGetItemText(GUIEditor.gridlist[1], rindex, 1)

				if rindex ~= -1 then
					revokeAPilot(rindex + 1)
				else
					outputChatBox("You must select a person to revoke.")
				end
			end, false)
	end

	GUIEditor.button[3] = guiCreateButton(0.67, 0.82, 0.29, 0.13, "Close", true, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[3], function ()
			if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
		end, false)
end
addEvent("pilotmission:startGUI", true)
addEventHandler("pilotmission:startGUI", resourceRoot, start_GUI)

add = {
    button = {},
    window = {},
    edit = {},
    label = {}
}
function addAPilot()
	if isElement(add.window[1]) then destroyElement(add.window[1]) end
	add.window[1] = guiCreateWindow(596, 346, 376, 78, "Los Santos Aero Club - Add", false)
	guiWindowSetSizable(add.window[1], false)
	guiSetInputMode("no_binds_when_editing")

	add.label[1] = guiCreateLabel(0.04, 0.51, 0.23, 0.22, "Enter full name", true, add.window[1])
	add.edit[1] = guiCreateEdit(0.29, 0.41, 0.37, 0.41, "", true, add.window[1])
	add.button[1] = guiCreateButton(0.68, 0.41, 0.13, 0.42, "Add", true, add.window[1])
	addEventHandler("onClientGUIClick", add.button[1], function ()
			if tostring(add.edit[1]) and tostring(add.edit[1]) ~= nil then
				triggerServerEvent("sfia_pilots:doquery", resourceRoot, 1, string.gsub(guiGetText(add.edit[1]), "_", " "))
				local thetable = getElementData(resourceRoot, "sfia_pilots:table")
				local newid = #thetable + 1
				thetable[newid] = { }
				thetable[newid]["charactername"] = string.gsub(guiGetText(add.edit[1]), "_", " ")
				setElementData(resourceRoot, "sfia_pilots:table", thetable)
				destroyElement(add.window[1])
				destroyElement(GUIEditor.window[1])
				start_GUI()
			end
		end, false)

	add.button[2] = guiCreateButton(0.82, 0.41, 0.13, 0.42, "Close", true, add.window[1])
	addEventHandler("onClientGUIClick",add.button[2], function ()
			if isElement(add.window[1]) then destroyElement(add.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)
end

function revokeAPilot(theid)
	local thetable = getElementData(resourceRoot, "sfia_pilots:table")
	triggerServerEvent("sfia_pilots:doquery", resourceRoot, 2, thetable[theid]["charactername"])
	table.remove(thetable, theid)
	setElementData(resourceRoot, "sfia_pilots:table", thetable)
	destroyElement(GUIEditor.window[1])
	start_GUI()
end

local assignedairport = nil
local blip = nil
local colsphere = nil
local source = nil


local allowedVehicles = {
	[548] = { true },
	[593] = { true },
	[417] = { true },
	[487] = { true },
	[563] = { true },
	[553] = { true },
	[511] = { true },
	[592] = { true },
	[577] = { true }
}

function doMission()
	local randomnumber = math.random(1, 4)
	local count = 0
	source = getLocalPlayer()
	for k, v in pairs(missiontable) do
		count = count + 1
		if count == randomnumber then
			assignedairport = tostring(k)
			outputChatBox("#B22400You have been given the following task:", 231, 217, 176, true)
			outputChatBox("     #FFFFFFDESTINATION: #B22400"..string.upper(tostring(k)), 231, 217, 176, true)
			outputChatBox("     #FFFFFFAIRCRAFT", 231, 217, 176, true)
			outputChatBox("          #FFFFFFROT/SER: #B22400250$", 231, 217, 176, true)
			outputChatBox("          #FFFFFFMER: #B22400750$", 231, 217, 176, true)
			outputChatBox("          #FFFFFFTER: #B224001800$", 231, 217, 176, true)
			outputChatBox("#B22400First pick up the shipment at LSIA (see blip).", 231, 217, 176, true)

			if isElement(blip) then destroyElement(blip) end
			blip = createBlip(lsa[1], lsa[2], lsa[3], 53, 2, 255, 0, 0, 255, 0, 5000)

			if isElement(colsphere) then destroyElement(colsphere) end
			colsphere = createColSphere(lsa[1], lsa[2], lsa[3], 20)

			addEventHandler("onClientColShapeHit", colsphere, function (theElement)
				if source ~= theElement then return false end
				local vehElement = getPedOccupiedVehicle(getLocalPlayer())
				if not vehElement then
					outputChatBox("You must be in an aircraft!")
					return false
				end
				local vehID = getVehicleModelFromName(getVehicleName(vehElement))
				if not allowedVehicles[vehID] then
					outputChatBox("This vehicle is not allowed.")
					return false
				end
				outputChatBox("#B22400A blip (flag) has been added to your GPS for the destination.", 231, 217, 176, true)

				if isElement(blip) then destroyElement(blip) end
				blip = createBlip(v[1], v[2], v[3], 53, 2, 255, 0, 0, 255, 0, 5000)

				if isElement(colsphere) then destroyElement(colsphere) end
				colsphere = createColSphere(v[1], v[2], v[3], 20)

				addEventHandler("onClientColShapeHit", colsphere, function (theElement)
					if source ~= theElement or not vehElement then return false end
					if isElement(blip) then destroyElement(blip) end
					if isElement(colsphere) then destroyElement(colsphere) end

					vehID = getVehicleModelFromName(getVehicleName(vehElement))
					if (vehID == 548 or vehID == 417 or vehID == 487 or vehID == 563 or vehID == 593) then
						triggerServerEvent("sfia_pilots:doquery", resourceRoot, 3, nil, getLocalPlayer(), 250)
					elseif (vehID == 553 or vehID == 511) then
						triggerServerEvent("sfia_pilots:doquery", resourceRoot, 3, nil, getLocalPlayer(), 750)
					elseif (vehID == 592 or vehID == 577) then
						triggerServerEvent("sfia_pilots:doquery", resourceRoot, 3, nil, getLocalPlayer(), 1800)
					else
						outputChatBox("The vehicle you are boarding is not valid for transport.")
					end
				end)
			end)
			break
		end
	end
end
addEvent("pilotmission:domission", true)
addEventHandler("pilotmission:domission", resourceRoot, doMission)

