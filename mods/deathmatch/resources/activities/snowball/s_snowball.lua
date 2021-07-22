-- object: 1974
local snowBallObj = 1974
local timeToMelt = 60000 -- 1 minute
local snowThrowSpeed = 500

function makeSnowball(thePlayer)
	if not getElementData(thePlayer, "snowball") then
		if not isPedDucked(thePlayer) then
			setPedAnimation(thePlayer, "bsktball", "bball_pickup", 500, false, true, false, false)
		end
		setTimer(function()
			local x, y, z = getElementPosition(thePlayer)
			local obj = createObject(snowBallObj, x, y, z)
			setElementCollisionsEnabled(obj, false)
			exports.bone_attach:attachElementToBone(obj, thePlayer, 12, 0, 0, 0.1) -- right hand
			setElementData(thePlayer, "snowball", obj)
			bindKey(thePlayer, "mouse1", "down", shootBall)
			triggerEvent('sendAme', thePlayer, "picks snow from the ground and forms a snowball.")

			setTimer(function()
				if isElement(obj) then destroyElement(obj) end
				if isElement(thePlayer) then 
					if getElementData(thePlayer, "snowball") then
						if getElementData(thePlayer, "snowball") == obj then
							triggerEvent('sendAme', thePlayer, "'s snowball has melted from their hand.")
							setElementData(thePlayer, "snowball", false)
							unbindKey(thePlayer, "mouse1", "down", shootBall)
						end
					end
				end
			end, timeToMelt, 1)
		end, 1000, 1)
	end
end

addEvent("xmas:snowball:make", true)
addEventHandler("xmas:snowball:make", root, makeSnowball)

function throwSnowball(thePlayer, x, y, z, hitElement, hit)
	if getElementData(thePlayer, "snowball") then
		local obj = getElementData(thePlayer, "snowball")
		setPedAnimation(thePlayer, "grenade", "weapon_throw", 700, false, true, false, false)
		triggerEvent('sendAme', thePlayer, " throws a snowball.")
		unbindKey(thePlayer, "mouse1", "down", shootBall)
		
		setTimer(function()
			exports.bone_attach:detachElementFromBone(obj)
			setElementPosition(obj, getElementPosition(thePlayer))
			moveObject(obj, snowThrowSpeed, x, y, z, 0, 0, 0, "OutQuad")
			setElementData(thePlayer, "snowball", false)
			setTimer(function()
				triggerClientEvent("xmas:snow:effect", resourceRoot, x, y, z)
				destroyElement(obj)
				if hitElement then
					triggerEvent('sendAme', hitElement, "gets hit by a snowball.")
					triggerClientEvent(hitElement, "xmas:snow:sound", resourceRoot)
				end

				if hit then
					triggerClientEvent("xmas:snow:sound3d", resourceRoot, x, y, z)
				end
			end, snowThrowSpeed, 1)
		end, 200, 1)
	end
end
addEvent("xmas:snow:throw", true)
addEventHandler("xmas:snow:throw", resourceRoot, throwSnowball)

function shootBall(thePlayer)
	triggerClientEvent(thePlayer, "xmas:snow:shoot", resourceRoot)
end

function predeleteBall()
	if getElementData(source, "snowball") then
		local obj = getElementData(source, "snowball") or false
		if obj and isElement(obj) then
			destroyElement(obj)
		end
	end
end
addEventHandler("accounts:characters:change", getRootElement(), predeleteBall)
addEventHandler("onPlayerQuit", getRootElement(), predeleteBall)