function onResourceStart()
	local node = xmlLoadFile ( "mods.xml" )
	if (node) then
		local children = xmlNodeGetChildren ( node )
		for k,v in ipairs(children) do
			local DFF = xmlNodeGetAttribute(v, "DFF")
			local TXD = xmlNodeGetAttribute(v, "TXD")
			local Model = tonumber(xmlNodeGetAttribute(v, "model"))
			if (DFF and TXD and Model) then
				engineImportTXD ( engineLoadTXD ( TXD ), Model )
				engineReplaceModel ( engineLoadDFF ( DFF,  Model ), Model )
			end
		end
	else
		local root = xmlCreateFile ( "mods.xml", "mods" )
		local root = xmlCreateChild ( root, "mod" )
		xmlSaveFile ( root )
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), onResourceStart)