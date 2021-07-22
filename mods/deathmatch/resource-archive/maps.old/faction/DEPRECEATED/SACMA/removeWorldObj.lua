function cleanUp()
	removeWorldModel(4019, 50, 1777.9000244141, -1773.9000244141, 12.5) 
	removeWorldModel(4025, 50, 1777.9000244141, -1773.9000244141, 12.5)
	removeWorldModel(4215, 50, 1777.5999755859, -1775.0999755859, 36.700000762939)
end
addEventHandler("onClientResourceStart", resourceRoot, cleanUp)


 