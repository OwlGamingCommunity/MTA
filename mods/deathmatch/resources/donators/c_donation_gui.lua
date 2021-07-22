--MAXIME
local wDonation,lSpendText,lActive,lAvailable, bClose,f7state, bRedeem, GUIEditor_TabPanel = nil
local lItems = {}
local bItems = { }
local screenWidth, screenHeight = guiGetScreenSize()
local obtained = {}
local available = {}
local credits = 0
local tab = {}
local grid = {}
local col = {}
local GUIEditor_Window = {}
local gui = {}
local ranking = {}
local history = {}
local purchased = {}
--local rankThisMonth = {}
local globalPurchaseHistory = {}

function openDonationGUI(obtained1, available1, credits1, history1, purchased1, globalPurchaseHistory1)
	showCursor(true)
	guiSetInputEnabled(true)
	obtained = obtained1
	available = available1
	credits = tonumber(credits1)
	--ranking = ranking1
	history = history1
	purchased = purchased1
	--rankThisMonth = rankThisMonth1
	globalPurchaseHistory = globalPurchaseHistory1
	if wDonation and isElement(wDonation) then
		--
	else
		triggerEvent( 'hud:blur', resourceRoot, 6, false, 0.5, nil )
		local w, h = 800,474
		local x, y = (screenWidth-w)/2, (screenHeight-h)/2
		wDonation = guiCreateWindow(x,y,w,h,"Premium Features",false)
		guiWindowSetSizable(wDonation, false)

		GUIEditor_TabPanel = guiCreateTabPanel(0.0122,0.0401,0.9757,0.87,true,wDonation)
		tab.availableItems = guiCreateTab("Available items",GUIEditor_TabPanel)
		tab.activatedPerks = guiCreateTab("Activated perks",GUIEditor_TabPanel)
		tab.purchased = guiCreateTab("Purchase history",GUIEditor_TabPanel)
		tab.history = guiCreateTab("My donations",GUIEditor_TabPanel)
		--tab.rankThisMonth = guiCreateTab("Donors of month",GUIEditor_TabPanel)
		--tab.rank = guiCreateTab("Donors of all times",GUIEditor_TabPanel)

		if exports.integration:isPlayerLeadAdmin(localPlayer) then
			tab.recent = guiCreateTab("Global purchases",GUIEditor_TabPanel)
		end

		grid.availableItems = guiCreateGridList(0,0,1,1,true,tab.availableItems)
		guiGridListSetSortingEnabled ( grid.availableItems, false )
		col.name = guiGridListAddColumn(grid.availableItems,"Perk Name",0.78)
		col.duration = guiGridListAddColumn(grid.availableItems,"Duration",0.1)
		col.price = guiGridListAddColumn(grid.availableItems,"Cost",0.07)
		--col.id = guiGridListAddColumn(grid.availableItems,"ID",0)

		grid.activatedPerks = guiCreateGridList(0,0,1,1,true,tab.activatedPerks)
		guiGridListSetSortingEnabled ( grid.activatedPerks, false )
		col.a_name = guiGridListAddColumn(grid.activatedPerks,"Perk Name",0.7)
		col.a_expire = guiGridListAddColumn(grid.activatedPerks,"Expire Date",0.2)
		--col.a_id = guiGridListAddColumn(grid.activatedPerks,"ID",0.1)

		grid.purchased = guiCreateGridList(0,0,1,1,true,tab.purchased)
		col.b_name = guiGridListAddColumn(grid.purchased,"Perk Name",0.6)
		col.b_GC = guiGridListAddColumn(grid.purchased,"Cost",0.1)
		col.b_purchaseDate = guiGridListAddColumn(grid.purchased,"Purchase Date",0.2)
		--[[
		grid.rankThisMonth = guiCreateGridList(0,0,1,1,true,tab.rankThisMonth)
		col.r_rank_month = guiGridListAddColumn(grid.rankThisMonth,"Rank",0.1)
		col.r_donor_month = guiGridListAddColumn(grid.rankThisMonth,"Donor",0.4)
		col.r_total_month = guiGridListAddColumn(grid.rankThisMonth,"Donated in total",0.4)

		grid.rank = guiCreateGridList(0,0,1,1,true,tab.rank)
		col.r_rank = guiGridListAddColumn(grid.rank,"Rank",0.1)
		col.r_donor = guiGridListAddColumn(grid.rank,"Donor",0.4)
		col.r_total = guiGridListAddColumn(grid.rank,"Donated in total",0.4)
		]]
		grid.history = guiCreateGridList(0,0,1,1,true,tab.history)
		--col.h_id = guiGridListAddColumn(grid.history,"ID",0.05)
		col.h_txn_id = guiGridListAddColumn(grid.history,"Transaction ID",0.2)
		col.h_email = guiGridListAddColumn(grid.history,"Details",0.45)
		col.h_amount = guiGridListAddColumn(grid.history,"Amount",0.1)
		col.h_date = guiGridListAddColumn(grid.history,"Date",0.2)

		if exports.integration:isPlayerLeadAdmin(localPlayer) then
			grid.recent = guiCreateGridList(0,0,1,1,true,tab.recent)
			col.r_account = guiGridListAddColumn(grid.recent,"Account",0.2)
			col.r_details = guiGridListAddColumn(grid.recent,"Details",0.4)
			col.r_amount = guiGridListAddColumn(grid.recent,"Amount",0.1)
			col.r_date = guiGridListAddColumn(grid.recent,"Date",0.2)
		end

		gui.donate = guiCreateButton(0.0135,0.9135,0.48715,0.0675,"Get GCs!",true,wDonation)
		--guiCreateStaticImage(663, 25, 13, 13, "gamecoin.png", false, wDonation)
		guiSetFont(gui.donate, "default-bold-small")

		addEventHandler("onClientGUIClick", gui.donate, function()
			if source == gui.donate then
				showInfoPanel(1)
			end
		end)

		bClose = guiCreateButton(0.0135+0.48715,0.9135,0.48715,0.0675,"Close",true,wDonation)
		guiSetFont(bClose, "default-bold-small")
		addEventHandler("onClientGUIClick", bClose, function()
			if source == bClose then
				closeDonationGUI()
			end
		end)
		lSpendText = guiCreateLabel(0.82, 0.05, 0.3, 0.05, "GameCoins:     "..exports.global:formatMoney(credits), true, wDonation)
		guiCreateStaticImage(725, 25, 13, 13, "gamecoin.png", false, wDonation)
		guiSetFont(lSpendText, "default-bold-small")
	end
	updateAvailablePerks()
	updateObtainedPerks()
	updatePurchaseHistory()
	--updateRanking()
	--updateRankingMonth()
	updateMyHistory()
	updateRecents()
	guiSetText(lSpendText ,"GameCoins:     "..exports.global:formatMoney(credits))
end
addEvent("donation-system:GUI:open", true)
addEventHandler("donation-system:GUI:open", getRootElement(), openDonationGUI)

function updateAvailablePerks()
	guiGridListClear(grid.availableItems)
	local purchasable = 0
	local gcTransferFee = false
	for perkID, perkArr in ipairs(available) do
		if (perkArr[1] ~= nil) and (perkArr[2] ~= 0) then
			local row = guiGridListAddRow(grid.availableItems)

			guiGridListSetItemText(grid.availableItems, row, col.name, perkArr[1], false, false)

			guiGridListSetItemText(grid.availableItems, row, col.duration, ( perkArr[3] > 1 and (perkArr[3] .." days") or "Permanent") , false, false)

			if perkArr[4] == 13 then--GCs Transfer
				guiGridListSetItemText(grid.availableItems, row, col.price, "Fee "..perkArr[2].."%", false, false)
				gcTransferFee = tonumber(perkArr[2]) or 0
			elseif perkArr[4] == 14 then--max ints
				local nextIntCap = tonumber( getElementData(localPlayer, "maxinteriors") )+1
				if credits >= perkArr[2]*(nextIntCap-10)*2 then
					guiGridListSetItemText(grid.availableItems, row, col.price, perkArr[2]*(nextIntCap-10)*2 .." GC" , false, false)
				else
					guiGridListSetItemText(grid.availableItems, row, col.price, perkArr[2]*(nextIntCap-10)*2 .." GC (not enough)", false, false)
				end
			elseif perkArr[4] == 15 then--max veh
				local currentMaxVehicles = tonumber( getElementData(localPlayer, "maxvehicles") )+1
				if credits >= perkArr[2]*(currentMaxVehicles-5)*2 then
					guiGridListSetItemText(grid.availableItems, row, col.price, perkArr[2]*(currentMaxVehicles-5)*2 .." GC" , false, false)
				else
					guiGridListSetItemText(grid.availableItems, row, col.price, perkArr[2]*(currentMaxVehicles-5)*2 .." GC (not enough)", false, false)
				end
			else
				if credits >= perkArr[2] then
					guiGridListSetItemText(grid.availableItems, row, col.price, perkArr[2] .." GC" , false, false)
				else
					guiGridListSetItemText(grid.availableItems, row, col.price, perkArr[2] .." GC (not enough)", false, false)
				end
			end
			--guiGridListSetItemText(grid.availableItems, row, col.id, perkArr[4] , false, true)
			guiGridListSetItemData ( grid.availableItems , row, 1, perkArr[4] )
		end
	end

	addEventHandler( "onClientGUIDoubleClick", grid.availableItems,
		function( button )
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid.availableItems)
				if row ~= -1 and col ~= -1 then
					local cName = guiGridListGetItemText( grid.availableItems , row, 1 )
					local cDur = guiGridListGetItemText( grid.availableItems , row, 2 )
					local cCost = string.match(guiGridListGetItemText( grid.availableItems , row, 3 ),"%d+")
					local cID = guiGridListGetItemData( grid.availableItems , row, 1 )
					cID = tonumber(cID)
					if cID == 13 and gcTransferFee then
						showGcTransfer(cID, gcTransferFee)
					elseif tonumber(cID) == 18 or tonumber(cID) == 19 then
						showPhonePicker(cID)
					elseif cID == 20 or cID == 21 or cID == 22 or cID == 23 or cID == 28 or cID == 33 or cID == 35 or cID == 36 or cID == 37 or cID == 38 then
						showInfoPanel(cID, cCost)
					elseif cID == 16 then
						showUsernameChange(cID)
					elseif cID == 17 then
						showKeypadDoorLock(cID)
					elseif cID == 29 then
						showCustomChatIconMenu(cID, cCost)
					elseif cID == 30 or cID == 31 then
						triggerServerEvent("bank:applyForNewATMCard", localPlayer)
					elseif cID == 34 then
						showLearnLanguageMenu(cID, cCost)
					else
						showConfirmSpend(cName, cDur, cCost, cID)
					end
					playSuccess()
				end
			end
		end,
	false)
end

function updateObtainedPerks()
	guiGridListClear(grid.activatedPerks)
	for perkID, perkTable in ipairs(obtained) do
		local perkArr = perkTable[1]
		local expirationDate = perkTable[2] or "Never"
		if (perkArr[1] ~= nil) then
			local row = guiGridListAddRow(grid.activatedPerks)
			guiGridListSetItemText(grid.activatedPerks, row, col.a_name, perkArr[1] , false, false)
			guiGridListSetItemText(grid.activatedPerks, row, col.a_expire, expirationDate , false, false)
			guiGridListSetItemData(grid.activatedPerks, row, 1, perkArr[4] )
		end
	end

	addEventHandler( "onClientGUIDoubleClick", grid.activatedPerks,
		function( button )
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid.activatedPerks)
				if row ~= -1 and col ~= -1 then
					local aName = guiGridListGetItemText( grid.activatedPerks , row, 1 )
					local aExpireDate = guiGridListGetItemText( grid.activatedPerks , row, 2 )
					local aID = guiGridListGetItemData( grid.activatedPerks , row, 1 )
					if aID == "29" then
						showCustomChatIconMenu(aID, "0 GC", true)
					else
						showConfirmRemovePerk(aName, aExpireDate, aID)
					end
					playSuccess()
				end
			end
		end,
	false)
end

function updateRanking()
	--ranking = sortTable(ranking)
	guiGridListClear(grid.rank)
	local maxRow = #ranking
	for i = 1, maxRow do
		local row = guiGridListAddRow(grid.rank)
		guiGridListSetItemText(grid.rank, row, col.r_rank, i , false, true)
		guiGridListSetItemText(grid.rank, row, col.r_donor, ranking[i][1] , false, false)
		guiGridListSetItemText(grid.rank, row, col.r_total, "$"..ranking[i][2] , false, true)
	end
end

function updateRankingMonth()
	guiGridListClear(grid.rankThisMonth)
	local maxRow = #rankThisMonth
	for i = 1, maxRow do
		local row = guiGridListAddRow(grid.rankThisMonth)
		guiGridListSetItemText(grid.rankThisMonth, row, col.r_rank_month, i , false, true)
		guiGridListSetItemText(grid.rankThisMonth, row, col.r_donor_month, rankThisMonth[i][1] , false, false)
		guiGridListSetItemText(grid.rankThisMonth, row, col.r_total_month, "$"..rankThisMonth[i][2] , false, true)
	end
end

function updateMyHistory()
	guiGridListClear(grid.history)
	for i = 1, #history do
		local row = guiGridListAddRow(grid.history)
		--guiGridListSetItemText(grid.history, row, col.h_id, history[i]["order_id"] , false, true)
		guiGridListSetItemText(grid.history, row, col.h_txn_id, history[i].id , false, false)
		guiGridListSetItemText(grid.history, row, col.h_email, history[i].details, false, false)
		guiGridListSetItemText(grid.history, row, col.h_amount, history[i].amount , false, true)
		guiGridListSetItemText(grid.history, row, col.h_date, history[i].date , false, false)
	end
end

function updatePurchaseHistory()
	guiGridListClear(grid.purchased)
	for i = 1, #purchased do
		local row = guiGridListAddRow(grid.purchased)
		guiGridListSetItemText(grid.purchased, row, col.b_name, purchased[i][1] , false, false)
		guiGridListSetItemText(grid.purchased, row, col.b_GC, ((tonumber(purchased[i][2]) > 0) and ("+"..purchased[i][2]) or (purchased[i][2])).." GC(s)", false, true)
		guiGridListSetItemText(grid.purchased, row, col.b_purchaseDate, purchased[i][3] , false, false)
	end

	addEventHandler( "onClientGUIDoubleClick", grid.purchased,
		function( button )
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid.purchased)
				if row ~= -1 and col ~= -1 then
					local b_name = guiGridListGetItemText( grid.purchased , row, 1 )
					local b_GC = guiGridListGetItemText( grid.purchased , row, 2 )
					local b_purchaseDate = guiGridListGetItemText( grid.purchased , row, 3 )
					if setClipboard(b_name.." - "..b_GC.." - "..b_purchaseDate) then
						playSuccess()
						outputChatBox("Copied.")
					end
				end
			end
		end,
	false)
end

function updateRecents()

	if exports.integration:isPlayerLeadAdmin(localPlayer) then
		guiGridListClear(grid.recent)
		for i = 1, #globalPurchaseHistory do
			local row = guiGridListAddRow(grid.recent)
			guiGridListSetItemText(grid.recent, row, col.r_account, (globalPurchaseHistory[i][4] or "Unknown") , false, false)
			guiGridListSetItemText(grid.recent, row, col.r_details, (globalPurchaseHistory[i][1] or "Unknown") , false, false)
			guiGridListSetItemText(grid.recent, row, col.r_amount, ( tonumber(globalPurchaseHistory[i][2]) > 0 and ("+"..globalPurchaseHistory[i][2]) or (globalPurchaseHistory[i][2])).." GC(s)" , false, true)
			guiGridListSetItemText(grid.recent, row, col.r_date, globalPurchaseHistory[i][3] , false, false)
		end
	end

end

function closeDonationGUI()
	closeConfirmSpend()
	if wDonation and isElement(wDonation) then
		destroyElement(wDonation)
		wDonation,lSpendText,lActive,lAvailable,bClose,bRedeem  = nil
		lItems = {}
		bItems = { }
		triggerEvent( 'hud:blur', resourceRoot, 'off' )
	end
	hideKeyValidator()
	hidePhonePicker()
	guiSetInputEnabled(false)
	showCursor(false)
end

--

function showInfoPanel(state, cost)
	closeInfoPanel()
	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, false)
	end
	playSuccess()
	local length = 110
	local content = ""
	local confirmBtnText = "Ok"
	local links = {
		[1] = "https://owlgaming.net/account/purchase/",
		[20] = "https://owlgaming.net/account/",
		[21] = "https://owlgaming.net/account/",
	}
	if state == 1 then -- Donation intro
		length = 120
		content = "Hey, "..getElementData(localPlayer, "account:username").."! Our community needs your help! Purchase GCs now to support the community work of this project!\n\nBy helping out our server, you'll be gifted with an amount of GameCoins. This is another currency beside money in game and is used to unlock special features.\n\nEvery single dollar we get is put directly back into the work of developing for the community and to pay expenses relating to the upkeep of the OwlGaming's servers!\n\nPlease visit '"..links[state].."' to make a donation."
		confirmBtnText = "Copy Link"
	elseif state == 20 then-- Assest transfer
		length = 65
		content = "You are currently having "..exports.global:formatMoney(credits).." GC so that you will be able to do "..math.floor(credits/cost).." transfer(s).\n\nYou can get more GC by purchasing them on our site.\n\nIt costs "..cost.." GC for each time transferring some or all assets(money, interiors, vehicles,...) from a character to an alternate character of yours.\n\nPlease visit '"..links[state].."' to process the transfer."
		confirmBtnText = "Copy Link"
	elseif state == 21 then-- Custom int
		length = 155
		content = "You can spend "..cost.." Game Coins on getting a custom interior for your property.\n\nAfter you put the map in, the map will be validated, processed and be ready to use in-game instantly.\n\n- You may upload .map file only.\n- File size must be smaller than 100kB.\n- Map file may contains less than 250 objects.\n- Map file must contains at least 1 cylinder(marker for the exit of interior).\n- All objects must be placed inside the world boundaries on the X,Y,Z axis between -3000 and 3000\n\nPlease log into User Control Panel to upload your map at '"..links[state].."'."

		confirmBtnText = "Copy Link"
	elseif state == 22 then-- Instant driver's licenses & fishing permit
		length = 0
		content = "You can spend "..cost.." Game Coins on getting an instant Driver's license of any kinds (Automotive, motorbike, boat) or a fishing permit from Department of Motor Vehicles(DMV) in no time and without taking any exams.\n\nPlease visit DMV to activate this perk."
		confirmBtnText = "Activate"
	elseif state == 23 then-- Personalized vehicle licence plates
		length = 0
		content = "You can spend "..cost.." Game Coins to give yourself options to choose an appropriate personalized message that balances the right of personal expression and community standards on your vehicle plate.\n\nPlease visit DMV to activate this perk."
		confirmBtnText = "Activate"
	elseif state == 24 then-- 	Unregistered vehicle
		length = 0
		content = "You can spend "..cost.." Game Coins to remove your vehicle registration. Make your vehicle hidden from the management and monitoring of the Government.\n\nPlease visit DMV to activate this perk."
		confirmBtnText = "Activate"
	elseif state == 25 then-- 	No-plate vehicle
		length = 0
		content = "You can spend "..cost.." Game Coin to remove plate from your vehicle, get it ready for some dirty business.\n\nPlease visit DMV to activate this perk."
		confirmBtnText = "Activate"
	elseif state == 26 then-- 	No-VIN vehicle
		length = 0
		content = "You can spend "..cost.." Game Coin to remove VIN from your vehicle, get it ready for some dirty business.\n\nPlease visit DMV to activate this perk."
		confirmBtnText = "Activate"
	elseif state == 28 then -- radio
		length = 230
		content = "You can purchase and own unlimited number of stations ("..cost.." GCs each) to stream your own sound, voice or music channel in game.\n\nOnce the perk is purchased, you will be able set up your station, renew or purchase more stations, rename or change your station's streaming URL any time you like in Radio Station Manager under F10 menu.\n\nTo purchase stations, please visit F10 menu -> Radio Station Manager -> Donor's Station -> Create new station."
	elseif state == 33 then-- Cellphone Private Number
		length = 0
		content = "You can spend "..cost.." Game Coins to make your caller ID hidden from other player's cellphone screen.\n\nPlease take out your phone, go to Settings -> Calls to activate this perk."
		confirmBtnText = "OK"
	elseif state == 35 then--
		length = 250
		content = "Serials are used by MTA server and server administrators to reliably identify a PC that a player is using. They are bound to the software and hardware configuration. Serials are 32 characters long and cointain letters and numbers.\n\nSerials are the most accurate form of identifying players that MTA has. By default, you're allowed to connect to OwlGaming MTA server from any PC. However, allowing only connections from certain PC(s) by making a whitelist of serials can greatly improve your account security. Hacker won't be able to login to your account from a strange PC even when your password is completely exposed.\n\nIt's always recommended to have at least one serial of your favorite PC added to the serial whitelist.\n\nBy default, it allows only 2 serial numbers to be added for security reasons. If you want to have more serial numbers in your whitelist, it's going to cost "..cost.." GC(s) per each additional number.\n\nThis item can be activated on UCP -> Account Settings."
		confirmBtnText = "OK"
	elseif state == 36 then--
		length = 120
		content = "An interior goes inactive when no body has entered it for 14 days or when your character hasn't been logged in game for 30 days.\n\nAn inactive interior is a waste of resources and thus far the interior's ownership will be stripped from you to give other players opportunities to buy and use it more efficiently.\n\nTo prevent this to happen, you may want to spend your GC(s) to protect it from the inactive interior scanner. It costs "..cost.." GCs per week, you can also extend the duration within and after activating the perk.\n\nThis item can be activated on UCP."
		confirmBtnText = "OK"
	elseif state == 37 then--
		length = 30
		content = "Offline Private Message is a premium feature that allows you to send a private massage to any player no matter if they're online or offline.\n\nIt costs "..cost.." GC(s) per message (free-of-charge for staff members).\n\nTo send offline private message click OK or type /opm"
		confirmBtnText = "OK"
	elseif state == 38 then--
		length = 120
		content = "A vehicle goes inactive when your character hasn't been logged in game for 30 days or when no body has started its engine for 14 days while parking outdoor.\n\nAn inactive vehicle is a waste of resources and thus far the vehicle will be removed or its ownership should be stripped from you to give other players opportunities to buy and use it more efficiently.\n\nTo prevent this to happen, you may want to spend your GC(s) to protect it from the inactive vehicle scanner. \n\nIt costs "..cost.." GCs per week, you can also extend the duration within and after activating the perk.\n\nThis item can be activated on UCP."
		confirmBtnText = "OK"
	end
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 350, 190+length
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	wPhone = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)

	gui["lblText1"] = guiCreateLabel(20, 25, windowWidth-40, 100+length, content, false, wPhone)
	guiLabelSetHorizontalAlign(gui["lblText1"], "left", true)

	gui["confirm"] = guiCreateButton(20, 140+length, 150, 30, confirmBtnText, false, wPhone)
	addEventHandler( "onClientGUIClick", gui["confirm"], function()
		if source == gui["confirm"] then
			if state == 1 or state == 20 or state == 21 then
				setClipboard(links[state])
			elseif state == 37 then
				executeCommandHandler("opm")
			end
			playSoundCreate()
			closeInfoPanel()
		end
	end)

	if state == 22 or state == 23 or state == 24 or state == 25 or state == 26 or state == 28 then
		guiSetEnabled(gui["confirm"], false)
	end

	gui["btnCancel"] = guiCreateButton(180, 140+length, 150, 30, "Cancel", false, wPhone)
	addEventHandler( "onClientGUIClick", gui["btnCancel"], function()
		if source == gui["btnCancel"] then
			closeInfoPanel()
		end
	end)
end

function closeInfoPanel()
	if wPhone and isElement(wPhone) then
		destroyElement(wPhone)
		wPhone = nil
	end
	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, true)
	end
end

local wPhone = nil
local eNumber, lNumber, bNumber
local specialPhone = false
function showPhonePicker(perkID)
	if perkID == 19 then
		specialPhone = true
	else
		specialPhone = false
	end
	hidePhonePicker()
	guiSetInputEnabled(true)
	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, false)
	end
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 350, 190
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	wPhone = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)
	--guiWindowSetSizable(wPhone, false)

	guiCreateLabel(20, 25, windowWidth-40, 16, "Pick a phone number of your choice:", false, wPhone)
	eNumber = guiCreateEdit(20, 45, windowWidth-40, 30, "", false, wPhone)
	guiSetProperty(eNumber,"ValidationString","[0-9]{0,9}")
	addEventHandler("onClientGUIChanged", eNumber, checkNumber)
	lNumber = guiCreateLabel(20, 45+30 , windowWidth-40, 16, "", false, wPhone)
	guiLabelSetColor(lNumber, 255, 0, 0)

	gui["lblText2"] = guiCreateLabel(20, 45+15*2, windowWidth-40, 70, "By clicking on Purchase button, you agree that a refund is not possible. Thanks for your support!", false, wPhone)
	guiLabelSetHorizontalAlign(gui["lblText2"], "left", true)
	guiLabelSetVerticalAlign(gui["lblText2"], "center", true)

	bNumber = guiCreateButton(20, 140, 150, 30, "Purchase", false, wPhone)
	guiSetEnabled(bNumber, false)
	addEventHandler("onClientGUIClick", bNumber,
		function()
			triggerServerEvent("donation-system:GUI:activate", getLocalPlayer(), perkID, guiGetText(eNumber))
			playSoundCreate()
		end, false
	)
	local cancel = guiCreateButton(180, 140, 150, 30, "Cancel", false, wPhone)
	addEventHandler("onClientGUIClick", cancel, hidePhonePicker, false)
end

function checkNumber()
	local valid, reason = checkValidNumber(tonumber(guiGetText(eNumber)), specialPhone)
	if valid then
		guiSetText(lNumber, "Valid number")
		guiLabelSetColor(lNumber, 0, 255, 0)

		guiSetEnabled(bNumber, true)
	else
		guiSetText(lNumber, reason)
		guiLabelSetColor(lNumber, 255, 0, 0)
		guiSetEnabled(bNumber, false)
	end
end

function hidePhonePicker()
	if wPhone then
		destroyElement(wPhone)
		wPhone = nil
	end

	if wDonation then
		guiSetEnabled(wDonation, true)
	end
	guiSetInputEnabled(false)
end
addEvent("donation-system:phone:close", true)
addEventHandler("donation-system:phone:close", getRootElement(), closeDonationGUI)

function hideKeyValidator()
	if wValidate then
		destroyElement(wValidate)
		wValidate = nil
	end

	if wDonation then
		guiSetEnabled(wDonation, true)
	end
	guiSetInputEnabled(false)
end

local guiUsername = {}
function showUsernameChange(perkID)
	hideUsernameChange()
	guiSetInputEnabled(true)
	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, false)
	end
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 350, 190
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	guiUsername.main = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)
	--guiWindowSetSizable(wPhone, false)

	guiCreateLabel(20, 25, windowWidth-40, 16, "Rename my username to:", false, guiUsername.main)
	guiUsername.username = guiCreateEdit(20, 45, windowWidth-40, 30, "", false, guiUsername.main)
	guiEditSetMaxLength(guiUsername.username, 25)

	addEventHandler("onClientGUIChanged", guiUsername.username, checkUsername)
	guiUsername.noti = guiCreateLabel(20, 45+30 , windowWidth-40, 16, "This changes your forums name also.", false, guiUsername.main)
	--guiLabelSetColor(guiUsername.noti, 255, 255, 255)

	guiUsername["lblText2"] = guiCreateLabel(20, 45+15*2, windowWidth-40, 70, "By clicking on Purchase button, you agree that a refund is not possible. Thanks for your support!", false, guiUsername.main)
	guiLabelSetHorizontalAlign(guiUsername["lblText2"], "left", true)
	guiLabelSetVerticalAlign(guiUsername["lblText2"], "center", true)

	guiUsername.purchase = guiCreateButton(20, 140, 150, 30, "Purchase", false, guiUsername.main)
	guiSetEnabled(guiUsername.purchase, false)
	addEventHandler("onClientGUIClick", guiUsername.purchase,
		function()
			triggerServerEvent("donation-system:GUI:activate", getLocalPlayer(), perkID, guiGetText(guiUsername.username))
			playSoundCreate()
		end, false
	)
	guiUsername.cancel = guiCreateButton(180, 140, 150, 30, "Cancel", false, guiUsername.main)
	addEventHandler("onClientGUIClick", guiUsername.cancel, hideUsernameChange, false)
end

local guiGC = {}
local fee = nil
function showGcTransfer(perkID, fee1)
	fee = fee1
	hideGcTransfer()
	guiSetInputEnabled(true)
	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, false)
	end
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 350, 190+15*4
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	guiGC.main = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)
	--guiWindowSetSizable(wPhone, false)

	guiCreateLabel(20, 25, windowWidth-40, 16, "Enter account name you want to transfer GCs to:", false, guiGC.main)
	guiGC.username = guiCreateEdit(20, 45, windowWidth-40, 30, "", false, guiGC.main)

	guiGC.noti = guiCreateLabel(20, 45+30 , windowWidth-40, 16, "Please enter account name.", false, guiGC.main)
	guiLabelSetColor(guiGC.noti, 255, 255, 255)
	guiSetFont(guiGC.noti, "default-small")

	guiCreateLabel(20, 45+15*3, windowWidth-40, 70, "Amount of GCs to transfer:", false, guiGC.main)
	guiGC.amount = guiCreateEdit(20, 45+15*3+20, windowWidth/2-40, 30, "", false, guiGC.main)

	guiGC.math = guiCreateLabel(windowWidth/2, 45+15*3+20 , windowWidth-40, 16, "Fee ("..fee.."%): -- GCs", false, guiGC.main)
	guiSetFont(guiGC.math, "default-small")
	guiGC.total = guiCreateLabel(windowWidth/2, 45+15*4+20 , windowWidth-40, 16, "Total: -- GCs", false, guiGC.main)
	guiSetFont(guiGC.total, "default-small")

	guiGC["lblText2"] = guiCreateLabel(20, 45+15*6, windowWidth-40, 70, "By clicking on Transfer button, you agree that a refund is not possible. Thanks for your support!", false, guiGC.main)
	guiLabelSetHorizontalAlign(guiGC["lblText2"], "left", true)
	guiLabelSetVerticalAlign(guiGC["lblText2"], "center", true)

	guiGC.purchase = guiCreateButton(20, 140+15*4, 150, 30, "Transfer", false, guiGC.main)
	guiSetEnabled(guiGC.purchase, false)
	addEventHandler("onClientGUIClick", guiGC.purchase,
		function()
			if dataToSend then
				triggerServerEvent("donation-system:GUI:activate", getLocalPlayer(), perkID, dataToSend)
				playSoundCreate()
			end
			hideGcTransfer()
		end, false
	)

	addEventHandler("onClientRender", root, checkUsernameExistanceAndAmmount)

	guiGC.cancel = guiCreateButton(180, 140+15*4, 150, 30, "Cancel", false, guiGC.main)
	addEventHandler("onClientGUIClick", guiGC.cancel, function()
		removeEventHandler("onClientRender", root, checkUsernameExistanceAndAmmount)
		hideGcTransfer()
	end, false)
end

function hideGcTransfer()
	removeEventHandler("onClientRender", root, checkUsernameExistanceAndAmmount)
	if guiGC.main and isElement(guiGC.main) then
		destroyElement(guiGC.main)
	end
	guiGC = {}
	if wDonation then
		guiSetEnabled(wDonation, true)
	end
	guiSetInputEnabled(false)
end

function checkUsernameExistanceAndAmmount()
	local isEverythingAlright = true
	dataToSend = {}
	local valid, reason, found = exports.cache:checkUsernameExistance(guiGetText(guiGC.username))
	if valid then
		dataToSend.target = found
		guiSetText(guiGC.noti, reason)
		guiLabelSetColor(guiGC.noti, 0, 255, 0)
	else
		guiSetText(guiGC.noti, reason)
		guiLabelSetColor(guiGC.noti, 255, 0, 0)
		isEverythingAlright = false
	end

	local amount = tonumber(guiGetText(guiGC.amount))
	if amount and amount > 0 then
		amount = math.floor(amount)
		dataToSend.amount = amount
		local fee1 = math.ceil(amount/100*math.ceil(fee))
		guiSetText(guiGC.math, "Fee ("..fee.."%): "..fee1.." GCs")
		local total = amount+fee1
		dataToSend.total = total
		guiSetText(guiGC.total, "Total: "..total.." GCs")
		if credits >= total then
			guiLabelSetColor(guiGC.math, 0, 255, 0)
			guiLabelSetColor(guiGC.total, 0, 255, 0)
		else
			guiLabelSetColor(guiGC.math, 255, 0, 0)
			guiLabelSetColor(guiGC.total, 255, 0, 0)
			isEverythingAlright = false
		end
	else
		isEverythingAlright = false
	end

	if isEverythingAlright then
		guiSetEnabled(guiGC.purchase, true)
	else
		guiSetEnabled(guiGC.purchase, false)
	end
end



function hideUsernameChange()
	for i, gui in pairs(guiUsername) do
		if gui and isElement(gui) then
			destroyElement(gui)
		end
	end
	guiUsername = {}
	if wDonation then
		guiSetEnabled(wDonation, true)
	end
	guiSetInputEnabled(false)
end
addEvent("donation-system:username:close", true)
addEventHandler("donation-system:username:close", getRootElement(), hideUsernameChange)

function checkUsername()
	local valid, reason = checkValidUsername(guiGetText(guiUsername.username))
	if valid then
		guiSetText(guiUsername.noti, reason)
		guiLabelSetColor(guiUsername.noti, 0, 255, 0)
		guiSetEnabled(guiUsername.purchase, true)
	else
		guiSetText(guiUsername.noti, reason)
		guiLabelSetColor(guiUsername.noti, 255, 0, 0)
		guiSetEnabled(guiUsername.purchase, false)
	end
end

local keypadDoor = {}
local comboItemIndex = {}
function showKeypadDoorLock(perkID)
	local offSet = 15*6
	hideKeypadDoorLock()
	guiSetInputEnabled(true)
	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, false)
	end
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 350, 190+offSet
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	keypadDoor.main = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)
	--guiWindowSetSizable(wPhone, false)

	keypadDoor.purchase = guiCreateButton(20, 140+offSet, 150, 30, "Purchase", false, keypadDoor.main)
	guiSetEnabled(keypadDoor.purchase, false)

	local ints = getInteriorsOwnedByPlayer()
	if #ints <= 0 then
		guiSetEnabled(keypadDoor.purchase, false)
		local t1 = guiCreateLabel(20, 25, windowWidth-40, 16*4, "You must own at least one interior to purchase this item.", false, keypadDoor.main)
		guiLabelSetHorizontalAlign(t1, "left", true)
		--guiLabelSetVerticalAlign(t1, "center", true)
	else
		guiSetEnabled(keypadDoor.purchase, true)
		guiCreateLabel(20, 25, windowWidth-40, 16, "Keypad door locks, equitpping for interior:", false, keypadDoor.main)

		keypadDoor.charname = guiCreateComboBox(20, 45, windowWidth-40, 30, ints[1][2].." ((ID #"..ints[1][1].."))", false, keypadDoor.main)
		comboItemIndex[0] = {ints[1][1], ints[1][2]}
		for i = 1, #ints do
			guiComboBoxAddItem(keypadDoor.charname, ints[i][2].." ((ID #"..ints[i][1].."))")
			comboItemIndex[i-1] = {ints[i][1], ints[i][2]}
		end
		exports.global:guiComboBoxAdjustHeight(keypadDoor.charname, #ints+1)

		keypadDoor.noti = guiCreateLabel(20, 45+30 , windowWidth-40, 16, "", false, keypadDoor.main)
		guiLabelSetColor(keypadDoor.noti, 255, 0, 0)

		keypadDoor["lblText2"] = guiCreateLabel(20, 45+15*2, windowWidth-40, 70+offSet, "This perk is coming with a pairs of 2 Keyless Digital Keypad Door Locks.\n\nThis high-ended security system is much more secure than a traditional keyed lock because they can't be picked or bumped.\n\nBy clicking on Purchase button, you agree that a refund is not possible. Thanks for your support!", false, keypadDoor.main)
		guiLabelSetHorizontalAlign(keypadDoor["lblText2"], "left", true)
		guiLabelSetVerticalAlign(keypadDoor["lblText2"], "center", true)

		addEventHandler("onClientGUIClick", keypadDoor.purchase,
			function()
				local selectedIndex = guiComboBoxGetSelected ( keypadDoor.charname )
				if selectedIndex == -1 then
					selectedIndex = 0
				end

				local selectedInt = comboItemIndex[selectedIndex]
				if selectedInt and selectedInt[1] and selectedInt[2] then
					guiSetText(keypadDoor.noti, "")
					playSoundCreate()
					triggerServerEvent("donation-system:GUI:activate", getLocalPlayer(), perkID, selectedInt)
					hideKeypadDoorLock()
				else
					exports.global:PlaySoundError()
					guiSetText(keypadDoor.noti, "This interior is defected.")
				end
			end, false
		)
	end

	keypadDoor.cancel = guiCreateButton(180, 140+offSet, 150, 30, "Cancel", false, keypadDoor.main)
	addEventHandler("onClientGUIClick", keypadDoor.cancel, hideKeypadDoorLock, false)
end

function hideKeypadDoorLock()
	for i, gui in pairs(keypadDoor) do
		if gui and isElement(gui) then
			destroyElement(gui)
		end
	end
	keypadDoor = {}
	if wDonation then
		guiSetEnabled(wDonation, true)
	end
	guiSetInputEnabled(false)
end
addEvent("donation-system:charname:close", true)
addEventHandler("donation-system:charname:close", getRootElement(), hideKeypadDoorLock)

function getInteriorsOwnedByPlayer()
	ints = {}
	for key, interior in ipairs(getElementsByType("interior")) do
		if isElement(interior) then
			local status = getElementData(interior, "status")
			if status.owner == getElementData(localPlayer, "dbid") then
				local id = getElementData(interior, "dbid")
				local name = getElementData(interior, "name")
				table.insert(ints, {id, name})
			end
		end
	end
	return ints
end


--[[
function checkCharname()
	local valid, reason = exports.account:checkValidCharacterName(guiGetText(keypadDoor.charname))
	if valid then
		guiSetText(keypadDoor.noti, reason)
		guiLabelSetColor(keypadDoor.noti, 0, 255, 0)
		guiSetEnabled(keypadDoor.purchase, true)
	else
		guiSetText(keypadDoor.noti, reason)
		guiLabelSetColor(keypadDoor.noti, 255, 0, 0)
		guiSetEnabled(keypadDoor.purchase, false)
	end
end
]]

function checkCodeLength()
	if tonumber(string.len(guiGetText(source))) == 40 then
		guiSetText(lValid, "This code seems valid.")
		guiLabelSetColor(lValid, 0, 255, 0)
		guiSetEnabled(bValidate, true)
	else
		guiSetText(lValid, "This code is not valid.")
		guiLabelSetColor(lValid, 255, 0, 0)
		guiSetEnabled(bValidate, false)
	end
end

function showConfirmSpend(perkName, perkDur, perkCost, perkID)
	closeConfirmSpend()
	--guiSetInputEnabled(true)
	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, false)
	end

	local length = 1
	local shiftDown = 0
	local previewHeight = 150
	local btmText = "By clicking on Purchase button, you agree that a refund is not possible. Thanks for your support!"
	if perkID == 24 or perkID == 25 or perkID == 26 then
		length = 5
		shiftDown = previewHeight+10
		btmText = "If you own more than one screen, you can always be able to switch among different screens in 'Activated Perks' tab.\n\n"..btmText
	elseif perkID == 28 then
		length = 8
		previewHeight = 0
		shiftDown = previewHeight+10
		btmText = "You can own unlimited number of stations.\n\nOnce the perk is purchased, you will be able to access Radio Station Manager under F10 menu, it allows you to set up your station, renew or purchase more stations, rename or change your station's streaming URL any time you like.\n\n"..btmText
	end

	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 350, 190+15*length+shiftDown
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2



	wPhone = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)
	--guiWindowSetSizable(wPhone, false)

	gui["lblText1"] = guiCreateLabel(20, 25, windowWidth-40, 16, "You're about to purchase the following perk:", false, wPhone)
	gui["lblVehicleName"] = guiCreateLabel(20, 45+5, windowWidth-40, 13, "Perk: "..perkName, false, wPhone)
	guiSetFont(gui["lblVehicleName"], "default-bold-small")
	gui["lblDurr"] = guiCreateLabel(20, 45+15+5, windowWidth-40, 13, "Duration: "..perkDur, false, wPhone)
	guiSetFont(gui["lblDurr"], "default-bold-small")
	gui["lblVehicleCost"] = guiCreateLabel(20, 45+15*2+5, windowWidth-40, 13, "Cost: "..exports.global:formatMoney(perkCost), false, wPhone)
	guiSetFont(gui["lblVehicleCost"], "default-bold-small")


	if perkID == 24 or perkID == 25 or perkID == 26 then
		guiCreateStaticImage(20, 45+15*4, windowWidth-40, previewHeight, ":resources/selectionScreenID"..perkID..".jpg", false, wPhone)
	end

	gui["lblText2"] = guiCreateLabel(20, 45+15*3+shiftDown, windowWidth-40, 55+15*(length), btmText, false, wPhone)
	guiLabelSetHorizontalAlign(gui["lblText2"], "left", true)
	guiLabelSetVerticalAlign(gui["lblText2"], "center", true)

	gui["spend"] = guiCreateButton(20, 140+15*(length)+shiftDown, 150, 30, "Purchase", false, wPhone)
	addEventHandler( "onClientGUIClick", gui["spend"], function()
		if source == gui["spend"] then
			if wPhone and isElement(wPhone) then
				guiSetEnabled(wPhone, false)
			end
			triggerServerEvent("donation-system:GUI:activate", localPlayer, perkID)
			playSoundCreate()
		end
	end)

	gui["btnCancel"] = guiCreateButton(180, 140+15*(length)+shiftDown, 150, 30, "Cancel", false, wPhone)
	addEventHandler( "onClientGUIClick", gui["btnCancel"], function()
		if source == gui["btnCancel"] then
			closeConfirmSpend()
		end
	end)

end

function closeConfirmSpend()
	if wPhone then
		destroyElement(wPhone)
		wPhone = nil
	end

	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, true)
	end
end

function showConfirmRemovePerk(aName, aExpireDate, aID)
	if tonumber(aID) == 24 or tonumber(aID) == 25 or tonumber(aID) == 26 then
		closeConfirmRemovePerk()
		--guiSetInputEnabled(true)
		if wDonation and isElement(wDonation) then
			guiSetEnabled(wDonation, false)
		end
		local screenWidth, screenHeight = guiGetScreenSize()
		local windowWidth, windowHeight = 350, 190+150
		local left = screenWidth/2 - windowWidth/2
		local top = screenHeight/2 - windowHeight/2
		wPhone = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)
		--guiWindowSetSizable(wPhone, false)

		gui["lblText1"] = guiCreateLabel(20, 25, windowWidth-40, 16, "Unique character selection screen configurations:", false, wPhone)
		guiSetFont(gui["lblText1"], "default-bold-small")
		gui["lblVehicleName"] = guiCreateLabel(20, 45+5, windowWidth-40, 13, aName, false, wPhone)
		--guiSetFont(gui["lblVehicleName"], "default-bold-small")
		gui["lblVehicleCost"] = guiCreateLabel(20, 45+15+5, windowWidth-40, 13, "Expire Date: "..aExpireDate, false, wPhone)
		--guiSetFont(gui["lblVehicleCost"], "default-bold-small")

		guiCreateStaticImage(20, 45+15*3+5, windowWidth-40, 150, ":resources/selectionScreenID"..aID..".jpg", false, wPhone)

		local hasThisPerk, thisPerkValue = hasPlayerPerk(localPlayer, aID)
		if hasThisPerk and tonumber(thisPerkValue) == 1 then
			gui["use"] = guiCreateButton(20, 45+15*4+150, windowWidth-40, 30, "Stop using this screen", false, wPhone)
			addEventHandler( "onClientGUIClick", gui["use"], function()
				if source == gui["use"] then
					if wPhone and isElement(wPhone) then
						guiSetEnabled(wPhone, false)
					end
					triggerServerEvent("donators:updatePerkValue", localPlayer, localPlayer, aID, 0)
					playSoundCreate()
					closeConfirmRemovePerk()
				end
			end)
		else
			gui["use"] = guiCreateButton(20, 45+15*4+150, windowWidth-40, 30, "Use this screen", false, wPhone)
			addEventHandler( "onClientGUIClick", gui["use"], function()
				if source == gui["use"] then
					if wPhone and isElement(wPhone) then
						guiSetEnabled(wPhone, false)
					end
					triggerServerEvent("donators:updatePerkValue", localPlayer, localPlayer, aID, 1)
					playSoundCreate()
					closeConfirmRemovePerk()
				end
			end)
		end


		gui["spend"] = guiCreateButton(20, 140+150, 150, 30, "Remove", false, wPhone)
		addEventHandler( "onClientGUIClick", gui["spend"], function()
			if source == gui["spend"] then
				if wPhone and isElement(wPhone) then
					guiSetEnabled(wPhone, false)
				end
				triggerServerEvent("donation-system:GUI:remove", localPlayer, aID)
				playSoundCreate()
			end
		end)

		gui["btnCancel"] = guiCreateButton(180, 140+150, 150, 30, "Cancel", false, wPhone)
		addEventHandler( "onClientGUIClick", gui["btnCancel"], function()
			if source == gui["btnCancel"] then
				closeConfirmRemovePerk()
			end
		end)
	else
		closeConfirmRemovePerk()
		--guiSetInputEnabled(true)
		if wDonation and isElement(wDonation) then
			guiSetEnabled(wDonation, false)
		end
		local screenWidth, screenHeight = guiGetScreenSize()
		local windowWidth, windowHeight = 350, 190
		local left = screenWidth/2 - windowWidth/2
		local top = screenHeight/2 - windowHeight/2
		wPhone = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)
		--guiWindowSetSizable(wPhone, false)

		gui["lblText1"] = guiCreateLabel(20, 25, windowWidth-40, 16, "You're about to remove the following perk:", false, wPhone)
		gui["lblVehicleName"] = guiCreateLabel(20, 45+5, windowWidth-40, 13, aName, false, wPhone)
		guiSetFont(gui["lblVehicleName"], "default-bold-small")
		gui["lblVehicleCost"] = guiCreateLabel(20, 45+15+5, windowWidth-40, 13, "Expire Date: "..aExpireDate, false, wPhone)
		guiSetFont(gui["lblVehicleCost"], "default-bold-small")
		gui["lblText2"] = guiCreateLabel(20, 45+15*2, windowWidth-40, 70, "This action can not be undone!", false, wPhone)
		guiLabelSetHorizontalAlign(gui["lblText2"], "left", true)
		guiLabelSetVerticalAlign(gui["lblText2"], "center", true)

		gui["spend"] = guiCreateButton(20, 140, 150, 30, "Remove", false, wPhone)
		addEventHandler( "onClientGUIClick", gui["spend"], function()
			if source == gui["spend"] then
				if wPhone and isElement(wPhone) then
					guiSetEnabled(wPhone, false)
				end
				triggerServerEvent("donation-system:GUI:remove", localPlayer, aID)
				playSoundCreate()
			end
		end)

		gui["btnCancel"] = guiCreateButton(180, 140, 150, 30, "Cancel", false, wPhone)
		addEventHandler( "onClientGUIClick", gui["btnCancel"], function()
			if source == gui["btnCancel"] then
				closeConfirmRemovePerk()
			end
		end)
	end
end

function closeConfirmRemovePerk()
	if wPhone then
		destroyElement(wPhone)
		wPhone = nil
	end
	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, true)
	end
end

local chatIcon = {}
local countryFlags = {
	[1] = "Default",
	[2] = "Albania",
	[3] = "Brazil",
	[4] = "Bulgaria",
	[5] = "Canada",
	[6] = "Denmark",
	[7] = "United_Kingdom",
	[8] = "Estonia",
	[9] = "Finland",
	[10] = "France",
	[11] = "India",
	[12] = "Ireland",
	[13] = "Lithuania",
	[14] = "Morocco",
	[15] = "Montenegro",
	[16] = "Netherlands",
	[17] = "Norway",
	[18] = "Portugal",
	[19] = "Russia",
	[20] = "Scotland",
	[21] = "Serbia",
	[22] = "Spain",
	[23] = "Sweden",
	[24] = "Turkey",
	[25] = "United_States",
	[26] = "Wales",
	[27] = "Slovenia",
	[28] = "Lebanon",
	[29] = "Palestine",
	[30] = "Australia",
	[31] = "Romania",
	[32] = "Israel",
	[33] = "Lybia",
	[34] = "Hercegovina",
	[35] = "Khalistan",
	[36] = "Iraq",
	[37] = "Ukraine",
	[38] = "Puerto_Rico",
	[39] = "Latvia",
	[40] = "Mexico",
	[41] = "Poland",
	[42] = "Belgium",
	[43] = "Wallonia_(Belgian_Province)",
	[44] = "Flanders_(Belgian_Province)",
	[45] = "Jamaica",
	[46] = "Japan",
	[47] = "Slovakia",
	[48] = "Switzerland",
	[49] = "United_Arab_Emirates",
	[50] = "Egypt",
	[51] = "Croatia",
	[52] = "Kazakhstan",
	[53] = "Greece",
	[54] = "Republic_Of_Congo",
	[55] = "North_Korea",
	[56] = "Pakistan",
	[57] = "Saudi_Arabia"
}

function getFlagURL(index)
	if countryFlags[index] then
		return ":donators/typing_icons/"..countryFlags[index]..".png"
	else
		return false
	end
end

local selectedIcon = 1

function switchIcon(movingForward, currentIcon, label, image)
	local nextIcon = movingForward and (currentIcon+1) or (currentIcon-1)
	if label and image and isElement(label) and isElement(image) and countryFlags[nextIcon] then
		guiSetText(label, "("..nextIcon.."/"..(#countryFlags)..") "..(string.gsub(countryFlags[nextIcon], "_", " ")))

		local nextImg = nil
		if nextIcon == 1 then
			nextImg = ":chat-system/chat.png"
		else
			nextImg = "typing_icons/"..countryFlags[nextIcon]..".png"
		end
		guiStaticImageLoadImage(image, nextImg)
		playSoundFrontEnd(1)
		return nextIcon
	else
		playError()
	end
end

function showCustomChatIconMenu(pID, pCost, removing)
	closeCustomChatIconMenu()
	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, false)
	end
	playSuccess()
	selectedIcon = 1
	local length = 110

	local content = "You can spend "..pCost.." on getting a customized country flag to replace the default OwlGaming logo with your own typing icon above your character's head. \n\nOnce you purchased and activated the perk, you will be able to switch to other country flags anytime in 'Activated Perks' tab."

	if removing then
		content = "Customized country flag typing icon is a special perk, allows you to to replace the default OwlGaming logo with your own icon above your character's head.\n\nPlease choose a flag to change to, it's free as you've already purchased this perk."
	end

	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 400, 280
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2

	local imageScale = 1
	local imageSizeW, imageSizeH = 126*imageScale, 77*imageScale
	local imgPosX = (windowWidth-imageSizeW)/2

	chatIcon.wMain = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)

	chatIcon["lblText1"] = guiCreateLabel(20, 25, windowWidth-40, 100, content, false, chatIcon.wMain)
	guiLabelSetHorizontalAlign(chatIcon["lblText1"], "left", true)


	chatIcon["lFlag"] = guiCreateLabel(20, 125+imageSizeH, windowWidth-40, 15, "(1/"..#countryFlags..") Default", false, chatIcon.wMain)
	guiLabelSetHorizontalAlign(chatIcon["lFlag"], "center", true)
	chatIcon["iFlag"] = guiCreateStaticImage(imgPosX, 125, imageSizeW, imageSizeH, ":chat-system/chat.png", false, chatIcon.wMain)

	btnSize = 20
	chatIcon.bPrevious = guiCreateButton(imgPosX-btnSize*2, 125+imageSizeH/2-btnSize/2, btnSize, btnSize, "<", false, chatIcon.wMain)
	chatIcon.bNext = guiCreateButton(imgPosX+btnSize+imageSizeW, 125+imageSizeH/2-btnSize/2, btnSize, btnSize, ">", false, chatIcon.wMain)

	addEventHandler( "onClientGUIClick", chatIcon.bNext, function()
		if source == chatIcon.bNext then
			local selectedIconTmp = switchIcon(true, selectedIcon, chatIcon["lFlag"], chatIcon["iFlag"])
			if selectedIconTmp and tonumber(selectedIconTmp) then
				selectedIcon = selectedIconTmp
			end
		end
	end)

	addEventHandler( "onClientGUIClick", chatIcon.bPrevious, function()
		if source == chatIcon.bPrevious then
			local selectedIconTmp = switchIcon(false, selectedIcon, chatIcon["lFlag"], chatIcon["iFlag"])
			if selectedIconTmp and tonumber(selectedIconTmp) then
				selectedIcon = selectedIconTmp
			end
		end
	end)

	local btnW = (windowWidth-40)/2
	chatIcon["confirm"] = guiCreateButton(20, 120+length, btnW, 30, (removing and "Switch" or "Purchase"), false, chatIcon.wMain)
	addEventHandler( "onClientGUIClick", chatIcon["confirm"], function()
		if source == chatIcon["confirm"] then
			playSoundCreate()
			closeCustomChatIconMenu()
			if removing then
				triggerServerEvent("donators:updatePerkValue" , localPlayer, localPlayer, pID, selectedIcon)
			else
				triggerServerEvent("donation-system:GUI:activate", localPlayer, pID, selectedIcon)
			end
		end
	end)

	chatIcon["btnCancel"] = guiCreateButton(20+btnW, 120+length, btnW, 30, "Cancel", false, chatIcon.wMain)
	addEventHandler( "onClientGUIClick", chatIcon["btnCancel"], function()
		if source == chatIcon["btnCancel"] then
			closeCustomChatIconMenu()
		end
	end)
end


function showLearnLanguageMenu(pID, pCost)
	closeCustomChatIconMenu()
	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, false)
	end
	playSuccess()
	local length = 110

	local content = "You can spend "..pCost.." GC(s) on making your current character ("..tostring(getPlayerName(localPlayer)):gsub("_", " ")..") fully learning a selected language instantly. Please select language from the list below."

	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 400, 280
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2

	local imageScale = 1
	local imageSizeW, imageSizeH = 126*imageScale, 77*imageScale
	local imgPosX = (windowWidth-imageSizeW)/2

	chatIcon.wMain = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)

	chatIcon["lblText1"] = guiCreateLabel(20, 25, windowWidth-40, 100, content, false, chatIcon.wMain)
	guiLabelSetHorizontalAlign(chatIcon["lblText1"], "left", true)

	local btnW = (windowWidth-40)/2
	chatIcon["confirm"] = guiCreateButton(20, 120+length, btnW, 30, "Purchase ("..tostring(pCost).." GCs)", false, chatIcon.wMain)
	addEventHandler( "onClientGUIClick", chatIcon["confirm"], function()
		if source == chatIcon["confirm"] then
			playSoundCreate()
			local item = guiComboBoxGetSelected(chatIcon["select"])
			local text = guiComboBoxGetItemText(chatIcon["select"], item)
			local selectedLang
			local languages = chatIcon["languages"]
			for k,v in ipairs(languages) do
				if text == v then
					selectedLang = k
					break
				end
			end
			if selectedLang then
				selectedLang = tonumber(selectedLang)
				if selectedLang > 0 then
					triggerServerEvent("donation-system:GUI:activate", localPlayer, pID, selectedLang)
				end
				closeLearnLanguageMenu()
			else
				closeLearnLanguageMenu()
			end
		end
	end)

	chatIcon["btnCancel"] = guiCreateButton(20+btnW, 120+length, btnW, 30, "Cancel", false, chatIcon.wMain)
	addEventHandler( "onClientGUIClick", chatIcon["btnCancel"], function()
		if source == chatIcon["btnCancel"] then
			closeLearnLanguageMenu()
		end
	end)

	local languages = exports["language-system"]:getLanguageList()
	chatIcon["languages"] = languages
	--table.sort(languages)

	chatIcon["select"] = guiCreateComboBox(20, 150, windowWidth-40, 100, "Select Language", false, chatIcon.wMain)

	for k,v in ipairs (languages) do
		guiComboBoxAddItem(chatIcon["select"], tostring(v))
	end

end
function closeLearnLanguageMenu()
	if chatIcon.wMain then
		destroyElement(chatIcon.wMain)
		chatIcon.wMain = nil
	end

	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, true)
	end
end

function closeCustomChatIconMenu()
	if chatIcon.wMain then
		destroyElement(chatIcon.wMain)
		chatIcon.wMain = nil
	end

	if wDonation and isElement(wDonation) then
		guiSetEnabled(wDonation, true)
	end
end
















function getResponseFromServer(code, msg)
	if code == 1 then
		closeConfirmSpend()
	elseif code == 2 then
		closeConfirmRemovePerk()
	elseif code == 3 then

	end
	if wDonation and isElement(wDonation) then
		guiSetText(wDonation, "OwlGaming Store - "..msg)
	end
end
addEvent("donation-system:getResponseFromServer", true)
addEventHandler("donation-system:getResponseFromServer", root, getResponseFromServer)

function playError()
	playSoundFrontEnd(4)
end

function playSuccess()
	playSoundFrontEnd(13)
end

function playSoundCreate()
	playSoundFrontEnd(6)
end

function isVisible()
	return wDonation and isElement(wDonation)
end
