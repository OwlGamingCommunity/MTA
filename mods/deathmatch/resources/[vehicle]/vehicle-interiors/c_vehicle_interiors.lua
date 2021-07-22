function useVehicleInterior(key, keyState, vehicle)
	--outputDebugString("useVehicleInterior()")
	--if(key == "f" and keyState == "down") then
		unbindKey("enter_exit", "down", useVehicleInterior)
		--unbindKey("space", "down", useVehicleInterior)
		hideIntName()
		--outputDebugString("useVehicleInterior() ok")
		triggerServerEvent("enterVehicleInterior", getLocalPlayer(), vehicle)
		cancelEvent()
	--end
end

function vehInteriorGUI()
	--outputDebugString("vehInteriorGUI()")
	if (isElement(gInteriorName) and guiGetVisible(gInteriorName)) then
		if isTimer(timer) then
			killTimer(timer)
			timer = nil
		end

		destroyElement(gInteriorName)
		gInteriorName = nil

		--destroyElement(gOwnerName)
		--gOwnerName = nil

		unbindKey("enter_exit", "down", useVehicleInterior)
		--unbindKey("space", "down", useVehicleInterior)
	end
	local px,py,pz = getElementPosition(getLocalPlayer())
	local x,y,z = getElementPosition(source)

	gInteriorName = guiCreateLabel(0.0, 0.85, 1.0, 0.3, tostring(getVehiclePlateText(source)), true)
	guiSetFont(gInteriorName, "sa-header")
	guiLabelSetHorizontalAlign(gInteriorName, "center", true)
	guiSetAlpha(gInteriorName, 0.0)

	--gOwnerName = guiCreateLabel(0.0, 0.90, 1.0, 0.3, "Press SPACE to enter "..tostring(getVehicleName(source)), true)
	--guiSetFont(gOwnerName, "default-bold-small")
	--guiLabelSetHorizontalAlign(gOwnerName, "center", true)
	--guiSetAlpha(gOwnerName, 0.0)

	timer = setTimer(fadeMessage, 50, 20, true)

	--outputDebugString("source: "..tostring(source))
	local result = bindKey("enter_exit", "down", useVehicleInterior, source)
	--outputDebugString("bind key = "..tostring(result))
	--bindKey("space", "down", useVehicleInterior, source)
end
addEvent("vehicle-interiors:showInteriorGUI", true)
addEventHandler("vehicle-interiors:showInteriorGUI", getRootElement(), vehInteriorGUI)
function hideVehInteriorGUI()
	--outputDebugString("unbound")
	unbindKey("enter_exit", "down", useVehicleInterior)
	--unbindKey("space", "down", useVehicleInterior)
	hideIntName()
end
addEvent("vehicle-interiors:hideInteriorGUI", true)
addEventHandler("vehicle-interiors:hideInteriorGUI", getRootElement(), hideVehInteriorGUI)


function changeTexture(model)
	--outputDebugString("applying texture ("..tostring(model)..")")
	if(model == 577) then --AT-400
		local txd = engineLoadTXD("files/at400_interior.txd")
		engineImportTXD(txd,14548)
	elseif(model == 592) then --Andromada
		--restore
		local txd = engineLoadTXD("files/ab_cargo_int.txd")
		engineImportTXD(txd,14548)
	else
		--restore
		local txd = engineLoadTXD("files/ab_cargo_int.txd")
		engineImportTXD(txd,14548)
	end
end
addEvent("vehicle-interiors:changeTextures", true)
addEventHandler("vehicle-interiors:changeTextures", getRootElement(), changeTexture)

function fadeMessage(fadein)
	if gInteriorName then
		local alpha = guiGetAlpha(gInteriorName)

		if (fadein) and (alpha) then
			local newalpha = alpha + 0.05
			guiSetAlpha(gInteriorName, newalpha)
			--guiSetAlpha(gOwnerName, newalpha)

			if(newalpha>=1.0) then
				timer = setTimer(hideIntName, 4000, 1)
			end
		elseif (alpha) then
			local newalpha = alpha - 0.05
			guiSetAlpha(gInteriorName, newalpha)
			--guiSetAlpha(gOwnerName, newalpha)

			if (gBuyMessage) then
				guiSetAlpha(gBuyMessage, newalpha)
			end

			if(newalpha<=0.0) then
				destroyElement(gInteriorName)
				gInteriorName = nil

				--destroyElement(gOwnerName)
				--gOwnerName = nil
			end
		end
	end
end

function hideIntName()
	setTimer(fadeMessage, 50, 20, false)
end

function getPositionFromElementOffset() -- This is for /windows !
	if getElementData(localPlayer, "isInWindow") == false then
		local dim = getElementDimension(localPlayer)
		local id = dim - 20000 -- Because vehicle interiors are 20000 + vehicle ID
		local vehicle = nil
		for k,v in ipairs(getElementsByType("vehicle")) do -- Find vehicle element with ID, client side
		  if tonumber(getElementData(v, "dbid")) == tonumber(id) then
		    vehicle = v
		    break
		  end
		end
		local offX, offY, offZ = getElementPosition(vehicle)
		local m = getElementMatrix ( vehicle )  -- Get the matrix
		local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1] -- Apply transform
		local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
		local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
		--outputDebugString("CLIENT x "..x.." y "..y.." z "..z)
		triggerServerEvent("seeThroughWindows", getRootElement(), localPlayer, x, y, z) -- Return the transformed point

		addEventHandler("onClientRender", getRootElement(), function ()
				if getElementData(localPlayer, "isInWindow") == true then
					triggerServerEvent("updateWindowsView", getRootElement(), localPlayer)
				end
			end )
	else
		triggerServerEvent("seeThroughWindows", getRootElement(), localPlayer)
	end
end

function tempDisable(thePlayer)
	outputChatBox("This command has been temporarly disabled by a scripter.", thePlayer)
end
addCommandHandler("windows", tempDisable)
