--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Client-side script: The grid
--Last updated 12.03.2015 by Exciter
--Copyright 2008-2015, The Roleplay Project (www.roleplayproject.com)

local SAMapFilesCache

function restoreSA()
	if SAMapFilesCache then
		processSAMaps(SAMapFilesCache)
	else
		triggerServerEvent("grid:getSAMaps", root)
	end
end

function processSAMaps(maps)
	if maps then
		if not SAMapFilesCache then SAMapFilesCache = maps end
		for k,v in ipairs(maps) do
			local xml = xmlLoadFile(v)
			if xml then
				local index = 0
				local node = xmlFindChild(xml, "removeWorldObject", index)
				local count = 1
				while node do
					local radius = tonumber(xmlNodeGetAttribute(node, "radius"))
					local model = tonumber(xmlNodeGetAttribute(node, "model"))
					local lodModel = tonumber(xmlNodeGetAttribute(node, "lodModel"))
					local posX = tonumber(xmlNodeGetAttribute(node, "posX"))
					local posY = tonumber(xmlNodeGetAttribute(node, "posY"))
					local posZ = tonumber(xmlNodeGetAttribute(node, "posZ"))
					removeWorldModel(model, radius, posX, posY, posZ, 0)
					index = index + 1
					node = xmlFindChild(xml, "removeWorldObject", index)
				end
				xmlUnloadFile(xml)
			end
		end
	end
end
addEvent("grid:clientGetSAMaps", true)
addEventHandler("grid:clientGetSAMaps", root, processSAMaps)