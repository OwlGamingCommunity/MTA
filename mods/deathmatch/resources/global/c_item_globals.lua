function hasSpaceForItem( ... )
	return call( getResourceFromName( "item-system" ), "hasSpaceForItem", ... )
end

function hasItem( element, itemID, itemValue )
	return call( getResourceFromName( "item-system" ), "hasItem", element, itemID, itemValue )
end

function getItemName( itemID, itemValue, metadata )
	return call( getResourceFromName( "item-system" ), "getItemName", itemID, itemValue, metadata )
end
