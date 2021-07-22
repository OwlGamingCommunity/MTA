---------------------------------
-- EAST SKY AIRLINES HOME PAGE --
---------------------------------

-- Website owner's forum name: Exciter
-- Website owner's Character's name: William Fernley
-- Last update: 01/04/2012 (DD/MM/YYYY)

local content, popup, popup2, formFrom, formTo, formPax, formDate, finalPrice, discountLink, listprice, discountCode

local function www_ippc_sa_themes_main(desiredLength)
	
	local skipOrg

	--if no active ippc session, create a new by defining necessary globals
	if not ippcSession then
		isFAA = false
		isFAALeader = false
		local isMember, rankID = exports.factions:isPlayerInFaction(localPlayer, 47)
		local isLeader = exports.factions:hasMemberPermissionTo(localPlayer, 47, "add_member")
		if isMember then
			isFAA = true
			if isLeader then
				isFAALeader = true
			end
		end
		triggerServerEvent("ippc:web:getSessionData", resourceRoot)
		ippcSession = true
		skipOrg = true
	end

	local page_length
	if desiredLength then
		page_length = tonumber(desiredLength)
	else
		page_length = 396
	end
	
	-- Webpage Properties
	---------------------
	--local page_length = 396 -- Set the total length of your webpage in px (Max page height is 765px). This will determine whether your page will have a vertical scroll bar. 
	local page_width = 660
	page_width, page_length = guiGetSize(internet_pane, false)
	setPageTitle("IPPC") -- This text is displayed at the top of the browser window when the page is opened. It is the same as the <title> tag used in the meta of a real webpage. Only change the text between the quotation marks.
	guiSetText(address_bar,"www.ippc.sa/themes/main") -- The url of the page. This should be the same as the function name but with the original "."s and "/". Example www.google.com.
	
	----------------------------
	-- Page Background Colour --
	----------------------------
	bg = guiCreateStaticImage(0,0,page_width,page_length,"websites/colours/1.png",false,internet_pane)
	local wrapper_width = page_width
	local wrapper_length = page_length - 20
	local content_length = wrapper_length - 50
	local wrapper = guiCreateStaticImage(0,0,wrapper_width,wrapper_length,"websites/colours/1.png",false,bg)
	
	------------
	-- Header --
	------------
	local header = guiCreateStaticImage(0,0,wrapper_width,50,"websites/colours/36.png",false,wrapper)
	local logo = guiCreateStaticImage(10,5,40,40,"websites/images/faa.png",false,header)
	--local logo = guiCreateStaticImage(0,0,565,100,"websites/images/eastsky.png",false,header)
	local headertxt = guiCreateLabel(60,10,80,50,"IPPC",false,header)
		guiSetFont(headertxt, guiCreateFont(":fonts/helveticastrong.ttf", 30))
	local headertxt2 = guiCreateLabel(140,27,170,25,"Internet Pilot Planning Center",false,header)

	local usertxt1 = guiCreateLabel(wrapper_width-100,5,100,15,"Logged in as",false,header)
		guiSetFont(usertxt1, "default-small")
	local usertxt2 = guiCreateLabel(wrapper_width-100,20,100,15,tostring(getPlayerName(getLocalPlayer()):gsub("_", " ")),false,header)
		guiSetFont(usertxt2, "default-small")
	orgLabel = guiCreateLabel(wrapper_width-100,35,100,15,"",false,header)
		guiSetFont(orgLabel, "default-small")

	----------
	-- Menu --
	----------
	local nav = guiCreateStaticImage(0,50,100,500,"websites/colours/13.png",false,wrapper)
	
	local menu_link1_txt = guiCreateLabel(10,5,80,20,"Home",false,nav)
		guiLabelSetColor(menu_link1_txt,255,255,255)
		guiSetFont(menu_link1_txt, "default-bold-small")

	addEventHandler("onClientMouseEnter",menu_link1_txt,function()
		guiLabelSetColor(menu_link1_txt,255,187,0)
	end,false)
	addEventHandler("onClientMouseLeave",menu_link1_txt,function()
		guiLabelSetColor(menu_link1_txt,255,255,255)
	end,false)
	addEventHandler("onClientGUIClick",menu_link1_txt,function()
		local url = tostring("www.ippc.sa")
		get_page(url)
	end,false)

	local menu_link2_txt = guiCreateLabel(10,30,80,20,"Flights",false,nav)
	guiLabelSetColor(menu_link2_txt,255,255,255)
	guiSetFont(menu_link2_txt, "default-bold-small")

	addEventHandler("onClientMouseEnter",menu_link2_txt,function()
		guiLabelSetColor(menu_link2_txt,255,187,0)
	end,false)
	addEventHandler("onClientMouseLeave",menu_link2_txt,function()
		guiLabelSetColor(menu_link2_txt,255,255,255)
	end,false)
	addEventHandler("onClientGUIClick",menu_link2_txt,function()
		local url = tostring("www.ippc.sa/flights")
		get_page(url)
	end,false)

	local menu_link3_txt = guiCreateLabel(10,55,80,20,"New Flightplan",false,nav)
	guiLabelSetColor(menu_link3_txt,255,255,255)
	guiSetFont(menu_link3_txt, "default-bold-small")

	addEventHandler("onClientMouseEnter",menu_link3_txt,function()
		guiLabelSetColor(menu_link3_txt,255,187,0)
	end,false)
	addEventHandler("onClientMouseLeave",menu_link3_txt,function()
		guiLabelSetColor(menu_link3_txt,255,255,255)
	end,false)
	addEventHandler("onClientGUIClick",menu_link3_txt,function()
		local url = tostring("www.ippc.sa/fpl")
		get_page(url)
	end,false)

	local menu_link4_txt = guiCreateLabel(10,80,80,20,"NOTAMs",false,nav)
	guiLabelSetColor(menu_link4_txt,255,255,255)
	guiSetFont(menu_link4_txt, "default-bold-small")

	addEventHandler("onClientMouseEnter",menu_link4_txt,function()
		guiLabelSetColor(menu_link4_txt,255,187,0)
	end,false)
	addEventHandler("onClientMouseLeave",menu_link4_txt,function()
		guiLabelSetColor(menu_link4_txt,255,255,255)
	end,false)
	addEventHandler("onClientGUIClick",menu_link4_txt,function()
		local url = tostring("www.ippc.sa/notam")
		get_page(url)
	end,false)
	
	local menu_link5_txt = guiCreateLabel(10,105,80,20,"Charts",false,nav)
	guiLabelSetColor(menu_link5_txt,255,255,255)
	guiSetFont(menu_link5_txt, "default-bold-small")

	addEventHandler("onClientMouseEnter",menu_link5_txt,function()
		guiLabelSetColor(menu_link5_txt,255,187,0)
	end,false)
	addEventHandler("onClientMouseLeave",menu_link5_txt,function()
		guiLabelSetColor(menu_link5_txt,255,255,255)
	end,false)
	addEventHandler("onClientGUIClick",menu_link5_txt,function()
		local url = tostring("www.ippc.sa/charts")
		get_page(url)
	end,false)
	
	local menu_link6_txt = guiCreateLabel(10,130,80,20,"My Profile",false,nav)
	guiLabelSetColor(menu_link6_txt,255,255,255)
	guiSetFont(menu_link6_txt, "default-bold-small")

	addEventHandler("onClientMouseEnter",menu_link6_txt,function()
		guiLabelSetColor(menu_link6_txt,255,187,0)
	end,false)
	addEventHandler("onClientMouseLeave",menu_link6_txt,function()
		guiLabelSetColor(menu_link6_txt,255,255,255)
	end,false)
	addEventHandler("onClientGUIClick",menu_link6_txt,function()
		local url = tostring("www.ippc.sa/profile")
		get_page(url)
	end,false)

	menu_link7_txt = guiCreateLabel(10,155,80,20,"Airline",false,nav)
	guiLabelSetColor(menu_link7_txt,255,255,255)
	guiSetFont(menu_link7_txt, "default-bold-small")

	addEventHandler("onClientMouseEnter",menu_link7_txt,function()
		guiLabelSetColor(menu_link7_txt,255,187,0)
	end,false)
	addEventHandler("onClientMouseLeave",menu_link7_txt,function()
		guiLabelSetColor(menu_link7_txt,255,255,255)
	end,false)
	addEventHandler("onClientGUIClick",menu_link7_txt,function()
		local url = tostring("www.ippc.sa/airline")
		get_page(url)
	end,false)

	guiSetVisible(menu_link7_txt, false)

	menu_link8_txt = guiCreateLabel(10,180,80,20,"Gates",false,nav)
	guiLabelSetColor(menu_link8_txt,255,255,255)
	guiSetFont(menu_link8_txt, "default-bold-small")

	addEventHandler("onClientMouseEnter",menu_link8_txt,function()
		guiLabelSetColor(menu_link8_txt,255,187,0)
	end,false)
	addEventHandler("onClientMouseLeave",menu_link8_txt,function()
		guiLabelSetColor(menu_link8_txt,255,255,255)
	end,false)
	addEventHandler("onClientGUIClick",menu_link8_txt,function()
		local url = tostring("www.ippc.sa/gates")
		get_page(url)
	end,false)

	guiSetVisible(menu_link8_txt, false)

	--[[
	local menu_link8_txt = guiCreateLabel(10,180,80,20,"FAA",false,nav)
	guiLabelSetColor(menu_link8_txt,255,255,255)
	guiSetFont(menu_link8_txt, "default-bold-small")

	addEventHandler("onClientMouseEnter",menu_link8_txt,function()
		guiLabelSetColor(menu_link8_txt,255,187,0)
	end,false)
	addEventHandler("onClientMouseLeave",menu_link8_txt,function()
		guiLabelSetColor(menu_link8_txt,255,255,255)
	end,false)
	addEventHandler("onClientGUIClick",menu_link8_txt,function()
		local url = tostring("www.faa.gov")
		get_page(url)
	end,false)
	--]]
	
	-------------
	-- Content --
	-------------
	content = guiCreateStaticImage(100,50,wrapper_width-100,content_length,"websites/colours/1.png",false,wrapper)
	
	------------
	-- Footer --
	------------
	local footer = guiCreateStaticImage(50,wrapper_length + 10,wrapper_width,20,"websites/colours/1.png",false,bg)
	local footer_txt = guiCreateLabel(0,0,wrapper_width,20,"IPPC service provided by FAA.",false,footer)
	guiSetFont(footer_txt, "default-small")
	guiLabelSetColor(footer_txt,50,50,50)
	guiLabelSetHorizontalAlign(footer_txt, "center", false)

	if not skipOrg then
		www_ippc_sa_scripts_updateorg()
	end
	
	----------------------------------------------- End of webpage design -- Do not edit below this line. -----------------------------------------------
	
	if(page_length>=397)then
		guiScrollPaneSetScrollBars(bg,false,true)
	else
		guiSetSize(bg,660,397,false)
		guiScrollPaneSetScrollBars(internet_pane, false, false)
	end
	
end

function www_ippc_sa()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"Welcome to IPPC",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	local para1 = guiCreateLabel(10,30,400,240, "The IPPC is a online tool for pilots, offered by the FAA.\n\nThis site gives pilots easy access to important and useful information.\n\nPilots can use the IPPC to create, edit and view flightplans which is submitted directly to the FAA and air traffic controllers.",false,content)
		guiSetFont(para1, "clear-normal")
		guiLabelSetColor(para1,0,0,0)
		guiLabelSetHorizontalAlign(para1, "left", true)	
end

function www_ippc_sa_flights()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/flights") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"Flights",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	local para1 = guiCreateLabel(10,30,50,20, "Show: ",false,content)
		guiSetFont(para1, "clear-normal")
		guiLabelSetColor(para1,0,0,0)
		guiLabelSetHorizontalAlign(para1, "left", true)	

	selectFlights = guiCreateComboBox(60,30,250,80,"",false,content)
		local item = guiComboBoxAddItem(selectFlights, "All")
			guiComboBoxSetSelected(selectFlights, item)
		guiComboBoxAddItem(selectFlights, "My flights")

	selectFlightsTime = guiCreateComboBox(320,30,100,67,"",false,content)
		local item = guiComboBoxAddItem(selectFlightsTime, "upcoming")
			guiComboBoxSetSelected(selectFlightsTime, item)
		guiComboBoxAddItem(selectFlightsTime, "past")

	flightsGrid = guiCreateGridList(10, 70, 540, 250, false, content)
		guiGridListAddColumn(flightsGrid, "Flight", 0.155)
		guiGridListAddColumn(flightsGrid, "ETD", 0.2)
		guiGridListAddColumn(flightsGrid, "From", 0.16)
		guiGridListAddColumn(flightsGrid, "To", 0.16)
		guiGridListAddColumn(flightsGrid, "Airline", 0.2)
		guiGridListAddColumn(flightsGrid, "ETA", 0.07)

	local row = guiGridListAddRow(flightsGrid)
		guiGridListSetItemText(flightsGrid, row, 2, "Loading...", false, false)

	triggerServerEvent("ippc:web:fetchAirlines", resourceRoot, "flights")
end

function www_ippc_sa_fpl()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/fpl") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"Flightplan",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	fplErrorLabel = guiCreateLabel(10,30,540,20,"",false,content)
		guiSetFont(fplErrorLabel, "default-bold-small")
		guiLabelSetColor(fplErrorLabel,255,0,0)
		guiLabelSetHorizontalAlign(fplErrorLabel, "left", true)

	local fields = {
		{"from", "From:", "Use 3-letter designation if available (ex.: LSA)."},
		{"to", "To:", "Use 3-letter designation if available (ex.: SFA)."},
		{"etd", "Departure time:", "YYYY-MM-DD HH:MM"},
		{"eta", "Arrival time:", "YYYY-MM-DD HH:MM"},
		{"tail", "Aircraft:", "Enter tailnumber"},
		{"pilot1", "Captain:", "(PIC) Enter full name."},
		{"pilot2", "Co-Pilot:", "Enter full name."},
		{"remark", "Remarks:", ""},
	}
	fplEdit = {}
	local ypos = 30
	for k,v in ipairs(fields) do
		ypos = ypos+20
		local txt1 = guiCreateLabel(10,ypos,100,20,tostring(v[2]),false,content)
			guiSetFont(txt1, "clear-normal")
			guiLabelSetColor(txt1,0,0,0)
			guiLabelSetHorizontalAlign(txt1, "right", true)
		fplEdit[tostring(v[1])] = guiCreateEdit(110,ypos,150,20,"",false,content)
		local txtb1 = guiCreateLabel(265,ypos+3,285,20,tostring(v[3]),false,content)
			guiSetFont(txtb1, "default-small")
			guiLabelSetColor(txtb1,0,0,0)
			guiLabelSetHorizontalAlign(txtb1, "left", true)
	end

	local txt2 = guiCreateLabel(10,ypos+20,100,20,"Airline:",false,content)
		guiSetFont(txt2, "clear-normal")
		guiLabelSetColor(txt2,0,0,0)
		guiLabelSetHorizontalAlign(txt2, "right", true)
	fplAirline = guiCreateComboBox(110,ypos+20,150,100,"",false,content)
		local item = guiComboBoxAddItem(fplAirline, "none")
		guiComboBoxSetSelected(fplAirline, item)

	local txt2 = guiCreateLabel(10,ypos+40,100,20,"Type of Flight:",false,content)
		guiSetFont(txt2, "clear-normal")
		guiLabelSetColor(txt2,0,0,0)
		guiLabelSetHorizontalAlign(txt2, "right", true)
	fplFlightType = guiCreateComboBox(110,ypos+40,150,100,"GA",false,content)
		guiComboBoxAddItem(fplFlightType, "GA")
		guiComboBoxAddItem(fplFlightType, "Commercial PAX")
		guiComboBoxAddItem(fplFlightType, "Commercial Cargo")
		guiComboBoxAddItem(fplFlightType, "Medical")
		guiComboBoxAddItem(fplFlightType, "SAR")
		guiComboBoxAddItem(fplFlightType, "Military")
		guiComboBoxAddItem(fplFlightType, "Aerobatic")
		guiComboBoxAddItem(fplFlightType, "Experimental")

	fplBtn = guiCreateButton(110,ypos+80,150,20,"Submit FPL",false,content)
		addEventHandler("onClientGUIClick", fplBtn, function ()
			guiSetEnabled(fplBtn, false)
			guiSetText(fplErrorLabel, "")
			local adep = guiGetText(fplEdit["from"])
			local ades = guiGetText(fplEdit["to"])
			local etd = guiGetText(fplEdit["etd"])..":00"
			local eta = guiGetText(fplEdit["eta"])..":00"
			local tail = guiGetText(fplEdit["tail"])
			local pilot1 = guiGetText(fplEdit["pilot1"])
			local pilot2 = guiGetText(fplEdit["pilot2"])
			local remarks = guiGetText(fplEdit["remark"])
			local airlineName = guiComboBoxGetItemText(fplAirline, guiComboBoxGetSelected(fplAirline))
			local category = guiComboBoxGetItemText(fplFlightType, guiComboBoxGetSelected(fplFlightType))

			if string.len(tail) < 1 then
				guiSetText(fplErrorLabel, "Enter tailnumber of the aircraft!")
				guiSetEnabled(fplBtn, true)
				return				
			end

			if not www_ippc_sa_scripts_isdatetime(etd) then
				guiSetText(fplErrorLabel, "Invalid datetime format for ETD! Use YYYY-MM-DD HH:MM")
				guiSetEnabled(fplBtn, true)
				return
			end
			--[[
			if not www_ippc_sa_scripts_isdatetime(eta) then
				guiSetText(fplErrorLabel, "Invalid datetime format for ETA! Use YYYY-MM-DD HH:MM")
				guiSetEnabled(fplBtn, true)
				return
			end
			--]]
			if not www_ippc_sa_scripts_isdatetime(eta) then
				eta = "NULL"
			end

			local airline
			if airlineName == "none" then
				airline = 0
			else
				for k,v in ipairs(airlinesCache) do
					if v[2] == airlineName then
						airline = v[1]
						break
					end
				end
			end
			triggerServerEvent("ippc:web:newFpl", resourceRoot, adep, ades, etd, eta, tail, pilot1, pilot2, remarks, airline, category)
		end, false)

	triggerServerEvent("ippc:web:fetchAirlines", resourceRoot, "fpl")
end

function www_ippc_sa_fpl_ack()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/fpl/ack") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,530,25,"Flightplan",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	local txt1 = guiCreateLabel(10,30,540,200,"Your flightplan has been submitted. Thank you!\n\nCallsign: "..tostring(myFplCallsign),false,content)
		guiSetFont(txt1, "default-bold-small")
		guiLabelSetColor(txt1,0,150,0)
		guiLabelSetHorizontalAlign(txt1, "center", true)
		guiLabelSetVerticalAlign(txt1, "center")
end

function www_ippc_sa_fpl_at()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/fpl/at") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"Flightplan",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	local txt1 = guiCreateLabel(10,30,540,20,"Do you want to sell tickets for this flight?",false,content)
		guiSetFont(txt1, "default-normal")
		guiLabelSetColor(txt1,0,0,0)
		guiLabelSetHorizontalAlign(txt1, "center", true)
	local btnYes = guiCreateButton(215,60,50,40,"Yes",false,content)
		addEventHandler("onClientGUIClick",btnYes,function()
			get_page("www.ippc.sa/fpl/tickets")
		end,false)
	local btnNo = guiCreateButton(270,60,50,40,"No",false,content)
		addEventHandler("onClientGUIClick",btnNo,function()
			get_page("www.ippc.sa/fpl/ack")
		end,false)
end

function www_ippc_sa_fpl_tickets()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/fpl/tickets") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"Flightplan",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	local txt1 = guiCreateLabel(10,30,540,100,"Your flightplan has been submitted. Thank you!\n\nCallsign: "..tostring(myFplCallsign),false,content)
		guiSetFont(txt1, "default-bold-small")
		guiLabelSetColor(txt1,0,0,0)
		guiLabelSetHorizontalAlign(txt1, "left", true)
end

function www_ippc_sa_notam()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/notam") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"NOTAMs",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	local para1 = guiCreateLabel(10,30,530,40, "NOTAM is short for Notice to Airmen. It is a notice that contains important information to pilots regarding their flight. See below for currently active NOTAMs.",false,content)
		guiSetFont(para1, "clear-normal")
		guiLabelSetColor(para1,0,0,0)
		guiLabelSetHorizontalAlign(para1, "left", true)

	notamMemo = guiCreateMemo(10, 70, 520, 250, "Loading...", false, content)
		guiMemoSetReadOnly(notamMemo, true)

	if isFAALeader then
		guiMemoSetReadOnly(notamMemo, false)
		local saveNotamBtn = guiCreateButton(530, 300, 30, 20, "UP", false, content)
			addEventHandler("onClientGUIClick", saveNotamBtn, function ()
				triggerServerEvent("ippc:web:saveNotam", resourceRoot, guiGetText(notamMemo))
			end, false)
	end

	triggerServerEvent("ippc:web:fetchNotam", resourceRoot)

end

function www_ippc_sa_charts()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/charts") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"Charts",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	local link = guiCreateLabel(10,30,400,25, "BCA - Bone County Air Base",false,content)
		guiSetFont(link, "clear-normal")
		guiLabelSetColor(link,0,0,255)
		addEventHandler("onClientMouseEnter",link,function()
			guiLabelSetColor(link,133,133,255)
		end,false)
		addEventHandler("onClientMouseLeave",link,function()
			guiLabelSetColor(link,0,0,255)
		end,false)
		addEventHandler("onClientGUIClick",link,function()
			local url = tostring("www.ippc.sa/charts/bca")
			get_page(url)
		end,false)	

	local link = guiCreateLabel(10,55,400,25, "LSA - Los Santos International Airport",false,content)
		guiSetFont(link, "clear-normal")
		guiLabelSetColor(link,0,0,255)
		addEventHandler("onClientMouseEnter",link,function()
			guiLabelSetColor(link,133,133,255)
		end,false)
		addEventHandler("onClientMouseLeave",link,function()
			guiLabelSetColor(link,0,0,255)
		end,false)
		addEventHandler("onClientGUIClick",link,function()
			local url = tostring("www.ippc.sa/charts/lsa")
			get_page(url)
		end,false)

	local link = guiCreateLabel(10,80,400,25, "LVA - Las Venturas Airport",false,content)
		guiSetFont(link, "clear-normal")
		guiLabelSetColor(link,0,0,255)
		addEventHandler("onClientMouseEnter",link,function()
			guiLabelSetColor(link,133,133,255)
		end,false)
		addEventHandler("onClientMouseLeave",link,function()
			guiLabelSetColor(link,0,0,255)
		end,false)
		addEventHandler("onClientGUIClick",link,function()
			local url = tostring("www.ippc.sa/charts/lva")
			get_page(url)
		end,false)

	local link = guiCreateLabel(10,105,400,25, "SFA - San Fierro Airport",false,content)
		guiSetFont(link, "clear-normal")
		guiLabelSetColor(link,0,0,255)
		addEventHandler("onClientMouseEnter",link,function()
			guiLabelSetColor(link,133,133,255)
		end,false)
		addEventHandler("onClientMouseLeave",link,function()
			guiLabelSetColor(link,0,0,255)
		end,false)
		addEventHandler("onClientGUIClick",link,function()
			local url = tostring("www.ippc.sa/charts/sfa")
			get_page(url)
		end,false)
end

function www_ippc_sa_charts_bca()
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/charts/bca") -- correct the URL
	local content_title = guiCreateLabel(10,5,400,25,"Charts",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)
	local link = guiCreateLabel(10,30,400,25, "< Go back",false,content)
		guiSetFont(link, "clear-normal")
		guiLabelSetColor(link,0,0,255)
		addEventHandler("onClientMouseEnter",link,function()
			guiLabelSetColor(link,133,133,255)
		end,false)
		addEventHandler("onClientMouseLeave",link,function()
			guiLabelSetColor(link,0,0,255)
		end,false)
		addEventHandler("onClientGUIClick",link,function()
			local url = tostring("www.ippc.sa/charts")
			get_page(url)
		end,false)	
	local label = guiCreateLabel(10,55,400,25,"Bone County Air Base (BCA)",false,content)
		guiSetFont(label, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(label,0,0,0)
	local map = guiCreateStaticImage(10, 80, 521, 515, ":sfia/images/map_BCA.jpg", false, content) --521,641
	local label = guiCreateLabel(541,80,400,400, "Military restricted area\nAccess: PPR\nELE: 18\nRWYS: 18, 36\nPrior permission required!",false,content)
		guiLabelSetColor(label,0,0,0)
end
function www_ippc_sa_charts_lsa()
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/charts/lsa") -- correct the URL
	local content_title = guiCreateLabel(10,5,400,25,"Charts",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)
	local link = guiCreateLabel(10,30,400,25, "< Go back",false,content)
		guiSetFont(link, "clear-normal")
		guiLabelSetColor(link,0,0,255)
		addEventHandler("onClientMouseEnter",link,function()
			guiLabelSetColor(link,133,133,255)
		end,false)
		addEventHandler("onClientMouseLeave",link,function()
			guiLabelSetColor(link,0,0,255)
		end,false)
		addEventHandler("onClientGUIClick",link,function()
			local url = tostring("www.ippc.sa/charts")
			get_page(url)
		end,false)	
	local label = guiCreateLabel(10,55,500,25,"Los Santos International Airport (LSA)",false,content)
		guiSetFont(label, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(label,0,0,0)
	local map = guiCreateStaticImage(10, 80, 721, 515, ":sfia/images/map_LSA.jpg", false, content) --521,641
	local label = guiCreateLabel(741,80,400,400, "Controlled\nAccess: Public\nELE: 14\nRWYS: 9, 27\nGRND: 122.800\nCheck if tower is active.",false,content)
		guiLabelSetColor(label,0,0,0)
end
function www_ippc_sa_charts_lva()
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/charts/lva") -- correct the URL
	local content_title = guiCreateLabel(10,5,400,25,"Charts",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)
	local link = guiCreateLabel(10,30,400,25, "< Go back",false,content)
		guiSetFont(link, "clear-normal")
		guiLabelSetColor(link,0,0,255)
		addEventHandler("onClientMouseEnter",link,function()
			guiLabelSetColor(link,133,133,255)
		end,false)
		addEventHandler("onClientMouseLeave",link,function()
			guiLabelSetColor(link,0,0,255)
		end,false)
		addEventHandler("onClientGUIClick",link,function()
			local url = tostring("www.ippc.sa/charts")
			get_page(url)
		end,false)	
	local label = guiCreateLabel(10,55,400,25,"Las Venturas Airport (LVA)",false,content)
		guiSetFont(label, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(label,0,0,0)
	local map = guiCreateStaticImage(10, 80, 521, 515, ":sfia/images/map_LVA.png", false, content) --521,641
	local label = guiCreateLabel(541,80,400,400, "Controlled\nAccess: Public\nELE: 11\nRWYS: 18, 36\nGRND: 119.900\nCheck if tower is active.",false,content)
		guiLabelSetColor(label,0,0,0)
end
function www_ippc_sa_charts_sfa()
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/charts/sfa") -- correct the URL
	local content_title = guiCreateLabel(10,5,400,25,"Charts",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)
	local link = guiCreateLabel(10,30,400,25, "< Go back",false,content)
		guiSetFont(link, "clear-normal")
		guiLabelSetColor(link,0,0,255)
		addEventHandler("onClientMouseEnter",link,function()
			guiLabelSetColor(link,133,133,255)
		end,false)
		addEventHandler("onClientMouseLeave",link,function()
			guiLabelSetColor(link,0,0,255)
		end,false)
		addEventHandler("onClientGUIClick",link,function()
			local url = tostring("www.ippc.sa/charts")
			get_page(url)
		end,false)	
	local label = guiCreateLabel(10,55,400,25,"San Fierro Airport (SFA)",false,content)
		guiSetFont(label, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(label,0,0,0)
	local map = guiCreateStaticImage(10, 80, 521, 515, ":sfia/images/map_SFA.png", false, content) --521,641
	local label = guiCreateLabel(541,80,400,400, "Uncontrolled\nAccess: Public\nELE: 14\nRWYS: 4, 22\nGRND: 118.500\nTransmit intentions on traffic UNICOM.",false,content)
		guiLabelSetColor(label,0,0,0)
end

function www_ippc_sa_profile()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/profile") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"My Profile",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	myInfoLabel = guiCreateLabel(10,30,330,50, "Name: "..tostring(getPlayerName(localPlayer):gsub("_", " ")).."\nWork for: "..tostring(guiGetText(orgLabel)),false,content)
		guiSetFont(myInfoLabel, "clear-normal")
		guiLabelSetColor(myInfoLabel,0,0,0)
		guiLabelSetHorizontalAlign(myInfoLabel, "left", true)	

	myInfoGridlist = guiCreateGridList(350, 10, 200, 250, false, content)

	local licenses = pilotLicenses or {}
	if #licenses > 0 then
		local column = guiGridListAddColumn(myInfoGridlist, "Licenses", 0.85)
		for k,v in ipairs(licenses) do
			local row = guiGridListAddRow(myInfoGridlist)
			guiGridListSetItemText(myInfoGridlist, row, column, tostring(v[3]), false, false)
		end
	else
		local column = guiGridListAddColumn(myInfoGridlist, "You have no pilot licenses", 0.9)
	end
end

function www_ippc_sa_airline()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/airline") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"Airline Management",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	selectAirline = guiCreateComboBox(10,30,250,80,"",false,content)

	if isFAALeader then
		local adminAirlinesBtn = guiCreateButton(270,30,150,20,"Administrate Airlines",false,content)
		addEventHandler("onClientGUIClick",adminAirlinesBtn,function()
			get_page("www.ippc.sa/airline/admin")
		end,false)
	end

	airlinePara = guiCreateLabel(10,60,530,40, "",false,content)
		guiSetFont(airlinePara, "clear-normal")
		guiLabelSetColor(airlinePara,0,0,0)
		guiLabelSetHorizontalAlign(airlinePara, "left", true)

	airlineMembersGrid = guiCreateGridList(10, 110, 200, 150, false, content)
		guiGridListAddColumn(airlineMembersGrid, "Pilot", 0.65)
		guiGridListAddColumn(airlineMembersGrid, "Leader", 0.25)

	airlineAddMemEdit = guiCreateEdit(10,265,150,20,"",false,content)

	airlineAddMemBtn = guiCreateButton(160,265,50,20,"Add pilot",false,content)
		addEventHandler("onClientGUIClick",airlineAddMemBtn,function()
			guiSetEnabled(airlineAddMemBtn, false)
			if(guiGetText(airlineAddMemBtn) == "OK") then
				guiSetText(airlineAddMemEdit, addPilotName or "")
				guiSetEnabled(airlineAddMemEdit, true)
				guiSetText(airlineAddMemBtn, "Add pilot")
				guiSetEnabled(airlineAddMemBtn, true)
				return
			end
			addPilotName = false
			local pilotName = tostring(guiGetText(airlineAddMemEdit))
			if string.len(pilotName) > 0 then
				guiSetEnabled(airlineAddMemEdit, false)
				guiSetText(airlineAddMemEdit, "Validating...")

				if airlinesCache then
					for k,v in ipairs(airlinesCache) do
						if v[1] == currentlySelectedAirline then
							for k2,v2 in ipairs(v[4]) do
								if v2[2] == pilotName then
									guiSetText(airlineAddMemEdit, "Already added!")
									guiSetText(airlineAddMemBtn, "OK")
									guiSetEnabled(airlineAddMemBtn, true)
									return
								end
							end
						end
					end
				end

				guiSetText(airlineAddMemEdit, "Searching...")

				addPilotName = pilotName

				triggerServerEvent("ippc:web:addPilotToAirline", resourceRoot, currentlySelectedAirline, pilotName)
			end
		end,false)

	airlineTogLeaderBtn = guiCreateButton(215,145,50,40,"Toggle leader",false,content)
		addEventHandler("onClientGUIClick", airlineTogLeaderBtn, function()
			guiSetEnabled(airlineTogLeaderBtn, false)
			local row = guiGridListGetSelectedItem(airlineMembersGrid)
			local pilotName = guiGridListGetItemText(airlineMembersGrid, row, 1)
			local pilotID, leader
			for k,v in ipairs(airlinesCache) do
				if v[1] == currentlySelectedAirline then
					for k2,v2 in ipairs(v[4]) do
						if v2[2] == pilotName then
							pilotID = v2[1]
							leader = not v2[3]
							airlinesCache[k][4][k2][3] = leader
							break
						end
					end
					break
				end
			end
			if tonumber(pilotID) then
				local text
				guiGridListSetItemText(airlineMembersGrid, row, 2, leader and "Yes" or "", false, false)
				triggerServerEvent("ippc:web:setPilotAirlineLeader", resourceRoot, currentlySelectedAirline, pilotID, leader)
			end
			guiSetEnabled(airlineTogLeaderBtn, true)
		end, false)

	airlineRemoveSelBtn = guiCreateButton(215,190,50,40,"Remove selected",false,content)
		addEventHandler("onClientGUIClick",airlineRemoveSelBtn,function()
			guiSetEnabled(airlineRemoveSelBtn, false)
			local row = guiGridListGetSelectedItem(airlineMembersGrid)
			local pilotName = guiGridListGetItemText(airlineMembersGrid, row, 1)
			local pilotID
			for k,v in ipairs(airlinesCache) do
				if v[1] == currentlySelectedAirline then
					for k2,v2 in ipairs(v[4]) do
						if v2[2] == pilotName then
							pilotID = v2[1]
							break
						end
					end
					break
				end
			end
			if tonumber(pilotID) then
				guiGridListRemoveRow(airlineMembersGrid, row)
				triggerServerEvent("ippc:web:removePilotFromAirline", resourceRoot, currentlySelectedAirline, pilotID)
			end
			guiSetEnabled(airlineRemoveSelBtn, true)
		end,false)

	guiSetVisible(airlineAddMemEdit, false)
	guiSetVisible(airlineAddMemBtn, false)
	guiSetVisible(airlineTogLeaderBtn, false)
	guiSetVisible(airlineRemoveSelBtn, false)

	guiSetVisible(airlineMembersGrid, false)

	triggerServerEvent("ippc:web:fetchAirlines", resourceRoot, "airline")
end

function www_ippc_sa_airline_admin()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/airline/admin") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"Airline Administration",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	if isFAALeader then
		airlinesAdminGrid = guiCreateGridList(10, 30, 250, 150, false, content)
			guiGridListAddColumn(airlinesAdminGrid, "Airline", 0.7)
			guiGridListAddColumn(airlinesAdminGrid, "Code", 0.2)

		local editBtn = guiCreateButton(265,50,50,40,"Edit",false,content)


		local deleteBtn = guiCreateButton(265,95,50,40,"Delete",false,content)
			addEventHandler("onClientGUIClick",deleteBtn,function()
				local row = guiGridListGetSelectedItem(airlinesAdminGrid)
				if row and row >= 0 then
					local airlineName = tostring(guiGridListGetItemText(airlinesAdminGrid, row, 1))
					local airlineCode = tostring(guiGridListGetItemText(airlinesAdminGrid, row, 2))
					guiGridListRemoveRow(airlinesAdminGrid, row)
					local airlineID = www_ippc_sa_scripts_airlineID(airlineCode)
					if airlineID then
						triggerServerEvent("ippc:web:deleteAirline", resourceRoot, airlineID)
						if inAirline then
							inAirline[airlineID] = false
						end
					end
				end
			end,false)

		local para1 = guiCreateLabel(10,200,200,20, "Create New Airline",false,content)
			guiSetFont(para1, "default-bold-small")
			guiLabelSetColor(para1,0,0,0)
			guiLabelSetHorizontalAlign(para1, "left", true)

		local para2 = guiCreateLabel(10,220,100,20, "Airline Name:",false,content)
			guiSetFont(para2, "default-normal")
			guiLabelSetColor(para2,0,0,0)
			guiLabelSetHorizontalAlign(para2, "left", true)
		newAirlineName = guiCreateEdit(110,220,150,20,"",false,content)

		local para3 = guiCreateLabel(10,240,100,20, "Airline Code:",false,content)
			guiSetFont(para3, "default-normal")
			guiLabelSetColor(para3,0,0,0)
			guiLabelSetHorizontalAlign(para3, "left", true)
		newAirlineCode = guiCreateEdit(110,240,150,20,"",false,content)

		local newAirlineBtn = guiCreateButton(110,270,150,20,"Create",false,content)
		addEventHandler("onClientGUIClick",newAirlineBtn,function()
			local airlineName = tostring(guiGetText(newAirlineName))
			local airlineCode = tostring(guiGetText(newAirlineCode))
			if string.len(airlineName) > 0 and string.len(airlineCode) > 0 then
				local row = guiGridListAddRow(airlinesAdminGrid)
				guiGridListSetItemText(airlinesAdminGrid, row, 1, airlineName, false, false)
				guiGridListSetItemText(airlinesAdminGrid, row, 2, airlineCode, false, false)
				guiSetText(newAirlineName, "")
				guiSetText(newAirlineCode, "")
				triggerServerEvent("ippc:web:addNewAirline", resourceRoot, airlineName, airlineCode)
			end
		end,false)

		triggerServerEvent("ippc:web:fetchAirlines", resourceRoot, "airline/admin")
	end
end

function www_ippc_sa_gates()
	
	www_ippc_sa_themes_main() -- load theme
	guiSetText(address_bar,"www.ippc.sa/gates") -- correct the URL
	
	-------------
	-- Content --
	-------------	
	local content_title = guiCreateLabel(10,5,400,25,"Airport Gates",false,content)
		guiSetFont(content_title, guiCreateFont(":fonts/helveticastrong.ttf", 20))
		guiLabelSetColor(content_title,0,0,0)

	local verticalOffset = 86
	
	if isFAA or #inAirline > 0 then
	
		bOpen = {}
		lGate = {}
		lBridge = {}
		lPlane = {}
		gateOpen = {}

		local airports = {
			["Los Santos"] = {
				{"Gate C", 1},
				{"Gate D", 2},
				{"Gate E", 3},
				{"Gate F", 4},
				{"Gate G", 5},
			},
			--[[
			["San Fierro"] = {
				{"Gate C", 6},
				{"Gate D", 7},
				{"Gate E", 8},
				{"Gate F", 9},
			},
			--]]
		}
		local i = 1
		for k,v in pairs(airports) do
			local label = guiCreateLabel(5,verticalOffset,650,16,tostring(k),false,content)
				guiLabelSetColor(label,0,0,0)
			verticalOffset = verticalOffset+16
			for key,value in ipairs(v) do
				--for k2, v2 in ipairs(value) do
					i = value[2]
					gateOpen[i] = false
					lGate[i] = guiCreateLabel(15,verticalOffset,650,16,tostring(value[1]),false,content)
						guiLabelSetColor(lGate[i],0,0,0)
					lPlane[i] = guiCreateLabel(65,verticalOffset,650,16,"Loading",false,content)
						guiLabelSetColor(lPlane[i],0,0,0)
					lBridge[i] = guiCreateLabel(215,verticalOffset,650,16,"Loading",false,content)
						guiLabelSetColor(lBridge[i],0,0,0)
					bOpen[i] = guiCreateButton(300,verticalOffset,35,16, "-", false, content)
					setElementData(bOpen[i], "airport.gate.id", i)
					addEventHandler("onClientGUIClick", bOpen[i], function(button, state, absX, absY)
						--if source ~= bOpen[i] then return end
						outputDebugString("hey ho")
						--local result = triggerServerEvent("airport-gates:toggleGateOpen", getLocalPlayer(), i)
						--outputDebugString("trigger "..tostring(result))
						local gateID = tonumber(getElementData(source, "airport.gate.id"))
						www_ippc_sa_scripts_toggleGate(gateID)
						www_ippc_sa_gates()
					end, false)
					triggerServerEvent("airport-gates:getGUIdata", getLocalPlayer(), false, i)
					verticalOffset = verticalOffset+16
					--i = i+1
				--end
			end
			verticalOffset = verticalOffset+10
		end
	else
		local label = guiCreateLabel(15,verticalOffset,650,16,"Access denied.",false,content)
			guiLabelSetColor(label,0,0,0)
	end

end

function www_ippc_sa_scripts_toggleGate(gateID)
	if gateOpen[gateID] then
		triggerServerEvent("airport-gates:setGateOpen", getLocalPlayer(), gateID, false)
	else
		triggerServerEvent("airport-gates:setGateOpen", getLocalPlayer(), gateID, true)
	end
end

function www_ippc_sa_scripts_fillGateControl(element, gateID, open, plane, connected)
	if open then
		guiLabelSetColor(lGate[gateID],0,150,0)
		guiSetText(bOpen[gateID], "Close")
		gateOpen[gateID] = true
	else
		guiLabelSetColor(lGate[gateID],255,0,0)
		guiSetText(bOpen[gateID], "Open")
		gateOpen[gateID] = false
	end

	if plane then
		planeText = tostring(getVehicleName(plane)).." ("..tostring(getVehiclePlateText(plane))..")"
		guiSetText(lPlane[gateID], planeText)
	else
		guiSetText(lPlane[gateID], "")
	end

	if connected then
		guiSetText(lBridge[gateID], "Connected")
	else
		guiSetText(lBridge[gateID], "")
	end
end
addEvent("airport-gates:fillControlGUI", true)
addEventHandler("airport-gates:fillControlGUI", getRootElement(), www_ippc_sa_scripts_fillGateControl)

function www_ippc_sa_scripts_notam(data)
	if notamMemo then
		guiSetText(notamMemo, tostring(data))
	end
end
addEvent("ippc:web:notamData", true)
addEventHandler("ippc:web:notamData", resourceRoot, www_ippc_sa_scripts_notam)

function www_ippc_sa_scripts_session(licenses, airlines)
	pilotLicenses = licenses
	airlinesCache = airlines
	airlineNameCache = {}
	isPilot = false
	for k,v in ipairs(licenses) do
		if v[3] == "ROT" or v[3] == "SER" then
			isPilot = true
			break
		end
	end
	www_ippc_sa_scripts_updateorg()
end
addEvent("ippc:web:sessionData", true)
addEventHandler("ippc:web:sessionData", resourceRoot, www_ippc_sa_scripts_session)

function www_ippc_sa_scripts_updateorg()
	if orgLabel then
		local orgTxt = ""
		local memOf = {}
		if isFAA then
			table.insert(memOf, "FAA")
		end
		local charID = tonumber(getElementData(getLocalPlayer(), "dbid")) or 0
		inAirline = {}
		airlineLeader = {}
		if airlinesCache then
			for k,v in ipairs(airlinesCache) do
				for k2,v2 in ipairs(v[4]) do
					if tonumber(v2[1]) == charID then
						table.insert(memOf, v[2])
						inAirline[tonumber(v[1])] = true
						airlineLeader[tonumber(v[1])] = v2[3]
					end
				end
			end
		end
		if #memOf > 0 then
			for k,v in ipairs(memOf) do
				orgTxt = orgTxt..tostring(v)
				if k < #memOf then
					orgTxt = orgTxt..", "
				elseif k == #memOf then
					orgTxt = orgTxt.."."
				end
			end
		else
			if isPilot then
				orgTxt = "Private Pilot"
			else
				orgTxt = ""
			end
		end
		guiSetText(orgLabel, orgTxt)
		if isFAALeader or #inAirline > 0 then
			guiSetVisible(menu_link7_txt, true)
		else
			guiSetVisible(menu_link7_txt, false)
		end
		if isFAA or #inAirline > 0 then
			guiSetVisible(menu_link8_txt, true)
		else
			guiSetVisible(menu_link8_txt, false)
		end
	end
end

function www_ippc_sa_scripts_isInAirline(airline)
	if inAirline then
		if inAirline[tonumber(airline)] then
			return true
		end
	else
		airline = tonumber(airline)
		local charID = tonumber(getElementData(getLocalPlayer(), "dbid"))
		if charID and airlinesCache and airline then
			for k,v in ipairs(airlinesCache) do
				if v[1] == airline then
					for k2,v2 in ipairs(v[4]) do
						if tonumber(v2[1]) == charID then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

function www_ippc_sa_scripts_airlineID(code, name)
	if code then
		code = tostring(code)
		if airlinesCache then
			for k,v in ipairs(airlinesCache) do
				if v[3] == code then
					return tonumber(v[1])
				end
			end
		end
	elseif name then
		name = tostring(name)
		if airlinesCache then
			for k,v in ipairs(airlinesCache) do
				if v[2] == name then
					return tonumber(v[1])
				end
			end
		end
	end
	return false
end

function www_ippc_sa_scripts_airlineName(id, code)
	if id then
		id = tonumber(id)
		if airlineNameCache then
			if airlineNameCache[id] then
				return tostring(airlineNameCache[id])
			end
		end
		if airlinesCache then
			for k,v in ipairs(airlinesCache) do
				if v[1] == id then
					if not airlineNameCache then airlineNameCache = {} end
					airlineNameCache[id] = v[2]
					return tostring(v[2])
				end
			end
		end
	elseif code then
		code = tostring(code)
		if airlinesCache then
			for k,v in ipairs(airlinesCache) do
				if v[3] == code then
					return tostring(v[2])
				end
			end
		end
	end
	return false
end

function www_ippc_sa_scripts_refreshAirlinePage()
	if tonumber(currentlySelectedAirline) then
		if airlinesCache then
			guiGridListClear(airlineMembersGrid)
			for k,v in ipairs(airlinesCache) do
				if tonumber(v[1]) == currentlySelectedAirline then
					guiSetVisible(airlineMembersGrid, true)
					guiSetText(airlinePara, "Airline Name: "..tostring(v[2]).."\nAirline Code: "..tostring(v[3]).."\n")
					for k2,v2 in ipairs(v[4]) do
						local row = guiGridListAddRow(airlineMembersGrid)
						guiGridListSetItemText(airlineMembersGrid, row, 1, tostring(v2[2]), false, false)
						guiGridListSetItemText(airlineMembersGrid, row, 2, v2[3] and "Yes" or "", false, false)
					end
					if isFAALeader or airlineLeader[currentlySelectedAirline] then
						guiSetVisible(airlineAddMemEdit, true)
						guiSetVisible(airlineAddMemBtn, true)
						guiSetVisible(airlineTogLeaderBtn, true)
						guiSetVisible(airlineRemoveSelBtn, true)
					else
						guiSetVisible(airlineAddMemEdit, false)
						guiSetVisible(airlineAddMemBtn, false)
						guiSetVisible(airlineTogLeaderBtn, false)
						guiSetVisible(airlineRemoveSelBtn, false)
					end
					return
				end
			end
		end
	end
end

function www_ippc_sa_scripts_addFlightToGrid(flight, etd, adep, ades, airline, eta, id)
	--outputDebugString("added")
	if www_ippc_sa_scripts_isdatetime(eta) then
		eta = exports.global:split(eta, " ")
		eta = exports.global:split(eta[2], ":")
		eta = eta[1]..":"..eta[2]
	else
		eta = ""
	end
	etd = exports.global:split(etd, ":")
	etd = etd[1]..":"..etd[2]
	local row = guiGridListAddRow(flightsGrid)
		guiGridListSetItemText(flightsGrid, row, 1, tostring(flight), false, false)
		guiGridListSetItemText(flightsGrid, row, 2, tostring(etd), false, false)
		guiGridListSetItemText(flightsGrid, row, 3, tostring(adep), false, false)
		guiGridListSetItemText(flightsGrid, row, 4, tostring(ades), false, false)
		guiGridListSetItemText(flightsGrid, row, 5, tostring(airline), false, false)
		guiGridListSetItemText(flightsGrid, row, 6, tostring(eta), false, false)
		guiGridListSetItemData(flightsGrid, row, 1, id)
	return row
end

function www_ippc_sa_scripts_isFutureFlight(eta, etd, now)
	if not now then
		now = exports.datetime:now()
	end
	if eta and string.len(eta) == 19 then
		if exports.datetime:datetimeToTimestamp(eta) <= now then
			--outputDebugString("IPPC: "..tostring(eta).." is future.")
			--outputDebugString(tostring(exports.datetime:datetimeToTimestamp(eta)).." <= "..tostring(now))
			return true
		else
			--outputDebugString("IPPC: "..tostring(eta).." is past.")
			return false
		end
	elseif etd and string.len(etd) == 19 then
		if exports.datetime:datetimeToTimestamp(etd) <= now then
			--outputDebugString("IPPC: "..tostring(etd).." is future.")
			return true
		else
			--outputDebugString("IPPC: "..tostring(etd).." is past.")
			return false
		end
	else
		--outputDebugString("IPPC:946: No valid datetime.")
	end
end

function www_ippc_sa_scripts_addToFlightList(filterFlights, filterTime, filterAirlineName, airline, now, callsign, etd, adep, ades, airlineName, eta, id, pilot1, pilot2, charID)
	if filterAirlineName then
		if airlineName == filterAirlineName then
			if filterTime == 1 then --future
				if www_ippc_sa_scripts_isFutureFlight(eta, etd, now) then
					return www_ippc_sa_scripts_addFlightToGrid(callsign, etd, adep, ades, airlineName, eta, id)
				end
			elseif filterTime == 2 then --past
				if not www_ippc_sa_scripts_isFutureFlight(eta, etd, now) then
					return www_ippc_sa_scripts_addFlightToGrid(callsign, etd, adep, ades, airlineName, eta, id)
				end
			end
		end
	else
		if filterFlights == 1 then --all
			if filterTime == 1 then --future
				if www_ippc_sa_scripts_isFutureFlight(eta, etd, now) then
					return www_ippc_sa_scripts_addFlightToGrid(callsign, etd, adep, ades, airlineName, eta, id)
				end
			elseif filterTime == 2 then --past
				if not www_ippc_sa_scripts_isFutureFlight(eta, etd, now) then
					return www_ippc_sa_scripts_addFlightToGrid(callsign, etd, adep, ades, airlineName, eta, id)
				end
			end
		elseif filterFlights == 2 then --my flights
			if tonumber(pilot1) then
				if tonumber(pilot1) == charID then
					if filterTime == 1 then --future
						if www_ippc_sa_scripts_isFutureFlight(eta, etd, now) then
							return www_ippc_sa_scripts_addFlightToGrid(callsign, etd, adep, ades, airlineName, eta, id)
						end
					elseif filterTime == 2 then --past
						if not www_ippc_sa_scripts_isFutureFlight(eta, etd, now) then
							return www_ippc_sa_scripts_addFlightToGrid(callsign, etd, adep, ades, airlineName, eta, id)
						end
					end
				end
			end
			if tonumber(pilot2) then
				if tonumber(pilot2) == charID then
					if filterTime == 1 then --future
						if www_ippc_sa_scripts_isFutureFlight(eta, etd, now) then
							return www_ippc_sa_scripts_addFlightToGrid(callsign, etd, adep, ades, airlineName, eta, id)
						end
					elseif filterTime == 2 then --past
						if not www_ippc_sa_scripts_isFutureFlight(eta, etd, now) then
							return www_ippc_sa_scripts_addFlightToGrid(callsign, etd, adep, ades, airlineName, eta, id)
						end
					end
				end						
			end
		end
	end
end

function www_ippc_sa_scripts_refreshFlightsPage()
	if flightsCache then
		flightIDs = {}
		guiGridListClear(flightsGrid)
		local filterTime = guiComboBoxGetSelected(selectFlightsTime) --1:future 2:past
		local filterFlights = guiComboBoxGetSelected(selectFlights)
		local filterAirlineName
		if filterFlights > 2 then
			filterAirlineName = guiComboBoxGetItemText(selectFlights, filterFlights)
		end
		local charID = tonumber(getElementData(getLocalPlayer(), "dbid")) or 0
		filterFlights = filterFlights + 1
		filterTime = filterTime + 1
		local now = exports.datetime:now()
		for k,v in ipairs(flightsCache) do
			if not type(v) == "table" then break end
			if not v["id"] then break end
			flightIDs[tonumber(v["id"])] = k
			local airline = tonumber(v["airline"]) or 0
			local airlineName = ""
			if airline > 0 then
				airlineName = www_ippc_sa_scripts_airlineName(v["airline"])
			end

			--outputDebugString("filterFlights = "..tostring(filterFlights))
			--outputDebugString("filterTime = "..tostring(filterTime))

			local row = www_ippc_sa_scripts_addToFlightList(filterFlights, filterTime, filterAirlineName, v["airline"], now, v["callsign"], v["etd"], v["adep"], v["ades"], airlineName, v["eta"], v["id"], v["pilot1"], v["pilot2"], charID)
		end
	end
end

function www_ippc_sa_scripts_airlinescache(data, page, flights)
	if data then
		airlinesCache = data
		if page then
			if page == "airline" then
				if selectAirline then
					local charID = tonumber(getElementData(getLocalPlayer(), "dbid")) or 0
					if not inAirline then inAirline = {} end
					if not airlineLeader then airlineLeader = {} end
					for k,v in ipairs(airlinesCache) do
						for k2,v2 in ipairs(v[4]) do
							if v2[1] == charID then
								inAirline[tonumber(v[1])] = true
								airlineLeader[tonumber(v[1])] = v[3]
							else
								inAirline[tonumber(v[1])] = false
								airlineLeader[tonumber(v[1])] = false
							end
						end
						if isFAALeader or inAirline[tonumber(v[1])] then
							local item = guiComboBoxAddItem(selectAirline, tostring(v[2]))
							guiComboBoxSetSelected(selectAirline, item)
							currentlySelectedAirline = tonumber(v[1])
							www_ippc_sa_scripts_refreshAirlinePage()
						end
					end
					addEventHandler("onClientGUIComboBoxAccepted", selectAirline, function()
						local airlineName = guiComboBoxGetItemText(selectAirline, guiComboBoxGetSelected(selectAirline))
						currentlySelectedAirline = www_ippc_sa_scripts_airlineID(false, airlineName)
						www_ippc_sa_scripts_refreshAirlinePage()
					end, false)
				end
			elseif page == "airline/admin" then
				if airlinesAdminGrid then
					for k,v in ipairs(airlinesCache) do
						local row = guiGridListAddRow(airlinesAdminGrid)
						guiGridListSetItemText(airlinesAdminGrid, row, 1, tostring(v[2]), false, false)
						guiGridListSetItemText(airlinesAdminGrid, row, 2, tostring(v[3]), false, false)
					end					
				end
			elseif page == "fpl" then
				if fplAirline then
					local charID = tonumber(getElementData(getLocalPlayer(), "dbid")) or 0
					if not inAirline then inAirline = {} end
					if not airlineLeader then airlineLeader = {} end
					for k,v in ipairs(airlinesCache) do
						for k2,v2 in ipairs(v[4]) do
							if v2[1] == charID then
								inAirline[tonumber(v[1])] = true
								airlineLeader[tonumber(v[1])] = v[3]
							else
								inAirline[tonumber(v[1])] = false
								airlineLeader[tonumber(v[1])] = false
							end
						end
						if inAirline[tonumber(v[1])] then
							local item = guiComboBoxAddItem(fplAirline, tostring(v[2]))
						end
					end
				end				
			elseif page == "flights" then
				local charID = tonumber(getElementData(getLocalPlayer(), "dbid")) or 0
				if not inAirline then inAirline = {} end
				if not airlineLeader then airlineLeader = {} end
				for k,v in ipairs(airlinesCache) do
					for k2,v2 in ipairs(v[4]) do
						if v2[1] == charID then
							inAirline[tonumber(v[1])] = true
							airlineLeader[tonumber(v[1])] = v[3]
						else
							inAirline[tonumber(v[1])] = false
							airlineLeader[tonumber(v[1])] = false
						end
					end
					if inAirline[tonumber(v[1])] then
						guiComboBoxAddItem(selectFlights, tostring(v[2]))
					end
				end
				flightsCache = flights or {}
				www_ippc_sa_scripts_refreshFlightsPage()
				addEventHandler("onClientGUIComboBoxAccepted", selectFlights, function()
					www_ippc_sa_scripts_refreshFlightsPage()
				end, false)	
				addEventHandler("onClientGUIComboBoxAccepted", selectFlightsTime, function()
					www_ippc_sa_scripts_refreshFlightsPage()
				end, false)		
			end
		end
	end
end
addEvent("ippc:web:airlinesCache", true)
addEventHandler("ippc:web:airlinesCache", resourceRoot, www_ippc_sa_scripts_airlinescache)

function www_ippc_sa_scripts_addpilottoairline(success, msg, pilotName, pilotID, airlineID)
	if success then
		addPilotName = false
		local row = guiGridListAddRow(airlineMembersGrid)
		guiGridListSetItemText(airlineMembersGrid, row, 1, tostring(pilotName), false, false)
		--guiGridListSetItemText(airlineMembersGrid, row, 2, "", false, false)
	end

	for k,v in ipairs(airlinesCache) do
		if v[1] == airlineID then
			table.insert(v[4], {pilotID, pilotName, false})
		end
	end

	guiSetText(airlineAddMemEdit, tostring(msg))
	guiSetText(airlineAddMemBtn, "OK")
	guiSetEnabled(airlineAddMemBtn, true)
end
addEvent("ippc:web:addPilotToAirlineResult", true)
addEventHandler("ippc:web:addPilotToAirlineResult", resourceRoot, www_ippc_sa_scripts_addpilottoairline)

function www_ippc_sa_scripts_fplResult(success, msg, askTickets, flightID)
	if success then
		myFplCallsign = msg
		myFplID = flightID
		if askTickets then
			get_page("www.ippc.sa/fpl/at")
		else
			get_page("www.ippc.sa/fpl/ack")
		end
	else
		guiSetText(fplErrorLabel, tostring(msg))
		guiSetEnabled(fplBtn, true)
	end
end
addEvent("ippc:web:fplResult", true)
addEventHandler("ippc:web:fplResult", resourceRoot, www_ippc_sa_scripts_fplResult)

function www_ippc_sa_scripts_isdatetime(timestring)
	-- YYYY-MM-DD HH:MM:SS
	local a = exports.global:split(timestring, " ")
	if #a == 2 then
		local b = exports.global:split(a[1], "-")
		if #b == 3 then
			if string.len(b[1]) == 4 then
				if tonumber(b[1]) then
					if string.len(b[2]) == 2 then
						if tonumber(b[2]) then
							if string.len(b[3]) == 2 then
								if tonumber(b[3]) then
									local c = exports.global:split(a[2], ":")
									if #c == 3 then
										if string.len(c[1]) == 2 then
											if tonumber(c[1]) then
												if string.len(c[2]) == 2 then
													if tonumber(c[2]) then
														if string.len(c[3]) == 2 then
															if tonumber(c[3]) then
																return true
															end
														end
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return false
end
