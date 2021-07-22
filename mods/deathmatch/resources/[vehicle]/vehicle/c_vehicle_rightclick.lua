local vehicle = nil
local ax, ay = 0, 0
function requestInventory(button)
	if button=="left" and not getElementData(localPlayer, "exclusiveGUI") then
		if isVehicleLocked(vehicle) and vehicle ~= getPedOccupiedVehicle(localPlayer) then
			triggerServerEvent("onVehicleRemoteAlarm", vehicle)
			outputChatBox("This vehicle is locked.", 255, 0, 0)
		elseif type(getElementData(vehicle, "Impounded")) == "number" and isVehicleImpounded(vehicle) and not exports.global:hasItem(localPlayer, 3, getElementData(vehicle, "dbid")) then
			outputChatBox("You need the keys to search this vehicle.", 255, 0, 0)
		else
			triggerServerEvent( "openFreakinInventory", localPlayer, vehicle, ax, ay )
		end
	end
end

function clickVehicle(button, state, absX, absY, wx, wy, wz, element)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if (element) and (getElementType(element)=="vehicle") and (button=="right") and (state=="down") then
		local x, y, z = getElementPosition(localPlayer)
		if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=3) then
			ax = absX
			ay = absY
			vehicle = element
			triggerServerEvent("vehicle:rightclick:fetch_data", vehicle)
		end
	end
end
addEventHandler("onClientClick", root, clickVehicle, true)

addEvent("vehicle:rightclick:data", true)
addEventHandler("vehicle:rightclick:data", root, function(...) if vehicle == source then showVehicleMenu(...) end end)

--Needs to be redone to run better
function isNotAllowedV(theVehicle)
	--[[local vmodel = getElementModel(theVehicle)
	if (getVehicleType(vmodel) == "Plane") then
		return true
	end
	if (getVehicleType(vmodel) == "Helicopter") then
		return true
	end
	if (getVehicleType(vmodel) == "Boat") then
		return true
	end
	if (getVehicleType(vmodel) == "Train") then
		return true
	end
	if (getVehicleType(vmodel) == "Trailer") then
		return true
	end]]
	return false
end

function showVehicleMenu(hasRamp)
	local rightclick = exports.rightclick
	--Name
	local vName = exports.global:getVehicleName(vehicle)

	local row = {}
	local rcMenu = rightclick:create(vName)

	local isLocked = isVehicleLocked(vehicle)
	local inCar = ( getPedSimplestTask(localPlayer) == "TASK_SIMPLE_CAR_DRIVE" and getPedOccupiedVehicle(localPlayer) == vehicle ) or false

	if exports.vehicle:hasVehiclePlates(vehicle) and getElementData(vehicle, "show_plate") ~= 0 then -- Addded no plates support
		row.plate = rightclick:addRow(getVehiclePlateText(vehicle), true)
	end

	if (isVehicleImpounded(vehicle)) then
		local days = getRealTime().yearday-getElementData(vehicle, "Impounded")
		row.impounded = rightclick:addRow("Impounded: "..days.." days", false, true)
	end

	if (hasVehicleWindows(vehicle)) then
		local windowState = isVehicleWindowUp(vehicle, true) and "Up" or "Down"
		row.window = rightclick:addRow("Window: "..windowState, false, true)
	end

	--y = y + lineH

	if ( getPedSimplestTask(localPlayer) == "TASK_SIMPLE_CAR_DRIVE" and getPedOccupiedVehicle(localPlayer) == vehicle ) or exports.global:hasItem(localPlayer, 3, getElementData(vehicle, "dbid")) or (exports.factions:isPlayerInFaction(localPlayer, getElementData(vehicle, "faction"))) then

		local lockText
		if isLocked then
			lockText = "Unlock"
		else
			lockText = "Lock"
		end
		row.lock = rightclick:addRow(lockText)
		addEventHandler("onClientGUIClick", row.lock, lockUnlock, false)

		if not isLocked or inCar then --if vehicle is not locked or if player is inside vehicle
			row.inventory = rightclick:addRow("Inventory")
			addEventHandler("onClientGUIClick", row.inventory, requestInventory, false)

			-- Cabriolet (Exciter)
			if isCabriolet(vehicle) then
				row.cabriolet = rightclick:addRow("Toggle Roof")
				addEventHandler("onClientGUIClick", row.cabriolet, cabrioletToggleRoof, false)
			end

			if hasRamp and getPedOccupiedVehicle(localPlayer) == vehicle then
				row.ramp = rightclick:addRow("Toggle Ramp")
				addEventHandler("onClientGUIClick", row.ramp, toggleRamp, false)
			end
		end
	end

	if getElementData(localPlayer, "job") == 5 or exports.integration:isPlayerTrialAdmin(localPlayer, true) then -- Mechanic
		row.fix = rightclick:addRow("Fix/Upgrade")
		addEventHandler("onClientGUIClick", row.fix, openMechanicWindow, false)
	end

	if not isLocked then
		local vx,vy,vz = getElementVelocity(vehicle)
		if vx < 0.05 and vy < 0.05 and vz < 0.05 and not getPedOccupiedVehicle(localPlayer) and not isVehicleLocked(vehicle) then -- completely stopped
			local trailers = { [606] = true, [607] = true, [610] = true, [590] = true, [569] = true, [611] = true, [584] = true, [608] = true, [435] = true, [450] = true, [591] = true }
			if trailers[ getElementModel( vehicle ) ] then
				if exports.global:hasItem(localPlayer, 3, getElementData(vehicle, "dbid")) then
					row.park = rightclick:addRow("Park")
					addEventHandler("onClientGUIClick", row.park, parkTrailer, false)
				else
					local vehicleFactionID = getElementData(vehicle, "faction")
					if exports.factions:hasMemberPermissionTo(localPlayer, vehicleFactionID, "respawn_vehs") then
						row.park = rightclick:addRow("Park")
						addEventHandler("onClientGUIClick", row.park, factionParkTrailer, false)
					else
						trailerAdminPark = true
					end
				end
			else
				if exports.global:hasItem(localPlayer, 57) then -- FUEL CAN
					row.fill = rightclick:addRow("Fill Tank")
					addEventHandler("onClientGUIClick", row.fill, fillFuelTank, false)
				end
			end
		end
	end

	if (getElementModel(vehicle)==497) or (getElementModel(vehicle)==469) then -- HELICOPTER
		local players = getElementData(vehicle, "players")
		local found = false

		if (players) then
			for key, value in ipairs(players) do
				if (value==localPlayer) then
					found = true
				end
			end
		end

		if not (found) then
			row.sit = rightclick:addRow("Sit")
			addEventHandler("onClientGUIClick", row.sit, sitInHelicopter, false)
		else
			row.sit = rightclick:addRow("Stand Up")
			addEventHandler("onClientGUIClick", row.sit, unsitInHelicopter, false)
		end
	end

	local entrance = getElementData( vehicle, "entrance" )
	if entrance then
		if not isPedInVehicle(localPlayer) then
			row.enter = rightclick:addRow("Enter Interior")
			addEventHandler("onClientGUIClick", row.enter, enterInterior, false)

			row.knock = rightclick:addRow("Knock on Door")
			addEventHandler("onClientGUIClick", row.knock, knockVehicle, false)
		elseif getElementModel(vehicle) == 435 then
			row.enter = rightclick:addRow("Enter Interior with Vehicle")
			addEventHandler("onClientGUIClick", row.enter, enterInterior, false)
		end
	end

	local seat = -1
	if vehicle == getPedOccupiedVehicle(localPlayer) then
		for i = 0, (getVehicleMaxPassengers(vehicle) or 0) do
			if getVehicleOccupant(vehicle, i) == localPlayer then
				seat = i
				break
			end
		end
	end
	if #getDoorsFor(getElementModel(vehicle), seat) > 0 then -- Now showing this outside of the check because people were abusing it to get away from the alarm.
		row.doorControl = rightclick:addRow("Door Control")
		addEventHandler("onClientGUIClick", row.doorControl, function(button, state) fDoorControl(button, state, isLocked) end, false)
	end

	if not isLocked then
		if (getVehicleType(vehicle) == "Trailer" or getVehicleNameFromModel( 608 ) == getVehicleName( vehicle )) then -- this is a trailer, zomg. But getVehicleType returns "" CLIENT-SIDE. Fine on the server.
			row.handbrake = rightclick:addRow("Handbrake")
			addEventHandler("onClientGUIClick", row.handbrake, handbrakeVehicle, false)
		end

		if (getElementModel(vehicle) == 416) or (getElementModel(vehicle) == 482 and getElementData(vehicle, "faction") == 147) then --Stretcher for ambulance and Dinoco (red rose funeral home).
			row.stretcher = rightclick:addRow("Stretcher")
			addEventHandler("onClientGUIClick", row.stretcher, fStretcher, false)
		elseif(getElementModel(vehicle) == 487 and getElementData(vehicle, "faction") == 2 or getElementModel(vehicle) == 417 and getElementData(vehicle, "faction") == 2) then --air ambulance and SAR heli
			row.stretcher = rightclick:addRow("Stretcher")
			addEventHandler("onClientGUIClick", row.stretcher, fStretcher, false)
		end

		if ( getPedSimplestTask(localPlayer) == "TASK_SIMPLE_CAR_DRIVE" and getPedOccupiedVehicle(localPlayer) == vehicle ) then
			if (getElementData(vehicle, "dbid") > 0 ) then
				row.look = rightclick:addRow("Edit Description")
				addEventHandler("onClientGUIClick", row.look, fLook, false)
			end
		end
	end

	--admin stuff (Exciter)
	if (exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerSupporter(localPlayer) or exports.integration:isPlayerScripter(localPlayer)) then
		if exports.global:isStaffOnDuty(localPlayer) then
			if trailerAdminPark then
				row.park = rightclick:addRow("ADM: Park")
				addEventHandler("onClientGUIClick", row.park, parkTrailer, false)
			end

			row.respawn = rightclick:addRow("ADM: Respawn")
			addEventHandler("onClientGUIClick", row.respawn, fRespawn, false)

			if (exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerScripter(localPlayer)) then
				row.textures = rightclick:addRow("ADM: Textures")
				addEventHandler("onClientGUIClick", row.textures, fTextures, false)
			end
		end
	end

	row.textures = rightclick:addRow("Preview Texture")
	addEventHandler("onClientGUIClick", row.textures, pTextures, false)
	
	if (getElementModel(vehicle) == 544) and not getPedOccupiedVehicle(localPlayer) then
		row.ladderTruck = rightclick:addRow("Climb ladder truck")
		addEventHandler("onClientGUIClick", row.ladderTruck, fLadder, false)
	end
end

function lockUnlock(button, state)
	if (button=="left") then
		if getPedSimplestTask(localPlayer) == "TASK_SIMPLE_CAR_DRIVE" and getPedOccupiedVehicle(localPlayer) == vehicle then
			triggerServerEvent("lockUnlockInsideVehicle", localPlayer, vehicle)
		elseif exports.global:hasItem(localPlayer, 3, getElementData(vehicle, "dbid")) or (exports.factions:isPlayerInFaction(localPlayer, getElementData(vehicle, "faction"))) then
			triggerServerEvent("lockUnlockOutsideVehicle", localPlayer, vehicle)
		end
	end
end

function fStretcher(button, state)
	if (button=="left") then
		if not (isVehicleLocked(vehicle)) then
			triggerServerEvent("stretcher:createStretcher", getLocalPlayer(), false, vehicle)
		end
	end
end

function fLook(button, state)
	if (button=="left") then
		triggerEvent("editdescription", getLocalPlayer())
	end
end

function fDoorControl(button, state, locked)
	if (button=="left") and (not locked) then
		openVehicleDoorGUI( vehicle )
	elseif locked then
		outputChatBox("This vehicle is locked.", 255, 0, 0)
	end
end

function parkTrailer(button, state)
	if (button=="left") then
		triggerServerEvent("parkVehicle", localPlayer, vehicle)
	end
end
function factionParkTrailer(button, state)
	if (button=="left") then
		triggerServerEvent("fparkVehicle", localPlayer, localPlayer, false, vehicle)
	end
end

function fillFuelTank(button, state)
	if (button=="left") then
		local _,_, value = exports.global:hasItem(localPlayer, 57)
		if value > 0 then
			triggerServerEvent("fillFuelTankVehicle", localPlayer, vehicle)
		else
			outputChatBox("This fuel can is empty...", 255, 0, 0)
		end
	end
end

function openMechanicWindow(button, state)
	if (button=="left") then
		triggerEvent("openMechanicFixWindow", localPlayer, vehicle)
	end
end

function toggleRamp(button)
	if (button=="left") then
		triggerServerEvent("vehicle:control:ramp", localPlayer, vehicle)
	end
end

function sitInHelicopter(button, state)
	if (button=="left") then
		triggerServerEvent("sitInHelicopter", localPlayer, vehicle)
	end
end

function unsitInHelicopter(button, state)
	if (button=="left") then
		triggerServerEvent("unsitInHelicopter", localPlayer, vehicle)
	end
end

function enterInterior()
	triggerServerEvent( "enterVehicleInterior", getLocalPlayer(), vehicle )
end

function knockVehicle()
	triggerServerEvent("onVehicleKnocking", getLocalPlayer(), vehicle)
end

function handbrakeVehicle()
	triggerServerEvent("vehicle:handbrake", vehicle)
end

function cabrioletToggleRoof()
	triggerServerEvent("vehicle:toggleRoof", getLocalPlayer(), vehicle)
end

function fRespawn()
	triggerServerEvent("vehicle-manager:respawn", getLocalPlayer(), vehicle)
end

function fTextures()
	triggerEvent("item-texture:vehtex", localPlayer, vehicle)
end

function pTextures()
    triggerEvent("item-texture:previewVehTex", localPlayer, vehicle) 
end

function fLadder(button, state)
	if (button=="left") then
		local vx, vy, vz = getElementPosition(vehicle)
		setElementPosition(localPlayer, vx, vy-4, vz+1.55)
	end
end