
function getItemPropertiesData(object)
	if not object then return end

	local creatorName
	local creator = tonumber(getElementData(object, "creator")) or 0
	if creator > 0 then
		creatorName = exports.global:getCharacterNameFromID(creator)
	end

	local createdDate = getElementData(object, "createdDate")
	if not createdDate then
		local timestamp = getElementData(object, "createdTimestamp")
		if timestamp then
			createdDate = exports.datetime:formatTimeInterval(timestamp)
		end
	end

	local protected = getElementData(object, "protected")
	if protected and protected ~= 0 then
		protected = true
	else
		protected = false
	end

	triggerClientEvent(client, "item-world:fillItemPropertiesGUI", getResourceRootElement(), object, creatorName, createdDate, protected)
end
addEvent("item-world:getItemPropertiesData", true)
addEventHandler("item-world:getItemPropertiesData", getResourceRootElement(), getItemPropertiesData)

function saveItemProperties(object, use, useData, move, moveData, pickup, pickupData, exactValues)
	--blind save
	if not object or not isElement(object) then return end
	if getElementParent(getElementParent(object)) == getResourceRootElement(getResourceFromName("item-world")) then
		local id = tonumber(getElementData(object, "id"))
		if id then
			use = tonumber(use) or 1
			move = tonumber(move) or 1
			pickup = tonumber(pickup) or 1
			useData = toJSON(useData or {})
			moveData = toJSON(moveData or {})
			pickupData = toJSON(pickupData or {})
			if exactValues then
				exactValues = 1
				setElementData(object, "useExactValues", true)
			else
				removeElementData(object, "useExactValues")
				exactValues = 0
			end
			local itemName = exports['item-system']:getItemName(tonumber(getElementData(object, "itemID")), getElementData(object, "itemValue"))

			local permissions = {use = use, move = move, pickup = pickup, useData = fromJSON(useData), moveData = fromJSON(moveData), pickupData = fromJSON(pickupData)}
			exports.anticheat:changeProtectedElementDataEx(object, "worlditem.permissions", permissions)

			local result = dbExec(mysql:getConn('mta'), "UPDATE `worlditems` SET perm_use=?,perm_move=?,perm_pickup=?,perm_use_data=?,perm_move_data=?,perm_pickup_data=?,useExactValues=? WHERE id = ?", use, move, pickup, useData, moveData, pickupData, exactValues, id)
			if result then
				outputChatBox("Saved properties for '"..tostring(itemName).."'.", client, 0,255,0)
			else
				outputChatBox("Failed to save properties for '"..tostring(itemName).."'.", client, 255,0,0)
				outputChatBox("If the problem persists, please make a bug report.", client, 255,0,0)
			end
		end
	end
end
addEvent("item-world:saveItemProperties", true)
addEventHandler("item-world:saveItemProperties", getResourceRootElement(), saveItemProperties)