local objects = {}
local oldDimension = nil
local safeToSpawn = true

function fallProtection(intx, inty, intz)
	local x, y, z = getElementPosition(localPlayer)
	local dim = getElementDimension(localPlayer)
	if ((intz - z) > 5 or getPedSimplestTask(localPlayer) == "TASK_SIMPLE_IN_AIR") and getElementData(localPlayer, "loggedin") == 1 and dim ~= 0 and not getElementData(localPlayer, "pd:snakecam") and not getElementData(localPlayer, "freecamTV:state") then
		outputChatBox("Warning: We detected a fall! Teleporting you to the interior entrance...", 0, 255, 0)
		triggerServerEvent("fallProtectionRespawn", root, intx, inty, intz)
	end
end

function isSafeToSpawn()
	if safeToSpawn then
		setElementFrozen(localPlayer, false)
		x, y, z = getElementPosition(localPlayer)
		setTimer(fallProtection, 2000, 1, x, y, z)
	else
		setTimer(isSafeToSpawn, 500, 1)
	end
end

function clearObjectsInDimension(dimension)
	for id, object in ipairs(objects[dimension] or {}) do
		destroyElement(object.object)
	end
	objects[dimension] = nil
end

function clearAllDimensionObjects()
	for dimension in pairs(objects) do
		clearObjectsInDimension(dimension)
	end
end

function streamDimensionIn(dimension)
	for id, data in ipairs(objects[dimension] or {}) do
		data.object = createObject(data.model, data.x, data.y, data.z, data.rot_x, data.rot_y, data.rot_z)

		setElementDimension(data.object, dimension)
		setElementInterior(data.object, data.interior)
		setElementCollisionsEnabled(data.object, data.is_solid)
		setElementDoubleSided(data.object, data.is_double_sided)
		setElementData(data.object, "object:dbid", data.id, false)
		setElementAlpha(data.object, data.alpha)

		if data.scale then
			setObjectScale(data.object, data.scale)
		end
		
		if data.is_breakable then
			setObjectBreakable(data.object, data.is_breakable)
		end
	end

	safeToSpawn = true
end

addEvent("onClientInteriorChange", true)

addEvent("object:sync", true)
addEventHandler("object:sync", root, function (dimensionObjects, dimension)
	clearObjectsInDimension(dimension)
	objects[dimension] = dimensionObjects
	streamDimensionIn(dimension)
end)

addEvent("object:safeTrue", true)
addEventHandler("object:safeTrue", resourceRoot, function ()
	safeToSpawn = true
end)

addEvent("object:clear", true)
addEventHandler("object:clear", root, clearObjectsInDimension)

addEventHandler("onClientPreRender", root, function ()
    local currentDimension = getElementDimension(localPlayer)
    
    if currentDimension == oldDimension then
        return
    end

    clearAllDimensionObjects()
    if currentDimension ~= 0 then
        safeToSpawn = false
        setElementFrozen(localPlayer, true)
        setTimer(isSafeToSpawn, 500, 1)

        if not objects[currentDimension] then
            triggerServerEvent("object:requestsync", localPlayer, currentDimension)
        else
            streamDimensionIn(currentDimension)
        end
    end
    triggerServerEvent("onPlayerInteriorChange", root, getElementInterior(localPlayer), currentDimension)
    oldDimension = currentDimension
end)

addEventHandler("onClientResourceStart", resourceRoot, function ()
	setTimer(function()
		setOcclusionsEnabled(false) -- to fix the object streaming issue (extreme low draw distance)
	end, 10000, 1)
end)