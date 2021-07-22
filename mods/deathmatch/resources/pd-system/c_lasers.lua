lasers = {}

function showLaser()
	for element, _ in ipairs(lasers) do
		if (isElement(element)) and (isElementStreamedIn(element)) then
			local weapon = getPedWeapon(element)

			if (weapon==24 or weapon==29 or weapon==31 or weapon==34) then
				local laser = getElementData(element, "laser")
				local deaglemode = getElementData(element, "deaglemode")

				if (laser) and (deaglemode==nil or deaglemode==0) then
					local sx, sy, sz = getPedWeaponMuzzlePosition(element)
					local ex, ey, ez = getPedTargetEnd(element)
					local task = getPedTask(element, "secondary", 0)

					if (task=="TASK_SIMPLE_USE_GUN") then
						local collision, cx, cy, cz, elementline = processLineOfSight(sx, sy, sz, ex, ey, ez, true, true, true, true, true, false, false, false)

						if not (collision) then
							cx = ex
							cy = ey
							cz = ez
						end

						dxDrawLine3D(sx, sy, sz-0.05, cx, cy, cz, tocolor(255,0,0,75), 2, false, 0)
					end
				end
			end
		elseif not isElement(element) then
			lasers[element] = nil
		end
	end
end
addEventHandler("onClientRender", getRootElement(), showLaser)

function addLaser(element)
	lasers[element] = true
end
addEvent("addLaser", true)
addEventHandler("addLaser", resourceRoot, addLaser)

function removeLaser(element)
	if lasers[element] then
		lasers[element] = nil
	end
end
addEvent("removeLaser", true)
addEventHandler("removeLaser", resourceRoot, removeLaser)

function populateList()
	for key, value in ipairs(getElementsByType("player")) do
		local laser = getElementData(value, "laser")
		if (laser) then
			lasers[value] = true
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, populateList)
