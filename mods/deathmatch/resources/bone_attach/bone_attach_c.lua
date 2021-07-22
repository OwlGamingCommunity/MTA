function sendReadyMessage()
	triggerServerEvent("boneAttach_requestAttachmentData",root)
end
addEventHandler("onClientResourceStart",resourceRoot,sendReadyMessage)

function getAttachmentData(ped,bone,x,y,z,rx,ry,rz)
	for element,att_ped in pairs(ped) do
		setElementCollisionsEnabled(element,false)
		attached_ped[element] = att_ped
		attached_bone[element] = bone[element]
		attached_x[element] = x[element]
		attached_y[element] = y[element]
		attached_z[element] = z[element]
		attached_rx[element] = rx[element]
		attached_ry[element] = ry[element]
		attached_rz[element] = rz[element]
	end
end
addEvent("boneAttach_sendAttachmentData",true)
addEventHandler("boneAttach_sendAttachmentData",root,getAttachmentData)

function initAttach()
	addEvent("boneAttach_attach",true)
	addEvent("boneAttach_detach",true)
	addEventHandler("boneAttach_attach",root,attachElementToBone)
	addEventHandler("boneAttach_detach",root,detachElementFromBone)
end
addEventHandler("onClientResourceStart",resourceRoot,initAttach)

bone_0,bone_t,bone_f = {},{},{}
bone_0[1],bone_t[1],bone_f[1] = 5,nil,6 --head
bone_0[2],bone_t[2],bone_f[2] = 4,5,8 --neck
bone_0[3],bone_t[3],bone_f[3] = 3,nil,31 --spine
bone_0[4],bone_t[4],bone_f[4] = 1,2,3 --pelvis
bone_0[5],bone_t[5],bone_f[5] = 4,32,5 --left clavicle
bone_0[6],bone_t[6],bone_f[6] = 4,22,5 --right clavicle
bone_0[7],bone_t[7],bone_f[7] = 32,33,34 --left shoulder
bone_0[8],bone_t[8],bone_f[8] = 22,23,24 --right shoulder
bone_0[9],bone_t[9],bone_f[9] = 33,34,32 --left elbow
bone_0[10],bone_t[10],bone_f[10] = 23,24,22 --right elbow
bone_0[11],bone_t[11],bone_f[11] = 34,35,36 --left hand
bone_0[12],bone_t[12],bone_f[12] = 24,25,26 --right hand
bone_0[13],bone_t[13],bone_f[13] = 41,42,43 --left hip
bone_0[14],bone_t[14],bone_f[14] = 51,52,53 --right hip
bone_0[15],bone_t[15],bone_f[15] = 42,43,44 --left knee
bone_0[16],bone_t[16],bone_f[16] = 52,53,54 --right knee
bone_0[17],bone_t[17],bone_f[17] = 43,42,44 --left ankle
bone_0[18],bone_t[18],bone_f[18] = 53,52,54 --right angle
bone_0[19],bone_t[19],bone_f[19] = 44,43,42 --left foot
bone_0[20],bone_t[20],bone_f[20] = 54,53,52 --right foot

local function matchAlphas(ped, eld)
	local ped_alpha = getElementAlpha(ped) -- Objects are fully transparent at 140.
	local elm_alpha = getElementAlpha(eld)
	if ped_alpha ~= elm_alpha then
		return setElementAlpha(eld, ped_alpha)
	end
end

function putAttachedElementsOnBones()
	for element,ped in pairs(attached_ped) do
		if ped then
			if isElement(ped) and isElement(element) then
				if isElementStreamedIn(ped) then
					local bone = attached_bone[element]
					local x,y,z = getPedBonePosition(ped,bone_0[bone])
					local xx,xy,xz,yx,yy,yz,zx,zy,zz = getBoneMatrix(ped,bone)
					local offx,offy,offz = attached_x[element],attached_y[element],attached_z[element]
					local offrx,offry,offrz = attached_rx[element],attached_ry[element],attached_rz[element]
					local objx = x+offx*xx+offy*yx+offz*zx
					local objy = y+offx*xy+offy*yy+offz*zy
					local objz = z+offx*xz+offy*yz+offz*zz
					local rxx,rxy,rxz,ryx,ryy,ryz,rzx,rzy,rzz = getMatrixFromEulerAngles(offrx,offry,offrz)

					local txx = rxx*xx+rxy*yx+rxz*zx
					local txy = rxx*xy+rxy*yy+rxz*zy
					local txz = rxx*xz+rxy*yz+rxz*zz
					local tyx = ryx*xx+ryy*yx+ryz*zx
					local tyy = ryx*xy+ryy*yy+ryz*zy
					local tyz = ryx*xz+ryy*yz+ryz*zz
					local tzx = rzx*xx+rzy*yx+rzz*zx
					local tzy = rzx*xy+rzy*yy+rzz*zy
					local tzz = rzx*xz+rzy*yz+rzz*zz
					offrx,offry,offrz = getEulerAnglesFromMatrix(txx,txy,txz,tyx,tyy,tyz,tzx,tzy,tzz)

					if (string.find(objx..objy..objz, "a")) then
    					setElementPosition(element, x, y, z)
					else
    					setElementPosition(element, objx, objy, objz)
					end

					if (not string.find(offrx..offry..offrz, "a")) then
    					setElementRotation(element, offrx, offry, offrz, "ZXY")
					end

					local ped_int = getElementInterior(ped)
					if ped_int ~= getElementInterior(element) then
						setElementInterior( element, ped_int )
					end

					local ped_dim = getElementDimension(ped)
					if ped_dim ~= getElementDimension(element) then
						setElementDimension( element, ped_dim )
					end
					matchAlphas(ped, element)
				else
					setElementAlpha(element, 0)
				end
			else
				if element and isElement(element) then
					destroyElement(element)
				end
			end
		else
			if isElement and isElement(isElement) then
				destroyElement(element)
			end
		end
    end
end
addEventHandler("onClientPreRender",root,putAttachedElementsOnBones)