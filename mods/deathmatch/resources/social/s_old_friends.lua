function declineFriendRequest(targetPlayer)
	--outputChatBox(getPlayerName(source):gsub("_", " ") .. " declined your friend request.", targetPlayer, 255, 0, 0)
	outputChatBox(" You have declined ".. getPlayerName(targetPlayer):gsub("_", " ") .."'s friend request.", source, 255, 0, 0)
end
addEvent("declineFriendSystemRequest", true)
addEventHandler("declineFriendSystemRequest", getRootElement(), declineFriendRequest)
