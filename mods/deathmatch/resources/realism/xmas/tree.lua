local x1 = 1479.455078125
local y1 = -1686.5869140625
local z1 = 11.046875

local objects1 = {
	 createObject(654, x1, y1, z1), 
	createObject(3038, x1-2, y1-2, z1+8, 0, 0, 45),
	createObject(3038, x1-2, y1-2, z1+12, 0, 0, 45),
	createObject(3038, x1-2, y1-2, z1+16, 0, 0, 45),

	createObject(3038, x1, y1+3, z1+8, 0, 0, 270),
	createObject(3038, x1, y1+3, z1+12, 0, 0, 270),
	createObject(3038, x1, y1+3, z1+16, 0, 0, 270),

	createObject(3038, x1+3, y1, z1+8, 0, 0, 180),
	createObject(3038, x1+3, y1, z1+12, 0, 0, 180),
	createObject(3038, x1+3, y1, z1+16, 0, 0, 180)
}

local x2 = 1479.455078125
local y2 = -1686.5869140625
local z2 = 11.046875

local objects2 = {
	createObject(654, x2, y2, z2),
	createObject(3038, x2-2, y2-2, z2+8, 0, 0, 45),
	createObject(3038, x2-2, y2-2, z2+12, 0, 0, 45),
	createObject(3038, x2-2, y2-2, z2+16, 0, 0, 45),

	createObject(3038, x2, y2+3, z2+8, 0, 0, 270),
	createObject(3038, x2, y2+3, z2+12, 0, 0, 270),
	createObject(3038, x2, y2+3, z2+16, 0, 0, 270),

	createObject(3038, x2+3, y2, z2+8, 0, 0, 180),
	createObject(3038, x2+3, y2, z2+12, 0, 0, 180),
	createObject(3038, x2+3, y2, z2+16, 0, 0, 180)
}

for _, object in ipairs( objects2 ) do
	setElementDimension(object, 1)
end