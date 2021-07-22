wPedRightClick = nil
bTalkToPed, bClosePedMenu = nil, nil
ax, ay = nil, nil
closing = nil
sent=false

function pedDamage()
	cancelEvent()
end
addEventHandler("onClientPedDamage", getRootElement(), pedDamage)

function clickPed(button, state, absX, absY, wx, wy, wz, element)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if (element) and (getElementType(element)=="ped") and (button=="right") and (state=="down") and (sent==false) and (element~=getLocalPlayer()) then
		if (isPedDoingGangDriveby(getLocalPlayer()) == true) then
			setPedWeaponSlot(getLocalPlayer(), 0)
			setPedDoingGangDriveby(getLocalPlayer(), false)
		end
		local gatekeeper = getElementData(element, "talk")
		if (gatekeeper) then
			local x, y, z = getElementPosition(getLocalPlayer())

			if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=3) then
				if (wPedRightClick) then
					hidePlayerMenu()
				end

				showCursor(true)
				ax = absX
				ay = absY
				local w, h = 150, 75
				player = element
				closing = false
				local pedName = getElementData(element, "name") or "The Storekeeper"
				pedName = tostring(pedName):gsub("_", " ")
				--wPedRightClick = guiCreateWindow(ax, ay, 150, 75, pedName, false)

				if pedName == "Tony Johnston" then showCursor(false) return end



				wPedRightClick = guiCreateStaticImage(ax-w/2, ay-h/2, w, h , ":resources/window_body.png", false)
				local l1 = guiCreateLabel(0, 0.08, 1, 0.25, pedName, true, wPedRightClick)
				guiLabelSetHorizontalAlign(l1, "center")
				bTalkToPed = guiCreateButton(0.05, 0.3, 0.87, 0.25, "Talk", true, wPedRightClick)
				addEventHandler("onClientGUIClick", bTalkToPed,  function (button, state)
					if(button == "left" and state == "up") then

						hidePedMenu()

						local ped = getElementData(element, "name")
						local isFuelped = getElementData(element,"ped:fuelped")
						local isTollped = getElementData(element,"ped:tollped")
						local isShopKeeper = getElementData(element,"shopkeeper") or false

						if (ped=="Steven Pullman") then
							triggerServerEvent( "startStevieConvo", getLocalPlayer())
							if (getElementData(element, "activeConvo")~=1) then
								triggerEvent ( "stevieIntroEvent", getLocalPlayer()) -- Trigger Client side function to create GUI.
							end
						elseif (ped=="Hunter") then
							triggerServerEvent( "startHunterConvo", getLocalPlayer())
						elseif (ped=="Rook") then
							triggerServerEvent( "startRookConvo", getLocalPlayer())
						elseif (ped=="Victoria Greene") then
							triggerEvent("cSANGreeting", getLocalPlayer())
						elseif (ped=="Jessie Smith") then
							--triggerEvent("onEmployment", getLocalPlayer())
							triggerEvent("cityhall:jesped", getLocalPlayer())
						elseif (ped=="Carla Cooper") then
							triggerEvent("onLicense", getLocalPlayer())
						elseif (ped=="Dominick Hollingsworth") then
							triggerEvent("showRecoverLicenseWindow", getLocalPlayer())
						elseif (ped=="Mr. Clown") then
							triggerServerEvent("electionWantVote", getLocalPlayer())
						elseif (ped=="Guard Jenkins") then
							triggerServerEvent("gateCityHall", getLocalPlayer())
						elseif (ped=="Airman Connor") then
							triggerServerEvent("gateAngBase", getLocalPlayer())
						elseif (ped=="Rosie Jenkins") then
							triggerEvent("lses:popupPedMenu", getLocalPlayer())
						--[[elseif (ped=="Jacob Greenaway") then
							triggerEvent("lses:popupPedMenu", getLocalPlayer())]]
						elseif (ped=="Gabrielle McCoy") then
							triggerEvent("cBeginPlate", getLocalPlayer())
						--elseif (ped=="Vanna Spadafora") then
							--triggerEvent("vm:popupPedMenu", getLocalPlayer())
						elseif (isFuelped == true) then
							triggerServerEvent("fuel:startConvo", element)
						elseif (isTollped == true) then
							triggerServerEvent("toll:startConvo", element)
						elseif (ped=="Novella Iadanza") then
							triggerServerEvent("onSpeedyTowMisterTalk", getLocalPlayer())
						elseif isShopKeeper then -- MAXIME
							triggerServerEvent("shop:keeper", element)
						elseif (ped=="Maxime Du Trieux") then --Banker ATM Service, MAXIME
							triggerEvent("bank-system:bankerInteraction", getLocalPlayer())
						elseif (ped=="Jonathan Smith") then --Banker General Service, MAXIME
							triggerServerEvent( "bank:showGeneralServiceGUI", getLocalPlayer(), getLocalPlayer())
						elseif getElementData(element,"carshop") then
							triggerServerEvent( "vehlib:sendLibraryToClient", localPlayer, localPlayer, element)
						elseif (ped=="Andre Martin") then
							triggerServerEvent('clothing:list', getResourceRootElement (getResourceFromName("mabako-clothingstore")))
						elseif (ped=="Evelyn Branson") then
							triggerEvent("airport:ped:receptionistFAA", localPlayer, element)
						elseif (ped=="John G. Fox") then
							triggerServerEvent("startPrisonGUI", root, localPlayer)
						elseif (ped=="Georgio Dupont") then
       						triggerEvent("locksmithGUI", localPlayer, localPlayer)
       					elseif (ped=="Corey Byrd") then
							triggerEvent('ha:treatment', getLocalPlayer())
						elseif (ped=="Jacob Garcia") then --RT impounder / Maxime
							triggerServerEvent("tow:openImpGui", localPlayer, ped)
						elseif (ped=="Greer Reid") then -- RT Release / Maxime
							--triggerServerEvent("onTowMisterTalk", getLocalPlayer())
							triggerServerEvent("tow:openReleaseGUI", localPlayer, ped)
						elseif (ped=="Justin Borunda") then --PD impounder / Maxime
							triggerServerEvent("tow:openImpGui", localPlayer, ped)
						elseif (ped=="Sergeant K. Johnson") then --PD release / Maxime
							triggerServerEvent("tow:openReleaseGUI", localPlayer, ped)
						elseif (ped=="Bobby Jones") then --SCoSA impounder / Maxime 
							triggerServerEvent("tow:openImpGui", localPlayer, ped)
						elseif (ped=="Robert Dunston") then --HP release / Maxime
							triggerServerEvent("tow:openReleaseGUI", localPlayer, ped)
						elseif (ped=="Melina Dupont") then -- Custom clothes NPC at Dupont HQ.
							--exports.hud:sendBottomNotification(getLocalPlayer(),(ped or "NPC").." says:", "        'Hello! Our service is temporarily closed down at the moment. Please check back later!'")
							exports.clothes:openClothesWizard(element)
						else
							exports.hud:sendBottomNotification(getLocalPlayer(),(ped or "NPC").." says:", "        'Hi!'")
						end
					end
				end, false)

				bClosePedMenu = guiCreateButton(0.05, 0.6, 0.87, 0.25, "Close Menu", true, wPedRightClick)
				addEventHandler("onClientGUIClick", bClosePedMenu, hidePedMenu, false)
				sent=true
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickPed, true)

function hidePedMenu()
	if (isElement(bTalkToPed)) then
		destroyElement(bTalkToPed)
	end
	bTalkToPed = nil

	if (isElement(bClosePedMenu)) then
		destroyElement(bClosePedMenu)
	end
	bClosePedMenu = nil

	if (isElement(wPedRightClick)) then
		destroyElement(wPedRightClick)
	end
	wPedRightClick = nil

	ax = nil
	ay = nil
	sent=false
	showCursor(false)

end
