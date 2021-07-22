localPlayer = getLocalPlayer()
function carshop_showInfo(carPrice, taxPrice)
	local isOverlayDisabled = getElementData(localPlayer, "hud:isOverlayDisabled")
	if isOverlayDisabled then
		outputChatBox("")
		outputChatBox("Car Dealership")
		outputChatBox("   - Brand: "..(getElementData(source, "brand") or getVehicleNameFromModel( getElementModel( source ) )) )
		outputChatBox("   - Model: "..(getElementData(source, "maximemodel") or getVehicleNameFromModel( getElementModel( source ) )) )
		outputChatBox("   - Year: "..(getElementData(source, "year") or "2015") )

		if getVehicleType(source) ~= 'BMX' then
			outputChatBox("   - Odometer: "..exports.global:formatMoney(getElementData(source, 'odometer') or 0) .. " miles"  )
		end
		outputChatBox("   - Price: $"..exports.global:formatMoney(carPrice)  )
		outputChatBox("   - Tax: $"..exports.global:formatMoney(taxPrice)  )
		outputChatBox("   (( MTA Model: "..getVehicleNameFromModel( getElementModel( source ) ).."))"  )
		outputChatBox("Press F or Enter to buy this vehicle")
	else
		local content = {}
		table.insert(content, { getCarShopNicename(getElementData(source, "carshop")) , false, false, false, false, false, false, "title"} )
		table.insert(content, {" " } )
		table.insert(content, {"   - Brand: "..(getElementData(source, "brand") or getVehicleNameFromModel( getElementModel( source ) )) } )
		table.insert(content, {"   - Model: "..(getElementData(source, "maximemodel") or getVehicleNameFromModel( getElementModel( source ) ))} )
		table.insert(content, {"   - Year: "..(getElementData(source, "year") or "2015")} )
		if getVehicleType(source) ~= 'BMX' then
			table.insert(content, {"   - Odometer: "..exports.global:formatMoney(getElementData(source, 'odometer') or 0) .. " miles"})
		end
		table.insert(content, {"   - Price: $"..exports.global:formatMoney(carPrice)  } )
		table.insert(content, {"   - Tax: $"..exports.global:formatMoney(taxPrice) } )
		table.insert(content, {"   (( MTA Model: "..getVehicleNameFromModel( getElementModel( source ) ).."))" } )
		table.insert(content, {"Press 'F' or 'Enter' to purchase!" } )
		exports.hud:sendTopRightNotification( content, localPlayer, 240)
	end
end
addEvent("carshop:showInfo", true)
addEventHandler("carshop:showInfo", getRootElement(), carshop_showInfo)

local gui, theVehicle = {}
function carshop_buyCar(carPrice, cashEnabled, bankEnabled)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return false
	end

	if gui["_root"] then
		return
	end

	setElementData(getLocalPlayer(), "exclusiveGUI", true, false)

	theVehicle = source

	guiSetInputEnabled(true)
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 350, 190
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	gui["_root"] = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)
	--guiWindowSetSizable(gui["_root"], false)

	gui["lblText1"] = guiCreateLabel(20, 25, windowWidth-40, 16, "You're about to buy the following vehicle:", false, gui["_root"])
	gui["lblVehicleName"] = guiCreateLabel(20, 45+5, windowWidth-40, 13, exports.global:getVehicleName(source) , false, gui["_root"])
	guiSetFont(gui["lblVehicleName"], "default-bold-small")
	gui["lblVehicleCost"] = guiCreateLabel(20, 45+15+5, windowWidth-40, 13, "Price: $"..exports.global:formatMoney(carPrice), false, gui["_root"])
	guiSetFont(gui["lblVehicleCost"], "default-bold-small")
	gui["lblText2"] = guiCreateLabel(20, 45+15*2, windowWidth-40, 70, "With clicking on a payment button, you agree that a refund is not possible. Thanks for choosing us!", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblText2"], "left", true)
	guiLabelSetVerticalAlign(gui["lblText2"], "center", true)

	gui["btnCash"] = guiCreateButton(10, 140, 105, 41, "Pay by cash", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["btnCash"], carshop_buyCar_click, false)
	guiSetEnabled(gui["btnCash"], cashEnabled)
	if exports.global:hasItem(localPlayer, 263) and carPrice <= 35000 then
		guiSetText(gui["btnCash"], "Redeem Token")
		guiSetEnabled(gui["btnCash"], true)
	end

	gui["btnBank"] = guiCreateButton(120, 140, 105, 41, "Pay by bank", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["btnBank"], carshop_buyCar_click, false)
	guiSetEnabled(gui["btnBank"], bankEnabled)

	gui["btnCancel"] = guiCreateButton(232, 140, 105, 41, "Cancel", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["btnCancel"], carshop_buyCar_close, false)
end
addEvent("carshop:buyCar", true)
addEventHandler("carshop:buyCar", getRootElement(), carshop_buyCar)

function carshop_buyCar_click()
	if exports.global:hasSpaceForItem(getLocalPlayer(), 3, 1) then
		local sourcestr = "cash"
		if (source == gui["btnBank"]) then
			sourcestr = "bank"
		elseif guiGetText(gui["btnCash"]) == "Redeem Token" then
			sourcestr = "token"
		end
		triggerServerEvent("carshop:buyCar", theVehicle, sourcestr)
	else
		outputChatBox("You don't have space in your inventory for a key", 0, 255, 0)
	end
	carshop_buyCar_close()
end


function carshop_buyCar_close()
	if gui["_root"] then
		destroyElement(gui["_root"])
		gui = { }
	end
	guiSetInputEnabled(false)
	setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
end
--PREVENT ABUSER TO CHANGE CHAR
addEventHandler ( "account:changingchar", getRootElement(), carshop_buyCar_close )
addEventHandler("onClientChangeChar", getRootElement(), carshop_buyCar_close)

function cleanUp()
	setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
end
addEventHandler("onClientResourceStart", resourceRoot, cleanUp)
