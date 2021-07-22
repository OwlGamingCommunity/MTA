-- Script: artifacts
-- Description: Handles artifacts (things players can wear that are not clothes)
-- Client-Side
-- Created by Exciter for Owl Gaming, 15.05.2014 (DD/MM/YYYY)
-- Thanks to Adams, iG Scripting Team and RPP Scripting Team for their base work.
-- License: BSD

local localPlayer = getLocalPlayer()
local root = getRootElement()

--[[addEvent('artifacts:startChecking', true)

local currentInterior, currentDimension = 0, 0
local checking = false
function doCheck() --This function checks continously for a player interior or dimension change, in order to move all attached objects with the player when changing int/dim
	local newInterior, newDimension = getElementInterior(localPlayer), getElementDimension(localPlayer)
	if currentInterior ~= newInterior or currentDimension ~= newDimension then
		triggerServerEvent('artifacts:update', root, localPlayer, newInterior, newDimension)
		currentInterior, currentDimension = newInterior, newDimension
	end
end

function startChecking(check) --This function starts the whole int/dim check, since we dont need to start this check before we know the player is wearing something
	check = check or false
	if check then
		if not checking then
			currentInterior, currentDimension = getElementInterior(localPlayer), getElementDimension(localPlayer)
			doCheckTimer = setTimer(doCheck, 1000, 0)
			checking = true
		end
	else
		if checking then
			killTimer(doCheckTimer)
			checking = false
		end
	end
end
addEventHandler('artifacts:startChecking', root, startChecking)]]

function applyTextureToArtifact(object, texData)
	if object and isElement(object) and texData then
		for k,v in ipairs(texData) do
			local path = v[1]
			local name = v[2]
			local shader, tec = dxCreateShader("texreplace.fx", 2, 0, true, "object")
			local tex = dxCreateTexture("textures/"..tostring(path))
			engineApplyShaderToWorldTexture(shader, tostring(name), object)
			dxSetShaderValue(shader, "gTexture", tex)
		end
	end
end
addEvent('artifacts:addTexture', true)
addEventHandler('artifacts:addTexture', root, applyTextureToArtifact)

function applyTexturesToAllArtifacts(textable)
	if textable then
		for k,v in ipairs(textable) do
			applyTextureToArtifact(v[1], v[2])
		end
	end
end
addEvent('artifacts:addAllTextures', true)
addEventHandler('artifacts:addAllTextures', root, applyTexturesToAllArtifacts)