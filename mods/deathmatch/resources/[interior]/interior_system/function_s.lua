--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function sendPlayersOutside( int )
	-- prepare some info.
	local dbid = int
	if tonumber( int ) then
		int = exports.pool:getElement( 'interior', int )
	elseif isElement( int ) then
		dbid = getElementData( int, 'dbid' )
	end
	local entrance = getElementData( int, 'entrance' )
	local exit = getElementData( int, 'exit' )

	-- ok.
	if int and isElement( int ) and getElementType( int ) == 'interior' then
		for key, value in pairs( exports.pool:getPoolElementsByType('player') ) do
			if getElementInterior( value ) == exit.int and getElementDimension( value ) == exit.dim then
				setElementInterior( value, entrance.int )
				setCameraInterior( value, entrance.int )
				setElementDimension( value, entrance.dim )
				setElementPosition( value, entrance.x, entrance.y, entrance.z )
				return true
			end
		end
	end
end
