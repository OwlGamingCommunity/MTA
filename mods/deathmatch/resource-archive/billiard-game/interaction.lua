addEvent("setPedAnimation", true)
addEventHandler("setPedAnimation", root, function(block,anim,time,loop,updatePosition,interruptable, freezeLastFrame)

	if (time==nil) then time=-1 end
	if (loop==nil) then loop=true end
	if (updatePosition==nil) then updatePosition=true end
	if (interruptable==nil) then interruptable=true end
	if (freezeLastFrame==nil) then freezeLastFrame=true end
--	bool setPedAnimation ( ped thePed [, string block=nil, string anim=nil, int time=-1, bool loop=true, bool updatePosition=true, bool interruptable=true, bool freezeLastFrame = true] )
	setPedAnimation(source, block, anim, time, loop, updatePosition, interruptable, freezeLastFrame)

end)

-- sends message to players near source
addEvent("broadcastCaptionedEvent", true)
addEventHandler("broadcastCaptionedEvent", root, function(descr, lifetime, range, includesource)
    if (not source or not isElement(source)) then return end

    local x,y,z=getElementPosition(source)
    local area=createColSphere(x,y,z,range)
    local gracze=getElementsWithinColShape(area, "player")
    for i,v in ipairs(gracze) do
	if ((includesource or (source~=v)) and getElementInterior(v)==getElementInterior(source) and getElementDimension(v)==getElementDimension(source)) then
	    outputChatBox("* " .. descr, v)
	end
    end
    destroyElement(area)
end)