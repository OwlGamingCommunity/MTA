local showedLogs, targetPlayer = nil
local isWeaponAmountValid = true
local isAmmoAmountValid = true
local isAmmoPerClipValid = true
local isTargetPlayerValid = false
local spawnCooldown = true

--local logs = ""
local targetPlayerName = ""
local wSelectedWepID = nil
local aSelectedWepID = nil


local getPlayerName_ = getPlayerName
getPlayerName = function( ... )
	s = getPlayerName_( ... )
	return s and s:gsub( "_", " " ) or s
end



local adminTitle = exports.global:getPlayerAdminTitle(getLocalPlayer())
local adminName = getPlayerName(getLocalPlayer())
local adminUsername = getElementData( getLocalPlayer(), "account:username" )

function openWeaponCreatorMain(commandName, category)
	if exports.integration:isPlayerAdmin(localPlayer) and getElementData(localPlayer, "loggedin") == 1 then
		if wWeaponsMain then
			closeWeaponCreatorMain()
		end
		
		isWeaponAmountValid = true
		isAmmoAmountValid = true
		isAmmoPerClipValid = true
		isTargetPlayerValid = false
		spawnCooldown = false
		
		GUIEditor_Checkbox = {}
		GUIEditor_Label = {}
		GUIEditor_Image = {}
		
		showCursor(true)
		guiSetInputEnabled(true)
		
		local sx, sy = guiGetScreenSize()
		local wWeaponsMain_x = sx/2-280
		local wWeaponsMain_y = sy/2-115
		wWeaponsMain = guiCreateWindow(wWeaponsMain_x,wWeaponsMain_y,560,230,"Admin Weapon Creator v2.0 - QUICK MODE",false)
			guiWindowSetSizable(wWeaponsMain,false)
			lCredit1 = guiCreateLabel(10,28,300,18,"Admin Weapon Creator",false,wWeaponsMain)
				guiSetFont(lCredit1,"default-small")
				guiLabelSetHorizontalAlign(lCredit1,"left",false)
			lCoolDown = guiCreateLabel(130,28,300,18,"",false,wWeaponsMain)
				guiSetFont(lCoolDown,"default-small")
				guiLabelSetHorizontalAlign(lCoolDown,"center",false)
				guiLabelSetColor(lCoolDown, 255,0,0)
			verLine = guiCreateStaticImage(279,42,1,100,"images/whitedot.jpg",false,wWeaponsMain)
			HorLine = guiCreateStaticImage(9,42,542,1,"images/whitedot.jpg",false,wWeaponsMain)
			HorLine = guiCreateStaticImage(9,142,542,1,"images/whitedot.jpg",false,wWeaponsMain)
			
			iWeapons = guiCreateStaticImage(30,55,57,62,"weapIcons/gun.png",false,wWeaponsMain)
			GUIEditor_Label[2] = guiCreateLabel(30,114,102,18,"Weapons",false,wWeaponsMain)
				guiSetFont(GUIEditor_Label[2],"default-bold-small")
			boxWeapons =  guiCreateComboBox(100,55,116,21,"None",false,wWeaponsMain)
				guiComboBoxAdjustHeight (  boxWeapons, 30 )
				guiComboBoxAddItem(boxWeapons, "None")
				guiComboBoxAddItem(boxWeapons, "(22) Colt 45")
				guiComboBoxAddItem(boxWeapons, "(24) Deagle")
				guiComboBoxAddItem(boxWeapons, "(23) Silenced")
				guiComboBoxAddItem(boxWeapons, "(25) Shotgun")
				guiComboBoxAddItem(boxWeapons, "(32) Tec-9")
				guiComboBoxAddItem(boxWeapons, "(28) Uzi")
				guiComboBoxAddItem(boxWeapons, "(29) MP5")
				guiComboBoxAddItem(boxWeapons, "(30) AK-47")
				guiComboBoxAddItem(boxWeapons, "(31) M4A1")
				guiComboBoxAddItem(boxWeapons, "(18) Molotov")
				guiComboBoxAddItem(boxWeapons, "(03) Nightstick ")
				guiComboBoxAddItem(boxWeapons, "(08) Katana")
				guiComboBoxAddItem(boxWeapons, "(09) Chainsaw")
				guiComboBoxAddItem(boxWeapons, "(01) Brass Knuckles")
				guiComboBoxAddItem(boxWeapons, "(34) Sniper")
				guiComboBoxAddItem(boxWeapons, "(26) Sawed-off")
				guiComboBoxAddItem(boxWeapons, "(33) Country Rifle")
				guiComboBoxAddItem(boxWeapons, "(27) Combat Shotgun")
				guiComboBoxAddItem(boxWeapons, "(35) Rocket Launcher")
			guiCreateLabel(220,58,8,15,"X",false,wWeaponsMain)
			eWeapons = guiCreateEdit(230,55,40,21,"1",false,wWeaponsMain)
				guiSetEnabled(eWeapons, false)
				guiEditSetReadOnly(eWeapons, true)
				guiSetAlpha(eWeapons, 0.3)
			lErrorWeap = guiCreateLabel(100,80,170,18,"",false,wWeaponsMain)
				guiLabelSetVerticalAlign(lErrorWeap,"top")
				guiSetFont(lErrorWeap,"default-small")
				guiLabelSetHorizontalAlign(lErrorWeap,"right")
				guiLabelSetColor(lErrorWeap,255,255,0)
			
			iAmmo = guiCreateStaticImage(300,57,57,57,"weapIcons/ammo.png",false,wWeaponsMain)
			lAmmo = guiCreateLabel(300,114,102,18,"Ammunition",false,wWeaponsMain)
				guiSetFont(lAmmo,"default-bold-small")
			boxAmmo = guiCreateComboBox(360,55,116,21,"None",false,wWeaponsMain)
				guiComboBoxAdjustHeight (  boxAmmo, 30 )
				guiComboBoxAddItem(boxAmmo, "None")
				guiComboBoxAddItem(boxAmmo, "(22) Colt 45")
				guiComboBoxAddItem(boxAmmo, "(24) Deagle")
				guiComboBoxAddItem(boxAmmo, "(23) Silenced")
				guiComboBoxAddItem(boxAmmo, "(25) Shotgun")
				guiComboBoxAddItem(boxAmmo, "(32) Tec-9")
				guiComboBoxAddItem(boxAmmo, "(28) Uzi")
				guiComboBoxAddItem(boxAmmo, "(29) MP5")
				guiComboBoxAddItem(boxAmmo, "(30) AK-47")
				guiComboBoxAddItem(boxAmmo, "(31) M4A1")
				guiComboBoxAddItem(boxAmmo, "(18) Molotov")
				guiComboBoxAddItem(boxAmmo, "(03) Nightstick ")
				guiComboBoxAddItem(boxAmmo, "(08) Katana")
				guiComboBoxAddItem(boxAmmo, "(09) Chainsaw")
				guiComboBoxAddItem(boxAmmo, "(01) Brass Knuckles")
				guiComboBoxAddItem(boxAmmo, "(34) Sniper")
				guiComboBoxAddItem(boxAmmo, "(26) Sawed-off")
				guiComboBoxAddItem(boxAmmo, "(33) Country Rifle")
				guiComboBoxAddItem(boxAmmo, "(27) Combat Shotgun")
				guiComboBoxAddItem(boxAmmo, "(35) Rocket Launcher")
			guiCreateLabel(480,58,8,15,"X",false,wWeaponsMain)
			eAmmo = guiCreateEdit(495,55,40,21,"1",false,wWeaponsMain)
				guiSetEnabled(eAmmo, false)
				guiEditSetReadOnly(eAmmo, true)
				guiSetAlpha(eAmmo, 0.3)
			lErrorAmmo = guiCreateLabel(367,78,170,18,"",false,wWeaponsMain)
				guiLabelSetVerticalAlign(lErrorAmmo,"top")
				guiSetFont(lErrorAmmo,"default-small")
				guiLabelSetHorizontalAlign(lErrorAmmo,"right")
				guiLabelSetColor(lErrorAmmo,255,255,0)
			
			lAmmoPerClip = guiCreateLabel(380,90,70,17,"Bullets/Mag:",false,wWeaponsMain)
				guiSetEnabled(lAmmoPerClip, false)
				guiSetAlpha(lAmmoPerClip, 0.3)
				guiLabelSetHorizontalAlign(lAmmoPerClip,"right")
			eAmmoPerClip = guiCreateEdit(450,90,85,17,"-1 (Full Clip)",false,wWeaponsMain)
				guiSetEnabled(eAmmoPerClip, false)
				guiEditSetReadOnly(eAmmoPerClip, true)
				guiSetAlpha(eAmmoPerClip, 0.3)
			addEventHandler("onClientGUIClick", eAmmoPerClip, function()
				guiSetText(eAmmoPerClip, "")
			end,false)
			lErroreAmmoPerClip = guiCreateLabel(367,108,170,18,"",false,wWeaponsMain)
				guiLabelSetVerticalAlign(lErroreAmmoPerClip,"top")
				guiSetFont(lErroreAmmoPerClip,"default-small")
				guiLabelSetHorizontalAlign(lErroreAmmoPerClip,"right")
				guiLabelSetColor(lErroreAmmoPerClip,255,255,0)
			
			guiCreateLabel(13,153,326,28,"Player you wish to spawn weapon to (Partial Name or ID):",false,wWeaponsMain)
			ePlayerName = guiCreateEdit(335,149,294,23,"",false,wWeaponsMain)
			lError = guiCreateLabel(280,169,326,28,"",false,wWeaponsMain)
				guiLabelSetVerticalAlign(lError,"top")
				guiSetFont(lError,"default-small")
				guiLabelSetHorizontalAlign(lError,"center")
				
			-- GUIEditor_Label[15] = guiCreateLabel(10,180,118,19,"Show logs after spawning: ",false,wWeaponsMain)
				-- guiSetFont(GUIEditor_Label[15],"default-small")
				-- guiLabelSetHorizontalAlign(GUIEditor_Label[15],"right")
			-- cbShowLogs = guiCreateCheckBox(130,177,22,19,"",false,false,wWeaponsMain)
			
			bHelp = guiCreateButton(65,190,100,30,"FULL MODE",false,wWeaponsMain)
				guiSetFont(bHelp,"default-bold-small")
			
			bSpawn = guiCreateButton(175,190,100,30,"SPAWN",false,wWeaponsMain)
				guiSetFont(bSpawn,"default-bold-small")
				guiSetEnabled(bSpawn, false)
			bSpawnc = guiCreateButton(285,190,100,30,"SPAWN & CLOSE",false,wWeaponsMain)
				guiSetFont(bSpawnc,"default-bold-small")
				guiSetEnabled(bSpawnc, false)
			bClose = guiCreateButton(395,190,100,30,"CANCEL",false,wWeaponsMain)
				guiSetFont(bClose,"default-bold-small")
			
		addEventHandler("onClientGUIChanged", ePlayerName, checkNameExists)
		addEventHandler ( "onClientGUIComboBoxAccepted", boxWeapons, boxWeaponsEnableOtherStuff)
		addEventHandler("onClientGUIChanged", eWeapons, validateWeaponAmount)
		addEventHandler ("onClientGUIComboBoxAccepted", boxAmmo, boxAmmoEnableOtherStuff)
		addEventHandler("onClientGUIChanged", eAmmo, validateAmmoAmount)
		addEventHandler("onClientGUIChanged", eAmmoPerClip, validateAmmoPerClip)
		addEventHandler("onClientGUIChanged", eAmmoPerClip, validateAround)
		addEventHandler ( "onClientGUIComboBoxAccepted", boxWeapons, validateAround)
		addEventHandler("onClientGUIChanged", eWeapons,  validateAround )
		addEventHandler ("onClientGUIComboBoxAccepted", boxAmmo, validateAround)
		addEventHandler("onClientGUIChanged", eAmmo, validateAround)
		addEventHandler("onClientGUIChanged", ePlayerName, validateAround )
		addEventHandler("onClientGUIClick", getRootElement(), onGuiClick)
	end
end
addCommandHandler("gunmaker", openWeaponCreatorMain, false, false)
--bindKey ( "F4", "up", openWeaponCreatorMain )     -- bind the player's F4 up key

function switchToFullMode()
	local sx, sy = guiGetScreenSize()
	local wWeaponsMain_y = sy/2-115
	local sizex, sizey = guiGetSize(wWeaponsMain, false)
	local x, y = guiGetPosition(wWeaponsMain, false)
	guiSetPosition(wWeaponsMain,x,wWeaponsMain_y-225, false) 
	guiSetSize(wWeaponsMain, sizex, sizey+ 450, false)
	guiSetText(wWeaponsMain, "Admin Weapon Creator v2.0 - FULL MODE")
	guiSetVisible(bHelp, false)
	bCloseChart = guiCreateButton(335,190,100,30,"QUICK MODE",false,wWeaponsMain)
		guiSetFont(bCloseChart,"default-bold-small")	
	
	guiSetPosition(bClose,450,190, false )
	
	guiSetVisible(bSpawn, false)
	guiSetVisible(bSpawnc, false)
	
	guiSetVisible(boxWeapons, false)
	guiSetVisible(boxAmmo, false)
	
	guiSetEnabled(eWeapons, true)
	guiEditSetReadOnly(eWeapons, false)
	guiSetAlpha(eWeapons, 1)
	
	guiSetEnabled(eAmmo, true)
	guiEditSetReadOnly(eAmmo, false)
	guiSetAlpha(eAmmo, 1)
	
	guiSetEnabled(lAmmoPerClip, true)
	guiSetAlpha(lAmmoPerClip, 1)
	
	guiSetEnabled(eAmmoPerClip, true)
	guiEditSetReadOnly(eAmmoPerClip, false)
	guiSetAlpha(eAmmoPerClip, 1)
	
	eWeaponBox = guiCreateEdit(100,55,116,21,"Double left click the list",false,wWeaponsMain)
		guiEditSetReadOnly(eWeaponBox,true)
	eAmmoBox = guiCreateEdit(360,55,116,21,"Double right click the list below",false,wWeaponsMain)
		guiEditSetReadOnly(eAmmoBox,true)
	
	HorLine = guiCreateStaticImage(9,180,542,1,"images/whitedot.jpg",false,wWeaponsMain)
	HorLine = guiCreateStaticImage(9,230,542,1,"images/whitedot.jpg",false,wWeaponsMain)
	verLine = guiCreateStaticImage(279,180,1,51,"images/whitedot.jpg",false,wWeaponsMain)
	local lhelp = guiCreateLabel(30,185,250,50,"- Double left click to spawn Weapon\n- Double right click to spawn ammunition\n- Middle click to copy weapon info",false,wWeaponsMain)
		guiSetFont(lhelp,"default-bold-small")
		guiLabelSetHorizontalAlign(lhelp,"left",false)
		guiLabelSetVerticalAlign(lhelp,"top",false)
		--guiLabelSetColor(lhelp, 100, 100 , 100)
	local gunChart1 = guiCreateGridList (10,231,560,460, false , wWeaponsMain)
	local columnID = guiGridListAddColumn( gunChart1, "ID", 0.1 )
	local columnName = guiGridListAddColumn( gunChart1, "Name", 0.3)
	local columnAmmoPerClip = guiGridListAddColumn( gunChart1, "Ammo/Clip", 0.1)
	local columnDamage = guiGridListAddColumn( gunChart1, "Damage", 0.1)
	local columnRange = guiGridListAddColumn( gunChart1, "Range", 0.1)
	local columnAccuracy = guiGridListAddColumn( gunChart1, "Accuracy", 0.1)
	local columnFiringSpeed = guiGridListAddColumn( gunChart1, "Firing Speed", 0.15)
	
	if columnID then 
		for id = 1 , 46 ,1 do
			if id == 20 or id == 21 or id == 19 or id == 40 then
			--Do nothing
			else
				local row = guiGridListAddRow ( gunChart1 )
				local weapName = getWeaponNameFromID (id):gsub( " ", "" )
				
				local weapRange = ""
				if getWeaponProperty (id, "std", "weapon_range") then
					if getWeaponProperty (id, "std", "weapon_range") > 1.7 then 
						weapRange = string.format("%.1f", getWeaponProperty (id, "std", "weapon_range"))
					else
						weapRange = ""
					end
				else
					weapRange = "Massive"
				end
				
				local weapDamage = ""
				if getWeaponProperty (id, "std", "damage") then
					if getWeaponProperty (id, "std", "damage") > 1.7 then 
						weapDamage = getWeaponProperty (id, "std", "damage")
					else
						weapDamage = ""
					end
				else
					weapDamage = "Massive"
				end
				
				local weapAmmoPerClip = ""
				if getWeaponProperty (id, "std", "maximum_clip_ammo") then
					weapAmmoPerClip = getWeaponProperty (id, "std", "maximum_clip_ammo")
					if weapAmmoPerClip == 0 then
						weapAmmoPerClip = ""
					end
					if weapAmmoPerClip == 1 then
						weapAmmoPerClip = 2
					end
				else
					weapAmmoPerClip = ""
				end
				
				local weapAccuracy = ""
				if getWeaponProperty (id, "std", "accuracy") then
					weapAccuracy = string.format("%d", getWeaponProperty (id, "std", "accuracy")*100).."%"
				end
				local weapFiringSpeed = ""
				if getWeaponProperty (id, "std", "firing_speed") then
					weapFiringSpeed = getWeaponProperty (id, "std", "firing_speed")
					if weapFiringSpeed == 0 then 
						weapFiringSpeed = "Instant"
					else
						weapFiringSpeed = string.format("%.2f", getWeaponProperty (id, "std", "firing_speed")).."s"
					end
				end
				
				guiGridListSetItemText ( gunChart1, row, columnID, id, false, false )
				guiGridListSetItemText ( gunChart1, row, columnName, weapName , false, false )
				guiGridListSetItemText ( gunChart1, row, columnAmmoPerClip, weapAmmoPerClip , false, false )
				guiGridListSetItemText ( gunChart1, row, columnDamage, weapDamage , false, false )
				guiGridListSetItemText ( gunChart1, row, columnRange, weapRange , false, false )
				guiGridListSetItemText ( gunChart1, row, columnAccuracy, weapAccuracy , false, false )
				guiGridListSetItemText ( gunChart1, row, columnFiringSpeed, weapFiringSpeed , false, false )
				
			end
		end
		
		function copyToBoxes( button )
			if button == "left" then
				local row, col = guiGridListGetSelectedItem( source )
				if row ~= -1 and col ~= -1 then
					local weapID = guiGridListGetItemText( source , row, col )
					local weapName = guiGridListGetItemText( source , row, col+1 )
					--outputChatBox(weapID.. "-"..weapName)
					guiSetText(eWeaponBox , "("..weapID..") "..weapName)
				else
					--outputChatBox( "[WEAPON CREATOR] You need to choose item before right clicking it.", 255, 0, 0 )
				end
			end
			
			if button == "middle" then
				local row, col = guiGridListGetSelectedItem( source )
				if row ~= -1 and col ~= -1 then
					local weapID = guiGridListGetItemText( source , row, col )
					--triggerServerEvent("admin:removehistory", getLocalPlayer(), gridID, name)
					-- destroyElement( wHist )
					-- wHist = nil
					
					-- showCursor( false )
					weapName = guiGridListGetItemText( source , row, col+1 )
					weapAmmoPerClip = guiGridListGetItemText( source , row, col+2 )
					weapDamage = guiGridListGetItemText( source , row, col+3 )
					weapAccuracy = guiGridListGetItemText( source , row, col+4 )
					weapFiringSpeed = guiGridListGetItemText( source , row, col+5 )	
					
					local tmp = weapName.." ("..weapID..")"
					if weapAmmoPerClip ~= "" then
						tmp = tmp.." - Ammo/clip: "..weapAmmoPerClip
					end
					if weapDamage ~= "" then
						tmp = tmp..", Damage: "..weapDamage
					end
					if weapAccuracy ~= "" then
						tmp = tmp..", Accuracy: "..weapAccuracy
					end
					if weapFiringSpeed ~= "" then
						tmp = tmp..", Firing Speed: "..weapFiringSpeed.."."
					end
					if setClipboard (tmp) then
						--outputChatBox( "[WEAPON CREATOR] Copied weapon info to clipboard.")
						guiSetText(lCoolDown, "Copied weapon info to clipboard.")
						guiLabelSetColor(lCoolDown, 0,255,0)
						setTimer(function ()
							guiSetText(lCoolDown, "")
						end,2000,1)
					end
				else
					--outputChatBox( "[WEAPON CREATOR] You need to select a weapon first.", 255, 0, 0 )
					guiSetText(lCoolDown, "You need to select a weapon first.")
					guiLabelSetColor(lCoolDown, 255,255,0)
					setTimer(function ()
						guiSetText(lCoolDown, "")
					end,2000,1)
					
				end
			end
			
			if button == "right" then
				local row, col = guiGridListGetSelectedItem( source )
				if row ~= -1 and col ~= -1 then
					local weapID = guiGridListGetItemText( source , row, col )
					local weapName = guiGridListGetItemText( source , row, col+1 )
					--outputChatBox(weapID.. "-"..weapName)
					guiSetText(eAmmoBox , "("..weapID..") "..weapName)
				else
					--outputChatBox( "[WEAPON CREATOR] You need to select a weapon first.", 255, 0, 0 )
					guiSetText(lCoolDown, "You need to select a weapon first.")
					guiLabelSetColor(lCoolDown, 255,255,0)
					setTimer(function ()
						guiSetText(lCoolDown, "")
					end,2000,1)
					
				end
			end
		end
		addEventHandler( "onClientGUIClick", gunChart1,copyToBoxes)
		
		function spawnWeaponAndAmmo( button )
			if button == "left" then
				local row, col = guiGridListGetSelectedItem( source )
				if row ~= -1 and col ~= -1 then
					local weapID = guiGridListGetItemText( source , row, col )
					if not targetPlayer then 
						guiSetText(lCoolDown, "Please input Target Player.")
						guiLabelSetColor(lCoolDown, 255,255,0)
						setTimer(function ()
							guiSetText(lCoolDown, "")
						end,2000,1)
					elseif not tonumber(guiGetText( eWeapons)) then
						guiSetText(lCoolDown, "Invalid amount of weapons.")
						guiLabelSetColor(lCoolDown, 255,255,0)
						setTimer(function ()
							guiSetText(lCoolDown, "")
						end,2000,1)
					else
						triggerServerEvent ("onMakeGun", getLocalPlayer(), getLocalPlayer(), "makegun" , targetPlayer, weapID , tostring(guiGetText( eWeapons)))
						spawnCooldown = true
						onCoolDown()
					end
				else
					outputChatBox( "[WEAPON CREATOR] You need to pick a weapon", 255, 0, 0 )
				end
			end
			
			if button == "right" then
				local row, col = guiGridListGetSelectedItem( source )
				if row ~= -1 and col ~= -1 then
					local weapID = guiGridListGetItemText( source , row, col )
					if not targetPlayer then 
						guiSetText(lCoolDown, "Please input Target Player.")
						guiLabelSetColor(lCoolDown, 255,255,0)
						setTimer(function ()
							guiSetText(lCoolDown, "")
						end,2000,1)
					elseif not tonumber(guiGetText( eAmmo)) then
						guiSetText(lCoolDown, "Invalid amount of ammopacks.")
						guiLabelSetColor(lCoolDown, 255,255,0)
						setTimer(function ()
							guiSetText(lCoolDown, "")
						end,2000,1)
					else
						triggerServerEvent ("onMakeAmmo", getLocalPlayer(), getLocalPlayer(), "makeammo" , targetPlayer, weapID , tostring(guiGetText( eAmmoPerClip)) ,tostring(guiGetText( eAmmo)))
						spawnCooldown = true
						onCoolDown()
					end
				else
					outputChatBox( "[WEAPON CREATOR] You need to pick a weapon", 255, 0, 0 )
				end
			end
		end
		addEventHandler( "onClientGUIDoubleClick", gunChart1,spawnWeaponAndAmmo)
	end

end	

function closeWeaponCreatorMain()
	removeEventHandler("onClientGUIClick", getRootElement(), onGuiClick)
	removeEventHandler("onClientGUIChanged", ePlayerName, checkNameExists)
	removeEventHandler("onClientGUIChanged", ePlayerName, validateAround )
	-----
	removeEventHandler ( "onClientGUIComboBoxAccepted", boxWeapons, boxWeaponsEnableOtherStuff)
	removeEventHandler ( "onClientGUIComboBoxAccepted", boxWeapons, validateAround)
	
	removeEventHandler("onClientGUIChanged", eWeapons, validateWeaponAmount)
	removeEventHandler("onClientGUIChanged", eWeapons,  validateAround )
	-----
	removeEventHandler ("onClientGUIComboBoxAccepted", boxAmmo, boxAmmoEnableOtherStuff)
	removeEventHandler ("onClientGUIComboBoxAccepted", boxAmmo, validateAround)
	
	removeEventHandler("onClientGUIChanged", eAmmo, validateAmmoAmount)
	removeEventHandler("onClientGUIChanged", eAmmo, validateAround)
	
	removeEventHandler("onClientGUIChanged", eAmmoPerClip, validateAmmoPerClip)
	removeEventHandler("onClientGUIChanged", eAmmoPerClip, validateAround)
	if wWeaponsMain then
		--killTimer(validateAroundTimer)
		destroyElement(wWeaponsMain)
		wWeaponsMain = nil
	end

	if gunChart1 then
		removeEventHandler("onClientGUIClick", bCloseChart, openWeaponCreatorMain)
		removeEventHandler( "onClientGUIDoubleClick", gunChart,copyToClipBoard)
	end
	showedLogs = nil
	showedLogs, targetPlayer = nil
	isWeaponAmountValid = nil
	isAmmoAmountValid = nil
	isAmmoPerClipValid = nil
	isTargetPlayerValid = nil
	targetPlayerName = nil
	wSelectedWepID = nil
	aSelectedWepID = nil
	spawnCooldown = nil
	
	showCursor(false)
	guiSetInputEnabled(false)
end

function showGunChart()
	if (exports.integration:isPlayerTrialAdmin(getLocalPlayer())) then
		showCursor(true)
		if wWeaponsMain then 
			outputChatBox( "[WEAPON CREATOR] Please close Weapon Creator first.", 255,0,0)
		elseif wWeaponsChart then
			closeGunChart()
		else
			local sx, sy = guiGetScreenSize()
			local wWeaponsMain_x = sx/2-280
			local wWeaponsMain_y = sy/2-225
			wWeaponsChart = guiCreateWindow(wWeaponsMain_x,wWeaponsMain_y,560,450,"Admin Weapon Chart",false)
				guiWindowSetSizable(wWeaponsChart,false)
			bCloseChart = guiCreateButton(500,20,70,20,"Close",false,wWeaponsChart)
				guiSetFont(bCloseChart,"default-bold-small")
			addEventHandler("onClientGUIClick", bCloseChart, closeGunChart)
			
			gunChart1 = guiCreateGridList (0,0.1,1,1, true , wWeaponsChart)
			local columnID = guiGridListAddColumn( gunChart1, "ID", 0.1 )
			local columnName = guiGridListAddColumn( gunChart1, "Name", 0.3)
			local columnAmmoPerClip = guiGridListAddColumn( gunChart1, "Ammo/Clip", 0.1)
			local columnDamage = guiGridListAddColumn( gunChart1, "Damage", 0.1)
			local columnRange = guiGridListAddColumn( gunChart1, "Range", 0.1)
			local columnAccuracy = guiGridListAddColumn( gunChart1, "Accuracy", 0.1)
			local columnFiringSpeed = guiGridListAddColumn( gunChart1, "Firing Speed", 0.15)
			
			if columnID then 
				for id = 1 , 46 ,1 do
					if id == 20 or id == 21 or id == 19 or id == 40 then
					--Do nothing
					else
						local row = guiGridListAddRow ( gunChart1 )
						local weapName = getWeaponNameFromID (id):gsub( " ", "" )
						
						local weapRange = ""
						if getWeaponProperty (id, "std", "weapon_range") then
							if getWeaponProperty (id, "std", "weapon_range") > 1.7 then 
								weapRange = string.format("%.1f", getWeaponProperty (id, "std", "weapon_range"))
							else
								weapRange = ""
							end
						else
							weapRange = "Massive"
						end
						
						local weapDamage = ""
						if getWeaponProperty (id, "std", "damage") then
							if getWeaponProperty (id, "std", "damage") > 1.7 then 
								weapDamage = getWeaponProperty (id, "std", "damage")
							else
								weapDamage = ""
							end
						else
							weapDamage = "Massive"
						end
						
						local weapAmmoPerClip = ""
						if getWeaponProperty (id, "std", "maximum_clip_ammo") then
							weapAmmoPerClip = getWeaponProperty (id, "std", "maximum_clip_ammo")
							if weapAmmoPerClip == 0 then
								weapAmmoPerClip = ""
							end
							if weapAmmoPerClip == 1 then
								weapAmmoPerClip = 2
							end
						else
							weapAmmoPerClip = ""
						end
						
						local weapAccuracy = ""
						if getWeaponProperty (id, "std", "accuracy") then
							weapAccuracy = string.format("%d", getWeaponProperty (id, "std", "accuracy")*100).."%"
						end
						local weapFiringSpeed = ""
						if getWeaponProperty (id, "std", "firing_speed") then
							weapFiringSpeed = getWeaponProperty (id, "std", "firing_speed")
							if weapFiringSpeed == 0 then 
								weapFiringSpeed = "Instant"
							else
								weapFiringSpeed = string.format("%.2f", getWeaponProperty (id, "std", "firing_speed")).."s"
							end
						end
						
						guiGridListSetItemText ( gunChart1, row, columnID, id, false, false )
						guiGridListSetItemText ( gunChart1, row, columnName, weapName , false, false )
						guiGridListSetItemText ( gunChart1, row, columnAmmoPerClip, weapAmmoPerClip , false, false )
						guiGridListSetItemText ( gunChart1, row, columnDamage, weapDamage , false, false )
						guiGridListSetItemText ( gunChart1, row, columnRange, weapRange , false, false )
						guiGridListSetItemText ( gunChart1, row, columnAccuracy, weapAccuracy , false, false )
						guiGridListSetItemText ( gunChart1, row, columnFiringSpeed, weapFiringSpeed , false, false )
						
					end
				end
				
				function copyToClipBoard( button )
					if button == "left" then
						local row, col = guiGridListGetSelectedItem( source )
						if row ~= -1 and col ~= -1 then
							local weapID = guiGridListGetItemText( source , row, col )
							--triggerServerEvent("admin:removehistory", getLocalPlayer(), gridID, name)
							-- destroyElement( wHist )
							-- wHist = nil
							
							-- showCursor( false )
							weapName = guiGridListGetItemText( source , row, col+1 )
							weapAmmoPerClip = guiGridListGetItemText( source , row, col+2 )
							weapDamage = guiGridListGetItemText( source , row, col+3 )
							weapAccuracy = guiGridListGetItemText( source , row, col+4 )
							weapFiringSpeed = guiGridListGetItemText( source , row, col+5 )	
							
							local tmp = weapName.." ("..weapID..")"
							if weapAmmoPerClip ~= "" then
								tmp = tmp.." - Ammo/clip: "..weapAmmoPerClip
							end
							if weapDamage ~= "" then
								tmp = tmp..", Damage: "..weapDamage
							end
							if weapAccuracy ~= "" then
								tmp = tmp..", Accuracy: "..weapAccuracy
							end
							if weapFiringSpeed ~= "" then
								tmp = tmp..", Firing Speed: "..weapFiringSpeed.."."
							end
							if setClipboard (tmp) then
								outputChatBox( "[WEAPON CREATOR] Copied weapon info to clipboard.")
								-- guiSetText(lCoolDown, "Copied weapon info to clipboard.")
								-- guiLabelSetColor(lCoolDown, 0,255,0)
								-- setTimer(function ()
									-- guiSetText(lCoolDown, "")
								-- end,2000,1)
							end
						end
					end
				end
				addEventHandler( "onClientGUIClick", gunChart1,copyToClipBoard)
			end		
		end
	end
end
addCommandHandler("gunids", showGunChart ,false, false)
addCommandHandler("gunlist", showGunChart ,false, false)	
addCommandHandler("gunchart", showGunChart ,false, false)
addCommandHandler("weaponchart", showGunChart ,false, false)

function closeGunChart()
	removeEventHandler( "onClientGUIClick", gunChart1,copyToClipBoard)
	removeEventHandler("onClientGUIClick", bCloseChart, closeGunChart)
	if wWeaponsChart then 
		destroyElement(wWeaponsChart)
	end
	showCursor(false)
	wWeaponsChart = nil
end

function onGuiClick(button, state)
	if button == "left" then
		if source == bClose then
			closeWeaponCreatorMain()
		elseif source == bSpawnc then		
			triggerEvent ( "onCoolDown", getRootElement() )
			if wSelectedWepID ~= nil then
				triggerServerEvent ("onMakeGun", getLocalPlayer(), getLocalPlayer(), "makegun" , targetPlayer, wSelectedWepID , tostring(guiGetText( eWeapons)))
				--spawnCooldown = true
			end
			if aSelectedWepID ~= nil then
				triggerServerEvent ("onMakeAmmo", getLocalPlayer(), getLocalPlayer(), "makeammo" , targetPlayer, aSelectedWepID , tostring(guiGetText( eAmmoPerClip)) ,tostring(guiGetText( eAmmo)))
				--spawnCooldown = true
			end
			closeWeaponCreatorMain()
		elseif source == bSpawn then	
			triggerEvent( "onCoolDown", getRootElement() )
			if wSelectedWepID ~= nil then
				triggerServerEvent ("onMakeGun", getLocalPlayer(), getLocalPlayer(), "makegun" , targetPlayer, wSelectedWepID , tostring(guiGetText( eWeapons)))
				spawnCooldown = true
			end
			if aSelectedWepID ~= nil then
				triggerServerEvent ("onMakeAmmo", getLocalPlayer(), getLocalPlayer(), "makeammo" , targetPlayer, aSelectedWepID , tostring(guiGetText( eAmmoPerClip)) ,tostring(guiGetText( eAmmo)))
				spawnCooldown = true
			end
		elseif source == bHelp then
			switchToFullMode()
		elseif source == bCloseChart then
			openWeaponCreatorMain()
		end
	end
end

function checkNameExists(theEditBox)
	local found = nil
	local count = 0
	
	
	local text = guiGetText(theEditBox)
	if text and #text > 0 then
		local players = getElementsByType("player")
		if tonumber(text) then
			local id = tonumber(text)
			for key, value in ipairs(players) do
				if getElementData(value, "playerid") == id then
					found = value
					count = 1
					break
				end
			end
		else
			for key, value in ipairs(players) do
				local username = string.lower(tostring(getPlayerName(value)))
				if string.find(username, string.lower(text)) then
					count = count + 1
					found = value
					break
				end
			end
		end
	end
	
	if (count>1) then
		isTargetPlayerValid = false
		
		guiSetText(lError, "Multiple Found.")
		guiLabelSetColor(lError, 255, 255, 0)
	elseif (count==1) then
		isTargetPlayerValid = true
		targetPlayerName = getPlayerName(found)
		guiSetText(lError, "Player Found: " .. getPlayerName(found) .. " (ID #" .. getElementData(found, "playerid") .. ")")
		guiLabelSetColor(lError, 0, 255, 0)
		targetPlayer = getElementData(found, "playerid") 
	elseif (count==0) then
		isTargetPlayerValid = false
		
		guiSetText(lError, "Player not found.")
		guiLabelSetColor(lError, 255, 0, 0)
	end
end

function validateWeaponAmount(theEditBox)
	if tonumber(guiGetText(theEditBox)) == nil then
		guiSetText(lErrorWeap, "Must be numberic!")
		isWeaponAmountValid = false
		
	else
		isWeaponAmountValid = true
		guiSetText(lErrorWeap,"")
	end
end

function validateAmmoAmount(theEditBox)
	if tonumber(guiGetText(theEditBox)) == nil then
		guiSetText(lErrorAmmo, "Must be numberic!")
		isAmmoAmountValid = false
		
	else
		isAmmoAmountValid = true
		guiSetText(lErrorAmmo,"")
	end
end

function validateAmmoPerClip(theEditBox)
	if tonumber(guiGetText(theEditBox)) == nil then
		guiSetText(lErroreAmmoPerClip, "Must be numberic!")
		isAmmoPerClipValid = false
		
	else
		isAmmoPerClipValid = true
		guiSetText(lErroreAmmoPerClip,"")
	end
end

function boxWeaponsEnableOtherStuff(boxWeapons)
	wSelectedWepID = tonumber(string.sub(guiComboBoxGetItemText ( boxWeapons, guiComboBoxGetSelected(boxWeapons)), 2, 3))
	if wSelectedWepID == nil then
		guiSetEnabled(eWeapons, false)
		guiSetAlpha(eWeapons, 0.3)
		guiEditSetReadOnly(eWeapons, true)
	else
		guiSetEnabled(eWeapons, true)
		guiSetAlpha(eWeapons, 1)
		guiEditSetReadOnly(eWeapons, false)
	end
end

function boxAmmoEnableOtherStuff(boxAmmo)
	aSelectedWepID = tonumber(string.sub(guiComboBoxGetItemText ( boxAmmo, guiComboBoxGetSelected(boxAmmo)), 2, 3))
	if aSelectedWepID == nil then
		guiSetEnabled(eAmmo, false)
		guiSetAlpha(eAmmo, 0.3)
		guiEditSetReadOnly(eAmmo, true)
		
		guiSetEnabled(lAmmoPerClip, false)
		guiSetAlpha(lAmmoPerClip, 0.3)
		
		guiSetEnabled(eAmmoPerClip, false)
		guiSetAlpha(eAmmoPerClip, 0.3)
		guiEditSetReadOnly(eAmmoPerClip, true)
		
	else
		guiSetEnabled(eAmmo, true)
		guiSetAlpha(eAmmo, 1)
		guiEditSetReadOnly(eAmmo, false)
		
		guiSetEnabled(lAmmoPerClip, true)
		guiSetAlpha(lAmmoPerClip, 1)
		
		guiSetEnabled(eAmmoPerClip, true)
		guiSetAlpha(eAmmoPerClip, 1)
		guiEditSetReadOnly(eAmmoPerClip, false)
	end
end

function validateAround()
	if spawnCooldown == false then 
		if wSelectedWepID ~= nil and aSelectedWepID ~= nil and isTargetPlayerValid then
			if isWeaponAmountValid and isAmmoAmountValid and isTargetPlayerValid then
				guiSetEnabled(bSpawnc, true)
				guiSetEnabled(bSpawn, true)
			else
				guiSetEnabled(bSpawnc, false)
				guiSetEnabled(bSpawn, false)
			end
		end
		
		if wSelectedWepID ~= nil and aSelectedWepID == nil and isTargetPlayerValid then
			if isWeaponAmountValid and isTargetPlayerValid then
				guiSetEnabled(bSpawnc, true)
				guiSetEnabled(bSpawn, true)
			else
				guiSetEnabled(bSpawnc, false)
				guiSetEnabled(bSpawn, false)
			end
		end
		
		if aSelectedWepID ~= nil and wSelectedWepID == nil and isTargetPlayerValid then
			if isAmmoAmountValid and isTargetPlayerValid then
				guiSetEnabled(bSpawnc, true)
				guiSetEnabled(bSpawn, true)
			else
				guiSetEnabled(bSpawnc, false)
				guiSetEnabled(bSpawn, false)
			end
		end
		
		if aSelectedWepID == nil and wSelectedWepID == nil and isTargetPlayerValid then
			guiSetEnabled(bSpawnc, false)
			guiSetEnabled(bSpawn, false)
		end
	else
		guiSetEnabled(bSpawnc, false)
		guiSetEnabled(bSpawn, false)
	end
end

addEvent("onCoolDown", true)
function onCoolDown()
	spawnCooldown = true
	if wWeaponsMain and isElement(wWeaponsMain) then
		guiSetEnabled(wWeaponsMain, false)
	end
	if lCoolDown and isElement(lCoolDown) then
		guiSetText(lCoolDown, "Cooldown...")
	end
	function timer()
		spawnCooldown = false
		if wWeaponsMain and isElement(wWeaponsMain) then
			guiSetEnabled(wWeaponsMain, true)
		end
		if lCoolDown and isElement(lCoolDown) then
			guiSetText(lCoolDown, "")
		end
	end
	timerCool2 = setTimer(timer, 1000, 1)
end
addEventHandler("onCoolDown", getRootElement(), onCoolDown)

function guiComboBoxAdjustHeight ( combobox, itemcount )
    if getElementType ( combobox ) ~= "gui-combobox" or type ( itemcount ) ~= "number" then error ( "Invalid arguments @ 'guiComboBoxAdjustHeight'", 2 ) end
    local width = guiGetSize ( combobox, false )
    return guiSetSize ( combobox, width, ( itemcount * 20 ) + 20, false )
end


