--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

wGeneralshop, iClothesPreview, bShrink  = nil
bSend, tBizManagement, tGoodBye = nil
shop = nil
shop_type = nil

BizNoteFont = guiCreateFont( ":resources/BizNote.ttf", 30 )
BizNoteFont18 = guiCreateFont( ":resources/BizNote.ttf", 18 )
BizNoteFont2 = guiCreateFont( "seguisb.ttf", 11 )

coolDownSend = 1 -- Minutes

local fdgw = {}

-- returns [item index in current shop], [actual item]
function getSelectedItem( grid )
	if grid then
		local row, col = guiGridListGetSelectedItem(grid)
		if row > -1 and col > -1 then
			local index = tonumber(guiGridListGetItemData(grid, row, 1)) -- 1 = cName
			if index then
				local item = getItemFromIndex( shop_type, index )
				return index, item
			end
		end
	end
end

local products = {}

-- creates a shop window, hooray.
function showGeneralshopUI(shop_type, race, gender, discount, products1)
	products = products1
	local ped = source
	if not wCustomShop and not wAddingItemsToShop and not wGeneralshop and not getElementData(localPlayer, "shop:NoAccess" ) then
		setElementData(localPlayer, "shop:NoAccess", true, true )
		if shop_type==17 then
			--CUSTOM SHOP / MAXIME

			local screenwidth, screenheight = guiGetScreenSize()
			local Width = 756
			local Height = 432
			local X = (screenwidth - Width)/2
			local Y = (screenheight - Height)/2

			local isClientBizOwner, bizName, bizNote, interiorSupplies, govOwned, int_element = isBizOwner(localPlayer)

			if not bizName then
				hideGeneralshopUI()
				return false
			end

			guiSetInputEnabled(true)
			showCursor(true)

			wCustomShop = guiCreateWindow(X,Y,Width,Height,bizName.." - Custom Shop",false)
			guiWindowSetSizable(wCustomShop,false)

			local shopTabPanel = guiCreateTabPanel(9,26,738,396,false,wCustomShop)
			local tProducts = guiCreateTab ( "Products" , shopTabPanel )
			local gProducts = guiCreateGridList ( 0, 0, 1, 0.9, true, tProducts)

			local lWelcomeText = guiCreateLabel(0,0.89,0.848,0.1,'"Welcome to '..bizName..'!" Double click on an item to buy it!',true,tProducts)
			bCloseStatic = guiCreateButton(0.85, 0.90 , 0.15, 0.089, "Close", true, tProducts)
			guiSetFont(bCloseStatic, BizNoteFont2)
			addEventHandler( "onClientGUIClick", bCloseStatic,hideGeneralshopUI , false )

			guiLabelSetVerticalAlign(lWelcomeText,"center")
			guiLabelSetHorizontalAlign(lWelcomeText,"center",false)
			guiSetFont(lWelcomeText, BizNoteFont18)

			local colName = guiGridListAddColumn(gProducts,"Name",0.2)
			local colAmount = guiGridListAddColumn(gProducts,"Details",0.2)
			local colPrice = guiGridListAddColumn(gProducts,"Price",0.1)
			local colDesc = guiGridListAddColumn(gProducts,"Description",0.36)
			--local colDate = guiGridListAddColumn(gProducts,"Published Date",0.15)
			local colProductID = guiGridListAddColumn(gProducts,"Product ID",0.1)
			local currentCap = 0
			for _, record in ipairs(products) do
				local row = guiGridListAddRow(gProducts)
				local itemName = exports["item-system"]:getItemName( tonumber(record[2]), tostring(record[3]), record[8] )
				local itemValue = ""
				if not exports["item-system"]:getItemHideItemValue(tonumber(record[2])) then
					itemValue = exports["item-system"]:getItemValue( tonumber(record[2]), tostring(record[3]), record[8] )
				end
				local itemPrice = "$"..exports.global:formatMoney(math.ceil(tonumber(record[5] or 0))) or false
				guiGridListSetItemText(gProducts, row, colName, itemName or "Unknown", false, false)
				guiGridListSetItemText(gProducts, row, colAmount, itemValue or "Unknown", false, false)
				guiGridListSetItemText(gProducts, row, colPrice, itemPrice, false, true)
				guiGridListSetItemText(gProducts, row, colDesc, record[4] or "Unknown", false, false)
				--guiGridListSetItemText(gProducts, row, colDate, record[6], false, false)
				guiGridListSetItemText(gProducts, row, colProductID, record[7] or "Unknown", false, true)
				currentCap = currentCap + 1
			end
			setElementData(ped, "currentCap", currentCap, true)

			if isClientBizOwner or exports.global:hasItem(localPlayer, 5, getElementDimension(localPlayer)) then
				----------------------START EDIT CONTACT-------------------------------------------------------
				tGoodBye = guiCreateTab ( "Edit Contact Info" , shopTabPanel )

				local lTitle1 = guiCreateLabel(11,19,716,56,("Edit Contact Info - "..bizName),false,tGoodBye)
					--guiLabelSetVerticalAlign(lTitle1[1],"center")
					guiLabelSetHorizontalAlign(lTitle1,"center",false)
					guiSetFont(lTitle1, BizNoteFont)
				-- Fetching info
				local sOwner = ""
				local sPhone = ""
				local sFormatedPhone = ""
				local sEmail = ""
				local sForum = ""
				local sContactInfo = getElementData(ped, "sContactInfo") or false
				if sContactInfo then
					sOwner = sContactInfo[1] or ""
					sPhone = sContactInfo[2] or ""
					sFormatedPhone = ""
					if sPhone ~= "" then
						sFormatedPhone = "(+555) "..exports.global:formatMoney(sPhone)
					end
					sEmail = sContactInfo[3] or ""
					sForum = sContactInfo[4] or ""
				end

				local lOwner = guiCreateLabel(11,75,100,20,"- Owner:",false,tGoodBye)
				local eOwner = guiCreateEdit(111,75,600,20,sOwner,false,tGoodBye)
				local lPhone = guiCreateLabel(11,95,100,20,"- Phone Number:",false,tGoodBye)
				local ePhone = guiCreateEdit(111,95,600,20,sPhone,false,tGoodBye)
				local lEmail = guiCreateLabel(11,115,100,20,"- Email Address:",false,tGoodBye)
				local eEmail = guiCreateEdit(111,115,600,20,sEmail,false,tGoodBye)
				local lForums = guiCreateLabel(11,135,100,20,"((Forums Name)):",false,tGoodBye)
				local eForums = guiCreateEdit(111,135,600,20,sForum,false,tGoodBye)

				guiEditSetMaxLength ( eOwner, 100 )
				guiEditSetMaxLength ( ePhone, 100 )
				guiEditSetMaxLength ( eEmail, 100 )
				guiEditSetMaxLength ( eForums, 100 )

				local lBizNote = guiCreateLabel(0.01,0.5,1,0.1,"- Biz Note:",true,tGoodBye)

				local eBizNote = guiCreateEdit ( 0.01, 0.58, 0.98, 0.1,bizNote, true, tGoodBye)
				guiEditSetMaxLength ( eBizNote, 100 )

				bSend = guiCreateButton(0.01, 0.88, 0.49, 0.1, "Save", true, tGoodBye)
				local contactName, contactContent = nil

				addEventHandler( "onClientGUIClick", bSend, function()
					if guiGetText(eBizNote) ~= "" then
						triggerServerEvent("businessSystem:setBizNote", localPlayer,localPlayer, "setbiznote", guiGetText(eBizNote))
					end

					if guiGetText(ePhone) ~= "" and not tonumber(guiGetText(ePhone)) then
						guiSetText(ePhone, "Invalid Number")
					else
						triggerServerEvent("shop:saveContactInfo", localPlayer, ped, {guiGetText(eOwner),guiGetText(ePhone),guiGetText(eEmail),guiGetText(eForums)})
						hideGeneralshopUI()
					end


				end, false )

				local bClose = guiCreateButton(0.5, 0.88, 0.49, 0.1, "Close", true, tGoodBye)
				addEventHandler( "onClientGUIClick", bClose, hideGeneralshopUI, false )


				----------------------START BIZ MANAGEMENT-------------------------------------------------------
				local GUIEditor_Memo = {}
				local GUIEditor_Label = {}

				tBizManagement = guiCreateTab ( "Business Management" , shopTabPanel )

				GUIEditor_Label[1] = guiCreateLabel(11,19,716,56,"Business Management - "..bizName or "",false,tBizManagement)
					--guiLabelSetVerticalAlign(GUIEditor_Label[1],"center")
					guiLabelSetHorizontalAlign(GUIEditor_Label[1],"center",false)
					guiSetFont(GUIEditor_Label[1], BizNoteFont)

				local sCapacity = tonumber(getElementData(ped, "sCapacity")) or 0
				local sIncome = tonumber(getElementData(ped, "sIncome")) or 0
				local sPendingWage = tonumber(getElementData(ped, "sPendingWage")) or 0
				local sSales = getElementData(ped, "sSales") or ""
				local sProfit = sIncome-sPendingWage

				guiSetText(lWelcomeText,'"Welcome boss! How are you doing?" || '..currentCap..'/'..sCapacity..' products , Total Income: $'..exports.global:formatMoney(sIncome)..'.')

				GUIEditor_Label[2] = guiCreateLabel(11,75,716,20,"- Capacity: "..sCapacity.." (Max number of products the shop can hold, you have to pay $1/hour more for 5 additional products)",false,tBizManagement)
				GUIEditor_Label[3] = guiCreateLabel(11,95,716,20,"- Income: $"..exports.global:formatMoney(sIncome),false,tBizManagement)
				GUIEditor_Label[4] = guiCreateLabel(11,115,716,20,"- Staff Payment: $"..exports.global:formatMoney(sPendingWage).." ($"..exports.global:formatMoney(sCapacity/wageRate).."/hour)",false,tBizManagement)
				GUIEditor_Label[5] = guiCreateLabel(11,135,716,20,"- Profit: $"..exports.global:formatMoney(sProfit),false,tBizManagement)
				GUIEditor_Label[6] = guiCreateLabel(11,155,57,19,"- Sales: ",false,tBizManagement)
				GUIEditor_Memo[1] = guiCreateMemo(11,179,498,184,sSales,false,tBizManagement)
				guiMemoSetReadOnly(GUIEditor_Memo[1], true)

				if sProfit < 0 then
					guiLabelSetColor ( GUIEditor_Label[5], 255, 0, 0)
					if sProfit < (0 - warningDebtAmount) then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (WARNING: If you're in debt of more than $"..exports.global:formatMoney(limitDebtAmount)..", your staff will quit job)." )
						guiLabelSetColor ( GUIEditor_Label[5], 255, 0, 0)

					end
				elseif sProfit == 0 then
				else
					if sProfit < 500 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Average).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 255, 0)
					elseif sProfit >= 500 and sProfit < 1000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Good!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 245, 0)
					elseif sProfit >= 1000 and sProfit < 2000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Very Good!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 235, 0)
					elseif sProfit >= 2000 and sProfit < 4000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Excellent!!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 225, 0)
					elseif sProfit >= 4000 and sProfit < 8000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Outstanding!!!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 215, 0)
					elseif sProfit >= 8000 and sProfit < 20000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Awesome!!!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 205, 0)
					elseif sProfit >= 20000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Mother of business!!!!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 195, 0)
					end
				end
				---------------------
				local bExpand = guiCreateButton(0.695, 0.48, 0.15, 0.1, "Expand Biz", true, tBizManagement)
				guiSetFont(bExpand, BizNoteFont2)
				addEventHandler( "onClientGUIClick", bExpand, function ()
					setElementData(ped, "sCapacity", tonumber(getElementData(ped, "sCapacity")) + 1, true)
					triggerServerEvent("shop:expand", localPlayer , getElementData(ped, "dbid"), getElementData(ped, "sCapacity") )
					guiSetText(GUIEditor_Label[2], "- Capacity: "..tostring(getElementData(ped, "sCapacity")).." (Max number of products the shop can hold, you have to pay $1/hour more for "..wageRate.." additional products)")
					guiSetText(GUIEditor_Label[4] , "- Staff Payment: $"..exports.global:formatMoney(sPendingWage).." ($"..exports.global:formatMoney(getElementData(ped, "sCapacity")/wageRate).."/hour)")
					if tonumber(getElementData(ped, "sCapacity")) <= tonumber(getElementData(ped, "currentCap")) and tonumber(getElementData(ped, "sCapacity")) <= 10 then
						guiSetEnabled(bShrink, false)
					else
						guiSetEnabled(bShrink, true)
					end
				end, false )
				-------------------------
				bShrink = guiCreateButton(0.845, 0.48, 0.15, 0.1, "Shrink Biz", true, tBizManagement)
				guiSetFont(bShrink, BizNoteFont2)
				addEventHandler( "onClientGUIClick", bShrink, function ()
					if tonumber(getElementData(ped, "sCapacity")) > tonumber(getElementData(ped, "currentCap")) and tonumber(getElementData(ped, "sCapacity")) > 10 then
						guiSetEnabled(bShrink, true)
						setElementData(ped, "sCapacity", tonumber(getElementData(ped, "sCapacity")) - 1, true)
						triggerServerEvent("shop:expand", localPlayer , getElementData(ped, "dbid"), getElementData(ped, "sCapacity") )
						guiSetText(GUIEditor_Label[2], "- Capacity: "..tostring(getElementData(ped, "sCapacity")).." (Max number of products the shop can hold, you have to pay $1/hour more for "..wageRate.." additional products)")
						guiSetText(GUIEditor_Label[4] , "- Staff Payment: $"..exports.global:formatMoney(sPendingWage).." ($"..exports.global:formatMoney(getElementData(ped, "sCapacity")/wageRate).."/hour)")
					else
						guiSetEnabled(bShrink, false)
					end
				end, false )
				---------------------------
				local bClearSaleLogs = guiCreateButton(0.695, 0.58, 0.3, 0.1, "Clear SaleLogs", true, tBizManagement)
				guiSetFont(bClearSaleLogs, BizNoteFont2)
				addEventHandler( "onClientGUIClick", bClearSaleLogs, function ()
					guiSetText(GUIEditor_Memo[1],"")
					setElementData(ped, "sSales", "", true)
					triggerServerEvent("shop:updateSaleLogs", localPlayer, localPlayer, getElementData(ped, "dbid") , "")
				end, false )

				--------------------------------

				local bPayWage = guiCreateButton(0.695, 0.68, 0.3, 0.1, "Pay Staff", true, tBizManagement)
				guiSetFont(bPayWage, BizNoteFont2)
				if sPendingWage > 0 then
					addEventHandler( "onClientGUIClick", bPayWage, function ()
						guiSetVisible(wCustomShop, false)
						triggerServerEvent("shop:solvePendingWage", localPlayer, localPlayer, ped)
						hideGeneralshopUI()
					end, false )
				else
					guiSetEnabled(bPayWage, false)
				end

				--------------------------------
				local bCollectProfit = guiCreateButton(0.695, 0.78, 0.3, 0.1, "Collect Profit", true, tBizManagement)
				guiSetFont(bCollectProfit, BizNoteFont2)
				if (sPendingWage > 0) or (sIncome > 0) then
					addEventHandler( "onClientGUIClick", bCollectProfit, function ()
						guiSetVisible(wCustomShop, false)
						triggerServerEvent("shop:collectMoney", ped, int_element)
						hideGeneralshopUI()
					end, false )
				else
					guiSetEnabled(bCollectProfit, false)
				end

				local bClose = guiCreateButton(0.695, 0.88, 0.3, 0.1, "Close", true, tBizManagement)
				guiSetFont(bClose, BizNoteFont2)
				addEventHandler( "onClientGUIClick", bClose, hideGeneralshopUI, false )
			else
				-----------------------------------------CUSTOMER PANEL-----------------------------------------------------------------

				tGoodBye = guiCreateTab ( "Contact Info" , shopTabPanel )

				local lTitle1 = guiCreateLabel(11,19,716,56,(bizName.." - See you again!"),false,tGoodBye)
					--guiLabelSetVerticalAlign(lTitle1[1],"center")
					guiLabelSetHorizontalAlign(lTitle1,"center",false)
					guiSetFont(lTitle1, BizNoteFont)
				-- Fetching info
				local sOwner = ""
				local sPhone = ""
				local sFormatedPhone = ""
				local sEmail = ""
				local sForum = ""
				local sContactInfo = getElementData(ped, "sContactInfo") or false
				if sContactInfo then
					sOwner = sContactInfo[1] or ""
					sPhone = sContactInfo[2] or ""
					sFormatedPhone = ""
					if sPhone ~= "" then
						sFormatedPhone = "(+555) "..exports.global:formatMoney(sPhone)
					end
					sEmail = sContactInfo[3] or ""
					sForum = sContactInfo[4] or ""
				end

				local lOwner = guiCreateLabel(11,75,716,20,"- Owner: "..sOwner.."",false,tGoodBye)
				local lPhone = guiCreateLabel(11,95,716,20,"- Phone Number: "..sFormatedPhone.."",false,tGoodBye)
				local lEmail = guiCreateLabel(11,115,716,20,"- Email Address: "..sEmail.."",false,tGoodBye)
				local lForums = guiCreateLabel(11,135,716,20,"- ((Forums Name: "..sForum.."))",false,tGoodBye)
				local lGuide = guiCreateLabel(0.01,0.5,1,0.1,"        'Hey, I can pass your message to my bosses if you want': ",true,tGoodBye)

				local eBargainName = guiCreateEdit ( 0.01, 0.58, 0.19, 0.1,"your identity", true, tGoodBye)
				addEventHandler( "onClientGUIClick", eBargainName, function()
					guiSetText(eBargainName, "")
				end, false )

				local eContent = guiCreateEdit ( 0.2, 0.58, 0.79, 0.1,"content", true, tGoodBye)
				guiEditSetMaxLength ( eContent, 95 )
				addEventHandler( "onClientGUIClick", eContent, function()
					guiSetText(eContent, "")
				end, false )

				bSend = guiCreateButton(0.01, 0.88, 0.49, 0.1, "Send", true, tGoodBye)
				local contactName, contactContent = nil

				local cooldown = getElementData(localPlayer, "shop:coolDown:contact")
				if not cooldown or getTickCount() - cooldown > 60000*coolDownSend then
					guiSetText(bSend, "Send")
					guiSetEnabled(bSend, true)
				else
					guiSetText(bSend, "(You can send another message in "..coolDownSend.." minute(s).)")
					guiSetEnabled(bSend, false)
				end

				addEventHandler( "onClientGUIClick", bSend, function()
					contactContent = guiGetText(eContent)
					if contactContent and contactContent ~= "" and contactContent ~= "content" then
						contactName = guiGetText(eBargainName):gsub("_"," ")
						if contactName == "" or contactName == "your identity" then
							contactName = "A Customer"
						else
							if getElementData(localPlayer, "gender") == 0 then
								contactName = "Mr. "..contactName
							else
								contactName = "Mrs. "..contactName
							end
						end

						triggerServerEvent("shop:notifyAllShopOwners", localPlayer , ped, "Hey boss! Read this '"..contactContent.."', said "..contactName..".")
						guiSetText(bSend, "(You can send another message in "..coolDownSend.." minute(s).)")
						guiSetEnabled(bSend, false)
						guiSetText(eContent, "")
						setElementData(localPlayer, "shop:coolDown:contact", getTickCount(), false)
					end
				end, false )

				addEventHandler( "onClientGUIAccepted", eContent,function()
					contactContent = guiGetText(eContent):gsub("_"," ")
					if contactContent and contactContent ~= "" and contactContent ~= "content" then
						contactName = guiGetText(eBargainName)
						if contactName == "" or contactName == "your identity" then
							contactName = "A Customer"
						else
							if getElementData(localPlayer, "gender") == 0 then
								contactName = "Mr. "..contactName
							else
								contactName = "Mrs. "..contactName
							end
						end

						triggerServerEvent("shop:notifyAllShopOwners", localPlayer , ped, "Hey boss! Read this '"..contactContent.."', said "..contactName..".")
						guiSetText(bSend, "(You can send another message in "..coolDownSend.." minute(s).)")
						guiSetEnabled(bSend, false)
						guiSetText(eContent, "")
						setElementData(localPlayer, "shop:coolDown:contact", getTickCount(), false)
					end
				end, false )

				local bClose = guiCreateButton(0.5, 0.88, 0.49, 0.1, "Close", true, tGoodBye)
				addEventHandler( "onClientGUIClick", bClose, hideGeneralshopUI, false )
			end

			addEventHandler("onClientGUIDoubleClick", gProducts, function ()
				if products then
					local row, col = guiGridListGetSelectedItem(gProducts)
					if (row==-1) or (col==-1) then
						--do nothing
					else
						local proID = tostring(guiGridListGetItemText(gProducts, row, 5))
						if isClientBizOwner then
							triggerEvent("shop:ownerProductView", root,  products, proID, ped)
						else
							triggerEvent("shop:customShopBuy", root,  products, proID, ped)
						end
					end
				end
			end, false)

			local originalskin = getElementModel(ped)
			local ifCustom = getElementData(ped, "clothing:id") or nil
			addEventHandler("onClientGUIClick", gProducts, function ()
				if products then
					local row, col = guiGridListGetSelectedItem(gProducts)
					if (row==-1) or (col==-1) then
						--do nothing
					else
						local isClothing = tostring(guiGridListGetItemText(gProducts, row, 1))
						local isCustomSkin = tostring(guiGridListGetItemText(gProducts, row, 2))
						if isClothing == "Clothes" and string.find(isCustomSkin, ":") then
							local skinData = split(isCustomSkin, ':')
							skin = tonumber(skinData[1])
							skinID = tonumber(skinData[2])
							setElementModel(ped, skin)
							setElementData(ped, "clothing:id", skinID, false)

							-- just for 5 seconds, and it's on client side
							setTimer(function ()
								setElementModel(ped, originalskin)
								setElementData(ped, "clothing:id", ifCustom)
							end, 5000, 1)
						end
					end
				end
			end, false)
			setSoundVolume(playSound(":resources/inv_open.mp3"), 0.3)
		elseif shop_type==18 then --Faction Drop NPC - General Items
			--shit
			--setSoundVolume(playSound(":resources/inv_open.mp3"), 0.3)
		elseif shop_type==19 then --Faction Drop NPC - Weapons
			if not canPlayerViewShop(localPlayer, ped) and not canPlayerAdminShop(localPlayer) then
				hideGeneralshopUI()
				sendRefusingLocalChat(ped)
				return false
			end

			local screenwidth, screenheight = guiGetScreenSize()
			local Width = 756
			local Height = 432
			local X = (screenwidth - Width)/2
			local Y = (screenheight - Height)/2

			guiSetInputEnabled(true)
			showCursor(true)

			wCustomShop = guiCreateWindow(X,Y,Width,Height,"Faction Drop NPC for Weapons",false)
			guiWindowSetSizable(wCustomShop,false)

			local shopTabPanel = guiCreateTabPanel(9,26,738,396,false,wCustomShop)
			local tProducts = guiCreateTab ( "Products" , shopTabPanel )
			fdgw.gProducts = guiCreateGridList ( 0, 0, 1, 0.9, true, tProducts)

			local lWelcomeText = guiCreateLabel(0,0.89,0.848,0.1,'Double click on an item to buy it!',true,tProducts)
			bCloseStatic = guiCreateButton(0.85, 0.90 , 0.15, 0.089, "Close", true, tProducts)
			guiSetFont(bCloseStatic, BizNoteFont2)
			addEventHandler( "onClientGUIClick", bCloseStatic,hideGeneralshopUI , false )

			guiLabelSetVerticalAlign(lWelcomeText,"center")
			guiLabelSetHorizontalAlign(lWelcomeText,"center",false)
			guiSetFont(lWelcomeText, BizNoteFont18)

			fdgw.colProductID = guiGridListAddColumn(fdgw.gProducts,"ID",0.08)
			fdgw.colName = guiGridListAddColumn(fdgw.gProducts,"Name",0.18)
			fdgw.colPrice = guiGridListAddColumn(fdgw.gProducts,"Price",0.08)
			fdgw.colDesc = guiGridListAddColumn(fdgw.gProducts,"Description",0.4)
			fdgw.colQuantity = guiGridListAddColumn(fdgw.gProducts,"In stock",0.06)
			fdgw.colRestock = guiGridListAddColumn(fdgw.gProducts,"Restocking in",0.15)

			for _, record in ipairs(products) do
				local row = guiGridListAddRow(fdgw.gProducts)
				local itemName = exports["item-system"]:getItemName( tonumber(record["pItemID"]), tostring(record["pItemValue"]) )
				local itemValue = exports["item-system"]:getItemValue( tonumber(record["pItemID"]), tostring(record["pItemValue"]) )
				local description = exports["item-system"]:getItemDescription( tonumber(record["pItemID"]), itemValue )
				local itemPrice = "$"..exports.global:formatMoney(math.floor(tonumber(record["pPrice"] or 0)))
				guiGridListSetItemText(fdgw.gProducts, row, fdgw.colName, itemName or "Unknown", false, false)
				guiGridListSetItemText(fdgw.gProducts, row, fdgw.colPrice, itemPrice, false, true)
				guiGridListSetItemText(fdgw.gProducts, row, fdgw.colDesc, description, false, false)
				guiGridListSetItemText(fdgw.gProducts, row, fdgw.colQuantity, exports.global:formatMoney(record["pQuantity"]), false, false)
				guiGridListSetItemText(fdgw.gProducts, row, fdgw.colProductID, record["pID"], false, true)
				local pRestockInFinal = "Never"
				local pRestockInterval = tonumber(record["pRestockInterval"]) or 0
				local pRestockIn = record["pRestockIn"]
				if pRestockIn and tonumber(pRestockIn) and pRestockInterval > 0 then
					pRestockIn = tonumber(pRestockIn)
					if pRestockIn == 0 then
						pRestockInFinal = "Today"
					elseif pRestockIn == 1 then
						pRestockInFinal = "Tomorrow"
					elseif pRestockIn == 2 then
						pRestockInFinal = "The day after tomorrow"
					elseif pRestockIn > 2 then
						pRestockInFinal = pRestockIn.." days"
					end
				end
				outputDebugString(pRestockIn)
				guiGridListSetItemText(fdgw.gProducts, row, fdgw.colRestock,  pRestockInFinal, false, true)
			end

			addEventHandler("onClientGUIDoubleClick", fdgw.gProducts, function ()
				if products then
					local row, col = guiGridListGetSelectedItem(fdgw.gProducts)
					if (row==-1) or (col==-1) then
						--do nothing
					else
						local quan = tostring(guiGridListGetItemText(fdgw.gProducts, row, 5))
						if tonumber(quan) <= 0 and not canPlayerAdminShop(localPlayer) then
							exports.global:playSoundError()
							return false
						end
						local proID = tostring(guiGridListGetItemText(fdgw.gProducts, row, 1))
						togMainShop(false)
						triggerEvent("shop:factionDropWeaponBuy", localPlayer,  products, proID, ped)
					end
				end
			end, false)

			local updateConfigGUI = function()
				if ped and tProducts and lWelcomeText then
					if getElementData(ped, "faction_belong") <= 0 then
						guiSetEnabled(tProducts, false)
						if addItemBtn and isElement(addItemBtn) then
							guiSetEnabled(addItemBtn, false)
						end
						guiSetText(lWelcomeText, "This NPC requires Lead Admin's configurations.")
					else
						guiSetEnabled(tProducts, true)
						if addItemBtn and isElement(addItemBtn) then
							guiSetEnabled(addItemBtn, true)
						end
						guiSetText(lWelcomeText, "Double click on an item to buy it!")
					end
				end
			end
			updateConfigGUI()

			if canPlayerAdminShop(localPlayer) then
				addItemBtn = guiCreateButton(0.85-0.15, 0.90 , 0.15, 0.089, "Create Item", true, tProducts)
				guiSetFont(addItemBtn, BizNoteFont2)
				addEventHandler( "onClientGUIClick", addItemBtn,function()
					showCreateFactionDropItem(getElementData(ped, "dbid"))
				end, false )



				tBizManagement = guiCreateTab ( "Configurations" , shopTabPanel )
				local l1 = guiCreateLabel(11,19,716,56,"Faction Drop NPC Configurations",false,tBizManagement)
				guiLabelSetHorizontalAlign(l1,"center",false)
				guiSetFont(l1, BizNoteFont)

				local line = 40
				local col = 200
				local xOffset = 30
				local lTeam = guiCreateLabel(xOffset,line*3,716,56,"Grant accesses to Faction:",false,tBizManagement)
				guiSetFont(lTeam, "default-bold-small")
				local cFaction =  guiCreateComboBox ( xOffset+col,line*3,col*2,150, "None", false, tBizManagement )
				local counter = 0
				local comboIndex1 = {}
				comboIndex1[0] = {"None", 0}
				guiComboBoxAddItem(cFaction, "None")
				local factions = getElementsByType("team")
				for i = 1, #factions do
					local factionName = getTeamName(factions[i])
					if factionName ~= "Citizen" then
						counter = counter + 1
						guiComboBoxAddItem(cFaction, factionName)
						comboIndex1[counter] = {getTeamName(factions[i]), getElementData(factions[i], "id")}
						outputDebugString(counter.." - "..tostring(getTeamName(factions[i])).." - ".. tostring(getElementData(factions[i], "id")))
					end
				end
				if counter > 2 then
					counter = counter - 1
				end
				guiComboBoxSetSelected ( cFaction, getComboIndexFromFactionID(comboIndex1,getElementData(ped, "faction_belong")) )
				local lMember = guiCreateLabel(xOffset,line*4,716,56,"Who can buy items from this NPC:",false,tBizManagement)
				guiSetFont(lMember, "default-bold-small")
				local cMember =  guiCreateComboBox ( xOffset+col,line*4,col*2,56, "No-one", false, tBizManagement )
				guiComboBoxAddItem(cMember, "No-one")
				guiComboBoxAddItem(cMember, "Leaders")
				guiComboBoxAddItem(cMember, "Leaders & Members")
				exports.global:guiComboBoxAdjustHeight(cMember, 3)
				guiComboBoxSetSelected ( cMember, getElementData(ped, "faction_access") )

				local bSaveNpcConfigs = guiCreateButton(0.85-0.15, 0.90 , 0.15, 0.089, "Save", true, tBizManagement)
				guiSetFont(bSaveNpcConfigs, BizNoteFont2)
				addEventHandler( "onClientGUIClick", bSaveNpcConfigs,function()
					local selectedIndex1 = guiComboBoxGetSelected ( cFaction ) or 0
					outputDebugString("selectedIndex1 = "..tostring(selectedIndex1))
					local factionBelong = comboIndex1[selectedIndex1][2] or 0
					outputDebugString("comboIndex1[selectedIndex1][2] = "..tostring(comboIndex1[selectedIndex1][2]))
					local factionAccess = guiComboBoxGetSelected ( cMember ) or 0
					triggerServerEvent("saveFactionDropNPCConfigs", localPlayer, ped, factionBelong, factionAccess)
					timer_updateConfigGUI = setTimer(function()
						updateConfigGUI()
					end, 3000, 1)
				end, false )

				local bCloseStatic2 = guiCreateButton(0.85, 0.90 , 0.15, 0.089, "Close", true, tBizManagement)
				guiSetFont(bCloseStatic2, BizNoteFont2)
				addEventHandler( "onClientGUIClick", bCloseStatic2,hideGeneralshopUI , false )
			end
			setSoundVolume(playSound(":resources/inv_open.mp3"), 0.3)
		else

			shop = g_shops[ shop_type ]

			if not shop or #shop == 0 then
				outputChatBox("This is no store. Go away.")
				hideGeneralshopUI()
				return
			end

			if shop_type == 7 then
				if not exports.global:hasItem(localPlayer, 183) then -- Viozy Membership Card
					outputChatBox("You must obtain a Viozy Membership Card to shop here!", 255, 0, 0)
					hideGeneralshopUI()
					return
				end
			end

			_G['shop_type'] = shop_type
			updateItems( shop_type, race, gender ) -- should modify /shop/ too, as shop is a reference to g_shops[type].

			--setElementData(localPlayer, "exclusiveGUI", true, false)

			local screenwidth, screenheight = guiGetScreenSize()
			local Width = 756
			local Height = 432
			local X = (screenwidth - Width)/2
			local Y = (screenheight - Height)/2

			-- adjust gui position for clothes shop
			if shop_type == 5 then
				local margin = 10
				X = screenwidth - Width - margin
				Y = screenheight - Height - margin
			end

			local isClientBizOwner, bizName, bizNote, interiorSupplies, govOwned, int_element = isBizOwner(localPlayer)

			if not bizName then
				bizName = ""
			end

			guiSetInputEnabled(true)
			showCursor(true)

			wGeneralshop = guiCreateWindow(X,Y,Width,Height,bizName.." - "..shop.name,false)
			guiWindowSetSizable(wGeneralshop,false)

			tabpanel = guiCreateTabPanel(9,26,738,396,false,wGeneralshop)
			-- create the tab panel with all shoppy items
			local counter = 1
			local bCloseStatic = {}
			local supplies = fromJSON(interiorSupplies)
			grids = {}

			for _, category in ipairs( shop ) do
				local tab = guiCreateTab( category.name, tabpanel )
				local grid =  guiCreateGridList ( 0, 0, 1, 0.9, true, tab)
				grids[_] = grid
				guiGridListSetSortingEnabled(grid, false)

				local cName = guiGridListAddColumn(grid, "Name", 0.18)
				local cPrice = guiGridListAddColumn(grid, "Price", 0.08)
				local cDescription = guiGridListAddColumn(grid, "Description", govOwned and 0.7 or 0.6)
				local cQuantity = false
				if not govOwned then
					cQuantity = guiGridListAddColumn(grid, "Quantity", 0.1)
				end

				local hasSkins = false
				for _, item in ipairs( category ) do
					-- check if the item is actually in stock
					if checkItemSupplies(shop_type, supplies, item.itemID, item.itemValue, getMetaItemName(item)) or govOwned then
						local row = guiGridListAddRow( grid )
						guiGridListSetItemText( grid, row, cName, item.name, false, false )
						guiGridListSetItemData( grid, row, cName, tostring( counter ) )

						if item.minimum_age and getElementData(localPlayer, "age") < item.minimum_age then
							guiGridListSetItemText( grid, row, cPrice, "◊ " .. item.minimum_age .. " or older", false, false )
						else
							if shop_type == 5 and category.name ~= 'Bandanas' then
								guiGridListSetItemText( grid, row, cPrice, 'Vary', false, false )
							else
								guiGridListSetItemText( grid, row, cPrice, "$" .. tostring(exports.global:formatMoney(math.ceil(discount * item.price))), false, false )
							end
						end
						guiGridListSetItemText( grid, row, cDescription, item.description or "", false, false )

						if not govOwned then
							if bandanas[item.itemID] then
								guiGridListSetItemText(grid, row, cQuantity, supplies["122"] or "Out of stock", false, false)
							elseif item.itemID == 16 then
								guiGridListSetItemText(grid, row, cQuantity, supplies["16"] or "Out of stock", false, false)
							elseif item.itemID == 114 then
								guiGridListSetItemText(grid, row, cQuantity, supplies["114:" .. vehicle_upgrades[tonumber(item.itemValue)-999][3]] or "Out of stock", false, false)
							else
								local supply = supplies[tostring(item.itemID) .. ":" .. (item.itemValue or 1)] or supplies[tostring(item.itemID) .. ":" .. (item.itemValue or 1) .. ":" .. getMetaItemName(item)] or "Out of stock"
								guiGridListSetItemText(grid, row, cQuantity, supply, false, false)
							end
						end

						if item.itemID == 16 then
							hasSkins = true
						end

						counter = counter + 1
					end
				end

				if hasSkins and category.name ~= 'Bandanas' then -- event handler for skin preview
					addEventHandler( "onClientGUIClick", grid, function( button, state )
						if button == "left" then
							local index, item = getSelectedItem( source )

							if iClothesPreview and isElement(iClothesPreview) then
								destroyElement(iClothesPreview)
								iClothesPreview = nil
							end

							if item and item.itemID == 16 then
								iClothesPreview = guiCreateStaticImage( 620, 23, 100, 100, ":account/img/" .. ("%03d"):format( item.itemValue or 1 ) .. ".png", false, source)
							end
						end
					end, false )
				end

				addEventHandler( "onClientGUIDoubleClick", grid, function( button, state )
					if button == "left" then
						local index, item = getSelectedItem( source )
						if index then
							if shop_type == 5 and category.name ~= 'Bandanas' then -- clothes
								triggerEvent('clothes:list', ped, getItemFromIndex( shop_type, index ))
							else
								triggerServerEvent( "shop:buy", ped, index )
							end
						end
					end
				end, false )

				local lWelcomeText = guiCreateLabel(0,0.89,0.848,0.1,'"Welcome to '..bizName..'!" Double click on an item to buy it!',true,tab)
				guiLabelSetVerticalAlign(lWelcomeText,"center")
				guiLabelSetHorizontalAlign(lWelcomeText,"center",false)
				guiSetFont(lWelcomeText, BizNoteFont18)
				if isClientBizOwner then
					guiSetText(lWelcomeText,'"Welcome boss! How are you doing?"')
				end
				bCloseStatic[_] = guiCreateButton(0.85, 0.90 , 0.15, 0.089, "Close", true, tab)
				guiSetFont(bCloseStatic[_], BizNoteFont2)
				addEventHandler( "onClientGUIClick", bCloseStatic[_], hideGeneralshopUI, false )
			end

			if isClientBizOwner or exports.global:hasItem(localPlayer, 5, getElementDimension(localPlayer)) then
				----------------------START EDIT CONTACT-------------------------------------------------------
				tGoodBye = guiCreateTab ( "Edit Contact Info" , tabpanel )
				guiSetInputEnabled(true)
				showCursor(true)
				local lTitle1 = guiCreateLabel(11,19,716,56,("Edit Contact Info - "..bizName),false,tGoodBye)
					--guiLabelSetVerticalAlign(lTitle1[1],"center")
					guiLabelSetHorizontalAlign(lTitle1,"center",false)
					guiSetFont(lTitle1, BizNoteFont)
				-- Fetching info
				local sOwner = ""
				local sPhone = ""
				local sFormatedPhone = ""
				local sEmail = ""
				local sForum = ""
				local sContactInfo = getElementData(ped, "sContactInfo") or false
				if sContactInfo then
					sOwner = sContactInfo[1] or ""
					sPhone = sContactInfo[2] or ""
					sFormatedPhone = ""
					if sPhone ~= "" then
						sFormatedPhone = "(+555) "..exports.global:formatMoney(sPhone)
					end
					sEmail = sContactInfo[3] or ""
					sForum = sContactInfo[4] or ""
				end

				local lOwner = guiCreateLabel(11,75,100,20,"- Owner:",false,tGoodBye)
				local eOwner = guiCreateEdit(111,75,600,20,sOwner,false,tGoodBye)
				local lPhone = guiCreateLabel(11,95,100,20,"- Phone Number:",false,tGoodBye)
				local ePhone = guiCreateEdit(111,95,600,20,sPhone,false,tGoodBye)
				local lEmail = guiCreateLabel(11,115,100,20,"- Email Address:",false,tGoodBye)
				local eEmail = guiCreateEdit(111,115,600,20,sEmail,false,tGoodBye)
				local lForums = guiCreateLabel(11,135,100,20,"((Forums Name)):",false,tGoodBye)
				local eForums = guiCreateEdit(111,135,600,20,sForum,false,tGoodBye)

				guiEditSetMaxLength ( eOwner, 100 )
				guiEditSetMaxLength ( ePhone, 100 )
				guiEditSetMaxLength ( eEmail, 100 )
				guiEditSetMaxLength ( eForums, 100 )

				local lBizNote = guiCreateLabel(0.01,0.5,1,0.1,"- Biz Note:",true,tGoodBye)

				local eBizNote = guiCreateEdit ( 0.01, 0.58, 0.98, 0.1,bizNote, true, tGoodBye)
				guiEditSetMaxLength ( eBizNote, 100 )

				bSend = guiCreateButton(0.01, 0.88, 0.49, 0.1, "Save", true, tGoodBye)
				local contactName, contactContent = nil

				addEventHandler( "onClientGUIClick", bSend, function()
					if guiGetText(eBizNote) ~= "" then
						triggerServerEvent("businessSystem:setBizNote", localPlayer,localPlayer, "setbiznote", guiGetText(eBizNote))
					end

					if guiGetText(ePhone) ~= "" and not tonumber(guiGetText(ePhone)) then
						guiSetText(ePhone, "Invalid Number")
					else
						triggerServerEvent("shop:saveContactInfo", localPlayer, ped, {guiGetText(eOwner),guiGetText(ePhone),guiGetText(eEmail),guiGetText(eForums)})
						hideGeneralshopUI()
					end


				end, false )

				local bClose = guiCreateButton(0.5, 0.88, 0.49, 0.1, "Close", true, tGoodBye)
				addEventHandler( "onClientGUIClick", bClose, hideGeneralshopUI, false )


				----------------------START BIZ MANAGEMENT-------------------------------------------------------
				local GUIEditor_Memo = {}
				local GUIEditor_Label = {}

				tBizManagement = guiCreateTab ( "Business Management" , tabpanel )

				GUIEditor_Label[1] = guiCreateLabel(11,19,716,56,"Business Management - "..bizName or "",false,tBizManagement)
					--guiLabelSetVerticalAlign(GUIEditor_Label[1],"center")
					guiLabelSetHorizontalAlign(GUIEditor_Label[1],"center",false)
					guiSetFont(GUIEditor_Label[1], BizNoteFont)

				local sIncome = tonumber(getElementData(ped, "sIncome")) or 0
				local sPendingWage = tonumber(getElementData(ped, "sPendingWage")) or 0
				local sSales = getElementData(ped, "sSales") or ""
				local sProfit = sIncome-sPendingWage

				GUIEditor_Label[3] = guiCreateLabel(11,95,716,20,"- Income: $"..exports.global:formatMoney(sIncome),false,tBizManagement)
				GUIEditor_Label[4] = guiCreateLabel(11,115,716,20,"- Staff Payment: $"..exports.global:formatMoney(sPendingWage),false,tBizManagement)
				GUIEditor_Label[5] = guiCreateLabel(11,135,716,20,"- Profit: $"..exports.global:formatMoney(sProfit),false,tBizManagement)
				GUIEditor_Label[6] = guiCreateLabel(11,155,57,19,"- Sales: ",false,tBizManagement)
				GUIEditor_Memo[1] = guiCreateMemo(11,179,498,184,sSales,false,tBizManagement)
				guiMemoSetReadOnly(GUIEditor_Memo[1], true)

				if sProfit < 0 then
					guiLabelSetColor ( GUIEditor_Label[5], 255, 0, 0)
					if sProfit < (0 - warningDebtAmount) then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (WARNING: If you're in debt of more than $"..exports.global:formatMoney(limitDebtAmount)..", your staff will quit job)." )
						guiLabelSetColor ( GUIEditor_Label[5], 255, 0, 0)
					end
				elseif sProfit == 0 then
				else
					if sProfit < 500 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Average).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 255, 0)
					elseif sProfit >= 500 and sProfit < 1000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Good!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 245, 0)
					elseif sProfit >= 1000 and sProfit < 2000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Very Good!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 235, 0)
					elseif sProfit >= 2000 and sProfit < 4000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Excellent!!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 225, 0)
					elseif sProfit >= 4000 and sProfit < 8000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Outstanding!!!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 215, 0)
					elseif sProfit >= 8000 and sProfit < 20000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Awesome!!!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 205, 0)
					elseif sProfit >= 20000 then
						guiSetText(GUIEditor_Label[5] , "- Profit: $"..exports.global:formatMoney(sProfit).." (Mother of business!!!!).")
						guiLabelSetColor ( GUIEditor_Label[5], 0, 195, 0)
					end
				end

				---------------------

				local bOrderSupplies = guiCreateButton(0.695, 0.48, 0.3, 0.1, "Manage Stocks", true, tBizManagement)
				guiSetFont(bOrderSupplies, BizNoteFont2)
				guiSetEnabled(bOrderSupplies, true)

				addEventHandler( "onClientGUIClick", bOrderSupplies, function ()
					--triggerServerEvent("shop:shopRemoteOrderSupplies", localPlayer, getElementData(ped, "orderingSupplies"))
					--setElementData(ped, "orderingSupplies", 0, false )
					showStockGUI(ped, shop, int_element, shop_type)
					playSoundFrontEnd(17)
				end, false )

				---------------------------
				
				local bClearSaleLogs = guiCreateButton(0.695, 0.68, 0.3, 0.1, "Clear SaleLogs", true, tBizManagement)
				guiSetFont(bClearSaleLogs, BizNoteFont2)
				addEventHandler( "onClientGUIClick", bClearSaleLogs, function ()
					guiSetText(GUIEditor_Memo[1],"")
					setElementData(ped, "sSales", "", true)
					triggerServerEvent("shop:updateSaleLogs", localPlayer, localPlayer, getElementData(ped, "dbid") , "")
				end, false )

				--------------------------------
				--[[
				local bPayWage = guiCreateButton(0.695, 0.68, 0.3, 0.1, "Pay Staff", true, tBizManagement)
				guiSetFont(bPayWage, BizNoteFont2)
				if sPendingWage > 0 then
					addEventHandler( "onClientGUIClick", bPayWage, function ()
						guiSetVisible(wCustomShop, false)
						triggerServerEvent("shop:solvePendingWage", localPlayer, localPlayer, ped)
						hideGeneralshopUI()
					end, false )
				else
					guiSetEnabled(bPayWage, false)
				end
				]]
				--------------------------------

				local bCollectProfit = guiCreateButton(0.695, 0.78, 0.3, 0.1, sIncome > sPendingWage and "Collect Profit" or "Solve Wage", true, tBizManagement)
				guiSetFont(bCollectProfit, BizNoteFont2)
				if govOwned then
					guiSetEnabled(bCollectProfit, false)
				else
					if (sPendingWage > 0) or (sIncome > 0) then
						addEventHandler( "onClientGUIClick", bCollectProfit, function ()
							triggerServerEvent("shop:collectMoney", ped, int_element)
							hideGeneralshopUI()
						end, false )
					else
						guiSetEnabled(bCollectProfit, false)
					end
				end
				local bClose = guiCreateButton(0.695, 0.88, 0.3, 0.1, "Close", true, tBizManagement)
				guiSetFont(bClose, BizNoteFont2)
				addEventHandler( "onClientGUIClick", bClose, hideGeneralshopUI, false )

			else
				-----------------------------------------CUSTOMER PANEL-----------------------------------------------------------------

				tGoodBye = guiCreateTab ( "Contact Info" , tabpanel )

				local lTitle1 = guiCreateLabel(11,19,716,56,(bizName.." - See you again!"),false,tGoodBye)
					--guiLabelSetVerticalAlign(lTitle1[1],"center")
					guiLabelSetHorizontalAlign(lTitle1,"center",false)
					guiSetFont(lTitle1, BizNoteFont)
				-- Fetching info
				local sOwner = ""
				local sPhone = ""
				local sFormatedPhone = ""
				local sEmail = ""
				local sForum = ""
				local sContactInfo = getElementData(ped, "sContactInfo") or false
				if sContactInfo then
					sOwner = sContactInfo[1] or ""
					sPhone = sContactInfo[2] or ""
					sFormatedPhone = ""
					if sPhone ~= "" then
						sFormatedPhone = "(+555) "..exports.global:formatMoney(sPhone)
					end
					sEmail = sContactInfo[3] or ""
					sForum = sContactInfo[4] or ""
				end

				local lOwner = guiCreateLabel(11,75,716,20,"- Owner: "..sOwner.."",false,tGoodBye)
				local lPhone = guiCreateLabel(11,95,716,20,"- Phone Number: "..sFormatedPhone.."",false,tGoodBye)
				local lEmail = guiCreateLabel(11,115,716,20,"- Email Address: "..sEmail.."",false,tGoodBye)
				local lForums = guiCreateLabel(11,135,716,20,"- ((Forums Name: "..sForum.."))",false,tGoodBye)
				local lGuide = guiCreateLabel(0.01,0.5,1,0.1,"        'Hey, I can pass your message to my bosses if you want': ",true,tGoodBye)

				local eBargainName = guiCreateEdit ( 0.01, 0.58, 0.19, 0.1,"your identity", true, tGoodBye)
				addEventHandler( "onClientGUIClick", eBargainName, function()
					guiSetText(eBargainName, "")
				end, false )

				local eContent = guiCreateEdit ( 0.2, 0.58, 0.79, 0.1,"content", true, tGoodBye)
				guiEditSetMaxLength ( eContent, 95 )
				addEventHandler( "onClientGUIClick", eContent, function()
					guiSetText(eContent, "")
				end, false )

				bSend = guiCreateButton(0.01, 0.88, 0.49, 0.1, "Send", true, tGoodBye)
				local contactName, contactContent = nil
				local cooldown = getElementData(localPlayer, "shop:coolDown:contact")
				if not cooldown or getTickCount() - cooldown > 60000*coolDownSend then
					guiSetText(bSend, "Send")
					guiSetEnabled(bSend, true)
				else
					guiSetText(bSend, "(You can send another message in "..coolDownSend.." minute(s).)")
					guiSetEnabled(bSend, false)
				end

				addEventHandler( "onClientGUIClick", bSend, function()
					contactContent = guiGetText(eContent)
					if contactContent and contactContent ~= "" and contactContent ~= "content" then
						contactName = guiGetText(eBargainName):gsub("_"," ")
						if contactName == "" or contactName == "your identity" then
							contactName = "A Customer"
						else
							if getElementData(localPlayer, "gender") == 0 then
								contactName = "Mr. "..contactName
							else
								contactName = "Mrs. "..contactName
							end
						end
						triggerServerEvent("shop:notifyAllShopOwners", localPlayer , ped, "Hey boss! Read this '"..contactContent.."', said "..contactName..".")
						setElementData(localPlayer, "shop:coolDown:contact", getTickCount(), false)
						guiSetText(bSend, "(You can send another message in "..coolDownSend.." minute(s).)")
						guiSetEnabled(bSend, false)
						guiSetText(eContent, "")
					end
				end, false )

				addEventHandler( "onClientGUIAccepted", eContent,function()
					contactContent = guiGetText(eContent):gsub("_"," ")
					if contactContent and contactContent ~= "" and contactContent ~= "content" then
						contactName = guiGetText(eBargainName)
						if contactName == "" or contactName == "your identity" then
							contactName = "A Customer"
						else
							if getElementData(localPlayer, "gender") == 0 then
								contactName = "Mr. "..contactName
							else
								contactName = "Mrs. "..contactName
							end
						end
						triggerServerEvent("shop:notifyAllShopOwners", localPlayer , ped, "Hey boss! Read this '"..contactContent.."', said "..contactName..".")
						setElementData(localPlayer, "shop:coolDown:contact", getTickCount(), false)
						guiSetText(bSend, "(You can send another message in "..coolDownSend.." minute(s).)")
						guiSetEnabled(bSend, false)
						guiSetText(eContent, "")
					end

				end, false )

				local bClose = guiCreateButton(0.5, 0.88, 0.49, 0.1, "Close", true, tGoodBye)
				addEventHandler( "onClientGUIClick", bClose, hideGeneralshopUI, false )
			end
			setSoundVolume(playSound(":resources/inv_open.mp3"), 0.3)
		end
	end
end
addEvent("showGeneralshopUI", true )
addEventHandler("showGeneralshopUI", getResourceRootElement(), showGeneralshopUI)

function showStockGUI(ped, shop, intelement, shop_type)
	if stockWindow and isElement(stockWindow) then
		return false
	end
	stockWindow = guiCreateWindow(511, 293, 485, 333, "Manage Stocks", false)
    guiWindowSetSizable(stockWindow, false)

    local stockGrid = guiCreateGridList(10, 27, 439, 260, false, stockWindow)
    guiGridListAddColumn(stockGrid, "Product", 0.5)
	guiGridListAddColumn(stockGrid, "$ Cost Per Unit", 0.2)
    guiGridListAddColumn(stockGrid, "Quantity", 0.2)

	local status = getElementData(intelement, "status") 
	local supplies = fromJSON(status.supplies)

	guiGridListSetSortingEnabled(stockGrid, false)

	local shopSupplies = {}
	local row = 0
	local handledClothes = false
	if shop_type ~= 14 then
		for _, category in ipairs(shop) do
			for _, item in ipairs(category) do
				if not bandanas[item.itemID] and item.itemID ~= 114 then
					if item.itemID == 16 then
						if not handledClothes then
							row = row + 1
							local clothes_quantity = 0
							if supplies and supplies["16"] then
								clothes_quantity = supplies["16"]
							end
							shopSupplies[row] = { 16, 1, clothes_quantity }
							guiGridListAddRow(stockGrid, "All Clothes", 40, tostring(clothes_quantity))
							handledClothes = true
						end
					else
						row = row + 1
						local quantity = 0
						if supplies and supplies[tostring(item.itemID) .. ":" .. (item.itemValue or 1)] then
							quantity = supplies[tostring(item.itemID) .. ":" .. (item.itemValue or 1)]
						end

						if supplies and supplies[tostring(item.itemID) .. ":" .. (item.itemValue or 1) .. ":" .. getMetaItemName(item)] then
							quantity = supplies[tostring(item.itemID) .. ":" .. (item.itemValue or 1) .. ":" .. getMetaItemName(item)]
						end

						local metaValue = getMetaItemName(item)
						shopSupplies[row] = { item.itemID, item.itemValue or 1, quantity, metaValue }
						local stockPrice = math.ceil((item.price/5)*4)
						if stockPrice >= item.price then
							stockPrice = math.ceil((item.price / 2))
						end
						if shop_type == 7 then
							stockPrice = math.ceil(stockPrice * 0.5)
						end
						guiGridListAddRow(stockGrid, item.name, tostring(stockPrice), tostring(quantity))
					end
				end
			end
		end
	end
	if shop_type == 5 then -- bandanas
		row = row + 1
		local bandana_quantity = 0
		if supplies and supplies["122"] then
			bandana_quantity = supplies["122"]
		end
		shopSupplies[row] = { 122, 1, bandana_quantity }
		guiGridListAddRow(stockGrid, "All Bandanas", 4, tostring(bandana_quantity))
	elseif shop_type == 14 or shop_type == 7 then
		local upgrade_rows = {
			{ "Spoilers", spoilerPrice/2 }, { "Hood Modifications", hoodPrice/2 }, { "Sideskirts", sideskirtPrice/2 }, { "Roof Modifications", roofPrice/2 },
			{ "Lights", lightPrice/2 }, { "Wheels", wheelPrice/2 }, { "Exhausts", exhaustPrice/2 }, { "Bullbars", bullbarPrice/2 }, { "Bumpers", bumperPrice/2,	},
			{ "Hydraulics", hydraulicPrice/2 }
		}	
		for i, v in ipairs(upgrade_rows) do
			if shop_type == 14 or v[1] == "Wheels" then
				row = row + 1
				local quantity = 0
				if supplies and supplies["114:" .. i] then
					quantity = supplies["114:" .. i]
				end
				local stockPrice = v[2]/5*4
				if shop_type == 7 then
					stockPrice = math.ceil(stockPrice * 0.5)
				end
				guiGridListAddRow(stockGrid, v[1], stockPrice, quantity)
				shopSupplies[row] = { 114, i, quantity }
			end
		end
	end

	local plus5 = guiCreateButton(451, 27, 25, 22, "+5", false, stockWindow)
    local plus1 = guiCreateButton(451, 53, 25, 22, "+1", false, stockWindow)
    local minus5 = guiCreateButton(451, 265, 25, 22, "-5", false, stockWindow)
    local minus1 = guiCreateButton(451, 239, 25, 22, "-1", false, stockWindow)

	local cost = 0
    local stockCost = guiCreateLabel(25, 302, 157, 15, "Total Cost: $0", false, stockWindow)
	guiSetFont(stockCost, "default-bold-small")
    local stockSave = guiCreateButton(336, 292, 114, 32, "Order", false, stockWindow)
    local stockCancel = guiCreateButton(212, 292, 114, 32, "Cancel", false, stockWindow)

	addEventHandler("onClientGUIClick", stockWindow, function()
		if source == stockCancel then
			destroyElement(stockWindow)
		elseif source == plus5 or source == plus1 then
			local row, column = guiGridListGetSelectedItem(stockGrid)
			if row == -1 then return end
			local currentQuantity = guiGridListGetItemText(stockGrid, row, 3)
			if tonumber(currentQuantity) then -- unchanged
				guiGridListSetItemText(stockGrid, row, 3, currentQuantity .. " + " .. (source == plus5 and 5 or source == plus1 and 1), false, false)
			else
				local q, a = gettok(currentQuantity, 1, " + "), gettok(currentQuantity, 2, " + ")
				guiGridListSetItemText(stockGrid, row, 3, q .. " + " .. (tonumber(a) + (source == plus5 and 5 or source == plus1 and 1)), false, false)
			end
			cost = cost + (tonumber(guiGridListGetItemText(stockGrid, row, 2)) * (source == plus5 and 5 or source == plus1 and 1))
			guiSetText(stockCost, "Total Cost: $" .. exports.global:formatMoney(cost))
			if cost > getElementData(getLocalPlayer(), "bankmoney") then
				guiLabelSetColor(stockCost, 255, 0, 0)
				guiSetProperty(stockSave, "Disabled", "True")
			else
				guiLabelSetColor(stockCost, 0, 255, 0)
				guiSetProperty(stockSave, "Disabled", "False")
			end
		elseif source == minus5 or source == minus1 then
			local row, column = guiGridListGetSelectedItem(stockGrid)
			local currentQuantity = guiGridListGetItemText(stockGrid, row, 3)
			if not tonumber(currentQuantity) then
				local q, a = gettok(currentQuantity, 1, " + "), gettok(currentQuantity, 2, " + ")
				if tonumber((tonumber(a) - (source == minus5 and 5 or source == minus1 and 1))) >= 0 then
					guiGridListSetItemText(stockGrid, row, 3, q .. " + " .. (tonumber(a) - (source == minus5 and 5 or source == minus1 and 1)), false, false)
					cost = cost - (tonumber(guiGridListGetItemText(stockGrid, row, 2)) * (source == minus5 and 5 or source == minus1 and 1))
					guiSetText(stockCost, "Total Cost: $" .. exports.global:formatMoney(cost))
					if cost > getElementData(getLocalPlayer(), "bankmoney") then
						guiLabelSetColor(stockCost, 255, 0, 0)
						guiSetProperty(stockSave, "Disabled", "True")
					elseif cost == 0 then
						guiLabelSetColor(stockCost, 255, 255, 255)
						guiSetProperty(stockSave, "Disabled", "True")
						guiGridListSetItemText(stockGrid, row, 3, q, false, false)
					else
						guiLabelSetColor(stockCost, 0, 255, 0)
						guiSetProperty(stockSave, "Disabled", "False")
					end
				end
			end
		elseif source == stockSave then
			guiSetProperty(stockSave, "Disabled", "True")
			supplies = fromJSON(status.supplies)
			addSupplies = {}
			for i=1, #shopSupplies do
				local quantityStr = guiGridListGetItemText(stockGrid, i-1, 3)
				if not tonumber(quantityStr) then
					local add = tonumber(gettok(quantityStr, 2, " + "))
					if shopSupplies[i][1] == 16 or shopSupplies[i][1] == 122 then
						addSupplies[tostring(shopSupplies[i][1])] = add
					elseif shopSupplies[i][4] then
						addSupplies[tostring(shopSupplies[i][1]) .. ":" .. shopSupplies[i][2] .. ":" .. shopSupplies[i][4]] = add
					else
						addSupplies[tostring(shopSupplies[i][1]) .. ":" .. shopSupplies[i][2]] = add
					end
				end
			end
			triggerServerEvent("updateShopSupplies", intelement, getElementDimension(getLocalPlayer()), addSupplies, getLocalPlayer(), cost, getElementData(ped, "name"))
			destroyElement(stockWindow)
		end
	end)
end

addEvent("updateShopGUI", true)
addEventHandler("updateShopGUI", getRootElement(),
function(int, shop_type, index)
	if grids then
		local counter = 1
		local found = false
		local status = getElementData(int, "status")
		local supplies = fromJSON(status.supplies)
		for _, category in ipairs(g_shops[shop_type]) do
			local rowID = 0
			for i, item in ipairs(category) do
				if shop_type == 5 then
					if bandanas[item.itemID] and supplies["122"] and supplies["122"] > 0 then
						if counter == index then
							if supplies["122"] > 1 then
								for p=1, 11 do
									guiGridListSetItemText(grids[_], p-1, 4, supplies["122"]-1, false, false)
								end
							else
								guiGridListClear(grids[_])
							end
						end
						counter = counter + 1
					elseif item.itemID == 16 and supplies["16"] and supplies["16"] > 0 then
						-- if clothes in stock, bump up the counter for each
						counter = counter + 1
					end
				elseif item.itemID == 16 and supplies["16"] and supplies["16"] > 0 then
					if counter == index then
						for p, pitem in ipairs(category) do
							guiGridListSetItemText(grids[_], p-1, 4, supplies["16"]-1, false, false)
						end
					end
					counter = counter + 1
				elseif (item.itemID == 114 and vehicle_upgrades[tonumber(item.itemValue)-999] and vehicle_upgrades[tonumber(item.itemValue)-999][3] and supplies["114:" .. vehicle_upgrades[tonumber(item.itemValue)-999][3]] and supplies["114:" .. vehicle_upgrades[tonumber(item.itemValue)-999][3]] > 0) then
					if counter == index then
						local modcounter = 1
						for p, pitem in ipairs(category) do
							if checkItemSupplies(shop_type, supplies, pitem.itemID, pitem.itemValue, getMetaItemName(pitem)) then
								if found then
									guiGridListSetItemData(grids[_], modcounter-1, 1, tostring(modcounter))
								end
								if pitem.itemID == 114 and vehicle_upgrades[tonumber(pitem.itemValue)-999][3] == vehicle_upgrades[tonumber(item.itemValue)-999][3] then
									if supplies["114:" .. vehicle_upgrades[tonumber(item.itemValue)-999][3]] > 1 then
										guiGridListSetItemText(grids[_], modcounter-1, 4, supplies["114:" .. vehicle_upgrades[tonumber(item.itemValue)-999][3]]-1, false, false)
									else
										guiGridListRemoveRow(grids[_], modcounter-1)
										modcounter = modcounter - 1
										if not found then
											found = true
										end
									end
								end
								modcounter = modcounter + 1
							end
						end
					end
					counter = counter + 1
				elseif supplies[item.itemID .. ":" .. (item.itemValue or "1")] and supplies[item.itemID .. ":" .. (item.itemValue or "1")] > 0 then
					if supplies[item.itemID .. ":" .. (item.itemValue or "1")] > 1 then
						if found then
							guiGridListSetItemData(grids[_], rowID-1, 1, tostring(counter-1))
						end
						if counter == index and grids[_] and isElement(grids[_]) then
							guiGridListSetItemText(grids[_], rowID, 4, supplies[item.itemID .. ":" .. (item.itemValue or "1")]-1, false, false)
							return
						end
					else
						if counter == index and isElement(grids[_]) then
							guiGridListRemoveRow(grids[_], rowID)
							found = true
						end
					end
					counter = counter + 1
					rowID = rowID + 1
				elseif supplies[item.itemID .. ":" .. (item.itemValue or "1") .. ":" .. getMetaItemName(item)] and supplies[item.itemID .. ":" .. (item.itemValue or "1")  .. ":" .. getMetaItemName(item)] > 0 then
					if supplies[item.itemID .. ":" .. (item.itemValue or "1") .. ":" .. getMetaItemName(item)] > 1 then
						if found then
							guiGridListSetItemData(grids[_], rowID-1, 1, tostring(counter-1))
						end
						if counter == index and grids[_] and isElement(grids[_]) then
							guiGridListSetItemText(grids[_], rowID, 4, supplies[item.itemID .. ":" .. (item.itemValue or "1") .. ":" .. getMetaItemName(item)]-1, false, false)
							return
						end
					else
						if counter == index and isElement(grids[_]) then
							guiGridListRemoveRow(grids[_], rowID)
							found = true
						end
					end
					counter = counter + 1
					rowID = rowID + 1
				end
			end
		end
	end
end)

function togShopWindow(state)
	if wCustomShop and isElement(wCustomShop) then
		guiSetEnabled(wCustomShop, state)
	end
	if wGeneralshop and isElement(wGeneralshop) then
		guiSetEnabled(wGeneralshop, state)
	end
end
addEvent("npc:togShopWindow", true )
addEventHandler("npc:togShopWindow", root, togShopWindow)

function hideGeneralshopUI()
	if timer_updateConfigGUI and isTimer(timer_updateConfigGUI) then
		killTimer(timer_updateConfigGUI)
	end
	triggerServerEvent("shop:removeMeFromCurrentShopUser", localPlayer, localPlayer)
	--outputDebugString("Triggered")
	setElementData(localPlayer, "exclusiveGUI", false, false)
	setTimer(function ()
		setElementData(localPlayer, "shop:NoAccess", false, true )
	end, 50, 1)
	guiSetInputEnabled(false)
	showCursor(false)
	if wGeneralshop then
		destroyElement(wGeneralshop)
		wGeneralshop = nil
		setSoundVolume(playSound(":resources/inv_close.mp3"), 0.3)
	end
	if wCustomShop then
		destroyElement(wCustomShop)
		wCustomShop = nil
		setSoundVolume(playSound(":resources/inv_close.mp3"), 0.3)
	end
	closeOwnerProductView()
	closeAddingItemWindow()
	closeCustomShopBuy()
end
addEvent("hideGeneralshopUI", true )
addEventHandler("hideGeneralshopUI", getRootElement(), hideGeneralshopUI)

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
	if wGeneralshop ~= nil then
		hideGeneralshopUI()
	end
	setElementData(localPlayer, "shop:NoAccess", false, true)
	setElementData(localPlayer, "shop:coolDown:contact", nil, false)
end)

function sendRefusingLocalChat(theShop)
	local says = {
		"Go away!",
		"Get lost!",
		"Who are you?",
		"Go home!",
		"Do I know you, bro?",
	}
	local ran = math.random(1, #says)
	local say = says[ran]
	local pedName = getElementData(theShop, "name")
	triggerServerEvent("shop:storeKeeperSay", localPlayer, localPlayer, say, pedName)
end


function factionDropUpdateWeaponList(newItems)
	products = newItems
	if fdgw.gProducts and isElement(fdgw.gProducts) then
		guiGridListClear(fdgw.gProducts)
		for _, record in ipairs(products) do
			local row = guiGridListAddRow(fdgw.gProducts)
			local itemName = exports["item-system"]:getItemName( tonumber(record["pItemID"]), tostring(record["pItemValue"]) )
			local itemValue = ""
			if not exports["item-system"]:getItemHideItemValue(tonumber(record["pItemID"])) then
				itemValue = exports["item-system"]:getItemValue( tonumber(record["pItemID"]), tostring(record["pItemValue"]) )
			end
			local description = exports["item-system"]:getItemDescription( tonumber(record["pItemID"]), itemValue )
			local itemPrice = "$"..exports.global:formatMoney(math.floor(tonumber(record["pPrice"] or 0)))
			guiGridListSetItemText(fdgw.gProducts, row, fdgw.colName, itemName or "Unknown", false, false)
			guiGridListSetItemText(fdgw.gProducts, row, fdgw.colPrice, itemPrice, false, true)
			guiGridListSetItemText(fdgw.gProducts, row, fdgw.colDesc, description, false, false)
			guiGridListSetItemText(fdgw.gProducts, row, fdgw.colQuantity, exports.global:formatMoney(record["pQuantity"]), false, false)
			guiGridListSetItemText(fdgw.gProducts, row, fdgw.colProductID, record["pID"], false, true)
			local pRestockInFinal = "Never"
			local pRestockInterval = tonumber(record["pRestockInterval"]) or 0
			local pRestockIn = record["pRestockIn"]
			if pRestockIn and tonumber(pRestockIn) and pRestockInterval > 0 then
				pRestockIn = tonumber(pRestockIn)
				if pRestockIn == 0 then
					pRestockInFinal = "Today"
				elseif pRestockIn == 1 then
					pRestockInFinal = "Tomorrow"
				elseif pRestockIn == 2 then
					pRestockInFinal = "The day after tomorrow"
				elseif pRestockIn > 2 then
					pRestockInFinal = pRestockIn.." days"
				end
			end
			outputDebugString(pRestockIn)
			guiGridListSetItemText(fdgw.gProducts, row, fdgw.colRestock,  pRestockInFinal, false, true)
		end
	end
end
addEvent("shop:factionDropUpdateWeaponList", true)
addEventHandler( "shop:factionDropUpdateWeaponList", root, factionDropUpdateWeaponList)

function togMainShop(state)
	if wCustomShop and isElement(wCustomShop) then
		guiSetEnabled(wCustomShop, state)
	end
end
