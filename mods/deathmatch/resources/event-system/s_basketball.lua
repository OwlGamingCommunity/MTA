local balls = {} -- Table
local baskets = {} -- Table
local boundries = {} -- Table

function newBall(x, y, z)
	local basketball = createObject(3065, x, y, z)
	local ballid = #balls + 1
	setElementData(basketball, "id", ballid, false)
    setElementData(basketball, "spawnposX", x, false)
    setElementData(basketball, "spawnposY", y, false)
    setElementData(basketball, "spawnposZ", z, false)
	balls[ ballid ] = basketball
	triggerClientEvent("basketball:announceball", basketball, ballid)
end

function requestBalls()
	for ballID, ballObject in pairs(balls) do
		triggerClientEvent(client, "basketball:announceball", ballObject, ballID)
	end
end
addEvent("basketball:announceball", true)
addEventHandler("basketball:announceball", getRootElement(), requestBalls)

function updateBallStatus(isBallInHand, fakeClient, fakeSource, doDropball)
	if fakeClient then -- not only females fake things!
		client = fakeClient
	end
	if fakeSource then
		source = fakeSource
	end
	if not doDropball then
		doDropball = true
	end

	setElementData(source, "heldby", isBallInHand and client or false, true)
	triggerClientEvent("basketball:cstatus", client, source, isBallInHand, doDropball)
end
addEvent("basketball:status", true)
addEventHandler("basketball:status", getRootElement(), updateBallStatus)

function isPlayerHoldingBall(thePlayer, theBall)
	for ballID,ballObject in pairs(balls) do
		local beingHeldBy = getElementData(ballObject, "heldby")
		if (beingHeldBy) and (isElement(beingHeldBy)) then
			if (beingHeldBy == thePlayer) then
				if not theBall then
					return true, ballObject
				else
					if theBall == ballObject then
						return true, ballObject
					end
				end
			end
		end
	end
	return false
end

function getClosestBasket(thePlayer)
	local pX, pY, pZ = getElementPosition(thePlayer)
	local current = 12
	local foundElement = false
	
	for basketID,basketShape in pairs(baskets) do
		local basketX, basketY, basketZ = getElementPosition(basketShape)
		local distance2D = getDistanceBetweenPoints2D(pX,pY,basketX,basketY)
		if distance2D < current then
			foundElement = basketShape
			current = distance2D
		end
	end
	return foundElement, current
end

function checkDunkThing(thePlayer)
    if isElement(thePlayer) and getElementType(thePlayer) == "player" and isPedOnGround(thePlayer) then
		local theBasket = source
		local isHoldingBall, ballElement = isPlayerHoldingBall(thePlayer)
		if isHoldingBall then
			local px, py, pz = getElementPosition(thePlayer)
			local basketX, basketY, basketZ = getElementPosition(theBasket)
			updateBallStatus(false, thePlayer, ballElement, false)
			setElementPosition(thePlayer, basketX, basketY, pz)
			setElementPosition(ballElement, basketX, basketY, pz+2)
			setPedAnimation(thePlayer,"BSKTBALL", "BBALL_Dnk_Gli", 1000, false, false, false)
			setTimer(setPedAnimation,500, 1, thePlayer,"BSKTBALL", "BBALL_Dnk",2000,false,false,false)
			setTimer(setPedAnimation,2000, 1, thePlayer,"BSKTBALL", "BBALL_Dnk_Lnd",5000,false,false,false)
			
			setTimer(function()
				setPedAnimation(thePlayer)
			end, 3000, 1)
			
			exports.global:sendLocalMeAction(thePlayer, "jumps up and grabs onto the hoop, dunking the ball through the net.")
		
			setTimer(triggerClientEvent,300,1,"bball:soundBoard",getRootElement(),1,theBasket) -- Play the sound
			setTimer(triggerClientEvent,300,1,"bball:soundBoard",getRootElement(),3,theBasket) -- Play the sound
			setTimer(moveObject,200,1,ballElement,400,basketX, basketY,pz-0.9)
			setTimer(moveObject,600,1,ballElement,200,basketX, basketY,pz-0.4)
			setTimer(moveObject,800,1,ballElement,200,basketX, basketY,pz-0.9)
			setTimer(moveObject,1000,1,ballElement,200,basketX, basketY,pz-0.7)
			setTimer(moveObject,1200,1,ballElement,200,basketX, basketY,pz-0.85)
        end
    end
end


function passBall(thePlayer)
	if getPedOccupiedVehicle(thePlayer) then
		return
	end
    if isPedOnGround(thePlayer) then
	local theBasket = source
	local isHoldingBall, ballElement = isPlayerHoldingBall(thePlayer)
	local reachedBoundries=checkBoundries(thePlayer)
	    if isHoldingBall then
	        if reachedBoundries then
				outputChatBox("Don't throw ball out of the court.", thePlayer, 255,0,0)
	        else
				local px, py, pz = getElementPosition(thePlayer)
				local pr=getPedRotation(thePlayer)
				setTimer(updateBallStatus,100,1,false, thePlayer, ballElement, false)
				local hx,hy=findPosition(px,py,pr,1)
				setTimer(setElementPosition,101,1,ballElement, px,py,pz+0.3)
				local hx,hy=findPosition(px,py,pr,2)
				setTimer(moveObject,150,1,ballElement,100,hx,hy,pz+0.5)
				local hx,hy=findPosition(px,py,pr,3)
				setTimer(moveObject,250,1,ballElement,100,hx,hy,pz+0.2)
				local hx,hy=findPosition(px,py,pr,4)
				setTimer(moveObject,350,1,ballElement,100,hx,hy,pz-0.4)
				local hx,hy=findPosition(px,py,pr,5)
				setTimer(moveObject,450,1,ballElement,100,hx,hy,pz-0.85)

			exports.global:sendLocalMeAction(thePlayer, "passes the ball.")				
	        end
	    end
	end
end
addCommandHandler("passball",passBall)

function dropBall(thePlayer)
	if getPedOccupiedVehicle(thePlayer) then
		return
	end
    if isPedOnGround(thePlayer) then
	local theBasket = source
	local isHoldingBall, ballElement = isPlayerHoldingBall(thePlayer)
	    if isHoldingBall then
	    local px, py, pz = getElementPosition(thePlayer) 
	    setTimer(updateBallStatus,100,1,false, thePlayer, ballElement, false)
        setTimer(setElementPosition,101,1,ballElement, px,py,pz)
        setTimer(moveObject,150,1,ballElement,100,px,py,pz-0.85)
		
		exports.global:sendLocalMeAction(thePlayer, "drops the ball.")	
        end
    end
end
addCommandHandler("dropball",dropBall)

function makeBasket(x, y)
	local basket = createColCircle(x, y ,1)
	local basketid = #baskets + 1
	setElementData(basket, "id", basketid, false)
	baskets[ basketid ] = basket
	addEventHandler("onColShapeHit", basket, checkDunkThing)
end

function makeBoundry(x,y,hx,hy,int,dim)
    local boundry = createColRectangle(x,y,hx,hy)
    setElementData(boundry,"posx",x)
    setElementData(boundry,"posy",y)
    setElementData(boundry,"sizex",hx)
    setElementData(boundry,"sizey",hy)
	setElementInterior(boundry, int)
	setElementInterior(boundry, dim)
    local boundryid = #boundries + 1
    setElementData(boundry,"id", boundryid,false)
    boundries[ boundryid ] = boundry
	addEventHandler("onColShapeHit", boundry, enterBoundries)
    addEventHandler("onColShapeLeave", boundry, leaveBoundries)
end

function resourceStart(source)
    makeBasket(2316.8637695313, -1514.7546386719) --East Jefferson courts.Northern part 
    makeBasket( 2317.123046875, -1541.1435546875) --East Jefferson courts. Southern part 
    
    makeBasket(2290.5463867188,-1514.7840576172) --West Jefferson courts. Northern part
    makeBasket(2290.6381835938,-1541.1708984375) --West Jefferson courts. Northern part
    
    makeBasket(2795.009765625,-2019.5705566406) -- Eastern part of Seville courts.
    makeBasket(2768.6613769531,-2019.66845703) --Western part of Seville courts.
    
    makeBasket(2533.4284667969,-1667.4903564453) --Grove street
    
    makeBasket(1883.060546875, -2045.603515625) -- El Corona hoop #1
    makeBasket(1882.9990234375, -2019.279296875) -- El Corona hoop #2
    
    
    makeBasket(-1066.59765625, -734.267578125) -- San Andreas Detention Center west court
    makeBasket(-1089.1728515625, -734.5029296875) -- San Andreas Detention Center west court
    
    makeBasket(-1009.2783203125, -735.5224609375) -- San Andreas Detention Center east court
    makeBasket(-1031.3330078125, -735.64453125) -- San Andreas Detention Center east court
    
    makeBasket(1916.3736572266, -1809.603515625) -- IGS West
    makeBasket(1941.6259765625, -1809.4384765625) -- IGS East
    
    makeBasket(2310.3525390625, -1775.951171875) -- Liverpool first
    makeBasket(2316.048828125, -1775.82421875)
    makeBasket(2320.64453125, -1775.6865234375)
    makeBasket(2326.0576171875, -1775.73046875)
    makeBasket(2326.0234375, -1791.802734375)
    makeBasket(2320.40625, -1791.7666015625)
    makeBasket(2315.822265625, -1791.681640625)
    makeBasket(2310.4755859375, -1791.521484375) -- Liverpool end
    makeBoundry(2308.06640625, -1792.985351562, 21,20,0,0) -- Liverpool Courts
    
    makeBoundry(2305.998046875,-1543.10546875,21.46,30.37,0,0) -- East Jefferson Courts
    makeBoundry(2279.7482910156,-1542.8782958984,20.786,29.73,0,0) -- West Jefferson Courts
    makeBoundry(2766.8815917969,-2029.9149169922,30.111,21.094,0,0) -- Seville Courts
    makeBoundry(2522.3217773438,-1670.9796142578,11.676,6.875,0,0) -- Grove Street
    
    makeBoundry(-1032.8837890625, -742.7236328125, 25, 13,0,0) -- San Andreas Detention Center east court
    
    makeBoundry(1915.119140625, -1815.615234375, 29, 13, 0, 0) -- IGS
    --makeBoundry(-1498.8330078125, 1133.39, 18.5, 13.15,0,0) -- San Fierro Correctional Facility Outdoor Quarters
    --makeBoundry(-1498.8330078125, 1146.89, 18.5, 13.15,0,0) -- San Fierro Correctional Facility Outdoor Quarters
	
	makeBoundry(1878, -2046.9111328125, 10, 29, 0, 0) -- El Corona
  
    setTimer(newBallPls, 5000, 1)
end
addEventHandler("onResourceStart",getResourceRootElement(getThisResource()),resourceStart)

function newBallPls()
	newBall(-1078.763671875, -735.1484375, 32.0078125) -- San Andreas Detention Center west court
	newBall(-1018.474609375, -735.3349609375, 32.0078125) -- San Andreas Detention Center east court
	newBall(2313.2878417969,-1525.4807128906,24.5) --Jefferson Courts, eastern part
	newBall(2292.96875,-1526.2958984375,26) --Jefferson courts, western part
    newBall(2782.0437011719,-2019.4356689453,12.7) --Seville courts
    newBall(2528.85,-1665.2897949219,14.267136192322) --Grove street
    newBall(1928.27734375, -1810.1484375, 12.925015068054) -- IGS
    newBall(2326.3193359375, -1782.97460937, 12.7) -- Liverpool 1
    newBall(2320.8330078125, -1783.7294921875, 12.7) -- Liverpool 2
    newBall(2317.0693359375, -1783.767578125, 12.7) -- Liverpool 3
    newBall(2310.4853515625, -1783.765625, 12.7) -- Liverpool 4
	newBall(1882.9462890625, -2032.9, 12.55) -- El Corona
end

function shootBall(thePlayer,command)
	if getPedOccupiedVehicle(thePlayer) then
		return
	end
	
    if isPedOnGround(thePlayer) then
		local isHoldingBall, ballElement = isPlayerHoldingBall(thePlayer)
	    if isHoldingBall then
			local theBasket, theDistance = getClosestBasket(thePlayer)
			if not theBasket then
				return -- No basket even near
			end
			
			local basketX, basketY, basketZ = getElementPosition(theBasket)
			local px, py, pz = getElementPosition(thePlayer)
			local ballX, ballY, ballZ = getElementPosition(ballElement)
			local pr = getPedRotation(thePlayer)
			local pRotation=findRotation(px, py,basketX,basketY)
			setPedRotation(thePlayer,pRotation)
			local theDistance = getDistanceBetweenPoints2D(px,py,basketX,basketY)
			
			setPedAnimation(thePlayer, "BSKTBALL", "BBALL_Jump_Shot", 1000, false, false, true, false)
			
			exports.global:sendLocalMeAction(thePlayer, "attempts to shoot as he throws the ball towards the hoop.")		
			
			setTimer(updateBallStatus,600,1,false, thePlayer, ballElement, false)
			
			setTimer(setElementPosition,650,1,ballElement, px,py,pz+0.5)
			
			setTimer(function()
				setPedAnimation(thePlayer)
			end, 1100, 1)

			chanceDistance = theDistance - 3 --chance to score
			if (chanceDistance <= 1) then 
				chanceDistance = 2
			end
			
			local luck = math.random(1,chanceDistance)

			local hxc=(px+basketX)/2   --x center of player and basket 
			local hyc=(py+basketY)/2   --y center of player and basket 
			local hzc=pz+4             --z center of player and basket 

			local hxs=(px+hxc)/2               --x center of player and hxc
			local hys=(py+hyc)/2               --y center of player and hyc
			local hzs=pz+3                     --z center of player and hzc


			local hxe=(hxc+basketX)/2  --x center of hxc and basket
			local hye=(hyc+basketY)/2  --y center of hyc and basket
			local hze=pz+3                     --z center of hzc and basket

			local hxb=(hxe+basketX)/2 --x center of hxe and basket
			local hyb=(hye+basketY)/2 --y center of hye and basket

			local hxf=(hxc+hxb)/2 
			local hyf=(hyc+hyb)/2
        
			if luck == 1 then
				local mSpeed = 80 + ( theDistance * 10 ) --Ball speed
				setTimer(moveObject,500,1,ballElement,mSpeed,hxs,hys,hzs)  --1st position
				setTimer(moveObject, mSpeed+500,1,ballElement,mSpeed,hxc,hyc,hzc) --2nd position
				local mTimec=mSpeed*2
				setTimer(moveObject, mTimec+500,1,ballElement,mSpeed,hxe,hye,hze) --3rd position
				local mTimed=mTimec+mSpeed
				setTimer(moveObject, mTimed+500,1,ballElement,mSpeed,basketX,basketY,pz+2) --4th (Basket) position
				local mTimee=mTimed+mSpeed
				local hzc=hzc-4.9 -- ground level
				setTimer(moveObject,mTimee+500,1,ballElement,300,basketX,basketY,hzc) --Ball falls inside the basket
            	setTimer(triggerClientEvent,mTimee+500,1,"bball:soundBoard",getRootElement(),3,theBasket) -- Play the sound
            	setTimer(moveObject,mTimee+800,1,ballElement,200,basketX,basketY,hzc+0.5)
            	setTimer(moveObject,mTimee+1000,1,ballElement,200,basketX,basketY,hzc)
            	setTimer(moveObject,mTimee+1200,1,ballElement,200,basketX,basketY,hzc+0.2)
            	setTimer(moveObject,mTimee+1400,1,ballElement,200,basketX,basketY,hzc)
				
				setTimer(function()
					local scoremessage = math.random(1, 3)
					if scoremessage == 1 then
						exports.global:sendLocalDoAction(thePlayer, "The ball lands in the hoop and slips through the net.")
					elseif scoremessage == 2 then
						exports.global:sendLocalDoAction(thePlayer, "The ball bounces off the back board and lands in the net.")
					elseif scoremessage == 3 then
						exports.global:sendLocalDoAction(thePlayer, "The ball rolls across the rim of the hoop and rolls into the net.")
					end
				end, 1300, 1)
			elseif luck > 1 then
				local mSpeed=80+(theDistance*10)
				setTimer(moveObject,500,1,ballElement,mSpeed,hxs,hys,hzs)  --1st position
				setTimer(moveObject, mSpeed+500,1,ballElement,mSpeed,hxc,hyc,hzc) --2nd position
				local mTimec=mSpeed*2
				setTimer(moveObject, mTimec+500,1,ballElement,mSpeed,hxe,hye,hze) --3rd position
				local mTimed=mTimec+mSpeed
				setTimer(moveObject, mTimed+500,1,ballElement,mSpeed,basketX,basketY,pz+2.5) --4th (Basket) position
				local mTimee=mTimed+mSpeed
				local hzc=hzc-4.9 -- ground level
				setTimer(moveObject, mTimee+500,1,ballElement,mSpeed,hxb,hyb,hzc+3.5) --5th position. Ball bounces off the board
            	local mTimef=mTimee+mSpeed
				setTimer(moveObject,mTimef+500,1,ballElement,300,hxe,hye,hzc) --Ball falls on the ground
            	setTimer(triggerClientEvent,mTimee+500,1,"bball:soundBoard",getRootElement(),4,theBasket) -- Play the sound
            	setTimer(moveObject,mTimef+800,1,ballElement,200,hxf,hyf,hzc+1)
            	setTimer(moveObject,mTimef+1000,1,ballElement,200,hxf,hyf,hzc)
				
				setTimer(function()
					local failmessage = math.random(1, 3)
					if failmessage == 1 then
						exports.global:sendLocalDoAction(thePlayer, "The ball hits the rim of the hoop and bounces off.")
					elseif failmessage == 2 then
						exports.global:sendLocalDoAction(thePlayer, "The ball bounces off the back board and misses the hoop.")
					elseif failmessage == 3 then
						exports.global:sendLocalDoAction(thePlayer, "The ball rolls across the rim of the hoop and falls outside of the hoop.")
					end
				end, 1300, 1)
		    end
		end
	end
end
addCommandHandler("shootball",shootBall)

function leaveBoundries(thePlayer)
	if getElementType ( thePlayer ) == "player" then 
		local isHoldingBall, ballElement = isPlayerHoldingBall(thePlayer)
		if isHoldingBall then
			local x = getElementData(ballElement, "spawnposX")
			local y = getElementData(ballElement, "spawnposY")
			local z = getElementData(ballElement, "spawnposZ")
			updateBallStatus(false, thePlayer, ballElement, false)
			setTimer(setElementPosition,200,1,ballElement,x,y,z)
		end
	end
end

function basketHelp(thePlayer, commandName)
	for _,boundryShape in pairs(boundries) do
        if isElementWithinColShape(thePlayer,boundryShape) then
			outputChatBox("/pickball: To pickup the ball. You have to stand close to the ball.", thePlayer)
			outputChatBox("/shootball: To shoot the ball to the closest basket.", thePlayer)
			outputChatBox("/passball: To pass the ball the direction you're facing.", thePlayer)
			outputChatBox("To dunk: just run to the basket while holding the ball.", thePlayer)
			outputChatBox("You're not required to roleplay your actions, you can make binds and play like a mini-game.", thePlayer)
		end
	end
end
addCommandHandler("baskethelp", basketHelp)

function enterBoundries(thePlayer, matchingDimension)
	if getElementType(thePlayer) == "player" and matchingDimension and not getPedOccupiedVehicle(thePlayer) and not getElementData(thePlayer, "superman:flying") then 
		outputChatBox("Welcome to the basketball court. Type /baskethelp to see the commands.", thePlayer)
	end
end

function findRotation(x1,y1,x2,y2) 
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end;
	return t
end

function findPosition(px,py,pr,pDis)
	local px = px - ( ( math.sin ( math.rad ( pr ) ) ) * pDis )
	local py = py + ( ( math.cos ( math.rad ( pr ) ) ) * pDis )
	return px, py
end

function checkBoundries(thePlayer)
    local reachedBoundries=false
    for boundryID,boundryShape in pairs(boundries) do
        if isElementWithinColShape(thePlayer,boundryShape) then
            local hx=getElementData(boundryShape,"sizex")
            local hy=getElementData(boundryShape,"sizey")
            local bX=getElementData(boundryShape,"posx")
            local bY=getElementData(boundryShape,"posy")
            local px,py,pz=getElementPosition(thePlayer)
            local r=getPedRotation(thePlayer)
            if (bX > (px-5)) and ( r> 0 and r < 180) then
				reachedBoundries=true
            elseif ((bX+hx) < (px+5)) and ( r> 180 and r < 360)  then
				reachedBoundries=true
           elseif (bY > (py-5)) and ( r> 90 and r < 270) then
				reachedBoundries=true
            elseif ((bY+hy) < (py+5)) and ( r> 270 and r < 90) then
				reachedBoundries=true
            end
            if reachedBoundries then
                return true
            else 
				return false
            end
        end
    end
end
