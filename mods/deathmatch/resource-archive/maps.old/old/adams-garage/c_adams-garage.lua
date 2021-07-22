-- ERMAGHERD PLS DONT STEEL M8

function hookItUpM8()
	-- Load up teh shitz
	bild = engineLoadDFF("adams-garage/files/ce_terminal1.dff", 13295)
	engineReplaceModel(bild, 13295)
	bildtxd = engineLoadTXD("adams-garage/files/ce_terminal.txd")
	engineImportTXD(bildtxd, 13295)
	bildcol = engineLoadCOL("adams-garage/files/ce_terminal1.col")
    engineReplaceCOL(bildcol, 13295)
end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()),
     function()
		--do dis cus sometime when u rerplace an shit it bug teh FUNK OUT so u double do do k?
         hookItUpM8()
         setTimer (hookItUpM8, 2000, 2)
end
)