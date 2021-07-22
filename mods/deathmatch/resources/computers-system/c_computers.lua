local wComputer
local screenWidth, screenHeight = guiGetScreenSize()
local launcherIconSize = 48
local launcherIconPadding = 20

local computerWidth = 800
local computerHeight = 500
local computerX = (screenWidth - computerWidth)/2
local computerY = (screenHeight - computerHeight)/2 + 10

function createComputerGUI(computerName, websiteToStartOn)
	if wComputer then
		return
	end

	-- which site do we want our computer to open up on?
	websiteToStartOn = websiteToStartOn or 'www.google.sa'

	wComputer = guiCreateWindow(computerX, computerY, computerWidth, computerHeight + 29, computerName or "Computer", false)
	guiWindowSetSizable(wComputer, false)
	desktopImage = guiCreateStaticImage(0, 20, computerWidth, computerHeight, "wallpaper.jpg", false, wComputer)

	local launcherButtons = {
		{ icon = 'chromium.png', fn = function() openBrowser(websiteToStartOn) end },
		{ icon = 'mail.png', fn = openEmailWindow },
		{ icon = 'shutdown.png', fn = closeComputerWindow },
	}

	local launcherX = (computerWidth - ( #launcherButtons * ( launcherIconSize + launcherIconPadding ) + launcherIconPadding )) / 2
	local launcherY = computerHeight - launcherIconSize - launcherIconPadding
	for i, button in ipairs(launcherButtons) do
		local image = guiCreateStaticImage(launcherX + (i-1) * (launcherIconSize + launcherIconPadding), launcherY, launcherIconSize, launcherIconSize, "icons/" .. button.icon, false, desktopImage)
		if button.fn then
			addEventHandler("onClientGUIClick", image, button.fn, false)
		else
			outputDebugString('Button ' .. button.icon .. ' has no function handler')
		end
	end

	local toggleInput = guiCreateButton(0, computerHeight - 24, 90, 24, "Toggle Input", false, desktopImage)
	addEventHandler("onClientGUIClick", toggleInput, toggleChatboxComputer)

	showCursor(true)
	guiSetInputEnabled(true)
end
-- addCommandHandler("pc", function() createComputerGUI("Test PC", "www.mdc.gov") end)
addEvent("useCompItem",true)
addEventHandler("useCompItem",getRootElement(),createComputerGUI)

-- is this needed?
function toggleChatboxComputer(key, state)
	if key == "left" and state == "down" then
		if(source == chatButton) then
			if (guiGetInputEnabled( )) then
				guiSetInputEnabled(false)
				showCursor(false)
				outputChatBox("Chatbox active", 0, 255, 0, true)
				outputChatBox("Press M on the keyboard to toggle back and use the computer")
			else
				guiSetInputEnabled(true)
				showCursor(false)
				outputChatBox("Computer window active", 0, 255, 0, true)
			end
		end
	end
end

-- is this needed?
function toggleChatboxComputer2(key, keyState)
	if(key == "m") then
		if(wComputer and isElement(wComputer) and guiGetVisible(wComputer)) then
			if (guiGetInputEnabled( )) then
				guiSetInputEnabled(false)
				outputChatBox("Chatbox active", 0, 255, 0, true)
				outputChatBox("Press M on the keyboard to toggle back and use the computer")
			else
				guiSetInputEnabled(true)
				outputChatBox("Computer window active", 0, 255, 0, true)
			end
		end
	end
end
bindKey ( "m", "down", toggleChatboxComputer2)


function closeComputerWindow()
	close_email_window()
	closeBrowser()
	-- Computer Desktop GUI.
	if wComputer then
		destroyElement(wComputer)
		wComputer = nil
	end

	guiSetInputEnabled(false)
	showCursor(false)

end
addCommandHandler("ctl+alt+del",closeComputerWindow) -- Emergency close command.

----------------------------------------

addEventHandler("onClientResourceStop", getResourceRootElement( ),
	function()
		closeComputerWindow()
	end
)
