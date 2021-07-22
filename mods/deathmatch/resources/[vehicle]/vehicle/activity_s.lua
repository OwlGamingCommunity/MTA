--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

addEventHandler( 'onVehicleEnter', root, function( player, seat, jacked ) 
	if seat == 0 and not hasVehicleEngine( source ) then
		local vid = getElementData( source, 'dbid' )
		exports.anticheat:setEld( source, "lastused", exports.datetime:now(), 'all' )
		dbExec( exports.mysql:getConn('mta'), "UPDATE vehicles SET lastUsed=NOW() WHERE id=? ", vid )
		-- logs
		exports.vehicle_manager:addVehicleLogs( vid , "Got in and reset last used because vehicle is engineless.", player )
		exports.logs:dbLog( player, 31, source , "Got in and reset last used because vehicle is engineless." )
	end
end )
