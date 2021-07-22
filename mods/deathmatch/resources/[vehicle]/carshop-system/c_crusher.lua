local window = nil

local screenWidth, screenHeight = guiGetScreenSize()
local windowWidth, windowHeight = 350, 170
local left = screenWidth/2 - windowWidth/2
local top = screenHeight - windowHeight * 1.1

local function closeWindow()
	if window then
		destroyElement(window)
		window = nil

		setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
	end
end

addEvent('crusher:show', true)
addEventHandler('crusher:show', root,
	function(price)
		local vehicle = source
		if getElementData(getLocalPlayer(), "exclusiveGUI") then
			return false
		end

		closeWindow()
		if source == localPlayer then
			return false
		end

		setElementData(getLocalPlayer(), "exclusiveGUI", true, false)

		window = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)
		guiCreateLabel(20, 15, windowWidth - 40, 16, 'We are about to crush your vehicle (( delete ))!', false, window)
		guiSetFont(guiCreateLabel(40, 40, windowWidth - 40, 16, exports.global:getVehicleName(source), false, window), 'default-bold-small')
		guiSetFont(guiCreateLabel(40, 65, windowWidth - 40, 16, 'VIN: ' .. tostring(getElementData(source, 'dbid')), false, window), 'default-bold-small')
		guiSetFont(guiCreateLabel(40, 90, windowWidth - 40, 16, 'For $' .. exports.global:formatMoney(price), false, window), 'default-bold-small')

		local accept = guiCreateButton(10, 110, windowWidth / 2 - 15, 40, "Yes, crush it please!", false, window)
		guiSetProperty(accept, 'NormalTextColour', 'FFFF0000')
		guiSetProperty(accept, 'HoverTextColour', 'FFFF0000')
		addEventHandler('onClientGUIClick', accept,
			function()
				closeWindow()
				if getPedOccupiedVehicle(localPlayer) == vehicle and getVehicleOccupant(vehicle) == localPlayer then
					triggerServerEvent('crusher:delete', vehicle)
				end
			end, false)

		local nope = guiCreateButton(windowWidth / 2 + 5, 110, windowWidth / 2 - 15, 40, "No, I want to keep my vehicle.", false, window)
		addEventHandler('onClientGUIClick', nope, closeWindow, false)
	end)

addEvent('crusher:hide', true)
--addEventHandler('crusher:hide', localPlayer, closeWindow)

addEventHandler('onClientColShapeLeave', resourceRoot, closeWindow)
addEventHandler("account:changingchar", root, closeWindow )
addEventHandler("onClientChangeChar", root, closeWindow)
