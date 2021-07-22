
-- Showing banner
local banner = dxCreateTexture("bmxpier/banner.jpg")
local dupont = dxCreateTexture("bmxpier/dupont.jpg")
addEventHandler("onClientRender", root, function()

	-- main big banner:
	local x, y = 837.2783203125, -1915.6884765625
	local top, bottom = 34, 23
	dxDrawMaterialLine3D (x, y, top, x, y, bottom, banner, 32, tocolor(255,255,255,255), x, y+1, tonumber((top+bottom)/2))

	-- small banner:
	local x1, y1 = 837.05, -1898.8
	local top1, bottom1 = 14, 12
	dxDrawMaterialLine3D (x1, y1, top1, x1, y1, bottom1, dupont, 4.8, tocolor(255,255,255,255), x1, y1+1, tonumber((top1+bottom1)/2))
end)

-- TV leaderboard
local webBrowser = createBrowser(800, 600, false, false)

function webBrowserRender()
    local x, y = 850.11035, -1896.24023
    local top, bottom = 15.4, 12.5
    dxDrawMaterialLine3D(x-0.15, y+0.15, top, x-0.15, y+0.15, bottom, webBrowser, 6.2, tocolor(255, 255, 255, 255), x-1, y+1, tonumber((top+bottom)/2))
end

function brow()
    loadBrowserURL(webBrowser, "https://externet.website/tools/owl/")
    addEventHandler("onClientRender", root, webBrowserRender)
end
addEventHandler("onClientBrowserCreated", webBrowser, brow)


local helpColShape = createColSphere(848.5302734375, -1894.6171875, 12.8671875, 5)
addEventHandler("onClientColShapeHit", resourceRoot, function(theElement)
	if source == helpColShape and theElement == getLocalPlayer() then
		exports.hud:sendBottomNotification(localPlayer, "Coca Cola BMX Cup", "If you do not see the scoreboard, please type /adddomain" )
	end
end)
function addDomain()
	requestBrowserDomains({ "externet.website" }) -- request browser domain
	addEventHandler("onClientBrowserWhitelistChange", root,
	   function(newDomains)
	     if newDomains[1] == "externet.website" then
	       loadBrowserURL(webBrowser, "https://externet.website/tools/owl/")
	       addEventHandler("onClientRender", root, webBrowserRender)
	   end
	end
	)
end
addCommandHandler("adddomain", addDomain)

-- Race
local checkPoints = {
	[1] = {825.9111328125, -1931.41015625, 12.8671875, 0, 0}, --Start
	[2] = {825.5771484375, -1959.0263671875, 12.885499954224, 0, 0},
	[3] = {825.6083984375, -1986.603515625, 12.885499954224, 0, 0},
	[4] = {825.11944580078, -2028.029296875, 18.049983978271, 0, 0},
	[5] = {825.15753173828, -2047.4140625, 14.632587432861, 0, 0},
	[6] = {834.9306640625, -2062.47265625, 12.971513748169, 0, 0},
	[7] = {849.71002197266, -2042.3251953125, 18.115161895752, 0, 0},
	[8] = {849.87603759766, -2031.8095703125, 13.990162849426, 0, 0},
	[9] = {841.64001464844, -2007.4647216797, 14.36074256897, 0, 0},
	[10] = {832.7412109375, -1995.3525390625, 12.8671875, 0, 0},
	[11] = {848.712890625, -2001.4365234375, 12.8671875, 0, 0},
	[12] = {848.70611572266, -1985.2768554688, 17.751512527466, 0, 0},
	[13] = {842.5419921875, -1981.0966796875, 12.8671875, 0, 0},
	[14] = {844.5703125, -1955.416015625, 13.063881874084, 0, 0},
	[15] = {844.419921875, -1937.255859375, 12.8671875, 0, 0} -- final
}

local markers = {}

function goThroughMarkers(c)
	local count = c + 1

	if count == #checkPoints+2 then return false end -- race is done

	local marker = nil
	if count == 15 then
		marker = createMarker(checkPoints[count][1], checkPoints[count][2], checkPoints[count][3], "checkpoint", 4, 255, 0, 0, 255)
		table.insert(markers, marker)
	elseif count == 16 then
		static = startTheClock()
		setTimer(function()
			racing = false
			triggerServerEvent("bmx:endrace", resourceRoot, getLocalPlayer(), static / 1000, false)
			for k, v in pairs(markers) do
				if isElement(v) then
					destroyElement(v)
				end
			end
			static = -1
			systemUpTime = nil
		end, 5000, 1)

		if isTimer(timer) then
			killTimer(timer)
		end

	else
		marker = createMarker(checkPoints[count][1], checkPoints[count][2], checkPoints[count][3], "checkpoint", 4, 0, 0, 255, 255)
		table.insert(markers, marker)
	end

	addEventHandler("onClientMarkerHit", root, function(thePlayer)
		if source == marker and getElementType(thePlayer) == "player" then
			destroyElement(marker)
			goThroughMarkers(count)
		end
	end)
end

local timer = nil
function startRace()
	local count = 1
	local marker = createMarker(checkPoints[1][1], checkPoints[1][2], checkPoints[1][3], "checkpoint", 4, 0, 255, 0, 255)
	table.insert(markers, marker)

	outputChatBox("At any time you can cancel the race by typing: /cancelrace")

	addEventHandler("onClientMarkerHit", root, function(thePlayer)
		if source == marker then
			destroyElement(marker)
			goThroughMarkers(count)
			static = -1
		end
	end)

	racing = true
	static = 0

	timer = setTimer(function()
		if racing == true then
			cancelRace()
		end
	end, 120000, 1)
end
addEvent("bmx:start", true)
addEventHandler("bmx:start", resourceRoot, startRace)

function cancelRace()
	if racing == true then
		if isTimer(timer) then
			killTimer(timer)
		end
		racing = false
		triggerServerEvent("bmx:endrace", resourceRoot, getLocalPlayer(), false, false)
		for k, v in pairs(markers) do
			if isElement(v) then
				destroyElement(v)
			end
		end
		static = -1
		systemUpTime = nil

		outputChatBox("The race was cancelled!")
	end
end
addCommandHandler("cancelrace", cancelRace)

function changeCharCancelRace()
	if racing == true then
		racing = false
		if isTimer(timer) then
			killTimer(timer)
		end
		triggerServerEvent("bmx:endrace", resourceRoot, getLocalPlayer(), false, true)
		for k, v in pairs(markers) do
			if isElement(v) then
				destroyElement(v)
			end
		end
		static = -1
		systemUpTime = nil

		outputChatBox("The race was cancelled!")
	end
end
addEventHandler("onClientChangeChar", root, changeCharCancelRace)


screenX,screenY = guiGetScreenSize()
racing = false
static = -1
function startTheClock ()
    if racing == true then
	    dxDrawRectangle (screenX *.40, screenY * .09, 250, 50, tocolor(0,0,0,150))

	    if static >= 0 then
	    	dxDrawText ( static / 1000, screenX * .48, screenY * .1, screenX, screenY, tocolor(255,255,255), 2)
	   	else
		    if not systemUpTime then
		            systemUpTime = getTickCount () --Store the system tick count, this will be 0 for us
		    end

		    currentCount = getTickCount ()
	   		dxDrawText ( ((currentCount - systemUpTime) / 1000), screenX * .48, screenY * .1, screenX, screenY, tocolor(255,255,255), 2)

	   		return (currentCount - systemUpTime)
	   	end
	end
end
addEventHandler ( "onClientRender", root, startTheClock )

function joinGUI()

	GUIEditor = {
	    button = {},
	    window = {},
	    memo = {}
	}
	GUIEditor.window[1] = guiCreateWindow(234, 168, 816, 427, "Participate in the 2017 Coca Cola BMX Cup!", false)
	guiWindowSetSizable(GUIEditor.window[1], false)
	exports.global:centerWindow(GUIEditor.window[1])

	GUIEditor.memo[1] = guiCreateMemo(9, 25, 793, 354, "Welcome to the 2017 LS BMX Cup, Presented by Coca Cola & Dupont Entertainment! \n\nInterested in participating? This event will last from April 21st through April 27th. The cost for participating is $50 per entry. You'll have one shot per entry to make it through the course and set a record time. The current best times will be displayed on the billboard out front, updated live! \n\nThe Grand Prize for the quickest record time will be the sum of all 50$ collected: 70% to the winner, 20% to 2nd and 10% to third.  \n\nWe also like to keep the rules simple: \n\nFirst, No Cheating! You must use the standard regulation BMX Bike provided, and you must not cut any corners.  \nThere are clearly marked boundaries and arrows in certain areas to guide you, as well as checkpoint markers.  \nJumping over certain objects such as barriers, railings on the edge of raised platforms, and such is not allowed, and you'll probably miss your next checkpoint if you do. \nYour time will be automatically recorded by event staff. This time is not disputable and is concrete. \nIf you wish to end your attempt early, simply stop, get off the bike, and raise your hand in the air. Event staff will escort you off the track. ((Use /cancelrace at any time to end your race and exit.))  \n\nPlease note that BMX is a dangerous sport, please wear protective gear at all times within the event. We cannot, and will not be held responsible for any injuries or damage. Any injury that occurs during the course of your entry will be your own responsibility!  \n\nGood luck!", false, GUIEditor.window[1])
	guiMemoSetReadOnly(GUIEditor.memo[1], true)
	GUIEditor.button[1] = guiCreateButton(9, 384, 401, 33, "Participate (50$)", false, GUIEditor.window[1])
	guiSetProperty(GUIEditor.button[1], "NormalTextColour", "FF06F8C2")
	GUIEditor.button[2] = guiCreateButton(443, 384, 359, 33, "Cancel", false, GUIEditor.window[1])

	addEventHandler("onClientGUIClick", GUIEditor.button[2], function()
		if isElement(GUIEditor.window[1]) then
			destroyElement(GUIEditor.window[1])
		end
	end, false)

	addEventHandler("onClientGUIClick", GUIEditor.button[1], function()
		if isElement(GUIEditor.window[1]) then
			destroyElement(GUIEditor.window[1])
		end

		triggerServerEvent("bmx:addtoqueue", resourceRoot, getLocalPlayer())
	end, false)
end
addEvent("bmx:join", true)
addEventHandler("bmx:join", root, joinGUI)
