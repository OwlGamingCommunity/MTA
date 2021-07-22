gInteriorName, gOwnerName, gBuyMessage, gBizMessage = nil

timer = nil

intNameFont = guiCreateFont( "intNameFont.ttf", 30 ) or "default-bold" --AngryBird
BizNoteFont = guiCreateFont( ":resources/BizNote.ttf", 21 ) or "default-bold"

-- Message on enter
function showIntName(name, ownerName, inttype, cost, ID, bizMsg)
	bizMessage = bizMsg
	if (isElement(gInteriorName) and guiGetVisible(gInteriorName)) then
		if timer and isTimer(timer) then
			killTimer(timer)
			timer = nil
		end

		destroyElement(gInteriorName)
		gInteriorName = nil

		if isElement(gOwnerName) then
			destroyElement(gOwnerName)
			gOwnerName = nil
		end

		if (gBuyMessage) then
			destroyElement(gBuyMessage)
			gBuyMessage = nil
		end

		if (gBizMessage) then
			destroyElement(gBizMessage)
			gBizMessage = nil
		end

	end
	if name == "None" then
		return
	elseif name then
		if (inttype==3) then -- Interior name and Owner for rented
			gInteriorName = guiCreateLabel(0.0, 0.84, 1.0, 0.3, tostring(name), true)
			guiSetFont(gInteriorName,intNameFont)
			guiLabelSetHorizontalAlign(gInteriorName, "center", true)
			guiSetAlpha(gInteriorName, 0.0)

			if (exports.integration:isPlayerTrialAdmin(localPlayer) and getElementData(localPlayer, "duty_admin") == 1) or exports.global:hasItem(localPlayer, 4, ID) then
				gOwnerName = guiCreateLabel(0.0, 0.90, 1.0, 0.3, "Rented by: " .. tostring(ownerName), true)
				guiSetFont(gOwnerName, "default")
				guiLabelSetHorizontalAlign(gOwnerName, "center", true)
				guiSetAlpha(gOwnerName, 0.0)
			end

		else -- Interior name and Owner for the rest
			--outputDebugString((name or "nil").." - "..(tostring(bizMsg) or "nil"))
			if bizMessage then
				gInteriorName = guiCreateLabel(0.0, 0.80, 1.0, 0.3, tostring(name), true)
				gBizMessage = guiCreateLabel(0.0, 0.864, 1.0, 0.3, tostring(bizMessage), true)
				guiLabelSetHorizontalAlign(gBizMessage, "center", true)
				guiSetAlpha(gBizMessage, 0.0)
				guiSetFont(gBizMessage, BizNoteFont)
			else
				gInteriorName = guiCreateLabel(0.0, 0.84, 1.0, 0.3, tostring(name), true)
			end
			guiSetFont(gInteriorName, intNameFont)
			guiLabelSetHorizontalAlign(gInteriorName, "center", true)
			guiSetAlpha(gInteriorName, 0.0)
			if (exports.integration:isPlayerTrialAdmin(localPlayer) and getElementData(localPlayer, "duty_admin") == 1) or exports.global:hasItem(localPlayer, 4, ID) or exports.global:hasItem(localPlayer, 5, ID) then
				gOwnerName = guiCreateLabel(0.0, 0.90, 1.0, 0.3, "Owner: " .. tostring(ownerName), true)
				guiSetFont(gOwnerName, "default")
				guiLabelSetHorizontalAlign(gOwnerName, "center", true)
				guiSetAlpha(gOwnerName, 0.0)
			end
		end
		if (ownerName=="None") and (inttype==3) then -- Unowned type 3 (rentable)
			gBuyMessage = guiCreateLabel(0.0, 0.915, 1.0, 0.3, "Press F to rent for $" .. tostring(exports.global:formatMoney(cost)) .. ".", true)
			guiSetFont(gBuyMessage, "default")
			guiLabelSetHorizontalAlign(gBuyMessage, "center", true)
			guiSetAlpha(gBuyMessage, 0.0)
		elseif (ownerName=="None") and (inttype<2) then -- Unowned any other type
			gBuyMessage = guiCreateLabel(0.0, 0.915, 1.0, 0.3, "Press F to buy for $" .. tostring(exports.global:formatMoney(cost)) .. ".", true)
			guiSetFont(gBuyMessage, "default")
			guiLabelSetHorizontalAlign(gBuyMessage, "center", true)
			guiSetAlpha(gBuyMessage, 0.0)
		else
			local msg = "Press F to enter."
			--[[if fee and fee > 0 then
				msg = "Entrance Fee: $" .. exports.global:formatMoney(fee)

				if exports.global:hasMoney( localPlayer, fee ) then
					msg = msg .. "\nPress F to enter."
				end
			end]]
			gBuyMessage = guiCreateLabel(0.0, 0.915, 1.0, 0.3, msg, true)
			guiSetFont(gBuyMessage, "default")
			guiLabelSetHorizontalAlign(gBuyMessage, "center", true)
			--guiSetAlpha(gBuyMessage, 0.0)
		end

		--[[setTimer(function()
			if gInteriorName then
				destroyElement(gInteriorName)
				gInteriorName = nil
			end

			if isElement(gOwnerName) then
				destroyElement(gOwnerName)
				gOwnerName = nil
			end

			if (gBuyMessage) then
				destroyElement(gBuyMessage)
				gBuyMessage = nil
			end

			if (gBizMessage) then
				destroyElement(gBizMessage)
				gBizMessage = nil
			end
		end, 3000, 1)
		]]

		timer = setTimer(fadeMessage, 50, 20, true)
	end
end
addEvent("displayInteriorName", true )
addEventHandler("displayInteriorName", root, showIntName)

function fadeMessage(fadein)
	local alpha = guiGetAlpha(gInteriorName)

	if (fadein) and (alpha) then
		local newalpha = alpha + 0.05
		guiSetAlpha(gInteriorName, newalpha)
		if isElement(gOwnerName) then
			guiSetAlpha(gOwnerName, newalpha)
		end

		if (gBuyMessage) then
			guiSetAlpha(gBuyMessage, newalpha)
		end

		if gBizMessage then
			guiSetAlpha(gBizMessage, newalpha)
		end

		if(newalpha>=1.0) then
			timer = setTimer(hideIntName, 15000, 1)
		end
	elseif (alpha) then
		local newalpha = alpha - 0.05
		guiSetAlpha(gInteriorName, newalpha)
		if isElement(gOwnerName) then
			guiSetAlpha(gOwnerName, newalpha)
		end

		if (gBuyMessage) then
			guiSetAlpha(gBuyMessage, newalpha)
		end

		if (gBizMessage) then
			guiSetAlpha(gBizMessage, newalpha)
		end

		if(newalpha<=0.0) then
			destroyElement(gInteriorName)
			gInteriorName = nil

			if isElement(gOwnerName) then
				destroyElement(gOwnerName)
				gOwnerName = nil
			end

			if (gBuyMessage) then
				destroyElement(gBuyMessage)
				gBuyMessage = nil
			end

			if (gBizMessage) then
				destroyElement(gBizMessage)
				gBizMessage = nil
			end
		end
	end
end

function hideIntName()
	setTimer(fadeMessage, 50, 20, false)
end

--[[
-- Creation of clientside blips
function createBlipsFromTable(interiors)
	-- remove existing house blips
	for key, value in ipairs(getElementsByType("blip")) do
		local blipicon = getBlipIcon(value)

		if (blipicon == 31 or blipicon == 32) then
			destroyElement(value)
		end
	end

	-- spawn the new ones
	for key, value in ipairs(interiors) do
		createBlipAtXY(interiors[key][1], interiors[key][2], interiors[key][3])
	end
end
addEvent("createBlipsFromTable", true)
addEventHandler("createBlipsFromTable", root, createBlipsFromTable)
]]

function createBlipAtXY(inttype, x, y)
	if inttype and tonumber(inttype) then
		if inttype == 3 then inttype = 0 end
		createBlip(x, y, 10, 31+inttype, 2, 255, 0, 0, 255, 0, 300)
	end
end
addEvent("createBlipAtXY", true)
addEventHandler("createBlipAtXY", root, createBlipAtXY)

function removeBlipAtXY(inttype, x, y)
	if inttype == 3 or type(inttype) ~= 'number' then inttype = 0 end
	for key, value in ipairs(getElementsByType("blip")) do
		local bx, by, bz = getElementPosition(value)
		local icon = getBlipIcon(value)

		if (icon==31+inttype and bx==x and by==y) then
			destroyElement(value)
			break
		end
	end
end
addEvent("removeBlipAtXY", true)
addEventHandler("removeBlipAtXY", root, removeBlipAtXY)

local house = nil
local houseID = nil
function showHouseMenu( absX, absY )
	rightclick = exports.rightclick

	local interior = house
	if getElementType(house) == "elevator" then
		interior = getElementByID('int' .. houseID) or interior
	end

	rcMenu = rightclick:create(getElementData(interior, "name") or ("Interior ID #"..tostring( houseID )))
	local row = { }

	row.lock = rightclick:addRow("Lock/Unlock")
	addEventHandler("onClientGUIClick", row.lock, lockUnlockHouse, false)

	row.knock = rightclick:addRow("Knock on Door")
	addEventHandler("onClientGUIClick", row.knock, knockHouse, false)

	if getElementType(house) == "interior" then
		if hasKey(houseID, true) then
			row.note = rightclick:addRow("Edit Greeting Msg")
			addEventHandler("onClientGUIClick", row.note, function()
				guiSetInputEnabled(true)
				local width, height = 506, 103
				local sx, sy = guiGetScreenSize()
				local posX = (sx/2)-(width/2)
				local posY = (sy/2)-(height/2)
				wBizNote = guiCreateWindow(posX,posY,width,height,"Edit Business Greeting Message - "..(getElementData(house, "name") or ("Interior ID #"..tostring( houseID ))),false)
				local eBizNote = guiCreateEdit(9,22,488,40,"",false,wBizNote)
				local bRemove = guiCreateButton(9,68,163,28,"Remove",false,wBizNote)
				local bSave = guiCreateButton(172,68,163,28,"Save",false,wBizNote)
				local bCancel = guiCreateButton(335,68,163,28,"Cancel",false,wBizNote)
				addEventHandler("onClientGUIClick", bRemove, function()
					if triggerServerEvent("businessSystem:setBizNote", localPlayer, localPlayer, houseID) then
						hideHouseMenu()
					end
				end, false)

				addEventHandler("onClientGUIClick", bSave, function()
					if triggerServerEvent("businessSystem:setBizNote", localPlayer, localPlayer, houseID, guiGetText(eBizNote)) then
						hideHouseMenu()
					end
				end, false)

				addEventHandler("onClientGUIClick", bCancel, function()
					if wBizNote then
						destroyElement(wBizNote)
						wBizNote = nil
					end
				end, false)

			end, false)
		end

		local interiorStatus = getElementData(house, "status")
		local interiorType = interiorStatus.type or 2
		if interiorType>=0 and interiorType<3 then
			row.mailbox = rightclick:addRow("Mailbox")
			addEventHandler("onClientGUIClick", row.mailbox, function(button)
				if button=="left" and not getElementData(localPlayer, "exclusiveGUI") then
					triggerServerEvent( "openFreakinInventory", localPlayer, house, absX, absY )
				end
			end, false)
		end
	end
end

local lastKnocked = 0
function knockHouse()
	local tick = getTickCount( )
	if tick - lastKnocked > 5000 then
		triggerServerEvent("onKnocking", localPlayer, house)
		hideHouseMenu()
		lastKnocked = tick
	else
		outputChatBox("Please wait a bit before knocking again.", 255, 0, 0)
	end
end

function lockUnlockHouse( )
	local tick = getTickCount( )
	if tick - lastKnocked > 2000 then
		local px, py, pz = getElementPosition(localPlayer)
		local interiorEntrance = getElementData(house, "entrance")
		local interiorExit = getElementData(house, "exit")

		if getElementType(house) == "elevator" then
			interiorEntrance = { x = interiorEntrance[1], y = interiorEntrance[2], z = interiorEntrance[3] }
			interiorExit = { x = interiorExit[1], y = interiorExit[2], z = interiorExit[3] }
		end

		local x, y, z = getElementPosition(house)
		if getDistanceBetweenPoints3D(interiorEntrance.x, interiorEntrance.y, interiorEntrance.z, px, py, pz) < 5 then
			triggerServerEvent( "lockUnlockHouseID", getLocalPlayer( ), houseID, nil, house )
		elseif getDistanceBetweenPoints3D(interiorExit.x, interiorExit.y, interiorExit.z, px, py, pz) < 5 then
			triggerServerEvent( "lockUnlockHouseID", getLocalPlayer( ), houseID, nil, house )
		end
		hideHouseMenu()
	end
end

function hideHouseMenu( )
	--[[if wRightClick then
		destroyElement( wRightClick )
		wRightClick = nil
		showCursor( false )
	end]]
	if wBizNote then
		destroyElement(wBizNote)
		wBizNote = nil
	end
	house = nil
	houseID = nil
	guiSetInputEnabled(false)
	showCursor(false)
end

function hasKey( key, biz_only )
	if (not biz_only and exports.global:hasItem(localPlayer, 4, key)) or exports.global:hasItem(localPlayer, 5,key) then
		return true, false
	else
		if getElementData(localPlayer, "duty_admin") == 1 then
			return true, true
		else
			return false, false
		end
	end
	return false, false
end

function clickHouse(button, state, absX, absY, wx, wy, wz, e)
	--outputDebugString(tostring(e))
	if (button == "right") and (state=="down") and not e then
		if getElementData(localPlayer, "exclusiveGUI") then
			return
		end

		local element, id = nil, nil
		local px, py, pz = getElementPosition(localPlayer)
		local x, y, z = nil
		local interiorres = getResourceRootElement(getResourceFromName("interior_system"))
		local elevatorres = getResourceRootElement(getResourceFromName("elevator-system"))

		for key, value in ipairs(getElementsByType("pickup")) do
			if isElementStreamedIn(value) then
				x, y, z = getElementPosition(value)
				local minx, miny, minz, maxx, maxy, maxz
				local offset = 4

				minx = x - offset
				miny = y - offset
				minz = z - offset

				maxx = x + offset
				maxy = y + offset
				maxz = z + offset

				if (wx >= minx and wx <=maxx) and (wy >= miny and wy <=maxy) and (wz >= minz and wz <=maxz) then
					local dbid = getElementData(getElementParent( value ), "dbid")
					if getElementType(getElementParent( value )) == "interior" then -- house found
						element = getElementParent( value )
						id = dbid
						break
					elseif  getElementType(getElementParent( value ) ) == "elevator" then
						-- it's an elevator
						if getElementData(value, "dim") and getElementData(value, "dim")  ~= 0 then
							element = getElementParent( value )
							id = getElementData(value, "dim")
							break
						elseif getElementData( getElementData( value, "other" ), "dim")  and getElementData( getElementData( value, "other" ), "dim")  ~= 0 then
							element = getElementParent( value )
							id = getElementData( getElementData( value, "other" ), "dim")
							break
						end
					end
				end
			end
		end

		if element then
			if getDistanceBetweenPoints3D(x, y, z, px, py, pz) < 5 then
				ax, ay = getScreenFromWorldPosition(x, y, z, 0, false)
				if ax then
					hideHouseMenu()
					house = element
					houseID = id
					showHouseMenu(absX, absY)
				end
			else
				--outputChatBox("You are too far away from this house.", 255, 0, 0)
			end
		else
			hideHouseMenu()
		end
	end
end
addEventHandler("onClientClick", root, clickHouse, true)

local cache = { }
function findProperty(thePlayer, dimension)
	local dbid = tonumber(dimension) or getElementDimension( thePlayer )
	if dbid > 0 then
		if cache[ dbid ] then
			return unpack( cache[ dbid ] )
		end
		-- find the entrance and exit
		local entrance, exit = nil, nil
		local res = exports.global:isResourceRunning( 'interior_load' )
		if res then
			for key, value in pairs( getElementsByType( "pickup", res ) ) do
				if getElementData(value, "dbid") == dbid then
					entrance = value
					break
				end
			end
		end
		if entrance then
			cache[ dbid ] = { dbid, entrance }
			return dbid, entrance
		end
	end
	cache[ dbid ] = { 0 }
	return 0
end

function findParent( element, dimension )
	local dbid, entrance = findProperty( element, dimension )
	return entrance
end

addEvent( "setPlayerInsideInterior", true )
addEventHandler( "setPlayerInsideInterior", getRootElement( ),
	function( targetLocation, targetInterior, furniture, camerafade)
		setTimer(function()
			if camerafade then
				fadeCamera(true)
			end
		end, 2000, 1)

		for i = 0, 4 do
    		setInteriorFurnitureEnabled(i, furniture and true or false)
		end
		--[[
		local adminnote = tostring(getElementData(targetInterior, "adminnote"))
		if string.sub(tostring(adminnote),1,8) ~= "userdata" and adminnote ~= "\n" and getElementData(localPlayer, "duty_admin") == 1 then
			outputChatBox("[INT MONITOR]: "..adminnote:gsub("\n", " ").."[..]", 255,0,0)
			outputChatBox("'/checkint "..getElementData(targetInterior, "dbid").." 'for details.",255,255,0)
		end
		]]
	end
)

addEvent( "setPlayerInsideInterior2", true )
addEventHandler( "setPlayerInsideInterior2", getRootElement( ),
	function( targetLocation, targetInterior, furniture)
		if inttimer then
			outputDebugString("setPlayerInsideInterior2: aborted because of inttimer")
			return
		end

		targetLocation = tempFix( targetLocation )

		if targetLocation.dim ~= 0 then
			setGravity(0)
		end

		setElementFrozen(localPlayer, true)
		setElementPosition(localPlayer, targetLocation.x, targetLocation.y, targetLocation.z, true)

		local currentInt = getElementInterior(localPlayer)
		local currentDim = getElementDimension(localPlayer)
		if(targetLocation.int ~= currentInt) then
			setElementInterior(localPlayer, targetLocation.int)
		end
		if(targetLocation.dim ~= currentDim) then
			setElementDimension(localPlayer, targetLocation.dim)
		end

		setCameraInterior(targetLocation.int)

		local rot = targetLocation.rot or targetLocation[INTERIOR_ANGLE]
		if rot then
			setPedRotation( localPlayer, rot )
		end

		for i = 0, 4 do
    		setInteriorFurnitureEnabled(i, furniture and true or false)
		end

		inttimer = setTimer(onPlayerPutInInteriorSecond, 1000, 1, targetLocation.dim, targetLocation.int)

		if false and targetInterior then
			local adminnote = tostring(getElementData(targetInterior, "adminnote"))
			if string.sub(tostring(adminnote),1,8) ~= "userdata" and adminnote ~= "\n" and getElementData(localPlayer, "duty_admin") == 1 then
				outputChatBox("[INT MONITOR]: "..adminnote:gsub("\n", " ").."[..]", 255,0,0)
				outputChatBox("'/checkint "..getElementData(targetInterior, "dbid").." 'for details.",255,255,0)
			end
		end
	end
)

addCommandHandler("getcamint", function (cmd)
	local camInt = getCameraInterior()
	outputChatBox("camInt="..tostring(camInt))
end)
addCommandHandler("setcamint", function (cmd, arg)
	if arg then
		arg = tonumber(arg) or 0
		setCameraInterior(arg)
	else
		outputChatBox("specify interior world")
	end
end)

function onPlayerPutInInteriorSecond(dimension, interior)
	setCameraInterior(interior)

	local safeToSpawn = true
	if(getResourceFromName("object-system"))then
		safeToSpawn = exports['object-system']:isSafeToSpawn()
	end

	if (safeToSpawn) then
		inttimer = nil
		if isElement(localPlayer) then
			setTimer(onPlayerPutInInteriorThird, 1000, 1)
		end
	else
		setTimer(onPlayerPutInInteriorSecond, 1000, 1, dimension, interior)
	end
end

function onPlayerPutInInteriorThird()
	setGravity(0.008)
	setElementFrozen(localPlayer, false)
	inttimer = nil
end

local starttime = false
local function updateIconAlpha( )
	local time = getTickCount( ) - starttime
	-- if time > 20000 then
		-- removeIcon( )
	-- else
		time = time % 1000
		local alpha = 0
		if time < 500 then
			alpha = time / 500
		else
			alpha = 1 - ( time - 500 ) / 500
		end

		guiSetAlpha(help_icon, alpha)
		guiSetAlpha(icon_label_shadow, alpha)
		guiSetAlpha(icon_label, alpha)
	--end
end

function showLoadingProgress(stats_numberOfInts, delayTime)
	if help_icon then
		removeIcon()
	end
	local title = stats_numberOfInts.." interiors(ETA: "..string.sub(tostring((tonumber(delayTime)-5000)/(60*1000)), 1, 3).." minutes) are being loaded. Don't panic if your house hasn't appeared yet. "
	local screenwidth, screenheight = guiGetScreenSize()
	help_icon = guiCreateStaticImage(screenwidth-25,6,20,20,"icon.png",false)
	icon_label_shadow = guiCreateLabel(screenwidth-829,11,800,20,title,false)
	guiSetFont(icon_label_shadow,"default-bold-small")
	guiLabelSetColor(icon_label_shadow,0,0,0)
	guiLabelSetHorizontalAlign(icon_label_shadow,"right",true)

	icon_label = guiCreateLabel(screenwidth-830,10,800,20,title,false)
	guiSetFont(icon_label,"default-bold-small")
	guiLabelSetHorizontalAlign(icon_label,"right",true)

	starttime = getTickCount( )
	updateIconAlpha( )
	addEventHandler( "onClientRender", getRootElement( ), updateIconAlpha )

	setTimer(function ()
		if help_icon then
			removeIcon()
		end
	end, delayTime+10000 , 1)
end
addEvent("interior:showLoadingProgress",true)
addEventHandler("interior:showLoadingProgress",root,showLoadingProgress)
--addCommandHandler("fu",showLoadingProgress)

function removeIcon()
	removeEventHandler( "onClientRender", getRootElement( ), updateIconAlpha )
	destroyElement(icon_label_shadow)
	destroyElement(icon_label)
	destroyElement(help_icon)
	icon_label_shadow, icon_label, help_icon = nil
end

local purchaseProperty = {
    button = {},
    window = {},
    label = {},
    rad = {}
}

local incompatibleForFurniture = {
	[66] = true,
}

function purchasePropertyGUI(interior, cost, isHouse, isRentable, neighborhood)
	if isElement(purchaseProperty.window[1]) then
		closePropertyGUI()
	end

	if getElementData(localPlayer, "exclusiveGUI") then
		return false
	end

	local intID = getElementData(interior, "dbid")
	local viewstate = getElementData( localPlayer, "viewingInterior" )
	if viewstate then
		triggerServerEvent("endViewPropertyInterior", localPlayer, localPlayer)
		return
	end
	showCursor(true)

	setElementData(localPlayer, "exclusiveGUI", true, false)

	purchaseProperty.window[1] = guiCreateWindow(607, 396, 499, 210, "Purchase Property", false)
	guiWindowSetSizable(purchaseProperty.window[1], false)
	guiSetAlpha(purchaseProperty.window[1], 0.89)
	exports.global:centerWindow(purchaseProperty.window[1])

	local margin = 13
	local btnW = 113
	local btnPosX = margin
	local fTable = {}
	for k,v in pairs(getElementData(localPlayer, "faction")) do
		if exports.factions:hasMemberPermissionTo(localPlayer, k, "manage_interiors") then
			fTable[k] = v
		end
	end


	local btnTextSet = {"Purchase using Cash", "Purchase via Bank"}
	if exports.global:hasItem(localPlayer, 262) and (cost <= 40000) and isHouse and not isRentable then
		btnTextSet = {"Purchase via Token", "Purchase via Bank"}
		exports.hud:sendBottomNotification(localPlayer, "Tip", "You are using a new character, because of this you have a house token on your character which can be used to purchase this house!")
	end
	if exports.global:countTable(fTable) > 0 then
		btnTextSet = {"Purchase \nfor personal", "Purchase \nfor faction"}
	end
	purchaseProperty.button[1] = guiCreateButton(btnPosX, 156, btnW, 43, btnTextSet[1], false, purchaseProperty.window[1])
	guiSetProperty(purchaseProperty.button[1], "NormalTextColour", "FFAAAAAA")
	btnPosX = btnPosX + btnW + margin/2
	purchaseProperty.button[2] = guiCreateButton(btnPosX, 156, btnW, 43, btnTextSet[2], false, purchaseProperty.window[1])
	guiSetProperty(purchaseProperty.button[2], "NormalTextColour", "FFAAAAAA")
	btnPosX = btnPosX + btnW + margin/2
	purchaseProperty.button[4] = guiCreateButton(btnPosX, 156, btnW, 43, "Preview Interior", false, purchaseProperty.window[1])
	guiSetProperty(purchaseProperty.button[4], "NormalTextColour", "FFAAAAAA")
	btnPosX = btnPosX + btnW + margin/2
	purchaseProperty.button[3] = guiCreateButton(btnPosX, 156, btnW, 43, "Close", false, purchaseProperty.window[1])
	guiSetProperty(purchaseProperty.button[3], "NormalTextColour", "FFAAAAAA")

	purchaseProperty.label[2] = guiCreateLabel(110, 44, 315, 20, "You may then select your method of payment.", false, purchaseProperty.window[1])
	purchaseProperty.label[3] = guiCreateLabel(20, 70, 88, 15, "Interior Name:", false, purchaseProperty.window[1])
	purchaseProperty.label[6] = guiCreateLabel(20, 90, 93, 15, "Neighborhood:", false, purchaseProperty.window[1])
	purchaseProperty.label[4] = guiCreateLabel(20, 110, 100, 15, "Cost:", false, purchaseProperty.window[1])
	purchaseProperty.label[5] = guiCreateLabel(250, 110, 73, 15, "Tax:", false, purchaseProperty.window[1])
	purchaseProperty.label[11] = guiCreateLabel(20, 130, 315, 15, "Would you like furniture to be enabled?", false, purchaseProperty.window[1]) -- Furniture

	purchaseProperty.label[7] = guiCreateLabel(117, 70, 400, 15, "", false, purchaseProperty.window[1]) -- Name
	purchaseProperty.label[9] = guiCreateLabel(117, 90, 400, 15, "", false, purchaseProperty.window[1]) -- Area
    purchaseProperty.label[8] = guiCreateLabel(117, 110, 91, 15, "", false, purchaseProperty.window[1]) -- Cost
    purchaseProperty.label[10] = guiCreateLabel(323, 110, 98, 15, "", false, purchaseProperty.window[1]) -- Tax

    purchaseProperty.rad[1] = guiCreateRadioButton(245, 128, 50, 20, "Yes", false, purchaseProperty.window[1])
    purchaseProperty.rad[2] = guiCreateRadioButton(295, 128, 50, 20, "No", false, purchaseProperty.window[1])
    guiRadioButtonSetSelected(purchaseProperty.rad[1], true)

    if incompatibleForFurniture[getElementData(interior, "exit")[4]] then
    	guiSetEnabled(purchaseProperty.rad[1], false)
    	guiSetEnabled(purchaseProperty.rad[2], false)
    end

	--guiSetFont(purchaseProperty.label[1], "default-bold-small")
	guiSetFont(purchaseProperty.label[2], "default-bold-small")
	guiSetFont(purchaseProperty.label[3], "default-bold-small")
	guiSetFont(purchaseProperty.label[4], "default-bold-small")
	guiSetFont(purchaseProperty.label[5], "default-bold-small")
	guiSetFont(purchaseProperty.label[6], "default-bold-small")



	addEventHandler("onClientGUIClick", purchaseProperty.button[3], closePropertyGUI, false)

	addEventHandler( "onClientGUIClick" ,purchaseProperty.button[1],
	function()
		local btnText = guiGetText(purchaseProperty.button[1])
		if btnText == "Purchase using Cash" then
			triggerServerEvent("buypropertywithcash", localPlayer, interior, cost, isHouse, isRentable, guiRadioButtonGetSelected(purchaseProperty.rad[1]))
			closePropertyGUI()
		elseif btnText == "Purchase via Token" then
			triggerServerEvent("buypropertywithtoken", localPlayer, interior, guiRadioButtonGetSelected(purchaseProperty.rad[1]))
			closePropertyGUI()
		else
			btnTextSet = {"Purchase using Cash", "Purchase via Bank", "Purchase via Token"}
			guiSetText(purchaseProperty.button[1], btnTextSet[1])
			guiSetText(purchaseProperty.button[2], btnTextSet[2])
			guiSetText(purchaseProperty.button[4], btnTextSet[3])
			guiSetEnabled(purchaseProperty.button[4], false)
			guiSetProperty(purchaseProperty.button[4], "NormalTextColour", "FF00FF00")
			if exports.global:hasItem(localPlayer, 262) and (cost <= 40000) and isHouse and not isRentable then
				exports.hud:sendBottomNotification(localPlayer, "Tip", "You are using a new character, because of this you have a house token on your character which can be used to purchase this house!")
				guiSetEnabled(purchaseProperty.button[4], true)
			end
		end
	end, false)

	addEventHandler( "onClientGUIClick" ,purchaseProperty.button[2],
	function()
		local btnText = guiGetText(purchaseProperty.button[2])
		if btnText == "Purchase via Bank" then
			triggerServerEvent("buypropertywithbank", localPlayer, interior, cost, isHouse, isRentable, guiRadioButtonGetSelected(purchaseProperty.rad[1]))
			closePropertyGUI()
		else
			if isRentable then
				outputChatBox("Factions can not own rentable properties at the moment.", 255, 0, 0)
			else
				startBuyingForFaction(interior, cost, isHouse, guiRadioButtonGetSelected(purchaseProperty.rad[1]))
				--triggerServerEvent("buypropertyForFaction", localPlayer, interior, cost, isHouse, guiRadioButtonGetSelected(purchaseProperty.rad[1]), selectedFaction)
				--closePropertyGUI()
			end
		end
	end, false)

	addEventHandler( "onClientGUIClick" ,purchaseProperty.button[4],
	function()
		local btnText = guiGetText(purchaseProperty.button[4])
		if btnText == "Preview Interior" then
			triggerServerEvent("viewPropertyInterior", localPlayer, intID)
			closePropertyGUI()
		else
			triggerServerEvent("buypropertywithtoken", localPlayer, interior, guiRadioButtonGetSelected(purchaseProperty.rad[1]))
			closePropertyGUI()
		end
	end, false)



    local interiorName = getElementData(interior, "name")
	if isHouse then
		local theTax = exports.payday:getPropertyTaxRate(0)
		purchaseProperty.label[1] = guiCreateLabel(50, 26, 419, 18, "Please confirm the following information about this property.", false, purchaseProperty.window[1])
		guiLabelSetHorizontalAlign(purchaseProperty.label[1], "center", false)
		taxtax = cost * theTax
		guiSetText(purchaseProperty.label[10], "$"..exports.global:formatMoney(taxtax).."")
	elseif isRentable then
		guiSetText(purchaseProperty.window[1], "Rent Property")
		purchaseProperty.label[1] = guiCreateLabel(50, 26, 419, 18, "Please confirm the following information about this rentable property.", false, purchaseProperty.window[1])
		guiLabelSetHorizontalAlign(purchaseProperty.label[1], "center", false)
		guiSetVisible(purchaseProperty.label[5], false)
		guiSetText(purchaseProperty.label[4], "Cost per Payday:")
	else
		local theTax = exports.payday:getPropertyTaxRate(1)
		guiSetText(purchaseProperty.window[1], "Purchase Business")
		purchaseProperty.label[1] = guiCreateLabel(50, 26, 419, 18, "Please confirm the following information about this business property.", false, purchaseProperty.window[1])
		guiLabelSetHorizontalAlign(purchaseProperty.label[1], "center", false)
		taxtax = cost * theTax
		guiSetText(purchaseProperty.label[10], "$"..exports.global:formatMoney(taxtax).."")
	end
	guiSetText(purchaseProperty.label[9], neighborhood)
	guiSetText(purchaseProperty.label[7], tostring(interiorName))
	guiSetText(purchaseProperty.label[8], "$"..exports.global:formatMoney(cost).."")

	triggerEvent("hud:convertUI", localPlayer, purchaseProperty.window[1])
end
addEvent( "openPropertyGUI", true )
addEventHandler( "openPropertyGUI", getRootElement( ), purchasePropertyGUI)

function closePropertyGUI()
	destroyElement(purchaseProperty.window[1])
	showCursor(false)
	setElementData(localPlayer, "exclusiveGUI", false, false)
	closeStartBuying()
end

local factionBuyGUI = {
    button = {},
    window = {},
    combobox = {}
}
function startBuyingForFaction(interior, cost, isHouse, furniture)
	closeStartBuying()

    factionBuyGUI.window[1] = guiCreateWindow(766, 385, 399, 121, "Select the faction for this interior", false)
    guiWindowSetSizable(factionBuyGUI.window[1], false)
	guiSetAlpha(factionBuyGUI.window[1], 0.89)
	exports.global:centerWindow(factionBuyGUI.window[1])
	guiSetEnabled(purchaseProperty.window[1], false)

    factionBuyGUI.button[1] = guiCreateButton(13, 64, 111, 42, "Cancel", false, factionBuyGUI.window[1])
    guiSetProperty(factionBuyGUI.button[1], "NormalTextColour", "FFAAAAAA")
    factionBuyGUI.combobox[1] = guiCreateComboBox(13, 35, 366, 113, "Select a faction to purchase for", false, factionBuyGUI.window[1])
    factionBuyGUI.button[2] = guiCreateButton(268, 64, 111, 42, "Accept", false, factionBuyGUI.window[1])
    guiSetProperty(factionBuyGUI.button[2], "NormalTextColour", "FFAAAAAA")

    for k,v in pairs(getElementData(localPlayer, "faction")) do
    	if exports.factions:hasMemberPermissionTo(localPlayer, k, "manage_interiors") then
    		guiComboBoxAddItem(factionBuyGUI.combobox[1], exports.factions:getFactionName(k))
    	end
    end

    addEventHandler("onClientGUIClick", factionBuyGUI.button[2], function()
    	local name = guiComboBoxGetItemText(factionBuyGUI.combobox[1], guiComboBoxGetSelected(factionBuyGUI.combobox[1]))

    	if name ~= "Select a faction to purchase for" then
			triggerServerEvent("buypropertyForFaction", localPlayer, interior, cost, isHouse, guiRadioButtonGetSelected(purchaseProperty.rad[1]), name)
    		closePropertyGUI()
    	else
    		outputChatBox("Please select a faction.", 255, 0, 0)
    	end
    end, false)

    addEventHandler("onClientGUIClick", factionBuyGUI.button[1], closeStartBuying, false)
end

function closeStartBuying()
	if factionBuyGUI.window[1] and isElement(factionBuyGUI.window[1]) then
		destroyElement(factionBuyGUI.window[1])
		factionBuyGUI.window[1] = nil
		if purchaseProperty.window[1] and isElement(purchaseProperty.window[1]) then
			guiSetEnabled(purchaseProperty.window[1], true)
		end
	end
end
