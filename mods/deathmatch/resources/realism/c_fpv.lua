--cameramodes
--key = index, value = cameramode id where -1 is first person
local viewModes = {}
viewModes[0] = 0  --bumper
viewModes[1] = -1 --first person
viewModes[2] = 1  --close external
viewModes[3] = 2  --middle external
viewModes[4] = 3  --far external
viewModes[5] = 5  --cinematic


--internal settings
local currentCamera = 3
local cameraKeys = getBoundKeys("change_camera")
local fpOn = false
local localVehicle
local isPedEnteringVehicle
setCameraViewMode(viewModes[currentCamera])

--function that runs before every frame
addEventHandler("onClientPreRender",root,
  function()

    --checks for unexpected situations
    if (isPedEnteringVehicle) then
      if (not getPedOccupiedVehicle) then
        isPedEnteringVehicle = false
      end
      if (not localVehicle) then
        localVehicle = getPedOccupiedVehicle(localPlayer)
      end
    end
    if (getPedOccupiedVehicle(localPlayer)) then
      if (localVehicle ~= getPedOccupiedVehicle(localPlayer) and not isPedEnteringVehicle) then
        localVehicle = getPedOccupiedVehicle(localPlayer)
      end
      if (viewModes[currentCamera] == -1 and not fpOn) then
        fpOn = true
      end
    else
      if (localVehicle) then
        localVehicle = false
      end
    end


    --actual camera

    --if fp is enabled
    if (fpOn and localVehicle) then
		if getPedControlState(localPlayer, "vehicle_look_left") or getPedControlState(localPlayer, "vehicle_look_right") then
			return setCameraTarget (localPlayer)
		end
		--get positions
		local bx,by,bz = getPedBonePosition(localPlayer,6)
		local vm = getElementMatrix(localVehicle)
		local rotx,roty,rotz = getElementRotation(localVehicle)

		--set camera to bone positions, looking forwards
		setCameraMatrix(bx,by,bz,bx+vm[2][1],by+vm[2][2],bz+vm[2][3])
	end
  end
)


--listen to key input
addEventHandler("onClientKey",root,
  function(btn,pressed)

    --if the chatbox is not active
    if (not isChatBoxInputActive()) and not isCursorShowing() then

      --if the pressed key is camera
      if (cameraKeys[btn]) then

        --if the user is in a vehicle, not entering it and key was not released
        if (localVehicle and not isPedEnteringVehicle and pressed) then

          --cancel gta camera
          cancelEvent()

          if guiGetInputMode() ~= "allow_binds" then
             return
          end

          --update camera setting
          if (currentCamera == 0) then
            currentCamera = #viewModes
          else
            currentCamera = currentCamera - 1
          end

          --if the camera view is not first person, change normally
          if (viewModes[currentCamera] ~= -1) then

            --if previous camera was first person, reset camera
            if (viewModes[currentCamera+1] == -1) then
              fpOn = false
              setCameraTarget(localPlayer)
            end

            --set updated camera mode
            setCameraViewMode(viewModes[currentCamera])

          --otherwise activate first person view
          else

            --enable first person
            fpOn = true
          end
        end
      end
    end
  end
)


--when the player enters a vehicle
addEventHandler("onClientVehicleEnter",root,
  function(player)
    if (player == localPlayer) then

      --update internal vars
      localVehicle = getPedOccupiedVehicle(localPlayer)
      isPedEnteringVehicle = false

      --if camera setting is first person, enable
      if (viewModes[currentCamera] == -1) then
        fpOn = true
      end
    end
  end
)


--when the player starts entering a vehicle
addEventHandler("onClientVehicleStartEnter",root,
  function(player)
    if (player == localPlayer) then

      --update internal vars
      isPedEnteringVehicle = true
    end
  end
)


--when the player exits a vehicle
addEventHandler("onClientVehicleExit",root,
  function(player)
    if (player == localPlayer) then
      if (fpOn) then

        --update internal vars
        fpOn = false
        setCameraTarget(localPlayer)
        localVehicle = nil
      end
    end
  end
)
