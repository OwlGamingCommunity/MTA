addEvent("bank:playAtmInsert", true)
addEventHandler("bank:playAtmInsert", root,
	function()
		playSound("soundFX/atm_insert.mp3")
	end
)

addEvent("bank:playAtmEject", true)
addEventHandler("bank:playAtmEject", root,
	function()
		playSound("soundFX/atm_eject.mp3")
	end
)

addEvent("bank:playAtmWithdraw", true)
addEventHandler("bank:playAtmWithdraw", root,
	function()
		playSound(":shop-system/playBuySound.mp3")
	end
)

addEvent("bank:playAtmError", true)
addEventHandler("bank:playAtmError", root,
	function()
		playSound("soundFX/atm_error.mp3")
	end
)