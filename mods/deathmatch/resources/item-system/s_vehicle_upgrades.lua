function addUpgrade( source, vehicle, itemSlot, itemID, itemValue )
	-- check for existing upgrades
	local old_upgrades = getVehicleUpgrades(vehicle)
	local old_upgrade = nil
	for key, value in ipairs(old_upgrades) do
		if value == itemValue then
			outputChatBox("This Upgrade is already added.", source, 255, 0, 0)
			return
		elseif getVehicleUpgradeSlotName(value) == getVehicleUpgradeSlotName(itemValue) then
			old_upgrade = value
		end
	end
	
	if getElementData(vehicle, "job") ~= 0 or getElementData(vehicle, "owner") == -2 then
		outputChatBox("You can't install upgrades to civilian vehicles!", source, 255, 0, 0)
		return
	end
	
	-- upgrade is not added yet, try it
	if takeItemFromSlot(source, itemSlot) then
		if addVehicleUpgrade(vehicle, itemValue) then
			local data = getElementData( source, "v:mods" ) or {}
			
			if old_upgrade then
				giveItem(source, itemID, old_upgrade)
				exports.logs:dbLog(source, 6, { vehicle }, "MODDING AUTOREMOVEUPGRADE ".. itemValue .. " " .. getItemDescription(itemID, itemValue))
				if data[vehicle] then
					data[vehicle][old_upgrade] = nil
				end
			end
			exports.logs:dbLog(source, 6, { vehicle }, "MODDING ADDUPGRADE ".. itemValue .. " " .. getItemDescription(itemID, itemValue))
			exports.global:sendLocalMeAction(source, "adds " .. getItemDescription(itemID, itemValue) .. " to their " .. exports.global:getVehicleName(vehicle).."("..getVehicleName(vehicle) .. ").")
			exports.vehicle:saveVehicleMods(vehicle)
			
			if not data[vehicle] then
				data[vehicle] = {}
			end
			data[vehicle][itemValue] = getRealTime( ).timestamp
			if isElement(source) then
				exports.anticheat:changeProtectedElementDataEx( source, "v:mods", data, true)
			else
				outputDebugString("AntiCheat Error on line 35", 2)
			end
		else
			outputChatBox("This upgrade is not compatible to this " .. exports.global:getVehicleName(vehicle) .. ".", source, 255, 194, 14)
			giveItem( source, itemID, itemValue )
		end
	else
		outputChatBox("Failed to take item.", source, 255, 194, 14)
	end
end

--
function moveUpgradeFromElement( upgrade )
	if isVehicleLocked( source ) and getPedOccupiedVehicle( client ) ~= source then
		triggerClientEvent( client, "finishItemMove", client )
		return
	end
	
	local data = getElementData( client, "v:mods" )
	local admin = false
	if not data or not data[ source ] or not data[ source ][ upgrade ] then
		if not exports.integration:isPlayerTrialAdmin( client ) then
			triggerClientEvent( client, "finishItemMove", client )
			return
		else
			admin = true
		end
	end

	if hasSpaceForItem( client, 114, upgrade ) then
		if removeVehicleUpgrade( source, upgrade ) then
			if not admin then
				data[ source ][ upgrade ] = nil
				if isElement(source) then
					exports.anticheat:changeProtectedElementDataEx( source, "v:mods", data, true)
				else
					outputDebugString("AntiCheat Error on line 70", 2)
				end
			end
			
			giveItem( client, 114, upgrade )
			exports.logs:dbLog(client, 6, { client, source }, "REMOVEUPGRADE ".. upgrade .. " " .. getVehicleUpgradeSlotName(upgrade) .. " | Only cause of being an admin = " .. tostring(admin))
			x_output_wrapper( source, client, 114, upgrade )
			triggerClientEvent( client, "forceElementMoveUpdate", client )
			
			exports.vehicle:saveVehicleMods(source)
		else
			outputChatBox( "Vehicle upgrade does not exist?", client, 255, 0, 0 )
		end
	else
		outputChatBox( "Your Inventory is full.", client, 255, 0, 0 )
	end
	triggerClientEvent( client, "finishItemMove", client )
end
addEvent( "item:vehicle:removeUpgrade", true )
addEventHandler( "item:vehicle:removeUpgrade", getRootElement(), moveUpgradeFromElement )

setTimer(
	function( ) -- cleanup
		for _, player in ipairs( getElementsByType( "player" ) ) do
			local data = getElementData( player, "v:mods" )
			if data then
				local anyAtAll = false
				local changed = false
				for vehicle, mods in pairs( data ) do
					local anyForVehicle = false
					
					for km, vm in pairs( mods ) do
						if getRealTime( ).timestamp - vm < 5 * 60000 then
							-- added more than five minutes ago
							data[vehicle][km] = nil
							changed = true
						else
							anyForVehicle = true
							anyAtAll = true
						end
					end
					
					if not anyForVehicle then
						data[vehicle] = nil
						changed = true
					end
				end
				
				if not anyAtAll then
					if isElement(player) then
						exports.anticheat:changeProtectedElementDataEx( player, "v:mods", data, true)
					else
						outputDebugString("AntiCheat Error on line 123", 2)
					end
				elseif changed then
					if isElement(player) then
						exports.anticheat:changeProtectedElementDataEx( player, "v:mods", data, true)
					else
						outputDebugString("AntiCheat Error on line 130", 2)
					end
				end
			end
		end
	end,
	5 * 60000,
	0
)
