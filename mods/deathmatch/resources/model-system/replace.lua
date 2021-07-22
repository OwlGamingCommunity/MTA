addEventHandler('onClientResourceStart', resourceRoot,
    function()
        -- local txd = engineLoadTXD('sniper.txd',true)
        -- engineImportTXD(txd, 358)
        -- local dff = engineLoadDFF('sniper.dff', 358)
        -- engineReplaceModel(dff, 358)

        -- local txd2 = engineLoadTXD('suitcase.txd',true)
        -- engineImportTXD(txd2, 324  )
        -- local dff2 = engineLoadDFF('suitcase.dff', 324  )
        -- engineReplaceModel(dff2, 324  )

		-- local txd = engineLoadTXD('atm.txd',true)
        -- engineImportTXD(txd, 2942  )
        -- local dff2 = engineLoadDFF('atm.dff', 2942  )
        -- engineReplaceModel(dff2, 2942  )

		local txd = engineLoadTXD('cocaine.txd',true)
        engineImportTXD(txd, 1575  )
        local dff = engineLoadDFF('cocaine.dff', 1575  )
        engineReplaceModel(dff, 1575  )

		local txd = engineLoadTXD('cocaine.txd',true)
        engineImportTXD(txd, 1579  )
        local dff = engineLoadDFF('cocaine.dff', 1579  )
        engineReplaceModel(dff, 1579  )

		local txd = engineLoadTXD('mari.txd',true)
        engineImportTXD(txd, 3044   )
        local dff = engineLoadDFF('cocaine.dff', 3044   )
        engineReplaceModel(dff, 3044   )

		local txd = engineLoadTXD('pill.txd',true)
        engineImportTXD(txd, 1576  )
        local dff = engineLoadDFF('pill.dff', 1576  )
        engineReplaceModel(dff, 1576  )

		local txd = engineLoadTXD('laptop.txd',true)
        engineImportTXD(txd, 2886  )
        local dff = engineLoadDFF('laptop.dff', 2886  )
        engineReplaceModel(dff, 2886  )

        local txd = engineLoadTXD('dog.txd',true) -- PD DOG
        engineImportTXD(txd, 300  )
        local dff = engineLoadDFF('dog.dff', 300  )
        engineReplaceModel(dff, 300  )
		
		local txd = engineLoadTXD('labrador.txd',true) -- PLAYER DOG
        engineImportTXD(txd, 2351  )
        local dff = engineLoadDFF('labrador.dff', 2351  )
        engineReplaceModel(dff, 2351  )

		-- local txd = engineLoadTXD('tv.txd',true)
        -- engineImportTXD(txd, 1518  )
        -- local dff = engineLoadDFF('tv.dff', 1518  )
        -- engineReplaceModel(dff, 1518  )

		-- local txd = engineLoadTXD('cellphone.txd',true)
        -- engineImportTXD(txd, 330   )
        -- local dff = engineLoadDFF('cellphone.dff', 330   )
        -- engineReplaceModel(dff, 330   )

		local txd = engineLoadTXD('enterable-barracks.txd',true)
        engineImportTXD(txd, 433   )
        local dff = engineLoadDFF('enterable-barracks.dff', 433   )
        engineReplaceModel(dff, 433   )
    end
)
