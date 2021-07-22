local emitters = { }

function createEmitter(thePlayer, commandName, type)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		
		if not (type) or (type - 0 > 3) or (type - 0 < 1) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Emitter Type]", thePlayer, 255, 194, 14)
			outputChatBox("Type 1: Synced Small Fire Emitter", thePlayer, 255, 194, 14)
			outputChatBox("Type 2: Synced Large Fire Emitter", thePlayer, 255, 194, 14)
			outputChatBox("Type 3: Synced Water Emitter", thePlayer, 255, 194, 14)
		else
			if tonumber(type) == 1 or tonumber(type) == 2 then
				setElementData(thePlayer, "emitter:fireResistance", true, true)
				setTimer(function() 
					setElementData(thePlayer, "emitter:fireResistance", false, true)
				end, 10000*3, 1) -- give admin 30 seconds to avoid being damaged by fire / MAXIME
			end
			
			local id = #emitters + 1
			local x, y, z = getElementPosition(thePlayer)
			
			emitters[id] = { }
			emitters[id][1] = x
			emitters[id][2] = y
			emitters[id][3] = z - 1
			emitters[id][4] = type
			emitters[id][5] = createObject(848 + type, x, y, z)
			emitters[id][6] = getPlayerName(thePlayer)
			
			setElementAlpha(emitters[id][5], 0)
			setElementDimension(emitters[id][5], getElementDimension(thePlayer))
			setElementInterior(emitters[id][5], getElementInterior(thePlayer))
			outputChatBox("Emitter created with ID " .. id .. " and Type " .. type .. ".", thePlayer, 0, 255, 0)
		end
	end
end
addCommandHandler("createemitter", createEmitter, false, false)

function nearbyEmitters(thePlayer)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local count = 0
		outputChatBox("Nearby Emitters: ", thePlayer, 255, 194, 15)
		local px, py, pz = getElementPosition(thePlayer)
		for key, value in ipairs(emitters) do
			local x = emitters[key][1]
			local y = emitters[key][2]
			local z = emitters[key][3]
			local type = emitters[key][4]
			local creator = emitters[key][6]
			
			if ( getDistanceBetweenPoints3D(x, y, z, px, py, pz) < 50) and getElementDimension( thePlayer ) == getElementDimension( value[5] ) then
				count = count + 1
				outputChatBox("Emitter with ID " .. key .. " and type " .. type .. " created by "..creator..".", thePlayer, 255, 194, 15)
			end
		end
		
		if ( count == 0 ) then
			outputChatBox("None.", thePlayer, 255, 194, 15)
		end
	end
end
addCommandHandler("nearbyemitters", nearbyEmitters)

function delEmitter(thePlayer, commandName, id)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (id) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Emitter ID]", thePlayer, 255, 194, 14)
		else
			if ( emitters[tonumber(id)] == nil ) then
				outputChatBox("Invalid Emitter ID.", thePlayer, 255, 0, 0)
			else
				local obj = emitters[tonumber(id)][5]
				emitters[tonumber(id)] = nil
				destroyElement(obj)
				outputChatBox("Emitter with ID " .. id .. " was deleted.", thePlayer, 0, 255, 0)
			end
		end
	end
end
addCommandHandler("delemitter", delEmitter)

function delEmitters(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local count = 0
		for k, v in pairs( emitters ) do
			destroyElement( v[5] )
			count = count + 1
		end
		emitters = {}
		outputChatBox("Deleted " .. count .. " Emitters.", thePlayer, 0, 255, 0)
	end
end
addCommandHandler("delemitters", delEmitters)