function loadTagsFromFile()
	if tags_loaded then return end
	tags_loaded = true
	local tags_file = xmlLoadFile("saved_tags/tags.xml")
	if not tags_file then return end
	local png_file = fileOpen("saved_tags/tags_png.dat",true)
	if not png_file then xmlUnloadFile(tags_file) return end
	local tag_nodes = xmlNodeGetChildren(tags_file)
	for tagnum,tag_node in ipairs(tag_nodes) do
		local tagdata = xmlNodeGetAttributes(tag_node)
		fileSetPos(png_file,tagdata.png_off)
		exports.drawtag:createTagFromExistingData(
			nil,
			tagdata.x,tagdata.y,tagdata.z,
			tagdata.x1,tagdata.y1,tagdata.z1,
			tagdata.x2,tagdata.y2,tagdata.z2,
			tagdata.nx,tagdata.ny,tagdata.nz,
			tagdata.size,
			tagdata.vis,fileRead(png_file,tagdata.png_len)
		)
	end
	fileClose(png_file)
	xmlUnloadFile(tags_file)
end

function saveTagsToFile()
	if not tags_loaded then return end
	tags_loaded = nil
	local tags_file = xmlCreateFile("saved_tags/tags.xml","tags")
	if not tags_file then return end
	local png_file = fileCreate("saved_tags/tags_png.dat")
	if not png_file then xmlUnloadFile(tags_file) return end
	local all_tags = exports.drawtag:getAllTags()
	for tagnum,tag in ipairs(all_tags) do
		local att,x,y,z,x1,y1,z1,x2,y2,z2,nx,ny,nz,size,vis,png = exports.drawtag:getTagData(tag)
		if not att then
			local tag_node = xmlCreateChild(tags_file,"tag")
			xmlNodeSetAttribute(tag_node,"x",x)
			xmlNodeSetAttribute(tag_node,"y",y)
			xmlNodeSetAttribute(tag_node,"z",z)
			xmlNodeSetAttribute(tag_node,"x1",x1)
			xmlNodeSetAttribute(tag_node,"y1",y1)
			xmlNodeSetAttribute(tag_node,"z1",z1)
			xmlNodeSetAttribute(tag_node,"x2",x2)
			xmlNodeSetAttribute(tag_node,"y2",y2)
			xmlNodeSetAttribute(tag_node,"z2",z2)
			xmlNodeSetAttribute(tag_node,"nx",nx)
			xmlNodeSetAttribute(tag_node,"ny",ny)
			xmlNodeSetAttribute(tag_node,"nz",nz)
			xmlNodeSetAttribute(tag_node,"size",size)
			xmlNodeSetAttribute(tag_node,"vis",vis)
			xmlNodeSetAttribute(tag_node,"png_off",fileGetPos(png_file))
			xmlNodeSetAttribute(tag_node,"png_len",fileWrite(png_file,png))
			destroyElement(tag)
		end
	end
	fileClose(png_file)
	xmlSaveFile(tags_file)
	xmlUnloadFile(tags_file)
end

