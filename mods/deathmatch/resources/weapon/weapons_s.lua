weapons = {}
ammopacks = {}

local function getItems(player)
	return exports['item-system']:getItems(player)
end

local function takeAllWeapons(player)
	for i, weap in pairs(exports.global:getPedWeapons(player, 0, 12)) do
		takeWeapon(player, weap)
		-- clear brassknuckle
		if weap == 1 then
			giveWeapon(player, 0, 0, true)
		end
	end
end

function refreshWeaponsAndAmmoTables(player)
	weapons[player] = { [0] = { [0] = { id = 0, slot = 0, name = 'Fist' } } }
	ammopacks[player] = {}
	for inv_slot, itemCheck in ipairs(getItems(player)) do
		-- check guns
		if itemCheck[1] == 115 then
			-- [1] = gta weapon id, [2] = serial number, [3] = weapon name, [4] = loaded ammo
			local dbid = tonumber(itemCheck[3])
			local gunDetails = exports.global:explode(':', itemCheck[2])
			local id = tonumber(gunDetails[1])
			local slot = getSlotFromWeapon(id)
			local loaded_ammo = tonumber(gunDetails[4] and gunDetails[4] or 0) or 0
			local serial = gunDetails[2]
			local serialNumberCheck = exports.global:retrieveWeaponDetails(serial)
			local duty = tonumber(serialNumberCheck[2]) == 2
			if not weapons[player][slot] then weapons[player][slot] = {} end
			weapons[player][slot][dbid] = { dbid = dbid, id = id, slot = slot, name = gunDetails[3], serial = serial, loaded_ammo = loaded_ammo, inv_slot = inv_slot, duty = duty, itemValue = itemCheck[2] }
			-- prepare ammo just in case we will need it.
		elseif itemCheck[1] == 116 then
			-- [1] Catridge ID, [2] Amount of bullets
			local gunDetails = exports.global:explode(':', itemCheck[2])
			local ammo = tonumber(gunDetails[2])
			local id = tonumber(gunDetails[1])
			if not ammopacks[player][id] and ammo > 0 then
				ammopacks[player][id] = { ammo = ammo, inv_slot = inv_slot, id = id, itemValue = itemCheck[2] }
			end
		end
	end
end

function updateLocalGuns(player, delay)
	player = player or source
	if not player or getElementData(player, "loggedin") ~= 1 then
		return
	end
	refreshWeaponsAndAmmoTables(player)

	-- take first, give later.
	takeAllWeapons(player)

	-- now send the data to set weapons to client
	-- only send one first weapon in slots
	local given = {}
	for slot, weap in pairs(weapons[player]) do
		for dbid, w in pairs(weap) do
			if weapons[player][slot][dbid] then
				if weapon_infinite_ammo[weapons[player][slot][dbid].id] then
					weapons[player][slot][dbid].loaded_ammo = 9998 -- because 9999 is infinite ammo, defined by GTA SA.
				end
				weapons[player][slot][dbid].loaded_ammo = weapons[player][slot][dbid].loaded_ammo or 0
				setWeaponAmmo(player, weapons[player][slot][dbid].id, 0)
				giveWeapon(player, weapons[player][slot][dbid].id, weapons[player][slot][dbid].loaded_ammo + 1, false)
				given[slot] = dbid
				break
			end
		end
	end
	-- need a bit of delay when you /restartres because client script may takes a few miliseconds to load, and it will bug if server triggers too soon.
	if delay and tonumber(delay) then
		setTimer(triggerClientEvent, delay, 1, player, 'weapon:updateUsingGun', resourceRoot, given)
	else
		triggerClientEvent(player, 'weapon:updateUsingGun', resourceRoot, given)
	end
end

addEvent("updateLocalGuns", true)
addEventHandler("updateLocalGuns", getRootElement(), updateLocalGuns)
addCommandHandler('updatelocalguns', updateLocalGuns, false)

addEventHandler('onResourceStart', resourceRoot, function()
	for _, player in pairs(exports.pool:getPoolElementsByType('player')) do
		updateLocalGuns(player, 3000)
	end
end)



addEvent("weapon:switch_weapon_in_same_slot", true)
addEventHandler("weapon:switch_weapon_in_same_slot", root,
	function (dbid, slot)
		local done
		refreshWeaponsAndAmmoTables(source)
		local weap = getPlayerWeaponFromDbid(source, dbid)
		if weap then
			-- clear all guns in the slot
			for dbid_, weap_ in pairs(weapons[source][weap.slot]) do
				if weap_.slot == weap.slot then
					setWeaponAmmo(source, weap_.id, 0)
				end
			end
			local loaded_ammo = weapons[source][weap.slot][dbid].loaded_ammo or 0
			giveWeapon(source, weap.id, loaded_ammo + 1, false)
			done = { slot = weap.slot, dbid = dbid }
		end
		triggerClientEvent(source, 'weapon:weaponSwitch_callback', source, done)
	end
)

function syncAmmo(queue)
	for dbid_, ammo in pairs(queue) do
		local weap = getPlayerWeaponFromDbid(client, dbid_)
		if weap then
			local slot = weap.slot
			if weapons[client][slot] then
				local dbid = weap.dbid
				if weapons[client][slot][dbid] then
					weapons[client][slot][dbid].loaded_ammo = ammo >= 0 and ammo or 0
					for inv_slot, item in ipairs(getItems(client)) do
						if item[1] == 115 and item[3] == dbid then
							local id = weap.id
							if weapon_ammoless[id] then
								exports['item-system']:takeItemFromSlot(client, inv_slot)
							else
								local newValue = modifyWeaponValue(item[2], 4, weapons[client][slot][dbid].loaded_ammo)
								if not newValue or not exports['item-system']:updateItemValue(client, inv_slot, newValue) then
									-- TODO: Make these stupid debug lines into logs...
									outputServerLog("[WEAPON] Server / syncAmmo / Could not sync ammo for player " .. getPlayerName(client))
								end
							end
							break
						end
					end
				end
			end
		end
	end
end

addEvent("weapon:syncAmmo", true)
addEventHandler("weapon:syncAmmo", resourceRoot, syncAmmo)

addCommandHandler('gunserial',
	function (player, cmd, serial)
	if exports.integration:isPlayerSupporter(player) or exports.integration:isPlayerTrialAdmin(player) or exports.integration:isPlayerScripter(player) then
		if serial then
			local serials = exports.global:retrieveWeaponDetails(serial)
			local gun_source = tonumber(serials[2])
			if gun_source then
				outputChatBox("Adminstrative information for '" .. serial .. "': ", player)
				local gun_creator = tonumber(serials[3])
				local account = gun_creator and exports.cache:getAccountFromCharacterId(gun_creator) or { id = 0, username = "Unknown" }
				local characterName = gun_creator and exports.cache:getCharacterNameFromID(gun_creator) or "Unknown"

				if gun_source == 1 then
					outputChatBox(" - Source: Spawned by admin.", player)
					outputChatBox(" - Spawned by: " .. characterName .. " (" .. account.username .. ")", player)
				elseif gun_source == 2 then
					outputChatBox(" - Source: Faction Duty", player)
					outputChatBox(" - Spawned to: " .. characterName .. " (" .. account.username .. ")", player)
				elseif gun_source == 3 then
					outputChatBox(" - Source: Ammunation", player)
					outputChatBox(" - Authorized under firearms license of: " .. characterName .. " (" .. account.username .. ")", player)
				elseif gun_source == 4 then
					outputChatBox(" - Source: Faction Drop NPC", player)
					outputChatBox(" - Created by: " .. characterName .. " (" .. account.username .. ")", player)
				else
					outputChatBox(" - No info could be retrieved.", player)
				end
			end
		else
			outputChatBox("SYNTAX: /" .. cmd .. " [Weapon Serial] - Retrieve adminstrative information about the weapons.", player)
		end
	end
end, false)