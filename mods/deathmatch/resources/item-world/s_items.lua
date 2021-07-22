--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

items = exports['item-system']
function createItem(id, itemID, itemValue, ...)
	local o = createObject(...)
	if o then
		anticheat:changeProtectedElementDataEx(o, "id", id)
		anticheat:changeProtectedElementDataEx(o, "itemID", itemID)
		anticheat:changeProtectedElementDataEx(o, "itemValue", itemValue, itemValue ~= 1)

		return o
	else
		if dbExec(mysql:getConn('mta'), "DELETE FROM `worlditems` WHERE `id` = ?", id) then
			outputDebugString("Deleted bugged Item ID #"..id)
		else
			outputDebugString("Failed to delete bugged Item ID #"..id)
		end
		return false
	end
end

function updateItemValue(element, newValue)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		local id = tonumber(getElementData(element, "id")) or 0
		if dbExec(mysql:getConn('mta'), "UPDATE `worlditems` SET `itemvalue`=? WHERE `id`=?",newValue,id) then
			anticheat:changeProtectedElementDataEx(element, "itemValue", newValue)
			return true
		end
	end
	return false
end

function setData(element, key, value)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		local id = tonumber(getElementData(element, "id")) or 0
		local metadata = getElementData(element, "metadata") or {}
		metadata[key] = value

		if dbExec(mysql:getConn('mta'), "UPDATE `worlditems` SET `metadata`=? WHERE `id`=?", toJSON(metadata), id) then
			--anticheat:changeProtectedElementDataEx(element, "worlditemData."..tostring(key), value)
			anticheat:changeProtectedElementDataEx(element, "metadata", metadata)
			return true
		end
	end
	return false
end

function getData(element, key)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		local metadata = getElementData(element, "metadata") or {}
		return metadata[key]
	end
	return nil
end

function setPermissions(element, permissions)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		local id = tonumber(getElementData(element, "id")) or 0
		result = mysql:query_free("UPDATE `worlditems` SET `perm_use`='"..mysqL:escape_string(tostring(permissions.use)).."', `perm_move`='"..mysqL:escape_string(tostring(permissions.move)).."', `perm_pickup`='"..mysqL:escape_string(tostring(permissions.pickup)).."', `perm_use_data`='"..mysqL:escape_string(tostring(toJSON(permissions.useData))).."', `perm_move_data`='"..mysqL:escape_string(tostring(toJSON(permissions.moveData))).."', `perm_pickup_data`='"..mysqL:escape_string(tostring(toJSON(permissions.pickupData))).."' WHERE `id`='"..mysql:escape_string(tostring(id)).."'")
		if result then
			anticheat:changeProtectedElementDataEx(element, "worlditem.permissions", permissions)
			return true
		end
	end
	return false
end

function getPermissions(element)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		local perm = getElementData(element, "worlditem.permissions")
		if perm then
			return perm
		else
			return getPermissionsFromDB(element)
		end
	end
	return false
end

function getPermissionsFromDB(element)
	if getElementParent(getElementParent(element)) ~= getResourceRootElement(getThisResource()) then
		return false
	end
	id = tonumber(getElementData(element, "id")) or 0
	if id < 1 then return false end
	local permissions
	local result = mysql:query("SELECT `perm_use`, `perm_move`, `perm_pickup`, `perm_use_data`, `perm_move_data`, `perm_pickup_data` FROM `worlditems` WHERE `id`='"..mysql:escape_string(tostring(id)).."' LIMIT 1")
	while true do
		local row = mysql:fetch_assoc(result)
		if not row then break end
		permissions = { use = tonumber(row.perm_use), move = tonumber(row.perm_move), pickup = tonumber(row.perm_pickup), useData = fromJSON(row.perm_use_data), moveData = fromJSON(row.perm_move_data), pickupData = fromJSON(row.perm_pickup_data) }
	end
	anticheat:changeProtectedElementDataEx(element, "worlditem.permissions", permissions)
	mysql:free_result(result)
	return permissions
end

local function sqlDeleteObject( dbid )
	
end

-- delete an object by dbid, return true of deleted something, false otherwise.
function deleteOne( dbid, no_sql ) 
	local destroyed = false
	local object = exports.pool:getElement( 'object', dbid )
	if object then
		destroyed = destroyElement( object ) 
		if destroyed and not no_sql then
			dbExec( exports.mysql:getConn('mta'), "DELETE FROM worlditem WHERE id=? ", dbid )
		end
	end
	return destroyed
end

-- nil value will delete all itemss with given itemId, return number of objects deleted.
function deleteAll( id, value, no_sql ) 
	local count = 0
	for k, o in pairs( getElementsByType( "object", resourceRoot ) ) do
		local id_ = getElementData( o, "itemID" )
		if id_ == id then
			local value_ = getElementData( o, "itemValue" )
			if not value or ( tonumber(value) or value ) == ( tonumber(value_) or value_ ) then
				destroyElement( o )
				count = count + 1
			end
		end
	end
	if count > 0 and not no_sql then
		dbExec( exports.mysql:getConn('mta'), "DELETE FROM worlditems WHERE itemid=? "..( value and "AND itemvalue=? " or "" ) , id, value or nil )
	end
	return count
end
