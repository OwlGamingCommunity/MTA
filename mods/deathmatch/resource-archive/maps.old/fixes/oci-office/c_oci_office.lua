-- ERMAGHERD PLS DONT STEEL M8

office1 = nil
office2 = nil

function hookItUpM8()
	bildcol = engineLoadCOL("office.col") -- This is the object of the floors that had no collision what so ever, now dey solid as funk, enjoy k
    engineReplaceCOL(bildcol, 3781)
	bildcol = engineLoadCOL("office2.col") -- This is the structure of the building, I have included the glass and inside walls in this to save doing 3 collsion files, smart adamz k
    engineReplaceCOL(bildcol, 4587)
end
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()),
     function()
         hookItUpM8()
			-- first u lick it, DEN U STICK IT
		 setTimer(fixPlsM8, 1000, 1)
end
)

function fixPlsM8()
	-- Create them, then hide them cus MTA is hella fuk bwoi and needs some work around for this shit
	office1 = createObject(3781, 1803.085938, -1294.203125, 34.34375)
	office2 = createObject(3781, 1803.085938, -1294.203125, 61.578125)
	office3 = createObject(3781, 1803.085938, -1294.203125, 88.8046875)
	office4 = createObject(3781, 1803.085938, -1294.203125, 116.03125)
	office5 = createObject(4587, 1803.085938, -1294.203125, 71.53125)
	
	setElementAlpha(office1, 0)
	setElementAlpha(office2, 0)
	setElementAlpha(office3, 0)
	setElementAlpha(office4, 0)
	setElementAlpha(office5, 0)
end

-- luv from adams 2 shadow