-- by tree (anumaz) on the 2th of june 2015
-- server-side script for the investment system

--[[ sql table;

CREATE TABLE `owl_mta`.`invest` (
  `companyname` TINYTEXT NOT NULL,
  `description` MEDIUMTEXT NULL,
  `pricepershare` INT NOT NULL DEFAULT 0,
  `maximumshare` INT NOT NULL DEFAULT 500,
  `value` FLOAT NOT NULL,
  `risk` TINYTEXT NOT NULL);

  CREATE TABLE `owl_mta`.`invest_shares` (
  `charactername` TINYTEXT NOT NULL,
  `companyname` TINYTEXT NOT NULL,
  `amountofshares` INT NOT NULL,
  `totalinvested` INT NOT NULL);

]]

-- large table containing all investment info
local investment = {}
local shares = {}

-- to cache data
addEventHandler("onResourceStart", getResourceRootElement(), function ()
	local result = exports.mysql:query( "SELECT * FROM `invest`" )
	while result do
		local row = exports.mysql:fetch_assoc( result )
		if not row then
			break
		end
		investment[tostring(row.companyname)] = row
	end
	exports.mysql:free_result( result )

	local result = exports.mysql:query( "SELECT * FROM `invest_shares`" )
	while result do
		local row = exports.mysql:fetch_assoc( result )
		if not row then
			break
		end
		if not shares[tostring(row.charactername)] then shares[tostring(row.charactername)] = {} end
		shares[tostring(row.charactername)][row.companyname] = row
	end
	exports.mysql:free_result( result )
end)

-- This is a small table of whom are able to manage the investplace. This is hardcoded rather than 'isLeadAdmin..blabla' purely to avoid any conflicts/abuse from other staff members at the same rank.
local allowedManagers = {
	-- All heads anyways
}

function canManage(player)
	return allowedManagers[tostring(getElementData(player, "account:username"))] or exports.integration:isPlayerHeadAdmin(player) or false
end

-- Event to open the investor's page
function triggerGUI(p)
	triggerClientEvent(p, "invest:investor_gui", resourceRoot, investment, shares)
end
addEvent("invest:open", true)
addEventHandler("invest:open", root, triggerGUI)

-- Command to open the management GUI
addCommandHandler("manageinvest", function(p)
	local accountName = getElementData(p, "account:username")
	if canManage(p) then
		triggerClientEvent(p, "invest:manage_gui", resourceRoot, investment)
	end
end)

-- To either INSERT INTO or UPDATE sql, as well as adding to the cache table
function addOrSave(player, data, new)
	if type(data) == "table" and isElement(player) then
		if new then
			-- sql query
			local sql_result = exports.mysql:query_free("INSERT INTO `invest` SET `companyname`='"..exports.mysql:escape_string(data.companyname).."', `description`='"..exports.mysql:escape_string(data.description).."', `pricepershare`="..exports.mysql:escape_string(data.pricepershare)..", `maximumshare`="..exports.mysql:escape_string(data.maximumshare)..", `value`="..exports.mysql:escape_string(data.value)..", `risk`='"..exports.mysql:escape_string(data.risk).."'")

			-- adding to cached table
			investment[tostring(data.companyname)] = {}
			investment[tostring(data.companyname)]["companyname"] = data.companyname
			investment[tostring(data.companyname)]["description"] = data.description
			investment[tostring(data.companyname)]["pricepershare"] = tonumber(data.pricepershare)
			investment[tostring(data.companyname)]["maximumshare"] = tonumber(data.maximumshare)
			investment[tostring(data.companyname)]["value"] = tonumber(data.value)
			investment[tostring(data.companyname)]["risk"] = data.risk

			-- checking if the table adding actually worked
			local table_result = false
			if type(investment[tostring(data.companyname)]) == "table" then table_result = true end

			if not sql_result or not table_result then
				outputChatBox("An error occured whilst adding a new company. BUG: INV#003", player, 255, 0, 0)
			else
				outputChatBox("You have succesfully added "..data.companyname.."!", player, 0, 255, 0)
				triggerClientEvent(player, "invest:manage_gui", resourceRoot, investment)
			end
		else
			-- sql query
			local sql_result = exports.mysql:query_free("UPDATE `invest` SET `description`='"..exports.mysql:escape_string(data.description).."', `pricepershare`="..exports.mysql:escape_string(data.pricepershare)..", `maximumshare`="..exports.mysql:escape_string(data.maximumshare)..", `value`="..exports.mysql:escape_string(data.value)..", `risk`='"..exports.mysql:escape_string(data.risk).."' WHERE companyname='"..exports.mysql:escape_string(data.companyname).."'")

			if sql_result and investment[data.companyname] then
				outputChatBox("You have succesfully edited "..data.companyname.."!", player, 0, 255, 0)

				investment[tostring(data.companyname)]["description"] = data.description
				investment[tostring(data.companyname)]["pricepershare"] = tonumber(data.pricepershare)
				investment[tostring(data.companyname)]["maximumshare"] = tonumber(data.maximumshare)
				investment[tostring(data.companyname)]["value"] = tonumber(data.value)
				investment[tostring(data.companyname)]["risk"] = data.risk

				triggerClientEvent(player, "invest:manage_gui", resourceRoot, investment)
			else
				outputChatBox("An error occured! Contact a scripter with bug INV#006", player, 255, 0, 0)
			end
		end
	end
end
addEvent("invest:addedit", true)
addEventHandler("invest:addedit", resourceRoot, addOrSave)

function deleteCompany(player, companyname)
	if isElement(player) and tostring(companyname) then
		-- sql query
		local sql_result = exports.mysql:query_free("DELETE FROM `invest` WHERE companyname='"..exports.mysql:escape_string(companyname).."'")

		-- cached table removal
		investment[companyname] = nil

		if sql_result and not investment[companyname] then
			outputChatBox("You have deleted "..companyname, player, 0, 255, 0)
			triggerClientEvent(player, "invest:manage_gui", resourceRoot, investment)
		else
			outputChatBox("An error has occured, report bug: INV#010", player, 255, 0, 0)
		end
	else
		outputChatBox("An error has occured, report bug: INV#009", player, 255, 0, 0)
	end
end
addEvent("invest:delete", true)
addEventHandler("invest:delete", resourceRoot, deleteCompany)

function buyShares(player, companyname, amount)
	amount = tonumber(amount)
	if isElement(player) and investment[companyname] and amount then
		local pricepershare = tonumber(investment[companyname]["pricepershare"])

		-- if somehow pricepershare does not exist
		if not pricepershare then outputChatBox("An error has occured, report bug: INV#013", player, 255, 0, 0) return end


		local playername = string.gsub(getPlayerName(player), "_", " ")

		-- if already has shares (sql and cache)
		if shares[playername] then
			if shares[playername][companyname] then
				shares[playername][companyname]["amountofshares"] = shares[playername][companyname]["amountofshares"] + amount
				shares[playername][companyname]["totalinvested"] = shares[playername][companyname]["totalinvested"] + ( amount*pricepershare )

				local sql_result = exports.mysql:query_free("UPDATE `invest_shares` SET `amountofshares`=amountofshares+"..exports.mysql:escape_string(amount)..", `totalinvested`=totalinvested+"..exports.mysql:escape_string(amount*pricepershare).." WHERE companyname='"..exports.mysql:escape_string(companyname).."' AND charactername='"..exports.mysql:escape_string(playername).."'")
				if not sql_result then
					outputChatBox("An error has occured, report bug: INV#015", player, 255, 0, 0)
				else
					local r = exports.bank:takeBankMoney(player, amount*pricepershare)
					if r then
						outputChatBox("You have succesfully invested "..amount.." shares ("..amount*pricepershare.."$) in "..companyname, player, 0, 255, 0)
						exports.bank:addBankTransactionLog(getElementData(player, "dbid"), nil , amount*pricepershare, 0, "Investment into "..companyname.." - InvestPlace" )
					else
						outputChatBox("An error has occured, report bug: INV#014", player, 255, 0, 0)
					end
				end
				triggerClientEvent(player, "invest:investor_gui", resourceRoot, investment, shares)
			else
				-- setting the table and cache
				if not shares[playername][companyname] then shares[playername][companyname] = {} end
				shares[playername][companyname]["amountofshares"] = amount
				shares[playername][companyname]["totalinvested"] = amount*pricepershare
				shares[playername][companyname]["companyname"] = companyname
				shares[playername][companyname]["charactername"] = playername

				--doing the sql
				local sql_result = exports.mysql:query_free("INSERT INTO `invest_shares` SET `charactername`='"..exports.mysql:escape_string(playername).."', `companyname`='"..exports.mysql:escape_string(companyname).."', `amountofshares`="..exports.mysql:escape_string(amount)..", `totalinvested`="..exports.mysql:escape_string(amount*pricepershare))

				if not sql_result then
					outputChatBox("An error has occured, report bug: INV#020", player, 255, 0, 0)
				else
					local r = exports.bank:takeBankMoney(player, amount*pricepershare)
					if r then
						outputChatBox("You have succesfully invested "..amount.." shares ("..amount*pricepershare.."$) in "..companyname, player, 0, 255, 0)
						exports.bank:addBankTransactionLog(getElementData(player, "dbid"), nil , amount*pricepershare, 0, "Investment into "..companyname.." - InvestPlace" )
					else
						outputChatBox("An error has occured, report bug: INV#021", player, 255, 0, 0)
					end
				end
				triggerClientEvent(player, "invest:investor_gui", resourceRoot, investment, shares)
			end
		else -- if player does not have shares
			-- setting the table and cache
			if not shares[playername] then shares[playername] = {} end
			if not shares[playername][companyname] then shares[playername][companyname] = {} end
			shares[playername][companyname]["amountofshares"] = amount
			shares[playername][companyname]["totalinvested"] = amount*pricepershare
			shares[playername][companyname]["companyname"] = companyname
			shares[playername][companyname]["charactername"] = playername

			--doing the sql
			local sql_result = exports.mysql:query_free("INSERT INTO `invest_shares` SET `charactername`='"..exports.mysql:escape_string(playername).."', `companyname`='"..exports.mysql:escape_string(companyname).."', `amountofshares`="..exports.mysql:escape_string(amount)..", `totalinvested`="..exports.mysql:escape_string(amount*pricepershare))

			if not sql_result then
				outputChatBox("An error has occured, report bug: INV#016", player, 255, 0, 0)
			else
				local r = exports.bank:takeBankMoney(player, amount*pricepershare)
				if r then
					outputChatBox("You have succesfully invested "..amount.." shares ("..amount*pricepershare.."$) in "..companyname, player, 0, 255, 0)
					exports.bank:addBankTransactionLog(getElementData(player, "dbid"), nil , amount*pricepershare, 0, "Investment into "..companyname.." - InvestPlace" )
				else
					outputChatBox("An error has occured, report bug: INV#014", player, 255, 0, 0)
				end
			end
			triggerClientEvent(player, "invest:investor_gui", resourceRoot, investment, shares)
		end
	end
end
addEvent("invest:buy", true)
addEventHandler("invest:buy", resourceRoot, buyShares)

function sellShares(player, companyname, amount)
	amount = tonumber(amount)
	if isElement(player) and investment[companyname] and amount then
		local playername = string.gsub(getPlayerName(player), "_", " ")

		local payAmount = amount * tonumber(investment[companyname]["pricepershare"])

		--removing shares from cached table
		shares[playername][companyname]["amountofshares"] = tonumber(shares[playername][companyname]["amountofshares"]) - amount
		shares[playername][companyname]["totalinvested"] = tonumber(shares[playername][companyname]["totalinvested"]) - payAmount

		--doing the sql
		local sql_result = exports.mysql:query_free("UPDATE `invest_shares` SET `amountofshares`=amountofshares-"..exports.mysql:escape_string(amount)..", `totalinvested`=totalinvested-"..exports.mysql:escape_string(payAmount).." WHERE companyname='"..(companyname).."' AND charactername='"..exports.mysql:escape_string(playername).."'")
		if not sql_result then
			outputChatBox("An error has occured, report bug: INV#018", player, 255, 0, 0)
		else
			outputChatBox("You have succesfully sold "..amount.." shares ("..payAmount.."$) from "..companyname, player, 0, 255, 0)
			exports.bank:giveBankMoney(player, payAmount)
			exports.bank:addBankTransactionLog(nil, getElementData(player, "dbid") , payAmount, 1, "Investment sold for "..companyname.." - InvestPlace" )
		end
		triggerClientEvent(player, "invest:investor_gui", resourceRoot, investment, shares)
	else
		outputChatBox("An error has occured, report bug: INV#017", player, 255, 0, 0)
	end
end
addEvent("invest:sell", true)
addEventHandler("invest:sell", resourceRoot, sellShares)
