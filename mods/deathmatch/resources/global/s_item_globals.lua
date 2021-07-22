function hasSpaceForItem( ... )
	return call( getResourceFromName( "item-system" ), "hasSpaceForItem", ... )
end

function hasItem( element, itemID, itemValue )
	return call( getResourceFromName( "item-system" ), "hasItem", element, itemID, itemValue )
end

function giveItem( element, itemID, itemValue, metadata )
	return call( getResourceFromName( "item-system" ), "giveItem", element, itemID, itemValue, false, true, metadata )
end

function takeItem( element, itemID, itemValue )
	return call( getResourceFromName( "item-system" ), "takeItem", element, itemID, itemValue )
end
