sx,sy,sz = 0,0,3
tx,ty,tz = 0,0,4
fx,fy,fz = 0,1,3

function getMatrixFromPoints(x,y,z,x3,y3,z3,x2,y2,z2)
	x3 = x3-x
	y3 = y3-y
	z3 = z3-z
	x2 = x2-x
	y2 = y2-y
	z2 = z2-z
	local x1 = y2*z3-z2*y3
	local y1 = z2*x3-x2*z3
	local z1 = x2*y3-y2*x3
	x2 = y3*z1-z3*y1
	y2 = z3*x1-x3*z1
	z2 = x3*y1-y3*x1
	local len1 = 1/math.sqrt(x1*x1+y1*y1+z1*z1)
	local len2 = 1/math.sqrt(x2*x2+y2*y2+z2*z2)
	local len3 = 1/math.sqrt(x3*x3+y3*y3+z3*z3)
	x1 = x1*len1 y1 = y1*len1 z1 = z1*len1
	x2 = x2*len2 y2 = y2*len2 z2 = z2*len2
	x3 = x3*len3 y3 = y3*len3 z3 = z3*len3
	return x1,y1,z1,x2,y2,z2,x3,y3,z3
end

function getEulerAnglesFromMatrix(x1,y1,z1,x2,y2,z2,x3,y3,z3)
	local nz1,nz2,nz3
	nz3 = math.sqrt(x2*x2+y2*y2)
	nz1 = -x2*z2/nz3
	nz2 = -y2*z2/nz3
	local vx = nz1*x1+nz2*y1+nz3*z1
	local vz = nz1*x3+nz2*y3+nz3*z3
	return math.deg(math.asin(z2)),-math.deg(math.atan2(vx,vz)),-math.deg(math.atan2(x2,y2))
end

function getMatrixFromEulerAngles(x,y,z)
	x,y,z = math.rad(x),math.rad(y),math.rad(z)
	local sinx,cosx,siny,cosy,sinz,cosz = math.sin(x),math.cos(x),math.sin(y),math.cos(y),math.sin(z),math.cos(z)
	return
		cosy*cosz-siny*sinx*sinz,cosy*sinz+siny*sinx*cosz,-siny*cosx,
		-cosx*sinz,cosx*cosz,sinx,
		siny*cosz+cosy*sinx*sinz,siny*sinz-cosy*sinx*cosz,cosy*cosx
end

if not script_serverside then
	function getBoneMatrix(ped,bone)
		local x,y,z,tx,ty,tz,fx,fy,fz
		x,y,z = getPedBonePosition(ped,bone_0[bone])
		if bone == 1 then
			local x6,y6,z6 = getPedBonePosition(ped,6)
			local x7,y7,z7 = getPedBonePosition(ped,7)
			tx,ty,tz = (x6+x7)*0.5,(y6+y7)*0.5,(z6+z7)*0.5
		elseif bone == 3 then
			local x21,y21,z21 = getPedBonePosition(ped,21)
			local x31,y31,z31 = getPedBonePosition(ped,31)
			tx,ty,tz = (x21+x31)*0.5,(y21+y31)*0.5,(z21+z31)*0.5
		else
			tx,ty,tz = getPedBonePosition(ped,bone_t[bone])
		end
		fx,fy,fz = getPedBonePosition(ped,bone_f[bone])
		local xx,xy,xz,yx,yy,yz,zx,zy,zz = getMatrixFromPoints(x,y,z,tx,ty,tz,fx,fy,fz)
		if bone == 1 or bone == 3 then xx,xy,xz,yx,yy,yz = -yx,-yy,-yz,xx,xy,xz end
		return xx,xy,xz,yx,yy,yz,zx,zy,zz
	end
end