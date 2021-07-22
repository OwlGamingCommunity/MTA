addEvent("duty:request", true)
function dutyRequest(grantID, itemTable, skinID, factionID)
	local thePlayer = client

	-- Fetch the factionPackage
	local foundPackage = getGrant(thePlayer, grantID, factionID)

	if foundPackage and canPlayerUseDutyPackage(thePlayer, foundPackage[1], factionID) then
		-- We've got an auth for the package

		-- Now we check the contents
		for itemIndexID, itemTableContent in ipairs(itemTable) do
			local found = false

			for aItemIndexID, aItemTableContent in pairs(foundPackage[5]) do
				if aItemTableContent[1] == itemTableContent[1] then
					found = true
					break
				end
			end

			if not found then
				outputChatBox("Error.", thePlayer)
				return false
			end
		end

		for itemIndexID, itemTableContent in ipairs(itemTable) do
			if itemTableContent[2] > 0 then -- its a real item
				exports.global:giveItem(thePlayer, itemTableContent[2], itemTableContent[3])
			else -- Its a weapon :O!
				if itemTableContent[2] == -100 then
					setPedArmor(thePlayer, itemTableContent[3])
				else
					local gtaWeaponID = tonumber(itemTableContent[2]) - tonumber(itemTableContent[2]) - tonumber(itemTableContent[2])
					local weaponSerial = exports.global:createWeaponSerial(2, getElementData(thePlayer, "dbid"))
					exports.global:giveItem(thePlayer, 115, gtaWeaponID ..":".. weaponSerial ..":" .. getWeaponNameFromID ( gtaWeaponID ) .. " (D):"..(tonumber(itemTableContent[3])+1)  )
				end
			end
		end

		savedSkin = 0
		savedClothing = 0
		if skinID and type(skinID) == 'string' then
			local skinData = split(skinID, ':')
			savedSkin = tonumber(skinData[1])
			setElementModel(thePlayer, savedSkin)
			if #skinData > 1 then
				savedClothing = tonumber(skinData[2])
				setElementData(thePlayer, 'clothing:id', savedClothing)
			else
				setElementData(thePlayer, 'clothing:id', nil)
			end
		end

		triggerClientEvent(thePlayer, "onPlayerDuty", thePlayer, true)
		triggerEvent("onPlayerDuty", thePlayer, true)
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "duty", grantID, true)
		exports.mysql:query_free( "UPDATE characters SET skin = '" .. exports.mysql:escape_string(savedSkin) .. "', clothingid = '" .. exports.mysql:escape_string(savedClothing) .. "', duty = '" .. exports.mysql:escape_string(getElementData( thePlayer, "duty" ) or 0 ) .. "' WHERE id = '" .. exports.mysql:escape_string(getElementData( thePlayer, "dbid" )).."'" )


	end
	return false
end
addEventHandler("duty:request", getRootElement(), dutyRequest)

addEvent("duty:offduty", true)
function dutyOffduty()

	local thePlayer = client or source
	local grantID = getElementData(thePlayer, "duty") or 0
	if tonumber(grantID) > 0 then
		local savedSkin, savedClothing = nil, nil

		setPedArmor(thePlayer, 0)
		local correction = 0
		local items = exports['item-system']:getItems( thePlayer ) -- [] [1] = itemID [2] = itemValue
		for itemSlot, itemCheck in ipairs(items) do
			if (itemCheck[1] == 115) then -- Weapon
				local itemCheckExplode = exports.global:explode(":", itemCheck[2])
				local serialNumberCheck = exports.global:retrieveWeaponDetails(itemCheckExplode[2])
				if (tonumber(serialNumberCheck[2]) == 2) then -- /duty spawned
					exports['item-system']:takeItemFromSlot(thePlayer, itemSlot - correction, false)
					correction = correction + 1
				end
			elseif (itemCheck[1] == 116) then
				local checkString = string.sub(itemCheck[2], -4)
				if checkString == " (D)" then -- duty given weapon
					exports['item-system']:takeItemFromSlot(thePlayer, itemSlot - correction, false)
					correction = correction + 1
				end
			elseif itemCheck[1] == 16 then
				-- use the first skin as skin to wear
				if not savedSkin then
					local skinData = split(tostring(itemCheck[2]), ':')
					savedSkin = tonumber(skinData[1])
					savedClothing = tonumber(skinData[2])
				end
			end
		end

		-- remove duty items
		local foundPackage = getGrant(thePlayer, grantID, exports.factions:getCurrentFactionDuty(thePlayer))
		if foundPackage then
			for itemIndexID, itemTableContent in pairs(foundPackage[5]) do
				if itemTableContent[2] > 0 then -- its a real item
					exports.global:takeItem(thePlayer, itemTableContent[2], itemTableContent[3])
				end
			end
		end

		-- reset the skin to the first found in the inventory
		if savedSkin then
			setElementModel(thePlayer, savedSkin)
			setElementData(thePlayer, 'clothing:id', savedClothing)

			exports.mysql:query_free( "UPDATE characters SET skin = '" .. exports.mysql:escape_string(savedSkin) .. "', clothingid = '" .. exports.mysql:escape_string(savedClothing or 0) .. "', duty = '0' WHERE id = '" .. exports.mysql:escape_string(getElementData( thePlayer, "dbid" )).."'" )
		else
			-- no actual clothes in inventory
			exports['item-system']:doItemGiveawayChecks(thePlayer, 16)

			exports.mysql:query_free( "UPDATE characters SET duty = '0' WHERE id = '" .. exports.mysql:escape_string(getElementData( thePlayer, "dbid" )).."'" )
		end

		exports.anticheat:changeProtectedElementDataEx(thePlayer, "duty", 0, true)

		triggerClientEvent(thePlayer, "onPlayerDuty", thePlayer, false)
		triggerEvent("onPlayerDuty", thePlayer, false)
	end
end
addEventHandler("duty:offduty", getRootElement(), dutyOffduty)
