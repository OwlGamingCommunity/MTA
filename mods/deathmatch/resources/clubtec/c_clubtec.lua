--clubtec
--Script that adds functionality for a range of items
--Created by Exciter, 23.06.2014 (DD.MM.YYYY).

--exports
global = exports.global
integration = exports.integration

--define vars
resourceRoot = getResourceRootElement(getThisResource())
root = getRootElement()
localPlayer = getLocalPlayer()

GUIEditor = {
    staticimage = {},
    edit = {},
    button = {},
    window = {},
    scrollbar = {},
    label = {}
}

function destroyGui()
	for k,v in ipairs(GUIEditor.window) do
		if isElement(v) then
			destroyElement(v)
		end
	end
	GUIEditor = {
	    staticimage = {},
	    edit = {},
	    button = {},
	    window = {},
	    scrollbar = {},
	    label = {}
	}
end

function vs1000_gui(element, data, shaderData, videoData, powerOn)
	if GUIEditor.window[1] then destroyGui() end

	vs1000_element = element

	GUIEditor.window[1] = guiCreateWindow(223, 185, 324, 503, "ClubTec VS1000 Control Panel", false)
	guiWindowSetSizable(GUIEditor.window[1], false)

	local discTitle
	local discMeta
	local hasDisc = false
	if data.video and data.video > 1 then
		hasDisc = true
	end
	if hasDisc and videoData then
		discTitle = tostring(videoData.name)
		discMeta = "Created by "..tostring(videoData.creator)..", "..tostring(videoData.date):sub(1, 10)
	else
		discTitle = "No Disc"
		discMeta = " "
	end

	currentPowerState = powerOn

	GUIEditor.staticimage[1] = guiCreateStaticImage(12, 24, 300, 80, "img/vs1000_guihead.png", false, GUIEditor.window[1])
	GUIEditor.label[1] = guiCreateLabel(11, 111, 301, 17, "DISC", false, GUIEditor.window[1])
	guiSetFont(GUIEditor.label[1], "default-bold-small")
	GUIEditor.label[2] = guiCreateLabel(11, 128, 301, 17, discTitle, false, GUIEditor.window[1])
	GUIEditor.label[3] = guiCreateLabel(11, 145, 301, 17, discMeta, false, GUIEditor.window[1])
	GUIEditor.button[4] = guiCreateButton(11, 165, 139, 26, powerOn and "Power Off" or "Power On", false, GUIEditor.window[1])
	GUIEditor.button[1] = guiCreateButton(168, 165, 139, 26, "Eject Disc", false, GUIEditor.window[1])
	GUIEditor.label[4] = guiCreateLabel(11, 196, 301, 17, "ADJUSTMENTS", false, GUIEditor.window[1])
	guiSetFont(GUIEditor.label[4], "default-bold-small")
	
	--if isClubtecGuy(localPlayer) then
		GUIEditor.label[5] = guiCreateLabel(11, 213, 144, 17, "Brightness", false, GUIEditor.window[1])
		GUIEditor.label[6] = guiCreateLabel(11, 420, 301, 17, "Texture", false, GUIEditor.window[1])
		GUIEditor.label[7] = guiCreateLabel(11, 248, 144, 17, "Scroll X", false, GUIEditor.window[1])
		GUIEditor.label[8] = guiCreateLabel(11, 281, 144, 17, "Scroll Y", false, GUIEditor.window[1])
		GUIEditor.label[9] = guiCreateLabel(11, 314, 144, 17, "XScale", false, GUIEditor.window[1])
		GUIEditor.label[10] = guiCreateLabel(11, 346, 144, 17, "YScale", false, GUIEditor.window[1])
		--GUIEditor.label[11] = guiCreateLabel(11, 383, 55, 17, "RotAngle", false, GUIEditor.window[1])
		GUIEditor.edit[1] = guiCreateEdit(14, 436, 298, 25, tostring(data.texture), false, GUIEditor.window[1]) --w298
		--GUIEditor.edit[2] = guiCreateEdit(68, 381, 45, 21, tostring(shaderData.rotAngle), false, GUIEditor.window[1])
		GUIEditor.edit[3] = guiCreateEdit(14, 363, 144, 21, tostring(shaderData.yScale), false, GUIEditor.window[1])
		GUIEditor.edit[4] = guiCreateEdit(14, 328, 144, 21, tostring(shaderData.xScale), false, GUIEditor.window[1])
		GUIEditor.edit[5] = guiCreateEdit(14, 296, 144, 21, tostring(shaderData.scrollY), false, GUIEditor.window[1])
		GUIEditor.edit[6] = guiCreateEdit(14, 263, 144, 21, tostring(shaderData.scrollX), false, GUIEditor.window[1])
		GUIEditor.edit[7] = guiCreateEdit(14, 229, 144, 21, tostring(shaderData.brightness), false, GUIEditor.window[1])
		
		GUIEditor.label[12] = guiCreateLabel(163, 346, 144, 17, "yOffset", false, GUIEditor.window[1])
		GUIEditor.edit[8] = guiCreateEdit(163, 363, 144, 21, tostring(shaderData.yOffset), false, GUIEditor.window[1])
		
		GUIEditor.label[13] = guiCreateLabel(163, 314, 144, 17, "xOffset", false, GUIEditor.window[1])
		GUIEditor.edit[9] = guiCreateEdit(163, 328, 144, 21, tostring(shaderData.xOffset), false, GUIEditor.window[1])
		
		GUIEditor.label[14] = guiCreateLabel(259, 281, 48, 17, "Blue", false, GUIEditor.window[1])
		GUIEditor.edit[10] = guiCreateEdit(259, 296, 48, 21, tostring(shaderData.bluColor), false, GUIEditor.window[1])

		GUIEditor.label[15] = guiCreateLabel(211, 281, 48, 17, "Green", false, GUIEditor.window[1])
		GUIEditor.edit[11] = guiCreateEdit(211, 296, 48, 21, tostring(shaderData.grnColor), false, GUIEditor.window[1])

		GUIEditor.label[16] = guiCreateLabel(163, 281, 48, 17, "Red", false, GUIEditor.window[1])
		GUIEditor.edit[12] = guiCreateEdit(163, 296, 48, 21, tostring(shaderData.redColor), false, GUIEditor.window[1])
		
		GUIEditor.label[17] = guiCreateLabel(163, 248, 144, 17, "grayScale", false, GUIEditor.window[1])
		GUIEditor.edit[13] = guiCreateEdit(163, 263, 144, 21, tostring(shaderData.grayScale), false, GUIEditor.window[1])

		GUIEditor.label[18] = guiCreateLabel(163, 213, 144, 17, "Alpha", false, GUIEditor.window[1])
		GUIEditor.edit[14] = guiCreateEdit(163, 229, 144, 21, tostring(shaderData.alpha), false, GUIEditor.window[1])

		GUIEditor.label[11] = guiCreateLabel(11, 382, 144, 17, "RotAngle", false, GUIEditor.window[1])
		GUIEditor.edit[2] = guiCreateEdit(14, 397, 144, 21, tostring(shaderData.rotAngle), false, GUIEditor.window[1])

		GUIEditor.label[19] = guiCreateLabel(163, 382, 144, 17, "Speed", false, GUIEditor.window[1])
		GUIEditor.edit[16] = guiCreateEdit(163, 397, 123, 21, tostring(shaderData.speed or "[auto]"), false, GUIEditor.window[1])
		GUIEditor.button[5] = guiCreateButton(286, 395, 21, 21, "A", false, GUIEditor.window[1])
		addEventHandler("onClientGUIClick", GUIEditor.button[5],  function (button, state)
			guiSetText(GUIEditor.edit[16], "[auto]")
		end, false)

	--else
	--	GUIEditor.label[5] = guiCreateLabel(11, 213, 301, 17, "Contact a ClubTec technician.", false, GUIEditor.window[1])
	--end

	GUIEditor.button[3] = guiCreateButton(11, 468, 139, 26, "Save", false, GUIEditor.window[1]) 
	GUIEditor.button[2] = guiCreateButton(174, 468, 139, 26, "Save & Close", false, GUIEditor.window[1]) 
	

	--[[ The improved future version. To be finished later.
	GUIEditor.staticimage[1] = guiCreateStaticImage(12, 24, 300, 80, ":clubtec/img/vs1000_guihead.png", false, GUIEditor.window[1])
	GUIEditor.label[1] = guiCreateLabel(11, 111, 301, 17, "DISC", false, GUIEditor.window[1])
	guiSetFont(GUIEditor.label[1], "default-bold-small")
	GUIEditor.label[2] = guiCreateLabel(11, 128, 301, 17, "No Disc", false, GUIEditor.window[1])
	GUIEditor.label[3] = guiCreateLabel(11, 145, 301, 17, "Created by Exciter, 2014-06-23 00:00:00", false, GUIEditor.window[1])
	GUIEditor.button[1] = guiCreateButton(92, 165, 139, 26, "Eject", false, GUIEditor.window[1])
	GUIEditor.label[4] = guiCreateLabel(11, 196, 301, 17, "ADJUSTMENTS", false, GUIEditor.window[1])
	guiSetFont(GUIEditor.label[4], "default-bold-small")
	GUIEditor.label[5] = guiCreateLabel(11, 213, 301, 17, "Brightness", false, GUIEditor.window[1])
	GUIEditor.scrollbar[1] = guiCreateScrollBar(11, 232, 235, 15, true, false, GUIEditor.window[1])
	GUIEditor.label[6] = guiCreateLabel(249, 230, 63, 17, "+10.24", false, GUIEditor.window[1])
	GUIEditor.button[2] = guiCreateButton(174, 447, 139, 26, "Save & Close", false, GUIEditor.window[1])
	GUIEditor.edit[1] = guiCreateEdit(14, 420, 298, 25, "tex_rodeo01_sign", false, GUIEditor.window[1])
	GUIEditor.label[7] = guiCreateLabel(11, 404, 301, 17, "Texture", false, GUIEditor.window[1])
	GUIEditor.label[8] = guiCreateLabel(11, 248, 301, 17, "Scroll X", false, GUIEditor.window[1])
	GUIEditor.scrollbar[2] = guiCreateScrollBar(11, 266, 235, 15, true, false, GUIEditor.window[1])
	GUIEditor.label[9] = guiCreateLabel(11, 281, 301, 17, "Scroll Y", false, GUIEditor.window[1])
	GUIEditor.scrollbar[3] = guiCreateScrollBar(11, 299, 235, 15, true, false, GUIEditor.window[1])
	GUIEditor.label[10] = guiCreateLabel(11, 314, 301, 17, "HScale", false, GUIEditor.window[1])
	GUIEditor.scrollbar[4] = guiCreateScrollBar(11, 331, 235, 15, true, false, GUIEditor.window[1])
	guiScrollBarSetScrollPosition(GUIEditor.scrollbar[4], 100.0)
	GUIEditor.label[11] = guiCreateLabel(11, 346, 301, 17, "VScale", false, GUIEditor.window[1])
	GUIEditor.scrollbar[5] = guiCreateScrollBar(11, 364, 235, 15, true, false, GUIEditor.window[1])
	guiScrollBarSetScrollPosition(GUIEditor.scrollbar[5], 100.0)
	GUIEditor.label[12] = guiCreateLabel(11, 383, 55, 17, "RotAngle", false, GUIEditor.window[1])
	GUIEditor.edit[2] = guiCreateEdit(68, 381, 45, 21, "360", false, GUIEditor.window[1])
	--]]

	if not hasDisc then
		guiSetEnabled(GUIEditor.button[1], false)
	end

	addEventHandler("onClientGUIClick", GUIEditor.button[1], function (button, state)
		if source ~= GUIEditor.button[1] then return end
		guiSetText(GUIEditor.label[2], "No Disc")
		guiSetText(GUIEditor.label[3], " ")
		guiSetEnabled(GUIEditor.button[1], false)
		triggerServerEvent("clubtec:vs1000:ejectDisc", resourceRoot, vs1000_element, currentPowerState)
	end, false)
	addEventHandler("onClientGUIClick", GUIEditor.button[4], function (button, state)
		if source ~= GUIEditor.button[4] then return end
		newPowerState = not currentPowerState
		triggerServerEvent("clubtec:vs1000:togglePower", resourceRoot, vs1000_element, newPowerState)
		guiSetText(GUIEditor.button[4], newPowerState and "Power Off" or "Power On")
		currentPowerState = newPowerState
	end, false)
	addEventHandler("onClientGUIClick", GUIEditor.button[2], vs1000_process, false)
	addEventHandler("onClientGUIClick", GUIEditor.button[3], vs1000_process, false)
	--[[
	addEventHandler("onClientGUIClick", GUIEditor.button[2], function (button, state)
		if source ~= GUIEditor.button[2] and source ~= GUIEditor.button[3] then return end
		if isClubtecGuy(localPlayer) then
			local newBrightness = tonumber(guiGetText(GUIEditor.edit[7]))
			local newScrollX = tonumber(guiGetText(GUIEditor.edit[6]))
			local newScrollY = tonumber(guiGetText(GUIEditor.edit[5]))
			local newXScale = tonumber(guiGetText(GUIEditor.edit[4]))
			local newYScale = tonumber(guiGetText(GUIEditor.edit[3]))
			local newRotAngle = tonumber(guiGetText(GUIEditor.edit[2]))
			local newAlpha = tonumber(guiGetText(GUIEditor.edit[14]))
			local newGray = tonumber(guiGetText(GUIEditor.edit[13]))
			local newRed = tonumber(guiGetText(GUIEditor.edit[12]))
			local newGreen = tonumber(guiGetText(GUIEditor.edit[11]))
			local newBlue = tonumber(guiGetText(GUIEditor.edit[10]))
			local newXOffset = tonumber(guiGetText(GUIEditor.edit[9]))
			local newYOffset = tonumber(guiGetText(GUIEditor.edit[8]))
			local newSpeed = tonumber(guiGetText(GUIEditor.edit[16]))
			if newSpeed == "[auto]" then
				newSpeed = false
			end

			local newTexture = guiGetText(GUIEditor.edit[1])
			local dimension = getElementDimension(vs1000_element)
			local newData = { brightness = newBrightness, scrollX = newScrollX, scrollY = newScrollY, xScale = newXScale, yScale = newYScale, rotAngle = newRotAngle, alpha = newAlpha, grayScale = newGray, redColor = newRed, grnColor = newGreen, bluColor = newBlue, xOffset = newXOffset, yOffset = newYOffset, speed = newSpeed, texture = newTexture }

			triggerServerEvent("clubtec:vs1000:updateSettings", resourceRoot, vs1000_element, newData, currentPowerState)
		end
		if source == GUIEditor.button[2] then
			destroyElement(GUIEditor.window[1])
			destroyGui()
		end
	end, false)
	--]]

	guiSetInputMode("no_binds_when_editing")
end
addEvent("clubtec:vs1000:gui", true)
addEventHandler("clubtec:vs1000:gui", resourceRoot, vs1000_gui)

function vs1000_process()
	if source ~= GUIEditor.button[2] and source ~= GUIEditor.button[3] then return end
	--if isClubtecGuy(localPlayer) then
		local newBrightness = tonumber(guiGetText(GUIEditor.edit[7]))
		local newScrollX = tonumber(guiGetText(GUIEditor.edit[6]))
		local newScrollY = tonumber(guiGetText(GUIEditor.edit[5]))
		local newXScale = tonumber(guiGetText(GUIEditor.edit[4]))
		local newYScale = tonumber(guiGetText(GUIEditor.edit[3]))
		local newRotAngle = tonumber(guiGetText(GUIEditor.edit[2]))
		local newAlpha = tonumber(guiGetText(GUIEditor.edit[14]))
		local newGray = tonumber(guiGetText(GUIEditor.edit[13]))
		local newRed = tonumber(guiGetText(GUIEditor.edit[12]))
		local newGreen = tonumber(guiGetText(GUIEditor.edit[11]))
		local newBlue = tonumber(guiGetText(GUIEditor.edit[10]))
		local newXOffset = tonumber(guiGetText(GUIEditor.edit[9]))
		local newYOffset = tonumber(guiGetText(GUIEditor.edit[8]))
		local newSpeed = tonumber(guiGetText(GUIEditor.edit[16]))
		if newSpeed == "[auto]" then
			newSpeed = false
		end

		local newTexture = guiGetText(GUIEditor.edit[1])
		local dimension = getElementDimension(vs1000_element)
		local newData = { brightness = newBrightness, scrollX = newScrollX, scrollY = newScrollY, xScale = newXScale, yScale = newYScale, rotAngle = newRotAngle, alpha = newAlpha, grayScale = newGray, redColor = newRed, grnColor = newGreen, bluColor = newBlue, xOffset = newXOffset, yOffset = newYOffset, speed = newSpeed, texture = newTexture }

		triggerServerEvent("clubtec:vs1000:updateSettings", resourceRoot, vs1000_element, newData, currentPowerState)
	--end
	if source == GUIEditor.button[2] then
		destroyElement(GUIEditor.window[1])
		destroyGui()
	end
end

function refreshCalls(res)
	global = exports.global
	integration = exports.integration
end
addEventHandler("onClientResourceStart", getRootElement(), refreshCalls)