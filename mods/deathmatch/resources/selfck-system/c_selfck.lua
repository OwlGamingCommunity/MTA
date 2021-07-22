local ckWindow = nil

function showCkMainUI()
	local logged = getElementData(getLocalPlayer(), "loggedin")
	local requested = getElementData(getLocalPlayer(), "ckstatus")
	local thePlayer = getLocalPlayer()
	local isMenuOpen = getElementData(thePlayer, "ckmenu")
	if requested~="requested" then
		if (logged==1) then    
			if (ckWindow==nil) then
				local screenW, screenH = guiGetScreenSize()
				GUIEditor = {
					label = {},
				}
				ckWindow = guiCreateWindow(741, 434, 416, 166, "Self CK Menu", false)
					guiWindowSetMovable(ckWindow, false)
					guiWindowSetSizable(ckWindow, false)
					guiSetAlpha(ckWindow, 0.87)
				lWelcome = guiCreateLabel(114, 25, 186, 16, "Welcome to the Self-CK system!", false, ckWindow)
					guiSetFont(lWelcome, "default-bold-small")
					guiLabelSetHorizontalAlign(lWelcome, "center", false)
				bCK = guiCreateButton(232, 128, 126, 18, "Next", false, ckWindow)
					addEventHandler("onClientGUIClick", bCK, displayWarning, true)
					guiSetProperty(bCK, "NormalTextColour", "FFAAAAAA")
				lCause = guiCreateLabel(111, 51, 199, 25, "Please explain your cause of death:", false, ckWindow)
				bClose = guiCreateButton(56, 128, 128, 18, "Cancel", false, ckWindow)
					addEventHandler("onClientGUIClick", bClose, closeMenu, true)
					guiSetProperty(bClose, "NormalTextColour", "FFAAAAAA")
				memo = guiCreateEdit(56, 76, 302, 40, "", false, ckWindow)
					addEventHandler( "onClientGUIClick", ckWindow,
						function( button, state )
							if button == "left" and state == "up" then
								if source == memo then
									guiSetInputEnabled( true )
								else
									guiSetInputEnabled( false )
								end
							end
						end
					)
				showCursor(true)
			else
				outputChatBox("DEBUG: CK window is not set to nil.", getLocalPlayer())
			end
		end
	else
		outputChatBox("You already have a pending Self-CK request, please use /cancelck to cancel your current one.", getLocalPlayer(), 255, 255, 0)
	end
end
addCommandHandler("selfck", showCkMainUI)

function displayWarning()
	local thePlayer = getLocalPlayer()
	guiSetVisible(ckWindow, false)
	GUIEditor = {
		label = {},
	}
	wConfirm = guiCreateWindow(786, 298, 370, 153, "Confirm your CK", false)
	guiWindowSetSizable(wConfirm, false)

	lWarning = guiCreateLabel(19, 38, 325, 20, "You are about to CK your character, '", false, wConfirm)
	lName = guiCreateLabel(227, 38, 167, 21, "N/A", false, wConfirm)
		guiSetText(lName, getPlayerName(thePlayer):gsub("_", " ") .. "'.")
	lConfirm = guiCreateLabel(141, 69, 182, 25, "Are you sure?", false, wConfirm)
	bYes = guiCreateButton(41, 104, 129, 30, "Yes", false, wConfirm)
		guiSetProperty(bYes, "NormalTextColour", "FFAAAAAA")
		addEventHandler("onClientGUIClick", bYes, showCKWarn, true)
	bNo = guiCreateButton(188, 104, 140, 31, "No", false, wConfirm)
		guiSetProperty(bNo, "NormalTextColour", "FFAAAAAA")
		addEventHandler("onClientGUIClick", bNo, closeWarning, true)
	lReason = guiCreateLabel(52, 58, 224, 17, "Reason:", false, wConfirm)
		guiSetAlpha(lReason, 0.00)
		guiSetFont(lReason, "default-bold-small")
		lMemo = guiCreateLabel(53, 0, 167, 15, "Error.", false, lReason)
		guiSetText(lMemo, guiGetText(memo))
end

function showCKWarn()
	local text = guiGetText(memo)
	if text~="" then
		guiSetVisible(wConfirm, false)
		local player = getLocalPlayer()
		triggerServerEvent("sendCKRequest", getLocalPlayer(), player, text)
		destroyElement(ckWindow)
		destroyElement(wConfirm)
		ckWindow = nil
	else
		outputChatBox("You did not enter a reason.", player)
	end
end

function closeMenu()
	destroyElement(ckWindow)
	ckWindow = nil
	showCursor(false)
end

function closeWarning()
	destroyElement(wConfirm)
	ckWindow = nil
	showCursor(false)
end