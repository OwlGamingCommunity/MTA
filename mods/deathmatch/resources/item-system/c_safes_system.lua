local safe = nil
local ax, ay = 0, 0

local function requestInventory(button)
	if button=="left" and not getElementData(localPlayer, "exclusiveGUI") then
		triggerServerEvent( "openFreakinInventory", getLocalPlayer(), safe, ax, ay )
	end
end

function clickSafe(button, state, absX, absY, wx, wy, wz, element)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if element and getElementType( element ) == "object" and button == "right" and state == "down" and getElementModel(element) == 2332 then
		local x, y, z = getElementPosition(localPlayer)
		
		if getDistanceBetweenPoints3D(x, y, z, wx, wy, wz) <= 3 then
			local dimension = getElementDimension(getLocalPlayer())
			if ( dimension < 19000 and ( hasItem(getLocalPlayer(), 5, dimension) or hasItem(getLocalPlayer(), 4, dimension) ) ) or ( dimension >= 20000 and hasItem(getLocalPlayer(), 3, dimension-20000) ) or ((getElementData(getLocalPlayer(),"admin_level") >= 2) and (getElementData(getLocalPlayer(),"duty_admin") == 1 )) then
				showCursor(true)
				ax = absX
				ay = absY
				safe = element
				showSafeMenu()
			else
				outputChatBox("You do not have the keys to the safe.", 255, 0, 0)
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickSafe, true)

function showSafeMenu()
	local rightclick = exports.rightclick

	local row = {}
	local rcMenu = rightclick:create("Safe")

	row.inventory = rightclick:addRow("Inventory")
	addEventHandler("onClientGUIClick", row.inventory, requestInventory, false)
end
