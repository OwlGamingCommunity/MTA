function requestEmail(id)
	if wEmail then
		closeEmailRequest()
	end
	guiSetInputEnabled ( true)
	showCursor(true)
	GUIEditor_Label = {}
	local width, height = 307, 160
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)
	
	wEmail = guiCreateWindow(x,y,width,height,"Update Security Email",false)
		guiWindowSetSizable(wEmail,false)
	GUIEditor_Label[1] = guiCreateLabel(13,26,207,19,"Please enter your email address:",false,wEmail)

	GUIEditor_Label[2] = guiCreateLabel(17,53,52,21,"Email:",false,wEmail)
		guiLabelSetVerticalAlign(GUIEditor_Label[2],"center")
		guiSetFont(GUIEditor_Label[2],"default-bold-small")
	eEmail1 = guiCreateEdit(79,52,209,22,"",false,wEmail)
	
	GUIEditor_Label[3] = guiCreateLabel(17,78,52,21,"Re-type:",false,wEmail)
		guiLabelSetVerticalAlign(GUIEditor_Label[3],"center")
		guiSetFont(GUIEditor_Label[3],"default-bold-small")
	eEmail2 = guiCreateEdit(79,78,209,22,"",false,wEmail)
	
	lMsg = guiCreateLabel(17,105,271,16,"This will be used to recover your password.",false,wEmail)
		guiLabelSetColor(lMsg,255,255,0)
		guiLabelSetHorizontalAlign(lMsg,"center",false)
		guiSetFont(lMsg,"default-small")
	
	bOK = guiCreateButton(17,126,138,25,"OK",false,wEmail)
	addEventHandler("onClientGUIClick", bOK, function ()
		if source == bOK then
			if guiGetText(eEmail1) == guiGetText(eEmail2) then
				if (guiGetText(eEmail1):match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")) then
					triggerServerEvent("requestEmail:saveEmail", getLocalPlayer(), id, guiGetText(eEmail1))
					guiSetText(lMsg, "Saved successfully!")
					guiLabelSetColor(lMsg,0,255,0)
					setTimer(function () closeEmailRequest() end, 1000, 1)
				else
					guiSetText(lMsg, "Invalid email address!")
					guiLabelSetColor(lMsg,255,255,0)
				end
			else
				guiSetText(lMsg, "Re-typed email doesn't match!")
				guiLabelSetColor(lMsg,255,255,0)
			end
		end
	end)
	
	bCancel = guiCreateButton(155,126,138,25,"CANCEL",false,wEmail)
	addEventHandler("onClientGUIClick", bCancel, function ()
		if source == bCancel then
			closeEmailRequest()
		end
	end)
	
	addEventHandler("onClientGUIChanged", getRootElement(), function ()
		guiSetText(lMsg, "")
	end)
end
addEvent("requestEmail:onPlayerLogin", true)
addEventHandler("requestEmail:onPlayerLogin", getRootElement(), requestEmail)

function closeEmailRequest()
	if wEmail then
		destroyElement(wEmail)
		wEmail = nil
	end
end