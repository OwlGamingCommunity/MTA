local chatting = false
local chatters = { }

function checkForChat()
	if not (getElementAlpha(getLocalPlayer()) == 0) then
		if (isChatBoxInputActive() and not chatting) then
			chatting = true
			triggerServerEvent('chat1', getLocalPlayer())
		elseif (not isChatBoxInputActive() and chatting) then
			chatting = false
			triggerServerEvent('chat0', getLocalPlayer())
		end
	end
end
setTimer(checkForChat, 200, 0)

function addChatter()
	for key, value in ipairs(chatters) do
		if ( value == source ) then
			return
		end
	end
	table.insert(chatters, source)
end
addEvent('addChatter', true)
addEventHandler('addChatter', getRootElement(), addChatter)

function delChatter()
	for key, value in ipairs(chatters) do
		if ( value == source ) then
			table.remove(chatters, key)
		end
	end
end
addEvent('delChatter', true)
addEventHandler('delChatter', getRootElement(), delChatter)
addEventHandler('onClientPlayerQuit', getRootElement(), delChatter)

function render()
	if not exports.hud:isActive() then return end
	local x, y, z = getElementPosition(getLocalPlayer())
	local reconx = getElementData(getLocalPlayer(), 'reconx')
	for key, value in ipairs(chatters) do
		if (isElement(value)) then
			if getElementType(value) == 'player' then
				local px, py, pz = getPedBonePosition(value, 6)

				local dist = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
				if isElementOnScreen(value) and getElementAlpha(value) ~= 0 and not getElementData(value, 'freecam:state') then
					if (dist>25) then
						chatters[value] = nil
						return
					end

					local lx, ly, lz = getCameraMatrix()
					local vehicle = getPedOccupiedVehicle(value) or nil
					local collision, cx, cy, cz, element = processLineOfSight(lx, ly, lz, px, py, pz+1, true, true, true, true, false, false, true, false, vehicle)
					if not (collision) or (reconx) then
						local screenX, screenY = getScreenFromWorldPosition(px, py, pz+0.5)
						if (screenX and screenY) then
							local scale = 3
							dist = dist / scale

							if (dist<1) then dist = 1 end
							if (dist>scale and reconx) then dist = scale end

							local chatIcon = 'chat.png'
							local iconSizeW, iconSizeH = 282, 143
							if getResourceFromName('donators') then
								local hasPerk, perkValue = exports.donators:hasPlayerPerk(value, 29)
								if hasPerk and perkValue then
									if tonumber(perkValue) then
										perkValue = tonumber(perkValue)
										if perkValue ~= 1 then
											chatIcon = exports.donators:getFlagURL(perkValue)
										end
									end
								end
							end

							dxDrawImage(screenX, screenY, iconSizeW*0.5 / dist, iconSizeH*0.5 / dist, chatIcon)
						end
					end
				end
			else
				chatters[key] = nil
			end
		else
			chatters[key] = nil
		end
	end
end

function updateTypingIcon()
	local state = getElementData(localPlayer, 'graphic_typingicon')
	if (state == '0') then
		triggerServerEvent('chaticon0', getLocalPlayer())
		removeEventHandler('onClientRender', getRootElement(), render)
	else
		triggerServerEvent('chaticon1', getLocalPlayer())
		addEventHandler('onClientRender', getRootElement(), render)
	end
end
addEvent('accounts:settings:graphic_typingicon', false)
addEventHandler('onClientResourceStart', resourceRoot, updateTypingIcon)
addEventHandler('accounts:settings:graphic_typingicon', root, updateTypingIcon)
