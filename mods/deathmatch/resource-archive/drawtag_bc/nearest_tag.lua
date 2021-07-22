function getNearestTag(x,y,z)
	local nearest_dist,nearest_tag = 3
	local all_tags = exports.drawtag:getAllTags()
	for tagnum,tag in ipairs(all_tags) do
		local tx,ty,tz = exports.drawtag:getTagPosition(tag)
		local nx,ny,nz = exports.drawtag:getTagNormal(tag)
		local att = exports.drawtag:getTagAttachedElement(tag)
		if not att or isElementStreamedIn(att) then
			if att then
				local m = getElementMatrix(att)
				tx,ty,tz =
					tx*m[1][1]+ty*m[2][1]+tz*m[3][1]+m[4][1],
					tx*m[1][2]+ty*m[2][2]+tz*m[3][2]+m[4][2],
					tx*m[1][3]+ty*m[2][3]+tz*m[3][3]+m[4][3]
				nx,ny,nz =
					nx*m[1][1]+ny*m[2][1]+nz*m[3][1],
					nx*m[1][2]+ny*m[2][2]+nz*m[3][2],
					nx*m[1][3]+ny*m[2][3]+nz*m[3][3]
			end
			local size = exports.drawtag:getTagSize(tag)*0.5+1
			tx,ty,tz = tx-x,ty-y,tz-z
			local dist_to_plane = -(tx*nx+ty*ny+tz*nz)
			local dist_to_center = tx*tx+ty*ty+tz*tz-dist_to_plane*dist_to_plane
			if dist_to_plane >= 0 and dist_to_plane <= nearest_dist and dist_to_center <= size*size then
				nearest_dist = dist_to_plane
				nearest_tag = tag
			end
		end
	end
	return nearest_tag
end

