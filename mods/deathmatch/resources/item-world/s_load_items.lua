function setElementData(...)
	return anticheat:changeProtectedElementDataEx(...)
end

local loadedWorldItems = 0
local totalWorldItems = 0
local percent
function loadOneWorldItem(row)
	if row then
		local id = tonumber(row["id"])
		local itemID = tonumber(row["itemid"])
		local itemValue = tonumber(row["itemvalue"]) or row["itemvalue"]
		local x = tonumber(row["x"])
		local y = tonumber(row["y"])
		local z = tonumber(row["z"])
		local dimension = tonumber(row["dimension"])
		local interior = tonumber(row["interior"])
		local rx2 = tonumber(row["rx"]) or 0
		local ry2 = tonumber(row["ry"]) or 0
		local rz2 = tonumber(row["rz"]) or 0
		local creator = tonumber(row["creator"])
		local createdDate = tostring(row["creationdate"])
		local protected = tonumber(row["protected"])
		local permUse = tonumber(row["perm_use"])
		local permMove = tonumber(row["perm_move"])
		local permPickup = tonumber(row["perm_pickup"])
		local permUseData = fromJSON(type(row["perm_use_data"])== "string" and row["perm_use_data"] or "")
		local permMoveData = fromJSON(type(row["perm_move_data"])== "string" and row["perm_move_data"] or "")
		local permPickupData = fromJSON(type(row["perm_pickup_data"])== "string" and row["perm_pickup_data"] or "")
		local useExactValues = tonumber(row["useExactValues"])
		local metadata = type(row["metadata"]) == "string" and fromJSON(row["metadata"]) or nil
		if itemID < 0 then
			itemID = -itemID
			local modelid = 2969
			if itemValue == 100 then
				modelid = 1242
			elseif itemValue == 42 then
				modelid = 2690
			else
				modelid = weaponmodels[itemID]
			end
		
			local obj = createItem(id, -itemID, itemValue, modelid, x, y, z - 0.1, 75, -10, rz2)
			exports.pool:allocateElement(obj)
			setElementDimension(obj, dimension)
			setElementInterior(obj, interior)
			setElementData(obj, "creator", creator)
			setElementData(obj, "createdDate", createdDate)
			
			if protected and protected ~= 0 then
				setElementData(obj, "protected", protected)
			end

			if metadata then
				anticheat:changeProtectedElementDataEx(obj, "metadata", metadata)
			end
		else
			local modelid = exports['item-system']:getItemModel(itemID, itemValue, metadata)
			
			local rx = 0
			local ry = 0
			local rz = 0
			local zoffset = 0

			if useExactValues ~= 1 then
				rx, ry, rz, zoffset = exports['item-system']:getItemRotInfo(itemID)
			end
			local obj = createItem(id, itemID, itemValue, modelid, x, y, z + ( zoffset or 0 ), rx+rx2, ry+ry2, rz+rz2)
			
			if isElement(obj) then
				exports.pool:allocateElement(obj, id, true)
				setElementDimension(obj, dimension)
				setElementInterior(obj, interior)
				setElementData(obj, "creator", creator)
				setElementData(obj, "createdDate", createdDate)
				
				if protected and protected ~= 0 then
					setElementData(obj, "protected", protected)
				end
				if useExactValues ~= 0 then
					setElementData(obj, "useExactValues", true)
				end

				local permissions = { use = permUse, move = permMove, pickup = permPickup, useData = permUseData, moveData = permMoveData, pickupData = permPickupData }
				anticheat:changeProtectedElementDataEx(obj, "worlditem.permissions", permissions)

				if metadata then
					anticheat:changeProtectedElementDataEx(obj, "metadata", metadata)
				end
				
				local scale = exports['item-system']:getItemScale(itemID, itemValue, metadata)
				if scale then
					setObjectScale(obj, scale)
				end
				
				local dblSided = exports['item-system']:getItemDoubleSided(itemID, itemValue)
				if dblSided then
					setElementDoubleSided(obj, dblSided)
				end
			else
				outputDebugString(id .. "/" .. itemID .. "/" .. itemValue .. "/" .. modelid)
			end
		end
	end
	
	loadedWorldItems = loadedWorldItems + 1
	if loadedWorldItems >= totalWorldItems then
		if getRandomPlayer() then
			triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading world items', { max=totalWorldItems, cur=totalWorldItems } )
		end
		restartResource(getResourceFromName("item-texture"))
	elseif getRandomPlayer() and percent ~= math.ceil( loadedWorldItems/totalWorldItems*100 ) then
		percent = math.ceil( loadedWorldItems/totalWorldItems*100 )
		triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading world items', { max=totalWorldItems, cur=loadedWorldItems } )
	end
end

local mysql = exports.mysql
local timerDelay = 50
function loadWorldItems()
	local ticks = getTickCount( )
	
	local itemInactivityScannerMode = tonumber(get("inactivityscanner_items"))
	--outputDebugString("itemInactivityScannerMode="..tostring(itemInactivityScannerMode))
	--[[
		MODES:
		0 - off
		1 - delete all items after 30 days
		2 - delete exterior items only after 30 days (avoid deleting interior items)
		Storage items ID 81 (fridge), 103 (fridge), 223 (storage generic) and 231 (shipping container) are excempt from deletion
		Other excempt items: 169 (keyless digital door lock)
		Notes (ID 72) will delete after 3 days.
	]]
	if itemInactivityScannerMode then
		if itemInactivityScannerMode == 1 then
			outputDebugString("Deleting all unprotected 30+ days old exterior and interior items (mode 1)")
			dbExec(mysql:getConn('mta'), "DELETE FROM `worlditems` WHERE `protected`='0' AND `itemID` NOT IN(81, 103, 169, 223, 231) AND ( (DATEDIFF(NOW(), creationdate) > 30 ) OR (DATEDIFF(NOW(), creationdate) > 3 AND `itemID` = 72) ) " )
		elseif itemInactivityScannerMode == 2 then
			outputDebugString("Deleting all unprotected 30+ days old exterior items (mode 2)")
			dbExec(mysql:getConn('mta'), "DELETE FROM `worlditems` WHERE `protected`='0' AND `itemID` NOT IN(81, 103, 169, 223, 231) AND (interior=0) AND ( (DATEDIFF(NOW(), creationdate) > 30 ) OR (DATEDIFF(NOW(), creationdate) > 3 AND `itemID` = 72) ) " )
		end
	end

	dbExec(mysql:getConn('mta'), "DELETE FROM `worlditems` WHERE `protected`='0' AND `itemID` NOT IN(81, 103, 169) AND (interior=0) AND ( (DATEDIFF(NOW(), creationdate) > 30 ) OR (DATEDIFF(NOW(), creationdate) > 3 AND `itemID` = 72) ) " )
	dbQuery(function(qh)
		local res, rows, err = dbPoll(qh,0)
		if rows > 0 then
			for k,v in pairs(res) do
				totalWorldItems = totalWorldItems + 1
				setTimer(loadOneWorldItem, timerDelay, 1, v)
				timerDelay = timerDelay + 1
			end
			outputDebugString("[ITEM WORLD] Loading "..(timerDelay/50-1).." world items will be finished in approximately "..tostring(math.ceil((timerDelay/1000)/60)).." minutes.")
		end
	end, mysql:getConn('mta'), "SELECT * FROM worlditems")
end
addEventHandler("onResourceStart", resourceRoot, loadWorldItems)
