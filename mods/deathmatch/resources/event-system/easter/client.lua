addEventHandler("onClientResourceStart", resourceRoot, function()
	--bunny
	local bunnySkin = engineLoadTXD("easter/bunny.txd")
	engineImportTXD(bunnySkin, 245)
	local bunnySkin = engineLoadDFF("easter/bunny.dff")
	engineReplaceModel(bunnySkin, 245)

	local eggModel = engineLoadTXD("easter/egg.txd")
	engineImportTXD(eggModel, 3082)
	local eggModel = engineLoadDFF("easter/egg.dff")
	engineReplaceModel(eggModel, 3082)
end)
