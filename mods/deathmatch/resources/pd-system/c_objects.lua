local objects = { }

local copSkins = { [280] = true, [281] = true, [282] = true, [283] = true, [284] = true, [285] = true, [286] = true, [287] = true, [288] = true }

function resStart(res)
	if (res==getThisResource()) then
		for key, value in ipairs(getElementsByType("player")) do
			streamIn(value)
		end
	end
end
addEventHandler("onClientResourceStart", getRootElement(), resStart)

function streamIn(player)
	if (player) then source = player end

	if (getElementType(source)=="player") then
		local skin = getPedSkin(source)
		if (copSkins[skin]) then
			objects[source] = { }
			local x, y, z = getPedBonePosition(source, 51)
			local px, py, pz = getElementPosition(source)
			local rot = getPedRotation(source)
			
			objects[source][1] = createObject(330, x, y, z, 0, 0, 45)
			setObjectScale(objects[source][1], 0.8)
			setElementCollisionsEnabled(objects[source][1], false)
			attachElements(objects[source][1], source, -0.09, -0.09, z-pz, 0, 0, 180)
		end
	end
end
addEventHandler("onClientElementStreamIn", getRootElement(), streamIn)