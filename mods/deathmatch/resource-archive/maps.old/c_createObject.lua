_c=createObject

function createObject(m,x,y,z,a,b,c,i,d,lod)
	local t
	if lod then
		t=_c(m,x,y,z,a,b,c,true)
	else
		t=_c(m,x,y,z,a,b,c)
	end
	if d then
		setElementDimension(t,d)
	end
	if i then
		setElementInterior(t,i)
	end
	--setElementData(v, "collisions", "true")
	if isElement(source) then
		setElementCollisionsEnabled(source, true)
	end
	return t
end
