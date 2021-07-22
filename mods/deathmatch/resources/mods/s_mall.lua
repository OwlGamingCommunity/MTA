--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Server-side script: Verona Mall mod
--Last updated 29.03.2013 by Exciter
--Copyright 2008, The Roleplay Project (www.roleplayproject.com)

function createObjectEx(model,x,y,z,rx,ry,rz,lod)
	local object = createObject(model,x,y,z,rx,ry,rz,(lod and true or false))
	setElementDoubleSided(object, true)
	
	--for mapping server:
	--[[
	local object2 = createObject(model,x,y,z,rx,ry,rz,(lod and true or false))
	setElementDoubleSided(object2, true)
	setElementDimension(object2, 200)
	--]]
end

--function doMallMapping()
	removeWorldModel(6130, 20000, 0, 0, 0)
	removeWorldModel(6255, 20000, 0, 0, 0)

	createObjectEx(2036,1117.5799561,-1490.0100098,32.7200012,0.0000000,0.0000000,0.0000000) --object(cj_psg1) (1)
	createObjectEx(2036,1117.5799561,-1490.0100098,32.7200012,0.0000000,0.0000000,0.0000000,true) --object(cj_psg1) (1)
	createObjectEx(2967,1117.5799561,-1490.0100098,32.7200012,0.0000000,0.0000000,0.0000000) --object(mobile1993a) (1)
	createObjectEx(2967,1117.5799561,-1490.0100098,32.7200012,0.0000000,0.0000000,0.0000000, true) --object(mobile1993a) (1)
--end
--addEventHandler("onResourceStart", getResourceRootElement(), doMallMapping)