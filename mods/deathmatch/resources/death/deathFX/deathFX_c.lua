--MAXIME
local deathSound = nil
local ckSound = nil
function playerWasted (thePlayer)
	deathSound = playSound("deathFX/wasted.mp3",false)
	setSoundVolume(deathSound, 0.2)
	setGameSpeed (0.1)
end
addEventHandler ( "onClientPlayerWasted", getLocalPlayer(), playerWasted )

function playerSpawn()
	if deathSound and isElement(deathSound) then
		destroyElement(deathSound)
	end
	setGameSpeed (1)
end
addEventHandler ( "onClientPlayerSpawn", getLocalPlayer(), playerSpawn )

local gui = {}
function showCkWindow()
	triggerServerEvent("updateCharacters", localPlayer)
	setTimer(function()
		triggerEvent("accounts:logout", localPlayer)
		setGameSpeed (1)
		closeCkWindow()

		ckSound = playSound("deathFX/cked.mp3",false)
		setSoundVolume(ckSound, 0.4)

		triggerEvent("es-system:closeRespawnButton", localPlayer)

		gui.window = guiCreateStaticImage(0, 0, 350, 300, ":resources/window_body.png", false)
		exports.global:centerWindow(gui.window)

		gui.label = guiCreateLabel(0.05, 0.05, 0.9, 0.7, string.gsub(getPlayerName(localPlayer), "_", " ").." has just been CK-ed!\n\nCK (Character killing) is the most uncommon way a character is killed in game and is used only in situations where it's needed. \n\nWhen you are killed from a CK, it's permanent and the only way to get the assests that are owned by this character back is from a stat transfer perk in Premium Features (F10).\n\nYou are now redirected to character selection screen as it was the only option you had.", true, gui.window)
		guiLabelSetHorizontalAlign(gui.label, "left", true)
		guiLabelSetVerticalAlign(gui.label, "center", true)

		gui.bClose = guiCreateButton(0.05, 0.8, 0.9, 0.15, "OK", true, gui.window)
		addEventHandler("onClientGUIClick", gui.bClose,
		function ()
			if source == gui.bClose then
				closeCkWindow()
			end
		end, false)
	end, 2000, 1)
end
addEvent("showCkWindow", true)
addEventHandler ( "showCkWindow", localPlayer, showCkWindow )

function closeCkWindow()
	if gui.window and isElement(gui.window) then
		destroyElement(gui.window)
		--setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
	end
end
