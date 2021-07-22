function createSpeedcam ()
	if getElementData(localPlayer, "speedradar_chat") == false and not speedcamMeter then
	speedFont = guiCreateFont( "speedcam/digital-7.ttf", 32 )

	speedcamMeter = guiCreateStaticImage(0.75, 0.25, 0.24, 0.17, "speedcam/gps.png", true)
	targetSpeed = guiCreateLabel(0.15, 0.34, 0.21, 0.25, "0", true, speedcamMeter)
	setSpeed = guiCreateLabel(0.40, 0.34, 0.21, 0.25, "", true, speedcamMeter)
	allowedSpeed = guiCreateLabel(0.66, 0.34, 0.21, 0.25, "", true, speedcamMeter)
	vehicleInfo = guiCreateLabel(0, 0.72, 0.8, 0.25, "No info", true, speedcamMeter)
	
	guiSetFont( targetSpeed, speedFont ) 
	guiSetFont( setSpeed, speedFont ) 
	guiSetFont( allowedSpeed, speedFont )
	guiSetFont( vehicleInfo, "default-bold-small")
	
	guiLabelSetColor (targetSpeed, 255, 168, 8)
	guiLabelSetColor (setSpeed, 242, 54, 42)
	guiLabelSetColor (allowedSpeed, 3, 209, 137)
	
	guiLabelSetHorizontalAlign(vehicleInfo, "center")
	
	triggerEvent("getData", localPlayer)
	addEventHandler("onClientRender", root, getAllData)
	end
end
addEvent("speedcamON", true)
addEventHandler("speedcamON", getRootElement(), createSpeedcam)

function getAllData ()
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	local ownSpeedValue = exports.global:getVehicleVelocity(vehicle, getLocalPlayer())
	local setSpeedValue = getElementData(getLocalPlayer(), "speedcamera:setSpeed")
	local setTargetValue = getElementData(getLocalPlayer(), "speedcamera:targetSpeed")
	local vehicleBrand = getElementData(getLocalPlayer(), "speedcamera:vehicleName")
	local vehicleColor = getElementData(getLocalPlayer(), "speedcamera:vehicleColor")
	local vehicleDirection = getElementData(getLocalPlayer(), "speedcamera:vehicleDirection")
	local vehicleTopSpeed = getElementData(getLocalPlayer(), "speedcamera:targetTopSpeed") 
	
	guiSetText(targetSpeed, setTargetValue)
	guiSetText(allowedSpeed, math.floor(ownSpeedValue))
	guiSetText(setSpeed, vehicleTopSpeed)
	guiSetText(vehicleInfo, "" .. string.gsub(vehicleColor, "^%l", vehicleColor.upper) .. " | " .. vehicleBrand .. " | " .. string.gsub(vehicleDirection, "^%l", vehicleDirection.upper))
	
	if getElementData(localPlayer, "speedradar_chat") == "0" then
		triggerEvent("destroyGUI", localPlayer)
	else
		if speedcamMeter == nil then
		triggerEvent("speedcamON", localPlayer)
		end
	end
end
addEvent("getData", true)

function removeAll ()
    if isElement(speedcamMeter) then 
        destroyElement(speedcamMeter)
        speedcamMeter = nil
        removeEventHandler("onClientRender", root, getAllData)
    end
end
addEvent("destroyGUI", true)
addEventHandler("destroyGUI", localPlayer, removeAll)