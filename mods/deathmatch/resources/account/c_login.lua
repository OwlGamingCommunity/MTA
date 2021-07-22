--Globals
local lUsername, tUsername, lPassword, tPassword, chkRememberLogin, bLogin, bRegister, defaultingTimer = nil
local newsTitle, newsText, newsAuthor
local loginTitleText = "OwlGaming MTA Roleplay"
local old_screen
--Settings block for c_characters.lua/line 87
loginScreens = {
	[1] = { 1324.1245117188, -718.6396484375, 110.76223754883, 1341.3719482422, -817.13720703125, 109.88974761963 },
	[2] = { 2174.9399414063, -1064.8714599609, 79.458114624023, 2085.4343261719, -1109.4544677734, 78.4111328125 },
	[3] = { 2088.4868164063, -1751.0032958984, 13.419298171997, 1991.2004394531, -1772.8931884766, 20.915758132935 },
	[4] = { 1393.1622314453, -1568.7086181641, 88.128997802734, 1456.677734375, -1637.5545654297, 53.114582061768 },
	[5] = { 46.309753417969, -1698.5400390625, 51.138675689697, 118.90101623535, -1766.6478271484, 41.555904388428 },
}
endCam = {
        [0] = {591.1669921875, -1827.3310546875, 10.137532234191, 570.09375, -1849.947265625, 4.968677997},
        [1] = {2511.8854980469, -1679.1414794922, 17.823833465576, 2425.4426269531, -1641.1086425781, -15.056860923767},
        [2] = {1553.4459228516, -1365.8366699219, 332.95718383789, 1495.1271972656, -1295.9808349609, 291.49520874023},
        [3] = {-2233.2431640625, -1705.6872558594, 484.6149597168, -2268.3579101563, -1797.0213623047, 463.99838256836},
}
startCam = {
        [0] = {1309.4599609375, -2123.7509765625, 106.98361206055, 1309.53515625, -1818.5615234375, 76.211189270 },
        [1] = {2637.0703125, -1719.1510009766, 90.978698730469, 2636.2329101563, -1718.8670654297, 90.511764526367},
        [2] = {1862.1447753906, -1743.5769042969, 616.80279541016, 1807.4505615234, -1676.6506347656, 566.50939941406},
        [3] = {-1553.6662597656, -1547.2840576172, 76.449432373047, -1653.0958251953, -1555.7768554688, 69.997413635254},
}
originalStartCam = {
        [0] = {1309.4599609375, -2123.7509765625, 106.98361206055, 1309.53515625, -1818.5615234375, 76.211189270 },
        [1] = {2637.0703125, -1719.1510009766, 90.978698730469, 2636.2329101563, -1718.8670654297, 90.511764526367},
        [2] = {1862.1447753906, -1743.5769042969, 616.80279541016, 1807.4505615234, -1676.6506347656, 566.50939941406},
        [3] = {-1553.6662597656, -1547.2840576172, 76.449432373047, -1653.0958251953, -1555.7768554688, 69.997413635254},
}
pedPos = {
        [0] = {581.5712890625, -1835.89453125, 5.8328125, 306.9929},
        [1] = {2502.59765625, -1679.40234375, 13.375785827637, 256.50445556641},
        [2] = {1549.615234375, -1362.326171875, 329.45889282227, 202.84092712402},
        [3] = {-2236.76171875, -1710.3046875, 480.88693237305, 310.16250610352},
}
globalspeed = 25 --Higher value = slower
speed = {}
doneCam = {
	[0] = {false, false, false, false, false, false},
	[1] = {false, false, false, false, false, false},
	[2] = {false, false, false, false, false, false},
	[3] = {false, false, false, false, false, false},
}

function shuffleScreen()
	local rand = math.random(1, #loginScreens)
	if rand ~= old then
		old_screen = rand
		return loginScreens[ rand ]
	else
		return shuffleScreen( old )
	end
end

function getSelectionScreenID()
	local hasThisPerk, thisPerkValue = exports.donators:hasPlayerPerk(localPlayer, 24) --Groove St
	if hasThisPerk and tonumber(thisPerkValue) == 1 then
		return 1
	end

	hasThisPerk, thisPerkValue = exports.donators:hasPlayerPerk(localPlayer, 25) --Star Tower
	if hasThisPerk and tonumber(thisPerkValue) == 1 then
		return 2
	end

	hasThisPerk, thisPerkValue = exports.donators:hasPlayerPerk(localPlayer, 26) --Mount Chiliad
	if hasThisPerk and tonumber(thisPerkValue) == 1 then
		return 3
	end

	return 0
end

--------------------------------------------
addEventHandler("accounts:login:request", getRootElement(),
	function ()
		setElementDimension ( localPlayer, 0 )
		setElementInterior( localPlayer, 0 )
		--setElementPosition( localPlayer, -262, -1143, 24)
		--setCameraMatrix(-262, -1143, 24, -97, -1167, 2)
		setElementPosition( localPlayer, unpack( defaultCharacterSelectionSpawnPosition ) )
		local scr = shuffleScreen()
		setCameraMatrix ( scr[1], scr[2], scr[3], scr[4], scr[5], scr[6], 0, exports.global:getPlayerFov())
		guiSetInputEnabled(true)
		clearChat()
		triggerServerEvent("onJoin", localPlayer)
		--LoginScreen_openLoginScreen()
	end
);

--[[ LoginScreen_openLoginScreen( ) - Open the login screen ]]--
local wLogin, lUsername, tUsername, lPassword, tPassword, chkRememberLogin, bLogin, bRegister--[[, updateTimer]] = nil
function LoginScreen_openLoginScreen(title)
	open_log_reg_pannel()
end
addEvent("beginLogin", true)
addEventHandler("beginLogin", getRootElement(), LoginScreen_openLoginScreen)

function showLoginTitle()
	--[[
	local screenX, screenY = guiGetScreenSize()
	local alphaAction = 3
	local alphaStep = 50
	local alphaAction = 3
	local alphaStep = 50
	local sWidth,sHeight = guiGetScreenSize()
	if loginTitleText == "Banned." then
		dxDrawText(loginTitleText,(700/1600)*sWidth, (350/900)*sHeight, (900/1600)*sWidth, (450/900)*sHeight, tocolor(255,0,0,255), (sWidth/1600)*2, "default-bold","center","center",false,false,false)
	else
		dxDrawText(loginTitleText,(700/1600)*sWidth, (350/900)*sHeight, (900/1600)*sWidth, (450/900)*sHeight, tocolor(255,255,255,255), (sWidth/1600)*2, "default-bold","center","center",false,false,false)
	end
	alphaStep = alphaStep + alphaAction
	if (alphaStep > 200) or (alphaStep < 50) then
		alphaAction = alphaAction - alphaAction - alphaAction
	end
	dxDrawRectangle( (10/1600)*sWidth, (17/900)*sHeight, (400/1600)*sWidth, (600/900)*sHeight, tocolor(0, 0, 0, 150))
	dxDrawText( newsTitle, (35/1600)*sWidth, (30/900)*sHeight, (375/1600)*sWidth, (550/900)*sHeight, tocolor ( 255, 255, 255, 255 ), 1.5, "default-bold" )
	dxDrawText( "     " .. newsAuthor, (80/1600)*sWidth, (60/900)*sHeight, sWidth, sHeight, tocolor ( 255, 255, 255, 255 ), 1.2, "default-bold", "left", "top", true, false )
	dxDrawText( newsText, (35/1600)*sWidth, (92/900)*sHeight, (375/1600)*sWidth, sHeight,  tocolor ( 255, 255, 255, 255 ), 1, "default-bold", "left", "top", true, true )
	]]
end

function LoginScreen_Register()
	local username = guiGetText(tUsername)
	local password = guiGetText(tPassword)
	if (string.len(username)<3) then
		LoginScreen_showWarningMessage( "Your username must be a minimum of 3 characters!" )
	elseif (string.find(username, ";", 0)) or (string.find(username, "'", 0)) or (string.find(username, "@", 0)) or (string.find(username, ",", 0)) or (string.find(username, " ", 0)) then
		LoginScreen_showWarningMessage("Your username cannot contain ;,@.' or space!")
	elseif (string.len(password)<6) then
	    LoginScreen_showWarningMessage("Your password is too short. \n You must enter 6 or more characters.", 255, 0, 0)
    elseif (string.len(password)>=30) then
        LoginScreen_showWarningMessage("Your password is too long. \n You must enter less than 30 characters.", 255, 0, 0)
    elseif (string.find(password, ";", 0)) or (string.find(password, "'", 0)) or (string.find(password, "@", 0)) or (string.find(password, ",", 0)) then
        LoginScreen_showWarningMessage("Your password cannot contain ;,@'.", 255, 0, 0)
	else
		showChat(true)
		triggerServerEvent("accounts:register:attempt", localPlayer, username, password)
	end
end

function LoginScreen_RefreshIMG()
	currentslide =  currentslide + 1
	if currentslide > totalslides then
		currentslide = 1
	end
end

--[[ LoginScreen_closeLoginScreen() - Close the loginscreen ]]
function LoginScreen_closeLoginScreen()
	removeEventHandler( "onClientRender", getRootElement(), showLoginTitle )
end

--[[ checkCredentials() - Used to validate and send the contents of the login screen  ]]--
function checkCredentials()
	local username = guiGetText(tUsername)
	local password = guiGetText(tPassword)
	guiSetText(tPassword, "")
	--appendSavedData("hashcode", "")
	if (string.len(username)<3) then
		outputChatBox("Your username is too short. You must enter 3 or more characters.", 255, 0, 0)
	else
		local saveInfo = guiCheckBoxGetSelected(chkRememberLogin)
		triggerServerEvent("accounts:login:attempt", localPlayer, username, password, saveInfo)

		if (saveInfo) then
			--appendSavedData("username", tostring(username))
		else
			--appendSavedData("username", "")
		end
	end
end

local warningBox, warningMessage, warningOk = nil
function LoginScreen_showWarningMessage( message )

	if (isElement(warningBox)) then
		destroyElement(warningBox)
	end

	local x, y = guiGetScreenSize()
	warningBox = guiCreateWindow( x*.5-150, y*.5-65, 300, 120, "Attention!", false )
	guiWindowSetSizable( warningBox, false )
	warningMessage = guiCreateLabel( 40, 30, 220, 60, message, false, warningBox )
	guiLabelSetHorizontalAlign( warningMessage, "center", true )
	guiLabelSetVerticalAlign( warningMessage, "center" )
	warningOk = guiCreateButton( 130, 90, 70, 20, "Ok", false, warningBox )
	addEventHandler( "onClientGUIClick", warningOk, function() destroyElement(warningBox) end )
	guiBringToFront( warningBox )
end
addEventHandler("accounts:error:window", getRootElement(), LoginScreen_showWarningMessage)

function defaultLoginText()
	loginTitleText = "OwlGaming MTA Roleplay"
end

addEventHandler("accounts:login:attempt", getRootElement(),
	function (statusCode, additionalData)

		if (statusCode == 0) then
			LoginScreen_closeLoginScreen()

			if (isElement(warningBox)) then
				destroyElement(warningBox)
			end

			-- Succesful login
			--[[
			for _, theValue in ipairs(additionalData) do
				setElementData(localPlayer, theValue[1], theValue[2], false)
			end
			]]

			local newAccountHash = getElementData(localPlayer, "account:newAccountHash")
			--appendSavedData("hashcode", newAccountHash or "")

			local characterList = getElementData(localPlayer, "account:characters")

			if #characterList == 0 then
				newCharacter_init()
			else
				Characters_showSelection()
				fadeCamera ( false, 0, 0,0,0 )
			end
		elseif (statusCode > 0) and (statusCode < 5) then
			LoginScreen_showWarningMessage( additionalData )
		elseif (statusCode == 5) then
			LoginScreen_showWarningMessage( additionalData )
			-- TODO: show make app screen?
		end
	end
)

local Window = {}
local Button = {}
local Label = {}
local Edit = {}

function showPasswordUpdate()
	showCursor(true)
	Window[1] = guiCreateWindow(0.3562,0.3997,0.2891,0.2383,"SECURITY NOTICE:",true)
		guiSetInputEnabled ( true)
		Label[1] = guiCreateLabel(0.0378,0.153,0.9324,0.2404,"We have noticed a potential security flaw with your account.\nTo help prevent any loss of data, we highly reccomend that\nyou enter a new password in the box below!",true,Window[1])
			guiLabelSetColor(Label[1],0,200,0)
			guiLabelSetHorizontalAlign(Label[1],"center",false)
		Edit[1] = guiCreateEdit(0.4243,0.4481,0.5351,0.1475,"",true,Window[1])
			guiEditSetMasked(Edit[1], true)
		Edit[2] = guiCreateEdit(0.4243,0.6175,0.5351,0.1475,"",true,Window[1])
			guiEditSetMasked(Edit[2], true)
		Label[2] = guiCreateLabel(0.1649,0.4754,0.2432,0.1038,"New Password:",true,Window[1])
		Label[3] = guiCreateLabel(0.1216,0.6284,0.2784,0.1038,"Confirm Password:",true,Window[1])
		Button[1] = guiCreateButton(0.427,0.8087,0.527,0.1257,"Change Password",true,Window[1])
			addEventHandler("onClientGUIClick", Button[1], function()
				triggerServerEvent("account:forceChange:validate", localPlayer, guiGetText(Edit[1]), guiGetText(Edit[2]))
			end)
end
addEvent("account:forceChangePassword:GUI", true)
addEventHandler("account:forceChangePassword:GUI", getRootElement(), showPasswordUpdate)

function closePasswordUpdate()
	destroyElement(Window[1])
	showCursor(false)
	guiSetInputEnabled ( false)
end
addEvent("account:forceChange:GUIClose", true)
addEventHandler("account:forceChange:GUIClose", getRootElement(), closePasswordUpdate)
