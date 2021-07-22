--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

addEvent( 'factions:fetchFactionList', true )
addEventHandler( 'factions:fetchFactionList', resourceRoot, function ( )
	dbQuery( function( qh, client )
		local res, nums, id = dbPoll( qh, 0 )
		local factions = { }
		if res and nums > 0 then
			for _, row in ipairs( res ) do
				table.insert( factions, {
					id = row.id,
					name = row.name,
					type = row.type,
					members = ( #getPlayersInFaction(row.id) or "?" ) .. " / " .. row.members,
					max_interiors = row.max_interiors,
					max_vehicles = row.max_vehicles,
					ints = row.ints,
					vehs = row.vehs,
					free_custom_ints = row.free_custom_ints,
					free_custom_skins = row.free_custom_skins,
					before_tax = row.before_tax_value,
					free_wage = row.before_wage_charge
				} )
				table.sort( factions, function( a, b ) return a.id < b.id end )
			end
		end
		triggerClientEvent( client, "showFactionList", resourceRoot, factions )
	end , { client }, exports.mysql:getConn('mta'), "SELECT	id, name, type, (SELECT COUNT(*) FROM characters_faction c WHERE c.faction_id = f.id) AS members, (SELECT COUNT(*) FROM interiors i WHERE i.faction = f.id AND i.deleted=0) AS ints, (SELECT COUNT(*) FROM vehicles v WHERE v.faction = f.id AND v.deleted=0) AS vehs, max_interiors, max_vehicles, free_custom_ints, free_custom_skins, before_tax_value, before_wage_charge FROM factions f ORDER BY id ASC" )
end )

addEvent( 'factions:editFaction', true )
addEventHandler( 'factions:editFaction', resourceRoot, function( data, old_id )
	local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT id, name FROM factions WHERE id!=? AND name=? LIMIT 1", old_id or 0, data.name )
	local res, nums, id = dbPoll( qh, 10000 )
	if res then
		if nums > 0 and res[1].name == data.name then
			return not triggerClientEvent( client, 'factions:editFaction:callback', resourceRoot, 'Faction Name is already taken.' )
		end
		-- if editing an existed faction.
		if old_id then
			local qh2 = dbQuery( exports.mysql:getConn('mta'), "UPDATE factions SET name=?, type=?, max_interiors=?, max_vehicles=?, free_custom_ints=?, free_custom_skins=?, before_tax_value=?, before_wage_charge=? WHERE id=?", data.name, data.type, data.max_interiors, data.max_vehicles, data.free_custom_ints, data.free_custom_skins, data.before_tax_value, data.free_wage_amount, old_id )
			local res, nums, id = dbPoll( qh2, 10000 )
			if nums and nums > 0 then
				local team = exports.pool:getElement( 'team', old_id )
				if team then
					exports.anticheat:setEld( team, 'type', data.type, 'all' )
					exports.anticheat:setEld( team, "max_interiors", data.max_interiors, 'none' ) --Don't sync at all
					exports.anticheat:setEld( team, "max_vehicles", data.max_vehicles, 'none' ) --Don't sync at all
					exports.anticheat:setEld( team, "before_tax_value", data.before_tax_value, 'none' ) --Don't sync at all
					exports.anticheat:setEld( team, "before_wage_charge", data.free_wage_amount, 'none' ) --Don't sync at all
					exports.anticheat:setEld( team, "permissions", { free_custom_ints = data.free_custom_ints, free_custom_skins = data.free_custom_skins } , 'all' )
					setTeamName( team, data.name )
					exports.cache:removeFactionNameFromCache(old_id)
				else
					outputDebugString( "[FACTION] factions:editFaction / Unable to allocate pool faction element id ".. old_id.. ". Data sample: "..tostring(team) )
				end
				exports.global:sendMessageToAdmins( "[FACTION] " .. exports.global:getPlayerFullIdentity( client ).." has modified faction '" .. data.name .. "'." )
				exports.factions:sendNotiToAllFactionMembers( old_id, "Your faction '" .. data.name .. "' was modified.", "Modified by "..exports.global:getPlayerFullIdentity( client, 1, true )..".")
				exports.logs:dbLog( client, 4, team, "EDIT FACTION" )
				return triggerClientEvent( client, 'factions:editFaction:callback', resourceRoot, 'ok' )
			else
				return not triggerClientEvent( client, 'factions:editFaction:callback', resourceRoot, 'Error code 61 occurred during the process. Faction modification failed. ' )
			end
		-- if creating new faction.
		else
			local qh2 = dbQuery( exports.mysql:getConn('mta'), "INSERT INTO factions SET bankbalance='0', motd='Welcome to the faction.', note = '', name=?, type=?, max_interiors=?, max_vehicles=?, free_custom_ints=?, free_custom_skins=?, before_tax_value=?, before_wage_charge=? ", data.name, data.type, data.max_interiors, data.max_vehicles, data.free_custom_ints, data.free_custom_skins, data.before_tax_value, data.free_wage_amount )
			local res, nums, id = dbPoll( qh2, 10000 )
			if id and tonumber(id) then
				data.id = id
				data.bankbalance = 0
				data.motd = ''
				data.note = ''
				data.fnote = ''
				local theTeam = loadOneFaction( data )
				local rank_order = ""
				local factionRanks = {}
				local factionWages = {}
				RanksByFaction[data.id] = {}
			
				local perms = {}
				for i,v in ipairs(mem_permissions) do
					table.insert(perms, i)
				end
				local permissions = table.concat(perms, ",")
				for i=1,2 do
					if i == 1 then
						local qh3 = dbQuery( exports.mysql:getConn('mta'), "INSERT INTO faction_ranks SET faction_id=?, name='Leader Rank', permissions=?, isDefault='0', isLeader='1', wage='0'", data.id, permissions)
						local res, nums, rid1 = dbPoll( qh3, 10000 )
						local rankID = tonumber(rid1)
						FactionRanks[rankID] = {}
						FactionRanks[rankID]["name"] = "Leader Rank"
						FactionRanks[rankID]["permissions"] = permissions
						FactionRanks[rankID]["isDefault"] = 0
						FactionRanks[rankID]["isLeader"] = 1
						FactionRanks[rankID]["faction_id"] = data.id
						table.insert(RanksByFaction[data.id], tonumber(rankID))
						factionRanks[rankID] = "Leader Rank"
						factionWages[rankID] = 0
						rank_order = rank_order..rankID..","
						dbFree( qh3 )

					elseif i == 2 then	
						local qh4 = dbQuery( exports.mysql:getConn('mta'), "INSERT INTO faction_ranks SET faction_id=?, name='Default Rank', permissions='', isDefault='1', isLeader='0', wage='0'", data.id)
						local res, nums, rid2 = dbPoll( qh4, 10000 )
						local rankID = tonumber(rid2)
						FactionRanks[rankID] = {}
						FactionRanks[rankID]["name"] = "Default Rank"
						FactionRanks[rankID]["permissions"] = ""
						FactionRanks[rankID]["isDefault"] = 1
						FactionRanks[rankID]["isLeader"] = 0
						FactionRanks[rankID]["faction_id"] = data.id
						table.insert(RanksByFaction[data.id], tonumber(rankID))
						factionRanks[rankID] = "Default Rank"
						factionWages[rankID] = 0
						rank_order = rank_order..rankID..","
						dbFree( qh4 )
					end
				end		
				--local orderQuery = dbQuery( exports.mysql:getConn('mta'), "UPDATE factions as f, (SELECT * FROM faction_ranks WHERE faction_id=?) as temp SET rank_order=temp.id WHERE id=?", data.id, data.id)
				
				
				
				dbExec(exports.mysql:getConn("mta"), "UPDATE `factions` SET `rank_order` = '"..rank_order.."' WHERE `id` = "..data.id)
				exports.anticheat:setEld(theTeam, "rank_order", rank_order, 'all')
				exports.anticheat:setEld(theTeam, "ranks", factionRanks, 'all')
				exports.anticheat:setEld(theTeam, "wages", factionWages, 'all') 
				dutyAllow[ id ] = { }
				dutyAllow[ id ] = { id, name, { --[[Duty information]] } }
				setElementData( resourceRoot, "dutyAllowTable", dutyAllow)
				locations[ id ] = { }
				custom[ id ] = { }
				exports.logs:dbLog( client, 4, theTeam, "MAKE FACTION")
				exports.global:sendMessageToAdmins( "[FACTION] " .. exports.global:getPlayerFullIdentity( client ).." has created faction '" .. data.name .. "'." )
				triggerClientEvent("faction-system.cacheRanks", root, FactionRanks)
				return triggerClientEvent( client, 'factions:editFaction:callback', resourceRoot, 'ok' )
			else
				return not triggerClientEvent( client, 'factions:editFaction:callback', resourceRoot, 'Error code 88 occurred during the process. Faction modification failed.' )
			end
		end
	else
		dbFree( qh )
		return not triggerClientEvent( client, 'factions:editFaction:callback', resourceRoot, 'Error code 97 occurred during the process. Faction modification failed.' )
	end
end )

addEvent( 'factions:delete', true )
addEventHandler( 'factions:delete', resourceRoot, function( factionID )
	factionID = tonumber( factionID )
	dbExec(exports.mysql:getConn("mta"), "DELETE FROM factions WHERE id=?", factionID )
	dbExec(exports.mysql:getConn("mta"), "DELETE FROM faction_ranks WHERE faction_id=?", factionID )
	--Clean all players in the faction
	for key, value in pairs( getPlayersInFaction( factionID ) ) do
		local factionInfo = getElementData(value, "faction")
		local organizedTable = {}

		for i, k in pairs(factionInfo) do
			organizedTable[k.count] = i
		end

		local found = false
		for k,v in ipairs(organizedTable) do
			if v == factionID then
				found = true
			end

			if found then
				factionInfo[v].count = factionInfo[v].count - 1
			end
		end

		factionInfo[factionID] = nil
		exports.anticheat:changeProtectedElementDataEx( value, "faction", factionInfo, true )

		if getElementData(value, "duty") and getElementData(value, "duty") > 0 then
			takeAllWeapons(value)
			exports.anticheat:changeProtectedElementDataEx(value, "duty", 0, true)
		end
	end
	dbExec(exports.mysql:getConn("mta"), "DELETE FROM characters_faction WHERE faction_id=?", factionID)

	local theTeam = exports.pool:getElement( 'team', factionID )

	--Remove all vehicles
	local vehs = 0
	--if mysql:query_free("UPDATE vehicles SET deleted="..getElementData(thePlayer, "account:id").." WHERE faction=" .. factionID) then
		for i, veh in pairs(getElementsByType("vehicle")) do
			if veh and isElement(veh) and getElementData(veh, "faction") == factionID then
				local vehid = getElementData(veh, "dbid")
				executeCommandHandler("delveh", client, vehid)
				executeCommandHandler("delveh", client, vehid)
				exports.vehicle_manager:addVehicleLogs(vehid, "Vehicle destroyed upon faction deletion ("..(theTeam and getTeamName( theTeam ) or "N/A")..").", client)
				--executeCommandHandler("removeveh", thePlayer, vehid)
				--executeCommandHandler("removeveh", thePlayer, vehid)
				vehs = vehs + 1
			end
		end
	--end

	--Remove all interiors
	local ints = 0
	--if mysql:query_free("UPDATE interiors SET deleted="..getElementData(thePlayer, "account:id").." WHERE faction=" .. factionID) then
		for i, int in pairs(getElementsByType("interior")) do
			if int and isElement(int) and getElementData(int, "status") and getElementData(int, "status").faction == factionID then
				local intid = getElementData(int, "dbid")
				triggerEvent("interior_system:factionfsell", client, factionID, intid)
				ints = ints + 1
			end
		end
	--end

	--Remove all duty information
	mysql:query_free("DELETE FROM duty_custom WHERE factionid = ".. factionID)
	mysql:query_free("DELETE FROM duty_locations WHERE factionid = ".. factionID)
	mysql:query_free("DELETE FROM duty_allowed WHERE faction = ".. factionID)
	custom[factionID] = nil
	if locations[factionID] then
		for k,v in pairs(locations[factionID]) do
			exports.duty:destroyDutyColShape(factionID, k)
		end
		locations[factionID] = nil
	end
	dutyAllow[factionID] = nil
	setElementData(resourceRoot, "dutyAllowTable", dutyAllow)
	for k,v in ipairs(dutyAllowChanges) do
		if v[1] == factionID then
			dutyAllowChanges[k] = nil
		end
	end

	-- Delete all users and groups from MDC system those are associated with this faction.
	exports.mdc:cleanUpMdcUsersAndGroups( factionID )
	exports.global:sendMessageToAdmins("[FACTION] "..exports.global:getPlayerFullIdentity(client, 1, true).." deleted faction '"..(theTeam and getTeamName( theTeam ) or "N/A").."'. "..ints.." interior(s) and "..vehs.." vehicle(s) were also destroyed.")
	exports.factions:sendNotiToAllFactionMembers(factionID, "Your faction '"..(theTeam and getTeamName( theTeam ) or "N/A").."' was deleted", "Processed by "..exports.global:getPlayerFullIdentity(client, 1, true)..".")
	if theTeam then
		exports.logs:dbLog( client, 4, theTeam, "DELETE FACTION")
		destroyElement( theTeam )
	end

	triggerClientEvent( client, 'showFactionList', resourceRoot )
end)

addEvent( 'factions:listMember', true )
addEventHandler( 'factions:listMember', resourceRoot, function ( fact_id )
	dbQuery( function( qh, client, fact_id )
		fact_id = tonumber(fact_id)
		local res, nums, id = dbPoll( qh, 0 )
		if nums and tonumber( nums ) then
			if nums > 0 then
				local qh2 = dbQuery( exports.mysql:getConn('mta'), "SELECT * FROM factions WHERE id=?", fact_id )
				local res2, nums2, id2 = dbPoll( qh2, 10000 )
				if res2 and nums2 > 0 then
					local members = {}
					for _, member in ipairs( res ) do
						member.faction_rank_name = getRankName(member.faction_rank)
						member.username = exports.cache:getUsernameFromId(member.account) or "Unknown"

						local player = getPlayerFromName( tostring(member.charactername) )
						member.online = player and 1 or 0
						member.duty = player and (getCurrentFactionDuty(player) == fact_id) or false
						table.insert( members, member )
					end
					table.sort( members, function(a, b)
						if a.online == b.online then
							if a.faction_leader == b.faction_leader then
								return a.faction_rank > b.faction_rank
							else
								return a.faction_leader > b.faction_leader
							end
						else
							return a.online > b.online
						end
					end)
					return triggerClientEvent( client, 'factions:listMember', resourceRoot, res2[1].name, 'ok', members )
				else
					dbFree( qh2 )
					return not triggerClientEvent( client, 'factions:listMember', resourceRoot, fact_id, 'Errors occurred while fetching information from server.' )
				end
			else
				return triggerClientEvent( client, 'factions:listMember', resourceRoot, fact_id, 'This faction is currently having no memeber.' )
			end
		else
			dbFree( qh )
			return not triggerClientEvent( client, 'factions:listMember', resourceRoot, fact_id, 'Errors occurred while fetching information from server.' )
		end
	end , { client, fact_id }, exports.mysql:getConn('mta'), "SELECT c.charactername, c.account, cf.faction_leader, cf.faction_rank FROM characters_faction cf LEFT JOIN characters c ON c.id=cf.character_id WHERE cf.faction_id=? ORDER BY c.charactername", fact_id )
end)
