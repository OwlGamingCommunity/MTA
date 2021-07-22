-- ITEM CREATOR BY MAXIME
function spawnItem (thePlayer, targetPlayerID, itemID, itemValue )
	--giveItem( targetPlayer, itemID, itemValue)
	executeCommandHandler ( "giveitem", thePlayer, targetPlayerID.." "..itemID.." "..itemValue )
end
addEvent("itemCreator:spawnItem", true)
addEventHandler("itemCreator:spawnItem", getRootElement(), spawnItem)