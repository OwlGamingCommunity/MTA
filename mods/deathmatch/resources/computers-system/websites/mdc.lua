function www_mdc_gov( )
	local width, height = guiGetSize(internet_pane, false)

	setPageTitle("MDC")
	guiSetText(address_bar,"www.mdc.gov")
	bg = guiCreateStaticImage(0,0,width,height,"websites/colours/1.png",false,internet_pane)
	
	local logo = guiCreateStaticImage( ( width - 150 ) / 2, ( height - 150 ) / 2, 150, 150,"websites/images/lspd-logo.png",false,bg)
	local btn = guiCreateButton( ( width - 200 ) / 2, ( height + 170 ) / 2, 200, 50, "Mobile Data Computer\nLog In", false, bg )
	guiSetProperty(btn, "NormalTextColour", "EEEEEEEE")
	guiSetProperty(btn, "HoverTextColour", "FFFFFFFF")
	addEventHandler( "onClientGUIClick", btn,
		function( )
			closeComputerWindow()
			triggerEvent("mdc:loginW", localPlayer, true)
		end,
		false
	)
end
