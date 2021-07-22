function replaceModels()
	itemDFF = engineLoadDFF("blueberry-samra/truckstop.dff", 13295)
	engineReplaceModel(itemDFF, 13295)
	itemTXD = engineLoadTXD("blueberry-samra/truckstop.txd")
	engineImportTXD(itemTXD, 13295)
	col = engineLoadCOL("blueberry-samra/truckstop.col")
	engineReplaceCOL(col, 13295)
end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()),
     function()
         replaceModels()
         setTimer (replaceModels, 1000, 1)
end
)
