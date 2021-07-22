-- Script: artifacts
-- Description: Handles artifacts (things players can wear that are not clothes)
-- Server-Side
-- Created by Exciter for Owl Gaming, 15.05.2014 (DD/MM/YYYY)
-- Thanks to Adams, iG Scripting Team and RPP Scripting Team for their base work.
-- License: BSD

addEvent('artifacts:removeAllOnPlayer', true)
addEvent('artifacts:add', true)
addEvent('artifacts:remove', true)
addEvent('artifacts:toggle', true)
--addEvent('artifacts:update', true)

local root = getRootElement()
local artifacts = {}
local artifactsList = {}
local texturedArtifacts = {}

function removeAllOnPlayer(player) --Remove all artifacts on a given player
	if artifactsList[player] then
		--triggerClientEvent(player, 'artifacts:startChecking', player, false)
		for k,v in pairs(artifactsList[player]) do
			if(isElement(v[2])) then
				destroyElement(v[2])
				artifacts[player][v[1]] = nil
			end
		end
		artifacts[player] = nil
		artifactsList[player] = nil
	end
end
addEventHandler('artifacts:removeAllOnPlayer', root, removeAllOnPlayer)

addCommandHandler("myartifacts", function(player, cmd)
	if artifactsList[player] and #artifactsList[player] > 0 then
		outputChatBox("--",player)
		for k,v in pairs(artifactsList[player]) do
			outputChatBox(tostring(v[1]),player)
		end
		outputChatBox(tostring(#artifactsList[player]).." items worn.",player)
		outputChatBox("--",player)
	else
		outputChatBox("You are not wearing any artifacts.",player)
	end
end)

function addArtifact(player, artifact, noOutput, customItemTexture) --Start to wear an artifact the player is not already wearing
	if client and player ~= client then return end -- SECURITY FIX: If client sends this event, only allow them to send the artifact for themselves.
	if player and artifact then	
		if artifacts[player] and artifacts[player][artifact] then
			--outputDebugString("artifacts/s_artifacts.lua: Player "..tostring(getPlayerName(player)).." is already wearing "..tostring(artifact)..".")
			return
		else
			--get artifact data
			local data = g_artifacts[artifact]
			local skin = getElementModel(player)
			--local skinSpecifics = getSkinSpecificArtifactData(artifact, skin)
			--if skinSpecifics then
			--	data = skinSpecifics
			--end
			if(g_skinSpecifics[artifact]) then
				if(g_skinSpecifics[artifact][skin]) then
					data = g_skinSpecifics[artifact][skin]
				end
			end
			local x, y, z = getElementPosition(player)
			--local int = getElementInterior(player)
			--local dim = getElementDimension(player)
			local object = createObject(data[ART_MODEL], x, y, z)
			--setElementInterior(object, int)
			--setElementDimension(object, dim)
			setObjectScale(object, data[ART_SCALE])
			setElementDoubleSided(object, data[ART_DOUBLESIDED])
			exports.bone_attach:attachElementToBone(object,player,data[ART_BONE],data[ART_X],data[ART_Y],data[ART_Z],data[ART_RX],data[ART_RY],data[ART_RZ])
			--triggerClientEvent(player, 'artifacts:startChecking', player, true)
			if not artifacts[player] then
				artifacts[player] = {}
			end
			if not artifactsList[player] then
				artifactsList[player] = {}
			end
			artifacts[player][artifact] = object
			table.insert(artifactsList[player], {artifact,object})
			--setElementData(player, "artifact.wearing."..tostring(artifact), true)
			if exports.global:isResourceRunning( 'item-texture' ) then
				if data[ART_TEXTURE] then
					--table.insert(texturedArtifacts, {object, data[ART_TEXTURE]})
					--triggerClientEvent("artifacts:addTexture", player, object, data[ART_TEXTURE])
					for k,v in ipairs(data[ART_TEXTURE]) do
						exports["item-texture"]:addTexture(object, v[2], v[1])
					end
				elseif customItemTexture then
					if type(customItemTexture) == "table" then
						for k,v in ipairs(customItemTexture) do
							exports["item-texture"]:addTexture(object, v[2], v[1])
						end					
					end
				end
			end
			
			if not noOutput and g_artifacts_mes[artifact] and g_artifacts_mes[artifact][1] then
				exports.global:sendLocalMeAction(player, tostring(g_artifacts_mes[artifact][1]))
			end
		end
	end
end
addEventHandler('artifacts:add', root, addArtifact)

function removeArtifact(player, artifact, noOutput) --Removing an artifact the player is wearing
	if client and player ~= client then return end -- SECURITY FIX: If client sends this event, only allow them to send the artifact for themselves.
	if player and artifact then	
		if not artifacts[player] or not artifacts[player][artifact] then
			--outputDebugString("artifacts/s_artifacts.lua: Player "..tostring(getPlayerName(player)).." is not wearing "..tostring(artifact)..".")
			return
		else
			--if(#artifacts[player] <= 1) then --stop the int/dim checking when there is no need for it anymore (when player is not wearing any artifacts)
				--triggerClientEvent(player, 'artifacts:startChecking', player, false)
			--end
			destroyElement(artifacts[player][artifact])
			artifacts[player][artifact] = nil
			for k,v in pairs(artifactsList[player]) do
				if(v[1] == artifact) then
					v = nil
					artifactsList[player][k] = nil
					break
				end
			end
			--setElementData(player, "artifact.wearing."..tostring(artifact), false)
			if not noOutput and g_artifacts_mes[artifact] and g_artifacts_mes[artifact][2] then
				exports.global:sendLocalMeAction(player, tostring(g_artifacts_mes[artifact][2]))
			end
		end
	end
end
addEventHandler('artifacts:remove', root, removeArtifact)

function toggleArtifact(player, artifact, noOutput) --Used for toggling an artifact, independent on current state. This is what you for example want to use from item-system when clicking an item to wear or take off
	if player and artifact then	
		if not artifacts[player] or not artifacts[player][artifact] then
			addArtifact(player, artifact, noOutput)
		else
			removeArtifact(player, artifact, noOutput)
		end
	end
end
addEventHandler('artifacts:toggle', root, toggleArtifact)

--[[addEventHandler('artifacts:update', root,
function(player, newInt, newDim) --This is used by the client-side int/dim change check, to update the int/dim of all attached artifacts when player changes int/dim
	if artifacts[player] then
		for k,v in pairs(artifacts[player]) do
			if(isElement(v)) then
				setElementInterior(v, newInt)
				setElementDimension(v, newDim)
			end
		end
		--artifacts[player] = nil
	end
end)]]

--When to remove all objects from a player:
addEventHandler("onPlayerQuit", root,
function()
	removeAllOnPlayer(source)
end)
--[[ This was replaced with an actual working trigger from account-system/s_characters.lua
addEventHandler("accounts:characters:change", root, removeAllOnPlayer)
--]]

addCommandHandler("removeartifacts", function(player, cmd)
	local num = #artifactsList[player]
	removeAllOnPlayer(player)
	outputChatBox(tostring(num).." artifacts removed.",player)
end)

function countPlayerArtifacts(player) --returns a number of how many artifacts the player is currently wearing
	local count = 0
	if artifacts[player] then
		for k,v in pairs(artifacts[player]) do
			if(isElement(v)) then
				count = count + 1
			end
		end
	end
	return count
end
function getPlayerArtifacts(player, withElements) --returns a table of all articrafts the player is wearing (table contains the IDs of the artifacts worn as strings, ref. g_artifacts list)
	local resultTable = {}
	local tableWithElements = {}
	if artifacts[player] then
		for k,v in pairs(artifacts[player]) do
			if(isElement(v)) then
				table.insert(resultTable, k)
				table.insert(tableWithElements, {v,k})
			end
		end
	end
	if withElements then
		return tableWithElements
	end
	return resultTable
end
function isPlayerWearingArtifact(player, artifact) --returns boolean wether player is wearing the specified artifact or not (may be useful as an exported function)
	if artifacts[player] and artifacts[player][artifact] and isElement(artifacts[player][artifact]) then
		return true
	end
	return false
end
function setPlayerArtifactProperty(player, artifact, property, value) --exported function to let other scripts change things about a worn artifact (adjust position, change model, change bone, etc.)
	if artifacts[player] and artifacts[player][artifact] and isElement(artifacts[player][artifact]) then
		local object = artifacts[player][artifact]
		if(property == "model") then
			local result = setElementModel(object, value)
			return result
		elseif(property == "scale") then
			local result = setObjectScale(object, value)
			return result
		elseif(property == "alpha") then
			local result = setElementAlpha(object, value)
			return result
		elseif(property == "doublesided") then
			local result = setElementDoubleSided(object, value)
			return result
		elseif(property == "texture") then
			if value then
				table.insert(texturedArtifacts, {object, value})
				triggerClientEvent("artifacts:addTexture", player, object, value)
				return true
			else
				return false
			end
		elseif(property == "bone") then
			local ped, bone, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object)
			exports.bone_attach:detachElementFromBone(object)
			local result = exports.bone_attach:attachElementToBone(object,ped,value,x,y,z,rx,ry,rz)
			if not result then
				exports.bone_attach:attachElementToBone(object,ped,bone,x,y,z,rx,ry,rz)
			end
			return result
		elseif(property == "x") then
			local ped, bone, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object)
			exports.bone_attach:detachElementFromBone(object)
			local result = exports.bone_attach:attachElementToBone(object,ped,bone,(x+value),y,z,rx,ry,rz)
			if not result then
				exports.bone_attach:attachElementToBone(object,ped,bone,x,y,z,rx,ry,rz)
			end
			return result
		elseif(property == "y") then
			local ped, bone, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object)
			exports.bone_attach:detachElementFromBone(object)
			local result = exports.bone_attach:attachElementToBone(object,ped,bone,x,(y+value),z,rx,ry,rz)
			if not result then
				exports.bone_attach:attachElementToBone(object,ped,bone,x,y,z,rx,ry,rz)
			end
			return result
		elseif(property == "z") then
			local ped, bone, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object)
			exports.bone_attach:detachElementFromBone(object)
			local result = exports.bone_attach:attachElementToBone(object,ped,bone,x,y,(z+value),rx,ry,rz)
			if not result then
				exports.bone_attach:attachElementToBone(object,ped,bone,x,y,z,rx,ry,rz)
			end
			return result
		elseif(property == "rx") then
			local ped, bone, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object)
			exports.bone_attach:detachElementFromBone(object)
			local result = exports.bone_attach:attachElementToBone(object,ped,bone,x,y,z,(rx+value),ry,rz)
			if not result then
				exports.bone_attach:attachElementToBone(object,ped,bone,x,y,z,rx,ry,rz)
			end
			return result
		elseif(property == "ry") then
			local ped, bone, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object)
			exports.bone_attach:detachElementFromBone(object)
			local result = exports.bone_attach:attachElementToBone(object,ped,bone,x,y,z,rx,(ry+value),rz)
			if not result then
				exports.bone_attach:attachElementToBone(object,ped,bone,x,y,z,rx,ry,rz)
			end
			return result
		elseif(property == "rz") then
			local ped, bone, x, y, z, rx, ry, rz = exports.bone_attach:getElementBoneAttachmentDetails(object)
			exports.bone_attach:detachElementFromBone(object)
			local result = exports.bone_attach:attachElementToBone(object,ped,bone,x,y,z,rx,ry,(rz+value))
			if not result then
				exports.bone_attach:attachElementToBone(object,ped,bone,x,y,z,rx,ry,rz)
			end
			return result
		elseif(property == "reset") then
			removeArtifact(player, artifact, true)
			addArtifact(player, artifact, true)
		end
	end
	return false
end

--[[ TODO:
- Add support for limiting how many artifacts you can wear, for example limiting to 1 artifact per bone at a time
--]]