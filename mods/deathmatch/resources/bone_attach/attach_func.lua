attached_ped = {}
attached_bone = {}
attached_x = {}
attached_y = {}
attached_z = {}
attached_rx = {}
attached_ry = {}
attached_rz = {}

function attachElementToBone(element,ped,bone,x,y,z,rx,ry,rz)
	if not (isElement(element) and isElement(ped)) then return false end
	if getElementType(ped) ~= "ped" and getElementType(ped) ~= "player" then return false end
	bone = tonumber(bone)
	if not bone or bone < 1 or bone > 20 then return false end
	x,y,z,rx,ry,rz = tonumber(x) or 0,tonumber(y) or 0,tonumber(z) or 0,tonumber(rx) or 0,tonumber(ry) or 0,tonumber(rz) or 0
	attached_ped[element] = ped
	attached_bone[element] = bone
	attached_x[element] = x
	attached_y[element] = y
	attached_z[element] = z
	attached_rx[element] = rx
	attached_ry[element] = ry
	attached_rz[element] = rz
	if setElementCollisionsEnabled then
		setElementCollisionsEnabled(element,false)
	end
	if script_serverside then
		triggerClientEvent("boneAttach_attach",root,element,ped,bone,x,y,z,rx,ry,rz)
	end
	return true
end

function detachElementFromBone(element)
	if not element then return false end
	if not attached_ped[element] then return false end
	clearAttachmentData(element)
	if setElementCollisionsEnabled then
		setElementCollisionsEnabled(element,true)
	end
	if script_serverside then
		triggerClientEvent("boneAttach_detach",root,element)
	end
	return true
end

function isElementAttachedToBone(element)
	if not element then return false end
	return isElement(attached_ped[element])
end

function getElementBoneAttachmentDetails(element)
	if not isElementAttachedToBone(element) then return false end
	return attached_ped[element],attached_bone[element],
		attached_x[element],attached_y[element],attached_z[element],
		attached_rx[element],attached_ry[element],attached_rz[element]
end

function setElementBonePositionOffset(element,x,y,z)
	local ped,bone,ox,oy,oz,rx,ry,rz = getElementBoneAttachmentDetails(element)
	if not ped then return false end
	return attachElementToBone(element,ped,bone,x,y,z,rx,ry,rz)
end

function setElementBoneRotationOffset(element,rx,ry,rz)
	local ped,bone,x,y,z,ox,oy,oz = getElementBoneAttachmentDetails(element)
	if not ped then return false end
	return attachElementToBone(element,ped,bone,x,y,z,rx,ry,rz)
end

if not script_serverside then
	function getBonePositionAndRotation(ped,bone)
		bone = tonumber(bone)
		if not bone or bone < 1 or bone > 20 then return false end
		if not isElement(ped) then return false end
		if getElementType(ped) ~= "player" and getElementType(ped) ~= "ped" then return false end
		if not isElementStreamedIn(ped) then return false end
		local x,y,z = getPedBonePosition(ped,bone_0[bone])
		local rx,ry,rz = getEulerAnglesFromMatrix(getBoneMatrix(ped,bone))
		return x,y,z,rx,ry,rz
	end
end

------------------------------------

function clearAttachmentData(element)
	attached_ped[element] = nil
	attached_bone[element] = nil
	attached_x[element] = nil
	attached_y[element] = nil
	attached_z[element] = nil
	attached_rx[element] = nil
	attached_ry[element] = nil
	attached_rz[element] = nil
end

function forgetDestroyedElements()
	if not attached_ped[source] then return end
	clearAttachmentData(source)
end
addEventHandler(script_serverside and "onElementDestroy" or "onClientElementDestroy",root,forgetDestroyedElements)

function forgetNonExistingPeds()
	local checkedcount = 0
	while true do
		for element,ped in pairs(attached_ped) do
			if not isElement(ped) then clearAttachmentData(element) end
			checkedcount = checkedcount+1
			if checkedcount >= 1000 then
				coroutine.yield()
				checkedcount = 0
			end
		end
		coroutine.yield()
	end
end
clearing_nonexisting_peds = coroutine.create(forgetNonExistingPeds)
setTimer(function()	if coroutine.status(clearing_nonexisting_peds) ~= 'dead' then coroutine.resume(clearing_nonexisting_peds) end end,1000,0)