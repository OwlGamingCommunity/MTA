temp=nil
_c=createObject

-- Client only function
-- Sucks that we basically have to use 3 different types of createObject functions across our script because someone was stupid, also we can't really remove the dim variable now that it was used and alpha was made
-- object createObject(int model, float x, float y, float z, [float rotx, float roty, float rotz, int interior, int dimension, int alpha, float scalex, float scaley, float scalez, bool collisions, bool breakable] )
function createObject(m,x,y,z,a,b,c,i,d,e,sx,sy,sz,col,brea)
	local t=_c(m,x,y,z,a,b,c)
	if d then
		setElementDimension(t,d)
	end
	if i then
		setElementInterior(t,i)
	end
	if e then
		setElementAlpha(t,e)
	end
	if sx then
		setObjectScale(t,sx,sy,sz)
	end
	if col then
		setElementCollisionsEnabled(t, col)
	end
	if brea then
		setObjectBreakable(t, brea)
	end
	return t
end
