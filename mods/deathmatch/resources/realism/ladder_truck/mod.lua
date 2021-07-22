rootElement = getRootElement()
function loadLad(resource)
    if resource ~= getThisResource() then return end
	-- vehicle itself
	txd9971 = engineLoadTXD('ladder_truck/ladder/firelad.txd')
	engineImportTXD(txd9971, 544)
	dff9971 = engineLoadDFF('ladder_truck/ladder/firelad.dff', 0)
	-- ladder parts
	dff1 = engineLoadDFF('ladder_truck/ladder/1.dff', 0)
	dff2 = engineLoadDFF('ladder_truck/ladder/2.dff', 0)
	dff3 = engineLoadDFF('ladder_truck/ladder/3.dff', 0)
	-- ladder col
	col1 = engineLoadCOL('ladder_truck/ladder/1.col')
	col2 = engineLoadCOL('ladder_truck/ladder/2.col')
	col3 = engineLoadCOL('ladder_truck/ladder/3.col')
	-- ladder txd
	tex1 = engineLoadTXD('ladder_truck/ladder/texture.txd')
	engineImportTXD(tex1, 1644)
	engineImportTXD(tex1, 3007)
	engineImportTXD(tex1, 3008)
	-- ladder col
	engineReplaceCOL(col1, 1644)
	engineReplaceCOL(col2, 3007)
	engineReplaceCOL(col3, 3008)
	-- vehicle
	engineReplaceModel(dff9971, 544)
	-- ladder
	engineReplaceModel(dff1, 1644)
	engineReplaceModel(dff2, 3007)
	engineReplaceModel(dff3, 3008)
end
addEventHandler('onClientResourceStart', rootElement, loadLad)