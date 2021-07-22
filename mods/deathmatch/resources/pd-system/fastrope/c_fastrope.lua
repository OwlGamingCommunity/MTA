local seat = -1

function storeSeat(vehicle, theSeat)
	seat = theSeat
end
addEventHandler("onClientVehicleEnter", getLocalPlayer(), storeSeat)

function Rope()
triggerServerEvent("startRappel", localPlayer, x, y, z, gz)
end
function fastRope()
	local localPlayer = getLocalPlayer()
	local vehicle = getPedOccupiedVehicle(localPlayer)

	if (vehicle) then
		local model = getElementModel(vehicle)

		if (model==497) or (model==563) then
			local x, y, z = getElementPosition(localPlayer)
			local r = getPedRotation(localPlayer)

			local gz = getGroundPosition(x, y, z)

			addRope(x, y, z, gz)
			triggerServerEvent("startRappel", localPlayer, x, y, z, gz)
		end
	end
end
addCommandHandler("fastrope", fastRope, false)

local ropes = { }

function destroyRope(x, y, z, gz)
	for i = 1, 10 do
		if (ropes[i]~=nil) then
			local ropex = ropes[i][1]
			local ropey = ropes[i][2]
			local ropez = ropes[i][3]
			local ropegz = ropes[i][4]

			if (x==ropex and y==ropey and z==ropez and gz==ropegz) then
				ropes[i][1] = nil
				ropes[i][2] = nil
				ropes[i][3] = nil
				ropes[i][4] = nil
				ropes[i] = nil
				break
			end
		end
	end
end

function addRope(x, y, z, gz)
	-- only supports 10 ropes at one time =[
	for i = 1, 10 do
		if (ropes[i]==nil) then
			ropes[i] = { }
			ropes[i][1] = x
			ropes[i][2] = y
			ropes[i][3] = z
			ropes[i][4] = gz
			setTimer(destroyRope, 2500, 1, x, y, z, gz)
			break
		end
	end
end
addEvent("createRope", true)
addEventHandler("createRope", getRootElement(), addRope)

function showRopes()
	for k,v in pairs(ropes) do
		local x = v[1]
		local y = v[2]
		local z = v[3]
		local gz = v[4]
		local vehicle = v[5]
		--createSWATRope(x, y, z, 5000)
		dxDrawLine3D(x, y, z-2, x+0.5, y+0.5, gz, tocolor(0,0,0,255), 2, false, 1)
	end
end
addEventHandler("onClientRender", getRootElement(), showRopes)
