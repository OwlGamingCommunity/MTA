--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function updateStaffReportCount( thePlayer, report )
	local adminreports = getElementData(thePlayer, "adminreports")
	adminreports = adminreports + 1
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "adminreports", adminreports, false)

	local adminreports_saved = getElementData(thePlayer, "adminreports_saved") or 0
	adminreports_saved = adminreports_saved + 1
	if adminreports_saved >= reportsToAward then
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "adminreports_saved", 0, false)
		exports.achievement:awardPlayer(thePlayer, false, "Handled "..reportsToAward.." reports!", gcToAward)
		exports.global:sendWrnToStaff(exports.global:getPlayerFullIdentity(thePlayer).." has earned "..gcToAward.." GCs for completing "..reportsToAward.." reports.", "ACHIEVEMENT")
	else
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "adminreports_saved", adminreports_saved, false)
	end

	-- print saved reports to admin.
	getSavedReports( thePlayer )

	-- updates to database.
	saveReportCount( thePlayer )

	-- collect data for statistics and graph.
	if report then
		collectReportData( report, thePlayer )
	end
end

function saveReportCount( player )
	local adminreports = getElementData( player, "adminreports")
	if tonumber(adminreports) then
		dbExec( exports.mysql:getConn('mta'), "UPDATE `account_details` SET `adminreports`=? WHERE `account_id`=? ", adminreports, getElementData( player, "account:id" ) )
	end

	local adminreports_saved = getElementData( player, "adminreports_saved")
	if tonumber(adminreports_saved) then
		dbExec( exports.mysql:getConn('mta'), "UPDATE `account_details` SET `adminreports_saved`=? WHERE `account_id`=? ", adminreports_saved, getElementData( player, "account:id" ) )
	end
end

function collectReportData( report, admin )
	local reporter = isElement( report[1] ) and getElementData( report[1], 'account:id' )
	local handler = report[5] == admin and getElementData( admin, 'account:id' )
	if handler and reporter then
		dbExec( exports.mysql:getConn('mta'), "INSERT INTO reports SET type=?, handler=?, reporter=?, details=? ", report[7] or 1, handler, reporter, report[3] or "N/A" )
	else
		outputDebugString( "[REPORT] Failed to collect report statistics for "..exports.global:getPlayerFullIdentity( admin ) )
	end
end

addEvent( 'report:syncStats', true )
addEventHandler( 'report:syncStats', resourceRoot, function( online, duty )
	dbExec( exports.mysql:getConn('mta'), "INSERT INTO online_sessions SET staff=?, minutes_online=?, minutes_duty=? ", getElementData( client, 'account:id' ), online, duty )
end )
