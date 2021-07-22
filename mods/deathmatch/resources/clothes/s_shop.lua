--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

addEvent('clothes:list', true)
addEventHandler('clothes:list', root,
	function(item, for_faction)
		-- triggered from clothes NPC
		if item then
			-- Client = player
			-- Source = the ped
			local table = {}
			for id, cloth in pairs(savedClothing) do
				if tonumber(item.itemValue) == cloth.skin and isForSale(cloth) then
					table[id] = cloth
				end
			end
			triggerClientEvent(client, 'clothes:list', source, item, table)
		-- triggered from Dupont NPC
		else
			if for_faction then
				local table = {}
				local fid = canUploadForFaction(source)
				if fid then
					for id, cloth in pairs(savedClothing) do
						if cloth.creator_char == -fid then
							table[id] = cloth
						end
					end
				end
				triggerClientEvent(source, 'clothes:listMyClothes', source, table, for_faction)
			else
				local table = {}
				for id, cloth in pairs(savedClothing) do
					if cloth.creator_char == getElementData(source, 'dbid') then
						table[id] = cloth
					end
				end
				triggerClientEvent(source, 'clothes:listMyClothes', source, table)
			end
		end
	end)

-- buying stuff
addEvent('clothing:buy', true)
addEventHandler('clothing:buy', root,
	function(id)
		-- prepare some interior info
		local int = exports.pool:getElement('interior', getElementDimension(source))
		local is_active_biz = int and exports.npc:isActiveBusiness(int)
		local status = int and getElementData(int, "status") or nil
		local interiorType = status and tonumber(status.type or 2)
		local discount = exports.npc:getDiscount( client, 5 )

		if id < 0 then -- default skin
			-- check supplies / except for ints made in world map or not in an active business
			if is_active_biz and not exports.npc:hasSupplies(int, 16) then
				return outputChatBox("This item is out of stock.", client, 255,0,0)
			end

			if exports.global:hasMoney(client, math.ceil(50*discount))  then
				if exports.global:giveItem(client, 16, -id) then
					outputChatBox('You purchased an outfit for $' .. exports.global:formatMoney(50) .. '.', client, 0, 255, 0)
					-- take & give some money
					exports.global:takeMoney(client, math.ceil( 50*discount))

					-- Deduct interior supplies / except for ints made in world map or or not in an active business
					if is_active_biz and exports.npc:takeSupplies(int, 16) then
						exports.npc:giveProfit(int, source, client, {price=50, name='Outfit #'..-id..' Original'})
					end
				else
					outputChatBox('You do not have enough space in your inventory.', client, 255, 0, 0)
				end
			else
				outputChatBox('You do not have the required $' .. exports.global:formatMoney(clothing.price) .. '.', client, 255, 0, 0)
			end
		else
			local clothing = savedClothing[id]
			if clothing and isForSale(clothing) then
				-- check supplies / except for ints made in world map or not in an active business
				if is_active_biz and not exports.npc:hasSupplies(int, 16) then
					return outputChatBox("This item is out of stock.", client, 255,0,0)
				end

				-- enough money to steal?
				if exports.global:hasMoney(client, math.ceil(clothing.price*discount)) then
					-- enough backpack space?
					if exports.global:giveItem(client, 16, clothing.skin .. ':' .. clothing.id) then
						outputChatBox('You purchased an outfit for $' .. exports.global:formatMoney(math.ceil(clothing.price*discount)) .. '.', client, 0, 255, 0)
						paid = clothing.price
						-- take & give some money
						exports.global:takeMoney(client, math.ceil(clothing.price*discount))

						-- Deduct interior supplies / except for ints made in world map or or not in an active business
						if is_active_biz and exports.npc:takeSupplies(int, 16) then
							exports.npc:giveProfit(int, source, client, {price=clothing.price, name='Outfit #'..clothing.skin..' '..clothing.description})
						end
					else
						outputChatBox('You do not have enough space in your inventory.', client, 255, 0, 0)
					end
				else
					outputChatBox('You do not have the required $' .. exports.global:formatMoney(math.ceil(clothing.price*discount)) .. '.', client, 255, 0, 0)
				end

			elseif clothing then
				outputChatBox("You don't have enough permission to purchase this clothes.", client, 255,0,0)
			else
				outputChatBox("We checked the link for this skin and found out it is no longer available. We've removed it from our systems, sorry about that!", client, 255, 0, 0)
			end
		end
	end)

-- saving new or old clothes
function saveClothes(values, player, no_output)
	if not player then player = client end

	-- datetime workaround
	local fs_until = 'NULL'
	values.for_sale_until = tonumber(values.for_sale_until) or 0
	if values.for_sale_until > 0 then
		fs_until = "FROM_UNIXTIME("..values.for_sale_until..")"
	end

	if not values.id then
		-- new clothing stuff
		local qh = dbQuery( exports.mysql:getConn('mta') , "INSERT INTO clothing SET skin=?, url=?, description=?, price=?, creator_char=?, distribution=?, for_sale_until="..fs_until,
		values.skin, values.url, values.description or "A clean set of clothes", values.price or 50, values.creator_char or 0, values.distribution or 0 )
		local result, num_affected_rows, last_insert_id = dbPoll ( qh, 10000 )
		if result then
			values.id = last_insert_id
			savedClothing[last_insert_id] = values
			if not values.request then values.request = "NONE" end
			if no_output then
				return false, "Your design has been saved"
			else
				outputChatBox('Your design has been saved', player, 0, 255, 0)
			end
			return last_insert_id
		else
			if no_output then
				return false, "Unable to add clothes."
			else
				outputChatBox('Unable to add clothes.', player, 255, 0, 0)
			end
		end
	else
		-- old clothing stuff
		local existing = savedClothing[values.id]
		if existing then
			local qh = dbQuery(exports.mysql:getConn('mta') , "UPDATE clothing SET skin=?, url=?, description=?, price=?, creator_char=?, distribution=?, for_sale_until="..fs_until.." WHERE id=?",
			values.skin, values.url, values.description or "A clean set of clothes", values.price or 50, values.creator_char or 0, values.distribution or 0, values.id )
			local result, num_affected_rows, last_insert_id = dbPoll ( qh, 10000 )
			if result then
				savedClothing[values.id] = values
				if no_output then
					return false, "Your design has been updated"
				else
					outputChatBox('Your design has been updated', player, 0, 255, 0)
				end
				return values.id
			else
				if no_output then
					return false, "Unable to save clothes."
				else
					outputChatBox('Unable to save clothes.', player, 255, 0, 0)
				end
			end
		else
			if no_output then
				return false, "Unable to find clothes?"
			else
				outputChatBox('Unable to find clothes?', player, 255, 0, 0)
			end
		end
	end
end
addEvent('clothing:save', true)
addEventHandler('clothing:save', resourceRoot, saveClothes, false)

addEvent('clothing:delete', true)
addEventHandler('clothing:delete', resourceRoot, function(id, event)
	if type(id) == 'number' and savedClothing[id] then
		savedClothing[id] = nil
		table.remove(savedClothing, id)
		local path = getPath(id)
		if fileExists(path) then
			fileDelete(path)
		end
		if client and event == "deleteMyClothes" then
			outputChatBox('Your design has been deleted.', client, 0, 255, 0)
		end
		dbExec(exports.mysql:getConn('mta'), 'DELETE FROM clothing WHERE id=?',id)
		--triggerClientEvent("clothes:deleteFile", resourceRoot, id)
	end
end, false)
