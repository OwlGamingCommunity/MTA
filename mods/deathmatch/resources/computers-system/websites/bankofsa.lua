---------------------
-- www.bankofsa.sa --
---------------------
function www_bankofsa_sa()
	local page_length = 500
	
	setPageTitle(internet_address_label, "Credit & Commerce Bank of San Andreas")
	guiSetText(address_bar,"www.bankofsa.sa")
	
	bg = guiCreateStaticImage(0,0,660,page_length,"websites/colours/14.png",false,internet_pane)
	
	local body = guiCreateStaticImage(105,0,450,500,"websites/colours/1.png",false,bg)
	local banner = guiCreateStaticImage(110,5,440,98,"websites/images/ccbosa-logo.png",false,bg)
	
	local link_1 = guiCreateLabel(123,107,33,14,"Offers",false,bg)
	guiSetFont(link_1,"default-small")
	guiLabelSetColor(link_1,0,51,153)
	
	local link_2 = guiCreateLabel(191,107,80,14,"Current Accounts",false,bg)
	guiSetFont(link_2,"default-small")
	guiLabelSetColor(link_2,0,51,153)
	
	local link_3 = guiCreateLabel(314,107,32,14,"Loans",false,bg)
	guiSetFont(link_3,"default-small")
	guiLabelSetColor(link_3,0,51,153)
	
	local link_4 = guiCreateLabel(387,107,56,14,"Investment",false,bg)
	guiSetFont(link_4,"default-small")
	guiLabelSetColor(link_4,0,51,153)
	
	local link_5 = guiCreateLabel(479,107,60,14,"Debit Cards",false,bg)
	guiSetFont(link_5,"default-small")
	guiLabelSetColor(link_5,0,51,153)
	
	local left_column = guiCreateStaticImage(110,125,145,360,"websites/colours/116.png",false,bg)
	local ad1 = guiCreateStaticImage(115,129,135,143,"websites/images/bank_ad1.png",false,bg)
	local ad2 = guiCreateStaticImage(115,276,135,143,"websites/images/bank_ad2.png",false,bg)
	
	local right_column = guiCreateStaticImage(260,125,290,360,"websites/colours/116.png",false,bg)
	local right_column_inner = guiCreateStaticImage(265,130,280,195,"websites/colours/1.png",false,bg)
	
	local title = guiCreateLabel(270,135,270,14,"Online Banking",false,bg)
	guiSetFont(title,"default-bold-small")
	guiLabelSetColor(title,0,51,153)
	
	local underline = guiCreateStaticImage(270,149,270,1,"websites/colours/116.png",false,bg)
	local text = guiCreateLabel(270,155,270,14,"Click here to open in a popup over a nonsecured connection!",false,bg)
	guiLabelSetColor(text,0,51,153)
	guiSetFont(text,"default-small")
	
	addEventHandler("onClientGUIClick",text,function()
		triggerServerEvent("bank:requestATMInterfacePIN", getLocalPlayer())
	end,false)
----------------------------------------------------------------------
	if(page_length>=397)then
		guiScrollPaneSetScrollBars(internet_pane,false,true)
		guiScrollPaneSetVerticalScrollPosition(internet_pane,0)
	else
		guiSetSize(bg,660,397,false)
		guiScrollPaneSetScrollBars(internet_pane, false, false)
	end
end
