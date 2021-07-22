--[[
x hasItem(obj, itemID, itemValue = nil ) -- returns true if the player has that item
x hasSpaceForItem(obj, itemID, itemValue) -- returns true if you can put more stuff in

x getItems(obj) -- returns an array of all items in { slot = { itemID, itemValue, index, protected, metadata } } table
x getCarriedWeight(obj) -- returns the current weight an element carries
x getMaxWeight(obj) -- returns the maximum weight the element is capable holding of
]]
local saveditems = {} -- client-side saved items


-- Recieve Items from the server
local function recieveItems( items )
	if items then
		-- workaround for MTA bandwith saving
		local arr = fromJSON( items )
		if arr then
			for k, v in ipairs( arr ) do
				arr[k][2] = tonumber(v[2]) or v[2]
				arr[k][3] = tonumber(v[3])
				arr[k][4] = tonumber(v[4])
				arr[k][5] = v[5]
			end
			saveditems[ source ] = arr
			return
		end
	end
	saveditems[ source ] = nil
end

addEvent( "recieveItems", true )
addEventHandler( "recieveItems", getRootElement( ), recieveItems )

-- checks if the element has that specific item
function hasItem(element, itemID, itemValue)
	if not saveditems[element] then
		return false, "Unknown"
	end
	
	for key, value in pairs(saveditems[element]) do
		if value[1] == itemID and ( not itemValue or itemValue == value[2] ) then
			return true, key, value[2], value[3], value[5]
		end
	end
	return false
end

-- checks if the element has space for adding a new item
function hasSpaceForItem(element, itemID, itemValue, metadata)
	if getItemWeight(itemID, itemValue or 1, metadata) > 20 and getElementType(element) == 'player' and exports.integration:isPlayerTrialAdmin(element, true) then
		return true
	end
	return getCarriedWeight(element) + getItemWeight(itemID, itemValue or 1, metadata) <= getMaxWeight(element)
end

-- count all instances of that object
function countItems( element, itemID, itemValue )
	if not saveditems[element] then
		return 0
	end
	
	local count = 0
	for key, value in pairs(saveditems[element]) do
		if value[1] == itemID and ( not itemValue or itemValue == value[2] ) then
			count = count + 1
		end
	end
	return count
end

-- returns a list of all items of that element
function getItems(element)
	if not saveditems[element] then
		return {}, "Unknown"
	end

	return saveditems[element]
end

-- returns the current weight an element carries
function getCarriedWeight(element)
	if not saveditems[element] then
		return 1000000, "Unknown" -- Obviously too large to pick anything further up :o Yet if it fails that might even be good since we assume "if not loaded, can't happen"
	end
	
	local weight = 0
	for key, value in ipairs(saveditems[element]) do
		weight = weight + getItemWeight(value[1], value[2], value[5])
	end
	return weight
end

local function getID(element)
	if getElementType(element) == "player" then -- Player
		return getElementData(element, "dbid")
	elseif getElementType(element) == "vehicle" then -- Vehicle
		return getElementData(element, "dbid")
	elseif getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("item-world")) then -- World Item
		return getElementData(element, "id")
	elseif getElementType(element) == "object" then -- Safe
		return getElementDimension(element)
	elseif getElementType(element) == "ped" then -- Ped
		return getElementData(element, "dbid")
	elseif getElementType(element) == "interior" then
		return getElementData(element, "dbid") -- Interior
	else
		return 0
	end
end

function getElementID(element)
	return getID(element)
end

-- returns the 'type' column content
local function getType(element)
	if getElementType(element) == "player" then -- Player
		return 1
	elseif getElementType(element) == "vehicle" then -- Vehicle
		return 2
	elseif getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("item-world")) then -- World Item
		return 3
	elseif getElementType(element) == "object" then -- Safe
		return 4
	elseif getElementType(element) == "ped" then -- Ped
		return 5
	elseif getElementType(element) == "interior" then -- Interior
		return 6
	else
		return 255
	end
end

function getMaxWeight(element)
	if getElementType( element ) == "player" then
		return getPlayerMaxCarryWeight( element )
	elseif getElementType( element ) == "vehicle" then
		if getID( element ) < 0 then
			return -1
		elseif getVehicleType( element ) == "BMX" then
			return 1
		elseif getVehicleType( element ) == "Bike" then
			return 10
		elseif isVan( element ) then
			return 80
		elseif isTruck( element ) then
			return 120
		elseif isSUV( element ) then
			return 75
		elseif isTrailer( element ) then
			return 350
		else
			return 20
		end
	elseif getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("item-world")) then -- World Item
		local itemID = getElementData(element, "itemID")
		local itemValue = getElementData(element, "itemValue")
		local metadata = getElementData(element, "metadata")
		return getItemWeightCapacity( itemID, itemValue, metadata )
	elseif getElementType( element ) == "interior" then
		return 500 -- mailboxes
	else
		return 20
	end
end

-- tell the server we're ready
addEventHandler( "onClientResourceStart", getResourceRootElement( ),
	function( )
		triggerServerEvent( "itemResourceStarted", getLocalPlayer( ) )
	end
)
