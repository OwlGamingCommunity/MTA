function copyPosToClipboard( prepairedText)
	setClipboard( prepairedText ) 
end
addEvent("copyPosToClipboard",true)
addEventHandler("copyPosToClipboard", getLocalPlayer(),copyPosToClipboard )