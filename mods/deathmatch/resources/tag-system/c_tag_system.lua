cooldown = nil
count = 0

function clientTagWall(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if (weapon==41) then
		local duty = getElementData(source, "duty")
		local tag = getElementData(source, "tag")

		--if exports.factions:isInFactionType(getLocalPlayer(), 2) and (duty~=14) then
			if not (hitElement) or (getElementType(hitElement)~="player") then -- Didn't attack someone
				
				if not cooldown then
					if (ammoInClip>10) and (weapon==41) then
						-- Check the player is near a wall
						local localPlayer = getLocalPlayer()
						local x, y, z = getElementPosition(localPlayer)
						local rot = getPedRotation(localPlayer)
						-- round the rotation to 10° to fix them being stuck halfway in a wall
						local rot2 = rot
						rot = math.floor( (rot+5)/10 ) * 10
						
						local matrix = getElementMatrix (localPlayer)
						
						-- DIRECTLY INFRONT OF PLAYER
						local oldX = 0
						local oldY = 1
						local oldZ = 0
						local newX = oldX * matrix[1][1] + oldY * matrix [2][1] + oldZ * matrix [3][1] + matrix [4][1]
						local newY = oldX * matrix[1][2] + oldY * matrix [2][2] + oldZ * matrix [3][2] + matrix [4][2]
						local newZ = oldX * matrix[1][3] + oldY * matrix [2][3] + oldZ * matrix [3][3] + matrix [4][3]
						
						-- TO LEFT OF PLAYER
						local oldXleft = -1.5
						local oldYleft = 1
						local oldZleft = 0
						local newXleft = oldXleft * matrix[1][1] + oldYleft * matrix [2][1] + oldZleft * matrix [3][1] + matrix [4][1]
						local newYleft = oldXleft * matrix[1][2] + oldYleft * matrix [2][2] + oldZleft * matrix [3][2] + matrix [4][2]
						local newZleft = oldXleft * matrix[1][3] + oldYleft * matrix [2][3] + oldZleft * matrix [3][3] + matrix [4][3]
						
						-- TO RIGHT OF PLAYER
						local oldXright = 1.5
						local oldYright = 1
						local oldZright = 0
						local newXright = oldXright * matrix[1][1] + oldYright * matrix [2][1] + oldZright * matrix [3][1] + matrix [4][1]
						local newYright = oldXright * matrix[1][2] + oldYright * matrix [2][2] + oldZright * matrix [3][2] + matrix [4][2]
						local newZright = oldXright * matrix[1][3] + oldYright * matrix [2][3] + oldZright * matrix [3][3] + matrix [4][3]
						
						-- TO TOP OF PLAYER
						local oldXtop = 0
						local oldYtop = 1
						local oldZtop = 1
						local newXtop = oldXtop * matrix[1][1] + oldYtop * matrix [2][1] + oldZtop * matrix [3][1] + matrix [4][1]
						local newYtop = oldXtop * matrix[1][2] + oldYtop * matrix [2][2] + oldZtop * matrix [3][2] + matrix [4][2]
						local newZtop = oldXtop * matrix[1][3] + oldYtop * matrix [2][3] + oldZtop * matrix [3][3] + matrix [4][3]
						
						local facingWall, cx, cy, cz, element = processLineOfSight(x, y, z, newX, newY, newZ, true, false, false, true, false)
						local facingWallleft, lx, ly, lz, lelement = processLineOfSight(x, y, z, newXleft, newYleft, newZleft, true, false, false, true, false)
						local facingWallright, rx, ry, rz, relement = processLineOfSight(x, y, z, newXright, newYright, newZright, true, false, false, true, false)
						local facingWalltop, tx, ty, tz, telement = processLineOfSight(x, y, z, newXtop, newYtop, newZtop, true, false, false, true, false)
						
						if not (facingWall) or not (facingWallleft) or not (facingWallright) or not (facingWalltop) then
							outputChatBox("You are not near a wall.", 255, 0, 0)
							count = 0
							cooldown = setTimer(resetCooldown, 5000, 1, false)
						else
							count = count + 1
							
							if (count==20) then
								count = 0
								cooldown = setTimer(resetCooldown, 30000, 1, false)
								local interior = getElementInterior(localPlayer)
								local dimension = getElementDimension(localPlayer)
								
								--cx = cx - math.sin(math.rad(rot)) * 0.1
								cy = cy - math.cos(math.rad(rot)) * 0.1
								
								triggerServerEvent("createTag", localPlayer, cx, cy, cz, rot, interior, dimension) 
							end
						end
					end
				end
			--end
		end
	end
end
addEventHandler("onClientPlayerWeaponFire", getLocalPlayer(), clientTagWall)

function resetCooldown(killTheTimer)
	if killTheTimer and cooldown then
		killTimer(cooldown)
	end
	cooldown = nil
end
bindKey('fire', 'up',
	function()
		if tonumber(getElementData(getLocalPlayer(), "tag")) == 9 then
			resetCooldown(true)
		end
	end
) 