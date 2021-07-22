--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

-- this block will fetch user groups from db and cache it in resourceRoot element data, also cleaning up groups, users data if faction accosiated with it is prematurely deleted.
addEventHandler( 'onResourceStart', resourceRoot, function()
	dbQuery( function( qh ) 
		local res, nums, id = dbPoll( qh, 0 )
		if res and nums > 0 then
			local perms = {}
			local perms_delete = {}
			for _, r in ipairs(res) do
				if r.existed then
					perms[r.faction_id] = {
						name = r.name,
						haveMdcInAllVehicles = r.haveMdcInAllVehicles == 1,
						canSeeWarrants = r.canSeeWarrants == 1,
						canSeeCalls = r.canSeeCalls == 1,
						canAddAPB = r.canAddAPB == 1,
						canSeeVehicles = r.canSeeVehicles == 1,
						canSeeProperties = r.canSeeProperties == 1,
						canSeeLicenses = r.canSeeLicenses == 1,
						canSeePilotStuff = r.canSeePilotStuff == 1,
						impound_can_see = r.impound_can_see == 1,
						settingUsernameFormat = r.settingUsernameFormat
					}
				else
					table.insert( perms_delete, r.faction_id )
				end
			end
			if setElementData( resourceRoot, 'mdc_groups', perms ) then
				outputDebugString("[MDC] Loaded "..nums.." mdc groups's permissions.")
			end
			-- clean up users and groups if factions is deleted.
			if #perms_delete > 0 then
				for _, delete in pairs( perms_delete ) do
					cleanUpMdcUsersAndGroups( faction_id )
				end
				outputDebugString("[MDC] Deleted "..#perms_delete.." mdc users and groups because the factions are no longer existed.")
			end
		end
	end, {}, exports.mysql:getConn('mta'), "SELECT m.*, f.id AS existed FROM mdc_groups m LEFT JOIN factions f ON m.faction_id=f.id" )
end)

-- this exported function is also used by /deletefaction in faction system.
function cleanUpMdcUsersAndGroups( faction_id )
	dbExec( exports.mysql:getConn('mta'), "DELETE FROM mdc_groups WHERE faction_id=? ", faction_id )
	dbExec( exports.mysql:getConn('mta'), "DELETE FROM mdc_users WHERE organization=? ", faction_id )
end

local function getIdFromOrg( org )
	for id, pack in pairs( getElementData( resourceRoot, 'mdc_groups' )  ) do
		if pack.name == org then
			return id
		end
	end
end

-- for development purpose only.
addCommandHandler( 'convertmdcaccounts', function(p, c)
	if exports.integration:isPlayerScripter( p ) then
		local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT * FROM mdc_users" )
		local res, nums, id = dbPoll( qh, 10000 )
		if res and nums > 0 then
			for i, row in pairs( res ) do
				local id_ = getIdFromOrg( row.organization )
				if id_ then
					dbExec( exports.mysql:getConn('mta'), "UPDATE mdc_users SET organization=? WHERE id=?", id_, row.id )
					outputDebugString('[MDC] Convert MDC account organization: '..row.organization..' => '..id_)
				end
			end
		end
	end
end)

-- for development purpose only, do not run twice.
addCommandHandler( 'removeduplicatedaccounts', function(p, c)
	if exports.integration:isPlayerScripter( p ) then
		local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT * FROM mdc_users" )
		local res, nums, id = dbPoll( qh, 10000 )
		local users = {}
		if res and nums > 0 then
			for i, row in pairs( res ) do
				users[ row.charid ] = ( users[ row.charid ] or 0 ) + 1
			end
			for charid, count in pairs( users ) do
				if count > 1 then
					dbExec( exports.mysql:getConn('mta'), "DELETE FROM mdc_users WHERE `level`=1 AND charid=?", charid )
					outputDebugString('[MDC] Deleted duplicated MDC account on charid= '..charid )
				end
			end
		end
	end
end)


