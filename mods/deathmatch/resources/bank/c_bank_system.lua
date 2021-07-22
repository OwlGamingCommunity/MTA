version = "Bank System v3.0 [06.09.2014]"

wBank, bClose, lBalance, tabPanel, tabPersonal, tabPersonalTransactions, tabBusiness, tabBusinessTransactions, lWithdrawP, tWithdrawP, bWithdrawP, lDepositP, tDepositP, bDepositP = nil
lWithdrawB, tWithdrawB, bWithdrawB, lDepositB, tDepositB, bDepositB, lBalanceB, gPersonalTransactions, gBusinessTransactions = nil
gfactionBalance = nil
cooldown = nil

lastUsedATM = nil
_depositable = nil
_withdrawable = nil
limitedwithdraw = 0

local localPlayer = getLocalPlayer()
function tonumber2( num )
	if type(num) == "number" then
		return num
	else
		num = num:gsub(",",""):gsub("%$","")
		return tonumber(num)
	end
end

local bankPed = createPed(150, 2358.710205, 2361.2133789, 2022.919189)
setPedRotation(bankPed, 90.4609375)
setElementInterior(bankPed, 3)

function updateTabStuff(fTable)
	if guiGetSelectedTab(tabPanel) == tabPersonalTransactions then
		guiGridListClear(gPersonalTransactions)
		triggerServerEvent("tellTransfersPersonal", localPlayer, cardInfoSaved)
	elseif guiGetSelectedTab(tabPanel) == tabBusinessTransactions then
		guiGridListClear(gBusinessTransactions)
		startFactionSelect(fTable, 2)
		--triggerServerEvent("tellTransfersBusiness", localPlayer)
	elseif guiGetSelectedTab(tabPanel) == tabBusiness then
		startFactionSelect(fTable, 1) -- 1 = tabBusiness, 2 = transactions
	end
end

local factionSelectGUI = {
    button = {},
    window = {},
    combobox = {}
}
function startFactionSelect(fTable, selectiontype)
	closeFactionSelect()

    factionSelectGUI.window[1] = guiCreateWindow(766, 385, 399, 121, "Select the faction to view", false)
    guiWindowSetSizable(factionSelectGUI.window[1], false)
	guiSetAlpha(factionSelectGUI.window[1], 0.89)
	exports.global:centerWindow(factionSelectGUI.window[1])
	guiSetEnabled(wBank, false)

    factionSelectGUI.button[1] = guiCreateButton(13, 64, 111, 42, "Cancel", false, factionSelectGUI.window[1])
    guiSetProperty(factionSelectGUI.button[1], "NormalTextColour", "FFAAAAAA")
    factionSelectGUI.combobox[1] = guiCreateComboBox(13, 35, 366, 113, "Select the faction to view", false, factionSelectGUI.window[1])
    factionSelectGUI.button[2] = guiCreateButton(268, 64, 111, 42, "Accept", false, factionSelectGUI.window[1])
    guiSetProperty(factionSelectGUI.button[2], "NormalTextColour", "FFAAAAAA")  

    for k,v in pairs(fTable) do
    	guiComboBoxAddItem(factionSelectGUI.combobox[1], exports.factions:getFactionName(k))
    end  

    addEventHandler("onClientGUIClick", factionSelectGUI.button[2], function()
    	local name = guiComboBoxGetItemText(factionSelectGUI.combobox[1], guiComboBoxGetSelected(factionSelectGUI.combobox[1]))

    	if name ~= "Select the faction to view" then
    		if selectiontype == 2 then
				triggerServerEvent("tellTransfersBusiness", localPlayer, name)
			else
				fillBusiness(name)
			end
    		closeFactionSelect()
    	else
    		outputChatBox("Please select a faction.", 255, 0, 0)
    	end
    end, false)

    addEventHandler("onClientGUIClick", factionSelectGUI.button[1], closeFactionSelect, false)
end

function closeFactionSelect()
	if factionSelectGUI.window[1] and isElement(factionSelectGUI.window[1]) then
		destroyElement(factionSelectGUI.window[1])
		factionSelectGUI.window[1] = nil
		if wBank and isElement(wBank) then
			guiSetEnabled(wBank, true)
		end
	end
end

function fillBusiness(name)
	if wBank and isElement(wBank) then
		local faction = exports.factions:getFactionFromName(name)
		if faction then
			gFactionID = getElementData(faction, "id")
			gfactionBalance = exports.global:getMoney(faction)
			guiSetText(lBalanceB, "Balance: $" .. exports.global:formatMoney(gfactionBalance))
		end
	end
end

function showBankUI(fTable, depositable, limit, withdrawable, ped)
	if not (wBank) then
		if getElementData(getLocalPlayer(), "exclusiveGUI") or not isCameraOnPlayer() then
			return false
		end
		cardInfoSaved = nil
		_depositable = depositable
		_withdrawable = withdrawable
		lastUsedATM = source
		limitedwithdraw = limit

		setElementData(getLocalPlayer(), "exclusiveGUI", true, false)

		local width, height = 600, 400
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)

		local transactionColumns = {
			{ "ID", 0.09 },
			{ "From", 0.2 },
			{ "To", 0.2 },
			{ "Amount", 0.1 },
			{ "Date", 0.2 },
			{ "Reason", 0.5 }
		}

		local bannedTypes = {
			[0] = true,
			[1] = true,
		}

		wBank = guiCreateWindow(x, y, width, height, "Bank of Los Santos | "..version.."", false)
		guiWindowSetSizable(wBank, false)

		tabPanel = guiCreateTabPanel(0.05, 0.05, 0.9, 0.85, true, wBank)
		addEventHandler( "onClientGUITabSwitched", tabPanel, function() updateTabStuff(fTable) end )

		tabPersonal = guiCreateTab("Personal Banking", tabPanel)
		tabPersonalTransactions = guiCreateTab("Personal Transactions", tabPanel)

		local hoursplayed = getElementData(localPlayer, "hoursplayed") or 0
		if (exports.global:countTable(fTable) > 0) then
			tabBusiness = guiCreateTab("Business Banking", tabPanel)

			lBalanceB = guiCreateLabel(0.1, 0.05, 0.9, 0.05, "Balance: $", true, tabBusiness)
			guiSetFont(lBalanceB, "default-bold-small")

			if (withdrawable) then
			-- WITHDRAWAL BUSINESS
				lWithdrawB = guiCreateLabel(0.1, 0.15, 0.2, 0.05, "Withdraw:", true, tabBusiness)
				guiSetFont(lWithdrawB, "default-bold-small")

				tWithdrawB = guiCreateEdit(0.22, 0.13, 0.2, 0.075, "0", true, tabBusiness)
				guiSetFont(tWithdrawB, "default-bold-small")
				addEventHandler("onClientGUIClick", tWithdrawB, function()
					if guiGetText(tWithdrawB) == "0" then
						guiSetText(tWithdrawB, "")
					end
				end, false)

				bWithdrawB = guiCreateButton(0.44, 0.13, 0.2, 0.075, "Withdraw", true, tabBusiness)
				addEventHandler("onClientGUIClick", bWithdrawB, withdrawMoneyBusiness, false)
			else
				lWithdrawB = guiCreateLabel(0.1, 0.15, 0.5, 0.05, "This ATM does not support the withdraw function.", true, tabBusiness)
				guiSetFont(lWithdrawB, "default-bold-small")
			end

			if (depositable) then
				-- DEPOSIT BUSINESS
				lDepositB = guiCreateLabel(0.1, 0.25, 0.2, 0.05, "Deposit:", true, tabBusiness)
				guiSetFont(lDepositB, "default-bold-small")

				tDepositB = guiCreateEdit(0.22, 0.23, 0.2, 0.075, "0", true, tabBusiness)
				guiSetFont(tDepositB, "default-bold-small")
				addEventHandler("onClientGUIClick", tDepositB, function()
					if guiGetText(tDepositB) == "0" then
						guiSetText(tDepositB, "")
					end
				end, false)

				bDepositB = guiCreateButton(0.44, 0.23, 0.2, 0.075, "Deposit", true, tabBusiness)
				addEventHandler("onClientGUIClick", bDepositB, depositMoneyBusiness, false)
			else
				lDepositB = guiCreateLabel(0.1, 0.25, 0.5, 0.05, "This ATM does not support the deposit function.", true, tabBusiness)
				guiSetFont(lDepositB, "default-bold-small")

				if limitedwithdraw > 0 and withdrawable then
					tDepositB = guiCreateLabel(0.67, 0.15, 0.2, 0.05, "Max: $" .. exports.global:formatMoney( limitedwithdraw - ( getElementData( source, "withdrawn" ) or 0 ) ) .. ".", true, tabBusiness)
					guiSetFont(tDepositB, "default-bold-small")
				end
			end

			if hoursplayed >= 12 then
				-- TRANSFER BUSINESS
				lTransferB = guiCreateLabel(0.1, 0.45, 0.2, 0.05, "Transfer:", true, tabBusiness)
				guiSetFont(lTransferB, "default-bold-small")

				tTransferB = guiCreateEdit(0.22, 0.43, 0.2, 0.075, "0", true, tabBusiness)
				guiSetFont(tTransferB, "default-bold-small")
				addEventHandler("onClientGUIClick", tTransferB, function()
					if guiGetText(tTransferB) == "0" then
						guiSetText(tTransferB, "")
					end
				end, false)

				bTransferB = guiCreateButton(0.44, 0.43, 0.2, 0.075, "Transfer to", true, tabBusiness)
				addEventHandler("onClientGUIClick", bTransferB, transferMoneyBusiness, false)

				eTransferB = guiCreateEdit(0.66, 0.43, 0.3, 0.075, "<Bank Account Number>", true, tabBusiness)
				addEventHandler("onClientGUIClick", eTransferB, function()
					if guiGetText(eTransferB) == "<Bank Account Number>" then
						guiSetText(eTransferB, "")
					end
				end, false)

				lTransferBReason = guiCreateLabel(0.1, 0.55, 0.2, 0.05, "Reason:", true, tabBusiness)
				guiSetFont(lTransferBReason, "default-bold-small")

				tTransferBReason = guiCreateEdit(0.22, 0.54, 0.74, 0.075, "<What is this transaction for?>", true, tabBusiness)
				addEventHandler("onClientGUIClick", tTransferBReason, function()
					if guiGetText(tTransferBReason) == "<What is this transaction for?>" then
						guiSetText(tTransferBReason, "")
					end
				end, false)
			end

			-- TRANSACTION HISTORY
			tabBusinessTransactions = guiCreateTab("Business Transactions", tabPanel)

			gBusinessTransactions = guiCreateGridList(0.02, 0.02, 0.96, 0.96, true, tabBusinessTransactions)
			for key, value in ipairs( transactionColumns ) do
				guiGridListAddColumn( gBusinessTransactions, value[1], value[2] or 0.1 )
			end
		end

		bClose = guiCreateButton(0.75, 0.91, 0.2, 0.1, "Close", true, wBank)
		addEventHandler("onClientGUIClick", bClose, hideBankUI, false)

		local balance = getElementData(localPlayer, "bankmoney")

		--outputDebugString(balance)
		--outputDebugString(exports.global:formatMoney(balance))

		--shit
		lBalance = guiCreateLabel(0.1, 0.05, 0.9, 0.05, "Balance: $" .. exports.global:formatMoney(balance), true, tabPersonal)
		guiSetFont(lBalance, "default-bold-small")

		if withdrawable then
			-- WITHDRAWAL PERSONAL
			lWithdrawP = guiCreateLabel(0.1, 0.15, 0.2, 0.05, "Withdraw:", true, tabPersonal)
			guiSetFont(lWithdrawP, "default-bold-small")

			tWithdrawP = guiCreateEdit(0.22, 0.13, 0.2, 0.075, "0", true, tabPersonal)
			guiSetFont(tWithdrawP, "default-bold-small")
			addEventHandler("onClientGUIClick", tWithdrawP, function()
				if guiGetText(tWithdrawP) == "0" then
					guiSetText(tWithdrawP, "")
				end
			end, false)

			bWithdrawP = guiCreateButton(0.44, 0.13, 0.2, 0.075, "Withdraw", true, tabPersonal)
			addEventHandler("onClientGUIClick", bWithdrawP, withdrawMoneyPersonal, false)
		else
			lWithdrawP = guiCreateLabel(0.1, 0.15, 0.5, 0.05, "This ATM does not support the withdraw function.", true, tabPersonal)
			guiSetFont(lWithdrawP, "default-bold-small")
		end

		if (depositable) then
			-- DEPOSIT PERSONAL
			lDepositP = guiCreateLabel(0.1, 0.25, 0.2, 0.05, "Deposit:", true, tabPersonal)
			guiSetFont(lDepositP, "default-bold-small")

			tDepositP = guiCreateEdit(0.22, 0.23, 0.2, 0.075, "0", true, tabPersonal)
			guiSetFont(tDepositP, "default-bold-small")
			addEventHandler("onClientGUIClick", tDepositP, function()
				if guiGetText(tDepositP) == "0" then
					guiSetText(tDepositP, "")
				end
			end, false)

			bDepositP = guiCreateButton(0.44, 0.23, 0.2, 0.075, "Deposit", true, tabPersonal)
			addEventHandler("onClientGUIClick", bDepositP, depositMoneyPersonal, false)
		else
			lDepositP = guiCreateLabel(0.1, 0.25, 0.5, 0.05, "This ATM does not support the deposit function.", true, tabPersonal)
			guiSetFont(lDepositP, "default-bold-small")

			if limitedwithdraw > 0 and withdrawable then
				tDepositP = guiCreateLabel(0.67, 0.15, 0.2, 0.05, "Max: $" .. ( limitedwithdraw - ( getElementData( source, "withdrawn" ) or 0 ) ) .. ".", true, tabPersonal)
				guiSetFont(tDepositP, "default-bold-small")
			end
		end

		if hoursplayed >= 12 then
			-- TRANSFER PERSONAL
			lTransferP = guiCreateLabel(0.1, 0.45, 0.2, 0.05, "Transfer:", true, tabPersonal)
			guiSetFont(lTransferP, "default-bold-small")

			tTransferP = guiCreateEdit(0.22, 0.43, 0.2, 0.075, "0", true, tabPersonal)
			guiSetFont(tTransferP, "default-bold-small")
			addEventHandler("onClientGUIClick", tTransferP, function()
				if guiGetText(tTransferP) == "0" then
					guiSetText(tTransferP, "")
				end
			end, false)

			bTransferP = guiCreateButton(0.44, 0.43, 0.2, 0.075, "Transfer to", true, tabPersonal)
			addEventHandler("onClientGUIClick", bTransferP, transferMoneyPersonal, false)

			eTransferP = guiCreateEdit(0.66, 0.43, 0.3, 0.075, "<Player/Faction Name>", true, tabPersonal)
			addEventHandler("onClientGUIClick", eTransferP, function()
				if guiGetText(eTransferP) == "<Player/Faction Name>" then
					guiSetText(eTransferP, "")
				end
			end, false)

			lTransferPReason = guiCreateLabel(0.1, 0.55, 0.2, 0.05, "Reason:", true, tabPersonal)
			guiSetFont(lTransferPReason, "default-bold-small")

			tTransferPReason = guiCreateEdit(0.22, 0.54, 0.74, 0.075, "<What is this transaction for?>", true, tabPersonal)
			addEventHandler("onClientGUIClick", tTransferPReason, function()
				if guiGetText(tTransferPReason) == "<What is this transaction for?>" then
					guiSetText(tTransferPReason, "")
				end
			end, false)
		end

		-- TRANSACTION HISTORY

		gPersonalTransactions = guiCreateGridList(0.02, 0.02, 0.96, 0.96, true, tabPersonalTransactions)
		for key, value in ipairs( transactionColumns ) do
			guiGridListAddColumn( gPersonalTransactions, value[1], value[2] or 0.1 )
		end

		guiSetInputEnabled(true)

		--outputChatBox("Welcome to the Bank of Los Santos")

	end
end
addEvent("showBankUI", true)
addEventHandler("showBankUI", getRootElement(), showBankUI)

function hideBankUI()
	if isElement(wBank) then
		destroyElement(wBank)
		wBank = nil

		guiSetInputEnabled(false)

		cooldown = setTimer(function() cooldown = nil end, 1000, 1)
		setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
		if exports.phone:isPhoneGUICreated() then
			setElementData(localPlayer, "exclusiveGUI", true)
			exports.phone:drawPhoneHome()
		 end
	end
end
addEvent("hideBankUI", true)
addEventHandler("hideBankUI", getRootElement(), hideBankUI)
addEventHandler ( "account:changingchar", getRootElement(), hideBankUI )
addEventHandler("onClientChangeChar", getRootElement(), hideBankUI)

function withdrawMoneyPersonal(button)
	if (button=="left") then
		local amount = tonumber2(guiGetText(tWithdrawP))
		local money = getElementData(localPlayer, "bankmoney")

		local oldamount = getElementData( lastUsedATM, "withdrawn" ) or 0
		if not amount or amount <= 0 or math.ceil( amount ) ~= amount then
			outputChatBox("Please enter a positive amount!", 255, 0, 0)
		elseif (amount>money) then
			outputChatBox("You do not have enough funds.", 255, 0, 0)
		elseif not _depositable and limitedwithdraw ~= 0 and oldamount + amount > limitedwithdraw then
			outputChatBox("This ATM only allows you to withdraw $" .. exports.global:formatMoney( limitedwithdraw - oldamount ) .. ".")
		else
			setElementData( lastUsedATM, "withdrawn", oldamount + amount, false )
			setTimer(
				function( atm, amount )
					setElementData( atm, "withdrawn", getElementData( atm, "withdrawn" ) - amount )
				end,
				120000, 1, lastUsedATM, amount
			)
			hideBankUI()
			triggerServerEvent("withdrawMoneyPersonal", localPlayer, amount)
		end
	end
end

function depositMoneyPersonal(button)
	if (button=="left") then
		local amount = tonumber2(guiGetText(tDepositP))

		if not amount or amount <= 0 or math.ceil( amount ) ~= amount then
			outputChatBox("Please enter a positive amount!", 255, 0, 0)
		elseif not exports.global:hasMoney(localPlayer, amount) then
			outputChatBox("You do not have enough funds.", 255, 0, 0)
		else
			hideBankUI()
			triggerServerEvent("depositMoneyPersonal", localPlayer, amount)
		end
	end
end

function transferMoneyPersonal(button)
	if (button=="left") then
		local amount = tonumber2(guiGetText(tTransferP))
		local money = getElementData(localPlayer, "bankmoney")
		local reason = guiGetText(tTransferPReason)
		local playername = guiGetText(eTransferP)

		if not amount or amount <= 0 or math.ceil( amount ) ~= amount then
			outputChatBox("Please enter a positive amount!", 255, 0, 0)
		elseif (amount>money) then
			outputChatBox("You do not have enough funds.", 255, 0, 0)
		elseif reason == "" then
			outputChatBox("Please enter a reason for the Transfer!", 255, 0, 0)
		elseif playername == "" then
			outputChatBox("Please enter the full character name of the reciever!", 255, 0, 0)
		else
			triggerServerEvent("transferMoneyToPersonal", localPlayer, nil, playername, amount, reason )
			guiSetText(tTransferP, "0")
			guiSetText(tTransferPReason, "")
			guiSetText(eTransferP, "")
		end
	end
end

function withdrawMoneyBusiness(button)
	if (button=="left") then
		local amount = tonumber2(guiGetText(tWithdrawB))

		local oldamount = getElementData( lastUsedATM, "withdrawn" ) or 0
		if not amount or amount <= 0 or math.ceil( amount ) ~= amount then
			outputChatBox("Please enter a positive amount!", 255, 0, 0)
		elseif (amount>gfactionBalance) then
			outputChatBox("You do not have enough funds.", 255, 0, 0)
		elseif not _depositable and limitedwithdraw ~= 0 and oldamount + amount > limitedwithdraw then
			outputChatBox("This ATM only allows you to withdraw $" .. exports.global:formatMoney( limitedwithdraw - oldamount ) .. ".")
		else
			setElementData( lastUsedATM, "withdrawn", oldamount + amount, false )
			setTimer(
				function( atm, amount )
					setElementData( atm, "withdrawn", getElementData( atm, "withdrawn" ) - amount, false )
				end,
				120000, 1, lastUsedATM, amount
			)
			hideBankUI()
			triggerServerEvent("withdrawMoneyBusiness", localPlayer, amount, gFactionID)
		end
	end
end

function depositMoneyBusiness(button)
	if (button=="left") then
		local amount = tonumber2(guiGetText(tDepositB))

		if not amount or amount <= 0 or math.ceil( amount ) ~= amount then
			outputChatBox("Please enter a positive amount!", 255, 0, 0)
		elseif not exports.global:hasMoney(localPlayer, amount) then
			outputChatBox("You do not have enough funds.", 255, 0, 0)
		else
			hideBankUI()
			triggerServerEvent("depositMoneyBusiness", localPlayer, amount, gFactionID)
		end
	end
end

function transferMoneyBusiness(button)
	if (button=="left") then
		local amount = tonumber2(guiGetText(tTransferB))
		local playername = guiGetText(eTransferB)
		local reason = guiGetText(tTransferBReason)

		if not amount or amount <= 0 or math.ceil( amount ) ~= amount then
			outputChatBox("Please enter a positive amount!", 255, 0, 0)
		elseif (amount>gfactionBalance) then
			outputChatBox("You do not have enough funds.", 255, 0, 0)
		elseif reason == "" then
			outputChatBox("Please enter a reason for the Transfer!", 255, 0, 0)
		elseif playername == "" then
			outputChatBox("Please enter the full character name of the reciever!", 255, 0, 0)
		else
			triggerServerEvent("transferMoneyToPersonal", localPlayer, gFactionID, playername, amount, reason )
			guiSetText(tTransferB, "0")
			guiSetText(tTransferBReason, "")
			guiSetText(eTransferB, "")
		end
	end
end

function getTransactionReason(type, reason, from)
	if type == 0 or type == 4 then
		return "Withdraw"
	elseif type == 1 or type == 5 then
		return "Deposit"
	elseif type == 6 then
		return tostring(reason or "")
	elseif type == 7 then
		return "Payday (Biz+Interest+Donator)"
	elseif type == 8 then
		return "Budget"
	elseif type == 9 then
		outputDebugString(tostring(reason) .. " " .. tostring(type))
		return tostring("Fuel: "..math.ceil(tonumber(reason)).."L")
	elseif type == 10 then
		return "Repair"
	else
		return "Transfer: " .. tostring(reason or "")
	end
end

function recieveTransfer(grid,  id, amount, time, type, from, to, reason, details, fID)
	if tonumber(fID) and fID < 0 then
		gFactionID = -fID
	end

	local row = guiGridListAddRow(grid)
	guiGridListSetItemText(grid, row, 1, tostring(id), false, true)
	guiGridListSetItemText(grid, row, 2, from, false, false)
	guiGridListSetItemText(grid, row, 3, to, false, false)
	if amount < 0 then
		guiGridListSetItemText(grid, row, 4, "-$"..exports.global:formatMoney(math.abs(amount)), false, true)
		guiGridListSetItemColor(grid, row, 4, 255, 127, 127)
	else
		guiGridListSetItemText(grid, row, 4, "$"..exports.global:formatMoney(amount), false, true)
		guiGridListSetItemColor(grid, row, 4, 127, 255, 127)
	end
	guiGridListSetItemText(grid, row, 5, time, false, false)
	guiGridListSetItemText(grid, row, 6, " " .. getTransactionReason(type, reason, from), false, false)
	guiGridListSetItemText(grid, row, 7, " " .. details, false, false)
end

function recievePersonalTransfer(...)
	recieveTransfer(gPersonalTransactions, ...)
end

addEvent("recievePersonalTransfer", true)
addEventHandler("recievePersonalTransfer", localPlayer, recievePersonalTransfer)

function recieveBusinessTransfer(...)
	recieveTransfer(gBusinessTransactions, ...)
end

addEvent("recieveBusinessTransfer", true)
addEventHandler("recieveBusinessTransfer", localPlayer, recieveBusinessTransfer)

function checkDataChange(dn)
	if wBank then
		if dn == "bankmoney" and source == localPlayer then
			guiSetText(lBalance, "Balance: $" .. exports.global:formatMoney(getElementData(source, "bankmoney")))
		elseif dn == "money" and gFactionID == getElementData(source, "id") then
			gfactionBalance = getElementData(source, "money")
			guiSetText(lBalanceB, "Balance: $" .. exports.global:formatMoney(gfactionBalance))
		end
	end
end
addEventHandler("onClientElementDataChange", getRootElement(), checkDataChange)

local thisResourceElement = getResourceRootElement(getThisResource())
function cleanUp()
	setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
end
addEventHandler("onClientResourceStart", thisResourceElement, cleanUp)

function fadeOut()
	fadeCamera ( true, 1, 0, 0, 0 )
end
addEvent("bank:fadeOut", true)
addEventHandler("bank:fadeOut", localPlayer, fadeOut)

function isCameraOnPlayer()
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if vehicle then
		return getCameraTarget( ) == vehicle
	else
		return getCameraTarget( ) == getLocalPlayer()
	end
end

function hasBankMoney(thePlayer, amount)
	amount = tonumber(amount)
	amount = math.floor(math.abs(amount))
	return getElementData(thePlayer, "bankmoney") >= amount
end
