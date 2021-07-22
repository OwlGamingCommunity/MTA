-- by tree (anumaz) on the 2th of june 2015
-- client-side script for the investment system

-- Rewriting the function 'guiSetVisible' and 'guiEditSetReadOnly' to allow tables instead of individual elements
_guiSetVisible = guiSetVisible 
function guiSetVisible(table, bool)
	if type(table) == "table" then
		for _, gui in pairs(table) do
			if isElement(gui) then
				_guiSetVisible(gui, bool)
			end
		end
	elseif isElement(table) then
		_guiSetVisible(table, bool)
	end
end

_guiEditSetReadOnly = guiEditSetReadOnly 
function guiEditSetReadOnly(table, bool)
	if type(table) == "table" then
		for _, gui in pairs(table) do
			if isElement(gui) then
				_guiEditSetReadOnly(gui, bool)
			end
		end
	elseif isElement(table) then
		_guiEditSetReadOnly(table, bool)
	end
end

-- GUIs

-- Management GUI
manage = {
    edit = {},
    button = {},
    window = {},
    label = {},
    combobox = {}
}
function manageGUI(investment)
	-- to disable double windows
	if isElement(manage.window[1]) then return false end
		
	-- in case the table is poorly transfered from server
	if not type(investment) == "table" then outputChatBox("An error occured. Please report this bug with ID: INV#001", 255, 0, 0) end

	-- disable binds
	guiSetInputMode("no_binds_when_editing")

	manage.window[1] = guiCreateWindow(528, 264, 581, 510, "Investplace Management", false)
	guiWindowSetSizable(manage.window[1], false)
	exports.global:centerWindow(manage.window[1])
	setElementData(getLocalPlayer(), "exclusiveGUI", true, false)

	manage.label[1] = guiCreateLabel(0.02, 0.05, 0.97, 0.04, "This management panel serves as sole purpose to manage the investment market.", true, manage.window[1])
	manage.label[2] = guiCreateLabel(0.02, 0.14, 0.57, 0.04, "1. Please either create a new or select an existant company", true, manage.window[1])
	manage.combobox[1] = guiCreateComboBox(0.05, 0.19, 0.48, 0.33, "", true, manage.window[1])
	manage.button[1] = guiCreateButton(0.58, 0.19, 0.37, 0.04, "Create new", true, manage.window[1])
	manage.label[3] = guiCreateLabel(0.02, 0.27, 0.93, 0.04, "2. Please modify the values you wish to edit", true, manage.window[1])
	manage.label[4] = guiCreateLabel(0.04, 0.35, 0.22, 0.06, "Company name", true, manage.window[1])
	manage.label[5] = guiCreateLabel(0.04, 0.40, 0.22, 0.06, "Description", true, manage.window[1])
	manage.label[6] = guiCreateLabel(0.04, 0.46, 0.22, 0.06, "Maximum shares", true, manage.window[1])
	manage.label[7] = guiCreateLabel(0.04, 0.52, 0.22, 0.06, "Price per share", true, manage.window[1])
	manage.label[8] = guiCreateLabel(0.04, 0.58, 0.24, 0.06, "Current value", true, manage.window[1])
	manage.label[12] = guiCreateLabel(0.04, 0.64, 0.24, 0.06, "Risk", true, manage.window[1])
	manage.edit[1] = guiCreateEdit(0.32, 0.35, 0.29, 0.06, "", true, manage.window[1])
	manage.edit[2] = guiCreateEdit(0.32, 0.41, 0.29, 0.06, "", true, manage.window[1])
	manage.edit[3] = guiCreateEdit(0.32, 0.47, 0.29, 0.06, "", true, manage.window[1])
	manage.edit[4] = guiCreateEdit(0.32, 0.53, 0.29, 0.06, "", true, manage.window[1])
	manage.edit[5] = guiCreateEdit(0.32, 0.59, 0.29, 0.06, "", true, manage.window[1])
	manage.edit[6] = guiCreateEdit(0.32, 0.65, 0.29, 0.06, "", true, manage.window[1])
	manage.label[9] = guiCreateLabel(0.63, 0.46, 0.34, 0.06, "*The maximum amount of shares you can buy.", true, manage.window[1])
	guiLabelSetHorizontalAlign(manage.label[9], "left", true)
	manage.label[10] = guiCreateLabel(0.63, 0.58, 0.34, 0.20, "*If you increase this, investors will likely get a render. If you decrease, they will have a loss. When this is at it's lowest, it is the perfect time to invest. Whilst it's at the highest, it's a perfect time to withdraw the shares.", true, manage.window[1])
	guiLabelSetHorizontalAlign(manage.label[10], "left", true)
	manage.label[11] = guiCreateLabel(0.02, 0.79, 0.93, 0.04, "3. Please select the right option", true, manage.window[1])
	manage.button[2] = guiCreateButton(0.03, 0.87, 0.20, 0.08, "Save/Add", true, manage.window[1])
	manage.button[3] = guiCreateButton(0.26, 0.87, 0.20, 0.08, "Delete", true, manage.window[1])
	manage.button[4] = guiCreateButton(0.49, 0.87, 0.48, 0.08, "Close", true, manage.window[1])

	-- disabling the delete button
	guiSetVisible(manage.button[3], false)

	-- to fill in the combobox
	for companies,_ in pairs(investment) do 
		guiComboBoxAddItem(manage.combobox[1], companies)
	end

	-- you either need to click 'Create new' or select something in combobox to be able to type into editboxes
	guiEditSetReadOnly(manage.edit, true)

	--close button
	addEventHandler("onClientGUIClick", manage.button[4], function ()
		destroyElement(manage.window[1])
		guiSetInputMode("allow_binds")
		setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
	end, false)

	--'Create new' button unlocks the editfields
	addEventHandler("onClientGUIClick", manage.button[1], function ()
		guiComboBoxSetSelected(manage.combobox[1], -1) -- just to make sure he does not edit and add something at the same time
		guiEditSetReadOnly(manage.edit, false) -- unlocking the previously locked edit fields

		-- emptying edit fields if there was anything
		guiSetText(manage.edit[1], "")
		guiSetText(manage.edit[2], "")
		guiSetText(manage.edit[3], "")
		guiSetText(manage.edit[4], "")
		guiSetText(manage.edit[5], "")
		guiSetText(manage.edit[6], "")

		-- disabling delete button
		guiSetVisible(manage.button[3], false)
	end, false)

	-- When selecting something in combobox list
	addEventHandler("onClientGUIComboBoxAccepted", manage.combobox[1], function ()
		guiEditSetReadOnly(manage.edit, false) -- unlocking the previously locked edit fields
		local i = guiComboBoxGetSelected(manage.combobox[1])
		local companyname = guiComboBoxGetItemText(manage.combobox[1], i)
		guiSetText(manage.edit[1], companyname)
		guiSetText(manage.edit[2], investment[companyname]["description"])
		guiSetText(manage.edit[3], investment[companyname]["maximumshare"])
		guiSetText(manage.edit[4], investment[companyname]["pricepershare"])
		guiSetText(manage.edit[5], investment[companyname]["value"])
		guiSetText(manage.edit[6], investment[companyname]["risk"])

		-- company name can't be changed, this is the primary key for sql 
		guiEditSetReadOnly(manage.edit[1], true)

		-- enabling Delete option
		guiSetVisible(manage.button[3], true)
	end)

	-- 'Save/add' button
	addEventHandler("onClientGUIClick", manage.button[2], function ()
		local newItem = true
		local item = guiComboBoxGetSelected(manage.combobox[1])
		if item>=0 then newItem = false end -- if there is something selected, then its an edit. Otherwise, its a new item.

		local temporaryTable = {}		
		temporaryTable.companyname = guiGetText(manage.edit[1])
		temporaryTable.description = guiGetText(manage.edit[2])
		temporaryTable.maximumshare = tonumber(guiGetText(manage.edit[3]))
		temporaryTable.pricepershare = tonumber(guiGetText(manage.edit[4]))
		temporaryTable.value = tonumber(guiGetText(manage.edit[5]))
		temporaryTable.risk = guiGetText(manage.edit[6])

		if not temporaryTable.companyname or not temporaryTable.description or not temporaryTable.risk or not tonumber(temporaryTable.maximumshare) or not tonumber(temporaryTable.pricepershare) or not tonumber(temporaryTable.value) then
			outputChatBox("Something went wrong. Please contact a scripter,  BUG : INV#002", 255, 0, 0)
		else
			if newItem then -- if it's a new company
				triggerServerEvent("invest:addedit", resourceRoot, getLocalPlayer(), temporaryTable, true) -- the 'true' as last argument notifies server-side that it is a new item, not an edit.
				destroyElement(manage.window[1])
				guiSetInputMode("allow_binds")
			else -- if it's an edit to an actual company
				triggerServerEvent("invest:addedit", resourceRoot, getLocalPlayer(), temporaryTable, false) -- the 'false' means that its an edit, not an addition
				destroyElement(manage.window[1])
				guiSetInputMode("allow_binds")
			end
		end
	end, false)

	-- the delete button
	addEventHandler("onClientGUIClick", manage.button[3], function ()
		local item = guiComboBoxGetSelected(manage.combobox[1])
		local companyname = guiComboBoxGetItemText(manage.combobox[1], item)
		guiSetInputMode("allow_binds")
		destroyElement(manage.window[1])
		triggerServerEvent("invest:delete", resourceRoot, getLocalPlayer(), companyname)
	end, false)
end
addEvent("invest:manage_gui", true)
addEventHandler("invest:manage_gui", resourceRoot, manageGUI)

-- Investors GUI
investor = {
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {},
    description = {},
    close = {}
}
function investorGUI(investment, shares)
	-- to disable double windows
	if isElement(investor.window[1]) then return false end

	-- in case the table is poorly transfered from server
	if not type(investment) == "table" then outputChatBox("An error occured. Please report this bug with ID: INV#001", 255, 0, 0) end
	if not type(shares) == "table" then outputChatBox("An error occured. Please report this bug with ID: INV#012", 255, 0, 0) end

	-- disable binds
	guiSetInputMode("no_binds_when_editing")
	setElementData(getLocalPlayer(), "exclusiveGUI", true, false)
	addEventHandler ( "account:changingchar", getRootElement(), eventCloseGUI)

	investor.window[1] = guiCreateWindow(349, 288, 799, 434, "https://www.investplace.net - InvestPlace: The opportunity to get richer", false)
	guiWindowSetSizable(investor.window[1], false)
	guiSetAlpha(investor.window[1], 0.97)
	exports.global:centerWindow(investor.window[1])

	investor.label[1] = guiCreateLabel(0.01, 0.06, 0.84, 0.08, "Welcome to the InvestPlace. This interface allows you to consult or manage your current shares. As an investor, we thank you to use our service. InvestPlace gathers a lot of companies in which you can invest. Let the opportunities rise!", true, investor.window[1])
	guiLabelSetHorizontalAlign(investor.label[1], "left", true)
	investor.gridlist[1] = guiCreateGridList(0.01, 0.16, 0.98, 0.34, true, investor.window[1])
	guiGridListAddColumn(investor.gridlist[1], "Name", 0.2)
	guiGridListAddColumn(investor.gridlist[1], "Description", 0.3)
	guiGridListAddColumn(investor.gridlist[1], "PPS", 0.1)
	guiGridListAddColumn(investor.gridlist[1], "MS", 0.1)
	guiGridListAddColumn(investor.gridlist[1], "Current value", 0.1)
	guiGridListAddColumn(investor.gridlist[1], "Risk indicator", 0.1)
	investor.label[2] = guiCreateLabel(0.60, 0.51, 0.38, 0.05, "*Historical graph and average is not yet available. Check forums.", true, investor.window[1])
	guiSetFont(investor.label[2], "default-small")
	investor.description[3] = guiCreateLabel(0.02, 0.57, 0.47, 0.06, "%companyname%", true, investor.window[1])
	guiSetFont(investor.description[3], "default-bold-small")
	investor.description[4] = guiCreateLabel(0.02, 0.62, 0.47, 0.11, "%description%", true, investor.window[1])
	guiLabelSetHorizontalAlign(investor.description[4], "left", true)
	investor.description[5] = guiCreateLabel(0.02, 0.73, 0.47, 0.06, "Price per share: %pricepershare%$", true, investor.window[1])
	guiLabelSetHorizontalAlign(investor.description[5], "left", true)
	investor.description[6] = guiCreateLabel(0.02, 0.79, 0.47, 0.06, "Maximum shares: %maximumshares%", true, investor.window[1])
	guiLabelSetHorizontalAlign(investor.description[6], "left", true)
	investor.description[7] = guiCreateLabel(0.02, 0.84, 0.47, 0.06, "Current value: %currentvalue%%", true, investor.window[1])
	guiLabelSetHorizontalAlign(investor.description[7], "left", true)
	investor.description[8] = guiCreateLabel(0.02, 0.90, 0.47, 0.06, "Risk: %averagerender%", true, investor.window[1])
	guiLabelSetHorizontalAlign(investor.description[8], "left", true)
	investor.label[9] = guiCreateLabel(0.49, 0.58, 0.28, 0.05, "1. What you possess:", true, investor.window[1])
	guiSetFont(investor.label[9], "default-bold-small")
	investor.label[10] = guiCreateLabel(0.49, 0.63, 0.22, 0.05, "Amount of shares: ", true, investor.window[1])
	investor.label[11] = guiCreateLabel(0.74, 0.63, 0.22, 0.05, "Total invested: ", true, investor.window[1])
	investor.label[12] = guiCreateLabel(0.49, 0.68, 0.28, 0.05, "2. You can invest:", true, investor.window[1])
	guiSetFont(investor.label[12], "default-bold-small")
	investor.label[13] = guiCreateLabel(0.49, 0.74, 0.37, 0.05, "Please insert the amount of shares you want to buy:", true, investor.window[1])
	investor.edit[1] = guiCreateEdit(0.87, 0.72, 0.11, 0.06, "", true, investor.window[1])
	investor.button[1] = guiCreateButton(0.87, 0.78, 0.11, 0.06, "Invest", true, investor.window[1])
	investor.label[14] = guiCreateLabel(0.49, 0.85, 0.28, 0.05, "3. You can withdraw:", true, investor.window[1])
	guiSetFont(investor.label[14], "default-bold-small")
	investor.label[15] = guiCreateLabel(0.49, 0.90, 0.37, 0.08, "By withdrawing, you'll get money based on current share values. Enter amount of shares to sell.", true, investor.window[1])
	guiLabelSetHorizontalAlign(investor.label[15], "left", true)
	investor.edit[2] = guiCreateEdit(0.87, 0.86, 0.11, 0.06, "", true, investor.window[1])
	investor.button[2] = guiCreateButton(0.87, 0.92, 0.11, 0.06, "Sell", true, investor.window[1])
	investor.close[3] = guiCreateButton(0.87, 0.06, 0.11, 0.08, "Close", true, investor.window[1])

	local charactername = string.gsub(getPlayerName(getLocalPlayer()), "_", " ")
	local companyname = ""

	-- filling the gridlist
	for k, v in pairs(investment) do
		local row = guiGridListAddRow(investor.gridlist[1])
		guiGridListSetItemText(investor.gridlist[1], row, 1, k, false, false)
		guiGridListSetItemText(investor.gridlist[1], row, 2, v["description"], false, false)
		guiGridListSetItemText(investor.gridlist[1], row, 3, v["pricepershare"], false, false)
		guiGridListSetItemText(investor.gridlist[1], row, 4, v["maximumshare"], false, false)
		guiGridListSetItemText(investor.gridlist[1], row, 5, v["value"], false, false)
		guiGridListSetItemText(investor.gridlist[1], row, 6, v["risk"], false, false)
	end	

	-- those are only visible if you select an item in the gridlist
	guiSetVisible(investor.description, false)
	guiSetVisible(investor.button, false)
	-- you can only input if you select an item in gridlist
	guiEditSetReadOnly(investor.edit, true)

	--close button
	addEventHandler("onClientGUIClick", investor.close[3], function ()
		destroyElement(investor.window[1])
		guiSetInputMode("allow_binds")
		setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
		removeEventHandler("account:changingchar", getRootElement(), eventCloseGUI)
	end, false)	

	-- selecting an item in gridlist
	addEventHandler("onClientGUIClick", investor.gridlist[1], function ()
			local rindex, cindex = guiGridListGetSelectedItem(investor.gridlist[1])
			if rindex>=0 then
				companyname = guiGridListGetItemText(investor.gridlist[1], rindex, 1)

				-- giving the details of the company
				guiSetText(investor.description[3], companyname)	
				guiSetText(investor.description[4], investment[companyname]["description"])	
				guiSetText(investor.description[5], "Price per share: "..investment[companyname]["pricepershare"].."$")	
				guiSetText(investor.description[6], "Maximum shares: "..investment[companyname]["maximumshare"])	
				guiSetText(investor.description[7], "Current value: "..investment[companyname]["value"].."%")	
				guiSetText(investor.description[8], "Risk: "..investment[companyname]["risk"])	

				-- if you have shares with the selected company, or not
				if shares[charactername] then
					if shares[charactername][companyname] then
						guiSetText(investor.label[10], "Amount of shares: "..shares[charactername][companyname]["amountofshares"])
						guiSetText(investor.label[11], "Total invested: "..shares[charactername][companyname]["totalinvested"].."$")
					else
						guiSetText(investor.label[10], "Amount of shares: 0")
						guiSetText(investor.label[11], "Total invested: 0$")	
					end
				else
					guiSetText(investor.label[10], "Amount of shares: 0")
					guiSetText(investor.label[11], "Total invested: 0$")	
				end

				-- enabling the buttons and labels
				guiSetVisible(investor.description, true)
				guiSetVisible(investor.button, true)
				guiEditSetReadOnly(investor.edit, false)

				--Investing and selling
				-- investing!

			else
				-- those are only visible if you select an item in the gridlist
				guiSetVisible(investor.description, false)
				guiSetVisible(investor.button, false)
				-- you can only input if you select an item in gridlist
				guiEditSetReadOnly(investor.edit, true)

				guiSetText(investor.label[10], "Amount of shares: ")
				guiSetText(investor.label[11], "Total invested: ")				
			end		
	end, false)		

	addEventHandler("onClientGUIClick", investor.button[1], function ()
		local currentShares = 0
		if shares[charactername] then
			if shares[charactername][companyname] then
				currentShares = tonumber(shares[charactername][companyname]["amountofshares"]) or 0
			end
		end
		local maximumShares = tonumber(investment[companyname]["maximumshare"])
		local buyableShares = maximumShares - currentShares

		local errors = false

		-- if tries to buy more than allowed or didn't type anything or wrote any other character than numbers
		local want_to_buy = math.floor(tonumber(guiGetText(investor.edit[1])))
		if not tonumber(want_to_buy) or tonumber(want_to_buy) == 0 or tonumber(want_to_buy) < 0 then 
			outputChatBox("You may only input numbers. They must be positive.")
			errors = true
			return
		end
		if tonumber(want_to_buy) > tonumber(buyableShares) then 
			errors = true
			outputChatBox("You may only buy up to "..buyableShares.." shares.") 
			return
		end

		-- if has enough money
		local amount = tonumber(want_to_buy) * tonumber(investment[companyname]["pricepershare"])
		local enoughmoney = exports.bank:hasBankMoney(getLocalPlayer(), amount)
		if not enoughmoney then
			outputChatBox("You may not afford "..amount.."$. Please reduce the shares amount.")
			errors = true
			return
		end

		if not errors then triggerServerEvent("invest:buy", resourceRoot, getLocalPlayer(), companyname, tonumber(want_to_buy)) end

		destroyElement(investor.window[1])
		guiSetInputMode("allow_binds")
	end, false)

	addEventHandler("onClientGUIClick", investor.button[2], function ()
		local amount = 0

		if shares[charactername] then 
			if shares[charactername][companyname] then
				amount = tonumber(shares[charactername][companyname]["amountofshares"])
				local errors = false
				local amount_to_sell = math.floor(tonumber(guiGetText(investor.edit[2])))

				if not tonumber(amount_to_sell) or tonumber(amount_to_sell) == 0 or tonumber(amount_to_sell) < 0 then 
					outputChatBox("You may only input numbers. They must be positive.")
					errors = true
					return
				end
				if tonumber(amount_to_sell) > tonumber(amount) then 
					errors = true
					outputChatBox("You may only sell up to "..amount.." shares.") 
					return
				end

				if amount and amount > 0 and not errors then
					destroyElement(investor.window[1])
					guiSetInputMode("allow_binds")

					triggerServerEvent("invest:sell", resourceRoot, getLocalPlayer(), companyname, tonumber(amount_to_sell))					
				end
			end
		end

		if amount == 0 then
			outputChatBox("You do not have any shares to sell in "..companyname)
			return
		end
	end, false)
end
addEvent("invest:investor_gui", true)
addEventHandler("invest:investor_gui", resourceRoot, investorGUI)

function eventCloseGUI()
	if investor.window[1] then
		destroyElement(investor.window[1])
		guiSetInputMode("allow_binds")
		setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
		removeEventHandler("account:changingchar", getRootElement(), eventCloseGUI)
	end
end