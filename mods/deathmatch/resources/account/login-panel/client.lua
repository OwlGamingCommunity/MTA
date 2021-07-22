--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local panel = {
		login = {},
		register = {},
		sounds = {
			{ 'http://files.owlgaming.net/menu.mp3', 0.3 },
			{ 'http://files.owlgaming.net/gtav.mp3', 0.3 },
			{ 'http://files.owlgaming.net/gtaiv.mp3', 0.3 },
		}
	}
local sw, sh = guiGetScreenSize()
local fade = { }
local logoScale = 0.5
local logoSize = { sw*logoScale, sw*455/1920*logoScale }
local uFont

function startLoginSound()
	local setting = loadMusicSetting()
	if setting == 0 then
		local sound = math.random( 1, 3 )
		local bgMusic = playSound ( panel.sounds[ sound ][ 1 ], true )
		if bgMusic then
			setSoundVolume( bgMusic, panel.sounds[ sound ][ 2 ] )
		end
		setElementData(localPlayer, "bgMusic", bgMusic , false)
	end
	updateSoundLabel(setting)
end

function open_log_reg_pannel()
	if not isElement ( panel.login.main ) then
		-- blur screen.
		triggerEvent( 'hud:blur', resourceRoot, 'off', true )
		setTimer( triggerEvent, 8000, 1, 'hud:blur', resourceRoot, 6, true, 0.1, nil )

		-- sound effects.
		triggerEvent("account:showMusicLabel", localPlayer)
		startLoginSound()
		
		-- prepare.
		showChat(false)
		showCursor(true)
		guiSetInputEnabled(true)
		local Width,Height = 350,350
		local X = (sw/2) - (Width/2)
		local Y = (sh/2) - (Height/2)
		ufont = ufont or guiCreateFont( ':interior_system/intNameFont.ttf', 11 )

		panel.login.main = guiCreateStaticImage( X, Y, 350, 350, "/login-panel/login_window.png", false )
		guiSetEnabled (panel.login.main, false)

		--panel.login.logo = guiCreateStaticImage( (sw-logoSize[1])/2, logoSize[2]/2, logoSize[1], logoSize[2], "/login-panel/OwlLogo7.png", false )
		panel.login.logo = guiCreateStaticImage( (sw-logoSize[1])/2, (sh-logoSize[2])/2 , logoSize[1], logoSize[2], "/login-panel/OwlLogo7.png", false )
		local x, y = guiGetPosition( panel.login.logo, false )
		--guiSetPosition( panel.login.logo, x, -logoSize[2], false )


		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		panel.login.login = guiCreateStaticImage( X + 23, Y + 349-120, 301, 44, "/login-panel/login.png", false )
		addEventHandler("onClientGUIClick",panel.login.login,onClickBtnLogin, false )
		addEventHandler( "onClientMouseEnter",panel.login.login,LoginSH)
		addEventHandler("onClientMouseLeave",panel.login.login,SErem)

		panel.login.username = guiCreateEdit(X + 20,Y + 220-120,310,35,"",false)
		panel.login.password = guiCreateEdit(X + 20,Y + 295-120,310,35,"",false)
		guiSetFont( panel.login.username, ufont )
		guiSetFont( panel.login.password, ufont )
		guiEditSetMaxLength ( panel.login.username,25)
		guiEditSetMasked ( panel.login.password, true )
		guiSetProperty( panel.login.password, 'MaskCodepoint', '8226' )

		addEventHandler("onClientGUIChanged", panel.login.username, resetLogButtons)
		addEventHandler("onClientGUIChanged", panel.login.password, resetLogButtons)
		addEventHandler( "onClientGUIAccepted", panel.login.username, startLoggingIn)
		addEventHandler( "onClientGUIAccepted", panel.login.password, startLoggingIn)
		--[[
		lbl_about_legth = guiCreateLabel(142,42,184,18,"",false)
		guiLabelSetColor(lbl_about_legth,253,255,68)
		guiLabelSetVerticalAlign(lbl_about_legth,"center")
		guiLabelSetHorizontalAlign(lbl_about_legth,"center",false)
		]]
		panel.login.remember = guiCreateCheckBox(X + 230,Y + 275-120,100,20,"(Remember me!)",false,false)
		guiSetFont(panel.login.remember,"default-small")

		panel.login.error = guiCreateLabel(X,Y + 325-120,364,31,"Error_login_tab",false)
		guiLabelSetColor(panel.login.error,255,0,0)
		guiLabelSetVerticalAlign(panel.login.error,"center")
		guiLabelSetHorizontalAlign(panel.login.error,"center",false)
		guiSetFont(panel.login.error,"default-bold-small")

		panel.login.authen = guiCreateLabel(X,Y + 325-120,364,31,"Authen_login_tab",false)
		guiLabelSetColor(panel.login.authen,0,255,0)
		guiLabelSetVerticalAlign(panel.login.authen,"center")
		guiLabelSetHorizontalAlign(panel.login.authen,"center",false)
		guiSetFont(panel.login.authen,"default-bold-small")


		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		panel.login.register = guiCreateStaticImage( X + 23, Y + 401-120, 301, 44, "/login-panel/signup.png", false ) -- A gomb
		addEventHandler("onClientGUIClick",panel.login.register,OnBtnRegister, false )
		addEventHandler( "onClientMouseEnter",panel.login.register,SignupSH)
		addEventHandler("onClientMouseLeave",panel.login.register,SErem)

		panel.login.toplabel = guiCreateLabel(X - 70,Y + 388+70-120,500,30,"",false)
		guiLabelSetColor(panel.login.toplabel,255,234,55)
		guiLabelSetVerticalAlign(panel.login.toplabel,"center")
		guiLabelSetHorizontalAlign(panel.login.toplabel,"center",false)
		guiSetFont(panel.login.toplabel,"default-bold-small")
		guiSetVisible(panel.login.toplabel,false)

		panel.login.username2 = guiCreateEdit(X + 20,Y + 215-120,310,35,"",false)
		guiEditSetMaxLength ( panel.login.username2,25)
		guiSetVisible(panel.login.username2,false)
		guiSetFont( panel.login.username2, ufont )
		addEventHandler("onClientGUIChanged", panel.login.username2, resetRegButtons)

		panel.login.password2 = guiCreateEdit(X + 20,Y + 290-120,310,35,"",false)
		guiEditSetMaxLength ( panel.login.password2,25)
		guiEditSetMasked ( panel.login.password2, true )
		guiSetProperty(panel.login.password2, 'MaskCodepoint', '8226')
		guiSetVisible(panel.login.password2,false)
		guiSetFont( panel.login.password2, ufont )
		addEventHandler("onClientGUIChanged", panel.login.password2, resetRegButtons)

		panel.login.repassword = guiCreateEdit(X + 20,Y + 365-120,310,35,"",false)
		guiEditSetMaxLength ( panel.login.repassword,25)
		guiEditSetMasked ( panel.login.repassword, true )
		guiSetProperty(panel.login.repassword, 'MaskCodepoint', '8226')
		guiSetVisible(panel.login.repassword,false)
		guiSetEnabled (panel.login.repassword, true)
		guiSetFont( panel.login.repassword, ufont )
		addEventHandler("onClientGUIChanged", panel.login.repassword, resetRegButtons)

		panel.login.email = guiCreateEdit(X + 20,Y + 435-120,310,35,"",false)
		guiEditSetMaxLength ( panel.login.email,100)
		--guiEditSetMasked ( panel.login.email, true )
		guiSetVisible(panel.login.email,false)
		guiSetFont( panel.login.email, ufont )
		guiSetEnabled (panel.login.email, true)
		addEventHandler("onClientGUIChanged", panel.login.email, resetRegButtons)

		--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		panel.login.register2 = guiCreateStaticImage( X + 182, Y + 401+6+70-120, 143, 45, "/login-panel/register.png", false )--guiCreateStaticImage( X + 23, Y + 409, 301, 44, "/login-panel/register2.png", false )
		addEventHandler("onClientGUIClick",panel.login.register2,onClickBtnRegister, false )
		addEventHandler( "onClientMouseEnter",panel.login.register2,Register2SH)
		addEventHandler("onClientMouseLeave",panel.login.register2,SErem)
		guiSetVisible(panel.login.register2,false)

		panel.login.cancel = guiCreateStaticImage( X + 23, Y + 401+6+70-120, 143, 45, "/login-panel/cancel.png", false ) -- A gomb
		addEventHandler("onClientGUIClick",panel.login.cancel,onClickCancel, false )
		addEventHandler( "onClientMouseEnter",panel.login.cancel,CancelSH)
		addEventHandler("onClientMouseLeave",panel.login.cancel,SErem)
		guiSetVisible(panel.login.cancel,false)

		showCursor(true)

		guiSetText(panel.login.error, "")
		guiSetText(panel.login.authen, "")

		local username, password = loadLoginFromXML()
		if username ~= "" then
			guiCheckBoxSetSelected ( panel.login.remember, true )
			guiSetText ( panel.login.username, tostring(username))
			guiSetText ( panel.login.password, tostring(password))
		else
			guiCheckBoxSetSelected ( panel.login.remember, false )
			guiSetText ( panel.login.username, tostring(username))
			guiSetText ( panel.login.password, tostring(password))
		end

		guisSetEnabled( 'login', false )
		guisSetPosition( 'login', (sw+Width)/2 )

		-- fade the login tab in.
		setTimer( fade.login, 8000, 1 , (sw+Width)/2 )

		-- dynamic screen effect.
		addEventHandler( 'onClientRender', root, slideScreen )

		-- make sure screen isn't black.
		fadeCamera ( true )
	end
end

function guisSetEnabled( part, state )
	for index, gui in pairs( panel[ part ] ) do
		if index ~= 'main' then
			guiSetEnabled( gui , state )
		end
	end
end

function guisSetPosition( part, x_, y_ )
	for index, gui in pairs( panel[ part ] ) do
		if index ~= 'logo' then
			local x, y = guiGetPosition( gui, false )
			if x_ then
				x = x + x_
			end
			if y_ then
				y = y + y_
			end
			guiSetPosition( gui, x, y, false )
		end
	end
end

function fade.render( )
	fade.cur = fade.cur + fade.dir
	fade.logo_start = fade.logo_start + fade.logo_dir
	if math.abs(fade.cur) <= fade.max then
		guisSetPosition( 'login', fade.dir )
		guiSetPosition( panel.login.logo, fade.logo_x, fade.logo_start, false )
	else
		guisSetEnabled( 'login', true )
		removeEventHandler( 'onClientRender', root, fade.render )
	end
end

function fade.login( max )
	fade.cur = 0
	fade.max = max
	fade.dir = -fade.max/50
	fade.logo_start = (sh-logoSize[2])/2
	fade.logo_end = sh - logoSize[2]*3/2
	fade.logo_dir = -(fade.logo_end-fade.logo_start)/50
	fade.logo_x = (sw-logoSize[1])/2
	addEventHandler( 'onClientRender', root, fade.render )
end

local speed = 0.01
local moved = 0

function slideScreen()
	local matrix = { getCameraMatrix ( localPlayer ) }
	matrix[1] = matrix[1] + speed
	moved = moved + speed
	if moved > 50 then
		local scr = shuffleScreen()
		moved = 0
		setCameraMatrix ( scr[1], scr[2], scr[3], scr[4], scr[5], scr[6], 0, exports.global:getPlayerFov())
	else
		setCameraMatrix ( unpack(matrix) )
	end
end

function LoginSH ()
	guiStaticImageLoadImage(panel.login.login, "/login-panel/sh.png" )
end

function SignupSH ()
	guiStaticImageLoadImage(panel.login.register, "/login-panel/signup2.png" )
end

function Register2SH ()
	guiStaticImageLoadImage(panel.login.register, "/login-panel/shr.png" )
end

function CancelSH ()
	guiStaticImageLoadImage(panel.login.cancel, "/login-panel/cancel2.png" )
end

function SErem ()
	guiStaticImageLoadImage(panel.login.login, "/login-panel/login.png" )
	guiStaticImageLoadImage(panel.login.register, "/login-panel/signup.png" )
	guiStaticImageLoadImage(panel.login.register2, "/login-panel/register.png" )
	guiStaticImageLoadImage(panel.login.cancel, "/login-panel/cancel.png" )
end

--[[
function start_cl_resource()
	open_log_reg_pannel()
end
addEventHandler("onClientResourceStart",getResourceRootElement(getThisResource()),start_cl_resource)
]]

function loadLoginFromXML()
	local xml_save_log_File = xmlLoadFile ("@rememberme.xml")
    if not xml_save_log_File then
        xml_save_log_File = xmlCreateFile("@rememberme.xml", "login")
    end
    local usernameNode = xmlFindChild (xml_save_log_File, "username", 0)
    local passwordNode = xmlFindChild (xml_save_log_File, "password", 0)
    local username, password = usernameNode and exports.global:decryptString(xmlNodeGetValue(usernameNode), localPlayer) or "", passwordNode and exports.global:decryptString(xmlNodeGetValue(passwordNode), localPlayer) or ""
    xmlUnloadFile ( xml_save_log_File )
    return username, password
end

function saveLoginToXML(username, password)
    local xml_save_log_File = xmlLoadFile ("@rememberme.xml")
    if not xml_save_log_File then
        xml_save_log_File = xmlCreateFile("@rememberme.xml", "login")
    end
	if (username ~= "") then
		local usernameNode = xmlFindChild (xml_save_log_File, "username", 0)
		local passwordNode = xmlFindChild (xml_save_log_File, "password", 0)
		if not usernameNode then
			usernameNode = xmlCreateChild(xml_save_log_File, "username")
		end
		if not passwordNode then
			passwordNode = xmlCreateChild(xml_save_log_File, "password")
		end
		xmlNodeSetValue (usernameNode, exports.global:encryptString(username, localPlayer))
		xmlNodeSetValue (passwordNode, exports.global:encryptString(password, localPlayer))
	end
    xmlSaveFile(xml_save_log_File)
    xmlUnloadFile (xml_save_log_File)
end
addEvent("saveLoginToXML", true)
addEventHandler("saveLoginToXML", getRootElement(), saveLoginToXML)

function saveMusicSetting(state)
	if not state then return false end
	local xmlFile = xmlLoadFile("@rememberme.xml")
	if not xmlFile then 
		xmlFile = xmlCreateFile("@rememberme.xml", "login")
	end

	local settingNode = xmlFindChild(xmlFile, "loginMusic", 0)
	if not settingNode then 
		settingNode = xmlCreateChild(xmlFile, "loginMusic")
	end

	xmlNodeSetValue(settingNode, state)
	xmlSaveFile(xmlFile)
	xmlUnloadFile(xmlFile)

	updateSoundLabel(state)
end

function loadMusicSetting()
	local xmlFile = xmlLoadFile ("@rememberme.xml")
	if not xmlFile then 
		return saveMusicSetting(0)
	end
	
	local settingNode = xmlFindChild(xmlFile, "loginMusic", 0)
	local setting = xmlNodeGetValue(settingNode)
	xmlUnloadFile(xmlFile)
	return tonumber(setting)
end

function resetSaveXML()
	local xml_save_log_File = xmlLoadFile ("@rememberme.xml")
    if xml_save_log_File then
		local username, password = xmlFindChild(xml_save_log_File, "username", 0), xmlFindChild (xml_save_log_File, "password", 0)
		if username and password then 
			xmlDestroyNode(username)
			xmlDestroyNode(password)
			xmlSaveFile(xml_save_log_File)
			xmlUnloadFile(xml_save_log_File)
		end
	end
end
addEvent("resetSaveXML", true)
addEventHandler("resetSaveXML", getRootElement(), resetSaveXML)

function onClickBtnLogin(button,state)
	if(button == "left" and state == "up") then
		if (source == panel.login.login) then
			startLoggingIn()
		end
	end
end

local loginClickTimer = nil
function startLoggingIn()
	if not getElementData(localPlayer, "clickedLogin") then
		setElementData(localPlayer, "clickedLogin", true, false)
		if isTimer(loginClickTimer) then
			killTimer(loginClickTimer)
		end
		loginClickTimer = setTimer(setElementData, 1000, 1, localPlayer, "clickedLogin", nil, false)

		username = guiGetText(panel.login.username)
		password = guiGetText(panel.login.password)
			if guiCheckBoxGetSelected ( panel.login.remember ) == true then
				checksave = true
			else
				checksave = false
			end
		playSoundFrontEnd ( 6 )
		guiSetEnabled(panel.login.login, false)
		guiSetAlpha(panel.login.login, 0.3)
		triggerServerEvent("accounts:login:attempt", getLocalPlayer(), username, password, checksave)
		authen_msg("Login", "Sending request to server..")
	else
		Error_msg("Login", "Slow down..")
	end
end

function hideLoginPanel(keepBG)
	showCursor(true)
	if keepBG then
		for name, gui in pairs( panel.login ) do
			if name ~= 'logo' then
				guiSetVisible( gui, false)
			end
		end
	else
		for name, gui in pairs( panel.login ) do
			if gui and isElement( gui ) then
				destroyElement( gui )
				gui = nil
			end
		end
		triggerEvent( 'hud:blur', resourceRoot, 'off', true )
		removeEventHandler( 'onClientRender', root, slideScreen )
	end
end
addEvent("hideLoginPanel", true)
addEventHandler("hideLoginPanel", getRootElement(), hideLoginPanel)


function OnBtnRegister ()
	switchToRegisterPanel() -- Disabled registration
	playSoundFrontEnd ( 2 )
	--guiSetText(panel.login.error, "Please register on Owlgaming.net/register.php")
end

function onClickCancel()
	switchToLoginPanel()
	playSoundFrontEnd ( 2 )
end

function switchToLoginPanel()
	guiSetText(panel.login.error, "")
	guiSetText(panel.login.authen, "")
	guiSetText(panel.login.toplabel, "")

	guiSetSize(panel.login.main, 350,350, false)
	guiStaticImageLoadImage(panel.login.main, "login-panel/Login_window.png" )
	guiSetVisible(panel.login.register2, false)
	guiSetVisible(panel.login.cancel,false)
	guiSetVisible(panel.login.toplabel,false)
	guiSetVisible(panel.login.repassword,false)
	guiSetEnabled (panel.login.repassword, false)
	guiSetVisible(panel.login.email,false)
	guiSetEnabled (panel.login.email, false)
	guiSetVisible(panel.login.password2,false)
	guiSetVisible(panel.login.username2,false)
	guiSetVisible(panel.login.register, true)
	guiSetVisible(panel.login.login, true)
	guiSetVisible(panel.login.password, true)
	guiSetVisible(panel.login.username, true)
	guiSetVisible(panel.login.remember, true)
	showCursor(true)
end

function switchToRegisterPanel()
	guiSetText(panel.login.error, "")
	guiSetText(panel.login.authen, "")
	guiSetText(panel.login.toplabel, "")

	guiSetSize(panel.login.main, 350,421, false)
	guiStaticImageLoadImage(panel.login.main, "login-panel/register_window.png" )
	guiSetVisible(panel.login.register2, true)
	guiSetVisible(panel.login.cancel,true)
	guiSetVisible(panel.login.toplabel,true)
	guiSetVisible(panel.login.repassword,true)
	guiSetEnabled (panel.login.repassword, true)
	guiSetVisible(panel.login.password2,true)
	guiSetVisible(panel.login.username2,true)
	guiSetVisible(panel.login.email,true)
	guiSetEnabled (panel.login.email, true)
	guiSetVisible(panel.login.register, false)
	guiSetVisible(panel.login.login, false)
	guiSetVisible(panel.login.password, false)
	guiSetVisible(panel.login.username, false)
	guiSetVisible(panel.login.remember, false)
	showCursor(true)
	setElementData(localPlayer, "switched", true, false)
end

function onClickBtnRegister(button,state)
	username = guiGetText(panel.login.username2)
	password = guiGetText(panel.login.password2)
	passwordConfirm = guiGetText(panel.login.repassword)
	email = guiGetText(panel.login.email)
	registerValidation(username, password, passwordConfirm,email)

	--playSoundFrontEnd ( 6 )
	guiSetEnabled(panel.login.register, false)
	guiSetAlpha(panel.login.register, 0.3)
end

function registerValidation(username, password, passwordConfirm, email)
	if not username or username == "" or not password or password == "" or not passwordConfirm or passwordConfirm == "" or not email or email == ""  then
		guiSetText(panel.login.toplabel, "Please fill out all fields.")
		guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
		playSoundFrontEnd ( 4 )
	elseif string.len(username) < 3 then
		guiSetText(panel.login.toplabel, "Username must be 3 characters or longer.")
		guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
		playSoundFrontEnd ( 4 )
	elseif string.len(username) >= 19 then
		guiSetText(panel.login.toplabel, "Username must be less then 20 characters long.")
		guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
		playSoundFrontEnd ( 4 )
	elseif string.find(username, ' ') then
		guiSetText(panel.login.toplabel, "Invalid Username.")
		guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
		playSoundFrontEnd ( 4 )
	elseif string.find(password, "'") or string.find(password, '"') then
		guiSetText(panel.login.toplabel, "Password must not contain ' or "..'"')
		guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
		playSoundFrontEnd ( 4 )
	elseif string.len(password) < 8 then
		guiSetText(panel.login.toplabel, "Password must be 8 characters or longer.")
		guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
		playSoundFrontEnd ( 4 )
	elseif string.len(password) > 25 then
		guiSetText(panel.login.toplabel, "Password must be less than 25 characters long.")
		guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
		playSoundFrontEnd ( 4 )
	elseif password ~= passwordConfirm then
		guiSetText(panel.login.toplabel, "Passwords mismatched!")
		guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
		playSoundFrontEnd ( 4 )
	elseif string.match(username,"%W") then
		guiSetText(panel.login.toplabel, "\"!@#$\"%'^&*()\" are not allowed in username.")
		guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
		playSoundFrontEnd ( 4 )
	else
		local validEmail, reason = exports.global:isEmail(email)
		if not validEmail then
			guiSetText(panel.login.toplabel, reason)
			guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
			playSoundFrontEnd ( 4 )
		else
			triggerServerEvent("accounts:register:attempt",getLocalPlayer(),username,password,passwordConfirm, email)
			authen_msg("Register", "Sending request to server.")
		end
	end
end

function registerComplete(username, pw, email)
	guiSetText(panel.login.username, username)
	guiSetText(panel.login.password, pw)
	playSoundFrontEnd(13)
	displayRegisterConpleteText(username, email)
end
addEvent("accounts:register:complete",true)
addEventHandler("accounts:register:complete",getRootElement(),registerComplete)

function displayRegisterConpleteText(username)
	local GUIEditor = {
	    button = {},
	    window = {},
	    label = {}
	}

	local extend = 100
	local yoffset = 150

	GUIEditor.window[1] = guiCreateWindow(667, 381, 357, 189+extend, "Congratulations! Account has been successfully created!", false)
	exports.global:centerWindow(GUIEditor.window[1])
	--local x, y = guiGetPosition(GUIEditor.window[1], false)
	--guiSetPosition(GUIEditor.window[1], x, y+yoffset, false)
	guiSetAlpha(GUIEditor.window[1], 1)
    guiWindowSetMovable(GUIEditor.window[1], false)
    guiWindowSetSizable(GUIEditor.window[1], false)
    guiSetProperty(GUIEditor.window[1], "AlwaysOnTop", "True")
    local temp = "An email contains instructions to activate your account has been dispatched, please check your email's inbox.\n\nIf for some reasons you don't receive the email, please check your junk box or try to dispatch another activation email at https://owlgaming.net/account/"
    GUIEditor.label[1] = guiCreateLabel(8, 50, 339, 121+extend, "Your OwlGaming MTA account for '"..username.."' is almost ready for action!\n\n"..temp.."\n\nSincerely, \nOwlGaming Community OwlGaming Development Team\"", false, GUIEditor.window[1])
    guiLabelSetHorizontalAlign(GUIEditor.label[1], "left", true)

    GUIEditor.button[1] = guiCreateButton(10, 153+extend, 337, 26, "Copy Activation Link", false, GUIEditor.window[1])
    addEventHandler("onClientGUIClick", GUIEditor.button[1], function()
    	if source == GUIEditor.button[1] then
    		if isElement(GUIEditor.window[1]) then
    			destroyElement(GUIEditor.window[1])
    			GUIEditor = nil
    			switchToLoginPanel()
    			setClipboard("https://owlgaming.net/account/")
    		end
    	else
    		cancelEvent()
    	end
    end, false )
end

function Error_msg(Tab, Text)
showCursor(true)
	if Tab == "Login" then
		playSoundFrontEnd ( 4)
		guiSetVisible(panel.login.register, true)
		guiSetVisible(panel.login.login, true)
		guiSetVisible(panel.login.password, true)
		guiSetVisible(panel.login.username, true)
		guiSetVisible(panel.login.remember, true)
		guiSetVisible(panel.login.main, true)

		guiSetText(panel.login.authen, "")
		guiSetText(panel.login.error, tostring(Text))
		--setTimer(function() guiSetText(panel.login.error, "") end,3000,1)
	else
		playSoundFrontEnd ( 4)
		guiSetText(panel.login.toplabel, tostring(Text))
		guiLabelSetColor ( panel.login.toplabel, 255, 0, 0 )
	end
end
addEvent("set_warning_text",true)
addEventHandler("set_warning_text",getRootElement(),Error_msg)

function authen_msg(Tab, Text)
showCursor(true)
	if Tab == "Login" then
		if panel.login.authen and isElement(panel.login.authen) and guiGetVisible(panel.login.authen) then
			--playSoundFrontEnd ( 12)
			guiSetVisible(panel.login.register, true)
			guiSetVisible(panel.login.login, true)
			guiSetVisible(panel.login.password, true)
			guiSetVisible(panel.login.username, true)
			guiSetVisible(panel.login.remember, true)
			guiSetVisible(panel.login.main, true)

			guiSetText(panel.login.error, "")
			guiSetText(panel.login.authen, tostring(Text))
			--setTimer(function() guiSetText(panel.login.authen, "") end,3000,1)
		end
	else
		--playSoundFrontEnd ( 12 )
		guiSetText(panel.login.toplabel, tostring(Text))
		guiLabelSetColor ( panel.login.toplabel, 255, 255, 255 )
	end
end
addEvent("set_authen_text",true)
addEventHandler("set_authen_text",getRootElement(),authen_msg)


function hideLoginWindow()
	showCursor(false)
	hideLoginPanel()
end
addEvent("hideLoginWindow", true)
addEventHandler("hideLoginWindow", getRootElement(), hideLoginWindow)

function CursorError ()
showCursor(false)
end
addCommandHandler("showc", CursorError)

function resetRegButtons ()
	guiSetEnabled(panel.login.register2, true)
	guiSetAlpha(panel.login.register2, 1)
end

function resetLogButtons()
	guiSetEnabled(panel.login.login, true)
	guiSetAlpha(panel.login.login, 1)
end


local screenStandByCurrent = 0
local screenStandByComplete = 2
local screenStandByShowing = false
function screenStandBy(action, value) -- Maxime / 2015.3.25
	if action == "add" then
		screenStandByCurrent = screenStandByCurrent + 1
		if screenStandByShowing then
			authen_msg("Login", "Loading prerequisite resources.."..screenStandBy("getPercentage").."%")
		end
		return screenStandByCurrent
	elseif action == "getCurrent" then
		return screenStandByCurrent
	elseif action == "getState" then
		return screenStandByShowing
	elseif action == "setState" then
		screenStandByShowing = value
		if screenStandByShowing then
			authen_msg("Login", "Loading prerequisite resources.."..screenStandBy("getPercentage").."%")
		end
		screenStandByCurrent = 0
		return true
	elseif action == "getPercentage" then
		local percentage = math.floor(screenStandByCurrent/screenStandByComplete*100)
		if screenStandByShowing then
			authen_msg("Login", "Loading prerequisite resources.."..percentage.."%")
		end
		return percentage
	end
end
addEvent("screenStandBy",true)
addEventHandler("screenStandBy",root,screenStandBy)

addEventHandler ( "onClientElementDataChange", localPlayer,
function ( dataName )
	if getElementType ( localPlayer ) == "player" and dataName == "loggedin" then
		showChat(getElementData(localPlayer, "loggedin") == 1)
	end
end )

--

addEventHandler("onClientResourceStart", resourceRoot, function()
	-- migrate the public file :account/login-panel/rememberme.xml to private resource @account/rememberme.xml
	if fileExists("/login-panel/rememberme.xml") then
		if not fileExists("@rememberme.xml") then
			fileCopy("/login-panel/rememberme.xml", "@rememberme.xml")
		end
		fileDelete("/login-panel/rememberme.xml")
	end
end)
