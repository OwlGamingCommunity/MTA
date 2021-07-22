local vControlGUI = { }
local controllingVehicle = nil
-- For vehs that need a higher distance for this
local tallVeh = {[577] = 25}
local vTimers = { }

function openVehicleDoorGUI( vehicleElement )
	if vControlGUI["main"] then
		closeVehicleGUI()
		return
	end

	if not vehicleElement then
		controllingVehicle = getPedOccupiedVehicle ( getLocalPlayer() )
	else
		controllingVehicle = vehicleElement
		if controllingVehicle ~= getPedOccupiedVehicle( getLocalPlayer() ) then
			local vehicle1x, vehicle1y, vehicle1z = getElementPosition ( controllingVehicle )
			local player1x, player1y, player1z = getElementPosition ( getLocalPlayer() )

			if getDistanceBetweenPoints3D ( vehicle1x, vehicle1y, vehicle1z, player1x, player1y, player1z ) > (tallVeh[getElementModel(controllingVehicle)] or 5) then
				return
			end
		end
	end

	local playerSeat = -1
	for checkingSeat = 0, ( getVehicleMaxPassengers ( controllingVehicle ) or 0 ) do
		if getVehicleOccupant( controllingVehicle, checkingSeat ) == localPlayer then
			playerSeat = checkingSeat
			break
		end
	end

	local doors = getDoorsFor(getElementModel(controllingVehicle), playerSeat)
	if #doors == 0 then
		return
	end

	local options = 0
	local guiPos = 30
	vControlGUI["main"] = guiCreateWindow(700,236,272,288,"Vehicle Control",false)
	for index, doorEntry in ipairs(doors) do
		vControlGUI["scroll"..index] = guiCreateScrollBar(24,guiPos + 17,225,17,true,false,vControlGUI["main"])
		vControlGUI["label"..index] = guiCreateLabel(30,guiPos,135,15,doorEntry[1],false,vControlGUI["main"])
		guiSetFont(vControlGUI["label"..index] ,"default-bold-small")
		setElementData(vControlGUI["scroll"..index], "vehicle:doorcontrol:panel", doorEntry[2], false)
		addEventHandler ( "onClientGUIScroll",vControlGUI["scroll"..index], startTimerUpdateServerSide, false )
		guiPos = guiPos + 40

		local currentDoorPos = getVehicleDoorOpenRatio ( controllingVehicle, doorEntry[2] )
		if currentDoorPos then
			currentDoorPos = currentDoorPos * 100
			guiScrollBarSetScrollPosition (vControlGUI["scroll"..index], currentDoorPos )
		end
	end

	guiSetSize(vControlGUI["main"],272,guiPos+40, false)
	vControlGUI["close"] = guiCreateButton(23,guiPos,230,14,"Close",false, vControlGUI["main"])
	addEventHandler ( "onClientGUIClick", vControlGUI["close"], closeVehicleGUI, false )
end
addCommandHandler("doors", openVehicleDoorGUI)

function closeVehicleGUI()
	if vControlGUI["main"] then
		destroyElement(vControlGUI["main"] )
		vControlGUI = { }
		controllingVehicle = nil
	end
end
addEventHandler("onClientPlayerVehicleExit", getLocalPlayer(), closeVehicleGUI)

function startTimerUpdateServerSide(theScrollBar)
	if vControlGUI["main"] then
		local door = getElementData(theScrollBar, "vehicle:doorcontrol:panel")
		if not door then
			return -- Not our element
		end

		if vTimers[theScrollBar] then
			return -- Already running a timer
		end

		vTimers[theScrollBar] = setTimer(updateServerSide, 400, 1, theScrollBar)
	end
end

function updateServerSide(theScrollBar, state)
	if vControlGUI["main"] then -- and state == "up" then

		local door = getElementData(theScrollBar, "vehicle:doorcontrol:panel")
		if not door then
			return
		end

		vehicle1x, vehicle1y, vehicle1z = getElementPosition ( controllingVehicle )
		player1x, player1y, player1z = getElementPosition ( getLocalPlayer() )
		if not (getPedOccupiedVehicle ( getLocalPlayer() ) == controllingVehicle) and not (getDistanceBetweenPoints3D ( vehicle1x, vehicle1y, vehicle1z, player1x, player1y, player1z ) < 5) then
			closeVehicleGUI()
			return
		end

		if (isVehicleLocked(controllingVehicle)) then
			return
		end


		local position = guiScrollBarGetScrollPosition(theScrollBar)
		triggerServerEvent("vehicle:control:doors", controllingVehicle, door, position)

		vTimers[theScrollBar] = nil
	end
end
