help={
	-- 1.	Welcome (accounts-system; 1st character give achievement)
	"welcome.xml",
	-- 2.	Vehicles (s_tootips)
	"vehicles.xml",
	-- 3	Weapons (c_tootips)
	"weapons.xml",
	-- 4	Interiors (s_tootips)
	"interiors.xml",
	-- 5	Shops (c_general_shop; show shop window)
	"shops.xml",
	-- 6	NPCs (c_tootips)
	"npcs.xml",
	-- 7	Jobs (c_jobs; showEmploymentWindow)
	"jobs.xml",
	-- 8	Languages (lang system; apply lang)
	"languages.xml",
	-- 9	Factions
	"factions.xml",
	-- 10	Dying (c_tootips)
	"deaths.xml",
	-- 11	Buying a vehicle
	"vehicle_buying.xml",
	-- 12	Pay Check (s_factions; pay day)
	"pay_check.xml",
	-- 13	Computers (computers system; create computer GUI)
	"computers.xml",
	-- 14	Inventory (item system; pickup item)
	"inventory.xml",
	-- 15	Houses & renting (s_tootips)
	"houses.xml",
	-- 16	Gas stations
	"gas_stations.xml",
	-- 17	Chat commands (s_chat; local chat)
	"chat.xml",
	-- 18 Injuries (c_tootips)
	"injuries.xml",
}

--
local screenwidth, screenheight = guiGetScreenSize()
local starttime = false

local function updateIconAlpha( )
	local time = getTickCount( ) - starttime
	if time > 20000 then
		removeIcon( )
	else
		time = time % 2000
		local alpha = 0
		if time < 1000 then
			alpha = time / 1000
		else
			alpha = 1 - ( time - 1000 ) / 1000
		end
		
		guiSetAlpha(help_icon, alpha)
		guiSetAlpha(icon_label_shadow, alpha)
		guiSetAlpha(icon_label, alpha)
	end
end

function show_icon(number)
	if getElementData(getLocalPlayer(),"tooltips:help") == 1 then
		if help_icon then
			removeIcon()
		end
		
		local xml = xmlLoadFile( "text/"..help[number] )
		if xml then
			local title = xmlNodeGetValue( xmlFindChild ( xml, "title", 0 ) )
			xmlUnloadFile( xml )

			help_icon = guiCreateStaticImage(screenwidth-30,3,30,30,"icon.png",false)
			addEventHandler( "onClientGUIClick", help_icon,
				function()
					createHelpGUI(number, title)
				end,
				false
			)
			
			icon_label_shadow = guiCreateLabel(screenwidth-429,11,400,20,title,false)
			guiSetFont(icon_label_shadow,"default-bold-small")
			guiLabelSetColor(icon_label_shadow,0,0,0)
			guiLabelSetHorizontalAlign(icon_label_shadow,"right",true)
			
			icon_label = guiCreateLabel(screenwidth-430,10,400,20,title,false)
			guiSetFont(icon_label,"default-bold-small")
			guiLabelSetHorizontalAlign(icon_label,"right",true)
			
			addEventHandler("onClientGUIClick",icon_label,
				function()
					createHelpGUI(number, title)
				end,
				false
			)
			
			starttime = getTickCount( )
			updateIconAlpha( )
			addEventHandler( "onClientRender", getRootElement( ), updateIconAlpha )
		else
			outputDebugString(help[number]..".xml not found.")
		end
	end
end
addEvent("tooltips:showHelp",true)
addEventHandler("tooltips:showHelp",getLocalPlayer(),show_icon)

function createHelpGUI(number, title)
	removeIcon()
	if not (wHelp) then
		local xml = xmlLoadFile( "text/"..help[number] )
		if (xml) then
			local content = xmlNodeGetValue(xmlFindChild (xml, "text", 0))
			local pageLength = tonumber(xmlNodeGetValue(xmlFindChild (xml, "pageLength", 0)))
			xmlUnloadFile( xml )
			
			local Width = 500
			local Height = 400
			
			local X = (screenwidth - Width)/2
			local Y = (screenheight - Height)/2
			
			wHelp = guiCreateWindow(X, Y, Width, Height, "Help", false)
			
			help_title_text = guiCreateLabel(10,30,396,30,title,false,wHelp)
			guiSetFont(help_title_text,"default-bold-small")
			
			help_scroll = guiCreateScrollPane(0,50,500,300,false,wHelp)
			
			help_text = guiCreateLabel(2,0,455,pageLength,content,false,help_scroll)
			guiLabelSetHorizontalAlign(help_text,"left",true)
			
			help_close_button = guiCreateButton(200,357,100,40,"Close",false,wHelp)
			addEventHandler("onClientGUIClick",help_close_button,close_help)
			
			showCursor(true)
			
			local page_x, page_y = guiGetSize(help_text, false)
			if (page_y>300) then
				guiScrollPaneSetScrollBars(help_scroll,false,true)
			end
		end
	end
end
addEvent("tooltips:welcomeHelp",true)
addEventHandler("tooltips:welcomeHelp",getLocalPlayer(),createHelpGUI)

function removeIcon()
	removeEventHandler( "onClientRender", getRootElement( ), updateIconAlpha )
	destroyElement(icon_label_shadow)
	destroyElement(icon_label)
	destroyElement(help_icon)
	icon_label_shadow, icon_label, help_icon = nil
end

function close_help()
	destroyElement(help_close_button)
	destroyElement(help_text)
	destroyElement(help_scroll)
	destroyElement(help_title_text)
	destroyElement(wHelp)
	help_close_button, help_text, help_scroll, help_title_text, wHelp = nil
	showCursor(false)
end

-- Triggers
---------------------------------
-- Weapons
addEventHandler("onClientPlayerWeaponSwitch",getLocalPlayer(),function()
	show_icon(3)
end)

-- NPCs
addEventHandler("onClientElementStreamIn",getRootElement(),function()
	if(getElementDimension(getLocalPlayer())~=0)then
		if (getElementType(source) == "ped") and (getElementType(source)~= "player") then
			show_icon(6)
		end
	end
end)

-- Death
addEventHandler("onClientPlayerWasted",getLocalPlayer(),function()
	show_icon(10)
end)

-- Injuries
addEventHandler("onClientPlayerDamage",getLocalPlayer(),function()
	if(getElementHealth(source)>20)then
		show_icon(18)
	end
end)