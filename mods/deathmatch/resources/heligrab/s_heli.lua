--[[ Heligrab - Server ]]--

local root = getRootElement()
local hanging_weight_limit = true

local hang_binds = get(getResourceName(getThisResource()) .. ".hang_binds")
local hang_commands = get(getResourceName(getThisResource()) .. ".hang_commands")
local drop_binds = get(getResourceName(getThisResource()) .. ".drop_binds")
local drop_commands = get(getResourceName(getThisResource()) .. ".drop_commands")

function ToggleHangingWeightLimit(state)
	if state then
		if state == true or state == false then
			hanging_weight_limit = state
			triggerClientEvent(root,"ToggleHangingWeightLimit",root,state)
		end
	end
end

--[[
addEvent("RequestHangingWeightLimit",true)
addEventHandler("RequestHangingWeightLimit",root,function()
]]
addEvent("RequestServerData",true)
addEventHandler("RequestServerData",root,function()
	-- piggy back the binds and commands here as well
	triggerClientEvent(source,"ReceiveServerData",root,hanging_weight_limit,hang_binds,hang_commands,drop_binds,drop_commands)
end)


function SetPlayerGrabbedHeli(player,state,heli,side_,line_percent_)
	if player then
		if state == true or state == "true" then
			-- if we have been given a heli
			if heli and isElement(heli) and getElementType(heli) == "vehicle" and getVehicleType(heli) == "Helicopter" then
				-- dont want to grab while also in a vehicle
				-- actually, there are too many possible situations to account for so leave it up to the caller to make sure the player is in a suitable state to be attached
				--if not isPedInVehicle(player) then
					
				-- default values
				local side = side_ or "right"
				local line_percent = line_percent_ or 0.5
	
				triggerClientEvent(player,"MakePlayerGrabHeli",player,heli,side,line_percent)
			end
		elseif state == false or state == "false" then
			local player_hanging = getElementData(player,"hanging")
			if player_hanging then
				triggerEvent("PlayerDropFromHeli",player,player_hanging.heli,"requested",true)
			end		
		end
	end
end


function IsPlayerHangingFromHeli(player)
	if player then
		if getElementData(player,"hanging") then
			return true
		else
			return false
		end
	end
	return nil
end


function GetPlayerHangingData(player)
	if player then
		local data = getElementData(player,"hanging")
		if data then
			return data.heli, data.side, data.line_percent, data.legs_up
		end
	end	
	return nil
end


function GetPlayersHangingFromHeli(heli,side_,line_percent_)
	if heli then
		local line = line_percent_ or false
		local side = side_ or false
		local hanging_players = {}
		
		for _,player in ipairs(getElementsByType("player")) do
			local data = getElementData(player,"hanging")
			if data then
				if ((side and side == data.side) or (not side)) and ((line and line == data.line) or (not line)) then
					table.insert(hanging_players,player)
				end
			end
		end
		
		if #hanging_players > 0 then
			return hanging_players
		else
			return nil
		end
	end
	
	return nil
end


--------------------------------------------------------
--[[
addCommandHandler("hanginfo",function(player)
	local hanging = IsPlayerHangingFromHeli(player)
	local heli,side,line,legs = GetPlayerHangingData(player)
	
	local hangers
	if heli then
		hangers = GetPlayersHangingFromHeli(heli)
	end
	
	outputChatBox("Hanging: "..tostring(hanging),player)
	outputChatBox("Data: "..tostring(heli)..", "..tostring(side)..", "..tostring(line)..", "..tostring(legs),player)
	outputChatBox("Hangers: ("..tostring(hangers)..")",player)
	
	if hangers then
		for _,p in ipairs(hangers) do
			outputChatBox(getPlayerName(p))
		end
	end	
end)
]]
--------------------------------------------------------


addEventHandler("onElementDestroy",root,function()
	if getElementType(source)=="vehicle" then
		if getVehicleType(source)=="Helicopter" then
			triggerClientEvent(root,"onClientVehicleDestroy",root,source)
		end
	end
end)


-- setting the camera target clientside frequently doesnt work (possible problem with getVehicleOccupant clientside), so do it serverside instead
function PlayerGrabVehicle(vehicle)
	SetCameraToHeliPilot(source,vehicle)
--	outputChatBox("Grabbed vehicle: "..getPlayerName(source))
end
addEvent("PlayerGrabVehicle",true)
addEventHandler("PlayerGrabVehicle",root,PlayerGrabVehicle)



function PlayerDropFromHeli(vehicle,reason,force)
	setCameraTarget(source,source)
--	outputChatBox("Dropped from heli: "..getPlayerName(source).." ["..reason.."]")
	for _,player in ipairs(getElementsByType("player")) do
		if (player ~= source) or (force) then
			triggerClientEvent(player,"PlayerDrop",source,reason,vehicle)
		end
	end
end
addEvent("PlayerDropFromHeli",true)
addEventHandler("PlayerDropFromHeli",root,PlayerDropFromHeli)



function SetCameraToHeliPilot(player,heli)
	local heli_driver = getVehicleOccupant(heli,0)
	if heli_driver then
		setCameraTarget(player,heli_driver)
--		outputChatBox("Set camera to heli")
	else
--		outputChatBox("could not set camera to pilot ("..tostring(heli_driver)..")")
	end	
end


-- reset the camera back to the player when the pilot exits the helicopter they are hanging from
addEventHandler("onPlayerVehicleExit",root,function(vehicle,seat)
	if getVehicleType(vehicle)=="Helicopter" and seat == 0 then
		for _,v in ipairs(getElementsByType("player")) do
			local player_hanging = getElementData(v,"hanging")
			if player_hanging and player_hanging.heli == vehicle then
				setCameraTarget(v,v)
			end
		end
	end
end)


-- set the camera on anyone hanging on the helicopter to the new pilot
addEventHandler("onPlayerVehicleEnter",root,function(vehicle,seat)
	if getVehicleType(vehicle)=="Helicopter" and seat == 0 then
		for _,v in ipairs(getElementsByType("player")) do
			local player_hanging = getElementData(v,"hanging")
			if player_hanging and player_hanging.heli == vehicle then
				setCameraTarget(v,source)
			end
		end
	end
end)


addEvent("RemoveHangingPedFromVehicle",true)
addEventHandler("RemoveHangingPedFromVehicle",root,function()
	removePedFromVehicle(source)
end)



addEventHandler("onResourceStop",getResourceRootElement(getThisResource()),function()
	for _,v in ipairs(getElementsByType("player")) do
		local player_hanging = getElementData(v,"hanging")
		if player_hanging then
			triggerEvent("PlayerDropFromHeli",v,player_hanging.heli,"stopped resource")
		end
	end	
end)
