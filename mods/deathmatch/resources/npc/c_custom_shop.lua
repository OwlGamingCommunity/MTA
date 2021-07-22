--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

MTAoutputChatBox = outputChatBox
function outputChatBox( text, visibleTo, r, g, b, colorCoded )
	if text then
		if string.len(text) > 128 then -- MTA Chatbox size limit
			MTAoutputChatBox( string.sub(text, 1, 127), visibleTo, r, g, b, colorCoded  )
			outputChatBox( string.sub(text, 128), visibleTo, r, g, b, colorCoded  )
		else
			MTAoutputChatBox( text, visibleTo, r, g, b, colorCoded  )
		end
	end
end


wAddingItemsToShop, wOwnerProductView = nil

function addItemToShop(source, item, slot, worldItem, npcID, shopElement )
	if tonumber(getElementData(shopElement, "currentCap")) >= tonumber(getElementData(shopElement, "sCapacity")) then
		triggerServerEvent("shop:storeKeeperSay", source, source, "Hey hey! I'm not selling anything more unless you raise my wage!", getElementData(shopElement, "name"))
		return false
	end

	closeAddingItemWindow()
	showCursor(true)
	guiSetInputEnabled(true)

	local screenwidth, screenheight = guiGetScreenSize()
	local Width = 438
	local Height = 199
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2

	wAddingItemsToShop = guiCreateWindow( X, Y, Width, Height,"Putting a product on sale",false)

	local itemURL = nil

	if tonumber(item['id']) == 16 then --clothes
		local value = exports.global:explode(":",tostring(item['value']))
		local skinid = tonumber(value[1]) or 1
		itemURL = ":account/img/" .. ("%03d"):format( skinid or 1 ) .. ".png"
	elseif tonumber(item['id']) == 115 then -- weapons
		itemURL = ":item-system/images/-"..string.match(tostring(item['value']), "(%d+)")..".png"
	else -- other
		itemURL = ":item-system/images/"..tostring(item['id'])..".png"
	end

	local itemName = exports["item-system"]:getItemName( tonumber(item['id']), item['value'], item['metadata'] ) or ""
	local itemValue = ""
	if not exports["item-system"]:getItemHideItemValue(tonumber(item['id'])) then
		itemValue = exports["item-system"]:getItemValue( tonumber(item['id']), item['value'], item['metadata'] ) or ""
	end

	local iProductImage = guiCreateStaticImage(9,27,128,128,itemURL,false,wAddingItemsToShop)
	local lProductName = guiCreateLabel(147,27,280,18,"Product Name: "..itemName or ""..".",false,wAddingItemsToShop)
	local lAmount = guiCreateLabel(147,45,280,18,"Details: "..itemValue or ""..".",false,wAddingItemsToShop)
	local lPrice = guiCreateLabel(147,63,42,18,"Price: $",false,wAddingItemsToShop)
	local ePrice = guiCreateEdit(189,62,238,20,"0",false,wAddingItemsToShop)
	local lDesc = guiCreateLabel(147,81,66,18,"Description: ",false,wAddingItemsToShop)
	local mDesc = guiCreateMemo(147,99,280,56,exports["item-system"]:getItemDescription( tonumber(item['id']), item['value'], item['metadata'] ) or "",false,wAddingItemsToShop)
	local bCancel = guiCreateButton(217,161,210,27,"Cancel",false,wAddingItemsToShop)
	addEventHandler( "onClientGUIClick", bCancel, function ()
		closeAddingItemWindow()
	end, false )
	local bOk = guiCreateButton(9,161,208,27,"OK, put this on sale please!",false,wAddingItemsToShop)
	addEventHandler( "onClientGUIClick", bOk, function ()
		local price = guiGetText(ePrice):gsub(",","")
		price = tonumber(price) or false
		local desc = guiGetText(mDesc):gsub("\n"," ")
		if price then
			triggerServerEvent( "shop:updateItemToShop", source, source, item, price, desc, npcID, slot, worldItem, shopElement )
			closeAddingItemWindow()
		else
			guiSetText(wAddingItemsToShop, "Invalid Price!")
			setTimer(function()
				guiSetText(wAddingItemsToShop,"Putting product ("..itemName..") on sale")
			end, 3000, 1)
		end
	end, false )
end
addEvent("shop:addItemToShop", true )
addEventHandler("shop:addItemToShop", getRootElement(), addItemToShop)

function closeAddingItemWindow()
	if wAddingItemsToShop then
		destroyElement(wAddingItemsToShop)
		wAddingItemsToShop = nil
		showCursor(false)
		guiSetInputEnabled(false)
	end
end

function ownerProductView(products, proID, shopElement)
	closeOwnerProductView()
	showCursor(true)
	guiSetInputEnabled(true)
	local screenwidth, screenheight = guiGetScreenSize()
	local Width = 438
	local Height = 199
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2

	local item = {}
	if products and proID then
		for key, value in ipairs(products) do
			if value[7] == proID then
				item = value
				item[1] = value[2] --itemID
				item[2] = value[3] --itemValue
				item[3] = value[4] --description
				item[4] = value[5] --price
				item[5] = value[1] --id
				item[6] = value[8] --metadata
				break
			end
		end
	end

	wOwnerProductView = guiCreateWindow( X, Y, Width, Height,"Product Management",false)

	local itemURL = nil

	if tonumber(item[1]) == 16 then --clothes
		local value = exports.global:explode(":",tostring(item[2]))
		local skinid = tonumber(value[1]) or 1
		itemURL = ":account/img/" .. ("%03d"):format( skinid or 1 ) .. ".png"
	elseif tonumber(item[1]) == 115 then -- weapons
		itemURL = ":item-system/images/-"..string.match(tostring(item[2]), "(%d+)")..".png"
	else -- other
		itemURL = ":item-system/images/"..tostring(item[1])..".png"
	end

	--outputDebugString(itemURL.." - "..item[1].." - "..item[2])

	local itemName = exports["item-system"]:getItemName( tonumber(item[1]), tostring(item[2]), item[6] ) or ""
	local itemValue = ""
	if not exports["item-system"]:getItemHideItemValue(tonumber(item[1])) then
		itemValue = exports["item-system"]:getItemValue( tonumber(item[1]), tostring(item[2]), item[6] ) or ""
	end

	local iProductImage = guiCreateStaticImage(9,27,128,128,itemURL,false,wOwnerProductView)
	local lProductName = guiCreateLabel(147,27,280,18,"Product Name: "..itemName or ""..".",false,wOwnerProductView)
	local lAmount = guiCreateLabel(147,45,280,18,"Details: "..itemValue or ""..".",false,wOwnerProductView)
	local lPrice = guiCreateLabel(147,63,42,18,"Price: $",false,wOwnerProductView)
	local ePrice = guiCreateEdit(189,62,238,20,item[4] or 0,false,wOwnerProductView)
	local lDesc = guiCreateLabel(147,81,66,18,"Description: ",false,wOwnerProductView)
	local mDesc = guiCreateMemo(147,99,280,56,item[3] or "",false,wOwnerProductView)

	local bTakeOff = guiCreateButton(9,161,142,27,"Take off",false,wOwnerProductView)
	addEventHandler( "onClientGUIClick", bTakeOff, function ()
		triggerServerEvent( "shop:takeOffProductFromShop", getLocalPlayer(), getLocalPlayer(), proID, item[1], item[2], itemName, shopElement, item[6])
		guiSetEnabled(wOwnerProductView, false)
		guiSetEnabled(wCustomShop, false)
		-- setTimer(function()
			-- closeOwnerProductView()
			-- hideGeneralshopUI()
		-- end, 3000, 1)
	end, false )


	local bSave = guiCreateButton(151,161,142,27,"Save",false,wOwnerProductView)
	addEventHandler( "onClientGUIClick", bSave, function ()
		local price = guiGetText(ePrice):gsub(",","")
		price = tonumber(price) or false
		local desc = guiGetText(mDesc):gsub("\n"," ")
		if price then
			triggerServerEvent( "shop:EditItemToShop", getLocalPlayer(), getLocalPlayer(), price, desc, proID, itemName, shopElement)
			guiSetEnabled(wOwnerProductView, false)
			guiSetEnabled(wCustomShop, false)
		else
			guiSetText(wOwnerProductView, "Invalid Price!")
			setTimer(function()
				guiSetText(wOwnerProductView,"Product Management")
			end, 3000, 1)
		end
	end, false )

	local bCancel = guiCreateButton(291,161,136,27,"Cancel",false,wOwnerProductView)
	addEventHandler( "onClientGUIClick", bCancel, function ()
		closeOwnerProductView()
	end, false )
end
addEvent("shop:ownerProductView", true )
addEventHandler("shop:ownerProductView", getRootElement(), ownerProductView)

function closeOwnerProductView()
	if wOwnerProductView then
		destroyElement(wOwnerProductView)
		wOwnerProductView = nil
		showCursor(false)
		guiSetInputEnabled(false)
	end
end


function customShopBuy(products, proID, shopElement)
	closeCustomShopBuy()
	showCursor(true)
	guiSetInputEnabled(true)
	local screenwidth, screenheight = guiGetScreenSize()
	local Width = 438
	local Height = 199
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2

	local item = {}
	if products and proID then
		for key, value in ipairs(products) do
			if value[7] == proID then
				item = value
				item[1] = value[2] --itemID
				item[2] = value[3] --itemValue
				item[3] = value[4] --description
				item[4] = value[5] --price
				item[5] = value[1] --id
				item[6] = value[8] --metadata
				break
			end
		end
	end

	wCustomShopBuy = guiCreateWindow( X, Y, Width, Height,"Product Purchase",false)

	local itemURL = nil

	if tonumber(item[1]) == 16 then --clothes
		local value = exports.global:explode(":",tostring(item[2]))
		local skinid = tonumber(value[1]) or 1
		itemURL = ":account/img/" .. ("%03d"):format( skinid or 1 ) .. ".png"
	elseif tonumber(item[1]) == 115 then -- weapons
		itemURL = ":item-system/images/-"..string.match(tostring(item[2]), "(%d+)")..".png"
	else -- other
		itemURL = ":item-system/images/"..tostring(item[1])..".png"
	end

	--outputDebugString(itemURL.." - "..item[1].." - "..item[2])

	local itemName = exports["item-system"]:getItemName( tonumber(item[1]), tostring(item[2]), item[6] ) or ""
	local itemValue = ""
	if not exports["item-system"]:getItemHideItemValue(tonumber(item[1])) then
		itemValue = exports["item-system"]:getItemValue( tonumber(item[1]), tostring(item[2]), item[6] ) or ""
	end
	local itemPrice = (tonumber(item[4]) or 0)

	local iProductImage = guiCreateStaticImage(9,27,128,128,itemURL,false,wCustomShopBuy)
	local lProductName = guiCreateLabel(147,27,280,18,"Product Name: "..itemName or ""..".",false,wCustomShopBuy)
	local lAmount = guiCreateLabel(147,45,280,18,"Details: "..itemValue or ""..".",false,wCustomShopBuy)
	local lPrice = guiCreateLabel(147,63,42,18,"Price: $",false,wCustomShopBuy)
	local ePrice = guiCreateLabel(189,62,238,20,exports.global:formatMoney(itemPrice),false,wCustomShopBuy)
	local lDesc = guiCreateLabel(147,81,66,18,"Description: ",false,wCustomShopBuy)
	local mDesc = guiCreateMemo(147,99,280,56,item[3] or "",false,wCustomShopBuy)

	guiMemoSetReadOnly(mDesc, true)

	local bankmoney = getElementData(getLocalPlayer(), "bankmoney") or 0
	local money = getElementData(getLocalPlayer(), "money") or 0

	--outputDebugString(bankmoney.."..".. money)

	local bPayByBank = guiCreateButton(9,161,142,27,"Pay by Debit Card",false,wCustomShopBuy)
	if bankmoney >= itemPrice then
		addEventHandler( "onClientGUIClick", bPayByBank, function ()
			triggerServerEvent( "shop:customShopBuy", getLocalPlayer(), proID, item[1], item[2], itemPrice,  itemName, true, shopElement, item[6])
			guiSetEnabled(wCustomShopBuy, false)
			guiSetEnabled(wCustomShop, false)
		end, false )
	else
		guiSetEnabled(bPayByBank, false)
	end

	local bPayByCash = guiCreateButton(151,161,142,27,"Pay By Cash",false,wCustomShopBuy)
	if money >= itemPrice then
		addEventHandler( "onClientGUIClick", bPayByCash, function ()
			triggerServerEvent( "shop:customShopBuy", getLocalPlayer(), proID, item[1], item[2], itemPrice, itemName, false, shopElement, item[6])
			guiSetEnabled(wCustomShopBuy, false)
			guiSetEnabled(wCustomShop, false)
		end, false )
	else
		guiSetEnabled(bPayByCash, false)
	end

	local bCancel = guiCreateButton(291,161,136,27,"Cancel",false,wCustomShopBuy)
	addEventHandler( "onClientGUIClick", bCancel, function ()
		closeCustomShopBuy()
	end, false )
end
addEvent("shop:customShopBuy", true )
addEventHandler("shop:customShopBuy", getRootElement(), customShopBuy)

function closeCustomShopBuy()
	if wCustomShopBuy then
		destroyElement(wCustomShopBuy)
		wCustomShopBuy = nil
		showCursor(false)
		guiSetInputEnabled(false)
	end
end

addEvent("shop:playPayWageSound", true)
addEventHandler("shop:playPayWageSound", root,
	function()
		setSoundVolume(playSound("playPayWageSound.mp3"), 0.2)
	end
)

addEvent("shop:playCollectMoneySound", true)
addEventHandler("shop:playCollectMoneySound", root,
	function()
		setSoundVolume(playSound("playCollectMoneySound.mp3"), 0.2)
	end
)

addEvent("shop:playBuySound", true)
addEventHandler("shop:playBuySound", root,
	function()
		playSound("playBuySound.mp3")
	end
)
