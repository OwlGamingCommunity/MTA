TAG_VISIBILITY_DISTANCE_MULT = 50

function initSpraying()
	empty_tex = dxCreateTexture(0,0)
	tag_root = getElementByID("drawtag:tags")
	all_tags = {}
	visible_tags = {}
	initTagPosData()
	initExistingTags()
	tag_stream_thread = coroutine.create(streamTags)
	addEventHandler("onClientElementDataChange",tag_root,updateTagData)
	addEventHandler("onClientElementDestroy",tag_root,clearTagData)
	addEventHandler("onClientPreRender",root,renderTags)
	addEventHandler("onClientPlayerWeaponFire",root,playerSpraying)
end

function initExistingTags()
	local tags = getElementChildren(tag_root)
	for tagnum,tag in ipairs(tags) do
		if getElementData(tag,"visible") then
			pushTagOnSpray(tag,getElementData(tag,"visibility")-1)
			all_tags[tag] = true
		end
	end
end

function getTagCenterPosition(tag)
	return getElementData(tag,"x"),getElementData(tag,"y"),getElementData(tag,"z")
end

function setTagCenterPosition(tag,x,y,z)
	setElementData(tag,"x",x)
	setElementData(tag,"y",y)
	setElementData(tag,"z",z)
end

function createTagTexture(tag)
	local tex = getElementData(tag,"texture")
	if tex then return end
	local pngdata = getElementData(tag,"pngdata")
	if not pngdata then return end
	tex = dxCreateTexture(pngdata,"dxt1",false,"clamp")
	setElementData(tag,"texture",tex,false)
end

function destroyTagTexture(tag)
	local tex = getElementData(tag,"texture")
	if not tex then return end
	destroyElement(tex)
	setElementData(tag,"texture",false,false)
end

function updateTagTexture(tag)
	destroyTagTexture(tag)
	createTagTexture(tag)
end

function updateTagData(dataname,oldval)
	if dataname == "visible" then
		all_tags[source] = true
		local att = getElementData(source,"attached")
		if att then
			if isElementStreamedIn(att) then
				streamInTag(source)
			end
		else
			local cx,cy,cz = getCameraMatrix()
			local x,y,z = getTagCenterPosition(source)
			x,y,z = x-cx,y-cy,z-cz
			local tagvisdist = getElementData(source,"size")*TAG_VISIBILITY_DISTANCE_MULT
			if x*x+y*y+z*z < tagvisdist*tagvisdist then
				streamInTag(source)
			end
		end
		pushTagOnSpray(source,getElementData(source,"visibility"))
	elseif dataname == "visibility" and oldval then
		pushTagOnSpray(source,getElementData(source,"visibility")-oldval)
	elseif dataname == "pngdata" then
		if source == getElementData(localPlayer,"drawtag:tag") then
			updateTagTexture(source)
		end
	end
end

function pushTagOnSpray(tag,off)
	local nx,ny,nz = getElementData(tag,"nx"),getElementData(tag,"ny"),getElementData(tag,"nz")
	local nlen = 0.0005/math.sqrt(nx*nx+ny*ny+nz*nz)*off
	nx,ny,nz = nx*nlen,ny*nlen,nz*nlen
	local x1,y1,z1 = getElementData(tag,"x1"),getElementData(tag,"y1"),getElementData(tag,"z1")
	local x2,y2,z2 = getElementData(tag,"x2"),getElementData(tag,"y2"),getElementData(tag,"z2")
	x1,y1,z1,x2,y2,z2 = x1+nx,y1+ny,z1+nz,x2+nx,y2+ny,z2+nz
	setElementData(tag,"x1",x1,false)
	setElementData(tag,"y1",y1,false)
	setElementData(tag,"z1",z1,false)
	setElementData(tag,"x2",x2,false)
	setElementData(tag,"y2",y2,false)
	setElementData(tag,"z2",z2,false)
end

function clearTagData()
	all_tags[source] = nil
	streamOutTag(source)
end

function renderTags()
	coroutine.resume(tag_stream_thread)
	do
		local x,y,z = getElementPosition(localPlayer)
		dxDrawMaterialLine3D(x,y,z,x,y,z,empty_tex,0,0,0,0,0)
	end
	for tag,visible in pairs(visible_tags) do
		local x1,y1,z1 = getElementData(tag,"x1"),getElementData(tag,"y1"),getElementData(tag,"z1")
		local x2,y2,z2 = getElementData(tag,"x2"),getElementData(tag,"y2"),getElementData(tag,"z2")
		local nx,ny,nz = getElementData(tag,"nx"),getElementData(tag,"ny"),getElementData(tag,"nz")
		local size = getElementData(tag,"size")
		local att = getElementData(tag,"attached")
		if att then
			local m = getElementMatrix(att)
			x1,y1,z1 = 
				x1*m[1][1]+y1*m[2][1]+z1*m[3][1]+m[4][1],
				x1*m[1][2]+y1*m[2][2]+z1*m[3][2]+m[4][2],
				x1*m[1][3]+y1*m[2][3]+z1*m[3][3]+m[4][3]
			x2,y2,z2 = 
				x2*m[1][1]+y2*m[2][1]+z2*m[3][1]+m[4][1],
				x2*m[1][2]+y2*m[2][2]+z2*m[3][2]+m[4][2],
				x2*m[1][3]+y2*m[2][3]+z2*m[3][3]+m[4][3]
			nx,ny,nz = 
				nx*m[1][1]+ny*m[2][1]+nz*m[3][1],
				nx*m[1][2]+ny*m[2][2]+nz*m[3][2],
				nx*m[1][3]+ny*m[2][3]+nz*m[3][3]
		end
		local tex = getElementData(tag,"texture")
		dxDrawMaterialLine3D(x1,y1,z1,x2,y2,z2,tex,size,tocolor(255,255,255,128),x1+nx,y1+ny,z1+nz)
	end
end

function streamTags()
	while true do
		local updated = 0
		local cx,cy,cz = getCameraMatrix()
		for tag,exists in pairs(all_tags) do
			local att = getElementData(tag,"attached")
			if att then
				local streamedin = isElementStreamedIn(att)
				if visible_tags[tag] then
					if not streamedin then streamOutTag(tag) end
				else
					if streamedin then streamInTag(tag) end
				end
			else
				local x,y,z = getTagCenterPosition(tag)
				x,y,z = x-cx,y-cy,z-cz
				local dist = x*x+y*y+z*z
				local tagvisdist = getElementData(tag,"size")*TAG_VISIBILITY_DISTANCE_MULT
				if visible_tags[tag] then
					if dist > tagvisdist*tagvisdist then streamOutTag(tag) end
				else
					if dist <= tagvisdist*tagvisdist then streamInTag(tag) end
				end
				updated = updated+1
				if updated == 64 then
					coroutine.yield()
					updated = 0
					cx,cy,cz = getCameraMatrix()
				end
			end
		end
		coroutine.yield()
	end
end

function streamInTag(tag)
	createTagTexture(tag)
	if visible_tags[tag] then return end
	visible_tags[tag] = true
	addTagToPosList(tag)
end

function streamOutTag(tag)
	destroyTagTexture(tag)
	if not visible_tags[tag] then return end
	visible_tags[tag] = nil
	removeTagFromPosList(tag)
end

function sprayNewTag(att,x,y,z,x1,y1,z1,x2,y2,z2,nx,ny,nz,size)
	local tag = getElementData(localPlayer,"drawtag:tag")
	if not tag then return end
	if not getElementData(tag,"pngdata") then return end

	if att then
		setElementData(tag,"attached",att)
		local attlist = getElementData(att,"drawtag:attached") or {n = 0}
		attlist[tag] = true
		attlist.n = attlist.n+1
		setElementData(att,"drawtag:attached",attlist)
	end

	setTagCenterPosition(tag,x,y,z)
	setElementData(tag,"x1",x1)
	setElementData(tag,"y1",y1)
	setElementData(tag,"z1",z1)
	setElementData(tag,"x2",x2)
	setElementData(tag,"y2",y2)
	setElementData(tag,"z2",z2)
	setElementData(tag,"nx",nx)
	setElementData(tag,"ny",ny)
	setElementData(tag,"nz",nz)
	setElementData(tag,"size",size)
	setElementData(tag,"visibility",1)
	setElementData(tag,"visible",true)
	setElementData(localPlayer,"drawtag:tag",false)
end

function playerSpraying(weapon,ammo,inclip,hitx,hity,hitz,hitel)
	if weapon ~= 41 then return end
	local spraymode = getElementData(source,"drawtag:spraymode")
	if not spraymode then return end
	local mx,my,mz = getPedBonePosition(source,23)
	hitx,hity,hitz = hitx-mx,hity-my,hitz-mz
	local hdist = 2/math.sqrt(hitx*hitx+hity*hity+hitz*hitz)
	hitx,hity,hitz = hitx*hdist,hity*hdist,hitz*hdist
	local wall,x0,y0,z0,hitel,zx,zy,zz = processLineOfSight(mx,my,mz,mx+hitx,my+hity,mz+hitz,true,true,false,true,false,false,false,false)
	if not wall then return end
	local spraymode_draw = spraymode == "draw"
	local tag = getNearestTag(hitel,spraymode_draw and getElementData(source,"drawtag:size") or 0,x0,y0,z0)
	if tag then
		local visibility = getElementData(tag,"visibility")
		do
			local radius = getElementData(tag,"size")*0.5+0.5
			local tx,ty,tz = getTagCenterPosition(tag)
			local att = getElementData(tag,"attached")
			if att then
				local m = getElementMatrix(att)
				tx,ty,tz =
					tx*m[1][1]+ty*m[2][1]+tz*m[3][1]+m[4][1],
					tx*m[1][2]+ty*m[2][2]+tz*m[3][2]+m[4][2],
					tx*m[1][3]+ty*m[2][3]+tz*m[3][3]+m[4][3]
			end
			tx,ty,tz = tx-x0,ty-y0,tz-z0
			if tx*tx+ty*ty+tz*tz > radius*radius then return end
		end
		if visibility == 90 and spraymode_draw then return end
		visibility = spraymode_draw and visibility+1 or visibility-1
		local sync = source == localPlayer and visibility%10 == 0
		setElementData(tag,"visibility",visibility,sync)
	elseif source == localPlayer and spraymode_draw then
		local size = getElementData(source,"drawtag:size")
		if not size then return end
		local xx,xy,xz
		local yx,yy,yz
		if hitel and getElementType(hitel) == "vehicle" then
			do
				local w,h = guiGetScreenSize()
				w,h = w*0.5,h*0.5
				local x1,y1,z1 = getWorldFromScreenPosition(w,h,1)
				xx,xy,xz = getWorldFromScreenPosition(w+w,h,1)
				yx,yy,yz = getWorldFromScreenPosition(w,0,1)
				xx,xy,xz = xx-x1,xy-y1,xz-z1
				yx,yy,yz = yx-x1,yy-y1,yz-z1
			end
			local xlen = size*0.5/math.sqrt(xx*xx+xy*xy+xz*xz)
			local ylen = size*0.5/math.sqrt(yx*yx+yy*yy+yz*yz)
			xx,xy,xz = xx*xlen,xy*xlen,xz*xlen
			yx,yy,yz = yx*ylen,yy*ylen,yz*ylen

			local precision = 0.5
			local count = (2/precision+1)

			x0,y0,z0 = 0,0,0
			local tag_xx,tag_xy,tag_xz = {},{},{}
			local tag_yx,tag_yy,tag_yz = {},{},{}
			for yoff = -1,1,precision do
				local syx = mx+yx*yoff
				local syy = my+yy*yoff
				local syz = mz+yz*yoff
				for xoff = -1,1,precision do
					local sx = syx+xx*xoff
					local sy = syy+xy*xoff
					local sz = syz+xz*xoff
					local col,cx,cy,cz,hit = processLineOfSight(sx,sy,sz,sx+hitx,sy+hity,sz+hitz,true,true,false,true,false,false,false,false) if not col or hit ~= hitel then return end
					tag_xx[xoff] = (tag_xx[xoff] or 0)+cx
					tag_xy[xoff] = (tag_xy[xoff] or 0)+cy
					tag_xz[xoff] = (tag_xz[xoff] or 0)+cz
					tag_yx[yoff] = (tag_yx[yoff] or 0)+cx
					tag_yy[yoff] = (tag_yy[yoff] or 0)+cy
					tag_yz[yoff] = (tag_yz[yoff] or 0)+cz
					x0,y0,z0 = x0+cx,y0+cy,z0+cz
				end
			end
			local average = 1/(count*count)
			x0,y0,z0 = x0*average,y0*average,z0*average
			
			xx,xy,xz,yx,yy,yz = 0,0,0,0,0,0
			local mult = 1-count
			for off = -1,1,precision do
				xx = xx+tag_xx[off]*mult
				xy = xy+tag_xy[off]*mult
				xz = xz+tag_xz[off]*mult
				yx = yx+tag_yx[off]*mult
				yy = yy+tag_yy[off]*mult
				yz = yz+tag_yz[off]*mult
				mult = mult+2
			end

			zx,zy,zz = xy*yz-xz*yy,xz*yx-xx*yz,xx*yy-xy*yx
			local xlen = size*0.5/math.sqrt(xx*xx+xy*xy+xz*xz)
			local ylen = size*0.5/math.sqrt(yx*yx+yy*yy+yz*yz)
			xx,xy,xz = xx*xlen,xy*xlen,xz*xlen
			yx,yy,yz = yx*ylen,yy*ylen,yz*ylen
		else
			do
				local w,h = guiGetScreenSize()
				w,h = w*0.5,h*0.5
				local x1,y1,z1 = getWorldFromScreenPosition(w,h,1)
				local cux,cuy,cuz = getWorldFromScreenPosition(w,0,1)
				cux,cuy,cuz = cux-x1,cuy-y1,cuz-z1
				xx,xy,xz = zy*cuz-zz*cuy,zz*cux-zx*cuz,zx*cuy-zy*cux
				yx,yy,yz = xy*zz-xz*zy,xz*zx-xx*zz,xx*zy-xy*zx
			end
			local xlen = size*0.5/math.sqrt(xx*xx+xy*xy+xz*xz)
			local ylen = size*0.5/math.sqrt(yx*yx+yy*yy+yz*yz)
			xx,xy,xz = xx*xlen,xy*xlen,xz*xlen
			yx,yy,yz = yx*ylen,yy*ylen,yz*ylen

			local cx,cy,cz = x0+zx,y0+zy,z0+zz
			local bx,by,bz = x0-zx*0.01,y0-zy*0.01,z0-zz*0.01
			local col,x,y,z,hit
			col,x,y,z,hit = processLineOfSight(cx,cy,cz,bx+xx+yx,by+xy+yy,bz+xz+yz,true,true,false,true,false,false,false,false) if not col or hit ~= hitel then return end
			col,x,y,z,hit = processLineOfSight(cx,cy,cz,bx+xx-yx,by+xy-yy,bz+xz-yz,true,true,false,true,false,false,false,false) if not col or hit ~= hitel then return end
			col,x,y,z,hit = processLineOfSight(cx,cy,cz,bx-xx+yx,by-xy+yy,bz-xz+yz,true,true,false,true,false,false,false,false) if not col or hit ~= hitel then return end
			col,x,y,z,hit = processLineOfSight(cx,cy,cz,bx-xx-yx,by-xy-yy,bz-xz-yz,true,true,false,true,false,false,false,false) if not col or hit ~= hitel then return end
			local fx,fy,fz = x0+zx*0.01,y0+zy*0.01,z0+zz*0.01
			if not isLineOfSightClear(cx,cy,cz,fx+xx+yx,fy+xy+yy,fz+xz+yz,true,true,false,true,false,true,false) then return end
			if not isLineOfSightClear(cx,cy,cz,fx+xx-yx,fy+xy-yy,fz+xz-yz,true,true,false,true,false,true,false) then return end
			if not isLineOfSightClear(cx,cy,cz,fx-xx+yx,fy-xy+yy,fz-xz+yz,true,true,false,true,false,true,false) then return end
			if not isLineOfSightClear(cx,cy,cz,fx-xx-yx,fy-xy-yy,fz-xz-yz,true,true,false,true,false,true,false) then return end
		end
		local zlen = 1/math.sqrt(zx*zx+zy*zy+zz*zz)
		zx,zy,zz,zlen = zx*zlen,zy*zlen,zz*zlen,1

		local off1 = -zlen*0.005
		local off2 = -zlen*0.035
		local x1,y1,z1 = x0+zx*off1+yx,y0+zy*off1+yy,z0+zz*off1+yz
		local x2,y2,z2 = x0+zx*off2-yx,y0+zy*off2-yy,z0+zz*off2-yz
		if hitel then
			local m = getElementMatrix(hitel)
			x0,y0,z0 = x0-m[4][1],y0-m[4][2],z0-m[4][3]
			x1,y1,z1 = x1-m[4][1],y1-m[4][2],z1-m[4][3]
			x2,y2,z2 = x2-m[4][1],y2-m[4][2],z2-m[4][3]
			x0,y0,z0 =
				x0*m[1][1]+y0*m[1][2]+z0*m[1][3],
				x0*m[2][1]+y0*m[2][2]+z0*m[2][3],
				x0*m[3][1]+y0*m[3][2]+z0*m[3][3]
			x1,y1,z1 =
				x1*m[1][1]+y1*m[1][2]+z1*m[1][3],
				x1*m[2][1]+y1*m[2][2]+z1*m[2][3],
				x1*m[3][1]+y1*m[3][2]+z1*m[3][3]
			x2,y2,z2 =
				x2*m[1][1]+y2*m[1][2]+z2*m[1][3],
				x2*m[2][1]+y2*m[2][2]+z2*m[2][3],
				x2*m[3][1]+y2*m[3][2]+z2*m[3][3]
			zx,zy,zz =
				zx*m[1][1]+zy*m[1][2]+zz*m[1][3],
				zx*m[2][1]+zy*m[2][2]+zz*m[2][3],
				zx*m[3][1]+zy*m[3][2]+zz*m[3][3]
		end
		sprayNewTag(hitel,x0,y0,z0,x1,y1,z1,x2,y2,z2,zx,zy,zz,size)
	end
end

----------------------------------------

function initTagPosData()
	tag_pos_list = {}
end

function addTagToPosList(tag)
	local att = getElementData(tag,"attached")
	if att then
		if not tag_pos_list[att] then
			tag_pos_list[att] = {n = 0}
		end
		if not tag_pos_list[att][tag] then
			tag_pos_list[att].n = tag_pos_list[att].n+1
			tag_pos_list[att][tag] = true
		end
		return
	end
	local x,y,z = getTagCenterPosition(tag)
	local size = getElementData(tag,"size")
	local x1,y1,z1 = math.floor((x-size)*0.1),math.floor((y-size)*0.1),math.floor((z-size)*0.1)
	local x2,y2,z2 = math.floor((x+size)*0.1),math.floor((y+size)*0.1),math.floor((z+size)*0.1)
	for x = x1,x2 do for y = y1,y2 do for z = z1,z2 do
		if not tag_pos_list[z] then
			tag_pos_list[z] = {n = 0}
		end
		if not tag_pos_list[z][y] then
			tag_pos_list[z].n = tag_pos_list[z].n+1
			tag_pos_list[z][y] = {n = 0}
		end
		if not tag_pos_list[z][y][x] then
			tag_pos_list[z][y].n = tag_pos_list[z][y].n+1
			tag_pos_list[z][y][x] = {n = 0}
		end
		if not tag_pos_list[z][y][x][tag] then
			tag_pos_list[z][y][x].n = tag_pos_list[z][y][x].n+1
			tag_pos_list[z][y][x][tag] = true
		end
	end end end
end

function removeTagFromPosList(tag)
	if not getElementData(tag,"visible") then return end
	local att = getElementData(tag,"attached")
	if att then
		if not tag_pos_list[att] then return end
		if tag_pos_list[att][tag] then
			tag_pos_list[att].n = tag_pos_list[att].n-1
			tag_pos_list[att][tag] = nil
			if tag_pos_list[att].n == 0 then
				tag_pos_list[att] = nil
			end
		end
		return
	end
	local x,y,z = getTagCenterPosition(tag)
	local size = getElementData(tag,"size")
	local x1,y1,z1 = math.floor((x-size)*0.1),math.floor((y-size)*0.1),math.floor((z-size)*0.1)
	local x2,y2,z2 = math.floor((x+size)*0.1),math.floor((y+size)*0.1),math.floor((z+size)*0.1)
	for x = x1,x2 do for y = y1,y2 do for z = z1,z2 do
		if tag_pos_list[z][y][x][tag] then
			tag_pos_list[z][y][x][tag] = nil
			tag_pos_list[z][y][x].n = tag_pos_list[z][y][x].n-1
			if tag_pos_list[z][y][x].n == 0 then
				tag_pos_list[z][y][x] = nil
				tag_pos_list[z][y].n = tag_pos_list[z][y].n-1
				if tag_pos_list[z][y].n == 0 then
					tag_pos_list[z][y] = nil
					tag_pos_list[z].n = tag_pos_list[z].n-1
					if tag_pos_list[z].n == 0 then
						tag_pos_list[z] = nil
					end
				end
			end
		end
	end end end
end

function getNearestTag(att,radius,x,y,z)
	local nearest_dist,nearest_tag = 1
	if att then
		local m = getElementMatrix(att)
		x,y,z = x-m[4][1],y-m[4][2],z-m[4][3]
		x,y,z =
			x*m[1][1]+y*m[1][2]+z*m[1][3],
			x*m[2][1]+y*m[2][2]+z*m[2][3],
			x*m[3][1]+y*m[3][2]+z*m[3][3]
		local maxdist = getElementType(att) == "vehicle" and 0.5 or 0.01
		local attached = tag_pos_list[att]
		if not attached then return end
		for tag,exists in pairs(attached) do
			if tag ~= "n" then
				local tx,ty,tz = getTagCenterPosition(tag)
				local nx,ny,nz = getElementData(tag,"nx"),getElementData(tag,"ny"),getElementData(tag,"nz")
				tx,ty,tz = tx-x,ty-y,tz-z
				if math.abs(tx*nx+ty*ny+tz*nz) < maxdist then
					local tagdist = (getElementData(tag,"size")+radius)*0.5
					local this_dist = (tx*tx+ty*ty+tz*tz)/(tagdist*tagdist)
					if this_dist < nearest_dist then
						nearest_tag = tag
						nearest_dist = this_dist
					end
				end
			end
		end
	else
		local cx,cy,cz = math.floor(x*0.1),math.floor(y*0.1),math.floor(z*0.1)
		for oz = -1,1 do
			local plane = tag_pos_list[cz+oz]
			if plane then
				for oy = -1,1 do
					local line = plane[cy+oy]
					if line then
						for ox = -1,1 do
							local cube = line[cx+ox]
							if cube then
								for tag,exists in pairs(cube) do
									if tag ~= "n" then
										local tx,ty,tz = getTagCenterPosition(tag)
										local nx,ny,nz = getElementData(tag,"nx"),getElementData(tag,"ny"),getElementData(tag,"nz")
										tx,ty,tz = tx-x,ty-y,tz-z
										if math.abs(tx*nx+ty*ny+tz*nz) < 0.01 then
											local tagdist = (getElementData(tag,"size")+radius)*0.5
											local this_dist = (tx*tx+ty*ty+tz*tz)/(tagdist*tagdist)
											if this_dist < nearest_dist then
												nearest_tag = tag
												nearest_dist = this_dist
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return nearest_tag
end

----------------------------------

function getPlayerSprayMode(player)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	return getElementData(player,"drawtag:spraymode") or "none"
end

function getPlayerTagSize(player)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	return getElementData(player,"drawtag:size")
end

function getAllTags()
	local tagnum = 1
	local tags = {}
	for tag,exists in pairs(all_tags) do
		tags[tagnum] = tag
		tagnum = tagnum+1
	end
	return tags
end

function getTagAttachedElement(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	return getElementData(tag,"attached")
end

function getTagPosition(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	return getElementData(tag,"x"),getElementData(tag,"y"),getElementData(tag,"z")
end

function getTagNormal(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	return getElementData(tag,"nx"),getElementData(tag,"ny"),getElementData(tag,"nz")
end

function getTagSize(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	return getElementData(tag,"size")
end

function getTagTexture(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	return getElementData(tag,"pngdata")
end

