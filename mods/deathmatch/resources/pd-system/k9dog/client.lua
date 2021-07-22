local gMe = getLocalPlayer()

addEvent("doPedJump", true)
addEvent("doPedEnter", true)
addEvent("doPedExitVeh", true)

addEventHandler("doPedJump", getLocalPlayer(), function(p, boolean)
	setPedControlState(p, "jump", boolean)
end)

addEventHandler("doPedEnter", getLocalPlayer(), function(p, boolean)
	setPedControlState(p, "enter_passenger", boolean)
end)

addEventHandler("doPedExitVeh", getLocalPlayer(), function(p, boolean)
	setPedControlState(p, "enter_exit", boolean)
end)


-- DAMAGE ABFRAGE --

local pedTarget = {}
local pedTimer = {}
local pedShooting = {}

local function doPedAttackOtherPlayer(ped)
	if(isTimer(pedTimer[ped])) or (isPedInVehicle(ped)) then
		killTimer(pedTimer[ped])
	end
	if(isElement(ped)) then
		pedTimer[ped] = setTimer(function()
			if(isElement(ped)) then
				local target = pedTarget[ped]
				if(target) then
					local x, y, z = getElementPosition(ped)
					local x2, y2, z2 = getElementPosition(target)
					if(isLineOfSightClear(x, y, z, x2, y2, z2, true, false, false, false, false, false)) then
						if(getElementHealth(target) > 1) then
							if(pedShooting[ped] ~= true) then
								--[[
								local x1, y1 = getElementPosition(ped)
								local x2, y2 = getElementPosition(target)
									local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
									rot = rot-90
									setPedRotation(ped, rot)
									setPedAnimation(ped)
									if(getPedControlState(ped, "fire") ~= true) then
										setPedControlState(ped, "fire", true)
									end
									setPedAimTarget(ped, x2, y2, z2)]]
								setPedControlState(ped, "fire", true)
								pedShooting[ped] = true
							else
								local x1, y1, z1 = getElementPosition(ped)
								local x2, y2, z2 = getElementPosition(target)
								local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
								rot = rot-90
								setPedRotation(ped, rot)
								setPedAimTarget(ped, x2, y2, z2)
							end
						else
							killTimer(pedTimer[ped])
							pedShooting[ped] = false
							setPedControlState(ped, "fire", false)
						end
					else
						killTimer(pedTimer[ped])
						pedShooting[ped] = false
						setPedControlState(ped, "fire", false)
					end
				end
			else
				killTimer(pedTimer[ped])
			end
		end, 500, -1)
	else
		killTimer(pedTimer[ped])
	end
end

--[[
addEventHandler("onClientPedDamage", getRootElement(), function(attacker)
	if(getElementData(source, "bodyguard") == true) then
		if(attacker) and (isElement(attacker)) then
			if(getElementType(attacker) == "player") or (getElementType(attacker) == "vehicle") then
				pedTarget[source] = attacker
				doPedAttackOtherPlayer(source)
			end
		end
	end
end)]]

GUIEditor = {
    gridlist = {},
    window = {},
    button = {},
    column = {}
}
function start_GUI(thePlayer, commandName)
	if exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or exports.integration:isPlayerScripter(getLocalPlayer()) then
		if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
		GUIEditor.window[1] = guiCreateWindow(659, 293, 254, 309, "Manage Dog Users", false)
		guiWindowSetSizable(GUIEditor.window[1], false)
		guiSetProperty(GUIEditor.window[1], "CaptionColour", "FFFE00B3")
	
		GUIEditor.gridlist[1] = guiCreateGridList(0.04, 0.07, 0.93, 0.72, true, GUIEditor.window[1])
		GUIEditor.column[1] = guiGridListAddColumn(GUIEditor.gridlist[1], "Name", 0.5)
		GUIEditor.column[2] = guiGridListAddColumn(GUIEditor.gridlist[1], "Attack", 0.5)
		guiGridListSetSortingEnabled(GUIEditor.gridlist[1], false)
	
		local t = getElementData(resourceRoot, "dogs:table")
		for k,v in ipairs(t) do
			local row = guiGridListAddRow(GUIEditor.gridlist[1])
			guiGridListSetItemText( GUIEditor.gridlist[1], row, GUIEditor.column[1], v["charactername"], false, false)
			guiGridListSetItemText( GUIEditor.gridlist[1], row, GUIEditor.column[2], v["attack"], false, false)
		end
	
		GUIEditor.button[1] = guiCreateButton(0.36, 0.82, 0.29, 0.13, "Revoke", true, GUIEditor.window[1])
		addEventHandler("onClientGUIClick", GUIEditor.button[1], function ()
				local rindex, cindex = guiGridListGetSelectedItem(GUIEditor.gridlist[1])
				local name = guiGridListGetItemText(GUIEditor.gridlist[1], rindex, 1)

				if rindex ~= -1 then
					local theid = rindex + 1
					triggerServerEvent("dogs:doquery", resourceRoot, 2, t[theid]["charactername"])
					table.remove(t, theid)
					setElementData(resourceRoot, "dogs:table", t)
					destroyElement(GUIEditor.window[1])
					start_GUI()
				else
					outputChatBox("You must select a person to revoke.")
				end
			end, false)

		GUIEditor.button[2] = guiCreateButton(0.67, 0.82, 0.29, 0.13, "Close", true, GUIEditor.window[1])
		addEventHandler("onClientGUIClick", GUIEditor.button[2], function ()
				if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
			end, false)
	end
end
addEvent("dogs:startGUI", true)
addEventHandler("dogs:startGUI", resourceRoot, start_GUI)
addCommandHandler("dogs", start_GUI)

addCommandHandler("dogadd", function (commandName, character, attack)
	if exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or exports.integration:isPlayerScripter(getLocalPlayer()) then
		if character and tonumber(attack) then
			triggerServerEvent("dogs:doquery", resourceRoot, 1, string.gsub(character, "_", " "), tonumber(attack))
			local thetable = getElementData(resourceRoot, "dogs:table")
			local newid = #thetable + 1
			thetable[newid] = { }
			thetable[newid]["charactername"] = string.gsub(character, "_", " ")
			thetable[newid]["attack"] = tonumber(attack)
			setElementData(resourceRoot, "dogs:table", thetable)
	
			if isElement(GUIEditor.window[1]) then
				destroyElement(GUIEditor.window[1])
			end
	
			start_GUI()
	
			outputChatBox("User has been added! "..character.." - Attack: "..attack)
		else
			outputChatBox("SYNTAX: /"..commandName.." [exact name] [attack: 1 or 0]")
		end
	end
end)