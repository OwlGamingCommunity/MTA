--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Server-side script: The grid
--Last updated 26.03.2015 by Exciter
--Copyright 2008-2015, The Roleplay Project (www.roleplayproject.com)

local SAMapFilesCache
local clientsWaitingForSAMaps = {}
local isLoadingSAMaps = false

function getSAMaps()
	if not SAMapFilesCache or isLoadingSAMaps then
		if isLoadingSAMaps then
			table.insert(clientsWaitingForSAMaps, client)
			return
		end
		isLoadingSAMaps = true
		SAMapFilesCache = {}
		local extension = ".map"
		local xml = xmlLoadFile("meta.xml")
		if xml then
			local index = 0
			local node = xmlFindChild(xml, "map", index)
			local count = 1
			while node do
				local src = xmlNodeGetAttribute(node, "src")
				if src and src:sub(-#extension) == extension then
					table.insert(SAMapFilesCache, src)
					count = count + 1
				end
				index = index + 1
				node = xmlFindChild(xml, "map", index)
			end
		end
		isLoadingSAMaps = false
		for k,v in ipairs(clientsWaitingForSAMaps) do
			triggerClientEvent(v, "grid:clientGetSAMaps", v, SAMapFilesCache)
		end
	end
	triggerClientEvent(client, "grid:clientGetSAMaps", client, SAMapFilesCache)
end
addEvent("grid:getSAMaps", true)
addEventHandler("grid:getSAMaps", root, getSAMaps)