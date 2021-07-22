--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Client-side script: The grid
--Last updated 12.03.2015 by Exciter
--Copyright 2008-2015, The Roleplay Project (www.roleplayproject.com)

function spawnMap(file, dim)
	if not file or not dim then return false end
	local xml = xmlLoadFile(file)
	if xml then
		local index = 0
		local node = xmlFindChild(xml, "object", index)
		local count = 1
		while node do
			local breakable = tostring(xmlNodeGetAttribute(node, "breakable")) == "true"
			local alpha = tonumber(xmlNodeGetAttribute(node, "alpha"))
			local model = tonumber(xmlNodeGetAttribute(node, "model"))
			local doublesided = tostring(xmlNodeGetAttribute(node, "doublesided")) == "true"
			local scale = tonumber(xmlNodeGetAttribute(node, "scale"))
			local posX = tonumber(xmlNodeGetAttribute(node, "posX"))
			local posY = tonumber(xmlNodeGetAttribute(node, "posY"))
			local posZ = tonumber(xmlNodeGetAttribute(node, "posZ"))
			local rotX = tonumber(xmlNodeGetAttribute(node, "rotX"))
			local rotY = tonumber(xmlNodeGetAttribute(node, "rotY"))
			local rotZ = tonumber(xmlNodeGetAttribute(node, "rotZ"))

			local obj = createObject(model, posX, posY, posZ, rotX, rotY, rotZ, false)
			setElementInterior(obj, 0)
			setElementDimension(obj, dim)
			setObjectBreakable(obj, breakable)
			setElementAlpha(obj, alpha)
			setElementDoubleSided(obj, doublesided)
			setObjectScale(obj, scale)
			
			index = index + 1
			node = xmlFindChild(xml, "object", index)
		end
		xmlUnloadFile(xml)
		return true
	end
	return false
end