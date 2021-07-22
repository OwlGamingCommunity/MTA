function spawnTheGates()
	local count = 0
	for k, v in pairs(gates) do
		local gate = createObject( objectID, v[7], v[8], v[9], v[10], v[11], v[12] )
		setElementInterior(gate, gateInt)
		setElementDimension(gate, gateDim)
		gates[k][13] = gate
		gates[k][14] = 0
		count = count + 1

		setElementData(gate, "prison-system:isGateMoving", false)
	end
	setElementData(resourceRoot, "gates", gates)
	outputDebugString("PRISON-SYSTEM: Loaded "..count.." cell gates from s_gates.lua")
end
addEventHandler("onResourceStart", resourceRoot, spawnTheGates)

function triggerAGate(gateID, allgates)
	if gateID and gates[gateID] then
		local gateElement = gates[gateID][13]
		local gateStatus = gates[gateID][14]
		if not getElementData(gateElement, "prison-system:isGateMoving") then
			if gateStatus == 1 then -- the gate is opened so you should close it
				gates[gateID][14] = 0
				moveObject( gateElement, 3500, gates[gateID][7], gates[gateID][8], gates[gateID][9], gates[gateID][10], gates[gateID][11], gates[gateID][12])

				setElementData(gateElement, "prison-system:isGateMoving", true)
				setTimer( function ()
						setElementData(gateElement, "prison-system:isGateMoving", false)
					end, 3500, 1) 

				for _, v in ipairs(getElementsByType("player")) do
					local pdim = getElementDimension(v)
					local pint = getElementInterior(v)

					if pdim == gateDim and pint == gateInt and not allgates then -- lets not play too much sounds if we trigger all gates...
						triggerClientEvent(v, "singleGateSound", v, gates[gateID][7], gates[gateID][8], gates[gateID][9])
					end
				end
			elseif gateStatus == 0 then -- the gate is closed so you should open it
				gates[gateID][14] = 1
				moveObject( gateElement, 3500, gates[gateID][1], gates[gateID][2], gates[gateID][3], gates[gateID][4], gates[gateID][5], gates[gateID][6])

				setElementData(gateElement, "prison-system:isGateMoving", true)
				setTimer( function ()
						setElementData(gateElement, "prison-system:isGateMoving", false)
					end, 3500, 1) 

				for _, v in ipairs(getElementsByType("player")) do
					local pdim = getElementDimension(v)
					local pint = getElementInterior(v)

					if pdim == gateDim and pint == gateInt and not allgates then -- lets not play too much sounds if we trigger all gates...
						triggerClientEvent(v, "singleGateSound", v, gates[gateID][1], gates[gateID][2], gates[gateID][3])
					end
				end
			else
				outputChatBox("ERROR CODE #G448E: Please submit a ticket at bugs.owlgaming.net with that bug code.", thePlayer, 255, 0, 0)
			end
			setElementData(resourceRoot, "gates", gates)
		end
	end
end
addEvent("triggerAGate", true)
addEventHandler("triggerAGate", resourceRoot, triggerAGate)

function triggerAllGates()
	setTimer( function ()
		for k, v in pairs(gates) do triggerAGate(k, "allgates") end -- loop to use function triggerAGate for all gates. We use 'allgates' there so that the playSound is not triggered for all gates. We'll use a single sound for that.
	end, 1400, 1)
	for _, player in ipairs(getElementsByType("player")) do
		if getElementDimension(player) == gateDim and getElementInterior(player) == gateInt then
			triggerClientEvent(player, "allGatesSound", player)
		end
	end
end
addEvent("triggerAllGates", true)
addEventHandler("triggerAllGates", resourceRoot, triggerAllGates)