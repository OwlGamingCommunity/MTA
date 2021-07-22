--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local function fetchPermissions( player )
	local groups, perm = getElementData( resourceRoot, 'mdc_groups' ), getElementData( player, 'mdc_account' )
	if groups and perm then
		return groups, perm
	else
		outputDebugString( '[MDC] Could not fetch groups permissions or user permissions for player '..getPlayerName( player ) )
	end
end

-- return (faction id, access level, access value) if player has access, return nil if no access found.
function canAccess( player, access_name )
	local groups, perm = fetchPermissions( player )
	local my_active_faction = exports.factions:getCurrentFactionDuty( player ) or 0
	local my_perm = perm and perm[ my_active_faction ] or false
	if my_perm then
		for my_org, group in pairs( groups ) do
			if my_org == my_active_faction and group[access_name] then
				return my_org, my_perm, group[access_name]
			end
		end
	end
end

function getOrgNameFromId( id )
	local groups = getElementData( resourceRoot, 'mdc_groups' )
	if groups then
		for my_org, group in pairs( groups ) do
			if my_org == id then
				return group['name']
			end
		end
	end
	return 'Unknown'
end

-- return level, faction_id
function getAdminLevel( player )
	local my_active_faction = exports.factions:getCurrentFactionDuty( player ) or 0
	return getElementData( player, 'mdc_account' )[ my_active_faction ], my_active_faction
end


--[[
canSeeWarrants = {
	["LSPD"] = true,
	["FAA"] = true,
	["LSES"] = true,
	["LS GOV"] = true,
	["SAHP"] = true,
	["Rapid Towing"] = false,
	["SCoSA"] = true,
	["DOC"] = true,
}
canSeeCalls = {
	["LSPD"] = true,
	["FAA"] = false,
	["LSES"] = true,
	["LS GOV"] = false,
	["SAHP"] = true,
	["Rapid Towing"] = false,
	["SCoSA"] = true,
}
canAddAPB = {
	["LSPD"] = true,
	["FAA"] = true,
	["LSES"] = false,
	["LS GOV"] = true,
	["SAHP"] = true,
	["Rapid Towing"] = false,
	["SCoSA"] = true,
	["DOC"] = true,
}
canSeeVehicles = {
	["LSPD"] = true,
	["FAA"] = true, --FAA only aircrafts
	["LSES"] = false,
	["LS GOV"] = true,
	["SAHP"] = true,
	["Rapid Towing"] = true,
	["SCoSA"] = true,
	["DOC"] = true,
}
canSeeProperties = {
	["LSPD"] = true,
	["FAA"] = false,
	["LSES"] = true,
	["LS GOV"] = true,
	["SAHP"] = true,
	["Rapid Towing"] = false,
	["SCoSA"] = true,
	["DOC"] = true,
}
canSeeLicenses = {
	["LSPD"] = true,
	["FAA"] = false,
	["LSES"] = false,
	["LS GOV"] = false,
	["SAHP"] = true,
	["Rapid Towing"] = false,
	["SCoSA"] = true,
	["DOC"] = true,
}
canSeePilotStuff = {
	["LSPD"] = true,
	["FAA"] = true,
	["LSES"] = false,
	["LS GOV"] = false,
	["SAHP"] = true,
	["Rapid Towing"] = false,
	["SCoSA"] = true,
}
impound_can_see = {
	['SAHP'] = 59,
	['LSPD'] = 1,
}
settingUsernameFormat = {
	--1: Firstname Lastname, 2: FLastname
	["LSPD"] = 2,
	["FAA"] = 1,
	["LSES"] = 1,
	["LS GOV"] = 1,
	["SAHP"] = 2,
	["Rapid Towing"] = 1,
	["SCoSA"] = 2,	
	["DOC"] = 2,
}

]]