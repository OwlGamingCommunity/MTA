--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Client-side script: Forklift features
--Last updated 23.02.2011 by Exciter
--Copyright 2008-2011, The Roleplay Project (www.roleplayproject.com)

local localPlayer = getLocalPlayer()

local shapes = {}
local myCurrentBox
local myCurrentItemSlot
local spaceKeyBound = false

local cargoVehicles = {
	--bool canBeUsed, xOffset, yOffset, zOffset, size
	[456] = {true, false, false, false, false}, --Yankee
	[498] = {true, false, false, false, false}, --Boxville
	[414] = {true, false, false, false, false}, --Mule
	[499] = {true, false, false, false, false}, --Benson
	[573] = {true, false, false, false, false}, --Dune
	[435] = {true, false, false, false, false}, --Trailer 1
	[450] = {true, false, false, false, false}, --Trailer 2
	[591] = {true, false, false, false, false}, --Trailer 3
	[607] = {true, 0, 0, 0, 3}, --Baggage Trailer (uncovered)
	[606] = {true, 0, 0, 0, 3}, --Baggage Trailer (covered)
	[592] = {true, 0, -23, -2.2, 5}, --Andromada
	[577] = {true, -2, -15, -0.5, 4.5}, --AT-400
	[548] = {true, 0, -4, 0, 4}, --Cargobob
	[553] = {true, -2, -3, 0, 3}, --Nevada
}

function loadForklift(forklift, element, slot)
	if spaceKeyBound then
		unbindKey("space", "down", unloadForklift)
		spaceKeyBound = false
	end
	if not getElementData(forklift, "cargo.forklift.carrying") then
		if wLoadItem then
			destroyElement(wLoadItem)
			wLoadItem = nil
			wLoadItem_pane = nil
		end
		triggerEvent("showLoading", localPlayer)
		triggerServerEvent("cargo:loadForklift", forklift, element, slot)
		--loadForkliftResponse(forklift, slot)
	end
end
--[[
function loadForkliftResponse(forklift, newSlot)
	triggerEvent("hideLoading", localPlayer)
	if not myCurrentBox then
		--myCurrentItemSlot = newSlot
		--myCurrentBox = createObject(1271,0,0,0)
		--attachElements(myCurrentBox, forklift, 0, 0.5, 0.28)
	end
end
addEvent("cargo:loadForkliftResponse", true )
addEventHandler("cargo:loadForkliftResponse", getRootElement(), loadForkliftResponse)
--]]
function unloadForkliftByKey(key, keyState, forklift, element)
	unloadForklift(forklift, element)
end
function unloadForklift(forklift, element)
	--outputDebugString("element = "..tostring(element))
	if spaceKeyBound then
		unbindKey("space", "down", unloadForkliftByKey)
		spaceKeyBound = false
	end
	if getElementData(forklift, "cargo.forklift.carrying") then
		if wLoadItem then
			destroyElement(wLoadItem)
			wLoadItem = nil
		end
		triggerEvent("showLoading", localPlayer)
		triggerServerEvent("cargo:unloadForklift", forklift, element)
		--unloadForkliftResponse(forklift)
	end
end
--[[
function unloadForkliftResponse(forklift)
	triggerEvent("hideLoading", localPlayer)
	if myCurrentBox then
		--myCurrentItemSlot = false
		--destroyElement(myCurrentBox)
		--myCurrentBox = false
	end
end
addEvent("cargo:unloadForkliftResponse", true )
addEventHandler("cargo:unloadForkliftResponse", getRootElement(), unloadForkliftResponse)
--]]

function onClientColShapeHit(element, matchingDimension)
	--element = the forklift, source = the colshape, parent = the vehicle/shelf
	--outputDebugString("onClientColShapeHit")
	if matchingDimension and (getElementType(element) == "vehicle") then
		--outputDebugString("check 1")
		if(getElementModel(element) == 530) and (getVehicleController(element) == localPlayer) then
			--outputDebugString("source = "..tostring(getElementType(source)))
			--local parent = getElementParent(source)
			if wLoadItem then
				destroyElement(wLoadItem)
				wLoadItem = nil
				wLoadItem_pane = nil
			end
			local parent = getElementAttachedTo(source)
			local parentType = getElementType(parent)
			--outputDebugString("parent = "..tostring(parent))
			if(parentType == "vehicle") then
				--outputChatBox("Hit car!")
				if not isVehicleLocked(parent) then
					--outputDebugString("not locked")
					if getElementData(element, "cargo.forklift.carrying") then
						--outputDebugString("carrying")
						local screenX, screenY = guiGetScreenSize()
						local width = 300
						local height = 40
						local listHeight = 0
						local posX = (screenX/2)-(width/2)
						local posY = (screenY/4)*3
						wLoadItem = guiCreateStaticImage(posX, posY, width, height, ":computers-system/websites/colours/0.png", false)
						guiSetAlpha(wLoadItem, .6)
						local info = guiCreateLabel(5, 12, width-10, 15, "Press SPACE to load from forklift to vehicle.", false, wLoadItem)
						guiLabelSetHorizontalAlign(info, "center", false)
						if not spaceKeyBound then
							bindKey("space", "down", unloadForkliftByKey, element, parent)
							spaceKeyBound = true
						end
					else
						--outputDebugString("not carrying")
						triggerEvent("showLoading", localPlayer)
						local shelfItems = exports['item-system']:getItems(parent)
						--outputDebugString("#shelfItems = "..tostring(#shelfItems))
						if(#shelfItems > 0) then
							local screenX, screenY = guiGetScreenSize()
							local maxHeight = (screenY/3)*2
							local width = 300
							local height = 20
							local listHeight = 0
							local posX = (screenX/2)-(width/2)
							local posY = (screenY/2)-(height/2)

							wLoadItem = guiCreateStaticImage(posX, posY, width, height, ":computers-system/websites/colours/0.png", false)
							guiSetAlpha(wLoadItem, .6)
							local info = guiCreateLabel(5, 0, width-10, 15, "Select an item to load on forklift.", false, wLoadItem)
							guiLabelSetHorizontalAlign(info, "center", false)
							wLoadItem_pane = guiCreateScrollPane(5, 15, width-10, 0, false, wLoadItem)

							local paneY = 5
							for slot,item in ipairs(shelfItems) do
								local guiBg = guiCreateStaticImage(5, paneY, width-10-10, 40, ":computers-system/websites/colours/0.png", false, wLoadItem_pane)
								guiSetAlpha(wLoadItem, .7)

								local name = exports['item-system']:getItemName( item[1], item[2] )
								local desc = tostring(item[1] == 114 and exports['item-system']:getItemDescription( item[1], item[2] ) or item[2] == 1 and "" or item[2])
								if name ~= desc and #desc > 0 then
									name = name .. " - " .. desc
								end

								local itemImg = false
								local itemImg = guiCreateStaticImage(3, 3, 34, 34, ":item-system/images/"..tostring(item[1])..".png", false, guiBg)
								if not itemImg then
									itemImg = guiCreateStaticImage(3, 3, 34, 34, ":item-system/images/121.png", false, guiBg)
								end
								local itemLabel = guiCreateLabel(42, 3, width-10-10-42, 15, tostring(name), false, guiBg)

								addEventHandler("onClientGUIClick", getRootElement(),
									function(button)
										--outputDebugString(""..tostring(source).." == "..tostring(guiBg).." or "..tostring(source).." == "..tostring(itemImg).." or "..tostring(source).." == "..tostring(itemLabel).."")
										if(source == guiBg or source == itemImg or source == itemLabel) then
											--outputDebugString("loadForklift("..tostring(element)..", "..tostring(parent)..", "..tostring(slot)..")")
											loadForklift(element, parent, slot)
										end
									end
								)

								if(height < maxHeight) then
									height = height + 45
									paneY = paneY + 45
									guiSetSize(wLoadItem_pane, width-10, paneY, false)
									posY = (screenY/2)-(height/2)
									guiSetSize(wLoadItem, width, height, false)
									guiSetPosition(wLoadItem, posX, posY, false)
								end
							end
						else
							--outputChatBox("No items in vehicle inventory.")
						end
						triggerEvent("hideLoading", localPlayer)
					end
				end
			elseif(parentType == "object") then
				local itemID = tonumber(getElementData(parent, "itemID")) or 0
				if itemID == 103 then
					--outputChatBox("Hit shelf!")
					if not getElementData(element, "cargo.forklift.carrying") then
						triggerEvent("showLoading", localPlayer)
						local shelfItems = exports['item-system']:getItems(parent)
						if(#shelfItems > 0) then
							local screenX, screenY = guiGetScreenSize()
							local maxHeight = (screenY/3)*2
							local width = 300
							local height = 20
							local listHeight = 0
							local posX = (screenX/2)-(width/2)
							local posY = (screenY/2)-(height/2)

							wLoadItem = guiCreateStaticImage(posX, posY, width, height, ":computers-system/websites/colours/0.png", false)
							guiSetAlpha(wLoadItem, .6)
							local info = guiCreateLabel(5, 0, width-10, 15, "Select an item to load on forklift.", false, wLoadItem)
							guiLabelSetHorizontalAlign(info, "center", false)
							wLoadItem_pane = guiCreateScrollPane(5, 15, width-10, 0, false, wLoadItem)

							local paneY = 5
							for slot,item in ipairs(shelfItems) do
								local guiBg = guiCreateStaticImage(5, paneY, width-10-10, 40, ":computers-system/websites/colours/0.png", false, wLoadItem_pane)
								guiSetAlpha(wLoadItem, .7)
								
								local name = exports['item-system']:getItemName( item[1], item[2] )
								local desc = tostring(item[1] == 114 and exports['item-system']:getItemDescription( item[1], item[2] ) or item[2] == 1 and "" or item[2])
								if name ~= desc and #desc > 0 then
									name = name .. " - " .. desc
								end

								local itemImg = false
								local itemImg = guiCreateStaticImage(3, 3, 34, 34, ":item-system/images/"..tostring(item[1])..".png", false, guiBg)
								if not itemImg then
									itemImg = guiCreateStaticImage(3, 3, 34, 34, ":item-system/images/121.png", false, guiBg)
								end
								local itemLabel = guiCreateLabel(42, 3, width-10-10-42, 15, tostring(name), false, guiBg)

								addEventHandler("onClientGUIClick", getRootElement(),
									function(button)
										--outputDebugString(""..tostring(source).." == "..tostring(guiBg).." or "..tostring(source).." == "..tostring(itemImg).." or "..tostring(source).." == "..tostring(itemLabel).."")
										if(source == guiBg or source == itemImg or source == itemLabel) then
											--outputDebugString("loadForklift("..tostring(element)..", "..tostring(parent)..", "..tostring(slot)..")")
											loadForklift(element, parent, slot)
										end
									end
								)
								
								if(height < maxHeight) then
									height = height + 45
									paneY = paneY + 45
									guiSetSize(wLoadItem_pane, width-10, paneY, false)
									posY = (screenY/2)-(height/2)
									guiSetSize(wLoadItem, width, height, false)
									guiSetPosition(wLoadItem, posX, posY, false)
								end
							end
						else
							--outputChatBox("No items in shelf.")
						end
						triggerEvent("hideLoading", localPlayer)
					else
						--outputChatBox("Unload first!",255,0,0)
						local screenX, screenY = guiGetScreenSize()
						local width = 300
						local height = 40
						local listHeight = 0
						local posX = (screenX/2)-(width/2)
						local posY = (screenY/4)*3
						wLoadItem = guiCreateStaticImage(posX, posY, width, height, ":computers-system/websites/colours/0.png", false)
						guiSetAlpha(wLoadItem, .6)
						local info = guiCreateLabel(5, 12, width-10, 15, "Press SPACE to load from forklift to shelf.", false, wLoadItem)
						guiLabelSetHorizontalAlign(info, "center", false)						
						if not spaceKeyBound then
							bindKey("space", "down", unloadForkliftByKey, element, parent)
							spaceKeyBound = true
						end
					end
				else
					--outputDebugString("cargo/c_cargo: not valid itemID")
				end
			else
				--outputDebugString("cargo/c_cargo: not valid element type ("..tostring(parentType)..")")
			end
		end
	end
end

function onClientColShapeLeave(element, matchingDimension)
	if matchingDimension and (getElementType(element) == "vehicle") then
		--outputDebugString("check 1")
		if(getElementModel(element) == 530) and (getVehicleController(element) == localPlayer) then
			if wLoadItem then
				destroyElement(wLoadItem)
				wLoadItem = nil
				wLoadItem_pane = nil
			end
		end
	end
end


addEventHandler("onClientVehicleEnter", getRootElement(),
	function(thePlayer, seat)
		if thePlayer == getLocalPlayer() and seat == 0 then
			local model = getElementModel(source)
			if(model == 530) then --forklift
				for k,v in ipairs(getElementsByType("vehicle")) do
					local vModel = getElementModel(v)
					if cargoVehicles[vModel] then
						if cargoVehicles[vModel][1] then
							local offset_x = 0
							local offset_y = -3
							local offset_z = 0
							local size = 4

							local edit_offset_x = cargoVehicles[vModel][2]
							local edit_offset_y = cargoVehicles[vModel][3]
							local edit_offset_z = cargoVehicles[vModel][4]
							local edit_size = cargoVehicles[vModel][5]
							
							if edit_offset_x then offset_x = edit_offset_x end
							if edit_offset_y then offset_y = edit_offset_y end
							if edit_offset_z then offset_z = edit_offset_z end
							if edit_size then size = edit_size end
							
							local colshape = createColSphere(0, 0, 0, size)
							table.insert(shapes, colshape)
							
							local int = getElementInterior(v)
							local dim = getElementDimension(v)
							setElementInterior(colshape, int)
							setElementDimension(colshape, dim)
							
							attachElements(colshape, v, offset_x, offset_y, offset_z)
							addEventHandler("onClientColShapeHit", colshape, onClientColShapeHit)
							addEventHandler("onClientColShapeLeave", colshape, onClientColShapeLeave)
						end
					end
				end
				for k, theObject in ipairs(getElementsByType("object", getResourceRootElement(getResourceFromName("item-world")))) do
					local itemID = tonumber(getElementData(theObject, "itemID")) or 0
					if(itemID == 103) then --shelf
						local colshape = createColSphere(0, 0, 0, 4)
						table.insert(shapes, colshape)
						
						local int = getElementInterior(theObject)
						local dim = getElementDimension(theObject)
						setElementInterior(colshape, int)
						setElementDimension(colshape, dim)
						
						attachElements(colshape, theObject, 0, 0, 0)
						addEventHandler("onClientColShapeHit", colshape, onClientColShapeHit)
						addEventHandler("onClientColShapeLeave", colshape, onClientColShapeLeave)
					end
				end
			end
		end
	end
)
addEventHandler("OnClientVehicleExit", getRootElement(),
	function(thePlayer, seat)
		if thePlayer == getLocalPlayer() and seat == 0 then
			if(getElementModel(source) == 530) then --forklift
				for k,v in ipairs(shapes) do
					destroyElement(v)
				end
			end
		end
	end
)