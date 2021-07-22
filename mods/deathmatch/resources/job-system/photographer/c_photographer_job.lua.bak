beautifulPeople = { [90]=true, [92]=true, [93]=true, [97]=true, [138]=true, [139]=true, [140]=true, [146]=true, [152]=true }
cop = { [280]=true, [281]=true, [282]=true, [283]=true, [84]=true, [286]=true, [288]=true, [287]=true }
swat = { [285]=true }
flashCar = { [601]=true, [541]=true, [415]=true, [480]=true, [411]=true, [506]=true, [451]=true, [477]=true, [409]=true, [580]=true, [575]=true, [603]=true }
emergencyVehicles = { [416]=true, [427]=true, [490]=true, [528]=true, [407]=true, [544]=true, [523]=true, [598]=true, [596]=true, [597]=true, [599]=true, [601]=true }

local collectionValue = 0
local localPlayer = getLocalPlayer()

-- Ped at submission desk just for the aesthetics.
local victoria = createPed(141, 2469.90625, -1730.3955078125, 200.01393127441)
setPedRotation(victoria, 180)
setElementFrozen(victoria, true)
setElementDimension(victoria, 1200)
setElementInterior(victoria, 1)
setPedAnimation ( victoria, "INT_OFFICE", "OFF_Sit_Idle_Loop", -1, true, false, false )
setElementData( victoria, "talk", 1, false )
setElementData( victoria, "name", "Victoria Greene", false )
--[[
local victoria = createPed(141, 1338.35, -965.45, 413.91)
setPedRotation(victoria, 90)
setElementFrozen(victoria, true)
setElementDimension(victoria, 1712)
setElementInterior(victoria, 0)
setPedAnimation ( victoria, "INT_OFFICE", "OFF_Sit_Idle_Loop", -1, true, false, false )
setElementData( victoria, "talk", 1 )
setElementData( victoria, "name", "Victoria Greene", false )]]


function snapPicture(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement )
	local logged = getElementData(localPlayer, "loggedin")
	
	if (logged==1) then
		local theTeam = getPlayerTeam(localPlayer)
		
		if (theTeam) then
			local factionType = getElementData(theTeam, "type")
			
			if (factionType==6) then
				if (weapon == 43) then
					local pictureValue = 0
					local onScreenPlayers = {}
					local players = getElementsByType( "player" )
					for theKey, thePlayer in ipairs(players) do			-- thePlayer ~= localPlayer
						if (isElementOnScreen(thePlayer) == true ) then
							table.insert(onScreenPlayers, thePlayer)	-- Identify everyone who is on the screen as the picture is taken.
						end
					end
					for theKey,thePlayer in ipairs(onScreenPlayers) do
						local Tx,Ty,Tz = getElementPosition(thePlayer)
						local Px,Py,Pz = getElementPosition(getLocalPlayer())
						local isclear = isLineOfSightClear (Px, Py, Pz +1, Tx, Ty, Tz, true, true, false, true, true, false)
						if (isclear) then
							-------------------
							-- Player Checks --
							-------------------
							local skin = getElementModel(thePlayer)
							if(beautifulPeople[skin]) then
								pictureValue=pictureValue+25
							end
							if(getPedWeapon(thePlayer)~=0)and(getPedTotalAmmo(thePlayer)~=0) then
								pictureValue=pictureValue+12
								if (cop[skin])then
									pictureValue=pictureValue+3
								end
							end
							if(swat[skin])then
								pictureValue=pictureValue+25
							end
							if(getPedControlState(thePlayer, "fire"))then
								pictureValue=pictureValue+25
							end
							if(isPedChoking(thePlayer))then
								pictureValue=pictureValue+25
							end
							if(isPedDoingGangDriveby(thePlayer))then
								pictureValue=pictureValue+50
							end
							if(isPedHeadless(thePlayer))then
								pictureValue=pictureValue+100
							end
							if(isPedOnFire(thePlayer))then
								pictureValue=pictureValue+125
							end
							if(isPlayerDead(thePlayer))then
								pictureValue=pictureValue+75
							end
							if (#onScreenPlayers>3)then
								pictureValue=pictureValue+5
							end
							--------------------
							-- Vehicle checks --
							--------------------
							local vehicle = getPedOccupiedVehicle(thePlayer)
							if(vehicle)then
								if(flashCar[vehicle])then
									pictureValue=pictureValue+100
								end
								if(emergencyVehicle[vehicle])and(getVehicleSirensOn(vehicle)) then
									pictureValue=pictureValue+50
								end
								if not (isVehicleOnGround(vehicle))then
									pictureValue=pictureValue+100
								end
							end
						end
					end
					if(pictureValue==0)then
						outputChatBox("No one is going to pay for that picture...", 255, 0, 0)
					else
						collectionValue = collectionValue + pictureValue
						outputChatBox("#FF9933That's a keeper! Picture value: $"..exports.global:formatMoney(pictureValue), 255, 104, 91, true)
						triggerServerEvent("updateCollectionValue", localPlayer, collectionValue)
					end
					outputChatBox("#FF9933Collection value: $"..exports.global:formatMoney(collectionValue), 255, 104, 91, true)
				end
			end
		end
	end
end
addEventHandler("onClientPlayerWeaponFire", getRootElement(), snapPicture)

-- /totalvalue to see how much your collection of pictures is worth.
function showValue()
	outputChatBox("#FF9933Collection value: $"..exports.global:formatMoney(collectionValue), 255, 104, 91, true)
end
addCommandHandler("totalvalue", showValue, false, false)

local open = false
function cPhotoOptions()
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if not open then
		local width, height = 150, 100
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)

		sanOptionMenu = guiCreateWindow(x, y, width, height, "How can we help you?", false)

		bPhotos = guiCreateButton(0.05, 0.3, 0.87, 0.25, "Sell Photos", true, sanOptionMenu)
		addEventHandler("onClientGUIClick", bPhotos, startPhotos, false)

		if (getElementDimension(victoria) ~= 9902) then
			bAdvert = guiCreateButton(0.05, 0.6, 0.87, 0.25, "Place Advert", true, sanOptionMenu)
			addEventHandler("onClientGUIClick", bAdvert, startAdvert, false)
		end

		showCursor(true)
		open = true
	end
end
addEvent("cPhotoOption", true)
addEventHandler("cPhotoOption", getRootElement(), cPhotoOptions)

function startPhotos()
	destroyElement(sanOptionMenu)
	triggerEvent("cSellPhotos", getLocalPlayer())
	showCursor(false)
	open = false
end

function startAdvert()
	destroyElement(sanOptionMenu)
	open = false
	triggerServerEvent("cSANAdvert", getLocalPlayer())
	showCursor(false)
end

addEvent("cSellPhotos", true)
addEventHandler("cSellPhotos", localPlayer, 
	function()
		local theTeam = getPlayerTeam(localPlayer)
		if getElementData(theTeam, "type") == 6 then
			if collectionValue == 0 then
				outputChatBox("None of the pictures you have are worth anything.", 255, 0, 0, true)
			else
				triggerServerEvent("submitCollection", localPlayer, collectionValue)
				collectionValue = 0
			end
		else
			triggerServerEvent("sellPhotosInfo", localPlayer)
		end
	end
)

addEvent("updateCollectionValue", true)
addEventHandler("updateCollectionValue", localPlayer,
	function(value)
		collectionValue = value
		if value > 0 then
			outputChatBox("You still have photos worth $" .. exports.global:formatMoney(collectionValue) .. ".", 255, 194, 14)
		end
	end
)

addEventHandler( "onClientResourceStart", getResourceRootElement(),
	function()
		triggerServerEvent( "getCollectionValue", localPlayer )
	end
)

addEvent("job:photo:heli", true)
function photoHeli()
	local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
	if theVehicle then
		local vehicleModel = getElementModel(theVehicle)
		if vehicleModel == 488 or vehicleModel == 487 then
			local currentAlpha = getElementAlpha(theVehicle)
			if currentAlpha ~= 0 then
				setElementAlpha(theVehicle, 0)
				setElementAlpha(getLocalPlayer(), 0)
			else
				setElementAlpha(theVehicle, 255)
				setElementAlpha(getLocalPlayer(), 255)
			end
		end
	end
end
addEventHandler("job:photo:heli", getRootElement(), photoHeli)