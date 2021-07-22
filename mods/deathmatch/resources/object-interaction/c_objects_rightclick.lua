local debugModelOutput = false

local noMenuFor = {
	[0] = true, --nothing
}
local noPickupFor = {
}
local noPropertiesFor = {

}

function clickObject(button, state, absX, absY, wx, wy, wz, element)
	if getElementData(localPlayer, "exclusiveGUI") then
		return
	end
	if (element) and (getElementType(element)=="object") and (button=="right") and (state=="down") then
		local x, y, z = getElementPosition(getLocalPlayer())
		local eX, eY, eZ = getElementPosition(element)
		local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(element)
		local addDistance = 0 --compensate for object size
		if minX then
			local boundingBoxBiggestDist = 0
			if minX > boundingBoxBiggestDist then
				boundingBoxBiggestDist = minX
			end
			if minY > boundingBoxBiggestDist then
				boundingBoxBiggestDist = minY
			end
			if maxX > boundingBoxBiggestDist then
				boundingBoxBiggestDist = maxX
			end
			if maxY > boundingBoxBiggestDist then
				boundingBoxBiggestDist = maxY
			end
			addDistance = boundingBoxBiggestDist
		end
		local maxDistance = 3 + addDistance
		if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=maxDistance) then
			local rcMenu
			local row = {}

			if getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("item-world")) then
				local itemID = tonumber(getElementData(element, "itemID")) or 0
				if noMenuFor[itemID] then return end
				local itemValue = getElementData(element, "itemValue")
				local metadata = getElementData(element, "metadata") or {}
				local itemName = tostring(exports.global:getItemName(itemID, itemValue, metadata))

				if exports['item-world']:can(localPlayer, "use", element) then
					if not rcMenu then rcMenu = exports.rightclick:create(itemName) end
					if itemID == 81 then --fridge
						row.a = exports.rightclick:addrow("Open fridge")
						addEventHandler("onClientGUIClick", row.a,  function (button, state)
							if not getElementData ( localPlayer, "exclusiveGUI" ) then
								triggerServerEvent( "openFreakinInventory", getLocalPlayer(), element, absX, absY )
							end
						end, false)
					elseif itemID == 103 then --shelf
						row.a = exports.rightclick:addrow("Browse shelf")
						addEventHandler("onClientGUIClick", row.a,  function (button, state)
							if not getElementData ( localPlayer, "exclusiveGUI" ) then
								triggerServerEvent( "openFreakinInventory", getLocalPlayer(), element, absX, absY )
							end
						end, false)
					elseif exports['item-system']:isStorageItem(itemID, itemValue) then -- Storage
						row.a = exports.rightclick:addrow("Browse storage")
						addEventHandler("onClientGUIClick", row.a,  function (button, state)
							if not getElementData ( localPlayer, "exclusiveGUI" ) then
								triggerServerEvent( "openFreakinInventory", getLocalPlayer(), element, absX, absY )
							end
						end, false)
					elseif itemID == 166 then --video system
						if exports.global:hasItem(element, 165) then --if disc in
							row.a = exports.rightclick:addrow("Eject disc")
							addEventHandler("onClientGUIClick", row.a,  function (button, state)
								triggerServerEvent("clubtec:vs1000:ejectDisc", getLocalPlayer(), element)
							end, false)
						end
						row.b = exports.rightclick:addrow("Control")
						addEventHandler("onClientGUIClick", row.b,  function (button, state)
							triggerServerEvent("clubtec:vs1000:gui", getLocalPlayer(), element)
						end, false)
					elseif itemID == 54 or itemID == 176 then -- Ghettoblaster
						row.a = exports.rightclick:addrow("Edit sound")
						addEventHandler("onClientGUIClick", row.a,  function (button, state)
							triggerEvent("item:showMenu", getLocalPlayer(), element, absX, absY)
						end, false)
					elseif itemID == 96 then
						row.a = exports.rightclick:addrow("Use")
						addEventHandler("onClientGUIClick", row.a,  function (button, state)
							triggerEvent("useCompItem", localPlayer)
							triggerServerEvent("computers:on", localPlayer)
						end, false)
					elseif(exports.sittablechairs:isSittableChair(element)) then
						if(exports.sittablechairs:canSitOnChair(element)) then
							row.a = exports.rightclick:addrow("Sit")
							addEventHandler("onClientGUIClick", row.a,  function (button, state)
								exports.sittablechairs:attemptToSitOnChair(element)
							end, false)
						end
					end
				end

				if (getElementDimension(element) ~= 0 or exports.integration:isPlayerTrialAdmin(localPlayer, true) or getElementData(localPlayer, "admin:tempmove")) and exports['item-world']:can(localPlayer, "move", element) and not getElementData(localPlayer, "jailed") then
					if not rcMenu then rcMenu = exports.rightclick:create(itemName) end
					row.move = exports.rightclick:addrow("Move")
					addEventHandler("onClientGUIClick", row.move,  function (button, state)
						triggerEvent("item:move", root, element)
					end, false)
				end
				if not noPickupFor[itemID] and exports['item-world']:can(localPlayer, "pickup", element) then
					if not rcMenu then rcMenu = exports.rightclick:create(itemName) end
					row.pickup = exports.rightclick:addrow("Pick up")
					addEventHandler("onClientGUIClick", row.pickup,  function (button, state)
						if itemID ~= 223 and itemID ~= 103 then
							if exports.global:hasSpaceForItem(localPlayer, itemID, itemValue, metadata) then
								triggerServerEvent("pickupItem", getLocalPlayer(), element)
							else
								outputChatBox("You lack the space in your inventory to pick this item up.", 255, 0, 0)
							end
						else
							areYouSure(element)
						end
					end, false)
				end
				if not noPropertiesFor[itemID] and exports['item-world']:canEditItemProperties(localPlayer, element) then
					if not rcMenu then rcMenu = exports.rightclick:create(itemName) end
					row.properties = exports.rightclick:addrow("Properties")
					addEventHandler("onClientGUIClick", row.properties,  function (button, state)
						triggerEvent("showItemProperties", localPlayer, element)
					end, false)
				end
			else
				if(exports.sittablechairs:isSittableChair(element)) then
					if(exports.sittablechairs:canSitOnChair(element)) then
						if not rcMenu then rcMenu = exports.rightclick:create("Chair") end
						row.a = exports.rightclick:addrow("Sit")
						addEventHandler("onClientGUIClick", row.a,  function (button, state)
							exports.sittablechairs:attemptToSitOnChair(element)
						end, false)
					end
				end
			end


			local model = getElementModel(element)
			if(model == 2517) then --SHOWERS
				if not rcMenu then  rcMenu = exports.rightclick:create("Shower") end
				if showering[1] then
					row.a = exports.rightclick:addrow("Stop showering")
					addEventHandler("onClientGUIClick", row.a,  function (button, state)
						takeShower(element)
					end, false)
				else
					row.a = exports.rightclick:addrow("Take a shower")
					addEventHandler("onClientGUIClick", row.a,  function (button, state)
						takeShower(element)
					end, false)
				end
			elseif(model == 2146) then --Stretcher (ES)
				if not rcMenu then  rcMenu = exports.rightclick:create("Stretcher") end
				row.a = exports.rightclick:addrow("Take Stretcher")
				addEventHandler("onClientGUIClick", row.a,  function (button, state)
					triggerServerEvent("stretcher:takeStretcher", localPlayer, element)
				end, true)
			elseif(model == 962) then --Airport gate control box
				local airGateID = getElementData(element, "airport.gate.id")
				if airGateID then
					if not rcMenu then  rcMenu = exports.rightclick:create("Control Box") end
					row.a = exports.rightclick:addrow("Control Gate")
					addEventHandler("onClientGUIClick", row.a,  function (button, state)
						triggerEvent("airport-gates:controlGUI", getLocalPlayer(), element)
					end, false)
				end
			elseif(model == 1819) then --Airport fuel
				local airFuel = getElementData(element, "airport.fuel")
				if airFuel then
					outputDebugString("Air fuel: TODO")
				end
			else
				if debugModelOutput then
					lastDebugModelElement = element
					outputChatBox("Model ID "..tostring(model))
					outputChatBox("Breakable: "..tostring(isObjectBreakable(element)))
					--[[
					local mapsres = getResourceDynamicElementRoot(getResourceFromName("maps"))
					local objectParent = getElementParent(getElementParent(element))
					if getElementType(objectParent) == "resource" then
						if mapsres == objectParent then
							outputChatBox("From resource: maps")
						end
					end
					--]]
					local objectIdentity = getElementData(element, "id")
					if objectIdentity then
						outputChatBox("ID: "..tostring(objectIdentity))
					end
					--outputDebugString("parent type = "..tostring(getElementType(objectParent)))
					--if getElementType(objectParent) == "resource" then
						--local objectResourceName = tostring(getResourceName(getResourceRootElement(objectParent)))
						--outputChatBox("Parent: "..objectResourceName)
						--if objectResourceName == "maps" then
							local objectPosX, objectPosY, objectPosZ = getElementPosition(element)
							local objectRotX, objectRotY, objectRotZ = getElementRotation(element)
							local mapformat = '<object id="object" breakable="'..tostring(isObjectBreakable(element))..'" interior="'..tostring(getElementInterior(element))..'" alpha="'..tostring(getElementAlpha(element))..'" model="'..tostring(model)..'" doublesided="'..tostring(getElementData(element, "doublesided") and true)..'" scale="'..tostring(getObjectScale(element) or 0)..'" dimension="'..tostring(getElementDimension(element))..'" posX="'..tostring(objectPosX)..'" posY="'..tostring(objectPosY)..'" posZ="'..tostring(objectPosZ)..'" rotX="'..tostring(objectRotX)..'" rotY="'..tostring(objectRotY)..'" rotZ="'..tostring(objectRotZ)..'"></object>'
							outputConsole(mapformat)
						--end
					--end
				end
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickObject, true)

function areYouSure( element )
	local SCREEN_X, SCREEN_Y = guiGetScreenSize()
	local check = { }
	local width = 300 -- The width of our window
	local height = 140 -- The height of our window
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	check.window = guiCreateWindow( x, y, width, height, "Pickup Item", false )

	check.message = guiCreateLabel( 10, 30, width - 20, 20, "Are you sure you want to pickup this item?", false, check.window )
	check.this = guiCreateLabel(10, 50, width - 20, 30, "This will delete all items within the storage container!", false, check.window)
	guiLabelSetHorizontalAlign( check.this, "center", true)
	guiLabelSetHorizontalAlign( check.message, "center", true)

	check.closeButton = guiCreateButton( 10, 87, width / 2 - 15, 40, "Cancel", false, check.window )
	addEventHandler( "onClientGUIClick", check.closeButton,
		function ()
			destroyElement( check.window )
			check = { }
		end
	)

	check.deleteButton = guiCreateButton( width / 2 + 5, 87, width / 2 - 15, 40, "I'm Sure!", false, check.window )
	addEventHandler( "onClientGUIClick", check.deleteButton,
		function ()
			triggerServerEvent("pickupItem", getLocalPlayer(), element)
			destroyElement( check.window )
			check = { }
		end
	)
end

function debugToggleModelOutput(thePlayer, commandName)
	--if exports.integration:isPlayerScripter(thePlayer) then
		debugModelOutput = not debugModelOutput
		outputChatBox("DBG: ModelOutput set to "..tostring(debugModelOutput))
	--end
end
addCommandHandler("debugmodeloutput", debugToggleModelOutput)

function debugDeleteLastModel(thePlayer, commandName)
	if debugModelOutput then
		--if exports.integration:isPlayerScripter(thePlayer) then
		if exports.integration:isPlayerTrialAdmin(thePlayer) then
			if lastDebugModelElement then
				if isElement(lastDebugModelElement) then
					destroyElement(lastDebugModelElement)
				end
			end
			debugModelOutput = not debugModelOutput
			outputChatBox("DBG: ModelOutput set to "..tostring(debugModelOutput))
		end
	end
end
addCommandHandler("deletelastdebugmodel", debugDeleteLastModel)

addEventHandler("onClientObjectBreak", root,
	function()
		--local isBreakable = isObjectBreakable(source)
		--if not isBreakable then
			cancelEvent()
		--end
		--outputDebugString("object-interaction/c_objects_rightclick: Object breakable "..tostring(isBreakable))
	end
)
