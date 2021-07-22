
local tables={ 	-- define table positions here
  -- x,y,z, dimension, interior
	{ 4380.3935546875, 1586.1005859375, 11.320322036743, 0,0}, 
	{ 4384.3935546875, 1578.1005859375, 11.320322036743, 0,0}, 
	{ 4394.3935546875, 1573.1005859375, 11.320322036743, 0,0}, 
	{ 4407.3935546875, 1552.1005859375, 11.320322036743, 0,0}, 
	-- you can define as many tables, as you wish
 }

I=0
D=0
Z=13.3
local W=1.9
local H=1

local ballObjectIDs={ 3106, 3100, 3101, 3102, 3103, 3104, 3105, 3002, 2995, 2996, 2997, 2998, 2999, 3000, 3001}


--2964

local function utworzBile(oid, x,y, z, d,i)
	local bila=createObject(oid, x,y,z)
	setElementDimension(bila, d)
	setElementInterior(bila,i)
	setElementFrozen(bila, true)
	return bila
end


local function createBalls(tableNumber)
	if (tables[tableNumber].bile) then
		for i,v in ipairs(tables[tableNumber].bile) do
			destroyElement(v.object)
		end
	end

	ballObjectIDs=shuffle(ballObjectIDs)
  tables[tableNumber].bile={}
  local row=1
  local wrzedzie=0
  for i=1,15 do
  	tables[tableNumber].bile[i]={}
----	bile[i].object=utworzBile(ballObjectIDs[i], 936.71+(row/14), 2507.05+(wrzedzie/14)-(row/28))
	tables[tableNumber].bile[i].object=utworzBile(ballObjectIDs[i], tables[tableNumber][1]-W*10/30+((5-row)/14), tables[tableNumber][2]+(wrzedzie/12)-(row/28)+0.035, tables[tableNumber][3], tables[tableNumber][4],tables[tableNumber][5])
	tables[tableNumber].bile[i].movement={0,0}
	wrzedzie=wrzedzie+1
	if (wrzedzie==row) then
		row=row+1
		wrzedzie=0
	end
  end

  tables[tableNumber].bile[16]={}
  tables[tableNumber].bile[16].object=utworzBile(3003, tables[tableNumber][1]+W*7/30, tables[tableNumber][2], tables[tableNumber][3], tables[tableNumber][4],tables[tableNumber][5])

end

local function createPots(tableNumber)
	tables[tableNumber].luzy={}
	table.insert(tables[tableNumber].luzy, createColSphere(tables[tableNumber][1]+W/2, tables[tableNumber][2]+H/2, tables[tableNumber][3]-0.1,0.15))
	table.insert(tables[tableNumber].luzy, createColSphere(tables[tableNumber][1]-W/2, tables[tableNumber][2]+H/2, tables[tableNumber][3]-0.1, 0.15))
	table.insert(tables[tableNumber].luzy, createColSphere(tables[tableNumber][1]+W/2, tables[tableNumber][2]-H/2, tables[tableNumber][3]-0.1, 0.15))
	table.insert(tables[tableNumber].luzy, createColSphere(tables[tableNumber][1]-W/2, tables[tableNumber][2]-H/2, tables[tableNumber][3]-0.1, 0.15))

	table.insert(tables[tableNumber].luzy, createColSphere(tables[tableNumber][1]    , tables[tableNumber][2]-H/1.8, tables[tableNumber][3]-0.1, 0.15))
	table.insert(tables[tableNumber].luzy, createColSphere(tables[tableNumber][1]    , tables[tableNumber][2]+H/1.8, tables[tableNumber][3]-0.1, 0.15))

	for i,v in ipairs(tables[tableNumber].luzy) do
		setElementDimension(v, tables[tableNumber][4])
		setElementInterior(v,tables[tableNumber][5])
		setElementData(v,"type","pot",false)
		setElementData(v, "table_id", tableNumber, false)
	end
end

for i,v in ipairs(getElementsByType("player")) do
	takeWeapon(v,7)
end

for i,v in ipairs(tables) do
	v.object=createObject(2964, v[1], v[2], v[3]-1)
	setElementInterior(v.object, v[5])
	setElementDimension(v.object, v[4])
--	setElementData(v.object,"customAction",{label="Ułóż bile",resource="lss-billard",funkcja="menu_resettableNumberu",args={tableNumber=i}})

	v.cs=createColSphere(v[1], v[2], v[3], 3)
	setElementInterior(v.cs, v[5])
	setElementDimension(v.cs, v[4])
	setElementData(v.cs, "table_id", i, false)

--[[ this should be delayed
	for i,v in ipairs(getElementsWithinColShape(v.cs,"player")) do
		triggerClientEvent(v, "onNearTable", resourceRoot)
		giveWeapon(v, 7, 1, true)
	end
]]--

	createBalls(i)
	createPots(i)
end

local function deleteBall(obiekt,tableNumber)
			for i,v in ipairs(tables[tableNumber].bile) do
				if (v.object==obiekt) then
					table.remove(tables[tableNumber].bile, i)
					destroyElement(obiekt)
					return true
				end
			end
		return false
end

addEventHandler("onColShapeHit", resourceRoot, function(el,md)
	if (not md) then return end
	if (getElementInterior(source)~=getElementInterior(el)) then return end
	if (getElementDimension(source)~=getElementDimension(el)) then return end

	local idx=getElementData(source, "table_id")
	if not idx then return end

	local st=getElementData(source,"type")
	if st and st=="pot" then
		if getElementType(el)~="object" then return end
		local model=getElementModel(el)
		if ballNames[model] and deleteBall(el, idx) then
			triggerEvent("broadcastCaptionedEvent", source, ballNames[model].." hits the pot.", 5, 5, true)
		end
		return
	end

	if (getElementType(el)~="player") then return end

	triggerClientEvent(el, "onNearTable", resourceRoot, tables[idx][1], tables[idx][2], tables[idx][3], W, H)
	giveWeapon(el, 7, 1, true)
end)

addEventHandler("onColShapeLeave", resourceRoot, function(el,md)
	if (not md) then return end
	if (getElementType(el)~="player") then return end
	triggerClientEvent(el, "onNearTable", resourceRoot, nil)
	takeWeapon(el,7)
end)

local function findTableNumber(plr)
	for i,v in ipairs(tables) do
		if isElementWithinColShape(plr,v.cs) then return i end
	end
	return nil
end


-- triggerServerEvent("doPoolShot", resourceRoot, localPlayer, x,y,x2,y2)
addEvent("doPoolShot", true)
addEventHandler("doPoolShot", resourceRoot, function(plr, x,y, x2,y2, bila)
--	outputDebugString("PoolShot")
	if not bila then return end
	if getPedWeapon(plr)~=7 then return end

	local tableNumber=findTableNumber(plr)
	if not tableNumber then return end

	for i,v in ipairs(tables[tableNumber].bile) do
			if v.object==bila then
				local bx,by=getElementPosition(v.object)
				local force=(getDistanceBetweenPoints2D(x,y,bx,by)*2)
				
				v.movement={(bx-x)/force,(by-y)/force}
--				outputDebugString(tostring((x-x2)/))
				billardProcess(tableNumber)
				if (not tables[tableNumber].timer) then
					tables[tableNumber].timer=setTimer(billardProcess, 75, 0, tableNumber)
				end
				return
			end
	end
end)


function billardProcess(tableNumber)
	if (getTickCount()-(tables[tableNumber].lastTick or 0)<25) then return end
	tables[tableNumber].lastTick=getTickCount()

	local totalMovement=0

	for i,v in ipairs(tables[tableNumber].bile) do
		if v.movement then -- and (v.movement[1]~=0 or v.movement[2]~=0) then

			local x,y,z=getElementPosition(v.object)
			local nx=x+(v.movement[1]/10)
			local ny=y+(v.movement[2]/10)

--			local rotx,roty,rotz=getElementRotation(v.object)
--			setElementRotation(v.object, rotx-v.movement[1]*60, roty, rotz) -- needs calculating

			if (nx<tables[tableNumber][1]-W/2 or nx>tables[tableNumber][1]+W/2)  then
				v.movement[1]=-v.movement[1]
			elseif (ny<tables[tableNumber][2]-H/2 or ny>tables[tableNumber][2]+H/2)  then
				v.movement[2]=-v.movement[2]
--				setElementPosition(v.object,x,y,z)
			else
--				moveObject(v.object, 75, nx,ny,z)
				setElementPosition(v.object,nx,ny,z)
				v.movement[1]=v.movement[1]/1.02
				v.movement[2]=v.movement[2]/1.02
				if (math.abs(v.movement[1])<0.05) then v.movement[1]=0 end
				if (math.abs(v.movement[2])<0.05) then v.movement[2]=0 end
			end
			-- collisions with other balls
			local force=math.abs(v.movement[1])+math.abs(v.movement[2])+0.001
			local collisions=0
			for i2,v2 in ipairs(tables[tableNumber].bile) do
				if (i2~=i and v2.movement and v.object and isElement(v.object)) then
					local x,y=getElementPosition(v.object)
					local x2,y2=getElementPosition(v2.object)
					if (getDistanceBetweenPoints2D(x,y,x2,y2)<0.08) then

						collisions=collisions+1
						local rx=x-x2
						local ry=y-y2
						v2.movement[1]=v2.movement[1]-(force*10*rx)
						v2.movement[2]=v2.movement[2]-(force*10*ry)

						if (force>0.25) then
							triggerClientEvent(root, "playBallSound", v2.object)
						end
					end
				end
			end
			if (collisions>0) then
--				v.movement[1]=v.movement[1]/(1+math.sqrt(collisions)
--				v.movement[2]=v.movement[2]/(1+math.sqrt(collisions)
				v.movement[1]=v.movement[1]/(1+collisions)
				v.movement[2]=v.movement[2]/(1+collisions)


			end
			totalMovement=totalMovement+math.abs(v.movement[1])+math.abs(v.movement[2])
		end

	end


	if totalMovement==0 and tables[tableNumber].timer and isTimer(tables[tableNumber].timer) then
		killTimer(tables[tableNumber].timer)
		tables[tableNumber].timer=nil
	end
end




-- this is a dummy placeholder for code to reset balls on table
-- usually you should bind it to gui or something like that.
addCommandHandler("resettable",function(plr,cmd,tn)
	tn=tonumber(tn)

	if not tn then
		outputChatBox("Use: /resettable <table number>", plr)
		return
	end

	if not tables[tn] then return end
--[[
	if (tables[tn].bile) then
		if (#tables[tn].bile>1) then
			outputChatBox("(( All balls must be in pots. ))", plr)
			return
		end
	end
]]--
	createBalls(tn)
	triggerEvent("broadcastCaptionedEvent", plr, getPlayerName(plr) .. " repositions balls on table.", 5, 5, true)
end)                                                                   