--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

safeTable = { }

function clearSafe( dbid, removeItems )
	if safeTable[ dbid ] then
		if isElement( safeTable[ dbid ] ) then
			if removeItems and exports.global:isResourceRunning( 'item-system' ) then
				exports['item-system']:clearItems( safeTable[ dbid ] )
			end
			destroyElement( safeTable[ dbid ] )
		end
		safeTable[ dbid ] = nil
		return true
	end
end

function getSafe( dbid )
	if dbid then
		if safeTable[ dbid ] and isElement( safeTable[ dbid ] ) and getElementType( safeTable[ dbid ] ) == 'object' then
			return safeTable[ dbid ]
		end
	else
		return safeTable
	end
end

local function buidSafe( oid, int, dim, pos, rot )
	local o = createObject( oid or 2332, pos[1], pos[2], pos[3], rot[1], rot[2], rot[3] )
	if o then
		setElementInterior( o, int )
		setElementDimension( o, dim )
		setElementDoubleSided( o, true )
		return o
	end
end

function addSafe( dbid, oid, pos, int, rot, clearItems, skipSql )
	-- clean up and prepare.
	clearSafe( dbid, clearItems )
	-- if newly created, fix its positions.
	if not skipSql then
		rot = rot + 180
		pos[3] = pos[3] - 0.5
	end
	-- ok.
	safeTable[ dbid ] = buidSafe( oid, int, dbid, pos, { 0, 0, rot } )
	if safeTable[ dbid ] and not skipSql then
		dbExec( exports.mysql:getConn('mta'), "UPDATE interiors SET safepositionX=?, safepositionY=?, safepositionZ=?, safepositionRZ=? WHERE id=? ", pos[1], pos[2], pos[3], rot, dbid )
	end
	return safeTable[ dbid ]
end

function updateSafe( dbid, pos, rot )
	return dbExec( exports.mysql:getConn('mta'), "UPDATE interiors SET safepositionX=?, safepositionY=?, safepositionZ=?, safepositionRZ=? WHERE id=? ", pos[1], pos[2], pos[3], rot, dbid )
	and setElementPosition( safeTable[ dbid ] , unpack(pos) )
	and setObjectRotation( safeTable[ dbid ] , 0, 0, rot )
end

addEvent( 'interior:clearAllSafes', false )
addEventHandler( 'interior:clearAllSafes', resourceRoot, function ()
	for dbid, obj in pairs( safeTable ) do
		clearSafe( dbid )
	end
end)

addEventHandler( 'onResourceStop', resourceRoot, function ()
	if exports.global:isResourceRunning( 'interior_load' ) then
		local safes = { }
		for dbid, obj in pairs( safeTable ) do
			local rot = getElementRotation( obj,'ZXY' )
			safes[ dbid ] = { getElementModel(obj), { getElementPosition(obj) }, getElementInterior(obj), rot+180, false, true }
		end
		exports.data:save( safes, 'interior:safeTable' )
	end
end )

addEventHandler( 'onResourceStart', resourceRoot, function ()
	if exports.global:isResourceRunning( 'interior_load' ) then
		local safes = exports.data:load( 'interior:safeTable' )
		if safes then
			for dbid, data in pairs( safes ) do
				addSafe( dbid, unpack(data) )
			end
		end
	end
end )





