function truckStop()
	removeWorldModel(781, 10, 196, -267, 0)
	removeWorldModel(13295, 150, 207, -249, 10)
	removeWorldModel(13298, 150, 207, -249, 10)
	createObject(13295, 207.8062, -249.14700317387, 7.0935, 0, 0, 90)
end
addEventHandler("onResourceStart", root, truckStop)
