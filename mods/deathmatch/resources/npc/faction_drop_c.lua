--MAXIME
local gui = {}
function showCreateFactionDropItem(npcID)
	closeCreateFactionDropItem()
	if wCustomShop and isElement(wCustomShop) then
		guiSetEnabled(wCustomShop, false)
	end
	exports.global:playSoundSuccess()
	gui.main = guiCreateStaticImage(566,236,446,294,":resources/window_body.png",false)
	exports.global:centerWindow(gui.main)
	gui.lItem = guiCreateLabel(43,39,117,24,"Weapon:",false,gui.main)
	guiLabelSetVerticalAlign(gui.lItem,"center")
	guiSetFont(gui.lItem,"default-bold-small")

	gui.cItem = guiCreateComboBox(170,39,213,24,"None",false,gui.main)
	local comboItemIndex = {}
	comboItemIndex[0] = {nil, nil, "None"}
	guiComboBoxAddItem(gui.cItem, "None")
	local weaponList = exports.weapon:getFactionNpcItems()
	for i = 1, #weaponList do
		local itemName = weaponList[i][3]
		local itemID = weaponList[i][1]
		local itemValue = weaponList[i][2]
		guiComboBoxAddItem(gui.cItem, itemName)
		comboItemIndex[i] = {itemID, itemValue, itemName}
	end
	exports.global:guiComboBoxAdjustHeight(gui.cItem, 9)
	addEventHandler ( "onClientGUIComboBoxAccepted", gui.cItem, updateGUIs)

	gui.lCaliber = guiCreateLabel(43,73,117,24,"Caliber:",false,gui.main)
	guiLabelSetVerticalAlign(gui.lCaliber,"center")
	guiSetFont(gui.lCaliber,"default-bold-small")
	gui.eCaliber = guiCreateEdit(170,73,213,24,"",false,gui.main)
	guiEditSetMaxLength(gui.eCaliber, 50)

	gui.lItemDesc = guiCreateLabel(43,107,117,24,"Custom Name:",false,gui.main)
	guiLabelSetVerticalAlign(gui.lItemDesc,"center")
	guiSetFont(gui.lItemDesc,"default-bold-small")
	gui.eItemDesc = guiCreateEdit(170,107,213,24,"",false,gui.main)
	guiEditSetMaxLength(gui.eItemDesc, 50)

	local xOffset1 = 70
	gui.lPrice = guiCreateLabel(43,141,117,24,"Price:",false,gui.main)
	guiLabelSetVerticalAlign(gui.lPrice,"center")
	guiSetFont(gui.lPrice,"default-bold-small")
	gui.ePrice = guiCreateEdit(170-xOffset1,141,80,24,"1",false,gui.main)
	guiEditSetMaxLength(gui.ePrice, 50)

	local xOffset2 = 203
	gui.lQuan = guiCreateLabel(43+xOffset2,141,117,24,"Quantity:",false,gui.main)
	guiLabelSetVerticalAlign(gui.lQuan,"center")
	guiSetFont(gui.lQuan,"default-bold-small")
	gui.eQuan = guiCreateEdit(170-xOffset1+xOffset2,141,80,24,"1",false,gui.main)
	guiEditSetMaxLength(gui.eQuan, 50)

	gui.lRetock = guiCreateLabel(43,175,117,24,"Auto-restock:",false,gui.main)
	guiLabelSetVerticalAlign(gui.lRetock,"center")
	guiSetFont(gui.lRetock,"default-bold-small")
	gui.eRetock = guiCreateEdit(170,175,213,24,"0",false,gui.main)
	guiEditSetMaxLength(gui.eRetock, 50)

	gui.lExplain = guiCreateLabel(170,202,233,27,"Days after the item restocks with full pre-set quantity.\nInput 0 to disable auto-restock.",false,gui.main)
	guiLabelSetHorizontalAlign(gui.lExplain,"left",true)
	guiSetFont(gui.lExplain,"default-small")

	gui.bCancel = guiCreateButton(33,239,187,37,"Cancel",false,gui.main)
	guiSetFont(gui.bCancel,"default-bold-small")
	addEventHandler( "onClientGUIClick", gui.bCancel,function()
		closeCreateFactionDropItem()
	end, false )

	gui.bCreate = guiCreateButton(220,239,191,37,"Create",false,gui.main)
	guiSetFont(gui.bCreate,"default-bold-small")
	addEventHandler( "onClientGUIClick", gui.bCreate,function()
		if gui.main and isElement(gui.main) then
			guiSetEnabled(gui.main, false)
			guiSetText(gui.bCreate, "Sending request to server..")
		end
		local selectedItem = guiComboBoxGetSelected(gui.cItem)
		local itemID = weaponList[selectedItem][1]
		local itemValue = weaponList[selectedItem][2]
		local itemCaliber = guiGetText(gui.eCaliber)
		local itemDesc = guiGetText(gui.eItemDesc)
		local itemQuan = guiGetText(gui.eQuan)
		local itemRestock = guiGetText(gui.eRetock)
		local itemPrice = guiGetText(gui.ePrice)
		triggerServerEvent("shop:factionDropCreateItem", localPlayer, npcID, itemID, itemValue, itemPrice, itemQuan, itemCaliber, itemDesc, itemRestock, selectedItem)
	end, false )

	guiSetInputEnabled(true)
	showCursor(true)
	updateGUIs()
end

function closeCreateFactionDropItem()
	if gui.main and isElement(gui.main) then
		destroyElement(gui.main)
		gui = {}
		if wCustomShop and isElement(wCustomShop) then
			guiSetEnabled(wCustomShop, true)
		end
	end
	guiSetInputEnabled(false)
	showCursor(false)
end

function updateGUIs()
	if not gui.main or not isElement(gui.main) or not gui.cItem or not isElement(gui.cItem) then
		return false
	end

	local disableAll = function ()
		guiSetEnabled(gui.eCaliber, false)
		guiSetEnabled(gui.eItemDesc, false)
		guiSetEnabled(gui.eQuan, false)
		guiSetEnabled(gui.eRetock, false)
		guiSetEnabled(gui.ePrice, false)
		guiSetEnabled(gui.bCreate, false)
	end

	local index = guiComboBoxGetSelected(gui.cItem)
	if not index or index < 1 then
		disableAll()
		return false
	end

	local weaponList = exports.weapon:getFactionNpcItems()

	local itemID = weaponList[index][1]
	if not itemID then
		disableAll()
	else
		guiSetEnabled(gui.eItemDesc, true)
		guiSetEnabled(gui.eQuan, true)
		guiSetEnabled(gui.eRetock, true)
		guiSetEnabled(gui.bCreate, true)
		guiSetText(gui.eCaliber, "")
		guiSetText(gui.eItemDesc, "")
		guiSetEnabled(gui.ePrice, true)
		if itemID == 115 then --gun
			guiSetText(gui.lItemDesc, "Custom Name:")
			--guiSetEnabled(gui.eCaliber, true)
			guiSetText(gui.eItemDesc, "")
		elseif itemID == 116 then --ammo
			guiSetText(gui.lItemDesc, "Bullets/Mag:")
			--guiSetEnabled(gui.eCaliber, false)
			local pack = exports.weapon:getAmmo(weaponList[index][2])
			guiSetText(gui.eItemDesc, pack and pack.rounds or "1")
		end
	end
end

function factionDropResponseFromServer(state, msg)
	if gui.main and isElement(gui.main) then
		guiSetEnabled(gui.main, true)
		guiSetText(gui.bCreate, "Create")
	end

	if state then
		exports.global:playSoundCreate()
		closeCreateFactionDropItem()
	else
		exports.global:playSoundError()
		guiSetText(gui.lExplain, msg)
		guiLabelSetColor(gui.lExplain, 255,0,0)
	end

end
addEvent("shop:factionDropResponseFromServer", true )
addEventHandler("shop:factionDropResponseFromServer", root, factionDropResponseFromServer)

function factionDropWeaponBuy(products, proID, shopElement)
	closeFactionDropWeaponBuy()
	showCursor(true)
	guiSetInputEnabled(true)
	local screenwidth, screenheight = guiGetScreenSize()
	local Width = 438
	local Height = 199
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2

	local item = {}
	local quantity = 0
	if products and proID then
		for key, value in ipairs(products) do
			if value["pID"] == proID then
				item = value
				quantity = tonumber(value["pQuantity"])
				--[[item[1] = value[2]
				item[2] = value[3]
				item[3] = value[4]
				item[4] = value[5]
				item[5] = value[1]
				]]
				break
			end
		end
	end

	wfactionDropWeaponBuy = guiCreateWindow( X, Y, Width, Height,"Product Purchase",false)
	exports.global:playSoundSuccess()
	local itemURL = exports['item-system']:getImage(tonumber(item["pItemID"]), item["pItemValue"])
	local itemName = exports["item-system"]:getItemName( tonumber(item["pItemID"]), tostring(item["pItemValue"]) ) or ""
	local itemValue = exports["item-system"]:getItemValue( tonumber(item["pItemID"]), tostring(item["pItemValue"]) ) or ""
	local itemPrice = (tonumber(item["pPrice"]) or 0)
	local itemDesc = ""
	local iProductImage = guiCreateStaticImage(9,27,128,128,itemURL,false,wfactionDropWeaponBuy)
	local lProductName = guiCreateLabel(147,27,280,18,"Product Name: "..itemName or ""..".",false,wfactionDropWeaponBuy)
	local lAmount = guiCreateLabel(147,45,280,18,"Details: "..itemValue or ""..".",false,wfactionDropWeaponBuy)
	local lPrice = guiCreateLabel(147,63,42,18,"Price: $",false,wfactionDropWeaponBuy)
	local ePrice = guiCreateLabel(189,62,238,20,exports.global:formatMoney(itemPrice),false,wfactionDropWeaponBuy)
	local lDesc = guiCreateLabel(147,81,250,18,"In-Character Reason to purchase this item: ",false,wfactionDropWeaponBuy)
	local mDesc = guiCreateMemo(147,99,280,56,itemDesc or "",false,wfactionDropWeaponBuy)

	local bankmoney = getElementData(localPlayer, "bankmoney") or 0
	local money = getElementData(localPlayer, "money") or 0

	--outputDebugString(bankmoney.."..".. money)

	bRemove = guiCreateButton(9,161,142,27,"Take Down",false,wfactionDropWeaponBuy)

	if canPlayerAdminShop(localPlayer) then
		addEventHandler( "onClientGUIClick", bRemove, function ()
			triggerServerEvent( "shop:factionDropTakeDown", localPlayer, tonumber(proID), shopElement)
			guiSetText(bRemove, "Taking item down..")
			togFactionDropWeaponBuy(false)
		end, false )
	else
		guiSetEnabled(bRemove, false)
	end

	local bPayByCash = guiCreateButton(151,161,142,27,"Pay By Cash",false,wfactionDropWeaponBuy)
	if money >= itemPrice and quantity > 0 then
		addEventHandler( "onClientGUIClick", bPayByCash, function ()
			triggerServerEvent( "shop:factionDropWeaponBuy", localPlayer, tonumber(proID), shopElement, guiGetText(mDesc))
			guiSetText(bPayByCash, "Buying..")
			togFactionDropWeaponBuy(false)
		end, false )
	else
		guiSetEnabled(bPayByCash, false)
	end
	guiSetEnabled(bPayByCash, false)
	addEventHandler("onClientGUIChanged", mDesc, function(element)
		if money >= itemPrice then
			local text = guiGetText(element)
			if string.len(text) < 10 or string.len(text) > 200 then
				guiSetEnabled(bPayByCash, false)
			else
				guiSetEnabled(bPayByCash, true)
			end
		end
	end)


	local bCancel = guiCreateButton(291,161,136,27,"Cancel",false,wfactionDropWeaponBuy)
	addEventHandler( "onClientGUIClick", bCancel, function ()
		closeFactionDropWeaponBuy()
	end, false )
end
addEvent("shop:factionDropWeaponBuy", true )
addEventHandler("shop:factionDropWeaponBuy", getRootElement(), factionDropWeaponBuy)

function closeFactionDropWeaponBuy()
	if wfactionDropWeaponBuy then
		destroyElement(wfactionDropWeaponBuy)
		wfactionDropWeaponBuy = nil
		showCursor(false)
		guiSetInputEnabled(false)
		togMainShop(true)
	end
end

function togFactionDropWeaponBuy(state)
	if wfactionDropWeaponBuy and isElement(wfactionDropWeaponBuy) then
		guiSetEnabled(wfactionDropWeaponBuy, state)
	end
end

function factionDropResponseFromServer2(state, msg)
	togFactionDropWeaponBuy(true)
	closeFactionDropWeaponBuy()
	local r, g, b = 255, 0, 0
	if state then
		r = 0
		g = 255
		exports.global:playSoundCreate()
	else
		exports.global:playSoundError()
	end
	outputChatBox(msg, r, g, b)
end
addEvent("shop:factionDropResponseFromServer:2", true )
addEventHandler("shop:factionDropResponseFromServer:2", root, factionDropResponseFromServer2)
